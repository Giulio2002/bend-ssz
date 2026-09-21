import Base
import ../../src/buffer.bend as B
import ../../src/api.bend as API
import ../../src/digest.bend as D
import ../../src/cschema.bend as CS
import ../../types/fulu_cschema.bend as Spec

# Where a small root's time goes: 100,000 roots each of
#   u64        CUint{8}: one chunk, no hash - walker overhead alone
#   bytes64    CBytes{64, 1}: two chunks, one hash, through the digest stack
#   checkpoint Checkpoint: two single-chunk fields, one hash, container path
# all on the same 64-byte buffer.

def fold(d: D.Digest) -> U32:
  match d:
    case D.D{+w0, w1, w2, w3, w4, w5, w6, w7}: w0

def loop(+k: Nat, +s: CS.CS, +len: U32, +acc: U32, pair: B.Buf & D.Digest) -> B.Buf & U32:
  match k:
    case 0n:
      (buf, o) = pair
      (buf, acc)
    case 1n+p:
      (buf, o) = pair
      loop(p, s, len, (acc .^. fold(o) : U32), API.root(s, len, buf))

def n() -> Nat: Nat.mul(1000n, 100n)

def timed(label: String, +t0: Nat, pair: B.Buf & U32) -> IO(B.Buf):
  (buf, +acc) = pair
  do IO<B.Buf>:
    t1 : Nat <- IO.now()
    IO.print(label ++ "_ms=" ++ Nat.show(Nat.sub(t1, t0)) ++ " acc=" ++ U32.show(acc))
    IO.pure(B.Buf, buf)

def run(label: String, +s: CS.CS, +len: U32, buf: B.Buf) -> IO(B.Buf):
  do IO<B.Buf>:
    t0 : Nat <- IO.now()
    timed(label, t0, loop(n(), s, len, 0, API.root(s, len, buf)))

def main() -> IO(Unit):
  do IO<Unit>:
    b0 : B.Buf = B.alloc(64)
    b1 : B.Buf <- run("u64", CS.CUint{8}, 8, b0)
    b2 : B.Buf <- run("bytes64", CS.CBytes{64, 1}, 64, b1)
    b3 : B.Buf <- run("checkpoint", Spec.Checkpoint(), 40, b2)
    IO.print("done")
