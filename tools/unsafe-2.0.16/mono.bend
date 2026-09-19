import Base

def len_go(xs: +List<U32>, acc: Nat) -> Nat:
  match xs:
    case Nil{}: acc
    case Con{h, t}: len_go(t, 1n+acc)

def a() -> Nat: len_go([1, 2], 0n)
