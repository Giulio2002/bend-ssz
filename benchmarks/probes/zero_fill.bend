import Base
import ../compact/objio.bend as IOx

# Two ways to allocate a zero-filled Array<U32> of 2^d words, each consuming a
# word of the result so no allocation is left unevaluated:
#   SSZ_MODE 0  Array.new(U32, d, 0)             (one element write per word)
#   SSZ_MODE 1  Array.new at depth 4, then d-4 doublings: Array.clone plus
#               ANode{a, b}, which the native backend emits as block copies
#   SSZ_MODE 2  as 1 but from depth 8

def word_of(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def first_word(a: Array<U32>) -> U32: word_of(Array.get(U32, a, 0))

def node_of(pair: Array<U32> & Array<U32>) -> Array<U32>:
  (a, b) = pair
  ANode{a, b}

def dbl(+k: Nat, a: Array<U32>) -> Array<U32>:
  match k:
    case 0n: a
    case 1n+q: dbl(q, node_of(Array.clone(U32, a)))

def zeros(+base: Nat, +d: Nat) -> Array<U32>: dbl(Nat.sub(d, base), Array.new(U32, base, 0))

def one(+mode: U32, +d: Nat) -> U32:
  match mode:
    case 0: first_word(Array.new(U32, d, 0))
    case 1: first_word(zeros(4n, d))
    case _: first_word(zeros(8n, d))

def loop(+k: Nat, +mode: U32, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. one(mode, d) : U32)
    case 1n+p: loop(p, mode, d, (acc .^. one(mode, d) : U32))

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def run(+mode: U32, +ops: U32, +d: U32) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, loop(U32.to_nat((ops - 1 : U32)), mode, U32.to_nat(d), 0))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    +d : U32 <- IOx.env_u32("SSZ_N")
    run(mode, ops, d)
