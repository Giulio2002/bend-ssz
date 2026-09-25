import Base
import 0xe4067e0d858024083f36a7abe7281e89/src/crypto/sha/sha256.bend as SHA
import 0xe4067e0d858024083f36a7abe7281e89/src/crypto/sha/core.bend as Core
import 0xe4067e0d858024083f36a7abe7281e89/src/crypto/sha/state.bend as S

# Cost of one SSZ Merkle node hash (two 32-byte chunks) on the native C
# backend, measured two ways: through the byte-list entry point the codec uses
# today, and directly through the vendored 16-word block compressor.

def bytes64(+seed: U32) -> List<&2, U32>:
  b = (seed .&. 255 : U32)
  [b, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
   32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
   48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63]

def head_or(xs: List<&2, U32>) -> U32:
  match xs:
    case Nil{}: 0
    case h <> t: h

# The accumulator feeds the next input, so no iteration is loop-invariant and
# nothing can be hoisted or shared between iterations.
def legacy_loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      legacy_loop(p, (acc .^. head_or(SHA.sha256_bytes(bytes64(acc))) : U32))

# Two blocks: the 64 message bytes, then the fixed padding block for a
# 512-bit message.
def pair_state(+a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32,
               +b0: U32, +b1: U32, +b2: U32, +b3: U32, +b4: U32, +b5: U32, +b6: U32, +b7: U32) -> S.State:
  Core.window_compress16(2147483648, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 512,
    48n, Core.round_constants(),
    Core.window_compress16(a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7,
      48n, Core.round_constants(), Core.initial()))

def state_head(s: S.State) -> U32:
  S.H{a, b, c, d, e, f, g, h} = s
  a

def compact_loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      compact_loop(p,
        (acc .^. state_head(pair_state(acc, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)) : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("X=" ++ U32.show(legacy_loop(50000n, 7)))
    t1 : Nat <- IO.now()
    IO.print("LEGACY_MS=" ++ Nat.show(Nat.sub(t1, t0)))
    t2 : Nat <- IO.now()
    IO.print("Y=" ++ U32.show(compact_loop(50000n, 7)))
    t3 : Nat <- IO.now()
    IO.print("COMPACT_MS=" ++ Nat.show(Nat.sub(t3, t2)))
