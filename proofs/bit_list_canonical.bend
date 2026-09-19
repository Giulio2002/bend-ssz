import Base
import ../src/bitfields.bend as API
import ../src/bit_decode.bend as D
import ../src/bit_packing.bend as P
import ../src/packing.bend as Pack
import ../src/primitives.bend as Bytes
import ../spec/primitives.bend as Domain
import ../spec/bitfields.bend as Spec
import ./bit_list_codec.bend as Codec
import ./bit_delimiter.bend as L
import ./bit_padding.bend as A
import ./bit_padding_pack.bend as Padding
import ./bit_inverse.bend as Inverse
import ./packing.bend as Packing
import ./bitfields.bend as Refinement
import ./bit_take_unique.bend as U
import ./word_facts.bend as W

law checked_requires_true:
  for +ok: Bool
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for decoded: {D.list_checked(ok, capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {ok == True{} : Bool}
def checked_requires_true(ok, capacity, xs, bits, decoded):
  match ok:
    case False{}: Equal.cong(Maybe<&2, +List<Bool>>, Bool, U.present, None{}, Some{bits}, decoded)
    case True{}: {==}

law accepted_bytes:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for decoded: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {Domain.bytes_domain(xs) == True{} : Bool}
def accepted_bytes(capacity, xs, bits, decoded):
  Equal.trans(Bool, Domain.bytes_domain(xs), Pack.valid_go(xs, True{}), True{}, Equal.sym(Bool, Pack.valid_go(xs, True{}), Domain.bytes_domain(xs), Packing.valid_go_correct(xs, True{})), checked_requires_true(Pack.valid_go(xs, True{}), capacity, xs, bits, decoded))

law accepted_forward_shape:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for decoded: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {D.expand(xs) == List.append(&2, Bool, bits, True{} <> L.zeros(L.removed(List.reverse(&2, Bool, D.expand(xs)), 7n), [])) : +List<Bool>}
def accepted_forward_shape(capacity, xs, bits, decoded):
  +q = L.removed(List.reverse(&2, Bool, D.expand(xs)), 7n)
  Equal.trans(+List<Bool>, D.expand(xs), List.reverse(&2, Bool, List.reverse(&2, Bool, D.expand(xs))), List.append(&2, Bool, bits, True{} <> L.zeros(q, [])), Equal.sym(+List<Bool>, List.reverse(&2, Bool, List.reverse(&2, Bool, D.expand(xs))), D.expand(xs), L.reverse_twice(D.expand(xs))),
    Equal.trans(+List<Bool>, List.reverse(&2, Bool, List.reverse(&2, Bool, D.expand(xs))), List.reverse(&2, Bool, L.zeros(q, True{} <> List.reverse(&2, Bool, bits))), List.append(&2, Bool, bits, True{} <> L.zeros(q, [])), Equal.cong(+List<Bool>, +List<Bool>, ys => List.reverse(&2, Bool, ys), List.reverse(&2, Bool, D.expand(xs)), L.zeros(q, True{} <> List.reverse(&2, Bool, bits)), Codec.accepted_delimiter_shape(capacity, xs, bits, decoded)), A.forward_shape(q, bits)))

law accepted_alignment:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for decoded: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {A.aligned(List.append(&2, Bool, bits, True{} <> L.zeros(L.removed(List.reverse(&2, Bool, D.expand(xs)), 7n), []))) == True{} : Bool}
def accepted_alignment(capacity, xs, bits, decoded):
  %accepted_forward_shape(capacity, xs, bits, decoded) : {A.aligned(_) == True{} : Bool}
  A.expand_aligned(xs)

law accepted_packed:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +decoded: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {P.pack(List.append(&2, Bool, bits, [True{}])) == xs : +List<U32>}
def accepted_packed(capacity, xs, bits, decoded):
  +q = L.removed(List.reverse(&2, Bool, D.expand(xs)), 7n)
  Equal.trans(+List<U32>, P.pack(List.append(&2, Bool, bits, [True{}])), P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(q, []))), xs, Padding.pack_padding(bits, q, L.removed_bounded(List.reverse(&2, Bool, D.expand(xs)), 7n), accepted_alignment(capacity, xs, bits, decoded)),
    Equal.trans(+List<U32>, P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(q, []))), P.pack(D.expand(xs)), xs, Equal.cong(+List<Bool>, +List<U32>, P.pack, List.append(&2, Bool, bits, True{} <> L.zeros(q, [])), D.expand(xs), Equal.sym(+List<Bool>, D.expand(xs), List.append(&2, Bool, bits, True{} <> L.zeros(q, [])), accepted_forward_shape(capacity, xs, bits, decoded))), Inverse.repack_expanded(xs, accepted_bytes(capacity, xs, bits, decoded))))

law accepted_canonical:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +decoded: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {API.bitlist_serialize(capacity, bits) == Some{xs} : Maybe<&2, +List<U32>>}
def accepted_canonical(capacity, xs, bits, decoded):
  %Equal.sym(Bool, API.list_valid(capacity, bits), True{}, Codec.accepted_valid(capacity, xs, bits, decoded)) : {Bytes.accept_bytes(_, P.pack(List.append(&2, Bool, bits, [True{}]))) == Some{xs} : Maybe<&2, +List<U32>>}
  Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, ys => Some{ys}, P.pack(List.append(&2, Bool, bits, [True{}])), xs, accepted_packed(capacity, xs, bits, decoded))

law accepted_normative_canonical:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for decoded: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {Spec.list_encoding(capacity, bits) == Some{xs} : Maybe<&2, +List<U32>>}
def accepted_normative_canonical(capacity, xs, bits, decoded):
  %Refinement.bitlist_serialize_correct(capacity, bits) : {_ == Some{xs} : Maybe<&2, +List<U32>>}
  accepted_canonical(capacity, xs, bits, decoded)

# The negative image condition quantifies over every legal Boolean list.
# No encoding, size limit, or runtime bound is supplied as a trusted oracle.
law reject_outside_branch:
  for +capacity: Nat
  for +xs: +List<U32>
  for +result: Maybe<&2, +List<Bool>>
  for +decoded: {API.bitlist_deserialize(capacity, xs) == result : Maybe<&2, +List<Bool>>}
  for outside: @+bits: +List<Bool> -> {API.list_valid(capacity, bits) == True{} : Bool} -> {Spec.list_encoding(capacity, bits) == Some{xs} : Maybe<&2, +List<U32>>} -> Empty
  {result == None{} : Maybe<&2, +List<Bool>>}
def reject_outside_branch(capacity, xs, result, decoded, outside):
  match result:
    case None{}: {==}
    case Some{bits}:
      Empty.absurd({Some{bits} == None{} : Maybe<&2, +List<Bool>>}, outside(bits, Codec.accepted_valid(capacity, xs, bits, decoded), accepted_normative_canonical(capacity, xs, bits, decoded)))

law rejected_exactly_outside_image:
  for +capacity: Nat
  for +xs: +List<U32>
  for outside: @+bits: +List<Bool> -> {API.list_valid(capacity, bits) == True{} : Bool} -> {Spec.list_encoding(capacity, bits) == Some{xs} : Maybe<&2, +List<U32>>} -> Empty
  {API.bitlist_deserialize(capacity, xs) == None{} : Maybe<&2, +List<Bool>>}
def rejected_exactly_outside_image(capacity, xs, outside):
  reject_outside_branch(capacity, xs, API.bitlist_deserialize(capacity, xs), {==}, outside)
