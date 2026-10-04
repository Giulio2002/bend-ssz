import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/FuluTransaction_def_generated.bend as TxD
import ../../../../../types/FuluTransaction_encode_ssz_generated.bend as TxE
import ../../../../../types/FuluTransaction_hashtreeroot_generated.bend as TxH
import ../../../../../types/vec_uint16_5_hashtreeroot_generated.bend as V5H
import ../../../../../types/vec_uint16_5_encode_ssz_generated.bend as V5E
import ../../../../../types/bitlist_32_def_generated.bend as B32D
import ../../../../../types/bitlist_32_encode_ssz_generated.bend as B32E
import ../../../../../types/bitlist_32_hashtreeroot_generated.bend as B32H
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-7 probe a: the public object API on values whose storage holds junk past the length (a caller builds O.Words{array, n} / O.Bits{array, k}
# with Array.new / Array.set: public record constructors), through X_valid, X_hash_tree_root, X_serialize and the append setters.
# SSZ_CASE:
#  1 Transaction of 1 byte 0x01 in clean storage of 8 words                                   (control)
#  2 the same byte, word 3 = 0xDEADBEEF (inside the first chunk, past the length; X_valid = 1)  (root must equal case 1)
#  3 the same byte, word 6 = 0xDEADBEEF                                                        (root must equal case 1)
#  4 Vector[uint16, 5] (10 bytes 0x11..) in clean storage of 8 words                          (control)
#  5 the same, word 5 = 0xDEADBEEF                                                             (root must equal case 4)
#  6 Transaction of 4 bytes 01 02 03 04, word 1 = 0xDEADBEEF, then append 0x05: serialize and root (must equal case 7)
#  7 Transaction of 5 bytes 01 02 03 04 05 in clean storage: serialize and root                (control)
#  8 Bitlist[32] of 31 bits (all 1) whose word 1 holds junk 0xDEADBEEF (valid: bits 31.. of word 0 zero), append True: serialize and root (must equal 9)
#  9 Bitlist[32] of 32 bits (all 1) in clean storage: serialize and root                       (control)
# 10 Transaction of 2 bytes 01 02 in a storage of 1 word, append 0x03 (grows), then append 0x04: serialize

def rs(d: D.Digest) -> String:
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}: U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(h)

def ck_go(+k: Nat, +i: U32, +acc: U32, pair: Array<U32> & U32) -> U32:
  match k pair:
    case 0n Tuple{ws, x}: acc
    case 1n+q Tuple{ws, +x}: ck_go(q, (i + 1 : U32), ((acc * 31 : U32) + x : U32), Array.get(U32, ws, (i + 1 : U32)))

def enc_str(e: O.Encoded) -> String:
  match e:
    case O.Encoded{x, b}:
      match b:
        case B.Buf{ws, +n}: "ok=" ++ O.pick_str(x) ++ " size=" ++ U32.show(n) ++ " ck=" ++ U32.show(ck_go(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, 7, Array.get(U32, ws, 0)))

def pr_root(label: String, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (w, d) = r
  IO.print(label ++ " root=" ++ rs(d))

def pr_rootb(label: String, pair: B.Buf & (O.Bits & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (w, d) = r
  IO.print(label ++ " root=" ++ rs(d))

def pr_ok(label: String, pair: O.Words & Bool) -> IO(Unit):
  (w, ok) = pair
  IO.print(label ++ " valid=" ++ O.pick_str(ok))

def w8(+v0: U32, +j: U32, +x: U32) -> Array<U32>: Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, v0), j, x)
def w8c(+v0: U32) -> Array<U32>: Array.set(U32, Array.new(U32, 3n, 0), 0, v0)
def v10(+j: U32, +x: U32) -> Array<U32>: Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 286331153), 1, 286331153), 2, 4369), j, x)

def tx_out(label: String, w: O.Words) -> IO(Unit):
  do IO<Unit>:
    pr_ok(label, TxE.bl1073741824_valid(w))
    IO.print(label ++ " ser " ++ enc_str(Pair.snd(O.Words, O.Encoded, TxE.Transaction_serialize(w))))
    pr_root(label, TxH.Transaction_hash_tree_root(O.hasher(), w))

def fstw(pair: O.Words & Bool) -> O.Words:
  (w, ok) = pair
  w
def fstb(pair: O.Bits & Bool) -> O.Bits:
  (w, ok) = pair
  w

def bl_out(label: String, b: O.Bits) -> IO(Unit):
  do IO<Unit>:
    IO.print(label ++ " ser " ++ enc_str(Pair.snd(O.Bits, O.Encoded, B32E.bitlist_32_serialize(b))))
    pr_rootb(label, B32H.bitlist_32_hash_tree_root(O.hasher(), b))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: tx_out("c1 tx1 clean", O.Words{w8c(1), 1})
    case 2: tx_out("c2 tx1 junk3", O.Words{w8(1, 3, 3735928559), 1})
    case 3: tx_out("c3 tx1 junk6", O.Words{w8(1, 6, 3735928559), 1})
    case 4: pr_root("c4 v5u16 clean", V5H.vec_uint16_5_hash_tree_root(O.hasher(), O.Words{v10(7, 0), 10}))
    case 5:
      do IO<Unit>:
        pr_ok("c5 v5u16 junk5", V5E.v5_u16_valid(O.Words{v10(5, 3735928559), 10}))
        pr_root("c5 v5u16 junk5", V5H.vec_uint16_5_hash_tree_root(O.hasher(), O.Words{v10(5, 3735928559), 10}))
    case 6: tx_out("c6 tx4 junk1 +05", fstw(TxD.bl1073741824_append(O.Words{w8(67305985, 1, 3735928559), 4}, 5)))
    case 7: tx_out("c7 tx5 clean", O.Words{Array.set(U32, w8c(67305985), 1, 5), 5})
    case 8: bl_out("c8 bits31 junk1 +1", fstb(B32D.bits32_append(O.Bits{w8(2147483647, 1, 3735928559), 31}, True{})))
    case 9: bl_out("c9 bits32 clean", O.Bits{w8c(4294967295), 32})
    case _: tx_out("c10 tx2 1word +3 +4", fstw(TxD.bl1073741824_append(fstw(TxD.bl1073741824_append(O.Words{Array.new(U32, 0n, 513), 2}, 3)), 4)))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
