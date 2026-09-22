import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/objio.bend as IOx

# How much of an encode is the size traversal that precedes the write?
#
# `X_encode` is `X_size` (one walk of every variable-size child, to learn how
# big the output must be) followed by `X_putn` (one walk that writes). This
# probe times them separately on a real decoded object, so the split is
# measured rather than argued.
#
#   SSZ_MODE 0  SSZ_OPS x BeaconBlockBody_size
#   SSZ_MODE 1  SSZ_OPS x BeaconBlockBody_encode
#
# SSZ_INPUT is a serialized BeaconBlockBody; its decode is outside the clock.

def out_last(pair: B.Buf & U32) -> U32:
  (b, +n) = pair
  IOx.word_out(b, n)

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

def keep(pair: T.BeaconBlockBody & U32) -> U32:
  (o, +x) = pair
  x

def report(+t0: Nat, pair: T.BeaconBlockBody & U32) -> IO(Unit):
  (o, +acc) = pair
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc)
      ++ " KEEP=" ++ U32.show(keep(T.BeaconBlockBody_force(o))))

def run_size(+ops: U32, o: T.BeaconBlockBody) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, sloop(U32.to_nat(ops), 0, T.BeaconBlockBody_size(o)))

def run_enc(+ops: U32, o: T.BeaconBlockBody) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    report(t0, eloop(U32.to_nat(ops), 0, T.BeaconBlockBody_encode(o)))

def pick_run(+mode: U32, +ops: U32, o: T.BeaconBlockBody) -> IO(Unit):
  match mode:
    case 0: run_size(ops, o)
    case _: run_enc(ops, o)

def with_obj(+mode: U32, +ops: U32, m: Maybe<&1, T.BeaconBlockBody>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "decode rejected")
    case Some{o}: pick_run(mode, ops, o)

def decoded(+mode: U32, +ops: U32, pair: B.Buf & Maybe<&1, T.BeaconBlockBody>) -> IO(Unit):
  (buf, m) = pair
  with_obj(mode, ops, m)

def start(+mode: U32, +ops: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  decoded(mode, ops, T.BeaconBlockBody_decode(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    input : B.Buf & U32 <- IOx.load()
    start(mode, ops, input)
