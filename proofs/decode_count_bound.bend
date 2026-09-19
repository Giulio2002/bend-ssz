import Base
import ../src/decode.bend as I
import ../src/layout.bend as Layout
import ../src/lists.bend as Lists
import ./lists.bend as L
import ./nat_order.bend as Order
import ./packing.bend as Pack
import ./primitive_invariants.bend as V

# A division traversal increments its quotient at most once per consumed
# natural successor. This is independent of any native integer width.
law quotient_upper:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  {Nat.is_le(Nat.div.fin(Nat.divmod.go(n, m, d, r)), Nat.add(n, d)) == True{} : Bool}
def quotient_upper(n, m, d, r):
  match n:
    case 0n: Order.reflexive(d)
    case 1n+p:
      match m:
        case 0n:
          %Pack.add_succ(p, d) : {Nat.is_le(Nat.div.fin(Nat.divmod.go(p, r, 1n+d, 0n)), _) == True{} : Bool}
          quotient_upper(p, r, 1n+d, 0n)
        case 1n+q: Order.step_right(Nat.div.fin(Nat.divmod.go(p, q, d, 1n+r)), Nat.add(p, d), quotient_upper(p, q, d, 1n+r))

law division_upper:
  for +n: Nat
  for +d: Nat
  {Nat.is_le(Nat.div(n, 1n+d), n) == True{} : Bool}
def division_upper(n, d):
  %Pack.add_zero(n) : {Nat.is_le(Nat.div(n, 1n+d), _) == True{} : Bool}
  quotient_upper(n, d, 0n, 0n)

def bound(maximum: Nat, result: Maybe<&2, Nat>) -> Type:
  match result:
    case None{}: Unit
    case Some{n}: {Nat.is_le(n, maximum) == True{} : Bool}

law gate_bound:
  for +ok: Bool
  for +n: Nat
  for +maximum: Nat
  for valid: {ok == True{} : Bool} -> {Nat.is_le(n, maximum) == True{} : Bool}
  bound(maximum, I.nat_gate(ok, n))
def gate_bound(ok, n, maximum, valid):
  match ok:
    case False{}: Unit{}
    case True{}: valid({==})

law variable_count_bound:
  for +first: Nat
  for +length: Nat
  bound(length, I.variable_count(first, length))
def variable_count_bound(first, length):
  gate_bound(Bool.and(Nat.is_lt(0n, first), Bool.and(Nat.is_eq(Nat.mod(first, 4n), 0n), Nat.is_le(first, length))), Nat.div(first, 4n), length, valid => Order.transitive(Nat.div(first, 4n), first, length, division_upper(first, 3n), V.and_right(Nat.is_eq(Nat.mod(first, 4n), 0n), Nat.is_le(first, length), V.and_right(Nat.is_lt(0n, first), Bool.and(Nat.is_eq(Nat.mod(first, 4n), 0n), Nat.is_le(first, length)), valid))))

law four_length:
  for +a: U32
  for +b: U32
  for +c: U32
  for +d: U32
  for +tail: +List<U32>
  {Lists.length(U32, a <> b <> c <> d <> tail) == 4n+Lists.length(U32, tail) : Nat}
def four_length(a, b, c, d, tail):
  %Equal.sym(Nat, Lists.length(U32, tail), List.length(&2, U32, tail), L.length_correct(U32, tail)) : {Lists.length(U32, a <> b <> c <> d <> tail) == 4n+_ : Nat}
  L.length_correct(U32, a <> b <> c <> d <> tail)

# Every successful sequence item count is bounded by the actual input length,
# including variable members with empty serialized payloads (four-byte table).
law item_count_bound:
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  bound(Lists.length(U32, xs), I.item_count(width, xs))
def item_count_bound(width, xs):
  match width:
    case Some{n}:
      match n:
        case 0n: Unit{}
        case 1n+p: gate_bound(Nat.is_eq(Nat.mod(Lists.length(U32, xs), 1n+p), 0n), Nat.div(Lists.length(U32, xs), 1n+p), Lists.length(U32, xs), valid => division_upper(Lists.length(U32, xs), p))
    case None{}:
      match xs:
        case Nil{}: {==}
        case Con{a, Nil{}}: Unit{}
        case Con{a, Con{b, Nil{}}}: Unit{}
        case Con{a, Con{b, Con{c, Nil{}}}}: Unit{}
        case Con{a, Con{b, Con{c, Con{d, tail}}}}:
          %Equal.sym(Nat, Lists.length(U32, a <> b <> c <> d <> tail), 4n+Lists.length(U32, tail), four_length(a, b, c, d, tail)) : bound(_, I.variable_count(Layout.offset([a, b, c, d]), 4n+Lists.length(U32, tail)))
          variable_count_bound(Layout.offset([a, b, c, d]), 4n+Lists.length(U32, tail))
