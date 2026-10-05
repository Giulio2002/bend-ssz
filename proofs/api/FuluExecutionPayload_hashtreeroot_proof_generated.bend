import Base
import ../compact/found_generated.bend as P0_F
import ../../src/buffer.bend as P0_B
import ../../src/digest.bend as P0_D
import ../../src/obj.bend as P0_O
import ../../types/FuluTransaction_hashtreeroot_generated.bend as FuluTransaction_h
import ../../types/FuluWithdrawal_def_generated.bend as FuluWithdrawal_d
import ../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as Fulu_list_bytelist_1073741824_1048576_d
import ../../types/Fulu_list_Withdrawal_16_def_generated.bend as Fulu_list_Withdrawal_16_d
import ../../types/FuluExecutionPayload_def_generated.bend as FuluExecutionPayload_d
import ../../types/FuluExecutionPayload_hashtreeroot_generated.bend as FuluExecutionPayload_h
import ../../types/schema.bend as P0_S
import ../../types/primitive.bend as P0_P
import ../obj/cform.bend as P0_CF
import ../obj/amap.bend as P0_AM
import ../../spec/root_relation.bend as P0_RR
import ../../spec/fulu_schemas.bend as P0_Spec
import ../obj/schema_shapes_generated.bend as P0_SH
import ../obj/dk.bend as P0_DK
import ../obj/mtree_defs.bend as P0_MD
import ../obj/words_obj_light.bend as P0_WO
import ../obj/list_obj_light.bend as P0_LO
import ../obj/obj_support.bend as P0_OS
import ../obj/xlist_support.bend as P0_XS
import ../obj/mtree_run.bend as P0_MR
import ../obj/words_cap.bend as P0_WC
import ../../spec/codec.bend as P0_Codec
import ../../spec/limits.bend as P0_Lim
import ../../spec/bit_root.bend as P0_Mix
import ../../spec/nat_bytes.bend as P0_Len
import ../../spec/byte_list.bend as P0_BL
import ../obj/root_types_light_generated.bend as P0_RT_L
import ../obj/lim_bl.bend as P0_LBL
import ../obj/root_ExecutionPayload_generated.bend as P0_PRV
import ../../src/buffer.bend as P1_B
import ../../src/digest.bend as P1_D
import ../../src/obj.bend as P1_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_1_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/digest.bend as P2_D
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_2_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/digest.bend as P3_D
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_3_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/digest.bend as P4_D
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_4_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/digest.bend as P5_D
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_5_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/digest.bend as P6_D
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_clean_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/digest.bend as P7_D
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_fold_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/digest.bend as P8_D
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_dok_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/digest.bend as P9_D
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_end_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/digest.bend as P10_D
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_1_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/digest.bend as P11_D
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_2_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/digest.bend as P12_D
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_3_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/digest.bend as P13_D
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_4_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/digest.bend as P14_D
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_5_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/digest.bend as P15_D
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_1_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/digest.bend as P16_D
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_2_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/digest.bend as P17_D
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_3_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/digest.bend as P18_D
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_0_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/digest.bend as P19_D
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_1_3_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/digest.bend as P20_D
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_3_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/digest.bend as P21_D
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_0_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/digest.bend as P22_D
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_2_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/digest.bend as P23_D
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_1_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/digest.bend as P24_D
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_2_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/digest.bend as P25_D
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_3_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/digest.bend as P26_D
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_4_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/digest.bend as P27_D
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_5_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/digest.bend as P28_D
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_clean_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/digest.bend as P29_D
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_dok_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/digest.bend as P30_D
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_end_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/digest.bend as P31_D
import ../../src/obj.bend as P31_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_grow_1_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/digest.bend as P32_D
import ../../src/obj.bend as P32_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_grow_2_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/digest.bend as P33_D
import ../../src/obj.bend as P33_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_grow_3_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/digest.bend as P34_D
import ../../src/obj.bend as P34_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_grow_4_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/digest.bend as P35_D
import ../../src/obj.bend as P35_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_grow_5_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/digest.bend as P36_D
import ../../src/obj.bend as P36_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_limit_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/digest.bend as P37_D
import ../../src/obj.bend as P37_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_1_generated.bend as P37_PRV
import ../../src/buffer.bend as P38_B
import ../../src/digest.bend as P38_D
import ../../src/obj.bend as P38_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_2_generated.bend as P38_PRV
import ../../src/buffer.bend as P39_B
import ../../src/digest.bend as P39_D
import ../../src/obj.bend as P39_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_3_generated.bend as P39_PRV
import ../../src/buffer.bend as P40_B
import ../../src/digest.bend as P40_D
import ../../src/obj.bend as P40_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_set_0_generated.bend as P40_PRV
import ../../src/buffer.bend as P41_B
import ../../src/digest.bend as P41_D
import ../../src/obj.bend as P41_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_set_1_3_generated.bend as P41_PRV
import ../../src/buffer.bend as P42_B
import ../../src/digest.bend as P42_D
import ../../src/obj.bend as P42_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_set_3_generated.bend as P42_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluExecutionPayload (ExecutionPayload): its hashtreeroot laws in the object API's terms, each discharged by its proving law.

def FuluExecutionPayload__root__ExecutionPayload_root_correct(-h: P0_B.Buf, -o: FuluExecutionPayload_d.ExecutionPayload, +s: P0_S.Schema, +es: {s == P0_Spec.ExecutionPayload() : P0_S.Schema}, +rep: P0_RT_L.rep_ExecutionPayload(o, s)) -> P0_RR.roots(P0_RT_L.v_ExecutionPayload(o), s, [P0_D.bytes(Pair.snd(FuluExecutionPayload_d.ExecutionPayload, P0_D.Digest, Pair.snd(P0_B.Buf, FuluExecutionPayload_d.ExecutionPayload & P0_D.Digest, FuluExecutionPayload_h.ExecutionPayload_hash_tree_root(h, o))))]):
  P0_PRV.ExecutionPayload_root_correct(h, o, s, es, rep)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_1(+hl: Nat) -> {P1_PRV.rd(hl, P1_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P1_O.words_new(0))) == P1_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P1_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P1_O.words_new(0)))) : P1_D.Digest}:
  P1_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_1(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_2(+hl: Nat) -> {P2_PRV.rd(hl, P2_PRV.ca(P2_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P2_O.words_new(0)), P2_O.words_new(0))) == P2_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P2_PRV.sa(P2_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P2_O.words_new(0)), P2_O.words_new(0)))) : P2_D.Digest}:
  P2_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_3(+hl: Nat) -> {P3_PRV.rd(hl, P3_PRV.ca(P3_PRV.ca(P3_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P3_O.words_new(0)), P3_O.words_new(0)), P3_O.words_new(0))) == P3_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P3_PRV.sa(P3_PRV.sa(P3_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P3_O.words_new(0)), P3_O.words_new(0)), P3_O.words_new(0)))) : P3_D.Digest}:
  P3_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_4(+hl: Nat) -> {P4_PRV.rd(hl, P4_PRV.ca(P4_PRV.ca(P4_PRV.ca(P4_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P4_O.words_new(0)), P4_O.words_new(0)), P4_O.words_new(0)), P4_O.words_new(0))) == P4_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P4_PRV.sa(P4_PRV.sa(P4_PRV.sa(P4_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P4_O.words_new(0)), P4_O.words_new(0)), P4_O.words_new(0)), P4_O.words_new(0)))) : P4_D.Digest}:
  P4_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_4(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_5(+hl: Nat) -> {P5_PRV.rd(hl, P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(P5_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0))) == P5_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0)))) : P5_D.Digest}:
  P5_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_5(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_clean(+hl: Nat) -> {P6_PRV.rd(hl, P6_PRV.ca(P6_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P6_O.words_new(0)), P6_O.words_new(0)), P6_O.words_new(0)))), P6_O.words_new(0))) == P6_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(P6_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P6_O.words_new(0)), P6_O.words_new(0)), P6_O.words_new(0)), P6_O.words_new(0)))) : P6_D.Digest}:
  P6_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_clean(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_fold(+hl: Nat) -> {P7_PRV.rd(hl, P7_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P7_O.words_new(0))) == P7_O.mix_len(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, P7_D.node(hl, Pair.snd(P7_O.Boxed<P7_O.Words>, P7_D.Digest, Pair.snd(P7_B.Buf, P7_O.Boxed<P7_O.Words> & P7_D.Digest, FuluTransaction_h.bl1073741824_bx_root(hl, P7_B.empty(), P7_O.BSome{P7_O.words_new(0), P7_O.BNone{}}, 64))), P7_D.zconst(0n)), P7_D.zconst(1n)), P7_D.zconst(2n)), P7_D.zconst(3n)), P7_D.zconst(4n)), P7_D.zconst(5n)), P7_D.zconst(6n)), P7_D.zconst(7n)), P7_D.zconst(8n)), P7_D.zconst(9n)), P7_D.zconst(10n)), P7_D.zconst(11n)), P7_D.zconst(12n)), P7_D.zconst(13n)), P7_D.zconst(14n)), P7_D.zconst(15n)), P7_D.zconst(16n)), P7_D.zconst(17n)), P7_D.zconst(18n)), P7_D.zconst(19n)), 1) : P7_D.Digest}:
  P7_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_fold(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_dok() -> {(P8_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P8_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P8_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P8_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P8_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_dok()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_end() -> {(Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Bool, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cset(P9_PRV.ca(P9_PRV.ca(P9_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P9_O.words_new(0)), P9_O.words_new(0)), P9_O.words_new(0)), 3, P9_O.words_new(0))), (Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Bool, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cset(P9_PRV.ca(P9_PRV.ca(P9_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P9_O.words_new(0)), P9_O.words_new(0)), P9_O.words_new(0)), 2, P9_O.words_new(0))), (P9_PRV.is_none(Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Maybe<&1, P9_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_ctake(P9_PRV.ca(P9_PRV.ca(P9_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P9_O.words_new(0)), P9_O.words_new(0)), P9_O.words_new(0)), 3))), P9_PRV.is_none(Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Maybe<&1, P9_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_ctake(P9_PRV.ca(P9_PRV.ca(P9_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P9_O.words_new(0)), P9_O.words_new(0)), P9_O.words_new(0)), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P9_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_end()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_1(+hl: Nat) -> {P10_PRV.rd(hl, P10_PRV.ca(P10_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default())), P10_O.words_new(0))) == P10_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P10_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P10_O.words_new(0)))) : P10_D.Digest}:
  P10_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_1(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_2(+hl: Nat) -> {P11_PRV.rd(hl, P11_PRV.ca(P11_PRV.rc(hl, P11_PRV.ca(P11_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default())), P11_O.words_new(0))), P11_O.words_new(0))) == P11_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P11_PRV.sa(P11_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P11_O.words_new(0)), P11_O.words_new(0)))) : P11_D.Digest}:
  P11_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_3(+hl: Nat) -> {P12_PRV.rd(hl, P12_PRV.ca(P12_PRV.rc(hl, P12_PRV.ca(P12_PRV.rc(hl, P12_PRV.ca(P12_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default())), P12_O.words_new(0))), P12_O.words_new(0))), P12_O.words_new(0))) == P12_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P12_PRV.sa(P12_PRV.sa(P12_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P12_O.words_new(0)), P12_O.words_new(0)), P12_O.words_new(0)))) : P12_D.Digest}:
  P12_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_4(+hl: Nat) -> {P13_PRV.rd(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, P13_PRV.ca(P13_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default())), P13_O.words_new(0))), P13_O.words_new(0))), P13_O.words_new(0))), P13_O.words_new(0))) == P13_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P13_O.words_new(0)), P13_O.words_new(0)), P13_O.words_new(0)), P13_O.words_new(0)))) : P13_D.Digest}:
  P13_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_4(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_5(+hl: Nat) -> {P14_PRV.rd(hl, P14_PRV.ca(P14_PRV.rc(hl, P14_PRV.ca(P14_PRV.rc(hl, P14_PRV.ca(P14_PRV.rc(hl, P14_PRV.ca(P14_PRV.rc(hl, P14_PRV.ca(P14_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default())), P14_O.words_new(0))), P14_O.words_new(0))), P14_O.words_new(0))), P14_O.words_new(0))), P14_O.words_new(0))) == P14_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(P14_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P14_O.words_new(0)), P14_O.words_new(0)), P14_O.words_new(0)), P14_O.words_new(0)), P14_O.words_new(0)))) : P14_D.Digest}:
  P14_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_grow_5(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_1(+hl: Nat) -> {P15_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P15_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P15_O.words_new(0)))) == P15_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P15_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P15_O.words_new(0)))) : P15_D.Digest}:
  P15_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_1(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_2(+hl: Nat) -> {P16_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P16_PRV.sa(P16_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P16_O.words_new(0)), P16_O.words_new(0)))) == P16_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P16_PRV.sa(P16_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P16_O.words_new(0)), P16_O.words_new(0)))) : P16_D.Digest}:
  P16_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_3(+hl: Nat) -> {P17_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P17_O.words_new(0)), P17_O.words_new(0)), P17_O.words_new(0)))) == P17_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P17_O.words_new(0)), P17_O.words_new(0)), P17_O.words_new(0)))) : P17_D.Digest}:
  P17_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_nonempty_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_0(+hl: Nat) -> {P18_PRV.win(P18_PRV.cs(P18_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P18_O.words_new(0)), P18_O.words_new(0)), P18_O.words_new(0)), P18_O.words_new(0)))), 0, P18_O.words_new(0))) == (0, 0) : U32 & U32}:
  P18_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_0(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_1_3(+hl: Nat) -> {P19_PRV.win(P19_PRV.cs(P19_PRV.cs(P19_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(P19_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P19_O.words_new(0)), P19_O.words_new(0)), P19_O.words_new(0)), P19_O.words_new(0)))), 1, P19_O.words_new(0)), 3, P19_O.words_new(0))) == (1, 3) : U32 & U32}:
  P19_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_1_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_3(+hl: Nat) -> {P20_PRV.win(P20_PRV.cs(P20_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(P20_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P20_O.words_new(0)), P20_O.words_new(0)), P20_O.words_new(0)), P20_O.words_new(0)))), 3, P20_O.words_new(0))) == (3, 3) : U32 & U32}:
  P20_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_0(+hl: Nat) -> {P21_PRV.rd(hl, Pair.fst(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Maybe<&1, P21_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_ctake(P21_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P21_PRV.sa(P21_PRV.sa(P21_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P21_O.words_new(0)), P21_O.words_new(0)), P21_O.words_new(0)))), 0))) == P21_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Pair.fst(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq, Maybe<&1, P21_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_take(P21_PRV.sa(P21_PRV.sa(P21_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P21_O.words_new(0)), P21_O.words_new(0)), P21_O.words_new(0)), 0)))) : P21_D.Digest}:
  P21_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_0(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_2(+hl: Nat) -> {P22_PRV.rd(hl, Pair.fst(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Maybe<&1, P22_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_ctake(P22_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P22_PRV.sa(P22_PRV.sa(P22_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P22_O.words_new(0)), P22_O.words_new(0)), P22_O.words_new(0)))), 2))) == P22_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Pair.fst(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq, Maybe<&1, P22_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_take(P22_PRV.sa(P22_PRV.sa(P22_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P22_O.words_new(0)), P22_O.words_new(0)), P22_O.words_new(0)), 2)))) : P22_D.Digest}:
  P22_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_1(+hl: Nat) -> {P23_PRV.rd(hl, P23_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default())) == P23_PRV.pd(hl, P23_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default())) : P23_D.Digest}:
  P23_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_1(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_2(+hl: Nat) -> {P24_PRV.rd(hl, P24_PRV.ca(P24_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P24_O.U64{1, 0}))) == P24_PRV.pd(hl, P24_PRV.sa(P24_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P24_O.U64{1, 0}))) : P24_D.Digest}:
  P24_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_3(+hl: Nat) -> {P25_PRV.rd(hl, P25_PRV.ca(P25_PRV.ca(P25_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P25_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default())) == P25_PRV.pd(hl, P25_PRV.sa(P25_PRV.sa(P25_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P25_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default())) : P25_D.Digest}:
  P25_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_4(+hl: Nat) -> {P26_PRV.rd(hl, P26_PRV.ca(P26_PRV.ca(P26_PRV.ca(P26_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P26_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P26_O.U64{1, 0}))) == P26_PRV.pd(hl, P26_PRV.sa(P26_PRV.sa(P26_PRV.sa(P26_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P26_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P26_O.U64{1, 0}))) : P26_D.Digest}:
  P26_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_4(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_5(+hl: Nat) -> {P27_PRV.rd(hl, P27_PRV.ca(P27_PRV.ca(P27_PRV.ca(P27_PRV.ca(P27_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P27_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P27_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default())) == P27_PRV.rd(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P27_PRV.sa(P27_PRV.sa(P27_PRV.sa(P27_PRV.sa(P27_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P27_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P27_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()))) : P27_D.Digest}:
  P27_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_5(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_clean(+hl: Nat) -> {P28_PRV.rd(hl, P28_PRV.ca(P28_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P28_PRV.sa(P28_PRV.sa(P28_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P28_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()))), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P28_O.U64{1, 0}))) == P28_PRV.pd(hl, P28_PRV.sa(P28_PRV.sa(P28_PRV.sa(P28_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P28_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P28_O.U64{1, 0}))) : P28_D.Digest}:
  P28_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_clean(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_dok() -> {(P29_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P29_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P29_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P29_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P29_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_dok()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_end() -> {(Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Bool, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cset(P30_PRV.ca(P30_PRV.ca(P30_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P30_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), 3, FuluWithdrawal_d.Withdrawal_default())), (Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Bool, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cset(P30_PRV.ca(P30_PRV.ca(P30_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P30_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), 2, FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P30_O.U64{1, 0}))), (P30_PRV.is_none(Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Maybe<&1, FuluWithdrawal_d.Withdrawal>, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cget(P30_PRV.ca(P30_PRV.ca(P30_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P30_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), 3))), P30_PRV.is_none(Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Maybe<&1, FuluWithdrawal_d.Withdrawal>, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cget(P30_PRV.ca(P30_PRV.ca(P30_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P30_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P30_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_end()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_grow_1(+hl: Nat) -> {P31_PRV.rd(hl, P31_PRV.ca(P31_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default())), FuluWithdrawal_d.Withdrawal_default())) == P31_PRV.pd(hl, P31_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default())) : P31_D.Digest}:
  P31_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_grow_1(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_grow_2(+hl: Nat) -> {P32_PRV.rd(hl, P32_PRV.ca(P32_PRV.rc(hl, P32_PRV.ca(P32_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default())), FuluWithdrawal_d.Withdrawal_default())), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P32_O.U64{1, 0}))) == P32_PRV.pd(hl, P32_PRV.sa(P32_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P32_O.U64{1, 0}))) : P32_D.Digest}:
  P32_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_grow_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_grow_3(+hl: Nat) -> {P33_PRV.rd(hl, P33_PRV.ca(P33_PRV.rc(hl, P33_PRV.ca(P33_PRV.rc(hl, P33_PRV.ca(P33_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default())), FuluWithdrawal_d.Withdrawal_default())), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P33_O.U64{1, 0}))), FuluWithdrawal_d.Withdrawal_default())) == P33_PRV.pd(hl, P33_PRV.sa(P33_PRV.sa(P33_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P33_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default())) : P33_D.Digest}:
  P33_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_grow_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_grow_4(+hl: Nat) -> {P34_PRV.rd(hl, P34_PRV.ca(P34_PRV.rc(hl, P34_PRV.ca(P34_PRV.rc(hl, P34_PRV.ca(P34_PRV.rc(hl, P34_PRV.ca(P34_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default())), FuluWithdrawal_d.Withdrawal_default())), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P34_O.U64{1, 0}))), FuluWithdrawal_d.Withdrawal_default())), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P34_O.U64{1, 0}))) == P34_PRV.pd(hl, P34_PRV.sa(P34_PRV.sa(P34_PRV.sa(P34_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P34_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P34_O.U64{1, 0}))) : P34_D.Digest}:
  P34_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_grow_4(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_grow_5(+hl: Nat) -> {P35_PRV.rd(hl, P35_PRV.ca(P35_PRV.rc(hl, P35_PRV.ca(P35_PRV.rc(hl, P35_PRV.ca(P35_PRV.rc(hl, P35_PRV.ca(P35_PRV.rc(hl, P35_PRV.ca(P35_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default())), FuluWithdrawal_d.Withdrawal_default())), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P35_O.U64{1, 0}))), FuluWithdrawal_d.Withdrawal_default())), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P35_O.U64{1, 0}))), FuluWithdrawal_d.Withdrawal_default())) == P35_PRV.rd(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P35_PRV.sa(P35_PRV.sa(P35_PRV.sa(P35_PRV.sa(P35_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P35_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P35_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()))) : P35_D.Digest}:
  P35_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_grow_5(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_limit() -> {(Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Bool, Fulu_list_Withdrawal_16_d.l16_Withdrawal_capp(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default())), Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Bool, Fulu_list_Withdrawal_16_d.l16_Withdrawal_capp(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(P36_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P36_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()))) == (True{}, False{}) : Bool & Bool}:
  P36_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_limit()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_1(+hl: Nat) -> {P37_PRV.rd(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P37_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()))) == P37_PRV.pd(hl, P37_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default())) : P37_D.Digest}:
  P37_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_1(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_2(+hl: Nat) -> {P38_PRV.rd(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P38_PRV.sa(P38_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P38_O.U64{1, 0})))) == P38_PRV.pd(hl, P38_PRV.sa(P38_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P38_O.U64{1, 0}))) : P38_D.Digest}:
  P38_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_3(+hl: Nat) -> {P39_PRV.rd(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P39_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()))) == P39_PRV.pd(hl, P39_PRV.sa(P39_PRV.sa(P39_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P39_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default())) : P39_D.Digest}:
  P39_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_nonempty_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_set_0(+hl: Nat) -> {P40_PRV.rd(hl, P40_PRV.cs(P40_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P40_PRV.sa(P40_PRV.sa(P40_PRV.sa(P40_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P40_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P40_O.U64{1, 0})))), 0, FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P40_O.U64{1, 0}))) == P40_PRV.pd(hl, P40_PRV.ss(P40_PRV.sa(P40_PRV.sa(P40_PRV.sa(P40_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P40_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P40_O.U64{1, 0})), 0, FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P40_O.U64{1, 0}))) : P40_D.Digest}:
  P40_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_set_0(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_set_1_3(+hl: Nat) -> {P41_PRV.rd(hl, P41_PRV.cs(P41_PRV.cs(P41_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P41_PRV.sa(P41_PRV.sa(P41_PRV.sa(P41_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P41_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P41_O.U64{1, 0})))), 1, FuluWithdrawal_d.Withdrawal_default()), 3, FuluWithdrawal_d.Withdrawal_default())) == P41_PRV.pd(hl, P41_PRV.ss(P41_PRV.ss(P41_PRV.sa(P41_PRV.sa(P41_PRV.sa(P41_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P41_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P41_O.U64{1, 0})), 1, FuluWithdrawal_d.Withdrawal_default()), 3, FuluWithdrawal_d.Withdrawal_default())) : P41_D.Digest}:
  P41_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_set_1_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_set_3(+hl: Nat) -> {P42_PRV.rd(hl, P42_PRV.cs(P42_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P42_PRV.sa(P42_PRV.sa(P42_PRV.sa(P42_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P42_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P42_O.U64{1, 0})))), 3, FuluWithdrawal_d.Withdrawal_default())) == P42_PRV.pd(hl, P42_PRV.ss(P42_PRV.sa(P42_PRV.sa(P42_PRV.sa(P42_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P42_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P42_O.U64{1, 0})), 3, FuluWithdrawal_d.Withdrawal_default())) : P42_D.Digest}:
  P42_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_set_3(hl)

