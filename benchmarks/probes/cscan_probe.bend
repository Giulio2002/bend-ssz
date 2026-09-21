import Base
import ../../src/buffer.bend as B
import ../../src/cscan.bend as S
import ../../types/fulu_cschema.bend as Spec
import ../../src/cschema.bend as T

# Does the indexed validator accept the real mainnet BeaconState fixtures, and
# how long does it take? The file is read in 64 KiB pieces that are written
# straight into the packed buffer, so the input never exists as a full byte
# list. A truncated copy of the same bytes must be rejected.

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

def show_result(pair: B.Buf & Bool) -> B.Buf & String:
  (buf, ok) = pair
  (buf, Bool.show(ok))

def check_once(schema: T.CS, +size: U32, buf: B.Buf) -> B.Buf & String:
  show_result(S.valid_at(schema, size, buf))

def report(label: String, pair: B.Buf & String) -> IO(B.Buf):
  (buf, text) = pair
  do IO<B.Buf>:
    IO.print(label ++ text)
    IO.pure(B.Buf, buf)

def run_checks(+size: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    b1 : B.Buf <- report("VALID=", check_once(Spec.BeaconState(), size, buf))
    t1 : Nat <- IO.now()
    IO.print("SCAN_MS=" ++ Nat.show(Nat.sub(t1, t0)))
    b2 : B.Buf <- report("TRUNCATED=", check_once(Spec.BeaconState(), (size - 1 : U32), b1))
    b3 : B.Buf <- report("OVERLONG=", check_once(Spec.BeaconState(), (size + 1 : U32), b2))
    IO.print("DROP=" ++ U32.show((B.drop(b3) .&. 0 : U32)))

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  do IO<Unit>:
    IO.print("SIZE=" ++ U32.show(size))
    run_checks(size, buf)

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- read_all("build/native/case_0.ssz")
    with_input(input)
