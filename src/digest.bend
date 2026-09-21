import Base
import 0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend as PKG

# A 32-byte SSZ chunk held as eight big-endian words instead of thirty-two
# list cells, and the single hashing primitive SSZ merkleization needs.
#
# Hashing goes through the pinned BendHub package
# `0xda83506fb9f059ead7afcfa2f498df5f` (Giulio2002/bend-sha256), whose sole
# production entry point takes a packed `Array<U32>` and a byte length and
# returns eight packed words. Nothing on this path builds, walks or consumes a
# linked list: the sixteen input words are written straight into a perfect
# sixteen-slot array and the eight result words are read straight out of the
# array the package returns.
#
# `bytes` is the byte-list *view* of a chunk. It exists for the specifications
# and their proofs only; no runtime path calls it.
type Digest is Data:
  D{w0: U32, w1: U32, w2: U32, w3: U32, w4: U32, w5: U32, w6: U32, w7: U32}

# The message array for one Merkle node: left chunk then right chunk, four
# big-endian bytes per word, sixteen words = the 64-byte message.
def words16(+a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32,
            +b0: U32, +b1: U32, +b2: U32, +b3: U32, +b4: U32, +b5: U32, +b6: U32, +b7: U32) -> Array<U32>:
  ANode{ANode{ANode{ANode{ALeaf{a0}, ALeaf{a1}}, ANode{ALeaf{a2}, ALeaf{a3}}},
              ANode{ANode{ALeaf{a4}, ALeaf{a5}}, ANode{ALeaf{a6}, ALeaf{a7}}}},
        ANode{ANode{ANode{ALeaf{b0}, ALeaf{b1}}, ANode{ALeaf{b2}, ALeaf{b3}}},
              ANode{ANode{ALeaf{b4}, ALeaf{b5}}, ANode{ALeaf{b6}, ALeaf{b7}}}}}

def pair_words(l: Digest, r: Digest) -> Array<U32>:
  match l:
    case D{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7}:
      match r:
        case D{+b0, +b1, +b2, +b3, +b4, +b5, +b6, +b7}:
          words16(a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7)

# The package returns exactly the eight-word balanced array built by its
# `buffer.digest`, so this match is the shape of every successful result; the
# other shapes are unreachable and are consumed rather than trusted.
def fold_array(a: Array<U32>) -> U32:
  match a:
    case ALeaf{+x}: x
    case ANode{xs, ys}: (fold_array(xs) .^. fold_array(ys) : U32)

def zero_after(+x: U32) -> Digest: D{0, 0, 0, 0, 0, 0, 0, 0}

def drop_array(a: Array<U32>) -> Digest: zero_after(fold_array(a))

def of_array(a: Array<U32>) -> Digest:
  match a:
    case ANode{ANode{ANode{ALeaf{+w0}, ALeaf{+w1}}, ANode{ALeaf{+w2}, ALeaf{+w3}}},
               ANode{ANode{ALeaf{+w4}, ALeaf{+w5}}, ANode{ALeaf{+w6}, ALeaf{+w7}}}}:
      D{w0, w1, w2, w3, w4, w5, w6, w7}
    case _: drop_array(a)

def of_result(r: Maybe<&1, Array<U32>>) -> Digest:
  match r:
    case None{}: D{0, 0, 0, 0, 0, 0, 0, 0}
    case Some{a}: of_array(a)

# One Merkle node: SHA-256 of the two chunks concatenated, 64 bytes in,
# 32 bytes out, no intermediate list anywhere.
def hash_pair(l: Digest, r: Digest) -> Digest:
  of_result(PKG.sha256(pair_words(l, r), 64n))

def zero() -> Digest: D{0, 0, 0, 0, 0, 0, 0, 0}

# ---------------------------------------------------------------------------
# Specification-facing views. These are used by proofs and by test oracles,
# never by the measured runtime path.
def be_bytes(+x: U32, tail: +List<U32>) -> +List<U32>:
  (U32.shrn(x, 24n) .&. 255 : U32) <> ((U32.shrn(x, 16n) .&. 255 : U32) <> ((U32.shrn(x, 8n) .&. 255 : U32) <> ((x .&. 255 : U32) <> tail)))

def bytes_onto(d: Digest, tail: +List<U32>) -> +List<U32>:
  match d:
    case D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      be_bytes(w0, be_bytes(w1, be_bytes(w2, be_bytes(w3, be_bytes(w4, be_bytes(w5, be_bytes(w6, be_bytes(w7, tail))))))))

def bytes(d: Digest) -> +List<U32>: bytes_onto(d, [])

def equal(a: Digest, b: Digest) -> Bool:
  match a:
    case D{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7}:
      match b:
        case D{+b0, +b1, +b2, +b3, +b4, +b5, +b6, +b7}:
          Bool.and(U32.is_eq(a0, b0), Bool.and(U32.is_eq(a1, b1), Bool.and(U32.is_eq(a2, b2), Bool.and(U32.is_eq(a3, b3),
            Bool.and(U32.is_eq(a4, b4), Bool.and(U32.is_eq(a5, b5), Bool.and(U32.is_eq(a6, b6), U32.is_eq(a7, b7))))))))
