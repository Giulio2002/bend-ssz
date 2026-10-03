import Base
import ../compact/found_generated.bend as P0_F
import ../../src/buffer.bend as P0_B
import ../../src/digest.bend as P0_D
import ../../src/obj.bend as P0_O
import ../../types/FuluDepositRequest_def_generated.bend as FuluDepositRequest_d
import ../../types/FuluWithdrawalRequest_def_generated.bend as FuluWithdrawalRequest_d
import ../../types/Fulu_list_DepositRequest_8192_def_generated.bend as Fulu_list_DepositRequest_8192_d
import ../../types/Fulu_list_WithdrawalRequest_16_def_generated.bend as Fulu_list_WithdrawalRequest_16_d
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
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_dok_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/digest.bend as P6_D
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_end_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/digest.bend as P7_D
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_limit_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/digest.bend as P8_D
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_0_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/digest.bend as P9_D
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_1_3_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/digest.bend as P10_D
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_3_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/digest.bend as P11_D
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_1_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/digest.bend as P12_D
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_2_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/digest.bend as P13_D
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_3_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/digest.bend as P14_D
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_app_4_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/digest.bend as P15_D
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_dok_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/digest.bend as P16_D
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_end_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/digest.bend as P17_D
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_set_0_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/digest.bend as P18_D
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_set_1_3_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/digest.bend as P19_D
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_ExecutionRequests_vroot_l8192_DepositRequest_cache_set_3_generated.bend as P19_PRV

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

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_dok() -> {(P5_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P5_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P5_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P5_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P5_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_dok()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_end() -> {(Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Bool, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cset(P6_PRV.ca(P6_PRV.ca(P6_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())), (Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Bool, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cset(P6_PRV.ca(P6_PRV.ca(P6_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), 2, FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0}))), (P6_PRV.is_none(Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Maybe<&1, FuluWithdrawalRequest_d.WithdrawalRequest>, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cget(P6_PRV.ca(P6_PRV.ca(P6_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), 3))), P6_PRV.is_none(Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Maybe<&1, FuluWithdrawalRequest_d.WithdrawalRequest>, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cget(P6_PRV.ca(P6_PRV.ca(P6_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P6_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P6_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_end()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_limit() -> {(Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Bool, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_capp(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default())), Pair.snd(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Cached, Bool, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_capp(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(P7_PRV.ca(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P7_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()))) == (True{}, False{}) : Bool & Bool}:
  P7_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_limit()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_0(+hl: Nat) -> {P8_PRV.rd(hl, P8_PRV.cs(P8_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P8_PRV.sa(P8_PRV.sa(P8_PRV.sa(P8_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0})))), 0, FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0}))) == P8_PRV.pd(hl, P8_PRV.ss(P8_PRV.sa(P8_PRV.sa(P8_PRV.sa(P8_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0})), 0, FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P8_O.U64{1, 0}))) : P8_D.Digest}:
  P8_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_0(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_1_3(+hl: Nat) -> {P9_PRV.rd(hl, P9_PRV.cs(P9_PRV.cs(P9_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P9_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P9_O.U64{1, 0})))), 1, FuluWithdrawalRequest_d.WithdrawalRequest_default()), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P9_PRV.pd(hl, P9_PRV.ss(P9_PRV.ss(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P9_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P9_O.U64{1, 0})), 1, FuluWithdrawalRequest_d.WithdrawalRequest_default()), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P9_D.Digest}:
  P9_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_1_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_3(+hl: Nat) -> {P10_PRV.rd(hl, P10_PRV.cs(P10_PRV.rc(hl, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_cache(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P10_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P10_O.U64{1, 0})))), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())) == P10_PRV.pd(hl, P10_PRV.ss(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_default(), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P10_O.U64{1, 0})), FuluWithdrawalRequest_d.WithdrawalRequest_default()), FuluWithdrawalRequest_d.WithdrawalRequest_set_amount(FuluWithdrawalRequest_d.WithdrawalRequest_default(), P10_O.U64{1, 0})), 3, FuluWithdrawalRequest_d.WithdrawalRequest_default())) : P10_D.Digest}:
  P10_PRV.ExecutionRequests_vroot_l16_WithdrawalRequest_cache_set_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_1(+hl: Nat) -> {P11_PRV.rd(hl, P11_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default())) == P11_PRV.pd(hl, P11_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default())) : P11_D.Digest}:
  P11_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_1(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_2(+hl: Nat) -> {P12_PRV.rd(hl, P12_PRV.ca(P12_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P12_O.U64{1, 0}))) == P12_PRV.pd(hl, P12_PRV.sa(P12_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P12_O.U64{1, 0}))) : P12_D.Digest}:
  P12_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_2(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_3(+hl: Nat) -> {P13_PRV.rd(hl, P13_PRV.ca(P13_PRV.ca(P13_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P13_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default())) == P13_PRV.pd(hl, P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P13_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default())) : P13_D.Digest}:
  P13_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_app_4(+hl: Nat) -> {P14_PRV.rd(hl, P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(P14_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P14_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P14_O.U64{1, 0}))) == P14_PRV.pd(hl, P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P14_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P14_O.U64{1, 0}))) : P14_D.Digest}:
  P14_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_app_4(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_dok() -> {(P15_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P15_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P15_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P15_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P15_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_dok()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_end() -> {(Pair.snd(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Cached, Bool, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cset(P16_PRV.ca(P16_PRV.ca(P16_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P16_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), 3, FuluDepositRequest_d.DepositRequest_default())), (Pair.snd(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Cached, Bool, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cset(P16_PRV.ca(P16_PRV.ca(P16_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P16_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), 2, FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P16_O.U64{1, 0}))), (P16_PRV.is_none(Pair.snd(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Cached, Maybe<&1, FuluDepositRequest_d.DepositRequest>, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cget(P16_PRV.ca(P16_PRV.ca(P16_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P16_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), 3))), P16_PRV.is_none(Pair.snd(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Cached, Maybe<&1, FuluDepositRequest_d.DepositRequest>, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cget(P16_PRV.ca(P16_PRV.ca(P16_PRV.ca(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default()), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P16_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P16_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_end()

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_set_0(+hl: Nat) -> {P17_PRV.rd(hl, P17_PRV.cs(P17_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P17_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P17_O.U64{1, 0})))), 0, FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P17_O.U64{1, 0}))) == P17_PRV.pd(hl, P17_PRV.ss(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P17_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P17_O.U64{1, 0})), 0, FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P17_O.U64{1, 0}))) : P17_D.Digest}:
  P17_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_set_0(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_set_1_3(+hl: Nat) -> {P18_PRV.rd(hl, P18_PRV.cs(P18_PRV.cs(P18_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P18_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P18_O.U64{1, 0})))), 1, FuluDepositRequest_d.DepositRequest_default()), 3, FuluDepositRequest_d.DepositRequest_default())) == P18_PRV.pd(hl, P18_PRV.ss(P18_PRV.ss(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P18_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P18_O.U64{1, 0})), 1, FuluDepositRequest_d.DepositRequest_default()), 3, FuluDepositRequest_d.DepositRequest_default())) : P18_D.Digest}:
  P18_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_set_1_3(hl)

def FuluExecutionRequests__root__ExecutionRequests_vroot_l8192_DepositRequest_cache_set_3(+hl: Nat) -> {P19_PRV.rd(hl, P19_PRV.cs(P19_PRV.rc(hl, Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_cache(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P19_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P19_O.U64{1, 0})))), 3, FuluDepositRequest_d.DepositRequest_default())) == P19_PRV.pd(hl, P19_PRV.ss(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_default(), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P19_O.U64{1, 0})), FuluDepositRequest_d.DepositRequest_default()), FuluDepositRequest_d.DepositRequest_set_amount(FuluDepositRequest_d.DepositRequest_default(), P19_O.U64{1, 0})), 3, FuluDepositRequest_d.DepositRequest_default())) : P19_D.Digest}:
  P19_PRV.ExecutionRequests_vroot_l8192_DepositRequest_cache_set_3(hl)

