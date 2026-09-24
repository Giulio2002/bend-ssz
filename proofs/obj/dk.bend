import Base

# Data-kind (copyable) existentials, pairs and sums for representation
# invariants. Base's Exists / & / Or are single-use (Kind &1), but a root law
# needs one invariant twice: to rewrite the runtime root and to relate the view.

def Ex(-A: Data, -B: @-x: A -> Data) -> Data:
  Sigma<&2, &2, A, B>

def P2(-A: Data, -B: Data) -> Data:
  Sigma<&2, &2, A, _ => B>

def Or2(-A: Data, -B: Data) -> Data:
  Either<&2, &2, A, B>

law and_l:
  for +a: Bool
  for +b: Bool
  for +e: {Bool.and(a, b) == True{} : Bool}
  {a == True{} : Bool}
def and_l(a, b, e):
  match a:
    case True{}: {==}
    case False{}: e

law and_r:
  for +a: Bool
  for +b: Bool
  for +e: {Bool.and(a, b) == True{} : Bool}
  {b == True{} : Bool}
def and_r(a, b, e):
  match a:
    case True{}: e
    case False{}:
      match b:
        case True{}: {==}
        case False{}: e
