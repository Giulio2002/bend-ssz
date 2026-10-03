import Base
import ../../../../../src/obj.bend as O
import ../../../../../types/Fulu_vec_bytevec_32_65536_encode_ssz_generated.bend as VB
import ../../../../../types/Fulu_list_Attestation_8_def_generated.bend as LA
import ../../../../../types/Fulu_list_Attestation_8_encode_ssz_generated.bend as LAE
import ../../../../../types/proglist_ProgressiveVarTestStruct_def_generated.bend as PP
import ../../../../../types/ProgressiveVarTestStruct_def_generated.bend as PV
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-3 probe: SSZ_CASE 1 Vector[Bytes32, 65536] valid of a 32-byte Words; 2 List[Attestation, 8] valid of a list claiming one absent element;
# 3 ProgressiveList[ProgressiveVarTestStruct] append at a claimed count of 2^32 - 1.

def vflag(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def aflag(label: String, pair: LA.l8_Attestation_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def pflag(label: String, pair: PP.pl_ProgressiveVarTestStruct_Seq & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ " ok=" ++ O.pick_str(ok))

def c1() -> IO(Unit): vflag("v65536_32bytes", VB.v65536_b32_valid(O.Words{Array.new(U32, 3n, 0), 32}))
def c2() -> IO(Unit): aflag("l8_absent_elem", LAE.l8_Attestation_valid(LA.l8_Attestation_Seq{LA.l8_Attestation_fill(0n), 1}))
def c3() -> IO(Unit): pflag("plvar_claim_max", PP.pl_ProgressiveVarTestStruct_append(PP.pl_ProgressiveVarTestStruct_Seq{PP.pl_ProgressiveVarTestStruct_fill(0n), 4294967295}, PV.ProgressiveVarTestStruct_default()))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case _: c3()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
