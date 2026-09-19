import Base
import ../types/schema.bend as T
import ./codec.bend as Codec

# Normative canonical-image relation for a legal SSZ type. It references only
# independent serialization semantics, never an implementation decoder.
# Independent type legality and proof of decoding completeness are separate.
def decodes(schema: T.Schema, input: +List<U32>, value: T.Value) -> Type:
  {Codec.encoding_for_legal_type(schema, value) == Some{input} : Maybe<&2, +List<U32>>}

def outside_image(+schema: T.Schema, +input: +List<U32>) -> Type:
  @value: T.Value -> decodes(schema, input, value) -> Empty
