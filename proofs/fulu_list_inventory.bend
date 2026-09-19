import Base
import ../types/list_alias.bend as A
import ../src/list_alias.bend as I
import ../spec/list_alias.bend as S
import ../src/byte_list.bend as ByteList
import ../src/primitives.bend as R
import ../src/limits.bend as Limits
import ./byte_list.bend as B
import ./tree.bend as Tree
import ./primitives.bend as Basic

# As with the retained byte-alias inventory, keep the closed identity symbolic
# while composing universal laws. This inventory contains precisely Transaction;
# its public named wrappers are direct applications of these actual APIs.
law domain_correct:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  {I.valid(alias, xs) == S.domain(alias, xs) : Bool}
def domain_correct(alias, xs): B.domain_correct(A.capacity(alias), xs)

law serialize_correct:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  {I.serialize(alias, xs) == S.encoding(alias, xs) : Maybe<&2, +List<U32>>}
def serialize_correct(alias, xs): B.serialize_correct(A.capacity(alias), xs)

law deserialize_correct:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  {I.deserialize(alias, xs) == S.decoding(alias, xs) : Maybe<&2, +List<U32>>}
def deserialize_correct(alias, xs): B.deserialize_correct(A.capacity(alias), xs)

law rejection_correct:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  {R.is_some(I.deserialize(alias, xs)) == S.domain(alias, xs) : Bool}
def rejection_correct(alias, xs): B.rejection_correct(A.capacity(alias), xs)

law decoding_complete:
  for +alias: A.ByteListAlias
  for +value: +List<U32>
  for +encoded: +List<U32>
  for e: {S.encoding(alias, value) == Some{encoded} : Maybe<&2, +List<U32>>}
  {I.deserialize(alias, encoded) == Some{value} : Maybe<&2, +List<U32>>}
def decoding_complete(alias, value, encoded, e): B.decoding_complete(A.capacity(alias), value, encoded, e)

law decoding_sound:
  for +alias: A.ByteListAlias
  for +encoded: +List<U32>
  for +value: +List<U32>
  for +e: {I.deserialize(alias, encoded) == Some{value} : Maybe<&2, +List<U32>>}
  {S.encoding(alias, value) == Some{encoded} : Maybe<&2, +List<U32>>}
def decoding_sound(alias, encoded, value, e): B.accepted_canonical(A.capacity(alias), encoded, value, e)

law root_refinement:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  {I.hash_tree_root(alias, xs) == S.root_at_depth(alias, Limits.depth(ByteList.chunk_limit(A.capacity(alias))), xs) : Maybe<&2, +List<U32>>}
def root_refinement(alias, xs): B.selected_correct(A.capacity(alias), xs)

law root_total:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  for +valid: {I.valid(alias, xs) == True{} : Bool}
  {R.is_some(I.hash_tree_root(alias, xs)) == True{} : Bool}
def root_total(alias, xs, valid): B.root_total(A.capacity(alias), xs, valid)

law root_scope:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  Tree.result_scope(I.hash_tree_root(alias, xs))
def root_scope(alias, xs): B.root_scope(A.capacity(alias), xs)

law root_length:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  {Basic.lengths(I.hash_tree_root(alias, xs)) == Basic.expected_root_length(I.hash_tree_root(alias, xs)) : Maybe<&2, Nat>}
def root_length(alias, xs): B.root_length(A.capacity(alias), xs)

law root_rejection:
  for +alias: A.ByteListAlias
  for +xs: +List<U32>
  {R.is_some(I.hash_tree_root(alias, xs)) == S.domain(alias, xs) : Bool}
def root_rejection(alias, xs):
  Equal.trans(Bool, R.is_some(I.hash_tree_root(alias, xs)), I.valid(alias, xs), S.domain(alias, xs), B.root_exact_acceptance(A.capacity(alias), xs), domain_correct(alias, xs))
