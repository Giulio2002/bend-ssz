import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../types/uint256_def_generated.bend as UD
import ../../../../../types/uint256_decode_ssz_generated.bend as UR
import ../../../../../types/bitvector_9_def_generated.bend as VD
import ../../../../../types/bitvector_9_decode_ssz_generated.bend as VR
import ../../../../../types/CompatibleUnionABCA_def_generated.bend as CD
import ../../../../../types/CompatibleUnionABCA_decode_ssz_generated.bend as CR
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-3 probe: the checked decoders X_decode_checked (public) of uint256, bitvector_9 and CompatibleUnionABCA, driven only with
# B.alloc buffers (honest) and the public constructor B.Buf{ws, size} (a lying size field). SSZ_CASE: 1 uint256 honest 32; 2 uint256
# Buf of 1 word claiming 32; 3 uint256 Buf of 4 words claiming 32; 4 bitvector_9 honest alloc(2) window 2; 5 bitvector_9 honest alloc(3) window 2;
# 6 bitvector_9 Buf of 1 word claiming 2; 7 union honest alloc(2) window 2 (all zero bytes: selector 0 is invalid: none); 8 uint256 alloc(40) window 32;
# 9 bitvector_9 alloc(2) window 3 (window past the buffer); 10 uint256 alloc(32) window 33.

def show_u(label: String, pair: B.Buf & Maybe<&1, UD.Uint256>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")

def show_v(label: String, pair: B.Buf & Maybe<&1, VD.Bitvector9>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{+v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")

def show_c(label: String, pair: B.Buf & Maybe<&1, CD.CompatibleUnionABCA>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")

def c1() -> IO(Unit): show_u("u256_honest_32", UR.uint256_decode_checked(B.alloc(32), 32))
def c2() -> IO(Unit): show_u("u256_lying_1word", UR.uint256_decode_checked(B.Buf{Array.new(U32, 0n, 0), 32}, 32))
def c3() -> IO(Unit): show_u("u256_lying_4words", UR.uint256_decode_checked(B.Buf{Array.new(U32, 2n, 0), 32}, 32))
def c4() -> IO(Unit): show_v("bv9_honest_2", VR.bitvector_9_decode_checked(B.alloc(2), 2))
def c5() -> IO(Unit): show_v("bv9_alloc3_window2", VR.bitvector_9_decode_checked(B.alloc(3), 2))
def c6() -> IO(Unit): show_v("bv9_lying_1word", VR.bitvector_9_decode_checked(B.Buf{Array.new(U32, 0n, 0), 2}, 2))
def c7() -> IO(Unit): show_c("union_zero_2", CR.CompatibleUnionABCA_decode_checked(B.alloc(2), 2))
def c8() -> IO(Unit): show_u("u256_alloc40_window32", UR.uint256_decode_checked(B.alloc(40), 32))
def c9() -> IO(Unit): show_v("bv9_alloc2_window3", VR.bitvector_9_decode_checked(B.alloc(2), 3))
def c10() -> IO(Unit): show_u("u256_alloc32_window33", UR.uint256_decode_checked(B.alloc(32), 33))

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
    case _: c10()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
