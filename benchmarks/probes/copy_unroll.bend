import Base
import ../compact/objio.bend as IOx

# Word copy between two arrays at an offset: one word per loop iteration
# (mode 0, what src/obj.bend pw_store does) against eight words per iteration
# (mode 1). Every run consumes a word of the destination.

def word_of(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def first_word(a: Array<U32>) -> U32: word_of(Array.get(U32, a, 0))

def pw_store(+k: Nat, +j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  match k:
    case 0n:
      (ws, +w) = pair
      (Array.set(U32, out, (q + j : U32), w), ws)
    case 1n+t:
      (ws, +w) = pair
      pw_store(t, (j + 1 : U32), q, Array.set(U32, out, (q + j : U32), w), Array.get(U32, ws, (j + 1 : U32)))

def pw_c7(+j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (ws, +w) = pair
  (Array.set(U32, out, (q + j + 7 : U32), w), ws)

def pw_c6(+j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (ws, +w) = pair
  pw_c7(j, q, Array.set(U32, out, (q + j + 6 : U32), w), Array.get(U32, ws, (j + 7 : U32)))

def pw_c5(+j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (ws, +w) = pair
  pw_c6(j, q, Array.set(U32, out, (q + j + 5 : U32), w), Array.get(U32, ws, (j + 6 : U32)))

def pw_c4(+j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (ws, +w) = pair
  pw_c5(j, q, Array.set(U32, out, (q + j + 4 : U32), w), Array.get(U32, ws, (j + 5 : U32)))

def pw_c3(+j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (ws, +w) = pair
  pw_c4(j, q, Array.set(U32, out, (q + j + 3 : U32), w), Array.get(U32, ws, (j + 4 : U32)))

def pw_c2(+j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (ws, +w) = pair
  pw_c3(j, q, Array.set(U32, out, (q + j + 2 : U32), w), Array.get(U32, ws, (j + 3 : U32)))

def pw_c1(+j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (ws, +w) = pair
  pw_c2(j, q, Array.set(U32, out, (q + j + 1 : U32), w), Array.get(U32, ws, (j + 2 : U32)))

def pw_c0(+j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (ws, +w) = pair
  pw_c1(j, q, Array.set(U32, out, (q + j + 0 : U32), w), Array.get(U32, ws, (j + 1 : U32)))

def pw_blk8(+k: Nat, +j: U32, +q: U32, pair: Array<U32> & Array<U32>) -> Array<U32> & Array<U32>:
  match k:
    case 0n: pair
    case 1n+t:
      (out, ws) = pair
      pw_blk8(t, (j + 8 : U32), q, pw_c0(j, q, out, Array.get(U32, ws, j)))

def fin(pair: Array<U32> & Array<U32>) -> U32:
  (out, ws) = pair
  (first_word(out) .^. first_word(ws) : U32)

def one(+mode: U32, +n: U32, +d: Nat) -> U32:
  match mode:
    case 0: fin(pw_store(U32.to_nat((n - 1 : U32)), 0, 1, Array.new(U32, d, 0), Array.get(U32, Array.new(U32, d, 7), 0)))
    case _: fin(pw_blk8(U32.to_nat(U32.shrn(n, 3n)), 0, 1, (Array.new(U32, d, 0), Array.new(U32, d, 7))))

def loop(+k: Nat, +mode: U32, +n: U32, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. one(mode, n, d) : U32)
    case 1n+p: loop(p, mode, n, d, (acc .^. one(mode, n, d) : U32))

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def run(+mode: U32, +ops: U32, +n: U32) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, loop(U32.to_nat((ops - 1 : U32)), mode, n, 13n, 0))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    +n : U32 <- IOx.env_u32("SSZ_N")
    run(mode, ops, n)
