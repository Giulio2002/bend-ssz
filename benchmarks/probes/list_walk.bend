import Base

# Same work over a linked list: walk and sum.
def build(+k: Nat, acc: +List<U32>) -> +List<U32>:
  match k:
    case 0n: acc
    case 1n+p: build(p, 7 <> acc)

def sum_list(xs: +List<U32>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: sum_list(t, U32.add(acc, h))

def run(+xs: +List<U32>, +start: Nat) -> IO(Unit):
  do IO<Unit>:
    s : U32 = sum_list(xs, 0)
    stop : Nat <- IO.now()
    IO.print("SUM=" ++ U32.show(s) ++ " MS=" ++ Nat.show(Nat.sub(stop, start)))

def main() -> IO(Unit):
  do IO<Unit>:
    +xs : +List<U32> = build(1048576n, [])
    start : Nat <- IO.now()
    run(xs, start)
