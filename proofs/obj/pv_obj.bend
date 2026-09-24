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
import ./words_obj.bend as WO
import ./schema_shapes.bend as SH
import ./dk.bend as DK

# Vectors of Bytes32 held as packed words (O.Words): each element is one chunk,
# so the object holds 32 * K bytes and its runtime root is O.words_root.
# See proofs/obj/words_obj.bend for the object form.

def pview(o: O.Words) -> S.Value:
  match o:
    case O.Words{ws, +n}: S.Sequence{WR.items(O.chunks_of(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n)}

# The representation invariant: a perfect word tree with room for 1 + q whole chunks.
def wfv(o: O.Words) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N => DK.Ex(Nat, q =>
    DK.P2({o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({U32.to_nat(N) == Nat.add(WS.e32(q), 32n) : Nat},
          {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool}))))))))

def to_wf1(-o: O.Words, +w: wfv(o)) -> WO.wf1(o):
  (+t, w1) = w
  (+dw, w2) = w1
  (+N, w3) = w2
  (+q, w4) = w3
  (+eo, w5) = w4
  (+pf, w6) = w5
  (+hd, w7) = w6
  (+en, +room) = w7
  (t, (dw, (N, (q, (32n, (eo, (pf, (hd, (en, ({==}, ({==}, (room, {==}))))))))))))

# The object represents a value of the vector schema s: it holds one chunk per element.
def rep_pv(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wfv(o), {Nat.is_eq(O.chunks_of(WO.len(o)), SH.Vector_length(s)) == True{} : Bool})

# The schema is a vector of Bytes32 whose length has minimal depth `depth`.
def ok_pv(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth))))

def pv_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: wfv(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.words_root(hl, h, o, dU, seg) == (h, (o, WO.wdig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
  WO.bv_st(hl, h, o, dU, seg, depth, to_wf1(o, wf), edu)

def k_len1(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +K: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ks: {Nat.is_eq(O.chunks_of(WO.len(o)), K) == True{} : Bool}) -> {Nat.is_eq(O.chunks_of(N), K) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(O.chunks_of(_), K) == True{} : Bool}
  ks

def k_len(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +q: Nat, +K: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), 32n) : Nat},
    +ks: {Nat.is_eq(O.chunks_of(WO.len(o)), K) == True{} : Bool}) -> {K == 1n+q : Nat}:
  +ks1 = k_len1(o, t, N, K, eo, ks)
  Equal.trans(Nat, K, O.chunks_of(N), 1n+q, Equal.sym(Nat, O.chunks_of(N), K, WS.nat_eq(O.chunks_of(N), K, ks1)), WO.chunks_q(N, q, 32n, en, {==}, {==}))

def min_k(+K: Nat, +q: Nat, +depth: Nat, +kq: {K == 1n+q : Nat}, +hm: {Lim.minimal(K, depth) == True{} : Bool}) -> {Lim.minimal(1n+q, depth) == True{} : Bool}:
  %kq : {Lim.minimal(_, depth) == True{} : Bool}
  hm

def pv_body(+hl: Nat, -h: B.Buf, -o: O.Words, +K: Nat, +depth: Nat, +dU: U32, +seg: U32,
    +wf: wfv(o),
    +ks: {Nat.is_eq(O.chunks_of(WO.len(o)), K) == True{} : Bool},
    +hm: {Lim.minimal(K, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(pview(o), S.Vector{S.ByteVector{32n}, K}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))]):
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+q, w4) = w3
  (+eo, w5) = w4
  (+pf, w6) = w5
  (+hd, w7) = w6
  (+en, +room) = w7
  +kq = k_len(o, t, N, q, K, eo, en, ks)
  %Equal.sym(Nat, K, 1n+q, kq) :
    RR.roots(pview(o), S.Vector{S.ByteVector{32n}, _}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    RR.roots(pview(_), S.Vector{S.ByteVector{32n}, 1n+q}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, _, dU, seg))))])
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    RR.roots(S.Sequence{WR.items(O.chunks_of(N), F.array__slots(U32, _), 0n)}, S.Vector{S.ByteVector{32n}, 1n+q}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg))))])
  %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, 32n, en, {==}, {==})) :
    RR.roots(S.Sequence{WR.items(_, F.array__slots(U32, t), 0n)}, S.Vector{S.ByteVector{32n}, 1n+q}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg))))])
  WR.pv_full(hl, h, dU, seg, N, depth, q, dw, t, en, pf, room, edu, hd, min_k(K, q, depth, kq, hm), hdep, ehl)

# A vector of Bytes32: its digest is a specification root of its elements.
def pv_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat, +dU: U32, +seg: U32,
    +rep: rep_pv(o, s),
    +ok: {ok_pv(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(pview(o), s, [D.bytes(WO.wdig(hl, o, depth))]):
  (+wf, +ks) = rep
  +c0 = DK.and_l(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth))), ok)
  +r1 = DK.and_r(SH.is_Vector(s), Bool.and(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth))), ok)
  +c1 = DK.and_l(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth)), r1)
  +r2 = DK.and_r(SH.is_ByteVector(SH.Vector_element(s)), Bool.and(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth)), r1)
  +c2 = DK.and_l(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth), r2)
  +c3 = DK.and_r(Nat.is_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n), Lim.minimal(SH.Vector_length(s), depth), r2)
  %pv_st(hl, h, o, dU, seg, depth, wf, edu) :
    RR.roots(pview(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, c0)) :
    RR.roots(pview(o), _, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  %Equal.sym(S.Schema, SH.Vector_element(s), S.ByteVector{SH.ByteVector_length(SH.Vector_element(s))}, SH.ByteVector_shape(SH.Vector_element(s), c1)) :
    RR.roots(pview(o), S.Vector{_, SH.Vector_length(s)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  %Equal.sym(Nat, SH.ByteVector_length(SH.Vector_element(s)), 32n, WS.nat_eq(SH.ByteVector_length(SH.Vector_element(s)), 32n, c2)) :
    RR.roots(pview(o), S.Vector{S.ByteVector{_}, SH.Vector_length(s)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  pv_body(hl, h, o, SH.Vector_length(s), depth, dU, seg, wf, ks, c3, edu, hdep, ehl)

def rep_wf(-o: O.Words, +s: S.Schema, +rep: rep_pv(o, s)) -> wfv(o):
  (+w, +n) = rep
  w
