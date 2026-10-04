import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/ProgressiveVarTestStruct_def_generated.bend as ProgressiveVarTestStruct_d
import ../../types/ProgressiveVarTestStruct_decode_ssz_generated.bend as ProgressiveVarTestStruct_r
import ../../types/schema.bend as P0_S
import ../../types/primitive.bend as P0_P
import ../compact/found_generated.bend as P0_FD
import ../compact/arith.bend as P0_A
import ../../proofs/nat_order.bend as P0_Order
import ../../spec/primitives.bend as P0_SP
import ../../spec/layout.bend as P0_Layout
import ../../spec/codec.bend as P0_Codec
import ../../spec/decoding_relation.bend as P0_Decoding
import ../../spec/nat_bytes.bend as P0_N
import ../obj/vpb29.bend as P0_VP
import ../obj/generic_specs_generated.bend as P0_Spec
import ../obj/spec_fixed.bend as P0_F
import ../obj/vspec.bend as P0_VS
import ../obj/vbuf.bend as P0_VB
import ../obj/vu32.bend as P0_VU
import ../obj/vcopy.bend as P0_VC
import ../obj/vdepth.bend as P0_VD
import ../obj/vfix.bend as P0_VF
import ../obj/var_fix_types_generated.bend as P0_VT
import ../obj/spec_bits_generated.bend as P0_FB
import ../obj/vfits.bend as P0_VFT
import ../obj/vlist.bend as P0_VLS
import ../obj/vbitl.bend as P0_VBL
import ../obj/vbyte_generated.bend as P0_VY
import ../obj/vbrt.bend as P0_VR
import ../obj/vbitc.bend as P0_VBC
import ../obj/vrej.bend as P0_VRJ
import ../obj/vnest.bend as P0_VN
import ../obj/dk.bend as P0_DK
import ../../spec/bitfields.bend as P0_Bits
import ../../spec/bit_packing.bend as P0_Bp
import ../obj/var_winx_ProgressiveVarTestStruct_generated.bend as P0_W
import ../../proofs/obj/decode_window_library_generated.bend as P0_DWL
import ../../proofs/obj/decode_window_ProgressiveVarTestStruct_generated.bend as P0_DW_ProgressiveVarTestStruct
import ../obj/var_codec_ProgressiveVarTestStruct_generated.bend as P0_PRV
import ../../types/schema.bend as P1_S
import ../../spec/decoding_relation.bend as P1_Decoding
import ../compact/found_generated.bend as P1_FD
import ../compact/arith.bend as P1_A
import ../obj/vbuf.bend as P1_VB
import ../obj/generic_specs_generated.bend as P1_GS
import ../obj/var_codec_ProgressiveVarTestStruct_generated.bend as P1_DC
import ../../proofs/decode_complete.bend as P1_DCO
import ../obj/var_codec_ProgressiveVarTestStruct_unique_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/obj.bend as P2_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_checked_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_bad_f_B_over_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_bad_f_B_ragged_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_bad_f_B_ragged_1_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_bad_f_C_nodelim_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_bad_off_minus_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_bad_off_plus_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_bad_order_f_C_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_ok_all_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_ok_default_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_ok_f_B_n1_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_ok_f_B_n2_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_ok_f_C_n1_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_ok_marked_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_rt_all_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_rt_default_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_rt_f_B_n1_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_rt_f_B_n2_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_rt_f_C_n1_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/generic_ProgressiveVarTestStruct_decode_literal_rt_marked_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../obj/decode_window_library_generated.bend as P22_DWL
import ../slop/offsets/ProgressiveVarTestStruct_generated.bend as P22_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# ProgressiveVarTestStruct: its decode_ssz laws in the object API's terms, each discharged by its proving law.

def ProgressiveVarTestStruct__ok_eval__ok_eval(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}) -> {ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_ok(P0_PRV.BF(t, n), 0, n) == (P0_PRV.BF(t, n), P0_PRV.CHK(t, n)) : P0_B.Buf & Bool}:
  P0_PRV.ok_eval(d, t, n, pf, hd, hn, hN)

def ProgressiveVarTestStruct__decode_accept__decode_accept(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> {ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), Some{P0_PRV.OBJ(d, t, n)}) : P0_B.Buf & Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P0_PRV.decode_accept(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveVarTestStruct__decode_spec__decode_spec(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.ProgressiveVarTestStruct(), P0_PRV.VW(t, n), P0_PRV.VAL(t, n)):
  P0_PRV.decode_spec(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveVarTestStruct__decode_unique__decode_unique(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_DC.CHK(t, n) == True{} : Bool}, +v: P1_S.Value, spec: P1_Decoding.decodes(P1_GS.ProgressiveVarTestStruct(), P1_DC.VW(t, n), v)) -> {v == P1_DC.VAL(t, n) : P1_S.Value}:
  P1_PRV.decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec)

def ProgressiveVarTestStruct__decode_reject__decode_reject(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == False{} : Bool}, +hPB: {P0_PRV.PBQ(t, n) == True{} : Bool}) -> P0_Decoding.outside_image(P0_Spec.ProgressiveVarTestStruct(), P0_PRV.VW(t, n)):
  P0_PRV.decode_reject(d, t, n, pf, hd, hn, hN, hchk, hPB)

def ProgressiveVarTestStruct__decode_none__decode_none(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == False{} : Bool}) -> {ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), None{}) : P0_B.Buf & Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P0_PRV.decode_none(d, t, n, pf, hd, hn, hN, hchk)

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vchecked_limit() -> {Pair.snd(P2_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_dchw(4294967265, 4294967265, (P2_B.empty(), 1073741824))) == None{} : Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P2_PRV.ProgressiveVarTestStruct_decode_vchecked_limit()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vchecked_nmax_wrap(buf: P2_B.Buf) -> {ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P2_B.Buf & Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P2_PRV.ProgressiveVarTestStruct_decode_vchecked_nmax_wrap(buf)

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vchecked_nmax_above(buf: P2_B.Buf) -> {ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P2_B.Buf & Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P2_PRV.ProgressiveVarTestStruct_decode_vchecked_nmax_above(buf)

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vchecked_accept() -> {P2_PRV.is_some(Pair.snd(P2_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_dchw(10, 10, (P2_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 256), 10}, 3))), Pair.snd(P2_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode_checked(P2_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 256), 10}, 10))) == (True{}, True{}) : Bool & Bool}:
  P2_PRV.ProgressiveVarTestStruct_decode_vchecked_accept()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vchecked_window() -> {Pair.snd(P2_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_dchw(10, 9, (P2_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 256), 10}, 3))) == None{} : Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P2_PRV.ProgressiveVarTestStruct_decode_vchecked_window()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vchecked_storage() -> {Pair.snd(P2_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_dchw(10, 10, (P2_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 256), 10}, 2))) == None{} : Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P2_PRV.ProgressiveVarTestStruct_decode_vchecked_storage()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vchecked_short() -> {Pair.snd(P2_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode_checked(P2_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 256), 9}, 10)) == None{} : Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P2_PRV.ProgressiveVarTestStruct_decode_vchecked_short()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vchecked_real() -> {Pair.snd(P2_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode_checked(P2_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 2304), 10}, 10)) == None{} : Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P2_PRV.ProgressiveVarTestStruct_decode_vchecked_real()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_bad_f_B_over() -> {P3_PRV.some1(Pair.snd(P3_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 2304), 1, 65792), 64, 256), 258}, 258))) == False{} : Bool}:
  P3_PRV.ProgressiveVarTestStruct_decode_vlit_bad_f_B_over()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_bad_f_B_ragged() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 3072), 3, 1), 13}, 13))) == False{} : Bool}:
  P4_PRV.ProgressiveVarTestStruct_decode_vlit_bad_f_B_ragged()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_bad_f_B_ragged_1() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2560), 2, 65536), 11}, 11))) == False{} : Bool}:
  P5_PRV.ProgressiveVarTestStruct_decode_vlit_bad_f_B_ragged_1()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_bad_f_C_nodelim() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 10}, 10))) == False{} : Bool}:
  P6_PRV.ProgressiveVarTestStruct_decode_vlit_bad_f_C_nodelim()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_bad_off_minus() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2048), 1, 2304), 2, 256), 10}, 10))) == False{} : Bool}:
  P7_PRV.ProgressiveVarTestStruct_decode_vlit_bad_off_minus()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_bad_off_plus() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2560), 1, 2304), 2, 256), 11}, 11))) == False{} : Bool}:
  P8_PRV.ProgressiveVarTestStruct_decode_vlit_bad_off_plus()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_bad_order_f_C() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2048), 2, 256), 10}, 10))) == False{} : Bool}:
  P9_PRV.ProgressiveVarTestStruct_decode_vlit_bad_order_f_C()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_ok_all() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2816), 2, 50331648), 12}, 12))) == True{} : Bool}:
  P10_PRV.ProgressiveVarTestStruct_decode_vlit_ok_all()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_ok_default() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 256), 10}, 10))) == True{} : Bool}:
  P11_PRV.ProgressiveVarTestStruct_decode_vlit_ok_default()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_ok_f_B_n1() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2816), 2, 16777216), 12}, 12))) == True{} : Bool}:
  P12_PRV.ProgressiveVarTestStruct_decode_vlit_ok_f_B_n1()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_ok_f_B_n2() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 3328), 3, 256), 14}, 14))) == True{} : Bool}:
  P13_PRV.ProgressiveVarTestStruct_decode_vlit_ok_f_B_n2()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_ok_f_C_n1() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 768), 10}, 10))) == True{} : Bool}:
  P14_PRV.ProgressiveVarTestStruct_decode_vlit_ok_f_C_n1()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_ok_marked() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 3328), 3, 768), 14}, 14))) == True{} : Bool}:
  P15_PRV.ProgressiveVarTestStruct_decode_vlit_ok_marked()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_rt_all() -> {(Pair.snd(P16_B.Buf, U32, P16_B.size(P16_PRV.rt(Pair.snd(P16_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2816), 2, 50331648), 12}, 12))))), P16_PRV.rw3(P16_PRV.rt(Pair.snd(P16_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2816), 2, 50331648), 12}, 12))), 0)) == (12, (2304, (2816, 50331648))) : U32 & (U32 & (U32 & (U32)))}:
  P16_PRV.ProgressiveVarTestStruct_decode_vlit_rt_all()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_rt_default() -> {(Pair.snd(P17_B.Buf, U32, P17_B.size(P17_PRV.rt(Pair.snd(P17_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 256), 10}, 10))))), P17_PRV.rw3(P17_PRV.rt(Pair.snd(P17_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 256), 10}, 10))), 0)) == (10, (2304, (2304, 256))) : U32 & (U32 & (U32 & (U32)))}:
  P17_PRV.ProgressiveVarTestStruct_decode_vlit_rt_default()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_rt_f_B_n1() -> {(Pair.snd(P18_B.Buf, U32, P18_B.size(P18_PRV.rt(Pair.snd(P18_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2816), 2, 16777216), 12}, 12))))), P18_PRV.rw3(P18_PRV.rt(Pair.snd(P18_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2816), 2, 16777216), 12}, 12))), 0)) == (12, (2304, (2816, 16777216))) : U32 & (U32 & (U32 & (U32)))}:
  P18_PRV.ProgressiveVarTestStruct_decode_vlit_rt_f_B_n1()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_rt_f_B_n2() -> {(Pair.snd(P19_B.Buf, U32, P19_B.size(P19_PRV.rt(Pair.snd(P19_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 3328), 3, 256), 14}, 14))))), P19_PRV.rw4(P19_PRV.rt(Pair.snd(P19_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 3328), 3, 256), 14}, 14))), 0)) == (14, (2304, (3328, (0, 256)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P19_PRV.ProgressiveVarTestStruct_decode_vlit_rt_f_B_n2()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_rt_f_C_n1() -> {(Pair.snd(P20_B.Buf, U32, P20_B.size(P20_PRV.rt(Pair.snd(P20_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 768), 10}, 10))))), P20_PRV.rw3(P20_PRV.rt(Pair.snd(P20_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 2304), 2, 768), 10}, 10))), 0)) == (10, (2304, (2304, 768))) : U32 & (U32 & (U32 & (U32)))}:
  P20_PRV.ProgressiveVarTestStruct_decode_vlit_rt_f_C_n1()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_vlit_rt_marked() -> {(Pair.snd(P21_B.Buf, U32, P21_B.size(P21_PRV.rt(Pair.snd(P21_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 3328), 3, 768), 14}, 14))))), P21_PRV.rw4(P21_PRV.rt(Pair.snd(P21_B.Buf, Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>, ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 2304), 1, 3328), 3, 768), 14}, 14))), 0)) == (14, (2304, (3328, (0, 768)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P21_PRV.ProgressiveVarTestStruct_decode_vlit_rt_marked()

def ProgressiveVarTestStruct__decode_offsets__ProgressiveVarTestStruct_decode_build(buf: P22_B.Buf, +size: U32, b2: P22_B.Buf, e: {ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_ok(buf, 0, size) == (b2, True{}) : P22_B.Buf & Bool}, hwin: {U32.is_le(size, P22_DWL.bsz(buf)) == True{} : Bool}) -> {ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_decode(buf, size) == ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_some(ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_build(b2, size)) : P22_B.Buf & Maybe<&1, ProgressiveVarTestStruct_d.ProgressiveVarTestStruct>}:
  P22_PRV.ProgressiveVarTestStruct_decode_build(buf, size, b2, e, hwin)

