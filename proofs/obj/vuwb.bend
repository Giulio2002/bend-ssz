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
import ./var_bits_enc_bw.bend as BW

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

# ---- arithmetic -------------------------------------------------------------------------------

def MOD4(+c: Nat) -> Nat: Nat.sub(c, A.quad(VD.s_rng(2n, c)))

# ceil(x / 4) <= floor(x / 4) + 1
law ns:
  for +x: Nat
  {Nat.is_le(VD.s_rng(2n, 3n+x), 1n+VD.s_rng(2n, x)) == True{} : Bool}
def ns(x):
  match x:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +y: ns(y)

# y <= 4 ceil(y / 4)
law ceilq:
  for +y: Nat
  {Nat.is_le(y, A.quad(VD.s_rng(2n, 3n+y))) == True{} : Bool}
def ceilq(y):
  match y:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +z: ceilq(z)

law m4lt:
  for +c: Nat
  {Nat.is_lt(MOD4(c), 4n) == True{} : Bool}
def m4lt(c):
  match c:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +y: m4lt(y)

def dm4(+c: Nat) -> {Nat.add(A.quad(VD.s_rng(2n, c)), MOD4(c)) == c : Nat}:
  FD.nat__sub_add(c, A.quad(VD.s_rng(2n, c)), VY.rng2_quad_le(c))

law le_sub:
  for +r: Nat
  for +x: Nat
  for +Y: Nat
  for +h: {Nat.is_le(Nat.add(r, x), Y) == True{} : Bool}
  {Nat.is_le(x, Nat.sub(Y, r)) == True{} : Bool}
def le_sub(r, x, Y, h):
  match r Y:
    case 0n _:
      %Equal.sym(Nat, Nat.sub(Y, 0n), Y, FD.nat__sub_zero(Y)) : {Nat.is_le(x, _) == True{} : Bool}
      h
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(x, Nat.sub(0n, 1n+p)) == True{} : Bool}, FD.logic__false_true(h))
    case 1n+ +p 1n+ +Z: le_sub(p, x, Z, h)

law sub_mono_l:
  for +r: Nat
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.sub(a, r), Nat.sub(b, r)) == True{} : Bool}
def sub_mono_l(r, a, b, h):
  match r a b:
    case 0n _ _:
      %Equal.sym(Nat, Nat.sub(a, 0n), a, FD.nat__sub_zero(a)) : {Nat.is_le(_, Nat.sub(b, 0n)) == True{} : Bool}
      %Equal.sym(Nat, Nat.sub(b, 0n), b, FD.nat__sub_zero(b)) : {Nat.is_le(a, _) == True{} : Bool}
      h
    case 1n+ +k 0n _: FD.nat__zero_le(Nat.sub(b, 1n+k))
    case 1n+ +k 1n+ +a2 0n: Empty.absurd({Nat.is_le(Nat.sub(1n+a2, 1n+k), Nat.sub(0n, 1n+k)) == True{} : Bool}, FD.logic__false_true(h))
    case 1n+ +k 1n+ +a2 1n+ +b2: sub_mono_l(k, a2, b2, h)

# The bytes a value of x bytes at byte r of a word covers to the end of its last word.
def winx(+r: Nat, +x: Nat) -> {Nat.add(x, UWD.PADB(r, x)) == Nat.sub(A.quad(UWD.NWN(Nat.add(r, x))), r) : Nat}:
  +Y = A.quad(UWD.NWN(Nat.add(r, x)))
  FD.nat__sub_add(Nat.sub(Y, r), x, le_sub(r, x, Y, ceilq(Nat.add(r, x))))

# NWN(r + x) <= NWN(r + (1 + x))
def nwn_mono(+r: Nat, +x: Nat) -> {Nat.is_le(UWD.NWN(Nat.add(r, x)), UWD.NWN(Nat.add(r, 1n+x))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(r, 1n+x), 1n+Nat.add(r, x), FD.nat__add_succ(r, x)) : {Nat.is_le(UWD.NWN(Nat.add(r, x)), UWD.NWN(_)) == True{} : Bool}
  ns(Nat.add(r, x))

def wmono(+r: Nat, +x: Nat) -> {Nat.is_le(Nat.add(x, UWD.PADB(r, x)), Nat.add(1n+x, UWD.PADB(r, 1n+x))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(x, UWD.PADB(r, x)), Nat.sub(A.quad(UWD.NWN(Nat.add(r, x))), r), winx(r, x)) : {Nat.is_le(_, Nat.add(1n+x, UWD.PADB(r, 1n+x))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(1n+x, UWD.PADB(r, 1n+x)), Nat.sub(A.quad(UWD.NWN(Nat.add(r, 1n+x))), r), winx(r, 1n+x)) : {Nat.is_le(Nat.sub(A.quad(UWD.NWN(Nat.add(r, x))), r), _) == True{} : Bool}
  sub_mono_l(r, A.quad(UWD.NWN(Nat.add(r, x))), A.quad(UWD.NWN(Nat.add(r, 1n+x))), UW.quad_le(UWD.NWN(Nat.add(r, x)), UWD.NWN(Nat.add(r, 1n+x)), nwn_mono(r, x)))

# x = 4 Q + R, R < 4: x >> 2 is Q.
def T4q(+x: U32, +Q: Nat, +R: Nat, +e: {U32.to_nat(x) == Nat.add(A.quad(Q), R) : Nat}, +hR: {Nat.is_lt(R, 4n) == True{} : Bool})
    -> {U32.to_nat(U32.shrn(x, 2n)) == Q : Nat}:
  +Qx = U32.to_nat(U32.shrn(x, 2n))
  +Rx = U32.to_nat(U32.and(x, 3))
  +e1 = Equal.trans(Nat, Nat.add(Nat.mul(Qx, 4n), Rx), Nat.add(A.quad(Qx), Rx), Nat.add(Nat.mul(Q, 4n), R),
    Equal.cong(Nat, Nat, z => Nat.add(z, Rx), Nat.mul(Qx, 4n), A.quad(Qx), VC.quad_mul(Qx)),
    Equal.trans(Nat, Nat.add(A.quad(Qx), Rx), U32.to_nat(x), Nat.add(Nat.mul(Q, 4n), R), Equal.sym(Nat, U32.to_nat(x), Nat.add(A.quad(Qx), Rx), VC.split4(x)),
      Equal.trans(Nat, U32.to_nat(x), Nat.add(A.quad(Q), R), Nat.add(Nat.mul(Q, 4n), R), e,
        Equal.cong(Nat, Nat, z => Nat.add(z, R), A.quad(Q), Nat.mul(Q, 4n), Equal.sym(Nat, Nat.mul(Q, 4n), A.quad(Q), VC.quad_mul(Q))))))
  Pair.fst({Qx == Q : Nat}, {Rx == R : Nat}, VU.dm_unique(Qx, Rx, Q, R, 4n, e1, FD.nat__le_lt_trans(Rx, 3n, 4n, RD.and_le(x, 3), {==}), hR))

# O.shl_bytes by the low two bits of a word, as SHB of their value.
def shb_b(+b0: Bool, +b1: Bool, +v: U32) -> {O.shl_bytes(v, U32{WCon{b0, WCon{b1, Word.zero(30n)}}}) == SHB(v, U32.to_nat(U32{WCon{b0, WCon{b1, Word.zero(30n)}}})) : U32}:
  match b0 b1:
    case False{} False{}: {==}
    case True{} False{}: {==}
    case False{} True{}: {==}
    case True{} True{}: {==}
def shb_u(+v: U32, +a: U32) -> {O.shl_bytes(v, U32.and(a, 3)) == SHB(v, U32.to_nat(U32.and(a, 3))) : U32}:
  %Equal.sym(U32, U32.and(a, 3), U32{WCon{UWD.LB0(a), WCon{UWD.LB1(a), Word.zero(30n)}}}, UWD.rmv(a)) : {O.shl_bytes(v, _) == SHB(v, U32.to_nat(_)) : U32}
  shb_b(UWD.LB0(a), UWD.LB1(a), v)

# r + (x + 1) == 1 + (r + x)
def a1(+r: Nat, +x: Nat) -> {Nat.add(r, Nat.add(x, 1n)) == 1n+Nat.add(r, x) : Nat}:
  Equal.trans(Nat, Nat.add(r, Nat.add(x, 1n)), Nat.add(Nat.add(r, x), 1n), 1n+Nat.add(r, x),
    Equal.sym(Nat, Nat.add(Nat.add(r, x), 1n), Nat.add(r, Nat.add(x, 1n)), FD.nat__add_assoc(r, x, 1n)),
    Equal.trans(Nat, Nat.add(Nat.add(r, x), 1n), 1n+Nat.add(Nat.add(r, x), 0n), 1n+Nat.add(r, x), FD.nat__add_succ(Nat.add(r, x), 0n),
      Equal.cong(Nat, Nat, z => 1n+z, Nat.add(Nat.add(r, x), 0n), Nat.add(r, x), FD.nat__add_zero(Nat.add(r, x)))))

# (b + 7) / 8 == 1 for 0 < b <= 7
def cb(+b: Nat, +h0: {Nat.is_eq(b, 0n) == False{} : Bool}, +h7: {Nat.is_le(b, 7n) == True{} : Bool}) -> {VD.s_rng(3n, Nat.add(b, 7n)) == 1n : Nat}:
  match b:
    case 0n: Empty.absurd({VD.s_rng(3n, Nat.add(0n, 7n)) == 1n : Nat}, FD.logic__true_false(h0))
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n: {==}
    case 5n: {==}
    case 6n: {==}
    case 7n: {==}
    case 8n+ +t: Empty.absurd({VD.s_rng(3n, Nat.add(8n+t, 7n)) == 1n : Nat}, FD.logic__false_true(h7))

# ---- the bit list writer at any byte -----------------------------------------------------------

def DB(+K: U32) -> U32: U32.and(MF.shl_by(1, U32.and(K, 7)), 255)
def CK(+r: Nat, +K: U32) -> Nat: Nat.add(r, VBT.AK(K))

# put_words of the K bits' bytes, then the delimiter byte OR-ed in at byte X + K / 8.
def PBX(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +K: U32) -> FD.array__Tree<U32>:
  UW.ORW(dd, UWD.PWM(r, dd, D, q, T, O.bits_nbytes(K)), Nat.add(q, VD.s_rng(2n, CK(r, K))), SHB(DB(K), MOD4(CK(r, K))))

def pbx_perfect(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +K: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PBX(r, dd, D, q, T, K)) == True{} : Bool}:
  UW.orw_perfect(dd, UWD.PWM(r, dd, D, q, T, O.bits_nbytes(K)), Nat.add(q, VD.s_rng(2n, CK(r, K))), SHB(DB(K), MOD4(CK(r, K))), UWD.pwm_perfect(r, dd, D, q, T, O.bits_nbytes(K), pf))

# The room of the bytes put_words writes, from the room of the wire size K / 8 + 1.
def nbhl(+zb: Bool, +K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: VBT.HK(K, kb), +r: Nat, +q: Nat, +dd: Nat,
    +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, Nat.add(VBT.AK(K), 1n)))), VB.pw(dd)) == True{} : Bool},
    +ezb: {Nat.is_eq(VBT.BKk(K), 0n) == zb : Bool})
    -> {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, U32.to_nat(O.bits_nbytes(K))))), VB.pw(dd)) == True{} : Bool}:
  match zb:
    case False{}:
      +AK = VBT.AK(K)
      +enb = Equal.trans(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK, VD.s_rng(3n, Nat.add(VBT.BKk(K), 7n))), Nat.add(AK, 1n), VBT.E3(K, kb, hkb, hK),
        Equal.cong(Nat, Nat, z => Nat.add(AK, z), VD.s_rng(3n, Nat.add(VBT.BKk(K), 7n)), 1n, cb(VBT.BKk(K), ezb, RD.and_le(K, 7))))
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, Nat.add(AK, 1n), U32.to_nat(O.bits_nbytes(K)), Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK, 1n), enb), hl)
    case True{}:
      +AK = VBT.AK(K)
      +e0 = FD.nat__eq_from_is_eq(VBT.BKk(K), 0n, ezb)
      +enb = Equal.trans(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK, VD.s_rng(3n, Nat.add(VBT.BKk(K), 7n))), AK, VBT.E3(K, kb, hkb, hK),
        Equal.trans(Nat, Nat.add(AK, VD.s_rng(3n, Nat.add(VBT.BKk(K), 7n))), Nat.add(AK, 0n), AK,
          Equal.cong(Nat, Nat, z => Nat.add(AK, VD.s_rng(3n, Nat.add(z, 7n))), VBT.BKk(K), 0n, e0), FD.nat__add_zero(AK)))
      +hm = FD.logic__subst(Nat, z => {Nat.is_le(UWD.NWN(Nat.add(r, AK)), UWD.NWN(Nat.add(r, z))) == True{} : Bool}, 1n+AK, Nat.add(AK, 1n), FD.nat__add_comm(1n, AK), nwn_mono(r, AK))
      +h2 = FD.nat__le_trans(Nat.add(q, UWD.NWN(Nat.add(r, AK))), Nat.add(q, UWD.NWN(Nat.add(r, Nat.add(AK, 1n)))), VB.pw(dd),
        Order.add_left(q, UWD.NWN(Nat.add(r, AK)), UWD.NWN(Nat.add(r, Nat.add(AK, 1n))), hm), hl)
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, AK, U32.to_nat(O.bits_nbytes(K)), Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), AK, enb), h2)

def nbhz(+zb: Bool, +K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: VBT.HK(K, kb), +r: Nat, +L: +List<U32>,
    +hz: {VS.bt(Nat.add(Nat.add(VBT.AK(K), 1n), UWD.PADB(r, Nat.add(VBT.AK(K), 1n))), L) == UW.ZB(Nat.add(Nat.add(VBT.AK(K), 1n), UWD.PADB(r, Nat.add(VBT.AK(K), 1n)))) : +List<U32>},
    +ezb: {Nat.is_eq(VBT.BKk(K), 0n) == zb : Bool})
    -> {VS.bt(Nat.add(U32.to_nat(O.bits_nbytes(K)), UWD.PADB(r, U32.to_nat(O.bits_nbytes(K)))), L) == UW.ZB(Nat.add(U32.to_nat(O.bits_nbytes(K)), UWD.PADB(r, U32.to_nat(O.bits_nbytes(K))))) : +List<U32>}:
  match zb:
    case False{}:
      +AK = VBT.AK(K)
      +enb = Equal.trans(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK, VD.s_rng(3n, Nat.add(VBT.BKk(K), 7n))), Nat.add(AK, 1n), VBT.E3(K, kb, hkb, hK),
        Equal.cong(Nat, Nat, z => Nat.add(AK, z), VD.s_rng(3n, Nat.add(VBT.BKk(K), 7n)), 1n, cb(VBT.BKk(K), ezb, RD.and_le(K, 7))))
      FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, UWD.PADB(r, z)), L) == UW.ZB(Nat.add(z, UWD.PADB(r, z))) : +List<U32>}, Nat.add(AK, 1n), U32.to_nat(O.bits_nbytes(K)), Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK, 1n), enb), hz)
    case True{}:
      +AK = VBT.AK(K)
      +e0 = FD.nat__eq_from_is_eq(VBT.BKk(K), 0n, ezb)
      +enb = Equal.trans(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK, VD.s_rng(3n, Nat.add(VBT.BKk(K), 7n))), AK, VBT.E3(K, kb, hkb, hK),
        Equal.trans(Nat, Nat.add(AK, VD.s_rng(3n, Nat.add(VBT.BKk(K), 7n))), Nat.add(AK, 0n), AK,
          Equal.cong(Nat, Nat, z => Nat.add(AK, VD.s_rng(3n, Nat.add(z, 7n))), VBT.BKk(K), 0n, e0), FD.nat__add_zero(AK)))
      +W0 = Nat.add(AK, UWD.PADB(r, AK))
      +W1 = Nat.add(Nat.add(AK, 1n), UWD.PADB(r, Nat.add(AK, 1n)))
      +hm = FD.logic__subst(Nat, z => {Nat.is_le(W0, Nat.add(z, UWD.PADB(r, z))) == True{} : Bool}, 1n+AK, Nat.add(AK, 1n), FD.nat__add_comm(1n, AK), wmono(r, AK))
      +eW = FD.nat__sub_add(W1, W0, hm)
      +h2 = UWD.zpre(W0, Nat.sub(W1, W0), L, FD.logic__subst(Nat, z => {VS.bt(z, L) == UW.ZB(z) : +List<U32>}, W1, Nat.add(W0, Nat.sub(W1, W0)), Equal.sym(Nat, Nat.add(W0, Nat.sub(W1, W0)), W1, eW), hz))
      FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, UWD.PADB(r, z)), L) == UW.ZB(Nat.add(z, UWD.PADB(r, z))) : +List<U32>}, AK, U32.to_nat(O.bits_nbytes(K)), Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), AK, enb), h2)

# O.put_bits at any byte position X = 4 q + r (room for its K / 8 + 1 bytes' own words).
def pbx_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +K: U32, +kb: Nat, +KY: Nat, +N: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hKY: {Nat.is_lt(KY, 31n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNY: {Nat.is_le(Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY)) == True{} : Bool}, +hWq: {Nat.is_le(Nat.add(VBT.QK(K), 1n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, U32.to_nat(CO.NK(K))))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(O.bits_nbytes(K), 3), VB.slot(T, VY.QL(O.bits_nbytes(K)))) == True{} : Bool},
    +hbz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(CO.NK(K)), UWD.PADB(r, U32.to_nat(CO.NK(K)))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(CO.NK(K)), UWD.PADB(r, U32.to_nat(CO.NK(K))))) : +List<U32>})
    -> {O.put_bits(FD.array__thaw(U32, D), X, O.Bits{FD.array__thaw(U32, T), K}) == (FD.array__thaw(U32, PBX(r, dd, D, q, T, K)), O.Bits{FD.array__thaw(U32, T), K}) : Array<U32> & O.Bits}:
  +NB = O.bits_nbytes(K)
  +AK = VBT.AK(K)
  +c = CK(r, K)
  +f = VD.s_rng(2n, CK(r, K))
  +QD = Nat.add(q, VD.s_rng(2n, CK(r, K)))
  +m = Nat.add(VBT.AK(K), 1n)
  +Y = U32.add(X, U32.shrn(K, 3n))
  +hK = FD.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  +eM = VBT.E4(K, kb, hkb, hK)
  +hl1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, U32.to_nat(CO.NK(K)), m, eM, hl)
  +hz1 = FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, UWD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, UWD.PADB(r, z))) : +List<U32>}, U32.to_nat(CO.NK(K)), m, eM, hz)
  +qk = VBT.QK(K)
  +jk = VBT.JK(K)
  +bk = VBT.BKk(K)
  +rk = DL.RK(K)
  +NWB = VC.NW(O.bits_nbytes(K))
  +hj = FD.nat__le_lt_trans(jk, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = FD.nat__le_lt_trans(bk, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(jk, bk, hj, hb)
  +cA = DL.p1(DL.TA(jk, bk), DL.CB(jk, bk), cf)
  +cB = DL.p1(DL.TB(bk), DL.CC(jk, bk), DL.p2(DL.TA(jk, bk), DL.CB(jk, bk), cf))
  +eNW = Equal.trans(Nat, NWB, Nat.add(qk, VD.s_rng(2n, Nat.add(Nat.add(jk, VD.s_rng(3n, Nat.add(bk, 7n))), 3n))), Nat.add(qk, BW.CWr(rk)),
    VBT.FNWnb(K, kb, hkb, hK, jk, bk, Nat.add(jk, VD.s_rng(3n, Nat.add(bk, 7n))), VD.s_rng(2n, Nat.add(Nat.add(jk, VD.s_rng(3n, Nat.add(bk, 7n))), 3n)), {==}, {==}, {==}, cB, {==}),
    Equal.cong(Nat, Nat, z => Nat.add(qk, z), VD.s_rng(2n, Nat.add(Nat.add(jk, VD.s_rng(3n, Nat.add(bk, 7n))), 3n)), BW.CWr(rk), cA))
  +hNW0 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(qk, 1n)) == True{} : Bool}, Nat.add(qk, BW.CWr(rk)), NWB,
    Equal.sym(Nat, NWB, Nat.add(qk, BW.CWr(rk)), eNW), Order.add_left(qk, BW.CWr(rk), 1n, CO.cwle(rk)))
  +hsrc = FD.nat__le_trans(NWB, Nat.add(qk, 1n), VB.pw(dw), hNW0, hWq)
  +e3 = VBT.E3(K, kb, hkb, hK)
  +hnb = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(VBT.AK(K), 1n)) == True{} : Bool}, Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(bk, 7n))), U32.to_nat(O.bits_nbytes(K)),
    Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(bk, 7n))), e3), Order.add_left(VBT.AK(K), VD.s_rng(3n, Nat.add(bk, 7n)), 1n, cB))
  +hnbN = FD.nat__le_trans(U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), 1n), Nat.add(N, 1n), hnb,
    FD.nat__le_trans(Nat.add(VBT.AK(K), 1n), Nat.add(U32.to_nat(K), 1n), Nat.add(N, 1n), Order.add_right(VBT.AK(K), U32.to_nat(K), 1n, VBT.lAK(K)), Order.add_right(U32.to_nat(K), N, 1n, hN)))
  +hy = FD.nat__le_trans(VC.YL(O.bits_nbytes(K)), Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY), Order.add_left(31n, U32.to_nat(O.bits_nbytes(K)), Nat.add(N, 1n), hnbN), hNY)
  +hlw = nbhl(Nat.is_eq(VBT.BKk(K), 0n), K, kb, hkb, hK, r, q, dd, hl1, {==})
  +hzw = nbhz(Nat.is_eq(VBT.BKk(K), 0n), K, kb, hkb, hK, r, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D)), hz1, {==})
  # the delimiter's word QD and byte MOD4(c): X + K / 8 = 4 QD + MOD4(c)
  +eC = a1(r, AK)
  +hQDl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, UWD.NWN(Nat.add(r, m)), 1n+f,
    Equal.cong(Nat, Nat, z => UWD.NWN(z), Nat.add(r, m), 1n+c, eC), hl1)
  +hQDs = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 1n+f), 1n+QD, FD.nat__add_succ(q, f), hQDl)
  +hQD = FD.nat__succ_le_lt(QD, VB.pw(dd), hQDs)
  +ec4 = Equal.sym(Nat, Nat.add(A.quad(f), MOD4(c)), c, dm4(c))
  +hcq = FD.logic__subst(Nat, z => {Nat.is_lt(z, A.quad(1n+f)) == True{} : Bool}, Nat.add(A.quad(f), MOD4(c)), c, dm4(c),
    FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(f), MOD4(c)), z) == True{} : Bool}, Nat.add(A.quad(f), 4n), A.quad(1n+f), FD.nat__add_comm(A.quad(f), 4n),
      FD.nat__lt_add_left(MOD4(c), 4n, A.quad(f), m4lt(c))))
  +eXq = Equal.trans(Nat, Nat.add(U32.to_nat(X), AK), Nat.add(Nat.add(A.quad(q), r), AK), Nat.add(A.quad(q), c),
    Equal.cong(Nat, Nat, z => Nat.add(z, AK), U32.to_nat(X), Nat.add(A.quad(q), r), e), FD.nat__add_assoc(A.quad(q), r, AK))
  +hbd = FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(2n+dd)) == True{} : Bool}, Nat.add(A.quad(q), c), Nat.add(U32.to_nat(X), AK), Equal.sym(Nat, Nat.add(U32.to_nat(X), AK), Nat.add(A.quad(q), c), eXq),
    FD.nat__le_trans(Nat.add(A.quad(q), c), A.quad(Nat.add(q, 1n+f)), O.pow2n(2n+dd),
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), c), z) == True{} : Bool}, Nat.add(A.quad(q), A.quad(1n+f)), A.quad(Nat.add(q, 1n+f)), VF.quad_add(q, 1n+f),
        Order.add_left(A.quad(q), c, A.quad(1n+f), FD.nat__lt_le(c, A.quad(1n+f), hcq))),
      FD.logic__subst(Nat, z => {Nat.is_le(A.quad(Nat.add(q, 1n+f)), A.quad(z)) == True{} : Bool}, VB.pw(dd), O.pow2n(dd), VD.s_pow2_eq(dd), UW.quad_le(Nat.add(q, 1n+f), VB.pw(dd), hQDl))))
  +eY = Equal.trans(Nat, U32.to_nat(Y), Nat.add(U32.to_nat(X), AK), Nat.add(A.quad(QD), MOD4(c)),
    VD.s_add_nat(X, U32.shrn(K, 3n), 2n+dd, FD.nat__lt_trans(dd, 29n, 30n, hd, {==}), hbd),
    Equal.trans(Nat, Nat.add(U32.to_nat(X), AK), Nat.add(A.quad(q), c), Nat.add(A.quad(QD), MOD4(c)), eXq,
      Equal.trans(Nat, Nat.add(A.quad(q), c), Nat.add(A.quad(q), Nat.add(A.quad(f), MOD4(c))), Nat.add(A.quad(QD), MOD4(c)),
        Equal.cong(Nat, Nat, z => Nat.add(A.quad(q), z), c, Nat.add(A.quad(f), MOD4(c)), ec4),
        Equal.trans(Nat, Nat.add(A.quad(q), Nat.add(A.quad(f), MOD4(c))), Nat.add(Nat.add(A.quad(q), A.quad(f)), MOD4(c)), Nat.add(A.quad(QD), MOD4(c)),
          Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), A.quad(f)), MOD4(c)), Nat.add(A.quad(q), Nat.add(A.quad(f), MOD4(c))), FD.nat__add_assoc(A.quad(q), A.quad(f), MOD4(c))),
          Equal.cong(Nat, Nat, z => Nat.add(z, MOD4(c)), Nat.add(A.quad(q), A.quad(f)), A.quad(QD), VF.quad_add(q, f))))))
  +eQ = T4q(Y, QD, MOD4(c), eY, m4lt(c))
  +eJ = VBT.T4(Y, QD, MOD4(c), eY, m4lt(c))
  +PW = UWD.PWM(r, dd, D, q, T, NB)
  +pw1 = UWD.putw_any(dd, D, X, q, r, dw, T, NB, KY, e, hr, hd, hdw, hKY, hy, hsrc, hlw, pf, pfT, htz, hzw)
  +esh = Equal.trans(U32, O.shl_bytes(DB(K), U32.and(Y, 3)), SHB(DB(K), U32.to_nat(U32.and(Y, 3))), SHB(DB(K), MOD4(c)), shb_u(DB(K), Y),
    Equal.cong(Nat, U32, z => SHB(DB(K), z), U32.to_nat(U32.and(Y, 3)), MOD4(c), eJ))
  +eor = UW.orw_rt(dd, PW, U32.shrn(Y, 2n), QD, SHB(DB(K), MOD4(c)), eQ, FD.nat__lt_trans(dd, 29n, 32n, hd, {==}), hQD, UWD.pwm_perfect(r, dd, D, q, T, NB, pf))
  %Equal.sym(Array<U32> & O.Words, O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), NB}), (FD.array__thaw(U32, PW), O.Words{FD.array__thaw(U32, T), NB}), pw1) :
    {O.bits_fin(K, O.w8_delim(X, K, _)) == (FD.array__thaw(U32, PBX(r, dd, D, q, T, K)), O.Bits{FD.array__thaw(U32, T), K}) : Array<U32> & O.Bits}
  %Equal.sym(U32, O.shl_bytes(DB(K), U32.and(Y, 3)), SHB(DB(K), MOD4(c)), esh) :
    {(O.or_word(FD.array__thaw(U32, PW), U32.shrn(Y, 2n), _), O.Bits{FD.array__thaw(U32, T), K}) == (FD.array__thaw(U32, PBX(r, dd, D, q, T, K)), O.Bits{FD.array__thaw(U32, T), K}) : Array<U32> & O.Bits}
  %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, PW), U32.shrn(Y, 2n), SHB(DB(K), MOD4(c))), FD.array__thaw(U32, UW.ORW(dd, PW, QD, SHB(DB(K), MOD4(c)))), eor) :
    {(_, O.Bits{FD.array__thaw(U32, T), K}) == (FD.array__thaw(U32, PBX(r, dd, D, q, T, K)), O.Bits{FD.array__thaw(U32, T), K}) : Array<U32> & O.Bits}
  {==}
