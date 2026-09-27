import Base
import ../../src/buffer.bend as B
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/FuluValidator_decode_ssz_generated.bend as FuluValidator_r
import ../compact/io.bend as IOx

# Compile-cost probe: one type's build (no validation) from the generated module.
def done(pair: B.Buf & FuluValidator_d.Validator) -> IO(Unit):
  (buf, v) = pair
  IO.print("OK " ++ U32.show(Pair.snd(FuluValidator_d.Validator, U32, FuluValidator_d.Validator_force(v))))

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(FuluValidator_r.Validator_build(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
