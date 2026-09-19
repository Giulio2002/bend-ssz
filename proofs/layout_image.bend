import Base
import ./word_facts.bend as W
import ../types/schema.bend as T
import ../spec/layout.bend as E
import ../spec/layout_decoding.bend as D
import ../spec/nat_bytes.bend as N
import ../spec/primitives.bend as P
import ./layout.bend as L
import ./layout_image_headers.bend as H
import ./layout_image_extents.bend as X
import ./primitive_invariants.bend as V

# Canonical serialized layout has exactly the independently described slices.
law encoded_slices:
  for +parts: +List<T.Part>
  for +bytes_valid: {E.bytes_valid(parts) == True{} : Bool}
  for +fits: {N.fits(4n, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts)))) == True{} : Bool}
  {D.decoding(H.widths(parts), List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
def encoded_slices(parts, bytes_valid, fits):
  %Equal.sym(Bool, P.bytes_domain(List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))), E.bytes_valid(parts), L.output_domain(parts, E.fixed_size(parts))) : {D.require(Bool.and(_, N.fits(4n, List.length(&2, U32, List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))))), u => D.resolve(D.read(H.widths(parts), List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))), D.fixed_size(H.widths(parts)), List.length(&2, U32, List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))))) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))), Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts))), L.output_length(parts, E.fixed_size(parts))) : {D.require(Bool.and(E.bytes_valid(parts), N.fits(4n, _)), u => D.resolve(D.read(H.widths(parts), List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))), D.fixed_size(H.widths(parts)), _)) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Bool, Bool.and(E.bytes_valid(parts), N.fits(4n, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts))))), True{}, V.and_true(E.bytes_valid(parts), N.fits(4n, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts)))), bytes_valid, fits)) : {D.require(_, u => D.resolve(D.read(H.widths(parts), List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))), D.fixed_size(H.widths(parts)), Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts))))) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Maybe<&2, D.HeaderRegion>, D.read(H.widths(parts), List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts))), Some{D.HeaderRegion{H.headers(parts, E.fixed_size(parts)), E.payloads(parts)}}, H.read_encoded_headers(parts, E.fixed_size(parts), E.payloads(parts), L.offsets_representable(parts, E.fixed_size(parts), fits))) : {D.resolve(_, D.fixed_size(H.widths(parts)), Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts)))) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Nat, D.fixed_size(H.widths(parts)), E.fixed_size(parts), H.fixed_size(parts)) : {D.extents(H.headers(parts, E.fixed_size(parts)), _, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts))), E.payloads(parts)) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
  X.extents_inverse(parts, E.fixed_size(parts))


def contents(result: Maybe<&2, +List<U32>>) -> +List<U32>:
  match result:
    case None{}: []
    case Some{xs}: xs

def present(result: Maybe<&2, +List<U32>>) -> Bool:
  match result:
    case None{}: False{}
    case Some{xs}: True{}

law optional_valid:
  for +ok: Bool
  for +output: +List<U32>
  for +bytes: +List<U32>
  for accepted: {P.optional(ok, output) == Some{bytes} : Maybe<&2, +List<U32>>}
  {ok == True{} : Bool}
def optional_valid(ok, output, bytes, accepted):
  match ok:
    case False{}: Equal.cong(Maybe<&2, +List<U32>>, Bool, r => present(r), None{}, Some{bytes}, accepted)
    case True{}: {==}

law optional_output:
  for +ok: Bool
  for +output: +List<U32>
  for +bytes: +List<U32>
  for accepted: {P.optional(ok, output) == Some{bytes} : Maybe<&2, +List<U32>>}
  {output == bytes : +List<U32>}
def optional_output(ok, output, bytes, accepted):
  match ok:
    case False{}: Empty.absurd({output == bytes : +List<U32>}, W.false_true(optional_valid(False{}, output, bytes, accepted)))
    case True{}: Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, r => contents(r), Some{output}, Some{bytes}, accepted)

law encoding_image_complete:
  for +parts: +List<T.Part>
  for +bytes: +List<U32>
  for +encoded: {E.encoding(parts) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.decoding(H.widths(parts), bytes) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
def encoding_image_complete(parts, bytes, encoded):
  %optional_output(Bool.and(E.bytes_valid(parts), N.fits(4n, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts))))), List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts)), bytes, encoded) : {D.decoding(H.widths(parts), _) == Some{H.values(parts)} : Maybe<&2, +List<+List<U32>>>}
  encoded_slices(parts, V.and_left(E.bytes_valid(parts), N.fits(4n, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts)))), optional_valid(Bool.and(E.bytes_valid(parts), N.fits(4n, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts))))), List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts)), bytes, encoded)), V.and_right(E.bytes_valid(parts), N.fits(4n, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts)))), optional_valid(Bool.and(E.bytes_valid(parts), N.fits(4n, Nat.add(E.fixed_size(parts), List.length(&2, U32, E.payloads(parts))))), List.append(&2, U32, E.fixed_parts(parts, E.fixed_size(parts)), E.payloads(parts)), bytes, encoded)))
