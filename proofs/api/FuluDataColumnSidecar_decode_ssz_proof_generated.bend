import Base
import ../../src/buffer.bend as P0_B
import ../../types/FuluDataColumnSidecar_def_generated.bend as FuluDataColumnSidecar_d
import ../../types/FuluDataColumnSidecar_decode_ssz_generated.bend as FuluDataColumnSidecar_r
import ../slop/offsets/fulu_DataColumnSidecar_first_offset_generated.bend as P0_PRV
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
import ../obj/vlist.bend as P1_VL
import ../obj/vmul_generated.bend as P1_VM
import ../obj/vmv_generated.bend as P1_VV
import ../obj/vvlz_generated.bend as P1_VZG
import ../obj/var_codec_DataColumnSidecar_generated.bend as P1_PRV
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
import ../obj/vlist.bend as P2_VL
import ../obj/vmul_generated.bend as P2_VM
import ../obj/vmv_generated.bend as P2_VV
import ../obj/vzeros_generated.bend as P2_VZ
import ../obj/var_fix_types_m_generated.bend as P2_VT
import ../obj/var_codec_DataColumnSidecar_generated.bend as P2_DC
import ../../proofs/obj/decode_window_library_generated.bend as P2_DWL
import ../../proofs/obj/decode_window_FuluDataColumnSidecar_generated.bend as P2_DW_FuluDataColumnSidecar
import ../obj/var_codec_DataColumnSidecar_acc_generated.bend as P2_PRV
import ../../types/schema.bend as P3_S
import ../../spec/decoding_relation.bend as P3_Decoding
import ../../spec/fulu_schemas.bend as P3_Spec
import ../compact/found_generated.bend as P3_F
import ../compact/arith.bend as P3_A
import ../obj/vbuf.bend as P3_VB
import ../obj/var_codec_DataColumnSidecar_generated.bend as P3_DC
import ../../proofs/decode_unique.bend as P3_DCO
import ../obj/var_codec_DataColumnSidecar_unique_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../../types/schema.bend as P4_S
import ../../types/primitive.bend as P4_P
import ../compact/found_generated.bend as P4_FD
import ../compact/arith.bend as P4_A
import ../../proofs/nat_order.bend as P4_Order
import ../../spec/primitives.bend as P4_SP
import ../../spec/layout.bend as P4_Layout
import ../../spec/codec.bend as P4_Codec
import ../../spec/decoding_relation.bend as P4_Decoding
import ../../spec/nat_bytes.bend as P4_N
import ../../spec/fulu_schemas.bend as P4_Spec
import ../obj/spec_fixed.bend as P4_F
import ../obj/vspec.bend as P4_VS
import ../obj/vbuf.bend as P4_VB
import ../obj/vu32.bend as P4_VU
import ../obj/vcopy.bend as P4_VC
import ../obj/vdepth.bend as P4_VD
import ../obj/vfix.bend as P4_VF
import ../obj/vlist.bend as P4_VL
import ../obj/vmul_generated.bend as P4_VM
import ../obj/vmv_generated.bend as P4_VV
import ../compact/bits_generated.bend as P4_BT
import ../../proofs/decode_shape.bend as P4_DS
import ../../proofs/decode_facts.bend as P4_DF
import ../obj/dk.bend as P4_DK
import ../obj/vrej.bend as P4_VR
import ../obj/vnest.bend as P4_VN
import ../obj/vdig.bend as P4_VG
import ../obj/vmr_generated.bend as P4_VMR
import ../obj/var_codec_DataColumnSidecar_generated.bend as P4_DC
import ../../proofs/obj/decode_window_library_generated.bend as P4_DWL
import ../../proofs/obj/decode_window_FuluDataColumnSidecar_generated.bend as P4_DW_FuluDataColumnSidecar
import ../obj/var_codec_DataColumnSidecar_rej_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_DataColumnSidecar_decode_checked_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_column_ragged_1_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_column_ragged_1024_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_column_ragged_2_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_commitments_ragged_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_commitments_ragged_1_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_commitments_ragged_2_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_commitments_ragged_24_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_commitments_ragged_47_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_commitments_ragged_50_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_proofs_ragged_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_proofs_ragged_1_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_proofs_ragged_2_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_proofs_ragged_24_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_proofs_ragged_47_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_kzg_proofs_ragged_50_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_off_minus_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_off_plus_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_order_kzg_commitments_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_bad_order_kzg_proofs_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_ok_default_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_ok_kzg_commitments_n1_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_ok_kzg_commitments_n2_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_ok_kzg_proofs_n1_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_DataColumnSidecar_decode_literal_ok_kzg_proofs_n2_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../obj/decode_window_library_generated.bend as P30_DWL
import ../slop/offsets/DataColumnSidecar_generated.bend as P30_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluDataColumnSidecar (DataColumnSidecar): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluDataColumnSidecar__decode_first_offset__DataColumnSidecar_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(356, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 8 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 356) == False{} : Bool}) -> {FuluDataColumnSidecar_r.DataColumnSidecar_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.DataColumnSidecar_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def FuluDataColumnSidecar__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(4n, P1_VB.pw(d)) == True{} : Bool}, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}) -> {FuluDataColumnSidecar_r.DataColumnSidecar_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, hd, hpo, pf)

def FuluDataColumnSidecar__decode_accept__decode_accept(+d: Nat, +t: P2_FD.array__Tree<U32>, +n: U32, +pf: {P2_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P2_VB.NMAX()) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}) -> {FuluDataColumnSidecar_r.DataColumnSidecar_decode(P2_DC.BF(t, n), n) == (P2_DC.BF(t, n), Some{P2_PRV.OBJ(t, n)}) : P2_B.Buf & Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P2_PRV.decode_accept(d, t, n, pf, hd, hn, hN, hchk)

def FuluDataColumnSidecar__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.DataColumnSidecar(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hN, hchk)

def FuluDataColumnSidecar__decode_unique__decode_unique(+d: Nat, +t: P3_F.array__Tree<U32>, +n: U32, +pf: {P3_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P3_A.quad(P3_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P3_VB.NMAX()) == True{} : Bool}, +hchk: {P3_DC.CHK(t, n) == True{} : Bool}, +v: P3_S.Value, spec: P3_Decoding.decodes(P3_Spec.DataColumnSidecar(), P3_DC.VW(t, n), v)) -> {v == P3_DC.VAL(t, n) : P3_S.Value}:
  P3_PRV.decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec)

def FuluDataColumnSidecar__decode_reject__decode_reject(+d: Nat, +t: P4_FD.array__Tree<U32>, +n: U32, +pf: {P4_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P4_A.quad(P4_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P4_VB.NMAX()) == True{} : Bool}, +hchk: {P4_DC.CHK(t, n) == False{} : Bool}) -> P4_Decoding.outside_image(P4_Spec.DataColumnSidecar(), P4_DC.VW(t, n)):
  P4_PRV.decode_reject(d, t, n, pf, hd, hn, hN, hchk)

def FuluDataColumnSidecar__decode_none__decode_none(+d: Nat, +t: P4_FD.array__Tree<U32>, +n: U32, +pf: {P4_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P4_A.quad(P4_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P4_VB.NMAX()) == True{} : Bool}, +hchk: {P4_DC.CHK(t, n) == False{} : Bool}) -> {FuluDataColumnSidecar_r.DataColumnSidecar_decode(P4_DC.BF(t, n), n) == (P4_DC.BF(t, n), None{}) : P4_B.Buf & Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P4_PRV.decode_none(d, t, n, pf, hd, hn, hN, hchk)

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_limit() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_dchw(4294967265, 4294967265, (P5_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P5_PRV.DataColumnSidecar_decode_vchecked_limit()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_nmax_wrap(buf: P5_B.Buf) -> {FuluDataColumnSidecar_r.DataColumnSidecar_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P5_B.Buf & Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P5_PRV.DataColumnSidecar_decode_vchecked_nmax_wrap(buf)

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_nmax_above(buf: P5_B.Buf) -> {FuluDataColumnSidecar_r.DataColumnSidecar_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P5_B.Buf & Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P5_PRV.DataColumnSidecar_decode_vchecked_nmax_above(buf)

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_accept() -> {P5_PRV.is_some(Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_dchw(356, 356, (P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 356}, 89))), Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode_checked(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 356}, 356))) == (True{}, True{}) : Bool & Bool}:
  P5_PRV.DataColumnSidecar_decode_vchecked_accept()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_window() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_dchw(356, 355, (P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 356}, 89))) == None{} : Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P5_PRV.DataColumnSidecar_decode_vchecked_window()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_storage() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_dchw(356, 356, (P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 356}, 88))) == None{} : Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P5_PRV.DataColumnSidecar_decode_vchecked_storage()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_short() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode_checked(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 355}, 356)) == None{} : Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P5_PRV.DataColumnSidecar_decode_vchecked_short()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_real() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode_checked(P5_B.Buf{Array.new(U32, 0n, 0), 356}, 356)) == None{} : Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P5_PRV.DataColumnSidecar_decode_vchecked_real()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_column_ragged_1() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 357), 4, 357), 357}, 357))) == False{} : Bool}:
  P6_PRV.DataColumnSidecar_decode_vlit_bad_column_ragged_1()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_column_ragged_1024() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 2, 356), 3, 1380), 4, 1380), 1380}, 1380))) == False{} : Bool}:
  P7_PRV.DataColumnSidecar_decode_vlit_bad_column_ragged_1024()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_column_ragged_2() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 358), 4, 358), 358}, 358))) == False{} : Bool}:
  P8_PRV.DataColumnSidecar_decode_vlit_bad_column_ragged_2()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 405), 405}, 405))) == False{} : Bool}:
  P9_PRV.DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_1() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 357), 357}, 357))) == False{} : Bool}:
  P10_PRV.DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_1()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_2() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 358), 358}, 358))) == False{} : Bool}:
  P11_PRV.DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_2()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_24() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 380), 380}, 380))) == False{} : Bool}:
  P12_PRV.DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_24()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_47() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 403), 403}, 403))) == False{} : Bool}:
  P13_PRV.DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_47()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_50() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 406), 406}, 406))) == False{} : Bool}:
  P14_PRV.DataColumnSidecar_decode_vlit_bad_kzg_commitments_ragged_50()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 405}, 405))) == False{} : Bool}:
  P15_PRV.DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_1() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 357}, 357))) == False{} : Bool}:
  P16_PRV.DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_1()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_2() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 358}, 358))) == False{} : Bool}:
  P17_PRV.DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_2()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_24() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 380}, 380))) == False{} : Bool}:
  P18_PRV.DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_24()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_47() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 403}, 403))) == False{} : Bool}:
  P19_PRV.DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_47()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_50() -> {P20_PRV.some1(Pair.snd(P20_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 406}, 406))) == False{} : Bool}:
  P20_PRV.DataColumnSidecar_decode_vlit_bad_kzg_proofs_ragged_50()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_off_minus() -> {P21_PRV.some1(Pair.snd(P21_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 355), 3, 356), 4, 356), 356}, 356))) == False{} : Bool}:
  P21_PRV.DataColumnSidecar_decode_vlit_bad_off_minus()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_off_plus() -> {P22_PRV.some1(Pair.snd(P22_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 357), 3, 356), 4, 356), 357}, 357))) == False{} : Bool}:
  P22_PRV.DataColumnSidecar_decode_vlit_bad_off_plus()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_order_kzg_commitments() -> {P23_PRV.some1(Pair.snd(P23_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 355), 4, 356), 356}, 356))) == False{} : Bool}:
  P23_PRV.DataColumnSidecar_decode_vlit_bad_order_kzg_commitments()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_bad_order_kzg_proofs() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 355), 356}, 356))) == False{} : Bool}:
  P24_PRV.DataColumnSidecar_decode_vlit_bad_order_kzg_proofs()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_ok_default() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 356}, 356))) == True{} : Bool}:
  P25_PRV.DataColumnSidecar_decode_vlit_ok_default()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_ok_kzg_commitments_n1() -> {P26_PRV.some1(Pair.snd(P26_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P26_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 404), 404}, 404))) == True{} : Bool}:
  P26_PRV.DataColumnSidecar_decode_vlit_ok_kzg_commitments_n1()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_ok_kzg_commitments_n2() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 452), 452}, 452))) == True{} : Bool}:
  P27_PRV.DataColumnSidecar_decode_vlit_ok_kzg_commitments_n2()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_ok_kzg_proofs_n1() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 404}, 404))) == True{} : Bool}:
  P28_PRV.DataColumnSidecar_decode_vlit_ok_kzg_proofs_n1()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vlit_ok_kzg_proofs_n2() -> {P29_PRV.some1(Pair.snd(P29_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_decode(P29_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 2, 356), 3, 356), 4, 356), 452}, 452))) == True{} : Bool}:
  P29_PRV.DataColumnSidecar_decode_vlit_ok_kzg_proofs_n2()

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_build(buf: P30_B.Buf, +size: U32, b2: P30_B.Buf, e: {FuluDataColumnSidecar_r.DataColumnSidecar_ok(buf, 0, size) == (b2, True{}) : P30_B.Buf & Bool}, hwin: {U32.is_le(size, P30_DWL.bsz(buf)) == True{} : Bool}) -> {FuluDataColumnSidecar_r.DataColumnSidecar_decode(buf, size) == FuluDataColumnSidecar_r.DataColumnSidecar_some(FuluDataColumnSidecar_r.DataColumnSidecar_build(b2, size)) : P30_B.Buf & Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P30_PRV.DataColumnSidecar_decode_build(buf, size, b2, e, hwin)

