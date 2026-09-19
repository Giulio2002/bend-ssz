import Base
import ./word_split.bend as W
import ./packing.bend as P

# Mathematical value of little-endian concatenated bit words. No native-width
# arithmetic or bounded fixtures stand in for these all-word equalities.
def power(n: Nat) -> Nat:
  match n:
    case 0n: 1n
    case 1n+p: Nat.double(power(p))

law times_one:
  for +n: Nat
  {Nat.mul(n, 1n) == n : Nat}
def times_one(n):
  match n:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat, Nat, x => 1n+x, Nat.mul(p, 1n), p, times_one(p))

law double_sum:
  for +a: Nat
  for +b: Nat
  {Nat.double(Nat.add(a, b)) == Nat.add(Nat.double(a), Nat.double(b)) : Nat}
def double_sum(a, b):
  match a:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat, Nat, x => 2n+x, Nat.double(Nat.add(p, b)), Nat.add(Nat.double(p), Nat.double(b)), double_sum(p, b))

law double_product:
  for +a: Nat
  for +b: Nat
  {Nat.double(Nat.mul(a, b)) == Nat.mul(a, Nat.double(b)) : Nat}
def double_product(a, b):
  match a:
    case 0n: {==}
    case 1n+p:
      Equal.trans(Nat, Nat.double(Nat.add(b, Nat.mul(p, b))), Nat.add(Nat.double(b), Nat.double(Nat.mul(p, b))), Nat.add(Nat.double(b), Nat.mul(p, Nat.double(b))), double_sum(b, Nat.mul(p, b)), Equal.cong(Nat, Nat, x => Nat.add(Nat.double(b), x), Nat.double(Nat.mul(p, b)), Nat.mul(p, Nat.double(b)), double_product(p, b)))

law double_recompose:
  for +value: Nat
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for decomposition: {value == Nat.add(a, Nat.mul(b, c)) : Nat}
  {Nat.double(value) == Nat.add(Nat.double(a), Nat.mul(b, Nat.double(c))) : Nat}
def double_recompose(value, a, b, c, decomposition):
  Equal.trans(Nat, Nat.double(value), Nat.double(Nat.add(a, Nat.mul(b, c))), Nat.add(Nat.double(a), Nat.mul(b, Nat.double(c))), Equal.cong(Nat, Nat, Nat.double, value, Nat.add(a, Nat.mul(b, c)), decomposition), Equal.trans(Nat, Nat.double(Nat.add(a, Nat.mul(b, c))), Nat.add(Nat.double(a), Nat.double(Nat.mul(b, c))), Nat.add(Nat.double(a), Nat.mul(b, Nat.double(c))), double_sum(a, Nat.mul(b, c)), Equal.cong(Nat, Nat, x => Nat.add(Nat.double(a), x), Nat.double(Nat.mul(b, c)), Nat.mul(b, Nat.double(c)), double_product(b, c))))

law join_value:
  for +n: Nat
  for +m: Nat
  for +low: Word(n)
  for +high: Word(m)
  {Word.to_nat(Nat.add(n, m), W.join(n, m, low, high)) == Nat.add(Word.to_nat(n, low), Nat.mul(Word.to_nat(m, high), power(n))) : Nat}
def join_value(n, m, low, high):
  match n:
    case 0n:
      match low:
        case WNil{}: Equal.sym(Nat, Nat.mul(Word.to_nat(m, high), 1n), Word.to_nat(m, high), times_one(Word.to_nat(m, high)))
    case 1n+p:
      match low:
        case WCon{False{}, tail}:
          double_recompose(Word.to_nat(Nat.add(p, m), W.join(p, m, tail, high)), Word.to_nat(p, tail), Word.to_nat(m, high), power(p), join_value(p, m, tail, high))
        case WCon{True{}, tail}:
          Equal.cong(Nat, Nat, x => 1n+x, Nat.double(Word.to_nat(Nat.add(p, m), W.join(p, m, tail, high))), Nat.add(Nat.double(Word.to_nat(p, tail)), Nat.mul(Word.to_nat(m, high), Nat.double(power(p)))), double_recompose(Word.to_nat(Nat.add(p, m), W.join(p, m, tail, high)), Word.to_nat(p, tail), Word.to_nat(m, high), power(p), join_value(p, m, tail, high)))

law zero_value:
  for +n: Nat
  {Word.to_nat(n, Word.zero(n)) == 0n : Nat}
def zero_value(n):
  match n:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat, Nat, Nat.double, Word.to_nat(p, Word.zero(p)), 0n, zero_value(p))
