import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../types/FuluAttesterSlashing_def_generated.bend as AsD
import ../../../../../types/FuluAttesterSlashing_encode_ssz_generated.bend as AsE
import ../../../../../types/FuluIndexedAttestation_def_generated.bend as IaD
import ../../../../../types/FuluAttestation_def_generated.bend as AtD
import ../../../../../types/Fulu_list_Attestation_8_def_generated.bend as LA
import ../../../../../types/Fulu_list_AttesterSlashing_1_def_generated.bend as LS
import ../../../../../types/FuluBeaconBlockBody_def_generated.bend as BbD
import ../../../../../types/FuluBeaconBlockBody_encode_ssz_generated.bend as BbE
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-3 probe: absent boxes (O.BNone, CH-12) through the public serializers. SSZ_CASE: 1 AttesterSlashing{BNone, default};
# 2 AttesterSlashing{default, BNone}; 3 default AttesterSlashing (control); 4 BeaconBlockBody whose attestations list claims one element
# that is absent; 5 the same with one default Attestation appended (control); 6 BeaconBlockBody whose attester_slashings list claims one
# absent element; 7 AttesterSlashing_valid of case 1; 8 AttesterSlashing_valid of the default.

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

def show_ck(label: String, ok: Bool, pair: U32 & U32) -> IO(Unit):
  (+n, +c) = pair
  IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n) ++ " ck=" ++ U32.show(c))

def show(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: show_ck(label, ok, ckinfo(b))

def ser_as(label: String, pair: AsD.AttesterSlashing & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def ser_bb(label: String, pair: BbD.BeaconBlockBody & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def valid_p(label: String, pair: AsD.AttesterSlashing & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def as_none1() -> AsD.AttesterSlashing: AsD.AttesterSlashing_set_attestation_1(AsD.AttesterSlashing_default(), O.BNone{})
def as_none2() -> AsD.AttesterSlashing: AsD.AttesterSlashing_set_attestation_2(AsD.AttesterSlashing_default(), O.BNone{})

def absent_atts() -> LA.l8_Attestation_Seq: LA.l8_Attestation_Seq{LA.l8_Attestation_fill(0n), 1}
def absent_slash() -> LS.l1_AttesterSlashing_Seq: LS.l1_AttesterSlashing_Seq{LS.l1_AttesterSlashing_fill(0n), 1}
def one_att() -> LA.l8_Attestation_Seq: Pair.fst(LA.l8_Attestation_Seq, Bool, LA.l8_Attestation_append(LA.l8_Attestation_default(), AtD.Attestation_default()))

def c1() -> IO(Unit): ser_as("as_none_1", AsE.AttesterSlashing_serialize(as_none1()))
def c2() -> IO(Unit): ser_as("as_none_2", AsE.AttesterSlashing_serialize(as_none2()))
def c3() -> IO(Unit): ser_as("as_default", AsE.AttesterSlashing_serialize(AsD.AttesterSlashing_default()))
def c4() -> IO(Unit): ser_bb("bb_absent_attestation", BbE.BeaconBlockBody_serialize(BbD.BeaconBlockBody_set_attestations(BbD.BeaconBlockBody_default(), absent_atts())))
def c5() -> IO(Unit): ser_bb("bb_one_attestation", BbE.BeaconBlockBody_serialize(BbD.BeaconBlockBody_set_attestations(BbD.BeaconBlockBody_default(), one_att())))
def c6() -> IO(Unit): ser_bb("bb_absent_slashing", BbE.BeaconBlockBody_serialize(BbD.BeaconBlockBody_set_attester_slashings(BbD.BeaconBlockBody_default(), absent_slash())))
def c7() -> IO(Unit): valid_p("as_none_1", AsE.AttesterSlashing_valid(as_none1()))
def c8() -> IO(Unit): valid_p("as_default", AsE.AttesterSlashing_valid(AsD.AttesterSlashing_default()))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case 3: c3()
    case 4: c4()
    case 5: c5()
    case 6: c6()
    case 7: c7()
    case _: c8()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
