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
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_marked_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_transactions_n1_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_transactions_n2_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_withdrawals_n1_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_ExecutionPayload_decode_literal_ok_withdrawals_n2_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../obj/decode_window_library_generated.bend as P29_DWL
import ../slop/offsets/ExecutionPayload_generated.bend as P29_PRV

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

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_nmax_at(buf: P3_B.Buf) -> {FuluExecutionPayload_r.ExecutionPayload_dchw(4294967264, 4294967264, (buf, 1073741816)) == FuluExecutionPayload_r.ExecutionPayload_dgo(True{}, buf, 4294967264) : P3_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_nmax_at(buf)

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_at_2pow31(buf: P3_B.Buf) -> {FuluExecutionPayload_r.ExecutionPayload_dchw(2147483648, 2147483648, (buf, 536870912)) == FuluExecutionPayload_r.ExecutionPayload_dgo(True{}, buf, 2147483648) : P3_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_at_2pow31(buf)

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

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_budget_agree(buf: P3_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(FuluExecutionPayload_r.ExecutionPayload_dcost(size), 4294967295), U32.is_le(FuluExecutionPayload_r.ExecutionPayload_dcost(size), budget)) == True{} : Bool}) -> {FuluExecutionPayload_r.ExecutionPayload_decode_checked_budget(buf, size, budget) == FuluExecutionPayload_r.ExecutionPayload_decode_checked(buf, size) : P3_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P3_PRV.ExecutionPayload_decode_vchecked_budget_agree(buf, size, budget, h)

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vchecked_budget_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode_checked_budget(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 528}, 528, 4294967295)), Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 528}, 528))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.ExecutionPayload_decode_vchecked_budget_accept()

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

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_marked() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 529), 127, 537), 132, 2055), 133, 2048), 134, 1024), 145, 1024), 625}, 625))) == True{} : Bool}:
  P24_PRV.ExecutionPayload_decode_vlit_ok_marked()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_transactions_n1() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 532), 132, 4), 532}, 532))) == True{} : Bool}:
  P25_PRV.ExecutionPayload_decode_vlit_ok_transactions_n1()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_transactions_n2() -> {P26_PRV.some1(Pair.snd(P26_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P26_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 536), 132, 8), 133, 8), 536}, 536))) == True{} : Bool}:
  P26_PRV.ExecutionPayload_decode_vlit_ok_transactions_n2()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_withdrawals_n1() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 572}, 572))) == True{} : Bool}:
  P27_PRV.ExecutionPayload_decode_vlit_ok_withdrawals_n1()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_vlit_ok_withdrawals_n2() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>, FuluExecutionPayload_r.ExecutionPayload_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 528), 126, 528), 127, 528), 616}, 616))) == True{} : Bool}:
  P28_PRV.ExecutionPayload_decode_vlit_ok_withdrawals_n2()

def FuluExecutionPayload__decode_offsets__ExecutionPayload_decode_build(buf: P29_B.Buf, +size: U32, b2: P29_B.Buf, e: {FuluExecutionPayload_r.ExecutionPayload_ok(buf, 0, size) == (b2, True{}) : P29_B.Buf & Bool}, hwin: {U32.is_le(size, P29_DWL.bsz(buf)) == True{} : Bool}) -> {FuluExecutionPayload_r.ExecutionPayload_decode(buf, size) == FuluExecutionPayload_r.ExecutionPayload_some(FuluExecutionPayload_r.ExecutionPayload_build(b2, size)) : P29_B.Buf & Maybe<&1, FuluExecutionPayload_d.ExecutionPayload>}:
  P29_PRV.ExecutionPayload_decode_build(buf, size, b2, e, hwin)

