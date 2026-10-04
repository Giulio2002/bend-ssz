import Base
import ../../src/buffer.bend as P0_B
import ../../types/ProgressiveBitsStruct_def_generated.bend as ProgressiveBitsStruct_d
import ../../types/ProgressiveBitsStruct_decode_ssz_generated.bend as ProgressiveBitsStruct_r
import ../slop/offsets/generic_ProgressiveBitsStruct_first_offset_generated.bend as P0_PRV
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
import ../obj/vpb29.bend as P1_VP
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
import ../obj/var_winx_ProgressiveBitsStruct_generated.bend as P1_W
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_ProgressiveBitsStruct_generated.bend as P1_DW_ProgressiveBitsStruct
import ../obj/var_codec_ProgressiveBitsStruct_generated.bend as P1_PRV
import ../../types/schema.bend as P2_S
import ../../spec/decoding_relation.bend as P2_Decoding
import ../compact/found_generated.bend as P2_FD
import ../compact/arith.bend as P2_A
import ../obj/vbuf.bend as P2_VB
import ../obj/generic_specs_generated.bend as P2_GS
import ../obj/var_codec_ProgressiveBitsStruct_generated.bend as P2_DC
import ../../proofs/decode_complete.bend as P2_DCO
import ../obj/var_codec_ProgressiveBitsStruct_unique_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/generic_ProgressiveBitsStruct_bitops_bits1280_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_ProgressiveBitsStruct_bitops_bits1281_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_ProgressiveBitsStruct_bitops_bits256_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_ProgressiveBitsStruct_bitops_bits257_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_checked_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_B_nodelim_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_B_over_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_C_nodelim_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_D_pad_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_E_nodelim_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_E_over_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_F_nodelim_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_H_nodelim_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_H_over_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_I_nodelim_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_J_pad_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_K_nodelim_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_K_over_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_f_L_nodelim_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_off_minus_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_off_plus_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_order_f_C_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_order_f_E_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_order_f_F_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_order_f_H_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_order_f_I_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_order_f_K_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_bad_order_f_L_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/obj.bend as P31_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_all_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/obj.bend as P32_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_default_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/obj.bend as P33_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_f_B_n1_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/obj.bend as P34_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_f_C_n1_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/obj.bend as P35_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_f_E_n1_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/obj.bend as P36_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_f_F_n1_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/obj.bend as P37_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_f_H_n1_generated.bend as P37_PRV
import ../../src/buffer.bend as P38_B
import ../../src/obj.bend as P38_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_f_I_n1_generated.bend as P38_PRV
import ../../src/buffer.bend as P39_B
import ../../src/obj.bend as P39_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_f_K_n1_generated.bend as P39_PRV
import ../../src/buffer.bend as P40_B
import ../../src/obj.bend as P40_O
import ../slop/validity/generic_ProgressiveBitsStruct_decode_literal_ok_f_L_n1_generated.bend as P40_PRV
import ../../src/buffer.bend as P41_B
import ../../src/obj.bend as P41_O
import ../obj/decode_window_library_generated.bend as P41_DWL
import ../slop/offsets/ProgressiveBitsStruct_generated.bend as P41_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# ProgressiveBitsStruct: its decode_ssz laws in the object API's terms, each discharged by its proving law.

def ProgressiveBitsStruct__decode_first_offset__ProgressiveBitsStruct_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(418, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 32 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 418) == False{} : Bool}) -> {ProgressiveBitsStruct_r.ProgressiveBitsStruct_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.ProgressiveBitsStruct_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def ProgressiveBitsStruct__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}) -> {ProgressiveBitsStruct_r.ProgressiveBitsStruct_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, pf, hd, hn, hN)

def ProgressiveBitsStruct__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(d, t, n)}) : P1_B.Buf & Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveBitsStruct__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.ProgressiveBitsStruct(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveBitsStruct__decode_unique__decode_unique(+d: Nat, +t: P2_FD.array__Tree<U32>, +n: U32, +pf: {P2_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P2_VB.NMAX()) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}, +v: P2_S.Value, spec: P2_Decoding.decodes(P2_GS.ProgressiveBitsStruct(), P2_DC.VW(t, n), v)) -> {v == P2_DC.VAL(t, n) : P2_S.Value}:
  P2_PRV.decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec)

def ProgressiveBitsStruct__decode_reject__decode_reject(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}, +hPB: {P1_PRV.PBQ(t, n) == True{} : Bool}) -> P1_Decoding.outside_image(P1_Spec.ProgressiveBitsStruct(), P1_PRV.VW(t, n)):
  P1_PRV.decode_reject(d, t, n, pf, hd, hn, hN, hchk, hPB)

def ProgressiveBitsStruct__decode_none__decode_none(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> {ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), None{}) : P1_B.Buf & Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P1_PRV.decode_none(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_0() -> {Pair.snd(P3_B.Buf, P3_O.Bits, P3_O.bits_clear(0, (P3_B.empty(), P3_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P3_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967294), 1, 4294967295), 0} : P3_O.Bits}:
  P3_PRV.ProgressiveBitsStruct_decode_vbits_clear_0()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_9() -> {Pair.snd(P3_B.Buf, P3_O.Bits, P3_O.bits_clear(9, (P3_B.empty(), P3_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P3_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294966783), 1, 4294967295), 9} : P3_O.Bits}:
  P3_PRV.ProgressiveBitsStruct_decode_vbits_clear_9()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_33() -> {Pair.snd(P3_B.Buf, P3_O.Bits, P3_O.bits_clear(33, (P3_B.empty(), P3_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P3_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967293), 33} : P3_O.Bits}:
  P3_PRV.ProgressiveBitsStruct_decode_vbits_clear_33()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_40() -> {Pair.snd(P3_B.Buf, P3_O.Bits, P3_O.bits_clear(40, (P3_B.empty(), P3_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P3_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967039), 40} : P3_O.Bits}:
  P3_PRV.ProgressiveBitsStruct_decode_vbits_clear_40()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_63() -> {Pair.snd(P3_B.Buf, P3_O.Bits, P3_O.bits_clear(63, (P3_B.empty(), P3_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P3_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 2147483647), 63} : P3_O.Bits}:
  P3_PRV.ProgressiveBitsStruct_decode_vbits_clear_63()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_0_2() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(0, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967294), 1, 4294967295), 0} : P4_O.Bits}:
  P4_PRV.ProgressiveBitsStruct_decode_vbits_clear_0()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_9_2() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(9, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294966783), 1, 4294967295), 9} : P4_O.Bits}:
  P4_PRV.ProgressiveBitsStruct_decode_vbits_clear_9()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_33_2() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(33, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967293), 33} : P4_O.Bits}:
  P4_PRV.ProgressiveBitsStruct_decode_vbits_clear_33()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_40_2() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(40, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967039), 40} : P4_O.Bits}:
  P4_PRV.ProgressiveBitsStruct_decode_vbits_clear_40()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_63_2() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(63, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 2147483647), 63} : P4_O.Bits}:
  P4_PRV.ProgressiveBitsStruct_decode_vbits_clear_63()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_0_3() -> {Pair.snd(P5_B.Buf, P5_O.Bits, P5_O.bits_clear(0, (P5_B.empty(), P5_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P5_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967294), 1, 4294967295), 0} : P5_O.Bits}:
  P5_PRV.ProgressiveBitsStruct_decode_vbits_clear_0()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_9_3() -> {Pair.snd(P5_B.Buf, P5_O.Bits, P5_O.bits_clear(9, (P5_B.empty(), P5_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P5_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294966783), 1, 4294967295), 9} : P5_O.Bits}:
  P5_PRV.ProgressiveBitsStruct_decode_vbits_clear_9()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_33_3() -> {Pair.snd(P5_B.Buf, P5_O.Bits, P5_O.bits_clear(33, (P5_B.empty(), P5_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P5_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967293), 33} : P5_O.Bits}:
  P5_PRV.ProgressiveBitsStruct_decode_vbits_clear_33()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_40_3() -> {Pair.snd(P5_B.Buf, P5_O.Bits, P5_O.bits_clear(40, (P5_B.empty(), P5_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P5_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967039), 40} : P5_O.Bits}:
  P5_PRV.ProgressiveBitsStruct_decode_vbits_clear_40()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_63_3() -> {Pair.snd(P5_B.Buf, P5_O.Bits, P5_O.bits_clear(63, (P5_B.empty(), P5_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P5_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 2147483647), 63} : P5_O.Bits}:
  P5_PRV.ProgressiveBitsStruct_decode_vbits_clear_63()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_0_4() -> {Pair.snd(P6_B.Buf, P6_O.Bits, P6_O.bits_clear(0, (P6_B.empty(), P6_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967294), 1, 4294967295), 0} : P6_O.Bits}:
  P6_PRV.ProgressiveBitsStruct_decode_vbits_clear_0()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_9_4() -> {Pair.snd(P6_B.Buf, P6_O.Bits, P6_O.bits_clear(9, (P6_B.empty(), P6_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294966783), 1, 4294967295), 9} : P6_O.Bits}:
  P6_PRV.ProgressiveBitsStruct_decode_vbits_clear_9()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_33_4() -> {Pair.snd(P6_B.Buf, P6_O.Bits, P6_O.bits_clear(33, (P6_B.empty(), P6_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967293), 33} : P6_O.Bits}:
  P6_PRV.ProgressiveBitsStruct_decode_vbits_clear_33()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_40_4() -> {Pair.snd(P6_B.Buf, P6_O.Bits, P6_O.bits_clear(40, (P6_B.empty(), P6_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967039), 40} : P6_O.Bits}:
  P6_PRV.ProgressiveBitsStruct_decode_vbits_clear_40()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vbits_clear_63_4() -> {Pair.snd(P6_B.Buf, P6_O.Bits, P6_O.bits_clear(63, (P6_B.empty(), P6_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 2147483647), 63} : P6_O.Bits}:
  P6_PRV.ProgressiveBitsStruct_decode_vbits_clear_63()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vchecked_limit() -> {Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_dchw(4294967265, 4294967265, (P7_B.empty(), 1073741824))) == None{} : Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P7_PRV.ProgressiveBitsStruct_decode_vchecked_limit()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vchecked_nmax_wrap(buf: P7_B.Buf) -> {ProgressiveBitsStruct_r.ProgressiveBitsStruct_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P7_B.Buf & Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P7_PRV.ProgressiveBitsStruct_decode_vchecked_nmax_wrap(buf)

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vchecked_nmax_above(buf: P7_B.Buf) -> {ProgressiveBitsStruct_r.ProgressiveBitsStruct_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P7_B.Buf & Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P7_PRV.ProgressiveBitsStruct_decode_vchecked_nmax_above(buf)

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vchecked_accept() -> {P7_PRV.is_some(Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_dchw(426, 426, (P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 107))), Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode_checked(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == (True{}, True{}) : Bool & Bool}:
  P7_PRV.ProgressiveBitsStruct_decode_vchecked_accept()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vchecked_window() -> {Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_dchw(426, 425, (P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 107))) == None{} : Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P7_PRV.ProgressiveBitsStruct_decode_vchecked_window()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vchecked_storage() -> {Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_dchw(426, 426, (P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 106))) == None{} : Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P7_PRV.ProgressiveBitsStruct_decode_vchecked_storage()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vchecked_short() -> {Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode_checked(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 425}, 426)) == None{} : Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P7_PRV.ProgressiveBitsStruct_decode_vchecked_short()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vchecked_real() -> {Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode_checked(P7_B.Buf{Array.new(U32, 0n, 0), 426}, 426)) == None{} : Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P7_PRV.ProgressiveBitsStruct_decode_vchecked_real()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_B_nodelim() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16777216), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P8_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_B_nodelim()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_B_over() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 451), 18, 115712), 19, 115968), 60, 116224), 61, 116480), 102, 29884416), 103, 29949952), 112, 16908288), 113, 16843009), 114, 257), 458}, 458))) == False{} : Bool}:
  P9_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_B_over()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_C_nodelim() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 65536), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P10_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_C_nodelim()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_D_pad() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107522), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P11_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_D_pad()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_E_nodelim() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843008), 106, 257), 426}, 426))) == False{} : Bool}:
  P12_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_E_nodelim()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_E_over() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 115968), 60, 116224), 61, 116480), 102, 29884416), 103, 29949952), 104, 16842752), 113, 16843012), 114, 257), 458}, 458))) == False{} : Bool}:
  P13_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_E_over()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_F_nodelim() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16842753), 106, 257), 426}, 426))) == False{} : Bool}:
  P14_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_F_nodelim()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_H_nodelim() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16777473), 106, 257), 426}, 426))) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_H_nodelim()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_H_over() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 149248), 102, 38273024), 103, 38338560), 104, 16842752), 105, 257), 145, 16908288), 146, 257), 586}, 586))) == False{} : Bool}:
  P16_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_H_over()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_I_nodelim() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 65793), 106, 257), 426}, 426))) == False{} : Bool}:
  P17_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_I_nodelim()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_J_pad() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787776), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P18_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_J_pad()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_K_nodelim() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 256), 426}, 426))) == False{} : Bool}:
  P19_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_K_nodelim()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_K_over() -> {P20_PRV.some1(Pair.snd(P20_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 38338560), 104, 16842752), 105, 16843009), 146, 260), 586}, 586))) == False{} : Bool}:
  P20_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_K_over()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_f_L_nodelim() -> {P21_PRV.some1(Pair.snd(P21_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 1), 426}, 426))) == False{} : Bool}:
  P21_PRV.ProgressiveBitsStruct_decode_vlit_bad_f_L_nodelim()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_off_minus() -> {P22_PRV.some1(Pair.snd(P22_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 417), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P22_PRV.ProgressiveBitsStruct_decode_vlit_bad_off_minus()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_off_plus() -> {P23_PRV.some1(Pair.snd(P23_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 419), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 427}, 427))) == False{} : Bool}:
  P23_PRV.ProgressiveBitsStruct_decode_vlit_bad_off_plus()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_order_f_C() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 417), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P24_PRV.ProgressiveBitsStruct_decode_vlit_bad_order_f_C()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_order_f_E() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107008), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P25_PRV.ProgressiveBitsStruct_decode_vlit_bad_order_f_E()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_order_f_F() -> {P26_PRV.some1(Pair.snd(P26_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P26_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107264), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P26_PRV.ProgressiveBitsStruct_decode_vlit_bad_order_f_F()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_order_f_H() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 107520), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P27_PRV.ProgressiveBitsStruct_decode_vlit_bad_order_f_H()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_order_f_I() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 107776), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P28_PRV.ProgressiveBitsStruct_decode_vlit_bad_order_f_I()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_order_f_K() -> {P29_PRV.some1(Pair.snd(P29_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P29_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27656192), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P29_PRV.ProgressiveBitsStruct_decode_vlit_bad_order_f_K()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_bad_order_f_L() -> {P30_PRV.some1(Pair.snd(P30_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P30_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27721728), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == False{} : Bool}:
  P30_PRV.ProgressiveBitsStruct_decode_vlit_bad_order_f_L()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_all() -> {P31_PRV.some1(Pair.snd(P31_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P31_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 50528256), 105, 50529027), 106, 771), 426}, 426))) == True{} : Bool}:
  P31_PRV.ProgressiveBitsStruct_decode_vlit_ok_all()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_default() -> {P32_PRV.some1(Pair.snd(P32_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P32_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 257), 426}, 426))) == True{} : Bool}:
  P32_PRV.ProgressiveBitsStruct_decode_vlit_ok_default()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_f_B_n1() -> {P33_PRV.some1(Pair.snd(P33_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P33_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16973824), 105, 16843009), 106, 257), 426}, 426))) == True{} : Bool}:
  P33_PRV.ProgressiveBitsStruct_decode_vlit_ok_f_B_n1()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_f_C_n1() -> {P34_PRV.some1(Pair.snd(P34_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P34_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 50397184), 105, 16843009), 106, 257), 426}, 426))) == True{} : Bool}:
  P34_PRV.ProgressiveBitsStruct_decode_vlit_ok_f_C_n1()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_f_E_n1() -> {P35_PRV.some1(Pair.snd(P35_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P35_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843011), 106, 257), 426}, 426))) == True{} : Bool}:
  P35_PRV.ProgressiveBitsStruct_decode_vlit_ok_f_E_n1()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_f_F_n1() -> {P36_PRV.some1(Pair.snd(P36_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P36_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843521), 106, 257), 426}, 426))) == True{} : Bool}:
  P36_PRV.ProgressiveBitsStruct_decode_vlit_ok_f_F_n1()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_f_H_n1() -> {P37_PRV.some1(Pair.snd(P37_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P37_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16974081), 106, 257), 426}, 426))) == True{} : Bool}:
  P37_PRV.ProgressiveBitsStruct_decode_vlit_ok_f_H_n1()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_f_I_n1() -> {P38_PRV.some1(Pair.snd(P38_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P38_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 50397441), 106, 257), 426}, 426))) == True{} : Bool}:
  P38_PRV.ProgressiveBitsStruct_decode_vlit_ok_f_I_n1()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_f_K_n1() -> {P39_PRV.some1(Pair.snd(P39_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P39_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 259), 426}, 426))) == True{} : Bool}:
  P39_PRV.ProgressiveBitsStruct_decode_vlit_ok_f_K_n1()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_vlit_ok_f_L_n1() -> {P40_PRV.some1(Pair.snd(P40_B.Buf, Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>, ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(P40_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 8, 418), 9, 419), 18, 107520), 19, 107776), 60, 108032), 61, 108288), 102, 27787264), 103, 27852800), 104, 16842752), 105, 16843009), 106, 769), 426}, 426))) == True{} : Bool}:
  P40_PRV.ProgressiveBitsStruct_decode_vlit_ok_f_L_n1()

def ProgressiveBitsStruct__decode_offsets__ProgressiveBitsStruct_decode_build(buf: P41_B.Buf, +size: U32, b2: P41_B.Buf, e: {ProgressiveBitsStruct_r.ProgressiveBitsStruct_ok(buf, 0, size) == (b2, True{}) : P41_B.Buf & Bool}, hwin: {U32.is_le(size, P41_DWL.bsz(buf)) == True{} : Bool}) -> {ProgressiveBitsStruct_r.ProgressiveBitsStruct_decode(buf, size) == ProgressiveBitsStruct_r.ProgressiveBitsStruct_some(ProgressiveBitsStruct_r.ProgressiveBitsStruct_build(b2, size)) : P41_B.Buf & Maybe<&1, ProgressiveBitsStruct_d.ProgressiveBitsStruct>}:
  P41_PRV.ProgressiveBitsStruct_decode_build(buf, size, b2, e, hwin)

