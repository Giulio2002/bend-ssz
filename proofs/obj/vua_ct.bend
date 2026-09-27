import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vnest.bend as VN
import ./vbrt.bend as VR
import ./vbytes.bend as VBY
import ./vbspec.bend as VBS
import ./vua.bend as UA
import ./vua_copy.bend as UC
import ./vua_sc.bend as USC

# The unaligned-offset layer, U4 (copies): copy_in of any length L at ANY byte
# offset off returns the storage CT(d, t, off, L, dz) (copy_in_at), whose
# first L bytes are the buffer's spec bytes [off, off + L) (ct_bytes). At
# off & 3 = 0 it is vbytes' aligned copy, otherwise vua_sc's shifted one.

def cts(r: Nat, +d: Nat, +t: F.array__Tree<U32>, +off: U32, +L: U32, +dz: Nat) -> F.array__Tree<U32>:
  match r:
    case 0n: VBY.MK(L, dz, VB.mone(VC.NW(L), VR.QX(off), 0n, dz, VC.ZT(dz), t))
    case 1n+q: VBY.MK(L, dz, UC.smone(1n+q, VC.NW(L), VR.QX(off), 0n, dz, d, VC.ZT(dz), t))

def CT(+d: Nat, +t: F.array__Tree<U32>, +off: U32, +L: U32, +dz: Nat) -> F.array__Tree<U32>: cts(VR.RX(off), d, t, off, L, dz)

def ci_rU(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +L: U32, +dz: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +ez: {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, dz, 0) : Array<U32>},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}, +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +r: Nat, +er: {VR.RX(off) == r : Nat}, +hr4: {Nat.is_lt(r, 4n) == True{} : Bool})
    -> {O.copy_in(VR.BF(t, n), off, L) == (VR.BF(t, n), O.Words{F.array__thaw(U32, cts(r, d, t, off, L, dz)), L}) : B.Buf & O.Words}:
  match r:
    case 0n: VBY.copy_in_anyU(d, t, n, off, VR.QX(off), L, dz, pf, hd, hdz, ez, F.u32__injective(U32.and(off, 3), 0, er), {==}, hs, hr, hy)
    case 1n: USC.copy_in_ua1U(d, t, n, off, VR.QX(off), L, dz, pf, hd, hdz, ez, F.u32__injective(U32.and(off, 3), 1, er), {==}, hs, hr, hy)
    case 2n: USC.copy_in_ua2U(d, t, n, off, VR.QX(off), L, dz, pf, hd, hdz, ez, F.u32__injective(U32.and(off, 3), 2, er), {==}, hs, hr, hy)
    case 3n: USC.copy_in_ua3U(d, t, n, off, VR.QX(off), L, dz, pf, hd, hdz, ez, F.u32__injective(U32.and(off, 3), 3, er), {==}, hs, hr, hy)
    case 4n+s: Empty.absurd({O.copy_in(VR.BF(t, n), off, L) == (VR.BF(t, n), O.Words{F.array__thaw(U32, cts(4n+s, d, t, off, L, dz)), L}) : B.Buf & O.Words}, F.nat__lt_zero_absurd(s, hr4))

def ci_r(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +L: U32, +dz: Nat, +k: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +ez: {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, dz, 0) : Array<U32>},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}, +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +r: Nat, +er: {VR.RX(off) == r : Nat}, +hr4: {Nat.is_lt(r, 4n) == True{} : Bool})
    -> {O.copy_in(VR.BF(t, n), off, L) == (VR.BF(t, n), O.Words{F.array__thaw(U32, cts(r, d, t, off, L, dz)), L}) : B.Buf & O.Words}:
  ci_rU(d, t, n, off, L, dz, pf, hd, hdz, ez, hs, hr, VC.hyU(L, k, hk, hy), r, er, hr4)

# U4: copy_in of L bytes at any offset off.
law copy_in_atU:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +off: U32
  for +L: U32
  for +dz: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool}
  for +ez: {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, dz, 0) : Array<U32>}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}
  {O.copy_in(VR.BF(t, n), off, L) == (VR.BF(t, n), O.Words{F.array__thaw(U32, CT(d, t, off, L, dz)), L}) : B.Buf & O.Words}
def copy_in_atU(d, t, n, off, L, dz, pf, hd, hdz, ez, hs, hr, hy):
  ci_rU(d, t, n, off, L, dz, pf, hd, hdz, ez, hs, hr, hy, VR.RX(off), {==}, UA.rx_lt(off))

law copy_in_at:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +off: U32
  for +L: U32
  for +dz: Nat
  for +k: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool}
  for +ez: {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, dz, 0) : Array<U32>}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  {O.copy_in(VR.BF(t, n), off, L) == (VR.BF(t, n), O.Words{F.array__thaw(U32, CT(d, t, off, L, dz)), L}) : B.Buf & O.Words}
def copy_in_at(d, t, n, off, L, dz, k, pf, hd, hdz, ez, hs, hr, hk, hy):
  copy_in_atU(d, t, n, off, L, dz, pf, hd, hdz, ez, hs, hr, VC.hyU(L, k, hk, hy))

def ct_rU(+d: Nat, +t: F.array__Tree<U32>, +off: U32, +L: U32, +dz: Nat, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}, +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +r: Nat, +hr4: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hB: {Nat.is_le(Nat.add(Nat.add(A.quad(VR.QX(off)), r), U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, cts(r, d, t, off, L, dz)))) == VS.bt(U32.to_nat(L), VS.bdr(Nat.add(A.quad(VR.QX(off)), r), UA.BYT(t))) : +List<U32>}:
  match r:
    case 0n:
      +q = VR.QX(off)
      +hsl = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(L), q), z) == True{} : Bool}, VB.pw(d), VB.len(F.array__slots(U32, t)),
        Equal.sym(Nat, VB.len(F.array__slots(U32, t)), VB.pw(d), F.array__slots_length(U32, d, t, pf)), hs)
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), F.nat__add_zero(A.quad(q))) :
        {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, cts(0n, d, t, off, L, dz)))) == VS.bt(U32.to_nat(L), VS.bdr(_, UA.BYT(t))) : +List<U32>}
      %Equal.sym(+List<U32>, VS.bdr(A.quad(q), FX.limbs(F.array__slots(U32, t))), FX.limbs(VS.wdr0(q, F.array__slots(U32, t))), VS.bdr_limbs(q, F.array__slots(U32, t))) :
        {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, cts(0n, d, t, off, L, dz)))) == VS.bt(U32.to_nat(L), _) : +List<U32>}
      %Equal.sym(List<&2, U32>, VS.wdr0(q, F.array__slots(U32, t)), VB.wdr(q, F.array__slots(U32, t)), VN.wdr0_eq(q, F.array__slots(U32, t))) :
        {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, cts(0n, d, t, off, L, dz)))) == VS.bt(U32.to_nat(L), FX.limbs(_)) : +List<U32>}
      VBS.ybytesU(L, dz, q, t, hy, hr, hsl)
    case 1n+ +p: UC.ci_bytesU(1n+p, L, VR.QX(off), dz, d, t, hy, pf, hr4, hs, hr, hB)

def ct_r(+d: Nat, +t: F.array__Tree<U32>, +off: U32, +L: U32, +dz: Nat, +k: Nat,
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}, +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +r: Nat, +hr4: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hB: {Nat.is_le(Nat.add(Nat.add(A.quad(VR.QX(off)), r), U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, cts(r, d, t, off, L, dz)))) == VS.bt(U32.to_nat(L), VS.bdr(Nat.add(A.quad(VR.QX(off)), r), UA.BYT(t))) : +List<U32>}:
  ct_rU(d, t, off, L, dz, VC.hyU(L, k, hk, hy), pf, hs, hr, r, hr4, hB)

# U4: the first L bytes of the copy are the buffer's spec bytes [off, off + L).
law ct_bytesU:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +off: U32
  for +L: U32
  for +dz: Nat
  for +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hB: {Nat.is_le(Nat.add(U32.to_nat(off), U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool}
  {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, CT(d, t, off, L, dz)))) == VS.bt(U32.to_nat(L), VS.bdr(U32.to_nat(off), UA.BYT(t))) : +List<U32>}
def ct_bytesU(d, t, off, L, dz, hy, pf, hs, hr, hB):
  +e = VC.split4(off)
  %Equal.sym(Nat, U32.to_nat(off), Nat.add(A.quad(VR.QX(off)), VR.RX(off)), e) :
    {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, CT(d, t, off, L, dz)))) == VS.bt(U32.to_nat(L), VS.bdr(_, UA.BYT(t))) : +List<U32>}
  ct_rU(d, t, off, L, dz, hy, pf, hs, hr, VR.RX(off), UA.rx_lt(off),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(off), Nat.add(A.quad(VR.QX(off)), VR.RX(off)), e, hB))

law ct_bytes:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +off: U32
  for +L: U32
  for +dz: Nat
  for +k: Nat
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hB: {Nat.is_le(Nat.add(U32.to_nat(off), U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool}
  {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, CT(d, t, off, L, dz)))) == VS.bt(U32.to_nat(L), VS.bdr(U32.to_nat(off), UA.BYT(t))) : +List<U32>}
def ct_bytes(d, t, off, L, dz, k, hk, hy, pf, hs, hr, hB):
  ct_bytesU(d, t, off, L, dz, VC.hyU(L, k, hk, hy), pf, hs, hr, hB)
