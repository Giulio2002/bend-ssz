import Base
import ../../src/buffer.bend as P0_B
import ../../types/Fulu_list_uint64_131072_decode_ssz_generated.bend as Fulu_list_uint64_131072_r
import ../../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
import ../../types/FuluIndexedAttestation_decode_ssz_generated.bend as FuluIndexedAttestation_r
import ../slop/offsets/fulu_IndexedAttestation_first_offset_generated.bend as P0_PRV
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
import ../../spec/fulu_schemas.bend as P1_Spec
import ../obj/spec_fixed.bend as P1_F
import ../obj/vspec.bend as P1_VS
import ../obj/vbuf.bend as P1_VB
import ../obj/vu32.bend as P1_VU
import ../obj/vcopy.bend as P1_VC
import ../obj/vdepth.bend as P1_VD
import ../obj/vfix.bend as P1_VF
import ../obj/var_fix_types_generated.bend as P1_VT
import ../obj/vbig.bend as P1_VBG
import ../../spec/schema.bend as P1_SC
import ../obj/vseq.bend as P1_VSQ
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_FuluIndexedAttestation_generated.bend as P1_DW_FuluIndexedAttestation
import ../obj/var_codec_IndexedAttestation_generated.bend as P1_PRV
import ../../types/schema.bend as P2_S
import ../../spec/decoding_relation.bend as P2_Decoding
import ../../spec/fulu_schemas.bend as P2_Spec
import ../compact/found_generated.bend as P2_F
import ../compact/arith.bend as P2_A
import ../obj/vbuf.bend as P2_VB
import ../obj/var_codec_IndexedAttestation_generated.bend as P2_DC
import ../../proofs/decode_unique.bend as P2_DCO
import ../obj/var_codec_IndexedAttestation_unique_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../../types/schema.bend as P3_S
import ../../types/primitive.bend as P3_P
import ../compact/found_generated.bend as P3_F
import ../compact/arith.bend as P3_A
import ../compact/bits_generated.bend as P3_BT
import ../../proofs/nat_order.bend as P3_Order
import ../../spec/primitives.bend as P3_SP
import ../../spec/layout.bend as P3_Layout
import ../../spec/codec.bend as P3_Codec
import ../../spec/decoding_relation.bend as P3_Decoding
import ../../spec/nat_bytes.bend as P3_N
import ../../spec/fulu_schemas.bend as P3_Spec
import ../../proofs/decode_shape.bend as P3_DS
import ../../proofs/decode_facts.bend as P3_DF
import ../obj/spec_fixed.bend as P3_FX
import ../obj/dk.bend as P3_DK
import ../obj/vspec.bend as P3_VS
import ../obj/vbuf.bend as P3_VB
import ../obj/vu32.bend as P3_VU
import ../obj/vcopy.bend as P3_VC
import ../obj/vrej.bend as P3_VR
import ../obj/var_codec_IndexedAttestation_generated.bend as P3_DC
import ../../proofs/obj/decode_window_library_generated.bend as P3_DWL
import ../../proofs/obj/decode_window_FuluIndexedAttestation_generated.bend as P3_DW_FuluIndexedAttestation
import ../obj/var_codec_IndexedAttestation_rej_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_IndexedAttestation_decode_checked_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_bad_attesting_indices_ragged_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_bad_attesting_indices_ragged_1_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_bad_attesting_indices_ragged_10_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_bad_attesting_indices_ragged_2_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_bad_attesting_indices_ragged_4_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_bad_attesting_indices_ragged_7_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_bad_off_minus_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_bad_off_plus_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_count_at_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_ok_attesting_indices_n1_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_ok_attesting_indices_n2_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_ok_default_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_ok_fixed_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_ok_marked_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_ok_wide_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_rt_fixed_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_IndexedAttestation_decode_literal_rt_wide_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../obj/decode_window_library_generated.bend as P22_DWL
import ../slop/offsets/IndexedAttestation_generated.bend as P22_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluIndexedAttestation (IndexedAttestation): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluIndexedAttestation__decode_first_offset__IndexedAttestation_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(228, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 0 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 228) == False{} : Bool}) -> {FuluIndexedAttestation_r.IndexedAttestation_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.IndexedAttestation_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def FuluIndexedAttestation__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(0n, P1_VB.pw(d)) == True{} : Bool}, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}) -> {FuluIndexedAttestation_r.IndexedAttestation_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, hd, hpo, pf)

def FuluIndexedAttestation__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {FuluIndexedAttestation_r.IndexedAttestation_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(t, n)}) : P1_B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def FuluIndexedAttestation__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.IndexedAttestation(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def FuluIndexedAttestation__decode_unique__decode_unique(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}, +v: P2_S.Value, spec: P2_Decoding.decodes(P2_Spec.IndexedAttestation(), P2_DC.VW(t, n), v)) -> {v == P2_DC.VAL(t, n) : P2_S.Value}:
  P2_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def FuluIndexedAttestation__decode_reject__decode_reject(+d: Nat, +t: P3_F.array__Tree<U32>, +n: U32, +pf: {P3_F.array__perfect(U32, d, t) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P3_A.quad(P3_VB.pw(d))) == True{} : Bool}, +hchk: {P3_DC.CHK(t, n) == False{} : Bool}) -> P3_Decoding.outside_image(P3_Spec.IndexedAttestation(), P3_DC.VW(t, n)):
  P3_PRV.decode_reject(d, t, n, pf, hn, hchk)

def FuluIndexedAttestation__decode_none__decode_none(+d: Nat, +t: P3_F.array__Tree<U32>, +n: U32, +pf: {P3_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P3_A.quad(P3_VB.pw(d))) == True{} : Bool}, +hchk: {P3_DC.CHK(t, n) == False{} : Bool}) -> {FuluIndexedAttestation_r.IndexedAttestation_decode(P3_DC.BF(t, n), n) == (P3_DC.BF(t, n), None{}) : P3_B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P3_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_limit() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_dchw(4294967265, 4294967265, (P4_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_limit()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_nmax_wrap(buf: P4_B.Buf) -> {FuluIndexedAttestation_r.IndexedAttestation_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P4_B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_nmax_wrap(buf)

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_nmax_above(buf: P4_B.Buf) -> {FuluIndexedAttestation_r.IndexedAttestation_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P4_B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_nmax_above(buf)

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_nmax_at(buf: P4_B.Buf) -> {FuluIndexedAttestation_r.IndexedAttestation_dchw(4294967264, 4294967264, (buf, 1073741816)) == FuluIndexedAttestation_r.IndexedAttestation_dgo(True{}, buf, 4294967264) : P4_B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_nmax_at(buf)

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_at_2pow31(buf: P4_B.Buf) -> {FuluIndexedAttestation_r.IndexedAttestation_dchw(2147483648, 2147483648, (buf, 536870912)) == FuluIndexedAttestation_r.IndexedAttestation_dgo(True{}, buf, 2147483648) : P4_B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_at_2pow31(buf)

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_accept() -> {P4_PRV.is_some(Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_dchw(228, 228, (P4_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 228}, 57))), Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode_checked(P4_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 228}, 228))) == (True{}, True{}) : Bool & Bool}:
  P4_PRV.IndexedAttestation_decode_vchecked_accept()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_window() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_dchw(228, 227, (P4_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 228}, 57))) == None{} : Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_window()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_storage() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_dchw(228, 228, (P4_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 228}, 56))) == None{} : Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_storage()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_short() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode_checked(P4_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 227}, 228)) == None{} : Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_short()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_real() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode_checked(P4_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 228), 228}, 228)) == None{} : Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_real()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_budget_agree(buf: P4_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(FuluIndexedAttestation_r.IndexedAttestation_dcost(size), 4294967295), U32.is_le(FuluIndexedAttestation_r.IndexedAttestation_dcost(size), budget)) == True{} : Bool}) -> {FuluIndexedAttestation_r.IndexedAttestation_decode_checked_budget(buf, size, budget) == FuluIndexedAttestation_r.IndexedAttestation_decode_checked(buf, size) : P4_B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P4_PRV.IndexedAttestation_decode_vchecked_budget_agree(buf, size, budget, h)

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vchecked_budget_accept() -> {P4_PRV.is_some(Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode_checked_budget(P4_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 228}, 228, 4294967295)), Pair.snd(P4_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode_checked(P4_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 228}, 228))) == (True{}, True{}) : Bool & Bool}:
  P4_PRV.IndexedAttestation_decode_vchecked_budget_accept()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_bad_attesting_indices_ragged() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P5_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 237}, 237))) == False{} : Bool}:
  P5_PRV.IndexedAttestation_decode_vlit_bad_attesting_indices_ragged()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_1() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P6_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 229}, 229))) == False{} : Bool}:
  P6_PRV.IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_1()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_10() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P7_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 238}, 238))) == False{} : Bool}:
  P7_PRV.IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_10()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_2() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P8_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 230}, 230))) == False{} : Bool}:
  P8_PRV.IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_2()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_4() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P9_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 232}, 232))) == False{} : Bool}:
  P9_PRV.IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_4()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_7() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P10_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 235}, 235))) == False{} : Bool}:
  P10_PRV.IndexedAttestation_decode_vlit_bad_attesting_indices_ragged_7()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_bad_off_minus() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P11_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 227), 228}, 228))) == False{} : Bool}:
  P11_PRV.IndexedAttestation_decode_vlit_bad_off_minus()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_bad_off_plus() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P12_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 229), 229}, 229))) == False{} : Bool}:
  P12_PRV.IndexedAttestation_decode_vlit_bad_off_plus()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_count_at_l131072_u64(buf: P13_B.Buf, +off: U32) -> {Fulu_list_uint64_131072_r.l131072_u64_ok(buf, off, 1048576) == (buf, True{}) : P13_B.Buf & Bool}:
  P13_PRV.IndexedAttestation_decode_vlit_count_at_l131072_u64(buf, off)

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_count_over_l131072_u64(buf: P13_B.Buf, +off: U32) -> {Fulu_list_uint64_131072_r.l131072_u64_ok(buf, off, 1048584) == (buf, False{}) : P13_B.Buf & Bool}:
  P13_PRV.IndexedAttestation_decode_vlit_count_over_l131072_u64(buf, off)

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_ok_attesting_indices_n1() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P14_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 236}, 236))) == True{} : Bool}:
  P14_PRV.IndexedAttestation_decode_vlit_ok_attesting_indices_n1()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_ok_attesting_indices_n2() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P15_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 244}, 244))) == True{} : Bool}:
  P15_PRV.IndexedAttestation_decode_vlit_ok_attesting_indices_n2()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_ok_default() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P16_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 228}, 228))) == True{} : Bool}:
  P16_PRV.IndexedAttestation_decode_vlit_ok_default()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_ok_fixed() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 1, 4), 2, 5), 3, 6), 4, 7), 5, 8), 6, 9), 7, 10), 8, 11), 9, 12), 10, 13), 11, 14), 12, 15), 13, 16), 14, 17), 15, 18), 16, 19), 17, 20), 18, 21), 19, 22), 20, 23), 21, 24), 22, 25), 23, 26), 24, 27), 25, 28), 26, 29), 27, 30), 28, 31), 29, 32), 30, 33), 31, 34), 32, 35), 33, 36), 34, 37), 35, 38), 36, 39), 37, 40), 38, 41), 39, 42), 40, 43), 41, 44), 42, 45), 43, 46), 44, 47), 45, 48), 46, 49), 47, 50), 48, 51), 49, 52), 50, 53), 51, 54), 52, 55), 53, 56), 54, 57), 55, 58), 56, 59), 228}, 228))) == True{} : Bool}:
  P17_PRV.IndexedAttestation_decode_vlit_ok_fixed()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_ok_marked() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 57, 4), 59, 4), 244}, 244))) == True{} : Bool}:
  P18_PRV.IndexedAttestation_decode_vlit_ok_marked()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_ok_wide() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 1, 8), 2, 9), 3, 10), 4, 11), 5, 12), 6, 13), 7, 14), 8, 15), 9, 16), 10, 17), 11, 18), 12, 19), 13, 20), 14, 21), 15, 22), 16, 23), 17, 24), 18, 25), 19, 26), 20, 27), 21, 28), 22, 29), 23, 30), 24, 31), 25, 32), 26, 33), 27, 34), 28, 35), 29, 36), 30, 37), 31, 38), 32, 39), 33, 40), 34, 41), 35, 42), 36, 43), 37, 44), 38, 45), 39, 46), 40, 47), 41, 48), 42, 49), 43, 50), 44, 51), 45, 52), 46, 53), 47, 54), 48, 55), 49, 56), 50, 57), 51, 58), 52, 59), 53, 60), 54, 61), 55, 62), 56, 63), 57, 4), 58, 5), 59, 6), 60, 7), 244}, 244))) == True{} : Bool}:
  P19_PRV.IndexedAttestation_decode_vlit_ok_wide()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_rt_fixed() -> {P20_PRV.rtc57(P20_PRV.rt(Pair.snd(P20_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 1, 4), 2, 5), 3, 6), 4, 7), 5, 8), 6, 9), 7, 10), 8, 11), 9, 12), 10, 13), 11, 14), 12, 15), 13, 16), 14, 17), 15, 18), 16, 19), 17, 20), 18, 21), 19, 22), 20, 23), 21, 24), 22, 25), 23, 26), 24, 27), 25, 28), 26, 29), 27, 30), 28, 31), 29, 32), 30, 33), 31, 34), 32, 35), 33, 36), 34, 37), 35, 38), 36, 39), 37, 40), 38, 41), 39, 42), 40, 43), 41, 44), 42, 45), 43, 46), 44, 47), 45, 48), 46, 49), 47, 50), 48, 51), 49, 52), 50, 53), 51, 54), 52, 55), 53, 56), 54, 57), 55, 58), 56, 59), 228}, 228)))) == (228, (228, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, 59))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P20_PRV.IndexedAttestation_decode_vlit_rt_fixed()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_vlit_rt_wide() -> {P21_PRV.rtc61(P21_PRV.rt(Pair.snd(P21_B.Buf, Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>, FuluIndexedAttestation_r.IndexedAttestation_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 228), 1, 8), 2, 9), 3, 10), 4, 11), 5, 12), 6, 13), 7, 14), 8, 15), 9, 16), 10, 17), 11, 18), 12, 19), 13, 20), 14, 21), 15, 22), 16, 23), 17, 24), 18, 25), 19, 26), 20, 27), 21, 28), 22, 29), 23, 30), 24, 31), 25, 32), 26, 33), 27, 34), 28, 35), 29, 36), 30, 37), 31, 38), 32, 39), 33, 40), 34, 41), 35, 42), 36, 43), 37, 44), 38, 45), 39, 46), 40, 47), 41, 48), 42, 49), 43, 50), 44, 51), 45, 52), 46, 53), 47, 54), 48, 55), 49, 56), 50, 57), 51, 58), 52, 59), 53, 60), 54, 61), 55, 62), 56, 63), 57, 4), 58, 5), 59, 6), 60, 7), 244}, 244)))) == (244, (228, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (60, (61, (62, (63, (4, (5, (6, 7))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P21_PRV.IndexedAttestation_decode_vlit_rt_wide()

def FuluIndexedAttestation__decode_offsets__IndexedAttestation_decode_build(buf: P22_B.Buf, +size: U32, b2: P22_B.Buf, e: {FuluIndexedAttestation_r.IndexedAttestation_ok(buf, 0, size) == (b2, True{}) : P22_B.Buf & Bool}, hwin: {U32.is_le(size, P22_DWL.bsz(buf)) == True{} : Bool}) -> {FuluIndexedAttestation_r.IndexedAttestation_decode(buf, size) == FuluIndexedAttestation_r.IndexedAttestation_some(FuluIndexedAttestation_r.IndexedAttestation_build(b2, size)) : P22_B.Buf & Maybe<&1, FuluIndexedAttestation_d.IndexedAttestation>}:
  P22_PRV.IndexedAttestation_decode_build(buf, size, b2, e, hwin)

