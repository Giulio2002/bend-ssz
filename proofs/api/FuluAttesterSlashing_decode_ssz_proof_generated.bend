import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/FuluAttesterSlashing_def_generated.bend as FuluAttesterSlashing_d
import ../../types/FuluAttesterSlashing_decode_ssz_generated.bend as FuluAttesterSlashing_r
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
import ../../spec/fulu_schemas.bend as P0_Spec
import ../obj/spec_fixed.bend as P0_F
import ../obj/vspec.bend as P0_VS
import ../obj/vbuf.bend as P0_VB
import ../obj/vu32.bend as P0_VU
import ../obj/vcopy.bend as P0_VC
import ../obj/vdepth.bend as P0_VD
import ../obj/vfix.bend as P0_VF
import ../obj/var_fix_types_generated.bend as P0_VT
import ../obj/var_codec_IndexedAttestation_generated.bend as P0_DC
import ../obj/var_codec_IndexedAttestation_win_generated.bend as P0_W
import ../obj/vdig.bend as P0_VG
import ../obj/vfits.bend as P0_VFT
import ../../src/primitives.bend as P0_I
import ../../proofs/obj/decode_window_library_generated.bend as P0_DWL
import ../../proofs/obj/decode_window_FuluAttesterSlashing_generated.bend as P0_DW_FuluAttesterSlashing
import ../obj/var_codec_AttesterSlashing_generated.bend as P0_PRV
import ../../types/schema.bend as P1_S
import ../../spec/decoding_relation.bend as P1_Decoding
import ../../spec/fulu_schemas.bend as P1_Spec
import ../compact/found_generated.bend as P1_F
import ../compact/arith.bend as P1_A
import ../obj/vbuf.bend as P1_VB
import ../obj/var_codec_AttesterSlashing_generated.bend as P1_DC
import ../../proofs/decode_unique.bend as P1_DCO
import ../obj/var_codec_AttesterSlashing_unique_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/obj.bend as P2_O
import ../../types/schema.bend as P2_S
import ../../types/primitive.bend as P2_P
import ../compact/found_generated.bend as P2_FD
import ../compact/arith.bend as P2_A
import ../../proofs/nat_order.bend as P2_Order
import ../../spec/primitives.bend as P2_SP
import ../../spec/layout.bend as P2_Layout
import ../../spec/codec.bend as P2_Codec
import ../../spec/decoding_relation.bend as P2_Decoding
import ../../spec/nat_bytes.bend as P2_N
import ../../spec/fulu_schemas.bend as P2_Spec
import ../obj/spec_fixed.bend as P2_F
import ../obj/vspec.bend as P2_VS
import ../obj/vbuf.bend as P2_VB
import ../obj/vu32.bend as P2_VU
import ../obj/vcopy.bend as P2_VC
import ../obj/vdepth.bend as P2_VD
import ../obj/vfix.bend as P2_VF
import ../obj/var_fix_types_generated.bend as P2_VT
import ../obj/var_codec_IndexedAttestation_generated.bend as P2_DC
import ../obj/var_codec_IndexedAttestation_win_generated.bend as P2_W
import ../obj/var_codec_IndexedAttestation_rej_generated.bend as P2_R
import ../obj/var_codec_AttesterSlashing_generated.bend as P2_M
import ../obj/vdig.bend as P2_VG
import ../obj/vfits.bend as P2_VFT
import ../obj/vnest.bend as P2_VN
import ../../proofs/decode_shape.bend as P2_DS
import ../../proofs/decode_facts.bend as P2_DF
import ../obj/var_codec_AttesterSlashing_rej_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_AttesterSlashing_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_1_attesting_indices_ragged_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_1_attesting_indices_ragged_1_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_1_attesting_indices_ragged_10_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_1_attesting_indices_ragged_2_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_1_attesting_indices_ragged_4_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_1_attesting_indices_ragged_7_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_1_off_minus_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_1_off_plus_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_2_attesting_indices_ragged_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_2_attesting_indices_ragged_1_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_2_attesting_indices_ragged_10_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_2_attesting_indices_ragged_2_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_2_attesting_indices_ragged_4_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_2_attesting_indices_ragged_7_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_2_off_minus_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_attestation_2_off_plus_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_off_minus_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_off_plus_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_bad_order_attestation_2_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_ok_all_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_ok_attestation_1_marked_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_ok_attestation_2_marked_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_ok_default_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_ok_fixed_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_ok_wide_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_rt_fixed_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_AttesterSlashing_decode_literal_rt_wide_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/obj.bend as P31_O
import ../obj/decode_window_library_generated.bend as P31_DWL
import ../slop/offsets/AttesterSlashing_generated.bend as P31_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluAttesterSlashing (AttesterSlashing): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluAttesterSlashing__ok_eval__ok_eval(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}) -> {FuluAttesterSlashing_r.AttesterSlashing_ok(P0_DC.BF(t, n), 0, n) == (P0_DC.BF(t, n), P0_PRV.CHK(t, n)) : P0_B.Buf & Bool}:
  P0_PRV.ok_eval(d, t, n, pf, hd, hn)

def FuluAttesterSlashing__decode_accept__decode_accept(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> {FuluAttesterSlashing_r.AttesterSlashing_decode(P0_DC.BF(t, n), n) == (P0_DC.BF(t, n), Some{P0_PRV.OBJ(t, n)}) : P0_B.Buf & Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P0_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def FuluAttesterSlashing__decode_spec__decode_spec(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.AttesterSlashing(), P0_PRV.VW(t, n), P0_PRV.VAL(t, n)):
  P0_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def FuluAttesterSlashing__decode_unique__decode_unique(+d: Nat, +t: P1_F.array__Tree<U32>, +n: U32, +pf: {P1_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_DC.CHK(t, n) == True{} : Bool}, +v: P1_S.Value, spec: P1_Decoding.decodes(P1_Spec.AttesterSlashing(), P1_DC.VW(t, n), v)) -> {v == P1_DC.VAL(t, n) : P1_S.Value}:
  P1_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def FuluAttesterSlashing__decode_reject__decode_reject(+d: Nat, +t: P2_FD.array__Tree<U32>, +n: U32, +pf: {P2_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_M.CHK(t, n) == False{} : Bool}) -> P2_Decoding.outside_image(P2_Spec.AttesterSlashing(), P2_M.VW(t, n)):
  P2_PRV.decode_reject(d, t, n, pf, hd, hn, hchk)

def FuluAttesterSlashing__decode_none__decode_none(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == False{} : Bool}) -> {FuluAttesterSlashing_r.AttesterSlashing_decode(P0_DC.BF(t, n), n) == (P0_DC.BF(t, n), None{}) : P0_B.Buf & Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P0_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P3_PRV.AttesterSlashing_decode_vchecked_limit()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {FuluAttesterSlashing_r.AttesterSlashing_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P3_PRV.AttesterSlashing_decode_vchecked_nmax_wrap(buf)

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {FuluAttesterSlashing_r.AttesterSlashing_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P3_PRV.AttesterSlashing_decode_vchecked_nmax_above(buf)

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_dchw(464, 464, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 464}, 116))), Pair.snd(P3_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 464}, 464))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.AttesterSlashing_decode_vchecked_accept()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_dchw(464, 463, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 464}, 116))) == None{} : Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P3_PRV.AttesterSlashing_decode_vchecked_window()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_dchw(464, 464, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 464}, 115))) == None{} : Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P3_PRV.AttesterSlashing_decode_vchecked_storage()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 463}, 464)) == None{} : Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P3_PRV.AttesterSlashing_decode_vchecked_short()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 8), 464}, 464)) == None{} : Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P3_PRV.AttesterSlashing_decode_vchecked_real()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 245), 2, 228), 61, 58368), 473}, 473))) == False{} : Bool}:
  P4_PRV.AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_1() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 237), 2, 228), 59, 58368), 465}, 465))) == False{} : Bool}:
  P5_PRV.AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_1()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_10() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 246), 2, 228), 61, 14942208), 474}, 474))) == False{} : Bool}:
  P6_PRV.AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_10()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_2() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 238), 2, 228), 59, 14942208), 466}, 466))) == False{} : Bool}:
  P7_PRV.AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_2()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_4() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 240), 2, 228), 60, 228), 468}, 468))) == False{} : Bool}:
  P8_PRV.AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_4()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_7() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 243), 2, 228), 60, 3825205248), 471}, 471))) == False{} : Bool}:
  P9_PRV.AttesterSlashing_decode_vlit_bad_attestation_1_attesting_indices_ragged_7()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_1_off_minus() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 227), 59, 228), 464}, 464))) == False{} : Bool}:
  P10_PRV.AttesterSlashing_decode_vlit_bad_attestation_1_off_minus()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_1_off_plus() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 237), 2, 229), 59, 58368), 465}, 465))) == False{} : Bool}:
  P11_PRV.AttesterSlashing_decode_vlit_bad_attestation_1_off_plus()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 473}, 473))) == False{} : Bool}:
  P12_PRV.AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_1() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 465}, 465))) == False{} : Bool}:
  P13_PRV.AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_1()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_10() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 474}, 474))) == False{} : Bool}:
  P14_PRV.AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_10()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_2() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 466}, 466))) == False{} : Bool}:
  P15_PRV.AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_2()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_4() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 468}, 468))) == False{} : Bool}:
  P16_PRV.AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_4()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_7() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 471}, 471))) == False{} : Bool}:
  P17_PRV.AttesterSlashing_decode_vlit_bad_attestation_2_attesting_indices_ragged_7()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_2_off_minus() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 227), 464}, 464))) == False{} : Bool}:
  P18_PRV.AttesterSlashing_decode_vlit_bad_attestation_2_off_minus()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_attestation_2_off_plus() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 229), 465}, 465))) == False{} : Bool}:
  P19_PRV.AttesterSlashing_decode_vlit_bad_attestation_2_off_plus()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_off_minus() -> {P20_PRV.some1(Pair.snd(P20_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 7), 1, 236), 2, 228), 59, 228), 464}, 464))) == False{} : Bool}:
  P20_PRV.AttesterSlashing_decode_vlit_bad_off_minus()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_off_plus() -> {P21_PRV.some1(Pair.snd(P21_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 9), 1, 236), 2, 228), 59, 228), 465}, 465))) == False{} : Bool}:
  P21_PRV.AttesterSlashing_decode_vlit_bad_off_plus()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_bad_order_attestation_2() -> {P22_PRV.some1(Pair.snd(P22_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 7), 2, 228), 59, 228), 464}, 464))) == False{} : Bool}:
  P22_PRV.AttesterSlashing_decode_vlit_bad_order_attestation_2()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_ok_all() -> {P23_PRV.some1(Pair.snd(P23_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 252), 2, 228), 59, 4), 61, 4), 63, 228), 120, 4), 122, 4), 496}, 496))) == True{} : Bool}:
  P23_PRV.AttesterSlashing_decode_vlit_ok_all()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_ok_attestation_1_marked() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 252), 2, 228), 59, 4), 61, 4), 63, 228), 480}, 480))) == True{} : Bool}:
  P24_PRV.AttesterSlashing_decode_vlit_ok_attestation_1_marked()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_ok_attestation_2_marked() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 116, 4), 118, 4), 480}, 480))) == True{} : Bool}:
  P25_PRV.AttesterSlashing_decode_vlit_ok_attestation_2_marked()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_ok_default() -> {P26_PRV.some1(Pair.snd(P26_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P26_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 59, 228), 464}, 464))) == True{} : Bool}:
  P26_PRV.AttesterSlashing_decode_vlit_ok_default()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_ok_fixed() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 3, 4), 4, 5), 5, 6), 6, 7), 7, 8), 8, 9), 9, 10), 10, 11), 11, 12), 12, 13), 13, 14), 14, 15), 15, 16), 16, 17), 17, 18), 18, 19), 19, 20), 20, 21), 21, 22), 22, 23), 23, 24), 24, 25), 25, 26), 26, 27), 27, 28), 28, 29), 29, 30), 30, 31), 31, 32), 32, 33), 33, 34), 34, 35), 35, 36), 36, 37), 37, 38), 38, 39), 39, 40), 40, 41), 41, 42), 42, 43), 43, 44), 44, 45), 45, 46), 46, 47), 47, 48), 48, 49), 49, 50), 50, 51), 51, 52), 52, 53), 53, 54), 54, 55), 55, 56), 56, 57), 57, 58), 58, 59), 59, 228), 60, 60), 61, 61), 62, 62), 63, 63), 64, 64), 65, 65), 66, 66), 67, 67), 68, 68), 69, 69), 70, 70), 71, 71), 72, 72), 73, 73), 74, 74), 75, 75), 76, 76), 77, 77), 78, 78), 79, 79), 80, 80), 81, 81), 82, 82), 83, 83), 84, 84), 85, 85), 86, 86), 87, 87), 88, 88), 89, 89), 90, 90), 91, 91), 92, 92), 93, 93), 94, 94), 95, 95), 96, 96), 97, 97), 98, 98), 99, 99), 100, 100), 101, 101), 102, 102), 103, 103), 104, 104), 105, 105), 106, 106), 107, 107), 108, 108), 109, 109), 110, 110), 111, 111), 112, 112), 113, 113), 114, 114), 115, 115), 464}, 464))) == True{} : Bool}:
  P27_PRV.AttesterSlashing_decode_vlit_ok_fixed()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_ok_wide() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 252), 2, 228), 3, 8), 4, 9), 5, 10), 6, 11), 7, 12), 8, 13), 9, 14), 10, 15), 11, 16), 12, 17), 13, 18), 14, 19), 15, 20), 16, 21), 17, 22), 18, 23), 19, 24), 20, 25), 21, 26), 22, 27), 23, 28), 24, 29), 25, 30), 26, 31), 27, 32), 28, 33), 29, 34), 30, 35), 31, 36), 32, 37), 33, 38), 34, 39), 35, 40), 36, 41), 37, 42), 38, 43), 39, 44), 40, 45), 41, 46), 42, 47), 43, 48), 44, 49), 45, 50), 46, 51), 47, 52), 48, 53), 49, 54), 50, 55), 51, 56), 52, 57), 53, 58), 54, 59), 55, 60), 56, 61), 57, 62), 58, 63), 59, 4), 60, 5), 61, 6), 62, 7), 63, 228), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 113), 110, 114), 111, 115), 112, 116), 113, 117), 114, 118), 115, 119), 116, 120), 117, 121), 118, 122), 119, 123), 120, 4), 121, 65), 122, 66), 123, 67), 496}, 496))) == True{} : Bool}:
  P28_PRV.AttesterSlashing_decode_vlit_ok_wide()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_rt_fixed() -> {P29_PRV.rtc116(P29_PRV.rt(Pair.snd(P29_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P29_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 236), 2, 228), 3, 4), 4, 5), 5, 6), 6, 7), 7, 8), 8, 9), 9, 10), 10, 11), 11, 12), 12, 13), 13, 14), 14, 15), 15, 16), 16, 17), 17, 18), 18, 19), 19, 20), 20, 21), 21, 22), 22, 23), 23, 24), 24, 25), 25, 26), 26, 27), 27, 28), 28, 29), 29, 30), 30, 31), 31, 32), 32, 33), 33, 34), 34, 35), 35, 36), 36, 37), 37, 38), 38, 39), 39, 40), 40, 41), 41, 42), 42, 43), 43, 44), 44, 45), 45, 46), 46, 47), 47, 48), 48, 49), 49, 50), 50, 51), 51, 52), 52, 53), 53, 54), 54, 55), 55, 56), 56, 57), 57, 58), 58, 59), 59, 228), 60, 60), 61, 61), 62, 62), 63, 63), 64, 64), 65, 65), 66, 66), 67, 67), 68, 68), 69, 69), 70, 70), 71, 71), 72, 72), 73, 73), 74, 74), 75, 75), 76, 76), 77, 77), 78, 78), 79, 79), 80, 80), 81, 81), 82, 82), 83, 83), 84, 84), 85, 85), 86, 86), 87, 87), 88, 88), 89, 89), 90, 90), 91, 91), 92, 92), 93, 93), 94, 94), 95, 95), 96, 96), 97, 97), 98, 98), 99, 99), 100, 100), 101, 101), 102, 102), 103, 103), 104, 104), 105, 105), 106, 106), 107, 107), 108, 108), 109, 109), 110, 110), 111, 111), 112, 112), 113, 113), 114, 114), 115, 115), 464}, 464)))) == (464, (8, (236, (228, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (228, (60, (61, (62, (63, (64, (65, (66, (67, (68, (69, (70, (71, (72, (73, (74, (75, (76, (77, (78, (79, (80, (81, (82, (83, (84, (85, (86, (87, (88, (89, (90, (91, (92, (93, (94, (95, (96, (97, (98, (99, (100, (101, (102, (103, (104, (105, (106, (107, (108, (109, (110, (111, (112, (113, (114, 115)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P29_PRV.AttesterSlashing_decode_vlit_rt_fixed()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_vlit_rt_wide() -> {P30_PRV.rtc124(P30_PRV.rt(Pair.snd(P30_B.Buf, Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>, FuluAttesterSlashing_r.AttesterSlashing_decode(P30_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 8), 1, 252), 2, 228), 3, 8), 4, 9), 5, 10), 6, 11), 7, 12), 8, 13), 9, 14), 10, 15), 11, 16), 12, 17), 13, 18), 14, 19), 15, 20), 16, 21), 17, 22), 18, 23), 19, 24), 20, 25), 21, 26), 22, 27), 23, 28), 24, 29), 25, 30), 26, 31), 27, 32), 28, 33), 29, 34), 30, 35), 31, 36), 32, 37), 33, 38), 34, 39), 35, 40), 36, 41), 37, 42), 38, 43), 39, 44), 40, 45), 41, 46), 42, 47), 43, 48), 44, 49), 45, 50), 46, 51), 47, 52), 48, 53), 49, 54), 50, 55), 51, 56), 52, 57), 53, 58), 54, 59), 55, 60), 56, 61), 57, 62), 58, 63), 59, 4), 60, 5), 61, 6), 62, 7), 63, 228), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 113), 110, 114), 111, 115), 112, 116), 113, 117), 114, 118), 115, 119), 116, 120), 117, 121), 118, 122), 119, 123), 120, 4), 121, 65), 122, 66), 123, 67), 496}, 496)))) == (496, (8, (252, (228, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (60, (61, (62, (63, (4, (5, (6, (7, (228, (68, (69, (70, (71, (72, (73, (74, (75, (76, (77, (78, (79, (80, (81, (82, (83, (84, (85, (86, (87, (88, (89, (90, (91, (92, (93, (94, (95, (96, (97, (98, (99, (100, (101, (102, (103, (104, (105, (106, (107, (108, (109, (110, (111, (112, (113, (114, (115, (116, (117, (118, (119, (120, (121, (122, (123, (4, (65, (66, 67)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P30_PRV.AttesterSlashing_decode_vlit_rt_wide()

def FuluAttesterSlashing__decode_offsets__AttesterSlashing_decode_build(buf: P31_B.Buf, +size: U32, b2: P31_B.Buf, e: {FuluAttesterSlashing_r.AttesterSlashing_ok(buf, 0, size) == (b2, True{}) : P31_B.Buf & Bool}, hwin: {U32.is_le(size, P31_DWL.bsz(buf)) == True{} : Bool}) -> {FuluAttesterSlashing_r.AttesterSlashing_decode(buf, size) == FuluAttesterSlashing_r.AttesterSlashing_some(FuluAttesterSlashing_r.AttesterSlashing_build(b2, size)) : P31_B.Buf & Maybe<&1, FuluAttesterSlashing_d.AttesterSlashing>}:
  P31_PRV.AttesterSlashing_decode_build(buf, size, b2, e, hwin)

