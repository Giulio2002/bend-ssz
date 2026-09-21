import Base

# What does U32.to_nat cost at runtime? The walkers build their fuel with it
# once per call. Two loops of 100,000 iterations: one converts 320 (a
# Checkpoint's fuel), one converts 0.

def eat(+n: Nat) -> U32:
  match n:
    case 0n: 0
    case 1n+p: 1

def loop(+k: Nat, +x: U32, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p: loop(p, x, (acc + eat(Nat.add(256n, U32.to_nat(x))) : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("A=" ++ U32.show(loop(Nat.mul(1000n, 100n), 320, 0)))
    +t1 : Nat <- IO.now()
    IO.print("B=" ++ U32.show(loop(Nat.mul(1000n, 100n), 0, 0)))
    t2 : Nat <- IO.now()
    IO.print("to_nat_320_ms=" ++ Nat.show(Nat.sub(t1, t0)) ++ " to_nat_0_ms=" ++ Nat.show(Nat.sub(t2, t1)))
