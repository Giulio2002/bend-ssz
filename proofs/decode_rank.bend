import Base
import ../types/schema.bend as T
import ../src/schema.bend as S
import ../spec/schema_forest.bend as F
import ./word_facts.bend as W
import ./nat_order.bend as O
import ./nat_algebra.bend as A
import ./packing.bend as P

# maximum bounds all byte slices reachable from the original input. Repeat
# spends one step per remaining slice; ordinary nodes decrease schema weight.
def regular(schema: T.Schema, +maximum: Nat) -> Nat:
  Nat.mul(2n+S.weight(schema), 2n+maximum)

def rank(schema: T.Schema, parts: +List<+List<U32>>, +maximum: Nat) -> Nat:
  match schema:
    case T.Repeat{e}: Nat.add(1n+List.length(&2, +List<U32>, parts), regular(e, maximum))
    case _: regular(schema, maximum)

law coefficient_strict:
  for +a: Nat
  for +b: Nat
  for +k: Nat
  for positive: {Nat.is_le(1n, k) == True{} : Bool}
  for increase: {Nat.is_le(1n+a, b) == True{} : Bool}
  {Nat.is_le(1n+Nat.mul(a, k), Nat.mul(b, k)) == True{} : Bool}
def coefficient_strict(a, b, k, positive, increase):
  O.transitive(1n+Nat.mul(a, k), Nat.mul(1n+a, k), Nat.mul(b, k), O.add_right(1n, k, Nat.mul(a, k), positive), A.mul_coefficient(1n+a, b, k, increase))

law regular_step:
  for +child: T.Schema
  for +parent: T.Schema
  for +maximum: Nat
  for smaller: {Nat.is_le(1n+S.weight(child), S.weight(parent)) == True{} : Bool}
  {Nat.is_le(1n+regular(child, maximum), regular(parent, maximum)) == True{} : Bool}
def regular_step(child, parent, maximum, smaller):
  coefficient_strict(2n+S.weight(child), 2n+S.weight(parent), 2n+maximum, O.zero_le(1n+maximum), smaller)

law empty_bound:
  for +schema: T.Schema
  for +maximum: Nat
  {Nat.is_le(rank(schema, [], maximum), regular(schema, maximum)) == True{} : Bool}
def empty_bound(schema, maximum):
  match schema:
    case T.Boolean{}: O.reflexive(regular(T.Boolean{}, maximum))
    case T.Unsigned{x0}: O.reflexive(regular(T.Unsigned{x0}, maximum))
    case T.ByteVector{x0}: O.reflexive(regular(T.ByteVector{x0}, maximum))
    case T.ByteList{x0}: O.reflexive(regular(T.ByteList{x0}, maximum))
    case T.BitVector{x0}: O.reflexive(regular(T.BitVector{x0}, maximum))
    case T.BitList{x0}: O.reflexive(regular(T.BitList{x0}, maximum))
    case T.Vector{x0, x1}: O.reflexive(regular(T.Vector{x0, x1}, maximum))
    case T.ListOf{x0, x1}: O.reflexive(regular(T.ListOf{x0, x1}, maximum))
    case T.Container{x0, x1}: O.reflexive(regular(T.Container{x0, x1}, maximum))
    case T.Union{x0}: O.reflexive(regular(T.Union{x0}, maximum))
    case T.Null{}: O.reflexive(regular(T.Null{}, maximum))
    case T.Chain{x0, x1}: O.reflexive(regular(T.Chain{x0, x1}, maximum))
    case T.End{}: O.reflexive(regular(T.End{}, maximum))
    case T.Repeat{x0}: O.add_right(1n, 2n+maximum, regular(x0, maximum), O.zero_le(1n+maximum))
    case T.Named{x0, x1}: O.reflexive(regular(T.Named{x0, x1}, maximum))
    case T.ProgressiveList{x0}: O.reflexive(regular(T.ProgressiveList{x0}, maximum))
    case T.ProgressiveBits{}: O.reflexive(regular(T.ProgressiveBits{}, maximum))
    case T.ProgressiveContainer{x0, x1, x2}: O.reflexive(regular(T.ProgressiveContainer{x0, x1, x2}, maximum))
    case T.CompatibleUnion{x0, x1}: O.reflexive(regular(T.CompatibleUnion{x0, x1}, maximum))

law forest_bound:
  for +schema: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for count: {List.length(&2, +List<U32>, parts) == S.count(schema) : Nat}
  {Nat.is_le(rank(schema, parts, maximum), regular(schema, maximum)) == True{} : Bool}
def forest_bound(schema, parts, maximum, count):
  match schema:
    case T.Boolean{}: O.reflexive(regular(T.Boolean{}, maximum))
    case T.Unsigned{x0}: O.reflexive(regular(T.Unsigned{x0}, maximum))
    case T.ByteVector{x0}: O.reflexive(regular(T.ByteVector{x0}, maximum))
    case T.ByteList{x0}: O.reflexive(regular(T.ByteList{x0}, maximum))
    case T.BitVector{x0}: O.reflexive(regular(T.BitVector{x0}, maximum))
    case T.BitList{x0}: O.reflexive(regular(T.BitList{x0}, maximum))
    case T.Vector{x0, x1}: O.reflexive(regular(T.Vector{x0, x1}, maximum))
    case T.ListOf{x0, x1}: O.reflexive(regular(T.ListOf{x0, x1}, maximum))
    case T.Container{x0, x1}: O.reflexive(regular(T.Container{x0, x1}, maximum))
    case T.Union{x0}: O.reflexive(regular(T.Union{x0}, maximum))
    case T.Null{}: O.reflexive(regular(T.Null{}, maximum))
    case T.Chain{x0, x1}: O.reflexive(regular(T.Chain{x0, x1}, maximum))
    case T.End{}: O.reflexive(regular(T.End{}, maximum))
    case T.Repeat{x0}: %Equal.sym(Nat, List.length(&2, +List<U32>, parts), 0n, count) : {Nat.is_le(Nat.add(1n+_, regular(x0, maximum)), regular(T.Repeat{x0}, maximum)) == True{} : Bool}
      empty_bound(T.Repeat{x0}, maximum)
    case T.Named{x0, x1}: O.reflexive(regular(T.Named{x0, x1}, maximum))
    case T.ProgressiveList{x0}: O.reflexive(regular(T.ProgressiveList{x0}, maximum))
    case T.ProgressiveBits{}: O.reflexive(regular(T.ProgressiveBits{}, maximum))
    case T.ProgressiveContainer{x0, x1, x2}: O.reflexive(regular(T.ProgressiveContainer{x0, x1, x2}, maximum))
    case T.CompatibleUnion{x0, x1}: O.reflexive(regular(T.CompatibleUnion{x0, x1}, maximum))

law positive:
  for +schema: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  {Nat.is_le(1n, rank(schema, parts, maximum)) == True{} : Bool}
def positive(schema, parts, maximum):
  match schema:
    case T.Boolean{}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.Boolean{}), 2n+maximum)))
    case T.Unsigned{x0}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.Unsigned{x0}), 2n+maximum)))
    case T.ByteVector{x0}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.ByteVector{x0}), 2n+maximum)))
    case T.ByteList{x0}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.ByteList{x0}), 2n+maximum)))
    case T.BitVector{x0}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.BitVector{x0}), 2n+maximum)))
    case T.BitList{x0}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.BitList{x0}), 2n+maximum)))
    case T.Vector{x0, x1}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.Vector{x0, x1}), 2n+maximum)))
    case T.ListOf{x0, x1}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.ListOf{x0, x1}), 2n+maximum)))
    case T.Container{x0, x1}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.Container{x0, x1}), 2n+maximum)))
    case T.Union{x0}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.Union{x0}), 2n+maximum)))
    case T.Null{}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.Null{}), 2n+maximum)))
    case T.Chain{x0, x1}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.Chain{x0, x1}), 2n+maximum)))
    case T.End{}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.End{}), 2n+maximum)))
    case T.Repeat{x0}: O.zero_le(Nat.add(List.length(&2, +List<U32>, parts), regular(x0, maximum)))
    case T.Named{x0, x1}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.Named{x0, x1}), 2n+maximum)))
    case T.ProgressiveList{x0}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.ProgressiveList{x0}), 2n+maximum)))
    case T.ProgressiveBits{}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.ProgressiveBits{}), 2n+maximum)))
    case T.ProgressiveContainer{x0, x1, x2}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.ProgressiveContainer{x0, x1, x2}), 2n+maximum)))
    case T.CompatibleUnion{x0, x1}: O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight(T.CompatibleUnion{x0, x1}), 2n+maximum)))

law finite_bound:
  for +schema: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for finite: {F.finite(schema) == True{} : Bool}
  {Nat.is_le(rank(schema, parts, maximum), regular(schema, maximum)) == True{} : Bool}
def finite_bound(schema, parts, maximum, finite):
  match schema:
    case T.Boolean{}: O.reflexive(regular(T.Boolean{}, maximum))
    case T.Unsigned{x0}: O.reflexive(regular(T.Unsigned{x0}, maximum))
    case T.ByteVector{x0}: O.reflexive(regular(T.ByteVector{x0}, maximum))
    case T.ByteList{x0}: O.reflexive(regular(T.ByteList{x0}, maximum))
    case T.BitVector{x0}: O.reflexive(regular(T.BitVector{x0}, maximum))
    case T.BitList{x0}: O.reflexive(regular(T.BitList{x0}, maximum))
    case T.Vector{x0, x1}: O.reflexive(regular(T.Vector{x0, x1}, maximum))
    case T.ListOf{x0, x1}: O.reflexive(regular(T.ListOf{x0, x1}, maximum))
    case T.Container{x0, x1}: O.reflexive(regular(T.Container{x0, x1}, maximum))
    case T.Union{x0}: O.reflexive(regular(T.Union{x0}, maximum))
    case T.Null{}: O.reflexive(regular(T.Null{}, maximum))
    case T.Chain{x0, x1}: O.reflexive(regular(T.Chain{x0, x1}, maximum))
    case T.End{}: O.reflexive(regular(T.End{}, maximum))
    case T.Repeat{x0}: Empty.absurd({Nat.is_le(rank(T.Repeat{x0}, parts, maximum), regular(T.Repeat{x0}, maximum)) == True{} : Bool}, W.false_true(finite))
    case T.Named{x0, x1}: O.reflexive(regular(T.Named{x0, x1}, maximum))
    case T.ProgressiveList{x0}: O.reflexive(regular(T.ProgressiveList{x0}, maximum))
    case T.ProgressiveBits{}: O.reflexive(regular(T.ProgressiveBits{}, maximum))
    case T.ProgressiveContainer{x0, x1, x2}: O.reflexive(regular(T.ProgressiveContainer{x0, x1, x2}, maximum))
    case T.CompatibleUnion{x0, x1}: O.reflexive(regular(T.CompatibleUnion{x0, x1}, maximum))

law child_step:
  for +child: T.Schema
  for +parent: T.Schema
  for +maximum: Nat
  for smaller: {Nat.is_le(1n+S.weight(child), S.weight(parent)) == True{} : Bool}
  {Nat.is_le(1n+rank(child, [], maximum), regular(parent, maximum)) == True{} : Bool}
def child_step(child, parent, maximum, smaller):
  O.transitive(1n+rank(child, [], maximum), 1n+regular(child, maximum), regular(parent, maximum), empty_bound(child, maximum), regular_step(child, parent, maximum, smaller))

law repeat_head:
  for +element: T.Schema
  for +first: +List<U32>
  for +rest: +List<+List<U32>>
  for +maximum: Nat
  {Nat.is_le(1n+rank(element, [], maximum), rank(T.Repeat{element}, first <> rest, maximum)) == True{} : Bool}
def repeat_head(element, first, rest, maximum):
  O.transitive(1n+rank(element, [], maximum), 1n+regular(element, maximum), rank(T.Repeat{element}, first <> rest, maximum), empty_bound(element, maximum), O.add_right(1n, 2n+List.length(&2, +List<U32>, rest), regular(element, maximum), O.zero_le(1n+List.length(&2, +List<U32>, rest))))

law repeat_tail:
  for +element: T.Schema
  for +first: +List<U32>
  for +rest: +List<+List<U32>>
  for +maximum: Nat
  {Nat.is_le(1n+rank(T.Repeat{element}, rest, maximum), rank(T.Repeat{element}, first <> rest, maximum)) == True{} : Bool}
def repeat_tail(element, first, rest, maximum):
  O.reflexive(rank(T.Repeat{element}, first <> rest, maximum))

law enter_sequence:
  for +element: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for count: {Nat.is_le(List.length(&2, +List<U32>, parts), maximum) == True{} : Bool}
  {Nat.is_le(1n+rank(T.Repeat{element}, parts, maximum), Nat.mul(3n+S.weight(element), 2n+maximum)) == True{} : Bool}
def enter_sequence(element, parts, maximum, count):
  O.add_right(2n+List.length(&2, +List<U32>, parts), 2n+maximum, regular(element, maximum), count)

law enter_forest:
  for +fields: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for count: {List.length(&2, +List<U32>, parts) == S.count(fields) : Nat}
  {Nat.is_le(1n+rank(fields, parts, maximum), Nat.mul(3n+S.weight(fields), 2n+maximum)) == True{} : Bool}
def enter_forest(fields, parts, maximum, count):
  O.transitive(1n+rank(fields, parts, maximum), 1n+regular(fields, maximum), Nat.mul(3n+S.weight(fields), 2n+maximum), forest_bound(fields, parts, maximum, count), O.add_right(1n, 2n+maximum, regular(fields, maximum), O.zero_le(1n+maximum)))

law child_budget:
  for +child: Nat
  for +parent: Nat
  for +fuel: Nat
  for step: {Nat.is_le(1n+child, parent) == True{} : Bool}
  for enough: {Nat.is_le(parent, 1n+fuel) == True{} : Bool}
  {Nat.is_le(child, fuel) == True{} : Bool}
def child_budget(child, parent, fuel, step, enough):
  O.transitive(1n+child, parent, 1n+fuel, step, enough)
