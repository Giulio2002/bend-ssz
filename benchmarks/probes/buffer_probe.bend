import Base
import ../../src/buffer.bend as B

# Correctness and cost of the indexed byte buffer at fixture scale
# (2,740,473 bytes is the size of the mainnet Fulu BeaconState fixtures).
#
# SUM_LIST is the checksum of the source byte list, SUM_BUF the checksum read
# back byte by byte through `B.byte_at`, and SUM32 the checksum of the same
# bytes read four at a time through `B.read32`; all three must agree.

def gen(+n: Nat, +i: U32, acc: +List<U32>) -> +List<U32>:
  match n:
    case 0n: acc
    case 1n+p: gen(p, (i - 1 : U32), ((i - 1 : U32) .&. 255 : U32) <> acc)

def sum_list(xs: +List<U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: sum_list(t, (acc + h : U32))

def scan_go(+k: Nat, +i: U32, +acc: U32, pair: B.Buf & U32) -> B.Buf & U32:
  match k pair:
    case 0n Tuple{b, v}: (b, acc)
    case 1n+p Tuple{b, v}: scan_go(p, (i + 1 : U32), (acc + v : U32), B.byte_at(b, (i + 1 : U32)))

def scan_at(+n: U32, b: B.Buf) -> B.Buf & U32:
  scan_go(U32.to_nat(n), 0, 0, B.byte_at(b, 0))

def words_go(+k: Nat, +i: U32, +acc: U32, pair: B.Buf & U32) -> B.Buf & U32:
  match k pair:
    case 0n Tuple{b, v}: (b, acc)
    case 1n+p Tuple{b, +v}:
      words_go(p, (i + 4 : U32), (acc + (v .&. 255 : U32) + (U32.shrn(v, 8n) .&. 255 : U32)
        + (U32.shrn(v, 16n) .&. 255 : U32) + U32.shrn(v, 24n) : U32), B.read32(b, (i + 4 : U32)))

def words_at(+n: U32, b: B.Buf) -> B.Buf & U32:
  words_go(U32.to_nat(U32.shrn(n, 2n)), 0, 0, B.read32(b, 0))

def drop_zero(b: B.Buf) -> U32: (B.drop(b) .&. 0 : U32)

def report(pair: B.Buf & U32) -> U32:
  (b, v) = pair
  (v + drop_zero(b) : U32)

def sum_buf(+n: U32, b: B.Buf) -> U32: report(scan_at(n, b))

def sum_words(+n: U32, b: B.Buf) -> U32: report(words_at(n, b))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("SUM_LIST=" ++ U32.show(sum_list(gen(U32.to_nat(2740472), 2740472, []), 0)))
    t0 : Nat <- IO.now()
    IO.print("SUM_BUF=" ++ U32.show(sum_buf(2740472, B.of_list(2740472, gen(U32.to_nat(2740472), 2740472, [])))))
    t1 : Nat <- IO.now()
    IO.print("FILL_AND_SCAN_MS=" ++ Nat.show(Nat.sub(t1, t0)))
    t2 : Nat <- IO.now()
    IO.print("SUM32=" ++ U32.show(sum_words(2740472, B.of_list(2740472, gen(U32.to_nat(2740472), 2740472, [])))))
    t3 : Nat <- IO.now()
    IO.print("FILL_AND_WORDSCAN_MS=" ++ Nat.show(Nat.sub(t3, t2)))
