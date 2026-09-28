import Base
import ../compact/found.bend as F
import ./vbuf.bend as VB
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vu32.bend as VU
import ./vmul.bend as VM
import ./vme.bend as VME

# GENERATED from codegen/vrl.bend.in by codegen/var_rlist.py. Do not edit.
# Arrays of any element type (lists of records): Array.set on a perfect tree.

def mget(-A: Data, m: Maybe<&2, A>, +dflt: A) -> A:
  match m:
    case None{}: dflt
    case Some{v}: v

def ng(-A: Data, +xs: List<&2, A>, +i: Nat, +dflt: A, +h: {Nat.is_lt(i, F.spec_common__length(A, xs)) == True{} : Bool},
    +m: Maybe<&2, A>, +e: {F.spec_common__nth(A, xs, i) == m : Maybe<&2, A>})
    -> {m == Some{mget(A, m, dflt)} : Maybe<&2, A>}:
  match m:
    case None{}: Empty.absurd({None{} == Some{mget(A, None{}, dflt)} : Maybe<&2, A>}, F.list__sc_nth_some(A, xs, i, h, e))
    case Some{+v}: {==}

def nth_get(-A: Data, +xs: List<&2, A>, +i: Nat, +dflt: A, +h: {Nat.is_lt(i, F.spec_common__length(A, xs)) == True{} : Bool})
    -> {F.spec_common__nth(A, xs, i) == Some{mget(A, F.spec_common__nth(A, xs, i), dflt)} : Maybe<&2, A>}:
  ng(A, xs, i, dflt, h, F.spec_common__nth(A, xs, i), {==})

# Array.set at index q = i < 2^d of a perfect tree is the tree's update.
def set_g(-T: Data, +d: Nat, +t: F.array__Tree<T>, +q: U32, +i: Nat, +v: T, +dflt: T, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(T, d, t) == True{} : Bool})
    -> {Array.set(T, F.array__thaw(T, t), q, v) == F.array__thaw(T, F.array__upd(T, d, t, i, v)) : Array<T>}:
  %eq : {Array.set(T, F.array__thaw(T, t), q, v) == F.array__thaw(T, F.array__upd(T, d, t, _, v)) : Array<T>}
  +hq = F.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(d)) == True{} : Bool}, i, U32.to_nat(q), Equal.sym(Nat, U32.to_nat(q), i, eq), hi)
  F.array__set(T, d, t, q, v, mget(T, F.spec_common__nth(T, F.array__slots(T, t), U32.to_nat(q)), dflt), hd, hq,
    nth_get(T, F.array__slots(T, t), U32.to_nat(q), dflt, F.array__len_lt(T, d, t, U32.to_nat(q), pf, hq)), pf)

# ---- positions of consecutive records -----------------------------------------------------------

def pos(+j: Nat, +R: Nat, +x: Nat) -> Nat: Nat.add(Nat.mul(j, R), x)

law mul_mono:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.mul(a, c), Nat.mul(b, c)) == True{} : Bool}
def mul_mono(a, b, c, h):
  match a b:
    case 0n _: F.nat__zero_le(Nat.mul(b, c))
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(Nat.mul(1n+p, c), Nat.mul(0n, c)) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: Order.add_left(c, Nat.mul(p, c), Nat.mul(q, c), mul_mono(p, q, c, h))

# a <= a (1 + r)
law le_mul:
  for +a: Nat
  for +r: Nat
  {Nat.is_le(a, Nat.mul(a, 1n+r)) == True{} : Bool}
def le_mul(a, r):
  match a:
    case 0n: {==}
    case 1n+ +p:
      F.nat__le_trans(p, Nat.mul(p, 1n+r), Nat.add(r, Nat.mul(p, 1n+r)), le_mul(p, r), Order.left_below_sum(r, Nat.mul(p, 1n+r)))

# The record after record j: its end is within the end of the last of j + 2 + q records.
def nextfit(+j: Nat, +q: Nat, +R: Nat, +x: Nat, +P: Nat, +h: {Nat.is_le(pos(Nat.add(2n+q, j), R, x), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(pos(1n+j, R, x), R), P) == True{} : Bool}:
  +M = Nat.mul(1n+j, R)
  +e = Equal.trans(Nat, Nat.add(Nat.add(M, x), R), Nat.add(M, Nat.add(x, R)), Nat.add(Nat.add(M, R), x), F.nat__add_assoc(M, x, R),
    Equal.trans(Nat, Nat.add(M, Nat.add(x, R)), Nat.add(M, Nat.add(R, x)), Nat.add(Nat.add(M, R), x),
      Equal.cong(Nat, Nat, z => Nat.add(M, z), Nat.add(x, R), Nat.add(R, x), F.nat__add_comm(x, R)),
      Equal.sym(Nat, Nat.add(Nat.add(M, R), x), Nat.add(M, Nat.add(R, x)), F.nat__add_assoc(M, R, x))))
  +e2 = Equal.trans(Nat, Nat.add(Nat.add(M, R), x), Nat.add(Nat.add(R, M), x), pos(2n+j, R, x),
    Equal.cong(Nat, Nat, z => Nat.add(z, x), Nat.add(M, R), Nat.add(R, M), F.nat__add_comm(M, R)), {==})
  +hj = Order.left_below_sum(q, j)
  +hm = Order.add_right(Nat.mul(2n+j, R), Nat.mul(Nat.add(2n+q, j), R), x, mul_mono(2n+j, Nat.add(2n+q, j), R, hj))
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, pos(2n+j, R, x), Nat.add(pos(1n+j, R, x), R), Equal.sym(Nat, Nat.add(pos(1n+j, R, x), R), pos(2n+j, R, x), Equal.trans(Nat, Nat.add(pos(1n+j, R, x), R), Nat.add(Nat.add(M, R), x), pos(2n+j, R, x), e, e2)),
    F.nat__le_trans(pos(2n+j, R, x), pos(Nat.add(2n+q, j), R, x), P, hm, h))

# The U32 position of record 1 + j, off + (i + 1) R, is x + (1 + j) R.
def posU(+d: Nat, +off: U32, +x: Nat, +i: U32, +j: Nat, +Ru: U32, +r: Nat, +eR: {U32.to_nat(Ru) == 1n+r : Nat},
    +eo: {U32.to_nat(off) == x : Nat}, +ej: {U32.to_nat(i) == j : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(pos(1n+j, 1n+r, x), 1n+r), A.quad(VB.pw(d))) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, U32.mul(U32.add(i, 1), Ru))) == pos(1n+j, 1n+r, x) : Nat}:
  +hd2 = F.nat__lt_trans(2n+d, 30n, 31n, hd, {==})
  +P = A.quad(VB.pw(d))
  +hp = F.nat__le_trans(pos(1n+j, 1n+r, x), Nat.add(pos(1n+j, 1n+r, x), 1n+r), P, F.nat__le_add_right(pos(1n+j, 1n+r, x), 1n+r), hb)
  +hmP = F.nat__le_trans(Nat.mul(1n+j, 1n+r), pos(1n+j, 1n+r, x), P, F.nat__le_add_right(Nat.mul(1n+j, 1n+r), x), hp)
  +e1 = VB.add_le_at(i, 1, j, 2n+d, ej, hd2, F.nat__le_trans(1n+j, Nat.mul(1n+j, 1n+r), P, le_mul(1n+j, r), hmP))
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), Nat.mul(1n+j, U32.to_nat(Ru)), Nat.mul(1n+j, 1n+r),
    Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Ru)), U32.to_nat(U32.add(i, 1)), 1n+j, e1),
    Equal.cong(Nat, Nat, z => Nat.mul(1n+j, z), U32.to_nat(Ru), 1n+r, eR))
  +e2 = Equal.trans(Nat, U32.to_nat(U32.mul(U32.add(i, 1), Ru)), Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), Nat.mul(1n+j, 1n+r),
    VU.mul_le(U32.add(i, 1), Ru, F.u32__pow2u(2n+d),
      F.logic__subst(Nat, z => {Nat.is_le(Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), z) == True{} : Bool}, P, U32.to_nat(F.u32__pow2u(2n+d)),
        Equal.sym(Nat, U32.to_nat(F.u32__pow2u(2n+d)), P, F.u32__pow2u_value(2n+d, F.nat__lt_trans(2n+d, 31n, 32n, hd2, {==}))),
        F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.mul(1n+j, 1n+r), Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), Equal.sym(Nat, Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), Nat.mul(1n+j, 1n+r), em), hmP))),
    em)
  +e3 = VB.add_le_at(off, U32.mul(U32.add(i, 1), Ru), x, 2n+d, eo, hd2,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, x), P) == True{} : Bool}, Nat.mul(1n+j, 1n+r), U32.to_nat(U32.mul(U32.add(i, 1), Ru)), Equal.sym(Nat, U32.to_nat(U32.mul(U32.add(i, 1), Ru)), Nat.mul(1n+j, 1n+r), e2), hp))
  Equal.trans(Nat, U32.to_nat(U32.add(off, U32.mul(U32.add(i, 1), Ru))), Nat.add(U32.to_nat(U32.mul(U32.add(i, 1), Ru)), x), pos(1n+j, 1n+r, x), e3,
    Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(U32.mul(U32.add(i, 1), Ru)), Nat.mul(1n+j, 1n+r), e2))

# The index after i: 1 + j.
def succU(+d: Nat, +i: U32, +j: Nat, +r: Nat, +x: Nat, +ej: {U32.to_nat(i) == j : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(pos(1n+j, 1n+r, x), 1n+r), A.quad(VB.pw(d))) == True{} : Bool})
    -> {U32.to_nat(U32.add(i, 1)) == 1n+j : Nat}:
  +P = A.quad(VB.pw(d))
  +hp = F.nat__le_trans(pos(1n+j, 1n+r, x), Nat.add(pos(1n+j, 1n+r, x), 1n+r), P, F.nat__le_add_right(pos(1n+j, 1n+r, x), 1n+r), hb)
  +hmP = F.nat__le_trans(Nat.mul(1n+j, 1n+r), pos(1n+j, 1n+r, x), P, F.nat__le_add_right(Nat.mul(1n+j, 1n+r), x), hp)
  VB.add_le_at(i, 1, j, 2n+d, ej, F.nat__lt_trans(2n+d, 30n, 31n, hd, {==}), F.nat__le_trans(1n+j, Nat.mul(1n+j, 1n+r), P, le_mul(1n+j, r), hmP))

# ---- the same at any depth: the record ends below 2^32 (every window of an n <= NMAX buffer) ----

def posU32(+off: U32, +x: Nat, +i: U32, +j: Nat, +Ru: U32, +r: Nat, +eR: {U32.to_nat(Ru) == 1n+r : Nat},
    +eo: {U32.to_nat(off) == x : Nat}, +ej: {U32.to_nat(i) == j : Nat},
    +hb: {Nat.is_lt(Nat.add(pos(1n+j, 1n+r, x), 1n+r), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, U32.mul(U32.add(i, 1), Ru))) == pos(1n+j, 1n+r, x) : Nat}:
  +P = F.spec_common__pow2(32n)
  +hp = F.nat__le_lt_trans(pos(1n+j, 1n+r, x), Nat.add(pos(1n+j, 1n+r, x), 1n+r), P, F.nat__le_add_right(pos(1n+j, 1n+r, x), 1n+r), hb)
  +hmP = F.nat__le_lt_trans(Nat.mul(1n+j, 1n+r), pos(1n+j, 1n+r, x), P, F.nat__le_add_right(Nat.mul(1n+j, 1n+r), x), hp)
  +e1 = VB.add_lt32(i, 1, j, ej, F.nat__le_lt_trans(1n+j, Nat.mul(1n+j, 1n+r), P, le_mul(1n+j, r), hmP))
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), Nat.mul(1n+j, U32.to_nat(Ru)), Nat.mul(1n+j, 1n+r),
    Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Ru)), U32.to_nat(U32.add(i, 1)), 1n+j, e1),
    Equal.cong(Nat, Nat, z => Nat.mul(1n+j, z), U32.to_nat(Ru), 1n+r, eR))
  +e2 = Equal.trans(Nat, U32.to_nat(U32.mul(U32.add(i, 1), Ru)), Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), Nat.mul(1n+j, 1n+r),
    VU.mul_lt32(U32.add(i, 1), Ru,
      F.logic__subst(Nat, z => {Nat.is_lt(z, P) == True{} : Bool}, Nat.mul(1n+j, 1n+r), Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), Equal.sym(Nat, Nat.mul(U32.to_nat(U32.add(i, 1)), U32.to_nat(Ru)), Nat.mul(1n+j, 1n+r), em), hmP)),
    em)
  +e3 = VB.add_lt32(off, U32.mul(U32.add(i, 1), Ru), x, eo,
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, x), P) == True{} : Bool}, Nat.mul(1n+j, 1n+r), U32.to_nat(U32.mul(U32.add(i, 1), Ru)), Equal.sym(Nat, U32.to_nat(U32.mul(U32.add(i, 1), Ru)), Nat.mul(1n+j, 1n+r), e2), hp))
  Equal.trans(Nat, U32.to_nat(U32.add(off, U32.mul(U32.add(i, 1), Ru))), Nat.add(U32.to_nat(U32.mul(U32.add(i, 1), Ru)), x), pos(1n+j, 1n+r, x), e3,
    Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(U32.mul(U32.add(i, 1), Ru)), Nat.mul(1n+j, 1n+r), e2))

def succU32(+i: U32, +j: Nat, +r: Nat, +x: Nat, +ej: {U32.to_nat(i) == j : Nat},
    +hb: {Nat.is_lt(Nat.add(pos(1n+j, 1n+r, x), 1n+r), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(i, 1)) == 1n+j : Nat}:
  +P = F.spec_common__pow2(32n)
  +hp = F.nat__le_lt_trans(pos(1n+j, 1n+r, x), Nat.add(pos(1n+j, 1n+r, x), 1n+r), P, F.nat__le_add_right(pos(1n+j, 1n+r, x), 1n+r), hb)
  +hmP = F.nat__le_lt_trans(Nat.mul(1n+j, 1n+r), pos(1n+j, 1n+r, x), P, F.nat__le_add_right(Nat.mul(1n+j, 1n+r), x), hp)
  VB.add_lt32(i, 1, j, ej, F.nat__le_lt_trans(1n+j, Nat.mul(1n+j, 1n+r), P, le_mul(1n+j, r), hmP))

# 4 c <= c (4 + r): a count of records of at least four bytes is at most a quarter of their bytes.
law quad_le_mul:
  for +c: Nat
  for +r: Nat
  {Nat.is_le(A.quad(c), Nat.mul(c, 4n+r)) == True{} : Bool}
def quad_le_mul(c, r):
  match c:
    case 0n: {==}
    case 1n+ +p:
      F.nat__le_trans(4n+A.quad(p), Nat.add(4n, Nat.mul(p, 4n+r)), Nat.add(4n+r, Nat.mul(p, 4n+r)),
        Order.add_left(4n, A.quad(p), Nat.mul(p, 4n+r), quad_le_mul(p, r)),
        Order.add_right(4n, 4n+r, Nat.mul(p, 4n+r), F.nat__le_add_right(4n, r)))

# ---- writes of consecutive records ------------------------------------------------------------

law mul_quad:
  for +j: Nat
  for +W: Nat
  {Nat.mul(j, A.quad(W)) == A.quad(Nat.mul(j, W)) : Nat}
def mul_quad(j, W):
  match j:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.mul(p, A.quad(W)), A.quad(Nat.mul(p, W)), mul_quad(p, W)) : {Nat.add(A.quad(W), _) == A.quad(Nat.add(W, Nat.mul(p, W))) : Nat}
      Equal.sym(Nat, A.quad(Nat.add(W, Nat.mul(p, W))), Nat.add(A.quad(W), A.quad(Nat.mul(p, W))), VM.quad_add(W, Nat.mul(p, W)))

def lt_le(+a: Nat, +b: Nat, +h: {Nat.is_lt(a, b) == True{} : Bool}) -> {Nat.is_le(a, b) == True{} : Bool}:
  F.nat__le_trans(a, 1n+a, b, Order.left_below_sum(1n, a), F.nat__lt_succ_le_succ(a, b, h))

# Record j's words (W from word Q + W j) fit when record j + 1 starts within P.
def fit0(+j: Nat, +W: Nat, +Q: Nat, +P: Nat, +h: {Nat.is_le(pos(1n+j, W, Q), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(W, pos(j, W, Q)), P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, pos(1n+j, W, Q), Nat.add(W, pos(j, W, Q)), F.nat__add_assoc(W, Nat.mul(j, W), Q), h)

def fitk(+j: Nat, +q: Nat, +W: Nat, +Q: Nat, +P: Nat, +h: {Nat.is_le(pos(Nat.add(2n+q, j), W, Q), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(W, pos(j, W, Q)), P) == True{} : Bool}:
  +hj = F.nat__le_trans(j, Nat.add(q, j), 1n+Nat.add(q, j), Order.left_below_sum(q, j), Order.left_below_sum(1n, Nat.add(q, j)))
  fit0(j, W, Q, P, F.nat__le_trans(pos(1n+j, W, Q), pos(Nat.add(2n+q, j), W, Q), P, Order.add_right(Nat.mul(1n+j, W), Nat.mul(Nat.add(2n+q, j), W), Q, mul_mono(1n+j, Nat.add(2n+q, j), W, hj)), h))

# The byte position of record j: 4 (Q + W j).
law qlt:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_lt(a, b) == True{} : Bool}
  {Nat.is_lt(A.quad(a), A.quad(b)) == True{} : Bool}
def qlt(a, b, h):
  match a b:
    case _ 0n: Empty.absurd({Nat.is_lt(A.quad(a), A.quad(0n)) == True{} : Bool}, F.nat__lt_zero_absurd(a, h))
    case 0n 1n+ +q: {==}
    case 1n+ +p 1n+ +q: qlt(p, q, h)

# The position of record j at any output depth dd < 31 (records of W >= 1 words: the sums stay below 2^32).
def posWW(+dd: Nat, +bp: U32, +Q: Nat, +i: U32, +j: Nat, +Ru: U32, +W: Nat, +eR: {U32.to_nat(Ru) == A.quad(W) : Nat},
    +ep: {U32.to_nat(bp) == A.quad(Q) : Nat}, +ei: {U32.to_nat(i) == j : Nat}, +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hW: {Nat.is_le(1n, W) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(W, pos(j, W, Q)), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(bp, U32.mul(i, Ru))) == A.quad(pos(j, W, Q)) : Nat}:
  +P32 = F.spec_common__pow2(32n)
  +hlt = F.nat__lt_le_trans(pos(j, W, Q), Nat.add(W, pos(j, W, Q)), VB.pw(dd),
    F.logic__subst(Nat, z => {Nat.is_lt(z, Nat.add(W, pos(j, W, Q))) == True{} : Bool}, Nat.add(0n, pos(j, W, Q)), pos(j, W, Q), {==},
      F.nat__lt_le_trans(Nat.add(0n, pos(j, W, Q)), Nat.add(1n, pos(j, W, Q)), Nat.add(W, pos(j, W, Q)), F.nat__lt_succ(pos(j, W, Q)), Order.add_right(1n, W, pos(j, W, Q), hW))),
    hb)
  +hq = F.nat__lt_le_trans(A.quad(pos(j, W, Q)), A.quad(VB.pw(dd)), P32, qlt(pos(j, W, Q), VB.pw(dd), hlt),
    F.logic__subst(Nat, z => {Nat.is_le(z, P32) == True{} : Bool}, VB.pw(2n+dd), A.quad(VB.pw(dd)), {==}, VB.pw2d32(dd, hdd)))
  +hm = F.nat__le_lt_trans(A.quad(Nat.mul(j, W)), A.quad(pos(j, W, Q)), P32, VME.quad_mono(Nat.mul(j, W), pos(j, W, Q), F.nat__le_add_right(Nat.mul(j, W), Q)), hq)
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, A.quad(W)), A.quad(Nat.mul(j, W)),
    Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, U32.to_nat(Ru)), Nat.mul(j, A.quad(W)),
      Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Ru)), U32.to_nat(i), j, ei), Equal.cong(Nat, Nat, z => Nat.mul(j, z), U32.to_nat(Ru), A.quad(W), eR)),
    mul_quad(j, W))
  +e2 = Equal.trans(Nat, U32.to_nat(U32.mul(i, Ru)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), A.quad(Nat.mul(j, W)),
    VU.mul_lt32(i, Ru, F.logic__subst(Nat, z => {Nat.is_lt(z, P32) == True{} : Bool}, A.quad(Nat.mul(j, W)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Equal.sym(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), A.quad(Nat.mul(j, W)), em), hm)),
    em)
  +hs = F.logic__subst(Nat, z => {Nat.is_lt(z, P32) == True{} : Bool}, A.quad(pos(j, W, Q)), Nat.add(A.quad(Nat.mul(j, W)), A.quad(Q)), VM.quad_add(Nat.mul(j, W), Q), hq)
  +e3 = VB.add_lt32(bp, U32.mul(i, Ru), A.quad(Q), ep,
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, A.quad(Q)), P32) == True{} : Bool}, A.quad(Nat.mul(j, W)), U32.to_nat(U32.mul(i, Ru)), Equal.sym(Nat, U32.to_nat(U32.mul(i, Ru)), A.quad(Nat.mul(j, W)), e2), hs))
  Equal.trans(Nat, U32.to_nat(U32.add(bp, U32.mul(i, Ru))), Nat.add(U32.to_nat(U32.mul(i, Ru)), A.quad(Q)), A.quad(pos(j, W, Q)), e3,
    Equal.trans(Nat, Nat.add(U32.to_nat(U32.mul(i, Ru)), A.quad(Q)), Nat.add(A.quad(Nat.mul(j, W)), A.quad(Q)), A.quad(pos(j, W, Q)),
      Equal.cong(Nat, Nat, z => Nat.add(z, A.quad(Q)), U32.to_nat(U32.mul(i, Ru)), A.quad(Nat.mul(j, W)), e2),
      Equal.sym(Nat, A.quad(pos(j, W, Q)), Nat.add(A.quad(Nat.mul(j, W)), A.quad(Q)), VM.quad_add(Nat.mul(j, W), Q))))

def posW(+dd: Nat, +bp: U32, +Q: Nat, +i: U32, +j: Nat, +Ru: U32, +W: Nat, +eR: {U32.to_nat(Ru) == A.quad(W) : Nat},
    +ep: {U32.to_nat(bp) == A.quad(Q) : Nat}, +ei: {U32.to_nat(i) == j : Nat}, +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(W, pos(j, W, Q)), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(bp, U32.mul(i, Ru))) == A.quad(pos(j, W, Q)) : Nat}:
  +P2 = VB.pw(2n+dd)
  +hq = VME.quad_mono(pos(j, W, Q), VB.pw(dd), F.nat__le_trans(pos(j, W, Q), Nat.add(W, pos(j, W, Q)), VB.pw(dd), Order.left_below_sum(W, pos(j, W, Q)), hb))
  +hm = F.nat__le_trans(A.quad(Nat.mul(j, W)), A.quad(pos(j, W, Q)), P2, VME.quad_mono(Nat.mul(j, W), pos(j, W, Q), F.nat__le_add_right(Nat.mul(j, W), Q)), hq)
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, A.quad(W)), A.quad(Nat.mul(j, W)),
    Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, U32.to_nat(Ru)), Nat.mul(j, A.quad(W)),
      Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Ru)), U32.to_nat(i), j, ei), Equal.cong(Nat, Nat, z => Nat.mul(j, z), U32.to_nat(Ru), A.quad(W), eR)),
    mul_quad(j, W))
  +e2 = Equal.trans(Nat, U32.to_nat(U32.mul(i, Ru)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), A.quad(Nat.mul(j, W)),
    VU.mul_le(i, Ru, F.u32__pow2u(2n+dd), F.logic__subst(Nat, z => {Nat.is_le(Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), z) == True{} : Bool}, P2, U32.to_nat(F.u32__pow2u(2n+dd)),
      Equal.sym(Nat, U32.to_nat(F.u32__pow2u(2n+dd)), P2, F.u32__pow2u_value(2n+dd, F.nat__lt_trans(2n+dd, 31n, 32n, hdd, {==}))),
      F.logic__subst(Nat, z => {Nat.is_le(z, P2) == True{} : Bool}, A.quad(Nat.mul(j, W)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Equal.sym(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), A.quad(Nat.mul(j, W)), em), hm))),
    em)
  +hs = F.logic__subst(Nat, z => {Nat.is_le(z, P2) == True{} : Bool}, A.quad(pos(j, W, Q)), Nat.add(A.quad(Nat.mul(j, W)), A.quad(Q)), VM.quad_add(Nat.mul(j, W), Q), hq)
  +e3 = VB.add_le_at(bp, U32.mul(i, Ru), A.quad(Q), 2n+dd, ep, hdd,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, A.quad(Q)), P2) == True{} : Bool}, A.quad(Nat.mul(j, W)), U32.to_nat(U32.mul(i, Ru)), Equal.sym(Nat, U32.to_nat(U32.mul(i, Ru)), A.quad(Nat.mul(j, W)), e2), hs))
  Equal.trans(Nat, U32.to_nat(U32.add(bp, U32.mul(i, Ru))), Nat.add(U32.to_nat(U32.mul(i, Ru)), A.quad(Q)), A.quad(pos(j, W, Q)), e3,
    Equal.trans(Nat, Nat.add(U32.to_nat(U32.mul(i, Ru)), A.quad(Q)), Nat.add(A.quad(Nat.mul(j, W)), A.quad(Q)), A.quad(pos(j, W, Q)),
      Equal.cong(Nat, Nat, z => Nat.add(z, A.quad(Q)), U32.to_nat(U32.mul(i, Ru)), A.quad(Nat.mul(j, W)), e2),
      Equal.sym(Nat, A.quad(pos(j, W, Q)), Nat.add(A.quad(Nat.mul(j, W)), A.quad(Q)), VM.quad_add(Nat.mul(j, W), Q))))

# A non-empty count is >= 1.
def cposu(+n: U32, +c: Nat, +ec: {U32.to_nat(n) == c : Nat}, +ee: {U32.is_eq(n, 0) == False{} : Bool}) -> {Nat.is_le(1n, c) == True{} : Bool}:
  match c:
    case 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, F.logic__true_false(Equal.trans(Bool, True{}, U32.is_eq(n, 0), False{},
      Equal.sym(Bool, U32.is_eq(n, 0), True{}, F.u32alg__eq_true(n, 0, F.u32__injective(n, 0, ec))), ee)))
    case 1n+ +p: F.nat__zero_le(p)

def u32le_n(+n: U32, +L: U32, +c: Nat, +ec: {U32.to_nat(n) == c : Nat}, +h: {Nat.is_le(c, U32.to_nat(L)) == True{} : Bool}) -> {U32.is_le(n, L) == True{} : Bool}:
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(n), U32.to_nat(L)), U32.is_le(n, L), Equal.sym(Bool, U32.is_le(n, L), Nat.is_le(U32.to_nat(n), U32.to_nat(L)), VU.le_u32(n, L)),
    F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(L)) == True{} : Bool}, c, U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), c, ec), h))

# The position after record j is record j + 1's.
def pnx(+j: Nat, +W: Nat, +Q: Nat) -> {Nat.add(pos(j, W, Q), W) == pos(1n+j, W, Q) : Nat}:
  +M = Nat.mul(j, W)
  Equal.trans(Nat, Nat.add(Nat.add(M, Q), W), Nat.add(M, Nat.add(Q, W)), pos(1n+j, W, Q), F.nat__add_assoc(M, Q, W),
    Equal.trans(Nat, Nat.add(M, Nat.add(Q, W)), Nat.add(M, Nat.add(W, Q)), pos(1n+j, W, Q), Equal.cong(Nat, Nat, z => Nat.add(M, z), Nat.add(Q, W), Nat.add(W, Q), F.nat__add_comm(Q, W)),
      Equal.trans(Nat, Nat.add(M, Nat.add(W, Q)), Nat.add(Nat.add(M, W), Q), pos(1n+j, W, Q), Equal.sym(Nat, Nat.add(Nat.add(M, W), Q), Nat.add(M, Nat.add(W, Q)), F.nat__add_assoc(M, W, Q)),
        Equal.cong(Nat, Nat, z => Nat.add(z, Q), Nat.add(M, W), Nat.add(W, M), F.nat__add_comm(M, W)))))

def pmono(+j: Nat, +W: Nat, +Q: Nat) -> {Nat.is_le(pos(j, W, Q), pos(1n+j, W, Q)) == True{} : Bool}:
  Order.add_right(Nat.mul(j, W), Nat.mul(1n+j, W), Q, Order.left_below_sum(W, Nat.mul(j, W)))

def pnx0(+j: Nat, +W: Nat, +Q: Nat) -> {Nat.add(W, pos(j, W, Q)) == pos(1n+j, W, Q) : Nat}:
  Equal.sym(Nat, pos(1n+j, W, Q), Nat.add(W, pos(j, W, Q)), F.nat__add_assoc(W, Nat.mul(j, W), Q))

# fit0's other direction: the run's end is record j + 1's position.
def fit0inv(+j: Nat, +W: Nat, +Q: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(W, pos(j, W, Q)), P) == True{} : Bool})
    -> {Nat.is_le(pos(1n+j, W, Q), P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(W, pos(j, W, Q)), pos(1n+j, W, Q), pnx0(j, W, Q), h)

# the first record of k + 1 fits
def fitk0(+j: Nat, +k: Nat, +W: Nat, +Q: Nat, +P: Nat, +h: {Nat.is_le(pos(Nat.add(1n+k, j), W, Q), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(W, pos(j, W, Q)), P) == True{} : Bool}:
  fit0(j, W, Q, P, F.nat__le_trans(pos(1n+j, W, Q), pos(Nat.add(1n+k, j), W, Q), P,
    Order.add_right(Nat.mul(1n+j, W), Nat.mul(Nat.add(1n+k, j), W), Q, mul_mono(1n+j, Nat.add(1n+k, j), W, Order.left_below_sum(k, j))), h))
