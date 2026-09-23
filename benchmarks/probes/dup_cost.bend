import Base
import ../../src/obj.bend as O
import ../compact/objio.bend as IOx

# A container has to write a field and also hand the field back, because the
# object is returned to the caller. Today the generated writers consume the
# value (`b32_put(out, pos, o) -> Array<U32>`), so the container marks the
# field duplicable and keeps the second copy. A sampling profile of
# BeaconBlock.serialize attributes 28.5% of the run to `term_drop`, which is
# what collecting those duplicates costs.
#
# The alternative is to thread the value: the writer takes it linearly, takes
# it apart to write it, and rebuilds it for the caller. This measures the two
# shapes on a 32-byte record, which is the commonest field in the schema.
#
#   SSZ_MODE 0  duplicate the record, write one copy, keep the other (today)
#   SSZ_MODE 1  thread the record: write it and give it back
#   SSZ_MODE 2  write only, never give the record back (the floor)
#
# SSZ_N records per iteration, all at aligned positions in one array.

type R8 is Data:
  R8{w0: U32, w1: U32, w2: U32, w3: U32, w4: U32, w5: U32, w6: U32, w7: U32}

def r8_seed(+x: U32) -> R8: R8{x, x, x, x, x, x, x, x}

def word_of(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def first_word(a: Array<U32>) -> U32: word_of(Array.get(U32, a, 0))

# ---- write only: consumes the record, returns the array ----

def r8_put(out: Array<U32>, +q: U32, o: R8) -> Array<U32>:
  match o:
    case R8{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32,
        Array.set(U32, Array.set(U32, Array.set(U32, out, (q + 0 : U32), w0),
        (q + 1 : U32), w1), (q + 2 : U32), w2), (q + 3 : U32), w3),
        (q + 4 : U32), w4), (q + 5 : U32), w5), (q + 6 : U32), w6), (q + 7 : U32), w7)

# ---- write and give the record back ----

def r8_put_keep(out: Array<U32>, +q: U32, o: R8) -> Array<U32> & R8:
  match o:
    case R8{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      (Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32,
        Array.set(U32, Array.set(U32, Array.set(U32, out, (q + 0 : U32), w0),
        (q + 1 : U32), w1), (q + 2 : U32), w2), (q + 3 : U32), w3),
        (q + 4 : U32), w4), (q + 5 : U32), w5), (q + 6 : U32), w6), (q + 7 : U32), w7),
       R8{w0, w1, w2, w3, w4, w5, w6, w7})

# ---- mode 0: the field is duplicated, one copy written, one kept ----

def dup_go(+k: Nat, +q: U32, out: Array<U32>, +o: R8) -> Array<U32> & R8:
  match k:
    case 0n: (r8_put(out, q, o), o)
    case 1n+p: dup_go(p, (q + 8 : U32), r8_put(out, q, o), o)

def r8_w0(o: R8) -> U32:
  match o:
    case R8{+w0, w1, w2, w3, w4, w5, w6, w7}: w0

def dup_fin(pair: Array<U32> & R8) -> U32:
  (out, o) = pair
  (first_word(out) .^. r8_w0(o) : U32)

def dup_one(+n: U32, +d: Nat) -> U32:
  dup_fin(dup_go(U32.to_nat((n - 1 : U32)), 0, Array.new(U32, d, 0), r8_seed(7)))

def dloop(+k: Nat, +n: U32, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. dup_one(n, d) : U32)
    case 1n+p: dloop(p, n, d, (acc .^. dup_one(n, d) : U32))

# ---- mode 1: the field is threaded ----

def thr_go(+k: Nat, +q: U32, pair: Array<U32> & R8) -> Array<U32> & R8:
  match k:
    case 0n:
      (out, o) = pair
      r8_put_keep(out, q, o)
    case 1n+p:
      (out, o) = pair
      thr_go(p, (q + 8 : U32), r8_put_keep(out, q, o))

def thr_one(+n: U32, +d: Nat) -> U32:
  dup_fin(thr_go(U32.to_nat((n - 1 : U32)), 0, (Array.new(U32, d, 0), r8_seed(7))))

def tloop(+k: Nat, +n: U32, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. thr_one(n, d) : U32)
    case 1n+p: tloop(p, n, d, (acc .^. thr_one(n, d) : U32))

# ---- mode 2: write only, a fresh record every time ----

def wo_go(+k: Nat, +q: U32, out: Array<U32>) -> Array<U32>:
  match k:
    case 0n: r8_put(out, q, r8_seed(7))
    case 1n+p: wo_go(p, (q + 8 : U32), r8_put(out, q, r8_seed(7)))

def wo_one(+n: U32, +d: Nat) -> U32:
  first_word(wo_go(U32.to_nat((n - 1 : U32)), 0, Array.new(U32, d, 0)))

def wloop(+k: Nat, +n: U32, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. wo_one(n, d) : U32)
    case 1n+p: wloop(p, n, d, (acc .^. wo_one(n, d) : U32))

# ---- driver ----

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def pick(+mode: U32, +k: Nat, +n: U32, +d: Nat) -> U32:
  match mode:
    case 0: dloop(k, n, d, 0)
    case 1: tloop(k, n, d, 0)
    case _: wloop(k, n, d, 0)

def run(+mode: U32, +ops: U32, +n: U32, +d: U32) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, pick(mode, U32.to_nat((ops - 1 : U32)), n, U32.to_nat(d)))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    +n : U32 <- IOx.env_u32("SSZ_N")
    +d : U32 <- IOx.env_u32("SSZ_D")
    run(mode, ops, n, d)
