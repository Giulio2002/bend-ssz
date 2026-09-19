import Base
import ./tree.bend as T
import ./packing.bend as Pack

# Independent characterization of the unique least perfect-tree depth covering
# the requested limit. Zero maps to a single zero leaf, as specified by SSZ.
def lower(+limit: Nat, depth: Nat) -> Bool:
  match depth:
    case 0n: True{}
    case 1n+p: Nat.is_lt(T.capacity(p), limit)

def minimal(+limit: Nat, +depth: Nat) -> Bool:
  Bool.and(Nat.is_le(limit, T.capacity(depth)), lower(limit, depth))

# Meaning at ANY depth satisfying minimal(limit, depth); uniqueness is a proof
# obligation, not a definition in terms of the implementation's depth selector.
def at_depth(+limit: Nat, depth: Nat, +chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  T.checked(Bool.and(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), limit)), depth, chunks)
