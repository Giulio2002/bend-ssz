import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/Fulu_list_bytevec_2048_4096_def_generated.bend as Cells
import ../../types/proglist_uint8_def_generated.bend as PlD
import ../../types/progbitlist_def_generated.bend as PbD
import ../../types/Fulu_bitlist_2048_def_generated.bend as B2048
import ../../types/FuluCheckpoint_def_generated.bend as CpD
import ../../types/FuluCheckpoint_decode_ssz_generated.bend as CpR
import ../../types/ComplexTestStruct_def_generated.bend as CtD
import ../../types/ComplexTestStruct_encode_ssz_generated.bend as CtE
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt regression probe: the cases of docs/CRASH_HUNT.md CH-01, CH-04, CH-05, CH-06 and CH-10 after their fixes.
# SSZ_CASE selects a case; each prints one line. tools/crash_hunt/regress.sh runs them all against regress_expected.txt.

def flag_line(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ "=" ++ O.pick_str(ok))

def bits_flag_line(label: String, pair: O.Bits & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print(label ++ "=" ++ O.pick_str(ok))

def cells2() -> O.Words: O.Words{Array.new(U32, 10n, 0), 4096}

# CH-01: a cell is exactly 2048 bytes; any other length is refused (it used to copy by the argument's length)
def case1() -> IO(Unit): flag_line("cell_set_empty", Cells.l4096_b2048_set(cells2(), 0, O.Words{Array.new(U32, 3n, 0), 0}))
def case2() -> IO(Unit): flag_line("cell_set_4096_at_1", Cells.l4096_b2048_set(cells2(), 1, O.Words{Array.new(U32, 10n, 4294967295), 4096}))
def case3() -> IO(Unit): flag_line("cell_set_64", Cells.l4096_b2048_set(cells2(), 0, O.Words{Array.new(U32, 5n, 4294967295), 64}))
def case4() -> IO(Unit): flag_line("cell_append_empty", Cells.l4096_b2048_append(cells2(), O.Words{Array.new(U32, 3n, 0), 0}))
def case5() -> IO(Unit): flag_line("cell_set_2048_control", Cells.l4096_b2048_set(cells2(), 0, O.Words{Array.new(U32, 9n, 7), 2048}))

# CH-04: a count of 2^32 - 1 elements is full: the append is refused (n + 1 used to wrap to 0)
def case6() -> IO(Unit): bits_flag_line("pbits_append_max", PbD.pbits_append(O.Bits{Array.new(U32, 1n, 0), 4294967295}, True{}))
def case7() -> IO(Unit): bits_flag_line("bits2048_append_max", B2048.bits2048_append(O.Bits{Array.new(U32, 1n, 0), 4294967295}, True{}))
def case8() -> IO(Unit): flag_line("pl_u8_append_max", PlD.pl_u8_append(O.Words{Array.new(U32, 4n, 0), 4294967295}, 7))

# CH-05, CH-06: the checked decoder refuses a window outside the buffer or at 2^31 bytes or more
def maybe_line(label: String, pair: B.Buf & Maybe<&1, CpD.Checkpoint>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")
def case9() -> IO(Unit): maybe_line("decode_checked_empty_buf_40", CpR.Checkpoint_decode_checked(B.empty(), 40))
def case10() -> IO(Unit): maybe_line("decode_checked_40_control", CpR.Checkpoint_decode_checked(B.alloc(40), 40))
def case11() -> IO(Unit): maybe_line("decode_checked_2gib", CpR.Checkpoint_decode_checked(B.alloc(40), 2147483648))

# CH-10: the default of a container with a vector of variable-size elements serializes to the spec's 100 bytes
def ct_line(pair: CtD.ComplexTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: IO.print("complex_default_serialize_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))
def case12() -> IO(Unit): ct_line(CtE.ComplexTestStruct_serialize(CtD.ComplexTestStruct_default()))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: case1()
    case 2: case2()
    case 3: case3()
    case 4: case4()
    case 5: case5()
    case 6: case6()
    case 7: case7()
    case 8: case8()
    case 9: case9()
    case 10: case10()
    case 11: case11()
    case _: case12()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
