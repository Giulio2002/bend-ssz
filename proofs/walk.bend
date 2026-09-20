import Base
import ../src/walk.bend as I
import ./word_facts.bend as W
import ./u32_order.bend as Order
import ./packing.bend as Pack
import ./bytes.bend as B

# The allocation-free byte walks of src/walk.bend are exactly List.drop and
# List.take: U32 step counters are related to Nat counts through Word.inc.

def cmp_is_lt(c: Cmp) -> Bool: Cmp.is_lt(c)

law lt_of_is_lt:
  for +c: Cmp
  for e: {Cmp.is_lt(c) == True{} : Bool}
  {c == LT{} : Cmp}
def lt_of_is_lt(c, e):
  match c:
    case LT{}: {==}
    case EQ{}: Empty.absurd({EQ{} == LT{} : Cmp}, W.false_true(e))
    case GT{}: Empty.absurd({GT{} == LT{} : Cmp}, W.false_true(e))

law fin_true_lt:
  for +c: Cmp
  for +bb: Bool
  for e: {Word.cmp.fin(True{}, bb, c) == LT{} : Cmp}
  {c == LT{} : Cmp}
def fin_true_lt(c, bb, e):
  match c:
    case LT{}: {==}
    case EQ{}:
      match bb:
        case False{}: Empty.absurd({EQ{} == LT{} : Cmp}, W.false_true(Equal.cong(Cmp, Bool, cmp_is_lt, GT{}, LT{}, e)))
        case True{}: Empty.absurd({EQ{} == LT{} : Cmp}, W.false_true(Equal.cong(Cmp, Bool, cmp_is_lt, EQ{}, LT{}, e)))
    case GT{}: Empty.absurd({GT{} == LT{} : Cmp}, W.false_true(Equal.cong(Cmp, Bool, cmp_is_lt, GT{}, LT{}, e)))

# A word strictly below another word is not all ones: increment adds one.
law inc_value:
  for +n: Nat
  for +a: Word(n)
  for +b: Word(n)
  for e: {Word.cmp(n, a, b) == LT{} : Cmp}
  {Word.to_nat(n, Word.inc(n, a)) == 1n+Word.to_nat(n, a) : Nat}
def inc_value(n, a, b, e):
  match n:
    case 0n: Empty.absurd({Word.to_nat(0n, Word.inc(0n, a)) == 1n+Word.to_nat(0n, a) : Nat}, W.false_true(Equal.cong(Cmp, Bool, cmp_is_lt, EQ{}, LT{}, e)))
    case 1n+p:
      match a b:
        case WCon{False{}, at} WCon{bb, bt}: {==}
        case WCon{True{}, at} WCon{bb, bt}:
          Equal.cong(Nat, Nat, x => Nat.double(x), Word.to_nat(p, Word.inc(p, at)), 1n+Word.to_nat(p, at), inc_value(p, at, bt, fin_true_lt(Word.cmp(p, at, bt), bb, e)))

law u32_inc_value:
  for +a: U32
  for +b: U32
  for e: {U32.is_lt(a, b) == True{} : Bool}
  {U32.to_nat(U32.inc(a)) == 1n+U32.to_nat(a) : Nat}
def u32_inc_value(a, b, e):
  match a b:
    case U32{x} U32{y}: inc_value(32n, x, y, lt_of_is_lt(Word.cmp(32n, x, y), e))

law nat_less_u32:
  for +a: U32
  for +b: U32
  for e: {Nat.is_lt(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}
  {U32.is_lt(a, b) == True{} : Bool}
def nat_less_u32(a, b, e):
  Equal.trans(Bool, U32.is_lt(a, b), Nat.is_lt(U32.to_nat(a), U32.to_nat(b)), True{}, Order.u32_less(a, b), e)

law u32_equal:
  for +a: U32
  for +b: U32
  {U32.is_eq(a, b) == Nat.is_eq(U32.to_nat(a), U32.to_nat(b)) : Bool}
def u32_equal(a, b):
  Equal.cong(Cmp, Bool, c => Cmp.is_eq(c), U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), Order.u32_compare(a, b))

law below_sum:
  for +a: Nat
  for +c: Nat
  {Nat.is_lt(a, Nat.add(a, 1n+c)) == True{} : Bool}
def below_sum(a, c):
  match a:
    case 0n: {==}
    case 1n+p: below_sum(p, c)

law equal_shift:
  for +x: Nat
  for +c: Nat
  {Nat.is_eq(x, Nat.add(x, c)) == Nat.is_eq(c, 0n) : Bool}
def equal_shift(x, c):
  match x:
    case 0n:
      match c:
        case 0n: {==}
        case 1n+q: {==}
    case 1n+p: equal_shift(p, c)

# The counter after one step: position a+1, still c steps from n.
law step_count:
  for +i: U32
  for +n: U32
  for +c: Nat
  for +e: {Nat.add(U32.to_nat(i), 1n+c) == U32.to_nat(n) : Nat}
  {Nat.add(U32.to_nat(U32.inc(i)), c) == U32.to_nat(n) : Nat}
def step_count(i, n, c, e):
  %Equal.sym(Nat, U32.to_nat(U32.inc(i)), 1n+U32.to_nat(i), u32_inc_value(i, n, nat_less_u32(i, n, Equal.trans(Bool, Nat.is_lt(U32.to_nat(i), U32.to_nat(n)), Nat.is_lt(U32.to_nat(i), Nat.add(U32.to_nat(i), 1n+c)), True{}, Equal.cong(Nat, Bool, m => Nat.is_lt(U32.to_nat(i), m), U32.to_nat(n), Nat.add(U32.to_nat(i), 1n+c), Equal.sym(Nat, Nat.add(U32.to_nat(i), 1n+c), U32.to_nat(n), e)), below_sum(U32.to_nat(i), c))))) : {Nat.add(_, c) == U32.to_nat(n) : Nat}
  Equal.trans(Nat, 1n+Nat.add(U32.to_nat(i), c), Nat.add(U32.to_nat(i), 1n+c), U32.to_nat(n), Equal.sym(Nat, Nat.add(U32.to_nat(i), 1n+c), 1n+Nat.add(U32.to_nat(i), c), Pack.add_succ(U32.to_nat(i), c)), e)

law step_stop:
  for +i: U32
  for +n: U32
  for +c: Nat
  for e: {Nat.add(U32.to_nat(U32.inc(i)), c) == U32.to_nat(n) : Nat}
  {U32.is_eq(U32.inc(i), n) == Nat.is_eq(c, 0n) : Bool}
def step_stop(i, n, c, e):
  Equal.trans(Bool, U32.is_eq(U32.inc(i), n), Nat.is_eq(U32.to_nat(U32.inc(i)), U32.to_nat(n)), Nat.is_eq(c, 0n), u32_equal(U32.inc(i), n),
    %e : {Nat.is_eq(U32.to_nat(U32.inc(i)), _) == Nat.is_eq(c, 0n) : Bool}
    equal_shift(U32.to_nat(U32.inc(i)), c))

# ---------------------------------------------------------------------------
# List facts about Base take/drop.
law take_drop:
  for +xs: +List<U32>
  for +c: Nat
  {List.append(&2, U32, List.take(&2, U32, xs, c), List.drop(&2, U32, xs, c)) == xs : +List<U32>}
def take_drop(xs, c):
  match xs c:
    case Nil{} _: {==}
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: Equal.cong(+List<U32>, +List<U32>, ys => h <> ys, List.append(&2, U32, List.take(&2, U32, t, p), List.drop(&2, U32, t, p)), t, take_drop(t, p))

law drop_drop:
  for +xs: +List<U32>
  for +a: Nat
  for +b: Nat
  {List.drop(&2, U32, List.drop(&2, U32, xs, a), b) == List.drop(&2, U32, xs, Nat.add(a, b)) : +List<U32>}
def drop_drop(xs, a, b):
  match xs a:
    case Nil{} 0n: {==}
    case Nil{} 1n+p:
      match b:
        case 0n: {==}
        case 1n+q: {==}
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: drop_drop(t, p, b)

law take_add:
  for +xs: +List<U32>
  for +a: Nat
  for +b: Nat
  {List.take(&2, U32, xs, Nat.add(a, b)) == List.append(&2, U32, List.take(&2, U32, xs, a), List.take(&2, U32, List.drop(&2, U32, xs, a), b)) : +List<U32>}
def take_add(xs, a, b):
  match xs a:
    case Nil{} 0n: {==}
    case Nil{} 1n+p:
      match b:
        case 0n: {==}
        case 1n+q: {==}
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: Equal.cong(+List<U32>, +List<U32>, ys => h <> ys, List.take(&2, U32, t, Nat.add(p, b)), List.append(&2, U32, List.take(&2, U32, t, p), List.take(&2, U32, List.drop(&2, U32, t, p), b)), take_add(t, p, b))

law length_take_drop:
  for +xs: +List<U32>
  for +c: Nat
  {Nat.add(List.length(&2, U32, List.take(&2, U32, xs, c)), List.length(&2, U32, List.drop(&2, U32, xs, c))) == List.length(&2, U32, xs) : Nat}
def length_take_drop(xs, c):
  match xs c:
    case Nil{} _: {==}
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: Equal.cong(Nat, Nat, n => 1n+n, Nat.add(List.length(&2, U32, List.take(&2, U32, t, p)), List.length(&2, U32, List.drop(&2, U32, t, p))), List.length(&2, U32, t), length_take_drop(t, p))

law take_prefix:
  for +p: +List<U32>
  for +r: +List<U32>
  {List.take(&2, U32, List.append(&2, U32, p, r), List.length(&2, U32, p)) == p : +List<U32>}
def take_prefix(p, r):
  match p:
    case Nil{}:
      match r:
        case Nil{}: {==}
        case Con{h, t}: {==}
    case Con{h, t}: Equal.cong(+List<U32>, +List<U32>, ys => h <> ys, List.take(&2, U32, List.append(&2, U32, t, r), List.length(&2, U32, t)), t, take_prefix(t, r))

law drop_prefix:
  for +p: +List<U32>
  for +r: +List<U32>
  {List.drop(&2, U32, List.append(&2, U32, p, r), List.length(&2, U32, p)) == r : +List<U32>}
def drop_prefix(p, r):
  match p:
    case Nil{}:
      match r:
        case Nil{}: {==}
        case Con{h, t}: {==}
    case Con{h, t}: drop_prefix(t, r)

law lt_step:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_lt(a, b) == True{} : Bool}
  {Nat.is_lt(a, 1n+b) == True{} : Bool}
def lt_step(a, b, e):
  match a b:
    case 0n _: {==}
    case 1n+p 0n: Empty.absurd({Nat.is_lt(1n+p, 1n) == True{} : Bool}, W.false_true(e))
    case 1n+p 1n+q: lt_step(p, q, e)

law lt_succ:
  for +a: Nat
  {Nat.is_lt(a, 1n+a) == True{} : Bool}
def lt_succ(a):
  match a:
    case 0n: {==}
    case 1n+p: lt_succ(p)

law drop_shorter:
  for +t: +List<U32>
  for +c: Nat
  for +h: U32
  {Nat.is_lt(List.length(&2, U32, List.drop(&2, U32, h <> t, 1n+c)), List.length(&2, U32, h <> t)) == True{} : Bool}
def drop_shorter(t, c, h):
  match t c:
    case Nil{} _: {==}
    case Con{x, u} 0n: lt_succ(List.length(&2, U32, u))
    case Con{x, u} 1n+p: lt_step(List.length(&2, U32, List.drop(&2, U32, x <> u, 1n+p)), List.length(&2, U32, x <> u), drop_shorter(u, p, x))

