import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/byte_list.bend as BL
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../../spec/packing.bend as Pack
import ../../spec/limits.bend as Lim
import 0xd9a2fae439ac7ff9e21e0853948f94fe/spec/crypto/sha.bend as VF
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./words_root_light.bend as WR_L
import ./sha_node.bend as SN
import ./len_bridge.bend as LB
import ./root_leaf.bend as RL

# Roots of byte lists (O.Words with a length mixed in, `O.mix_count(hl, 0n, ..)`)
# against the specification's ByteList relation (spec/root_relation.bend: a
# minimal depth for the chunk limit, the data tree of the chunks, and the
# length's 32-byte encoding mixed in with one more SHA-256).
#
# The object representation is as in proofs/obj/words_root.bend: a perfect
# word array thaw(t) of depth dw and a byte count N; the view is the first N
# bytes. A nonempty list has N = 32q + r with 1 <= r <= 32 (every N >= 1 has
# exactly one such q, r) and zero bytes after N up to the chunk boundary; the
# empty list (N = 0) has no chunks.

law zero_le:
  for +x: Nat
  {Nat.is_le(0n, x) == True{} : Bool}
def zero_le(x):
  match x:
    case 0n: {==}
    case 1n+p: {==}

# The runtime's length chunk and the list's data root, hashed together, are the
# specification's mix-in of that root and the length encoding.
def mix_bytes(+hl: Nat, +ehl: {hl == 64n : Nat}, +R: D.Digest, +N: U32)
    -> {Mix.mix_length_bytes(Some{D.bytes(R)}, Len.encoding(32n, U32.to_nat(N))) == Some{D.bytes(O.mix_len(hl, R, N))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Maybe<&2, +List<U32>>, Len.encoding(32n, U32.to_nat(N)), Some{List.append(&2, U32, FX.limbs([N]), SP.zero_bytes(28n))}, LB.len_bytes(N)) :
    {Mix.mix_length_bytes(Some{D.bytes(R)}, _) == Some{D.bytes(O.mix_len(hl, R, N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(List<&2, U32>, D.bytes(D.node(hl, R, O.len_chunk(N))), VF.sha256_bytes(List.append(&2, U32, D.bytes(R), D.bytes(O.len_chunk(N)))), SN.node_at(hl, ehl, R, O.len_chunk(N))) :
    {Mix.mix_length_bytes(Some{D.bytes(R)}, Some{List.append(&2, U32, FX.limbs([N]), SP.zero_bytes(28n))}) == Some{_} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, D.bytes(O.len_chunk(N)), List.append(&2, U32, FX.limbs([N]), SP.zero_bytes(28n)), RL.bytes_1(N)) :
    {Mix.mix_length_bytes(Some{D.bytes(R)}, Some{List.append(&2, U32, FX.limbs([N]), SP.zero_bytes(28n))}) == Some{VF.sha256_bytes(List.append(&2, U32, D.bytes(R), _))} : Maybe<&2, +List<U32>>}
  {==}

# ---- nonempty lists ----------------------------------------------------------

def bl_state(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +N: U32, +depth: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +edu: {U32.to_nat(dU) == depth : Nat}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool})
    -> {O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}:
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
      WR.bv_state(hl, h, dU, seg, N, depth, q, r, dw, t, en, h1, h32, pf, room, slack, edu, hd)) :
    {O.mix_count(hl, 0n, _) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
  {==}

def bl_hlen(+q: Nat, +t: F.array__Tree<U32>, +cap: Nat, +hc: {Nat.is_le(1n+q, BL.chunk_limit(cap)) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), BL.chunk_limit(cap)) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), 1n+q, MR.clist_len(1n+q, F.array__slots(U32, t), 0n)) :
    {Nat.is_le(_, BL.chunk_limit(cap)) == True{} : Bool}
  hc

def bl_gate(+hl: Nat, +cap: Nat, +N: U32, +depth: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +hn: {Nat.is_le(Nat.add(WS.e32(q), r), cap) == True{} : Bool},
    +hc: {Nat.is_le(1n+q, BL.chunk_limit(cap)) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> {RR.bytelist_at_depth(cap, depth, WR_L.view(t, N)) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), en) :
    {RR.bytelist_at_depth(cap, depth, WS.btake(_, FX.limbs(F.array__slots(U32, t)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, SP.bytes_domain(WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))), True{},
      WS.scope_dom(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), WS.chunk_scope(q, r, F.array__slots(U32, t), 0n, h32, WR_L.cap_at(q, dw, t, pf, room)))) :
    {BL.root_gate(Bool.and(_, Nat.is_le(List.length(&2, U32, WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))), cap)), cap, depth, WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, List.length(&2, U32, WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))), Nat.add(WS.e32(q), r),
      WS.scope_len(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), WS.chunk_scope(q, r, F.array__slots(U32, t), 0n, h32, WR_L.cap_at(q, dw, t, pf, room)))) :
    {BL.root_gate(Bool.and(True{}, Nat.is_le(_, cap)), cap, depth, WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_le(Nat.add(WS.e32(q), r), cap), True{}, hn) :
    {BL.root_gate(Bool.and(True{}, _), cap, depth, WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Pack.scan(WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), 31n, [], []), MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)),
      WS.chunk_scan(q, r, F.array__slots(U32, t), 0n, [], h1, h32, WR_L.cap_at(q, dw, t, pf, room), slack)) :
    {Mix.mix_length_bytes(Lim.at_depth(BL.chunk_limit(cap), depth, _), Len.encoding(32n, List.length(&2, U32, WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, List.length(&2, U32, WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t)))), Nat.add(WS.e32(q), r),
      WS.scope_len(Nat.add(WS.e32(q), r), WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), WS.chunk_scope(q, r, F.array__slots(U32, t), 0n, h32, WR_L.cap_at(q, dw, t, pf, room)))) :
    {Mix.mix_length_bytes(Lim.at_depth(BL.chunk_limit(cap), depth, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %en :
    {Mix.mix_length_bytes(Lim.at_depth(BL.chunk_limit(cap), depth, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Lim.at_depth(BL.chunk_limit(cap), depth, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n))), hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))},
      RS.at_depth_tree(BL.chunk_limit(cap), depth, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), hdep, bl_hlen(q, t, cap, hc), ehl)) :
    {Mix.mix_length_bytes(_, Len.encoding(32n, U32.to_nat(N))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_lt(0n, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n))), True{}, {==}) :
    {Mix.mix_length_bytes(Some{D.bytes(MD.rtree(depth, _, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))}, Len.encoding(32n, U32.to_nat(N))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  mix_bytes(hl, ehl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N)

def bl_full(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +cap: Nat, +N: U32, +depth: Nat, +q: Nat, +r: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +room: {Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
    +slack: {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>},
    +edu: {U32.to_nat(dU) == depth : Nat}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +hn: {Nat.is_le(Nat.add(WS.e32(q), r), cap) == True{} : Bool},
    +hc: {Nat.is_le(1n+q, BL.chunk_limit(cap)) == True{} : Bool},
    +hmin: {Lim.minimal(BL.chunk_limit(cap), depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{WR_L.view(t, N)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)))))]):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)), (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))),
      bl_state(hl, h, dU, seg, N, depth, q, r, dw, t, en, h1, h32, pf, room, slack, edu, hd)) :
    RR.roots(S.BytesValue{WR_L.view(t, N)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  (depth, (hmin, bl_gate(hl, cap, N, depth, q, r, dw, t, en, h1, h32, pf, room, slack, hn, hc, hdep, ehl)))

# ---- the empty list ----------------------------------------------------------

def bl0_state(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +N: U32, +depth: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == 0n : Nat},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool})
    -> {O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}:
  %Equal.sym(Nat, U32.to_nat(dU), depth, edu) :
    {O.mix_count(hl, 0n, O.mt_words(N, O.mtree(_, 0n, Nat.is_lt(0n, O.chunks_of(N)), hl, O.LWords{}, O.pow2n(_), 0n, O.chunks_of(N), (h, (F.array__thaw(U32, t), D.zero()))))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, U32.to_nat(N), 0n, en) :
    {O.mix_count(hl, 0n, O.mt_words(N, O.mtree(depth, 0n, Nat.is_lt(0n, Nat.div(Nat.add(_, 31n), 32n)), hl, O.LWords{}, O.pow2n(depth), 0n, Nat.div(Nat.add(_, 31n), 32n), (h, (F.array__thaw(U32, t), D.zero()))))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, Nat.div(Nat.add(0n, 31n), 32n), 0n, {==}) :
    {O.mix_count(hl, 0n, O.mt_words(N, O.mtree(depth, 0n, Nat.is_lt(0n, _), hl, O.LWords{}, O.pow2n(depth), 0n, _, (h, (F.array__thaw(U32, t), D.zero()))))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(depth, 0n, False{}, hl, O.LWords{}, O.pow2n(depth), 0n, 0n, (h, (F.array__thaw(U32, t), D.zero()))), (h, (F.array__thaw(U32, t), MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))),
      MR.mt_words(depth, False{}, hl, dw, t, 0n, 0n, h, D.zero(), {==}, hd, pf, zero_le(F.spec_common__pow2(dw)))) :
    {O.mix_count(hl, 0n, O.mt_words(N, _)) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
  {==}

def bl0_gate(+hl: Nat, +cap: Nat, +N: U32, +depth: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == 0n : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> {RR.bytelist_at_depth(cap, depth, WR_L.view(t, N)) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Nat, U32.to_nat(N), 0n, en) :
    {RR.bytelist_at_depth(cap, depth, WS.btake(_, FX.limbs(F.array__slots(U32, t)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_le(0n, cap), True{}, zero_le(cap)) :
    {BL.root_gate(Bool.and(True{}, _), cap, depth, []) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %en :
    {Mix.mix_length_bytes(Lim.at_depth(BL.chunk_limit(cap), depth, MD.bytes_list(MR.clist(0n, F.array__slots(U32, t), 0n))), Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Lim.at_depth(BL.chunk_limit(cap), depth, MD.bytes_list(MR.clist(0n, F.array__slots(U32, t), 0n))), Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(MR.clist(0n, F.array__slots(U32, t), 0n))), hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))},
      RS.at_depth_tree(BL.chunk_limit(cap), depth, hl, MR.clist(0n, F.array__slots(U32, t), 0n), hdep, zero_le(BL.chunk_limit(cap)), ehl)) :
    {Mix.mix_length_bytes(_, Len.encoding(32n, U32.to_nat(N))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_lt(0n, MD.dlen(MR.clist(0n, F.array__slots(U32, t), 0n))), False{}, {==}) :
    {Mix.mix_length_bytes(Some{D.bytes(MD.rtree(depth, _, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))}, Len.encoding(32n, U32.to_nat(N))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))} : Maybe<&2, +List<U32>>}
  mix_bytes(hl, ehl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N)

def bl0_full(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +cap: Nat, +N: U32, +depth: Nat, +dw: Nat, +t: F.array__Tree<U32>,
    +en: {U32.to_nat(N) == 0n : Nat},
    +pf: {F.array__perfect(U32, dw, t) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +hmin: {Lim.minimal(BL.chunk_limit(cap), depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{WR_L.view(t, N)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)))))]):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)), (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))),
      bl0_state(hl, h, dU, seg, N, depth, dw, t, en, pf, edu, hd)) :
    RR.roots(S.BytesValue{WR_L.view(t, N)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  (depth, (hmin, bl0_gate(hl, cap, N, depth, t, en, hdep, ehl)))
