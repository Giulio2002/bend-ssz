import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vbrt.bend as VR
import ./vbytes.bend as VBY
import ./vua.bend as UA
import ./vua_sc.bend as USC
import ./vua_ct.bend as UCT

# Byte lists and byte vectors at ANY byte offset: copy_into (the reader of a byte
# vector, into a fresh zero storage of depth dz) of L bytes at off returns the same
# storage UCT.CT(d, t, off, L, dz) as copy_in (vua_ct.copy_in_at).

def cti_r(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +L: U32, +dz: Nat, +k: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}, +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +r: Nat, +er: {VR.RX(off) == r : Nat}, +hr4: {Nat.is_lt(r, 4n) == True{} : Bool})
    -> {O.copy_into(VR.BF(t, n), off, L, Array.new(U32, dz, 0)) == (VR.BF(t, n), O.Words{F.array__thaw(U32, UCT.cts(r, d, t, off, L, dz)), L}) : B.Buf & O.Words}:
  match r:
    case 0n: VBY.copy_into_any(d, t, n, off, VR.QX(off), L, dz, k, pf, hd, hdz, F.u32__injective(U32.and(off, 3), 0, er), {==}, hs, hr, hk, hy)
    case 1n: USC.copy_into_ua1(d, t, n, off, VR.QX(off), L, dz, k, pf, hd, hdz, F.u32__injective(U32.and(off, 3), 1, er), {==}, hs, hr, hk, hy)
    case 2n: USC.copy_into_ua2(d, t, n, off, VR.QX(off), L, dz, k, pf, hd, hdz, F.u32__injective(U32.and(off, 3), 2, er), {==}, hs, hr, hk, hy)
    case 3n: USC.copy_into_ua3(d, t, n, off, VR.QX(off), L, dz, k, pf, hd, hdz, F.u32__injective(U32.and(off, 3), 3, er), {==}, hs, hr, hk, hy)
    case 4n+s: Empty.absurd({O.copy_into(VR.BF(t, n), off, L, Array.new(U32, dz, 0)) == (VR.BF(t, n), O.Words{F.array__thaw(U32, UCT.cts(4n+s, d, t, off, L, dz)), L}) : B.Buf & O.Words}, F.nat__lt_zero_absurd(s, hr4))

# copy_into of L bytes at any offset off.
def copy_into_at(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +L: U32, +dz: Nat, +k: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}, +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool})
    -> {O.copy_into(VR.BF(t, n), off, L, Array.new(U32, dz, 0)) == (VR.BF(t, n), O.Words{F.array__thaw(U32, UCT.CT(d, t, off, L, dz)), L}) : B.Buf & O.Words}:
  cti_r(d, t, n, off, L, dz, k, pf, hd, hdz, hs, hr, hk, hy, VR.RX(off), {==}, UA.rx_lt(off))
