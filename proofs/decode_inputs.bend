import Base
import ../types/schema.bend as T
import ../src/decode.bend as D
import ../src/layout.bend as L
import ../src/schema.bend as S
import ../src/lists.bend as Lists
import ./layout_bounds.bend as B
import ./decode_layout_bound.bend as Count
import ./schema_measure.bend as Measure
import ./lists.bend as ListProof
import ./nat_order.bend as O
import ./bit_vector_inverse.bend as Eq

law weaken:
  for +parts: +List<+List<U32>>
  for +a: Nat
  for +b: Nat
  for +limit: {Nat.is_le(a, b) == True{} : Bool}
  for bounds: B.slices(a, parts)
  B.slices(b, parts)
def weaken(parts, a, b, limit, bounds):
  match parts:
    case Nil{}: Unit{}
    case Con{h, t}:
      (first, rest) = bounds
      (O.transitive(List.length(&2, U32, h), a, b, first, limit), weaken(t, a, b, limit, rest))

law layout:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for input: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
  for decoded: {L.decode(widths, xs) == Some{parts} : Maybe<&2, +List<+List<U32>>>}
  B.slices(maximum, parts)
def layout(widths, xs, parts, maximum, input, decoded):
  weaken(parts, List.length(&2, U32, xs), maximum, input,
    %decoded : B.result_bound(List.length(&2, U32, xs), _)
    B.actual_bound(widths, xs))

law repeated_count:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for counted: {D.item_count(width, xs) == Some{n} : Maybe<&2, Nat>}
  for decoded: {L.decode(Lists.replicate(Maybe<&2, Nat>, n, width), xs) == Some{parts} : Maybe<&2, +List<+List<U32>>>}
  for input: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
  {Nat.is_le(List.length(&2, +List<U32>, parts), maximum) == True{} : Bool}
def repeated_count(n, width, xs, parts, maximum, counted, decoded, input):
  O.transitive(List.length(&2, +List<U32>, parts), List.length(&2, U32, xs), maximum,
    %ListProof.length_correct(U32, xs) : {Nat.is_le(List.length(&2, +List<U32>, parts), _) == True{} : Bool}
    Count.sequence_parts_bound(n, width, xs, parts, counted, decoded), input)

law vector_count:
  for +k: Nat
  for +n: Nat
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  for counted: {D.item_count(width, xs) == Some{k} : Maybe<&2, Nat>}
  for same: {Nat.is_eq(k, n) == True{} : Bool}
  {D.item_count(width, xs) == Some{n} : Maybe<&2, Nat>}
def vector_count(k, n, width, xs, counted, same):
  %Eq.nat_equal_sound(k, n, same) : {D.item_count(width, xs) == Some{_} : Maybe<&2, Nat>}
  counted

law forest_count:
  for +fields: T.Schema
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for decoded: {L.decode(S.widths(fields), xs) == Some{parts} : Maybe<&2, +List<+List<U32>>>}
  {List.length(&2, +List<U32>, parts) == S.count(fields) : Nat}
def forest_count(fields, xs, parts, decoded):
  Equal.trans(Nat, List.length(&2, +List<U32>, parts), List.length(&2, Maybe<&2, Nat>, S.widths(fields)), S.count(fields), Count.accepted_layout_count(S.widths(fields), xs, parts, decoded), Measure.widths_count(fields))
