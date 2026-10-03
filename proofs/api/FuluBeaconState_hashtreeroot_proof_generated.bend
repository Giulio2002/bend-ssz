import Base
import ../compact/found_generated.bend as P0_F
import ../../src/buffer.bend as P0_B
import ../../src/digest.bend as P0_D
import ../../src/obj.bend as P0_O
import ../../types/FuluPendingConsolidation_def_generated.bend as FuluPendingConsolidation_d
import ../../types/FuluPendingConsolidation_hashtreeroot_generated.bend as FuluPendingConsolidation_h
import ../../types/FuluPendingPartialWithdrawal_def_generated.bend as FuluPendingPartialWithdrawal_d
import ../../types/FuluPendingPartialWithdrawal_hashtreeroot_generated.bend as FuluPendingPartialWithdrawal_h
import ../../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../../types/FuluPendingDeposit_def_generated.bend as FuluPendingDeposit_d
import ../../types/FuluPendingDeposit_hashtreeroot_generated.bend as FuluPendingDeposit_h
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/FuluValidator_hashtreeroot_generated.bend as FuluValidator_h
import ../../types/Fulu_list_Eth1Data_2048_def_generated.bend as Fulu_list_Eth1Data_2048_d
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d
import ../../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as Fulu_list_PendingDeposit_134217728_d
import ../../types/Fulu_list_PendingPartialWithdrawal_134217728_def_generated.bend as Fulu_list_PendingPartialWithdrawal_134217728_d
import ../../types/Fulu_list_PendingConsolidation_262144_def_generated.bend as Fulu_list_PendingConsolidation_262144_d
import ../../types/FuluBeaconState_def_generated.bend as FuluBeaconState_d
import ../../types/FuluBeaconState_hashtreeroot_generated.bend as FuluBeaconState_h
import ../../types/schema.bend as P0_S
import ../../types/primitive.bend as P0_P
import ../obj/cform.bend as P0_CF
import ../obj/amap.bend as P0_AM
import ../../spec/root_relation.bend as P0_RR
import ../../spec/fulu_schemas.bend as P0_Spec
import ../obj/schema_shapes_generated.bend as P0_SH
import ../obj/dk.bend as P0_DK
import ../obj/mtree_defs.bend as P0_MD
import ../obj/pv_obj_light.bend as P0_PV
import ../obj/obj_support.bend as P0_OS
import ../obj/ulist_obj_light.bend as P0_UL
import ../obj/xlist_support.bend as P0_XS
import ../obj/mtree_run.bend as P0_MR
import ../obj/words_cap.bend as P0_WC
import ../../spec/codec.bend as P0_Codec
import ../../spec/limits.bend as P0_Lim
import ../../spec/bit_root.bend as P0_Mix
import ../../spec/nat_bytes.bend as P0_Len
import ../../spec/byte_list.bend as P0_BL
import ../obj/lim_bl.bend as P0_LBL
import ../obj/root_state_light_generated.bend as P0_ST_L
import ../obj/root_BeaconState_generated.bend as P0_PRV
import ../../src/buffer.bend as P1_B
import ../../src/digest.bend as P1_D
import ../../src/obj.bend as P1_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_app_1_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/digest.bend as P2_D
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_app_2_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/digest.bend as P3_D
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_app_3_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/digest.bend as P4_D
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_app_4_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/digest.bend as P5_D
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_app_fold_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/digest.bend as P6_D
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_dok_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/digest.bend as P7_D
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_end_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/digest.bend as P8_D
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_set_0_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/digest.bend as P9_D
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_set_1_3_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/digest.bend as P10_D
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_set_3_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/digest.bend as P11_D
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_1_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/digest.bend as P12_D
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_2_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/digest.bend as P13_D
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_3_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/digest.bend as P14_D
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_4_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/digest.bend as P15_D
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_fold_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/digest.bend as P16_D
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_dok_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/digest.bend as P17_D
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_end_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/digest.bend as P18_D
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_set_0_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/digest.bend as P19_D
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_set_1_3_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/digest.bend as P20_D
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_set_3_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/digest.bend as P21_D
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_1_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/digest.bend as P22_D
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_2_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/digest.bend as P23_D
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_3_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/digest.bend as P24_D
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_4_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/digest.bend as P25_D
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_fold_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/digest.bend as P26_D
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_dok_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/digest.bend as P27_D
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_end_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/digest.bend as P28_D
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_0_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/digest.bend as P29_D
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_1_3_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/digest.bend as P30_D
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_3_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/digest.bend as P31_D
import ../../src/obj.bend as P31_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_1_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/digest.bend as P32_D
import ../../src/obj.bend as P32_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_2_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/digest.bend as P33_D
import ../../src/obj.bend as P33_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_3_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/digest.bend as P34_D
import ../../src/obj.bend as P34_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_4_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/digest.bend as P35_D
import ../../src/obj.bend as P35_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_dok_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/digest.bend as P36_D
import ../../src/obj.bend as P36_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_end_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/digest.bend as P37_D
import ../../src/obj.bend as P37_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_set_0_generated.bend as P37_PRV
import ../../src/buffer.bend as P38_B
import ../../src/digest.bend as P38_D
import ../../src/obj.bend as P38_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_set_1_3_generated.bend as P38_PRV
import ../../src/buffer.bend as P39_B
import ../../src/digest.bend as P39_D
import ../../src/obj.bend as P39_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_set_3_generated.bend as P39_PRV
import ../../src/buffer.bend as P40_B
import ../../src/digest.bend as P40_D
import ../../src/obj.bend as P40_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_1_generated.bend as P40_PRV
import ../../src/buffer.bend as P41_B
import ../../src/digest.bend as P41_D
import ../../src/obj.bend as P41_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_2_generated.bend as P41_PRV
import ../../src/buffer.bend as P42_B
import ../../src/digest.bend as P42_D
import ../../src/obj.bend as P42_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_3_generated.bend as P42_PRV
import ../../src/buffer.bend as P43_B
import ../../src/digest.bend as P43_D
import ../../src/obj.bend as P43_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_4_generated.bend as P43_PRV
import ../../src/buffer.bend as P44_B
import ../../src/digest.bend as P44_D
import ../../src/obj.bend as P44_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_fold_generated.bend as P44_PRV
import ../../src/buffer.bend as P45_B
import ../../src/digest.bend as P45_D
import ../../src/obj.bend as P45_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_dok_generated.bend as P45_PRV
import ../../src/buffer.bend as P46_B
import ../../src/digest.bend as P46_D
import ../../src/obj.bend as P46_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_end_generated.bend as P46_PRV
import ../../src/buffer.bend as P47_B
import ../../src/digest.bend as P47_D
import ../../src/obj.bend as P47_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_set_0_generated.bend as P47_PRV
import ../../src/buffer.bend as P48_B
import ../../src/digest.bend as P48_D
import ../../src/obj.bend as P48_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_set_1_3_generated.bend as P48_PRV
import ../../src/buffer.bend as P49_B
import ../../src/digest.bend as P49_D
import ../../src/obj.bend as P49_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_set_3_generated.bend as P49_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluBeaconState (BeaconState): its hashtreeroot laws in the object API's terms, each discharged by its proving law.

def FuluBeaconState__root__BeaconState_root_correct(-h: P0_B.Buf, -o: FuluBeaconState_d.BeaconState, +s: P0_S.Schema, +es: {s == P0_Spec.BeaconState() : P0_S.Schema}, +rep: P0_ST_L.rep_BeaconState(o, s)) -> P0_RR.roots(P0_ST_L.v_BeaconState(o), s, [P0_D.bytes(Pair.snd(FuluBeaconState_d.BeaconState, P0_D.Digest, Pair.snd(P0_B.Buf, FuluBeaconState_d.BeaconState & P0_D.Digest, FuluBeaconState_h.BeaconState_hash_tree_root(h, o))))]):
  P0_PRV.BeaconState_root_correct(h, o, s, es, rep)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_app_1(+hl: Nat) -> {P1_PRV.rd(hl, P1_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default())) == P1_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P1_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()))) : P1_D.Digest}:
  P1_PRV.BeaconState_vroot_l1099511627776_Validator_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_app_2(+hl: Nat) -> {P2_PRV.rd(hl, P2_PRV.ca(P2_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P2_O.U64{1, 0}))) == P2_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P2_PRV.sa(P2_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P2_O.U64{1, 0})))) : P2_D.Digest}:
  P2_PRV.BeaconState_vroot_l1099511627776_Validator_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_app_3(+hl: Nat) -> {P3_PRV.rd(hl, P3_PRV.ca(P3_PRV.ca(P3_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P3_O.U64{1, 0})), FuluValidator_d.Validator_default())) == P3_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P3_PRV.sa(P3_PRV.sa(P3_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P3_O.U64{1, 0})), FuluValidator_d.Validator_default()))) : P3_D.Digest}:
  P3_PRV.BeaconState_vroot_l1099511627776_Validator_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_app_4(+hl: Nat) -> {P4_PRV.rd(hl, P4_PRV.ca(P4_PRV.ca(P4_PRV.ca(P4_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P4_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P4_O.U64{1, 0}))) == P4_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P4_PRV.sa(P4_PRV.sa(P4_PRV.sa(P4_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P4_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P4_O.U64{1, 0})))) : P4_D.Digest}:
  P4_PRV.BeaconState_vroot_l1099511627776_Validator_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_app_fold(+hl: Nat) -> {P5_PRV.rd(hl, P5_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default())) == P5_O.mix_len(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, P5_D.node(hl, Pair.snd(P5_B.Buf, P5_D.Digest, FuluValidator_h.Validator_root(hl, P5_B.empty(), FuluValidator_d.Validator_default(), 64)), P5_D.zconst(0n)), P5_D.zconst(1n)), P5_D.zconst(2n)), P5_D.zconst(3n)), P5_D.zconst(4n)), P5_D.zconst(5n)), P5_D.zconst(6n)), P5_D.zconst(7n)), P5_D.zconst(8n)), P5_D.zconst(9n)), P5_D.zconst(10n)), P5_D.zconst(11n)), P5_D.zconst(12n)), P5_D.zconst(13n)), P5_D.zconst(14n)), P5_D.zconst(15n)), P5_D.zconst(16n)), P5_D.zconst(17n)), P5_D.zconst(18n)), P5_D.zconst(19n)), P5_D.zconst(20n)), P5_D.zconst(21n)), P5_D.zconst(22n)), P5_D.zconst(23n)), P5_D.zconst(24n)), P5_D.zconst(25n)), P5_D.zconst(26n)), P5_D.zconst(27n)), P5_D.zconst(28n)), P5_D.zconst(29n)), P5_D.zconst(30n)), P5_D.zconst(31n)), P5_D.zconst(32n)), P5_D.zconst(33n)), P5_D.zconst(34n)), P5_D.zconst(35n)), P5_D.zconst(36n)), P5_D.zconst(37n)), P5_D.zconst(38n)), P5_D.zconst(39n)), 1) : P5_D.Digest}:
  P5_PRV.BeaconState_vroot_l1099511627776_Validator_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_dok() -> {(P6_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P6_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P6_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P6_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P6_PRV.BeaconState_vroot_l1099511627776_Validator_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_end() -> {(Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P7_O.U64{1, 0})), FuluValidator_d.Validator_default()), 3, FuluValidator_d.Validator_default())), (Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P7_O.U64{1, 0})), FuluValidator_d.Validator_default()), 2, FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P7_O.U64{1, 0}))), (P7_PRV.is_none(Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, Maybe<&1, FuluValidator_d.Validator>, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cget(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P7_O.U64{1, 0})), FuluValidator_d.Validator_default()), 3))), P7_PRV.is_none(Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, Maybe<&1, FuluValidator_d.Validator>, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cget(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P7_O.U64{1, 0})), FuluValidator_d.Validator_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P7_PRV.BeaconState_vroot_l1099511627776_Validator_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_set_0(+hl: Nat) -> {P8_PRV.rd(hl, P8_PRV.cs(P8_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P8_PRV.sa(P8_PRV.sa(P8_PRV.sa(P8_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P8_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P8_O.U64{1, 0})))), 0, FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P8_O.U64{1, 0}))) == P8_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P8_PRV.ss(P8_PRV.sa(P8_PRV.sa(P8_PRV.sa(P8_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P8_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P8_O.U64{1, 0})), 0, FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P8_O.U64{1, 0})))) : P8_D.Digest}:
  P8_PRV.BeaconState_vroot_l1099511627776_Validator_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_set_1_3(+hl: Nat) -> {P9_PRV.rd(hl, P9_PRV.cs(P9_PRV.cs(P9_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0})))), 1, FuluValidator_d.Validator_default()), 3, FuluValidator_d.Validator_default())) == P9_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P9_PRV.ss(P9_PRV.ss(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0})), 1, FuluValidator_d.Validator_default()), 3, FuluValidator_d.Validator_default()))) : P9_D.Digest}:
  P9_PRV.BeaconState_vroot_l1099511627776_Validator_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_set_3(+hl: Nat) -> {P10_PRV.rd(hl, P10_PRV.cs(P10_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P10_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P10_O.U64{1, 0})))), 3, FuluValidator_d.Validator_default())) == P10_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P10_PRV.ss(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P10_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P10_O.U64{1, 0})), 3, FuluValidator_d.Validator_default()))) : P10_D.Digest}:
  P10_PRV.BeaconState_vroot_l1099511627776_Validator_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_1(+hl: Nat) -> {P11_PRV.rd(hl, P11_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default())) == P11_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P11_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()))) : P11_D.Digest}:
  P11_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_2(+hl: Nat) -> {P12_PRV.rd(hl, P12_PRV.ca(P12_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P12_O.U64{1, 0}))) == P12_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P12_PRV.sa(P12_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P12_O.U64{1, 0})))) : P12_D.Digest}:
  P12_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_3(+hl: Nat) -> {P13_PRV.rd(hl, P13_PRV.ca(P13_PRV.ca(P13_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P13_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default())) == P13_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P13_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()))) : P13_D.Digest}:
  P13_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_4(+hl: Nat) -> {P14_PRV.rd(hl, P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P14_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P14_O.U64{1, 0}))) == P14_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P14_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P14_O.U64{1, 0})))) : P14_D.Digest}:
  P14_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_fold(+hl: Nat) -> {P15_PRV.rd(hl, P15_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default())) == P15_O.mix_len(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, P15_D.node(hl, Pair.snd(P15_B.Buf, P15_D.Digest, FuluPendingDeposit_h.PendingDeposit_root(hl, P15_B.empty(), FuluPendingDeposit_d.PendingDeposit_default(), 64)), P15_D.zconst(0n)), P15_D.zconst(1n)), P15_D.zconst(2n)), P15_D.zconst(3n)), P15_D.zconst(4n)), P15_D.zconst(5n)), P15_D.zconst(6n)), P15_D.zconst(7n)), P15_D.zconst(8n)), P15_D.zconst(9n)), P15_D.zconst(10n)), P15_D.zconst(11n)), P15_D.zconst(12n)), P15_D.zconst(13n)), P15_D.zconst(14n)), P15_D.zconst(15n)), P15_D.zconst(16n)), P15_D.zconst(17n)), P15_D.zconst(18n)), P15_D.zconst(19n)), P15_D.zconst(20n)), P15_D.zconst(21n)), P15_D.zconst(22n)), P15_D.zconst(23n)), P15_D.zconst(24n)), P15_D.zconst(25n)), P15_D.zconst(26n)), 1) : P15_D.Digest}:
  P15_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_dok() -> {(P16_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P16_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P16_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P16_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P16_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_end() -> {(Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Cached, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cset(P17_PRV.ca(P17_PRV.ca(P17_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P17_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), 3, FuluPendingDeposit_d.PendingDeposit_default())), (Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Cached, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cset(P17_PRV.ca(P17_PRV.ca(P17_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P17_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), 2, FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P17_O.U64{1, 0}))), (P17_PRV.is_none(Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Cached, Maybe<&1, FuluPendingDeposit_d.PendingDeposit>, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cget(P17_PRV.ca(P17_PRV.ca(P17_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P17_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), 3))), P17_PRV.is_none(Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Cached, Maybe<&1, FuluPendingDeposit_d.PendingDeposit>, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cget(P17_PRV.ca(P17_PRV.ca(P17_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P17_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P17_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_set_0(+hl: Nat) -> {P18_PRV.rd(hl, P18_PRV.cs(P18_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P18_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P18_O.U64{1, 0})))), 0, FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P18_O.U64{1, 0}))) == P18_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P18_PRV.ss(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P18_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P18_O.U64{1, 0})), 0, FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P18_O.U64{1, 0})))) : P18_D.Digest}:
  P18_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_set_1_3(+hl: Nat) -> {P19_PRV.rd(hl, P19_PRV.cs(P19_PRV.cs(P19_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P19_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P19_O.U64{1, 0})))), 1, FuluPendingDeposit_d.PendingDeposit_default()), 3, FuluPendingDeposit_d.PendingDeposit_default())) == P19_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P19_PRV.ss(P19_PRV.ss(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P19_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P19_O.U64{1, 0})), 1, FuluPendingDeposit_d.PendingDeposit_default()), 3, FuluPendingDeposit_d.PendingDeposit_default()))) : P19_D.Digest}:
  P19_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_set_3(+hl: Nat) -> {P20_PRV.rd(hl, P20_PRV.cs(P20_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P20_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P20_O.U64{1, 0})))), 3, FuluPendingDeposit_d.PendingDeposit_default())) == P20_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P20_PRV.ss(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P20_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P20_O.U64{1, 0})), 3, FuluPendingDeposit_d.PendingDeposit_default()))) : P20_D.Digest}:
  P20_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_1(+hl: Nat) -> {P21_PRV.rd(hl, P21_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P21_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P21_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P21_D.Digest}:
  P21_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_2(+hl: Nat) -> {P22_PRV.rd(hl, P22_PRV.ca(P22_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P22_O.U64{1, 0}))) == P22_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P22_PRV.sa(P22_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P22_O.U64{1, 0})))) : P22_D.Digest}:
  P22_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_3(+hl: Nat) -> {P23_PRV.rd(hl, P23_PRV.ca(P23_PRV.ca(P23_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P23_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P23_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P23_PRV.sa(P23_PRV.sa(P23_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P23_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P23_D.Digest}:
  P23_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_4(+hl: Nat) -> {P24_PRV.rd(hl, P24_PRV.ca(P24_PRV.ca(P24_PRV.ca(P24_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P24_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P24_O.U64{1, 0}))) == P24_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P24_PRV.sa(P24_PRV.sa(P24_PRV.sa(P24_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P24_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P24_O.U64{1, 0})))) : P24_D.Digest}:
  P24_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_fold(+hl: Nat) -> {P25_PRV.rd(hl, P25_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P25_O.mix_len(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, P25_D.node(hl, Pair.snd(P25_B.Buf, P25_D.Digest, FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_root(hl, P25_B.empty(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), 64)), P25_D.zconst(0n)), P25_D.zconst(1n)), P25_D.zconst(2n)), P25_D.zconst(3n)), P25_D.zconst(4n)), P25_D.zconst(5n)), P25_D.zconst(6n)), P25_D.zconst(7n)), P25_D.zconst(8n)), P25_D.zconst(9n)), P25_D.zconst(10n)), P25_D.zconst(11n)), P25_D.zconst(12n)), P25_D.zconst(13n)), P25_D.zconst(14n)), P25_D.zconst(15n)), P25_D.zconst(16n)), P25_D.zconst(17n)), P25_D.zconst(18n)), P25_D.zconst(19n)), P25_D.zconst(20n)), P25_D.zconst(21n)), P25_D.zconst(22n)), P25_D.zconst(23n)), P25_D.zconst(24n)), P25_D.zconst(25n)), P25_D.zconst(26n)), 1) : P25_D.Digest}:
  P25_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_dok() -> {(P26_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P26_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P26_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P26_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P26_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_end() -> {(Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Cached, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cset(P27_PRV.ca(P27_PRV.ca(P27_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P27_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())), (Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Cached, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cset(P27_PRV.ca(P27_PRV.ca(P27_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P27_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 2, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P27_O.U64{1, 0}))), (P27_PRV.is_none(Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Cached, Maybe<&1, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal>, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cget(P27_PRV.ca(P27_PRV.ca(P27_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P27_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 3))), P27_PRV.is_none(Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Cached, Maybe<&1, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal>, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cget(P27_PRV.ca(P27_PRV.ca(P27_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P27_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P27_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_0(+hl: Nat) -> {P28_PRV.rd(hl, P28_PRV.cs(P28_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P28_PRV.sa(P28_PRV.sa(P28_PRV.sa(P28_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P28_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P28_O.U64{1, 0})))), 0, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P28_O.U64{1, 0}))) == P28_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P28_PRV.ss(P28_PRV.sa(P28_PRV.sa(P28_PRV.sa(P28_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P28_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P28_O.U64{1, 0})), 0, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P28_O.U64{1, 0})))) : P28_D.Digest}:
  P28_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_1_3(+hl: Nat) -> {P29_PRV.rd(hl, P29_PRV.cs(P29_PRV.cs(P29_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P29_PRV.sa(P29_PRV.sa(P29_PRV.sa(P29_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P29_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P29_O.U64{1, 0})))), 1, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P29_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P29_PRV.ss(P29_PRV.ss(P29_PRV.sa(P29_PRV.sa(P29_PRV.sa(P29_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P29_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P29_O.U64{1, 0})), 1, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P29_D.Digest}:
  P29_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_3(+hl: Nat) -> {P30_PRV.rd(hl, P30_PRV.cs(P30_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P30_PRV.sa(P30_PRV.sa(P30_PRV.sa(P30_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P30_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P30_O.U64{1, 0})))), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P30_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P30_PRV.ss(P30_PRV.sa(P30_PRV.sa(P30_PRV.sa(P30_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P30_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P30_O.U64{1, 0})), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P30_D.Digest}:
  P30_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_1(+hl: Nat) -> {P31_PRV.rd(hl, P31_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default())) == P31_PRV.pd(hl, P31_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default())) : P31_D.Digest}:
  P31_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_2(+hl: Nat) -> {P32_PRV.rd(hl, P32_PRV.ca(P32_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P32_O.U64{1, 0}))) == P32_PRV.pd(hl, P32_PRV.sa(P32_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P32_O.U64{1, 0}))) : P32_D.Digest}:
  P32_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_3(+hl: Nat) -> {P33_PRV.rd(hl, P33_PRV.ca(P33_PRV.ca(P33_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P33_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default())) == P33_PRV.pd(hl, P33_PRV.sa(P33_PRV.sa(P33_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P33_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default())) : P33_D.Digest}:
  P33_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_4(+hl: Nat) -> {P34_PRV.rd(hl, P34_PRV.ca(P34_PRV.ca(P34_PRV.ca(P34_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P34_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P34_O.U64{1, 0}))) == P34_PRV.pd(hl, P34_PRV.sa(P34_PRV.sa(P34_PRV.sa(P34_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P34_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P34_O.U64{1, 0}))) : P34_D.Digest}:
  P34_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_dok() -> {(P35_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P35_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P35_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P35_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P35_PRV.BeaconState_vroot_l2048_Eth1Data_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_end() -> {(Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Cached, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cset(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P36_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), 3, FuluEth1Data_d.Eth1Data_default())), (Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Cached, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cset(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P36_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), 2, FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P36_O.U64{1, 0}))), (P36_PRV.is_none(Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Cached, Maybe<&1, FuluEth1Data_d.Eth1Data>, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cget(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P36_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), 3))), P36_PRV.is_none(Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Cached, Maybe<&1, FuluEth1Data_d.Eth1Data>, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cget(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P36_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P36_PRV.BeaconState_vroot_l2048_Eth1Data_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_set_0(+hl: Nat) -> {P37_PRV.rd(hl, P37_PRV.cs(P37_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P37_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P37_O.U64{1, 0})))), 0, FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P37_O.U64{1, 0}))) == P37_PRV.pd(hl, P37_PRV.ss(P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P37_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P37_O.U64{1, 0})), 0, FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P37_O.U64{1, 0}))) : P37_D.Digest}:
  P37_PRV.BeaconState_vroot_l2048_Eth1Data_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_set_1_3(+hl: Nat) -> {P38_PRV.rd(hl, P38_PRV.cs(P38_PRV.cs(P38_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P38_PRV.sa(P38_PRV.sa(P38_PRV.sa(P38_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P38_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P38_O.U64{1, 0})))), 1, FuluEth1Data_d.Eth1Data_default()), 3, FuluEth1Data_d.Eth1Data_default())) == P38_PRV.pd(hl, P38_PRV.ss(P38_PRV.ss(P38_PRV.sa(P38_PRV.sa(P38_PRV.sa(P38_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P38_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P38_O.U64{1, 0})), 1, FuluEth1Data_d.Eth1Data_default()), 3, FuluEth1Data_d.Eth1Data_default())) : P38_D.Digest}:
  P38_PRV.BeaconState_vroot_l2048_Eth1Data_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_set_3(+hl: Nat) -> {P39_PRV.rd(hl, P39_PRV.cs(P39_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P39_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P39_O.U64{1, 0})))), 3, FuluEth1Data_d.Eth1Data_default())) == P39_PRV.pd(hl, P39_PRV.ss(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P39_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P39_O.U64{1, 0})), 3, FuluEth1Data_d.Eth1Data_default())) : P39_D.Digest}:
  P39_PRV.BeaconState_vroot_l2048_Eth1Data_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_1(+hl: Nat) -> {P40_PRV.rd(hl, P40_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default())) == P40_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P40_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P40_D.Digest}:
  P40_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_2(+hl: Nat) -> {P41_PRV.rd(hl, P41_PRV.ca(P41_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P41_O.U64{1, 0}))) == P41_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P41_PRV.sa(P41_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P41_O.U64{1, 0})))) : P41_D.Digest}:
  P41_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_3(+hl: Nat) -> {P42_PRV.rd(hl, P42_PRV.ca(P42_PRV.ca(P42_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P42_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default())) == P42_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P42_PRV.sa(P42_PRV.sa(P42_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P42_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P42_D.Digest}:
  P42_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_4(+hl: Nat) -> {P43_PRV.rd(hl, P43_PRV.ca(P43_PRV.ca(P43_PRV.ca(P43_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P43_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P43_O.U64{1, 0}))) == P43_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P43_PRV.sa(P43_PRV.sa(P43_PRV.sa(P43_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P43_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P43_O.U64{1, 0})))) : P43_D.Digest}:
  P43_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_fold(+hl: Nat) -> {P44_PRV.rd(hl, P44_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default())) == P44_O.mix_len(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, P44_D.node(hl, Pair.snd(P44_B.Buf, P44_D.Digest, FuluPendingConsolidation_h.PendingConsolidation_root(hl, P44_B.empty(), FuluPendingConsolidation_d.PendingConsolidation_default(), 64)), P44_D.zconst(0n)), P44_D.zconst(1n)), P44_D.zconst(2n)), P44_D.zconst(3n)), P44_D.zconst(4n)), P44_D.zconst(5n)), P44_D.zconst(6n)), P44_D.zconst(7n)), P44_D.zconst(8n)), P44_D.zconst(9n)), P44_D.zconst(10n)), P44_D.zconst(11n)), P44_D.zconst(12n)), P44_D.zconst(13n)), P44_D.zconst(14n)), P44_D.zconst(15n)), P44_D.zconst(16n)), P44_D.zconst(17n)), 1) : P44_D.Digest}:
  P44_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_dok() -> {(P45_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P45_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P45_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P45_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P45_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_end() -> {(Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Cached, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cset(P46_PRV.ca(P46_PRV.ca(P46_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P46_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), 3, FuluPendingConsolidation_d.PendingConsolidation_default())), (Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Cached, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cset(P46_PRV.ca(P46_PRV.ca(P46_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P46_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), 2, FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P46_O.U64{1, 0}))), (P46_PRV.is_none(Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Cached, Maybe<&1, FuluPendingConsolidation_d.PendingConsolidation>, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cget(P46_PRV.ca(P46_PRV.ca(P46_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P46_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), 3))), P46_PRV.is_none(Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Cached, Maybe<&1, FuluPendingConsolidation_d.PendingConsolidation>, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cget(P46_PRV.ca(P46_PRV.ca(P46_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P46_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P46_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_set_0(+hl: Nat) -> {P47_PRV.rd(hl, P47_PRV.cs(P47_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P47_PRV.sa(P47_PRV.sa(P47_PRV.sa(P47_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P47_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P47_O.U64{1, 0})))), 0, FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P47_O.U64{1, 0}))) == P47_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P47_PRV.ss(P47_PRV.sa(P47_PRV.sa(P47_PRV.sa(P47_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P47_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P47_O.U64{1, 0})), 0, FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P47_O.U64{1, 0})))) : P47_D.Digest}:
  P47_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_set_1_3(+hl: Nat) -> {P48_PRV.rd(hl, P48_PRV.cs(P48_PRV.cs(P48_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P48_PRV.sa(P48_PRV.sa(P48_PRV.sa(P48_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P48_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P48_O.U64{1, 0})))), 1, FuluPendingConsolidation_d.PendingConsolidation_default()), 3, FuluPendingConsolidation_d.PendingConsolidation_default())) == P48_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P48_PRV.ss(P48_PRV.ss(P48_PRV.sa(P48_PRV.sa(P48_PRV.sa(P48_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P48_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P48_O.U64{1, 0})), 1, FuluPendingConsolidation_d.PendingConsolidation_default()), 3, FuluPendingConsolidation_d.PendingConsolidation_default()))) : P48_D.Digest}:
  P48_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_set_3(+hl: Nat) -> {P49_PRV.rd(hl, P49_PRV.cs(P49_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P49_PRV.sa(P49_PRV.sa(P49_PRV.sa(P49_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P49_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P49_O.U64{1, 0})))), 3, FuluPendingConsolidation_d.PendingConsolidation_default())) == P49_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P49_PRV.ss(P49_PRV.sa(P49_PRV.sa(P49_PRV.sa(P49_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P49_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P49_O.U64{1, 0})), 3, FuluPendingConsolidation_d.PendingConsolidation_default()))) : P49_D.Digest}:
  P49_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_set_3(hl)

