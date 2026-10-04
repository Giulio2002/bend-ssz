import Base
import ../../src/buffer.bend as P0_B
import ../../types/FuluLightClientHeader_def_generated.bend as FuluLightClientHeader_d
import ../../types/FuluLightClientHeader_decode_ssz_generated.bend as FuluLightClientHeader_r
import ../slop/offsets/fulu_LightClientHeader_first_offset_generated.bend as P0_PRV
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
import ../obj/vbytes.bend as P1_VY
import ../obj/vbspec.bend as P1_VZ
import ../obj/var_bytes_fix_generated.bend as P1_VT
import ../obj/var_bytes_LightClientHeader_win_generated.bend as P1_W
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_FuluLightClientHeader_generated.bend as P1_DW_FuluLightClientHeader
import ../obj/var_bytes_LightClientHeader_generated.bend as P1_PRV
import ../../types/schema.bend as P2_S
import ../../spec/decoding_relation.bend as P2_Decoding
import ../../spec/fulu_schemas.bend as P2_Spec
import ../compact/found_generated.bend as P2_F
import ../compact/arith.bend as P2_A
import ../obj/vbuf.bend as P2_VB
import ../obj/var_bytes_LightClientHeader_generated.bend as P2_DC
import ../../proofs/decode_unique.bend as P2_DCO
import ../obj/var_bytes_LightClientHeader_unique_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../../types/schema.bend as P3_S
import ../../types/primitive.bend as P3_P
import ../compact/found_generated.bend as P3_F
import ../compact/arith.bend as P3_A
import ../compact/bits_generated.bend as P3_BT
import ../../proofs/nat_order.bend as P3_Order
import ../../proofs/primitive_invariants.bend as P3_V
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
import ../obj/vfix.bend as P3_VF
import ../obj/vbspec.bend as P3_VZ
import ../obj/var_bytes_LightClientHeader_win_generated.bend as P3_W
import ../obj/var_bytes_LightClientHeader_generated.bend as P3_DC
import ../obj/var_bytes_ExecutionPayloadHeader_win_generated.bend as P3_YW
import ../obj/var_bytes_ExecutionPayloadHeader_rej_generated.bend as P3_YR
import ../../proofs/obj/decode_window_library_generated.bend as P3_DWL
import ../../proofs/obj/decode_window_FuluLightClientHeader_generated.bend as P3_DW_FuluLightClientHeader
import ../obj/var_bytes_LightClientHeader_rej_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_LightClientHeader_decode_checked_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_LightClientHeader_decode_literal_bad_execution_extra_data_over_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_LightClientHeader_decode_literal_bad_execution_off_minus_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_LightClientHeader_decode_literal_bad_execution_off_plus_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_LightClientHeader_decode_literal_bad_off_minus_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_LightClientHeader_decode_literal_bad_off_plus_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_LightClientHeader_decode_literal_ok_default_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../obj/decode_window_library_generated.bend as P11_DWL
import ../slop/offsets/LightClientHeader_generated.bend as P11_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluLightClientHeader (LightClientHeader): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluLightClientHeader__decode_first_offset__LightClientHeader_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(244, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 112 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 244) == False{} : Bool}) -> {FuluLightClientHeader_r.LightClientHeader_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.LightClientHeader_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def FuluLightClientHeader__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}) -> {FuluLightClientHeader_r.LightClientHeader_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, pf, hd, hn)

def FuluLightClientHeader__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {FuluLightClientHeader_r.LightClientHeader_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(t, n)}) : P1_B.Buf & Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def FuluLightClientHeader__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.LightClientHeader(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def FuluLightClientHeader__decode_unique__decode_unique(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}, +v: P2_S.Value, spec: P2_Decoding.decodes(P2_Spec.LightClientHeader(), P2_DC.VW(t, n), v)) -> {v == P2_DC.VAL(t, n) : P2_S.Value}:
  P2_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def FuluLightClientHeader__decode_reject__decode_reject(+d: Nat, +t: P3_F.array__Tree<U32>, +n: U32, +pf: {P3_F.array__perfect(U32, d, t) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P3_A.quad(P3_VB.pw(d))) == True{} : Bool}, +hchk: {P3_DC.CHK(t, n) == False{} : Bool}) -> P3_Decoding.outside_image(P3_Spec.LightClientHeader(), P3_DC.VW(t, n)):
  P3_PRV.decode_reject(d, t, n, pf, hn, hchk)

def FuluLightClientHeader__decode_none__decode_none(+d: Nat, +t: P3_F.array__Tree<U32>, +n: U32, +pf: {P3_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P3_A.quad(P3_VB.pw(d))) == True{} : Bool}, +hchk: {P3_DC.CHK(t, n) == False{} : Bool}) -> {FuluLightClientHeader_r.LightClientHeader_decode(P3_DC.BF(t, n), n) == (P3_DC.BF(t, n), None{}) : P3_B.Buf & Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P3_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_limit() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_dchw(4294967265, 4294967265, (P4_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_limit()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_nmax_wrap(buf: P4_B.Buf) -> {FuluLightClientHeader_r.LightClientHeader_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P4_B.Buf & Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_nmax_wrap(buf)

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_nmax_above(buf: P4_B.Buf) -> {FuluLightClientHeader_r.LightClientHeader_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P4_B.Buf & Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_nmax_above(buf)

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_nmax_at(buf: P4_B.Buf) -> {FuluLightClientHeader_r.LightClientHeader_dchw(4294967264, 4294967264, (buf, 1073741816)) == FuluLightClientHeader_r.LightClientHeader_dgo(True{}, buf, 4294967264) : P4_B.Buf & Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_nmax_at(buf)

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_at_2pow31(buf: P4_B.Buf) -> {FuluLightClientHeader_r.LightClientHeader_dchw(2147483648, 2147483648, (buf, 536870912)) == FuluLightClientHeader_r.LightClientHeader_dgo(True{}, buf, 2147483648) : P4_B.Buf & Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_at_2pow31(buf)

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_accept() -> {P4_PRV.is_some(Pair.snd(P4_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_dchw(828, 828, (P4_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 584), 828}, 207))), Pair.snd(P4_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode_checked(P4_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 584), 828}, 828))) == (True{}, True{}) : Bool & Bool}:
  P4_PRV.LightClientHeader_decode_vchecked_accept()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_window() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_dchw(828, 827, (P4_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 584), 828}, 207))) == None{} : Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_window()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_storage() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_dchw(828, 828, (P4_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 584), 828}, 206))) == None{} : Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_storage()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_short() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode_checked(P4_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 584), 827}, 828)) == None{} : Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_short()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vchecked_real() -> {Pair.snd(P4_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode_checked(P4_B.Buf{Array.new(U32, 0n, 0), 828}, 828)) == None{} : Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P4_PRV.LightClientHeader_decode_vchecked_real()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vlit_bad_execution_extra_data_over() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 584), 861}, 861))) == False{} : Bool}:
  P5_PRV.LightClientHeader_decode_vlit_bad_execution_extra_data_over()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vlit_bad_execution_off_minus() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 583), 828}, 828))) == False{} : Bool}:
  P6_PRV.LightClientHeader_decode_vlit_bad_execution_off_minus()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vlit_bad_execution_off_plus() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 585), 829}, 829))) == False{} : Bool}:
  P7_PRV.LightClientHeader_decode_vlit_bad_execution_off_plus()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vlit_bad_off_minus() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 243), 170, 584), 828}, 828))) == False{} : Bool}:
  P8_PRV.LightClientHeader_decode_vlit_bad_off_minus()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vlit_bad_off_plus() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 245), 170, 584), 829}, 829))) == False{} : Bool}:
  P9_PRV.LightClientHeader_decode_vlit_bad_off_plus()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_vlit_ok_default() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluLightClientHeader_d.LightClientHeader>, FuluLightClientHeader_r.LightClientHeader_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 28, 244), 170, 584), 828}, 828))) == True{} : Bool}:
  P10_PRV.LightClientHeader_decode_vlit_ok_default()

def FuluLightClientHeader__decode_offsets__LightClientHeader_decode_build(buf: P11_B.Buf, +size: U32, b2: P11_B.Buf, e: {FuluLightClientHeader_r.LightClientHeader_ok(buf, 0, size) == (b2, True{}) : P11_B.Buf & Bool}, hwin: {U32.is_le(size, P11_DWL.bsz(buf)) == True{} : Bool}) -> {FuluLightClientHeader_r.LightClientHeader_decode(buf, size) == FuluLightClientHeader_r.LightClientHeader_some(FuluLightClientHeader_r.LightClientHeader_build(b2, size)) : P11_B.Buf & Maybe<&1, FuluLightClientHeader_d.LightClientHeader>}:
  P11_PRV.LightClientHeader_decode_build(buf, size, b2, e, hwin)

