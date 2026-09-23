import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/objio.bend as IOx

# How close is the encoder's word copy to the floor this runtime allows?
#
# Every mode moves or writes SSZ_N words and then reads one word of the result,
# so none of the work can be left unevaluated (an unobserved `Array.set` chain
# is never rewritten). The allocation is inside every mode, so the modes differ
# only in what they do to the array.
#
#   SSZ_MODE 0  allocate only                      (the zero fill)
#   SSZ_MODE 1  allocate + a bare store loop       (one array op per word)
#   SSZ_MODE 2  allocate + a load/store loop       (two array ops per word)
#   SSZ_MODE 3  allocate + O.put_words, aligned    (what an encode does)
#   SSZ_MODE 4  allocate + O.put_words at byte 1   (the unaligned run)
#   SSZ_MODE 5  Array.clone of an n-word array     (a whole-block copy, if the
#               runtime has one: nothing in the SSZ path can use it, but it
#               bounds what block copying costs here)
#   SSZ_MODE 6  a load/store loop with separate source and destination indices
#               (what an offset copy needs: two counters instead of one)
#
# Mode 1 is the floor for writing n words at all; mode 2 is the floor for
# copying them from somewhere; mode 3 is what the encoder pays.

def word_of(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def first_word(a: Array<U32>) -> U32: word_of(Array.get(U32, a, 0))

def src_of(+n: U32) -> O.Words: O.Words{Array.new(U32, O.depth_for((4 * n : U32)), 7), (4 * n : U32)}

# ---- mode 0: the allocation alone ----

def alloc_one(+n: U32) -> U32: first_word(O.out_new((4 * n : U32)))

def aloop(+k: Nat, +n: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. alloc_one(n) : U32)
    case 1n+p: aloop(p, n, (acc .^. alloc_one(n) : U32))

# ---- mode 1: a bare store loop ----

def st_go(+k: Nat, +j: U32, out: Array<U32>) -> Array<U32>:
  match k:
    case 0n: Array.set(U32, out, j, j)
    case 1n+p: st_go(p, (j + 1 : U32), Array.set(U32, out, j, j))

def st_one(+n: U32) -> U32:
  first_word(st_go(U32.to_nat((n - 1 : U32)), 0, O.out_new((4 * n : U32))))

def sloop(+k: Nat, +n: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. st_one(n) : U32)
    case 1n+p: sloop(p, n, (acc .^. st_one(n) : U32))

# ---- mode 2: a load/store loop ----

def ld_go(+k: Nat, +j: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  match k:
    case 0n:
      (ws, +w) = pair
      (Array.set(U32, out, j, w), ws)
    case 1n+p:
      (ws, +w) = pair
      ld_go(p, (j + 1 : U32), Array.set(U32, out, j, w), Array.get(U32, ws, (j + 1 : U32)))

def ld_fin(pair: Array<U32> & Array<U32>) -> U32:
  (out, ws) = pair
  (first_word(out) .^. first_word(ws) : U32)

def ld_one(+n: U32, ws: Array<U32>) -> U32:
  ld_fin(ld_go(U32.to_nat((n - 1 : U32)), 0, O.out_new((4 * n : U32)), Array.get(U32, ws, 0)))

def lloop(+k: Nat, +n: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. ld_one(n, Array.new(U32, O.depth_for((4 * n : U32)), 7)) : U32)
    case 1n+p: lloop(p, n, (acc .^. ld_one(n, Array.new(U32, O.depth_for((4 * n : U32)), 7)) : U32))

# ---- mode 5: Array.clone ----

def clone_fin(pair: Array<U32> & Array<U32>) -> U32:
  (a, b) = pair
  (first_word(a) .^. first_word(b) : U32)

def clone_one(+n: U32) -> U32:
  clone_fin(Array.clone(U32, Array.new(U32, O.depth_for((4 * n : U32)), 7)))

def kloop(+k: Nat, +n: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. clone_one(n) : U32)
    case 1n+p: kloop(p, n, (acc .^. clone_one(n) : U32))

# ---- mode 6: an offset copy: two indices ----

def o_go(+k: Nat, +j: U32, +q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  match k:
    case 0n:
      (ws, +w) = pair
      (Array.set(U32, out, q, w), ws)
    case 1n+p:
      (ws, +w) = pair
      o_go(p, (j + 1 : U32), (q + 1 : U32), Array.set(U32, out, q, w), Array.get(U32, ws, (j + 1 : U32)))

def o_one(+n: U32) -> U32:
  ld_fin(o_go(U32.to_nat((n - 1 : U32)), 0, 1, O.out_new((4 * n + 4 : U32)),
    Array.get(U32, Array.new(U32, O.depth_for((4 * n : U32)), 7), 0)))

def oloop(+k: Nat, +n: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. o_one(n) : U32)
    case 1n+p: oloop(p, n, (acc .^. o_one(n) : U32))

# ---- modes 3 and 4: the encoder's own writer ----

def pw_fin(pair: Array<U32> & O.Words) -> U32:
  (out, w) = pair
  match w:
    case O.Words{ws, +n}: (first_word(out) .^. first_word(ws) : U32)

def pw_one(+n: U32, +p: U32) -> U32:
  pw_fin(O.put_words(O.out_new((4 * n + 4 : U32)), p, src_of(n)))

def ploop(+k: Nat, +n: U32, +p: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. pw_one(n, p) : U32)
    case 1n+p2: ploop(p2, n, p, (acc .^. pw_one(n, p) : U32))

# ---- driver ----

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def pick(+mode: U32, +k: Nat, +n: U32) -> U32:
  match mode:
    case 0: aloop(k, n, 0)
    case 1: sloop(k, n, 0)
    case 2: lloop(k, n, 0)
    case 3: ploop(k, n, 0, 0)
    case 4: ploop(k, n, 1, 0)
    case 5: kloop(k, n, 0)
    case _: oloop(k, n, 0)

def run(+mode: U32, +ops: U32, +n: U32) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, pick(mode, U32.to_nat((ops - 1 : U32)), n))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    +n : U32 <- IOx.env_u32("SSZ_N")
    run(mode, ops, n)
