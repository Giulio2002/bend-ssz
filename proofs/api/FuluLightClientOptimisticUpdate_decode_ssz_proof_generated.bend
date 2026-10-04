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
import ../obj/decode_window_library_generated.bend as P12_DWL
import ../slop/offsets/LightClientOptimisticUpdate_generated.bend as P12_PRV

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

def FuluLightClientOptimisticUpdate__decode_offsets__LightClientOptimisticUpdate_decode_build(buf: P12_B.Buf, +size: U32, b2: P12_B.Buf, e: {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_ok(buf, 0, size) == (b2, True{}) : P12_B.Buf & Bool}, hwin: {U32.is_le(size, P12_DWL.bsz(buf)) == True{} : Bool}) -> {FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_decode(buf, size) == FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_some(FuluLightClientOptimisticUpdate_r.LightClientOptimisticUpdate_build(b2, size)) : P12_B.Buf & Maybe<&1, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate>}:
  P12_PRV.LightClientOptimisticUpdate_decode_build(buf, size, b2, e, hwin)

