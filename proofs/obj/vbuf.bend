import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../compact/buf.bend as BF
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS

# Variable-size codec laws, runtime side: the word loops of src/obj.bend
# (bulk copies, the input copy `copy_in`, the output writers) on the array
# model of proofs/compact/found_generated.bend. An array is `thaw(t)` for a perfect tree
# t of depth d < 31; indices are U32 words whose values are carried as Nat
# equations `to_nat(i) == n`, bounded by 2^d, so no statement mentions a
# closed power of two and no U32 operation wraps.

# ---- index arithmetic ------------------------------------------------------------------

def pw(+d: Nat) -> Nat: F.spec_common__pow2(d)

def bound_le(+a: U32, +c: U32, +i: Nat, +d: Nat, +ea: {U32.to_nat(a) == i : Nat}, +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +h: {Nat.is_lt(Nat.add(U32.to_nat(c), i), pw(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(c)), U32.to_nat(F.u32__pow2u(d))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(F.u32__pow2u(d)), pw(d), F.u32__pow2u_value(d, hd)) : {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(c)), _) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(a), i, ea) : {Nat.is_le(Nat.add(_, U32.to_nat(c)), pw(d)) == True{} : Bool}
  %F.nat__add_comm(U32.to_nat(c), i) : {Nat.is_le(_, pw(d)) == True{} : Bool}
  F.nat__lt_le(Nat.add(U32.to_nat(c), i), pw(d), h)

# a + c does not wrap below 2^d.
def add_at(+a: U32, +c: U32, +i: Nat, +d: Nat, +ea: {U32.to_nat(a) == i : Nat}, +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +h: {Nat.is_lt(Nat.add(U32.to_nat(c), i), pw(d)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, c)) == Nat.add(U32.to_nat(c), i) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(a, c)), Nat.add(U32.to_nat(a), U32.to_nat(c)), A.add_le(a, c, F.u32__pow2u(d), bound_le(a, c, i, d, ea, hd, h))) :
    {_ == Nat.add(U32.to_nat(c), i) : Nat}
  %Equal.sym(Nat, U32.to_nat(a), i, ea) : {Nat.add(_, U32.to_nat(c)) == Nat.add(U32.to_nat(c), i) : Nat}
  F.nat__add_comm(i, U32.to_nat(c))

# ---- reads and writes ---------------------------------------------------------------

def slot(t: F.array__Tree<U32>, +i: Nat) -> U32: F.flat__nthc(F.array__slots(U32, t), i)

def get_n(+d: Nat, +t: F.array__Tree<U32>, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.get(U32, F.array__thaw(U32, t), q) == (F.array__thaw(U32, t), slot(t, i)) : Array<U32> & U32}:
  %eq : {Array.get(U32, F.array__thaw(U32, t), q) == (F.array__thaw(U32, t), slot(t, _)) : Array<U32> & U32}
  +hq = F.logic__subst(Nat, z => {Nat.is_lt(z, pw(d)) == True{} : Bool}, i, U32.to_nat(q), Equal.sym(Nat, U32.to_nat(q), i, eq), hi)
  F.array__get(U32, d, t, q, slot(t, U32.to_nat(q)), hd, hq,
    F.flat__nthc_nth(F.array__slots(U32, t), U32.to_nat(q), F.array__len_lt(U32, d, t, U32.to_nat(q), pf, hq)), pf)

def set_n(+d: Nat, +t: F.array__Tree<U32>, +q: U32, +i: Nat, +v: U32, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.set(U32, F.array__thaw(U32, t), q, v) == F.array__thaw(U32, F.array__upd(U32, d, t, i, v)) : Array<U32>}:
  %eq : {Array.set(U32, F.array__thaw(U32, t), q, v) == F.array__thaw(U32, F.array__upd(U32, d, t, _, v)) : Array<U32>}
  +hq = F.logic__subst(Nat, z => {Nat.is_lt(z, pw(d)) == True{} : Bool}, i, U32.to_nat(q), Equal.sym(Nat, U32.to_nat(q), i, eq), hi)
  F.array__set(U32, d, t, q, v, slot(t, U32.to_nat(q)), hd, hq,
    F.flat__nthc_nth(F.array__slots(U32, t), U32.to_nat(q), F.array__len_lt(U32, d, t, U32.to_nat(q), pf, hq)), pf)

# Reads and writes at a + c, c a small literal.
def get_at(+d: Nat, +t: F.array__Tree<U32>, +a: U32, +c: U32, +i: Nat, +ea: {U32.to_nat(a) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(Nat.add(U32.to_nat(c), i), pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.get(U32, F.array__thaw(U32, t), U32.add(a, c)) == (F.array__thaw(U32, t), slot(t, Nat.add(U32.to_nat(c), i))) : Array<U32> & U32}:
  get_n(d, t, U32.add(a, c), Nat.add(U32.to_nat(c), i), add_at(a, c, i, d, ea, hd, hi), hd, hi, pf)

def set_at(+d: Nat, +t: F.array__Tree<U32>, +a: U32, +c: U32, +i: Nat, +v: U32, +ea: {U32.to_nat(a) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(Nat.add(U32.to_nat(c), i), pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.set(U32, F.array__thaw(U32, t), U32.add(a, c), v) == F.array__thaw(U32, F.array__upd(U32, d, t, Nat.add(U32.to_nat(c), i), v)) : Array<U32>}:
  set_n(d, t, U32.add(a, c), Nat.add(U32.to_nat(c), i), v, add_at(a, c, i, d, ea, hd, hi), hd, hi, pf)

# ---- bounds for a block of eight -----------------------------------------------------

law lt_kk:
  for +k: Nat
  for +m: Nat
  for +j: Nat
  for +h: {Nat.is_lt(k, m) == True{} : Bool}
  {Nat.is_lt(Nat.add(k, j), Nat.add(m, j)) == True{} : Bool}
def lt_kk(k, m, j, h):
  match k m:
    case 0n 0n: Empty.absurd({Nat.is_lt(j, j) == True{} : Bool}, F.logic__false_true(h))
    case 0n 1n+ +q: F.nat__le_lt_succ(j, Nat.add(q, j), Order.left_below_sum(q, j))
    case 1n+p 0n: Empty.absurd({Nat.is_lt(1n+Nat.add(p, j), j) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: lt_kk(p, q, j, h)

# k + j < P from 8 + X + j <= P, for k < 8.
def lt8(+k: Nat, +X: Nat, +j: Nat, +P: Nat, +hk: {Nat.is_lt(k, 8n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(8n+X, j), P) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(k, j), P) == True{} : Bool}:
  F.nat__lt_le_trans(Nat.add(k, j), Nat.add(8n+X, j), P, lt_kk(k, 8n+X, j, F.nat__lt_le_trans(k, 8n, 8n+X, hk, Order.below_sum(8n, X))), h)

# ---- word copies ------------------------------------------------------------------------

# n single-word copies: dst[j + x] = src[i + x] for x < n (the tree after them).
def mone(n: Nat, +i: Nat, +j: Nat, +dd: Nat, D: F.array__Tree<U32>, +S: F.array__Tree<U32>) -> F.array__Tree<U32>:
  match n:
    case 0n: D
    case 1n+p: mone(p, 1n+i, 1n+j, dd, F.array__upd(U32, dd, D, j, slot(S, i)), S)

law mone_perfect:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  {F.array__perfect(U32, dd, mone(n, i, j, dd, D, S)) == True{} : Bool}
def mone_perfect(n, i, j, dd, D, S, pf):
  match n:
    case 0n: pf
    case 1n+ +p: mone_perfect(p, 1n+i, 1n+j, dd, F.array__upd(U32, dd, D, j, slot(S, i)), S, F.array__upd_perfect(U32, dd, D, j, slot(S, i), pf))

# le: K + j <= 7 + j (K <= 7 a literal).

def c7(+a: U32, +b: U32, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +ea: {U32.to_nat(a) == i : Nat}, +eb: {U32.to_nat(b) == j : Nat},
    +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(7n+i, pw(ds)) == True{} : Bool}, +hj: {Nat.is_lt(7n+j, pw(dd)) == True{} : Bool},
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {O.ac_c7(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, 7n+i))) == (F.array__thaw(U32, mone(1n, 7n+i, 7n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add(b, 7), slot(S, 7n+i)), F.array__thaw(U32, F.array__upd(U32, dd, D, 7n+j, slot(S, 7n+i))), set_at(dd, D, b, 7, j, slot(S, 7n+i), eb, hdd, F.nat__le_lt_trans(Nat.add(7n, j), 7n+j, pw(dd), Order.left_below_sum(0n, j), hj), pfD)) :
    {(_, F.array__thaw(U32, S)) == (F.array__thaw(U32, mone(1n, 7n+i, 7n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  {==}

def c6(+a: U32, +b: U32, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +ea: {U32.to_nat(a) == i : Nat}, +eb: {U32.to_nat(b) == j : Nat},
    +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(7n+i, pw(ds)) == True{} : Bool}, +hj: {Nat.is_lt(7n+j, pw(dd)) == True{} : Bool},
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {O.ac_c6(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, 6n+i))) == (F.array__thaw(U32, mone(2n, 6n+i, 6n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add(b, 6), slot(S, 6n+i)), F.array__thaw(U32, F.array__upd(U32, dd, D, 6n+j, slot(S, 6n+i))), set_at(dd, D, b, 6, j, slot(S, 6n+i), eb, hdd, F.nat__le_lt_trans(Nat.add(6n, j), 7n+j, pw(dd), Order.left_below_sum(1n, j), hj), pfD)) :
    {O.ac_c7(a, b, _, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 7))) == (F.array__thaw(U32, mone(2n, 6n+i, 6n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 7)), (F.array__thaw(U32, S), slot(S, 7n+i)), get_at(ds, S, a, 7, i, ea, hds, F.nat__le_lt_trans(Nat.add(7n, i), 7n+i, pw(ds), Order.left_below_sum(0n, i), hi), pfS)) :
    {O.ac_c7(a, b, F.array__thaw(U32, F.array__upd(U32, dd, D, 6n+j, slot(S, 6n+i))), _) == (F.array__thaw(U32, mone(2n, 6n+i, 6n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  c7(a, b, i, j, dd, ds, F.array__upd(U32, dd, D, 6n+j, slot(S, 6n+i)), S, ea, eb, hdd, hds, hi, hj, F.array__upd_perfect(U32, dd, D, 6n+j, slot(S, 6n+i), pfD), pfS)

def c5(+a: U32, +b: U32, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +ea: {U32.to_nat(a) == i : Nat}, +eb: {U32.to_nat(b) == j : Nat},
    +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(7n+i, pw(ds)) == True{} : Bool}, +hj: {Nat.is_lt(7n+j, pw(dd)) == True{} : Bool},
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {O.ac_c5(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, 5n+i))) == (F.array__thaw(U32, mone(3n, 5n+i, 5n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add(b, 5), slot(S, 5n+i)), F.array__thaw(U32, F.array__upd(U32, dd, D, 5n+j, slot(S, 5n+i))), set_at(dd, D, b, 5, j, slot(S, 5n+i), eb, hdd, F.nat__le_lt_trans(Nat.add(5n, j), 7n+j, pw(dd), Order.left_below_sum(2n, j), hj), pfD)) :
    {O.ac_c6(a, b, _, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 6))) == (F.array__thaw(U32, mone(3n, 5n+i, 5n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 6)), (F.array__thaw(U32, S), slot(S, 6n+i)), get_at(ds, S, a, 6, i, ea, hds, F.nat__le_lt_trans(Nat.add(6n, i), 7n+i, pw(ds), Order.left_below_sum(1n, i), hi), pfS)) :
    {O.ac_c6(a, b, F.array__thaw(U32, F.array__upd(U32, dd, D, 5n+j, slot(S, 5n+i))), _) == (F.array__thaw(U32, mone(3n, 5n+i, 5n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  c6(a, b, i, j, dd, ds, F.array__upd(U32, dd, D, 5n+j, slot(S, 5n+i)), S, ea, eb, hdd, hds, hi, hj, F.array__upd_perfect(U32, dd, D, 5n+j, slot(S, 5n+i), pfD), pfS)

def c4(+a: U32, +b: U32, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +ea: {U32.to_nat(a) == i : Nat}, +eb: {U32.to_nat(b) == j : Nat},
    +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(7n+i, pw(ds)) == True{} : Bool}, +hj: {Nat.is_lt(7n+j, pw(dd)) == True{} : Bool},
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {O.ac_c4(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, 4n+i))) == (F.array__thaw(U32, mone(4n, 4n+i, 4n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add(b, 4), slot(S, 4n+i)), F.array__thaw(U32, F.array__upd(U32, dd, D, 4n+j, slot(S, 4n+i))), set_at(dd, D, b, 4, j, slot(S, 4n+i), eb, hdd, F.nat__le_lt_trans(Nat.add(4n, j), 7n+j, pw(dd), Order.left_below_sum(3n, j), hj), pfD)) :
    {O.ac_c5(a, b, _, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 5))) == (F.array__thaw(U32, mone(4n, 4n+i, 4n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 5)), (F.array__thaw(U32, S), slot(S, 5n+i)), get_at(ds, S, a, 5, i, ea, hds, F.nat__le_lt_trans(Nat.add(5n, i), 7n+i, pw(ds), Order.left_below_sum(2n, i), hi), pfS)) :
    {O.ac_c5(a, b, F.array__thaw(U32, F.array__upd(U32, dd, D, 4n+j, slot(S, 4n+i))), _) == (F.array__thaw(U32, mone(4n, 4n+i, 4n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  c5(a, b, i, j, dd, ds, F.array__upd(U32, dd, D, 4n+j, slot(S, 4n+i)), S, ea, eb, hdd, hds, hi, hj, F.array__upd_perfect(U32, dd, D, 4n+j, slot(S, 4n+i), pfD), pfS)

def c3(+a: U32, +b: U32, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +ea: {U32.to_nat(a) == i : Nat}, +eb: {U32.to_nat(b) == j : Nat},
    +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(7n+i, pw(ds)) == True{} : Bool}, +hj: {Nat.is_lt(7n+j, pw(dd)) == True{} : Bool},
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {O.ac_c3(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, 3n+i))) == (F.array__thaw(U32, mone(5n, 3n+i, 3n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add(b, 3), slot(S, 3n+i)), F.array__thaw(U32, F.array__upd(U32, dd, D, 3n+j, slot(S, 3n+i))), set_at(dd, D, b, 3, j, slot(S, 3n+i), eb, hdd, F.nat__le_lt_trans(Nat.add(3n, j), 7n+j, pw(dd), Order.left_below_sum(4n, j), hj), pfD)) :
    {O.ac_c4(a, b, _, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 4))) == (F.array__thaw(U32, mone(5n, 3n+i, 3n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 4)), (F.array__thaw(U32, S), slot(S, 4n+i)), get_at(ds, S, a, 4, i, ea, hds, F.nat__le_lt_trans(Nat.add(4n, i), 7n+i, pw(ds), Order.left_below_sum(3n, i), hi), pfS)) :
    {O.ac_c4(a, b, F.array__thaw(U32, F.array__upd(U32, dd, D, 3n+j, slot(S, 3n+i))), _) == (F.array__thaw(U32, mone(5n, 3n+i, 3n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  c4(a, b, i, j, dd, ds, F.array__upd(U32, dd, D, 3n+j, slot(S, 3n+i)), S, ea, eb, hdd, hds, hi, hj, F.array__upd_perfect(U32, dd, D, 3n+j, slot(S, 3n+i), pfD), pfS)

def c2(+a: U32, +b: U32, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +ea: {U32.to_nat(a) == i : Nat}, +eb: {U32.to_nat(b) == j : Nat},
    +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(7n+i, pw(ds)) == True{} : Bool}, +hj: {Nat.is_lt(7n+j, pw(dd)) == True{} : Bool},
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {O.ac_c2(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, 2n+i))) == (F.array__thaw(U32, mone(6n, 2n+i, 2n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add(b, 2), slot(S, 2n+i)), F.array__thaw(U32, F.array__upd(U32, dd, D, 2n+j, slot(S, 2n+i))), set_at(dd, D, b, 2, j, slot(S, 2n+i), eb, hdd, F.nat__le_lt_trans(Nat.add(2n, j), 7n+j, pw(dd), Order.left_below_sum(5n, j), hj), pfD)) :
    {O.ac_c3(a, b, _, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 3))) == (F.array__thaw(U32, mone(6n, 2n+i, 2n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 3)), (F.array__thaw(U32, S), slot(S, 3n+i)), get_at(ds, S, a, 3, i, ea, hds, F.nat__le_lt_trans(Nat.add(3n, i), 7n+i, pw(ds), Order.left_below_sum(4n, i), hi), pfS)) :
    {O.ac_c3(a, b, F.array__thaw(U32, F.array__upd(U32, dd, D, 2n+j, slot(S, 2n+i))), _) == (F.array__thaw(U32, mone(6n, 2n+i, 2n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  c3(a, b, i, j, dd, ds, F.array__upd(U32, dd, D, 2n+j, slot(S, 2n+i)), S, ea, eb, hdd, hds, hi, hj, F.array__upd_perfect(U32, dd, D, 2n+j, slot(S, 2n+i), pfD), pfS)

def c1(+a: U32, +b: U32, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +ea: {U32.to_nat(a) == i : Nat}, +eb: {U32.to_nat(b) == j : Nat},
    +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(7n+i, pw(ds)) == True{} : Bool}, +hj: {Nat.is_lt(7n+j, pw(dd)) == True{} : Bool},
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {O.ac_c1(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, 1n+i))) == (F.array__thaw(U32, mone(7n, 1n+i, 1n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add(b, 1), slot(S, 1n+i)), F.array__thaw(U32, F.array__upd(U32, dd, D, 1n+j, slot(S, 1n+i))), set_at(dd, D, b, 1, j, slot(S, 1n+i), eb, hdd, F.nat__le_lt_trans(Nat.add(1n, j), 7n+j, pw(dd), Order.left_below_sum(6n, j), hj), pfD)) :
    {O.ac_c2(a, b, _, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 2))) == (F.array__thaw(U32, mone(7n, 1n+i, 1n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 2)), (F.array__thaw(U32, S), slot(S, 2n+i)), get_at(ds, S, a, 2, i, ea, hds, F.nat__le_lt_trans(Nat.add(2n, i), 7n+i, pw(ds), Order.left_below_sum(5n, i), hi), pfS)) :
    {O.ac_c2(a, b, F.array__thaw(U32, F.array__upd(U32, dd, D, 1n+j, slot(S, 1n+i))), _) == (F.array__thaw(U32, mone(7n, 1n+i, 1n+j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  c2(a, b, i, j, dd, ds, F.array__upd(U32, dd, D, 1n+j, slot(S, 1n+i)), S, ea, eb, hdd, hds, hi, hj, F.array__upd_perfect(U32, dd, D, 1n+j, slot(S, 1n+i), pfD), pfS)

def c0(+a: U32, +b: U32, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +ea: {U32.to_nat(a) == i : Nat}, +eb: {U32.to_nat(b) == j : Nat},
    +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hds: {Nat.is_lt(ds, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(7n+i, pw(ds)) == True{} : Bool}, +hj: {Nat.is_lt(7n+j, pw(dd)) == True{} : Bool},
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {O.ac_c0(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, i))) == (F.array__thaw(U32, mone(8n, i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), U32.add(b, 0), slot(S, i)), F.array__thaw(U32, F.array__upd(U32, dd, D, j, slot(S, i))), set_at(dd, D, b, 0, j, slot(S, i), eb, hdd, F.nat__le_lt_trans(Nat.add(0n, j), 7n+j, pw(dd), Order.left_below_sum(7n, j), hj), pfD)) :
    {O.ac_c1(a, b, _, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 1))) == (F.array__thaw(U32, mone(8n, i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), U32.add(a, 1)), (F.array__thaw(U32, S), slot(S, 1n+i)), get_at(ds, S, a, 1, i, ea, hds, F.nat__le_lt_trans(Nat.add(1n, i), 7n+i, pw(ds), Order.left_below_sum(6n, i), hi), pfS)) :
    {O.ac_c1(a, b, F.array__thaw(U32, F.array__upd(U32, dd, D, j, slot(S, i))), _) == (F.array__thaw(U32, mone(8n, i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  c1(a, b, i, j, dd, ds, F.array__upd(U32, dd, D, j, slot(S, i)), S, ea, eb, hdd, hds, hi, hj, F.array__upd_perfect(U32, dd, D, j, slot(S, i), pfD), pfS)

def lt32(+d: Nat, +h: {Nat.is_lt(d, 31n) == True{} : Bool}) -> {Nat.is_lt(d, 32n) == True{} : Bool}:
  F.nat__lt_trans(d, 31n, 32n, h, {==})

def lt32s(+d: Nat, +h: {Nat.is_lt(d, 31n) == True{} : Bool}) -> {Nat.is_lt(1n+d, 32n) == True{} : Bool}: h

# x <= 2^d gives x < 2^(1 + d).
def le_pw_lt(+x: Nat, +d: Nat, +h: {Nat.is_le(x, pw(d)) == True{} : Bool}) -> {Nat.is_lt(x, pw(1n+d)) == True{} : Bool}:
  F.nat__le_lt_trans(x, pw(d), pw(1n+d), h, F.nat__pow2_lt_succ(d))

# i + k for a U32 index a == i, with i + k <= 2^d (d < 31).
def add_le_at(+a: U32, +c: U32, +i: Nat, +d: Nat, +ea: {U32.to_nat(a) == i : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(c), i), pw(d)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, c)) == Nat.add(U32.to_nat(c), i) : Nat}:
  add_at(a, c, i, 1n+d, ea, lt32s(d, hd), le_pw_lt(Nat.add(U32.to_nat(c), i), d, h))

def le8_shift(+X: Nat, +i: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(8n+X, i), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(X, 8n+i), P) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(X, 8n+i), 8n+Nat.add(X, i), F.lru_nat_algebra__add_swap(X, 8n, i)) : {Nat.is_le(_, P) == True{} : Bool}
  h

def le8_head(+X: Nat, +i: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(8n+X, i), P) == True{} : Bool})
    -> {Nat.is_le(8n+i, P) == True{} : Bool}:
  F.nat__le_trans(8n+i, Nat.add(8n+X, i), P, Order.add_left(8n, i, Nat.add(X, i), Order.left_below_sum(X, i)), h)

# The eight-word loop copies 8k words.
law blk:
  for +k: Nat
  for +a: U32
  for +b: U32
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +ds: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +ea: {U32.to_nat(a) == i : Nat}
  for +eb: {U32.to_nat(b) == j : Nat}
  for +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}
  for +hds: {Nat.is_lt(ds, 31n) == True{} : Bool}
  for +hi: {Nat.is_le(Nat.add(VS.x8(k), i), pw(ds)) == True{} : Bool}
  for +hj: {Nat.is_le(Nat.add(VS.x8(k), j), pw(dd)) == True{} : Bool}
  for +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool}
  {O.ac_blk(k, a, b, (F.array__thaw(U32, D), F.array__thaw(U32, S))) == (F.array__thaw(U32, mone(VS.x8(k), i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
def blk(k, a, b, i, j, dd, ds, D, S, ea, eb, hdd, hds, hi, hj, pfD, pfS):
  match k:
    case 0n: {==}
    case 1n+ +t:
      +M8 = mone(8n, i, j, dd, D, S)
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), a), (F.array__thaw(U32, S), slot(S, i)), get_n(ds, S, a, i, ea, lt32(ds, hds), lt8(0n, VS.x8(t), i, pw(ds), {==}, hi), pfS)) :
        {O.ac_blk(t, U32.add(a, 8), U32.add(b, 8), O.ac_c0(a, b, F.array__thaw(U32, D), _)) == (F.array__thaw(U32, mone(VS.x8(1n+t), i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
      %Equal.sym(Array<U32> & Array<U32>, O.ac_c0(a, b, F.array__thaw(U32, D), (F.array__thaw(U32, S), slot(S, i))), (F.array__thaw(U32, M8), F.array__thaw(U32, S)),
          c0(a, b, i, j, dd, ds, D, S, ea, eb, lt32(dd, hdd), lt32(ds, hds), lt8(7n, VS.x8(t), i, pw(ds), {==}, hi), lt8(7n, VS.x8(t), j, pw(dd), {==}, hj), pfD, pfS)) :
        {O.ac_blk(t, U32.add(a, 8), U32.add(b, 8), _) == (F.array__thaw(U32, mone(VS.x8(1n+t), i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
      blk(t, U32.add(a, 8), U32.add(b, 8), 8n+i, 8n+j, dd, ds, M8, S,
        add_le_at(a, 8, i, ds, ea, hds, le8_head(VS.x8(t), i, pw(ds), hi)),
        add_le_at(b, 8, j, dd, eb, hdd, le8_head(VS.x8(t), j, pw(dd), hj)),
        hdd, hds, le8_shift(VS.x8(t), i, pw(ds), hi), le8_shift(VS.x8(t), j, pw(dd), hj),
        mone_perfect(8n, i, j, dd, D, S, pfD), pfS)

def le1_head(+t: Nat, +i: Nat, +P: Nat, +h: {Nat.is_le(1n+Nat.add(t, i), P) == True{} : Bool}) -> {Nat.is_lt(i, P) == True{} : Bool}:
  F.nat__le_lt_trans(i, Nat.add(t, i), P, Order.left_below_sum(t, i), F.nat__succ_le_lt(Nat.add(t, i), P, h))

def le1_shift(+t: Nat, +i: Nat, +P: Nat, +h: {Nat.is_le(1n+Nat.add(t, i), P) == True{} : Bool}) -> {Nat.is_le(Nat.add(t, 1n+i), P) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(t, 1n+i), 1n+Nat.add(t, i), F.nat__add_succ(t, i)) : {Nat.is_le(_, P) == True{} : Bool}
  h

def le1_next(+t: Nat, +i: Nat, +P: Nat, +h: {Nat.is_le(1n+Nat.add(t, i), P) == True{} : Bool}) -> {Nat.is_le(1n+i, P) == True{} : Bool}:
  F.nat__lt_succ_le_succ(i, P, le1_head(t, i, P, h))

# The one-word loop copies k words.
law tail:
  for +k: Nat
  for +a: U32
  for +b: U32
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +ds: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +ea: {U32.to_nat(a) == i : Nat}
  for +eb: {U32.to_nat(b) == j : Nat}
  for +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}
  for +hds: {Nat.is_lt(ds, 31n) == True{} : Bool}
  for +hi: {Nat.is_le(Nat.add(k, i), pw(ds)) == True{} : Bool}
  for +hj: {Nat.is_le(Nat.add(k, j), pw(dd)) == True{} : Bool}
  for +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool}
  {O.ac_tail(k, a, b, (F.array__thaw(U32, D), F.array__thaw(U32, S))) == (F.array__thaw(U32, mone(k, i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
def tail(k, a, b, i, j, dd, ds, D, S, ea, eb, hdd, hds, hi, hj, pfD, pfS):
  match k:
    case 0n: {==}
    case 1n+ +t:
      +D1 = F.array__upd(U32, dd, D, j, slot(S, i))
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, S), a), (F.array__thaw(U32, S), slot(S, i)), get_n(ds, S, a, i, ea, lt32(ds, hds), le1_head(t, i, pw(ds), hi), pfS)) :
        {O.ac_tail(t, U32.add(a, 1), U32.add(b, 1), O.ac_w(b, F.array__thaw(U32, D), _)) == (F.array__thaw(U32, mone(1n+t, i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
      %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, D), b, slot(S, i)), F.array__thaw(U32, D1),
          set_n(dd, D, b, j, slot(S, i), eb, lt32(dd, hdd), le1_head(t, j, pw(dd), hj), pfD)) :
        {O.ac_tail(t, U32.add(a, 1), U32.add(b, 1), (_, F.array__thaw(U32, S))) == (F.array__thaw(U32, mone(1n+t, i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
      tail(t, U32.add(a, 1), U32.add(b, 1), 1n+i, 1n+j, dd, ds, D1, S,
        add_le_at(a, 1, i, ds, ea, hds, le1_next(t, i, pw(ds), hi)),
        add_le_at(b, 1, j, dd, eb, hdd, le1_next(t, j, pw(dd), hj)),
        hdd, hds, le1_shift(t, i, pw(ds), hi), le1_shift(t, j, pw(dd), hj),
        F.array__upd_perfect(U32, dd, D, j, slot(S, i), pfD), pfS)

# ---- the value of a word from its low bits ---------------------------------------------

def d3(+R: Nat) -> Nat: Nat.double(Nat.double(Nat.double(R)))

law x8_d3:
  for +R: Nat
  {VS.x8(R) == d3(R) : Nat}
def x8_d3(R):
  match R:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, VS.x8(p), d3(p), x8_d3(p)) : {8n+_ == 8n+d3(p) : Nat}
      {==}

def x8_add(+R: Nat, +k: Nat) -> {Nat.add(VS.x8(R), k) == Nat.add(k, d3(R)) : Nat}:
  %Equal.sym(Nat, VS.x8(R), d3(R), x8_d3(R)) : {Nat.add(_, k) == Nat.add(k, d3(R)) : Nat}
  F.nat__add_comm(d3(R), k)

def eighth_value(+b0: Bool, +b1: Bool, +b2: Bool, +r: Word(29n))
    -> {U32.to_nat(U32.shrn(U32{WCon{b0, WCon{b1, WCon{b2, r}}}}, 3n)) == Word.to_nat(29n, r) : Nat}:
  Equal.trans(Nat, Word.to_nat(32n, Word.shr.pad(31n, Word.shr.pad(30n, Word.shr.pad(29n, r)))), Word.to_nat(31n, Word.shr.pad(30n, Word.shr.pad(29n, r))), Word.to_nat(29n, r),
    BF.pad_value(31n, Word.shr.pad(30n, Word.shr.pad(29n, r))),
    Equal.trans(Nat, Word.to_nat(31n, Word.shr.pad(30n, Word.shr.pad(29n, r))), Word.to_nat(30n, Word.shr.pad(29n, r)), Word.to_nat(29n, r),
      BF.pad_value(30n, Word.shr.pad(29n, r)), BF.pad_value(29n, r)))

# A word is eight times its value shifted right by three, plus its low three bits.
law split8:
  for +x: U32
  {U32.to_nat(x) == Nat.add(VS.x8(U32.to_nat(U32.shrn(x, 3n))), U32.to_nat(U32.and(x, 7))) : Nat}
def split8(x):
  match x:
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, +r}}}}:
      %Equal.sym(Word(29n), Word.and(29n, r, Word.zero(29n)), Word.zero(29n), BF.and_zero(29n, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{False{}, r}}}}) == Nat.add(VS.x8(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{False{}, WCon{False{}, r}}}}, 3n))), U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{False{}, _}}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{False{}, WCon{False{}, r}}}}, 3n)), Word.to_nat(29n, r), eighth_value(False{}, False{}, False{}, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{False{}, r}}}}) == Nat.add(VS.x8(_), 0n) : Nat}
      %Equal.sym(Nat, Nat.add(VS.x8(Word.to_nat(29n, r)), 0n), Nat.add(0n, d3(Word.to_nat(29n, r))), x8_add(Word.to_nat(29n, r), 0n)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{False{}, r}}}}) == _ : Nat}
      {==}
    case U32{WCon{True{}, WCon{False{}, WCon{False{}, +r}}}}:
      %Equal.sym(Word(29n), Word.and(29n, r, Word.zero(29n)), Word.zero(29n), BF.and_zero(29n, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, WCon{False{}, r}}}}) == Nat.add(VS.x8(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, WCon{False{}, r}}}}, 3n))), U32.to_nat(U32{WCon{True{}, WCon{False{}, WCon{False{}, _}}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, WCon{False{}, r}}}}, 3n)), Word.to_nat(29n, r), eighth_value(True{}, False{}, False{}, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, WCon{False{}, r}}}}) == Nat.add(VS.x8(_), 1n) : Nat}
      %Equal.sym(Nat, Nat.add(VS.x8(Word.to_nat(29n, r)), 1n), Nat.add(1n, d3(Word.to_nat(29n, r))), x8_add(Word.to_nat(29n, r), 1n)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, WCon{False{}, r}}}}) == _ : Nat}
      {==}
    case U32{WCon{False{}, WCon{True{}, WCon{False{}, +r}}}}:
      %Equal.sym(Word(29n), Word.and(29n, r, Word.zero(29n)), Word.zero(29n), BF.and_zero(29n, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, WCon{False{}, r}}}}) == Nat.add(VS.x8(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, WCon{False{}, r}}}}, 3n))), U32.to_nat(U32{WCon{False{}, WCon{True{}, WCon{False{}, _}}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, WCon{False{}, r}}}}, 3n)), Word.to_nat(29n, r), eighth_value(False{}, True{}, False{}, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, WCon{False{}, r}}}}) == Nat.add(VS.x8(_), 2n) : Nat}
      %Equal.sym(Nat, Nat.add(VS.x8(Word.to_nat(29n, r)), 2n), Nat.add(2n, d3(Word.to_nat(29n, r))), x8_add(Word.to_nat(29n, r), 2n)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, WCon{False{}, r}}}}) == _ : Nat}
      {==}
    case U32{WCon{True{}, WCon{True{}, WCon{False{}, +r}}}}:
      %Equal.sym(Word(29n), Word.and(29n, r, Word.zero(29n)), Word.zero(29n), BF.and_zero(29n, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{False{}, r}}}}) == Nat.add(VS.x8(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, WCon{False{}, r}}}}, 3n))), U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{False{}, _}}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, WCon{False{}, r}}}}, 3n)), Word.to_nat(29n, r), eighth_value(True{}, True{}, False{}, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{False{}, r}}}}) == Nat.add(VS.x8(_), 3n) : Nat}
      %Equal.sym(Nat, Nat.add(VS.x8(Word.to_nat(29n, r)), 3n), Nat.add(3n, d3(Word.to_nat(29n, r))), x8_add(Word.to_nat(29n, r), 3n)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{False{}, r}}}}) == _ : Nat}
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, +r}}}}:
      %Equal.sym(Word(29n), Word.and(29n, r, Word.zero(29n)), Word.zero(29n), BF.and_zero(29n, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{True{}, r}}}}) == Nat.add(VS.x8(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{False{}, WCon{True{}, r}}}}, 3n))), U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{True{}, _}}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{False{}, WCon{True{}, r}}}}, 3n)), Word.to_nat(29n, r), eighth_value(False{}, False{}, True{}, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{True{}, r}}}}) == Nat.add(VS.x8(_), 4n) : Nat}
      %Equal.sym(Nat, Nat.add(VS.x8(Word.to_nat(29n, r)), 4n), Nat.add(4n, d3(Word.to_nat(29n, r))), x8_add(Word.to_nat(29n, r), 4n)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{True{}, r}}}}) == _ : Nat}
      {==}
    case U32{WCon{True{}, WCon{False{}, WCon{True{}, +r}}}}:
      %Equal.sym(Word(29n), Word.and(29n, r, Word.zero(29n)), Word.zero(29n), BF.and_zero(29n, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, WCon{True{}, r}}}}) == Nat.add(VS.x8(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, WCon{True{}, r}}}}, 3n))), U32.to_nat(U32{WCon{True{}, WCon{False{}, WCon{True{}, _}}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, WCon{True{}, r}}}}, 3n)), Word.to_nat(29n, r), eighth_value(True{}, False{}, True{}, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, WCon{True{}, r}}}}) == Nat.add(VS.x8(_), 5n) : Nat}
      %Equal.sym(Nat, Nat.add(VS.x8(Word.to_nat(29n, r)), 5n), Nat.add(5n, d3(Word.to_nat(29n, r))), x8_add(Word.to_nat(29n, r), 5n)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, WCon{True{}, r}}}}) == _ : Nat}
      {==}
    case U32{WCon{False{}, WCon{True{}, WCon{True{}, +r}}}}:
      %Equal.sym(Word(29n), Word.and(29n, r, Word.zero(29n)), Word.zero(29n), BF.and_zero(29n, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, WCon{True{}, r}}}}) == Nat.add(VS.x8(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, WCon{True{}, r}}}}, 3n))), U32.to_nat(U32{WCon{False{}, WCon{True{}, WCon{True{}, _}}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, WCon{True{}, r}}}}, 3n)), Word.to_nat(29n, r), eighth_value(False{}, True{}, True{}, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, WCon{True{}, r}}}}) == Nat.add(VS.x8(_), 6n) : Nat}
      %Equal.sym(Nat, Nat.add(VS.x8(Word.to_nat(29n, r)), 6n), Nat.add(6n, d3(Word.to_nat(29n, r))), x8_add(Word.to_nat(29n, r), 6n)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, WCon{True{}, r}}}}) == _ : Nat}
      {==}
    case U32{WCon{True{}, WCon{True{}, WCon{True{}, +r}}}}:
      %Equal.sym(Word(29n), Word.and(29n, r, Word.zero(29n)), Word.zero(29n), BF.and_zero(29n, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{True{}, r}}}}) == Nat.add(VS.x8(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, WCon{True{}, r}}}}, 3n))), U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{True{}, _}}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, WCon{True{}, r}}}}, 3n)), Word.to_nat(29n, r), eighth_value(True{}, True{}, True{}, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{True{}, r}}}}) == Nat.add(VS.x8(_), 7n) : Nat}
      %Equal.sym(Nat, Nat.add(VS.x8(Word.to_nat(29n, r)), 7n), Nat.add(7n, d3(Word.to_nat(29n, r))), x8_add(Word.to_nat(29n, r), 7n)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{True{}, r}}}}) == _ : Nat}
      {==}

law mone_add:
  for +m: Nat
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  {mone(n, Nat.add(m, i), Nat.add(m, j), dd, mone(m, i, j, dd, D, S), S) == mone(Nat.add(m, n), i, j, dd, D, S) : F.array__Tree<U32>}
def mone_add(m, n, i, j, dd, D, S):
  match m:
    case 0n: {==}
    case 1n+ +p:
      +D1 = F.array__upd(U32, dd, D, j, slot(S, i))
      %F.nat__add_succ(p, i) :
        {mone(n, _, 1n+Nat.add(p, j), dd, mone(p, 1n+i, 1n+j, dd, D1, S), S) == mone(Nat.add(p, n), 1n+i, 1n+j, dd, D1, S) : F.array__Tree<U32>}
      %F.nat__add_succ(p, j) :
        {mone(n, Nat.add(p, 1n+i), _, dd, mone(p, 1n+i, 1n+j, dd, D1, S), S) == mone(Nat.add(p, n), 1n+i, 1n+j, dd, D1, S) : F.array__Tree<U32>}
      mone_add(p, n, 1n+i, 1n+j, dd, D1, S)

def sub_mid(+A: Nat, +r: Nat, +i: Nat) -> {Nat.sub(Nat.add(Nat.add(A, r), i), r) == Nat.add(A, i) : Nat}:
  %Equal.sym(Nat, Nat.add(Nat.add(A, r), i), Nat.add(A, Nat.add(r, i)), F.nat__add_assoc(A, r, i)) : {Nat.sub(_, r) == Nat.add(A, i) : Nat}
  %Equal.sym(Nat, Nat.add(r, i), Nat.add(i, r), F.nat__add_comm(r, i)) : {Nat.sub(Nat.add(A, _), r) == Nat.add(A, i) : Nat}
  %F.nat__add_assoc(A, i, r) : {Nat.sub(_, r) == Nat.add(A, i) : Nat}
  %F.nat__add_comm(r, Nat.add(A, i)) : {Nat.sub(_, r) == Nat.add(A, i) : Nat}
  F.nat__add_sub_cancel(r, Nat.add(A, i))

def le_add_r(+A: Nat, +r: Nat, +i: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(A, r), i), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A, i), P) == True{} : Bool}:
  F.nat__le_trans(Nat.add(A, i), Nat.add(Nat.add(A, r), i), P, Order.add_right(A, Nat.add(A, r), i, Order.below_sum(A, r)), h)

def le_add_rot(+A: Nat, +r: Nat, +i: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(A, r), i), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(r, Nat.add(A, i)), P) == True{} : Bool}:
  %(Equal.trans(Nat, Nat.add(Nat.add(A, r), i), Nat.add(Nat.add(r, A), i), Nat.add(r, Nat.add(A, i)),
      Equal.cong(Nat, Nat, z => Nat.add(z, i), Nat.add(A, r), Nat.add(r, A), F.nat__add_comm(A, r)),
      F.nat__add_assoc(r, A, i))) : {Nat.is_le(_, P) == True{} : Bool}
  h

# The start of the remainder loop: a + nw - (nw & 7) == a + 8 (nw >> 3).
def rest_at(+a: U32, +nw: U32, +i: Nat, +ds: Nat, +ea: {U32.to_nat(a) == i : Nat}, +hds: {Nat.is_lt(ds, 31n) == True{} : Bool},
    +hi: {Nat.is_le(Nat.add(U32.to_nat(nw), i), pw(ds)) == True{} : Bool})
    -> {U32.to_nat(U32.sub(U32.add(a, nw), U32.and(nw, 7))) == Nat.add(VS.x8(U32.to_nat(U32.shrn(nw, 3n))), i) : Nat}:
  +A = VS.x8(U32.to_nat(U32.shrn(nw, 3n)))
  +r = U32.to_nat(U32.and(nw, 7))
  +e1 = add_le_at(a, nw, i, ds, ea, hds, hi)
  +le = F.logic__subst(Nat, z => {Nat.is_le(r, z) == True{} : Bool}, Nat.add(Nat.add(A, r), i), Nat.add(U32.to_nat(nw), i),
    Equal.cong(Nat, Nat, z => Nat.add(z, i), Nat.add(A, r), U32.to_nat(nw), Equal.sym(Nat, U32.to_nat(nw), Nat.add(A, r), split8(nw))),
    F.nat__le_trans(r, Nat.add(A, r), Nat.add(Nat.add(A, r), i), Order.left_below_sum(A, r), Order.below_sum(Nat.add(A, r), i)))
  %Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(a, nw), U32.and(nw, 7))), Nat.sub(U32.to_nat(U32.add(a, nw)), r),
      F.u32__sub_nat(U32.add(a, nw), U32.and(nw, 7), F.logic__subst(Nat, z => {Nat.is_le(r, z) == True{} : Bool}, Nat.add(U32.to_nat(nw), i), U32.to_nat(U32.add(a, nw)), Equal.sym(Nat, U32.to_nat(U32.add(a, nw)), Nat.add(U32.to_nat(nw), i), e1), le))) :
    {_ == Nat.add(A, i) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(a, nw)), Nat.add(U32.to_nat(nw), i), e1) : {Nat.sub(_, r) == Nat.add(A, i) : Nat}
  %Equal.sym(Nat, U32.to_nat(nw), Nat.add(A, r), split8(nw)) : {Nat.sub(Nat.add(_, i), r) == Nat.add(A, i) : Nat}
  sub_mid(A, r, i)

# The bulk copy moves nw words.
law acopy_ok:
  for +nw: U32
  for +a: U32
  for +b: U32
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +ds: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +ea: {U32.to_nat(a) == i : Nat}
  for +eb: {U32.to_nat(b) == j : Nat}
  for +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}
  for +hds: {Nat.is_lt(ds, 31n) == True{} : Bool}
  for +hi: {Nat.is_le(Nat.add(U32.to_nat(nw), i), pw(ds)) == True{} : Bool}
  for +hj: {Nat.is_le(Nat.add(U32.to_nat(nw), j), pw(dd)) == True{} : Bool}
  for +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool}
  {O.acopy(nw, a, b, F.array__thaw(U32, D), F.array__thaw(U32, S)) == (F.array__thaw(U32, mone(U32.to_nat(nw), i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
def acopy_ok(nw, a, b, i, j, dd, ds, D, S, ea, eb, hdd, hds, hi, hj, pfD, pfS):
  +q = U32.to_nat(U32.shrn(nw, 3n))
  +A = VS.x8(q)
  +r = U32.to_nat(U32.and(nw, 7))
  +sp = split8(nw)
  +hi2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, i), pw(ds)) == True{} : Bool}, U32.to_nat(nw), Nat.add(A, r), sp, hi)
  +hj2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, j), pw(dd)) == True{} : Bool}, U32.to_nat(nw), Nat.add(A, r), sp, hj)
  +M = mone(A, i, j, dd, D, S)
  %Equal.sym(Array<U32> & Array<U32>, O.ac_blk(q, a, b, (F.array__thaw(U32, D), F.array__thaw(U32, S))), (F.array__thaw(U32, M), F.array__thaw(U32, S)),
      blk(q, a, b, i, j, dd, ds, D, S, ea, eb, hdd, hds, le_add_r(A, r, i, pw(ds), hi2), le_add_r(A, r, j, pw(dd), hj2), pfD, pfS)) :
    {O.ac_tail(r, U32.sub(U32.add(a, nw), U32.and(nw, 7)), U32.sub(U32.add(b, nw), U32.and(nw, 7)), _) == (F.array__thaw(U32, mone(U32.to_nat(nw), i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & Array<U32>, O.ac_tail(r, U32.sub(U32.add(a, nw), U32.and(nw, 7)), U32.sub(U32.add(b, nw), U32.and(nw, 7)), (F.array__thaw(U32, M), F.array__thaw(U32, S))),
      (F.array__thaw(U32, mone(r, Nat.add(A, i), Nat.add(A, j), dd, M, S)), F.array__thaw(U32, S)),
      tail(r, U32.sub(U32.add(a, nw), U32.and(nw, 7)), U32.sub(U32.add(b, nw), U32.and(nw, 7)), Nat.add(A, i), Nat.add(A, j), dd, ds, M, S,
        rest_at(a, nw, i, ds, ea, hds, hi), rest_at(b, nw, j, dd, eb, hdd, hj), hdd, hds,
        le_add_rot(A, r, i, pw(ds), hi2), le_add_rot(A, r, j, pw(dd), hj2), mone_perfect(A, i, j, dd, D, S, pfD), pfS)) :
    {_ == (F.array__thaw(U32, mone(U32.to_nat(nw), i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %Equal.sym(Nat, U32.to_nat(nw), Nat.add(A, r), sp) :
    {(F.array__thaw(U32, mone(r, Nat.add(A, i), Nat.add(A, j), dd, M, S)), F.array__thaw(U32, S)) == (F.array__thaw(U32, mone(_, i, j, dd, D, S)), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  %mone_add(A, r, i, j, dd, D, S) :
    {(F.array__thaw(U32, mone(r, Nat.add(A, i), Nat.add(A, j), dd, M, S)), F.array__thaw(U32, S)) == (F.array__thaw(U32, _), F.array__thaw(U32, S)) : Array<U32> & Array<U32>}
  {==}

# ---- the words a copy leaves, as lists ------------------------------------------------

def len(+W: List<&2, U32>) -> Nat: F.spec_common__length(U32, W)

def wdr(n: Nat, W: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: W
    case 1n+p:
      match W:
        case Nil{}: []
        case Con{h, t}: wdr(p, t)

law wdr_eta:
  for +j: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_lt(j, len(W)) == True{} : Bool}
  {wdr(j, W) == Con{F.flat__nthc(W, j), wdr(1n+j, W)} : List<&2, U32>}
def wdr_eta(j, W, h):
  match j W:
    case 0n Nil{}: Empty.absurd({wdr(0n, Nil{}) == Con{F.flat__nthc(Nil{}, 0n), wdr(1n, Nil{})} : List<&2, U32>}, F.logic__false_true(h))
    case 0n Con{+x, +t}: {==}
    case 1n+ +p Nil{}: Empty.absurd({wdr(1n+p, Nil{}) == Con{F.flat__nthc(Nil{}, 1n+p), wdr(2n+p, Nil{})} : List<&2, U32>}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: wdr_eta(p, t, h)

# The list model of mone.
def lm(n: Nat, +i: Nat, +j: Nat, L: List<&2, U32>, +SL: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: L
    case 1n+p: lm(p, 1n+i, 1n+j, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i)), SL)

law lm_len:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +L: List<&2, U32>
  for +SL: List<&2, U32>
  {len(lm(n, i, j, L, SL)) == len(L) : Nat}
def lm_len(n, i, j, L, SL):
  match n:
    case 0n: {==}
    case 1n+ +p:
      %F.list__length_update(U32, L, j, F.flat__nthc(SL, i)) :
        {len(lm(p, 1n+i, 1n+j, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i)), SL)) == _ : Nat}
      lm_len(p, 1n+i, 1n+j, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i)), SL)

law lm_pre:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +L: List<&2, U32>
  for +SL: List<&2, U32>
  for +k: Nat
  for +hk: {Nat.is_lt(k, j) == True{} : Bool}
  {F.flat__nthc(lm(n, i, j, L, SL), k) == F.flat__nthc(L, k) : U32}
def lm_pre(n, i, j, L, SL, k, hk):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +L1 = F.spec_common__update(U32, L, j, F.flat__nthc(SL, i))
      %Equal.sym(U32, F.flat__nthc(lm(p, 1n+i, 1n+j, L1, SL), k), F.flat__nthc(L1, k), lm_pre(p, 1n+i, 1n+j, L1, SL, k, F.nat__lt_trans(k, j, 1n+j, hk, F.nat__lt_succ(j)))) :
        {_ == F.flat__nthc(L, k) : U32}
      F.flat__nthc_other(L, j, k, F.flat__nthc(SL, i), F.flat__ne_gt(j, k, hk))

law lm_win:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +L: List<&2, U32>
  for +SL: List<&2, U32>
  for +hj: {Nat.is_le(Nat.add(n, j), len(L)) == True{} : Bool}
  for +hi: {Nat.is_le(Nat.add(n, i), len(SL)) == True{} : Bool}
  {VS.wtake(n, wdr(j, lm(n, i, j, L, SL))) == VS.wtake(n, wdr(i, SL)) : List<&2, U32>}
def lm_win(n, i, j, L, SL, hj, hi):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +v = F.flat__nthc(SL, i)
      +L1 = F.spec_common__update(U32, L, j, v)
      +A = lm(p, 1n+i, 1n+j, L1, SL)
      +hjL = le1_head(p, j, len(L), hj)
      +hjA = F.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, len(L), len(A),
        Equal.sym(Nat, len(A), len(L), Equal.trans(Nat, len(A), len(L1), len(L), lm_len(p, 1n+i, 1n+j, L1, SL), F.list__length_update(U32, L, j, v))), hjL)
      %Equal.sym(List<&2, U32>, wdr(j, A), Con{F.flat__nthc(A, j), wdr(1n+j, A)}, wdr_eta(j, A, hjA)) :
        {VS.wtake(1n+p, _) == VS.wtake(1n+p, wdr(i, SL)) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, wdr(i, SL), Con{v, wdr(1n+i, SL)}, wdr_eta(i, SL, le1_head(p, i, len(SL), hi))) :
        {Con{F.flat__nthc(A, j), VS.wtake(p, wdr(1n+j, A))} == VS.wtake(1n+p, _) : List<&2, U32>}
      %Equal.sym(U32, F.flat__nthc(A, j), F.flat__nthc(L1, j), lm_pre(p, 1n+i, 1n+j, L1, SL, j, F.nat__lt_succ(j))) :
        {Con{_, VS.wtake(p, wdr(1n+j, A))} == Con{v, VS.wtake(p, wdr(1n+i, SL))} : List<&2, U32>}
      %Equal.sym(U32, F.flat__nthc(L1, j), v, F.flat__nthc_same(L, j, v, hjL)) :
        {Con{_, VS.wtake(p, wdr(1n+j, A))} == Con{v, VS.wtake(p, wdr(1n+i, SL))} : List<&2, U32>}
      %Equal.sym(List<&2, U32>, VS.wtake(p, wdr(1n+j, A)), VS.wtake(p, wdr(1n+i, SL)),
          lm_win(p, 1n+i, 1n+j, L1, SL,
            F.logic__subst(Nat, z => {Nat.is_le(Nat.add(p, 1n+j), z) == True{} : Bool}, len(L), len(L1), Equal.sym(Nat, len(L1), len(L), F.list__length_update(U32, L, j, v)), le1_shift(p, j, len(L), hj)),
            le1_shift(p, i, len(SL), hi))) :
        {Con{v, _} == Con{v, VS.wtake(p, wdr(1n+i, SL))} : List<&2, U32>}
      {==}

# The slots of the copied tree are its list model.
law slots_mone:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hj: {Nat.is_le(Nat.add(n, j), pw(dd)) == True{} : Bool}
  {F.array__slots(U32, mone(n, i, j, dd, D, S)) == lm(n, i, j, F.array__slots(U32, D), F.array__slots(U32, S)) : List<&2, U32>}
def slots_mone(n, i, j, dd, D, S, pf, hj):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +D1 = F.array__upd(U32, dd, D, j, slot(S, i))
      %Equal.sym(List<&2, U32>, F.array__slots(U32, mone(p, 1n+i, 1n+j, dd, D1, S)), lm(p, 1n+i, 1n+j, F.array__slots(U32, D1), F.array__slots(U32, S)),
          slots_mone(p, 1n+i, 1n+j, dd, D1, S, F.array__upd_perfect(U32, dd, D, j, slot(S, i), pf), le1_shift(p, j, pw(dd), hj))) :
        {_ == lm(p, 1n+i, 1n+j, F.spec_common__update(U32, F.array__slots(U32, D), j, slot(S, i)), F.array__slots(U32, S)) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, F.array__slots(U32, D1), F.spec_common__update(U32, F.array__slots(U32, D), j, slot(S, i)),
          F.array__upd_slots(U32, dd, D, j, slot(S, i), le1_head(p, j, pw(dd), hj), pf)) :
        {lm(p, 1n+i, 1n+j, _, F.array__slots(U32, S)) == lm(p, 1n+i, 1n+j, F.spec_common__update(U32, F.array__slots(U32, D), j, slot(S, i)), F.array__slots(U32, S)) : List<&2, U32>}
      {==}

def wt_eta(+k: Nat, +j: Nat, +W: List<&2, U32>, +h: {Nat.is_lt(j, len(W)) == True{} : Bool})
    -> {VS.wtake(1n+k, wdr(j, W)) == Con{F.flat__nthc(W, j), VS.wtake(k, wdr(1n+j, W))} : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, wdr(j, W), Con{F.flat__nthc(W, j), wdr(1n+j, W)}, wdr_eta(j, W, h)) :
    {VS.wtake(1n+k, _) == Con{F.flat__nthc(W, j), VS.wtake(k, wdr(1n+j, W))} : List<&2, U32>}
  {==}

law wdr_upd:
  for +j: Nat
  for +L: List<&2, U32>
  for +k: Nat
  for +v: U32
  for +h: {Nat.is_lt(k, j) == True{} : Bool}
  {wdr(j, F.spec_common__update(U32, L, k, v)) == wdr(j, L) : List<&2, U32>}
def wdr_upd(j, L, k, v, h):
  match j L k:
    case 0n _ _: Empty.absurd({wdr(0n, F.spec_common__update(U32, L, k, v)) == wdr(0n, L) : List<&2, U32>}, F.logic__false_true(F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(k, 0n), False{}, F.nat__not_lt_zero(k), h)))
    case 1n+ +p Nil{} _: {==}
    case 1n+ +p Con{+x, +t} 0n: {==}
    case 1n+ +p Con{+x, +t} 1n+ +q: wdr_upd(p, t, q, v, h)

# ---- the object API's input limit -----------------------------------------------------------
# NMAX = 2^32 - 32: the largest input length n whose size arithmetic does not wrap a U32 (the
# decoders' list storage ((n + 31) >> 5) 8 + 8 words, O.depth_for / O.zeros_for; B.capacity's
# (n + 3) >> 2 and every offset sum of a validated window stay below it). UMAX = 2^32 - 1 = NMAX + 31.
# The decode laws take n <= NMAX as the U32 comparison U32.is_le(n, NMAX()), and trees of depth d < 31
# (B.capacity(NMAX) = 30). Both constants are only ever compared, never unfolded in unary.
def NMAX() -> U32: 4294967264
def UMAX() -> U32: 4294967295

# NMAX + 31 = UMAX as Nats. Both are the same 27 high one bits x under five low bits (0s for NMAX,
# 1s for UMAX): e_hi proves 31 + [x 00000] = [x 11111] for a variable x, so no 2^32-sized Nat is
# ever built; the constants are rewritten to their constructor form (x = 27 ones) first.
def e_hi(+x: Word(27n)) -> {Nat.add(31n, U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, x}}}}}})) == U32.to_nat(U32{WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, x}}}}}}) : Nat}: {==}
def nmax_bits() -> {NMAX() == U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}: {==}
def umax_bits() -> {UMAX() == U32{WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : U32}: {==}
def e_umax() -> {Nat.add(31n, U32.to_nat(NMAX())) == U32.to_nat(UMAX()) : Nat}:
  %Equal.sym(U32, NMAX(), U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, nmax_bits()) : {Nat.add(31n, U32.to_nat(_)) == U32.to_nat(UMAX()) : Nat}
  %Equal.sym(U32, UMAX(), U32{WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, umax_bits()) : {Nat.add(31n, U32.to_nat(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == U32.to_nat(_) : Nat}
  e_hi(WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}})

def le_u32n(+a: U32, +b: U32) -> {U32.is_le(a, b) == Nat.is_le(U32.to_nat(a), U32.to_nat(b)) : Bool}:
  %Equal.sym(Cmp, U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), F.u32__u32_cmp(a, b)) : {Cmp.is_le(_) == Nat.is_le(U32.to_nat(a), U32.to_nat(b)) : Bool}
  {==}

# 31 + n <= UMAX for every n <= NMAX.
def le_nmax(+n: U32, +hN: {U32.is_le(n, NMAX()) == True{} : Bool})
    -> {Nat.is_le(Nat.add(31n, U32.to_nat(n)), U32.to_nat(UMAX())) == True{} : Bool}:
  +h = F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(n, NMAX()), Nat.is_le(U32.to_nat(n), U32.to_nat(NMAX())), le_u32n(n, NMAX()), hN)
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, U32.to_nat(n)), z) == True{} : Bool}, Nat.add(31n, U32.to_nat(NMAX())), U32.to_nat(UMAX()), e_umax(),
    Order.add_left(31n, U32.to_nat(n), U32.to_nat(NMAX()), h))

# A sum within UMAX does not wrap.
def add_nw(+a: U32, +c: U32, +i: Nat, +ea: {U32.to_nat(a) == i : Nat},
    +h: {Nat.is_le(Nat.add(U32.to_nat(c), i), U32.to_nat(UMAX())) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, c)) == Nat.add(U32.to_nat(c), i) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(a, c)), Nat.add(U32.to_nat(a), U32.to_nat(c)),
      A.add_le(a, c, UMAX(), F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(UMAX())) == True{} : Bool}, Nat.add(U32.to_nat(c), i), Nat.add(U32.to_nat(a), U32.to_nat(c)),
        Equal.trans(Nat, Nat.add(U32.to_nat(c), i), Nat.add(i, U32.to_nat(c)), Nat.add(U32.to_nat(a), U32.to_nat(c)), F.nat__add_comm(U32.to_nat(c), i),
          Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(c)), i, U32.to_nat(a), Equal.sym(Nat, U32.to_nat(a), i, ea))), h))) :
    {_ == Nat.add(U32.to_nat(c), i) : Nat}
  %Equal.sym(Nat, U32.to_nat(a), i, ea) : {Nat.add(_, U32.to_nat(c)) == Nat.add(U32.to_nat(c), i) : Nat}
  F.nat__add_comm(i, U32.to_nat(c))

# add_nw with the addend's value k given as a Nat (c + i <= UMAX spelled with k): the hypothesis
# is moved to to_nat(c) inside a subst motive, so no conversion meets the closed UMAX in unary.
def add_nwk(+a: U32, +c: U32, +k: Nat, +i: Nat, +ea: {U32.to_nat(a) == i : Nat}, +ek: {U32.to_nat(c) == k : Nat},
    +h: {Nat.is_le(Nat.add(k, i), U32.to_nat(UMAX())) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, c)) == Nat.add(U32.to_nat(c), i) : Nat}:
  add_nw(a, c, i, ea, F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, i), U32.to_nat(UMAX())) == True{} : Bool}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ek), h))

# Every U32 is below 2^32 (spelled F.spec_common__pow2(32n): a closed power is only compared syntactically).
def u32_lt(+x: U32) -> {Nat.is_lt(U32.to_nat(x), F.spec_common__pow2(32n)) == True{} : Bool}:
  match x:
    case U32{+w}:
      F.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(U32{w}), z) == True{} : Bool}, F.spec_numeric__scale_binary(32n, 1n), F.spec_common__pow2(32n),
        Equal.sym(Nat, F.spec_common__pow2(32n), F.spec_numeric__scale_binary(32n, 1n), F.u32__pow2_scale(32n)),
        F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_numeric__scale_binary(32n, 1n)) == True{} : Bool}, F.spec_numeric__unsigned(32n, w), U32.to_nat(U32{w}),
          Equal.sym(Nat, U32.to_nat(U32{w}), F.spec_numeric__unsigned(32n, w), F.u32__to_nat_word(w)), F.u32__WB_unsigned(32n, w)))

def umax_lt(+x: Nat, +h: {Nat.is_le(x, U32.to_nat(UMAX())) == True{} : Bool}) -> {Nat.is_lt(x, F.spec_common__pow2(32n)) == True{} : Bool}:
  F.nat__le_lt_trans(x, U32.to_nat(UMAX()), F.spec_common__pow2(32n), h, u32_lt(UMAX()))

# A sum below 2^32 does not wrap.
def add_lt32(+a: U32, +c: U32, +i: Nat, +ea: {U32.to_nat(a) == i : Nat},
    +h: {Nat.is_lt(Nat.add(U32.to_nat(c), i), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, c)) == Nat.add(U32.to_nat(c), i) : Nat}:
  +S = Nat.add(U32.to_nat(c), i)
  +eS = F.u32__to_nat_from_nat(S, 32n, {==}, h)
  +hS = F.logic__subst(Nat, z => {Nat.is_le(S, z) == True{} : Bool}, S, U32.to_nat(U32.from_nat(S)), Equal.sym(Nat, U32.to_nat(U32.from_nat(S)), S, eS), F.nat__le_refl(S))
  %Equal.sym(Nat, U32.to_nat(U32.add(a, c)), Nat.add(U32.to_nat(a), U32.to_nat(c)),
      A.add_le(a, c, U32.from_nat(S), F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(U32.from_nat(S))) == True{} : Bool}, S, Nat.add(U32.to_nat(a), U32.to_nat(c)),
        Equal.trans(Nat, S, Nat.add(i, U32.to_nat(c)), Nat.add(U32.to_nat(a), U32.to_nat(c)), F.nat__add_comm(U32.to_nat(c), i),
          Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(c)), i, U32.to_nat(a), Equal.sym(Nat, U32.to_nat(a), i, ea))), hS))) :
    {_ == S : Nat}
  %Equal.sym(Nat, U32.to_nat(a), i, ea) : {Nat.add(_, U32.to_nat(c)) == S : Nat}
  F.nat__add_comm(i, U32.to_nat(c))

# add_lt32 with the addend's value k given as a Nat (as add_nwk).
def add_lt32k(+a: U32, +c: U32, +k: Nat, +i: Nat, +ea: {U32.to_nat(a) == i : Nat}, +ek: {U32.to_nat(c) == k : Nat},
    +h: {Nat.is_lt(Nat.add(k, i), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, c)) == Nat.add(U32.to_nat(c), i) : Nat}:
  add_lt32(a, c, i, ea, F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, i), F.spec_common__pow2(32n)) == True{} : Bool}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ek), h))

# 31 + n < 2^32 for every n <= NMAX.
def nmax_lt(+n: U32, +hN: {U32.is_le(n, NMAX()) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(31n, U32.to_nat(n)), F.spec_common__pow2(32n)) == True{} : Bool}:
  umax_lt(Nat.add(31n, U32.to_nat(n)), le_nmax(n, hN))

# 2^(2 + d) <= 2^32 for d < 31.
def pw2d32(+d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}) -> {Nat.is_le(pw(2n+d), F.spec_common__pow2(32n)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(z, F.spec_common__pow2(32n)) == True{} : Bool}, F.spec_common__pow2(2n+d), pw(2n+d), {==},
    F.nat__pow2_mono(2n+d, 32n, F.nat__lt_succ_le(d, 30n, hd)))

# Anything within a U32 length is below 2^32.
def le_n_lt32(+x: Nat, +n: U32, +h: {Nat.is_le(x, U32.to_nat(n)) == True{} : Bool}) -> {Nat.is_lt(x, F.spec_common__pow2(32n)) == True{} : Bool}:
  F.nat__le_lt_trans(x, U32.to_nat(n), F.spec_common__pow2(32n), h, u32_lt(n))

def lt_u32n(+a: U32, +b: U32) -> {U32.is_lt(a, b) == Nat.is_lt(U32.to_nat(a), U32.to_nat(b)) : Bool}:
  %Equal.sym(Cmp, U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), F.u32__u32_cmp(a, b)) : {Cmp.is_lt(_) == Nat.is_lt(U32.to_nat(a), U32.to_nat(b)) : Bool}
  {==}

# A window within a tree of depth d < 30 ends below 2^32: 4 2^d <= 2^31 (no closed power is compared).
def hw32of(+d: Nat, +S: Nat, +hd: {Nat.is_lt(d, 30n) == True{} : Bool}, +h: {Nat.is_le(S, A.quad(pw(d))) == True{} : Bool})
    -> {Nat.is_lt(S, F.spec_common__pow2(32n)) == True{} : Bool}:
  F.nat__le_lt_trans(S, pw(2n+d), F.spec_common__pow2(32n), h,
    F.nat__lt_le_trans(pw(2n+d), F.spec_common__pow2(3n+d), F.spec_common__pow2(32n), F.nat__pow2_lt_succ(2n+d),
      F.nat__pow2_mono(3n+d, 32n, F.nat__lt_succ_le(d, 29n, hd))))

# A window within a tree of depth d < 28 ends by NMAX: 4 2^d <= 2^29 (no closed power is compared).
def hwNof(+d: Nat, +S: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +h: {Nat.is_le(S, A.quad(pw(d))) == True{} : Bool})
    -> {Nat.is_le(S, U32.to_nat(NMAX())) == True{} : Bool}:
  +h29 = F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(F.u32__pow2u(29n), NMAX()), Nat.is_le(U32.to_nat(F.u32__pow2u(29n)), U32.to_nat(NMAX())),
    le_u32n(F.u32__pow2u(29n), NMAX()), {==})
  +P29 = F.spec_common__pow2(29n)
  F.nat__le_trans(S, pw(2n+d), U32.to_nat(NMAX()), h,
    F.nat__le_trans(pw(2n+d), P29, U32.to_nat(NMAX()),
      F.logic__subst(Nat, z => {Nat.is_le(z, P29) == True{} : Bool}, F.spec_common__pow2(2n+d), pw(2n+d), {==}, F.nat__pow2_mono(2n+d, 29n, F.nat__lt_succ_le(d, 27n, hd))),
      F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(NMAX())) == True{} : Bool}, U32.to_nat(F.u32__pow2u(29n)), P29, F.u32__pow2u_value(29n, {==}), h29)))

# n <= m and m <= c as U32 comparisons give n <= c (a list limit m below NMAX bounds n by NMAX).
def u32le_trans(+n: U32, +m: U32, +c: U32, +h: {U32.is_le(n, m) == True{} : Bool}, +hm: {U32.is_le(m, c) == True{} : Bool})
    -> {U32.is_le(n, c) == True{} : Bool}:
  +h1 = F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(n, m), Nat.is_le(U32.to_nat(n), U32.to_nat(m)), le_u32n(n, m), h)
  +h2 = F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(m, c), Nat.is_le(U32.to_nat(m), U32.to_nat(c)), le_u32n(m, c), hm)
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(n), U32.to_nat(c)), U32.is_le(n, c), Equal.sym(Bool, U32.is_le(n, c), Nat.is_le(U32.to_nat(n), U32.to_nat(c)), le_u32n(n, c)),
    F.nat__le_trans(U32.to_nat(n), U32.to_nat(m), U32.to_nat(c), h1, h2))
