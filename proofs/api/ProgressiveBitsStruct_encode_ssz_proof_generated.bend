import Base
import ../../src/obj.bend as P0_O
import ../../src/primitives.bend as P0_I
import ../../types/bitvector_256_def_generated.bend as bitvector_256_d
import ../../types/bitvector_257_def_generated.bend as bitvector_257_d
import ../../types/progbitlist_def_generated.bend as progbitlist_d
import ../../types/bitlist_256_def_generated.bend as bitlist_256_d
import ../../types/bitlist_256_encode_ssz_generated.bend as bitlist_256_e
import ../../types/bitlist_257_def_generated.bend as bitlist_257_d
import ../../types/bitlist_257_encode_ssz_generated.bend as bitlist_257_e
import ../../types/bitvector_1280_encode_ssz_generated.bend as bitvector_1280_e
import ../../types/bitlist_1280_def_generated.bend as bitlist_1280_d
import ../../types/bitlist_1280_encode_ssz_generated.bend as bitlist_1280_e
import ../../types/bitvector_1281_encode_ssz_generated.bend as bitvector_1281_e
import ../../types/bitlist_1281_def_generated.bend as bitlist_1281_d
import ../../types/bitlist_1281_encode_ssz_generated.bend as bitlist_1281_e
import ../../types/ProgressiveBitsStruct_def_generated.bend as ProgressiveBitsStruct_d
import ../../types/ProgressiveBitsStruct_encode_ssz_generated.bend as ProgressiveBitsStruct_e
import ../../types/schema.bend as P0_S
import ../../types/primitive.bend as P0_P
import ../../spec/codec.bend as P0_Codec
import ../../spec/layout.bend as P0_Layout
import ../../spec/primitives.bend as P0_SP
import ../obj/generic_specs_generated.bend as P0_Spec
import ../compact/found_generated.bend as P0_FD
import ../compact/arith.bend as P0_A
import ../../proofs/nat_order.bend as P0_Order
import ../obj/spec_fixed.bend as P0_FX
import ../obj/vspec.bend as P0_VS
import ../obj/vbuf.bend as P0_VB
import ../obj/vua.bend as P0_UA
import ../obj/vuw.bend as P0_UW
import ../obj/vuwd.bend as P0_WD
import ../obj/vcopy.bend as P0_VC
import ../obj/vrecx.bend as P0_VRX
import ../obj/vcont.bend as P0_VCN
import ../obj/vua_lay.bend as P0_LY
import ../obj/vconts.bend as P0_CS
import ../obj/spec_bits_generated.bend as P0_FB
import ../obj/dk.bend as P0_DK
import ../obj/vuwg_bv256_generated.bend as P0_V_bv256
import ../obj/vbv257.bend as P0_V_bv257
import ../obj/vuwg_bv1280_generated.bend as P0_V_bv1280
import ../obj/vbv1281d.bend as P0_V_bv1281
import ../obj/encx_bits256_generated.bend as P0_EX_bits256
import ../obj/encx_pbits_generated.bend as P0_EX_pbits
import ../obj/encx_bits257_generated.bend as P0_EX_bits257
import ../obj/encx_bits1280_generated.bend as P0_EX_bits1280
import ../obj/encx_bits1281_generated.bend as P0_EX_bits1281
import ../obj/vpiece.bend as P0_VPC
import ../obj/vbv257s.bend as P0_V2S
import ../obj/vbv128s.bend as P0_V2S8
import ../obj/vmr_generated.bend as P0_VMR
import ../obj/vbenc.bend as P0_VBE
import ../../src/buffer.bend as P0_B
import ../../spec/decoding_relation.bend as P0_Decoding
import ../obj/vlist.bend as P0_VL
import ../obj/vdepth.bend as P0_VD
import ../obj/vvlz_generated.bend as P0_VZG
import ../obj/vuwb.bend as P0_UWB
import ../obj/vvle.bend as P0_VE2
import ../obj/encx_ProgressiveBitsStruct_iface_generated.bend as P0_CI
import ../obj/encx_ProgressiveBitsStruct_size_generated.bend as P0_Z
import ../obj/var_codec_ProgressiveBitsStruct_enc_generated.bend as P0_PRV
import ../../src/obj.bend as P1_O
import ../slop/validity/generic_ProgressiveBitsStruct_appb_bits1280_generated.bend as P1_PRV
import ../../src/obj.bend as P2_O
import ../slop/validity/generic_ProgressiveBitsStruct_appb_bits1281_generated.bend as P2_PRV
import ../../src/obj.bend as P3_O
import ../slop/validity/generic_ProgressiveBitsStruct_appb_bits256_generated.bend as P3_PRV
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_ProgressiveBitsStruct_appb_bits257_generated.bend as P4_PRV
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_ProgressiveBitsStruct_appb_pbits_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_ProgressiveBitsStruct_bitops_bits1280_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_ProgressiveBitsStruct_bitops_bits1281_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_ProgressiveBitsStruct_bitops_bits256_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_ProgressiveBitsStruct_bitops_bits257_generated.bend as P9_PRV
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_ProgressiveBitsStruct_collection_bits1280_generated.bend as P10_PRV
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_ProgressiveBitsStruct_collection_bits1281_generated.bend as P11_PRV
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_ProgressiveBitsStruct_collection_bits256_generated.bend as P12_PRV
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_ProgressiveBitsStruct_collection_bits257_generated.bend as P13_PRV
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_ProgressiveBitsStruct_collection_pbits_generated.bend as P14_PRV
import ../../src/obj.bend as P15_O
import ../slop/validity/generic_ProgressiveBitsStruct_fields_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/generic_ProgressiveBitsStruct_senc_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../slop/validity/generic_ProgressiveBitsStruct_size_bits1280_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/generic_ProgressiveBitsStruct_size_bits1281_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/generic_ProgressiveBitsStruct_size_bits256_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/generic_ProgressiveBitsStruct_size_bits257_generated.bend as P20_PRV
import ../../src/obj.bend as P21_O
import ../slop/validity/generic_ProgressiveBitsStruct_unit_bv1280_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../slop/validity/generic_ProgressiveBitsStruct_writer_bits1280_generated.bend as P22_PRV
import ../../src/buffer.bend as P23_B
import ../../src/obj.bend as P23_O
import ../slop/validity/generic_ProgressiveBitsStruct_writer_bits1281_generated.bend as P23_PRV
import ../../src/buffer.bend as P24_B
import ../../src/obj.bend as P24_O
import ../slop/validity/generic_ProgressiveBitsStruct_writer_bits256_generated.bend as P24_PRV
import ../../src/buffer.bend as P25_B
import ../../src/obj.bend as P25_O
import ../slop/validity/generic_ProgressiveBitsStruct_writer_bits257_generated.bend as P25_PRV
import ../../src/buffer.bend as P26_B
import ../../src/obj.bend as P26_O
import ../slop/validity/generic_ProgressiveBitsStruct_writer_bv1280_generated.bend as P26_PRV
import ../../src/buffer.bend as P27_B
import ../../src/obj.bend as P27_O
import ../slop/validity/generic_ProgressiveBitsStruct_writer_bv1281_generated.bend as P27_PRV
import ../../src/buffer.bend as P28_B
import ../../src/obj.bend as P28_O
import ../../src/digest.bend as P28_D
import ../slop/constants/ProgressiveBitsStruct_generated.bend as P28_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# ProgressiveBitsStruct: its encode_ssz laws in the object API's terms, each discharged by its proving law.

def ProgressiveBitsStruct__encode_eval__encode_eval(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> {ProgressiveBitsStruct_e.ProgressiveBitsStruct_encode(P0_CI.TH(m)) == (P0_CI.TH(m), P0_B.Buf{P0_FD.array__thaw(U32, P0_PRV.OUTE(m)), P0_PRV.SZSM(m)}) : ProgressiveBitsStruct_d.ProgressiveBitsStruct & P0_B.Buf}:
  P0_PRV.encode_eval(m, hok)

def ProgressiveBitsStruct__encode_spec__encode_spec(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.ProgressiveBitsStruct(), P0_VS.bt(U32.to_nat(P0_PRV.SZSM(m)), P0_FX.limbs(P0_FD.array__slots(U32, P0_PRV.OUTE(m)))), P0_CI.VAL(m)):
  P0_PRV.encode_spec(m, hok)

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_below() -> {Pair.snd(P1_O.Bits, Bool, bitlist_1280_d.bits1280_append(P1_O.Bits{Array.new(U32, 6n, 0), 1279}, True{})) == True{} : Bool}:
  P1_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_below()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_at() -> {Pair.snd(P1_O.Bits, Bool, bitlist_1280_d.bits1280_append(P1_O.Bits{Array.new(U32, 6n, 0), 1280}, True{})) == False{} : Bool}:
  P1_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_at()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_above() -> {Pair.snd(P1_O.Bits, Bool, bitlist_1280_d.bits1280_append(P1_O.Bits{Array.new(U32, 6n, 0), 1281}, True{})) == False{} : Bool}:
  P1_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_above()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_fit() -> {Pair.snd(P1_O.Bits, Bool, bitlist_1280_d.bits1280_append(P1_O.Bits{Array.new(U32, 0n, 0), 32}, True{})) == True{} : Bool}:
  P1_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_fit()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_short() -> {Pair.snd(P1_O.Bits, Bool, bitlist_1280_d.bits1280_append(P1_O.Bits{Array.new(U32, 0n, 0), 33}, True{})) == False{} : Bool}:
  P1_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_appb_short()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_below() -> {Pair.snd(P2_O.Bits, Bool, bitlist_1281_d.bits1281_append(P2_O.Bits{Array.new(U32, 6n, 0), 1280}, True{})) == True{} : Bool}:
  P2_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_below()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_at() -> {Pair.snd(P2_O.Bits, Bool, bitlist_1281_d.bits1281_append(P2_O.Bits{Array.new(U32, 6n, 0), 1281}, True{})) == False{} : Bool}:
  P2_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_at()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_above() -> {Pair.snd(P2_O.Bits, Bool, bitlist_1281_d.bits1281_append(P2_O.Bits{Array.new(U32, 6n, 0), 1282}, True{})) == False{} : Bool}:
  P2_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_above()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_fit() -> {Pair.snd(P2_O.Bits, Bool, bitlist_1281_d.bits1281_append(P2_O.Bits{Array.new(U32, 0n, 0), 32}, True{})) == True{} : Bool}:
  P2_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_fit()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_short() -> {Pair.snd(P2_O.Bits, Bool, bitlist_1281_d.bits1281_append(P2_O.Bits{Array.new(U32, 0n, 0), 33}, True{})) == False{} : Bool}:
  P2_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_appb_short()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_appb_below() -> {Pair.snd(P3_O.Bits, Bool, bitlist_256_d.bits256_append(P3_O.Bits{Array.new(U32, 5n, 0), 255}, True{})) == True{} : Bool}:
  P3_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_appb_below()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_appb_at() -> {Pair.snd(P3_O.Bits, Bool, bitlist_256_d.bits256_append(P3_O.Bits{Array.new(U32, 5n, 0), 256}, True{})) == False{} : Bool}:
  P3_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_appb_at()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_appb_above() -> {Pair.snd(P3_O.Bits, Bool, bitlist_256_d.bits256_append(P3_O.Bits{Array.new(U32, 5n, 0), 257}, True{})) == False{} : Bool}:
  P3_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_appb_above()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_appb_fit() -> {Pair.snd(P3_O.Bits, Bool, bitlist_256_d.bits256_append(P3_O.Bits{Array.new(U32, 0n, 0), 32}, True{})) == True{} : Bool}:
  P3_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_appb_fit()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_appb_short() -> {Pair.snd(P3_O.Bits, Bool, bitlist_256_d.bits256_append(P3_O.Bits{Array.new(U32, 0n, 0), 33}, True{})) == False{} : Bool}:
  P3_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_appb_short()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_appb_below() -> {Pair.snd(P4_O.Bits, Bool, bitlist_257_d.bits257_append(P4_O.Bits{Array.new(U32, 5n, 0), 256}, True{})) == True{} : Bool}:
  P4_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_appb_below()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_appb_at() -> {Pair.snd(P4_O.Bits, Bool, bitlist_257_d.bits257_append(P4_O.Bits{Array.new(U32, 5n, 0), 257}, True{})) == False{} : Bool}:
  P4_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_appb_at()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_appb_above() -> {Pair.snd(P4_O.Bits, Bool, bitlist_257_d.bits257_append(P4_O.Bits{Array.new(U32, 5n, 0), 258}, True{})) == False{} : Bool}:
  P4_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_appb_above()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_appb_fit() -> {Pair.snd(P4_O.Bits, Bool, bitlist_257_d.bits257_append(P4_O.Bits{Array.new(U32, 0n, 0), 32}, True{})) == True{} : Bool}:
  P4_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_appb_fit()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_appb_short() -> {Pair.snd(P4_O.Bits, Bool, bitlist_257_d.bits257_append(P4_O.Bits{Array.new(U32, 0n, 0), 33}, True{})) == False{} : Bool}:
  P4_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_appb_short()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_pbits_appb_below() -> {Pair.snd(P5_O.Bits, Bool, progbitlist_d.pbits_append(P5_O.Bits{Array.new(U32, 28n, 0), 4294967294}, True{})) == True{} : Bool}:
  P5_PRV.ProgressiveBitsStruct_serialize_vcoll_pbits_appb_below()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_pbits_appb_at() -> {Pair.snd(P5_O.Bits, Bool, progbitlist_d.pbits_append(P5_O.Bits{Array.new(U32, 28n, 0), 4294967295}, True{})) == False{} : Bool}:
  P5_PRV.ProgressiveBitsStruct_serialize_vcoll_pbits_appb_at()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_pbits_appb_fit() -> {Pair.snd(P5_O.Bits, Bool, progbitlist_d.pbits_append(P5_O.Bits{Array.new(U32, 0n, 0), 32}, True{})) == True{} : Bool}:
  P5_PRV.ProgressiveBitsStruct_serialize_vcoll_pbits_appb_fit()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_pbits_appb_short() -> {Pair.snd(P5_O.Bits, Bool, progbitlist_d.pbits_append(P5_O.Bits{Array.new(U32, 0n, 0), 33}, True{})) == False{} : Bool}:
  P5_PRV.ProgressiveBitsStruct_serialize_vcoll_pbits_appb_short()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vbits_size() -> {(Pair.snd(P6_O.Bits, U32, P6_O.bits_size(P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 0})), (Pair.snd(P6_O.Bits, U32, P6_O.bits_size(P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 7})), (Pair.snd(P6_O.Bits, U32, P6_O.bits_size(P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 8})), (Pair.snd(P6_O.Bits, U32, P6_O.bits_size(P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 9})), Pair.snd(P6_O.Bits, U32, P6_O.bits_size(P6_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 64})))))) == (1, (1, (2, (2, 9)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P6_PRV.ProgressiveBitsStruct_serialize_vbits_size()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vbits_size_2() -> {(Pair.snd(P7_O.Bits, U32, P7_O.bits_size(P7_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 0})), (Pair.snd(P7_O.Bits, U32, P7_O.bits_size(P7_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 7})), (Pair.snd(P7_O.Bits, U32, P7_O.bits_size(P7_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 8})), (Pair.snd(P7_O.Bits, U32, P7_O.bits_size(P7_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 9})), Pair.snd(P7_O.Bits, U32, P7_O.bits_size(P7_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 64})))))) == (1, (1, (2, (2, 9)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P7_PRV.ProgressiveBitsStruct_serialize_vbits_size()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vbits_size_3() -> {(Pair.snd(P8_O.Bits, U32, P8_O.bits_size(P8_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 0})), (Pair.snd(P8_O.Bits, U32, P8_O.bits_size(P8_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 7})), (Pair.snd(P8_O.Bits, U32, P8_O.bits_size(P8_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 8})), (Pair.snd(P8_O.Bits, U32, P8_O.bits_size(P8_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 9})), Pair.snd(P8_O.Bits, U32, P8_O.bits_size(P8_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 64})))))) == (1, (1, (2, (2, 9)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P8_PRV.ProgressiveBitsStruct_serialize_vbits_size()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vbits_size_4() -> {(Pair.snd(P9_O.Bits, U32, P9_O.bits_size(P9_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 0})), (Pair.snd(P9_O.Bits, U32, P9_O.bits_size(P9_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 7})), (Pair.snd(P9_O.Bits, U32, P9_O.bits_size(P9_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 8})), (Pair.snd(P9_O.Bits, U32, P9_O.bits_size(P9_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 9})), Pair.snd(P9_O.Bits, U32, P9_O.bits_size(P9_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 0), 1, 0), 64})))))) == (1, (1, (2, (2, 9)))) : U32 & (U32 & (U32 & (U32 & (U32))))}:
  P9_PRV.ProgressiveBitsStruct_serialize_vbits_size()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_first() -> {(Pair.snd(P10_O.Bits, Bool, bitlist_1280_d.bits1280_append(bitlist_1280_d.bits1280_default(), True{})), (Pair.snd(P10_O.Bits, U32, bitlist_1280_d.bits1280_len(P10_PRV.ap(bitlist_1280_d.bits1280_default(), True{}))), (Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(P10_PRV.ap(bitlist_1280_d.bits1280_default(), True{}), 0)), Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(P10_PRV.ap(bitlist_1280_d.bits1280_default(), True{}), 1))))) == (True{}, (1, (Some{True{}}, None{}))) : Bool & (U32 & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P10_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_first()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_order() -> {(Pair.snd(P10_O.Bits, U32, bitlist_1280_d.bits1280_len(P10_PRV.ap(P10_PRV.ap(P10_PRV.ap(bitlist_1280_d.bits1280_default(), True{}), False{}), True{}))), (Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(P10_PRV.ap(P10_PRV.ap(P10_PRV.ap(bitlist_1280_d.bits1280_default(), True{}), False{}), True{}), 0)), (Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(P10_PRV.ap(P10_PRV.ap(P10_PRV.ap(bitlist_1280_d.bits1280_default(), True{}), False{}), True{}), 1)), (Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(P10_PRV.ap(P10_PRV.ap(P10_PRV.ap(bitlist_1280_d.bits1280_default(), True{}), False{}), True{}), 2)), Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(P10_PRV.ap(P10_PRV.ap(P10_PRV.ap(bitlist_1280_d.bits1280_default(), True{}), False{}), True{}), 3)))))) == (3, (Some{True{}}, (Some{False{}}, (Some{True{}}, None{})))) : U32 & (Maybe<&1, Bool> & (Maybe<&1, Bool> & (Maybe<&1, Bool> & Maybe<&1, Bool>)))}:
  P10_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_order()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_full() -> {(Pair.snd(P10_O.Bits, Bool, bitlist_1280_d.bits1280_append(P10_O.bits_zeros(1280), True{})), (Pair.snd(P10_O.Bits, Bool, bitlist_1280_d.bits1280_append(P10_O.bits_zeros(1279), True{})), Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(P10_PRV.ap(P10_O.bits_zeros(1279), True{}), 1279)))) == (False{}, (True{}, Some{True{}})) : Bool & (Bool & Maybe<&1, Bool>)}:
  P10_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_full()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1280_set_edge() -> {(Pair.snd(P10_O.Bits, Bool, bitlist_1280_d.bits1280_set(P10_O.bits_zeros(40), 40, True{})), (Pair.snd(P10_O.Bits, Bool, bitlist_1280_d.bits1280_set(P10_O.bits_zeros(40), 39, True{})), (Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(Pair.fst(P10_O.Bits, Bool, bitlist_1280_d.bits1280_set(P10_O.bits_zeros(40), 39, True{})), 39)), Pair.snd(P10_O.Bits, Maybe<&1, Bool>, bitlist_1280_d.bits1280_get(Pair.fst(P10_O.Bits, Bool, bitlist_1280_d.bits1280_set(P10_O.bits_zeros(40), 39, True{})), 38))))) == (False{}, (True{}, (Some{True{}}, Some{False{}}))) : Bool & (Bool & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P10_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1280_set_edge()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_first() -> {(Pair.snd(P11_O.Bits, Bool, bitlist_1281_d.bits1281_append(bitlist_1281_d.bits1281_default(), True{})), (Pair.snd(P11_O.Bits, U32, bitlist_1281_d.bits1281_len(P11_PRV.ap(bitlist_1281_d.bits1281_default(), True{}))), (Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(P11_PRV.ap(bitlist_1281_d.bits1281_default(), True{}), 0)), Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(P11_PRV.ap(bitlist_1281_d.bits1281_default(), True{}), 1))))) == (True{}, (1, (Some{True{}}, None{}))) : Bool & (U32 & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P11_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_first()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_order() -> {(Pair.snd(P11_O.Bits, U32, bitlist_1281_d.bits1281_len(P11_PRV.ap(P11_PRV.ap(P11_PRV.ap(bitlist_1281_d.bits1281_default(), True{}), False{}), True{}))), (Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(P11_PRV.ap(P11_PRV.ap(P11_PRV.ap(bitlist_1281_d.bits1281_default(), True{}), False{}), True{}), 0)), (Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(P11_PRV.ap(P11_PRV.ap(P11_PRV.ap(bitlist_1281_d.bits1281_default(), True{}), False{}), True{}), 1)), (Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(P11_PRV.ap(P11_PRV.ap(P11_PRV.ap(bitlist_1281_d.bits1281_default(), True{}), False{}), True{}), 2)), Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(P11_PRV.ap(P11_PRV.ap(P11_PRV.ap(bitlist_1281_d.bits1281_default(), True{}), False{}), True{}), 3)))))) == (3, (Some{True{}}, (Some{False{}}, (Some{True{}}, None{})))) : U32 & (Maybe<&1, Bool> & (Maybe<&1, Bool> & (Maybe<&1, Bool> & Maybe<&1, Bool>)))}:
  P11_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_order()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_full() -> {(Pair.snd(P11_O.Bits, Bool, bitlist_1281_d.bits1281_append(P11_O.bits_zeros(1281), True{})), (Pair.snd(P11_O.Bits, Bool, bitlist_1281_d.bits1281_append(P11_O.bits_zeros(1280), True{})), Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(P11_PRV.ap(P11_O.bits_zeros(1280), True{}), 1280)))) == (False{}, (True{}, Some{True{}})) : Bool & (Bool & Maybe<&1, Bool>)}:
  P11_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_full()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits1281_set_edge() -> {(Pair.snd(P11_O.Bits, Bool, bitlist_1281_d.bits1281_set(P11_O.bits_zeros(40), 40, True{})), (Pair.snd(P11_O.Bits, Bool, bitlist_1281_d.bits1281_set(P11_O.bits_zeros(40), 39, True{})), (Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(Pair.fst(P11_O.Bits, Bool, bitlist_1281_d.bits1281_set(P11_O.bits_zeros(40), 39, True{})), 39)), Pair.snd(P11_O.Bits, Maybe<&1, Bool>, bitlist_1281_d.bits1281_get(Pair.fst(P11_O.Bits, Bool, bitlist_1281_d.bits1281_set(P11_O.bits_zeros(40), 39, True{})), 38))))) == (False{}, (True{}, (Some{True{}}, Some{False{}}))) : Bool & (Bool & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P11_PRV.ProgressiveBitsStruct_serialize_vcoll_bits1281_set_edge()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_first() -> {(Pair.snd(P12_O.Bits, Bool, bitlist_256_d.bits256_append(bitlist_256_d.bits256_default(), True{})), (Pair.snd(P12_O.Bits, U32, bitlist_256_d.bits256_len(P12_PRV.ap(bitlist_256_d.bits256_default(), True{}))), (Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(P12_PRV.ap(bitlist_256_d.bits256_default(), True{}), 0)), Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(P12_PRV.ap(bitlist_256_d.bits256_default(), True{}), 1))))) == (True{}, (1, (Some{True{}}, None{}))) : Bool & (U32 & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P12_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_first()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_order() -> {(Pair.snd(P12_O.Bits, U32, bitlist_256_d.bits256_len(P12_PRV.ap(P12_PRV.ap(P12_PRV.ap(bitlist_256_d.bits256_default(), True{}), False{}), True{}))), (Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(P12_PRV.ap(P12_PRV.ap(P12_PRV.ap(bitlist_256_d.bits256_default(), True{}), False{}), True{}), 0)), (Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(P12_PRV.ap(P12_PRV.ap(P12_PRV.ap(bitlist_256_d.bits256_default(), True{}), False{}), True{}), 1)), (Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(P12_PRV.ap(P12_PRV.ap(P12_PRV.ap(bitlist_256_d.bits256_default(), True{}), False{}), True{}), 2)), Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(P12_PRV.ap(P12_PRV.ap(P12_PRV.ap(bitlist_256_d.bits256_default(), True{}), False{}), True{}), 3)))))) == (3, (Some{True{}}, (Some{False{}}, (Some{True{}}, None{})))) : U32 & (Maybe<&1, Bool> & (Maybe<&1, Bool> & (Maybe<&1, Bool> & Maybe<&1, Bool>)))}:
  P12_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_order()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_full() -> {(Pair.snd(P12_O.Bits, Bool, bitlist_256_d.bits256_append(P12_O.bits_zeros(256), True{})), (Pair.snd(P12_O.Bits, Bool, bitlist_256_d.bits256_append(P12_O.bits_zeros(255), True{})), Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(P12_PRV.ap(P12_O.bits_zeros(255), True{}), 255)))) == (False{}, (True{}, Some{True{}})) : Bool & (Bool & Maybe<&1, Bool>)}:
  P12_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_full()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits256_set_edge() -> {(Pair.snd(P12_O.Bits, Bool, bitlist_256_d.bits256_set(P12_O.bits_zeros(40), 40, True{})), (Pair.snd(P12_O.Bits, Bool, bitlist_256_d.bits256_set(P12_O.bits_zeros(40), 39, True{})), (Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(Pair.fst(P12_O.Bits, Bool, bitlist_256_d.bits256_set(P12_O.bits_zeros(40), 39, True{})), 39)), Pair.snd(P12_O.Bits, Maybe<&1, Bool>, bitlist_256_d.bits256_get(Pair.fst(P12_O.Bits, Bool, bitlist_256_d.bits256_set(P12_O.bits_zeros(40), 39, True{})), 38))))) == (False{}, (True{}, (Some{True{}}, Some{False{}}))) : Bool & (Bool & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P12_PRV.ProgressiveBitsStruct_serialize_vcoll_bits256_set_edge()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_first() -> {(Pair.snd(P13_O.Bits, Bool, bitlist_257_d.bits257_append(bitlist_257_d.bits257_default(), True{})), (Pair.snd(P13_O.Bits, U32, bitlist_257_d.bits257_len(P13_PRV.ap(bitlist_257_d.bits257_default(), True{}))), (Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(P13_PRV.ap(bitlist_257_d.bits257_default(), True{}), 0)), Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(P13_PRV.ap(bitlist_257_d.bits257_default(), True{}), 1))))) == (True{}, (1, (Some{True{}}, None{}))) : Bool & (U32 & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P13_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_first()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_order() -> {(Pair.snd(P13_O.Bits, U32, bitlist_257_d.bits257_len(P13_PRV.ap(P13_PRV.ap(P13_PRV.ap(bitlist_257_d.bits257_default(), True{}), False{}), True{}))), (Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(P13_PRV.ap(P13_PRV.ap(P13_PRV.ap(bitlist_257_d.bits257_default(), True{}), False{}), True{}), 0)), (Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(P13_PRV.ap(P13_PRV.ap(P13_PRV.ap(bitlist_257_d.bits257_default(), True{}), False{}), True{}), 1)), (Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(P13_PRV.ap(P13_PRV.ap(P13_PRV.ap(bitlist_257_d.bits257_default(), True{}), False{}), True{}), 2)), Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(P13_PRV.ap(P13_PRV.ap(P13_PRV.ap(bitlist_257_d.bits257_default(), True{}), False{}), True{}), 3)))))) == (3, (Some{True{}}, (Some{False{}}, (Some{True{}}, None{})))) : U32 & (Maybe<&1, Bool> & (Maybe<&1, Bool> & (Maybe<&1, Bool> & Maybe<&1, Bool>)))}:
  P13_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_order()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_full() -> {(Pair.snd(P13_O.Bits, Bool, bitlist_257_d.bits257_append(P13_O.bits_zeros(257), True{})), (Pair.snd(P13_O.Bits, Bool, bitlist_257_d.bits257_append(P13_O.bits_zeros(256), True{})), Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(P13_PRV.ap(P13_O.bits_zeros(256), True{}), 256)))) == (False{}, (True{}, Some{True{}})) : Bool & (Bool & Maybe<&1, Bool>)}:
  P13_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_full()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_bits257_set_edge() -> {(Pair.snd(P13_O.Bits, Bool, bitlist_257_d.bits257_set(P13_O.bits_zeros(40), 40, True{})), (Pair.snd(P13_O.Bits, Bool, bitlist_257_d.bits257_set(P13_O.bits_zeros(40), 39, True{})), (Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(Pair.fst(P13_O.Bits, Bool, bitlist_257_d.bits257_set(P13_O.bits_zeros(40), 39, True{})), 39)), Pair.snd(P13_O.Bits, Maybe<&1, Bool>, bitlist_257_d.bits257_get(Pair.fst(P13_O.Bits, Bool, bitlist_257_d.bits257_set(P13_O.bits_zeros(40), 39, True{})), 38))))) == (False{}, (True{}, (Some{True{}}, Some{False{}}))) : Bool & (Bool & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P13_PRV.ProgressiveBitsStruct_serialize_vcoll_bits257_set_edge()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_pbits_first() -> {(Pair.snd(P14_O.Bits, Bool, progbitlist_d.pbits_append(progbitlist_d.pbits_default(), True{})), (Pair.snd(P14_O.Bits, U32, progbitlist_d.pbits_len(P14_PRV.ap(progbitlist_d.pbits_default(), True{}))), (Pair.snd(P14_O.Bits, Maybe<&1, Bool>, progbitlist_d.pbits_get(P14_PRV.ap(progbitlist_d.pbits_default(), True{}), 0)), Pair.snd(P14_O.Bits, Maybe<&1, Bool>, progbitlist_d.pbits_get(P14_PRV.ap(progbitlist_d.pbits_default(), True{}), 1))))) == (True{}, (1, (Some{True{}}, None{}))) : Bool & (U32 & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P14_PRV.ProgressiveBitsStruct_serialize_vcoll_pbits_first()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_pbits_order() -> {(Pair.snd(P14_O.Bits, U32, progbitlist_d.pbits_len(P14_PRV.ap(P14_PRV.ap(P14_PRV.ap(progbitlist_d.pbits_default(), True{}), False{}), True{}))), (Pair.snd(P14_O.Bits, Maybe<&1, Bool>, progbitlist_d.pbits_get(P14_PRV.ap(P14_PRV.ap(P14_PRV.ap(progbitlist_d.pbits_default(), True{}), False{}), True{}), 0)), (Pair.snd(P14_O.Bits, Maybe<&1, Bool>, progbitlist_d.pbits_get(P14_PRV.ap(P14_PRV.ap(P14_PRV.ap(progbitlist_d.pbits_default(), True{}), False{}), True{}), 1)), (Pair.snd(P14_O.Bits, Maybe<&1, Bool>, progbitlist_d.pbits_get(P14_PRV.ap(P14_PRV.ap(P14_PRV.ap(progbitlist_d.pbits_default(), True{}), False{}), True{}), 2)), Pair.snd(P14_O.Bits, Maybe<&1, Bool>, progbitlist_d.pbits_get(P14_PRV.ap(P14_PRV.ap(P14_PRV.ap(progbitlist_d.pbits_default(), True{}), False{}), True{}), 3)))))) == (3, (Some{True{}}, (Some{False{}}, (Some{True{}}, None{})))) : U32 & (Maybe<&1, Bool> & (Maybe<&1, Bool> & (Maybe<&1, Bool> & Maybe<&1, Bool>)))}:
  P14_PRV.ProgressiveBitsStruct_serialize_vcoll_pbits_order()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vcoll_pbits_set_edge() -> {(Pair.snd(P14_O.Bits, Bool, progbitlist_d.pbits_set(P14_O.bits_zeros(40), 40, True{})), (Pair.snd(P14_O.Bits, Bool, progbitlist_d.pbits_set(P14_O.bits_zeros(40), 39, True{})), (Pair.snd(P14_O.Bits, Maybe<&1, Bool>, progbitlist_d.pbits_get(Pair.fst(P14_O.Bits, Bool, progbitlist_d.pbits_set(P14_O.bits_zeros(40), 39, True{})), 39)), Pair.snd(P14_O.Bits, Maybe<&1, Bool>, progbitlist_d.pbits_get(Pair.fst(P14_O.Bits, Bool, progbitlist_d.pbits_set(P14_O.bits_zeros(40), 39, True{})), 38))))) == (False{}, (True{}, (Some{True{}}, Some{False{}}))) : Bool & (Bool & (Maybe<&1, Bool> & Maybe<&1, Bool>))}:
  P14_PRV.ProgressiveBitsStruct_serialize_vcoll_pbits_set_edge()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_default_valid() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct_default())) == True{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_default_valid()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vrefuse_bad_flag() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, P15_O.Encoded, ProgressiveBitsStruct_e.ProgressiveBitsStruct_senc_go(True{}, 0, ProgressiveBitsStruct_d.ProgressiveBitsStruct_default())) == P15_O.refused() : P15_O.Encoded}:
  P15_PRV.ProgressiveBitsStruct_serialize_vrefuse_bad_flag()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vrefuse_poisoned_size() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, P15_O.Encoded, ProgressiveBitsStruct_e.ProgressiveBitsStruct_senc_sized((ProgressiveBitsStruct_d.ProgressiveBitsStruct_default(), 4294967295))) == P15_O.refused() : P15_O.Encoded}:
  P15_PRV.ProgressiveBitsStruct_serialize_vrefuse_poisoned_size()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_B() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_set_f_B(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), P15_O.Bits{Array.new(U32, 0n, 0), 64}), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default()})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_B()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_C() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_set_f_C(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), P15_O.Bits{Array.new(U32, 0n, 0), 64}), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default()})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_C()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_E() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_set_f_E(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), P15_O.Bits{Array.new(U32, 0n, 0), 64}), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default()})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_E()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_F() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_set_f_F(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), P15_O.Bits{Array.new(U32, 0n, 0), 64}), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default()})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_F()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_G() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_set_f_G(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), P15_O.Words{Array.new(U32, 0n, 0), 5}), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default()})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_G()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_H() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_set_f_H(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), P15_O.Bits{Array.new(U32, 0n, 0), 64}), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default()})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_H()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_I() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_set_f_I(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default(), P15_O.Bits{Array.new(U32, 0n, 0), 64})})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_I()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_J() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_set_f_J(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default(), P15_O.Words{Array.new(U32, 0n, 0), 5})})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_J()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_K() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_set_f_K(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default(), P15_O.Bits{Array.new(U32, 0n, 0), 64})})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_K()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vreject_f_L() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, Bool, ProgressiveBitsStruct_e.ProgressiveBitsStruct_valid(ProgressiveBitsStruct_d.ProgressiveBitsStruct{ProgressiveBitsStruct_d.ProgressiveBitsStruct_g0_default(), ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_set_f_L(ProgressiveBitsStruct_d.ProgressiveBitsStruct_g1_default(), P15_O.Bits{Array.new(U32, 0n, 0), 64})})) == False{} : Bool}:
  P15_PRV.ProgressiveBitsStruct_serialize_vreject_f_L()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vrefuse_writer_marker() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, P16_O.Encoded, ProgressiveBitsStruct_e.ProgressiveBitsStruct_senc_out(0, Array.new(U32, 0n, 0), ProgressiveBitsStruct_d.ProgressiveBitsStruct_default(), 4294967295)) == P16_O.refused() : P16_O.Encoded}:
  P16_PRV.ProgressiveBitsStruct_serialize_vrefuse_writer_marker()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vrefuse_writer_above() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, P16_O.Encoded, ProgressiveBitsStruct_e.ProgressiveBitsStruct_senc_out(0, Array.new(U32, 0n, 0), ProgressiveBitsStruct_d.ProgressiveBitsStruct_default(), 4294967265)) == P16_O.refused() : P16_O.Encoded}:
  P16_PRV.ProgressiveBitsStruct_serialize_vrefuse_writer_above()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vrefuse_writer_ok() -> {Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, P16_O.Encoded, ProgressiveBitsStruct_e.ProgressiveBitsStruct_senc_out(0, Array.new(U32, 0n, 0), ProgressiveBitsStruct_d.ProgressiveBitsStruct_default(), 0)) == P16_O.Encoded{True{}, P16_B.Buf{Array.new(U32, 0n, 0), 0}} : P16_O.Encoded}:
  P16_PRV.ProgressiveBitsStruct_serialize_vrefuse_writer_ok()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_size_bits1280_storage() -> {(Pair.snd(P17_O.Bits, U32, bitlist_1280_e.bits1280_size(P17_O.Bits{Array.new(U32, 0n, 0), 8})), (Pair.snd(P17_O.Bits, U32, bitlist_1280_e.bits1280_size(P17_O.Bits{Array.new(U32, 0n, 0), 31})), Pair.snd(P17_O.Bits, U32, bitlist_1280_e.bits1280_size(P17_O.Bits{Array.new(U32, 0n, 0), 32})))) == (2, (4, 4294967295)) : U32 & (U32 & U32)}:
  P17_PRV.ProgressiveBitsStruct_serialize_vpoison_size_bits1280_storage()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_size_bits1281_storage() -> {(Pair.snd(P18_O.Bits, U32, bitlist_1281_e.bits1281_size(P18_O.Bits{Array.new(U32, 0n, 0), 8})), (Pair.snd(P18_O.Bits, U32, bitlist_1281_e.bits1281_size(P18_O.Bits{Array.new(U32, 0n, 0), 31})), Pair.snd(P18_O.Bits, U32, bitlist_1281_e.bits1281_size(P18_O.Bits{Array.new(U32, 0n, 0), 32})))) == (2, (4, 4294967295)) : U32 & (U32 & U32)}:
  P18_PRV.ProgressiveBitsStruct_serialize_vpoison_size_bits1281_storage()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_size_bits256_storage() -> {(Pair.snd(P19_O.Bits, U32, bitlist_256_e.bits256_size(P19_O.Bits{Array.new(U32, 0n, 0), 8})), (Pair.snd(P19_O.Bits, U32, bitlist_256_e.bits256_size(P19_O.Bits{Array.new(U32, 0n, 0), 31})), Pair.snd(P19_O.Bits, U32, bitlist_256_e.bits256_size(P19_O.Bits{Array.new(U32, 0n, 0), 32})))) == (2, (4, 4294967295)) : U32 & (U32 & U32)}:
  P19_PRV.ProgressiveBitsStruct_serialize_vpoison_size_bits256_storage()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_size_bits257_storage() -> {(Pair.snd(P20_O.Bits, U32, bitlist_257_e.bits257_size(P20_O.Bits{Array.new(U32, 0n, 0), 8})), (Pair.snd(P20_O.Bits, U32, bitlist_257_e.bits257_size(P20_O.Bits{Array.new(U32, 0n, 0), 31})), Pair.snd(P20_O.Bits, U32, bitlist_257_e.bits257_size(P20_O.Bits{Array.new(U32, 0n, 0), 32})))) == (2, (4, 4294967295)) : U32 & (U32 & U32)}:
  P20_PRV.ProgressiveBitsStruct_serialize_vpoison_size_bits257_storage()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vunit_bv1280_range_below_159() -> {Pair.snd(P21_O.Words, Bool, bitvector_1280_e.bv1280_valid(P21_O.words_new(159))) == False{} : Bool}:
  P21_PRV.ProgressiveBitsStruct_serialize_vunit_bv1280_range_below_159()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vunit_bv1280_range_lo_160() -> {Pair.snd(P21_O.Words, Bool, bitvector_1280_e.bv1280_valid(P21_O.words_new(160))) == True{} : Bool}:
  P21_PRV.ProgressiveBitsStruct_serialize_vunit_bv1280_range_lo_160()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vunit_bv1280_range_above_161() -> {Pair.snd(P21_O.Words, Bool, bitvector_1280_e.bv1280_valid(P21_O.words_new(161))) == False{} : Bool}:
  P21_PRV.ProgressiveBitsStruct_serialize_vunit_bv1280_range_above_161()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_pk_bits1280() -> {P22_O.is_poisoned(Pair.snd(P22_O.Bits, U32, Pair.snd(Array<U32>, P22_O.Bits & U32, bitlist_1280_e.bits1280_pk(Array.new(U32, 0n, 0), 0, (P22_O.Bits{Array.new(U32, 0n, 0), 0}, False{}))))) == True{} : Bool}:
  P22_PRV.ProgressiveBitsStruct_serialize_vpoison_pk_bits1280()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_pk_bits1281() -> {P23_O.is_poisoned(Pair.snd(P23_O.Bits, U32, Pair.snd(Array<U32>, P23_O.Bits & U32, bitlist_1281_e.bits1281_pk(Array.new(U32, 0n, 0), 0, (P23_O.Bits{Array.new(U32, 0n, 0), 0}, False{}))))) == True{} : Bool}:
  P23_PRV.ProgressiveBitsStruct_serialize_vpoison_pk_bits1281()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_pk_bits256() -> {P24_O.is_poisoned(Pair.snd(P24_O.Bits, U32, Pair.snd(Array<U32>, P24_O.Bits & U32, bitlist_256_e.bits256_pk(Array.new(U32, 0n, 0), 0, (P24_O.Bits{Array.new(U32, 0n, 0), 0}, False{}))))) == True{} : Bool}:
  P24_PRV.ProgressiveBitsStruct_serialize_vpoison_pk_bits256()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_pk_bits257() -> {P25_O.is_poisoned(Pair.snd(P25_O.Bits, U32, Pair.snd(Array<U32>, P25_O.Bits & U32, bitlist_257_e.bits257_pk(Array.new(U32, 0n, 0), 0, (P25_O.Bits{Array.new(U32, 0n, 0), 0}, False{}))))) == True{} : Bool}:
  P25_PRV.ProgressiveBitsStruct_serialize_vpoison_pk_bits257()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_pk_bv1280() -> {P26_O.is_poisoned(Pair.snd(P26_O.Words, U32, Pair.snd(Array<U32>, P26_O.Words & U32, bitvector_1280_e.bv1280_pk(Array.new(U32, 0n, 0), 0, (P26_O.words_new(0), False{}))))) == True{} : Bool}:
  P26_PRV.ProgressiveBitsStruct_serialize_vpoison_pk_bv1280()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_serialize_vpoison_pk_bv1281() -> {P27_O.is_poisoned(Pair.snd(P27_O.Words, U32, Pair.snd(Array<U32>, P27_O.Words & U32, bitvector_1281_e.bv1281_pk(Array.new(U32, 0n, 0), 0, (P27_O.words_new(0), False{}))))) == True{} : Bool}:
  P27_PRV.ProgressiveBitsStruct_serialize_vpoison_pk_bv1281()

def ProgressiveBitsStruct__serialize_valid__ProgressiveBitsStruct_mc_ser() -> {ProgressiveBitsStruct_e.ProgressiveBitsStruct_serialize(ProgressiveBitsStruct_d.ProgressiveBitsStruct_set_f_D(ProgressiveBitsStruct_d.ProgressiveBitsStruct_set_f_A(ProgressiveBitsStruct_d.ProgressiveBitsStruct_default(), bitvector_256_d.bv256_seed(2271572670)), bitvector_257_d.bv257_seed(2271572721))) == (Pair.fst(ProgressiveBitsStruct_d.ProgressiveBitsStruct, P28_B.Buf, ProgressiveBitsStruct_e.ProgressiveBitsStruct_encode(ProgressiveBitsStruct_d.ProgressiveBitsStruct_set_f_D(ProgressiveBitsStruct_d.ProgressiveBitsStruct_set_f_A(ProgressiveBitsStruct_d.ProgressiveBitsStruct_default(), bitvector_256_d.bv256_seed(2271572670)), bitvector_257_d.bv257_seed(2271572721)))), P28_O.encoded(Pair.snd(ProgressiveBitsStruct_d.ProgressiveBitsStruct, P28_B.Buf, ProgressiveBitsStruct_e.ProgressiveBitsStruct_encode(ProgressiveBitsStruct_d.ProgressiveBitsStruct_set_f_D(ProgressiveBitsStruct_d.ProgressiveBitsStruct_set_f_A(ProgressiveBitsStruct_d.ProgressiveBitsStruct_default(), bitvector_256_d.bv256_seed(2271572670)), bitvector_257_d.bv257_seed(2271572721)))))) : ProgressiveBitsStruct_d.ProgressiveBitsStruct & P28_O.Encoded}:
  P28_PRV.ProgressiveBitsStruct_mc_ser()

