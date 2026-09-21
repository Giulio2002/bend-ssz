import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/io.bend as IOx

# Compile-cost probe: one type, decode + encode + root.
def rooted(pair: B.Buf & (T.BeaconState & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (v, d) = r
  IO.print("OK " ++ U32.show(Pair.snd(T.BeaconState, U32, T.BeaconState_force(v))))

def encoded(pair: T.BeaconState & B.Buf) -> IO(Unit):
  (v, out) = pair
  rooted(T.BeaconState_hash_tree_root(O.hasher(), v))

def done(pair: B.Buf & Maybe<&1, T.BeaconState>) -> IO(Unit):
  (buf, m) = pair
  match m:
    case None{}: IO.print("REJECT")
    case Some{v}: encoded(T.BeaconState_encode(v))

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(T.BeaconState_decode(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
