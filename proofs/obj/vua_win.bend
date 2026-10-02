import Base
import ../../spec/primitives.bend as SP
import ../../types/schema.bend as S
import ../../spec/codec.bend as Codec
import ../../spec/schema.bend as SS
import ../../spec/layout.bend as Layout
import ../../proofs/decode_facts.bend as DF
import ../compact/found_generated.bend as F
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
import ./vua_rd.bend as UR
import ./vua_copy.bend as UC
import ./vnest.bend as VN
import ./vbitc.bend as VBC

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

# ---- any tree depth d < 31 ---------------------------------------------------------------------

# The last byte's position x + m, for a window that ends below 2^32.
def eXNw(+off: U32, +x: Nat, +n: U32, +m: Nat, +eo: {U32.to_nat(off) == x : Nat},
    +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(n)), F.spec_common__pow2(32n)) == True{} : Bool},
    +e1: {U32.to_nat(n) == 1n+m : Nat})
    -> {U32.to_nat(VR.XN(off, n)) == Nat.add(x, m) : Nat}:
  +h0 = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(32n)) == True{} : Bool}, Nat.add(x, U32.to_nat(n)), Nat.add(U32.to_nat(n), x), F.nat__add_comm(x, U32.to_nat(n)), hw32)
  +ea = VB.add_lt32(off, n, x, eo, h0)
  +ea2 = Equal.trans(Nat, U32.to_nat(U32.add(off, n)), Nat.add(U32.to_nat(n), x), 1n+Nat.add(m, x), ea,
    Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(n), 1n+m, e1))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+Nat.add(m, x), U32.to_nat(U32.add(off, n)), Equal.sym(Nat, U32.to_nat(U32.add(off, n)), 1n+Nat.add(m, x), ea2), F.nat__zero_le(Nat.add(m, x)))
  %Equal.sym(Nat, U32.to_nat(VR.XN(off, n)), Nat.sub(U32.to_nat(U32.add(off, n)), 1n), F.u32__sub_nat(U32.add(off, n), 1, h1)) : {_ == Nat.add(x, m) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(off, n)), 1n+Nat.add(m, x), ea2) : {Nat.sub(_, 1n) == Nat.add(x, m) : Nat}
  %Equal.sym(Nat, Nat.sub(Nat.add(1n, Nat.add(m, x)), 1n), Nat.add(m, x), F.nat__add_sub_cancel(1n, Nat.add(m, x))) : {_ == Nat.add(x, m) : Nat}
  F.nat__add_comm(m, x)

# The window's words lie in the buffer, the list storage bounded by 31 + L <= 2^k (k < 31).
def hsxBU(+d: Nat, +off: U32, +x: Nat, +L: U32, +eo: {U32.to_nat(off) == x : Nat}, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}:
  +q = VR.QX(off)
  +ex = Equal.trans(Nat, x, U32.to_nat(off), Nat.add(A.quad(q), VR.RX(off)), Equal.sym(Nat, U32.to_nat(off), x, eo), VC.split4(off))
  +hq = F.logic__subst(Nat, z => {Nat.is_le(A.quad(q), z) == True{} : Bool}, Nat.add(A.quad(q), VR.RX(off)), x, Equal.sym(Nat, x, Nat.add(A.quad(q), VR.RX(off)), ex), F.nat__le_add_right(A.quad(q), VR.RX(off)))
  VBY.nw_roomU(q, L, VB.pw(d), hy,
    F.nat__le_trans(Nat.add(A.quad(q), U32.to_nat(L)), Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d)), Order.add_right(A.quad(q), x, U32.to_nat(L), hq), hw))

# ---- splitting a window -----------------------------------------------------------------------

def hsxB(+d: Nat, +off: U32, +x: Nat, +L: U32, +eo: {U32.to_nat(off) == x : Nat},
    +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(L), VR.QX(off)), VB.pw(d)) == True{} : Bool}:
  hsxBU(d, off, x, L, eo, VC.hyU(L, k, hk, hy), hw)

# The window after its first h bytes.
def tailWX(+t: F.array__Tree<U32>, +x: Nat, +h: Nat, +L: Nat) -> {VS.bdr(h, WX(t, x, Nat.add(h, L))) == WX(t, Nat.add(h, x), L) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bdr(h, VS.bt(Nat.add(h, L), VS.bdr(x, UA.BYT(t)))), VS.bt(L, VS.bdr(h, VS.bdr(x, UA.BYT(t)))), VS.bdr_bt(h, L, VS.bdr(x, UA.BYT(t)))) :
    {_ == WX(t, Nat.add(h, x), L) : +List<U32>}
  %VN.bdr_add(x, h, UA.BYT(t)) : {VS.bt(L, _) == WX(t, Nat.add(h, x), L) : +List<U32>}
  %F.nat__add_comm(x, h) : {VS.bt(L, VS.bdr(Nat.add(x, h), UA.BYT(t))) == VS.bt(L, VS.bdr(_, UA.BYT(t))) : +List<U32>}
  {==}

# A window is the words of its first 4 H bytes, then the window after them.
def headWX(+d: Nat, +t: F.array__Tree<U32>, +x: Nat, +H: Nat, +L: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, Nat.add(A.quad(H), L)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {WX(t, x, Nat.add(A.quad(H), L)) == List.append(&2, U32, FX.limbs(UR.RWS(H, t, x)), WX(t, Nat.add(A.quad(H), x), L)) : +List<U32>}:
  +hh = F.nat__le_trans(Nat.add(x, A.quad(H)), Nat.add(x, Nat.add(A.quad(H), L)), A.quad(VB.pw(d)),
    Order.add_left(x, A.quad(H), Nat.add(A.quad(H), L), Order.below_sum(A.quad(H), L)), hw)
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(H), L), VS.bdr(x, UA.BYT(t))), List.append(&2, U32, VS.bt(A.quad(H), VS.bdr(x, UA.BYT(t))), VS.bt(L, VS.bdr(A.quad(H), VS.bdr(x, UA.BYT(t))))),
      VBC.bt_split(A.quad(H), L, VS.bdr(x, UA.BYT(t)))) :
    {_ == List.append(&2, U32, FX.limbs(UR.RWS(H, t, x)), WX(t, Nat.add(A.quad(H), x), L)) : +List<U32>}
  %VN.bdr_add(x, A.quad(H), UA.BYT(t)) :
    {List.append(&2, U32, VS.bt(A.quad(H), VS.bdr(x, UA.BYT(t))), VS.bt(L, _)) == List.append(&2, U32, FX.limbs(UR.RWS(H, t, x)), WX(t, Nat.add(A.quad(H), x), L)) : +List<U32>}
  %F.nat__add_comm(x, A.quad(H)) :
    {List.append(&2, U32, VS.bt(A.quad(H), VS.bdr(x, UA.BYT(t))), VS.bt(L, VS.bdr(Nat.add(x, A.quad(H)), UA.BYT(t)))) == List.append(&2, U32, FX.limbs(UR.RWS(H, t, x)), VS.bt(L, VS.bdr(_, UA.BYT(t)))) : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(UR.RWS(H, t, x)), VS.bt(A.quad(H), VS.bdr(x, UA.BYT(t))), UR.rws_bytes(H, d, t, x, pf, hh)) :
    {List.append(&2, U32, VS.bt(A.quad(H), VS.bdr(x, UA.BYT(t))), VS.bt(L, VS.bdr(Nat.add(x, A.quad(H)), UA.BYT(t)))) == List.append(&2, U32, _, VS.bt(L, VS.bdr(Nat.add(x, A.quad(H)), UA.BYT(t)))) : +List<U32>}
  {==}

# The four bytes at P of a window are the word at P + x.
def byteWX(+d: Nat, +t: F.array__Tree<U32>, +x: Nat, +P: Nat, +R: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, Nat.add(P, 4n+R)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(P, WX(t, x, Nat.add(P, 4n+R)))) == FX.limbs([UR.RWN(t, Nat.add(P, x))]) : +List<U32>}:
  +h4 = F.nat__le_trans(Nat.add(Nat.add(P, x), 4n), Nat.add(x, Nat.add(P, 4n+R)), A.quad(VB.pw(d)),
    F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(x, Nat.add(P, 4n+R))) == True{} : Bool}, Nat.add(x, Nat.add(P, 4n)), Nat.add(Nat.add(P, x), 4n),
      Equal.trans(Nat, Nat.add(x, Nat.add(P, 4n)), Nat.add(P, Nat.add(x, 4n)), Nat.add(Nat.add(P, x), 4n), F.lru_nat_algebra__add_swap(x, P, 4n), Equal.sym(Nat, Nat.add(Nat.add(P, x), 4n), Nat.add(P, Nat.add(x, 4n)), F.nat__add_assoc(P, x, 4n))),
      Order.add_left(x, Nat.add(P, 4n), Nat.add(P, 4n+R), Order.add_left(P, 4n, 4n+R, Order.below_sum(4n, R)))),
    hw)
  %Equal.sym(+List<U32>, VS.bdr(P, WX(t, x, Nat.add(P, 4n+R))), WX(t, Nat.add(P, x), 4n+R), tailWX(t, x, P, 4n+R)) : {VS.bt(4n, _) == FX.limbs([UR.RWN(t, Nat.add(P, x))]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bt(4n+R, VS.bdr(Nat.add(P, x), UA.BYT(t)))), VS.bt(4n, VS.bdr(Nat.add(P, x), UA.BYT(t))), VS.bt_bt(4n, R, VS.bdr(Nat.add(P, x), UA.BYT(t)))) :
    {_ == FX.limbs([UR.RWN(t, Nat.add(P, x))]) : +List<U32>}
  Equal.sym(+List<U32>, FX.limbs([UR.RWN(t, Nat.add(P, x))]), VS.bt(4n, VS.bdr(Nat.add(P, x), UA.BYT(t))), UR.rwn_bytes(d, t, Nat.add(P, x), pf, h4))

# A window is its first L1 bytes, then the L2 bytes after them.
def splitWX(+t: F.array__Tree<U32>, +a: Nat, +L1: Nat, +L2: Nat)
    -> {WX(t, a, Nat.add(L1, L2)) == List.append(&2, U32, WX(t, a, L1), WX(t, Nat.add(L1, a), L2)) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bt(Nat.add(L1, L2), VS.bdr(a, UA.BYT(t))), List.append(&2, U32, VS.bt(L1, VS.bdr(a, UA.BYT(t))), VS.bt(L2, VS.bdr(L1, VS.bdr(a, UA.BYT(t))))),
      VBC.bt_split(L1, L2, VS.bdr(a, UA.BYT(t)))) :
    {_ == List.append(&2, U32, WX(t, a, L1), WX(t, Nat.add(L1, a), L2)) : +List<U32>}
  %VN.bdr_add(a, L1, UA.BYT(t)) : {List.append(&2, U32, WX(t, a, L1), VS.bt(L2, _)) == List.append(&2, U32, WX(t, a, L1), WX(t, Nat.add(L1, a), L2)) : +List<U32>}
  %F.nat__add_comm(a, L1) : {List.append(&2, U32, WX(t, a, L1), VS.bt(L2, VS.bdr(Nat.add(a, L1), UA.BYT(t)))) == List.append(&2, U32, WX(t, a, L1), VS.bt(L2, VS.bdr(_, UA.BYT(t)))) : +List<U32>}
  {==}

# The first m <= L bytes of a window of L bytes.
def btWX(+t: F.array__Tree<U32>, +x: Nat, +m: Nat, +L: Nat, +h: {Nat.is_le(m, L) == True{} : Bool})
    -> {VS.bt(m, WX(t, x, L)) == WX(t, x, m) : +List<U32>}:
  UC.bt_le(m, L, VS.bdr(x, UA.BYT(t)), h)

law bt_self:
  for +xs: +List<U32>
  {VS.bt(List.length(&2, U32, xs), xs) == xs : +List<U32>}
def bt_self(xs):
  match xs:
    case Nil{}: {==}
    case Con{+h, +r}:
      %bt_self(r) : {h <> VS.bt(List.length(&2, U32, r), r) == h <> _ : +List<U32>}
      {==}

law le_cancel:
  for +a: Nat
  for +m: Nat
  for +r: Nat
  for +h: {Nat.is_le(Nat.add(a, m), Nat.add(a, r)) == True{} : Bool}
  {Nat.is_le(m, r) == True{} : Bool}
def le_cancel(a, m, r, h):
  match a:
    case 0n: h
    case 1n+ +p: le_cancel(p, m, r, h)

# The m bytes at h of a window of L >= h + m bytes.
def subWX(+t: F.array__Tree<U32>, +x: Nat, +h: Nat, +m: Nat, +L: Nat, +hl: {Nat.is_le(Nat.add(h, m), L) == True{} : Bool})
    -> {VS.bt(m, VS.bdr(h, WX(t, x, L))) == WX(t, Nat.add(h, x), m) : +List<U32>}:
  +hle = F.nat__le_trans(h, Nat.add(h, m), L, Order.below_sum(h, m), hl)
  +R = Nat.sub(L, h)
  +eL = F.nat__sub_add(L, h, hle)
  %eL : {VS.bt(m, VS.bdr(h, WX(t, x, _))) == WX(t, Nat.add(h, x), m) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(h, WX(t, x, Nat.add(h, R))), WX(t, Nat.add(h, x), R), tailWX(t, x, h, R)) : {VS.bt(m, _) == WX(t, Nat.add(h, x), m) : +List<U32>}
  btWX(t, Nat.add(h, x), m, R, le_cancel(h, m, R, F.logic__subst(Nat, z => {Nat.is_le(Nat.add(h, m), z) == True{} : Bool}, L, Nat.add(h, R), Equal.sym(Nat, Nat.add(h, R), L, eL), hl)))

# ---- the spec parts of a variable-size container value are one variable part ---------------

def vs_enc(+m: Maybe<&2, +List<U32>>) -> DF.single_result(None{}, Codec.one(m, None{})):
  match m:
    case None{}: Unit{}
    case Some{+xs}: {==}

def vs_agg(+m: Maybe<&2, +List<S.Part>>) -> DF.single_result(None{}, Codec.aggregate(m, None{})):
  match m:
    case None{}: Unit{}
    case Some{+ps}: vs_enc(Layout.encoding(ps))

law vsingle:
  for +h: S.Value
  for +names: +List<String>
  for +fields: S.Schema
  for +e: {SS.fixed_size(fields) == None{} : Maybe<&2, Nat>}
  DF.single_result(None{}, Codec.parts(h, S.Container{names, fields}))
def vsingle(h, names, fields, e):
  match h:
    case S.Sequence{+items}:
      F.logic__subst(Maybe<&2, Nat>, z => DF.single_result(None{}, Codec.aggregate(Codec.parts(items, fields), z)), None{}, SS.fixed_size(fields), Equal.sym(Maybe<&2, Nat>, SS.fixed_size(fields), None{}, e),
        vs_agg(Codec.parts(items, fields)))
    case S.BooleanValue{+b0}: Unit{}
    case S.UnsignedValue{+u0}: Unit{}
    case S.BytesValue{+xs0}: Unit{}
    case S.BitsValue{+bs0}: Unit{}
    case S.Items{+hd0, +tl0}: Unit{}
    case S.EmptyItems{}: Unit{}
    case S.Selected{+sel0, +sv0}: Unit{}
    case S.NullValue{}: Unit{}
