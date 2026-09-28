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

# GENERATED by codegen/root_laws_generic.py (via root_laws_b.py). Do not edit.
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

def fzth_w(+m: LV.WMr) -> {LV.fz_w(LV.th_w(m)) == m : LV.WMr}:
  match m:
    case LV.WMr{+t, +n}:
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) : {LV.WMr{_, n} == LV.WMr{t, n} : LV.WMr}
      {==}
def fzth_b(+m: LV.BMr) -> {LV.fz_b(LV.th_b(m)) == m : LV.BMr}:
  match m:
    case LV.BMr{+t, +k}:
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) : {LV.BMr{_, k} == LV.BMr{t, k} : LV.BMr}
      {==}
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

def d_Gc465214E502(+hl: Nat, o: VarTestStruct_d.Gc465214E502) -> D.Digest:
  match o:
    case VarTestStruct_d.Gc465214E502{+x0, x1, +x2}: MD.rtree(2n, True{}, hl, [RN.d_u16(hl, x0), BLI.bdig(hl, x1, 6n, 1n), RN.d_u8(hl, x2)], 0n)
def ok_Gc465214E502(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))))))
def okc_Gc465214E502(+s: S.Schema, +dv: OS.DV, +ok: {ok_Gc465214E502(s, dv) == True{} : Bool}) -> {SH.is_Container(s) == True{} : Bool}: DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n))))), ok)
def eqs_Gc465214E502(+s: S.Schema) -> Data: DK.P2({SH.Chain_head(SH.Container_fields(s)) == S.Unsigned{P.U16{}} : S.Schema}, {SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))) == S.Unsigned{P.U8{}} : S.Schema})
def fsh_Gc465214E502(+s: S.Schema, +dv: OS.DV, +ok: {ok_Gc465214E502(s, dv) == True{} : Bool}) -> {SH.Container_fields(s) == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}} : S.Schema}:
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
def st_Gc465214E502(+hl: Nat, -h: B.Buf, -o: VarTestStruct_d.Gc465214E502, +seg: U32, +s: S.Schema, +rep: LV.rep_Gc465214E502(o, s))
    -> {VarTestStruct_h.Gc465214E502_root(hl, h, o, seg) == (h, (o, d_Gc465214E502(hl, o))) : B.Buf & (VarTestStruct_d.Gc465214E502 & D.Digest)}:
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  %Equal.sym(VarTestStruct_d.Gc465214E502, o, VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}, eo) :
    {VarTestStruct_h.Gc465214E502_root(hl, h, _, seg) == (h, (_, d_Gc465214E502(hl, _))) : B.Buf & (VarTestStruct_d.Gc465214E502 & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, uint16_h.u16_root(hl, h, x0, seg), (h, RN.d_u16(hl, x0)), RN.st_u16(hl, h, x0, seg)) :
    {VarTestStruct_h.Gc465214E502_rt0(hl, seg, x0, LV.pj_Gc465214E502_1(o), x2, _) == (h, (VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}, d_Gc465214E502(hl, VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}))) : B.Buf & (VarTestStruct_d.Gc465214E502 & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), list_uint16_1024_h.l1024_u16_root(hl, h, LV.pj_Gc465214E502_1(o), seg), (h, (LV.pj_Gc465214E502_1(o), BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n))), BLI.bl_st(hl, h, LV.pj_Gc465214E502_1(o), 6, seg, 6n, 1n, BLI_L.rep_wf2(LV.pj_Gc465214E502_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), rp1), {==})) :
    {VarTestStruct_h.Gc465214E502_rt1(hl, seg, x0, x2, RN.d_u16(hl, x0), _) == (h, (VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}, d_Gc465214E502(hl, VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}))) : B.Buf & (VarTestStruct_d.Gc465214E502 & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, uint8_h.u8_root(hl, h, x2, seg), (h, RN.d_u8(hl, x2)), RN.st_u8(hl, h, x2, seg)) :
    {VarTestStruct_h.Gc465214E502_rt2(hl, seg, x0, LV.pj_Gc465214E502_1(o), x2, RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n), _) == (h, (VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}, d_Gc465214E502(hl, VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}))) : B.Buf & (VarTestStruct_d.Gc465214E502 & D.Digest)}
  {==}
def wd_Gc465214E502(+hl: Nat, -o: VarTestStruct_d.Gc465214E502, +s: S.Schema, +rep: LV.rep_Gc465214E502(o, s)) -> OS.DW(d_Gc465214E502(hl, o)):
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  +dd1 = OS.dwv(BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n), wd_l2(hl, LV.pj_Gc465214E502_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, rp1))
  +de1 = OS.dwe(BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n), wd_l2(hl, LV.pj_Gc465214E502_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, rp1))
  %Equal.sym(VarTestStruct_d.Gc465214E502, o, VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}, eo) : OS.DW(d_Gc465214E502(hl, _))
  %Equal.sym(D.Digest, BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n), dd1, de1) :
    OS.DW(MD.rtree(2n, True{}, hl, [RN.d_u16(hl, x0), _, RN.d_u8(hl, x2)], 0n))
  (MD.rtree(2n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2)], 0n), {==})
def rs_Gc465214E502(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: VarTestStruct_d.Gc465214E502, +s: S.Schema, +rep: LV.rep_Gc465214E502(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}, +ok: {ok_Gc465214E502(s, dv) == True{} : Bool}, +ev: eqs_Gc465214E502(s))
    -> RR.roots(LV.v_Gc465214E502(o), s, [D.bytes(d_Gc465214E502(hl, o))]):
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  (+qe0, +qv0) = ev
  +dd1 = OS.dwv(BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n), wd_l2(hl, LV.pj_Gc465214E502_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, rp1))
  +de1 = OS.dwe(BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n), wd_l2(hl, LV.pj_Gc465214E502_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, rp1))
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
  %Equal.sym(VarTestStruct_d.Gc465214E502, o, VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}, eo) : RR.roots(LV.v_Gc465214E502(_), s, [D.bytes(d_Gc465214E502(hl, _))])
  %Equal.sym(S.Schema, s, S.Container{SH.Container_names(s), SH.Container_fields(s)}, SH.Container_shape(s, k0)) :
    RR.roots(LV.v_Gc465214E502(VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}), _, [D.bytes(d_Gc465214E502(hl, VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}))])
  %Equal.sym(S.Schema, SH.Container_fields(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}}, fsh_Gc465214E502(s, dv, ok)) :
    RR.roots(LV.v_Gc465214E502(VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}), S.Container{SH.Container_names(s), _}, [D.bytes(d_Gc465214E502(hl, VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}))])
  %Equal.sym(D.Digest, BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n), dd1, de1) :
    RR.roots(LV.v_Gc465214E502(VarTestStruct_d.Gc465214E502{x0, LV.pj_Gc465214E502_1(o), x2}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.End{}}}}}, [D.bytes(MD.rtree(2n, True{}, hl, [RN.d_u16(hl, x0), _, RN.d_u8(hl, x2)], 0n))])
  (MD.bytes_list([RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2)]), (([D.bytes(RN.d_u16(hl, x0))], (MD.bytes_list([dd1, RN.d_u8(hl, x2)]), (OS.transport(RN_L.v_u16(x0), SH.Chain_head(SH.Container_fields(s)), S.Unsigned{P.U16{}}, [D.bytes(RN.d_u16(hl, x0))], qe0, RN.rs_u16(hl, ehl, x0, rp0)), (([D.bytes(dd1)], (MD.bytes_list([RN.d_u8(hl, x2)]), (OS.dtrans(PB_L.vview2(LV.pj_Gc465214E502_1(o)), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), dd1, BLI.bdig(hl, LV.pj_Gc465214E502_1(o), 6n, 1n), de1, BLI.l2_rs(hl, ehl, h, LV.pj_Gc465214E502_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 6n, 6, 0, rp1, r5, {==}, {==})), (([D.bytes(RN.d_u8(hl, x2))], (MD.bytes_list([]), (OS.transport(RN_L.v_u8(x2), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Unsigned{P.U8{}}, [D.bytes(RN.d_u8(hl, x2))], qv0, RN.rs_u8(hl, ehl, x2, q4)), ({==}, {==})))), {==})))), {==})))),
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

law nth_v4_GcDC3E457711:
  for +W: List<&2, FixedTestStruct_d.GcDC3E457711>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(FixedTestStruct_d.GcDC3E457711, W)) == True{} : Bool}
  {F.spec_common__nth(FixedTestStruct_d.GcDC3E457711, W, i) == Some{LV.xat_v4_GcDC3E457711(W, i)} : Maybe<&2, FixedTestStruct_d.GcDC3E457711>}
def nth_v4_GcDC3E457711(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(FixedTestStruct_d.GcDC3E457711, Nil{}, i) == Some{LV.xat_v4_GcDC3E457711(Nil{}, i)} : Maybe<&2, FixedTestStruct_d.GcDC3E457711>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_v4_GcDC3E457711(t, j, hi)
def xl_v4_GcDC3E457711(k: Nat, +W: List<&2, FixedTestStruct_d.GcDC3E457711>, +i: Nat, +hl: Nat) -> List<&2, D.Digest>:
  match k:
    case 0n: []
    case 1n+q: RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(W, i)) <> xl_v4_GcDC3E457711(q, W, 1n+i, hl)
law xlen_v4_GcDC3E457711:
  for +k: Nat
  for +W: List<&2, FixedTestStruct_d.GcDC3E457711>
  for +i: Nat
  for +hl: Nat
  {MD.dlen(xl_v4_GcDC3E457711(k, W, i, hl)) == k : Nat}
def xlen_v4_GcDC3E457711(k, W, i, hl):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %xlen_v4_GcDC3E457711(q, W, 1n+i, hl) : {1n+MD.dlen(xl_v4_GcDC3E457711(q, W, 1n+i, hl)) == 1n+_ : Nat}
      {==}
law xat_at_v4_GcDC3E457711:
  for +s: Nat
  for +k: Nat
  for +W: List<&2, FixedTestStruct_d.GcDC3E457711>
  for +i: Nat
  for +hl: Nat
  for +e: {Nat.is_lt(s, k) == True{} : Bool}
  {MD.dhead(MD.ddrop(s, xl_v4_GcDC3E457711(k, W, i, hl))) == RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(W, Nat.add(s, i))) : D.Digest}
def xat_at_v4_GcDC3E457711(s, k, W, i, hl, e):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(0n, xl_v4_GcDC3E457711(0n, W, i, hl))) == RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(W, Nat.add(0n, i))) : D.Digest}, MD.false_true(e))
        case 1n+q: {==}
    case 1n+ +p1:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(1n+p1, xl_v4_GcDC3E457711(0n, W, i, hl))) == RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(W, Nat.add(1n+p1, i))) : D.Digest}, MD.false_true(e))
        case 1n+ +q:
          %MR.add_succ(p1, i) : {MD.dhead(MD.ddrop(p1, xl_v4_GcDC3E457711(q, W, 1n+i, hl))) == RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(W, _)) : D.Digest}
          xat_at_v4_GcDC3E457711(p1, q, W, 1n+i, hl, e)
law xroots_v4_GcDC3E457711:
  for +k: Nat
  for +W: List<&2, FixedTestStruct_d.GcDC3E457711>
  for +i: Nat
  for +hl: Nat
  for +ehl: {hl == 64n : Nat}
  for +er: LV.ereps_v4_GcDC3E457711(k, W, i)
  RR.roots(LV.xi_v4_GcDC3E457711(k, W, i), S.Repeat{S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}}, MD.bytes_list(xl_v4_GcDC3E457711(k, W, i, hl)))
def xroots_v4_GcDC3E457711(k, W, i, hl, ehl, er):
  match k:
    case 0n: {==}
    case 1n+ +q:
      (+r0, +rs) = er
      ([D.bytes(RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(W, i)))], (MD.bytes_list(xl_v4_GcDC3E457711(q, W, 1n+i, hl)), (RN.rs_GcDC3E457711(hl, ehl, LV.xat_v4_GcDC3E457711(W, i), r0), (xroots_v4_GcDC3E457711(q, W, 1n+i, hl, ehl, rs), {==}))))
law xcount_v4_GcDC3E457711:
  for +k: Nat
  for +W: List<&2, FixedTestStruct_d.GcDC3E457711>
  for +i: Nat
  {Codec.count(LV.xi_v4_GcDC3E457711(k, W, i)) == k : Nat}
def xcount_v4_GcDC3E457711(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Codec.count(LV.xi_v4_GcDC3E457711(q, W, 1n+i)), q, xcount_v4_GcDC3E457711(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}
law xph1_v4_GcDC3E457711:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +seg: U32
  for +v: Nat
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for -ws: Array<FixedTestStruct_d.GcDC3E457711>
  for +dl: D.Digest
  {vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(d, 1n, b, hl, seg, v, s, n, (h, (ws, dl))) == vec_FixedTestStruct_4_h.v4_GcDC3E457711_mj(hl, dl, vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(d, 0n, b, hl, seg, v, s, n, (h, (ws, D.zero())))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
def xph1_v4_GcDC3E457711(d, b, hl, seg, v, s, n, h, ws, dl):
  match d:
    case 0n: {==}
    case 1n+q: {==}
def xget_v4_GcDC3E457711(+dw: Nat, +t: F.array__Tree<FixedTestStruct_d.GcDC3E457711>, +s: Nat, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(FixedTestStruct_d.GcDC3E457711, dw, t) == True{} : Bool}, +hs: {Nat.is_lt(s, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Array.get(FixedTestStruct_d.GcDC3E457711, F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), U32.from_nat(s)) == (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s)) : Array<FixedTestStruct_d.GcDC3E457711> & FixedTestStruct_d.GcDC3E457711}:
  +e1 = F.u32__to_nat_from_nat(s, dw, F.nat__lt_le(dw, 32n, hd), hs)
  +hlen = XS.lt_len(FixedTestStruct_d.GcDC3E457711, dw, t, s, pf, hs)
  F.array__get(FixedTestStruct_d.GcDC3E457711, dw, t, U32.from_nat(s), LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s), hd, MR.hi_at(dw, s, hd, hs),
    XS.at_nth(FixedTestStruct_d.GcDC3E457711, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s, U32.to_nat(U32.from_nat(s)), LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s), e1, nth_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s, hlen)), pf)
law xmt_v4_GcDC3E457711:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +seg: U32
  for +dw: Nat
  for +t: F.array__Tree<FixedTestStruct_d.GcDC3E457711>
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for +junk: D.Digest
  for +e: {Nat.is_lt(s, n) == b : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(FixedTestStruct_d.GcDC3E457711, dw, t) == True{} : Bool}
  for +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool}
  {vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(d, 0n, b, hl, seg, O.pow2n(d), s, n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), junk))) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(d, b, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
def xmt_v4_GcDC3E457711(d, b, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn):
  match d:
    case 0n:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Array<FixedTestStruct_d.GcDC3E457711> & FixedTestStruct_d.GcDC3E457711, Array.get(FixedTestStruct_d.GcDC3E457711, F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), U32.from_nat(s)), (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s)), xget_v4_GcDC3E457711(dw, t, s, hd, pf, F.nat__lt_le_trans(s, n, F.spec_common__pow2(dw), e, hn))) :
            {vec_FixedTestStruct_4_h.v4_GcDC3E457711_rl(hl, seg, h, _) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(0n, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          %Equal.sym(B.Buf & D.Digest, FixedTestStruct_h.GcDC3E457711_root(hl, h, LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s), (seg + 64 : U32)), (h, RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s))), RN.st_GcDC3E457711(hl, h, LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s), (seg + 64 : U32))) :
            {vec_FixedTestStruct_4_h.v4_GcDC3E457711_rl_d(F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), _) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(0n, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          %Equal.sym(D.Digest, MD.dhead(MD.ddrop(s, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl))), RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), Nat.add(s, 0n))), xat_at_v4_GcDC3E457711(s, n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl, e)) :
            {(h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s)))) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), _)) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          %Equal.sym(Nat, Nat.add(s, 0n), s, MR.add_zero(s)) :
            {(h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), s)))) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), RN.d_GcDC3E457711(hl, LV.xat_v4_GcDC3E457711(F.array__slots(FixedTestStruct_d.GcDC3E457711, t), _)))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          {==}
    case 1n+ +q:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Nat, MD.dlen(xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl)), n, xlen_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl)) :
            {vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 1n, Nat.is_lt(Nat.add(s, Nat.div(Nat.double(O.pow2n(q)), 2n)), n), hl, seg, Nat.div(Nat.double(O.pow2n(q)), 2n), Nat.add(s, Nat.div(Nat.double(O.pow2n(q)), 2n)), n, vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 0n, True{}, hl, seg, Nat.div(Nat.double(O.pow2n(q)), 2n), s, n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), junk)))) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), _), hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          %Equal.sym(Nat, Nat.div(Nat.double(O.pow2n(q)), 2n), O.pow2n(q), MR.div_double(O.pow2n(q))) :
            {vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 1n, Nat.is_lt(Nat.add(s, _), n), hl, seg, _, Nat.add(s, _), n, vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 0n, True{}, hl, seg, _, s, n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), junk)))) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          %Equal.sym(B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest), vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 0n, True{}, hl, seg, O.pow2n(q), s, n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), junk))), (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s))), xmt_v4_GcDC3E457711(q, True{}, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn)) :
            {vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 1n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, _) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          %Equal.sym(B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest), vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 1n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s)))),
              vec_FixedTestStruct_4_h.v4_GcDC3E457711_mj(hl, MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s), vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 0n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), D.zero())))),
              xph1_v4_GcDC3E457711(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, h, F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s))) :
            {_ == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          %Equal.sym(B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest), vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 0n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), D.zero()))), (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), Nat.add(s, O.pow2n(q))))),
              xmt_v4_GcDC3E457711(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, dw, t, Nat.add(s, O.pow2n(q)), n, h, D.zero(), {==}, hd, pf, hn)) :
            {vec_FixedTestStruct_4_h.v4_GcDC3E457711_mj(hl, MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s), _) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), D.node(hl, MD.rtree(q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          {==}
def xmt0_v4_GcDC3E457711(+d: Nat, +b: Bool, +hl: Nat, +seg: U32, +dw: Nat, +t: F.array__Tree<FixedTestStruct_d.GcDC3E457711>, +n: Nat, -h: B.Buf, +junk: D.Digest,
    +e: {Nat.is_lt(0n, n) == b : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(FixedTestStruct_d.GcDC3E457711, dw, t) == True{} : Bool}, +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt0(d, b, hl, seg, n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), junk))) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(d, b, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), 0n))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}:
  match d:
    case 0n: xmt_v4_GcDC3E457711(0n, b, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn)
    case 1n+ +q:
      match b:
        case False{}: {==}
        case True{}:
          %MR.div_double(O.pow2n(q)) :
            {vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 1n, Nat.is_lt(Nat.add(0n, _), n), hl, seg, _, Nat.add(0n, _), n, vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt(q, 0n, True{}, hl, seg, _, 0n, n, (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), junk)))) == (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(1n+q, True{}, hl, xl_v4_GcDC3E457711(n, F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), 0n))) : B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest)}
          xmt_v4_GcDC3E457711(1n+q, True{}, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn)
def xd_v4_GcDC3E457711(+hl: Nat, o: vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq) -> D.Digest:
  match o:
    case vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{arr, +n}: MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(n)), hl, xl_v4_GcDC3E457711(U32.to_nat(n), F.array__slots(FixedTestStruct_d.GcDC3E457711, F.array__freeze(FixedTestStruct_d.GcDC3E457711, arr)), 0n, hl), 0n)
def ok_v4_GcDC3E457711(+s: S.Schema) -> Bool: Bool.and(SH.is_Vector(s), Lim.minimal(SH.Vector_length(s), 2n))
def st_v4_GcDC3E457711(+hl: Nat, -h: B.Buf, -o: vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq, +seg: U32, +s: S.Schema, +rep: LV.rep_v4_GcDC3E457711(o, s))
    -> {vec_FixedTestStruct_4_h.v4_GcDC3E457711_root(hl, h, o, seg) == (h, (o, xd_v4_GcDC3E457711(hl, o))) : B.Buf & (vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq & D.Digest)}:
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, w6) = w5
  (+hn, +er) = w6
  %Equal.sym(vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq, o, vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}, eo) :
    {vec_FixedTestStruct_4_h.v4_GcDC3E457711_root(hl, h, _, seg) == (h, (_, xd_v4_GcDC3E457711(hl, _))) : B.Buf & (vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq & D.Digest)}
  %Equal.sym(B.Buf & (Array<FixedTestStruct_d.GcDC3E457711> & D.Digest), vec_FixedTestStruct_4_h.v4_GcDC3E457711_mt0(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, U32.to_nat(N), (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), D.zero()))), (h, (F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), 0n))),
      xmt0_v4_GcDC3E457711(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, dw, t, U32.to_nat(N), h, D.zero(), {==}, hd, pf, hn)) :
    {vec_FixedTestStruct_4_h.v4_GcDC3E457711_rt_fin(hl, N, _) == (h, (vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}, xd_v4_GcDC3E457711(hl, vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}))) : B.Buf & (vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq & D.Digest)}
  %Equal.sym(F.array__Tree<FixedTestStruct_d.GcDC3E457711>, F.array__freeze(FixedTestStruct_d.GcDC3E457711, F.array__thaw(FixedTestStruct_d.GcDC3E457711, t)), t, F.array__freeze_thaw(FixedTestStruct_d.GcDC3E457711, t)) :
    {(h, (vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}, MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), 0n))) == (h, (vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}, MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, _), 0n, hl), 0n))) : B.Buf & (vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq & D.Digest)}
  {==}
def xhl_v4_GcDC3E457711(+N: U32, +Lm: Nat, +Wl: List<&2, FixedTestStruct_d.GcDC3E457711>, +hl: Nat, +hv: {Nat.is_le(U32.to_nat(N), Lm) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(xl_v4_GcDC3E457711(U32.to_nat(N), Wl, 0n, hl)), Lm) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(xl_v4_GcDC3E457711(U32.to_nat(N), Wl, 0n, hl)), U32.to_nat(N), xlen_v4_GcDC3E457711(U32.to_nat(N), Wl, 0n, hl)) : {Nat.is_le(_, Lm) == True{} : Bool}
  hv
def xhv_v4_GcDC3E457711(-o: vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq, +t: F.array__Tree<FixedTestStruct_d.GcDC3E457711>, +N: U32, +Lm: Nat, +eo: {o == vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N} : vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq},
    +hv: {Nat.is_eq(U32.to_nat(LV.xlen_o_v4_GcDC3E457711(o)), Lm) == True{} : Bool}) -> {Nat.is_eq(U32.to_nat(N), Lm) == True{} : Bool}:
  %Equal.cong(vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq, U32, LV.xlen_o_v4_GcDC3E457711, o, vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}, eo) : {Nat.is_eq(U32.to_nat(_), Lm) == True{} : Bool}
  hv
def wd_v4_GcDC3E457711(+hl: Nat, -o: vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq, +s: S.Schema, +rep: LV.rep_v4_GcDC3E457711(o, s)) -> OS.DW(xd_v4_GcDC3E457711(hl, o)):
  (+wf, +hv) = rep
  (+t, +w1) = wf
  (+dw, +w2) = w1
  (+N, +w3) = w2
  (+eo, +w4) = w3
  %Equal.sym(vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq, o, vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}, eo) : OS.DW(xd_v4_GcDC3E457711(hl, _))
  (xd_v4_GcDC3E457711(hl, vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}), {==})
def rs_v4_GcDC3E457711(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq, +s: S.Schema, +rep: LV.rep_v4_GcDC3E457711(o, s), +ok: {ok_v4_GcDC3E457711(s) == True{} : Bool}, +eq: {SH.Vector_element(s) == S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}} : S.Schema})
    -> RR.roots(LV.xv_v4_GcDC3E457711(o), s, [D.bytes(xd_v4_GcDC3E457711(hl, o))]):
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
  +hvN = veq_le(U32.to_nat(N), SH.Vector_length(s), xhv_v4_GcDC3E457711(o, t, N, SH.Vector_length(s), eo, hv))
  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, k0)) :
    RR.roots(LV.xv_v4_GcDC3E457711(o), _, [D.bytes(xd_v4_GcDC3E457711(hl, o))])
  %Equal.sym(S.Schema, SH.Vector_element(s), S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, eq) :
    RR.roots(LV.xv_v4_GcDC3E457711(o), S.Vector{_, SH.Vector_length(s)}, [D.bytes(xd_v4_GcDC3E457711(hl, o))])
  %Equal.sym(vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq, o, vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq{F.array__thaw(FixedTestStruct_d.GcDC3E457711, t), N}, eo) :
    RR.roots(LV.xv_v4_GcDC3E457711(_), S.Vector{S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, SH.Vector_length(s)}, [D.bytes(xd_v4_GcDC3E457711(hl, _))])
  %Equal.sym(F.array__Tree<FixedTestStruct_d.GcDC3E457711>, F.array__freeze(FixedTestStruct_d.GcDC3E457711, F.array__thaw(FixedTestStruct_d.GcDC3E457711, t)), t, F.array__freeze_thaw(FixedTestStruct_d.GcDC3E457711, t)) :
    RR.roots(S.Sequence{LV.xi_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, _), 0n)}, S.Vector{S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, SH.Vector_length(s)}, [D.bytes(MD.rtree(2n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, _), 0n, hl), 0n))])
  %xlen_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl) :
    RR.roots(S.Sequence{LV.xi_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n)}, S.Vector{S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, SH.Vector_length(s)}, [D.bytes(MD.rtree(2n, Nat.is_lt(0n, _), hl, xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), 0n))])
  (MD.bytes_list(xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl)), (xroots_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl, ehl, er),
    (D.bytes(MD.rtree(2n, Nat.is_lt(0n, MD.dlen(xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl))), hl, xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), 0n)), ((2n, (k1, RS.at_depth_tree(SH.Vector_length(s), 2n, hl, xl_v4_GcDC3E457711(U32.to_nat(N), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), 0n, hl), {==}, xhl_v4_GcDC3E457711(N, SH.Vector_length(s), F.array__slots(FixedTestStruct_d.GcDC3E457711, t), hl, hvN), ehl))),
     {==}))))

def d_Gc465214E502_bx(+hl: Nat, o: O.Boxed<VarTestStruct_d.Gc465214E502>) -> D.Digest:
  match o:
    case O.BSome{v, rest}: d_Gc465214E502(hl, v)
    case O.BNone{}: D.zero()
def st_Gc465214E502_bx(+hl: Nat, -h: B.Buf, -o: O.Boxed<VarTestStruct_d.Gc465214E502>, +seg: U32, +s: S.Schema, +rep: LV.rep_Gc465214E502_bx(o, s))
    -> {VarTestStruct_h.Gc465214E502_bx_root(hl, h, o, seg) == (h, (o, d_Gc465214E502_bx(hl, o))) : B.Buf & (O.Boxed<VarTestStruct_d.Gc465214E502> & D.Digest)}:
  (+eo, +ri) = rep
  %Equal.sym(O.Boxed<VarTestStruct_d.Gc465214E502>, o, O.BSome{LV.pjb_Gc465214E502_bx(o), O.BNone{}}, eo) :
    {VarTestStruct_h.Gc465214E502_bx_root(hl, h, _, seg) == (h, (_, d_Gc465214E502_bx(hl, _))) : B.Buf & (O.Boxed<VarTestStruct_d.Gc465214E502> & D.Digest)}
  %Equal.sym(B.Buf & (VarTestStruct_d.Gc465214E502 & D.Digest), VarTestStruct_h.Gc465214E502_root(hl, h, LV.pjb_Gc465214E502_bx(o), seg), (h, (LV.pjb_Gc465214E502_bx(o), d_Gc465214E502(hl, LV.pjb_Gc465214E502_bx(o)))), st_Gc465214E502(hl, h, LV.pjb_Gc465214E502_bx(o), seg, s, ri)) :
    {VarTestStruct_h.Gc465214E502_bx_rt(_) == (h, (O.BSome{LV.pjb_Gc465214E502_bx(o), O.BNone{}}, d_Gc465214E502_bx(hl, O.BSome{LV.pjb_Gc465214E502_bx(o), O.BNone{}}))) : B.Buf & (O.Boxed<VarTestStruct_d.Gc465214E502> & D.Digest)}
  {==}
def rs_Gc465214E502_bx(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: O.Boxed<VarTestStruct_d.Gc465214E502>, +s: S.Schema, +rep: LV.rep_Gc465214E502_bx(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}, +ok: {ok_Gc465214E502(s, dv) == True{} : Bool}, +eq: eqs_Gc465214E502(s))
    -> RR.roots(LV.v_Gc465214E502_bx(o), s, [D.bytes(d_Gc465214E502_bx(hl, o))]):
  (+eo, +ri) = rep
  %Equal.sym(O.Boxed<VarTestStruct_d.Gc465214E502>, o, O.BSome{LV.pjb_Gc465214E502_bx(o), O.BNone{}}, eo) : RR.roots(LV.v_Gc465214E502_bx(_), s, [D.bytes(d_Gc465214E502_bx(hl, _))])
  rs_Gc465214E502(hl, ehl, h, LV.pjb_Gc465214E502_bx(o), s, ri, dv, edv, ok, eq)
def wd_Gc465214E502_bx(+hl: Nat, -o: O.Boxed<VarTestStruct_d.Gc465214E502>, +s: S.Schema, +rep: LV.rep_Gc465214E502_bx(o, s)) -> OS.DW(d_Gc465214E502_bx(hl, o)):
  (+eo, +ri) = rep
  %Equal.sym(O.Boxed<VarTestStruct_d.Gc465214E502>, o, O.BSome{LV.pjb_Gc465214E502_bx(o), O.BNone{}}, eo) : OS.DW(d_Gc465214E502_bx(hl, _))
  wd_Gc465214E502(hl, LV.pjb_Gc465214E502_bx(o), s, ri)
def ok_Gc465214E502_bx(+s: S.Schema, +dv: OS.DV) -> Bool: ok_Gc465214E502(s, dv)
def eqs_Gc465214E502_bx(+s: S.Schema) -> Data: eqs_Gc465214E502(s)

def fzth_Gc465214E502(+m: LV.M_Gc465214E502) -> {LV.fz_Gc465214E502(LV.th_Gc465214E502(m)) == m : LV.M_Gc465214E502}:
  match m:
    case LV.M_Gc465214E502{+a0, +a1, +a2}:
      %Equal.sym(LV.WMr, LV.fz_w(LV.th_w(a1)), a1, fzth_w(a1)) :
        {LV.M_Gc465214E502{a0, _, a2} == LV.M_Gc465214E502{a0, a1, a2} : LV.M_Gc465214E502}
      {==}

def mfz_Gc465214E502_bx(x: O.Boxed<VarTestStruct_d.Gc465214E502>) -> LV.M_Gc465214E502:
  match x:
    case O.BSome{v, rest}: LV.fz_Gc465214E502(v)
    case O.BNone{}: LV.fz_Gc465214E502(VarTestStruct_d.Gc465214E502_default())
def fzth_Gc465214E502_bx(+m: LV.MB<LV.M_Gc465214E502>) -> {LV.fz_Gc465214E502_bx(LV.th_Gc465214E502_bx(m)) == m : LV.MB<LV.M_Gc465214E502>}:
  match m:
    case LV.MSome{+v}:
      %Equal.sym(LV.M_Gc465214E502, LV.fz_Gc465214E502(LV.th_Gc465214E502(v)), v, fzth_Gc465214E502(v)) : {LV.MSome{_} == LV.MSome{v} : LV.MB<LV.M_Gc465214E502>}
      {==}
    case LV.MNone{}: {==}

def amsize_v2_Gc465214E502(+d: Nat, +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>, +pf: {F.array__perfect(LV.MB<LV.M_Gc465214E502>, d, t) == True{} : Bool}) -> {Array.size(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t)) == (LV.am_v2_Gc465214E502(t), F.u32__pow2u(d)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & U32}:
  match d t:
    case 0n F.TLeaf{x}:
      {==}
    case 0n F.TNode{l, r}:
      Empty.absurd({Array.size(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(F.TNode{l, r})) == (LV.am_v2_Gc465214E502(F.TNode{l, r}), 1) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & U32}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{x}:
      Empty.absurd({Array.size(O.Boxed<VarTestStruct_d.Gc465214E502>, ALeaf{LV.th_Gc465214E502_bx(x)}) == (ALeaf{LV.th_Gc465214E502_bx(x)}, F.u32__pow2u(1n+p)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & U32}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r}:
      %Equal.sym(Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & U32, Array.size(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l)), (LV.am_v2_Gc465214E502(l), F.u32__pow2u(p)), amsize_v2_Gc465214E502(p, l, F.array__pf_left(LV.MB<LV.M_Gc465214E502>, p, l, r, pf))) : {Array.size.node(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(r), _) == (ANode{LV.am_v2_Gc465214E502(l), LV.am_v2_Gc465214E502(r)}, U32.shl(F.u32__pow2u(p))) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & U32}
      {==}

def amswap_go_v2_Gc465214E502(+d: Nat, +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>, +i: U32, +v: LV.MB<LV.M_Gc465214E502>, +x: LV.MB<LV.M_Gc465214E502>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, LV.MB<LV.M_Gc465214E502>>}, +b: Bool, +eb: {U32.is_lt(i, F.u32__pow2u(F.nat__pred(d))) == b : Bool}, +pf: {F.array__perfect(LV.MB<LV.M_Gc465214E502>, d, t) == True{} : Bool}) -> {Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t), F.u32__pow2u(d), i, LV.th_Gc465214E502_bx(v)) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}:
  match d t b:
    case 0n F.TLeaf{+y} _:
      %F.array__leaf_value(LV.MB<LV.M_Gc465214E502>, y, U32.to_nat(i), x, hi, hx) : {(ALeaf{LV.th_Gc465214E502_bx(v)}, LV.th_Gc465214E502_bx(y)) == (ALeaf{LV.th_Gc465214E502_bx(v)}, LV.th_Gc465214E502_bx(_)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      {==}
    case 0n F.TNode{l, r} _:
      Empty.absurd({Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(F.TNode{l, r}), 1, i, LV.th_Gc465214E502_bx(v)) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, 0n, F.TNode{l, r}, U32.to_nat(i), v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{y} _:
      Empty.absurd({Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, ALeaf{LV.th_Gc465214E502_bx(y)}, F.u32__pow2u(1n+p), i, LV.th_Gc465214E502_bx(v)) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, 1n+p, F.TLeaf{y}, U32.to_nat(i), v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r} True{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(LV.MB<LV.M_Gc465214E502>, p, l, r, pf)
      +hil = F.array__lt_bridge(i, p, hp, True{}, eb)
      +ti = U32.to_nat(i)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.if(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l), LV.am_v2_Gc465214E502(r), _, i, LV.th_Gc465214E502_bx(v), U32.is_lt(i, _)) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, 1n+p, F.TNode{l, r}, ti, v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      %Equal.sym(Bool, U32.is_lt(i, F.u32__pow2u(p)), True{}, eb) : {Array.swap.if(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l), LV.am_v2_Gc465214E502(r), F.u32__pow2u(p), i, LV.th_Gc465214E502_bx(v), _) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, 1n+p, F.TNode{l, r}, ti, v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), True{}, hil) : {Array.swap.lo(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(r), Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l), F.u32__pow2u(p), i, LV.th_Gc465214E502_bx(v))) == (LV.am_v2_Gc465214E502(F.array__tupd(LV.MB<LV.M_Gc465214E502>, 1n+p, F.TNode{l, r}, ti, v, _)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      %Equal.sym(Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>, Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l), F.u32__pow2u(p), i, LV.th_Gc465214E502_bx(v)), (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, p, l, ti, v)), LV.th_Gc465214E502_bx(x)), amswap_go_v2_Gc465214E502(p, l, i, v, x, hp, hil, Equal.trans(Maybe<&2, LV.MB<LV.M_Gc465214E502>>, F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, l), ti), F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.spec_common__append(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, l), F.array__slots(LV.MB<LV.M_Gc465214E502>, r)), ti), Some{x}, Equal.sym(Maybe<&2, LV.MB<LV.M_Gc465214E502>>, F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.spec_common__append(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, l), F.array__slots(LV.MB<LV.M_Gc465214E502>, r)), ti), F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, l), ti), F.list__nth_append_left(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, l), F.array__slots(LV.MB<LV.M_Gc465214E502>, r), ti, F.array__len_lt(LV.MB<LV.M_Gc465214E502>, p, l, ti, pl, hil))), hx), U32.is_lt(i, F.u32__pow2u(F.nat__pred(p))), {==}, pl)) : {Array.swap.lo(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(r), _) == (LV.am_v2_Gc465214E502(F.TNode{F.array__tupd(LV.MB<LV.M_Gc465214E502>, p, l, ti, v, F.array__ndec(p, ti)), r}), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      {==}
    case 1n+ +p F.TNode{+l, +r} False{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(LV.MB<LV.M_Gc465214E502>, p, l, r, pf)
      +ti = U32.to_nat(i)
      +nb = F.array__lt_bridge(i, p, hp, False{}, eb)
      +le = F.nat__not_lt_le(ti, F.spec_common__pow2(p), nb)
      +j = U32.sub(i, F.u32__pow2u(p))
      +k = Nat.sub(ti, F.spec_common__pow2(p))
      +ej = F.array__sub_bridge(i, p, hp, le)
      +hir = F.logic__subst(Nat, n => {Nat.is_lt(n, F.spec_common__pow2(p)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), F.array__upper_lt(ti, p, hi, le))
      +hxr = F.logic__subst(Nat, n => {F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, r), n) == Some{x} : Maybe<&2, LV.MB<LV.M_Gc465214E502>>}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), Equal.trans(Maybe<&2, LV.MB<LV.M_Gc465214E502>>, F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, r), k), F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.spec_common__append(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, l), F.array__slots(LV.MB<LV.M_Gc465214E502>, r)), ti), Some{x}, Equal.sym(Maybe<&2, LV.MB<LV.M_Gc465214E502>>, F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.spec_common__append(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, l), F.array__slots(LV.MB<LV.M_Gc465214E502>, r)), ti), F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, r), k), F.array__right_nth(LV.MB<LV.M_Gc465214E502>, p, l, r, ti, pl, le)), hx))
      +ih = amswap_go_v2_Gc465214E502(p, r, j, v, x, hp, hir, hxr, U32.is_lt(j, F.u32__pow2u(F.nat__pred(p))), {==}, F.array__pf_right(LV.MB<LV.M_Gc465214E502>, p, l, r, pf))
      +ih2 = F.logic__subst(Nat, n => {Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(r), F.u32__pow2u(p), j, LV.th_Gc465214E502_bx(v)) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, p, r, n, v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}, U32.to_nat(j), k, ej, ih)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.if(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l), LV.am_v2_Gc465214E502(r), _, i, LV.th_Gc465214E502_bx(v), U32.is_lt(i, _)) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, 1n+p, F.TNode{l, r}, ti, v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      %Equal.sym(Bool, U32.is_lt(i, F.u32__pow2u(p)), False{}, eb) : {Array.swap.if(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l), LV.am_v2_Gc465214E502(r), F.u32__pow2u(p), i, LV.th_Gc465214E502_bx(v), _) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, 1n+p, F.TNode{l, r}, ti, v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), False{}, nb) : {Array.swap.hi(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l), Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(r), F.u32__pow2u(p), j, LV.th_Gc465214E502_bx(v))) == (LV.am_v2_Gc465214E502(F.array__tupd(LV.MB<LV.M_Gc465214E502>, 1n+p, F.TNode{l, r}, ti, v, _)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      %Equal.sym(Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>, Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(r), F.u32__pow2u(p), j, LV.th_Gc465214E502_bx(v)), (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, p, r, k, v)), LV.th_Gc465214E502_bx(x)), ih2) : {Array.swap.hi(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(l), _) == (LV.am_v2_Gc465214E502(F.TNode{l, F.array__tupd(LV.MB<LV.M_Gc465214E502>, p, r, k, v, F.array__ndec(p, k))}), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
      {==}

# Public Base entry points. Premises: the tree is perfect of depth d < 32 and
# the index is below 2^d; x is the value currently stored at that index.
def amswap_v2_Gc465214E502(+d: Nat, +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>, +i: U32, +v: LV.MB<LV.M_Gc465214E502>, +x: LV.MB<LV.M_Gc465214E502>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, LV.MB<LV.M_Gc465214E502>>}, +pf: {F.array__perfect(LV.MB<LV.M_Gc465214E502>, d, t) == True{} : Bool}) -> {Array.swap(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t), i, LV.th_Gc465214E502_bx(v)) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}:
  %Equal.sym(Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & U32, Array.size(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t)), (LV.am_v2_Gc465214E502(t), F.u32__pow2u(d)), amsize_v2_Gc465214E502(d, t, pf)) : {Array.swap.at(O.Boxed<VarTestStruct_d.Gc465214E502>, i, LV.th_Gc465214E502_bx(v), _) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
  %Equal.sym(U32, U32.and(i, U32.sub(F.u32__pow2u(d), 1)), i, F.u32__mask_pow2u(i, d, hd, hi)) : {Array.swap.go(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t), F.u32__pow2u(d), _, LV.th_Gc465214E502_bx(v)) == (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), v)), LV.th_Gc465214E502_bx(x)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>}
  amswap_go_v2_Gc465214E502(d, t, i, v, x, hd, hi, hx, U32.is_lt(i, F.u32__pow2u(F.nat__pred(d))), {==}, pf)

def amset_v2_Gc465214E502(+d: Nat, +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>, +i: U32, +v: LV.MB<LV.M_Gc465214E502>, +x: LV.MB<LV.M_Gc465214E502>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, LV.MB<LV.M_Gc465214E502>>}, +pf: {F.array__perfect(LV.MB<LV.M_Gc465214E502>, d, t) == True{} : Bool}) -> {Array.set(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t), i, LV.th_Gc465214E502_bx(v)) == LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>>}:
  %Equal.sym(Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>, Array.swap(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t), i, LV.th_Gc465214E502_bx(v)), (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), v)), LV.th_Gc465214E502_bx(x)), amswap_v2_Gc465214E502(d, t, i, v, x, hd, hi, hx, pf)) : {Array.set.fin(O.Boxed<VarTestStruct_d.Gc465214E502>, _) == LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>>}
  {==}

# Swap an element out (replaced by th_Gc465214E502_bx(z)), then set th_Gc465214E502_bx(x) back: the array is
# unchanged. This is the leaf step of every tree over such a list.
def amswap_back_v2_Gc465214E502(+d: Nat, +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>, +i: U32, +z: LV.MB<LV.M_Gc465214E502>, +x: LV.MB<LV.M_Gc465214E502>,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, LV.MB<LV.M_Gc465214E502>>},
    +pf: {F.array__perfect(LV.MB<LV.M_Gc465214E502>, d, t) == True{} : Bool})
    -> {Array.set(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), z)), i, LV.th_Gc465214E502_bx(x)) == LV.am_v2_Gc465214E502(t) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>>}:
  +t2 = F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), z)
  +hz = F.logic__subst(List<&2, LV.MB<LV.M_Gc465214E502>>, ys => {F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, ys, U32.to_nat(i)) == Some{z} : Maybe<&2, LV.MB<LV.M_Gc465214E502>>}, F.spec_common__update(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), U32.to_nat(i), z), F.array__slots(LV.MB<LV.M_Gc465214E502>, t2),
    Equal.sym(List<&2, LV.MB<LV.M_Gc465214E502>>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t2), F.spec_common__update(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), U32.to_nat(i), z), F.array__upd_slots(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), z, hi, pf)),
    F.list__nth_update_same(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), U32.to_nat(i), z, F.list__nth_lt_length(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), U32.to_nat(i), x, hx)))
  %Equal.sym(Array<O.Boxed<VarTestStruct_d.Gc465214E502>>, Array.set(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t2), i, LV.th_Gc465214E502_bx(x)), LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t2, U32.to_nat(i), x)),
      amset_v2_Gc465214E502(d, t2, i, x, z, hd, hi, hz, F.array__upd_perfect(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), z, pf))) :
    {_ == LV.am_v2_Gc465214E502(t) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>>}
  %Equal.sym(F.array__Tree<LV.MB<LV.M_Gc465214E502>>, F.array__upd(LV.MB<LV.M_Gc465214E502>, d, t2, U32.to_nat(i), x), t, AM.upd_restore(LV.MB<LV.M_Gc465214E502>, d, t, U32.to_nat(i), z, x, hi, hx, pf)) :
    {LV.am_v2_Gc465214E502(_) == LV.am_v2_Gc465214E502(t) : Array<O.Boxed<VarTestStruct_d.Gc465214E502>>}
  {==}
law nth_v2_Gc465214E502:
  for +W: List<&2, LV.MB<LV.M_Gc465214E502>>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(LV.MB<LV.M_Gc465214E502>, W)) == True{} : Bool}
  {F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, W, i) == Some{LV.xat_v2_Gc465214E502(W, i)} : Maybe<&2, LV.MB<LV.M_Gc465214E502>>}
def nth_v2_Gc465214E502(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(LV.MB<LV.M_Gc465214E502>, Nil{}, i) == Some{LV.xat_v2_Gc465214E502(Nil{}, i)} : Maybe<&2, LV.MB<LV.M_Gc465214E502>>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_v2_Gc465214E502(t, j, hi)
def xl_v2_Gc465214E502(k: Nat, +W: List<&2, LV.MB<LV.M_Gc465214E502>>, +i: Nat, +hl: Nat) -> List<&2, D.Digest>:
  match k:
    case 0n: []
    case 1n+q: d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, i))) <> xl_v2_Gc465214E502(q, W, 1n+i, hl)
law xlen_v2_Gc465214E502:
  for +k: Nat
  for +W: List<&2, LV.MB<LV.M_Gc465214E502>>
  for +i: Nat
  for +hl: Nat
  {MD.dlen(xl_v2_Gc465214E502(k, W, i, hl)) == k : Nat}
def xlen_v2_Gc465214E502(k, W, i, hl):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %xlen_v2_Gc465214E502(q, W, 1n+i, hl) : {1n+MD.dlen(xl_v2_Gc465214E502(q, W, 1n+i, hl)) == 1n+_ : Nat}
      {==}
law xat_at_v2_Gc465214E502:
  for +s: Nat
  for +k: Nat
  for +W: List<&2, LV.MB<LV.M_Gc465214E502>>
  for +i: Nat
  for +hl: Nat
  for +e: {Nat.is_lt(s, k) == True{} : Bool}
  {MD.dhead(MD.ddrop(s, xl_v2_Gc465214E502(k, W, i, hl))) == d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, Nat.add(s, i)))) : D.Digest}
def xat_at_v2_Gc465214E502(s, k, W, i, hl, e):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(0n, xl_v2_Gc465214E502(0n, W, i, hl))) == d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, Nat.add(0n, i)))) : D.Digest}, MD.false_true(e))
        case 1n+q: {==}
    case 1n+ +p1:
      match k:
        case 0n: Empty.absurd({MD.dhead(MD.ddrop(1n+p1, xl_v2_Gc465214E502(0n, W, i, hl))) == d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, Nat.add(1n+p1, i)))) : D.Digest}, MD.false_true(e))
        case 1n+ +q:
          %MR.add_succ(p1, i) : {MD.dhead(MD.ddrop(p1, xl_v2_Gc465214E502(q, W, 1n+i, hl))) == d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, _))) : D.Digest}
          xat_at_v2_Gc465214E502(p1, q, W, 1n+i, hl, e)
def erep_at_v2_Gc465214E502(+s: Nat, +k: Nat, +W: List<&2, LV.MB<LV.M_Gc465214E502>>, +i: Nat, +sE: S.Schema, +er: LV.ereps_v2_Gc465214E502(k, W, i, sE), +e: {Nat.is_lt(s, k) == True{} : Bool})
    -> LV.rep_Gc465214E502_bx(LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, Nat.add(s, i))), sE):
  match s:
    case 0n:
      match k:
        case 0n: Empty.absurd(LV.rep_Gc465214E502_bx(LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, Nat.add(0n, i))), sE), MD.false_true(e))
        case 1n+q:
          (+r0, +rs) = er
          r0
    case 1n+ +p1:
      match k:
        case 0n: Empty.absurd(LV.rep_Gc465214E502_bx(LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, Nat.add(1n+p1, i))), sE), MD.false_true(e))
        case 1n+ +q:
          (+r0, +rs) = er
          %MR.add_succ(p1, i) : LV.rep_Gc465214E502_bx(LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, _)), sE)
          erep_at_v2_Gc465214E502(p1, q, W, 1n+i, sE, rs, e)
law xroots_v2_Gc465214E502:
  for +k: Nat
  for +W: List<&2, LV.MB<LV.M_Gc465214E502>>
  for +i: Nat
  for +hl: Nat
  for +ehl: {hl == 64n : Nat}
  for -h: B.Buf
  for +sE: S.Schema
  for +er: LV.ereps_v2_Gc465214E502(k, W, i, sE)
  for +dv: OS.DV
  for +edv: {dv == OS.DV0() : OS.DV}
  for +ok: {ok_Gc465214E502_bx(sE, dv) == True{} : Bool}
  for +eq: eqs_Gc465214E502_bx(sE)
  RR.roots(LV.xi_v2_Gc465214E502(k, W, i), S.Repeat{sE}, MD.bytes_list(xl_v2_Gc465214E502(k, W, i, hl)))
def xroots_v2_Gc465214E502(k, W, i, hl, ehl, h, sE, er, dv, edv, ok, eq):
  match k:
    case 0n: {==}
    case 1n+ +q:
      (+r0, +rs) = er
      ([D.bytes(d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, i))))], (MD.bytes_list(xl_v2_Gc465214E502(q, W, 1n+i, hl)), (rs_Gc465214E502_bx(hl, ehl, h, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(W, i)), sE, r0, dv, edv, ok, eq), (xroots_v2_Gc465214E502(q, W, 1n+i, hl, ehl, h, sE, rs, dv, edv, ok, eq), {==}))))
law xcount_v2_Gc465214E502:
  for +k: Nat
  for +W: List<&2, LV.MB<LV.M_Gc465214E502>>
  for +i: Nat
  {Codec.count(LV.xi_v2_Gc465214E502(k, W, i)) == k : Nat}
def xcount_v2_Gc465214E502(k, W, i):
  match k:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Codec.count(LV.xi_v2_Gc465214E502(q, W, 1n+i)), q, xcount_v2_Gc465214E502(q, W, 1n+i)) : {1n+_ == 1n+q : Nat}
      {==}
law xph1_v2_Gc465214E502:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +seg: U32
  for +v: Nat
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for -ws: Array<O.Boxed<VarTestStruct_d.Gc465214E502>>
  for +dl: D.Digest
  {vec_VarTestStruct_2_h.v2_Gc465214E502_mt(d, 1n, b, hl, seg, v, s, n, (h, (ws, dl))) == vec_VarTestStruct_2_h.v2_Gc465214E502_mj(hl, dl, vec_VarTestStruct_2_h.v2_Gc465214E502_mt(d, 0n, b, hl, seg, v, s, n, (h, (ws, D.zero())))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
def xph1_v2_Gc465214E502(d, b, hl, seg, v, s, n, h, ws, dl):
  match d:
    case 0n: {==}
    case 1n+q: {==}
law xmt_v2_Gc465214E502:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +seg: U32
  for +dw: Nat
  for +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>
  for +s: Nat
  for +n: Nat
  for -h: B.Buf
  for +junk: D.Digest
  for +e: {Nat.is_lt(s, n) == b : Bool}
  for +hd: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pf: {F.array__perfect(LV.MB<LV.M_Gc465214E502>, dw, t) == True{} : Bool}
  for +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool}
  for +sE: S.Schema
  for +er: LV.ereps_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, sE)
  {vec_VarTestStruct_2_h.v2_Gc465214E502_mt(d, 0n, b, hl, seg, O.pow2n(d), s, n, (h, (LV.am_v2_Gc465214E502(t), junk))) == (h, (LV.am_v2_Gc465214E502(t), MD.rtree(d, b, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
def xmt_v2_Gc465214E502(d, b, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn, sE, er):
  match d:
    case 0n:
      match b:
        case False{}: {==}
        case True{}:
          +hs = F.nat__lt_le_trans(s, n, F.spec_common__pow2(dw), e, hn)
          +e1 = F.u32__to_nat_from_nat(s, dw, F.nat__lt_le(dw, 32n, hd), hs)
          +hx = XS.at_nth(LV.MB<LV.M_Gc465214E502>, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s, U32.to_nat(U32.from_nat(s)), LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s), e1, nth_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s, XS.lt_len(LV.MB<LV.M_Gc465214E502>, dw, t, s, pf, hs)))
          +rx = F.logic__subst(Nat, j => LV.rep_Gc465214E502_bx(LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), j)), sE), Nat.add(s, 0n), s, MR.add_zero(s), erep_at_v2_Gc465214E502(s, n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, sE, er, e))
          %Equal.sym(Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & O.Boxed<VarTestStruct_d.Gc465214E502>, Array.swap(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(t), U32.from_nat(s), O.BNone{}), (LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, dw, t, U32.to_nat(U32.from_nat(s)), LV.MNone{})), LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s))),
              amswap_v2_Gc465214E502(dw, t, U32.from_nat(s), LV.MNone{}, LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s), hd, MR.hi_at(dw, s, hd, hs), hx, pf)) :
            {vec_VarTestStruct_2_h.v2_Gc465214E502_rl(hl, U32.from_nat(s), seg, h, _) == (h, (LV.am_v2_Gc465214E502(t), MD.rtree(0n, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          %Equal.sym(B.Buf & (O.Boxed<VarTestStruct_d.Gc465214E502> & D.Digest), VarTestStruct_h.Gc465214E502_bx_root(hl, h, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s)), (seg + 64 : U32)), (h, (LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s)), d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s))))), st_Gc465214E502_bx(hl, h, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s)), (seg + 64 : U32), sE, rx)) :
            {vec_VarTestStruct_2_h.v2_Gc465214E502_rl_n(U32.from_nat(s), LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, dw, t, U32.to_nat(U32.from_nat(s)), LV.MNone{})), _) == (h, (LV.am_v2_Gc465214E502(t), MD.rtree(0n, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          %Equal.sym(Array<O.Boxed<VarTestStruct_d.Gc465214E502>>, Array.set(O.Boxed<VarTestStruct_d.Gc465214E502>, LV.am_v2_Gc465214E502(F.array__upd(LV.MB<LV.M_Gc465214E502>, dw, t, U32.to_nat(U32.from_nat(s)), LV.MNone{})), U32.from_nat(s), LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s))), LV.am_v2_Gc465214E502(t), amswap_back_v2_Gc465214E502(dw, t, U32.from_nat(s), LV.MNone{}, LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s), hd, MR.hi_at(dw, s, hd, hs), hx, pf)) :
            {(h, (_, d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s))))) == (h, (LV.am_v2_Gc465214E502(t), MD.rtree(0n, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          %Equal.sym(D.Digest, MD.dhead(MD.ddrop(s, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl))), d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), Nat.add(s, 0n)))), xat_at_v2_Gc465214E502(s, n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl, e)) :
            {(h, (LV.am_v2_Gc465214E502(t), d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s))))) == (h, (LV.am_v2_Gc465214E502(t), _)) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          %Equal.sym(Nat, Nat.add(s, 0n), s, MR.add_zero(s)) :
            {(h, (LV.am_v2_Gc465214E502(t), d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), s))))) == (h, (LV.am_v2_Gc465214E502(t), d_Gc465214E502_bx(hl, LV.th_Gc465214E502_bx(LV.xat_v2_Gc465214E502(F.array__slots(LV.MB<LV.M_Gc465214E502>, t), _))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          {==}
    case 1n+ +q:
      match b:
        case False{}: {==}
        case True{}:
          %Equal.sym(Nat, MD.dlen(xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl)), n, xlen_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl)) :
            {vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 1n, Nat.is_lt(Nat.add(s, Nat.div(Nat.double(O.pow2n(q)), 2n)), n), hl, seg, Nat.div(Nat.double(O.pow2n(q)), 2n), Nat.add(s, Nat.div(Nat.double(O.pow2n(q)), 2n)), n, vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 0n, True{}, hl, seg, Nat.div(Nat.double(O.pow2n(q)), 2n), s, n, (h, (LV.am_v2_Gc465214E502(t), junk)))) == (h, (LV.am_v2_Gc465214E502(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), _), hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          %Equal.sym(Nat, Nat.div(Nat.double(O.pow2n(q)), 2n), O.pow2n(q), MR.div_double(O.pow2n(q))) :
            {vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 1n, Nat.is_lt(Nat.add(s, _), n), hl, seg, _, Nat.add(s, _), n, vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 0n, True{}, hl, seg, _, s, n, (h, (LV.am_v2_Gc465214E502(t), junk)))) == (h, (LV.am_v2_Gc465214E502(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          %Equal.sym(B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest), vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 0n, True{}, hl, seg, O.pow2n(q), s, n, (h, (LV.am_v2_Gc465214E502(t), junk))), (h, (LV.am_v2_Gc465214E502(t), MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s))), xmt_v2_Gc465214E502(q, True{}, hl, seg, dw, t, s, n, h, junk, e, hd, pf, hn, sE, er)) :
            {vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 1n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, _) == (h, (LV.am_v2_Gc465214E502(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          %Equal.sym(B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest), vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 1n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (LV.am_v2_Gc465214E502(t), MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s)))),
              vec_VarTestStruct_2_h.v2_Gc465214E502_mj(hl, MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s), vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 0n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (LV.am_v2_Gc465214E502(t), D.zero())))),
              xph1_v2_Gc465214E502(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, h, LV.am_v2_Gc465214E502(t), MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s))) :
            {_ == (h, (LV.am_v2_Gc465214E502(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          %Equal.sym(B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest), vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 0n, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(s, O.pow2n(q)), n, (h, (LV.am_v2_Gc465214E502(t), D.zero()))), (h, (LV.am_v2_Gc465214E502(t), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), Nat.add(s, O.pow2n(q))))),
              xmt_v2_Gc465214E502(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, seg, dw, t, Nat.add(s, O.pow2n(q)), n, h, D.zero(), {==}, hd, pf, hn, sE, er)) :
            {vec_VarTestStruct_2_h.v2_Gc465214E502_mj(hl, MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s), _) == (h, (LV.am_v2_Gc465214E502(t), D.node(hl, MD.rtree(q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), s), MD.rtree(q, Nat.is_lt(Nat.add(s, O.pow2n(q)), n), hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), Nat.add(s, O.pow2n(q)))))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          {==}
def xmt0_v2_Gc465214E502(+d: Nat, +b: Bool, +hl: Nat, +seg: U32, +dw: Nat, +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>, +n: Nat, -h: B.Buf, +junk: D.Digest,
    +e: {Nat.is_lt(0n, n) == b : Bool}, +hd: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pf: {F.array__perfect(LV.MB<LV.M_Gc465214E502>, dw, t) == True{} : Bool}, +hn: {Nat.is_le(n, F.spec_common__pow2(dw)) == True{} : Bool},
    +sE: S.Schema, +er: LV.ereps_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, sE))
    -> {vec_VarTestStruct_2_h.v2_Gc465214E502_mt0(d, b, hl, seg, n, (h, (LV.am_v2_Gc465214E502(t), junk))) == (h, (LV.am_v2_Gc465214E502(t), MD.rtree(d, b, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), 0n))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}:
  match d:
    case 0n: xmt_v2_Gc465214E502(0n, b, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn, sE, er)
    case 1n+ +q:
      match b:
        case False{}: {==}
        case True{}:
          %MR.div_double(O.pow2n(q)) :
            {vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 1n, Nat.is_lt(Nat.add(0n, _), n), hl, seg, _, Nat.add(0n, _), n, vec_VarTestStruct_2_h.v2_Gc465214E502_mt(q, 0n, True{}, hl, seg, _, 0n, n, (h, (LV.am_v2_Gc465214E502(t), junk)))) == (h, (LV.am_v2_Gc465214E502(t), MD.rtree(1n+q, True{}, hl, xl_v2_Gc465214E502(n, F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), 0n))) : B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest)}
          xmt_v2_Gc465214E502(1n+q, True{}, hl, seg, dw, t, 0n, n, h, junk, e, hd, pf, hn, sE, er)
law tfzam_v2_Gc465214E502:
  for +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>
  {LV.tfz_v2_Gc465214E502(LV.am_v2_Gc465214E502(t)) == t : F.array__Tree<LV.MB<LV.M_Gc465214E502>>}
def tfzam_v2_Gc465214E502(t):
  match t:
    case F.TLeaf{+x}:
      %Equal.sym(LV.MB<LV.M_Gc465214E502>, LV.fz_Gc465214E502_bx(LV.th_Gc465214E502_bx(x)), x, fzth_Gc465214E502_bx(x)) : {F.TLeaf{_} == F.TLeaf{x} : F.array__Tree<LV.MB<LV.M_Gc465214E502>>}
      {==}
    case F.TNode{+l, +r}:
      %Equal.sym(F.array__Tree<LV.MB<LV.M_Gc465214E502>>, LV.tfz_v2_Gc465214E502(LV.am_v2_Gc465214E502(l)), l, tfzam_v2_Gc465214E502(l)) : {F.TNode{_, LV.tfz_v2_Gc465214E502(LV.am_v2_Gc465214E502(r))} == F.TNode{l, r} : F.array__Tree<LV.MB<LV.M_Gc465214E502>>}
      %Equal.sym(F.array__Tree<LV.MB<LV.M_Gc465214E502>>, LV.tfz_v2_Gc465214E502(LV.am_v2_Gc465214E502(r)), r, tfzam_v2_Gc465214E502(r)) : {F.TNode{l, _} == F.TNode{l, r} : F.array__Tree<LV.MB<LV.M_Gc465214E502>>}
      {==}
def xd_v2_Gc465214E502(+hl: Nat, o: vec_VarTestStruct_2_d.v2_Gc465214E502_Seq) -> D.Digest:
  match o:
    case vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{arr, +n}: MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(n)), hl, xl_v2_Gc465214E502(U32.to_nat(n), F.array__slots(LV.MB<LV.M_Gc465214E502>, LV.tfz_v2_Gc465214E502(arr)), 0n, hl), 0n)
def ok_v2_Gc465214E502(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_Vector(s), Bool.and(Lim.minimal(SH.Vector_length(s), 1n), ok_Gc465214E502_bx(SH.Vector_element(s), dv)))
def eqs_v2_Gc465214E502(+s: S.Schema) -> Data: eqs_Gc465214E502_bx(SH.Vector_element(s))
def st_v2_Gc465214E502(+hl: Nat, -h: B.Buf, -o: vec_VarTestStruct_2_d.v2_Gc465214E502_Seq, +seg: U32, +s: S.Schema, +rep: LV.rep_v2_Gc465214E502(o, s))
    -> {vec_VarTestStruct_2_h.v2_Gc465214E502_root(hl, h, o, seg) == (h, (o, xd_v2_Gc465214E502(hl, o))) : B.Buf & (vec_VarTestStruct_2_d.v2_Gc465214E502_Seq & D.Digest)}:
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, w6) = w5
  (+hn, +er) = w6
  %Equal.sym(vec_VarTestStruct_2_d.v2_Gc465214E502_Seq, o, vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N}, eo) :
    {vec_VarTestStruct_2_h.v2_Gc465214E502_root(hl, h, _, seg) == (h, (_, xd_v2_Gc465214E502(hl, _))) : B.Buf & (vec_VarTestStruct_2_d.v2_Gc465214E502_Seq & D.Digest)}
  %Equal.sym(B.Buf & (Array<O.Boxed<VarTestStruct_d.Gc465214E502>> & D.Digest), vec_VarTestStruct_2_h.v2_Gc465214E502_mt0(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, U32.to_nat(N), (h, (LV.am_v2_Gc465214E502(t), D.zero()))), (h, (LV.am_v2_Gc465214E502(t), MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), 0n))),
      xmt0_v2_Gc465214E502(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, seg, dw, t, U32.to_nat(N), h, D.zero(), {==}, hd, pf, hn, SH.Vector_element(s), er)) :
    {vec_VarTestStruct_2_h.v2_Gc465214E502_rt_fin(hl, N, _) == (h, (vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N}, xd_v2_Gc465214E502(hl, vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N}))) : B.Buf & (vec_VarTestStruct_2_d.v2_Gc465214E502_Seq & D.Digest)}
  %Equal.sym(F.array__Tree<LV.MB<LV.M_Gc465214E502>>, LV.tfz_v2_Gc465214E502(LV.am_v2_Gc465214E502(t)), t, tfzam_v2_Gc465214E502(t)) :
    {(h, (vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N}, MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), 0n))) == (h, (vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N}, MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, _), 0n, hl), 0n))) : B.Buf & (vec_VarTestStruct_2_d.v2_Gc465214E502_Seq & D.Digest)}
  {==}
def xhl_v2_Gc465214E502(+N: U32, +Lm: Nat, +Wl: List<&2, LV.MB<LV.M_Gc465214E502>>, +hl: Nat, +hv: {Nat.is_le(U32.to_nat(N), Lm) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(xl_v2_Gc465214E502(U32.to_nat(N), Wl, 0n, hl)), Lm) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(xl_v2_Gc465214E502(U32.to_nat(N), Wl, 0n, hl)), U32.to_nat(N), xlen_v2_Gc465214E502(U32.to_nat(N), Wl, 0n, hl)) : {Nat.is_le(_, Lm) == True{} : Bool}
  hv
def xhv_v2_Gc465214E502(-o: vec_VarTestStruct_2_d.v2_Gc465214E502_Seq, +t: F.array__Tree<LV.MB<LV.M_Gc465214E502>>, +N: U32, +Lm: Nat, +eo: {o == vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N} : vec_VarTestStruct_2_d.v2_Gc465214E502_Seq},
    +hv: {Nat.is_eq(U32.to_nat(LV.xlen_o_v2_Gc465214E502(o)), Lm) == True{} : Bool}) -> {Nat.is_eq(U32.to_nat(N), Lm) == True{} : Bool}:
  %Equal.cong(vec_VarTestStruct_2_d.v2_Gc465214E502_Seq, U32, LV.xlen_o_v2_Gc465214E502, o, vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N}, eo) : {Nat.is_eq(U32.to_nat(_), Lm) == True{} : Bool}
  hv
def wd_v2_Gc465214E502(+hl: Nat, -o: vec_VarTestStruct_2_d.v2_Gc465214E502_Seq, +s: S.Schema, +rep: LV.rep_v2_Gc465214E502(o, s)) -> OS.DW(xd_v2_Gc465214E502(hl, o)):
  (+wf, +hv) = rep
  (+t, +w1) = wf
  (+dw, +w2) = w1
  (+N, +w3) = w2
  (+eo, +w4) = w3
  %Equal.sym(vec_VarTestStruct_2_d.v2_Gc465214E502_Seq, o, vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N}, eo) : OS.DW(xd_v2_Gc465214E502(hl, _))
  %Equal.sym(F.array__Tree<LV.MB<LV.M_Gc465214E502>>, LV.tfz_v2_Gc465214E502(LV.am_v2_Gc465214E502(t)), t, tfzam_v2_Gc465214E502(t)) : OS.DW(MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, _), 0n, hl), 0n))
  (MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), 0n), {==})
def rs_v2_Gc465214E502(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: vec_VarTestStruct_2_d.v2_Gc465214E502_Seq, +s: S.Schema, +rep: LV.rep_v2_Gc465214E502(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}, +ok: {ok_v2_Gc465214E502(s, dv) == True{} : Bool}, +eq: eqs_v2_Gc465214E502(s))
    -> RR.roots(LV.xv_v2_Gc465214E502(o), s, [D.bytes(xd_v2_Gc465214E502(hl, o))]):
  (+wf, +hv) = rep
  (+t, w1) = wf
  (+dw, w2) = w1
  (+N, w3) = w2
  (+eo, w4) = w3
  (+pf, w5) = w4
  (+hd, w6) = w5
  (+hn, +er) = w6
  +k0 = DK.and_l(SH.is_Vector(s), Bool.and(Lim.minimal(SH.Vector_length(s), 1n), ok_Gc465214E502_bx(SH.Vector_element(s), dv)), ok)
  +k1 = DK.and_r(SH.is_Vector(s), Bool.and(Lim.minimal(SH.Vector_length(s), 1n), ok_Gc465214E502_bx(SH.Vector_element(s), dv)), ok)
  +kmin = DK.and_l(Lim.minimal(SH.Vector_length(s), 1n), ok_Gc465214E502_bx(SH.Vector_element(s), dv), k1)
  +kel = DK.and_r(Lim.minimal(SH.Vector_length(s), 1n), ok_Gc465214E502_bx(SH.Vector_element(s), dv), k1)
  +hvN = veq_le(U32.to_nat(N), SH.Vector_length(s), xhv_v2_Gc465214E502(o, t, N, SH.Vector_length(s), eo, hv))
  +ebs = bs_cont(SH.Vector_element(s), okc_Gc465214E502(SH.Vector_element(s), dv, kel))
  %Equal.sym(S.Schema, s, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, SH.Vector_shape(s, k0)) :
    RR.roots(LV.xv_v2_Gc465214E502(o), _, [D.bytes(xd_v2_Gc465214E502(hl, o))])
  %Equal.sym(vec_VarTestStruct_2_d.v2_Gc465214E502_Seq, o, vec_VarTestStruct_2_d.v2_Gc465214E502_Seq{LV.am_v2_Gc465214E502(t), N}, eo) :
    RR.roots(LV.xv_v2_Gc465214E502(_), S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, [D.bytes(xd_v2_Gc465214E502(hl, _))])
  %Equal.sym(F.array__Tree<LV.MB<LV.M_Gc465214E502>>, LV.tfz_v2_Gc465214E502(LV.am_v2_Gc465214E502(t)), t, tfzam_v2_Gc465214E502(t)) :
    RR.roots(S.Sequence{LV.xi_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, _), 0n)}, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, [D.bytes(MD.rtree(1n, Nat.is_lt(0n, U32.to_nat(N)), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, _), 0n, hl), 0n))])
  %xlen_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl) :
    RR.roots(S.Sequence{LV.xi_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n)}, S.Vector{SH.Vector_element(s), SH.Vector_length(s)}, [D.bytes(MD.rtree(1n, Nat.is_lt(0n, _), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), 0n))])
  vec_none(LV.xi_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n), SH.Vector_element(s), SH.Vector_length(s), [D.bytes(MD.rtree(1n, Nat.is_lt(0n, MD.dlen(xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl))), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), 0n))], ebs,
  (MD.bytes_list(xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl)), (xroots_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl, ehl, h, SH.Vector_element(s), er, dv, edv, kel, eq),
    (D.bytes(MD.rtree(1n, Nat.is_lt(0n, MD.dlen(xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl))), hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), 0n)), ((1n, (kmin, RS.at_depth_tree(SH.Vector_length(s), 1n, hl, xl_v2_Gc465214E502(U32.to_nat(N), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), 0n, hl), {==}, xhl_v2_Gc465214E502(N, SH.Vector_length(s), F.array__slots(LV.MB<LV.M_Gc465214E502>, t), hl, hvN), ehl))),
     {==})))))

def d_Gc56D855869F(+hl: Nat, o: ComplexTestStruct_d.Gc56D855869F) -> D.Digest:
  match o:
    case ComplexTestStruct_d.Gc56D855869F{+x0, x1, +x2, x3, x4, x5, x6}: MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), BLI.bdig(hl, x1, 3n, 1n), RN.d_u8(hl, x2), LO.ldig(hl, x3, 3n), d_Gc465214E502(hl, x4), xd_v4_GcDC3E457711(hl, x5), xd_v2_Gc465214E502(hl, x6)], 0n)
def ok_Gc56D855869F(+s: S.Schema, +dv: OS.DV) -> Bool: Bool.and(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))))
def okc_Gc56D855869F(+s: S.Schema, +dv: OS.DV, +ok: {ok_Gc56D855869F(s, dv) == True{} : Bool}) -> {SH.is_Container(s) == True{} : Bool}: DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
def eqs_Gc56D855869F(+s: S.Schema) -> Data: DK.P2({SH.Chain_head(SH.Container_fields(s)) == S.Unsigned{P.U16{}} : S.Schema}, DK.P2({SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))) == S.Unsigned{P.U8{}} : S.Schema}, DK.P2(eqs_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), DK.P2({SH.Vector_element(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))) == S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}} : S.Schema}, eqs_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))
def fsh_Gc56D855869F(+s: S.Schema, +dv: OS.DV, +ok: {ok_Gc56D855869F(s, dv) == True{} : Bool}) -> {SH.Container_fields(s) == S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}} : S.Schema}:
  +k0 = DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
  +r1 = DK.and_r(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
  +k1 = DK.and_l(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))))), r1)
  +r2 = DK.and_r(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))))), r1)
  +k2 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))), r2)
  +r3 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))), r2)
  +k3 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))), r3)
  +r4 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))), r3)
  +k4 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))), r4)
  +r5 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))), r4)
  +k5 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))), r5)
  +r6 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))), r5)
  +k6 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))), r6)
  +r7 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))), r6)
  +k7 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))), r7)
  +r8 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))), r7)
  +k8 = DK.and_l(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))), r8)
  +r9 = DK.and_r(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))), r8)
  +k9 = DK.and_l(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))), r9)
  +r10 = DK.and_r(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))), r9)
  +k10 = DK.and_l(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))), r10)
  +r11 = DK.and_r(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))), r10)
  +k11 = DK.and_l(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)), r11)
  +r12 = DK.and_r(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)), r11)
  +k12 = DK.and_l(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv), r12)
  +r13 = DK.and_r(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv), r12)
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
def st_Gc56D855869F(+hl: Nat, -h: B.Buf, -o: ComplexTestStruct_d.Gc56D855869F, +seg: U32, +s: S.Schema, +rep: LV.rep_Gc56D855869F(o, s))
    -> {ComplexTestStruct_h.Gc56D855869F_root(hl, h, o, seg) == (h, (o, d_Gc56D855869F(hl, o))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}:
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  (+rp2, +q5) = q4
  (+rp3, +q6) = q5
  (+rp4, +q7) = q6
  (+rp5, +q8) = q7
  %Equal.sym(ComplexTestStruct_d.Gc56D855869F, o, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, eo) :
    {ComplexTestStruct_h.Gc56D855869F_root(hl, h, _, seg) == (h, (_, d_Gc56D855869F(hl, _))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, uint16_h.u16_root(hl, h, x0, seg), (h, RN.d_u16(hl, x0)), RN.st_u16(hl, h, x0, seg)) :
    {ComplexTestStruct_h.Gc56D855869F_rt0(hl, seg, x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o), _) == (h, (ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), list_uint16_128_h.l128_u16_root(hl, h, LV.pj_Gc56D855869F_1(o), seg), (h, (LV.pj_Gc56D855869F_1(o), BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n))), BLI.bl_st(hl, h, LV.pj_Gc56D855869F_1(o), 3, seg, 3n, 1n, BLI_L.rep_wf2(LV.pj_Gc56D855869F_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), rp1), {==})) :
    {ComplexTestStruct_h.Gc56D855869F_rt1(hl, seg, x0, x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o), RN.d_u16(hl, x0), _) == (h, (ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, uint8_h.u8_root(hl, h, x2, seg), (h, RN.d_u8(hl, x2)), RN.st_u8(hl, h, x2, seg)) :
    {ComplexTestStruct_h.Gc56D855869F_rt2(hl, seg, x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), _) == (h, (ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}
  %Equal.sym(B.Buf & (O.Words & D.Digest), bytelist_256_h.bl256_root(hl, h, LV.pj_Gc56D855869F_3(o), seg), (h, (LV.pj_Gc56D855869F_3(o), LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n))), LO.bl_st(hl, h, LV.pj_Gc56D855869F_3(o), 3, seg, 3n, LO_L.rep_wf(LV.pj_Gc56D855869F_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), rp3), {==})) :
    {ComplexTestStruct_h.Gc56D855869F_rt3(hl, seg, x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), RN.d_u8(hl, x2), _) == (h, (ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}
  %Equal.sym(B.Buf & (VarTestStruct_d.Gc465214E502 & D.Digest), VarTestStruct_h.Gc465214E502_root(hl, h, LV.pj_Gc56D855869F_4(o), seg), (h, (LV.pj_Gc56D855869F_4(o), d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)))), st_Gc465214E502(hl, h, LV.pj_Gc56D855869F_4(o), seg, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4)) :
    {ComplexTestStruct_h.Gc56D855869F_rt4(hl, seg, x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), _) == (h, (ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}
  %Equal.sym(B.Buf & (vec_FixedTestStruct_4_d.v4_GcDC3E457711_Seq & D.Digest), vec_FixedTestStruct_4_h.v4_GcDC3E457711_root(hl, h, LV.pj_Gc56D855869F_5(o), seg), (h, (LV.pj_Gc56D855869F_5(o), xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)))), st_v4_GcDC3E457711(hl, h, LV.pj_Gc56D855869F_5(o), seg, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5)) :
    {ComplexTestStruct_h.Gc56D855869F_rt5(hl, seg, x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_6(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), _) == (h, (ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}
  %Equal.sym(B.Buf & (vec_VarTestStruct_2_d.v2_Gc465214E502_Seq & D.Digest), vec_VarTestStruct_2_h.v2_Gc465214E502_root(hl, h, LV.pj_Gc56D855869F_6(o), seg), (h, (LV.pj_Gc56D855869F_6(o), xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o)))), st_v2_Gc465214E502(hl, h, LV.pj_Gc56D855869F_6(o), seg, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8)) :
    {ComplexTestStruct_h.Gc56D855869F_rt6(hl, seg, x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), RN.d_u16(hl, x0), BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), _) == (h, (ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))) : B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest)}
  {==}
def wd_Gc56D855869F(+hl: Nat, -o: ComplexTestStruct_d.Gc56D855869F, +s: S.Schema, +rep: LV.rep_Gc56D855869F(o, s)) -> OS.DW(d_Gc56D855869F(hl, o)):
  (+x0, +q0) = rep
  (+x2, +q1) = q0
  (+eo, +q2) = q1
  (+rp0, +q3) = q2
  (+rp1, +q4) = q3
  (+rp2, +q5) = q4
  (+rp3, +q6) = q5
  (+rp4, +q7) = q6
  (+rp5, +q8) = q7
  +dd1 = OS.dwv(BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), wd_l2(hl, LV.pj_Gc56D855869F_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, rp1))
  +de1 = OS.dwe(BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), wd_l2(hl, LV.pj_Gc56D855869F_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, rp1))
  +dd3 = OS.dwv(LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), wd_bl(hl, LV.pj_Gc56D855869F_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, rp3))
  +de3 = OS.dwe(LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), wd_bl(hl, LV.pj_Gc56D855869F_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, rp3))
  +dd4 = OS.dwv(d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), wd_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4))
  +de4 = OS.dwe(d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), wd_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4))
  +dd5 = OS.dwv(xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), wd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5))
  +de5 = OS.dwe(xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), wd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5))
  +dd6 = OS.dwv(xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o)), wd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8))
  +de6 = OS.dwe(xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o)), wd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8))
  %Equal.sym(ComplexTestStruct_d.Gc56D855869F, o, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, eo) : OS.DW(d_Gc56D855869F(hl, _))
  %Equal.sym(D.Digest, BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), dd1, de1) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), _, RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o))], 0n))
  %Equal.sym(D.Digest, LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), dd3, de3) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), _, d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o))], 0n))
  %Equal.sym(D.Digest, d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), dd4, de4) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, _, xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o))], 0n))
  %Equal.sym(D.Digest, xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), dd5, de5) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, _, xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o))], 0n))
  %Equal.sym(D.Digest, xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o)), dd6, de6) :
    OS.DW(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, _], 0n))
  (MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, dd6], 0n), {==})
def rs_Gc56D855869F(+hl: Nat, +ehl: {hl == 64n : Nat}, -h: B.Buf, -o: ComplexTestStruct_d.Gc56D855869F, +s: S.Schema, +rep: LV.rep_Gc56D855869F(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}, +ok: {ok_Gc56D855869F(s, dv) == True{} : Bool}, +ev: eqs_Gc56D855869F(s))
    -> RR.roots(LV.v_Gc56D855869F(o), s, [D.bytes(d_Gc56D855869F(hl, o))]):
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
  +dd1 = OS.dwv(BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), wd_l2(hl, LV.pj_Gc56D855869F_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, rp1))
  +de1 = OS.dwe(BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), wd_l2(hl, LV.pj_Gc56D855869F_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, rp1))
  +dd3 = OS.dwv(LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), wd_bl(hl, LV.pj_Gc56D855869F_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, rp3))
  +de3 = OS.dwe(LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), wd_bl(hl, LV.pj_Gc56D855869F_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, rp3))
  +dd4 = OS.dwv(d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), wd_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4))
  +de4 = OS.dwe(d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), wd_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4))
  +dd5 = OS.dwv(xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), wd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5))
  +de5 = OS.dwe(xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), wd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5))
  +dd6 = OS.dwv(xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o)), wd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8))
  +de6 = OS.dwe(xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o)), wd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8))
  +k0 = DK.and_l(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
  +r1 = DK.and_r(SH.is_Container(s), Bool.and(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))))), ok)
  +k1 = DK.and_l(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))))), r1)
  +r2 = DK.and_r(SH.is_Chain(SH.Container_fields(s)), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))))), r1)
  +k2 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))), r2)
  +r3 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Container_fields(s))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))))), r2)
  +k3 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))), r3)
  +r4 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))))), r3)
  +k4 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))), r4)
  +r5 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))))), r4)
  +k5 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))), r5)
  +r6 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))))), r5)
  +k6 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))), r6)
  +r7 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), Bool.and(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))))), r6)
  +k7 = DK.and_l(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))), r7)
  +r8 = DK.and_r(SH.is_Chain(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), Bool.and(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))))), r7)
  +k8 = DK.and_l(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))), r8)
  +r9 = DK.and_r(SH.is_End(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), Bool.and(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))))), r8)
  +k9 = DK.and_l(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))), r9)
  +r10 = DK.and_r(BLI.ok_l2(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n), Bool.and(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)))), r9)
  +k10 = DK.and_l(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))), r10)
  +r11 = DK.and_r(LO_L.ok_bl(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n), Bool.and(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv))), r10)
  +k11 = DK.and_l(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)), r11)
  +r12 = DK.and_r(ok_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dv), Bool.and(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv)), r11)
  +k12 = DK.and_l(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv), r12)
  +r13 = DK.and_r(ok_v4_GcDC3E457711(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), ok_v2_Gc465214E502(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dv), r12)
  %Equal.sym(ComplexTestStruct_d.Gc56D855869F, o, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}, eo) : RR.roots(LV.v_Gc56D855869F(_), s, [D.bytes(d_Gc56D855869F(hl, _))])
  %Equal.sym(S.Schema, s, S.Container{SH.Container_names(s), SH.Container_fields(s)}, SH.Container_shape(s, k0)) :
    RR.roots(LV.v_Gc56D855869F(ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}), _, [D.bytes(d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))])
  %Equal.sym(S.Schema, SH.Container_fields(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}, fsh_Gc56D855869F(s, dv, ok)) :
    RR.roots(LV.v_Gc56D855869F(ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}), S.Container{SH.Container_names(s), _}, [D.bytes(d_Gc56D855869F(hl, ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}))])
  %Equal.sym(D.Digest, BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), dd1, de1) :
    RR.roots(LV.v_Gc56D855869F(ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), _, RN.d_u8(hl, x2), LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o))], 0n))])
  %Equal.sym(D.Digest, LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), dd3, de3) :
    RR.roots(LV.v_Gc56D855869F(ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), _, d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o))], 0n))])
  %Equal.sym(D.Digest, d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), dd4, de4) :
    RR.roots(LV.v_Gc56D855869F(ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, _, xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o))], 0n))])
  %Equal.sym(D.Digest, xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), dd5, de5) :
    RR.roots(LV.v_Gc56D855869F(ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, _, xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o))], 0n))])
  %Equal.sym(D.Digest, xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o)), dd6, de6) :
    RR.roots(LV.v_Gc56D855869F(ComplexTestStruct_d.Gc56D855869F{x0, LV.pj_Gc56D855869F_1(o), x2, LV.pj_Gc56D855869F_3(o), LV.pj_Gc56D855869F_4(o), LV.pj_Gc56D855869F_5(o), LV.pj_Gc56D855869F_6(o)}), S.Container{SH.Container_names(s), S.Chain{SH.Chain_head(SH.Container_fields(s)), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), S.Chain{SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), S.End{}}}}}}}}}, [D.bytes(MD.rtree(3n, True{}, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, _], 0n))])
  (MD.bytes_list([RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, dd6]), (([D.bytes(RN.d_u16(hl, x0))], (MD.bytes_list([dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, dd6]), (OS.transport(RN_L.v_u16(x0), SH.Chain_head(SH.Container_fields(s)), S.Unsigned{P.U16{}}, [D.bytes(RN.d_u16(hl, x0))], qe0, RN.rs_u16(hl, ehl, x0, rp0)), (([D.bytes(dd1)], (MD.bytes_list([RN.d_u8(hl, x2), dd3, dd4, dd5, dd6]), (OS.dtrans(PB_L.vview2(LV.pj_Gc56D855869F_1(o)), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), dd1, BLI.bdig(hl, LV.pj_Gc56D855869F_1(o), 3n, 1n), de1, BLI.l2_rs(hl, ehl, h, LV.pj_Gc56D855869F_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))), 3n, 3, 0, rp1, k9, {==}, {==})), (([D.bytes(RN.d_u8(hl, x2))], (MD.bytes_list([dd3, dd4, dd5, dd6]), (OS.transport(RN_L.v_u8(x2), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))), S.Unsigned{P.U8{}}, [D.bytes(RN.d_u8(hl, x2))], qe2, RN.rs_u8(hl, ehl, x2, rp2)), (([D.bytes(dd3)], (MD.bytes_list([dd4, dd5, dd6]), (OS.dtrans(S.BytesValue{WO_L.wview(LV.pj_Gc56D855869F_3(o))}, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), dd3, LO.ldig(hl, LV.pj_Gc56D855869F_3(o), 3n), de3, LO.bl_rs(hl, ehl, h, LV.pj_Gc56D855869F_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), 3n, 3, 0, rp3, k10, {==}, {==})), (([D.bytes(dd4)], (MD.bytes_list([dd5, dd6]), (OS.dtrans(LV.v_Gc465214E502(LV.pj_Gc56D855869F_4(o)), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), dd4, d_Gc465214E502(hl, LV.pj_Gc56D855869F_4(o)), de4, rs_Gc465214E502(hl, ehl, h, LV.pj_Gc56D855869F_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), rp4, dv, edv, k11, qe4)), (([D.bytes(dd5)], (MD.bytes_list([dd6]), (OS.dtrans(LV.xv_v4_GcDC3E457711(LV.pj_Gc56D855869F_5(o)), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), dd5, xd_v4_GcDC3E457711(hl, LV.pj_Gc56D855869F_5(o)), de5, rs_v4_GcDC3E457711(hl, ehl, h, LV.pj_Gc56D855869F_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rp5, k12, qe5)), (([D.bytes(dd6)], (MD.bytes_list([]), (OS.dtrans(LV.xv_v2_Gc465214E502(LV.pj_Gc56D855869F_6(o)), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), dd6, xd_v2_Gc465214E502(hl, LV.pj_Gc56D855869F_6(o)), de6, rs_v2_Gc465214E502(hl, ehl, h, LV.pj_Gc56D855869F_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), q8, dv, edv, r13, qv3)), ({==}, {==})))), {==})))), {==})))), {==})))), {==})))), {==})))), {==})))),
    RS.aggregate_digests(7n, 3n, hl, [RN.d_u16(hl, x0), dd1, RN.d_u8(hl, x2), dd3, dd4, dd5, dd6], {==}, {==}, {==}, ehl)))

# Gt83D8B3D008: for every packed byte object representing a value of Spec.Gt83D8B3D008(),
# the runtime root is a specification root of its elements.
def Gt83D8B3D008_ok(+s: S.Schema, +es: {s == Spec.Gt83D8B3D008() : S.Schema}) -> {PG.ok_plb(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt83D8B3D008(), es) : {PG.ok_plb(_) == True{} : Bool}
  {==}
law Gt83D8B3D008_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt83D8B3D008() : S.Schema}
  for +rep: PG_L.rep_plb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_bool_h.Gt83D8B3D008_hash_tree_root(h, o))))])
def Gt83D8B3D008_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 0n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 0n))), PG.pl_st(64n, h, o, 0, 0n, PG_L.rep_wfb(o, s, rep))) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.plb_rs(64n, {==}, o, s, rep, Gt83D8B3D008_ok(s, es))

# Gt1D9B3E1871: for every packed word object representing a value of Spec.Gt1D9B3E1871(),
# the runtime root is a specification root of its elements.
def Gt1D9B3E1871_ok(+s: S.Schema, +es: {s == Spec.Gt1D9B3E1871() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt1D9B3E1871(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law Gt1D9B3E1871_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt1D9B3E1871() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_16_h.Gt1D9B3E1871_hash_tree_root(h, o))))])
def Gt1D9B3E1871_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, Gt1D9B3E1871_ok(s, es), {==})

# GtAE3EF932C2: for every packed word object representing a value of Spec.GtAE3EF932C2(),
# the runtime root is a specification root of its elements.
def GtAE3EF932C2_ok(+s: S.Schema, +es: {s == Spec.GtAE3EF932C2() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtAE3EF932C2(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law GtAE3EF932C2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtAE3EF932C2() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_1_h.GtAE3EF932C2_hash_tree_root(h, o))))])
def GtAE3EF932C2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, GtAE3EF932C2_ok(s, es), {==})

# Gt3771256492: for every packed word object representing a value of Spec.Gt3771256492(),
# the runtime root is a specification root of its elements.
def Gt3771256492_ok(+s: S.Schema, +es: {s == Spec.Gt3771256492() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt3771256492(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law Gt3771256492_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt3771256492() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_2_h.Gt3771256492_hash_tree_root(h, o))))])
def Gt3771256492_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, Gt3771256492_ok(s, es), {==})

# Gt9DF37A5216: for every packed word object representing a value of Spec.Gt9DF37A5216(),
# the runtime root is a specification root of its elements.
def Gt9DF37A5216_ok(+s: S.Schema, +es: {s == Spec.Gt9DF37A5216() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt9DF37A5216(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law Gt9DF37A5216_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt9DF37A5216() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_31_h.Gt9DF37A5216_hash_tree_root(h, o))))])
def Gt9DF37A5216_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, Gt9DF37A5216_ok(s, es), {==})

# Gt57090094FA: for every packed word object representing a value of Spec.Gt57090094FA(),
# the runtime root is a specification root of its elements.
def Gt57090094FA_ok(+s: S.Schema, +es: {s == Spec.Gt57090094FA() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt57090094FA(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law Gt57090094FA_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt57090094FA() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_3_h.Gt57090094FA_hash_tree_root(h, o))))])
def Gt57090094FA_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, Gt57090094FA_ok(s, es), {==})

# GtC57121EA56: for every packed word object representing a value of Spec.GtC57121EA56(),
# the runtime root is a specification root of its elements.
def GtC57121EA56_ok(+s: S.Schema, +es: {s == Spec.GtC57121EA56() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtC57121EA56(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law GtC57121EA56_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtC57121EA56() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_4_h.GtC57121EA56_hash_tree_root(h, o))))])
def GtC57121EA56_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, GtC57121EA56_ok(s, es), {==})

# Gt34AE45611E: for every packed word object representing a value of Spec.Gt34AE45611E(),
# the runtime root is a specification root of its elements.
def Gt34AE45611E_ok(+s: S.Schema, +es: {s == Spec.Gt34AE45611E() : S.Schema}) -> {PB.ok_vb(s, 4n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt34AE45611E(), es) : {PB.ok_vb(_, 4n) == True{} : Bool}
  {==}
law Gt34AE45611E_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt34AE45611E() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_512_h.Gt34AE45611E_hash_tree_root(h, o))))])
def Gt34AE45611E_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 4, 0), (h, (o, WO_L.wdig(64n, o, 4n))), WO.bv_st(64n, h, o, 4, 0, 4n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 4n, rep, Gt34AE45611E_ok(s, es), {==})

# GtEB2FD43D9B: for every packed word object representing a value of Spec.GtEB2FD43D9B(),
# the runtime root is a specification root of its elements.
def GtEB2FD43D9B_ok(+s: S.Schema, +es: {s == Spec.GtEB2FD43D9B() : S.Schema}) -> {PB.ok_vb(s, 5n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtEB2FD43D9B(), es) : {PB.ok_vb(_, 5n) == True{} : Bool}
  {==}
law GtEB2FD43D9B_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtEB2FD43D9B() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_513_h.GtEB2FD43D9B_hash_tree_root(h, o))))])
def GtEB2FD43D9B_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 5, 0), (h, (o, WO_L.wdig(64n, o, 5n))), WO.bv_st(64n, h, o, 5, 0, 5n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 5n, rep, GtEB2FD43D9B_ok(s, es), {==})

# Gt7FBB1934E8: for every packed word object representing a value of Spec.Gt7FBB1934E8(),
# the runtime root is a specification root of its elements.
def Gt7FBB1934E8_ok(+s: S.Schema, +es: {s == Spec.Gt7FBB1934E8() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt7FBB1934E8(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law Gt7FBB1934E8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt7FBB1934E8() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_5_h.Gt7FBB1934E8_hash_tree_root(h, o))))])
def Gt7FBB1934E8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, Gt7FBB1934E8_ok(s, es), {==})

# Gt526892A4DC: for every packed word object representing a value of Spec.Gt526892A4DC(),
# the runtime root is a specification root of its elements.
def Gt526892A4DC_ok(+s: S.Schema, +es: {s == Spec.Gt526892A4DC() : S.Schema}) -> {PB.ok_vb(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt526892A4DC(), es) : {PB.ok_vb(_, 0n) == True{} : Bool}
  {==}
law Gt526892A4DC_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt526892A4DC() : S.Schema}
  for +rep: PB_L.rep_vb(o, s)
  RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_bool_8_h.Gt526892A4DC_hash_tree_root(h, o))))])
def Gt526892A4DC_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wfb(o, s, rep), {==})) :
    RR.roots(PB_L.vviewb(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.vb_rs(64n, {==}, o, s, 0n, rep, Gt526892A4DC_ok(s, es), {==})

# Gt1C2FA69562: for every packed byte object representing a value of Spec.Gt1C2FA69562(),
# the runtime root is a specification root of its elements.
def Gt1C2FA69562_ok(+s: S.Schema, +es: {s == Spec.Gt1C2FA69562() : S.Schema}) -> {PG.ok_pl16(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt1C2FA69562(), es) : {PG.ok_pl16(_) == True{} : Bool}
  {==}
law Gt1C2FA69562_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt1C2FA69562() : S.Schema}
  for +rep: PG_L.rep_pl16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint128_h.Gt1C2FA69562_hash_tree_root(h, o))))])
def Gt1C2FA69562_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 4n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 4n))), PG.pl_st(64n, h, o, 0, 4n, PG_L.rep_wf16(o, s, rep))) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl16_rs(64n, {==}, o, s, rep, Gt1C2FA69562_ok(s, es))

# Gt3EC8B89B94: for every packed word object representing a value of Spec.Gt3EC8B89B94(),
# the runtime root is a specification root of its elements.
def Gt3EC8B89B94_ok(+s: S.Schema, +es: {s == Spec.Gt3EC8B89B94() : S.Schema}) -> {PK.ok_v16(s, 3n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt3EC8B89B94(), es) : {PK.ok_v16(_, 3n) == True{} : Bool}
  {==}
law Gt3EC8B89B94_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt3EC8B89B94() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_16_h.Gt3EC8B89B94_hash_tree_root(h, o))))])
def Gt3EC8B89B94_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 3, 0), (h, (o, WO_L.wdig(64n, o, 3n))), WO.bv_st(64n, h, o, 3, 0, 3n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 3n, rep, Gt3EC8B89B94_ok(s, es), {==})

# Gt3FD98F54A5: for every packed word object representing a value of Spec.Gt3FD98F54A5(),
# the runtime root is a specification root of its elements.
def Gt3FD98F54A5_ok(+s: S.Schema, +es: {s == Spec.Gt3FD98F54A5() : S.Schema}) -> {PK.ok_v16(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt3FD98F54A5(), es) : {PK.ok_v16(_, 0n) == True{} : Bool}
  {==}
law Gt3FD98F54A5_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt3FD98F54A5() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_1_h.Gt3FD98F54A5_hash_tree_root(h, o))))])
def Gt3FD98F54A5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 0n, rep, Gt3FD98F54A5_ok(s, es), {==})

# Gt7D65FF3A10: for every packed word object representing a value of Spec.Gt7D65FF3A10(),
# the runtime root is a specification root of its elements.
def Gt7D65FF3A10_ok(+s: S.Schema, +es: {s == Spec.Gt7D65FF3A10() : S.Schema}) -> {PK.ok_v16(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt7D65FF3A10(), es) : {PK.ok_v16(_, 0n) == True{} : Bool}
  {==}
law Gt7D65FF3A10_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt7D65FF3A10() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_2_h.Gt7D65FF3A10_hash_tree_root(h, o))))])
def Gt7D65FF3A10_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 0n, rep, Gt7D65FF3A10_ok(s, es), {==})

# Gt6B1336E534: for every packed word object representing a value of Spec.Gt6B1336E534(),
# the runtime root is a specification root of its elements.
def Gt6B1336E534_ok(+s: S.Schema, +es: {s == Spec.Gt6B1336E534() : S.Schema}) -> {PK.ok_v16(s, 4n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt6B1336E534(), es) : {PK.ok_v16(_, 4n) == True{} : Bool}
  {==}
law Gt6B1336E534_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt6B1336E534() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_31_h.Gt6B1336E534_hash_tree_root(h, o))))])
def Gt6B1336E534_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 4, 0), (h, (o, WO_L.wdig(64n, o, 4n))), WO.bv_st(64n, h, o, 4, 0, 4n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 4n, rep, Gt6B1336E534_ok(s, es), {==})

# Gt7600AB7870: for every packed word object representing a value of Spec.Gt7600AB7870(),
# the runtime root is a specification root of its elements.
def Gt7600AB7870_ok(+s: S.Schema, +es: {s == Spec.Gt7600AB7870() : S.Schema}) -> {PK.ok_v16(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt7600AB7870(), es) : {PK.ok_v16(_, 1n) == True{} : Bool}
  {==}
law Gt7600AB7870_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt7600AB7870() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_3_h.Gt7600AB7870_hash_tree_root(h, o))))])
def Gt7600AB7870_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 1n, rep, Gt7600AB7870_ok(s, es), {==})

# GtB0CCEA154C: for every packed word object representing a value of Spec.GtB0CCEA154C(),
# the runtime root is a specification root of its elements.
def GtB0CCEA154C_ok(+s: S.Schema, +es: {s == Spec.GtB0CCEA154C() : S.Schema}) -> {PK.ok_v16(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtB0CCEA154C(), es) : {PK.ok_v16(_, 1n) == True{} : Bool}
  {==}
law GtB0CCEA154C_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtB0CCEA154C() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_4_h.GtB0CCEA154C_hash_tree_root(h, o))))])
def GtB0CCEA154C_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 1n, rep, GtB0CCEA154C_ok(s, es), {==})

# Gt7274F61A0F: for every packed word object representing a value of Spec.Gt7274F61A0F(),
# the runtime root is a specification root of its elements.
def Gt7274F61A0F_ok(+s: S.Schema, +es: {s == Spec.Gt7274F61A0F() : S.Schema}) -> {PK.ok_v16(s, 8n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt7274F61A0F(), es) : {PK.ok_v16(_, 8n) == True{} : Bool}
  {==}
law Gt7274F61A0F_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt7274F61A0F() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_512_h.Gt7274F61A0F_hash_tree_root(h, o))))])
def Gt7274F61A0F_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 8, 0), (h, (o, WO_L.wdig(64n, o, 8n))), WO.bv_st(64n, h, o, 8, 0, 8n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 8n, rep, Gt7274F61A0F_ok(s, es), {==})

# Gt9EA902108D: for every packed word object representing a value of Spec.Gt9EA902108D(),
# the runtime root is a specification root of its elements.
def Gt9EA902108D_ok(+s: S.Schema, +es: {s == Spec.Gt9EA902108D() : S.Schema}) -> {PK.ok_v16(s, 9n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt9EA902108D(), es) : {PK.ok_v16(_, 9n) == True{} : Bool}
  {==}
law Gt9EA902108D_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt9EA902108D() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_513_h.Gt9EA902108D_hash_tree_root(h, o))))])
def Gt9EA902108D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 9, 0), (h, (o, WO_L.wdig(64n, o, 9n))), WO.bv_st(64n, h, o, 9, 0, 9n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 9n, rep, Gt9EA902108D_ok(s, es), {==})

# GtBB42F83A45: for every packed word object representing a value of Spec.GtBB42F83A45(),
# the runtime root is a specification root of its elements.
def GtBB42F83A45_ok(+s: S.Schema, +es: {s == Spec.GtBB42F83A45() : S.Schema}) -> {PK.ok_v16(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtBB42F83A45(), es) : {PK.ok_v16(_, 2n) == True{} : Bool}
  {==}
law GtBB42F83A45_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtBB42F83A45() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_5_h.GtBB42F83A45_hash_tree_root(h, o))))])
def GtBB42F83A45_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 2n, rep, GtBB42F83A45_ok(s, es), {==})

# Gt3E2A057F33: for every packed word object representing a value of Spec.Gt3E2A057F33(),
# the runtime root is a specification root of its elements.
def Gt3E2A057F33_ok(+s: S.Schema, +es: {s == Spec.Gt3E2A057F33() : S.Schema}) -> {PK.ok_v16(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt3E2A057F33(), es) : {PK.ok_v16(_, 2n) == True{} : Bool}
  {==}
law Gt3E2A057F33_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt3E2A057F33() : S.Schema}
  for +rep: PK_L.rep_v16(o, s)
  RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint128_8_h.Gt3E2A057F33_hash_tree_root(h, o))))])
def Gt3E2A057F33_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf16(o, s, rep), {==})) :
    RR.roots(PK_L.vview16(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v16_rs(64n, {==}, o, s, 2n, rep, Gt3E2A057F33_ok(s, es), {==})

# GtDE4B86A990: for every packed byte object representing a value of Spec.GtDE4B86A990(),
# the runtime root is a specification root of its elements.
def GtDE4B86A990_ok(+s: S.Schema, +es: {s == Spec.GtDE4B86A990() : S.Schema}) -> {PG.ok_pl1(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtDE4B86A990(), es) : {PG.ok_pl1(_) == True{} : Bool}
  {==}
law GtDE4B86A990_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtDE4B86A990() : S.Schema}
  for +rep: PG_L.rep_pl1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint8_h.GtDE4B86A990_hash_tree_root(h, o))))])
def GtDE4B86A990_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 0n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 0n))), PG.pl_st(64n, h, o, 0, 0n, PG_L.rep_wf1(o, s, rep))) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl1_rs(64n, {==}, o, s, rep, GtDE4B86A990_ok(s, es))

# Gt28ED72E3EF: for every packed word object representing a value of Spec.Gt28ED72E3EF(),
# the runtime root is a specification root of its elements.
def Gt28ED72E3EF_ok(+s: S.Schema, +es: {s == Spec.Gt28ED72E3EF() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt28ED72E3EF(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law Gt28ED72E3EF_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt28ED72E3EF() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_16_h.Gt28ED72E3EF_hash_tree_root(h, o))))])
def Gt28ED72E3EF_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, Gt28ED72E3EF_ok(s, es), {==})

# GtB85E1BC748: for every packed word object representing a value of Spec.GtB85E1BC748(),
# the runtime root is a specification root of its elements.
def GtB85E1BC748_ok(+s: S.Schema, +es: {s == Spec.GtB85E1BC748() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtB85E1BC748(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law GtB85E1BC748_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtB85E1BC748() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_1_h.GtB85E1BC748_hash_tree_root(h, o))))])
def GtB85E1BC748_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, GtB85E1BC748_ok(s, es), {==})

# Gt3429157FEB: for every packed word object representing a value of Spec.Gt3429157FEB(),
# the runtime root is a specification root of its elements.
def Gt3429157FEB_ok(+s: S.Schema, +es: {s == Spec.Gt3429157FEB() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt3429157FEB(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law Gt3429157FEB_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt3429157FEB() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_2_h.Gt3429157FEB_hash_tree_root(h, o))))])
def Gt3429157FEB_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, Gt3429157FEB_ok(s, es), {==})

# GtC0FC7B166A: for every packed word object representing a value of Spec.GtC0FC7B166A(),
# the runtime root is a specification root of its elements.
def GtC0FC7B166A_ok(+s: S.Schema, +es: {s == Spec.GtC0FC7B166A() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtC0FC7B166A(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law GtC0FC7B166A_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtC0FC7B166A() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_31_h.GtC0FC7B166A_hash_tree_root(h, o))))])
def GtC0FC7B166A_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, GtC0FC7B166A_ok(s, es), {==})

# GtC19E8053EB: for every packed word object representing a value of Spec.GtC19E8053EB(),
# the runtime root is a specification root of its elements.
def GtC19E8053EB_ok(+s: S.Schema, +es: {s == Spec.GtC19E8053EB() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtC19E8053EB(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law GtC19E8053EB_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtC19E8053EB() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_3_h.GtC19E8053EB_hash_tree_root(h, o))))])
def GtC19E8053EB_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, GtC19E8053EB_ok(s, es), {==})

# Gt75C1995C88: for every packed word object representing a value of Spec.Gt75C1995C88(),
# the runtime root is a specification root of its elements.
def Gt75C1995C88_ok(+s: S.Schema, +es: {s == Spec.Gt75C1995C88() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt75C1995C88(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law Gt75C1995C88_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt75C1995C88() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_4_h.Gt75C1995C88_hash_tree_root(h, o))))])
def Gt75C1995C88_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, Gt75C1995C88_ok(s, es), {==})

# Gt28605B5D5C: for every packed word object representing a value of Spec.Gt28605B5D5C(),
# the runtime root is a specification root of its elements.
def Gt28605B5D5C_ok(+s: S.Schema, +es: {s == Spec.Gt28605B5D5C() : S.Schema}) -> {PB.ok_v1(s, 4n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt28605B5D5C(), es) : {PB.ok_v1(_, 4n) == True{} : Bool}
  {==}
law Gt28605B5D5C_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt28605B5D5C() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_512_h.Gt28605B5D5C_hash_tree_root(h, o))))])
def Gt28605B5D5C_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 4, 0), (h, (o, WO_L.wdig(64n, o, 4n))), WO.bv_st(64n, h, o, 4, 0, 4n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 4n, rep, Gt28605B5D5C_ok(s, es), {==})

# Gt2CD118DF5F: for every packed word object representing a value of Spec.Gt2CD118DF5F(),
# the runtime root is a specification root of its elements.
def Gt2CD118DF5F_ok(+s: S.Schema, +es: {s == Spec.Gt2CD118DF5F() : S.Schema}) -> {PB.ok_v1(s, 5n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt2CD118DF5F(), es) : {PB.ok_v1(_, 5n) == True{} : Bool}
  {==}
law Gt2CD118DF5F_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt2CD118DF5F() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_513_h.Gt2CD118DF5F_hash_tree_root(h, o))))])
def Gt2CD118DF5F_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 5, 0), (h, (o, WO_L.wdig(64n, o, 5n))), WO.bv_st(64n, h, o, 5, 0, 5n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 5n, rep, Gt2CD118DF5F_ok(s, es), {==})

# GtF3865AEE9A: for every packed word object representing a value of Spec.GtF3865AEE9A(),
# the runtime root is a specification root of its elements.
def GtF3865AEE9A_ok(+s: S.Schema, +es: {s == Spec.GtF3865AEE9A() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtF3865AEE9A(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law GtF3865AEE9A_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtF3865AEE9A() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_5_h.GtF3865AEE9A_hash_tree_root(h, o))))])
def GtF3865AEE9A_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, GtF3865AEE9A_ok(s, es), {==})

# GtA8100D747D: for every packed word object representing a value of Spec.GtA8100D747D(),
# the runtime root is a specification root of its elements.
def GtA8100D747D_ok(+s: S.Schema, +es: {s == Spec.GtA8100D747D() : S.Schema}) -> {PB.ok_v1(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtA8100D747D(), es) : {PB.ok_v1(_, 0n) == True{} : Bool}
  {==}
law GtA8100D747D_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtA8100D747D() : S.Schema}
  for +rep: PB_L.rep_v1(o, s)
  RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint8_8_h.GtA8100D747D_hash_tree_root(h, o))))])
def GtA8100D747D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf1(o, s, rep), {==})) :
    RR.roots(PB_L.vview1(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v1_rs(64n, {==}, o, s, 0n, rep, GtA8100D747D_ok(s, es), {==})

# GtF23A2FB97E: for every packed byte object representing a value of Spec.GtF23A2FB97E(),
# the runtime root is a specification root of its elements.
def GtF23A2FB97E_ok(+s: S.Schema, +es: {s == Spec.GtF23A2FB97E() : S.Schema}) -> {PG.ok_pl2(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtF23A2FB97E(), es) : {PG.ok_pl2(_) == True{} : Bool}
  {==}
law GtF23A2FB97E_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtF23A2FB97E() : S.Schema}
  for +rep: PG_L.rep_pl2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint16_h.GtF23A2FB97E_hash_tree_root(h, o))))])
def GtF23A2FB97E_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 1n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 1n))), PG.pl_st(64n, h, o, 0, 1n, PG_L.rep_wf2(o, s, rep))) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl2_rs(64n, {==}, o, s, rep, GtF23A2FB97E_ok(s, es))

# GtAEB382AD1F: for every packed word object representing a value of Spec.GtAEB382AD1F(),
# the runtime root is a specification root of its elements.
def GtAEB382AD1F_ok(+s: S.Schema, +es: {s == Spec.GtAEB382AD1F() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtAEB382AD1F(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law GtAEB382AD1F_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtAEB382AD1F() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_16_h.GtAEB382AD1F_hash_tree_root(h, o))))])
def GtAEB382AD1F_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, GtAEB382AD1F_ok(s, es), {==})

# GtE6006F6F55: for every packed word object representing a value of Spec.GtE6006F6F55(),
# the runtime root is a specification root of its elements.
def GtE6006F6F55_ok(+s: S.Schema, +es: {s == Spec.GtE6006F6F55() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtE6006F6F55(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law GtE6006F6F55_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtE6006F6F55() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_1_h.GtE6006F6F55_hash_tree_root(h, o))))])
def GtE6006F6F55_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, GtE6006F6F55_ok(s, es), {==})

# Gt04170D6AA7: for every packed word object representing a value of Spec.Gt04170D6AA7(),
# the runtime root is a specification root of its elements.
def Gt04170D6AA7_ok(+s: S.Schema, +es: {s == Spec.Gt04170D6AA7() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt04170D6AA7(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law Gt04170D6AA7_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt04170D6AA7() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_2_h.Gt04170D6AA7_hash_tree_root(h, o))))])
def Gt04170D6AA7_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, Gt04170D6AA7_ok(s, es), {==})

# Gt9333E6513D: for every packed word object representing a value of Spec.Gt9333E6513D(),
# the runtime root is a specification root of its elements.
def Gt9333E6513D_ok(+s: S.Schema, +es: {s == Spec.Gt9333E6513D() : S.Schema}) -> {PB.ok_v2(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt9333E6513D(), es) : {PB.ok_v2(_, 1n) == True{} : Bool}
  {==}
law Gt9333E6513D_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt9333E6513D() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_31_h.Gt9333E6513D_hash_tree_root(h, o))))])
def Gt9333E6513D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 1n, rep, Gt9333E6513D_ok(s, es), {==})

# Gt19F04F79B8: for every packed word object representing a value of Spec.Gt19F04F79B8(),
# the runtime root is a specification root of its elements.
def Gt19F04F79B8_ok(+s: S.Schema, +es: {s == Spec.Gt19F04F79B8() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt19F04F79B8(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law Gt19F04F79B8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt19F04F79B8() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_3_h.Gt19F04F79B8_hash_tree_root(h, o))))])
def Gt19F04F79B8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, Gt19F04F79B8_ok(s, es), {==})

# Gt6463DC73A8: for every packed word object representing a value of Spec.Gt6463DC73A8(),
# the runtime root is a specification root of its elements.
def Gt6463DC73A8_ok(+s: S.Schema, +es: {s == Spec.Gt6463DC73A8() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt6463DC73A8(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law Gt6463DC73A8_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt6463DC73A8() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_4_h.Gt6463DC73A8_hash_tree_root(h, o))))])
def Gt6463DC73A8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, Gt6463DC73A8_ok(s, es), {==})

# Gt2FF8722A75: for every packed word object representing a value of Spec.Gt2FF8722A75(),
# the runtime root is a specification root of its elements.
def Gt2FF8722A75_ok(+s: S.Schema, +es: {s == Spec.Gt2FF8722A75() : S.Schema}) -> {PB.ok_v2(s, 5n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt2FF8722A75(), es) : {PB.ok_v2(_, 5n) == True{} : Bool}
  {==}
law Gt2FF8722A75_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt2FF8722A75() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_512_h.Gt2FF8722A75_hash_tree_root(h, o))))])
def Gt2FF8722A75_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 5, 0), (h, (o, WO_L.wdig(64n, o, 5n))), WO.bv_st(64n, h, o, 5, 0, 5n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 5n, rep, Gt2FF8722A75_ok(s, es), {==})

# Gt5BE68AF2C7: for every packed word object representing a value of Spec.Gt5BE68AF2C7(),
# the runtime root is a specification root of its elements.
def Gt5BE68AF2C7_ok(+s: S.Schema, +es: {s == Spec.Gt5BE68AF2C7() : S.Schema}) -> {PB.ok_v2(s, 6n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt5BE68AF2C7(), es) : {PB.ok_v2(_, 6n) == True{} : Bool}
  {==}
law Gt5BE68AF2C7_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt5BE68AF2C7() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_513_h.Gt5BE68AF2C7_hash_tree_root(h, o))))])
def Gt5BE68AF2C7_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 6, 0), (h, (o, WO_L.wdig(64n, o, 6n))), WO.bv_st(64n, h, o, 6, 0, 6n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 6n, rep, Gt5BE68AF2C7_ok(s, es), {==})

# Gt89824BEACE: for every packed word object representing a value of Spec.Gt89824BEACE(),
# the runtime root is a specification root of its elements.
def Gt89824BEACE_ok(+s: S.Schema, +es: {s == Spec.Gt89824BEACE() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt89824BEACE(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law Gt89824BEACE_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt89824BEACE() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_5_h.Gt89824BEACE_hash_tree_root(h, o))))])
def Gt89824BEACE_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, Gt89824BEACE_ok(s, es), {==})

# Gt39CAD03032: for every packed word object representing a value of Spec.Gt39CAD03032(),
# the runtime root is a specification root of its elements.
def Gt39CAD03032_ok(+s: S.Schema, +es: {s == Spec.Gt39CAD03032() : S.Schema}) -> {PB.ok_v2(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt39CAD03032(), es) : {PB.ok_v2(_, 0n) == True{} : Bool}
  {==}
law Gt39CAD03032_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt39CAD03032() : S.Schema}
  for +rep: PB_L.rep_v2(o, s)
  RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint16_8_h.Gt39CAD03032_hash_tree_root(h, o))))])
def Gt39CAD03032_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PB.rep_wf2(o, s, rep), {==})) :
    RR.roots(PB_L.vview2(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PB.v2_rs(64n, {==}, o, s, 0n, rep, Gt39CAD03032_ok(s, es), {==})

# GtA8457965E2: for every packed byte object representing a value of Spec.GtA8457965E2(),
# the runtime root is a specification root of its elements.
def GtA8457965E2_ok(+s: S.Schema, +es: {s == Spec.GtA8457965E2() : S.Schema}) -> {PG.ok_pl32(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtA8457965E2(), es) : {PG.ok_pl32(_) == True{} : Bool}
  {==}
law GtA8457965E2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtA8457965E2() : S.Schema}
  for +rep: PG_L.rep_pl32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint256_h.GtA8457965E2_hash_tree_root(h, o))))])
def GtA8457965E2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 5n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 5n))), PG.pl_st(64n, h, o, 0, 5n, PG_L.rep_wf32(o, s, rep))) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl32_rs(64n, {==}, o, s, rep, GtA8457965E2_ok(s, es))

# Gt3E6E18CD57: for every packed word object representing a value of Spec.Gt3E6E18CD57(),
# the runtime root is a specification root of its elements.
def Gt3E6E18CD57_ok(+s: S.Schema, +es: {s == Spec.Gt3E6E18CD57() : S.Schema}) -> {PK.ok_v32(s, 4n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt3E6E18CD57(), es) : {PK.ok_v32(_, 4n) == True{} : Bool}
  {==}
law Gt3E6E18CD57_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt3E6E18CD57() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_16_h.Gt3E6E18CD57_hash_tree_root(h, o))))])
def Gt3E6E18CD57_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 4, 0), (h, (o, WO_L.wdig(64n, o, 4n))), WO.bv_st(64n, h, o, 4, 0, 4n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 4n, rep, Gt3E6E18CD57_ok(s, es), {==})

# GtBBFD66E011: for every packed word object representing a value of Spec.GtBBFD66E011(),
# the runtime root is a specification root of its elements.
def GtBBFD66E011_ok(+s: S.Schema, +es: {s == Spec.GtBBFD66E011() : S.Schema}) -> {PK.ok_v32(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtBBFD66E011(), es) : {PK.ok_v32(_, 0n) == True{} : Bool}
  {==}
law GtBBFD66E011_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtBBFD66E011() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_1_h.GtBBFD66E011_hash_tree_root(h, o))))])
def GtBBFD66E011_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 0n, rep, GtBBFD66E011_ok(s, es), {==})

# GtB91D4D285D: for every packed word object representing a value of Spec.GtB91D4D285D(),
# the runtime root is a specification root of its elements.
def GtB91D4D285D_ok(+s: S.Schema, +es: {s == Spec.GtB91D4D285D() : S.Schema}) -> {PK.ok_v32(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtB91D4D285D(), es) : {PK.ok_v32(_, 1n) == True{} : Bool}
  {==}
law GtB91D4D285D_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtB91D4D285D() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_2_h.GtB91D4D285D_hash_tree_root(h, o))))])
def GtB91D4D285D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 1n, rep, GtB91D4D285D_ok(s, es), {==})

# Gt6E9B243B7C: for every packed word object representing a value of Spec.Gt6E9B243B7C(),
# the runtime root is a specification root of its elements.
def Gt6E9B243B7C_ok(+s: S.Schema, +es: {s == Spec.Gt6E9B243B7C() : S.Schema}) -> {PK.ok_v32(s, 5n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt6E9B243B7C(), es) : {PK.ok_v32(_, 5n) == True{} : Bool}
  {==}
law Gt6E9B243B7C_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt6E9B243B7C() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_31_h.Gt6E9B243B7C_hash_tree_root(h, o))))])
def Gt6E9B243B7C_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 5, 0), (h, (o, WO_L.wdig(64n, o, 5n))), WO.bv_st(64n, h, o, 5, 0, 5n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 5n, rep, Gt6E9B243B7C_ok(s, es), {==})

# Gt2E7060B297: for every packed word object representing a value of Spec.Gt2E7060B297(),
# the runtime root is a specification root of its elements.
def Gt2E7060B297_ok(+s: S.Schema, +es: {s == Spec.Gt2E7060B297() : S.Schema}) -> {PK.ok_v32(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt2E7060B297(), es) : {PK.ok_v32(_, 2n) == True{} : Bool}
  {==}
law Gt2E7060B297_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt2E7060B297() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_3_h.Gt2E7060B297_hash_tree_root(h, o))))])
def Gt2E7060B297_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 2n, rep, Gt2E7060B297_ok(s, es), {==})

# Gt74B2AF1CB3: for every packed word object representing a value of Spec.Gt74B2AF1CB3(),
# the runtime root is a specification root of its elements.
def Gt74B2AF1CB3_ok(+s: S.Schema, +es: {s == Spec.Gt74B2AF1CB3() : S.Schema}) -> {PK.ok_v32(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt74B2AF1CB3(), es) : {PK.ok_v32(_, 2n) == True{} : Bool}
  {==}
law Gt74B2AF1CB3_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt74B2AF1CB3() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_4_h.Gt74B2AF1CB3_hash_tree_root(h, o))))])
def Gt74B2AF1CB3_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 2n, rep, Gt74B2AF1CB3_ok(s, es), {==})

# Gt274A0B8DC2: for every packed word object representing a value of Spec.Gt274A0B8DC2(),
# the runtime root is a specification root of its elements.
def Gt274A0B8DC2_ok(+s: S.Schema, +es: {s == Spec.Gt274A0B8DC2() : S.Schema}) -> {PK.ok_v32(s, 9n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt274A0B8DC2(), es) : {PK.ok_v32(_, 9n) == True{} : Bool}
  {==}
law Gt274A0B8DC2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt274A0B8DC2() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_512_h.Gt274A0B8DC2_hash_tree_root(h, o))))])
def Gt274A0B8DC2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 9, 0), (h, (o, WO_L.wdig(64n, o, 9n))), WO.bv_st(64n, h, o, 9, 0, 9n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 9n, rep, Gt274A0B8DC2_ok(s, es), {==})

# Gt0A3B6B4128: for every packed word object representing a value of Spec.Gt0A3B6B4128(),
# the runtime root is a specification root of its elements.
def Gt0A3B6B4128_ok(+s: S.Schema, +es: {s == Spec.Gt0A3B6B4128() : S.Schema}) -> {PK.ok_v32(s, 10n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt0A3B6B4128(), es) : {PK.ok_v32(_, 10n) == True{} : Bool}
  {==}
law Gt0A3B6B4128_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt0A3B6B4128() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_513_h.Gt0A3B6B4128_hash_tree_root(h, o))))])
def Gt0A3B6B4128_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 10, 0), (h, (o, WO_L.wdig(64n, o, 10n))), WO.bv_st(64n, h, o, 10, 0, 10n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 10n, rep, Gt0A3B6B4128_ok(s, es), {==})

# Gt0B1B711C4D: for every packed word object representing a value of Spec.Gt0B1B711C4D(),
# the runtime root is a specification root of its elements.
def Gt0B1B711C4D_ok(+s: S.Schema, +es: {s == Spec.Gt0B1B711C4D() : S.Schema}) -> {PK.ok_v32(s, 3n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt0B1B711C4D(), es) : {PK.ok_v32(_, 3n) == True{} : Bool}
  {==}
law Gt0B1B711C4D_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt0B1B711C4D() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_5_h.Gt0B1B711C4D_hash_tree_root(h, o))))])
def Gt0B1B711C4D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 3, 0), (h, (o, WO_L.wdig(64n, o, 3n))), WO.bv_st(64n, h, o, 3, 0, 3n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 3n, rep, Gt0B1B711C4D_ok(s, es), {==})

# GtFAE59DA275: for every packed word object representing a value of Spec.GtFAE59DA275(),
# the runtime root is a specification root of its elements.
def GtFAE59DA275_ok(+s: S.Schema, +es: {s == Spec.GtFAE59DA275() : S.Schema}) -> {PK.ok_v32(s, 3n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtFAE59DA275(), es) : {PK.ok_v32(_, 3n) == True{} : Bool}
  {==}
law GtFAE59DA275_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtFAE59DA275() : S.Schema}
  for +rep: PK_L.rep_v32(o, s)
  RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint256_8_h.GtFAE59DA275_hash_tree_root(h, o))))])
def GtFAE59DA275_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 3, 0), (h, (o, WO_L.wdig(64n, o, 3n))), WO.bv_st(64n, h, o, 3, 0, 3n, PK.rep_wf32(o, s, rep), {==})) :
    RR.roots(PK_L.vview32(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v32_rs(64n, {==}, o, s, 3n, rep, GtFAE59DA275_ok(s, es), {==})

# Gt3A9420DD8E: for every packed byte object representing a value of Spec.Gt3A9420DD8E(),
# the runtime root is a specification root of its elements.
def Gt3A9420DD8E_ok(+s: S.Schema, +es: {s == Spec.Gt3A9420DD8E() : S.Schema}) -> {PG.ok_pl4(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt3A9420DD8E(), es) : {PG.ok_pl4(_) == True{} : Bool}
  {==}
law Gt3A9420DD8E_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt3A9420DD8E() : S.Schema}
  for +rep: PG_L.rep_pl4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint32_h.Gt3A9420DD8E_hash_tree_root(h, o))))])
def Gt3A9420DD8E_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 2n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 2n))), PG.pl_st(64n, h, o, 0, 2n, PG_L.rep_wf4(o, s, rep))) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl4_rs(64n, {==}, o, s, rep, Gt3A9420DD8E_ok(s, es))

# Gt3CC580499F: for every packed word object representing a value of Spec.Gt3CC580499F(),
# the runtime root is a specification root of its elements.
def Gt3CC580499F_ok(+s: S.Schema, +es: {s == Spec.Gt3CC580499F() : S.Schema}) -> {PK.ok_v4(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt3CC580499F(), es) : {PK.ok_v4(_, 1n) == True{} : Bool}
  {==}
law Gt3CC580499F_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt3CC580499F() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_16_h.Gt3CC580499F_hash_tree_root(h, o))))])
def Gt3CC580499F_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 1n, rep, Gt3CC580499F_ok(s, es), {==})

# Gt669C528764: for every packed word object representing a value of Spec.Gt669C528764(),
# the runtime root is a specification root of its elements.
def Gt669C528764_ok(+s: S.Schema, +es: {s == Spec.Gt669C528764() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt669C528764(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law Gt669C528764_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt669C528764() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_1_h.Gt669C528764_hash_tree_root(h, o))))])
def Gt669C528764_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, Gt669C528764_ok(s, es), {==})

# GtF45E42B273: for every packed word object representing a value of Spec.GtF45E42B273(),
# the runtime root is a specification root of its elements.
def GtF45E42B273_ok(+s: S.Schema, +es: {s == Spec.GtF45E42B273() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtF45E42B273(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law GtF45E42B273_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtF45E42B273() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_2_h.GtF45E42B273_hash_tree_root(h, o))))])
def GtF45E42B273_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, GtF45E42B273_ok(s, es), {==})

# GtE528AAE3C6: for every packed word object representing a value of Spec.GtE528AAE3C6(),
# the runtime root is a specification root of its elements.
def GtE528AAE3C6_ok(+s: S.Schema, +es: {s == Spec.GtE528AAE3C6() : S.Schema}) -> {PK.ok_v4(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtE528AAE3C6(), es) : {PK.ok_v4(_, 2n) == True{} : Bool}
  {==}
law GtE528AAE3C6_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtE528AAE3C6() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_31_h.GtE528AAE3C6_hash_tree_root(h, o))))])
def GtE528AAE3C6_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 2n, rep, GtE528AAE3C6_ok(s, es), {==})

# GtD1AEF07F7D: for every packed word object representing a value of Spec.GtD1AEF07F7D(),
# the runtime root is a specification root of its elements.
def GtD1AEF07F7D_ok(+s: S.Schema, +es: {s == Spec.GtD1AEF07F7D() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtD1AEF07F7D(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law GtD1AEF07F7D_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtD1AEF07F7D() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_3_h.GtD1AEF07F7D_hash_tree_root(h, o))))])
def GtD1AEF07F7D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, GtD1AEF07F7D_ok(s, es), {==})

# Gt240C147AA2: for every packed word object representing a value of Spec.Gt240C147AA2(),
# the runtime root is a specification root of its elements.
def Gt240C147AA2_ok(+s: S.Schema, +es: {s == Spec.Gt240C147AA2() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt240C147AA2(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law Gt240C147AA2_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt240C147AA2() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_4_h.Gt240C147AA2_hash_tree_root(h, o))))])
def Gt240C147AA2_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, Gt240C147AA2_ok(s, es), {==})

# Gt13AFE546ED: for every packed word object representing a value of Spec.Gt13AFE546ED(),
# the runtime root is a specification root of its elements.
def Gt13AFE546ED_ok(+s: S.Schema, +es: {s == Spec.Gt13AFE546ED() : S.Schema}) -> {PK.ok_v4(s, 6n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt13AFE546ED(), es) : {PK.ok_v4(_, 6n) == True{} : Bool}
  {==}
law Gt13AFE546ED_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt13AFE546ED() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_512_h.Gt13AFE546ED_hash_tree_root(h, o))))])
def Gt13AFE546ED_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 6, 0), (h, (o, WO_L.wdig(64n, o, 6n))), WO.bv_st(64n, h, o, 6, 0, 6n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 6n, rep, Gt13AFE546ED_ok(s, es), {==})

# Gt53D2408A5F: for every packed word object representing a value of Spec.Gt53D2408A5F(),
# the runtime root is a specification root of its elements.
def Gt53D2408A5F_ok(+s: S.Schema, +es: {s == Spec.Gt53D2408A5F() : S.Schema}) -> {PK.ok_v4(s, 7n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt53D2408A5F(), es) : {PK.ok_v4(_, 7n) == True{} : Bool}
  {==}
law Gt53D2408A5F_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt53D2408A5F() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_513_h.Gt53D2408A5F_hash_tree_root(h, o))))])
def Gt53D2408A5F_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 7, 0), (h, (o, WO_L.wdig(64n, o, 7n))), WO.bv_st(64n, h, o, 7, 0, 7n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 7n, rep, Gt53D2408A5F_ok(s, es), {==})

# Gt1719057EB7: for every packed word object representing a value of Spec.Gt1719057EB7(),
# the runtime root is a specification root of its elements.
def Gt1719057EB7_ok(+s: S.Schema, +es: {s == Spec.Gt1719057EB7() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt1719057EB7(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law Gt1719057EB7_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt1719057EB7() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_5_h.Gt1719057EB7_hash_tree_root(h, o))))])
def Gt1719057EB7_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, Gt1719057EB7_ok(s, es), {==})

# GtCCF6FFA0A0: for every packed word object representing a value of Spec.GtCCF6FFA0A0(),
# the runtime root is a specification root of its elements.
def GtCCF6FFA0A0_ok(+s: S.Schema, +es: {s == Spec.GtCCF6FFA0A0() : S.Schema}) -> {PK.ok_v4(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtCCF6FFA0A0(), es) : {PK.ok_v4(_, 0n) == True{} : Bool}
  {==}
law GtCCF6FFA0A0_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtCCF6FFA0A0() : S.Schema}
  for +rep: PK_L.rep_v4(o, s)
  RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint32_8_h.GtCCF6FFA0A0_hash_tree_root(h, o))))])
def GtCCF6FFA0A0_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf4(o, s, rep), {==})) :
    RR.roots(PK_L.vview4(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v4_rs(64n, {==}, o, s, 0n, rep, GtCCF6FFA0A0_ok(s, es), {==})

# GtE83F21B20A: for every packed byte object representing a value of Spec.GtE83F21B20A(),
# the runtime root is a specification root of its elements.
def GtE83F21B20A_ok(+s: S.Schema, +es: {s == Spec.GtE83F21B20A() : S.Schema}) -> {PG.ok_pl8(s) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtE83F21B20A(), es) : {PG.ok_pl8(_) == True{} : Bool}
  {==}
law GtE83F21B20A_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtE83F21B20A() : S.Schema}
  for +rep: PG_L.rep_pl8(o, s)
  RR.roots(UL_L.uview(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, proglist_uint64_h.GtE83F21B20A_hash_tree_root(h, o))))])
def GtE83F21B20A_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.mix_count(64n, 3n, O.words_root_prog(64n, h, o, 0)), (h, (o, PG.pdig(64n, o, 3n))), PG.pl_st(64n, h, o, 0, 3n, PG_L.rep_wf8(o, s, rep))) :
    RR.roots(UL_L.uview(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PG.pl8_rs(64n, {==}, o, s, rep, GtE83F21B20A_ok(s, es))

# Gt0B4EF17D71: for every packed word object representing a value of Spec.Gt0B4EF17D71(),
# the runtime root is a specification root of its elements.
def Gt0B4EF17D71_ok(+s: S.Schema, +es: {s == Spec.Gt0B4EF17D71() : S.Schema}) -> {PK.ok_v8(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt0B4EF17D71(), es) : {PK.ok_v8(_, 2n) == True{} : Bool}
  {==}
law Gt0B4EF17D71_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt0B4EF17D71() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_16_h.Gt0B4EF17D71_hash_tree_root(h, o))))])
def Gt0B4EF17D71_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 2, 0), (h, (o, WO_L.wdig(64n, o, 2n))), WO.bv_st(64n, h, o, 2, 0, 2n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 2n, rep, Gt0B4EF17D71_ok(s, es), {==})

# GtADC8DCD962: for every packed word object representing a value of Spec.GtADC8DCD962(),
# the runtime root is a specification root of its elements.
def GtADC8DCD962_ok(+s: S.Schema, +es: {s == Spec.GtADC8DCD962() : S.Schema}) -> {PK.ok_v8(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtADC8DCD962(), es) : {PK.ok_v8(_, 0n) == True{} : Bool}
  {==}
law GtADC8DCD962_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtADC8DCD962() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_1_h.GtADC8DCD962_hash_tree_root(h, o))))])
def GtADC8DCD962_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 0n, rep, GtADC8DCD962_ok(s, es), {==})

# GtC923FCB2DA: for every packed word object representing a value of Spec.GtC923FCB2DA(),
# the runtime root is a specification root of its elements.
def GtC923FCB2DA_ok(+s: S.Schema, +es: {s == Spec.GtC923FCB2DA() : S.Schema}) -> {PK.ok_v8(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtC923FCB2DA(), es) : {PK.ok_v8(_, 0n) == True{} : Bool}
  {==}
law GtC923FCB2DA_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtC923FCB2DA() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_2_h.GtC923FCB2DA_hash_tree_root(h, o))))])
def GtC923FCB2DA_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 0n, rep, GtC923FCB2DA_ok(s, es), {==})

# Gt7D1CD7363A: for every packed word object representing a value of Spec.Gt7D1CD7363A(),
# the runtime root is a specification root of its elements.
def Gt7D1CD7363A_ok(+s: S.Schema, +es: {s == Spec.Gt7D1CD7363A() : S.Schema}) -> {PK.ok_v8(s, 3n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt7D1CD7363A(), es) : {PK.ok_v8(_, 3n) == True{} : Bool}
  {==}
law Gt7D1CD7363A_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt7D1CD7363A() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_31_h.Gt7D1CD7363A_hash_tree_root(h, o))))])
def Gt7D1CD7363A_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 3, 0), (h, (o, WO_L.wdig(64n, o, 3n))), WO.bv_st(64n, h, o, 3, 0, 3n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 3n, rep, Gt7D1CD7363A_ok(s, es), {==})

# Gt8E507C4540: for every packed word object representing a value of Spec.Gt8E507C4540(),
# the runtime root is a specification root of its elements.
def Gt8E507C4540_ok(+s: S.Schema, +es: {s == Spec.Gt8E507C4540() : S.Schema}) -> {PK.ok_v8(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt8E507C4540(), es) : {PK.ok_v8(_, 0n) == True{} : Bool}
  {==}
law Gt8E507C4540_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt8E507C4540() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_3_h.Gt8E507C4540_hash_tree_root(h, o))))])
def Gt8E507C4540_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 0n, rep, Gt8E507C4540_ok(s, es), {==})

# Gt46F5D7703F: for every packed word object representing a value of Spec.Gt46F5D7703F(),
# the runtime root is a specification root of its elements.
def Gt46F5D7703F_ok(+s: S.Schema, +es: {s == Spec.Gt46F5D7703F() : S.Schema}) -> {PK.ok_v8(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt46F5D7703F(), es) : {PK.ok_v8(_, 0n) == True{} : Bool}
  {==}
law Gt46F5D7703F_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt46F5D7703F() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_4_h.Gt46F5D7703F_hash_tree_root(h, o))))])
def Gt46F5D7703F_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 0, 0), (h, (o, WO_L.wdig(64n, o, 0n))), WO.bv_st(64n, h, o, 0, 0, 0n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 0n, rep, Gt46F5D7703F_ok(s, es), {==})

# Gt843A1262ED: for every packed word object representing a value of Spec.Gt843A1262ED(),
# the runtime root is a specification root of its elements.
def Gt843A1262ED_ok(+s: S.Schema, +es: {s == Spec.Gt843A1262ED() : S.Schema}) -> {PK.ok_v8(s, 7n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt843A1262ED(), es) : {PK.ok_v8(_, 7n) == True{} : Bool}
  {==}
law Gt843A1262ED_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt843A1262ED() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_512_h.Gt843A1262ED_hash_tree_root(h, o))))])
def Gt843A1262ED_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 7, 0), (h, (o, WO_L.wdig(64n, o, 7n))), WO.bv_st(64n, h, o, 7, 0, 7n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 7n, rep, Gt843A1262ED_ok(s, es), {==})

# Gt10D6F42D74: for every packed word object representing a value of Spec.Gt10D6F42D74(),
# the runtime root is a specification root of its elements.
def Gt10D6F42D74_ok(+s: S.Schema, +es: {s == Spec.Gt10D6F42D74() : S.Schema}) -> {PK.ok_v8(s, 8n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt10D6F42D74(), es) : {PK.ok_v8(_, 8n) == True{} : Bool}
  {==}
law Gt10D6F42D74_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt10D6F42D74() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_513_h.Gt10D6F42D74_hash_tree_root(h, o))))])
def Gt10D6F42D74_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 8, 0), (h, (o, WO_L.wdig(64n, o, 8n))), WO.bv_st(64n, h, o, 8, 0, 8n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 8n, rep, Gt10D6F42D74_ok(s, es), {==})

# Gt8FB0CF9679: for every packed word object representing a value of Spec.Gt8FB0CF9679(),
# the runtime root is a specification root of its elements.
def Gt8FB0CF9679_ok(+s: S.Schema, +es: {s == Spec.Gt8FB0CF9679() : S.Schema}) -> {PK.ok_v8(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt8FB0CF9679(), es) : {PK.ok_v8(_, 1n) == True{} : Bool}
  {==}
law Gt8FB0CF9679_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.Gt8FB0CF9679() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_5_h.Gt8FB0CF9679_hash_tree_root(h, o))))])
def Gt8FB0CF9679_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 1n, rep, Gt8FB0CF9679_ok(s, es), {==})

# GtE470919895: for every packed word object representing a value of Spec.GtE470919895(),
# the runtime root is a specification root of its elements.
def GtE470919895_ok(+s: S.Schema, +es: {s == Spec.GtE470919895() : S.Schema}) -> {PK.ok_v8(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtE470919895(), es) : {PK.ok_v8(_, 1n) == True{} : Bool}
  {==}
law GtE470919895_root_correct:
  for -h: B.Buf
  for -o: O.Words
  for +s: S.Schema
  for +es: {s == Spec.GtE470919895() : S.Schema}
  for +rep: PK_L.rep_v8(o, s)
  RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, vec_uint64_8_h.GtE470919895_hash_tree_root(h, o))))])
def GtE470919895_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Words & D.Digest), O.words_root(64n, h, o, 1, 0), (h, (o, WO_L.wdig(64n, o, 1n))), WO.bv_st(64n, h, o, 1, 0, 1n, PK.rep_wf8(o, s, rep), {==})) :
    RR.roots(PK_L.vview8(o), s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, _)))])
  PK.v8_rs(64n, {==}, o, s, 1n, rep, GtE470919895_ok(s, es), {==})

# Gc465214E502: for every object representing a value of Spec.Gc465214E502(), the runtime
# root is a specification root of that value.
def Gc465214E502_ok(+s: S.Schema, +es: {s == Spec.Gc465214E502() : S.Schema}, +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}) -> {ok_Gc465214E502(s, dv) == True{} : Bool}:
  OS.ok_at(y => d => ok_Gc465214E502(y, d), s, Spec.Gc465214E502(), dv, es, edv, {==})
def Gc465214E502_eqs(+s: S.Schema, +es: {s == Spec.Gc465214E502() : S.Schema}) -> eqs_Gc465214E502(s): (OS.eq_at(y => SH.Chain_head(SH.Container_fields(y)), s, Spec.Gc465214E502(), S.Unsigned{P.U16{}}, es, {==}), OS.eq_at(y => SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))), s, Spec.Gc465214E502(), S.Unsigned{P.U8{}}, es, {==}))
def Gc465214E502_rc(-h: B.Buf, -o: VarTestStruct_d.Gc465214E502, +s: S.Schema, +es: {s == Spec.Gc465214E502() : S.Schema}, +rep: LV.rep_Gc465214E502(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV})
    -> RR.roots(LV.v_Gc465214E502(o), s, [D.bytes(Pair.snd(VarTestStruct_d.Gc465214E502, D.Digest, Pair.snd(B.Buf, VarTestStruct_d.Gc465214E502 & D.Digest, VarTestStruct_h.Gc465214E502_hash_tree_root(h, o))))]):
  %Equal.sym(B.Buf & (VarTestStruct_d.Gc465214E502 & D.Digest), VarTestStruct_h.Gc465214E502_root(64n, h, o, 0), (h, (o, d_Gc465214E502(64n, o))), st_Gc465214E502(64n, h, o, 0, s, rep)) :
    RR.roots(LV.v_Gc465214E502(o), s, [D.bytes(Pair.snd(VarTestStruct_d.Gc465214E502, D.Digest, Pair.snd(B.Buf, VarTestStruct_d.Gc465214E502 & D.Digest, _)))])
  rs_Gc465214E502(64n, {==}, h, o, s, rep, dv, edv, Gc465214E502_ok(s, es, dv, edv), Gc465214E502_eqs(s, es))
law Gc465214E502_root_correct:
  for -h: B.Buf
  for -o: VarTestStruct_d.Gc465214E502
  for +s: S.Schema
  for +es: {s == Spec.Gc465214E502() : S.Schema}
  for +rep: LV.rep_Gc465214E502(o, s)
  RR.roots(LV.v_Gc465214E502(o), s, [D.bytes(Pair.snd(VarTestStruct_d.Gc465214E502, D.Digest, Pair.snd(B.Buf, VarTestStruct_d.Gc465214E502 & D.Digest, VarTestStruct_h.Gc465214E502_hash_tree_root(h, o))))])
def Gc465214E502_root_correct(h, o, s, es, rep): Gc465214E502_rc(h, o, s, es, rep, OS.DV0(), {==})

# Gc56D855869F: for every object representing a value of Spec.Gc56D855869F(), the runtime
# root is a specification root of that value.
def Gc56D855869F_ok(+s: S.Schema, +es: {s == Spec.Gc56D855869F() : S.Schema}, +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV}) -> {ok_Gc56D855869F(s, dv) == True{} : Bool}:
  OS.ok_at(y => d => ok_Gc56D855869F(y, d), s, Spec.Gc56D855869F(), dv, es, edv, {==})
def Gc56D855869F_eqs(+s: S.Schema, +es: {s == Spec.Gc56D855869F() : S.Schema}) -> eqs_Gc56D855869F(s): (OS.eq_at(y => SH.Chain_head(SH.Container_fields(y)), s, Spec.Gc56D855869F(), S.Unsigned{P.U16{}}, es, {==}), (OS.eq_at(y => SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))), s, Spec.Gc56D855869F(), S.Unsigned{P.U8{}}, es, {==}), ((OS.eq_at(y => SH.Chain_head(SH.Container_fields(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))))))), s, Spec.Gc56D855869F(), S.Unsigned{P.U16{}}, es, {==}), OS.eq_at(y => SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))))))))), s, Spec.Gc56D855869F(), S.Unsigned{P.U8{}}, es, {==})), (OS.eq_at(y => SH.Vector_element(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y)))))))), s, Spec.Gc56D855869F(), S.Container{["f_A", "f_B", "f_C"], S.Chain{S.Unsigned{P.U8{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U32Width{}}, S.End{}}}}}, es, {==}), (OS.eq_at(y => SH.Chain_head(SH.Container_fields(SH.Vector_element(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y))))))))))), s, Spec.Gc56D855869F(), S.Unsigned{P.U16{}}, es, {==}), OS.eq_at(y => SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(SH.Vector_element(SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(y))))))))))))), s, Spec.Gc56D855869F(), S.Unsigned{P.U8{}}, es, {==}))))))
def Gc56D855869F_rc(-h: B.Buf, -o: ComplexTestStruct_d.Gc56D855869F, +s: S.Schema, +es: {s == Spec.Gc56D855869F() : S.Schema}, +rep: LV.rep_Gc56D855869F(o, s), +dv: OS.DV, +edv: {dv == OS.DV0() : OS.DV})
    -> RR.roots(LV.v_Gc56D855869F(o), s, [D.bytes(Pair.snd(ComplexTestStruct_d.Gc56D855869F, D.Digest, Pair.snd(B.Buf, ComplexTestStruct_d.Gc56D855869F & D.Digest, ComplexTestStruct_h.Gc56D855869F_hash_tree_root(h, o))))]):
  %Equal.sym(B.Buf & (ComplexTestStruct_d.Gc56D855869F & D.Digest), ComplexTestStruct_h.Gc56D855869F_root(64n, h, o, 0), (h, (o, d_Gc56D855869F(64n, o))), st_Gc56D855869F(64n, h, o, 0, s, rep)) :
    RR.roots(LV.v_Gc56D855869F(o), s, [D.bytes(Pair.snd(ComplexTestStruct_d.Gc56D855869F, D.Digest, Pair.snd(B.Buf, ComplexTestStruct_d.Gc56D855869F & D.Digest, _)))])
  rs_Gc56D855869F(64n, {==}, h, o, s, rep, dv, edv, Gc56D855869F_ok(s, es, dv, edv), Gc56D855869F_eqs(s, es))
law Gc56D855869F_root_correct:
  for -h: B.Buf
  for -o: ComplexTestStruct_d.Gc56D855869F
  for +s: S.Schema
  for +es: {s == Spec.Gc56D855869F() : S.Schema}
  for +rep: LV.rep_Gc56D855869F(o, s)
  RR.roots(LV.v_Gc56D855869F(o), s, [D.bytes(Pair.snd(ComplexTestStruct_d.Gc56D855869F, D.Digest, Pair.snd(B.Buf, ComplexTestStruct_d.Gc56D855869F & D.Digest, ComplexTestStruct_h.Gc56D855869F_hash_tree_root(h, o))))])
def Gc56D855869F_root_correct(h, o, s, es, rep): Gc56D855869F_rc(h, o, s, es, rep, OS.DV0(), {==})

# GtDB1482527D: for every bit list object representing a value of Spec.GtDB1482527D(),
# the runtime root is a specification root of its bits.
def GtDB1482527D_ok(+s: S.Schema, +es: {s == Spec.GtDB1482527D() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtDB1482527D(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law GtDB1482527D_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.GtDB1482527D() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_15_h.GtDB1482527D_hash_tree_root(h, o))))])
def GtDB1482527D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, GtDB1482527D_ok(s, es), {==}, {==})

# Gt7C1C13B292: for every bit list object representing a value of Spec.Gt7C1C13B292(),
# the runtime root is a specification root of its bits.
def Gt7C1C13B292_ok(+s: S.Schema, +es: {s == Spec.Gt7C1C13B292() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt7C1C13B292(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law Gt7C1C13B292_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt7C1C13B292() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_16_h.Gt7C1C13B292_hash_tree_root(h, o))))])
def Gt7C1C13B292_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, Gt7C1C13B292_ok(s, es), {==}, {==})

# GtAA99FAAC9D: for every bit list object representing a value of Spec.GtAA99FAAC9D(),
# the runtime root is a specification root of its bits.
def GtAA99FAAC9D_ok(+s: S.Schema, +es: {s == Spec.GtAA99FAAC9D() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtAA99FAAC9D(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law GtAA99FAAC9D_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.GtAA99FAAC9D() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_17_h.GtAA99FAAC9D_hash_tree_root(h, o))))])
def GtAA99FAAC9D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, GtAA99FAAC9D_ok(s, es), {==}, {==})

# Gt94B70684B5: for every bit list object representing a value of Spec.Gt94B70684B5(),
# the runtime root is a specification root of its bits.
def Gt94B70684B5_ok(+s: S.Schema, +es: {s == Spec.Gt94B70684B5() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt94B70684B5(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law Gt94B70684B5_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt94B70684B5() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_1_h.Gt94B70684B5_hash_tree_root(h, o))))])
def Gt94B70684B5_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, Gt94B70684B5_ok(s, es), {==}, {==})

# GtCF587DD386: for every bit list object representing a value of Spec.GtCF587DD386(),
# the runtime root is a specification root of its bits.
def GtCF587DD386_ok(+s: S.Schema, +es: {s == Spec.GtCF587DD386() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtCF587DD386(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law GtCF587DD386_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.GtCF587DD386() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_2_h.GtCF587DD386_hash_tree_root(h, o))))])
def GtCF587DD386_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, GtCF587DD386_ok(s, es), {==}, {==})

# Gt4B1BA0C81D: for every bit list object representing a value of Spec.Gt4B1BA0C81D(),
# the runtime root is a specification root of its bits.
def Gt4B1BA0C81D_ok(+s: S.Schema, +es: {s == Spec.Gt4B1BA0C81D() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt4B1BA0C81D(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law Gt4B1BA0C81D_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt4B1BA0C81D() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_31_h.Gt4B1BA0C81D_hash_tree_root(h, o))))])
def Gt4B1BA0C81D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, Gt4B1BA0C81D_ok(s, es), {==}, {==})

# Gt2F34855D3D: for every bit list object representing a value of Spec.Gt2F34855D3D(),
# the runtime root is a specification root of its bits.
def Gt2F34855D3D_ok(+s: S.Schema, +es: {s == Spec.Gt2F34855D3D() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt2F34855D3D(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law Gt2F34855D3D_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt2F34855D3D() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_32_h.Gt2F34855D3D_hash_tree_root(h, o))))])
def Gt2F34855D3D_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, Gt2F34855D3D_ok(s, es), {==}, {==})

# Gt039DD44FD8: for every bit list object representing a value of Spec.Gt039DD44FD8(),
# the runtime root is a specification root of its bits.
def Gt039DD44FD8_ok(+s: S.Schema, +es: {s == Spec.Gt039DD44FD8() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt039DD44FD8(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law Gt039DD44FD8_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt039DD44FD8() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_33_h.Gt039DD44FD8_hash_tree_root(h, o))))])
def Gt039DD44FD8_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, Gt039DD44FD8_ok(s, es), {==}, {==})

# GtC847E618FA: for every bit list object representing a value of Spec.GtC847E618FA(),
# the runtime root is a specification root of its bits.
def GtC847E618FA_ok(+s: S.Schema, +es: {s == Spec.GtC847E618FA() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtC847E618FA(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law GtC847E618FA_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.GtC847E618FA() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_3_h.GtC847E618FA_hash_tree_root(h, o))))])
def GtC847E618FA_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, GtC847E618FA_ok(s, es), {==}, {==})

# Gt484D1ADAFE: for every bit list object representing a value of Spec.Gt484D1ADAFE(),
# the runtime root is a specification root of its bits.
def Gt484D1ADAFE_ok(+s: S.Schema, +es: {s == Spec.Gt484D1ADAFE() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt484D1ADAFE(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law Gt484D1ADAFE_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt484D1ADAFE() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_4_h.Gt484D1ADAFE_hash_tree_root(h, o))))])
def Gt484D1ADAFE_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, Gt484D1ADAFE_ok(s, es), {==}, {==})

# Gt21E1483EE1: for every bit list object representing a value of Spec.Gt21E1483EE1(),
# the runtime root is a specification root of its bits.
def Gt21E1483EE1_ok(+s: S.Schema, +es: {s == Spec.Gt21E1483EE1() : S.Schema}) -> {BO_L.ok_bits(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt21E1483EE1(), es) : {BO_L.ok_bits(_, 1n) == True{} : Bool}
  {==}
law Gt21E1483EE1_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt21E1483EE1() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_511_h.Gt21E1483EE1_hash_tree_root(h, o))))])
def Gt21E1483EE1_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 1, 0), (h, (o, BO.bdig(64n, o, 1n))), BO.bst(64n, h, o, 1, 0, 1n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 1n, 1, 0, rep, Gt21E1483EE1_ok(s, es), {==}, {==})

# Gt38F5890C13: for every bit list object representing a value of Spec.Gt38F5890C13(),
# the runtime root is a specification root of its bits.
def Gt38F5890C13_ok(+s: S.Schema, +es: {s == Spec.Gt38F5890C13() : S.Schema}) -> {BO_L.ok_bits(s, 1n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt38F5890C13(), es) : {BO_L.ok_bits(_, 1n) == True{} : Bool}
  {==}
law Gt38F5890C13_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt38F5890C13() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_512_h.Gt38F5890C13_hash_tree_root(h, o))))])
def Gt38F5890C13_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 1, 0), (h, (o, BO.bdig(64n, o, 1n))), BO.bst(64n, h, o, 1, 0, 1n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 1n, 1, 0, rep, Gt38F5890C13_ok(s, es), {==}, {==})

# Gt44F1B6940F: for every bit list object representing a value of Spec.Gt44F1B6940F(),
# the runtime root is a specification root of its bits.
def Gt44F1B6940F_ok(+s: S.Schema, +es: {s == Spec.Gt44F1B6940F() : S.Schema}) -> {BO_L.ok_bits(s, 2n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt44F1B6940F(), es) : {BO_L.ok_bits(_, 2n) == True{} : Bool}
  {==}
law Gt44F1B6940F_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt44F1B6940F() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_513_h.Gt44F1B6940F_hash_tree_root(h, o))))])
def Gt44F1B6940F_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 2, 0), (h, (o, BO.bdig(64n, o, 2n))), BO.bst(64n, h, o, 2, 0, 2n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 2n, 2, 0, rep, Gt44F1B6940F_ok(s, es), {==}, {==})

# GtF91FD5FC73: for every bit list object representing a value of Spec.GtF91FD5FC73(),
# the runtime root is a specification root of its bits.
def GtF91FD5FC73_ok(+s: S.Schema, +es: {s == Spec.GtF91FD5FC73() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtF91FD5FC73(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law GtF91FD5FC73_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.GtF91FD5FC73() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_5_h.GtF91FD5FC73_hash_tree_root(h, o))))])
def GtF91FD5FC73_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, GtF91FD5FC73_ok(s, es), {==}, {==})

# Gt98B8C9F262: for every bit list object representing a value of Spec.Gt98B8C9F262(),
# the runtime root is a specification root of its bits.
def Gt98B8C9F262_ok(+s: S.Schema, +es: {s == Spec.Gt98B8C9F262() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt98B8C9F262(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law Gt98B8C9F262_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt98B8C9F262() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_6_h.Gt98B8C9F262_hash_tree_root(h, o))))])
def Gt98B8C9F262_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, Gt98B8C9F262_ok(s, es), {==}, {==})

# GtC063F5D9E0: for every bit list object representing a value of Spec.GtC063F5D9E0(),
# the runtime root is a specification root of its bits.
def GtC063F5D9E0_ok(+s: S.Schema, +es: {s == Spec.GtC063F5D9E0() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtC063F5D9E0(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law GtC063F5D9E0_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.GtC063F5D9E0() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_7_h.GtC063F5D9E0_hash_tree_root(h, o))))])
def GtC063F5D9E0_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, GtC063F5D9E0_ok(s, es), {==}, {==})

# GtD291A17219: for every bit list object representing a value of Spec.GtD291A17219(),
# the runtime root is a specification root of its bits.
def GtD291A17219_ok(+s: S.Schema, +es: {s == Spec.GtD291A17219() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.GtD291A17219(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law GtD291A17219_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.GtD291A17219() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_8_h.GtD291A17219_hash_tree_root(h, o))))])
def GtD291A17219_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, GtD291A17219_ok(s, es), {==}, {==})

# Gt9D356BAF82: for every bit list object representing a value of Spec.Gt9D356BAF82(),
# the runtime root is a specification root of its bits.
def Gt9D356BAF82_ok(+s: S.Schema, +es: {s == Spec.Gt9D356BAF82() : S.Schema}) -> {BO_L.ok_bits(s, 0n) == True{} : Bool}:
  %Equal.sym(S.Schema, s, Spec.Gt9D356BAF82(), es) : {BO_L.ok_bits(_, 0n) == True{} : Bool}
  {==}
law Gt9D356BAF82_root_correct:
  for -h: B.Buf
  for -o: O.Bits
  for +s: S.Schema
  for +es: {s == Spec.Gt9D356BAF82() : S.Schema}
  for +rep: BO_L.rep_bits(o, s)
  RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, bitlist_9_h.Gt9D356BAF82_hash_tree_root(h, o))))])
def Gt9D356BAF82_root_correct(h, o, s, es, rep):
  %Equal.sym(B.Buf & (O.Bits & D.Digest), O.bits_root(64n, h, o, 0, 0), (h, (o, BO.bdig(64n, o, 0n))), BO.bst(64n, h, o, 0, 0, 0n, BO_L.rep_wf(o, s, rep), {==})) :
    RR.roots(S.BitsValue{BO_L.bview(o)}, s, [D.bytes(Pair.snd(O.Bits, D.Digest, Pair.snd(B.Buf, O.Bits & D.Digest, _)))])
  BO.brs(64n, {==}, h, o, s, 0n, 0, 0, rep, Gt9D356BAF82_ok(s, es), {==}, {==})

