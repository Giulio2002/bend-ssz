import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/limits.bend as Lim
import ../compact/found_generated.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./words_root_light.bend as WR_L
import ./schema_shapes_generated.bend as SH
import ./dk.bend as DK
import ./words_obj_light.bend as LV

# Byte storage (O.Words) as an object: its view, its representation invariant,
# its root as a pair (hasher, (object, digest)), and that digest against a
# specification schema that is a variable.
#
# Why a schema variable. The checker compares terms by weak-head evaluation and
# stops early only on pointer-identical terms, so two separately built copies
# of a large closed number (a schema size like U32.to_nat(131072)) are compared
# by unfolding both into unary digits, one stack frame per unit. The laws below
# therefore never compare the specification's sizes: a law takes the schema as
# a variable `s` (a per-name law adds `s == Spec.Name()`), the object's facts
# are stated relative to `s` (`rep_bv(o, s)`: its length is the schema's
# length), and the schema's own facts are one closed Bool (`ok_bv(s, depth)`),
# which the checker evaluates iteratively once `s` is replaced by its value.

# The runtime root of nonempty byte storage hands back the hasher and the
# object, with the digest it computed.
def bv_eta(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: LV.wf1(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.words_root(hl, h, o, dU, seg) == (h, (o, Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))) : B.Buf & (O.Words & D.Digest)}:
  (+t, w1) = wf
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
    {O.words_root(hl, h, _, dU, seg) == (h, (_, Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, _, dU, seg))))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
      WR.bv_state(hl, h, dU, seg, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd)) :
    {_ == (h, (O.Words{F.array__thaw(U32, t), N}, Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))) : B.Buf & (O.Words & D.Digest)}
  {==}

# ---- byte vectors ------------------------------------------------------------

def bv_body(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +n: Nat, -o: O.Words, +depth: Nat,
    +wf: LV.wf1(o),
    +ns: {Nat.is_eq(U32.to_nat(LV.len(o)), n) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hm: {Lim.minimal(Nat.div(Nat.add(n, 31n), 32n), depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{LV.wview(o)}, S.ByteVector{n}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))]):
  (+t, w1) = wf
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
  +eN = WS.nat_eq(U32.to_nat(N), n, LV.eq_len(o, t, N, n, eo, ns))
  %eN :
    RR.roots(S.BytesValue{LV.wview(o)}, S.ByteVector{_}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    RR.roots(S.BytesValue{LV.wview(_)}, S.ByteVector{U32.to_nat(N)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, _, dU, seg))))])
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    RR.roots(S.BytesValue{WR_L.view(_, N)}, S.ByteVector{U32.to_nat(N)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg))))])
  WR.bv_full(hl, h, dU, seg, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd, LV.minimal_view(N, depth, q, r, enq, h1, h32, LV.min_n(N, n, depth, eN, hm)), hdep, ehl)

# A byte vector: for any byte vector schema the object represents, the runtime
# root (O.words_root at the depth of the chunk count) is a specification root
# of the object's bytes.
def bv_gen(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +s: S.Schema, -o: O.Words, +depth: Nat,
    +rep: LV.rep_bv(o, s),
    +ok: {LV.ok_bv(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{LV.wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))]):
  (+wf, +ns) = rep
  +ks = DK.and_l(SH.is_ByteVector(s), Lim.minimal(Nat.div(Nat.add(SH.ByteVector_length(s), 31n), 32n), depth), ok)
  +hm = DK.and_r(SH.is_ByteVector(s), Lim.minimal(Nat.div(Nat.add(SH.ByteVector_length(s), 31n), 32n), depth), ok)
  %Equal.sym(S.Schema, s, S.ByteVector{SH.ByteVector_length(s)}, SH.ByteVector_shape(s, ks)) :
    RR.roots(S.BytesValue{LV.wview(o)}, _, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  bv_body(hl, h, dU, seg, SH.ByteVector_length(s), o, depth, wf, ns, edu, hm, hdep, ehl)

# ---- the digest as a function of the object ------------------------------------

def bv_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: LV.wf1(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.words_root(hl, h, o, dU, seg) == (h, (o, LV.wdig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
  (+t, w1) = wf
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
    {O.words_root(hl, h, _, dU, seg) == (h, (_, LV.wdig(hl, _, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
      WR.bv_state(hl, h, dU, seg, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd)) :
    {_ == (h, (O.Words{F.array__thaw(U32, t), N}, LV.wdig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {(h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, O.chunks_of(N), 1n+q, LV.chunks_q(N, q, r, enq, h1, h32)) :
    {(h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  {==}

# A byte vector's digest is a specification root of its bytes.
def bv_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat, +dU: U32, +seg: U32,
    +rep: LV.rep_bv(o, s),
    +ok: {LV.ok_bv(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(S.BytesValue{LV.wview(o)}, s, [D.bytes(LV.wdig(hl, o, depth))]):
  (+wf, +ns) = rep
  %bv_st(hl, h, o, dU, seg, depth, wf, edu) :
    RR.roots(S.BytesValue{LV.wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  bv_gen(hl, h, dU, seg, s, o, depth, rep, ok, edu, hdep, ehl)

def rep_wf(-o: O.Words, +s: S.Schema, +rep: LV.rep_bv(o, s)) -> LV.wf1(o):
  (+w, +n) = rep
  w
