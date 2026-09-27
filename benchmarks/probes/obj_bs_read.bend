import Base
import ../../src/buffer.bend as B
import ../../types/FuluBeaconState_def_generated.bend as FuluBeaconState_d
import ../../types/FuluBeaconState_decode_ssz_generated.bend as FuluBeaconState_r
import ../compact/io.bend as IOx

# Compile-cost probe: BeaconState build only.
def done(pair: B.Buf & FuluBeaconState_d.BeaconState) -> IO(Unit):
  (buf, v) = pair
  IO.print("OK")

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(FuluBeaconState_r.BeaconState_build(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
