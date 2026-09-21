import Base
import ./digest.bend as D

# Indexed byte storage for the SSZ runtime.
#
# A `Buf` is one packed `Array<U32>` holding four bytes per word in
# little-endian order, plus the logical byte length. There is no chunk list, no
# cons cell per byte and no pointer chasing: byte j lives in word j >> 2 at bit
# (j & 3) * 8, so every read is an index computation followed by one array
# read. Little-endian packing is chosen because SSZ integers and offsets are
# little-endian, so an aligned four-byte read is the word itself.
#
# `Array<U32>` has kind `Type`, so a `Buf` cannot be duplicated: every reader
# takes the buffer and gives it back. That is the input-ownership contract of
# the primary API - the caller owns the buffer, hands it to an operation, and
# receives it back together with the result. Bend also forbids matching a
# computed value, so each step that consumes an `Array.get` result passes the
# pair into its own definition; that is why the readers are split this way.
type Buf is Type:
  Buf{words: Array<U32>, size: U32}

def size(b: Buf) -> Buf & U32:
  match b:
    case Buf{ws, +n}: (Buf{ws, n}, n)

def rewrap(+n: U32, pair: Array<U32> & U32) -> Buf & U32:
  (ws, w) = pair
  (Buf{ws, n}, w)

# Raw word read by word index. `Array.get` masks out-of-range indices, so every
# public reader below bound-checks before reading.
def word(b: Buf, +i: U32) -> Buf & U32:
  match b:
    case Buf{ws, +n}: rewrap(n, Array.get(U32, ws, i))

# Byte selection inside a word. The shift amount is one of four constants, so
# it is a four-way match rather than a variable shift (Base only shifts by a
# literal Nat).
def byte_sel(+j: U32, +w: U32) -> U32:
  match j:
    case 0: (w .&. 255 : U32)
    case 1: (U32.shrn(w, 8n) .&. 255 : U32)
    case 2: (U32.shrn(w, 16n) .&. 255 : U32)
    case _: U32.shrn(w, 24n)

def byte_pick(+j: U32, pair: Buf & U32) -> Buf & U32:
  (b, w) = pair
  (b, byte_sel(j, w))

# Byte at a logical offset.
def byte_at(b: Buf, +i: U32) -> Buf & U32:
  byte_pick((i .&. 3 : U32), word(b, U32.shrn(i, 2n)))

# Four little-endian bytes at a logical offset: a uint32, or an SSZ offset.
# Aligned offsets are a single word read, because the packing is little-endian;
# the three unaligned cases join the low bits of one word with the high bits of
# the next.
def join_sel(+j: U32, +lo: U32, +hi: U32) -> U32:
  match j:
    case 1: (U32.shrn(lo, 8n) .|. U32.shln(hi, 24n) : U32)
    case 2: (U32.shrn(lo, 16n) .|. U32.shln(hi, 16n) : U32)
    case _: (U32.shrn(lo, 24n) .|. U32.shln(hi, 8n) : U32)

def join_words(+j: U32, +lo: U32, pair: Buf & U32) -> Buf & U32:
  (b, hi) = pair
  (b, join_sel(j, lo, hi))

def read32_split(+i: U32, +j: U32, pair: Buf & U32) -> Buf & U32:
  (b, lo) = pair
  join_words(j, lo, word(b, (U32.shrn(i, 2n) + 1 : U32)))

def read32_choose(+i: U32, +j: U32, aligned: Bool, b: Buf) -> Buf & U32:
  match aligned:
    case True{}: word(b, U32.shrn(i, 2n))
    case False{}: read32_split(i, j, word(b, U32.shrn(i, 2n)))

def read32(b: Buf, +i: U32) -> Buf & U32:
  read32_choose(i, (i .&. 3 : U32), U32.is_eq((i .&. 3 : U32), 0), b)

# Eight little-endian bytes as a (low, high) word pair, i.e. a uint64.
def read64_hi(+lo: U32, pair: Buf & U32) -> Buf & (U32 & U32):
  (b, hi) = pair
  (b, (lo, hi))

def read64_lo(+i: U32, pair: Buf & U32) -> Buf & (U32 & U32):
  (b, lo) = pair
  read64_hi(lo, read32(b, (i + 4 : U32)))

def read64(b: Buf, +i: U32) -> Buf & (U32 & U32):
  read64_lo(i, read32(b, i))

# Big-endian word at a four-byte offset, which is what a SHA-256 message block
# needs; the storage is little-endian, so this is a byte swap.
def swap32(+w: U32) -> U32:
  (U32.shln((w .&. 255 : U32), 24n) .|. U32.shln((U32.shrn(w, 8n) .&. 255 : U32), 16n)
    .|. U32.shln((U32.shrn(w, 16n) .&. 255 : U32), 8n) .|. U32.shrn(w, 24n) : U32)

def swap_pair(pair: Buf & U32) -> Buf & U32:
  (b, w) = pair
  (b, swap32(w))

def be_word_at(b: Buf, +i: U32) -> Buf & U32:
  swap_pair(read32(b, i))

# ---------------------------------------------------------------------------
# Construction. Building a buffer from a byte list is a transport-boundary
# operation: files and official test vectors arrive as lists through Base.
# It is reported separately from decoding and is never inside a measured
# decode window.
def word_of(+a: U32, +b: U32, +c: U32, +d: U32) -> U32:
  ((a .&. 255 : U32) .|. U32.shln((b .&. 255 : U32), 8n)
    .|. U32.shln((c .&. 255 : U32), 16n) .|. U32.shln((d .&. 255 : U32), 24n) : U32)

# Four input bytes and one array write per step. The list argument comes first
# because it is the argument that shrinks.
def fill_go(xs: +List<U32>, ws: Array<U32>, +i: U32) -> Array<U32>:
  match xs:
    case Con{a, Con{b, Con{c, Con{d, rest}}}}:
      fill_go(rest, Array.set(U32, ws, i, word_of(a, b, c, d)), (i + 1 : U32))
    case Con{a, Con{b, Con{c, Nil{}}}}: Array.set(U32, ws, i, word_of(a, b, c, 0))
    case Con{a, Con{b, Nil{}}}: Array.set(U32, ws, i, word_of(a, b, 0, 0))
    case Con{a, Nil{}}: Array.set(U32, ws, i, word_of(a, 0, 0, 0))
    case Nil{}: ws

# Smallest power-of-two word count that holds `need` words, as the depth
# `Array.new` expects: halve until one slot is left. The fuel argument is what
# makes the loop structurally terminating; thirty-two halvings cover every U32.
def capacity_go(+fuel: Nat, +need: U32, +depth: Nat) -> Nat:
  match fuel:
    case 0n: depth
    case 1n+p:
      match need:
        case 0: depth
        case 1: depth
        case _: capacity_go(p, U32.shrn((need + 1 : U32), 1n), 1n+depth)

def capacity(+n: U32) -> Nat:
  capacity_go(32n, U32.shrn((n + 3 : U32), 2n), 0n)

# ---------------------------------------------------------------------------
# Merkle scratch. A buffer being hashed carries 1024 digest slots of eight
# words right after its data, at word (n + 3) / 4: the level stack of the
# streaming merkleizer (64-slot segments, one per nesting level) and, in slots
# 960..1023, the zero-subtree roots. So the only mutable state of a hash is the
# caller's own packed array: no second structure, no sharing, O(1) word access.
def scratch_words() -> U32: 8192

def scratch_base(+n: U32) -> U32: U32.shrn((n + 3 : U32), 2n)

# Capacity for `n` data bytes plus the scratch.
def capacity_hashable(+n: U32) -> Nat:
  capacity_go(32n, (U32.shrn((n + 3 : U32), 2n) + 8192 : U32), 0n)

def dg7(+n: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32,
        pair: Array<U32> & U32) -> Buf & D.Digest:
  (ws, +a7) = pair
  (Buf{ws, n}, D.D{a0, a1, a2, a3, a4, a5, a6, a7})

def dg6(+n: U32, +w: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32,
        pair: Array<U32> & U32) -> Buf & D.Digest:
  (ws, +a6) = pair
  dg7(n, a0, a1, a2, a3, a4, a5, a6, Array.get(U32, ws, (w + 7 : U32)))

def dg5(+n: U32, +w: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, pair: Array<U32> & U32) -> Buf & D.Digest:
  (ws, +a5) = pair
  dg6(n, w, a0, a1, a2, a3, a4, a5, Array.get(U32, ws, (w + 6 : U32)))

def dg4(+n: U32, +w: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, pair: Array<U32> & U32) -> Buf & D.Digest:
  (ws, +a4) = pair
  dg5(n, w, a0, a1, a2, a3, a4, Array.get(U32, ws, (w + 5 : U32)))

def dg3(+n: U32, +w: U32, +a0: U32, +a1: U32, +a2: U32, pair: Array<U32> & U32) -> Buf & D.Digest:
  (ws, +a3) = pair
  dg4(n, w, a0, a1, a2, a3, Array.get(U32, ws, (w + 4 : U32)))

def dg2(+n: U32, +w: U32, +a0: U32, +a1: U32, pair: Array<U32> & U32) -> Buf & D.Digest:
  (ws, +a2) = pair
  dg3(n, w, a0, a1, a2, Array.get(U32, ws, (w + 3 : U32)))

def dg1(+n: U32, +w: U32, +a0: U32, pair: Array<U32> & U32) -> Buf & D.Digest:
  (ws, +a1) = pair
  dg2(n, w, a0, a1, Array.get(U32, ws, (w + 2 : U32)))

def dg0(+n: U32, +w: U32, pair: Array<U32> & U32) -> Buf & D.Digest:
  (ws, +a0) = pair
  dg1(n, w, a0, Array.get(U32, ws, (w + 1 : U32)))

# Scratch slot `s` as a digest: eight word reads. The accessors are
# recursive in form (`guard` is always 0n) so that the backend does not inline
# them into every caller: inlined, they pushed programs over the compile cap.
def get_digest_go(+guard: Nat, b: Buf, +s: U32) -> Buf & D.Digest:
  match guard:
    case 0n:
      match b:
        case Buf{ws, +n}:
          dg0(n, (scratch_base(n) + 8 * s : U32), Array.get(U32, ws, (scratch_base(n) + 8 * s : U32)))
    case 1n+p: get_digest_go(p, b, s)

def get_digest(b: Buf, +s: U32) -> Buf & D.Digest: get_digest_go(0n, b, s)

def set_digest_go(+guard: Nat, b: Buf, +s: U32, d: D.Digest) -> Buf:
  match guard:
    case 1n+p: set_digest_go(p, b, s, d)
    case 0n:
      match b:
        case Buf{ws, +n}:
          match d:
            case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
              Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32,
                   Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, ws,
                     (scratch_base(n) + 8 * s : U32), w0), (scratch_base(n) + 8 * s + 1 : U32), w1),
                     (scratch_base(n) + 8 * s + 2 : U32), w2), (scratch_base(n) + 8 * s + 3 : U32), w3),
                     (scratch_base(n) + 8 * s + 4 : U32), w4), (scratch_base(n) + 8 * s + 5 : U32), w5),
                     (scratch_base(n) + 8 * s + 6 : U32), w6), (scratch_base(n) + 8 * s + 7 : U32), w7), n}

# Write a digest into scratch slot `s`: eight word writes.
def set_digest(b: Buf, +s: U32, d: D.Digest) -> Buf: set_digest_go(0n, b, s, d)

# A buffer whose array cannot hold the scratch (an encode output, say) is
# copied once into one that can, the first time it is hashed.
def copy_words(+k: Nat, +i: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  match k pair:
    case 0n Tuple{src, w}: (src, out)
    case 1n+p Tuple{src, +w}:
      copy_words(p, (i + 1 : U32), Array.set(U32, out, i, w), Array.get(U32, src, (i + 1 : U32)))

def regrown(+n: U32, pair: Array<U32> & Array<U32>) -> Buf:
  (src, out) = pair
  Buf{out, n}

def grow_pick(+roomy: Bool, +n: U32, ws: Array<U32>) -> Buf:
  match roomy:
    case True{}: Buf{ws, n}
    case False{}:
      regrown(n, copy_words(U32.to_nat(scratch_base(n)), 0, Array.new(U32, capacity_hashable(n), 0),
        Array.get(U32, ws, 0)))

def grow_sized(+n: U32, pair: Array<U32> & U32) -> Buf:
  (ws, +cap) = pair
  grow_pick(U32.is_le((scratch_base(n) + 8192 : U32), cap), n, ws)

def with_scratch(b: Buf) -> Buf:
  match b:
    case Buf{ws, +n}: grow_sized(n, Array.size(U32, ws))

def of_list(+n: U32, xs: +List<U32>) -> Buf:
  Buf{fill_go(xs, Array.new(U32, capacity(n), 0), 0), n}

def empty() -> Buf: Buf{Array.new(U32, 0n, 0), 0}

# Allocate a buffer of `n` bytes with all words zero; pieces are then written
# in with `fill_at`, so a large input never exists as a byte list in full.
# Input buffers get their natural power-of-two capacity. When its slack holds
# the Merkle scratch (a 2.74 MB BeaconState sits in a 4 MiB block) hashing
# needs nothing more; a small buffer is grown once, by `with_scratch`, the
# first time it is hashed, and the grown buffer is what the caller gets back.
# Reserving the scratch up front made every small encode copy 32 KiB.
def alloc(+n: U32) -> Buf: Buf{Array.new(U32, capacity(n), 0), n}

def fill_at(b: Buf, +byte_off: U32, xs: +List<U32>) -> Buf:
  match b:
    case Buf{ws, +n}: Buf{fill_go(xs, ws, U32.shrn(byte_off, 2n)), n}

# ---------------------------------------------------------------------------
# Views used by proofs, transports and test oracles only, never on a measured
# runtime path. The pending read is threaded as the last argument so that the
# loop stays a single self-recursive definition.
def to_list_go(+k: Nat, +i: U32, acc: +List<U32>, pair: Buf & U32) -> Buf & +List<U32>:
  match k pair:
    case 0n Tuple{b, v}: (b, acc)
    case 1n+p Tuple{b, v}: to_list_go(p, (i - 1 : U32), v <> acc, byte_at(b, (i - 1 : U32)))

def to_list_at(pair: Buf & U32) -> Buf & +List<U32>:
  (b, +n) = pair
  to_list_go(U32.to_nat(n), n, [], byte_at(b, 0))

def to_list(b: Buf) -> Buf & +List<U32>:
  to_list_at(size(b))

# Consumes a buffer, folding every word so nothing is left unforced.
def fold(a: Array<U32>) -> U32:
  match a:
    case ALeaf{+x}: x
    case ANode{xs, ys}: (fold(xs) .^. fold(ys) : U32)

def drop(b: Buf) -> U32:
  match b:
    case Buf{ws, +n}: fold(ws)

# ---------------------------------------------------------------------------
# Output. Base writes files from a byte list only, so bytes leave a buffer one
# piece at a time: `emit` lists the bytes of words [w, w + k) and the caller
# writes that piece before asking for the next, so only one piece's list exists
# at a time. The words are read by index. Matching `ANode` would not do: the
# native runtime copies both halves of a block on every such match (see the
# block-layer comment in the emitted C), while `Array.get` opens no half.

def pick(c: Bool, +x: U32, +y: U32) -> U32:
  match c:
    case True{}: x
    case False{}: y

# How many bytes of word `i` lie below the logical end `n`: four, fewer for
# the final partial word, none for padding words past the end.
def bytes_in(+i: U32, +n: U32) -> U32:
  pick(U32.is_le(n, (4 * i : U32)), 0,
    pick(U32.is_le(((4 * i : U32) + 4 : U32), n), 4, (n - (4 * i : U32) : U32)))

def prepend_word(+k: U32, +w: U32, acc: +List<U32>) -> +List<U32>:
  match k:
    case 0: acc
    case 1: byte_sel(0, w) <> acc
    case 2: byte_sel(0, w) <> byte_sel(1, w) <> acc
    case 3: byte_sel(0, w) <> byte_sel(1, w) <> byte_sel(2, w) <> acc
    case _: byte_sel(0, w) <> byte_sel(1, w) <> byte_sel(2, w) <> byte_sel(3, w) <> acc

# Back to front, so the list is built without reversal: `pair` holds word `i`,
# the next one to prepend. The read after the last step is of word w - 1, which
# `Array.get` masks into range and whose value is discarded.
def emit_go(+k: Nat, +i: U32, +n: U32, acc: +List<U32>, pair: Buf & U32) -> Buf & +List<U32>:
  match k pair:
    case 0n Tuple{b, w}: (b, acc)
    case 1n+p Tuple{b, +w}:
      emit_go(p, (i - 1 : U32), n, prepend_word(bytes_in(i, n), w, acc), word(b, (i - 1 : U32)))

# The bytes of words [w, w + k), cut at the logical length.
def emit(b: Buf, +w: U32, +k: U32) -> Buf & +List<U32>:
  match b:
    case Buf{ws, +n}:
      emit_go(U32.to_nat(k), ((w + k : U32) - 1 : U32), n, [], word(Buf{ws, n}, ((w + k : U32) - 1 : U32)))
