import Base
import ./primitives.bend as P
import ../types/primitive.bend as T
import 0xe4067e0d858024083f36a7abe7281e89/spec/crypto/sha.bend as FIPS

# simple-serialize.md, Merkleization: hash(root || uint256_LE(length)).
# full_digits is independent arithmetic base-256 expansion of eight limbs.
def checked(ok: Bool, root: +List<U32>, length: T.UInt) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{FIPS.sha256_bytes(List.append(&2, U32, root, P.full_digits(length)))}

def mix_in_length(+root: +List<U32>, length: T.UInt) -> Maybe<&2, +List<U32>>:
  checked(P.byte_scope(32n, root), root, length)

# The uint8 selector occupies the first byte of a zero-filled Merkle chunk.
# See CORRESPONDENCE.md for the pinned document/fixture disambiguation.
def selector_domain(+root: +List<U32>, selector: U32) -> Bool:
  Bool.and(P.byte_scope(32n, root), U32.is_lt(selector, 256))

def selector_chunk(selector: U32) -> +List<U32>:
  List.append(&2, U32, [selector], P.zero_bytes(31n))

def selector_checked(ok: Bool, root: +List<U32>, selector: U32) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{FIPS.sha256_bytes(List.append(&2, U32, root, selector_chunk(selector)))}

def mix_in_selector(+root: +List<U32>, +selector: U32) -> Maybe<&2, +List<U32>>:
  selector_checked(selector_domain(root, selector), root, selector)
