import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ./found.bend as F
import ./reads.bend as Rd
import ./cvm.bend as V
import ../../src/buffer.bend as B

# What a successful run of the scanner from a given state establishes.
#
# FD(h, fr): the obligations the frame stack `fr` still has to discharge.
# Den(h, tag, ...): those of a machine state. Both are stated with the jobs of
# cvm.bend, at level h (the machine's remaining fuel). The scanner's tags are
# U32 literals; the states are indexed here by the enumeration of the tags it
# uses, so that every state names a concrete literal (tag 12 is the machine's
# default branch).

type Tag is Data:
  T0{}
  T1{}
  T2{}
  T3{}
  T4{}
  T5{}
  T6{}
  T8{}
  T9{}
  T11{}
  T12{}
  T13{}
  T15{}
  T16{}

def lit(tg: Tag) -> U32:
  match tg:
    case T0{}: 0
    case T1{}: 1
    case T2{}: 2
    case T3{}: 3
    case T4{}: 4
    case T5{}: 5
    case T6{}: 6
    case T8{}: 8
    case T9{}: 9
    case T11{}: 11
    case T12{}: 12
    case T13{}: 13
    case T15{}: 15
    case T16{}: 16

def FD(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, fr: C.Frame) -> Type:
  match fr:
    case C.FDone{}: Unit
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, up}:
      V.M(t, d, h, V.W8{fields, i, cnt, base, endp, fp, pend, start, has}) & FD(t, d, h, up)
    case C.FRep{+elem, +left, +stride, +off, up}:
      V.M(t, d, h, V.Rep{elem, left, off, stride}) & FD(t, d, h, up)
    case C.FVarList{+elem, +i, +n, +base, +endp, up}:
      V.M(t, d, h, V.VEl{elem, i, n, base, endp}) & FD(t, d, h, up)

# Tag 9: the offset v of the variable field just passed (index i - 1) was read.
def Den9(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, fr: C.Frame, +v: U32) -> Type:
  match fr:
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, up}:
      V.If(U32.is_eq(has, 1),
        V.Is(C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})) &
        V.Shallow(S.shallow(pend, ((base + v : U32) - start : U32)), V.M(t, d, h, V.Node{pend, start, (base + v : U32)})),
        V.Is(U32.is_eq(v, fp))) &
      V.M(t, d, h, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) &
      FD(t, d, h, up)
    case _: Empty

# Tag 11: the offset v of element i was read (element i + 1's is read next).
def Den11(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, fr: C.Frame, +v: U32) -> Type:
  match fr:
    case C.FVarList{+elem, +i, +n, +base, +endp, up}:
      V.Is(C.bsel(U32.is_le((base + v : U32), endp), U32.is_ge((base + v : U32), base), False{})) &
      V.VarStep(U32.is_eq((i + 1 : U32), n), (base + v : U32), V.el_at(t, d, base, (i + 1 : U32)), endp,
        V.M(t, d, h, V.Node{elem, (base + v : U32), endp}),
        V.M(t, d, h, V.Node{elem, (base + v : U32), V.el_at(t, d, base, (i + 1 : U32))}),
        V.M(t, d, h, V.VEl{elem, (i + 1 : U32), n, base, endp})) &
      FD(t, d, h, up)
    case _: Empty

# Tag 12: element i starts at a; the offset v of its end was read.
def Den12(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, fr: C.Frame, +a: U32, +v: U32) -> Type:
  match fr:
    case C.FVarList{+elem, +i, +n, +base, +endp, up}:
      V.Is(C.bsel(U32.is_ge((base + v : U32), a), U32.is_le((base + v : U32), endp), False{})) &
      V.M(t, d, h, V.Node{elem, a, (base + v : U32)}) &
      V.M(t, d, h, V.VEl{elem, (i + 1 : U32), n, base, endp}) &
      FD(t, d, h, up)
    case _: Empty

def Den3(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, schema: S.CS, fr: C.Frame, +a: U32, +b: U32, +v: U32) -> Type:
  match schema:
    case S.CBitList{+lim, +big, depth}: V.Is(V.tail_ok(a, b, v, lim, big)) & FD(t, d, h, fr)
    case _: Empty

def Den4(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, schema: S.CS, fr: C.Frame, +a: U32, +b: U32, +v: U32) -> Type:
  match schema:
    case S.CVecVar{+elem, +count, depth}:
      V.Is(U32.is_eq(v, (4 * count : U32))) & V.M(t, d, h, V.VEl{elem, 0, count, a, b}) & FD(t, d, h, fr)
    case S.CListVar{+elem, +lim, +big, depth}:
      V.Is(V.list_head_ok(a, b, v, lim, big)) & V.M(t, d, h, V.VEl{elem, 0, U32.shrn(v, 2n), a, b}) & FD(t, d, h, fr)
    case _: Empty

def Den13(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, schema: S.CS, fr: C.Frame, +a: U32, +b: U32, +v: U32) -> Type:
  match schema:
    case S.CUnion{+options, +nsel}:
      V.Is(C.bsel(U32.is_lt(v, nsel), C.is_leaf(S.field(options, v)), False{})) &
      V.M(t, d, h, V.Node{C.f_schema(S.field(options, v)), (a + 1 : U32), b}) & FD(t, d, h, fr)
    case _: Empty

def Den15(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, fr: C.Frame, +v: U32) -> Type:
  match fr:
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, up}:
      V.M(t, d, h, V.W15{fields, i, cnt, base, endp, fp, pend, start, v}) & FD(t, d, h, up)
    case _: Empty

def Den16(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, fr: C.Frame, +v: U32) -> Type:
  match fr:
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, up}:
      V.M(t, d, h, V.W16{fields, i, cnt, base, v}) & FD(t, d, h, up)
    case _: Empty

def Den8(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, fr: C.Frame) -> Type:
  match fr:
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, up}: FD(t, d, h, C.FCont{fields, i, cnt, base, endp, fp, pend, start, has, up})
    case _: Empty

def Den(+t: F.array__Tree<U32>, +d: Nat, +h: Nat, tg: Tag, +schema: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32) -> Type:
  match tg:
    case T0{}: V.M(t, d, h, V.Node{schema, a, b}) & FD(t, d, h, fr)
    case T1{}: V.Is(U32.is_le(v, 1)) & FD(t, d, h, fr)
    case T2{}: V.Is(U32.is_eq(v, (v .&. C.low_mask(c) : U32))) & FD(t, d, h, fr)
    case T3{}: Den3(t, d, h, schema, fr, a, b, v)
    case T4{}: Den4(t, d, h, schema, fr, a, b, v)
    case T5{}: FD(t, d, h, fr)
    case T6{}: Empty
    case T8{}: Den8(t, d, h, fr)
    case T9{}: Den9(t, d, h, fr, v)
    case T11{}: Den11(t, d, h, fr, v)
    case T12{}: Den12(t, d, h, fr, a, v)
    case T13{}: Den13(t, d, h, schema, fr, a, b, v)
    case T15{}: Den15(t, d, h, fr, v)
    case T16{}: Den16(t, d, h, fr, v)

# The machine's buffer throughout a scan.
def bf(+t: F.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{F.array__thaw(U32, t), n}

# A successful run from a state.
def Ok(+t: F.array__Tree<U32>, +n: U32, +f: Nat, tg: Tag, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32) -> Type:
  {C.run(f, lit(tg), s, fr, a, b, c, (B.Buf{F.array__thaw(U32, t), n}, v)) == (B.Buf{F.array__thaw(U32, t), n}, True{}) : B.Buf & Bool}

# The induction hypothesis of the soundness proof at fuel p.
def IH(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat) -> Type:
  @tg: Tag -> @s: S.CS -> @fr: C.Frame -> @a: U32 -> @b: U32 -> @c: U32 -> @v: U32 ->
    Ok(t, n, p, tg, s, fr, a, b, c, v) -> Den(t, d, p, tg, s, fr, a, b, c, v)
