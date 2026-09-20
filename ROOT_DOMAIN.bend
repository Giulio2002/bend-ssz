import Base
import ./types/schema.bend as T
import ./types/fulu.bend as Fulu
import ./src/ssz.bend as API
import ./src/schema.bend as Schema
import ./spec/type_legality.bend as Legal
import ./spec/root_relation.bend as Roots
import ./spec/root_relation_serializable.bend as SerializableRoots
import ./spec/value_domain.bend as Domain
import ./spec/codec.bend as Encoding
import ./spec/decoding_relation.bend as Decoding
import ./spec/primitives.bend as Bytes
import ./proofs/root_public.bend as RootLaws
import ./proofs/root_domain_compat.bend as Compat
import ./proofs/root_domain_witness.bend as Witness
import ./proofs/root_domain_broader.bend as Broader
import ./proofs/type_validator_soundness.bend as ValidatorSound
import ./proofs/type_validator_complete.bend as ValidatorComplete
import ./proofs/codec_composition.bend as Composition
import ./proofs/fulu_named.bend as Named
import ./proofs/primitive_invariants.bend as V
import ./proofs/word_facts.bend as W
import ./END_TO_END.bend as EndToEnd

# ROOT-DOMAIN CORRECTION. The independent root domain is
#   Domain.root_domain(schema, value) =
#     Domain.root_valid(value, schema)        -- structural type/value validity
#     AND Domain.mixing_lengths(value, schema) -- every mixed length is uint256
# (spec/value_domain.bend). It mentions no serialization, offset or
# serialized-size condition. The relation Roots.root_for_legal_type is the
# root of a structurally valid value, computed recursively over child roots
# (spec/root_relation.bend). The previous, serializable-only relation is
# SerializableRoots.serializable_root_for_legal_type and the previous domain is
# Domain.serializable_root_domain. See ROOT_DOMAIN_REVIEW.md.

# ---------------------------------------------------------------------------
# Complete public root contract for one schema/value pair: soundness (with the
# root domain and exact 32-byte byte-range output), completeness, totality on
# the root domain (no premise that a root or an encoding exists), functional
# uniqueness of the relation, and rejection outside the domain / of illegal
# types. The rejection clause covers every structural failure (wrong shape,
# wrong or unknown selector, out-of-range byte/uint, wrong vector count,
# over-capacity list/bitlist/bytelist) and every length whose uint256 mix
# does not exist (length >= 2^256).
def root_contract(+schema: T.Schema, +value: T.Value) -> Type:
  (@+root: +List<U32> -> @+accepted: {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} -> Legal.type_legal(schema) & Roots.root_for_legal_type(schema, value, root) & {Domain.root_domain(schema, value) == True{} : Bool} & {Bytes.byte_scope(32n, root) == True{} : Bool}) &
  (Legal.type_legal(schema) -> @+root: +List<U32> -> Roots.root_for_legal_type(schema, value, root) -> {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}) &
  (Legal.type_legal(schema) -> {Domain.root_domain(schema, value) == True{} : Bool} -> Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>})) &
  (Legal.type_legal(schema) -> @+a: +List<U32> -> @+b: +List<U32> -> Roots.root_for_legal_type(schema, value, a) -> Roots.root_for_legal_type(schema, value, b) -> {a == b : +List<U32>}) &
  ({Domain.root_domain(schema, value) == False{} : Bool} -> {API.hash_tree_root(schema, value) == None{} : Maybe<&2, +List<U32>>}) &
  ((Legal.type_legal(schema) -> Empty) -> {API.hash_tree_root(schema, value) == None{} : Maybe<&2, +List<U32>>})

# The same contract for every one of the 109 frozen Fulu names, stated for
# the actual named API Fulu.Name.hash_tree_root (definitionally the generic
# API at the name's independent schema and the typed value's representation).
def named_root_contract(+name: Fulu.Name) -> Type:
  @+value: Fulu.Name.Value(name) ->
    (@+root: +List<U32> -> @+accepted: {Fulu.Name.hash_tree_root(name, value) == Some{root} : Maybe<&2, +List<U32>>} -> Roots.root_for_legal_type(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root) & {Domain.root_domain(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value)) == True{} : Bool} & {Bytes.byte_scope(32n, root) == True{} : Bool}) &
    (@+root: +List<U32> -> Roots.root_for_legal_type(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root) -> {Fulu.Name.hash_tree_root(name, value) == Some{root} : Maybe<&2, +List<U32>>}) &
    ({Domain.root_domain(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value)) == True{} : Bool} -> Exists(+List<U32>, root => {Fulu.Name.hash_tree_root(name, value) == Some{root} : Maybe<&2, +List<U32>>})) &
    ({Domain.root_domain(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value)) == False{} : Bool} -> {Fulu.Name.hash_tree_root(name, value) == None{} : Maybe<&2, +List<U32>>})

def root_of(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case None{}: []
    case Some{x}: x

law none_unless:
  for +r: Maybe<&2, +List<U32>>
  for bad: @+root: +List<U32> -> {r == Some{root} : Maybe<&2, +List<U32>>} -> Empty
  {r == None{} : Maybe<&2, +List<U32>>}
def none_unless(r, bad):
  match r:
    case None{}: {==}
    case Some{root}: Empty.absurd({Some{root} == None{} : Maybe<&2, +List<U32>>}, bad(root, {==}))

law domain_rejected:
  for +schema: T.Schema
  for +value: T.Value
  for +outside: {Domain.root_domain(schema, value) == False{} : Bool}
  {API.hash_tree_root(schema, value) == None{} : Maybe<&2, +List<U32>>}
def domain_rejected(schema, value, outside):
  none_unless(API.hash_tree_root(schema, value), root => accepted =>
    W.false_true(Equal.trans(Bool, False{}, Domain.root_domain(schema, value), True{}, Equal.sym(Bool, Domain.root_domain(schema, value), False{}, outside), RootLaws.root_domain_accepted(schema, value, root, accepted))))

law illegal_rejected:
  for +schema: T.Schema
  for +value: T.Value
  for illegal: Legal.type_legal(schema) -> Empty
  {API.hash_tree_root(schema, value) == None{} : Maybe<&2, +List<U32>>}
def illegal_rejected(schema, value, illegal):
  none_unless(API.hash_tree_root(schema, value), root => accepted => illegal(ValidatorSound.public_sound(schema, RootLaws.accepted_legal(schema, value, root, accepted))))

law relation_unique:
  for +schema: T.Schema
  for +value: T.Value
  for +a: +List<U32>
  for +b: +List<U32>
  for +valid: {Schema.valid(schema) == True{} : Bool}
  for ra: Roots.root_for_legal_type(schema, value, a)
  for rb: Roots.root_for_legal_type(schema, value, b)
  {a == b : +List<U32>}
def relation_unique(schema, value, a, b, valid, ra, rb):
  Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, root_of, Some{a}, Some{b},
    Equal.trans(Maybe<&2, +List<U32>>, Some{a}, API.hash_tree_root(schema, value), Some{b},
      Equal.sym(Maybe<&2, +List<U32>>, API.hash_tree_root(schema, value), Some{a}, RootLaws.root_complete(schema, value, a, valid, ra)),
      RootLaws.root_complete(schema, value, b, valid, rb)))

law generic_contract:
  for +schema: T.Schema
  for +value: T.Value
  root_contract(schema, value)
def generic_contract(schema, value):
  (root => accepted => (ValidatorSound.public_sound(schema, RootLaws.accepted_legal(schema, value, root, accepted)), (RootLaws.root_sound(schema, value, root, accepted), (RootLaws.root_domain_accepted(schema, value, root, accepted), RootLaws.root_bytes(schema, value, root, accepted)))),
   (legal => root => rel => RootLaws.root_complete(schema, value, root, ValidatorComplete.public_complete(schema, legal), rel),
    (legal => domain => RootLaws.root_total(schema, value, ValidatorComplete.public_complete(schema, legal), domain),
     (legal => a => b => ra => rb => relation_unique(schema, value, a, b, ValidatorComplete.public_complete(schema, legal), ra, rb),
      (outside => domain_rejected(schema, value, outside),
       illegal => illegal_rejected(schema, value, illegal))))))

law named_contract:
  for +name: Fulu.Name
  named_root_contract(name)
def named_contract(name):
  value => (root => accepted => (RootLaws.root_sound(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root, accepted), (RootLaws.root_domain_accepted(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root, accepted), RootLaws.root_bytes(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root, accepted))),
    (root => rel => RootLaws.root_complete(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), root, EndToEnd.named_valid(name), rel),
     (domain => RootLaws.root_total(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), EndToEnd.named_valid(name), domain),
      outside => domain_rejected(Fulu.Name.schema(name), Fulu.Name.to_ssz(name, value), outside))))

# (a) Full-domain public root correctness for the generic API and all 109
# named APIs.
law full_root_correct:
  (@+schema: T.Schema -> @+value: T.Value -> root_contract(schema, value)) & (@+name: Fulu.Name -> Legal.type_legal(Fulu.Name.schema(name)) & named_root_contract(name))
def full_root_correct():
  (schema => value => generic_contract(schema, value), name => (Named.legal(name), named_contract(name)))

# ---------------------------------------------------------------------------
# (b) Compatibility with the previous serializable root domain. Every value of
# the previous domain (normative whole-object encoding exists, mixed lengths
# uint256) is in the new domain; the corrected API returns a root for it, and
# a root is returned exactly when it satisfies the PREVIOUS relation -- so the
# root is exactly the one the previous API returned (the previous theorems
# characterised the previous API by that relation). The codec laws are the
# unchanged END_TO_END theorems, restated verbatim.
def codec_laws(+schema: T.Schema, +value: T.Value) -> Type:
  ((Legal.type_legal(schema) -> {API.serialize(schema, value) == Encoding.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}) & ((Legal.type_legal(schema) -> Empty) -> {API.serialize(schema, value) == None{} : Maybe<&2, +List<U32>>})) &
  (@+bytes: +List<U32> -> ({API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>} -> Legal.type_legal(schema) & Decoding.decodes(schema, bytes, value)) & ((Legal.type_legal(schema) & Decoding.decodes(schema, bytes, value)) -> {API.deserialize(schema, bytes) == Some{value} : Maybe<&2, T.Value>})) &
  (@+bytes: +List<U32> -> ({API.deserialize(schema, bytes) == None{} : Maybe<&2, T.Value>} -> Legal.type_legal(schema) -> Decoding.outside_image(schema, bytes)) & ((Legal.type_legal(schema) -> Decoding.outside_image(schema, bytes)) -> {API.deserialize(schema, bytes) == None{} : Maybe<&2, T.Value>})) &
  (@+bytes: +List<U32> -> @+a: T.Value -> @+b: T.Value -> Legal.type_legal(schema) -> Decoding.decodes(schema, bytes, a) -> Decoding.decodes(schema, bytes, b) -> {a == b : T.Value})

def serializable_roots_preserved(+schema: T.Schema, +value: T.Value) -> Type:
  Legal.type_legal(schema) -> {Domain.serializable_root_domain(schema, value) == True{} : Bool} ->
    {Domain.root_domain(schema, value) == True{} : Bool} &
    Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} & SerializableRoots.serializable_root_for_legal_type(schema, value, root)) &
    (@+root: +List<U32> -> {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} -> SerializableRoots.serializable_root_for_legal_type(schema, value, root)) &
    (@+root: +List<U32> -> SerializableRoots.serializable_root_for_legal_type(schema, value, root) -> {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>})

law with_previous_at:
  for +schema: T.Schema
  for +value: T.Value
  for +serial: {Domain.serializable(schema, value) == True{} : Bool}
  for +root: +List<U32>
  for +accepted: {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}
  Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} & SerializableRoots.serializable_root_for_legal_type(schema, value, root))
def with_previous_at(schema, value, serial, root, accepted):
  (root, (accepted, Compat.relation_to_serializable(schema, value, root, serial, RootLaws.root_sound(schema, value, root, accepted))))

law with_previous:
  for +schema: T.Schema
  for +value: T.Value
  for +serial: {Domain.serializable(schema, value) == True{} : Bool}
  for found: Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>})
  Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} & SerializableRoots.serializable_root_for_legal_type(schema, value, root))
def with_previous(schema, value, serial, found):
  (+root, accepted) = found
  with_previous_at(schema, value, serial, root, accepted)

law previous_at:
  for +schema: T.Schema
  for +value: T.Value
  for +valid: {Schema.valid(schema) == True{} : Bool}
  for +old: {Domain.serializable_root_domain(schema, value) == True{} : Bool}
  {Domain.root_domain(schema, value) == True{} : Bool} &
    Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} & SerializableRoots.serializable_root_for_legal_type(schema, value, root)) &
    (@+root: +List<U32> -> {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} -> SerializableRoots.serializable_root_for_legal_type(schema, value, root)) &
    (@+root: +List<U32> -> SerializableRoots.serializable_root_for_legal_type(schema, value, root) -> {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>})
def previous_at(schema, value, valid, old):
  (Compat.serializable_domain_included(schema, value, old),
   (with_previous(schema, value, V.and_left(Domain.serializable(schema, value), Domain.mixing_lengths(value, schema), old), RootLaws.root_total(schema, value, valid, Compat.serializable_domain_included(schema, value, old))),
    (root => accepted => Compat.relation_to_serializable(schema, value, root, V.and_left(Domain.serializable(schema, value), Domain.mixing_lengths(value, schema), old), RootLaws.root_sound(schema, value, root, accepted)),
     root => rel => RootLaws.root_complete(schema, value, root, valid, Compat.relation_from_serializable(schema, value, root, V.and_left(Domain.serializable(schema, value), Domain.mixing_lengths(value, schema), old), rel)))))

law previous_preserved:
  for +schema: T.Schema
  for +value: T.Value
  serializable_roots_preserved(schema, value)
def previous_preserved(schema, value):
  legal => old => previous_at(schema, value, ValidatorComplete.public_complete(schema, legal), old)

law serializable_root_compatibility:
  for +schema: T.Schema
  for +value: T.Value
  serializable_roots_preserved(schema, value) & codec_laws(schema, value)
def serializable_root_compatibility(schema, value):
  (previous_preserved(schema, value),
   (EndToEnd.serialize_correct(schema, value),
    (bytes => EndToEnd.deserialize_correct(schema, bytes, value),
     (bytes => EndToEnd.deserialize_rejection_correct(schema, bytes),
      bytes => a => b => legal => first => second => EndToEnd.deserialize_unique(schema, bytes, a, b, legal, first, second)))))

# ---------------------------------------------------------------------------
# (c) The corrected domain is strictly broader, for composite values. For
# every nesting depth d >= 3 and every r, with F = 256*(1+r): the legal type
#   nest_schema(d, r) = Vector[... Vector[ByteVector[256], F] ..., F]  (d levels)
# (serialized size 256*F^d >= 2^32) has, for EVERY 256-byte leaf, a value in
# the new root domain that the actual API roots (a 32-byte root satisfying the
# relation), but no normative encoding: the previous domain excludes it and the
# actual serializer returns None. Nothing is assumed; the values are built
# explicitly and every fact is proved symbolically (proofs/root_domain_witness,
# proofs/root_domain_broader). d = 3, r = 0 is
# Vector[Vector[Vector[Bytes256, 256], 256], 256], exactly 2^32 serialized
# bytes; the depth is left symbolic so that checking this law never unfolds a
# fanout-wide schema (the previous literal depth made it exhaust memory).
law root_domain_strictly_broader:
  for +d: Nat
  for +r: Nat
  for +deep: {Nat.is_le(3n, d) == True{} : Bool}
  (@+xs: +List<U32> -> {Bytes.byte_scope(256n, xs) == True{} : Bool} -> Broader.broader_facts(Witness.nest_schema(d, r), Witness.nest_value(d, r, xs))) &
  Exists(T.Schema, schema => Exists(T.Value, value => Broader.broader_facts(schema, value)))
def root_domain_strictly_broader(d, r, deep): Broader.strictly_broader(d, r, deep)
