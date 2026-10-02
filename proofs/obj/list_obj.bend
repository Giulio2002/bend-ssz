import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/byte_list.bend as BL
import ../../spec/limits.bend as Lim
import ../compact/found_generated.bend as F
import ./words_spec.bend as WS
import ./words_root_light.bend as WR
import ./words_obj_light.bend as WO
import ./list_root.bend as LR
import ./nat_facts.bend as NF
import ./schema_shapes_generated.bend as SH
import ./dk.bend as DK
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ../../spec/primitives.bend as SP
import ./list_obj_light.bend as LV

# Byte lists as objects (see proofs/obj/words_obj.bend for the object form and
# why the schema is a variable).

# The runtime root of a byte list (data tree and length) hands back the hasher
# and the object, with the digest it computed.
def bl_eta(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: LV.wfl(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.mix_count(hl, 0n, O.words_root(hl, h, o, dU, seg)) == (h, (o, Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, o, dU, seg)))))) : B.Buf & (O.Words & D.Digest)}:
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +en0) = w5
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {O.mix_count(hl, 0n, O.words_root(hl, h, _, dU, seg)) == (h, (_, Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, _, dU, seg)))))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)), (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))),
          LR.bl0_state(hl, h, dU, seg, N, depth, dw, t, en0, pf, edu, hd)) :
        {_ == (h, (O.Words{F.array__thaw(U32, t), N}, Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))) : B.Buf & (O.Words & D.Digest)}
      {==}
    case Inr{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+q, w4) = w3
      (+r, w5) = w4
      (+eo, w6) = w5
      (+pf, w7) = w6
      (+hd, w8) = w7
      (+enq, w9) = w8
      (+h1, w10) = w9
      (+h32, w11) = w10
      (+room, +slack) = w11
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {O.mix_count(hl, 0n, O.words_root(hl, h, _, dU, seg)) == (h, (_, Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, _, dU, seg)))))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)), (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))),
          LR.bl_state(hl, h, dU, seg, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd)) :
        {_ == (h, (O.Words{F.array__thaw(U32, t), N}, Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))) : B.Buf & (O.Words & D.Digest)}
      {==}

def le_len(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +cap: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +hn: {Nat.is_le(U32.to_nat(WO.len(o)), cap) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(N), cap) == True{} : Bool}:
  %Equal.cong(O.Words, U32, WO.len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_le(U32.to_nat(_), cap) == True{} : Bool}
  hn

def rw_le(+a: Nat, +b: Nat, +cap: Nat, +e: {a == b : Nat}, +h: {Nat.is_le(a, cap) == True{} : Bool}) -> {Nat.is_le(b, cap) == True{} : Bool}:
  %e : {Nat.is_le(_, cap) == True{} : Bool}
  h

def bl_body(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +cap: Nat, -o: O.Words, +depth: Nat,
    +wf: LV.wfl(o),
    +hn: {Nat.is_le(U32.to_nat(WO.len(o)), cap) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hmin: {Lim.minimal(BL.chunk_limit(cap), depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{WO.wview(o)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, o, dU, seg)))))]):
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +en0) = w5
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        RR.roots(S.BytesValue{WO.wview(_)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, _, dU, seg)))))])
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        RR.roots(S.BytesValue{WR.view(_, N)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)))))])
      LR.bl0_full(hl, h, dU, seg, cap, N, depth, dw, t, en0, pf, edu, hd, hmin, hdep, ehl)
    case Inr{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+q, w4) = w3
      (+r, w5) = w4
      (+eo, w6) = w5
      (+pf, w7) = w6
      (+hd, w8) = w7
      (+enq, w9) = w8
      (+h1, w10) = w9
      (+h32, w11) = w10
      (+room, +slack) = w11
      +hnN = le_len(o, t, N, cap, eo, hn)
      +hnq = rw_le(U32.to_nat(N), Nat.add(WS.e32(q), r), cap, enq, hnN)
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        RR.roots(S.BytesValue{WO.wview(_)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, _, dU, seg)))))])
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        RR.roots(S.BytesValue{WR.view(_, N)}, S.ByteList{cap}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)))))])
      LR.bl_full(hl, h, dU, seg, cap, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd, hnq, NF.chunk_le(q, r, cap, h1, h32, hnq), hmin, hdep, ehl)

# A byte list of any length within its capacity: the runtime root (the data
# tree with the length mixed in) is a specification root of the object's bytes.
def bl_gen(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +s: S.Schema, -o: O.Words, +depth: Nat,
    +rep: LV.rep_bl(o, s),
    +ok: {LV.ok_bl(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{WO.wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, o, dU, seg)))))]):
  (+wf, +hn) = rep
  +ks = DK.and_l(SH.is_ByteList(s), Lim.minimal(BL.chunk_limit(SH.ByteList_limit(s)), depth), ok)
  +hmin = DK.and_r(SH.is_ByteList(s), Lim.minimal(BL.chunk_limit(SH.ByteList_limit(s)), depth), ok)
  %Equal.sym(S.Schema, s, S.ByteList{SH.ByteList_limit(s)}, SH.ByteList_shape(s, ks)) :
    RR.roots(S.BytesValue{WO.wview(o)}, _, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.mix_count(hl, 0n, O.words_root(hl, h, o, dU, seg)))))])
  bl_body(hl, h, dU, seg, SH.ByteList_limit(s), o, depth, wf, hn, edu, hmin, hdep, ehl)

# ---- the digest as a function of the object ------------------------------------

def ldig(+hl: Nat, o: O.Words, +depth: Nat) -> D.Digest:
  match o:
    case O.Words{ws, +n}: O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(n)), hl, MR.clist(O.chunks_of(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n), 0n), n)

def bl_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: LV.wfl(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.mix_count(hl, 0n, O.words_root(hl, h, o, dU, seg)) == (h, (o, ldig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
  match wf:
    case Inl{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+eo, w4) = w3
      (+pf, w5) = w4
      (+hd, +en0) = w5
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {O.mix_count(hl, 0n, O.words_root(hl, h, _, dU, seg)) == (h, (_, ldig(hl, _, depth))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)), (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))),
          LR.bl0_state(hl, h, dU, seg, N, depth, dw, t, en0, pf, edu, hd)) :
        {_ == (h, (O.Words{F.array__thaw(U32, t), N}, ldig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(Nat, U32.to_nat(N), 0n, en0) :
        {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, False{}, hl, MR.clist(0n, F.array__slots(U32, t), 0n), 0n), N))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, Nat.div(Nat.add(_, 31n), 32n)), hl, MR.clist(Nat.div(Nat.add(_, 31n), 32n), F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
      {==}
    case Inr{w}:
      (+t, w1) = w
      (+dw, w2) = w1
      (+N, w3) = w2
      (+q, w4) = w3
      (+r, w5) = w4
      (+eo, w6) = w5
      (+pf, w7) = w6
      (+hd, w8) = w7
      (+enq, w9) = w8
      (+h1, w10) = w9
      (+h32, w11) = w10
      (+room, +slack) = w11
      %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
        {O.mix_count(hl, 0n, O.words_root(hl, h, _, dU, seg)) == (h, (_, ldig(hl, _, depth))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(hl, 0n, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg)), (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))),
          LR.bl_state(hl, h, dU, seg, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd)) :
        {_ == (h, (O.Words{F.array__thaw(U32, t), N}, ldig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
        {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
      %Equal.sym(Nat, O.chunks_of(N), 1n+q, WO.chunks_q(N, q, r, enq, h1, h32)) :
        {(h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n), N))) == (h, (O.Words{F.array__thaw(U32, t), N}, O.mix_len(hl, MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n), N))) : B.Buf & (O.Words & D.Digest)}
      {==}

# A byte list's digest is a specification root of its bytes.
def bl_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat, +dU: U32, +seg: U32,
    +rep: LV.rep_bl(o, s),
    +ok: {LV.ok_bl(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(S.BytesValue{WO.wview(o)}, s, [D.bytes(ldig(hl, o, depth))]):
  (+wf, +hn) = rep
  %bl_st(hl, h, o, dU, seg, depth, wf, edu) :
    RR.roots(S.BytesValue{WO.wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  bl_gen(hl, h, dU, seg, s, o, depth, rep, ok, edu, hdep, ehl)
