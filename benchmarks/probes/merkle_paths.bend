import Base
import ../../src/digest.bend as Dg
import ../../src/tree.bend as Tree
import ../../src/primitives.bend as P

# Merkleizing the same 32,768 chunks two ways on the native C backend: the
# current list-of-byte-lists path in src/tree.bend, and a streaming fold over
# eight-word chunk records. Leaves are generated from the index so neither side
# can hoist the leaf data, and both fold the resulting root so nothing is left
# unforced.

def leaf_word(+i: U32, +j: U32) -> U32: (i .^. U32.shln(j, 16n) : U32)

def leaf_digest(+i: U32) -> Dg.Digest:
  Dg.D{leaf_word(i, 0), leaf_word(i, 1), leaf_word(i, 2), leaf_word(i, 3),
       leaf_word(i, 4), leaf_word(i, 5), leaf_word(i, 6), leaf_word(i, 7)}

def leaf_bytes(+i: U32) -> +List<U32>: Dg.bytes(leaf_digest(i))

# Streaming: consume a perfect subtree of the given depth straight from the
# index generator; no chunk sequence is ever materialised.
def stream_go(+depth: Nat, +i: U32) -> Dg.Digest:
  match depth:
    case 0n: leaf_digest(i)
    case 1n+p:
      Dg.hash_pair(stream_go(p, i), stream_go(p, (i + U32.shln(1, p) : U32)))

def legacy_leaves(+n: Nat, +i: U32, acc: +List<+List<U32>>) -> +List<+List<U32>>:
  match n:
    case 0n: acc
    case 1n+p: legacy_leaves(p, (i - 1 : U32), leaf_bytes((i - 1 : U32)) <> acc)

def fold_bytes(xs: +List<U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: fold_bytes(t, (acc .^. h : U32))

def root_sum(r: Maybe<&2, +List<U32>>) -> U32:
  match r:
    case None{}: 1
    case Some{root}: fold_bytes(root, 0)

def legacy_root(+depth: Nat, +n: Nat) -> U32:
  root_sum(Tree.merkleize_at_depth(depth, legacy_leaves(n, U32.from_nat(n), [])))

def digest_sum(d: Dg.Digest) -> U32:
  match d:
    case Dg.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      (w0 .^. w1 .^. w2 .^. w3 .^. w4 .^. w5 .^. w6 .^. w7 : U32)

def compact_root(+depth: Nat) -> U32: digest_sum(stream_go(depth, 0))

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("LEGACY=" ++ U32.show(legacy_root(15n, 32768n)))
    t1 : Nat <- IO.now()
    IO.print("LEGACY_MS=" ++ Nat.show(Nat.sub(t1, t0)))
    t2 : Nat <- IO.now()
    IO.print("COMPACT=" ++ U32.show(compact_root(15n)))
    t3 : Nat <- IO.now()
    IO.print("COMPACT_MS=" ++ Nat.show(Nat.sub(t3, t2)))
