import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ./found.bend as F
import ./reads.bend as Rd

# The scanner's machine-level specification.
#
# CVm(h, cs, a, b) is exactly what src/cscan.bend decides for the window
# [a, b), written as a direct recursive definition: the same U32 arithmetic,
# the same reads (Rd.b8 / Rd.r32 - what B.byte_at / B.read32 return at any
# index), the same loop tests. The continuation-passing machine (frames,
# tags, fuel) is proved to accept exactly when CVm holds; CVm is related to
# the byte-level specification (cv.bend) and so to the spec separately. The
# level h bounds the nesting depth and every loop's length, as the machine's
# own fuel does; `Empty` where it runs out.

def If(c: Bool, A: Type, B: Type) -> Type:
  match c:
    case True{}: A
    case False{}: B

def Is(b: Bool) -> Type: {b == True{} : Bool}

# The outcome of a length-only check (S.shallow): 0 = walk into the schema
# (validate it in full), 1 = valid, anything else = invalid.
def Shallow(+r: U32, A: Type) -> Type:
  If(U32.is_eq(r, 0), A, If(U32.is_eq(r, 1), Unit, Empty))

# A bit vector's padding (tag 2) and a bit list's delimiter and limit (tag 3).
def pad_ok(+bits: U32, +v: U32) -> Bool:
  Bool.or(U32.is_eq((bits .&. 7 : U32), 0), U32.is_eq(v, (v .&. C.low_mask((bits .&. 7 : U32)) : U32)))

def tail_ok(+a: U32, +b: U32, +v: U32, +lim: U32, +big: Bool) -> Bool:
  C.bsel(U32.is_eq(v, 0), False{},
    C.bsel(big, True{}, C.bsel(U32.is_lt(((b - a : U32) - 1 : U32), U32.shrn(lim, 3n)), True{},
      C.bsel(U32.is_eq(((b - a : U32) - 1 : U32), U32.shrn(lim, 3n)), U32.is_le(C.high_bit(v), (lim .&. 7 : U32)), False{}))))

# The first offset of a non-empty variable-element list (tag 4).
def list_head_ok(+a: U32, +b: U32, +v: U32, +lim: U32, +big: Bool) -> Bool:
  C.bsel(U32.is_eq((v .&. 3 : U32), 0),
    C.bsel(C.bsel(U32.is_le(4, v), U32.is_le(v, (b - a : U32)), False{}), S.within(U32.shrn(v, 2n), lim, big), False{}),
    False{})

# ---- the jobs of the specification ----------------------------------------------

# One job of the scanner, each mirroring a machine state family:
#   Node   validate `cs` over [a, b)              (tag 0 and the tags it leads to)
#   Rep    `left` more fixed-stride elements      (FRep pops)
#   VEl    elements i .. n - 1 by offsets          (FVarList pops, tags 11 / 12)
#   W8     the check-tree walk, pending field      (FCont pops, tags 8 / 9)
#   W15    a simple variable container's walk      (tag 15)
#   W16    a simple fixed container's walk         (tag 16)
type Job is Data:
  Node{cs: S.CS, a: U32, b: U32}
  Rep{elem: S.CS, left: U32, off: U32, stride: U32}
  VEl{elem: S.CS, i: U32, n: U32, base: U32, endp: U32}
  W8{fields: S.CS, i: U32, cnt: U32, base: U32, endp: U32, fp: U32, pend: S.CS, start: U32, has: U32}
  W15{fields: S.CS, i: U32, cnt: U32, base: U32, endp: U32, fp: U32, pend: S.CS, start: U32, v: U32}
  W16{fields: S.CS, i: U32, cnt: U32, base: U32, v: U32}

def VarStep(last: Bool, +child: U32, +cend: U32, +endp: U32, A: Type, B: Type, R: Type) -> Type:
  match last:
    case True{}: A & R
    case False{}: Is(C.bsel(U32.is_ge(cend, child), U32.is_le(cend, endp), False{})) & B & R

# The offset read for element i of a variable-size sequence at base, and
# where that element starts.
def el_at(+t: F.array__Tree<U32>, +d: Nat, +base: U32, +i: U32) -> U32:
  (base + Rd.r32(t, d, (base + 4 * i : U32)) : U32)

def var_at(+t: F.array__Tree<U32>, +d: Nat, +base: U32, +f: S.CS) -> U32:
  (base + Rd.r32(t, d, (base + C.f_hoff(f) : U32)) : U32)

def M(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, job: Job) -> Type:
  match h:
    case 0n:
      match job:
        case Rep{elem, +left, off, stride}: If(U32.is_eq(left, 0), Unit, Empty)
        case VEl{elem, +i, +n, base, endp}: If(U32.is_eq(i, n), Unit, Empty)
        case _: Empty
    case 1n+ +g:
      match job:
        case Node{cs, +a, +b}:
          match cs:
            case S.CBool{}:
              Is(U32.is_eq((b - a : U32), 1)) & Is(U32.is_le(Rd.b8(t, d, a), 1))
            case S.CUint{+size}:
              Is(U32.is_eq((b - a : U32), size))
            case S.CBytes{+len, depth}:
              Is(U32.is_eq((b - a : U32), len))
            case S.CByteList{+lim, +big, depth}:
              Is(S.within((b - a : U32), lim, big))
            case S.CBitVec{+bits, +bytes, depth}:
              Is(U32.is_eq((b - a : U32), bytes)) & Is(pad_ok(bits, Rd.b8(t, d, (a + bytes - 1 : U32))))
            case S.CBitList{+lim, +big, depth}:
              Is(Bool.not(U32.is_eq((b - a : U32), 0))) & Is(tail_ok(a, b, Rd.b8(t, d, (b - 1 : U32)), lim, big))
            case S.CVec{+elem, +count, +stride, depth, basic, +plain}:
              Is(U32.is_eq((b - a : U32), (count * stride : U32))) &
              If(Bool.or(U32.is_eq(count, 0), plain), Unit,
                M(t, d, g, Node{elem, a, (a + stride : U32)}) & M(t, d, g, Rep{elem, (count - 1 : U32), (a + stride : U32), stride}))
            case S.CVecVar{+elem, +count, depth}:
              Is(Bool.not(U32.is_lt((b - a : U32), (4 * count : U32)))) &
              Is(U32.is_eq(Rd.r32(t, d, a), (4 * count : U32))) &
              M(t, d, g, VEl{elem, 0, count, a, b})
            case S.CList{+elem, +lim, +big, +stride, depth, basic, +plain}:
              Is(U32.is_eq((b - a : U32), (U32.div((b - a : U32), stride) * stride : U32))) &
              Is(S.within(U32.div((b - a : U32), stride), lim, big)) &
              If(Bool.or(U32.is_eq((b - a : U32), 0), plain), Unit,
                M(t, d, g, Node{elem, a, (a + stride : U32)}) &
                M(t, d, g, Rep{elem, (U32.div((b - a : U32), stride) - 1 : U32), (a + stride : U32), stride}))
            case S.CListVar{+elem, +lim, +big, depth}:
              If(U32.is_eq((b - a : U32), 0), Unit,
                Is(list_head_ok(a, b, Rd.r32(t, d, a), lim, big)) &
                M(t, d, g, VEl{elem, 0, U32.shrn(Rd.r32(t, d, a), 2n), a, b}))
            case S.CCont{fields, cnt, +fp, size, +fixed, depth, +plain, +checks, +nchecks, +simple}:
              Is(C.bsel(fixed, U32.is_eq((b - a : U32), fp), U32.is_ge((b - a : U32), fp))) &
              If(plain, Unit,
                If(simple,
                  If(fixed,
                    M(t, d, g, W16{checks, 0, nchecks, a, Rd.b8(t, d, C.check_byte(a, S.field(checks, 0)))}),
                    M(t, d, g, W15{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32))})),
                  M(t, d, g, W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0})))
            case S.CPCont{fields, cnt, +fp, size, +fixed, +plain, +checks, +nchecks, slots, nslots, active}:
              Is(C.bsel(fixed, U32.is_eq((b - a : U32), fp), U32.is_ge((b - a : U32), fp))) &
              If(plain, Unit, M(t, d, g, W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0}))
            case S.CUnion{+options, +nsel}:
              Is(U32.is_lt(a, b)) &
              Is(C.bsel(U32.is_lt(Rd.b8(t, d, a), nsel), C.is_leaf(S.field(options, Rd.b8(t, d, a))), False{})) &
              M(t, d, g, Node{C.f_schema(S.field(options, Rd.b8(t, d, a))), (a + 1 : U32), b})
            case S.CNull{}:
              Is(U32.is_eq((b - a : U32), 0))
            case _: Empty
        case Rep{+elem, +left, +off, +stride}:
          If(U32.is_eq(left, 0), Unit,
            M(t, d, g, Node{elem, off, (off + stride : U32)}) & M(t, d, g, Rep{elem, (left - 1 : U32), (off + stride : U32), stride}))
        case VEl{+elem, +i, +n, +base, +endp}:
          If(U32.is_eq(i, n), Unit,
            Is(C.bsel(U32.is_le(el_at(t, d, base, i), endp), U32.is_ge(el_at(t, d, base, i), base), False{})) &
            VarStep(U32.is_eq((i + 1 : U32), n), el_at(t, d, base, i), el_at(t, d, base, (i + 1 : U32)), endp,
              M(t, d, g, Node{elem, el_at(t, d, base, i), endp}),
              M(t, d, g, Node{elem, el_at(t, d, base, i), el_at(t, d, base, (i + 1 : U32))}),
              M(t, d, g, VEl{elem, (i + 1 : U32), n, base, endp})))
        case W8{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has}:
          If(U32.is_eq(i, cnt),
            If(U32.is_eq(has, 1), Shallow(S.shallow(pend, (endp - start : U32)), M(t, d, g, Node{pend, start, endp})), Unit),
            If(C.f_fixed(S.field(fields, i)),
              If(S.is_plain(C.f_schema(S.field(fields, i))),
                M(t, d, g, W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has}),
                M(t, d, g, Node{C.f_schema(S.field(fields, i)), (base + C.f_hoff(S.field(fields, i)) : U32),
                  ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32)}) &
                M(t, d, g, W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has})),
              If(U32.is_eq(has, 1),
                Is(C.bsel(U32.is_ge(var_at(t, d, base, S.field(fields, i)), start), U32.is_le(var_at(t, d, base, S.field(fields, i)), endp), False{})) &
                Shallow(S.shallow(pend, (var_at(t, d, base, S.field(fields, i)) - start : U32)), M(t, d, g, Node{pend, start, var_at(t, d, base, S.field(fields, i))})),
                Is(U32.is_eq(Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), fp))) &
              M(t, d, g, W8{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), var_at(t, d, base, S.field(fields, i)), 1})))
        case W15{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +v}:
          Is(C.bsel(U32.is_eq(i, 0), U32.is_eq(v, fp), C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{}))) &
          Is(C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, ((base + v : U32) - start : U32)), 1))) &
          If(U32.is_eq((i + 1 : U32), cnt),
            Is(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1)),
            M(t, d, g, W15{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32),
              Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32))}))
        case W16{+fields, +i, +cnt, +base, +v}:
          Is(C.byte_ok(C.f_schema(S.field(fields, i)), v)) &
          If(U32.is_eq((i + 1 : U32), cnt), Unit,
            M(t, d, g, W16{fields, (i + 1 : U32), cnt, base, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))}))

# The machine-level specification of a window.
def CVm(+t: F.array__Tree<U32>, +d: Nat, h: Nat, +cs: S.CS, +a: U32, +b: U32) -> Type:
  M(t, d, h, Node{cs, a, b})
