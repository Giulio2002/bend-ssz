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

# Soundness steps of the scanner for sequences: tag 0 on vectors and lists,
# the first offset (tag 4), the frame pops (tag 5) and the offset steps of
# variable-size sequences (tags 11, 12).

def mono_both(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, j1: V.Job, j2: V.Job, pr: V.M(t, d, p, j1) & V.M(t, d, p, j2))
    -> V.M(t, d, 1n+p, j1) & V.M(t, d, 1n+p, j2):
  (x, y) = pr
  (G.m_mono(t, d, p, j1, x), G.m_mono(t, d, p, j2, y))

# M(p, j1) & (M(p, j2) & FD(p, fr))  ->  (M(p, j1) & M(p, j2)) & FD(1 + p, fr)
def node_rest(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, j1: V.Job, j2: V.Job, +fr: C.Frame,
    pr: V.M(t, d, p, j1) & (V.M(t, d, p, j2) & D.FD(t, d, p, fr))) -> (V.M(t, d, p, j1) & V.M(t, d, p, j2)) & D.FD(t, d, 1n+p, fr):
  (x, r) = pr
  (y, f) = r
  ((x, y), DM.fd_mono(t, d, p, fr, f))

# ---- tag 0: fixed-stride vectors and lists ---------------------------------------

# Either nothing to visit (pop), or the first element and the rest.
def rep_skip(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +sch: S.CS, +elem: S.CS, +cnt: Nat, +st: Nat,
    +fr: C.Frame, +a: Nat, +c: U32, ih: D.IH(t, d, n, p), skip: Bool,
    h: {C.run(p, C.usel(skip, 5, 0), C.ssel(skip, sch, elem),
          C.fsel(skip, fr, C.FRep{elem, Nat.sub(cnt, 1n), st, Nat.add(a, st), fr}), a, Nat.add(a, st), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(skip, Unit, V.M(t, d, p, V.Node{elem, a, Nat.add(a, st)}) & V.M(t, d, p, V.Rep{elem, Nat.sub(cnt, 1n), Nat.add(a, st), st})) & D.FD(t, d, 1n+p, fr):
  match skip:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, sch, fr, a, Nat.add(a, st), c, 0, h)))
    case False{}:
      node_rest(t, d, p, V.Node{elem, a, Nat.add(a, st)}, V.Rep{elem, Nat.sub(cnt, 1n), Nat.add(a, st), st}, fr,
        ih(D.T0{}, elem, C.FRep{elem, Nat.sub(cnt, 1n), st, Nat.add(a, st), fr}, a, Nat.add(a, st), c, 0, h))

def vec_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, ih: D.IH(t, d, n, p), ok: Bool, e: {Nat.is_eq(Nat.sub(b, a), Nat.mul(U32.to_nat(count), U32.to_nat(stride))) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(Bool.or(U32.is_eq(count, 0), plain), 5, 0), 6), C.ssel(Bool.or(U32.is_eq(count, 0), plain), S.CVec{elem, count, stride, depth, basic, plain}, elem),
          C.fsel(Bool.or(U32.is_eq(count, 0), plain), fr, C.FRep{elem, Nat.sub(U32.to_nat(count), 1n), U32.to_nat(stride), Nat.add(a, U32.to_nat(stride)), fr}), a, Nat.add(a, U32.to_nat(stride)), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, b, c, 0):
  match ok:
    case True{}:
      L.reassoc(V.Is(Nat.is_eq(Nat.sub(b, a), Nat.mul(U32.to_nat(count), U32.to_nat(stride)))),
        V.If(Bool.or(U32.is_eq(count, 0), plain), Unit, V.M(t, d, p, V.Node{elem, a, Nat.add(a, U32.to_nat(stride))}) & V.M(t, d, p, V.Rep{elem, Nat.sub(U32.to_nat(count), 1n), Nat.add(a, U32.to_nat(stride)), U32.to_nat(stride)})),
        D.FD(t, d, 1n+p, fr), e,
        rep_skip(t, d, n, p, S.CVec{elem, count, stride, depth, basic, plain}, elem, U32.to_nat(count), U32.to_nat(stride), fr, a, c, ih, Bool.or(U32.is_eq(count, 0), plain), h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, b, c, 0),
      ih(D.T6{}, C.ssel(Bool.or(U32.is_eq(count, 0), plain), S.CVec{elem, count, stride, depth, basic, plain}, elem),
        C.fsel(Bool.or(U32.is_eq(count, 0), plain), fr, C.FRep{elem, Nat.sub(U32.to_nat(count), 1n), U32.to_nat(stride), Nat.add(a, U32.to_nat(stride)), fr}), a, Nat.add(a, U32.to_nat(stride)), c, 0, h))

def t0_vec(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, b, c, v):
  vec_ok(t, d, n, p, elem, count, stride, depth, basic, plain, fr, a, b, c, ih, Nat.is_eq(Nat.sub(b, a), Nat.mul(U32.to_nat(count), U32.to_nat(stride))), {==}, h)

def list_w(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, ih: D.IH(t, d, n, p), w: Bool, ew: {S.within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big) == w : Bool},
    h: {C.run(p, C.usel(w, C.usel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), 5, 0), 6), C.ssel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), S.CList{elem, lim, big, stride, depth, basic, plain}, elem),
          C.fsel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), fr, C.FRep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), U32.to_nat(stride), Nat.add(a, U32.to_nat(stride)), fr}), a, Nat.add(a, U32.to_nat(stride)), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> (V.Is(S.within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big)) &
        V.If(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), Unit, V.M(t, d, p, V.Node{elem, a, Nat.add(a, U32.to_nat(stride))}) & V.M(t, d, p, V.Rep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), Nat.add(a, U32.to_nat(stride)), U32.to_nat(stride)}))) &
       D.FD(t, d, 1n+p, fr):
  match w:
    case True{}:
      L.reassoc(V.Is(S.within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big)),
        V.If(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), Unit, V.M(t, d, p, V.Node{elem, a, Nat.add(a, U32.to_nat(stride))}) & V.M(t, d, p, V.Rep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), Nat.add(a, U32.to_nat(stride)), U32.to_nat(stride)})),
        D.FD(t, d, 1n+p, fr), ew,
        rep_skip(t, d, n, p, S.CList{elem, lim, big, stride, depth, basic, plain}, elem, Nat.div(Nat.sub(b, a), U32.to_nat(stride)), U32.to_nat(stride), fr, a, c, ih, Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), h))
    case False{}: Empty.absurd(
      (V.Is(S.within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big)) & V.If(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), Unit, V.M(t, d, p, V.Node{elem, a, Nat.add(a, U32.to_nat(stride))}) & V.M(t, d, p, V.Rep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), Nat.add(a, U32.to_nat(stride)), U32.to_nat(stride)}))) & D.FD(t, d, 1n+p, fr),
      ih(D.T6{}, C.ssel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), S.CList{elem, lim, big, stride, depth, basic, plain}, elem),
        C.fsel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), fr, C.FRep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), U32.to_nat(stride), Nat.add(a, U32.to_nat(stride)), fr}), a, Nat.add(a, U32.to_nat(stride)), c, 0, h))

def list_ex(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, ih: D.IH(t, d, n, p), ex: Bool, e: {Nat.is_eq(Nat.sub(b, a), Nat.mul(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), U32.to_nat(stride))) == ex : Bool},
    h: {C.run(p, C.usel(C.bsel(ex, S.within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big), False{}), C.usel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), 5, 0), 6), C.ssel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), S.CList{elem, lim, big, stride, depth, basic, plain}, elem),
          C.fsel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), fr, C.FRep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), U32.to_nat(stride), Nat.add(a, U32.to_nat(stride)), fr}), a, Nat.add(a, U32.to_nat(stride)), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CList{elem, lim, big, stride, depth, basic, plain}, fr, a, b, c, 0):
  match ex:
    case True{}:
      L.reassoc(V.Is(Nat.is_eq(Nat.sub(b, a), Nat.mul(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), U32.to_nat(stride)))),
        V.Is(S.within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big)) &
        V.If(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), Unit, V.M(t, d, p, V.Node{elem, a, Nat.add(a, U32.to_nat(stride))}) & V.M(t, d, p, V.Rep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), Nat.add(a, U32.to_nat(stride)), U32.to_nat(stride)})),
        D.FD(t, d, 1n+p, fr), e,
        list_w(t, d, n, p, elem, lim, big, stride, depth, basic, plain, fr, a, b, c, ih, S.within(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), lim, big), {==}, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CList{elem, lim, big, stride, depth, basic, plain}, fr, a, b, c, 0),
      ih(D.T6{}, C.ssel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), S.CList{elem, lim, big, stride, depth, basic, plain}, elem),
        C.fsel(Bool.or(Nat.is_eq(Nat.sub(b, a), 0n), plain), fr, C.FRep{elem, Nat.sub(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), 1n), U32.to_nat(stride), Nat.add(a, U32.to_nat(stride)), fr}), a, Nat.add(a, U32.to_nat(stride)), c, 0, h))

def t0_list(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CList{elem, lim, big, stride, depth, basic, plain}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CList{elem, lim, big, stride, depth, basic, plain}, fr, a, b, c, v):
  list_ex(t, d, n, p, elem, lim, big, stride, depth, basic, plain, fr, a, b, c, ih, Nat.is_eq(Nat.sub(b, a), Nat.mul(Nat.div(Nat.sub(b, a), U32.to_nat(stride)), U32.to_nat(stride))), {==}, h)

# ---- tag 0: variable-size vector and list; tag 4: the first offset --------------

# Is(A) & (Is(B) & M) & FD at p  from  A and (Is(B) & (M & FD(p)))
def lead3(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, -A: Type, -Bt: Type, j: V.Job, ea: A,
    pr: Bt & (V.M(t, d, p, j) & D.FD(t, d, p, fr))) -> (A & (Bt & V.M(t, d, p, j))) & D.FD(t, d, 1n+p, fr):
  (x, r) = pr
  (m, f) = r
  ((ea, (x, m)), DM.fd_mono(t, d, p, fr, f))

def vecvar_lt(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +depth: U32, +fr: C.Frame, +a: Nat, +b: Nat,
    ih: D.IH(t, d, n, p), lt: Bool, e: {Nat.is_lt(Nat.sub(b, a), Nat.mul(4n, U32.to_nat(count))) == lt : Bool},
    h: {C.run(p, C.usel(lt, 6, 4), S.CVecVar{elem, count, depth}, fr, a, b, count, (D.bf(t, n), V.r32(t, d, a))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CVecVar{elem, count, depth}, fr, a, b, 0, 0):
  match lt:
    case True{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CVecVar{elem, count, depth}, fr, a, b, 0, 0), ih(D.T6{}, S.CVecVar{elem, count, depth}, fr, a, b, count, V.r32(t, d, a), h))
    case False{}:
      lead3(t, d, p, fr, V.Is(Bool.not(Nat.is_lt(Nat.sub(b, a), Nat.mul(4n, U32.to_nat(count))))), V.Is(Nat.is_eq(U32.to_nat(V.r32(t, d, a)), Nat.mul(4n, U32.to_nat(count)))), V.VEl{elem, 0n, U32.to_nat(count), a, b},
        F.logic__subst(Bool, z => V.Is(Bool.not(z)), False{}, Nat.is_lt(Nat.sub(b, a), Nat.mul(4n, U32.to_nat(count))), Equal.sym(Bool, Nat.is_lt(Nat.sub(b, a), Nat.mul(4n, U32.to_nat(count))), False{}, e), {==}),
        ih(D.T4{}, S.CVecVar{elem, count, depth}, fr, a, b, count, V.r32(t, d, a), h))

def t0_vecvar(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +elem: S.CS, +count: U32, +depth: U32, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CVecVar{elem, count, depth}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CVecVar{elem, count, depth}, fr, a, b, c, v):
  vecvar_lt(t, d, n, p, elem, count, depth, fr, a, b, ih, Nat.is_lt(Nat.sub(b, a), Nat.mul(4n, U32.to_nat(count))), {==},
    F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(Nat.is_lt(Nat.sub(b, a), Nat.mul(4n, U32.to_nat(count))), 6, 4), S.CVecVar{elem, count, depth}, fr, a, b, count, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
      C.rd32(D.bf(t, n), a), (D.bf(t, n), V.r32(t, d, a)), Rd.read32_any(d, t, n, U32.from_nat(a), hd, pf), h))

# (Is(A) & (M & FD(p)))  ->  (Is(A) & M) & FD(1 + p)
def listvar_head(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, +a: Nat, +b: Nat, +lim: U32, +big: Bool, +elem: S.CS, +v: U32,
    pr: V.Is(V.list_head_ok(a, b, v, lim, big)) & (V.M(t, d, p, V.VEl{elem, 0n, Nat.div(U32.to_nat(v), 4n), a, b}) & D.FD(t, d, p, fr)))
    -> (V.Is(V.list_head_ok(a, b, v, lim, big)) & V.M(t, d, p, V.VEl{elem, 0n, Nat.div(U32.to_nat(v), 4n), a, b})) & D.FD(t, d, 1n+p, fr):
  (x, r) = pr
  (m, f) = r
  ((x, m), DM.fd_mono(t, d, p, fr, f))

def listvar_empty(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32,
    ih: D.IH(t, d, n, p), z: Bool,
    h: {C.run(p, C.usel(z, 5, 4), S.CListVar{elem, lim, big, depth}, fr, a, b, c, (D.bf(t, n), V.r32(t, d, a))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(z, Unit, V.Is(V.list_head_ok(a, b, V.r32(t, d, a), lim, big)) & V.M(t, d, p, V.VEl{elem, 0n, Nat.div(U32.to_nat(V.r32(t, d, a)), 4n), a, b})) & D.FD(t, d, 1n+p, fr):
  match z:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, V.r32(t, d, a), h)))
    case False{}: listvar_head(t, d, p, fr, a, b, lim, big, elem, V.r32(t, d, a), ih(D.T4{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, V.r32(t, d, a), h))

def t0_listvar(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, v):
  listvar_empty(t, d, n, p, elem, lim, big, depth, fr, a, b, c, ih, Nat.is_eq(Nat.sub(b, a), 0n),
    F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(Nat.is_eq(Nat.sub(b, a), 0n), 5, 4), S.CListVar{elem, lim, big, depth}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
      C.rd32(D.bf(t, n), a), (D.bf(t, n), V.r32(t, d, a)), Rd.read32_any(d, t, n, U32.from_nat(a), hd, pf), h))

# FD(p, FVarList) as the child obligations, lifted.
def vel_frame(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +elem: S.CS, +i: Nat, +m: Nat, +base: Nat, +endp: Nat, +fr: C.Frame,
    x: D.FD(t, d, p, C.FVarList{elem, i, m, base, endp, fr})) -> V.M(t, d, 1n+p, V.VEl{elem, i, m, base, endp}) & D.FD(t, d, 1n+p, fr):
  (y, f) = x
  (G.m_mono(t, d, p, V.VEl{elem, i, m, base, endp}, y), DM.fd_mono(t, d, p, fr, f))

# A & (B & FD(p))  ->  (A & B) & FD(1 + p)
def regroup(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, -A: Type, -Bt: Type, pr: A & (Bt & D.FD(t, d, p, fr))) -> (A & Bt) & D.FD(t, d, 1n+p, fr):
  (x, r) = pr
  (y, f) = r
  ((x, y), DM.fd_mono(t, d, p, fr, f))

# ---- tag 4: the first offset v of a variable-size sequence ------------------------

def vecvar_head(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +depth: U32, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), ok: Bool, e: {Nat.is_eq(U32.to_nat(v), Nat.mul(4n, U32.to_nat(count))) == ok : Bool},
    h: {C.run(p, C.usel(ok, 5, 6), S.CVecVar{elem, count, depth}, C.FVarList{elem, 0n, U32.to_nat(count), a, b, fr}, a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T4{}, S.CVecVar{elem, count, depth}, fr, a, b, c, v):
  match ok:
    case True{}: (e, vel_frame(t, d, p, elem, 0n, U32.to_nat(count), a, b, fr, ih(D.T5{}, S.CVecVar{elem, count, depth}, C.FVarList{elem, 0n, U32.to_nat(count), a, b, fr}, a, b, c, 0, h)))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CVecVar{elem, count, depth}, fr, a, b, c, v), ih(D.T6{}, S.CVecVar{elem, count, depth}, C.FVarList{elem, 0n, U32.to_nat(count), a, b, fr}, a, b, c, 0, h))

def listvar_first(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), ok: Bool, e: {V.list_head_ok(a, b, v, lim, big) == ok : Bool},
    h: {C.run(p, C.usel(ok, 5, 6), S.CListVar{elem, lim, big, depth}, C.FVarList{elem, 0n, Nat.div(U32.to_nat(v), 4n), a, b, fr}, a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T4{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, v):
  match ok:
    case True{}: (e, vel_frame(t, d, p, elem, 0n, Nat.div(U32.to_nat(v), 4n), a, b, fr, ih(D.T5{}, S.CListVar{elem, lim, big, depth}, C.FVarList{elem, 0n, Nat.div(U32.to_nat(v), 4n), a, b, fr}, a, b, c, 0, h)))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, v), ih(D.T6{}, S.CListVar{elem, lim, big, depth}, C.FVarList{elem, 0n, Nat.div(U32.to_nat(v), 4n), a, b, fr}, a, b, c, 0, h))

def sound_t4(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T4{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T4{}, s, fr, a, b, c, v):
  match s:
    case S.CVecVar{+elem, +count, +depth}: vecvar_head(t, d, n, p, elem, count, depth, fr, a, b, c, v, ih, Nat.is_eq(U32.to_nat(v), Nat.mul(4n, U32.to_nat(count))), {==}, h)
    case S.CListVar{+elem, +lim, +big, +depth}: listvar_first(t, d, n, p, elem, lim, big, depth, fr, a, b, c, v, ih, V.list_head_ok(a, b, v, lim, big), {==}, h)
    case S.CBool{}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CBool{}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CUint{x0}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CUint{x0}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CBytes{x0, x1}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CBytes{x0, x1}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CByteList{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CByteList{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CBitVec{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CBitVec{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CBitList{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CBitList{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CVec{x0, x1, x2, x3, x4, x5}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CVec{x0, x1, x2, x3, x4, x5}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CList{x0, x1, x2, x3, x4, x5, x6}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CList{x0, x1, x2, x3, x4, x5, x6}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CPCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CPCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CUnion{x0, x1}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CUnion{x0, x1}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CNull{}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CNull{}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CFLeaf{x0, x1, x2, x3}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CFLeaf{x0, x1, x2, x3}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CFNode{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CFNode{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CFNone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CFNone{}, fr, a, b, c, v), L.no_run(t, n, h))

# ---- tag 5: pop the frame ----------------------------------------------------------

def rep_pop(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +elem: S.CS, +left: Nat, +stride: Nat, +off: Nat, +up: C.Frame,
    +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), done: Bool, e: {Nat.is_eq(left, 0n) == done : Bool},
    h: {C.run(p, C.usel(done, 5, 0), elem, C.fsel(done, up, C.FRep{elem, Nat.sub(left, 1n), stride, Nat.add(off, stride), up}), off, Nat.add(off, stride), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T5{}, s, C.FRep{elem, left, stride, off, up}, a, b, c, v):
  match done:
    case True{}:
      %Equal.sym(Bool, Nat.is_eq(left, 0n), True{}, e) : {V.If(_, Unit, V.M(t, d, p, V.Node{elem, off, Nat.add(off, stride)}) & V.M(t, d, p, V.Rep{elem, Nat.sub(left, 1n), Nat.add(off, stride), stride})) & D.FD(t, d, 1n+p, up) : Type}
      (Unit{}, DM.fd_mono(t, d, p, up, ih(D.T5{}, elem, up, off, Nat.add(off, stride), c, 0, h)))
    case False{}:
      %Equal.sym(Bool, Nat.is_eq(left, 0n), False{}, e) : {V.If(_, Unit, V.M(t, d, p, V.Node{elem, off, Nat.add(off, stride)}) & V.M(t, d, p, V.Rep{elem, Nat.sub(left, 1n), Nat.add(off, stride), stride})) & D.FD(t, d, 1n+p, up) : Type}
      node_rest(t, d, p, V.Node{elem, off, Nat.add(off, stride)}, V.Rep{elem, Nat.sub(left, 1n), Nat.add(off, stride), stride}, up,
        ih(D.T0{}, elem, C.FRep{elem, Nat.sub(left, 1n), stride, Nat.add(off, stride), up}, off, Nat.add(off, stride), c, 0, h))

def vel_pop(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +elem: S.CS, +i: Nat, +m: Nat, +base: Nat, +endp: Nat, +up: C.Frame,
    +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), done: Bool, e: {Nat.is_eq(i, m) == done : Bool},
    h: {C.run(p, C.usel(done, 5, 11), elem, C.fsel(done, up, C.FVarList{elem, i, m, base, endp, up}), a, b, c, (D.bf(t, n), V.r32(t, d, Nat.add(base, Nat.mul(4n, i))))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T5{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v):
  match done:
    case True{}:
      %Equal.sym(Bool, Nat.is_eq(i, m), True{}, e) : {V.If(_, Unit, V.Is(C.bsel(Nat.is_le(V.el_at(t, d, base, i), endp), Nat.is_le(base, V.el_at(t, d, base, i)), False{})) & V.VarStep(Nat.is_eq(Nat.add(i, 1n), m), V.el_at(t, d, base, i), V.el_at(t, d, base, Nat.add(i, 1n)), endp, V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), endp}), V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), V.el_at(t, d, base, Nat.add(i, 1n))}), V.M(t, d, p, V.VEl{elem, Nat.add(i, 1n), m, base, endp}))) & D.FD(t, d, 1n+p, up) : Type}
      (Unit{}, DM.fd_mono(t, d, p, up, ih(D.T5{}, elem, up, a, b, c, V.r32(t, d, Nat.add(base, Nat.mul(4n, i))), h)))
    case False{}:
      %Equal.sym(Bool, Nat.is_eq(i, m), False{}, e) : {V.If(_, Unit, V.Is(C.bsel(Nat.is_le(V.el_at(t, d, base, i), endp), Nat.is_le(base, V.el_at(t, d, base, i)), False{})) & V.VarStep(Nat.is_eq(Nat.add(i, 1n), m), V.el_at(t, d, base, i), V.el_at(t, d, base, Nat.add(i, 1n)), endp, V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), endp}), V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), V.el_at(t, d, base, Nat.add(i, 1n))}), V.M(t, d, p, V.VEl{elem, Nat.add(i, 1n), m, base, endp}))) & D.FD(t, d, 1n+p, up) : Type}
      regroup(t, d, p, up, V.Is(C.bsel(Nat.is_le(V.el_at(t, d, base, i), endp), Nat.is_le(base, V.el_at(t, d, base, i)), False{})), V.VarStep(Nat.is_eq(Nat.add(i, 1n), m), V.el_at(t, d, base, i), V.el_at(t, d, base, Nat.add(i, 1n)), endp, V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), endp}), V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), V.el_at(t, d, base, Nat.add(i, 1n))}), V.M(t, d, p, V.VEl{elem, Nat.add(i, 1n), m, base, endp})),
        ih(D.T11{}, elem, C.FVarList{elem, i, m, base, endp, up}, a, b, c, V.r32(t, d, Nat.add(base, Nat.mul(4n, i))), h))

def sound_t5(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T5{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T5{}, s, fr, a, b, c, v):
  match fr:
    case C.FDone{}: Unit{}
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
      DM.fd_mono(t, d, p, C.FCont{fields, i, cnt, base, endp, fp, pend, start, has, up}, ih(D.T8{}, s, C.FCont{fields, i, cnt, base, endp, fp, pend, start, has, up}, a, b, c, 0, h))
    case C.FRep{+elem, +left, +stride, +off, +up}:
      rep_pop(t, d, n, p, s, elem, left, stride, off, up, a, b, c, v, ih, Nat.is_eq(left, 0n), {==}, h)
    case C.FVarList{+elem, +i, +m, +base, +endp, +up}:
      vel_pop(t, d, n, p, s, elem, i, m, base, endp, up, a, b, c, v, ih, Nat.is_eq(i, m), {==},
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(Nat.is_eq(i, m), 5, 11), elem, C.fsel(Nat.is_eq(i, m), up, C.FVarList{elem, i, m, base, endp, up}), a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
          C.rd32(D.bf(t, n), Nat.add(base, Nat.mul(4n, i))), (D.bf(t, n), V.r32(t, d, Nat.add(base, Nat.mul(4n, i)))), Rd.read32_any(d, t, n, U32.from_nat(Nat.add(base, Nat.mul(4n, i))), hd, pf), h))

def end_parts(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +elem: S.CS, +i: Nat, +m: Nat, +base: Nat, +endp: Nat, +up: C.Frame, +a: Nat, +cend: Nat,
    e: V.Is(C.bsel(Nat.is_le(a, cend), Nat.is_le(cend, endp), False{})),
    pr: V.M(t, d, p, V.Node{elem, a, cend}) & D.FD(t, d, p, C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}))
    -> V.Is(C.bsel(Nat.is_le(a, cend), Nat.is_le(cend, endp), False{})) & V.M(t, d, 1n+p, V.Node{elem, a, cend}) & V.M(t, d, 1n+p, V.VEl{elem, Nat.add(i, 1n), m, base, endp}) & D.FD(t, d, 1n+p, up):
  (x, r) = pr
  (y, f) = r
  (e, (G.m_mono(t, d, p, V.Node{elem, a, cend}, x), (G.m_mono(t, d, p, V.VEl{elem, Nat.add(i, 1n), m, base, endp}, y), DM.fd_mono(t, d, p, up, f))))

# ---- tag 11: the offset v of element i ----------------------------------------------

# Last element: it ends at the window's end.
def el_last(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +elem: S.CS, +i: Nat, +m: Nat, +base: Nat, +endp: Nat, +up: C.Frame, +child: Nat,
    pr: V.M(t, d, p, V.Node{elem, child, endp}) & D.FD(t, d, p, C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}))
    -> (V.M(t, d, 1n+p, V.Node{elem, child, endp}) & V.M(t, d, 1n+p, V.VEl{elem, Nat.add(i, 1n), m, base, endp})) & D.FD(t, d, 1n+p, up):
  (x, r) = pr
  (y, f) = r
  ((G.m_mono(t, d, p, V.Node{elem, child, endp}, x), G.m_mono(t, d, p, V.VEl{elem, Nat.add(i, 1n), m, base, endp}, y)), DM.fd_mono(t, d, p, up, f))

# Not the last: tag 12 has checked the next offset.
def el_mid(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +elem: S.CS, +i: Nat, +m: Nat, +base: Nat, +endp: Nat, +up: C.Frame, +child: Nat, +cend: Nat,
    pr: V.Is(C.bsel(Nat.is_le(child, cend), Nat.is_le(cend, endp), False{})) & V.M(t, d, p, V.Node{elem, child, cend}) & V.M(t, d, p, V.VEl{elem, Nat.add(i, 1n), m, base, endp}) & D.FD(t, d, p, up))
    -> (V.Is(C.bsel(Nat.is_le(child, cend), Nat.is_le(cend, endp), False{})) & V.M(t, d, 1n+p, V.Node{elem, child, cend}) & V.M(t, d, 1n+p, V.VEl{elem, Nat.add(i, 1n), m, base, endp})) & D.FD(t, d, 1n+p, up):
  (o, r1) = pr
  (x, r2) = r1
  (y, f) = r2
  ((o, (G.m_mono(t, d, p, V.Node{elem, child, cend}, x), G.m_mono(t, d, p, V.VEl{elem, Nat.add(i, 1n), m, base, endp}, y))), DM.fd_mono(t, d, p, up, f))

def el_step(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +i: Nat, +m: Nat, +base: Nat, +endp: Nat, +up: C.Frame, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), last: Bool,
    h: {C.run(p, C.usel(last, 0, 12), elem, C.fsel(last, C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}, C.FVarList{elem, i, m, base, endp, up}),
          Nat.add(base, U32.to_nat(v)), endp, c, (D.bf(t, n), V.r32(t, d, Nat.add(base, Nat.mul(4n, Nat.add(i, 1n)))))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.VarStep(last, Nat.add(base, U32.to_nat(v)), V.el_at(t, d, base, Nat.add(i, 1n)), endp,
         V.M(t, d, 1n+p, V.Node{elem, Nat.add(base, U32.to_nat(v)), endp}), V.M(t, d, 1n+p, V.Node{elem, Nat.add(base, U32.to_nat(v)), V.el_at(t, d, base, Nat.add(i, 1n))}),
         V.M(t, d, 1n+p, V.VEl{elem, Nat.add(i, 1n), m, base, endp})) & D.FD(t, d, 1n+p, up):
  match last:
    case True{}: el_last(t, d, p, elem, i, m, base, endp, up, Nat.add(base, U32.to_nat(v)),
      ih(D.T0{}, elem, C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}, Nat.add(base, U32.to_nat(v)), endp, c, V.r32(t, d, Nat.add(base, Nat.mul(4n, Nat.add(i, 1n)))), h))
    case False{}: el_mid(t, d, p, elem, i, m, base, endp, up, Nat.add(base, U32.to_nat(v)), V.el_at(t, d, base, Nat.add(i, 1n)),
      ih(D.T12{}, elem, C.FVarList{elem, i, m, base, endp, up}, Nat.add(base, U32.to_nat(v)), endp, c, V.r32(t, d, Nat.add(base, Nat.mul(4n, Nat.add(i, 1n)))), h))

def el_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +elem: S.CS, +i: Nat, +m: Nat, +base: Nat, +endp: Nat, +up: C.Frame,
    +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), ok: Bool, e: {C.bsel(Nat.is_le(Nat.add(base, U32.to_nat(v)), endp), Nat.is_le(base, Nat.add(base, U32.to_nat(v))), False{}) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(Nat.is_eq(Nat.add(i, 1n), m), 0, 12), 6), elem, C.fsel(Nat.is_eq(Nat.add(i, 1n), m), C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}, C.FVarList{elem, i, m, base, endp, up}),
          Nat.add(base, U32.to_nat(v)), endp, c, (D.bf(t, n), V.r32(t, d, Nat.add(base, Nat.mul(4n, Nat.add(i, 1n)))))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T11{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v):
  match ok:
    case True{}:
      (e, el_step(t, d, n, p, elem, i, m, base, endp, up, c, v, ih, Nat.is_eq(Nat.add(i, 1n), m), h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T11{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v),
      ih(D.T6{}, elem, C.fsel(Nat.is_eq(Nat.add(i, 1n), m), C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}, C.FVarList{elem, i, m, base, endp, up}),
        Nat.add(base, U32.to_nat(v)), endp, c, V.r32(t, d, Nat.add(base, Nat.mul(4n, Nat.add(i, 1n)))), h))

def sound_t11(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T11{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T11{}, s, fr, a, b, c, v):
  match fr:
    case C.FVarList{+elem, +i, +m, +base, +endp, +up}:
      el_ok(t, d, n, p, s, elem, i, m, base, endp, up, a, b, c, v, ih, C.bsel(Nat.is_le(Nat.add(base, U32.to_nat(v)), endp), Nat.is_le(base, Nat.add(base, U32.to_nat(v))), False{}), {==},
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(C.bsel(Nat.is_le(Nat.add(base, U32.to_nat(v)), endp), Nat.is_le(base, Nat.add(base, U32.to_nat(v))), False{}), C.usel(Nat.is_eq(Nat.add(i, 1n), m), 0, 12), 6), elem,
              C.fsel(Nat.is_eq(Nat.add(i, 1n), m), C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}, C.FVarList{elem, i, m, base, endp, up}), Nat.add(base, U32.to_nat(v)), endp, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
          C.rd32(D.bf(t, n), Nat.add(base, Nat.mul(4n, Nat.add(i, 1n)))), (D.bf(t, n), V.r32(t, d, Nat.add(base, Nat.mul(4n, Nat.add(i, 1n))))), Rd.read32_any(d, t, n, U32.from_nat(Nat.add(base, Nat.mul(4n, Nat.add(i, 1n)))), hd, pf), h))
    case C.FDone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T11{}, s, C.FDone{}, a, b, c, v), L.no_run(t, n, h))
    case C.FCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}: Empty.absurd(D.Den(t, d, 1n+p, D.T11{}, s, C.FCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}, a, b, c, v), L.no_run(t, n, h))
    case C.FRep{x0, x1, x2, x3, x4}: Empty.absurd(D.Den(t, d, 1n+p, D.T11{}, s, C.FRep{x0, x1, x2, x3, x4}, a, b, c, v), L.no_run(t, n, h))

# ---- tag 12: the offset v where element i, starting at a, ends --------------------------

def end_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +elem: S.CS, +i: Nat, +m: Nat, +base: Nat, +endp: Nat, +up: C.Frame,
    +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), ok: Bool, e: {C.bsel(Nat.is_le(a, Nat.add(base, U32.to_nat(v))), Nat.is_le(Nat.add(base, U32.to_nat(v)), endp), False{}) == ok : Bool},
    h: {C.run(p, C.usel(ok, 0, 6), elem, C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}, a, Nat.add(base, U32.to_nat(v)), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T12{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v):
  match ok:
    case True{}: end_parts(t, d, p, elem, i, m, base, endp, up, a, Nat.add(base, U32.to_nat(v)), e,
      ih(D.T0{}, elem, C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}, a, Nat.add(base, U32.to_nat(v)), c, 0, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T12{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v),
      ih(D.T6{}, elem, C.FVarList{elem, Nat.add(i, 1n), m, base, endp, up}, a, Nat.add(base, U32.to_nat(v)), c, 0, h))

def sound_t12(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T12{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T12{}, s, fr, a, b, c, v):
  match fr:
    case C.FVarList{+elem, +i, +m, +base, +endp, +up}:
      end_ok(t, d, n, p, s, elem, i, m, base, endp, up, a, b, c, v, ih, C.bsel(Nat.is_le(a, Nat.add(base, U32.to_nat(v))), Nat.is_le(Nat.add(base, U32.to_nat(v)), endp), False{}), {==}, h)
    case C.FDone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T12{}, s, C.FDone{}, a, b, c, v), L.no_run(t, n, h))
    case C.FCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}: Empty.absurd(D.Den(t, d, 1n+p, D.T12{}, s, C.FCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}, a, b, c, v), L.no_run(t, n, h))
    case C.FRep{x0, x1, x2, x3, x4}: Empty.absurd(D.Den(t, d, 1n+p, D.T12{}, s, C.FRep{x0, x1, x2, x3, x4}, a, b, c, v), L.no_run(t, n, h))
