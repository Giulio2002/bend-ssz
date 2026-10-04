import Base
import ../../../src/buffer.bend as B
import ../../../src/obj.bend as O
import ../../../types/FuluExecutionPayload_decode_ssz_generated.bend as EP
import ../../../types/FuluBeaconState_decode_ssz_generated.bend as BS
import ../../../types/FuluExecutionPayload_def_generated.bend as EPd
import ../../../types/ProgressiveComplexTestStruct_def_generated.bend as PCd
import ../../../types/ProgressiveComplexTestStruct_decode_ssz_generated.bend as PC
import ../../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 6, probe T (build on agent/decode-amplification): the decode budget's bound and the O.* slice helper at edges.
#  SSZ_CASE 1, SSZ_ARG = size: prints ExecutionPayload_dcost, ProgressiveComplexTestStruct_dcost, BeaconState_dcost and O.dcost(size, 0)
#  SSZ_CASE 2, SSZ_ARG = n:    O.words_slice(Words{2 words, 8}, 0, n): the length of the result, or does not return (R5-02 edge)
#  SSZ_CASE 3, SSZ_ARG = budget: ExecutionPayload_decode_checked_budget of SSZ_INPUT (SSZ_SIZE bytes): DEC=1 or DEC=0
#  SSZ_CASE 4, SSZ_ARG = budget: ProgressiveComplexTestStruct_decode_checked_budget of SSZ_INPUT (SSZ_SIZE bytes): DEC=1 or DEC=0

def show(pair: O.Words & O.Words) -> IO(Unit):
  (a, b) = pair
  match b:
    case O.Words{ws, +n}: IO.print("done n=" ++ U32.show(n))

def costs(+s: U32) -> IO(Unit):
  IO.print("EP=" ++ U32.show(EP.ExecutionPayload_dcost(s)) ++ " PC=" ++ U32.show(PC.ProgressiveComplexTestStruct_dcost(s)) ++ " BS=" ++ U32.show(BS.BeaconState_dcost(s)) ++ " K0=" ++ U32.show(O.dcost(s, 0)))

def said_ep(pair: B.Buf & Maybe<&1, EPd.ExecutionPayload>) -> IO(Unit):
  (b, m) = pair
  match m:
    case None{}: IO.print("DEC=0")
    case Some{x}: IO.print("DEC=1")

def said_pc(pair: B.Buf & Maybe<&1, PCd.ProgressiveComplexTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case None{}: IO.print("DEC=0")
    case Some{x}: IO.print("DEC=1")

def dec(+c: U32, +size: U32, +budget: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +total) = pair
  match c:
    case 3: said_ep(EP.ExecutionPayload_decode_checked_budget(buf, size, budget))
    case _: said_pc(PC.ProgressiveComplexTestStruct_decode_checked_budget(buf, size, budget))

def go(+c: U32, +n: U32) -> IO(Unit):
  match c:
    case 1: costs(n)
    case 2: show(O.words_slice(O.Words{Array.new(U32, 1n, 7), 8}, 0, n))
    case _:
      do IO<Unit>:
        +size : U32 <- IOx.env_u32("SSZ_SIZE")
        input : B.Buf & U32 <- IOx.load()
        dec(c, size, n, input)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +n : U32 <- IOx.env_u32("SSZ_ARG")
    go(c, n)
