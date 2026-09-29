import Base
import ../compact/found.bend as F
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/proglist_uint64_hashtreeroot_generated.bend as proglist_uint64_h
import ../../types/VarTestStruct_def_generated.bend as VarTestStruct_d
import ../../types/VarTestStruct_hashtreeroot_generated.bend as VarTestStruct_h
import ../../types/proglist_bool_hashtreeroot_generated.bend as proglist_bool_h
import ../../types/vec_bool_16_hashtreeroot_generated.bend as vec_bool_16_h
import ../../types/vec_bool_1_hashtreeroot_generated.bend as vec_bool_1_h
import ../../types/vec_bool_2_hashtreeroot_generated.bend as vec_bool_2_h
import ../../types/vec_bool_31_hashtreeroot_generated.bend as vec_bool_31_h
import ../../types/vec_bool_3_hashtreeroot_generated.bend as vec_bool_3_h
import ../../types/vec_bool_4_hashtreeroot_generated.bend as vec_bool_4_h
import ../../types/vec_bool_512_hashtreeroot_generated.bend as vec_bool_512_h
import ../../types/vec_bool_513_hashtreeroot_generated.bend as vec_bool_513_h
import ../../types/vec_bool_5_hashtreeroot_generated.bend as vec_bool_5_h
import ../../types/vec_bool_8_hashtreeroot_generated.bend as vec_bool_8_h
import ../../types/proglist_uint128_hashtreeroot_generated.bend as proglist_uint128_h
import ../../types/vec_uint128_16_hashtreeroot_generated.bend as vec_uint128_16_h
import ../../types/vec_uint128_1_hashtreeroot_generated.bend as vec_uint128_1_h
import ../../types/vec_uint128_2_hashtreeroot_generated.bend as vec_uint128_2_h
import ../../types/vec_uint128_31_hashtreeroot_generated.bend as vec_uint128_31_h
import ../../types/vec_uint128_3_hashtreeroot_generated.bend as vec_uint128_3_h
import ../../types/vec_uint128_4_hashtreeroot_generated.bend as vec_uint128_4_h
import ../../types/vec_uint128_512_hashtreeroot_generated.bend as vec_uint128_512_h
import ../../types/vec_uint128_513_hashtreeroot_generated.bend as vec_uint128_513_h
import ../../types/vec_uint128_5_hashtreeroot_generated.bend as vec_uint128_5_h
import ../../types/vec_uint128_8_hashtreeroot_generated.bend as vec_uint128_8_h
import ../../types/proglist_uint8_hashtreeroot_generated.bend as proglist_uint8_h
import ../../types/vec_uint8_16_hashtreeroot_generated.bend as vec_uint8_16_h
import ../../types/vec_uint8_1_hashtreeroot_generated.bend as vec_uint8_1_h
import ../../types/vec_uint8_2_hashtreeroot_generated.bend as vec_uint8_2_h
import ../../types/vec_uint8_31_hashtreeroot_generated.bend as vec_uint8_31_h
import ../../types/vec_uint8_3_hashtreeroot_generated.bend as vec_uint8_3_h
import ../../types/vec_uint8_4_hashtreeroot_generated.bend as vec_uint8_4_h
import ../../types/vec_uint8_512_hashtreeroot_generated.bend as vec_uint8_512_h
import ../../types/vec_uint8_513_hashtreeroot_generated.bend as vec_uint8_513_h
import ../../types/vec_uint8_5_hashtreeroot_generated.bend as vec_uint8_5_h
import ../../types/vec_uint8_8_hashtreeroot_generated.bend as vec_uint8_8_h
import ../../types/proglist_uint16_hashtreeroot_generated.bend as proglist_uint16_h
import ../../types/vec_uint16_16_hashtreeroot_generated.bend as vec_uint16_16_h
import ../../types/vec_uint16_1_hashtreeroot_generated.bend as vec_uint16_1_h
import ../../types/vec_uint16_2_hashtreeroot_generated.bend as vec_uint16_2_h
import ../../types/vec_uint16_31_hashtreeroot_generated.bend as vec_uint16_31_h
import ../../types/vec_uint16_3_hashtreeroot_generated.bend as vec_uint16_3_h
import ../../types/vec_uint16_4_hashtreeroot_generated.bend as vec_uint16_4_h
import ../../types/vec_uint16_512_hashtreeroot_generated.bend as vec_uint16_512_h
import ../../types/vec_uint16_513_hashtreeroot_generated.bend as vec_uint16_513_h
import ../../types/vec_uint16_5_hashtreeroot_generated.bend as vec_uint16_5_h
import ../../types/vec_uint16_8_hashtreeroot_generated.bend as vec_uint16_8_h
import ../../types/proglist_uint256_hashtreeroot_generated.bend as proglist_uint256_h
import ../../types/vec_uint256_16_hashtreeroot_generated.bend as vec_uint256_16_h
import ../../types/vec_uint256_1_hashtreeroot_generated.bend as vec_uint256_1_h
import ../../types/vec_uint256_2_hashtreeroot_generated.bend as vec_uint256_2_h
import ../../types/vec_uint256_31_hashtreeroot_generated.bend as vec_uint256_31_h
import ../../types/vec_uint256_3_hashtreeroot_generated.bend as vec_uint256_3_h
import ../../types/vec_uint256_4_hashtreeroot_generated.bend as vec_uint256_4_h
import ../../types/vec_uint256_512_hashtreeroot_generated.bend as vec_uint256_512_h
import ../../types/vec_uint256_513_hashtreeroot_generated.bend as vec_uint256_513_h
import ../../types/vec_uint256_5_hashtreeroot_generated.bend as vec_uint256_5_h
import ../../types/vec_uint256_8_hashtreeroot_generated.bend as vec_uint256_8_h
import ../../types/proglist_uint32_hashtreeroot_generated.bend as proglist_uint32_h
import ../../types/vec_uint32_16_hashtreeroot_generated.bend as vec_uint32_16_h
import ../../types/vec_uint32_1_hashtreeroot_generated.bend as vec_uint32_1_h
import ../../types/vec_uint32_2_hashtreeroot_generated.bend as vec_uint32_2_h
import ../../types/vec_uint32_31_hashtreeroot_generated.bend as vec_uint32_31_h
import ../../types/vec_uint32_3_hashtreeroot_generated.bend as vec_uint32_3_h
import ../../types/vec_uint32_4_hashtreeroot_generated.bend as vec_uint32_4_h
import ../../types/vec_uint32_512_hashtreeroot_generated.bend as vec_uint32_512_h
import ../../types/vec_uint32_513_hashtreeroot_generated.bend as vec_uint32_513_h
import ../../types/vec_uint32_5_hashtreeroot_generated.bend as vec_uint32_5_h
import ../../types/vec_uint32_8_hashtreeroot_generated.bend as vec_uint32_8_h
import ../../types/vec_uint64_16_hashtreeroot_generated.bend as vec_uint64_16_h
import ../../types/vec_uint64_1_hashtreeroot_generated.bend as vec_uint64_1_h
import ../../types/vec_uint64_2_hashtreeroot_generated.bend as vec_uint64_2_h
import ../../types/vec_uint64_31_hashtreeroot_generated.bend as vec_uint64_31_h
import ../../types/vec_uint64_3_hashtreeroot_generated.bend as vec_uint64_3_h
import ../../types/vec_uint64_4_hashtreeroot_generated.bend as vec_uint64_4_h
import ../../types/vec_uint64_512_hashtreeroot_generated.bend as vec_uint64_512_h
import ../../types/vec_uint64_513_hashtreeroot_generated.bend as vec_uint64_513_h
import ../../types/vec_uint64_5_hashtreeroot_generated.bend as vec_uint64_5_h
import ../../types/vec_uint64_8_hashtreeroot_generated.bend as vec_uint64_8_h
import ../../types/bitlist_5_hashtreeroot_generated.bend as bitlist_5_h
import ../../types/bitlist_6_hashtreeroot_generated.bend as bitlist_6_h
import ../../types/ComplexTestStruct_def_generated.bend as ComplexTestStruct_d
import ../../types/ComplexTestStruct_hashtreeroot_generated.bend as ComplexTestStruct_h
import ../../types/bitlist_15_hashtreeroot_generated.bend as bitlist_15_h
import ../../types/bitlist_16_hashtreeroot_generated.bend as bitlist_16_h
import ../../types/bitlist_17_hashtreeroot_generated.bend as bitlist_17_h
import ../../types/bitlist_1_hashtreeroot_generated.bend as bitlist_1_h
import ../../types/bitlist_2_hashtreeroot_generated.bend as bitlist_2_h
import ../../types/bitlist_31_hashtreeroot_generated.bend as bitlist_31_h
import ../../types/bitlist_32_hashtreeroot_generated.bend as bitlist_32_h
import ../../types/bitlist_33_hashtreeroot_generated.bend as bitlist_33_h
import ../../types/bitlist_3_hashtreeroot_generated.bend as bitlist_3_h
import ../../types/bitlist_4_hashtreeroot_generated.bend as bitlist_4_h
import ../../types/bitlist_511_hashtreeroot_generated.bend as bitlist_511_h
import ../../types/bitlist_512_hashtreeroot_generated.bend as bitlist_512_h
import ../../types/bitlist_513_hashtreeroot_generated.bend as bitlist_513_h
import ../../types/bitlist_7_hashtreeroot_generated.bend as bitlist_7_h
import ../../types/bitlist_8_hashtreeroot_generated.bend as bitlist_8_h
import ../../types/bitlist_9_hashtreeroot_generated.bend as bitlist_9_h
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../obj/cform.bend as CF
import ../obj/amap.bend as AM
import ../../spec/root_relation.bend as RR
import ../obj/generic_specs.bend as Spec
import ../obj/schema_shapes.bend as SH
import ../obj/dk.bend as DK
import ../obj/mtree_defs.bend as MD
import ../obj/words_obj_light.bend as WO_L
import ../obj/list_obj_light.bend as LO_L
import ../obj/pv_obj_light.bend as PV
import ../obj/bitlist_obj_light.bend as BO_L
import ../obj/cells_light.bend as CE_L
import ../obj/obj_support.bend as OS
import ../obj/root_gnames_light.bend as RN_L
import ../obj/ulist_obj_light.bend as UL_L
import ../obj/packed_obj_light.bend as PK_L
import ../obj/packed_bytes_light.bend as PB_L
import ../obj/prog_list_light.bend as PG_L
import ../obj/blist_obj_light.bend as BLI_L
import ../obj/elems48_light.bend as E48_L
import ../obj/xlist_support.bend as XS
import ../obj/mtree_run.bend as MR
import ../../spec/codec.bend as Codec
import ../../spec/limits.bend as Lim
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../../spec/byte_list.bend as BL
import ../obj/root_gtypes_light.bend as LV
import ../obj/root_gtypes.bend as PRV

# GENERATED by codegen/api_gate.py. Do not edit.
# The object API laws that proofs/obj/root_gtypes.bend proves (ComplexTestStruct, VarTestStruct, bitlist_1, bitlist_15, bitlist_16, bitlist_17, bitlist_2, bitlist_3, bitlist_31, bitlist_32, bitlist_33, bitlist_4, bitlist_5, bitlist_511, bitlist_512, bitlist_513, bitlist_6, bitlist_7, bitlist_8, bitlist_9, proglist_bool, proglist_uint128, proglist_uint16, proglist_uint256, proglist_uint32, proglist_uint64, proglist_uint8, vec_bool_1, vec_bool_16, vec_bool_2, vec_bool_3, vec_bool_31, vec_bool_4, vec_bool_5, vec_bool_512, vec_bool_513, vec_bool_8, vec_uint128_1, vec_uint128_16, vec_uint128_2, vec_uint128_3, vec_uint128_31, vec_uint128_4, vec_uint128_5, vec_uint128_512, vec_uint128_513, vec_uint128_8, vec_uint16_1, vec_uint16_16, vec_uint16_2, vec_uint16_3, vec_uint16_31, vec_uint16_4, vec_uint16_5, vec_uint16_512, vec_uint16_513, vec_uint16_8, vec_uint256_1, vec_uint256_16, vec_uint256_2, vec_uint256_3, vec_uint256_31, vec_uint256_4, vec_uint256_5, vec_uint256_512, vec_uint256_513, vec_uint256_8, vec_uint32_1, vec_uint32_16, vec_uint32_2, vec_uint32_3, vec_uint32_31, vec_uint32_4, vec_uint32_5, vec_uint32_512, vec_uint32_513, vec_uint32_8, vec_uint64_1, vec_uint64_16, vec_uint64_2, vec_uint64_3, vec_uint64_31, vec_uint64_4, vec_uint64_5, vec_uint64_512, vec_uint64_513, vec_uint64_8, vec_uint8_1, vec_uint8_16, vec_uint8_2, vec_uint8_3, vec_uint8_31, vec_uint8_4, vec_uint8_5, vec_uint8_512, vec_uint8_513, vec_uint8_8), each discharged by that law.

def ComplexTestStruct__root__ComplexTestStruct_root_correct(-h: B.Buf, -o: ComplexTestStruct_d.ComplexTestStruct, +s: S.Schema, +es: {s == Spec.ComplexTestStruct() : S.Schema}, +rep: LV.rep_ComplexTestStruct(o, s)) -> RR.roots(LV.v_ComplexTestStruct(o), s, [D.bytes(Pair.snd(ComplexTestStruct_d.ComplexTestStruct, D.Digest, Pair.snd(B.Buf, ComplexTestStruct_d.ComplexTestStruct & D.Digest, ComplexTestStruct_h.ComplexTestStruct_hash_tree_root(h, o))))]):
  PRV.ComplexTestStruct_root_correct(h, o, s, es, rep)

def VarTestStruct__root__VarTestStruct_root_correct(-h: B.Buf, -o: VarTestStruct_d.VarTestStruct, +s: S.Schema, +es: {s == Spec.VarTestStruct() : S.Schema}, +rep: LV.rep_VarTestStruct(o, s)) -> RR.roots(LV.v_VarTestStruct(o), s, [D.bytes(Pair.snd(VarTestStruct_d.VarTestStruct, D.Digest, Pair.snd(B.Buf, VarTestStruct_d.VarTestStruct & D.Digest, VarTestStruct_h.VarTestStruct_hash_tree_root(h, o))))]):
  PRV.VarTestStruct_root_correct(h, o, s, es, rep)

def bitlist_1__root__bitlist_1_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_1() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_1_h.bitlist_1_hash_tree_root(h, o))))]):
  PRV.bitlist_1_root_correct(h, o, s, es, rep)

def bitlist_15__root__bitlist_15_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_15() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_15_h.bitlist_15_hash_tree_root(h, o))))]):
  PRV.bitlist_15_root_correct(h, o, s, es, rep)

def bitlist_16__root__bitlist_16_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_16() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_16_h.bitlist_16_hash_tree_root(h, o))))]):
  PRV.bitlist_16_root_correct(h, o, s, es, rep)

def bitlist_17__root__bitlist_17_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_17() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_17_h.bitlist_17_hash_tree_root(h, o))))]):
  PRV.bitlist_17_root_correct(h, o, s, es, rep)

def bitlist_2__root__bitlist_2_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_2() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_2_h.bitlist_2_hash_tree_root(h, o))))]):
  PRV.bitlist_2_root_correct(h, o, s, es, rep)

def bitlist_3__root__bitlist_3_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_3() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_3_h.bitlist_3_hash_tree_root(h, o))))]):
  PRV.bitlist_3_root_correct(h, o, s, es, rep)

def bitlist_31__root__bitlist_31_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_31() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_31_h.bitlist_31_hash_tree_root(h, o))))]):
  PRV.bitlist_31_root_correct(h, o, s, es, rep)

def bitlist_32__root__bitlist_32_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_32() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_32_h.bitlist_32_hash_tree_root(h, o))))]):
  PRV.bitlist_32_root_correct(h, o, s, es, rep)

def bitlist_33__root__bitlist_33_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_33() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_33_h.bitlist_33_hash_tree_root(h, o))))]):
  PRV.bitlist_33_root_correct(h, o, s, es, rep)

def bitlist_4__root__bitlist_4_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_4() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_4_h.bitlist_4_hash_tree_root(h, o))))]):
  PRV.bitlist_4_root_correct(h, o, s, es, rep)

def bitlist_5__root__bitlist_5_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_5() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_5_h.bitlist_5_hash_tree_root(h, o))))]):
  PRV.bitlist_5_root_correct(h, o, s, es, rep)

def bitlist_511__root__bitlist_511_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_511() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_511_h.bitlist_511_hash_tree_root(h, o))))]):
  PRV.bitlist_511_root_correct(h, o, s, es, rep)

def bitlist_512__root__bitlist_512_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_512() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_512_h.bitlist_512_hash_tree_root(h, o))))]):
  PRV.bitlist_512_root_correct(h, o, s, es, rep)

def bitlist_513__root__bitlist_513_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_513() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_513_h.bitlist_513_hash_tree_root(h, o))))]):
  PRV.bitlist_513_root_correct(h, o, s, es, rep)

def bitlist_6__root__bitlist_6_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_6() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_6_h.bitlist_6_hash_tree_root(h, o))))]):
  PRV.bitlist_6_root_correct(h, o, s, es, rep)

def bitlist_7__root__bitlist_7_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_7() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_7_h.bitlist_7_hash_tree_root(h, o))))]):
  PRV.bitlist_7_root_correct(h, o, s, es, rep)

def bitlist_8__root__bitlist_8_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_8() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_8_h.bitlist_8_hash_tree_root(h, o))))]):
  PRV.bitlist_8_root_correct(h, o, s, es, rep)

def bitlist_9__root__bitlist_9_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.bitlist_9() : S.Schema}, +rep: BO_L.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_9_h.bitlist_9_hash_tree_root(h, o))))]):
  PRV.bitlist_9_root_correct(h, o, s, es, rep)

def proglist_bool__root__proglist_bool_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.proglist_bool() : S.Schema}, +rep: PG_L.rep_plb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_bool_h.proglist_bool_hash_tree_root(h, o))))]):
  PRV.proglist_bool_root_correct(h, o, s, es, rep)

def proglist_uint128__root__proglist_uint128_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.proglist_uint128() : S.Schema}, +rep: PG_L.rep_pl16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint128_h.proglist_uint128_hash_tree_root(h, o))))]):
  PRV.proglist_uint128_root_correct(h, o, s, es, rep)

def proglist_uint16__root__proglist_uint16_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.proglist_uint16() : S.Schema}, +rep: PG_L.rep_pl2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint16_h.proglist_uint16_hash_tree_root(h, o))))]):
  PRV.proglist_uint16_root_correct(h, o, s, es, rep)

def proglist_uint256__root__proglist_uint256_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.proglist_uint256() : S.Schema}, +rep: PG_L.rep_pl32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint256_h.proglist_uint256_hash_tree_root(h, o))))]):
  PRV.proglist_uint256_root_correct(h, o, s, es, rep)

def proglist_uint32__root__proglist_uint32_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.proglist_uint32() : S.Schema}, +rep: PG_L.rep_pl4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint32_h.proglist_uint32_hash_tree_root(h, o))))]):
  PRV.proglist_uint32_root_correct(h, o, s, es, rep)

def proglist_uint64__root__proglist_uint64_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.proglist_uint64() : S.Schema}, +rep: PG_L.rep_pl8(o, s)) -> RR.roots(UL_L.uview(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint64_h.proglist_uint64_hash_tree_root(h, o))))]):
  PRV.proglist_uint64_root_correct(h, o, s, es, rep)

def proglist_uint8__root__proglist_uint8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.proglist_uint8() : S.Schema}, +rep: PG_L.rep_pl1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint8_h.proglist_uint8_hash_tree_root(h, o))))]):
  PRV.proglist_uint8_root_correct(h, o, s, es, rep)

def vec_bool_1__root__vec_bool_1_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_1() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_1_h.vec_bool_1_hash_tree_root(h, o))))]):
  PRV.vec_bool_1_root_correct(h, o, s, es, rep)

def vec_bool_16__root__vec_bool_16_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_16() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_16_h.vec_bool_16_hash_tree_root(h, o))))]):
  PRV.vec_bool_16_root_correct(h, o, s, es, rep)

def vec_bool_2__root__vec_bool_2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_2() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_2_h.vec_bool_2_hash_tree_root(h, o))))]):
  PRV.vec_bool_2_root_correct(h, o, s, es, rep)

def vec_bool_3__root__vec_bool_3_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_3() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_3_h.vec_bool_3_hash_tree_root(h, o))))]):
  PRV.vec_bool_3_root_correct(h, o, s, es, rep)

def vec_bool_31__root__vec_bool_31_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_31() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_31_h.vec_bool_31_hash_tree_root(h, o))))]):
  PRV.vec_bool_31_root_correct(h, o, s, es, rep)

def vec_bool_4__root__vec_bool_4_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_4() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_4_h.vec_bool_4_hash_tree_root(h, o))))]):
  PRV.vec_bool_4_root_correct(h, o, s, es, rep)

def vec_bool_5__root__vec_bool_5_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_5() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_5_h.vec_bool_5_hash_tree_root(h, o))))]):
  PRV.vec_bool_5_root_correct(h, o, s, es, rep)

def vec_bool_512__root__vec_bool_512_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_512() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_512_h.vec_bool_512_hash_tree_root(h, o))))]):
  PRV.vec_bool_512_root_correct(h, o, s, es, rep)

def vec_bool_513__root__vec_bool_513_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_513() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_513_h.vec_bool_513_hash_tree_root(h, o))))]):
  PRV.vec_bool_513_root_correct(h, o, s, es, rep)

def vec_bool_8__root__vec_bool_8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_bool_8() : S.Schema}, +rep: PB_L.rep_vb(o, s)) -> RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_8_h.vec_bool_8_hash_tree_root(h, o))))]):
  PRV.vec_bool_8_root_correct(h, o, s, es, rep)

def vec_uint128_1__root__vec_uint128_1_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_1() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_1_h.vec_uint128_1_hash_tree_root(h, o))))]):
  PRV.vec_uint128_1_root_correct(h, o, s, es, rep)

def vec_uint128_16__root__vec_uint128_16_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_16() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_16_h.vec_uint128_16_hash_tree_root(h, o))))]):
  PRV.vec_uint128_16_root_correct(h, o, s, es, rep)

def vec_uint128_2__root__vec_uint128_2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_2() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_2_h.vec_uint128_2_hash_tree_root(h, o))))]):
  PRV.vec_uint128_2_root_correct(h, o, s, es, rep)

def vec_uint128_3__root__vec_uint128_3_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_3() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_3_h.vec_uint128_3_hash_tree_root(h, o))))]):
  PRV.vec_uint128_3_root_correct(h, o, s, es, rep)

def vec_uint128_31__root__vec_uint128_31_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_31() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_31_h.vec_uint128_31_hash_tree_root(h, o))))]):
  PRV.vec_uint128_31_root_correct(h, o, s, es, rep)

def vec_uint128_4__root__vec_uint128_4_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_4() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_4_h.vec_uint128_4_hash_tree_root(h, o))))]):
  PRV.vec_uint128_4_root_correct(h, o, s, es, rep)

def vec_uint128_5__root__vec_uint128_5_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_5() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_5_h.vec_uint128_5_hash_tree_root(h, o))))]):
  PRV.vec_uint128_5_root_correct(h, o, s, es, rep)

def vec_uint128_512__root__vec_uint128_512_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_512() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_512_h.vec_uint128_512_hash_tree_root(h, o))))]):
  PRV.vec_uint128_512_root_correct(h, o, s, es, rep)

def vec_uint128_513__root__vec_uint128_513_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_513() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_513_h.vec_uint128_513_hash_tree_root(h, o))))]):
  PRV.vec_uint128_513_root_correct(h, o, s, es, rep)

def vec_uint128_8__root__vec_uint128_8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint128_8() : S.Schema}, +rep: PK_L.rep_v16(o, s)) -> RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_8_h.vec_uint128_8_hash_tree_root(h, o))))]):
  PRV.vec_uint128_8_root_correct(h, o, s, es, rep)

def vec_uint16_1__root__vec_uint16_1_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_1() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_1_h.vec_uint16_1_hash_tree_root(h, o))))]):
  PRV.vec_uint16_1_root_correct(h, o, s, es, rep)

def vec_uint16_16__root__vec_uint16_16_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_16() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_16_h.vec_uint16_16_hash_tree_root(h, o))))]):
  PRV.vec_uint16_16_root_correct(h, o, s, es, rep)

def vec_uint16_2__root__vec_uint16_2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_2() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_2_h.vec_uint16_2_hash_tree_root(h, o))))]):
  PRV.vec_uint16_2_root_correct(h, o, s, es, rep)

def vec_uint16_3__root__vec_uint16_3_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_3() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_3_h.vec_uint16_3_hash_tree_root(h, o))))]):
  PRV.vec_uint16_3_root_correct(h, o, s, es, rep)

def vec_uint16_31__root__vec_uint16_31_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_31() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_31_h.vec_uint16_31_hash_tree_root(h, o))))]):
  PRV.vec_uint16_31_root_correct(h, o, s, es, rep)

def vec_uint16_4__root__vec_uint16_4_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_4() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_4_h.vec_uint16_4_hash_tree_root(h, o))))]):
  PRV.vec_uint16_4_root_correct(h, o, s, es, rep)

def vec_uint16_5__root__vec_uint16_5_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_5() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_5_h.vec_uint16_5_hash_tree_root(h, o))))]):
  PRV.vec_uint16_5_root_correct(h, o, s, es, rep)

def vec_uint16_512__root__vec_uint16_512_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_512() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_512_h.vec_uint16_512_hash_tree_root(h, o))))]):
  PRV.vec_uint16_512_root_correct(h, o, s, es, rep)

def vec_uint16_513__root__vec_uint16_513_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_513() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_513_h.vec_uint16_513_hash_tree_root(h, o))))]):
  PRV.vec_uint16_513_root_correct(h, o, s, es, rep)

def vec_uint16_8__root__vec_uint16_8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint16_8() : S.Schema}, +rep: PB_L.rep_v2(o, s)) -> RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_8_h.vec_uint16_8_hash_tree_root(h, o))))]):
  PRV.vec_uint16_8_root_correct(h, o, s, es, rep)

def vec_uint256_1__root__vec_uint256_1_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_1() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_1_h.vec_uint256_1_hash_tree_root(h, o))))]):
  PRV.vec_uint256_1_root_correct(h, o, s, es, rep)

def vec_uint256_16__root__vec_uint256_16_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_16() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_16_h.vec_uint256_16_hash_tree_root(h, o))))]):
  PRV.vec_uint256_16_root_correct(h, o, s, es, rep)

def vec_uint256_2__root__vec_uint256_2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_2() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_2_h.vec_uint256_2_hash_tree_root(h, o))))]):
  PRV.vec_uint256_2_root_correct(h, o, s, es, rep)

def vec_uint256_3__root__vec_uint256_3_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_3() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_3_h.vec_uint256_3_hash_tree_root(h, o))))]):
  PRV.vec_uint256_3_root_correct(h, o, s, es, rep)

def vec_uint256_31__root__vec_uint256_31_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_31() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_31_h.vec_uint256_31_hash_tree_root(h, o))))]):
  PRV.vec_uint256_31_root_correct(h, o, s, es, rep)

def vec_uint256_4__root__vec_uint256_4_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_4() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_4_h.vec_uint256_4_hash_tree_root(h, o))))]):
  PRV.vec_uint256_4_root_correct(h, o, s, es, rep)

def vec_uint256_5__root__vec_uint256_5_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_5() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_5_h.vec_uint256_5_hash_tree_root(h, o))))]):
  PRV.vec_uint256_5_root_correct(h, o, s, es, rep)

def vec_uint256_512__root__vec_uint256_512_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_512() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_512_h.vec_uint256_512_hash_tree_root(h, o))))]):
  PRV.vec_uint256_512_root_correct(h, o, s, es, rep)

def vec_uint256_513__root__vec_uint256_513_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_513() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_513_h.vec_uint256_513_hash_tree_root(h, o))))]):
  PRV.vec_uint256_513_root_correct(h, o, s, es, rep)

def vec_uint256_8__root__vec_uint256_8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint256_8() : S.Schema}, +rep: PK_L.rep_v32(o, s)) -> RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_8_h.vec_uint256_8_hash_tree_root(h, o))))]):
  PRV.vec_uint256_8_root_correct(h, o, s, es, rep)

def vec_uint32_1__root__vec_uint32_1_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_1() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_1_h.vec_uint32_1_hash_tree_root(h, o))))]):
  PRV.vec_uint32_1_root_correct(h, o, s, es, rep)

def vec_uint32_16__root__vec_uint32_16_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_16() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_16_h.vec_uint32_16_hash_tree_root(h, o))))]):
  PRV.vec_uint32_16_root_correct(h, o, s, es, rep)

def vec_uint32_2__root__vec_uint32_2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_2() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_2_h.vec_uint32_2_hash_tree_root(h, o))))]):
  PRV.vec_uint32_2_root_correct(h, o, s, es, rep)

def vec_uint32_3__root__vec_uint32_3_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_3() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_3_h.vec_uint32_3_hash_tree_root(h, o))))]):
  PRV.vec_uint32_3_root_correct(h, o, s, es, rep)

def vec_uint32_31__root__vec_uint32_31_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_31() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_31_h.vec_uint32_31_hash_tree_root(h, o))))]):
  PRV.vec_uint32_31_root_correct(h, o, s, es, rep)

def vec_uint32_4__root__vec_uint32_4_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_4() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_4_h.vec_uint32_4_hash_tree_root(h, o))))]):
  PRV.vec_uint32_4_root_correct(h, o, s, es, rep)

def vec_uint32_5__root__vec_uint32_5_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_5() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_5_h.vec_uint32_5_hash_tree_root(h, o))))]):
  PRV.vec_uint32_5_root_correct(h, o, s, es, rep)

def vec_uint32_512__root__vec_uint32_512_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_512() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_512_h.vec_uint32_512_hash_tree_root(h, o))))]):
  PRV.vec_uint32_512_root_correct(h, o, s, es, rep)

def vec_uint32_513__root__vec_uint32_513_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_513() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_513_h.vec_uint32_513_hash_tree_root(h, o))))]):
  PRV.vec_uint32_513_root_correct(h, o, s, es, rep)

def vec_uint32_8__root__vec_uint32_8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint32_8() : S.Schema}, +rep: PK_L.rep_v4(o, s)) -> RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_8_h.vec_uint32_8_hash_tree_root(h, o))))]):
  PRV.vec_uint32_8_root_correct(h, o, s, es, rep)

def vec_uint64_1__root__vec_uint64_1_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_1() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_1_h.vec_uint64_1_hash_tree_root(h, o))))]):
  PRV.vec_uint64_1_root_correct(h, o, s, es, rep)

def vec_uint64_16__root__vec_uint64_16_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_16() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_16_h.vec_uint64_16_hash_tree_root(h, o))))]):
  PRV.vec_uint64_16_root_correct(h, o, s, es, rep)

def vec_uint64_2__root__vec_uint64_2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_2() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_2_h.vec_uint64_2_hash_tree_root(h, o))))]):
  PRV.vec_uint64_2_root_correct(h, o, s, es, rep)

def vec_uint64_3__root__vec_uint64_3_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_3() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_3_h.vec_uint64_3_hash_tree_root(h, o))))]):
  PRV.vec_uint64_3_root_correct(h, o, s, es, rep)

def vec_uint64_31__root__vec_uint64_31_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_31() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_31_h.vec_uint64_31_hash_tree_root(h, o))))]):
  PRV.vec_uint64_31_root_correct(h, o, s, es, rep)

def vec_uint64_4__root__vec_uint64_4_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_4() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_4_h.vec_uint64_4_hash_tree_root(h, o))))]):
  PRV.vec_uint64_4_root_correct(h, o, s, es, rep)

def vec_uint64_5__root__vec_uint64_5_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_5() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_5_h.vec_uint64_5_hash_tree_root(h, o))))]):
  PRV.vec_uint64_5_root_correct(h, o, s, es, rep)

def vec_uint64_512__root__vec_uint64_512_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_512() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_512_h.vec_uint64_512_hash_tree_root(h, o))))]):
  PRV.vec_uint64_512_root_correct(h, o, s, es, rep)

def vec_uint64_513__root__vec_uint64_513_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_513() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_513_h.vec_uint64_513_hash_tree_root(h, o))))]):
  PRV.vec_uint64_513_root_correct(h, o, s, es, rep)

def vec_uint64_8__root__vec_uint64_8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint64_8() : S.Schema}, +rep: PK_L.rep_v8(o, s)) -> RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_8_h.vec_uint64_8_hash_tree_root(h, o))))]):
  PRV.vec_uint64_8_root_correct(h, o, s, es, rep)

def vec_uint8_1__root__vec_uint8_1_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_1() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_1_h.vec_uint8_1_hash_tree_root(h, o))))]):
  PRV.vec_uint8_1_root_correct(h, o, s, es, rep)

def vec_uint8_16__root__vec_uint8_16_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_16() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_16_h.vec_uint8_16_hash_tree_root(h, o))))]):
  PRV.vec_uint8_16_root_correct(h, o, s, es, rep)

def vec_uint8_2__root__vec_uint8_2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_2() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_2_h.vec_uint8_2_hash_tree_root(h, o))))]):
  PRV.vec_uint8_2_root_correct(h, o, s, es, rep)

def vec_uint8_3__root__vec_uint8_3_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_3() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_3_h.vec_uint8_3_hash_tree_root(h, o))))]):
  PRV.vec_uint8_3_root_correct(h, o, s, es, rep)

def vec_uint8_31__root__vec_uint8_31_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_31() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_31_h.vec_uint8_31_hash_tree_root(h, o))))]):
  PRV.vec_uint8_31_root_correct(h, o, s, es, rep)

def vec_uint8_4__root__vec_uint8_4_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_4() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_4_h.vec_uint8_4_hash_tree_root(h, o))))]):
  PRV.vec_uint8_4_root_correct(h, o, s, es, rep)

def vec_uint8_5__root__vec_uint8_5_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_5() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_5_h.vec_uint8_5_hash_tree_root(h, o))))]):
  PRV.vec_uint8_5_root_correct(h, o, s, es, rep)

def vec_uint8_512__root__vec_uint8_512_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_512() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_512_h.vec_uint8_512_hash_tree_root(h, o))))]):
  PRV.vec_uint8_512_root_correct(h, o, s, es, rep)

def vec_uint8_513__root__vec_uint8_513_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_513() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_513_h.vec_uint8_513_hash_tree_root(h, o))))]):
  PRV.vec_uint8_513_root_correct(h, o, s, es, rep)

def vec_uint8_8__root__vec_uint8_8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.vec_uint8_8() : S.Schema}, +rep: PB_L.rep_v1(o, s)) -> RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_8_h.vec_uint8_8_hash_tree_root(h, o))))]):
  PRV.vec_uint8_8_root_correct(h, o, s, es, rep)

