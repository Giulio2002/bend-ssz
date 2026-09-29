import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/FuluCheckpoint_def_generated.bend as FuluCheckpoint_d
import ../../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../../types/Fulu_list_uint64_131072_encode_ssz_generated.bend as Fulu_list_uint64_131072_e
import ../../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
import ../../types/FuluIndexedAttestation_encode_ssz_generated.bend as FuluIndexedAttestation_e
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
import ./encx_recs.bend as ER
import ./vuwv_b96.bend as V_b96
import ./big_encx_l131072_u64.bend as EX_l131072_u64
import ./big_encx_IndexedAttestation.bend as K
import ./big_encx_IndexedAttestation_iface.bend as OB

# GENERATED (codegen/okw.py okw_companion). Do not edit.
# the size and validity passes on OKW (encodings below 2^31 bytes) of big_encx_IndexedAttestation_iface

def sizeCW(+m_attesting_indices: EX_l131072_u64.MW, +data: FuluAttestationData_d.AttestationData, +signature: FuluBytes96_d.Bytes96, +h: {OB.OKTW(m_attesting_indices, data, signature) == True{} : Bool}) -> {FuluIndexedAttestation_e.IndexedAttestation_size(K.OBJC(m_attesting_indices, data, signature)) == (K.OBJC(m_attesting_indices, data, signature), K.SZC(m_attesting_indices, data, signature)) : FuluIndexedAttestation_d.IndexedAttestation & U32}:
  %Equal.sym(O.Words & U32, Fulu_list_uint64_131072_e.l131072_u64_size(EX_l131072_u64.TH(m_attesting_indices)), (EX_l131072_u64.TH(m_attesting_indices), EX_l131072_u64.SZ(m_attesting_indices)), EX_l131072_u64.sizex(m_attesting_indices, OB.ok_hok_attesting_indicesW(m_attesting_indices, data, signature, h))) :
    {FuluIndexedAttestation_e.IndexedAttestation_sz0(data, signature, 228, _) == (K.OBJC(m_attesting_indices, data, signature), K.SZC(m_attesting_indices, data, signature)) : FuluIndexedAttestation_d.IndexedAttestation & U32}
  {==}

def rvalidCW(+m_attesting_indices: EX_l131072_u64.MW, +data: FuluAttestationData_d.AttestationData, +signature: FuluBytes96_d.Bytes96, +h: {OB.OKTW(m_attesting_indices, data, signature) == True{} : Bool}) -> {FuluIndexedAttestation_e.IndexedAttestation_valid(K.OBJC(m_attesting_indices, data, signature)) == (K.OBJC(m_attesting_indices, data, signature), True{}) : FuluIndexedAttestation_d.IndexedAttestation & Bool}:
  %Equal.sym(O.Words & Bool, Fulu_list_uint64_131072_e.l131072_u64_valid(EX_l131072_u64.TH(m_attesting_indices)), (EX_l131072_u64.TH(m_attesting_indices), True{}), EX_l131072_u64.validx(m_attesting_indices, OB.ok_hok_attesting_indicesW(m_attesting_indices, data, signature, h))) :
    {FuluIndexedAttestation_e.IndexedAttestation_va0(data, signature, True{}, _) == (K.OBJC(m_attesting_indices, data, signature), True{}) : FuluIndexedAttestation_d.IndexedAttestation & Bool}
  {==}

law sizexO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {FuluIndexedAttestation_e.IndexedAttestation_size(OB.TH(m)) == (OB.TH(m), OB.SZ(m)) : FuluIndexedAttestation_d.IndexedAttestation & U32}
def sizexO(m, hok):
  match m:
    case OB.MW{+m_attesting_indices, +data, +signature}: sizeCW(m_attesting_indices, data, signature, hok)

law validxO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {FuluIndexedAttestation_e.IndexedAttestation_valid(OB.TH(m)) == (OB.TH(m), True{}) : FuluIndexedAttestation_d.IndexedAttestation & Bool}
def validxO(m, hok):
  match m:
    case OB.MW{+m_attesting_indices, +data, +signature}: rvalidCW(m_attesting_indices, data, signature, hok)
