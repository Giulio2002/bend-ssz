import Base
import ../compact/found_generated.bend as P0_F
import ../../src/buffer.bend as P0_B
import ../../src/digest.bend as P0_D
import ../../src/obj.bend as P0_O
import ../../types/FuluBytes20_def_generated.bend as FuluBytes20_d
import ../../types/FuluDepositRequest_def_generated.bend as FuluDepositRequest_d
import ../../types/FuluConsolidationRequest_def_generated.bend as FuluConsolidationRequest_d
import ../../types/FuluWithdrawalRequest_def_generated.bend as FuluWithdrawalRequest_d
import ../../types/Fulu_list_DepositRequest_8192_def_generated.bend as Fulu_list_DepositRequest_8192_d
import ../../types/Fulu_list_WithdrawalRequest_16_def_generated.bend as Fulu_list_WithdrawalRequest_16_d
import ../../types/Fulu_list_ConsolidationRequest_2_def_generated.bend as Fulu_list_ConsolidationRequest_2_d
import ../../types/FuluExecutionRequests_def_generated.bend as FuluExecutionRequests_d
import ../../types/FuluExecutionRequests_hashtreeroot_generated.bend as FuluExecutionRequests_h
import ../../types/schema.bend as P0_S
import ../../types/primitive.bend as P0_P
import ../obj/cform.bend as P0_CF
import ../obj/amap.bend as P0_AM
import ../../spec/root_relation.bend as P0_RR
import ../../spec/fulu_schemas.bend as P0_Spec
import ../obj/schema_shapes_generated.bend as P0_SH
import ../obj/dk.bend as P0_DK
import ../obj/mtree_defs.bend as P0_MD
import ../obj/words_obj_light.bend as P0_WO_L
import ../obj/list_obj_light.bend as P0_LO_L
import ../obj/pv_obj_light.bend as P0_PV_L
import ../obj/bitlist_obj_light.bend as P0_BO_L
import ../obj/cells_light.bend as P0_CE_L
import ../obj/obj_support.bend as P0_OS
import ../obj/root_names_light_generated.bend as P0_RN_L
import ../obj/ulist_obj_light.bend as P0_UL_L
import ../obj/elems48_light.bend as P0_E48_L
import ../obj/xlist_support.bend as P0_XS
import ../obj/mtree_run.bend as P0_MR
import ../obj/words_cap.bend as P0_WC
import ../../spec/codec.bend as P0_Codec
import ../../spec/limits.bend as P0_Lim
import ../../spec/bit_root.bend as P0_Mix
import ../../spec/nat_bytes.bend as P0_Len
import ../../spec/byte_list.bend as P0_BL
import ../obj/root_types_light_generated.bend as P0_LV
import ../obj/root_types_generated.bend as P0_PRV
import ../../src/buffer.bend as P1_B
import ../../src/digest.bend as P1_D
import ../../src/obj.bend as P1_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_1_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/digest.bend as P2_D
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_2_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/digest.bend as P3_D
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_3_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/digest.bend as P4_D
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_4_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/digest.bend as P5_D
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_5_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/digest.bend as P6_D
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_clean_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/digest.bend as P7_D
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_dok_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/digest.bend as P8_D
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_end_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/digest.bend as P9_D
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_1_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/digest.bend as P10_D
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_2_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/digest.bend as P11_D
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_3_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/digest.bend as P12_D
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_4_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/digest.bend as P13_D
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_5_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/digest.bend as P14_D
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_limit_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/digest.bend as P15_D
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_1_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/digest.bend as P16_D
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_2_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/digest.bend as P17_D
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_3_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/digest.bend as P18_D
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_0_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/digest.bend as P19_D
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_1_3_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/digest.bend as P20_D
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_3_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/digest.bend as P21_D
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_app_1_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/digest.bend as P22_D
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_app_2_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/digest.bend as P23_D
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_dok_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/digest.bend as P24_D
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_end_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/digest.bend as P25_D
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_grow_1_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/digest.bend as P26_D
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_grow_2_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/digest.bend as P27_D
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_limit_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/digest.bend as P28_D
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_nonempty_1_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/digest.bend as P29_D
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_nonempty_2_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/digest.bend as P30_D
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_set_0_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/digest.bend as P31_D
import ../../src/obj.bend as P31_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l2_ConsolidationRequest_cache_set_1_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/digest.bend as P32_D
import ../../src/obj.bend as P32_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_1_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/digest.bend as P33_D
import ../../src/obj.bend as P33_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_2_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/digest.bend as P34_D
import ../../src/obj.bend as P34_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_3_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/digest.bend as P35_D
import ../../src/obj.bend as P35_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_4_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/digest.bend as P36_D
import ../../src/obj.bend as P36_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_5_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/digest.bend as P37_D
import ../../src/obj.bend as P37_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_clean_generated.bend as P37_PRV
import ../../src/buffer.bend as P38_B
import ../../src/digest.bend as P38_D
import ../../src/obj.bend as P38_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_dok_generated.bend as P38_PRV
import ../../src/buffer.bend as P39_B
import ../../src/digest.bend as P39_D
import ../../src/obj.bend as P39_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_end_generated.bend as P39_PRV
import ../../src/buffer.bend as P40_B
import ../../src/digest.bend as P40_D
import ../../src/obj.bend as P40_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_1_generated.bend as P40_PRV
import ../../src/buffer.bend as P41_B
import ../../src/digest.bend as P41_D
import ../../src/obj.bend as P41_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_2_generated.bend as P41_PRV
import ../../src/buffer.bend as P42_B
import ../../src/digest.bend as P42_D
import ../../src/obj.bend as P42_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_3_generated.bend as P42_PRV
import ../../src/buffer.bend as P43_B
import ../../src/digest.bend as P43_D
import ../../src/obj.bend as P43_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_4_generated.bend as P43_PRV
import ../../src/buffer.bend as P44_B
import ../../src/digest.bend as P44_D
import ../../src/obj.bend as P44_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_5_generated.bend as P44_PRV
import ../../src/buffer.bend as P45_B
import ../../src/digest.bend as P45_D
import ../../src/obj.bend as P45_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_1_generated.bend as P45_PRV
import ../../src/buffer.bend as P46_B
import ../../src/digest.bend as P46_D
import ../../src/obj.bend as P46_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_2_generated.bend as P46_PRV
import ../../src/buffer.bend as P47_B
import ../../src/digest.bend as P47_D
import ../../src/obj.bend as P47_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_3_generated.bend as P47_PRV
import ../../src/buffer.bend as P48_B
import ../../src/digest.bend as P48_D
import ../../src/obj.bend as P48_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_set_0_generated.bend as P48_PRV
import ../../src/buffer.bend as P49_B
import ../../src/digest.bend as P49_D
import ../../src/obj.bend as P49_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_set_1_3_generated.bend as P49_PRV
import ../../src/buffer.bend as P50_B
import ../../src/digest.bend as P50_D
import ../../src/obj.bend as P50_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_set_3_generated.bend as P50_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluExecutionRequests (ExecutionRequests): its hashtreeroot laws in the object API's terms, each discharged by its proving law.

def FuluExecutionRequests__root__ExecutionRequests_root_correct(-h: P0_B.Buf, -o: FuluExecutionRequests_d.ExecutionRequests, +s: P0_S.Schema, +es: {s == P0_Spec.ExecutionRequests() : P0_S.Schema}, +rep: P0_LV.rep_ExecutionRequests(o, s)) -> P0_RR.roots(P0_LV.v_ExecutionRequests(o), s, [P0_D.bytes(Pair.snd(FuluExecutionRequests_d.ExecutionRequests, P0_D.Digest, Pair.snd(P0_B.Buf, FuluExecutionRequests_d.ExecutionRequests & P0_D.Digest, FuluExecutionRequests_h.ExecutionRequests_hash_tree_root(h, o))))]):
  P0_PRV.ExecutionRequests_root_correct(h, o, s, es, rep)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_1(+hl: Nat) -> {P1_PRV.rd(hl, P1_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P1_PRV.pd(hl, P1_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P1_D.Digest}:
  P1_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_2(+hl: Nat) -> {P2_PRV.rd(hl, P2_PRV.ca(P2_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P2_O.U64{1, 0}))) == P2_PRV.pd(hl, P2_PRV.sa(P2_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P2_O.U64{1, 0}))) : P2_D.Digest}:
  P2_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_3(+hl: Nat) -> {P3_PRV.rd(hl, P3_PRV.ca(P3_PRV.ca(P3_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P3_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P3_PRV.pd(hl, P3_PRV.sa(P3_PRV.sa(P3_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P3_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P3_D.Digest}:
  P3_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_4(+hl: Nat) -> {P4_PRV.rd(hl, P4_PRV.ca(P4_PRV.ca(P4_PRV.ca(P4_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P4_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P4_O.U64{1, 0}))) == P4_PRV.pd(hl, P4_PRV.sa(P4_PRV.sa(P4_PRV.sa(P4_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P4_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P4_O.U64{1, 0}))) : P4_D.Digest}:
  P4_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_4(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_5(+hl: Nat) -> {P5_PRV.rd(hl, P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P5_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P5_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P5_PRV.rd(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P5_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P5_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()))) : P5_D.Digest}:
  P5_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_5(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_clean(+hl: Nat) -> {P6_PRV.rd(hl, P6_PRV.ca(P6_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()))), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0}))) == P6_PRV.pd(hl, P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0}))) : P6_D.Digest}:
  P6_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_app_clean(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_dok() -> {(P7_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P7_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P7_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P7_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P7_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_dok()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_end() -> {(Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Bool, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cset(P8_PRV.ca(P8_PRV.ca(P8_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())), (Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Bool, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cset(P8_PRV.ca(P8_PRV.ca(P8_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), 2, FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0}))), (P8_PRV.is_none(Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Maybe<&1, FuluWithdrawalRequest_d.WithdrawalRequest>, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cget(P8_PRV.ca(P8_PRV.ca(P8_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), 3))), P8_PRV.is_none(Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Maybe<&1, FuluWithdrawalRequest_d.WithdrawalRequest>, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cget(P8_PRV.ca(P8_PRV.ca(P8_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P8_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_end()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_1(+hl: Nat) -> {P9_PRV.rd(hl, P9_PRV.ca(P9_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P9_PRV.pd(hl, P9_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P9_D.Digest}:
  P9_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_2(+hl: Nat) -> {P10_PRV.rd(hl, P10_PRV.ca(P10_PRV.rc(hl, P10_PRV.ca(P10_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P10_O.U64{1, 0}))) == P10_PRV.pd(hl, P10_PRV.sa(P10_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P10_O.U64{1, 0}))) : P10_D.Digest}:
  P10_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_3(+hl: Nat) -> {P11_PRV.rd(hl, P11_PRV.ca(P11_PRV.rc(hl, P11_PRV.ca(P11_PRV.rc(hl, P11_PRV.ca(P11_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P11_O.U64{1, 0}))), FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P11_PRV.pd(hl, P11_PRV.sa(P11_PRV.sa(P11_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P11_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P11_D.Digest}:
  P11_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_4(+hl: Nat) -> {P12_PRV.rd(hl, P12_PRV.ca(P12_PRV.rc(hl, P12_PRV.ca(P12_PRV.rc(hl, P12_PRV.ca(P12_PRV.rc(hl, P12_PRV.ca(P12_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P12_O.U64{1, 0}))), FuluWithdrawalRequest_d.WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P12_O.U64{1, 0}))) == P12_PRV.pd(hl, P12_PRV.sa(P12_PRV.sa(P12_PRV.sa(P12_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P12_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P12_O.U64{1, 0}))) : P12_D.Digest}:
  P12_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_4(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_5(+hl: Nat) -> {P13_PRV.rd(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P13_O.U64{1, 0}))), FuluWithdrawalRequest_d.WithdrawalRequest_default())), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P13_O.U64{1, 0}))), FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P13_PRV.rd(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P13_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P13_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()))) : P13_D.Digest}:
  P13_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_grow_5(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_limit() -> {(Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Bool, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_capp(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default())), Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Bool, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_capp(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P14_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()))) == (True{}, False{}) : Bool & Bool}:
  P14_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_limit()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_1(+hl: Nat) -> {P15_PRV.rd(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P15_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()))) == P15_PRV.pd(hl, P15_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P15_D.Digest}:
  P15_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_2(+hl: Nat) -> {P16_PRV.rd(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P16_PRV.sa(P16_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P16_O.U64{1, 0})))) == P16_PRV.pd(hl, P16_PRV.sa(P16_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P16_O.U64{1, 0}))) : P16_D.Digest}:
  P16_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_3(+hl: Nat) -> {P17_PRV.rd(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P17_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()))) == P17_PRV.pd(hl, P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P17_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P17_D.Digest}:
  P17_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_nonempty_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_0(+hl: Nat) -> {P18_PRV.rd(hl, P18_PRV.cs(P18_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P18_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P18_O.U64{1, 0})))), 0, FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P18_O.U64{1, 0}))) == P18_PRV.pd(hl, P18_PRV.ss(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P18_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P18_O.U64{1, 0})), 0, FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P18_O.U64{1, 0}))) : P18_D.Digest}:
  P18_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_0(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_1_3(+hl: Nat) -> {P19_PRV.rd(hl, P19_PRV.cs(P19_PRV.cs(P19_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P19_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P19_O.U64{1, 0})))), 1, FuluWithdrawalRequest_d.WithdrawalRequest_default()), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P19_PRV.pd(hl, P19_PRV.ss(P19_PRV.ss(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P19_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P19_O.U64{1, 0})), 1, FuluWithdrawalRequest_d.WithdrawalRequest_default()), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P19_D.Digest}:
  P19_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_1_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_3(+hl: Nat) -> {P20_PRV.rd(hl, P20_PRV.cs(P20_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P20_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P20_O.U64{1, 0})))), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P20_PRV.pd(hl, P20_PRV.ss(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P20_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P20_O.U64{1, 0})), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P20_D.Digest}:
  P20_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_app_1(+hl: Nat) -> {P21_PRV.rd(hl, P21_PRV.ca(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default())) == P21_PRV.pd(hl, P21_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default())) : P21_D.Digest}:
  P21_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_app_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_app_2(+hl: Nat) -> {P22_PRV.rd(hl, P22_PRV.ca(P22_PRV.ca(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0}))) == P22_PRV.pd(hl, P22_PRV.sa(P22_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0}))) : P22_D.Digest}:
  P22_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_app_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_dok() -> {(P23_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P23_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P23_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P23_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P23_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_dok()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_end() -> {(Pair.snd(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Cached, Bool, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cset(P24_PRV.ca(P24_PRV.ca(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})), 2, FuluConsolidationRequest_d.ConsolidationRequest_default())), (Pair.snd(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Cached, Bool, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cset(P24_PRV.ca(P24_PRV.ca(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})), 1, FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0}))), (P24_PRV.is_none(Pair.snd(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Cached, Maybe<&1, FuluConsolidationRequest_d.ConsolidationRequest>, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cget(P24_PRV.ca(P24_PRV.ca(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})), 2))), P24_PRV.is_none(Pair.snd(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Cached, Maybe<&1, FuluConsolidationRequest_d.ConsolidationRequest>, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cget(P24_PRV.ca(P24_PRV.ca(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})), 1)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P24_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_end()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_grow_1(+hl: Nat) -> {P25_PRV.rd(hl, P25_PRV.ca(P25_PRV.rc(hl, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default())), FuluConsolidationRequest_d.ConsolidationRequest_default())) == P25_PRV.pd(hl, P25_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default())) : P25_D.Digest}:
  P25_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_grow_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_grow_2(+hl: Nat) -> {P26_PRV.rd(hl, P26_PRV.ca(P26_PRV.rc(hl, P26_PRV.ca(P26_PRV.rc(hl, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default())), FuluConsolidationRequest_d.ConsolidationRequest_default())), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0}))) == P26_PRV.pd(hl, P26_PRV.sa(P26_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0}))) : P26_D.Digest}:
  P26_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_grow_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_limit() -> {(Pair.snd(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Cached, Bool, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_capp(P27_PRV.ca(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default())), Pair.snd(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Cached, Bool, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_capp(P27_PRV.ca(P27_PRV.ca(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})), FuluConsolidationRequest_d.ConsolidationRequest_default()))) == (True{}, False{}) : Bool & Bool}:
  P27_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_limit()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_nonempty_1(+hl: Nat) -> {P28_PRV.rd(hl, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(P28_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()))) == P28_PRV.pd(hl, P28_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default())) : P28_D.Digest}:
  P28_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_nonempty_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_nonempty_2(+hl: Nat) -> {P29_PRV.rd(hl, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(P29_PRV.sa(P29_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})))) == P29_PRV.pd(hl, P29_PRV.sa(P29_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0}))) : P29_D.Digest}:
  P29_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_nonempty_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_set_0(+hl: Nat) -> {P30_PRV.rd(hl, P30_PRV.cs(P30_PRV.rc(hl, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(P30_PRV.sa(P30_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})))), 0, FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0}))) == P30_PRV.pd(hl, P30_PRV.ss(P30_PRV.sa(P30_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})), 0, FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0}))) : P30_D.Digest}:
  P30_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_set_0(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l2_ConsolidationRequest_cache_set_1(+hl: Nat) -> {P31_PRV.rd(hl, P31_PRV.cs(P31_PRV.rc(hl, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_cache(P31_PRV.sa(P31_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})))), 1, FuluConsolidationRequest_d.ConsolidationRequest_default())) == P31_PRV.pd(hl, P31_PRV.ss(P31_PRV.sa(P31_PRV.sa(Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_default(), FuluConsolidationRequest_d.ConsolidationRequest_default()), FuluConsolidationRequest_d.ConsolidationRequest_set_source_address(FuluConsolidationRequest_d.ConsolidationRequest_default(), FuluBytes20_d.Bytes20{1, 0, 0, 0, 0})), 1, FuluConsolidationRequest_d.ConsolidationRequest_default())) : P31_D.Digest}:
  P31_PRV.ExecutionRequests_vroot_l2_ConsolidationRequest_cache_set_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_1(+hl: Nat) -> {P32_PRV.rd(hl, P32_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default())) == P32_PRV.pd(hl, P32_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default())) : P32_D.Digest}:
  P32_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_2(+hl: Nat) -> {P33_PRV.rd(hl, P33_PRV.ca(P33_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P33_O.U64{1, 0}))) == P33_PRV.pd(hl, P33_PRV.sa(P33_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P33_O.U64{1, 0}))) : P33_D.Digest}:
  P33_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_3(+hl: Nat) -> {P34_PRV.rd(hl, P34_PRV.ca(P34_PRV.ca(P34_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P34_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default())) == P34_PRV.pd(hl, P34_PRV.sa(P34_PRV.sa(P34_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P34_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default())) : P34_D.Digest}:
  P34_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_4(+hl: Nat) -> {P35_PRV.rd(hl, P35_PRV.ca(P35_PRV.ca(P35_PRV.ca(P35_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P35_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P35_O.U64{1, 0}))) == P35_PRV.pd(hl, P35_PRV.sa(P35_PRV.sa(P35_PRV.sa(P35_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P35_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P35_O.U64{1, 0}))) : P35_D.Digest}:
  P35_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_4(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_5(+hl: Nat) -> {P36_PRV.rd(hl, P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P36_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P36_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default())) == P36_PRV.rd(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P36_PRV.sa(P36_PRV.sa(P36_PRV.sa(P36_PRV.sa(P36_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P36_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P36_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()))) : P36_D.Digest}:
  P36_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_5(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_clean(+hl: Nat) -> {P37_PRV.rd(hl, P37_PRV.ca(P37_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P37_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()))), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P37_O.U64{1, 0}))) == P37_PRV.pd(hl, P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P37_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P37_O.U64{1, 0}))) : P37_D.Digest}:
  P37_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_clean(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_dok() -> {(P38_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P38_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P38_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P38_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P38_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_dok()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_end() -> {(Pair.snd(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Cached, Bool, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cset(P39_PRV.ca(P39_PRV.ca(P39_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P39_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), 3, FuluDepositRequest_d.DepositRequest_default())), (Pair.snd(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Cached, Bool, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cset(P39_PRV.ca(P39_PRV.ca(P39_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P39_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), 2, FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P39_O.U64{1, 0}))), (P39_PRV.is_none(Pair.snd(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Cached, Maybe<&1, FuluDepositRequest_d.DepositRequest>, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cget(P39_PRV.ca(P39_PRV.ca(P39_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P39_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), 3))), P39_PRV.is_none(Pair.snd(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Cached, Maybe<&1, FuluDepositRequest_d.DepositRequest>, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cget(P39_PRV.ca(P39_PRV.ca(P39_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P39_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P39_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_end()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_1(+hl: Nat) -> {P40_PRV.rd(hl, P40_PRV.ca(P40_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default())), FuluDepositRequest_d.DepositRequest_default())) == P40_PRV.pd(hl, P40_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default())) : P40_D.Digest}:
  P40_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_2(+hl: Nat) -> {P41_PRV.rd(hl, P41_PRV.ca(P41_PRV.rc(hl, P41_PRV.ca(P41_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default())), FuluDepositRequest_d.DepositRequest_default())), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P41_O.U64{1, 0}))) == P41_PRV.pd(hl, P41_PRV.sa(P41_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P41_O.U64{1, 0}))) : P41_D.Digest}:
  P41_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_3(+hl: Nat) -> {P42_PRV.rd(hl, P42_PRV.ca(P42_PRV.rc(hl, P42_PRV.ca(P42_PRV.rc(hl, P42_PRV.ca(P42_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default())), FuluDepositRequest_d.DepositRequest_default())), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P42_O.U64{1, 0}))), FuluDepositRequest_d.DepositRequest_default())) == P42_PRV.pd(hl, P42_PRV.sa(P42_PRV.sa(P42_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P42_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default())) : P42_D.Digest}:
  P42_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_4(+hl: Nat) -> {P43_PRV.rd(hl, P43_PRV.ca(P43_PRV.rc(hl, P43_PRV.ca(P43_PRV.rc(hl, P43_PRV.ca(P43_PRV.rc(hl, P43_PRV.ca(P43_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default())), FuluDepositRequest_d.DepositRequest_default())), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P43_O.U64{1, 0}))), FuluDepositRequest_d.DepositRequest_default())), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P43_O.U64{1, 0}))) == P43_PRV.pd(hl, P43_PRV.sa(P43_PRV.sa(P43_PRV.sa(P43_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P43_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P43_O.U64{1, 0}))) : P43_D.Digest}:
  P43_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_4(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_5(+hl: Nat) -> {P44_PRV.rd(hl, P44_PRV.ca(P44_PRV.rc(hl, P44_PRV.ca(P44_PRV.rc(hl, P44_PRV.ca(P44_PRV.rc(hl, P44_PRV.ca(P44_PRV.rc(hl, P44_PRV.ca(P44_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default())), FuluDepositRequest_d.DepositRequest_default())), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P44_O.U64{1, 0}))), FuluDepositRequest_d.DepositRequest_default())), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P44_O.U64{1, 0}))), FuluDepositRequest_d.DepositRequest_default())) == P44_PRV.rd(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P44_PRV.sa(P44_PRV.sa(P44_PRV.sa(P44_PRV.sa(P44_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P44_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P44_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()))) : P44_D.Digest}:
  P44_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_grow_5(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_1(+hl: Nat) -> {P45_PRV.rd(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P45_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()))) == P45_PRV.pd(hl, P45_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default())) : P45_D.Digest}:
  P45_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_2(+hl: Nat) -> {P46_PRV.rd(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P46_PRV.sa(P46_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P46_O.U64{1, 0})))) == P46_PRV.pd(hl, P46_PRV.sa(P46_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P46_O.U64{1, 0}))) : P46_D.Digest}:
  P46_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_3(+hl: Nat) -> {P47_PRV.rd(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P47_PRV.sa(P47_PRV.sa(P47_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P47_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()))) == P47_PRV.pd(hl, P47_PRV.sa(P47_PRV.sa(P47_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P47_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default())) : P47_D.Digest}:
  P47_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_nonempty_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_set_0(+hl: Nat) -> {P48_PRV.rd(hl, P48_PRV.cs(P48_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P48_PRV.sa(P48_PRV.sa(P48_PRV.sa(P48_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P48_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P48_O.U64{1, 0})))), 0, FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P48_O.U64{1, 0}))) == P48_PRV.pd(hl, P48_PRV.ss(P48_PRV.sa(P48_PRV.sa(P48_PRV.sa(P48_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P48_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P48_O.U64{1, 0})), 0, FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P48_O.U64{1, 0}))) : P48_D.Digest}:
  P48_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_set_0(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_set_1_3(+hl: Nat) -> {P49_PRV.rd(hl, P49_PRV.cs(P49_PRV.cs(P49_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P49_PRV.sa(P49_PRV.sa(P49_PRV.sa(P49_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P49_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P49_O.U64{1, 0})))), 1, FuluDepositRequest_d.DepositRequest_default()), 3, FuluDepositRequest_d.DepositRequest_default())) == P49_PRV.pd(hl, P49_PRV.ss(P49_PRV.ss(P49_PRV.sa(P49_PRV.sa(P49_PRV.sa(P49_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P49_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P49_O.U64{1, 0})), 1, FuluDepositRequest_d.DepositRequest_default()), 3, FuluDepositRequest_d.DepositRequest_default())) : P49_D.Digest}:
  P49_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_set_1_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_set_3(+hl: Nat) -> {P50_PRV.rd(hl, P50_PRV.cs(P50_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P50_PRV.sa(P50_PRV.sa(P50_PRV.sa(P50_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P50_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P50_O.U64{1, 0})))), 3, FuluDepositRequest_d.DepositRequest_default())) == P50_PRV.pd(hl, P50_PRV.ss(P50_PRV.sa(P50_PRV.sa(P50_PRV.sa(P50_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P50_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P50_O.U64{1, 0})), 3, FuluDepositRequest_d.DepositRequest_default())) : P50_D.Digest}:
  P50_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_set_3(hl)

