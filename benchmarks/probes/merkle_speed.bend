import Base
import ../../src/buffer.bend as B
import ../../src/merkle_fast.bend as MF
import ../../src/digest.bend as D

# Cost of merkleizing a real-sized byte range out of the packed buffer.
def gen(+n: Nat, +i: U32, acc: +List<U32>) -> +List<U32>:
  match n:
    case 0n: acc
    case 1n+p: gen(p, (i - 1 : U32), ((((i - 1 : U32) * 7 : U32) + 3 : U32) .&. 255 : U32) <> acc)

def digest_sum(d: D.Digest) -> U32:
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      (w0 .^. w1 .^. w2 .^. w3 .^. w4 .^. w5 .^. w6 .^. w7 : U32)

def root_sum(pair: B.Buf & D.Digest) -> U32:
  (buf, d) = pair
  (digest_sum(d) .^. (B.drop(buf) .&. 0 : U32) : U32)

def run_case(+len: U32, +limit: U32, xs: +List<U32>) -> U32:
  root_sum(MF.merkleize_bytes(B.of_list(len, xs), 0, len, limit))

def main() -> IO(Unit):
  do IO<Unit>:
    xs : +List<U32> = gen(U32.to_nat(1048576), 1048576, [])
    IO.print("PREP=" ++ U32.show(U32.from_nat(List.length(&2, U32, xs))))
    t0 : Nat <- IO.now()
    IO.print("R1M=" ++ U32.show(run_case(1048576, 32768, gen(U32.to_nat(1048576), 1048576, []))))
    t1 : Nat <- IO.now()
    IO.print("MERKLE_1MB_MS=" ++ Nat.show(Nat.sub(t1, t0)))
