import Base
import ../src/bitfields.bend as API
import ../src/bit_decode.bend as D
import ../src/bit_packing.bend as P
import ../src/packing.bend as Pack
import ../src/primitives.bend as Bytes
import ../spec/primitives.bend as Domain
import ../spec/bitfields.bend as Spec
import ./bit_list_inverse.bend as Inverse
import ./bit_delimiter.bend as Delimiter
import ./bit_packing.bend as Bits
import ./packing.bend as Packing
import ./bitfields.bend as Refinement
import ./bit_decode.bend as Decode
import ./bit_take_unique.bend as U
import ./word_facts.bend as W

law packed_valid:
  for +bits: +List<Bool>
  {Pack.valid_go(P.pack(bits), True{}) == True{} : Bool}
def packed_valid(bits):
  Equal.trans(Bool, Pack.valid_go(P.pack(bits), True{}), Domain.bytes_domain(P.pack(bits)), True{}, Packing.valid_go_correct(P.pack(bits), True{}), Bits.pack_bytes(bits))

law list_decode_packed:
  for +capacity: Nat
  for +bits: +List<Bool>
  for +valid: {API.list_valid(capacity, bits) == True{} : Bool}
  {API.bitlist_deserialize(capacity, P.pack(List.append(&2, Bool, bits, [True{}]))) == Some{bits} : Maybe<&2, +List<Bool>>}
def list_decode_packed(capacity, bits, valid):
  %Equal.sym(Bool, Pack.valid_go(P.pack(List.append(&2, Bool, bits, [True{}])), True{}), True{}, packed_valid(List.append(&2, Bool, bits, [True{}]))) :
    {D.list_checked(_, capacity, P.pack(List.append(&2, Bool, bits, [True{}]))) == Some{bits} : Maybe<&2, +List<Bool>>}
  %Equal.sym(Maybe<&2, +List<Bool>>, D.delimiter(List.reverse(&2, Bool, D.expand(P.pack(List.append(&2, Bool, bits, [True{}])))), 7n), Some{bits}, Inverse.delimiter_packed(bits)) :
    {D.bounded(capacity, _) == Some{bits} : Maybe<&2, +List<Bool>>}
  %Equal.sym(Bool, API.list_valid(capacity, bits), True{}, valid) :
    {D.accept(_, bits) == Some{bits} : Maybe<&2, +List<Bool>>}
  {==}

def decode_encoding(capacity: Nat, encoded: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<Bool>>:
  match encoded:
    case None{}: None{}
    case Some{xs}: API.bitlist_deserialize(capacity, xs)

law list_roundtrip:
  for +capacity: Nat
  for +bits: +List<Bool>
  for +valid: {API.list_valid(capacity, bits) == True{} : Bool}
  {decode_encoding(capacity, API.bitlist_serialize(capacity, bits)) == Some{bits} : Maybe<&2, +List<Bool>>}
def list_roundtrip(capacity, bits, valid):
  %Equal.sym(Bool, API.list_valid(capacity, bits), True{}, valid) :
    {decode_encoding(capacity, Bytes.accept_bytes(_, P.pack(List.append(&2, Bool, bits, [True{}])))) == Some{bits} : Maybe<&2, +List<Bool>>}
  list_decode_packed(capacity, bits, valid)

law list_normative_encoding_complete:
  for +capacity: Nat
  for +bits: +List<Bool>
  for +valid: {API.list_valid(capacity, bits) == True{} : Bool}
  {decode_encoding(capacity, Spec.list_encoding(capacity, bits)) == Some{bits} : Maybe<&2, +List<Bool>>}
def list_normative_encoding_complete(capacity, bits, valid):
  %Refinement.bitlist_serialize_correct(capacity, bits) : {decode_encoding(capacity, _) == Some{bits} : Maybe<&2, +List<Bool>>}
  list_roundtrip(capacity, bits, valid)

law accepted_valid:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for decoded: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {API.list_valid(capacity, bits) == True{} : Bool}
def accepted_valid(capacity, xs, bits, decoded):
  %decoded : Decode.in_capacity(capacity, _)
  Decode.bitlist_decoded_capacity(capacity, xs)

law normative_image_decodes:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +valid: {API.list_valid(capacity, bits) == True{} : Bool}
  for encoded: {Spec.list_encoding(capacity, bits) == Some{xs} : Maybe<&2, +List<U32>>}
  {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
def normative_image_decodes(capacity, xs, bits, valid, encoded):
  %encoded : {decode_encoding(capacity, _) == Some{bits} : Maybe<&2, +List<Bool>>}
  list_normative_encoding_complete(capacity, bits, valid)

# Rejected input cannot equal any legal normative serialization. The converse
# (every accepted byte sequence re-encodes) remains a separate obligation.
law rejected_excludes_normative_image:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for valid: {API.list_valid(capacity, bits) == True{} : Bool}
  for rejected: {API.bitlist_deserialize(capacity, xs) == None{} : Maybe<&2, +List<Bool>>}
  for encoded: {Spec.list_encoding(capacity, bits) == Some{xs} : Maybe<&2, +List<U32>>}
  Empty
def rejected_excludes_normative_image(capacity, xs, bits, valid, rejected, encoded):
  W.false_true(Equal.cong(Maybe<&2, +List<Bool>>, Bool, U.present, None{}, Some{bits}, Equal.trans(Maybe<&2, +List<Bool>>, None{}, API.bitlist_deserialize(capacity, xs), Some{bits}, Equal.sym(Maybe<&2, +List<Bool>>, API.bitlist_deserialize(capacity, xs), None{}, rejected), normative_image_decodes(capacity, xs, bits, valid, encoded))))

law bounded_accept_preserves:
  for +ok: Bool
  for +xs: +List<Bool>
  for +bits: +List<Bool>
  for +decoded: {D.accept(ok, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {Some{xs} == Some{bits} : Maybe<&2, +List<Bool>>}
def bounded_accept_preserves(ok, xs, bits, decoded):
  match ok:
    case False{}:
      Empty.absurd({Some{xs} == Some{bits} : Maybe<&2, +List<Bool>>}, W.false_true(Equal.cong(Maybe<&2, +List<Bool>>, Bool, U.present, None{}, Some{bits}, decoded)))
    case True{}: decoded

law bounded_preserves_value:
  for +capacity: Nat
  for +r: Maybe<&2, +List<Bool>>
  for +bits: +List<Bool>
  for +decoded: {D.bounded(capacity, r) == Some{bits} : Maybe<&2, +List<Bool>>}
  {r == Some{bits} : Maybe<&2, +List<Bool>>}
def bounded_preserves_value(capacity, r, bits, decoded):
  match r:
    case None{}: decoded
    case Some{xs}:
      bounded_accept_preserves(Nat.is_le(List.length(&2, Bool, xs), capacity), xs, bits, decoded)

law checked_preserves_delimiter:
  for +ok: Bool
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +decoded: {D.list_checked(ok, capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {D.delimiter(List.reverse(&2, Bool, D.expand(xs)), 7n) == Some{bits} : Maybe<&2, +List<Bool>>}
def checked_preserves_delimiter(ok, capacity, xs, bits, decoded):
  match ok:
    case False{}:
      Empty.absurd({D.delimiter(List.reverse(&2, Bool, D.expand(xs)), 7n) == Some{bits} : Maybe<&2, +List<Bool>>}, W.false_true(Equal.cong(Maybe<&2, +List<Bool>>, Bool, U.present, None{}, Some{bits}, decoded)))
    case True{}:
      bounded_preserves_value(capacity, D.delimiter(List.reverse(&2, Bool, D.expand(xs)), 7n), bits, decoded)

law accepted_delimiter_shape:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +decoded: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {List.reverse(&2, Bool, D.expand(xs)) == Delimiter.zeros(Delimiter.removed(List.reverse(&2, Bool, D.expand(xs)), 7n), True{} <> List.reverse(&2, Bool, bits)) : +List<Bool>}
def accepted_delimiter_shape(capacity, xs, bits, decoded):
  Delimiter.delimiter_remove_insert(List.reverse(&2, Bool, D.expand(xs)), 7n, bits, checked_preserves_delimiter(Pack.valid_go(xs, True{}), capacity, xs, bits, decoded))
