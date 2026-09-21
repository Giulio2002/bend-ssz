import Base
import ../../src/buffer.bend as B
import ../../src/api.bend as API
import ../../src/digest.bend as D
import ../../types/fulu_cschema_index.bend as Ix
import ../../src/cschema.bend as CS
import ./io.bend as IOx

# hash_tree_root through the compact primary API, SSZ_OPS times on one
# validated buffer. SSZ_INDEX selects the schema (build/cschema-index.json).
# The input is validated once before the clock starts - the root of a value
# that is not a valid encoding is not defined - and a rejected input exits 1.
# Every root is consumed: its eight words are folded into an accumulator
# (ACC). The last root is printed in full (ROOTWORDS, eight big-endian words)
# and as its byte sum (ROOTSUM, the checksum the Go reference prints).

def fold(d: D.Digest) -> U32:
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      (w0 .^. w1 .^. w2 .^. w3 .^. w4 .^. w5 .^. w6 .^. w7 : U32)

def byte_sum(xs: +List<U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{+h, t}: byte_sum(t, (acc + h : U32))

# `pair` holds the previous root; the loop takes k more.
def loop(+k: Nat, +schema: CS.CS, +size: U32, +acc: U32, pair: B.Buf & API.Outcome) -> B.Buf & (U32 & D.Digest):
  match k:
    case 0n:
      (buf, o) = pair
      (buf, (acc, API.root_of(o)))
    case 1n+p:
      (buf, o) = pair
      loop(p, schema, size, (acc .^. fold(API.root_of(o)) : U32), API.run(1, schema, size, buf))

# The last root in full, as its eight big-endian words.
def words(d: D.Digest) -> String:
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      U32.show(w0) ++ "," ++ U32.show(w1) ++ "," ++ U32.show(w2) ++ "," ++ U32.show(w3) ++ ","
        ++ U32.show(w4) ++ "," ++ U32.show(w5) ++ "," ++ U32.show(w6) ++ "," ++ U32.show(w7)

def show(+ms: Nat, r: U32 & D.Digest) -> IO(Unit):
  (+acc, +d) = r
  do IO<Unit>:
    IO.print("MS=" ++ Nat.show(ms) ++ " ACC=" ++ U32.show(acc))
    IO.print("ROOTSUM=" ++ U32.show(byte_sum(D.bytes(d), 0)))
    IO.print("ROOTWORDS=" ++ words(d))

def timed(+t0: Nat, pair: B.Buf & (U32 & D.Digest)) -> IO(Unit):
  (buf, r) = pair
  do IO<Unit>:
    t1 : Nat <- IO.now()
    show(Nat.sub(t1, t0), r)

def gate(ok: Bool, +schema: CS.CS, +size: U32, +ops: U32, buf: B.Buf) -> IO(Unit):
  match ok:
    case False{}: IO.die(Unit, 1, "decode rejected")
    case True{}:
      do IO<Unit>:
        t0 : Nat <- IO.now()
        timed(t0, loop(U32.to_nat((ops - 1 : U32)), schema, size, 0, API.run(1, schema, size, buf)))

def checked(+schema: CS.CS, +size: U32, +ops: U32, pair: B.Buf & API.Outcome) -> IO(Unit):
  (buf, o) = pair
  gate(API.accepted(o), schema, size, ops, buf)

def with_input(+schema: CS.CS, +ops: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  checked(schema, size, ops, API.run(0, schema, size, buf))

def main() -> IO(Unit):
  do IO<Unit>:
    +index : U32 <- IOx.env_u32("SSZ_INDEX")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    input : B.Buf & U32 <- IOx.load()
    with_input(Ix.by_index(index), ops, input)
