import Base
import ./buffer.bend as B
import ./digest.bend as D

# Streaming merkleization over indexed storage.
#
# Chunks are read straight out of the packed buffer as eight big-endian words,
# the form the pinned SHA-256 package consumes, so no chunk list, byte list or
# materialised zero padding ever exists. Partial subtrees live in a level stack
# (`DStack`, below): 512 digest slots, each caller using its own 64-slot
# segment, which is more than the deepest SSZ tree. The zero-subtree root for
# each level is carried upward during the final ascent, one hash per level,
# rather than tabulated.
#
# The algorithm is the usual one: push leaf i, combining with the stack while
# bit k of i is set; then ascend from level 0 to the target depth, taking the
# stack entry as the left sibling exactly where bit k of the leaf count is set,
# and the zero-subtree root as the right sibling otherwise.

# Mask keeping the low `k` bytes of a little-endian word, k = 0..4.
def byte_mask(+k: U32) -> U32:
  match k:
    case 0: 0
    case 1: 255
    case 2: 65535
    case 3: 16777215
    case _: 4294967295

# A word of the chunk: bytes [pos, pos+4) of the buffer, zero past `limit`.
def clip_partial(past: Bool, +pos: U32, +limit: U32, +w: U32) -> U32:
  match past:
    case True{}: 0
    case False{}: (w .&. byte_mask((limit - pos : U32)) : U32)

def clip_pick(whole: Bool, past: Bool, +pos: U32, +limit: U32, +w: U32) -> U32:
  match whole:
    case True{}: w
    case False{}: clip_partial(past, pos, limit, w)

def clip_word(+pos: U32, +limit: U32, +w: U32) -> U32:
  clip_pick(U32.is_le((pos + 4 : U32), limit), U32.is_le(limit, pos), pos, limit, w)

# A bit list's terminator bit must be cleared before its bytes are chunked.
# `mpos` is the byte position to mask (0xFFFFFFFF disables it) and `mask` the
# bits to keep there.
def mask_sel(+j: U32, +mask: U32, +w: U32) -> U32:
  match j:
    case 0: ((w .&. 4294967040 : U32) .|. ((w .&. 255 : U32) .&. mask : U32) : U32)
    case 1: ((w .&. 4294902015 : U32) .|. U32.shln(((U32.shrn(w, 8n) .&. 255 : U32) .&. mask : U32), 8n) : U32)
    case 2: ((w .&. 4278255615 : U32) .|. U32.shln(((U32.shrn(w, 16n) .&. 255 : U32) .&. mask : U32), 16n) : U32)
    case _: ((w .&. 16777215 : U32) .|. U32.shln((U32.shrn(w, 24n) .&. mask : U32), 24n) : U32)

def mask_pick(inside: Bool, +pos: U32, +mpos: U32, +mask: U32, +w: U32) -> U32:
  match inside:
    case False{}: w
    case True{}: mask_sel((mpos - pos : U32), mask, w)

def apply_mask(+pos: U32, +mpos: U32, +mask: U32, +w: U32) -> U32:
  mask_pick(Bool.and(U32.is_ge(mpos, pos), U32.is_lt(mpos, (pos + 4 : U32))), pos, mpos, mask, w)

# A general chunk - unaligned, running past the range, or holding a bit list's
# terminator - reads each word with `read32` and clips and masks it, then builds
# the digest record once.
def fix(+pos: U32, +limit: U32, +mpos: U32, +mask: U32, +w: U32) -> U32:
  B.swap32(apply_mask(pos, mpos, mask, clip_word(pos, limit, w)))

def g7(+p: U32, +l: U32, +m: U32, +k: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32,
       pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a7) = pair
  (buf, D.D{a0, a1, a2, a3, a4, a5, a6, fix((p + 28 : U32), l, m, k, a7)})

def g6(+p: U32, +l: U32, +m: U32, +k: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32,
       pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a6) = pair
  g7(p, l, m, k, a0, a1, a2, a3, a4, a5, fix((p + 24 : U32), l, m, k, a6), B.read32(buf, (p + 28 : U32)))

def g5(+p: U32, +l: U32, +m: U32, +k: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32,
       pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a5) = pair
  g6(p, l, m, k, a0, a1, a2, a3, a4, fix((p + 20 : U32), l, m, k, a5), B.read32(buf, (p + 24 : U32)))

def g4(+p: U32, +l: U32, +m: U32, +k: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32,
       pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a4) = pair
  g5(p, l, m, k, a0, a1, a2, a3, fix((p + 16 : U32), l, m, k, a4), B.read32(buf, (p + 20 : U32)))

def g3(+p: U32, +l: U32, +m: U32, +k: U32, +a0: U32, +a1: U32, +a2: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a3) = pair
  g4(p, l, m, k, a0, a1, a2, fix((p + 12 : U32), l, m, k, a3), B.read32(buf, (p + 16 : U32)))

def g2(+p: U32, +l: U32, +m: U32, +k: U32, +a0: U32, +a1: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a2) = pair
  g3(p, l, m, k, a0, a1, fix((p + 8 : U32), l, m, k, a2), B.read32(buf, (p + 12 : U32)))

def g1(+p: U32, +l: U32, +m: U32, +k: U32, +a0: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a1) = pair
  g2(p, l, m, k, a0, fix((p + 4 : U32), l, m, k, a1), B.read32(buf, (p + 8 : U32)))

def g0(+p: U32, +l: U32, +m: U32, +k: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a0) = pair
  g1(p, l, m, k, fix(p, l, m, k, a0), B.read32(buf, (p + 4 : U32)))

# The common chunk - word aligned, wholly inside the range, no bit-list mask in
# it - is eight raw word reads and one digest record, with no clipping, masking
# or per-word record rebuild.
def w7(+a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a7) = pair
  (buf, D.D{B.swap32(a0), B.swap32(a1), B.swap32(a2), B.swap32(a3),
            B.swap32(a4), B.swap32(a5), B.swap32(a6), B.swap32(a7)})

def w6(+i: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a6) = pair
  w7(a0, a1, a2, a3, a4, a5, a6, B.word(buf, (i + 7 : U32)))

def w5(+i: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a5) = pair
  w6(i, a0, a1, a2, a3, a4, a5, B.word(buf, (i + 6 : U32)))

def w4(+i: U32, +a0: U32, +a1: U32, +a2: U32, +a3: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a4) = pair
  w5(i, a0, a1, a2, a3, a4, B.word(buf, (i + 5 : U32)))

def w3(+i: U32, +a0: U32, +a1: U32, +a2: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a3) = pair
  w4(i, a0, a1, a2, a3, B.word(buf, (i + 4 : U32)))

def w2(+i: U32, +a0: U32, +a1: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a2) = pair
  w3(i, a0, a1, a2, B.word(buf, (i + 3 : U32)))

def w1(+i: U32, +a0: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a1) = pair
  w2(i, a0, a1, B.word(buf, (i + 2 : U32)))

def w0(+i: U32, pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +a0) = pair
  w1(i, a0, B.word(buf, (i + 1 : U32)))

def chunk_pick(whole: Bool, buf: B.Buf, +pos: U32, +limit: U32, +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  match whole:
    case True{}: w0(U32.shrn(pos, 2n), B.word(buf, U32.shrn(pos, 2n)))
    case False{}: g0(pos, limit, mpos, mask, B.read32(buf, pos))

def masked_in(+pos: U32, +mpos: U32) -> Bool:
  Bool.and(U32.is_ge(mpos, pos), U32.is_lt(mpos, (pos + 32 : U32)))

# The 32-byte chunk starting at `pos`, zero-padded past `limit`.
def chunk_at(buf: B.Buf, +pos: U32, +limit: U32, +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  chunk_pick(
    Bool.and(U32.is_eq((pos .&. 3 : U32), 0),
      Bool.and(U32.is_le((pos + 32 : U32), limit), Bool.not(masked_in(pos, mpos)))),
    buf, pos, limit, mpos, mask)

# Shift right by a runtime amount, as five conditional constant shifts.
def shr_step(c: Bool, +x: U32, +n: Nat) -> U32:
  match c:
    case True{}: U32.shrn(x, n)
    case False{}: x

def shr_by(+x: U32, +k: U32) -> U32:
  shr_step(U32.is_eq((k .&. 16 : U32), 16),
    shr_step(U32.is_eq((k .&. 8 : U32), 8),
      shr_step(U32.is_eq((k .&. 4 : U32), 4),
        shr_step(U32.is_eq((k .&. 2 : U32), 2),
          shr_step(U32.is_eq((k .&. 1 : U32), 1), x, 1n), 2n), 4n), 8n), 16n)

def bit_in(small: Bool, +x: U32, +k: U32) -> Bool:
  match small:
    case True{}: U32.is_eq((shr_by(x, k) .&. 1 : U32), 1)
    case False{}: False{}

# Bit k of x. `shr_by` only sees the low five bits of k, so positions from 32
# up - reached by the 2^40-limit registry lists - are answered here: a U32 has
# no bits there.
def bit(+x: U32, +k: U32) -> Bool: bit_in(U32.is_lt(k, 32), x, k)

def shl_step(c: Bool, +x: U32, +n: Nat) -> U32:
  match c:
    case True{}: U32.shln(x, n)
    case False{}: x

# Shift left by a runtime amount, as five conditional constant shifts.
def shl_by(+x: U32, +k: U32) -> U32:
  shl_step(U32.is_eq((k .&. 16 : U32), 16),
    shl_step(U32.is_eq((k .&. 8 : U32), 8),
      shl_step(U32.is_eq((k .&. 4 : U32), 4),
        shl_step(U32.is_eq((k .&. 2 : U32), 2),
          shl_step(U32.is_eq((k .&. 1 : U32), 1), x, 1n), 2n), 4n), 8n), 16n)

# ---------------------------------------------------------------------------
# The level stack.
#
# One digest per level, addressed by index through a balanced 512-slot tree
# that is grown on demand. It is a `Data` structure, not a linear `Array`, for two reasons: the
# pinned backend could not compile a walker that threads two linear resources
# when its buffer comes from another recursive producer (see
# `build/t_read_once.bend` versus `build/t_read_stack.bend`), and a duplicable
# stack keeps the walkers' state a single linear value. Access is by halving,
# six steps, never a spine walk.
type DStack is Data:
  DLeaf{d: D.Digest}
  DNode{lo: DStack, hi: DStack}

# A leaf at any level stands for a subtree whose slots all hold its digest, so
# a fresh stack is one leaf and `set_at` splits leaves only along the path it
# writes. Building all 511 nodes up front cost more than the hashing of a small
# container's root.
def new_stack() -> DStack: DLeaf{D.zero()}

def dget_leaf(+st: DStack) -> D.Digest:
  match st:
    case DLeaf{+d}: d
    case DNode{+lo, hi}: dget_leaf(lo)

# Is bit 8 - the top bit of a nine-level index - clear? The descent shifts the
# index left one place per level, so this one test reads each level's bit in
# turn, where a shift by the level number would cost five conditional shifts.
def top_zero(+i: U32) -> Bool: U32.is_eq((i .&. 256 : U32), 0)

# Indexed read: descend bit by bit from the top level. The decision for the
# next level is computed by the caller, because Bend cannot match a computed
# value and has no mutual recursion.
def dget(+levels: Nat, low: Bool, +st: DStack, +i: U32) -> D.Digest:
  match levels:
    case 0n: dget_leaf(st)
    case 1n+p:
      match low:
        case True{}:
          match st:
            case DNode{+lo, hi}: dget(p, top_zero(U32.shln(i, 1n)), lo, U32.shln(i, 1n))
            case DLeaf{+d}: d
        case False{}:
          match st:
            case DNode{lo, +hi}: dget(p, top_zero(U32.shln(i, 1n)), hi, U32.shln(i, 1n))
            case DLeaf{+d}: d

def get_at(+st: DStack, +i: U32) -> D.Digest: dget(9n, top_zero(i), st, i)

def dset(+levels: Nat, low: Bool, +st: DStack, +i: U32, +d: D.Digest) -> DStack:
  match levels:
    case 0n: DLeaf{d}
    case 1n+p:
      match low:
        case True{}:
          match st:
            case DNode{+lo, +hi}:
              DNode{dset(p, top_zero(U32.shln(i, 1n)), lo, U32.shln(i, 1n), d), hi}
            case DLeaf{+x}:
              DNode{dset(p, top_zero(U32.shln(i, 1n)), DLeaf{x}, U32.shln(i, 1n), d), DLeaf{x}}
        case False{}:
          match st:
            case DNode{+lo, +hi}:
              DNode{lo, dset(p, top_zero(U32.shln(i, 1n)), hi, U32.shln(i, 1n), d)}
            case DLeaf{+x}:
              DNode{DLeaf{x}, dset(p, top_zero(U32.shln(i, 1n)), DLeaf{x}, U32.shln(i, 1n), d)}

def set_at(+st: DStack, +i: U32, +d: D.Digest) -> DStack:
  dset(9n, top_zero(i), st, i, d)

# Push digest `d` as leaf `i`: combine with the stack while bit k of i is set.
def push(+fuel: Nat, set: Bool, +i: U32, +k: U32, +seg: U32, +d: D.Digest, +st: DStack) -> DStack:
  match fuel:
    case 0n: set_at(st, (seg + k : U32), d)
    case 1n+p:
      match set:
        case False{}: set_at(st, (seg + k : U32), d)
        case True{}:
          push(p, bit(i, (k + 1 : U32)), i, (k + 1 : U32), seg,
            D.hash_pair(get_at(st, (seg + k : U32)), d), st)

# Push every chunk of [off, off+len); `n` is the number of chunks.
def leaves(+fuel: Nat, more: Bool, +i: U32, +n: U32, +off: U32, +len: U32, +mpos: U32, +mask: U32,
           +seg: U32, +st: DStack, pair: B.Buf & D.Digest) -> B.Buf & DStack:
  match fuel:
    case 0n:
      (buf, d) = pair
      (buf, st)
    case 1n+p:
      match more:
        case False{}:
          (buf, d) = pair
          (buf, st)
        case True{}:
          (buf, +d) = pair
          leaves(p, U32.is_lt((i + 1 : U32), n), (i + 1 : U32), n, off, len, mpos, mask, seg,
            push(64n, bit(i, 0), i, 0, seg, d, st),
            chunk_at(buf, (off + 32 * (i + 1 : U32) : U32), (off + len : U32), mpos, mask))

def climb(left: Bool, top: D.Digest, acc: D.Digest, z: D.Digest) -> D.Digest:
  match left:
    case True{}: D.hash_pair(top, acc)
    case False{}: D.hash_pair(acc, z)

# Ascend to `depth`: the stack entry is the left sibling exactly where bit k of
# the leaf count is set, the zero-subtree root the right sibling otherwise.
def ascend(+fuel: Nat, more: Bool, +k: U32, +depth: U32, +n: U32, +seg: U32, acc: D.Digest,
           +z: D.Digest, +st: DStack) -> D.Digest:
  match fuel:
    case 0n: acc
    case 1n+p:
      match more:
        case False{}: acc
        case True{}:
          ascend(p, U32.is_lt((k + 1 : U32), depth), (k + 1 : U32), depth, n, seg,
            climb(bit(n, k), get_at(st, (seg + k : U32)), acc, z), D.hash_pair(z, z), st)

# Depth needed for `limit` leaves: the smallest d with 2^d >= limit.
def depth_go(+fuel: Nat, +limit: U32, +d: U32) -> U32:
  match fuel:
    case 0n: d
    case 1n+p:
      match limit:
        case 0: d
        case 1: d
        case _: depth_go(p, U32.shrn((limit + 1 : U32), 1n), (d + 1 : U32))

def depth_of(+limit: U32) -> U32: depth_go(32n, limit, 0)

def close_pick(full: Bool, +depth: U32, +n: U32, +seg: U32, +st: DStack) -> D.Digest:
  match full:
    case True{}: get_at(st, (seg + depth : U32))
    case False{}:
      ascend(64n, U32.is_lt(0, depth), 0, depth, n, seg, D.zero(), D.zero(), st)

def full_in(small: Bool, +depth: U32, +n: U32) -> Bool:
  match small:
    case True{}: U32.is_eq(n, shl_by(1, depth))
    case False{}: False{}

# A tree of depth 32 or more is never full: its capacity exceeds any U32 count.
def close(+depth: U32, +n: U32, +seg: U32, +st: DStack) -> D.Digest:
  close_pick(full_in(U32.is_lt(depth, 32), depth, n), depth, n, seg, st)

def finish_leaves(+depth: U32, +n: U32, +seg: U32, pair: B.Buf & DStack) -> B.Buf & D.Digest:
  (buf, +st) = pair
  (buf, close(depth, n, seg, st))

# The general case: push every chunk, then close the tree. The stack is a
# duplicable value, so only the buffer is threaded.
def merkleize_tree(buf: B.Buf, +st: DStack, +seg: U32, +off: U32, +len: U32, +depth: U32,
                   +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  finish_leaves(depth, U32.shrn((len + 31 : U32), 5n), seg,
    leaves(Nat.add(8n, U32.to_nat(U32.shrn((len + 31 : U32), 5n))),
      U32.is_lt(0, U32.shrn((len + 31 : U32), 5n)), 0,
      U32.shrn((len + 31 : U32), 5n), off, len, mpos, mask, seg, st,
      chunk_at(buf, off, (off + len : U32), mpos, mask)))

def merkleize_pick(single: Bool, buf: B.Buf, +st: DStack, +seg: U32, +off: U32, +len: U32,
                   +depth: U32, +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  match single:
    case True{}: chunk_at(buf, off, (off + len : U32), mpos, mask)
    case False{}: merkleize_tree(buf, st, seg, off, len, depth, mpos, mask)

# Merkleize a byte range using the caller's stack segment. A depth-0 tree is a
# single chunk - the range zero-padded to 32 bytes, which is also the empty
# range's root - so it is read directly, without a round trip through the
# stack; that is every uint, `Bytes32` and other one-chunk field.
def merkleize_in(buf: B.Buf, +st: DStack, +seg: U32, +off: U32, +len: U32, +depth: U32,
                 +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  merkleize_pick(U32.is_eq(depth, 0), buf, st, seg, off, len, depth, mpos, mask)

def merkleize_at(buf: B.Buf, +off: U32, +len: U32, +depth: U32) -> B.Buf & D.Digest:
  merkleize_in(buf, new_stack(), 0, off, len, depth, 4294967295, 255)

# Merkle root padded to `limit` chunks; the depth follows from the limit.
def merkleize_bytes(buf: B.Buf, +off: U32, +len: U32, +limit: U32) -> B.Buf & D.Digest:
  merkleize_at(buf, off, len, depth_of(limit))
