import Base
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vfix.bend as VF
import ./vlist.bend as VL
import ./vua.bend as UA
import ./vuw.bend as UW
import ./vuwd.bend as WD

# Positions and room of the fields of a fixed-size value written at a byte position
# X = 4 q + r (hand-written; for codegen/var_rec_enc.py): a field at byte 4 k of the value is
# at 4 (k + q) + r, and its m bytes lie within the value's L bytes, hence within the tree.

law nwn_quad:
  for +a: Nat
  for +b: Nat
  {WD.NWN(Nat.add(A.quad(a), b)) == Nat.add(a, WD.NWN(b)) : Nat}
def nwn_quad(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, WD.NWN(Nat.add(A.quad(p), b)), Nat.add(p, WD.NWN(b)), nwn_quad(p, b))

law nwn_ge:
  for +y: Nat
  {Nat.is_le(y, A.quad(WD.NWN(y))) == True{} : Bool}
def nwn_ge(y):
  match y:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +z: nwn_ge(z)

def nwn_le(+y: Nat, +P: Nat, +h: {Nat.is_le(y, A.quad(P)) == True{} : Bool}) -> {Nat.is_le(WD.NWN(y), P) == True{} : Bool}:
  %VL.rng2_q(P) : {Nat.is_le(WD.NWN(y), _) == True{} : Bool}
  VC.rng_mono(2n, 3n+y, 3n+A.quad(P), h)

def nwn_mono(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(WD.NWN(a), WD.NWN(b)) == True{} : Bool}:
  VC.rng_mono(2n, 3n+a, 3n+b, h)

# The value's bytes end within the tree: X0 + L <= 4 2^dd.
def xend(+q: Nat, +r: Nat, +L: Nat, +dd: Nat, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), L), A.quad(VB.pw(dd))) == True{} : Bool}:
  +y = Nat.add(r, L)
  +e1 = Equal.trans(Nat, Nat.add(Nat.add(A.quad(q), r), L), Nat.add(A.quad(q), y), Nat.add(A.quad(q), y), F.nat__add_assoc(A.quad(q), r, L), {==})
  F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dd))) == True{} : Bool}, Nat.add(A.quad(q), y), Nat.add(Nat.add(A.quad(q), r), L), Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), r), L), Nat.add(A.quad(q), y), e1),
    F.nat__le_trans(Nat.add(A.quad(q), y), Nat.add(A.quad(q), A.quad(WD.NWN(y))), A.quad(VB.pw(dd)), Order.add_left(A.quad(q), y, A.quad(WD.NWN(y)), nwn_ge(y)),
      F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dd))) == True{} : Bool}, A.quad(Nat.add(q, WD.NWN(y))), Nat.add(A.quad(q), A.quad(WD.NWN(y))),
        Equal.sym(Nat, Nat.add(A.quad(q), A.quad(WD.NWN(y))), A.quad(Nat.add(q, WD.NWN(y))), VF.quad_add(q, WD.NWN(y))),
        UW.quad_le(Nat.add(q, WD.NWN(y)), VB.pw(dd), hl))))

# The start X0 <= |BYT D|.
def xstart(+q: Nat, +r: Nat, +L: Nat, +dd: Nat, +D: F.array__Tree<U32>, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A.quad(q), r), List.length(&2, U32, UA.BYT(D))) == True{} : Bool}:
  +eL = Equal.trans(Nat, List.length(&2, U32, UA.BYT(D)), A.quad(VB.len(F.array__slots(U32, D))), A.quad(VB.pw(dd)), UW.len_limbs_v(F.array__slots(U32, D)),
    Equal.cong(Nat, Nat, z => A.quad(z), VB.len(F.array__slots(U32, D)), VB.pw(dd), F.array__slots_length(U32, dd, D, pf)))
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), r), z) == True{} : Bool}, A.quad(VB.pw(dd)), List.length(&2, U32, UA.BYT(D)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(D)), A.quad(VB.pw(dd)), eL),
    F.nat__le_trans(Nat.add(A.quad(q), r), Nat.add(Nat.add(A.quad(q), r), L), A.quad(VB.pw(dd)), Order.below_sum(Nat.add(A.quad(q), r), L), xend(q, r, L, dd, hl)))

# A field at byte 4 k (4 k <= L) is at byte 4 (k + q) + r.
def fpos(+X: U32, +q: Nat, +r: Nat, +k: Nat, +c: U32, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hk: {Nat.is_le(A.quad(k), L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, c)) == Nat.add(A.quad(Nat.add(k, q)), r) : Nat}:
  +X0 = Nat.add(A.quad(q), r)
  UW.ua_add(X, c, q, k, r, 2n+dd, e, ec, hd,
    F.nat__le_trans(Nat.add(A.quad(k), X0), Nat.add(X0, L), A.quad(VB.pw(dd)),
      F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(X0, L)) == True{} : Bool}, Nat.add(X0, A.quad(k)), Nat.add(A.quad(k), X0), F.nat__add_comm(X0, A.quad(k)), Order.add_left(X0, A.quad(k), L, hk)),
      xend(q, r, L, dd, hl)))

# The room of a field of m bytes at byte 4 k, 4 k + m <= L.
def froom(+q: Nat, +r: Nat, +dd: Nat, +k: Nat, +m: Nat, +L: Nat, +hk: {Nat.is_le(Nat.add(A.quad(k), m), L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(k, q), WD.NWN(Nat.add(r, m))), VB.pw(dd)) == True{} : Bool}:
  +e1 = Equal.trans(Nat, WD.NWN(Nat.add(A.quad(Nat.add(k, q)), Nat.add(r, m))), Nat.add(Nat.add(k, q), WD.NWN(Nat.add(r, m))), Nat.add(Nat.add(k, q), WD.NWN(Nat.add(r, m))),
    nwn_quad(Nat.add(k, q), Nat.add(r, m)), {==})
  +y1 = Nat.add(A.quad(Nat.add(k, q)), Nat.add(r, m))
  +y2 = Nat.add(A.quad(q), Nat.add(r, L))
  +e2 = Equal.trans(Nat, y1, Nat.add(Nat.add(A.quad(k), A.quad(q)), Nat.add(r, m)), Nat.add(A.quad(q), Nat.add(r, Nat.add(A.quad(k), m))),
    Equal.cong(Nat, Nat, z => Nat.add(z, Nat.add(r, m)), A.quad(Nat.add(k, q)), Nat.add(A.quad(k), A.quad(q)), Equal.sym(Nat, Nat.add(A.quad(k), A.quad(q)), A.quad(Nat.add(k, q)), VF.quad_add(k, q))),
    Equal.trans(Nat, Nat.add(Nat.add(A.quad(k), A.quad(q)), Nat.add(r, m)), Nat.add(A.quad(q), Nat.add(A.quad(k), Nat.add(r, m))), Nat.add(A.quad(q), Nat.add(r, Nat.add(A.quad(k), m))),
      Equal.trans(Nat, Nat.add(Nat.add(A.quad(k), A.quad(q)), Nat.add(r, m)), Nat.add(Nat.add(A.quad(q), A.quad(k)), Nat.add(r, m)), Nat.add(A.quad(q), Nat.add(A.quad(k), Nat.add(r, m))),
        Equal.cong(Nat, Nat, z => Nat.add(z, Nat.add(r, m)), Nat.add(A.quad(k), A.quad(q)), Nat.add(A.quad(q), A.quad(k)), F.nat__add_comm(A.quad(k), A.quad(q))),
        F.nat__add_assoc(A.quad(q), A.quad(k), Nat.add(r, m))),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(q), z), Nat.add(A.quad(k), Nat.add(r, m)), Nat.add(r, Nat.add(A.quad(k), m)),
        Equal.trans(Nat, Nat.add(A.quad(k), Nat.add(r, m)), Nat.add(Nat.add(A.quad(k), r), m), Nat.add(r, Nat.add(A.quad(k), m)),
          Equal.sym(Nat, Nat.add(Nat.add(A.quad(k), r), m), Nat.add(A.quad(k), Nat.add(r, m)), F.nat__add_assoc(A.quad(k), r, m)),
          Equal.trans(Nat, Nat.add(Nat.add(A.quad(k), r), m), Nat.add(Nat.add(r, A.quad(k)), m), Nat.add(r, Nat.add(A.quad(k), m)),
            Equal.cong(Nat, Nat, z => Nat.add(z, m), Nat.add(A.quad(k), r), Nat.add(r, A.quad(k)), F.nat__add_comm(A.quad(k), r)),
            F.nat__add_assoc(r, A.quad(k), m))))))
  +h12 = F.logic__subst(Nat, z => {Nat.is_le(z, y2) == True{} : Bool}, Nat.add(A.quad(q), Nat.add(r, Nat.add(A.quad(k), m))), y1, Equal.sym(Nat, y1, Nat.add(A.quad(q), Nat.add(r, Nat.add(A.quad(k), m))), e2),
    Order.add_left(A.quad(q), Nat.add(r, Nat.add(A.quad(k), m)), Nat.add(r, L), Order.add_left(r, Nat.add(A.quad(k), m), L, hk)))
  F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, WD.NWN(y1), Nat.add(Nat.add(k, q), WD.NWN(Nat.add(r, m))), e1,
    F.nat__le_trans(WD.NWN(y1), WD.NWN(y2), VB.pw(dd), nwn_mono(y1, y2, h12),
      F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, WD.NWN(Nat.add(r, L))), WD.NWN(y2), Equal.sym(Nat, WD.NWN(y2), Nat.add(q, WD.NWN(Nat.add(r, L))), nwn_quad(q, Nat.add(r, L))), hl)))

# The field's byte position as the region invariant names it: X0 + 4 k.
def fpx(+q: Nat, +r: Nat, +k: Nat) -> {Nat.add(Nat.add(A.quad(q), r), A.quad(k)) == Nat.add(A.quad(Nat.add(k, q)), r) : Nat}:
  Equal.sym(Nat, Nat.add(A.quad(Nat.add(k, q)), r), Nat.add(Nat.add(A.quad(q), r), A.quad(k)), UW.pos_eq(k, q, r))
