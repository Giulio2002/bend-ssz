import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/primitives.bend as SP
import ../../spec/limits.bend as Lim
import ../compact/found_generated.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./words_spec.bend as WS
import ./words_root_light.bend as WR
import ./schema_shapes_generated.bend as SH
import ./dk.bend as DK

# The definitions of words_obj.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

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

# The object represents a value of the byte vector schema s.
def rep_bv(o: O.Words, +s: S.Schema) -> Data:
  DK.P2(wf1(o), {Nat.is_eq(U32.to_nat(len(o)), SH.ByteVector_length(s)) == True{} : Bool})

# The schema is a byte vector whose chunk count has minimal depth `depth`.
def ok_bv(+s: S.Schema, +depth: Nat) -> Bool:
  Bool.and(SH.is_ByteVector(s), Lim.minimal(Nat.div(Nat.add(SH.ByteVector_length(s), 31n), 32n), depth))

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
