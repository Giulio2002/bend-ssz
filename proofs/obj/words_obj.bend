import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/limits.bend as Lim
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./words_spec.bend as WS
import ./words_root.bend as WR
import ./schema_shapes.bend as SH
import ./dk.bend as DK

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

def len(o: O.Words) -> U32:
  match o:
    case O.Words{ws, +n}: n

# The bytes of the object: the first len(o) bytes of its words.
def wview(o: O.Words) -> +List<U32>:
  match o:
    case O.Words{ws, +n}: WR.view(F.array__freeze(U32, ws), n)

# The representation invariant of nonempty byte storage: the array is a perfect
# tree t of depth dw < 32 with room for the chunks, the length N is 32q + r with
# 1 <= r <= 32, and the bytes after N up to the chunk boundary are zero.
def wf1(o: O.Words) -> Data:
  DK.Ex(F.array__Tree<U32>, t => DK.Ex(Nat, dw => DK.Ex(U32, N => DK.Ex(Nat, q => DK.Ex(Nat, r =>
    DK.P2({o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    DK.P2({F.array__perfect(U32, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    DK.P2({Nat.is_lt(0n, r) == True{} : Bool},
    DK.P2({Nat.is_le(r, 32n) == True{} : Bool},
    DK.P2({Nat.is_le(O.e8(1n+q), F.spec_common__pow2(dw)) == True{} : Bool},
          {WS.bdrop(r, WS.cb(F.array__slots(U32, t), Nat.add(q, 0n))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>}))))))))))))

# Two equations as one, so a law can move all its variables to their closed
# values in a single rewrite (the closed goal is then evaluated by {==}).
law pair_eq:
  for -A: Data
  for -B: Data
  for -a: A
  for -x: A
  for -b: B
  for -y: B
  for ea: {a == x : A}
  for eb: {b == y : B}
  {(a, b) == (x, y) : A & B}
def pair_eq(A, B, a, x, b, y, ea, eb):
  %Equal.sym(A, a, x, ea) : {(_, b) == (x, y) : A & B}
  %Equal.sym(B, b, y, eb) : {(x, _) == (x, y) : A & B}
  {==}

def minimal_view(+N: U32, +depth: Nat, +q: Nat, +r: Nat,
    +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat},
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +hmin: {Lim.minimal(O.chunks_of(N), depth) == True{} : Bool})
    -> {Lim.minimal(1n+q, depth) == True{} : Bool}:
  %WS.chunks_count(q, r, h1, h32) :
    {Lim.minimal(_, depth) == True{} : Bool}
  %enq :
    {Lim.minimal(Nat.div(Nat.add(_, 31n), 32n), depth) == True{} : Bool}
  hmin

def eq_len(-o: O.Words, +t: F.array__Tree<U32>, +N: U32, +n: Nat, +eo: {o == O.Words{F.array__thaw(U32, t), N} : O.Words},
    +ns: {Nat.is_eq(U32.to_nat(len(o)), n) == True{} : Bool}) -> {Nat.is_eq(U32.to_nat(N), n) == True{} : Bool}:
  %Equal.cong(O.Words, U32, len, o, O.Words{F.array__thaw(U32, t), N}, eo) : {Nat.is_eq(U32.to_nat(_), n) == True{} : Bool}
  ns

def min_n(+N: U32, +n: Nat, +depth: Nat, +eN: {U32.to_nat(N) == n : Nat},
    +hm: {Lim.minimal(Nat.div(Nat.add(n, 31n), 32n), depth) == True{} : Bool}) -> {Lim.minimal(O.chunks_of(N), depth) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(N), n, eN) : {Lim.minimal(Nat.div(Nat.add(_, 31n), 32n), depth) == True{} : Bool}
  hm

# The runtime root of nonempty byte storage hands back the hasher and the
# object, with the digest it computed.
def bv_eta(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: wf1(o), +edu: {U32.to_nat(dU) == depth : Nat})
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

# The object represents a value of the byte vector schema s.
def rep_bv(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wf1(o), {Nat.is_eq(U32.to_nat(len(o)), SH.ByteVector_length(s)) == True{} : Bool})

# The schema is a byte vector whose chunk count has minimal depth `depth`.
def ok_bv(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_ByteVector(s), Lim.minimal(Nat.div(Nat.add(SH.ByteVector_length(s), 31n), 32n), depth))

def bv_body(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +n: Nat, -o: O.Words, +depth: Nat,
    +wf: wf1(o),
    +ns: {Nat.is_eq(U32.to_nat(len(o)), n) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hm: {Lim.minimal(Nat.div(Nat.add(n, 31n), 32n), depth) == True{} : Bool},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{wview(o)}, S.ByteVector{n}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))]):
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
  +eN = WS.nat_eq(U32.to_nat(N), n, eq_len(o, t, N, n, eo, ns))
  %eN :
    RR.roots(S.BytesValue{wview(o)}, S.ByteVector{_}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, eo) :
    RR.roots(S.BytesValue{wview(_)}, S.ByteVector{U32.to_nat(N)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, _, dU, seg))))])
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    RR.roots(S.BytesValue{WR.view(_, N)}, S.ByteVector{U32.to_nat(N)}, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg))))])
  WR.bv_full(hl, h, dU, seg, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd, minimal_view(N, depth, q, r, enq, h1, h32, min_n(N, n, depth, eN, hm)), hdep, ehl)

# A byte vector: for any byte vector schema the object represents, the runtime
# root (O.words_root at the depth of the chunk count) is a specification root
# of the object's bytes.
def bv_gen(+hl: Nat, -h: B.Buf, +dU: U32, +seg: U32, +s: S.Schema, -o: O.Words, +depth: Nat,
    +rep: rep_bv(o, s),
    +ok: {ok_bv(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool}, +ehl: {hl == 64n : Nat})
    -> RR.roots(S.BytesValue{wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))]):
  (+wf, +ns) = rep
  +ks = DK.and_l(SH.is_ByteVector(s), Lim.minimal(Nat.div(Nat.add(SH.ByteVector_length(s), 31n), 32n), depth), ok)
  +hm = DK.and_r(SH.is_ByteVector(s), Lim.minimal(Nat.div(Nat.add(SH.ByteVector_length(s), 31n), 32n), depth), ok)
  %Equal.sym(S.Schema, s, S.ByteVector{SH.ByteVector_length(s)}, SH.ByteVector_shape(s, ks)) :
    RR.roots(S.BytesValue{wview(o)}, _, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, O.words_root(hl, h, o, dU, seg))))])
  bv_body(hl, h, dU, seg, SH.ByteVector_length(s), o, depth, wf, ns, edu, hm, hdep, ehl)

# ---- the digest as a function of the object ------------------------------------

# The reference tree over the object's chunk digests at `depth`: the digest the
# runtime computes (bv_st), written without the hasher, so that a container's
# digest is a function of its fields.
def wdig(+hl: Nat, o: O.Words, +depth: Nat) -> D.Digest:
  match o:
    case O.Words{ws, +n}: MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(n)), hl, MR.clist(O.chunks_of(n), F.array__slots(U32, F.array__freeze(U32, ws)), 0n), 0n)

law chunks_q:
  for +N: U32
  for +q: Nat
  for +r: Nat
  for +enq: {U32.to_nat(N) == Nat.add(WS.e32(q), r) : Nat}
  for +h1: {Nat.is_lt(0n, r) == True{} : Bool}
  for +h32: {Nat.is_le(r, 32n) == True{} : Bool}
  {O.chunks_of(N) == 1n+q : Nat}
def chunks_q(N, q, r, enq, h1, h32):
  %WS.chunks_count(q, r, h1, h32) : {O.chunks_of(N) == _ : Nat}
  %Equal.sym(Nat, U32.to_nat(N), Nat.add(WS.e32(q), r), enq) :
    {Nat.div(Nat.add(_, 31n), 32n) == Nat.div(Nat.add(Nat.add(WS.e32(q), r), 31n), 32n) : Nat}
  {==}

def bv_st(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32, +depth: Nat, +wf: wf1(o), +edu: {U32.to_nat(dU) == depth : Nat})
    -> {O.words_root(hl, h, o, dU, seg) == (h, (o, wdig(hl, o, depth))) : B.Buf & (O.Words & D.Digest)}:
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
    {O.words_root(hl, h, _, dU, seg) == (h, (_, wdig(hl, _, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(hl, h, O.Words{F.array__thaw(U32, t), N}, dU, seg), (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))),
      WR.bv_state(hl, h, dU, seg, N, depth, q, r, dw, t, enq, h1, h32, pf, room, slack, edu, hd)) :
    {_ == (h, (O.Words{F.array__thaw(U32, t), N}, wdig(hl, O.Words{F.array__thaw(U32, t), N}, depth))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) :
    {(h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, Nat.is_lt(0n, O.chunks_of(N)), hl, MR.clist(O.chunks_of(N), F.array__slots(U32, _), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  %Equal.sym(Nat, O.chunks_of(N), 1n+q, chunks_q(N, q, r, enq, h1, h32)) :
    {(h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, True{}, hl, MR.clist(1n+q, F.array__slots(U32, t), 0n), 0n))) == (h, (O.Words{F.array__thaw(U32, t), N}, MD.rtree(depth, Nat.is_lt(0n, _), hl, MR.clist(_, F.array__slots(U32, t), 0n), 0n))) : B.Buf & (O.Words & D.Digest)}
  {==}

# A byte vector's digest is a specification root of its bytes.
def bv_rs(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Words, +s: S.Schema, +depth: Nat, +dU: U32, +seg: U32,
    +rep: rep_bv(o, s),
    +ok: {ok_bv(s, depth) == True{} : Bool},
    +edu: {U32.to_nat(dU) == depth : Nat},
    +hdep: {Nat.is_lt(depth, 64n) == True{} : Bool})
    -> RR.roots(S.BytesValue{wview(o)}, s, [D.bytes(wdig(hl, o, depth))]):
  (+wf, +ns) = rep
  %bv_st(hl, h, o, dU, seg, depth, wf, edu) :
    RR.roots(S.BytesValue{wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  bv_gen(hl, h, dU, seg, s, o, depth, rep, ok, edu, hdep, ehl)

def rep_wf(-o: O.Words, +s: S.Schema, +rep: rep_bv(o, s)) -> wf1(o):
  (+w, +n) = rep
  w
