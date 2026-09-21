import Base
import ../src/buffer.bend as B
import ../src/api.bend as API
import ../src/digest.bend as D
import ../types/fulu_cschema.bend as Spec

# Native driver for the compact primary path, speaking the same protocol as
# native_bench/fastssz: SSZ_INPUT, SSZ_OUTPUT, SSZ_PHASES=input|decode|root|all,
# PHASE= markers at every boundary, DECODE_MS / ROOT_MS / SERIALIZE_MS timings
# and a ROOTSUM that must equal Go's.
#
#   read      the fixture goes into the packed buffer in 64 KiB pieces; the
#             input never exists as a byte list in full
#   decode    the primary decode pass validates the whole BeaconState in place;
#             the decoded value is the validated buffer, so nothing else is
#             allocated
#   root      hash_tree_root over the same buffer
#   serialize the value's encoding is streamed from the buffer to SSZ_OUTPUT
#             one 64 KiB piece at a time, read by index; SERIALIZE_MS includes
#             the writes, which Go's SERIALIZE_NS does not
#
# Every phase ends with a settle window so the harness can take an idle
# reading, and every boundary can end the process so a phase's kernel
# high-water mark can be measured by a run that stops there.
def settle() -> IO(Unit): IO.sleep(150)

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

def env_or(name: String, fallback: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env(name)
    IO.pure(String, Result.default(&1, &1, U32 & String, String, r, fallback))

# A process told to stop at a boundary drops the buffer - no traversal, so the
# stopping run does no work the full run does not - and says so.
def stop_now(buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    IO.print("PHASE=stopped")
    settle()

# The input is complete before the baseline marker: the last byte depends on
# every piece written into the buffer, so reading it forces the whole fill.
def forced(pair: B.Buf & U32) -> IO(B.Buf):
  (buf, last) = pair
  do IO<B.Buf>:
    IO.print("LAST=" ++ U32.show(last))
    IO.pure(B.Buf, buf)

# ---------------------------------------------------------------------------
# serialize: stream the buffer, one 64 KiB piece (16384 words) per write.

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

def write_buf(file: File, +size: U32, buf: B.Buf) -> IO(File & B.Buf):
  write_loop(Nat.div(Nat.add(U32.to_nat(size), 65535n), 65536n), 0,
    U32.shrn((size + 3 : U32), 2n), (file, buf))

def close_out(pair: File & B.Buf) -> IO(Unit):
  (file, buf) = pair
  File.close(file)

def phase_serialize(+out: String, +size: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    file : File <- IO.try(File, File.open(out, "w"))
    done : File & B.Buf <- write_buf(file, size, buf)
    close_out(done)
    t1 : Nat <- IO.now()
    IO.print("SERIALIZE_MS=" ++ Nat.show(Nat.sub(t1, t0)))
    IO.print("PHASE=serialized")
    settle()
    IO.print("PHASE=done")
    settle()

# ---------------------------------------------------------------------------
# root

def byte_sum(xs: +List<U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{+h, t}: byte_sum(t, (acc + h : U32))

def after_root(stop: Bool, +out: String, +size: U32, buf: B.Buf) -> IO(Unit):
  match stop:
    case True{}: stop_now(buf)
    case False{}: phase_serialize(out, size, buf)

def rooted(+mode: String, +out: String, +size: U32, +t0: Nat, pair: B.Buf & API.Outcome) -> IO(Unit):
  (buf, o) = pair
  do IO<Unit>:
    +sum : U32 = byte_sum(D.bytes(API.root_of(o)), 0)
    IO.print("ROOTSUM=" ++ U32.show(sum))
    t1 : Nat <- IO.now()
    IO.print("ROOT_MS=" ++ Nat.show(Nat.sub(t1, t0)))
    IO.print("PHASE=rooted")
    settle()
    after_root(String.eq(mode, "root"), out, size, buf)

def phase_root(+mode: String, +out: String, +size: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    rooted(mode, out, size, t0, API.run(1, Spec.BeaconState(), size, buf))

# ---------------------------------------------------------------------------
# decode

def after_decode(stop: Bool, +mode: String, +out: String, +size: U32, buf: B.Buf) -> IO(Unit):
  match stop:
    case True{}: stop_now(buf)
    case False{}: phase_root(mode, out, size, buf)

def decoded_gate(ok: Bool, +mode: String, +out: String, +size: U32, +t0: Nat, buf: B.Buf) -> IO(Unit):
  match ok:
    case False{}: IO.die(Unit, 1, "decode rejected")
    case True{}:
      do IO<Unit>:
        t1 : Nat <- IO.now()
        IO.print("DECODE_MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " CHECKSUM=" ++ U32.show(size))
        IO.print("PHASE=decoded")
        settle()
        after_decode(String.eq(mode, "decode"), mode, out, size, buf)

def decoded(+mode: String, +out: String, +size: U32, +t0: Nat, pair: B.Buf & API.Outcome) -> IO(Unit):
  (buf, o) = pair
  decoded_gate(API.accepted(o), mode, out, size, t0, buf)

def phase_decode(+mode: String, +out: String, +size: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    decoded(mode, out, size, t0, API.run(0, Spec.BeaconState(), size, buf))

def after_input(stop: Bool, +mode: String, +out: String, +size: U32, buf: B.Buf) -> IO(Unit):
  match stop:
    case True{}: stop_now(buf)
    case False{}: phase_decode(mode, out, size, buf)

def with_input(+mode: String, +out: String, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  do IO<Unit>:
    IO.print("SIZE=" ++ U32.show(size))
    live : B.Buf <- forced(B.byte_at(buf, (size - 1 : U32)))
    IO.print("PHASE=baseline")
    settle()
    after_input(String.eq(mode, "input"), mode, out, size, live)

def main() -> IO(Unit):
  do IO<Unit>:
    path : String <- IO.try(String, IO.get_env("SSZ_INPUT"))
    out : String <- IO.try(String, IO.get_env("SSZ_OUTPUT"))
    +mode : String <- env_or("SSZ_PHASES", "all")
    input : B.Buf & U32 <- read_all(path)
    with_input(mode, out, input)
