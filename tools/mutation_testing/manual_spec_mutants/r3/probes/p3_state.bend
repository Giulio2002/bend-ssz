import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/FuluBeaconState_def_generated.bend as SD
import ../../../../../types/FuluBeaconState_encode_ssz_generated.bend as SE
import ../../../../../types/FuluBeaconState_decode_ssz_generated.bend as SR
import ../../../../../types/FuluBeaconState_hashtreeroot_generated.bend as SH
import ../../../../../types/Fulu_list_Validator_1099511627776_def_generated.bend as LV
import ../../../../../types/FuluValidator_def_generated.bend as VD
import ../../../../../types/Fulu_list_Eth1Data_2048_def_generated.bend as LE
import ../../../../../types/FuluEth1Data_def_generated.bend as ED
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-3 probe: a BeaconState through serialize -> decode (public X_serialize, X_decode) -> serialize -> X_hash_tree_root.
# SSZ_CASE: 1 default; 2 with two validators; 3 with two validators and two eth1 data votes. Prints size, checksum of the bytes, whether the
# decode answers some, the checksum of the re-serialized bytes and the first root word.

def ck(+k: Nat, +i: U32, +acc: U32, pair: Array<U32> & U32) -> Array<U32> & U32:
  match k:
    case 0n:
      (ws, +w) = pair
      (ws, (acc + (w * (i + 1 : U32) : U32) : U32))
    case 1n+q:
      (ws, +w) = pair
      ck(q, (i + 1 : U32), (acc + (w * (i + 1 : U32) : U32) : U32), Array.get(U32, ws, (i + 1 : U32)))

def ckz(empty: Bool, ws: Array<U32>, +n: U32) -> Array<U32> & U32:
  match empty:
    case True{}: (ws, 0)
    case False{}: ck(U32.to_nat((U32.shrn((n + 3 : U32), 2n) - 1 : U32)), 0, 0, Array.get(U32, ws, 0))

def ckfin(+n: U32, pair: Array<U32> & U32) -> U32 & U32:
  (ws, +c) = pair
  (n, c)

def ckinfo(b: B.Buf) -> U32 & U32:
  match b:
    case B.Buf{ws, +n}: ckfin(n, ckz(U32.is_eq(n, 0), ws, n))

def ckb2fin(+n: U32, pair: Array<U32> & U32) -> B.Buf & (U32 & U32):
  (ws, +c) = pair
  (B.Buf{ws, n}, (n, c))

def ckb2(b: B.Buf) -> B.Buf & (U32 & U32):
  match b:
    case B.Buf{ws, +n}: ckb2fin(n, ckz(U32.is_eq(n, 0), ws, n))

def root0(pair: B.Buf & (SD.BeaconState & D.Digest)) -> U32:
  (b, r) = pair
  (o, d) = r
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}: a

def step4(label: String, +n: U32, +c1: U32, ok2: Bool, pair: U32 & U32, o: SD.BeaconState) -> IO(Unit):
  (+n2, +c2) = pair
  IO.print(label ++ " size=" ++ U32.show(n) ++ " ck=" ++ U32.show(c1) ++ " decoded=" ++ O.pick_str(ok2) ++ " size2=" ++ U32.show(n2) ++ " ck2=" ++ U32.show(c2) ++ " root0=" ++ U32.show(root0(SH.BeaconState_hash_tree_root(O.hasher(), o))))

def step3(label: String, +n: U32, +c1: U32, pair: SD.BeaconState & O.Encoded) -> IO(Unit):
  (o2, e) = pair
  match e:
    case O.Encoded{ok2, b2}: step4(label, n, c1, ok2, ckinfo(b2), o2)

def step2(label: String, +n: U32, +c1: U32, pair: B.Buf & Maybe<&1, SD.BeaconState>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{o}: step3(label, n, c1, SE.BeaconState_serialize(o))
    case None{}: IO.print(label ++ " size=" ++ U32.show(n) ++ " ck=" ++ U32.show(c1) ++ " decoded=none")

def step1b(label: String, r: U32 & U32, b: B.Buf) -> IO(Unit):
  (+n, +c) = r
  step2(label, n, c, SR.BeaconState_decode(b, n))

def step1a(label: String, pair: B.Buf & (U32 & U32)) -> IO(Unit):
  (b, r) = pair
  step1b(label, r, b)

def step1(label: String, pair: SD.BeaconState & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: step1a(label, ckb2(b))

def vals2(o: SD.BeaconState) -> SD.BeaconState:
  SD.BeaconState_set_validators(o, Pair.fst(LV.l1099511627776_Validator_Seq, Bool, LV.l1099511627776_Validator_append(Pair.fst(LV.l1099511627776_Validator_Seq, Bool, LV.l1099511627776_Validator_append(LV.l1099511627776_Validator_default(), VD.Validator_default())), VD.Validator_default())))

def votes2(o: SD.BeaconState) -> SD.BeaconState:
  SD.BeaconState_set_eth1_data_votes(o, Pair.fst(LE.l2048_Eth1Data_Seq, Bool, LE.l2048_Eth1Data_append(Pair.fst(LE.l2048_Eth1Data_Seq, Bool, LE.l2048_Eth1Data_append(LE.l2048_Eth1Data_default(), ED.Eth1Data_default())), ED.Eth1Data_default())))

def c1() -> IO(Unit): step1("state_default", SE.BeaconState_serialize(SD.BeaconState_default()))
def c2() -> IO(Unit): step1("state_2val", SE.BeaconState_serialize(vals2(SD.BeaconState_default())))
def c3() -> IO(Unit): step1("state_2val_2votes", SE.BeaconState_serialize(votes2(vals2(SD.BeaconState_default()))))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case _: c3()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
