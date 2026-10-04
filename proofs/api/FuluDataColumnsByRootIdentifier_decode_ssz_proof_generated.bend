import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/FuluDataColumnsByRootIdentifier_def_generated.bend as FuluDataColumnsByRootIdentifier_d
import ../../types/FuluDataColumnsByRootIdentifier_decode_ssz_generated.bend as FuluDataColumnsByRootIdentifier_r
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
import ../../spec/schema.bend as P0_SC
import ../obj/vseq.bend as P0_VSQ
import ../../proofs/obj/decode_window_library_generated.bend as P0_DWL
import ../../proofs/obj/decode_window_FuluDataColumnsByRootIdentifier_generated.bend as P0_DW_FuluDataColumnsByRootIdentifier
import ../obj/var_codec_DataColumnsByRootIdentifier_generated.bend as P0_PRV
import ../../types/schema.bend as P1_S
import ../../spec/decoding_relation.bend as P1_Decoding
import ../../spec/fulu_schemas.bend as P1_Spec
import ../compact/found_generated.bend as P1_F
import ../compact/arith.bend as P1_A
import ../obj/vbuf.bend as P1_VB
import ../obj/var_codec_DataColumnsByRootIdentifier_generated.bend as P1_DC
import ../../proofs/decode_unique.bend as P1_DCO
import ../obj/var_codec_DataColumnsByRootIdentifier_unique_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/obj.bend as P2_O
import ../../types/schema.bend as P2_S
import ../../types/primitive.bend as P2_P
import ../compact/found_generated.bend as P2_F
import ../compact/arith.bend as P2_A
import ../compact/bits_generated.bend as P2_BT
import ../../proofs/nat_order.bend as P2_Order
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
import ../obj/var_codec_DataColumnsByRootIdentifier_generated.bend as P2_DC
import ../../proofs/obj/decode_window_library_generated.bend as P2_DWL
import ../../proofs/obj/decode_window_FuluDataColumnsByRootIdentifier_generated.bend as P2_DW_FuluDataColumnsByRootIdentifier
import ../obj/var_codec_DataColumnsByRootIdentifier_rej_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_columns_over_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_columns_ragged_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_columns_ragged_1_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_columns_ragged_10_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_columns_ragged_2_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_columns_ragged_4_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_columns_ragged_7_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_off_minus_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_bad_off_plus_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_ok_columns_n1_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_ok_columns_n2_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_ok_default_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_ok_marked_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_rt_columns_n1_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_rt_columns_n2_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_rt_default_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_DataColumnsByRootIdentifier_decode_literal_rt_marked_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../obj/decode_window_library_generated.bend as P21_DWL
import ../slop/offsets/DataColumnsByRootIdentifier_generated.bend as P21_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluDataColumnsByRootIdentifier (DataColumnsByRootIdentifier): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluDataColumnsByRootIdentifier__ok_eval__ok_eval(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(8n, P0_VB.pw(d)) == True{} : Bool}, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}) -> {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_ok(P0_PRV.BF(t, n), 0, n) == (P0_PRV.BF(t, n), P0_PRV.CHK(t, n)) : P0_B.Buf & Bool}:
  P0_PRV.ok_eval(d, t, n, hd, hpo, pf)

def FuluDataColumnsByRootIdentifier__decode_accept__decode_accept(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P0_PRV.BF(t, n), n) == (P0_PRV.BF(t, n), Some{P0_PRV.OBJ(t, n)}) : P0_B.Buf & Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P0_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def FuluDataColumnsByRootIdentifier__decode_spec__decode_spec(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +hchk: {P0_PRV.CHK(t, n) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.DataColumnsByRootIdentifier(), P0_PRV.VW(t, n), P0_PRV.VAL(t, n)):
  P0_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def FuluDataColumnsByRootIdentifier__decode_unique__decode_unique(+d: Nat, +t: P1_F.array__Tree<U32>, +n: U32, +pf: {P1_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_DC.CHK(t, n) == True{} : Bool}, +v: P1_S.Value, spec: P1_Decoding.decodes(P1_Spec.DataColumnsByRootIdentifier(), P1_DC.VW(t, n), v)) -> {v == P1_DC.VAL(t, n) : P1_S.Value}:
  P1_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def FuluDataColumnsByRootIdentifier__decode_reject__decode_reject(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == False{} : Bool}) -> P2_Decoding.outside_image(P2_Spec.DataColumnsByRootIdentifier(), P2_DC.VW(t, n)):
  P2_PRV.decode_reject(d, t, n, pf, hn, hchk)

def FuluDataColumnsByRootIdentifier__decode_none__decode_none(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == False{} : Bool}) -> {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P2_DC.BF(t, n), n) == (P2_DC.BF(t, n), None{}) : P2_B.Buf & Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P2_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_limit()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_nmax_wrap(buf)

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_nmax_above(buf)

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_nmax_at(buf: P3_B.Buf) -> {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dchw(4294967264, 4294967264, (buf, 1073741816)) == FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dgo(True{}, buf, 4294967264) : P3_B.Buf & Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_nmax_at(buf)

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_at_2pow31(buf: P3_B.Buf) -> {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dchw(2147483648, 2147483648, (buf, 536870912)) == FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dgo(True{}, buf, 2147483648) : P3_B.Buf & Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_at_2pow31(buf)

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dchw(36, 36, (P3_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 36}, 9))), Pair.snd(P3_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 36}, 36))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_accept()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dchw(36, 35, (P3_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 36}, 9))) == None{} : Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_window()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_dchw(36, 36, (P3_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 36}, 8))) == None{} : Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_storage()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode_checked(P3_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 35}, 36)) == None{} : Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_short()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode_checked(P3_B.Buf{Array.new(U32, 0n, 0), 36}, 36)) == None{} : Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P3_PRV.DataColumnsByRootIdentifier_decode_vchecked_real()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_columns_over() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P4_B.Buf{Array.set(U32, Array.new(U32, 9n, 0), 8, 36), 1068}, 1068))) == False{} : Bool}:
  P4_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_columns_over()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P5_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 45}, 45))) == False{} : Bool}:
  P5_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_1() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P6_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 37}, 37))) == False{} : Bool}:
  P6_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_1()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_10() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P7_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 46}, 46))) == False{} : Bool}:
  P7_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_10()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_2() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P8_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 38}, 38))) == False{} : Bool}:
  P8_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_2()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_4() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P9_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 40}, 40))) == False{} : Bool}:
  P9_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_4()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_7() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P10_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 43}, 43))) == False{} : Bool}:
  P10_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_columns_ragged_7()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_off_minus() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P11_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 35), 36}, 36))) == False{} : Bool}:
  P11_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_off_minus()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_bad_off_plus() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P12_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 37), 37}, 37))) == False{} : Bool}:
  P12_PRV.DataColumnsByRootIdentifier_decode_vlit_bad_off_plus()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_ok_columns_n1() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P13_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 44}, 44))) == True{} : Bool}:
  P13_PRV.DataColumnsByRootIdentifier_decode_vlit_ok_columns_n1()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_ok_columns_n2() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P14_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 52}, 52))) == True{} : Bool}:
  P14_PRV.DataColumnsByRootIdentifier_decode_vlit_ok_columns_n2()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_ok_default() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P15_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 36}, 36))) == True{} : Bool}:
  P15_PRV.DataColumnsByRootIdentifier_decode_vlit_ok_default()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_ok_marked() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 9, 4), 11, 4), 52}, 52))) == True{} : Bool}:
  P16_PRV.DataColumnsByRootIdentifier_decode_vlit_ok_marked()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_rt_columns_n1() -> {(Pair.snd(P17_B.Buf, U32, P17_B.size(P17_PRV.rt(Pair.snd(P17_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P17_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 44}, 44))))), P17_PRV.rw11(P17_PRV.rt(Pair.snd(P17_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P17_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 44}, 44))), 0)) == (44, (0, (0, (0, (0, (0, (0, (0, (0, (36, (0, 0))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))}:
  P17_PRV.DataColumnsByRootIdentifier_decode_vlit_rt_columns_n1()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_rt_columns_n2() -> {(Pair.snd(P18_B.Buf, U32, P18_B.size(P18_PRV.rt(Pair.snd(P18_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P18_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 52}, 52))))), P18_PRV.rw13(P18_PRV.rt(Pair.snd(P18_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P18_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 52}, 52))), 0)) == (52, (0, (0, (0, (0, (0, (0, (0, (0, (36, (0, (0, (0, 0))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))}:
  P18_PRV.DataColumnsByRootIdentifier_decode_vlit_rt_columns_n2()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_rt_default() -> {(Pair.snd(P19_B.Buf, U32, P19_B.size(P19_PRV.rt(Pair.snd(P19_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P19_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 36}, 36))))), P19_PRV.rw9(P19_PRV.rt(Pair.snd(P19_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P19_B.Buf{Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 36}, 36))), 0)) == (36, (0, (0, (0, (0, (0, (0, (0, (0, 36))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))}:
  P19_PRV.DataColumnsByRootIdentifier_decode_vlit_rt_default()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_vlit_rt_marked() -> {(Pair.snd(P20_B.Buf, U32, P20_B.size(P20_PRV.rt(Pair.snd(P20_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 9, 4), 11, 4), 52}, 52))))), P20_PRV.rw13(P20_PRV.rt(Pair.snd(P20_B.Buf, Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>, FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 8, 36), 9, 4), 11, 4), 52}, 52))), 0)) == (52, (0, (0, (0, (0, (0, (0, (0, (0, (36, (4, (0, (4, 0))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32)))))))))))))}:
  P20_PRV.DataColumnsByRootIdentifier_decode_vlit_rt_marked()

def FuluDataColumnsByRootIdentifier__decode_offsets__DataColumnsByRootIdentifier_decode_build(buf: P21_B.Buf, +size: U32, b2: P21_B.Buf, e: {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_ok(buf, 0, size) == (b2, True{}) : P21_B.Buf & Bool}, hwin: {U32.is_le(size, P21_DWL.bsz(buf)) == True{} : Bool}) -> {FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_decode(buf, size) == FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_some(FuluDataColumnsByRootIdentifier_r.DataColumnsByRootIdentifier_build(b2, size)) : P21_B.Buf & Maybe<&1, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier>}:
  P21_PRV.DataColumnsByRootIdentifier_decode_build(buf, size, b2, e, hwin)

