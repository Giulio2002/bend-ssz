import Base
import ./word_facts.bend as W
import ./packing.bend as Pack

# tree.bend's double_add, here so that this module does not import tree.bend (and
# through it the SHA-256 conformance proofs: decode_image imports this module).
law double_add:
  for +n: Nat
  {Nat.double(n) == Nat.add(n, n) : Nat}
def double_add(n):
  match n:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Nat, Nat.add(p, 1n+p), 1n+Nat.add(p, p), Pack.add_succ(p, p)) : {Nat.double(1n+p) == 1n+_ : Nat}
      %double_add(p) : {2n+Nat.double(p) == 2n+_ : Nat}
      {==}

law zero_le:
  for n: Nat
  {Nat.is_le(0n, n) == True{} : Bool}
def zero_le(n):
  match n:
    case 0n: {==}
    case 1n+p: {==}

law reflexive:
  for +n: Nat
  {Nat.is_le(n, n) == True{} : Bool}
def reflexive(n):
  match n:
    case 0n: {==}
    case 1n+p: reflexive(p)

law step_right:
  for +a: Nat
  for +b: Nat
  for e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(a, 1n+b) == True{} : Bool}
def step_right(a, b, e):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+p: {==}
    case 1n+p 0n: Empty.absurd({Nat.is_le(1n+p, 1n) == True{} : Bool}, W.false_true(e))
    case 1n+p 1n+q: step_right(p, q, e)

law transitive:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for ab: {Nat.is_le(a, b) == True{} : Bool}
  for bc: {Nat.is_le(b, c) == True{} : Bool}
  {Nat.is_le(a, c) == True{} : Bool}
def transitive(a, b, c, ab, bc):
  match a b c:
    case 0n 0n 0n: {==}
    case 0n 0n 1n+r: {==}
    case 0n 1n+q 0n: {==}
    case 0n 1n+q 1n+r: {==}
    case 1n+p 0n 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, W.false_true(ab))
    case 1n+p 0n 1n+r: Empty.absurd({Nat.is_le(1n+p, 1n+r) == True{} : Bool}, W.false_true(ab))
    case 1n+p 1n+q 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, W.false_true(bc))
    case 1n+p 1n+q 1n+r: transitive(p, q, r, ab, bc)

law add_left:
  for +n: Nat
  for +a: Nat
  for +b: Nat
  for e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.add(n, a), Nat.add(n, b)) == True{} : Bool}
def add_left(n, a, b, e):
  match n:
    case 0n: e
    case 1n+p: add_left(p, a, b, e)

law below_sum:
  for +a: Nat
  for +b: Nat
  {Nat.is_le(a, Nat.add(a, b)) == True{} : Bool}
def below_sum(a, b):
  match a:
    case 0n: zero_le(b)
    case 1n+p: below_sum(p, b)

law left_below_sum:
  for +n: Nat
  for +a: Nat
  {Nat.is_le(a, Nat.add(n, a)) == True{} : Bool}
def left_below_sum(n, a):
  match n:
    case 0n: reflexive(a)
    case 1n+p: step_right(a, Nat.add(p, a), left_below_sum(p, a))

law add_right:
  for +a: Nat
  for +b: Nat
  for +n: Nat
  for e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.add(a, n), Nat.add(b, n)) == True{} : Bool}
def add_right(a, b, n, e):
  match a b:
    case 0n 0n: reflexive(n)
    case 0n 1n+q: left_below_sum(1n+q, n)
    case 1n+p 0n: Empty.absurd({Nat.is_le(Nat.add(1n+p, n), n) == True{} : Bool}, W.false_true(e))
    case 1n+p 1n+q: add_right(p, q, n, e)

law not_le_lt:
  for +a: Nat
  for +b: Nat
  for e: {Nat.is_le(a, b) == False{} : Bool}
  {Nat.is_lt(b, a) == True{} : Bool}
def not_le_lt(a, b, e):
  match a b:
    case 0n 0n: Empty.absurd({False{} == True{} : Bool}, W.false_true(Equal.sym(Bool, True{}, False{}, e)))
    case 0n 1n+q: Empty.absurd({False{} == True{} : Bool}, W.false_true(Equal.sym(Bool, True{}, False{}, e)))
    case 1n+p 0n: {==}
    case 1n+p 1n+q: not_le_lt(p, q, e)

law double_grows:
  for +n: Nat
  for e: {Nat.is_le(1n, n) == True{} : Bool}
  {Nat.is_le(1n+n, Nat.double(n)) == True{} : Bool}
def double_grows(n, e):
  match n:
    case 0n: Empty.absurd({False{} == True{} : Bool}, W.false_true(e))
    case 1n+p:
      %Equal.sym(Nat, Nat.double(p), Nat.add(p, p), double_add(p)) : {Nat.is_le(p, _) == True{} : Bool}
      below_sum(p, p)

law advance_budget:
  for +limit: Nat
  for +cap: Nat
  for +fuel: Nat
  for positive: {Nat.is_le(1n, cap) == True{} : Bool}
  for budget: {Nat.is_le(limit, Nat.add(cap, 1n+fuel)) == True{} : Bool}
  {Nat.is_le(limit, Nat.add(Nat.double(cap), fuel)) == True{} : Bool}
law budget_rewrite:
  for +limit: Nat
  for +cap: Nat
  for +fuel: Nat
  for e: {Nat.is_le(limit, Nat.add(cap, 1n+fuel)) == True{} : Bool}
  {Nat.is_le(limit, Nat.add(1n+cap, fuel)) == True{} : Bool}
def budget_rewrite(limit, cap, fuel, e):
  %Pack.add_succ(cap, fuel) : {Nat.is_le(limit, _) == True{} : Bool}
  e

def advance_budget(limit, cap, fuel, positive, budget):
  transitive(limit, Nat.add(1n+cap, fuel), Nat.add(Nat.double(cap), fuel),
    budget_rewrite(limit, cap, fuel, budget),
    add_right(1n+cap, Nat.double(cap), fuel, double_grows(cap, positive)))

law double_monotone:
  for +a: Nat
  for +b: Nat
  for e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.double(a), Nat.double(b)) == True{} : Bool}
def double_monotone(a, b, e):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: Empty.absurd({False{} == True{} : Bool}, W.false_true(e))
    case 1n+p 1n+q: double_monotone(p, q, e)

law lt_zero:
  for +a: Nat
  for e: {Nat.is_lt(a, 0n) == True{} : Bool}
  Empty
def lt_zero(a, e):
  match a:
    case 0n: W.false_true(e)
    case 1n+p: W.false_true(e)

law lt_succ_le:
  for +a: Nat
  for +b: Nat
  for e: {Nat.is_lt(a, 1n+b) == True{} : Bool}
  {Nat.is_le(a, b) == True{} : Bool}
def lt_succ_le(a, b, e):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n:
      Empty.absurd({False{} == True{} : Bool}, lt_zero(p, e))
    case 1n+p 1n+q: lt_succ_le(p, q, e)

law le_lt_conflict:
  for +a: Nat
  for +b: Nat
  for ab: {Nat.is_le(a, b) == True{} : Bool}
  for ba: {Nat.is_lt(b, a) == True{} : Bool}
  Empty
def le_lt_conflict(a, b, ab, ba):
  match a b:
    case 0n 0n: W.false_true(ba)
    case 0n 1n+q: W.false_true(ba)
    case 1n+p 0n: W.false_true(ab)
    case 1n+p 1n+q: le_lt_conflict(p, q, ab, ba)

law equal_if_neither_less:
  for +a: Nat
  for +b: Nat
  for ab: {Nat.is_lt(a, b) == True{} : Bool} -> Empty
  for ba: {Nat.is_lt(b, a) == True{} : Bool} -> Empty
  {a == b : Nat}
def equal_if_neither_less(a, b, ab, ba):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: Empty.absurd({0n == 1n+q : Nat}, ab({==}))
    case 1n+p 0n: Empty.absurd({1n+p == 0n : Nat}, ba({==}))
    case 1n+p 1n+q:
      Equal.cong(Nat, Nat, n => 1n+n, p, q, equal_if_neither_less(p, q, ab, ba))
