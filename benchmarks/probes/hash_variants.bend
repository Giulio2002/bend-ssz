import Base
import 0xe4067e0d858024083f36a7abe7281e89/src/crypto/sha/packed/sha256.bend as PKG
import ../../src/digest.bend as D

# Chained Merkle-node hashing, two ways of feeding the pinned package:
#   nodes    message built from nested ANode constructors, result read by
#            matching the ANode shape (the previous src/digest.bend)
#   indexed  message built by Array.new + sixteen Array.set, result read by
#            eight Array.get - what src/digest.bend now does; the native
#            runtime copies blocks on ANode construction and matching, and
#            does not on get/set
# Both chains must end on the same digest.
#
# Measured 2026-09-21: nodes 76 ms, indexed 52 ms for 200,000 nodes.

def words16(+a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32,
            +b0: U32, +b1: U32, +b2: U32, +b3: U32, +b4: U32, +b5: U32, +b6: U32, +b7: U32) -> Array<U32>:
  ANode{ANode{ANode{ANode{ALeaf{a0}, ALeaf{a1}}, ANode{ALeaf{a2}, ALeaf{a3}}},
              ANode{ANode{ALeaf{a4}, ALeaf{a5}}, ANode{ALeaf{a6}, ALeaf{a7}}}},
        ANode{ANode{ANode{ALeaf{b0}, ALeaf{b1}}, ANode{ALeaf{b2}, ALeaf{b3}}},
              ANode{ANode{ALeaf{b4}, ALeaf{b5}}, ANode{ALeaf{b6}, ALeaf{b7}}}}}

def node_words(l: D.Digest, r: D.Digest) -> Array<U32>:
  match l:
    case D.D{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7}:
      match r:
        case D.D{+b0, +b1, +b2, +b3, +b4, +b5, +b6, +b7}:
          words16(a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7)

def fold_array(a: Array<U32>) -> U32:
  match a:
    case ALeaf{+x}: x
    case ANode{xs, ys}: (fold_array(xs) .^. fold_array(ys) : U32)

def zero_after(+x: U32) -> D.Digest: D.zero()

def node_digest(a: Array<U32>) -> D.Digest:
  match a:
    case ANode{ANode{ANode{ALeaf{+w0}, ALeaf{+w1}}, ANode{ALeaf{+w2}, ALeaf{+w3}}},
               ANode{ANode{ALeaf{+w4}, ALeaf{+w5}}, ANode{ALeaf{+w6}, ALeaf{+w7}}}}:
      D.D{w0, w1, w2, w3, w4, w5, w6, w7}
    case _: zero_after(fold_array(a))

def node_result(r: Maybe<&1, Array<U32>>) -> D.Digest:
  match r:
    case None{}: D.zero()
    case Some{a}: node_digest(a)

def hash_nodes(l: D.Digest, r: D.Digest) -> D.Digest: node_result(PKG.sha256(node_words(l, r), 64n))

def hash_indexed(l: D.Digest, r: D.Digest) -> D.Digest: D.hash_pair(l, r)

def chain_cur(+k: Nat, +d: D.Digest) -> D.Digest:
  match k:
    case 0n: d
    case 1n+p: chain_cur(p, hash_nodes(d, d))

def chain_idx(+k: Nat, +d: D.Digest) -> D.Digest:
  match k:
    case 0n: d
    case 1n+p: chain_idx(p, hash_indexed(d, d))

def w0(d: D.Digest) -> U32:
  match d:
    case D.D{+a, b, c, e, f, g, h, i}: a

def n() -> Nat: Nat.mul(1000n, 200n)

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("nodes=" ++ U32.show(w0(chain_cur(n(), D.D{1, 2, 3, 4, 5, 6, 7, 8}))))
    +t1 : Nat <- IO.now()
    IO.print("indexed=" ++ U32.show(w0(chain_idx(n(), D.D{1, 2, 3, 4, 5, 6, 7, 8}))))
    t2 : Nat <- IO.now()
    IO.print("nodes_ms=" ++ Nat.show(Nat.sub(t1, t0)) ++ " indexed_ms=" ++ Nat.show(Nat.sub(t2, t1)))
