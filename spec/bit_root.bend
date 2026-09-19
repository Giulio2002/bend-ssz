import Base
import ./nat_bytes.bend as Length
import ../vendor/bend_sha256/fips.bend as FIPS
import ./bitfields.bend as Fields
import ./bit_packing.bend as Bits
import ./packing.bend as Pack
import ./limits.bend as Merkle

# SSZ chunk_count(Bitvector[N]) = ceil(N / 256). Nat is unbounded.
def chunk_limit(capacity: Nat) -> Nat:
  Nat.div(Nat.add(capacity, 255n), 256n)

# Normative arithmetic bit packing without a serialization delimiter, followed
# by consecutive 32-byte grouping and zero padding of the last partial chunk.
def chunks(bits: +List<Bool>) -> +List<+List<U32>>:
  Pack.scan(Bits.pack(bits), 31n, [], [])

def canonical_depth(capacity: Nat, depth: Nat) -> Bool:
  Merkle.minimal(chunk_limit(capacity), depth)

def vector_gate(ok: Bool, size: Nat, depth: Nat, bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Merkle.at_depth(chunk_limit(size), depth, chunks(bits))

def bitvector_at_depth(+size: Nat, depth: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  vector_gate(Fields.vector_domain(size, bits), size, depth, bits)

# Normative mix_in_length: the data root followed by the exact uint256 length.
# The serialization delimiter is absent from chunks(bits).
def mix_length_bytes(root: Maybe<&2, +List<U32>>, length: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match root length:
    case None{} None{}: None{}
    case None{} Some{xs}: None{}
    case Some{xs} None{}: None{}
    case Some{xs} Some{ys}: Some{FIPS.sha256_bytes(List.append(&2, U32, xs, ys))}

def list_gate(ok: Bool, capacity: Nat, depth: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}:
      mix_length_bytes(Merkle.at_depth(chunk_limit(capacity), depth, chunks(bits)), Length.encoding(32n, List.length(&2, Bool, bits)))

def bitlist_at_depth(+capacity: Nat, depth: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  list_gate(Fields.list_domain(capacity, bits), capacity, depth, bits)
