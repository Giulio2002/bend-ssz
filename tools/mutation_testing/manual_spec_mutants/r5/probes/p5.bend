import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/FuluTransaction_hashtreeroot_generated.bend as TxH
import ../../../../../types/vec_uint128_3_hashtreeroot_generated.bend as V3H
import ../../../../../types/vec_uint128_3_encode_ssz_generated.bend as V3E
import ../../../../../types/proglist_uint8_hashtreeroot_generated.bend as P8H
import ../../../../../types/proglist_uint8_encode_ssz_generated.bend as P8E
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-5 probe: the public object API on the values that reach the round-5 survivors. Inputs use only public constructors
# (O.Words{array, n} with an array a caller builds with Array.new / Array.set) and the public entry points X_hash_tree_root / X_serialize.
# SSZ_CASE:
#  1 Transaction (ByteList[2^30]) of 3 bytes 01 02 03, clean storage of 8 words                     (control)
#  2 the same 3 bytes, word 5 of the storage (inside the first chunk, past the length) = 0xDEADBEEF  (root must equal case 1)
#  3 Transaction of 40 bytes (2 chunks), clean storage of 16 words                                 (control)
#  4 the same 40 bytes, word 12 (second chunk, past the length) = 0xDEADBEEF                         (root must equal case 3)
#  5 Vector[uint128, 3] (48 bytes), clean storage of 16 words                                      (control)
#  6 the same, word 13 (second chunk, past the 48 bytes) = 0xDEADBEEF                                (root must equal case 5)
#  7 ProgressiveList[uint8] of 3 bytes, clean storage                                              (control)
#  8 the same, word 5 = 0xDEADBEEF                                                                  (root must equal case 7)
#  9 Transaction of 3 bytes in a storage of 1 word (Array.new depth 0: smaller than the chunk)      (root must equal case 1)
# 10 Transaction of 13 bytes 0x11.. in a storage of 4 words (depth 2), and 11 its clean 8-word twin (roots must agree)
# 12 ProgressiveList[uint8] of 3 bytes in a storage of 1 word                                      (root must equal case 7)

def rs(d: D.Digest) -> String:
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}: U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d1) ++ "," ++ U32.show(e) ++ "," ++ U32.show(f) ++ "," ++ U32.show(g) ++ "," ++ U32.show(h)

def pr_root(label: String, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (w, d) = r
  IO.print(label ++ " root=" ++ rs(d))

def pr_ok(label: String, pair: O.Words & Bool) -> IO(Unit):
  (w, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

# 8 words: bytes 01 02 03 then zeros; `junk` at word j when j < 8
def w3(+j: U32) -> Array<U32>: Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 197121), j, 3735928559)
def w3c() -> Array<U32>: Array.set(U32, Array.new(U32, 3n, 0), 0, 197121)
# 16 words: 40 bytes (10 words) of 0x11, junk at word j
def f10(+k: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match k:
    case 0n: a
    case 1n+q: f10(q, (i + 1 : U32), Array.set(U32, a, i, 286331153))
def w40c() -> Array<U32>: f10(10n, 0, Array.new(U32, 4n, 0))
def w40(+j: U32) -> Array<U32>: Array.set(U32, w40c(), j, 3735928559)
def w48c() -> Array<U32>: f10(12n, 0, Array.new(U32, 4n, 0))
def w48(+j: U32) -> Array<U32>: Array.set(U32, w48c(), j, 3735928559)

def c1() -> IO(Unit): pr_root("c1 tx3 clean", TxH.Transaction_hash_tree_root(O.hasher(), O.Words{w3c(), 3}))
def c2() -> IO(Unit): pr_root("c2 tx3 junk5", TxH.Transaction_hash_tree_root(O.hasher(), O.Words{w3(5), 3}))
def c3() -> IO(Unit): pr_root("c3 tx40 clean", TxH.Transaction_hash_tree_root(O.hasher(), O.Words{w40c(), 40}))
def c4() -> IO(Unit): pr_root("c4 tx40 junk12", TxH.Transaction_hash_tree_root(O.hasher(), O.Words{w40(12), 40}))
def c5() -> IO(Unit): pr_root("c5 v3u128 clean", V3H.vec_uint128_3_hash_tree_root(O.hasher(), O.Words{w48c(), 48}))
def c6() -> IO(Unit):
  do IO<Unit>:
    pr_ok("c6 v3u128 junk13", V3E.v3_u128_valid(O.Words{w48(13), 48}))
    pr_root("c6 v3u128 junk13", V3H.vec_uint128_3_hash_tree_root(O.hasher(), O.Words{w48(13), 48}))
def c7() -> IO(Unit): pr_root("c7 pl8 clean", P8H.proglist_uint8_hash_tree_root(O.hasher(), O.Words{w3c(), 3}))
def w13s() -> Array<U32>: Array.set(U32, f10(3n, 0, Array.new(U32, 2n, 0)), 3, 17)
def w13c() -> Array<U32>: Array.set(U32, f10(3n, 0, Array.new(U32, 3n, 0)), 3, 17)
def c9() -> IO(Unit): pr_root("c9 tx3 1word", TxH.Transaction_hash_tree_root(O.hasher(), O.Words{Array.new(U32, 0n, 197121), 3}))
def c10() -> IO(Unit): pr_root("c10 tx13 4words", TxH.Transaction_hash_tree_root(O.hasher(), O.Words{w13s(), 13}))
def c11() -> IO(Unit): pr_root("c11 tx13 clean", TxH.Transaction_hash_tree_root(O.hasher(), O.Words{w13c(), 13}))
def c12() -> IO(Unit): pr_root("c12 pl8 1word", P8H.proglist_uint8_hash_tree_root(O.hasher(), O.Words{Array.new(U32, 0n, 197121), 3}))
def c8() -> IO(Unit):
  do IO<Unit>:
    pr_ok("c8 pl8 junk5", P8E.pl_u8_valid(O.Words{w3(5), 3}))
    pr_root("c8 pl8 junk5", P8H.proglist_uint8_hash_tree_root(O.hasher(), O.Words{w3(5), 3}))

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
    case 10: c10()
    case 11: c11()
    case _: c12()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
