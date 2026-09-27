import Base
import ../../src/buffer.bend as B
import ../../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../../types/FuluExecutionPayloadHeader_decode_ssz_generated.bend as FuluExecutionPayloadHeader_r
import ../compact/io.bend as IOx

# Compile-cost probe: BeaconState build only.
def done(pair: B.Buf & FuluExecutionPayloadHeader_d.ExecutionPayloadHeader) -> IO(Unit):
  (buf, v) = pair
  IO.print("OK")

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_build(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
