import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/lists.bend as Lists
import ./lists.bend as L
import ./nat_order.bend as Order

law fields_bounded_by_weight:
  for +schema: T.Schema
  {Nat.is_le(I.count(schema), I.weight(schema)) == True{} : Bool}
def fields_bounded_by_weight(schema):
  match schema:
    case T.Boolean{}: Order.zero_le(I.weight(T.Boolean{}))
    case T.Unsigned{x0}: Order.zero_le(I.weight(T.Unsigned{x0}))
    case T.ByteVector{x0}: Order.zero_le(I.weight(T.ByteVector{x0}))
    case T.ByteList{x0}: Order.zero_le(I.weight(T.ByteList{x0}))
    case T.BitVector{x0}: Order.zero_le(I.weight(T.BitVector{x0}))
    case T.BitList{x0}: Order.zero_le(I.weight(T.BitList{x0}))
    case T.Vector{x0, x1}: Order.zero_le(I.weight(T.Vector{x0, x1}))
    case T.ListOf{x0, x1}: Order.zero_le(I.weight(T.ListOf{x0, x1}))
    case T.Container{x0, x1}: Order.zero_le(I.weight(T.Container{x0, x1}))
    case T.Union{x0}: Order.zero_le(I.weight(T.Union{x0}))
    case T.Null{}: Order.zero_le(I.weight(T.Null{}))
    case T.Chain{x0, x1}: Order.transitive(I.count(x1), I.weight(x1), Nat.add(I.weight(x0), I.weight(x1)), fields_bounded_by_weight(x1), Order.left_below_sum(I.weight(x0), I.weight(x1)))
    case T.End{}: Order.zero_le(I.weight(T.End{}))
    case T.Repeat{x0}: Order.zero_le(I.weight(T.Repeat{x0}))
    case T.Named{x0, x1}: Order.zero_le(I.weight(T.Named{x0, x1}))
    case T.ProgressiveList{x0}: Order.zero_le(I.weight(T.ProgressiveList{x0}))
    case T.ProgressiveBits{}: Order.zero_le(I.weight(T.ProgressiveBits{}))
    case T.ProgressiveContainer{x0, x1, x2}: Order.zero_le(I.weight(T.ProgressiveContainer{x0, x1, x2}))
    case T.CompatibleUnion{x0, x1}: Order.zero_le(I.weight(T.CompatibleUnion{x0, x1}))

law widths_count:
  for +schema: T.Schema
  {List.length(&2, Maybe<&2, Nat>, I.widths(schema)) == I.count(schema) : Nat}
def widths_count(schema):
  match schema:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: {==}
    case T.ListOf{x0, x1}: {==}
    case T.Container{x0, x1}: {==}
    case T.Union{x0}: {==}
    case T.Null{}: {==}
    case T.Chain{x0, x1}: Equal.cong(Nat, Nat, n => 1n+n, List.length(&2, Maybe<&2, Nat>, I.widths(x1)), I.count(x1), widths_count(x1))
    case T.End{}: {==}
    case T.Repeat{x0}: {==}
    case T.Named{x0, x1}: {==}
    case T.ProgressiveList{x0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: {==}
    case T.CompatibleUnion{x0, x1}: {==}

law replicate_length:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  {List.length(&2, Maybe<&2, Nat>, List.replicate(Maybe<&2, Nat>, n, width)) == n : Nat}
def replicate_length(n, width):
  match n:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat, Nat, k => 1n+k, List.length(&2, Maybe<&2, Nat>, List.replicate(Maybe<&2, Nat>, p, width)), p, replicate_length(p, width))

law replicated_widths_count:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  {List.length(&2, Maybe<&2, Nat>, Lists.replicate(Maybe<&2, Nat>, n, width)) == n : Nat}
def replicated_widths_count(n, width):
  %Equal.sym(+List<Maybe<&2, Nat>>, Lists.replicate(Maybe<&2, Nat>, n, width), List.replicate(Maybe<&2, Nat>, n, width), L.replicate_correct(Maybe<&2, Nat>, n, width)) : {List.length(&2, Maybe<&2, Nat>, _) == n : Nat}
  replicate_length(n, width)
