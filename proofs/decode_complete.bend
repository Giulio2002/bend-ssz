import Base
import ../types/schema.bend as T
import ../src/ssz.bend as API
import ../src/decode.bend as D
import ../src/schema.bend as I
import ../src/codec.bend as Codec
import ../src/packing.bend as Pack
import ../src/lists.bend as Lists
import ../spec/codec.bend as S
import ../spec/primitives.bend as SP
import ../spec/decoding_relation.bend as Relation
import ../spec/type_legality.bend as Legal
import ./decode_goal.bend as G
import ./decode_inverse.bend as Inverse
import ./decode_shape.bend as Shape
import ./decode_budget.bend as Budget
import ./decode_canonical.bend as Canonical
import ./decode_soundness.bend as Soundness
import ./codec_composition.bend as Composition
import ./packing.bend as Packing
import ./type_validator_complete.bend as ValidatorComplete
import ./type_validator_soundness.bend as ValidatorSound
import ./word_facts.bend as W

# Canonical decoding completeness for the exported API: every byte string in
# the independent canonical encoding image of a validated schema is accepted
# by the actual deserializer and decodes to exactly the encoded value. With
# decode_soundness this is the exact decoding relation, and it makes the
# canonical encoding injective (the decoded value is unique).
def bytes_present(r: Maybe<&2, +List<U32>>) -> Bool:
  match r:
    case None{}: False{}
    case Some{v}: True{}

def bytes_contents(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case None{}: []
    case Some{v}: v

law encoded_part:
  for +schema: T.Schema
  for +value: T.Value
  for +ps: +List<T.Part>
  for +bytes: +List<U32>
  for known: G.single_goal(schema, value, ps)
  for encoded: {S.bytes(Some{ps}) == Some{bytes} : Maybe<&2, +List<U32>>}
  G.single_bytes(schema, value, bytes)
def encoded_part(schema, value, ps, bytes, known, encoded):
  match ps:
    case Nil{}: Empty.absurd(G.single_bytes(schema, value, bytes), W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, bytes_present, None{}, Some{bytes}, encoded)))
    case Con{T.Fixed{xs}, Nil{}}:
      %Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, bytes_contents, Some{xs}, Some{bytes}, encoded) : G.single_bytes(schema, value, _)
      known
    case Con{T.Variable{xs}, Nil{}}:
      %Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, bytes_contents, Some{xs}, Some{bytes}, encoded) : G.single_bytes(schema, value, _)
      known
    case Con{T.Fixed{xs}, Con{p, q}}: Empty.absurd(G.single_bytes(schema, value, bytes), W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, bytes_present, None{}, Some{bytes}, encoded)))
    case Con{T.Variable{xs}, Con{p, q}}: Empty.absurd(G.single_bytes(schema, value, bytes), W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, bytes_present, None{}, Some{bytes}, encoded)))

law encoded_result:
  for +schema: T.Schema
  for +value: T.Value
  for +result: Maybe<&2, +List<T.Part>>
  for +bytes: +List<U32>
  for known: G.single_result(schema, value, result)
  for encoded: {S.bytes(result) == Some{bytes} : Maybe<&2, +List<U32>>}
  G.single_bytes(schema, value, bytes)
def encoded_result(schema, value, result, bytes, known, encoded):
  match result:
    case None{}: Empty.absurd(G.single_bytes(schema, value, bytes), W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, bytes_present, None{}, Some{bytes}, encoded)))
    case Some{ps}: encoded_part(schema, value, ps, bytes, known, encoded)

law encoded_inverse:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +legal: {I.valid(schema) == True{} : Bool}
  for encoded: {S.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  G.single_bytes(schema, value, bytes)
def encoded_inverse(schema, value, bytes, legal, encoded):
  encoded_result(schema, value, S.parts(value, schema), bytes, Inverse.head_view(schema, value, S.parts(value, schema), legal, Inverse.inverse(value, schema, Shape.ok_single(schema, legal))), encoded)

law domain_gate:
  for +xs: +List<U32>
  for domain: {SP.bytes_domain(xs) == True{} : Bool}
  {Pack.valid_go(xs, True{}) == True{} : Bool}
def domain_gate(xs, domain):
  Equal.trans(Bool, Pack.valid_go(xs, True{}), SP.bytes_domain(xs), True{}, Packing.valid_go_correct(xs, True{}), domain)

law raw_accepts:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +legal: {I.valid(schema) == True{} : Bool}
  for decoded: {D.decode_go(Nat.mul(2n+I.weight(schema), 2n+Lists.length(U32, bytes)), schema, bytes, [], T.EmptyItems{}) == Some{value} : Maybe<&2, T.Value>}
  for domain: {SP.bytes_domain(bytes) == True{} : Bool}
  for +serialized: {Codec.serialize(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>}
def raw_accepts(schema, value, bytes, legal, decoded, domain, serialized):
  %Equal.sym(Bool, I.valid(schema), True{}, legal) : {D.gate(Bool.and(_, Pack.valid_go(bytes, True{})), u => D.canonical(D.decode_go(Nat.mul(2n+I.weight(schema), 2n+Lists.length(U32, bytes)), schema, bytes, [], T.EmptyItems{}), schema, bytes)) == Some{value} : Maybe<&2, T.Value>}
  %Equal.sym(Bool, Pack.valid_go(bytes, True{}), True{}, domain_gate(bytes, domain)) : {D.gate(Bool.and(True{}, _), u => D.canonical(D.decode_go(Nat.mul(2n+I.weight(schema), 2n+Lists.length(U32, bytes)), schema, bytes, [], T.EmptyItems{}), schema, bytes)) == Some{value} : Maybe<&2, T.Value>}
  %Equal.sym(Maybe<&2, T.Value>, D.decode_go(Nat.mul(2n+I.weight(schema), 2n+Lists.length(U32, bytes)), schema, bytes, [], T.EmptyItems{}), Some{value}, decoded) : {D.canonical(_, schema, bytes) == Some{value} : Maybe<&2, T.Value>}
  Canonical.canonical_preserves_encoding(schema, bytes, value, serialized)

law accepts_known:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +legal: {I.valid(schema) == True{} : Bool}
  for known: G.single_bytes(schema, value, bytes)
  for +serialized: {Codec.serialize(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>}
def accepts_known(schema, value, bytes, legal, known, serialized):
  (decoded, domain) = known
  raw_accepts(schema, value, bytes, legal, Budget.accepts_finite(schema, bytes, value, G.fuel(value), legal, decoded), domain, serialized)

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
  accepts_known(schema, value, bytes, legal, encoded_inverse(schema, value, bytes, legal, encoded),
    Equal.trans(Maybe<&2, +List<U32>>, Codec.serialize(schema, value), S.encoding_for_legal_type(schema, value), Some{bytes}, Composition.serialize_for_valid_type(schema, value, legal), encoded))

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
