import Base
import ../vendor/bend_sha256/sha256.bend as SHA

# Use the pinned upstream optimized implementation directly.
def hash(xs: +List<U32>) -> +List<U32>:
  SHA.sha256_bytes(xs)

def get_or_zero(x: Maybe<&2, U32>) -> U32:
  match x:
    case None{}:
      0
    case Some{v}:
      v

def at(xs: +List<U32>, index: Nat) -> U32:
  get_or_zero(List.get(&2, U32, xs, index))
