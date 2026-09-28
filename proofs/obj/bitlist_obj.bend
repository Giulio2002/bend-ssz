import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/bit_root.bend as Bm
import ../../spec/bit_packing.bend as Bp
import ../../spec/packing.bend as Pack
import ../../spec/limits.bend as Lim
import ../../spec/nat_bytes.bend as Len
import ../../spec/primitives.bend as SP
import ../compact/found.bend as F
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./words_root_light.bend as WR_L
import ./words_obj_light.bend as WO
import ./list_root.bend as LR
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./root_support.bend as RS
import ./obj_support.bend as OS
import ./spec_fixed.bend as FX
import ./bitlist_pack.bend as BK
import ./bitlist_obj_light.bend as LV

# Bit lists as objects (O.Bits{ws, k}: the words holding the bits, least
# significant first, and the bit count k; no delimiter). The runtime root is the
# data tree of the first ceil(k/8) bytes of the words with k mixed in
# (src/obj.bend bits_root); the specification root is that of the first k bits
# (spec/bit_root.bend bitlist_at_depth). They meet at bitlist_pack.bend
# `bpack`: the first k bits pack to the first ceil(k/8) bytes when the bits of
# the last byte past k are zero.

def bdig(+hl: Nat, o: O.Bits, +depth: Nat) -> D.Digest:
  match o:
    case O.Bits{ws, +k}: O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(k))), hl, MR.clist(O.chunks_of(O.bits_nbytes(k)), F.array__slots(U32, F.array__freeze(U32, ws)), 0n), 0n), k)

def blen_at(-o: O.Bits, +t: F.array__Tree<U32>, +K: U32, +eo: {o == O.Bits{F.array__thaw(U32, t), K} : O.Bits}) -> {LV.blen(o) == K : U32}:
  Equal.cong(O.Bits, U32, LV.blen, o, O.Bits{F.array__thaw(U32, t), K}, eo)

def rw_le(+a: Nat, +b: Nat, +c: Nat, +e: {a == b : Nat}, +h: {Nat.is_le(a, c) == True{} : Bool}) -> {Nat.is_le(b, c) == True{} : Bool}:
  %e : {Nat.is_le(_, c) == True{} : Bool}
  h

def le_blen(-o: O.Bits, +t: F.array__Tree<U32>, +K: U32, +cap: Nat, +eo: {o == O.Bits{F.array__thaw(U32, t), K} : O.Bits},
    +hn: {Nat.is_le(U32.to_nat(LV.blen(o)), cap) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(K), cap) == True{} : Bool}:
  %blen_at(o, t, K, eo) : {Nat.is_le(U32.to_nat(_), cap) == True{} : Bool}
  hn

def le_chunks(-o: O.Bits, +t: F.array__Tree<U32>, +K: U32, +q: Nat, +r: Nat, +L: Nat, +eo: {o == O.Bits{F.array__thaw(U32, t), K} : O.Bits},
    +enq: {U32.to_nat(O.bits_nbytes(K)) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +hc: {Nat.is_le(O.chunks_of(O.bits_nbytes(LV.blen(o))), L) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), L) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n)), 1n+q, MR.clist_len(1n+q, F.array__slots(U32, t), 0n)) :
    {Nat.is_le(_, L) == True{} : Bool}
  %WO.chunks_q(O.bits_nbytes(K), q, r, enq, h1, h32) : {Nat.is_le(_, L) == True{} : Bool}
  %blen_at(o, t, K, eo) : {Nat.is_le(O.chunks_of(O.bits_nbytes(_)), L) == True{} : Bool}
  hc

# ---- the runtime root -----------------------------------------------------------

def bst(+hl: Nat, -h: B.Buf, -o: O.Bits, +dU: U32, +seg: U32, +depth: Nat, +wf: LV.wfb(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.bits_root(hl, h, o, dU, seg) == (h, (o, bdig(hl, o, depth))) : B.Buf & (O.Bits & D.Digest)}:
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+K, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +ek) = w5
      +kz = F.u32__injective(K, 0, ek)
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        {O.bits_root(hl, h, _, dU, seg) == (h, (_, bdig(hl, _, depth))) : B.Buf & (O.Bits & D.Digest)}
      %Equal.sym(U32, K, 0, kz) :
        {O.bits_root(hl, h, O.Bits{F.array__thaw(U32, t), _}, dU, seg) == (h, (O.Bits{F.array__thaw(U32, t), _}, bdig(hl, O.Bits{F.array__thaw(U32, t), _}, depth))) : B.Buf & (O.Bits & D.Digest)}
      %Equal.sym(Nat, U32.to_nat(dU), depth, edu) :
        {O.bits_rooted(hl, 0, O.mt_words(O.bits_nbytes(0), O.mtree(_, 0n, Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(0))), hl, O.LWords{}, O.pow2n(_), 0n, O.chunks_of(O.bits_nbytes(0)), (h, (F.array__thaw(U32, t), D.zero()))))) == (h, (O.Bits{F.array__thaw(U32, t), 0}, bdig(hl, O.Bits{F.array__thaw(U32, t), 0}, depth))) : B.Buf & (O.Bits & D.Digest)}
      %Equal.sym(B.Buf & (Array<U32> & D.Digest), O.mtree(depth, 0n, False{}, hl, O.LWords{}, O.pow2n(depth), 0n, 0n, (h, (F.array__thaw(U32, t), D.zero()))), (h, (F.array__thaw(U32, t), MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))),
          MR.mt_words(depth, False{}, hl, dw, t, 0n, 0n, h, D.zero(), {==}, hd, pf, LR.zero_le(F.spec_common__pow2(dw)))) :
        {O.bits_rooted(hl, 0, O.mt_words(O.bits_nbytes(0), _)) == (h, (O.Bits{F.array__thaw(U32, t), 0}, bdig(hl, O.Bits{F.array__thaw(U32, t), 0}, depth))) : B.Buf & (O.Bits & D.Digest)}
      {==}
    case Inr{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+K, w3) = w2
      (+q, w4) = w3
      (+r, w5) = w4
      (+eo, w6) = w5
      (+pf, w7) = w6
      (+hd, w8) = w7
      (+enq, w9) = w8
      (+h1, w10) = w9
      (+h32, w11) = w10
      (+room, w12) = w11
      (+slack, w13) = w12
      (+hz, w14) = w13
      (+hbc, +hln) = w14
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        {O.bits_root(hl, h, _, dU, seg) == (h, (_, bdig(hl, _, depth))) : B.Buf & (O.Bits & D.Digest)}
      %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), O.bits_nbytes(K)}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), O.bits_nbytes(K)}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
          WR.bv_state(hl, h, dU, seg, O.bits_nbytes(K), depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd)) :
        {O.bits_rooted(hl, K, _) == (h, (O.Bits{F.array__thaw(U32, t), K}, bdig(hl, O.Bits{F.array__thaw(U32, t), K}, depth))) : B.Buf & (O.Bits & D.Digest)}
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        {(h, (O.Bits{F.array__thaw(U32, t), K}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))) == (h, (O.Bits{F.array__thaw(U32, t), K}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(K))), hl, MR.clist(O.chunks_of(O.bits_nbytes(K)), F.array__slots(U32, _), 0n), 0n), K))) : B.Buf & (O.Bits & D.Digest)}
      %Equal.sym(Nat, O.chunks_of(O.bits_nbytes(K)), 1n+q, WO.chunks_q(O.bits_nbytes(K), q, r, enq, h1, h32)) :
        {(h, (O.Bits{F.array__thaw(U32, t), K}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))) == (h, (O.Bits{F.array__thaw(U32, t), K}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n), K))) : B.Buf & (O.Bits & D.Digest)}
      {==}

# ---- the specification root ---------------------------------------------------------

def bgate(+hl: Nat, +ehl: {hl == 64n : Nat}, +cap: Nat, +depth: Nat, -o: O.Bits, +wf: LV.wfb(o),
    +hn: {Nat.is_le(U32.to_nat(LV.blen(o)), cap) == True{} : Bool},
    +hc: {Nat.is_le(O.chunks_of(O.bits_nbytes(LV.blen(o))), Bm.chunk_limit(cap)) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> {Bm.bitlist_at_depth(cap, depth, LV.bview(o)) == Some{D.bytes(bdig(hl, o, depth))} : Maybe<&2, +List<U32>>}:
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+K, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +ek) = w5
      +kz = F.u32__injective(K, 0, ek)
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        {Bm.bitlist_at_depth(cap, depth, LV.bview(_)) == Some{D.bytes(bdig(hl, _, depth))} : Maybe<&2, +List<U32>>}
      %Equal.sym(U32, K, 0, kz) :
        {Bm.bitlist_at_depth(cap, depth, LV.bview(O.Bits{F.array__thaw(U32, t), _})) == Some{D.bytes(bdig(hl, O.Bits{F.array__thaw(U32, t), _}, depth))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Nat.is_le(0n, cap), True{}, LR.zero_le(cap)) :
        {Bm.list_gate(_, cap, depth, []) == Some{D.bytes(bdig(hl, O.Bits{F.array__thaw(U32, t), 0}, depth))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Maybe<&2, +List<U32>>, Lim.at_depth(Bm.chunk_limit(cap), depth, MD.bytes_list(MR.clist(0n, F.array__slots(U32, t), 0n))), Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(MR.clist(0n, F.array__slots(U32, t), 0n))), hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n))},
          RS.at_depth_tree(Bm.chunk_limit(cap), depth, hl, MR.clist(0n, F.array__slots(U32, t), 0n), hdep, LR.zero_le(Bm.chunk_limit(cap)), ehl)) :
        {Bm.mix_length_bytes(_, Len.encoding(32n, 0n)) == Some{D.bytes(bdig(hl, O.Bits{F.array__thaw(U32, t), 0}, depth))} : Maybe<&2, +List<U32>>}
      LR.mix_bytes(hl, ehl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), 0)
    case Inr{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+K, w3) = w2
      (+q, w4) = w3
      (+r, w5) = w4
      (+eo, w6) = w5
      (+pf, w7) = w6
      (+hd, w8) = w7
      (+enq, w9) = w8
      (+h1, w10) = w9
      (+h32, w11) = w10
      (+room, w12) = w11
      (+slack, w13) = w12
      (+hz, w14) = w13
      (+hbc, +hln) = w14
      +hnK = le_blen(o, t, K, cap, eo, hn)
      +hcq = le_chunks(o, t, K, q, r, Bm.chunk_limit(cap), eo, enq, h1, h32, hc)
      %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) :
        {Bm.bitlist_at_depth(cap, depth, LV.bview(_)) == Some{D.bytes(bdig(hl, _, depth))} : Maybe<&2, +List<U32>>}
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        {Bm.bitlist_at_depth(cap, depth, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, _)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(O.bits_nbytes(K))), hl, MR.clist(O.chunks_of(O.bits_nbytes(K)), F.array__slots(U32, _), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Nat, O.chunks_of(O.bits_nbytes(K)), 1n+q, WO.chunks_q(O.bits_nbytes(K), q, r, enq, h1, h32)) :
        {Bm.bitlist_at_depth(cap, depth, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Nat, List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))), U32.to_nat(K), hln) :
        {Bm.list_gate(Nat.is_le(_, cap), cap, depth, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Nat.is_le(U32.to_nat(K), cap), True{}, hnK) :
        {Bm.list_gate(_, cap, depth, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<U32>, Bp.pack(BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))), WS.btake(Bp.byte_count(U32.to_nat(K)), FX.limbs(F.array__slots(U32, t))), BK.bpack(F.array__slots(U32, t), U32.to_nat(K), hz)) :
        {Bm.mix_length_bytes(Lim.at_depth(Bm.chunk_limit(cap), depth, Pack.scan(_, 31n, [], [])), Len.encoding(32n, List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Nat, Bp.byte_count(U32.to_nat(K)), U32.to_nat(O.bits_nbytes(K)), hbc) :
        {Bm.mix_length_bytes(Lim.at_depth(Bm.chunk_limit(cap), depth, Pack.scan(WS.btake(_, FX.limbs(F.array__slots(U32, t))), 31n, [], [])), Len.encoding(32n, List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(WS.e32(q), r), enq) :
        {Bm.mix_length_bytes(Lim.at_depth(Bm.chunk_limit(cap), depth, Pack.scan(WS.btake(_, FX.limbs(F.array__slots(U32, t))), 31n, [], [])), Len.encoding(32n, List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<+List<U32>>, Pack.scan(WS.btake(Nat.add(WS.e32(q), r), FX.limbs(F.array__slots(U32, t))), 31n, [], []), MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n)),
          WS.chunk_scan(q, r, F.array__slots(U32, t), 0n, [], h1, h32, WR_L.cap_at(q, dw, t, pf, room), slack)) :
        {Bm.mix_length_bytes(Lim.at_depth(Bm.chunk_limit(cap), depth, _), Len.encoding(32n, List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Nat, List.length(&2, Bool, BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, t)))), U32.to_nat(K), hln) :
        {Bm.mix_length_bytes(Lim.at_depth(Bm.chunk_limit(cap), depth, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), Len.encoding(32n, _)) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Maybe<&2, +List<U32>>, Lim.at_depth(Bm.chunk_limit(cap), depth, MD.bytes_list(MR.clist(1n+q, F.array__slots(U32, t), 0n))), Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n))), hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))},
          RS.at_depth_tree(Bm.chunk_limit(cap), depth, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), hdep, hcq, ehl)) :
        {Bm.mix_length_bytes(_, Len.encoding(32n, U32.to_nat(K))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Bool, Nat.is_lt(0n, MD.dlen(MR.clist(1n+q, F.array__slots(U32, t), 0n))), True{}, {==}) :
        {Bm.mix_length_bytes(Some{D.bytes(MD.rtree(depth, _, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))}, Len.encoding(32n, U32.to_nat(K))) == Some{D.bytes(O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K))} : Maybe<&2, +List<U32>>}
      LR.mix_bytes(hl, ehl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), K)

# A bit list's digest is a specification root of its bits.
def brs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Bits, +s: S.Schema, +depth: Nat, +dU: U32, +seg: U32,
    +rep: LV.rep_bits(o, s),
    +ok: {LV.ok_bits(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(S.BitsValue{LV.bview(o)}, s, [D.bytes(bdig(hl, o, depth))]):
  (+wf, +hs) = rep
  (+hn, +hc) = hs
  +ks = DK.and_l(SH.is_BitList(s), Bm.canonical_depth(SH.BitList_limit(s), depth), ok)
  +hmin = DK.and_r(SH.is_BitList(s), Bm.canonical_depth(SH.BitList_limit(s), depth), ok)
  %Equal.sym(S.Schema, s, S.BitList{SH.BitList_limit(s)}, SH.BitList_shape(s, ks)) :
    RR.roots(S.BitsValue{LV.bview(o)}, _, [D.bytes(bdig(hl, o, depth))])
  (depth, (hmin, bgate(hl, ehl, SH.BitList_limit(s), depth, o, wf, hn, hc, hdep)))

# ---- the digest as a value, from the invariant ----------------------------------------

def CFB(o: O.Bits) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(U32, K => {o == O.Bits{F.array__thaw(U32, t), K} : O.Bits}))

def bcf(-o: O.Bits, +w: LV.wfb(o)) -> CFB(o):
  match w:
    case Inl{+a}:
      (+t, +a1) = a
      (+dw, +a2) = a1
      (+K, +a3) = a2
      (+eo, +a4) = a3
      (t, (K, eo))
    case Inr{+b}:
      (+t, +b1) = b
      (+dw, +b2) = b1
      (+K, +b3) = b2
      (+q, +b4) = b3
      (+r, +b5) = b4
      (+eo, +b6) = b5
      (t, (K, eo))

def bwdc(+hl: Nat, -o: O.Bits, +d: Nat, +c: CFB(o)) -> OS.DW(bdig(hl, o, d)):
  (+t, +c1) = c
  (+K, +eo) = c1
  %Equal.sym(O.Bits, o, O.Bits{F.array__thaw(U32, t), K}, eo) : OS.DW(bdig(hl, _, d))
  (bdig(hl, O.Bits{F.array__thaw(U32, t), K}, d), {==})

def bwd(+hl: Nat, -o: O.Bits, +s: S.Schema, +d: Nat, +r: LV.rep_bits(o, s)) -> OS.DW(bdig(hl, o, d)):
  (+w, +z) = r
  bwdc(hl, o, d, bcf(o, w))
