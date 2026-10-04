import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../types/FuluCheckpoint_def_generated.bend as CPD
import ../../../../../types/FuluCheckpoint_decode_ssz_generated.bend as CP
import ../../../../../types/FuluExecutionPayload_decode_ssz_generated.bend as EP
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-8 probe c: the decode budget (public X_dcost and X_decode_checked_budget only).
# SSZ_CASE:
#  1 Checkpoint_dcost(0), Checkpoint_dcost(40), Checkpoint_dcost(4096) (K = 0: the constant 524288)        (r8-f01/10)
#  2 Checkpoint_decode_checked_budget of 40 zero bytes with budgets 524288 and 2^32 - 1: Some / None        (r8-f01/10)
#  3 ExecutionPayload_dcost(855999992) (w = 107000000, K = 40: 4280524288, not saturated)                     (r8-f01/12)

def mstr(pair: B.Buf & Maybe<&1, CPD.Checkpoint>) -> String:
  (b, m) = pair
  match m:
    case Some{v}: "Some"
    case None{}: "None"

def zbuf() -> B.Buf: B.Buf{Array.new(U32, 4n, 0), 40}

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: IO.print("c1 dcost " ++ U32.show(CP.Checkpoint_dcost(0)) ++ " " ++ U32.show(CP.Checkpoint_dcost(40)) ++ " " ++ U32.show(CP.Checkpoint_dcost(4096)))
    case 2: IO.print("c2 budget524288=" ++ mstr(CP.Checkpoint_decode_checked_budget(zbuf(), 40, 524288)) ++ " budgetmax=" ++ mstr(CP.Checkpoint_decode_checked_budget(zbuf(), 40, 4294967295)))
    case _: IO.print("c3 EP dcost " ++ U32.show(EP.ExecutionPayload_dcost(855999992)))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
