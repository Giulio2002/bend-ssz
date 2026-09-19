import Base
import ./primitives.bend as P
import ./packing.bend as Pack
import ./limits.bend as Merkle
import ./nat_bytes.bend as Length
import ./bit_root.bend as Mix

# Homogeneous byte lists are already in their canonical byte representation.
# The sequence serialization algorithm additionally requires total size < 2^32.
def domain(+capacity: Nat, +xs: +List<U32>) -> Bool:
  Bool.and(Bool.and(P.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), capacity)), Length.fits(4n, List.length(&2, U32, xs)))

def encoding(capacity: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  P.optional(domain(capacity, xs), xs)

def decoding(capacity: Nat, xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  encoding(capacity, xs)

def chunk_limit(capacity: Nat) -> Nat:
  Nat.div(Nat.add(capacity, 31n), 32n)

def root_gate(ok: Bool, capacity: Nat, depth: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}:
      Mix.mix_length_bytes(Merkle.at_depth(chunk_limit(capacity), depth, Pack.scan(xs, 31n, [], [])), Length.encoding(32n, List.length(&2, U32, xs)))

def at_depth(+capacity: Nat, depth: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  root_gate(domain(capacity, xs), capacity, depth, xs)
