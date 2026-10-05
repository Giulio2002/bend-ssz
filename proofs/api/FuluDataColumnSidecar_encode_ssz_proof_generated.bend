import Base
import ../../src/buffer.bend as P0_B
import ../../src/obj.bend as P0_O
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/uint64_def_generated.bend as uint64_d
import ../../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
import ../../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
import ../../types/FuluExecutionBranch_encode_ssz_generated.bend as FuluExecutionBranch_e
import ../../types/Fulu_list_bytevec_48_4096_def_generated.bend as Fulu_list_bytevec_48_4096_d
import ../../types/Fulu_list_bytevec_48_4096_encode_ssz_generated.bend as Fulu_list_bytevec_48_4096_e
import ../../types/Fulu_list_bytevec_2048_4096_def_generated.bend as Fulu_list_bytevec_2048_4096_d
import ../../types/Fulu_list_bytevec_2048_4096_encode_ssz_generated.bend as Fulu_list_bytevec_2048_4096_e
import ../../types/FuluDataColumnSidecar_def_generated.bend as FuluDataColumnSidecar_d
import ../../types/FuluDataColumnSidecar_encode_ssz_generated.bend as FuluDataColumnSidecar_e
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
import ../obj/vlist.bend as P0_VL
import ../obj/vmul_generated.bend as P0_VM
import ../obj/vmv_generated.bend as P0_VV
import ../obj/vadd.bend as P0_VA
import ../obj/venc.bend as P0_VE
import ../obj/venc2.bend as P0_V2
import ../obj/vme_generated.bend as P0_VME
import ../obj/vzeros_generated.bend as P0_VZ
import ../obj/var_fix_types_m_generated.bend as P0_VT
import ../obj/vfits.bend as P0_VFT
import ../obj/xmul.bend as P0_XM
import ../../spec/schema.bend as P0_SC
import ../obj/vseq.bend as P0_VSQ
import ../obj/var_codec_DataColumnSidecar_generated.bend as P0_DC
import ../obj/var_codec_DataColumnSidecar_enc_generated.bend as P0_PRV
import ../../src/obj.bend as P1_O
import ../slop/validity/fulu_DataColumnSidecar_api_l4096_b2048_generated.bend as P1_PRV
import ../../src/obj.bend as P2_O
import ../slop/validity/fulu_DataColumnSidecar_api_l4096_b48_generated.bend as P2_PRV
import ../../src/obj.bend as P3_O
import ../slop/validity/fulu_DataColumnSidecar_appb_l4096_b2048_generated.bend as P3_PRV
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_DataColumnSidecar_appb_l4096_b48_generated.bend as P4_PRV
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_blit_generated.bend as P5_PRV
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_get_0_generated.bend as P6_PRV
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_get_1_generated.bend as P7_PRV
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_get_end_generated.bend as P8_PRV
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_len_generated.bend as P9_PRV
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_refuse_app_long_generated.bend as P10_PRV
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_refuse_app_ok_generated.bend as P11_PRV
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_refuse_app_short_generated.bend as P12_PRV
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_refuse_app_tight_generated.bend as P13_PRV
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_refuse_set_end_generated.bend as P14_PRV
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_refuse_set_long_generated.bend as P15_PRV
import ../../src/obj.bend as P16_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_refuse_set_short_generated.bend as P16_PRV
import ../../src/obj.bend as P17_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_refuse_set_tight_generated.bend as P17_PRV
import ../../src/obj.bend as P18_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_set_get_0_generated.bend as P18_PRV
import ../../src/obj.bend as P19_O
import ../slop/validity/fulu_DataColumnSidecar_cells_l4096_b2048_set_get_1_generated.bend as P19_PRV
import ../../src/obj.bend as P20_O
import ../slop/validity/fulu_DataColumnSidecar_fields_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/fulu_DataColumnSidecar_senc_generated.bend as P21_PRV
import ../../src/obj.bend as P22_O
import ../slop/validity/fulu_DataColumnSidecar_unit_l4096_b2048_generated.bend as P22_PRV
import ../../src/obj.bend as P23_O
import ../slop/validity/fulu_DataColumnSidecar_unit_l4096_b48_generated.bend as P23_PRV
import ../../src/obj.bend as P24_O
import ../slop/validity/fulu_DataColumnSidecar_unit_v4_b32_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/fulu_DataColumnSidecar_writer_l4096_b2048_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/fulu_DataColumnSidecar_writer_l4096_b48_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/size/DataColumnSidecar_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../../src/digest.bend as P28_D
import ../slop/constants/DataColumnSidecar_generated.bend as P28_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluDataColumnSidecar (DataColumnSidecar): its encode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluDataColumnSidecar__encode_eval__encode_eval(+N0: U32, +N1: U32, +N2: U32, +c0: Nat, +c1: Nat, +T0: P0_FD.array__Tree<U32>, +T1: P0_FD.array__Tree<U32>, +T2: P0_FD.array__Tree<U32>, +TP: P0_FD.array__Tree<U32>, +i0: U32, +i1: U32, +h0: U32, +h1: U32, +h2: U32, +h3: U32, +h4: U32, +h5: U32, +h6: U32, +h7: U32, +h8: U32, +h9: U32, +h10: U32, +h11: U32, +h12: U32, +h13: U32, +h14: U32, +h15: U32, +h16: U32, +h17: U32, +h18: U32, +h19: U32, +h20: U32, +h21: U32, +h22: U32, +h23: U32, +h24: U32, +h25: U32, +h26: U32, +h27: U32, +h28: U32, +h29: U32, +h30: U32, +h31: U32, +h32: U32, +h33: U32, +h34: U32, +h35: U32, +h36: U32, +h37: U32, +h38: U32, +h39: U32, +h40: U32, +h41: U32, +h42: U32, +h43: U32, +h44: U32, +h45: U32, +h46: U32, +h47: U32, +h48: U32, +h49: U32, +h50: U32, +h51: U32, +c2: Nat, +dw0: Nat, +dw1: Nat, +dw2: Nat, +dp: Nat, +pf0: {P0_FD.array__perfect(U32, dw0, T0) == True{} : Bool}, +pf1: {P0_FD.array__perfect(U32, dw1, T1) == True{} : Bool}, +pf2: {P0_FD.array__perfect(U32, dw2, T2) == True{} : Bool}, +pfP: {P0_FD.array__perfect(U32, dp, TP) == True{} : Bool}, +hdw0: {Nat.is_lt(dw0, 31n) == True{} : Bool}, +hdw1: {Nat.is_lt(dw1, 31n) == True{} : Bool}, +hdw2: {Nat.is_lt(dw2, 31n) == True{} : Bool}, +hdp: {Nat.is_lt(dp, 31n) == True{} : Bool}, +ec0: {U32.to_nat(N0) == P0_A.quad(P0_PRV.M0(c0)) : Nat}, +ec1: {U32.to_nat(N1) == P0_A.quad(P0_PRV.M1(c1)) : Nat}, +ec2: {U32.to_nat(N2) == P0_A.quad(P0_PRV.M2(c2)) : Nat}, +hc0: {Nat.is_le(c0, U32.to_nat(4096)) == True{} : Bool}, +hc1: {Nat.is_le(c1, U32.to_nat(4096)) == True{} : Bool}, +hc2: {Nat.is_le(c2, U32.to_nat(4096)) == True{} : Bool}, +hr0: {Nat.is_le(Nat.add(P0_VC.NW(N0), 0n), P0_VB.pw(dw0)) == True{} : Bool}, +hr1: {Nat.is_le(Nat.add(P0_VC.NW(N1), 0n), P0_VB.pw(dw1)) == True{} : Bool}, +hr2: {Nat.is_le(Nat.add(P0_VC.NW(N2), 0n), P0_VB.pw(dw2)) == True{} : Bool}, +hrP: {Nat.is_le(32n, P0_VB.pw(dp)) == True{} : Bool}) -> {FuluDataColumnSidecar_e.DataColumnSidecar_encode(FuluDataColumnSidecar_d.DataColumnSidecar{P0_O.U64{i0, i1}, P0_O.Words{P0_FD.array__thaw(U32, T0), N0}, P0_O.Words{P0_FD.array__thaw(U32, T1), N1}, P0_O.Words{P0_FD.array__thaw(U32, T2), N2}, P0_O.BSome{FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{FuluBeaconBlockHeader_d.BeaconBlockHeader{P0_O.U64{h0, h1}, P0_O.U64{h2, h3}, FuluBytes32_d.Bytes32{h4, h5, h6, h7, h8, h9, h10, h11}, FuluBytes32_d.Bytes32{h12, h13, h14, h15, h16, h17, h18, h19}, FuluBytes32_d.Bytes32{h20, h21, h22, h23, h24, h25, h26, h27}}, FuluBytes96_d.Bytes96{h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51}}, P0_O.BNone{}}, P0_O.Words{P0_FD.array__thaw(U32, TP), 128}}) == (FuluDataColumnSidecar_d.DataColumnSidecar{P0_O.U64{i0, i1}, P0_O.Words{P0_FD.array__thaw(U32, T0), N0}, P0_O.Words{P0_FD.array__thaw(U32, T1), N1}, P0_O.Words{P0_FD.array__thaw(U32, T2), N2}, P0_O.BSome{FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{FuluBeaconBlockHeader_d.BeaconBlockHeader{P0_O.U64{h0, h1}, P0_O.U64{h2, h3}, FuluBytes32_d.Bytes32{h4, h5, h6, h7, h8, h9, h10, h11}, FuluBytes32_d.Bytes32{h12, h13, h14, h15, h16, h17, h18, h19}, FuluBytes32_d.Bytes32{h20, h21, h22, h23, h24, h25, h26, h27}}, FuluBytes96_d.Bytes96{h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51}}, P0_O.BNone{}}, P0_O.Words{P0_FD.array__thaw(U32, TP), 128}}, P0_B.Buf{P0_FD.array__thaw(U32, P0_PRV.D9(N0, N1, N2, c0, c1, T0, T1, T2, TP, i0, i1, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51)), P0_PRV.S3(N0, N1, N2)}) : FuluDataColumnSidecar_d.DataColumnSidecar & P0_B.Buf}:
  P0_PRV.encode_eval(N0, N1, N2, c0, c1, T0, T1, T2, TP, i0, i1, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, c2, dw0, dw1, dw2, dp, pf0, pf1, pf2, pfP, hdw0, hdw1, hdw2, hdp, ec0, ec1, ec2, hc0, hc1, hc2, hr0, hr1, hr2, hrP)

def FuluDataColumnSidecar__encode_spec__encode_spec(+N0: U32, +N1: U32, +N2: U32, +c0: Nat, +c1: Nat, +T0: P0_FD.array__Tree<U32>, +T1: P0_FD.array__Tree<U32>, +T2: P0_FD.array__Tree<U32>, +TP: P0_FD.array__Tree<U32>, +i0: U32, +i1: U32, +h0: U32, +h1: U32, +h2: U32, +h3: U32, +h4: U32, +h5: U32, +h6: U32, +h7: U32, +h8: U32, +h9: U32, +h10: U32, +h11: U32, +h12: U32, +h13: U32, +h14: U32, +h15: U32, +h16: U32, +h17: U32, +h18: U32, +h19: U32, +h20: U32, +h21: U32, +h22: U32, +h23: U32, +h24: U32, +h25: U32, +h26: U32, +h27: U32, +h28: U32, +h29: U32, +h30: U32, +h31: U32, +h32: U32, +h33: U32, +h34: U32, +h35: U32, +h36: U32, +h37: U32, +h38: U32, +h39: U32, +h40: U32, +h41: U32, +h42: U32, +h43: U32, +h44: U32, +h45: U32, +h46: U32, +h47: U32, +h48: U32, +h49: U32, +h50: U32, +h51: U32, +c2: Nat, +dw0: Nat, +dw1: Nat, +dw2: Nat, +dp: Nat, +pf0: {P0_FD.array__perfect(U32, dw0, T0) == True{} : Bool}, +pf1: {P0_FD.array__perfect(U32, dw1, T1) == True{} : Bool}, +pf2: {P0_FD.array__perfect(U32, dw2, T2) == True{} : Bool}, +pfP: {P0_FD.array__perfect(U32, dp, TP) == True{} : Bool}, +hdw0: {Nat.is_lt(dw0, 31n) == True{} : Bool}, +hdw1: {Nat.is_lt(dw1, 31n) == True{} : Bool}, +hdw2: {Nat.is_lt(dw2, 31n) == True{} : Bool}, +hdp: {Nat.is_lt(dp, 31n) == True{} : Bool}, +ec0: {U32.to_nat(N0) == P0_A.quad(P0_PRV.M0(c0)) : Nat}, +ec1: {U32.to_nat(N1) == P0_A.quad(P0_PRV.M1(c1)) : Nat}, +ec2: {U32.to_nat(N2) == P0_A.quad(P0_PRV.M2(c2)) : Nat}, +hc0: {Nat.is_le(c0, U32.to_nat(4096)) == True{} : Bool}, +hc1: {Nat.is_le(c1, U32.to_nat(4096)) == True{} : Bool}, +hc2: {Nat.is_le(c2, U32.to_nat(4096)) == True{} : Bool}, +hr0: {Nat.is_le(Nat.add(P0_VC.NW(N0), 0n), P0_VB.pw(dw0)) == True{} : Bool}, +hr1: {Nat.is_le(Nat.add(P0_VC.NW(N1), 0n), P0_VB.pw(dw1)) == True{} : Bool}, +hr2: {Nat.is_le(Nat.add(P0_VC.NW(N2), 0n), P0_VB.pw(dw2)) == True{} : Bool}, +hrP: {Nat.is_le(32n, P0_VB.pw(dp)) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.DataColumnSidecar(), P0_VS.bt(U32.to_nat(P0_PRV.S3(N0, N1, N2)), P0_F.limbs(P0_FD.array__slots(U32, P0_PRV.D9(N0, N1, N2, c0, c1, T0, T1, T2, TP, i0, i1, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51)))), P0_PRV.XE(N0, N1, N2, c0, c1, T0, T1, T2, TP, i0, i1, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, c2, dw0, dw1, dw2, dp, pf0, pf1, pf2, pfP, hdw0, hdw1, hdw2, hdp, ec0, ec1, ec2, hc0, hc1, hc2, hr0, hr1, hr2, hrP)):
  P0_PRV.encode_spec(N0, N1, N2, c0, c1, T0, T1, T2, TP, i0, i1, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, c2, dw0, dw1, dw2, dp, pf0, pf1, pf2, pfP, hdw0, hdw1, hdw2, hdp, ec0, ec1, ec2, hc0, hc1, hc2, hr0, hr1, hr2, hrP)

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_api_len() -> {(Pair.snd(P1_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default())), (Pair.snd(P1_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P1_O.words_new(2048))), (Pair.snd(P1_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len(Pair.fst(P1_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P1_O.words_new(2048))))), (Pair.snd(P1_O.Words, Maybe<&1, P1_O.Words>, Fulu_list_bytevec_2048_4096_d.l4096_b2048_get(Pair.fst(P1_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P1_O.words_new(2048))), 1)), (Pair.snd(P1_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_set(Pair.fst(P1_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P1_O.words_new(2048))), 1, P1_O.words_new(2048))), Pair.snd(P1_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len(Pair.fst(P1_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_set(Pair.fst(P1_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P1_O.words_new(2048))), 0, P1_O.words_new(2048)))))))))) == (0, (True{}, (1, (None{}, (False{}, 1))))) : U32 & (Bool & (U32 & (Maybe<&1, P1_O.Words> & (Bool & U32))))}:
  P1_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_api_len()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_api_get() -> {(Pair.snd(P2_O.Words, U32, Fulu_list_bytevec_48_4096_d.l4096_b48_len(P2_PRV.obj())), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(P2_PRV.obj(), 0)), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(P2_PRV.obj(), 1)), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(P2_PRV.obj(), 2)), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(P2_PRV.obj(), 3)), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(P2_PRV.obj(), 4)), Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(P2_PRV.obj(), 4294967295)))))))) == (3, (Some{FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051}}, (Some{FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}}, (Some{FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691}}, (None{}, (None{}, None{})))))) : U32 & (Maybe<&1, FuluBytes48_d.Bytes48> & (Maybe<&1, FuluBytes48_d.Bytes48> & (Maybe<&1, FuluBytes48_d.Bytes48> & (Maybe<&1, FuluBytes48_d.Bytes48> & (Maybe<&1, FuluBytes48_d.Bytes48> & Maybe<&1, FuluBytes48_d.Bytes48>)))))}:
  P2_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_api_get()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_api_default() -> {(Pair.snd(P2_O.Words, U32, Fulu_list_bytevec_48_4096_d.l4096_b48_len(Fulu_list_bytevec_48_4096_d.l4096_b48_default())), Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), 0))) == (0, None{}) : U32 & Maybe<&1, FuluBytes48_d.Bytes48>}:
  P2_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_api_default()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_api_set_0() -> {(Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 0, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 0, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 0)), (Pair.snd(P2_O.Words, U32, Fulu_list_bytevec_48_4096_d.l4096_b48_len(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 0, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})))), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 0, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 1)), Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 0, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 2)))))) == (True{}, (Some{FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131}}, (3, (Some{FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}}, Some{FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691}})))) : Bool & (Maybe<&1, FuluBytes48_d.Bytes48> & (U32 & (Maybe<&1, FuluBytes48_d.Bytes48> & Maybe<&1, FuluBytes48_d.Bytes48>)))}:
  P2_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_api_set_0()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_api_set_1() -> {(Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 1, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 1, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 1)), (Pair.snd(P2_O.Words, U32, Fulu_list_bytevec_48_4096_d.l4096_b48_len(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 1, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})))), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 1, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 0)), Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 1, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 2)))))) == (True{}, (Some{FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131}}, (3, (Some{FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051}}, Some{FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691}})))) : Bool & (Maybe<&1, FuluBytes48_d.Bytes48> & (U32 & (Maybe<&1, FuluBytes48_d.Bytes48> & Maybe<&1, FuluBytes48_d.Bytes48>)))}:
  P2_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_api_set_1()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_api_set_2() -> {(Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 2, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 2, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 2)), (Pair.snd(P2_O.Words, U32, Fulu_list_bytevec_48_4096_d.l4096_b48_len(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 2, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})))), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 2, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 0)), Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 2, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131})), 1)))))) == (True{}, (Some{FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131}}, (3, (Some{FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051}}, Some{FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}})))) : Bool & (Maybe<&1, FuluBytes48_d.Bytes48> & (U32 & (Maybe<&1, FuluBytes48_d.Bytes48> & Maybe<&1, FuluBytes48_d.Bytes48>)))}:
  P2_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_api_set_2()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_api_set_out() -> {(Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 3, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131}), (Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 4, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131}), Fulu_list_bytevec_48_4096_d.l4096_b48_set(P2_PRV.obj(), 4294967295, FuluBytes48_d.Bytes48{1010565120, 1010565121, 1010565122, 1010565123, 1010565124, 1010565125, 1010565126, 1010565127, 1010565128, 1010565129, 1010565130, 1010565131}))) == ((P2_PRV.obj(), False{}), ((P2_PRV.obj(), False{}), (P2_PRV.obj(), False{}))) : (P2_O.Words & Bool) & ((P2_O.Words & Bool) & (P2_O.Words & Bool))}:
  P2_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_api_set_out()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_api_len() -> {(Pair.snd(P2_O.Words, U32, Fulu_list_bytevec_48_4096_d.l4096_b48_len(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})))), Pair.snd(P2_O.Words, U32, Fulu_list_bytevec_48_4096_d.l4096_b48_len(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_set(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), 0, FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}))))) == (1, 1) : U32 & U32}:
  P2_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_api_len()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_api_append() -> {(Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), (Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})), (Pair.snd(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})), FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691})), (Pair.snd(P2_O.Words, U32, Fulu_list_bytevec_48_4096_d.l4096_b48_len(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})), FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691})))), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})), FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691})), 0)), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})), FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691})), 1)), (Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})), FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691})), 2)), Pair.snd(P2_O.Words, Maybe<&1, FuluBytes48_d.Bytes48>, Fulu_list_bytevec_48_4096_d.l4096_b48_get(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Pair.fst(P2_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(Fulu_list_bytevec_48_4096_d.l4096_b48_default(), FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051})), FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})), FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691})), 3))))))))) == (True{}, (True{}, (True{}, (3, (Some{FuluBytes48_d.Bytes48{4294967040, 4294967041, 4294967042, 4294967043, 4294967044, 4294967045, 4294967046, 4294967047, 4294967048, 4294967049, 4294967050, 4294967051}}, (Some{FuluBytes48_d.Bytes48{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}}, (Some{FuluBytes48_d.Bytes48{1515847680, 1515847681, 1515847682, 1515847683, 1515847684, 1515847685, 1515847686, 1515847687, 1515847688, 1515847689, 1515847690, 1515847691}}, None{}))))))) : Bool & (Bool & (Bool & (U32 & (Maybe<&1, FuluBytes48_d.Bytes48> & (Maybe<&1, FuluBytes48_d.Bytes48> & (Maybe<&1, FuluBytes48_d.Bytes48> & Maybe<&1, FuluBytes48_d.Bytes48>))))))}:
  P2_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_api_append()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_appb_below() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(P3_O.Words{Array.new(U32, 22n, 0), 8386560}, P3_O.words_new(2048))) == True{} : Bool}:
  P3_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_appb_below()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_appb_at() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(P3_O.Words{Array.new(U32, 22n, 0), 8388608}, P3_O.words_new(2048))) == False{} : Bool}:
  P3_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_appb_at()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_appb_above() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(P3_O.Words{Array.new(U32, 22n, 0), 8390656}, P3_O.words_new(2048))) == False{} : Bool}:
  P3_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_appb_above()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_appb_short() -> {Pair.snd(P3_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(P3_O.Words{Array.new(U32, 0n, 0), 2048}, P3_O.words_new(2048))) == False{} : Bool}:
  P3_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_appb_short()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_appb_below() -> {Pair.snd(P4_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(P4_O.Words{Array.new(U32, 16n, 0), 196560}, FuluBytes48_d.b48_default())) == True{} : Bool}:
  P4_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_appb_below()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_appb_at() -> {Pair.snd(P4_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(P4_O.Words{Array.new(U32, 16n, 0), 196608}, FuluBytes48_d.b48_default())) == False{} : Bool}:
  P4_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_appb_at()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b48_appb_above() -> {Pair.snd(P4_O.Words, Bool, Fulu_list_bytevec_48_4096_d.l4096_b48_append(P4_O.Words{Array.new(U32, 16n, 0), 196656}, FuluBytes48_d.b48_default())) == False{} : Bool}:
  P4_PRV.DataColumnSidecar_serialize_vcoll_l4096_b48_appb_above()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_blit() -> {((Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.fst(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 0)), (Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.fst(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 1)), (Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.fst(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 2)), (Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.fst(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 3)), (Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.fst(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 4)), (Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.fst(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 8)), Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.fst(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 9)))))))), (Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.snd(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 0)), (Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.snd(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))), 1)), (Pair.snd(P5_O.Words, U32, P5_O.words_len(Pair.snd(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_write(P5_O.words_write(P5_O.words_new(8), 0, 11, 4), 4, 22, 4))))), (Pair.snd(P5_O.Words, U32, P5_O.words_len(Pair.snd(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_new(0))))), Pair.snd(P5_O.Words, U32, P5_O.words_word(Pair.fst(P5_O.Words, P5_O.Words, P5_O.words_blit(P5_O.words_new(64), 8, P5_O.words_new(0))), 2))))))) == ((0, (0, (11, (22, (0, (0, 0)))))), (11, (22, (8, (0, 0))))) : (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))) & (U32 & (U32 & (U32 & (U32 & U32))))}:
  P5_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_blit()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_get_0() -> {P6_PRV.sig(Pair.snd(P6_O.Words, Maybe<&1, P6_O.Words>, Fulu_list_bytevec_2048_4096_d.l4096_b2048_get(P6_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P6_O.words_write(P6_O.words_write(P6_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), 0))) == (2048, (1, 2)) : U32 & (U32 & U32)}:
  P6_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_get_0()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_get_1() -> {P7_PRV.sig(Pair.snd(P7_O.Words, Maybe<&1, P7_O.Words>, Fulu_list_bytevec_2048_4096_d.l4096_b2048_get(P7_PRV.ap(P7_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P7_O.words_write(P7_O.words_write(P7_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), P7_O.words_write(P7_O.words_write(P7_O.words_new(2048), 0, 3, 4), 2044, 4, 4)), 1))) == (2048, (3, 4)) : U32 & (U32 & U32)}:
  P7_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_get_1()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_get_end() -> {P8_PRV.sig(Pair.snd(P8_O.Words, Maybe<&1, P8_O.Words>, Fulu_list_bytevec_2048_4096_d.l4096_b2048_get(P8_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P8_O.words_write(P8_O.words_write(P8_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), 1))) == (0, (0, 0)) : U32 & (U32 & U32)}:
  P8_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_get_end()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_len() -> {(Pair.snd(P9_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len_of((P9_O.words_new(0), 0))), (Pair.snd(P9_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len_of((P9_O.words_new(0), 2047))), (Pair.snd(P9_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len_of((P9_O.words_new(0), 2048))), (Pair.snd(P9_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len_of((P9_O.words_new(0), 4095))), (Pair.snd(P9_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len_of((P9_O.words_new(0), 4096))), (Pair.snd(P9_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len_of((P9_O.words_new(0), 4192256))), Pair.snd(P9_O.Words, U32, Fulu_list_bytevec_2048_4096_d.l4096_b2048_len_of((P9_O.words_new(0), 8388608))))))))) == (0, (0, (1, (1, (2, (2047, 4096)))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))}:
  P9_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_len()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_app_long() -> {Pair.snd(P10_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P10_O.words_new(2049))) == False{} : Bool}:
  P10_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_app_long()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_app_ok() -> {Pair.snd(P11_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P11_O.words_write(P11_O.words_write(P11_O.words_new(2048), 0, 7, 4), 2044, 8, 4))) == True{} : Bool}:
  P11_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_app_ok()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_app_short() -> {Pair.snd(P12_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P12_O.words_new(2047))) == False{} : Bool}:
  P12_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_app_short()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_app_tight() -> {Pair.snd(P13_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_append(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P13_O.Words{Array.new(U32, 0n, 0), 2048})) == False{} : Bool}:
  P13_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_app_tight()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_set_end() -> {Pair.snd(P14_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_set(P14_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P14_O.words_write(P14_O.words_write(P14_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), 1, P14_O.words_write(P14_O.words_write(P14_O.words_new(2048), 0, 7, 4), 2044, 8, 4))) == False{} : Bool}:
  P14_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_set_end()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_set_long() -> {Pair.snd(P15_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_set(P15_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P15_O.words_write(P15_O.words_write(P15_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), 0, P15_O.words_new(2049))) == False{} : Bool}:
  P15_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_set_long()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_set_short() -> {Pair.snd(P16_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_set(P16_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P16_O.words_write(P16_O.words_write(P16_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), 0, P16_O.words_new(2047))) == False{} : Bool}:
  P16_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_set_short()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_set_tight() -> {Pair.snd(P17_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_set(P17_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P17_O.words_write(P17_O.words_write(P17_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), 0, P17_O.Words{Array.new(U32, 0n, 0), 2048})) == False{} : Bool}:
  P17_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_refuse_set_tight()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_set_get_0() -> {P18_PRV.sig(Pair.snd(P18_O.Words, Maybe<&1, P18_O.Words>, Fulu_list_bytevec_2048_4096_d.l4096_b2048_get(Pair.fst(P18_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_set(P18_PRV.ap(P18_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P18_O.words_write(P18_O.words_write(P18_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), P18_O.words_write(P18_O.words_write(P18_O.words_new(2048), 0, 3, 4), 2044, 4, 4)), 1, P18_O.words_write(P18_O.words_write(P18_O.words_new(2048), 0, 7, 4), 2044, 8, 4))), 0))) == (2048, (1, 2)) : U32 & (U32 & U32)}:
  P18_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_set_get_0()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_set_get_1() -> {P19_PRV.sig(Pair.snd(P19_O.Words, Maybe<&1, P19_O.Words>, Fulu_list_bytevec_2048_4096_d.l4096_b2048_get(Pair.fst(P19_O.Words, Bool, Fulu_list_bytevec_2048_4096_d.l4096_b2048_set(P19_PRV.ap(P19_PRV.ap(Fulu_list_bytevec_2048_4096_d.l4096_b2048_default(), P19_O.words_write(P19_O.words_write(P19_O.words_new(2048), 0, 1, 4), 2044, 2, 4)), P19_O.words_write(P19_O.words_write(P19_O.words_new(2048), 0, 3, 4), 2044, 4, 4)), 1, P19_O.words_write(P19_O.words_write(P19_O.words_new(2048), 0, 7, 4), 2044, 8, 4))), 1))) == (2048, (7, 8)) : U32 & (U32 & U32)}:
  P19_PRV.DataColumnSidecar_serialize_vcoll_l4096_b2048_cell_set_get_1()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vreject_default_valid() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, Bool, FuluDataColumnSidecar_e.DataColumnSidecar_valid(FuluDataColumnSidecar_d.DataColumnSidecar_default())) == True{} : Bool}:
  P20_PRV.DataColumnSidecar_serialize_vreject_default_valid()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vrefuse_bad_flag() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, P20_O.Encoded, FuluDataColumnSidecar_e.DataColumnSidecar_senc_go(True{}, 0, FuluDataColumnSidecar_d.DataColumnSidecar_default())) == P20_O.refused() : P20_O.Encoded}:
  P20_PRV.DataColumnSidecar_serialize_vrefuse_bad_flag()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vrefuse_poisoned_size() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, P20_O.Encoded, FuluDataColumnSidecar_e.DataColumnSidecar_senc_sized((FuluDataColumnSidecar_d.DataColumnSidecar_default(), 4294967295))) == P20_O.refused() : P20_O.Encoded}:
  P20_PRV.DataColumnSidecar_serialize_vrefuse_poisoned_size()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vreject_column() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, Bool, FuluDataColumnSidecar_e.DataColumnSidecar_valid(FuluDataColumnSidecar_d.DataColumnSidecar_set_column(FuluDataColumnSidecar_d.DataColumnSidecar_default(), P20_O.Words{Array.new(U32, 0n, 0), 5}))) == False{} : Bool}:
  P20_PRV.DataColumnSidecar_serialize_vreject_column()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vreject_kzg_commitments() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, Bool, FuluDataColumnSidecar_e.DataColumnSidecar_valid(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_commitments(FuluDataColumnSidecar_d.DataColumnSidecar_default(), P20_O.Words{Array.new(U32, 0n, 0), 5}))) == False{} : Bool}:
  P20_PRV.DataColumnSidecar_serialize_vreject_kzg_commitments()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vreject_kzg_proofs() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, Bool, FuluDataColumnSidecar_e.DataColumnSidecar_valid(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_proofs(FuluDataColumnSidecar_d.DataColumnSidecar_default(), P20_O.Words{Array.new(U32, 0n, 0), 5}))) == False{} : Bool}:
  P20_PRV.DataColumnSidecar_serialize_vreject_kzg_proofs()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vreject_signed_block_header() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, Bool, FuluDataColumnSidecar_e.DataColumnSidecar_valid(FuluDataColumnSidecar_d.DataColumnSidecar_set_signed_block_header(FuluDataColumnSidecar_d.DataColumnSidecar_default(), P20_O.BNone{}))) == False{} : Bool}:
  P20_PRV.DataColumnSidecar_serialize_vreject_signed_block_header()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vrefuse_signed_block_header() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, P20_O.Encoded, FuluDataColumnSidecar_e.DataColumnSidecar_serialize(FuluDataColumnSidecar_d.DataColumnSidecar_set_signed_block_header(FuluDataColumnSidecar_d.DataColumnSidecar_default(), P20_O.BNone{}))) == P20_O.refused() : P20_O.Encoded}:
  P20_PRV.DataColumnSidecar_serialize_vrefuse_signed_block_header()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vreject_kzg_commitments_inclusion_proof() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, Bool, FuluDataColumnSidecar_e.DataColumnSidecar_valid(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_commitments_inclusion_proof(FuluDataColumnSidecar_d.DataColumnSidecar_default(), P20_O.Words{Array.new(U32, 0n, 0), 5}))) == False{} : Bool}:
  P20_PRV.DataColumnSidecar_serialize_vreject_kzg_commitments_inclusion_proof()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vrefuse_writer_marker() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, P21_O.Encoded, FuluDataColumnSidecar_e.DataColumnSidecar_senc_out(0, Array.new(U32, 0n, 0), FuluDataColumnSidecar_d.DataColumnSidecar_default(), 4294967295)) == P21_O.refused() : P21_O.Encoded}:
  P21_PRV.DataColumnSidecar_serialize_vrefuse_writer_marker()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vrefuse_writer_above() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, P21_O.Encoded, FuluDataColumnSidecar_e.DataColumnSidecar_senc_out(0, Array.new(U32, 0n, 0), FuluDataColumnSidecar_d.DataColumnSidecar_default(), 4294967265)) == P21_O.refused() : P21_O.Encoded}:
  P21_PRV.DataColumnSidecar_serialize_vrefuse_writer_above()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vrefuse_writer_ok() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, P21_O.Encoded, FuluDataColumnSidecar_e.DataColumnSidecar_senc_out(0, Array.new(U32, 0n, 0), FuluDataColumnSidecar_d.DataColumnSidecar_default(), 0)) == P21_O.Encoded{True{}, P21_B.Buf{Array.new(U32, 0n, 0), 0}} : P21_O.Encoded}:
  P21_PRV.DataColumnSidecar_serialize_vrefuse_writer_ok()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b2048_refuse_1() -> {Pair.snd(P22_O.Words, Bool, Fulu_list_bytevec_2048_4096_e.l4096_b2048_valid(P22_O.words_new(1))) == False{} : Bool}:
  P22_PRV.DataColumnSidecar_serialize_vunit_l4096_b2048_refuse_1()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b2048_refuse_1024() -> {Pair.snd(P22_O.Words, Bool, Fulu_list_bytevec_2048_4096_e.l4096_b2048_valid(P22_O.words_new(1024))) == False{} : Bool}:
  P22_PRV.DataColumnSidecar_serialize_vunit_l4096_b2048_refuse_1024()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b2048_refuse_2049() -> {Pair.snd(P22_O.Words, Bool, Fulu_list_bytevec_2048_4096_e.l4096_b2048_valid(P22_O.words_new(2049))) == False{} : Bool}:
  P22_PRV.DataColumnSidecar_serialize_vunit_l4096_b2048_refuse_2049()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b2048_accept_2048() -> {Pair.snd(P22_O.Words, Bool, Fulu_list_bytevec_2048_4096_e.l4096_b2048_valid(P22_O.words_new(2048))) == True{} : Bool}:
  P22_PRV.DataColumnSidecar_serialize_vunit_l4096_b2048_accept_2048()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b2048_accept_4096() -> {Pair.snd(P22_O.Words, Bool, Fulu_list_bytevec_2048_4096_e.l4096_b2048_valid(P22_O.words_new(4096))) == True{} : Bool}:
  P22_PRV.DataColumnSidecar_serialize_vunit_l4096_b2048_accept_4096()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b2048_range_lo_0() -> {Pair.snd(P22_O.Words, Bool, Fulu_list_bytevec_2048_4096_e.l4096_b2048_valid(P22_O.words_new(0))) == True{} : Bool}:
  P22_PRV.DataColumnSidecar_serialize_vunit_l4096_b2048_range_lo_0()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b2048_range_hi_full() -> {Pair.snd(P22_O.Words, Bool, Fulu_list_bytevec_2048_4096_e.l4096_b2048_valid(P22_O.Words{Array.new(U32, 30n, 0), 8388608})) == True{} : Bool}:
  P22_PRV.DataColumnSidecar_serialize_vunit_l4096_b2048_range_hi_full()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b2048_range_above_full() -> {Pair.snd(P22_O.Words, Bool, Fulu_list_bytevec_2048_4096_e.l4096_b2048_valid(P22_O.Words{Array.new(U32, 30n, 0), 8390656})) == False{} : Bool}:
  P22_PRV.DataColumnSidecar_serialize_vunit_l4096_b2048_range_above_full()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_ok_2048() -> {(P22_O.unit_ok(2048, 1), (P22_O.unit_ok(2048, 1024), (P22_O.unit_ok(2048, 2047), (P22_O.unit_ok(2048, 2048), (P22_O.unit_ok(2048, 2049), (P22_O.unit_ok(2048, 4095), (P22_O.unit_ok(2048, 4096), (P22_O.unit_ok(2048, 6144), P22_O.unit_ok(2048, 7168))))))))) == (False{}, (False{}, (False{}, (True{}, (False{}, (False{}, (True{}, (True{}, False{})))))))) : Bool & (Bool & (Bool & (Bool & (Bool & (Bool & (Bool & (Bool & (Bool))))))))}:
  P22_PRV.DataColumnSidecar_serialize_vunit_ok_2048()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b48_refuse_1() -> {Pair.snd(P23_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P23_O.words_new(1))) == False{} : Bool}:
  P23_PRV.DataColumnSidecar_serialize_vunit_l4096_b48_refuse_1()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b48_refuse_24() -> {Pair.snd(P23_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P23_O.words_new(24))) == False{} : Bool}:
  P23_PRV.DataColumnSidecar_serialize_vunit_l4096_b48_refuse_24()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b48_refuse_49() -> {Pair.snd(P23_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P23_O.words_new(49))) == False{} : Bool}:
  P23_PRV.DataColumnSidecar_serialize_vunit_l4096_b48_refuse_49()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b48_accept_48() -> {Pair.snd(P23_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P23_O.words_new(48))) == True{} : Bool}:
  P23_PRV.DataColumnSidecar_serialize_vunit_l4096_b48_accept_48()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b48_accept_96() -> {Pair.snd(P23_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P23_O.words_new(96))) == True{} : Bool}:
  P23_PRV.DataColumnSidecar_serialize_vunit_l4096_b48_accept_96()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b48_range_lo_0() -> {Pair.snd(P23_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P23_O.words_new(0))) == True{} : Bool}:
  P23_PRV.DataColumnSidecar_serialize_vunit_l4096_b48_range_lo_0()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b48_range_hi_196608() -> {Pair.snd(P23_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P23_O.words_new(196608))) == True{} : Bool}:
  P23_PRV.DataColumnSidecar_serialize_vunit_l4096_b48_range_hi_196608()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_l4096_b48_range_above_196656() -> {Pair.snd(P23_O.Words, Bool, Fulu_list_bytevec_48_4096_e.l4096_b48_valid(P23_O.words_new(196656))) == False{} : Bool}:
  P23_PRV.DataColumnSidecar_serialize_vunit_l4096_b48_range_above_196656()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_v4_b32_range_below_96() -> {Pair.snd(P24_O.Words, Bool, FuluExecutionBranch_e.v4_b32_valid(P24_O.words_new(96))) == False{} : Bool}:
  P24_PRV.DataColumnSidecar_serialize_vunit_v4_b32_range_below_96()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_v4_b32_range_lo_128() -> {Pair.snd(P24_O.Words, Bool, FuluExecutionBranch_e.v4_b32_valid(P24_O.words_new(128))) == True{} : Bool}:
  P24_PRV.DataColumnSidecar_serialize_vunit_v4_b32_range_lo_128()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vunit_v4_b32_range_above_160() -> {Pair.snd(P24_O.Words, Bool, FuluExecutionBranch_e.v4_b32_valid(P24_O.words_new(160))) == False{} : Bool}:
  P24_PRV.DataColumnSidecar_serialize_vunit_v4_b32_range_above_160()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vpoison_pk_l4096_b2048() -> {P25_O.is_poisoned(Pair.snd(P25_O.Words, U32, Pair.snd(Array<U32>, P25_O.Words & U32, Fulu_list_bytevec_2048_4096_e.l4096_b2048_pk(Array.new(U32, 0n, 0), 0, (P25_O.words_new(0), False{}))))) == True{} : Bool}:
  P25_PRV.DataColumnSidecar_serialize_vpoison_pk_l4096_b2048()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_serialize_vpoison_pk_l4096_b48() -> {P26_O.is_poisoned(Pair.snd(P26_O.Words, U32, Pair.snd(Array<U32>, P26_O.Words & U32, Fulu_list_bytevec_48_4096_e.l4096_b48_pk(Array.new(U32, 0n, 0), 0, (P26_O.words_new(0), False{}))))) == True{} : Bool}:
  P26_PRV.DataColumnSidecar_serialize_vpoison_pk_l4096_b48()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_ms_size() -> {Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, U32, FuluDataColumnSidecar_e.DataColumnSidecar_size(FuluDataColumnSidecar_d.DataColumnSidecar_default())) == 356 : U32}:
  P27_PRV.DataColumnSidecar_ms_size()

def FuluDataColumnSidecar__serialize_valid__DataColumnSidecar_mc_ser() -> {FuluDataColumnSidecar_e.DataColumnSidecar_serialize(FuluDataColumnSidecar_d.DataColumnSidecar_set_index(FuluDataColumnSidecar_d.DataColumnSidecar_default(), uint64_d.u64_seed(2271597235))) == (Pair.fst(FuluDataColumnSidecar_d.DataColumnSidecar, P28_B.Buf, FuluDataColumnSidecar_e.DataColumnSidecar_encode(FuluDataColumnSidecar_d.DataColumnSidecar_set_index(FuluDataColumnSidecar_d.DataColumnSidecar_default(), uint64_d.u64_seed(2271597235)))), P28_O.encoded(Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, P28_B.Buf, FuluDataColumnSidecar_e.DataColumnSidecar_encode(FuluDataColumnSidecar_d.DataColumnSidecar_set_index(FuluDataColumnSidecar_d.DataColumnSidecar_default(), uint64_d.u64_seed(2271597235)))))) : FuluDataColumnSidecar_d.DataColumnSidecar & P28_O.Encoded}:
  P28_PRV.DataColumnSidecar_mc_ser()

