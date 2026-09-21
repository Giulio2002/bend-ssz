import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/objio.bend as IOx

# Debug probe: the two field roots of a SyncCommittee object, separately.
def show2(d1: D.Digest, d2: D.Digest) -> IO(Unit):
  do IO<Unit>:
    IO.print("PUBKEYS=" ++ IOx.words(d1))
    IO.print("AGG=" ++ IOx.words(d2))

def with_fields(+agg: T.Bytes48, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (w, d) = r
  show2(d, Pair.snd(B.Buf, D.Digest, T.b48_root(h, agg, 0)))

def on_obj(o: T.SyncCommittee) -> IO(Unit):
  match o:
    case T.SyncCommittee{pubkeys, +aggregate_pubkey}:
      with_fields(aggregate_pubkey, T.v512_b48_root(O.hasher(), pubkeys, 0))

def on_dec(m: Maybe<&1, T.SyncCommittee>, buf: B.Buf) -> IO(Unit):
  match m:
    case None{}: IO.print("REJECT")
    case Some{o}: on_obj(o)

def decoded(pair: B.Buf & Maybe<&1, T.SyncCommittee>) -> IO(Unit):
  (buf, m) = pair
  on_dec(m, buf)

def with_input(pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  decoded(T.SyncCommittee_decode(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    input : B.Buf & U32 <- IOx.load()
    with_input(input)
