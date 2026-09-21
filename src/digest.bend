import Base
import 0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend as PKG

# A 32-byte SSZ chunk held as eight big-endian words instead of thirty-two
# list cells, and the single hashing primitive SSZ merkleization needs.
#
# Hashing goes through the pinned BendHub package
# `0xda83506fb9f059ead7afcfa2f498df5f` (Giulio2002/bend-sha256), whose sole
# production entry point takes a packed `Array<U32>` and a byte length and
# returns eight packed words. Nothing on this path builds, walks or consumes a
# linked list: the sixteen input words are written into a sixteen-slot array
# by index and the eight result words are read out of the array the package
# returns by index.
#
# `bytes` is the byte-list *view* of a chunk. It exists for the specifications
# and their proofs only; no runtime path calls it.
type Digest is Data:
  D{w0: U32, w1: U32, w2: U32, w3: U32, w4: U32, w5: U32, w6: U32, w7: U32}

# The message array for one Merkle node: left chunk then right chunk, four
# big-endian bytes per word, sixteen words = the 64-byte message. It is built
# by `Array.new` and sixteen `Array.set`s and the result is read back by eight
# `Array.get`s. Building it from nested `ANode` constructors, or reading the
# result by matching its `ANode` shape, gives the same words but costs a block
# copy per node on the native runtime; the indexed form is 32 % faster per hash
# (benchmarks/probes/hash_variants.bend: 52 ms against 76 ms for 200,000 chained
# nodes, same final digest).
def set16(a: Array<U32>, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32,
          +b0: U32, +b1: U32, +b2: U32, +b3: U32, +b4: U32, +b5: U32, +b6: U32, +b7: U32) -> Array<U32>:
  Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32,
  Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32,
    a, 0, a0), 1, a1), 2, a2), 3, a3), 4, a4), 5, a5), 6, a6), 7, a7),
    8, b0), 9, b1), 10, b2), 11, b3), 12, b4), 13, b5), 14, b6), 15, b7)

def pair_words(l: Digest, r: Digest) -> Array<U32>:
  match l:
    case D{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7}:
      match r:
        case D{+b0, +b1, +b2, +b3, +b4, +b5, +b6, +b7}:
          set16(Array.new(U32, 4n, 0), a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7)

# The package returns eight words; they are read by index, one definition per
# word because Bend cannot match a computed pair.
def g7(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w7) = pair
  D{w0, w1, w2, w3, w4, w5, w6, w7}

def g6(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w6) = pair
  g7(w0, w1, w2, w3, w4, w5, w6, Array.get(U32, a, 7))

def g5(+w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w5) = pair
  g6(w0, w1, w2, w3, w4, w5, Array.get(U32, a, 6))

def g4(+w0: U32, +w1: U32, +w2: U32, +w3: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w4) = pair
  g5(w0, w1, w2, w3, w4, Array.get(U32, a, 5))

def g3(+w0: U32, +w1: U32, +w2: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w3) = pair
  g4(w0, w1, w2, w3, Array.get(U32, a, 4))

def g2(+w0: U32, +w1: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w2) = pair
  g3(w0, w1, w2, Array.get(U32, a, 3))

def g1(+w0: U32, pair: Array<U32> & U32) -> Digest:
  (a, +w1) = pair
  g2(w0, w1, Array.get(U32, a, 2))

def g0(pair: Array<U32> & U32) -> Digest:
  (a, +w0) = pair
  g1(w0, Array.get(U32, a, 1))

def of_array(a: Array<U32>) -> Digest: g0(Array.get(U32, a, 0))

# `None` is the package's answer for an oversized byte length; a 64-byte
# message never is one.
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
