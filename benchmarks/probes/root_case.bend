import Base
import ../../src/buffer.bend as B
import ../../src/croot.bend as R
import ../../src/digest.bend as D
import ../../types/fulu_cschema_index.bend as Spec

# Root any named Fulu type from a file, so one compiled program can be run
# over the whole official corpus:
#
#   root_case <path> <type index>
#
# prints "ROOT=<64 hex digits>" and the elapsed milliseconds.

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

def hex_nib(+x: U32) -> String:
  match x:
    case 0: "0"
    case 1: "1"
    case 2: "2"
    case 3: "3"
    case 4: "4"
    case 5: "5"
    case 6: "6"
    case 7: "7"
    case 8: "8"
    case 9: "9"
    case 10: "a"
    case 11: "b"
    case 12: "c"
    case 13: "d"
    case 14: "e"
    case _: "f"

def hex_word(+w: U32) -> String:
  hex_nib((U32.shrn(w, 28n) .&. 15 : U32)) ++ hex_nib((U32.shrn(w, 24n) .&. 15 : U32))
    ++ hex_nib((U32.shrn(w, 20n) .&. 15 : U32)) ++ hex_nib((U32.shrn(w, 16n) .&. 15 : U32))
    ++ hex_nib((U32.shrn(w, 12n) .&. 15 : U32)) ++ hex_nib((U32.shrn(w, 8n) .&. 15 : U32))
    ++ hex_nib((U32.shrn(w, 4n) .&. 15 : U32)) ++ hex_nib((w .&. 15 : U32))

def hex_digest(d: D.Digest) -> String:
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      hex_word(w0) ++ hex_word(w1) ++ hex_word(w2) ++ hex_word(w3)
        ++ hex_word(w4) ++ hex_word(w5) ++ hex_word(w6) ++ hex_word(w7)

def keep_text(t: String, +sink: U32) -> String: t

def root_text(pair: B.Buf & D.Digest) -> String:
  (buf, d) = pair
  keep_text(hex_digest(d), B.drop(buf))

def digits(s: String, +acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{+c}, t}: digits(t, (acc * 10 + (c - 48 : U32) : U32))

def run_case(+index: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  do IO<Unit>:
    t0 : Nat <- IO.now()
    IO.print("ROOT=" ++ root_text(R.root(Spec.by_index(index), size, buf)))
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)))

def with_args(args: List<String>) -> IO(Unit):
  match args:
    case Con{path, Con{index, rest}}:
      do IO<Unit>:
        input : B.Buf & U32 <- read_all(path)
        run_case(digits(index, 0), input)
    case _: IO.print("usage: root_case <path> <type index>")

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    with_args(args)
