import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/objio.bend as IOx

# What does copying a large byte range cost, per word, and how much of that is
# the allocation rather than the loop?
#
# The result is always consumed by reading the last word of the copy, so no
# part of it can be left unevaluated: in an interaction net an unobserved
# `Array.set` chain is never rewritten, which makes a probe that drops its
# result measure nothing.
#
#   SSZ_MODE 0  SSZ_OPS x O.copy_in(buf, 0, SSZ_N)          aligned source
#   SSZ_MODE 1  SSZ_OPS x O.copy_in(buf, 1, SSZ_N)          unaligned source
#   SSZ_MODE 2  SSZ_OPS x Array.new at the same depth       allocation alone
#
# SSZ_N is a byte count; the input file must hold at least SSZ_N + 4 bytes.

def last_of(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

# Reading the last word forces the whole write chain that produced it.
def consume_words(w: O.Words) -> U32:
  match w:
    case O.Words{ws, +n}:
      last_of(Array.get(U32, ws, (U32.shrn((n + 3 : U32), 2n) - 1 : U32)))

def copy_one(+off: U32, +n: U32, pair: B.Buf & O.Words) -> B.Buf & U32:
  (buf, w) = pair
  (buf, consume_words(w))

def cloop(+k: Nat, +off: U32, +n: U32, +acc: U32, pair: B.Buf & U32) -> B.Buf & U32:
  match k:
    case 0n:
      (buf, +x) = pair
      (buf, (acc .^. x : U32))
    case 1n+q:
      (buf, +x) = pair
      cloop(q, off, n, (acc .^. x : U32), copy_one(off, n, O.copy_in(buf, off, n)))

def alloc_one(+d: Nat, +n: U32) -> U32:
  last_of(Array.get(U32, Array.new(U32, d, 0), (U32.shrn((n + 3 : U32), 2n) - 1 : U32)))

def aloop(+k: Nat, +d: Nat, +n: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. alloc_one(d, n) : U32)
    case 1n+q: aloop(q, d, n, (acc .^. alloc_one(d, n) : U32))

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def drop_buf(pair: B.Buf & U32) -> U32:
  (buf, +acc) = pair
  acc

def run_copy(+off: U32, +ops: U32, +n: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, drop_buf(cloop(U32.to_nat((ops - 1 : U32)), off, n, 0,
      copy_one(off, n, O.copy_in(buf, off, n)))))

def run_alloc(+ops: U32, +n: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, aloop(U32.to_nat((ops - 1 : U32)), O.depth_for(n), n, 0))

def pick_run(+mode: U32, +ops: U32, +n: U32, buf: B.Buf) -> IO(Unit):
  match mode:
    case 0: run_copy(0, ops, n, buf)
    case 1: run_copy(1, ops, n, buf)
    case _: run_alloc(ops, n, buf)

def start(+mode: U32, +ops: U32, +n: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  pick_run(mode, ops, n, buf)

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    +n : U32 <- IOx.env_u32("SSZ_N")
    input : B.Buf & U32 <- IOx.load()
    start(mode, ops, n, input)
