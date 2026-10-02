import Base
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vfix.bend as VF
import ./vbrt.bend as VR
import ./vbitc.bend as VBC
import ./vnest.bend as VN
import ./vcopy.bend as VC

# Byte windows of a buffer: a window's bytes are its first words' limbs
# followed by the window after them, and its bytes at 4 k are the limbs of
# its word k.

def S(t: F.array__Tree<U32>) -> List<&2, U32>: F.array__slots(U32, t)

law quad_comm:
  for +i: Nat
  for +h: Nat
  {Nat.add(A.quad(i), A.quad(h)) == A.quad(Nat.add(h, i)) : Nat}
def quad_comm(i, h):
  %F.nat__add_comm(A.quad(h), A.quad(i)) : {_ == A.quad(Nat.add(h, i)) : Nat}
  VF.quad_add(h, i)

# Dropping 4 i then 4 h bytes of limbs drops the limbs of i + h words.
def bdr2(+t: F.array__Tree<U32>, +i: Nat, +h: Nat)
    -> {VS.bdr(A.quad(h), VS.bdr(A.quad(i), FX.limbs(S(t)))) == VS.bdr(A.quad(Nat.add(h, i)), FX.limbs(S(t))) : +List<U32>}:
  %VN.bdr_add(A.quad(i), A.quad(h), FX.limbs(S(t))) :
    {_ == VS.bdr(A.quad(Nat.add(h, i)), FX.limbs(S(t))) : +List<U32>}
  %Equal.sym(Nat, Nat.add(A.quad(i), A.quad(h)), A.quad(Nat.add(h, i)), quad_comm(i, h)) : {VS.bdr(_, FX.limbs(S(t))) == VS.bdr(A.quad(Nat.add(h, i)), FX.limbs(S(t))) : +List<U32>}
  {==}

# The window after the first h words of a window.
law tailW:
  for +t: F.array__Tree<U32>
  for +i: Nat
  for +h: Nat
  for +L: Nat
  {VS.bdr(A.quad(h), VR.WB(t, i, Nat.add(A.quad(h), L))) == VR.WB(t, Nat.add(h, i), L) : +List<U32>}
def tailW(t, i, h, L):
  %Equal.sym(+List<U32>, VS.bdr(A.quad(h), VS.bt(Nat.add(A.quad(h), L), VS.bdr(A.quad(i), FX.limbs(S(t))))), VS.bt(L, VS.bdr(A.quad(h), VS.bdr(A.quad(i), FX.limbs(S(t))))),
      VS.bdr_bt(A.quad(h), L, VS.bdr(A.quad(i), FX.limbs(S(t))))) :
    {_ == VR.WB(t, Nat.add(h, i), L) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(h), VS.bdr(A.quad(i), FX.limbs(S(t)))), VS.bdr(A.quad(Nat.add(h, i)), FX.limbs(S(t))), bdr2(t, i, h)) :
    {VS.bt(L, _) == VR.WB(t, Nat.add(h, i), L) : +List<U32>}
  {==}

# A window is its first h words' limbs followed by the window after them.
def splitW(+t: F.array__Tree<U32>, +i: Nat, +h: Nat, +L: Nat, +hh: {Nat.is_le(Nat.add(h, i), VB.len(S(t))) == True{} : Bool})
    -> {VR.WB(t, i, Nat.add(A.quad(h), L)) == List.append(&2, U32, FX.limbs(VF.app(VF.wpre(h, i, S(t)), [])), VR.WB(t, Nat.add(h, i), L)) : +List<U32>}:
  +X = VS.bdr(A.quad(i), FX.limbs(S(t)))
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(h), L), X), List.append(&2, U32, VS.bt(A.quad(h), X), VS.bt(L, VS.bdr(A.quad(h), X))), VBC.bt_split(A.quad(h), L, X)) :
    {_ == List.append(&2, U32, FX.limbs(VF.app(VF.wpre(h, i, S(t)), [])), VR.WB(t, Nat.add(h, i), L)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(h), X), VS.bdr(A.quad(Nat.add(h, i)), FX.limbs(S(t))), bdr2(t, i, h)) :
    {List.append(&2, U32, VS.bt(A.quad(h), X), VS.bt(L, _)) == List.append(&2, U32, FX.limbs(VF.app(VF.wpre(h, i, S(t)), [])), VR.WB(t, Nat.add(h, i), L)) : +List<U32>}
  %Equal.sym(+List<U32>, X, FX.limbs(VS.wdr0(i, S(t))), VS.bdr_limbs(i, S(t))) :
    {List.append(&2, U32, VS.bt(A.quad(h), _), VR.WB(t, Nat.add(h, i), L)) == List.append(&2, U32, FX.limbs(VF.app(VF.wpre(h, i, S(t)), [])), VR.WB(t, Nat.add(h, i), L)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(h), FX.limbs(VS.wdr0(i, S(t)))), FX.limbs(VS.wtake(h, VS.wdr0(i, S(t)))), VS.bt_limbs(h, VS.wdr0(i, S(t)))) :
    {List.append(&2, U32, _, VR.WB(t, Nat.add(h, i), L)) == List.append(&2, U32, FX.limbs(VF.app(VF.wpre(h, i, S(t)), [])), VR.WB(t, Nat.add(h, i), L)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(i, S(t)), VB.wdr(i, S(t)), VN.wdr0_eq(i, S(t))) :
    {List.append(&2, U32, FX.limbs(VS.wtake(h, _)), VR.WB(t, Nat.add(h, i), L)) == List.append(&2, U32, FX.limbs(VF.app(VF.wpre(h, i, S(t)), [])), VR.WB(t, Nat.add(h, i), L)) : +List<U32>}
  %F.nat__add_zero(h) :
    {List.append(&2, U32, FX.limbs(VS.wtake(_, VB.wdr(i, S(t)))), VR.WB(t, Nat.add(h, i), L)) == List.append(&2, U32, FX.limbs(VF.app(VF.wpre(h, i, S(t)), [])), VR.WB(t, Nat.add(h, i), L)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(h, 0n), VB.wdr(i, S(t))), VF.app(VF.wpre(h, i, S(t)), VS.wtake(0n, VB.wdr(Nat.add(h, i), S(t)))), VF.wt_pre(h, 0n, i, S(t), hh)) :
    {List.append(&2, U32, FX.limbs(_), VR.WB(t, Nat.add(h, i), L)) == List.append(&2, U32, FX.limbs(VF.app(VF.wpre(h, i, S(t)), [])), VR.WB(t, Nat.add(h, i), L)) : +List<U32>}
  {==}

# The four bytes at 4 k of a window are the limbs of its word k.
def byteW(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +k: Nat, +R: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), Nat.add(A.quad(k), 4n+R)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(A.quad(k), VR.WB(t, i, Nat.add(A.quad(k), 4n+R)))) == FX.limbs([VB.slot(t, Nat.add(k, i))]) : +List<U32>}:
  +j = Nat.add(k, i)
  %Equal.sym(+List<U32>, VS.bdr(A.quad(k), VR.WB(t, i, Nat.add(A.quad(k), 4n+R))), VR.WB(t, j, 4n+R), tailW(t, i, k, 4n+R)) : {VS.bt(4n, _) == FX.limbs([VB.slot(t, j)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bt(4n+R, VS.bdr(A.quad(j), FX.limbs(S(t))))), VS.bt(4n, VS.bdr(A.quad(j), FX.limbs(S(t)))), VS.bt_bt(4n, R, VS.bdr(A.quad(j), FX.limbs(S(t))))) :
    {_ == FX.limbs([VB.slot(t, j)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(j), FX.limbs(S(t))), FX.limbs(VS.wdr0(j, S(t))), VS.bdr_limbs(j, S(t))) :
    {VS.bt(4n, _) == FX.limbs([VB.slot(t, j)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, FX.limbs(VS.wdr0(j, S(t)))), FX.limbs(VS.wtake(1n, VS.wdr0(j, S(t)))), VS.bt_limbs(1n, VS.wdr0(j, S(t)))) :
    {_ == FX.limbs([VB.slot(t, j)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(j, S(t)), VB.wdr(j, S(t)), VN.wdr0_eq(j, S(t))) :
    {FX.limbs(VS.wtake(1n, _)) == FX.limbs([VB.slot(t, j)]) : +List<U32>}
  # j < 2^d
  +h1 = F.nat__le_trans(Nat.add(A.quad(i), Nat.add(A.quad(k), 4n)), Nat.add(A.quad(i), Nat.add(A.quad(k), 4n+R)), A.quad(VB.pw(d)),
    Order.add_left(A.quad(i), Nat.add(A.quad(k), 4n), Nat.add(A.quad(k), 4n+R), Order.add_left(A.quad(k), 4n, 4n+R, Order.below_sum(4n, R))), hw)
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(A.quad(i), Nat.add(A.quad(k), 4n)), A.quad(1n+j),
    Equal.trans(Nat, Nat.add(A.quad(i), Nat.add(A.quad(k), 4n)), Nat.add(Nat.add(A.quad(k), 4n), A.quad(i)), A.quad(1n+j), F.nat__add_comm(A.quad(i), Nat.add(A.quad(k), 4n)),
      Equal.trans(Nat, Nat.add(Nat.add(A.quad(k), 4n), A.quad(i)), Nat.add(A.quad(1n+k), A.quad(i)), A.quad(1n+j),
        Equal.cong(Nat, Nat, z => Nat.add(z, A.quad(i)), Nat.add(A.quad(k), 4n), A.quad(1n+k), Equal.trans(Nat, Nat.add(A.quad(k), 4n), Nat.add(4n, A.quad(k)), A.quad(1n+k), F.nat__add_comm(A.quad(k), 4n), {==})),
        VF.quad_add(1n+k, i))), h1)
  +hj = F.nat__succ_le_lt(j, VB.pw(d), VC.quad_inv(1n+j, VB.pw(d), h2))
  +hjs = F.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, VB.pw(d), VB.len(S(t)), Equal.sym(Nat, VB.len(S(t)), VB.pw(d), F.array__slots_length(U32, d, t, pf)), hj)
  %Equal.sym(List<&2, U32>, VS.wtake(1n, VB.wdr(j, S(t))), Con{F.flat__nthc(S(t), j), VS.wtake(0n, VB.wdr(1n+j, S(t)))}, VB.wt_eta(0n, j, S(t), hjs)) :
    {FX.limbs(_) == FX.limbs([VB.slot(t, j)]) : +List<U32>}
  {==}
