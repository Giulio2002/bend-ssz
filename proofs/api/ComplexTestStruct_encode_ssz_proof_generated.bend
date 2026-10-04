import Base
import ../../src/obj.bend as P0_O
import ../../src/primitives.bend as P0_I
import ../../types/uint8_def_generated.bend as uint8_d
import ../../types/VarTestStruct_def_generated.bend as VarTestStruct_d
import ../../types/FixedTestStruct_def_generated.bend as FixedTestStruct_d
import ../../types/list_uint16_128_def_generated.bend as list_uint16_128_d
import ../../types/list_uint16_128_encode_ssz_generated.bend as list_uint16_128_e
import ../../types/bytelist_256_def_generated.bend as bytelist_256_d
import ../../types/bytelist_256_encode_ssz_generated.bend as bytelist_256_e
import ../../types/vec_FixedTestStruct_4_def_generated.bend as vec_FixedTestStruct_4_d
import ../../types/vec_FixedTestStruct_4_encode_ssz_generated.bend as vec_FixedTestStruct_4_e
import ../../types/vec_VarTestStruct_2_def_generated.bend as vec_VarTestStruct_2_d
import ../../types/vec_VarTestStruct_2_encode_ssz_generated.bend as vec_VarTestStruct_2_e
import ../../types/ComplexTestStruct_def_generated.bend as ComplexTestStruct_d
import ../../types/ComplexTestStruct_encode_ssz_generated.bend as ComplexTestStruct_e
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
import ../obj/vpiece.bend as P0_VPC
import ../obj/encx_v4_FixedTestStruct_generated.bend as P0_RV_v4_FixedTestStruct
import ../obj/encx_v4_FixedTestStruct_d_generated.bend as P0_RV_v4_FixedTestStruct_D
import ../obj/encx_l128_u16_generated.bend as P0_EX_l128_u16
import ../obj/encx_l128_u16_d_generated.bend as P0_EX_l128_u16_D
import ../obj/encx_bl256_generated.bend as P0_EX_bl256
import ../obj/encx_bl256_d_generated.bend as P0_EX_bl256_D
import ../obj/encx_VarTestStruct_iface_generated.bend as P0_EX_VarTestStruct
import ../obj/encx_v2_VarTestStruct_generated.bend as P0_EX_v2_VarTestStruct
import ../obj/encx_v2_VarTestStruct_d_generated.bend as P0_EX_v2_VarTestStruct_D
import ../obj/vrecb.bend as P0_VRB
import ../obj/vbenc.bend as P0_VBE
import ../../src/buffer.bend as P0_B
import ../../spec/decoding_relation.bend as P0_Decoding
import ../obj/vlist.bend as P0_VL
import ../obj/vdepth.bend as P0_VD
import ../obj/vvlz_generated.bend as P0_VZG
import ../obj/vuwb.bend as P0_UWB
import ../obj/vvle.bend as P0_VE2
import ../obj/encx_ComplexTestStruct_iface_generated.bend as P0_CI
import ../obj/var_codec_ComplexTestStruct_enc_generated.bend as P0_PRV
import ../../src/obj.bend as P1_O
import ../slop/validity/generic_ComplexTestStruct_api_bl256_generated.bend as P1_PRV
import ../../src/obj.bend as P2_O
import ../slop/validity/generic_ComplexTestStruct_api_l128_u16_generated.bend as P2_PRV
import ../../src/obj.bend as P3_O
import ../slop/validity/generic_ComplexTestStruct_api_v2_VarTestStruct_generated.bend as P3_PRV
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_ComplexTestStruct_api_v4_FixedTestStruct_generated.bend as P4_PRV
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_ComplexTestStruct_appb_bl256_generated.bend as P5_PRV
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_ComplexTestStruct_appb_l128_u16_generated.bend as P6_PRV
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_ComplexTestStruct_collection_bl256_generated.bend as P7_PRV
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_ComplexTestStruct_collection_l128_u16_generated.bend as P8_PRV
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_ComplexTestStruct_fields_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_ComplexTestStruct_senc_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_ComplexTestStruct_size_v2_VarTestStruct_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_ComplexTestStruct_size_v4_FixedTestStruct_generated.bend as P12_PRV
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_ComplexTestStruct_unit_bl256_generated.bend as P13_PRV
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_ComplexTestStruct_unit_l128_u16_generated.bend as P14_PRV
import ../../src/obj.bend as P15_O
import ../slop/validity/generic_ComplexTestStruct_vaccess_v2_VarTestStruct_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/digest.bend as P16_D
import ../../src/obj.bend as P16_O
import ../slop/validity/generic_ComplexTestStruct_vrootj1_bl256_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/digest.bend as P17_D
import ../../src/obj.bend as P17_O
import ../slop/validity/generic_ComplexTestStruct_vrootj1_l128_u16_generated.bend as P17_PRV
import ../../src/buffer.bend as P18_B
import ../../src/obj.bend as P18_O
import ../slop/validity/generic_ComplexTestStruct_writer_bl256_generated.bend as P18_PRV
import ../../src/buffer.bend as P19_B
import ../../src/obj.bend as P19_O
import ../slop/validity/generic_ComplexTestStruct_writer_l128_u16_generated.bend as P19_PRV
import ../../src/buffer.bend as P20_B
import ../../src/obj.bend as P20_O
import ../slop/validity/generic_ComplexTestStruct_writer_v2_VarTestStruct_generated.bend as P20_PRV
import ../../src/buffer.bend as P21_B
import ../../src/obj.bend as P21_O
import ../slop/validity/generic_ComplexTestStruct_writer_v4_FixedTestStruct_generated.bend as P21_PRV
import ../../src/buffer.bend as P22_B
import ../../src/obj.bend as P22_O
import ../../src/digest.bend as P22_D
import ../slop/constants/ComplexTestStruct_generated.bend as P22_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# ComplexTestStruct: its encode_ssz laws in the object API's terms, each discharged by its proving law.

def ComplexTestStruct__encode_eval__encode_eval(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> {ComplexTestStruct_e.ComplexTestStruct_encode(P0_CI.TH(m)) == (P0_CI.TH(m), P0_B.Buf{P0_FD.array__thaw(U32, P0_PRV.OUTE(m)), P0_PRV.SZSM(m)}) : ComplexTestStruct_d.ComplexTestStruct & P0_B.Buf}:
  P0_PRV.encode_eval(m, hok)

def ComplexTestStruct__encode_spec__encode_spec(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.ComplexTestStruct(), P0_VS.bt(U32.to_nat(P0_PRV.SZSM(m)), P0_FX.limbs(P0_FD.array__slots(U32, P0_PRV.OUTE(m)))), P0_CI.VAL(m)):
  P0_PRV.encode_spec(m, hok)

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_get() -> {(Pair.snd(P1_O.Words, U32, bytelist_256_d.bl256_len(P1_PRV.obj())), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P1_PRV.obj(), 0)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P1_PRV.obj(), 1)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P1_PRV.obj(), 2)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P1_PRV.obj(), 3)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P1_PRV.obj(), 4)), Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P1_PRV.obj(), 4294967295)))))))) == (3, (Some{255}, (Some{1}, (Some{90}, (None{}, (None{}, None{})))))) : U32 & (Maybe<&1, U32> & (Maybe<&1, U32> & (Maybe<&1, U32> & (Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>)))))}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_get()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_default() -> {(Pair.snd(P1_O.Words, U32, bytelist_256_d.bl256_len(bytelist_256_d.bl256_default())), Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(bytelist_256_d.bl256_default(), 0))) == (0, None{}) : U32 & Maybe<&1, U32>}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_default()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_set_0() -> {(Pair.snd(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 0, 60)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 0, 60)), 0)), (Pair.snd(P1_O.Words, U32, bytelist_256_d.bl256_len(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 0, 60)))), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 0, 60)), 1)), Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 0, 60)), 2)))))) == (True{}, (Some{60}, (3, (Some{1}, Some{90})))) : Bool & (Maybe<&1, U32> & (U32 & (Maybe<&1, U32> & Maybe<&1, U32>)))}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_set_0()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_set_1() -> {(Pair.snd(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 60)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 60)), 1)), (Pair.snd(P1_O.Words, U32, bytelist_256_d.bl256_len(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 60)))), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 60)), 0)), Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 60)), 2)))))) == (True{}, (Some{60}, (3, (Some{255}, Some{90})))) : Bool & (Maybe<&1, U32> & (U32 & (Maybe<&1, U32> & Maybe<&1, U32>)))}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_set_1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_set_2() -> {(Pair.snd(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 2, 60)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 2, 60)), 2)), (Pair.snd(P1_O.Words, U32, bytelist_256_d.bl256_len(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 2, 60)))), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 2, 60)), 0)), Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 2, 60)), 1)))))) == (True{}, (Some{60}, (3, (Some{255}, Some{1})))) : Bool & (Maybe<&1, U32> & (U32 & (Maybe<&1, U32> & Maybe<&1, U32>)))}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_set_2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_set_out() -> {(bytelist_256_d.bl256_set(P1_PRV.obj(), 3, 60), (bytelist_256_d.bl256_set(P1_PRV.obj(), 4, 60), bytelist_256_d.bl256_set(P1_PRV.obj(), 4294967295, 60))) == ((P1_PRV.obj(), False{}), ((P1_PRV.obj(), False{}), (P1_PRV.obj(), False{}))) : (P1_O.Words & Bool) & ((P1_O.Words & Bool) & (P1_O.Words & Bool))}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_set_out()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_range() -> {(bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 256), (bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 4294967295), (Pair.snd(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 255)), Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(P1_PRV.obj(), 1, 255)), 1))))) == ((P1_PRV.obj(), False{}), ((P1_PRV.obj(), False{}), (True{}, Some{255}))) : (P1_O.Words & Bool) & ((P1_O.Words & Bool) & (Bool & Maybe<&1, U32>))}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_range()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_len() -> {(Pair.snd(P1_O.Words, U32, bytelist_256_d.bl256_len(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)))), Pair.snd(P1_O.Words, U32, bytelist_256_d.bl256_len(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_set(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), 0, 1))))) == (1, 1) : U32 & U32}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_len()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_api_append() -> {(Pair.snd(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), (Pair.snd(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), 1)), (Pair.snd(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), 1)), 90)), (Pair.snd(P1_O.Words, U32, bytelist_256_d.bl256_len(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), 1)), 90)))), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), 1)), 90)), 0)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), 1)), 90)), 1)), (Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), 1)), 90)), 2)), Pair.snd(P1_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(Pair.fst(P1_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255)), 1)), 90)), 3))))))))) == (True{}, (True{}, (True{}, (3, (Some{255}, (Some{1}, (Some{90}, None{}))))))) : Bool & (Bool & (Bool & (U32 & (Maybe<&1, U32> & (Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>))))))}:
  P1_PRV.ComplexTestStruct_serialize_vcoll_bl256_api_append()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_get() -> {(Pair.snd(P2_O.Words, U32, list_uint16_128_d.l128_u16_len(P2_PRV.obj())), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P2_PRV.obj(), 0)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P2_PRV.obj(), 1)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P2_PRV.obj(), 2)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P2_PRV.obj(), 3)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P2_PRV.obj(), 4)), Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P2_PRV.obj(), 4294967295)))))))) == (3, (Some{65535}, (Some{1}, (Some{23130}, (None{}, (None{}, None{})))))) : U32 & (Maybe<&1, U32> & (Maybe<&1, U32> & (Maybe<&1, U32> & (Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>)))))}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_get()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_default() -> {(Pair.snd(P2_O.Words, U32, list_uint16_128_d.l128_u16_len(list_uint16_128_d.l128_u16_default())), Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(list_uint16_128_d.l128_u16_default(), 0))) == (0, None{}) : U32 & Maybe<&1, U32>}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_default()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_set_0() -> {(Pair.snd(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 0, 15420)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 0, 15420)), 0)), (Pair.snd(P2_O.Words, U32, list_uint16_128_d.l128_u16_len(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 0, 15420)))), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 0, 15420)), 1)), Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 0, 15420)), 2)))))) == (True{}, (Some{15420}, (3, (Some{1}, Some{23130})))) : Bool & (Maybe<&1, U32> & (U32 & (Maybe<&1, U32> & Maybe<&1, U32>)))}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_set_0()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_set_1() -> {(Pair.snd(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 15420)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 15420)), 1)), (Pair.snd(P2_O.Words, U32, list_uint16_128_d.l128_u16_len(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 15420)))), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 15420)), 0)), Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 15420)), 2)))))) == (True{}, (Some{15420}, (3, (Some{65535}, Some{23130})))) : Bool & (Maybe<&1, U32> & (U32 & (Maybe<&1, U32> & Maybe<&1, U32>)))}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_set_1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_set_2() -> {(Pair.snd(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 2, 15420)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 2, 15420)), 2)), (Pair.snd(P2_O.Words, U32, list_uint16_128_d.l128_u16_len(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 2, 15420)))), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 2, 15420)), 0)), Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 2, 15420)), 1)))))) == (True{}, (Some{15420}, (3, (Some{65535}, Some{1})))) : Bool & (Maybe<&1, U32> & (U32 & (Maybe<&1, U32> & Maybe<&1, U32>)))}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_set_2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_set_out() -> {(list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 3, 15420), (list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 4, 15420), list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 4294967295, 15420))) == ((P2_PRV.obj(), False{}), ((P2_PRV.obj(), False{}), (P2_PRV.obj(), False{}))) : (P2_O.Words & Bool) & ((P2_O.Words & Bool) & (P2_O.Words & Bool))}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_set_out()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_range() -> {(list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 65536), (list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 4294967295), (Pair.snd(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 65535)), Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(P2_PRV.obj(), 1, 65535)), 1))))) == ((P2_PRV.obj(), False{}), ((P2_PRV.obj(), False{}), (True{}, Some{65535}))) : (P2_O.Words & Bool) & ((P2_O.Words & Bool) & (Bool & Maybe<&1, U32>))}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_range()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_len() -> {(Pair.snd(P2_O.Words, U32, list_uint16_128_d.l128_u16_len(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)))), Pair.snd(P2_O.Words, U32, list_uint16_128_d.l128_u16_len(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_set(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), 0, 1))))) == (1, 1) : U32 & U32}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_len()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_api_append() -> {(Pair.snd(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), (Pair.snd(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), 1)), (Pair.snd(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), 1)), 23130)), (Pair.snd(P2_O.Words, U32, list_uint16_128_d.l128_u16_len(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), 1)), 23130)))), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), 1)), 23130)), 0)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), 1)), 23130)), 1)), (Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), 1)), 23130)), 2)), Pair.snd(P2_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(Pair.fst(P2_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535)), 1)), 23130)), 3))))))))) == (True{}, (True{}, (True{}, (3, (Some{65535}, (Some{1}, (Some{23130}, None{}))))))) : Bool & (Bool & (Bool & (U32 & (Maybe<&1, U32> & (Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>))))))}:
  P2_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_api_append()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_get() -> {(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, U32, vec_VarTestStruct_2_d.v2_VarTestStruct_len(P3_PRV.obj())), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(P3_PRV.obj(), 0)), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(P3_PRV.obj(), 1)), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(P3_PRV.obj(), 2)), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(P3_PRV.obj(), 3)), Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(P3_PRV.obj(), 4294967295))))))) == (2, (Some{VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)}, (Some{VarTestStruct_d.VarTestStruct_default()}, (None{}, (None{}, None{}))))) : U32 & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (Maybe<&1, VarTestStruct_d.VarTestStruct> & Maybe<&1, VarTestStruct_d.VarTestStruct>))))}:
  P3_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_get()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_default() -> {(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, U32, vec_VarTestStruct_2_d.v2_VarTestStruct_len(vec_VarTestStruct_2_d.v2_VarTestStruct_default())), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 0)), Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 2)))) == (2, (Some{VarTestStruct_d.VarTestStruct_default()}, None{})) : U32 & (Maybe<&1, VarTestStruct_d.VarTestStruct> & Maybe<&1, VarTestStruct_d.VarTestStruct>)}:
  P3_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_default()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_set_0() -> {(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 0, VarTestStruct_d.VarTestStruct_default())), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 0, VarTestStruct_d.VarTestStruct_default())), 0)), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, U32, vec_VarTestStruct_2_d.v2_VarTestStruct_len(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 0, VarTestStruct_d.VarTestStruct_default())))), Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 0, VarTestStruct_d.VarTestStruct_default())), 1))))) == (True{}, (Some{VarTestStruct_d.VarTestStruct_default()}, (2, Some{VarTestStruct_d.VarTestStruct_default()}))) : Bool & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (U32 & Maybe<&1, VarTestStruct_d.VarTestStruct>))}:
  P3_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_set_0()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_set_1() -> {(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 1, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 1, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 1)), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, U32, vec_VarTestStruct_2_d.v2_VarTestStruct_len(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 1, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 1, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 0))))) == (True{}, (Some{VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)}, (2, Some{VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)}))) : Bool & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (U32 & Maybe<&1, VarTestStruct_d.VarTestStruct>))}:
  P3_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_set_1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_set_out() -> {(vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 2, VarTestStruct_d.VarTestStruct_default()), (vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 3, VarTestStruct_d.VarTestStruct_default()), vec_VarTestStruct_2_d.v2_VarTestStruct_set(P3_PRV.obj(), 4294967295, VarTestStruct_d.VarTestStruct_default()))) == ((P3_PRV.obj(), False{}), ((P3_PRV.obj(), False{}), (P3_PRV.obj(), False{}))) : (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & Bool) & ((vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & Bool) & (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & Bool))}:
  P3_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_api_set_out()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_get() -> {(Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_d.v4_FixedTestStruct_len(P4_PRV.obj())), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(P4_PRV.obj(), 0)), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(P4_PRV.obj(), 1)), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(P4_PRV.obj(), 3)), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(P4_PRV.obj(), 4)), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(P4_PRV.obj(), 5)), Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(P4_PRV.obj(), 4294967295)))))))) == (4, (Some{FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1)}, (Some{FixedTestStruct_d.FixedTestStruct_default()}, (Some{FixedTestStruct_d.FixedTestStruct_default()}, (None{}, (None{}, None{})))))) : U32 & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & Maybe<&1, FixedTestStruct_d.FixedTestStruct>)))))}:
  P4_PRV.ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_get()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_default() -> {(Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_d.v4_FixedTestStruct_len(vec_FixedTestStruct_4_d.v4_FixedTestStruct_default())), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(vec_FixedTestStruct_4_d.v4_FixedTestStruct_default(), 0)), Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(vec_FixedTestStruct_4_d.v4_FixedTestStruct_default(), 4)))) == (4, (Some{FixedTestStruct_d.FixedTestStruct_default()}, None{})) : U32 & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & Maybe<&1, FixedTestStruct_d.FixedTestStruct>)}:
  P4_PRV.ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_default()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_set_0() -> {(Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 0, FixedTestStruct_d.FixedTestStruct_default())), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 0, FixedTestStruct_d.FixedTestStruct_default())), 0)), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_d.v4_FixedTestStruct_len(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 0, FixedTestStruct_d.FixedTestStruct_default())))), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 0, FixedTestStruct_d.FixedTestStruct_default())), 1)), Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 0, FixedTestStruct_d.FixedTestStruct_default())), 3)))))) == (True{}, (Some{FixedTestStruct_d.FixedTestStruct_default()}, (4, (Some{FixedTestStruct_d.FixedTestStruct_default()}, Some{FixedTestStruct_d.FixedTestStruct_default()})))) : Bool & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & (U32 & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & Maybe<&1, FixedTestStruct_d.FixedTestStruct>)))}:
  P4_PRV.ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_set_0()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_set_1() -> {(Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 1, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 1, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), 1)), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_d.v4_FixedTestStruct_len(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 1, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))))), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 1, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), 0)), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 1, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), 2)), Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 1, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), 3))))))) == (True{}, (Some{FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1)}, (4, (Some{FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1)}, (Some{FixedTestStruct_d.FixedTestStruct_default()}, Some{FixedTestStruct_d.FixedTestStruct_default()}))))) : Bool & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & (U32 & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & Maybe<&1, FixedTestStruct_d.FixedTestStruct>))))}:
  P4_PRV.ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_set_1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_set_3() -> {(Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 3, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 3, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), 3)), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_d.v4_FixedTestStruct_len(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 3, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))))), (Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 3, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), 0)), Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Maybe<&1, FixedTestStruct_d.FixedTestStruct>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_get(Pair.fst(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, Bool, vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 3, FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1))), 2)))))) == (True{}, (Some{FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1)}, (4, (Some{FixedTestStruct_d.FixedTestStruct_set_f_A_go(FixedTestStruct_d.FixedTestStruct_default(), 1)}, Some{FixedTestStruct_d.FixedTestStruct_default()})))) : Bool & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & (U32 & (Maybe<&1, FixedTestStruct_d.FixedTestStruct> & Maybe<&1, FixedTestStruct_d.FixedTestStruct>)))}:
  P4_PRV.ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_set_3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_set_out() -> {(vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 4, FixedTestStruct_d.FixedTestStruct_default()), (vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 5, FixedTestStruct_d.FixedTestStruct_default()), vec_FixedTestStruct_4_d.v4_FixedTestStruct_set(P4_PRV.obj(), 4294967295, FixedTestStruct_d.FixedTestStruct_default()))) == ((P4_PRV.obj(), False{}), ((P4_PRV.obj(), False{}), (P4_PRV.obj(), False{}))) : (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & Bool) & ((vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & Bool) & (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & Bool))}:
  P4_PRV.ComplexTestStruct_serialize_vcoll_v4_FixedTestStruct_api_set_out()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_appb_below() -> {Pair.snd(P5_O.Words, Bool, bytelist_256_d.bl256_append(P5_O.Words{Array.new(U32, 7n, 0), 255}, 0)) == True{} : Bool}:
  P5_PRV.ComplexTestStruct_serialize_vcoll_bl256_appb_below()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_appb_at() -> {Pair.snd(P5_O.Words, Bool, bytelist_256_d.bl256_append(P5_O.Words{Array.new(U32, 7n, 0), 256}, 0)) == False{} : Bool}:
  P5_PRV.ComplexTestStruct_serialize_vcoll_bl256_appb_at()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_appb_above() -> {Pair.snd(P5_O.Words, Bool, bytelist_256_d.bl256_append(P5_O.Words{Array.new(U32, 7n, 0), 257}, 0)) == False{} : Bool}:
  P5_PRV.ComplexTestStruct_serialize_vcoll_bl256_appb_above()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_appb_fit() -> {Pair.snd(P5_O.Words, Bool, bytelist_256_d.bl256_append(P5_O.Words{Array.new(U32, 3n, 0), 32}, 0)) == True{} : Bool}:
  P5_PRV.ComplexTestStruct_serialize_vcoll_bl256_appb_fit()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_appb_short() -> {Pair.snd(P5_O.Words, Bool, bytelist_256_d.bl256_append(P5_O.Words{Array.new(U32, 3n, 0), 33}, 0)) == False{} : Bool}:
  P5_PRV.ComplexTestStruct_serialize_vcoll_bl256_appb_short()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_appb_below() -> {Pair.snd(P6_O.Words, Bool, list_uint16_128_d.l128_u16_append(P6_O.Words{Array.new(U32, 7n, 0), 254}, 0)) == True{} : Bool}:
  P6_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_appb_below()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_appb_at() -> {Pair.snd(P6_O.Words, Bool, list_uint16_128_d.l128_u16_append(P6_O.Words{Array.new(U32, 7n, 0), 256}, 0)) == False{} : Bool}:
  P6_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_appb_at()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_appb_above() -> {Pair.snd(P6_O.Words, Bool, list_uint16_128_d.l128_u16_append(P6_O.Words{Array.new(U32, 7n, 0), 258}, 0)) == False{} : Bool}:
  P6_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_appb_above()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_appb_fit() -> {Pair.snd(P6_O.Words, Bool, list_uint16_128_d.l128_u16_append(P6_O.Words{Array.new(U32, 3n, 0), 32}, 0)) == True{} : Bool}:
  P6_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_appb_fit()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_appb_short() -> {Pair.snd(P6_O.Words, Bool, list_uint16_128_d.l128_u16_append(P6_O.Words{Array.new(U32, 3n, 0), 34}, 0)) == False{} : Bool}:
  P6_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_appb_short()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_len_get() -> {(Pair.snd(P7_O.Words, U32, bytelist_256_d.bl256_len(P7_PRV.ap(P7_PRV.ap(bytelist_256_d.bl256_default(), 255), 1))), (Pair.snd(P7_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P7_PRV.ap(P7_PRV.ap(bytelist_256_d.bl256_default(), 255), 1), 0)), (Pair.snd(P7_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P7_PRV.ap(P7_PRV.ap(bytelist_256_d.bl256_default(), 255), 1), 1)), Pair.snd(P7_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P7_PRV.ap(P7_PRV.ap(bytelist_256_d.bl256_default(), 255), 1), 2))))) == (2, (Some{255}, (Some{1}, None{}))) : U32 & (Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>))}:
  P7_PRV.ComplexTestStruct_serialize_vcoll_bl256_len_get()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_get_edge() -> {(Pair.snd(P7_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P7_O.words_new(3), 2)), (Pair.snd(P7_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(P7_O.words_new(3), 3)), Pair.snd(P7_O.Words, U32, bytelist_256_d.bl256_len(P7_O.words_new(3))))) == (Some{0}, (None{}, 3)) : Maybe<&1, U32> & (Maybe<&1, U32> & U32)}:
  P7_PRV.ComplexTestStruct_serialize_vcoll_bl256_get_edge()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_append_range() -> {(Pair.snd(P7_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 256)), Pair.snd(P7_O.Words, Bool, bytelist_256_d.bl256_append(bytelist_256_d.bl256_default(), 255))) == (False{}, True{}) : Bool & Bool}:
  P7_PRV.ComplexTestStruct_serialize_vcoll_bl256_append_range()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_append_full() -> {(Pair.snd(P7_O.Words, Bool, bytelist_256_d.bl256_append(P7_O.words_new(256), 0)), (Pair.snd(P7_O.Words, Bool, bytelist_256_d.bl256_append(P7_O.words_new(255), 0)), Pair.snd(P7_O.Words, U32, bytelist_256_d.bl256_len(P7_PRV.ap(P7_O.words_new(255), 0))))) == (False{}, (True{}, 256)) : Bool & (Bool & U32)}:
  P7_PRV.ComplexTestStruct_serialize_vcoll_bl256_append_full()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_set_edge() -> {(Pair.snd(P7_O.Words, Bool, bytelist_256_d.bl256_set(P7_O.words_new(3), 3, 0)), (Pair.snd(P7_O.Words, Bool, bytelist_256_d.bl256_set(P7_O.words_new(3), 2, 0)), Pair.snd(P7_O.Words, Bool, bytelist_256_d.bl256_set(P7_O.words_new(3), 1, 256)))) == (False{}, (True{}, False{})) : Bool & (Bool & Bool)}:
  P7_PRV.ComplexTestStruct_serialize_vcoll_bl256_set_edge()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_set_write() -> {(Pair.snd(P7_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P7_O.Words, Bool, bytelist_256_d.bl256_set(P7_O.words_new(3), 1, 255)), 0)), (Pair.snd(P7_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P7_O.Words, Bool, bytelist_256_d.bl256_set(P7_O.words_new(3), 1, 255)), 1)), Pair.snd(P7_O.Words, Maybe<&1, U32>, bytelist_256_d.bl256_get(Pair.fst(P7_O.Words, Bool, bytelist_256_d.bl256_set(P7_O.words_new(3), 1, 255)), 2)))) == (Some{0}, (Some{255}, Some{0})) : Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>)}:
  P7_PRV.ComplexTestStruct_serialize_vcoll_bl256_set_write()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_bl256_append_clear() -> {(Pair.snd(P7_O.Words, Bool, bytelist_256_d.bl256_append(P7_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), (Pair.snd(P7_O.Words, U32, P7_O.words_word(Pair.fst(P7_O.Words, Bool, bytelist_256_d.bl256_append(P7_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), 1)), Pair.snd(P7_O.Words, U32, P7_O.words_word(Pair.fst(P7_O.Words, Bool, bytelist_256_d.bl256_append(P7_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), 0)))) == (True{}, (1, 0)) : Bool & (U32 & U32)}:
  P7_PRV.ComplexTestStruct_serialize_vcoll_bl256_append_clear()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_len_get() -> {(Pair.snd(P8_O.Words, U32, list_uint16_128_d.l128_u16_len(P8_PRV.ap(P8_PRV.ap(list_uint16_128_d.l128_u16_default(), 65535), 1))), (Pair.snd(P8_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P8_PRV.ap(P8_PRV.ap(list_uint16_128_d.l128_u16_default(), 65535), 1), 0)), (Pair.snd(P8_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P8_PRV.ap(P8_PRV.ap(list_uint16_128_d.l128_u16_default(), 65535), 1), 1)), Pair.snd(P8_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P8_PRV.ap(P8_PRV.ap(list_uint16_128_d.l128_u16_default(), 65535), 1), 2))))) == (2, (Some{65535}, (Some{1}, None{}))) : U32 & (Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>))}:
  P8_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_len_get()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_get_edge() -> {(Pair.snd(P8_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P8_O.words_new(6), 2)), (Pair.snd(P8_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(P8_O.words_new(6), 3)), Pair.snd(P8_O.Words, U32, list_uint16_128_d.l128_u16_len(P8_O.words_new(6))))) == (Some{0}, (None{}, 3)) : Maybe<&1, U32> & (Maybe<&1, U32> & U32)}:
  P8_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_get_edge()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_append_range() -> {(Pair.snd(P8_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65536)), Pair.snd(P8_O.Words, Bool, list_uint16_128_d.l128_u16_append(list_uint16_128_d.l128_u16_default(), 65535))) == (False{}, True{}) : Bool & Bool}:
  P8_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_append_range()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_append_full() -> {(Pair.snd(P8_O.Words, Bool, list_uint16_128_d.l128_u16_append(P8_O.words_new(256), 0)), (Pair.snd(P8_O.Words, Bool, list_uint16_128_d.l128_u16_append(P8_O.words_new(254), 0)), Pair.snd(P8_O.Words, U32, list_uint16_128_d.l128_u16_len(P8_PRV.ap(P8_O.words_new(254), 0))))) == (False{}, (True{}, 128)) : Bool & (Bool & U32)}:
  P8_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_append_full()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_set_edge() -> {(Pair.snd(P8_O.Words, Bool, list_uint16_128_d.l128_u16_set(P8_O.words_new(6), 3, 0)), (Pair.snd(P8_O.Words, Bool, list_uint16_128_d.l128_u16_set(P8_O.words_new(6), 2, 0)), Pair.snd(P8_O.Words, Bool, list_uint16_128_d.l128_u16_set(P8_O.words_new(6), 1, 65536)))) == (False{}, (True{}, False{})) : Bool & (Bool & Bool)}:
  P8_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_set_edge()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_set_write() -> {(Pair.snd(P8_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P8_O.Words, Bool, list_uint16_128_d.l128_u16_set(P8_O.words_new(6), 1, 65535)), 0)), (Pair.snd(P8_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P8_O.Words, Bool, list_uint16_128_d.l128_u16_set(P8_O.words_new(6), 1, 65535)), 1)), Pair.snd(P8_O.Words, Maybe<&1, U32>, list_uint16_128_d.l128_u16_get(Pair.fst(P8_O.Words, Bool, list_uint16_128_d.l128_u16_set(P8_O.words_new(6), 1, 65535)), 2)))) == (Some{0}, (Some{65535}, Some{0})) : Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>)}:
  P8_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_set_write()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_l128_u16_append_clear() -> {(Pair.snd(P8_O.Words, Bool, list_uint16_128_d.l128_u16_append(P8_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), (Pair.snd(P8_O.Words, U32, P8_O.words_word(Pair.fst(P8_O.Words, Bool, list_uint16_128_d.l128_u16_append(P8_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), 1)), Pair.snd(P8_O.Words, U32, P8_O.words_word(Pair.fst(P8_O.Words, Bool, list_uint16_128_d.l128_u16_append(P8_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), 0)))) == (True{}, (1, 0)) : Bool & (U32 & U32)}:
  P8_PRV.ComplexTestStruct_serialize_vcoll_l128_u16_append_clear()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_false_flag() -> {P9_O.is_poisoned(P9_O.pz(False{})) == True{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vpoison_false_flag()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_true_flag() -> {P9_O.is_poisoned(P9_O.pz(True{})) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vpoison_true_flag()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_below() -> {P9_O.is_poisoned(4294967264) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vpoison_below()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_carried() -> {P9_O.is_poisoned(P9_O.padd(5, 4294967295)) == True{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vpoison_carried()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_f_A() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_set_f_A_go(ComplexTestStruct_d.ComplexTestStruct_default(), 65536))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_f_A()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_f_A() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P9_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_A_go(ComplexTestStruct_d.ComplexTestStruct_default(), 65536))) == P9_O.refused() : P9_O.Encoded}:
  P9_PRV.ComplexTestStruct_serialize_vrefuse_f_A()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_f_C() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_set_f_C_go(ComplexTestStruct_d.ComplexTestStruct_default(), 256))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_f_C()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_f_C() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P9_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_C_go(ComplexTestStruct_d.ComplexTestStruct_default(), 256))) == P9_O.refused() : P9_O.Encoded}:
  P9_PRV.ComplexTestStruct_serialize_vrefuse_f_C()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_default_valid() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_default())) == True{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_default_valid()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_bad_flag() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P9_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_senc_go(True{}, 0, ComplexTestStruct_d.ComplexTestStruct_default())) == P9_O.refused() : P9_O.Encoded}:
  P9_PRV.ComplexTestStruct_serialize_vrefuse_bad_flag()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_poisoned_size() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P9_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_senc_sized((ComplexTestStruct_d.ComplexTestStruct_default(), 4294967295))) == P9_O.refused() : P9_O.Encoded}:
  P9_PRV.ComplexTestStruct_serialize_vrefuse_poisoned_size()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_f_B() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_set_f_B(ComplexTestStruct_d.ComplexTestStruct_default(), P9_O.Words{Array.new(U32, 0n, 0), 5}))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_f_B()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_f_D() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_set_f_D(ComplexTestStruct_d.ComplexTestStruct_default(), P9_O.Words{Array.new(U32, 0n, 0), 5}))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_f_D()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_f_E_f_B() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_set_f_E(ComplexTestStruct_d.ComplexTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_B(VarTestStruct_d.VarTestStruct_default(), P9_O.Words{Array.new(U32, 0n, 0), 5})))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_f_E_f_B()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_f_E_f_B() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P9_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_E(ComplexTestStruct_d.ComplexTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_B(VarTestStruct_d.VarTestStruct_default(), P9_O.Words{Array.new(U32, 0n, 0), 5})))) == P9_O.refused() : P9_O.Encoded}:
  P9_PRV.ComplexTestStruct_serialize_vrefuse_f_E_f_B()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_f_F() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_set_f_F(ComplexTestStruct_d.ComplexTestStruct_default(), vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{vec_FixedTestStruct_4_d.v4_FixedTestStruct_fill(0n), 2}))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_f_F()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_f_G() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_set_f_G(ComplexTestStruct_d.ComplexTestStruct_default(), vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{vec_VarTestStruct_2_d.v2_VarTestStruct_fill(0n), 2}))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_f_G()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_f_G_elem() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, Bool, ComplexTestStruct_e.ComplexTestStruct_valid(ComplexTestStruct_d.ComplexTestStruct_set_f_G(ComplexTestStruct_d.ComplexTestStruct_default(), vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{vec_VarTestStruct_2_d.v2_VarTestStruct_fill(0n), 1}))) == False{} : Bool}:
  P9_PRV.ComplexTestStruct_serialize_vreject_f_G_elem()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_writer_marker() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P10_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_senc_out(0, Array.new(U32, 0n, 0), ComplexTestStruct_d.ComplexTestStruct_default(), 4294967295)) == P10_O.refused() : P10_O.Encoded}:
  P10_PRV.ComplexTestStruct_serialize_vrefuse_writer_marker()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_writer_above() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P10_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_senc_out(0, Array.new(U32, 0n, 0), ComplexTestStruct_d.ComplexTestStruct_default(), 4294967265)) == P10_O.refused() : P10_O.Encoded}:
  P10_PRV.ComplexTestStruct_serialize_vrefuse_writer_above()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_writer_ok() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P10_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_senc_out(0, Array.new(U32, 0n, 0), ComplexTestStruct_d.ComplexTestStruct_default(), 0)) == P10_O.Encoded{True{}, P10_B.Buf{Array.new(U32, 0n, 0), 0}} : P10_O.Encoded}:
  P10_PRV.ComplexTestStruct_serialize_vrefuse_writer_ok()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_size_v2_VarTestStruct_offsets() -> {(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, U32, vec_VarTestStruct_2_e.v2_VarTestStruct_size(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{vec_VarTestStruct_2_d.v2_VarTestStruct_fill(0n), 1})), Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, U32, vec_VarTestStruct_2_e.v2_VarTestStruct_size(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{vec_VarTestStruct_2_d.v2_VarTestStruct_fill(1n), 2}))) == (4, 8) : U32 & U32}:
  P11_PRV.ComplexTestStruct_serialize_vpoison_size_v2_VarTestStruct_offsets()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_size_v4_FixedTestStruct_storage_short() -> {Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_e.v4_FixedTestStruct_size(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{vec_FixedTestStruct_4_d.v4_FixedTestStruct_fill(1n), 3})) == 4294967295 : U32}:
  P12_PRV.ComplexTestStruct_serialize_vpoison_size_v4_FixedTestStruct_storage_short()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_size_v4_FixedTestStruct_storage_tight() -> {Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_e.v4_FixedTestStruct_size(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{vec_FixedTestStruct_4_d.v4_FixedTestStruct_fill(1n), 2})) == 26 : U32}:
  P12_PRV.ComplexTestStruct_serialize_vpoison_size_v4_FixedTestStruct_storage_tight()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_size_v4_FixedTestStruct_above() -> {Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_e.v4_FixedTestStruct_size(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{vec_FixedTestStruct_4_d.v4_FixedTestStruct_fill(29n), 330382098})) == 4294967295 : U32}:
  P12_PRV.ComplexTestStruct_serialize_vpoison_size_v4_FixedTestStruct_above()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_size_v4_FixedTestStruct_at() -> {Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, vec_FixedTestStruct_4_e.v4_FixedTestStruct_size(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{vec_FixedTestStruct_4_d.v4_FixedTestStruct_fill(29n), 330382097})) == 4294967261 : U32}:
  P12_PRV.ComplexTestStruct_serialize_vpoison_size_v4_FixedTestStruct_at()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_bl256_range_lo_0() -> {Pair.snd(P13_O.Words, Bool, bytelist_256_e.bl256_valid(P13_O.words_new(0))) == True{} : Bool}:
  P13_PRV.ComplexTestStruct_serialize_vunit_bl256_range_lo_0()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_bl256_range_hi_256() -> {Pair.snd(P13_O.Words, Bool, bytelist_256_e.bl256_valid(P13_O.words_new(256))) == True{} : Bool}:
  P13_PRV.ComplexTestStruct_serialize_vunit_bl256_range_hi_256()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_bl256_range_above_257() -> {Pair.snd(P13_O.Words, Bool, bytelist_256_e.bl256_valid(P13_O.words_new(257))) == False{} : Bool}:
  P13_PRV.ComplexTestStruct_serialize_vunit_bl256_range_above_257()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_l128_u16_refuse_1() -> {Pair.snd(P14_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P14_O.words_new(1))) == False{} : Bool}:
  P14_PRV.ComplexTestStruct_serialize_vunit_l128_u16_refuse_1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_l128_u16_refuse_3() -> {Pair.snd(P14_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P14_O.words_new(3))) == False{} : Bool}:
  P14_PRV.ComplexTestStruct_serialize_vunit_l128_u16_refuse_3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_l128_u16_accept_2() -> {Pair.snd(P14_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P14_O.words_new(2))) == True{} : Bool}:
  P14_PRV.ComplexTestStruct_serialize_vunit_l128_u16_accept_2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_l128_u16_accept_4() -> {Pair.snd(P14_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P14_O.words_new(4))) == True{} : Bool}:
  P14_PRV.ComplexTestStruct_serialize_vunit_l128_u16_accept_4()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_l128_u16_range_lo_0() -> {Pair.snd(P14_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P14_O.words_new(0))) == True{} : Bool}:
  P14_PRV.ComplexTestStruct_serialize_vunit_l128_u16_range_lo_0()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_l128_u16_range_hi_256() -> {Pair.snd(P14_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P14_O.words_new(256))) == True{} : Bool}:
  P14_PRV.ComplexTestStruct_serialize_vunit_l128_u16_range_hi_256()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vunit_l128_u16_range_above_258() -> {Pair.snd(P14_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P14_O.words_new(258))) == False{} : Bool}:
  P14_PRV.ComplexTestStruct_serialize_vunit_l128_u16_range_above_258()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_read_set_0() -> {(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 0, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 0, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 0))) == (True{}, Some{VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)}) : Bool & Maybe<&1, VarTestStruct_d.VarTestStruct>}:
  P15_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_read_set_0()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_other_set_0() -> {Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 0, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 1)) == Some{VarTestStruct_d.VarTestStruct_default()} : Maybe<&1, VarTestStruct_d.VarTestStruct>}:
  P15_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_other_set_0()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_read_set_1() -> {(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 1, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 1, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 1))) == (True{}, Some{VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)}) : Bool & Maybe<&1, VarTestStruct_d.VarTestStruct>}:
  P15_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_read_set_1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_other_set_1() -> {Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 1, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 0)) == Some{VarTestStruct_d.VarTestStruct_default()} : Maybe<&1, VarTestStruct_d.VarTestStruct>}:
  P15_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_other_set_1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_out_of_range() -> {(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 2, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 2, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 0)), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Bool, vec_VarTestStruct_2_d.v2_VarTestStruct_set(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 2, VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 1)), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 2)), (Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 2)), 0)), Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(Pair.fst(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, vec_VarTestStruct_2_d.v2_VarTestStruct_take(vec_VarTestStruct_2_d.v2_VarTestStruct_default(), 2)), 1))))))) == (False{}, (Some{VarTestStruct_d.VarTestStruct_default()}, (Some{VarTestStruct_d.VarTestStruct_default()}, (None{}, (Some{VarTestStruct_d.VarTestStruct_default()}, Some{VarTestStruct_d.VarTestStruct_default()}))))) : Bool & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (Maybe<&1, VarTestStruct_d.VarTestStruct> & Maybe<&1, VarTestStruct_d.VarTestStruct>))))}:
  P15_PRV.ComplexTestStruct_serialize_vcoll_v2_VarTestStruct_out_of_range()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_j1_bl256_n1_b1() -> {Pair.snd(P16_O.Words, Bool, bytelist_256_e.bl256_valid(P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 48641), 1})) == False{} : Bool}:
  P16_PRV.ComplexTestStruct_serialize_vreject_j1_bl256_n1_b1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_j1_bl256_n1_b1() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P16_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_D(ComplexTestStruct_d.ComplexTestStruct_default(), P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 48641), 1}))) == P16_O.refused() : P16_O.Encoded}:
  P16_PRV.ComplexTestStruct_serialize_vrefuse_j1_bl256_n1_b1()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_j1_bl256_n1_b2() -> {Pair.snd(P16_O.Words, Bool, bytelist_256_e.bl256_valid(P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 12451841), 1})) == False{} : Bool}:
  P16_PRV.ComplexTestStruct_serialize_vreject_j1_bl256_n1_b2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_j1_bl256_n1_b2() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P16_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_D(ComplexTestStruct_d.ComplexTestStruct_default(), P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 12451841), 1}))) == P16_O.refused() : P16_O.Encoded}:
  P16_PRV.ComplexTestStruct_serialize_vrefuse_j1_bl256_n1_b2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_j1_bl256_n1_b3() -> {Pair.snd(P16_O.Words, Bool, bytelist_256_e.bl256_valid(P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187671041), 1})) == False{} : Bool}:
  P16_PRV.ComplexTestStruct_serialize_vreject_j1_bl256_n1_b3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_j1_bl256_n1_b3() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P16_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_D(ComplexTestStruct_d.ComplexTestStruct_default(), P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187671041), 1}))) == P16_O.refused() : P16_O.Encoded}:
  P16_PRV.ComplexTestStruct_serialize_vrefuse_j1_bl256_n1_b3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_j1_bl256_n2_b2() -> {Pair.snd(P16_O.Words, Bool, bytelist_256_e.bl256_valid(P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 12452353), 2})) == False{} : Bool}:
  P16_PRV.ComplexTestStruct_serialize_vreject_j1_bl256_n2_b2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_j1_bl256_n2_b2() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P16_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_D(ComplexTestStruct_d.ComplexTestStruct_default(), P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 12452353), 2}))) == P16_O.refused() : P16_O.Encoded}:
  P16_PRV.ComplexTestStruct_serialize_vrefuse_j1_bl256_n2_b2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_j1_bl256_n2_b3() -> {Pair.snd(P16_O.Words, Bool, bytelist_256_e.bl256_valid(P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187671553), 2})) == False{} : Bool}:
  P16_PRV.ComplexTestStruct_serialize_vreject_j1_bl256_n2_b3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_j1_bl256_n2_b3() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P16_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_D(ComplexTestStruct_d.ComplexTestStruct_default(), P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187671553), 2}))) == P16_O.refused() : P16_O.Encoded}:
  P16_PRV.ComplexTestStruct_serialize_vrefuse_j1_bl256_n2_b3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_j1_bl256_n3_b3() -> {Pair.snd(P16_O.Words, Bool, bytelist_256_e.bl256_valid(P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187868161), 3})) == False{} : Bool}:
  P16_PRV.ComplexTestStruct_serialize_vreject_j1_bl256_n3_b3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_j1_bl256_n3_b3() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P16_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_D(ComplexTestStruct_d.ComplexTestStruct_default(), P16_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187868161), 3}))) == P16_O.refused() : P16_O.Encoded}:
  P16_PRV.ComplexTestStruct_serialize_vrefuse_j1_bl256_n3_b3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_j1_l128_u16_n2_b2() -> {Pair.snd(P17_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P17_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 12452353), 2})) == False{} : Bool}:
  P17_PRV.ComplexTestStruct_serialize_vreject_j1_l128_u16_n2_b2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_j1_l128_u16_n2_b2() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P17_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_B(ComplexTestStruct_d.ComplexTestStruct_default(), P17_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 12452353), 2}))) == P17_O.refused() : P17_O.Encoded}:
  P17_PRV.ComplexTestStruct_serialize_vrefuse_j1_l128_u16_n2_b2()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vreject_j1_l128_u16_n2_b3() -> {Pair.snd(P17_O.Words, Bool, list_uint16_128_e.l128_u16_valid(P17_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187671553), 2})) == False{} : Bool}:
  P17_PRV.ComplexTestStruct_serialize_vreject_j1_l128_u16_n2_b3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vrefuse_j1_l128_u16_n2_b3() -> {Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P17_O.Encoded, ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_B(ComplexTestStruct_d.ComplexTestStruct_default(), P17_O.Words{Array.set(U32, Array.new(U32, 3n, 0), 0, 3187671553), 2}))) == P17_O.refused() : P17_O.Encoded}:
  P17_PRV.ComplexTestStruct_serialize_vrefuse_j1_l128_u16_n2_b3()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_pk_bl256() -> {P18_O.is_poisoned(Pair.snd(P18_O.Words, U32, Pair.snd(Array<U32>, P18_O.Words & U32, bytelist_256_e.bl256_pk(Array.new(U32, 0n, 0), 0, (P18_O.words_new(0), False{}))))) == True{} : Bool}:
  P18_PRV.ComplexTestStruct_serialize_vpoison_pk_bl256()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_pk_l128_u16() -> {P19_O.is_poisoned(Pair.snd(P19_O.Words, U32, Pair.snd(Array<U32>, P19_O.Words & U32, list_uint16_128_e.l128_u16_pk(Array.new(U32, 0n, 0), 0, (P19_O.words_new(0), False{}))))) == True{} : Bool}:
  P19_PRV.ComplexTestStruct_serialize_vpoison_pk_l128_u16()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_pk_v2_VarTestStruct() -> {P20_O.is_poisoned(Pair.snd(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, U32, Pair.snd(Array<U32>, vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & U32, vec_VarTestStruct_2_e.v2_VarTestStruct_pk(Array.new(U32, 0n, 0), 0, (vec_VarTestStruct_2_d.v2_VarTestStruct_default(), False{}))))) == True{} : Bool}:
  P20_PRV.ComplexTestStruct_serialize_vpoison_pk_v2_VarTestStruct()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_serialize_vpoison_pk_v4_FixedTestStruct() -> {P21_O.is_poisoned(Pair.snd(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, Pair.snd(Array<U32>, vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & U32, vec_FixedTestStruct_4_e.v4_FixedTestStruct_pk(Array.new(U32, 0n, 0), 0, (vec_FixedTestStruct_4_d.v4_FixedTestStruct_default(), False{}))))) == True{} : Bool}:
  P21_PRV.ComplexTestStruct_serialize_vpoison_pk_v4_FixedTestStruct()

def ComplexTestStruct__serialize_valid__ComplexTestStruct_mc_ser() -> {ComplexTestStruct_e.ComplexTestStruct_serialize(ComplexTestStruct_d.ComplexTestStruct_set_f_C_go(ComplexTestStruct_d.ComplexTestStruct_set_f_A_go(ComplexTestStruct_d.ComplexTestStruct_default(), uint8_d.u8_seed(2271568267)), uint8_d.u8_seed(2271568318))) == (Pair.fst(ComplexTestStruct_d.ComplexTestStruct, P22_B.Buf, ComplexTestStruct_e.ComplexTestStruct_encode(ComplexTestStruct_d.ComplexTestStruct_set_f_C_go(ComplexTestStruct_d.ComplexTestStruct_set_f_A_go(ComplexTestStruct_d.ComplexTestStruct_default(), uint8_d.u8_seed(2271568267)), uint8_d.u8_seed(2271568318)))), P22_O.encoded(Pair.snd(ComplexTestStruct_d.ComplexTestStruct, P22_B.Buf, ComplexTestStruct_e.ComplexTestStruct_encode(ComplexTestStruct_d.ComplexTestStruct_set_f_C_go(ComplexTestStruct_d.ComplexTestStruct_set_f_A_go(ComplexTestStruct_d.ComplexTestStruct_default(), uint8_d.u8_seed(2271568267)), uint8_d.u8_seed(2271568318)))))) : ComplexTestStruct_d.ComplexTestStruct & P22_O.Encoded}:
  P22_PRV.ComplexTestStruct_mc_ser()

