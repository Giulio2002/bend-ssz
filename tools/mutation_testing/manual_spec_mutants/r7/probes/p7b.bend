import Base
import ../../../../../src/buffer.bend as B
import ../../../../../types/FuluExecutionPayload_def_generated.bend as EpD
import ../../../../../types/FuluExecutionPayload_decode_ssz_generated.bend as EpR
import ../../../../../types/FuluTransaction_decode_ssz_generated.bend as TxR
import ../../../../../types/FuluBeaconState_decode_ssz_generated.bend as BsR
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-7 probe b (run on the decode-budget branch 5c1f48b93): the public X_dcost(size) bound that X_decode_checked_budget compares with the budget.
# A correct bound is monotone in the size and saturates at 2^32 - 1; a wrapped bound is small for a huge size (a small budget then admits it).
# SSZ_CASE:
#  1 ExecutionPayload_dcost(4096)          (K = 40: 513 * 40 + 524288 = 544808)
#  2 ExecutionPayload_dcost(2^31)          (saturated: 4294967295)
#  3 ExecutionPayload_dcost(858980000)     (w = 107372501 > floor((2^32 - 1 - 524288) / 40) = 107361075: saturated)
#  4 ExecutionPayload_dcost(858900000)     (w = 107362501: saturated, a w just past the bound)
#  5 Transaction_dcost(4294967264)         (K = 5, NMAX: w = 536870909, 5 w > 2^32 - 1 - 524288: saturated)
#  6 BeaconState_dcost(4294967264)         (K = 7: saturated)
#  7 ExecutionPayload_decode_checked_budget(B.Buf{1 word, 2^31}, 2^31, 2200000000) is None (refused by the bound)

def show(label: String, +x: U32) -> IO(Unit): IO.print(label ++ " " ++ U32.show(x))

def is_none(pair: B.Buf & Maybe<&1, EpD.ExecutionPayload>) -> String:
  (b, m) = pair
  match m:
    case Some{v}: "some"
    case None{}: "none"

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: show("c1 ep 4096", EpR.ExecutionPayload_dcost(4096))
    case 2: show("c2 ep 2^31", EpR.ExecutionPayload_dcost(2147483648))
    case 3: show("c3 ep 858980000", EpR.ExecutionPayload_dcost(858980000))
    case 4: show("c4 ep 858900000", EpR.ExecutionPayload_dcost(858900000))
    case 5: show("c5 tx nmax", TxR.Transaction_dcost(4294967264))
    case 6: show("c6 bs nmax", BsR.BeaconState_dcost(4294967264))
    case _: IO.print("c7 ep budget " ++ is_none(EpR.ExecutionPayload_decode_checked_budget(B.Buf{Array.new(U32, 0n, 0), 2147483648}, 2147483648, 2200000000)))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
