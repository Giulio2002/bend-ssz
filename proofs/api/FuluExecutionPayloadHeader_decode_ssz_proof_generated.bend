import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/Fulu_bytelist_32_decode_ssz_generated.bend as Fulu_bytelist_32_r
import ../../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../../types/FuluExecutionPayloadHeader_decode_ssz_generated.bend as FuluExecutionPayloadHeader_r
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
import ../obj/vbytes.bend as P0_VY
import ../obj/vbspec.bend as P0_VZ
import ../obj/var_bytes_fix_generated.bend as P0_VT
import ../obj/var_bytes_ExecutionPayloadHeader_win_generated.bend as P0_W
import ../../proofs/obj/decode_window_library_generated.bend as P0_DWL
import ../../proofs/obj/decode_window_FuluExecutionPayloadHeader_generated.bend as P0_DW_FuluExecutionPayloadHeader
import ../obj/var_bytes_ExecutionPayloadHeader_generated.bend as P0_PRV
import ../../types/schema.bend as P1_S
import ../../spec/decoding_relation.bend as P1_Decoding
import ../../spec/fulu_schemas.bend as P1_Spec
import ../compact/found_generated.bend as P1_F
import ../compact/arith.bend as P1_A
import ../obj/vbuf.bend as P1_VB
import ../obj/var_bytes_ExecutionPayloadHeader_generated.bend as P1_DC
import ../../proofs/decode_unique.bend as P1_DCO
import ../obj/var_bytes_ExecutionPayloadHeader_unique_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/obj.bend as P2_O
import ../../types/schema.bend as P2_S
import ../../types/primitive.bend as P2_P
import ../compact/found_generated.bend as P2_F
import ../compact/arith.bend as P2_A
import ../compact/bits_generated.bend as P2_BT
import ../../proofs/nat_order.bend as P2_Order
import ../../proofs/primitive_invariants.bend as P2_V
import ../../spec/primitives.bend as P2_SP
import ../../spec/layout.bend as P2_Layout
import ../../spec/codec.bend as P2_Codec
import ../../spec/byte_list.bend as P2_ByteList
import ../../spec/decoding_relation.bend as P2_Decoding
import ../../spec/nat_bytes.bend as P2_N
import ../../spec/fulu_schemas.bend as P2_Spec
import ../../proofs/decode_shape.bend as P2_DS
import ../../proofs/decode_facts.bend as P2_DF
import ../obj/spec_fixed.bend as P2_FX
import ../obj/dk.bend as P2_DK
import ../obj/vspec.bend as P2_VS
import ../obj/vbuf.bend as P2_VB
import ../obj/vu32.bend as P2_VU
import ../obj/vcopy.bend as P2_VC
import ../obj/vrej.bend as P2_VR
import ../obj/vfix.bend as P2_VF
import ../obj/vbspec.bend as P2_VZ
import ../obj/var_bytes_ExecutionPayloadHeader_win_generated.bend as P2_W
import ../obj/var_bytes_ExecutionPayloadHeader_generated.bend as P2_DC
import ../../proofs/obj/decode_window_library_generated.bend as P2_DWL
import ../../proofs/obj/decode_window_FuluExecutionPayloadHeader_generated.bend as P2_DW_FuluExecutionPayloadHeader
import ../obj/var_bytes_ExecutionPayloadHeader_rej_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_bad_extra_data_over_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_bad_off_minus_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_bad_off_plus_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_count_at_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_ok_default_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_ok_extra_data_n1_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_ok_fixed_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_ok_wide_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_rt_fixed_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_ExecutionPayloadHeader_decode_literal_rt_wide_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../obj/decode_window_library_generated.bend as P14_DWL
import ../slop/offsets/ExecutionPayloadHeader_generated.bend as P14_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluExecutionPayloadHeader (ExecutionPayloadHeader): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluExecutionPayloadHeader__ok_eval__ok_eval(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_ok(P0_PRV.BF(t, n), 0, n) == (P0_PRV.BF(t, n), P0_PRV.CHK(t, n)) : P0_B.Buf & Bool}:
  P0_PRV.ok_eval(d, t, n, pf, hd, hn)

def FuluExecutionPayloadHeader__decode_accept__decode_accept(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), Some{P0_PRV.OBJ(t, n)}) : P0_B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P0_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def FuluExecutionPayloadHeader__decode_spec__decode_spec(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.ExecutionPayloadHeader(), P0_PRV.VW(t, n), P0_PRV.VAL(t, n)):
  P0_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def FuluExecutionPayloadHeader__decode_unique__decode_unique(+d: Nat, +t: P1_F.array__Tree<U32>, +n: U32, +pf: {P1_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_DC.CHK(t, n) == True{} : Bool}, +v: P1_S.Value, spec: P1_Decoding.decodes(P1_Spec.ExecutionPayloadHeader(), P1_DC.VW(t, n), v)) -> {v == P1_DC.VAL(t, n) : P1_S.Value}:
  P1_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def FuluExecutionPayloadHeader__decode_reject__decode_reject(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == False{} : Bool}) -> P2_Decoding.outside_image(P2_Spec.ExecutionPayloadHeader(), P2_DC.VW(t, n)):
  P2_PRV.decode_reject(d, t, n, pf, hn, hchk)

def FuluExecutionPayloadHeader__decode_none__decode_none(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == False{} : Bool}) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P2_DC.BF(t, n), n) == (P2_DC.BF(t, n), None{}) : P2_B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P2_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_limit()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_nmax_wrap(buf)

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_nmax_above(buf)

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_nmax_at(buf: P3_B.Buf) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dchw(4294967264, 4294967264, (buf, 1073741816)) == FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dgo(True{}, buf, 4294967264) : P3_B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_nmax_at(buf)

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_at_2pow31(buf: P3_B.Buf) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dchw(2147483648, 2147483648, (buf, 536870912)) == FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dgo(True{}, buf, 2147483648) : P3_B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_at_2pow31(buf)

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dchw(584, 584, (P3_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 584}, 146))), Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 584}, 584))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_accept()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dchw(584, 583, (P3_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 584}, 146))) == None{} : Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_window()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dchw(584, 584, (P3_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 584}, 145))) == None{} : Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_storage()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 583}, 584)) == None{} : Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_short()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode_checked(P3_B.Buf{Array.new(U32, 0n, 0), 584}, 584)) == None{} : Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_real()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_budget_agree(buf: P3_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dcost(size), 4294967295), U32.is_le(FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_dcost(size), budget)) == True{} : Bool}) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode_checked_budget(buf, size, budget) == FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode_checked(buf, size) : P3_B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_budget_agree(buf, size, budget, h)

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vchecked_budget_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode_checked_budget(P3_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 584}, 584, 4294967295)), Pair.snd(P3_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 584}, 584))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.ExecutionPayloadHeader_decode_vchecked_budget_accept()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_bad_extra_data_over() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P4_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 617}, 617))) == False{} : Bool}:
  P4_PRV.ExecutionPayloadHeader_decode_vlit_bad_extra_data_over()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_bad_off_minus() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P5_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 583), 584}, 584))) == False{} : Bool}:
  P5_PRV.ExecutionPayloadHeader_decode_vlit_bad_off_minus()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_bad_off_plus() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P6_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 585), 585}, 585))) == False{} : Bool}:
  P6_PRV.ExecutionPayloadHeader_decode_vlit_bad_off_plus()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_count_at_bl32(buf: P7_B.Buf, +off: U32) -> {Fulu_bytelist_32_r.bl32_ok(buf, off, 32) == (buf, True{}) : P7_B.Buf & Bool}:
  P7_PRV.ExecutionPayloadHeader_decode_vlit_count_at_bl32(buf, off)

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_count_over_bl32(buf: P7_B.Buf, +off: U32) -> {Fulu_bytelist_32_r.bl32_ok(buf, off, 33) == (buf, False{}) : P7_B.Buf & Bool}:
  P7_PRV.ExecutionPayloadHeader_decode_vlit_count_over_bl32(buf, off)

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_ok_default() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P8_B.Buf{Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 584}, 584))) == True{} : Bool}:
  P8_PRV.ExecutionPayloadHeader_decode_vlit_ok_default()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_ok_extra_data_n1() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 109, 584), 146, 7), 585}, 585))) == True{} : Bool}:
  P9_PRV.ExecutionPayloadHeader_decode_vlit_ok_extra_data_n1()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_ok_fixed() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 4), 1, 5), 2, 6), 3, 7), 4, 8), 5, 9), 6, 10), 7, 11), 8, 12), 9, 13), 10, 14), 11, 15), 12, 16), 13, 17), 14, 18), 15, 19), 16, 20), 17, 21), 18, 22), 19, 23), 20, 24), 21, 25), 22, 26), 23, 27), 24, 28), 25, 29), 26, 30), 27, 31), 28, 32), 29, 33), 30, 34), 31, 35), 32, 36), 33, 37), 34, 38), 35, 39), 36, 40), 37, 41), 38, 42), 39, 43), 40, 44), 41, 45), 42, 46), 43, 47), 44, 48), 45, 49), 46, 50), 47, 51), 48, 52), 49, 53), 50, 54), 51, 55), 52, 56), 53, 57), 54, 58), 55, 59), 56, 60), 57, 61), 58, 62), 59, 63), 60, 64), 61, 65), 62, 66), 63, 67), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 584), 110, 113), 111, 114), 112, 115), 113, 116), 114, 117), 115, 118), 116, 119), 117, 120), 118, 121), 119, 122), 120, 123), 121, 124), 122, 125), 123, 126), 124, 127), 125, 128), 126, 129), 127, 130), 128, 131), 129, 132), 130, 133), 131, 134), 132, 135), 133, 136), 134, 137), 135, 138), 136, 139), 137, 140), 138, 141), 139, 142), 140, 143), 141, 144), 142, 145), 143, 146), 144, 147), 145, 148), 584}, 584))) == True{} : Bool}:
  P10_PRV.ExecutionPayloadHeader_decode_vlit_ok_fixed()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_ok_wide() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 4), 1, 5), 2, 6), 3, 7), 4, 8), 5, 9), 6, 10), 7, 11), 8, 12), 9, 13), 10, 14), 11, 15), 12, 16), 13, 17), 14, 18), 15, 19), 16, 20), 17, 21), 18, 22), 19, 23), 20, 24), 21, 25), 22, 26), 23, 27), 24, 28), 25, 29), 26, 30), 27, 31), 28, 32), 29, 33), 30, 34), 31, 35), 32, 36), 33, 37), 34, 38), 35, 39), 36, 40), 37, 41), 38, 42), 39, 43), 40, 44), 41, 45), 42, 46), 43, 47), 44, 48), 45, 49), 46, 50), 47, 51), 48, 52), 49, 53), 50, 54), 51, 55), 52, 56), 53, 57), 54, 58), 55, 59), 56, 60), 57, 61), 58, 62), 59, 63), 60, 64), 61, 65), 62, 66), 63, 67), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 584), 110, 118), 111, 119), 112, 120), 113, 121), 114, 122), 115, 123), 116, 124), 117, 125), 118, 126), 119, 127), 120, 128), 121, 129), 122, 130), 123, 131), 124, 132), 125, 133), 126, 134), 127, 135), 128, 136), 129, 137), 130, 138), 131, 139), 132, 140), 133, 141), 134, 142), 135, 143), 136, 144), 137, 145), 138, 146), 139, 147), 140, 148), 141, 149), 142, 150), 143, 151), 144, 152), 145, 153), 146, 4), 147, 114), 148, 115), 149, 116), 150, 117), 604}, 604))) == True{} : Bool}:
  P11_PRV.ExecutionPayloadHeader_decode_vlit_ok_wide()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_rt_fixed() -> {P12_PRV.rtc146(P12_PRV.rt(Pair.snd(P12_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 4), 1, 5), 2, 6), 3, 7), 4, 8), 5, 9), 6, 10), 7, 11), 8, 12), 9, 13), 10, 14), 11, 15), 12, 16), 13, 17), 14, 18), 15, 19), 16, 20), 17, 21), 18, 22), 19, 23), 20, 24), 21, 25), 22, 26), 23, 27), 24, 28), 25, 29), 26, 30), 27, 31), 28, 32), 29, 33), 30, 34), 31, 35), 32, 36), 33, 37), 34, 38), 35, 39), 36, 40), 37, 41), 38, 42), 39, 43), 40, 44), 41, 45), 42, 46), 43, 47), 44, 48), 45, 49), 46, 50), 47, 51), 48, 52), 49, 53), 50, 54), 51, 55), 52, 56), 53, 57), 54, 58), 55, 59), 56, 60), 57, 61), 58, 62), 59, 63), 60, 64), 61, 65), 62, 66), 63, 67), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 584), 110, 113), 111, 114), 112, 115), 113, 116), 114, 117), 115, 118), 116, 119), 117, 120), 118, 121), 119, 122), 120, 123), 121, 124), 122, 125), 123, 126), 124, 127), 125, 128), 126, 129), 127, 130), 128, 131), 129, 132), 130, 133), 131, 134), 132, 135), 133, 136), 134, 137), 135, 138), 136, 139), 137, 140), 138, 141), 139, 142), 140, 143), 141, 144), 142, 145), 143, 146), 144, 147), 145, 148), 584}, 584)))) == (584, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (60, (61, (62, (63, (64, (65, (66, (67, (68, (69, (70, (71, (72, (73, (74, (75, (76, (77, (78, (79, (80, (81, (82, (83, (84, (85, (86, (87, (88, (89, (90, (91, (92, (93, (94, (95, (96, (97, (98, (99, (100, (101, (102, (103, (104, (105, (106, (107, (108, (109, (110, (111, (112, (584, (113, (114, (115, (116, (117, (118, (119, (120, (121, (122, (123, (124, (125, (126, (127, (128, (129, (130, (131, (132, (133, (134, (135, (136, (137, (138, (139, (140, (141, (142, (143, (144, (145, (146, (147, 148)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P12_PRV.ExecutionPayloadHeader_decode_vlit_rt_fixed()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_vlit_rt_wide() -> {P13_PRV.rtc151(P13_PRV.rt(Pair.snd(P13_B.Buf, Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 4), 1, 5), 2, 6), 3, 7), 4, 8), 5, 9), 6, 10), 7, 11), 8, 12), 9, 13), 10, 14), 11, 15), 12, 16), 13, 17), 14, 18), 15, 19), 16, 20), 17, 21), 18, 22), 19, 23), 20, 24), 21, 25), 22, 26), 23, 27), 24, 28), 25, 29), 26, 30), 27, 31), 28, 32), 29, 33), 30, 34), 31, 35), 32, 36), 33, 37), 34, 38), 35, 39), 36, 40), 37, 41), 38, 42), 39, 43), 40, 44), 41, 45), 42, 46), 43, 47), 44, 48), 45, 49), 46, 50), 47, 51), 48, 52), 49, 53), 50, 54), 51, 55), 52, 56), 53, 57), 54, 58), 55, 59), 56, 60), 57, 61), 58, 62), 59, 63), 60, 64), 61, 65), 62, 66), 63, 67), 64, 68), 65, 69), 66, 70), 67, 71), 68, 72), 69, 73), 70, 74), 71, 75), 72, 76), 73, 77), 74, 78), 75, 79), 76, 80), 77, 81), 78, 82), 79, 83), 80, 84), 81, 85), 82, 86), 83, 87), 84, 88), 85, 89), 86, 90), 87, 91), 88, 92), 89, 93), 90, 94), 91, 95), 92, 96), 93, 97), 94, 98), 95, 99), 96, 100), 97, 101), 98, 102), 99, 103), 100, 104), 101, 105), 102, 106), 103, 107), 104, 108), 105, 109), 106, 110), 107, 111), 108, 112), 109, 584), 110, 118), 111, 119), 112, 120), 113, 121), 114, 122), 115, 123), 116, 124), 117, 125), 118, 126), 119, 127), 120, 128), 121, 129), 122, 130), 123, 131), 124, 132), 125, 133), 126, 134), 127, 135), 128, 136), 129, 137), 130, 138), 131, 139), 132, 140), 133, 141), 134, 142), 135, 143), 136, 144), 137, 145), 138, 146), 139, 147), 140, 148), 141, 149), 142, 150), 143, 151), 144, 152), 145, 153), 146, 4), 147, 114), 148, 115), 149, 116), 150, 117), 604}, 604)))) == (604, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (60, (61, (62, (63, (64, (65, (66, (67, (68, (69, (70, (71, (72, (73, (74, (75, (76, (77, (78, (79, (80, (81, (82, (83, (84, (85, (86, (87, (88, (89, (90, (91, (92, (93, (94, (95, (96, (97, (98, (99, (100, (101, (102, (103, (104, (105, (106, (107, (108, (109, (110, (111, (112, (584, (118, (119, (120, (121, (122, (123, (124, (125, (126, (127, (128, (129, (130, (131, (132, (133, (134, (135, (136, (137, (138, (139, (140, (141, (142, (143, (144, (145, (146, (147, (148, (149, (150, (151, (152, (153, (4, (114, (115, (116, 117))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P13_PRV.ExecutionPayloadHeader_decode_vlit_rt_wide()

def FuluExecutionPayloadHeader__decode_offsets__ExecutionPayloadHeader_decode_build(buf: P14_B.Buf, +size: U32, b2: P14_B.Buf, e: {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_ok(buf, 0, size) == (b2, True{}) : P14_B.Buf & Bool}, hwin: {U32.is_le(size, P14_DWL.bsz(buf)) == True{} : Bool}) -> {FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_decode(buf, size) == FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_some(FuluExecutionPayloadHeader_r.ExecutionPayloadHeader_build(b2, size)) : P14_B.Buf & Maybe<&1, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}:
  P14_PRV.ExecutionPayloadHeader_decode_build(buf, size, b2, e, hwin)

