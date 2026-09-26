import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vnest.bend as VN
import ./vbitc.bend as VBC
import ./vua.bend as UA

# The unaligned-offset layer, U3: the runtime's fixed-size scalar reads at ANY
# byte offset X. A uint64 is two four-byte reads (rd64_any), whose limbs are
# the buffer's spec bytes [X, X + 8) (rd64_bytes). (uint32 and offsets are
# UA.rd_any, bytes and bools VR.byte_at_ok, byte vectors vua_sc.copy_in_ua*.)

def X4(+X: U32) -> U32: U32.add(X, 4)

# x + 8 == 4 + (x + 4)
def e84(+x: Nat) -> {Nat.add(x, 8n) == 4n+Nat.add(x, 4n) : Nat}:
  %Equal.sym(Nat, Nat.add(x, 4n), Nat.add(4n, x), F.nat__add_comm(x, 4n)) : {Nat.add(x, 8n) == 4n+_ : Nat}
  F.nat__add_comm(x, 8n)

# The second word's offset: X + 4 without wrap.
def ex4(+d: Nat, +X: U32, +hd: {Nat.is_lt(d, 30n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {U32.to_nat(X4(X)) == Nat.add(U32.to_nat(X), 4n) : Nat}:
  +h8 = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(U32.to_nat(X), 8n), 4n+Nat.add(U32.to_nat(X), 4n), e84(U32.to_nat(X)), h)
  +hl = F.nat__lt_le_trans(Nat.add(4n, U32.to_nat(X)), 4n+Nat.add(U32.to_nat(X), 4n), VB.pw(2n+d),
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(4n, U32.to_nat(X)), 4n+z) == True{} : Bool}, Nat.add(4n, U32.to_nat(X)), Nat.add(U32.to_nat(X), 4n), F.nat__add_comm(4n, U32.to_nat(X)),
      F.nat__le_lt_trans(Nat.add(4n, U32.to_nat(X)), Nat.add(4n, U32.to_nat(X)), 4n+Nat.add(4n, U32.to_nat(X)), F.nat__le_refl(Nat.add(4n, U32.to_nat(X))), VB.lt_kk(0n, 4n, Nat.add(4n, U32.to_nat(X)), {==}))),
    h8)
  Equal.trans(Nat, U32.to_nat(X4(X)), Nat.add(4n, U32.to_nat(X)), Nat.add(U32.to_nat(X), 4n),
    VB.add_at(X, 4, U32.to_nat(X), 2n+d, {==}, hd, hl), F.nat__add_comm(4n, U32.to_nat(X)))

def h4(+d: Nat, +X: U32, +hd: {Nat.is_lt(d, 30n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(X4(X)), 4n), A.quad(VB.pw(d))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(X4(X)), Nat.add(U32.to_nat(X), 4n), ex4(d, X, hd, h)) : {Nat.is_le(Nat.add(_, 4n), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(X), 4n), 4n), Nat.add(U32.to_nat(X), 8n), F.nat__add_assoc(U32.to_nat(X), 4n, 4n)) : {Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}
  h

def h0(+d: Nat, +X: U32, +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(X), 4n), A.quad(VB.pw(d))) == True{} : Bool}:
  F.nat__le_trans(Nat.add(U32.to_nat(X), 4n), Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d)),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(X), 4n), z) == True{} : Bool}, 4n+Nat.add(U32.to_nat(X), 4n), Nat.add(U32.to_nat(X), 8n),
      Equal.sym(Nat, Nat.add(U32.to_nat(X), 8n), 4n+Nat.add(U32.to_nat(X), 4n), e84(U32.to_nat(X))), A.le_skip(4n, Nat.add(U32.to_nat(X), 4n))),
    h)

# U3: the uint64 read at any offset X with X + 8 <= 4 2^d.
law rd64_any:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +X: U32
  for +hd: {Nat.is_lt(d, 30n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool}
  {O.rd_u64(UA.BF(t, n), X) == (UA.BF(t, n), O.U64{UA.RW(t, X), UA.RW(t, X4(X))}) : B.Buf & O.U64}
def rd64_any(d, t, n, X, hd, pf, h):
  +hd31 = F.nat__lt_trans(d, 30n, 31n, hd, {==})
  %Equal.sym(B.Buf & U32, B.read32(UA.BF(t, n), X), (UA.BF(t, n), UA.RW(t, X)), UA.rd_any(d, t, n, X, hd31, pf, h0(d, X, h))) :
    {O.u64_of(B.read64_lo(X, _)) == (UA.BF(t, n), O.U64{UA.RW(t, X), UA.RW(t, X4(X))}) : B.Buf & O.U64}
  %Equal.sym(B.Buf & U32, B.read32(UA.BF(t, n), X4(X)), (UA.BF(t, n), UA.RW(t, X4(X))), UA.rd_any(d, t, n, X4(X), hd31, pf, h4(d, X, hd, h))) :
    {O.u64_of(B.read64_hi(UA.RW(t, X), _)) == (UA.BF(t, n), O.U64{UA.RW(t, X), UA.RW(t, X4(X))}) : B.Buf & O.U64}
  {==}

# U3, bytes: the limbs of the two words are the spec bytes [X, X + 8).
law rd64_bytes:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +X: U32
  for +hd: {Nat.is_lt(d, 30n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool}
  {FX.limbs([UA.RW(t, X), UA.RW(t, X4(X))]) == VS.bt(8n, VS.bdr(U32.to_nat(X), UA.BYT(t))) : +List<U32>}
def rd64_bytes(d, t, X, hd, pf, h):
  +x = U32.to_nat(X)
  +Y = VS.bdr(x, UA.BYT(t))
  +a = UA.RW(t, X)
  +b = UA.RW(t, X4(X))
  %Equal.sym(+List<U32>, VS.bt(Nat.add(4n, 4n), Y), List.append(&2, U32, VS.bt(4n, Y), VS.bt(4n, VS.bdr(4n, Y))), VBC.bt_split(4n, 4n, Y)) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == _ : +List<U32>}
  %VN.bdr_add(x, 4n, UA.BYT(t)) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, VS.bt(4n, Y), VS.bt(4n, _)) : +List<U32>}
  %ex4(d, X, hd, h) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, VS.bt(4n, Y), VS.bt(4n, VS.bdr(_, UA.BYT(t)))) : +List<U32>}
  %UA.rd_bytes(d, t, X4(X), pf, h4(d, X, hd, h)) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, VS.bt(4n, Y), _) : +List<U32>}
  %UA.rd_bytes(d, t, X, pf, h0(d, X, h)) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, _, List.append(&2, U32, I.limb(b), [])) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, I.limb(a), []), I.limb(a), VS.app_nil(I.limb(a))) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, _, List.append(&2, U32, I.limb(b), [])) : +List<U32>}
  {==}
