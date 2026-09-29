import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/progbitlist_encode_ssz_generated.bend as progbitlist_e
import ../../types/ProgressiveSingleListContainerTestStruct_def_generated.bend as ProgressiveSingleListContainerTestStruct_d
import ../../types/ProgressiveSingleListContainerTestStruct_encode_ssz_generated.bend as ProgressiveSingleListContainerTestStruct_e
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
import ./big_encx_pbits.bend as EX_pbits
import ./big_encx_Gp4B0CA2906A.bend as K
import ./big_encx_Gp4B0CA2906A_iface.bend as OB

# GENERATED (codegen/okw.py okw_companion). Do not edit.
# the size and validity passes on OKW (encodings below 2^31 bytes) of big_encx_Gp4B0CA2906A_iface

def sizeCW(+m_f_C: EX_pbits.MB, +h: {OB.OKTW(m_f_C) == True{} : Bool}) -> {ProgressiveSingleListContainerTestStruct_e.Gp4B0CA2906A_size(K.OBJC(m_f_C)) == (K.OBJC(m_f_C), K.SZC(m_f_C)) : ProgressiveSingleListContainerTestStruct_d.Gp4B0CA2906A & U32}:
  %Equal.sym(O.Bits & U32, progbitlist_e.pbits_size(EX_pbits.TH(m_f_C)), (EX_pbits.TH(m_f_C), EX_pbits.SZ(m_f_C)), EX_pbits.sizex(m_f_C, OB.ok_hok_f_CW(m_f_C, h))) :
    {ProgressiveSingleListContainerTestStruct_e.Gp4B0CA2906A_sz0(4, _) == (K.OBJC(m_f_C), K.SZC(m_f_C)) : ProgressiveSingleListContainerTestStruct_d.Gp4B0CA2906A & U32}
  {==}

def rvalidCW(+m_f_C: EX_pbits.MB, +h: {OB.OKTW(m_f_C) == True{} : Bool}) -> {ProgressiveSingleListContainerTestStruct_e.Gp4B0CA2906A_valid(K.OBJC(m_f_C)) == (K.OBJC(m_f_C), True{}) : ProgressiveSingleListContainerTestStruct_d.Gp4B0CA2906A & Bool}:
  %Equal.sym(O.Bits & Bool, progbitlist_e.pbits_valid(EX_pbits.TH(m_f_C)), (EX_pbits.TH(m_f_C), True{}), EX_pbits.validx(m_f_C, OB.ok_hok_f_CW(m_f_C, h))) :
    {ProgressiveSingleListContainerTestStruct_e.Gp4B0CA2906A_va0(True{}, _) == (K.OBJC(m_f_C), True{}) : ProgressiveSingleListContainerTestStruct_d.Gp4B0CA2906A & Bool}
  {==}

law sizexO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {ProgressiveSingleListContainerTestStruct_e.Gp4B0CA2906A_size(OB.TH(m)) == (OB.TH(m), OB.SZ(m)) : ProgressiveSingleListContainerTestStruct_d.Gp4B0CA2906A & U32}
def sizexO(m, hok):
  match m:
    case OB.MW{+m_f_C}: sizeCW(m_f_C, hok)

law validxO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {ProgressiveSingleListContainerTestStruct_e.Gp4B0CA2906A_valid(OB.TH(m)) == (OB.TH(m), True{}) : ProgressiveSingleListContainerTestStruct_d.Gp4B0CA2906A & Bool}
def validxO(m, hok):
  match m:
    case OB.MW{+m_f_C}: rvalidCW(m_f_C, hok)
