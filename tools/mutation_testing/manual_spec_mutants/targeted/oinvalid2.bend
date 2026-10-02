import Base
import ../../../../src/buffer.bend as B
import ../../../../src/obj.bend as O
import ../../../../types/FixedTestStruct_def_generated.bend as FixedTestStruct_d
import ../../../../types/FixedTestStruct_encode_ssz_generated.bend as FixedTestStruct_e
import ../../../../types/SmallTestStruct_def_generated.bend as SmallTestStruct_d
import ../../../../types/SmallTestStruct_encode_ssz_generated.bend as SmallTestStruct_e
import ../../../../types/SingleFieldTestStruct_def_generated.bend as SingleFieldTestStruct_d
import ../../../../types/SingleFieldTestStruct_encode_ssz_generated.bend as SingleFieldTestStruct_e
import ../../../../types/ProgressiveSingleFieldContainerTestStruct_def_generated.bend as ProgressiveSingleFieldContainerTestStruct_d
import ../../../../types/ProgressiveSingleFieldContainerTestStruct_encode_ssz_generated.bend as ProgressiveSingleFieldContainerTestStruct_e
import ../../../../types/vec_bool_5_encode_ssz_generated.bend as vec_bool_5_e
import ../../../../types/vec_bool_16_encode_ssz_generated.bend as vec_bool_16_e
import ../../../../types/proglist_bool_encode_ssz_generated.bend as proglist_bool_e
import ../../../../types/bitlist_5_encode_ssz_generated.bend as bitlist_5_e
import ../../../../types/bitvector_5_encode_ssz_generated.bend as bitvector_5_e
import ../../../../types/bitvector_5_def_generated.bend as bitvector_5_d

# Targeted invalid-object cases for the manual spec mutants that no proof and no decode-first corpus case reaches (tools/mutation_testing/manual_spec_mutants/targeted.py).
# Same idea as benchmarks/compact/oinvalid.bend: build a representable but invalid object with the raw record constructors and print whether the public
# checked encoder `<Name>_serialize` accepted it (1) or refused it (0). Every invalid case has a valid control.

def show(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ "=" ++ O.pick_str(ok))

def show_w(label: String, pair: O.Words & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def show_b(label: String, pair: O.Bits & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show(label, e)

def words(+n: Nat, +a: U32) -> Array<U32>:
  Array.set(U32, Array.new(U32, n, 0), 0, a)

def main() -> IO(Unit):
  do IO<Unit>:
    # b04/01: a Vector[boolean, 5] whose second byte is 2 (513 = 0x0201), and a clean one (257 = 0x0101)
    show_w("vecbool5_two", vec_bool_5_e.vec_bool_5_serialize(O.Words{words(2n, 513), 5}))
    show_w("vecbool5_ok", vec_bool_5_e.vec_bool_5_serialize(O.Words{words(2n, 257), 5}))
    show_w("vecbool16_two", vec_bool_16_e.vec_bool_16_serialize(O.Words{words(3n, 513), 16}))
    show_w("vecbool16_ok", vec_bool_16_e.vec_bool_16_serialize(O.Words{words(3n, 257), 16}))
    show_w("proglistbool_two", proglist_bool_e.proglist_bool_serialize(O.Words{words(2n, 513), 5}))
    show_w("proglistbool_ok", proglist_bool_e.proglist_bool_serialize(O.Words{words(2n, 257), 5}))
    # c02/05: FixedTestStruct with a uint8 field of 300
    show("fixed_300", FixedTestStruct_e.FixedTestStruct_serialize(FixedTestStruct_d.FixedTestStruct{300, O.U64{0, 0}, 0}))
    show("fixed_200", FixedTestStruct_e.FixedTestStruct_serialize(FixedTestStruct_d.FixedTestStruct{200, O.U64{0, 0}, 0}))
    # c06/03: SmallTestStruct with a uint16 field B of 70000
    show("small_b70000", SmallTestStruct_e.SmallTestStruct_serialize(SmallTestStruct_d.SmallTestStruct{1, 70000}))
    show("small_ok", SmallTestStruct_e.SmallTestStruct_serialize(SmallTestStruct_d.SmallTestStruct{1, 60000}))
    # c06/04: SingleFieldTestStruct with a uint8 of 300
    show("single_300", SingleFieldTestStruct_e.SingleFieldTestStruct_serialize(SingleFieldTestStruct_d.SingleFieldTestStruct{300}))
    show("single_200", SingleFieldTestStruct_e.SingleFieldTestStruct_serialize(SingleFieldTestStruct_d.SingleFieldTestStruct{200}))
    # c06/05: ProgressiveSingleFieldContainerTestStruct with a uint8 of 300
    show("psingle_300", ProgressiveSingleFieldContainerTestStruct_e.ProgressiveSingleFieldContainerTestStruct_serialize(ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct{300}))
    show("psingle_200", ProgressiveSingleFieldContainerTestStruct_e.ProgressiveSingleFieldContainerTestStruct_serialize(ProgressiveSingleFieldContainerTestStruct_d.ProgressiveSingleFieldContainerTestStruct{200}))
    # bv03/02 (bits_above_zero, entry for 5 bits): a Bitlist[5] of 5 bits whose bit 5 (the stray bit before the delimiter) is set, and a clean one
    show_b("bitlist5_stray", bitlist_5_e.bitlist_5_serialize(O.Bits{words(1n, 32), 5}))
    show_b("bitlist5_ok", bitlist_5_e.bitlist_5_serialize(O.Bits{words(1n, 31), 5}))
    # s01/01: bits_nbytes(2^32 - 1) must be 2^29
    IO.print("nbytes_top=" ++ O.pick_str(U32.is_eq(O.bits_nbytes(4294967295), 536870912)))
