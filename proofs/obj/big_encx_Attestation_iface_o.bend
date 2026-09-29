import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/Fulu_bitvector_64_def_generated.bend as Fulu_bitvector_64_d
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/FuluCheckpoint_def_generated.bend as FuluCheckpoint_d
import ../../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../../types/Fulu_bitlist_131072_encode_ssz_generated.bend as Fulu_bitlist_131072_e
import ../../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ../../types/FuluAttestation_encode_ssz_generated.bend as FuluAttestation_e
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
import ./vuwv_bv64.bend as V_bv64
import ./big_encx_bits131072.bend as EX_bits131072
import ./big_encx_Attestation.bend as K
import ./big_encx_Attestation_iface.bend as OB

# GENERATED (codegen/okw.py okw_companion). Do not edit.
# the size and validity passes on OKW (encodings below 2^31 bytes) of big_encx_Attestation_iface

def sizeCW(+m_aggregation_bits: EX_bits131072.MB, +data: FuluAttestationData_d.AttestationData, +signature: FuluBytes96_d.Bytes96, +committee_bits: Fulu_bitvector_64_d.Bitvector64, +h: {OB.OKTW(m_aggregation_bits, data, signature, committee_bits) == True{} : Bool}) -> {FuluAttestation_e.Attestation_size(K.OBJC(m_aggregation_bits, data, signature, committee_bits)) == (K.OBJC(m_aggregation_bits, data, signature, committee_bits), K.SZC(m_aggregation_bits, data, signature, committee_bits)) : FuluAttestation_d.Attestation & U32}:
  %Equal.sym(O.Bits & U32, Fulu_bitlist_131072_e.bits131072_size(EX_bits131072.TH(m_aggregation_bits)), (EX_bits131072.TH(m_aggregation_bits), EX_bits131072.SZ(m_aggregation_bits)), EX_bits131072.sizex(m_aggregation_bits, OB.ok_hok_aggregation_bitsW(m_aggregation_bits, data, signature, committee_bits, h))) :
    {FuluAttestation_e.Attestation_sz0(data, signature, committee_bits, 236, _) == (K.OBJC(m_aggregation_bits, data, signature, committee_bits), K.SZC(m_aggregation_bits, data, signature, committee_bits)) : FuluAttestation_d.Attestation & U32}
  {==}

def rvalidCW(+m_aggregation_bits: EX_bits131072.MB, +data: FuluAttestationData_d.AttestationData, +signature: FuluBytes96_d.Bytes96, +committee_bits: Fulu_bitvector_64_d.Bitvector64, +h: {OB.OKTW(m_aggregation_bits, data, signature, committee_bits) == True{} : Bool}) -> {FuluAttestation_e.Attestation_valid(K.OBJC(m_aggregation_bits, data, signature, committee_bits)) == (K.OBJC(m_aggregation_bits, data, signature, committee_bits), True{}) : FuluAttestation_d.Attestation & Bool}:
  %Equal.sym(O.Bits & Bool, Fulu_bitlist_131072_e.bits131072_valid(EX_bits131072.TH(m_aggregation_bits)), (EX_bits131072.TH(m_aggregation_bits), True{}), EX_bits131072.validx(m_aggregation_bits, OB.ok_hok_aggregation_bitsW(m_aggregation_bits, data, signature, committee_bits, h))) :
    {FuluAttestation_e.Attestation_va0(data, signature, committee_bits, True{}, _) == (K.OBJC(m_aggregation_bits, data, signature, committee_bits), True{}) : FuluAttestation_d.Attestation & Bool}
  {==}

law sizexO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {FuluAttestation_e.Attestation_size(OB.TH(m)) == (OB.TH(m), OB.SZ(m)) : FuluAttestation_d.Attestation & U32}
def sizexO(m, hok):
  match m:
    case OB.MW{+m_aggregation_bits, +data, +signature, +committee_bits}: sizeCW(m_aggregation_bits, data, signature, committee_bits, hok)

law validxO:
  for +m: OB.MW
  for +hok: {OB.OKW(m) == True{} : Bool}
  {FuluAttestation_e.Attestation_valid(OB.TH(m)) == (OB.TH(m), True{}) : FuluAttestation_d.Attestation & Bool}
def validxO(m, hok):
  match m:
    case OB.MW{+m_aggregation_bits, +data, +signature, +committee_bits}: rvalidCW(m_aggregation_bits, data, signature, committee_bits, hok)
