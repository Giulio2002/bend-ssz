import Base
import ../types/schema.bend as T
import ../src/codec.bend as I
import ../src/schema.bend as IS
import ../spec/codec.bend as S
import ../spec/type_legality.bend as Legal
import ./type_legality_structure.bend as Structure
import ./codec_composition.bend as Codec
import ./codec_helpers.bend as Helpers

# The internal actual encoder refines normative semantics for every independently
# legal schema. No premise about the implementation validator is used here.
law encoding_for_normative_type:
  for +schema: T.Schema
  for +value: T.Value
  for legal: Legal.type_legal(schema)
  {I.unwrap(I.encode(value, schema)) == S.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}
def encoding_for_normative_type(schema, value, legal):
  %Codec.parts_correct(value, schema, Structure.public_legal_well_formed(schema, legal)) : {I.unwrap(I.encode(value, schema)) == S.bytes(_) : Maybe<&2, +List<U32>>}
  Helpers.unwrap_correct(I.encode(value, schema))

law gated_rejection:
  for +ok: Bool
  for +parts: Maybe<&2, +List<T.Part>>
  for rejected: {I.unwrap(parts) == None{} : Maybe<&2, +List<U32>>}
  {I.unwrap(I.gate(ok, u => parts)) == None{} : Maybe<&2, +List<U32>>}
def gated_rejection(ok, parts, rejected):
  match ok:
    case False{}: {==}
    case True{}: rejected

# One direction of value rejection at the actual public entry point. The other
# direction requires showing the actual validator accepts every normative type.
law normative_invalid_value_rejected:
  for +schema: T.Schema
  for +value: T.Value
  for legal: Legal.type_legal(schema)
  for rejected: {S.encoding_for_legal_type(schema, value) == None{} : Maybe<&2, +List<U32>>}
  {I.serialize(schema, value) == None{} : Maybe<&2, +List<U32>>}
def normative_invalid_value_rejected(schema, value, legal, rejected):
  gated_rejection(IS.valid(schema), I.encode(value, schema), Equal.trans(Maybe<&2, +List<U32>>, I.unwrap(I.encode(value, schema)), S.encoding_for_legal_type(schema, value), None{}, encoding_for_normative_type(schema, value, legal), rejected))
