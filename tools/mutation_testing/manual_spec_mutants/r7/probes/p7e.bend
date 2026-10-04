import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../types/FuluExecutionPayload_def_generated.bend as EpD
import ../../../../../types/FuluExecutionPayload_encode_ssz_generated.bend as EpE
import ../../../../../types/FuluExecutionPayload_decode_ssz_generated.bend as EpR
import ../../../../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as TlD
import ../../../../../types/Fulu_list_Withdrawal_16_def_generated.bend as WlD
import ../../../../../types/FuluWithdrawal_def_generated.bend as WD
import ../../../../../types/Fulu_bytelist_32_def_generated.bend as XdD
import ../../../../../types/FuluTransaction_def_generated.bend as TxD
import ../../../../../types/FuluSignedBeaconBlock_def_generated.bend as SbD
import ../../../../../types/FuluSignedBeaconBlock_encode_ssz_generated.bend as SbE
import ../../../../../types/FuluSignedBeaconBlock_decode_ssz_generated.bend as SbR
import ../../../../../types/FuluBytes96_def_generated.bend as B96
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-7 probe e: ExecutionPayload / SignedBeaconBlock values built with public setters, serialized, decoded, re-serialized (size and a word checksum).
# SSZ_CASE:
#  1 ExecutionPayload default                                                                    (control)
#  2 ExecutionPayload with extra_data = [7], transactions = [[1, 2], [3]], withdrawals = [default, default]
#  3 SignedBeaconBlock default with signature word 0 = 7
#  4 case 2's bytes with the transactions' second offset (byte 528 + 1 + 4) set past the transactions window (10 -> 200): invalid
#  5 case 2's bytes with byte 528 + 1 + 4 set to 4 (offsets 8, 4: descending): invalid

def ck_st(+k: Nat, +i: U32, +acc: U32, pair: Array<U32> & U32) -> U32:
  (ws, +x) = pair
  ck_go(k, (i + 1 : U32), ((acc * 31 : U32) + x : U32), ws)

def ck_go(+k: Nat, +i: U32, +acc: U32, ws: Array<U32>) -> U32:
  match k:
    case 0n: acc
    case 1n+q: ck_st(q, i, acc, Array.get(U32, ws, i))

def show_buf(label: String, x: Bool, b: B.Buf) -> IO(Unit):
  match b:
    case B.Buf{ws, +n}: IO.print(label ++ " reser_ok=" ++ O.pick_str(x) ++ " size=" ++ U32.show(n) ++ " ck=" ++ U32.show(ck_go(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, 7, ws)))
def show_enc(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{x, b}: show_buf(label, x, b)

def ep_ser(label: String, pair: EpD.ExecutionPayload & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show_enc(label, e)
def show_ep(label: String, pair: B.Buf & Maybe<&1, EpD.ExecutionPayload>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: ep_ser(label ++ " decoded=some", EpE.ExecutionPayload_serialize(v))
    case None{}: IO.print(label ++ " decoded=none")
def sb_ser(label: String, pair: SbD.SignedBeaconBlock & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show_enc(label, e)
def show_sb(label: String, pair: B.Buf & Maybe<&1, SbD.SignedBeaconBlock>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: sb_ser(label ++ " decoded=some", SbE.SignedBeaconBlock_serialize(v))
    case None{}: IO.print(label ++ " decoded=none")

def fw(pair: O.Words & Bool) -> O.Words:
  (w, ok) = pair
  w
def ft(pair: TlD.l1048576_bl1073741824_Seq & Bool) -> TlD.l1048576_bl1073741824_Seq:
  (w, ok) = pair
  w
def fl(pair: WlD.l16_Withdrawal_Seq & Bool) -> WlD.l16_Withdrawal_Seq:
  (w, ok) = pair
  w
def tx(+a: U32) -> O.Words: fw(TxD.bl1073741824_append(TxD.bl1073741824_default(), a))
def txs() -> TlD.l1048576_bl1073741824_Seq:
  ft(TlD.l1048576_bl1073741824_append(ft(TlD.l1048576_bl1073741824_append(TlD.l1048576_bl1073741824_default(), fw(TxD.bl1073741824_append(tx(1), 2)))), tx(3)))
def wds() -> WlD.l16_Withdrawal_Seq: fl(WlD.l16_Withdrawal_append(fl(WlD.l16_Withdrawal_append(WlD.l16_Withdrawal_default(), WD.Withdrawal_default())), WD.Withdrawal_default()))
def ep2() -> EpD.ExecutionPayload:
  EpD.ExecutionPayload_set_withdrawals(EpD.ExecutionPayload_set_transactions(EpD.ExecutionPayload_set_extra_data(EpD.ExecutionPayload_default(), fw(XdD.bl32_append(XdD.bl32_default(), 7))), txs()), wds())
def bytes_of(e: O.Encoded) -> B.Buf: O.ser_out(e)
def ep_bytes(o: EpD.ExecutionPayload) -> B.Buf: bytes_of(Pair.snd(EpD.ExecutionPayload, O.Encoded, EpE.ExecutionPayload_serialize(o)))
def dec_ep(label: String, pair: B.Buf & U32) -> IO(Unit):
  (b, +n) = pair
  show_ep(label, EpR.ExecutionPayload_decode(b, n))
# byte 533 = word 133, byte 1: set it to v (it is the low byte of the transactions' second offset, at 528 + 1 + 4)
def set_w(+i: U32, +v: U32, +n: U32, pair: Array<U32> & U32) -> B.Buf:
  (ws, +x) = pair
  B.Buf{Array.set(U32, ws, i, ((x .&. 4294902015 : U32) .|. (v * 256 : U32) : U32)), n}
def set533(+v: U32, b: B.Buf) -> B.Buf:
  match b:
    case B.Buf{ws, +n}: set_w(133, v, n, Array.get(U32, ws, 133))
def sig7() -> B96.Bytes96: B96.Bytes96{7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
def sb_bytes() -> B.Buf: bytes_of(Pair.snd(SbD.SignedBeaconBlock, O.Encoded, SbE.SignedBeaconBlock_serialize(SbD.SignedBeaconBlock_set_signature(SbD.SignedBeaconBlock_default(), sig7()))))
def dec_sb(label: String, pair: B.Buf & U32) -> IO(Unit):
  (b, +n) = pair
  show_sb(label, SbR.SignedBeaconBlock_decode(b, n))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: dec_ep("c1 ep default", B.size(ep_bytes(EpD.ExecutionPayload_default())))
    case 2: dec_ep("c2 ep x1 t2 w2", B.size(ep_bytes(ep2())))
    case 3: dec_sb("c3 sbb sig7", B.size(sb_bytes()))
    case 4: dec_ep("c4 ep tx off past", B.size(set533(200, ep_bytes(ep2()))))
    case _: dec_ep("c5 ep tx off desc", B.size(set533(4, ep_bytes(ep2()))))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
