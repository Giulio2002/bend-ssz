import Base
import ./buffer.bend as B
import ./digest.bend as D

# Streaming merkleization over indexed storage.
#
# Chunks are read straight out of the packed buffer as eight big-endian words,
# the form the pinned SHA-256 package consumes, so no chunk list, byte list or
# materialised zero padding ever exists. Partial subtrees live in an
# `Array<D.Digest>` indexed by level - sixty-four slots is more than the deepest
# SSZ tree - and the zero-subtree root for each level is carried upward during
# the final ascent, one hash per level, rather than tabulated.
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

# The eight words of a chunk, read one per step into an accumulating digest.
# This used to be eight chained definitions; as a loop it is a fraction of the
# code, which matters because the whole program has to fit in the compiler's
# memory budget.
def set_at_word(+d: D.Digest, +k: U32, +w: U32) -> D.Digest:
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      match k:
        case 0: D.D{w, w1, w2, w3, w4, w5, w6, w7}
        case 1: D.D{w0, w, w2, w3, w4, w5, w6, w7}
        case 2: D.D{w0, w1, w, w3, w4, w5, w6, w7}
        case 3: D.D{w0, w1, w2, w, w4, w5, w6, w7}
        case 4: D.D{w0, w1, w2, w3, w, w5, w6, w7}
        case 5: D.D{w0, w1, w2, w3, w4, w, w6, w7}
        case 6: D.D{w0, w1, w2, w3, w4, w5, w, w7}
        case _: D.D{w0, w1, w2, w3, w4, w5, w6, w}

def chunk_go(+k: Nat, +i: U32, +pos: U32, +limit: U32, +mpos: U32, +mask: U32, +acc: D.Digest,
             pair: B.Buf & U32) -> B.Buf & D.Digest:
  match k:
    case 0n:
      (buf, w) = pair
      (buf, acc)
    case 1n+p:
      (buf, +w) = pair
      chunk_go(p, (i + 1 : U32), pos, limit, mpos, mask,
        set_at_word(acc, i, B.swap32(apply_mask((pos + 4 * i : U32), mpos, mask,
          clip_word((pos + 4 * i : U32), limit, w)))),
        B.read32(buf, (pos + 4 * (i + 1 : U32) : U32)))

# The 32-byte chunk starting at `pos`, zero-padded past `limit`.
def chunk_at(buf: B.Buf, +pos: U32, +limit: U32, +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  chunk_go(8n, 0, pos, limit, mpos, mask, D.zero(), B.read32(buf, pos))

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
# One digest per level, addressed by index through a balanced sixty-four-slot
# tree. It is a `Data` structure, not a linear `Array`, for two reasons: the
# pinned backend could not compile a walker that threads two linear resources
# when its buffer comes from another recursive producer (see
# `build/t_read_once.bend` versus `build/t_read_stack.bend`), and a duplicable
# stack keeps the walkers' state a single linear value. Access is by halving,
# six steps, never a spine walk.
type DStack is Data:
  DLeaf{d: D.Digest}
  DNode{lo: DStack, hi: DStack}

def new_stack_go(+levels: Nat) -> DStack:
  match levels:
    case 0n: DLeaf{D.zero()}
    case 1n+p: DNode{new_stack_go(p), new_stack_go(p)}

def new_stack() -> DStack: new_stack_go(9n)

def dget_leaf(+st: DStack) -> D.Digest:
  match st:
    case DLeaf{+d}: d
    case DNode{+lo, hi}: dget_leaf(lo)

def bit_zero(+i: U32, +k: U32) -> Bool: U32.is_eq((shr_by(i, k) .&. 1 : U32), 0)

# Indexed read: descend bit by bit from the top level. The decision for the
# next level is computed by the caller, because Bend cannot match a computed
# value and has no mutual recursion.
def dget(+levels: Nat, low: Bool, +k: U32, +st: DStack, +i: U32) -> D.Digest:
  match levels:
    case 0n: dget_leaf(st)
    case 1n+p:
      match low:
        case True{}:
          match st:
            case DNode{+lo, hi}: dget(p, bit_zero(i, (k - 1 : U32)), (k - 1 : U32), lo, i)
            case DLeaf{+d}: d
        case False{}:
          match st:
            case DNode{lo, +hi}: dget(p, bit_zero(i, (k - 1 : U32)), (k - 1 : U32), hi, i)
            case DLeaf{+d}: d

def get_at(+st: DStack, +i: U32) -> D.Digest: dget(9n, bit_zero(i, 8), 8, st, i)

def dset(+levels: Nat, low: Bool, +k: U32, +st: DStack, +i: U32, +d: D.Digest) -> DStack:
  match levels:
    case 0n: DLeaf{d}
    case 1n+p:
      match low:
        case True{}:
          match st:
            case DNode{+lo, +hi}:
              DNode{dset(p, bit_zero(i, (k - 1 : U32)), (k - 1 : U32), lo, i, d), hi}
            case DLeaf{x}: DLeaf{d}
        case False{}:
          match st:
            case DNode{+lo, +hi}:
              DNode{lo, dset(p, bit_zero(i, (k - 1 : U32)), (k - 1 : U32), hi, i, d)}
            case DLeaf{x}: DLeaf{d}

def set_at(+st: DStack, +i: U32, +d: D.Digest) -> DStack:
  dset(9n, bit_zero(i, 8), 8, st, i, d)

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

# Merkleize a byte range using the caller's stack segment. The stack is a
# duplicable value, so only the buffer is threaded.
def merkleize_in(buf: B.Buf, +st: DStack, +seg: U32, +off: U32, +len: U32, +depth: U32,
                 +mpos: U32, +mask: U32) -> B.Buf & D.Digest:
  finish_leaves(depth, U32.shrn((len + 31 : U32), 5n), seg,
    leaves(Nat.add(8n, U32.to_nat(U32.shrn((len + 31 : U32), 5n))),
      U32.is_lt(0, U32.shrn((len + 31 : U32), 5n)), 0,
      U32.shrn((len + 31 : U32), 5n), off, len, mpos, mask, seg, st,
      chunk_at(buf, off, (off + len : U32), mpos, mask)))

def merkleize_at(buf: B.Buf, +off: U32, +len: U32, +depth: U32) -> B.Buf & D.Digest:
  merkleize_in(buf, new_stack(), 0, off, len, depth, 4294967295, 255)

# Merkle root padded to `limit` chunks; the depth follows from the limit.
def merkleize_bytes(buf: B.Buf, +off: U32, +len: U32, +limit: U32) -> B.Buf & D.Digest:
  merkleize_at(buf, off, len, depth_of(limit))
