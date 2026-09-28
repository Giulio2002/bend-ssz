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
import ./vu32.bend as VU
import ./vme.bend as VME
import ./vrl.bend as VRL

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
def fposW(+X: U32, +q: Nat, +r: Nat, +k: Nat, +c: U32, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hk: {Nat.is_lt(A.quad(k), L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, c)) == Nat.add(A.quad(Nat.add(k, q)), r) : Nat}:
  +X0 = Nat.add(A.quad(q), r)
  +h1 = F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(k), X0), z) == True{} : Bool}, Nat.add(L, X0), Nat.add(X0, L), F.nat__add_comm(L, X0), VB.lt_kk(A.quad(k), L, X0, hk))
  UW.ua_addS(X, c, q, k, r, e, ec,
    F.nat__lt_le_trans(Nat.add(A.quad(k), X0), Nat.add(X0, L), F.spec_common__pow2(32n), h1,
      F.nat__le_trans(Nat.add(X0, L), A.quad(VB.pw(dd)), F.spec_common__pow2(32n), xend(q, r, L, dd, hl), UW.q32(dd, hd))))

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

# ---- runs of records (for the lists of fixed records) -------------------------------------------

def LN(+a: +List<U32>) -> Nat: List.length(&2, U32, a)
def AP(+a: +List<U32>, +b: +List<U32>) -> +List<U32>: List.append(&2, U32, a, b)

law bt_all:
  for +a: +List<U32>
  for +b: +List<U32>
  {VS.bt(LN(a), AP(a, b)) == a : +List<U32>}
def bt_all(a, b):
  match a:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, VS.bt(LN(t), AP(t, b)), t, bt_all(t, b))

law bdr_all:
  for +a: +List<U32>
  for +b: +List<U32>
  {VS.bdr(LN(a), AP(a, b)) == b : +List<U32>}
def bdr_all(a, b):
  match a:
    case Nil{}: {==}
    case Con{+x, +t}: bdr_all(t, b)

law len_app:
  for +a: +List<U32>
  for +b: +List<U32>
  {LN(AP(a, b)) == Nat.add(LN(a), LN(b)) : Nat}
def len_app(a, b):
  match a:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(Nat, Nat, z => 1n+z, LN(AP(t, b)), Nat.add(LN(t), LN(b)), len_app(t, b))

# The bytes past a splice are the original's.
def bdr_spl(+B: +List<U32>, +X: Nat, +Y: +List<U32>, +hX: {Nat.is_le(X, LN(B)) == True{} : Bool})
    -> {VS.bdr(Nat.add(X, LN(Y)), UW.SPL(B, X, Y)) == VS.bdr(Nat.add(X, LN(Y)), B) : +List<U32>}:
  +P = VS.bt(X, B)
  +R0 = VS.bdr(Nat.add(X, LN(Y)), B)
  +eP = VS.bt_len(X, B, hX)
  +e1 = F.logic__subst(Nat, w => {VS.bdr(Nat.add(w, LN(Y)), AP(P, AP(Y, R0))) == VS.bdr(LN(Y), AP(Y, R0)) : +List<U32>}, LN(P), X, eP, UW.bdr_app_len(P, LN(Y), AP(Y, R0)))
  Equal.trans(+List<U32>, VS.bdr(Nat.add(X, LN(Y)), AP(P, AP(Y, R0))), VS.bdr(LN(Y), AP(Y, R0)), R0, e1, bdr_all(Y, R0))

# Two adjacent splices are one: Z at X, then Y right after it.
def spl_cat(+B: +List<U32>, +X: Nat, +Z: +List<U32>, +Y: +List<U32>, +hX: {Nat.is_le(X, LN(B)) == True{} : Bool})
    -> {UW.SPL(UW.SPL(B, X, Z), Nat.add(X, LN(Z)), Y) == UW.SPL(B, X, AP(Z, Y)) : +List<U32>}:
  +z = LN(Z)
  +m = LN(Y)
  +P = VS.bt(X, B)
  +R0 = VS.bdr(Nat.add(X, z), B)
  +T = AP(P, AP(Z, R0))
  +Xz = Nat.add(X, z)
  +Rb = VS.bdr(Nat.add(Xz, m), B)
  +eP = VS.bt_len(X, B, hX)
  +g1a = F.logic__subst(Nat, w => {VS.bt(Nat.add(w, z), T) == AP(P, VS.bt(z, AP(Z, R0))) : +List<U32>}, LN(P), X, eP, UW.bt_app_len(P, z, AP(Z, R0)))
  +g1 = Equal.trans(+List<U32>, VS.bt(Xz, T), AP(P, VS.bt(z, AP(Z, R0))), AP(P, Z), g1a,
    Equal.cong(+List<U32>, +List<U32>, w => AP(P, w), VS.bt(z, AP(Z, R0)), Z, bt_all(Z, R0)))
  +g2a = F.logic__subst(Nat, w => {VS.bdr(Nat.add(w, z), T) == VS.bdr(z, AP(Z, R0)) : +List<U32>}, LN(P), X, eP, UW.bdr_app_len(P, z, AP(Z, R0)))
  +g2b = Equal.trans(+List<U32>, VS.bdr(Xz, T), VS.bdr(z, AP(Z, R0)), R0, g2a, bdr_all(Z, R0))
  +g2 = Equal.trans(+List<U32>, VS.bdr(Nat.add(Xz, m), T), VS.bdr(m, VS.bdr(Xz, T)), Rb, UW.bdr_add(Xz, m, T),
    Equal.trans(+List<U32>, VS.bdr(m, VS.bdr(Xz, T)), VS.bdr(m, R0), Rb, Equal.cong(+List<U32>, +List<U32>, w => VS.bdr(m, w), VS.bdr(Xz, T), R0, g2b),
      Equal.sym(+List<U32>, Rb, VS.bdr(m, R0), UW.bdr_add(Xz, m, B))))
  +eL = Equal.trans(+List<U32>, AP(VS.bt(Xz, T), AP(Y, VS.bdr(Nat.add(Xz, m), T))), AP(AP(P, Z), AP(Y, VS.bdr(Nat.add(Xz, m), T))), AP(AP(P, Z), AP(Y, Rb)),
    Equal.cong(+List<U32>, +List<U32>, w => AP(w, AP(Y, VS.bdr(Nat.add(Xz, m), T))), VS.bt(Xz, T), AP(P, Z), g1),
    Equal.cong(+List<U32>, +List<U32>, w => AP(AP(P, Z), AP(Y, w)), VS.bdr(Nat.add(Xz, m), T), Rb, g2))
  +eA = VS.app_assoc(P, Z, AP(Y, Rb))
  +eX = Equal.trans(Nat, Nat.add(X, LN(AP(Z, Y))), Nat.add(X, Nat.add(z, m)), Nat.add(Xz, m),
    Equal.cong(Nat, Nat, w => Nat.add(X, w), LN(AP(Z, Y)), Nat.add(z, m), len_app(Z, Y)), Equal.sym(Nat, Nat.add(Xz, m), Nat.add(X, Nat.add(z, m)), F.nat__add_assoc(X, z, m)))
  +eR = Equal.trans(+List<U32>, AP(P, AP(AP(Z, Y), VS.bdr(Nat.add(X, LN(AP(Z, Y))), B))), AP(P, AP(AP(Z, Y), Rb)), AP(P, AP(Z, AP(Y, Rb))),
    Equal.cong(Nat, +List<U32>, w => AP(P, AP(AP(Z, Y), VS.bdr(w, B))), Nat.add(X, LN(AP(Z, Y))), Nat.add(Xz, m), eX),
    Equal.cong(+List<U32>, +List<U32>, w => AP(P, w), AP(AP(Z, Y), Rb), AP(Z, AP(Y, Rb)), VS.app_assoc(Z, Y, Rb)))
  Equal.trans(+List<U32>, AP(VS.bt(Xz, T), AP(Y, VS.bdr(Nat.add(Xz, m), T))), AP(P, AP(Z, AP(Y, Rb))), AP(P, AP(AP(Z, Y), VS.bdr(Nat.add(X, LN(AP(Z, Y))), B))),
    Equal.trans(+List<U32>, AP(VS.bt(Xz, T), AP(Y, VS.bdr(Nat.add(Xz, m), T))), AP(AP(P, Z), AP(Y, Rb)), AP(P, AP(Z, AP(Y, Rb))), eL, eA),
    Equal.sym(+List<U32>, AP(P, AP(AP(Z, Y), VS.bdr(Nat.add(X, LN(AP(Z, Y))), B))), AP(P, AP(Z, AP(Y, Rb))), eR))

# spl_cat at a named position Xn = X + |Z| of a named splice UB.
def spl_catx(+B: +List<U32>, +X: Nat, +Z: +List<U32>, +Y: +List<U32>, +Xn: Nat, +UB: +List<U32>, +hX: {Nat.is_le(X, LN(B)) == True{} : Bool},
    +eXn: {Xn == Nat.add(X, LN(Z)) : Nat}, +eU: {UB == UW.SPL(B, X, Z) : +List<U32>})
    -> {UW.SPL(UB, Xn, Y) == UW.SPL(B, X, AP(Z, Y)) : +List<U32>}:
  %Equal.sym(Nat, Xn, Nat.add(X, LN(Z)), eXn) : {UW.SPL(UB, _, Y) == UW.SPL(B, X, AP(Z, Y)) : +List<U32>}
  %Equal.sym(+List<U32>, UB, UW.SPL(B, X, Z), eU) : {UW.SPL(_, Nat.add(X, LN(Z)), Y) == UW.SPL(B, X, AP(Z, Y)) : +List<U32>}
  spl_cat(B, X, Z, Y, hX)

# The head a and the tail b of a zero window of a + b bytes.
def zhead(+a: Nat, +b: Nat, +xs: +List<U32>, +h: {VS.bt(Nat.add(a, b), xs) == UW.ZB(Nat.add(a, b)) : +List<U32>}) -> {VS.bt(a, xs) == UW.ZB(a) : +List<U32>}:
  +hl = Order.below_sum(a, b)
  Equal.trans(+List<U32>, VS.bt(a, xs), VS.bt(a, VS.bt(Nat.add(a, b), xs)), UW.ZB(a), Equal.sym(+List<U32>, VS.bt(a, VS.bt(Nat.add(a, b), xs)), VS.bt(a, xs), UW.bt_le_m(a, Nat.add(a, b), xs, hl)),
    Equal.trans(+List<U32>, VS.bt(a, VS.bt(Nat.add(a, b), xs)), VS.bt(a, UW.ZB(Nat.add(a, b))), UW.ZB(a),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(a, z), VS.bt(Nat.add(a, b), xs), UW.ZB(Nat.add(a, b)), h), UW.zb_win(0n, a, Nat.add(a, b), hl)))
def ztail(+a: Nat, +b: Nat, +xs: +List<U32>, +h: {VS.bt(Nat.add(a, b), xs) == UW.ZB(Nat.add(a, b)) : +List<U32>}) -> {VS.bt(b, VS.bdr(a, xs)) == UW.ZB(b) : +List<U32>}:
  +hl = F.nat__le_refl(Nat.add(a, b))
  Equal.trans(+List<U32>, VS.bt(b, VS.bdr(a, xs)), VS.bt(b, VS.bdr(a, VS.bt(Nat.add(a, b), xs))), UW.ZB(b), UW.bt_bdr_bt(b, a, Nat.add(a, b), xs, hl),
    Equal.trans(+List<U32>, VS.bt(b, VS.bdr(a, VS.bt(Nat.add(a, b), xs))), VS.bt(b, VS.bdr(a, UW.ZB(Nat.add(a, b)))), UW.ZB(b),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(b, VS.bdr(a, z)), VS.bt(Nat.add(a, b), xs), UW.ZB(Nat.add(a, b)), h), UW.zb_win(a, b, Nat.add(a, b), hl)))

# After a splice of a bytes at X, the zero window's remaining b bytes at Xn = X + a.
def znext(+B: +List<U32>, +X: Nat, +Y: +List<U32>, +Xn: Nat, +a: Nat, +b: Nat, +UB: +List<U32>, +hX: {Nat.is_le(X, LN(B)) == True{} : Bool},
    +eY: {LN(Y) == a : Nat}, +eXn: {Xn == Nat.add(X, a) : Nat}, +eU: {UB == UW.SPL(B, X, Y) : +List<U32>},
    +hz: {VS.bt(Nat.add(a, b), VS.bdr(X, B)) == UW.ZB(Nat.add(a, b)) : +List<U32>})
    -> {VS.bt(b, VS.bdr(Xn, UB)) == UW.ZB(b) : +List<U32>}:
  +e1 = F.logic__subst(Nat, w => {VS.bdr(Nat.add(X, w), UW.SPL(B, X, Y)) == VS.bdr(Nat.add(X, w), B) : +List<U32>}, LN(Y), a, eY, bdr_spl(B, X, Y, hX))
  %Equal.sym(Nat, Xn, Nat.add(X, a), eXn) : {VS.bt(b, VS.bdr(_, UB)) == UW.ZB(b) : +List<U32>}
  %Equal.sym(+List<U32>, UB, UW.SPL(B, X, Y), eU) : {VS.bt(b, VS.bdr(Nat.add(X, a), _)) == UW.ZB(b) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(X, a), UW.SPL(B, X, Y)), VS.bdr(Nat.add(X, a), B), e1) : {VS.bt(b, _) == UW.ZB(b) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(X, a), B), VS.bdr(a, VS.bdr(X, B)), UW.bdr_add(X, a, B)) : {VS.bt(b, _) == UW.ZB(b) : +List<U32>}
  ztail(a, b, VS.bdr(X, B), hz)

# Record j of W words at byte X0 + 4 W j: its byte position, and the next record's.
def YP(+j: Nat, +W: Nat, +q: Nat, +r: Nat) -> Nat: Nat.add(A.quad(Nat.add(Nat.mul(j, W), q)), r)
def ynext(+j: Nat, +W: Nat, +q: Nat, +r: Nat) -> {YP(1n+j, W, q, r) == Nat.add(YP(j, W, q, r), A.quad(W)) : Nat}:
  +q2 = Nat.add(Nat.mul(j, W), q)
  Equal.trans(Nat, YP(1n+j, W, q, r), Nat.add(A.quad(Nat.add(W, q2)), r), Nat.add(Nat.add(A.quad(q2), r), A.quad(W)),
    Equal.cong(Nat, Nat, z => Nat.add(A.quad(z), r), Nat.add(Nat.add(W, Nat.mul(j, W)), q), Nat.add(W, q2), F.nat__add_assoc(W, Nat.mul(j, W), q)),
    UW.pos_eq(W, q2, r))

# i * RS for record i = j (RS = 4 W bytes) within the tree.
def mulqW(+i: U32, +j: Nat, +Ru: U32, +W: Nat, +eR: {U32.to_nat(Ru) == A.quad(W) : Nat}, +ei: {U32.to_nat(i) == j : Nat},
    +hm: {Nat.is_lt(A.quad(Nat.mul(j, W)), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.mul(i, Ru)) == A.quad(Nat.mul(j, W)) : Nat}:
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, A.quad(W)), A.quad(Nat.mul(j, W)),
    Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, U32.to_nat(Ru)), Nat.mul(j, A.quad(W)),
      Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Ru)), U32.to_nat(i), j, ei), Equal.cong(Nat, Nat, z => Nat.mul(j, z), U32.to_nat(Ru), A.quad(W), eR)),
    VRL.mul_quad(j, W))
  Equal.trans(Nat, U32.to_nat(U32.mul(i, Ru)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), A.quad(Nat.mul(j, W)),
    VU.mul_lt32(i, Ru, F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(32n)) == True{} : Bool}, A.quad(Nat.mul(j, W)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)),
      Equal.sym(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), A.quad(Nat.mul(j, W)), em), hm)),
    em)

def mulq(+dd: Nat, +i: U32, +j: Nat, +Ru: U32, +W: Nat, +eR: {U32.to_nat(Ru) == A.quad(W) : Nat}, +ei: {U32.to_nat(i) == j : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hm: {Nat.is_le(A.quad(Nat.mul(j, W)), VB.pw(2n+dd)) == True{} : Bool})
    -> {U32.to_nat(U32.mul(i, Ru)) == A.quad(Nat.mul(j, W)) : Nat}:
  +P2 = VB.pw(2n+dd)
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, A.quad(W)), A.quad(Nat.mul(j, W)),
    Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, U32.to_nat(Ru)), Nat.mul(j, A.quad(W)),
      Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Ru)), U32.to_nat(i), j, ei), Equal.cong(Nat, Nat, z => Nat.mul(j, z), U32.to_nat(Ru), A.quad(W), eR)),
    VRL.mul_quad(j, W))
  Equal.trans(Nat, U32.to_nat(U32.mul(i, Ru)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), A.quad(Nat.mul(j, W)),
    VU.mul_le(i, Ru, F.u32__pow2u(2n+dd), F.logic__subst(Nat, z => {Nat.is_le(Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), z) == True{} : Bool}, P2, U32.to_nat(F.u32__pow2u(2n+dd)),
      Equal.sym(Nat, U32.to_nat(F.u32__pow2u(2n+dd)), P2, F.u32__pow2u_value(2n+dd, F.nat__lt_trans(2n+dd, 31n, 32n, hdd, {==}))),
      F.logic__subst(Nat, z => {Nat.is_le(z, P2) == True{} : Bool}, A.quad(Nat.mul(j, W)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Equal.sym(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), A.quad(Nat.mul(j, W)), em), hm))),
    em)

# Record j of a run of LT bytes at X = 4 q + r, the records j + 1 + k <= the run: its position, and its room.
def rposW(+X: U32, +i: U32, +j: Nat, +k: Nat, +q: Nat, +r: Nat, +W: Nat, +Ru: U32, +LT: Nat, +dd: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +eR: {U32.to_nat(Ru) == A.quad(W) : Nat}, +ei: {U32.to_nat(i) == j : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hW: {Nat.is_le(1n, W) == True{} : Bool}, +hj: {Nat.is_le(A.quad(Nat.mul(Nat.add(1n+k, j), W)), LT) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, U32.mul(i, Ru))) == YP(j, W, q, r) : Nat}:
  +jW = Nat.mul(j, W)
  +h0 = F.nat__lt_le_trans(jW, Nat.mul(1n+j, W), Nat.mul(Nat.add(1n+k, j), W),
    F.nat__lt_le_trans(jW, 1n+jW, Nat.add(W, jW), F.nat__lt_succ(jW), Order.add_right(1n, W, jW, hW)),
    VRL.mul_mono(1n+j, Nat.add(1n+k, j), W, Order.left_below_sum(k, j)))
  +h1 = F.nat__lt_le_trans(A.quad(jW), A.quad(Nat.mul(Nat.add(1n+k, j), W)), LT, VF.qlt(jW, Nat.mul(Nat.add(1n+k, j), W), h0), hj)
  +hm = F.nat__lt_le_trans(A.quad(jW), LT, F.spec_common__pow2(32n), h1,
    F.nat__le_trans(LT, Nat.add(Nat.add(A.quad(q), r), LT), F.spec_common__pow2(32n), Order.left_below_sum(Nat.add(A.quad(q), r), LT),
      F.nat__le_trans(Nat.add(Nat.add(A.quad(q), r), LT), A.quad(VB.pw(dd)), F.spec_common__pow2(32n), xend(q, r, LT, dd, hl), UW.q32(dd, hd))))
  fposW(X, q, r, jW, U32.mul(i, Ru), LT, dd, e, mulqW(i, j, Ru, W, eR, ei, hm), hd, h1, hl)

def rpos(+X: U32, +i: U32, +j: Nat, +k: Nat, +q: Nat, +r: Nat, +W: Nat, +Ru: U32, +LT: Nat, +dd: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +eR: {U32.to_nat(Ru) == A.quad(W) : Nat}, +ei: {U32.to_nat(i) == j : Nat},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hj: {Nat.is_le(A.quad(Nat.mul(Nat.add(1n+k, j), W)), LT) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, U32.mul(i, Ru))) == YP(j, W, q, r) : Nat}:
  +h1 = F.nat__le_trans(A.quad(Nat.mul(j, W)), A.quad(Nat.mul(Nat.add(1n+k, j), W)), LT,
    VME.quad_mono(Nat.mul(j, W), Nat.mul(Nat.add(1n+k, j), W), VRL.mul_mono(j, Nat.add(1n+k, j), W, F.nat__le_trans(j, Nat.add(k, j), 1n+Nat.add(k, j), Order.left_below_sum(k, j), Order.left_below_sum(1n, Nat.add(k, j))))), hj)
  +hm = F.nat__le_trans(A.quad(Nat.mul(j, W)), LT, VB.pw(2n+dd), h1,
    F.nat__le_trans(LT, Nat.add(Nat.add(A.quad(q), r), LT), VB.pw(2n+dd), Order.left_below_sum(Nat.add(A.quad(q), r), LT), xend(q, r, LT, dd, hl)))
  fpos(X, q, r, Nat.mul(j, W), U32.mul(i, Ru), LT, dd, e, mulq(dd, i, j, Ru, W, eR, ei, hd, hm), hd, h1, hl)
def rroom(+j: Nat, +k: Nat, +q: Nat, +r: Nat, +W: Nat, +LT: Nat, +dd: Nat,
    +hj: {Nat.is_le(A.quad(Nat.mul(Nat.add(1n+k, j), W)), LT) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(Nat.mul(j, W), q), WD.NWN(Nat.add(r, A.quad(W)))), VB.pw(dd)) == True{} : Bool}:
  +h1 = F.nat__le_trans(A.quad(Nat.mul(1n+j, W)), A.quad(Nat.mul(Nat.add(1n+k, j), W)), LT,
    VME.quad_mono(Nat.mul(1n+j, W), Nat.mul(Nat.add(1n+k, j), W), VRL.mul_mono(1n+j, Nat.add(1n+k, j), W, Order.left_below_sum(k, j))), hj)
  +e1 = Equal.trans(Nat, A.quad(Nat.mul(1n+j, W)), Nat.add(A.quad(W), A.quad(Nat.mul(j, W))), Nat.add(A.quad(Nat.mul(j, W)), A.quad(W)),
    Equal.sym(Nat, Nat.add(A.quad(W), A.quad(Nat.mul(j, W))), A.quad(Nat.add(W, Nat.mul(j, W))), VF.quad_add(W, Nat.mul(j, W))),
    F.nat__add_comm(A.quad(W), A.quad(Nat.mul(j, W))))
  froom(q, r, dd, Nat.mul(j, W), A.quad(W), LT, F.logic__subst(Nat, z => {Nat.is_le(z, LT) == True{} : Bool}, A.quad(Nat.mul(1n+j, W)), Nat.add(A.quad(Nat.mul(j, W)), A.quad(W)), e1, h1), hl)

# A splice of nothing.
def spl_nil(+B: +List<U32>, +X: Nat) -> {UW.SPL(B, X, []) == B : +List<U32>}:
  %Equal.sym(Nat, Nat.add(X, 0n), X, F.nat__add_zero(X)) : {AP(VS.bt(X, B), VS.bdr(_, B)) == B : +List<U32>}
  UW.bt_bdr_split(X, B)

# x + x = 2 x (the fixed vectors' size bounds over a symbolic power of two).
law add_self_double:
  for +x: Nat
  {Nat.add(x, x) == Nat.double(x) : Nat}
def add_self_double(x):
  match x:
    case 0n: {==}
    case 1n+ +p:
      Equal.trans(Nat, Nat.add(1n+p, 1n+p), 1n+1n+Nat.add(p, p), Nat.double(1n+p),
        Equal.cong(Nat, Nat, z => 1n+z, Nat.add(p, 1n+p), 1n+Nat.add(p, p), F.nat__add_succ(p, p)),
        Equal.trans(Nat, 1n+1n+Nat.add(p, p), 1n+1n+Nat.double(p), Nat.double(1n+p),
          Equal.cong(Nat, Nat, z => 1n+1n+z, Nat.add(p, p), Nat.double(p), add_self_double(p)),
          Equal.sym(Nat, Nat.double(1n+p), Nat.add(2n, Nat.double(p)), F.nat__double_succ(p))))

# 31 + 2^e <= 2^e1 for e1 = 1 + e, when 5 <= e: a fixed vector's YL bound, the power symbolic
# (e1 a parameter: 1n+21n is not the literal 22n, and comparing them would evaluate the powers).
def yl_pow(+e: Nat, +e1: Nat, +ee: {1n+e == e1 : Nat}, +h5: {Nat.is_le(5n, e) == True{} : Bool})
    -> {Nat.is_le(Nat.add(31n, VB.pw(e)), VB.pw(e1)) == True{} : Bool}:
  +x = VB.pw(e)
  +h31 = F.nat__le_trans(31n, VB.pw(5n), x, {==}, F.nat__pow2_mono(5n, e, h5))
  +h = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, x), z) == True{} : Bool}, Nat.add(x, x), Nat.double(x), add_self_double(x), Order.add_right(31n, x, x, h31))
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, x), VB.pw(z)) == True{} : Bool}, 1n+e, e1, ee, h)

# ---- the region's end below 2^32 (the encoder-window twins' hl32) ---------------------------------------------
# hl32: 4 q + (r + L) < 2^32 (the region's last byte is a U32 position), the byte-exact companion of hl.

# 4 q + y <= 4 (q + NWN y).
def yq(+q: Nat, +y: Nat) -> {Nat.is_le(Nat.add(A.quad(q), y), A.quad(Nat.add(q, WD.NWN(y)))) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), y), z) == True{} : Bool}, Nat.add(A.quad(q), A.quad(WD.NWN(y))), A.quad(Nat.add(q, WD.NWN(y))),
    VF.quad_add(q, WD.NWN(y)),
    Order.add_left(A.quad(q), y, A.quad(WD.NWN(y)), nwn_ge(y)))

# At dd < 29 (the old names): hl gives hl32.
def hl32w(+q: Nat, +r: Nat, +L: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, L)), F.spec_common__pow2(32n)) == True{} : Bool}:
  F.nat__le_lt_trans(Nat.add(A.quad(q), Nat.add(r, L)), A.quad(Nat.add(q, WD.NWN(Nat.add(r, L)))), F.spec_common__pow2(32n),
    yq(q, Nat.add(r, L)), VF.r32w(Nat.add(q, WD.NWN(Nat.add(r, L))), dd, hd, hl))

# The region's length and start are below 2^32.
def yl32(+q: Nat, +r: Nat, +L: Nat, +h: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, L)), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {Nat.is_lt(L, F.spec_common__pow2(32n)) == True{} : Bool}:
  F.nat__le_lt_trans(L, Nat.add(A.quad(q), Nat.add(r, L)), F.spec_common__pow2(32n),
    F.nat__le_trans(L, Nat.add(r, L), Nat.add(A.quad(q), Nat.add(r, L)), Order.left_below_sum(r, L), Order.left_below_sum(A.quad(q), Nat.add(r, L))), h)

# froom's field region (4 k + m <= L) ends inside U32 positions.
def froom32(+q: Nat, +r: Nat, +dd: Nat, +k: Nat, +m: Nat, +L: Nat, +hk: {Nat.is_le(Nat.add(A.quad(k), m), L) == True{} : Bool},
    +hl32: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, L)), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(A.quad(Nat.add(k, q)), Nat.add(r, m)), F.spec_common__pow2(32n)) == True{} : Bool}:
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
  F.nat__le_lt_trans(y1, y2, F.spec_common__pow2(32n), h12, hl32)

# rroom's record region (records j + 1 + k <= LT / W) ends inside U32 positions.
def rroom32(+j: Nat, +k: Nat, +q: Nat, +r: Nat, +W: Nat, +LT: Nat, +dd: Nat,
    +hj: {Nat.is_le(A.quad(Nat.mul(Nat.add(1n+k, j), W)), LT) == True{} : Bool},
    +hl32: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, LT)), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(A.quad(Nat.add(Nat.mul(j, W), q)), Nat.add(r, A.quad(W))), F.spec_common__pow2(32n)) == True{} : Bool}:
  +h1 = F.nat__le_trans(A.quad(Nat.mul(1n+j, W)), A.quad(Nat.mul(Nat.add(1n+k, j), W)), LT,
    VME.quad_mono(Nat.mul(1n+j, W), Nat.mul(Nat.add(1n+k, j), W), VRL.mul_mono(1n+j, Nat.add(1n+k, j), W, Order.left_below_sum(k, j))), hj)
  +e1 = Equal.trans(Nat, A.quad(Nat.mul(1n+j, W)), Nat.add(A.quad(W), A.quad(Nat.mul(j, W))), Nat.add(A.quad(Nat.mul(j, W)), A.quad(W)),
    Equal.sym(Nat, Nat.add(A.quad(W), A.quad(Nat.mul(j, W))), A.quad(Nat.add(W, Nat.mul(j, W))), VF.quad_add(W, Nat.mul(j, W))),
    F.nat__add_comm(A.quad(W), A.quad(Nat.mul(j, W))))
  froom32(q, r, dd, Nat.mul(j, W), A.quad(W), LT, F.logic__subst(Nat, z => {Nat.is_le(z, LT) == True{} : Bool}, A.quad(Nat.mul(1n+j, W)), Nat.add(A.quad(Nat.mul(j, W)), A.quad(W)), e1, h1), hl32)
