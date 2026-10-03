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
import ../../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ../../types/FuluAttesterSlashing_def_generated.bend as FuluAttesterSlashing_d
import ../../types/FuluDeposit_def_generated.bend as FuluDeposit_d
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
import ../slop/validity/fulu_BeaconBlockBody_appb_l16_Deposit_generated.bend as P1_PRV
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_BeaconBlockBody_appb_l16_ProposerSlashing_generated.bend as P2_PRV
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_BeaconBlockBody_appb_l16_SignedBLSToExecutionChange_generated.bend as P3_PRV
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_BeaconBlockBody_appb_l16_SignedVoluntaryExit_generated.bend as P4_PRV
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_BeaconBlockBody_appb_l1_AttesterSlashing_generated.bend as P5_PRV
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_BeaconBlockBody_appb_l8_Attestation_generated.bend as P6_PRV
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_BeaconBlockBody_fields_generated.bend as P7_PRV
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_BeaconBlockBody_unit_l4096_b48_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/digest.bend as P9_D
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_BeaconBlockBody_vroot_l16_ProposerSlashing_cache_enc_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/digest.bend as P10_D
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_BeaconBlockBody_vroot_l16_SignedBLSToExecutionChange_cache_enc_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/digest.bend as P11_D
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_BeaconBlockBody_vroot_l16_SignedVoluntaryExit_cache_enc_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/size/BeaconBlockBody_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../../src/digest.bend as P13_D
import ../slop/constants/BeaconBlockBody_generated.bend as P13_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluBeaconBlockBody (BeaconBlockBody): its encode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluBeaconBlockBody__encode_eval__encode_eval(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> {FuluBeaconBlockBody_e.BeaconBlockBody_encode(P0_CI.TH(m)) == (P0_CI.TH(m), P0_B.Buf{P0_FD.array__thaw(U32, P0_PRV.OUTE(m)), P0_PRV.SZSM(m)}) : FuluBeaconBlockBody_d.BeaconBlockBody & P0_B.Buf}:
  P0_PRV.encode_eval(m, hok)

def FuluBeaconBlockBody__encode_spec__encode_spec(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.BeaconBlockBody(), P0_VS.bt(U32.to_nat(P0_PRV.SZSM(m)), P0_FX.limbs(P0_FD.array__slots(U32, P0_PRV.OUTE(m)))), P0_CI.VAL(m)):
  P0_PRV.encode_spec(m, hok)

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_below() -> {Pair.snd(Fulu_list_Deposit_16_d.l16_Deposit_Seq, Bool, Fulu_list_Deposit_16_d.l16_Deposit_append(Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(5n), 15}, FuluDeposit_d.Deposit_default())) == True{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_below()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_at() -> {Pair.snd(Fulu_list_Deposit_16_d.l16_Deposit_Seq, Bool, Fulu_list_Deposit_16_d.l16_Deposit_append(Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(5n), 16}, FuluDeposit_d.Deposit_default())) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_at()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_above() -> {Pair.snd(Fulu_list_Deposit_16_d.l16_Deposit_Seq, Bool, Fulu_list_Deposit_16_d.l16_Deposit_append(Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(5n), 17}, FuluDeposit_d.Deposit_default())) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_above()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_fit() -> {Pair.snd(Fulu_list_Deposit_16_d.l16_Deposit_Seq, Bool, Fulu_list_Deposit_16_d.l16_Deposit_append(Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(2n), 3}, FuluDeposit_d.Deposit_default())) == True{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_fit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_short() -> {Pair.snd(Fulu_list_Deposit_16_d.l16_Deposit_Seq, Bool, Fulu_list_Deposit_16_d.l16_Deposit_append(Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(2n), 5}, FuluDeposit_d.Deposit_default())) == False{} : Bool}:
  P1_PRV.BeaconBlockBody_serialize_vcoll_l16_Deposit_appb_short()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_below() -> {Pair.snd(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq, Bool, Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_append(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(5n), 15}, FuluProposerSlashing_d.ProposerSlashing_default())) == True{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_below()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_at() -> {Pair.snd(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq, Bool, Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_append(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(5n), 16}, FuluProposerSlashing_d.ProposerSlashing_default())) == False{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_at()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_above() -> {Pair.snd(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq, Bool, Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_append(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(5n), 17}, FuluProposerSlashing_d.ProposerSlashing_default())) == False{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_above()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_fit() -> {Pair.snd(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq, Bool, Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_append(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(2n), 3}, FuluProposerSlashing_d.ProposerSlashing_default())) == True{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_fit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_short() -> {Pair.snd(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq, Bool, Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_append(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(2n), 5}, FuluProposerSlashing_d.ProposerSlashing_default())) == False{} : Bool}:
  P2_PRV.BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_appb_short()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_below() -> {Pair.snd(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq, Bool, Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_append(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(5n), 15}, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default())) == True{} : Bool}:
  P3_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_below()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_at() -> {Pair.snd(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq, Bool, Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_append(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(5n), 16}, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default())) == False{} : Bool}:
  P3_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_at()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_above() -> {Pair.snd(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq, Bool, Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_append(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(5n), 17}, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default())) == False{} : Bool}:
  P3_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_above()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_fit() -> {Pair.snd(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq, Bool, Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_append(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(2n), 3}, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default())) == True{} : Bool}:
  P3_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_fit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_short() -> {Pair.snd(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq, Bool, Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_append(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(2n), 5}, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default())) == False{} : Bool}:
  P3_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_appb_short()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_below() -> {Pair.snd(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq, Bool, Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_append(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(5n), 15}, FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default())) == True{} : Bool}:
  P4_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_below()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_at() -> {Pair.snd(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq, Bool, Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_append(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(5n), 16}, FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default())) == False{} : Bool}:
  P4_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_at()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_above() -> {Pair.snd(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq, Bool, Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_append(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(5n), 17}, FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default())) == False{} : Bool}:
  P4_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_above()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_fit() -> {Pair.snd(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq, Bool, Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_append(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(2n), 3}, FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default())) == True{} : Bool}:
  P4_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_fit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_short() -> {Pair.snd(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq, Bool, Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_append(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(2n), 5}, FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default())) == False{} : Bool}:
  P4_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_appb_short()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l1_AttesterSlashing_appb_below() -> {Pair.snd(Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq, Bool, Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_append(Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(1n), 0}, FuluAttesterSlashing_d.AttesterSlashing_default())) == True{} : Bool}:
  P5_PRV.BeaconBlockBody_serialize_vcoll_l1_AttesterSlashing_appb_below()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l1_AttesterSlashing_appb_at() -> {Pair.snd(Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq, Bool, Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_append(Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(2n), 1}, FuluAttesterSlashing_d.AttesterSlashing_default())) == False{} : Bool}:
  P5_PRV.BeaconBlockBody_serialize_vcoll_l1_AttesterSlashing_appb_at()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l1_AttesterSlashing_appb_above() -> {Pair.snd(Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq, Bool, Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_append(Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(2n), 2}, FuluAttesterSlashing_d.AttesterSlashing_default())) == False{} : Bool}:
  P5_PRV.BeaconBlockBody_serialize_vcoll_l1_AttesterSlashing_appb_above()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_below() -> {Pair.snd(Fulu_list_Attestation_8_d.l8_Attestation_Seq, Bool, Fulu_list_Attestation_8_d.l8_Attestation_append(Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(4n), 7}, FuluAttestation_d.Attestation_default())) == True{} : Bool}:
  P6_PRV.BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_below()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_at() -> {Pair.snd(Fulu_list_Attestation_8_d.l8_Attestation_Seq, Bool, Fulu_list_Attestation_8_d.l8_Attestation_append(Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(4n), 8}, FuluAttestation_d.Attestation_default())) == False{} : Bool}:
  P6_PRV.BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_at()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_above() -> {Pair.snd(Fulu_list_Attestation_8_d.l8_Attestation_Seq, Bool, Fulu_list_Attestation_8_d.l8_Attestation_append(Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(4n), 9}, FuluAttestation_d.Attestation_default())) == False{} : Bool}:
  P6_PRV.BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_above()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_fit() -> {Pair.snd(Fulu_list_Attestation_8_d.l8_Attestation_Seq, Bool, Fulu_list_Attestation_8_d.l8_Attestation_append(Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(2n), 3}, FuluAttestation_d.Attestation_default())) == True{} : Bool}:
  P6_PRV.BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_fit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_short() -> {Pair.snd(Fulu_list_Attestation_8_d.l8_Attestation_Seq, Bool, Fulu_list_Attestation_8_d.l8_Attestation_append(Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(2n), 5}, FuluAttestation_d.Attestation_default())) == False{} : Bool}:
  P6_PRV.BeaconBlockBody_serialize_vcoll_l8_Attestation_appb_short()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_default_valid() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody_default())) == True{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_default_valid()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_proposer_slashings() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_proposer_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_proposer_slashings()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_proposer_slashings_elem() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_proposer_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(0n), 1}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_proposer_slashings_elem()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_proposer_slashings_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_proposer_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_proposer_slashings_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_proposer_slashings_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_proposer_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P7_O.refused() : P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_serialize_vrefuse_proposer_slashings_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attester_slashings() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attester_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_attester_slashings()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attester_slashings_elem() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attester_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(0n), 1}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_attester_slashings_elem()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attester_slashings_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attester_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(1n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_attester_slashings_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_attester_slashings_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attester_slashings(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_fill(1n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P7_O.refused() : P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_serialize_vrefuse_attester_slashings_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attestations() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attestations(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_attestations()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attestations_elem() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attestations(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(0n), 1}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_attestations_elem()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_attestations_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attestations(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(4n), 9}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_attestations_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_attestations_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_attestations(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Attestation_8_d.l8_Attestation_Seq{Fulu_list_Attestation_8_d.l8_Attestation_fill(4n), 9}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P7_O.refused() : P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_serialize_vrefuse_attestations_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_deposits() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_deposits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_deposits()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_deposits_elem() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_deposits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(0n), 1}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_deposits_elem()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_deposits_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_deposits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_deposits_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_deposits_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_deposits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_Deposit_16_d.l16_Deposit_Seq{Fulu_list_Deposit_16_d.l16_Deposit_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P7_O.refused() : P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_serialize_vrefuse_deposits_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_voluntary_exits() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_voluntary_exits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(0n), 2}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_voluntary_exits()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_voluntary_exits_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_voluntary_exits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_voluntary_exits_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_voluntary_exits_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_set_voluntary_exits(FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_fill(5n), 17}), FuluBeaconBlockBody_d.BeaconBlockBody_g1_default()})) == P7_O.refused() : P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_serialize_vrefuse_voluntary_exits_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_sync_aggregate() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_sync_aggregate(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P7_O.BNone{})})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_sync_aggregate()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_sync_aggregate() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_sync_aggregate(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P7_O.BNone{})})) == P7_O.refused() : P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_serialize_vrefuse_sync_aggregate()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_execution_payload() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_execution_payload(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P7_O.BNone{})})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_execution_payload()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_execution_payload() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_execution_payload(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P7_O.BNone{})})) == P7_O.refused() : P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_serialize_vrefuse_execution_payload()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_bls_to_execution_changes() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_bls_to_execution_changes(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(0n), 2})})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_bls_to_execution_changes()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_bls_to_execution_changes_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_bls_to_execution_changes(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(5n), 17})})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_bls_to_execution_changes_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vrefuse_bls_to_execution_changes_limit() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P7_O.Encoded, FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_bls_to_execution_changes(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_fill(5n), 17})})) == P7_O.refused() : P7_O.Encoded}:
  P7_PRV.BeaconBlockBody_serialize_vrefuse_bls_to_execution_changes_limit()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_blob_kzg_commitments() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, Bool, FuluBeaconBlockBody_e.BeaconBlockBody_valid(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0_default(), FuluBeaconBlockBody_d.BeaconBlockBody_g1_set_blob_kzg_commitments(FuluBeaconBlockBody_d.BeaconBlockBody_g1_default(), P7_O.Words{Array.new(U32, 0n, 0), 5})})) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_blob_kzg_commitments()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_bx_size() -> {FuluBeaconBlockBody_e.BeaconBlockBody_bx_size(P7_O.BNone{}) == (P7_O.BNone{}, 0) : P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32}:
  P7_PRV.BeaconBlockBody_serialize_vreject_bx_size()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vreject_bx_valid() -> {FuluBeaconBlockBody_e.BeaconBlockBody_bx_valid(P7_O.BNone{}) == (P7_O.BNone{}, False{}) : P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & Bool}:
  P7_PRV.BeaconBlockBody_serialize_vreject_bx_valid()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vpoison_bx_absent() -> {Pair.snd(P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, Pair.snd(Array<U32>, P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32, FuluBeaconBlockBody_e.BeaconBlockBody_bx_putk(Array.new(U32, 1n, 0), 0, P7_O.BNone{}))) == 2147483648 : U32}:
  P7_PRV.BeaconBlockBody_serialize_vpoison_bx_absent()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vpoison_bx_ok() -> {P7_O.is_poisoned(Pair.snd(P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, Pair.snd(Array<U32>, P7_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32, FuluBeaconBlockBody_e.BeaconBlockBody_bx_putk(Array.new(U32, 4n, 0), 0, FuluBeaconBlockBody_d.BeaconBlockBody_bx_wrap(FuluBeaconBlockBody_d.BeaconBlockBody_default()))))) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_serialize_vpoison_bx_ok()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_refuse_1() -> {Pair.snd(P8_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P8_O.words_new(1))) == False{} : Bool}:
  P8_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_refuse_1()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_refuse_24() -> {Pair.snd(P8_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P8_O.words_new(24))) == False{} : Bool}:
  P8_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_refuse_24()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_refuse_49() -> {Pair.snd(P8_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P8_O.words_new(49))) == False{} : Bool}:
  P8_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_refuse_49()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_accept_48() -> {Pair.snd(P8_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P8_O.words_new(48))) == True{} : Bool}:
  P8_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_accept_48()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_accept_96() -> {Pair.snd(P8_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P8_O.words_new(96))) == True{} : Bool}:
  P8_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_accept_96()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_range_lo_0() -> {Pair.snd(P8_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P8_O.words_new(0))) == True{} : Bool}:
  P8_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_range_lo_0()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_range_hi_196608() -> {Pair.snd(P8_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P8_O.words_new(196608))) == True{} : Bool}:
  P8_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_range_hi_196608()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vunit_l4096_b48_range_above_196656() -> {Pair.snd(P8_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P8_O.words_new(196656))) == False{} : Bool}:
  P8_PRV.BeaconBlockBody_serialize_vunit_l4096_b48_range_above_196656()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_enc() -> {Pair.fst(Array<U32>, Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq & U32, Fulu_list_ProposerSlashing_16_e.l16_ProposerSlashing_putn(Array.new(U32, 9n, 0), 0, P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_default(), FuluProposerSlashing_d.ProposerSlashing_set_signed_header_1(FuluProposerSlashing_d.ProposerSlashing_default(), FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_bx_wrap(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_set_message(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_default(), FuluBeaconBlockHeader_d.BeaconBlockHeader_set_slot(FuluBeaconBlockHeader_d.BeaconBlockHeader_default(), P9_O.U64{1, 0}))))), FuluProposerSlashing_d.ProposerSlashing_default()), FuluProposerSlashing_d.ProposerSlashing_set_signed_header_1(FuluProposerSlashing_d.ProposerSlashing_default(), FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_bx_wrap(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_set_message(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_default(), FuluBeaconBlockHeader_d.BeaconBlockHeader_set_slot(FuluBeaconBlockHeader_d.BeaconBlockHeader_default(), P9_O.U64{1, 0}))))))) == Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 0, 1), 208, 1) : Array<U32>}:
  P9_PRV.BeaconBlockBody_serialize_vcoll_l16_ProposerSlashing_enc()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_enc() -> {Pair.fst(Array<U32>, Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq & U32, Fulu_list_SignedBLSToExecutionChange_16_e.l16_SignedBLSToExecutionChange_putn(Array.new(U32, 8n, 0), 0, P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_default(), FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_set_message(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default(), FuluBLSToExecutionChange_d.BLSToExecutionChange_set_validator_index(FuluBLSToExecutionChange_d.BLSToExecutionChange_default(), P10_O.U64{1, 0}))), FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default()), FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_set_message(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default(), FuluBLSToExecutionChange_d.BLSToExecutionChange_set_validator_index(FuluBLSToExecutionChange_d.BLSToExecutionChange_default(), P10_O.U64{1, 0}))))) == Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 1), 86, 1) : Array<U32>}:
  P10_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedBLSToExecutionChange_enc()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_enc() -> {Pair.fst(Array<U32>, Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq & U32, Fulu_list_SignedVoluntaryExit_16_e.l16_SignedVoluntaryExit_putn(Array.new(U32, 7n, 0), 0, P11_PRV.sa(P11_PRV.sa(P11_PRV.sa(Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_default(), FuluSignedVoluntaryExit_d.SignedVoluntaryExit_set_message(FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default(), FuluVoluntaryExit_d.VoluntaryExit_set_epoch(FuluVoluntaryExit_d.VoluntaryExit_default(), P11_O.U64{1, 0}))), FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default()), FuluSignedVoluntaryExit_d.SignedVoluntaryExit_set_message(FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default(), FuluVoluntaryExit_d.VoluntaryExit_set_epoch(FuluVoluntaryExit_d.VoluntaryExit_default(), P11_O.U64{1, 0}))))) == Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 1), 56, 1) : Array<U32>}:
  P11_PRV.BeaconBlockBody_serialize_vcoll_l16_SignedVoluntaryExit_enc()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_ms_size() -> {Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, U32, FuluBeaconBlockBody_e.BeaconBlockBody_size(FuluBeaconBlockBody_d.BeaconBlockBody_default())) == 936 : U32}:
  P12_PRV.BeaconBlockBody_ms_size()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_ms_bxsize_BeaconBlockBody() -> {Pair.snd(P12_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, FuluBeaconBlockBody_e.BeaconBlockBody_bx_size(P12_O.BNone{})) == 0 : U32}:
  P12_PRV.BeaconBlockBody_ms_bxsize_BeaconBlockBody()

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_mc_bxpoison_BeaconBlockBody(out: Array<U32>, pos: U32) -> {FuluBeaconBlockBody_e.BeaconBlockBody_bx_putk(out, pos, P13_O.BNone{}) == (out, (P13_O.BNone{}, P13_O.poison())) : Array<U32> & (P13_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32)}:
  P13_PRV.BeaconBlockBody_mc_bxpoison_BeaconBlockBody(out, pos)

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_mc_bxcount_BeaconBlockBody(out: Array<U32>, pos: U32) -> {Pair.snd(P13_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, Pair.snd(Array<U32>, (P13_O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32), FuluBeaconBlockBody_e.BeaconBlockBody_bx_putn(out, pos, P13_O.BNone{}))) == 0 : U32}:
  P13_PRV.BeaconBlockBody_mc_bxcount_BeaconBlockBody(out, pos)

def FuluBeaconBlockBody__serialize_valid__BeaconBlockBody_mc_ser() -> {FuluBeaconBlockBody_e.BeaconBlockBody_serialize(FuluBeaconBlockBody_d.BeaconBlockBody_set_randao_reveal(FuluBeaconBlockBody_d.BeaconBlockBody_set_graffiti(FuluBeaconBlockBody_d.BeaconBlockBody_set_eth1_data(FuluBeaconBlockBody_d.BeaconBlockBody_default(), FuluEth1Data_d.Eth1Data_seed(2271570273)), FuluBytes32_d.b32_seed(2271570324)), FuluBytes96_d.b96_seed(2271570358))) == (Pair.fst(FuluBeaconBlockBody_d.BeaconBlockBody, P13_B.Buf, FuluBeaconBlockBody_e.BeaconBlockBody_encode(FuluBeaconBlockBody_d.BeaconBlockBody_set_randao_reveal(FuluBeaconBlockBody_d.BeaconBlockBody_set_graffiti(FuluBeaconBlockBody_d.BeaconBlockBody_set_eth1_data(FuluBeaconBlockBody_d.BeaconBlockBody_default(), FuluEth1Data_d.Eth1Data_seed(2271570273)), FuluBytes32_d.b32_seed(2271570324)), FuluBytes96_d.b96_seed(2271570358)))), P13_O.encoded(Pair.snd(FuluBeaconBlockBody_d.BeaconBlockBody, P13_B.Buf, FuluBeaconBlockBody_e.BeaconBlockBody_encode(FuluBeaconBlockBody_d.BeaconBlockBody_set_randao_reveal(FuluBeaconBlockBody_d.BeaconBlockBody_set_graffiti(FuluBeaconBlockBody_d.BeaconBlockBody_set_eth1_data(FuluBeaconBlockBody_d.BeaconBlockBody_default(), FuluEth1Data_d.Eth1Data_seed(2271570273)), FuluBytes32_d.b32_seed(2271570324)), FuluBytes96_d.b96_seed(2271570358)))))) : FuluBeaconBlockBody_d.BeaconBlockBody & P13_O.Encoded}:
  P13_PRV.BeaconBlockBody_mc_ser()

