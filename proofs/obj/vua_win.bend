import Base
import ../../spec/primitives.bend as SP
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vbitl.bend as VBL
import ./vlist.bend as VL
import ./vbytes.bend as VBY
import ./vbrt.bend as VR
import ./vua.bend as UA

# The unaligned-offset layer, U4 (windows): the spec bytes of a window at ANY
# byte position x of a buffer, WX(t, x, L) = bytes [x, x + L), and the facts
# the window modules use about them (VR's word-aligned WB(t, i, L) is
# WX(t, 4 i, L)).
#
# The byte-offset window interface. A module for type X read at the window
# [off, off + len) of a buffer BF(t, n), off at byte position x, exports
#
#   CHKw(t, x, off, len) : Bool      X's validator's result on the window;
#   ok_evalw(d, t, n, x, off, len, eo, hd, hw, pf)
#       {T.X_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len))};
#   OBJw(d, t, x, off, len)          the object the reader builds;
#   readw(d, t, n, x, off, len, eo, hd, hw, pf, hchk)
#       {T.X_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len))};
#   VALw(t, x, len) : S.Value        its spec value;
#   specw(d, t, n, x, off, len, eo, hd, hw, pf, hchk)
#       {Codec.parts(VALw(t, x, len), SCH) == Some{[S.Variable{WX(t, x, U32.to_nat(len))}]}};
#   invw(d, t, n, x, off, len, eo, hd, hw, pf, v, e)
#       every v with {Codec.parts(v, SCH) == Some{[S.Variable{WX(t, x, U32.to_nat(len))}]}}
#       has {CHKw(t, x, off, len) == True{}};
#
# with hchk: {CHKw(t, x, off, len) == True{}} and, for a perfect word tree t
# of depth d (pf: {F.array__perfect(U32, d, t) == True{}}),
#
#   eo: {U32.to_nat(off) == x : Nat}
#   hd: {Nat.is_lt(d, 28n) == True{} : Bool}
#   hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}
#
# (the word-aligned modules of codegen/var_win.py are the case x = 4 i, with
# i for x and VR.WB(t, i, L) for WX). Runtime reads at any offset: UA.rd_any
# (four bytes), vua_rd.rd64_any (uint64), VR.byte_at_ok (a byte),
# vua_ct.copy_in_at (any length; its storage CT, whose bytes are ct_bytes),
# with hsx below for copy_in_at's room.

def WX(+t: F.array__Tree<U32>, +x: Nat, +L: Nat) -> +List<U32>: VS.bt(L, VS.bdr(x, UA.BYT(t)))

def lenWX(+d: Nat, +t: F.array__Tree<U32>, +x: Nat, +L: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, L), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, WX(t, x, L)) == L : Nat}:
  VS.bt_len(L, VS.bdr(x, UA.BYT(t)), VR.bdr_len(x, UA.BYT(t), L,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, L), z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, UA.BYT(t)),
      Equal.sym(Nat, List.length(&2, U32, UA.BYT(t)), A.quad(VB.pw(d)), VR.lenS(d, t, pf)), hw)))

# The window's last spec byte is the byte the runtime reads at X = x + m.
def lastWX(+d: Nat, +t: F.array__Tree<U32>, +x: Nat, +m: Nat, +X: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, 1n+m), A.quad(VB.pw(d))) == True{} : Bool},
    +eX: {U32.to_nat(X) == Nat.add(x, m) : Nat})
    -> {VBL.lastb(WX(t, x, 1n+m)) == VR.VX(t, X) : U32}:
  +hr = F.nat__le_lt_trans(VR.RX(X), 3n, 4n, RD.and_le(X, 3), {==})
  %Equal.sym(U32, VBL.lastb(WX(t, x, 1n+m)), VBL.nthb(WX(t, x, 1n+m), m), VR.last_len(WX(t, x, 1n+m), m, lenWX(d, t, x, 1n+m, pf, hw))) : {_ == VR.VX(t, X) : U32}
  %Equal.sym(U32, VBL.nthb(WX(t, x, 1n+m), m), VBL.nthb(VS.bdr(x, UA.BYT(t)), m), VR.nth_bt(1n+m, VS.bdr(x, UA.BYT(t)), m, F.nat__lt_succ(m))) :
    {_ == VR.VX(t, X) : U32}
  %Equal.sym(U32, VBL.nthb(VS.bdr(x, UA.BYT(t)), m), VBL.nthb(UA.BYT(t), Nat.add(x, m)), VR.nth_bdr(x, UA.BYT(t), m)) :
    {_ == VR.VX(t, X) : U32}
  %eX : {VBL.nthb(UA.BYT(t), _) == VR.VX(t, X) : U32}
  %Equal.sym(Nat, U32.to_nat(X), Nat.add(A.quad(VR.QX(X)), VR.RX(X)), VC.split4(X)) : {VBL.nthb(UA.BYT(t), _) == VR.VX(t, X) : U32}
  %Equal.sym(U32, VBL.nthb(UA.BYT(t), Nat.add(A.quad(VR.QX(X)), VR.RX(X))), VR.bsN(VR.RX(X), VB.slot(t, VR.QX(X))), VR.nth_limbs(VR.SL(t), VR.QX(X), VR.RX(X), hr)) :
    {_ == VR.VX(t, X) : U32}
  Equal.sym(U32, VR.VX(t, X), VR.bsN(VR.RX(X), VB.slot(t, VR.QX(X))), VR.bs_eq(U32.and(X, 3), VB.slot(t, VR.QX(X)), VR.RX(X), {==}, hr))

def domWX(+t: F.array__Tree<U32>, +x: Nat, +L: Nat) -> {SP.bytes_domain(WX(t, x, L)) == True{} : Bool}:
  VR.dom_bt(L, VS.bdr(x, UA.BYT(t)), VR.dom_bdr(x, UA.BYT(t), FX.domain_limbs(VR.SL(t))))

# The last byte's position: x + m, for a window x + (1 + m) <= 4 2^d.
def eXN(+d: Nat, +off: U32, +x: Nat, +n: U32, +m: Nat, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(n)), A.quad(VB.pw(d))) == True{} : Bool},
    +e1: {U32.to_nat(n) == 1n+m : Nat})
    -> {U32.to_nat(VR.XN(off, n)) == Nat.add(x, m) : Nat}:
  +h0 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(2n+d)) == True{} : Bool}, Nat.add(x, U32.to_nat(n)), Nat.add(U32.to_nat(n), x), F.nat__add_comm(x, U32.to_nat(n)), hw)
  +ea = VB.add_le_at(off, n, x, 2n+d, eo, hd, h0)
  +ea2 = Equal.trans(Nat, U32.to_nat(U32.add(off, n)), Nat.add(U32.to_nat(n), x), 1n+Nat.add(m, x), ea,
    Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(n), 1n+m, e1))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+Nat.add(m, x), U32.to_nat(U32.add(off, n)), Equal.sym(Nat, U32.to_nat(U32.add(off, n)), 1n+Nat.add(m, x), ea2), F.nat__zero_le(Nat.add(m, x)))
  %Equal.sym(Nat, U32.to_nat(VR.XN(off, n)), Nat.sub(U32.to_nat(U32.add(off, n)), 1n), F.u32__sub_nat(U32.add(off, n), 1, h1)) : {_ == Nat.add(x, m) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(off, n)), 1n+Nat.add(m, x), ea2) : {Nat.sub(_, 1n) == Nat.add(x, m) : Nat}
  %Equal.sym(Nat, Nat.sub(Nat.add(1n, Nat.add(m, x)), 1n), Nat.add(m, x), F.nat__add_sub_cancel(1n, Nat.add(m, x))) : {_ == Nat.add(x, m) : Nat}
  F.nat__add_comm(m, x)

# The window's words lie in the buffer: ceil(L / 4) + (off >> 2) <= 2^d.
def hsx(+d: Nat, +off: U32, +x: Nat, +L: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}:
  +q = VR.QX(off)
  +ex = Equal.trans(Nat, x, U32.to_nat(off), Nat.add(A.quad(q), VR.RX(off)), Equal.sym(Nat, U32.to_nat(off), x, eo), VC.split4(off))
  +hq = F.logic__subst(Nat, z => {Nat.is_le(A.quad(q), z) == True{} : Bool}, Nat.add(A.quad(q), VR.RX(off)), x, Equal.sym(Nat, x, Nat.add(A.quad(q), VR.RX(off)), ex), F.nat__le_add_right(A.quad(q), VR.RX(off)))
  +hL = F.nat__le_trans(U32.to_nat(L), Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(L)), hw)
  VBY.nw_room(q, L, VB.pw(d), VL.KK(d), VL.kk_lt(d, hd), VL.hyn(d, L, hL),
    F.nat__le_trans(Nat.add(A.quad(q), U32.to_nat(L)), Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d)), Order.add_right(A.quad(q), x, U32.to_nat(L), hq), hw))
