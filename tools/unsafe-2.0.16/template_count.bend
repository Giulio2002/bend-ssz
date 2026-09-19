import Base

# A structurally terminating template: the self-call shrinks xs.
def len_go(~A: Data, xs: +List<A>, acc: Nat) -> Nat:
  match xs:
    case Nil{}: acc
    case Con{h, t}: len_go(~A, t, 1n+acc)

def a() -> Nat: len_go(~U32, [1, 2], 0n)
def b() -> Nat: len_go(~Bool, [True{}], 0n)
