import Base
import ../../src/obj.bend as O
import ../../src/buffer.bend as B
import ../compact/objio.bend as IOx

# What does an encoder's output buffer cost before anything is written to it?
#
# SSZ_MODE 0 times `Array.new(U32, d, 0)` (what O.out_new does) for a depth
# taken from SSZ_D, consuming one word of the result so the allocation cannot
# be dropped. SSZ_MODE 1 times the same allocation plus a word-by-word copy of
# `SSZ_N` words into it, which is what an encode of that many words does. The
# difference is the copy; the first number alone is the zero-fill.

def word_of(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def one(+d: Nat) -> U32: word_of(Array.get(U32, Array.new(U32, d, 0), 0))

def aloop(+k: Nat, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. one(d) : U32)
    case 1n+p: aloop(p, d, (acc .^. one(d) : U32))

def cp(+k: Nat, +j: U32, out: Array<U32>) -> Array<U32>:
  match k:
    case 0n: Array.set(U32, out, j, j)
    case 1n+p: cp(p, (j + 1 : U32), Array.set(U32, out, j, j))

def one_cp(+d: Nat, +n: U32) -> U32:
  word_of(Array.get(U32, cp(U32.to_nat((n - 1 : U32)), 0, Array.new(U32, d, 0)), 0))

def cloop(+k: Nat, +d: Nat, +n: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. one_cp(d, n) : U32)
    case 1n+p: cloop(p, d, n, (acc .^. one_cp(d, n) : U32))

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def pick_acc(+mode: U32, +ops: U32, +d: Nat, +n: U32) -> U32:
  match mode:
    case 0: aloop(U32.to_nat(ops), d, 0)
    case _: cloop(U32.to_nat(ops), d, n, 0)

def run(+mode: U32, +ops: U32, +d: Nat, +n: U32) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, pick_acc(mode, ops, d, n))

def env_u32(name: String) -> IO(U32): IOx.env_u32(name)

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    +d : U32 <- IOx.env_u32("SSZ_D")
    +n : U32 <- IOx.env_u32("SSZ_N")
    run(mode, ops, U32.to_nat(d), n)
