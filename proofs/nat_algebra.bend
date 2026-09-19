import Base
import ./packing.bend as P
import ./layout.bend as L
import ./nat_order.bend as O

law add_commute:
  for +a: Nat
  for +b: Nat
  {Nat.add(a, b) == Nat.add(b, a) : Nat}
def add_commute(a, b):
  match a:
    case 0n: Equal.sym(Nat, Nat.add(b, 0n), b, P.add_zero(b))
    case 1n+p:
      %Equal.sym(Nat, Nat.add(b, 1n+p), 1n+Nat.add(b, p), P.add_succ(b, p)) : {1n+Nat.add(p, b) == _ : Nat}
      Equal.cong(Nat, Nat, x => 1n+x, Nat.add(p, b), Nat.add(b, p), add_commute(p, b))

law add_swap:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  {Nat.add(a, Nat.add(b, c)) == Nat.add(b, Nat.add(a, c)) : Nat}
def add_swap(a, b, c):
  %L.add_associative(b, a, c) : {Nat.add(a, Nat.add(b, c)) == _ : Nat}
  %add_commute(a, b) : {Nat.add(a, Nat.add(b, c)) == Nat.add(_, c) : Nat}
  Equal.sym(Nat, Nat.add(Nat.add(a, b), c), Nat.add(a, Nat.add(b, c)), L.add_associative(a, b, c))

law add_monotone:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +d: Nat
  for ac: {Nat.is_le(a, c) == True{} : Bool}
  for bd: {Nat.is_le(b, d) == True{} : Bool}
  {Nat.is_le(Nat.add(a, b), Nat.add(c, d)) == True{} : Bool}
def add_monotone(a, b, c, d, ac, bd):
  O.transitive(Nat.add(a, b), Nat.add(c, b), Nat.add(c, d), O.add_right(a, c, b, ac), O.add_left(c, b, d, bd))

law mul_monotone:
  for +n: Nat
  for +a: Nat
  for +b: Nat
  for +ab: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.mul(n, a), Nat.mul(n, b)) == True{} : Bool}
def mul_monotone(n, a, b, ab):
  match n:
    case 0n: {==}
    case 1n+p: add_monotone(a, Nat.mul(p, a), b, Nat.mul(p, b), ab, mul_monotone(p, a, b, ab))

law mul_succ_right:
  for +n: Nat
  for +a: Nat
  {Nat.mul(n, 1n+a) == Nat.add(n, Nat.mul(n, a)) : Nat}
def mul_succ_right(n, a):
  match n:
    case 0n: {==}
    case 1n+p:
      %add_swap(a, p, Nat.mul(p, a)) : {1n+Nat.add(a, Nat.mul(p, 1n+a)) == 1n+_ : Nat}
      %mul_succ_right(p, a) : {1n+Nat.add(a, Nat.mul(p, 1n+a)) == 1n+Nat.add(a, _) : Nat}
      {==}

law mul_zero:
  for +n: Nat
  {Nat.mul(n, 0n) == 0n : Nat}
def mul_zero(n):
  match n:
    case 0n: {==}
    case 1n+p: mul_zero(p)

law mul_distribute:
  for +n: Nat
  for +a: Nat
  for +b: Nat
  {Nat.mul(n, Nat.add(a, b)) == Nat.add(Nat.mul(n, a), Nat.mul(n, b)) : Nat}
def mul_distribute(n, a, b):
  match n:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Nat, Nat.add(Nat.add(a, Nat.mul(p, a)), Nat.add(b, Nat.mul(p, b))), Nat.add(a, Nat.add(Nat.mul(p, a), Nat.add(b, Nat.mul(p, b)))), L.add_associative(a, Nat.mul(p, a), Nat.add(b, Nat.mul(p, b)))) : {Nat.add(Nat.add(a, b), Nat.mul(p, Nat.add(a, b))) == _ : Nat}
      %add_swap(b, Nat.mul(p, a), Nat.mul(p, b)) : {Nat.add(Nat.add(a, b), Nat.mul(p, Nat.add(a, b))) == Nat.add(a, _) : Nat}
      Equal.trans(Nat, Nat.add(Nat.add(a, b), Nat.mul(p, Nat.add(a, b))), Nat.add(Nat.add(a, b), Nat.add(Nat.mul(p, a), Nat.mul(p, b))), Nat.add(a, Nat.add(b, Nat.add(Nat.mul(p, a), Nat.mul(p, b)))),
        Equal.cong(Nat, Nat, r => Nat.add(Nat.add(a, b), r), Nat.mul(p, Nat.add(a, b)), Nat.add(Nat.mul(p, a), Nat.mul(p, b)), mul_distribute(p, a, b)),
        L.add_associative(a, b, Nat.add(Nat.mul(p, a), Nat.mul(p, b))))

law mul_strict:
  for +k: Nat
  for +a: Nat
  for +b: Nat
  for positive: {Nat.is_le(1n, k) == True{} : Bool}
  for step: {Nat.is_le(1n+a, b) == True{} : Bool}
  {Nat.is_le(1n+Nat.mul(k, a), Nat.mul(k, b)) == True{} : Bool}
def mul_strict(k, a, b, positive, step):
  O.transitive(1n+Nat.mul(k, a), Nat.mul(k, 1n+a), Nat.mul(k, b),
    %Equal.sym(Nat, Nat.mul(k, 1n+a), Nat.add(k, Nat.mul(k, a)), mul_succ_right(k, a)) : {Nat.is_le(1n+Nat.mul(k, a), _) == True{} : Bool}
    O.add_right(1n, k, Nat.mul(k, a), positive),
    mul_monotone(k, 1n+a, b, step))

law mul_coefficient:
  for +a: Nat
  for +b: Nat
  for +n: Nat
  for less: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.mul(a, n), Nat.mul(b, n)) == True{} : Bool}
def mul_coefficient(a, b, n, less):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: O.zero_le(Nat.mul(1n+q, n))
    case 1n+p 0n: Empty.absurd({Nat.is_le(Nat.mul(1n+p, n), 0n) == True{} : Bool}, O.le_lt_conflict(1n+p, 0n, less, {==}))
    case 1n+p 1n+q: O.add_left(n, Nat.mul(p, n), Nat.mul(q, n), mul_coefficient(p, q, n, less))

law mul_add_left:
  for +a: Nat
  for +b: Nat
  for +n: Nat
  {Nat.mul(Nat.add(a, b), n) == Nat.add(Nat.mul(a, n), Nat.mul(b, n)) : Nat}
def mul_add_left(a, b, n):
  match a:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Nat, Nat.add(Nat.add(n, Nat.mul(p, n)), Nat.mul(b, n)), Nat.add(n, Nat.add(Nat.mul(p, n), Nat.mul(b, n))), L.add_associative(n, Nat.mul(p, n), Nat.mul(b, n))) : {Nat.add(n, Nat.mul(Nat.add(p, b), n)) == _ : Nat}
      Equal.cong(Nat, Nat, r => Nat.add(n, r), Nat.mul(Nat.add(p, b), n), Nat.add(Nat.mul(p, n), Nat.mul(b, n)), mul_add_left(p, b, n))

law subtract_zero:
  for +n: Nat
  {Nat.sub(n, 0n) == n : Nat}
def subtract_zero(n):
  match n:
    case 0n: {==}
    case 1n+p: {==}

law subtract_prefix:
  for +a: Nat
  for +b: Nat
  {Nat.sub(Nat.add(a, b), a) == b : Nat}
def subtract_prefix(a, b):
  match a:
    case 0n: subtract_zero(b)
    case 1n+p: subtract_prefix(p, b)
