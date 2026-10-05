import Base
import ../../src/buffer.bend as P0_B
import ../../types/ProgressiveTestStruct_def_generated.bend as ProgressiveTestStruct_d
import ../../types/ProgressiveTestStruct_decode_ssz_generated.bend as ProgressiveTestStruct_r
import ../slop/offsets/generic_ProgressiveTestStruct_first_offset_generated.bend as P0_PRV
import ../../src/buffer.bend as P1_B
import ../../src/obj.bend as P1_O
import ../../types/schema.bend as P1_S
import ../../types/primitive.bend as P1_P
import ../compact/found_generated.bend as P1_FD
import ../compact/arith.bend as P1_A
import ../../proofs/nat_order.bend as P1_Order
import ../../spec/primitives.bend as P1_SP
import ../../spec/layout.bend as P1_Layout
import ../../spec/codec.bend as P1_Codec
import ../../spec/decoding_relation.bend as P1_Decoding
import ../../spec/nat_bytes.bend as P1_N
import ../obj/generic_specs_generated.bend as P1_Spec
import ../obj/spec_fixed.bend as P1_F
import ../obj/vspec.bend as P1_VS
import ../obj/vbuf.bend as P1_VB
import ../obj/vu32.bend as P1_VU
import ../obj/vcopy.bend as P1_VC
import ../obj/vdepth.bend as P1_VD
import ../obj/vfix.bend as P1_VF
import ../obj/var_fix_types_generated.bend as P1_VT
import ../obj/spec_bits_generated.bend as P1_FB
import ../obj/vfits.bend as P1_VFT
import ../obj/vlist.bend as P1_VLS
import ../obj/vbitl.bend as P1_VBL
import ../obj/vbyte_generated.bend as P1_VY
import ../obj/vbrt.bend as P1_VR
import ../obj/vbitc.bend as P1_VBC
import ../obj/vrej.bend as P1_VRJ
import ../obj/vnest.bend as P1_VN
import ../obj/dk.bend as P1_DK
import ../../spec/bitfields.bend as P1_Bits
import ../../spec/bit_packing.bend as P1_Bp
import ../obj/var_winx_ProgressiveTestStruct_generated.bend as P1_W
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_ProgressiveTestStruct_generated.bend as P1_DW_ProgressiveTestStruct
import ../obj/var_codec_ProgressiveTestStruct_generated.bend as P1_PRV
import ../../types/schema.bend as P2_S
import ../../spec/decoding_relation.bend as P2_Decoding
import ../compact/found_generated.bend as P2_FD
import ../compact/arith.bend as P2_A
import ../obj/vbuf.bend as P2_VB
import ../obj/generic_specs_generated.bend as P2_GS
import ../obj/var_codec_ProgressiveTestStruct_generated.bend as P2_DC
import ../../proofs/decode_complete.bend as P2_DCO
import ../obj/var_codec_ProgressiveTestStruct_unique_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_B_ragged_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_B_ragged_1_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_B_ragged_10_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_B_ragged_2_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_B_ragged_4_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_B_ragged_7_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_C_ragged_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_C_ragged_1_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_C_ragged_2_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_C_ragged_3_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_C_ragged_6_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_elem_first_past_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_elem_off0_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_elem_off5_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_elem_off_desc_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_elem_off_past_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_first_past_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_off0_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_off5_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_off_desc_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_f_D_off_past_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_off_minus_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_off_plus_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_order_f_B_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_order_f_C_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_order_f_D_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_bad_size_f_D_elem_elem_f_B_ragged_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/obj.bend as P31_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_all_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/obj.bend as P32_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_default_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/obj.bend as P33_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_f_A_n1_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/obj.bend as P34_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_f_A_n2_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/obj.bend as P35_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_f_B_n1_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/obj.bend as P36_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_f_B_n2_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/obj.bend as P37_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_f_C_n1_generated.bend as P37_PRV
import ../../src/buffer.bend as P38_B
import ../../src/obj.bend as P38_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_f_C_n2_generated.bend as P38_PRV
import ../../src/buffer.bend as P39_B
import ../../src/obj.bend as P39_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_f_D_n1_generated.bend as P39_PRV
import ../../src/buffer.bend as P40_B
import ../../src/obj.bend as P40_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_f_D_n2_generated.bend as P40_PRV
import ../../src/buffer.bend as P41_B
import ../../src/obj.bend as P41_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_marked_generated.bend as P41_PRV
import ../../src/buffer.bend as P42_B
import ../../src/obj.bend as P42_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_ok_wide_generated.bend as P42_PRV
import ../../src/buffer.bend as P43_B
import ../../src/obj.bend as P43_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_all_generated.bend as P43_PRV
import ../../src/buffer.bend as P44_B
import ../../src/obj.bend as P44_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_default_generated.bend as P44_PRV
import ../../src/buffer.bend as P45_B
import ../../src/obj.bend as P45_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_f_A_n1_generated.bend as P45_PRV
import ../../src/buffer.bend as P46_B
import ../../src/obj.bend as P46_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_f_A_n2_generated.bend as P46_PRV
import ../../src/buffer.bend as P47_B
import ../../src/obj.bend as P47_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_f_B_n1_generated.bend as P47_PRV
import ../../src/buffer.bend as P48_B
import ../../src/obj.bend as P48_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_f_B_n2_generated.bend as P48_PRV
import ../../src/buffer.bend as P49_B
import ../../src/obj.bend as P49_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_f_C_n1_generated.bend as P49_PRV
import ../../src/buffer.bend as P50_B
import ../../src/obj.bend as P50_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_f_C_n2_generated.bend as P50_PRV
import ../../src/buffer.bend as P51_B
import ../../src/obj.bend as P51_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_f_D_n1_generated.bend as P51_PRV
import ../../src/buffer.bend as P52_B
import ../../src/obj.bend as P52_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_f_D_n2_generated.bend as P52_PRV
import ../../src/buffer.bend as P53_B
import ../../src/obj.bend as P53_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_marked_generated.bend as P53_PRV
import ../../src/buffer.bend as P54_B
import ../../src/obj.bend as P54_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_ua1_f_B_generated.bend as P54_PRV
import ../../src/buffer.bend as P55_B
import ../../src/obj.bend as P55_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_ua1_f_C_generated.bend as P55_PRV
import ../../src/buffer.bend as P56_B
import ../../src/obj.bend as P56_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_ua2_f_B_generated.bend as P56_PRV
import ../../src/buffer.bend as P57_B
import ../../src/obj.bend as P57_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_ua2_f_C_generated.bend as P57_PRV
import ../../src/buffer.bend as P58_B
import ../../src/obj.bend as P58_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_ua3_f_B_generated.bend as P58_PRV
import ../../src/buffer.bend as P59_B
import ../../src/obj.bend as P59_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_ua3_f_C_generated.bend as P59_PRV
import ../../src/buffer.bend as P60_B
import ../../src/obj.bend as P60_O
import ../slop/validity/generic_ProgressiveTestStruct_decode_literal_rt_wide_generated.bend as P60_PRV
import ../../src/buffer.bend as P61_B
import ../../src/obj.bend as P61_O
import ../obj/decode_window_library_generated.bend as P61_DWL
import ../slop/offsets/ProgressiveTestStruct_generated.bend as P61_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# ProgressiveTestStruct: its decode_ssz laws in the object API's terms, each discharged by its proving law.

def ProgressiveTestStruct__decode_first_offset__ProgressiveTestStruct_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(16, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 0 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 16) == False{} : Bool}) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.ProgressiveTestStruct_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def ProgressiveTestStruct__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, pf, hd, hn, hN)

def ProgressiveTestStruct__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(d, t, n)}) : P1_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveTestStruct__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.ProgressiveTestStruct(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveTestStruct__decode_unique__decode_unique(+d: Nat, +t: P2_FD.array__Tree<U32>, +n: U32, +pf: {P2_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P2_VB.NMAX()) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}, +v: P2_S.Value, spec: P2_Decoding.decodes(P2_GS.ProgressiveTestStruct(), P2_DC.VW(t, n), v)) -> {v == P2_DC.VAL(t, n) : P2_S.Value}:
  P2_PRV.decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec)

def ProgressiveTestStruct__decode_reject__decode_reject(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> P1_Decoding.outside_image(P1_Spec.ProgressiveTestStruct(), P1_PRV.VW(t, n)):
  P1_PRV.decode_reject(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveTestStruct__decode_none__decode_none(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), None{}) : P1_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P1_PRV.decode_none(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_limit()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_nmax_wrap(buf)

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_nmax_above(buf)

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_nmax_at(buf: P3_B.Buf) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(4294967264, 4294967264, (buf, 1073741816)) == ProgressiveTestStruct_r.ProgressiveTestStruct_dgo(True{}, buf, 4294967264) : P3_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_nmax_at(buf)

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_at_2pow31(buf: P3_B.Buf) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(2147483648, 2147483648, (buf, 536870912)) == ProgressiveTestStruct_r.ProgressiveTestStruct_dgo(True{}, buf, 2147483648) : P3_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_at_2pow31(buf)

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(16, 16, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 4))), Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 16))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_accept()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(16, 15, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 4))) == None{} : Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_window()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(16, 16, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 3))) == None{} : Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_storage()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 15}, 16)) == None{} : Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_short()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 16), 16}, 16)) == None{} : Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_real()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_storage_size(buf: P3_B.Buf) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_dchw(16, 16, (buf, 3)) == (buf, None{}) : P3_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_storage_size(buf)

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_budget_agree(buf: P3_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(ProgressiveTestStruct_r.ProgressiveTestStruct_dcost(size), 4294967295), U32.is_le(ProgressiveTestStruct_r.ProgressiveTestStruct_dcost(size), budget)) == True{} : Bool}) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_decode_checked_budget(buf, size, budget) == ProgressiveTestStruct_r.ProgressiveTestStruct_decode_checked(buf, size) : P3_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_budget_agree(buf, size, budget, h)

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vchecked_budget_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode_checked_budget(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 16, 4294967295)), Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 16))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.ProgressiveTestStruct_decode_vchecked_budget_accept()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_B_ragged() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 25), 3, 25), 25}, 25))) == False{} : Bool}:
  P4_PRV.ProgressiveTestStruct_decode_vlit_bad_f_B_ragged()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_1() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 17), 3, 17), 17}, 17))) == False{} : Bool}:
  P5_PRV.ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_10() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 26), 3, 26), 26}, 26))) == False{} : Bool}:
  P6_PRV.ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_10()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_2() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 18), 3, 18), 18}, 18))) == False{} : Bool}:
  P7_PRV.ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_4() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 20), 3, 20), 20}, 20))) == False{} : Bool}:
  P8_PRV.ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_4()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_7() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 23), 3, 23), 23}, 23))) == False{} : Bool}:
  P9_PRV.ProgressiveTestStruct_decode_vlit_bad_f_B_ragged_7()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_C_ragged() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 21), 21}, 21))) == False{} : Bool}:
  P10_PRV.ProgressiveTestStruct_decode_vlit_bad_f_C_ragged()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_C_ragged_1() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 17), 17}, 17))) == False{} : Bool}:
  P11_PRV.ProgressiveTestStruct_decode_vlit_bad_f_C_ragged_1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_C_ragged_2() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 18), 18}, 18))) == False{} : Bool}:
  P12_PRV.ProgressiveTestStruct_decode_vlit_bad_f_C_ragged_2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_C_ragged_3() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 19), 19}, 19))) == False{} : Bool}:
  P13_PRV.ProgressiveTestStruct_decode_vlit_bad_f_C_ragged_3()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_C_ragged_6() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 22), 22}, 22))) == False{} : Bool}:
  P14_PRV.ProgressiveTestStruct_decode_vlit_bad_f_C_ragged_6()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_elem_first_past() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 5, 15), 6, 458752), 31}, 31))) == False{} : Bool}:
  P15_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_elem_first_past()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off0() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 6, 458752), 31}, 31))) == False{} : Bool}:
  P16_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off0()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off5() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 5, 5), 6, 117440512), 32}, 32))) == False{} : Bool}:
  P17_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off5()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off_desc() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 5, 8), 6, 7), 7, 458752), 9, 1792), 42}, 42))) == False{} : Bool}:
  P18_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off_desc()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off_past() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 5, 8), 6, 23), 7, 458752), 9, 1792), 42}, 42))) == False{} : Bool}:
  P19_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_elem_off_past()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_first_past() -> {P20_PRV.some1(Pair.snd(P20_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 8), 20}, 20))) == False{} : Bool}:
  P20_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_first_past()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_off0() -> {P21_PRV.some1(Pair.snd(P21_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 20}, 20))) == False{} : Bool}:
  P21_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_off0()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_off5() -> {P22_PRV.some1(Pair.snd(P22_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 5), 21}, 21))) == False{} : Bool}:
  P22_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_off5()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_off_desc() -> {P23_PRV.some1(Pair.snd(P23_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 8), 5, 7), 24}, 24))) == False{} : Bool}:
  P23_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_off_desc()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_f_D_off_past() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 8), 5, 9), 24}, 24))) == False{} : Bool}:
  P24_PRV.ProgressiveTestStruct_decode_vlit_bad_f_D_off_past()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_off_minus() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 15), 1, 16), 2, 16), 3, 16), 16}, 16))) == False{} : Bool}:
  P25_PRV.ProgressiveTestStruct_decode_vlit_bad_off_minus()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_off_plus() -> {P26_PRV.some1(Pair.snd(P26_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P26_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 17), 1, 16), 2, 16), 3, 16), 17}, 17))) == False{} : Bool}:
  P26_PRV.ProgressiveTestStruct_decode_vlit_bad_off_plus()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_order_f_B() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 15), 2, 16), 3, 16), 16}, 16))) == False{} : Bool}:
  P27_PRV.ProgressiveTestStruct_decode_vlit_bad_order_f_B()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_order_f_C() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 15), 3, 16), 16}, 16))) == False{} : Bool}:
  P28_PRV.ProgressiveTestStruct_decode_vlit_bad_order_f_C()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_order_f_D() -> {P29_PRV.some1(Pair.snd(P29_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P29_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 15), 16}, 16))) == False{} : Bool}:
  P29_PRV.ProgressiveTestStruct_decode_vlit_bad_order_f_D()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_bad_size_f_D_elem_elem_f_B_ragged() -> {P30_PRV.some1(Pair.snd(P30_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P30_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 5, 4), 6, 458752), 34}, 34))) == False{} : Bool}:
  P30_PRV.ProgressiveTestStruct_decode_vlit_bad_size_f_D_elem_elem_f_B_ragged()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_all() -> {P31_PRV.some1(Pair.snd(P31_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P31_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 17), 2, 25), 3, 29), 7, 1024), 33}, 33))) == True{} : Bool}:
  P31_PRV.ProgressiveTestStruct_decode_vlit_ok_all()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_default() -> {P32_PRV.some1(Pair.snd(P32_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P32_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 16))) == True{} : Bool}:
  P32_PRV.ProgressiveTestStruct_decode_vlit_ok_default()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_f_A_n1() -> {P33_PRV.some1(Pair.snd(P33_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P33_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 17), 2, 17), 3, 17), 17}, 17))) == True{} : Bool}:
  P33_PRV.ProgressiveTestStruct_decode_vlit_ok_f_A_n1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_f_A_n2() -> {P34_PRV.some1(Pair.snd(P34_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P34_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 18), 2, 18), 3, 18), 18}, 18))) == True{} : Bool}:
  P34_PRV.ProgressiveTestStruct_decode_vlit_ok_f_A_n2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_f_B_n1() -> {P35_PRV.some1(Pair.snd(P35_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P35_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 24), 3, 24), 24}, 24))) == True{} : Bool}:
  P35_PRV.ProgressiveTestStruct_decode_vlit_ok_f_B_n1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_f_B_n2() -> {P36_PRV.some1(Pair.snd(P36_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P36_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 32), 3, 32), 32}, 32))) == True{} : Bool}:
  P36_PRV.ProgressiveTestStruct_decode_vlit_ok_f_B_n2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_f_C_n1() -> {P37_PRV.some1(Pair.snd(P37_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P37_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 20), 20}, 20))) == True{} : Bool}:
  P37_PRV.ProgressiveTestStruct_decode_vlit_ok_f_C_n1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_f_C_n2() -> {P38_PRV.some1(Pair.snd(P38_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P38_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 24), 24}, 24))) == True{} : Bool}:
  P38_PRV.ProgressiveTestStruct_decode_vlit_ok_f_C_n2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_f_D_n1() -> {P39_PRV.some1(Pair.snd(P39_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P39_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 20}, 20))) == True{} : Bool}:
  P39_PRV.ProgressiveTestStruct_decode_vlit_ok_f_D_n1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_f_D_n2() -> {P40_PRV.some1(Pair.snd(P40_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P40_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 8), 5, 8), 24}, 24))) == True{} : Bool}:
  P40_PRV.ProgressiveTestStruct_decode_vlit_ok_f_D_n2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_marked() -> {P41_PRV.some1(Pair.snd(P41_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P41_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 18), 2, 34), 3, 42), 4, 262144), 6, 262144), 8, 262144), 9, 262144), 10, 524288), 11, 524288), 50}, 50))) == True{} : Bool}:
  P41_PRV.ProgressiveTestStruct_decode_vlit_ok_marked()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_ok_wide() -> {P42_PRV.some1(Pair.snd(P42_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P42_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 16), 1, 20), 2, 36), 3, 44), 4, 4), 5, 4), 6, 6), 7, 7), 8, 8), 9, 4), 10, 10), 11, 8), 12, 30), 13, 8), 14, 15), 15, 458763), 16, 201326592), 17, 1792), 18, 524288), 19, 983040), 20, 851968), 21, 7), 22, 117444096), 96}, 96))) == True{} : Bool}:
  P42_PRV.ProgressiveTestStruct_decode_vlit_ok_wide()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_all() -> {(Pair.snd(P43_B.Buf, U32, P43_B.size(P43_PRV.rt(Pair.snd(P43_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P43_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 17), 2, 25), 3, 29), 7, 1024), 33}, 33))))), P43_PRV.rw9(P43_PRV.rt(Pair.snd(P43_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P43_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 17), 2, 25), 3, 29), 7, 1024), 33}, 33))), 0)) == (33, (16, (17, (25, (29, (0, (0, (0, (1024, 0))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))}:
  P43_PRV.ProgressiveTestStruct_decode_vlit_rt_all()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_default() -> {(Pair.snd(P44_B.Buf, U32, P44_B.size(P44_PRV.rt(Pair.snd(P44_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P44_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 16))))), P44_PRV.rw4(P44_PRV.rt(Pair.snd(P44_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P44_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 16}, 16))), 0)) == (16, (16, (16, (16, 16)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P44_PRV.ProgressiveTestStruct_decode_vlit_rt_default()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_f_A_n1() -> {(Pair.snd(P45_B.Buf, U32, P45_B.size(P45_PRV.rt(Pair.snd(P45_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P45_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 17), 2, 17), 3, 17), 17}, 17))))), P45_PRV.rw5(P45_PRV.rt(Pair.snd(P45_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P45_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 17), 2, 17), 3, 17), 17}, 17))), 0)) == (17, (16, (17, (17, (17, 0))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))}:
  P45_PRV.ProgressiveTestStruct_decode_vlit_rt_f_A_n1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_f_A_n2() -> {(Pair.snd(P46_B.Buf, U32, P46_B.size(P46_PRV.rt(Pair.snd(P46_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P46_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 18), 2, 18), 3, 18), 18}, 18))))), P46_PRV.rw5(P46_PRV.rt(Pair.snd(P46_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P46_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 18), 2, 18), 3, 18), 18}, 18))), 0)) == (18, (16, (18, (18, (18, 0))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))}:
  P46_PRV.ProgressiveTestStruct_decode_vlit_rt_f_A_n2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_f_B_n1() -> {(Pair.snd(P47_B.Buf, U32, P47_B.size(P47_PRV.rt(Pair.snd(P47_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P47_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 24), 3, 24), 24}, 24))))), P47_PRV.rw6(P47_PRV.rt(Pair.snd(P47_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P47_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 24), 3, 24), 24}, 24))), 0)) == (24, (16, (16, (24, (24, (0, 0)))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))}:
  P47_PRV.ProgressiveTestStruct_decode_vlit_rt_f_B_n1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_f_B_n2() -> {(Pair.snd(P48_B.Buf, U32, P48_B.size(P48_PRV.rt(Pair.snd(P48_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P48_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 32), 3, 32), 32}, 32))))), P48_PRV.rw8(P48_PRV.rt(Pair.snd(P48_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P48_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 32), 3, 32), 32}, 32))), 0)) == (32, (16, (16, (32, (32, (0, (0, (0, 0)))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))}:
  P48_PRV.ProgressiveTestStruct_decode_vlit_rt_f_B_n2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_f_C_n1() -> {(Pair.snd(P49_B.Buf, U32, P49_B.size(P49_PRV.rt(Pair.snd(P49_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P49_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 20), 20}, 20))))), P49_PRV.rw5(P49_PRV.rt(Pair.snd(P49_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P49_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 20), 20}, 20))), 0)) == (20, (16, (16, (16, (20, 0))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))}:
  P49_PRV.ProgressiveTestStruct_decode_vlit_rt_f_C_n1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_f_C_n2() -> {(Pair.snd(P50_B.Buf, U32, P50_B.size(P50_PRV.rt(Pair.snd(P50_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P50_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 24), 24}, 24))))), P50_PRV.rw6(P50_PRV.rt(Pair.snd(P50_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P50_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 24), 24}, 24))), 0)) == (24, (16, (16, (16, (24, (0, 0)))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))}:
  P50_PRV.ProgressiveTestStruct_decode_vlit_rt_f_C_n2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_f_D_n1() -> {(Pair.snd(P51_B.Buf, U32, P51_B.size(P51_PRV.rt(Pair.snd(P51_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P51_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 20}, 20))))), P51_PRV.rw5(P51_PRV.rt(Pair.snd(P51_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P51_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 4), 20}, 20))), 0)) == (20, (16, (16, (16, (16, 4))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))}:
  P51_PRV.ProgressiveTestStruct_decode_vlit_rt_f_D_n1()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_f_D_n2() -> {(Pair.snd(P52_B.Buf, U32, P52_B.size(P52_PRV.rt(Pair.snd(P52_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P52_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 8), 5, 8), 24}, 24))))), P52_PRV.rw6(P52_PRV.rt(Pair.snd(P52_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P52_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 16), 2, 16), 3, 16), 4, 8), 5, 8), 24}, 24))), 0)) == (24, (16, (16, (16, (16, (8, 8)))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))}:
  P52_PRV.ProgressiveTestStruct_decode_vlit_rt_f_D_n2()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_marked() -> {(Pair.snd(P53_B.Buf, U32, P53_B.size(P53_PRV.rt(Pair.snd(P53_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P53_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 18), 2, 34), 3, 42), 4, 262144), 6, 262144), 8, 262144), 9, 262144), 10, 524288), 11, 524288), 50}, 50))))), P53_PRV.rw13(P53_PRV.rt(Pair.snd(P53_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P53_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 18), 2, 34), 3, 42), 4, 262144), 6, 262144), 8, 262144), 9, 262144), 10, 524288), 11, 524288), 50}, 50))), 0)) == (50, (16, (18, (34, (42, (262144, (0, (262144, (0, (262144, (262144, (524288, (524288, 0))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))}:
  P53_PRV.ProgressiveTestStruct_decode_vlit_rt_marked()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_ua1_f_B() -> {P54_PRV.rtc9(P54_PRV.rt(Pair.snd(P54_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P54_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 17), 2, 33), 3, 33), 4, 1260781830), 5, 3753547120), 6, 2018717193), 7, 300401309), 8, 54), 33}, 33)))) == (33, (16, (17, (33, (33, (1260781830, (3753547120, (2018717193, (300401309, 54))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))}:
  P54_PRV.ProgressiveTestStruct_decode_vlit_rt_ua1_f_B()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_ua1_f_C() -> {P55_PRV.rtc8(P55_PRV.rt(Pair.snd(P55_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P55_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 17), 2, 17), 3, 29), 4, 1260781830), 5, 3753547120), 6, 2018717193), 7, 157), 29}, 29)))) == (29, (16, (17, (17, (29, (1260781830, (3753547120, (2018717193, 157)))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))}:
  P55_PRV.ProgressiveTestStruct_decode_vlit_rt_ua1_f_C()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_ua2_f_B() -> {P56_PRV.rtc9(P56_PRV.rt(Pair.snd(P56_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P56_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 18), 2, 34), 3, 34), 4, 637610758), 5, 3130355787), 6, 1395526111), 7, 3888291192), 8, 13841), 34}, 34)))) == (34, (16, (18, (34, (34, (637610758, (3130355787, (1395526111, (3888291192, 13841))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))}:
  P56_PRV.ProgressiveTestStruct_decode_vlit_rt_ua2_f_B()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_ua2_f_C() -> {P57_PRV.rtc8(P57_PRV.rt(Pair.snd(P57_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P57_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 18), 2, 18), 3, 30), 4, 637610758), 5, 3130355787), 6, 1395526111), 7, 40312), 30}, 30)))) == (30, (16, (18, (18, (30, (637610758, (3130355787, (1395526111, 40312)))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))}:
  P57_PRV.ProgressiveTestStruct_decode_vlit_rt_ua2_f_C()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_ua3_f_B() -> {P58_PRV.rtc9(P58_PRV.rt(Pair.snd(P58_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P58_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, 16), 1, 19), 2, 35), 3, 35), 4, 22031110), 5, 2507164454), 6, 772399034), 7, 3265099859), 8, 3543527), 35}, 35)))) == (35, (16, (19, (35, (35, (22031110, (2507164454, (772399034, (3265099859, 3543527))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))}:
  P58_PRV.ProgressiveTestStruct_decode_vlit_rt_ua3_f_B()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_ua3_f_C() -> {P59_PRV.rtc8(P59_PRV.rt(Pair.snd(P59_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P59_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 16), 1, 19), 2, 19), 3, 31), 4, 22031110), 5, 2507164454), 6, 772399034), 7, 10319955), 31}, 31)))) == (31, (16, (19, (19, (31, (22031110, (2507164454, (772399034, 10319955)))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))}:
  P59_PRV.ProgressiveTestStruct_decode_vlit_rt_ua3_f_C()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_vlit_rt_wide() -> {P60_PRV.rtc24(P60_PRV.rt(Pair.snd(P60_B.Buf, Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>, ProgressiveTestStruct_r.ProgressiveTestStruct_decode(P60_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 16), 1, 20), 2, 36), 3, 44), 4, 4), 5, 4), 6, 6), 7, 7), 8, 8), 9, 4), 10, 10), 11, 8), 12, 30), 13, 8), 14, 15), 15, 458763), 16, 201326592), 17, 1792), 18, 524288), 19, 983040), 20, 851968), 21, 7), 22, 117444096), 96}, 96)))) == (96, (16, (20, (36, (44, (4, (4, (6, (7, (8, (4, (10, (8, (30, (8, (15, (458763, (201326592, (1792, (524288, (983040, (851968, (7, (117444096, 0)))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))}:
  P60_PRV.ProgressiveTestStruct_decode_vlit_rt_wide()

def ProgressiveTestStruct__decode_offsets__ProgressiveTestStruct_decode_build(buf: P61_B.Buf, +size: U32, b2: P61_B.Buf, e: {ProgressiveTestStruct_r.ProgressiveTestStruct_ok(buf, 0, size) == (b2, True{}) : P61_B.Buf & Bool}, hwin: {U32.is_le(size, P61_DWL.bsz(buf)) == True{} : Bool}) -> {ProgressiveTestStruct_r.ProgressiveTestStruct_decode(buf, size) == ProgressiveTestStruct_r.ProgressiveTestStruct_some(ProgressiveTestStruct_r.ProgressiveTestStruct_build(b2, size)) : P61_B.Buf & Maybe<&1, ProgressiveTestStruct_d.ProgressiveTestStruct>}:
  P61_PRV.ProgressiveTestStruct_decode_build(buf, size, b2, e, hwin)

