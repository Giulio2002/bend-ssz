import Base
import ../../src/buffer.bend as P0_B
import ../../types/bitlist_5_decode_ssz_generated.bend as bitlist_5_r
import ../../types/bitlist_6_decode_ssz_generated.bend as bitlist_6_r
import ../../types/BitsStruct_def_generated.bend as BitsStruct_d
import ../../types/BitsStruct_decode_ssz_generated.bend as BitsStruct_r
import ../slop/offsets/generic_BitsStruct_first_offset_generated.bend as P0_PRV
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
import ../obj/var_winx_BitsStruct_generated.bend as P1_W
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_BitsStruct_generated.bend as P1_DW_BitsStruct
import ../obj/var_codec_BitsStruct_generated.bend as P1_PRV
import ../../types/schema.bend as P2_S
import ../../spec/decoding_relation.bend as P2_Decoding
import ../compact/found_generated.bend as P2_FD
import ../compact/arith.bend as P2_A
import ../obj/vbuf.bend as P2_VB
import ../obj/generic_specs_generated.bend as P2_GS
import ../obj/var_codec_BitsStruct_generated.bend as P2_DC
import ../../proofs/decode_complete.bend as P2_DCO
import ../obj/var_codec_BitsStruct_unique_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/generic_BitsStruct_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_f_A_nodelim_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_f_A_over_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_f_B_pad_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_f_C_pad_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_f_D_nodelim_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_f_D_over_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_off_minus_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_off_plus_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_BitsStruct_decode_literal_bad_order_f_D_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_BitsStruct_decode_literal_count_at_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_BitsStruct_decode_literal_ok_all_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/generic_BitsStruct_decode_literal_ok_default_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/generic_BitsStruct_decode_literal_ok_f_A_n1_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/generic_BitsStruct_decode_literal_ok_f_D_n1_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/generic_BitsStruct_decode_literal_ok_fixed_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/generic_BitsStruct_decode_literal_ok_wide_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/generic_BitsStruct_decode_literal_rt_all_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/generic_BitsStruct_decode_literal_rt_default_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/generic_BitsStruct_decode_literal_rt_f_A_n1_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/generic_BitsStruct_decode_literal_rt_f_D_n1_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/generic_BitsStruct_decode_literal_rt_fixed_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/generic_BitsStruct_decode_literal_rt_wide_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../obj/decode_window_library_generated.bend as P26_DWL
import ../slop/offsets/BitsStruct_generated.bend as P26_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# BitsStruct: its decode_ssz laws in the object API's terms, each discharged by its proving law.

def BitsStruct__decode_first_offset__BitsStruct_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(11, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 0 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 11) == False{} : Bool}) -> {BitsStruct_r.BitsStruct_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.BitsStruct_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def BitsStruct__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}) -> {BitsStruct_r.BitsStruct_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, pf, hd, hn)

def BitsStruct__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {BitsStruct_r.BitsStruct_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(d, t, n)}) : P1_B.Buf & Maybe<&1, BitsStruct_d.BitsStruct>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def BitsStruct__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.BitsStruct(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def BitsStruct__decode_unique__decode_unique(+d: Nat, +t: P2_FD.array__Tree<U32>, +n: U32, +pf: {P2_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}, +v: P2_S.Value, spec: P2_Decoding.decodes(P2_GS.BitsStruct(), P2_DC.VW(t, n), v)) -> {v == P2_DC.VAL(t, n) : P2_S.Value}:
  P2_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def BitsStruct__decode_reject__decode_reject(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> P1_Decoding.outside_image(P1_Spec.BitsStruct(), P1_PRV.VW(t, n)):
  P1_PRV.decode_reject(d, t, n, pf, hd, hn, hchk)

def BitsStruct__decode_none__decode_none(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> {BitsStruct_r.BitsStruct_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), None{}) : P1_B.Buf & Maybe<&1, BitsStruct_d.BitsStruct>}:
  P1_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_limit()

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {BitsStruct_r.BitsStruct_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_nmax_wrap(buf)

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {BitsStruct_r.BitsStruct_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_nmax_above(buf)

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_nmax_at(buf: P3_B.Buf) -> {BitsStruct_r.BitsStruct_dchw(4294967264, 4294967264, (buf, 1073741816)) == BitsStruct_r.BitsStruct_dgo(True{}, buf, 4294967264) : P3_B.Buf & Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_nmax_at(buf)

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_at_2pow31(buf: P3_B.Buf) -> {BitsStruct_r.BitsStruct_dchw(2147483648, 2147483648, (buf, 536870912)) == BitsStruct_r.BitsStruct_dgo(True{}, buf, 2147483648) : P3_B.Buf & Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_at_2pow31(buf)

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_dchw(13, 13, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 4))), Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 13))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.BitsStruct_decode_vchecked_accept()

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_dchw(13, 12, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 4))) == None{} : Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_window()

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_dchw(13, 13, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 3))) == None{} : Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_storage()

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 12}, 13)) == None{} : Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_short()

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 11), 13}, 13)) == None{} : Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_real()

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_budget_agree(buf: P3_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(BitsStruct_r.BitsStruct_dcost(size), 4294967295), U32.is_le(BitsStruct_r.BitsStruct_dcost(size), budget)) == True{} : Bool}) -> {BitsStruct_r.BitsStruct_decode_checked_budget(buf, size, budget) == BitsStruct_r.BitsStruct_decode_checked(buf, size) : P3_B.Buf & Maybe<&1, BitsStruct_d.BitsStruct>}:
  P3_PRV.BitsStruct_decode_vchecked_budget_agree(buf, size, budget, h)

def BitsStruct__decode_offsets__BitsStruct_decode_vchecked_budget_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode_checked_budget(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 13, 4294967295)), Pair.snd(P3_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 13))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.BitsStruct_decode_vchecked_budget_accept()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_f_A_nodelim() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 3, 1), 13}, 13))) == False{} : Bool}:
  P4_PRV.BitsStruct_decode_vlit_bad_f_A_nodelim()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_f_A_over() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 1073741824), 3, 1), 13}, 13))) == False{} : Bool}:
  P5_PRV.BitsStruct_decode_vlit_bad_f_A_over()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_f_B_pad() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786436), 2, 16777216), 3, 1), 13}, 13))) == False{} : Bool}:
  P6_PRV.BitsStruct_decode_vlit_bad_f_B_pad()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_f_C_pad() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786944), 2, 16777216), 3, 1), 13}, 13))) == False{} : Bool}:
  P7_PRV.BitsStruct_decode_vlit_bad_f_C_pad()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_f_D_nodelim() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 13}, 13))) == False{} : Bool}:
  P8_PRV.BitsStruct_decode_vlit_bad_f_D_nodelim()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_f_D_over() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 128), 13}, 13))) == False{} : Bool}:
  P9_PRV.BitsStruct_decode_vlit_bad_f_D_over()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_off_minus() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 10), 1, 786432), 2, 16777216), 3, 1), 13}, 13))) == False{} : Bool}:
  P10_PRV.BitsStruct_decode_vlit_bad_off_minus()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_off_plus() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 12), 1, 786432), 2, 16777216), 3, 1), 14}, 14))) == False{} : Bool}:
  P11_PRV.BitsStruct_decode_vlit_bad_off_plus()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_bad_order_f_D() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 655360), 2, 16777216), 3, 1), 13}, 13))) == False{} : Bool}:
  P12_PRV.BitsStruct_decode_vlit_bad_order_f_D()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_count_at_bits5(buf: P13_B.Buf, +off: U32, hb: {P13_B.byte_at(buf, (off + 1 - 1 : U32)) == (buf, 32) : P13_B.Buf & U32}) -> {bitlist_5_r.bits5_ok(buf, off, 1) == (buf, True{}) : P13_B.Buf & Bool}:
  P13_PRV.BitsStruct_decode_vlit_count_at_bits5(buf, off, hb)

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_count_over_bits5(buf: P13_B.Buf, +off: U32, hb: {P13_B.byte_at(buf, (off + 1 - 1 : U32)) == (buf, 64) : P13_B.Buf & U32}) -> {bitlist_5_r.bits5_ok(buf, off, 1) == (buf, False{}) : P13_B.Buf & Bool}:
  P13_PRV.BitsStruct_decode_vlit_count_over_bits5(buf, off, hb)

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_count_at_bits6(buf: P13_B.Buf, +off: U32, hb: {P13_B.byte_at(buf, (off + 1 - 1 : U32)) == (buf, 64) : P13_B.Buf & U32}) -> {bitlist_6_r.bits6_ok(buf, off, 1) == (buf, True{}) : P13_B.Buf & Bool}:
  P13_PRV.BitsStruct_decode_vlit_count_at_bits6(buf, off, hb)

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_count_over_bits6(buf: P13_B.Buf, +off: U32, hb: {P13_B.byte_at(buf, (off + 1 - 1 : U32)) == (buf, 128) : P13_B.Buf & U32}) -> {bitlist_6_r.bits6_ok(buf, off, 1) == (buf, False{}) : P13_B.Buf & Bool}:
  P13_PRV.BitsStruct_decode_vlit_count_over_bits6(buf, off, hb)

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_ok_all() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 50331648), 3, 3), 13}, 13))) == True{} : Bool}:
  P14_PRV.BitsStruct_decode_vlit_ok_all()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_ok_default() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 13))) == True{} : Bool}:
  P15_PRV.BitsStruct_decode_vlit_ok_default()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_ok_f_A_n1() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 50331648), 3, 1), 13}, 13))) == True{} : Bool}:
  P16_PRV.BitsStruct_decode_vlit_ok_f_A_n1()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_ok_f_D_n1() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 3), 13}, 13))) == True{} : Bool}:
  P17_PRV.BitsStruct_decode_vlit_ok_f_D_n1()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_ok_fixed() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786433), 2, 16777216), 3, 1), 13}, 13))) == True{} : Bool}:
  P18_PRV.BitsStruct_decode_vlit_ok_fixed()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_ok_wide() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786433), 2, 889192448), 3, 53), 13}, 13))) == True{} : Bool}:
  P19_PRV.BitsStruct_decode_vlit_ok_wide()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_rt_all() -> {(Pair.snd(P20_B.Buf, U32, P20_B.size(P20_PRV.rt(Pair.snd(P20_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 50331648), 3, 3), 13}, 13))))), P20_PRV.rw4(P20_PRV.rt(Pair.snd(P20_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 50331648), 3, 3), 13}, 13))), 0)) == (13, (11, (786432, (50331648, 3)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P20_PRV.BitsStruct_decode_vlit_rt_all()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_rt_default() -> {(Pair.snd(P21_B.Buf, U32, P21_B.size(P21_PRV.rt(Pair.snd(P21_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 13))))), P21_PRV.rw4(P21_PRV.rt(Pair.snd(P21_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 1), 13}, 13))), 0)) == (13, (11, (786432, (16777216, 1)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P21_PRV.BitsStruct_decode_vlit_rt_default()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_rt_f_A_n1() -> {(Pair.snd(P22_B.Buf, U32, P22_B.size(P22_PRV.rt(Pair.snd(P22_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 50331648), 3, 1), 13}, 13))))), P22_PRV.rw4(P22_PRV.rt(Pair.snd(P22_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 50331648), 3, 1), 13}, 13))), 0)) == (13, (11, (786432, (50331648, 1)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P22_PRV.BitsStruct_decode_vlit_rt_f_A_n1()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_rt_f_D_n1() -> {(Pair.snd(P23_B.Buf, U32, P23_B.size(P23_PRV.rt(Pair.snd(P23_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 3), 13}, 13))))), P23_PRV.rw4(P23_PRV.rt(Pair.snd(P23_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786432), 2, 16777216), 3, 3), 13}, 13))), 0)) == (13, (11, (786432, (16777216, 3)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P23_PRV.BitsStruct_decode_vlit_rt_f_D_n1()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_rt_fixed() -> {P24_PRV.rtc4(P24_PRV.rt(Pair.snd(P24_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786433), 2, 16777216), 3, 1), 13}, 13)))) == (13, (11, (786433, (16777216, 1)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P24_PRV.BitsStruct_decode_vlit_rt_fixed()

def BitsStruct__decode_offsets__BitsStruct_decode_vlit_rt_wide() -> {P25_PRV.rtc4(P25_PRV.rt(Pair.snd(P25_B.Buf, Maybe<&1, BitsStruct_d.BitsStruct>, BitsStruct_r.BitsStruct_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 11), 1, 786433), 2, 889192448), 3, 53), 13}, 13)))) == (13, (11, (786433, (889192448, 53)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P25_PRV.BitsStruct_decode_vlit_rt_wide()

def BitsStruct__decode_offsets__BitsStruct_decode_build(buf: P26_B.Buf, +size: U32, b2: P26_B.Buf, e: {BitsStruct_r.BitsStruct_ok(buf, 0, size) == (b2, True{}) : P26_B.Buf & Bool}, hwin: {U32.is_le(size, P26_DWL.bsz(buf)) == True{} : Bool}) -> {BitsStruct_r.BitsStruct_decode(buf, size) == BitsStruct_r.BitsStruct_some(BitsStruct_r.BitsStruct_build(b2, size)) : P26_B.Buf & Maybe<&1, BitsStruct_d.BitsStruct>}:
  P26_PRV.BitsStruct_decode_build(buf, size, b2, e, hwin)

