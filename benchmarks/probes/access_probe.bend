import Base
import ../../src/buffer.bend as B
import ../../src/api.bend as API
import ../../src/access.bend as A
import ../../src/cschema.bend as CS
import ../../types/fulu_cschema.bend as Spec

# Field access, element iteration and encode through the compact API on a real
# BeaconState, printed so benchmarks/checks/access_check.py can compare every value with an
# independent reading of the same bytes. Input: build/native/input.ssz.

def sized(pair: File & Result<&1, &1, U32 & String, U32>) -> IO(File & U32):
  (file, result) = pair
  do IO<File & U32>:
    n : U32 <- IO.pass(U32, result)
    return (file, n)

def piece_into(pair: File & Result<&1, &1, U32 & String, +List<U32>>, +offset: U32, buf: B.Buf) -> IO(B.Buf):
  (file, result) = pair
  do IO<B.Buf>:
    File.close(file)
    piece : +List<U32> <- IO.pass(+List<U32>, result)
    IO.pure(B.Buf, B.fill_at(buf, offset, piece))

def read_loop(k: Nat, +path: String, +offset: U32, +want: U32, buf: B.Buf) -> IO(B.Buf):
  match k:
    case 0n: IO.pure(B.Buf, buf)
    case 1n+p:
      do IO<B.Buf>:
        file : File <- IO.try(File, File.open(path, "r"))
        pair : File & Result<&1, &1, U32 & String, +List<U32>> <- File.read_at(file, offset, want)
        grown : B.Buf <- piece_into(pair, offset, buf)
        read_loop(p, path, (offset + 65536 : U32), want, grown)

def read_sized(+path: String, +size: U32) -> IO(B.Buf):
  read_loop(Nat.div(Nat.add(U32.to_nat(size), 65535n), 65536n), path, 0, 65536, B.alloc(size))

def read_opened(handle: File & U32, +path: String) -> IO(B.Buf & U32):
  (file, +size) = handle
  do IO<B.Buf & U32>:
    File.close(file)
    buf : B.Buf <- read_sized(path, size)
    IO.pure(B.Buf & U32, (buf, size))

def read_all(+path: String) -> IO(B.Buf & U32):
  do IO<B.Buf & U32>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
    got : File & U32 <- sized(pair)
    read_opened(got, path)

# ---------------------------------------------------------------------------
# Combinators over (buffer, view) pairs.

def fld(+s: CS.CS, +i: U32, pair: B.Buf & A.View) -> B.Buf & A.View:
  (b, +v) = pair
  A.field(s, i, v, b)

def elm(+s: CS.CS, +i: U32, pair: B.Buf & A.View) -> B.Buf & A.View:
  (b, +v) = pair
  A.elem(s, i, v, b)

def words_text(w: U32 & U32, +sep: String) -> String:
  (+lo, +hi) = w
  U32.show(lo) ++ sep ++ U32.show(hi)

def lo_text(pair: B.Buf & (U32 & U32)) -> B.Buf & String:
  (b, w) = pair
  (b, words_text(w, ":"))

def u64(pair: B.Buf & A.View) -> B.Buf & String:
  (b, +v) = pair
  lo_text(A.uint64(v, b))

def num(pair: B.Buf & U32) -> B.Buf & String:
  (b, +n) = pair
  (b, U32.show(n))

def cnt(+s: CS.CS, pair: B.Buf & A.View) -> B.Buf & String:
  (b, +v) = pair
  num(A.count(s, v, b))

def span(pair: B.Buf & A.View) -> B.Buf & String:
  (b, +v) = pair
  (b, U32.show(A.view_off(v)) ++ "+" ++ U32.show(A.view_len(v)))

# Element `count - 1` of a sequence view.
def last_of(+s: CS.CS, +v: A.View, pair: B.Buf & U32) -> B.Buf & A.View:
  (b, +n) = pair
  A.elem(s, (n - 1 : U32), v, b)

def last(+s: CS.CS, pair: B.Buf & A.View) -> B.Buf & A.View:
  (b, +v) = pair
  last_of(s, v, A.count(s, v, b))

# Byte sum and length of an encoding.
def bsum(+k: Nat, +i: U32, +acc: U32, pair: B.Buf & U32) -> B.Buf & U32:
  match k pair:
    case 0n Tuple{b, x}: (b, acc)
    case 1n+p Tuple{b, +x}: bsum(p, (i + 1 : U32), (acc + x : U32), B.byte_at(b, (i + 1 : U32)))

def sum_of(+n: U32, pair: B.Buf & U32) -> B.Buf & (U32 & U32):
  (b, +s) = pair
  (b, (s, n))

def enc_len(pair: B.Buf & U32) -> B.Buf & (U32 & U32):
  (b, +n) = pair
  sum_of(n, bsum(U32.to_nat(n), 0, 0, B.byte_at(b, 0)))

def enc_done(b: B.Buf, pair: B.Buf & (U32 & U32)) -> B.Buf & String:
  (out, sn) = pair
  (b, words_text(sn, "/"))

def enc_text(pair: B.Buf & B.Buf) -> B.Buf & String:
  (b, out) = pair
  enc_done(b, enc_len(B.size(out)))

def enc(pair: B.Buf & A.View) -> B.Buf & String:
  (b, +v) = pair
  enc_text(A.encode(v, b))

def report(label: String, pair: B.Buf & String) -> IO(B.Buf):
  (b, text) = pair
  do IO<B.Buf>:
    IO.print(label ++ "=" ++ text)
    IO.pure(B.Buf, b)

def whole(+size: U32, b: B.Buf) -> B.Buf & A.View: (b, A.View{0, size})

def st() -> CS.CS: Spec.BeaconState()

def sch(+i: U32) -> CS.CS: A.field_schema(st(), i)

def queries(+size: U32, b0: B.Buf) -> IO(Unit):
  do IO<Unit>:
    b1 : B.Buf <- report("slot", u64(fld(st(), 2, whole(size, b0))))
    b2 : B.Buf <- report("validators", cnt(sch(11), fld(st(), 11, whole(size, b1))))
    b3 : B.Buf <- report("last_validator_effective_balance",
      u64(fld(Spec.Validator(), 2, last(sch(11), fld(st(), 11, whole(size, b2))))))
    b4 : B.Buf <- report("balances", cnt(sch(12), fld(st(), 12, whole(size, b3))))
    b5 : B.Buf <- report("historical_roots", cnt(sch(7), fld(st(), 7, whole(size, b4))))
    b6 : B.Buf <- report("proposer_lookahead_3", u64(elm(sch(37), 3, fld(st(), 37, whole(size, b5)))))
    b7 : B.Buf <- report("payload_header", span(fld(st(), 24, whole(size, b6))))
    b8 : B.Buf <- report("extra_data", span(fld(sch(24), 10, fld(st(), 24, whole(size, b7)))))
    b9 : B.Buf <- report("payload_header_encoding", enc(fld(st(), 24, whole(size, b8))))
    b10 : B.Buf <- report("eth1_votes", cnt(sch(9), fld(st(), 9, whole(size, b9))))
    IO.print("DONE")

def gate(ok: Bool, +size: U32, b: B.Buf) -> IO(Unit):
  match ok:
    case True{}: queries(size, b)
    case False{}: IO.print("INVALID")

def checked(+size: U32, pair: B.Buf & Bool) -> IO(Unit):
  (b, o) = pair
  gate(o, size, b)

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (b, +size) = pair
  checked(size, API.validate(Spec.BeaconState(), size, b))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- read_all("build/native/input.ssz")
    with_input(input)
