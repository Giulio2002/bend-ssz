import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/FuluBytes1_def_generated.bend as FuluBytes1_d
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/uint8_encode_ssz_generated.bend as uint8_e
import ../../types/FuluBytes1_encode_ssz_generated.bend as FuluBytes1_e
import ../../types/FuluContributionAndProof_def_generated.bend as FuluContributionAndProof_d
import ../../types/FuluContributionAndProof_encode_ssz_generated.bend as FuluContributionAndProof_e
import ../../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ../../types/FuluAttestation_encode_ssz_generated.bend as FuluAttestation_e
import ../../types/FuluTransaction_encode_ssz_generated.bend as FuluTransaction_e
import ../../types/FuluDataColumnsByRootIdentifier_def_generated.bend as FuluDataColumnsByRootIdentifier_d
import ../../types/FuluDataColumnsByRootIdentifier_encode_ssz_generated.bend as FuluDataColumnsByRootIdentifier_e

# Invalid representable objects (finite regressions, not laws). Each case
# builds a value with the raw record constructors - a state no decoder or
# checked setter produces - and prints whether the public checked encoder
# `<Name>_serialize` accepted it. tests_generated/invalid_objects.py compares
# every line with the expected answer; each invalid case has a valid control.

def show(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ "=" ++ O.pick_str(ok))

def snd_enc(label: String, pair: FuluAttestation_d.Attestation & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def snd_dc(label: String, pair: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def snd_cp(label: String, pair: FuluContributionAndProof_d.ContributionAndProof & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def snd_tx(label: String, pair: O.Words & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def att_put(pair: FuluAttestation_d.Attestation & O.Bits) -> FuluAttestation_d.Attestation:
  (o, old) = pair
  o

def att_with(bits: O.Bits) -> FuluAttestation_d.Attestation:
  att_put(FuluAttestation_d.Attestation_swap_aggregation_bits(FuluAttestation_d.Attestation_default(), bits))

def dc_put(pair: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier & O.Words) -> FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier:
  (o, old) = pair
  o

def dc_with(cols: O.Words) -> FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier:
  dc_put(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier_swap_columns(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier_default(), cols))

def words2(+a: U32, +b: U32) -> Array<U32>:
  Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, a), 1, b)

def main() -> IO(Unit):
  do IO<Unit>:
    # a uint8 above 255, and a valid one
    show("uint8_300", uint8_e.uint8_serialize(300))
    show("uint8_200", uint8_e.uint8_serialize(200))
    # a one-byte vector with bits past its byte, and a valid one
    show("bytes1_tail", FuluBytes1_e.Bytes1_serialize(FuluBytes1_d.Bytes1{511}))
    show("bytes1_ok", FuluBytes1_e.Bytes1_serialize(FuluBytes1_d.Bytes1{127}))
    # a byte list: 5 bytes with the last word's slack set; a clean one; storage too small
    snd_tx("tx_slack", FuluTransaction_e.Transaction_serialize(O.Words{words2(67305985, 65289), 5}))
    snd_tx("tx_ok", FuluTransaction_e.Transaction_serialize(O.Words{words2(67305985, 9), 5}))
    snd_tx("tx_capacity", FuluTransaction_e.Transaction_serialize(O.Words{Array.new(U32, 1n, 0), 100}))
    # a bit list one past its limit (131072), and one at the limit
    snd_enc("att_bits_over", FuluAttestation_e.Attestation_serialize(att_with(O.Bits{Array.new(U32, 13n, 0), 131073})))
    snd_enc("att_bits_limit", FuluAttestation_e.Attestation_serialize(att_with(O.Bits{Array.new(U32, 13n, 0), 131072})))
    # a packed list of uint64 one past its limit (128), one at it, one not a multiple of 8
    snd_dc("columns_over", FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_serialize(dc_with(O.Words{Array.new(U32, 9n, 0), 1032})))
    snd_dc("columns_limit", FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_serialize(dc_with(O.Words{Array.new(U32, 9n, 0), 1024})))
    snd_dc("columns_unit", FuluDataColumnsByRootIdentifier_e.DataColumnsByRootIdentifier_serialize(dc_with(O.Words{Array.new(U32, 9n, 0), 1020})))
    # a boxed field with no value, and the default
    snd_cp("box_empty", FuluContributionAndProof_e.ContributionAndProof_serialize(FuluContributionAndProof_d.ContributionAndProof{O.U64{1, 0}, O.BNone{}, FuluBytes96_d.Bytes96{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}))
    snd_cp("box_ok", FuluContributionAndProof_e.ContributionAndProof_serialize(FuluContributionAndProof_d.ContributionAndProof_default()))
