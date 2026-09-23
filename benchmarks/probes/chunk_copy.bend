import Base
import ../../src/obj.bend as O
import ../compact/objio.bend as IOx

# Would a wider array element beat the word copy?
#
# The encoder's cost is one `Array.get` plus one `Array.set` per 32-bit word
# (benchmarks/probes/copy_floor.bend: 0.73 ns/word for a bare load/store loop,
# 0.97 ns/word for `O.put_words`). Go's whole serialize is 0.245 ns/word, so
# the word copy alone is about 4x the entire reference operation. The only way
# to move more bytes per array interaction is a wider element.
#
# This measures the three shapes that matter, all moving SSZ_N words:
#
#   SSZ_MODE 0  Array<U32>  load/store per word                (today)
#   SSZ_MODE 1  Array<C8>   load/store per 32-byte chunk, chunk aligned
#   SSZ_MODE 2  Array<C8>   load, take the eight words apart, rebuild, store
#               (what a chunk copy at an unaligned byte offset has to do)
#
# Mode 1 is the best case (the destination chunk boundary coincides with the
# source's); mode 2 is the general case. Every mode reads a word of its result
# so nothing can be left unevaluated.

type C8 is Data:
  C8{w0: U32, w1: U32, w2: U32, w3: U32, w4: U32, w5: U32, w6: U32, w7: U32}

def word_of(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def first_word(a: Array<U32>) -> U32: word_of(Array.get(U32, a, 0))

def c8_of(pair: Array<C8> & C8) -> Array<C8> & U32:
  (a, c) = pair
  match c:
    case C8{+w0, w1, w2, w3, w4, w5, w6, w7}: (a, w0)

def first_chunk(a: Array<C8>) -> Array<C8> & U32: c8_of(Array.get(C8, a, 0))

def c8_zero() -> C8: C8{0, 0, 0, 0, 0, 0, 0, 0}

# ---- mode 0: the word copy ----

def w_go(+k: Nat, +j: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:
  match k:
    case 0n:
      (ws, +w) = pair
      (Array.set(U32, out, j, w), ws)
    case 1n+p:
      (ws, +w) = pair
      w_go(p, (j + 1 : U32), Array.set(U32, out, j, w), Array.get(U32, ws, (j + 1 : U32)))

def w_fin(pair: Array<U32> & Array<U32>) -> U32:
  (out, ws) = pair
  (first_word(out) .^. first_word(ws) : U32)

def w_one(+n: U32, +d: Nat) -> U32:
  w_fin(w_go(U32.to_nat((n - 1 : U32)), 0, Array.new(U32, d, 0), Array.get(U32, Array.new(U32, d, 7), 0)))

def wloop(+k: Nat, +n: U32, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. w_one(n, d) : U32)
    case 1n+p: wloop(p, n, d, (acc .^. w_one(n, d) : U32))

# ---- mode 1: whole chunks, aligned ----

def c_go(+k: Nat, +j: U32, out: Array<C8>, pair: Array<C8> & C8) -> Array<C8> & Array<C8>:
  match k:
    case 0n:
      (ws, c) = pair
      (Array.set(C8, out, j, c), ws)
    case 1n+p:
      (ws, c) = pair
      c_go(p, (j + 1 : U32), Array.set(C8, out, j, c), Array.get(C8, ws, (j + 1 : U32)))

def c_fin3(+x: U32, pair: Array<C8> & U32) -> U32:
  (ws, +y) = pair
  (x .^. y : U32)

def c_fin2(pair: Array<C8> & U32, ws: Array<C8>) -> U32:
  (out, +x) = pair
  c_fin3(x, first_chunk(ws))

def c_fin(pair: Array<C8> & Array<C8>) -> U32:
  (out, ws) = pair
  c_fin2(first_chunk(out), ws)

def c_one(+nc: U32, +d: Nat) -> U32:
  c_fin(c_go(U32.to_nat((nc - 1 : U32)), 0, Array.new(C8, d, c8_zero()),
    Array.get(C8, Array.new(C8, d, C8{7, 7, 7, 7, 7, 7, 7, 7}), 0)))

def cloop(+k: Nat, +nc: U32, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. c_one(nc, d) : U32)
    case 1n+p: cloop(p, nc, d, (acc .^. c_one(nc, d) : U32))

# ---- mode 2: chunks taken apart and rebuilt ----
# One 32-byte chunk written at a byte offset that is not a multiple of 32 needs
# every word shifted across its neighbour, so the chunk is opened, its words
# are combined, and a new chunk is built. `s` is a whole-word shift here, which
# is the cheapest version of that work.

def shift_chunk(+c: C8, +carry: U32) -> C8:
  match c:
    case C8{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      C8{carry, w0, w1, w2, w3, w4, w5, w6}

def chunk_w7(+c: C8) -> U32:
  match c:
    case C8{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}: w7

def m_go(+k: Nat, +j: U32, +carry: U32, out: Array<C8>, pair: Array<C8> & C8) -> Array<C8> & Array<C8>:
  match k:
    case 0n:
      (ws, +c) = pair
      (Array.set(C8, out, j, shift_chunk(c, carry)), ws)
    case 1n+p:
      (ws, +c) = pair
      m_go(p, (j + 1 : U32), chunk_w7(c), Array.set(C8, out, j, shift_chunk(c, carry)),
        Array.get(C8, ws, (j + 1 : U32)))

def m_one(+nc: U32, +d: Nat) -> U32:
  c_fin(m_go(U32.to_nat((nc - 1 : U32)), 0, 0, Array.new(C8, d, c8_zero()),
    Array.get(C8, Array.new(C8, d, C8{7, 7, 7, 7, 7, 7, 7, 7}), 0)))

def mloop(+k: Nat, +nc: U32, +d: Nat, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. m_one(nc, d) : U32)
    case 1n+p: mloop(p, nc, d, (acc .^. m_one(nc, d) : U32))

# ---- driver ----

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def pick(+mode: U32, +k: Nat, +n: U32, +d: Nat, +dc: Nat) -> U32:
  match mode:
    case 0: wloop(k, n, d, 0)
    case 1: cloop(k, U32.shrn(n, 3n), dc, 0)
    case _: mloop(k, U32.shrn(n, 3n), dc, 0)

def run(+mode: U32, +ops: U32, +n: U32, +d: U32) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, pick(mode, U32.to_nat((ops - 1 : U32)), n, U32.to_nat(d), U32.to_nat((d - 3 : U32))))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    +n : U32 <- IOx.env_u32("SSZ_N")
    +d : U32 <- IOx.env_u32("SSZ_D")
    run(mode, ops, n, d)
