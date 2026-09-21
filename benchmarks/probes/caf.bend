import Base
import ../../src/digest.bend as D

# Does the native runtime evaluate a closed top-level definition once (and
# share the result), or again at every reference? `chain()` costs 20,000
# hashes; it is referenced 20 times. Evaluated once: ~5 ms. Per reference:
# ~100 ms.

def w0(d: D.Digest) -> U32:
  match d:
    case D.D{+a, b, c, e, f, g, h, i}: a

def go(+k: Nat, +d: D.Digest) -> D.Digest:
  match k:
    case 0n: d
    case 1n+p: go(p, D.hash_pair(d, d))

def chain() -> D.Digest: go(Nat.mul(200n, 100n), D.zero())

def use(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p: use(p, (acc .^. w0(chain()) : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("ACC=" ++ U32.show(use(20n, 0)))
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)))
