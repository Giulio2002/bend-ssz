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
import ../obj/decode_window_library_generated.bend as P6_DWL
import ../slop/offsets/DataColumnSidecar_generated.bend as P6_PRV

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

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_vchecked_limit() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>, FuluDataColumnSidecar_r.DataColumnSidecar_dchw(2147483648, 2147483648, (P5_B.empty(), 536870912))) == None{} : Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P5_PRV.DataColumnSidecar_decode_vchecked_limit()

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

def FuluDataColumnSidecar__decode_offsets__DataColumnSidecar_decode_build(buf: P6_B.Buf, +size: U32, b2: P6_B.Buf, e: {FuluDataColumnSidecar_r.DataColumnSidecar_ok(buf, 0, size) == (b2, True{}) : P6_B.Buf & Bool}, hwin: {U32.is_le(size, P6_DWL.bsz(buf)) == True{} : Bool}) -> {FuluDataColumnSidecar_r.DataColumnSidecar_decode(buf, size) == FuluDataColumnSidecar_r.DataColumnSidecar_some(FuluDataColumnSidecar_r.DataColumnSidecar_build(b2, size)) : P6_B.Buf & Maybe<&1, FuluDataColumnSidecar_d.DataColumnSidecar>}:
  P6_PRV.DataColumnSidecar_decode_build(buf, size, b2, e, hwin)

