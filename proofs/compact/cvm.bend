import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ./found.bend as F
import ./reads.bend as Rd

# The scanner's machine-level specification.
#
# CVm(h, cs, a, b) is exactly what src/cscan.bend decides for the window
# [a, b), written as a direct recursive definition: the same arithmetic on
# byte positions (Nat), the same reads (b8 / r32: what B.byte_at / B.read32
# return at any position), the same loop tests. The continuation-passing
# machine (frames, tags, fuel) is proved to accept exactly when CVm holds. The
# level h bounds the nesting depth and every loop's length, as the machine's
# own fuel does; `Empty` where it runs out.

def If(c: Bool, A: Type, B: Type) -> Type:
  match c:
    case True{}: A
    case False{}: B

def Is(b: Bool) -> Type: {b == True{} : Bool}

# The byte and the little-endian word the machine reads at position k.
def b8(+t: F.array__Tree<U32>, +d: Nat, +k: Nat) -> U32: Rd.b8(t, d, U32.from_nat(k))

def r32(+t: F.array__Tree<U32>, +d: Nat, +k: Nat) -> U32: Rd.r32(t, d, U32.from_nat(k))

# The outcome of a length-only check (S.shallow): 0 = walk into the schema
# (validate it in full), 1 = valid, anything else = invalid.
def Shallow(+r: U32, A: Type) -> Type:
  If(U32.is_eq(r, 0), A, If(U32.is_eq(r, 1), Unit, Empty))

# A bit vector's padding (tag 2) and a bit list's delimiter and limit (tag 3).
def pad_ok(+bits: U32, +v: U32) -> Bool:
  Bool.or(U32.is_eq((bits .&. 7 : U32), 0), U32.is_eq(v, (v .&. C.low_mask((bits .&. 7 : U32)) : U32)))

def tail_ok(+a: Nat, +b: Nat, +v: U32, +lim: U32, +big: Bool) -> Bool:
  C.bsel(U32.is_eq(v, 0), False{},
    S.within(Nat.add(Nat.mul(8n, Nat.sub(Nat.sub(b, a), 1n)), U32.to_nat(C.high_bit(v))), lim, big))

# The first offset of a non-empty variable-element list (tag 4).
def list_head_ok(+a: Nat, +b: Nat, +v: U32, +lim: U32, +big: Bool) -> Bool:
  C.bsel(Nat.is_eq(U32.to_nat(v), Nat.mul(4n, Nat.div(U32.to_nat(v), 4n))),
    C.bsel(C.bsel(Nat.is_le(4n, U32.to_nat(v)), Nat.is_le(U32.to_nat(v), Nat.sub(b, a)), False{}),
      S.within(Nat.div(U32.to_nat(v), 4n), lim, big), False{}),
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
  Node{cs: S.CS, a: Nat, b: Nat}
  Rep{elem: S.CS, left: Nat, off: Nat, stride: Nat}
  VEl{elem: S.CS, i: Nat, n: Nat, base: Nat, endp: Nat}
  W8{fields: S.CS, i: U32, cnt: U32, base: Nat, endp: Nat, fp: Nat, pend: S.CS, start: Nat, has: U32}
  W15{fields: S.CS, i: U32, cnt: U32, base: Nat, endp: Nat, fp: Nat, pend: S.CS, start: Nat, v: U32}
  W16{fields: S.CS, i: U32, cnt: U32, base: Nat, v: U32}

def VarStep(last: Bool, +child: Nat, +cend: Nat, +endp: Nat, A: Type, B: Type, R: Type) -> Type:
  match last:
    case True{}: A & R
    case False{}: Is(C.bsel(Nat.is_le(child, cend), Nat.is_le(cend, endp), False{})) & B & R

# The offset read for element i of a variable-size sequence at base, and
# where that element starts.
def el_at(+t: F.array__Tree<U32>, +d: Nat, +base: Nat, +i: Nat) -> Nat:
  Nat.add(base, U32.to_nat(r32(t, d, Nat.add(base, Nat.mul(4n, i)))))

def var_at(+t: F.array__Tree<U32>, +d: Nat, +base: Nat, +f: S.CS) -> Nat:
  Nat.add(base, U32.to_nat(r32(t, d, C.hpos(base, f))))

def M(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, job: Job) -> Type:
  match h:
    case 0n:
      match job:
        case Rep{elem, +left, off, stride}: If(Nat.is_eq(left, 0n), Unit, Empty)
        case VEl{elem, +i, +n, base, endp}: If(Nat.is_eq(i, n), Unit, Empty)
        case _: Empty
    case 1n+ +g:
      match job:
        case Node{cs, +a, +b}:
          match cs:
            case S.CBool{}:
              Is(Nat.is_eq(Nat.sub(b, a), 1n)) & Is(U32.is_le(b8(t, d, a), 1))
            case S.CUint{+size}:
              Is(Nat.is_eq(Nat.sub(b, a), U32.to_nat(size)))
            case S.CBytes{+len, depth}:
              Is(Nat.is_eq(Nat.sub(b, a), U32.to_nat(len)))
            case S.CByteList{+lim, +big, depth}:
              Is(S.within(Nat.sub(b, a), lim, big))
            case S.CBitVec{+bits, +bytes, depth}:
              Is(Nat.is_eq(Nat.sub(b, a), U32.to_nat(bytes))) & Is(pad_ok(bits, b8(t, d, Nat.sub(b, 1n))))
            case S.CBitList{+lim, +big, depth}:
              Is(Bool.not(Nat.is_eq(Nat.sub(b, a), 0n))) & Is(tail_ok(a, b, b8(t, d, Nat.sub(b, 1n)), lim, big))
            case S.CVec{+elem, +count, +stride, depth, basic, +plain}:
              Is(Nat.is_eq(Nat.sub(b, a), Nat.mul(U32.to_nat(count), U32.to_nat(stride)))) &
              If(Bool.or(U32.is_eq(count, 0), plain), Unit,
                M(t, d, g, Node{elem, a, Nat.add(a, U32.to_nat(stride))}) &
                M(t, d, g, Rep{elem, Nat.sub(U32.to_nat(count), 1n), Nat.add(a, U32.to_nat(stride)), U32.to_nat(stride)}))
            case S.CVecVar{+elem, +count, depth}:
              Is(Bool.not(Nat.is_lt(Nat.sub(b, a), Nat.mul(4n, U32.to_nat(count))))) &
              Is(Nat.is_eq(U32.to_nat(r32(t, d, a)), Nat.mul(4n, U32.to_nat(count)))) &
              M(t, d, g, VEl{elem, 0n, U32.to_nat(count), a, b})
            case S.CList{+elem, +lim, +big, +stride, depth, basic, +plain}:
              Is(Nat.is_eq(Nat.sub(b, a), Nat.mul(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), U32.to_nat(stride)))) &
              Is(S.within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big)) &
              If(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), Unit,
                M(t, d, g, Node{elem, a, Nat.add(a, U32.to_nat(stride))}) &
                M(t, d, g, Rep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), Nat.add(a, U32.to_nat(stride)), U32.to_nat(stride)}))
            case S.CListVar{+elem, +lim, +big, depth}:
              If(Nat.is_eq(Nat.sub(b, a), 0n), Unit,
                Is(list_head_ok(a, b, r32(t, d, a), lim, big)) &
                M(t, d, g, VEl{elem, 0n, Nat.div(U32.to_nat(r32(t, d, a)), 4n), a, b}))
            case S.CCont{fields, cnt, +fp, size, +fixed, depth, +plain, +checks, +nchecks, +simple}:
              Is(C.bsel(fixed, Nat.is_eq(Nat.sub(b, a), U32.to_nat(fp)), Nat.is_le(U32.to_nat(fp), Nat.sub(b, a)))) &
              If(plain, Unit,
                If(simple,
                  If(fixed,
                    M(t, d, g, W16{checks, 0, nchecks, a, b8(t, d, C.check_byte(a, S.field(checks, 0)))}),
                    M(t, d, g, W15{checks, 0, nchecks, a, b, U32.to_nat(fp), S.CFNone{}, 0n, r32(t, d, C.hpos(a, S.field(checks, 0)))})),
                  M(t, d, g, W8{checks, 0, nchecks, a, b, U32.to_nat(fp), S.CFNone{}, 0n, 0})))
            case S.CPCont{fields, cnt, +fp, size, +fixed, +plain, +checks, +nchecks, slots, nslots, active}:
              Is(C.bsel(fixed, Nat.is_eq(Nat.sub(b, a), U32.to_nat(fp)), Nat.is_le(U32.to_nat(fp), Nat.sub(b, a)))) &
              If(plain, Unit, M(t, d, g, W8{checks, 0, nchecks, a, b, U32.to_nat(fp), S.CFNone{}, 0n, 0}))
            case S.CUnion{+options, +nsel}:
              Is(Nat.is_lt(a, b)) &
              Is(C.bsel(U32.is_lt(b8(t, d, a), nsel), C.is_leaf(S.field(options, b8(t, d, a))), False{})) &
              M(t, d, g, Node{C.f_schema(S.field(options, b8(t, d, a))), Nat.add(a, 1n), b})
            case S.CNull{}:
              Is(Nat.is_eq(Nat.sub(b, a), 0n))
            case _: Empty
        case Rep{+elem, +left, +off, +stride}:
          If(Nat.is_eq(left, 0n), Unit,
            M(t, d, g, Node{elem, off, Nat.add(off, stride)}) & M(t, d, g, Rep{elem, Nat.sub(left, 1n), Nat.add(off, stride), stride}))
        case VEl{+elem, +i, +n, +base, +endp}:
          If(Nat.is_eq(i, n), Unit,
            Is(C.bsel(Nat.is_le(el_at(t, d, base, i), endp), Nat.is_le(base, el_at(t, d, base, i)), False{})) &
            VarStep(Nat.is_eq(Nat.add(i, 1n), n), el_at(t, d, base, i), el_at(t, d, base, Nat.add(i, 1n)), endp,
              M(t, d, g, Node{elem, el_at(t, d, base, i), endp}),
              M(t, d, g, Node{elem, el_at(t, d, base, i), el_at(t, d, base, Nat.add(i, 1n))}),
              M(t, d, g, VEl{elem, Nat.add(i, 1n), n, base, endp})))
        case W8{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has}:
          If(U32.is_eq(i, cnt),
            If(U32.is_eq(has, 1), Shallow(S.shallow(pend, Nat.sub(endp, start)), M(t, d, g, Node{pend, start, endp})), Unit),
            If(C.f_fixed(S.field(fields, i)),
              If(S.is_plain(C.f_schema(S.field(fields, i))),
                M(t, d, g, W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has}),
                M(t, d, g, Node{C.f_schema(S.field(fields, i)), C.hpos(base, S.field(fields, i)),
                  Nat.add(C.hpos(base, S.field(fields, i)), U32.to_nat(C.f_hsize(S.field(fields, i))))}) &
                M(t, d, g, W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has})),
              If(U32.is_eq(has, 1),
                Is(C.bsel(Nat.is_le(start, var_at(t, d, base, S.field(fields, i))), Nat.is_le(var_at(t, d, base, S.field(fields, i)), endp), False{})) &
                Shallow(S.shallow(pend, Nat.sub(var_at(t, d, base, S.field(fields, i)), start)), M(t, d, g, Node{pend, start, var_at(t, d, base, S.field(fields, i))})),
                Is(Nat.is_eq(U32.to_nat(r32(t, d, C.hpos(base, S.field(fields, i)))), fp))) &
              M(t, d, g, W8{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), var_at(t, d, base, S.field(fields, i)), 1})))
        case W15{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +v}:
          Is(C.bsel(U32.is_eq(i, 0), Nat.is_eq(U32.to_nat(v), fp),
            C.bsel(Nat.is_le(start, Nat.add(base, U32.to_nat(v))), Nat.is_le(Nat.add(base, U32.to_nat(v)), endp), False{}))) &
          Is(C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, Nat.sub(Nat.add(base, U32.to_nat(v)), start)), 1))) &
          If(U32.is_eq((i + 1 : U32), cnt),
            Is(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), Nat.sub(endp, Nat.add(base, U32.to_nat(v)))), 1)),
            M(t, d, g, W15{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), Nat.add(base, U32.to_nat(v)),
              r32(t, d, C.hpos(base, S.field(fields, (i + 1 : U32))))}))
        case W16{+fields, +i, +cnt, +base, +v}:
          Is(C.byte_ok(C.f_schema(S.field(fields, i)), v)) &
          If(U32.is_eq((i + 1 : U32), cnt), Unit,
            M(t, d, g, W16{fields, (i + 1 : U32), cnt, base, b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))}))

# The machine-level specification of a window.
def CVm(+t: F.array__Tree<U32>, +d: Nat, h: Nat, +cs: S.CS, +a: Nat, +b: Nat) -> Type:
  M(t, d, h, Node{cs, a, b})
