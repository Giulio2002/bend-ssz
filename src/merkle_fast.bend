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

# The 32-byte chunk starting at `pos`, zero-padded past `limit`. Recursive in
# form (`guard` is always 0n) so that the backend does not inline it.
def chunk_go(+guard: Nat, buf: B.Buf, +pos: U32, +limit: U32, +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  match guard:
    case 1n+p: chunk_go(p, buf, pos, limit, mpos, mask)
    case 0n:
      chunk_pick(
        Bool.and(U32.is_eq((pos .&. 3 : U32), 0),
          Bool.and(U32.is_le((pos + 32 : U32), limit), Bool.not(masked_in(pos, mpos)))),
        buf, pos, limit, mpos, mask)

def chunk_at(buf: B.Buf, +pos: U32, +limit: U32, +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  chunk_go(0n, buf, pos, limit, mpos, mask)

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
# The level stack and the zero table live in the buffer's Merkle scratch
# (`B.get_digest` / `B.set_digest`, slot s = eight words): one digest per level
# in 64-slot segments, one segment per nesting level of the schema, and the
# zero-subtree roots Z(0..63) in slots 960..1023. So the only mutable state of
# a hash is the caller's own packed array - no second structure, no sharing,
# and every access is eight O(1) word reads or writes.
#
# (Measured alternatives: a duplicable binary tree of digests
# cost ~150 ns per access and made the stack most of a small root's time;
# four- and sixteen-way trees were slower or did not fit the compile budget.)

# Z(0) is the zero chunk and Z(k + 1) = H(Z(k), Z(k)) - computed by hashing,
# the specification's own definition, not a table of constants.
def fill_zeros(+k: Nat, +i: U32, +z: D.Digest, buf: B.Buf) -> B.Buf:
  match k:
    case 0n: buf
    case 1n+p: fill_zeros(p, (i + 1 : U32), D.hash_pair(z, z), B.set_digest(buf, (960 + i : U32), z))

def ready_pick(filled: Bool, buf: B.Buf) -> B.Buf:
  match filled:
    case True{}: buf
    case False{}: fill_zeros(64n, 0, D.zero(), buf)

def first_word(d: D.Digest) -> U32:
  match d:
    case D.D{+x0, x1, x2, x3, x4, x5, x6, x7}: x0

def ready_seen(pair: B.Buf & D.Digest) -> B.Buf:
  (buf, d) = pair
  ready_pick(Bool.not(U32.is_eq(first_word(d), 0)), buf)

# A buffer ready to be hashed: it has scratch room, and its zero table is
# filled. The table is filled once per buffer; Z(1) = H(0, 0) begins with the
# word 0xf5a5fd42, so a zero there means "not filled yet".
def ready(buf: B.Buf) -> B.Buf: ready_seen(B.get_digest(B.with_scratch(buf), 961))

# Push digest `d` as leaf `i`: combine with the stack while bit k of i is set.
# `pair` holds the buffer and the stack entry at level k, read beforehand.
def push(+fuel: Nat, set: Bool, +i: U32, +k: U32, +seg: U32, +d: D.Digest, pair: B.Buf & D.Digest) -> B.Buf:
  match fuel:
    case 0n:
      (buf, top) = pair
      B.set_digest(buf, (seg + k : U32), d)
    case 1n+p:
      match set:
        case False{}:
          (buf, top) = pair
          B.set_digest(buf, (seg + k : U32), d)
        case True{}:
          (buf, +top) = pair
          push(p, bit(i, (k + 1 : U32)), i, (k + 1 : U32), seg, D.hash_pair(top, d),
            B.get_digest(buf, (seg + k + 1 : U32)))

def push_leaf(+i: U32, +seg: U32, +d: D.Digest, buf: B.Buf) -> B.Buf:
  push(64n, bit(i, 0), i, 0, seg, d, B.get_digest(buf, seg))

# Push every chunk of [off, off+len); `n` is the number of chunks.
def leaves(+fuel: Nat, more: Bool, +i: U32, +n: U32, +off: U32, +len: U32, +mpos: U32, +mask: U32,
           +seg: U32, pair: B.Buf & D.Digest) -> B.Buf:
  match fuel:
    case 0n:
      (buf, d) = pair
      buf
    case 1n+p:
      match more:
        case False{}:
          (buf, d) = pair
          buf
        case True{}:
          (buf, +d) = pair
          leaves(p, U32.is_lt((i + 1 : U32), n), (i + 1 : U32), n, off, len, mpos, mask, seg,
            chunk_at(push_leaf(i, seg, d, buf), (off + 32 * (i + 1 : U32) : U32), (off + len : U32), mpos, mask))

def climb(left: Bool, other: D.Digest, acc: D.Digest) -> D.Digest:
  match left:
    case True{}: D.hash_pair(other, acc)
    case False{}: D.hash_pair(acc, other)

def slot_pick(left: Bool, +here: U32, +zero: U32) -> U32:
  match left:
    case True{}: here
    case False{}: zero

# Ascend to `depth`: the stack entry is the left sibling exactly where bit k of
# the leaf count is set, and the zero-subtree root Z(k) is the right sibling
# otherwise - so each level reads one slot and hashes once. `pair` holds that
# slot's digest, read beforehand.
def ascend(+fuel: Nat, more: Bool, +k: U32, +depth: U32, +n: U32, +seg: U32, +acc: D.Digest,
           pair: B.Buf & D.Digest) -> B.Buf & D.Digest:
  match fuel:
    case 0n:
      (buf, other) = pair
      (buf, acc)
    case 1n+p:
      match more:
        case False{}:
          (buf, other) = pair
          (buf, acc)
        case True{}:
          (buf, +other) = pair
          ascend(p, U32.is_lt((k + 1 : U32), depth), (k + 1 : U32), depth, n, seg,
            climb(bit(n, k), other, acc),
            B.get_digest(buf, slot_pick(bit(n, (k + 1 : U32)), (seg + k + 1 : U32), (960 + k + 1 : U32))))

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

# An empty tree of depth d is Z(d); a full one is the stack's top entry.
def close_pick(full: Bool, empty: Bool, +depth: U32, +n: U32, +seg: U32, buf: B.Buf) -> B.Buf & D.Digest:
  match full:
    case True{}: B.get_digest(buf, (seg + depth : U32))
    case False{}:
      match empty:
        case True{}: B.get_digest(buf, (960 + depth : U32))
        case False{}:
          ascend(64n, U32.is_lt(0, depth), 0, depth, n, seg, D.zero(),
            B.get_digest(buf, slot_pick(bit(n, 0), seg, 960)))

def full_in(small: Bool, +depth: U32, +n: U32) -> Bool:
  match small:
    case True{}: U32.is_eq(n, shl_by(1, depth))
    case False{}: False{}

# A tree of depth 32 or more is never full: its capacity exceeds any U32 count.
def close(+depth: U32, +n: U32, +seg: U32, buf: B.Buf) -> B.Buf & D.Digest:
  close_pick(full_in(U32.is_lt(depth, 32), depth, n), U32.is_eq(n, 0), depth, n, seg, buf)

# The general case: push every chunk, then close the tree.
def merkleize_tree(buf: B.Buf, +seg: U32, +off: U32, +len: U32, +depth: U32,
                   +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  close(depth, U32.shrn((len + 31 : U32), 5n), seg,
    leaves(Nat.add(8n, U32.to_nat(U32.shrn((len + 31 : U32), 5n))),
      U32.is_lt(0, U32.shrn((len + 31 : U32), 5n)), 0,
      U32.shrn((len + 31 : U32), 5n), off, len, mpos, mask, seg,
      chunk_at(buf, off, (off + len : U32), mpos, mask)))

def merkleize_pick(single: Bool, buf: B.Buf, +seg: U32, +off: U32, +len: U32,
                   +depth: U32, +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  match single:
    case True{}: chunk_at(buf, off, (off + len : U32), mpos, mask)
    case False{}: merkleize_tree(buf, seg, off, len, depth, mpos, mask)

# ---------------------------------------------------------------------------
# Progressive merkleization (ProgressiveList, ProgressiveBitlist, progressive
# containers). Segment k holds 4^k chunks, starting at chunk s(k) = (4^k-1)/3;
# its root T(k) is a complete tree of depth 2k, and the whole root is
# P = H(P', T(0)) where P' is the same construction over the later segments and
# P(no chunks) is the zero chunk. Streaming: the segment being filled uses the
# stack levels seg .. seg + 2k, each finished T(k) is kept in slot seg + 48 + k,
# and the T(k) are folded right to left at the end. Depth 255 marks a
# progressive tree in the schema; chunk counts below 2^32 need k <= 15.
def prog_depth() -> U32: 255

def is_prog(+depth: U32) -> Bool: U32.is_eq(depth, 255)

def prog_cap(+k: U32) -> U32: shl_by(1, (2 * k : U32))

def prog_start(+k: U32) -> U32: U32.div((prog_cap(k) - 1 : U32), 3)

def pick_u32(c: Bool, +x: U32, +y: U32) -> U32:
  match c:
    case True{}: x
    case False{}: y

def umin(+x: U32, +y: U32) -> U32: pick_u32(U32.is_le(x, y), x, y)

# The segment of chunk i. The later-segment search is an argument of the
# selector, and untaken selector arguments are not evaluated.
def prog_k(+fuel: Nat, +k: U32, +i: U32) -> U32:
  match fuel:
    case 0n: k
    case 1n+p: pick_u32(U32.is_lt(i, (prog_start(k) + prog_cap(k) : U32)), k, prog_k(p, (k + 1 : U32), i))

def seg_of(+i: U32) -> U32: prog_k(16n, 0, i)

def copy_slot(+to: U32, pair: B.Buf & D.Digest) -> B.Buf:
  (b, d) = pair
  B.set_digest(b, to, d)

# A finished segment's root, the top of its full local tree, is kept.
def seal_if(full: Bool, +k: U32, +seg: U32, buf: B.Buf) -> B.Buf:
  match full:
    case True{}: copy_slot((seg + 48 + k : U32), B.get_digest(buf, (seg + 2 * k : U32)))
    case False{}: buf

def push_prog_at(+k: U32, +j: U32, +seg: U32, +d: D.Digest, buf: B.Buf) -> B.Buf:
  seal_if(U32.is_eq(j, (prog_cap(k) - 1 : U32)), k, seg,
    push(64n, bit(j, 0), j, 0, seg, d, B.get_digest(buf, seg)))

# Push digest `d` as chunk i of a progressive tree.
def push_prog(+i: U32, +seg: U32, +d: D.Digest, buf: B.Buf) -> B.Buf:
  push_prog_at(seg_of(i), (i - prog_start(seg_of(i)) : U32), seg, d, buf)

# Fold the kept segment roots from segment k down to 0: acc = H(acc, T(k)).
# `pair` holds T(k), read beforehand.
def fold_prog(+fuel: Nat, more: Bool, +k: U32, +seg: U32, +acc: D.Digest, pair: B.Buf & D.Digest) -> B.Buf & D.Digest:
  match fuel:
    case 0n:
      (buf, t) = pair
      (buf, acc)
    case 1n+p:
      match more:
        case False{}:
          (buf, +t) = pair
          (buf, D.hash_pair(acc, t))
        case True{}:
          (buf, +t) = pair
          fold_prog(p, U32.is_lt(1, k), (k - 1 : U32), seg, D.hash_pair(acc, t),
            B.get_digest(buf, (seg + 48 + k - 1 : U32)))

def fold_from(+k: U32, +seg: U32, buf: B.Buf) -> B.Buf & D.Digest:
  fold_prog(17n, U32.is_lt(0, k), k, seg, D.zero(), B.get_digest(buf, (seg + 48 + k : U32)))

# The last segment, if partial, is closed as a depth-2k tree and kept.
def seal_last(full: Bool, +k: U32, +m: U32, +seg: U32, buf: B.Buf) -> B.Buf:
  match full:
    case True{}: buf
    case False{}: copy_slot((seg + 48 + k : U32), close((2 * k : U32), m, seg, buf))

def close_prog_at(+k: U32, +n: U32, +seg: U32, buf: B.Buf) -> B.Buf & D.Digest:
  fold_from(k, seg,
    seal_last(U32.is_eq((n - prog_start(k) : U32), prog_cap(k)), k, (n - prog_start(k) : U32), seg, buf))

def close_prog_pick(empty: Bool, +n: U32, +seg: U32, buf: B.Buf) -> B.Buf & D.Digest:
  match empty:
    case True{}: (buf, D.zero())
    case False{}: close_prog_at(seg_of((n - 1 : U32)), n, seg, buf)

# Root of a progressive tree of n pushed chunks.
def close_prog(+n: U32, +seg: U32, buf: B.Buf) -> B.Buf & D.Digest:
  close_prog_pick(U32.is_eq(n, 0), n, seg, buf)

def push_any_pick(prog: Bool, +i: U32, +seg: U32, +d: D.Digest, buf: B.Buf) -> B.Buf:
  match prog:
    case True{}: push_prog(i, seg, d, buf)
    case False{}: push_leaf(i, seg, d, buf)

# Push and close for either kind of tree, by the schema's depth.
def push_any(+depth: U32, +i: U32, +seg: U32, +d: D.Digest, buf: B.Buf) -> B.Buf:
  push_any_pick(is_prog(depth), i, seg, d, buf)

def close_any_pick(prog: Bool, +depth: U32, +n: U32, +seg: U32, buf: B.Buf) -> B.Buf & D.Digest:
  match prog:
    case True{}: close_prog(n, seg, buf)
    case False{}: close(depth, n, seg, buf)

def close_any(+depth: U32, +n: U32, +seg: U32, buf: B.Buf) -> B.Buf & D.Digest:
  close_any_pick(is_prog(depth), depth, n, seg, buf)

# A progressive tree over the chunks of a byte range: each segment's chunks
# are one ordinary merkleization of depth 2k, kept in slot seg + 48 + k.
def prog_segments(+fuel: Nat, more: Bool, +k: U32, +n: U32, +seg: U32, +off: U32, +len: U32,
                  +mpos: U32, +mask: U32, buf: B.Buf) -> B.Buf:
  match fuel:
    case 0n: buf
    case 1n+p:
      match more:
        case False{}: buf
        case True{}:
          prog_segments(p, U32.is_lt(prog_start((k + 1 : U32)), n), (k + 1 : U32), n, seg, off, len, mpos, mask,
            copy_slot((seg + 48 + k : U32),
              merkleize_pick(U32.is_eq(k, 0), buf, seg, (off + 32 * prog_start(k) : U32),
                umin((len - 32 * prog_start(k) : U32), (32 * prog_cap(k) : U32)), (2 * k : U32), mpos, mask)))

def merkleize_prog_at(+n: U32, +seg: U32, +off: U32, +len: U32, +mpos: U32, +mask: U32, buf: B.Buf) -> B.Buf & D.Digest:
  fold_from(seg_of((n - 1 : U32)), seg, prog_segments(17n, True{}, 0, n, seg, off, len, mpos, mask, buf))

def merkleize_prog_pick(empty: Bool, +n: U32, +seg: U32, +off: U32, +len: U32, +mpos: U32, +mask: U32,
                        buf: B.Buf) -> B.Buf & D.Digest:
  match empty:
    case True{}: (buf, D.zero())
    case False{}: merkleize_prog_at(n, seg, off, len, mpos, mask, buf)

def merkleize_prog(buf: B.Buf, +seg: U32, +off: U32, +len: U32, +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  merkleize_prog_pick(U32.is_eq(len, 0), U32.shrn((len + 31 : U32), 5n), seg, off, len, mpos, mask, buf)

# Merkleize a byte range using the caller's stack segment in a ready buffer.
# A depth-0 tree is a single chunk - the range zero-padded to 32 bytes, which
# is also the empty range's root - so it is read directly, without touching the
# stack; that is every uint, `Bytes32` and other one-chunk field.
def merkleize_kind(prog: Bool, buf: B.Buf, +seg: U32, +off: U32, +len: U32, +depth: U32,
                   +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  match prog:
    case True{}: merkleize_prog(buf, seg, off, len, mpos, mask)
    case False{}: merkleize_pick(U32.is_eq(depth, 0), buf, seg, off, len, depth, mpos, mask)

def merkleize_in(buf: B.Buf, +seg: U32, +off: U32, +len: U32, +depth: U32,
                 +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  merkleize_kind(is_prog(depth), buf, seg, off, len, depth, mpos, mask)

def merkleize_at(buf: B.Buf, +off: U32, +len: U32, +depth: U32) -> B.Buf & D.Digest:
  merkleize_in(ready(buf), 0, off, len, depth, 4294967295, 255)

# Merkle root padded to `limit` chunks; the depth follows from the limit.
def merkleize_bytes(buf: B.Buf, +off: U32, +len: U32, +limit: U32) -> B.Buf & D.Digest:
  merkleize_at(buf, off, len, depth_of(limit))
