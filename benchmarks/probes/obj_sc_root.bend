import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/FuluBytes48_hashtreeroot_generated.bend as FuluBytes48_h
import ../../types/Fulu_vec_bytevec_48_512_hashtreeroot_generated.bend as Fulu_vec_bytevec_48_512_h
import ../../types/FuluSyncCommittee_def_generated.bend as FuluSyncCommittee_d
import ../../types/FuluSyncCommittee_decode_ssz_generated.bend as FuluSyncCommittee_r
import ../compact/objio.bend as IOx

# Debug probe: the two field roots of a SyncCommittee object, separately.
def show2(d1: D.Digest, d2: D.Digest) -> IO(Unit):
  do IO<Unit>:
    IO.print("PUBKEYS=" ++ IOx.words(d1))
    IO.print("AGG=" ++ IOx.words(d2))

def with_fields(+agg: FuluBytes48_d.Bytes48, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (w, d) = r
  show2(d, Pair.snd(B.Buf, D.Digest, FuluBytes48_h.b48_root(h, agg, 0)))

def on_obj(o: FuluSyncCommittee_d.SyncCommittee) -> IO(Unit):
  match o:
    case FuluSyncCommittee_d.SyncCommittee{pubkeys, +aggregate_pubkey}:
      with_fields(aggregate_pubkey, Fulu_vec_bytevec_48_512_h.v512_b48_root(O.hasher(), pubkeys, 0))

def on_dec(m: Maybe<&1, FuluSyncCommittee_d.SyncCommittee>, buf: B.Buf) -> IO(Unit):
  match m:
    case None{}: IO.print("REJECT")
    case Some{o}: on_obj(o)

def decoded(pair: B.Buf & Maybe<&1, FuluSyncCommittee_d.SyncCommittee>) -> IO(Unit):
  (buf, m) = pair
  on_dec(m, buf)

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  decoded(FuluSyncCommittee_r.SyncCommittee_decode(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
