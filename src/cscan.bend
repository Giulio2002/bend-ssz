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
# Byte positions and lengths are `Nat`s (machine words in the native backend):
# no position arithmetic can wrap, so a window is exactly the bytes between
# its two ends. Values read from the buffer, and the schema's sizes, limits and
# field indices, stay `U32`.
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
  FCont{fields: S.CS, i: U32, cnt: U32, base: Nat, endp: Nat, fp: Nat,
        pend: S.CS, start: Nat, has: U32, up: Frame}
  FRep{elem: S.CS, left: Nat, stride: Nat, off: Nat, up: Frame}
  FVarList{elem: S.CS, i: Nat, n: Nat, base: Nat, endp: Nat, up: Frame}

def usel(c: Bool, +x: U32, +y: U32) -> U32:
  match c:
    case True{}: x
    case False{}: y

def natsel(c: Bool, +x: Nat, +y: Nat) -> Nat:
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

# Reads at a byte position.
def rd8(buf: B.Buf, +k: Nat) -> B.Buf & U32: B.byte_at(buf, U32.from_nat(k))

def rd32(buf: B.Buf, +k: Nat) -> B.Buf & U32: B.read32(buf, U32.from_nat(k))

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

# Where a field's header starts in a container at base.
def hpos(+base: Nat, +f: S.CS) -> Nat: Nat.add(base, U32.to_nat(f_hoff(f)))

# Next tag after a shallow check (S.shallow): 0 = not shallow, walk into it
# (`deep`); 1 = valid, go on (`next`); otherwise reject.
def shallow_tag(+sh: U32, +deep: U32, +next: U32) -> U32:
  match sh:
    case 0: deep
    case 1: next
    case _: 6

# The byte a fixed byte check reads: the last byte of the field.
def check_byte(+base: Nat, +f: S.CS) -> Nat: Nat.sub(Nat.add(hpos(base, f), U32.to_nat(f_hsize(f))), 1n)

# Is `v` a valid last byte for this check: a boolean byte, or a bit vector's
# last byte with its padding bits zero?
def byte_ok(s: S.CS, +v: U32) -> Bool:
  match s:
    case S.CBool{}: U32.is_le(v, 1)
    case S.CBitVec{+bits, bytes, depth}: U32.is_eq(v, (v .&. low_mask((bits .&. 7 : U32)) : U32))
    case _: False{}

# The first value a simple container's walk needs.
def first_read(fixed: Bool, +f: S.CS, +a: Nat, buf: B.Buf) -> B.Buf & U32:
  match fixed:
    case True{}: rd8(buf, check_byte(a, f))
    case False{}: rd32(buf, hpos(a, f))

def is_leaf(f: S.CS) -> Bool:
  match f:
    case S.CFLeaf{s, hoff, hsize, fixed}: True{}
    case _: False{}

def f_fixed(f: S.CS) -> Bool:
  match f:
    case S.CFLeaf{s, hoff, hsize, +fixed}: fixed
    case _: False{}

def run(+fuel: Nat, +tag: U32, +schema: S.CS, +fr: Frame, +a: Nat, +b: Nat, +c: U32,
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
              run(p, usel(Nat.is_eq(Nat.sub(b, a), 1n), 1, 6), schema, fr, a, b, c, rd8(buf, a))
            case S.CUint{+size}:
              (buf, v) = pair
              run(p, usel(Nat.is_eq(Nat.sub(b, a), U32.to_nat(size)), 5, 6), schema, fr, a, b, c, (buf, 0))
            case S.CBytes{+len, depth}:
              (buf, v) = pair
              run(p, usel(Nat.is_eq(Nat.sub(b, a), U32.to_nat(len)), 5, 6), schema, fr, a, b, c, (buf, 0))
            case S.CByteList{+lim, +big, depth}:
              (buf, v) = pair
              run(p, usel(S.within(Nat.sub(b, a), lim, big), 5, 6), schema, fr, a, b, c, (buf, 0))
            case S.CBitVec{+bits, +bytes, depth}:
              (buf, v) = pair
              run(p, usel(Nat.is_eq(Nat.sub(b, a), U32.to_nat(bytes)),
                    usel(U32.is_eq((bits .&. 7 : U32), 0), 5, 2), 6),
                schema, fr, a, b, (bits .&. 7 : U32), rd8(buf, Nat.sub(b, 1n)))
            case S.CBitList{lim, big, depth}:
              (buf, v) = pair
              run(p, usel(Nat.is_eq(Nat.sub(b, a), 0n), 6, 3), schema, fr, a, b, c,
                rd8(buf, Nat.sub(b, 1n)))
            case S.CVec{+elem, +count, +stride, depth, basic, +plain}:
              (buf, v) = pair
              +st = U32.to_nat(stride)
              +ok = Nat.is_eq(Nat.sub(b, a), Nat.mul(U32.to_nat(count), st))
              +skip = Bool.or(U32.is_eq(count, 0), plain)
              run(p, usel(ok, usel(skip, 5, 0), 6), ssel(skip, schema, elem),
                fsel(skip, fr, FRep{elem, Nat.sub(U32.to_nat(count), 1n), st, Nat.add(a, st), fr}),
                a, Nat.add(a, st), c, (buf, 0))
            case S.CVecVar{+elem, +count, depth}:
              (buf, v) = pair
              run(p, usel(Nat.is_lt(Nat.sub(b, a), Nat.mul(4n, U32.to_nat(count))), 6, 4), schema, fr, a, b, count,
                rd32(buf, a))
            case S.CList{+elem, +lim, +big, +stride, depth, basic, +plain}:
              (buf, v) = pair
              +len = Nat.sub(b, a)
              +st = U32.to_nat(stride)
              +count = Nat.div(len, st)
              +exact = Nat.is_eq(len, Nat.mul(count, st))
              +skip = Bool.or(Nat.is_eq(len, 0n), plain)
              run(p, usel(bsel(exact, S.within(count, lim, big), False{}), usel(skip, 5, 0), 6),
                ssel(skip, schema, elem),
                fsel(skip, fr, FRep{elem, Nat.sub(count, 1n), st, Nat.add(a, st), fr}),
                a, Nat.add(a, st), c, (buf, 0))
            case S.CListVar{+elem, lim, big, depth}:
              (buf, v) = pair
              run(p, usel(Nat.is_eq(Nat.sub(b, a), 0n), 5, 4), schema, fr, a, b, c,
                rd32(buf, a))
            case S.CCont{fields, cnt, +fp, size, fixed, depth, +plain, +checks, +nchecks, +simple}:
              (buf, v) = pair
              +len = Nat.sub(b, a)
              +fpn = U32.to_nat(fp)
              # A simple container goes straight to its fast walk with the first
              # value read: tag 15 (variable: first offset), tag 16 (fixed: the
              # byte of its first byte check).
              run(p, usel(bsel(S.is_fixed(schema), Nat.is_eq(len, fpn), Nat.is_le(fpn, len)),
                    usel(plain, 5, usel(simple, usel(S.is_fixed(schema), 16, 15), 8)), 6),
                schema, fsel(plain, fr, FCont{checks, 0, nchecks, a, b, fpn, S.CFNone{}, 0n, 0, fr}), a, b, c,
                first_read(S.is_fixed(schema), S.field(checks, 0), a, buf))
            case S.CPCont{fields, cnt, +fp, size, fixed, +plain, +checks, +nchecks, slots, nslots, active}:
              (buf, v) = pair
              +len = Nat.sub(b, a)
              +fpn = U32.to_nat(fp)
              run(p, usel(bsel(S.is_fixed(schema), Nat.is_eq(len, fpn), Nat.is_le(fpn, len)), usel(plain, 5, 8), 6),
                schema, fsel(plain, fr, FCont{checks, 0, nchecks, a, b, fpn, S.CFNone{}, 0n, 0, fr}), a, b, c, (buf, 0))
            case S.CUnion{options, nsel}:
              (buf, v) = pair
              run(p, usel(Nat.is_lt(a, b), 13, 6), schema, fr, a, b, c, rd8(buf, a))
            case S.CNull{}:
              (buf, v) = pair
              run(p, usel(Nat.is_eq(Nat.sub(b, a), 0n), 5, 6), schema, fr, a, b, c, (buf, 0))
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
              # The bit count 8 (len - 1) + high_bit(v) must be within the limit.
              +bits = Nat.add(Nat.mul(8n, Nat.sub(Nat.sub(b, a), 1n)), U32.to_nat(high_bit(v)))
              run(p, usel(bsel(U32.is_eq(v, 0), False{}, S.within(bits, lim, big)), 5, 6),
                schema, fr, a, b, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})
        case 4:
          match schema:
            case S.CVecVar{+elem, +count, depth}:
              (buf, +v) = pair
              run(p, usel(Nat.is_eq(U32.to_nat(v), Nat.mul(4n, U32.to_nat(count))), 5, 6), schema,
                FVarList{elem, 0n, U32.to_nat(count), a, b, fr}, a, b, c, (buf, 0))
            case S.CListVar{+elem, +lim, +big, depth}:
              (buf, +v) = pair
              +first = U32.to_nat(v)
              +count = Nat.div(first, 4n)
              +aligned = Nat.is_eq(first, Nat.mul(4n, count))
              # A non-empty list has at least one element, so its first
              # offset is at least 4; an empty list is the empty window,
              # handled at tag 0.
              +within_len = bsel(Nat.is_le(4n, first), Nat.is_le(first, Nat.sub(b, a)), False{})
              run(p, usel(bsel(aligned, bsel(within_len, S.within(count, lim, big), False{}), False{}), 5, 6),
                schema, FVarList{elem, 0n, count, a, b, fr}, a, b, c, (buf, 0))
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
              +done = Nat.is_eq(left, 0n)
              run(p, usel(done, 5, 0), elem,
                fsel(done, up, FRep{elem, Nat.sub(left, 1n), stride, Nat.add(off, stride), up}),
                off, Nat.add(off, stride), c, (buf, 0))
            case FVarList{+elem, +i, +n, +base, +endp, +up}:
              (buf, v) = pair
              +done = Nat.is_eq(i, n)
              run(p, usel(done, 5, 11), elem,
                fsel(done, up, FVarList{elem, i, n, base, endp, up}),
                a, b, c, rd32(buf, Nat.add(base, Nat.mul(4n, i))))
        case 8:
          match fr:
            case FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
              (buf, v) = pair
              +last = U32.is_eq(i, cnt)
              +pending = U32.is_eq(has, 1)
              +f = S.field(fields, i)
              +fixed = f_fixed(f)
              +hp = hpos(base, f)
              # A fixed field of a plain type needs no check - its size is fixed
              # by the layout - so the walk moves straight to the next field.
              # The pending variable field's end is now known (the container's
              # end). If its validity depends on its length alone, decide it here.
              # A variable field's schema travels to tag 9 as the schema.
              run(p, usel(last, usel(pending, shallow_tag(S.shallow(pend, Nat.sub(endp, start)), 0, 5), 5),
                    usel(fixed, usel(S.is_plain(f_schema(f)), 8, 0), 9)),
                ssel(last, pend, f_schema(f)),
                fsel(last, up,
                  FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}),
                natsel(last, start, hp), natsel(last, endp, Nat.add(hp, U32.to_nat(f_hsize(f)))), c,
                rd32(buf, hp))
            case _:
              (buf, v) = pair
              (buf, False{})
        case 9:
          match fr:
            case FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
              (buf, +v) = pair
              +child = Nat.add(base, U32.to_nat(v))
              +first_ok = Nat.is_eq(U32.to_nat(v), fp)
              +grow_ok = bsel(Nat.is_le(start, child), Nat.is_le(child, endp), False{})
              +pending = U32.is_eq(has, 1)
              # The previous variable field ends where this one (whose schema
              # is `schema`) starts; if its validity depends on its length
              # alone, decide it and walk on.
              run(p, usel(pending, usel(grow_ok, shallow_tag(S.shallow(pend, Nat.sub(child, start)), 0, 8), 6),
                    usel(first_ok, 8, 6)), pend,
                FCont{fields, i, cnt, base, endp, fp, schema, child, 1, up},
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
              +child = Nat.add(base, U32.to_nat(v))
              +first = U32.is_eq(i, 0)
              +off_ok = bsel(first, Nat.is_eq(U32.to_nat(v), fp),
                bsel(Nat.is_le(start, child), Nat.is_le(child, endp), False{}))
              +prev_ok = bsel(first, True{}, U32.is_eq(S.shallow(pend, Nat.sub(child, start)), 1))
              +last = U32.is_eq((i + 1 : U32), cnt)
              +f = S.field(fields, i)
              run(p, usel(bsel(off_ok, prev_ok, False{}),
                    usel(last, usel(U32.is_eq(S.shallow(f_schema(f), Nat.sub(endp, child)), 1), 5, 6), 15), 6),
                schema,
                fsel(last, up, FCont{fields, (i + 1 : U32), cnt, base, endp, fp, f_schema(f), child, 1, up}),
                a, b, c, rd32(buf, hpos(base, S.field(fields, (i + 1 : U32)))))
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
                a, b, c, rd8(buf, check_byte(base, S.field(fields, (i + 1 : U32)))))
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
                fr, Nat.add(a, 1n), b, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})
        case 11:
          match fr:
            case FVarList{+elem, +i, +n, +base, +endp, +up}:
              (buf, +v) = pair
              +child = Nat.add(base, U32.to_nat(v))
              +last = Nat.is_eq(Nat.add(i, 1n), n)
              +ok = bsel(Nat.is_le(child, endp), Nat.is_le(base, child), False{})
              run(p, usel(ok, usel(last, 0, 12), 6), elem,
                fsel(last, FVarList{elem, Nat.add(i, 1n), n, base, endp, up},
                     FVarList{elem, i, n, base, endp, up}),
                child, endp, c, rd32(buf, Nat.add(base, Nat.mul(4n, Nat.add(i, 1n)))))
            case _:
              (buf, v) = pair
              (buf, False{})
        case _:
          match fr:
            case FVarList{+elem, +i, +n, +base, +endp, +up}:
              (buf, +v) = pair
              +child_end = Nat.add(base, U32.to_nat(v))
              +ok = bsel(Nat.is_le(a, child_end), Nat.is_le(child_end, endp), False{})
              run(p, usel(ok, 0, 6), elem,
                FVarList{elem, Nat.add(i, 1n), n, base, endp, up}, a, child_end, c, (buf, 0))
            case _:
              (buf, v) = pair
              (buf, False{})

# Entry point: is the window [0, size) a legal encoding of `schema`?
def valid_pick(plain: Bool, +schema: S.CS, +off: U32, +len: U32, buf: B.Buf) -> B.Buf & Bool:
  match plain:
    case True{}: (buf, U32.is_eq(len, S.fixed_or_zero(schema)))
    case False{}:
      run(Nat.add(64n, Nat.mul(4n, U32.to_nat(len))), 0, schema, FDone{},
        U32.to_nat(off), Nat.add(U32.to_nat(off), U32.to_nat(len)), 0, (buf, 0))

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
