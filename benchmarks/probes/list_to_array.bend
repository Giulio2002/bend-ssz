import Base

# Fill an array from a byte list: the unavoidable conversion at the IO
# boundary, because Base's File.read_bytes yields List<U32>.
def fill(xs: +List<U32>, a: Array<U32>, +i: U32) -> Array<U32>:
  match xs:
    case Nil{}: a
    case Con{h, t}: fill(t, Array.set(U32, a, i, h), U32.add(i, 1))

def scan(+k: Nat, r: Array<U32> & U32, +i: U32, acc: U32) -> Array<U32> & U32:
  match k:
    case 0n:
      (a, v) = r
      (a, U32.add(acc, v))
    case 1n+p:
      (a, v) = r
      scan(p, Array.get(U32, a, i), U32.add(i, 1), U32.add(acc, v))

def build(+k: Nat, acc: +List<U32>) -> +List<U32>:
  match k:
    case 0n: acc
    case 1n+p: build(p, 3 <> acc)

def report(pair: Array<U32> & U32, +fillms: Nat, +scanms: Nat) -> IO(Unit):
  (a, s) = pair
  IO.print("SUM=" ++ U32.show(s) ++ " FILL_MS=" ++ Nat.show(fillms) ++ " SCAN_MS=" ++ Nat.show(scanms))

def phase2(a: Array<U32>, +fillms: Nat) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    r : Array<U32> & U32 = scan(2740473n, (a, 0), 0, 0)
    t1 : Nat <- IO.now()
    report(r, fillms, Nat.sub(t1, t0))

def phase1(+xs: +List<U32>) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    a : Array<U32> = fill(xs, Array.new(U32, 22n, 0), 0)
    t1 : Nat <- IO.now()
    phase2(a, Nat.sub(t1, t0))

def main() -> IO(Unit):
  do IO<Unit>:
    +xs : +List<U32> = build(2740473n, [])
    phase1(xs)
