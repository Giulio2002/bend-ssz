import Base
import ../../src/buffer.bend as B
import ../../src/merkle_fast.bend as MF
import ../../src/digest.bend as D

# Merkleization cost with the buffer built and forced beforehand, so only
# chunking, the level stack and hashing are timed: 1 MiB = 32,768 chunks,
# 32,767 node hashes. Compare with benchmarks/probes/hash_variants.bend for the
# hashing share.

def gen(+n: Nat, +i: U32, acc: +List<U32>) -> +List<U32>:
  match n:
    case 0n: acc
    case 1n+p: gen(p, (i - 1 : U32), ((((i - 1 : U32) * 7 : U32) + 3 : U32) .&. 255 : U32) <> acc)

def digest_sum(d: D.Digest) -> U32:
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      (w0 .^. w1 .^. w2 .^. w3 .^. w4 .^. w5 .^. w6 .^. w7 : U32)

def root_text(pair: B.Buf & D.Digest) -> String:
  (buf, d) = pair
  U32.show(digest_sum(d))

def timed(pair: B.Buf & U32) -> IO(Unit):
  (buf, +last) = pair
  do IO<Unit>:
    IO.print("LAST=" ++ U32.show(last))
    t0 : Nat <- IO.now()
    IO.print("ROOT=" ++ root_text(MF.merkleize_bytes(buf, 0, 1048576, 32768)))
    t1 : Nat <- IO.now()
    IO.print("MERKLE_1MIB_MS=" ++ Nat.show(Nat.sub(t1, t0)))

def main() -> IO(Unit):
  timed(B.byte_at(B.of_list(1048576, gen(U32.to_nat(1048576), 1048576, [])), 1048575))
