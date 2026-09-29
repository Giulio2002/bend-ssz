import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/FuluBeaconBlock_def_generated.bend as FuluBeaconBlock_d
import ../../types/FuluBeaconBlock_encode_ssz_generated.bend as FuluBeaconBlock_e
import ../../types/FuluSignedBeaconBlock_def_generated.bend as FuluSignedBeaconBlock_d
import ../../types/FuluSignedBeaconBlock_encode_ssz_generated.bend as FuluSignedBeaconBlock_e
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/codec.bend as Codec
import ../../spec/layout.bend as Layout
import ../../spec/primitives.bend as SP
import ../../spec/fulu_schemas.bend as Spec
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
import ./vuwv_b96.bend as V_b96
import ./big_encx_BeaconBlock_iface.bend as EC_BeaconBlock
import ./big_encx_BeaconBlock_iface_o.bend as EC_BeaconBlocko
import ./big_encx_SignedBeaconBlock.bend as K
import ./big_encx_SignedBeaconBlock_iface.bend as OB

# GENERATED (codegen/okw.py okw_companion). Do not edit.
# the size and validity passes on OKW (encodings below 2^31 bytes) of big_encx_SignedBeaconBlock_iface

def sizeCW(+m_message: EC_BeaconBlock.MW, +signature: FuluBytes96_d.Bytes96, +h: {OB.OKTW(m_message, signature) == True{} : Bool}) -> {FuluSignedBeaconBlock_e.SignedBeaconBlock_size(K.OBJC(m_message, signature)) == (K.OBJC(m_message, signature), K.SZC(m_message, signature)) : FuluSignedBeaconBlock_d.SignedBeaconBlock & U32}:
  %Equal.sym(FuluBeaconBlock_d.BeaconBlock & U32, FuluBeaconBlock_e.BeaconBlock_size(EC_BeaconBlock.TH(m_message)), (EC_BeaconBlock.TH(m_message), EC_BeaconBlock.SZ(m_message)), EC_BeaconBlocko.sizexO(m_message, OB.ok_hok_messageW(m_message, signature, h))) :
    {FuluSignedBeaconBlock_e.SignedBeaconBlock_sz0(signature, 100, _) == (K.OBJC(m_message, signature), K.SZC(m_message, signature)) : FuluSignedBeaconBlock_d.SignedBeaconBlock & U32}
  {==}

def rvalidCW(+m_message: EC_BeaconBlock.MW, +signature: FuluBytes96_d.Bytes96, +h: {OB.OKTW(m_message, signature) == True{} : Bool}) -> {FuluSignedBeaconBlock_e.SignedBeaconBlock_valid(K.OBJC(m_message, signature)) == (K.OBJC(m_message, signature), True{}) : FuluSignedBeaconBlock_d.SignedBeaconBlock & Bool}:
  %Equal.sym(FuluBeaconBlock_d.BeaconBlock & Bool, FuluBeaconBlock_e.BeaconBlock_valid(EC_BeaconBlock.TH(m_message)), (EC_BeaconBlock.TH(m_message), True{}), EC_BeaconBlocko.validxO(m_message, OB.ok_hok_messageW(m_message, signature, h))) :
    {FuluSignedBeaconBlock_e.SignedBeaconBlock_va0(signature, True{}, _) == (K.OBJC(m_message, signature), True{}) : FuluSignedBeaconBlock_d.SignedBeaconBlock & Bool}
  {==}

law sizexO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {FuluSignedBeaconBlock_e.SignedBeaconBlock_size(OB.TH(m)) == (OB.TH(m), OB.SZ(m)) : FuluSignedBeaconBlock_d.SignedBeaconBlock & U32}
def sizexO(m, hok):
  match m:
    case OB.MW{+m_message, +signature}: sizeCW(m_message, signature, hok)

law validxO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {FuluSignedBeaconBlock_e.SignedBeaconBlock_valid(OB.TH(m)) == (OB.TH(m), True{}) : FuluSignedBeaconBlock_d.SignedBeaconBlock & Bool}
def validxO(m, hok):
  match m:
    case OB.MW{+m_message, +signature}: rvalidCW(m_message, signature, hok)
