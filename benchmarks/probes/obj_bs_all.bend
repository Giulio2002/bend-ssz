import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluBeaconState_def_generated.bend as FuluBeaconState_d
import ../../types/FuluBeaconState_decode_ssz_generated.bend as FuluBeaconState_r
import ../../types/FuluBeaconState_encode_ssz_generated.bend as FuluBeaconState_e
import ../../types/FuluBeaconState_hashtreeroot_generated.bend as FuluBeaconState_h
import ../compact/io.bend as IOx

# Compile-cost probe: one type, decode + encode + root.
def rooted(pair: B.Buf & (FuluBeaconState_d.BeaconState & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (v, d) = r
  IO.print("OK " ++ U32.show(Pair.snd(FuluBeaconState_d.BeaconState, U32, FuluBeaconState_d.BeaconState_force(v))))

def encoded(pair: FuluBeaconState_d.BeaconState & B.Buf) -> IO(Unit):
  (v, out) = pair
  rooted(FuluBeaconState_h.BeaconState_hash_tree_root(O.hasher(), v))

def done(pair: B.Buf & Maybe<&1, FuluBeaconState_d.BeaconState>) -> IO(Unit):
  (buf, m) = pair
  match m:
    case None{}: IO.print("REJECT")
    case Some{v}: encoded(FuluBeaconState_e.BeaconState_encode(v))

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  done(FuluBeaconState_r.BeaconState_decode(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
