import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/ProgressiveTestStruct_def_generated.bend as PtD
import ../../../../../types/ProgressiveTestStruct_encode_ssz_generated.bend as PtE
import ../../../../../types/ProgressiveTestStruct_decode_ssz_generated.bend as PtR
import ../../../../../types/ProgressiveComplexTestStruct_def_generated.bend as PcD
import ../../../../../types/ProgressiveComplexTestStruct_encode_ssz_generated.bend as PcE
import ../../../../../types/ProgressiveComplexTestStruct_decode_ssz_generated.bend as PcR
import ../../../../../types/ProgressiveSingleListContainerTestStruct_def_generated.bend as SlD
import ../../../../../types/CompatibleUnionBC_def_generated.bend as UbD
import ../../../../../types/CompatibleUnionBC_encode_ssz_generated.bend as UbE
import ../../../../../types/CompatibleUnionBC_decode_ssz_generated.bend as UbR
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-5 probe c: X_decode of byte strings (B.Buf{words, size}) that reach the round-5 decode faults; a decoded value is re-serialized.
# SSZ_CASE (ProgressiveTestStruct: 4 offsets o0..o3; f_C = ProgressiveList[SmallTestStruct]; f_D = ProgressiveList[ProgressiveList[VarTestStruct]]):
#  1 offsets 16,16,16,16, size 16 (every field empty: valid)
#  2 offsets 16,16,20,16, size 20, bytes 16..19 = 4 (o3 < o2: invalid)
#  3 offsets 16,16,16,20, size 24, f_C = [SmallTestStruct{1, 2}], f_D = [[]] (valid)
#  4 offsets 16,16,16,16, size 21, f_D's first offset 5 (not a multiple of 4: invalid)
#  5 offsets 16,16,16,16, size 24, f_D = [[], []] (offsets 8, 8: valid)
#  6 offsets 16,16,16,18, size 18 (f_C of 2 bytes: not a multiple of 4: invalid)
#  7 ProgressiveComplexTestStruct default, serialized then decoded (valid)
#  8 the same bytes with byte 29 (f_C's delimiter byte 0x01) cleared (a progressive bitlist without delimiter: invalid)
#  9 CompatibleUnionBC arm 0 (default payload) serialized then decoded (valid)
# 10 the same bytes with the selector byte 2 replaced by 1 (no such selector: invalid)

def pick_n(label: String, x: Bool, b: B.Buf) -> IO(Unit):
  match b:
    case B.Buf{ws, +n}: IO.print(label ++ " decoded=some reser_ok=" ++ O.pick_str(x) ++ " size=" ++ U32.show(n))

def pick_ok(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{x, b}: pick_n(label, x, b)

def pt_ser(label: String, pair: PtD.ProgressiveTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  pick_ok(label, e)
def show_pt(label: String, pair: B.Buf & Maybe<&1, PtD.ProgressiveTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: pt_ser(label, PtE.ProgressiveTestStruct_serialize(v))
    case None{}: IO.print(label ++ " decoded=none")

def pc_ser(label: String, pair: PcD.ProgressiveComplexTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  pick_ok(label, e)
def show_pc(label: String, pair: B.Buf & Maybe<&1, PcD.ProgressiveComplexTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: pc_ser(label, PcE.ProgressiveComplexTestStruct_serialize(v))
    case None{}: IO.print(label ++ " decoded=none")

def ub_ser(label: String, pair: UbD.CompatibleUnionBC & O.Encoded) -> IO(Unit):
  (o, e) = pair
  pick_ok(label, e)
def show_ub(label: String, pair: B.Buf & Maybe<&1, UbD.CompatibleUnionBC>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: ub_ser(label, UbE.CompatibleUnionBC_serialize(v))
    case None{}: IO.print(label ++ " decoded=none")

# 16 words of storage, the first words given
def w6(+a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32) -> Array<U32>:
  Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, a), 1, b), 2, c), 3, d), 4, e), 5, f)
def buf6(+n: U32, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32) -> B.Buf: B.Buf{w6(a, b, c, d, e, f), n}

def pc_bytes() -> B.Buf: O.ser_out(Pair.snd(PcD.ProgressiveComplexTestStruct, O.Encoded, PcE.ProgressiveComplexTestStruct_serialize(PcD.ProgressiveComplexTestStruct_default())))
def ub_bytes() -> B.Buf: O.ser_out(Pair.snd(UbD.CompatibleUnionBC, O.Encoded, UbE.CompatibleUnionBC_serialize(UbD.CompatibleUnionBC_c0{SlD.ProgressiveSingleListContainerTestStruct_default()})))

def and_at(+i: U32, +m: U32, pair: Array<U32> & U32) -> Array<U32>:
  (a, +w) = pair
  Array.set(U32, a, i, (w .&. m : U32))
def or_at(+i: U32, +x: U32, pair: Array<U32> & U32) -> Array<U32>:
  (a, +w) = pair
  Array.set(U32, a, i, (w .|. x : U32))
# clear byte 29 (word 7, byte 1)
def clear29(b: B.Buf) -> B.Buf:
  match b:
    case B.Buf{ws, +n}: B.Buf{and_at(7, 4294902015, Array.get(U32, ws, 7)), n}
# selector byte 0: 2 -> 1 (clear it, then or 1)
def sel1(b: B.Buf) -> B.Buf:
  match b:
    case B.Buf{ws, +n}: B.Buf{or_at(0, 1, Array.get(U32, and_at(0, 4294967040, Array.get(U32, ws, 0)), 0)), n}
def bsize(b: B.Buf) -> B.Buf & U32: B.size(b)
def dec_pc(label: String, pair: B.Buf & U32) -> IO(Unit):
  (b, +n) = pair
  show_pc(label, PcR.ProgressiveComplexTestStruct_decode(b, n))
def dec_ub(label: String, pair: B.Buf & U32) -> IO(Unit):
  (b, +n) = pair
  show_ub(label, UbR.CompatibleUnionBC_decode(b, n))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: show_pt("c1 pts empty", PtR.ProgressiveTestStruct_decode(buf6(16, 16, 16, 16, 16, 0, 0), 16))
    case 2: show_pt("c2 pts o3<o2", PtR.ProgressiveTestStruct_decode(buf6(20, 16, 16, 20, 16, 4, 0), 20))
    case 3: show_pt("c3 pts C1 D[[]]", PtR.ProgressiveTestStruct_decode(buf6(24, 16, 16, 16, 20, 131073, 4), 24))
    case 4: show_pt("c4 pts D first 5", PtR.ProgressiveTestStruct_decode(buf6(21, 16, 16, 16, 16, 5, 0), 21))
    case 5: show_pt("c5 pts D[[],[]]", PtR.ProgressiveTestStruct_decode(buf6(24, 16, 16, 16, 16, 8, 8), 24))
    case 6: show_pt("c6 pts C 2 bytes", PtR.ProgressiveTestStruct_decode(buf6(18, 16, 16, 16, 18, 0, 0), 18))
    case 7: dec_pc("c7 pcts default", bsize(pc_bytes()))
    case 8: dec_pc("c8 pcts no delim", bsize(clear29(pc_bytes())))
    case 9: dec_ub("c9 ubc arm0", bsize(ub_bytes()))
    case _: dec_ub("c10 ubc sel1", bsize(sel1(ub_bytes())))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
