import Base
import ../compact/found.bend as F
import ./vbuf.bend as VB
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vu32.bend as VU

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
