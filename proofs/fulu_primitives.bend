import Base
import ../types/primitive.bend as T
import ../types/fulu_primitives.bend as F
import ../spec/primitives.bend as S
import ./integer_encoding.bend as E
import ./integer_decoding.bend as D
import ./encoding_complete.bend as C
import ./primitives.bend as P
import ./primitive_invariants.bend as V
import ./boolean_canonical.bend as B


law boolean.serialize_correct:
  for b: Bool
  {F.boolean.serialize(b) == S.boolean_encoding(b) : +List<U32>}
def boolean.serialize_correct(b): P.boolean_serialize_correct(b)
law boolean.deserialize_correct:
  for xs: +List<U32>
  {F.boolean.deserialize(xs) == S.boolean_decoding(xs) : Maybe<&2, Bool>}
def boolean.deserialize_correct(xs): P.boolean_deserialize_correct(xs)
law boolean.root_correct:
  for b: Bool
  {F.boolean.hash_tree_root(b) == S.boolean_hash_tree_root(b) : +List<U32>}
def boolean.root_correct(b): P.boolean_hash_tree_root_correct(b)
law boolean.decoding_complete:
  for b: Bool
  {F.boolean.deserialize(S.boolean_encoding(b)) == Some{b} : Maybe<&2, Bool>}
def boolean.decoding_complete(b): P.boolean_decoding_complete(b)
law boolean.accepted_sound:
  for +xs: +List<U32>
  for b: Bool
  for e: {F.boolean.deserialize(xs) == Some{b} : Maybe<&2, Bool>}
  {S.boolean_encoding(b) == xs : +List<U32>}
def boolean.accepted_sound(xs, b, e): B.boolean_accepted_sound(xs, b, e)
law boolean.root_length:
  for b: Bool
  {List.length(&2, U32, F.boolean.hash_tree_root(b)) == 32n : Nat}
def boolean.root_length(b): P.boolean_root_length(b)


law uint8.serialize_correct:
  for +v: F.uint8()
  {F.uint8.serialize(v) == S.uint_encoding(T.U8{}, v) : Maybe<&2, +List<U32>>}
def uint8.serialize_correct(v): E.uint_serialize_correct(T.U8{}, v)
law uint8.deserialize_correct:
  for +xs: +List<U32>
  {F.uint8.deserialize(xs) == S.uint_decoding(T.U8{}, xs) : Maybe<&2, T.UInt>}
def uint8.deserialize_correct(xs): D.uint_deserialize_correct(T.U8{}, xs)
law uint8.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.uint8.deserialize(xs)) == Bool.not(S.byte_scope(1n, xs)) : Bool}
def uint8.rejection_correct(xs): P.uint_rejection_correct(T.U8{}, xs)
law uint8.root_correct:
  for +v: F.uint8()
  {F.uint8.hash_tree_root(v) == S.uint_hash_tree_root(T.U8{}, v) : Maybe<&2, +List<U32>>}
def uint8.root_correct(v): E.uint_hash_tree_root_correct(T.U8{}, v)
law uint8.domain_correct:
  for +v: F.uint8()
  {F.uint8.valid(v) == S.uint_domain(T.U8{}, v) : Bool}
def uint8.domain_correct(v): E.uint_domain_correct(T.U8{}, v)
law uint8.serialized_scope:
  for +v: F.uint8()
  V.scoped(1n, F.uint8.serialize(v))
def uint8.serialized_scope(v): V.uint_serialized_scope(T.U8{}, v)
law uint8.decoding_complete:
  for +v: F.uint8()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U8{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.uint8.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def uint8.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U8{}, v, xs, e)
law uint8.accepted_sound:
  for +xs: +List<U32>
  for +v: F.uint8()
  for e: {F.uint8.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U8{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def uint8.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U8{}, xs, v, e)
law uint8.accepted_domain:
  for +xs: +List<U32>
  for +v: F.uint8()
  for e: {F.uint8.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.uint8.valid(v) == True{} : Bool}
def uint8.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U8{}, xs, v, e)
law uint8.root_length:
  for +v: F.uint8()
  {P.lengths(F.uint8.hash_tree_root(v)) == P.expected_root_length(F.uint8.serialize(v)) : Maybe<&2, Nat>}
def uint8.root_length(v): P.uint_root_length(T.U8{}, v)


law uint32.serialize_correct:
  for +v: F.uint32()
  {F.uint32.serialize(v) == S.uint_encoding(T.U32Width{}, v) : Maybe<&2, +List<U32>>}
def uint32.serialize_correct(v): E.uint_serialize_correct(T.U32Width{}, v)
law uint32.deserialize_correct:
  for +xs: +List<U32>
  {F.uint32.deserialize(xs) == S.uint_decoding(T.U32Width{}, xs) : Maybe<&2, T.UInt>}
def uint32.deserialize_correct(xs): D.uint_deserialize_correct(T.U32Width{}, xs)
law uint32.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.uint32.deserialize(xs)) == Bool.not(S.byte_scope(4n, xs)) : Bool}
def uint32.rejection_correct(xs): P.uint_rejection_correct(T.U32Width{}, xs)
law uint32.root_correct:
  for +v: F.uint32()
  {F.uint32.hash_tree_root(v) == S.uint_hash_tree_root(T.U32Width{}, v) : Maybe<&2, +List<U32>>}
def uint32.root_correct(v): E.uint_hash_tree_root_correct(T.U32Width{}, v)
law uint32.domain_correct:
  for +v: F.uint32()
  {F.uint32.valid(v) == S.uint_domain(T.U32Width{}, v) : Bool}
def uint32.domain_correct(v): E.uint_domain_correct(T.U32Width{}, v)
law uint32.serialized_scope:
  for +v: F.uint32()
  V.scoped(4n, F.uint32.serialize(v))
def uint32.serialized_scope(v): V.uint_serialized_scope(T.U32Width{}, v)
law uint32.decoding_complete:
  for +v: F.uint32()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U32Width{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.uint32.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def uint32.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U32Width{}, v, xs, e)
law uint32.accepted_sound:
  for +xs: +List<U32>
  for +v: F.uint32()
  for e: {F.uint32.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U32Width{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def uint32.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U32Width{}, xs, v, e)
law uint32.accepted_domain:
  for +xs: +List<U32>
  for +v: F.uint32()
  for e: {F.uint32.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.uint32.valid(v) == True{} : Bool}
def uint32.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U32Width{}, xs, v, e)
law uint32.root_length:
  for +v: F.uint32()
  {P.lengths(F.uint32.hash_tree_root(v)) == P.expected_root_length(F.uint32.serialize(v)) : Maybe<&2, Nat>}
def uint32.root_length(v): P.uint_root_length(T.U32Width{}, v)


law uint64.serialize_correct:
  for +v: F.uint64()
  {F.uint64.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def uint64.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law uint64.deserialize_correct:
  for +xs: +List<U32>
  {F.uint64.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def uint64.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law uint64.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.uint64.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def uint64.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law uint64.root_correct:
  for +v: F.uint64()
  {F.uint64.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def uint64.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law uint64.domain_correct:
  for +v: F.uint64()
  {F.uint64.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def uint64.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law uint64.serialized_scope:
  for +v: F.uint64()
  V.scoped(8n, F.uint64.serialize(v))
def uint64.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law uint64.decoding_complete:
  for +v: F.uint64()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.uint64.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def uint64.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law uint64.accepted_sound:
  for +xs: +List<U32>
  for +v: F.uint64()
  for e: {F.uint64.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def uint64.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law uint64.accepted_domain:
  for +xs: +List<U32>
  for +v: F.uint64()
  for e: {F.uint64.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.uint64.valid(v) == True{} : Bool}
def uint64.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law uint64.root_length:
  for +v: F.uint64()
  {P.lengths(F.uint64.hash_tree_root(v)) == P.expected_root_length(F.uint64.serialize(v)) : Maybe<&2, Nat>}
def uint64.root_length(v): P.uint_root_length(T.U64{}, v)


law uint256.serialize_correct:
  for +v: F.uint256()
  {F.uint256.serialize(v) == S.uint_encoding(T.U256{}, v) : Maybe<&2, +List<U32>>}
def uint256.serialize_correct(v): E.uint_serialize_correct(T.U256{}, v)
law uint256.deserialize_correct:
  for +xs: +List<U32>
  {F.uint256.deserialize(xs) == S.uint_decoding(T.U256{}, xs) : Maybe<&2, T.UInt>}
def uint256.deserialize_correct(xs): D.uint_deserialize_correct(T.U256{}, xs)
law uint256.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.uint256.deserialize(xs)) == Bool.not(S.byte_scope(32n, xs)) : Bool}
def uint256.rejection_correct(xs): P.uint_rejection_correct(T.U256{}, xs)
law uint256.root_correct:
  for +v: F.uint256()
  {F.uint256.hash_tree_root(v) == S.uint_hash_tree_root(T.U256{}, v) : Maybe<&2, +List<U32>>}
def uint256.root_correct(v): E.uint_hash_tree_root_correct(T.U256{}, v)
law uint256.domain_correct:
  for +v: F.uint256()
  {F.uint256.valid(v) == S.uint_domain(T.U256{}, v) : Bool}
def uint256.domain_correct(v): E.uint_domain_correct(T.U256{}, v)
law uint256.serialized_scope:
  for +v: F.uint256()
  V.scoped(32n, F.uint256.serialize(v))
def uint256.serialized_scope(v): V.uint_serialized_scope(T.U256{}, v)
law uint256.decoding_complete:
  for +v: F.uint256()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U256{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.uint256.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def uint256.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U256{}, v, xs, e)
law uint256.accepted_sound:
  for +xs: +List<U32>
  for +v: F.uint256()
  for e: {F.uint256.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U256{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def uint256.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U256{}, xs, v, e)
law uint256.accepted_domain:
  for +xs: +List<U32>
  for +v: F.uint256()
  for e: {F.uint256.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.uint256.valid(v) == True{} : Bool}
def uint256.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U256{}, xs, v, e)
law uint256.root_length:
  for +v: F.uint256()
  {P.lengths(F.uint256.hash_tree_root(v)) == P.expected_root_length(F.uint256.serialize(v)) : Maybe<&2, Nat>}
def uint256.root_length(v): P.uint_root_length(T.U256{}, v)


law Slot.serialize_correct:
  for +v: F.Slot()
  {F.Slot.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def Slot.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law Slot.deserialize_correct:
  for +xs: +List<U32>
  {F.Slot.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def Slot.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law Slot.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.Slot.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def Slot.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law Slot.root_correct:
  for +v: F.Slot()
  {F.Slot.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def Slot.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law Slot.domain_correct:
  for +v: F.Slot()
  {F.Slot.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def Slot.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law Slot.serialized_scope:
  for +v: F.Slot()
  V.scoped(8n, F.Slot.serialize(v))
def Slot.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law Slot.decoding_complete:
  for +v: F.Slot()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.Slot.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def Slot.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law Slot.accepted_sound:
  for +xs: +List<U32>
  for +v: F.Slot()
  for e: {F.Slot.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def Slot.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law Slot.accepted_domain:
  for +xs: +List<U32>
  for +v: F.Slot()
  for e: {F.Slot.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.Slot.valid(v) == True{} : Bool}
def Slot.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law Slot.root_length:
  for +v: F.Slot()
  {P.lengths(F.Slot.hash_tree_root(v)) == P.expected_root_length(F.Slot.serialize(v)) : Maybe<&2, Nat>}
def Slot.root_length(v): P.uint_root_length(T.U64{}, v)


law Epoch.serialize_correct:
  for +v: F.Epoch()
  {F.Epoch.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def Epoch.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law Epoch.deserialize_correct:
  for +xs: +List<U32>
  {F.Epoch.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def Epoch.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law Epoch.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.Epoch.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def Epoch.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law Epoch.root_correct:
  for +v: F.Epoch()
  {F.Epoch.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def Epoch.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law Epoch.domain_correct:
  for +v: F.Epoch()
  {F.Epoch.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def Epoch.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law Epoch.serialized_scope:
  for +v: F.Epoch()
  V.scoped(8n, F.Epoch.serialize(v))
def Epoch.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law Epoch.decoding_complete:
  for +v: F.Epoch()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.Epoch.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def Epoch.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law Epoch.accepted_sound:
  for +xs: +List<U32>
  for +v: F.Epoch()
  for e: {F.Epoch.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def Epoch.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law Epoch.accepted_domain:
  for +xs: +List<U32>
  for +v: F.Epoch()
  for e: {F.Epoch.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.Epoch.valid(v) == True{} : Bool}
def Epoch.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law Epoch.root_length:
  for +v: F.Epoch()
  {P.lengths(F.Epoch.hash_tree_root(v)) == P.expected_root_length(F.Epoch.serialize(v)) : Maybe<&2, Nat>}
def Epoch.root_length(v): P.uint_root_length(T.U64{}, v)


law Gwei.serialize_correct:
  for +v: F.Gwei()
  {F.Gwei.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def Gwei.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law Gwei.deserialize_correct:
  for +xs: +List<U32>
  {F.Gwei.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def Gwei.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law Gwei.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.Gwei.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def Gwei.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law Gwei.root_correct:
  for +v: F.Gwei()
  {F.Gwei.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def Gwei.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law Gwei.domain_correct:
  for +v: F.Gwei()
  {F.Gwei.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def Gwei.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law Gwei.serialized_scope:
  for +v: F.Gwei()
  V.scoped(8n, F.Gwei.serialize(v))
def Gwei.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law Gwei.decoding_complete:
  for +v: F.Gwei()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.Gwei.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def Gwei.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law Gwei.accepted_sound:
  for +xs: +List<U32>
  for +v: F.Gwei()
  for e: {F.Gwei.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def Gwei.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law Gwei.accepted_domain:
  for +xs: +List<U32>
  for +v: F.Gwei()
  for e: {F.Gwei.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.Gwei.valid(v) == True{} : Bool}
def Gwei.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law Gwei.root_length:
  for +v: F.Gwei()
  {P.lengths(F.Gwei.hash_tree_root(v)) == P.expected_root_length(F.Gwei.serialize(v)) : Maybe<&2, Nat>}
def Gwei.root_length(v): P.uint_root_length(T.U64{}, v)


law CommitteeIndex.serialize_correct:
  for +v: F.CommitteeIndex()
  {F.CommitteeIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def CommitteeIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law CommitteeIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.CommitteeIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def CommitteeIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law CommitteeIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.CommitteeIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def CommitteeIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law CommitteeIndex.root_correct:
  for +v: F.CommitteeIndex()
  {F.CommitteeIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def CommitteeIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law CommitteeIndex.domain_correct:
  for +v: F.CommitteeIndex()
  {F.CommitteeIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def CommitteeIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law CommitteeIndex.serialized_scope:
  for +v: F.CommitteeIndex()
  V.scoped(8n, F.CommitteeIndex.serialize(v))
def CommitteeIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law CommitteeIndex.decoding_complete:
  for +v: F.CommitteeIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.CommitteeIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def CommitteeIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law CommitteeIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.CommitteeIndex()
  for e: {F.CommitteeIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def CommitteeIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law CommitteeIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.CommitteeIndex()
  for e: {F.CommitteeIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.CommitteeIndex.valid(v) == True{} : Bool}
def CommitteeIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law CommitteeIndex.root_length:
  for +v: F.CommitteeIndex()
  {P.lengths(F.CommitteeIndex.hash_tree_root(v)) == P.expected_root_length(F.CommitteeIndex.serialize(v)) : Maybe<&2, Nat>}
def CommitteeIndex.root_length(v): P.uint_root_length(T.U64{}, v)


law ValidatorIndex.serialize_correct:
  for +v: F.ValidatorIndex()
  {F.ValidatorIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def ValidatorIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law ValidatorIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.ValidatorIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def ValidatorIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law ValidatorIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.ValidatorIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def ValidatorIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law ValidatorIndex.root_correct:
  for +v: F.ValidatorIndex()
  {F.ValidatorIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def ValidatorIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law ValidatorIndex.domain_correct:
  for +v: F.ValidatorIndex()
  {F.ValidatorIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def ValidatorIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law ValidatorIndex.serialized_scope:
  for +v: F.ValidatorIndex()
  V.scoped(8n, F.ValidatorIndex.serialize(v))
def ValidatorIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law ValidatorIndex.decoding_complete:
  for +v: F.ValidatorIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.ValidatorIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def ValidatorIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law ValidatorIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.ValidatorIndex()
  for e: {F.ValidatorIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def ValidatorIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law ValidatorIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.ValidatorIndex()
  for e: {F.ValidatorIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.ValidatorIndex.valid(v) == True{} : Bool}
def ValidatorIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law ValidatorIndex.root_length:
  for +v: F.ValidatorIndex()
  {P.lengths(F.ValidatorIndex.hash_tree_root(v)) == P.expected_root_length(F.ValidatorIndex.serialize(v)) : Maybe<&2, Nat>}
def ValidatorIndex.root_length(v): P.uint_root_length(T.U64{}, v)


law NodeID.serialize_correct:
  for +v: F.NodeID()
  {F.NodeID.serialize(v) == S.uint_encoding(T.U256{}, v) : Maybe<&2, +List<U32>>}
def NodeID.serialize_correct(v): E.uint_serialize_correct(T.U256{}, v)
law NodeID.deserialize_correct:
  for +xs: +List<U32>
  {F.NodeID.deserialize(xs) == S.uint_decoding(T.U256{}, xs) : Maybe<&2, T.UInt>}
def NodeID.deserialize_correct(xs): D.uint_deserialize_correct(T.U256{}, xs)
law NodeID.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.NodeID.deserialize(xs)) == Bool.not(S.byte_scope(32n, xs)) : Bool}
def NodeID.rejection_correct(xs): P.uint_rejection_correct(T.U256{}, xs)
law NodeID.root_correct:
  for +v: F.NodeID()
  {F.NodeID.hash_tree_root(v) == S.uint_hash_tree_root(T.U256{}, v) : Maybe<&2, +List<U32>>}
def NodeID.root_correct(v): E.uint_hash_tree_root_correct(T.U256{}, v)
law NodeID.domain_correct:
  for +v: F.NodeID()
  {F.NodeID.valid(v) == S.uint_domain(T.U256{}, v) : Bool}
def NodeID.domain_correct(v): E.uint_domain_correct(T.U256{}, v)
law NodeID.serialized_scope:
  for +v: F.NodeID()
  V.scoped(32n, F.NodeID.serialize(v))
def NodeID.serialized_scope(v): V.uint_serialized_scope(T.U256{}, v)
law NodeID.decoding_complete:
  for +v: F.NodeID()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U256{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.NodeID.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def NodeID.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U256{}, v, xs, e)
law NodeID.accepted_sound:
  for +xs: +List<U32>
  for +v: F.NodeID()
  for e: {F.NodeID.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U256{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def NodeID.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U256{}, xs, v, e)
law NodeID.accepted_domain:
  for +xs: +List<U32>
  for +v: F.NodeID()
  for e: {F.NodeID.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.NodeID.valid(v) == True{} : Bool}
def NodeID.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U256{}, xs, v, e)
law NodeID.root_length:
  for +v: F.NodeID()
  {P.lengths(F.NodeID.hash_tree_root(v)) == P.expected_root_length(F.NodeID.serialize(v)) : Maybe<&2, Nat>}
def NodeID.root_length(v): P.uint_root_length(T.U256{}, v)


law SubnetID.serialize_correct:
  for +v: F.SubnetID()
  {F.SubnetID.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def SubnetID.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law SubnetID.deserialize_correct:
  for +xs: +List<U32>
  {F.SubnetID.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def SubnetID.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law SubnetID.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.SubnetID.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def SubnetID.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law SubnetID.root_correct:
  for +v: F.SubnetID()
  {F.SubnetID.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def SubnetID.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law SubnetID.domain_correct:
  for +v: F.SubnetID()
  {F.SubnetID.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def SubnetID.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law SubnetID.serialized_scope:
  for +v: F.SubnetID()
  V.scoped(8n, F.SubnetID.serialize(v))
def SubnetID.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law SubnetID.decoding_complete:
  for +v: F.SubnetID()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.SubnetID.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def SubnetID.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law SubnetID.accepted_sound:
  for +xs: +List<U32>
  for +v: F.SubnetID()
  for e: {F.SubnetID.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def SubnetID.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law SubnetID.accepted_domain:
  for +xs: +List<U32>
  for +v: F.SubnetID()
  for e: {F.SubnetID.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.SubnetID.valid(v) == True{} : Bool}
def SubnetID.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law SubnetID.root_length:
  for +v: F.SubnetID()
  {P.lengths(F.SubnetID.hash_tree_root(v)) == P.expected_root_length(F.SubnetID.serialize(v)) : Maybe<&2, Nat>}
def SubnetID.root_length(v): P.uint_root_length(T.U64{}, v)


law Ether.serialize_correct:
  for +v: F.Ether()
  {F.Ether.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def Ether.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law Ether.deserialize_correct:
  for +xs: +List<U32>
  {F.Ether.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def Ether.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law Ether.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.Ether.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def Ether.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law Ether.root_correct:
  for +v: F.Ether()
  {F.Ether.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def Ether.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law Ether.domain_correct:
  for +v: F.Ether()
  {F.Ether.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def Ether.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law Ether.serialized_scope:
  for +v: F.Ether()
  V.scoped(8n, F.Ether.serialize(v))
def Ether.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law Ether.decoding_complete:
  for +v: F.Ether()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.Ether.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def Ether.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law Ether.accepted_sound:
  for +xs: +List<U32>
  for +v: F.Ether()
  for e: {F.Ether.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def Ether.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law Ether.accepted_domain:
  for +xs: +List<U32>
  for +v: F.Ether()
  for e: {F.Ether.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.Ether.valid(v) == True{} : Bool}
def Ether.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law Ether.root_length:
  for +v: F.Ether()
  {P.lengths(F.Ether.hash_tree_root(v)) == P.expected_root_length(F.Ether.serialize(v)) : Maybe<&2, Nat>}
def Ether.root_length(v): P.uint_root_length(T.U64{}, v)


law ParticipationFlags.serialize_correct:
  for +v: F.ParticipationFlags()
  {F.ParticipationFlags.serialize(v) == S.uint_encoding(T.U8{}, v) : Maybe<&2, +List<U32>>}
def ParticipationFlags.serialize_correct(v): E.uint_serialize_correct(T.U8{}, v)
law ParticipationFlags.deserialize_correct:
  for +xs: +List<U32>
  {F.ParticipationFlags.deserialize(xs) == S.uint_decoding(T.U8{}, xs) : Maybe<&2, T.UInt>}
def ParticipationFlags.deserialize_correct(xs): D.uint_deserialize_correct(T.U8{}, xs)
law ParticipationFlags.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.ParticipationFlags.deserialize(xs)) == Bool.not(S.byte_scope(1n, xs)) : Bool}
def ParticipationFlags.rejection_correct(xs): P.uint_rejection_correct(T.U8{}, xs)
law ParticipationFlags.root_correct:
  for +v: F.ParticipationFlags()
  {F.ParticipationFlags.hash_tree_root(v) == S.uint_hash_tree_root(T.U8{}, v) : Maybe<&2, +List<U32>>}
def ParticipationFlags.root_correct(v): E.uint_hash_tree_root_correct(T.U8{}, v)
law ParticipationFlags.domain_correct:
  for +v: F.ParticipationFlags()
  {F.ParticipationFlags.valid(v) == S.uint_domain(T.U8{}, v) : Bool}
def ParticipationFlags.domain_correct(v): E.uint_domain_correct(T.U8{}, v)
law ParticipationFlags.serialized_scope:
  for +v: F.ParticipationFlags()
  V.scoped(1n, F.ParticipationFlags.serialize(v))
def ParticipationFlags.serialized_scope(v): V.uint_serialized_scope(T.U8{}, v)
law ParticipationFlags.decoding_complete:
  for +v: F.ParticipationFlags()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U8{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.ParticipationFlags.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def ParticipationFlags.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U8{}, v, xs, e)
law ParticipationFlags.accepted_sound:
  for +xs: +List<U32>
  for +v: F.ParticipationFlags()
  for e: {F.ParticipationFlags.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U8{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def ParticipationFlags.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U8{}, xs, v, e)
law ParticipationFlags.accepted_domain:
  for +xs: +List<U32>
  for +v: F.ParticipationFlags()
  for e: {F.ParticipationFlags.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.ParticipationFlags.valid(v) == True{} : Bool}
def ParticipationFlags.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U8{}, xs, v, e)
law ParticipationFlags.root_length:
  for +v: F.ParticipationFlags()
  {P.lengths(F.ParticipationFlags.hash_tree_root(v)) == P.expected_root_length(F.ParticipationFlags.serialize(v)) : Maybe<&2, Nat>}
def ParticipationFlags.root_length(v): P.uint_root_length(T.U8{}, v)


law WithdrawalIndex.serialize_correct:
  for +v: F.WithdrawalIndex()
  {F.WithdrawalIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def WithdrawalIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law WithdrawalIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.WithdrawalIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def WithdrawalIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law WithdrawalIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.WithdrawalIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def WithdrawalIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law WithdrawalIndex.root_correct:
  for +v: F.WithdrawalIndex()
  {F.WithdrawalIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def WithdrawalIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law WithdrawalIndex.domain_correct:
  for +v: F.WithdrawalIndex()
  {F.WithdrawalIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def WithdrawalIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law WithdrawalIndex.serialized_scope:
  for +v: F.WithdrawalIndex()
  V.scoped(8n, F.WithdrawalIndex.serialize(v))
def WithdrawalIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law WithdrawalIndex.decoding_complete:
  for +v: F.WithdrawalIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.WithdrawalIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def WithdrawalIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law WithdrawalIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.WithdrawalIndex()
  for e: {F.WithdrawalIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def WithdrawalIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law WithdrawalIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.WithdrawalIndex()
  for e: {F.WithdrawalIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.WithdrawalIndex.valid(v) == True{} : Bool}
def WithdrawalIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law WithdrawalIndex.root_length:
  for +v: F.WithdrawalIndex()
  {P.lengths(F.WithdrawalIndex.hash_tree_root(v)) == P.expected_root_length(F.WithdrawalIndex.serialize(v)) : Maybe<&2, Nat>}
def WithdrawalIndex.root_length(v): P.uint_root_length(T.U64{}, v)


law BlobIndex.serialize_correct:
  for +v: F.BlobIndex()
  {F.BlobIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def BlobIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law BlobIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.BlobIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def BlobIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law BlobIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.BlobIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def BlobIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law BlobIndex.root_correct:
  for +v: F.BlobIndex()
  {F.BlobIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def BlobIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law BlobIndex.domain_correct:
  for +v: F.BlobIndex()
  {F.BlobIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def BlobIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law BlobIndex.serialized_scope:
  for +v: F.BlobIndex()
  V.scoped(8n, F.BlobIndex.serialize(v))
def BlobIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law BlobIndex.decoding_complete:
  for +v: F.BlobIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.BlobIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def BlobIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law BlobIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.BlobIndex()
  for e: {F.BlobIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def BlobIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law BlobIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.BlobIndex()
  for e: {F.BlobIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.BlobIndex.valid(v) == True{} : Bool}
def BlobIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law BlobIndex.root_length:
  for +v: F.BlobIndex()
  {P.lengths(F.BlobIndex.hash_tree_root(v)) == P.expected_root_length(F.BlobIndex.serialize(v)) : Maybe<&2, Nat>}
def BlobIndex.root_length(v): P.uint_root_length(T.U64{}, v)


law CellIndex.serialize_correct:
  for +v: F.CellIndex()
  {F.CellIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def CellIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law CellIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.CellIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def CellIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law CellIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.CellIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def CellIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law CellIndex.root_correct:
  for +v: F.CellIndex()
  {F.CellIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def CellIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law CellIndex.domain_correct:
  for +v: F.CellIndex()
  {F.CellIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def CellIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law CellIndex.serialized_scope:
  for +v: F.CellIndex()
  V.scoped(8n, F.CellIndex.serialize(v))
def CellIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law CellIndex.decoding_complete:
  for +v: F.CellIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.CellIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def CellIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law CellIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.CellIndex()
  for e: {F.CellIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def CellIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law CellIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.CellIndex()
  for e: {F.CellIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.CellIndex.valid(v) == True{} : Bool}
def CellIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law CellIndex.root_length:
  for +v: F.CellIndex()
  {P.lengths(F.CellIndex.hash_tree_root(v)) == P.expected_root_length(F.CellIndex.serialize(v)) : Maybe<&2, Nat>}
def CellIndex.root_length(v): P.uint_root_length(T.U64{}, v)


law CommitmentIndex.serialize_correct:
  for +v: F.CommitmentIndex()
  {F.CommitmentIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def CommitmentIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law CommitmentIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.CommitmentIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def CommitmentIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law CommitmentIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.CommitmentIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def CommitmentIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law CommitmentIndex.root_correct:
  for +v: F.CommitmentIndex()
  {F.CommitmentIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def CommitmentIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law CommitmentIndex.domain_correct:
  for +v: F.CommitmentIndex()
  {F.CommitmentIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def CommitmentIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law CommitmentIndex.serialized_scope:
  for +v: F.CommitmentIndex()
  V.scoped(8n, F.CommitmentIndex.serialize(v))
def CommitmentIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law CommitmentIndex.decoding_complete:
  for +v: F.CommitmentIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.CommitmentIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def CommitmentIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law CommitmentIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.CommitmentIndex()
  for e: {F.CommitmentIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def CommitmentIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law CommitmentIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.CommitmentIndex()
  for e: {F.CommitmentIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.CommitmentIndex.valid(v) == True{} : Bool}
def CommitmentIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law CommitmentIndex.root_length:
  for +v: F.CommitmentIndex()
  {P.lengths(F.CommitmentIndex.hash_tree_root(v)) == P.expected_root_length(F.CommitmentIndex.serialize(v)) : Maybe<&2, Nat>}
def CommitmentIndex.root_length(v): P.uint_root_length(T.U64{}, v)


law RowIndex.serialize_correct:
  for +v: F.RowIndex()
  {F.RowIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def RowIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law RowIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.RowIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def RowIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law RowIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.RowIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def RowIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law RowIndex.root_correct:
  for +v: F.RowIndex()
  {F.RowIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def RowIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law RowIndex.domain_correct:
  for +v: F.RowIndex()
  {F.RowIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def RowIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law RowIndex.serialized_scope:
  for +v: F.RowIndex()
  V.scoped(8n, F.RowIndex.serialize(v))
def RowIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law RowIndex.decoding_complete:
  for +v: F.RowIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.RowIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def RowIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law RowIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.RowIndex()
  for e: {F.RowIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def RowIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law RowIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.RowIndex()
  for e: {F.RowIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.RowIndex.valid(v) == True{} : Bool}
def RowIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law RowIndex.root_length:
  for +v: F.RowIndex()
  {P.lengths(F.RowIndex.hash_tree_root(v)) == P.expected_root_length(F.RowIndex.serialize(v)) : Maybe<&2, Nat>}
def RowIndex.root_length(v): P.uint_root_length(T.U64{}, v)


law ColumnIndex.serialize_correct:
  for +v: F.ColumnIndex()
  {F.ColumnIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def ColumnIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law ColumnIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.ColumnIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def ColumnIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law ColumnIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.ColumnIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def ColumnIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law ColumnIndex.root_correct:
  for +v: F.ColumnIndex()
  {F.ColumnIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def ColumnIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law ColumnIndex.domain_correct:
  for +v: F.ColumnIndex()
  {F.ColumnIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def ColumnIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law ColumnIndex.serialized_scope:
  for +v: F.ColumnIndex()
  V.scoped(8n, F.ColumnIndex.serialize(v))
def ColumnIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law ColumnIndex.decoding_complete:
  for +v: F.ColumnIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.ColumnIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def ColumnIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law ColumnIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.ColumnIndex()
  for e: {F.ColumnIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def ColumnIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law ColumnIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.ColumnIndex()
  for e: {F.ColumnIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.ColumnIndex.valid(v) == True{} : Bool}
def ColumnIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law ColumnIndex.root_length:
  for +v: F.ColumnIndex()
  {P.lengths(F.ColumnIndex.hash_tree_root(v)) == P.expected_root_length(F.ColumnIndex.serialize(v)) : Maybe<&2, Nat>}
def ColumnIndex.root_length(v): P.uint_root_length(T.U64{}, v)


law CustodyIndex.serialize_correct:
  for +v: F.CustodyIndex()
  {F.CustodyIndex.serialize(v) == S.uint_encoding(T.U64{}, v) : Maybe<&2, +List<U32>>}
def CustodyIndex.serialize_correct(v): E.uint_serialize_correct(T.U64{}, v)
law CustodyIndex.deserialize_correct:
  for +xs: +List<U32>
  {F.CustodyIndex.deserialize(xs) == S.uint_decoding(T.U64{}, xs) : Maybe<&2, T.UInt>}
def CustodyIndex.deserialize_correct(xs): D.uint_deserialize_correct(T.U64{}, xs)
law CustodyIndex.rejection_correct:
  for +xs: +List<U32>
  {P.integer_rejected(F.CustodyIndex.deserialize(xs)) == Bool.not(S.byte_scope(8n, xs)) : Bool}
def CustodyIndex.rejection_correct(xs): P.uint_rejection_correct(T.U64{}, xs)
law CustodyIndex.root_correct:
  for +v: F.CustodyIndex()
  {F.CustodyIndex.hash_tree_root(v) == S.uint_hash_tree_root(T.U64{}, v) : Maybe<&2, +List<U32>>}
def CustodyIndex.root_correct(v): E.uint_hash_tree_root_correct(T.U64{}, v)
law CustodyIndex.domain_correct:
  for +v: F.CustodyIndex()
  {F.CustodyIndex.valid(v) == S.uint_domain(T.U64{}, v) : Bool}
def CustodyIndex.domain_correct(v): E.uint_domain_correct(T.U64{}, v)
law CustodyIndex.serialized_scope:
  for +v: F.CustodyIndex()
  V.scoped(8n, F.CustodyIndex.serialize(v))
def CustodyIndex.serialized_scope(v): V.uint_serialized_scope(T.U64{}, v)
law CustodyIndex.decoding_complete:
  for +v: F.CustodyIndex()
  for +xs: +List<U32>
  for e: {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {F.CustodyIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
def CustodyIndex.decoding_complete(v, xs, e): C.uint_decoding_complete(T.U64{}, v, xs, e)
law CustodyIndex.accepted_sound:
  for +xs: +List<U32>
  for +v: F.CustodyIndex()
  for e: {F.CustodyIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(T.U64{}, v) == Some{xs} : Maybe<&2, +List<U32>>}
def CustodyIndex.accepted_sound(xs, v, e): C.uint_accepted_sound(T.U64{}, xs, v, e)
law CustodyIndex.accepted_domain:
  for +xs: +List<U32>
  for +v: F.CustodyIndex()
  for e: {F.CustodyIndex.deserialize(xs) == Some{v} : Maybe<&2, T.UInt>}
  {F.CustodyIndex.valid(v) == True{} : Bool}
def CustodyIndex.accepted_domain(xs, v, e): C.uint_accepted_domain(T.U64{}, xs, v, e)
law CustodyIndex.root_length:
  for +v: F.CustodyIndex()
  {P.lengths(F.CustodyIndex.hash_tree_root(v)) == P.expected_root_length(F.CustodyIndex.serialize(v)) : Maybe<&2, Nat>}
def CustodyIndex.root_length(v): P.uint_root_length(T.U64{}, v)
