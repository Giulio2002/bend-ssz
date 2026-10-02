import Base
import ../compact/found.bend as F
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/uint8_hashtreeroot_generated.bend as uint8_h
import ../../types/proglist_uint64_hashtreeroot_generated.bend as proglist_uint64_h
import ../../types/uint16_hashtreeroot_generated.bend as uint16_h
import ../../types/list_uint16_1024_hashtreeroot_generated.bend as list_uint16_1024_h
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
import ../../types/FixedTestStruct_def_generated.bend as FixedTestStruct_d
import ../../types/FixedTestStruct_hashtreeroot_generated.bend as FixedTestStruct_h
import ../../types/list_uint16_128_hashtreeroot_generated.bend as list_uint16_128_h
import ../../types/bytelist_256_hashtreeroot_generated.bend as bytelist_256_h
import ../../types/vec_FixedTestStruct_4_def_generated.bend as vec_FixedTestStruct_4_d
import ../../types/vec_FixedTestStruct_4_hashtreeroot_generated.bend as vec_FixedTestStruct_4_h
import ../../types/vec_VarTestStruct_2_def_generated.bend as vec_VarTestStruct_2_d
import ../../types/vec_VarTestStruct_2_hashtreeroot_generated.bend as vec_VarTestStruct_2_h
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
import ./cform.bend as CF
import ./amap.bend as AM
import ../../spec/root_relation.bend as RR
import ./generic_specs.bend as Spec
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./mtree_defs.bend as MD
import ./root_support.bend as RS
import ./words_obj.bend as WO
import ./words_obj_light.bend as WO_L
import ./list_obj.bend as LO
import ./list_obj_light.bend as LO_L
import ./pv_obj_light.bend as PV
import ./bitlist_obj.bend as BO
import ./bitlist_obj_light.bend as BO_L
import ./cells.bend as CE
import ./cells_light.bend as CE_L
import ./obj_support.bend as OS
import ./root_gnames.bend as RN
import ./root_gnames_light.bend as RN_L
import ./ulist_obj.bend as UL
import ./ulist_obj_light.bend as UL_L
import ./packed_obj.bend as PK
import ./packed_obj_light.bend as PK_L
import ./packed_bytes.bend as PB
import ./packed_bytes_light.bend as PB_L
import ./prog_list.bend as PG
import ./prog_list_light.bend as PG_L
import ./blist_obj.bend as BLI
import ./blist_obj_light.bend as BLI_L
import ./elems48.bend as E48
import ./elems48_light.bend as E48_L
import ./xlist_support.bend as XS
import ./mtree_run.bend as MR
import ../../spec/codec.bend as Codec
import ../../spec/limits.bend as Lim
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../../spec/byte_list.bend as BL
import ./root_gtypes_light.bend as LV

# GENERATED by generic_form_root_laws (codegen: via container_root_laws.py). Do not edit.
# Root laws of the generic forms (Type-kind shapes), as proofs/obj/root_types.bend.

# ---- digest witnesses of byte storage fields (values from the invariant) ----
def wdc_wdig(+hl: Nat, -o: O.Words, +d: Nat, +c: CF.CF(o)) -> OS.DW(WO_L.wdig(hl, o, d)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(WO_L.wdig(hl, _, d))
  (WO_L.wdig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})
def wdc_ldig(+hl: Nat, -o: O.Words, +d: Nat, +c: CF.CF(o)) -> OS.DW(LO.ldig(hl, o, d)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(LO.ldig(hl, _, d))
  (LO.ldig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})
def wdc_udig(+hl: Nat, -o: O.Words, +d: Nat, +c: CF.CF(o)) -> OS.DW(UL.udig(hl, o, d)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(UL.udig(hl, _, d))
  (UL.udig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})
def wd_bv(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: WO_L.rep_bv(o, s)) -> OS.DW(WO_L.wdig(hl, o, d)):
  (+w, +z) = r
  wdc_wdig(hl, o, d, CF.cf1(o, w))
def wd_pv(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: PV.rep_pv(o, s)) -> OS.DW(WO_L.wdig(hl, o, d)):
  (+w, +z) = r
  wdc_wdig(hl, o, d, CF.cfv(o, w))
def wd_bl(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: LO_L.rep_bl(o, s)) -> OS.DW(LO.ldig(hl, o, d)):
  (+w, +z) = r
  wdc_ldig(hl, o, d, CF.cfl(o, w))
def wd_ul(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: UL_L.rep_ul(o, s)) -> OS.DW(UL.udig(hl, o, d)):
  (+w, +z) = r
  wdc_udig(hl, o, d, CF.cfl(o, w))
def wd_ev(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: E48_L.rep_ev(o, s)) -> OS.DW(E48.edig(hl, o, d)):
  (+w, +z) = r
  (+t, +a) = w
  (+dw, +b) = a
  (+N, +c) = b
  (+ce, +y) = c
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(E48.edig(hl, _, d))
  (E48.edig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})
def wd_el(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: E48_L.rep_el(o, s)) -> OS.DW(E48.ldig(hl, o, d)):
  (+w, +z) = r
  (+t, +a) = w
  (+dw, +b) = a
  (+N, +c) = b
  (+ce, +y) = c
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(E48.ldig(hl, _, d))
  (E48.ldig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})

def wd_cl(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: CE_L.rep_el(o, s)) -> OS.DW(CE.ldig(hl, o, d)):
  (+w, +z) = r
  (+t, +a) = w
  (+dw, +b) = a
  (+N, +c) = b
  (+ce, +y) = c
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(CE.ldig(hl, _, d))
  (CE.ldig(hl, O.Words{F.array__thaw(U32, t), N}, d), {==})

# A container or byte list schema is composite: no basic size.
def bs_cont(+E: S.Schema, +k: {SH.is_Container(E) == True{} : Bool}) -> {RR.basic_size(E) == None{} : Maybe<&2, Nat>}:
  %Equal.sym(S.Schema, E, S.Container{SH.Container_names(E), SH.Container_fields(E)}, SH.Container_shape(E, k)) : {RR.basic_size(_) == None{} : Maybe<&2, Nat>}
  {==}
def bs_blist(+E: S.Schema, +k: {SH.is_ByteList(E) == True{} : Bool}) -> {RR.basic_size(E) == None{} : Maybe<&2, Nat>}:
  %Equal.sym(S.Schema, E, S.ByteList{SH.ByteList_limit(E)}, SH.ByteList_shape(E, k)) : {RR.basic_size(_) == None{} : Maybe<&2, Nat>}
  {==}

def wdc_bdig(+hl: Nat, -o: O.Words, +d: Nat, +sh: Nat, +c: CF.CF(o)) -> OS.DW(BLI.bdig(hl, o, d, sh)):
  (+t, +c1) = c
  (+N, +ce) = c1
  %Equal.sym(O.Words, o, O.Words{F.array__thaw(U32, t), N}, ce) : OS.DW(BLI.bdig(hl, _, d, sh))
  (BLI.bdig(hl, O.Words{F.array__thaw(U32, t), N}, d, sh), {==})
def wd_l2(+hl: Nat, -o: O.Words, +s: S.Schema, +d: Nat, +r: BLI_L.rep_l2(o, s)) -> OS.DW(BLI.bdig(hl, o, d, 1n)):
  wdc_bdig(hl, o, d, 1n, CF.cfl(o, BLI_L.rep_wf2(o, s, r)))

def d_VarTestStruct(+hl: Nat, o: VarTestStruct_d.VarTestStruct) -> D.Digest:
  match o:
    case VarTestStruct_d.VarTestStruct{+x0, x1, +x2}: MD.rtree(2n, True{}, hl, [RN.d_u16(hl, x0), BLI.bdig(hl, x1, 6n, 1n), RN.d_u8(hl, x2)], 0n)
def ok_VarTestStruct(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))))))
def okc_VarTestStruct(+s: S.Schema, +dv: OS.DV, +ok: {ok_VarTestStruct(s, dv) == True{} : Bool}) -> {SH.is_Container(s) == True{} : Bool}: DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))))), ok)
def eqs_VarTestStruct(+s: S.Schema) -> Data: DK.P2({SH.Chain_head(SH.Container_fields(s)) == S.Unsigned{P.U16{}} : S.Schema}, {SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))) == S.Unsigned{P.U8{}} : S.Schema})
def fsh_VarTestStruct(+s: S.Schema, +dv: OS.DV, +ok: {ok_VarTestStruct(s, dv) == True{} : Bool}) -> {SH.Container_fields(s) == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}} : S.Schema}:
  +k0 = DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))))), ok)
  +r1 = DK.and_r(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))))), ok)
  +k1 = DK.and_l(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n)))), r1)
  +r2 = DK.and_r(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n)))), r1)
  +k2 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))), r2)
  +r3 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))), r2)
  +k3 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n)), r3)
  +r4 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n)), r3)
  +k4 = DK.and_l(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n), r4)
  +r5 = DK.and_r(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n), r4)
  %Equal.sym(S.Schema, SH.Container_fields(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), SH.Chain_tail(SH.Container_fields(s))}, SH.Chain_shape(SH.Container_fields(s), k1)) :
    {_ == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))}, SH.Chain_shape(SH.Chain_tail(SH.Container_fields(s)), k2)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), _} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))}, SH.Chain_shape(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))), k3)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), _}} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}, SH.End_shape(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), k4)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), _}}} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}} : S.Schema}
  {==}
def st_VarTestStruct(+hl: Nat, -h: B.Buf, -o: VarTestStruct_d.VarTestStruct, +seg: U32, +s: S.Schema, +rep: LV.rep_VarTestStruct(o, s))
    -> {VarTestStruct_h.VarTestStruct_root(hl, h, o, seg) == (h, (o, d_VarTestStruct(hl, o))) : B.Buf & (VarTestStruct_d.VarTestStruct & D.Digest)}:
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  %Equal.sym(VarTestStruct_d.VarTestStruct, o, VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}, eo) :
    {VarTestStruct_h.VarTestStruct_root(hl, h, _, seg) == (h, (_, d_VarTestStruct(hl, _))) : B.Buf & (VarTestStruct_d.VarTestStruct & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, uint16_h.u16_root(hl, h, x0, seg), (h, RN.d_u16(hl, x0)), RN.st_u16(hl, h, x0, seg)) :
    {VarTestStruct_h.VarTestStruct_rt0(hl, seg, x0, LV.pj_VarTestStruct_1(o), x2, _) == (h, (VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}, d_VarTestStruct(hl, VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}))) : B.Buf & (VarTestStruct_d.VarTestStruct & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), list_uint16_1024_h.l1024_u16_root(hl, h, LV.pj_VarTestStruct_1(o), seg), (h, (LV.pj_VarTestStruct_1(o), BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n))), BLI.bl_st(hl, h, LV.pj_VarTestStruct_1(o), 6, seg, 6n, 1n, BLI_L.rep_wf2(LV.pj_VarTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), rp1), {==})) :
    {VarTestStruct_h.VarTestStruct_rt1(hl, seg, x0, x2, RN.d_u16(hl, x0), _) == (h, (VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}, d_VarTestStruct(hl, VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}))) : B.Buf & (VarTestStruct_d.VarTestStruct & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, uint8_h.u8_root(hl, h, x2, seg), (h, RN.d_u8(hl, x2)), RN.st_u8(hl, h, x2, seg)) :
    {VarTestStruct_h.VarTestStruct_rt2(hl, seg, x0, LV.pj_VarTestStruct_1(o), x2, RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n), _) == (h, (VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}, d_VarTestStruct(hl, VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}))) : B.Buf & (VarTestStruct_d.VarTestStruct & D.Digest)}
  {==}
def wd_VarTestStruct(+hl: Nat, -o: VarTestStruct_d.VarTestStruct, +s: S.Schema, +rep: LV.rep_VarTestStruct(o, s)) -> OS.DW(d_VarTestStruct(hl, o)):
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  +dd1 = OS.dwv(BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n), wd_l2(hl, LV.pj_VarTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, rp1))
  +de1 = OS.dwe(BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n), wd_l2(hl, LV.pj_VarTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, rp1))
  %Equal.sym(VarTestStruct_d.VarTestStruct, o, VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}, eo) : OS.DW(d_VarTestStruct(hl, _))
  %Equal.sym(D.Digest, BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n), dd1, de1) :
    OS.DW(MD.rtree(2n, True{}, hl, [RN.d_u16(hl, x0), _, RN.d_u8(hl, x2)], 0n))
  (MD.rtree(2n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2)], 0n), {==})
def rs_VarTestStruct(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: VarTestStruct_d.VarTestStruct, +s: S.Schema, +rep: LV.rep_VarTestStruct(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}, +ok: {ok_VarTestStruct(s, dv) == True{} : Bool}, +ev: eqs_VarTestStruct(s))
    -> RR.roots(LV.v_VarTestStruct(o), s, [D.bytes(d_VarTestStruct(hl, o))]):
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  (+qe0, +qv0) = ev
  +dd1 = OS.dwv(BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n), wd_l2(hl, LV.pj_VarTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, rp1))
  +de1 = OS.dwe(BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n), wd_l2(hl, LV.pj_VarTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, rp1))
  +k0 = DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))))), ok)
  +r1 = DK.and_r(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))))), ok)
  +k1 = DK.and_l(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n)))), r1)
  +r2 = DK.and_r(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n)))), r1)
  +k2 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))), r2)
  +r3 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))), r2)
  +k3 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n)), r3)
  +r4 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n)), r3)
  +k4 = DK.and_l(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n), r4)
  +r5 = DK.and_r(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n), r4)
  %Equal.sym(VarTestStruct_d.VarTestStruct, o, VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}, eo) : RR.roots(LV.v_VarTestStruct(_), s, [D.bytes(d_VarTestStruct(hl, _))])
  %Equal.sym(S.Schema, s, S.Container{SH.Container_names(s), SH.Container_fields(s)}, SH.Container_shape(s, k0)) :
    RR.roots(LV.v_VarTestStruct(VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}), _, [D.bytes(d_VarTestStruct(hl, VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}))])
  %Equal.sym(S.Schema, SH.Container_fields(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}}, fsh_VarTestStruct(s, dv, ok)) :
    RR.roots(LV.v_VarTestStruct(VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}), S.Container{SH.Container_names(s), _}, [D.bytes(d_VarTestStruct(hl, VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}))])
  %Equal.sym(D.Digest, BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n), dd1, de1) :
    RR.roots(LV.v_VarTestStruct(VarTestStruct_d.VarTestStruct{x0, LV.pj_VarTestStruct_1(o), x2}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}}}, [D.bytes(MD.rtree(2n, True{}, hl, [RN.d_u16(hl, x0), _, RN.d_u8(hl, x2)], 0n))])
  (MD.bytes_list([RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2)]), (([D.bytes(RN.d_u16(hl, x0))], (MD.bytes_list([dd1, RN.d_u8(hl, x2)]), (OS.transport(RN_L.v_u16(x0), SH.Chain_head(SH.Container_fields(s)), S.Unsigned{P.U16{}}, [D.bytes(RN.d_u16(hl, x0))], qe0, RN.rs_u16(hl, ehl, x0, rp0)), (([D.bytes(dd1)], (MD.bytes_list([RN.d_u8(hl, x2)]), (OS.dtrans(PB_L.vview2(LV.pj_VarTestStruct_1(o)), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), dd1, BLI.bdig(hl, LV.pj_VarTestStruct_1(o), 6n, 1n), de1, BLI.l2_rs(hl, ehl, h, LV.pj_VarTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, 6, 0, rp1, r5, {==}, {==})), (([D.bytes(RN.d_u8(hl, x2))], (MD.bytes_list([]), (OS.transport(RN_L.v_u8(x2), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Unsigned{P.U8{}}, [D.bytes(RN.d_u8(hl, x2))], qv0, RN.rs_u8(hl, ehl, x2, q4)), ({==}, {==})))), {==})))), {==})))),
    RS.aggregate_digests(3n, 2n, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2)], {==}, {==}, {==}, ehl)))

# ---- vectors of containers: the sequence relation without a length ----
def vec_none(-items: S.Value, -E: S.Schema, -L: Nat, -outs: +List<+List<U32>>, +e: {RR.basic_size(E) == None{} : Maybe<&2, Nat>},
    p: RR.sequence(None{}, RR.basic_bytes(items, E), c => RR.roots(items, S.Repeat{E}, c), L, False{}, None{}, outs))
    -> RR.roots(S.Sequence{items}, S.Vector{E, L}, outs):
  %Equal.sym(Maybe<&2, Nat>, RR.basic_size(E), None{}, e) : RR.sequence(_, RR.basic_bytes(items, E), c => RR.roots(items, S.Repeat{E}, c), L, False{}, None{}, outs)
  p
law veq_le:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_eq(a, b) == True{} : Bool}
  {Nat.is_le(a, b) == True{} : Bool}
def veq_le(a, b, e):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: Empty.absurd({Nat.is_le(0n, 1n+q) == True{} : Bool}, MD.false_true(e))
    case 1n+p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, MD.false_true(e))
    case 1n+ +p 1n+ +q: veq_le(p, q, e)

def xl_v4_FixedTestStruct(k: Nat, +W: List<&2, FixedTestStruct_d.FixedTestStruct>, +i: Nat, +hl: Nat) -> List<&2, D.Digest>:
  match k:
    case 0n: []
    case 1n+q: RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(W, i)) <> xl_v4_FixedTestStruct(q, W, 1n+i, hl)
law xlen_v4_FixedTestStruct:
  for +k: Nat
  for +W: List<&2, FixedTestStruct_d.FixedTestStruct>
  for +i: Nat
  for +hl: Nat
  {MD.dlen(xl_v4_FixedTestStruct(k, W, i, hl)) == k : Nat}
def xlen_v4_FixedTestStruct(k, W, i, hl):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %xlen_v4_FixedTestStruct(q, W, 1n+i, hl) : {1n+MD.dlen(xl_v4_FixedTestStruct(q, W, 1n+i, hl)) == 1n+_ : Nat}
      {==}
law xat_at_v4_FixedTestStruct:
  for +s: Nat
  for +k: Nat
  for +W: List<&2, FixedTestStruct_d.FixedTestStruct>
  for +i: Nat
  for +hl: Nat
  for +e: {Nat.is_lt(s, k) == True{} : Bool}
  {MD.dhead(MD.ddrop(s, xl_v4_FixedTestStruct(k, W, i, hl))) == RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(W, Nat.add(s, i))) : D.Digest}
def xat_at_v4_FixedTestStruct(s, k, W, i, hl, e):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(0n, xl_v4_FixedTestStruct(0n, W, i, hl))) == RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(W, Nat.add(0n, i))) : D.Digest}, MD.false_true(e))
        case 1n+q: {==}
    case 1n+ +p1:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(1n+p1, xl_v4_FixedTestStruct(0n, W, i, hl))) == RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(W, Nat.add(1n+p1, i))) : D.Digest}, MD.false_true(e))
        case 1n+ +q:
          %MR.add_succ(p1, i) : {MD.dhead(MD.ddrop(p1, xl_v4_FixedTestStruct(q, W, 1n+i, hl))) == RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(W, _)) : D.Digest}
          xat_at_v4_FixedTestStruct(p1, q, W, 1n+i, hl, e)
law xroots_v4_FixedTestStruct:
  for +k: Nat
  for +W: List<&2, FixedTestStruct_d.FixedTestStruct>
  for +i: Nat
  for +hl: Nat
  for +ehl: {hl == 64n : Nat}
  for +er: LV.ereps_v4_FixedTestStruct(k, W, i)
  RR.roots(LV.xi_v4_FixedTestStruct(k, W, i), S.Repeat{S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}}, MD.bytes_list(xl_v4_FixedTestStruct(k, W, i, hl)))
def xroots_v4_FixedTestStruct(k, W, i, hl, ehl, er):
  match k:
    case 0n: {==}
    case 1n+ +q:
      (+r0, +rs) = er
      ([D.bytes(RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(W, i)))], (MD.bytes_list(xl_v4_FixedTestStruct(q, W, 1n+i, hl)), (RN.rs_FixedTestStruct(hl, ehl, LV.xat_v4_FixedTestStruct(W, i), r0), (xroots_v4_FixedTestStruct(q, W, 1n+i, hl, ehl, rs), {==}))))
law xcount_v4_FixedTestStruct:
  for +k: Nat
  for +W: List<&2, FixedTestStruct_d.FixedTestStruct>
  for +i: Nat
  {Codec.count(LV.xi_v4_FixedTestStruct(k, W, i)) == k : Nat}
def xcount_v4_FixedTestStruct(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Codec.count(LV.xi_v4_FixedTestStruct(q, W, 1n+i)), q, xcount_v4_FixedTestStruct(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}
law xph1_v4_FixedTestStruct:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +seg: U32
  for +v: Nat
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for -ws: Array<FixedTestStruct_d.FixedTestStruct>
  for +dl: D.Digest
  {vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(d, 1n, b, hl, seg, v, s, n, (h, (ws, dl))) == vec_FixedTestStruct_4_h.v4_FixedTestStruct_mj(hl, dl, vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(d, 0n, b, hl, seg, v, s, n, (h, (ws, D.zero())))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
def xph1_v4_FixedTestStruct(d, b, hl, seg, v, s, n, h, ws, dl):
  match d:
    case 0n: {==}
    case 1n+q: {==}
def xget_v4_FixedTestStruct(+dw: Nat, +t: F.array__Tree<FixedTestStruct_d.FixedTestStruct>, +s: Nat, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(FixedTestStruct_d.FixedTestStruct, dw, t) == True{} : Bool}, +hs: {Nat.is_lt(s, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Array.get(FixedTestStruct_d.FixedTestStruct, F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), U32.from_nat(s)) == (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s)) : Array<FixedTestStruct_d.FixedTestStruct> & FixedTestStruct_d.FixedTestStruct}:
  +e1 = F.u32__to_nat_from_nat(s, dw, F.nat__lt_le(dw, 32n, hd), hs)
  +hlen = XS.lt_len(FixedTestStruct_d.FixedTestStruct, dw, t, s, pf, hs)
  F.array__get(FixedTestStruct_d.FixedTestStruct, dw, t, U32.from_nat(s), LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s), hd, MR.hi_at(dw, s, hd, hs),
    XS.at_nth(FixedTestStruct_d.FixedTestStruct, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s, U32.to_nat(U32.from_nat(s)), LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s), e1, LV.nth_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s, hlen)), pf)
law xmt_v4_FixedTestStruct:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +seg: U32
  for +dw: Nat
  for +t: F.array__Tree<FixedTestStruct_d.FixedTestStruct>
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for +junk: D.Digest
  for +e: {Nat.is_lt(s, n) == b : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(FixedTestStruct_d.FixedTestStruct, dw, t) == True{} : Bool}
  for +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool}
  {vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(d, 0n, b, hl, seg, O.pow2n(d), s, n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), junk))) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(d, b, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
def xmt_v4_FixedTestStruct(d, b, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn):
  match d:
    case 0n:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Array<FixedTestStruct_d.FixedTestStruct> & FixedTestStruct_d.FixedTestStruct, Array.get(FixedTestStruct_d.FixedTestStruct, F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), U32.from_nat(s)), (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s)), xget_v4_FixedTestStruct(dw, t, s, hd, pf, F.nat__lt_le_trans(s, n, F.spec_common__pow2(dw), e, hn))) :
            {vec_FixedTestStruct_4_h.v4_FixedTestStruct_rl(hl, seg, h, _) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(0n, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          %Equal.sym(B.Buf & D.Digest, FixedTestStruct_h.FixedTestStruct_root(hl, h, LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s), (seg + 64 : U32)), (h, RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s))), RN.st_FixedTestStruct(hl, h, LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s), (seg + 64 : U32))) :
            {vec_FixedTestStruct_4_h.v4_FixedTestStruct_rl_d(F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), _) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(0n, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          %Equal.sym(D.Digest, MD.dhead(MD.ddrop(s, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl))), RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), Nat.add(s, 0n))), xat_at_v4_FixedTestStruct(s, n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl, e)) :
            {(h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s)))) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), _)) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          %Equal.sym(Nat, Nat.add(s, 0n), s, MR.add_zero(s)) :
            {(h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), s)))) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), RN.d_FixedTestStruct(hl, LV.xat_v4_FixedTestStruct(F.array__slots(FixedTestStruct_d.FixedTestStruct, t), _)))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          {==}
    case 1n+ +q:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Nat, MD.dlen(xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl)), n, xlen_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl)) :
            {vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(s, Nat.div(Nat.double(O.pow2n(q)), 2n)), n), hl, seg, Nat.div(Nat.double(O.pow2n(q)), 2n), Nat.add(s, Nat.div(Nat.double(O.pow2n(q)), 2n)), n, vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 0n, True{}, hl, seg, Nat.div(Nat.double(O.pow2n(q)), 2n), s, n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), junk)))) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), _), hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          %Equal.sym(Nat, Nat.div(Nat.double(O.pow2n(q)), 2n), O.pow2n(q), MR.div_double(O.pow2n(q))) :
            {vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(s, _), n), hl, seg, _, Nat.add(s, _), n, vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 0n, True{}, hl, seg, _, s, n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), junk)))) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          %Equal.sym(B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest), vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 0n, True{}, hl, seg, O.pow2n(q), s, n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), junk))), (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s))), xmt_v4_FixedTestStruct(q, True{}, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn)) :
            {vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, _) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          %Equal.sym(B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest), vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s)))),
              vec_FixedTestStruct_4_h.v4_FixedTestStruct_mj(hl, MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s), vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 0n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), D.zero())))),
              xph1_v4_FixedTestStruct(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, h, F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s))) :
            {_ == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          %Equal.sym(B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest), vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 0n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), D.zero()))), (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), Nat.add(s, O.pow2n(q))))),
              xmt_v4_FixedTestStruct(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, dw, t, Nat.add(s, O.pow2n(q)), n, h, D.zero(), {==}, hd, pf, hn)) :
            {vec_FixedTestStruct_4_h.v4_FixedTestStruct_mj(hl, MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s), _) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          {==}
def xmt0_v4_FixedTestStruct(+d: Nat, +b: Bool, +hl: Nat, +seg: U32, +dw: Nat, +t: F.array__Tree<FixedTestStruct_d.FixedTestStruct>, +n: Nat, -h: B.Buf, +junk: D.Digest,
    +e: {Nat.is_lt(0n, n) == b : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(FixedTestStruct_d.FixedTestStruct, dw, t) == True{} : Bool}, +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt0(d, b, hl, seg, n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), junk))) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(d, b, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), 0n))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}:
  match d:
    case 0n: xmt_v4_FixedTestStruct(0n, b, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn)
    case 1n+ +q:
      match b:
        case False{}: {==}
        case True{}:
          %MR.div_double(O.pow2n(q)) :
            {vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(0n, _), n), hl, seg, _, Nat.add(0n, _), n, vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt(q, 0n, True{}, hl, seg, _, 0n, n, (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), junk)))) == (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(1n+q, True{}, hl, xl_v4_FixedTestStruct(n, F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), 0n))) : B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest)}
          xmt_v4_FixedTestStruct(1n+q, True{}, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn)
def xd_v4_FixedTestStruct(+hl: Nat, o: vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq) -> D.Digest:
  match o:
    case vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{arr, +n}: MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(n)), hl, xl_v4_FixedTestStruct(U32.to_nat(n), F.array__slots(FixedTestStruct_d.FixedTestStruct, F.array__freeze(FixedTestStruct_d.FixedTestStruct, arr)), 0n, hl), 0n)
def ok_v4_FixedTestStruct(+s: S.Schema) -> Bool: Bool.and(SH.is_Vector(s), Lim.minimal(SH.Vector_length(s), 2n))
def st_v4_FixedTestStruct(+hl: Nat, -h: B.Buf, -o: vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, +seg: U32, +s: S.Schema, +rep: LV.rep_v4_FixedTestStruct(o, s))
    -> {vec_FixedTestStruct_4_h.v4_FixedTestStruct_root(hl, h, o, seg) == (h, (o, xd_v4_FixedTestStruct(hl, o))) : B.Buf & (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & D.Digest)}:
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, w6) = w5
  (+hn, +er) = w6
  %Equal.sym(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, o, vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}, eo) :
    {vec_FixedTestStruct_4_h.v4_FixedTestStruct_root(hl, h, _, seg) == (h, (_, xd_v4_FixedTestStruct(hl, _))) : B.Buf & (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & D.Digest)}
  %Equal.sym(B.Buf & (Array<FixedTestStruct_d.FixedTestStruct> & D.Digest), vec_FixedTestStruct_4_h.v4_FixedTestStruct_mt0(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, U32.to_nat(N), (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), D.zero()))), (h, (F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), 0n))),
      xmt0_v4_FixedTestStruct(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, dw, t, U32.to_nat(N), h, D.zero(), {==}, hd, pf, hn)) :
    {vec_FixedTestStruct_4_h.v4_FixedTestStruct_rt_fin(hl, N, _) == (h, (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}, xd_v4_FixedTestStruct(hl, vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}))) : B.Buf & (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & D.Digest)}
  %Equal.sym(F.array__Tree<FixedTestStruct_d.FixedTestStruct>, F.array__freeze(FixedTestStruct_d.FixedTestStruct, F.array__thaw(FixedTestStruct_d.FixedTestStruct, t)), t, F.array__freeze_thaw(FixedTestStruct_d.FixedTestStruct, t)) :
    {(h, (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}, MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), 0n))) == (h, (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}, MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, _), 0n, hl), 0n))) : B.Buf & (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & D.Digest)}
  {==}
def xhl_v4_FixedTestStruct(+N: U32, +Lm: Nat, +Wl: List<&2, FixedTestStruct_d.FixedTestStruct>, +hl: Nat, +hv: {Nat.is_le(U32.to_nat(N), Lm) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(xl_v4_FixedTestStruct(U32.to_nat(N), Wl, 0n, hl)), Lm) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(xl_v4_FixedTestStruct(U32.to_nat(N), Wl, 0n, hl)), U32.to_nat(N), xlen_v4_FixedTestStruct(U32.to_nat(N), Wl, 0n, hl)) : {Nat.is_le(_, Lm) == True{} : Bool}
  hv
def xhv_v4_FixedTestStruct(-o: vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, +t: F.array__Tree<FixedTestStruct_d.FixedTestStruct>, +N: U32, +Lm: Nat, +eo: {o == vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N} : vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq},
    +hv: {Nat.is_eq(U32.to_nat(LV.xlen_o_v4_FixedTestStruct(o)), Lm) == True{} : Bool}) -> {Nat.is_eq(U32.to_nat(N), Lm) == True{} : Bool}:
  %Equal.cong(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, U32, LV.xlen_o_v4_FixedTestStruct, o, vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}, eo) : {Nat.is_eq(U32.to_nat(_), Lm) == True{} : Bool}
  hv
def wd_v4_FixedTestStruct(+hl: Nat, -o: vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, +s: S.Schema, +rep: LV.rep_v4_FixedTestStruct(o, s)) -> OS.DW(xd_v4_FixedTestStruct(hl, o)):
  (+wf, +hv) = rep
  (+t, +w1) = wf
  (+dw, +w2) = w1
  (+N, +w3) = w2
  (+eo, +w4) = w3
  %Equal.sym(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, o, vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}, eo) : OS.DW(xd_v4_FixedTestStruct(hl, _))
  (xd_v4_FixedTestStruct(hl, vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}), {==})
def rs_v4_FixedTestStruct(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, +s: S.Schema, +rep: LV.rep_v4_FixedTestStruct(o, s), +ok: {ok_v4_FixedTestStruct(s) == True{} : Bool}, +eq: {SH.Vector_element(s) == S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}} : S.Schema})
    -> RR.roots(LV.xv_v4_FixedTestStruct(o), s, [D.bytes(xd_v4_FixedTestStruct(hl, o))]):
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, w6) = w5
  (+hn, +er) = w6
  +k0 = DK.and_l(SH.is_Vector(s), Lim.minimal(SH.Vector_length(s), 2n), ok)
  +k1 = DK.and_r(SH.is_Vector(s), Lim.minimal(SH.Vector_length(s), 2n), ok)
  +hvN = veq_le(U32.to_nat(N), SH.Vector_length(s), xhv_v4_FixedTestStruct(o, t, N, SH.Vector_length(s), eo, hv))
  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, k0)) :
    RR.roots(LV.xv_v4_FixedTestStruct(o), _, [D.bytes(xd_v4_FixedTestStruct(hl, o))])
  %Equal.sym(S.Schema, SH.Vector_element(s), S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, eq) :
    RR.roots(LV.xv_v4_FixedTestStruct(o), S.Vector{_, SH.Vector_length(s)}, [D.bytes(xd_v4_FixedTestStruct(hl, o))])
  %Equal.sym(vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq, o, vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq{F.array__thaw(FixedTestStruct_d.FixedTestStruct, t), N}, eo) :
    RR.roots(LV.xv_v4_FixedTestStruct(_), S.Vector{S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, SH.Vector_length(s)}, [D.bytes(xd_v4_FixedTestStruct(hl, _))])
  %Equal.sym(F.array__Tree<FixedTestStruct_d.FixedTestStruct>, F.array__freeze(FixedTestStruct_d.FixedTestStruct, F.array__thaw(FixedTestStruct_d.FixedTestStruct, t)), t, F.array__freeze_thaw(FixedTestStruct_d.FixedTestStruct, t)) :
    RR.roots(S.Sequence{LV.xi_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, _), 0n)}, S.Vector{S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, SH.Vector_length(s)}, [D.bytes(MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, _), 0n, hl), 0n))])
  %xlen_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl) :
    RR.roots(S.Sequence{LV.xi_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n)}, S.Vector{S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, SH.Vector_length(s)}, [D.bytes(MD.rtree(2n, Nat.is_lt(0n, _), hl, xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), 0n))])
  (MD.bytes_list(xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl)), (xroots_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl, ehl, er),
    (D.bytes(MD.rtree(2n, Nat.is_lt(0n, MD.dlen(xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl))), hl, xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), 0n)), ((2n, (k1, RS.at_depth_tree(SH.Vector_length(s), 2n, hl, xl_v4_FixedTestStruct(U32.to_nat(N), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), 0n, hl), {==}, xhl_v4_FixedTestStruct(N, SH.Vector_length(s), F.array__slots(FixedTestStruct_d.FixedTestStruct, t), hl, hvN), ehl))),
     {==}))))

def d_VarTestStruct_bx(+hl: Nat, o: O.Boxed<VarTestStruct_d.VarTestStruct>) -> D.Digest:
  match o:
    case O.BSome{v, rest}: d_VarTestStruct(hl, v)
    case O.BNone{}: D.zero()
def st_VarTestStruct_bx(+hl: Nat, -h: B.Buf, -o: O.Boxed<VarTestStruct_d.VarTestStruct>, +seg: U32, +s: S.Schema, +rep: LV.rep_VarTestStruct_bx(o, s))
    -> {VarTestStruct_h.VarTestStruct_bx_root(hl, h, o, seg) == (h, (o, d_VarTestStruct_bx(hl, o))) : B.Buf & (O.Boxed<VarTestStruct_d.VarTestStruct> & D.Digest)}:
  (+eo, +ri) = rep
  %Equal.sym(O.Boxed<VarTestStruct_d.VarTestStruct>, o, O.BSome{LV.pjb_VarTestStruct_bx(o), O.BNone{}}, eo) :
    {VarTestStruct_h.VarTestStruct_bx_root(hl, h, _, seg) == (h, (_, d_VarTestStruct_bx(hl, _))) : B.Buf & (O.Boxed<VarTestStruct_d.VarTestStruct> & D.Digest)}
  %Equal.sym(B.Buf & (VarTestStruct_d.VarTestStruct & D.Digest), VarTestStruct_h.VarTestStruct_root(hl, h, LV.pjb_VarTestStruct_bx(o), seg), (h, (LV.pjb_VarTestStruct_bx(o), d_VarTestStruct(hl, LV.pjb_VarTestStruct_bx(o)))), st_VarTestStruct(hl, h, LV.pjb_VarTestStruct_bx(o), seg, s, ri)) :
    {VarTestStruct_h.VarTestStruct_bx_rt(_) == (h, (O.BSome{LV.pjb_VarTestStruct_bx(o), O.BNone{}}, d_VarTestStruct_bx(hl, O.BSome{LV.pjb_VarTestStruct_bx(o), O.BNone{}}))) : B.Buf & (O.Boxed<VarTestStruct_d.VarTestStruct> & D.Digest)}
  {==}
def rs_VarTestStruct_bx(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Boxed<VarTestStruct_d.VarTestStruct>, +s: S.Schema, +rep: LV.rep_VarTestStruct_bx(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}, +ok: {ok_VarTestStruct(s, dv) == True{} : Bool}, +eq: eqs_VarTestStruct(s))
    -> RR.roots(LV.v_VarTestStruct_bx(o), s, [D.bytes(d_VarTestStruct_bx(hl, o))]):
  (+eo, +ri) = rep
  %Equal.sym(O.Boxed<VarTestStruct_d.VarTestStruct>, o, O.BSome{LV.pjb_VarTestStruct_bx(o), O.BNone{}}, eo) : RR.roots(LV.v_VarTestStruct_bx(_), s, [D.bytes(d_VarTestStruct_bx(hl, _))])
  rs_VarTestStruct(hl, ehl, h, LV.pjb_VarTestStruct_bx(o), s, ri, dv, edv, ok, eq)
def wd_VarTestStruct_bx(+hl: Nat, -o: O.Boxed<VarTestStruct_d.VarTestStruct>, +s: S.Schema, +rep: LV.rep_VarTestStruct_bx(o, s)) -> OS.DW(d_VarTestStruct_bx(hl, o)):
  (+eo, +ri) = rep
  %Equal.sym(O.Boxed<VarTestStruct_d.VarTestStruct>, o, O.BSome{LV.pjb_VarTestStruct_bx(o), O.BNone{}}, eo) : OS.DW(d_VarTestStruct_bx(hl, _))
  wd_VarTestStruct(hl, LV.pjb_VarTestStruct_bx(o), s, ri)
def ok_VarTestStruct_bx(+s: S.Schema, +dv: OS.DV) -> Bool: ok_VarTestStruct(s, dv)
def eqs_VarTestStruct_bx(+s: S.Schema) -> Data: eqs_VarTestStruct(s)

def mfz_VarTestStruct_bx(x: O.Boxed<VarTestStruct_d.VarTestStruct>) -> LV.M_VarTestStruct:
  match x:
    case O.BSome{v, rest}: LV.fz_VarTestStruct(v)
    case O.BNone{}: LV.fz_VarTestStruct(VarTestStruct_d.VarTestStruct_default())
def xl_v2_VarTestStruct(k: Nat, +W: List<&2, LV.MB<LV.M_VarTestStruct>>, +i: Nat, +hl: Nat) -> List<&2, D.Digest>:
  match k:
    case 0n: []
    case 1n+q: d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, i))) <> xl_v2_VarTestStruct(q, W, 1n+i, hl)
law xlen_v2_VarTestStruct:
  for +k: Nat
  for +W: List<&2, LV.MB<LV.M_VarTestStruct>>
  for +i: Nat
  for +hl: Nat
  {MD.dlen(xl_v2_VarTestStruct(k, W, i, hl)) == k : Nat}
def xlen_v2_VarTestStruct(k, W, i, hl):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %xlen_v2_VarTestStruct(q, W, 1n+i, hl) : {1n+MD.dlen(xl_v2_VarTestStruct(q, W, 1n+i, hl)) == 1n+_ : Nat}
      {==}
law xat_at_v2_VarTestStruct:
  for +s: Nat
  for +k: Nat
  for +W: List<&2, LV.MB<LV.M_VarTestStruct>>
  for +i: Nat
  for +hl: Nat
  for +e: {Nat.is_lt(s, k) == True{} : Bool}
  {MD.dhead(MD.ddrop(s, xl_v2_VarTestStruct(k, W, i, hl))) == d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, Nat.add(s, i)))) : D.Digest}
def xat_at_v2_VarTestStruct(s, k, W, i, hl, e):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(0n, xl_v2_VarTestStruct(0n, W, i, hl))) == d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, Nat.add(0n, i)))) : D.Digest}, MD.false_true(e))
        case 1n+q: {==}
    case 1n+ +p1:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(1n+p1, xl_v2_VarTestStruct(0n, W, i, hl))) == d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, Nat.add(1n+p1, i)))) : D.Digest}, MD.false_true(e))
        case 1n+ +q:
          %MR.add_succ(p1, i) : {MD.dhead(MD.ddrop(p1, xl_v2_VarTestStruct(q, W, 1n+i, hl))) == d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, _))) : D.Digest}
          xat_at_v2_VarTestStruct(p1, q, W, 1n+i, hl, e)
def erep_at_v2_VarTestStruct(+s: Nat, +k: Nat, +W: List<&2, LV.MB<LV.M_VarTestStruct>>, +i: Nat, +sE: S.Schema, +er: LV.ereps_v2_VarTestStruct(k, W, i, sE), +e: {Nat.is_lt(s, k) == True{} : Bool})
    -> LV.rep_VarTestStruct_bx(LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, Nat.add(s, i))), sE):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd(LV.rep_VarTestStruct_bx(LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, Nat.add(0n, i))), sE), MD.false_true(e))
        case 1n+q:
          (+r0, +rs) = er
          r0
    case 1n+ +p1:
      match k:
        case 0n: Empty.absurd(LV.rep_VarTestStruct_bx(LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, Nat.add(1n+p1, i))), sE), MD.false_true(e))
        case 1n+ +q:
          (+r0, +rs) = er
          %MR.add_succ(p1, i) : LV.rep_VarTestStruct_bx(LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, _)), sE)
          erep_at_v2_VarTestStruct(p1, q, W, 1n+i, sE, rs, e)
law xroots_v2_VarTestStruct:
  for +k: Nat
  for +W: List<&2, LV.MB<LV.M_VarTestStruct>>
  for +i: Nat
  for +hl: Nat
  for +ehl: {hl == 64n : Nat}
  for -h: B.Buf
  for +sE: S.Schema
  for +er: LV.ereps_v2_VarTestStruct(k, W, i, sE)
  for +dv: OS.DV
  for +edv: {dv == OS.DV0() : OS.DV}
  for +ok: {ok_VarTestStruct_bx(sE, dv) == True{} : Bool}
  for +eq: eqs_VarTestStruct_bx(sE)
  RR.roots(LV.xi_v2_VarTestStruct(k, W, i), S.Repeat{sE}, MD.bytes_list(xl_v2_VarTestStruct(k, W, i, hl)))
def xroots_v2_VarTestStruct(k, W, i, hl, ehl, h, sE, er, dv, edv, ok, eq):
  match k:
    case 0n: {==}
    case 1n+ +q:
      (+r0, +rs) = er
      ([D.bytes(d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, i))))], (MD.bytes_list(xl_v2_VarTestStruct(q, W, 1n+i, hl)), (rs_VarTestStruct_bx(hl, ehl, h, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(W, i)), sE, r0, dv, edv, ok, eq), (xroots_v2_VarTestStruct(q, W, 1n+i, hl, ehl, h, sE, rs, dv, edv, ok, eq), {==}))))
law xcount_v2_VarTestStruct:
  for +k: Nat
  for +W: List<&2, LV.MB<LV.M_VarTestStruct>>
  for +i: Nat
  {Codec.count(LV.xi_v2_VarTestStruct(k, W, i)) == k : Nat}
def xcount_v2_VarTestStruct(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Codec.count(LV.xi_v2_VarTestStruct(q, W, 1n+i)), q, xcount_v2_VarTestStruct(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}
law xph1_v2_VarTestStruct:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +seg: U32
  for +v: Nat
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for -ws: Array<O.Boxed<VarTestStruct_d.VarTestStruct>>
  for +dl: D.Digest
  {vec_VarTestStruct_2_h.v2_VarTestStruct_mt(d, 1n, b, hl, seg, v, s, n, (h, (ws, dl))) == vec_VarTestStruct_2_h.v2_VarTestStruct_mj(hl, dl, vec_VarTestStruct_2_h.v2_VarTestStruct_mt(d, 0n, b, hl, seg, v, s, n, (h, (ws, D.zero())))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
def xph1_v2_VarTestStruct(d, b, hl, seg, v, s, n, h, ws, dl):
  match d:
    case 0n: {==}
    case 1n+q: {==}
law xmt_v2_VarTestStruct:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +seg: U32
  for +dw: Nat
  for +t: F.array__Tree<LV.MB<LV.M_VarTestStruct>>
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for +junk: D.Digest
  for +e: {Nat.is_lt(s, n) == b : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(LV.MB<LV.M_VarTestStruct>, dw, t) == True{} : Bool}
  for +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool}
  for +sE: S.Schema
  for +er: LV.ereps_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, sE)
  {vec_VarTestStruct_2_h.v2_VarTestStruct_mt(d, 0n, b, hl, seg, O.pow2n(d), s, n, (h, (LV.am_v2_VarTestStruct(t), junk))) == (h, (LV.am_v2_VarTestStruct(t), MD.rtree(d, b, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
def xmt_v2_VarTestStruct(d, b, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn, sE, er):
  match d:
    case 0n:
      match b:
        case False{}: {==}
        case True{}:
          +hs = F.nat__lt_le_trans(s, n, F.spec_common__pow2(dw), e, hn)
          +e1 = F.u32__to_nat_from_nat(s, dw, F.nat__lt_le(dw, 32n, hd), hs)
          +hx = XS.at_nth(LV.MB<LV.M_VarTestStruct>, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s, U32.to_nat(U32.from_nat(s)), LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s), e1, LV.nth_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s, XS.lt_len(LV.MB<LV.M_VarTestStruct>, dw, t, s, pf, hs)))
          +rx = F.logic__subst(Nat, j => LV.rep_VarTestStruct_bx(LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), j)), sE), Nat.add(s, 0n), s, MR.add_zero(s), erep_at_v2_VarTestStruct(s, n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, sE, er, e))
          %Equal.sym(Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & O.Boxed<VarTestStruct_d.VarTestStruct>, Array.swap(O.Boxed<VarTestStruct_d.VarTestStruct>, LV.am_v2_VarTestStruct(t), U32.from_nat(s), O.BNone{}), (LV.am_v2_VarTestStruct(F.array__upd(LV.MB<LV.M_VarTestStruct>, dw, t, U32.to_nat(U32.from_nat(s)), LV.MNone{})), LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s))),
              LV.amswap_v2_VarTestStruct(dw, t, U32.from_nat(s), LV.MNone{}, LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s), hd, MR.hi_at(dw, s, hd, hs), hx, pf)) :
            {vec_VarTestStruct_2_h.v2_VarTestStruct_rl(hl, U32.from_nat(s), seg, h, _) == (h, (LV.am_v2_VarTestStruct(t), MD.rtree(0n, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          %Equal.sym(B.Buf & (O.Boxed<VarTestStruct_d.VarTestStruct> & D.Digest), VarTestStruct_h.VarTestStruct_bx_root(hl, h, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s)), (seg + 64 : U32)), (h, (LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s)), d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s))))), st_VarTestStruct_bx(hl, h, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s)), (seg + 64 : U32), sE, rx)) :
            {vec_VarTestStruct_2_h.v2_VarTestStruct_rl_n(U32.from_nat(s), LV.am_v2_VarTestStruct(F.array__upd(LV.MB<LV.M_VarTestStruct>, dw, t, U32.to_nat(U32.from_nat(s)), LV.MNone{})), _) == (h, (LV.am_v2_VarTestStruct(t), MD.rtree(0n, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          %Equal.sym(Array<O.Boxed<VarTestStruct_d.VarTestStruct>>, Array.set(O.Boxed<VarTestStruct_d.VarTestStruct>, LV.am_v2_VarTestStruct(F.array__upd(LV.MB<LV.M_VarTestStruct>, dw, t, U32.to_nat(U32.from_nat(s)), LV.MNone{})), U32.from_nat(s), LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s))), LV.am_v2_VarTestStruct(t), LV.amswap_back_v2_VarTestStruct(dw, t, U32.from_nat(s), LV.MNone{}, LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s), hd, MR.hi_at(dw, s, hd, hs), hx, pf)) :
            {(h, (_, d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s))))) == (h, (LV.am_v2_VarTestStruct(t), MD.rtree(0n, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          %Equal.sym(D.Digest, MD.dhead(MD.ddrop(s, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl))), d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), Nat.add(s, 0n)))), xat_at_v2_VarTestStruct(s, n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl, e)) :
            {(h, (LV.am_v2_VarTestStruct(t), d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s))))) == (h, (LV.am_v2_VarTestStruct(t), _)) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          %Equal.sym(Nat, Nat.add(s, 0n), s, MR.add_zero(s)) :
            {(h, (LV.am_v2_VarTestStruct(t), d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), s))))) == (h, (LV.am_v2_VarTestStruct(t), d_VarTestStruct_bx(hl, LV.th_VarTestStruct_bx(LV.xat_v2_VarTestStruct(F.array__slots(LV.MB<LV.M_VarTestStruct>, t), _))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          {==}
    case 1n+ +q:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Nat, MD.dlen(xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl)), n, xlen_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl)) :
            {vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(s, Nat.div(Nat.double(O.pow2n(q)), 2n)), n), hl, seg, Nat.div(Nat.double(O.pow2n(q)), 2n), Nat.add(s, Nat.div(Nat.double(O.pow2n(q)), 2n)), n, vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 0n, True{}, hl, seg, Nat.div(Nat.double(O.pow2n(q)), 2n), s, n, (h, (LV.am_v2_VarTestStruct(t), junk)))) == (h, (LV.am_v2_VarTestStruct(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), _), hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          %Equal.sym(Nat, Nat.div(Nat.double(O.pow2n(q)), 2n), O.pow2n(q), MR.div_double(O.pow2n(q))) :
            {vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(s, _), n), hl, seg, _, Nat.add(s, _), n, vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 0n, True{}, hl, seg, _, s, n, (h, (LV.am_v2_VarTestStruct(t), junk)))) == (h, (LV.am_v2_VarTestStruct(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          %Equal.sym(B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest), vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 0n, True{}, hl, seg, O.pow2n(q), s, n, (h, (LV.am_v2_VarTestStruct(t), junk))), (h, (LV.am_v2_VarTestStruct(t), MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s))), xmt_v2_VarTestStruct(q, True{}, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn, sE, er)) :
            {vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, _) == (h, (LV.am_v2_VarTestStruct(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          %Equal.sym(B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest), vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (LV.am_v2_VarTestStruct(t), MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s)))),
              vec_VarTestStruct_2_h.v2_VarTestStruct_mj(hl, MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s), vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 0n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (LV.am_v2_VarTestStruct(t), D.zero())))),
              xph1_v2_VarTestStruct(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, h, LV.am_v2_VarTestStruct(t), MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s))) :
            {_ == (h, (LV.am_v2_VarTestStruct(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          %Equal.sym(B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest), vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 0n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (LV.am_v2_VarTestStruct(t), D.zero()))), (h, (LV.am_v2_VarTestStruct(t), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), Nat.add(s, O.pow2n(q))))),
              xmt_v2_VarTestStruct(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, dw, t, Nat.add(s, O.pow2n(q)), n, h, D.zero(), {==}, hd, pf, hn, sE, er)) :
            {vec_VarTestStruct_2_h.v2_VarTestStruct_mj(hl, MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s), _) == (h, (LV.am_v2_VarTestStruct(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          {==}
def xmt0_v2_VarTestStruct(+d: Nat, +b: Bool, +hl: Nat, +seg: U32, +dw: Nat, +t: F.array__Tree<LV.MB<LV.M_VarTestStruct>>, +n: Nat, -h: B.Buf, +junk: D.Digest,
    +e: {Nat.is_lt(0n, n) == b : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(LV.MB<LV.M_VarTestStruct>, dw, t) == True{} : Bool}, +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool},
    +sE: S.Schema, +er: LV.ereps_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, sE))
    -> {vec_VarTestStruct_2_h.v2_VarTestStruct_mt0(d, b, hl, seg, n, (h, (LV.am_v2_VarTestStruct(t), junk))) == (h, (LV.am_v2_VarTestStruct(t), MD.rtree(d, b, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), 0n))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}:
  match d:
    case 0n: xmt_v2_VarTestStruct(0n, b, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn, sE, er)
    case 1n+ +q:
      match b:
        case False{}: {==}
        case True{}:
          %MR.div_double(O.pow2n(q)) :
            {vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 1n, Nat.is_lt(Nat.add(0n, _), n), hl, seg, _, Nat.add(0n, _), n, vec_VarTestStruct_2_h.v2_VarTestStruct_mt(q, 0n, True{}, hl, seg, _, 0n, n, (h, (LV.am_v2_VarTestStruct(t), junk)))) == (h, (LV.am_v2_VarTestStruct(t), MD.rtree(1n+q, True{}, hl, xl_v2_VarTestStruct(n, F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), 0n))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest)}
          xmt_v2_VarTestStruct(1n+q, True{}, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn, sE, er)
def xd_v2_VarTestStruct(+hl: Nat, o: vec_VarTestStruct_2_d.v2_VarTestStruct_Seq) -> D.Digest:
  match o:
    case vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{arr, +n}: MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(n)), hl, xl_v2_VarTestStruct(U32.to_nat(n), F.array__slots(LV.MB<LV.M_VarTestStruct>, LV.tfz_v2_VarTestStruct(arr)), 0n, hl), 0n)
def ok_v2_VarTestStruct(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_Vector(s), Bool.and(Lim.minimal(SH.Vector_length(s), 1n), ok_VarTestStruct_bx(SH.Vector_element(s), dv)))
def eqs_v2_VarTestStruct(+s: S.Schema) -> Data: eqs_VarTestStruct_bx(SH.Vector_element(s))
def st_v2_VarTestStruct(+hl: Nat, -h: B.Buf, -o: vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, +seg: U32, +s: S.Schema, +rep: LV.rep_v2_VarTestStruct(o, s))
    -> {vec_VarTestStruct_2_h.v2_VarTestStruct_root(hl, h, o, seg) == (h, (o, xd_v2_VarTestStruct(hl, o))) : B.Buf & (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & D.Digest)}:
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, w6) = w5
  (+hn, +er) = w6
  %Equal.sym(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, o, vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N}, eo) :
    {vec_VarTestStruct_2_h.v2_VarTestStruct_root(hl, h, _, seg) == (h, (_, xd_v2_VarTestStruct(hl, _))) : B.Buf & (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & D.Digest)}
  %Equal.sym(B.Buf & (Array<O.Boxed<VarTestStruct_d.VarTestStruct>> & D.Digest), vec_VarTestStruct_2_h.v2_VarTestStruct_mt0(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, U32.to_nat(N), (h, (LV.am_v2_VarTestStruct(t), D.zero()))), (h, (LV.am_v2_VarTestStruct(t), MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), 0n))),
      xmt0_v2_VarTestStruct(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, dw, t, U32.to_nat(N), h, D.zero(), {==}, hd, pf, hn, SH.Vector_element(s), er)) :
    {vec_VarTestStruct_2_h.v2_VarTestStruct_rt_fin(hl, N, _) == (h, (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N}, xd_v2_VarTestStruct(hl, vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N}))) : B.Buf & (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & D.Digest)}
  %Equal.sym(F.array__Tree<LV.MB<LV.M_VarTestStruct>>, LV.tfz_v2_VarTestStruct(LV.am_v2_VarTestStruct(t)), t, LV.tfzam_v2_VarTestStruct(t)) :
    {(h, (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N}, MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), 0n))) == (h, (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N}, MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, _), 0n, hl), 0n))) : B.Buf & (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & D.Digest)}
  {==}
def xhl_v2_VarTestStruct(+N: U32, +Lm: Nat, +Wl: List<&2, LV.MB<LV.M_VarTestStruct>>, +hl: Nat, +hv: {Nat.is_le(U32.to_nat(N), Lm) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(xl_v2_VarTestStruct(U32.to_nat(N), Wl, 0n, hl)), Lm) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(xl_v2_VarTestStruct(U32.to_nat(N), Wl, 0n, hl)), U32.to_nat(N), xlen_v2_VarTestStruct(U32.to_nat(N), Wl, 0n, hl)) : {Nat.is_le(_, Lm) == True{} : Bool}
  hv
def xhv_v2_VarTestStruct(-o: vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, +t: F.array__Tree<LV.MB<LV.M_VarTestStruct>>, +N: U32, +Lm: Nat, +eo: {o == vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N} : vec_VarTestStruct_2_d.v2_VarTestStruct_Seq},
    +hv: {Nat.is_eq(U32.to_nat(LV.xlen_o_v2_VarTestStruct(o)), Lm) == True{} : Bool}) -> {Nat.is_eq(U32.to_nat(N), Lm) == True{} : Bool}:
  %Equal.cong(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, U32, LV.xlen_o_v2_VarTestStruct, o, vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N}, eo) : {Nat.is_eq(U32.to_nat(_), Lm) == True{} : Bool}
  hv
def wd_v2_VarTestStruct(+hl: Nat, -o: vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, +s: S.Schema, +rep: LV.rep_v2_VarTestStruct(o, s)) -> OS.DW(xd_v2_VarTestStruct(hl, o)):
  (+wf, +hv) = rep
  (+t, +w1) = wf
  (+dw, +w2) = w1
  (+N, +w3) = w2
  (+eo, +w4) = w3
  %Equal.sym(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, o, vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N}, eo) : OS.DW(xd_v2_VarTestStruct(hl, _))
  %Equal.sym(F.array__Tree<LV.MB<LV.M_VarTestStruct>>, LV.tfz_v2_VarTestStruct(LV.am_v2_VarTestStruct(t)), t, LV.tfzam_v2_VarTestStruct(t)) : OS.DW(MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, _), 0n, hl), 0n))
  (MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), 0n), {==})
def rs_v2_VarTestStruct(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, +s: S.Schema, +rep: LV.rep_v2_VarTestStruct(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}, +ok: {ok_v2_VarTestStruct(s, dv) == True{} : Bool}, +eq: eqs_v2_VarTestStruct(s))
    -> RR.roots(LV.xv_v2_VarTestStruct(o), s, [D.bytes(xd_v2_VarTestStruct(hl, o))]):
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, w6) = w5
  (+hn, +er) = w6
  +k0 = DK.and_l(SH.is_Vector(s), Bool.and(Lim.minimal(SH.Vector_length(s), 1n), ok_VarTestStruct_bx(SH.Vector_element(s), dv)), ok)
  +k1 = DK.and_r(SH.is_Vector(s), Bool.and(Lim.minimal(SH.Vector_length(s), 1n), ok_VarTestStruct_bx(SH.Vector_element(s), dv)), ok)
  +kmin = DK.and_l(Lim.minimal(SH.Vector_length(s), 1n), ok_VarTestStruct_bx(SH.Vector_element(s), dv), k1)
  +kel = DK.and_r(Lim.minimal(SH.Vector_length(s), 1n), ok_VarTestStruct_bx(SH.Vector_element(s), dv), k1)
  +hvN = veq_le(U32.to_nat(N), SH.Vector_length(s), xhv_v2_VarTestStruct(o, t, N, SH.Vector_length(s), eo, hv))
  +ebs = bs_cont(SH.Vector_element(s), okc_VarTestStruct(SH.Vector_element(s), dv, kel))
  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, k0)) :
    RR.roots(LV.xv_v2_VarTestStruct(o), _, [D.bytes(xd_v2_VarTestStruct(hl, o))])
  %Equal.sym(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq, o, vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{LV.am_v2_VarTestStruct(t), N}, eo) :
    RR.roots(LV.xv_v2_VarTestStruct(_), S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, [D.bytes(xd_v2_VarTestStruct(hl, _))])
  %Equal.sym(F.array__Tree<LV.MB<LV.M_VarTestStruct>>, LV.tfz_v2_VarTestStruct(LV.am_v2_VarTestStruct(t)), t, LV.tfzam_v2_VarTestStruct(t)) :
    RR.roots(S.Sequence{LV.xi_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, _), 0n)}, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, [D.bytes(MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, _), 0n, hl), 0n))])
  %xlen_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl) :
    RR.roots(S.Sequence{LV.xi_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n)}, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, [D.bytes(MD.rtree(1n, Nat.is_lt(0n, _), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), 0n))])
  vec_none(LV.xi_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n), SH.Vector_element(s), SH.Vector_length(s), [D.bytes(MD.rtree(1n, Nat.is_lt(0n, MD.dlen(xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl))), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), 0n))], ebs,
  (MD.bytes_list(xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl)), (xroots_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl, ehl, h, SH.Vector_element(s), er, dv, edv, kel, eq),
    (D.bytes(MD.rtree(1n, Nat.is_lt(0n, MD.dlen(xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl))), hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), 0n)), ((1n, (kmin, RS.at_depth_tree(SH.Vector_length(s), 1n, hl, xl_v2_VarTestStruct(U32.to_nat(N), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), 0n, hl), {==}, xhl_v2_VarTestStruct(N, SH.Vector_length(s), F.array__slots(LV.MB<LV.M_VarTestStruct>, t), hl, hvN), ehl))),
     {==})))))

def d_ComplexTestStruct(+hl: Nat, o: ComplexTestStruct_d.ComplexTestStruct) -> D.Digest:
  match o:
    case ComplexTestStruct_d.ComplexTestStruct{+x0, x1, +x2, x3, x4, x5, x6}: MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), BLI.bdig(hl, x1, 3n, 1n), RN.d_u8(hl, x2), LO.ldig(hl, x3, 3n), d_VarTestStruct(hl, x4), xd_v4_FixedTestStruct(hl, x5), xd_v2_VarTestStruct(hl, x6)], 0n)
def ok_ComplexTestStruct(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))))
def okc_ComplexTestStruct(+s: S.Schema, +dv: OS.DV, +ok: {ok_ComplexTestStruct(s, dv) == True{} : Bool}) -> {SH.is_Container(s) == True{} : Bool}: DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
def eqs_ComplexTestStruct(+s: S.Schema) -> Data: DK.P2({SH.Chain_head(SH.Container_fields(s)) == S.Unsigned{P.U16{}} : S.Schema}, DK.P2({SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))) == S.Unsigned{P.U8{}} : S.Schema}, DK.P2(eqs_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), DK.P2({SH.Vector_element(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))) == S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}} : S.Schema}, eqs_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))
def fsh_ComplexTestStruct(+s: S.Schema, +dv: OS.DV, +ok: {ok_ComplexTestStruct(s, dv) == True{} : Bool}) -> {SH.Container_fields(s) == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}:
  +k0 = DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
  +r1 = DK.and_r(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
  +k1 = DK.and_l(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))))), r1)
  +r2 = DK.and_r(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))))), r1)
  +k2 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))), r2)
  +r3 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))), r2)
  +k3 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))), r3)
  +r4 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))), r3)
  +k4 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))), r4)
  +r5 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))), r4)
  +k5 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))), r5)
  +r6 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))), r5)
  +k6 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))), r6)
  +r7 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))), r6)
  +k7 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))), r7)
  +r8 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))), r7)
  +k8 = DK.and_l(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))), r8)
  +r9 = DK.and_r(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))), r8)
  +k9 = DK.and_l(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))), r9)
  +r10 = DK.and_r(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))), r9)
  +k10 = DK.and_l(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))), r10)
  +r11 = DK.and_r(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))), r10)
  +k11 = DK.and_l(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)), r11)
  +r12 = DK.and_r(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)), r11)
  +k12 = DK.and_l(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv), r12)
  +r13 = DK.and_r(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv), r12)
  %Equal.sym(S.Schema, SH.Container_fields(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), SH.Chain_tail(SH.Container_fields(s))}, SH.Chain_shape(SH.Container_fields(s), k1)) :
    {_ == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))}, SH.Chain_shape(SH.Chain_tail(SH.Container_fields(s)), k2)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), _} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))}, SH.Chain_shape(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))), k3)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), _}} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))}, SH.Chain_shape(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), k4)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), _}}} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))}, SH.Chain_shape(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), k5)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), _}}}} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))}, SH.Chain_shape(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), k6)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), _}}}}} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))}, SH.Chain_shape(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), k7)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), _}}}}}} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}
  %Equal.sym(S.Schema, SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}, SH.End_shape(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), k8)) :
    {S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), _}}}}}}} == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}
  {==}
def st_ComplexTestStruct(+hl: Nat, -h: B.Buf, -o: ComplexTestStruct_d.ComplexTestStruct, +seg: U32, +s: S.Schema, +rep: LV.rep_ComplexTestStruct(o, s))
    -> {ComplexTestStruct_h.ComplexTestStruct_root(hl, h, o, seg) == (h, (o, d_ComplexTestStruct(hl, o))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}:
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  (+rp2, +q5) = q4
  (+rp3, +q6) = q5
  (+rp4, +q7) = q6
  (+rp5, +q8) = q7
  %Equal.sym(ComplexTestStruct_d.ComplexTestStruct, o, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, eo) :
    {ComplexTestStruct_h.ComplexTestStruct_root(hl, h, _, seg) == (h, (_, d_ComplexTestStruct(hl, _))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, uint16_h.u16_root(hl, h, x0, seg), (h, RN.d_u16(hl, x0)), RN.st_u16(hl, h, x0, seg)) :
    {ComplexTestStruct_h.ComplexTestStruct_rt0(hl, seg, x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o), _) == (h, (ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), list_uint16_128_h.l128_u16_root(hl, h, LV.pj_ComplexTestStruct_1(o), seg), (h, (LV.pj_ComplexTestStruct_1(o), BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n))), BLI.bl_st(hl, h, LV.pj_ComplexTestStruct_1(o), 3, seg, 3n, 1n, BLI_L.rep_wf2(LV.pj_ComplexTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), rp1), {==})) :
    {ComplexTestStruct_h.ComplexTestStruct_rt1(hl, seg, x0, x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o), RN.d_u16(hl, x0), _) == (h, (ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, uint8_h.u8_root(hl, h, x2, seg), (h, RN.d_u8(hl, x2)), RN.st_u8(hl, h, x2, seg)) :
    {ComplexTestStruct_h.ComplexTestStruct_rt2(hl, seg, x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), _) == (h, (ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), bytelist_256_h.bl256_root(hl, h, LV.pj_ComplexTestStruct_3(o), seg), (h, (LV.pj_ComplexTestStruct_3(o), LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n))), LO.bl_st(hl, h, LV.pj_ComplexTestStruct_3(o), 3, seg, 3n, LO_L.rep_wf(LV.pj_ComplexTestStruct_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), rp3), {==})) :
    {ComplexTestStruct_h.ComplexTestStruct_rt3(hl, seg, x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), RN.d_u8(hl, x2), _) == (h, (ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}
  %Equal.sym(B.Buf & (VarTestStruct_d.VarTestStruct & D.Digest), VarTestStruct_h.VarTestStruct_root(hl, h, LV.pj_ComplexTestStruct_4(o), seg), (h, (LV.pj_ComplexTestStruct_4(o), d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)))), st_VarTestStruct(hl, h, LV.pj_ComplexTestStruct_4(o), seg, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4)) :
    {ComplexTestStruct_h.ComplexTestStruct_rt4(hl, seg, x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), _) == (h, (ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}
  %Equal.sym(B.Buf & (vec_FixedTestStruct_4_d.v4_FixedTestStruct_Seq & D.Digest), vec_FixedTestStruct_4_h.v4_FixedTestStruct_root(hl, h, LV.pj_ComplexTestStruct_5(o), seg), (h, (LV.pj_ComplexTestStruct_5(o), xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)))), st_v4_FixedTestStruct(hl, h, LV.pj_ComplexTestStruct_5(o), seg, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5)) :
    {ComplexTestStruct_h.ComplexTestStruct_rt5(hl, seg, x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_6(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), _) == (h, (ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}
  %Equal.sym(B.Buf & (vec_VarTestStruct_2_d.v2_VarTestStruct_Seq & D.Digest), vec_VarTestStruct_2_h.v2_VarTestStruct_root(hl, h, LV.pj_ComplexTestStruct_6(o), seg), (h, (LV.pj_ComplexTestStruct_6(o), xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o)))), st_v2_VarTestStruct(hl, h, LV.pj_ComplexTestStruct_6(o), seg, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8)) :
    {ComplexTestStruct_h.ComplexTestStruct_rt6(hl, seg, x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), _) == (h, (ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))) : B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest)}
  {==}
def wd_ComplexTestStruct(+hl: Nat, -o: ComplexTestStruct_d.ComplexTestStruct, +s: S.Schema, +rep: LV.rep_ComplexTestStruct(o, s)) -> OS.DW(d_ComplexTestStruct(hl, o)):
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  (+rp2, +q5) = q4
  (+rp3, +q6) = q5
  (+rp4, +q7) = q6
  (+rp5, +q8) = q7
  +dd1 = OS.dwv(BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), wd_l2(hl, LV.pj_ComplexTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, rp1))
  +de1 = OS.dwe(BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), wd_l2(hl, LV.pj_ComplexTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, rp1))
  +dd3 = OS.dwv(LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), wd_bl(hl, LV.pj_ComplexTestStruct_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, rp3))
  +de3 = OS.dwe(LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), wd_bl(hl, LV.pj_ComplexTestStruct_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, rp3))
  +dd4 = OS.dwv(d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), wd_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4))
  +de4 = OS.dwe(d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), wd_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4))
  +dd5 = OS.dwv(xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), wd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5))
  +de5 = OS.dwe(xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), wd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5))
  +dd6 = OS.dwv(xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o)), wd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8))
  +de6 = OS.dwe(xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o)), wd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8))
  %Equal.sym(ComplexTestStruct_d.ComplexTestStruct, o, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, eo) : OS.DW(d_ComplexTestStruct(hl, _))
  %Equal.sym(D.Digest, BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), dd1, de1) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), _, RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o))], 0n))
  %Equal.sym(D.Digest, LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), dd3, de3) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), _, d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o))], 0n))
  %Equal.sym(D.Digest, d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), dd4, de4) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, _, xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o))], 0n))
  %Equal.sym(D.Digest, xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), dd5, de5) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, _, xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o))], 0n))
  %Equal.sym(D.Digest, xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o)), dd6, de6) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, _], 0n))
  (MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, dd6], 0n), {==})
def rs_ComplexTestStruct(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: ComplexTestStruct_d.ComplexTestStruct, +s: S.Schema, +rep: LV.rep_ComplexTestStruct(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}, +ok: {ok_ComplexTestStruct(s, dv) == True{} : Bool}, +ev: eqs_ComplexTestStruct(s))
    -> RR.roots(LV.v_ComplexTestStruct(o), s, [D.bytes(d_ComplexTestStruct(hl, o))]):
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  (+rp2, +q5) = q4
  (+rp3, +q6) = q5
  (+rp4, +q7) = q6
  (+rp5, +q8) = q7
  (+qe0, +qv0) = ev
  (+qe2, +qv1) = qv0
  (+qe4, +qv2) = qv1
  (+qe5, +qv3) = qv2
  +dd1 = OS.dwv(BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), wd_l2(hl, LV.pj_ComplexTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, rp1))
  +de1 = OS.dwe(BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), wd_l2(hl, LV.pj_ComplexTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, rp1))
  +dd3 = OS.dwv(LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), wd_bl(hl, LV.pj_ComplexTestStruct_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, rp3))
  +de3 = OS.dwe(LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), wd_bl(hl, LV.pj_ComplexTestStruct_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, rp3))
  +dd4 = OS.dwv(d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), wd_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4))
  +de4 = OS.dwe(d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), wd_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4))
  +dd5 = OS.dwv(xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), wd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5))
  +de5 = OS.dwe(xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), wd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5))
  +dd6 = OS.dwv(xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o)), wd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8))
  +de6 = OS.dwe(xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o)), wd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8))
  +k0 = DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
  +r1 = DK.and_r(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
  +k1 = DK.and_l(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))))), r1)
  +r2 = DK.and_r(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))))), r1)
  +k2 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))), r2)
  +r3 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))), r2)
  +k3 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))), r3)
  +r4 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))), r3)
  +k4 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))), r4)
  +r5 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))), r4)
  +k5 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))), r5)
  +r6 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))), r5)
  +k6 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))), r6)
  +r7 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))), r6)
  +k7 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))), r7)
  +r8 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))), r7)
  +k8 = DK.and_l(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))), r8)
  +r9 = DK.and_r(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))), r8)
  +k9 = DK.and_l(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))), r9)
  +r10 = DK.and_r(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))), r9)
  +k10 = DK.and_l(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))), r10)
  +r11 = DK.and_r(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))), r10)
  +k11 = DK.and_l(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)), r11)
  +r12 = DK.and_r(ok_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)), r11)
  +k12 = DK.and_l(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv), r12)
  +r13 = DK.and_r(ok_v4_FixedTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_VarTestStruct(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv), r12)
  %Equal.sym(ComplexTestStruct_d.ComplexTestStruct, o, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}, eo) : RR.roots(LV.v_ComplexTestStruct(_), s, [D.bytes(d_ComplexTestStruct(hl, _))])
  %Equal.sym(S.Schema, s, S.Container{SH.Container_names(s), SH.Container_fields(s)}, SH.Container_shape(s, k0)) :
    RR.roots(LV.v_ComplexTestStruct(ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}), _, [D.bytes(d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))])
  %Equal.sym(S.Schema, SH.Container_fields(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}, fsh_ComplexTestStruct(s, dv, ok)) :
    RR.roots(LV.v_ComplexTestStruct(ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}), S.Container{SH.Container_names(s), _}, [D.bytes(d_ComplexTestStruct(hl, ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}))])
  %Equal.sym(D.Digest, BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), dd1, de1) :
    RR.roots(LV.v_ComplexTestStruct(ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), _, RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o))], 0n))])
  %Equal.sym(D.Digest, LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), dd3, de3) :
    RR.roots(LV.v_ComplexTestStruct(ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), _, d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o))], 0n))])
  %Equal.sym(D.Digest, d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), dd4, de4) :
    RR.roots(LV.v_ComplexTestStruct(ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, _, xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o))], 0n))])
  %Equal.sym(D.Digest, xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), dd5, de5) :
    RR.roots(LV.v_ComplexTestStruct(ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, _, xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o))], 0n))])
  %Equal.sym(D.Digest, xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o)), dd6, de6) :
    RR.roots(LV.v_ComplexTestStruct(ComplexTestStruct_d.ComplexTestStruct{x0, LV.pj_ComplexTestStruct_1(o), x2, LV.pj_ComplexTestStruct_3(o), LV.pj_ComplexTestStruct_4(o), LV.pj_ComplexTestStruct_5(o), LV.pj_ComplexTestStruct_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, _], 0n))])
  (MD.bytes_list([RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, dd6]), (([D.bytes(RN.d_u16(hl, x0))], (MD.bytes_list([dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, dd6]), (OS.transport(RN_L.v_u16(x0), SH.Chain_head(SH.Container_fields(s)), S.Unsigned{P.U16{}}, [D.bytes(RN.d_u16(hl, x0))], qe0, RN.rs_u16(hl, ehl, x0, rp0)), (([D.bytes(dd1)], (MD.bytes_list([RN.d_u8(hl, x2), dd3, dd4, dd5, dd6]), (OS.dtrans(PB_L.vview2(LV.pj_ComplexTestStruct_1(o)), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), dd1, BLI.bdig(hl, LV.pj_ComplexTestStruct_1(o), 3n, 1n), de1, BLI.l2_rs(hl, ehl, h, LV.pj_ComplexTestStruct_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, 3, 0, rp1, k9, {==}, {==})), (([D.bytes(RN.d_u8(hl, x2))], (MD.bytes_list([dd3, dd4, dd5, dd6]), (OS.transport(RN_L.v_u8(x2), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Unsigned{P.U8{}}, [D.bytes(RN.d_u8(hl, x2))], qe2, RN.rs_u8(hl, ehl, x2, rp2)), (([D.bytes(dd3)], (MD.bytes_list([dd4, dd5, dd6]), (OS.dtrans(S.BytesValue{WO_L.wview(LV.pj_ComplexTestStruct_3(o))}, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), dd3, LO.ldig(hl, LV.pj_ComplexTestStruct_3(o), 3n), de3, LO.bl_rs(hl, ehl, h, LV.pj_ComplexTestStruct_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, 3, 0, rp3, k10, {==}, {==})), (([D.bytes(dd4)], (MD.bytes_list([dd5, dd6]), (OS.dtrans(LV.v_VarTestStruct(LV.pj_ComplexTestStruct_4(o)), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dd4, d_VarTestStruct(hl, LV.pj_ComplexTestStruct_4(o)), de4, rs_VarTestStruct(hl, ehl, h, LV.pj_ComplexTestStruct_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4, dv, edv, k11, qe4)), (([D.bytes(dd5)], (MD.bytes_list([dd6]), (OS.dtrans(LV.xv_v4_FixedTestStruct(LV.pj_ComplexTestStruct_5(o)), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), dd5, xd_v4_FixedTestStruct(hl, LV.pj_ComplexTestStruct_5(o)), de5, rs_v4_FixedTestStruct(hl, ehl, h, LV.pj_ComplexTestStruct_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5, k12, qe5)), (([D.bytes(dd6)], (MD.bytes_list([]), (OS.dtrans(LV.xv_v2_VarTestStruct(LV.pj_ComplexTestStruct_6(o)), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dd6, xd_v2_VarTestStruct(hl, LV.pj_ComplexTestStruct_6(o)), de6, rs_v2_VarTestStruct(hl, ehl, h, LV.pj_ComplexTestStruct_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8, dv, edv, r13, qv3)), ({==}, {==})))), {==})))), {==})))), {==})))), {==})))), {==})))), {==})))),
    RS.aggregate_digests(7n, 3n, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, dd6], {==}, {==}, {==}, ehl)))

# proglist_bool: for every packed byte object representing a value of Spec.proglist_bool(),
# the runtime root is a specification root of its elements.
def proglist_bool_ok(+s: S.Schema, +es: {s == Spec.proglist_bool() : S.Schema}) -> {PG.ok_plb(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.proglist_bool(), es) : {PG.ok_plb(_) == True{} : Bool}
  {==}
law proglist_bool_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.proglist_bool() : S.Schema}
  for +rep: PG_L.rep_plb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_bool_h.proglist_bool_hash_tree_root(h, o))))])
def proglist_bool_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 0n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 0n))), PG.pl_st(64n, h, o, 0, 0n, PG_L.rep_wfb(o, s, rep))) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.plb_rs(64n, {==}, o, s, rep, proglist_bool_ok(s, es))

# vec_bool_16: for every packed word object representing a value of Spec.vec_bool_16(),
# the runtime root is a specification root of its elements.
def vec_bool_16_ok(+s: S.Schema, +es: {s == Spec.vec_bool_16() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_16(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law vec_bool_16_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_16() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_16_h.vec_bool_16_hash_tree_root(h, o))))])
def vec_bool_16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, vec_bool_16_ok(s, es), {==})

# vec_bool_1: for every packed word object representing a value of Spec.vec_bool_1(),
# the runtime root is a specification root of its elements.
def vec_bool_1_ok(+s: S.Schema, +es: {s == Spec.vec_bool_1() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_1(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law vec_bool_1_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_1() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_1_h.vec_bool_1_hash_tree_root(h, o))))])
def vec_bool_1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, vec_bool_1_ok(s, es), {==})

# vec_bool_2: for every packed word object representing a value of Spec.vec_bool_2(),
# the runtime root is a specification root of its elements.
def vec_bool_2_ok(+s: S.Schema, +es: {s == Spec.vec_bool_2() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_2(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law vec_bool_2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_2() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_2_h.vec_bool_2_hash_tree_root(h, o))))])
def vec_bool_2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, vec_bool_2_ok(s, es), {==})

# vec_bool_31: for every packed word object representing a value of Spec.vec_bool_31(),
# the runtime root is a specification root of its elements.
def vec_bool_31_ok(+s: S.Schema, +es: {s == Spec.vec_bool_31() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_31(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law vec_bool_31_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_31() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_31_h.vec_bool_31_hash_tree_root(h, o))))])
def vec_bool_31_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, vec_bool_31_ok(s, es), {==})

# vec_bool_3: for every packed word object representing a value of Spec.vec_bool_3(),
# the runtime root is a specification root of its elements.
def vec_bool_3_ok(+s: S.Schema, +es: {s == Spec.vec_bool_3() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_3(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law vec_bool_3_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_3() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_3_h.vec_bool_3_hash_tree_root(h, o))))])
def vec_bool_3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, vec_bool_3_ok(s, es), {==})

# vec_bool_4: for every packed word object representing a value of Spec.vec_bool_4(),
# the runtime root is a specification root of its elements.
def vec_bool_4_ok(+s: S.Schema, +es: {s == Spec.vec_bool_4() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_4(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law vec_bool_4_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_4() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_4_h.vec_bool_4_hash_tree_root(h, o))))])
def vec_bool_4_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, vec_bool_4_ok(s, es), {==})

# vec_bool_512: for every packed word object representing a value of Spec.vec_bool_512(),
# the runtime root is a specification root of its elements.
def vec_bool_512_ok(+s: S.Schema, +es: {s == Spec.vec_bool_512() : S.Schema}) -> {PB.ok_vb(s, 4n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_512(), es) : {PB.ok_vb(_, 4n) == True{} : Bool}
  {==}
law vec_bool_512_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_512() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_512_h.vec_bool_512_hash_tree_root(h, o))))])
def vec_bool_512_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 4, 0), (h, (o, WO_L.wdig(64n, o, 4n))), WO.bv_st(64n, h, o, 4, 0, 4n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 4n, rep, vec_bool_512_ok(s, es), {==})

# vec_bool_513: for every packed word object representing a value of Spec.vec_bool_513(),
# the runtime root is a specification root of its elements.
def vec_bool_513_ok(+s: S.Schema, +es: {s == Spec.vec_bool_513() : S.Schema}) -> {PB.ok_vb(s, 5n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_513(), es) : {PB.ok_vb(_, 5n) == True{} : Bool}
  {==}
law vec_bool_513_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_513() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_513_h.vec_bool_513_hash_tree_root(h, o))))])
def vec_bool_513_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 5, 0), (h, (o, WO_L.wdig(64n, o, 5n))), WO.bv_st(64n, h, o, 5, 0, 5n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 5n, rep, vec_bool_513_ok(s, es), {==})

# vec_bool_5: for every packed word object representing a value of Spec.vec_bool_5(),
# the runtime root is a specification root of its elements.
def vec_bool_5_ok(+s: S.Schema, +es: {s == Spec.vec_bool_5() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_5(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law vec_bool_5_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_5() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_5_h.vec_bool_5_hash_tree_root(h, o))))])
def vec_bool_5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, vec_bool_5_ok(s, es), {==})

# vec_bool_8: for every packed word object representing a value of Spec.vec_bool_8(),
# the runtime root is a specification root of its elements.
def vec_bool_8_ok(+s: S.Schema, +es: {s == Spec.vec_bool_8() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_bool_8(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law vec_bool_8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_bool_8() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_8_h.vec_bool_8_hash_tree_root(h, o))))])
def vec_bool_8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, vec_bool_8_ok(s, es), {==})

# proglist_uint128: for every packed byte object representing a value of Spec.proglist_uint128(),
# the runtime root is a specification root of its elements.
def proglist_uint128_ok(+s: S.Schema, +es: {s == Spec.proglist_uint128() : S.Schema}) -> {PG.ok_pl16(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.proglist_uint128(), es) : {PG.ok_pl16(_) == True{} : Bool}
  {==}
law proglist_uint128_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.proglist_uint128() : S.Schema}
  for +rep: PG_L.rep_pl16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint128_h.proglist_uint128_hash_tree_root(h, o))))])
def proglist_uint128_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 4n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 4n))), PG.pl_st(64n, h, o, 0, 4n, PG_L.rep_wf16(o, s, rep))) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl16_rs(64n, {==}, o, s, rep, proglist_uint128_ok(s, es))

# vec_uint128_16: for every packed word object representing a value of Spec.vec_uint128_16(),
# the runtime root is a specification root of its elements.
def vec_uint128_16_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_16() : S.Schema}) -> {PK.ok_v16(s, 3n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_16(), es) : {PK.ok_v16(_, 3n) == True{} : Bool}
  {==}
law vec_uint128_16_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_16() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_16_h.vec_uint128_16_hash_tree_root(h, o))))])
def vec_uint128_16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 3, 0), (h, (o, WO_L.wdig(64n, o, 3n))), WO.bv_st(64n, h, o, 3, 0, 3n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 3n, rep, vec_uint128_16_ok(s, es), {==})

# vec_uint128_1: for every packed word object representing a value of Spec.vec_uint128_1(),
# the runtime root is a specification root of its elements.
def vec_uint128_1_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_1() : S.Schema}) -> {PK.ok_v16(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_1(), es) : {PK.ok_v16(_, 0n) == True{} : Bool}
  {==}
law vec_uint128_1_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_1() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_1_h.vec_uint128_1_hash_tree_root(h, o))))])
def vec_uint128_1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 0n, rep, vec_uint128_1_ok(s, es), {==})

# vec_uint128_2: for every packed word object representing a value of Spec.vec_uint128_2(),
# the runtime root is a specification root of its elements.
def vec_uint128_2_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_2() : S.Schema}) -> {PK.ok_v16(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_2(), es) : {PK.ok_v16(_, 0n) == True{} : Bool}
  {==}
law vec_uint128_2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_2() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_2_h.vec_uint128_2_hash_tree_root(h, o))))])
def vec_uint128_2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 0n, rep, vec_uint128_2_ok(s, es), {==})

# vec_uint128_31: for every packed word object representing a value of Spec.vec_uint128_31(),
# the runtime root is a specification root of its elements.
def vec_uint128_31_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_31() : S.Schema}) -> {PK.ok_v16(s, 4n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_31(), es) : {PK.ok_v16(_, 4n) == True{} : Bool}
  {==}
law vec_uint128_31_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_31() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_31_h.vec_uint128_31_hash_tree_root(h, o))))])
def vec_uint128_31_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 4, 0), (h, (o, WO_L.wdig(64n, o, 4n))), WO.bv_st(64n, h, o, 4, 0, 4n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 4n, rep, vec_uint128_31_ok(s, es), {==})

# vec_uint128_3: for every packed word object representing a value of Spec.vec_uint128_3(),
# the runtime root is a specification root of its elements.
def vec_uint128_3_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_3() : S.Schema}) -> {PK.ok_v16(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_3(), es) : {PK.ok_v16(_, 1n) == True{} : Bool}
  {==}
law vec_uint128_3_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_3() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_3_h.vec_uint128_3_hash_tree_root(h, o))))])
def vec_uint128_3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 1n, rep, vec_uint128_3_ok(s, es), {==})

# vec_uint128_4: for every packed word object representing a value of Spec.vec_uint128_4(),
# the runtime root is a specification root of its elements.
def vec_uint128_4_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_4() : S.Schema}) -> {PK.ok_v16(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_4(), es) : {PK.ok_v16(_, 1n) == True{} : Bool}
  {==}
law vec_uint128_4_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_4() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_4_h.vec_uint128_4_hash_tree_root(h, o))))])
def vec_uint128_4_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 1n, rep, vec_uint128_4_ok(s, es), {==})

# vec_uint128_512: for every packed word object representing a value of Spec.vec_uint128_512(),
# the runtime root is a specification root of its elements.
def vec_uint128_512_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_512() : S.Schema}) -> {PK.ok_v16(s, 8n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_512(), es) : {PK.ok_v16(_, 8n) == True{} : Bool}
  {==}
law vec_uint128_512_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_512() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_512_h.vec_uint128_512_hash_tree_root(h, o))))])
def vec_uint128_512_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 8, 0), (h, (o, WO_L.wdig(64n, o, 8n))), WO.bv_st(64n, h, o, 8, 0, 8n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 8n, rep, vec_uint128_512_ok(s, es), {==})

# vec_uint128_513: for every packed word object representing a value of Spec.vec_uint128_513(),
# the runtime root is a specification root of its elements.
def vec_uint128_513_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_513() : S.Schema}) -> {PK.ok_v16(s, 9n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_513(), es) : {PK.ok_v16(_, 9n) == True{} : Bool}
  {==}
law vec_uint128_513_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_513() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_513_h.vec_uint128_513_hash_tree_root(h, o))))])
def vec_uint128_513_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 9, 0), (h, (o, WO_L.wdig(64n, o, 9n))), WO.bv_st(64n, h, o, 9, 0, 9n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 9n, rep, vec_uint128_513_ok(s, es), {==})

# vec_uint128_5: for every packed word object representing a value of Spec.vec_uint128_5(),
# the runtime root is a specification root of its elements.
def vec_uint128_5_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_5() : S.Schema}) -> {PK.ok_v16(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_5(), es) : {PK.ok_v16(_, 2n) == True{} : Bool}
  {==}
law vec_uint128_5_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_5() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_5_h.vec_uint128_5_hash_tree_root(h, o))))])
def vec_uint128_5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 2n, rep, vec_uint128_5_ok(s, es), {==})

# vec_uint128_8: for every packed word object representing a value of Spec.vec_uint128_8(),
# the runtime root is a specification root of its elements.
def vec_uint128_8_ok(+s: S.Schema, +es: {s == Spec.vec_uint128_8() : S.Schema}) -> {PK.ok_v16(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint128_8(), es) : {PK.ok_v16(_, 2n) == True{} : Bool}
  {==}
law vec_uint128_8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint128_8() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_8_h.vec_uint128_8_hash_tree_root(h, o))))])
def vec_uint128_8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 2n, rep, vec_uint128_8_ok(s, es), {==})

# proglist_uint8: for every packed byte object representing a value of Spec.proglist_uint8(),
# the runtime root is a specification root of its elements.
def proglist_uint8_ok(+s: S.Schema, +es: {s == Spec.proglist_uint8() : S.Schema}) -> {PG.ok_pl1(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.proglist_uint8(), es) : {PG.ok_pl1(_) == True{} : Bool}
  {==}
law proglist_uint8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.proglist_uint8() : S.Schema}
  for +rep: PG_L.rep_pl1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint8_h.proglist_uint8_hash_tree_root(h, o))))])
def proglist_uint8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 0n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 0n))), PG.pl_st(64n, h, o, 0, 0n, PG_L.rep_wf1(o, s, rep))) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl1_rs(64n, {==}, o, s, rep, proglist_uint8_ok(s, es))

# vec_uint8_16: for every packed word object representing a value of Spec.vec_uint8_16(),
# the runtime root is a specification root of its elements.
def vec_uint8_16_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_16() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_16(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law vec_uint8_16_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_16() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_16_h.vec_uint8_16_hash_tree_root(h, o))))])
def vec_uint8_16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, vec_uint8_16_ok(s, es), {==})

# vec_uint8_1: for every packed word object representing a value of Spec.vec_uint8_1(),
# the runtime root is a specification root of its elements.
def vec_uint8_1_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_1() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_1(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law vec_uint8_1_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_1() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_1_h.vec_uint8_1_hash_tree_root(h, o))))])
def vec_uint8_1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, vec_uint8_1_ok(s, es), {==})

# vec_uint8_2: for every packed word object representing a value of Spec.vec_uint8_2(),
# the runtime root is a specification root of its elements.
def vec_uint8_2_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_2() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_2(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law vec_uint8_2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_2() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_2_h.vec_uint8_2_hash_tree_root(h, o))))])
def vec_uint8_2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, vec_uint8_2_ok(s, es), {==})

# vec_uint8_31: for every packed word object representing a value of Spec.vec_uint8_31(),
# the runtime root is a specification root of its elements.
def vec_uint8_31_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_31() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_31(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law vec_uint8_31_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_31() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_31_h.vec_uint8_31_hash_tree_root(h, o))))])
def vec_uint8_31_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, vec_uint8_31_ok(s, es), {==})

# vec_uint8_3: for every packed word object representing a value of Spec.vec_uint8_3(),
# the runtime root is a specification root of its elements.
def vec_uint8_3_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_3() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_3(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law vec_uint8_3_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_3() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_3_h.vec_uint8_3_hash_tree_root(h, o))))])
def vec_uint8_3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, vec_uint8_3_ok(s, es), {==})

# vec_uint8_4: for every packed word object representing a value of Spec.vec_uint8_4(),
# the runtime root is a specification root of its elements.
def vec_uint8_4_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_4() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_4(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law vec_uint8_4_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_4() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_4_h.vec_uint8_4_hash_tree_root(h, o))))])
def vec_uint8_4_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, vec_uint8_4_ok(s, es), {==})

# vec_uint8_512: for every packed word object representing a value of Spec.vec_uint8_512(),
# the runtime root is a specification root of its elements.
def vec_uint8_512_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_512() : S.Schema}) -> {PB.ok_v1(s, 4n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_512(), es) : {PB.ok_v1(_, 4n) == True{} : Bool}
  {==}
law vec_uint8_512_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_512() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_512_h.vec_uint8_512_hash_tree_root(h, o))))])
def vec_uint8_512_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 4, 0), (h, (o, WO_L.wdig(64n, o, 4n))), WO.bv_st(64n, h, o, 4, 0, 4n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 4n, rep, vec_uint8_512_ok(s, es), {==})

# vec_uint8_513: for every packed word object representing a value of Spec.vec_uint8_513(),
# the runtime root is a specification root of its elements.
def vec_uint8_513_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_513() : S.Schema}) -> {PB.ok_v1(s, 5n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_513(), es) : {PB.ok_v1(_, 5n) == True{} : Bool}
  {==}
law vec_uint8_513_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_513() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_513_h.vec_uint8_513_hash_tree_root(h, o))))])
def vec_uint8_513_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 5, 0), (h, (o, WO_L.wdig(64n, o, 5n))), WO.bv_st(64n, h, o, 5, 0, 5n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 5n, rep, vec_uint8_513_ok(s, es), {==})

# vec_uint8_5: for every packed word object representing a value of Spec.vec_uint8_5(),
# the runtime root is a specification root of its elements.
def vec_uint8_5_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_5() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_5(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law vec_uint8_5_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_5() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_5_h.vec_uint8_5_hash_tree_root(h, o))))])
def vec_uint8_5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, vec_uint8_5_ok(s, es), {==})

# vec_uint8_8: for every packed word object representing a value of Spec.vec_uint8_8(),
# the runtime root is a specification root of its elements.
def vec_uint8_8_ok(+s: S.Schema, +es: {s == Spec.vec_uint8_8() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint8_8(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law vec_uint8_8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint8_8() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_8_h.vec_uint8_8_hash_tree_root(h, o))))])
def vec_uint8_8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, vec_uint8_8_ok(s, es), {==})

# proglist_uint16: for every packed byte object representing a value of Spec.proglist_uint16(),
# the runtime root is a specification root of its elements.
def proglist_uint16_ok(+s: S.Schema, +es: {s == Spec.proglist_uint16() : S.Schema}) -> {PG.ok_pl2(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.proglist_uint16(), es) : {PG.ok_pl2(_) == True{} : Bool}
  {==}
law proglist_uint16_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.proglist_uint16() : S.Schema}
  for +rep: PG_L.rep_pl2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint16_h.proglist_uint16_hash_tree_root(h, o))))])
def proglist_uint16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 1n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 1n))), PG.pl_st(64n, h, o, 0, 1n, PG_L.rep_wf2(o, s, rep))) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl2_rs(64n, {==}, o, s, rep, proglist_uint16_ok(s, es))

# vec_uint16_16: for every packed word object representing a value of Spec.vec_uint16_16(),
# the runtime root is a specification root of its elements.
def vec_uint16_16_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_16() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_16(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law vec_uint16_16_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_16() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_16_h.vec_uint16_16_hash_tree_root(h, o))))])
def vec_uint16_16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, vec_uint16_16_ok(s, es), {==})

# vec_uint16_1: for every packed word object representing a value of Spec.vec_uint16_1(),
# the runtime root is a specification root of its elements.
def vec_uint16_1_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_1() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_1(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law vec_uint16_1_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_1() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_1_h.vec_uint16_1_hash_tree_root(h, o))))])
def vec_uint16_1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, vec_uint16_1_ok(s, es), {==})

# vec_uint16_2: for every packed word object representing a value of Spec.vec_uint16_2(),
# the runtime root is a specification root of its elements.
def vec_uint16_2_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_2() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_2(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law vec_uint16_2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_2() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_2_h.vec_uint16_2_hash_tree_root(h, o))))])
def vec_uint16_2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, vec_uint16_2_ok(s, es), {==})

# vec_uint16_31: for every packed word object representing a value of Spec.vec_uint16_31(),
# the runtime root is a specification root of its elements.
def vec_uint16_31_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_31() : S.Schema}) -> {PB.ok_v2(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_31(), es) : {PB.ok_v2(_, 1n) == True{} : Bool}
  {==}
law vec_uint16_31_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_31() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_31_h.vec_uint16_31_hash_tree_root(h, o))))])
def vec_uint16_31_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 1n, rep, vec_uint16_31_ok(s, es), {==})

# vec_uint16_3: for every packed word object representing a value of Spec.vec_uint16_3(),
# the runtime root is a specification root of its elements.
def vec_uint16_3_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_3() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_3(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law vec_uint16_3_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_3() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_3_h.vec_uint16_3_hash_tree_root(h, o))))])
def vec_uint16_3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, vec_uint16_3_ok(s, es), {==})

# vec_uint16_4: for every packed word object representing a value of Spec.vec_uint16_4(),
# the runtime root is a specification root of its elements.
def vec_uint16_4_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_4() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_4(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law vec_uint16_4_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_4() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_4_h.vec_uint16_4_hash_tree_root(h, o))))])
def vec_uint16_4_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, vec_uint16_4_ok(s, es), {==})

# vec_uint16_512: for every packed word object representing a value of Spec.vec_uint16_512(),
# the runtime root is a specification root of its elements.
def vec_uint16_512_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_512() : S.Schema}) -> {PB.ok_v2(s, 5n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_512(), es) : {PB.ok_v2(_, 5n) == True{} : Bool}
  {==}
law vec_uint16_512_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_512() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_512_h.vec_uint16_512_hash_tree_root(h, o))))])
def vec_uint16_512_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 5, 0), (h, (o, WO_L.wdig(64n, o, 5n))), WO.bv_st(64n, h, o, 5, 0, 5n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 5n, rep, vec_uint16_512_ok(s, es), {==})

# vec_uint16_513: for every packed word object representing a value of Spec.vec_uint16_513(),
# the runtime root is a specification root of its elements.
def vec_uint16_513_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_513() : S.Schema}) -> {PB.ok_v2(s, 6n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_513(), es) : {PB.ok_v2(_, 6n) == True{} : Bool}
  {==}
law vec_uint16_513_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_513() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_513_h.vec_uint16_513_hash_tree_root(h, o))))])
def vec_uint16_513_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 6, 0), (h, (o, WO_L.wdig(64n, o, 6n))), WO.bv_st(64n, h, o, 6, 0, 6n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 6n, rep, vec_uint16_513_ok(s, es), {==})

# vec_uint16_5: for every packed word object representing a value of Spec.vec_uint16_5(),
# the runtime root is a specification root of its elements.
def vec_uint16_5_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_5() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_5(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law vec_uint16_5_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_5() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_5_h.vec_uint16_5_hash_tree_root(h, o))))])
def vec_uint16_5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, vec_uint16_5_ok(s, es), {==})

# vec_uint16_8: for every packed word object representing a value of Spec.vec_uint16_8(),
# the runtime root is a specification root of its elements.
def vec_uint16_8_ok(+s: S.Schema, +es: {s == Spec.vec_uint16_8() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint16_8(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law vec_uint16_8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint16_8() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_8_h.vec_uint16_8_hash_tree_root(h, o))))])
def vec_uint16_8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, vec_uint16_8_ok(s, es), {==})

# proglist_uint256: for every packed byte object representing a value of Spec.proglist_uint256(),
# the runtime root is a specification root of its elements.
def proglist_uint256_ok(+s: S.Schema, +es: {s == Spec.proglist_uint256() : S.Schema}) -> {PG.ok_pl32(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.proglist_uint256(), es) : {PG.ok_pl32(_) == True{} : Bool}
  {==}
law proglist_uint256_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.proglist_uint256() : S.Schema}
  for +rep: PG_L.rep_pl32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint256_h.proglist_uint256_hash_tree_root(h, o))))])
def proglist_uint256_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 5n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 5n))), PG.pl_st(64n, h, o, 0, 5n, PG_L.rep_wf32(o, s, rep))) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl32_rs(64n, {==}, o, s, rep, proglist_uint256_ok(s, es))

# vec_uint256_16: for every packed word object representing a value of Spec.vec_uint256_16(),
# the runtime root is a specification root of its elements.
def vec_uint256_16_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_16() : S.Schema}) -> {PK.ok_v32(s, 4n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_16(), es) : {PK.ok_v32(_, 4n) == True{} : Bool}
  {==}
law vec_uint256_16_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_16() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_16_h.vec_uint256_16_hash_tree_root(h, o))))])
def vec_uint256_16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 4, 0), (h, (o, WO_L.wdig(64n, o, 4n))), WO.bv_st(64n, h, o, 4, 0, 4n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 4n, rep, vec_uint256_16_ok(s, es), {==})

# vec_uint256_1: for every packed word object representing a value of Spec.vec_uint256_1(),
# the runtime root is a specification root of its elements.
def vec_uint256_1_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_1() : S.Schema}) -> {PK.ok_v32(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_1(), es) : {PK.ok_v32(_, 0n) == True{} : Bool}
  {==}
law vec_uint256_1_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_1() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_1_h.vec_uint256_1_hash_tree_root(h, o))))])
def vec_uint256_1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 0n, rep, vec_uint256_1_ok(s, es), {==})

# vec_uint256_2: for every packed word object representing a value of Spec.vec_uint256_2(),
# the runtime root is a specification root of its elements.
def vec_uint256_2_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_2() : S.Schema}) -> {PK.ok_v32(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_2(), es) : {PK.ok_v32(_, 1n) == True{} : Bool}
  {==}
law vec_uint256_2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_2() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_2_h.vec_uint256_2_hash_tree_root(h, o))))])
def vec_uint256_2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 1n, rep, vec_uint256_2_ok(s, es), {==})

# vec_uint256_31: for every packed word object representing a value of Spec.vec_uint256_31(),
# the runtime root is a specification root of its elements.
def vec_uint256_31_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_31() : S.Schema}) -> {PK.ok_v32(s, 5n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_31(), es) : {PK.ok_v32(_, 5n) == True{} : Bool}
  {==}
law vec_uint256_31_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_31() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_31_h.vec_uint256_31_hash_tree_root(h, o))))])
def vec_uint256_31_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 5, 0), (h, (o, WO_L.wdig(64n, o, 5n))), WO.bv_st(64n, h, o, 5, 0, 5n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 5n, rep, vec_uint256_31_ok(s, es), {==})

# vec_uint256_3: for every packed word object representing a value of Spec.vec_uint256_3(),
# the runtime root is a specification root of its elements.
def vec_uint256_3_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_3() : S.Schema}) -> {PK.ok_v32(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_3(), es) : {PK.ok_v32(_, 2n) == True{} : Bool}
  {==}
law vec_uint256_3_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_3() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_3_h.vec_uint256_3_hash_tree_root(h, o))))])
def vec_uint256_3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 2n, rep, vec_uint256_3_ok(s, es), {==})

# vec_uint256_4: for every packed word object representing a value of Spec.vec_uint256_4(),
# the runtime root is a specification root of its elements.
def vec_uint256_4_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_4() : S.Schema}) -> {PK.ok_v32(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_4(), es) : {PK.ok_v32(_, 2n) == True{} : Bool}
  {==}
law vec_uint256_4_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_4() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_4_h.vec_uint256_4_hash_tree_root(h, o))))])
def vec_uint256_4_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 2n, rep, vec_uint256_4_ok(s, es), {==})

# vec_uint256_512: for every packed word object representing a value of Spec.vec_uint256_512(),
# the runtime root is a specification root of its elements.
def vec_uint256_512_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_512() : S.Schema}) -> {PK.ok_v32(s, 9n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_512(), es) : {PK.ok_v32(_, 9n) == True{} : Bool}
  {==}
law vec_uint256_512_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_512() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_512_h.vec_uint256_512_hash_tree_root(h, o))))])
def vec_uint256_512_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 9, 0), (h, (o, WO_L.wdig(64n, o, 9n))), WO.bv_st(64n, h, o, 9, 0, 9n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 9n, rep, vec_uint256_512_ok(s, es), {==})

# vec_uint256_513: for every packed word object representing a value of Spec.vec_uint256_513(),
# the runtime root is a specification root of its elements.
def vec_uint256_513_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_513() : S.Schema}) -> {PK.ok_v32(s, 10n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_513(), es) : {PK.ok_v32(_, 10n) == True{} : Bool}
  {==}
law vec_uint256_513_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_513() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_513_h.vec_uint256_513_hash_tree_root(h, o))))])
def vec_uint256_513_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 10, 0), (h, (o, WO_L.wdig(64n, o, 10n))), WO.bv_st(64n, h, o, 10, 0, 10n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 10n, rep, vec_uint256_513_ok(s, es), {==})

# vec_uint256_5: for every packed word object representing a value of Spec.vec_uint256_5(),
# the runtime root is a specification root of its elements.
def vec_uint256_5_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_5() : S.Schema}) -> {PK.ok_v32(s, 3n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_5(), es) : {PK.ok_v32(_, 3n) == True{} : Bool}
  {==}
law vec_uint256_5_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_5() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_5_h.vec_uint256_5_hash_tree_root(h, o))))])
def vec_uint256_5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 3, 0), (h, (o, WO_L.wdig(64n, o, 3n))), WO.bv_st(64n, h, o, 3, 0, 3n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 3n, rep, vec_uint256_5_ok(s, es), {==})

# vec_uint256_8: for every packed word object representing a value of Spec.vec_uint256_8(),
# the runtime root is a specification root of its elements.
def vec_uint256_8_ok(+s: S.Schema, +es: {s == Spec.vec_uint256_8() : S.Schema}) -> {PK.ok_v32(s, 3n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint256_8(), es) : {PK.ok_v32(_, 3n) == True{} : Bool}
  {==}
law vec_uint256_8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint256_8() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_8_h.vec_uint256_8_hash_tree_root(h, o))))])
def vec_uint256_8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 3, 0), (h, (o, WO_L.wdig(64n, o, 3n))), WO.bv_st(64n, h, o, 3, 0, 3n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 3n, rep, vec_uint256_8_ok(s, es), {==})

# proglist_uint32: for every packed byte object representing a value of Spec.proglist_uint32(),
# the runtime root is a specification root of its elements.
def proglist_uint32_ok(+s: S.Schema, +es: {s == Spec.proglist_uint32() : S.Schema}) -> {PG.ok_pl4(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.proglist_uint32(), es) : {PG.ok_pl4(_) == True{} : Bool}
  {==}
law proglist_uint32_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.proglist_uint32() : S.Schema}
  for +rep: PG_L.rep_pl4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint32_h.proglist_uint32_hash_tree_root(h, o))))])
def proglist_uint32_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 2n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 2n))), PG.pl_st(64n, h, o, 0, 2n, PG_L.rep_wf4(o, s, rep))) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl4_rs(64n, {==}, o, s, rep, proglist_uint32_ok(s, es))

# vec_uint32_16: for every packed word object representing a value of Spec.vec_uint32_16(),
# the runtime root is a specification root of its elements.
def vec_uint32_16_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_16() : S.Schema}) -> {PK.ok_v4(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_16(), es) : {PK.ok_v4(_, 1n) == True{} : Bool}
  {==}
law vec_uint32_16_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_16() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_16_h.vec_uint32_16_hash_tree_root(h, o))))])
def vec_uint32_16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 1n, rep, vec_uint32_16_ok(s, es), {==})

# vec_uint32_1: for every packed word object representing a value of Spec.vec_uint32_1(),
# the runtime root is a specification root of its elements.
def vec_uint32_1_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_1() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_1(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law vec_uint32_1_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_1() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_1_h.vec_uint32_1_hash_tree_root(h, o))))])
def vec_uint32_1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, vec_uint32_1_ok(s, es), {==})

# vec_uint32_2: for every packed word object representing a value of Spec.vec_uint32_2(),
# the runtime root is a specification root of its elements.
def vec_uint32_2_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_2() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_2(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law vec_uint32_2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_2() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_2_h.vec_uint32_2_hash_tree_root(h, o))))])
def vec_uint32_2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, vec_uint32_2_ok(s, es), {==})

# vec_uint32_31: for every packed word object representing a value of Spec.vec_uint32_31(),
# the runtime root is a specification root of its elements.
def vec_uint32_31_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_31() : S.Schema}) -> {PK.ok_v4(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_31(), es) : {PK.ok_v4(_, 2n) == True{} : Bool}
  {==}
law vec_uint32_31_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_31() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_31_h.vec_uint32_31_hash_tree_root(h, o))))])
def vec_uint32_31_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 2n, rep, vec_uint32_31_ok(s, es), {==})

# vec_uint32_3: for every packed word object representing a value of Spec.vec_uint32_3(),
# the runtime root is a specification root of its elements.
def vec_uint32_3_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_3() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_3(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law vec_uint32_3_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_3() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_3_h.vec_uint32_3_hash_tree_root(h, o))))])
def vec_uint32_3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, vec_uint32_3_ok(s, es), {==})

# vec_uint32_4: for every packed word object representing a value of Spec.vec_uint32_4(),
# the runtime root is a specification root of its elements.
def vec_uint32_4_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_4() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_4(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law vec_uint32_4_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_4() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_4_h.vec_uint32_4_hash_tree_root(h, o))))])
def vec_uint32_4_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, vec_uint32_4_ok(s, es), {==})

# vec_uint32_512: for every packed word object representing a value of Spec.vec_uint32_512(),
# the runtime root is a specification root of its elements.
def vec_uint32_512_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_512() : S.Schema}) -> {PK.ok_v4(s, 6n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_512(), es) : {PK.ok_v4(_, 6n) == True{} : Bool}
  {==}
law vec_uint32_512_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_512() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_512_h.vec_uint32_512_hash_tree_root(h, o))))])
def vec_uint32_512_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 6, 0), (h, (o, WO_L.wdig(64n, o, 6n))), WO.bv_st(64n, h, o, 6, 0, 6n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 6n, rep, vec_uint32_512_ok(s, es), {==})

# vec_uint32_513: for every packed word object representing a value of Spec.vec_uint32_513(),
# the runtime root is a specification root of its elements.
def vec_uint32_513_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_513() : S.Schema}) -> {PK.ok_v4(s, 7n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_513(), es) : {PK.ok_v4(_, 7n) == True{} : Bool}
  {==}
law vec_uint32_513_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_513() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_513_h.vec_uint32_513_hash_tree_root(h, o))))])
def vec_uint32_513_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 7, 0), (h, (o, WO_L.wdig(64n, o, 7n))), WO.bv_st(64n, h, o, 7, 0, 7n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 7n, rep, vec_uint32_513_ok(s, es), {==})

# vec_uint32_5: for every packed word object representing a value of Spec.vec_uint32_5(),
# the runtime root is a specification root of its elements.
def vec_uint32_5_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_5() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_5(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law vec_uint32_5_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_5() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_5_h.vec_uint32_5_hash_tree_root(h, o))))])
def vec_uint32_5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, vec_uint32_5_ok(s, es), {==})

# vec_uint32_8: for every packed word object representing a value of Spec.vec_uint32_8(),
# the runtime root is a specification root of its elements.
def vec_uint32_8_ok(+s: S.Schema, +es: {s == Spec.vec_uint32_8() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint32_8(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law vec_uint32_8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint32_8() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_8_h.vec_uint32_8_hash_tree_root(h, o))))])
def vec_uint32_8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, vec_uint32_8_ok(s, es), {==})

# proglist_uint64: for every packed byte object representing a value of Spec.proglist_uint64(),
# the runtime root is a specification root of its elements.
def proglist_uint64_ok(+s: S.Schema, +es: {s == Spec.proglist_uint64() : S.Schema}) -> {PG.ok_pl8(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.proglist_uint64(), es) : {PG.ok_pl8(_) == True{} : Bool}
  {==}
law proglist_uint64_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.proglist_uint64() : S.Schema}
  for +rep: PG_L.rep_pl8(o, s)
  RR.roots(UL_L.uview(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint64_h.proglist_uint64_hash_tree_root(h, o))))])
def proglist_uint64_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 3n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 3n))), PG.pl_st(64n, h, o, 0, 3n, PG_L.rep_wf8(o, s, rep))) :
    RR.roots(UL_L.uview(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl8_rs(64n, {==}, o, s, rep, proglist_uint64_ok(s, es))

# vec_uint64_16: for every packed word object representing a value of Spec.vec_uint64_16(),
# the runtime root is a specification root of its elements.
def vec_uint64_16_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_16() : S.Schema}) -> {PK.ok_v8(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_16(), es) : {PK.ok_v8(_, 2n) == True{} : Bool}
  {==}
law vec_uint64_16_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_16() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_16_h.vec_uint64_16_hash_tree_root(h, o))))])
def vec_uint64_16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 2n, rep, vec_uint64_16_ok(s, es), {==})

# vec_uint64_1: for every packed word object representing a value of Spec.vec_uint64_1(),
# the runtime root is a specification root of its elements.
def vec_uint64_1_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_1() : S.Schema}) -> {PK.ok_v8(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_1(), es) : {PK.ok_v8(_, 0n) == True{} : Bool}
  {==}
law vec_uint64_1_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_1() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_1_h.vec_uint64_1_hash_tree_root(h, o))))])
def vec_uint64_1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 0n, rep, vec_uint64_1_ok(s, es), {==})

# vec_uint64_2: for every packed word object representing a value of Spec.vec_uint64_2(),
# the runtime root is a specification root of its elements.
def vec_uint64_2_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_2() : S.Schema}) -> {PK.ok_v8(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_2(), es) : {PK.ok_v8(_, 0n) == True{} : Bool}
  {==}
law vec_uint64_2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_2() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_2_h.vec_uint64_2_hash_tree_root(h, o))))])
def vec_uint64_2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 0n, rep, vec_uint64_2_ok(s, es), {==})

# vec_uint64_31: for every packed word object representing a value of Spec.vec_uint64_31(),
# the runtime root is a specification root of its elements.
def vec_uint64_31_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_31() : S.Schema}) -> {PK.ok_v8(s, 3n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_31(), es) : {PK.ok_v8(_, 3n) == True{} : Bool}
  {==}
law vec_uint64_31_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_31() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_31_h.vec_uint64_31_hash_tree_root(h, o))))])
def vec_uint64_31_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 3, 0), (h, (o, WO_L.wdig(64n, o, 3n))), WO.bv_st(64n, h, o, 3, 0, 3n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 3n, rep, vec_uint64_31_ok(s, es), {==})

# vec_uint64_3: for every packed word object representing a value of Spec.vec_uint64_3(),
# the runtime root is a specification root of its elements.
def vec_uint64_3_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_3() : S.Schema}) -> {PK.ok_v8(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_3(), es) : {PK.ok_v8(_, 0n) == True{} : Bool}
  {==}
law vec_uint64_3_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_3() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_3_h.vec_uint64_3_hash_tree_root(h, o))))])
def vec_uint64_3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 0n, rep, vec_uint64_3_ok(s, es), {==})

# vec_uint64_4: for every packed word object representing a value of Spec.vec_uint64_4(),
# the runtime root is a specification root of its elements.
def vec_uint64_4_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_4() : S.Schema}) -> {PK.ok_v8(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_4(), es) : {PK.ok_v8(_, 0n) == True{} : Bool}
  {==}
law vec_uint64_4_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_4() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_4_h.vec_uint64_4_hash_tree_root(h, o))))])
def vec_uint64_4_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 0n, rep, vec_uint64_4_ok(s, es), {==})

# vec_uint64_512: for every packed word object representing a value of Spec.vec_uint64_512(),
# the runtime root is a specification root of its elements.
def vec_uint64_512_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_512() : S.Schema}) -> {PK.ok_v8(s, 7n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_512(), es) : {PK.ok_v8(_, 7n) == True{} : Bool}
  {==}
law vec_uint64_512_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_512() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_512_h.vec_uint64_512_hash_tree_root(h, o))))])
def vec_uint64_512_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 7, 0), (h, (o, WO_L.wdig(64n, o, 7n))), WO.bv_st(64n, h, o, 7, 0, 7n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 7n, rep, vec_uint64_512_ok(s, es), {==})

# vec_uint64_513: for every packed word object representing a value of Spec.vec_uint64_513(),
# the runtime root is a specification root of its elements.
def vec_uint64_513_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_513() : S.Schema}) -> {PK.ok_v8(s, 8n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_513(), es) : {PK.ok_v8(_, 8n) == True{} : Bool}
  {==}
law vec_uint64_513_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_513() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_513_h.vec_uint64_513_hash_tree_root(h, o))))])
def vec_uint64_513_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 8, 0), (h, (o, WO_L.wdig(64n, o, 8n))), WO.bv_st(64n, h, o, 8, 0, 8n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 8n, rep, vec_uint64_513_ok(s, es), {==})

# vec_uint64_5: for every packed word object representing a value of Spec.vec_uint64_5(),
# the runtime root is a specification root of its elements.
def vec_uint64_5_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_5() : S.Schema}) -> {PK.ok_v8(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_5(), es) : {PK.ok_v8(_, 1n) == True{} : Bool}
  {==}
law vec_uint64_5_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_5() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_5_h.vec_uint64_5_hash_tree_root(h, o))))])
def vec_uint64_5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 1n, rep, vec_uint64_5_ok(s, es), {==})

# vec_uint64_8: for every packed word object representing a value of Spec.vec_uint64_8(),
# the runtime root is a specification root of its elements.
def vec_uint64_8_ok(+s: S.Schema, +es: {s == Spec.vec_uint64_8() : S.Schema}) -> {PK.ok_v8(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.vec_uint64_8(), es) : {PK.ok_v8(_, 1n) == True{} : Bool}
  {==}
law vec_uint64_8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.vec_uint64_8() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_8_h.vec_uint64_8_hash_tree_root(h, o))))])
def vec_uint64_8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 1n, rep, vec_uint64_8_ok(s, es), {==})

# VarTestStruct: for every object representing a value of Spec.VarTestStruct(), the runtime
# root is a specification root of that value.
def VarTestStruct_ok(+s: S.Schema, +es: {s == Spec.VarTestStruct() : S.Schema}, +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}) -> {ok_VarTestStruct(s, dv) == True{} : Bool}:
  OS.ok_at(y => d => ok_VarTestStruct(y, d), s, Spec.VarTestStruct(), dv, es, edv, {==})
def VarTestStruct_eqs(+s: S.Schema, +es: {s == Spec.VarTestStruct() : S.Schema}) -> eqs_VarTestStruct(s): (OS.eq_at(y => SH.Chain_head(SH.Container_fields(y)), s, Spec.VarTestStruct(), S.Unsigned{P.U16{}}, es, {==}), OS.eq_at(y => SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))), s, Spec.VarTestStruct(), S.Unsigned{P.U8{}}, es, {==}))
def VarTestStruct_rc(-h: B.Buf, -o: VarTestStruct_d.VarTestStruct, +s: S.Schema, +es: {s == Spec.VarTestStruct() : S.Schema}, +rep: LV.rep_VarTestStruct(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV})
    -> RR.roots(LV.v_VarTestStruct(o), s, [D.bytes(Pair.snd(VarTestStruct_d.VarTestStruct, D.Digest, Pair.snd(B.Buf, VarTestStruct_d.VarTestStruct & D.Digest, VarTestStruct_h.VarTestStruct_hash_tree_root(h, o))))]):
  %Equal.sym(B.Buf & (VarTestStruct_d.VarTestStruct & D.Digest), VarTestStruct_h.VarTestStruct_root(64n, h, o, 0), (h, (o, d_VarTestStruct(64n, o))), st_VarTestStruct(64n, h, o, 0, s, rep)) :
    RR.roots(LV.v_VarTestStruct(o), s, [D.bytes(Pair.snd(VarTestStruct_d.VarTestStruct, D.Digest, Pair.snd(B.Buf, VarTestStruct_d.VarTestStruct & D.Digest, _)))])
  rs_VarTestStruct(64n, {==}, h, o, s, rep, dv, edv, VarTestStruct_ok(s, es, dv, edv), VarTestStruct_eqs(s, es))
law VarTestStruct_root_correct:
  for -h: B.Buf
  for -o: VarTestStruct_d.VarTestStruct
  for +s: S.Schema
  for +es: {s == Spec.VarTestStruct() : S.Schema}
  for +rep: LV.rep_VarTestStruct(o, s)
  RR.roots(LV.v_VarTestStruct(o), s, [D.bytes(Pair.snd(VarTestStruct_d.VarTestStruct, D.Digest, Pair.snd(B.Buf, VarTestStruct_d.VarTestStruct & D.Digest, VarTestStruct_h.VarTestStruct_hash_tree_root(h, o))))])
def VarTestStruct_root_correct(h, o, s, es, rep): VarTestStruct_rc(h, o, s, es, rep, OS.DV0(), {==})

# ComplexTestStruct: for every object representing a value of Spec.ComplexTestStruct(), the runtime
# root is a specification root of that value.
def ComplexTestStruct_ok(+s: S.Schema, +es: {s == Spec.ComplexTestStruct() : S.Schema}, +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}) -> {ok_ComplexTestStruct(s, dv) == True{} : Bool}:
  OS.ok_at(y => d => ok_ComplexTestStruct(y, d), s, Spec.ComplexTestStruct(), dv, es, edv, {==})
def ComplexTestStruct_eqs(+s: S.Schema, +es: {s == Spec.ComplexTestStruct() : S.Schema}) -> eqs_ComplexTestStruct(s): (OS.eq_at(y => SH.Chain_head(SH.Container_fields(y)), s, Spec.ComplexTestStruct(), S.Unsigned{P.U16{}}, es, {==}), (OS.eq_at(y => SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))), s, Spec.ComplexTestStruct(), S.Unsigned{P.U8{}}, es, {==}), ((OS.eq_at(y => SH.Chain_head(SH.Container_fields(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))))))), s, Spec.ComplexTestStruct(), S.Unsigned{P.U16{}}, es, {==}), OS.eq_at(y => SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))))))))), s, Spec.ComplexTestStruct(), S.Unsigned{P.U8{}}, es, {==})), (OS.eq_at(y => SH.Vector_element(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))))))), s, Spec.ComplexTestStruct(), S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, es, {==}), (OS.eq_at(y => SH.Chain_head(SH.Container_fields(SH.Vector_element(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y))))))))))), s, Spec.ComplexTestStruct(), S.Unsigned{P.U16{}}, es, {==}), OS.eq_at(y => SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(SH.Vector_element(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y))))))))))))), s, Spec.ComplexTestStruct(), S.Unsigned{P.U8{}}, es, {==}))))))
def ComplexTestStruct_rc(-h: B.Buf, -o: ComplexTestStruct_d.ComplexTestStruct, +s: S.Schema, +es: {s == Spec.ComplexTestStruct() : S.Schema}, +rep: LV.rep_ComplexTestStruct(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV})
    -> RR.roots(LV.v_ComplexTestStruct(o), s, [D.bytes(Pair.snd(ComplexTestStruct_d.ComplexTestStruct, D.Digest, Pair.snd(B.Buf, ComplexTestStruct_d.ComplexTestStruct & D.Digest, ComplexTestStruct_h.ComplexTestStruct_hash_tree_root(h, o))))]):
  %Equal.sym(B.Buf & (ComplexTestStruct_d.ComplexTestStruct & D.Digest), ComplexTestStruct_h.ComplexTestStruct_root(64n, h, o, 0), (h, (o, d_ComplexTestStruct(64n, o))), st_ComplexTestStruct(64n, h, o, 0, s, rep)) :
    RR.roots(LV.v_ComplexTestStruct(o), s, [D.bytes(Pair.snd(ComplexTestStruct_d.ComplexTestStruct, D.Digest, Pair.snd(B.Buf, ComplexTestStruct_d.ComplexTestStruct & D.Digest, _)))])
  rs_ComplexTestStruct(64n, {==}, h, o, s, rep, dv, edv, ComplexTestStruct_ok(s, es, dv, edv), ComplexTestStruct_eqs(s, es))
law ComplexTestStruct_root_correct:
  for -h: B.Buf
  for -o: ComplexTestStruct_d.ComplexTestStruct
  for +s: S.Schema
  for +es: {s == Spec.ComplexTestStruct() : S.Schema}
  for +rep: LV.rep_ComplexTestStruct(o, s)
  RR.roots(LV.v_ComplexTestStruct(o), s, [D.bytes(Pair.snd(ComplexTestStruct_d.ComplexTestStruct, D.Digest, Pair.snd(B.Buf, ComplexTestStruct_d.ComplexTestStruct & D.Digest, ComplexTestStruct_h.ComplexTestStruct_hash_tree_root(h, o))))])
def ComplexTestStruct_root_correct(h, o, s, es, rep): ComplexTestStruct_rc(h, o, s, es, rep, OS.DV0(), {==})

# bitlist_15: for every bit list object representing a value of Spec.bitlist_15(),
# the runtime root is a specification root of its bits.
def bitlist_15_ok(+s: S.Schema, +es: {s == Spec.bitlist_15() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_15(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_15_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_15() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_15_h.bitlist_15_hash_tree_root(h, o))))])
def bitlist_15_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_15_ok(s, es), {==}, {==})

# bitlist_16: for every bit list object representing a value of Spec.bitlist_16(),
# the runtime root is a specification root of its bits.
def bitlist_16_ok(+s: S.Schema, +es: {s == Spec.bitlist_16() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_16(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_16_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_16() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_16_h.bitlist_16_hash_tree_root(h, o))))])
def bitlist_16_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_16_ok(s, es), {==}, {==})

# bitlist_17: for every bit list object representing a value of Spec.bitlist_17(),
# the runtime root is a specification root of its bits.
def bitlist_17_ok(+s: S.Schema, +es: {s == Spec.bitlist_17() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_17(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_17_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_17() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_17_h.bitlist_17_hash_tree_root(h, o))))])
def bitlist_17_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_17_ok(s, es), {==}, {==})

# bitlist_1: for every bit list object representing a value of Spec.bitlist_1(),
# the runtime root is a specification root of its bits.
def bitlist_1_ok(+s: S.Schema, +es: {s == Spec.bitlist_1() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_1(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_1_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_1() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_1_h.bitlist_1_hash_tree_root(h, o))))])
def bitlist_1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_1_ok(s, es), {==}, {==})

# bitlist_2: for every bit list object representing a value of Spec.bitlist_2(),
# the runtime root is a specification root of its bits.
def bitlist_2_ok(+s: S.Schema, +es: {s == Spec.bitlist_2() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_2(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_2_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_2() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_2_h.bitlist_2_hash_tree_root(h, o))))])
def bitlist_2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_2_ok(s, es), {==}, {==})

# bitlist_31: for every bit list object representing a value of Spec.bitlist_31(),
# the runtime root is a specification root of its bits.
def bitlist_31_ok(+s: S.Schema, +es: {s == Spec.bitlist_31() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_31(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_31_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_31() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_31_h.bitlist_31_hash_tree_root(h, o))))])
def bitlist_31_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_31_ok(s, es), {==}, {==})

# bitlist_32: for every bit list object representing a value of Spec.bitlist_32(),
# the runtime root is a specification root of its bits.
def bitlist_32_ok(+s: S.Schema, +es: {s == Spec.bitlist_32() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_32(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_32_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_32() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_32_h.bitlist_32_hash_tree_root(h, o))))])
def bitlist_32_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_32_ok(s, es), {==}, {==})

# bitlist_33: for every bit list object representing a value of Spec.bitlist_33(),
# the runtime root is a specification root of its bits.
def bitlist_33_ok(+s: S.Schema, +es: {s == Spec.bitlist_33() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_33(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_33_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_33() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_33_h.bitlist_33_hash_tree_root(h, o))))])
def bitlist_33_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_33_ok(s, es), {==}, {==})

# bitlist_3: for every bit list object representing a value of Spec.bitlist_3(),
# the runtime root is a specification root of its bits.
def bitlist_3_ok(+s: S.Schema, +es: {s == Spec.bitlist_3() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_3(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_3_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_3() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_3_h.bitlist_3_hash_tree_root(h, o))))])
def bitlist_3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_3_ok(s, es), {==}, {==})

# bitlist_4: for every bit list object representing a value of Spec.bitlist_4(),
# the runtime root is a specification root of its bits.
def bitlist_4_ok(+s: S.Schema, +es: {s == Spec.bitlist_4() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_4(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_4_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_4() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_4_h.bitlist_4_hash_tree_root(h, o))))])
def bitlist_4_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_4_ok(s, es), {==}, {==})

# bitlist_511: for every bit list object representing a value of Spec.bitlist_511(),
# the runtime root is a specification root of its bits.
def bitlist_511_ok(+s: S.Schema, +es: {s == Spec.bitlist_511() : S.Schema}) -> {BO_L.ok_bits(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_511(), es) : {BO_L.ok_bits(_, 1n) == True{} : Bool}
  {==}
law bitlist_511_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_511() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_511_h.bitlist_511_hash_tree_root(h, o))))])
def bitlist_511_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 1, 0), (h, (o, BO.bdig(64n, o, 1n))), BO.bst(64n, h, o, 1, 0, 1n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 1n, 1, 0, rep, bitlist_511_ok(s, es), {==}, {==})

# bitlist_512: for every bit list object representing a value of Spec.bitlist_512(),
# the runtime root is a specification root of its bits.
def bitlist_512_ok(+s: S.Schema, +es: {s == Spec.bitlist_512() : S.Schema}) -> {BO_L.ok_bits(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_512(), es) : {BO_L.ok_bits(_, 1n) == True{} : Bool}
  {==}
law bitlist_512_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_512() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_512_h.bitlist_512_hash_tree_root(h, o))))])
def bitlist_512_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 1, 0), (h, (o, BO.bdig(64n, o, 1n))), BO.bst(64n, h, o, 1, 0, 1n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 1n, 1, 0, rep, bitlist_512_ok(s, es), {==}, {==})

# bitlist_513: for every bit list object representing a value of Spec.bitlist_513(),
# the runtime root is a specification root of its bits.
def bitlist_513_ok(+s: S.Schema, +es: {s == Spec.bitlist_513() : S.Schema}) -> {BO_L.ok_bits(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_513(), es) : {BO_L.ok_bits(_, 2n) == True{} : Bool}
  {==}
law bitlist_513_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_513() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_513_h.bitlist_513_hash_tree_root(h, o))))])
def bitlist_513_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 2, 0), (h, (o, BO.bdig(64n, o, 2n))), BO.bst(64n, h, o, 2, 0, 2n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 2n, 2, 0, rep, bitlist_513_ok(s, es), {==}, {==})

# bitlist_5: for every bit list object representing a value of Spec.bitlist_5(),
# the runtime root is a specification root of its bits.
def bitlist_5_ok(+s: S.Schema, +es: {s == Spec.bitlist_5() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_5(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_5_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_5() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_5_h.bitlist_5_hash_tree_root(h, o))))])
def bitlist_5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_5_ok(s, es), {==}, {==})

# bitlist_6: for every bit list object representing a value of Spec.bitlist_6(),
# the runtime root is a specification root of its bits.
def bitlist_6_ok(+s: S.Schema, +es: {s == Spec.bitlist_6() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_6(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_6_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_6() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_6_h.bitlist_6_hash_tree_root(h, o))))])
def bitlist_6_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_6_ok(s, es), {==}, {==})

# bitlist_7: for every bit list object representing a value of Spec.bitlist_7(),
# the runtime root is a specification root of its bits.
def bitlist_7_ok(+s: S.Schema, +es: {s == Spec.bitlist_7() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_7(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_7_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_7() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_7_h.bitlist_7_hash_tree_root(h, o))))])
def bitlist_7_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_7_ok(s, es), {==}, {==})

# bitlist_8: for every bit list object representing a value of Spec.bitlist_8(),
# the runtime root is a specification root of its bits.
def bitlist_8_ok(+s: S.Schema, +es: {s == Spec.bitlist_8() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_8(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_8_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_8() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_8_h.bitlist_8_hash_tree_root(h, o))))])
def bitlist_8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_8_ok(s, es), {==}, {==})

# bitlist_9: for every bit list object representing a value of Spec.bitlist_9(),
# the runtime root is a specification root of its bits.
def bitlist_9_ok(+s: S.Schema, +es: {s == Spec.bitlist_9() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.bitlist_9(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law bitlist_9_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.bitlist_9() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_9_h.bitlist_9_hash_tree_root(h, o))))])
def bitlist_9_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, bitlist_9_ok(s, es), {==}, {==})

