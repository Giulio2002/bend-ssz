import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Prim
import ../src/schema.bend as I
import ../src/lists.bend as Lists
import ../spec/schema.bend as SS
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./nat_algebra.bend as A

# Positive element widths. Extracted unchanged from the positivity fragment of
# the removed list decoder's completeness proof, for the packed decoder's
# completeness proof.
def positive(width: Maybe<&2, Nat>) -> Type:
  match width:
    case None{}: Unit
    case Some{n}: {Nat.is_lt(0n, n) == True{} : Bool}
law quotient_positive:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  {Nat.is_lt(0n, Pair.fst(Nat, Nat, Nat.divmod.go(n, m, 1n+d, r))) == True{} : Bool}
def quotient_positive(n, m, d, r):
  match n:
    case 0n: {==}
    case 1n+np:
      match m:
        case 0n: quotient_positive(np, r, 1n+d, 0n)
        case 1n+mp: quotient_positive(np, mp, d, 1n+r)

law bit_bytes_positive:
  for +n: Nat
  for legal: {Nat.is_lt(0n, n) == True{} : Bool}
  {Nat.is_lt(0n, Nat.div(Nat.add(n, 7n), 8n)) == True{} : Bool}
def bit_bytes_positive(n, legal):
  match n:
    case 0n: Empty.absurd({Nat.is_lt(0n, Nat.div(Nat.add(0n, 7n), 8n)) == True{} : Bool}, W.false_true(legal))
    case 1n+p:
      %Equal.sym(Nat, Nat.add(p, 7n), Nat.add(7n, p), A.add_commute(p, 7n)) : {Nat.is_lt(0n, Nat.div(1n+_, 8n)) == True{} : Bool}
      quotient_positive(p, 7n, 0n, 0n)
law mul_positive:
  for +n: Nat
  for +w: Nat
  for a: {Nat.is_lt(0n, n) == True{} : Bool}
  for b: {Nat.is_lt(0n, w) == True{} : Bool}
  {Nat.is_lt(0n, Nat.mul(n, w)) == True{} : Bool}
def mul_positive(n, w, a, b):
  match n:
    case 0n: Empty.absurd({Nat.is_lt(0n, Nat.mul(0n, w)) == True{} : Bool}, W.false_true(a))
    case 1n+p:
      match w:
        case 0n: Empty.absurd({Nat.is_lt(0n, Nat.mul(1n+p, 0n)) == True{} : Bool}, W.false_true(b))
        case 1n+q: {==}
law times_positive:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  for legal: {Nat.is_lt(0n, n) == True{} : Bool}
  for inner: positive(width)
  positive(SS.times(n, width))
def times_positive(n, width, legal, inner):
  match width:
    case None{}: Unit{}
    case Some{w}: mul_positive(n, w, legal, inner)
law add_positive:
  for +x: Nat
  for +y: Nat
  for inner: {Nat.is_lt(0n, x) == True{} : Bool}
  {Nat.is_lt(0n, Nat.add(x, y)) == True{} : Bool}
def add_positive(x, y, inner):
  match x:
    case 0n: Empty.absurd({Nat.is_lt(0n, Nat.add(0n, y)) == True{} : Bool}, W.false_true(inner))
    case 1n+p: {==}
law sum_positive:
  for +a: Maybe<&2, Nat>
  for +b: Maybe<&2, Nat>
  for inner: positive(a)
  positive(SS.sum(a, b))
def sum_positive(a, b, inner):
  match a b:
    case None{} _: Unit{}
    case Some{x} None{}: Unit{}
    case Some{x} Some{y}: add_positive(x, y, inner)
law width_positive:
  for +schema: T.Schema
  for +legal: {I.valid_go(schema, False{}) == True{} : Bool}
  positive(SS.fixed_size(schema))
def width_positive(schema, legal):
  match schema:
    case T.Boolean{}: {==}
    case T.Unsigned{s0}:
      match s0:
        case Prim.U8{}: {==}
        case Prim.U16{}: {==}
        case Prim.U32Width{}: {==}
        case Prim.U64{}: {==}
        case Prim.U128{}: {==}
        case Prim.U256{}: {==}
    case T.ByteVector{s0}: legal
    case T.ByteList{s0}: Unit{}
    case T.BitVector{s0}: bit_bytes_positive(s0, legal)
    case T.BitList{s0}: Unit{}
    case T.Vector{s0, s1}: times_positive(s1, SS.fixed_size(s0), V.and_left(Nat.is_lt(0n, s1), I.valid_go(s0, False{}), legal), width_positive(s0, V.and_right(Nat.is_lt(0n, s1), I.valid_go(s0, False{}), legal)))
    case T.ListOf{s0, s1}: Unit{}
    case T.Container{s0, s1}:
      match s1:
        case T.Boolean{}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.Boolean{}})), W.false_true(V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Boolean{})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Boolean{})), I.unique_names(s0))), I.valid_go(T.Boolean{}, True{}), legal)))
        case T.Unsigned{f0}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.Unsigned{f0}})), W.false_true(V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Unsigned{f0})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Unsigned{f0})), I.unique_names(s0))), I.valid_go(T.Unsigned{f0}, True{}), legal)))
        case T.ByteVector{f0}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.ByteVector{f0}})), W.false_true(V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.ByteVector{f0})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.ByteVector{f0})), I.unique_names(s0))), I.valid_go(T.ByteVector{f0}, True{}), legal)))
        case T.ByteList{f0}: Unit{}
        case T.BitVector{f0}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.BitVector{f0}})), W.false_true(V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.BitVector{f0})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.BitVector{f0})), I.unique_names(s0))), I.valid_go(T.BitVector{f0}, True{}), legal)))
        case T.BitList{f0}: Unit{}
        case T.Vector{f0, f1}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.Vector{f0, f1}})), W.false_true(V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Vector{f0, f1})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Vector{f0, f1})), I.unique_names(s0))), I.valid_go(T.Vector{f0, f1}, True{}), legal)))
        case T.ListOf{f0, f1}: Unit{}
        case T.Container{f0, f1}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.Container{f0, f1}})), W.false_true(V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Container{f0, f1})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Container{f0, f1})), I.unique_names(s0))), I.valid_go(T.Container{f0, f1}, True{}), legal)))
        case T.Union{f0}: Unit{}
        case T.Null{}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.Null{}})), W.false_true(V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Null{})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Null{})), I.unique_names(s0))), I.valid_go(T.Null{}, True{}), legal)))
        case T.Chain{f0, f1}: sum_positive(SS.fixed_size(f0), SS.fixed_size(f1), width_positive(f0, V.and_left(I.valid_go(f0, False{}), I.valid_go(f1, True{}), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Chain{f0, f1})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Chain{f0, f1})), I.unique_names(s0))), I.valid_go(T.Chain{f0, f1}, True{}), legal))))
        case T.End{}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.End{}})), W.false_true(V.and_left(Nat.is_lt(0n, I.count(T.End{})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.End{})), I.unique_names(s0)), V.and_left(Bool.and(Nat.is_lt(0n, I.count(T.End{})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.End{})), I.unique_names(s0))), I.valid_go(T.End{}, True{}), legal))))
        case T.Repeat{f0}: Unit{}
        case T.Named{f0, f1}: Unit{}
        case T.ProgressiveList{f0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{f0, f1, f2}: Empty.absurd(positive(SS.fixed_size(T.Container{s0, T.ProgressiveContainer{f0, f1, f2}})), W.false_true(V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.ProgressiveContainer{f0, f1, f2})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.ProgressiveContainer{f0, f1, f2})), I.unique_names(s0))), I.valid_go(T.ProgressiveContainer{f0, f1, f2}, True{}), legal)))
        case T.CompatibleUnion{f0, f1}: Unit{}
    case T.Union{s0}: Unit{}
    case T.Null{}: Empty.absurd(positive(SS.fixed_size(T.Null{})), W.false_true(legal))
    case T.Chain{s0, s1}: Empty.absurd(positive(SS.fixed_size(T.Chain{s0, s1})), W.false_true(legal))
    case T.End{}: Empty.absurd(positive(SS.fixed_size(T.End{})), W.false_true(legal))
    case T.Repeat{s0}: Unit{}
    case T.Named{s0, s1}: Unit{}
    case T.ProgressiveList{s0}: Unit{}
    case T.ProgressiveBits{}: Unit{}
    case T.ProgressiveContainer{s0, s1, s2}:
      match s1:
        case T.Boolean{}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.Boolean{}, s2})), W.false_true(V.and_left(I.valid_go(T.Boolean{}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Boolean{})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Boolean{})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Boolean{})), I.unique_names(s0))), Bool.and(I.valid_go(T.Boolean{}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Boolean{}))))), legal))))
        case T.Unsigned{f0}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.Unsigned{f0}, s2})), W.false_true(V.and_left(I.valid_go(T.Unsigned{f0}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Unsigned{f0})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Unsigned{f0})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Unsigned{f0})), I.unique_names(s0))), Bool.and(I.valid_go(T.Unsigned{f0}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Unsigned{f0}))))), legal))))
        case T.ByteVector{f0}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.ByteVector{f0}, s2})), W.false_true(V.and_left(I.valid_go(T.ByteVector{f0}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.ByteVector{f0})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.ByteVector{f0})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.ByteVector{f0})), I.unique_names(s0))), Bool.and(I.valid_go(T.ByteVector{f0}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.ByteVector{f0}))))), legal))))
        case T.ByteList{f0}: Unit{}
        case T.BitVector{f0}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.BitVector{f0}, s2})), W.false_true(V.and_left(I.valid_go(T.BitVector{f0}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.BitVector{f0})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.BitVector{f0})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.BitVector{f0})), I.unique_names(s0))), Bool.and(I.valid_go(T.BitVector{f0}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.BitVector{f0}))))), legal))))
        case T.BitList{f0}: Unit{}
        case T.Vector{f0, f1}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.Vector{f0, f1}, s2})), W.false_true(V.and_left(I.valid_go(T.Vector{f0, f1}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Vector{f0, f1})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Vector{f0, f1})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Vector{f0, f1})), I.unique_names(s0))), Bool.and(I.valid_go(T.Vector{f0, f1}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Vector{f0, f1}))))), legal))))
        case T.ListOf{f0, f1}: Unit{}
        case T.Container{f0, f1}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.Container{f0, f1}, s2})), W.false_true(V.and_left(I.valid_go(T.Container{f0, f1}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Container{f0, f1})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Container{f0, f1})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Container{f0, f1})), I.unique_names(s0))), Bool.and(I.valid_go(T.Container{f0, f1}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Container{f0, f1}))))), legal))))
        case T.Union{f0}: Unit{}
        case T.Null{}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.Null{}, s2})), W.false_true(V.and_left(I.valid_go(T.Null{}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Null{})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Null{})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Null{})), I.unique_names(s0))), Bool.and(I.valid_go(T.Null{}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Null{}))))), legal))))
        case T.Chain{f0, f1}: sum_positive(SS.fixed_size(f0), SS.fixed_size(f1), width_positive(f0, V.and_left(I.valid_go(f0, False{}), I.valid_go(f1, True{}), V.and_left(I.valid_go(T.Chain{f0, f1}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Chain{f0, f1})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.Chain{f0, f1})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.Chain{f0, f1})), I.unique_names(s0))), Bool.and(I.valid_go(T.Chain{f0, f1}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.Chain{f0, f1}))))), legal)))))
        case T.End{}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.End{}, s2})), W.false_true(V.and_left(Nat.is_lt(0n, I.count(T.End{})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.End{})), I.unique_names(s0)), V.and_left(Bool.and(Nat.is_lt(0n, I.count(T.End{})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.End{})), I.unique_names(s0))), Bool.and(I.valid_go(T.End{}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.End{}))))), legal))))
        case T.Repeat{f0}: Unit{}
        case T.Named{f0, f1}: Unit{}
        case T.ProgressiveList{f0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{f0, f1, f2}: Empty.absurd(positive(SS.fixed_size(T.ProgressiveContainer{s0, T.ProgressiveContainer{f0, f1, f2}, s2})), W.false_true(V.and_left(I.valid_go(T.ProgressiveContainer{f0, f1, f2}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.ProgressiveContainer{f0, f1, f2})))), V.and_right(Bool.and(Nat.is_lt(0n, I.count(T.ProgressiveContainer{f0, f1, f2})), Bool.and(Nat.is_eq(Lists.length(String, s0), I.count(T.ProgressiveContainer{f0, f1, f2})), I.unique_names(s0))), Bool.and(I.valid_go(T.ProgressiveContainer{f0, f1, f2}, True{}), Bool.and(Nat.is_le(Lists.length(Bool, s2), 256n), Bool.and(I.ends_active(s2, False{}), Nat.is_eq(I.active_count(s2, 0n), I.count(T.ProgressiveContainer{f0, f1, f2}))))), legal))))
        case T.CompatibleUnion{f0, f1}: Unit{}
    case T.CompatibleUnion{s0, s1}: Unit{}


# Reading a positive width as either a positive fixed size or a variable one.
law width_elim:
  for -G: Type
  for +w: Maybe<&2, Nat>
  for pos: positive(w)
  for k1: @+q: Nat -> {w == Some{1n+q} : Maybe<&2, Nat>} -> G
  for k2: {w == None{} : Maybe<&2, Nat>} -> G
  G
def width_elim(G, w, pos, k1, k2):
  match w:
    case None{}: k2({==})
    case Some{q}:
      match q:
        case 0n: Empty.absurd(G, W.false_true(pos))
        case 1n+r: k1(r, {==})
