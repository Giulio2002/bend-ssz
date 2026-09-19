import Base
import ../types/schema.bend as T
import ../src/schema.bend as Schema
import ../src/codec.bend as I
import ../src/primitives.bend as Primitive
import ../spec/codec.bend as Encoding
import ../spec/value_domain.bend as S
import ./codec_composition.bend as Codec

law present_correct:
  for result: Maybe<&2, +List<U32>>
  {Primitive.is_some(result) == S.present(result) : Bool}
def present_correct(result):
  match result:
    case None{}: {==}
    case Some{bytes}: {==}

# This characterizes the CURRENT public valid API precisely as serialization
# validity. It deliberately does not claim that the uint256 root mixer domain
# follows for every mathematical bitlist. That public-domain gap remains open.
law serializable_correct:
  for +schema: T.Schema
  for +value: T.Value
  for legal: {Schema.valid(schema) == True{} : Bool}
  {I.valid(schema, value) == S.serializable(schema, value) : Bool}
def serializable_correct(schema, value, legal):
  %Equal.sym(Maybe<&2, +List<U32>>, I.serialize(schema, value), Encoding.encoding_for_legal_type(schema, value), Codec.serialize_for_valid_type(schema, value, legal)) : {Primitive.is_some(_) == S.serializable(schema, value) : Bool}
  present_correct(Encoding.encoding_for_legal_type(schema, value))
