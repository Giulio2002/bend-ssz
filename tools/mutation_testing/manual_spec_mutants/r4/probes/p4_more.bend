import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/VarTestStruct_def_generated.bend as VtD
import ../../../../../types/proglist_VarTestStruct_def_generated.bend as PvD
import ../../../../../types/proglist_proglist_VarTestStruct_def_generated.bend as PpD
import ../../../../../types/ProgressiveTestStruct_def_generated.bend as PtD
import ../../../../../types/ProgressiveTestStruct_encode_ssz_generated.bend as PtE
import ../../../../../types/ProgressiveTestStruct_decode_ssz_generated.bend as PtR
import ../../../../../types/FuluPendingAttestation_def_generated.bend as PaD
import ../../../../../types/FuluPendingAttestation_encode_ssz_generated.bend as PaE
import ../../../../../types/FuluExecutionPayloadHeader_def_generated.bend as EhD
import ../../../../../types/FuluExecutionPayloadHeader_encode_ssz_generated.bend as EhE
import ../../../../../types/ComplexTestStruct_def_generated.bend as CtD
import ../../../../../types/ComplexTestStruct_decode_ssz_generated.bend as CtR
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-4 probe 2 (public API only). SSZ_CASE: 1 ProgressiveTestStruct with f_D = [[VarTestStruct{C = 256}]] (inner element invalid);
# 2 PendingAttestation with 2049 aggregation bits (> 2048); 3 ExecutionPayloadHeader with 33 bytes of extra_data (> 32);
# 4 ComplexTestStruct_decode_checked of a 1-word B.Buf claiming 2^32 - 1 bytes; 5 ProgressiveTestStruct_decode_checked, same buffer;
# 6 ComplexTestStruct_decode_checked of a 32-word B.Buf claiming 129 bytes; 7 ExecutionPayloadHeader default (control); 8 PendingAttestation default (control).

def show(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ " ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))
def ser_pt(label: String, pair: PtD.ProgressiveTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)
def ser_pa(label: String, pair: PaD.PendingAttestation & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)
def ser_eh(label: String, pair: EhD.ExecutionPayloadHeader & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)
def show_ct(label: String, pair: B.Buf & Maybe<&1, CtD.ComplexTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ " decoded=some")
    case None{}: IO.print(label ++ " decoded=none")
def show_pt(label: String, pair: B.Buf & Maybe<&1, PtD.ProgressiveTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ " decoded=some")
    case None{}: IO.print(label ++ " decoded=none")

def bad_var() -> VtD.VarTestStruct: VtD.VarTestStruct{0, O.Words{Array.new(U32, 0n, 0), 0}, 256}
def bad_inner() -> PvD.pl_VarTestStruct_Seq: PvD.pl_VarTestStruct_Seq{ALeaf{O.BSome{bad_var(), O.BNone{}}}, 1}
def bad_d() -> PpD.pl_pl_VarTestStruct_Seq: PpD.pl_pl_VarTestStruct_Seq{ALeaf{O.BSome{bad_inner(), O.BNone{}}}, 1}

def c1() -> IO(Unit): ser_pt("pts_bad_D", PtE.ProgressiveTestStruct_serialize(PtD.ProgressiveTestStruct_set_f_D(PtD.ProgressiveTestStruct_default(), bad_d())))
def c2() -> IO(Unit): ser_pa("pa_bad_bits", PaE.PendingAttestation_serialize(PaD.PendingAttestation_set_aggregation_bits(PaD.PendingAttestation_default(), O.Bits{Array.new(U32, 7n, 0), 2049})))
def c3() -> IO(Unit): ser_eh("eph_bad_extra", EhE.ExecutionPayloadHeader_serialize(EhD.ExecutionPayloadHeader_set_extra_data(EhD.ExecutionPayloadHeader_default(), O.Words{Array.new(U32, 4n, 0), 33})))
def c4() -> IO(Unit): show_ct("cts_dchk_4g", CtR.ComplexTestStruct_decode_checked(B.Buf{Array.new(U32, 0n, 0), 4294967295}, 4294967295))
def c5() -> IO(Unit): show_pt("pts_dchk_4g", PtR.ProgressiveTestStruct_decode_checked(B.Buf{Array.new(U32, 0n, 0), 4294967295}, 4294967295))
def c6() -> IO(Unit): show_ct("cts_dchk_129", CtR.ComplexTestStruct_decode_checked(B.Buf{Array.new(U32, 5n, 0), 129}, 129))
def c7() -> IO(Unit): ser_eh("eph_default", EhE.ExecutionPayloadHeader_serialize(EhD.ExecutionPayloadHeader_default()))
def c8() -> IO(Unit): ser_pa("pa_default", PaE.PendingAttestation_serialize(PaD.PendingAttestation_default()))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case 3: c3()
    case 4: c4()
    case 5: c5()
    case 6: c6()
    case 7: c7()
    case _: c8()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
