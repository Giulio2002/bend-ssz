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

# ---- tag 0: fixed-stride vector -----------------------------------------------

def vec_skip(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p), skip: Bool,
    h: {C.run(p, C.usel(skip, 5, 0), C.ssel(skip, S.CVec{elem, count, stride, depth, basic, plain}, elem),
          C.fsel(skip, fr, C.FRep{elem, (count - 1 : U32), stride, (a + stride : U32), fr}), a, (a + stride : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(skip, Unit, V.M(t, d, p, V.Node{elem, a, (a + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (count - 1 : U32), (a + stride : U32), stride})) & D.FD(t, d, 1n+p, fr):
  match skip:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, (a + stride : U32), c, 0, h)))
    case False{}:
      node_rest(t, d, p, V.Node{elem, a, (a + stride : U32)}, V.Rep{elem, (count - 1 : U32), (a + stride : U32), stride}, fr,
        ih(D.T0{}, elem, C.FRep{elem, (count - 1 : U32), stride, (a + stride : U32), fr}, a, (a + stride : U32), c, 0, h))

def vec_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p), ok: Bool, e: {U32.is_eq((b - a : U32), (count * stride : U32)) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(Bool.or(U32.is_eq(count, 0), plain), 5, 0), 6), C.ssel(Bool.or(U32.is_eq(count, 0), plain), S.CVec{elem, count, stride, depth, basic, plain}, elem),
          C.fsel(Bool.or(U32.is_eq(count, 0), plain), fr, C.FRep{elem, (count - 1 : U32), stride, (a + stride : U32), fr}), a, (a + stride : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, b, c, 0):
  match ok:
    case True{}:
      L.reassoc(V.Is(U32.is_eq((b - a : U32), (count * stride : U32))),
        V.If(Bool.or(U32.is_eq(count, 0), plain), Unit, V.M(t, d, p, V.Node{elem, a, (a + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (count - 1 : U32), (a + stride : U32), stride})),
        D.FD(t, d, 1n+p, fr), e,
        vec_skip(t, d, n, p, elem, count, stride, depth, basic, plain, fr, a, b, c, ih, Bool.or(U32.is_eq(count, 0), plain), h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, b, c, 0),
      ih(D.T6{}, C.ssel(Bool.or(U32.is_eq(count, 0), plain), S.CVec{elem, count, stride, depth, basic, plain}, elem),
        C.fsel(Bool.or(U32.is_eq(count, 0), plain), fr, C.FRep{elem, (count - 1 : U32), stride, (a + stride : U32), fr}), a, (a + stride : U32), c, 0, h))

def t0_vec(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CVec{elem, count, stride, depth, basic, plain}, fr, a, b, c, v):
  vec_ok(t, d, n, p, elem, count, stride, depth, basic, plain, fr, a, b, c, ih, U32.is_eq((b - a : U32), (count * stride : U32)), {==}, h)

# ---- tag 0: fixed-stride list --------------------------------------------------

def list_skip(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +sch: S.CS, +elem: S.CS, +count: U32, +stride: U32,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p), skip: Bool,
    h: {C.run(p, C.usel(skip, 5, 0), C.ssel(skip, sch, elem),
          C.fsel(skip, fr, C.FRep{elem, (count - 1 : U32), stride, (a + stride : U32), fr}), a, (a + stride : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(skip, Unit, V.M(t, d, p, V.Node{elem, a, (a + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (count - 1 : U32), (a + stride : U32), stride})) & D.FD(t, d, 1n+p, fr):
  match skip:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, sch, fr, a, (a + stride : U32), c, 0, h)))
    case False{}:
      node_rest(t, d, p, V.Node{elem, a, (a + stride : U32)}, V.Rep{elem, (count - 1 : U32), (a + stride : U32), stride}, fr,
        ih(D.T0{}, elem, C.FRep{elem, (count - 1 : U32), stride, (a + stride : U32), fr}, a, (a + stride : U32), c, 0, h))

def list_w(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p), w: Bool, ew: {S.within(U32.div((b - a : U32), stride), lim, big) == w : Bool},
    h: {C.run(p, C.usel(w, C.usel(Bool.or(U32.is_eq((b - a : U32), 0), plain), 5, 0), 6), C.ssel(Bool.or(U32.is_eq((b - a : U32), 0), plain), S.CList{elem, lim, big, stride, depth, basic, plain}, elem),
          C.fsel(Bool.or(U32.is_eq((b - a : U32), 0), plain), fr, C.FRep{elem, (U32.div((b - a : U32), stride) - 1 : U32), stride, (a + stride : U32), fr}), a, (a + stride : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> (V.Is(S.within(U32.div((b - a : U32), stride), lim, big)) &
        V.If(Bool.or(U32.is_eq((b - a : U32), 0), plain), Unit, V.M(t, d, p, V.Node{elem, a, (a + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (U32.div((b - a : U32), stride) - 1 : U32), (a + stride : U32), stride}))) &
       D.FD(t, d, 1n+p, fr):
  match w:
    case True{}:
      L.reassoc(V.Is(S.within(U32.div((b - a : U32), stride), lim, big)),
        V.If(Bool.or(U32.is_eq((b - a : U32), 0), plain), Unit, V.M(t, d, p, V.Node{elem, a, (a + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (U32.div((b - a : U32), stride) - 1 : U32), (a + stride : U32), stride})),
        D.FD(t, d, 1n+p, fr), ew,
        list_skip(t, d, n, p, S.CList{elem, lim, big, stride, depth, basic, plain}, elem, U32.div((b - a : U32), stride), stride, fr, a, b, c, ih, Bool.or(U32.is_eq((b - a : U32), 0), plain), h))
    case False{}: Empty.absurd(
      (V.Is(S.within(U32.div((b - a : U32), stride), lim, big)) & V.If(Bool.or(U32.is_eq((b - a : U32), 0), plain), Unit, V.M(t, d, p, V.Node{elem, a, (a + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (U32.div((b - a : U32), stride) - 1 : U32), (a + stride : U32), stride}))) & D.FD(t, d, 1n+p, fr),
      ih(D.T6{}, C.ssel(Bool.or(U32.is_eq((b - a : U32), 0), plain), S.CList{elem, lim, big, stride, depth, basic, plain}, elem),
        C.fsel(Bool.or(U32.is_eq((b - a : U32), 0), plain), fr, C.FRep{elem, (U32.div((b - a : U32), stride) - 1 : U32), stride, (a + stride : U32), fr}), a, (a + stride : U32), c, 0, h))

def list_ex(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, ih: D.IH(t, d, n, p), ex: Bool, e: {U32.is_eq((b - a : U32), (U32.div((b - a : U32), stride) * stride : U32)) == ex : Bool},
    h: {C.run(p, C.usel(C.bsel(ex, S.within(U32.div((b - a : U32), stride), lim, big), False{}), C.usel(Bool.or(U32.is_eq((b - a : U32), 0), plain), 5, 0), 6), C.ssel(Bool.or(U32.is_eq((b - a : U32), 0), plain), S.CList{elem, lim, big, stride, depth, basic, plain}, elem),
          C.fsel(Bool.or(U32.is_eq((b - a : U32), 0), plain), fr, C.FRep{elem, (U32.div((b - a : U32), stride) - 1 : U32), stride, (a + stride : U32), fr}), a, (a + stride : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CList{elem, lim, big, stride, depth, basic, plain}, fr, a, b, c, 0):
  match ex:
    case True{}:
      L.reassoc(V.Is(U32.is_eq((b - a : U32), (U32.div((b - a : U32), stride) * stride : U32))),
        V.Is(S.within(U32.div((b - a : U32), stride), lim, big)) &
        V.If(Bool.or(U32.is_eq((b - a : U32), 0), plain), Unit, V.M(t, d, p, V.Node{elem, a, (a + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (U32.div((b - a : U32), stride) - 1 : U32), (a + stride : U32), stride})),
        D.FD(t, d, 1n+p, fr), e,
        list_w(t, d, n, p, elem, lim, big, stride, depth, basic, plain, fr, a, b, c, ih, S.within(U32.div((b - a : U32), stride), lim, big), {==}, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CList{elem, lim, big, stride, depth, basic, plain}, fr, a, b, c, 0),
      ih(D.T6{}, C.ssel(Bool.or(U32.is_eq((b - a : U32), 0), plain), S.CList{elem, lim, big, stride, depth, basic, plain}, elem),
        C.fsel(Bool.or(U32.is_eq((b - a : U32), 0), plain), fr, C.FRep{elem, (U32.div((b - a : U32), stride) - 1 : U32), stride, (a + stride : U32), fr}), a, (a + stride : U32), c, 0, h))

def t0_list(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +stride: U32, +depth: U32, +basic: Bool, +plain: Bool,
    +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CList{elem, lim, big, stride, depth, basic, plain}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CList{elem, lim, big, stride, depth, basic, plain}, fr, a, b, c, v):
  list_ex(t, d, n, p, elem, lim, big, stride, depth, basic, plain, fr, a, b, c, ih, U32.is_eq((b - a : U32), (U32.div((b - a : U32), stride) * stride : U32)), {==}, h)

# ---- tag 0: variable-size vector and list; tag 4: the first offset --------------

# Is(A) & (Is(B) & M) & FD at p  from  A and (Is(B) & (M & FD(p)))
def lead3(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, -A: Type, -Bt: Type, j: V.Job, ea: A,
    pr: Bt & (V.M(t, d, p, j) & D.FD(t, d, p, fr))) -> (A & (Bt & V.M(t, d, p, j))) & D.FD(t, d, 1n+p, fr):
  (x, r) = pr
  (m, f) = r
  ((ea, (x, m)), DM.fd_mono(t, d, p, fr, f))

def vecvar_lt(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +depth: U32, +fr: C.Frame, +a: U32, +b: U32,
    ih: D.IH(t, d, n, p), lt: Bool, e: {U32.is_lt((b - a : U32), (4 * count : U32)) == lt : Bool},
    h: {C.run(p, C.usel(lt, 6, 4), S.CVecVar{elem, count, depth}, fr, a, b, count, (D.bf(t, n), Rd.r32(t, d, a))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, S.CVecVar{elem, count, depth}, fr, a, b, 0, 0):
  match lt:
    case True{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CVecVar{elem, count, depth}, fr, a, b, 0, 0), ih(D.T6{}, S.CVecVar{elem, count, depth}, fr, a, b, count, Rd.r32(t, d, a), h))
    case False{}:
      lead3(t, d, p, fr, V.Is(Bool.not(U32.is_lt((b - a : U32), (4 * count : U32)))), V.Is(U32.is_eq(Rd.r32(t, d, a), (4 * count : U32))), V.VEl{elem, 0, count, a, b},
        F.logic__subst(Bool, z => V.Is(Bool.not(z)), False{}, U32.is_lt((b - a : U32), (4 * count : U32)), Equal.sym(Bool, U32.is_lt((b - a : U32), (4 * count : U32)), False{}, e), {==}),
        ih(D.T4{}, S.CVecVar{elem, count, depth}, fr, a, b, count, Rd.r32(t, d, a), h))

def t0_vecvar(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +elem: S.CS, +count: U32, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CVecVar{elem, count, depth}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CVecVar{elem, count, depth}, fr, a, b, c, v):
  vecvar_lt(t, d, n, p, elem, count, depth, fr, a, b, ih, U32.is_lt((b - a : U32), (4 * count : U32)), {==},
    F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_lt((b - a : U32), (4 * count : U32)), 6, 4), S.CVecVar{elem, count, depth}, fr, a, b, count, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
      B.read32(D.bf(t, n), a), (D.bf(t, n), Rd.r32(t, d, a)), Rd.read32_any(d, t, n, a, hd, pf), h))

# (Is(A) & (M & FD(p)))  ->  (Is(A) & M) & FD(1 + p)
def listvar_head(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, +a: U32, +b: U32, +lim: U32, +big: Bool, +elem: S.CS, +v: U32,
    pr: V.Is(V.list_head_ok(a, b, v, lim, big)) & (V.M(t, d, p, V.VEl{elem, 0, U32.shrn(v, 2n), a, b}) & D.FD(t, d, p, fr)))
    -> (V.Is(V.list_head_ok(a, b, v, lim, big)) & V.M(t, d, p, V.VEl{elem, 0, U32.shrn(v, 2n), a, b})) & D.FD(t, d, 1n+p, fr):
  (x, r) = pr
  (m, f) = r
  ((x, m), DM.fd_mono(t, d, p, fr, f))

def listvar_empty(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32,
    ih: D.IH(t, d, n, p), z: Bool,
    h: {C.run(p, C.usel(z, 5, 4), S.CListVar{elem, lim, big, depth}, fr, a, b, c, (D.bf(t, n), Rd.r32(t, d, a))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.If(z, Unit, V.Is(V.list_head_ok(a, b, Rd.r32(t, d, a), lim, big)) & V.M(t, d, p, V.VEl{elem, 0, U32.shrn(Rd.r32(t, d, a), 2n), a, b})) & D.FD(t, d, 1n+p, fr):
  match z:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, Rd.r32(t, d, a), h)))
    case False{}: listvar_head(t, d, p, fr, a, b, lim, big, elem, Rd.r32(t, d, a), ih(D.T4{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, Rd.r32(t, d, a), h))

def t0_listvar(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, v):
  listvar_empty(t, d, n, p, elem, lim, big, depth, fr, a, b, c, ih, U32.is_eq((b - a : U32), 0),
    F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_eq((b - a : U32), 0), 5, 4), S.CListVar{elem, lim, big, depth}, fr, a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
      B.read32(D.bf(t, n), a), (D.bf(t, n), Rd.r32(t, d, a)), Rd.read32_any(d, t, n, a, hd, pf), h))

# FD(p, FVarList) as the child obligations, lifted.
def vel_frame(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +elem: S.CS, +i: U32, +m: U32, +base: U32, +endp: U32, +fr: C.Frame,
    x: D.FD(t, d, p, C.FVarList{elem, i, m, base, endp, fr})) -> V.M(t, d, 1n+p, V.VEl{elem, i, m, base, endp}) & D.FD(t, d, 1n+p, fr):
  (y, f) = x
  (G.m_mono(t, d, p, V.VEl{elem, i, m, base, endp}, y), DM.fd_mono(t, d, p, fr, f))

# A & (B & FD(p))  ->  (A & B) & FD(1 + p)
def regroup(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, -A: Type, -Bt: Type, pr: A & (Bt & D.FD(t, d, p, fr))) -> (A & Bt) & D.FD(t, d, 1n+p, fr):
  (x, r) = pr
  (y, f) = r
  ((x, y), DM.fd_mono(t, d, p, fr, f))

# ---- tag 4: the first offset v of a variable-size sequence ------------------------

def vecvar_head(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +count: U32, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), ok: Bool, e: {U32.is_eq(v, (4 * count : U32)) == ok : Bool},
    h: {C.run(p, C.usel(ok, 5, 6), S.CVecVar{elem, count, depth}, C.FVarList{elem, 0, count, a, b, fr}, a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T4{}, S.CVecVar{elem, count, depth}, fr, a, b, c, v):
  match ok:
    case True{}: (e, vel_frame(t, d, p, elem, 0, count, a, b, fr, ih(D.T5{}, S.CVecVar{elem, count, depth}, C.FVarList{elem, 0, count, a, b, fr}, a, b, c, 0, h)))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CVecVar{elem, count, depth}, fr, a, b, c, v), ih(D.T6{}, S.CVecVar{elem, count, depth}, C.FVarList{elem, 0, count, a, b, fr}, a, b, c, 0, h))

def listvar_first(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +lim: U32, +big: Bool, +depth: U32, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), ok: Bool, e: {V.list_head_ok(a, b, v, lim, big) == ok : Bool},
    h: {C.run(p, C.usel(ok, 5, 6), S.CListVar{elem, lim, big, depth}, C.FVarList{elem, 0, U32.shrn(v, 2n), a, b, fr}, a, b, c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T4{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, v):
  match ok:
    case True{}: (e, vel_frame(t, d, p, elem, 0, U32.shrn(v, 2n), a, b, fr, ih(D.T5{}, S.CListVar{elem, lim, big, depth}, C.FVarList{elem, 0, U32.shrn(v, 2n), a, b, fr}, a, b, c, 0, h)))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T4{}, S.CListVar{elem, lim, big, depth}, fr, a, b, c, v), ih(D.T6{}, S.CListVar{elem, lim, big, depth}, C.FVarList{elem, 0, U32.shrn(v, 2n), a, b, fr}, a, b, c, 0, h))

def sound_t4(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T4{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T4{}, s, fr, a, b, c, v):
  match s:
    case S.CVecVar{+elem, +count, +depth}: vecvar_head(t, d, n, p, elem, count, depth, fr, a, b, c, v, ih, U32.is_eq(v, (4 * count : U32)), {==}, h)
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

def rep_pop(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +elem: S.CS, +left: U32, +stride: U32, +off: U32, +up: C.Frame,
    +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), done: Bool, e: {U32.is_eq(left, 0) == done : Bool},
    h: {C.run(p, C.usel(done, 5, 0), elem, C.fsel(done, up, C.FRep{elem, (left - 1 : U32), stride, (off + stride : U32), up}), off, (off + stride : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T5{}, s, C.FRep{elem, left, stride, off, up}, a, b, c, v):
  match done:
    case True{}:
      %Equal.sym(Bool, U32.is_eq(left, 0), True{}, e) : {V.If(_, Unit, V.M(t, d, p, V.Node{elem, off, (off + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (left - 1 : U32), (off + stride : U32), stride})) & D.FD(t, d, 1n+p, up) : Type}
      (Unit{}, DM.fd_mono(t, d, p, up, ih(D.T5{}, elem, up, off, (off + stride : U32), c, 0, h)))
    case False{}:
      %Equal.sym(Bool, U32.is_eq(left, 0), False{}, e) : {V.If(_, Unit, V.M(t, d, p, V.Node{elem, off, (off + stride : U32)}) & V.M(t, d, p, V.Rep{elem, (left - 1 : U32), (off + stride : U32), stride})) & D.FD(t, d, 1n+p, up) : Type}
      node_rest(t, d, p, V.Node{elem, off, (off + stride : U32)}, V.Rep{elem, (left - 1 : U32), (off + stride : U32), stride}, up,
        ih(D.T0{}, elem, C.FRep{elem, (left - 1 : U32), stride, (off + stride : U32), up}, off, (off + stride : U32), c, 0, h))

def vel_pop(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +elem: S.CS, +i: U32, +m: U32, +base: U32, +endp: U32, +up: C.Frame,
    +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), done: Bool, e: {U32.is_eq(i, m) == done : Bool},
    h: {C.run(p, C.usel(done, 5, 11), elem, C.fsel(done, up, C.FVarList{elem, i, m, base, endp, up}), a, b, c, (D.bf(t, n), Rd.r32(t, d, (base + 4 * i : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T5{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v):
  match done:
    case True{}:
      %Equal.sym(Bool, U32.is_eq(i, m), True{}, e) : {V.If(_, Unit, V.Is(C.bsel(U32.is_le(V.el_at(t, d, base, i), endp), U32.is_ge(V.el_at(t, d, base, i), base), False{})) & V.VarStep(U32.is_eq((i + 1 : U32), m), V.el_at(t, d, base, i), V.el_at(t, d, base, (i + 1 : U32)), endp, V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), endp}), V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), V.el_at(t, d, base, (i + 1 : U32))}), V.M(t, d, p, V.VEl{elem, (i + 1 : U32), m, base, endp}))) & D.FD(t, d, 1n+p, up) : Type}
      (Unit{}, DM.fd_mono(t, d, p, up, ih(D.T5{}, elem, up, a, b, c, Rd.r32(t, d, (base + 4 * i : U32)), h)))
    case False{}:
      %Equal.sym(Bool, U32.is_eq(i, m), False{}, e) : {V.If(_, Unit, V.Is(C.bsel(U32.is_le(V.el_at(t, d, base, i), endp), U32.is_ge(V.el_at(t, d, base, i), base), False{})) & V.VarStep(U32.is_eq((i + 1 : U32), m), V.el_at(t, d, base, i), V.el_at(t, d, base, (i + 1 : U32)), endp, V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), endp}), V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), V.el_at(t, d, base, (i + 1 : U32))}), V.M(t, d, p, V.VEl{elem, (i + 1 : U32), m, base, endp}))) & D.FD(t, d, 1n+p, up) : Type}
      regroup(t, d, p, up, V.Is(C.bsel(U32.is_le(V.el_at(t, d, base, i), endp), U32.is_ge(V.el_at(t, d, base, i), base), False{})), V.VarStep(U32.is_eq((i + 1 : U32), m), V.el_at(t, d, base, i), V.el_at(t, d, base, (i + 1 : U32)), endp, V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), endp}), V.M(t, d, p, V.Node{elem, V.el_at(t, d, base, i), V.el_at(t, d, base, (i + 1 : U32))}), V.M(t, d, p, V.VEl{elem, (i + 1 : U32), m, base, endp})),
        ih(D.T11{}, elem, C.FVarList{elem, i, m, base, endp, up}, a, b, c, Rd.r32(t, d, (base + 4 * i : U32)), h))

def sound_t5(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T5{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T5{}, s, fr, a, b, c, v):
  match fr:
    case C.FDone{}: Unit{}
    case C.FCont{+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up}:
      DM.fd_mono(t, d, p, C.FCont{fields, i, cnt, base, endp, fp, pend, start, has, up}, ih(D.T8{}, s, C.FCont{fields, i, cnt, base, endp, fp, pend, start, has, up}, a, b, c, 0, h))
    case C.FRep{+elem, +left, +stride, +off, +up}:
      rep_pop(t, d, n, p, s, elem, left, stride, off, up, a, b, c, v, ih, U32.is_eq(left, 0), {==}, h)
    case C.FVarList{+elem, +i, +m, +base, +endp, +up}:
      vel_pop(t, d, n, p, s, elem, i, m, base, endp, up, a, b, c, v, ih, U32.is_eq(i, m), {==},
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_eq(i, m), 5, 11), elem, C.fsel(U32.is_eq(i, m), up, C.FVarList{elem, i, m, base, endp, up}), a, b, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
          B.read32(D.bf(t, n), (base + 4 * i : U32)), (D.bf(t, n), Rd.r32(t, d, (base + 4 * i : U32))), Rd.read32_any(d, t, n, (base + 4 * i : U32), hd, pf), h))

def end_parts(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +elem: S.CS, +i: U32, +m: U32, +base: U32, +endp: U32, +up: C.Frame, +a: U32, +cend: U32,
    e: V.Is(C.bsel(U32.is_ge(cend, a), U32.is_le(cend, endp), False{})),
    pr: V.M(t, d, p, V.Node{elem, a, cend}) & D.FD(t, d, p, C.FVarList{elem, (i + 1 : U32), m, base, endp, up}))
    -> V.Is(C.bsel(U32.is_ge(cend, a), U32.is_le(cend, endp), False{})) & V.M(t, d, 1n+p, V.Node{elem, a, cend}) & V.M(t, d, 1n+p, V.VEl{elem, (i + 1 : U32), m, base, endp}) & D.FD(t, d, 1n+p, up):
  (x, r) = pr
  (y, f) = r
  (e, (G.m_mono(t, d, p, V.Node{elem, a, cend}, x), (G.m_mono(t, d, p, V.VEl{elem, (i + 1 : U32), m, base, endp}, y), DM.fd_mono(t, d, p, up, f))))

# ---- tag 11: the offset v of element i ----------------------------------------------

# Last element: it ends at the window's end.
def el_last(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +elem: S.CS, +i: U32, +m: U32, +base: U32, +endp: U32, +up: C.Frame, +child: U32,
    pr: V.M(t, d, p, V.Node{elem, child, endp}) & D.FD(t, d, p, C.FVarList{elem, (i + 1 : U32), m, base, endp, up}))
    -> (V.M(t, d, 1n+p, V.Node{elem, child, endp}) & V.M(t, d, 1n+p, V.VEl{elem, (i + 1 : U32), m, base, endp})) & D.FD(t, d, 1n+p, up):
  (x, r) = pr
  (y, f) = r
  ((G.m_mono(t, d, p, V.Node{elem, child, endp}, x), G.m_mono(t, d, p, V.VEl{elem, (i + 1 : U32), m, base, endp}, y)), DM.fd_mono(t, d, p, up, f))

# Not the last: tag 12 has checked the next offset.
def el_mid(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +elem: S.CS, +i: U32, +m: U32, +base: U32, +endp: U32, +up: C.Frame, +child: U32, +cend: U32,
    pr: V.Is(C.bsel(U32.is_ge(cend, child), U32.is_le(cend, endp), False{})) & V.M(t, d, p, V.Node{elem, child, cend}) & V.M(t, d, p, V.VEl{elem, (i + 1 : U32), m, base, endp}) & D.FD(t, d, p, up))
    -> (V.Is(C.bsel(U32.is_ge(cend, child), U32.is_le(cend, endp), False{})) & V.M(t, d, 1n+p, V.Node{elem, child, cend}) & V.M(t, d, 1n+p, V.VEl{elem, (i + 1 : U32), m, base, endp})) & D.FD(t, d, 1n+p, up):
  (o, r1) = pr
  (x, r2) = r1
  (y, f) = r2
  ((o, (G.m_mono(t, d, p, V.Node{elem, child, cend}, x), G.m_mono(t, d, p, V.VEl{elem, (i + 1 : U32), m, base, endp}, y))), DM.fd_mono(t, d, p, up, f))

def el_step(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +elem: S.CS, +i: U32, +m: U32, +base: U32, +endp: U32, +up: C.Frame, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), last: Bool,
    h: {C.run(p, C.usel(last, 0, 12), elem, C.fsel(last, C.FVarList{elem, (i + 1 : U32), m, base, endp, up}, C.FVarList{elem, i, m, base, endp, up}),
          (base + v : U32), endp, c, (D.bf(t, n), Rd.r32(t, d, (base + 4 * (i + 1 : U32) : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.VarStep(last, (base + v : U32), V.el_at(t, d, base, (i + 1 : U32)), endp,
         V.M(t, d, 1n+p, V.Node{elem, (base + v : U32), endp}), V.M(t, d, 1n+p, V.Node{elem, (base + v : U32), V.el_at(t, d, base, (i + 1 : U32))}),
         V.M(t, d, 1n+p, V.VEl{elem, (i + 1 : U32), m, base, endp})) & D.FD(t, d, 1n+p, up):
  match last:
    case True{}: el_last(t, d, p, elem, i, m, base, endp, up, (base + v : U32),
      ih(D.T0{}, elem, C.FVarList{elem, (i + 1 : U32), m, base, endp, up}, (base + v : U32), endp, c, Rd.r32(t, d, (base + 4 * (i + 1 : U32) : U32)), h))
    case False{}: el_mid(t, d, p, elem, i, m, base, endp, up, (base + v : U32), V.el_at(t, d, base, (i + 1 : U32)),
      ih(D.T12{}, elem, C.FVarList{elem, i, m, base, endp, up}, (base + v : U32), endp, c, Rd.r32(t, d, (base + 4 * (i + 1 : U32) : U32)), h))

def el_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +elem: S.CS, +i: U32, +m: U32, +base: U32, +endp: U32, +up: C.Frame,
    +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), ok: Bool, e: {C.bsel(U32.is_le((base + v : U32), endp), U32.is_ge((base + v : U32), base), False{}) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(U32.is_eq((i + 1 : U32), m), 0, 12), 6), elem, C.fsel(U32.is_eq((i + 1 : U32), m), C.FVarList{elem, (i + 1 : U32), m, base, endp, up}, C.FVarList{elem, i, m, base, endp, up}),
          (base + v : U32), endp, c, (D.bf(t, n), Rd.r32(t, d, (base + 4 * (i + 1 : U32) : U32)))) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T11{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v):
  match ok:
    case True{}:
      (e, el_step(t, d, n, p, elem, i, m, base, endp, up, c, v, ih, U32.is_eq((i + 1 : U32), m), h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T11{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v),
      ih(D.T6{}, elem, C.fsel(U32.is_eq((i + 1 : U32), m), C.FVarList{elem, (i + 1 : U32), m, base, endp, up}, C.FVarList{elem, i, m, base, endp, up}),
        (base + v : U32), endp, c, Rd.r32(t, d, (base + 4 * (i + 1 : U32) : U32)), h))

def sound_t11(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T11{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T11{}, s, fr, a, b, c, v):
  match fr:
    case C.FVarList{+elem, +i, +m, +base, +endp, +up}:
      el_ok(t, d, n, p, s, elem, i, m, base, endp, up, a, b, c, v, ih, C.bsel(U32.is_le((base + v : U32), endp), U32.is_ge((base + v : U32), base), False{}), {==},
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(C.bsel(U32.is_le((base + v : U32), endp), U32.is_ge((base + v : U32), base), False{}), C.usel(U32.is_eq((i + 1 : U32), m), 0, 12), 6), elem,
              C.fsel(U32.is_eq((i + 1 : U32), m), C.FVarList{elem, (i + 1 : U32), m, base, endp, up}, C.FVarList{elem, i, m, base, endp, up}), (base + v : U32), endp, c, z) == (D.bf(t, n), True{}) : B.Buf & Bool},
          B.read32(D.bf(t, n), (base + 4 * (i + 1 : U32) : U32)), (D.bf(t, n), Rd.r32(t, d, (base + 4 * (i + 1 : U32) : U32))), Rd.read32_any(d, t, n, (base + 4 * (i + 1 : U32) : U32), hd, pf), h))
    case C.FDone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T11{}, s, C.FDone{}, a, b, c, v), L.no_run(t, n, h))
    case C.FCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}: Empty.absurd(D.Den(t, d, 1n+p, D.T11{}, s, C.FCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}, a, b, c, v), L.no_run(t, n, h))
    case C.FRep{x0, x1, x2, x3, x4}: Empty.absurd(D.Den(t, d, 1n+p, D.T11{}, s, C.FRep{x0, x1, x2, x3, x4}, a, b, c, v), L.no_run(t, n, h))

# ---- tag 12: the offset v where element i, starting at a, ends --------------------------

def end_ok(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +elem: S.CS, +i: U32, +m: U32, +base: U32, +endp: U32, +up: C.Frame,
    +a: U32, +b: U32, +c: U32, +v: U32, ih: D.IH(t, d, n, p), ok: Bool, e: {C.bsel(U32.is_ge((base + v : U32), a), U32.is_le((base + v : U32), endp), False{}) == ok : Bool},
    h: {C.run(p, C.usel(ok, 0, 6), elem, C.FVarList{elem, (i + 1 : U32), m, base, endp, up}, a, (base + v : U32), c, (D.bf(t, n), 0)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T12{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v):
  match ok:
    case True{}: end_parts(t, d, p, elem, i, m, base, endp, up, a, (base + v : U32), e,
      ih(D.T0{}, elem, C.FVarList{elem, (i + 1 : U32), m, base, endp, up}, a, (base + v : U32), c, 0, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T12{}, s, C.FVarList{elem, i, m, base, endp, up}, a, b, c, v),
      ih(D.T6{}, elem, C.FVarList{elem, (i + 1 : U32), m, base, endp, up}, a, (base + v : U32), c, 0, h))

def sound_t12(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T12{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T12{}, s, fr, a, b, c, v):
  match fr:
    case C.FVarList{+elem, +i, +m, +base, +endp, +up}:
      end_ok(t, d, n, p, s, elem, i, m, base, endp, up, a, b, c, v, ih, C.bsel(U32.is_ge((base + v : U32), a), U32.is_le((base + v : U32), endp), False{}), {==}, h)
    case C.FDone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T12{}, s, C.FDone{}, a, b, c, v), L.no_run(t, n, h))
    case C.FCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}: Empty.absurd(D.Den(t, d, 1n+p, D.T12{}, s, C.FCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}, a, b, c, v), L.no_run(t, n, h))
    case C.FRep{x0, x1, x2, x3, x4}: Empty.absurd(D.Den(t, d, 1n+p, D.T12{}, s, C.FRep{x0, x1, x2, x3, x4}, a, b, c, v), L.no_run(t, n, h))
