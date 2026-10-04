import Base
import ../../src/buffer.bend as P0_B
import ../../types/FuluBeaconBlockBody_def_generated.bend as FuluBeaconBlockBody_d
import ../../types/FuluBeaconBlockBody_decode_ssz_generated.bend as FuluBeaconBlockBody_r
import ../slop/offsets/fulu_BeaconBlockBody_first_offset_generated.bend as P0_PRV
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
import ../obj/var_winx_BeaconBlockBody_generated.bend as P1_EW
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_FuluBeaconBlockBody_generated.bend as P1_DW_FuluBeaconBlockBody
import ../obj/var_codec_BeaconBlockBody_generated.bend as P1_PRV
import ../../src/buffer.bend as P2_B
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_BeaconBlockBody_and_pair_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_BeaconBlockBody_decode_checked_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attestations_elem_aggregation_bits_nodelim_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attestations_elem_off_minus_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attestations_elem_off_plus_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attestations_first_past_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attestations_off0_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attestations_off5_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attestations_off_desc_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attestations_off_past_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_elem_attestation_1_off_plus_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_elem_off_minus_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_elem_off_plus_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_elem_order_attestation_2_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_first_past_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_off0_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_off5_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_off_desc_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_off_past_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_attester_slashings_over_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_deposits_ragged_1_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_deposits_ragged_2_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_deposits_ragged_620_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_execution_payload_extra_data_over_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_execution_payload_off_minus_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_execution_payload_off_plus_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_execution_payload_order_transactions_generated.bend as P28_PRV
import ../../src/buffer.bend as P29_B
import ../../src/obj.bend as P29_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_execution_payload_order_withdrawals_generated.bend as P29_PRV
import ../../src/buffer.bend as P30_B
import ../../src/obj.bend as P30_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_execution_payload_transactions_off0_generated.bend as P30_PRV
import ../../src/buffer.bend as P31_B
import ../../src/obj.bend as P31_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_execution_payload_transactions_off5_generated.bend as P31_PRV
import ../../src/buffer.bend as P32_B
import ../../src/obj.bend as P32_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_off_minus_generated.bend as P32_PRV
import ../../src/buffer.bend as P33_B
import ../../src/obj.bend as P33_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_off_plus_generated.bend as P33_PRV
import ../../src/buffer.bend as P34_B
import ../../src/obj.bend as P34_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_order_attestations_generated.bend as P34_PRV
import ../../src/buffer.bend as P35_B
import ../../src/obj.bend as P35_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_order_attester_slashings_generated.bend as P35_PRV
import ../../src/buffer.bend as P36_B
import ../../src/obj.bend as P36_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_order_blob_kzg_commitments_generated.bend as P36_PRV
import ../../src/buffer.bend as P37_B
import ../../src/obj.bend as P37_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_order_bls_to_execution_changes_generated.bend as P37_PRV
import ../../src/buffer.bend as P38_B
import ../../src/obj.bend as P38_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_order_deposits_generated.bend as P38_PRV
import ../../src/buffer.bend as P39_B
import ../../src/obj.bend as P39_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_order_execution_payload_generated.bend as P39_PRV
import ../../src/buffer.bend as P40_B
import ../../src/obj.bend as P40_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_order_execution_requests_generated.bend as P40_PRV
import ../../src/buffer.bend as P41_B
import ../../src/obj.bend as P41_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_order_voluntary_exits_generated.bend as P41_PRV
import ../../src/buffer.bend as P42_B
import ../../src/obj.bend as P42_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_proposer_slashings_ragged_generated.bend as P42_PRV
import ../../src/buffer.bend as P43_B
import ../../src/obj.bend as P43_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_proposer_slashings_ragged_1_generated.bend as P43_PRV
import ../../src/buffer.bend as P44_B
import ../../src/obj.bend as P44_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_proposer_slashings_ragged_2_generated.bend as P44_PRV
import ../../src/buffer.bend as P45_B
import ../../src/obj.bend as P45_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_proposer_slashings_ragged_208_generated.bend as P45_PRV
import ../../src/buffer.bend as P46_B
import ../../src/obj.bend as P46_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_proposer_slashings_ragged_415_generated.bend as P46_PRV
import ../../src/buffer.bend as P47_B
import ../../src/obj.bend as P47_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_proposer_slashings_ragged_418_generated.bend as P47_PRV
import ../../src/buffer.bend as P48_B
import ../../src/obj.bend as P48_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_voluntary_exits_ragged_generated.bend as P48_PRV
import ../../src/buffer.bend as P49_B
import ../../src/obj.bend as P49_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_voluntary_exits_ragged_1_generated.bend as P49_PRV
import ../../src/buffer.bend as P50_B
import ../../src/obj.bend as P50_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_voluntary_exits_ragged_111_generated.bend as P50_PRV
import ../../src/buffer.bend as P51_B
import ../../src/obj.bend as P51_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_voluntary_exits_ragged_114_generated.bend as P51_PRV
import ../../src/buffer.bend as P52_B
import ../../src/obj.bend as P52_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_voluntary_exits_ragged_2_generated.bend as P52_PRV
import ../../src/buffer.bend as P53_B
import ../../src/obj.bend as P53_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_bad_voluntary_exits_ragged_56_generated.bend as P53_PRV
import ../../src/buffer.bend as P54_B
import ../../src/obj.bend as P54_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_attestations_n1_generated.bend as P54_PRV
import ../../src/buffer.bend as P55_B
import ../../src/obj.bend as P55_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_attestations_n2_generated.bend as P55_PRV
import ../../src/buffer.bend as P56_B
import ../../src/obj.bend as P56_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_attester_slashings_n1_generated.bend as P56_PRV
import ../../src/buffer.bend as P57_B
import ../../src/obj.bend as P57_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_blob_kzg_commitments_n1_generated.bend as P57_PRV
import ../../src/buffer.bend as P58_B
import ../../src/obj.bend as P58_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_blob_kzg_commitments_n2_generated.bend as P58_PRV
import ../../src/buffer.bend as P59_B
import ../../src/obj.bend as P59_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_bls_to_execution_changes_n1_generated.bend as P59_PRV
import ../../src/buffer.bend as P60_B
import ../../src/obj.bend as P60_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_bls_to_execution_changes_n2_generated.bend as P60_PRV
import ../../src/buffer.bend as P61_B
import ../../src/obj.bend as P61_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_default_generated.bend as P61_PRV
import ../../src/buffer.bend as P62_B
import ../../src/obj.bend as P62_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_execution_payload_marked_generated.bend as P62_PRV
import ../../src/buffer.bend as P63_B
import ../../src/obj.bend as P63_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_execution_requests_marked_generated.bend as P63_PRV
import ../../src/buffer.bend as P64_B
import ../../src/obj.bend as P64_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_proposer_slashings_n1_generated.bend as P64_PRV
import ../../src/buffer.bend as P65_B
import ../../src/obj.bend as P65_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_proposer_slashings_n2_generated.bend as P65_PRV
import ../../src/buffer.bend as P66_B
import ../../src/obj.bend as P66_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_voluntary_exits_n1_generated.bend as P66_PRV
import ../../src/buffer.bend as P67_B
import ../../src/obj.bend as P67_O
import ../slop/validity/fulu_BeaconBlockBody_decode_literal_ok_voluntary_exits_n2_generated.bend as P67_PRV
import ../../src/buffer.bend as P68_B
import ../../src/obj.bend as P68_O
import ../obj/decode_window_library_generated.bend as P68_DWL
import ../slop/offsets/BeaconBlockBody_generated.bend as P68_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluBeaconBlockBody (BeaconBlockBody): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluBeaconBlockBody__decode_first_offset__BeaconBlockBody_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(396, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 200 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 396) == False{} : Bool}) -> {FuluBeaconBlockBody_r.BeaconBlockBody_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.BeaconBlockBody_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def FuluBeaconBlockBody__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}) -> {FuluBeaconBlockBody_r.BeaconBlockBody_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, pf, hd, hn, hN)

def FuluBeaconBlockBody__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {FuluBeaconBlockBody_r.BeaconBlockBody_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(d, t, n)}) : P1_B.Buf & Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hN, hchk)

def FuluBeaconBlockBody__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.BeaconBlockBody(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hN, hchk)

def FuluBeaconBlockBody__decode_unique__decode_unique(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}, +v: P1_S.Value, spec: P1_Decoding.decodes(P1_Spec.BeaconBlockBody(), P1_PRV.VW(t, n), v)) -> {v == P1_PRV.VAL(t, n) : P1_S.Value}:
  P1_PRV.decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec)

def FuluBeaconBlockBody__decode_reject__decode_reject(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> P1_Decoding.outside_image(P1_Spec.BeaconBlockBody(), P1_PRV.VW(t, n)):
  P1_PRV.decode_reject(d, t, n, pf, hd, hn, hN, hchk)

def FuluBeaconBlockBody__decode_none__decode_none(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hN: {U32.is_le(n, P1_VB.NMAX()) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> {FuluBeaconBlockBody_r.BeaconBlockBody_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), None{}) : P1_B.Buf & Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P1_PRV.decode_none(d, t, n, pf, hd, hn, hN, hchk)

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vand_pair() -> {(Pair.snd(P2_B.Buf, Bool, P2_O.and_pair(True{}, (P2_B.empty(), True{}))), (Pair.snd(P2_B.Buf, Bool, P2_O.and_pair(True{}, (P2_B.empty(), False{}))), (Pair.snd(P2_B.Buf, Bool, P2_O.and_pair(False{}, (P2_B.empty(), True{}))), Pair.snd(P2_B.Buf, Bool, P2_O.and_pair(False{}, (P2_B.empty(), False{})))))) == (True{}, (False{}, (False{}, False{}))) : Bool & (Bool & (Bool & Bool))}:
  P2_PRV.BeaconBlockBody_decode_vand_pair()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_limit() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_dchw(4294967265, 4294967265, (P3_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P3_PRV.BeaconBlockBody_decode_vchecked_limit()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_nmax_wrap(buf: P3_B.Buf) -> {FuluBeaconBlockBody_r.BeaconBlockBody_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P3_PRV.BeaconBlockBody_decode_vchecked_nmax_wrap(buf)

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_nmax_above(buf: P3_B.Buf) -> {FuluBeaconBlockBody_r.BeaconBlockBody_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P3_B.Buf & Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P3_PRV.BeaconBlockBody_decode_vchecked_nmax_above(buf)

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_dchw(936, 936, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 234))), Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.BeaconBlockBody_decode_vchecked_accept()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_window() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_dchw(936, 935, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 234))) == None{} : Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P3_PRV.BeaconBlockBody_decode_vchecked_window()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_storage() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_dchw(936, 936, (P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 233))) == None{} : Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P3_PRV.BeaconBlockBody_decode_vchecked_storage()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_short() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 935}, 936)) == None{} : Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P3_PRV.BeaconBlockBody_decode_vchecked_short()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_real() -> {Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode_checked(P3_B.Buf{Array.new(U32, 0n, 0), 936}, 936)) == None{} : Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P3_PRV.BeaconBlockBody_decode_vchecked_real()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_budget_agree(buf: P3_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(FuluBeaconBlockBody_r.BeaconBlockBody_dcost(size), 4294967295), U32.is_le(FuluBeaconBlockBody_r.BeaconBlockBody_dcost(size), budget)) == True{} : Bool}) -> {FuluBeaconBlockBody_r.BeaconBlockBody_decode_checked_budget(buf, size, budget) == FuluBeaconBlockBody_r.BeaconBlockBody_decode_checked(buf, size) : P3_B.Buf & Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P3_PRV.BeaconBlockBody_decode_vchecked_budget_agree(buf, size, budget, h)

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vchecked_budget_accept() -> {P3_PRV.is_some(Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode_checked_budget(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936, 4294967295)), Pair.snd(P3_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode_checked(P3_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == (True{}, True{}) : Bool & Bool}:
  P3_PRV.BeaconBlockBody_decode_vchecked_budget_accept()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attestations_elem_aggregation_bits_nodelim() -> {P4_PRV.some1(Pair.snd(P4_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P4_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 637), 54, 637), 95, 637), 96, 1165), 97, 1165), 98, 1165), 99, 4), 100, 236), 268, 135168), 285, 135168), 286, 135168), 291, 3072), 292, 3072), 293, 3072), 1177}, 1177))) == False{} : Bool}:
  P4_PRV.BeaconBlockBody_decode_vlit_bad_attestations_elem_aggregation_bits_nodelim()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attestations_elem_off_minus() -> {P5_PRV.some1(Pair.snd(P5_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P5_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 637), 54, 637), 95, 637), 96, 1165), 97, 1165), 98, 1165), 99, 4), 100, 235), 159, 1), 268, 135168), 285, 135168), 286, 135168), 291, 3072), 292, 3072), 293, 3072), 1177}, 1177))) == False{} : Bool}:
  P5_PRV.BeaconBlockBody_decode_vlit_bad_attestations_elem_off_minus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attestations_elem_off_plus() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P6_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 638), 54, 638), 95, 638), 96, 1166), 97, 1166), 98, 1166), 99, 4), 100, 237), 159, 1), 268, 34603008), 285, 34603008), 286, 34603008), 291, 786432), 292, 786432), 293, 786432), 1178}, 1178))) == False{} : Bool}:
  P6_PRV.BeaconBlockBody_decode_vlit_bad_attestations_elem_off_plus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attestations_first_past() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 637), 54, 637), 95, 637), 96, 1165), 97, 1165), 98, 1165), 99, 245), 100, 236), 159, 1), 268, 135168), 285, 135168), 286, 135168), 291, 3072), 292, 3072), 293, 3072), 1177}, 1177))) == False{} : Bool}:
  P7_PRV.BeaconBlockBody_decode_vlit_bad_attestations_first_past()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attestations_off0() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 637), 54, 637), 95, 637), 96, 1165), 97, 1165), 98, 1165), 100, 236), 159, 1), 268, 135168), 285, 135168), 286, 135168), 291, 3072), 292, 3072), 293, 3072), 1177}, 1177))) == False{} : Bool}:
  P8_PRV.BeaconBlockBody_decode_vlit_bad_attestations_off0()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attestations_off5() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 638), 54, 638), 95, 638), 96, 1166), 97, 1166), 98, 1166), 99, 5), 100, 60416), 159, 256), 268, 34603008), 285, 34603008), 286, 34603008), 291, 786432), 292, 786432), 293, 786432), 1178}, 1178))) == False{} : Bool}:
  P9_PRV.BeaconBlockBody_decode_vlit_bad_attestations_off5()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attestations_off_desc() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 878), 54, 878), 95, 878), 96, 1406), 97, 1406), 98, 1406), 99, 8), 100, 7), 101, 236), 160, 60417), 219, 256), 328, 34603008), 345, 34603008), 346, 34603008), 351, 786432), 352, 786432), 353, 786432), 1418}, 1418))) == False{} : Bool}:
  P10_PRV.BeaconBlockBody_decode_vlit_bad_attestations_off_desc()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attestations_off_past() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 878), 54, 878), 95, 878), 96, 1406), 97, 1406), 98, 1406), 99, 8), 100, 483), 101, 236), 160, 60417), 219, 256), 328, 34603008), 345, 34603008), 346, 34603008), 351, 786432), 352, 786432), 353, 786432), 1418}, 1418))) == False{} : Bool}:
  P11_PRV.BeaconBlockBody_decode_vlit_bad_attestations_off_past()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_attestation_1_off_plus() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 865), 53, 865), 54, 865), 95, 865), 96, 1393), 97, 1393), 98, 1393), 99, 4), 100, 8), 101, 237), 102, 229), 159, 58368), 325, 135168), 342, 135168), 343, 135168), 348, 3072), 349, 3072), 350, 3072), 1405}, 1405))) == False{} : Bool}:
  P12_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_attestation_1_off_plus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_off_minus() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 864), 53, 864), 54, 864), 95, 864), 96, 1392), 97, 1392), 98, 1392), 99, 4), 100, 7), 101, 236), 102, 228), 159, 228), 325, 528), 342, 528), 343, 528), 348, 12), 349, 12), 350, 12), 1404}, 1404))) == False{} : Bool}:
  P13_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_off_minus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_off_plus() -> {P14_PRV.some1(Pair.snd(P14_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 865), 53, 865), 54, 865), 95, 865), 96, 1393), 97, 1393), 98, 1393), 99, 4), 100, 9), 101, 236), 102, 228), 159, 228), 325, 135168), 342, 135168), 343, 135168), 348, 3072), 349, 3072), 350, 3072), 1405}, 1405))) == False{} : Bool}:
  P14_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_off_plus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_order_attestation_2() -> {P15_PRV.some1(Pair.snd(P15_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 864), 53, 864), 54, 864), 95, 864), 96, 1392), 97, 1392), 98, 1392), 99, 4), 100, 8), 101, 7), 102, 228), 159, 228), 325, 528), 342, 528), 343, 528), 348, 12), 349, 12), 350, 12), 1404}, 1404))) == False{} : Bool}:
  P15_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_elem_order_attestation_2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_first_past() -> {P16_PRV.some1(Pair.snd(P16_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P16_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 864), 53, 864), 54, 864), 95, 864), 96, 1392), 97, 1392), 98, 1392), 99, 472), 100, 8), 101, 236), 102, 228), 159, 228), 325, 528), 342, 528), 343, 528), 348, 12), 349, 12), 350, 12), 1404}, 1404))) == False{} : Bool}:
  P16_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_first_past()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_off0() -> {P17_PRV.some1(Pair.snd(P17_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P17_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 864), 53, 864), 54, 864), 95, 864), 96, 1392), 97, 1392), 98, 1392), 100, 8), 101, 236), 102, 228), 159, 228), 325, 528), 342, 528), 343, 528), 348, 12), 349, 12), 350, 12), 1404}, 1404))) == False{} : Bool}:
  P17_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_off0()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_off5() -> {P18_PRV.some1(Pair.snd(P18_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P18_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 865), 53, 865), 54, 865), 95, 865), 96, 1393), 97, 1393), 98, 1393), 99, 5), 100, 2048), 101, 60416), 102, 58368), 159, 58368), 325, 135168), 342, 135168), 343, 135168), 348, 3072), 349, 3072), 350, 3072), 1405}, 1405))) == False{} : Bool}:
  P18_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_off5()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_off_desc() -> {P19_PRV.some1(Pair.snd(P19_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P19_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 1332), 53, 1332), 54, 1332), 95, 1332), 96, 1860), 97, 1860), 98, 1860), 99, 8), 100, 7), 101, 8), 102, 236), 103, 228), 160, 228), 217, 8), 218, 236), 219, 228), 276, 228), 442, 528), 459, 528), 460, 528), 465, 12), 466, 12), 467, 12), 1872}, 1872))) == False{} : Bool}:
  P19_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_off_desc()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_off_past() -> {P20_PRV.some1(Pair.snd(P20_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P20_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 1332), 53, 1332), 54, 1332), 95, 1332), 96, 1860), 97, 1860), 98, 1860), 99, 8), 100, 937), 101, 8), 102, 236), 103, 228), 160, 228), 217, 8), 218, 236), 219, 228), 276, 228), 442, 528), 459, 528), 460, 528), 465, 12), 466, 12), 467, 12), 1872}, 1872))) == False{} : Bool}:
  P20_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_off_past()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_attester_slashings_over() -> {P21_PRV.some1(Pair.snd(P21_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P21_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 1332), 53, 1332), 54, 1332), 95, 1332), 96, 1860), 97, 1860), 98, 1860), 99, 8), 100, 472), 101, 8), 102, 236), 103, 228), 160, 228), 217, 8), 218, 236), 219, 228), 276, 228), 442, 528), 459, 528), 460, 528), 465, 12), 466, 12), 467, 12), 1872}, 1872))) == False{} : Bool}:
  P21_PRV.BeaconBlockBody_decode_vlit_bad_attester_slashings_over()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_deposits_ragged_1() -> {P22_PRV.some1(Pair.snd(P22_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P22_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 397), 95, 397), 96, 925), 97, 925), 98, 925), 208, 135168), 225, 135168), 226, 135168), 231, 3072), 232, 3072), 233, 3072), 937}, 937))) == False{} : Bool}:
  P22_PRV.BeaconBlockBody_decode_vlit_bad_deposits_ragged_1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_deposits_ragged_2() -> {P23_PRV.some1(Pair.snd(P23_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P23_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 398), 95, 398), 96, 926), 97, 926), 98, 926), 208, 34603008), 225, 34603008), 226, 34603008), 231, 786432), 232, 786432), 233, 786432), 938}, 938))) == False{} : Bool}:
  P23_PRV.BeaconBlockBody_decode_vlit_bad_deposits_ragged_2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_deposits_ragged_620() -> {P24_PRV.some1(Pair.snd(P24_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P24_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 1016), 95, 1016), 96, 1544), 97, 1544), 98, 1544), 363, 528), 380, 528), 381, 528), 386, 12), 387, 12), 388, 12), 1556}, 1556))) == False{} : Bool}:
  P24_PRV.BeaconBlockBody_decode_vlit_bad_deposits_ragged_620()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_execution_payload_extra_data_over() -> {P25_PRV.some1(Pair.snd(P25_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P25_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 957), 97, 957), 98, 957), 208, 528), 225, 561), 226, 561), 239, 3072), 240, 3072), 241, 3072), 969}, 969))) == False{} : Bool}:
  P25_PRV.BeaconBlockBody_decode_vlit_bad_execution_payload_extra_data_over()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_execution_payload_off_minus() -> {P26_PRV.some1(Pair.snd(P26_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P26_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 527), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P26_PRV.BeaconBlockBody_decode_vlit_bad_execution_payload_off_minus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_execution_payload_off_plus() -> {P27_PRV.some1(Pair.snd(P27_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P27_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 925), 97, 925), 98, 925), 208, 529), 225, 528), 226, 528), 231, 3072), 232, 3072), 233, 3072), 937}, 937))) == False{} : Bool}:
  P27_PRV.BeaconBlockBody_decode_vlit_bad_execution_payload_off_plus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_execution_payload_order_transactions() -> {P28_PRV.some1(Pair.snd(P28_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P28_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 527), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P28_PRV.BeaconBlockBody_decode_vlit_bad_execution_payload_order_transactions()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_execution_payload_order_withdrawals() -> {P29_PRV.some1(Pair.snd(P29_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P29_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 527), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P29_PRV.BeaconBlockBody_decode_vlit_bad_execution_payload_order_withdrawals()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_execution_payload_transactions_off0() -> {P30_PRV.some1(Pair.snd(P30_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P30_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 928), 97, 928), 98, 928), 208, 528), 225, 528), 226, 532), 232, 12), 233, 12), 234, 12), 940}, 940))) == False{} : Bool}:
  P30_PRV.BeaconBlockBody_decode_vlit_bad_execution_payload_transactions_off0()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_execution_payload_transactions_off5() -> {P31_PRV.some1(Pair.snd(P31_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P31_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 929), 97, 929), 98, 929), 208, 528), 225, 528), 226, 533), 231, 5), 232, 3072), 233, 3072), 234, 3072), 941}, 941))) == False{} : Bool}:
  P31_PRV.BeaconBlockBody_decode_vlit_bad_execution_payload_transactions_off5()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_off_minus() -> {P32_PRV.some1(Pair.snd(P32_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P32_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 395), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P32_PRV.BeaconBlockBody_decode_vlit_bad_off_minus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_off_plus() -> {P33_PRV.some1(Pair.snd(P33_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P33_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 397), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 937}, 937))) == False{} : Bool}:
  P33_PRV.BeaconBlockBody_decode_vlit_bad_off_plus()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_order_attestations() -> {P34_PRV.some1(Pair.snd(P34_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P34_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 395), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P34_PRV.BeaconBlockBody_decode_vlit_bad_order_attestations()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_order_attester_slashings() -> {P35_PRV.some1(Pair.snd(P35_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P35_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 395), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P35_PRV.BeaconBlockBody_decode_vlit_bad_order_attester_slashings()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_order_blob_kzg_commitments() -> {P36_PRV.some1(Pair.snd(P36_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P36_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 923), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P36_PRV.BeaconBlockBody_decode_vlit_bad_order_blob_kzg_commitments()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_order_bls_to_execution_changes() -> {P37_PRV.some1(Pair.snd(P37_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P37_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 395), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P37_PRV.BeaconBlockBody_decode_vlit_bad_order_bls_to_execution_changes()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_order_deposits() -> {P38_PRV.some1(Pair.snd(P38_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P38_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 395), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P38_PRV.BeaconBlockBody_decode_vlit_bad_order_deposits()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_order_execution_payload() -> {P39_PRV.some1(Pair.snd(P39_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P39_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 395), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P39_PRV.BeaconBlockBody_decode_vlit_bad_order_execution_payload()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_order_execution_requests() -> {P40_PRV.some1(Pair.snd(P40_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P40_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 923), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P40_PRV.BeaconBlockBody_decode_vlit_bad_order_execution_requests()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_order_voluntary_exits() -> {P41_PRV.some1(Pair.snd(P41_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P41_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 395), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == False{} : Bool}:
  P41_PRV.BeaconBlockBody_decode_vlit_bad_order_voluntary_exits()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged() -> {P42_PRV.some1(Pair.snd(P42_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P42_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 813), 52, 813), 53, 813), 54, 813), 95, 813), 96, 1341), 97, 1341), 98, 1341), 312, 135168), 329, 135168), 330, 135168), 335, 3072), 336, 3072), 337, 3072), 1353}, 1353))) == False{} : Bool}:
  P42_PRV.BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_1() -> {P43_PRV.some1(Pair.snd(P43_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P43_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 397), 52, 397), 53, 397), 54, 397), 95, 397), 96, 925), 97, 925), 98, 925), 208, 135168), 225, 135168), 226, 135168), 231, 3072), 232, 3072), 233, 3072), 937}, 937))) == False{} : Bool}:
  P43_PRV.BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_2() -> {P44_PRV.some1(Pair.snd(P44_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P44_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 398), 52, 398), 53, 398), 54, 398), 95, 398), 96, 926), 97, 926), 98, 926), 208, 34603008), 225, 34603008), 226, 34603008), 231, 786432), 232, 786432), 233, 786432), 938}, 938))) == False{} : Bool}:
  P44_PRV.BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_208() -> {P45_PRV.some1(Pair.snd(P45_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P45_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 604), 52, 604), 53, 604), 54, 604), 95, 604), 96, 1132), 97, 1132), 98, 1132), 260, 528), 277, 528), 278, 528), 283, 12), 284, 12), 285, 12), 1144}, 1144))) == False{} : Bool}:
  P45_PRV.BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_208()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_415() -> {P46_PRV.some1(Pair.snd(P46_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P46_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 811), 52, 811), 53, 811), 54, 811), 95, 811), 96, 1339), 97, 1339), 98, 1339), 311, 268435456), 312, 2), 328, 268435456), 329, 268435458), 330, 2), 334, 201326592), 335, 201326592), 336, 201326592), 1351}, 1351))) == False{} : Bool}:
  P46_PRV.BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_415()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_418() -> {P47_PRV.some1(Pair.snd(P47_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P47_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 814), 52, 814), 53, 814), 54, 814), 95, 814), 96, 1342), 97, 1342), 98, 1342), 312, 34603008), 329, 34603008), 330, 34603008), 335, 786432), 336, 786432), 337, 786432), 1354}, 1354))) == False{} : Bool}:
  P47_PRV.BeaconBlockBody_decode_vlit_bad_proposer_slashings_ragged_418()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged() -> {P48_PRV.some1(Pair.snd(P48_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P48_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 509), 96, 1037), 97, 1037), 98, 1037), 236, 135168), 253, 135168), 254, 135168), 259, 3072), 260, 3072), 261, 3072), 1049}, 1049))) == False{} : Bool}:
  P48_PRV.BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_1() -> {P49_PRV.some1(Pair.snd(P49_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P49_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 397), 96, 925), 97, 925), 98, 925), 208, 135168), 225, 135168), 226, 135168), 231, 3072), 232, 3072), 233, 3072), 937}, 937))) == False{} : Bool}:
  P49_PRV.BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_111() -> {P50_PRV.some1(Pair.snd(P50_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P50_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 507), 96, 1035), 97, 1035), 98, 1035), 235, 268435456), 236, 2), 252, 268435456), 253, 268435458), 254, 2), 258, 201326592), 259, 201326592), 260, 201326592), 1047}, 1047))) == False{} : Bool}:
  P50_PRV.BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_111()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_114() -> {P51_PRV.some1(Pair.snd(P51_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P51_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 510), 96, 1038), 97, 1038), 98, 1038), 236, 34603008), 253, 34603008), 254, 34603008), 259, 786432), 260, 786432), 261, 786432), 1050}, 1050))) == False{} : Bool}:
  P51_PRV.BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_114()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_2() -> {P52_PRV.some1(Pair.snd(P52_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P52_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 398), 96, 926), 97, 926), 98, 926), 208, 34603008), 225, 34603008), 226, 34603008), 231, 786432), 232, 786432), 233, 786432), 938}, 938))) == False{} : Bool}:
  P52_PRV.BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_56() -> {P53_PRV.some1(Pair.snd(P53_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P53_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 452), 96, 980), 97, 980), 98, 980), 222, 528), 239, 528), 240, 528), 245, 12), 246, 12), 247, 12), 992}, 992))) == False{} : Bool}:
  P53_PRV.BeaconBlockBody_decode_vlit_bad_voluntary_exits_ragged_56()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_attestations_n1() -> {P54_PRV.some1(Pair.snd(P54_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P54_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 637), 54, 637), 95, 637), 96, 1165), 97, 1165), 98, 1165), 99, 4), 100, 236), 159, 1), 268, 135168), 285, 135168), 286, 135168), 291, 3072), 292, 3072), 293, 3072), 1177}, 1177))) == True{} : Bool}:
  P54_PRV.BeaconBlockBody_decode_vlit_ok_attestations_n1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_attestations_n2() -> {P55_PRV.some1(Pair.snd(P55_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P55_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 878), 54, 878), 95, 878), 96, 1406), 97, 1406), 98, 1406), 99, 8), 100, 245), 101, 236), 160, 60417), 219, 256), 328, 34603008), 345, 34603008), 346, 34603008), 351, 786432), 352, 786432), 353, 786432), 1418}, 1418))) == True{} : Bool}:
  P55_PRV.BeaconBlockBody_decode_vlit_ok_attestations_n2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_attester_slashings_n1() -> {P56_PRV.some1(Pair.snd(P56_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P56_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 864), 53, 864), 54, 864), 95, 864), 96, 1392), 97, 1392), 98, 1392), 99, 4), 100, 8), 101, 236), 102, 228), 159, 228), 325, 528), 342, 528), 343, 528), 348, 12), 349, 12), 350, 12), 1404}, 1404))) == True{} : Bool}:
  P56_PRV.BeaconBlockBody_decode_vlit_ok_attester_slashings_n1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_blob_kzg_commitments_n1() -> {P57_PRV.some1(Pair.snd(P57_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P57_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 972), 208, 528), 225, 528), 226, 528), 243, 12), 244, 12), 245, 12), 984}, 984))) == True{} : Bool}:
  P57_PRV.BeaconBlockBody_decode_vlit_ok_blob_kzg_commitments_n1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_blob_kzg_commitments_n2() -> {P58_PRV.some1(Pair.snd(P58_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P58_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 1020), 208, 528), 225, 528), 226, 528), 255, 12), 256, 12), 257, 12), 1032}, 1032))) == True{} : Bool}:
  P58_PRV.BeaconBlockBody_decode_vlit_ok_blob_kzg_commitments_n2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_bls_to_execution_changes_n1() -> {P59_PRV.some1(Pair.snd(P59_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P59_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 1096), 98, 1096), 208, 528), 225, 528), 226, 528), 274, 12), 275, 12), 276, 12), 1108}, 1108))) == True{} : Bool}:
  P59_PRV.BeaconBlockBody_decode_vlit_ok_bls_to_execution_changes_n1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_bls_to_execution_changes_n2() -> {P60_PRV.some1(Pair.snd(P60_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P60_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 1268), 98, 1268), 208, 528), 225, 528), 226, 528), 317, 12), 318, 12), 319, 12), 1280}, 1280))) == True{} : Bool}:
  P60_PRV.BeaconBlockBody_decode_vlit_ok_bls_to_execution_changes_n2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_default() -> {P61_PRV.some1(Pair.snd(P61_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P61_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 12), 233, 12), 936}, 936))) == True{} : Bool}:
  P61_PRV.BeaconBlockBody_decode_vlit_ok_default()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_execution_payload_marked() -> {P62_PRV.some1(Pair.snd(P62_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P62_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 8n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 1012), 97, 1012), 98, 1012), 208, 528), 225, 528), 226, 528), 231, 4), 242, 4), 253, 12), 254, 12), 255, 12), 1024}, 1024))) == True{} : Bool}:
  P62_PRV.BeaconBlockBody_decode_vlit_ok_execution_payload_marked()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_execution_requests_marked() -> {P63_PRV.some1(Pair.snd(P63_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P63_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 396), 96, 924), 97, 924), 98, 924), 208, 528), 225, 528), 226, 528), 231, 12), 232, 396), 233, 548), 234, 4), 282, 4), 330, 4), 349, 4), 368, 4), 397, 4), 1704}, 1704))) == True{} : Bool}:
  P63_PRV.BeaconBlockBody_decode_vlit_ok_execution_requests_marked()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_proposer_slashings_n1() -> {P64_PRV.some1(Pair.snd(P64_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P64_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 812), 52, 812), 53, 812), 54, 812), 95, 812), 96, 1340), 97, 1340), 98, 1340), 312, 528), 329, 528), 330, 528), 335, 12), 336, 12), 337, 12), 1352}, 1352))) == True{} : Bool}:
  P64_PRV.BeaconBlockBody_decode_vlit_ok_proposer_slashings_n1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_proposer_slashings_n2() -> {P65_PRV.some1(Pair.snd(P65_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P65_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 1228), 52, 1228), 53, 1228), 54, 1228), 95, 1228), 96, 1756), 97, 1756), 98, 1756), 416, 528), 433, 528), 434, 528), 439, 12), 440, 12), 441, 12), 1768}, 1768))) == True{} : Bool}:
  P65_PRV.BeaconBlockBody_decode_vlit_ok_proposer_slashings_n2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_voluntary_exits_n1() -> {P66_PRV.some1(Pair.snd(P66_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P66_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 508), 96, 1036), 97, 1036), 98, 1036), 236, 528), 253, 528), 254, 528), 259, 12), 260, 12), 261, 12), 1048}, 1048))) == True{} : Bool}:
  P66_PRV.BeaconBlockBody_decode_vlit_ok_voluntary_exits_n1()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_vlit_ok_voluntary_exits_n2() -> {P67_PRV.some1(Pair.snd(P67_B.Buf, Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>, FuluBeaconBlockBody_r.BeaconBlockBody_decode(P67_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 9n, 0), 50, 396), 51, 396), 52, 396), 53, 396), 54, 396), 95, 620), 96, 1148), 97, 1148), 98, 1148), 264, 528), 281, 528), 282, 528), 287, 12), 288, 12), 289, 12), 1160}, 1160))) == True{} : Bool}:
  P67_PRV.BeaconBlockBody_decode_vlit_ok_voluntary_exits_n2()

def FuluBeaconBlockBody__decode_offsets__BeaconBlockBody_decode_build(buf: P68_B.Buf, +size: U32, b2: P68_B.Buf, e: {FuluBeaconBlockBody_r.BeaconBlockBody_ok(buf, 0, size) == (b2, True{}) : P68_B.Buf & Bool}, hwin: {U32.is_le(size, P68_DWL.bsz(buf)) == True{} : Bool}) -> {FuluBeaconBlockBody_r.BeaconBlockBody_decode(buf, size) == FuluBeaconBlockBody_r.BeaconBlockBody_some(FuluBeaconBlockBody_r.BeaconBlockBody_build(b2, size)) : P68_B.Buf & Maybe<&1, FuluBeaconBlockBody_d.BeaconBlockBody>}:
  P68_PRV.BeaconBlockBody_decode_build(buf, size, b2, e, hwin)

