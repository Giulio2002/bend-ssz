import Base
import ../types/schema.bend as T
import ../src/model.bend as API
import ../src/decode.bend as D
import ../src/schema.bend as I
import ../src/codec.bend as Codec
import ../spec/codec.bend as S
import ../spec/primitives.bend as SP
import ../spec/decoding_relation.bend as Relation
import ../spec/type_legality.bend as Legal
import ./decode_image.bend as Image
import ./decode_canonical.bend as Canonical
import ./decode_soundness.bend as Soundness
import ./codec_composition.bend as Composition
import ./type_validator_complete.bend as ValidatorComplete
import ./type_validator_soundness.bend as ValidatorSound
import ./word_facts.bend as W

# Canonical decoding completeness for the exported API: every byte string in
# the independent canonical encoding image of a validated schema is accepted
# by the actual deserializer and decodes to exactly the encoded value. With
# decode_soundness this is the exact decoding relation, and it makes the
# canonical encoding injective (the decoded value is unique).
#
# The packed cursor decoder proves this in proofs/decode_image.bend, by the
# decoder's own recursion (proofs/complete_decode.go_complete); this module is
# the public statement and its consequences.

# Completeness: the canonical image of every validated schema is accepted with
# exactly its encoded value, for arbitrary values and byte strings.
law image_accepted:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +legal: {I.valid(schema) == True{} : Bool}
  for +encoded: {S.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>}
def image_accepted(schema, value, bytes, legal, encoded):
  Image.image_accepted(schema, value, bytes, legal, encoded)

def value_present(r: Maybe<&2, T.Value>) -> Bool:
  match r:
    case None{}: False{}
    case Some{v}: True{}

def value_contents(r: Maybe<&2, T.Value>) -> T.Value:
  match r:
    case None{}: T.NullValue{}
    case Some{v}: v

# The independent canonical image is decoded by the public API exactly.
law normative_image_accepted:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for legal: Legal.type_legal(schema)
  for +encoded: {S.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>}
def normative_image_accepted(schema, value, bytes, legal, encoded):
  image_accepted(schema, value, bytes, ValidatorComplete.public_complete(schema, legal), encoded)

law decoding_exact:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +value: T.Value
  for legal: Legal.type_legal(schema)
  ({API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>} -> Relation.decodes(schema, bytes, value)) & (Relation.decodes(schema, bytes, value) -> {API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>})
def decoding_exact(schema, bytes, value, legal):
  (accepted => Soundness.accepted_decodes(schema, bytes, value, accepted),
   encoded => image_accepted(schema, value, bytes, ValidatorComplete.public_complete(schema, legal), encoded))

law valid_unique:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +a: T.Value
  for +b: T.Value
  for +valid: {I.valid(schema) == True{} : Bool}
  for +first: {S.encoding_for_legal_type(schema, a) == Some{bytes} : Maybe<&2, +List<U32>>}
  for +second: {S.encoding_for_legal_type(schema, b) == Some{bytes} : Maybe<&2, +List<U32>>}
  {a == b : T.Value}
def valid_unique(schema, bytes, a, b, valid, first, second):
  Equal.cong(Maybe<&2, T.Value>, T.Value, value_contents, Some{a}, Some{b},
    Equal.trans(Maybe<&2, T.Value>, Some{a}, API.deserialize(schema, bytes), Some{b},
      Equal.sym(Maybe<&2, T.Value>, API.deserialize(schema, bytes), Some{a}, image_accepted(schema, a, bytes, valid, first)),
      image_accepted(schema, b, bytes, valid, second)))

# The independent canonical encoding is injective on every legal type.
law image_unique:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +a: T.Value
  for +b: T.Value
  for legal: Legal.type_legal(schema)
  for +first: {S.encoding_for_legal_type(schema, a) == Some{bytes} : Maybe<&2, +List<U32>>}
  for +second: {S.encoding_for_legal_type(schema, b) == Some{bytes} : Maybe<&2, +List<U32>>}
  {a == b : T.Value}
def image_unique(schema, bytes, a, b, legal, first, second):
  valid_unique(schema, bytes, a, b, ValidatorComplete.public_complete(schema, legal), first, second)

law valid_rejected_outside:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +valid: {I.valid(schema) == True{} : Bool}
  for +rejected: {API.deserialize(schema, bytes) == None{} : Maybe<&2, T.Value>}
  Relation.outside_image(schema, bytes)
def valid_rejected_outside(schema, bytes, valid, rejected):
  value => encoded => W.false_true(Equal.cong(Maybe<&2, T.Value>, Bool, value_present, None{}, Some{value},
    Equal.trans(Maybe<&2, T.Value>, None{}, API.deserialize(schema, bytes), Some{value}, Equal.sym(Maybe<&2, T.Value>, API.deserialize(schema, bytes), None{}, rejected), image_accepted(schema, value, bytes, valid, encoded))))

law rejection_exact:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for legal: Legal.type_legal(schema)
  ({API.deserialize(schema, bytes) == None{} : Maybe<&2, T.Value>} -> Relation.outside_image(schema, bytes)) & (Relation.outside_image(schema, bytes) -> {API.deserialize(schema, bytes) == None{} : Maybe<&2, T.Value>})
def rejection_exact(schema, bytes, legal):
  (rejected => valid_rejected_outside(schema, bytes, ValidatorComplete.public_complete(schema, legal), rejected),
   outside => Soundness.outside_image_rejected(schema, bytes, outside))
