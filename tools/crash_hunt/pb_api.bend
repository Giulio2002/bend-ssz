import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluCheckpoint_def_generated.bend as CpD
import ../../types/FuluCheckpoint_decode_ssz_generated.bend as CpR
import ../../types/SmallTestStruct_def_generated.bend as StD
import ../../types/SmallTestStruct_encode_ssz_generated.bend as StE
import ../../types/SmallTestStruct_hashtreeroot_generated.bend as StH
import ../../types/FuluBytes96_def_generated.bend as Bytes96D
import ../../types/FuluSyncCommitteeContribution_def_generated.bend as ScD
import ../../types/FuluContributionAndProof_def_generated.bend as CapD
import ../../types/FuluContributionAndProof_hashtreeroot_generated.bend as CapH
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt probe B: decode of a buffer shorter than the size argument, and a container holding a scalar outside
# its type (70000 for a uint16) given to the three public entry points.

def maybe_line(label: String, pair: B.Buf & Maybe<&1, CpD.Checkpoint>) -> IO(Unit):
  (b, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")

def case1() -> IO(Unit): maybe_line("decode_empty_buf_size40", CpR.Checkpoint_decode(B.empty(), 40))

def root_line(label: String, pair: B.Buf & D.Digest) -> IO(Unit):
  (h, d) = pair
  IO.print(label ++ "=" ++ IOx.words(d))

def case2() -> IO(Unit): root_line("root_uint16_70000", StH.SmallTestStruct_hash_tree_root(O.hasher(), StD.SmallTestStruct{70000, 5}))
def case3() -> IO(Unit): root_line("root_uint16_4464", StH.SmallTestStruct_hash_tree_root(O.hasher(), StD.SmallTestStruct{4464, 5}))

def enc_line(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ "_ok=" ++ O.pick_str(ok))

def case4() -> IO(Unit): enc_line("serialize_uint16_70000", StE.SmallTestStruct_serialize(StD.SmallTestStruct{70000, 5}))

def size_line(label: String, b: B.Buf) -> IO(Unit):
  IO.print(label ++ "=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))

def case5() -> IO(Unit): size_line("encode_uint16_70000_size", StE.SmallTestStruct_encode(StD.SmallTestStruct{70000, 5}))

def cap_root_line(label: String, pair: B.Buf & (CapD.ContributionAndProof & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print(label ++ "=" ++ IOx.words(d))

def zero96() -> Bytes96D.Bytes96: Bytes96D.Bytes96{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
def case6() -> IO(Unit): cap_root_line("root_boxed_none", CapH.ContributionAndProof_hash_tree_root(O.hasher(), CapD.ContributionAndProof{O.U64{1, 0}, O.BNone{}, zero96()}))
def case7() -> IO(Unit): cap_root_line("root_boxed_default", CapH.ContributionAndProof_hash_tree_root(O.hasher(), CapD.ContributionAndProof{O.U64{1, 0}, ScD.SyncCommitteeContribution_bx_default(), zero96()}))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: case1()
    case 2: case2()
    case 3: case3()
    case 4: case4()
    case 6: case6()
    case 7: case7()
    case _: case5()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
