import Base
import ../types/schema.bend as T
import ../src/ssz.bend as API
import ../src/root.bend as IR
import ../src/codec.bend as IC
import ../src/schema.bend as IS
import ../src/primitives.bend as IP
import ../src/cached_tree.bend as Cache
import ../spec/root_relation.bend as R
import ../spec/codec.bend as SC
import ../spec/primitives.bend as SP
import ./root_steps.bend as G
import ./root_sound.bend as Sound
import ./root_scope.bend as Scope
import ./decode_shape.bend as Shape
import ./codec_composition.bend as Composition
import ./word_facts.bend as W
import ./root_complete.bend as Complete
import ../spec/value_domain.bend as VD
import ./value_domain.bend as ValueDomain
import ./root_total_steps.bend as TS
import ./root_total.bend as Total
import ./primitive_invariants.bend as V

# Public root soundness: every root returned by the exported API satisfies the
# independent root relation for a legal schema, including existence of the
# normative encoding, and consists of exactly 32 byte-range elements.
def roots_present(r: Maybe<&2, +List<U32>>) -> Bool:
  match r:
    case None{}: False{}
    case Some{x}: True{}

def root_contents(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case None{}: []
    case Some{x}: x

law gate_open:
  for +ok: Bool
  for -next: Unit -> Maybe<&2, +List<U32>>
  for +root: +List<U32>
  for accepted: {IR.gate(ok, next) == Some{root} : Maybe<&2, +List<U32>>}
  {ok == True{} : Bool}
def gate_open(ok, next, root, accepted):
  match ok:
    case False{}: Equal.cong(Maybe<&2, +List<U32>>, Bool, roots_present, None{}, Some{root}, accepted)
    case True{}: {==}

law gate_body:
  for +ok: Bool
  for -next: Unit -> Maybe<&2, +List<U32>>
  for +root: +List<U32>
  for accepted: {IR.gate(ok, next) == Some{root} : Maybe<&2, +List<U32>>}
  {next(Unit{}) == Some{root} : Maybe<&2, +List<U32>>}
def gate_body(ok, next, root, accepted):
  match ok:
    case False{}: Empty.absurd({next(Unit{}) == Some{root} : Maybe<&2, +List<U32>>}, W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, roots_present, None{}, Some{root}, accepted)))
    case True{}: accepted

law present_bytes:
  for +r: Maybe<&2, +List<U32>>
  for present: {IP.is_some(r) == True{} : Bool}
  Exists(+List<U32>, bytes => {r == Some{bytes} : Maybe<&2, +List<U32>>})
def present_bytes(r, present):
  match r:
    case None{}: Empty.absurd(Exists(+List<U32>, bytes => {None{} == Some{bytes} : Maybe<&2, +List<U32>>}), W.false_true(present))
    case Some{bytes}: (bytes, {==})

law encoded_exists:
  for +schema: T.Schema
  for +value: T.Value
  for +legal: {IS.valid(schema) == True{} : Bool}
  for present: {IC.valid(schema, value) == True{} : Bool}
  Exists(+List<U32>, encoded => {SC.encoding_for_legal_type(schema, value) == Some{encoded} : Maybe<&2, +List<U32>>})
def encoded_exists(schema, value, legal, present):
  %Composition.serialize_for_valid_type(schema, value, legal) : Exists(+List<U32>, encoded => {_ == Some{encoded} : Maybe<&2, +List<U32>>})
  present_bytes(IC.serialize(schema, value), present)

law unwrap_list:
  for +value: T.Value
  for +schema: T.Schema
  for +rs: +List<+List<U32>>
  for +root: +List<U32>
  for known: R.roots(value, schema, rs)
  for unwrapped: {IR.unwrap(Some{rs}) == Some{root} : Maybe<&2, +List<U32>>}
  R.roots(value, schema, [root])
def unwrap_list(value, schema, rs, root, known, unwrapped):
  match rs:
    case Nil{}: Empty.absurd(R.roots(value, schema, [root]), W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, roots_present, None{}, Some{root}, unwrapped)))
    case Con{x, rest}:
      match rest:
        case Nil{}:
          %Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, root_contents, Some{x}, Some{root}, unwrapped) : R.roots(value, schema, [_])
          known
        case Con{a, b}: Empty.absurd(R.roots(value, schema, [root]), W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, roots_present, None{}, Some{root}, unwrapped)))

law unwrap_rel:
  for +value: T.Value
  for +schema: T.Schema
  for +result: Maybe<&2, +List<+List<U32>>>
  for +root: +List<U32>
  for known: G.rel_single(outs => R.roots(value, schema, outs), result)
  for unwrapped: {IR.unwrap(result) == Some{root} : Maybe<&2, +List<U32>>}
  R.roots(value, schema, [root])
def unwrap_rel(value, schema, result, root, known, unwrapped):
  match result:
    case None{}: Empty.absurd(R.roots(value, schema, [root]), W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, roots_present, None{}, Some{root}, unwrapped)))
    case Some{rs}: unwrap_list(value, schema, rs, root, known, unwrapped)

law root_sound:
  for +schema: T.Schema
  for +value: T.Value
  for +root: +List<U32>
  for +legal: {IS.valid(schema) == True{} : Bool}
  for +accepted: {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}
  R.root_for_legal_type(schema, value, root)
def root_sound(schema, value, root, legal, accepted):
  (encoded_exists(schema, value, legal, gate_open(IC.valid(schema, value), u => IR.unwrap(IR.roots(value, schema)), root, accepted)),
   unwrap_rel(value, schema, IR.roots(value, schema), root,
     Sound.head_view(schema, value, [], IR.roots(value, schema), legal, Sound.sound(value, schema, [], Bool.pick(Nat, Nat.is_lt(IS.weight(schema), 24n), IS.weight(schema), 24n), Shape.ok_single(schema, legal))),
     gate_body(IC.valid(schema, value), u => IR.unwrap(IR.roots(value, schema)), root, accepted)))

law root_bytes:
  for +schema: T.Schema
  for +value: T.Value
  for +root: +List<U32>
  for accepted: {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}
  {SP.byte_scope(32n, root) == True{} : Bool}
def root_bytes(schema, value, root, accepted): Scope.accepted_root_scope(schema, value, root, accepted)

law unwrap_some_list:
  for +rs: +List<+List<U32>>
  for known: TS.single_ok(Some{rs})
  Exists(+List<U32>, root => {IR.unwrap(Some{rs}) == Some{root} : Maybe<&2, +List<U32>>})
def unwrap_some_list(rs, known):
  match rs:
    case Nil{}:
      match known:
    case Con{root, rest}:
      match rest:
        case Nil{}: (root, {==})
        case Con{a, b}:
          match known:

law unwrap_some:
  for +r: Maybe<&2, +List<+List<U32>>>
  for known: TS.single_ok(r)
  Exists(+List<U32>, root => {IR.unwrap(r) == Some{root} : Maybe<&2, +List<U32>>})
def unwrap_some(r, known):
  match r:
    case None{}:
      match known:
    case Some{rs}: unwrap_some_list(rs, known)

law bytes_parts:
  for +r: Maybe<&2, +List<T.Part>>
  for +e: {VD.present(SC.bytes(r)) == True{} : Bool}
  {TS.parts_present(r) == True{} : Bool}
def bytes_parts(r, e):
  match r:
    case None{}: e
    case Some{ps}: {==}

law open_gate:
  for +ok: Bool
  for -next: Unit -> Maybe<&2, +List<U32>>
  for +e: {ok == True{} : Bool}
  for body: Exists(+List<U32>, root => {next(Unit{}) == Some{root} : Maybe<&2, +List<U32>>})
  Exists(+List<U32>, root => {IR.gate(ok, next) == Some{root} : Maybe<&2, +List<U32>>})
def open_gate(ok, next, e, body):
  match ok:
    case False{}: Empty.absurd(Exists(+List<U32>, root => {None{} == Some{root} : Maybe<&2, +List<U32>>}), W.false_true(e))
    case True{}: body

# Valid-value root totality: every value in the independent root domain
# (normative encoding exists and every uint256 length mix is representable)
# has an actual root.
law root_total:
  for +schema: T.Schema
  for +value: T.Value
  for +legal: {IS.valid(schema) == True{} : Bool}
  for +domain: {VD.root_domain(schema, value) == True{} : Bool}
  Exists(+List<U32>, root => {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>})
def root_total(schema, value, legal, domain):
  open_gate(IC.valid(schema, value), u => IR.unwrap(IR.roots(value, schema)),
    Equal.trans(Bool, IC.valid(schema, value), VD.serializable(schema, value), True{}, ValueDomain.serializable_correct(schema, value, legal), V.and_left(VD.serializable(schema, value), VD.mixing_lengths(value, schema), domain)),
    unwrap_some(IR.roots(value, schema), Total.single_ok_of(IR.roots(value, schema),
      Total.total(value, schema, [], Bool.pick(Nat, Nat.is_lt(IS.weight(schema), 24n), IS.weight(schema), 24n), Shape.ok_single(schema, legal), bytes_parts(SC.parts(value, schema), V.and_left(VD.serializable(schema, value), VD.mixing_lengths(value, schema), domain)), V.and_right(VD.serializable(schema, value), VD.mixing_lengths(value, schema), domain)),
      Scope.roots_public_scope(schema, value),
      Total.one_map(value, schema, IR.roots(value, schema), legal, Sound.head_view(schema, value, [], IR.roots(value, schema), legal, Sound.sound(value, schema, [], Bool.pick(Nat, Nat.is_lt(IS.weight(schema), 24n), IS.weight(schema), 24n), Shape.ok_single(schema, legal)))))))

law valid_from_encoding:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for +legal: {IS.valid(schema) == True{} : Bool}
  for +encoded: {SC.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {IC.valid(schema, value) == True{} : Bool}
def valid_from_encoding(schema, value, bytes, legal, encoded):
  %Equal.sym(Maybe<&2, +List<U32>>, IC.serialize(schema, value), Some{bytes}, Equal.trans(Maybe<&2, +List<U32>>, IC.serialize(schema, value), SC.encoding_for_legal_type(schema, value), Some{bytes}, Composition.serialize_for_valid_type(schema, value, legal), encoded)) : {IP.is_some(_) == True{} : Bool}
  {==}

law gate_complete:
  for +ok: Bool
  for -next: Unit -> Maybe<&2, +List<U32>>
  for +root: +List<U32>
  for +e: {ok == True{} : Bool}
  for body: {next(Unit{}) == Some{root} : Maybe<&2, +List<U32>>}
  {IR.gate(ok, next) == Some{root} : Maybe<&2, +List<U32>>}
def gate_complete(ok, next, root, e, body):
  match ok:
    case False{}: Empty.absurd({None{} == Some{root} : Maybe<&2, +List<U32>>}, W.false_true(e))
    case True{}: body

law unwrap_complete:
  for +result: Maybe<&2, +List<+List<U32>>>
  for +root: +List<U32>
  for +same: {result == Some{[root]} : Maybe<&2, +List<+List<U32>>>}
  {IR.unwrap(result) == Some{root} : Maybe<&2, +List<U32>>}
def unwrap_complete(result, root, same):
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, result, Some{[root]}, same) : {IR.unwrap(_) == Some{root} : Maybe<&2, +List<U32>>}
  {==}

# Public root completeness: the independent relation determines the actual
# root exactly (so the relation is functional on legal types).
law root_complete:
  for +schema: T.Schema
  for +value: T.Value
  for +root: +List<U32>
  for +legal: {IS.valid(schema) == True{} : Bool}
  for rel: R.root_for_legal_type(schema, value, root)
  {API.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}
def root_complete(schema, value, root, legal, rel):
  ((+bytes, encoded), roots) = rel
  gate_complete(IC.valid(schema, value), u => IR.unwrap(IR.roots(value, schema)), root, valid_from_encoding(schema, value, bytes, legal, encoded),
    unwrap_complete(IR.roots(value, schema), root, Complete.head_view(schema, value, Bool.pick(Nat, Nat.is_lt(IS.weight(schema), 24n), IS.weight(schema), 24n), [root], legal, Complete.complete(value, schema, [], Bool.pick(Nat, Nat.is_lt(IS.weight(schema), 24n), IS.weight(schema), 24n), Shape.ok_single(schema, legal), [root], roots))))
