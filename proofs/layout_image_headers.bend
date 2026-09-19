import Base
import ../types/schema.bend as T
import ../spec/layout.bend as E
import ../spec/layout_decoding.bend as D
import ../spec/nat_bytes.bend as N
import ./nat_bytes.bend as Digits
import ./layout_offset_value.bend as Offset
import ./layout_slices.bend as Cut
import ./lists.bend as L
import ./primitive_invariants.bend as V

# Layout metadata induced by independently encoded children. These are proof
# views of Part, not new definitions of serialization or deserialization.
def widths(parts: +List<T.Part>) -> +List<Maybe<&2, Nat>>:
  match parts:
    case Nil{}: []
    case Con{T.Fixed{xs}, t}: Some{List.length(&2, U32, xs)} <> widths(t)
    case Con{T.Variable{xs}, t}: None{} <> widths(t)

def values(parts: +List<T.Part>) -> +List<+List<U32>>:
  match parts:
    case Nil{}: []
    case Con{T.Fixed{xs}, t}: xs <> values(t)
    case Con{T.Variable{xs}, t}: xs <> values(t)

def headers(parts: +List<T.Part>, +offset: Nat) -> +List<T.Header>:
  match parts:
    case Nil{}: []
    case Con{T.Fixed{xs}, t}: T.Inline{xs} <> headers(t, offset)
    case Con{T.Variable{xs}, t}: T.Offset{offset} <> headers(t, Nat.add(offset, List.length(&2, U32, xs)))

law fixed_size:
  for +parts: +List<T.Part>
  {D.fixed_size(widths(parts)) == E.fixed_size(parts) : Nat}
def fixed_size(parts):
  match parts:
    case Nil{}: {==}
    case Con{T.Fixed{xs}, t}: Equal.cong(Nat, Nat, n => Nat.add(List.length(&2, U32, xs), n), D.fixed_size(widths(t)), E.fixed_size(t), fixed_size(t))
    case Con{T.Variable{xs}, t}: Equal.cong(Nat, Nat, n => 4n+n, D.fixed_size(widths(t)), E.fixed_size(t), fixed_size(t))

law read_prefix:
  for +width: Maybe<&2, Nat>
  for +tail_widths: +List<Maybe<&2, Nat>>
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for +field: T.Header
  for +tail_fields: +List<T.Header>
  for +payload: +List<U32>
  for length: {D.slot(width) == List.length(&2, U32, prefix) : Nat}
  for decoded: {D.field(width, prefix) == field : T.Header}
  for tail: {D.read(tail_widths, rest) == Some{D.HeaderRegion{tail_fields, payload}} : Maybe<&2, D.HeaderRegion>}
  {D.read(width <> tail_widths, List.append(&2, U32, prefix, rest)) == Some{D.HeaderRegion{field <> tail_fields, payload}} : Maybe<&2, D.HeaderRegion>}
def read_prefix(width, tail_widths, prefix, rest, field, tail_fields, payload, length, decoded, tail):
  %Equal.sym(Nat, D.slot(width), List.length(&2, U32, prefix), length) : {D.read_slice(D.cut(_, List.append(&2, U32, prefix, rest)), width, xs => D.read(tail_widths, xs)) == Some{D.HeaderRegion{field <> tail_fields, payload}} : Maybe<&2, D.HeaderRegion>}
  %Equal.sym(Maybe<&2, D.Slice>, D.cut(List.length(&2, U32, prefix), List.append(&2, U32, prefix, rest)), Some{D.Slice{prefix, rest}}, Cut.cut_prefix(prefix, rest)) : {D.read_slice(_, width, xs => D.read(tail_widths, xs)) == Some{D.HeaderRegion{field <> tail_fields, payload}} : Maybe<&2, D.HeaderRegion>}
  %Equal.sym(T.Header, D.field(width, prefix), field, decoded) : {D.prepend_header(_, D.read(tail_widths, rest)) == Some{D.HeaderRegion{field <> tail_fields, payload}} : Maybe<&2, D.HeaderRegion>}
  %Equal.sym(Maybe<&2, D.HeaderRegion>, D.read(tail_widths, rest), Some{D.HeaderRegion{tail_fields, payload}}, tail) : {D.prepend_header(field, _) == Some{D.HeaderRegion{field <> tail_fields, payload}} : Maybe<&2, D.HeaderRegion>}
  {==}

law read_encoded_headers:
  for +parts: +List<T.Part>
  for +offset: Nat
  for +payload: +List<U32>
  for +fit: {E.offsets_fit(parts, offset) == True{} : Bool}
  {D.read(widths(parts), List.append(&2, U32, E.fixed_parts(parts, offset), payload)) == Some{D.HeaderRegion{headers(parts, offset), payload}} : Maybe<&2, D.HeaderRegion>}
def read_encoded_headers(parts, offset, payload, fit):
  match parts:
    case Nil{}: {==}
    case Con{T.Fixed{xs}, t}:
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, E.fixed_parts(t, offset)), payload), List.append(&2, U32, xs, List.append(&2, U32, E.fixed_parts(t, offset), payload)), L.append_associative(U32, xs, E.fixed_parts(t, offset), payload)) : {D.read(widths(T.Fixed{xs} <> t), _) == Some{D.HeaderRegion{headers(T.Fixed{xs} <> t, offset), payload}} : Maybe<&2, D.HeaderRegion>}
      read_prefix(Some{List.length(&2, U32, xs)}, widths(t), xs, List.append(&2, U32, E.fixed_parts(t, offset), payload), T.Inline{xs}, headers(t, offset), payload, {==}, {==}, read_encoded_headers(t, offset, payload, fit))
    case Con{T.Variable{xs}, t}:
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, N.digits(4n, offset), E.fixed_parts(t, Nat.add(offset, List.length(&2, U32, xs)))), payload), List.append(&2, U32, N.digits(4n, offset), List.append(&2, U32, E.fixed_parts(t, Nat.add(offset, List.length(&2, U32, xs))), payload)), L.append_associative(U32, N.digits(4n, offset), E.fixed_parts(t, Nat.add(offset, List.length(&2, U32, xs))), payload)) : {D.read(widths(T.Variable{xs} <> t), _) == Some{D.HeaderRegion{headers(T.Variable{xs} <> t, offset), payload}} : Maybe<&2, D.HeaderRegion>}
      read_prefix(None{}, widths(t), N.digits(4n, offset), List.append(&2, U32, E.fixed_parts(t, Nat.add(offset, List.length(&2, U32, xs))), payload), T.Offset{offset}, headers(t, Nat.add(offset, List.length(&2, U32, xs))), payload, Equal.sym(Nat, List.length(&2, U32, N.digits(4n, offset)), 4n, Digits.digits_length(4n, offset)), Offset.field_offset(offset, V.and_left(N.fits(4n, offset), E.offsets_fit(t, Nat.add(offset, List.length(&2, U32, xs))), fit)), read_encoded_headers(t, Nat.add(offset, List.length(&2, U32, xs)), payload, V.and_right(N.fits(4n, offset), E.offsets_fit(t, Nat.add(offset, List.length(&2, U32, xs))), fit)))
