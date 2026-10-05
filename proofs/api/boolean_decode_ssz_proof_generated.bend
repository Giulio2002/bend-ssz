import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/boolean_def_generated.bend as boolean_d
import ../../types/boolean_decode_ssz_generated.bend as boolean_r
import ../../types/boolean_encode_ssz_generated.bend as boolean_e
import ../../types/schema.bend as P0_S
import ../../spec/codec.bend as P0_Codec
import ../../spec/decoding_relation.bend as P0_Decoding
import ../../spec/schema.bend as P0_SS
import ../../proofs/decode_shape.bend as P0_DS
import ../../spec/fulu_schemas.bend as P0_Spec
import ../compact/found_generated.bend as P0_FD
import ../compact/arith.bend as P0_A
import ../obj/vbuf.bend as P0_VB
import ../obj/vua.bend as P0_UA
import ../obj/vua_win.bend as P0_UW
import ../obj/vua_fix_generated.bend as P0_VTX
import ../obj/vrl_generated.bend as P0_VRL
import ../obj/vrejb_generated.bend as P0_VRB
import ../obj/fixchk_boolf_generated.bend as P0_PRV
import ../../src/buffer.bend as P1_B
import ../../src/obj.bend as P1_O
import ../../types/schema.bend as P1_S
import ../../types/primitive.bend as P1_P
import ../../spec/codec.bend as P1_Codec
import ../../spec/decoding_relation.bend as P1_Decoding
import ../../spec/fulu_schemas.bend as P1_Spec
import ../../proofs/compact/bits_generated.bend as P1_BT
import ../../proofs/compact/found_generated.bend as P1_FD
import ../../proofs/word_facts.bend as P1_WF
import ../../spec/primitives.bend as P1_SP
import ../../proofs/integer_encoding.bend as P1_IE
import ../obj/spec_fixed.bend as P1_SF
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_FuluBytes1_generated.bend as P1_DW_FuluBytes1
import ../../proofs/obj/decode_window_FuluParticipationFlags_generated.bend as P1_DW_FuluParticipationFlags
import ../../proofs/obj/decode_window_boolean_generated.bend as P1_DW_boolean
import ../../proofs/obj/decode_window_uint8_generated.bend as P1_DW_uint8
import ../obj/spec_small_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/obj.bend as P2_O
import ../../types/schema.bend as P2_S
import ../../types/primitive.bend as P2_P
import ../../spec/codec.bend as P2_Codec
import ../../spec/primitives.bend as P2_SP
import ../../spec/decoding_relation.bend as P2_Decoding
import ../../spec/fulu_schemas.bend as P2_Spec
import ../../proofs/compact/found_generated.bend as P2_F
import ../obj/spec_fixed.bend as P2_SF
import ../obj/sub_pack_generated.bend as P2_SP2
import ../obj/word_mul_generated.bend as P2_WM
import ../../proofs/obj/decode_window_library_generated.bend as P2_DWL
import ../../proofs/obj/decode_window_boolean_generated.bend as P2_DW_boolean
import ../obj/sub_boolean_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../types/schema.bend as P3_S
import ../../types/primitive.bend as P3_P
import ../../spec/decoding_relation.bend as P3_Decoding
import ../../spec/fulu_schemas.bend as P3_Spec
import ../decode_unique.bend as P3_E
import ../../proofs/compact/found_generated.bend as P3_FD
import ../obj/spec_small_generated.bend as P3_SM
import ../obj/spec_unique_small_generated.bend as P3_PRV
import ../../types/schema.bend as P4_S
import ../../types/primitive.bend as P4_P
import ../../src/obj.bend as P4_O
import ../../src/buffer.bend as P4_B
import ../../spec/decoding_relation.bend as P4_Decoding
import ../../spec/fulu_schemas.bend as P4_Spec
import ../decode_unique.bend as P4_E
import ../type_validator_soundness.bend as P4_VS
import ../obj/spec_fixed.bend as P4_SF
import ../../proofs/compact/found_generated.bend as P4_F
import ../obj/sub_pack_generated.bend as P4_SP2
import ../obj/spec_bits_generated.bend as P4_FB
import ../../spec/primitives.bend as P4_SP
import ../obj/sub_boolean_generated.bend as P4_C
import ../obj/sub_unique_boolean_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../obj/codec_0_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../../proofs/compact/found_generated.bend as P6_FD
import ../obj/repr.bend as P6_R
import ../obj/spec_fixed.bend as P6_F
import ../obj/spec_small_generated.bend as P6_C
import ../obj/spec_repr_small_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/size/boolean_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_boolean_decode_checked_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_boolean_decode_literal_bad_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_boolean_decode_literal_ok_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_boolean_decode_literal_rt_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../obj/decode_window_library_generated.bend as P12_DWL
import ../slop/offsets/boolean_generated.bend as P12_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# boolean: its decode_ssz laws in the object API's terms, each discharged by its proving law.

def boolean__ok_eval__boolean_ok_eval(+d: Nat, +t: P0_FD.array__Tree<U32>, +n: U32, +off: U32, +x: Nat, +e: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +pf: {P0_FD.array__perfect(U32, d, t) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(x, 1n), P0_A.quad(P0_VB.pw(d))) == True{} : Bool}, +len: U32) -> {boolean_r.bool_ok(P0_UA.BF(t, n), off, len) == (P0_UA.BF(t, n), Bool.and(U32.is_eq(len, 1), P0_VRB.ALLB(P0_UW.WX(t, x, 1n)))) : P0_B.Buf & Bool}:
  P0_PRV.boolean_ok_eval(d, t, n, off, x, e, hd, pf, hb, len)

def boolean__decode_accept__boolean_spec_decode_0(+w: U32, +h: {P1_B.byte_sel(0, w) == 0 : U32}) -> {boolean_r.boolean_decode(P1_B.Buf{ALeaf{w}, 1}, 1) == (P1_B.Buf{ALeaf{w}, 1}, Some{False{}}) : P1_B.Buf & Maybe<&1, Bool>}:
  P1_PRV.boolean_spec_decode_0(w, h)

def boolean__decode_accept__boolean_spec_decode_1(+w: U32, +h: {P1_B.byte_sel(0, w) == 1 : U32}) -> {boolean_r.boolean_decode(P1_B.Buf{ALeaf{w}, 1}, 1) == (P1_B.Buf{ALeaf{w}, 1}, Some{True{}}) : P1_B.Buf & Maybe<&1, Bool>}:
  P1_PRV.boolean_spec_decode_1(w, h)

def boolean__decode_accept__boolean_spec_decode(+x0: U32, +hb: {U32.is_le(P2_B.byte_sel(0, x0), 1) == True{} : Bool}) -> {boolean_r.boolean_decode(P2_B.Buf{ALeaf{x0}, 1}, 1) == (P2_B.Buf{ALeaf{x0}, 1}, Some{U32.is_eq(P2_B.byte_sel(0, x0), 1)}) : P2_B.Buf & Maybe<&1, Bool>}:
  P2_PRV.boolean_spec_decode(x0, hb)

def boolean__decode_spec__boolean_true_spec_encode() -> P1_Decoding.decodes(P1_Spec.boolean(), [1], P1_S.BooleanValue{True{}}):
  P1_PRV.boolean_true_spec_encode()

def boolean__decode_spec__boolean_false_spec_encode() -> P1_Decoding.decodes(P1_Spec.boolean(), [0], P1_S.BooleanValue{False{}}):
  P1_PRV.boolean_false_spec_encode()

def boolean__decode_spec__boolean_spec_encode(+x0: U32, +hb: {U32.is_le(P2_B.byte_sel(0, x0), 1) == True{} : Bool}) -> P2_Decoding.decodes(P2_Spec.boolean(), [P2_B.byte_sel(0, x0)], P2_S.BooleanValue{U32.is_eq(P2_B.byte_sel(0, x0), 1)}):
  P2_PRV.boolean_spec_encode(x0, hb)

def boolean__decode_unique__boolean_spec_unique_0(+w: U32, +h: {P3_B.byte_sel(0, w) == 0 : U32}, +v: P3_S.Value, spec: P3_Decoding.decodes(P3_Spec.boolean(), [P3_B.byte_sel(0, w)], v)) -> {v == P3_S.BooleanValue{False{}} : P3_S.Value}:
  P3_PRV.boolean_spec_unique_0(w, h, v, spec)

def boolean__decode_unique__boolean_spec_unique_1(+w: U32, +h: {P3_B.byte_sel(0, w) == 1 : U32}, +v: P3_S.Value, spec: P3_Decoding.decodes(P3_Spec.boolean(), [P3_B.byte_sel(0, w)], v)) -> {v == P3_S.BooleanValue{True{}} : P3_S.Value}:
  P3_PRV.boolean_spec_unique_1(w, h, v, spec)

def boolean__decode_unique__boolean_spec_unique(+x0: U32, +hb: {U32.is_le(P4_B.byte_sel(0, x0), 1) == True{} : Bool}, +v: P4_S.Value, spec: P4_Decoding.decodes(P4_Spec.boolean(), [P4_B.byte_sel(0, x0)], v)) -> {v == P4_S.BooleanValue{U32.is_eq(P4_B.byte_sel(0, x0), 1)} : P4_S.Value}:
  P4_PRV.boolean_spec_unique(x0, hb, v, spec)

def boolean__decode_reject__boolean_decode_reject(+bs: +List<U32>, +h: {Bool.and(Nat.is_eq(List.length(&2, U32, bs), 1n), P0_VRB.ALLB(bs)) == False{} : Bool}) -> P0_Decoding.outside_image(P0_Spec.boolean(), bs):
  P0_PRV.boolean_decode_reject(bs, h)

def boolean__decode_reject__boolean_outside(+c: U32, +h: {U32.is_le(c, 1) == False{} : Bool}) -> P1_Decoding.outside_image(P1_Spec.boolean(), [c]):
  P1_PRV.boolean_outside(c, h)

def boolean__decode_reject__boolean_spec_reject_outside(+w: U32, +h: {U32.is_le(P1_B.byte_sel(0, w), 1) == False{} : Bool}) -> P1_Decoding.outside_image(P1_Spec.boolean(), [P1_B.byte_sel(0, w)]):
  P1_PRV.boolean_spec_reject_outside(w, h)

def boolean__decode_none__boolean_spec_decode_reject(+w: U32, +h: {U32.is_le(P1_B.byte_sel(0, w), 1) == False{} : Bool}) -> {boolean_r.boolean_decode(P1_B.Buf{ALeaf{w}, 1}, 1) == (P1_B.Buf{ALeaf{w}, 1}, None{}) : P1_B.Buf & Maybe<&1, Bool>}:
  P1_PRV.boolean_spec_decode_reject(w, h)

def boolean__decode_none__boolean_spec_reject(buf: P1_B.Buf, +m: U32, e: {U32.is_eq(m, 1) == False{} : Bool}) -> {boolean_r.boolean_decode(buf, m) == (buf, None{}) : P1_B.Buf & Maybe<&1, Bool>}:
  P1_PRV.boolean_spec_reject(buf, m, e)

def boolean__decode_none__boolean_spec_reject_bool(+x0: U32, +hb: {U32.is_le(P2_B.byte_sel(0, x0), 1) == False{} : Bool}) -> {boolean_r.boolean_decode(P2_B.Buf{ALeaf{x0}, 1}, 1) == (P2_B.Buf{ALeaf{x0}, 1}, None{}) : P2_B.Buf & Maybe<&1, Bool>}:
  P2_PRV.boolean_spec_reject_bool(x0, hb)

def boolean__decode_none__boolean_spec_reject_2(buf: P2_B.Buf, +m: U32, e: {U32.is_eq(m, 1) == False{} : Bool}) -> {boolean_r.boolean_decode(buf, m) == (buf, None{}) : P2_B.Buf & Maybe<&1, Bool>}:
  P2_PRV.boolean_spec_reject(buf, m, e)

def boolean__reject_short__boolean_t_reject_short() -> {boolean_r.boolean_decode(boolean_e.boolean_encode(True{}), 0) == (boolean_e.boolean_encode(True{}), None{}) : P5_B.Buf & Maybe<&1, Bool>}:
  P5_PRV.boolean_t_reject_short()

def boolean__reject_short__boolean_f_reject_short() -> {boolean_r.boolean_decode(boolean_e.boolean_encode(False{}), 0) == (boolean_e.boolean_encode(False{}), None{}) : P5_B.Buf & Maybe<&1, Bool>}:
  P5_PRV.boolean_f_reject_short()

def boolean__reject_long__boolean_t_reject_long() -> {boolean_r.boolean_decode(boolean_e.boolean_encode(True{}), 2) == (boolean_e.boolean_encode(True{}), None{}) : P5_B.Buf & Maybe<&1, Bool>}:
  P5_PRV.boolean_t_reject_long()

def boolean__reject_long__boolean_f_reject_long() -> {boolean_r.boolean_decode(boolean_e.boolean_encode(False{}), 2) == (boolean_e.boolean_encode(False{}), None{}) : P5_B.Buf & Maybe<&1, Bool>}:
  P5_PRV.boolean_f_reject_long()

def boolean__decode_tree__boolean_spec_decode_0_tree(+t: P6_FD.array__Tree<U32>, +pf: {P6_FD.array__perfect(U32, 0n, t) == True{} : Bool}, +h: {P6_B.byte_sel(0, P6_R.w(t, 0n)) == 0 : U32}) -> {boolean_r.boolean_decode(P6_B.Buf{P6_FD.array__thaw(U32, t), 1}, 1) == (P6_B.Buf{P6_FD.array__thaw(U32, t), 1}, Some{False{}}) : P6_B.Buf & Maybe<&1, Bool>}:
  P6_PRV.boolean_spec_decode_0_tree(t, pf, h)

def boolean__decode_tree__boolean_spec_decode_1_tree(+t: P6_FD.array__Tree<U32>, +pf: {P6_FD.array__perfect(U32, 0n, t) == True{} : Bool}, +h: {P6_B.byte_sel(0, P6_R.w(t, 0n)) == 1 : U32}) -> {boolean_r.boolean_decode(P6_B.Buf{P6_FD.array__thaw(U32, t), 1}, 1) == (P6_B.Buf{P6_FD.array__thaw(U32, t), 1}, Some{True{}}) : P6_B.Buf & Maybe<&1, Bool>}:
  P6_PRV.boolean_spec_decode_1_tree(t, pf, h)

def boolean__decode_input__boolean_ms_build() -> {boolean_r.boolean_build(P7_B.Buf{boolean_e.bool_put(P7_O.out_at(2n), 0, boolean_d.bool_seed(2271560481)), 1}, 1) == (P7_B.Buf{boolean_e.bool_put(P7_O.out_at(2n), 0, boolean_d.bool_seed(2271560481)), 1}, boolean_d.bool_seed(2271560481)) : P7_B.Buf & Bool}:
  P7_PRV.boolean_ms_build()

def boolean__decode_input__boolean_ms_dec() -> {(boolean_r.boolean_decode(P7_B.Buf{boolean_e.bool_put(P7_O.out_at(2n), 0, boolean_d.bool_seed(2271560481)), 1}, 1), boolean_r.boolean_decode(P7_B.Buf{boolean_e.bool_put(P7_O.out_at(2n), 0, boolean_d.bool_seed(2271560482)), 1}, 1)) == ((P7_B.Buf{boolean_e.bool_put(P7_O.out_at(2n), 0, boolean_d.bool_seed(2271560481)), 1}, Some{boolean_d.bool_seed(2271560481)}), (P7_B.Buf{boolean_e.bool_put(P7_O.out_at(2n), 0, boolean_d.bool_seed(2271560482)), 1}, Some{boolean_d.bool_seed(2271560482)})) : (P7_B.Buf & Maybe<&1, Bool>) & (P7_B.Buf & Maybe<&1, Bool>)}:
  P7_PRV.boolean_ms_dec()

def boolean__decode_offsets__boolean_decode_vchecked_limit() -> {Pair.snd(P8_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_dchw(4294967265, 4294967265, (P8_B.empty(), 1073741824))) == None{} : Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_limit()

def boolean__decode_offsets__boolean_decode_vchecked_nmax_wrap(buf: P8_B.Buf) -> {boolean_r.boolean_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P8_B.Buf & Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_nmax_wrap(buf)

def boolean__decode_offsets__boolean_decode_vchecked_nmax_above(buf: P8_B.Buf) -> {boolean_r.boolean_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P8_B.Buf & Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_nmax_above(buf)

def boolean__decode_offsets__boolean_decode_vchecked_nmax_at(buf: P8_B.Buf) -> {boolean_r.boolean_dchw(4294967264, 4294967264, (buf, 1073741816)) == boolean_r.boolean_dgo(True{}, buf, 4294967264) : P8_B.Buf & Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_nmax_at(buf)

def boolean__decode_offsets__boolean_decode_vchecked_at_2pow31(buf: P8_B.Buf) -> {boolean_r.boolean_dchw(2147483648, 2147483648, (buf, 536870912)) == boolean_r.boolean_dgo(True{}, buf, 2147483648) : P8_B.Buf & Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_at_2pow31(buf)

def boolean__decode_offsets__boolean_decode_vchecked_accept() -> {P8_PRV.is_some(Pair.snd(P8_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_dchw(1, 1, (P8_B.Buf{Array.new(U32, 0n, 0), 1}, 1))), Pair.snd(P8_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode_checked(P8_B.Buf{Array.new(U32, 0n, 0), 1}, 1))) == (True{}, True{}) : Bool & Bool}:
  P8_PRV.boolean_decode_vchecked_accept()

def boolean__decode_offsets__boolean_decode_vchecked_window() -> {Pair.snd(P8_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_dchw(1, 0, (P8_B.Buf{Array.new(U32, 0n, 0), 1}, 1))) == None{} : Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_window()

def boolean__decode_offsets__boolean_decode_vchecked_storage() -> {Pair.snd(P8_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_dchw(1, 1, (P8_B.Buf{Array.new(U32, 0n, 0), 1}, 0))) == None{} : Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_storage()

def boolean__decode_offsets__boolean_decode_vchecked_short() -> {Pair.snd(P8_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode_checked(P8_B.Buf{Array.new(U32, 0n, 0), 0}, 1)) == None{} : Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_short()

def boolean__decode_offsets__boolean_decode_vchecked_storage_size(buf: P8_B.Buf) -> {boolean_r.boolean_dchw(1, 1, (buf, 0)) == (buf, None{}) : P8_B.Buf & Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_storage_size(buf)

def boolean__decode_offsets__boolean_decode_vchecked_budget_agree(buf: P8_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(boolean_r.boolean_dcost(size), 4294967295), U32.is_le(boolean_r.boolean_dcost(size), budget)) == True{} : Bool}) -> {boolean_r.boolean_decode_checked_budget(buf, size, budget) == boolean_r.boolean_decode_checked(buf, size) : P8_B.Buf & Maybe<&1, Bool>}:
  P8_PRV.boolean_decode_vchecked_budget_agree(buf, size, budget, h)

def boolean__decode_offsets__boolean_decode_vchecked_budget_accept() -> {P8_PRV.is_some(Pair.snd(P8_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode_checked_budget(P8_B.Buf{Array.new(U32, 0n, 0), 1}, 1, 4294967295)), Pair.snd(P8_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode_checked(P8_B.Buf{Array.new(U32, 0n, 0), 1}, 1))) == (True{}, True{}) : Bool & Bool}:
  P8_PRV.boolean_decode_vchecked_budget_accept()

def boolean__decode_offsets__boolean_decode_vlit_bad_short() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode(P9_B.Buf{Array.new(U32, 0n, 0), 0}, 0))) == False{} : Bool}:
  P9_PRV.boolean_decode_vlit_bad_short()

def boolean__decode_offsets__boolean_decode_vlit_bad_long() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode(P9_B.Buf{Array.new(U32, 0n, 0), 2}, 2))) == False{} : Bool}:
  P9_PRV.boolean_decode_vlit_bad_long()

def boolean__decode_offsets__boolean_decode_vlit_bad_bool2() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode(P9_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 2), 1}, 1))) == False{} : Bool}:
  P9_PRV.boolean_decode_vlit_bad_bool2()

def boolean__decode_offsets__boolean_decode_vlit_ok_default() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode(P10_B.Buf{Array.new(U32, 0n, 0), 1}, 1))) == True{} : Bool}:
  P10_PRV.boolean_decode_vlit_ok_default()

def boolean__decode_offsets__boolean_decode_vlit_rt_default() -> {(Pair.snd(P11_B.Buf, U32, P11_B.size(P11_PRV.rt(Pair.snd(P11_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode(P11_B.Buf{Array.new(U32, 0n, 0), 1}, 1))))), P11_PRV.rw1(P11_PRV.rt(Pair.snd(P11_B.Buf, Maybe<&1, Bool>, boolean_r.boolean_decode(P11_B.Buf{Array.new(U32, 0n, 0), 1}, 1))), 0)) == (1, 0) : U32 & (U32)}:
  P11_PRV.boolean_decode_vlit_rt_default()

def boolean__decode_offsets__boolean_decode_build(buf: P12_B.Buf, +size: U32, b2: P12_B.Buf, e: {boolean_r.bool_ok(buf, 0, size) == (b2, True{}) : P12_B.Buf & Bool}, hwin: {U32.is_le(size, P12_DWL.bsz(buf)) == True{} : Bool}) -> {boolean_r.boolean_decode(buf, size) == boolean_r.boolean_some(boolean_r.boolean_build(b2, size)) : P12_B.Buf & Maybe<&1, Bool>}:
  P12_PRV.boolean_decode_build(buf, size, b2, e, hwin)

