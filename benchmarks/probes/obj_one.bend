import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/FuluCheckpoint_def_generated.bend as FuluCheckpoint_d
import ../../types/FuluCheckpoint_decode_ssz_generated.bend as FuluCheckpoint_r
import ../compact/io.bend as IOx

# Compile-cost probe: one type's decode and encode from the generated module.
def done(pair: B.Buf & Maybe<&1, FuluCheckpoint_d.Checkpoint>) -> IO(Unit):
  (buf, m) = pair
  match m:
    case None{}: IO.print("REJECT")
    case Some{+v}: IO.print("OK " ++ U32.show(FuluCheckpoint_d.Checkpoint_force(v)))

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(FuluCheckpoint_r.Checkpoint_decode(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
