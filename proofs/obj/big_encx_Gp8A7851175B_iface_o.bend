import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/uint8_encode_ssz_generated.bend as uint8_e
import ../../types/progbitlist_encode_ssz_generated.bend as progbitlist_e
import ../../types/list_uint16_123_encode_ssz_generated.bend as list_uint16_123_e
import ../../types/proglist_uint64_encode_ssz_generated.bend as proglist_uint64_e
import ../../types/proglist_SmallTestStruct_def_generated.bend as proglist_SmallTestStruct_d
import ../../types/proglist_SmallTestStruct_encode_ssz_generated.bend as proglist_SmallTestStruct_e
import ../../types/proglist_proglist_VarTestStruct_def_generated.bend as proglist_proglist_VarTestStruct_d
import ../../types/proglist_proglist_VarTestStruct_encode_ssz_generated.bend as proglist_proglist_VarTestStruct_e
import ../../types/list_ProgressiveSingleFieldContainerTestStruct_10_def_generated.bend as list_ProgressiveSingleFieldContainerTestStruct_10_d
import ../../types/list_ProgressiveSingleFieldContainerTestStruct_10_encode_ssz_generated.bend as list_ProgressiveSingleFieldContainerTestStruct_10_e
import ../../types/proglist_ProgressiveVarTestStruct_def_generated.bend as proglist_ProgressiveVarTestStruct_d
import ../../types/proglist_ProgressiveVarTestStruct_encode_ssz_generated.bend as proglist_ProgressiveVarTestStruct_e
import ../../types/ProgressiveComplexTestStruct_def_generated.bend as ProgressiveComplexTestStruct_d
import ../../types/ProgressiveComplexTestStruct_encode_ssz_generated.bend as ProgressiveComplexTestStruct_e
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/codec.bend as Codec
import ../../spec/layout.bend as Layout
import ../../spec/primitives.bend as SP
import ./generic_specs.bend as Spec
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vua.bend as UA
import ./vuw.bend as UW
import ./vuwd.bend as WD
import ./vcopy.bend as VC
import ./vrecx.bend as VRX
import ./vcont.bend as VCN
import ./vua_lay.bend as LY
import ./vconts.bend as CS
import ./spec_bits.bend as FB
import ./dk.bend as DK
import ./vpiece.bend as VPC
import ./big_encx_l123_u16.bend as EX_l123_u16
import ./big_encx_pbits.bend as EX_pbits
import ./big_encx_pl_u64.bend as EX_pl_u64
import ./big_encx_pl_Gc4ED9619F50.bend as EX_pl_Gc4ED9619F50
import ./big_encx_pl_pl_Gc465214E502.bend as EX_pl_pl_Gc465214E502
import ./big_encx_l10_GpF350A3C486.bend as EX_l10_GpF350A3C486
import ./big_encx_pl_Gp66304057C3.bend as EX_pl_Gp66304057C3
import ./vrecb.bend as VRB
import ./big_encx_Gp8A7851175B.bend as K
import ./big_encx_Gp8A7851175B_iface.bend as OB

# GENERATED (codegen/okw.py okw_companion). Do not edit.
# the size and validity passes on OKW (encodings below 2^31 bytes) of big_encx_Gp8A7851175B_iface

def sizeCW(+f_A: U32, +m_f_B: EX_l123_u16.MW, +m_f_C: EX_pbits.MB, +m_f_D: EX_pl_u64.MW, +m_f_E: EX_pl_Gc4ED9619F50.MW, +m_f_F: EX_pl_pl_Gc465214E502.MW, +m_f_G: EX_l10_GpF350A3C486.MW, +m_f_H: EX_pl_Gp66304057C3.MW, +h: {OB.OKTW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H) == True{} : Bool}) -> {ProgressiveComplexTestStruct_e.Gp8A7851175B_size(K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H)) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), K.SZC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H)) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}:
  %Equal.sym(U32, K.SZC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_pl_Gp66304057C3.SZ(m_f_H)), K.szpz(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, OB.ok_hpzW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_size(K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H)) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), _) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
  %Equal.sym(O.Words & U32, list_uint16_123_e.l123_u16_size(EX_l123_u16.TH(m_f_B)), (EX_l123_u16.TH(m_f_B), EX_l123_u16.SZ(m_f_B)), EX_l123_u16.sizex(m_f_B, OB.ok_hok_f_BW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_sz0(f_A, EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), 29, _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_pl_Gp66304057C3.SZ(m_f_H))) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
  %Equal.sym(O.Bits & U32, progbitlist_e.pbits_size(EX_pbits.TH(m_f_C)), (EX_pbits.TH(m_f_C), EX_pbits.SZ(m_f_C)), EX_pbits.sizex(m_f_C, OB.ok_hok_f_CW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_sz1(f_A, EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), EX_l123_u16.TH(m_f_B), O.padd(29, EX_l123_u16.SZ(m_f_B)), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_pl_Gp66304057C3.SZ(m_f_H))) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
  %Equal.sym(O.Words & U32, proglist_uint64_e.pl_u64_size(EX_pl_u64.TH(m_f_D)), (EX_pl_u64.TH(m_f_D), EX_pl_u64.SZ(m_f_D)), EX_pl_u64.sizex(m_f_D, OB.ok_hok_f_DW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_sz2(f_A, EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_pl_Gp66304057C3.SZ(m_f_H))) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
  %Equal.sym(proglist_SmallTestStruct_d.pl_Gc4ED9619F50_Seq & U32, proglist_SmallTestStruct_e.pl_Gc4ED9619F50_size(EX_pl_Gc4ED9619F50.TH(m_f_E)), (EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_Gc4ED9619F50.sizex(m_f_E, OB.ok_hok_f_EW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_sz3(f_A, EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_pl_Gp66304057C3.SZ(m_f_H))) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
  %Equal.sym(proglist_proglist_VarTestStruct_d.pl_pl_Gc465214E502_Seq & U32, proglist_proglist_VarTestStruct_e.pl_pl_Gc465214E502_size(EX_pl_pl_Gc465214E502.TH(m_f_F)), (EX_pl_pl_Gc465214E502.TH(m_f_F), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_pl_pl_Gc465214E502.sizex(m_f_F, OB.ok_hok_f_FW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_sz4(f_A, EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_pl_Gp66304057C3.SZ(m_f_H))) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
  %Equal.sym(list_ProgressiveSingleFieldContainerTestStruct_10_d.l10_GpF350A3C486_Seq & U32, list_ProgressiveSingleFieldContainerTestStruct_10_e.l10_GpF350A3C486_size(EX_l10_GpF350A3C486.TH(m_f_G)), (EX_l10_GpF350A3C486.TH(m_f_G), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_l10_GpF350A3C486.sizex(m_f_G, OB.ok_hok_f_GW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_sz5(f_A, EX_pl_Gp66304057C3.TH(m_f_H), EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_pl_Gp66304057C3.SZ(m_f_H))) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
  %Equal.sym(proglist_ProgressiveVarTestStruct_d.pl_Gp66304057C3_Seq & U32, proglist_ProgressiveVarTestStruct_e.pl_Gp66304057C3_size(EX_pl_Gp66304057C3.TH(m_f_H)), (EX_pl_Gp66304057C3.TH(m_f_H), EX_pl_Gp66304057C3.SZ(m_f_H)), EX_pl_Gp66304057C3.sizex(m_f_H, OB.ok_hok_f_HW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_sz6(f_A, EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(O.padd(29, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), EX_pl_u64.SZ(m_f_D)), EX_pl_Gc4ED9619F50.SZ(m_f_E)), EX_pl_pl_Gc465214E502.SZ(m_f_F)), EX_l10_GpF350A3C486.SZ(m_f_G)), EX_pl_Gp66304057C3.SZ(m_f_H))) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
  {==}

def rvalidCW(+f_A: U32, +m_f_B: EX_l123_u16.MW, +m_f_C: EX_pbits.MB, +m_f_D: EX_pl_u64.MW, +m_f_E: EX_pl_Gc4ED9619F50.MW, +m_f_F: EX_pl_pl_Gc465214E502.MW, +m_f_G: EX_l10_GpF350A3C486.MW, +m_f_H: EX_pl_Gp66304057C3.MW, +h: {OB.OKTW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H) == True{} : Bool}) -> {ProgressiveComplexTestStruct_e.Gp8A7851175B_valid(K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H)) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}:
  %Equal.sym(Bool, uint8_e.u8_valid(f_A), True{}, OB.ok_hpzW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h)) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_va0(f_A, EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), _, list_uint16_123_e.l123_u16_valid(EX_l123_u16.TH(m_f_B))) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
  %Equal.sym(O.Words & Bool, list_uint16_123_e.l123_u16_valid(EX_l123_u16.TH(m_f_B)), (EX_l123_u16.TH(m_f_B), True{}), EX_l123_u16.validx(m_f_B, OB.ok_hok_f_BW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_va0(f_A, EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), True{}, _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
  %Equal.sym(O.Bits & Bool, progbitlist_e.pbits_valid(EX_pbits.TH(m_f_C)), (EX_pbits.TH(m_f_C), True{}), EX_pbits.validx(m_f_C, OB.ok_hok_f_CW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_va1(f_A, EX_l123_u16.TH(m_f_B), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), Bool.and(True{}, True{}), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
  %Equal.sym(O.Words & Bool, proglist_uint64_e.pl_u64_valid(EX_pl_u64.TH(m_f_D)), (EX_pl_u64.TH(m_f_D), True{}), EX_pl_u64.validx(m_f_D, OB.ok_hok_f_DW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_va2(f_A, EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), Bool.and(Bool.and(True{}, True{}), True{}), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
  %Equal.sym(proglist_SmallTestStruct_d.pl_Gc4ED9619F50_Seq & Bool, proglist_SmallTestStruct_e.pl_Gc4ED9619F50_valid(EX_pl_Gc4ED9619F50.TH(m_f_E)), (EX_pl_Gc4ED9619F50.TH(m_f_E), True{}), EX_pl_Gc4ED9619F50.validx(m_f_E, OB.ok_hok_f_EW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_va3(f_A, EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), Bool.and(Bool.and(Bool.and(True{}, True{}), True{}), True{}), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
  %Equal.sym(proglist_proglist_VarTestStruct_d.pl_pl_Gc465214E502_Seq & Bool, proglist_proglist_VarTestStruct_e.pl_pl_Gc465214E502_valid(EX_pl_pl_Gc465214E502.TH(m_f_F)), (EX_pl_pl_Gc465214E502.TH(m_f_F), True{}), EX_pl_pl_Gc465214E502.validx(m_f_F, OB.ok_hok_f_FW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_va4(f_A, EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_l10_GpF350A3C486.TH(m_f_G), EX_pl_Gp66304057C3.TH(m_f_H), Bool.and(Bool.and(Bool.and(Bool.and(True{}, True{}), True{}), True{}), True{}), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
  %Equal.sym(list_ProgressiveSingleFieldContainerTestStruct_10_d.l10_GpF350A3C486_Seq & Bool, list_ProgressiveSingleFieldContainerTestStruct_10_e.l10_GpF350A3C486_valid(EX_l10_GpF350A3C486.TH(m_f_G)), (EX_l10_GpF350A3C486.TH(m_f_G), True{}), EX_l10_GpF350A3C486.validx(m_f_G, OB.ok_hok_f_GW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_va5(f_A, EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_pl_Gp66304057C3.TH(m_f_H), Bool.and(Bool.and(Bool.and(Bool.and(Bool.and(True{}, True{}), True{}), True{}), True{}), True{}), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
  %Equal.sym(proglist_ProgressiveVarTestStruct_d.pl_Gp66304057C3_Seq & Bool, proglist_ProgressiveVarTestStruct_e.pl_Gp66304057C3_valid(EX_pl_Gp66304057C3.TH(m_f_H)), (EX_pl_Gp66304057C3.TH(m_f_H), True{}), EX_pl_Gp66304057C3.validx(m_f_H, OB.ok_hok_f_HW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, h))) :
    {ProgressiveComplexTestStruct_e.Gp8A7851175B_va6(f_A, EX_l123_u16.TH(m_f_B), EX_pbits.TH(m_f_C), EX_pl_u64.TH(m_f_D), EX_pl_Gc4ED9619F50.TH(m_f_E), EX_pl_pl_Gc465214E502.TH(m_f_F), EX_l10_GpF350A3C486.TH(m_f_G), Bool.and(Bool.and(Bool.and(Bool.and(Bool.and(Bool.and(True{}, True{}), True{}), True{}), True{}), True{}), True{}), _) == (K.OBJC(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
  {==}

law sizexO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {ProgressiveComplexTestStruct_e.Gp8A7851175B_size(OB.TH(m)) == (OB.TH(m), OB.SZ(m)) : ProgressiveComplexTestStruct_d.Gp8A7851175B & U32}
def sizexO(m, hok):
  match m:
    case OB.MW{+f_A, +m_f_B, +m_f_C, +m_f_D, +m_f_E, +m_f_F, +m_f_G, +m_f_H}: sizeCW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, hok)

law validxO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {ProgressiveComplexTestStruct_e.Gp8A7851175B_valid(OB.TH(m)) == (OB.TH(m), True{}) : ProgressiveComplexTestStruct_d.Gp8A7851175B & Bool}
def validxO(m, hok):
  match m:
    case OB.MW{+f_A, +m_f_B, +m_f_C, +m_f_D, +m_f_E, +m_f_F, +m_f_G, +m_f_H}: rvalidCW(f_A, m_f_B, m_f_C, m_f_D, m_f_E, m_f_F, m_f_G, m_f_H, hok)
