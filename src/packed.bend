import Base
import ./walk.bend as W
import ./primitives.bend as P
import ../types/primitive.bend as Primitive

# Packed byte storage for the native runtime.
#
# A byte string is held as 32-byte chunks of eight little-endian words plus an
# explicit byte length; the final chunk is zero padded past the length. On the
# native C backend a Chunk is a flat eight-word record, so 32 bytes of payload
# cost one heap node instead of the 32 linked cells that `+List<U32>` needs.
# The chunk width is the SSZ chunk width, so packing is also what
# merkleization consumes.
#
# `Packed.bytes` is the logical view: the byte list this storage denotes. Every
# implementation law about packed storage is stated through that view, never by
# assuming a particular chunk arrangement.
type Chunk is Data:
  Chunk{w0: U32, w1: U32, w2: U32, w3: U32, w4: U32, w5: U32, w6: U32, w7: U32}

type Packed is Data:
  Packed{length: Nat, chunks: +List<Chunk>}

def byte0(+w: U32) -> U32: U32.and(w, 255)
def byte1(+w: U32) -> U32: U32.and(U32.shrn(w, 8n), 255)
def byte2(+w: U32) -> U32: U32.and(U32.shrn(w, 16n), 255)
def byte3(+w: U32) -> U32: U32.shrn(w, 24n)

def word_bytes(+w: U32, tail: +List<U32>) -> +List<U32>:
  byte0(w) <> (byte1(w) <> (byte2(w) <> (byte3(w) <> tail)))

def chunk_bytes(c: Chunk, tail: +List<U32>) -> +List<U32>:
  match c:
    case Chunk{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      word_bytes(w0, word_bytes(w1, word_bytes(w2, word_bytes(w3, word_bytes(w4, word_bytes(w5, word_bytes(w6, word_bytes(w7, tail))))))))

def chunks_bytes(cs: +List<Chunk>) -> +List<U32>:
  match cs:
    case Nil{}: []
    case Con{c, t}: chunk_bytes(c, chunks_bytes(t))

# The logical byte list denoted by packed storage.
def bytes(p: Packed) -> +List<U32>:
  match p:
    case Packed{+n, chunks}: List.take(&2, U32, chunks_bytes(chunks), n)

def size(p: Packed) -> Nat:
  match p:
    case Packed{n, chunks}: n

# ---------------------------------------------------------------------------
# Reading packed storage from a byte cursor.
def limb(+a: U32, +b: U32, +c: U32, +d: U32) -> U32:
  U32.or(a, U32.or(U32.shln(b, 8n), U32.or(U32.shln(c, 16n), U32.shln(d, 24n))))

type Read is Data:
  Read{chunk: Chunk, rest: +List<U32>}
  Short{}

# Exactly 32 bytes at the cursor.
def read_chunk(xs: +List<U32>) -> Read:
  match xs:
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Con{b31, t}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      Read{Chunk{limb(b0, b1, b2, b3), limb(b4, b5, b6, b7), limb(b8, b9, b10, b11), limb(b12, b13, b14, b15), limb(b16, b17, b18, b19), limb(b20, b21, b22, b23), limb(b24, b25, b26, b27), limb(b28, b29, b30, b31)}, t}
    case _: Short{}

# Up to 32 remaining bytes, zero padded to a full chunk. The padded copy is a
# bounded temporary: at most one chunk.
def chunk_of(r: Read) -> Chunk:
  match r:
    case Read{c, rest}: c
    case Short{}: Chunk{0, 0, 0, 0, 0, 0, 0, 0}

def read_tail(+n: Nat, +xs: +List<U32>) -> Chunk:
  chunk_of(read_chunk(P.pad(32n, W.copy(True{}, n, xs))))

# ---------------------------------------------------------------------------
# Packing a region: `n` bytes at the cursor become chunk storage.
#
# The region is first extended to a chunk boundary (`P.pad` truncates or zero
# fills), then one pass consumes exactly 32 bytes per step and emits the chunk
# they denote. No accumulator, reversal or second walk is allocated, and the
# padded copy is released as the chunks are built.
def pack_chunks(+k: Nat, +ys: +List<U32>) -> +List<Chunk>:
  match k:
    case 0n: []
    case 1n+p:
      match ys:
        case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Con{b31, t}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
          Chunk{limb(b0, b1, b2, b3), limb(b4, b5, b6, b7), limb(b8, b9, b10, b11), limb(b12, b13, b14, b15), limb(b16, b17, b18, b19), limb(b20, b21, b22, b23), limb(b24, b25, b26, b27), limb(b28, b29, b30, b31)} <> pack_chunks(p, t)
        case _: []

# Pack exactly n bytes at the cursor.
def chunk_count(+n: Nat) -> Nat: Nat.div(Nat.add(n, 31n), 32n)

def pack(+n: Nat, +xs: +List<U32>) -> Packed:
  Packed{n, pack_chunks(chunk_count(n), P.pad(Nat.mul(32n, chunk_count(n)), xs))}


# ---------------------------------------------------------------------------
# Byte slices over packed storage.
#
# A slice denotes `size` bytes starting `start` bytes into the chunk stream.
# Sub-slicing shares the chunks, so decoding a field copies nothing: the
# decoded value points into the same storage as the input. `slice_bytes` is
# the logical view every law is stated against.
type Slice is Data:
  Slice{chunks: +List<Chunk>, start: Nat, size: Nat}

def slice_bytes(s: Slice) -> +List<U32>:
  match s:
    case Slice{chunks, at, n}: List.take(&2, U32, List.drop(&2, U32, chunks_bytes(chunks), at), n)

def slice_size(s: Slice) -> Nat:
  match s:
    case Slice{chunks, at, n}: n

def whole(p: Packed) -> Slice:
  match p:
    case Packed{n, chunks}: Slice{chunks, 0n, n}

# Drop whole chunks while the offset allows it, so `start` stays below 32 and
# sequential reading is constant time per byte.
# `start` is reduced below the chunk width by dropping whole chunks, so
# sequential reads stay constant time per byte.
def normalize(chunks: +List<Chunk>, +start: Nat, +size: Nat) -> Slice:
  match chunks:
    case Nil{}: Slice{[], start, size}
    case Con{c, t}:
      match start:
        case 32n+rest: normalize(t, rest, size)
        case _: Slice{c <> t, start, size}

# The first `n` bytes of a slice, sharing storage.
def sub(s: Slice, +n: Nat) -> Slice:
  match s:
    case Slice{chunks, at, +len}: Slice{chunks, at, Nat.min(n, len)}

# The slice after its first `n` bytes.
def adv(s: Slice, +n: Nat) -> Slice:
  match s:
    case Slice{chunks, +at, +len}: normalize(chunks, Nat.add(at, n), Nat.sub(len, n))

# ---------------------------------------------------------------------------
# Reading bytes out of a slice. Positions are relative to the slice start; a
# position at or past the end reads zero, and callers check sizes first.
def word_at(c: Chunk, +i: Nat) -> U32:
  match c:
    case Chunk{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      match i:
        case 0n: w0
        case 1n: w1
        case 2n: w2
        case 3n: w3
        case 4n: w4
        case 5n: w5
        case 6n: w6
        case 7n: w7
        case _: 0

def byte_in_word(+w: U32, +j: Nat) -> U32:
  match j:
    case 0n: byte0(w)
    case 1n: byte1(w)
    case 2n: byte2(w)
    case _: byte3(w)

def chunk_byte(c: Chunk, +i: Nat) -> U32:
  byte_in_word(word_at(c, Nat.div(i, 4n)), Nat.mod(i, 4n))

def head_byte(chunks: +List<Chunk>, +i: Nat) -> U32:
  match chunks:
    case Nil{}: 0
    case Con{c, t}: chunk_byte(c, i)

# Byte `i` of the slice.
def positioned(s: Slice) -> U32:
  match s:
    case Slice{chunks, at, n}: head_byte(chunks, at)

def slice_byte(in_range: Bool, chunks: +List<Chunk>, +at: Nat, +size: Nat) -> U32:
  match in_range:
    case False{}: 0
    case True{}: positioned(normalize(chunks, at, size))

def byte_at(+s: Slice, +i: Nat) -> U32:
  match s:
    case Slice{chunks, +at, +len}: slice_byte(Nat.is_lt(i, len), chunks, Nat.add(at, i), len)

# Little-endian reads at the slice start.
def u32_at(+s: Slice, +i: Nat) -> U32:
  limb(byte_at(s, i), byte_at(s, 1n+i), byte_at(s, 2n+i), byte_at(s, 3n+i))

def offset_at(+s: Slice) -> Nat:
  U32.to_nat(u32_at(s, 0n))

# The byte list denoted by a slice, materialised: the neutral-value view and
# the bitfield leaf codecs need an ordinary list of bytes.
#
# The cursor advances, so reading is linear (`byte_at` is only constant time
# near the slice start), and the bytes are collected onto an accumulator
# rather than in front of a pending recursive call: materialising a payload
# must not hold one suspended call per byte, which the JavaScript backend
# cannot do for a large payload. `rev_append` puts them back in order, also
# without holding anything per element.
def rev_append(xs: +List<U32>, acc: +List<U32>) -> +List<U32>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: rev_append(t, h <> acc)

def to_list_go(+n: Nat, +s: Slice, acc: +List<U32>) -> +List<U32>:
  match n:
    case 0n: acc
    case 1n+p: to_list_go(p, adv(s, 1n), byte_at(s, 0n) <> acc)

def to_list(+s: Slice) -> +List<U32>:
  rev_append(to_list_go(slice_size(s), s, []), [])

# Unsigned integers: `width` little-endian bytes at the slice start.
def uint_word(+s: Slice, +i: Nat) -> U32:
  limb(byte_at(s, i), byte_at(s, 1n+i), byte_at(s, 2n+i), byte_at(s, 3n+i))

def uint_word_guard(+s: Slice, +i: Nat, +width: Nat) -> U32:
  uint_word(sub(s, width), i)

def uint_of(+s: Slice, +width: Nat) -> Primitive.UInt:
  Primitive.UInt{
    uint_word_guard(s, 0n, width), uint_word_guard(s, 4n, width), uint_word_guard(s, 8n, width), uint_word_guard(s, 12n, width),
    uint_word_guard(s, 16n, width), uint_word_guard(s, 20n, width), uint_word_guard(s, 24n, width), uint_word_guard(s, 28n, width)}


def chunks_of(p: Packed) -> +List<Chunk>:
  match p:
    case Packed{n, chunks}: chunks

# ---------------------------------------------------------------------------
# One pass over the input: chunk storage, the byte count and the byte-domain
# check are produced together, so the decoder never walks the input twice.
type Packing is Data:
  Packing{length: Nat, domain: Bool, chunks: +List<Chunk>}

def small_length(+xs: +List<U32>) -> Nat:
  match xs:
    case Nil{}: 0n
    case Con{hd, tl}: 1n+small_length(tl)

def small_domain(+xs: +List<U32>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{hd, tl}: Bool.and(U32.is_lt(hd, 256), small_domain(tl))

def tail_packing(+ys: +List<U32>) -> Packing:
  match ys:
    case Nil{}: Packing{0n, True{}, []}
    case Con{hd, tl}: Packing{small_length(ys), small_domain(ys), [chunk_of(read_chunk(P.pad(32n, ys)))]}

def pack_step(+b0: U32, +b1: U32, +b2: U32, +b3: U32, +b4: U32, +b5: U32, +b6: U32, +b7: U32, +b8: U32, +b9: U32, +b10: U32, +b11: U32, +b12: U32, +b13: U32, +b14: U32, +b15: U32, +b16: U32, +b17: U32, +b18: U32, +b19: U32, +b20: U32, +b21: U32, +b22: U32, +b23: U32, +b24: U32, +b25: U32, +b26: U32, +b27: U32, +b28: U32, +b29: U32, +b30: U32, +b31: U32, rest: Packing) -> Packing:
  match rest:
    case Packing{+rest_length, +rest_domain, rest_chunks}:
      Packing{Nat.add(32n, rest_length), Bool.and(U32.is_lt(b0, 256), Bool.and(U32.is_lt(b1, 256), Bool.and(U32.is_lt(b2, 256), Bool.and(U32.is_lt(b3, 256), Bool.and(U32.is_lt(b4, 256), Bool.and(U32.is_lt(b5, 256), Bool.and(U32.is_lt(b6, 256), Bool.and(U32.is_lt(b7, 256), Bool.and(U32.is_lt(b8, 256), Bool.and(U32.is_lt(b9, 256), Bool.and(U32.is_lt(b10, 256), Bool.and(U32.is_lt(b11, 256), Bool.and(U32.is_lt(b12, 256), Bool.and(U32.is_lt(b13, 256), Bool.and(U32.is_lt(b14, 256), Bool.and(U32.is_lt(b15, 256), Bool.and(U32.is_lt(b16, 256), Bool.and(U32.is_lt(b17, 256), Bool.and(U32.is_lt(b18, 256), Bool.and(U32.is_lt(b19, 256), Bool.and(U32.is_lt(b20, 256), Bool.and(U32.is_lt(b21, 256), Bool.and(U32.is_lt(b22, 256), Bool.and(U32.is_lt(b23, 256), Bool.and(U32.is_lt(b24, 256), Bool.and(U32.is_lt(b25, 256), Bool.and(U32.is_lt(b26, 256), Bool.and(U32.is_lt(b27, 256), Bool.and(U32.is_lt(b28, 256), Bool.and(U32.is_lt(b29, 256), Bool.and(U32.is_lt(b30, 256), Bool.and(U32.is_lt(b31, 256), rest_domain)))))))))))))))))))))))))))))))), Chunk{limb(b0, b1, b2, b3), limb(b4, b5, b6, b7), limb(b8, b9, b10, b11), limb(b12, b13, b14, b15), limb(b16, b17, b18, b19), limb(b20, b21, b22, b23), limb(b24, b25, b26, b27), limb(b28, b29, b30, b31)} <> rest_chunks}

# The packing specification, one chunk per 32 input bytes in order. This is
# the definition every packing law is stated about; `pack_list` below computes
# exactly it (proofs/packed_pack_acc.bend) without holding one suspended call
# per chunk, which a 2.7 MB input would otherwise need.
def pack_spec_go(+xs: +List<U32>, +ys: +List<U32>) -> Packing:
  match xs:
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Con{b31, t}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      pack_step(b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, pack_spec_go(t, t))
    case _: tail_packing(ys)

# Chunks accumulated newest-first, put back in order in one pass.
def chunk_rev_append(acc: +List<Chunk>, tail: +List<Chunk>) -> +List<Chunk>:
  match acc:
    case Nil{}: tail
    case Con{c, t}: chunk_rev_append(t, c <> tail)

# Close an accumulated packing: `n` bytes and `ok` are what the accumulated
# chunks contribute, `rest` is the packing of the final partial chunk.
def pack_close(+n: Nat, +ok: Bool, acc: +List<Chunk>, rest: Packing) -> Packing:
  match rest:
    case Packing{+rest_length, +rest_domain, rest_chunks}:
      Packing{Nat.add(n, rest_length), Bool.and(ok, rest_domain), chunk_rev_append(acc, rest_chunks)}

def pack_list_go(+xs: +List<U32>, +ys: +List<U32>, +n: Nat, +ok: Bool, acc: +List<Chunk>) -> Packing:
  match xs:
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Con{b31, t}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      pack_list_go(t, t, Nat.add(32n, n), Bool.and(ok, Bool.and(U32.is_lt(b0, 256), Bool.and(U32.is_lt(b1, 256), Bool.and(U32.is_lt(b2, 256), Bool.and(U32.is_lt(b3, 256), Bool.and(U32.is_lt(b4, 256), Bool.and(U32.is_lt(b5, 256), Bool.and(U32.is_lt(b6, 256), Bool.and(U32.is_lt(b7, 256), Bool.and(U32.is_lt(b8, 256), Bool.and(U32.is_lt(b9, 256), Bool.and(U32.is_lt(b10, 256), Bool.and(U32.is_lt(b11, 256), Bool.and(U32.is_lt(b12, 256), Bool.and(U32.is_lt(b13, 256), Bool.and(U32.is_lt(b14, 256), Bool.and(U32.is_lt(b15, 256), Bool.and(U32.is_lt(b16, 256), Bool.and(U32.is_lt(b17, 256), Bool.and(U32.is_lt(b18, 256), Bool.and(U32.is_lt(b19, 256), Bool.and(U32.is_lt(b20, 256), Bool.and(U32.is_lt(b21, 256), Bool.and(U32.is_lt(b22, 256), Bool.and(U32.is_lt(b23, 256), Bool.and(U32.is_lt(b24, 256), Bool.and(U32.is_lt(b25, 256), Bool.and(U32.is_lt(b26, 256), Bool.and(U32.is_lt(b27, 256), Bool.and(U32.is_lt(b28, 256), Bool.and(U32.is_lt(b29, 256), Bool.and(U32.is_lt(b30, 256), U32.is_lt(b31, 256))))))))))))))))))))))))))))))))), Chunk{limb(b0, b1, b2, b3), limb(b4, b5, b6, b7), limb(b8, b9, b10, b11), limb(b12, b13, b14, b15), limb(b16, b17, b18, b19), limb(b20, b21, b22, b23), limb(b24, b25, b26, b27), limb(b28, b29, b30, b31)} <> acc)
    case _: pack_close(n, ok, acc, tail_packing(ys))

# The whole input as packed storage, with its length and byte-domain check.
def pack_spec(+xs: +List<U32>) -> Packing:
  pack_spec_go(xs, xs)

def pack_list(+xs: +List<U32>) -> Packing:
  pack_list_go(xs, xs, 0n, True{}, [])

def packing_slice(p: Packing) -> Slice:
  match p:
    case Packing{+n, domain, chunks}: Slice{chunks, 0n, n}

def packing_length(p: Packing) -> Nat:
  match p:
    case Packing{n, domain, chunks}: n

def packing_domain(p: Packing) -> Bool:
  match p:
    case Packing{n, domain, chunks}: domain

def packing_chunks(p: Packing) -> +List<Chunk>:
  match p:
    case Packing{n, domain, chunks}: chunks
