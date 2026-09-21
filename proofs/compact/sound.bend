import Base
import ../../src/cschema.bend as S
import ../../src/cscan.bend as C
import ../../src/buffer.bend as B
import ./found.bend as F
import ./cvm.bend as V
import ./den.bend as D
import ./sound_leaf.bend as L
import ./sound_seq.bend as Q
import ./sound_cont.bend as K

# Soundness of the compact scanner (src/cscan.bend) against its machine-level
# specification (proofs/compact/cvm.bend): every successful run from any state,
# with any fuel, any schema and any buffer - a perfect tree of depth d < 32 read
# through its flattening - establishes that state's obligations (den.bend).
# The proof is by induction on the fuel; each step is one of the step lemmas.

def step0(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T0{}, s, fr, a, b, c, v):
  match s:
    case S.CBool{}: L.t0_bool(t, d, n, hd, pf, p, fr, a, b, c, v, ih, h)
    case S.CUint{+x0}: L.t0_uint(t, d, n, p, x0, fr, a, b, c, v, ih, h)
    case S.CBytes{+x0, +x1}: L.t0_bytes(t, d, n, p, x0, x1, fr, a, b, c, v, ih, h)
    case S.CByteList{+x0, +x1, +x2}: L.t0_bytelist(t, d, n, p, x0, x1, x2, fr, a, b, c, v, ih, h)
    case S.CBitVec{+x0, +x1, +x2}: L.t0_bitvec(t, d, n, hd, pf, p, x0, x1, x2, fr, a, b, c, v, ih, h)
    case S.CBitList{+x0, +x1, +x2}: L.t0_bitlist(t, d, n, hd, pf, p, x0, x1, x2, fr, a, b, c, v, ih, h)
    case S.CVec{+x0, +x1, +x2, +x3, +x4, +x5}: Q.t0_vec(t, d, n, p, x0, x1, x2, x3, x4, x5, fr, a, b, c, v, ih, h)
    case S.CVecVar{+x0, +x1, +x2}: Q.t0_vecvar(t, d, n, hd, pf, p, x0, x1, x2, fr, a, b, c, v, ih, h)
    case S.CList{+x0, +x1, +x2, +x3, +x4, +x5, +x6}: Q.t0_list(t, d, n, p, x0, x1, x2, x3, x4, x5, x6, fr, a, b, c, v, ih, h)
    case S.CListVar{+x0, +x1, +x2, +x3}: Q.t0_listvar(t, d, n, hd, pf, p, x0, x1, x2, x3, fr, a, b, c, v, ih, h)
    case S.CCont{+x0, +x1, +x2, +x3, +x4, +x5, +x6, +x7, +x8, +x9}: K.t0_cont(t, d, n, hd, pf, p, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, fr, a, b, c, v, ih, h)
    case S.CPCont{+x0, +x1, +x2, +x3, +x4, +x5, +x6, +x7, +x8, +x9, +x10}: K.t0_pcont(t, d, n, p, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, fr, a, b, c, v, ih, h)
    case S.CUnion{+x0, +x1}: K.t0_union(t, d, n, hd, pf, p, x0, x1, fr, a, b, c, v, ih, h)
    case S.CNull{}: L.t0_null(t, d, n, p, fr, a, b, c, v, ih, h)
    case S.CFLeaf{x0, x1, x2, x3}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CFLeaf{x0, x1, x2, x3}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CFNode{x0, x1, x2}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CFNode{x0, x1, x2}, fr, a, b, c, v), L.no_run(t, n, h))
    case S.CFNone{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, S.CFNone{}, fr, a, b, c, v), L.no_run(t, n, h))

def step(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +p: Nat, tg: D.Tag, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, tg, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, tg, s, fr, a, b, c, v):
  match tg:
    case D.T0{}: step0(t, d, n, hd, pf, p, s, fr, a, b, c, v, ih, h)
    case D.T1{}: L.sound_t1(t, d, n, p, s, fr, a, b, c, v, ih, h)
    case D.T2{}: L.sound_t2(t, d, n, p, s, fr, a, b, c, v, ih, h)
    case D.T3{}: L.sound_t3(t, d, n, p, s, fr, a, b, c, v, ih, h)
    case D.T4{}: Q.sound_t4(t, d, n, p, s, fr, a, b, c, v, ih, h)
    case D.T5{}: Q.sound_t5(t, d, n, hd, pf, p, s, fr, a, b, c, v, ih, h)
    case D.T6{}: L.no_run(t, n, h)
    case D.T8{}: K.sound_t8(t, d, n, hd, pf, p, s, fr, a, b, c, v, ih, h)
    case D.T9{}: K.sound_t9(t, d, n, p, s, fr, a, b, c, v, ih, h)
    case D.T11{}: Q.sound_t11(t, d, n, hd, pf, p, s, fr, a, b, c, v, ih, h)
    case D.T12{}: Q.sound_t12(t, d, n, p, s, fr, a, b, c, v, ih, h)
    case D.T13{}: K.sound_t13(t, d, n, p, s, fr, a, b, c, v, ih, h)
    case D.T15{}: K.sound_t15(t, d, n, hd, pf, p, s, fr, a, b, c, v, ih, h)
    case D.T16{}: K.sound_t16(t, d, n, hd, pf, p, s, fr, a, b, c, v, ih, h)

def sound(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +fuel: Nat, tg: D.Tag, +s: S.CS, +fr: C.Frame, +a: U32, +b: U32, +c: U32, +v: U32,
    h: D.Ok(t, n, fuel, tg, s, fr, a, b, c, v)) -> D.Den(t, d, fuel, tg, s, fr, a, b, c, v):
  match fuel:
    case 0n: Empty.absurd(D.Den(t, d, 0n, tg, s, fr, a, b, c, v), L.no_run(t, n, h))
    case 1n+ +p: step(t, d, n, hd, pf, p, tg, s, fr, a, b, c, v,
      tg2 => s2 => fr2 => a2 => b2 => c2 => v2 => h2 => sound(t, d, n, hd, pf, p, tg2, s2, fr2, a2, b2, c2, v2, h2), h)

def first_of(-A: Type, pr: A & Unit) -> A:
  (x, u) = pr
  x

# The walk's entry point: a schema that is not plain is scanned by the walk
# from tag 0 with fuel 64 + 4 len; if it accepts the window [off, off + len),
# the window meets the machine-level specification at that fuel.
def sound_walk(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +s: S.CS, +off: U32, +len: U32,
    h: {C.valid_pick(False{}, s, off, len, D.bf(t, n)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.CVm(t, d, Nat.add(64n, U32.to_nat((4 * len : U32))), s, off, (off + len : U32)):
  first_of(V.M(t, d, Nat.add(64n, U32.to_nat((4 * len : U32))), V.Node{s, off, (off + len : U32)}),
    sound(t, d, n, hd, pf, Nat.add(64n, U32.to_nat((4 * len : U32))), D.T0{}, s, C.FDone{}, off, (off + len : U32), 0, 0, h))

# The same through valid_in, for a schema that is not plain.
def sound_valid_in(+t: F.array__Tree<U32>, +d: Nat, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +s: S.CS, +off: U32, +len: U32, np: {S.is_plain(s) == False{} : Bool},
    h: {C.valid_in(s, off, len, D.bf(t, n)) == (D.bf(t, n), True{}) : B.Buf & Bool})
    -> V.CVm(t, d, Nat.add(64n, U32.to_nat((4 * len : U32))), s, off, (off + len : U32)):
  sound_walk(t, d, n, hd, pf, s, off, len,
    F.logic__subst(Bool, z => {C.valid_pick(z, s, off, len, D.bf(t, n)) == (D.bf(t, n), True{}) : B.Buf & Bool}, S.is_plain(s), False{}, np, h))
