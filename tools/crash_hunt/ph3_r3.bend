import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluCheckpoint_def_generated.bend as Cd
import ../../types/FuluCheckpoint_hashtreeroot_generated.bend as Ch
import ../../types/FuluBeaconBlockHeader_def_generated.bend as Hd
import ../../types/FuluBeaconBlockHeader_hashtreeroot_generated.bend as Hh
import ../../types/proglist_uint8_def_generated.bend as P8
import ../../types/proglist_uint8_hashtreeroot_generated.bend as P8h
import ../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 3, probe H: the hasher argument of _hash_tree_root is a public B.Buf. SSZ_CASE: which hasher (1: O.hasher() control,
# 2: B.empty(), 3: B.alloc(0), 4: B.alloc(100000), 5: a B.Buf with len 2^32 - 1 over one word); SSZ_ARG 1: Checkpoint, 2: BeaconBlockHeader, 3: 40-byte proglist_uint8

def hs(+c: U32) -> B.Buf:
  match c:
    case 1: O.hasher()
    case 2: B.empty()
    case 3: B.alloc(0)
    case 4: B.alloc(100000)
    case _: B.Buf{Array.new(U32, 0n, 0), 4294967295}

def pr1(pair: B.Buf & D.Digest) -> IO(Unit):
  (h, d) = pair
  IO.print("checkpoint root=" ++ IOx.words(d))
def pr2(pair: B.Buf & D.Digest) -> IO(Unit):
  (h, d) = pair
  IO.print("header root=" ++ IOx.words(d))
def pr3(pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print("proglist root=" ++ IOx.words(d))

def go(+c: U32, +a: U32) -> IO(Unit):
  match a:
    case 1: pr1(Ch.Checkpoint_hash_tree_root(hs(c), Cd.Checkpoint_default()))
    case 2: pr2(Hh.BeaconBlockHeader_hash_tree_root(hs(c), Hd.BeaconBlockHeader_default()))
    case _: pr3(P8h.proglist_uint8_hash_tree_root(hs(c), O.words_new(40)))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    go(c, a)
