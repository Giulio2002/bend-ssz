import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ../../src/buffer.bend as B
import ./found.bend as F
import ./reads.bend as Rd
import ./cvm.bend as V
import ./cvm_mono.bend as V2
import ./cvm_mono_gen.bend as G
import ./den.bend as D
import ./den_mono.bend as DM
import ./sound_leaf.bend as L
import ./sound_seq.bend as Q

# Soundness steps of the scanner for containers (tag 0 on containers, the
# walks of tags 8, 9, 15, 16) and unions (tag 0 on a union, tag 13).

# ---- the length-only check's outcome is one of three literals --------------------

type Sh is Data:
  Sh0{}
  Sh1{}
  Sh2{}

def sh_lit(k: Sh) -> U32:
  match k:
    case Sh0{}: 0
    case Sh1{}: 1
    case Sh2{}: 2

def pick_is(ok: Bool) -> &k: Sh -> {S.shallow_pick(ok) == sh_lit(k) : U32}:
  match ok:
    case True{}: (Sh1{}, {==})
    case False{}: (Sh2{}, {==})

def shallow_is(+s: S.CS, +len: U32) -> &k: Sh -> {S.shallow(s, len) == sh_lit(k) : U32}:
  match s:
    case S.CByteList{+lim, +big, depth}: pick_is(S.within(len, lim, big))
    case S.CList{elem, +lim, +big, +stride, depth, basic, +plain}:
      match plain:
        case True{}: pick_is(Bool.and(U32.is_eq(len, (U32.div(len, stride) * stride : U32)), S.within(U32.div(len, stride), lim, big)))
        case False{}: (Sh0{}, {==})
    case S.CBool{}: (Sh0{}, {==})
    case S.CUint{x0}: (Sh0{}, {==})
    case S.CBytes{x0, x1}: (Sh0{}, {==})
    case S.CBitVec{x0, x1, x2}: (Sh0{}, {==})
    case S.CBitList{x0, x1, x2}: (Sh0{}, {==})
    case S.CVec{x0, x1, x2, x3, x4, x5}: (Sh0{}, {==})
    case S.CVecVar{x0, x1, x2}: (Sh0{}, {==})
    case S.CListVar{x0, x1, x2, x3}: (Sh0{}, {==})
    case S.CCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}: (Sh0{}, {==})
    case S.CPCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10}: (Sh0{}, {==})
    case S.CUnion{x0, x1}: (Sh0{}, {==})
    case S.CNull{}: (Sh0{}, {==})
    case S.CFLeaf{x0, x1, x2, x3}: (Sh0{}, {==})
    case S.CFNode{x0, x1, x2}: (Sh0{}, {==})
    case S.CFNone{}: (Sh0{}, {==})

# ---- tag 13 and tag 0 on a union ---------------------------------------------------

def opt_lift(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +s: S.CS, +a: U32, +b: U32, +fr: C.Frame,
    pr: V.M(t, d, p, V.Node{s, a, b}) & D.FD(t, d, p, fr)) -> V.M(t, d, 1n+p, V.Node{s, a, b}) & D.FD(t, d, 1n+p, fr):
  (x, f) = pr
  (G.m_mono(t, d, p, V.Node{s, a, b}, x), DM.fd_mono(t, d, p, fr, f))

def union_parts(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +options: S.CS, +nsel: U32, +fr: C.Frame, +a: U32, +b: U32, +v: U32,
    e: {U32.is_lt(a, b) == True{} : Bool},
    pr: V.Is(C.bsel(U32.is_lt(v, nsel), C.is_leaf(S.field(options, v)), False{})) & V.M(t, d, p, V.Node{C.f_schema(S.field(options, v)), (a + 1 : U32), b}) & D.FD(t, d, p, fr))
    -> (V.Is(U32.is_lt(a, b)) & V.Is(C.bsel(U32.is_lt(v, nsel), C.is_leaf(S.field(options, v)), False{})) & V.M(t, d, p, V.Node{C.f_schema(S.field(options, v)), (a + 1 : U32), b})) & D.FD(t, d, 1n+p, fr):
  (x, r) = pr
  (m, f) = r
  ((e, (x, m)), DM.fd_mono(t, d, p, fr, f))

def opt_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +options: S.CS, +nsel: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), ok: Bool, e: {C.bsel(U32.is_lt(v, nsel), C.is_leaf(S.field(options, v)), False{}) == ok : Bool},
    h: {C.run(p, C.usel(ok, 0, 6), C.f_schema(S.field(options, v)), fr, (a + 1 : U32), b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T13{}, S.CUnion{options, nsel}, fr, a, b, c, v):
  match ok:
    case True{}: (e, opt_lift(t, d, p, C.f_schema(S.field(options, v)), (a + 1 : U32), b, fr, ih(D.T0{}, C.f_schema(S.field(options, v)), fr, (a + 1 : U32), b, c, 0, h)))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CUnion{options, nsel}, fr, a, b, c, v), ih(D.T6{}, C.f_schema(S.field(options, v)), fr, (a + 1 : U32), b, c, 0, h))

def union_lt(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +options: S.CS, +nsel: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32,
    ih: D.IH(t, d, n, p), ok: Bool, e: {U32.is_lt(a, b) == ok : Bool},
    h: {C.run(p, C.usel(ok, 13, 6), S.CUnion{options, nsel}, fr, a, b, c, (D.bf(t, n), Rd.b8(t, d, a))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CUnion{options, nsel}, fr, a, b, c, 0):
  match ok:
    case True{}: union_parts(t, d, p, options, nsel, fr, a, b, Rd.b8(t, d, a), e, ih(D.T13{}, S.CUnion{options, nsel}, fr, a, b, c, Rd.b8(t, d, a), h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CUnion{options, nsel}, fr, a, b, c, 0), ih(D.T6{}, S.CUnion{options, nsel}, fr, a, b, c, Rd.b8(t, d, a), h))

def t0_union(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +options: S.CS, +nsel: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CUnion{options, nsel}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CUnion{options, nsel}, fr, a, b, c, v):
  union_lt(t, d, n, p, options, nsel, fr, a, b, c, ih, U32.is_lt(a, b), {==},
    F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_lt(a, b), 13, 6), S.CUnion{options, nsel}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
      B.byte_at(D.bf(t, n), a), (D.bf(t, n), Rd.b8(t, d, a)), Rd.byte_any(d, t, n, a, hd, pf), h))

# ---- tag 0 on a container ------------------------------------------------------------

def cont_lift(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, -W: Type, pr: W & D.FD(t, d, p, fr)) -> W & D.FD(t, d, 1n+p, fr):
  (x, f) = pr
  (x, DM.fd_mono(t, d, p, fr, f))

def cont_flags(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, fixed: Bool, +depth: U32, plain: Bool, +checks: S.CS, +nchecks: U32, simple: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p),
    h: {C.run(p, C.usel(plain, 5, C.usel(simple, C.usel(fixed, 16, 15), 8)), S.CCont{fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple},
          C.fsel(plain, fr, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c, C.first_read(fixed, S.field(checks, 0), a, D.bf(t, n))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(plain, Unit, V.If(simple, V.If(fixed, V.M(t, d, p, V.W16{checks, 0, nchecks, a, Rd.b8(t, d, C.check_byte(a, S.field(checks, 0)))}), V.M(t, d, p, V.W15{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32))})), V.M(t, d, p, V.W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0}))) & D.FD(t, d, 1n+p, fr):
  match fixed plain simple:
    case True{} True{} True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CCont{fields, cnt, fp, size, True{}, depth, True{}, checks, nchecks, True{}}, fr, a, b, c, Rd.b8(t, d, C.check_byte(a, S.field(checks, 0))), F.logic__subst(B.Buf & U32, z => {C.run(p, 5, S.CCont{fields, cnt, fp, size, True{}, depth, True{}, checks, nchecks, True{}}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool}, B.byte_at(D.bf(t, n), C.check_byte(a, S.field(checks, 0))), (D.bf(t, n), Rd.b8(t, d, C.check_byte(a, S.field(checks, 0)))), Rd.byte_any(d, t, n, C.check_byte(a, S.field(checks, 0)), hd, pf), h))))
    case True{} True{} False{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CCont{fields, cnt, fp, size, True{}, depth, True{}, checks, nchecks, False{}}, fr, a, b, c, Rd.b8(t, d, C.check_byte(a, S.field(checks, 0))), F.logic__subst(B.Buf & U32, z => {C.run(p, 5, S.CCont{fields, cnt, fp, size, True{}, depth, True{}, checks, nchecks, False{}}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool}, B.byte_at(D.bf(t, n), C.check_byte(a, S.field(checks, 0))), (D.bf(t, n), Rd.b8(t, d, C.check_byte(a, S.field(checks, 0)))), Rd.byte_any(d, t, n, C.check_byte(a, S.field(checks, 0)), hd, pf), h))))
    case True{} False{} True{}: cont_lift(t, d, p, fr, V.M(t, d, p, V.W16{checks, 0, nchecks, a, Rd.b8(t, d, C.check_byte(a, S.field(checks, 0)))}), ih(D.T16{}, S.CCont{fields, cnt, fp, size, True{}, depth, False{}, checks, nchecks, True{}}, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, Rd.b8(t, d, C.check_byte(a, S.field(checks, 0))), F.logic__subst(B.Buf & U32, z => {C.run(p, 16, S.CCont{fields, cnt, fp, size, True{}, depth, False{}, checks, nchecks, True{}}, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool}, B.byte_at(D.bf(t, n), C.check_byte(a, S.field(checks, 0))), (D.bf(t, n), Rd.b8(t, d, C.check_byte(a, S.field(checks, 0)))), Rd.byte_any(d, t, n, C.check_byte(a, S.field(checks, 0)), hd, pf), h)))
    case True{} False{} False{}: cont_lift(t, d, p, fr, V.M(t, d, p, V.W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0}), ih(D.T8{}, S.CCont{fields, cnt, fp, size, True{}, depth, False{}, checks, nchecks, False{}}, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, Rd.b8(t, d, C.check_byte(a, S.field(checks, 0))), F.logic__subst(B.Buf & U32, z => {C.run(p, 8, S.CCont{fields, cnt, fp, size, True{}, depth, False{}, checks, nchecks, False{}}, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool}, B.byte_at(D.bf(t, n), C.check_byte(a, S.field(checks, 0))), (D.bf(t, n), Rd.b8(t, d, C.check_byte(a, S.field(checks, 0)))), Rd.byte_any(d, t, n, C.check_byte(a, S.field(checks, 0)), hd, pf), h)))
    case False{} True{} True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CCont{fields, cnt, fp, size, False{}, depth, True{}, checks, nchecks, True{}}, fr, a, b, c, Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32)), F.logic__subst(B.Buf & U32, z => {C.run(p, 5, S.CCont{fields, cnt, fp, size, False{}, depth, True{}, checks, nchecks, True{}}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool}, B.read32(D.bf(t, n), (a + C.f_hoff(S.field(checks, 0)) : U32)), (D.bf(t, n), Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32))), Rd.read32_any(d, t, n, (a + C.f_hoff(S.field(checks, 0)) : U32), hd, pf), h))))
    case False{} True{} False{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CCont{fields, cnt, fp, size, False{}, depth, True{}, checks, nchecks, False{}}, fr, a, b, c, Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32)), F.logic__subst(B.Buf & U32, z => {C.run(p, 5, S.CCont{fields, cnt, fp, size, False{}, depth, True{}, checks, nchecks, False{}}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool}, B.read32(D.bf(t, n), (a + C.f_hoff(S.field(checks, 0)) : U32)), (D.bf(t, n), Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32))), Rd.read32_any(d, t, n, (a + C.f_hoff(S.field(checks, 0)) : U32), hd, pf), h))))
    case False{} False{} True{}: cont_lift(t, d, p, fr, V.M(t, d, p, V.W15{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32))}), ih(D.T15{}, S.CCont{fields, cnt, fp, size, False{}, depth, False{}, checks, nchecks, True{}}, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32)), F.logic__subst(B.Buf & U32, z => {C.run(p, 15, S.CCont{fields, cnt, fp, size, False{}, depth, False{}, checks, nchecks, True{}}, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool}, B.read32(D.bf(t, n), (a + C.f_hoff(S.field(checks, 0)) : U32)), (D.bf(t, n), Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32))), Rd.read32_any(d, t, n, (a + C.f_hoff(S.field(checks, 0)) : U32), hd, pf), h)))
    case False{} False{} False{}: cont_lift(t, d, p, fr, V.M(t, d, p, V.W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0}), ih(D.T8{}, S.CCont{fields, cnt, fp, size, False{}, depth, False{}, checks, nchecks, False{}}, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32)), F.logic__subst(B.Buf & U32, z => {C.run(p, 8, S.CCont{fields, cnt, fp, size, False{}, depth, False{}, checks, nchecks, False{}}, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool}, B.read32(D.bf(t, n), (a + C.f_hoff(S.field(checks, 0)) : U32)), (D.bf(t, n), Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32))), Rd.read32_any(d, t, n, (a + C.f_hoff(S.field(checks, 0)) : U32), hd, pf), h)))

def cont_len(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, +fixed: Bool, +depth: U32, +plain: Bool, +checks: S.CS, +nchecks: U32, +simple: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p), ok: Bool, e: {C.bsel(fixed, U32.is_eq((b - a : U32), fp), U32.is_ge((b - a : U32), fp)) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(plain, 5, C.usel(simple, C.usel(fixed, 16, 15), 8)), 6), S.CCont{fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple},
          C.fsel(plain, fr, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c, C.first_read(fixed, S.field(checks, 0), a, D.bf(t, n))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CCont{fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}, fr, a, b, c, 0):
  match ok:
    case True{}:
      L.reassoc(V.Is(C.bsel(fixed, U32.is_eq((b - a : U32), fp), U32.is_ge((b - a : U32), fp))), V.If(plain, Unit, V.If(simple, V.If(fixed, V.M(t, d, p, V.W16{checks, 0, nchecks, a, Rd.b8(t, d, C.check_byte(a, S.field(checks, 0)))}), V.M(t, d, p, V.W15{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, Rd.r32(t, d, (a + C.f_hoff(S.field(checks, 0)) : U32))})), V.M(t, d, p, V.W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0}))), D.FD(t, d, 1n+p, fr), e,
        cont_flags(t, d, n, hd, pf, p, fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple, fr, a, b, c, ih, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CCont{fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}, fr, a, b, c, 0),
      L.no_run6(t, n, p, S.CCont{fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}, C.fsel(plain, fr, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c, C.first_read(fixed, S.field(checks, 0), a, D.bf(t, n)), h))

def t0_cont(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, +fixed: Bool, +depth: U32, +plain: Bool, +checks: S.CS, +nchecks: U32, +simple: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    h: D.Ok(t, n, 1n+p, D.T0{}, S.CCont{fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CCont{fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}, fr, a, b, c, v):
  cont_len(t, d, n, hd, pf, p, fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple, fr, a, b, c, ih,
    C.bsel(fixed, U32.is_eq((b - a : U32), fp), U32.is_ge((b - a : U32), fp)), {==}, h)

# ---- tag 0 on a progressive container -------------------------------------------------------

def pcont_plain(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +sch: S.CS, +fp: U32, plain: Bool, +checks: S.CS, +nchecks: U32,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p),
    h: {C.run(p, C.usel(plain, 5, 8), sch, C.fsel(plain, fr, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(plain, Unit, V.M(t, d, p, V.W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0})) & D.FD(t, d, 1n+p, fr):
  match plain:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, sch, fr, a, b, c, 0, h)))
    case False{}: cont_lift(t, d, p, fr, V.M(t, d, p, V.W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0}), ih(D.T8{}, sch, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}, a, b, c, 0, h))

def pcont_len(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, +fixed: Bool, +plain: Bool, +checks: S.CS, +nchecks: U32,
    +slots: S.CS, +nslots: U32, +active: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p),
    ok: Bool, e: {C.bsel(fixed, U32.is_eq((b - a : U32), fp), U32.is_ge((b - a : U32), fp)) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(plain, 5, 8), 6), S.CPCont{fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active},
          C.fsel(plain, fr, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CPCont{fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}, fr, a, b, c, 0):
  match ok:
    case True{}:
      L.reassoc(V.Is(C.bsel(fixed, U32.is_eq((b - a : U32), fp), U32.is_ge((b - a : U32), fp))), V.If(plain, Unit, V.M(t, d, p, V.W8{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0})), D.FD(t, d, 1n+p, fr), e,
        pcont_plain(t, d, n, p, S.CPCont{fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}, fp, plain, checks, nchecks, fr, a, b, c, ih, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CPCont{fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}, fr, a, b, c, 0),
      L.no_run6(t, n, p, S.CPCont{fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}, C.fsel(plain, fr, C.FCont{checks, 0, nchecks, a, b, fp, S.CFNone{}, 0, 0, fr}), a, b, c, (D.bf(t, n), 0), h))

def t0_pcont(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, +fixed: Bool, +plain: Bool, +checks: S.CS, +nchecks: U32,
    +slots: S.CS, +nslots: U32, +active: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    h: D.Ok(t, n, 1n+p, D.T0{}, S.CPCont{fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CPCont{fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}, fr, a, b, c, v):
  pcont_len(t, d, n, p, fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active, fr, a, b, c, ih,
    C.bsel(fixed, U32.is_eq((b - a : U32), fp), U32.is_ge((b - a : U32), fp)), {==}, h)


# ---- shared helpers for the walks ---------------------------------------------------

def dec_inc(+i: U32) -> {((i + 1 : U32) - 1 : U32) == i : U32}:
  Equal.trans(U32, ((i + 1 : U32) - 1 : U32), ((1 + i : U32) - 1 : U32), i,
    Equal.cong(U32, U32, z => (z - 1 : U32), (i + 1 : U32), (1 + i : U32), F.u32alg__comm(i, 1)),
    F.u32alg__add_sub(1, i))

def shal0(-A: Type, +r: U32, eq: {r == 0 : U32}, x: A) -> V.Shallow(r, A):
  F.logic__subst(U32, z => V.Shallow(z, A), 0, r, Equal.sym(U32, r, 0, eq), x)

def shal1(-A: Type, +r: U32, eq: {r == 1 : U32}) -> V.Shallow(r, A):
  F.logic__subst(U32, z => V.Shallow(z, A), 1, r, Equal.sym(U32, r, 1, eq), Unit{})

def both_true(x: Bool, y: Bool, e: {C.bsel(x, y, False{}) == True{} : Bool}) -> V.Is(x) & V.Is(y):
  match x:
    case True{}: ({==}, e)
    case False{}: Empty.absurd(V.Is(False{}) & V.Is(y), F.logic__false_true(e))

def pack3(-A: Type, -B: Type, -Cc: Type, -Fd: Type, ab: A & B, pr: Cc & Fd) -> (A & B & Cc) & Fd:
  (x, y) = ab
  (z, f) = pr
  ((x, (y, z)), f)

def lift_right(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +up: C.Frame, -A: Type, -B: Type,
    pr: A & (B & D.FD(t, d, p, up))) -> (A & B) & D.FD(t, d, 1n+p, up):
  (x, r) = pr
  (y, f) = r
  ((x, y), DM.fd_mono(t, d, p, up, f))

def lift_m2(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +up: C.Frame, +j: V.Job,
    pr: V.M(t, d, p, j) & D.FD(t, d, p, up)) -> V.M(t, d, 1n+p, j) & D.FD(t, d, 1n+p, up):
  (x, f) = pr
  (G.m_mono(t, d, p, j, x), DM.fd_mono(t, d, p, up, f))

# ---- tag 13 -------------------------------------------------------------------------

def sound_t13(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T13{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T13{}, s, fr, a, b, c, v):
  match s:
    case S.CUnion{+options, +nsel}:
      opt_ok(t, d, n, p, options, nsel, fr, a, b, c, v, ih, C.bsel(U32.is_lt(v, nsel), C.is_leaf(S.field(options, v)), False{}), {==}, h)
    case S.CBool{}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CBool{}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CUint{x0}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CUint{x0}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CBytes{x0, x1}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CBytes{x0, x1}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CByteList{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CByteList{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CBitVec{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CBitVec{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CBitList{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CBitList{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CVec{x0, x1, x2, x3, x4, x5}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CVec{x0, x1, x2, x3, x4, x5}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CVecVar{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CVecVar{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CList{x0, x1, x2, x3, x4, x5, x6}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CList{x0, x1, x2, x3, x4, x5, x6}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CListVar{x0, x1, x2, x3}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CListVar{x0, x1, x2, x3}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CPCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CPCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CNull{}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CNull{}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CFLeaf{x0, x1, x2, x3}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CFLeaf{x0, x1, x2, x3}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CFNode{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CFNode{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CFNone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T13{}, S.CFNone{}, fr, a, b, c, v), L.no_run(t, n, h))

# ---- tag 16: a fixed simple container's check bytes ------------------------------------

def t16_last(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p), last: Bool,
    h: {C.run(p, C.usel(last, 5, 16), s, C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), a, b, c, (D.bf(t, n), Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32)))))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(last, Unit, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))})) & D.FD(t, d, 1n+p, up):
  match last:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, up, ih(D.T5{}, s, up, a, b, c, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32)))), h)))
    case False{}: cont_lift(t, d, p, up, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))}),
      ih(D.T16{}, s, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}, a, b, c, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32)))), h))

def t16_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), +last: Bool,
    ok: Bool, e: {C.byte_ok(C.f_schema(S.field(fields, i)), v) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(last, 5, 16), 6), s, C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), a, b, c, (D.bf(t, n), Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32)))))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> (V.Is(C.byte_ok(C.f_schema(S.field(fields, i)), v)) & V.If(last, Unit, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))}))) & D.FD(t, d, 1n+p, up):
  match ok:
    case True{}: L.reassoc(V.Is(C.byte_ok(C.f_schema(S.field(fields, i)), v)), V.If(last, Unit, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))})), D.FD(t, d, 1n+p, up), e,
      t16_last(t, d, n, p, s, fields, i, cnt, base, endp, fp, pend, start, has, up, a, b, c, ih, last, h))
    case False{}: Empty.absurd((V.Is(C.byte_ok(C.f_schema(S.field(fields, i)), v)) & V.If(last, Unit, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))}))) & D.FD(t, d, 1n+p, up),
      ih(D.T6{}, s, C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), a, b, c, Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32)))), h))

def sound_t16(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T16{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T16{}, s, fr, a, b, c, v):
  match fr:
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
      t16_ok(t, d, n, p, s, fields, i, cnt, base, endp, fp, pend, start, has, up, a, b, c, v, ih, U32.is_eq((i + 1 : U32), cnt), C.byte_ok(C.f_schema(S.field(fields, i)), v), {==},
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(C.byte_ok(C.f_schema(S.field(fields, i)), v), C.usel(U32.is_eq((i + 1 : U32), cnt), 5, 16), 6), s,
            C.fsel(U32.is_eq((i + 1 : U32), cnt), up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
          B.byte_at(D.bf(t, n), C.check_byte(base, S.field(fields, (i + 1 : U32)))), (D.bf(t, n), Rd.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))),
          Rd.byte_any(d, t, n, C.check_byte(base, S.field(fields, (i + 1 : U32))), hd, pf), h))
    case C.FDone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T16{}, s, C.FDone{}, a, b, c, v), L.no_run(t, n, h))
    case C.FRep{x0, x1, x2, x3, x4}: Empty.absurd(D.Den(t, d, 1n+p, D.T16{}, s, C.FRep{x0, x1, x2, x3, x4}, a, b, c, v), L.no_run(t, n, h))
    case C.FVarList{x0, x1, x2, x3, x4, x5}: Empty.absurd(D.Den(t, d, 1n+p, D.T16{}, s, C.FVarList{x0, x1, x2, x3, x4, x5}, a, b, c, v), L.no_run(t, n, h))

# ---- tag 15: a simple container's offsets --------------------------------------------

def t15_end(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fields: S.CS, +i: U32, +endp: U32, +base: U32, +v: U32, +up: C.Frame, +a: U32, +b: U32, +c: U32, +r: U32, ih: D.IH(t, d, n, p),
    en: Bool, e: {U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1) == en : Bool},
    h: {C.run(p, C.usel(en, 5, 6), s, up, a, b, c, (D.bf(t, n), r)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.Is(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1)) & D.FD(t, d, 1n+p, up):
  match en:
    case True{}: (e, DM.fd_mono(t, d, p, up, ih(D.T5{}, s, up, a, b, c, r, h)))
    case False{}: Empty.absurd(V.Is(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1)) & D.FD(t, d, 1n+p, up),
      ih(D.T6{}, s, up, a, b, c, r, h))

def t15_last(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), last: Bool,
    h: {C.run(p, C.usel(last, C.usel(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1), 5, 6), 15), s,
          C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), 1, up}), a, b, c, (D.bf(t, n), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(last, V.Is(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1)),
         V.M(t, d, p, V.W15{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32))})) & D.FD(t, d, 1n+p, up):
  match last:
    case True{}: t15_end(t, d, n, p, s, fields, i, endp, base, v, up, a, b, c, Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32)), ih, U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1), {==}, h)
    case False{}: cont_lift(t, d, p, up, V.M(t, d, p, V.W15{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32))}),
      ih(D.T15{}, s, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), 1, up}, a, b, c, Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32)), h))

def t15_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), +last: Bool,
    ok: Bool, e: {C.bsel(C.bsel(U32.is_eq(i, 0), U32.is_eq(v, fp), C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})), C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, ((base + v : U32) - start : U32)), 1)), False{}) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(last, C.usel(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1), 5, 6), 15), 6), s,
          C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), 1, up}), a, b, c, (D.bf(t, n), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> (V.Is(C.bsel(U32.is_eq(i, 0), U32.is_eq(v, fp), C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{}))) & V.Is(C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, ((base + v : U32) - start : U32)), 1))) & V.If(last, V.Is(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1)),
         V.M(t, d, p, V.W15{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32))}))) & D.FD(t, d, 1n+p, up):
  match ok:
    case True{}: pack3(V.Is(C.bsel(U32.is_eq(i, 0), U32.is_eq(v, fp), C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{}))), V.Is(C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, ((base + v : U32) - start : U32)), 1))), V.If(last, V.Is(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1)),
         V.M(t, d, p, V.W15{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32))})), D.FD(t, d, 1n+p, up),
      both_true(C.bsel(U32.is_eq(i, 0), U32.is_eq(v, fp), C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})), C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, ((base + v : U32) - start : U32)), 1)), e), t15_last(t, d, n, p, s, fields, i, cnt, base, endp, fp, pend, start, has, up, a, b, c, v, ih, last, h))
    case False{}: Empty.absurd((V.Is(C.bsel(U32.is_eq(i, 0), U32.is_eq(v, fp), C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{}))) & V.Is(C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, ((base + v : U32) - start : U32)), 1))) & V.If(last, V.Is(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1)),
         V.M(t, d, p, V.W15{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32))}))) & D.FD(t, d, 1n+p, up),
      ih(D.T6{}, s, C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), 1, up}), a, b, c, Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32)), h))

def sound_t15(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T15{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T15{}, s, fr, a, b, c, v):
  match fr:
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
      t15_ok(t, d, n, p, s, fields, i, cnt, base, endp, fp, pend, start, has, up, a, b, c, v, ih, U32.is_eq((i + 1 : U32), cnt), C.bsel(C.bsel(U32.is_eq(i, 0), U32.is_eq(v, fp), C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})), C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, ((base + v : U32) - start : U32)), 1)), False{}), {==},
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(C.bsel(C.bsel(U32.is_eq(i, 0), U32.is_eq(v, fp), C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})), C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, ((base + v : U32) - start : U32)), 1)), False{}), C.usel(U32.is_eq((i + 1 : U32), cnt), C.usel(U32.is_eq(S.shallow(C.f_schema(S.field(fields, i)), (endp - (base + v : U32) : U32)), 1), 5, 6), 15), 6), s,
            C.fsel(U32.is_eq((i + 1 : U32), cnt), up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), (base + v : U32), 1, up}), a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
          B.read32(D.bf(t, n), (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32)), (D.bf(t, n), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32))),
          Rd.read32_any(d, t, n, (base + C.f_hoff(S.field(fields, (i + 1 : U32))) : U32), hd, pf), h))
    case C.FDone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T15{}, s, C.FDone{}, a, b, c, v), L.no_run(t, n, h))
    case C.FRep{x0, x1, x2, x3, x4}: Empty.absurd(D.Den(t, d, 1n+p, D.T15{}, s, C.FRep{x0, x1, x2, x3, x4}, a, b, c, v), L.no_run(t, n, h))
    case C.FVarList{x0, x1, x2, x3, x4, x5}: Empty.absurd(D.Den(t, d, 1n+p, D.T15{}, s, C.FVarList{x0, x1, x2, x3, x4, x5}, a, b, c, v), L.no_run(t, n, h))

# ---- tag 9: a general container's variable-field offset ---------------------------------

def t9_sh0(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +v: U32, +r: U32, eq: {r == 0 : U32},
    pr: V.M(t, d, p, V.Node{pend, start, (base + v : U32)}) & (V.M(t, d, p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, p, up)))
    -> V.Shallow(r, V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)})) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)):
  (x, rest) = pr
  (shal0(V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)}), r, eq, G.m_mono(t, d, p, V.Node{pend, start, (base + v : U32)}, x)), lift_m2(t, d, p, up, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}, rest))


def t9_k(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    k: Sh, +eq: {S.shallow(pend, ((base + v : U32) - start : U32)) == sh_lit(k) : U32},
    h: {C.run(p, C.shallow_tag(S.shallow(pend, ((base + v : U32) - start : U32)), 0, 8), pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.Shallow(S.shallow(pend, ((base + v : U32) - start : U32)), V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)})) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)):
  match k:
    case Sh0{}: t9_sh0(t, d, p, fields, i, cnt, base, endp, fp, pend, start, has, up, v, S.shallow(pend, ((base + v : U32) - start : U32)), eq,
      ih(D.T0{}, pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, 0,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 8), pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool},
          S.shallow(pend, ((base + v : U32) - start : U32)), 0, eq, h)))
    case Sh1{}: (shal1(V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)}), S.shallow(pend, ((base + v : U32) - start : U32)), eq),
      lift_m2(t, d, p, up, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}, ih(D.T8{}, pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, 0,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 8), pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool},
          S.shallow(pend, ((base + v : U32) - start : U32)), 1, eq, h))))
    case Sh2{}: Empty.absurd(V.Shallow(S.shallow(pend, ((base + v : U32) - start : U32)), V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)})) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)),
      ih(D.T6{}, pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, 0,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 8), pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool},
          S.shallow(pend, ((base + v : U32) - start : U32)), 2, eq, h)))

def t9_sh(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    pr: &k: Sh -> {S.shallow(pend, ((base + v : U32) - start : U32)) == sh_lit(k) : U32},
    h: {C.run(p, C.shallow_tag(S.shallow(pend, ((base + v : U32) - start : U32)), 0, 8), pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.Shallow(S.shallow(pend, ((base + v : U32) - start : U32)), V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)})) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)):
  match pr:
    case (k, eq): t9_k(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, v, ih, k, eq, h)

def t9_grow(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    g: Bool, e: {C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{}) == g : Bool},
    h: {C.run(p, C.usel(g, C.shallow_tag(S.shallow(pend, ((base + v : U32) - start : U32)), 0, 8), 6), pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> (V.Is(C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})) & V.Shallow(S.shallow(pend, ((base + v : U32) - start : U32)), V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)}))) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)):
  match g:
    case True{}: L.reassoc(V.Is(C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})), V.Shallow(S.shallow(pend, ((base + v : U32) - start : U32)), V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)})), (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)), e,
      t9_sh(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, v, ih, shallow_is(pend, ((base + v : U32) - start : U32)), h))
    case False{}: Empty.absurd((V.Is(C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})) & V.Shallow(S.shallow(pend, ((base + v : U32) - start : U32)), V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)}))) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)),
      ih(D.T6{}, pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, 0, h))

def t9_first(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    ok: Bool, e: {U32.is_eq(v, fp) == ok : Bool},
    h: {C.run(p, C.usel(ok, 8, 6), pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.Is(U32.is_eq(v, fp)) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)):
  match ok:
    case True{}: (e, lift_m2(t, d, p, up, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}, ih(D.T8{}, pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, 0, h)))
    case False{}: Empty.absurd(V.Is(U32.is_eq(v, fp)) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)), ih(D.T6{}, pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, 0, h))

def t9_pend(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, +v: U32, ih: D.IH(t, d, n, p), pending: Bool,
    h: {C.run(p, C.usel(pending, C.usel(C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{}), C.shallow_tag(S.shallow(pend, ((base + v : U32) - start : U32)), 0, 8), 6), C.usel(U32.is_eq(v, fp), 8, 6)),
          pend, C.FCont{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1, up}, start, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(pending, V.Is(C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{})) & V.Shallow(S.shallow(pend, ((base + v : U32) - start : U32)), V.M(t, d, 1n+p, V.Node{pend, start, (base + v : U32)})), V.Is(U32.is_eq(v, fp))) & (V.M(t, d, 1n+p, V.W8{fields, i, cnt, base, endp, fp, C.f_schema(S.field(fields, (i - 1 : U32))), (base + v : U32), 1}) & D.FD(t, d, 1n+p, up)):
  match pending:
    case True{}: t9_grow(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, v, ih, C.bsel(U32.is_ge((base + v : U32), start), U32.is_le((base + v : U32), endp), False{}), {==}, h)
    case False{}: t9_first(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, v, ih, U32.is_eq(v, fp), {==}, h)

def sound_t9(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T9{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T9{}, s, fr, a, b, c, v):
  match fr:
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}: t9_pend(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, v, ih, U32.is_eq(has, 1), h)
    case C.FDone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T9{}, s, C.FDone{}, a, b, c, v), L.no_run(t, n, h))
    case C.FRep{x0, x1, x2, x3, x4}: Empty.absurd(D.Den(t, d, 1n+p, D.T9{}, s, C.FRep{x0, x1, x2, x3, x4}, a, b, c, v), L.no_run(t, n, h))
    case C.FVarList{x0, x1, x2, x3, x4, x5}: Empty.absurd(D.Den(t, d, 1n+p, D.T9{}, s, C.FVarList{x0, x1, x2, x3, x4, x5}, a, b, c, v), L.no_run(t, n, h))

# ---- tag 8: a general container's walk ------------------------------------------------

def t8_sh0(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +pend: S.CS, +start: U32, +endp: U32, +up: C.Frame, +r: U32, eq: {r == 0 : U32},
    pr: V.M(t, d, p, V.Node{pend, start, endp}) & D.FD(t, d, p, up)) -> V.Shallow(r, V.M(t, d, p, V.Node{pend, start, endp})) & D.FD(t, d, 1n+p, up):
  (x, f) = pr
  (shal0(V.M(t, d, p, V.Node{pend, start, endp}), r, eq, x), DM.fd_mono(t, d, p, up, f))


def t8_k(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, +r: U32, ih: D.IH(t, d, n, p),
    k: Sh, +eq: {S.shallow(pend, (endp - start : U32)) == sh_lit(k) : U32},
    h: {C.run(p, C.shallow_tag(S.shallow(pend, (endp - start : U32)), 0, 5), pend, up, start, endp, c, (D.bf(t, n), r)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.Shallow(S.shallow(pend, (endp - start : U32)), V.M(t, d, p, V.Node{pend, start, endp})) & D.FD(t, d, 1n+p, up):
  match k:
    case Sh0{}: t8_sh0(t, d, p, pend, start, endp, up, S.shallow(pend, (endp - start : U32)), eq,
      ih(D.T0{}, pend, up, start, endp, c, r,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 5), pend, up, start, endp, c, (D.bf(t, n), r)) == (D.bf(t, n), True{}) : B.Buf & Bool}, S.shallow(pend, (endp - start : U32)), 0, eq, h)))
    case Sh1{}: (shal1(V.M(t, d, p, V.Node{pend, start, endp}), S.shallow(pend, (endp - start : U32)), eq),
      DM.fd_mono(t, d, p, up, ih(D.T5{}, pend, up, start, endp, c, r,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 5), pend, up, start, endp, c, (D.bf(t, n), r)) == (D.bf(t, n), True{}) : B.Buf & Bool}, S.shallow(pend, (endp - start : U32)), 1, eq, h))))
    case Sh2{}: Empty.absurd(V.Shallow(S.shallow(pend, (endp - start : U32)), V.M(t, d, p, V.Node{pend, start, endp})) & D.FD(t, d, 1n+p, up),
      ih(D.T6{}, pend, up, start, endp, c, r,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 5), pend, up, start, endp, c, (D.bf(t, n), r)) == (D.bf(t, n), True{}) : B.Buf & Bool}, S.shallow(pend, (endp - start : U32)), 2, eq, h)))

def t8_sh(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, +r: U32, ih: D.IH(t, d, n, p),
    pr: &k: Sh -> {S.shallow(pend, (endp - start : U32)) == sh_lit(k) : U32},
    h: {C.run(p, C.shallow_tag(S.shallow(pend, (endp - start : U32)), 0, 5), pend, up, start, endp, c, (D.bf(t, n), r)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.Shallow(S.shallow(pend, (endp - start : U32)), V.M(t, d, p, V.Node{pend, start, endp})) & D.FD(t, d, 1n+p, up):
  match pr:
    case (k, eq): t8_k(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, r, ih, k, eq, h)

def t8_end(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, +r: U32, ih: D.IH(t, d, n, p), pending: Bool,
    h: {C.run(p, C.usel(pending, C.shallow_tag(S.shallow(pend, (endp - start : U32)), 0, 5), 5), pend, up, start, endp, c, (D.bf(t, n), r)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(pending, V.Shallow(S.shallow(pend, (endp - start : U32)), V.M(t, d, p, V.Node{pend, start, endp})), Unit) & D.FD(t, d, 1n+p, up):
  match pending:
    case True{}: t8_sh(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, r, ih, shallow_is(pend, (endp - start : U32)), h)
    case False{}: (Unit{}, DM.fd_mono(t, d, p, up, ih(D.T5{}, pend, up, start, endp, c, r, h)))

def t8_plain(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, ih: D.IH(t, d, n, p), plain: Bool,
    h: {C.run(p, C.usel(plain, 8, 0), C.f_schema(S.field(fields, i)), C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}, (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32), c, (D.bf(t, n), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(plain, V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has}), V.M(t, d, p, V.Node{C.f_schema(S.field(fields, i)), (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32)}) & V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has})) & D.FD(t, d, 1n+p, up):
  match plain:
    case True{}: cont_lift(t, d, p, up, V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has}), ih(D.T8{}, C.f_schema(S.field(fields, i)), C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}, (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32), c, Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), h))
    case False{}: lift_right(t, d, p, up, V.M(t, d, p, V.Node{C.f_schema(S.field(fields, i)), (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32)}), V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has}), ih(D.T0{}, C.f_schema(S.field(fields, i)), C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}, (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32), c, Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), h))

def t8_var(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, ih: D.IH(t, d, n, p),
    h: {C.run(p, 9, pend, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}, (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32), c, (D.bf(t, n), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> (V.If(U32.is_eq(has, 1), V.Is(C.bsel(U32.is_ge(V.var_at(t, d, base, S.field(fields, i)), start), U32.is_le(V.var_at(t, d, base, S.field(fields, i)), endp), False{})) & V.Shallow(S.shallow(pend, (V.var_at(t, d, base, S.field(fields, i)) - start : U32)), V.M(t, d, p, V.Node{pend, start, V.var_at(t, d, base, S.field(fields, i))})), V.Is(U32.is_eq(Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), fp))) & V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), V.var_at(t, d, base, S.field(fields, i)), 1})) & D.FD(t, d, 1n+p, up):
  lift_right(t, d, p, up, V.If(U32.is_eq(has, 1), V.Is(C.bsel(U32.is_ge(V.var_at(t, d, base, S.field(fields, i)), start), U32.is_le(V.var_at(t, d, base, S.field(fields, i)), endp), False{})) & V.Shallow(S.shallow(pend, (V.var_at(t, d, base, S.field(fields, i)) - start : U32)), V.M(t, d, p, V.Node{pend, start, V.var_at(t, d, base, S.field(fields, i))})), V.Is(U32.is_eq(Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), fp))), V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), V.var_at(t, d, base, S.field(fields, i)), 1}),
    F.logic__subst(U32, z => V.If(U32.is_eq(has, 1), V.Is(C.bsel(U32.is_ge(V.var_at(t, d, base, S.field(fields, i)), start), U32.is_le(V.var_at(t, d, base, S.field(fields, i)), endp), False{})) & V.Shallow(S.shallow(pend, (V.var_at(t, d, base, S.field(fields, i)) - start : U32)), V.M(t, d, p, V.Node{pend, start, V.var_at(t, d, base, S.field(fields, i))})), V.Is(U32.is_eq(Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), fp))) & V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, z)), V.var_at(t, d, base, S.field(fields, i)), 1}) & D.FD(t, d, p, up),
      ((i + 1 : U32) - 1 : U32), i, dec_inc(i), ih(D.T9{}, pend, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}, (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32), c, Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), h)))

def t8_fixed(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, ih: D.IH(t, d, n, p), fixed: Bool, +plain: Bool,
    h: {C.run(p, C.usel(fixed, C.usel(plain, 8, 0), 9), C.ssel(fixed, C.f_schema(S.field(fields, i)), pend), C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}, (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32), c, (D.bf(t, n), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(fixed, V.If(plain, V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has}), V.M(t, d, p, V.Node{C.f_schema(S.field(fields, i)), (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32)}) & V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has})), V.If(U32.is_eq(has, 1), V.Is(C.bsel(U32.is_ge(V.var_at(t, d, base, S.field(fields, i)), start), U32.is_le(V.var_at(t, d, base, S.field(fields, i)), endp), False{})) & V.Shallow(S.shallow(pend, (V.var_at(t, d, base, S.field(fields, i)) - start : U32)), V.M(t, d, p, V.Node{pend, start, V.var_at(t, d, base, S.field(fields, i))})), V.Is(U32.is_eq(Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), fp))) & V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), V.var_at(t, d, base, S.field(fields, i)), 1})) & D.FD(t, d, 1n+p, up):
  match fixed:
    case True{}: t8_plain(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, ih, plain, h)
    case False{}: t8_var(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, ih, h)

def t8_last(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +fields: S.CS, +i: U32, +cnt: U32, +base: U32, +endp: U32, +fp: U32, +pend: S.CS, +start: U32, +has: U32, +up: C.Frame, +c: U32, ih: D.IH(t, d, n, p), last: Bool, +fixed: Bool, +plain: Bool,
    h: {C.run(p, C.usel(last, C.usel(U32.is_eq(has, 1), C.shallow_tag(S.shallow(pend, (endp - start : U32)), 0, 5), 5), C.usel(fixed, C.usel(plain, 8, 0), 9)),
          C.ssel(last, pend, C.ssel(fixed, C.f_schema(S.field(fields, i)), pend)), C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), C.usel(last, start, (base + C.f_hoff(S.field(fields, i)) : U32)), C.usel(last, endp, ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32)), c, (D.bf(t, n), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(last, V.If(U32.is_eq(has, 1), V.Shallow(S.shallow(pend, (endp - start : U32)), V.M(t, d, p, V.Node{pend, start, endp})), Unit),
         V.If(fixed, V.If(plain, V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has}), V.M(t, d, p, V.Node{C.f_schema(S.field(fields, i)), (base + C.f_hoff(S.field(fields, i)) : U32), ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32)}) & V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has})), V.If(U32.is_eq(has, 1), V.Is(C.bsel(U32.is_ge(V.var_at(t, d, base, S.field(fields, i)), start), U32.is_le(V.var_at(t, d, base, S.field(fields, i)), endp), False{})) & V.Shallow(S.shallow(pend, (V.var_at(t, d, base, S.field(fields, i)) - start : U32)), V.M(t, d, p, V.Node{pend, start, V.var_at(t, d, base, S.field(fields, i))})), V.Is(U32.is_eq(Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), fp))) & V.M(t, d, p, V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, C.f_schema(S.field(fields, i)), V.var_at(t, d, base, S.field(fields, i)), 1}))) & D.FD(t, d, 1n+p, up):
  match last:
    case True{}: t8_end(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32)), ih, U32.is_eq(has, 1), h)
    case False{}: t8_fixed(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, ih, fixed, plain, h)

def sound_t8(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T8{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T8{}, s, fr, a, b, c, v):
  match fr:
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
      t8_last(t, d, n, p, fields, i, cnt, base, endp, fp, pend, start, has, up, c, ih, U32.is_eq(i, cnt), C.f_fixed(S.field(fields, i)), S.is_plain(C.f_schema(S.field(fields, i))),
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_eq(i, cnt), C.usel(U32.is_eq(has, 1), C.shallow_tag(S.shallow(pend, (endp - start : U32)), 0, 5), 5),
              C.usel(C.f_fixed(S.field(fields, i)), C.usel(S.is_plain(C.f_schema(S.field(fields, i))), 8, 0), 9)),
            C.ssel(U32.is_eq(i, cnt), pend, C.ssel(C.f_fixed(S.field(fields, i)), C.f_schema(S.field(fields, i)), pend)), C.fsel(U32.is_eq(i, cnt), up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}),
            C.usel(U32.is_eq(i, cnt), start, (base + C.f_hoff(S.field(fields, i)) : U32)), C.usel(U32.is_eq(i, cnt), endp, ((base + C.f_hoff(S.field(fields, i)) : U32) + C.f_hsize(S.field(fields, i)) : U32)), c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
          B.read32(D.bf(t, n), (base + C.f_hoff(S.field(fields, i)) : U32)), (D.bf(t, n), Rd.r32(t, d, (base + C.f_hoff(S.field(fields, i)) : U32))), Rd.read32_any(d, t, n, (base + C.f_hoff(S.field(fields, i)) : U32), hd, pf), h))
    case C.FDone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T8{}, s, C.FDone{}, a, b, c, v), L.no_run(t, n, h))
    case C.FRep{x0, x1, x2, x3, x4}: Empty.absurd(D.Den(t, d, 1n+p, D.T8{}, s, C.FRep{x0, x1, x2, x3, x4}, a, b, c, v), L.no_run(t, n, h))
    case C.FVarList{x0, x1, x2, x3, x4, x5}: Empty.absurd(D.Den(t, d, 1n+p, D.T8{}, s, C.FVarList{x0, x1, x2, x3, x4, x5}, a, b, c, v), L.no_run(t, n, h))
