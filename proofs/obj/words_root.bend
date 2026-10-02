import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/byte_root.bend as Br
import ../../spec/packing.bend as Pack
import ../../spec/limits.bend as Lim
import ../../spec/tree.bend as Tr
import ../../spec/value_domain.bend as VD
import ../compact/found_generated.bend as F
import ./spec_fixed.bend as FX
import ./mtree_defs.bend as MD
import ./mtree_spec.bend as MS
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./words_spec.bend as WS
import ./words_root_light.bend as LV
import ./words_cap.bend as WC
import ./words_canon.bend as WCN

# Roots of packed byte storage (O.Words) against the specification.
#
# A Words object is its word array and its byte count n. The array is a
# perfect Base array tree `thaw(t)` of depth dw < 32 holding at least the
# chunks' words (the object API only ever builds perfect arrays; found.bend
# proves Array.new and Array.set keep them perfect), and the bytes past n up
# to the chunk boundary are zero (every constructor and writer of the API keeps
# them so; this is the representation invariant the root needs, because the
# runtime hashes whole chunks). The view of the object is its first n bytes,
# `btake(n, limbs(slots t))` - stuck on t, so no length is ever unfolded.
#
# n = 32q + r with 1 <= r <= 32: q + 1 chunks, the last holding r bytes.

# The chunks of the view are the chunk digests' bytes.
def chunks_view(+N: U32, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>})
    -> {Br.chunks(LV.view(t, N)) == MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)) : +List<+List<U32>>}:
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), en) :
    {Pack.scan(WS.btake(_, FX.limbs(F.array__slots(U32, t))), 31n, [], []) == MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)) : +List<+List<U32>>}
  WS.chunk_scan(q, r, F.array__slots(U32, t), 0n, [], h1, h32, LV.cap_at(q, dw, t, pf, cap), slack)

def canon_view(+N: U32, +depth: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +hmin: {Lim.minimal(1n+q, depth) == True{} : Bool})
    -> {Br.canonical_depth(LV.view(t, N), depth) == True{} : Bool}:
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.view(t, N)), MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)), chunks_view(N, q, r, dw, t, en, h1, h32, pf, cap, slack)) :
    {Lim.minimal(List.length(&2, +List<U32>, _), depth) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, +List<U32>, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), RS.length_bytes(MR.clist(1n+q, F.array__slots(U32, t), 0n))) :
    {Lim.minimal(_, depth) == True{} : Bool}
  %Equal.sym(Nat, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), 1n+q, MR.clist_len(1n+q, F.array__slots(U32, t), 0n)) :
    {Lim.minimal(_, depth) == True{} : Bool}
  hmin

def gate_view(+hl: Nat, +N: U32, +depth: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> {RR.bytevector_at_depth(U32.to_nat(N), depth, LV.view(t, N)) == Some{D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), en) :
    {Br.gate(VD.bytevector_domain(_, LV.view(t, N)), depth, LV.view(t, N)) == Some{D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, VD.bytevector_domain(Nat.add(WS.e32(q), r), LV.view(t, N)), SP.byte_scope(Nat.add(WS.e32(q), r), LV.view(t, N)), LV.dom_pos(Nat.add(WS.e32(q), r), LV.view(t, N), LV.pos_add(WS.e32(q), r, h1))) :
    {Br.gate(_, depth, LV.view(t, N)) == Some{D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), en) :
    {Br.gate(SP.byte_scope(Nat.add(WS.e32(q), r), WS.btake(_, FX.limbs(F.array__slots(U32, t)))), depth, LV.view(t, N)) == Some{D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, SP.byte_scope(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))), True{}, WS.chunk_scope(q, r, F.array__slots(U32, t), 0n, h32, LV.cap_at(q, dw, t, pf, cap))) :
    {Br.gate(_, depth, LV.view(t, N)) == Some{D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.view(t, N)), MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)), chunks_view(N, q, r, dw, t, en, h1, h32, pf, cap, slack)) :
    {Some{Tr.tree(depth, _)} == Some{D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n, {==}, hdep, ehl) :
    {Some{_} == Some{D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))} : Maybe<&2, +List<U32>>}
  {==}

# The runtime root of the byte storage (O.words_root) is the reference tree over
# its chunk digests, and hands back the hasher and the object unchanged.
def bv_state(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +N: U32, +depth: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +edu: {U32.to_nat(dU) == depth : Nat}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool})
    -> {O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}:
  +hcn = Equal.trans(Nat, O.chunks_of(N), Nat.div(Nat.add(Nat.add(WS.e32(q), r), 31n), 32n), 1n+q,
    Equal.cong(Nat, Nat, z => Nat.div(Nat.add(z, 31n), 32n), U32.to_nat(N), Nat.add(WS.e32(q), r), en), WS.chunks_count(q, r, h1, h32))
  +hcap = F.logic__subst(Nat, z => {Nat.is_le(O.e8(z), F.spec_common__pow2(dw)) == True{} : Bool}, 1n+q, O.chunks_of(N), Equal.sym(Nat, O.chunks_of(N), 1n+q, hcn), cap)
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg),
      O.mt_words(N, O.mtree(U32.to_nat(dU), 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(U32.to_nat(dU)), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))), WC.wr_unfold(hl, h, dU, seg, N, dw, t, pf, hd, hcap, WCN.canon1(N, q, r, dw, t, en, h1, h32, hd, pf, cap, slack))) :
    {_ == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(dU), depth, edu) :
    {O.mt_words(N, O.mtree(_, 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(_), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero())))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), en) :
    {O.mt_words(N, O.mtree(depth, 0n, Nat.is_lt(0n, Nat.div(Nat.add(_, 31n), 32n)), hl, O.LWords{}, O.pow2n(depth), 0n, Nat.div(Nat.add(_, 31n), 32n), (h, (F.array__thaw(U32, t), D.zero())))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, Nat.div(Nat.add(Nat.add(WS.e32(q), r), 31n), 32n), 1n+q, WS.chunks_count(q, r, h1, h32)) :
    {O.mt_words(N, O.mtree(depth, 0n, Nat.is_lt(0n, _), hl, O.LWords{}, O.pow2n(depth), 0n, _, (h, (F.array__thaw(U32, t), D.zero())))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(depth, 0n, True{}, hl, O.LWords{}, O.pow2n(depth), 0n, 1n+q, (h, (F.array__thaw(U32, t), D.zero()))), (h, (F.array__thaw(U32, t), MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
      MR.mt_words(depth, True{}, hl, dw, t, 0n, 1n+q, h, D.zero(), {==}, hd, pf, cap)) :
    {O.mt_words(N, _) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  {==}

# The specification root of the view (a byte vector of N bytes) is that tree's root.
def bv_root(+hl: Nat, +N: U32, +depth: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +hmin: {Lim.minimal(1n+q, depth) == True{} : Bool}, +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{LV.view(t, N)}, S.ByteVector{U32.to_nat(N)}, [D.bytes(MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))]):
  (depth, (canon_view(N, depth, q, r, dw, t, en, h1, h32, pf, cap, slack, hmin), gate_view(hl, N, depth, q, r, dw, t, en, h1, h32, pf, cap, slack, hdep, ehl)))

# Both together, with the runtime root in the statement and no tree term: this is
# what the per-name laws instantiate (at hl = 64n and the name's size), so the
# instance never unfolds a reference tree over concrete chunk digests.
def bv_full(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +N: U32, +depth: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +edu: {U32.to_nat(dU) == depth : Nat}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +hmin: {Lim.minimal(1n+q, depth) == True{} : Bool}, +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{LV.view(t, N)}, S.ByteVector{U32.to_nat(N)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg))))]):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
      bv_state(hl, h, dU, seg, N, depth, q, r, dw, t, en, h1, h32, pf, cap, slack, edu, hd)) :
    RR.roots(S.BytesValue{LV.view(t, N)}, S.ByteVector{U32.to_nat(N)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  bv_root(hl, N, depth, q, r, dw, t, en, h1, h32, pf, cap, slack, hmin, hdep, ehl)

def elem_gate(+W: List<&2, U32>, +i: Nat) -> {RR.bytevector_at_depth(32n, 0n, WS.cb(W, i)) == Some{D.bytes(MR.cw(W, i))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, SP.byte_scope(32n, WS.cb(W, i)), True{}, WS.scope_cb(W, i)) :
    {Br.gate(_, 0n, WS.cb(W, i)) == Some{D.bytes(MR.cw(W, i))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, D.bytes(MR.cw(W, i)), WS.cb(W, i), WS.bytes_cw(W, i)) :
    {Br.gate(True{}, 0n, WS.cb(W, i)) == Some{_} : Maybe<&2, +List<U32>>}
  {==}

# ---- vectors and lists of Bytes32 (packed; each element is one chunk) -------------

# One element: a 32-byte vector is its own root (depth 0).
def elem_root(+W: List<&2, U32>, +i: Nat) -> RR.roots(S.BytesValue{WS.cb(W, i)}, S.ByteVector{32n}, [D.bytes(MR.cw(W, i))]):
  (0n, ({==}, elem_gate(W, i)))

# The elements' roots are the chunk digests' bytes.
law items_roots:
  for +k: Nat
  for +W: List<&2, U32>
  for +i: Nat
  RR.roots(LV.items(k, W, i), S.Repeat{S.ByteVector{32n}}, MD.bytes_list(MR.clist(k, W, i)))
def items_roots(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      ([D.bytes(MR.cw(W, i))], (MD.bytes_list(MR.clist(q, W, 1n+i)), (elem_root(W, i), (items_roots(q, W, 1n+i), {==}))))

# A vector of 1 + q Bytes32 (the object holds 32(q + 1) bytes, whole chunks, so
# there is no slack): its root is the specification root of its elements.
def pv_full(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +N: U32, +depth: Nat, +q: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), 32n) : Nat},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +cap: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +hmin: {Lim.minimal(1n+q, depth) == True{} : Bool}, +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.Sequence{LV.items(1n+q, F.array__slots(U32, t), 0n)}, S.Vector{S.ByteVector{32n}, 1n+q}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg))))]):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
      bv_state(hl, h, dU, seg, N, depth, q, 32n, dw, t, en, {==}, {==}, pf, cap, {==}, edu, hd)) :
    RR.roots(S.Sequence{LV.items(1n+q, F.array__slots(U32, t), 0n)}, S.Vector{S.ByteVector{32n}, 1n+q}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  (MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)), (items_roots(1n+q, F.array__slots(U32, t), 0n),
    RS.aggregate_digests(1n+q, depth, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), hdep, hmin, Equal.trans(Bool, Nat.is_le(MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), 1n+q), Nat.is_le(1n+q, 1n+q), True{},
      Equal.cong(Nat, Bool, x => Nat.is_le(x, 1n+q), MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), 1n+q, MR.clist_len(1n+q, F.array__slots(U32, t), 0n)), RS.le_refl(1n+q)), ehl)))
