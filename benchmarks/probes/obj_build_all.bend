import Base
import ../../src/buffer.bend as B
import ../../types/fulu_obj_index.bend as Ix
import ../compact/io.bend as IOx

# Compile-cost probe: decode and force for all 109 names.
def forced(pair: Ix.Any & U32) -> IO(Unit):
  (a, +x) = pair
  IO.print("OK " ++ U32.show(x))

def done(pair: B.Buf & Maybe<&1, Ix.Any>) -> IO(Unit):
  (buf, m) = pair
  match m:
    case None{}: IO.print("REJECT")
    case Some{a}: forced(Ix.force(a))

def with_input(+i: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(Ix.build(i, buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    +i : U32 <- IOx.env_u32("SSZ_INDEX")
    input : B.Buf & U32 <- IOx.load()
    with_input(i, input)
