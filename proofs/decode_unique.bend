import Base
import ../types/schema.bend as T
import ../src/model.bend as API
import ../src/schema.bend as I
import ../spec/codec.bend as S
import ./decode_image.bend as Image

# Injectivity of the canonical encoding on a schema the implementation's
# validator accepts, with only the decoder's completeness (decode_image) in its
# import closure.
#
# decode_complete.valid_unique is the same law; importing decode_complete also
# checks type_validator_complete (the whole compatibility_* chain, ~3 s) for
# `public_complete`, which only its type_legal forms (image_unique) need. A
# per-name uniqueness law has the validator's acceptance of its own schema by
# evaluation ({I.valid(schema) == True}), so it uses this module instead.

def value_contents(r: Maybe<&2, T.Value>) -> T.Value:
  match r:
    case None{}: T.NullValue{}
    case Some{v}: v

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
      Equal.sym(Maybe<&2, T.Value>, API.deserialize(schema, bytes), Some{a}, Image.image_accepted(schema, a, bytes, valid, first)),
      Image.image_accepted(schema, b, bytes, valid, second)))
