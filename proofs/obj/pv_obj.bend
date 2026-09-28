import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/limits.bend as Lim
import ../compact/found.bend as F
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./words_root_light.bend as WR_L
import ./words_obj.bend as WO
import ./words_obj_light.bend as WO_L
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./pv_obj_light.bend as LV

# Vectors of Bytes32 held as packed words (O.Words): each element is one chunk,
# so the object holds 32 * K bytes and its runtime root is O.words_root.
# See proofs/obj/words_obj.bend for the object form.

def to_wf1(-o: O.Words, +w: LV.wfv(o)) -> WO_L.wf1(o):
  (+t, w1) = w
  (+dw, w2) = w1
  (+N, w3) = w2
  (+q, w4) = w3
  (+eo, w5) = w4
  (+pf, w6) = w5
  (+hd, w7) = w6
  (+en, +room) = w7
  (t, (dw, (N, (q, (32n, (eo, (pf, (hd, (en, ({==}, ({==}, (room, {==}))))))))))))

def pv_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: LV.wfv(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.words_root(hl, h, o, dU, seg) == (h, (o, WO_L.wdig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
  WO.bv_st(hl, h, o, dU, seg, depth, to_wf1(o, wf), edu)

def min_k(+K: Nat, +q: Nat, +depth: Nat, +kq: {K == 1n+q : Nat}, +hm: {Lim.minimal(K, depth) == True{} : Bool}) -> {Lim.minimal(1n+q, depth) == True{} : Bool}:
  %kq : {Lim.minimal(_, depth) == True{} : Bool}
  hm

def pv_body(+hl: Nat, -h: B.Buf, -o: O.Words, +K: Nat, +depth: Nat, +dU: U32, +seg: U32,
    +wf: LV.wfv(o),
    +ks: {Nat.is_eq(O.chunks_of(WO_L.len(o)), K) == True{} : Bool},
    +hm: {Lim.minimal(K, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(LV.pview(o), S.Vector{S.ByteVector{32n}, K}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))]):
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+q, w4) = w3
  (+eo, w5) = w4
  (+pf, w6) = w5
  (+hd, w7) = w6
  (+en, +room) = w7
  +kq = LV.k_len(o, t, N, q, K, eo, en, ks)
  %Equal.sym(Nat, K, 1n+q, kq) :
    RR.roots(LV.pview(o), S.Vector{S.ByteVector{32n}, _}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    RR.roots(LV.pview(_), S.Vector{S.ByteVector{32n}, 1n+q}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, _, dU, seg))))])
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    RR.roots(S.Sequence{WR_L.items(O.chunks_of(N), F.array__slots(U32, _), 0n)}, S.Vector{S.ByteVector{32n}, 1n+q}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg))))])
  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO_L.chunks_q(N, q, 32n, en, {==}, {==})) :
    RR.roots(S.Sequence{WR_L.items(_, F.array__slots(U32, t), 0n)}, S.Vector{S.ByteVector{32n}, 1n+q}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg))))])
  WR.pv_full(hl, h, dU, seg, N, depth, q, dw, t, en, pf, room, edu, hd, min_k(K, q, depth, kq, hm), hdep, ehl)

# A vector of Bytes32: its digest is a specification root of its elements.
def pv_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat, +dU: U32, +seg: U32,
    +rep: LV.rep_pv(o, s),
    +ok: {LV.ok_pv(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(LV.pview(o), s, [D.bytes(WO_L.wdig(hl, o, depth))]):
  (+wf, +ks) = rep
  +c0 = DK.and_l(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth))), ok)
  +r1 = DK.and_r(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth))), ok)
  +c1 = DK.and_l(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth)), r1)
  +c2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth), r2)
  +c3 = DK.and_r(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth), r2)
  %pv_st(hl, h, o, dU, seg, depth, wf, edu) :
    RR.roots(LV.pview(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, c0)) :
    RR.roots(LV.pview(o), _, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  %Equal.sym(S.Schema, SH.Vector_element(s), S.ByteVector{SH.ByteVector_length(SH.Vector_element(s))}, SH.ByteVector_shape(SH.Vector_element(s), c1)) :
    RR.roots(LV.pview(o), S.Vector{_, SH.Vector_length(s)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  %Equal.sym(Nat, SH.ByteVector_length(SH.Vector_element(s)), 32n, WS.nat_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n, c2)) :
    RR.roots(LV.pview(o), S.Vector{S.ByteVector{_}, SH.Vector_length(s)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  pv_body(hl, h, o, SH.Vector_length(s), depth, dU, seg, wf, ks, c3, edu, hdep, ehl)
