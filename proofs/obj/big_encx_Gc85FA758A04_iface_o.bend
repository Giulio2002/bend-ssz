import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/bitvector_1_def_generated.bend as bitvector_1_d
import ../../types/bitvector_2_def_generated.bend as bitvector_2_d
import ../../types/bitvector_8_def_generated.bend as bitvector_8_d
import ../../types/bitlist_5_encode_ssz_generated.bend as bitlist_5_e
import ../../types/bitvector_2_encode_ssz_generated.bend as bitvector_2_e
import ../../types/bitvector_1_encode_ssz_generated.bend as bitvector_1_e
import ../../types/bitlist_6_encode_ssz_generated.bend as bitlist_6_e
import ../../types/bitvector_8_encode_ssz_generated.bend as bitvector_8_e
import ../../types/BitsStruct_def_generated.bend as BitsStruct_d
import ../../types/BitsStruct_encode_ssz_generated.bend as BitsStruct_e
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
import ./big_encx_bits5.bend as EX_bits5
import ./big_encx_bits6.bend as EX_bits6
import ./vbitb.bend as VBB
import ./big_encx_Gc85FA758A04.bend as K
import ./big_encx_Gc85FA758A04_iface.bend as OB

# GENERATED (codegen/okw.py okw_companion). Do not edit.
# the size and validity passes on OKW (encodings below 2^31 bytes) of big_encx_Gc85FA758A04_iface

def sizeCW(+m_f_A: EX_bits5.MB, +f_B: U32, +f_C: U32, +m_f_D: EX_bits6.MB, +f_E: U32, +h: {OB.OKTW(m_f_A, f_B, f_C, m_f_D, f_E) == True{} : Bool}) -> {BitsStruct_e.Gc85FA758A04_size(K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E)) == (K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E), K.SZC(m_f_A, f_B, f_C, m_f_D, f_E)) : BitsStruct_d.Gc85FA758A04 & U32}:
  %Equal.sym(U32, K.SZC(m_f_A, f_B, f_C, m_f_D, f_E), O.padd(O.padd(11, EX_bits5.SZ(m_f_A)), EX_bits6.SZ(m_f_D)), K.szpz(m_f_A, f_B, f_C, m_f_D, f_E, OB.ok_hpzW(m_f_A, f_B, f_C, m_f_D, f_E, h))) :
    {BitsStruct_e.Gc85FA758A04_size(K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E)) == (K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E), _) : BitsStruct_d.Gc85FA758A04 & U32}
  %Equal.sym(O.Bits & U32, bitlist_5_e.bits5_size(EX_bits5.TH(m_f_A)), (EX_bits5.TH(m_f_A), EX_bits5.SZ(m_f_A)), EX_bits5.sizex(m_f_A, OB.ok_hok_f_AW(m_f_A, f_B, f_C, m_f_D, f_E, h))) :
    {BitsStruct_e.Gc85FA758A04_sz0(bitvector_2_d.Bitvector2{f_B}, bitvector_1_d.Bitvector1{f_C}, EX_bits6.TH(m_f_D), bitvector_8_d.Bitvector8{f_E}, 11, _) == (K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E), O.padd(O.padd(11, EX_bits5.SZ(m_f_A)), EX_bits6.SZ(m_f_D))) : BitsStruct_d.Gc85FA758A04 & U32}
  %Equal.sym(O.Bits & U32, bitlist_6_e.bits6_size(EX_bits6.TH(m_f_D)), (EX_bits6.TH(m_f_D), EX_bits6.SZ(m_f_D)), EX_bits6.sizex(m_f_D, OB.ok_hok_f_DW(m_f_A, f_B, f_C, m_f_D, f_E, h))) :
    {BitsStruct_e.Gc85FA758A04_sz1(bitvector_2_d.Bitvector2{f_B}, bitvector_1_d.Bitvector1{f_C}, bitvector_8_d.Bitvector8{f_E}, EX_bits5.TH(m_f_A), O.padd(11, EX_bits5.SZ(m_f_A)), _) == (K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E), O.padd(O.padd(11, EX_bits5.SZ(m_f_A)), EX_bits6.SZ(m_f_D))) : BitsStruct_d.Gc85FA758A04 & U32}
  {==}

def rvalidCW(+m_f_A: EX_bits5.MB, +f_B: U32, +f_C: U32, +m_f_D: EX_bits6.MB, +f_E: U32, +h: {OB.OKTW(m_f_A, f_B, f_C, m_f_D, f_E) == True{} : Bool}) -> {BitsStruct_e.Gc85FA758A04_valid(K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E)) == (K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E), True{}) : BitsStruct_d.Gc85FA758A04 & Bool}:
  %Equal.sym(Bool, Bool.and(bitvector_2_e.bv2_valid(bitvector_2_d.Bitvector2{f_B}), Bool.and(bitvector_1_e.bv1_valid(bitvector_1_d.Bitvector1{f_C}), bitvector_8_e.bv8_valid(bitvector_8_d.Bitvector8{f_E}))), True{}, OB.ok_hpzW(m_f_A, f_B, f_C, m_f_D, f_E, h)) :
    {BitsStruct_e.Gc85FA758A04_va0(bitvector_2_d.Bitvector2{f_B}, bitvector_1_d.Bitvector1{f_C}, EX_bits6.TH(m_f_D), bitvector_8_d.Bitvector8{f_E}, _, bitlist_5_e.bits5_valid(EX_bits5.TH(m_f_A))) == (K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E), True{}) : BitsStruct_d.Gc85FA758A04 & Bool}
  %Equal.sym(O.Bits & Bool, bitlist_5_e.bits5_valid(EX_bits5.TH(m_f_A)), (EX_bits5.TH(m_f_A), True{}), EX_bits5.validx(m_f_A, OB.ok_hok_f_AW(m_f_A, f_B, f_C, m_f_D, f_E, h))) :
    {BitsStruct_e.Gc85FA758A04_va0(bitvector_2_d.Bitvector2{f_B}, bitvector_1_d.Bitvector1{f_C}, EX_bits6.TH(m_f_D), bitvector_8_d.Bitvector8{f_E}, True{}, _) == (K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E), True{}) : BitsStruct_d.Gc85FA758A04 & Bool}
  %Equal.sym(O.Bits & Bool, bitlist_6_e.bits6_valid(EX_bits6.TH(m_f_D)), (EX_bits6.TH(m_f_D), True{}), EX_bits6.validx(m_f_D, OB.ok_hok_f_DW(m_f_A, f_B, f_C, m_f_D, f_E, h))) :
    {BitsStruct_e.Gc85FA758A04_va1(EX_bits5.TH(m_f_A), bitvector_2_d.Bitvector2{f_B}, bitvector_1_d.Bitvector1{f_C}, bitvector_8_d.Bitvector8{f_E}, Bool.and(True{}, True{}), _) == (K.OBJC(m_f_A, f_B, f_C, m_f_D, f_E), True{}) : BitsStruct_d.Gc85FA758A04 & Bool}
  {==}

law sizexO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {BitsStruct_e.Gc85FA758A04_size(OB.TH(m)) == (OB.TH(m), OB.SZ(m)) : BitsStruct_d.Gc85FA758A04 & U32}
def sizexO(m, hok):
  match m:
    case OB.MW{+m_f_A, +f_B, +f_C, +m_f_D, +f_E}: sizeCW(m_f_A, f_B, f_C, m_f_D, f_E, hok)

law validxO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {BitsStruct_e.Gc85FA758A04_valid(OB.TH(m)) == (OB.TH(m), True{}) : BitsStruct_d.Gc85FA758A04 & Bool}
def validxO(m, hok):
  match m:
    case OB.MW{+m_f_A, +f_B, +f_C, +m_f_D, +f_E}: rvalidCW(m_f_A, f_B, f_C, m_f_D, f_E, hok)
