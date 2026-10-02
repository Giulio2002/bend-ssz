import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/proglist_uint8_def_generated.bend as P8D
import ../../types/proglist_uint8_encode_ssz_generated.bend as P8E
import ../../types/proglist_uint8_hashtreeroot_generated.bend as P8H
import ../../types/Fulu_list_uint64_131072_encode_ssz_generated.bend as L64E
import ../../types/Fulu_list_uint64_131072_hashtreeroot_generated.bend as L64H
import ../../types/progbitlist_encode_ssz_generated.bend as PbE
import ../../types/progbitlist_hashtreeroot_generated.bend as PbH
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt round 2, probe H: objects that _valid accepts but whose storage is not the canonical padded storage
# (bytes past the length in whole words, storage smaller than one chunk). SSZ_CASE: type, SSZ_ARG: storage variant.
# Prints valid, serialize ok/size and the root.

def G() -> U32: 3735928559

# storage variants: 0 = [1, 2, 0, 0]; 1 = [1, 2, G, G]; 2 = [1, 2] (2 words); 3 = [1, 2, 0, 0, 0, 0, 0, 0] with garbage in word 5; 4 = 1 word [1]
def store(+v: U32) -> Array<U32>:
  match v:
    case 0: Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 1), 1, 2)
    case 1: Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 0, 1), 1, 2), 2, G()), 3, G())
    case 2: Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 1), 1, 2)
    case 3: Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1, 2), 5, G())
    case 4: Array.set(U32, Array.new(U32, 0n, 0), 0, 1)
    case 5: Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1, 2)
    case _: Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 1), 1, 2), 6, G())

def ser_str(pair: O.Words & O.Encoded) -> String:
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: "ser_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b)))

def bser_str(pair: O.Bits & O.Encoded) -> String:
  (o, e) = pair
  match e:
    case O.Encoded{ok, b}: "ser_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b)))

def wroot_str(pair: B.Buf & (O.Words & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  "root=" ++ IOx.words(d)

def broot_str(pair: B.Buf & (O.Bits & D.Digest)) -> String:
  (h, r) = pair
  (o, d) = r
  "root=" ++ IOx.words(d)

def valid_str(pair: O.Words & Bool) -> String:
  (o, ok) = pair
  "valid=" ++ O.pick_str(ok)

def bvalid_str(pair: O.Bits & Bool) -> String:
  (o, ok) = pair
  "valid=" ++ O.pick_str(ok)

# 1: byte list, n bytes
def c1(+v: U32, +n: U32) -> IO(Unit):
  do IO<Unit>:
    IO.print("u8 " ++ valid_str(P8E.pl_u8_valid(O.Words{store(v), n})))
    IO.print("u8 " ++ ser_str(P8E.proglist_uint8_serialize(O.Words{store(v), n})))
    IO.print("u8 " ++ wroot_str(P8H.proglist_uint8_hash_tree_root(O.hasher(), O.Words{store(v), n})))
# 2: List[uint64, 131072], n bytes
def c2(+v: U32, +n: U32) -> IO(Unit):
  do IO<Unit>:
    IO.print("l64 " ++ valid_str(L64E.l131072_u64_valid(O.Words{store(v), n})))
    IO.print("l64 " ++ wroot_str(L64H.l131072_u64_root(64n, O.hasher(), O.Words{store(v), n}, 0)))
# 3: progressive bit list, k bits
def c3(+v: U32, +k: U32) -> IO(Unit):
  do IO<Unit>:
    IO.print("pbits " ++ bvalid_str(PbE.pbits_valid(O.Bits{store(v), k})))
    IO.print("pbits " ++ bser_str(PbE.progbitlist_serialize(O.Bits{store(v), k})))
    IO.print("pbits " ++ broot_str(PbH.progbitlist_hash_tree_root(O.hasher(), O.Bits{store(v), k})))

def dispatch(+c: U32, +v: U32, +n: U32) -> IO(Unit):
  match c:
    case 1: c1(v, n)
    case 2: c2(v, n)
    case _: c3(v, n)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +v : U32 <- IOx.env_u32("SSZ_ARG")
    +n : U32 <- IOx.env_u32("SSZ_N")
    dispatch(c, v, n)
