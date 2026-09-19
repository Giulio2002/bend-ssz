import Base
import ../types/fulu_bytes.bend as F
import ../spec/bytes.bend as S
import ../src/primitives.bend as P
import ./bytes.bend as B
import ./byte_root.bend as ByteRoot
import ./tree.bend as Tree
import ../spec/byte_root.bend as RootSpec
import ./primitives.bend as Basic


law Bytes1.domain_correct:
  for +xs: F.Bytes1()
  {F.Bytes1.valid(xs) == S.vector_domain(1n, xs) : Bool}
def Bytes1.domain_correct(xs): B.vector_domain_correct(1n, xs)
law Bytes1.serialize_correct:
  for +xs: F.Bytes1()
  {F.Bytes1.serialize(xs) == S.vector_encoding(1n, xs) : Maybe<&2, +List<U32>>}
def Bytes1.serialize_correct(xs): B.vector_serialize_correct(1n, xs)
law Bytes1.deserialize_correct:
  for +xs: +List<U32>
  {F.Bytes1.deserialize(xs) == S.vector_decoding(1n, xs) : Maybe<&2, +List<U32>>}
def Bytes1.deserialize_correct(xs): B.vector_deserialize_correct(1n, xs)
law Bytes1.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Bytes1.deserialize(xs)) == S.vector_domain(1n, xs) : Bool}
def Bytes1.rejection_correct(xs): B.vector_rejection_correct(1n, xs)
law Bytes1.root_correct:
  for +xs: F.Bytes1()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Bytes1.hash_tree_root(xs) == RootSpec.at_depth(1n, depth, xs) : Maybe<&2, +List<U32>>}
def Bytes1.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(1n, xs, depth, minimal)
law Bytes1.root_refinement:
  for +xs: F.Bytes1()
  {F.Bytes1.hash_tree_root(xs) == RootSpec.at_depth(1n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Bytes1.root_refinement(xs): ByteRoot.hash_tree_root_refinement(1n, xs)
law Bytes1.root_rejection:
  for +xs: F.Bytes1()
  {P.is_some(F.Bytes1.hash_tree_root(xs)) == S.vector_domain(1n, xs) : Bool}
def Bytes1.root_rejection(xs): ByteRoot.hash_tree_root_rejection(1n, xs)
law Bytes1.root_scope:
  for +xs: F.Bytes1()
  Tree.result_scope(F.Bytes1.hash_tree_root(xs))
def Bytes1.root_scope(xs): ByteRoot.hash_tree_root_scope(1n, xs)
law Bytes1.root_length:
  for +xs: F.Bytes1()
  {Basic.lengths(F.Bytes1.hash_tree_root(xs)) == Basic.expected_root_length(F.Bytes1.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Bytes1.root_length(xs): ByteRoot.hash_tree_root_length(1n, xs)



law Bytes4.domain_correct:
  for +xs: F.Bytes4()
  {F.Bytes4.valid(xs) == S.vector_domain(4n, xs) : Bool}
def Bytes4.domain_correct(xs): B.vector_domain_correct(4n, xs)
law Bytes4.serialize_correct:
  for +xs: F.Bytes4()
  {F.Bytes4.serialize(xs) == S.vector_encoding(4n, xs) : Maybe<&2, +List<U32>>}
def Bytes4.serialize_correct(xs): B.vector_serialize_correct(4n, xs)
law Bytes4.deserialize_correct:
  for +xs: +List<U32>
  {F.Bytes4.deserialize(xs) == S.vector_decoding(4n, xs) : Maybe<&2, +List<U32>>}
def Bytes4.deserialize_correct(xs): B.vector_deserialize_correct(4n, xs)
law Bytes4.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Bytes4.deserialize(xs)) == S.vector_domain(4n, xs) : Bool}
def Bytes4.rejection_correct(xs): B.vector_rejection_correct(4n, xs)
law Bytes4.root_correct:
  for +xs: F.Bytes4()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Bytes4.hash_tree_root(xs) == RootSpec.at_depth(4n, depth, xs) : Maybe<&2, +List<U32>>}
def Bytes4.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(4n, xs, depth, minimal)
law Bytes4.root_refinement:
  for +xs: F.Bytes4()
  {F.Bytes4.hash_tree_root(xs) == RootSpec.at_depth(4n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Bytes4.root_refinement(xs): ByteRoot.hash_tree_root_refinement(4n, xs)
law Bytes4.root_rejection:
  for +xs: F.Bytes4()
  {P.is_some(F.Bytes4.hash_tree_root(xs)) == S.vector_domain(4n, xs) : Bool}
def Bytes4.root_rejection(xs): ByteRoot.hash_tree_root_rejection(4n, xs)
law Bytes4.root_scope:
  for +xs: F.Bytes4()
  Tree.result_scope(F.Bytes4.hash_tree_root(xs))
def Bytes4.root_scope(xs): ByteRoot.hash_tree_root_scope(4n, xs)
law Bytes4.root_length:
  for +xs: F.Bytes4()
  {Basic.lengths(F.Bytes4.hash_tree_root(xs)) == Basic.expected_root_length(F.Bytes4.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Bytes4.root_length(xs): ByteRoot.hash_tree_root_length(4n, xs)



law Bytes32.domain_correct:
  for +xs: F.Bytes32()
  {F.Bytes32.valid(xs) == S.vector_domain(32n, xs) : Bool}
def Bytes32.domain_correct(xs): B.vector_domain_correct(32n, xs)
law Bytes32.serialize_correct:
  for +xs: F.Bytes32()
  {F.Bytes32.serialize(xs) == S.vector_encoding(32n, xs) : Maybe<&2, +List<U32>>}
def Bytes32.serialize_correct(xs): B.vector_serialize_correct(32n, xs)
law Bytes32.deserialize_correct:
  for +xs: +List<U32>
  {F.Bytes32.deserialize(xs) == S.vector_decoding(32n, xs) : Maybe<&2, +List<U32>>}
def Bytes32.deserialize_correct(xs): B.vector_deserialize_correct(32n, xs)
law Bytes32.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Bytes32.deserialize(xs)) == S.vector_domain(32n, xs) : Bool}
def Bytes32.rejection_correct(xs): B.vector_rejection_correct(32n, xs)
law Bytes32.root_correct:
  for +xs: F.Bytes32()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Bytes32.hash_tree_root(xs) == RootSpec.at_depth(32n, depth, xs) : Maybe<&2, +List<U32>>}
def Bytes32.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(32n, xs, depth, minimal)
law Bytes32.root_refinement:
  for +xs: F.Bytes32()
  {F.Bytes32.hash_tree_root(xs) == RootSpec.at_depth(32n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Bytes32.root_refinement(xs): ByteRoot.hash_tree_root_refinement(32n, xs)
law Bytes32.root_rejection:
  for +xs: F.Bytes32()
  {P.is_some(F.Bytes32.hash_tree_root(xs)) == S.vector_domain(32n, xs) : Bool}
def Bytes32.root_rejection(xs): ByteRoot.hash_tree_root_rejection(32n, xs)
law Bytes32.root_scope:
  for +xs: F.Bytes32()
  Tree.result_scope(F.Bytes32.hash_tree_root(xs))
def Bytes32.root_scope(xs): ByteRoot.hash_tree_root_scope(32n, xs)
law Bytes32.root_length:
  for +xs: F.Bytes32()
  {Basic.lengths(F.Bytes32.hash_tree_root(xs)) == Basic.expected_root_length(F.Bytes32.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Bytes32.root_length(xs): ByteRoot.hash_tree_root_length(32n, xs)



law Bytes48.domain_correct:
  for +xs: F.Bytes48()
  {F.Bytes48.valid(xs) == S.vector_domain(48n, xs) : Bool}
def Bytes48.domain_correct(xs): B.vector_domain_correct(48n, xs)
law Bytes48.serialize_correct:
  for +xs: F.Bytes48()
  {F.Bytes48.serialize(xs) == S.vector_encoding(48n, xs) : Maybe<&2, +List<U32>>}
def Bytes48.serialize_correct(xs): B.vector_serialize_correct(48n, xs)
law Bytes48.deserialize_correct:
  for +xs: +List<U32>
  {F.Bytes48.deserialize(xs) == S.vector_decoding(48n, xs) : Maybe<&2, +List<U32>>}
def Bytes48.deserialize_correct(xs): B.vector_deserialize_correct(48n, xs)
law Bytes48.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Bytes48.deserialize(xs)) == S.vector_domain(48n, xs) : Bool}
def Bytes48.rejection_correct(xs): B.vector_rejection_correct(48n, xs)
law Bytes48.root_correct:
  for +xs: F.Bytes48()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Bytes48.hash_tree_root(xs) == RootSpec.at_depth(48n, depth, xs) : Maybe<&2, +List<U32>>}
def Bytes48.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(48n, xs, depth, minimal)
law Bytes48.root_refinement:
  for +xs: F.Bytes48()
  {F.Bytes48.hash_tree_root(xs) == RootSpec.at_depth(48n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Bytes48.root_refinement(xs): ByteRoot.hash_tree_root_refinement(48n, xs)
law Bytes48.root_rejection:
  for +xs: F.Bytes48()
  {P.is_some(F.Bytes48.hash_tree_root(xs)) == S.vector_domain(48n, xs) : Bool}
def Bytes48.root_rejection(xs): ByteRoot.hash_tree_root_rejection(48n, xs)
law Bytes48.root_scope:
  for +xs: F.Bytes48()
  Tree.result_scope(F.Bytes48.hash_tree_root(xs))
def Bytes48.root_scope(xs): ByteRoot.hash_tree_root_scope(48n, xs)
law Bytes48.root_length:
  for +xs: F.Bytes48()
  {Basic.lengths(F.Bytes48.hash_tree_root(xs)) == Basic.expected_root_length(F.Bytes48.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Bytes48.root_length(xs): ByteRoot.hash_tree_root_length(48n, xs)



law Bytes96.domain_correct:
  for +xs: F.Bytes96()
  {F.Bytes96.valid(xs) == S.vector_domain(96n, xs) : Bool}
def Bytes96.domain_correct(xs): B.vector_domain_correct(96n, xs)
law Bytes96.serialize_correct:
  for +xs: F.Bytes96()
  {F.Bytes96.serialize(xs) == S.vector_encoding(96n, xs) : Maybe<&2, +List<U32>>}
def Bytes96.serialize_correct(xs): B.vector_serialize_correct(96n, xs)
law Bytes96.deserialize_correct:
  for +xs: +List<U32>
  {F.Bytes96.deserialize(xs) == S.vector_decoding(96n, xs) : Maybe<&2, +List<U32>>}
def Bytes96.deserialize_correct(xs): B.vector_deserialize_correct(96n, xs)
law Bytes96.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Bytes96.deserialize(xs)) == S.vector_domain(96n, xs) : Bool}
def Bytes96.rejection_correct(xs): B.vector_rejection_correct(96n, xs)
law Bytes96.root_correct:
  for +xs: F.Bytes96()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Bytes96.hash_tree_root(xs) == RootSpec.at_depth(96n, depth, xs) : Maybe<&2, +List<U32>>}
def Bytes96.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(96n, xs, depth, minimal)
law Bytes96.root_refinement:
  for +xs: F.Bytes96()
  {F.Bytes96.hash_tree_root(xs) == RootSpec.at_depth(96n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Bytes96.root_refinement(xs): ByteRoot.hash_tree_root_refinement(96n, xs)
law Bytes96.root_rejection:
  for +xs: F.Bytes96()
  {P.is_some(F.Bytes96.hash_tree_root(xs)) == S.vector_domain(96n, xs) : Bool}
def Bytes96.root_rejection(xs): ByteRoot.hash_tree_root_rejection(96n, xs)
law Bytes96.root_scope:
  for +xs: F.Bytes96()
  Tree.result_scope(F.Bytes96.hash_tree_root(xs))
def Bytes96.root_scope(xs): ByteRoot.hash_tree_root_scope(96n, xs)
law Bytes96.root_length:
  for +xs: F.Bytes96()
  {Basic.lengths(F.Bytes96.hash_tree_root(xs)) == Basic.expected_root_length(F.Bytes96.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Bytes96.root_length(xs): ByteRoot.hash_tree_root_length(96n, xs)



law Bytes8.domain_correct:
  for +xs: F.Bytes8()
  {F.Bytes8.valid(xs) == S.vector_domain(8n, xs) : Bool}
def Bytes8.domain_correct(xs): B.vector_domain_correct(8n, xs)
law Bytes8.serialize_correct:
  for +xs: F.Bytes8()
  {F.Bytes8.serialize(xs) == S.vector_encoding(8n, xs) : Maybe<&2, +List<U32>>}
def Bytes8.serialize_correct(xs): B.vector_serialize_correct(8n, xs)
law Bytes8.deserialize_correct:
  for +xs: +List<U32>
  {F.Bytes8.deserialize(xs) == S.vector_decoding(8n, xs) : Maybe<&2, +List<U32>>}
def Bytes8.deserialize_correct(xs): B.vector_deserialize_correct(8n, xs)
law Bytes8.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Bytes8.deserialize(xs)) == S.vector_domain(8n, xs) : Bool}
def Bytes8.rejection_correct(xs): B.vector_rejection_correct(8n, xs)
law Bytes8.root_correct:
  for +xs: F.Bytes8()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Bytes8.hash_tree_root(xs) == RootSpec.at_depth(8n, depth, xs) : Maybe<&2, +List<U32>>}
def Bytes8.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(8n, xs, depth, minimal)
law Bytes8.root_refinement:
  for +xs: F.Bytes8()
  {F.Bytes8.hash_tree_root(xs) == RootSpec.at_depth(8n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Bytes8.root_refinement(xs): ByteRoot.hash_tree_root_refinement(8n, xs)
law Bytes8.root_rejection:
  for +xs: F.Bytes8()
  {P.is_some(F.Bytes8.hash_tree_root(xs)) == S.vector_domain(8n, xs) : Bool}
def Bytes8.root_rejection(xs): ByteRoot.hash_tree_root_rejection(8n, xs)
law Bytes8.root_scope:
  for +xs: F.Bytes8()
  Tree.result_scope(F.Bytes8.hash_tree_root(xs))
def Bytes8.root_scope(xs): ByteRoot.hash_tree_root_scope(8n, xs)
law Bytes8.root_length:
  for +xs: F.Bytes8()
  {Basic.lengths(F.Bytes8.hash_tree_root(xs)) == Basic.expected_root_length(F.Bytes8.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Bytes8.root_length(xs): ByteRoot.hash_tree_root_length(8n, xs)



law Bytes20.domain_correct:
  for +xs: F.Bytes20()
  {F.Bytes20.valid(xs) == S.vector_domain(20n, xs) : Bool}
def Bytes20.domain_correct(xs): B.vector_domain_correct(20n, xs)
law Bytes20.serialize_correct:
  for +xs: F.Bytes20()
  {F.Bytes20.serialize(xs) == S.vector_encoding(20n, xs) : Maybe<&2, +List<U32>>}
def Bytes20.serialize_correct(xs): B.vector_serialize_correct(20n, xs)
law Bytes20.deserialize_correct:
  for +xs: +List<U32>
  {F.Bytes20.deserialize(xs) == S.vector_decoding(20n, xs) : Maybe<&2, +List<U32>>}
def Bytes20.deserialize_correct(xs): B.vector_deserialize_correct(20n, xs)
law Bytes20.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Bytes20.deserialize(xs)) == S.vector_domain(20n, xs) : Bool}
def Bytes20.rejection_correct(xs): B.vector_rejection_correct(20n, xs)
law Bytes20.root_correct:
  for +xs: F.Bytes20()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Bytes20.hash_tree_root(xs) == RootSpec.at_depth(20n, depth, xs) : Maybe<&2, +List<U32>>}
def Bytes20.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(20n, xs, depth, minimal)
law Bytes20.root_refinement:
  for +xs: F.Bytes20()
  {F.Bytes20.hash_tree_root(xs) == RootSpec.at_depth(20n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Bytes20.root_refinement(xs): ByteRoot.hash_tree_root_refinement(20n, xs)
law Bytes20.root_rejection:
  for +xs: F.Bytes20()
  {P.is_some(F.Bytes20.hash_tree_root(xs)) == S.vector_domain(20n, xs) : Bool}
def Bytes20.root_rejection(xs): ByteRoot.hash_tree_root_rejection(20n, xs)
law Bytes20.root_scope:
  for +xs: F.Bytes20()
  Tree.result_scope(F.Bytes20.hash_tree_root(xs))
def Bytes20.root_scope(xs): ByteRoot.hash_tree_root_scope(20n, xs)
law Bytes20.root_length:
  for +xs: F.Bytes20()
  {Basic.lengths(F.Bytes20.hash_tree_root(xs)) == Basic.expected_root_length(F.Bytes20.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Bytes20.root_length(xs): ByteRoot.hash_tree_root_length(20n, xs)



law Hash32.domain_correct:
  for +xs: F.Hash32()
  {F.Hash32.valid(xs) == S.vector_domain(32n, xs) : Bool}
def Hash32.domain_correct(xs): B.vector_domain_correct(32n, xs)
law Hash32.serialize_correct:
  for +xs: F.Hash32()
  {F.Hash32.serialize(xs) == S.vector_encoding(32n, xs) : Maybe<&2, +List<U32>>}
def Hash32.serialize_correct(xs): B.vector_serialize_correct(32n, xs)
law Hash32.deserialize_correct:
  for +xs: +List<U32>
  {F.Hash32.deserialize(xs) == S.vector_decoding(32n, xs) : Maybe<&2, +List<U32>>}
def Hash32.deserialize_correct(xs): B.vector_deserialize_correct(32n, xs)
law Hash32.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Hash32.deserialize(xs)) == S.vector_domain(32n, xs) : Bool}
def Hash32.rejection_correct(xs): B.vector_rejection_correct(32n, xs)
law Hash32.root_correct:
  for +xs: F.Hash32()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Hash32.hash_tree_root(xs) == RootSpec.at_depth(32n, depth, xs) : Maybe<&2, +List<U32>>}
def Hash32.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(32n, xs, depth, minimal)
law Hash32.root_refinement:
  for +xs: F.Hash32()
  {F.Hash32.hash_tree_root(xs) == RootSpec.at_depth(32n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Hash32.root_refinement(xs): ByteRoot.hash_tree_root_refinement(32n, xs)
law Hash32.root_rejection:
  for +xs: F.Hash32()
  {P.is_some(F.Hash32.hash_tree_root(xs)) == S.vector_domain(32n, xs) : Bool}
def Hash32.root_rejection(xs): ByteRoot.hash_tree_root_rejection(32n, xs)
law Hash32.root_scope:
  for +xs: F.Hash32()
  Tree.result_scope(F.Hash32.hash_tree_root(xs))
def Hash32.root_scope(xs): ByteRoot.hash_tree_root_scope(32n, xs)
law Hash32.root_length:
  for +xs: F.Hash32()
  {Basic.lengths(F.Hash32.hash_tree_root(xs)) == Basic.expected_root_length(F.Hash32.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Hash32.root_length(xs): ByteRoot.hash_tree_root_length(32n, xs)



law Version.domain_correct:
  for +xs: F.Version()
  {F.Version.valid(xs) == S.vector_domain(4n, xs) : Bool}
def Version.domain_correct(xs): B.vector_domain_correct(4n, xs)
law Version.serialize_correct:
  for +xs: F.Version()
  {F.Version.serialize(xs) == S.vector_encoding(4n, xs) : Maybe<&2, +List<U32>>}
def Version.serialize_correct(xs): B.vector_serialize_correct(4n, xs)
law Version.deserialize_correct:
  for +xs: +List<U32>
  {F.Version.deserialize(xs) == S.vector_decoding(4n, xs) : Maybe<&2, +List<U32>>}
def Version.deserialize_correct(xs): B.vector_deserialize_correct(4n, xs)
law Version.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Version.deserialize(xs)) == S.vector_domain(4n, xs) : Bool}
def Version.rejection_correct(xs): B.vector_rejection_correct(4n, xs)
law Version.root_correct:
  for +xs: F.Version()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Version.hash_tree_root(xs) == RootSpec.at_depth(4n, depth, xs) : Maybe<&2, +List<U32>>}
def Version.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(4n, xs, depth, minimal)
law Version.root_refinement:
  for +xs: F.Version()
  {F.Version.hash_tree_root(xs) == RootSpec.at_depth(4n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Version.root_refinement(xs): ByteRoot.hash_tree_root_refinement(4n, xs)
law Version.root_rejection:
  for +xs: F.Version()
  {P.is_some(F.Version.hash_tree_root(xs)) == S.vector_domain(4n, xs) : Bool}
def Version.root_rejection(xs): ByteRoot.hash_tree_root_rejection(4n, xs)
law Version.root_scope:
  for +xs: F.Version()
  Tree.result_scope(F.Version.hash_tree_root(xs))
def Version.root_scope(xs): ByteRoot.hash_tree_root_scope(4n, xs)
law Version.root_length:
  for +xs: F.Version()
  {Basic.lengths(F.Version.hash_tree_root(xs)) == Basic.expected_root_length(F.Version.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Version.root_length(xs): ByteRoot.hash_tree_root_length(4n, xs)



law DomainType.domain_correct:
  for +xs: F.DomainType()
  {F.DomainType.valid(xs) == S.vector_domain(4n, xs) : Bool}
def DomainType.domain_correct(xs): B.vector_domain_correct(4n, xs)
law DomainType.serialize_correct:
  for +xs: F.DomainType()
  {F.DomainType.serialize(xs) == S.vector_encoding(4n, xs) : Maybe<&2, +List<U32>>}
def DomainType.serialize_correct(xs): B.vector_serialize_correct(4n, xs)
law DomainType.deserialize_correct:
  for +xs: +List<U32>
  {F.DomainType.deserialize(xs) == S.vector_decoding(4n, xs) : Maybe<&2, +List<U32>>}
def DomainType.deserialize_correct(xs): B.vector_deserialize_correct(4n, xs)
law DomainType.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.DomainType.deserialize(xs)) == S.vector_domain(4n, xs) : Bool}
def DomainType.rejection_correct(xs): B.vector_rejection_correct(4n, xs)
law DomainType.root_correct:
  for +xs: F.DomainType()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.DomainType.hash_tree_root(xs) == RootSpec.at_depth(4n, depth, xs) : Maybe<&2, +List<U32>>}
def DomainType.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(4n, xs, depth, minimal)
law DomainType.root_refinement:
  for +xs: F.DomainType()
  {F.DomainType.hash_tree_root(xs) == RootSpec.at_depth(4n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def DomainType.root_refinement(xs): ByteRoot.hash_tree_root_refinement(4n, xs)
law DomainType.root_rejection:
  for +xs: F.DomainType()
  {P.is_some(F.DomainType.hash_tree_root(xs)) == S.vector_domain(4n, xs) : Bool}
def DomainType.root_rejection(xs): ByteRoot.hash_tree_root_rejection(4n, xs)
law DomainType.root_scope:
  for +xs: F.DomainType()
  Tree.result_scope(F.DomainType.hash_tree_root(xs))
def DomainType.root_scope(xs): ByteRoot.hash_tree_root_scope(4n, xs)
law DomainType.root_length:
  for +xs: F.DomainType()
  {Basic.lengths(F.DomainType.hash_tree_root(xs)) == Basic.expected_root_length(F.DomainType.hash_tree_root(xs)) : Maybe<&2, Nat>}
def DomainType.root_length(xs): ByteRoot.hash_tree_root_length(4n, xs)



law BLSSignature.domain_correct:
  for +xs: F.BLSSignature()
  {F.BLSSignature.valid(xs) == S.vector_domain(96n, xs) : Bool}
def BLSSignature.domain_correct(xs): B.vector_domain_correct(96n, xs)
law BLSSignature.serialize_correct:
  for +xs: F.BLSSignature()
  {F.BLSSignature.serialize(xs) == S.vector_encoding(96n, xs) : Maybe<&2, +List<U32>>}
def BLSSignature.serialize_correct(xs): B.vector_serialize_correct(96n, xs)
law BLSSignature.deserialize_correct:
  for +xs: +List<U32>
  {F.BLSSignature.deserialize(xs) == S.vector_decoding(96n, xs) : Maybe<&2, +List<U32>>}
def BLSSignature.deserialize_correct(xs): B.vector_deserialize_correct(96n, xs)
law BLSSignature.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.BLSSignature.deserialize(xs)) == S.vector_domain(96n, xs) : Bool}
def BLSSignature.rejection_correct(xs): B.vector_rejection_correct(96n, xs)
law BLSSignature.root_correct:
  for +xs: F.BLSSignature()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.BLSSignature.hash_tree_root(xs) == RootSpec.at_depth(96n, depth, xs) : Maybe<&2, +List<U32>>}
def BLSSignature.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(96n, xs, depth, minimal)
law BLSSignature.root_refinement:
  for +xs: F.BLSSignature()
  {F.BLSSignature.hash_tree_root(xs) == RootSpec.at_depth(96n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def BLSSignature.root_refinement(xs): ByteRoot.hash_tree_root_refinement(96n, xs)
law BLSSignature.root_rejection:
  for +xs: F.BLSSignature()
  {P.is_some(F.BLSSignature.hash_tree_root(xs)) == S.vector_domain(96n, xs) : Bool}
def BLSSignature.root_rejection(xs): ByteRoot.hash_tree_root_rejection(96n, xs)
law BLSSignature.root_scope:
  for +xs: F.BLSSignature()
  Tree.result_scope(F.BLSSignature.hash_tree_root(xs))
def BLSSignature.root_scope(xs): ByteRoot.hash_tree_root_scope(96n, xs)
law BLSSignature.root_length:
  for +xs: F.BLSSignature()
  {Basic.lengths(F.BLSSignature.hash_tree_root(xs)) == Basic.expected_root_length(F.BLSSignature.hash_tree_root(xs)) : Maybe<&2, Nat>}
def BLSSignature.root_length(xs): ByteRoot.hash_tree_root_length(96n, xs)



law VersionedHash.domain_correct:
  for +xs: F.VersionedHash()
  {F.VersionedHash.valid(xs) == S.vector_domain(32n, xs) : Bool}
def VersionedHash.domain_correct(xs): B.vector_domain_correct(32n, xs)
law VersionedHash.serialize_correct:
  for +xs: F.VersionedHash()
  {F.VersionedHash.serialize(xs) == S.vector_encoding(32n, xs) : Maybe<&2, +List<U32>>}
def VersionedHash.serialize_correct(xs): B.vector_serialize_correct(32n, xs)
law VersionedHash.deserialize_correct:
  for +xs: +List<U32>
  {F.VersionedHash.deserialize(xs) == S.vector_decoding(32n, xs) : Maybe<&2, +List<U32>>}
def VersionedHash.deserialize_correct(xs): B.vector_deserialize_correct(32n, xs)
law VersionedHash.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.VersionedHash.deserialize(xs)) == S.vector_domain(32n, xs) : Bool}
def VersionedHash.rejection_correct(xs): B.vector_rejection_correct(32n, xs)
law VersionedHash.root_correct:
  for +xs: F.VersionedHash()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.VersionedHash.hash_tree_root(xs) == RootSpec.at_depth(32n, depth, xs) : Maybe<&2, +List<U32>>}
def VersionedHash.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(32n, xs, depth, minimal)
law VersionedHash.root_refinement:
  for +xs: F.VersionedHash()
  {F.VersionedHash.hash_tree_root(xs) == RootSpec.at_depth(32n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def VersionedHash.root_refinement(xs): ByteRoot.hash_tree_root_refinement(32n, xs)
law VersionedHash.root_rejection:
  for +xs: F.VersionedHash()
  {P.is_some(F.VersionedHash.hash_tree_root(xs)) == S.vector_domain(32n, xs) : Bool}
def VersionedHash.root_rejection(xs): ByteRoot.hash_tree_root_rejection(32n, xs)
law VersionedHash.root_scope:
  for +xs: F.VersionedHash()
  Tree.result_scope(F.VersionedHash.hash_tree_root(xs))
def VersionedHash.root_scope(xs): ByteRoot.hash_tree_root_scope(32n, xs)
law VersionedHash.root_length:
  for +xs: F.VersionedHash()
  {Basic.lengths(F.VersionedHash.hash_tree_root(xs)) == Basic.expected_root_length(F.VersionedHash.hash_tree_root(xs)) : Maybe<&2, Nat>}
def VersionedHash.root_length(xs): ByteRoot.hash_tree_root_length(32n, xs)



law G1Point.domain_correct:
  for +xs: F.G1Point()
  {F.G1Point.valid(xs) == S.vector_domain(48n, xs) : Bool}
def G1Point.domain_correct(xs): B.vector_domain_correct(48n, xs)
law G1Point.serialize_correct:
  for +xs: F.G1Point()
  {F.G1Point.serialize(xs) == S.vector_encoding(48n, xs) : Maybe<&2, +List<U32>>}
def G1Point.serialize_correct(xs): B.vector_serialize_correct(48n, xs)
law G1Point.deserialize_correct:
  for +xs: +List<U32>
  {F.G1Point.deserialize(xs) == S.vector_decoding(48n, xs) : Maybe<&2, +List<U32>>}
def G1Point.deserialize_correct(xs): B.vector_deserialize_correct(48n, xs)
law G1Point.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.G1Point.deserialize(xs)) == S.vector_domain(48n, xs) : Bool}
def G1Point.rejection_correct(xs): B.vector_rejection_correct(48n, xs)
law G1Point.root_correct:
  for +xs: F.G1Point()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.G1Point.hash_tree_root(xs) == RootSpec.at_depth(48n, depth, xs) : Maybe<&2, +List<U32>>}
def G1Point.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(48n, xs, depth, minimal)
law G1Point.root_refinement:
  for +xs: F.G1Point()
  {F.G1Point.hash_tree_root(xs) == RootSpec.at_depth(48n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def G1Point.root_refinement(xs): ByteRoot.hash_tree_root_refinement(48n, xs)
law G1Point.root_rejection:
  for +xs: F.G1Point()
  {P.is_some(F.G1Point.hash_tree_root(xs)) == S.vector_domain(48n, xs) : Bool}
def G1Point.root_rejection(xs): ByteRoot.hash_tree_root_rejection(48n, xs)
law G1Point.root_scope:
  for +xs: F.G1Point()
  Tree.result_scope(F.G1Point.hash_tree_root(xs))
def G1Point.root_scope(xs): ByteRoot.hash_tree_root_scope(48n, xs)
law G1Point.root_length:
  for +xs: F.G1Point()
  {Basic.lengths(F.G1Point.hash_tree_root(xs)) == Basic.expected_root_length(F.G1Point.hash_tree_root(xs)) : Maybe<&2, Nat>}
def G1Point.root_length(xs): ByteRoot.hash_tree_root_length(48n, xs)



law G2Point.domain_correct:
  for +xs: F.G2Point()
  {F.G2Point.valid(xs) == S.vector_domain(96n, xs) : Bool}
def G2Point.domain_correct(xs): B.vector_domain_correct(96n, xs)
law G2Point.serialize_correct:
  for +xs: F.G2Point()
  {F.G2Point.serialize(xs) == S.vector_encoding(96n, xs) : Maybe<&2, +List<U32>>}
def G2Point.serialize_correct(xs): B.vector_serialize_correct(96n, xs)
law G2Point.deserialize_correct:
  for +xs: +List<U32>
  {F.G2Point.deserialize(xs) == S.vector_decoding(96n, xs) : Maybe<&2, +List<U32>>}
def G2Point.deserialize_correct(xs): B.vector_deserialize_correct(96n, xs)
law G2Point.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.G2Point.deserialize(xs)) == S.vector_domain(96n, xs) : Bool}
def G2Point.rejection_correct(xs): B.vector_rejection_correct(96n, xs)
law G2Point.root_correct:
  for +xs: F.G2Point()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.G2Point.hash_tree_root(xs) == RootSpec.at_depth(96n, depth, xs) : Maybe<&2, +List<U32>>}
def G2Point.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(96n, xs, depth, minimal)
law G2Point.root_refinement:
  for +xs: F.G2Point()
  {F.G2Point.hash_tree_root(xs) == RootSpec.at_depth(96n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def G2Point.root_refinement(xs): ByteRoot.hash_tree_root_refinement(96n, xs)
law G2Point.root_rejection:
  for +xs: F.G2Point()
  {P.is_some(F.G2Point.hash_tree_root(xs)) == S.vector_domain(96n, xs) : Bool}
def G2Point.root_rejection(xs): ByteRoot.hash_tree_root_rejection(96n, xs)
law G2Point.root_scope:
  for +xs: F.G2Point()
  Tree.result_scope(F.G2Point.hash_tree_root(xs))
def G2Point.root_scope(xs): ByteRoot.hash_tree_root_scope(96n, xs)
law G2Point.root_length:
  for +xs: F.G2Point()
  {Basic.lengths(F.G2Point.hash_tree_root(xs)) == Basic.expected_root_length(F.G2Point.hash_tree_root(xs)) : Maybe<&2, Nat>}
def G2Point.root_length(xs): ByteRoot.hash_tree_root_length(96n, xs)



law Root.domain_correct:
  for +xs: F.Root()
  {F.Root.valid(xs) == S.vector_domain(32n, xs) : Bool}
def Root.domain_correct(xs): B.vector_domain_correct(32n, xs)
law Root.serialize_correct:
  for +xs: F.Root()
  {F.Root.serialize(xs) == S.vector_encoding(32n, xs) : Maybe<&2, +List<U32>>}
def Root.serialize_correct(xs): B.vector_serialize_correct(32n, xs)
law Root.deserialize_correct:
  for +xs: +List<U32>
  {F.Root.deserialize(xs) == S.vector_decoding(32n, xs) : Maybe<&2, +List<U32>>}
def Root.deserialize_correct(xs): B.vector_deserialize_correct(32n, xs)
law Root.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Root.deserialize(xs)) == S.vector_domain(32n, xs) : Bool}
def Root.rejection_correct(xs): B.vector_rejection_correct(32n, xs)
law Root.root_correct:
  for +xs: F.Root()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Root.hash_tree_root(xs) == RootSpec.at_depth(32n, depth, xs) : Maybe<&2, +List<U32>>}
def Root.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(32n, xs, depth, minimal)
law Root.root_refinement:
  for +xs: F.Root()
  {F.Root.hash_tree_root(xs) == RootSpec.at_depth(32n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Root.root_refinement(xs): ByteRoot.hash_tree_root_refinement(32n, xs)
law Root.root_rejection:
  for +xs: F.Root()
  {P.is_some(F.Root.hash_tree_root(xs)) == S.vector_domain(32n, xs) : Bool}
def Root.root_rejection(xs): ByteRoot.hash_tree_root_rejection(32n, xs)
law Root.root_scope:
  for +xs: F.Root()
  Tree.result_scope(F.Root.hash_tree_root(xs))
def Root.root_scope(xs): ByteRoot.hash_tree_root_scope(32n, xs)
law Root.root_length:
  for +xs: F.Root()
  {Basic.lengths(F.Root.hash_tree_root(xs)) == Basic.expected_root_length(F.Root.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Root.root_length(xs): ByteRoot.hash_tree_root_length(32n, xs)



law ForkDigest.domain_correct:
  for +xs: F.ForkDigest()
  {F.ForkDigest.valid(xs) == S.vector_domain(4n, xs) : Bool}
def ForkDigest.domain_correct(xs): B.vector_domain_correct(4n, xs)
law ForkDigest.serialize_correct:
  for +xs: F.ForkDigest()
  {F.ForkDigest.serialize(xs) == S.vector_encoding(4n, xs) : Maybe<&2, +List<U32>>}
def ForkDigest.serialize_correct(xs): B.vector_serialize_correct(4n, xs)
law ForkDigest.deserialize_correct:
  for +xs: +List<U32>
  {F.ForkDigest.deserialize(xs) == S.vector_decoding(4n, xs) : Maybe<&2, +List<U32>>}
def ForkDigest.deserialize_correct(xs): B.vector_deserialize_correct(4n, xs)
law ForkDigest.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.ForkDigest.deserialize(xs)) == S.vector_domain(4n, xs) : Bool}
def ForkDigest.rejection_correct(xs): B.vector_rejection_correct(4n, xs)
law ForkDigest.root_correct:
  for +xs: F.ForkDigest()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.ForkDigest.hash_tree_root(xs) == RootSpec.at_depth(4n, depth, xs) : Maybe<&2, +List<U32>>}
def ForkDigest.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(4n, xs, depth, minimal)
law ForkDigest.root_refinement:
  for +xs: F.ForkDigest()
  {F.ForkDigest.hash_tree_root(xs) == RootSpec.at_depth(4n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def ForkDigest.root_refinement(xs): ByteRoot.hash_tree_root_refinement(4n, xs)
law ForkDigest.root_rejection:
  for +xs: F.ForkDigest()
  {P.is_some(F.ForkDigest.hash_tree_root(xs)) == S.vector_domain(4n, xs) : Bool}
def ForkDigest.root_rejection(xs): ByteRoot.hash_tree_root_rejection(4n, xs)
law ForkDigest.root_scope:
  for +xs: F.ForkDigest()
  Tree.result_scope(F.ForkDigest.hash_tree_root(xs))
def ForkDigest.root_scope(xs): ByteRoot.hash_tree_root_scope(4n, xs)
law ForkDigest.root_length:
  for +xs: F.ForkDigest()
  {Basic.lengths(F.ForkDigest.hash_tree_root(xs)) == Basic.expected_root_length(F.ForkDigest.hash_tree_root(xs)) : Maybe<&2, Nat>}
def ForkDigest.root_length(xs): ByteRoot.hash_tree_root_length(4n, xs)



law Domain.domain_correct:
  for +xs: F.Domain()
  {F.Domain.valid(xs) == S.vector_domain(32n, xs) : Bool}
def Domain.domain_correct(xs): B.vector_domain_correct(32n, xs)
law Domain.serialize_correct:
  for +xs: F.Domain()
  {F.Domain.serialize(xs) == S.vector_encoding(32n, xs) : Maybe<&2, +List<U32>>}
def Domain.serialize_correct(xs): B.vector_serialize_correct(32n, xs)
law Domain.deserialize_correct:
  for +xs: +List<U32>
  {F.Domain.deserialize(xs) == S.vector_decoding(32n, xs) : Maybe<&2, +List<U32>>}
def Domain.deserialize_correct(xs): B.vector_deserialize_correct(32n, xs)
law Domain.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Domain.deserialize(xs)) == S.vector_domain(32n, xs) : Bool}
def Domain.rejection_correct(xs): B.vector_rejection_correct(32n, xs)
law Domain.root_correct:
  for +xs: F.Domain()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Domain.hash_tree_root(xs) == RootSpec.at_depth(32n, depth, xs) : Maybe<&2, +List<U32>>}
def Domain.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(32n, xs, depth, minimal)
law Domain.root_refinement:
  for +xs: F.Domain()
  {F.Domain.hash_tree_root(xs) == RootSpec.at_depth(32n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Domain.root_refinement(xs): ByteRoot.hash_tree_root_refinement(32n, xs)
law Domain.root_rejection:
  for +xs: F.Domain()
  {P.is_some(F.Domain.hash_tree_root(xs)) == S.vector_domain(32n, xs) : Bool}
def Domain.root_rejection(xs): ByteRoot.hash_tree_root_rejection(32n, xs)
law Domain.root_scope:
  for +xs: F.Domain()
  Tree.result_scope(F.Domain.hash_tree_root(xs))
def Domain.root_scope(xs): ByteRoot.hash_tree_root_scope(32n, xs)
law Domain.root_length:
  for +xs: F.Domain()
  {Basic.lengths(F.Domain.hash_tree_root(xs)) == Basic.expected_root_length(F.Domain.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Domain.root_length(xs): ByteRoot.hash_tree_root_length(32n, xs)



law BLSPubkey.domain_correct:
  for +xs: F.BLSPubkey()
  {F.BLSPubkey.valid(xs) == S.vector_domain(48n, xs) : Bool}
def BLSPubkey.domain_correct(xs): B.vector_domain_correct(48n, xs)
law BLSPubkey.serialize_correct:
  for +xs: F.BLSPubkey()
  {F.BLSPubkey.serialize(xs) == S.vector_encoding(48n, xs) : Maybe<&2, +List<U32>>}
def BLSPubkey.serialize_correct(xs): B.vector_serialize_correct(48n, xs)
law BLSPubkey.deserialize_correct:
  for +xs: +List<U32>
  {F.BLSPubkey.deserialize(xs) == S.vector_decoding(48n, xs) : Maybe<&2, +List<U32>>}
def BLSPubkey.deserialize_correct(xs): B.vector_deserialize_correct(48n, xs)
law BLSPubkey.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.BLSPubkey.deserialize(xs)) == S.vector_domain(48n, xs) : Bool}
def BLSPubkey.rejection_correct(xs): B.vector_rejection_correct(48n, xs)
law BLSPubkey.root_correct:
  for +xs: F.BLSPubkey()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.BLSPubkey.hash_tree_root(xs) == RootSpec.at_depth(48n, depth, xs) : Maybe<&2, +List<U32>>}
def BLSPubkey.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(48n, xs, depth, minimal)
law BLSPubkey.root_refinement:
  for +xs: F.BLSPubkey()
  {F.BLSPubkey.hash_tree_root(xs) == RootSpec.at_depth(48n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def BLSPubkey.root_refinement(xs): ByteRoot.hash_tree_root_refinement(48n, xs)
law BLSPubkey.root_rejection:
  for +xs: F.BLSPubkey()
  {P.is_some(F.BLSPubkey.hash_tree_root(xs)) == S.vector_domain(48n, xs) : Bool}
def BLSPubkey.root_rejection(xs): ByteRoot.hash_tree_root_rejection(48n, xs)
law BLSPubkey.root_scope:
  for +xs: F.BLSPubkey()
  Tree.result_scope(F.BLSPubkey.hash_tree_root(xs))
def BLSPubkey.root_scope(xs): ByteRoot.hash_tree_root_scope(48n, xs)
law BLSPubkey.root_length:
  for +xs: F.BLSPubkey()
  {Basic.lengths(F.BLSPubkey.hash_tree_root(xs)) == Basic.expected_root_length(F.BLSPubkey.hash_tree_root(xs)) : Maybe<&2, Nat>}
def BLSPubkey.root_length(xs): ByteRoot.hash_tree_root_length(48n, xs)



law ExecutionAddress.domain_correct:
  for +xs: F.ExecutionAddress()
  {F.ExecutionAddress.valid(xs) == S.vector_domain(20n, xs) : Bool}
def ExecutionAddress.domain_correct(xs): B.vector_domain_correct(20n, xs)
law ExecutionAddress.serialize_correct:
  for +xs: F.ExecutionAddress()
  {F.ExecutionAddress.serialize(xs) == S.vector_encoding(20n, xs) : Maybe<&2, +List<U32>>}
def ExecutionAddress.serialize_correct(xs): B.vector_serialize_correct(20n, xs)
law ExecutionAddress.deserialize_correct:
  for +xs: +List<U32>
  {F.ExecutionAddress.deserialize(xs) == S.vector_decoding(20n, xs) : Maybe<&2, +List<U32>>}
def ExecutionAddress.deserialize_correct(xs): B.vector_deserialize_correct(20n, xs)
law ExecutionAddress.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.ExecutionAddress.deserialize(xs)) == S.vector_domain(20n, xs) : Bool}
def ExecutionAddress.rejection_correct(xs): B.vector_rejection_correct(20n, xs)
law ExecutionAddress.root_correct:
  for +xs: F.ExecutionAddress()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.ExecutionAddress.hash_tree_root(xs) == RootSpec.at_depth(20n, depth, xs) : Maybe<&2, +List<U32>>}
def ExecutionAddress.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(20n, xs, depth, minimal)
law ExecutionAddress.root_refinement:
  for +xs: F.ExecutionAddress()
  {F.ExecutionAddress.hash_tree_root(xs) == RootSpec.at_depth(20n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def ExecutionAddress.root_refinement(xs): ByteRoot.hash_tree_root_refinement(20n, xs)
law ExecutionAddress.root_rejection:
  for +xs: F.ExecutionAddress()
  {P.is_some(F.ExecutionAddress.hash_tree_root(xs)) == S.vector_domain(20n, xs) : Bool}
def ExecutionAddress.root_rejection(xs): ByteRoot.hash_tree_root_rejection(20n, xs)
law ExecutionAddress.root_scope:
  for +xs: F.ExecutionAddress()
  Tree.result_scope(F.ExecutionAddress.hash_tree_root(xs))
def ExecutionAddress.root_scope(xs): ByteRoot.hash_tree_root_scope(20n, xs)
law ExecutionAddress.root_length:
  for +xs: F.ExecutionAddress()
  {Basic.lengths(F.ExecutionAddress.hash_tree_root(xs)) == Basic.expected_root_length(F.ExecutionAddress.hash_tree_root(xs)) : Maybe<&2, Nat>}
def ExecutionAddress.root_length(xs): ByteRoot.hash_tree_root_length(20n, xs)



law PayloadId.domain_correct:
  for +xs: F.PayloadId()
  {F.PayloadId.valid(xs) == S.vector_domain(8n, xs) : Bool}
def PayloadId.domain_correct(xs): B.vector_domain_correct(8n, xs)
law PayloadId.serialize_correct:
  for +xs: F.PayloadId()
  {F.PayloadId.serialize(xs) == S.vector_encoding(8n, xs) : Maybe<&2, +List<U32>>}
def PayloadId.serialize_correct(xs): B.vector_serialize_correct(8n, xs)
law PayloadId.deserialize_correct:
  for +xs: +List<U32>
  {F.PayloadId.deserialize(xs) == S.vector_decoding(8n, xs) : Maybe<&2, +List<U32>>}
def PayloadId.deserialize_correct(xs): B.vector_deserialize_correct(8n, xs)
law PayloadId.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.PayloadId.deserialize(xs)) == S.vector_domain(8n, xs) : Bool}
def PayloadId.rejection_correct(xs): B.vector_rejection_correct(8n, xs)
law PayloadId.root_correct:
  for +xs: F.PayloadId()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.PayloadId.hash_tree_root(xs) == RootSpec.at_depth(8n, depth, xs) : Maybe<&2, +List<U32>>}
def PayloadId.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(8n, xs, depth, minimal)
law PayloadId.root_refinement:
  for +xs: F.PayloadId()
  {F.PayloadId.hash_tree_root(xs) == RootSpec.at_depth(8n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def PayloadId.root_refinement(xs): ByteRoot.hash_tree_root_refinement(8n, xs)
law PayloadId.root_rejection:
  for +xs: F.PayloadId()
  {P.is_some(F.PayloadId.hash_tree_root(xs)) == S.vector_domain(8n, xs) : Bool}
def PayloadId.root_rejection(xs): ByteRoot.hash_tree_root_rejection(8n, xs)
law PayloadId.root_scope:
  for +xs: F.PayloadId()
  Tree.result_scope(F.PayloadId.hash_tree_root(xs))
def PayloadId.root_scope(xs): ByteRoot.hash_tree_root_scope(8n, xs)
law PayloadId.root_length:
  for +xs: F.PayloadId()
  {Basic.lengths(F.PayloadId.hash_tree_root(xs)) == Basic.expected_root_length(F.PayloadId.hash_tree_root(xs)) : Maybe<&2, Nat>}
def PayloadId.root_length(xs): ByteRoot.hash_tree_root_length(8n, xs)



law KZGCommitment.domain_correct:
  for +xs: F.KZGCommitment()
  {F.KZGCommitment.valid(xs) == S.vector_domain(48n, xs) : Bool}
def KZGCommitment.domain_correct(xs): B.vector_domain_correct(48n, xs)
law KZGCommitment.serialize_correct:
  for +xs: F.KZGCommitment()
  {F.KZGCommitment.serialize(xs) == S.vector_encoding(48n, xs) : Maybe<&2, +List<U32>>}
def KZGCommitment.serialize_correct(xs): B.vector_serialize_correct(48n, xs)
law KZGCommitment.deserialize_correct:
  for +xs: +List<U32>
  {F.KZGCommitment.deserialize(xs) == S.vector_decoding(48n, xs) : Maybe<&2, +List<U32>>}
def KZGCommitment.deserialize_correct(xs): B.vector_deserialize_correct(48n, xs)
law KZGCommitment.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.KZGCommitment.deserialize(xs)) == S.vector_domain(48n, xs) : Bool}
def KZGCommitment.rejection_correct(xs): B.vector_rejection_correct(48n, xs)
law KZGCommitment.root_correct:
  for +xs: F.KZGCommitment()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.KZGCommitment.hash_tree_root(xs) == RootSpec.at_depth(48n, depth, xs) : Maybe<&2, +List<U32>>}
def KZGCommitment.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(48n, xs, depth, minimal)
law KZGCommitment.root_refinement:
  for +xs: F.KZGCommitment()
  {F.KZGCommitment.hash_tree_root(xs) == RootSpec.at_depth(48n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def KZGCommitment.root_refinement(xs): ByteRoot.hash_tree_root_refinement(48n, xs)
law KZGCommitment.root_rejection:
  for +xs: F.KZGCommitment()
  {P.is_some(F.KZGCommitment.hash_tree_root(xs)) == S.vector_domain(48n, xs) : Bool}
def KZGCommitment.root_rejection(xs): ByteRoot.hash_tree_root_rejection(48n, xs)
law KZGCommitment.root_scope:
  for +xs: F.KZGCommitment()
  Tree.result_scope(F.KZGCommitment.hash_tree_root(xs))
def KZGCommitment.root_scope(xs): ByteRoot.hash_tree_root_scope(48n, xs)
law KZGCommitment.root_length:
  for +xs: F.KZGCommitment()
  {Basic.lengths(F.KZGCommitment.hash_tree_root(xs)) == Basic.expected_root_length(F.KZGCommitment.hash_tree_root(xs)) : Maybe<&2, Nat>}
def KZGCommitment.root_length(xs): ByteRoot.hash_tree_root_length(48n, xs)



law KZGProof.domain_correct:
  for +xs: F.KZGProof()
  {F.KZGProof.valid(xs) == S.vector_domain(48n, xs) : Bool}
def KZGProof.domain_correct(xs): B.vector_domain_correct(48n, xs)
law KZGProof.serialize_correct:
  for +xs: F.KZGProof()
  {F.KZGProof.serialize(xs) == S.vector_encoding(48n, xs) : Maybe<&2, +List<U32>>}
def KZGProof.serialize_correct(xs): B.vector_serialize_correct(48n, xs)
law KZGProof.deserialize_correct:
  for +xs: +List<U32>
  {F.KZGProof.deserialize(xs) == S.vector_decoding(48n, xs) : Maybe<&2, +List<U32>>}
def KZGProof.deserialize_correct(xs): B.vector_deserialize_correct(48n, xs)
law KZGProof.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.KZGProof.deserialize(xs)) == S.vector_domain(48n, xs) : Bool}
def KZGProof.rejection_correct(xs): B.vector_rejection_correct(48n, xs)
law KZGProof.root_correct:
  for +xs: F.KZGProof()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.KZGProof.hash_tree_root(xs) == RootSpec.at_depth(48n, depth, xs) : Maybe<&2, +List<U32>>}
def KZGProof.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(48n, xs, depth, minimal)
law KZGProof.root_refinement:
  for +xs: F.KZGProof()
  {F.KZGProof.hash_tree_root(xs) == RootSpec.at_depth(48n, ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def KZGProof.root_refinement(xs): ByteRoot.hash_tree_root_refinement(48n, xs)
law KZGProof.root_rejection:
  for +xs: F.KZGProof()
  {P.is_some(F.KZGProof.hash_tree_root(xs)) == S.vector_domain(48n, xs) : Bool}
def KZGProof.root_rejection(xs): ByteRoot.hash_tree_root_rejection(48n, xs)
law KZGProof.root_scope:
  for +xs: F.KZGProof()
  Tree.result_scope(F.KZGProof.hash_tree_root(xs))
def KZGProof.root_scope(xs): ByteRoot.hash_tree_root_scope(48n, xs)
law KZGProof.root_length:
  for +xs: F.KZGProof()
  {Basic.lengths(F.KZGProof.hash_tree_root(xs)) == Basic.expected_root_length(F.KZGProof.hash_tree_root(xs)) : Maybe<&2, Nat>}
def KZGProof.root_length(xs): ByteRoot.hash_tree_root_length(48n, xs)


# Blob: generic byte-codec theorems apply, but direct large-bound
# specialization is covered by the closed-inventory laws in fulu_byte_inventory.bend.


law Cell.domain_correct:
  for +xs: F.Cell()
  {F.Cell.valid(xs) == S.vector_domain(Nat.mul(2n, 1024n), xs) : Bool}
def Cell.domain_correct(xs): B.vector_domain_correct(Nat.mul(2n, 1024n), xs)
law Cell.serialize_correct:
  for +xs: F.Cell()
  {F.Cell.serialize(xs) == S.vector_encoding(Nat.mul(2n, 1024n), xs) : Maybe<&2, +List<U32>>}
def Cell.serialize_correct(xs): B.vector_serialize_correct(Nat.mul(2n, 1024n), xs)
law Cell.deserialize_correct:
  for +xs: +List<U32>
  {F.Cell.deserialize(xs) == S.vector_decoding(Nat.mul(2n, 1024n), xs) : Maybe<&2, +List<U32>>}
def Cell.deserialize_correct(xs): B.vector_deserialize_correct(Nat.mul(2n, 1024n), xs)
law Cell.rejection_correct:
  for +xs: +List<U32>
  {P.is_some(F.Cell.deserialize(xs)) == S.vector_domain(Nat.mul(2n, 1024n), xs) : Bool}
def Cell.rejection_correct(xs): B.vector_rejection_correct(Nat.mul(2n, 1024n), xs)
law Cell.root_correct:
  for +xs: F.Cell()
  for +depth: Nat
  for minimal: {RootSpec.canonical_depth(xs, depth) == True{} : Bool}
  {F.Cell.hash_tree_root(xs) == RootSpec.at_depth(Nat.mul(2n, 1024n), depth, xs) : Maybe<&2, +List<U32>>}
def Cell.root_correct(xs, depth, minimal): ByteRoot.hash_tree_root_correct(Nat.mul(2n, 1024n), xs, depth, minimal)
law Cell.root_refinement:
  for +xs: F.Cell()
  {F.Cell.hash_tree_root(xs) == RootSpec.at_depth(Nat.mul(2n, 1024n), ByteRoot.witness(xs), xs) : Maybe<&2, +List<U32>>}
def Cell.root_refinement(xs): ByteRoot.hash_tree_root_refinement(Nat.mul(2n, 1024n), xs)
law Cell.root_rejection:
  for +xs: F.Cell()
  {P.is_some(F.Cell.hash_tree_root(xs)) == S.vector_domain(Nat.mul(2n, 1024n), xs) : Bool}
def Cell.root_rejection(xs): ByteRoot.hash_tree_root_rejection(Nat.mul(2n, 1024n), xs)
law Cell.root_scope:
  for +xs: F.Cell()
  Tree.result_scope(F.Cell.hash_tree_root(xs))
def Cell.root_scope(xs): ByteRoot.hash_tree_root_scope(Nat.mul(2n, 1024n), xs)
law Cell.root_length:
  for +xs: F.Cell()
  {Basic.lengths(F.Cell.hash_tree_root(xs)) == Basic.expected_root_length(F.Cell.hash_tree_root(xs)) : Maybe<&2, Nat>}
def Cell.root_length(xs): ByteRoot.hash_tree_root_length(Nat.mul(2n, 1024n), xs)

