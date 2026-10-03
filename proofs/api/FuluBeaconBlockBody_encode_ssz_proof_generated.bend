import Base
import ../../src/obj.bend as P0_O
import ../../src/primitives.bend as P0_I
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/FuluVoluntaryExit_def_generated.bend as FuluVoluntaryExit_d
import ../../types/FuluSignedVoluntaryExit_def_generated.bend as FuluSignedVoluntaryExit_d
import ../../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
import ../../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
import ../../types/FuluProposerSlashing_def_generated.bend as FuluProposerSlashing_d
import ../../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../../types/FuluBLSToExecutionChange_def_generated.bend as FuluBLSToExecutionChange_d
import ../../types/FuluSignedBLSToExecutionChange_def_generated.bend as FuluSignedBLSToExecutionChange_d
import ../../types/Fulu_list_ProposerSlashing_16_def_generated.bend as Fulu_list_ProposerSlashing_16_d
import ../../types/Fulu_list_ProposerSlashing_16_encode_ssz_generated.bend as Fulu_list_ProposerSlashing_16_e
import ../../types/Fulu_list_AttesterSlashing_1_def_generated.bend as Fulu_list_AttesterSlashing_1_d
import ../../types/Fulu_list_Attestation_8_def_generated.bend as Fulu_list_Attestation_8_d
import ../../types/Fulu_list_Deposit_16_def_generated.bend as Fulu_list_Deposit_16_d
import ../../types/Fulu_list_SignedVoluntaryExit_16_def_generated.bend as Fulu_list_SignedVoluntaryExit_16_d
import ../../types/Fulu_list_SignedVoluntaryExit_16_encode_ssz_generated.bend as Fulu_list_SignedVoluntaryExit_16_e
import ../../types/Fulu_list_SignedBLSToExecutionChange_16_def_generated.bend as Fulu_list_SignedBLSToExecutionChange_16_d
import ../../types/Fulu_list_SignedBLSToExecutionChange_16_encode_ssz_generated.bend as Fulu_list_SignedBLSToExecutionChange_16_e
import ../../types/Fulu_list_bytevec_48_4096_encode_ssz_generated.bend as Fulu_list_bytevec_48_4096_e
import ../../types/FuluBeaconBlockBody_def_generated.bend as FuluBeaconBlockBody_d
import ../../types/FuluBeaconBlockBody_encode_ssz_generated.bend as FuluBeaconBlockBody_e
import ../../types/schema.bend as P0_S
import ../../types/primitive.bend as P0_P
import ../../spec/codec.bend as P0_Codec
import ../../spec/layout.bend as P0_Layout
import ../../spec/primitives.bend as P0_SP
import ../../spec/fulu_schemas.bend as P0_Spec
import ../compact/found_generated.bend as P0_FD
import ../compact/arith.bend as P0_A
import ../../proofs/nat_order.bend as P0_Order
import ../obj/spec_fixed.bend as P0_FX
import ../obj/vspec.bend as P0_VS
import ../obj/vbuf.bend as P0_VB
import ../obj/vua.bend as P0_UA
import ../obj/vuw.bend as P0_UW
import ../obj/vuwd.bend as P0_WD
import ../obj/vcopy.bend as P0_VC
import ../obj/vrecx.bend as P0_VRX
import ../obj/vcont.bend as P0_VCN
import ../obj/vua_lay.bend as P0_LY
import ../obj/vconts.bend as P0_CS
import ../obj/spec_bits_generated.bend as P0_FB
import ../obj/dk.bend as P0_DK
import ../obj/vuwv_b96_generated.bend as P0_V_b96
import ../obj/encx_recs_generated.bend as P0_ER
import ../obj/vuwv_b32_generated.bend as P0_V_b32
import ../obj/encx_l16_ProposerSlashing_generated.bend as P0_EW_l16_ProposerSlashing
import ../obj/encx_l1_AttesterSlashing_generated.bend as P0_EX_l1_AttesterSlashing
import ../obj/encx_l8_Attestation_generated.bend as P0_EX_l8_Attestation
import ../obj/encx_l16_Deposit_generated.bend as P0_EW_l16_Deposit
import ../obj/encx_l16_SignedVoluntaryExit_generated.bend as P0_EW_l16_SignedVoluntaryExit
import ../obj/encx_ExecutionPayload_iface_generated.bend as P0_EC_ExecutionPayload
import ../obj/encx_ExecutionPayload_size_generated.bend as P0_ES_ExecutionPayload
import ../obj/encx_l16_SignedBLSToExecutionChange_generated.bend as P0_EW_l16_SignedBLSToExecutionChange
import ../obj/encx_l4096_b48_generated.bend as P0_EX_l4096_b48
import ../obj/encx_ExecutionRequests_iface_generated.bend as P0_EX_ExecutionRequests
import ../obj/encx_BeaconBlockBody_generated.bend as P0_K
import ../../src/buffer.bend as P0_B
import ../../spec/decoding_relation.bend as P0_Decoding
import ../obj/vlist.bend as P0_VL
import ../obj/vdepth.bend as P0_VD
import ../obj/vvlz_generated.bend as P0_VZG
import ../obj/vuwb.bend as P0_UWB
import ../obj/vvle.bend as P0_VE2
import ../obj/encx_BeaconBlockBody_iface_generated.bend as P0_CI
import ../obj/encx_BeaconBlockBody_size_generated.bend as P0_Z
import ../obj/var_codec_BeaconBlockBody_enc_generated.bend as P0_PRV
import ../../src/obj.bend as P1_O
import ../slop/validity/fulu_BeaconBlockBody_fields_generated.bend as P1_PRV
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_BeaconBlockBody_unit_l4096_b48_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/digest.bend as P3_D
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_BeaconBlockBody_vroot_l16_ProposerSlashing_cache_enc_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/digest.bend as P4_D
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_BeaconBlockBody_vroot_l16_SignedBLSToExecutionChange_cache_enc_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/digest.bend as P5_D
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_BeaconBlockBody_vroot_l16_SignedVoluntaryExit_cache_enc_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/size/BeaconBlockBody_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../../src/digest.bend as P7_D
import ../slop/constants/BeaconBlockBody_generated.bend as P7_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluBeaconBlockBody (BeaconBlockBody): its encode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluBeaconBlockBody__encode_eval__encode_eval(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> {FuluBeaconBlockBody_e.BeaconBlockBody_encode(P0_CI.TH(m)) == (P0_CI.TH(m), P0_B.Buf{P0_FD.array__thaw(U32, P0_PRV.OUTE(m)), P0_PRV.SZSM(m)}) : FuluBeaconBlockBody_d.BeaconBlockBody & P0_B.Buf}:
  P0_PRV.encode_eval(m, hok)

def FuluBeaconBlockBody__encode_spec__encode_spec(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.BeaconBlockBody(), P0_VS.bt(U32.to_nat(P0_PRV.SZSM(m)), P0_FX.limbs(P0_FD.array__slots(U32, P0_PRV.OUTE(m)))), P0_CI.VAL(m)):
  P0_PRV.encode_spec(m, hok)

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_default_valid() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody_default())) == True{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_default_valid()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_proposer_slashings() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_proposer_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_proposer_slashings()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_proposer_slashings_elem() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_proposer_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(0n), 1}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_proposer_slashings_elem()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_proposer_slashings_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_proposer_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_proposer_slashings_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_proposer_slashings_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P1_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_proposer_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P1_O.refused() : P1_O.Encoded}:
  P1_PRV.BeaconBlockBody_serialize_vrefuse_proposer_slashings_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attester_slashings() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attester_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_attester_slashings()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attester_slashings_elem() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attester_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(0n), 1}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_attester_slashings_elem()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attester_slashings_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attester_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(1n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_attester_slashings_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_attester_slashings_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P1_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attester_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(1n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P1_O.refused() : P1_O.Encoded}:
  P1_PRV.BeaconBlockBody_serialize_vrefuse_attester_slashings_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attestations() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attestations(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_attestations()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attestations_elem() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attestations(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(0n), 1}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_attestations_elem()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attestations_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attestations(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(4n), 9}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_attestations_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_attestations_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P1_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attestations(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(4n), 9}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P1_O.refused() : P1_O.Encoded}:
  P1_PRV.BeaconBlockBody_serialize_vrefuse_attestations_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_deposits() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_deposits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_deposits()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_deposits_elem() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_deposits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(0n), 1}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_deposits_elem()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_deposits_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_deposits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_deposits_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_deposits_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P1_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_deposits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P1_O.refused() : P1_O.Encoded}:
  P1_PRV.BeaconBlockBody_serialize_vrefuse_deposits_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_voluntary_exits() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_voluntary_exits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_voluntary_exits()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_voluntary_exits_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_voluntary_exits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_voluntary_exits_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_voluntary_exits_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P1_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_voluntary_exits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P1_O.refused() : P1_O.Encoded}:
  P1_PRV.BeaconBlockBody_serialize_vrefuse_voluntary_exits_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_sync_aggregate() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_sync_aggregate(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P1_O.BNone{})})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_sync_aggregate()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_sync_aggregate() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P1_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_sync_aggregate(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P1_O.BNone{})})) == P1_O.refused() : P1_O.Encoded}:
  P1_PRV.BeaconBlockBody_serialize_vrefuse_sync_aggregate()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_execution_payload() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_execution_payload(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P1_O.BNone{})})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_execution_payload()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_execution_payload() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P1_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_execution_payload(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P1_O.BNone{})})) == P1_O.refused() : P1_O.Encoded}:
  P1_PRV.BeaconBlockBody_serialize_vrefuse_execution_payload()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_bls_to_execution_changes() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_bls_to_execution_changes(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(0n), 2})})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_bls_to_execution_changes()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_bls_to_execution_changes_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_bls_to_execution_changes(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(5n), 17})})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_bls_to_execution_changes_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_bls_to_execution_changes_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P1_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_bls_to_execution_changes(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(5n), 17})})) == P1_O.refused() : P1_O.Encoded}:
  P1_PRV.BeaconBlockBody_serialize_vrefuse_bls_to_execution_changes_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_blob_kzg_commitments() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_blob_kzg_commitments(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P1_O.Words{Array.new(U32, 0n, 0), 5})})) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_blob_kzg_commitments()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_bx_size() -> {FuluBeaconBlockBody_e.BeaconBlockBody_bx_size(P1_O.BNone{}) == (P1_O.BNone{}, 0) : P1_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32}:
  P1_PRV.BeaconBlockBody_serialize_vreject_bx_size()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_bx_valid() -> {FuluBeaconBlockBody_e.BeaconBlockBody_bx_valid(P1_O.BNone{}) == (P1_O.BNone{}, False{}) : P1_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & Bool}:
  P1_PRV.BeaconBlockBody_serialize_vreject_bx_valid()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vpoison_bx_absent() -> {Pair.snd(P1_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, Pair.snd(Array<U32>, P1_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32, FuluBeaconBlockBody_e.BeaconBlockBody_bx_putk(Array.new(U32, 1n, 0), 0, P1_O.BNone{}))) == 2147483648 : U32}:
  P1_PRV.BeaconBlockBody_serialize_vpoison_bx_absent()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vpoison_bx_ok() -> {P1_O.is_poisoned(Pair.snd(P1_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, Pair.snd(Array<U32>, P1_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32, FuluBeaconBlockBody_e.BeaconBlockBody_bx_putk(Array.new(U32, 4n, 0), 0, FuluBeaconBlockBody_d.BeaconBlockBody_bx_wrap(FuluBeaconBlockBody_d.BeaconBlockBody_default()))))) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vpoison_bx_ok()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_refuse_1() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P2_O.words_new(1))) == False{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_refuse_1()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_refuse_24() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P2_O.words_new(24))) == False{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_refuse_24()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_refuse_49() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P2_O.words_new(49))) == False{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_refuse_49()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_accept_48() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P2_O.words_new(48))) == True{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_accept_48()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_accept_96() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P2_O.words_new(96))) == True{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_accept_96()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_range_lo_0() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P2_O.words_new(0))) == True{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_range_lo_0()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_range_hi_196608() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P2_O.words_new(196608))) == True{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_range_hi_196608()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_range_above_196656() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P2_O.words_new(196656))) == False{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_range_above_196656()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_enc() -> {Pair.fst(Array<U32>, Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq & U32, Fulu_list_ProposerSlashing_16_e.l16_ProposerSlashing_putn(Array.new(U32, 9n, 0), 0, P3_PRV.sa(P3_PRV.sa(P3_PRV.sa(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_default(), FuluProposerSlashing_d.ProposerSlashing_set_signed_header_1(FuluProposerSlashing_d.ProposerSlashing_default(), FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_bx_wrap(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_set_message(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_default(), FuluBeaconBlockHeader_d.BeaconBlockHeader_set_slot(FuluBeaconBlockHeader_d.BeaconBlockHeader_default(), P3_O.U64{1, 0}))))), FuluProposerSlashing_d.ProposerSlashing_default()), FuluProposerSlashing_d.ProposerSlashing_set_signed_header_1(FuluProposerSlashing_d.ProposerSlashing_default(), FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_bx_wrap(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_set_message(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_default(), FuluBeaconBlockHeader_d.BeaconBlockHeader_set_slot(FuluBeaconBlockHeader_d.BeaconBlockHeader_default(), P3_O.U64{1, 0}))))))) == Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 0, 1), 208, 1) : Array<U32>}:
  P3_PRV.BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_enc()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_enc() -> {Pair.fst(Array<U32>, Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq & U32, Fulu_list_SignedBLSToExecutionChange_16_e.l16_SignedBLSToExecutionChange_putn(Array.new(U32, 8n, 0), 0, P4_PRV.sa(P4_PRV.sa(P4_PRV.sa(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_default(), FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_set_message(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default(), FuluBLSToExecutionChange_d.BLSToExecutionChange_set_validator_index(FuluBLSToExecutionChange_d.BLSToExecutionChange_default(), P4_O.U64{1, 0}))), FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default()), FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_set_message(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default(), FuluBLSToExecutionChange_d.BLSToExecutionChange_set_validator_index(FuluBLSToExecutionChange_d.BLSToExecutionChange_default(), P4_O.U64{1, 0}))))) == Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 1), 86, 1) : Array<U32>}:
  P4_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_enc()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_enc() -> {Pair.fst(Array<U32>, Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq & U32, Fulu_list_SignedVoluntaryExit_16_e.l16_SignedVoluntaryExit_putn(Array.new(U32, 7n, 0), 0, P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_default(), FuluSignedVoluntaryExit_d.SignedVoluntaryExit_set_message(FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default(), FuluVoluntaryExit_d.VoluntaryExit_set_epoch(FuluVoluntaryExit_d.VoluntaryExit_default(), P5_O.U64{1, 0}))), FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default()), FuluSignedVoluntaryExit_d.SignedVoluntaryExit_set_message(FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default(), FuluVoluntaryExit_d.VoluntaryExit_set_epoch(FuluVoluntaryExit_d.VoluntaryExit_default(), P5_O.U64{1, 0}))))) == Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 1), 56, 1) : Array<U32>}:
  P5_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_enc()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_ms_size() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, U32, FuluBeaconBlockBody_e.BeaconBlockBody_size(FuluBeaconBlockBody_d.BeaconBlockBody_default())) == 936 : U32}:
  P6_PRV.BeaconBlockBody_ms_size()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_ms_bxsize_BeaconBlockBody() -> {Pair.snd(P6_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, FuluBeaconBlockBody_e.BeaconBlockBody_bx_size(P6_O.BNone{})) == 0 : U32}:
  P6_PRV.BeaconBlockBody_ms_bxsize_BeaconBlockBody()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_mc_bxpoison_BeaconBlockBody(out: Array<U32>, pos: U32) -> {FuluBeaconBlockBody_e.BeaconBlockBody_bx_putk(out, pos, P7_O.BNone{}) == (out, (P7_O.BNone{}, P7_O.poison())) : Array<U32> & (P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32)}:
  P7_PRV.BeaconBlockBody_mc_bxpoison_BeaconBlockBody(out, pos)

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_mc_bxcount_BeaconBlockBody(out: Array<U32>, pos: U32) -> {Pair.snd(P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, Pair.snd(Array<U32>, (P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32), FuluBeaconBlockBody_e.BeaconBlockBody_bx_putn(out, pos, P7_O.BNone{}))) == 0 : U32}:
  P7_PRV.BeaconBlockBody_mc_bxcount_BeaconBlockBody(out, pos)

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_mc_ser() -> {FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody_set_randao_reveal(FuluBeaconBlockBody_d.BeaconBlockBody_set_graffiti(FuluBeaconBlockBody_d.BeaconBlockBody_set_eth1_data(FuluBeaconBlockBody_d.BeaconBlockBody_default(), FuluEth1Data_d.Eth1Data_seed(2271570273)), FuluBytes32_d.b32_seed(2271570324)), FuluBytes96_d.b96_seed(2271570358))) == (Pair.fst(FuluBeaconBlockBody_d.BeaconBlockBody, P7_B.Buf, FuluBeaconBlockBody_e.BeaconBlockBody_encode(FuluBeaconBlockBody_d.BeaconBlockBody_set_randao_reveal(FuluBeaconBlockBody_d.BeaconBlockBody_set_graffiti(FuluBeaconBlockBody_d.BeaconBlockBody_set_eth1_data(FuluBeaconBlockBody_d.BeaconBlockBody_default(), FuluEth1Data_d.Eth1Data_seed(2271570273)), FuluBytes32_d.b32_seed(2271570324)), FuluBytes96_d.b96_seed(2271570358)))), P7_O.encoded(Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_B.Buf, FuluBeaconBlockBody_e.BeaconBlockBody_encode(FuluBeaconBlockBody_d.BeaconBlockBody_set_randao_reveal(FuluBeaconBlockBody_d.BeaconBlockBody_set_graffiti(FuluBeaconBlockBody_d.BeaconBlockBody_set_eth1_data(FuluBeaconBlockBody_d.BeaconBlockBody_default(), FuluEth1Data_d.Eth1Data_seed(2271570273)), FuluBytes32_d.b32_seed(2271570324)), FuluBytes96_d.b96_seed(2271570358)))))) : FuluBeaconBlockBody_d.BeaconBlockBody & P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_mc_ser()

