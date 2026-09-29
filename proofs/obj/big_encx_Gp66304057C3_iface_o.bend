import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/uint8_encode_ssz_generated.bend as uint8_e
import ../../types/progbitlist_encode_ssz_generated.bend as progbitlist_e
import ../../types/list_uint16_123_encode_ssz_generated.bend as list_uint16_123_e
import ../../types/ProgressiveVarTestStruct_def_generated.bend as ProgressiveVarTestStruct_d
import ../../types/ProgressiveVarTestStruct_encode_ssz_generated.bend as ProgressiveVarTestStruct_e
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
import ./vrecb.bend as VRB
import ./big_encx_Gp66304057C3.bend as K
import ./big_encx_Gp66304057C3_iface.bend as OB

# GENERATED (codegen/okw.py okw_companion). Do not edit.
# the size and validity passes on OKW (encodings below 2^31 bytes) of big_encx_Gp66304057C3_iface

def sizeCW(+f_A: U32, +m_f_B: EX_l123_u16.MW, +m_f_C: EX_pbits.MB, +h: {OB.OKTW(f_A, m_f_B, m_f_C) == True{} : Bool}) -> {ProgressiveVarTestStruct_e.Gp66304057C3_size(K.OBJC(f_A, m_f_B, m_f_C)) == (K.OBJC(f_A, m_f_B, m_f_C), K.SZC(f_A, m_f_B, m_f_C)) : ProgressiveVarTestStruct_d.Gp66304057C3 & U32}:
  %Equal.sym(U32, K.SZC(f_A, m_f_B, m_f_C), O.padd(O.padd(9, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C)), K.szpz(f_A, m_f_B, m_f_C, OB.ok_hpzW(f_A, m_f_B, m_f_C, h))) :
    {ProgressiveVarTestStruct_e.Gp66304057C3_size(K.OBJC(f_A, m_f_B, m_f_C)) == (K.OBJC(f_A, m_f_B, m_f_C), _) : ProgressiveVarTestStruct_d.Gp66304057C3 & U32}
  %Equal.sym(O.Words & U32, list_uint16_123_e.l123_u16_size(EX_l123_u16.TH(m_f_B)), (EX_l123_u16.TH(m_f_B), EX_l123_u16.SZ(m_f_B)), EX_l123_u16.sizex(m_f_B, OB.ok_hok_f_BW(f_A, m_f_B, m_f_C, h))) :
    {ProgressiveVarTestStruct_e.Gp66304057C3_sz0(f_A, EX_pbits.TH(m_f_C), 9, _) == (K.OBJC(f_A, m_f_B, m_f_C), O.padd(O.padd(9, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C))) : ProgressiveVarTestStruct_d.Gp66304057C3 & U32}
  %Equal.sym(O.Bits & U32, progbitlist_e.pbits_size(EX_pbits.TH(m_f_C)), (EX_pbits.TH(m_f_C), EX_pbits.SZ(m_f_C)), EX_pbits.sizex(m_f_C, OB.ok_hok_f_CW(f_A, m_f_B, m_f_C, h))) :
    {ProgressiveVarTestStruct_e.Gp66304057C3_sz1(f_A, EX_l123_u16.TH(m_f_B), O.padd(9, EX_l123_u16.SZ(m_f_B)), _) == (K.OBJC(f_A, m_f_B, m_f_C), O.padd(O.padd(9, EX_l123_u16.SZ(m_f_B)), EX_pbits.SZ(m_f_C))) : ProgressiveVarTestStruct_d.Gp66304057C3 & U32}
  {==}

def rvalidCW(+f_A: U32, +m_f_B: EX_l123_u16.MW, +m_f_C: EX_pbits.MB, +h: {OB.OKTW(f_A, m_f_B, m_f_C) == True{} : Bool}) -> {ProgressiveVarTestStruct_e.Gp66304057C3_valid(K.OBJC(f_A, m_f_B, m_f_C)) == (K.OBJC(f_A, m_f_B, m_f_C), True{}) : ProgressiveVarTestStruct_d.Gp66304057C3 & Bool}:
  %Equal.sym(Bool, uint8_e.u8_valid(f_A), True{}, OB.ok_hpzW(f_A, m_f_B, m_f_C, h)) :
    {ProgressiveVarTestStruct_e.Gp66304057C3_va0(f_A, EX_pbits.TH(m_f_C), _, list_uint16_123_e.l123_u16_valid(EX_l123_u16.TH(m_f_B))) == (K.OBJC(f_A, m_f_B, m_f_C), True{}) : ProgressiveVarTestStruct_d.Gp66304057C3 & Bool}
  %Equal.sym(O.Words & Bool, list_uint16_123_e.l123_u16_valid(EX_l123_u16.TH(m_f_B)), (EX_l123_u16.TH(m_f_B), True{}), EX_l123_u16.validx(m_f_B, OB.ok_hok_f_BW(f_A, m_f_B, m_f_C, h))) :
    {ProgressiveVarTestStruct_e.Gp66304057C3_va0(f_A, EX_pbits.TH(m_f_C), True{}, _) == (K.OBJC(f_A, m_f_B, m_f_C), True{}) : ProgressiveVarTestStruct_d.Gp66304057C3 & Bool}
  %Equal.sym(O.Bits & Bool, progbitlist_e.pbits_valid(EX_pbits.TH(m_f_C)), (EX_pbits.TH(m_f_C), True{}), EX_pbits.validx(m_f_C, OB.ok_hok_f_CW(f_A, m_f_B, m_f_C, h))) :
    {ProgressiveVarTestStruct_e.Gp66304057C3_va1(f_A, EX_l123_u16.TH(m_f_B), Bool.and(True{}, True{}), _) == (K.OBJC(f_A, m_f_B, m_f_C), True{}) : ProgressiveVarTestStruct_d.Gp66304057C3 & Bool}
  {==}

law sizexO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {ProgressiveVarTestStruct_e.Gp66304057C3_size(OB.TH(m)) == (OB.TH(m), OB.SZ(m)) : ProgressiveVarTestStruct_d.Gp66304057C3 & U32}
def sizexO(m, hok):
  match m:
    case OB.MW{+f_A, +m_f_B, +m_f_C}: sizeCW(f_A, m_f_B, m_f_C, hok)

law validxO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {ProgressiveVarTestStruct_e.Gp66304057C3_valid(OB.TH(m)) == (OB.TH(m), True{}) : ProgressiveVarTestStruct_d.Gp66304057C3 & Bool}
def validxO(m, hok):
  match m:
    case OB.MW{+f_A, +m_f_B, +m_f_C}: rvalidCW(f_A, m_f_B, m_f_C, hok)
