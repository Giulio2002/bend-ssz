import Base

law and_right_true:
  for +b: Bool
  {b == Bool.and(b, True{}) : Bool}
def and_right_true(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law and_right_false:
  for +b: Bool
  {False{} == Bool.and(b, False{}) : Bool}
def and_right_false(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law natural_symmetry:
  for +a: Nat
  for +b: Nat
  {Nat.is_eq(a, b) == Nat.is_eq(b, a) : Bool}
def natural_symmetry(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: natural_symmetry(p, q)
