import Base

# Scanner-style position arithmetic in U32 and in Nat: a window walk that adds,
# subtracts and compares at every step. Both loops do the same work; the
# question is whether Nat positions cost more than U32 ones in native C.

def su(ok: Bool, +x: U32, +y: U32) -> U32:
  match ok:
    case True{}: x
    case False{}: y

def wu(+k: Nat, +a: U32, +b: U32, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p:
      +len = (b - a : U32)
      +ok = U32.is_le(len, 4096)
      wu(p, su(ok, ((a + 3 : U32) .&. 1023 : U32), 0), su(ok, (((b + 1 : U32) .&. 4095 : U32) + 1024 : U32), 2048), (acc + su(ok, len, 0) : U32))

def sn(ok: Bool, +x: Nat, +y: Nat) -> Nat:
  match ok:
    case True{}: x
    case False{}: y

def wn(+k: Nat, +a: Nat, +b: Nat, +acc: Nat) -> Nat:
  match k:
    case 0n: acc
    case 1n+p:
      +len = Nat.sub(b, a)
      +ok = Nat.is_le(len, 4096n)
      wn(p, sn(ok, Nat.mod(Nat.add(a, 3n), 1024n), 0n), sn(ok, Nat.add(Nat.mod(Nat.add(b, 1n), 4096n), 1024n), 2048n), Nat.mod(Nat.add(acc, sn(ok, len, 0n)), 65536n))

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("U=" ++ U32.show(wu(Nat.mul(1000n, 10000n), 0, 2048, 0)))
    +t1 : Nat <- IO.now()
    IO.print("N=" ++ Nat.show(wn(Nat.mul(1000n, 10000n), 0n, 2048n, 0n)))
    t2 : Nat <- IO.now()
    IO.print("u32_ms=" ++ Nat.show(Nat.sub(t1, t0)) ++ " nat_ms=" ++ Nat.show(Nat.sub(t2, t1)))
