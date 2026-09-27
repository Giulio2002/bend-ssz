import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/FuluBlobIndex_encode_ssz_generated.bend as FuluBlobIndex_e
import ../../types/FuluKZGCommitment_encode_ssz_generated.bend as FuluKZGCommitment_e

# Where the time of a small encode goes. Each loop runs the same number of
# iterations and consumes its result, so the differences are the parts:
#
#   0  allocate the output array the generic way (runtime capacity) and drop it
#   1  allocate it with a capacity known at compile time
#   2  allocate and write two words through the generic byte-position writer
#   3  allocate and write the same two words as aligned word stores
#   4  the generated BlobIndex encode (a uint64), for comparison
#   5  the generated KZGCommitment encode (48 bytes)

def word_of(pair: B.Buf & U32) -> U32:
  (b, +w) = pair
  w

def consume(out: B.Buf) -> U32: word_of(B.word(out, 0))

def loop0(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p: loop0(p, (acc .^. consume(O.out_done(8, O.out_new(8))) : U32))

def loop1(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p: loop1(p, (acc .^. consume(B.Buf{Array.new(U32, 2n, 0), 8}) : U32))

def loop2(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p: loop2(p, (acc .^. consume(O.out_done(8, O.w32(O.w32(O.out_new(8), 0, 305419896), 4, 2596069104))) : U32))

def loop3(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p:
      loop3(p, (acc .^. consume(B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 305419896), 1, 2596069104), 8}) : U32))

def loop4(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p: loop4(p, (acc .^. consume(FuluBlobIndex_e.BlobIndex_encode(O.U64{305419896, 2596069104})) : U32))

def loop5(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p:
      loop5(p, (acc .^. consume(FuluKZGCommitment_e.KZGCommitment_encode(
        FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})) : U32))

def pick(+which: U32, +k: Nat) -> U32:
  match which:
    case 0: loop0(k, 0)
    case 1: loop1(k, 0)
    case 2: loop2(k, 0)
    case 3: loop3(k, 0)
    case 4: loop4(k, 0)
    case _: loop5(k, 0)

def report(+which: U32, +n: U32, +t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("LOOP=" ++ U32.show(which) ++ " MS=" ++ Nat.show(Nat.sub(t1, t0))
      ++ " ACC=" ++ U32.show(acc))

def timed(+which: U32, +n: U32, +t0: Nat) -> IO(Unit):
  report(which, n, t0, pick(which, U32.to_nat(n)))

def main() -> IO(Unit):
  do IO<Unit>:
    +which : U32 <- IO.pure(U32, 0)
    t0 : Nat <- IO.now()
    timed(0, 2000000, t0)
    t1 : Nat <- IO.now()
    timed(1, 2000000, t1)
    t2 : Nat <- IO.now()
    timed(2, 2000000, t2)
    t3 : Nat <- IO.now()
    timed(3, 2000000, t3)
    t4 : Nat <- IO.now()
    timed(4, 2000000, t4)
    t5 : Nat <- IO.now()
    timed(5, 2000000, t5)
