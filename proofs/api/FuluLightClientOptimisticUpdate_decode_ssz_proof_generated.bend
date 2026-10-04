import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/FuluLightClientOptimisticUpdate_def_generated.bend as FuluLightClientOptimisticUpdate_d
import ../../types/FuluLightClientOptimisticUpdate_decode_ssz_generated.bend as FuluLightClientOptimisticUpdate_r
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
import ../obj/var_bytes_LightClientOptimisticUpdate_win_generated.bend as P0_W
import ../../proofs/obj/decode_window_library_generated.bend as P0_DWL
import ../../proofs/obj/decode_window_FuluLightClientOptimisticUpdate_generated.bend as P0_DW_FuluLightClientOptimisticUpdate
import ../obj/var_bytes_LightClientOptimisticUpdate_generated.bend as P0_PRV
import ../../types/schema.bend as P1_S
import ../../spec/decoding_relation.bend as P1_Decoding
import ../../spec/fulu_schemas.bend as P1_Spec
import ../compact/found_generated.bend as P1_F
import ../compact/arith.bend as P1_A
import ../obj/vbuf.bend as P1_VB
import ../obj/var_bytes_LightClientOptimisticUpdate_generated.bend as P1_DC
import ../../proofs/decode_unique.bend as P1_DCO
import ../obj/var_bytes_LightClientOptimisticUpdate_unique_generated.bend as P1_PRV
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
import ../obj/var_bytes_LightClientOptimisticUpdate_win_generated.bend as P2_W
import ../obj/var_bytes_LightClientOptimisticUpdate_generated.bend as P2_DC
import ../obj/var_bytes_LightClientHeader_win_generated.bend as P2_YW
import ../obj/var_bytes_LightClientHeader_rej_generated.bend as P2_YR
import ../../proofs/obj/decode_window_library_generated.bend as P2_DWL
import ../../proofs/obj/decode_window_FuluLightClientOptimisticUpdate_generated.bend as P2_DW_FuluLightClientOptimisticUpdate
import ../obj/var_bytes_LightClientOptimisticUpdate_rej_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_bad_attested_header_execution_extra_data_over_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_bad_attested_header_execution_off_minus_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_bad_attested_header_execution_off_plus_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_bad_attested_header_off_minus_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_bad_attested_header_off_plus_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_bad_off_minus_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_bad_off_plus_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_ok_default_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_ok_fixed_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_LightClientOptimisticUpdate_decode_literal_rt_fixed_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../obj/decode_window_library_generated.bend as P14_DWL
import ../slop/offsets/LightClientOptimisticUpdate_generated.bend as P14_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluLightClientOptimisticUpdate (LightClientOptimisticUpdate): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluLightClientOptimisticUpdate__ok_eval__ok_eval(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_ok(P0_PRV.BF(t, n), 0, n) == (P0_PRV.BF(t, n), P0_PRV.CHK(t, n)) : P0_B.Buf & Bool}:
  P0_PRV.ok_eval(d, t, n, pf, hd, hn)

def FuluLightClientOptimisticUpdate__decode_accept__decode_accept(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), Some{P0_PRV.OBJ(t, n)}) : P0_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P0_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def FuluLightClientOptimisticUpdate__decode_spec__decode_spec(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.LightClientOptimisticUpdate(), P0_PRV.VW(t, n), P0_PRV.VAL(t, n)):
  P0_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def FuluLightClientOptimisticUpdate__decode_unique__decode_unique(+d: Nat, +t: P1_F.array__Tree<U32>, +n: U32, +pf: {P1_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_DC.CHK(t, n) == True{} : Bool}, +v: P1_S.Value, spec: P1_Decoding.decodes(P1_Spec.LightClientOptimisticUpdate(), P1_DC.VW(t, n), v)) -> {v == P1_DC.VAL(t, n) : P1_S.Value}:
  P1_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def FuluLightClientOptimisticUpdate__decode_reject__decode_reject(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == False{} : Bool}) -> P2_Decoding.outside_image(P2_Spec.LightClientOptimisticUpdate(), P2_DC.VW(t, n)):
  P2_PRV.decode_reject(d, t, n, pf, hn, hchk)

def FuluLightClientOptimisticUpdate__decode_none__decode_none(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == False{} : Bool}) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P2_DC.BF(t, n), n) == (P2_DC.BF(t, n), None{}) : P2_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P2_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_limit()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_nmax_wrap(buf)

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_nmax_above(buf)

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_nmax_at(buf: P3_B.Buf) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dchw(4294967264, 4294967264, (buf, 1073741816)) == FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dgo(True{}, buf, 4294967264) : P3_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_nmax_at(buf)

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_at_2pow31(buf: P3_B.Buf) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dchw(2147483648, 2147483648, (buf, 536870912)) == FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dgo(True{}, buf, 2147483648) : P3_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_at_2pow31(buf)

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dchw(1000, 1000, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 584), 1000}, 250))), Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 584), 1000}, 1000))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_accept()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dchw(1000, 999, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 584), 1000}, 250))) == None{} : Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_window()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dchw(1000, 1000, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 584), 1000}, 249))) == None{} : Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_storage()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 584), 999}, 1000)) == None{} : Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_short()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 172), 1000}, 1000)) == None{} : Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_real()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_budget_agree(buf: P3_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dcost(size), 4294967295), U32.is_le(FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_dcost(size), budget)) == True{} : Bool}) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode_checked_budget(buf, size, budget) == FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode_checked(buf, size) : P3_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_budget_agree(buf, size, budget, h)

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vchecked_budget_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode_checked_budget(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 584), 1000}, 1000, 4294967295)), Pair.snd(P3_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 584), 1000}, 1000))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.LightClientOptimisticUpdate_decode_vchecked_budget_accept()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_bad_attested_header_execution_extra_data_over() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 0, 172), 71, 244), 213, 584), 1033}, 1033))) == False{} : Bool}:
  P4_PRV.LightClientOptimisticUpdate_decode_vlit_bad_attested_header_execution_extra_data_over()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_bad_attested_header_execution_off_minus() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 583), 1000}, 1000))) == False{} : Bool}:
  P5_PRV.LightClientOptimisticUpdate_decode_vlit_bad_attested_header_execution_off_minus()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_bad_attested_header_execution_off_plus() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 585), 1001}, 1001))) == False{} : Bool}:
  P6_PRV.LightClientOptimisticUpdate_decode_vlit_bad_attested_header_execution_off_plus()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_bad_attested_header_off_minus() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 243), 213, 584), 1000}, 1000))) == False{} : Bool}:
  P7_PRV.LightClientOptimisticUpdate_decode_vlit_bad_attested_header_off_minus()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_bad_attested_header_off_plus() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 245), 213, 584), 1001}, 1001))) == False{} : Bool}:
  P8_PRV.LightClientOptimisticUpdate_decode_vlit_bad_attested_header_off_plus()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_bad_off_minus() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 171), 71, 244), 213, 584), 1000}, 1000))) == False{} : Bool}:
  P9_PRV.LightClientOptimisticUpdate_decode_vlit_bad_off_minus()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_bad_off_plus() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 173), 71, 244), 213, 584), 1001}, 1001))) == False{} : Bool}:
  P10_PRV.LightClientOptimisticUpdate_decode_vlit_bad_off_plus()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_ok_default() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 71, 244), 213, 584), 1000}, 1000))) == True{} : Bool}:
  P11_PRV.LightClientOptimisticUpdate_decode_vlit_ok_default()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_ok_fixed() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 1, 1), 17, 209), 18, 210), 19, 211), 20, 212), 21, 213), 22, 214), 23, 215), 24, 216), 25, 217), 26, 218), 27, 219), 28, 220), 29, 221), 30, 222), 31, 223), 32, 224), 33, 225), 34, 226), 35, 227), 36, 228), 37, 229), 38, 230), 39, 231), 40, 232), 41, 233), 42, 234), 43, 4), 44, 5), 45, 6), 46, 7), 47, 8), 48, 9), 49, 10), 50, 11), 51, 12), 52, 13), 53, 14), 54, 15), 55, 16), 56, 17), 57, 18), 58, 19), 59, 20), 60, 21), 61, 22), 62, 23), 63, 24), 64, 25), 65, 26), 66, 27), 67, 28), 68, 29), 69, 30), 70, 31), 71, 244), 72, 177), 73, 178), 74, 179), 75, 180), 76, 181), 77, 182), 78, 183), 79, 184), 80, 185), 81, 186), 82, 187), 83, 188), 84, 189), 85, 190), 86, 191), 87, 192), 88, 193), 89, 194), 90, 195), 91, 196), 92, 197), 93, 198), 94, 199), 95, 200), 96, 201), 97, 202), 98, 203), 99, 204), 100, 205), 101, 206), 102, 207), 103, 208), 104, 32), 105, 33), 106, 34), 107, 35), 108, 36), 109, 37), 110, 38), 111, 39), 112, 40), 113, 41), 114, 42), 115, 43), 116, 44), 117, 45), 118, 46), 119, 47), 120, 48), 121, 49), 122, 50), 123, 51), 124, 52), 125, 53), 126, 54), 127, 55), 128, 56), 129, 57), 130, 58), 131, 59), 132, 60), 133, 61), 134, 62), 135, 63), 136, 64), 137, 65), 138, 66), 139, 67), 140, 68), 141, 69), 142, 70), 143, 71), 144, 72), 145, 73), 146, 74), 147, 75), 148, 76), 149, 77), 150, 78), 151, 79), 152, 80), 153, 81), 154, 82), 155, 83), 156, 84), 157, 85), 158, 86), 159, 87), 160, 88), 161, 89), 162, 90), 163, 91), 164, 92), 165, 93), 166, 94), 167, 95), 168, 96), 169, 97), 170, 98), 171, 99), 172, 100), 173, 101), 174, 102), 175, 103), 176, 104), 177, 105), 178, 106), 179, 107), 180, 108), 181, 109), 182, 110), 183, 111), 184, 112), 185, 113), 186, 114), 187, 115), 188, 116), 189, 117), 190, 118), 191, 119), 192, 120), 193, 121), 194, 122), 195, 123), 196, 124), 197, 125), 198, 126), 199, 127), 200, 128), 201, 129), 202, 130), 203, 131), 204, 132), 205, 133), 206, 134), 207, 135), 208, 136), 209, 137), 210, 138), 211, 139), 212, 140), 213, 584), 214, 141), 215, 142), 216, 143), 217, 144), 218, 145), 219, 146), 220, 147), 221, 148), 222, 149), 223, 150), 224, 151), 225, 152), 226, 153), 227, 154), 228, 155), 229, 156), 230, 157), 231, 158), 232, 159), 233, 160), 234, 161), 235, 162), 236, 163), 237, 164), 238, 165), 239, 166), 240, 167), 241, 168), 242, 169), 243, 170), 244, 171), 245, 172), 246, 173), 247, 174), 248, 175), 249, 176), 1000}, 1000))) == True{} : Bool}:
  P12_PRV.LightClientOptimisticUpdate_decode_vlit_ok_fixed()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_vlit_rt_fixed() -> {P13_PRV.rtc192(P13_PRV.rt(Pair.snd(P13_B.Buf, Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>, FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 0, 172), 1, 1), 17, 209), 18, 210), 19, 211), 20, 212), 21, 213), 22, 214), 23, 215), 24, 216), 25, 217), 26, 218), 27, 219), 28, 220), 29, 221), 30, 222), 31, 223), 32, 224), 33, 225), 34, 226), 35, 227), 36, 228), 37, 229), 38, 230), 39, 231), 40, 232), 41, 233), 42, 234), 43, 4), 44, 5), 45, 6), 46, 7), 47, 8), 48, 9), 49, 10), 50, 11), 51, 12), 52, 13), 53, 14), 54, 15), 55, 16), 56, 17), 57, 18), 58, 19), 59, 20), 60, 21), 61, 22), 62, 23), 63, 24), 64, 25), 65, 26), 66, 27), 67, 28), 68, 29), 69, 30), 70, 31), 71, 244), 72, 177), 73, 178), 74, 179), 75, 180), 76, 181), 77, 182), 78, 183), 79, 184), 80, 185), 81, 186), 82, 187), 83, 188), 84, 189), 85, 190), 86, 191), 87, 192), 88, 193), 89, 194), 90, 195), 91, 196), 92, 197), 93, 198), 94, 199), 95, 200), 96, 201), 97, 202), 98, 203), 99, 204), 100, 205), 101, 206), 102, 207), 103, 208), 104, 32), 105, 33), 106, 34), 107, 35), 108, 36), 109, 37), 110, 38), 111, 39), 112, 40), 113, 41), 114, 42), 115, 43), 116, 44), 117, 45), 118, 46), 119, 47), 120, 48), 121, 49), 122, 50), 123, 51), 124, 52), 125, 53), 126, 54), 127, 55), 128, 56), 129, 57), 130, 58), 131, 59), 132, 60), 133, 61), 134, 62), 135, 63), 136, 64), 137, 65), 138, 66), 139, 67), 140, 68), 141, 69), 142, 70), 143, 71), 144, 72), 145, 73), 146, 74), 147, 75), 148, 76), 149, 77), 150, 78), 151, 79), 152, 80), 153, 81), 154, 82), 155, 83), 156, 84), 157, 85), 158, 86), 159, 87), 160, 88), 161, 89), 162, 90), 163, 91), 164, 92), 165, 93), 166, 94), 167, 95), 168, 96), 169, 97), 170, 98), 171, 99), 172, 100), 173, 101), 174, 102), 175, 103), 176, 104), 177, 105), 178, 106), 179, 107), 180, 108), 181, 109), 182, 110), 183, 111), 184, 112), 185, 113), 186, 114), 187, 115), 188, 116), 189, 117), 190, 118), 191, 119), 192, 120), 193, 121), 194, 122), 195, 123), 196, 124), 197, 125), 198, 126), 199, 127), 200, 128), 201, 129), 202, 130), 203, 131), 204, 132), 205, 133), 206, 134), 207, 135), 208, 136), 209, 137), 210, 138), 211, 139), 212, 140), 213, 584), 214, 141), 215, 142), 216, 143), 217, 144), 218, 145), 219, 146), 220, 147), 221, 148), 222, 149), 223, 150), 224, 151), 225, 152), 226, 153), 227, 154), 228, 155), 229, 156), 230, 157), 231, 158), 232, 159), 233, 160), 234, 161), 235, 162), 236, 163), 237, 164), 238, 165), 239, 166), 240, 167), 241, 168), 242, 169), 243, 170), 244, 171), 245, 172), 246, 173), 247, 174), 248, 175), 249, 176), 1000}, 1000)))) == (1000, (172, (1, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (0, (209, (210, (211, (212, (213, (214, (215, (216, (217, (218, (219, (220, (221, (222, (223, (224, (225, (226, (227, (228, (229, (230, (231, (232, (233, (234, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (244, (177, (178, (179, (180, (181, (182, (183, (184, (185, (186, (187, (188, (189, (190, (191, (192, (193, (194, (195, (196, (197, (198, (199, (200, (201, (202, (203, (204, (205, (206, (207, (208, (32, (33, (34, (35, (36, (37, (38, (39, (40, (41, (42, (43, (44, (45, (46, (47, (48, (49, (50, (51, (52, (53, (54, (55, (56, (57, (58, (59, (60, (61, (62, (63, (64, (65, (66, (67, (68, (69, (70, (71, (72, (73, (74, (75, (76, (77, (78, (79, (80, (81, (82, (83, (84, (85, (86, (87, (88, (89, (90, (91, (92, (93, (94, (95, (96, (97, (98, (99, (100, (101, (102, (103, (104, (105, (106, (107, (108, (109, (110, (111, (112, (113, (114, (115, (116, (117, (118, 119)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))}:
  P13_PRV.LightClientOptimisticUpdate_decode_vlit_rt_fixed()

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_build(buf: P14_B.Buf, +size: U32, b2: P14_B.Buf, e: {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_ok(buf, 0, size) == (b2, True{}) : P14_B.Buf & Bool}, hwin: {U32.is_le(size, P14_DWL.bsz(buf)) == True{} : Bool}) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(buf, size) == FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_some(FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_build(b2, size)) : P14_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P14_PRV.LightClientOptimisticUpdate_decode_build(buf, size, b2, e, hwin)

