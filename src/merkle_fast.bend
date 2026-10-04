import Base
import ./buffer.bend as B
import ./digest.bend as D

# What the object API takes from the old streaming merkleizer (round 8: the streaming merkleizer itself, its chunk readers, level stack
# and progressive segments had no caller and were removed; every root goes through src/obj.bend's `mtree` / `ptree` and `D.zconst`):
# the runtime shifts `shr_by` / `shl_by` and `ready`, which gives a buffer its Merkle scratch and fills the zero-subtree table there.

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

# The zero table lives in the buffer's Merkle scratch (`B.get_digest` / `B.set_digest`, slot s = eight words): the zero-subtree roots
# Z(0..63) in slots 960..1023.
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

