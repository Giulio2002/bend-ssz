import Base
import 0xd9a2fae439ac7ff9e21e0853948f94fe/src/crypto/sha/sha256.bend as SHA

# Use the pinned upstream optimized implementation directly.
def hash(xs: +List<U32>) -> +List<U32>:
  SHA.sha256_bytes(xs)
