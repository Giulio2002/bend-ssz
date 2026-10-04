import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/FuluTransaction_def_generated.bend as TxD
import ../../../../../types/FuluTransaction_encode_ssz_generated.bend as TxE
import ../../../../../types/FuluTransaction_hashtreeroot_generated.bend as TxH
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-8 probe a: r8-a03-clean-copy/01 (tail_zero case 1 tests bytes 2..3 only). Public calls only: the record constructor O.Words{array, n},
# Transaction_hash_tree_root, bl1073741824_valid, Transaction_serialize.
# SSZ_CASE:
#  1 Transaction of 1 byte 0x01, storage word 0 = 0x0000BE01 (junk in byte 1 only)   (root must equal case 2 by the j_tail contract)
#  2 Transaction of 1 byte 0x01 in clean storage                                      (control)
#  3 Transaction of 5 bytes 01 02 03 04 05, word 1 = 0x0000BE05 (junk in byte 5 only)  (root must equal case 4)
#  4 Transaction of 5 bytes in clean storage                                          (control)
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

def w8(+v0: U32, +j: U32, +x: U32) -> Array<U32>: Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, v0), j, x)
def w8c(+v0: U32) -> Array<U32>: Array.set(U32, Array.new(U32, 3n, 0), 0, v0)
def v10(+j: U32, +x: U32) -> Array<U32>: Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, 286331153), 1, 286331153), 2, 4369), j, x)

def rstr(pair: B.Buf & (O.Words & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def rstrb(pair: B.Buf & (O.Bits & D.Digest)) -> String:
  (h, r) = pair
  (w, d) = r
  rs(d)

def tx_o3(label: String, pair: O.Words & O.Encoded) -> IO(Unit):
  (w, e) = pair
  IO.print(label ++ " ser " ++ enc_str(e) ++ " root=" ++ rstr(TxH.Transaction_hash_tree_root(O.hasher(), w)))

def tx_o2(label: String, pair: O.Words & Bool) -> IO(Unit):
  (w, ok) = pair
  tx_o3(label ++ " valid=" ++ O.pick_str(ok), TxE.Transaction_serialize(w))

def tx_out(label: String, w: O.Words) -> IO(Unit): tx_o2(label, TxE.bl1073741824_valid(w))

def w1(+v0: U32) -> Array<U32>: Array.set(U32, Array.new(U32, 3n, 0), 0, v0)
def w2(+v0: U32, +v1: U32) -> Array<U32>: Array.set(U32, Array.set(U32, Array.new(U32, 3n, 0), 0, v0), 1, v1)

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: tx_out("c1 tx1 junk-byte1", O.Words{w1(48641), 1})
    case 2: tx_out("c2 tx1 clean", O.Words{w1(1), 1})
    case 3: tx_out("c3 tx5 junk-byte5", O.Words{w2(67305985, 48645), 5})
    case _: tx_out("c4 tx5 clean", O.Words{w2(67305985, 5), 5})

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
