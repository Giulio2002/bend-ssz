import Base
import ../../src/buffer.bend as B
import ../../types/fulu_obj.bend as T
import ../compact/io.bend as IOx

# Compile-cost probe: BeaconState build only.
def done(pair: B.Buf & T.BeaconState) -> IO(Unit):
  (buf, v) = pair
  IO.print("OK")

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(T.BeaconState_build(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
