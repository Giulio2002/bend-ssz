import Base
import ./buffer.bend as B
import ./cschema.bend as S

# Structural SSZ validation over indexed storage and the compact schema.
#
# This is the decoding pass of the primary runtime. It answers whether the
# bytes in a window are a legal SSZ encoding of a schema, checking exactly what
# the normative specification requires: exact fixed sizes, list limits, boolean
# bytes, bit-vector padding bits, bit-list terminators, and the offset
# discipline of variable-size containers and lists. It copies nothing.
#
# Everything it needs is precomputed in `src/cschema.bend`: strides, fixed
# sizes, field header offsets, machine-sized limits. No unary numeral is walked
# and no schema spine is traversed - container fields are addressed by index.
#
# Shape: one self-recursive definition, because Bend has no mutual recursion,
# cannot match a computed value, and requires a self-call to keep every
# argument unchanged until one shrinks. The first argument is a `Nat` fuel, the
# last is the buffer paired with the value read for this step, `tag` says what
# that value is, and `fr` is the continuation.
#
# Tags:
#   0  validate `schema` over the window [a, b)
#   1  the boolean byte is in v
#   2  the last byte of a bit vector is in v, c holds the bits used
#   3  the last byte of a bit list is in v
#   4  the first offset of a variable-element sequence is in v
#   5  pop: the current item is done
#   6  reject
#   8  advance the container walk held in the frame
#   9  the offset of the current variable field is in v
#  11  the offset of variable element i is in v
#  12  the offset that ends element i is in v; it starts at a
#  13  a union's selector byte is in v; the value follows it
#  15  a simple container's variable field i has its offset in v
#  16  a fixed simple container's byte check i has its byte in v
type Frame is Data:
  FDone{}
  FCont{fields: S.CS, i: U32, cnt: U32, base: U32, endp: U32, fp: U32,
        pend: S.CS, start: U32, has: U32, up: Frame}
  FRep{elem: S.CS, left: U32, stride: U32, off: U32, up: Frame}
  FVarList{elem: S.CS, i: U32, n: U32, base: U32, endp: U32, up: Frame}

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

def ssel(c: Bool, x: S.CS, y: S.CS) -> S.CS:
  match c:
    case True{}: x
    case False{}: y

# Highest set bit position of a non-zero byte, 0..7.
def high_bit(+v: U32) -> U32:
  usel(U32.is_ge(v, 128), 7,
    usel(U32.is_ge(v, 64), 6,
      usel(U32.is_ge(v, 32), 5,
        usel(U32.is_ge(v, 16), 4,
          usel(U32.is_ge(v, 8), 3,
            usel(U32.is_ge(v, 4), 2, usel(U32.is_ge(v, 2), 1, 0)))))))

# Keeps the r low bits of a byte, r = 0..7.
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

# Field accessors: a leaf carries the field schema, its header offset inside
# the fixed part, its header size and whether it is fixed size.
def f_schema(f: S.CS) -> S.CS:
  match f:
    case S.CFLeaf{+s, hoff, hsize, fixed}: s
    case _: S.CFNone{}

def f_hoff(f: S.CS) -> U32:
  match f:
    case S.CFLeaf{s, +hoff, hsize, fixed}: hoff
    case _: 0

def f_hsize(f: S.CS) -> U32:
  match f:
    case S.CFLeaf{s, hoff, +hsize, fixed}: hsize
    case _: 0

# Next tag after a shallow check (S.shallow): 0 = not shallow, walk into it
# (`deep`); 1 = valid, go on (`next`); otherwise reject.
def shallow_tag(+sh: U32, +deep: U32, +next: U32) -> U32:
  match sh:
    case 0: deep
    case 1: next
    case _: 6

# The byte a fixed byte check reads: the last byte of the field.
def check_byte(+base: U32, +f: S.CS) -> U32: ((base + f_hoff(f) : U32) + f_hsize(f) - 1 : U32)

# Is `v` a valid last byte for this check: a boolean byte, or a bit vector's
# last byte with its padding bits zero?
def byte_ok(s: S.CS, +v: U32) -> Bool:
  match s:
    case S.CBool{}: U32.is_le(v, 1)
    case S.CBitVec{+bits, bytes, depth}: U32.is_eq(v, (v .&. low_mask((bits .&. 7 : U32)) : U32))
    case _: False{}

# The first value a simple container's walk needs.
def first_read(fixed: Bool, +f: S.CS, +a: U32, buf: B.Buf) -> B.Buf & U32:
  match fixed:
    case True{}: B.byte_at(buf, check_byte(a, f))
    case False{}: B.read32(buf, (a + f_hoff(f) : U32))

def is_leaf(f: S.CS) -> Bool:
  match f:
    case S.CFLeaf{s, hoff, hsize, fixed}: True{}
    case _: False{}

def f_fixed(f: S.CS) -> Bool:
  match f:
    case S.CFLeaf{s, hoff, hsize, +fixed}: fixed
    case _: False{}

def run(+fuel: Nat, +tag: U32, +schema: S.CS, +fr: Frame, +a: U32, +b: U32, +c: U32,
        pair: B.Buf & U32) -> B.Buf & Bool:
  match fuel:
    case 0n:
      (buf, v) = pair
      (buf, False{})
    case 1n+p:
      match tag:
        case 6:
          (buf, v) = pair
          (buf, False{})
        case 0:
          match schema:
            case S.CBool{}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), 1), 1, 6), schema, fr, a, b, c, B.byte_at(buf, a))
            case S.CUint{+size}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), size), 5, 6), schema, fr, a, b, c, (buf, 0))
            case S.CBytes{+len, depth}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), len), 5, 6), schema, fr, a, b, c, (buf, 0))
            case S.CByteList{+lim, +big, depth}:
              (buf, v) = pair
              run(p, usel(S.within((b - a : U32), lim, big), 5, 6), schema, fr, a, b, c, (buf, 0))
            case S.CBitVec{+bits, +bytes, depth}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), bytes),
                    usel(U32.is_eq((bits .&. 7 : U32), 0), 5, 2), 6),
                schema, fr, a, b, (bits .&. 7 : U32), B.byte_at(buf, (a + bytes - 1 : U32)))
            case S.CBitList{lim, big, depth}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), 0), 6, 3), schema, fr, a, b, c,
                B.byte_at(buf, (b - 1 : U32)))
            case S.CVec{+elem, +count, +stride, depth, basic, +plain}:
              (buf, v) = pair
              +ok = U32.is_eq((b - a : U32), (count * stride : U32))
              +skip = Bool.or(U32.is_eq(count, 0), plain)
              run(p, usel(ok, usel(skip, 5, 0), 6), ssel(skip, schema, elem),
                fsel(skip, fr, FRep{elem, (count - 1 : U32), stride, (a + stride : U32), fr}),
                a, (a + stride : U32), c, (buf, 0))
            case S.CVecVar{+elem, +count, depth}:
              (buf, v) = pair
              run(p, usel(U32.is_lt((b - a : U32), (4 * count : U32)), 6, 4), schema, fr, a, b, count,
                B.read32(buf, a))
            case S.CList{+elem, +lim, +big, +stride, depth, basic, +plain}:
              (buf, v) = pair
              +len = (b - a : U32)
              +count = U32.div(len, stride)
              +exact = U32.is_eq(len, (count * stride : U32))
              +skip = Bool.or(U32.is_eq(len, 0), plain)
              run(p, usel(bsel(exact, S.within(count, lim, big), False{}), usel(skip, 5, 0), 6),
                ssel(skip, schema, elem),
                fsel(skip, fr, FRep{elem, (count - 1 : U32), stride, (a + stride : U32), fr}),
                a, (a + stride : U32), c, (buf, 0))
            case S.CListVar{+elem, lim, big, depth}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), 0), 5, 4), schema, fr, a, b, c,
                B.read32(buf, a))
            case S.CCont{fields, cnt, +fp, size, fixed, depth, +plain, +checks, +nchecks, +simple}:
              (buf, v) = pair
              +len = (b - a : U32)
              # A simple container goes straight to its fast walk with the first
              # value read: tag 15 (variable: first offset), tag 16 (fixed: the
              # byte of its first byte check).
              run(p, usel(bsel(S.is_fixed(schema), U32.is_eq(len, fp), U32.is_ge(len, fp)),
                    usel(plain, 5, usel(simple, usel(S.is_fixed(schema), 16, 15), 8)), 6),
                schema, fsel(plain, fr, FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c,
                first_read(S.is_fixed(schema), S.field(checks, 0), a, buf))
            case S.CPCont{fields, cnt, +fp, size, fixed, +plain, +checks, +nchecks, slots, nslots, active}:
              (buf, v) = pair
              +len = (b - a : U32)
              run(p, usel(bsel(S.is_fixed(schema), U32.is_eq(len, fp), U32.is_ge(len, fp)), usel(plain, 5, 8), 6),
                schema, fsel(plain, fr, FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c, (buf, 0))
            case S.CUnion{options, nsel}:
              (buf, v) = pair
              run(p, usel(U32.is_lt(a, b), 13, 6), schema, fr, a, b, c, B.byte_at(buf, a))
            case S.CNull{}:
              (buf, v) = pair
              run(p, usel(U32.is_eq((b - a : U32), 0), 5, 6), schema, fr, a, b, c, (buf, 0))
            case S.CFLeaf{s, hoff, hsize, fixed}:
              (buf, v) = pair
              (buf, False{})
            case S.CFNode{lo, hi, split}:
              (buf, v) = pair
              (buf, False{})
            case S.CFNone{}:
              (buf, v) = pair
              (buf, False{})
        case 1:
          (buf, +v) = pair
          run(p, usel(U32.is_le(v, 1), 5, 6), schema, fr, a, b, c, (buf, 0))
        case 2:
          (buf, +v) = pair
          run(p, usel(U32.is_eq(v, (v .&. low_mask(c) : U32)), 5, 6), schema, fr, a, b, c, (buf, 0))
        case 3:
          match schema:
            case S.CBitList{+lim, +big, depth}:
              (buf, +v) = pair
              +bits = (((b - a : U32) - 1 : U32) * 8 + high_bit(v) : U32)
              run(p, usel(bsel(U32.is_eq(v, 0), False{}, S.within(bits, lim, big)), 5, 6),
                schema, fr, a, b, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})
        case 4:
          match schema:
            case S.CVecVar{+elem, +count, depth}:
              (buf, +v) = pair
              run(p, usel(U32.is_eq(v, (4 * count : U32)), 5, 6), schema,
                FVarList{elem, 0, count, a, b, fr}, a, b, c, (buf, 0))
            case S.CListVar{+elem, +lim, +big, depth}:
              (buf, +v) = pair
              +count = U32.shrn(v, 2n)
              +aligned = U32.is_eq((v .&. 3 : U32), 0)
              +within_len = U32.is_le(v, (b - a : U32))
              run(p, usel(bsel(aligned, bsel(within_len, S.within(count, lim, big), False{}), False{}), 5, 6),
                schema, FVarList{elem, 0, count, a, b, fr}, a, b, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})
        case 5:
          match fr:
            case FDone{}:
              (buf, v) = pair
              (buf, True{})
            case FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
              (buf, v) = pair
              run(p, 8, schema, FCont{fields, i, cnt, base, endp, fp, pend, start, has, up},
                a, b, c, (buf, 0))
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
        case 8:
          match fr:
            case FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
              (buf, v) = pair
              +last = U32.is_eq(i, cnt)
              +pending = U32.is_eq(has, 1)
              +f = S.field(fields, i)
              +fixed = f_fixed(f)
              +hp = (base + f_hoff(f) : U32)
              # A fixed field of a plain type needs no check - its size is fixed
              # by the layout - so the walk moves straight to the next field.
              # The pending variable field's end is now known (the container's
              # end). If its validity depends on its length alone, decide it here.
              run(p, usel(last, usel(pending, shallow_tag(S.shallow(pend, (endp - start : U32)), 0, 5), 5),
                    usel(fixed, usel(S.is_plain(f_schema(f)), 8, 0), 9)),
                ssel(last, pend, ssel(fixed, f_schema(f), pend)),
                fsel(last, up,
                  FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}),
                usel(last, start, hp), usel(last, endp, (hp + f_hsize(f) : U32)), c,
                B.read32(buf, hp))
            case _:
              (buf, v) = pair
              (buf, False{})
        case 9:
          match fr:
            case FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
              (buf, +v) = pair
              +child = (base + v : U32)
              +f = S.field(fields, (i - 1 : U32))
              +first_ok = U32.is_eq(v, fp)
              +grow_ok = bsel(U32.is_ge(child, start), U32.is_le(child, endp), False{})
              +pending = U32.is_eq(has, 1)
              # The previous variable field ends where this one starts; if its
              # validity depends on its length alone, decide it and walk on.
              run(p, usel(pending, usel(grow_ok, shallow_tag(S.shallow(pend, (child - start : U32)), 0, 8), 6),
                    usel(first_ok, 8, 6)), pend,
                FCont{fields, i, cnt, base, endp, fp, f_schema(f), child, 1, up},
                start, child, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})
        # ---- 15: simple container: the offset of variable field i is in v ----
        # One step per variable field: check this offset (the first equals the
        # fixed part; each later one is at least the previous and at most the
        # end), check the previous field by its length alone, and read the next
        # offset - or, after the last field, check it against the end.
        case 15:
          match fr:
            case FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
              (buf, +v) = pair
              +child = (base + v : U32)
              +first = U32.is_eq(i, 0)
              +off_ok = bsel(first, U32.is_eq(v, fp),
                bsel(U32.is_ge(child, start), U32.is_le(child, endp), False{}))
              +prev_ok = bsel(first, True{}, U32.is_eq(S.shallow(pend, (child - start : U32)), 1))
              +last = U32.is_eq((i + 1 : U32), cnt)
              +f = S.field(fields, i)
              run(p, usel(bsel(off_ok, prev_ok, False{}),
                    usel(last, usel(U32.is_eq(S.shallow(f_schema(f), (endp - child : U32)), 1), 5, 6), 15), 6),
                schema,
                fsel(last, up, FCont{fields, (i + 1 : U32), cnt, base, endp, fp, f_schema(f), child, 1, up}),
                a, b, c, B.read32(buf, (base + f_hoff(S.field(fields, (i + 1 : U32))) : U32)))
            case _:
              (buf, v) = pair
              (buf, False{})
        # ---- 16: fixed simple container: the byte of check i is in v ---------
        # Its checks are single bytes at fixed offsets - a boolean (0 or 1), or
        # the last byte of a bit vector whose padding bits must be zero - so
        # each step checks one and reads the next.
        case 16:
          match fr:
            case FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
              (buf, +v) = pair
              +last = U32.is_eq((i + 1 : U32), cnt)
              run(p, usel(byte_ok(f_schema(S.field(fields, i)), v), usel(last, 5, 16), 6),
                schema,
                fsel(last, up, FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}),
                a, b, c, B.byte_at(buf, check_byte(base, S.field(fields, (i + 1 : U32)))))
            case _:
              (buf, v) = pair
              (buf, False{})
        # ---- 13: a union's selector byte is in v ---------------------------
        case 13:
          match schema:
            case S.CUnion{+options, +nsel}:
              (buf, +v) = pair
              +opt = S.field(options, v)
              run(p, usel(bsel(U32.is_lt(v, nsel), is_leaf(opt), False{}), 0, 6), f_schema(opt),
                fr, (a + 1 : U32), b, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})
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
        case _:
          match fr:
            case FVarList{+elem, +i, +n, +base, +endp, +up}:
              (buf, +v) = pair
              +child_end = (base + v : U32)
              +ok = bsel(U32.is_ge(child_end, a), U32.is_le(child_end, endp), False{})
              run(p, usel(ok, 0, 6), elem,
                FVarList{elem, (i + 1 : U32), n, base, endp, up}, a, child_end, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})

# Entry point: is the window [0, size) a legal encoding of `schema`?
def valid_pick(plain: Bool, +schema: S.CS, +off: U32, +len: U32, buf: B.Buf) -> B.Buf & Bool:
  match plain:
    case True{}: (buf, U32.is_eq(len, S.fixed_or_zero(schema)))
    case False{}:
      run(Nat.add(64n, U32.to_nat((4 * len : U32))), 0, schema, FDone{}, off, (off + len : U32), 0, (buf, 0))

# Is the window [off, off + len) a legal encoding of `schema`? For a plain
# schema - every byte string of its fixed size is valid - that is the length
# check alone, answered without starting the walk; this is the same test the
# walk's first step makes for a plain schema.
def valid_in(+schema: S.CS, +off: U32, +len: U32, buf: B.Buf) -> B.Buf & Bool:
  valid_pick(S.is_plain(schema), schema, off, len, buf)

def valid_at(schema: S.CS, +size: U32, buf: B.Buf) -> B.Buf & Bool: valid_in(schema, 0, size, buf)

def valid_of(schema: S.CS, pair: B.Buf & U32) -> B.Buf & Bool:
  (buf, +n) = pair
  valid_at(schema, n, buf)

def valid(schema: S.CS, buf: B.Buf) -> B.Buf & Bool:
  valid_of(schema, B.size(buf))
