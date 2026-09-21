import Base
import ../../src/buffer.bend as B
import ../../types/fulu_obj.bend as T
import ../compact/io.bend as IOx

# Compile-cost probe: one type's build (no validation) from the generated module.
def done(pair: B.Buf & T.Validator) -> IO(Unit):
  (buf, v) = pair
  IO.print("OK " ++ U32.show(Pair.snd(T.Validator, U32, T.Validator_force(v))))

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(T.Validator_build(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
