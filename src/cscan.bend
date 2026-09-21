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
            case S.CCont{+fields, +cnt, +fp, size, fixed, depth, +plain}:
              (buf, v) = pair
              +len = (b - a : U32)
              run(p, usel(bsel(S.is_fixed(schema), U32.is_eq(len, fp), U32.is_ge(len, fp)), usel(plain, 5, 8), 6),
                schema, fsel(plain, fr, FCont{fields, 0, cnt, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c, (buf, 0))
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
              run(p, usel(last, usel(pending, 0, 5), usel(fixed, 0, 9)),
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
              run(p, usel(pending, usel(grow_ok, 0, 6), usel(first_ok, 8, 6)), pend,
                FCont{fields, i, cnt, base, endp, fp, f_schema(f), child, 1, up},
                start, child, c, (buf, 0))
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
def valid_at(schema: S.CS, +size: U32, buf: B.Buf) -> B.Buf & Bool:
  run(Nat.add(64n, U32.to_nat((4 * size : U32))), 0, schema, FDone{}, 0, size, 0, (buf, 0))

def valid_of(schema: S.CS, pair: B.Buf & U32) -> B.Buf & Bool:
  (buf, +n) = pair
  valid_at(schema, n, buf)

def valid(schema: S.CS, buf: B.Buf) -> B.Buf & Bool:
  valid_of(schema, B.size(buf))
