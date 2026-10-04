import Base
import ../../src/buffer.bend as P0_B
import ../../types/ComplexTestStruct_def_generated.bend as ComplexTestStruct_d
import ../../types/ComplexTestStruct_decode_ssz_generated.bend as ComplexTestStruct_r
import ../slop/offsets/generic_ComplexTestStruct_first_offset_generated.bend as P0_PRV
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
import ../obj/var_winx_ComplexTestStruct_generated.bend as P1_W
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_ComplexTestStruct_generated.bend as P1_DW_ComplexTestStruct
import ../obj/var_codec_ComplexTestStruct_generated.bend as P1_PRV
import ../../types/schema.bend as P2_S
import ../../spec/decoding_relation.bend as P2_Decoding
import ../compact/found_generated.bend as P2_FD
import ../compact/arith.bend as P2_A
import ../obj/vbuf.bend as P2_VB
import ../obj/generic_specs_generated.bend as P2_GS
import ../obj/var_codec_ComplexTestStruct_generated.bend as P2_DC
import ../../proofs/decode_complete.bend as P2_DCO
import ../obj/var_codec_ComplexTestStruct_unique_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/generic_ComplexTestStruct_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_B_over_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_B_ragged_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_B_ragged_1_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_D_over_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_E_f_B_ragged_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_E_f_B_ragged_1_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_E_off_minus_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_E_off_plus_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_G_e0_f_B_ragged_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_G_e0_f_B_ragged_1_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_G_e0_off_minus_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_G_e0_off_plus_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_G_e1_f_B_ragged_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_G_e1_f_B_ragged_1_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_G_e1_off_minus_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_f_G_e1_off_plus_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_off_minus_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_off_plus_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_order_f_D_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_order_f_E_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_bad_order_f_G_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_ok_all_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_ok_default_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_ok_f_B_n1_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_ok_f_B_n2_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_ok_f_D_n1_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_ok_marked_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/obj.bend as P31_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_rt_all_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/obj.bend as P32_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_rt_default_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/obj.bend as P33_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_rt_f_B_n1_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/obj.bend as P34_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_rt_f_B_n2_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/obj.bend as P35_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_rt_f_D_n1_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/obj.bend as P36_O
import ../slop/validity/generic_ComplexTestStruct_decode_literal_rt_marked_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/obj.bend as P37_O
import ../obj/decode_window_library_generated.bend as P37_DWL
import ../slop/offsets/ComplexTestStruct_generated.bend as P37_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# ComplexTestStruct: its decode_ssz laws in the object API's terms, each discharged by its proving law.

def ComplexTestStruct__decode_first_offset__ComplexTestStruct_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(71, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 2 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 71) == False{} : Bool}) -> {ComplexTestStruct_r.ComplexTestStruct_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.ComplexTestStruct_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def ComplexTestStruct__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}) -> {ComplexTestStruct_r.ComplexTestStruct_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, pf, hd, hn)

def ComplexTestStruct__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {ComplexTestStruct_r.ComplexTestStruct_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(d, t, n)}) : P1_B.Buf & Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def ComplexTestStruct__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.ComplexTestStruct(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def ComplexTestStruct__decode_unique__decode_unique(+d: Nat, +t: P2_FD.array__Tree<U32>, +n: U32, +pf: {P2_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}, +v: P2_S.Value, spec: P2_Decoding.decodes(P2_GS.ComplexTestStruct(), P2_DC.VW(t, n), v)) -> {v == P2_DC.VAL(t, n) : P2_S.Value}:
  P2_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def ComplexTestStruct__decode_reject__decode_reject(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> P1_Decoding.outside_image(P1_Spec.ComplexTestStruct(), P1_PRV.VW(t, n)):
  P1_PRV.decode_reject(d, t, n, pf, hd, hn, hchk)

def ComplexTestStruct__decode_none__decode_none(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> {ComplexTestStruct_r.ComplexTestStruct_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), None{}) : P1_B.Buf & Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P1_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_limit()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {ComplexTestStruct_r.ComplexTestStruct_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_nmax_wrap(buf)

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {ComplexTestStruct_r.ComplexTestStruct_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_nmax_above(buf)

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_nmax_at(buf: P3_B.Buf) -> {ComplexTestStruct_r.ComplexTestStruct_dchw(4294967264, 4294967264, (buf, 1073741816)) == ComplexTestStruct_r.ComplexTestStruct_dgo(True{}, buf, 4294967264) : P3_B.Buf & Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_nmax_at(buf)

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_at_2pow31(buf: P3_B.Buf) -> {ComplexTestStruct_r.ComplexTestStruct_dchw(2147483648, 2147483648, (buf, 536870912)) == ComplexTestStruct_r.ComplexTestStruct_dgo(True{}, buf, 2147483648) : P3_B.Buf & Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_at_2pow31(buf)

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_dchw(100, 100, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 25))), Pair.snd(P3_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.ComplexTestStruct_decode_vchecked_accept()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_dchw(100, 99, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 25))) == None{} : Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_window()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_dchw(100, 100, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 24))) == None{} : Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_storage()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 99}, 100)) == None{} : Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_short()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 4653056), 100}, 100)) == None{} : Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P3_PRV.ComplexTestStruct_decode_vchecked_real()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_B_over() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 4653056), 1, 1224736768), 2, 1224736769), 3, 1), 16, 1342177280), 17, 1), 82, 117440512), 84, 8), 85, 15), 86, 458752), 88, 1792), 358}, 358))) == False{} : Bool}:
  P4_PRV.ComplexTestStruct_decode_vlit_bad_f_B_over()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_B_ragged() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1241513984), 2, 1241513984), 16, 1358954496), 19, 7), 20, 2048), 21, 3840), 22, 117440512), 24, 458752), 103}, 103))) == False{} : Bool}:
  P5_PRV.ComplexTestStruct_decode_vlit_bad_f_B_ragged()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_B_ragged_1() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1207959552), 2, 1207959552), 16, 1325400064), 18, 458752), 19, 134217728), 20, 251658240), 22, 1792), 24, 7), 101}, 101))) == False{} : Bool}:
  P6_PRV.ComplexTestStruct_decode_vlit_bad_f_B_ragged_1()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_D_over() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 4653056), 1, 1191182336), 2, 1207959552), 3, 1), 16, 1325400064), 17, 1), 82, 458752), 83, 134217728), 84, 251658240), 86, 1792), 88, 7), 357}, 357))) == False{} : Bool}:
  P7_PRV.ComplexTestStruct_decode_vlit_bad_f_D_over()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_E_f_B_ragged() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1358954496), 18, 1792), 20, 2048), 21, 3840), 22, 117440512), 24, 458752), 103}, 103))) == False{} : Bool}:
  P8_PRV.ComplexTestStruct_decode_vlit_bad_f_E_f_B_ragged()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_E_f_B_ragged_1() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1325400064), 18, 1792), 19, 134217728), 20, 251658240), 22, 1792), 24, 7), 101}, 101))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_decode_vlit_bad_f_E_f_B_ragged_1()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_E_off_minus() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1536), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))) == False{} : Bool}:
  P10_PRV.ComplexTestStruct_decode_vlit_bad_f_E_off_minus()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_E_off_plus() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1325400064), 18, 2048), 19, 134217728), 20, 251658240), 22, 1792), 24, 7), 101}, 101))) == False{} : Bool}:
  P11_PRV.ComplexTestStruct_decode_vlit_bad_f_E_off_plus()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_G_e0_f_B_ragged() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 1179648), 22, 7), 24, 458752), 103}, 103))) == False{} : Bool}:
  P12_PRV.ComplexTestStruct_decode_vlit_bad_f_G_e0_f_B_ragged()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_G_e0_f_B_ragged_1() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 1048576), 22, 7), 24, 7), 101}, 101))) == False{} : Bool}:
  P13_PRV.ComplexTestStruct_decode_vlit_bad_f_G_e0_f_B_ragged_1()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_G_e0_off_minus() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 6), 23, 117440512), 100}, 100))) == False{} : Bool}:
  P14_PRV.ComplexTestStruct_decode_vlit_bad_f_G_e0_off_minus()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_G_e0_off_plus() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 1048576), 22, 8), 24, 7), 101}, 101))) == False{} : Bool}:
  P15_PRV.ComplexTestStruct_decode_vlit_bad_f_G_e0_off_plus()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_G_e1_f_B_ragged() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 103}, 103))) == False{} : Bool}:
  P16_PRV.ComplexTestStruct_decode_vlit_bad_f_G_e1_f_B_ragged()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_G_e1_f_B_ragged_1() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 101}, 101))) == False{} : Bool}:
  P17_PRV.ComplexTestStruct_decode_vlit_bad_f_G_e1_f_B_ragged_1()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_G_e1_off_minus() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 100663296), 100}, 100))) == False{} : Bool}:
  P18_PRV.ComplexTestStruct_decode_vlit_bad_f_G_e1_off_minus()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_f_G_e1_off_plus() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 134217728), 101}, 101))) == False{} : Bool}:
  P19_PRV.ComplexTestStruct_decode_vlit_bad_f_G_e1_off_plus()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_off_minus() -> {P20_PRV.some1(Pair.snd(P20_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4587520), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))) == False{} : Bool}:
  P20_PRV.ComplexTestStruct_decode_vlit_bad_off_minus()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_off_plus() -> {P21_PRV.some1(Pair.snd(P21_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4718592), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 101}, 101))) == False{} : Bool}:
  P21_PRV.ComplexTestStruct_decode_vlit_bad_off_plus()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_order_f_D() -> {P22_PRV.some1(Pair.snd(P22_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1174405120), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))) == False{} : Bool}:
  P22_PRV.ComplexTestStruct_decode_vlit_bad_order_f_D()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_order_f_E() -> {P23_PRV.some1(Pair.snd(P23_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1174405120), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))) == False{} : Bool}:
  P23_PRV.ComplexTestStruct_decode_vlit_bad_order_f_E()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_bad_order_f_G() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1174405120), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))) == False{} : Bool}:
  P24_PRV.ComplexTestStruct_decode_vlit_bad_order_f_G()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_ok_all() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1224736768), 2, 1241513984), 16, 1358954496), 18, 1792), 19, 7), 20, 2048), 21, 3840), 22, 117440512), 24, 458752), 103}, 103))) == True{} : Bool}:
  P25_PRV.ComplexTestStruct_decode_vlit_ok_all()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_ok_default() -> {P26_PRV.some1(Pair.snd(P26_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P26_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))) == True{} : Bool}:
  P26_PRV.ComplexTestStruct_decode_vlit_ok_default()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_ok_f_B_n1() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1224736768), 2, 1224736768), 16, 1342177280), 18, 117440512), 20, 8), 21, 15), 22, 458752), 24, 1792), 102}, 102))) == True{} : Bool}:
  P27_PRV.ComplexTestStruct_decode_vlit_ok_f_B_n1()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_ok_f_B_n2() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1258291200), 2, 1258291200), 16, 1375731712), 19, 1792), 20, 524288), 21, 983040), 23, 7), 24, 117440512), 104}, 104))) == True{} : Bool}:
  P28_PRV.ComplexTestStruct_decode_vlit_ok_f_B_n2()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_ok_f_D_n1() -> {P29_PRV.some1(Pair.snd(P29_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P29_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1207959552), 16, 1325400064), 17, 117440512), 18, 458752), 19, 134217728), 20, 251658240), 22, 1792), 24, 7), 101}, 101))) == True{} : Bool}:
  P29_PRV.ComplexTestStruct_decode_vlit_ok_f_D_n1()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_ok_marked() -> {P30_PRV.some1(Pair.snd(P30_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P30_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1258291200), 2, 1275068416), 16, 1392508928), 18, 117440512), 19, 458752), 20, 134217728), 21, 251658240), 23, 1792), 25, 7), 105}, 105))) == True{} : Bool}:
  P30_PRV.ComplexTestStruct_decode_vlit_ok_marked()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_rt_all() -> {(Pair.snd(P31_B.Buf, U32, P31_B.size(P31_PRV.rt(Pair.snd(P31_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P31_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1224736768), 2, 1241513984), 16, 1358954496), 18, 1792), 19, 7), 20, 2048), 21, 3840), 22, 117440512), 24, 458752), 103}, 103))))), P31_PRV.rw26(P31_PRV.rt(Pair.snd(P31_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P31_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1224736768), 2, 1241513984), 16, 1358954496), 18, 1792), 19, 7), 20, 2048), 21, 3840), 22, 117440512), 24, 458752), 103}, 103))), 0)) == (103, (4653056, (1224736768, (1241513984, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (1358954496, (0, (1792, (7, (2048, (3840, (117440512, (0, (458752, 0)))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))}:
  P31_PRV.ComplexTestStruct_decode_vlit_rt_all()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_rt_default() -> {(Pair.snd(P32_B.Buf, U32, P32_B.size(P32_PRV.rt(Pair.snd(P32_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P32_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))))), P32_PRV.rw25(P32_PRV.rt(Pair.snd(P32_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P32_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1191182336), 16, 1308622848), 18, 1792), 19, 524288), 20, 983040), 22, 7), 23, 117440512), 100}, 100))), 0)) == (100, (4653056, (1191182336, (1191182336, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (1308622848, (0, (1792, (524288, (983040, (0, (7, (117440512, 0))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))))))))))))))}:
  P32_PRV.ComplexTestStruct_decode_vlit_rt_default()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_rt_f_B_n1() -> {(Pair.snd(P33_B.Buf, U32, P33_B.size(P33_PRV.rt(Pair.snd(P33_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P33_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1224736768), 2, 1224736768), 16, 1342177280), 18, 117440512), 20, 8), 21, 15), 22, 458752), 24, 1792), 102}, 102))))), P33_PRV.rw26(P33_PRV.rt(Pair.snd(P33_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P33_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1224736768), 2, 1224736768), 16, 1342177280), 18, 117440512), 20, 8), 21, 15), 22, 458752), 24, 1792), 102}, 102))), 0)) == (102, (4653056, (1224736768, (1224736768, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (1342177280, (0, (117440512, (0, (8, (15, (458752, (0, (1792, 0)))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))}:
  P33_PRV.ComplexTestStruct_decode_vlit_rt_f_B_n1()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_rt_f_B_n2() -> {(Pair.snd(P34_B.Buf, U32, P34_B.size(P34_PRV.rt(Pair.snd(P34_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P34_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1258291200), 2, 1258291200), 16, 1375731712), 19, 1792), 20, 524288), 21, 983040), 23, 7), 24, 117440512), 104}, 104))))), P34_PRV.rw26(P34_PRV.rt(Pair.snd(P34_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P34_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1258291200), 2, 1258291200), 16, 1375731712), 19, 1792), 20, 524288), 21, 983040), 23, 7), 24, 117440512), 104}, 104))), 0)) == (104, (4653056, (1258291200, (1258291200, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (1375731712, (0, (0, (1792, (524288, (983040, (0, (7, (117440512, 0)))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))}:
  P34_PRV.ComplexTestStruct_decode_vlit_rt_f_B_n2()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_rt_f_D_n1() -> {(Pair.snd(P35_B.Buf, U32, P35_B.size(P35_PRV.rt(Pair.snd(P35_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P35_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1207959552), 16, 1325400064), 17, 117440512), 18, 458752), 19, 134217728), 20, 251658240), 22, 1792), 24, 7), 101}, 101))))), P35_PRV.rw26(P35_PRV.rt(Pair.snd(P35_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P35_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1191182336), 2, 1207959552), 16, 1325400064), 17, 117440512), 18, 458752), 19, 134217728), 20, 251658240), 22, 1792), 24, 7), 101}, 101))), 0)) == (101, (4653056, (1191182336, (1207959552, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (1325400064, (117440512, (458752, (134217728, (251658240, (0, (1792, (0, (7, 0)))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))}:
  P35_PRV.ComplexTestStruct_decode_vlit_rt_f_D_n1()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_vlit_rt_marked() -> {(Pair.snd(P36_B.Buf, U32, P36_B.size(P36_PRV.rt(Pair.snd(P36_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P36_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1258291200), 2, 1275068416), 16, 1392508928), 18, 117440512), 19, 458752), 20, 134217728), 21, 251658240), 23, 1792), 25, 7), 105}, 105))))), P36_PRV.rw27(P36_PRV.rt(Pair.snd(P36_B.Buf, Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>, ComplexTestStruct_r.ComplexTestStruct_decode(P36_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 5n, 0), 0, 4653056), 1, 1258291200), 2, 1275068416), 16, 1392508928), 18, 117440512), 19, 458752), 20, 134217728), 21, 251658240), 23, 1792), 25, 7), 105}, 105))), 0)) == (105, (4653056, (1258291200, (1275068416, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (1392508928, (0, (117440512, (458752, (134217728, (251658240, (0, (1792, (0, (7, 0))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))))))))))))))))}:
  P36_PRV.ComplexTestStruct_decode_vlit_rt_marked()

def ComplexTestStruct__decode_offsets__ComplexTestStruct_decode_build(buf: P37_B.Buf, +size: U32, b2: P37_B.Buf, e: {ComplexTestStruct_r.ComplexTestStruct_ok(buf, 0, size) == (b2, True{}) : P37_B.Buf & Bool}, hwin: {U32.is_le(size, P37_DWL.bsz(buf)) == True{} : Bool}) -> {ComplexTestStruct_r.ComplexTestStruct_decode(buf, size) == ComplexTestStruct_r.ComplexTestStruct_some(ComplexTestStruct_r.ComplexTestStruct_build(b2, size)) : P37_B.Buf & Maybe<&1, ComplexTestStruct_d.ComplexTestStruct>}:
  P37_PRV.ComplexTestStruct_decode_build(buf, size, b2, e, hwin)

