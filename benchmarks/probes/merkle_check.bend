import Base
import ../../src/buffer.bend as B
import ../../src/merkle_fast.bend as MF
import ../../src/digest.bend as D
import ../../src/tree.bend as Tree
import ../../src/primitives.bend as P

# The indexed merkleizer against the existing list-based one that the current
# proofs are about. Same bytes, same chunk count, same limit: the roots must be
# identical, including the padded and empty cases.

def gen(+n: Nat, +i: U32, acc: +List<U32>) -> +List<U32>:
  match n:
    case 0n: acc
    case 1n+p: gen(p, (i - 1 : U32), ((((i - 1 : U32) * 7 : U32) + 3 : U32) .&. 255 : U32) <> acc)

# Split a byte list into 32-byte chunks, zero padding the last one.
def chunks_of(+fuel: Nat, +xs: +List<U32>, acc: +List<+List<U32>>) -> +List<+List<U32>>:
  match fuel:
    case 0n: List.reverse(&2, +List<U32>, acc)
    case 1n+p:
      match xs:
        case Nil{}: List.reverse(&2, +List<U32>, acc)
        case Con{+h, +t}:
          chunks_of(p, List.drop(&2, U32, h <> t, 32n), P.pad(32n, List.take(&2, U32, h <> t, 32n)) <> acc)

def legacy_of(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case None{}: []
    case Some{root}: root

def legacy_root(+len: Nat, +limit: U32, xs: +List<U32>) -> +List<U32>:
  legacy_of(Tree.merkleize_at_depth(U32.to_nat(MF.depth_of(limit)), chunks_of(1000n, xs, [])))

def keep_bytes(xs: +List<U32>, +sink: U32) -> +List<U32>: xs

def fast_of(pair: B.Buf & D.Digest) -> +List<U32>:
  (buf, d) = pair
  keep_bytes(D.bytes(d), B.drop(buf))

def fast_root(+len: U32, +limit: U32, xs: +List<U32>) -> +List<U32>:
  fast_of(MF.merkleize_bytes(B.of_list(len, xs), 0, len, limit))

def same(a: +List<U32>, b: +List<U32>) -> Bool:
  match a:
    case Nil{}:
      match b:
        case Nil{}: True{}
        case Con{h, t}: False{}
    case Con{+ha, ta}:
      match b:
        case Nil{}: False{}
        case Con{+hb, tb}: Bool.and(U32.is_eq(ha, hb), same(ta, tb))

def case_line(label: String, +len: U32, +limit: U32) -> String:
  label ++ "=" ++ Bool.show(same(fast_root(len, limit, gen(U32.to_nat(len), len, [])),
    legacy_root(U32.to_nat(len), limit, gen(U32.to_nat(len), len, []))))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(case_line("len0_lim1", 0, 1))
    IO.print(case_line("len1_lim1", 1, 1))
    IO.print(case_line("len32_lim1", 32, 1))
    IO.print(case_line("len33_lim2", 33, 2))
    IO.print(case_line("len64_lim2", 64, 2))
    IO.print(case_line("len64_lim4", 64, 4))
    IO.print(case_line("len96_lim3", 96, 3))
    IO.print(case_line("len100_lim8", 100, 8))
    IO.print(case_line("len160_lim5", 160, 5))
    IO.print(case_line("len1000_lim32", 1000, 32))
    IO.print(case_line("len2048_lim64", 2048, 64))
    IO.print(case_line("len2049_lim1024", 2049, 1024))
