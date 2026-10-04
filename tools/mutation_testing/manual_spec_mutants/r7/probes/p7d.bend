import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../types/ProgressiveTestStruct_def_generated.bend as PtD
import ../../../../../types/ProgressiveTestStruct_encode_ssz_generated.bend as PtE
import ../../../../../types/ProgressiveTestStruct_decode_ssz_generated.bend as PtR
import ../../../../../types/ProgressiveComplexTestStruct_def_generated.bend as PcD
import ../../../../../types/ProgressiveComplexTestStruct_encode_ssz_generated.bend as PcE
import ../../../../../types/ProgressiveComplexTestStruct_decode_ssz_generated.bend as PcR
import ../../../../../types/list_ProgressiveSingleFieldContainerTestStruct_10_def_generated.bend as L10
import ../../../../../types/ProgressiveSingleFieldContainerTestStruct_def_generated.bend as SfD
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-7 probe d: X_decode of byte strings (B.Buf{words, size}) that reach the open round-5 decode faults; a decoded value is re-serialized and
# its bytes printed as size and a word checksum (a reader fault decodes a valid string into another value: the re-serialization differs).
# ProgressiveTestStruct: 4 offsets o0..o3 (fixed part 16); f_C = ProgressiveList[SmallTestStruct]; f_D = ProgressiveList[ProgressiveList[VarTestStruct]];
# VarTestStruct = {A: uint16, B: List[uint16, 1024] (offset), C: uint8} (7 fixed bytes).
# SSZ_CASE:
#  1 PTS, f_D's window holds the first offset 0 (offsets 16,16,16,16, size 20, bytes 16..19 = 0): invalid (d01/07: first >= 4 dropped)
#  2 PTS, f_D = [[VarTestStruct{1, [], 2}]] (offsets 16,16,16,16; 4, 4, 01 00 07 00 00 00 02; size 31): valid (d01/09, d01/10 readers)
#  3 PTS, f_C = [SmallTestStruct{1, 2}], f_D = [[VarTestStruct{1, [], 2}]] (offsets 16,16,16,20; size 35): valid (d02/07, d02/08 readers)
#  4 PTS, o2 = 24 > o3 = 16 (f_B = one uint64 whose bytes are 8, 8; f_C's window wraps): invalid (d02/01: o2 <= o3 dropped)
#  5 PCTS default with f_G = [{5}, {9}] serialized, decoded, re-serialized: valid (d04/02: element i + 1 read at off + i)
#  6 PTS, o3 = 40 > size 24 (f_D's window past the end, f_C's window [16, 40) past the end; storage beyond the size zero): invalid (d02/02)
#  7 PTS, f_D = [[], []] with the second offset 4 < the first 8 (offsets 16,16,16,16; 8, 4; size 24): invalid (d01/01: non-decreasing dropped)

def ck_go(+k: Nat, +i: U32, +acc: U32, pair: Array<U32> & U32) -> U32:
  match k pair:
    case 0n Tuple{ws, x}: acc
    case 1n+q Tuple{ws, +x}: ck_go(q, (i + 1 : U32), ((acc * 31 : U32) + x : U32), Array.get(U32, ws, (i + 1 : U32)))

def show_buf(label: String, x: Bool, b: B.Buf) -> IO(Unit):
  match b:
    case B.Buf{ws, +n}: IO.print(label ++ " decoded=some reser_ok=" ++ O.pick_str(x) ++ " size=" ++ U32.show(n) ++ " ck=" ++ U32.show(ck_go(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, 7, Array.get(U32, ws, 0))))

def show_enc(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{x, b}: show_buf(label, x, b)

def pt_ser(label: String, pair: PtD.ProgressiveTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show_enc(label, e)
def show_pt(label: String, pair: B.Buf & Maybe<&1, PtD.ProgressiveTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: pt_ser(label, PtE.ProgressiveTestStruct_serialize(v))
    case None{}: IO.print(label ++ " decoded=none")

def pc_ser(label: String, pair: PcD.ProgressiveComplexTestStruct & O.Encoded) -> IO(Unit):
  (o, e) = pair
  show_enc(label, e)
def show_pc(label: String, pair: B.Buf & Maybe<&1, PcD.ProgressiveComplexTestStruct>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: pc_ser(label, PcE.ProgressiveComplexTestStruct_serialize(v))
    case None{}: IO.print(label ++ " decoded=none")

# 16 words of storage, the first nine given
def w9(+a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32, +i: U32) -> Array<U32>:
  Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 4n, 0), 0, a), 1, b), 2, c), 3, d), 4, e), 5, f), 6, g), 7, h), 8, i)
def buf9(+n: U32, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32, +i: U32) -> B.Buf: B.Buf{w9(a, b, c, d, e, f, g, h, i), n}

def app1(pair: L10.l10_ProgressiveSingleFieldContainerTestStruct_Seq & Bool) -> L10.l10_ProgressiveSingleFieldContainerTestStruct_Seq:
  (l, ok) = pair
  l
def fg2() -> L10.l10_ProgressiveSingleFieldContainerTestStruct_Seq:
  app1(L10.l10_ProgressiveSingleFieldContainerTestStruct_append(app1(L10.l10_ProgressiveSingleFieldContainerTestStruct_append(L10.l10_ProgressiveSingleFieldContainerTestStruct_default(), SfD.ProgressiveSingleFieldContainerTestStruct{5})), SfD.ProgressiveSingleFieldContainerTestStruct{9}))
def pc_bytes() -> B.Buf: O.ser_out(Pair.snd(PcD.ProgressiveComplexTestStruct, O.Encoded, PcE.ProgressiveComplexTestStruct_serialize(PcD.ProgressiveComplexTestStruct_set_f_G(PcD.ProgressiveComplexTestStruct_default(), fg2()))))
def dec_pc(label: String, pair: B.Buf & U32) -> IO(Unit):
  (b, +n) = pair
  show_pc(label, PcR.ProgressiveComplexTestStruct_decode(b, n))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: show_pt("c1 pts D first 0", PtR.ProgressiveTestStruct_decode(buf9(20, 16, 16, 16, 16, 0, 0, 0, 0, 0), 20))
    case 2: show_pt("c2 pts D [[V]]", PtR.ProgressiveTestStruct_decode(buf9(31, 16, 16, 16, 16, 4, 4, 458753, 131072, 0), 31))
    case 3: show_pt("c3 pts C1 D [[V]]", PtR.ProgressiveTestStruct_decode(buf9(35, 16, 16, 16, 20, 131073, 4, 4, 458753, 131072), 35))
    case 4: show_pt("c4 pts o2>o3", PtR.ProgressiveTestStruct_decode(buf9(24, 16, 16, 24, 16, 8, 8, 0, 0, 0), 24))
    case 5: dec_pc("c5 pcts fG [5,9]", B.size(pc_bytes()))
    case 6: show_pt("c6 pts o3>len", PtR.ProgressiveTestStruct_decode(buf9(24, 16, 16, 16, 40, 0, 0, 0, 0, 0), 24))
    case _: show_pt("c7 pts D off desc", PtR.ProgressiveTestStruct_decode(buf9(24, 16, 16, 16, 16, 8, 4, 0, 0, 0), 24))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
