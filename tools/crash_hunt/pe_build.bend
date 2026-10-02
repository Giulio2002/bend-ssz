import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/Fulu_list_Attestation_8_def_generated.bend as LD
import ../../types/Fulu_list_Attestation_8_decode_ssz_generated.bend as LR
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt probe E: the unchecked reader (`_read` / `_build`, the half of decode that runs after `_ok`) on 4 hostile bytes.
# SSZ_ARG is the first (and only) 32-bit word: the offset table of a List[Attestation, 8] read without validation.

def line(pair: B.Buf & LD.l8_Attestation_Seq) -> IO(Unit):
  (b, o) = pair
  match o:
    case LD.l8_Attestation_Seq{items, +n}: IO.print("read_count=" ++ U32.show(n))

def main() -> IO(Unit):
  do IO<Unit>:
    +first : U32 <- IOx.env_u32("SSZ_ARG")
    line(LR.l8_Attestation_read(B.Buf{Array.set(U32, Array.new(U32, 1n, 0), 0, first), 4}, 0, 4))
