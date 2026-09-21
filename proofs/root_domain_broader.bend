import Base
import ../types/schema.bend as T
import ../src/model.bend as API
import ../src/schema.bend as Schema
import ../spec/type_legality.bend as Legal
import ../spec/root_relation.bend as Roots
import ../spec/value_domain.bend as Domain
import ../spec/codec.bend as Encoding
import ../spec/primitives.bend as Bytes
import ./root_public.bend as RootLaws
import ./type_validator_complete.bend as ValidatorComplete
import ./codec_composition.bend as Composition
import ./root_domain_witness.bend as Witness
import ./word_facts.bend as W

# ---------------------------------------------------------------------------
# (c) The corrected domain is strictly broader, for composite values. For
# every r, with F = 256*(1+r): the legal type
#   Vector[Vector[Vector[ByteVector[256], F], F], F]
# (serialized size 256*F^3 >= 2^32) has, for EVERY 256-byte leaf, a value in
# the new root domain that the actual API roots, but no normative encoding
# (the previous domain excludes it and the actual serializer rejects it).
# Nothing is assumed: the values are constructed explicitly and every fact is
# proved symbolically (Witness).
def broader_facts(+schema: T.Schema, +value: T.Value) -> Type:
  Legal.type_legal(schema) &
  {Domain.root_domain(schema, value) == True{} : Bool} &
  {Domain.serializable(schema, value) == False{} : Bool} &
  {Domain.serializable_root_domain(schema, value) == False{} : Bool} &
  {API.serialize(schema, value) == None{} : Maybe<&2, +List<U32>>} &
  Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} & Roots.root_for_legal_type(schema, value, root) & {Bytes.byte_scope(32n, root) == True{} : Bool})

def present_bytes(r: Maybe<&2, +List<U32>>) -> Bool:
  match r:
    case None{}: False{}
    case Some{x}: True{}

law absent_encoding:
  for +r: Maybe<&2, +List<U32>>
  for +e: {Domain.present(r) == False{} : Bool}
  {r == None{} : Maybe<&2, +List<U32>>}
def absent_encoding(r, e):
  match r:
    case None{}: {==}
    case Some{x}: Empty.absurd({Some{x} == None{} : Maybe<&2, +List<U32>>}, W.false_true(Equal.sym(Bool, True{}, False{}, e)))

law rooted_at:
  for +schema: T.Schema
  for +value: T.Value
  for +root: +List<U32>
  for +accepted: {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}
  Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} & Roots.root_for_legal_type(schema, value, root) & {Bytes.byte_scope(32n, root) == True{} : Bool})
def rooted_at(schema, value, root, accepted):
  (root, (accepted, (RootLaws.root_sound(schema, value, root, accepted), RootLaws.root_bytes(schema, value, root, accepted))))

law rooted:
  for +schema: T.Schema
  for +value: T.Value
  for found: Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>})
  Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>} & Roots.root_for_legal_type(schema, value, root) & {Bytes.byte_scope(32n, root) == True{} : Bool})
def rooted(schema, value, found):
  (+root, accepted) = found
  rooted_at(schema, value, root, accepted)

law and_false_left:
  for +a: Bool
  for +b: Bool
  for +e: {a == False{} : Bool}
  {Bool.and(a, b) == False{} : Bool}
def and_false_left(a, b, e):
  match a:
    case False{}: {==}
    case True{}: Empty.absurd({b == False{} : Bool}, W.false_true(Equal.sym(Bool, True{}, False{}, e)))

law witness_facts:
  for +schema: T.Schema
  for +value: T.Value
  for legal: Legal.type_legal(schema)
  for +valid: {Schema.valid(schema) == True{} : Bool}
  for +domain: {Domain.root_domain(schema, value) == True{} : Bool}
  for +outside: {Domain.serializable(schema, value) == False{} : Bool}
  broader_facts(schema, value)
def witness_facts(schema, value, legal, valid, domain, outside):
  (legal,
   (domain,
    (outside,
     (and_false_left(Domain.serializable(schema, value), Domain.mixing_lengths(value, schema), outside),
      (Equal.trans(Maybe<&2, +List<U32>>, API.serialize(schema, value), Encoding.encoding_for_legal_type(schema, value), None{}, Composition.serialize_for_valid_type(schema, value, valid), absent_encoding(Encoding.encoding_for_legal_type(schema, value), outside)),
       rooted(schema, value, RootLaws.root_total(schema, value, valid, domain)))))))

# The depth is a parameter, not the literal 3. Writing `3n` here forced the
# checker to unfold nest_schema three levels deep and then walk the root and
# validity machinery fanout-wide at each level (F = 256*(1+r) children per
# level), which is what exploded this module's memory; with `d` symbolic the
# same statement covers every depth >= 3 (so it is strictly stronger) and
# every term stays stuck.
law strictly_broader:
  for +d: Nat
  for +r: Nat
  for +deep: {Nat.is_le(3n, d) == True{} : Bool}
  (@+xs: +List<U32> -> {Bytes.byte_scope(256n, xs) == True{} : Bool} -> broader_facts(Witness.nest_schema(d, r), Witness.nest_value(d, r, xs))) &
  Exists(T.Schema, schema => Exists(T.Value, value => broader_facts(schema, value)))
def strictly_broader(d, r, deep):
  (xs => leaf => witness_facts(Witness.nest_schema(d, r), Witness.nest_value(d, r, xs), Witness.legal_nest(d, r), ValidatorComplete.public_complete(Witness.nest_schema(d, r), Witness.legal_nest(d, r)), Witness.nest_domain(d, r, xs, leaf), Witness.nest_not_serializable(d, r, xs, deep)),
   (Witness.nest_schema(d, r), (Witness.nest_value(d, r, Bytes.zero_bytes(256n)),
     witness_facts(Witness.nest_schema(d, r), Witness.nest_value(d, r, Bytes.zero_bytes(256n)), Witness.legal_nest(d, r), ValidatorComplete.public_complete(Witness.nest_schema(d, r), Witness.legal_nest(d, r)), Witness.nest_domain(d, r, Bytes.zero_bytes(256n), {==}), Witness.nest_not_serializable(d, r, Bytes.zero_bytes(256n), deep)))))
