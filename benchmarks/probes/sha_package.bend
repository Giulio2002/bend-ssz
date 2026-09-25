import Base
import ../../vendor/bend_sha256_pkg/sha256.bend as PKG

# Cost of one SSZ Merkle node hash (64 bytes = sixteen packed words) through
# the pinned BendHub package's production array API, on the native C backend.
# The sixteen-word input array is built directly as a perfect tree, which is
# what `Array.new`/`Array.set` would produce, without any list allocation.

def words16(+a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32,
            +b0: U32, +b1: U32, +b2: U32, +b3: U32, +b4: U32, +b5: U32, +b6: U32, +b7: U32) -> Array<U32>:
  ANode{ANode{ANode{ANode{ALeaf{a0}, ALeaf{a1}}, ANode{ALeaf{a2}, ALeaf{a3}}},
              ANode{ANode{ALeaf{a4}, ALeaf{a5}}, ANode{ALeaf{a6}, ALeaf{a7}}}},
        ANode{ANode{ANode{ALeaf{b0}, ALeaf{b1}}, ANode{ALeaf{b2}, ALeaf{b3}}},
              ANode{ANode{ALeaf{b4}, ALeaf{b5}}, ANode{ALeaf{b6}, ALeaf{b7}}}}}

# Consumes the linear digest array and folds every word, so nothing is left
# unforced and the array is not leaked.
def fold_array(a: Array<U32>) -> U32:
  match a:
    case ALeaf{+x}: x
    case ANode{xs, ys}: (fold_array(xs) .^. fold_array(ys) : U32)

def first_word(r: Maybe<&1, Array<U32>>) -> U32:
  match r:
    case None{}: 1
    case Some{a}: fold_array(a)

def digest_head(+x: U32) -> U32:
  first_word(PKG.sha256(words16(x, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15), 64n))

def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, (acc .^. digest_head(acc) : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("X=" ++ U32.show(loop(50000n, 7)))
    t1 : Nat <- IO.now()
    IO.print("PACKAGE_MS=" ++ Nat.show(Nat.sub(t1, t0)))
