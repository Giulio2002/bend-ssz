# Example: decode, read, update, serialize and hash a Checkpoint through the
# generated object API. Check it with `tools/check.sh examples/checkpoint.bend`
# and run it with `bend examples/checkpoint.bend`.
import Base
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ../src/digest.bend as D
import ../types/FuluCheckpoint_def_generated.bend as Cp
import ../types/FuluCheckpoint_decode_ssz_generated.bend as CpDec
import ../types/FuluCheckpoint_encode_ssz_generated.bend as CpEnc
import ../types/FuluCheckpoint_hashtreeroot_generated.bend as CpRoot

# 40 bytes: epoch = 7 (uint64, little endian), then root = 32 bytes of 0x11.
def input() -> B.Buf:
  B.fill_at(B.alloc(40), 0, [7, 0, 0, 0, 0, 0, 0, 0,
    17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
    17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17])

def flag(b: Bool) -> String:
  match b:
    case True{}: "1"
    case False{}: "0"

def line(ok: Bool, +w0: U32, pair: B.Buf & U32) -> IO(Unit):
  (bytes, n) = pair
  IO.print("serialize_ok=" ++ flag(ok) ++ " size=" ++ U32.show(n) ++ " root_w0=" ++ U32.show(w0))

def report(ok: Bool, dg: D.Digest, pair: B.Buf & U32) -> IO(Unit):
  match dg:
    case D.D{w0, w1, w2, w3, w4, w5, w6, w7}: line(ok, w0, pair)

def with_bytes(dg: D.Digest, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, bytes}: report(ok, dg, B.size(bytes))

def with_root(c: Cp.Checkpoint, pair: B.Buf & D.Digest) -> IO(Unit):
  (h, dg) = pair
  with_bytes(dg, CpEnc.Checkpoint_serialize(c))

# A Checkpoint is plain data, so it can be both hashed and serialized.
def both(+c: Cp.Checkpoint) -> IO(Unit):
  with_root(c, CpRoot.Checkpoint_hash_tree_root(O.hasher(), c))

# Set the epoch to 8, then hash_tree_root and the checked serialize
# (serialize answers ok = 0 and no bytes for an invalid object).
def update(c: Cp.Checkpoint) -> IO(Unit):
  both(Cp.Checkpoint_set_epoch(c, O.U64{8, 0}))

def with_epoch(pair: Cp.Checkpoint & O.U64) -> IO(Unit):
  (c, e) = pair
  do IO<Unit>:
    IO.print("epoch=" ++ U32.show(O.u64_lo_of(e)))
    update(c)

def decoded(pair: B.Buf & Maybe<&1, Cp.Checkpoint>) -> IO(Unit):
  (buf, m) = pair
  match m:
    case None{}: IO.print("rejected")
    case Some{c}: with_epoch(Cp.Checkpoint_get_epoch(c))

# decode_checked answers None unless the window is exactly a canonical
# Checkpoint encoding inside the buffer.
def main() -> IO(Unit):
  decoded(CpDec.Checkpoint_decode_checked(input(), 40))
