import Base
import ../../src/buffer.bend as B
import ../../src/api.bend as API
import ../../src/digest.bend as D
import ../../src/cschema.bend as CS
import ../../types/fulu_cschema.bend as Spec

# Validate and root the real mainnet BeaconState fixture through the indexed
# runtime, and print the root so it can be compared with the fixture's
# roots.yaml (0xcc7fb85a... for case_0).

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

def show_root(pair: B.Buf & D.Digest) -> B.Buf & String:
  (buf, o) = pair
  (buf, hex_digest(o))

def show_valid(pair: B.Buf & Bool) -> B.Buf & String:
  (buf, o) = pair
  (buf, Bool.show(o))

def report(label: String, pair: B.Buf & String) -> IO(B.Buf):
  (buf, text) = pair
  do IO<B.Buf>:
    IO.print(label ++ text)
    IO.pure(B.Buf, buf)

def run_all(+size: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    b1 : B.Buf <- report("ROOT=", show_root(API.root(Spec.BeaconState(), size, buf)))
    t1 : Nat <- IO.now()
    IO.print("ROOT_MS=" ++ Nat.show(Nat.sub(t1, t0)))
    IO.print("DROP=" ++ U32.show((B.drop(b1) .&. 0 : U32)))

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  do IO<Unit>:
    IO.print("SIZE=" ++ U32.show(size))
    run_all(size, buf)

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- read_all("build/native/input.ssz")
    with_input(input)
