import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../types/FuluAttesterSlashing_def_generated.bend as SD
import ../../../../../types/FuluAttesterSlashing_encode_ssz_generated.bend as SE
import ../../../../../types/FuluIndexedAttestation_def_generated.bend as ID
import ../../../../../types/FuluAttestationData_def_generated.bend as AD
import ../../../../../types/FuluBytes96_def_generated.bend as B96
import ../../../../../types/FuluAttestation_def_generated.bend as TD
import ../../../../../types/FuluAttestation_encode_ssz_generated.bend as TE
import ../../../../../types/Fulu_bitlist_131072_def_generated.bend as BLD
import ../../../../../types/Fulu_bitvector_64_def_generated.bend as BVD
import ../../../../../types/FuluCheckpoint_def_generated.bend as CpD
import ../../../../../types/FuluCheckpoint_decode_ssz_generated.bend as CpR
import ../../../../../types/ComplexTestStruct_def_generated.bend as CtD
import ../../../../../types/ComplexTestStruct_encode_ssz_generated.bend as CtE
import ../../../../../types/VarTestStruct_def_generated.bend as VD
import ../../../../../types/VarTestStruct_encode_ssz_generated.bend as VE
import ../../../../../types/list_uint16_1024_def_generated.bend as L16
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-2 validity probe: X_serialize of objects built with the public record constructors (each is invalid except the controls), the
# checked decoder, and the default of a vector of variable-size elements. SSZ_CASE selects one line.

def ok_s(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ "=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))

def slash(label: String, pair: SD.AttesterSlashing & O.Encoded) -> IO(Unit):
  (o, e) = pair
  ok_s(label, e)
def att(label: String, pair: TD.Attestation & O.Encoded) -> IO(Unit):
  (o, e) = pair
  ok_s(label, e)

def bad_ia() -> ID.IndexedAttestation: ID.IndexedAttestation{O.Words{Array.new(U32, 0n, 0), 8}, AD.AttestationData_default(), B96.b96_default()}
def good_ia() -> O.Boxed<ID.IndexedAttestation>: ID.IndexedAttestation_bx_default()

def c1() -> IO(Unit): slash("slash_default_control", SE.AttesterSlashing_serialize(SD.AttesterSlashing_default()))
def c2() -> IO(Unit): slash("slash_absent_1", SE.AttesterSlashing_serialize(SD.AttesterSlashing{O.BNone{}, good_ia()}))
def c3() -> IO(Unit): slash("slash_absent_2", SE.AttesterSlashing_serialize(SD.AttesterSlashing{good_ia(), O.BNone{}}))
def c4() -> IO(Unit): slash("slash_bad_list_1", SE.AttesterSlashing_serialize(SD.AttesterSlashing{O.BSome{bad_ia(), O.BNone{}}, good_ia()}))
def c5() -> IO(Unit): slash("slash_bad_list_2", SE.AttesterSlashing_serialize(SD.AttesterSlashing{good_ia(), O.BSome{bad_ia(), O.BNone{}}}))
def c6() -> IO(Unit): att("att_default_control", TE.Attestation_serialize(TD.Attestation_default()))
def c7() -> IO(Unit): att("att_bad_bits", TE.Attestation_serialize(TD.Attestation{O.Bits{Array.new(U32, 0n, 0), 40}, AD.AttestationData_default(), B96.b96_default(), BVD.bv64_default()}))

def maybe_line(label: String, pair: B.Buf & Maybe<&1, CpD.Checkpoint>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")
def c8() -> IO(Unit): maybe_line("dchk_empty_40", CpR.Checkpoint_decode_checked(B.empty(), 40))
def c9() -> IO(Unit): maybe_line("dchk_alloc_40", CpR.Checkpoint_decode_checked(B.alloc(40), 40))
def c10() -> IO(Unit): maybe_line("dchk_alloc_40_size_41", CpR.Checkpoint_decode_checked(B.alloc(40), 41))
def c11() -> IO(Unit): maybe_line("dchk_alloc_40_size_2gib", CpR.Checkpoint_decode_checked(B.alloc(40), 2147483648))
def c12() -> IO(Unit): maybe_line("dchk_big_buf_40", CpR.Checkpoint_decode_checked(B.Buf{Array.new(U32, 1n, 0), 4294967295}, 40))
def ct_line(pair: CtD.ComplexTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: IO.print("complex_default_serialize_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))
def c13() -> IO(Unit): ct_line(CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_default()))

def vt(label: String, pair: VD.VarTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  ok_s(label, e)
def c14() -> IO(Unit): vt("vts_c_300", VE.VarTestStruct_serialize(VD.VarTestStruct{1, L16.l1024_u16_default(), 300}))
def c15() -> IO(Unit): vt("vts_c_7_control", VE.VarTestStruct_serialize(VD.VarTestStruct{1, L16.l1024_u16_default(), 7}))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case 3: c3()
    case 4: c4()
    case 5: c5()
    case 6: c6()
    case 7: c7()
    case 8: c8()
    case 9: c9()
    case 10: c10()
    case 11: c11()
    case 12: c12()
    case 14: c14()
    case 15: c15()
    case _: c13()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
