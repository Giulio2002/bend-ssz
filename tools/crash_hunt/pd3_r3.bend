import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../benchmarks/compact/objio.bend as IOx
import ../../types/FuluBeaconState_decode_ssz_generated.bend as X0
import ../../types/FuluBeaconState_def_generated.bend as D0
import ../../types/FuluBeaconBlockBody_decode_ssz_generated.bend as X1
import ../../types/FuluBeaconBlockBody_def_generated.bend as D1
import ../../types/FuluSignedBeaconBlock_decode_ssz_generated.bend as X2
import ../../types/FuluSignedBeaconBlock_def_generated.bend as D2
import ../../types/FuluExecutionPayload_decode_ssz_generated.bend as X3
import ../../types/FuluExecutionPayload_def_generated.bend as D3
import ../../types/FuluDataColumnSidecar_decode_ssz_generated.bend as X4
import ../../types/FuluDataColumnSidecar_def_generated.bend as D4
import ../../types/FuluLightClientUpdate_decode_ssz_generated.bend as X5
import ../../types/FuluLightClientUpdate_def_generated.bend as D5
import ../../types/ProgressiveTestStruct_decode_ssz_generated.bend as X6
import ../../types/ProgressiveTestStruct_def_generated.bend as D6
import ../../types/CompatibleUnionABCA_decode_ssz_generated.bend as X7
import ../../types/CompatibleUnionABCA_def_generated.bend as D7
import ../../types/FuluCheckpoint_decode_ssz_generated.bend as X8
import ../../types/FuluCheckpoint_def_generated.bend as D8
import ../../types/FuluValidator_decode_ssz_generated.bend as X9
import ../../types/FuluValidator_def_generated.bend as D9

# Crash hunt round 3, probe D: decode_checked of a hand-built B.Buf that claims SSZ_ARG bytes over a 2-word array, window = the claim and claim - 1.
# SSZ_CASE selects the name (order of the imports). Must answer none: the window is not in the words the array holds (R2-04).

def r0(label: String, pair: B.Buf & Maybe<&1, D0.BeaconState>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("BeaconState " ++ label ++ " some")
    case None{}: IO.print("BeaconState " ++ label ++ " none")
def c0(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r0("claim", X0.BeaconState_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r0("claim-1", X0.BeaconState_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r1(label: String, pair: B.Buf & Maybe<&1, D1.BeaconBlockBody>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("BeaconBlockBody " ++ label ++ " some")
    case None{}: IO.print("BeaconBlockBody " ++ label ++ " none")
def c1(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r1("claim", X1.BeaconBlockBody_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r1("claim-1", X1.BeaconBlockBody_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r2(label: String, pair: B.Buf & Maybe<&1, D2.SignedBeaconBlock>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("SignedBeaconBlock " ++ label ++ " some")
    case None{}: IO.print("SignedBeaconBlock " ++ label ++ " none")
def c2(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r2("claim", X2.SignedBeaconBlock_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r2("claim-1", X2.SignedBeaconBlock_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r3(label: String, pair: B.Buf & Maybe<&1, D3.ExecutionPayload>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("ExecutionPayload " ++ label ++ " some")
    case None{}: IO.print("ExecutionPayload " ++ label ++ " none")
def c3(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r3("claim", X3.ExecutionPayload_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r3("claim-1", X3.ExecutionPayload_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r4(label: String, pair: B.Buf & Maybe<&1, D4.DataColumnSidecar>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("DataColumnSidecar " ++ label ++ " some")
    case None{}: IO.print("DataColumnSidecar " ++ label ++ " none")
def c4(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r4("claim", X4.DataColumnSidecar_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r4("claim-1", X4.DataColumnSidecar_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r5(label: String, pair: B.Buf & Maybe<&1, D5.LightClientUpdate>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("LightClientUpdate " ++ label ++ " some")
    case None{}: IO.print("LightClientUpdate " ++ label ++ " none")
def c5(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r5("claim", X5.LightClientUpdate_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r5("claim-1", X5.LightClientUpdate_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r6(label: String, pair: B.Buf & Maybe<&1, D6.ProgressiveTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("ProgressiveTestStruct " ++ label ++ " some")
    case None{}: IO.print("ProgressiveTestStruct " ++ label ++ " none")
def c6(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r6("claim", X6.ProgressiveTestStruct_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r6("claim-1", X6.ProgressiveTestStruct_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r7(label: String, pair: B.Buf & Maybe<&1, D7.CompatibleUnionABCA>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("CompatibleUnionABCA " ++ label ++ " some")
    case None{}: IO.print("CompatibleUnionABCA " ++ label ++ " none")
def c7(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r7("claim", X7.CompatibleUnionABCA_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r7("claim-1", X7.CompatibleUnionABCA_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r8(label: String, pair: B.Buf & Maybe<&1, D8.Checkpoint>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("Checkpoint " ++ label ++ " some")
    case None{}: IO.print("Checkpoint " ++ label ++ " none")
def c8(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r8("claim", X8.Checkpoint_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r8("claim-1", X8.Checkpoint_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def r9(label: String, pair: B.Buf & Maybe<&1, D9.Validator>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{x}: IO.print("Validator " ++ label ++ " some")
    case None{}: IO.print("Validator " ++ label ++ " none")
def c9(+n: U32) -> IO(Unit):
  do IO<Unit>:
    r9("claim", X9.Validator_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, n))
    r9("claim-1", X9.Validator_decode_checked(B.Buf{Array.new(U32, 1n, 0), n}, (n - 1 : U32)))

def dispatch(+c: U32, +a: U32) -> IO(Unit):
  match c:
    case 0: c0(a)
    case 1: c1(a)
    case 2: c2(a)
    case 3: c3(a)
    case 4: c4(a)
    case 5: c5(a)
    case 6: c6(a)
    case 7: c7(a)
    case 8: c8(a)
    case _: c9(a)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    dispatch(c, a)
