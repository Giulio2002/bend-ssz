import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/io.bend as IOx

# Compile-cost probe: one type's decode and encode from the generated module.
def done(pair: B.Buf & Maybe<&1, T.Checkpoint>) -> IO(Unit):
  (buf, m) = pair
  match m:
    case None{}: IO.print("REJECT")
    case Some{+v}: IO.print("OK " ++ U32.show(T.Checkpoint_force(v)))

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(T.Checkpoint_decode(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
