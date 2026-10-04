import Base
import ../../src/obj.bend as P0_O
import ../../src/primitives.bend as P0_I
import ../../types/proglist_uint64_def_generated.bend as proglist_uint64_d
import ../../types/proglist_uint64_encode_ssz_generated.bend as proglist_uint64_e
import ../../types/SmallTestStruct_def_generated.bend as SmallTestStruct_d
import ../../types/proglist_SmallTestStruct_def_generated.bend as proglist_SmallTestStruct_d
import ../../types/proglist_SmallTestStruct_encode_ssz_generated.bend as proglist_SmallTestStruct_e
import ../../types/VarTestStruct_def_generated.bend as VarTestStruct_d
import ../../types/proglist_VarTestStruct_def_generated.bend as proglist_VarTestStruct_d
import ../../types/proglist_VarTestStruct_encode_ssz_generated.bend as proglist_VarTestStruct_e
import ../../types/proglist_proglist_VarTestStruct_def_generated.bend as proglist_proglist_VarTestStruct_d
import ../../types/proglist_proglist_VarTestStruct_encode_ssz_generated.bend as proglist_proglist_VarTestStruct_e
import ../../types/proglist_uint8_def_generated.bend as proglist_uint8_d
import ../../types/ProgressiveTestStruct_def_generated.bend as ProgressiveTestStruct_d
import ../../types/ProgressiveTestStruct_encode_ssz_generated.bend as ProgressiveTestStruct_e
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
import ../obj/encx_pl_u8_generated.bend as P0_EX_pl_u8
import ../obj/encx_pl_u8_d_generated.bend as P0_EX_pl_u8_D
import ../obj/encx_pl_u64_generated.bend as P0_EX_pl_u64
import ../obj/encx_pl_u64_d_generated.bend as P0_EX_pl_u64_D
import ../obj/encx_pl_SmallTestStruct_generated.bend as P0_EX_pl_SmallTestStruct
import ../obj/encx_pl_SmallTestStruct_d_generated.bend as P0_EX_pl_SmallTestStruct_D
import ../obj/encx_pl_pl_VarTestStruct_generated.bend as P0_EX_pl_pl_VarTestStruct
import ../obj/encx_pl_pl_VarTestStruct_d_generated.bend as P0_EX_pl_pl_VarTestStruct_D
import ../obj/vbenc.bend as P0_VBE
import ../../src/buffer.bend as P0_B
import ../../spec/decoding_relation.bend as P0_Decoding
import ../obj/vlist.bend as P0_VL
import ../obj/vdepth.bend as P0_VD
import ../obj/vvlz_generated.bend as P0_VZG
import ../obj/vuwb.bend as P0_UWB
import ../obj/vvle.bend as P0_VE2
import ../obj/encx_ProgressiveTestStruct_iface_generated.bend as P0_CI
import ../obj/var_codec_ProgressiveTestStruct_enc_generated.bend as P0_PRV
import ../../src/obj.bend as P1_O
import ../slop/validity/generic_ProgressiveTestStruct_access_pl_SmallTestStruct_generated.bend as P1_PRV
import ../../src/obj.bend as P2_O
import ../slop/validity/generic_ProgressiveTestStruct_access_pl_VarTestStruct_generated.bend as P2_PRV
import ../../src/obj.bend as P3_O
import ../slop/validity/generic_ProgressiveTestStruct_access_pl_pl_VarTestStruct_generated.bend as P3_PRV
import ../../src/obj.bend as P4_O
import ../slop/validity/generic_ProgressiveTestStruct_appb_pl_SmallTestStruct_generated.bend as P4_PRV
import ../../src/obj.bend as P5_O
import ../slop/validity/generic_ProgressiveTestStruct_appb_pl_u64_generated.bend as P5_PRV
import ../../src/obj.bend as P6_O
import ../slop/validity/generic_ProgressiveTestStruct_appb_pl_u8_generated.bend as P6_PRV
import ../../src/obj.bend as P7_O
import ../slop/validity/generic_ProgressiveTestStruct_collection_pl_u8_generated.bend as P7_PRV
import ../../src/obj.bend as P8_O
import ../slop/validity/generic_ProgressiveTestStruct_fields_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/generic_ProgressiveTestStruct_senc_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/generic_ProgressiveTestStruct_size_pl_SmallTestStruct_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/generic_ProgressiveTestStruct_size_pl_VarTestStruct_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/generic_ProgressiveTestStruct_size_pl_pl_VarTestStruct_generated.bend as P12_PRV
import ../../src/obj.bend as P13_O
import ../slop/validity/generic_ProgressiveTestStruct_unit_pl_u64_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/generic_ProgressiveTestStruct_writer_pl_SmallTestStruct_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/generic_ProgressiveTestStruct_writer_pl_VarTestStruct_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../slop/validity/generic_ProgressiveTestStruct_writer_pl_pl_VarTestStruct_generated.bend as P16_PRV
import ../../src/buffer.bend as P17_B
import ../../src/obj.bend as P17_O
import ../../src/digest.bend as P17_D
import ../slop/constants/ProgressiveTestStruct_generated.bend as P17_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# ProgressiveTestStruct: its encode_ssz laws in the object API's terms, each discharged by its proving law.

def ProgressiveTestStruct__encode_eval__encode_eval(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> {ProgressiveTestStruct_e.ProgressiveTestStruct_encode(P0_CI.TH(m)) == (P0_CI.TH(m), P0_B.Buf{P0_FD.array__thaw(U32, P0_PRV.OUTE(m)), P0_PRV.SZSM(m)}) : ProgressiveTestStruct_d.ProgressiveTestStruct & P0_B.Buf}:
  P0_PRV.encode_eval(m, hok)

def ProgressiveTestStruct__encode_spec__encode_spec(+m: P0_CI.MW, +hok: {P0_CI.OK(m) == True{} : Bool}) -> P0_Decoding.decodes(P0_Spec.ProgressiveTestStruct(), P0_VS.bt(U32.to_nat(P0_PRV.SZSM(m)), P0_FX.limbs(P0_FD.array__slots(U32, P0_PRV.OUTE(m)))), P0_CI.VAL(m)):
  P0_PRV.encode_spec(m, hok)

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_append_grow() -> {(Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), (Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), (Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), (Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_e.pl_SmallTestStruct_valid(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))))), (Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, U32, proglist_SmallTestStruct_d.pl_SmallTestStruct_len(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))))), (Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Maybe<&1, SmallTestStruct_d.SmallTestStruct>, proglist_SmallTestStruct_d.pl_SmallTestStruct_get(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), 0)), (Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Maybe<&1, SmallTestStruct_d.SmallTestStruct>, proglist_SmallTestStruct_d.pl_SmallTestStruct_get(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), 1)), Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Maybe<&1, SmallTestStruct_d.SmallTestStruct>, proglist_SmallTestStruct_d.pl_SmallTestStruct_get(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(Pair.fst(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1))), 2))))))))) == (True{}, (True{}, (True{}, (True{}, (3, (Some{SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1)}, (Some{SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1)}, Some{SmallTestStruct_d.SmallTestStruct_set_f_A_go(SmallTestStruct_d.SmallTestStruct_default(), 1)}))))))) : Bool & (Bool & (Bool & (Bool & (U32 & (Maybe<&1, SmallTestStruct_d.SmallTestStruct> & (Maybe<&1, SmallTestStruct_d.SmallTestStruct> & Maybe<&1, SmallTestStruct_d.SmallTestStruct>))))))}:
  P1_PRV.ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_append_grow()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_VarTestStruct_append_grow() -> {(Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), (Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), (Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), (Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_e.pl_VarTestStruct_valid(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), (Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, U32, proglist_VarTestStruct_d.pl_VarTestStruct_len(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), (Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, proglist_VarTestStruct_d.pl_VarTestStruct_take(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 0)), (Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, proglist_VarTestStruct_d.pl_VarTestStruct_take(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 1)), Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Maybe<&1, VarTestStruct_d.VarTestStruct>, proglist_VarTestStruct_d.pl_VarTestStruct_take(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))), 2))))))))) == (True{}, (True{}, (True{}, (True{}, (3, (Some{VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)}, (Some{VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)}, Some{VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)}))))))) : Bool & (Bool & (Bool & (Bool & (U32 & (Maybe<&1, VarTestStruct_d.VarTestStruct> & (Maybe<&1, VarTestStruct_d.VarTestStruct> & Maybe<&1, VarTestStruct_d.VarTestStruct>))))))}:
  P2_PRV.ProgressiveTestStruct_serialize_vcoll_pl_VarTestStruct_append_grow()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_pl_VarTestStruct_append_grow() -> {(Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), (Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), (Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), (Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_e.pl_pl_VarTestStruct_valid(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))))), (Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, U32, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_len(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))))), (Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Maybe<&1, proglist_VarTestStruct_d.pl_VarTestStruct_Seq>, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_take(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), 0)), (Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Maybe<&1, proglist_VarTestStruct_d.pl_VarTestStruct_Seq>, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_take(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), 1)), Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Maybe<&1, proglist_VarTestStruct_d.pl_VarTestStruct_Seq>, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_take(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(Pair.fst(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, Bool, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_append(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1))))), 2))))))))) == (True{}, (True{}, (True{}, (True{}, (3, (Some{Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)))}, (Some{Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)))}, Some{Pair.fst(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, Bool, proglist_VarTestStruct_d.pl_VarTestStruct_append(proglist_VarTestStruct_d.pl_VarTestStruct_default(), VarTestStruct_d.VarTestStruct_set_f_A_go(VarTestStruct_d.VarTestStruct_default(), 1)))}))))))) : Bool & (Bool & (Bool & (Bool & (U32 & (Maybe<&1, proglist_VarTestStruct_d.pl_VarTestStruct_Seq> & (Maybe<&1, proglist_VarTestStruct_d.pl_VarTestStruct_Seq> & Maybe<&1, proglist_VarTestStruct_d.pl_VarTestStruct_Seq>))))))}:
  P3_PRV.ProgressiveTestStruct_serialize_vcoll_pl_pl_VarTestStruct_append_grow()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_below() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(30n), 1073741815}, SmallTestStruct_d.SmallTestStruct_default())) == True{} : Bool}:
  P4_PRV.ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_below()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_at() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(30n), 1073741816}, SmallTestStruct_d.SmallTestStruct_default())) == False{} : Bool}:
  P4_PRV.ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_at()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_above() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(30n), 1073741817}, SmallTestStruct_d.SmallTestStruct_default())) == False{} : Bool}:
  P4_PRV.ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_above()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_fit() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(2n), 3}, SmallTestStruct_d.SmallTestStruct_default())) == True{} : Bool}:
  P4_PRV.ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_fit()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_short() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, Bool, proglist_SmallTestStruct_d.pl_SmallTestStruct_append(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(2n), 5}, SmallTestStruct_d.SmallTestStruct_default())) == False{} : Bool}:
  P4_PRV.ProgressiveTestStruct_serialize_vcoll_pl_SmallTestStruct_appb_short()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_below() -> {Pair.snd(P5_O.Words, Bool, proglist_uint64_d.pl_u64_append(P5_O.Words{Array.new(U32, 30n, 0), 4294967256}, P5_O.U64{0, 0})) == True{} : Bool}:
  P5_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_below()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_at() -> {Pair.snd(P5_O.Words, Bool, proglist_uint64_d.pl_u64_append(P5_O.Words{Array.new(U32, 31n, 0), 4294967264}, P5_O.U64{0, 0})) == False{} : Bool}:
  P5_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_at()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_above() -> {Pair.snd(P5_O.Words, Bool, proglist_uint64_d.pl_u64_append(P5_O.Words{Array.new(U32, 31n, 0), 4294967272}, P5_O.U64{0, 0})) == False{} : Bool}:
  P5_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_above()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_fit() -> {Pair.snd(P5_O.Words, Bool, proglist_uint64_d.pl_u64_append(P5_O.Words{Array.new(U32, 3n, 0), 32}, P5_O.U64{0, 0})) == True{} : Bool}:
  P5_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_fit()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_short() -> {Pair.snd(P5_O.Words, Bool, proglist_uint64_d.pl_u64_append(P5_O.Words{Array.new(U32, 3n, 0), 40}, P5_O.U64{0, 0})) == False{} : Bool}:
  P5_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u64_appb_short()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_below() -> {Pair.snd(P6_O.Words, Bool, proglist_uint8_d.pl_u8_append(P6_O.Words{Array.new(U32, 30n, 0), 4294967263}, 0)) == True{} : Bool}:
  P6_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_below()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_at() -> {Pair.snd(P6_O.Words, Bool, proglist_uint8_d.pl_u8_append(P6_O.Words{Array.new(U32, 31n, 0), 4294967264}, 0)) == False{} : Bool}:
  P6_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_at()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_above() -> {Pair.snd(P6_O.Words, Bool, proglist_uint8_d.pl_u8_append(P6_O.Words{Array.new(U32, 31n, 0), 4294967265}, 0)) == False{} : Bool}:
  P6_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_above()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_fit() -> {Pair.snd(P6_O.Words, Bool, proglist_uint8_d.pl_u8_append(P6_O.Words{Array.new(U32, 3n, 0), 32}, 0)) == True{} : Bool}:
  P6_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_fit()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_short() -> {Pair.snd(P6_O.Words, Bool, proglist_uint8_d.pl_u8_append(P6_O.Words{Array.new(U32, 3n, 0), 33}, 0)) == False{} : Bool}:
  P6_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_appb_short()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_len_get() -> {(Pair.snd(P7_O.Words, U32, proglist_uint8_d.pl_u8_len(P7_PRV.ap(P7_PRV.ap(proglist_uint8_d.pl_u8_default(), 255), 1))), (Pair.snd(P7_O.Words, Maybe<&1, U32>, proglist_uint8_d.pl_u8_get(P7_PRV.ap(P7_PRV.ap(proglist_uint8_d.pl_u8_default(), 255), 1), 0)), (Pair.snd(P7_O.Words, Maybe<&1, U32>, proglist_uint8_d.pl_u8_get(P7_PRV.ap(P7_PRV.ap(proglist_uint8_d.pl_u8_default(), 255), 1), 1)), Pair.snd(P7_O.Words, Maybe<&1, U32>, proglist_uint8_d.pl_u8_get(P7_PRV.ap(P7_PRV.ap(proglist_uint8_d.pl_u8_default(), 255), 1), 2))))) == (2, (Some{255}, (Some{1}, None{}))) : U32 & (Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>))}:
  P7_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_len_get()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_get_edge() -> {(Pair.snd(P7_O.Words, Maybe<&1, U32>, proglist_uint8_d.pl_u8_get(P7_O.words_new(3), 2)), (Pair.snd(P7_O.Words, Maybe<&1, U32>, proglist_uint8_d.pl_u8_get(P7_O.words_new(3), 3)), Pair.snd(P7_O.Words, U32, proglist_uint8_d.pl_u8_len(P7_O.words_new(3))))) == (Some{0}, (None{}, 3)) : Maybe<&1, U32> & (Maybe<&1, U32> & U32)}:
  P7_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_get_edge()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_append_range() -> {(Pair.snd(P7_O.Words, Bool, proglist_uint8_d.pl_u8_append(proglist_uint8_d.pl_u8_default(), 256)), Pair.snd(P7_O.Words, Bool, proglist_uint8_d.pl_u8_append(proglist_uint8_d.pl_u8_default(), 255))) == (False{}, True{}) : Bool & Bool}:
  P7_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_append_range()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_set_edge() -> {(Pair.snd(P7_O.Words, Bool, proglist_uint8_d.pl_u8_set(P7_O.words_new(3), 3, 0)), (Pair.snd(P7_O.Words, Bool, proglist_uint8_d.pl_u8_set(P7_O.words_new(3), 2, 0)), Pair.snd(P7_O.Words, Bool, proglist_uint8_d.pl_u8_set(P7_O.words_new(3), 1, 256)))) == (False{}, (True{}, False{})) : Bool & (Bool & Bool)}:
  P7_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_set_edge()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_set_write() -> {(Pair.snd(P7_O.Words, Maybe<&1, U32>, proglist_uint8_d.pl_u8_get(Pair.fst(P7_O.Words, Bool, proglist_uint8_d.pl_u8_set(P7_O.words_new(3), 1, 255)), 0)), (Pair.snd(P7_O.Words, Maybe<&1, U32>, proglist_uint8_d.pl_u8_get(Pair.fst(P7_O.Words, Bool, proglist_uint8_d.pl_u8_set(P7_O.words_new(3), 1, 255)), 1)), Pair.snd(P7_O.Words, Maybe<&1, U32>, proglist_uint8_d.pl_u8_get(Pair.fst(P7_O.Words, Bool, proglist_uint8_d.pl_u8_set(P7_O.words_new(3), 1, 255)), 2)))) == (Some{0}, (Some{255}, Some{0})) : Maybe<&1, U32> & (Maybe<&1, U32> & Maybe<&1, U32>)}:
  P7_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_set_write()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vcoll_pl_u8_append_clear() -> {(Pair.snd(P7_O.Words, Bool, proglist_uint8_d.pl_u8_append(P7_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), (Pair.snd(P7_O.Words, U32, P7_O.words_word(Pair.fst(P7_O.Words, Bool, proglist_uint8_d.pl_u8_append(P7_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), 1)), Pair.snd(P7_O.Words, U32, P7_O.words_word(Pair.fst(P7_O.Words, Bool, proglist_uint8_d.pl_u8_append(P7_O.Words{Array.set(U32, Array.new(U32, 2n, 0), 1, 3735928559), 4}, 1)), 0)))) == (True{}, (1, 0)) : Bool & (U32 & U32)}:
  P7_PRV.ProgressiveTestStruct_serialize_vcoll_pl_u8_append_clear()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vreject_default_valid() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, Bool, ProgressiveTestStruct_e.ProgressiveTestStruct_valid(ProgressiveTestStruct_d.ProgressiveTestStruct_default())) == True{} : Bool}:
  P8_PRV.ProgressiveTestStruct_serialize_vreject_default_valid()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vrefuse_bad_flag() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, P8_O.Encoded, ProgressiveTestStruct_e.ProgressiveTestStruct_senc_go(True{}, 0, ProgressiveTestStruct_d.ProgressiveTestStruct_default())) == P8_O.refused() : P8_O.Encoded}:
  P8_PRV.ProgressiveTestStruct_serialize_vrefuse_bad_flag()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vrefuse_poisoned_size() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, P8_O.Encoded, ProgressiveTestStruct_e.ProgressiveTestStruct_senc_sized((ProgressiveTestStruct_d.ProgressiveTestStruct_default(), 4294967295))) == P8_O.refused() : P8_O.Encoded}:
  P8_PRV.ProgressiveTestStruct_serialize_vrefuse_poisoned_size()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vreject_f_A() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, Bool, ProgressiveTestStruct_e.ProgressiveTestStruct_valid(ProgressiveTestStruct_d.ProgressiveTestStruct_set_f_A(ProgressiveTestStruct_d.ProgressiveTestStruct_default(), P8_O.Words{Array.new(U32, 0n, 0), 5}))) == False{} : Bool}:
  P8_PRV.ProgressiveTestStruct_serialize_vreject_f_A()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vreject_f_B() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, Bool, ProgressiveTestStruct_e.ProgressiveTestStruct_valid(ProgressiveTestStruct_d.ProgressiveTestStruct_set_f_B(ProgressiveTestStruct_d.ProgressiveTestStruct_default(), P8_O.Words{Array.new(U32, 0n, 0), 5}))) == False{} : Bool}:
  P8_PRV.ProgressiveTestStruct_serialize_vreject_f_B()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vreject_f_C() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, Bool, ProgressiveTestStruct_e.ProgressiveTestStruct_valid(ProgressiveTestStruct_d.ProgressiveTestStruct_set_f_C(ProgressiveTestStruct_d.ProgressiveTestStruct_default(), proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(0n), 2}))) == False{} : Bool}:
  P8_PRV.ProgressiveTestStruct_serialize_vreject_f_C()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vreject_f_D() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, Bool, ProgressiveTestStruct_e.ProgressiveTestStruct_valid(ProgressiveTestStruct_d.ProgressiveTestStruct_set_f_D(ProgressiveTestStruct_d.ProgressiveTestStruct_default(), proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq{proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_fill(0n), 2}))) == False{} : Bool}:
  P8_PRV.ProgressiveTestStruct_serialize_vreject_f_D()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vreject_f_D_elem() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, Bool, ProgressiveTestStruct_e.ProgressiveTestStruct_valid(ProgressiveTestStruct_d.ProgressiveTestStruct_set_f_D(ProgressiveTestStruct_d.ProgressiveTestStruct_default(), proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq{proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_fill(0n), 1}))) == False{} : Bool}:
  P8_PRV.ProgressiveTestStruct_serialize_vreject_f_D_elem()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vrefuse_writer_marker() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, P9_O.Encoded, ProgressiveTestStruct_e.ProgressiveTestStruct_senc_out(0, Array.new(U32, 0n, 0), ProgressiveTestStruct_d.ProgressiveTestStruct_default(), 4294967295)) == P9_O.refused() : P9_O.Encoded}:
  P9_PRV.ProgressiveTestStruct_serialize_vrefuse_writer_marker()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vrefuse_writer_above() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, P9_O.Encoded, ProgressiveTestStruct_e.ProgressiveTestStruct_senc_out(0, Array.new(U32, 0n, 0), ProgressiveTestStruct_d.ProgressiveTestStruct_default(), 4294967265)) == P9_O.refused() : P9_O.Encoded}:
  P9_PRV.ProgressiveTestStruct_serialize_vrefuse_writer_above()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vrefuse_writer_ok() -> {Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, P9_O.Encoded, ProgressiveTestStruct_e.ProgressiveTestStruct_senc_out(0, Array.new(U32, 0n, 0), ProgressiveTestStruct_d.ProgressiveTestStruct_default(), 0)) == P9_O.Encoded{True{}, P9_B.Buf{Array.new(U32, 0n, 0), 0}} : P9_O.Encoded}:
  P9_PRV.ProgressiveTestStruct_serialize_vrefuse_writer_ok()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_size_pl_SmallTestStruct_storage_short() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, U32, proglist_SmallTestStruct_e.pl_SmallTestStruct_size(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(1n), 3})) == 4294967295 : U32}:
  P10_PRV.ProgressiveTestStruct_serialize_vpoison_size_pl_SmallTestStruct_storage_short()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_size_pl_SmallTestStruct_storage_tight() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, U32, proglist_SmallTestStruct_e.pl_SmallTestStruct_size(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(1n), 2})) == 8 : U32}:
  P10_PRV.ProgressiveTestStruct_serialize_vpoison_size_pl_SmallTestStruct_storage_tight()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_size_pl_SmallTestStruct_above() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, U32, proglist_SmallTestStruct_e.pl_SmallTestStruct_size(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(30n), 1073741817})) == 4294967295 : U32}:
  P10_PRV.ProgressiveTestStruct_serialize_vpoison_size_pl_SmallTestStruct_above()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_size_pl_SmallTestStruct_at() -> {Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, U32, proglist_SmallTestStruct_e.pl_SmallTestStruct_size(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq{proglist_SmallTestStruct_d.pl_SmallTestStruct_fill(30n), 1073741816})) == 4294967264 : U32}:
  P10_PRV.ProgressiveTestStruct_serialize_vpoison_size_pl_SmallTestStruct_at()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_size_pl_VarTestStruct_offsets() -> {(Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, U32, proglist_VarTestStruct_e.pl_VarTestStruct_size(proglist_VarTestStruct_d.pl_VarTestStruct_Seq{proglist_VarTestStruct_d.pl_VarTestStruct_fill(0n), 1})), Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, U32, proglist_VarTestStruct_e.pl_VarTestStruct_size(proglist_VarTestStruct_d.pl_VarTestStruct_Seq{proglist_VarTestStruct_d.pl_VarTestStruct_fill(1n), 2}))) == (4, 8) : U32 & U32}:
  P11_PRV.ProgressiveTestStruct_serialize_vpoison_size_pl_VarTestStruct_offsets()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_size_pl_pl_VarTestStruct_offsets() -> {(Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, U32, proglist_proglist_VarTestStruct_e.pl_pl_VarTestStruct_size(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq{proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_fill(0n), 1})), Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, U32, proglist_proglist_VarTestStruct_e.pl_pl_VarTestStruct_size(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq{proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_fill(1n), 2}))) == (4, 8) : U32 & U32}:
  P12_PRV.ProgressiveTestStruct_serialize_vpoison_size_pl_pl_VarTestStruct_offsets()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vunit_pl_u64_refuse_1() -> {Pair.snd(P13_O.Words, Bool, proglist_uint64_e.pl_u64_valid(P13_O.words_new(1))) == False{} : Bool}:
  P13_PRV.ProgressiveTestStruct_serialize_vunit_pl_u64_refuse_1()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vunit_pl_u64_refuse_4() -> {Pair.snd(P13_O.Words, Bool, proglist_uint64_e.pl_u64_valid(P13_O.words_new(4))) == False{} : Bool}:
  P13_PRV.ProgressiveTestStruct_serialize_vunit_pl_u64_refuse_4()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vunit_pl_u64_refuse_9() -> {Pair.snd(P13_O.Words, Bool, proglist_uint64_e.pl_u64_valid(P13_O.words_new(9))) == False{} : Bool}:
  P13_PRV.ProgressiveTestStruct_serialize_vunit_pl_u64_refuse_9()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vunit_pl_u64_accept_8() -> {Pair.snd(P13_O.Words, Bool, proglist_uint64_e.pl_u64_valid(P13_O.words_new(8))) == True{} : Bool}:
  P13_PRV.ProgressiveTestStruct_serialize_vunit_pl_u64_accept_8()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vunit_pl_u64_accept_16() -> {Pair.snd(P13_O.Words, Bool, proglist_uint64_e.pl_u64_valid(P13_O.words_new(16))) == True{} : Bool}:
  P13_PRV.ProgressiveTestStruct_serialize_vunit_pl_u64_accept_16()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vunit_pl_u64_range_lo_0() -> {Pair.snd(P13_O.Words, Bool, proglist_uint64_e.pl_u64_valid(P13_O.words_new(0))) == True{} : Bool}:
  P13_PRV.ProgressiveTestStruct_serialize_vunit_pl_u64_range_lo_0()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vunit_pl_u64_range_hi_full() -> {Pair.snd(P13_O.Words, Bool, proglist_uint64_e.pl_u64_valid(P13_O.Words{Array.new(U32, 30n, 0), 4294967264})) == True{} : Bool}:
  P13_PRV.ProgressiveTestStruct_serialize_vunit_pl_u64_range_hi_full()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vunit_pl_u64_range_above_full() -> {Pair.snd(P13_O.Words, Bool, proglist_uint64_e.pl_u64_valid(P13_O.Words{Array.new(U32, 30n, 0), 4294967272})) == False{} : Bool}:
  P13_PRV.ProgressiveTestStruct_serialize_vunit_pl_u64_range_above_full()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_pk_pl_SmallTestStruct() -> {P14_O.is_poisoned(Pair.snd(proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq, U32, Pair.snd(Array<U32>, proglist_SmallTestStruct_d.pl_SmallTestStruct_Seq & U32, proglist_SmallTestStruct_e.pl_SmallTestStruct_pk(Array.new(U32, 0n, 0), 0, (proglist_SmallTestStruct_d.pl_SmallTestStruct_default(), False{}))))) == True{} : Bool}:
  P14_PRV.ProgressiveTestStruct_serialize_vpoison_pk_pl_SmallTestStruct()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_pk_pl_VarTestStruct() -> {P15_O.is_poisoned(Pair.snd(proglist_VarTestStruct_d.pl_VarTestStruct_Seq, U32, Pair.snd(Array<U32>, proglist_VarTestStruct_d.pl_VarTestStruct_Seq & U32, proglist_VarTestStruct_e.pl_VarTestStruct_pk(Array.new(U32, 0n, 0), 0, (proglist_VarTestStruct_d.pl_VarTestStruct_default(), False{}))))) == True{} : Bool}:
  P15_PRV.ProgressiveTestStruct_serialize_vpoison_pk_pl_VarTestStruct()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_serialize_vpoison_pk_pl_pl_VarTestStruct() -> {P16_O.is_poisoned(Pair.snd(proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq, U32, Pair.snd(Array<U32>, proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_Seq & U32, proglist_proglist_VarTestStruct_e.pl_pl_VarTestStruct_pk(Array.new(U32, 0n, 0), 0, (proglist_proglist_VarTestStruct_d.pl_pl_VarTestStruct_default(), False{}))))) == True{} : Bool}:
  P16_PRV.ProgressiveTestStruct_serialize_vpoison_pk_pl_pl_VarTestStruct()

def ProgressiveTestStruct__serialize_valid__ProgressiveTestStruct_mc_ser() -> {ProgressiveTestStruct_e.ProgressiveTestStruct_serialize(ProgressiveTestStruct_d.ProgressiveTestStruct_default()) == (Pair.fst(ProgressiveTestStruct_d.ProgressiveTestStruct, P17_B.Buf, ProgressiveTestStruct_e.ProgressiveTestStruct_encode(ProgressiveTestStruct_d.ProgressiveTestStruct_default())), P17_O.encoded(Pair.snd(ProgressiveTestStruct_d.ProgressiveTestStruct, P17_B.Buf, ProgressiveTestStruct_e.ProgressiveTestStruct_encode(ProgressiveTestStruct_d.ProgressiveTestStruct_default())))) : ProgressiveTestStruct_d.ProgressiveTestStruct & P17_O.Encoded}:
  P17_PRV.ProgressiveTestStruct_mc_ser()

