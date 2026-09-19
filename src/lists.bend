import Base

# Tail-recursive operations used on potentially large serialized byte strings.
def length_go(-A: Data, xs: +List<A>, acc: Nat) -> Nat:
  match xs:
    case Nil{}: acc
    case Con{h, t}: length_go(A, t, 1n+acc)

def length(-A: Data, xs: +List<A>) -> Nat: length_go(A, xs, 0n)

def append(-A: Data, xs: +List<A>, ys: +List<A>) -> +List<A>:
  List.reverse.go(&2, A, List.reverse(&2, A, xs), ys)

def replicate_go(-A: Data, n: Nat, +x: A, acc: +List<A>) -> +List<A>:
  match n:
    case 0n: acc
    case 1n+p: replicate_go(A, p, x, x <> acc)

def replicate(-A: Data, n: Nat, x: A) -> +List<A>: replicate_go(A, n, x, [])
