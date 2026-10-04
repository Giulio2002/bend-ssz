import Base
import ../../src/obj.bend as P0_O
import ../../src/primitives.bend as P0_I
import ../../types/FuluPendingConsolidation_def_generated.bend as FuluPendingConsolidation_d
import ../../types/FuluPendingPartialWithdrawal_def_generated.bend as FuluPendingPartialWithdrawal_d
import ../../types/FuluHistoricalSummary_def_generated.bend as FuluHistoricalSummary_d
import ../../types/Fulu_vec_bytevec_32_8192_encode_ssz_generated.bend as Fulu_vec_bytevec_32_8192_e
import ../../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../../types/FuluPendingDeposit_def_generated.bend as FuluPendingDeposit_d
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/Fulu_list_bytevec_32_16777216_encode_ssz_generated.bend as Fulu_list_bytevec_32_16777216_e
import ../../types/Fulu_list_Eth1Data_2048_def_generated.bend as Fulu_list_Eth1Data_2048_d
import ../../types/Fulu_list_Eth1Data_2048_encode_ssz_generated.bend as Fulu_list_Eth1Data_2048_e
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d
import ../../types/Fulu_list_Validator_1099511627776_encode_ssz_generated.bend as Fulu_list_Validator_1099511627776_e
import ../../types/Fulu_list_uint64_1099511627776_def_generated.bend as Fulu_list_uint64_1099511627776_d
import ../../types/Fulu_list_uint64_1099511627776_encode_ssz_generated.bend as Fulu_list_uint64_1099511627776_e
import ../../types/Fulu_vec_bytevec_32_65536_encode_ssz_generated.bend as Fulu_vec_bytevec_32_65536_e
import ../../types/Fulu_vec_uint64_8192_encode_ssz_generated.bend as Fulu_vec_uint64_8192_e
import ../../types/Fulu_list_uint8_1099511627776_def_generated.bend as Fulu_list_uint8_1099511627776_d
import ../../types/Fulu_list_uint8_1099511627776_encode_ssz_generated.bend as Fulu_list_uint8_1099511627776_e
import ../../types/Fulu_list_HistoricalSummary_16777216_def_generated.bend as Fulu_list_HistoricalSummary_16777216_d
import ../../types/Fulu_list_HistoricalSummary_16777216_encode_ssz_generated.bend as Fulu_list_HistoricalSummary_16777216_e
import ../../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as Fulu_list_PendingDeposit_134217728_d
import ../../types/Fulu_list_PendingDeposit_134217728_encode_ssz_generated.bend as Fulu_list_PendingDeposit_134217728_e
import ../../types/Fulu_list_PendingPartialWithdrawal_134217728_def_generated.bend as Fulu_list_PendingPartialWithdrawal_134217728_d
import ../../types/Fulu_list_PendingPartialWithdrawal_134217728_encode_ssz_generated.bend as Fulu_list_PendingPartialWithdrawal_134217728_e
import ../../types/Fulu_list_PendingConsolidation_262144_def_generated.bend as Fulu_list_PendingConsolidation_262144_d
import ../../types/Fulu_list_PendingConsolidation_262144_encode_ssz_generated.bend as Fulu_list_PendingConsolidation_262144_e
import ../../types/Fulu_vec_uint64_64_encode_ssz_generated.bend as Fulu_vec_uint64_64_e
import ../../types/FuluBeaconState_def_generated.bend as FuluBeaconState_d
import ../../types/FuluBeaconState_encode_ssz_generated.bend as FuluBeaconState_e
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
import ../../spec/nat_bytes.bend as P0_N
import ../obj/vuwv_b32_generated.bend as P0_V_b32
import ../obj/encx_recs_generated.bend as P0_ER
import ../obj/vuwv_bv4_generated.bend as P0_V_bv4
import ../obj/vuwv_v8192_b32_generated.bend as P0_V_v8192_b32
import ../obj/vuwv_v65536_b32_generated.bend as P0_V_v65536_b32
import ../obj/vuwv_v8192_u64_generated.bend as P0_V_v8192_u64
import ../obj/vuwv_SyncCommittee_generated.bend as P0_V_SyncCommittee
import ../obj/vuwv_v64_u64_generated.bend as P0_V_v64_u64
import ../obj/encx_l16777216_b32_generated.bend as P0_EX_l16777216_b32
import ../obj/encx_l2048_Eth1Data_generated.bend as P0_EW_l2048_Eth1Data
import ../obj/encx_l1099511627776_Validator_generated.bend as P0_EW_l1099511627776_Validator
import ../obj/encx_l1099511627776_u64_generated.bend as P0_EX_l1099511627776_u64
import ../obj/encx_l1099511627776_u8_generated.bend as P0_EX_l1099511627776_u8
import ../obj/encx_ExecutionPayloadHeader_iface_generated.bend as P0_EC_ExecutionPayloadHeader
import ../obj/encx_ExecutionPayloadHeader_size_generated.bend as P0_ES_ExecutionPayloadHeader
import ../obj/encx_l16777216_HistoricalSummary_generated.bend as P0_EW_l16777216_HistoricalSummary
import ../obj/encx_l134217728_PendingDeposit_generated.bend as P0_EW_l134217728_PendingDeposit
import ../obj/encx_l134217728_PendingPartialWithdrawal_generated.bend as P0_EW_l134217728_PendingPartialWithdrawal
import ../obj/encx_l262144_PendingConsolidation_generated.bend as P0_EW_l262144_PendingConsolidation
import ../obj/vpiece.bend as P0_VPC
import ../obj/vfx_bv4_generated.bend as P0_VFB4
import ../obj/vbitb.bend as P0_VBB
import ../obj/vfixw_spec.bend as P0_FWS
import ../obj/vfixw_u32.bend as P0_WU
import ../obj/vpos32.bend as P0_P32
import ../obj/encx_BeaconState_generated.bend as P0_K
import ../obj/vbenc.bend as P0_VBE
import ../../src/buffer.bend as P0_B
import ../../spec/decoding_relation.bend as P0_Decoding
import ../obj/vlist.bend as P0_VL
import ../obj/vdepth.bend as P0_VD
import ../obj/vvlz_generated.bend as P0_VZG
import ../obj/vuwb.bend as P0_UWB
import ../obj/vvle.bend as P0_VE2
import ../obj/encx_BeaconState_iface_generated.bend as P0_CI
import ../obj/encx_BeaconState_size_generated.bend as P0_Z
import ../obj/var_codec_BeaconState_enc_generated.bend as P0_PRV
import ../../src/obj.bend as P1_O
import ../slop/validity/fulu_BeaconState_appb_l1099511627776_Validator_generated.bend as P1_PRV
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_BeaconState_appb_l1099511627776_u64_generated.bend as P2_PRV
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_BeaconState_appb_l1099511627776_u8_generated.bend as P3_PRV
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_BeaconState_appb_l134217728_PendingDeposit_generated.bend as P4_PRV
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_BeaconState_appb_l134217728_PendingPartialWithdrawal_generated.bend as P5_PRV
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_BeaconState_appb_l16777216_HistoricalSummary_generated.bend as P6_PRV
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_BeaconState_appb_l2048_Eth1Data_generated.bend as P7_PRV
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_BeaconState_appb_l262144_PendingConsolidation_generated.bend as P8_PRV
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_BeaconState_collection_l1099511627776_u8_generated.bend as P9_PRV
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_BeaconState_fields_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_BeaconState_senc_generated.bend as P11_PRV
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_BeaconState_unit_l1099511627776_u64_generated.bend as P12_PRV
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_BeaconState_unit_l1099511627776_u8_generated.bend as P13_PRV
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_BeaconState_unit_l16777216_b32_generated.bend as P14_PRV
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_BeaconState_unit_v64_u64_generated.bend as P15_PRV
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_BeaconState_unit_v65536_b32_generated.bend as P16_PRV
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_BeaconState_unit_v8192_b32_generated.bend as P17_PRV
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_BeaconState_unit_v8192_u64_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/digest.bend as P19_D
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_enc_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/digest.bend as P20_D
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_enc_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_BeaconState_writer_l1099511627776_Validator_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_BeaconState_writer_l1099511627776_u64_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_BeaconState_writer_l1099511627776_u8_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_BeaconState_writer_l134217728_PendingDeposit_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_BeaconState_writer_l134217728_PendingPartialWithdrawal_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_BeaconState_writer_l16777216_HistoricalSummary_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_BeaconState_writer_l16777216_b32_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_BeaconState_writer_l2048_Eth1Data_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_BeaconState_writer_l262144_PendingConsolidation_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_BeaconState_writer_v64_u64_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/obj.bend as P31_O
import ../slop/validity/fulu_BeaconState_writer_v65536_b32_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/obj.bend as P32_O
import ../slop/validity/fulu_BeaconState_writer_v8192_u64_generated.bend as P32_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluBeaconState (BeaconState): its encode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluBeaconState__encode_eval__encode_eval(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> {FuluBeaconState_e.BeaconState_encode(P0_CI.TH(m)) == (P0_CI.TH(m), P0_B.Buf{P0_FD.array__thaw(U32, P0_PRV.OUTE(m)), P0_PRV.SZSM(m)}) : FuluBeaconState_d.BeaconState & P0_B.Buf}:
  P0_PRV.encode_eval(m, hok)

def FuluBeaconState__encode_spec__encode_spec(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.BeaconState(), P0_VS.bt(U32.to_nat(P0_PRV.SZSM(m)), P0_FX.limbs(P0_FD.array__slots(U32, P0_PRV.OUTE(m)))), P0_CI.VAL(m)):
  P0_PRV.encode_spec(m, hok)

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_Validator_appb_below() -> {Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_append(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_fill(26n), 35495596}, FuluValidator_d.Validator_default())) == True{} : Bool}:
  P1_PRV.BeaconState_serialize_vcoll_l1099511627776_Validator_appb_below()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_Validator_appb_at() -> {Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_append(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_fill(26n), 35495597}, FuluValidator_d.Validator_default())) == False{} : Bool}:
  P1_PRV.BeaconState_serialize_vcoll_l1099511627776_Validator_appb_at()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_Validator_appb_above() -> {Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_append(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_fill(26n), 35495598}, FuluValidator_d.Validator_default())) == False{} : Bool}:
  P1_PRV.BeaconState_serialize_vcoll_l1099511627776_Validator_appb_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_Validator_appb_fit() -> {Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_append(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_fill(2n), 3}, FuluValidator_d.Validator_default())) == True{} : Bool}:
  P1_PRV.BeaconState_serialize_vcoll_l1099511627776_Validator_appb_fit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_Validator_appb_short() -> {Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_append(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_fill(2n), 5}, FuluValidator_d.Validator_default())) == False{} : Bool}:
  P1_PRV.BeaconState_serialize_vcoll_l1099511627776_Validator_appb_short()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u64_appb_below() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_uint64_1099511627776_d.l1099511627776_u64_append(P2_O.Words{Array.new(U32, 30n, 0), 4294967256}, P2_O.U64{0, 0})) == True{} : Bool}:
  P2_PRV.BeaconState_serialize_vcoll_l1099511627776_u64_appb_below()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u64_appb_at() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_uint64_1099511627776_d.l1099511627776_u64_append(P2_O.Words{Array.new(U32, 31n, 0), 4294967264}, P2_O.U64{0, 0})) == False{} : Bool}:
  P2_PRV.BeaconState_serialize_vcoll_l1099511627776_u64_appb_at()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u64_appb_above() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_uint64_1099511627776_d.l1099511627776_u64_append(P2_O.Words{Array.new(U32, 31n, 0), 4294967272}, P2_O.U64{0, 0})) == False{} : Bool}:
  P2_PRV.BeaconState_serialize_vcoll_l1099511627776_u64_appb_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u64_appb_fit() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_uint64_1099511627776_d.l1099511627776_u64_append(P2_O.Words{Array.new(U32, 3n, 0), 32}, P2_O.U64{0, 0})) == True{} : Bool}:
  P2_PRV.BeaconState_serialize_vcoll_l1099511627776_u64_appb_fit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u64_appb_short() -> {Pair.snd(P2_O.Words, Bool, Fulu_list_uint64_1099511627776_d.l1099511627776_u64_append(P2_O.Words{Array.new(U32, 3n, 0), 40}, P2_O.U64{0, 0})) == False{} : Bool}:
  P2_PRV.BeaconState_serialize_vcoll_l1099511627776_u64_appb_short()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_appb_below() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(P3_O.Words{Array.new(U32, 30n, 0), 4294967263}, 0)) == True{} : Bool}:
  P3_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_appb_below()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_appb_at() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(P3_O.Words{Array.new(U32, 31n, 0), 4294967264}, 0)) == False{} : Bool}:
  P3_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_appb_at()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_appb_above() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(P3_O.Words{Array.new(U32, 31n, 0), 4294967265}, 0)) == False{} : Bool}:
  P3_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_appb_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_appb_fit() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(P3_O.Words{Array.new(U32, 3n, 0), 32}, 0)) == True{} : Bool}:
  P3_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_appb_fit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_appb_short() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(P3_O.Words{Array.new(U32, 3n, 0), 33}, 0)) == False{} : Bool}:
  P3_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_appb_short()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_below() -> {Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_append(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq{Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_fill(25n), 22369620}, FuluPendingDeposit_d.PendingDeposit_default())) == True{} : Bool}:
  P4_PRV.BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_below()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_at() -> {Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_append(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq{Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_fill(25n), 22369621}, FuluPendingDeposit_d.PendingDeposit_default())) == False{} : Bool}:
  P4_PRV.BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_at()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_above() -> {Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_append(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq{Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_fill(25n), 22369622}, FuluPendingDeposit_d.PendingDeposit_default())) == False{} : Bool}:
  P4_PRV.BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_fit() -> {Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_append(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq{Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_fill(2n), 3}, FuluPendingDeposit_d.PendingDeposit_default())) == True{} : Bool}:
  P4_PRV.BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_fit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_short() -> {Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_append(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq{Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_fill(2n), 5}, FuluPendingDeposit_d.PendingDeposit_default())) == False{} : Bool}:
  P4_PRV.BeaconState_serialize_vcoll_l134217728_PendingDeposit_appb_short()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_below() -> {Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_append(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq{Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_fill(28n), 134217727}, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == True{} : Bool}:
  P5_PRV.BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_below()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_at() -> {Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_append(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq{Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_fill(28n), 134217728}, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == False{} : Bool}:
  P5_PRV.BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_at()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_above() -> {Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_append(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq{Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_fill(28n), 134217729}, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == False{} : Bool}:
  P5_PRV.BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_fit() -> {Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_append(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq{Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_fill(2n), 3}, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == True{} : Bool}:
  P5_PRV.BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_fit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_short() -> {Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_append(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq{Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_fill(2n), 5}, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == False{} : Bool}:
  P5_PRV.BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_appb_short()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_below() -> {Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq, Bool, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_append(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq{Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_fill(25n), 16777215}, FuluHistoricalSummary_d.HistoricalSummary_default())) == True{} : Bool}:
  P6_PRV.BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_below()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_at() -> {Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq, Bool, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_append(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq{Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_fill(25n), 16777216}, FuluHistoricalSummary_d.HistoricalSummary_default())) == False{} : Bool}:
  P6_PRV.BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_at()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_above() -> {Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq, Bool, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_append(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq{Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_fill(25n), 16777217}, FuluHistoricalSummary_d.HistoricalSummary_default())) == False{} : Bool}:
  P6_PRV.BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_fit() -> {Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq, Bool, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_append(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq{Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_fill(2n), 3}, FuluHistoricalSummary_d.HistoricalSummary_default())) == True{} : Bool}:
  P6_PRV.BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_fit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_short() -> {Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq, Bool, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_append(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq{Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_fill(2n), 5}, FuluHistoricalSummary_d.HistoricalSummary_default())) == False{} : Bool}:
  P6_PRV.BeaconState_serialize_vcoll_l16777216_HistoricalSummary_appb_short()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l2048_Eth1Data_appb_below() -> {Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_append(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq{Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_fill(12n), 2047}, FuluEth1Data_d.Eth1Data_default())) == True{} : Bool}:
  P7_PRV.BeaconState_serialize_vcoll_l2048_Eth1Data_appb_below()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l2048_Eth1Data_appb_at() -> {Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_append(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq{Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_fill(12n), 2048}, FuluEth1Data_d.Eth1Data_default())) == False{} : Bool}:
  P7_PRV.BeaconState_serialize_vcoll_l2048_Eth1Data_appb_at()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l2048_Eth1Data_appb_above() -> {Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_append(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq{Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_fill(12n), 2049}, FuluEth1Data_d.Eth1Data_default())) == False{} : Bool}:
  P7_PRV.BeaconState_serialize_vcoll_l2048_Eth1Data_appb_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l2048_Eth1Data_appb_fit() -> {Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_append(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq{Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_fill(2n), 3}, FuluEth1Data_d.Eth1Data_default())) == True{} : Bool}:
  P7_PRV.BeaconState_serialize_vcoll_l2048_Eth1Data_appb_fit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l2048_Eth1Data_appb_short() -> {Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_append(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq{Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_fill(2n), 5}, FuluEth1Data_d.Eth1Data_default())) == False{} : Bool}:
  P7_PRV.BeaconState_serialize_vcoll_l2048_Eth1Data_appb_short()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_below() -> {Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_append(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq{Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_fill(19n), 262143}, FuluPendingConsolidation_d.PendingConsolidation_default())) == True{} : Bool}:
  P8_PRV.BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_below()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_at() -> {Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_append(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq{Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_fill(19n), 262144}, FuluPendingConsolidation_d.PendingConsolidation_default())) == False{} : Bool}:
  P8_PRV.BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_at()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_above() -> {Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_append(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq{Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_fill(19n), 262145}, FuluPendingConsolidation_d.PendingConsolidation_default())) == False{} : Bool}:
  P8_PRV.BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_fit() -> {Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_append(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq{Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_fill(2n), 3}, FuluPendingConsolidation_d.PendingConsolidation_default())) == True{} : Bool}:
  P8_PRV.BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_fit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_short() -> {Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_append(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq{Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_fill(2n), 5}, FuluPendingConsolidation_d.PendingConsolidation_default())) == False{} : Bool}:
  P8_PRV.BeaconState_serialize_vcoll_l262144_PendingConsolidation_appb_short()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_len_get() -> {(Pair.snd(P9_O.Words, U32, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_len(P9_PRV.ap(P9_PRV.ap(Fulu_list_uint8_1099511627776_d.l1099511627776_u8_default(), 255), 1))), (Pair.snd(P9_O.Words, Maybe<&1, U32>, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_get(P9_PRV.ap(P9_PRV.ap(Fulu_list_uint8_1099511627776_d.l1099511627776_u8_default(), 255), 1), 0)), (Pair.snd(P9_O.Words, Maybe<&1, U32>, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_get(P9_PRV.ap(P9_PRV.ap(Fulu_list_uint8_1099511627776_d.l1099511627776_u8_default(), 255), 1), 1)), Pair.snd(P9_O.Words, Maybe<&1, U32>, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_get(P9_PRV.ap(P9_PRV.ap(Fulu_list_uint8_1099511627776_d.l1099511627776_u8_default(), 255), 1), 2))))) == (2, (Some{255}, (Some{1}, None{}))) : U32 & (Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>))}:
  P9_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_len_get()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_get_edge() -> {(Pair.snd(P9_O.Words, Maybe<&1, U32>, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_get(P9_O.words_new(3), 2)), (Pair.snd(P9_O.Words, Maybe<&1, U32>, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_get(P9_O.words_new(3), 3)), Pair.snd(P9_O.Words, U32, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_len(P9_O.words_new(3))))) == (Some{0}, (None{}, 3)) : Maybe<&1, U32> & (Maybe<&1, U32> & U32)}:
  P9_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_get_edge()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_append_range() -> {(Pair.snd(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(Fulu_list_uint8_1099511627776_d.l1099511627776_u8_default(), 256)), Pair.snd(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(Fulu_list_uint8_1099511627776_d.l1099511627776_u8_default(), 255))) == (False{}, True{}) : Bool & Bool}:
  P9_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_append_range()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_set_edge() -> {(Pair.snd(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_set(P9_O.words_new(3), 3, 0)), (Pair.snd(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_set(P9_O.words_new(3), 2, 0)), Pair.snd(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_set(P9_O.words_new(3), 1, 256)))) == (False{}, (True{}, False{})) : Bool & (Bool & Bool)}:
  P9_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_set_edge()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_set_write() -> {(Pair.snd(P9_O.Words, Maybe<&1, U32>, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_get(Pair.fst(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_set(P9_O.words_new(3), 1, 255)), 0)), (Pair.snd(P9_O.Words, Maybe<&1, U32>, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_get(Pair.fst(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_set(P9_O.words_new(3), 1, 255)), 1)), Pair.snd(P9_O.Words, Maybe<&1, U32>, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_get(Pair.fst(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_set(P9_O.words_new(3), 1, 255)), 2)))) == (Some{0}, (Some{255}, Some{0})) : Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>)}:
  P9_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_set_write()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l1099511627776_u8_append_clear() -> {(Pair.snd(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(P9_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), (Pair.snd(P9_O.Words, U32, P9_O.words_word(Pair.fst(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(P9_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), 1)), Pair.snd(P9_O.Words, U32, P9_O.words_word(Pair.fst(P9_O.Words, Bool, Fulu_list_uint8_1099511627776_d.l1099511627776_u8_append(P9_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), 0)))) == (True{}, (1, 0)) : Bool & (U32 & U32)}:
  P9_PRV.BeaconState_serialize_vcoll_l1099511627776_u8_append_clear()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_default_valid() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState_default())) == True{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_default_valid()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vrefuse_bad_flag() -> {Pair.snd(FuluBeaconState_d.BeaconState, P10_O.Encoded, FuluBeaconState_e.BeaconState_senc_go(True{}, 0, FuluBeaconState_d.BeaconState_default())) == P10_O.refused() : P10_O.Encoded}:
  P10_PRV.BeaconState_serialize_vrefuse_bad_flag()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vrefuse_poisoned_size() -> {Pair.snd(FuluBeaconState_d.BeaconState, P10_O.Encoded, FuluBeaconState_e.BeaconState_senc_sized((FuluBeaconState_d.BeaconState_default(), 4294967295))) == P10_O.refused() : P10_O.Encoded}:
  P10_PRV.BeaconState_serialize_vrefuse_poisoned_size()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_block_roots() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_set_block_roots(FuluBeaconState_d.BeaconState_g0_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_block_roots()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_state_roots() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_set_state_roots(FuluBeaconState_d.BeaconState_g0_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_state_roots()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_historical_roots() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_set_historical_roots(FuluBeaconState_d.BeaconState_g0_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_historical_roots()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_eth1_data_votes() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_set_eth1_data_votes(FuluBeaconState_d.BeaconState_g1_default(), Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq{Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_fill(0n), 2}), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_eth1_data_votes()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_eth1_data_votes_limit() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_set_eth1_data_votes(FuluBeaconState_d.BeaconState_g1_default(), Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq{Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_fill(12n), 2049}), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_eth1_data_votes_limit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_validators() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_set_validators(FuluBeaconState_d.BeaconState_g1_default(), Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_fill(0n), 2}), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_validators()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_balances() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_set_balances(FuluBeaconState_d.BeaconState_g1_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_balances()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_randao_mixes() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_set_randao_mixes(FuluBeaconState_d.BeaconState_g1_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_randao_mixes()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_slashings() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_set_slashings(FuluBeaconState_d.BeaconState_g1_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_slashings()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_previous_epoch_participation() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_set_previous_epoch_participation(FuluBeaconState_d.BeaconState_g1_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_previous_epoch_participation()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_current_epoch_participation() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_set_current_epoch_participation(FuluBeaconState_d.BeaconState_g2_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_current_epoch_participation()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_inactivity_scores() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_set_inactivity_scores(FuluBeaconState_d.BeaconState_g2_default(), P10_O.Words{Array.new(U32, 0n, 0), 5}), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_inactivity_scores()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_latest_execution_payload_header() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_set_latest_execution_payload_header(FuluBeaconState_d.BeaconState_g3_default(), P10_O.BNone{}), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_latest_execution_payload_header()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_historical_summaries() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_set_historical_summaries(FuluBeaconState_d.BeaconState_g3_default(), Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq{Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_fill(0n), 2}), FuluBeaconState_d.BeaconState_g4_default()})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_historical_summaries()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_pending_deposits() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_set_pending_deposits(FuluBeaconState_d.BeaconState_g4_default(), Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq{Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_fill(0n), 2})})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_pending_deposits()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_pending_partial_withdrawals() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_set_pending_partial_withdrawals(FuluBeaconState_d.BeaconState_g4_default(), Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq{Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_fill(0n), 2})})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_pending_partial_withdrawals()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_pending_consolidations() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_set_pending_consolidations(FuluBeaconState_d.BeaconState_g4_default(), Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq{Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_fill(0n), 2})})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_pending_consolidations()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_pending_consolidations_limit() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_set_pending_consolidations(FuluBeaconState_d.BeaconState_g4_default(), Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq{Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_fill(19n), 262145})})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_pending_consolidations_limit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vreject_proposer_lookahead() -> {Pair.snd(FuluBeaconState_d.BeaconState, Bool, FuluBeaconState_e.BeaconState_valid(FuluBeaconState_d.BeaconState{FuluBeaconState_d.BeaconState_g0_default(), FuluBeaconState_d.BeaconState_g1_default(), FuluBeaconState_d.BeaconState_g2_default(), FuluBeaconState_d.BeaconState_g3_default(), FuluBeaconState_d.BeaconState_g4_set_proposer_lookahead(FuluBeaconState_d.BeaconState_g4_default(), P10_O.Words{Array.new(U32, 0n, 0), 5})})) == False{} : Bool}:
  P10_PRV.BeaconState_serialize_vreject_proposer_lookahead()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vrefuse_writer_marker() -> {Pair.snd(FuluBeaconState_d.BeaconState, P11_O.Encoded, FuluBeaconState_e.BeaconState_senc_out(0, Array.new(U32, 0n, 0), FuluBeaconState_d.BeaconState_default(), 4294967295)) == P11_O.refused() : P11_O.Encoded}:
  P11_PRV.BeaconState_serialize_vrefuse_writer_marker()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vrefuse_writer_above() -> {Pair.snd(FuluBeaconState_d.BeaconState, P11_O.Encoded, FuluBeaconState_e.BeaconState_senc_out(0, Array.new(U32, 0n, 0), FuluBeaconState_d.BeaconState_default(), 4294967265)) == P11_O.refused() : P11_O.Encoded}:
  P11_PRV.BeaconState_serialize_vrefuse_writer_above()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vrefuse_writer_ok() -> {Pair.snd(FuluBeaconState_d.BeaconState, P11_O.Encoded, FuluBeaconState_e.BeaconState_senc_out(0, Array.new(U32, 0n, 0), FuluBeaconState_d.BeaconState_default(), 0)) == P11_O.Encoded{True{}, P11_B.Buf{Array.new(U32, 0n, 0), 0}} : P11_O.Encoded}:
  P11_PRV.BeaconState_serialize_vrefuse_writer_ok()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l1099511627776_u64_refuse_1() -> {Pair.snd(P12_O.Words, Bool, Fulu_list_uint64_1099511627776_e.l1099511627776_u64_valid(P12_O.words_new(1))) == False{} : Bool}:
  P12_PRV.BeaconState_serialize_vunit_l1099511627776_u64_refuse_1()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l1099511627776_u64_refuse_4() -> {Pair.snd(P12_O.Words, Bool, Fulu_list_uint64_1099511627776_e.l1099511627776_u64_valid(P12_O.words_new(4))) == False{} : Bool}:
  P12_PRV.BeaconState_serialize_vunit_l1099511627776_u64_refuse_4()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l1099511627776_u64_refuse_9() -> {Pair.snd(P12_O.Words, Bool, Fulu_list_uint64_1099511627776_e.l1099511627776_u64_valid(P12_O.words_new(9))) == False{} : Bool}:
  P12_PRV.BeaconState_serialize_vunit_l1099511627776_u64_refuse_9()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l1099511627776_u64_accept_8() -> {Pair.snd(P12_O.Words, Bool, Fulu_list_uint64_1099511627776_e.l1099511627776_u64_valid(P12_O.words_new(8))) == True{} : Bool}:
  P12_PRV.BeaconState_serialize_vunit_l1099511627776_u64_accept_8()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l1099511627776_u64_accept_16() -> {Pair.snd(P12_O.Words, Bool, Fulu_list_uint64_1099511627776_e.l1099511627776_u64_valid(P12_O.words_new(16))) == True{} : Bool}:
  P12_PRV.BeaconState_serialize_vunit_l1099511627776_u64_accept_16()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l1099511627776_u64_range_lo_0() -> {Pair.snd(P12_O.Words, Bool, Fulu_list_uint64_1099511627776_e.l1099511627776_u64_valid(P12_O.words_new(0))) == True{} : Bool}:
  P12_PRV.BeaconState_serialize_vunit_l1099511627776_u64_range_lo_0()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l1099511627776_u8_range_lo_0() -> {Pair.snd(P13_O.Words, Bool, Fulu_list_uint8_1099511627776_e.l1099511627776_u8_valid(P13_O.words_new(0))) == True{} : Bool}:
  P13_PRV.BeaconState_serialize_vunit_l1099511627776_u8_range_lo_0()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l16777216_b32_refuse_1() -> {Pair.snd(P14_O.Words, Bool, Fulu_list_bytevec_32_16777216_e.l16777216_b32_valid(P14_O.words_new(1))) == False{} : Bool}:
  P14_PRV.BeaconState_serialize_vunit_l16777216_b32_refuse_1()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l16777216_b32_refuse_16() -> {Pair.snd(P14_O.Words, Bool, Fulu_list_bytevec_32_16777216_e.l16777216_b32_valid(P14_O.words_new(16))) == False{} : Bool}:
  P14_PRV.BeaconState_serialize_vunit_l16777216_b32_refuse_16()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l16777216_b32_refuse_33() -> {Pair.snd(P14_O.Words, Bool, Fulu_list_bytevec_32_16777216_e.l16777216_b32_valid(P14_O.words_new(33))) == False{} : Bool}:
  P14_PRV.BeaconState_serialize_vunit_l16777216_b32_refuse_33()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l16777216_b32_accept_32() -> {Pair.snd(P14_O.Words, Bool, Fulu_list_bytevec_32_16777216_e.l16777216_b32_valid(P14_O.words_new(32))) == True{} : Bool}:
  P14_PRV.BeaconState_serialize_vunit_l16777216_b32_accept_32()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l16777216_b32_accept_64() -> {Pair.snd(P14_O.Words, Bool, Fulu_list_bytevec_32_16777216_e.l16777216_b32_valid(P14_O.words_new(64))) == True{} : Bool}:
  P14_PRV.BeaconState_serialize_vunit_l16777216_b32_accept_64()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_l16777216_b32_range_lo_0() -> {Pair.snd(P14_O.Words, Bool, Fulu_list_bytevec_32_16777216_e.l16777216_b32_valid(P14_O.words_new(0))) == True{} : Bool}:
  P14_PRV.BeaconState_serialize_vunit_l16777216_b32_range_lo_0()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v64_u64_range_below_504() -> {Pair.snd(P15_O.Words, Bool, Fulu_vec_uint64_64_e.v64_u64_valid(P15_O.words_new(504))) == False{} : Bool}:
  P15_PRV.BeaconState_serialize_vunit_v64_u64_range_below_504()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v64_u64_range_lo_512() -> {Pair.snd(P15_O.Words, Bool, Fulu_vec_uint64_64_e.v64_u64_valid(P15_O.words_new(512))) == True{} : Bool}:
  P15_PRV.BeaconState_serialize_vunit_v64_u64_range_lo_512()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v64_u64_range_above_520() -> {Pair.snd(P15_O.Words, Bool, Fulu_vec_uint64_64_e.v64_u64_valid(P15_O.words_new(520))) == False{} : Bool}:
  P15_PRV.BeaconState_serialize_vunit_v64_u64_range_above_520()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v65536_b32_range_below_2097120() -> {Pair.snd(P16_O.Words, Bool, Fulu_vec_bytevec_32_65536_e.v65536_b32_valid(P16_O.words_new(2097120))) == False{} : Bool}:
  P16_PRV.BeaconState_serialize_vunit_v65536_b32_range_below_2097120()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v65536_b32_range_lo_2097152() -> {Pair.snd(P16_O.Words, Bool, Fulu_vec_bytevec_32_65536_e.v65536_b32_valid(P16_O.words_new(2097152))) == True{} : Bool}:
  P16_PRV.BeaconState_serialize_vunit_v65536_b32_range_lo_2097152()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v65536_b32_range_above_2097184() -> {Pair.snd(P16_O.Words, Bool, Fulu_vec_bytevec_32_65536_e.v65536_b32_valid(P16_O.words_new(2097184))) == False{} : Bool}:
  P16_PRV.BeaconState_serialize_vunit_v65536_b32_range_above_2097184()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v8192_b32_range_below_262112() -> {Pair.snd(P17_O.Words, Bool, Fulu_vec_bytevec_32_8192_e.v8192_b32_valid(P17_O.words_new(262112))) == False{} : Bool}:
  P17_PRV.BeaconState_serialize_vunit_v8192_b32_range_below_262112()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v8192_b32_range_lo_262144() -> {Pair.snd(P17_O.Words, Bool, Fulu_vec_bytevec_32_8192_e.v8192_b32_valid(P17_O.words_new(262144))) == True{} : Bool}:
  P17_PRV.BeaconState_serialize_vunit_v8192_b32_range_lo_262144()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v8192_b32_range_above_262176() -> {Pair.snd(P17_O.Words, Bool, Fulu_vec_bytevec_32_8192_e.v8192_b32_valid(P17_O.words_new(262176))) == False{} : Bool}:
  P17_PRV.BeaconState_serialize_vunit_v8192_b32_range_above_262176()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v8192_u64_range_below_65528() -> {Pair.snd(P18_O.Words, Bool, Fulu_vec_uint64_8192_e.v8192_u64_valid(P18_O.words_new(65528))) == False{} : Bool}:
  P18_PRV.BeaconState_serialize_vunit_v8192_u64_range_below_65528()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v8192_u64_range_lo_65536() -> {Pair.snd(P18_O.Words, Bool, Fulu_vec_uint64_8192_e.v8192_u64_valid(P18_O.words_new(65536))) == True{} : Bool}:
  P18_PRV.BeaconState_serialize_vunit_v8192_u64_range_lo_65536()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vunit_v8192_u64_range_above_65544() -> {Pair.snd(P18_O.Words, Bool, Fulu_vec_uint64_8192_e.v8192_u64_valid(P18_O.words_new(65544))) == False{} : Bool}:
  P18_PRV.BeaconState_serialize_vunit_v8192_u64_range_above_65544()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_enc() -> {Pair.fst(Array<U32>, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq & U32, Fulu_list_PendingPartialWithdrawal_134217728_e.l134217728_PendingPartialWithdrawal_putn(Array.new(U32, 5n, 0), 0, P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P19_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P19_O.U64{1, 0})))) == Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 1), 12, 1) : Array<U32>}:
  P19_PRV.BeaconState_serialize_vcoll_l134217728_PendingPartialWithdrawal_enc()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vcoll_l262144_PendingConsolidation_enc() -> {Pair.fst(Array<U32>, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq & U32, Fulu_list_PendingConsolidation_262144_e.l262144_PendingConsolidation_putn(Array.new(U32, 4n, 0), 0, P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P20_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P20_O.U64{1, 0})))) == Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 1), 8, 1) : Array<U32>}:
  P20_PRV.BeaconState_serialize_vcoll_l262144_PendingConsolidation_enc()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l1099511627776_Validator() -> {P21_O.is_poisoned(Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq, U32, Pair.snd(Array<U32>, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq & U32, Fulu_list_Validator_1099511627776_e.l1099511627776_Validator_pk(Array.new(U32, 0n, 0), 0, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), False{}))))) == True{} : Bool}:
  P21_PRV.BeaconState_serialize_vpoison_pk_l1099511627776_Validator()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l1099511627776_u64() -> {P22_O.is_poisoned(Pair.snd(P22_O.Words, U32, Pair.snd(Array<U32>, P22_O.Words & U32, Fulu_list_uint64_1099511627776_e.l1099511627776_u64_pk(Array.new(U32, 0n, 0), 0, (P22_O.words_new(0), False{}))))) == True{} : Bool}:
  P22_PRV.BeaconState_serialize_vpoison_pk_l1099511627776_u64()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l1099511627776_u8() -> {P23_O.is_poisoned(Pair.snd(P23_O.Words, U32, Pair.snd(Array<U32>, P23_O.Words & U32, Fulu_list_uint8_1099511627776_e.l1099511627776_u8_pk(Array.new(U32, 0n, 0), 0, (P23_O.words_new(0), False{}))))) == True{} : Bool}:
  P23_PRV.BeaconState_serialize_vpoison_pk_l1099511627776_u8()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l134217728_PendingDeposit() -> {P24_O.is_poisoned(Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq, U32, Pair.snd(Array<U32>, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Seq & U32, Fulu_list_PendingDeposit_134217728_e.l134217728_PendingDeposit_pk(Array.new(U32, 0n, 0), 0, (Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), False{}))))) == True{} : Bool}:
  P24_PRV.BeaconState_serialize_vpoison_pk_l134217728_PendingDeposit()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l134217728_PendingPartialWithdrawal() -> {P25_O.is_poisoned(Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq, U32, Pair.snd(Array<U32>, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Seq & U32, Fulu_list_PendingPartialWithdrawal_134217728_e.l134217728_PendingPartialWithdrawal_pk(Array.new(U32, 0n, 0), 0, (Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), False{}))))) == True{} : Bool}:
  P25_PRV.BeaconState_serialize_vpoison_pk_l134217728_PendingPartialWithdrawal()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l16777216_HistoricalSummary() -> {P26_O.is_poisoned(Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq, U32, Pair.snd(Array<U32>, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Seq & U32, Fulu_list_HistoricalSummary_16777216_e.l16777216_HistoricalSummary_pk(Array.new(U32, 0n, 0), 0, (Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), False{}))))) == True{} : Bool}:
  P26_PRV.BeaconState_serialize_vpoison_pk_l16777216_HistoricalSummary()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l16777216_b32() -> {P27_O.is_poisoned(Pair.snd(P27_O.Words, U32, Pair.snd(Array<U32>, P27_O.Words & U32, Fulu_list_bytevec_32_16777216_e.l16777216_b32_pk(Array.new(U32, 0n, 0), 0, (P27_O.words_new(0), False{}))))) == True{} : Bool}:
  P27_PRV.BeaconState_serialize_vpoison_pk_l16777216_b32()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l2048_Eth1Data() -> {P28_O.is_poisoned(Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq, U32, Pair.snd(Array<U32>, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Seq & U32, Fulu_list_Eth1Data_2048_e.l2048_Eth1Data_pk(Array.new(U32, 0n, 0), 0, (Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), False{}))))) == True{} : Bool}:
  P28_PRV.BeaconState_serialize_vpoison_pk_l2048_Eth1Data()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_l262144_PendingConsolidation() -> {P29_O.is_poisoned(Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq, U32, Pair.snd(Array<U32>, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Seq & U32, Fulu_list_PendingConsolidation_262144_e.l262144_PendingConsolidation_pk(Array.new(U32, 0n, 0), 0, (Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), False{}))))) == True{} : Bool}:
  P29_PRV.BeaconState_serialize_vpoison_pk_l262144_PendingConsolidation()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_v64_u64() -> {P30_O.is_poisoned(Pair.snd(P30_O.Words, U32, Pair.snd(Array<U32>, P30_O.Words & U32, Fulu_vec_uint64_64_e.v64_u64_pk(Array.new(U32, 0n, 0), 0, (P30_O.words_new(0), False{}))))) == True{} : Bool}:
  P30_PRV.BeaconState_serialize_vpoison_pk_v64_u64()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_v65536_b32() -> {P31_O.is_poisoned(Pair.snd(P31_O.Words, U32, Pair.snd(Array<U32>, P31_O.Words & U32, Fulu_vec_bytevec_32_65536_e.v65536_b32_pk(Array.new(U32, 0n, 0), 0, (P31_O.words_new(0), False{}))))) == True{} : Bool}:
  P31_PRV.BeaconState_serialize_vpoison_pk_v65536_b32()

def FuluBeaconState__serialize_valid__BeaconState_serialize_vpoison_pk_v8192_u64() -> {P32_O.is_poisoned(Pair.snd(P32_O.Words, U32, Pair.snd(Array<U32>, P32_O.Words & U32, Fulu_vec_uint64_8192_e.v8192_u64_pk(Array.new(U32, 0n, 0), 0, (P32_O.words_new(0), False{}))))) == True{} : Bool}:
  P32_PRV.BeaconState_serialize_vpoison_pk_v8192_u64()

