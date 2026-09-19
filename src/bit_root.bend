import Base
import ./nat_bytes.bend as Length
import ./merkle.bend as Node
import ./bitfields.bend as Fields
import ./bit_packing.bend as Bits
import ./packing.bend as Pack
import ./limits.bend as Merkle

# Mathematical Nat arithmetic: no machine-width narrowing of the SSZ limit.
def chunk_limit(capacity: Nat) -> Nat:
  Nat.div(Nat.add(capacity, 255n), 256n)

# The serialization delimiter never enters root packing.
def chunks(bits: +List<Bool>) -> +List<+List<U32>>:
  Pack.scan(Bits.pack(bits), 31n, [], [])

def vector_gate(ok: Bool, size: Nat, bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Merkle.merkleize(chunk_limit(size), chunks(bits))

def bitvector_hash_tree_root(+size: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  vector_gate(Fields.vector_valid(size, bits), size, bits)

# The length is converted without narrowing; uint256 overflow is rejected.
def mix_length_bytes(root: Maybe<&2, +List<U32>>, length: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match root length:
    case None{} None{}: None{}
    case None{} Some{xs}: None{}
    case Some{xs} None{}: None{}
    case Some{xs} Some{ys}: Node.hash_pair(xs, ys)

def list_gate(ok: Bool, capacity: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}:
      mix_length_bytes(Merkle.merkleize(chunk_limit(capacity), chunks(bits)), Length.encode(32n, List.length(&2, Bool, bits)))

def bitlist_hash_tree_root(+capacity: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  list_gate(Fields.list_valid(capacity, bits), capacity, bits)
