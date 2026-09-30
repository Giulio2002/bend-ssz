import Base
import ../../src/digest.bend as D
import 0xd9a2fae439ac7ff9e21e0853948f94fe/spec/crypto/sha.bend as VF
import ./sha_node.bend as SN
import ./zero_roots.bend as ZR

# Digests are determined by their bytes, and the runtime node of two equal
# zero-subtree roots is the next one (Z(k + 1) = node(Z(k), Z(k))), as digests.
# The cached Merkle trees hash explicit zero leaves where the reference tree
# (mtree_defs rtree) uses the constants D.zconst: this is the bridge.

def bnth(xs: List<&2, U32>, +i: Nat) -> U32:
  match xs:
    case Nil{}: 0
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: bnth(t, j)

def wat(+xs: List<&2, U32>, +k: Nat) -> U32:
  VF.decode(bnth(xs, Nat.add(Nat.double(Nat.double(k)), 0n)), bnth(xs, Nat.add(Nat.double(Nat.double(k)), 1n)),
    bnth(xs, Nat.add(Nat.double(Nat.double(k)), 2n)), bnth(xs, Nat.add(Nat.double(Nat.double(k)), 3n)))

# The digest read back from its 32 bytes.
def of_bytes(+xs: List<&2, U32>) -> D.Digest:
  D.D{wat(xs, 0n), wat(xs, 1n), wat(xs, 2n), wat(xs, 3n), wat(xs, 4n), wat(xs, 5n), wat(xs, 6n), wat(xs, 7n)}

law of_bytes_bytes:
  for +d: D.Digest
  {of_bytes(D.bytes(d)) == d : D.Digest}
def of_bytes_bytes(d):
  match d:
    case D.D{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      %Equal.sym(U32, VF.decode((U32.shrn(w0, 24n) .&. 255 : U32), (U32.shrn(w0, 16n) .&. 255 : U32), (U32.shrn(w0, 8n) .&. 255 : U32), (w0 .&. 255 : U32)), w0, SN.dec_be(w0)) :
        {D.D{_, VF.decode((U32.shrn(w1, 24n) .&. 255 : U32), (U32.shrn(w1, 16n) .&. 255 : U32), (U32.shrn(w1, 8n) .&. 255 : U32), (w1 .&. 255 : U32)), VF.decode((U32.shrn(w2, 24n) .&. 255 : U32), (U32.shrn(w2, 16n) .&. 255 : U32), (U32.shrn(w2, 8n) .&. 255 : U32), (w2 .&. 255 : U32)), VF.decode((U32.shrn(w3, 24n) .&. 255 : U32), (U32.shrn(w3, 16n) .&. 255 : U32), (U32.shrn(w3, 8n) .&. 255 : U32), (w3 .&. 255 : U32)), VF.decode((U32.shrn(w4, 24n) .&. 255 : U32), (U32.shrn(w4, 16n) .&. 255 : U32), (U32.shrn(w4, 8n) .&. 255 : U32), (w4 .&. 255 : U32)), VF.decode((U32.shrn(w5, 24n) .&. 255 : U32), (U32.shrn(w5, 16n) .&. 255 : U32), (U32.shrn(w5, 8n) .&. 255 : U32), (w5 .&. 255 : U32)), VF.decode((U32.shrn(w6, 24n) .&. 255 : U32), (U32.shrn(w6, 16n) .&. 255 : U32), (U32.shrn(w6, 8n) .&. 255 : U32), (w6 .&. 255 : U32)), VF.decode((U32.shrn(w7, 24n) .&. 255 : U32), (U32.shrn(w7, 16n) .&. 255 : U32), (U32.shrn(w7, 8n) .&. 255 : U32), (w7 .&. 255 : U32))} == D.D{w0, w1, w2, w3, w4, w5, w6, w7} : D.Digest}
      %Equal.sym(U32, VF.decode((U32.shrn(w1, 24n) .&. 255 : U32), (U32.shrn(w1, 16n) .&. 255 : U32), (U32.shrn(w1, 8n) .&. 255 : U32), (w1 .&. 255 : U32)), w1, SN.dec_be(w1)) :
        {D.D{w0, _, VF.decode((U32.shrn(w2, 24n) .&. 255 : U32), (U32.shrn(w2, 16n) .&. 255 : U32), (U32.shrn(w2, 8n) .&. 255 : U32), (w2 .&. 255 : U32)), VF.decode((U32.shrn(w3, 24n) .&. 255 : U32), (U32.shrn(w3, 16n) .&. 255 : U32), (U32.shrn(w3, 8n) .&. 255 : U32), (w3 .&. 255 : U32)), VF.decode((U32.shrn(w4, 24n) .&. 255 : U32), (U32.shrn(w4, 16n) .&. 255 : U32), (U32.shrn(w4, 8n) .&. 255 : U32), (w4 .&. 255 : U32)), VF.decode((U32.shrn(w5, 24n) .&. 255 : U32), (U32.shrn(w5, 16n) .&. 255 : U32), (U32.shrn(w5, 8n) .&. 255 : U32), (w5 .&. 255 : U32)), VF.decode((U32.shrn(w6, 24n) .&. 255 : U32), (U32.shrn(w6, 16n) .&. 255 : U32), (U32.shrn(w6, 8n) .&. 255 : U32), (w6 .&. 255 : U32)), VF.decode((U32.shrn(w7, 24n) .&. 255 : U32), (U32.shrn(w7, 16n) .&. 255 : U32), (U32.shrn(w7, 8n) .&. 255 : U32), (w7 .&. 255 : U32))} == D.D{w0, w1, w2, w3, w4, w5, w6, w7} : D.Digest}
      %Equal.sym(U32, VF.decode((U32.shrn(w2, 24n) .&. 255 : U32), (U32.shrn(w2, 16n) .&. 255 : U32), (U32.shrn(w2, 8n) .&. 255 : U32), (w2 .&. 255 : U32)), w2, SN.dec_be(w2)) :
        {D.D{w0, w1, _, VF.decode((U32.shrn(w3, 24n) .&. 255 : U32), (U32.shrn(w3, 16n) .&. 255 : U32), (U32.shrn(w3, 8n) .&. 255 : U32), (w3 .&. 255 : U32)), VF.decode((U32.shrn(w4, 24n) .&. 255 : U32), (U32.shrn(w4, 16n) .&. 255 : U32), (U32.shrn(w4, 8n) .&. 255 : U32), (w4 .&. 255 : U32)), VF.decode((U32.shrn(w5, 24n) .&. 255 : U32), (U32.shrn(w5, 16n) .&. 255 : U32), (U32.shrn(w5, 8n) .&. 255 : U32), (w5 .&. 255 : U32)), VF.decode((U32.shrn(w6, 24n) .&. 255 : U32), (U32.shrn(w6, 16n) .&. 255 : U32), (U32.shrn(w6, 8n) .&. 255 : U32), (w6 .&. 255 : U32)), VF.decode((U32.shrn(w7, 24n) .&. 255 : U32), (U32.shrn(w7, 16n) .&. 255 : U32), (U32.shrn(w7, 8n) .&. 255 : U32), (w7 .&. 255 : U32))} == D.D{w0, w1, w2, w3, w4, w5, w6, w7} : D.Digest}
      %Equal.sym(U32, VF.decode((U32.shrn(w3, 24n) .&. 255 : U32), (U32.shrn(w3, 16n) .&. 255 : U32), (U32.shrn(w3, 8n) .&. 255 : U32), (w3 .&. 255 : U32)), w3, SN.dec_be(w3)) :
        {D.D{w0, w1, w2, _, VF.decode((U32.shrn(w4, 24n) .&. 255 : U32), (U32.shrn(w4, 16n) .&. 255 : U32), (U32.shrn(w4, 8n) .&. 255 : U32), (w4 .&. 255 : U32)), VF.decode((U32.shrn(w5, 24n) .&. 255 : U32), (U32.shrn(w5, 16n) .&. 255 : U32), (U32.shrn(w5, 8n) .&. 255 : U32), (w5 .&. 255 : U32)), VF.decode((U32.shrn(w6, 24n) .&. 255 : U32), (U32.shrn(w6, 16n) .&. 255 : U32), (U32.shrn(w6, 8n) .&. 255 : U32), (w6 .&. 255 : U32)), VF.decode((U32.shrn(w7, 24n) .&. 255 : U32), (U32.shrn(w7, 16n) .&. 255 : U32), (U32.shrn(w7, 8n) .&. 255 : U32), (w7 .&. 255 : U32))} == D.D{w0, w1, w2, w3, w4, w5, w6, w7} : D.Digest}
      %Equal.sym(U32, VF.decode((U32.shrn(w4, 24n) .&. 255 : U32), (U32.shrn(w4, 16n) .&. 255 : U32), (U32.shrn(w4, 8n) .&. 255 : U32), (w4 .&. 255 : U32)), w4, SN.dec_be(w4)) :
        {D.D{w0, w1, w2, w3, _, VF.decode((U32.shrn(w5, 24n) .&. 255 : U32), (U32.shrn(w5, 16n) .&. 255 : U32), (U32.shrn(w5, 8n) .&. 255 : U32), (w5 .&. 255 : U32)), VF.decode((U32.shrn(w6, 24n) .&. 255 : U32), (U32.shrn(w6, 16n) .&. 255 : U32), (U32.shrn(w6, 8n) .&. 255 : U32), (w6 .&. 255 : U32)), VF.decode((U32.shrn(w7, 24n) .&. 255 : U32), (U32.shrn(w7, 16n) .&. 255 : U32), (U32.shrn(w7, 8n) .&. 255 : U32), (w7 .&. 255 : U32))} == D.D{w0, w1, w2, w3, w4, w5, w6, w7} : D.Digest}
      %Equal.sym(U32, VF.decode((U32.shrn(w5, 24n) .&. 255 : U32), (U32.shrn(w5, 16n) .&. 255 : U32), (U32.shrn(w5, 8n) .&. 255 : U32), (w5 .&. 255 : U32)), w5, SN.dec_be(w5)) :
        {D.D{w0, w1, w2, w3, w4, _, VF.decode((U32.shrn(w6, 24n) .&. 255 : U32), (U32.shrn(w6, 16n) .&. 255 : U32), (U32.shrn(w6, 8n) .&. 255 : U32), (w6 .&. 255 : U32)), VF.decode((U32.shrn(w7, 24n) .&. 255 : U32), (U32.shrn(w7, 16n) .&. 255 : U32), (U32.shrn(w7, 8n) .&. 255 : U32), (w7 .&. 255 : U32))} == D.D{w0, w1, w2, w3, w4, w5, w6, w7} : D.Digest}
      %Equal.sym(U32, VF.decode((U32.shrn(w6, 24n) .&. 255 : U32), (U32.shrn(w6, 16n) .&. 255 : U32), (U32.shrn(w6, 8n) .&. 255 : U32), (w6 .&. 255 : U32)), w6, SN.dec_be(w6)) :
        {D.D{w0, w1, w2, w3, w4, w5, _, VF.decode((U32.shrn(w7, 24n) .&. 255 : U32), (U32.shrn(w7, 16n) .&. 255 : U32), (U32.shrn(w7, 8n) .&. 255 : U32), (w7 .&. 255 : U32))} == D.D{w0, w1, w2, w3, w4, w5, w6, w7} : D.Digest}
      %Equal.sym(U32, VF.decode((U32.shrn(w7, 24n) .&. 255 : U32), (U32.shrn(w7, 16n) .&. 255 : U32), (U32.shrn(w7, 8n) .&. 255 : U32), (w7 .&. 255 : U32)), w7, SN.dec_be(w7)) :
        {D.D{w0, w1, w2, w3, w4, w5, w6, _} == D.D{w0, w1, w2, w3, w4, w5, w6, w7} : D.Digest}
      {==}

law bytes_inj:
  for +a: D.Digest
  for +b: D.Digest
  for +e: {D.bytes(a) == D.bytes(b) : List<&2, U32>}
  {a == b : D.Digest}
def bytes_inj(a, b, e):
  Equal.trans(D.Digest, a, of_bytes(D.bytes(b)), b,
    Equal.trans(D.Digest, a, of_bytes(D.bytes(a)), of_bytes(D.bytes(b)),
      Equal.sym(D.Digest, of_bytes(D.bytes(a)), a, of_bytes_bytes(a)),
      Equal.cong(List<&2, U32>, D.Digest, x => of_bytes(x), D.bytes(a), D.bytes(b), e)),
    of_bytes_bytes(b))

# The node of two zero-subtree roots of height k is the zero-subtree root of height k + 1.
law zero_node:
  for +k: Nat
  for +hk: {Nat.is_lt(k, 63n) == True{} : Bool}
  {D.node(64n, D.zconst(k), D.zconst(k)) == D.zconst(1n+k) : D.Digest}
def zero_node(k, hk):
  bytes_inj(D.node(64n, D.zconst(k), D.zconst(k)), D.zconst(1n+k),
    Equal.trans(List<&2, U32>, D.bytes(D.node(64n, D.zconst(k), D.zconst(k))), VF.sha256_bytes(List.append(&2, U32, D.bytes(D.zconst(k)), D.bytes(D.zconst(k)))), D.bytes(D.zconst(1n+k)),
      SN.node(D.zconst(k), D.zconst(k)),
      Equal.sym(List<&2, U32>, D.bytes(D.zconst(1n+k)), VF.sha256_bytes(List.append(&2, U32, D.bytes(D.zconst(k)), D.bytes(D.zconst(k)))), ZR.zconst_step(k, hk))))
