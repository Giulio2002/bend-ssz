import Base
import ../../spec/bit_packing.bend as Bp
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../src/merkle_fast.bend as MF
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../compact/buf.bend as BF
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vfix.bend as VF
import ./vcopy.bend as VC
import ./vbytes.bend as VY
import ./vdepth.bend as VD
import ./vu32.bend as VU
import ./vua.bend as UA
import ./vuw_bits.bend as UWB
import ./vuw.bend as UW
import ./vuwd.bend as UWD
import ./word_mul.bend as WM
import ./vbitenc.bend as VBT
import ./vbitdl.bend as DL
import ./vbitcore.bend as CO

# O.put_bits at ANY byte position X = 4 q + r: the byte-range write of the bit list's
# ceil(K / 8) bytes (vuwd's put_words), then the delimiter byte OR-ed in at X + K / 8.
# Its bytes are the spec's packing of the bits and the delimiter (vbitcore's enc_core at
# offset 0), then zeros to the end of the last word written.

# ---- a byte OR-ed into a byte list ------------------------------------------------------------

def ORB(L: +List<U32>, +i: Nat, +v: U32) -> +List<U32>:
  match L i:
    case Nil{} _: []
    case Con{+h, t} 0n: Con{U32.or(h, v), t}
    case Con{+h, t} 1n+p: Con{h, ORB(t, p, v)}

# A byte at byte s of a word (O.shl_bytes with the byte index as a Nat).
def SHB(+v: U32, +s: Nat) -> U32:
  match s:
    case 0n: v
    case 1n: U32.mul(v, 256)
    case 2n: U32.mul(v, 65536)
    case 3n: U32.mul(v, 16777216)
    case 4n+t: v

law len_orb:
  for +L: +List<U32>
  for +i: Nat
  for +v: U32
  {List.length(&2, U32, ORB(L, i, v)) == List.length(&2, U32, L) : Nat}
def len_orb(L, i, v):
  match L i:
    case Nil{} _: {==}
    case Con{+h, +t} 0n: {==}
    case Con{+h, +t} 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, List.length(&2, U32, ORB(t, p, v)), List.length(&2, U32, t), len_orb(t, p, v))

# Past a prefix A.
law orb_app:
  for +A0: +List<U32>
  for +j: Nat
  for +R: +List<U32>
  for +v: U32
  {ORB(List.append(&2, U32, A0, R), Nat.add(List.length(&2, U32, A0), j), v) == List.append(&2, U32, A0, ORB(R, j, v)) : +List<U32>}
def orb_app(A0, j, R, v):
  match A0:
    case Nil{}: {==}
    case Con{+h, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{h, z}, ORB(List.append(&2, U32, t, R), Nat.add(List.length(&2, U32, t), j), v), List.append(&2, U32, t, ORB(R, j, v)), orb_app(t, j, R, v))

# Inside a prefix A.
law orb_app_l:
  for +A0: +List<U32>
  for +j: Nat
  for +R: +List<U32>
  for +v: U32
  for +h: {Nat.is_lt(j, List.length(&2, U32, A0)) == True{} : Bool}
  {ORB(List.append(&2, U32, A0, R), j, v) == List.append(&2, U32, ORB(A0, j, v), R) : +List<U32>}
def orb_app_l(A0, j, R, v, h):
  match A0 j:
    case Nil{} _: Empty.absurd({ORB(List.append(&2, U32, Nil{}, R), j, v) == List.append(&2, U32, ORB(Nil{}, j, v), R) : +List<U32>}, FD.nat__lt_zero_absurd(j, h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, ORB(List.append(&2, U32, t, R), p, v), List.append(&2, U32, ORB(t, p, v), R), orb_app_l(t, p, R, v, h))

# Inside a prefix of n bytes.
law orb_bt:
  for +n: Nat
  for +L: +List<U32>
  for +j: Nat
  for +v: U32
  for +h: {Nat.is_lt(j, n) == True{} : Bool}
  {ORB(VS.bt(n, L), j, v) == VS.bt(n, ORB(L, j, v)) : +List<U32>}
def orb_bt(n, L, j, v, h):
  match n L j:
    case 0n _ _: {==}
    case 1n+ +p Nil{} _: {==}
    case 1n+ +p Con{+x, +t} 0n: {==}
    case 1n+ +p Con{+x, +t} 1n+ +k: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, ORB(VS.bt(p, t), k, v), VS.bt(p, ORB(t, k, v)), orb_bt(p, t, k, v, h))

# Inside a splice's bytes.
def orb_spl(+B: +List<U32>, +X: Nat, +Y: +List<U32>, +j: Nat, +v: U32,
    +hX: {Nat.is_le(X, List.length(&2, U32, B)) == True{} : Bool}, +h: {Nat.is_lt(j, List.length(&2, U32, Y)) == True{} : Bool})
    -> {ORB(UW.SPL(B, X, Y), Nat.add(X, j), v) == UW.SPL(B, X, ORB(Y, j, v)) : +List<U32>}:
  +P = VS.bt(X, B)
  +R = VS.bdr(Nat.add(X, List.length(&2, U32, Y)), B)
  +eP = VS.bt_len(X, B, hX)
  +e1 = FD.logic__subst(Nat, z => {ORB(List.append(&2, U32, P, List.append(&2, U32, Y, R)), Nat.add(z, j), v) == List.append(&2, U32, P, ORB(List.append(&2, U32, Y, R), j, v)) : +List<U32>},
    List.length(&2, U32, P), X, eP, orb_app(P, j, List.append(&2, U32, Y, R), v))
  +e2 = Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, P, z), ORB(List.append(&2, U32, Y, R), j, v), List.append(&2, U32, ORB(Y, j, v), R), orb_app_l(Y, j, R, v, h))
  +e3 = Equal.cong(Nat, +List<U32>, z => List.append(&2, U32, P, List.append(&2, U32, ORB(Y, j, v), VS.bdr(Nat.add(X, z), B))), List.length(&2, U32, Y), List.length(&2, U32, ORB(Y, j, v)),
    Equal.sym(Nat, List.length(&2, U32, ORB(Y, j, v)), List.length(&2, U32, Y), len_orb(Y, j, v)))
  Equal.trans(+List<U32>, ORB(UW.SPL(B, X, Y), Nat.add(X, j), v), List.append(&2, U32, P, ORB(List.append(&2, U32, Y, R), j, v)), UW.SPL(B, X, ORB(Y, j, v)), e1,
    Equal.trans(+List<U32>, List.append(&2, U32, P, ORB(List.append(&2, U32, Y, R), j, v)), List.append(&2, U32, P, List.append(&2, U32, ORB(Y, j, v), R)), UW.SPL(B, X, ORB(Y, j, v)), e2, e3))

# ---- a byte OR-ed into a word of the tree -----------------------------------------------------

def shb_l(+w: U32, +v: U32, +s: Nat, +hs: {Nat.is_lt(s, 4n) == True{} : Bool})
    -> {I.limb(U32.or(w, SHB(U32.and(v, 255), s))) == ORB(I.limb(w), s, U32.and(v, 255)) : +List<U32>}:
  match s:
    case 0n: UWB.orbl0(w, v)
    case 1n:
      %Equal.sym(U32, U32.mul(U32.and(v, 255), 256), U32.shln(U32.and(v, 255), 8n), WM.mul256(U32.and(v, 255))) : {I.limb(U32.or(w, _)) == ORB(I.limb(w), 1n, U32.and(v, 255)) : +List<U32>}
      UWB.orbl1(w, v)
    case 2n:
      %Equal.sym(U32, U32.mul(U32.and(v, 255), 65536), U32.shln(U32.and(v, 255), 16n), WM.mul65536(U32.and(v, 255))) : {I.limb(U32.or(w, _)) == ORB(I.limb(w), 2n, U32.and(v, 255)) : +List<U32>}
      UWB.orbl2(w, v)
    case 3n:
      %Equal.sym(U32, U32.mul(U32.and(v, 255), 16777216), U32.shln(U32.and(v, 255), 24n), WM.mul16777216(U32.and(v, 255))) : {I.limb(U32.or(w, _)) == ORB(I.limb(w), 3n, U32.and(v, 255)) : +List<U32>}
      UWB.orbl3(w, v)
    case 4n+ +t: Empty.absurd({I.limb(U32.or(w, SHB(U32.and(v, 255), 4n+t))) == ORB(I.limb(w), 4n+t, U32.and(v, 255)) : +List<U32>}, FD.nat__lt_zero_absurd(t, hs))

# Inside a word's limbs, followed by the rest.
def orb_limb(+x: U32, +R: +List<U32>, +s: Nat, +v: U32, +hs: {Nat.is_lt(s, 4n) == True{} : Bool})
    -> {ORB(List.append(&2, U32, I.limb(x), R), s, v) == List.append(&2, U32, ORB(I.limb(x), s, v), R) : +List<U32>}:
  match s:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +t: Empty.absurd({ORB(List.append(&2, U32, I.limb(x), R), 4n+t, v) == List.append(&2, U32, ORB(I.limb(x), 4n+t, v), R) : +List<U32>}, FD.nat__lt_zero_absurd(t, hs))

# The tree's bytes after a byte v is OR-ed in at byte s of word i.
def tor(+dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +s: Nat, +v: U32,
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(dd)) == True{} : Bool}, +hs: {Nat.is_lt(s, 4n) == True{} : Bool})
    -> {UA.BYT(UW.ORW(dd, D, i, SHB(U32.and(v, 255), s))) == ORB(UA.BYT(D), Nat.add(A.quad(i), s), U32.and(v, 255)) : +List<U32>}:
  +SL = UW.SLW(D)
  +x = FD.flat__nthc(UW.SLW(D), i)
  +vb = U32.and(v, 255)
  +val = U32.or(VB.slot(D, i), SHB(U32.and(v, 255), s))
  +hl = FD.array__len_lt(U32, dd, D, i, pf, hi)
  +P = VS.bt(A.quad(i), FX.limbs(UW.SLW(D)))
  +R = VS.bdr(4n+A.quad(i), FX.limbs(UW.SLW(D)))
  +hq = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(i), z) == True{} : Bool}, A.quad(VB.len(SL)), List.length(&2, U32, FX.limbs(SL)), Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL)), A.quad(VB.len(SL)), UW.len_limbs_v(SL)),
    UW.quad_le(i, VB.len(SL), FD.nat__lt_le(i, VB.len(SL), hl)))
  +eP = VS.bt_len(A.quad(i), FX.limbs(SL), hq)
  # the new bytes
  +e1 = Equal.trans(+List<U32>, UA.BYT(UW.ORW(dd, D, i, SHB(vb, s))), FX.limbs(FD.spec_common__update(U32, SL, i, val)), List.append(&2, U32, P, List.append(&2, U32, I.limb(val), R)),
    Equal.cong(List<&2, U32>, +List<U32>, z => FX.limbs(z), UW.SLW(UW.ORW(dd, D, i, SHB(vb, s))), FD.spec_common__update(U32, SL, i, val), FD.array__upd_slots(U32, dd, D, i, val, hi, pf)),
    UW.limbs_upd(SL, i, val, hl))
  +e2 = Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, P, List.append(&2, U32, z, R)), I.limb(val), ORB(I.limb(x), s, vb), shb_l(x, v, s, hs))
  # the old bytes, split at word i
  +e3 = Equal.trans(+List<U32>, FX.limbs(SL), FX.limbs(FD.spec_common__update(U32, SL, i, x)), List.append(&2, U32, P, List.append(&2, U32, I.limb(x), R)),
    Equal.cong(List<&2, U32>, +List<U32>, z => FX.limbs(z), SL, FD.spec_common__update(U32, SL, i, x), Equal.sym(List<&2, U32>, FD.spec_common__update(U32, SL, i, x), SL, UW.upd_same_l(SL, i))),
    UW.limbs_upd(SL, i, x, hl))
  +e4 = Equal.trans(+List<U32>, ORB(FX.limbs(SL), Nat.add(A.quad(i), s), vb), ORB(List.append(&2, U32, P, List.append(&2, U32, I.limb(x), R)), Nat.add(A.quad(i), s), vb), List.append(&2, U32, P, ORB(List.append(&2, U32, I.limb(x), R), s, vb)),
    Equal.cong(+List<U32>, +List<U32>, z => ORB(z, Nat.add(A.quad(i), s), vb), FX.limbs(SL), List.append(&2, U32, P, List.append(&2, U32, I.limb(x), R)), e3),
    FD.logic__subst(Nat, z => {ORB(List.append(&2, U32, P, List.append(&2, U32, I.limb(x), R)), Nat.add(z, s), vb) == List.append(&2, U32, P, ORB(List.append(&2, U32, I.limb(x), R), s, vb)) : +List<U32>},
      List.length(&2, U32, P), A.quad(i), eP, orb_app(P, s, List.append(&2, U32, I.limb(x), R), vb)))
  +e5 = Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, P, z), ORB(List.append(&2, U32, I.limb(x), R), s, vb), List.append(&2, U32, ORB(I.limb(x), s, vb), R), orb_limb(x, R, s, vb, hs))
  Equal.trans(+List<U32>, UA.BYT(UW.ORW(dd, D, i, SHB(vb, s))), List.append(&2, U32, P, List.append(&2, U32, ORB(I.limb(x), s, vb), R)), ORB(UA.BYT(D), Nat.add(A.quad(i), s), vb),
    Equal.trans(+List<U32>, UA.BYT(UW.ORW(dd, D, i, SHB(vb, s))), List.append(&2, U32, P, List.append(&2, U32, I.limb(val), R)), List.append(&2, U32, P, List.append(&2, U32, ORB(I.limb(x), s, vb), R)), e1, e2),
    Equal.sym(+List<U32>, ORB(UA.BYT(D), Nat.add(A.quad(i), s), vb), List.append(&2, U32, P, List.append(&2, U32, ORB(I.limb(x), s, vb), R)),
      Equal.trans(+List<U32>, ORB(FX.limbs(SL), Nat.add(A.quad(i), s), vb), List.append(&2, U32, P, ORB(List.append(&2, U32, I.limb(x), R), s, vb)), List.append(&2, U32, P, List.append(&2, U32, ORB(I.limb(x), s, vb), R)), e4, e5)))
