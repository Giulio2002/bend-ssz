import Base
import ../compact/found_generated.bend as P0_F
import ../../src/buffer.bend as P0_B
import ../../src/digest.bend as P0_D
import ../../src/obj.bend as P0_O
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluPendingConsolidation_def_generated.bend as FuluPendingConsolidation_d
import ../../types/FuluPendingConsolidation_hashtreeroot_generated.bend as FuluPendingConsolidation_h
import ../../types/FuluPendingPartialWithdrawal_def_generated.bend as FuluPendingPartialWithdrawal_d
import ../../types/FuluPendingPartialWithdrawal_hashtreeroot_generated.bend as FuluPendingPartialWithdrawal_h
import ../../types/FuluHistoricalSummary_def_generated.bend as FuluHistoricalSummary_d
import ../../types/FuluHistoricalSummary_hashtreeroot_generated.bend as FuluHistoricalSummary_h
import ../../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../../types/FuluPendingDeposit_def_generated.bend as FuluPendingDeposit_d
import ../../types/FuluPendingDeposit_hashtreeroot_generated.bend as FuluPendingDeposit_h
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/FuluValidator_hashtreeroot_generated.bend as FuluValidator_h
import ../../types/Fulu_list_Eth1Data_2048_def_generated.bend as Fulu_list_Eth1Data_2048_d
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d
import ../../types/Fulu_list_HistoricalSummary_16777216_def_generated.bend as Fulu_list_HistoricalSummary_16777216_d
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
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_app_5_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/digest.bend as P6_D
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_app_clean_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/digest.bend as P7_D
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_app_fold_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/digest.bend as P8_D
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_dok_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/digest.bend as P9_D
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_end_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/digest.bend as P10_D
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_grow_1_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/digest.bend as P11_D
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_grow_2_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/digest.bend as P12_D
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_grow_3_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/digest.bend as P13_D
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_grow_4_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/digest.bend as P14_D
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_grow_5_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/digest.bend as P15_D
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_nonempty_1_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/digest.bend as P16_D
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_nonempty_2_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/digest.bend as P17_D
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_nonempty_3_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/digest.bend as P18_D
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_set_0_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/digest.bend as P19_D
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_set_1_3_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/digest.bend as P20_D
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_BeaconState_vroot_l1099511627776_Validator_cache_set_3_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/digest.bend as P21_D
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_1_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/digest.bend as P22_D
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_2_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/digest.bend as P23_D
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_3_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/digest.bend as P24_D
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_4_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/digest.bend as P25_D
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_5_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/digest.bend as P26_D
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_clean_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/digest.bend as P27_D
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_app_fold_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/digest.bend as P28_D
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_dok_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/digest.bend as P29_D
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_end_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/digest.bend as P30_D
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_grow_1_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/digest.bend as P31_D
import ../../src/obj.bend as P31_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_grow_2_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/digest.bend as P32_D
import ../../src/obj.bend as P32_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_grow_3_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/digest.bend as P33_D
import ../../src/obj.bend as P33_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_grow_4_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/digest.bend as P34_D
import ../../src/obj.bend as P34_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_grow_5_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/digest.bend as P35_D
import ../../src/obj.bend as P35_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_1_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/digest.bend as P36_D
import ../../src/obj.bend as P36_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_2_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/digest.bend as P37_D
import ../../src/obj.bend as P37_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_3_generated.bend as P37_PRV
import ../../src/buffer.bend as P38_B
import ../../src/digest.bend as P38_D
import ../../src/obj.bend as P38_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_set_0_generated.bend as P38_PRV
import ../../src/buffer.bend as P39_B
import ../../src/digest.bend as P39_D
import ../../src/obj.bend as P39_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_set_1_3_generated.bend as P39_PRV
import ../../src/buffer.bend as P40_B
import ../../src/digest.bend as P40_D
import ../../src/obj.bend as P40_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingDeposit_cache_set_3_generated.bend as P40_PRV
import ../../src/buffer.bend as P41_B
import ../../src/digest.bend as P41_D
import ../../src/obj.bend as P41_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_1_generated.bend as P41_PRV
import ../../src/buffer.bend as P42_B
import ../../src/digest.bend as P42_D
import ../../src/obj.bend as P42_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_2_generated.bend as P42_PRV
import ../../src/buffer.bend as P43_B
import ../../src/digest.bend as P43_D
import ../../src/obj.bend as P43_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_3_generated.bend as P43_PRV
import ../../src/buffer.bend as P44_B
import ../../src/digest.bend as P44_D
import ../../src/obj.bend as P44_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_4_generated.bend as P44_PRV
import ../../src/buffer.bend as P45_B
import ../../src/digest.bend as P45_D
import ../../src/obj.bend as P45_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_5_generated.bend as P45_PRV
import ../../src/buffer.bend as P46_B
import ../../src/digest.bend as P46_D
import ../../src/obj.bend as P46_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_clean_generated.bend as P46_PRV
import ../../src/buffer.bend as P47_B
import ../../src/digest.bend as P47_D
import ../../src/obj.bend as P47_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_fold_generated.bend as P47_PRV
import ../../src/buffer.bend as P48_B
import ../../src/digest.bend as P48_D
import ../../src/obj.bend as P48_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_dok_generated.bend as P48_PRV
import ../../src/buffer.bend as P49_B
import ../../src/digest.bend as P49_D
import ../../src/obj.bend as P49_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_end_generated.bend as P49_PRV
import ../../src/buffer.bend as P50_B
import ../../src/digest.bend as P50_D
import ../../src/obj.bend as P50_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_1_generated.bend as P50_PRV
import ../../src/buffer.bend as P51_B
import ../../src/digest.bend as P51_D
import ../../src/obj.bend as P51_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_2_generated.bend as P51_PRV
import ../../src/buffer.bend as P52_B
import ../../src/digest.bend as P52_D
import ../../src/obj.bend as P52_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_3_generated.bend as P52_PRV
import ../../src/buffer.bend as P53_B
import ../../src/digest.bend as P53_D
import ../../src/obj.bend as P53_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_4_generated.bend as P53_PRV
import ../../src/buffer.bend as P54_B
import ../../src/digest.bend as P54_D
import ../../src/obj.bend as P54_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_5_generated.bend as P54_PRV
import ../../src/buffer.bend as P55_B
import ../../src/digest.bend as P55_D
import ../../src/obj.bend as P55_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_1_generated.bend as P55_PRV
import ../../src/buffer.bend as P56_B
import ../../src/digest.bend as P56_D
import ../../src/obj.bend as P56_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_2_generated.bend as P56_PRV
import ../../src/buffer.bend as P57_B
import ../../src/digest.bend as P57_D
import ../../src/obj.bend as P57_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_3_generated.bend as P57_PRV
import ../../src/buffer.bend as P58_B
import ../../src/digest.bend as P58_D
import ../../src/obj.bend as P58_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_0_generated.bend as P58_PRV
import ../../src/buffer.bend as P59_B
import ../../src/digest.bend as P59_D
import ../../src/obj.bend as P59_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_1_3_generated.bend as P59_PRV
import ../../src/buffer.bend as P60_B
import ../../src/digest.bend as P60_D
import ../../src/obj.bend as P60_O
import ../slop/validity/fulu_BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_3_generated.bend as P60_PRV
import ../../src/buffer.bend as P61_B
import ../../src/digest.bend as P61_D
import ../../src/obj.bend as P61_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_app_1_generated.bend as P61_PRV
import ../../src/buffer.bend as P62_B
import ../../src/digest.bend as P62_D
import ../../src/obj.bend as P62_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_app_2_generated.bend as P62_PRV
import ../../src/buffer.bend as P63_B
import ../../src/digest.bend as P63_D
import ../../src/obj.bend as P63_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_app_3_generated.bend as P63_PRV
import ../../src/buffer.bend as P64_B
import ../../src/digest.bend as P64_D
import ../../src/obj.bend as P64_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_app_4_generated.bend as P64_PRV
import ../../src/buffer.bend as P65_B
import ../../src/digest.bend as P65_D
import ../../src/obj.bend as P65_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_app_5_generated.bend as P65_PRV
import ../../src/buffer.bend as P66_B
import ../../src/digest.bend as P66_D
import ../../src/obj.bend as P66_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_app_clean_generated.bend as P66_PRV
import ../../src/buffer.bend as P67_B
import ../../src/digest.bend as P67_D
import ../../src/obj.bend as P67_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_app_fold_generated.bend as P67_PRV
import ../../src/buffer.bend as P68_B
import ../../src/digest.bend as P68_D
import ../../src/obj.bend as P68_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_dok_generated.bend as P68_PRV
import ../../src/buffer.bend as P69_B
import ../../src/digest.bend as P69_D
import ../../src/obj.bend as P69_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_end_generated.bend as P69_PRV
import ../../src/buffer.bend as P70_B
import ../../src/digest.bend as P70_D
import ../../src/obj.bend as P70_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_1_generated.bend as P70_PRV
import ../../src/buffer.bend as P71_B
import ../../src/digest.bend as P71_D
import ../../src/obj.bend as P71_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_2_generated.bend as P71_PRV
import ../../src/buffer.bend as P72_B
import ../../src/digest.bend as P72_D
import ../../src/obj.bend as P72_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_3_generated.bend as P72_PRV
import ../../src/buffer.bend as P73_B
import ../../src/digest.bend as P73_D
import ../../src/obj.bend as P73_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_4_generated.bend as P73_PRV
import ../../src/buffer.bend as P74_B
import ../../src/digest.bend as P74_D
import ../../src/obj.bend as P74_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_5_generated.bend as P74_PRV
import ../../src/buffer.bend as P75_B
import ../../src/digest.bend as P75_D
import ../../src/obj.bend as P75_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_1_generated.bend as P75_PRV
import ../../src/buffer.bend as P76_B
import ../../src/digest.bend as P76_D
import ../../src/obj.bend as P76_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_2_generated.bend as P76_PRV
import ../../src/buffer.bend as P77_B
import ../../src/digest.bend as P77_D
import ../../src/obj.bend as P77_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_3_generated.bend as P77_PRV
import ../../src/buffer.bend as P78_B
import ../../src/digest.bend as P78_D
import ../../src/obj.bend as P78_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_set_0_generated.bend as P78_PRV
import ../../src/buffer.bend as P79_B
import ../../src/digest.bend as P79_D
import ../../src/obj.bend as P79_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_set_1_3_generated.bend as P79_PRV
import ../../src/buffer.bend as P80_B
import ../../src/digest.bend as P80_D
import ../../src/obj.bend as P80_O
import ../slop/validity/fulu_BeaconState_vroot_l16777216_HistoricalSummary_cache_set_3_generated.bend as P80_PRV
import ../../src/buffer.bend as P81_B
import ../../src/digest.bend as P81_D
import ../../src/obj.bend as P81_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_1_generated.bend as P81_PRV
import ../../src/buffer.bend as P82_B
import ../../src/digest.bend as P82_D
import ../../src/obj.bend as P82_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_2_generated.bend as P82_PRV
import ../../src/buffer.bend as P83_B
import ../../src/digest.bend as P83_D
import ../../src/obj.bend as P83_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_3_generated.bend as P83_PRV
import ../../src/buffer.bend as P84_B
import ../../src/digest.bend as P84_D
import ../../src/obj.bend as P84_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_4_generated.bend as P84_PRV
import ../../src/buffer.bend as P85_B
import ../../src/digest.bend as P85_D
import ../../src/obj.bend as P85_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_5_generated.bend as P85_PRV
import ../../src/buffer.bend as P86_B
import ../../src/digest.bend as P86_D
import ../../src/obj.bend as P86_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_app_clean_generated.bend as P86_PRV
import ../../src/buffer.bend as P87_B
import ../../src/digest.bend as P87_D
import ../../src/obj.bend as P87_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_dok_generated.bend as P87_PRV
import ../../src/buffer.bend as P88_B
import ../../src/digest.bend as P88_D
import ../../src/obj.bend as P88_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_end_generated.bend as P88_PRV
import ../../src/buffer.bend as P89_B
import ../../src/digest.bend as P89_D
import ../../src/obj.bend as P89_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_grow_1_generated.bend as P89_PRV
import ../../src/buffer.bend as P90_B
import ../../src/digest.bend as P90_D
import ../../src/obj.bend as P90_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_grow_2_generated.bend as P90_PRV
import ../../src/buffer.bend as P91_B
import ../../src/digest.bend as P91_D
import ../../src/obj.bend as P91_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_grow_3_generated.bend as P91_PRV
import ../../src/buffer.bend as P92_B
import ../../src/digest.bend as P92_D
import ../../src/obj.bend as P92_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_grow_4_generated.bend as P92_PRV
import ../../src/buffer.bend as P93_B
import ../../src/digest.bend as P93_D
import ../../src/obj.bend as P93_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_grow_5_generated.bend as P93_PRV
import ../../src/buffer.bend as P94_B
import ../../src/digest.bend as P94_D
import ../../src/obj.bend as P94_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_nonempty_1_generated.bend as P94_PRV
import ../../src/buffer.bend as P95_B
import ../../src/digest.bend as P95_D
import ../../src/obj.bend as P95_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_nonempty_2_generated.bend as P95_PRV
import ../../src/buffer.bend as P96_B
import ../../src/digest.bend as P96_D
import ../../src/obj.bend as P96_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_nonempty_3_generated.bend as P96_PRV
import ../../src/buffer.bend as P97_B
import ../../src/digest.bend as P97_D
import ../../src/obj.bend as P97_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_set_0_generated.bend as P97_PRV
import ../../src/buffer.bend as P98_B
import ../../src/digest.bend as P98_D
import ../../src/obj.bend as P98_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_set_1_3_generated.bend as P98_PRV
import ../../src/buffer.bend as P99_B
import ../../src/digest.bend as P99_D
import ../../src/obj.bend as P99_O
import ../slop/validity/fulu_BeaconState_vroot_l2048_Eth1Data_cache_set_3_generated.bend as P99_PRV
import ../../src/buffer.bend as P100_B
import ../../src/digest.bend as P100_D
import ../../src/obj.bend as P100_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_1_generated.bend as P100_PRV
import ../../src/buffer.bend as P101_B
import ../../src/digest.bend as P101_D
import ../../src/obj.bend as P101_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_2_generated.bend as P101_PRV
import ../../src/buffer.bend as P102_B
import ../../src/digest.bend as P102_D
import ../../src/obj.bend as P102_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_3_generated.bend as P102_PRV
import ../../src/buffer.bend as P103_B
import ../../src/digest.bend as P103_D
import ../../src/obj.bend as P103_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_4_generated.bend as P103_PRV
import ../../src/buffer.bend as P104_B
import ../../src/digest.bend as P104_D
import ../../src/obj.bend as P104_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_5_generated.bend as P104_PRV
import ../../src/buffer.bend as P105_B
import ../../src/digest.bend as P105_D
import ../../src/obj.bend as P105_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_clean_generated.bend as P105_PRV
import ../../src/buffer.bend as P106_B
import ../../src/digest.bend as P106_D
import ../../src/obj.bend as P106_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_app_fold_generated.bend as P106_PRV
import ../../src/buffer.bend as P107_B
import ../../src/digest.bend as P107_D
import ../../src/obj.bend as P107_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_dok_generated.bend as P107_PRV
import ../../src/buffer.bend as P108_B
import ../../src/digest.bend as P108_D
import ../../src/obj.bend as P108_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_end_generated.bend as P108_PRV
import ../../src/buffer.bend as P109_B
import ../../src/digest.bend as P109_D
import ../../src/obj.bend as P109_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_grow_1_generated.bend as P109_PRV
import ../../src/buffer.bend as P110_B
import ../../src/digest.bend as P110_D
import ../../src/obj.bend as P110_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_grow_2_generated.bend as P110_PRV
import ../../src/buffer.bend as P111_B
import ../../src/digest.bend as P111_D
import ../../src/obj.bend as P111_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_grow_3_generated.bend as P111_PRV
import ../../src/buffer.bend as P112_B
import ../../src/digest.bend as P112_D
import ../../src/obj.bend as P112_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_grow_4_generated.bend as P112_PRV
import ../../src/buffer.bend as P113_B
import ../../src/digest.bend as P113_D
import ../../src/obj.bend as P113_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_grow_5_generated.bend as P113_PRV
import ../../src/buffer.bend as P114_B
import ../../src/digest.bend as P114_D
import ../../src/obj.bend as P114_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_1_generated.bend as P114_PRV
import ../../src/buffer.bend as P115_B
import ../../src/digest.bend as P115_D
import ../../src/obj.bend as P115_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_2_generated.bend as P115_PRV
import ../../src/buffer.bend as P116_B
import ../../src/digest.bend as P116_D
import ../../src/obj.bend as P116_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_3_generated.bend as P116_PRV
import ../../src/buffer.bend as P117_B
import ../../src/digest.bend as P117_D
import ../../src/obj.bend as P117_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_set_0_generated.bend as P117_PRV
import ../../src/buffer.bend as P118_B
import ../../src/digest.bend as P118_D
import ../../src/obj.bend as P118_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_set_1_3_generated.bend as P118_PRV
import ../../src/buffer.bend as P119_B
import ../../src/digest.bend as P119_D
import ../../src/obj.bend as P119_O
import ../slop/validity/fulu_BeaconState_vroot_l262144_PendingConsolidation_cache_set_3_generated.bend as P119_PRV
import ../../src/buffer.bend as P120_B
import ../../src/digest.bend as P120_D
import ../../src/obj.bend as P120_O
import ../slop/validity/fulu_BeaconState_vrootj1_l1099511627776_u8_generated.bend as P120_PRV
import ../../src/buffer.bend as P121_B
import ../../src/digest.bend as P121_D
import ../../src/obj.bend as P121_O
import ../slop/validity/fulu_BeaconState_vrootj_l1099511627776_u64_generated.bend as P121_PRV
import ../../src/buffer.bend as P122_B
import ../../src/digest.bend as P122_D
import ../../src/obj.bend as P122_O
import ../slop/validity/fulu_BeaconState_vrootj_l1099511627776_u8_generated.bend as P122_PRV

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

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_app_5(+hl: Nat) -> {P5_PRV.rd(hl, P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P5_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P5_O.U64{1, 0})), FuluValidator_d.Validator_default())) == P5_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P5_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P5_O.U64{1, 0})), FuluValidator_d.Validator_default()))) : P5_D.Digest}:
  P5_PRV.BeaconState_vroot_l1099511627776_Validator_cache_app_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_app_clean(+hl: Nat) -> {P6_PRV.rd(hl, P6_PRV.ca(P6_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P6_O.U64{1, 0})), FuluValidator_d.Validator_default()))), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P6_O.U64{1, 0}))) == P6_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P6_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P6_O.U64{1, 0})))) : P6_D.Digest}:
  P6_PRV.BeaconState_vroot_l1099511627776_Validator_cache_app_clean(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_app_fold(+hl: Nat) -> {P7_PRV.rd(hl, P7_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default())) == P7_O.mix_len(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, Pair.snd(P7_B.Buf, P7_D.Digest, FuluValidator_h.Validator_root(hl, P7_B.empty(), FuluValidator_d.Validator_default(), 64)), P7_D.zconst(0n)), P7_D.zconst(1n)), P7_D.zconst(2n)), P7_D.zconst(3n)), P7_D.zconst(4n)), P7_D.zconst(5n)), P7_D.zconst(6n)), P7_D.zconst(7n)), P7_D.zconst(8n)), P7_D.zconst(9n)), P7_D.zconst(10n)), P7_D.zconst(11n)), P7_D.zconst(12n)), P7_D.zconst(13n)), P7_D.zconst(14n)), P7_D.zconst(15n)), P7_D.zconst(16n)), P7_D.zconst(17n)), P7_D.zconst(18n)), P7_D.zconst(19n)), P7_D.zconst(20n)), P7_D.zconst(21n)), P7_D.zconst(22n)), P7_D.zconst(23n)), P7_D.zconst(24n)), P7_D.zconst(25n)), P7_D.zconst(26n)), P7_D.zconst(27n)), P7_D.zconst(28n)), P7_D.zconst(29n)), P7_D.zconst(30n)), P7_D.zconst(31n)), P7_D.zconst(32n)), P7_D.zconst(33n)), P7_D.zconst(34n)), P7_D.zconst(35n)), P7_D.zconst(36n)), P7_D.zconst(37n)), P7_D.zconst(38n)), P7_D.zconst(39n)), 1) : P7_D.Digest}:
  P7_PRV.BeaconState_vroot_l1099511627776_Validator_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_dok() -> {(P8_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P8_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P8_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P8_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P8_PRV.BeaconState_vroot_l1099511627776_Validator_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_end() -> {(Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset(P9_PRV.ca(P9_PRV.ca(P9_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0})), FuluValidator_d.Validator_default()), 3, FuluValidator_d.Validator_default())), (Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, Bool, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset(P9_PRV.ca(P9_PRV.ca(P9_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0})), FuluValidator_d.Validator_default()), 2, FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0}))), (P9_PRV.is_none(Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, Maybe<&1, FuluValidator_d.Validator>, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cget(P9_PRV.ca(P9_PRV.ca(P9_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0})), FuluValidator_d.Validator_default()), 3))), P9_PRV.is_none(Pair.snd(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, Maybe<&1, FuluValidator_d.Validator>, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cget(P9_PRV.ca(P9_PRV.ca(P9_PRV.ca(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default()), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P9_O.U64{1, 0})), FuluValidator_d.Validator_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P9_PRV.BeaconState_vroot_l1099511627776_Validator_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_grow_1(+hl: Nat) -> {P10_PRV.rd(hl, P10_PRV.ca(P10_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default())), FuluValidator_d.Validator_default())) == P10_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P10_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()))) : P10_D.Digest}:
  P10_PRV.BeaconState_vroot_l1099511627776_Validator_cache_grow_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_grow_2(+hl: Nat) -> {P11_PRV.rd(hl, P11_PRV.ca(P11_PRV.rc(hl, P11_PRV.ca(P11_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default())), FuluValidator_d.Validator_default())), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P11_O.U64{1, 0}))) == P11_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P11_PRV.sa(P11_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P11_O.U64{1, 0})))) : P11_D.Digest}:
  P11_PRV.BeaconState_vroot_l1099511627776_Validator_cache_grow_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_grow_3(+hl: Nat) -> {P12_PRV.rd(hl, P12_PRV.ca(P12_PRV.rc(hl, P12_PRV.ca(P12_PRV.rc(hl, P12_PRV.ca(P12_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default())), FuluValidator_d.Validator_default())), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P12_O.U64{1, 0}))), FuluValidator_d.Validator_default())) == P12_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P12_PRV.sa(P12_PRV.sa(P12_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P12_O.U64{1, 0})), FuluValidator_d.Validator_default()))) : P12_D.Digest}:
  P12_PRV.BeaconState_vroot_l1099511627776_Validator_cache_grow_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_grow_4(+hl: Nat) -> {P13_PRV.rd(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default())), FuluValidator_d.Validator_default())), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P13_O.U64{1, 0}))), FuluValidator_d.Validator_default())), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P13_O.U64{1, 0}))) == P13_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P13_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P13_O.U64{1, 0})))) : P13_D.Digest}:
  P13_PRV.BeaconState_vroot_l1099511627776_Validator_cache_grow_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_grow_5(+hl: Nat) -> {P14_PRV.rd(hl, P14_PRV.ca(P14_PRV.rc(hl, P14_PRV.ca(P14_PRV.rc(hl, P14_PRV.ca(P14_PRV.rc(hl, P14_PRV.ca(P14_PRV.rc(hl, P14_PRV.ca(P14_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default())), FuluValidator_d.Validator_default())), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P14_O.U64{1, 0}))), FuluValidator_d.Validator_default())), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P14_O.U64{1, 0}))), FuluValidator_d.Validator_default())) == P14_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P14_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P14_O.U64{1, 0})), FuluValidator_d.Validator_default()))) : P14_D.Digest}:
  P14_PRV.BeaconState_vroot_l1099511627776_Validator_cache_grow_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_nonempty_1(+hl: Nat) -> {P15_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P15_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()))) == P15_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P15_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()))) : P15_D.Digest}:
  P15_PRV.BeaconState_vroot_l1099511627776_Validator_cache_nonempty_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_nonempty_2(+hl: Nat) -> {P16_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P16_PRV.sa(P16_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P16_O.U64{1, 0})))) == P16_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P16_PRV.sa(P16_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P16_O.U64{1, 0})))) : P16_D.Digest}:
  P16_PRV.BeaconState_vroot_l1099511627776_Validator_cache_nonempty_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_nonempty_3(+hl: Nat) -> {P17_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P17_O.U64{1, 0})), FuluValidator_d.Validator_default()))) == P17_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P17_O.U64{1, 0})), FuluValidator_d.Validator_default()))) : P17_D.Digest}:
  P17_PRV.BeaconState_vroot_l1099511627776_Validator_cache_nonempty_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_set_0(+hl: Nat) -> {P18_PRV.rd(hl, P18_PRV.cs(P18_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P18_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P18_O.U64{1, 0})))), 0, FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P18_O.U64{1, 0}))) == P18_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P18_PRV.ss(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P18_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P18_O.U64{1, 0})), 0, FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P18_O.U64{1, 0})))) : P18_D.Digest}:
  P18_PRV.BeaconState_vroot_l1099511627776_Validator_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_set_1_3(+hl: Nat) -> {P19_PRV.rd(hl, P19_PRV.cs(P19_PRV.cs(P19_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P19_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P19_O.U64{1, 0})))), 1, FuluValidator_d.Validator_default()), 3, FuluValidator_d.Validator_default())) == P19_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P19_PRV.ss(P19_PRV.ss(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P19_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P19_O.U64{1, 0})), 1, FuluValidator_d.Validator_default()), 3, FuluValidator_d.Validator_default()))) : P19_D.Digest}:
  P19_PRV.BeaconState_vroot_l1099511627776_Validator_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_Validator_cache_set_3(+hl: Nat) -> {P20_PRV.rd(hl, P20_PRV.cs(P20_PRV.rc(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P20_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P20_O.U64{1, 0})))), 3, FuluValidator_d.Validator_default())) == P20_PRV.rd(hl, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(P20_PRV.ss(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_default(), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P20_O.U64{1, 0})), FuluValidator_d.Validator_default()), FuluValidator_d.Validator_set_effective_balance(FuluValidator_d.Validator_default(), P20_O.U64{1, 0})), 3, FuluValidator_d.Validator_default()))) : P20_D.Digest}:
  P20_PRV.BeaconState_vroot_l1099511627776_Validator_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_1(+hl: Nat) -> {P21_PRV.rd(hl, P21_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default())) == P21_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P21_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()))) : P21_D.Digest}:
  P21_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_2(+hl: Nat) -> {P22_PRV.rd(hl, P22_PRV.ca(P22_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P22_O.U64{1, 0}))) == P22_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P22_PRV.sa(P22_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P22_O.U64{1, 0})))) : P22_D.Digest}:
  P22_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_3(+hl: Nat) -> {P23_PRV.rd(hl, P23_PRV.ca(P23_PRV.ca(P23_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P23_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default())) == P23_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P23_PRV.sa(P23_PRV.sa(P23_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P23_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()))) : P23_D.Digest}:
  P23_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_4(+hl: Nat) -> {P24_PRV.rd(hl, P24_PRV.ca(P24_PRV.ca(P24_PRV.ca(P24_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P24_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P24_O.U64{1, 0}))) == P24_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P24_PRV.sa(P24_PRV.sa(P24_PRV.sa(P24_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P24_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P24_O.U64{1, 0})))) : P24_D.Digest}:
  P24_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_5(+hl: Nat) -> {P25_PRV.rd(hl, P25_PRV.ca(P25_PRV.ca(P25_PRV.ca(P25_PRV.ca(P25_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P25_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P25_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default())) == P25_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P25_PRV.sa(P25_PRV.sa(P25_PRV.sa(P25_PRV.sa(P25_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P25_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P25_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()))) : P25_D.Digest}:
  P25_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_clean(+hl: Nat) -> {P26_PRV.rd(hl, P26_PRV.ca(P26_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P26_PRV.sa(P26_PRV.sa(P26_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P26_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()))), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P26_O.U64{1, 0}))) == P26_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P26_PRV.sa(P26_PRV.sa(P26_PRV.sa(P26_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P26_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P26_O.U64{1, 0})))) : P26_D.Digest}:
  P26_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_clean(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_app_fold(+hl: Nat) -> {P27_PRV.rd(hl, P27_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default())) == P27_O.mix_len(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, P27_D.node(hl, Pair.snd(P27_B.Buf, P27_D.Digest, FuluPendingDeposit_h.PendingDeposit_root(hl, P27_B.empty(), FuluPendingDeposit_d.PendingDeposit_default(), 64)), P27_D.zconst(0n)), P27_D.zconst(1n)), P27_D.zconst(2n)), P27_D.zconst(3n)), P27_D.zconst(4n)), P27_D.zconst(5n)), P27_D.zconst(6n)), P27_D.zconst(7n)), P27_D.zconst(8n)), P27_D.zconst(9n)), P27_D.zconst(10n)), P27_D.zconst(11n)), P27_D.zconst(12n)), P27_D.zconst(13n)), P27_D.zconst(14n)), P27_D.zconst(15n)), P27_D.zconst(16n)), P27_D.zconst(17n)), P27_D.zconst(18n)), P27_D.zconst(19n)), P27_D.zconst(20n)), P27_D.zconst(21n)), P27_D.zconst(22n)), P27_D.zconst(23n)), P27_D.zconst(24n)), P27_D.zconst(25n)), P27_D.zconst(26n)), 1) : P27_D.Digest}:
  P27_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_dok() -> {(P28_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P28_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P28_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P28_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P28_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_end() -> {(Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Cached, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cset(P29_PRV.ca(P29_PRV.ca(P29_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P29_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), 3, FuluPendingDeposit_d.PendingDeposit_default())), (Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Cached, Bool, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cset(P29_PRV.ca(P29_PRV.ca(P29_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P29_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), 2, FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P29_O.U64{1, 0}))), (P29_PRV.is_none(Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Cached, Maybe<&1, FuluPendingDeposit_d.PendingDeposit>, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cget(P29_PRV.ca(P29_PRV.ca(P29_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P29_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), 3))), P29_PRV.is_none(Pair.snd(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_Cached, Maybe<&1, FuluPendingDeposit_d.PendingDeposit>, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cget(P29_PRV.ca(P29_PRV.ca(P29_PRV.ca(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P29_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P29_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_grow_1(+hl: Nat) -> {P30_PRV.rd(hl, P30_PRV.ca(P30_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_default())) == P30_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P30_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()))) : P30_D.Digest}:
  P30_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_grow_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_grow_2(+hl: Nat) -> {P31_PRV.rd(hl, P31_PRV.ca(P31_PRV.rc(hl, P31_PRV.ca(P31_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P31_O.U64{1, 0}))) == P31_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P31_PRV.sa(P31_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P31_O.U64{1, 0})))) : P31_D.Digest}:
  P31_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_grow_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_grow_3(+hl: Nat) -> {P32_PRV.rd(hl, P32_PRV.ca(P32_PRV.rc(hl, P32_PRV.ca(P32_PRV.rc(hl, P32_PRV.ca(P32_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P32_O.U64{1, 0}))), FuluPendingDeposit_d.PendingDeposit_default())) == P32_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P32_PRV.sa(P32_PRV.sa(P32_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P32_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()))) : P32_D.Digest}:
  P32_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_grow_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_grow_4(+hl: Nat) -> {P33_PRV.rd(hl, P33_PRV.ca(P33_PRV.rc(hl, P33_PRV.ca(P33_PRV.rc(hl, P33_PRV.ca(P33_PRV.rc(hl, P33_PRV.ca(P33_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P33_O.U64{1, 0}))), FuluPendingDeposit_d.PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P33_O.U64{1, 0}))) == P33_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P33_PRV.sa(P33_PRV.sa(P33_PRV.sa(P33_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P33_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P33_O.U64{1, 0})))) : P33_D.Digest}:
  P33_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_grow_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_grow_5(+hl: Nat) -> {P34_PRV.rd(hl, P34_PRV.ca(P34_PRV.rc(hl, P34_PRV.ca(P34_PRV.rc(hl, P34_PRV.ca(P34_PRV.rc(hl, P34_PRV.ca(P34_PRV.rc(hl, P34_PRV.ca(P34_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P34_O.U64{1, 0}))), FuluPendingDeposit_d.PendingDeposit_default())), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P34_O.U64{1, 0}))), FuluPendingDeposit_d.PendingDeposit_default())) == P34_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P34_PRV.sa(P34_PRV.sa(P34_PRV.sa(P34_PRV.sa(P34_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P34_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P34_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()))) : P34_D.Digest}:
  P34_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_grow_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_1(+hl: Nat) -> {P35_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P35_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()))) == P35_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P35_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()))) : P35_D.Digest}:
  P35_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_2(+hl: Nat) -> {P36_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P36_PRV.sa(P36_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P36_O.U64{1, 0})))) == P36_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P36_PRV.sa(P36_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P36_O.U64{1, 0})))) : P36_D.Digest}:
  P36_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_3(+hl: Nat) -> {P37_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P37_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()))) == P37_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P37_PRV.sa(P37_PRV.sa(P37_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P37_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()))) : P37_D.Digest}:
  P37_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_nonempty_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_set_0(+hl: Nat) -> {P38_PRV.rd(hl, P38_PRV.cs(P38_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P38_PRV.sa(P38_PRV.sa(P38_PRV.sa(P38_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P38_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P38_O.U64{1, 0})))), 0, FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P38_O.U64{1, 0}))) == P38_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P38_PRV.ss(P38_PRV.sa(P38_PRV.sa(P38_PRV.sa(P38_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P38_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P38_O.U64{1, 0})), 0, FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P38_O.U64{1, 0})))) : P38_D.Digest}:
  P38_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_set_1_3(+hl: Nat) -> {P39_PRV.rd(hl, P39_PRV.cs(P39_PRV.cs(P39_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P39_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P39_O.U64{1, 0})))), 1, FuluPendingDeposit_d.PendingDeposit_default()), 3, FuluPendingDeposit_d.PendingDeposit_default())) == P39_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P39_PRV.ss(P39_PRV.ss(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P39_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P39_O.U64{1, 0})), 1, FuluPendingDeposit_d.PendingDeposit_default()), 3, FuluPendingDeposit_d.PendingDeposit_default()))) : P39_D.Digest}:
  P39_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingDeposit_cache_set_3(+hl: Nat) -> {P40_PRV.rd(hl, P40_PRV.cs(P40_PRV.rc(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P40_PRV.sa(P40_PRV.sa(P40_PRV.sa(P40_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P40_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P40_O.U64{1, 0})))), 3, FuluPendingDeposit_d.PendingDeposit_default())) == P40_PRV.rd(hl, Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_cache(P40_PRV.ss(P40_PRV.sa(P40_PRV.sa(P40_PRV.sa(P40_PRV.sa(Fulu_list_PendingDeposit_134217728_d.l134217728_PendingDeposit_default(), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P40_O.U64{1, 0})), FuluPendingDeposit_d.PendingDeposit_default()), FuluPendingDeposit_d.PendingDeposit_set_amount(FuluPendingDeposit_d.PendingDeposit_default(), P40_O.U64{1, 0})), 3, FuluPendingDeposit_d.PendingDeposit_default()))) : P40_D.Digest}:
  P40_PRV.BeaconState_vroot_l134217728_PendingDeposit_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_1(+hl: Nat) -> {P41_PRV.rd(hl, P41_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P41_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P41_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P41_D.Digest}:
  P41_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_2(+hl: Nat) -> {P42_PRV.rd(hl, P42_PRV.ca(P42_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P42_O.U64{1, 0}))) == P42_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P42_PRV.sa(P42_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P42_O.U64{1, 0})))) : P42_D.Digest}:
  P42_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_3(+hl: Nat) -> {P43_PRV.rd(hl, P43_PRV.ca(P43_PRV.ca(P43_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P43_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P43_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P43_PRV.sa(P43_PRV.sa(P43_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P43_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P43_D.Digest}:
  P43_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_4(+hl: Nat) -> {P44_PRV.rd(hl, P44_PRV.ca(P44_PRV.ca(P44_PRV.ca(P44_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P44_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P44_O.U64{1, 0}))) == P44_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P44_PRV.sa(P44_PRV.sa(P44_PRV.sa(P44_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P44_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P44_O.U64{1, 0})))) : P44_D.Digest}:
  P44_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_5(+hl: Nat) -> {P45_PRV.rd(hl, P45_PRV.ca(P45_PRV.ca(P45_PRV.ca(P45_PRV.ca(P45_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P45_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P45_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P45_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P45_PRV.sa(P45_PRV.sa(P45_PRV.sa(P45_PRV.sa(P45_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P45_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P45_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P45_D.Digest}:
  P45_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_clean(+hl: Nat) -> {P46_PRV.rd(hl, P46_PRV.ca(P46_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P46_PRV.sa(P46_PRV.sa(P46_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P46_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P46_O.U64{1, 0}))) == P46_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P46_PRV.sa(P46_PRV.sa(P46_PRV.sa(P46_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P46_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P46_O.U64{1, 0})))) : P46_D.Digest}:
  P46_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_clean(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_fold(+hl: Nat) -> {P47_PRV.rd(hl, P47_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P47_O.mix_len(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, P47_D.node(hl, Pair.snd(P47_B.Buf, P47_D.Digest, FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_root(hl, P47_B.empty(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), 64)), P47_D.zconst(0n)), P47_D.zconst(1n)), P47_D.zconst(2n)), P47_D.zconst(3n)), P47_D.zconst(4n)), P47_D.zconst(5n)), P47_D.zconst(6n)), P47_D.zconst(7n)), P47_D.zconst(8n)), P47_D.zconst(9n)), P47_D.zconst(10n)), P47_D.zconst(11n)), P47_D.zconst(12n)), P47_D.zconst(13n)), P47_D.zconst(14n)), P47_D.zconst(15n)), P47_D.zconst(16n)), P47_D.zconst(17n)), P47_D.zconst(18n)), P47_D.zconst(19n)), P47_D.zconst(20n)), P47_D.zconst(21n)), P47_D.zconst(22n)), P47_D.zconst(23n)), P47_D.zconst(24n)), P47_D.zconst(25n)), P47_D.zconst(26n)), 1) : P47_D.Digest}:
  P47_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_dok() -> {(P48_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P48_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P48_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P48_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P48_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_end() -> {(Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Cached, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cset(P49_PRV.ca(P49_PRV.ca(P49_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P49_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())), (Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Cached, Bool, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cset(P49_PRV.ca(P49_PRV.ca(P49_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P49_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 2, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P49_O.U64{1, 0}))), (P49_PRV.is_none(Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Cached, Maybe<&1, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal>, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cget(P49_PRV.ca(P49_PRV.ca(P49_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P49_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 3))), P49_PRV.is_none(Pair.snd(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_Cached, Maybe<&1, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal>, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cget(P49_PRV.ca(P49_PRV.ca(P49_PRV.ca(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P49_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P49_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_1(+hl: Nat) -> {P50_PRV.rd(hl, P50_PRV.ca(P50_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P50_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P50_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P50_D.Digest}:
  P50_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_2(+hl: Nat) -> {P51_PRV.rd(hl, P51_PRV.ca(P51_PRV.rc(hl, P51_PRV.ca(P51_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P51_O.U64{1, 0}))) == P51_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P51_PRV.sa(P51_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P51_O.U64{1, 0})))) : P51_D.Digest}:
  P51_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_3(+hl: Nat) -> {P52_PRV.rd(hl, P52_PRV.ca(P52_PRV.rc(hl, P52_PRV.ca(P52_PRV.rc(hl, P52_PRV.ca(P52_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P52_O.U64{1, 0}))), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P52_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P52_PRV.sa(P52_PRV.sa(P52_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P52_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P52_D.Digest}:
  P52_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_4(+hl: Nat) -> {P53_PRV.rd(hl, P53_PRV.ca(P53_PRV.rc(hl, P53_PRV.ca(P53_PRV.rc(hl, P53_PRV.ca(P53_PRV.rc(hl, P53_PRV.ca(P53_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P53_O.U64{1, 0}))), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P53_O.U64{1, 0}))) == P53_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P53_PRV.sa(P53_PRV.sa(P53_PRV.sa(P53_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P53_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P53_O.U64{1, 0})))) : P53_D.Digest}:
  P53_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_5(+hl: Nat) -> {P54_PRV.rd(hl, P54_PRV.ca(P54_PRV.rc(hl, P54_PRV.ca(P54_PRV.rc(hl, P54_PRV.ca(P54_PRV.rc(hl, P54_PRV.ca(P54_PRV.rc(hl, P54_PRV.ca(P54_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P54_O.U64{1, 0}))), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P54_O.U64{1, 0}))), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P54_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P54_PRV.sa(P54_PRV.sa(P54_PRV.sa(P54_PRV.sa(P54_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P54_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P54_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P54_D.Digest}:
  P54_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_grow_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_1(+hl: Nat) -> {P55_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P55_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) == P55_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P55_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P55_D.Digest}:
  P55_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_2(+hl: Nat) -> {P56_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P56_PRV.sa(P56_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P56_O.U64{1, 0})))) == P56_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P56_PRV.sa(P56_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P56_O.U64{1, 0})))) : P56_D.Digest}:
  P56_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_3(+hl: Nat) -> {P57_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P57_PRV.sa(P57_PRV.sa(P57_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P57_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) == P57_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P57_PRV.sa(P57_PRV.sa(P57_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P57_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P57_D.Digest}:
  P57_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_nonempty_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_0(+hl: Nat) -> {P58_PRV.rd(hl, P58_PRV.cs(P58_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P58_PRV.sa(P58_PRV.sa(P58_PRV.sa(P58_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P58_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P58_O.U64{1, 0})))), 0, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P58_O.U64{1, 0}))) == P58_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P58_PRV.ss(P58_PRV.sa(P58_PRV.sa(P58_PRV.sa(P58_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P58_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P58_O.U64{1, 0})), 0, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P58_O.U64{1, 0})))) : P58_D.Digest}:
  P58_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_1_3(+hl: Nat) -> {P59_PRV.rd(hl, P59_PRV.cs(P59_PRV.cs(P59_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P59_PRV.sa(P59_PRV.sa(P59_PRV.sa(P59_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P59_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P59_O.U64{1, 0})))), 1, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P59_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P59_PRV.ss(P59_PRV.ss(P59_PRV.sa(P59_PRV.sa(P59_PRV.sa(P59_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P59_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P59_O.U64{1, 0})), 1, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P59_D.Digest}:
  P59_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_3(+hl: Nat) -> {P60_PRV.rd(hl, P60_PRV.cs(P60_PRV.rc(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P60_PRV.sa(P60_PRV.sa(P60_PRV.sa(P60_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P60_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P60_O.U64{1, 0})))), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default())) == P60_PRV.rd(hl, Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_cache(P60_PRV.ss(P60_PRV.sa(P60_PRV.sa(P60_PRV.sa(P60_PRV.sa(Fulu_list_PendingPartialWithdrawal_134217728_d.l134217728_PendingPartialWithdrawal_default(), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P60_O.U64{1, 0})), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()), FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_set_validator_index(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default(), P60_O.U64{1, 0})), 3, FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal_default()))) : P60_D.Digest}:
  P60_PRV.BeaconState_vroot_l134217728_PendingPartialWithdrawal_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_app_1(+hl: Nat) -> {P61_PRV.rd(hl, P61_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default())) == P61_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P61_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()))) : P61_D.Digest}:
  P61_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_app_2(+hl: Nat) -> {P62_PRV.rd(hl, P62_PRV.ca(P62_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))) == P62_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P62_PRV.sa(P62_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))) : P62_D.Digest}:
  P62_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_app_3(+hl: Nat) -> {P63_PRV.rd(hl, P63_PRV.ca(P63_PRV.ca(P63_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default())) == P63_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P63_PRV.sa(P63_PRV.sa(P63_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()))) : P63_D.Digest}:
  P63_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_app_4(+hl: Nat) -> {P64_PRV.rd(hl, P64_PRV.ca(P64_PRV.ca(P64_PRV.ca(P64_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))) == P64_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P64_PRV.sa(P64_PRV.sa(P64_PRV.sa(P64_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))) : P64_D.Digest}:
  P64_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_app_5(+hl: Nat) -> {P65_PRV.rd(hl, P65_PRV.ca(P65_PRV.ca(P65_PRV.ca(P65_PRV.ca(P65_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default())) == P65_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P65_PRV.sa(P65_PRV.sa(P65_PRV.sa(P65_PRV.sa(P65_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()))) : P65_D.Digest}:
  P65_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_app_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_app_clean(+hl: Nat) -> {P66_PRV.rd(hl, P66_PRV.ca(P66_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P66_PRV.sa(P66_PRV.sa(P66_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()))), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))) == P66_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P66_PRV.sa(P66_PRV.sa(P66_PRV.sa(P66_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))) : P66_D.Digest}:
  P66_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_app_clean(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_app_fold(+hl: Nat) -> {P67_PRV.rd(hl, P67_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default())) == P67_O.mix_len(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, P67_D.node(hl, Pair.snd(P67_B.Buf, P67_D.Digest, FuluHistoricalSummary_h.HistoricalSummary_root(hl, P67_B.empty(), FuluHistoricalSummary_d.HistoricalSummary_default(), 64)), P67_D.zconst(0n)), P67_D.zconst(1n)), P67_D.zconst(2n)), P67_D.zconst(3n)), P67_D.zconst(4n)), P67_D.zconst(5n)), P67_D.zconst(6n)), P67_D.zconst(7n)), P67_D.zconst(8n)), P67_D.zconst(9n)), P67_D.zconst(10n)), P67_D.zconst(11n)), P67_D.zconst(12n)), P67_D.zconst(13n)), P67_D.zconst(14n)), P67_D.zconst(15n)), P67_D.zconst(16n)), P67_D.zconst(17n)), P67_D.zconst(18n)), P67_D.zconst(19n)), P67_D.zconst(20n)), P67_D.zconst(21n)), P67_D.zconst(22n)), P67_D.zconst(23n)), 1) : P67_D.Digest}:
  P67_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_dok() -> {(P68_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P68_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P68_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P68_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P68_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_end() -> {(Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Cached, Bool, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cset(P69_PRV.ca(P69_PRV.ca(P69_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), 3, FuluHistoricalSummary_d.HistoricalSummary_default())), (Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Cached, Bool, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cset(P69_PRV.ca(P69_PRV.ca(P69_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), 2, FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))), (P69_PRV.is_none(Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Cached, Maybe<&1, FuluHistoricalSummary_d.HistoricalSummary>, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cget(P69_PRV.ca(P69_PRV.ca(P69_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), 3))), P69_PRV.is_none(Pair.snd(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_Cached, Maybe<&1, FuluHistoricalSummary_d.HistoricalSummary>, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cget(P69_PRV.ca(P69_PRV.ca(P69_PRV.ca(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P69_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_1(+hl: Nat) -> {P70_PRV.rd(hl, P70_PRV.ca(P70_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_default())) == P70_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P70_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()))) : P70_D.Digest}:
  P70_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_2(+hl: Nat) -> {P71_PRV.rd(hl, P71_PRV.ca(P71_PRV.rc(hl, P71_PRV.ca(P71_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))) == P71_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P71_PRV.sa(P71_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))) : P71_D.Digest}:
  P71_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_3(+hl: Nat) -> {P72_PRV.rd(hl, P72_PRV.ca(P72_PRV.rc(hl, P72_PRV.ca(P72_PRV.rc(hl, P72_PRV.ca(P72_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))), FuluHistoricalSummary_d.HistoricalSummary_default())) == P72_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P72_PRV.sa(P72_PRV.sa(P72_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()))) : P72_D.Digest}:
  P72_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_4(+hl: Nat) -> {P73_PRV.rd(hl, P73_PRV.ca(P73_PRV.rc(hl, P73_PRV.ca(P73_PRV.rc(hl, P73_PRV.ca(P73_PRV.rc(hl, P73_PRV.ca(P73_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))), FuluHistoricalSummary_d.HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))) == P73_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P73_PRV.sa(P73_PRV.sa(P73_PRV.sa(P73_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))) : P73_D.Digest}:
  P73_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_5(+hl: Nat) -> {P74_PRV.rd(hl, P74_PRV.ca(P74_PRV.rc(hl, P74_PRV.ca(P74_PRV.rc(hl, P74_PRV.ca(P74_PRV.rc(hl, P74_PRV.ca(P74_PRV.rc(hl, P74_PRV.ca(P74_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))), FuluHistoricalSummary_d.HistoricalSummary_default())), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))), FuluHistoricalSummary_d.HistoricalSummary_default())) == P74_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P74_PRV.sa(P74_PRV.sa(P74_PRV.sa(P74_PRV.sa(P74_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()))) : P74_D.Digest}:
  P74_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_grow_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_1(+hl: Nat) -> {P75_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P75_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()))) == P75_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P75_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()))) : P75_D.Digest}:
  P75_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_2(+hl: Nat) -> {P76_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P76_PRV.sa(P76_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))) == P76_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P76_PRV.sa(P76_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))) : P76_D.Digest}:
  P76_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_3(+hl: Nat) -> {P77_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P77_PRV.sa(P77_PRV.sa(P77_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()))) == P77_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P77_PRV.sa(P77_PRV.sa(P77_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()))) : P77_D.Digest}:
  P77_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_nonempty_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_set_0(+hl: Nat) -> {P78_PRV.rd(hl, P78_PRV.cs(P78_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P78_PRV.sa(P78_PRV.sa(P78_PRV.sa(P78_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))), 0, FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0}))) == P78_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P78_PRV.ss(P78_PRV.sa(P78_PRV.sa(P78_PRV.sa(P78_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), 0, FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))) : P78_D.Digest}:
  P78_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_set_1_3(+hl: Nat) -> {P79_PRV.rd(hl, P79_PRV.cs(P79_PRV.cs(P79_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P79_PRV.sa(P79_PRV.sa(P79_PRV.sa(P79_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))), 1, FuluHistoricalSummary_d.HistoricalSummary_default()), 3, FuluHistoricalSummary_d.HistoricalSummary_default())) == P79_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P79_PRV.ss(P79_PRV.ss(P79_PRV.sa(P79_PRV.sa(P79_PRV.sa(P79_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), 1, FuluHistoricalSummary_d.HistoricalSummary_default()), 3, FuluHistoricalSummary_d.HistoricalSummary_default()))) : P79_D.Digest}:
  P79_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l16777216_HistoricalSummary_cache_set_3(+hl: Nat) -> {P80_PRV.rd(hl, P80_PRV.cs(P80_PRV.rc(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P80_PRV.sa(P80_PRV.sa(P80_PRV.sa(P80_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})))), 3, FuluHistoricalSummary_d.HistoricalSummary_default())) == P80_PRV.rd(hl, Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_cache(P80_PRV.ss(P80_PRV.sa(P80_PRV.sa(P80_PRV.sa(P80_PRV.sa(Fulu_list_HistoricalSummary_16777216_d.l16777216_HistoricalSummary_default(), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), FuluHistoricalSummary_d.HistoricalSummary_default()), FuluHistoricalSummary_d.HistoricalSummary_set_block_summary_root(FuluHistoricalSummary_d.HistoricalSummary_default(), FuluBytes32_d.Bytes32{1, 0, 0, 0, 0, 0, 0, 0})), 3, FuluHistoricalSummary_d.HistoricalSummary_default()))) : P80_D.Digest}:
  P80_PRV.BeaconState_vroot_l16777216_HistoricalSummary_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_1(+hl: Nat) -> {P81_PRV.rd(hl, P81_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default())) == P81_PRV.pd(hl, P81_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default())) : P81_D.Digest}:
  P81_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_2(+hl: Nat) -> {P82_PRV.rd(hl, P82_PRV.ca(P82_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P82_O.U64{1, 0}))) == P82_PRV.pd(hl, P82_PRV.sa(P82_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P82_O.U64{1, 0}))) : P82_D.Digest}:
  P82_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_3(+hl: Nat) -> {P83_PRV.rd(hl, P83_PRV.ca(P83_PRV.ca(P83_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P83_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default())) == P83_PRV.pd(hl, P83_PRV.sa(P83_PRV.sa(P83_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P83_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default())) : P83_D.Digest}:
  P83_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_4(+hl: Nat) -> {P84_PRV.rd(hl, P84_PRV.ca(P84_PRV.ca(P84_PRV.ca(P84_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P84_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P84_O.U64{1, 0}))) == P84_PRV.pd(hl, P84_PRV.sa(P84_PRV.sa(P84_PRV.sa(P84_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P84_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P84_O.U64{1, 0}))) : P84_D.Digest}:
  P84_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_5(+hl: Nat) -> {P85_PRV.rd(hl, P85_PRV.ca(P85_PRV.ca(P85_PRV.ca(P85_PRV.ca(P85_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P85_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P85_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default())) == P85_PRV.rd(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P85_PRV.sa(P85_PRV.sa(P85_PRV.sa(P85_PRV.sa(P85_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P85_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P85_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()))) : P85_D.Digest}:
  P85_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_app_clean(+hl: Nat) -> {P86_PRV.rd(hl, P86_PRV.ca(P86_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P86_PRV.sa(P86_PRV.sa(P86_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P86_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()))), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P86_O.U64{1, 0}))) == P86_PRV.pd(hl, P86_PRV.sa(P86_PRV.sa(P86_PRV.sa(P86_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P86_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P86_O.U64{1, 0}))) : P86_D.Digest}:
  P86_PRV.BeaconState_vroot_l2048_Eth1Data_cache_app_clean(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_dok() -> {(P87_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P87_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P87_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P87_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P87_PRV.BeaconState_vroot_l2048_Eth1Data_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_end() -> {(Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Cached, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cset(P88_PRV.ca(P88_PRV.ca(P88_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P88_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), 3, FuluEth1Data_d.Eth1Data_default())), (Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Cached, Bool, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cset(P88_PRV.ca(P88_PRV.ca(P88_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P88_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), 2, FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P88_O.U64{1, 0}))), (P88_PRV.is_none(Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Cached, Maybe<&1, FuluEth1Data_d.Eth1Data>, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cget(P88_PRV.ca(P88_PRV.ca(P88_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P88_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), 3))), P88_PRV.is_none(Pair.snd(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_Cached, Maybe<&1, FuluEth1Data_d.Eth1Data>, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cget(P88_PRV.ca(P88_PRV.ca(P88_PRV.ca(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default()), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P88_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P88_PRV.BeaconState_vroot_l2048_Eth1Data_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_grow_1(+hl: Nat) -> {P89_PRV.rd(hl, P89_PRV.ca(P89_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default())), FuluEth1Data_d.Eth1Data_default())) == P89_PRV.pd(hl, P89_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default())) : P89_D.Digest}:
  P89_PRV.BeaconState_vroot_l2048_Eth1Data_cache_grow_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_grow_2(+hl: Nat) -> {P90_PRV.rd(hl, P90_PRV.ca(P90_PRV.rc(hl, P90_PRV.ca(P90_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default())), FuluEth1Data_d.Eth1Data_default())), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P90_O.U64{1, 0}))) == P90_PRV.pd(hl, P90_PRV.sa(P90_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P90_O.U64{1, 0}))) : P90_D.Digest}:
  P90_PRV.BeaconState_vroot_l2048_Eth1Data_cache_grow_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_grow_3(+hl: Nat) -> {P91_PRV.rd(hl, P91_PRV.ca(P91_PRV.rc(hl, P91_PRV.ca(P91_PRV.rc(hl, P91_PRV.ca(P91_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default())), FuluEth1Data_d.Eth1Data_default())), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P91_O.U64{1, 0}))), FuluEth1Data_d.Eth1Data_default())) == P91_PRV.pd(hl, P91_PRV.sa(P91_PRV.sa(P91_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P91_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default())) : P91_D.Digest}:
  P91_PRV.BeaconState_vroot_l2048_Eth1Data_cache_grow_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_grow_4(+hl: Nat) -> {P92_PRV.rd(hl, P92_PRV.ca(P92_PRV.rc(hl, P92_PRV.ca(P92_PRV.rc(hl, P92_PRV.ca(P92_PRV.rc(hl, P92_PRV.ca(P92_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default())), FuluEth1Data_d.Eth1Data_default())), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P92_O.U64{1, 0}))), FuluEth1Data_d.Eth1Data_default())), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P92_O.U64{1, 0}))) == P92_PRV.pd(hl, P92_PRV.sa(P92_PRV.sa(P92_PRV.sa(P92_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P92_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P92_O.U64{1, 0}))) : P92_D.Digest}:
  P92_PRV.BeaconState_vroot_l2048_Eth1Data_cache_grow_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_grow_5(+hl: Nat) -> {P93_PRV.rd(hl, P93_PRV.ca(P93_PRV.rc(hl, P93_PRV.ca(P93_PRV.rc(hl, P93_PRV.ca(P93_PRV.rc(hl, P93_PRV.ca(P93_PRV.rc(hl, P93_PRV.ca(P93_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default())), FuluEth1Data_d.Eth1Data_default())), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P93_O.U64{1, 0}))), FuluEth1Data_d.Eth1Data_default())), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P93_O.U64{1, 0}))), FuluEth1Data_d.Eth1Data_default())) == P93_PRV.rd(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P93_PRV.sa(P93_PRV.sa(P93_PRV.sa(P93_PRV.sa(P93_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P93_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P93_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()))) : P93_D.Digest}:
  P93_PRV.BeaconState_vroot_l2048_Eth1Data_cache_grow_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_nonempty_1(+hl: Nat) -> {P94_PRV.rd(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P94_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()))) == P94_PRV.pd(hl, P94_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default())) : P94_D.Digest}:
  P94_PRV.BeaconState_vroot_l2048_Eth1Data_cache_nonempty_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_nonempty_2(+hl: Nat) -> {P95_PRV.rd(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P95_PRV.sa(P95_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P95_O.U64{1, 0})))) == P95_PRV.pd(hl, P95_PRV.sa(P95_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P95_O.U64{1, 0}))) : P95_D.Digest}:
  P95_PRV.BeaconState_vroot_l2048_Eth1Data_cache_nonempty_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_nonempty_3(+hl: Nat) -> {P96_PRV.rd(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P96_PRV.sa(P96_PRV.sa(P96_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P96_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()))) == P96_PRV.pd(hl, P96_PRV.sa(P96_PRV.sa(P96_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P96_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default())) : P96_D.Digest}:
  P96_PRV.BeaconState_vroot_l2048_Eth1Data_cache_nonempty_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_set_0(+hl: Nat) -> {P97_PRV.rd(hl, P97_PRV.cs(P97_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P97_PRV.sa(P97_PRV.sa(P97_PRV.sa(P97_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P97_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P97_O.U64{1, 0})))), 0, FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P97_O.U64{1, 0}))) == P97_PRV.pd(hl, P97_PRV.ss(P97_PRV.sa(P97_PRV.sa(P97_PRV.sa(P97_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P97_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P97_O.U64{1, 0})), 0, FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P97_O.U64{1, 0}))) : P97_D.Digest}:
  P97_PRV.BeaconState_vroot_l2048_Eth1Data_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_set_1_3(+hl: Nat) -> {P98_PRV.rd(hl, P98_PRV.cs(P98_PRV.cs(P98_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P98_PRV.sa(P98_PRV.sa(P98_PRV.sa(P98_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P98_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P98_O.U64{1, 0})))), 1, FuluEth1Data_d.Eth1Data_default()), 3, FuluEth1Data_d.Eth1Data_default())) == P98_PRV.pd(hl, P98_PRV.ss(P98_PRV.ss(P98_PRV.sa(P98_PRV.sa(P98_PRV.sa(P98_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P98_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P98_O.U64{1, 0})), 1, FuluEth1Data_d.Eth1Data_default()), 3, FuluEth1Data_d.Eth1Data_default())) : P98_D.Digest}:
  P98_PRV.BeaconState_vroot_l2048_Eth1Data_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l2048_Eth1Data_cache_set_3(+hl: Nat) -> {P99_PRV.rd(hl, P99_PRV.cs(P99_PRV.rc(hl, Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_cache(P99_PRV.sa(P99_PRV.sa(P99_PRV.sa(P99_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P99_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P99_O.U64{1, 0})))), 3, FuluEth1Data_d.Eth1Data_default())) == P99_PRV.pd(hl, P99_PRV.ss(P99_PRV.sa(P99_PRV.sa(P99_PRV.sa(P99_PRV.sa(Fulu_list_Eth1Data_2048_d.l2048_Eth1Data_default(), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P99_O.U64{1, 0})), FuluEth1Data_d.Eth1Data_default()), FuluEth1Data_d.Eth1Data_set_deposit_count(FuluEth1Data_d.Eth1Data_default(), P99_O.U64{1, 0})), 3, FuluEth1Data_d.Eth1Data_default())) : P99_D.Digest}:
  P99_PRV.BeaconState_vroot_l2048_Eth1Data_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_1(+hl: Nat) -> {P100_PRV.rd(hl, P100_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default())) == P100_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P100_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P100_D.Digest}:
  P100_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_2(+hl: Nat) -> {P101_PRV.rd(hl, P101_PRV.ca(P101_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P101_O.U64{1, 0}))) == P101_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P101_PRV.sa(P101_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P101_O.U64{1, 0})))) : P101_D.Digest}:
  P101_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_3(+hl: Nat) -> {P102_PRV.rd(hl, P102_PRV.ca(P102_PRV.ca(P102_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P102_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default())) == P102_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P102_PRV.sa(P102_PRV.sa(P102_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P102_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P102_D.Digest}:
  P102_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_4(+hl: Nat) -> {P103_PRV.rd(hl, P103_PRV.ca(P103_PRV.ca(P103_PRV.ca(P103_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P103_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P103_O.U64{1, 0}))) == P103_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P103_PRV.sa(P103_PRV.sa(P103_PRV.sa(P103_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P103_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P103_O.U64{1, 0})))) : P103_D.Digest}:
  P103_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_5(+hl: Nat) -> {P104_PRV.rd(hl, P104_PRV.ca(P104_PRV.ca(P104_PRV.ca(P104_PRV.ca(P104_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P104_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P104_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default())) == P104_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P104_PRV.sa(P104_PRV.sa(P104_PRV.sa(P104_PRV.sa(P104_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P104_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P104_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P104_D.Digest}:
  P104_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_clean(+hl: Nat) -> {P105_PRV.rd(hl, P105_PRV.ca(P105_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P105_PRV.sa(P105_PRV.sa(P105_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P105_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()))), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P105_O.U64{1, 0}))) == P105_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P105_PRV.sa(P105_PRV.sa(P105_PRV.sa(P105_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P105_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P105_O.U64{1, 0})))) : P105_D.Digest}:
  P105_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_clean(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_app_fold(+hl: Nat) -> {P106_PRV.rd(hl, P106_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default())) == P106_O.mix_len(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, P106_D.node(hl, Pair.snd(P106_B.Buf, P106_D.Digest, FuluPendingConsolidation_h.PendingConsolidation_root(hl, P106_B.empty(), FuluPendingConsolidation_d.PendingConsolidation_default(), 64)), P106_D.zconst(0n)), P106_D.zconst(1n)), P106_D.zconst(2n)), P106_D.zconst(3n)), P106_D.zconst(4n)), P106_D.zconst(5n)), P106_D.zconst(6n)), P106_D.zconst(7n)), P106_D.zconst(8n)), P106_D.zconst(9n)), P106_D.zconst(10n)), P106_D.zconst(11n)), P106_D.zconst(12n)), P106_D.zconst(13n)), P106_D.zconst(14n)), P106_D.zconst(15n)), P106_D.zconst(16n)), P106_D.zconst(17n)), 1) : P106_D.Digest}:
  P106_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_app_fold(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_dok() -> {(P107_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P107_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P107_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P107_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P107_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_dok()

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_end() -> {(Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Cached, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cset(P108_PRV.ca(P108_PRV.ca(P108_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P108_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), 3, FuluPendingConsolidation_d.PendingConsolidation_default())), (Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Cached, Bool, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cset(P108_PRV.ca(P108_PRV.ca(P108_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P108_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), 2, FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P108_O.U64{1, 0}))), (P108_PRV.is_none(Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Cached, Maybe<&1, FuluPendingConsolidation_d.PendingConsolidation>, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cget(P108_PRV.ca(P108_PRV.ca(P108_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P108_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), 3))), P108_PRV.is_none(Pair.snd(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_Cached, Maybe<&1, FuluPendingConsolidation_d.PendingConsolidation>, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cget(P108_PRV.ca(P108_PRV.ca(P108_PRV.ca(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P108_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P108_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_end()

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_grow_1(+hl: Nat) -> {P109_PRV.rd(hl, P109_PRV.ca(P109_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_default())) == P109_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P109_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P109_D.Digest}:
  P109_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_grow_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_grow_2(+hl: Nat) -> {P110_PRV.rd(hl, P110_PRV.ca(P110_PRV.rc(hl, P110_PRV.ca(P110_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P110_O.U64{1, 0}))) == P110_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P110_PRV.sa(P110_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P110_O.U64{1, 0})))) : P110_D.Digest}:
  P110_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_grow_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_grow_3(+hl: Nat) -> {P111_PRV.rd(hl, P111_PRV.ca(P111_PRV.rc(hl, P111_PRV.ca(P111_PRV.rc(hl, P111_PRV.ca(P111_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P111_O.U64{1, 0}))), FuluPendingConsolidation_d.PendingConsolidation_default())) == P111_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P111_PRV.sa(P111_PRV.sa(P111_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P111_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P111_D.Digest}:
  P111_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_grow_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_grow_4(+hl: Nat) -> {P112_PRV.rd(hl, P112_PRV.ca(P112_PRV.rc(hl, P112_PRV.ca(P112_PRV.rc(hl, P112_PRV.ca(P112_PRV.rc(hl, P112_PRV.ca(P112_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P112_O.U64{1, 0}))), FuluPendingConsolidation_d.PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P112_O.U64{1, 0}))) == P112_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P112_PRV.sa(P112_PRV.sa(P112_PRV.sa(P112_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P112_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P112_O.U64{1, 0})))) : P112_D.Digest}:
  P112_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_grow_4(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_grow_5(+hl: Nat) -> {P113_PRV.rd(hl, P113_PRV.ca(P113_PRV.rc(hl, P113_PRV.ca(P113_PRV.rc(hl, P113_PRV.ca(P113_PRV.rc(hl, P113_PRV.ca(P113_PRV.rc(hl, P113_PRV.ca(P113_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P113_O.U64{1, 0}))), FuluPendingConsolidation_d.PendingConsolidation_default())), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P113_O.U64{1, 0}))), FuluPendingConsolidation_d.PendingConsolidation_default())) == P113_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P113_PRV.sa(P113_PRV.sa(P113_PRV.sa(P113_PRV.sa(P113_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P113_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P113_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P113_D.Digest}:
  P113_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_grow_5(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_1(+hl: Nat) -> {P114_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P114_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()))) == P114_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P114_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P114_D.Digest}:
  P114_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_1(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_2(+hl: Nat) -> {P115_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P115_PRV.sa(P115_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P115_O.U64{1, 0})))) == P115_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P115_PRV.sa(P115_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P115_O.U64{1, 0})))) : P115_D.Digest}:
  P115_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_2(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_3(+hl: Nat) -> {P116_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P116_PRV.sa(P116_PRV.sa(P116_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P116_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()))) == P116_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P116_PRV.sa(P116_PRV.sa(P116_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P116_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()))) : P116_D.Digest}:
  P116_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_nonempty_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_set_0(+hl: Nat) -> {P117_PRV.rd(hl, P117_PRV.cs(P117_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P117_PRV.sa(P117_PRV.sa(P117_PRV.sa(P117_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P117_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P117_O.U64{1, 0})))), 0, FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P117_O.U64{1, 0}))) == P117_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P117_PRV.ss(P117_PRV.sa(P117_PRV.sa(P117_PRV.sa(P117_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P117_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P117_O.U64{1, 0})), 0, FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P117_O.U64{1, 0})))) : P117_D.Digest}:
  P117_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_set_0(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_set_1_3(+hl: Nat) -> {P118_PRV.rd(hl, P118_PRV.cs(P118_PRV.cs(P118_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P118_PRV.sa(P118_PRV.sa(P118_PRV.sa(P118_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P118_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P118_O.U64{1, 0})))), 1, FuluPendingConsolidation_d.PendingConsolidation_default()), 3, FuluPendingConsolidation_d.PendingConsolidation_default())) == P118_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P118_PRV.ss(P118_PRV.ss(P118_PRV.sa(P118_PRV.sa(P118_PRV.sa(P118_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P118_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P118_O.U64{1, 0})), 1, FuluPendingConsolidation_d.PendingConsolidation_default()), 3, FuluPendingConsolidation_d.PendingConsolidation_default()))) : P118_D.Digest}:
  P118_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_set_1_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l262144_PendingConsolidation_cache_set_3(+hl: Nat) -> {P119_PRV.rd(hl, P119_PRV.cs(P119_PRV.rc(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P119_PRV.sa(P119_PRV.sa(P119_PRV.sa(P119_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P119_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P119_O.U64{1, 0})))), 3, FuluPendingConsolidation_d.PendingConsolidation_default())) == P119_PRV.rd(hl, Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_cache(P119_PRV.ss(P119_PRV.sa(P119_PRV.sa(P119_PRV.sa(P119_PRV.sa(Fulu_list_PendingConsolidation_262144_d.l262144_PendingConsolidation_default(), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P119_O.U64{1, 0})), FuluPendingConsolidation_d.PendingConsolidation_default()), FuluPendingConsolidation_d.PendingConsolidation_set_source_index(FuluPendingConsolidation_d.PendingConsolidation_default(), P119_O.U64{1, 0})), 3, FuluPendingConsolidation_d.PendingConsolidation_default()))) : P119_D.Digest}:
  P119_PRV.BeaconState_vroot_l262144_PendingConsolidation_cache_set_3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j1_n1_b1(+hl: Nat) -> {Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 48641), 1}, 8, 0))) == Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1}, 8, 0))) : P120_D.Digest}:
  P120_PRV.BeaconState_vroot_l1099511627776_u8_j1_n1_b1(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j1_n1_b2(+hl: Nat) -> {Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 12451841), 1}, 8, 0))) == Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1}, 8, 0))) : P120_D.Digest}:
  P120_PRV.BeaconState_vroot_l1099511627776_u8_j1_n1_b2(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j1_n1_b3(+hl: Nat) -> {Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187671041), 1}, 8, 0))) == Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1}, 8, 0))) : P120_D.Digest}:
  P120_PRV.BeaconState_vroot_l1099511627776_u8_j1_n1_b3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j1_n2_b2(+hl: Nat) -> {Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 12452353), 2}, 8, 0))) == Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 513), 2}, 8, 0))) : P120_D.Digest}:
  P120_PRV.BeaconState_vroot_l1099511627776_u8_j1_n2_b2(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j1_n2_b3(+hl: Nat) -> {Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187671553), 2}, 8, 0))) == Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 513), 2}, 8, 0))) : P120_D.Digest}:
  P120_PRV.BeaconState_vroot_l1099511627776_u8_j1_n2_b3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j1_n3_b3(+hl: Nat) -> {Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187868161), 3}, 8, 0))) == Pair.snd(P120_O.Words, P120_D.Digest, Pair.snd(P120_B.Buf, P120_O.Words & P120_D.Digest, P120_O.words_root(hl, P120_B.empty(), P120_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 197121), 3}, 8, 0))) : P120_D.Digest}:
  P120_PRV.BeaconState_vroot_l1099511627776_u8_j1_n3_b3(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u64_j_past(+hl: Nat) -> {Pair.snd(P121_O.Words, P121_D.Digest, Pair.snd(P121_B.Buf, P121_O.Words & P121_D.Digest, P121_O.words_root(hl, P121_B.empty(), P121_O.Words{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 67305985), 1, 134678021), 2, 3735928559), 7, 286331153), 8}, 8, 0))) == Pair.snd(P121_O.Words, P121_D.Digest, Pair.snd(P121_B.Buf, P121_O.Words & P121_D.Digest, P121_O.words_root(hl, P121_B.empty(), P121_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 67305985), 1, 134678021), 8}, 8, 0))) : P121_D.Digest}:
  P121_PRV.BeaconState_vroot_l1099511627776_u64_j_past(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u64_j_tight(+hl: Nat) -> {Pair.snd(P121_O.Words, P121_D.Digest, Pair.snd(P121_B.Buf, P121_O.Words & P121_D.Digest, P121_O.words_root(hl, P121_B.empty(), P121_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 67305985), 1, 134678021), 8}, 8, 0))) == Pair.snd(P121_O.Words, P121_D.Digest, Pair.snd(P121_B.Buf, P121_O.Words & P121_D.Digest, P121_O.words_root(hl, P121_B.empty(), P121_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 67305985), 1, 134678021), 8}, 8, 0))) : P121_D.Digest}:
  P121_PRV.BeaconState_vroot_l1099511627776_u64_j_tight(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j_past(+hl: Nat) -> {Pair.snd(P122_O.Words, P122_D.Digest, Pair.snd(P122_B.Buf, P122_O.Words & P122_D.Digest, P122_O.words_root(hl, P122_B.empty(), P122_O.Words{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1, 3735928559), 7, 286331153), 1}, 8, 0))) == Pair.snd(P122_O.Words, P122_D.Digest, Pair.snd(P122_B.Buf, P122_O.Words & P122_D.Digest, P122_O.words_root(hl, P122_B.empty(), P122_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1}, 8, 0))) : P122_D.Digest}:
  P122_PRV.BeaconState_vroot_l1099511627776_u8_j_past(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j_tail(+hl: Nat) -> {Pair.snd(P122_O.Words, P122_D.Digest, Pair.snd(P122_B.Buf, P122_O.Words & P122_D.Digest, P122_O.words_root(hl, P122_B.empty(), P122_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3735928321), 1}, 8, 0))) == Pair.snd(P122_O.Words, P122_D.Digest, Pair.snd(P122_B.Buf, P122_O.Words & P122_D.Digest, P122_O.words_root(hl, P122_B.empty(), P122_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1}, 8, 0))) : P122_D.Digest}:
  P122_PRV.BeaconState_vroot_l1099511627776_u8_j_tail(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j_tight(+hl: Nat) -> {Pair.snd(P122_O.Words, P122_D.Digest, Pair.snd(P122_B.Buf, P122_O.Words & P122_D.Digest, P122_O.words_root(hl, P122_B.empty(), P122_O.Words{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 1}, 8, 0))) == Pair.snd(P122_O.Words, P122_D.Digest, Pair.snd(P122_B.Buf, P122_O.Words & P122_D.Digest, P122_O.words_root(hl, P122_B.empty(), P122_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1}, 8, 0))) : P122_D.Digest}:
  P122_PRV.BeaconState_vroot_l1099511627776_u8_j_tight(hl)

def FuluBeaconState__root__BeaconState_vroot_l1099511627776_u8_j_tight_tail(+hl: Nat) -> {Pair.snd(P122_O.Words, P122_D.Digest, Pair.snd(P122_B.Buf, P122_O.Words & P122_D.Digest, P122_O.words_root(hl, P122_B.empty(), P122_O.Words{Array.set(U32, Array.new(U32, 0n, 0), 0, 3735928321), 1}, 8, 0))) == Pair.snd(P122_O.Words, P122_D.Digest, Pair.snd(P122_B.Buf, P122_O.Words & P122_D.Digest, P122_O.words_root(hl, P122_B.empty(), P122_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1}, 8, 0))) : P122_D.Digest}:
  P122_PRV.BeaconState_vroot_l1099511627776_u8_j_tight_tail(hl)

