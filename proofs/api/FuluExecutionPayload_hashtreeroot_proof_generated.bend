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
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_clean_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/digest.bend as P6_D
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_fold_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/digest.bend as P7_D
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_dok_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/digest.bend as P8_D
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_end_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/digest.bend as P9_D
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_0_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/digest.bend as P10_D
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_1_3_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/digest.bend as P11_D
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_3_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/digest.bend as P12_D
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_0_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/digest.bend as P13_D
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_2_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/digest.bend as P14_D
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_1_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/digest.bend as P15_D
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_2_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/digest.bend as P16_D
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_3_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/digest.bend as P17_D
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_4_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/digest.bend as P18_D
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_app_clean_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/digest.bend as P19_D
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_dok_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/digest.bend as P20_D
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_end_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/digest.bend as P21_D
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_limit_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/digest.bend as P22_D
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_set_0_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/digest.bend as P23_D
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_set_1_3_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/digest.bend as P24_D
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_ExecutionPayload_vroot_l16_Withdrawal_cache_set_3_generated.bend as P24_PRV

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

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_clean(+hl: Nat) -> {P5_PRV.rd(hl, P5_PRV.ca(P5_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0)))), P5_O.words_new(0))) == P5_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(P5_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0)), P5_O.words_new(0)))) : P5_D.Digest}:
  P5_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_clean(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_fold(+hl: Nat) -> {P6_PRV.rd(hl, P6_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P6_O.words_new(0))) == P6_O.mix_len(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, P6_D.node(hl, Pair.snd(P6_O.Boxed<P6_O.Words>, P6_D.Digest, Pair.snd(P6_B.Buf, P6_O.Boxed<P6_O.Words> & P6_D.Digest, FuluTransaction_h.bl1073741824_bx_root(hl, P6_B.empty(), P6_O.BSome{P6_O.words_new(0), P6_O.BNone{}}, 64))), P6_D.zconst(0n)), P6_D.zconst(1n)), P6_D.zconst(2n)), P6_D.zconst(3n)), P6_D.zconst(4n)), P6_D.zconst(5n)), P6_D.zconst(6n)), P6_D.zconst(7n)), P6_D.zconst(8n)), P6_D.zconst(9n)), P6_D.zconst(10n)), P6_D.zconst(11n)), P6_D.zconst(12n)), P6_D.zconst(13n)), P6_D.zconst(14n)), P6_D.zconst(15n)), P6_D.zconst(16n)), P6_D.zconst(17n)), P6_D.zconst(18n)), P6_D.zconst(19n)), 1) : P6_D.Digest}:
  P6_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_app_fold(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_dok() -> {(P7_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P7_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P7_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P7_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P7_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_dok()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_end() -> {(Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Bool, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cset(P8_PRV.ca(P8_PRV.ca(P8_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P8_O.words_new(0)), P8_O.words_new(0)), P8_O.words_new(0)), 3, P8_O.words_new(0))), (Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Bool, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cset(P8_PRV.ca(P8_PRV.ca(P8_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P8_O.words_new(0)), P8_O.words_new(0)), P8_O.words_new(0)), 2, P8_O.words_new(0))), (P8_PRV.is_none(Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Maybe<&1, P8_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_ctake(P8_PRV.ca(P8_PRV.ca(P8_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P8_O.words_new(0)), P8_O.words_new(0)), P8_O.words_new(0)), 3))), P8_PRV.is_none(Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Maybe<&1, P8_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_ctake(P8_PRV.ca(P8_PRV.ca(P8_PRV.ca(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default()), P8_O.words_new(0)), P8_O.words_new(0)), P8_O.words_new(0)), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P8_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_end()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_0(+hl: Nat) -> {P9_PRV.rd(hl, P9_PRV.cs(P9_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P9_O.words_new(0)), P9_O.words_new(0)), P9_O.words_new(0)), P9_O.words_new(0)))), 0, P9_O.words_new(0))) == P9_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P9_PRV.ss(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(P9_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P9_O.words_new(0)), P9_O.words_new(0)), P9_O.words_new(0)), P9_O.words_new(0)), 0, P9_O.words_new(0)))) : P9_D.Digest}:
  P9_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_0(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_1_3(+hl: Nat) -> {P10_PRV.rd(hl, P10_PRV.cs(P10_PRV.cs(P10_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P10_O.words_new(0)), P10_O.words_new(0)), P10_O.words_new(0)), P10_O.words_new(0)))), 1, P10_O.words_new(0)), 3, P10_O.words_new(0))) == P10_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P10_PRV.ss(P10_PRV.ss(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(P10_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P10_O.words_new(0)), P10_O.words_new(0)), P10_O.words_new(0)), P10_O.words_new(0)), 1, P10_O.words_new(0)), 3, P10_O.words_new(0)))) : P10_D.Digest}:
  P10_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_1_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_3(+hl: Nat) -> {P11_PRV.rd(hl, P11_PRV.cs(P11_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P11_PRV.sa(P11_PRV.sa(P11_PRV.sa(P11_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P11_O.words_new(0)), P11_O.words_new(0)), P11_O.words_new(0)), P11_O.words_new(0)))), 3, P11_O.words_new(0))) == P11_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P11_PRV.ss(P11_PRV.sa(P11_PRV.sa(P11_PRV.sa(P11_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P11_O.words_new(0)), P11_O.words_new(0)), P11_O.words_new(0)), P11_O.words_new(0)), 3, P11_O.words_new(0)))) : P11_D.Digest}:
  P11_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_set_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_0(+hl: Nat) -> {P12_PRV.rd(hl, Pair.fst(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Maybe<&1, P12_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_ctake(P12_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P12_PRV.sa(P12_PRV.sa(P12_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P12_O.words_new(0)), P12_O.words_new(0)), P12_O.words_new(0)))), 0))) == P12_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Pair.fst(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq, Maybe<&1, P12_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_take(P12_PRV.sa(P12_PRV.sa(P12_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P12_O.words_new(0)), P12_O.words_new(0)), P12_O.words_new(0)), 0)))) : P12_D.Digest}:
  P12_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_0(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_2(+hl: Nat) -> {P13_PRV.rd(hl, Pair.fst(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Cached, Maybe<&1, P13_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_ctake(P13_PRV.rc(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P13_O.words_new(0)), P13_O.words_new(0)), P13_O.words_new(0)))), 2))) == P13_PRV.rd(hl, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_cache(Pair.fst(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq, Maybe<&1, P13_O.Words>, Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_take(P13_PRV.sa(P13_PRV.sa(P13_PRV.sa(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_default(), P13_O.words_new(0)), P13_O.words_new(0)), P13_O.words_new(0)), 2)))) : P13_D.Digest}:
  P13_PRV.ExecutionPayload_vroot_l1048576_bl1073741824_cache_take_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_1(+hl: Nat) -> {P14_PRV.rd(hl, P14_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default())) == P14_PRV.pd(hl, P14_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default())) : P14_D.Digest}:
  P14_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_1(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_2(+hl: Nat) -> {P15_PRV.rd(hl, P15_PRV.ca(P15_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P15_O.U64{1, 0}))) == P15_PRV.pd(hl, P15_PRV.sa(P15_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P15_O.U64{1, 0}))) : P15_D.Digest}:
  P15_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_2(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_3(+hl: Nat) -> {P16_PRV.rd(hl, P16_PRV.ca(P16_PRV.ca(P16_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P16_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default())) == P16_PRV.pd(hl, P16_PRV.sa(P16_PRV.sa(P16_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P16_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default())) : P16_D.Digest}:
  P16_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_4(+hl: Nat) -> {P17_PRV.rd(hl, P17_PRV.ca(P17_PRV.ca(P17_PRV.ca(P17_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P17_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P17_O.U64{1, 0}))) == P17_PRV.pd(hl, P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(P17_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P17_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P17_O.U64{1, 0}))) : P17_D.Digest}:
  P17_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_4(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_app_clean(+hl: Nat) -> {P18_PRV.rd(hl, P18_PRV.ca(P18_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P18_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()))), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P18_O.U64{1, 0}))) == P18_PRV.pd(hl, P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(P18_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P18_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P18_O.U64{1, 0}))) : P18_D.Digest}:
  P18_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_app_clean(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_dok() -> {(P19_O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (P19_O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (P19_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), P19_O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))}:
  P19_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_dok()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_end() -> {(Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Bool, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cset(P20_PRV.ca(P20_PRV.ca(P20_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P20_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), 3, FuluWithdrawal_d.Withdrawal_default())), (Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Bool, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cset(P20_PRV.ca(P20_PRV.ca(P20_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P20_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), 2, FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P20_O.U64{1, 0}))), (P20_PRV.is_none(Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Maybe<&1, FuluWithdrawal_d.Withdrawal>, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cget(P20_PRV.ca(P20_PRV.ca(P20_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P20_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), 3))), P20_PRV.is_none(Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Maybe<&1, FuluWithdrawal_d.Withdrawal>, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cget(P20_PRV.ca(P20_PRV.ca(P20_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P20_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), 2)))))) == (False{}, (True{}, (True{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P20_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_end()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_limit() -> {(Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Bool, Fulu_list_Withdrawal_16_d.l16_Withdrawal_capp(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default())), Pair.snd(Fulu_list_Withdrawal_16_d.l16_Withdrawal_Cached, Bool, Fulu_list_Withdrawal_16_d.l16_Withdrawal_capp(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(P21_PRV.ca(Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default()), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P21_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()))) == (True{}, False{}) : Bool & Bool}:
  P21_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_limit()

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_set_0(+hl: Nat) -> {P22_PRV.rd(hl, P22_PRV.cs(P22_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P22_PRV.sa(P22_PRV.sa(P22_PRV.sa(P22_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P22_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P22_O.U64{1, 0})))), 0, FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P22_O.U64{1, 0}))) == P22_PRV.pd(hl, P22_PRV.ss(P22_PRV.sa(P22_PRV.sa(P22_PRV.sa(P22_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P22_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P22_O.U64{1, 0})), 0, FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P22_O.U64{1, 0}))) : P22_D.Digest}:
  P22_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_set_0(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_set_1_3(+hl: Nat) -> {P23_PRV.rd(hl, P23_PRV.cs(P23_PRV.cs(P23_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P23_PRV.sa(P23_PRV.sa(P23_PRV.sa(P23_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P23_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P23_O.U64{1, 0})))), 1, FuluWithdrawal_d.Withdrawal_default()), 3, FuluWithdrawal_d.Withdrawal_default())) == P23_PRV.pd(hl, P23_PRV.ss(P23_PRV.ss(P23_PRV.sa(P23_PRV.sa(P23_PRV.sa(P23_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P23_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P23_O.U64{1, 0})), 1, FuluWithdrawal_d.Withdrawal_default()), 3, FuluWithdrawal_d.Withdrawal_default())) : P23_D.Digest}:
  P23_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_set_1_3(hl)

def FuluExecutionPayload__root__ExecutionPayload_vroot_l16_Withdrawal_cache_set_3(+hl: Nat) -> {P24_PRV.rd(hl, P24_PRV.cs(P24_PRV.rc(hl, Fulu_list_Withdrawal_16_d.l16_Withdrawal_cache(P24_PRV.sa(P24_PRV.sa(P24_PRV.sa(P24_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P24_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P24_O.U64{1, 0})))), 3, FuluWithdrawal_d.Withdrawal_default())) == P24_PRV.pd(hl, P24_PRV.ss(P24_PRV.sa(P24_PRV.sa(P24_PRV.sa(P24_PRV.sa(Fulu_list_Withdrawal_16_d.l16_Withdrawal_default(), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P24_O.U64{1, 0})), FuluWithdrawal_d.Withdrawal_default()), FuluWithdrawal_d.Withdrawal_set_index(FuluWithdrawal_d.Withdrawal_default(), P24_O.U64{1, 0})), 3, FuluWithdrawal_d.Withdrawal_default())) : P24_D.Digest}:
  P24_PRV.ExecutionPayload_vroot_l16_Withdrawal_cache_set_3(hl)

