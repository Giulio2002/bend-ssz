import Base
import ../types/schema.bend as T
import ./buffer.bend as B
import ./sizes.bend as Z

# Structural SSZ validation directly over indexed storage.
#
# This is the decoding pass of the compact runtime: it walks a schema over a
# `Buf` window and answers whether the bytes are a legal SSZ encoding of that
# schema, checking exactly what the normative specification requires - exact
# fixed sizes, list limits, boolean bytes, bit-field terminators and padding,
# and the offset discipline of variable-size containers and lists. It copies
# nothing: byte payloads stay in the buffer and are described by (offset,
# length) pairs in `src/compact.bend`.
#
# Shape of the code. Bend has no mutual recursion, cannot match a computed
# value, and requires a self-call to keep every argument unchanged until one
# shrinks. So the walk is one self-recursive definition whose first argument is
# a `Nat` fuel, whose last argument is the buffer paired with the value read
# for this step, and whose control state is a `tag` plus a continuation frame.
# Every step performs at most one buffer read and issues the next read in its
# own self-call.
#
# Tags:
#   0  start: validate `schema` over the window [a, b)
#   1  the boolean byte at a is in v
#   2  the last byte of a bit vector is in v
#   3  the last byte of a bit list is in v
#   4  the first offset of a variable-element sequence is in v
#   5  pop: the current item is done, continue with the frame
#   8  walk the remaining field chain `schema`, header cursor a, window [c, b)
#   9  the offset of the current variable field is in v
#  10  the following offset is in v; the pending child starts at a
#  11  the offset of variable element i is in v
#  12  the offset of element i+1 is in v; the pending child starts at a
type Frame is Data:
  FDone{}
  FChain{rest: T.Schema, hp: U32, base: U32, endp: U32, pend: T.Schema, start: U32, has: U32, up: Frame}
  FRep{elem: T.Schema, left: U32, stride: U32, off: U32, up: Frame}
  FVarList{elem: T.Schema, i: U32, n: U32, base: U32, endp: U32, up: Frame}

# Bit-field helpers. `low_mask(r)` keeps the r low bits of a byte; r is 0..7,
# so it is a table rather than a variable shift.
def low_mask(+r: U32) -> U32:
  match r:
    case 0: 0
    case 1: 1
    case 2: 3
    case 3: 7
    case 4: 15
    case 5: 31
    case 6: 63
    case _: 127

# Pure selectors. Bend cannot match a computed value, so every decision is a
# selection made in its own definition and fed back as data.
def usel(c: Bool, +x: U32, +y: U32) -> U32:
  match c:
    case True{}: x
    case False{}: y

def bsel(c: Bool, x: Bool, y: Bool) -> Bool:
  match c:
    case True{}: x
    case False{}: y

def fsel(c: Bool, x: Frame, y: Frame) -> Frame:
  match c:
    case True{}: x
    case False{}: y

def ssel(c: Bool, x: T.Schema, y: T.Schema) -> T.Schema:
  match c:
    case True{}: x
    case False{}: y

def maybe_value(m: Maybe<&2, U32>, +d: U32) -> U32:
  match m:
    case None{}: d
    case Some{x}: x

def size_or(m: Maybe<&2, U32>, +d: U32) -> U32:
  match m:
    case None{}: d
    case Some{x}: x

def nat_le(+x: U32, limit: Nat) -> Bool: Nat.is_le(U32.to_nat(x), limit)

# Highest set bit position of a non-zero byte, 0..7, as a comparison chain:
# Bend has no mutual recursion, and this needs none.
def high_bit(+v: U32) -> U32:
  usel(U32.is_ge(v, 128), 7,
    usel(U32.is_ge(v, 64), 6,
      usel(U32.is_ge(v, 32), 5,
        usel(U32.is_ge(v, 16), 4,
          usel(U32.is_ge(v, 8), 3,
            usel(U32.is_ge(v, 4), 2, usel(U32.is_ge(v, 2), 1, 0)))))))

# ---------------------------------------------------------------------------
# The walk. One self-recursive definition: `tag` says what `v` holds and what
# to do, `fr` is the continuation, and `a`, `b`, `c` carry positions.
def run(+fuel: Nat, +tag: U32, +schema: T.Schema, +fr: Frame, +a: U32, +b: U32, +c: U32,
        pair: B.Buf & U32) -> B.Buf & Bool:
  match fuel:
    case 0n:
      (buf, v) = pair
      (buf, False{})
    case 1n+p:
      match tag:
        # ---- 6: reject -------------------------------------------------
        case 6:
          (buf, v) = pair
          (buf, False{})
        # ---- 0: validate `schema` over [a, b) ---------------------------
        case 0:
          match schema:
            case T.Boolean{}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), 1), 1, 6), schema, fr, a, b, c, B.byte_at(buf, a))
            case T.Unsigned{+w}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), Z.width_bytes(w)), 5, 6), schema, fr, a, b, c, (buf, 0))
            case T.ByteVector{+n}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), U32.from_nat(n)), 5, 6), schema, fr, a, b, c, (buf, 0))
            case T.ByteList{+limit}:
              (buf, v) = pair
              run(p, usel(nat_le((b - a : U32), limit), 5, 6), schema, fr, a, b, c, (buf, 0))
            case T.BitVector{+n}:
              (buf, v) = pair
              +bits = U32.from_nat(n)
              +need = Z.bit_bytes(bits)
              +rest = (bits .&. 7 : U32)
              run(p, usel(U32.is_eq((b - a : U32), need), usel(U32.is_eq(rest, 0), 5, 2), 6),
                schema, fr, a, b, rest, B.byte_at(buf, (a + need - 1 : U32)))
            case T.BitList{+limit}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), 0), 6, 3), schema, fr, a, b, c,
                B.byte_at(buf, (b - 1 : U32)))
            case T.Vector{+e, +n}:
              (buf, v) = pair
              +count = U32.from_nat(n)
              +stride = size_or(Z.fixed_size(e), 0)
              +fixed = Z.is_fixed(e)
              +len = (b - a : U32)
              # fixed elements: exact total size, then walk them in place;
              # variable elements: an offset table of `count` entries.
              +ok_fixed = U32.is_eq(len, (count * stride : U32))
              +empty = U32.is_eq(count, 0)
              run(p,
                usel(fixed, usel(ok_fixed, usel(empty, 5, 0), 6),
                     usel(U32.is_eq(len, 0), 6, 4)),
                ssel(fixed, e, schema),
                fsel(fixed, fsel(empty, fr, FRep{e, (count - 1 : U32), stride, (a + stride : U32), fr}), fr),
                usel(fixed, a, a), usel(fixed, (a + stride : U32), b), count,
                B.read32(buf, a))
            case T.ListOf{+e, +limit}:
              (buf, v) = pair
              +stride = size_or(Z.fixed_size(e), 0)
              +fixed = Z.is_fixed(e)
              +len = (b - a : U32)
              +count = usel(U32.is_eq(stride, 0), 0, U32.div(len, stride))
              +exact = U32.is_eq(len, (count * stride : U32))
              +within = nat_le(count, limit)
              +empty = U32.is_eq(len, 0)
              run(p,
                usel(empty, 5,
                  usel(fixed, usel(bsel(exact, within, False{}), 0, 6), 4)),
                ssel(fixed, e, schema),
                fsel(fixed, FRep{e, (count - 1 : U32), stride, (a + stride : U32), fr}, fr),
                a, usel(fixed, (a + stride : U32), b), 0,
                B.read32(buf, a))
            case T.Container{names, +fields}:
              (buf, v) = pair
              +fp = Z.fixed_part(fields)
              +len = (b - a : U32)
              run(p, usel(bsel(Z.is_fixed(fields), U32.is_eq(len, fp), U32.is_ge(len, fp)), 8, 6),
                schema, FChain{fields, a, a, b, T.End{}, 0, 0, fr}, a, b, c, (buf, 0))
            case T.Chain{+h, +t}:
              (buf, v) = pair
              +fp = Z.fixed_part(schema)
              +len = (b - a : U32)
              run(p, usel(bsel(Z.is_fixed(schema), U32.is_eq(len, fp), U32.is_ge(len, fp)), 8, 6),
                schema, FChain{schema, a, a, b, T.End{}, 0, 0, fr}, a, b, c, (buf, 0))
            case T.End{}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), 0), 5, 6), schema, fr, a, b, c, (buf, 0))
            case T.Null{}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), 0), 5, 6), schema, fr, a, b, c, (buf, 0))
            case T.Named{name, +inner}:
              (buf, v) = pair
              run(p, 0, inner, fr, a, b, c, (buf, 0))
            case T.Repeat{+e}:
              (buf, v) = pair
              (buf, False{})
            case T.Union{+options}:
              (buf, v) = pair
              (buf, False{})
            case T.CompatibleUnion{selectors, +options}:
              (buf, v) = pair
              (buf, False{})
            case T.ProgressiveList{+e}:
              (buf, v) = pair
              (buf, False{})
            case T.ProgressiveBits{}:
              (buf, v) = pair
              (buf, False{})
            case T.ProgressiveContainer{names, +fields, active}:
              (buf, v) = pair
              (buf, False{})
        # ---- 1: boolean byte -------------------------------------------
        case 1:
          (buf, +v) = pair
          run(p, usel(U32.is_le(v, 1), 5, 6), schema, fr, a, b, c, (buf, 0))
        # ---- 2: bit vector padding, c = bits used in the last byte ------
        case 2:
          (buf, +v) = pair
          run(p, usel(U32.is_eq(v, (v .&. low_mask(c) : U32)), 5, 6), schema, fr, a, b, c, (buf, 0))
        # ---- 3: bit list terminator, window [a, b) ----------------------
        case 3:
          match schema:
            case T.BitList{+limit}:
              (buf, +v) = pair
              +bits = (((b - a : U32) - 1 : U32) * 8 + high_bit(v) : U32)
              run(p, usel(bsel(U32.is_eq(v, 0), False{}, nat_le(bits, limit)), 5, 6),
                schema, fr, a, b, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})
        # ---- 4: first offset of a variable-element sequence -------------
        case 4:
          match schema:
            case T.Vector{+e, +n}:
              (buf, +v) = pair
              +count = U32.from_nat(n)
              run(p, usel(U32.is_eq(v, (4 * count : U32)), 5, 6), schema,
                FVarList{e, 0, count, a, b, fr}, a, b, c, (buf, 0))
            case T.ListOf{+e, +limit}:
              (buf, +v) = pair
              +count = U32.shrn(v, 2n)
              +aligned = U32.is_eq((v .&. 3 : U32), 0)
              +within = bsel(nat_le(count, limit), U32.is_le(v, (b - a : U32)), False{})
              run(p, usel(bsel(aligned, within, False{}), 5, 6), schema,
                FVarList{e, 0, count, a, b, fr}, a, b, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})
        # ---- 5: the current item is done --------------------------------
        case 5:
          match fr:
            case FDone{}:
              (buf, v) = pair
              (buf, True{})
            case FChain{+rest, +hp, +base, +endp, +pend, +start, +has, +up}:
              (buf, v) = pair
              run(p, 8, schema, FChain{rest, hp, base, endp, pend, start, has, up}, a, b, c, (buf, 0))
            case FRep{+elem, +left, +stride, +off, +up}:
              (buf, v) = pair
              +done = U32.is_eq(left, 0)
              run(p, usel(done, 5, 0), elem,
                fsel(done, up, FRep{elem, (left - 1 : U32), stride, (off + stride : U32), up}),
                off, (off + stride : U32), c, (buf, 0))
            case FVarList{+elem, +i, +n, +base, +endp, +up}:
              (buf, v) = pair
              +done = U32.is_eq(i, n)
              run(p, usel(done, 5, 11), elem,
                fsel(done, up, FVarList{elem, i, n, base, endp, up}),
                a, b, c, B.read32(buf, (base + 4 * i : U32)))
        # ---- 8: advance the field-chain walk in the frame ----------------
        case 8:
          match fr:
            case FChain{+rest, +hp, +base, +endp, +pend, +start, +has, +up}:
              match rest:
                case T.End{}:
                  (buf, v) = pair
                  +pending = U32.is_eq(has, 1)
                  run(p, usel(pending, 0, 5), pend, up, start, endp, c, (buf, 0))
                case T.Chain{+h, +t}:
                  (buf, v) = pair
                  +s = Z.header_size(h)
                  +fixed = Z.is_fixed(h)
                  run(p, usel(fixed, 0, 9), ssel(fixed, h, rest),
                    FChain{ssel(fixed, t, rest), usel(fixed, (hp + s : U32), hp), base, endp, pend, start, has, up},
                    hp, (hp + s : U32), c, B.read32(buf, hp))
                case _:
                  (buf, v) = pair
                  (buf, False{})
            case _:
              (buf, v) = pair
              (buf, False{})
        # ---- 9: v is the offset of the current variable field ------------
        case 9:
          match fr:
            case FChain{+rest, +hp, +base, +endp, +pend, +start, +has, +up}:
              match rest:
                case T.Chain{+h, +t}:
                  (buf, +v) = pair
                  +child = (base + v : U32)
                  +first_ok = U32.is_eq(v, ((hp + 4 : U32) + Z.fixed_part(t) - base : U32))
                  +grow_ok = bsel(U32.is_ge(child, start), U32.is_le(child, endp), False{})
                  +pending = U32.is_eq(has, 1)
                  run(p, usel(pending, usel(grow_ok, 0, 6), usel(first_ok, 8, 6)), pend,
                    FChain{t, (hp + 4 : U32), base, endp, h, child, 1, up},
                    start, child, c, (buf, 0))
                case _:
                  (buf, v) = pair
                  (buf, False{})
            case _:
              (buf, v) = pair
              (buf, False{})
        # ---- 11: v is the offset of variable element i -------------------
        case 11:
          match fr:
            case FVarList{+elem, +i, +n, +base, +endp, +up}:
              (buf, +v) = pair
              +child = (base + v : U32)
              +last = U32.is_eq((i + 1 : U32), n)
              +ok = bsel(U32.is_le(child, endp), U32.is_ge(child, base), False{})
              run(p, usel(ok, usel(last, 0, 12), 6), elem,
                fsel(last, FVarList{elem, (i + 1 : U32), n, base, endp, up},
                     FVarList{elem, i, n, base, endp, up}),
                child, endp, c, B.read32(buf, (base + 4 * (i + 1 : U32) : U32)))
            case _:
              (buf, v) = pair
              (buf, False{})
        # ---- 12: v is the offset that ends element i; it starts at a -----
        case _:
          match fr:
            case FVarList{+elem, +i, +n, +base, +endp, +up}:
              (buf, +v) = pair
              +child_end = (base + v : U32)
              +ok = bsel(U32.is_ge(child_end, a), U32.is_le(child_end, endp), False{})
              run(p, usel(ok, 0, 6), elem,
                FVarList{elem, (i + 1 : U32), n, base, endp, up},
                a, child_end, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})

# Entry point: is the whole buffer a legal encoding of `schema`?
def valid_at(schema: T.Schema, +size: U32, buf: B.Buf) -> B.Buf & Bool:
  run(Nat.add(64n, U32.to_nat((4 * size : U32))), 0, schema, FDone{}, 0, size, 0, (buf, 0))

def valid_of(schema: T.Schema, pair: B.Buf & U32) -> B.Buf & Bool:
  (buf, +n) = pair
  valid_at(schema, n, buf)

def valid(schema: T.Schema, buf: B.Buf) -> B.Buf & Bool:
  valid_of(schema, B.size(buf))
