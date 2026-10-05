import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/Fulu_list_DepositRequest_8192_decode_ssz_generated.bend as Fulu_list_DepositRequest_8192_r
import ../../types/Fulu_list_WithdrawalRequest_16_decode_ssz_generated.bend as Fulu_list_WithdrawalRequest_16_r
import ../../types/Fulu_list_ConsolidationRequest_2_decode_ssz_generated.bend as Fulu_list_ConsolidationRequest_2_r
import ../../types/FuluExecutionRequests_def_generated.bend as FuluExecutionRequests_d
import ../../types/FuluExecutionRequests_decode_ssz_generated.bend as FuluExecutionRequests_r
import ../../types/schema.bend as P0_S
import ../../types/primitive.bend as P0_P
import ../compact/found_generated.bend as P0_FD
import ../compact/arith.bend as P0_A
import ../../proofs/nat_order.bend as P0_Order
import ../../spec/primitives.bend as P0_SP
import ../../spec/layout.bend as P0_Layout
import ../../spec/codec.bend as P0_Codec
import ../../spec/nat_bytes.bend as P0_N
import ../../spec/fulu_schemas.bend as P0_Spec
import ../../proofs/decode_shape.bend as P0_DS
import ../../proofs/decode_facts.bend as P0_DF
import ../obj/spec_fixed.bend as P0_F
import ../obj/vspec.bend as P0_VS
import ../obj/vbuf.bend as P0_VB
import ../obj/vu32.bend as P0_VU
import ../obj/vcopy.bend as P0_VC
import ../obj/vdepth.bend as P0_VD
import ../obj/vfits.bend as P0_VFT
import ../obj/vmr_generated.bend as P0_VMR
import ../obj/vua.bend as P0_UA
import ../obj/vua_rd.bend as P0_UR
import ../obj/vua_win.bend as P0_UW
import ../obj/vua_fix_generated.bend as P0_VTX
import ../obj/vrl_generated.bend as P0_VRL
import ../../spec/decoding_relation.bend as P0_Decoding
import ../../proofs/decode_unique.bend as P0_DCO
import ../obj/var_winx_ExecutionRequests_generated.bend as P0_EW
import ../../proofs/obj/decode_window_library_generated.bend as P0_DWL
import ../../proofs/obj/decode_window_FuluExecutionRequests_generated.bend as P0_DW_FuluExecutionRequests
import ../obj/var_codec_ExecutionRequests_generated.bend as P0_PRV
import ../../src/buffer.bend as P1_B
import ../../src/obj.bend as P1_O
import ../slop/validity/fulu_ExecutionRequests_decode_checked_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_consolidations_over_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_consolidations_ragged_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_consolidations_ragged_1_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_consolidations_ragged_115_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_consolidations_ragged_118_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_consolidations_ragged_2_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_consolidations_ragged_58_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_deposits_ragged_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_deposits_ragged_1_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_deposits_ragged_191_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_deposits_ragged_194_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_deposits_ragged_2_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_deposits_ragged_96_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_off_minus_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_off_plus_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_order_consolidations_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_order_withdrawals_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_withdrawals_over_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_withdrawals_ragged_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_withdrawals_ragged_1_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_withdrawals_ragged_2_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_withdrawals_ragged_38_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_withdrawals_ragged_75_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_bad_withdrawals_ragged_78_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_count_at_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_all_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_consolidations_n1_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_consolidations_n2_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_default_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/obj.bend as P31_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_deposits_n1_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/obj.bend as P32_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_deposits_n2_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/obj.bend as P33_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_marked_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/obj.bend as P34_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_wide_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/obj.bend as P35_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_withdrawals_n1_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/obj.bend as P36_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_ok_withdrawals_n2_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/obj.bend as P37_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_rt_consolidations_n1_generated.bend as P37_PRV
import ../../src/buffer.bend as P38_B
import ../../src/obj.bend as P38_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_rt_default_generated.bend as P38_PRV
import ../../src/buffer.bend as P39_B
import ../../src/obj.bend as P39_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_rt_wide_generated.bend as P39_PRV
import ../../src/buffer.bend as P40_B
import ../../src/obj.bend as P40_O
import ../slop/validity/fulu_ExecutionRequests_decode_literal_rt_withdrawals_n1_generated.bend as P40_PRV
import ../../src/buffer.bend as P41_B
import ../../src/obj.bend as P41_O
import ../obj/decode_window_library_generated.bend as P41_DWL
import ../slop/offsets/ExecutionRequests_generated.bend as P41_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluExecutionRequests (ExecutionRequests): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluExecutionRequests__ok_eval__ok_eval(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}) -> {FuluExecutionRequests_r.ExecutionRequests_ok(P0_PRV.BF(t, n), 0, n) == (P0_PRV.BF(t, n), P0_PRV.CHK(t, n)) : P0_B.Buf & Bool}:
  P0_PRV.ok_eval(d, t, n, pf, hd, hn)

def FuluExecutionRequests__decode_accept__decode_accept(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> {FuluExecutionRequests_r.ExecutionRequests_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), Some{P0_PRV.OBJ(d, t, n)}) : P0_B.Buf & Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P0_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def FuluExecutionRequests__decode_spec__decode_spec(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.ExecutionRequests(), P0_PRV.VW(t, n), P0_PRV.VAL(t, n)):
  P0_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def FuluExecutionRequests__decode_unique__decode_unique(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}, +v: P0_S.Value, spec: P0_Decoding.decodes(P0_Spec.ExecutionRequests(), P0_PRV.VW(t, n), v)) -> {v == P0_PRV.VAL(t, n) : P0_S.Value}:
  P0_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def FuluExecutionRequests__decode_reject__decode_reject(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == False{} : Bool}) -> P0_Decoding.outside_image(P0_Spec.ExecutionRequests(), P0_PRV.VW(t, n)):
  P0_PRV.decode_reject(d, t, n, pf, hd, hn, hchk)

def FuluExecutionRequests__decode_none__decode_none(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == False{} : Bool}) -> {FuluExecutionRequests_r.ExecutionRequests_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), None{}) : P0_B.Buf & Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P0_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_limit() -> {Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_dchw(4294967265, 4294967265, (P1_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_limit()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_nmax_wrap(buf: P1_B.Buf) -> {FuluExecutionRequests_r.ExecutionRequests_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P1_B.Buf & Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_nmax_wrap(buf)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_nmax_above(buf: P1_B.Buf) -> {FuluExecutionRequests_r.ExecutionRequests_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P1_B.Buf & Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_nmax_above(buf)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_nmax_at(buf: P1_B.Buf) -> {FuluExecutionRequests_r.ExecutionRequests_dchw(4294967264, 4294967264, (buf, 1073741816)) == FuluExecutionRequests_r.ExecutionRequests_dgo(True{}, buf, 4294967264) : P1_B.Buf & Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_nmax_at(buf)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_at_2pow31(buf: P1_B.Buf) -> {FuluExecutionRequests_r.ExecutionRequests_dchw(2147483648, 2147483648, (buf, 536870912)) == FuluExecutionRequests_r.ExecutionRequests_dgo(True{}, buf, 2147483648) : P1_B.Buf & Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_at_2pow31(buf)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_accept() -> {P1_PRV.is_some(Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_dchw(12, 12, (P1_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 3))), Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode_checked(P1_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 12))) == (True{}, True{}) : Bool & Bool}:
  P1_PRV.ExecutionRequests_decode_vchecked_accept()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_window() -> {Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_dchw(12, 11, (P1_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 3))) == None{} : Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_window()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_storage() -> {Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_dchw(12, 12, (P1_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 2))) == None{} : Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_storage()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_short() -> {Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode_checked(P1_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 11}, 12)) == None{} : Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_short()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_real() -> {Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode_checked(P1_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 12), 12}, 12)) == None{} : Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_real()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_budget_agree(buf: P1_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(FuluExecutionRequests_r.ExecutionRequests_dcost(size), 4294967295), U32.is_le(FuluExecutionRequests_r.ExecutionRequests_dcost(size), budget)) == True{} : Bool}) -> {FuluExecutionRequests_r.ExecutionRequests_decode_checked_budget(buf, size, budget) == FuluExecutionRequests_r.ExecutionRequests_decode_checked(buf, size) : P1_B.Buf & Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P1_PRV.ExecutionRequests_decode_vchecked_budget_agree(buf, size, budget, h)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vchecked_budget_accept() -> {P1_PRV.is_some(Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode_checked_budget(P1_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 12, 4294967295)), Pair.snd(P1_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode_checked(P1_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 12))) == (True{}, True{}) : Bool & Bool}:
  P1_PRV.ExecutionRequests_decode_vchecked_budget_accept()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_consolidations_over() -> {P2_PRV.some1(Pair.snd(P2_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P2_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 12), 1, 12), 2, 12), 360}, 360))) == False{} : Bool}:
  P2_PRV.ExecutionRequests_decode_vlit_bad_consolidations_over()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_consolidations_ragged() -> {P3_PRV.some1(Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 12), 1, 12), 2, 12), 129}, 129))) == False{} : Bool}:
  P3_PRV.ExecutionRequests_decode_vlit_bad_consolidations_ragged()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_consolidations_ragged_1() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 13}, 13))) == False{} : Bool}:
  P4_PRV.ExecutionRequests_decode_vlit_bad_consolidations_ragged_1()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_consolidations_ragged_115() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 12), 127}, 127))) == False{} : Bool}:
  P5_PRV.ExecutionRequests_decode_vlit_bad_consolidations_ragged_115()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_consolidations_ragged_118() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 12), 1, 12), 2, 12), 130}, 130))) == False{} : Bool}:
  P6_PRV.ExecutionRequests_decode_vlit_bad_consolidations_ragged_118()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_consolidations_ragged_2() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 14}, 14))) == False{} : Bool}:
  P7_PRV.ExecutionRequests_decode_vlit_bad_consolidations_ragged_2()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_consolidations_ragged_58() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 12), 70}, 70))) == False{} : Bool}:
  P8_PRV.ExecutionRequests_decode_vlit_bad_consolidations_ragged_58()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_deposits_ragged() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 12), 1, 205), 2, 205), 205}, 205))) == False{} : Bool}:
  P9_PRV.ExecutionRequests_decode_vlit_bad_deposits_ragged()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_deposits_ragged_1() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 13), 2, 13), 13}, 13))) == False{} : Bool}:
  P10_PRV.ExecutionRequests_decode_vlit_bad_deposits_ragged_1()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_deposits_ragged_191() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 12), 1, 203), 2, 203), 203}, 203))) == False{} : Bool}:
  P11_PRV.ExecutionRequests_decode_vlit_bad_deposits_ragged_191()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_deposits_ragged_194() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 12), 1, 206), 2, 206), 206}, 206))) == False{} : Bool}:
  P12_PRV.ExecutionRequests_decode_vlit_bad_deposits_ragged_194()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_deposits_ragged_2() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 14), 2, 14), 14}, 14))) == False{} : Bool}:
  P13_PRV.ExecutionRequests_decode_vlit_bad_deposits_ragged_2()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_deposits_ragged_96() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 108), 2, 108), 108}, 108))) == False{} : Bool}:
  P14_PRV.ExecutionRequests_decode_vlit_bad_deposits_ragged_96()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_off_minus() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 12), 2, 12), 12}, 12))) == False{} : Bool}:
  P15_PRV.ExecutionRequests_decode_vlit_bad_off_minus()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_off_plus() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 13), 1, 12), 2, 12), 13}, 13))) == False{} : Bool}:
  P16_PRV.ExecutionRequests_decode_vlit_bad_off_plus()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_order_consolidations() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 11), 12}, 12))) == False{} : Bool}:
  P17_PRV.ExecutionRequests_decode_vlit_bad_order_consolidations()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_order_withdrawals() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 11), 2, 12), 12}, 12))) == False{} : Bool}:
  P18_PRV.ExecutionRequests_decode_vlit_bad_order_withdrawals()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_withdrawals_over() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 0, 12), 1, 12), 2, 1304), 1304}, 1304))) == False{} : Bool}:
  P19_PRV.ExecutionRequests_decode_vlit_bad_withdrawals_over()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_withdrawals_ragged() -> {P20_PRV.some1(Pair.snd(P20_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 89), 89}, 89))) == False{} : Bool}:
  P20_PRV.ExecutionRequests_decode_vlit_bad_withdrawals_ragged()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_withdrawals_ragged_1() -> {P21_PRV.some1(Pair.snd(P21_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 13), 13}, 13))) == False{} : Bool}:
  P21_PRV.ExecutionRequests_decode_vlit_bad_withdrawals_ragged_1()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_withdrawals_ragged_2() -> {P22_PRV.some1(Pair.snd(P22_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 14), 14}, 14))) == False{} : Bool}:
  P22_PRV.ExecutionRequests_decode_vlit_bad_withdrawals_ragged_2()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_withdrawals_ragged_38() -> {P23_PRV.some1(Pair.snd(P23_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 12), 1, 12), 2, 50), 50}, 50))) == False{} : Bool}:
  P23_PRV.ExecutionRequests_decode_vlit_bad_withdrawals_ragged_38()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_withdrawals_ragged_75() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 87), 87}, 87))) == False{} : Bool}:
  P24_PRV.ExecutionRequests_decode_vlit_bad_withdrawals_ragged_75()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_bad_withdrawals_ragged_78() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 90), 90}, 90))) == False{} : Bool}:
  P25_PRV.ExecutionRequests_decode_vlit_bad_withdrawals_ragged_78()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_count_at_l16_WithdrawalRequest(buf: P26_B.Buf, +off: U32) -> {Fulu_list_WithdrawalRequest_16_r.l16_WithdrawalRequest_ok(buf, off, 1216) == (buf, True{}) : P26_B.Buf & Bool}:
  P26_PRV.ExecutionRequests_decode_vlit_count_at_l16_WithdrawalRequest(buf, off)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_count_over_l16_WithdrawalRequest(buf: P26_B.Buf, +off: U32) -> {Fulu_list_WithdrawalRequest_16_r.l16_WithdrawalRequest_ok(buf, off, 1292) == (buf, False{}) : P26_B.Buf & Bool}:
  P26_PRV.ExecutionRequests_decode_vlit_count_over_l16_WithdrawalRequest(buf, off)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_count_at_l2_ConsolidationRequest(buf: P26_B.Buf, +off: U32) -> {Fulu_list_ConsolidationRequest_2_r.l2_ConsolidationRequest_ok(buf, off, 232) == (buf, True{}) : P26_B.Buf & Bool}:
  P26_PRV.ExecutionRequests_decode_vlit_count_at_l2_ConsolidationRequest(buf, off)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_count_over_l2_ConsolidationRequest(buf: P26_B.Buf, +off: U32) -> {Fulu_list_ConsolidationRequest_2_r.l2_ConsolidationRequest_ok(buf, off, 348) == (buf, False{}) : P26_B.Buf & Bool}:
  P26_PRV.ExecutionRequests_decode_vlit_count_over_l2_ConsolidationRequest(buf, off)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_count_at_l8192_DepositRequest(buf: P26_B.Buf, +off: U32) -> {Fulu_list_DepositRequest_8192_r.l8192_DepositRequest_ok(buf, off, 1572864) == (buf, True{}) : P26_B.Buf & Bool}:
  P26_PRV.ExecutionRequests_decode_vlit_count_at_l8192_DepositRequest(buf, off)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_count_over_l8192_DepositRequest(buf: P26_B.Buf, +off: U32) -> {Fulu_list_DepositRequest_8192_r.l8192_DepositRequest_ok(buf, off, 1573056) == (buf, False{}) : P26_B.Buf & Bool}:
  P26_PRV.ExecutionRequests_decode_vlit_count_over_l8192_DepositRequest(buf, off)

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_all() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 12), 1, 204), 2, 280), 396}, 396))) == True{} : Bool}:
  P27_PRV.ExecutionRequests_decode_vlit_ok_all()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_consolidations_n1() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 12), 128}, 128))) == True{} : Bool}:
  P28_PRV.ExecutionRequests_decode_vlit_ok_consolidations_n1()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_consolidations_n2() -> {P29_PRV.some1(Pair.snd(P29_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P29_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 12), 1, 12), 2, 12), 244}, 244))) == True{} : Bool}:
  P29_PRV.ExecutionRequests_decode_vlit_ok_consolidations_n2()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_default() -> {P30_PRV.some1(Pair.snd(P30_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P30_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 12))) == True{} : Bool}:
  P30_PRV.ExecutionRequests_decode_vlit_ok_default()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_deposits_n1() -> {P31_PRV.some1(Pair.snd(P31_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P31_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 12), 1, 204), 2, 204), 204}, 204))) == True{} : Bool}:
  P31_PRV.ExecutionRequests_decode_vlit_ok_deposits_n1()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_deposits_n2() -> {P32_PRV.some1(Pair.snd(P32_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P32_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 12), 1, 396), 2, 396), 396}, 396))) == True{} : Bool}:
  P32_PRV.ExecutionRequests_decode_vlit_ok_deposits_n2()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_marked() -> {P33_PRV.some1(Pair.snd(P33_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P33_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 12), 1, 396), 2, 548), 3, 4), 51, 4), 99, 4), 118, 4), 137, 4), 166, 4), 780}, 780))) == True{} : Bool}:
  P33_PRV.ExecutionRequests_decode_vlit_ok_marked()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_wide() -> {P34_PRV.some1(Pair.snd(P34_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P34_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 12), 1, 396), 2, 548), 3, 4), 4, 5), 5, 6), 6, 7), 7, 8), 8, 9), 9, 10), 10, 11), 11, 12), 12, 13), 13, 14), 14, 15), 15, 16), 16, 17), 17, 18), 18, 19), 19, 20), 20, 21), 21, 22), 22, 23), 23, 24), 24, 25), 25, 26), 26, 27), 27, 28), 28, 29), 29, 30), 30, 31), 31, 32), 32, 33), 33, 34), 34, 35), 35, 36), 36, 37), 37, 38), 38, 39), 39, 40), 40, 41), 41, 42), 42, 43), 43, 44), 44, 45), 45, 46), 46, 47), 47, 48), 48, 49), 49, 50), 50, 51), 51, 52), 52, 53), 53, 54), 54, 55), 55, 56), 56, 57), 57, 58), 58, 59), 59, 60), 60, 61), 61, 62), 62, 63), 63, 64), 64, 65), 65, 66), 66, 67), 67, 68), 68, 69), 69, 70), 70, 71), 71, 72), 72, 73), 73, 74), 74, 75), 75, 76), 76, 77), 77, 78), 78, 79), 79, 80), 80, 81), 81, 82), 82, 83), 83, 84), 84, 85), 85, 86), 86, 87), 87, 88), 88, 89), 89, 90), 90, 91), 91, 92), 92, 93), 93, 94), 94, 95), 95, 96), 96, 97), 97, 98), 98, 99), 99, 4), 100, 101), 101, 102), 102, 103), 103, 104), 104, 105), 105, 106), 106, 107), 107, 108), 108, 109), 109, 110), 110, 111), 111, 112), 112, 113), 113, 114), 114, 115), 115, 116), 116, 117), 117, 118), 118, 119), 119, 120), 120, 121), 121, 122), 122, 123), 123, 124), 124, 125), 125, 126), 126, 127), 127, 128), 128, 129), 129, 130), 130, 131), 131, 132), 132, 133), 133, 134), 134, 135), 135, 136), 136, 137), 137, 4), 138, 139), 139, 140), 140, 141), 141, 142), 142, 143), 143, 144), 144, 145), 145, 146), 146, 147), 147, 148), 148, 149), 149, 150), 150, 151), 151, 152), 152, 153), 153, 154), 154, 155), 155, 156), 156, 157), 157, 158), 158, 159), 159, 160), 160, 161), 161, 162), 162, 163), 163, 164), 164, 165), 165, 166), 166, 167), 167, 168), 168, 169), 169, 170), 170, 171), 171, 172), 172, 173), 173, 174), 174, 175), 175, 176), 176, 177), 177, 178), 178, 179), 179, 180), 180, 181), 181, 182), 182, 183), 183, 184), 184, 185), 185, 186), 186, 187), 187, 188), 188, 189), 189, 190), 190, 191), 191, 192), 192, 193), 193, 194), 194, 195), 780}, 780))) == True{} : Bool}:
  P34_PRV.ExecutionRequests_decode_vlit_ok_wide()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_withdrawals_n1() -> {P35_PRV.some1(Pair.snd(P35_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P35_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 88), 88}, 88))) == True{} : Bool}:
  P35_PRV.ExecutionRequests_decode_vlit_ok_withdrawals_n1()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_ok_withdrawals_n2() -> {P36_PRV.some1(Pair.snd(P36_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P36_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 12), 1, 12), 2, 164), 164}, 164))) == True{} : Bool}:
  P36_PRV.ExecutionRequests_decode_vlit_ok_withdrawals_n2()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_rt_consolidations_n1() -> {(Pair.snd(P37_B.Buf, U32, P37_B.size(P37_PRV.rt(Pair.snd(P37_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P37_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 12), 128}, 128))))), P37_PRV.rw32(P37_PRV.rt(Pair.snd(P37_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P37_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 12), 128}, 128))), 0)) == (128, (12, (12, (12, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, 0)))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))}:
  P37_PRV.ExecutionRequests_decode_vlit_rt_consolidations_n1()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_rt_default() -> {(Pair.snd(P38_B.Buf, U32, P38_B.size(P38_PRV.rt(Pair.snd(P38_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P38_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 12))))), P38_PRV.rw3(P38_PRV.rt(Pair.snd(P38_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P38_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 12), 2, 12), 12}, 12))), 0)) == (12, (12, (12, 12))) : U32 & (U32 & (U32 & (U32)))}:
  P38_PRV.ExecutionRequests_decode_vlit_rt_default()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_rt_wide() -> {P39_PRV.rtc192(P39_PRV.rt(Pair.snd(P39_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P39_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 12), 1, 396), 2, 548), 3, 4), 4, 5), 5, 6), 6, 7), 7, 8), 8, 9), 9, 10), 10, 11), 11, 12), 12, 13), 13, 14), 14, 15), 15, 16), 16, 17), 17, 18), 18, 19), 19, 20), 20, 21), 21, 22), 22, 23), 23, 24), 24, 25), 25, 26), 26, 27), 27, 28), 28, 29), 29, 30), 30, 31), 31, 32), 32, 33), 33, 34), 34, 35), 35, 36), 36, 37), 37, 38), 38, 39), 39, 40), 40, 41), 41, 42), 42, 43), 43, 44), 44, 45), 45, 46), 46, 47), 47, 48), 48, 49), 49, 50), 50, 51), 51, 52), 52, 53), 53, 54), 54, 55), 55, 56), 56, 57), 57, 58), 58, 59), 59, 60), 60, 61), 61, 62), 62, 63), 63, 64), 64, 65), 65, 66), 66, 67), 67, 68), 68, 69), 69, 70), 70, 71), 71, 72), 72, 73), 73, 74), 74, 75), 75, 76), 76, 77), 77, 78), 78, 79), 79, 80), 80, 81), 81, 82), 82, 83), 83, 84), 84, 85), 85, 86), 86, 87), 87, 88), 88, 89), 89, 90), 90, 91), 91, 92), 92, 93), 93, 94), 94, 95), 95, 96), 96, 97), 97, 98), 98, 99), 99, 4), 100, 101), 101, 102), 102, 103), 103, 104), 104, 105), 105, 106), 106, 107), 107, 108), 108, 109), 109, 110), 110, 111), 111, 112), 112, 113), 113, 114), 114, 115), 115, 116), 116, 117), 117, 118), 118, 119), 119, 120), 120, 121), 121, 122), 122, 123), 123, 124), 124, 125), 125, 126), 126, 127), 127, 128), 128, 129), 129, 130), 130, 131), 131, 132), 132, 133), 133, 134), 134, 135), 135, 136), 136, 137), 137, 4), 138, 139), 139, 140), 140, 141), 141, 142), 142, 143), 143, 144), 144, 145), 145, 146), 146, 147), 147, 148), 148, 149), 149, 150), 150, 151), 151, 152), 152, 153), 153, 154), 154, 155), 155, 156), 156, 157), 157, 158), 158, 159), 159, 160), 160, 161), 161, 162), 162, 163), 163, 164), 164, 165), 165, 166), 166, 167), 167, 168), 168, 169), 169, 170), 170, 171), 171, 172), 172, 173), 173, 174), 174, 175), 175, 176), 176, 177), 177, 178), 178, 179), 179, 180), 180, 181), 181, 182), 182, 183), 183, 184), 184, 185), 185, 186), 186, 187), 187, 188), 188, 189), 189, 190), 190, 191), 191, 192), 192, 193), 193, 194), 194, 195), 780}, 780)))) == (780, (12, (396, (548, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (60, (61, (62, (63, (64, (65, (66, (67, (68, (69, (70, (71, (72, (73, (74, (75, (76, (77, (78, (79, (80, (81, (82, (83, (84, (85, (86, (87, (88, (89, (90, (91, (92, (93, (94, (95, (96, (97, (98, (99, (4, (101, (102, (103, (104, (105, (106, (107, (108, (109, (110, (111, (112, (113, (114, (115, (116, (117, (118, (119, (120, (121, (122, (123, (124, (125, (126, (127, (128, (129, (130, (131, (132, (133, (134, (135, (136, (137, (4, (139, (140, (141, (142, (143, (144, (145, (146, (147, (148, (149, (150, (151, (152, (153, (154, (155, (156, (157, (158, (159, (160, (161, (162, (163, (164, (165, (166, (167, (168, (169, (170, (171, (172, (173, (174, (175, (176, (177, (178, (179, (180, (181, (182, (183, (184, (185, (186, (187, (188, (189, (190, (191, 192)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P39_PRV.ExecutionRequests_decode_vlit_rt_wide()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_vlit_rt_withdrawals_n1() -> {(Pair.snd(P40_B.Buf, U32, P40_B.size(P40_PRV.rt(Pair.snd(P40_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P40_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 88), 88}, 88))))), P40_PRV.rw22(P40_PRV.rt(Pair.snd(P40_B.Buf, Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>, FuluExecutionRequests_r.ExecutionRequests_decode(P40_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 12), 1, 12), 2, 88), 88}, 88))), 0)) == (88, (12, (12, (88, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, 0)))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))}:
  P40_PRV.ExecutionRequests_decode_vlit_rt_withdrawals_n1()

def FuluExecutionRequests__decode_offsets__ExecutionRequests_decode_build(buf: P41_B.Buf, +size: U32, b2: P41_B.Buf, e: {FuluExecutionRequests_r.ExecutionRequests_ok(buf, 0, size) == (b2, True{}) : P41_B.Buf & Bool}, hwin: {U32.is_le(size, P41_DWL.bsz(buf)) == True{} : Bool}) -> {FuluExecutionRequests_r.ExecutionRequests_decode(buf, size) == FuluExecutionRequests_r.ExecutionRequests_some(FuluExecutionRequests_r.ExecutionRequests_build(b2, size)) : P41_B.Buf & Maybe<&1, FuluExecutionRequests_d.ExecutionRequests>}:
  P41_PRV.ExecutionRequests_decode_build(buf, size, b2, e, hwin)

