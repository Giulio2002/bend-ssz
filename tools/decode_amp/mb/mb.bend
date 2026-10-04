import Base
import ../../../src/obj.bend as O
import ../../../benchmarks/compact/objio.bend as IOx

type Seq is Type:
  Seq{arr: Array<O.Boxed<O.Words>>, n: U32}

def elem(+c: U32) -> O.Boxed<O.Words>:
  match c:
    case 0: O.BNone{}
    case 1: O.BSome{O.Words{Array.new(U32, 0n, 0), 0}, O.BNone{}}
    case 2: O.BSome{O.Words{O.zeros_for(0), 0}, O.BNone{}}
    case _: O.BSome{O.Words{Array.new(U32, 0n, 0), 0}, O.BNone{}}

def fill(+d: Nat) -> Array<O.Boxed<O.Words>>:
  match d:
    case 0n: ALeaf{O.BNone{}}
    case 1n+q: ANode{fill(q), fill(q)}

def go(+k: Nat, +c: U32, +i: U32, arr: Array<O.Boxed<O.Words>>) -> Array<O.Boxed<O.Words>>:
  match k:
    case 0n: arr
    case 1n+p: go(p, c, (i + 1 : U32), Array.set(O.Boxed<O.Words>, arr, i, elem(c)))

def fin(pair: Array<O.Boxed<O.Words>> & U32) -> IO(Unit):
  (a, +n) = pair
  IO.print("N=" ++ U32.show(n))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +d : U32 <- IOx.env_u32("SSZ_D")
    fin(Array.size(O.Boxed<O.Words>, go(U32.to_nat(O.pow2u(U32.to_nat(d))), c, 0, fill(U32.to_nat(d)))))
