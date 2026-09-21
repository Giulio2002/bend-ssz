import Base
import ../../src/buffer.bend as B
import ../../src/api.bend as API
import ../../types/fulu_cschema_index.bend as Ix
import ../../src/cschema.bend as CS
import ./io.bend as IOx

# deserialize through the compact primary API, SSZ_OPS times on one buffer.
# Decode is the in-place validating pass: its result is the validated view, so
# every run does all the work a decode must do (sizes, offsets, list limits,
# boolean bytes, bit-vector padding, bit-list terminators). Every verdict is
# consumed; any rejection exits 1, which is how malformed inputs are reported.

def verdict(ok: Bool) -> U32:
  match ok:
    case True{}: 1
    case False{}: 0

# `pair` holds the previous verdict; the loop takes k more.
def loop(+k: Nat, +schema: CS.CS, +size: U32, +acc: U32, pair: B.Buf & API.Outcome) -> B.Buf & U32:
  match k:
    case 0n:
      (buf, o) = pair
      (buf, (acc + verdict(API.accepted(o)) : U32))
    case 1n+p:
      (buf, o) = pair
      loop(p, schema, size, (acc + verdict(API.accepted(o)) : U32), API.run(0, schema, size, buf))

def report_if(all: Bool, +ms: Nat, +accepted: U32) -> IO(Unit):
  match all:
    case True{}: IO.print("MS=" ++ Nat.show(ms) ++ " ACCEPTED=" ++ U32.show(accepted))
    case False{}: IO.die(Unit, 1, "decode rejected")

def report(+ops: U32, +ms: Nat, +accepted: U32) -> IO(Unit):
  report_if(U32.is_eq(accepted, ops), ms, accepted)

def timed(+ops: U32, +t0: Nat, pair: B.Buf & U32) -> IO(Unit):
  (buf, +accepted) = pair
  do IO<Unit>:
    t1 : Nat <- IO.now()
    report(ops, Nat.sub(t1, t0), accepted)

def with_input(+schema: CS.CS, +ops: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  do IO<Unit>:
    t0 : Nat <- IO.now()
    timed(ops, t0, loop(U32.to_nat((ops - 1 : U32)), schema, size, 0, API.run(0, schema, size, buf)))

def main() -> IO(Unit):
  do IO<Unit>:
    +index : U32 <- IOx.env_u32("SSZ_INDEX")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    input : B.Buf & U32 <- IOx.load()
    with_input(Ix.by_index(index), ops, input)
