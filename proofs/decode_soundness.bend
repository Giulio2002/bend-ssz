import Base
import ../types/schema.bend as T
import ../src/ssz.bend as API
import ../spec/codec.bend as Encoding
import ../spec/decoding_relation.bend as S
import ./codec_composition.bend as Codec
import ./decode_canonical.bend as Canonical

# This is refinement to an independent encoding-image relation, beyond actual
# re-encoding. It is soundness only; it does not prove completeness or uniqueness.
law accepted_decodes:
  for +schema: T.Schema
  for +input: +List<U32>
  for +value: T.Value
  for +accepted: {API.deserialize(schema, input) == Some{value} : Maybe<&2, T.Value>}
  S.decodes(schema, input, value)
def accepted_decodes(schema, input, value, accepted):
  Equal.trans(Maybe<&2, +List<U32>>, Encoding.encoding_for_legal_type(schema, value), API.serialize(schema, value), Some{input}, Equal.sym(Maybe<&2, +List<U32>>, API.serialize(schema, value), Encoding.encoding_for_legal_type(schema, value), Codec.serialize_for_valid_type(schema, value, Canonical.accepted_type_valid(schema, input, value, accepted))), Canonical.public_accepted_serializes_exactly(schema, input, value, accepted))

def sound_result(schema: T.Schema, input: +List<U32>, result: Maybe<&2, T.Value>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: S.decodes(schema, input, value)

law result_sound:
  for +schema: T.Schema
  for +input: +List<U32>
  for +result: Maybe<&2, T.Value>
  for evaluation: {API.deserialize(schema, input) == result : Maybe<&2, T.Value>}
  sound_result(schema, input, result)
def result_sound(schema, input, result, evaluation):
  match result:
    case None{}: Unit{}
    case Some{value}: accepted_decodes(schema, input, value, evaluation)

law deserialize_sound:
  for +schema: T.Schema
  for +input: +List<U32>
  sound_result(schema, input, API.deserialize(schema, input))
def deserialize_sound(schema, input):
  result_sound(schema, input, API.deserialize(schema, input), {==})

law outside_result_rejected:
  for +schema: T.Schema
  for +input: +List<U32>
  for +result: Maybe<&2, T.Value>
  for evaluation: {API.deserialize(schema, input) == result : Maybe<&2, T.Value>}
  for outside: S.outside_image(schema, input)
  {result == None{} : Maybe<&2, T.Value>}
def outside_result_rejected(schema, input, result, evaluation, outside):
  match result:
    case None{}: {==}
    case Some{value}: Empty.absurd({Some{value} == None{} : Maybe<&2, T.Value>}, outside(value, accepted_decodes(schema, input, value, evaluation)))

# Every byte string outside the independent canonical encoding image is rejected.
# The converse (no valid image is rejected) remains the completeness obligation.
law outside_image_rejected:
  for +schema: T.Schema
  for +input: +List<U32>
  for outside: S.outside_image(schema, input)
  {API.deserialize(schema, input) == None{} : Maybe<&2, T.Value>}
def outside_image_rejected(schema, input, outside):
  outside_result_rejected(schema, input, API.deserialize(schema, input), {==}, outside)
