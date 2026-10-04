import Base
import ../../src/buffer.bend as P0_B
import ../../types/FuluExecutionPayload_def_generated.bend as FuluExecutionPayload_d
import ../../types/FuluExecutionPayload_decode_ssz_generated.bend as FuluExecutionPayload_r
import ../slop/offsets/fulu_ExecutionPayload_first_offset_generated.bend as P0_PRV
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
import ../../spec/nat_bytes.bend as P1_N
import ../../spec/fulu_schemas.bend as P1_Spec
import ../../proofs/decode_shape.bend as P1_DS
import ../../proofs/decode_facts.bend as P1_DF
import ../obj/spec_fixed.bend as P1_F
import ../obj/vspec.bend as P1_VS
import ../obj/vbuf.bend as P1_VB
import ../obj/vu32.bend as P1_VU
import ../obj/vcopy.bend as P1_VC
import ../obj/vdepth.bend as P1_VD
import ../obj/vfits.bend as P1_VFT
import ../obj/vmr_generated.bend as P1_VMR
import ../obj/vua.bend as P1_UA
import ../obj/vua_rd.bend as P1_UR
import ../obj/vua_win.bend as P1_UW
import ../obj/vua_fix_generated.bend as P1_VTX
import ../obj/vrl_generated.bend as P1_VRL
import ../../spec/decoding_relation.bend as P1_Decoding
import ../../proofs/decode_unique.bend as P1_DCO
import ../obj/var_winx_ExecutionPayload_generated.bend as P1_EW
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_FuluExecutionPayload_generated.bend as P1_DW_FuluExecutionPayload
import ../obj/var_codec_ExecutionPayload_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_ExecutionPayload_and_pair_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_ExecutionPayload_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_extra_data_over_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_off_minus_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_off_plus_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_order_transactions_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_order_withdrawals_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_transactions_first_past_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_transactions_off0_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_transactions_off5_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_transactions_off_desc_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_transactions_off_past_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_withdrawals_over_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_withdrawals_ragged_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_withdrawals_ragged_1_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_withdrawals_ragged_2_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_withdrawals_ragged_22_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_withdrawals_ragged_43_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_bad_withdrawals_ragged_46_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_all_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_default_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_extra_data_n1_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_fixed_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_marked_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_transactions_n1_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_transactions_n2_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_wide_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_withdrawals_n1_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_withdrawals_n2_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/obj.bend as P31_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_rt_fixed_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/obj.bend as P32_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_rt_wide_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/obj.bend as P33_O
import ../obj/decode_window_library_generated.bend as P33_DWL
import ../slop/offsets/ExecutionPayload_generated.bend as P33_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluExecutionPayload (ExecutionPayload): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluExecutionPayload__decode_first_offset__ExecutionPayload_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(528, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 436 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 528) == False{} : Bool}) -> {FuluExecutionPayload_r.ExecutionPayload_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.ExecutionPayload_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def FuluExecutionPayload__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}) -> {FuluExecutionPayload_r.ExecutionPayload_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, pf, hd, hn, hN)

def FuluExecutionPayload__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {FuluExecutionPayload_r.ExecutionPayload_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(d, t, n)}) : P1_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hN, hchk)

def FuluExecutionPayload__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.ExecutionPayload(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hN, hchk)

def FuluExecutionPayload__decode_unique__decode_unique(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}, +v: P1_S.Value, spec: P1_Decoding.decodes(P1_Spec.ExecutionPayload(), P1_PRV.VW(t, n), v)) -> {v == P1_PRV.VAL(t, n) : P1_S.Value}:
  P1_PRV.decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec)

def FuluExecutionPayload__decode_reject__decode_reject(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> P1_Decoding.outside_image(P1_Spec.ExecutionPayload(), P1_PRV.VW(t, n)):
  P1_PRV.decode_reject(d, t, n, pf, hd, hn, hN, hchk)

def FuluExecutionPayload__decode_none__decode_none(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> {FuluExecutionPayload_r.ExecutionPayload_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), None{}) : P1_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P1_PRV.decode_none(d, t, n, pf, hd, hn, hN, hchk)

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vand_pair() -> {(Pair.snd(P2_B.Buf, Bool, P2_O.and_pair(True{}, (P2_B.empty(), True{}))), (Pair.snd(P2_B.Buf, Bool, P2_O.and_pair(True{}, (P2_B.empty(), False{}))), (Pair.snd(P2_B.Buf, Bool, P2_O.and_pair(False{}, (P2_B.empty(), True{}))), Pair.snd(P2_B.Buf, Bool, P2_O.and_pair(False{}, (P2_B.empty(), False{})))))) == (True{}, (False{}, (False{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P2_PRV.ExecutionPayload_decode_vand_pair()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_limit()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {FuluExecutionPayload_r.ExecutionPayload_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_nmax_wrap(buf)

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {FuluExecutionPayload_r.ExecutionPayload_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_nmax_above(buf)

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_dchw(528, 528, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 528}, 132))), Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 528}, 528))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.ExecutionPayload_decode_vchecked_accept()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_dchw(528, 527, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 528}, 132))) == None{} : Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_window()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_dchw(528, 528, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 528}, 131))) == None{} : Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_storage()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 527}, 528)) == None{} : Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_short()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode_checked(P3_B.Buf{Array.new(U32, 0n, 0), 528}, 528)) == None{} : Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_real()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_extra_data_over() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 561), 127, 561), 561}, 561))) == False{} : Bool}:
  P4_PRV.ExecutionPayload_decode_vlit_bad_extra_data_over()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_off_minus() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 527), 126, 528), 127, 528), 528}, 528))) == False{} : Bool}:
  P5_PRV.ExecutionPayload_decode_vlit_bad_off_minus()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_off_plus() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 529), 126, 528), 127, 528), 529}, 529))) == False{} : Bool}:
  P6_PRV.ExecutionPayload_decode_vlit_bad_off_plus()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_order_transactions() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 527), 127, 528), 528}, 528))) == False{} : Bool}:
  P7_PRV.ExecutionPayload_decode_vlit_bad_order_transactions()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_order_withdrawals() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 527), 528}, 528))) == False{} : Bool}:
  P8_PRV.ExecutionPayload_decode_vlit_bad_order_withdrawals()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_transactions_first_past() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 532), 132, 8), 532}, 532))) == False{} : Bool}:
  P9_PRV.ExecutionPayload_decode_vlit_bad_transactions_first_past()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_transactions_off0() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 532), 532}, 532))) == False{} : Bool}:
  P10_PRV.ExecutionPayload_decode_vlit_bad_transactions_off0()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_transactions_off5() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 533), 132, 5), 533}, 533))) == False{} : Bool}:
  P11_PRV.ExecutionPayload_decode_vlit_bad_transactions_off5()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_transactions_off_desc() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 536), 132, 8), 133, 7), 536}, 536))) == False{} : Bool}:
  P12_PRV.ExecutionPayload_decode_vlit_bad_transactions_off_desc()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_transactions_off_past() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 536), 132, 8), 133, 9), 536}, 536))) == False{} : Bool}:
  P13_PRV.ExecutionPayload_decode_vlit_bad_transactions_off_past()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_withdrawals_over() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 109, 528), 126, 528), 127, 528), 1276}, 1276))) == False{} : Bool}:
  P14_PRV.ExecutionPayload_decode_vlit_bad_withdrawals_over()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_withdrawals_ragged() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 573}, 573))) == False{} : Bool}:
  P15_PRV.ExecutionPayload_decode_vlit_bad_withdrawals_ragged()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_withdrawals_ragged_1() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 529}, 529))) == False{} : Bool}:
  P16_PRV.ExecutionPayload_decode_vlit_bad_withdrawals_ragged_1()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_withdrawals_ragged_2() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 530}, 530))) == False{} : Bool}:
  P17_PRV.ExecutionPayload_decode_vlit_bad_withdrawals_ragged_2()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_withdrawals_ragged_22() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 550}, 550))) == False{} : Bool}:
  P18_PRV.ExecutionPayload_decode_vlit_bad_withdrawals_ragged_22()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_withdrawals_ragged_43() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 571}, 571))) == False{} : Bool}:
  P19_PRV.ExecutionPayload_decode_vlit_bad_withdrawals_ragged_43()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_bad_withdrawals_ragged_46() -> {P20_PRV.some1(Pair.snd(P20_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 574}, 574))) == False{} : Bool}:
  P20_PRV.ExecutionPayload_decode_vlit_bad_withdrawals_ragged_46()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_all() -> {P21_PRV.some1(Pair.snd(P21_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 529), 127, 533), 132, 1031), 577}, 577))) == True{} : Bool}:
  P21_PRV.ExecutionPayload_decode_vlit_ok_all()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_default() -> {P22_PRV.some1(Pair.snd(P22_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 528}, 528))) == True{} : Bool}:
  P22_PRV.ExecutionPayload_decode_vlit_ok_default()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_extra_data_n1() -> {P23_PRV.some1(Pair.snd(P23_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 529), 127, 529), 132, 7), 529}, 529))) == True{} : Bool}:
  P23_PRV.ExecutionPayload_decode_vlit_ok_extra_data_n1()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_fixed() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 4), 1, 5), 2, 6), 3, 7), 4, 8), 5, 9), 6, 10), 7, 11), 8, 12), 9, 13), 10, 14), 11, 15), 12, 16), 13, 17), 14, 18), 15, 19), 16, 20), 17, 21), 18, 22), 19, 23), 20, 24), 21, 25), 22, 26), 23, 27), 24, 28), 25, 29), 26, 30), 27, 31), 28, 32), 29, 33), 30, 34), 31, 35), 32, 36), 33, 37), 34, 38), 35, 39), 36, 40), 37, 41), 38, 42), 39, 43), 40, 44), 41, 45), 42, 46), 43, 47), 44, 48), 45, 49), 46, 50), 47, 51), 48, 52), 49, 53), 50, 54), 51, 55), 52, 56), 53, 57), 54, 58), 55, 59), 56, 60), 57, 61), 58, 62), 59, 63), 60, 64), 61, 65), 62, 66), 63, 67), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 528), 110, 113), 111, 114), 112, 115), 113, 116), 114, 117), 115, 118), 116, 119), 117, 120), 118, 121), 119, 122), 120, 123), 121, 124), 122, 125), 123, 126), 124, 127), 125, 128), 126, 528), 127, 528), 128, 129), 129, 130), 130, 131), 131, 132), 528}, 528))) == True{} : Bool}:
  P24_PRV.ExecutionPayload_decode_vlit_ok_fixed()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_marked() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 529), 127, 537), 132, 2055), 133, 2048), 134, 1024), 145, 1024), 625}, 625))) == True{} : Bool}:
  P25_PRV.ExecutionPayload_decode_vlit_ok_marked()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_transactions_n1() -> {P26_PRV.some1(Pair.snd(P26_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P26_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 532), 132, 4), 532}, 532))) == True{} : Bool}:
  P26_PRV.ExecutionPayload_decode_vlit_ok_transactions_n1()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_transactions_n2() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 536), 132, 8), 133, 8), 536}, 536))) == True{} : Bool}:
  P27_PRV.ExecutionPayload_decode_vlit_ok_transactions_n2()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_wide() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 4), 1, 5), 2, 6), 3, 7), 4, 8), 5, 9), 6, 10), 7, 11), 8, 12), 9, 13), 10, 14), 11, 15), 12, 16), 13, 17), 14, 18), 15, 19), 16, 20), 17, 21), 18, 22), 19, 23), 20, 24), 21, 25), 22, 26), 23, 27), 24, 28), 25, 29), 26, 30), 27, 31), 28, 32), 29, 33), 30, 34), 31, 35), 32, 36), 33, 37), 34, 38), 35, 39), 36, 40), 37, 41), 38, 42), 39, 43), 40, 44), 41, 45), 42, 46), 43, 47), 44, 48), 45, 49), 46, 50), 47, 51), 48, 52), 49, 53), 50, 54), 51, 55), 52, 56), 53, 57), 54, 58), 55, 59), 56, 60), 57, 61), 58, 62), 59, 63), 60, 64), 61, 65), 62, 66), 63, 67), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 528), 110, 118), 111, 119), 112, 120), 113, 121), 114, 122), 115, 123), 116, 124), 117, 125), 118, 126), 119, 127), 120, 128), 121, 129), 122, 130), 123, 131), 124, 132), 125, 133), 126, 548), 127, 596), 128, 166), 129, 167), 130, 168), 131, 169), 132, 4), 133, 114), 134, 115), 135, 116), 136, 117), 137, 8), 138, 28), 139, 4), 140, 135), 141, 136), 142, 137), 143, 138), 144, 4), 145, 140), 146, 141), 147, 142), 148, 143), 149, 4), 150, 145), 151, 146), 152, 147), 153, 148), 154, 149), 155, 150), 156, 151), 157, 152), 158, 153), 159, 154), 160, 155), 161, 156), 162, 157), 163, 158), 164, 159), 165, 160), 166, 161), 167, 162), 168, 163), 169, 164), 170, 165), 684}, 684))) == True{} : Bool}:
  P28_PRV.ExecutionPayload_decode_vlit_ok_wide()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_withdrawals_n1() -> {P29_PRV.some1(Pair.snd(P29_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P29_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 572}, 572))) == True{} : Bool}:
  P29_PRV.ExecutionPayload_decode_vlit_ok_withdrawals_n1()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_withdrawals_n2() -> {P30_PRV.some1(Pair.snd(P30_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P30_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 616}, 616))) == True{} : Bool}:
  P30_PRV.ExecutionPayload_decode_vlit_ok_withdrawals_n2()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_rt_fixed() -> {P31_PRV.rtc132(P31_PRV.rt(Pair.snd(P31_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P31_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 4), 1, 5), 2, 6), 3, 7), 4, 8), 5, 9), 6, 10), 7, 11), 8, 12), 9, 13), 10, 14), 11, 15), 12, 16), 13, 17), 14, 18), 15, 19), 16, 20), 17, 21), 18, 22), 19, 23), 20, 24), 21, 25), 22, 26), 23, 27), 24, 28), 25, 29), 26, 30), 27, 31), 28, 32), 29, 33), 30, 34), 31, 35), 32, 36), 33, 37), 34, 38), 35, 39), 36, 40), 37, 41), 38, 42), 39, 43), 40, 44), 41, 45), 42, 46), 43, 47), 44, 48), 45, 49), 46, 50), 47, 51), 48, 52), 49, 53), 50, 54), 51, 55), 52, 56), 53, 57), 54, 58), 55, 59), 56, 60), 57, 61), 58, 62), 59, 63), 60, 64), 61, 65), 62, 66), 63, 67), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 528), 110, 113), 111, 114), 112, 115), 113, 116), 114, 117), 115, 118), 116, 119), 117, 120), 118, 121), 119, 122), 120, 123), 121, 124), 122, 125), 123, 126), 124, 127), 125, 128), 126, 528), 127, 528), 128, 129), 129, 130), 130, 131), 131, 132), 528}, 528)))) == (528, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (60, (61, (62, (63, (64, (65, (66, (67, (68, (69, (70, (71, (72, (73, (74, (75, (76, (77, (78, (79, (80, (81, (82, (83, (84, (85, (86, (87, (88, (89, (90, (91, (92, (93, (94, (95, (96, (97, (98, (99, (100, (101, (102, (103, (104, (105, (106, (107, (108, (109, (110, (111, (112, (528, (113, (114, (115, (116, (117, (118, (119, (120, (121, (122, (123, (124, (125, (126, (127, (128, (528, (528, (129, (130, (131, 132)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P31_PRV.ExecutionPayload_decode_vlit_rt_fixed()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_rt_wide() -> {P32_PRV.rtc171(P32_PRV.rt(Pair.snd(P32_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P32_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 4), 1, 5), 2, 6), 3, 7), 4, 8), 5, 9), 6, 10), 7, 11), 8, 12), 9, 13), 10, 14), 11, 15), 12, 16), 13, 17), 14, 18), 15, 19), 16, 20), 17, 21), 18, 22), 19, 23), 20, 24), 21, 25), 22, 26), 23, 27), 24, 28), 25, 29), 26, 30), 27, 31), 28, 32), 29, 33), 30, 34), 31, 35), 32, 36), 33, 37), 34, 38), 35, 39), 36, 40), 37, 41), 38, 42), 39, 43), 40, 44), 41, 45), 42, 46), 43, 47), 44, 48), 45, 49), 46, 50), 47, 51), 48, 52), 49, 53), 50, 54), 51, 55), 52, 56), 53, 57), 54, 58), 55, 59), 56, 60), 57, 61), 58, 62), 59, 63), 60, 64), 61, 65), 62, 66), 63, 67), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 528), 110, 118), 111, 119), 112, 120), 113, 121), 114, 122), 115, 123), 116, 124), 117, 125), 118, 126), 119, 127), 120, 128), 121, 129), 122, 130), 123, 131), 124, 132), 125, 133), 126, 548), 127, 596), 128, 166), 129, 167), 130, 168), 131, 169), 132, 4), 133, 114), 134, 115), 135, 116), 136, 117), 137, 8), 138, 28), 139, 4), 140, 135), 141, 136), 142, 137), 143, 138), 144, 4), 145, 140), 146, 141), 147, 142), 148, 143), 149, 4), 150, 145), 151, 146), 152, 147), 153, 148), 154, 149), 155, 150), 156, 151), 157, 152), 158, 153), 159, 154), 160, 155), 161, 156), 162, 157), 163, 158), 164, 159), 165, 160), 166, 161), 167, 162), 168, 163), 169, 164), 170, 165), 684}, 684)))) == (684, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (60, (61, (62, (63, (64, (65, (66, (67, (68, (69, (70, (71, (72, (73, (74, (75, (76, (77, (78, (79, (80, (81, (82, (83, (84, (85, (86, (87, (88, (89, (90, (91, (92, (93, (94, (95, (96, (97, (98, (99, (100, (101, (102, (103, (104, (105, (106, (107, (108, (109, (110, (111, (112, (528, (118, (119, (120, (121, (122, (123, (124, (125, (126, (127, (128, (129, (130, (131, (132, (133, (548, (596, (166, (167, (168, (169, (4, (114, (115, (116, (117, (8, (28, (4, (135, (136, (137, (138, (4, (140, (141, (142, (143, (4, (145, (146, (147, (148, (149, (150, (151, (152, (153, (154, (155, (156, (157, (158, (159, (160, (161, (162, (163, (164, 165))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P32_PRV.ExecutionPayload_decode_vlit_rt_wide()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_build(buf: P33_B.Buf, +size: U32, b2: P33_B.Buf, e: {FuluExecutionPayload_r.ExecutionPayload_ok(buf, 0, size) == (b2, True{}) : P33_B.Buf & Bool}, hwin: {U32.is_le(size, P33_DWL.bsz(buf)) == True{} : Bool}) -> {FuluExecutionPayload_r.ExecutionPayload_decode(buf, size) == FuluExecutionPayload_r.ExecutionPayload_some(FuluExecutionPayload_r.ExecutionPayload_build(b2, size)) : P33_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P33_PRV.ExecutionPayload_decode_build(buf, size, b2, e, hwin)

