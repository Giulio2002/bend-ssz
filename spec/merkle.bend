import Base
import ./primitives.bend as P
import 0xe4067e0d858024083f36a7abe7281e89/spec/crypto/sha.bend as FIPS

# Normative binary-node hashing, independent of the optimized runtime SHA.
def pair_checked(ok: Bool, left: +List<U32>, right: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{FIPS.sha256_bytes(List.append(&2, U32, left, right))}

def hash_pair(+left: +List<U32>, +right: +List<U32>) -> Maybe<&2, +List<U32>>:
  pair_checked(Bool.and(P.byte_scope(32n, left), P.byte_scope(32n, right)), left, right)

# The empty leaf is Bytes32(); each level hashes its two equal child roots.
# This characterizes virtual padding independently through FIPS SHA-256.
def zero_subtree(depth: Nat) -> +List<U32>:
  match depth:
    case 0n: P.zero_bytes(32n)
    case 1n+p:
      +child = zero_subtree(p)
      FIPS.sha256_bytes(List.append(&2, U32, child, child))
