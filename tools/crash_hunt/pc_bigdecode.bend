import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/proglist_uint8_def_generated.bend as PlD
import ../../types/proglist_uint8_decode_ssz_generated.bend as PlR
import ../../types/progbitlist_def_generated.bend as PbD
import ../../types/progbitlist_decode_ssz_generated.bend as PbR
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt probe C: decode of inputs whose size is near the U32 limits. The input buffer is built directly
# (an all-constant word array, nothing read from a file). SSZ_CASE: 1 byte list, 2 bit list, 3 bit list then append.
# SSZ_ARG: the size in bytes; SSZ_FILL: the word every input word is set to.

def words_line(pair: B.Buf & Maybe<&1, O.Words>) -> IO(Unit):
  (b, m) = pair
  match m:
    case None{}: IO.print("decode=none")
    case Some{w}: len_line(O.words_len(w))
def len_line(pair: O.Words & U32) -> IO(Unit):
  (w, +n) = pair
  IO.print("decode=some len=" ++ U32.show(n))

def case1(+size: U32, +depth: Nat, +fill: U32) -> IO(Unit): words_line(PlR.proglist_uint8_decode(B.Buf{Array.new(U32, depth, fill), size}, size))

def bits_line(pair: B.Buf & Maybe<&1, O.Bits>) -> IO(Unit):
  (b, m) = pair
  match m:
    case None{}: IO.print("decode=none")
    case Some{o}: bits_len_line(O.bits_len(o))
def bits_len_line(pair: O.Bits & U32) -> IO(Unit):
  (o, +n) = pair
  IO.print("decode=some bits=" ++ U32.show(n))

def case2(+size: U32, +depth: Nat, +fill: U32) -> IO(Unit): bits_line(PbR.progbitlist_decode(B.Buf{Array.new(U32, depth, fill), size}, size))

def push_line(pair: O.Bits & Bool) -> IO(Unit):
  (o, ok) = pair
  match o:
    case O.Bits{ws, +k}: IO.print("append_ok=" ++ O.pick_str(ok) ++ " bits_after=" ++ U32.show(k))
def after_decode(pair: B.Buf & Maybe<&1, O.Bits>) -> IO(Unit):
  (b, m) = pair
  match m:
    case None{}: IO.print("decode=none")
    case Some{o}: push_line(PbD.pbits_append(o, True{}))
def case3(+size: U32, +depth: Nat, +fill: U32) -> IO(Unit): after_decode(PbR.progbitlist_decode(B.Buf{Array.new(U32, depth, fill), size}, size))

def dispatch(+c: U32, +size: U32, +depth: U32, +fill: U32) -> IO(Unit):
  match c:
    case 1: case1(size, U32.to_nat(depth), fill)
    case 2: case2(size, U32.to_nat(depth), fill)
    case _: case3(size, U32.to_nat(depth), fill)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +size : U32 <- IOx.env_u32("SSZ_ARG")
    +depth : U32 <- IOx.env_u32("SSZ_DEPTH")
    +fill : U32 <- IOx.env_u32("SSZ_FILL")
    dispatch(c, size, depth, fill)
