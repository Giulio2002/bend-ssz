import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/ProgressiveSingleListContainerTestStruct_decode_ssz_generated.bend as ProgressiveSingleListContainerTestStruct_r
import ../../types/ProgressiveSingleFieldContainerTestStruct_def_generated.bend as ProgressiveSingleFieldContainerTestStruct_d
import ../../types/ProgressiveSingleFieldContainerTestStruct_decode_ssz_generated.bend as ProgressiveSingleFieldContainerTestStruct_r
import ../../types/ProgressiveVarTestStruct_decode_ssz_generated.bend as ProgressiveVarTestStruct_r
import ../../types/CompatibleUnionABCA_def_generated.bend as CompatibleUnionABCA_d
import ../../types/CompatibleUnionABCA_decode_ssz_generated.bend as CompatibleUnionABCA_r
import ../../types/CompatibleUnionABCA_encode_ssz_generated.bend as CompatibleUnionABCA_e
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
import ../obj/vpb29.bend as P0_VP
import ../obj/var_winx_ProgressiveSingleListContainerTestStruct_generated.bend as P0_CH1
import ../obj/var_winx_ProgressiveVarTestStruct_generated.bend as P0_CH2
import ../obj/generic_specs_generated.bend as P0_Spec
import ../../spec/schema.bend as P0_SS
import ../obj/spec_fixed.bend as P0_F
import ../obj/vspec.bend as P0_VS
import ../obj/vbuf.bend as P0_VB
import ../obj/vu32.bend as P0_VU
import ../obj/vcopy.bend as P0_VC
import ../obj/vdepth.bend as P0_VD
import ../obj/vfix.bend as P0_VF
import ../obj/var_fix_types_generated.bend as P0_VT
import ../obj/spec_bits_generated.bend as P0_FB
import ../obj/vfits.bend as P0_VFT
import ../obj/vlist.bend as P0_VLS
import ../obj/vbitl.bend as P0_VBL
import ../obj/vbyte_generated.bend as P0_VY
import ../obj/vbrt.bend as P0_VR
import ../obj/vbitc.bend as P0_VBC
import ../obj/vrej.bend as P0_VRJ
import ../obj/vnest.bend as P0_VN
import ../obj/dk.bend as P0_DK
import ../../spec/bitfields.bend as P0_Bits
import ../../spec/bit_packing.bend as P0_Bp
import ../obj/var_winx_CompatibleUnionABCA_generated.bend as P0_W
import ../../proofs/obj/decode_window_library_generated.bend as P0_DWL
import ../../proofs/obj/decode_window_CompatibleUnionABCA_generated.bend as P0_DW_CompatibleUnionABCA
import ../obj/var_codec_CompatibleUnionABCA_generated.bend as P0_PRV
import ../../src/buffer.bend as P1_B
import ../../src/obj.bend as P1_O
import ../slop/alignment/CompatibleUnionABCA_union_arm_generated.bend as P1_PRV
import ../../types/schema.bend as P2_S
import ../../spec/decoding_relation.bend as P2_Decoding
import ../compact/found_generated.bend as P2_FD
import ../compact/arith.bend as P2_A
import ../obj/vbuf.bend as P2_VB
import ../obj/generic_specs_generated.bend as P2_GS
import ../obj/var_codec_CompatibleUnionABCA_generated.bend as P2_DC
import ../../proofs/decode_complete.bend as P2_DCO
import ../obj/var_codec_CompatibleUnionABCA_unique_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/size/CompatibleUnionABCA_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_checked_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_bad_sel_255_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_bad_sel_5_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_bad_selector_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_ok_default_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_ok_sel_1_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_ok_sel_2_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_ok_sel_3_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_ok_sel_4_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_CompatibleUnionABCA_decode_literal_rt_default_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_CompatibleUnionABCA_selectors_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../obj/decode_window_library_generated.bend as P15_DWL
import ../slop/offsets/CompatibleUnionABCA_generated.bend as P15_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# CompatibleUnionABCA: its decode_ssz laws in the object API's terms, each discharged by its proving law.

def CompatibleUnionABCA__ok_eval__ok_eval(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok(P0_PRV.BF(t, n), 0, n) == (P0_PRV.BF(t, n), P0_PRV.CHK(t, n)) : P0_B.Buf & Bool}:
  P0_PRV.ok_eval(d, t, n, pf, hd, hn, hN)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_ok3_t(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok3(True{}, s, buf, off, len) == ProgressiveSingleFieldContainerTestStruct_r.ProgressiveSingleFieldContainerTestStruct_ok(buf, (off + 1 : U32), (len - 1 : U32)) : P1_B.Buf & Bool}:
  P1_PRV.CompatibleUnionABCA_ua_ok3_t(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_ok3_f(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok3(False{}, s, buf, off, len) == (buf, False{}) : P1_B.Buf & Bool}:
  P1_PRV.CompatibleUnionABCA_ua_ok3_f(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_ok2_t(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok2(True{}, s, buf, off, len) == ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_ok(buf, (off + 1 : U32), (len - 1 : U32)) : P1_B.Buf & Bool}:
  P1_PRV.CompatibleUnionABCA_ua_ok2_t(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_ok2_f(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok2(False{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_ok3(U32.is_eq(s, 4), s, buf, off, len) : P1_B.Buf & Bool}:
  P1_PRV.CompatibleUnionABCA_ua_ok2_f(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_ok1_t(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok1(True{}, s, buf, off, len) == ProgressiveSingleListContainerTestStruct_r.ProgressiveSingleListContainerTestStruct_ok(buf, (off + 1 : U32), (len - 1 : U32)) : P1_B.Buf & Bool}:
  P1_PRV.CompatibleUnionABCA_ua_ok1_t(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_ok1_f(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok1(False{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_ok2(U32.is_eq(s, 3), s, buf, off, len) : P1_B.Buf & Bool}:
  P1_PRV.CompatibleUnionABCA_ua_ok1_f(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_ok0_t(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok0(True{}, s, buf, off, len) == ProgressiveSingleFieldContainerTestStruct_r.ProgressiveSingleFieldContainerTestStruct_ok(buf, (off + 1 : U32), (len - 1 : U32)) : P1_B.Buf & Bool}:
  P1_PRV.CompatibleUnionABCA_ua_ok0_t(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_ok0_f(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_ok0(False{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_ok1(U32.is_eq(s, 2), s, buf, off, len) : P1_B.Buf & Bool}:
  P1_PRV.CompatibleUnionABCA_ua_ok0_f(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_rd3_t(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_rd3(True{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_rw3(ProgressiveSingleFieldContainerTestStruct_r.ProgressiveSingleFieldContainerTestStruct_read(buf, (off + 1 : U32), (len - 1 : U32))) : P1_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P1_PRV.CompatibleUnionABCA_ua_rd3_t(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_rd3_f(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_rd3(False{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_rw0(ProgressiveSingleFieldContainerTestStruct_r.ProgressiveSingleFieldContainerTestStruct_read(buf, (off + 1 : U32), (len - 1 : U32))) : P1_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P1_PRV.CompatibleUnionABCA_ua_rd3_f(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_rd2_t(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_rd2(True{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_rw2(ProgressiveVarTestStruct_r.ProgressiveVarTestStruct_read(buf, (off + 1 : U32), (len - 1 : U32))) : P1_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P1_PRV.CompatibleUnionABCA_ua_rd2_t(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_rd2_f(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_rd2(False{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_rd3(U32.is_eq(s, 4), s, buf, off, len) : P1_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P1_PRV.CompatibleUnionABCA_ua_rd2_f(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_rd1_t(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_rd1(True{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_rw1(ProgressiveSingleListContainerTestStruct_r.ProgressiveSingleListContainerTestStruct_read(buf, (off + 1 : U32), (len - 1 : U32))) : P1_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P1_PRV.CompatibleUnionABCA_ua_rd1_t(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_rd1_f(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_rd1(False{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_rd2(U32.is_eq(s, 3), s, buf, off, len) : P1_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P1_PRV.CompatibleUnionABCA_ua_rd1_f(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_rd0_t(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_rd0(True{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_rw0(ProgressiveSingleFieldContainerTestStruct_r.ProgressiveSingleFieldContainerTestStruct_read(buf, (off + 1 : U32), (len - 1 : U32))) : P1_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P1_PRV.CompatibleUnionABCA_ua_rd0_t(s, buf, off, len)

def CompatibleUnionABCA__ok_eval__CompatibleUnionABCA_ua_rd0_f(+s: U32, buf: P1_B.Buf, +off: U32, +len: U32) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_rd0(False{}, s, buf, off, len) == CompatibleUnionABCA_r.CompatibleUnionABCA_rd1(U32.is_eq(s, 2), s, buf, off, len) : P1_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P1_PRV.CompatibleUnionABCA_ua_rd0_f(s, buf, off, len)

def CompatibleUnionABCA__decode_accept__decode_accept(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), Some{P0_PRV.OBJ(d, t, n)}) : P0_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P0_PRV.decode_accept(d, t, n, pf, hd, hn, hN, hchk)

def CompatibleUnionABCA__decode_spec__decode_spec(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.CompatibleUnionABCA(), P0_PRV.VW(t, n), P0_PRV.VAL(t, n)):
  P0_PRV.decode_spec(d, t, n, pf, hd, hn, hN, hchk)

def CompatibleUnionABCA__decode_unique__decode_unique(+d: Nat, +t: P2_FD.array__Tree<U32>, +n: U32, +pf: {P2_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P2_VB.NMAX()) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}, +v: P2_S.Value, spec: P2_Decoding.decodes(P2_GS.CompatibleUnionABCA(), P2_DC.VW(t, n), v)) -> {v == P2_DC.VAL(t, n) : P2_S.Value}:
  P2_PRV.decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec)

def CompatibleUnionABCA__decode_reject__decode_reject(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == False{} : Bool}, +hPB: {P0_PRV.PBQ(t, n) == True{} : Bool}) -> P0_Decoding.outside_image(P0_Spec.CompatibleUnionABCA(), P0_PRV.VW(t, n)):
  P0_PRV.decode_reject(d, t, n, pf, hd, hn, hN, hchk, hPB)

def CompatibleUnionABCA__decode_none__decode_none(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P0_VB.NMAX()) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == False{} : Bool}) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), None{}) : P0_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P0_PRV.decode_none(d, t, n, pf, hd, hn, hN, hchk)

def CompatibleUnionABCA__decode_input__CompatibleUnionABCA_ms_armbad() -> {CompatibleUnionABCA_r.CompatibleUnionABCA_read(P3_B.Buf{P3_O.or_word(Pair.fst(Array<U32>, CompatibleUnionABCA_d.CompatibleUnionABCA, CompatibleUnionABCA_e.CompatibleUnionABCA_put(P3_O.out_at(3n), 0, CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)})), 0, 128), Pair.snd(P3_B.Buf, U32, P3_B.size(Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)}))))}, 0, Pair.snd(P3_B.Buf, U32, P3_B.size(Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)}))))) == (P3_B.Buf{P3_O.or_word(Pair.fst(Array<U32>, CompatibleUnionABCA_d.CompatibleUnionABCA, CompatibleUnionABCA_e.CompatibleUnionABCA_put(P3_O.out_at(3n), 0, CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)})), 0, 128), Pair.snd(P3_B.Buf, U32, P3_B.size(Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)}))))}, CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)}) : P3_B.Buf & CompatibleUnionABCA_d.CompatibleUnionABCA}:
  P3_PRV.CompatibleUnionABCA_ms_armbad()

def CompatibleUnionABCA__decode_input__CompatibleUnionABCA_ms_arm0() -> {CompatibleUnionABCA_r.CompatibleUnionABCA_decode(Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)})), Pair.snd(P3_B.Buf, U32, P3_B.size(Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)}))))) == (Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)})), Some{CompatibleUnionABCA_d.CompatibleUnionABCA_c0{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)}}) : P3_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P3_PRV.CompatibleUnionABCA_ms_arm0()

def CompatibleUnionABCA__decode_input__CompatibleUnionABCA_ms_arm3() -> {CompatibleUnionABCA_r.CompatibleUnionABCA_decode(Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c3{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)})), Pair.snd(P3_B.Buf, U32, P3_B.size(Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c3{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)}))))) == (Pair.snd(CompatibleUnionABCA_d.CompatibleUnionABCA, P3_B.Buf, CompatibleUnionABCA_e.CompatibleUnionABCA_encode(CompatibleUnionABCA_d.CompatibleUnionABCA_c3{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)})), Some{CompatibleUnionABCA_d.CompatibleUnionABCA_c3{ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct_seed(2271560481)}}) : P3_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P3_PRV.CompatibleUnionABCA_ms_arm3()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_limit() -> {Pair.snd(P4_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_dchw(4294967265, 4294967265, (P4_B.empty(), 1073741824))) == None{} : Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_limit()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_nmax_wrap(buf: P4_B.Buf) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P4_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_nmax_wrap(buf)

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_nmax_above(buf: P4_B.Buf) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P4_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_nmax_above(buf)

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_nmax_at(buf: P4_B.Buf) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_dchw(4294967264, 4294967264, (buf, 1073741816)) == CompatibleUnionABCA_r.CompatibleUnionABCA_dgo(True{}, buf, 4294967264) : P4_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_nmax_at(buf)

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_at_2pow31(buf: P4_B.Buf) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_dchw(2147483648, 2147483648, (buf, 536870912)) == CompatibleUnionABCA_r.CompatibleUnionABCA_dgo(True{}, buf, 2147483648) : P4_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_at_2pow31(buf)

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_accept() -> {P4_PRV.is_some(Pair.snd(P4_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_dchw(2, 2, (P4_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 1))), Pair.snd(P4_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode_checked(P4_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 2))) == (True{}, True{}) : Bool & Bool}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_accept()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_window() -> {Pair.snd(P4_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_dchw(2, 1, (P4_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 1))) == None{} : Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_window()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_storage() -> {Pair.snd(P4_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_dchw(2, 2, (P4_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 0))) == None{} : Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_storage()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_short() -> {Pair.snd(P4_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode_checked(P4_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 1}, 2)) == None{} : Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_short()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_budget_agree(buf: P4_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(CompatibleUnionABCA_r.CompatibleUnionABCA_dcost(size), 4294967295), U32.is_le(CompatibleUnionABCA_r.CompatibleUnionABCA_dcost(size), budget)) == True{} : Bool}) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_decode_checked_budget(buf, size, budget) == CompatibleUnionABCA_r.CompatibleUnionABCA_decode_checked(buf, size) : P4_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_budget_agree(buf, size, budget, h)

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vchecked_budget_accept() -> {P4_PRV.is_some(Pair.snd(P4_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode_checked_budget(P4_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 2, 4294967295)), Pair.snd(P4_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode_checked(P4_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 2))) == (True{}, True{}) : Bool & Bool}:
  P4_PRV.CompatibleUnionABCA_decode_vchecked_budget_accept()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_bad_sel_255() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P5_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 255), 2}, 2))) == False{} : Bool}:
  P5_PRV.CompatibleUnionABCA_decode_vlit_bad_sel_255()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_bad_sel_5() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P6_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 5), 2}, 2))) == False{} : Bool}:
  P6_PRV.CompatibleUnionABCA_decode_vlit_bad_sel_5()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_bad_selector() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P7_B.Buf{Array.new(U32, 0n, 0), 2}, 2))) == False{} : Bool}:
  P7_PRV.CompatibleUnionABCA_decode_vlit_bad_selector()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_ok_default() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P8_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 2))) == True{} : Bool}:
  P8_PRV.CompatibleUnionABCA_decode_vlit_ok_default()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_ok_sel_1() -> {P9_PRV.selof(Pair.snd(P9_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P9_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 2))) == 1 : U32}:
  P9_PRV.CompatibleUnionABCA_decode_vlit_ok_sel_1()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_ok_sel_2() -> {P10_PRV.selof(Pair.snd(P10_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 1026), 1, 256), 6}, 6))) == 2 : U32}:
  P10_PRV.CompatibleUnionABCA_decode_vlit_ok_sel_2()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_ok_sel_3() -> {P11_PRV.selof(Pair.snd(P11_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 589827), 1, 589824), 2, 65536), 11}, 11))) == 3 : U32}:
  P11_PRV.CompatibleUnionABCA_decode_vlit_ok_sel_3()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_ok_sel_4() -> {P12_PRV.selof(Pair.snd(P12_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P12_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 4), 2}, 2))) == 4 : U32}:
  P12_PRV.CompatibleUnionABCA_decode_vlit_ok_sel_4()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vlit_rt_default() -> {(Pair.snd(P13_B.Buf, U32, P13_B.size(P13_PRV.rt(Pair.snd(P13_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P13_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 2))))), P13_PRV.rw1(P13_PRV.rt(Pair.snd(P13_B.Buf, Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>, CompatibleUnionABCA_r.CompatibleUnionABCA_decode(P13_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 1), 2}, 2))), 0)) == (2, 1) : U32 & (U32)}:
  P13_PRV.CompatibleUnionABCA_decode_vlit_rt_default()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vsel_outside() -> {(Pair.snd(P14_B.Buf, Bool, CompatibleUnionABCA_r.CompatibleUnionABCA_ok(P14_B.Buf{Array.new(U32, 0n, 0), 2}, 0, 2)), (Pair.snd(P14_B.Buf, Bool, CompatibleUnionABCA_r.CompatibleUnionABCA_ok(P14_B.Buf{Array.new(U32, 0n, 5), 2}, 0, 2)), Pair.snd(P14_B.Buf, Bool, CompatibleUnionABCA_r.CompatibleUnionABCA_ok(P14_B.Buf{Array.new(U32, 0n, 255), 2}, 0, 2)))) == (False{}, (False{}, False{})) : Bool & (Bool & (Bool))}:
  P14_PRV.CompatibleUnionABCA_decode_vsel_outside()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vsel_empty() -> {Pair.snd(P14_B.Buf, Bool, CompatibleUnionABCA_r.CompatibleUnionABCA_ok(P14_B.Buf{Array.new(U32, 0n, 1), 1}, 0, 1)) == False{} : Bool}:
  P14_PRV.CompatibleUnionABCA_decode_vsel_empty()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_vsel_arms() -> {(Pair.snd(P14_B.Buf, Bool, CompatibleUnionABCA_r.CompatibleUnionABCA_ok(P14_B.Buf{Array.new(U32, 0n, 1), 2}, 0, 2)), Pair.snd(P14_B.Buf, Bool, CompatibleUnionABCA_r.CompatibleUnionABCA_ok(P14_B.Buf{Array.new(U32, 0n, 4), 2}, 0, 2))) == (True{}, True{}) : Bool & (Bool)}:
  P14_PRV.CompatibleUnionABCA_decode_vsel_arms()

def CompatibleUnionABCA__decode_offsets__CompatibleUnionABCA_decode_build(buf: P15_B.Buf, +size: U32, b2: P15_B.Buf, e: {CompatibleUnionABCA_r.CompatibleUnionABCA_ok(buf, 0, size) == (b2, True{}) : P15_B.Buf & Bool}, hwin: {U32.is_le(size, P15_DWL.bsz(buf)) == True{} : Bool}) -> {CompatibleUnionABCA_r.CompatibleUnionABCA_decode(buf, size) == CompatibleUnionABCA_r.CompatibleUnionABCA_some(CompatibleUnionABCA_r.CompatibleUnionABCA_build(b2, size)) : P15_B.Buf & Maybe<&1, CompatibleUnionABCA_d.CompatibleUnionABCA>}:
  P15_PRV.CompatibleUnionABCA_decode_build(buf, size, b2, e, hwin)

