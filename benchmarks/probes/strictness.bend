import Base
import ../../src/digest.bend as D

# Are values stored with Array.set evaluated when stored, or only when read?
# Store k expensive values (one SHA-256 node each) and read only the last one.
# Strict storage costs k hashes; lazy storage costs one.

def w0(d: D.Digest) -> U32:
  match d:
    case D.D{+a, b, c, e, f, g, h, i}: a

def costly(+i: U32) -> U32: w0(D.hash_pair(D.D{i, 0, 0, 0, 0, 0, 0, 0}, D.zero()))

def fill(+k: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match k:
    case 0n: a
    case 1n+p: fill(p, (i + 1 : U32), Array.set(U32, a, i, costly(i)))

def last(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("LAST=" ++ U32.show(last(Array.get(U32, fill(20000n, 0, Array.new(U32, 15n, 0)), 19999))))
    +t1 : Nat <- IO.now()
    IO.print("FILL_20000_MS=" ++ Nat.show(Nat.sub(t1, t0)))
    IO.print("ONE_HASH_EACH=" ++ U32.show(costly(1)))
