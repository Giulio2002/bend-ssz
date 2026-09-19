import Base
import ../types/schema.bend as T
import ../src/decode.bend as Decode
import ../src/layout.bend as Layout
import ../src/schema.bend as Schema
import ../src/lists.bend as Lists
import ./layout_counts.bend as Counts
import ./schema_measure.bend as Measure
import ./decode_count_bound.bend as Bound

law accepted_layout_count:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for accepted: {Layout.decode(widths, xs) == Some{parts} : Maybe<&2, +List<+List<U32>>>}
  {List.length(&2, +List<U32>, parts) == List.length(&2, Maybe<&2, Nat>, widths) : Nat}
def accepted_layout_count(widths, xs, parts, accepted):
  %accepted : Counts.count(List.length(&2, Maybe<&2, Nat>, widths), _)
  Counts.actual_count(widths, xs)

law repeated_layout_count:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for accepted: {Layout.decode(Lists.replicate(Maybe<&2, Nat>, n, width), xs) == Some{parts} : Maybe<&2, +List<+List<U32>>>}
  {List.length(&2, +List<U32>, parts) == n : Nat}
def repeated_layout_count(n, width, xs, parts, accepted):
  Equal.trans(Nat, List.length(&2, +List<U32>, parts), List.length(&2, Maybe<&2, Nat>, Lists.replicate(Maybe<&2, Nat>, n, width)), n, accepted_layout_count(Lists.replicate(Maybe<&2, Nat>, n, width), xs, parts, accepted), Measure.replicated_widths_count(n, width))

# This is the actual pair of APIs used before entering Repeat in decode_go.
# Even empty variable children have offset-table entries, so their count cannot
# exceed the input byte length. No fixture/resource bound is a premise.
law sequence_parts_bound:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for counted: {Decode.item_count(width, xs) == Some{n} : Maybe<&2, Nat>}
  for decoded: {Layout.decode(Lists.replicate(Maybe<&2, Nat>, n, width), xs) == Some{parts} : Maybe<&2, +List<+List<U32>>>}
  {Nat.is_le(List.length(&2, +List<U32>, parts), Lists.length(U32, xs)) == True{} : Bool}
def sequence_parts_bound(n, width, xs, parts, counted, decoded):
  %Equal.sym(Nat, List.length(&2, +List<U32>, parts), n, repeated_layout_count(n, width, xs, parts, decoded)) : {Nat.is_le(_, Lists.length(U32, xs)) == True{} : Bool}
  %counted : Bound.bound(Lists.length(U32, xs), _)
  Bound.item_count_bound(width, xs)

law container_parts_bound:
  for +fields: T.Schema
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for decoded: {Layout.decode(Schema.widths(fields), xs) == Some{parts} : Maybe<&2, +List<+List<U32>>>}
  {Nat.is_le(List.length(&2, +List<U32>, parts), Schema.weight(fields)) == True{} : Bool}
def container_parts_bound(fields, xs, parts, decoded):
  %Equal.sym(Nat, List.length(&2, +List<U32>, parts), Schema.count(fields), Equal.trans(Nat, List.length(&2, +List<U32>, parts), List.length(&2, Maybe<&2, Nat>, Schema.widths(fields)), Schema.count(fields), accepted_layout_count(Schema.widths(fields), xs, parts, decoded), Measure.widths_count(fields))) : {Nat.is_le(_, Schema.weight(fields)) == True{} : Bool}
  Measure.fields_bounded_by_weight(fields)
