import Base
import ./word_facts.bend as W
import ./packing.bend as Pack
import ./layout.bend as Layout
import ./nat_algebra.bend as A
import ./exact_division.bend as X
import ./nat_order.bend as O

# Base division by any positive divisor 1+w: quotient and remainder of
# q*(1+w) + r (r <= w) are exactly q and r, and every n has that form.

law go_small:
  for +r: Nat
  for +m: Nat
  for +d: Nat
  for +s: Nat
  for +le: {Nat.is_le(r, m) == True{} : Bool}
  {Nat.divmod.go(r, m, d, s) == (d, Nat.add(r, s)) : Nat & Nat}
def go_small(r, m, d, s, le):
  match r m:
    case 0n _: {==}
    case 1n+rp 0n: Empty.absurd({Nat.divmod.go(1n+rp, 0n, d, s) == (d, Nat.add(1n+rp, s)) : Nat & Nat}, W.false_true(le))
    case 1n+rp 1n+mp:
      Equal.trans(Nat & Nat, Nat.divmod.go(rp, mp, d, 1n+s), (d, Nat.add(rp, 1n+s)), (d, 1n+Nat.add(rp, s)), go_small(rp, mp, d, 1n+s, le), Equal.cong(Nat, Nat & Nat, x => (d, x), Nat.add(rp, 1n+s), 1n+Nat.add(rp, s), Pack.add_succ(rp, s)))

law go_blocks:
  for +q: Nat
  for +r: Nat
  for +w: Nat
  for +d: Nat
  for +le: {Nat.is_le(r, w) == True{} : Bool}
  {Nat.divmod.go(Nat.add(Nat.mul(q, 1n+w), r), w, d, 0n) == (Nat.add(q, d), r) : Nat & Nat}
def go_blocks(q, r, w, d, le):
  match q:
    case 0n: Equal.trans(Nat & Nat, Nat.divmod.go(r, w, d, 0n), (d, Nat.add(r, 0n)), (d, r), go_small(r, w, d, 0n, le), Equal.cong(Nat, Nat & Nat, x => (d, x), Nat.add(r, 0n), r, Pack.add_zero(r)))
    case 1n+qp:
      %Equal.sym(Nat, Nat.add(Nat.add(1n+w, Nat.mul(qp, 1n+w)), r), Nat.add(1n+w, Nat.add(Nat.mul(qp, 1n+w), r)), Layout.add_associative(1n+w, Nat.mul(qp, 1n+w), r)) : {Nat.divmod.go(_, w, d, 0n) == (1n+Nat.add(qp, d), r) : Nat & Nat}
      Equal.trans(Nat & Nat, Nat.divmod.go(Nat.add(1n+w, Nat.add(Nat.mul(qp, 1n+w), r)), w, d, 0n), Nat.divmod.go(Nat.add(Nat.mul(qp, 1n+w), r), w, 1n+d, 0n), (1n+Nat.add(qp, d), r),
        X.block(w, Nat.add(Nat.mul(qp, 1n+w), r), d, 0n),
        Equal.trans(Nat & Nat, Nat.divmod.go(Nat.add(Nat.mul(qp, 1n+w), r), w, 1n+d, 0n), (Nat.add(qp, 1n+d), r), (1n+Nat.add(qp, d), r), go_blocks(qp, r, w, 1n+d, le), Equal.cong(Nat, Nat & Nat, x => (x, r), Nat.add(qp, 1n+d), 1n+Nat.add(qp, d), Pack.add_succ(qp, d))))

law div_exact:
  for +q: Nat
  for +r: Nat
  for +w: Nat
  for +le: {Nat.is_le(r, w) == True{} : Bool}
  {Nat.div(Nat.add(Nat.mul(q, 1n+w), r), 1n+w) == q : Nat}
def div_exact(q, r, w, le):
  Equal.trans(Nat, Nat.div(Nat.add(Nat.mul(q, 1n+w), r), 1n+w), Nat.add(q, 0n), q, Equal.cong(Nat & Nat, Nat, x => Pair.fst(Nat, Nat, x), Nat.divmod.go(Nat.add(Nat.mul(q, 1n+w), r), w, 0n, 0n), (Nat.add(q, 0n), r), go_blocks(q, r, w, 0n, le)), Pack.add_zero(q))

law mod_exact:
  for +q: Nat
  for +r: Nat
  for +w: Nat
  for +le: {Nat.is_le(r, w) == True{} : Bool}
  {Nat.mod(Nat.add(Nat.mul(q, 1n+w), r), 1n+w) == r : Nat}
def mod_exact(q, r, w, le):
  Equal.cong(Nat & Nat, Nat, x => Pair.snd(Nat, Nat, x), Nat.divmod.go(Nat.add(Nat.mul(q, 1n+w), r), w, 0n, 0n), (Nat.add(q, 0n), r), go_blocks(q, r, w, 0n, le))

# Every n is q*(1+w) + r with r <= w.
def split_type(n: Nat, w: Nat) -> Type:
  Exists(Nat, q => Exists(Nat, r => {Nat.is_le(r, w) == True{} : Bool} & {Nat.add(Nat.mul(q, 1n+w), r) == n : Nat}))

law le_of_lt:
  for +r: Nat
  for +w: Nat
  for +lt: {Nat.is_lt(r, w) == True{} : Bool}
  {Nat.is_le(1n+r, w) == True{} : Bool}
def le_of_lt(r, w, lt):
  match r w:
    case 0n 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, W.false_true(lt))
    case 0n 1n+wp: O.zero_le(wp)
    case 1n+rp 0n: Empty.absurd({Nat.is_le(2n+rp, 0n) == True{} : Bool}, W.false_true(lt))
    case 1n+rp 1n+wp: le_of_lt(rp, wp, lt)

law le_not_lt_equal:
  for +r: Nat
  for +w: Nat
  for +le: {Nat.is_le(r, w) == True{} : Bool}
  for +nlt: {Nat.is_lt(r, w) == False{} : Bool}
  {r == w : Nat}
def le_not_lt_equal(r, w, le, nlt):
  match r w:
    case 0n 0n: {==}
    case 0n 1n+wp: Empty.absurd({0n == 1n+wp : Nat}, W.false_true(Equal.sym(Bool, True{}, False{}, nlt)))
    case 1n+rp 0n: Empty.absurd({1n+rp == 0n : Nat}, W.false_true(le))
    case 1n+rp 1n+wp: Equal.cong(Nat, Nat, x => 1n+x, rp, wp, le_not_lt_equal(rp, wp, le, nlt))

law split_step:
  for +b: Bool
  for +q: Nat
  for +r: Nat
  for +w: Nat
  for +n: Nat
  for +lt: {Nat.is_lt(r, w) == b : Bool}
  for +le: {Nat.is_le(r, w) == True{} : Bool}
  for +eq: {Nat.add(Nat.mul(q, 1n+w), r) == n : Nat}
  split_type(1n+n, w)
def split_step(b, q, r, w, n, lt, le, eq):
  match b:
    case True{}:
      (q, (1n+r, (le_of_lt(r, w, lt), Equal.trans(Nat, Nat.add(Nat.mul(q, 1n+w), 1n+r), 1n+Nat.add(Nat.mul(q, 1n+w), r), 1n+n, Pack.add_succ(Nat.mul(q, 1n+w), r), Equal.cong(Nat, Nat, x => 1n+x, Nat.add(Nat.mul(q, 1n+w), r), n, eq)))))
    case False{}:
      same = Equal.trans(Nat, Nat.add(Nat.mul(q, 1n+w), w), Nat.add(Nat.mul(q, 1n+w), r), n, Equal.cong(Nat, Nat, x => Nat.add(Nat.mul(q, 1n+w), x), w, r, Equal.sym(Nat, r, w, le_not_lt_equal(r, w, le, lt))), eq)
      (1n+q, (0n, (O.zero_le(w), Equal.trans(Nat, Nat.add(Nat.mul(1n+q, 1n+w), 0n), Nat.mul(1n+q, 1n+w), 1n+n, Pack.add_zero(Nat.mul(1n+q, 1n+w)), Equal.trans(Nat, 1n+Nat.add(w, Nat.mul(q, 1n+w)), 1n+Nat.add(Nat.mul(q, 1n+w), w), 1n+n, Equal.cong(Nat, Nat, x => 1n+x, Nat.add(w, Nat.mul(q, 1n+w)), Nat.add(Nat.mul(q, 1n+w), w), A.add_commute(w, Nat.mul(q, 1n+w))), Equal.cong(Nat, Nat, x => 1n+x, Nat.add(Nat.mul(q, 1n+w), w), n, same))))))
