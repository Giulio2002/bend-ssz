import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/objio.bend as IOx

# Is the benchmark's sum type the cost? The same decode and encode of one
# BlobIdentifier, called directly on the typed API instead of through the
# group program's Any wrapper (whose layout is as wide as its widest member).

def keep(m: Maybe<&1, T.BlobIdentifier>) -> U32:
  match m:
    case None{}: 0
    case Some{+v}: T.BlobIdentifier_force(v)

def dec_one(+size: U32, pair: B.Buf & Maybe<&1, T.BlobIdentifier>) -> B.Buf & U32:
  (buf, m) = pair
  (buf, keep(m))

def dloop(+k: Nat, +acc: U32, +size: U32, pair: B.Buf & U32) -> B.Buf & U32:
  match k:
    case 0n: pair
    case 1n+p:
      (buf, +x) = pair
      dloop(p, (acc .^. x : U32), size, dec_one(size, T.BlobIdentifier_decode(buf, size)))

def word_of(pair: B.Buf & U32) -> U32:
  (b, +w) = pair
  w

def consume(out: B.Buf) -> U32: word_of(B.word(out, 0))

def eloop(+k: Nat, +acc: U32, +v: T.BlobIdentifier) -> U32:
  match k:
    case 0n: acc
    case 1n+p: eloop(p, (acc .^. consume(T.BlobIdentifier_encode(v)) : U32), v)

def rloop(+k: Nat, +acc: U32, +v: T.BlobIdentifier, pair: B.Buf & D.Digest) -> B.Buf & U32:
  match k:
    case 0n:
      (h, d) = pair
      (h, (acc .^. IOx.fold(d) : U32))
    case 1n+p:
      (h, d) = pair
      rloop(p, (acc .^. IOx.fold(d) : U32), v, T.BlobIdentifier_hash_tree_root(h, v))

def show_dec(+t0: Nat, pair: B.Buf & U32) -> IO(Unit):
  (buf, +acc) = pair
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("DECODE_MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def show_enc(+t0: Nat, +acc: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("ENCODE_MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def show_root(+t0: Nat, pair: B.Buf & U32) -> IO(Unit):
  (h, +acc) = pair
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("ROOT_MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))

def value() -> T.BlobIdentifier:
  T.BlobIdentifier{T.Bytes32{1, 2, 3, 4, 5, 6, 7, 8}, O.U64{9, 10}}

def phases(+ops: U32, +size: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    show_dec(t0, dloop(U32.to_nat(ops), 0, size, (buf, 0)))
    t1 : Nat <- IO.now()
    show_enc(t1, eloop(U32.to_nat(ops), 0, value()))
    t2 : Nat <- IO.now()
    show_root(t2, rloop(U32.to_nat(ops), 0, value(), T.BlobIdentifier_hash_tree_root(O.hasher(), value())))

def with_input(+ops: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  phases(ops, size, buf)

def main() -> IO(Unit):
  do IO<Unit>:
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    input : B.Buf & U32 <- IOx.load()
    with_input(ops, input)
