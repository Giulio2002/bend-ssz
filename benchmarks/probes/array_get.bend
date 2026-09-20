import Base

def sum_loop(+k: Nat, r: Array<U32> & U32, +i: U32, acc: U32) -> Array<U32> & U32:
  match k:
    case 0n:
      (a, v) = r
      (a, U32.add(acc, v))
    case 1n+p:
      (a, v) = r
      sum_loop(p, Array.get(U32, a, i), U32.add(i, 1), U32.add(acc, v))

def sized(pair: Array<U32> & U32, +s: U32, +ms: Nat) -> IO(Unit):
  (a, n) = pair
  IO.print("SUM=" ++ U32.show(s) ++ " SIZE=" ++ U32.show(n) ++ " MS=" ++ Nat.show(ms))

def finish(r: Array<U32> & U32, +ms: Nat) -> IO(Unit):
  (a, s) = r
  sized(Array.size(U32, a), s, ms)

def run(a: Array<U32>, +start: Nat) -> IO(Unit):
  do IO<Unit>:
    r : Array<U32> & U32 = sum_loop(1048576n, (a, 0), 0, 0)
    stop : Nat <- IO.now()
    finish(r, Nat.sub(stop, start))

def main() -> IO(Unit):
  do IO<Unit>:
    start : Nat <- IO.now()
    run(Array.new(U32, 20n, 7), start)
