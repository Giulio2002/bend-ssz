import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/proglist_uint64_encode_ssz_generated.bend as proglist_uint64_e
import ../../types/proglist_SmallTestStruct_def_generated.bend as proglist_SmallTestStruct_d
import ../../types/proglist_SmallTestStruct_encode_ssz_generated.bend as proglist_SmallTestStruct_e
import ../../types/proglist_proglist_VarTestStruct_def_generated.bend as proglist_proglist_VarTestStruct_d
import ../../types/proglist_proglist_VarTestStruct_encode_ssz_generated.bend as proglist_proglist_VarTestStruct_e
import ../../types/proglist_uint8_encode_ssz_generated.bend as proglist_uint8_e
import ../../types/ProgressiveTestStruct_def_generated.bend as ProgressiveTestStruct_d
import ../../types/ProgressiveTestStruct_encode_ssz_generated.bend as ProgressiveTestStruct_e
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
import ./big_encx_pl_u8.bend as EX_pl_u8
import ./big_encx_pl_u64.bend as EX_pl_u64
import ./big_encx_pl_Gc4ED9619F50.bend as EX_pl_Gc4ED9619F50
import ./big_encx_pl_pl_Gc465214E502.bend as EX_pl_pl_Gc465214E502
import ./big_encx_Gc221EC01D83.bend as K
import ./big_encx_Gc221EC01D83_iface.bend as OB

# GENERATED (codegen/okw.py okw_companion). Do not edit.
# the size and validity passes on OKW (encodings below 2^31 bytes) of big_encx_Gc221EC01D83_iface

def sizeCW(+m_f_A: EX_pl_u8.MW, +m_f_B: EX_pl_u64.MW, +m_f_C: EX_pl_Gc4ED9619F50.MW, +m_f_D: EX_pl_pl_Gc465214E502.MW, +h: {OB.OKTW(m_f_A, m_f_B, m_f_C, m_f_D) == True{} : Bool}) -> {ProgressiveTestStruct_e.Gc221EC01D83_size(K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D)) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), K.SZC(m_f_A, m_f_B, m_f_C, m_f_D)) : ProgressiveTestStruct_d.Gc221EC01D83 & U32}:
  %Equal.sym(O.Words & U32, proglist_uint8_e.pl_u8_size(EX_pl_u8.TH(m_f_A)), (EX_pl_u8.TH(m_f_A), EX_pl_u8.SZ(m_f_A)), EX_pl_u8.sizex(m_f_A, OB.ok_hok_f_AW(m_f_A, m_f_B, m_f_C, m_f_D, h))) :
    {ProgressiveTestStruct_e.Gc221EC01D83_sz0(EX_pl_u64.TH(m_f_B), EX_pl_Gc4ED9619F50.TH(m_f_C), EX_pl_pl_Gc465214E502.TH(m_f_D), 16, _) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), K.SZC(m_f_A, m_f_B, m_f_C, m_f_D)) : ProgressiveTestStruct_d.Gc221EC01D83 & U32}
  %Equal.sym(O.Words & U32, proglist_uint64_e.pl_u64_size(EX_pl_u64.TH(m_f_B)), (EX_pl_u64.TH(m_f_B), EX_pl_u64.SZ(m_f_B)), EX_pl_u64.sizex(m_f_B, OB.ok_hok_f_BW(m_f_A, m_f_B, m_f_C, m_f_D, h))) :
    {ProgressiveTestStruct_e.Gc221EC01D83_sz1(EX_pl_Gc4ED9619F50.TH(m_f_C), EX_pl_pl_Gc465214E502.TH(m_f_D), EX_pl_u8.TH(m_f_A), O.padd(16, EX_pl_u8.SZ(m_f_A)), _) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), K.SZC(m_f_A, m_f_B, m_f_C, m_f_D)) : ProgressiveTestStruct_d.Gc221EC01D83 & U32}
  %Equal.sym(proglist_SmallTestStruct_d.pl_Gc4ED9619F50_Seq & U32, proglist_SmallTestStruct_e.pl_Gc4ED9619F50_size(EX_pl_Gc4ED9619F50.TH(m_f_C)), (EX_pl_Gc4ED9619F50.TH(m_f_C), EX_pl_Gc4ED9619F50.SZ(m_f_C)), EX_pl_Gc4ED9619F50.sizex(m_f_C, OB.ok_hok_f_CW(m_f_A, m_f_B, m_f_C, m_f_D, h))) :
    {ProgressiveTestStruct_e.Gc221EC01D83_sz2(EX_pl_pl_Gc465214E502.TH(m_f_D), EX_pl_u8.TH(m_f_A), EX_pl_u64.TH(m_f_B), O.padd(O.padd(16, EX_pl_u8.SZ(m_f_A)), EX_pl_u64.SZ(m_f_B)), _) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), K.SZC(m_f_A, m_f_B, m_f_C, m_f_D)) : ProgressiveTestStruct_d.Gc221EC01D83 & U32}
  %Equal.sym(proglist_proglist_VarTestStruct_d.pl_pl_Gc465214E502_Seq & U32, proglist_proglist_VarTestStruct_e.pl_pl_Gc465214E502_size(EX_pl_pl_Gc465214E502.TH(m_f_D)), (EX_pl_pl_Gc465214E502.TH(m_f_D), EX_pl_pl_Gc465214E502.SZ(m_f_D)), EX_pl_pl_Gc465214E502.sizex(m_f_D, OB.ok_hok_f_DW(m_f_A, m_f_B, m_f_C, m_f_D, h))) :
    {ProgressiveTestStruct_e.Gc221EC01D83_sz3(EX_pl_u8.TH(m_f_A), EX_pl_u64.TH(m_f_B), EX_pl_Gc4ED9619F50.TH(m_f_C), O.padd(O.padd(O.padd(16, EX_pl_u8.SZ(m_f_A)), EX_pl_u64.SZ(m_f_B)), EX_pl_Gc4ED9619F50.SZ(m_f_C)), _) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), K.SZC(m_f_A, m_f_B, m_f_C, m_f_D)) : ProgressiveTestStruct_d.Gc221EC01D83 & U32}
  {==}

def rvalidCW(+m_f_A: EX_pl_u8.MW, +m_f_B: EX_pl_u64.MW, +m_f_C: EX_pl_Gc4ED9619F50.MW, +m_f_D: EX_pl_pl_Gc465214E502.MW, +h: {OB.OKTW(m_f_A, m_f_B, m_f_C, m_f_D) == True{} : Bool}) -> {ProgressiveTestStruct_e.Gc221EC01D83_valid(K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D)) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), True{}) : ProgressiveTestStruct_d.Gc221EC01D83 & Bool}:
  %Equal.sym(O.Words & Bool, proglist_uint8_e.pl_u8_valid(EX_pl_u8.TH(m_f_A)), (EX_pl_u8.TH(m_f_A), True{}), EX_pl_u8.validx(m_f_A, OB.ok_hok_f_AW(m_f_A, m_f_B, m_f_C, m_f_D, h))) :
    {ProgressiveTestStruct_e.Gc221EC01D83_va0(EX_pl_u64.TH(m_f_B), EX_pl_Gc4ED9619F50.TH(m_f_C), EX_pl_pl_Gc465214E502.TH(m_f_D), True{}, _) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), True{}) : ProgressiveTestStruct_d.Gc221EC01D83 & Bool}
  %Equal.sym(O.Words & Bool, proglist_uint64_e.pl_u64_valid(EX_pl_u64.TH(m_f_B)), (EX_pl_u64.TH(m_f_B), True{}), EX_pl_u64.validx(m_f_B, OB.ok_hok_f_BW(m_f_A, m_f_B, m_f_C, m_f_D, h))) :
    {ProgressiveTestStruct_e.Gc221EC01D83_va1(EX_pl_u8.TH(m_f_A), EX_pl_Gc4ED9619F50.TH(m_f_C), EX_pl_pl_Gc465214E502.TH(m_f_D), Bool.and(True{}, True{}), _) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), True{}) : ProgressiveTestStruct_d.Gc221EC01D83 & Bool}
  %Equal.sym(proglist_SmallTestStruct_d.pl_Gc4ED9619F50_Seq & Bool, proglist_SmallTestStruct_e.pl_Gc4ED9619F50_valid(EX_pl_Gc4ED9619F50.TH(m_f_C)), (EX_pl_Gc4ED9619F50.TH(m_f_C), True{}), EX_pl_Gc4ED9619F50.validx(m_f_C, OB.ok_hok_f_CW(m_f_A, m_f_B, m_f_C, m_f_D, h))) :
    {ProgressiveTestStruct_e.Gc221EC01D83_va2(EX_pl_u8.TH(m_f_A), EX_pl_u64.TH(m_f_B), EX_pl_pl_Gc465214E502.TH(m_f_D), Bool.and(Bool.and(True{}, True{}), True{}), _) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), True{}) : ProgressiveTestStruct_d.Gc221EC01D83 & Bool}
  %Equal.sym(proglist_proglist_VarTestStruct_d.pl_pl_Gc465214E502_Seq & Bool, proglist_proglist_VarTestStruct_e.pl_pl_Gc465214E502_valid(EX_pl_pl_Gc465214E502.TH(m_f_D)), (EX_pl_pl_Gc465214E502.TH(m_f_D), True{}), EX_pl_pl_Gc465214E502.validx(m_f_D, OB.ok_hok_f_DW(m_f_A, m_f_B, m_f_C, m_f_D, h))) :
    {ProgressiveTestStruct_e.Gc221EC01D83_va3(EX_pl_u8.TH(m_f_A), EX_pl_u64.TH(m_f_B), EX_pl_Gc4ED9619F50.TH(m_f_C), Bool.and(Bool.and(Bool.and(True{}, True{}), True{}), True{}), _) == (K.OBJC(m_f_A, m_f_B, m_f_C, m_f_D), True{}) : ProgressiveTestStruct_d.Gc221EC01D83 & Bool}
  {==}

law sizexO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {ProgressiveTestStruct_e.Gc221EC01D83_size(OB.TH(m)) == (OB.TH(m), OB.SZ(m)) : ProgressiveTestStruct_d.Gc221EC01D83 & U32}
def sizexO(m, hok):
  match m:
    case OB.MW{+m_f_A, +m_f_B, +m_f_C, +m_f_D}: sizeCW(m_f_A, m_f_B, m_f_C, m_f_D, hok)

law validxO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {ProgressiveTestStruct_e.Gc221EC01D83_valid(OB.TH(m)) == (OB.TH(m), True{}) : ProgressiveTestStruct_d.Gc221EC01D83 & Bool}
def validxO(m, hok):
  match m:
    case OB.MW{+m_f_A, +m_f_B, +m_f_C, +m_f_D}: rvalidCW(m_f_A, m_f_B, m_f_C, m_f_D, hok)
