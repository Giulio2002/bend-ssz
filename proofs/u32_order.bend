import Base

# Unsigned word comparison agrees with arithmetic comparison of the words'
# natural values, for every width and every pair of words.
law double_compare:
  for +a: Nat
  for +b: Nat
  {Nat.cmp(Nat.double(a), Nat.double(b)) == Nat.cmp(a, b) : Cmp}
def double_compare(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: double_compare(p, q)

law even_odd_compare:
  for +a: Nat
  for +b: Nat
  {Nat.cmp(Nat.double(a), 1n+Nat.double(b)) == Word.cmp.fin(False{}, True{}, Nat.cmp(a, b)) : Cmp}
def even_odd_compare(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: even_odd_compare(p, q)

law odd_even_compare:
  for +a: Nat
  for +b: Nat
  {Nat.cmp(1n+Nat.double(a), Nat.double(b)) == Word.cmp.fin(True{}, False{}, Nat.cmp(a, b)) : Cmp}
def odd_even_compare(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: odd_even_compare(p, q)

law bit_compare:
  for +x: Bool
  for +y: Bool
  for +a: Nat
  for +b: Nat
  {Nat.cmp(Word.to_nat(1n, WCon{x, WNil{}}) , Word.to_nat(1n, WCon{y, WNil{}})) == Bool.cmp(x, y) : Cmp}
def bit_compare(x, y, a, b):
  match x y:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}: {==}

law fin_equal:
  for +x: Bool
  for +c: Cmp
  {c == Word.cmp.fin(x, x, c) : Cmp}
def fin_equal(x, c):
  match x:
    case False{}:
      match c:
        case LT{}: {==}
        case EQ{}: {==}
        case GT{}: {==}
    case True{}:
      match c:
        case LT{}: {==}
        case EQ{}: {==}
        case GT{}: {==}

law step_compare:
  for +x: Bool
  for +y: Bool
  for +a: Nat
  for +b: Nat
  {Nat.cmp(Bool.pick(Nat, x, 1n+Nat.double(a), Nat.double(a)), Bool.pick(Nat, y, 1n+Nat.double(b), Nat.double(b))) == Word.cmp.fin(x, y, Nat.cmp(a, b)) : Cmp}
def step_compare(x, y, a, b):
  match x y:
    case False{} False{}:
      %Equal.sym(Cmp, Nat.cmp(Nat.double(a), Nat.double(b)), Nat.cmp(a, b), double_compare(a, b)) : {_ == Word.cmp.fin(False{}, False{}, Nat.cmp(a, b)) : Cmp}
      fin_equal(False{}, Nat.cmp(a, b))
    case False{} True{}: even_odd_compare(a, b)
    case True{} False{}: odd_even_compare(a, b)
    case True{} True{}:
      %Equal.sym(Cmp, Nat.cmp(Nat.double(a), Nat.double(b)), Nat.cmp(a, b), double_compare(a, b)) : {_ == Word.cmp.fin(True{}, True{}, Nat.cmp(a, b)) : Cmp}
      fin_equal(True{}, Nat.cmp(a, b))

def bit_value(x: Bool, n: Nat) -> Nat:
  match x:
    case False{}: Nat.double(n)
    case True{}: 1n+Nat.double(n)

law bit_step:
  for +x: Bool
  for +y: Bool
  for +a: Nat
  for +b: Nat
  {Word.cmp.fin(x, y, Nat.cmp(a, b)) == Nat.cmp(bit_value(x, a), bit_value(y, b)) : Cmp}
def bit_step(x, y, a, b):
  match x y:
    case False{} False{}: Equal.trans(Cmp, Word.cmp.fin(False{}, False{}, Nat.cmp(a, b)), Nat.cmp(a, b), Nat.cmp(Nat.double(a), Nat.double(b)), Equal.sym(Cmp, Nat.cmp(a, b), Word.cmp.fin(False{}, False{}, Nat.cmp(a, b)), fin_equal(False{}, Nat.cmp(a, b))), Equal.sym(Cmp, Nat.cmp(Nat.double(a), Nat.double(b)), Nat.cmp(a, b), double_compare(a, b)))
    case False{} True{}: Equal.sym(Cmp, Nat.cmp(Nat.double(a), 1n+Nat.double(b)), Word.cmp.fin(False{}, True{}, Nat.cmp(a, b)), even_odd_compare(a, b))
    case True{} False{}: Equal.sym(Cmp, Nat.cmp(1n+Nat.double(a), Nat.double(b)), Word.cmp.fin(True{}, False{}, Nat.cmp(a, b)), odd_even_compare(a, b))
    case True{} True{}: Equal.trans(Cmp, Word.cmp.fin(True{}, True{}, Nat.cmp(a, b)), Nat.cmp(a, b), Nat.cmp(Nat.double(a), Nat.double(b)), Equal.sym(Cmp, Nat.cmp(a, b), Word.cmp.fin(True{}, True{}, Nat.cmp(a, b)), fin_equal(True{}, Nat.cmp(a, b))), Equal.sym(Cmp, Nat.cmp(Nat.double(a), Nat.double(b)), Nat.cmp(a, b), double_compare(a, b)))

law word_step:
  for +x: Bool
  for +y: Bool
  for +p: Nat
  for +at: Word(p)
  for +bt: Word(p)
  for tail: {Word.cmp(p, at, bt) == Nat.cmp(Word.to_nat(p, at), Word.to_nat(p, bt)) : Cmp}
  {Word.cmp(1n+p, WCon{x, at}, WCon{y, bt}) == Nat.cmp(Word.to_nat(1n+p, WCon{x, at}), Word.to_nat(1n+p, WCon{y, bt})) : Cmp}
def word_step(x, y, p, at, bt, tail):
  match x y:
    case False{} False{}:
      %Equal.sym(Cmp, Word.cmp(p, at, bt), Nat.cmp(Word.to_nat(p, at), Word.to_nat(p, bt)), tail) : {Word.cmp.fin(False{}, False{}, _) == Nat.cmp(Word.to_nat(1n+p, WCon{False{}, at}), Word.to_nat(1n+p, WCon{False{}, bt})) : Cmp}
      bit_step(False{}, False{}, Word.to_nat(p, at), Word.to_nat(p, bt))
    case False{} True{}:
      %Equal.sym(Cmp, Word.cmp(p, at, bt), Nat.cmp(Word.to_nat(p, at), Word.to_nat(p, bt)), tail) : {Word.cmp.fin(False{}, True{}, _) == Nat.cmp(Word.to_nat(1n+p, WCon{False{}, at}), Word.to_nat(1n+p, WCon{True{}, bt})) : Cmp}
      bit_step(False{}, True{}, Word.to_nat(p, at), Word.to_nat(p, bt))
    case True{} False{}:
      %Equal.sym(Cmp, Word.cmp(p, at, bt), Nat.cmp(Word.to_nat(p, at), Word.to_nat(p, bt)), tail) : {Word.cmp.fin(True{}, False{}, _) == Nat.cmp(Word.to_nat(1n+p, WCon{True{}, at}), Word.to_nat(1n+p, WCon{False{}, bt})) : Cmp}
      bit_step(True{}, False{}, Word.to_nat(p, at), Word.to_nat(p, bt))
    case True{} True{}:
      %Equal.sym(Cmp, Word.cmp(p, at, bt), Nat.cmp(Word.to_nat(p, at), Word.to_nat(p, bt)), tail) : {Word.cmp.fin(True{}, True{}, _) == Nat.cmp(Word.to_nat(1n+p, WCon{True{}, at}), Word.to_nat(1n+p, WCon{True{}, bt})) : Cmp}
      bit_step(True{}, True{}, Word.to_nat(p, at), Word.to_nat(p, bt))

law word_compare:
  for +n: Nat
  for +a: Word(n)
  for +b: Word(n)
  {Word.cmp(n, a, b) == Nat.cmp(Word.to_nat(n, a), Word.to_nat(n, b)) : Cmp}
def word_compare(n, a, b):
  match n:
    case 0n: {==}
    case 1n+p:
      match a b:
        case WCon{x, at} WCon{y, bt}: word_step(x, y, p, at, bt, word_compare(p, at, bt))

law u32_compare:
  for +a: U32
  for +b: U32
  {U32.cmp(a, b) == Nat.cmp(U32.to_nat(a), U32.to_nat(b)) : Cmp}
def u32_compare(a, b):
  match a b:
    case U32{x} U32{y}: word_compare(32n, x, y)

law u32_less:
  for +a: U32
  for +b: U32
  {U32.is_lt(a, b) == Nat.is_lt(U32.to_nat(a), U32.to_nat(b)) : Bool}
def u32_less(a, b):
  Equal.cong(Cmp, Bool, Cmp.is_lt, U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), u32_compare(a, b))
