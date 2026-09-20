import Base
import ./types/schema.bend as T
import ./src/ssz.bend as API
import ./src/schema.bend as Schema
import ./src/decode.bend as Decoder
import ./src/lists.bend as Lists
import ./src/packing.bend as Packing
import ./src/packed.bend as Packed
import ./src/cvalue.bend as CValue
import ./src/codec.bend as Codec
import ./src/root.bend as Root
import ./spec/type_legality.bend as Legal
import ./spec/codec.bend as Encoding
import ./spec/decoding_relation.bend as Decoding
import ./spec/root_relation.bend as Roots
import ./spec/value_domain.bend as Domain
import ./spec/primitives.bend as Bytes
import ./proofs/type_validator_soundness.bend as ValidatorSound
import ./proofs/type_validator_complete.bend as ValidatorComplete
import ./proofs/codec_composition.bend as Composition
import ./proofs/decode_soundness.bend as DecodeSound
import ./proofs/decode_complete.bend as DecodeComplete
import ./proofs/decode_canonical.bend as Canonical
import ./proofs/root_public.bend as RootLaws
import ./proofs/word_facts.bend as W
import ./types/fulu.bend as Fulu
import ./proofs/fulu_named.bend as Named
import ./proofs/fulu_adapter_complete.bend as AdapterComplete
import ./proofs/codec_shape.bend as CodecShape
import ./proofs/representation_erasure.bend as Erasure
import ./spec/representation.bend as Shape

# End-to-end public SSZ laws. Every law is universally quantified over the
# exported API's schema/value/byte inputs; the specifications are the
# independent spec/*.bend transcriptions of simple-serialize.md:
#   Legal.type_legal         -- legal SSZ types (illegal types section)
#   Encoding.encoding_for_legal_type -- serialize()
#   Decoding.decodes / outside_image -- canonical deserialization image
#   Roots.root_for_legal_type -- hash_tree_root() of a structurally valid
#                               value: packing of basic objects, padding,
#                               minimal-depth Merkleization over child roots,
#                               progressive Merkleization, active fields,
#                               length and selector mixing. No whole-object
#                               encoding is required (see ROOT_DOMAIN.bend).
#   Domain.root_domain       -- structurally valid values (Domain.root_valid)
#                               whose mixed lengths are uint256.

# ---------------------------------------------------------------------------
# Helpers deciding type legality through the (proven equivalent) validator.

law decide_invalid:
  for +schema: T.Schema
  for +b: Bool
  for +same: {Schema.valid(schema) == b : Bool}
  for illegal: Legal.type_legal(schema) -> Empty
  {b == False{} : Bool}
def decide_invalid(schema, b, same, illegal):
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, illegal(ValidatorSound.public_sound(schema, same)))

law illegal_invalid:
  for +schema: T.Schema
  for illegal: Legal.type_legal(schema) -> Empty
  {Schema.valid(schema) == False{} : Bool}
def illegal_invalid(schema, illegal): decide_invalid(schema, Schema.valid(schema), {==}, illegal)

law serialize_illegal:
  for +schema: T.Schema
  for +value: T.Value
  for illegal: Legal.type_legal(schema) -> Empty
  {API.serialize(schema, value) == None{} : Maybe<&2, +List<U32>>}
def serialize_illegal(schema, value, illegal):
  %Equal.sym(Bool, Schema.valid(schema), False{}, illegal_invalid(schema, illegal)) : {Codec.unwrap(Codec.gate(_, u => Codec.encode(value, schema))) == None{} : Maybe<&2, +List<U32>>}
  {==}

# serialize: exactly the normative encoding for legal types; rejection of
# every value of an illegal type.
law serialize_correct:
  for +schema: T.Schema
  for +value: T.Value
  (Legal.type_legal(schema) -> {API.serialize(schema, value) == Encoding.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}) & ((Legal.type_legal(schema) -> Empty) -> {API.serialize(schema, value) == None{} : Maybe<&2, +List<U32>>})
def serialize_correct(schema, value):
  (legal => Composition.serialize_for_valid_type(schema, value, ValidatorComplete.public_complete(schema, legal)),
   illegal => serialize_illegal(schema, value, illegal))

# ---------------------------------------------------------------------------
# deserialize: accepted exactly on the canonical image of a legal type, with
# exactly the encoded value (sound, complete; the image is injective).

law accepted_spec:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +value: T.Value
  for +accepted: {API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>}
  Legal.type_legal(schema) & Decoding.decodes(schema, bytes, value)
def accepted_spec(schema, bytes, value, accepted):
  (ValidatorSound.public_sound(schema, Canonical.accepted_type_valid(schema, bytes, value, accepted)), DecodeSound.accepted_decodes(schema, bytes, value, accepted))

law spec_accepted:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +value: T.Value
  for spec: Legal.type_legal(schema) & Decoding.decodes(schema, bytes, value)
  {API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>}
def spec_accepted(schema, bytes, value, spec):
  (legal, encoded) = spec
  DecodeComplete.normative_image_accepted(schema, value, bytes, legal, encoded)

law deserialize_correct:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +value: T.Value
  ({API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>} -> Legal.type_legal(schema) & Decoding.decodes(schema, bytes, value)) & ((Legal.type_legal(schema) & Decoding.decodes(schema, bytes, value)) -> {API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>})
def deserialize_correct(schema, bytes, value):
  (accepted => accepted_spec(schema, bytes, value, accepted), spec => spec_accepted(schema, bytes, value, spec))

# Injectivity of the canonical image (no two values share an encoding).
law deserialize_unique:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +a: T.Value
  for +b: T.Value
  for legal: Legal.type_legal(schema)
  for first: Decoding.decodes(schema, bytes, a)
  for second: Decoding.decodes(schema, bytes, b)
  {a == b : T.Value}
def deserialize_unique(schema, bytes, a, b, legal, first, second):
  DecodeComplete.image_unique(schema, bytes, a, b, legal, first, second)

# ---------------------------------------------------------------------------
# Rejection: deserialize returns None exactly when (for a legal type) the
# input is outside the canonical image; every input of an illegal type is
# rejected. Resource exhaustion is not a rejection path: the traversal budget
# is proven sufficient (decode_budget/decode_stability).

law reject_decide:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +b: Bool
  for +same: {Schema.valid(schema) == b : Bool}
  for spec: Legal.type_legal(schema) -> Decoding.outside_image(schema, bytes)
  {API.deserialize(schema, bytes) == None{} : Maybe<&2, T.Value>}
def reject_decide(schema, bytes, b, same, spec):
  match b:
    case True{}: DecodeSound.outside_image_rejected(schema, bytes, spec(ValidatorSound.public_sound(schema, same)))
    case False{}:
      %Equal.sym(Bool, Schema.valid(schema), False{}, same) : {CValue.result(Decoder.gate(_, u => Decoder.measured(Packed.pack_list(bytes), schema))) == None{} : Maybe<&2, T.Value>}
      {==}

law deserialize_rejection_correct:
  for +schema: T.Schema
  for +bytes: +List<U32>
  ({API.deserialize(schema, bytes) == None{} : Maybe<&2, T.Value>} -> Legal.type_legal(schema) -> Decoding.outside_image(schema, bytes)) & ((Legal.type_legal(schema) -> Decoding.outside_image(schema, bytes)) -> {API.deserialize(schema, bytes) == None{} : Maybe<&2, T.Value>})
def deserialize_rejection_correct(schema, bytes):
  (rejected => legal => DecodeComplete.valid_rejected_outside(schema, bytes, ValidatorComplete.public_complete(schema, legal), rejected),
   spec => reject_decide(schema, bytes, Schema.valid(schema), {==}, spec))

# ---------------------------------------------------------------------------
# hash_tree_root: every returned root is exactly 32 bytes and satisfies the
# independent relational root semantics of a structurally valid value of a
# legal type; conversely every root related to a value by that semantics is
# exactly the returned root (so the API result is characterized exactly);
# every value of the independent root domain (structural validity and
# uint256-representable mixed lengths, no encoding premise) has a root.

law root_accepted:
  for +schema: T.Schema
  for +value: T.Value
  for +root: +List<U32>
  for +accepted: {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}
  Legal.type_legal(schema) & Roots.root_for_legal_type(schema, value, root) & {Bytes.byte_scope(32n, root) == True{} : Bool}
def root_accepted(schema, value, root, accepted):
  (ValidatorSound.public_sound(schema, RootLaws.accepted_legal(schema, value, root, accepted)), (RootLaws.root_sound(schema, value, root, accepted), RootLaws.root_bytes(schema, value, root, accepted)))

law hash_tree_root_correct:
  for +schema: T.Schema
  for +value: T.Value
  (@+root: +List<U32> -> @+accepted: {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} -> Legal.type_legal(schema) & Roots.root_for_legal_type(schema, value, root) & {Bytes.byte_scope(32n, root) == True{} : Bool}) & (Legal.type_legal(schema) -> @+root: +List<U32> -> Roots.root_for_legal_type(schema, value, root) -> {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}) & (Legal.type_legal(schema) -> {Domain.root_domain(schema, value) == True{} : Bool} -> Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}))
def hash_tree_root_correct(schema, value):
  (root => accepted => root_accepted(schema, value, root, accepted),
   (legal => root => rel => RootLaws.root_complete(schema, value, root, ValidatorComplete.public_complete(schema, legal), rel),
    legal => domain => RootLaws.root_total(schema, value, ValidatorComplete.public_complete(schema, legal), domain)))

# ---------------------------------------------------------------------------
# Every frozen mainnet Fulu name (the closed index Fulu.Name has exactly the
# 109 names of schemas/fulu_mainnet.json, including names without official
# test cases). Fulu.Name.schema(name) is the independent transcription
# spec/fulu_schemas.bend; every public Fulu.X.{schema,to_ssz,from_ssz,valid,
# serialize,deserialize,hash_tree_root} is by definition Fulu.Name.* at
# Fulu.Name_X{}. Typed values convert to the neutral representation with
# checked inverse/preservation/shape-completeness laws.

def named_serialize(name: Fulu.Name) -> Type:
  @+value: Fulu.Name.Value(name) -> {Fulu.Name.serialize(name, value) == Encoding.encoding_for_legal_type(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value)) : Maybe<&2, +List<U32>>}

def named_deserialize(name: Fulu.Name) -> Type:
  @+bytes: +List<U32> -> @+value: Fulu.Name.Value(name) -> ({Fulu.Name.deserialize(name, bytes) == Some{value} : Maybe<&2, Fulu.Name.Value(name)>} -> Decoding.decodes(Fulu.Name.schema(name), bytes, Fulu.Name.to_ssz(name, value))) & (Decoding.decodes(Fulu.Name.schema(name), bytes, Fulu.Name.to_ssz(name, value)) -> {Fulu.Name.deserialize(name, bytes) == Some{value} : Maybe<&2, Fulu.Name.Value(name)>})

def named_rejection(name: Fulu.Name) -> Type:
  @+bytes: +List<U32> -> ({Fulu.Name.deserialize(name, bytes) == None{} : Maybe<&2, Fulu.Name.Value(name)>} -> Decoding.outside_image(Fulu.Name.schema(name), bytes)) & (Decoding.outside_image(Fulu.Name.schema(name), bytes) -> {Fulu.Name.deserialize(name, bytes) == None{} : Maybe<&2, Fulu.Name.Value(name)>})

def named_roots(name: Fulu.Name) -> Type:
  @+value: Fulu.Name.Value(name) -> (@+root: +List<U32> -> @+accepted: {Fulu.Name.hash_tree_root(name, value) == Some{root} : Maybe<&2, +List<U32>>} -> Roots.root_for_legal_type(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root) & {Bytes.byte_scope(32n, root) == True{} : Bool}) & (@+root: +List<U32> -> Roots.root_for_legal_type(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root) -> {Fulu.Name.hash_tree_root(name, value) == Some{root} : Maybe<&2, +List<U32>>}) & ({Domain.root_domain(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value)) == True{} : Bool} -> Exists(+List<U32>, root => {Fulu.Name.hash_tree_root(name, value) == Some{root} : Maybe<&2, +List<U32>>}))

def named_adapter(name: Fulu.Name) -> Type:
  @+value: Fulu.Name.Value(name) -> {Fulu.Name.from_ssz(name, Fulu.Name.to_ssz(name, value)) == Some{value} : Maybe<&2, Fulu.Name.Value(name)>}

law named_valid:
  for +name: Fulu.Name
  {Schema.valid(Fulu.Name.schema(name)) == True{} : Bool}
def named_valid(name): ValidatorComplete.public_complete(Fulu.Name.schema(name), Named.legal(name))

law preserved:
  for +name: Fulu.Name
  for +original: T.Value
  for +result: Maybe<&2, Fulu.Name.Value(name)>
  for +value: Fulu.Name.Value(name)
  for +same: {result == Some{value} : Maybe<&2, Fulu.Name.Value(name)>}
  for known: Named.preserves(name, original, result)
  {Fulu.Name.to_ssz(name, value) == original : T.Value}
def preserved(name, original, result, value, same, known):
  %same : Named.preserves(name, original, _)
  known

def named_present(name: Fulu.Name, r: Maybe<&2, Fulu.Name.Value(name)>) -> Bool:
  match r:
    case None{}: False{}
    case Some{v}: True{}

law named_accepted_result:
  for +name: Fulu.Name
  for +bytes: +List<U32>
  for +value: Fulu.Name.Value(name)
  for +r: Maybe<&2, T.Value>
  for +found: {API.deserialize(Fulu.Name.schema(name), bytes) == r : Maybe<&2, T.Value>}
  for +accepted: {Fulu.Name.decode_result(name, r) == Some{value} : Maybe<&2, Fulu.Name.Value(name)>}
  Decoding.decodes(Fulu.Name.schema(name), bytes, Fulu.Name.to_ssz(name, value))
def named_accepted_result(name, bytes, value, r, found, accepted):
  match r:
    case None{}: Empty.absurd(Decoding.decodes(Fulu.Name.schema(name), bytes, Fulu.Name.to_ssz(name, value)), W.false_true(Equal.cong(Maybe<&2, Fulu.Name.Value(name)>, Bool, x => named_present(name, x), None{}, Some{value}, accepted)))
    case Some{w}:
      %Equal.sym(T.Value, Fulu.Name.to_ssz(name, value), w, preserved(name, w, Fulu.Name.from_ssz(name, w), value, accepted, Named.sound(name, w))) : Decoding.decodes(Fulu.Name.schema(name), bytes, _)
      DecodeSound.accepted_decodes(Fulu.Name.schema(name), bytes, w, found)

law named_decoded:
  for +name: Fulu.Name
  for +bytes: +List<U32>
  for +value: Fulu.Name.Value(name)
  for +encoded: {Encoding.encoding_for_legal_type(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value)) == Some{bytes} : Maybe<&2, +List<U32>>}
  {Fulu.Name.deserialize(name, bytes) == Some{value} : Maybe<&2, Fulu.Name.Value(name)>}
def named_decoded(name, bytes, value, encoded):
  %Equal.sym(Maybe<&2, T.Value>, API.deserialize(Fulu.Name.schema(name), bytes), Some{Fulu.Name.to_ssz(name, value)}, DecodeComplete.image_accepted(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), bytes, named_valid(name), encoded)) : {Fulu.Name.decode_result(name, _) == Some{value} : Maybe<&2, Fulu.Name.Value(name)>}
  Named.inverse(name, value)

law decoded_shape:
  for +schema: T.Schema
  for +bytes: +List<U32>
  for +w: T.Value
  for +encoded: {Encoding.encoding_for_legal_type(schema, w) == Some{bytes} : Maybe<&2, +List<U32>>}
  {Shape.shape(w, schema) == True{} : Bool}
def decoded_shape(schema, bytes, w, encoded):
  %encoded : CodecShape.bytes_shape(Shape.shape(w, schema), _)
  CodecShape.encoding_shape(schema, w)

law named_rejected_result:
  for +name: Fulu.Name
  for +bytes: +List<U32>
  for +r: Maybe<&2, T.Value>
  for +found: {API.deserialize(Fulu.Name.schema(name), bytes) == r : Maybe<&2, T.Value>}
  for +rejected: {Fulu.Name.decode_result(name, r) == None{} : Maybe<&2, Fulu.Name.Value(name)>}
  Decoding.outside_image(Fulu.Name.schema(name), bytes)
def named_rejected_result(name, bytes, r, found, rejected):
  match r:
    case None{}: DecodeComplete.valid_rejected_outside(Fulu.Name.schema(name), bytes, named_valid(name), found)
    case Some{w}: Empty.absurd(Decoding.outside_image(Fulu.Name.schema(name), bytes), W.false_true(Equal.trans(Bool, False{}, AdapterComplete.present(Fulu.Name.Value(name), Fulu.Name.from_ssz(name, w)), True{}, Equal.cong(Maybe<&2, Fulu.Name.Value(name)>, Bool, x => AdapterComplete.present(Fulu.Name.Value(name), x), None{}, Fulu.Name.from_ssz(name, w), Equal.sym(Maybe<&2, Fulu.Name.Value(name)>, Fulu.Name.from_ssz(name, w), None{}, rejected)), Named.complete(name, w, Erasure.shape_erased_true(w, Fulu.Name.schema(name), decoded_shape(Fulu.Name.schema(name), bytes, w, DecodeSound.accepted_decodes(Fulu.Name.schema(name), bytes, w, found)))))))

law named_root_accepted:
  for +name: Fulu.Name
  for +value: Fulu.Name.Value(name)
  for +root: +List<U32>
  for +accepted: {Fulu.Name.hash_tree_root(name, value) == Some{root} : Maybe<&2, +List<U32>>}
  Roots.root_for_legal_type(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root) & {Bytes.byte_scope(32n, root) == True{} : Bool}
def named_root_accepted(name, value, root, accepted):
  (RootLaws.root_sound(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root, accepted), RootLaws.root_bytes(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root, accepted))

law named_outside:
  for +name: Fulu.Name
  for +bytes: +List<U32>
  for outside: Decoding.outside_image(Fulu.Name.schema(name), bytes)
  {Fulu.Name.deserialize(name, bytes) == None{} : Maybe<&2, Fulu.Name.Value(name)>}
def named_outside(name, bytes, outside):
  %Equal.sym(Maybe<&2, T.Value>, API.deserialize(Fulu.Name.schema(name), bytes), None{}, DecodeSound.outside_image_rejected(Fulu.Name.schema(name), bytes, outside)) : {Fulu.Name.decode_result(name, _) == None{} : Maybe<&2, Fulu.Name.Value(name)>}
  {==}

law fulu_types_correct:
  for +name: Fulu.Name
  Legal.type_legal(Fulu.Name.schema(name)) & named_serialize(name) & named_deserialize(name) & named_rejection(name) & named_roots(name) & named_adapter(name)
def fulu_types_correct(name):
  (Named.legal(name),
   (value => Composition.serialize_for_valid_type(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), named_valid(name)),
    (bytes => value => (accepted => named_accepted_result(name, bytes, value, API.deserialize(Fulu.Name.schema(name), bytes), {==}, accepted), encoded => named_decoded(name, bytes, value, encoded)),
     (bytes => (rejected => named_rejected_result(name, bytes, API.deserialize(Fulu.Name.schema(name), bytes), {==}, rejected), outside => named_outside(name, bytes, outside)),
      (value => (root => accepted => named_root_accepted(name, value, root, accepted), (root => rel => RootLaws.root_complete(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root, named_valid(name), rel), domain => RootLaws.root_total(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), named_valid(name), domain))),
       value => Named.inverse(name, value))))))


# ---------------------------------------------------------------------------
# Nonvacuity witnesses: the premises above are satisfiable by concrete legal
# types, canonical images, rejected inputs and valid values (checked by
# evaluation of the independent definitions only).

law legal_boolean_exists:
  Legal.type_legal(T.Boolean{})
def legal_boolean_exists(): {==}

law boolean_image_exists:
  Decoding.decodes(T.Boolean{}, [1], T.BooleanValue{True{}})
def boolean_image_exists(): {==}

law boolean_image_decoded:
  {API.deserialize(T.Boolean{}, [1]) == Some{T.BooleanValue{True{}}} : Maybe<&2, T.Value>}
def boolean_image_decoded(): spec_accepted(T.Boolean{}, [1], T.BooleanValue{True{}}, (legal_boolean_exists(), boolean_image_exists()))

law boolean_rejects_two:
  {API.deserialize(T.Boolean{}, [2]) == None{} : Maybe<&2, T.Value>}
def boolean_rejects_two(): {==}

law boolean_root_domain:
  {Domain.root_domain(T.Boolean{}, T.BooleanValue{True{}}) == True{} : Bool}
def boolean_root_domain(): {==}

law empty_container_absurd:
  for legal: Legal.type_legal(T.Container{[], T.End{}})
  Empty
def empty_container_absurd(legal):
  (context, (named, rest)) = legal
  (positive, others) = named
  W.false_true(positive)

law illegal_empty_container:
  Legal.type_legal(T.Container{[], T.End{}}) -> Empty
def illegal_empty_container(): legal => empty_container_absurd(legal)

law checkpoint_named_legal:
  Legal.type_legal(Fulu.Name.schema(Fulu.Name_Checkpoint{}))
def checkpoint_named_legal(): Named.legal(Fulu.Name_Checkpoint{})
