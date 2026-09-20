import Base
import ./packing.bend as Pack
import ./primitives.bend as P
import ./limits.bend as Merkle
import ./nat_bytes.bend as Length
import ./bit_root.bend as Mix

# List[byte, capacity]: bytes retain their order, with no offset or delimiter.
# The normative sequence serialization bound is strict total size < 2^32.
def valid(+capacity: Nat, +xs: +List<U32>) -> Bool:
  Bool.and(Bool.and(Pack.valid_go(xs, True{}), Nat.is_le(List.length(&2, U32, xs), capacity)), P.is_some(Length.encode(4n, List.length(&2, U32, xs))))

def serialize(capacity: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  P.accept_bytes(valid(capacity, xs), xs)

def deserialize(capacity: Nat, xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  serialize(capacity, xs)

def chunk_limit(capacity: Nat) -> Nat:
  Nat.div(Nat.add(capacity, 31n), 32n)

def root_gate(ok: Bool, capacity: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}:
      Mix.mix_length_bytes(Merkle.merkleize(chunk_limit(capacity), Pack.scan(xs, 31n, [], [])), Length.encode(32n, List.length(&2, U32, xs)))

def hash_tree_root(+capacity: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  root_gate(valid(capacity, xs), capacity, xs)

# Root-only domain for ByteList[capacity] inside the generic Merkleization
# path: byte range and length <= capacity. The uint256 length mix is checked by
# the mixer itself; the serializer's 4-byte size bound is not a root condition.
def root_valid(+capacity: Nat, +xs: +List<U32>) -> Bool:
  Bool.and(Pack.valid_go(xs, True{}), Nat.is_le(List.length(&2, U32, xs), capacity))

def merkle_root(+capacity: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  root_gate(root_valid(capacity, xs), capacity, xs)
