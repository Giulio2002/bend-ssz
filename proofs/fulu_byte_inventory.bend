import Base
import ../types/byte_alias.bend as A
import ../src/byte_alias.bend as I
import ../src/primitives.bend as R
import ../spec/byte_alias.bend as S
import ../spec/byte_root.bend as RootSpec
import ./bytes.bend as B
import ./byte_root.bend as Root
import ./tree.bend as Tree
import ./primitives.bend as Basic

# Quantification over the CLOSED frozen alias inventory includes Blob and Cell.
# Named wrappers are defined directly as calls of these actual APIs with their
# corresponding constructor. Keep the identity symbolic: expanding a concrete
# large Nat while comparing specialization types overflows the unchanged checker.
law domain_correct:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  {I.valid(alias, xs) == S.domain(alias, xs) : Bool}
def domain_correct(alias, xs): B.vector_domain_correct(A.size(alias), xs)

law serialize_correct:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  {I.serialize(alias, xs) == S.encoding(alias, xs) : Maybe<&2, +List<U32>>}
def serialize_correct(alias, xs): B.vector_serialize_correct(A.size(alias), xs)

law deserialize_correct:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  {I.deserialize(alias, xs) == S.decoding(alias, xs) : Maybe<&2, +List<U32>>}
def deserialize_correct(alias, xs): B.vector_deserialize_correct(A.size(alias), xs)

law rejection_correct:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  {R.is_some(I.deserialize(alias, xs)) == S.domain(alias, xs) : Bool}
def rejection_correct(alias, xs): B.vector_rejection_correct(A.size(alias), xs)

law decoding_complete:
  for +alias: A.ByteAlias
  for +value: +List<U32>
  for +encoded: +List<U32>
  for e: {S.encoding(alias, value) == Some{encoded} : Maybe<&2, +List<U32>>}
  {I.deserialize(alias, encoded) == Some{value} : Maybe<&2, +List<U32>>}
def decoding_complete(alias, value, encoded, e): B.vector_decoding_complete(A.size(alias), value, encoded, e)

law accepted_sound:
  for +alias: A.ByteAlias
  for +encoded: +List<U32>
  for +value: +List<U32>
  for +e: {I.deserialize(alias, encoded) == Some{value} : Maybe<&2, +List<U32>>}
  {S.encoding(alias, value) == Some{encoded} : Maybe<&2, +List<U32>>}
def accepted_sound(alias, encoded, value, e): B.vector_accepted_sound(A.size(alias), encoded, value, e)

law root_correct:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {I.hash_tree_root(alias, xs) == S.root_at_depth(alias, depth, xs) : Maybe<&2, +List<U32>>}
def root_correct(alias, xs, depth, minimal): Root.hash_tree_root_correct(A.size(alias), xs, depth, minimal)

law root_refinement:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  {I.hash_tree_root(alias, xs) == S.root_at_depth(alias, Root.witness(xs), xs) : Maybe<&2, +List<U32>>}
def root_refinement(alias, xs): Root.hash_tree_root_refinement(A.size(alias), xs)

law root_rejection:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  {R.is_some(I.hash_tree_root(alias, xs)) == S.domain(alias, xs) : Bool}
def root_rejection(alias, xs): Root.hash_tree_root_rejection(A.size(alias), xs)

law root_scope:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  Tree.result_scope(I.hash_tree_root(alias, xs))
def root_scope(alias, xs): Root.hash_tree_root_scope(A.size(alias), xs)

law root_length:
  for +alias: A.ByteAlias
  for +xs: +List<U32>
  {Basic.lengths(I.hash_tree_root(alias, xs)) == Basic.expected_root_length(I.hash_tree_root(alias, xs)) : Maybe<&2, Nat>}
def root_length(alias, xs): Root.hash_tree_root_length(A.size(alias), xs)
