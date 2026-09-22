import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../src/digest.bend as D

# Shared IO for the generated object programs (benchmarks/objprog/g*.bend):
# reading the input, the environment settings, writing an encoding out and
# printing the result lines benchmarks/run.py and the conformance checks parse.
# Reading and writing are outside every timed region.

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

def digits(s: String, +acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{+c}, t}: digits(t, (acc * 10 + (c - 48 : U32) : U32))

def env_u32(name: String) -> IO(U32):
  do IO<U32>:
    s : String <- IO.try(String, IO.get_env(name))
    IO.pure(U32, digits(s, 0))

# The input is complete before any clock starts: its last byte depends on
# every piece written into the buffer.
def forced(pair: B.Buf & U32) -> IO(B.Buf):
  (buf, last) = pair
  do IO<B.Buf>:
    IO.print("LAST=" ++ U32.show(last))
    IO.pure(B.Buf, buf)

def loaded(pair: B.Buf & U32) -> IO(B.Buf & U32):
  (buf, +size) = pair
  do IO<B.Buf & U32>:
    live : B.Buf <- forced(B.byte_at(buf, (size - 1 : U32)))
    IO.pure(B.Buf & U32, (live, size))

def load() -> IO(B.Buf & U32):
  do IO<B.Buf & U32>:
    path : String <- IO.try(String, IO.get_env("SSZ_INPUT"))
    got : B.Buf & U32 <- read_all(path)
    loaded(got)

# ---- output ----------------------------------------------------------------

def wrote(pair: File & Result<&1, &1, U32 & String, Unit>) -> IO(File):
  (file, result) = pair
  do IO<File>:
    IO.pass(Unit, result)
    IO.pure(File, file)

def write_piece(file: File, pair: B.Buf & +List<U32>) -> IO(File & B.Buf):
  (buf, data) = pair
  do IO<File & B.Buf>:
    got : File & Result<&1, &1, U32 & String, Unit> <- File.write_bytes(file, data)
    done : File <- wrote(got)
    IO.pure(File & B.Buf, (done, buf))

def write_loop(k: Nat, +w: U32, +words: U32, pair: File & B.Buf) -> IO(File & B.Buf):
  match k:
    case 0n: IO.pure(File & B.Buf, pair)
    case 1n+p:
      (file, buf) = pair
      do IO<File & B.Buf>:
        next : File & B.Buf <- write_piece(file,
          B.emit(buf, w, B.pick(U32.is_le((w + 16384 : U32), words), 16384, (words - w : U32))))
        write_loop(p, (w + 16384 : U32), words, next)

def close_out(pair: File & B.Buf) -> IO(Unit):
  (file, buf) = pair
  File.close(file)

def write_out(out: B.Buf, +size: U32) -> IO(Unit):
  do IO<Unit>:
    path : String <- IO.try(String, IO.get_env("SSZ_OUTPUT"))
    file : File <- IO.try(File, File.open(path, "w"))
    done : File & B.Buf <- write_loop(Nat.div(Nat.add(U32.to_nat(size), 65535n), 65536n), 0,
      U32.shrn((size + 3 : U32), 2n), (file, out))
    close_out(done)

def emit_encoding(pair: B.Buf & U32) -> IO(Unit):
  (out, +n) = pair
  do IO<Unit>:
    IO.print("ENCODED=" ++ U32.show(n))
    write_out(out, n)

def words(d: D.Digest) -> String:
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      U32.show(w0) ++ "," ++ U32.show(w1) ++ "," ++ U32.show(w2) ++ "," ++ U32.show(w3) ++ ","
        ++ U32.show(w4) ++ "," ++ U32.show(w5) ++ "," ++ U32.show(w6) ++ "," ++ U32.show(w7)

def byte_sum(xs: +List<U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{+h, t}: byte_sum(t, (acc + h : U32))

# The checksum of the 32 root bytes, the same one the Go reference prints.
def rootsum(d: D.Digest) -> U32: byte_sum(D.bytes(d), 0)

def fold(d: D.Digest) -> U32:
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      (w0 .^. w1 .^. w2 .^. w3 .^. w4 .^. w5 .^. w6 .^. w7 : U32)

# The last word that actually holds output bytes. Reading word size/4 would be
# one past the end for a size that is a multiple of four, and the output is now
# allocated for exactly ceil(size/4) words.
def last_word(b: B.Buf, +size: U32) -> B.Buf & U32:
  B.word(b, O.pick(U32.is_eq(size, 0), 0, (U32.shrn((size + 3 : U32), 2n) - 1 : U32)))

# The last output word that holds bytes, for consuming an encoding.
def bare(pair: B.Buf & U32) -> U32:
  (b, +w) = pair
  w

def word_out(b: B.Buf, +size: U32) -> U32: bare(last_word(b, size))

def word_out_of(pair: B.Buf & U32) -> U32:
  (b, +n) = pair
  word_out(b, n)
