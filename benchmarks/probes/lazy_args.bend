import Base
import ../../src/digest.bend as D

# Is a function argument evaluated when the branch that would use it is not
# taken? `sel(False, costly, cheap)` 100,000 times, where costly is one hash.
# Evaluated: ~26 ms. Discarded unevaluated: ~0 ms.

def w0(d: D.Digest) -> U32:
  match d:
    case D.D{+a, b, c, e, f, g, h, i}: a

def sel(c: Bool, x: D.Digest, y: D.Digest) -> D.Digest:
  match c:
    case True{}: x
    case False{}: y

def loop(+k: Nat, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p: loop(p, (acc + w0(sel(False{}, D.hash_pair(D.D{acc, 0, 0, 0, 0, 0, 0, 0}, D.zero()), D.D{1, 0, 0, 0, 0, 0, 0, 0})) : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("ACC=" ++ U32.show(loop(Nat.mul(1000n, 100n), 0)))
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)))
