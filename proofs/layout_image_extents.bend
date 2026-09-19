import Base
import ../types/schema.bend as T
import ../spec/layout.bend as E
import ../spec/layout_decoding.bend as D
import ./layout_image_headers.bend as H
import ./layout_slices.bend as Cut
import ./layout.bend as Layout
import ./packing.bend as Pack
import ./nat_algebra.bend as A
import ./nat_order.bend as O
import ./primitive_invariants.bend as V
import ./bit_vector_canonical.bend as Eq

law next_boundary:
  for +parts: +List<T.Part>
  for +position: Nat
  {D.boundary(H.headers(parts, position), Nat.add(position, List.length(&2, U32, E.payloads(parts)))) == position : Nat}
def next_boundary(parts, position):
  match parts:
    case Nil{}: Pack.add_zero(position)
    case Con{T.Fixed{xs}, t}: next_boundary(t, position)
    case Con{T.Variable{xs}, t}: {==}

law extent_guard:
  for +position: Nat
  for +size: Nat
  for +rest: Nat
  {Bool.and(Nat.is_eq(position, position), Bool.and(Nat.is_le(position, Nat.add(position, size)), Nat.is_le(Nat.add(position, size), Nat.add(Nat.add(position, size), rest)))) == True{} : Bool}
def extent_guard(position, size, rest):
  V.and_true(Nat.is_eq(position, position), Bool.and(Nat.is_le(position, Nat.add(position, size)), Nat.is_le(Nat.add(position, size), Nat.add(Nat.add(position, size), rest))), Eq.nat_equal_refl(position), V.and_true(Nat.is_le(position, Nat.add(position, size)), Nat.is_le(Nat.add(position, size), Nat.add(Nat.add(position, size), rest)), O.below_sum(position, size), O.below_sum(Nat.add(position, size), rest)))

law variable_extent:
  for +fields: +List<T.Header>
  for +position: Nat
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for +values: +List<+List<U32>>
  for boundary: {D.boundary(fields, Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest))) == Nat.add(position, List.length(&2, U32, prefix)) : Nat}
  for tail: {D.extents(fields, Nat.add(position, List.length(&2, U32, prefix)), Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest)), rest) == Some{values} : Maybe<&2, +List<+List<U32>>>}
  {D.extents(T.Offset{position} <> fields, position, Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest)), List.append(&2, U32, prefix, rest)) == Some{prefix <> values} : Maybe<&2, +List<+List<U32>>>}
def variable_extent(fields, position, prefix, rest, values, boundary, tail):
  %Equal.sym(Nat, D.boundary(fields, Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest))), Nat.add(position, List.length(&2, U32, prefix)), boundary) : {D.require(Bool.and(Nat.is_eq(position, position), Bool.and(Nat.is_le(position, _), Nat.is_le(_, Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest))))), u => D.sliced(D.cut(Nat.sub(_, position), List.append(&2, U32, prefix, rest)), remaining => D.extents(fields, _, Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest)), remaining))) == Some{prefix <> values} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Bool, Bool.and(Nat.is_eq(position, position), Bool.and(Nat.is_le(position, Nat.add(position, List.length(&2, U32, prefix))), Nat.is_le(Nat.add(position, List.length(&2, U32, prefix)), Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest))))), True{}, extent_guard(position, List.length(&2, U32, prefix), List.length(&2, U32, rest))) : {D.require(_, u => D.sliced(D.cut(Nat.sub(Nat.add(position, List.length(&2, U32, prefix)), position), List.append(&2, U32, prefix, rest)), remaining => D.extents(fields, Nat.add(position, List.length(&2, U32, prefix)), Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest)), remaining))) == Some{prefix <> values} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Nat, Nat.sub(Nat.add(position, List.length(&2, U32, prefix)), position), List.length(&2, U32, prefix), A.subtract_prefix(position, List.length(&2, U32, prefix))) : {D.sliced(D.cut(_, List.append(&2, U32, prefix, rest)), remaining => D.extents(fields, Nat.add(position, List.length(&2, U32, prefix)), Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest)), remaining)) == Some{prefix <> values} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Maybe<&2, D.Slice>, D.cut(List.length(&2, U32, prefix), List.append(&2, U32, prefix, rest)), Some{D.Slice{prefix, rest}}, Cut.cut_prefix(prefix, rest)) : {D.sliced(_, remaining => D.extents(fields, Nat.add(position, List.length(&2, U32, prefix)), Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest)), remaining)) == Some{prefix <> values} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, D.extents(fields, Nat.add(position, List.length(&2, U32, prefix)), Nat.add(Nat.add(position, List.length(&2, U32, prefix)), List.length(&2, U32, rest)), rest), Some{values}, tail) : {D.prepend(prefix, _) == Some{prefix <> values} : Maybe<&2, +List<+List<U32>>>}
  {==}

law extents_inverse:
  for +parts: +List<T.Part>
  for +position: Nat
  {D.extents(H.headers(parts, position), position, Nat.add(position, List.length(&2, U32, E.payloads(parts))), E.payloads(parts)) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
def extents_inverse(parts, position):
  match parts:
    case Nil{}: {==}
    case Con{T.Fixed{xs}, t}: Equal.cong(Maybe<&2, +List<+List<U32>>>, Maybe<&2, +List<+List<U32>>>, result => D.prepend(xs, result), D.extents(H.headers(t, position), position, Nat.add(position, List.length(&2, U32, E.payloads(t))), E.payloads(t)), Some{H.values(t)}, extents_inverse(t, position))
    case Con{T.Variable{xs}, t}:
      %Layout.advance_total(position, xs, E.payloads(t)) : {D.extents(T.Offset{position} <> H.headers(t, Nat.add(position, List.length(&2, U32, xs))), position, _, List.append(&2, U32, xs, E.payloads(t))) == Some{xs <> H.values(t)} : Maybe<&2, +List<+List<U32>>>}
      variable_extent(H.headers(t, Nat.add(position, List.length(&2, U32, xs))), position, xs, E.payloads(t), H.values(t), next_boundary(t, Nat.add(position, List.length(&2, U32, xs))), extents_inverse(t, Nat.add(position, List.length(&2, U32, xs))))
