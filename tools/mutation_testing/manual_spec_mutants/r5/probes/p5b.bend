import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/FuluSignedBeaconBlock_def_generated.bend as SbD
import ../../../../../types/FuluSignedBeaconBlock_encode_ssz_generated.bend as SbE
import ../../../../../types/FuluBeaconBlock_def_generated.bend as BkD
import ../../../../../types/FuluBeaconBlockBody_def_generated.bend as BdD
import ../../../../../types/FuluSignedAggregateAndProof_def_generated.bend as SaD
import ../../../../../types/FuluSignedAggregateAndProof_encode_ssz_generated.bend as SaE
import ../../../../../types/FuluAggregateAndProof_def_generated.bend as ApD
import ../../../../../types/FuluAttestation_def_generated.bend as AtD
import ../../../../../types/SmallTestStruct_def_generated.bend as SmD
import ../../../../../types/proglist_SmallTestStruct_def_generated.bend as PsD
import ../../../../../types/proglist_SmallTestStruct_encode_ssz_generated.bend as PsE
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-5 probe b: X_valid and X_serialize of the signed wrappers (SignedBeaconBlock, SignedAggregateAndProof) whose message holds an
# invalid field, built with public defaults and setters only. SSZ_CASE:
#  1 SignedBeaconBlock default (control: valid=1, ok=1)
#  2 SignedBeaconBlock whose message.body.blob_kzg_commitments is O.Words{16 words, 49} (49 bytes: not a multiple of 48) -> valid=0, ok=0
#  3 SignedAggregateAndProof default (control)
#  4 SignedAggregateAndProof whose message.aggregate.aggregation_bits claims 131073 bits (> 131072) -> valid=0, ok=0
#  5 ProgressiveList[SmallTestStruct] [SmallTestStruct{65536, 0}] (uint16 out of range): pl_SmallTestStruct_valid -> 0

def enc_ok(label: String, ok: Bool, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{x, b}: IO.print(label ++ " valid=" ++ O.pick_str(ok) ++ " ser_ok=" ++ O.pick_str(x))

def sb_ser(label: String, ok: Bool, pair: SbD.SignedBeaconBlock & O.Encoded) -> IO(Unit):
  (o, e) = pair
  enc_ok(label, ok, e)

def show_sb(label: String, pair: SbD.SignedBeaconBlock & Bool) -> IO(Unit):
  (o, ok) = pair
  sb_ser(label, ok, SbE.SignedBeaconBlock_serialize(o))

def sa_ser(label: String, ok: Bool, pair: SaD.SignedAggregateAndProof & O.Encoded) -> IO(Unit):
  (o, e) = pair
  enc_ok(label, ok, e)

def show_sa(label: String, pair: SaD.SignedAggregateAndProof & Bool) -> IO(Unit):
  (o, ok) = pair
  sa_ser(label, ok, SaE.SignedAggregateAndProof_serialize(o))

def bad_body() -> BdD.BeaconBlockBody: BdD.BeaconBlockBody_set_blob_kzg_commitments(BdD.BeaconBlockBody_default(), O.Words{Array.new(U32, 4n, 0), 49})
def bad_sb() -> SbD.SignedBeaconBlock: SbD.SignedBeaconBlock_set_message(SbD.SignedBeaconBlock_default(), BkD.BeaconBlock_set_body(BkD.BeaconBlock_default(), BdD.BeaconBlockBody_bx_wrap(bad_body())))
def bad_att() -> AtD.Attestation: AtD.Attestation_set_aggregation_bits(AtD.Attestation_default(), O.Bits{Array.new(U32, 13n, 0), 131073})
def bad_sa() -> SaD.SignedAggregateAndProof: SaD.SignedAggregateAndProof_set_message(SaD.SignedAggregateAndProof_default(), ApD.AggregateAndProof_set_aggregate(ApD.AggregateAndProof_default(), AtD.Attestation_bx_wrap(bad_att())))

def show_ps(label: String, pair: PsD.pl_SmallTestStruct_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: show_sb("c1 sbb default", SbE.SignedBeaconBlock_valid(SbD.SignedBeaconBlock_default()))
    case 2: show_sb("c2 sbb bad kzg", SbE.SignedBeaconBlock_valid(bad_sb()))
    case 3: show_sa("c3 saap default", SaE.SignedAggregateAndProof_valid(SaD.SignedAggregateAndProof_default()))
    case 4: show_sa("c4 saap bad bits", SaE.SignedAggregateAndProof_valid(bad_sa()))
    case _: show_ps("c5 pl_small 65536", PsE.pl_SmallTestStruct_valid(PsD.pl_SmallTestStruct_Seq{Array.new(SmD.SmallTestStruct, 0n, SmD.SmallTestStruct{65536, 0}), 1}))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
