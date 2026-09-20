import Base

type Rec is Data:
  Leaf{start: Nat, size: Nat}
  Node{a: Rec, b: Rec}

# Build n records in a right-nested chain, as a decoder builds one node per
# decoded child, then fold them to force the whole structure.
def build(+k: Nat, acc: Rec) -> Rec:
  match k:
    case 0n: acc
    case 1n+p: build(p, Node{Leaf{k, k}, acc})

def fold(r: Rec, acc: Nat) -> Nat:
  match r:
    case Leaf{s, n}: Nat.add(acc, n)
    case Node{a, b}: fold(b, fold(a, acc))

def phase(+k: Nat, +t0: Nat) -> IO(Unit):
  do IO<Unit>:
    +r : Rec = build(k, Leaf{0n, 0n})
    +t1 : Nat <- IO.now()
    s : Nat = fold(r, 0n)
    +t2 : Nat <- IO.now()
    IO.print("BUILD_MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " FOLD_MS=" ++ Nat.show(Nat.sub(t2, t1)) ++ " SUM=" ++ Nat.show(s))

def main() -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    phase(200000n, t0)
