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
import ../obj/root_support.bend as RS
import ../obj/words_obj.bend as WO
import ../obj/list_obj.bend as LO
import ../obj/pv_obj.bend as PV
import ../obj/bitlist_obj.bend as BO
import ../obj/cells.bend as CE
import ../obj/obj_support.bend as OS
import ../obj/root_gnames.bend as RN
import ../obj/ulist_obj.bend as UL
import ../obj/lim_ul.bend as LUL
import ../obj/packed_obj.bend as PK
import ../obj/packed_bytes.bend as PB
import ../obj/prog_list.bend as PG
import ../obj/blist_obj.bend as BLI
import ../obj/elems48.bend as E48
import ../obj/xlist_support.bend as XS
import ../obj/mtree_run.bend as MR
import ../obj/list_root.bend as LR
import ../../spec/codec.bend as Codec
import ../../spec/limits.bend as Lim
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../../spec/byte_list.bend as BL
import ../obj/root_gtypes.bend as PRV

# GENERATED by codegen/api_gate.py. Do not edit.
# The object API laws that proofs/obj/root_gtypes.bend proves (Gc465214E502, Gc56D855869F, Gt039DD44FD8, Gt04170D6AA7, Gt0A3B6B4128, Gt0B1B711C4D, Gt0B4EF17D71, Gt10D6F42D74, Gt13AFE546ED, Gt1719057EB7, Gt19F04F79B8, Gt1C2FA69562, Gt1D9B3E1871, Gt21E1483EE1, Gt240C147AA2, Gt274A0B8DC2, Gt28605B5D5C, Gt28ED72E3EF, Gt2CD118DF5F, Gt2E7060B297, Gt2F34855D3D, Gt2FF8722A75, Gt3429157FEB, Gt34AE45611E, Gt3771256492, Gt38F5890C13, Gt39CAD03032, Gt3A9420DD8E, Gt3CC580499F, Gt3E2A057F33, Gt3E6E18CD57, Gt3EC8B89B94, Gt3FD98F54A5, Gt44F1B6940F, Gt46F5D7703F, Gt484D1ADAFE, Gt4B1BA0C81D, Gt526892A4DC, Gt53D2408A5F, Gt57090094FA, Gt5BE68AF2C7, Gt6463DC73A8, Gt669C528764, Gt6B1336E534, Gt6E9B243B7C, Gt7274F61A0F, Gt74B2AF1CB3, Gt75C1995C88, Gt7600AB7870, Gt7C1C13B292, Gt7D1CD7363A, Gt7D65FF3A10, Gt7FBB1934E8, Gt83D8B3D008, Gt843A1262ED, Gt89824BEACE, Gt8E507C4540, Gt8FB0CF9679, Gt9333E6513D, Gt94B70684B5, Gt98B8C9F262, Gt9D356BAF82, Gt9DF37A5216, Gt9EA902108D, GtA8100D747D, GtA8457965E2, GtAA99FAAC9D, GtADC8DCD962, GtAE3EF932C2, GtAEB382AD1F, GtB0CCEA154C, GtB85E1BC748, GtB91D4D285D, GtBB42F83A45, GtBBFD66E011, GtC063F5D9E0, GtC0FC7B166A, GtC19E8053EB, GtC57121EA56, GtC847E618FA, GtC923FCB2DA, GtCCF6FFA0A0, GtCF587DD386, GtD1AEF07F7D, GtD291A17219, GtDB1482527D, GtDE4B86A990, GtE470919895, GtE528AAE3C6, GtE6006F6F55, GtE83F21B20A, GtEB2FD43D9B, GtF23A2FB97E, GtF3865AEE9A, GtF45E42B273, GtF91FD5FC73, GtFAE59DA275), each discharged by that law.

def Gc465214E502__root__Gc465214E502_root_correct(-h: B.Buf, -o: VarTestStruct_d.Gc465214E502, +s: S.Schema, +es: {s == Spec.Gc465214E502() : S.Schema}, +rep: PRV.rep_Gc465214E502(o, s)) -> RR.roots(PRV.v_Gc465214E502(o), s, [D.bytes(Pair.snd(VarTestStruct_d.Gc465214E502, D.Digest, Pair.snd(B.Buf, VarTestStruct_d.Gc465214E502 & D.Digest, VarTestStruct_h.Gc465214E502_hash_tree_root(h, o))))]):
  PRV.Gc465214E502_root_correct(h, o, s, es, rep)

def Gc56D855869F__root__Gc56D855869F_root_correct(-h: B.Buf, -o: ComplexTestStruct_d.Gc56D855869F, +s: S.Schema, +es: {s == Spec.Gc56D855869F() : S.Schema}, +rep: PRV.rep_Gc56D855869F(o, s)) -> RR.roots(PRV.v_Gc56D855869F(o), s, [D.bytes(Pair.snd(ComplexTestStruct_d.Gc56D855869F, D.Digest, Pair.snd(B.Buf, ComplexTestStruct_d.Gc56D855869F & D.Digest, ComplexTestStruct_h.Gc56D855869F_hash_tree_root(h, o))))]):
  PRV.Gc56D855869F_root_correct(h, o, s, es, rep)

def Gt039DD44FD8__root__Gt039DD44FD8_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt039DD44FD8() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_33_h.Gt039DD44FD8_hash_tree_root(h, o))))]):
  PRV.Gt039DD44FD8_root_correct(h, o, s, es, rep)

def Gt04170D6AA7__root__Gt04170D6AA7_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt04170D6AA7() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_2_h.Gt04170D6AA7_hash_tree_root(h, o))))]):
  PRV.Gt04170D6AA7_root_correct(h, o, s, es, rep)

def Gt0A3B6B4128__root__Gt0A3B6B4128_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt0A3B6B4128() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_513_h.Gt0A3B6B4128_hash_tree_root(h, o))))]):
  PRV.Gt0A3B6B4128_root_correct(h, o, s, es, rep)

def Gt0B1B711C4D__root__Gt0B1B711C4D_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt0B1B711C4D() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_5_h.Gt0B1B711C4D_hash_tree_root(h, o))))]):
  PRV.Gt0B1B711C4D_root_correct(h, o, s, es, rep)

def Gt0B4EF17D71__root__Gt0B4EF17D71_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt0B4EF17D71() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_16_h.Gt0B4EF17D71_hash_tree_root(h, o))))]):
  PRV.Gt0B4EF17D71_root_correct(h, o, s, es, rep)

def Gt10D6F42D74__root__Gt10D6F42D74_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt10D6F42D74() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_513_h.Gt10D6F42D74_hash_tree_root(h, o))))]):
  PRV.Gt10D6F42D74_root_correct(h, o, s, es, rep)

def Gt13AFE546ED__root__Gt13AFE546ED_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt13AFE546ED() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_512_h.Gt13AFE546ED_hash_tree_root(h, o))))]):
  PRV.Gt13AFE546ED_root_correct(h, o, s, es, rep)

def Gt1719057EB7__root__Gt1719057EB7_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt1719057EB7() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_5_h.Gt1719057EB7_hash_tree_root(h, o))))]):
  PRV.Gt1719057EB7_root_correct(h, o, s, es, rep)

def Gt19F04F79B8__root__Gt19F04F79B8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt19F04F79B8() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_3_h.Gt19F04F79B8_hash_tree_root(h, o))))]):
  PRV.Gt19F04F79B8_root_correct(h, o, s, es, rep)

def Gt1C2FA69562__root__Gt1C2FA69562_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt1C2FA69562() : S.Schema}, +rep: PG.rep_pl16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint128_h.Gt1C2FA69562_hash_tree_root(h, o))))]):
  PRV.Gt1C2FA69562_root_correct(h, o, s, es, rep)

def Gt1D9B3E1871__root__Gt1D9B3E1871_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt1D9B3E1871() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_16_h.Gt1D9B3E1871_hash_tree_root(h, o))))]):
  PRV.Gt1D9B3E1871_root_correct(h, o, s, es, rep)

def Gt21E1483EE1__root__Gt21E1483EE1_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt21E1483EE1() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_511_h.Gt21E1483EE1_hash_tree_root(h, o))))]):
  PRV.Gt21E1483EE1_root_correct(h, o, s, es, rep)

def Gt240C147AA2__root__Gt240C147AA2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt240C147AA2() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_4_h.Gt240C147AA2_hash_tree_root(h, o))))]):
  PRV.Gt240C147AA2_root_correct(h, o, s, es, rep)

def Gt274A0B8DC2__root__Gt274A0B8DC2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt274A0B8DC2() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_512_h.Gt274A0B8DC2_hash_tree_root(h, o))))]):
  PRV.Gt274A0B8DC2_root_correct(h, o, s, es, rep)

def Gt28605B5D5C__root__Gt28605B5D5C_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt28605B5D5C() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_512_h.Gt28605B5D5C_hash_tree_root(h, o))))]):
  PRV.Gt28605B5D5C_root_correct(h, o, s, es, rep)

def Gt28ED72E3EF__root__Gt28ED72E3EF_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt28ED72E3EF() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_16_h.Gt28ED72E3EF_hash_tree_root(h, o))))]):
  PRV.Gt28ED72E3EF_root_correct(h, o, s, es, rep)

def Gt2CD118DF5F__root__Gt2CD118DF5F_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt2CD118DF5F() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_513_h.Gt2CD118DF5F_hash_tree_root(h, o))))]):
  PRV.Gt2CD118DF5F_root_correct(h, o, s, es, rep)

def Gt2E7060B297__root__Gt2E7060B297_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt2E7060B297() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_3_h.Gt2E7060B297_hash_tree_root(h, o))))]):
  PRV.Gt2E7060B297_root_correct(h, o, s, es, rep)

def Gt2F34855D3D__root__Gt2F34855D3D_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt2F34855D3D() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_32_h.Gt2F34855D3D_hash_tree_root(h, o))))]):
  PRV.Gt2F34855D3D_root_correct(h, o, s, es, rep)

def Gt2FF8722A75__root__Gt2FF8722A75_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt2FF8722A75() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_512_h.Gt2FF8722A75_hash_tree_root(h, o))))]):
  PRV.Gt2FF8722A75_root_correct(h, o, s, es, rep)

def Gt3429157FEB__root__Gt3429157FEB_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt3429157FEB() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_2_h.Gt3429157FEB_hash_tree_root(h, o))))]):
  PRV.Gt3429157FEB_root_correct(h, o, s, es, rep)

def Gt34AE45611E__root__Gt34AE45611E_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt34AE45611E() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_512_h.Gt34AE45611E_hash_tree_root(h, o))))]):
  PRV.Gt34AE45611E_root_correct(h, o, s, es, rep)

def Gt3771256492__root__Gt3771256492_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt3771256492() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_2_h.Gt3771256492_hash_tree_root(h, o))))]):
  PRV.Gt3771256492_root_correct(h, o, s, es, rep)

def Gt38F5890C13__root__Gt38F5890C13_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt38F5890C13() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_512_h.Gt38F5890C13_hash_tree_root(h, o))))]):
  PRV.Gt38F5890C13_root_correct(h, o, s, es, rep)

def Gt39CAD03032__root__Gt39CAD03032_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt39CAD03032() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_8_h.Gt39CAD03032_hash_tree_root(h, o))))]):
  PRV.Gt39CAD03032_root_correct(h, o, s, es, rep)

def Gt3A9420DD8E__root__Gt3A9420DD8E_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt3A9420DD8E() : S.Schema}, +rep: PG.rep_pl4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint32_h.Gt3A9420DD8E_hash_tree_root(h, o))))]):
  PRV.Gt3A9420DD8E_root_correct(h, o, s, es, rep)

def Gt3CC580499F__root__Gt3CC580499F_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt3CC580499F() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_16_h.Gt3CC580499F_hash_tree_root(h, o))))]):
  PRV.Gt3CC580499F_root_correct(h, o, s, es, rep)

def Gt3E2A057F33__root__Gt3E2A057F33_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt3E2A057F33() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_8_h.Gt3E2A057F33_hash_tree_root(h, o))))]):
  PRV.Gt3E2A057F33_root_correct(h, o, s, es, rep)

def Gt3E6E18CD57__root__Gt3E6E18CD57_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt3E6E18CD57() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_16_h.Gt3E6E18CD57_hash_tree_root(h, o))))]):
  PRV.Gt3E6E18CD57_root_correct(h, o, s, es, rep)

def Gt3EC8B89B94__root__Gt3EC8B89B94_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt3EC8B89B94() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_16_h.Gt3EC8B89B94_hash_tree_root(h, o))))]):
  PRV.Gt3EC8B89B94_root_correct(h, o, s, es, rep)

def Gt3FD98F54A5__root__Gt3FD98F54A5_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt3FD98F54A5() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_1_h.Gt3FD98F54A5_hash_tree_root(h, o))))]):
  PRV.Gt3FD98F54A5_root_correct(h, o, s, es, rep)

def Gt44F1B6940F__root__Gt44F1B6940F_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt44F1B6940F() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_513_h.Gt44F1B6940F_hash_tree_root(h, o))))]):
  PRV.Gt44F1B6940F_root_correct(h, o, s, es, rep)

def Gt46F5D7703F__root__Gt46F5D7703F_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt46F5D7703F() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_4_h.Gt46F5D7703F_hash_tree_root(h, o))))]):
  PRV.Gt46F5D7703F_root_correct(h, o, s, es, rep)

def Gt484D1ADAFE__root__Gt484D1ADAFE_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt484D1ADAFE() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_4_h.Gt484D1ADAFE_hash_tree_root(h, o))))]):
  PRV.Gt484D1ADAFE_root_correct(h, o, s, es, rep)

def Gt4B1BA0C81D__root__Gt4B1BA0C81D_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt4B1BA0C81D() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_31_h.Gt4B1BA0C81D_hash_tree_root(h, o))))]):
  PRV.Gt4B1BA0C81D_root_correct(h, o, s, es, rep)

def Gt526892A4DC__root__Gt526892A4DC_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt526892A4DC() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_8_h.Gt526892A4DC_hash_tree_root(h, o))))]):
  PRV.Gt526892A4DC_root_correct(h, o, s, es, rep)

def Gt53D2408A5F__root__Gt53D2408A5F_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt53D2408A5F() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_513_h.Gt53D2408A5F_hash_tree_root(h, o))))]):
  PRV.Gt53D2408A5F_root_correct(h, o, s, es, rep)

def Gt57090094FA__root__Gt57090094FA_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt57090094FA() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_3_h.Gt57090094FA_hash_tree_root(h, o))))]):
  PRV.Gt57090094FA_root_correct(h, o, s, es, rep)

def Gt5BE68AF2C7__root__Gt5BE68AF2C7_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt5BE68AF2C7() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_513_h.Gt5BE68AF2C7_hash_tree_root(h, o))))]):
  PRV.Gt5BE68AF2C7_root_correct(h, o, s, es, rep)

def Gt6463DC73A8__root__Gt6463DC73A8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt6463DC73A8() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_4_h.Gt6463DC73A8_hash_tree_root(h, o))))]):
  PRV.Gt6463DC73A8_root_correct(h, o, s, es, rep)

def Gt669C528764__root__Gt669C528764_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt669C528764() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_1_h.Gt669C528764_hash_tree_root(h, o))))]):
  PRV.Gt669C528764_root_correct(h, o, s, es, rep)

def Gt6B1336E534__root__Gt6B1336E534_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt6B1336E534() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_31_h.Gt6B1336E534_hash_tree_root(h, o))))]):
  PRV.Gt6B1336E534_root_correct(h, o, s, es, rep)

def Gt6E9B243B7C__root__Gt6E9B243B7C_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt6E9B243B7C() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_31_h.Gt6E9B243B7C_hash_tree_root(h, o))))]):
  PRV.Gt6E9B243B7C_root_correct(h, o, s, es, rep)

def Gt7274F61A0F__root__Gt7274F61A0F_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt7274F61A0F() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_512_h.Gt7274F61A0F_hash_tree_root(h, o))))]):
  PRV.Gt7274F61A0F_root_correct(h, o, s, es, rep)

def Gt74B2AF1CB3__root__Gt74B2AF1CB3_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt74B2AF1CB3() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_4_h.Gt74B2AF1CB3_hash_tree_root(h, o))))]):
  PRV.Gt74B2AF1CB3_root_correct(h, o, s, es, rep)

def Gt75C1995C88__root__Gt75C1995C88_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt75C1995C88() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_4_h.Gt75C1995C88_hash_tree_root(h, o))))]):
  PRV.Gt75C1995C88_root_correct(h, o, s, es, rep)

def Gt7600AB7870__root__Gt7600AB7870_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt7600AB7870() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_3_h.Gt7600AB7870_hash_tree_root(h, o))))]):
  PRV.Gt7600AB7870_root_correct(h, o, s, es, rep)

def Gt7C1C13B292__root__Gt7C1C13B292_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt7C1C13B292() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_16_h.Gt7C1C13B292_hash_tree_root(h, o))))]):
  PRV.Gt7C1C13B292_root_correct(h, o, s, es, rep)

def Gt7D1CD7363A__root__Gt7D1CD7363A_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt7D1CD7363A() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_31_h.Gt7D1CD7363A_hash_tree_root(h, o))))]):
  PRV.Gt7D1CD7363A_root_correct(h, o, s, es, rep)

def Gt7D65FF3A10__root__Gt7D65FF3A10_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt7D65FF3A10() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_2_h.Gt7D65FF3A10_hash_tree_root(h, o))))]):
  PRV.Gt7D65FF3A10_root_correct(h, o, s, es, rep)

def Gt7FBB1934E8__root__Gt7FBB1934E8_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt7FBB1934E8() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_5_h.Gt7FBB1934E8_hash_tree_root(h, o))))]):
  PRV.Gt7FBB1934E8_root_correct(h, o, s, es, rep)

def Gt83D8B3D008__root__Gt83D8B3D008_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt83D8B3D008() : S.Schema}, +rep: PG.rep_plb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_bool_h.Gt83D8B3D008_hash_tree_root(h, o))))]):
  PRV.Gt83D8B3D008_root_correct(h, o, s, es, rep)

def Gt843A1262ED__root__Gt843A1262ED_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt843A1262ED() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_512_h.Gt843A1262ED_hash_tree_root(h, o))))]):
  PRV.Gt843A1262ED_root_correct(h, o, s, es, rep)

def Gt89824BEACE__root__Gt89824BEACE_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt89824BEACE() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_5_h.Gt89824BEACE_hash_tree_root(h, o))))]):
  PRV.Gt89824BEACE_root_correct(h, o, s, es, rep)

def Gt8E507C4540__root__Gt8E507C4540_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt8E507C4540() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_3_h.Gt8E507C4540_hash_tree_root(h, o))))]):
  PRV.Gt8E507C4540_root_correct(h, o, s, es, rep)

def Gt8FB0CF9679__root__Gt8FB0CF9679_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt8FB0CF9679() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_5_h.Gt8FB0CF9679_hash_tree_root(h, o))))]):
  PRV.Gt8FB0CF9679_root_correct(h, o, s, es, rep)

def Gt9333E6513D__root__Gt9333E6513D_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt9333E6513D() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_31_h.Gt9333E6513D_hash_tree_root(h, o))))]):
  PRV.Gt9333E6513D_root_correct(h, o, s, es, rep)

def Gt94B70684B5__root__Gt94B70684B5_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt94B70684B5() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_1_h.Gt94B70684B5_hash_tree_root(h, o))))]):
  PRV.Gt94B70684B5_root_correct(h, o, s, es, rep)

def Gt98B8C9F262__root__Gt98B8C9F262_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt98B8C9F262() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_6_h.Gt98B8C9F262_hash_tree_root(h, o))))]):
  PRV.Gt98B8C9F262_root_correct(h, o, s, es, rep)

def Gt9D356BAF82__root__Gt9D356BAF82_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.Gt9D356BAF82() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_9_h.Gt9D356BAF82_hash_tree_root(h, o))))]):
  PRV.Gt9D356BAF82_root_correct(h, o, s, es, rep)

def Gt9DF37A5216__root__Gt9DF37A5216_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt9DF37A5216() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_31_h.Gt9DF37A5216_hash_tree_root(h, o))))]):
  PRV.Gt9DF37A5216_root_correct(h, o, s, es, rep)

def Gt9EA902108D__root__Gt9EA902108D_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Gt9EA902108D() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_513_h.Gt9EA902108D_hash_tree_root(h, o))))]):
  PRV.Gt9EA902108D_root_correct(h, o, s, es, rep)

def GtA8100D747D__root__GtA8100D747D_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtA8100D747D() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_8_h.GtA8100D747D_hash_tree_root(h, o))))]):
  PRV.GtA8100D747D_root_correct(h, o, s, es, rep)

def GtA8457965E2__root__GtA8457965E2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtA8457965E2() : S.Schema}, +rep: PG.rep_pl32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint256_h.GtA8457965E2_hash_tree_root(h, o))))]):
  PRV.GtA8457965E2_root_correct(h, o, s, es, rep)

def GtAA99FAAC9D__root__GtAA99FAAC9D_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.GtAA99FAAC9D() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_17_h.GtAA99FAAC9D_hash_tree_root(h, o))))]):
  PRV.GtAA99FAAC9D_root_correct(h, o, s, es, rep)

def GtADC8DCD962__root__GtADC8DCD962_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtADC8DCD962() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_1_h.GtADC8DCD962_hash_tree_root(h, o))))]):
  PRV.GtADC8DCD962_root_correct(h, o, s, es, rep)

def GtAE3EF932C2__root__GtAE3EF932C2_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtAE3EF932C2() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_1_h.GtAE3EF932C2_hash_tree_root(h, o))))]):
  PRV.GtAE3EF932C2_root_correct(h, o, s, es, rep)

def GtAEB382AD1F__root__GtAEB382AD1F_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtAEB382AD1F() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_16_h.GtAEB382AD1F_hash_tree_root(h, o))))]):
  PRV.GtAEB382AD1F_root_correct(h, o, s, es, rep)

def GtB0CCEA154C__root__GtB0CCEA154C_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtB0CCEA154C() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_4_h.GtB0CCEA154C_hash_tree_root(h, o))))]):
  PRV.GtB0CCEA154C_root_correct(h, o, s, es, rep)

def GtB85E1BC748__root__GtB85E1BC748_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtB85E1BC748() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_1_h.GtB85E1BC748_hash_tree_root(h, o))))]):
  PRV.GtB85E1BC748_root_correct(h, o, s, es, rep)

def GtB91D4D285D__root__GtB91D4D285D_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtB91D4D285D() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_2_h.GtB91D4D285D_hash_tree_root(h, o))))]):
  PRV.GtB91D4D285D_root_correct(h, o, s, es, rep)

def GtBB42F83A45__root__GtBB42F83A45_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtBB42F83A45() : S.Schema}, +rep: PK.rep_v16(o, s)) -> RR.roots(PK.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_5_h.GtBB42F83A45_hash_tree_root(h, o))))]):
  PRV.GtBB42F83A45_root_correct(h, o, s, es, rep)

def GtBBFD66E011__root__GtBBFD66E011_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtBBFD66E011() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_1_h.GtBBFD66E011_hash_tree_root(h, o))))]):
  PRV.GtBBFD66E011_root_correct(h, o, s, es, rep)

def GtC063F5D9E0__root__GtC063F5D9E0_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.GtC063F5D9E0() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_7_h.GtC063F5D9E0_hash_tree_root(h, o))))]):
  PRV.GtC063F5D9E0_root_correct(h, o, s, es, rep)

def GtC0FC7B166A__root__GtC0FC7B166A_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtC0FC7B166A() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_31_h.GtC0FC7B166A_hash_tree_root(h, o))))]):
  PRV.GtC0FC7B166A_root_correct(h, o, s, es, rep)

def GtC19E8053EB__root__GtC19E8053EB_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtC19E8053EB() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_3_h.GtC19E8053EB_hash_tree_root(h, o))))]):
  PRV.GtC19E8053EB_root_correct(h, o, s, es, rep)

def GtC57121EA56__root__GtC57121EA56_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtC57121EA56() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_4_h.GtC57121EA56_hash_tree_root(h, o))))]):
  PRV.GtC57121EA56_root_correct(h, o, s, es, rep)

def GtC847E618FA__root__GtC847E618FA_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.GtC847E618FA() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_3_h.GtC847E618FA_hash_tree_root(h, o))))]):
  PRV.GtC847E618FA_root_correct(h, o, s, es, rep)

def GtC923FCB2DA__root__GtC923FCB2DA_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtC923FCB2DA() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_2_h.GtC923FCB2DA_hash_tree_root(h, o))))]):
  PRV.GtC923FCB2DA_root_correct(h, o, s, es, rep)

def GtCCF6FFA0A0__root__GtCCF6FFA0A0_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtCCF6FFA0A0() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_8_h.GtCCF6FFA0A0_hash_tree_root(h, o))))]):
  PRV.GtCCF6FFA0A0_root_correct(h, o, s, es, rep)

def GtCF587DD386__root__GtCF587DD386_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.GtCF587DD386() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_2_h.GtCF587DD386_hash_tree_root(h, o))))]):
  PRV.GtCF587DD386_root_correct(h, o, s, es, rep)

def GtD1AEF07F7D__root__GtD1AEF07F7D_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtD1AEF07F7D() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_3_h.GtD1AEF07F7D_hash_tree_root(h, o))))]):
  PRV.GtD1AEF07F7D_root_correct(h, o, s, es, rep)

def GtD291A17219__root__GtD291A17219_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.GtD291A17219() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_8_h.GtD291A17219_hash_tree_root(h, o))))]):
  PRV.GtD291A17219_root_correct(h, o, s, es, rep)

def GtDB1482527D__root__GtDB1482527D_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.GtDB1482527D() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_15_h.GtDB1482527D_hash_tree_root(h, o))))]):
  PRV.GtDB1482527D_root_correct(h, o, s, es, rep)

def GtDE4B86A990__root__GtDE4B86A990_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtDE4B86A990() : S.Schema}, +rep: PG.rep_pl1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint8_h.GtDE4B86A990_hash_tree_root(h, o))))]):
  PRV.GtDE4B86A990_root_correct(h, o, s, es, rep)

def GtE470919895__root__GtE470919895_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtE470919895() : S.Schema}, +rep: PK.rep_v8(o, s)) -> RR.roots(PK.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_8_h.GtE470919895_hash_tree_root(h, o))))]):
  PRV.GtE470919895_root_correct(h, o, s, es, rep)

def GtE528AAE3C6__root__GtE528AAE3C6_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtE528AAE3C6() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_31_h.GtE528AAE3C6_hash_tree_root(h, o))))]):
  PRV.GtE528AAE3C6_root_correct(h, o, s, es, rep)

def GtE6006F6F55__root__GtE6006F6F55_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtE6006F6F55() : S.Schema}, +rep: PB.rep_v2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_1_h.GtE6006F6F55_hash_tree_root(h, o))))]):
  PRV.GtE6006F6F55_root_correct(h, o, s, es, rep)

def GtE83F21B20A__root__GtE83F21B20A_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtE83F21B20A() : S.Schema}, +rep: PG.rep_pl8(o, s)) -> RR.roots(UL.uview(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint64_h.GtE83F21B20A_hash_tree_root(h, o))))]):
  PRV.GtE83F21B20A_root_correct(h, o, s, es, rep)

def GtEB2FD43D9B__root__GtEB2FD43D9B_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtEB2FD43D9B() : S.Schema}, +rep: PB.rep_vb(o, s)) -> RR.roots(PB.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_513_h.GtEB2FD43D9B_hash_tree_root(h, o))))]):
  PRV.GtEB2FD43D9B_root_correct(h, o, s, es, rep)

def GtF23A2FB97E__root__GtF23A2FB97E_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtF23A2FB97E() : S.Schema}, +rep: PG.rep_pl2(o, s)) -> RR.roots(PB.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint16_h.GtF23A2FB97E_hash_tree_root(h, o))))]):
  PRV.GtF23A2FB97E_root_correct(h, o, s, es, rep)

def GtF3865AEE9A__root__GtF3865AEE9A_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtF3865AEE9A() : S.Schema}, +rep: PB.rep_v1(o, s)) -> RR.roots(PB.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_5_h.GtF3865AEE9A_hash_tree_root(h, o))))]):
  PRV.GtF3865AEE9A_root_correct(h, o, s, es, rep)

def GtF45E42B273__root__GtF45E42B273_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtF45E42B273() : S.Schema}, +rep: PK.rep_v4(o, s)) -> RR.roots(PK.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_2_h.GtF45E42B273_hash_tree_root(h, o))))]):
  PRV.GtF45E42B273_root_correct(h, o, s, es, rep)

def GtF91FD5FC73__root__GtF91FD5FC73_root_correct(-h: B.Buf, -o: O.Bits, +s: S.Schema, +es: {s == Spec.GtF91FD5FC73() : S.Schema}, +rep: BO.rep_bits(o, s)) -> RR.roots(S.BitsValue{BO.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_5_h.GtF91FD5FC73_hash_tree_root(h, o))))]):
  PRV.GtF91FD5FC73_root_correct(h, o, s, es, rep)

def GtFAE59DA275__root__GtFAE59DA275_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.GtFAE59DA275() : S.Schema}, +rep: PK.rep_v32(o, s)) -> RR.roots(PK.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_8_h.GtFAE59DA275_hash_tree_root(h, o))))]):
  PRV.GtFAE59DA275_root_correct(h, o, s, es, rep)

