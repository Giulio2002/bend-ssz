import Base
import ../src/ssz.bend as API
import ../src/decode.bend as Decode
import ../src/cvalue.bend as C
import ../src/packed.bend as Packed
import ../spec/fulu_schemas.bend as Spec
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive

# Native SSZ driver for the memory/latency comparison.
#
# Phase boundaries are explicit: the process prints a marker and then sleeps,
# so the harness reads the operating system's resident size while this process
# is provably idle. The Bend runtime never returns heap pages to the operating
# system (its heap is one MAP_NORESERVE mapping with a monotone page bump and
# per-class free lists, see build/native/*.c), so resident size is monotone
# within a phase and the value observed at the end of the phase IS that
# phase's high-water mark. The harness additionally samples continuously and
# cross-checks that no sample exceeds the boundary reading.
#
# The decoded value is folded into a checksum inside the measured window and
# is still live afterwards (it is serialized), so nothing is postponed or
# eliminated.

def settle() -> IO(Unit): IO.sleep(150)

def loaded(pair: File & Result<&1, &1, U32 & String, +List<U32>>) -> IO(+List<U32>):
  (file, result) = pair
  do IO<+List<U32>>:
    File.close(file)
    IO.pass(+List<U32>, result)

def sized(pair: File & Result<&1, &1, U32 & String, U32>) -> IO(File & U32):
  (file, result) = pair
  do IO<File & U32>:
    n : U32 <- IO.pass(U32, result)
    return (file, n)

# Read the whole file: the size comes from the file itself, and a short read
# is a hard error rather than a silent truncation.
def length_gate(ok: Bool, +bytes: +List<U32>) -> IO(+List<U32>):
  match ok:
    case True{}: IO.pure(+List<U32>, bytes)
    case False{}: IO.die(+List<U32>, 2, "short read: input truncated")

def checked_length(+bytes: +List<U32>, +size: U32) -> IO(+List<U32>):
  length_gate(U32.is_eq(U32.from_nat(List.length(&2, U32, bytes)), size), bytes)

# Streaming read: the file is read in 64 KiB pieces, each piece packed
# immediately, so the one-cell-per-byte form of the input never exists in
# full; only the packed form (one node per 32 bytes) stays resident. Pieces
# are read from the last to the first so that each packed piece is prepended
# in constant time per chunk.

def piece_gate(ok: Bool, +piece: +List<U32>, +want: U32, acc: +List<Packed.Chunk>) -> IO(+List<Packed.Chunk>):
  match ok:
    case False{}: IO.die(+List<Packed.Chunk>, 2, "short read: input truncated")
    case True{}: IO.pure(+List<Packed.Chunk>, List.append(&2, Packed.Chunk, Packed.chunks_of(Packed.pack(U32.to_nat(want), piece)), acc))

def piece_chunks(pair: File & Result<&1, &1, U32 & String, +List<U32>>, +want: U32, acc: +List<Packed.Chunk>) -> IO(+List<Packed.Chunk>):
  (file, result) = pair
  do IO<+List<Packed.Chunk>>:
    File.close(file)
    +piece : +List<U32> <- IO.pass(+List<U32>, result)
    piece_gate(U32.is_eq(U32.from_nat(List.length(&2, U32, piece)), want), piece, want, acc)

# `k` pieces remain, the last one starting at `offset` and `want` bytes long.

def read_loop(k: Nat, +path: String, +offset: U32, +want: U32, acc: +List<Packed.Chunk>) -> IO(+List<Packed.Chunk>):
  match k:
    case 0n: IO.pure(+List<Packed.Chunk>, acc)
    case 1n+p:
      do IO<+List<Packed.Chunk>>:
        file : File <- IO.try(File, File.open(path, "r"))
        pair : File & Result<&1, &1, U32 & String, +List<U32>> <- File.read_at(file, offset, want)
        grown : +List<Packed.Chunk> <- piece_chunks(pair, want, acc)
        read_loop(p, path, U32.sub(offset, 65536), 65536, grown)

def read_from(+pieces: Nat, +offset: U32, +path: String, +size: U32) -> IO(Packed.Slice):
  do IO<Packed.Slice>:
    chunks : +List<Packed.Chunk> <- read_loop(pieces, path, offset, U32.sub(size, offset), [])
    IO.pure(Packed.Slice, Packed.Slice{chunks, 0n, U32.to_nat(size)})

def read_pieces(+pieces: Nat, +path: String, +size: U32) -> IO(Packed.Slice):
  read_from(pieces, U32.mul(U32.from_nat(Nat.sub(pieces, 1n)), 65536), path, size)

def read_sized(+path: String, +size: U32) -> IO(Packed.Slice):
  read_pieces(Nat.div(Nat.add(U32.to_nat(size), 65535n), 65536n), path, size)

def read_opened(handle: File & U32, +path: String) -> IO(Packed.Slice):
  (file, +size) = handle
  do IO<Packed.Slice>:
    File.close(file)
    read_sized(path, size)

def read_all(+path: String) -> IO(Packed.Slice):
  do IO<Packed.Slice>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
    got : File & U32 <- sized(pair)
    read_opened(got, path)

# Force the decoded value: every leaf contributes to the checksum, so the
# whole structure is built and consumed inside the measured window.
def fold_uint(u: Primitive.UInt) -> U32:
  match u:
    case Primitive.UInt{a, b, c, d, e, f, g, h}: U32.add(U32.add(U32.add(a, b), U32.add(c, d)), U32.add(U32.add(e, f), U32.add(g, h)))

def fold_bytes(bs: +List<U32>, acc: U32) -> U32:
  match bs:
    case Nil{}: acc
    case Con{b, t}: fold_bytes(t, U32.add(acc, b))

def fold_bits(bs: +List<Bool>, acc: U32) -> U32:
  match bs:
    case Nil{}: acc
    case Con{b, t}: fold_bits(t, U32.add(acc, Bool.to_u32(b)))

# Consume every decoded node: each leaf contributes its size and its first and
# last byte, so nothing is dropped as dead code and the whole structure is
# traversed. The Go reference performs the matching per-field fold.
def fold_packed(+s: Packed.Slice, acc: U32) -> U32:
  U32.add(U32.add(acc, U32.from_nat(Packed.slice_size(s))),
    U32.add(Packed.byte_at(s, 0n), Packed.byte_at(s, Nat.sub(Packed.slice_size(s), 1n))))

def fold_value(v: C.CValue, acc: U32) -> U32:
  match v:
    case C.CBool{b}: U32.add(acc, Bool.to_u32(b))
    case C.CUint{u}: U32.add(acc, fold_uint(u))
    case C.CBytes{p}: fold_packed(p, acc)
    case C.CBits{bs}: fold_bits(bs, acc)
    case C.CSeq{items}: fold_value(items, acc)
    case C.CCons{h, t}: fold_value(t, fold_value(h, acc))
    case C.CEnd{}: acc
    case C.CSel{s, x}: fold_value(x, U32.add(acc, s))
    case C.CNull{}: acc

def forced(r: Maybe<&2, C.CValue>) -> IO(C.CValue):
  match r:
    case None{}: IO.die(C.CValue, 1, "decode rejected")
    case Some{v}: IO.pure(C.CValue, v)

def encoded(value: Maybe<&2, +List<U32>>) -> IO(+List<U32>):
  match value:
    case None{}: IO.die(+List<U32>, 1, "serialize rejected")
    case Some{v}: IO.pure(+List<U32>, v)

def written(pair: File & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (file, result) = pair
  do IO<Unit>:
    File.close(file)
    IO.pass(Unit, result)

def rooted(r: Maybe<&2, +List<U32>>) -> IO(+List<U32>):
  match r:
    case None{}: IO.die(+List<U32>, 1, "hash_tree_root rejected")
    case Some{v}: IO.pure(+List<U32>, v)

# Which phases this process runs. The harness measures a phase's true
# high-water mark by stopping a fresh process at the end of that phase and
# reading the kernel's peak resident size for the whole (identical) prefix:
# `input` stops after the input has been read and packed, `decode` stops after
# the decoded value has been fully forced, `root` after hashing. `all` runs
# everything and is the run whose output bytes are compared.
def env_or(name: String, fallback: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env(name)
    IO.pure(String, Result.default(&1, &1, U32 & String, String, r, fallback))

def stop_now() -> IO(Unit):
  do IO<Unit>:
    IO.print("PHASE=stopped")
    settle()

def phase_write(+out: String, data: +List<U32>) -> IO(Unit):
  do IO<Unit>:
    file : File <- IO.try(File, File.open(out, "w"))
    pair : File & Result<&1, &1, U32 & String, Unit> <- File.write_bytes(file, data)
    written(pair)
    IO.print("PHASE=done")
    settle()

def phase_serialize(+out: String, +schema: T.Schema, +value: C.CValue) -> IO(Unit):
  do IO<Unit>:
    sstart : Nat <- IO.now()
    data : +List<U32> <- encoded(API.serialize(schema, C.to_value(value)))
    sstop : Nat <- IO.now()
    IO.print("SERIALIZE_MS=" ++ Nat.show(Nat.sub(sstop, sstart)))
    IO.print("PHASE=serialized")
    settle()
    phase_write(out, data)

def after_root(stop: Bool, +out: String, +schema: T.Schema, +value: C.CValue) -> IO(Unit):
  match stop:
    case True{}: stop_now()
    case False{}: phase_serialize(out, schema, value)

def phase_root(+mode: String, +out: String, +schema: T.Schema, +value: C.CValue) -> IO(Unit):
  do IO<Unit>:
    rstart : Nat <- IO.now()
    digest : +List<U32> <- rooted(API.hash_tree_root(schema, C.to_value(value)))
    rsum : U32 = fold_bytes(digest, 0)
    rstop : Nat <- IO.now()
    IO.print("ROOT_MS=" ++ Nat.show(Nat.sub(rstop, rstart)) ++ " ROOTSUM=" ++ U32.show(rsum))
    IO.print("PHASE=rooted")
    settle()
    after_root(String.eq(mode, "root"), out, schema, value)

def after_decode(stop: Bool, +mode: String, +out: String, +schema: T.Schema, +value: C.CValue) -> IO(Unit):
  match stop:
    case True{}: stop_now()
    case False{}: phase_root(mode, out, schema, value)

def after_input(stop: Bool, +mode: String, +out: String, +schema: T.Schema, +input: Packed.Slice) -> IO(Unit):
  match stop:
    case True{}: stop_now()
    case False{}:
      do IO<Unit>:
        start : Nat <- IO.now()
        decoded : Maybe<&2, C.CValue> = Decode.decode_packed(schema, input)
        +value : C.CValue <- forced(decoded)
        sum : U32 = fold_value(value, 0)
        stop2 : Nat <- IO.now()
        IO.print("DECODE_MS=" ++ Nat.show(Nat.sub(stop2, start)) ++ " CHECKSUM=" ++ U32.show(sum))
        IO.print("PHASE=decoded")
        settle()
        after_decode(String.eq(mode, "decode"), mode, out, schema, value)

def main() -> IO(Unit):
  do IO<Unit>:
    path : String <- IO.try(String, IO.get_env("SSZ_INPUT"))
    out : String <- IO.try(String, IO.get_env("SSZ_OUTPUT"))
    +mode : String <- env_or("SSZ_PHASES", "all")
    +input : Packed.Slice <- read_all(path)
    +schema : T.Schema = Spec.BeaconState()
    IO.print("PHASE=baseline")
    settle()
    after_input(String.eq(mode, "input"), mode, out, schema, input)
