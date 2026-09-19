import Base
import ./primitives.bend as P
import ./sha256.bend as H

# A binary Merkle node hashes two exact SSZ chunks with the pinned SHA API.
def pair_checked(ok: Bool, left: +List<U32>, right: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{H.hash(List.append(&2, U32, left, right))}

def hash_pair(+left: +List<U32>, +right: +List<U32>) -> Maybe<&2, +List<U32>>:
  pair_checked(Bool.and(P.valid_bytes(32n, left), P.valid_bytes(32n, right)), left, right)

# Root of a complete all-zero subtree with 2^depth leaves. This uses O(depth)
# hashes and never materializes those leaves.
def zero_hash(depth: Nat) -> +List<U32>:
  match depth:
    case 0n: P.pad(32n, [])
    case 1n+p:
      +child = zero_hash(p)
      H.hash(List.append(&2, U32, child, child))
