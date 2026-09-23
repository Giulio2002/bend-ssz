import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/objio.bend as IOx

# The three parts of one encode, timed separately on a real decoded object.
#
# `X_encode(o)` is `X_size(o)` (learn the output length), `O.out_new(n)` (a
# zero-filled array of ceil(n/4) words) and `X_putn(out, 0, o)` (write). The
# generated `putn` of a container passes the parent's own output array to every
# child, so a nested child writes into the final buffer and is never copied
# again; this probe measures whether that is what the cost actually shows.
#
#   SSZ_MODE 0  SSZ_OPS x BeaconBlockBody_size
#   SSZ_MODE 1  SSZ_OPS x BeaconBlockBody_encode           (size + alloc + put)
#   SSZ_MODE 2  SSZ_OPS x O.out_new(BeaconBlockBody_size)  (the allocation)
#   SSZ_MODE 3  SSZ_OPS x BeaconBlockBody_putn into one reused buffer
#   SSZ_MODE 4  SSZ_OPS x BeaconBlock_size
#   SSZ_MODE 5  SSZ_OPS x BeaconBlock_encode
#   SSZ_MODE 6  SSZ_OPS x O.out_new(BeaconBlock_size)
#   SSZ_MODE 7  SSZ_OPS x BeaconBlock_putn into one reused buffer
#   SSZ_MODE 8  SSZ_OPS x BeaconBlockBody_putn at byte 84 of a buffer 84 bytes
#               longer - the position a BeaconBlock writes its body at, so the
#               only difference from mode 3 is the starting offset
#
# Modes 3 and 7 write into the same array every iteration, so the bytes are
# the OR of every iteration; the work done per iteration is the same as a real
# write, which is what is being measured. Every mode consumes a word of its
# result so nothing can be left unevaluated.

# SSZ_INPUT holds a serialized BeaconBlockBody for modes 0-3 and a serialized
# BeaconBlock for modes 4-7.

# ---- consuming helpers ----

def word_of(pair: Array<U32> & U32) -> U32:
  (a, +w) = pair
  w

def buf_word(pair: B.Buf & U32) -> U32:
  (b, +w) = pair
  w

def out_last(pair: B.Buf & U32) -> U32:
  (b, +n) = pair
  IOx.word_out(b, n)

# ---- BeaconBlockBody ----

def sloop(+k: Nat, +acc: U32, pair: T.BeaconBlockBody & U32) -> T.BeaconBlockBody & U32:
  match k:
    case 0n:
      (o, +n) = pair
      (o, (acc .^. n : U32))
    case 1n+p:
      (o, +n) = pair
      sloop(p, (acc .^. n : U32), T.BeaconBlockBody_size(o))

def eloop(+k: Nat, +acc: U32, pair: T.BeaconBlockBody & B.Buf) -> T.BeaconBlockBody & U32:
  match k:
    case 0n:
      (o, out) = pair
      (o, (acc .^. out_last(B.size(out)) : U32))
    case 1n+p:
      (o, out) = pair
      eloop(p, (acc .^. out_last(B.size(out)) : U32), T.BeaconBlockBody_encode(o))

def aloop(+k: Nat, +n: U32, +acc: U32) -> U32:
  match k:
    case 0n: (acc .^. word_of(Array.get(U32, O.out_new(n), 0)) : U32)
    case 1n+p: aloop(p, n, (acc .^. word_of(Array.get(U32, O.out_new(n), 0)) : U32))

def ploop(+k: Nat, +acc: U32, pair: Array<U32> & (T.BeaconBlockBody & U32)) -> Array<U32> & (T.BeaconBlockBody & U32):
  match k:
    case 0n:
      (out, r) = pair
      (o, n) = r
      (out, (o, (acc .^. n : U32)))
    case 1n+p:
      (out, r) = pair
      (o, n) = r
      ploop(p, (acc .^. n : U32), T.BeaconBlockBody_putn(out, 0, o))

# ---- BeaconBlock ----

def bsloop(+k: Nat, +acc: U32, pair: T.BeaconBlock & U32) -> T.BeaconBlock & U32:
  match k:
    case 0n:
      (o, +n) = pair
      (o, (acc .^. n : U32))
    case 1n+p:
      (o, +n) = pair
      bsloop(p, (acc .^. n : U32), T.BeaconBlock_size(o))

def beloop(+k: Nat, +acc: U32, pair: T.BeaconBlock & B.Buf) -> T.BeaconBlock & U32:
  match k:
    case 0n:
      (o, out) = pair
      (o, (acc .^. out_last(B.size(out)) : U32))
    case 1n+p:
      (o, out) = pair
      beloop(p, (acc .^. out_last(B.size(out)) : U32), T.BeaconBlock_encode(o))

def bploop(+k: Nat, +acc: U32, pair: Array<U32> & (T.BeaconBlock & U32)) -> Array<U32> & (T.BeaconBlock & U32):
  match k:
    case 0n:
      (out, r) = pair
      (o, n) = r
      (out, (o, (acc .^. n : U32)))
    case 1n+p:
      (out, r) = pair
      (o, n) = r
      bploop(p, (acc .^. n : U32), T.BeaconBlock_putn(out, 0, o))

# ---- reporting ----

def report(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def keep_x(+x: U32) -> U32: x

def keep_body(pair: T.BeaconBlockBody & U32) -> U32:
  (o, +x) = pair
  x

def keep_block(pair: T.BeaconBlock & U32) -> U32:
  (o, +x) = pair
  x

def keep_put(pair: Array<U32> & (T.BeaconBlockBody & U32)) -> U32:
  (out, r) = pair
  (o, x) = r
  (keep_x(x) .^. keep_body(T.BeaconBlockBody_force(o)) : U32)

def keep_bput(pair: Array<U32> & (T.BeaconBlock & U32)) -> U32:
  (out, r) = pair
  (o, x) = r
  (keep_x(x) .^. keep_block(T.BeaconBlock_force(o)) : U32)

def run_bsize(+ops: U32, o: T.BeaconBlockBody) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, keep_body(sloop(U32.to_nat((ops - 1 : U32)), 0, T.BeaconBlockBody_size(o))))

def run_benc(+ops: U32, o: T.BeaconBlockBody) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, keep_body(eloop(U32.to_nat((ops - 1 : U32)), 0, T.BeaconBlockBody_encode(o))))

def run_balloc_at(+ops: U32, pair: T.BeaconBlockBody & U32) -> IO(Unit):
  (o, +n) = pair
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, (aloop(U32.to_nat((ops - 1 : U32)), n, 0) .^. keep_body(T.BeaconBlockBody_force(o)) : U32))

def run_bput_at(+ops: U32, +n: U32, o: T.BeaconBlockBody) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, keep_put(ploop(U32.to_nat((ops - 1 : U32)), 0, T.BeaconBlockBody_putn(O.out_new(n), 0, o))))

def run_bput(+ops: U32, pair: T.BeaconBlockBody & U32) -> IO(Unit):
  (o, +n) = pair
  run_bput_at(ops, n, o)

def ploop84(+k: Nat, +acc: U32, pair: Array<U32> & (T.BeaconBlockBody & U32)) -> Array<U32> & (T.BeaconBlockBody & U32):
  match k:
    case 0n:
      (out, r) = pair
      (o, n) = r
      (out, (o, (acc .^. n : U32)))
    case 1n+p:
      (out, r) = pair
      (o, n) = r
      ploop84(p, (acc .^. n : U32), T.BeaconBlockBody_putn(out, 84, o))

def run_bput84_at(+ops: U32, +n: U32, o: T.BeaconBlockBody) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, keep_put(ploop84(U32.to_nat((ops - 1 : U32)), 0, T.BeaconBlockBody_putn(O.out_new((n + 84 : U32)), 84, o))))

def run_bput84(+ops: U32, pair: T.BeaconBlockBody & U32) -> IO(Unit):
  (o, +n) = pair
  run_bput84_at(ops, n, o)

def run_ksize(+ops: U32, o: T.BeaconBlock) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, keep_block(bsloop(U32.to_nat((ops - 1 : U32)), 0, T.BeaconBlock_size(o))))

def run_kenc(+ops: U32, o: T.BeaconBlock) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, keep_block(beloop(U32.to_nat((ops - 1 : U32)), 0, T.BeaconBlock_encode(o))))

def run_kalloc_at(+ops: U32, pair: T.BeaconBlock & U32) -> IO(Unit):
  (o, +n) = pair
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, (aloop(U32.to_nat((ops - 1 : U32)), n, 0) .^. keep_block(T.BeaconBlock_force(o)) : U32))

def run_kput_at(+ops: U32, +n: U32, o: T.BeaconBlock) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, keep_bput(bploop(U32.to_nat((ops - 1 : U32)), 0, T.BeaconBlock_putn(O.out_new(n), 0, o))))

def run_kput(+ops: U32, pair: T.BeaconBlock & U32) -> IO(Unit):
  (o, +n) = pair
  run_kput_at(ops, n, o)

def body_run(+mode: U32, +ops: U32, o: T.BeaconBlockBody) -> IO(Unit):
  match mode:
    case 0: run_bsize(ops, o)
    case 1: run_benc(ops, o)
    case 2: run_balloc_at(ops, T.BeaconBlockBody_size(o))
    case 3: run_bput(ops, T.BeaconBlockBody_size(o))
    case _: run_bput84(ops, T.BeaconBlockBody_size(o))

def block_run(+mode: U32, +ops: U32, o: T.BeaconBlock) -> IO(Unit):
  match mode:
    case 4: run_ksize(ops, o)
    case 5: run_kenc(ops, o)
    case 6: run_kalloc_at(ops, T.BeaconBlock_size(o))
    case _: run_kput(ops, T.BeaconBlock_size(o))

def with_body(+mode: U32, +ops: U32, m: Maybe<&1, T.BeaconBlockBody>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "decode rejected")
    case Some{o}: body_run(mode, ops, o)

def with_block(+mode: U32, +ops: U32, m: Maybe<&1, T.BeaconBlock>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "decode rejected")
    case Some{o}: block_run(mode, ops, o)

def body_decoded(+mode: U32, +ops: U32, pair: B.Buf & Maybe<&1, T.BeaconBlockBody>) -> IO(Unit):
  (buf, m) = pair
  with_body(mode, ops, m)

def block_decoded(+mode: U32, +ops: U32, pair: B.Buf & Maybe<&1, T.BeaconBlock>) -> IO(Unit):
  (buf, m) = pair
  with_block(mode, ops, m)

def start_at(+mode: U32, +ops: U32, +size: U32, buf: B.Buf, body: Bool) -> IO(Unit):
  match body:
    case True{}: body_decoded(mode, ops, T.BeaconBlockBody_decode(buf, size))
    case False{}: block_decoded(mode, ops, T.BeaconBlock_decode(buf, size))

def start(+mode: U32, +ops: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  start_at(mode, ops, size, buf, Bool.or(U32.is_lt(mode, 4), U32.is_eq(mode, 8)))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    input : B.Buf & U32 <- IOx.load()
    start(mode, ops, input)
