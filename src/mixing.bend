import Base
import ./primitives.bend as P
import ./merkle.bend as M
import ../types/primitive.bend as T

# All eight-limb UInt values are in the uint256 domain. No host integer
# conversion, truncation, or separate upper-bound assumption is needed.
def mix_in_length(+root: +List<U32>, length: T.UInt) -> Maybe<&2, +List<U32>>:
  M.pair_checked(P.valid_bytes(32n, root), root, P.uint_bytes(length))

# Selector is a uint8 value, zero-extended to one Merkle chunk.
# Union option membership is checked by the enclosing union codec.
def mix_in_selector(+root: +List<U32>, +selector: U32) -> Maybe<&2, +List<U32>>:
  M.pair_checked(Bool.and(P.valid_bytes(32n, root), U32.is_lt(selector, 256)), root, P.pad(32n, [selector]))
