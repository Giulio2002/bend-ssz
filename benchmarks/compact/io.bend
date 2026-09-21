import Base
import ../../src/buffer.bend as B

# Shared plumbing for the compact benchmark programs: read SSZ_INPUT into a
# packed buffer in 64 KiB pieces, read integer settings from the environment,
# and print the result lines benchmarks/run.py parses. Reading is outside every
# timed region.

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
