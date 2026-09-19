import Base
import ../src/bit_packing.bend as I
import ../spec/bit_packing.bend as S
import ../spec/primitives.bend as P
import ./primitive_invariants.bend as V

law octet_correct:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  {I.octet(b0, b1, b2, b3, b4, b5, b6, b7) == S.octet(b0, b1, b2, b3, b4, b5, b6, b7) : U32}
def octet_correct(b0, b1, b2, b3, b4, b5, b6, b7):
  match b0 b1 b2 b3 b4 b5 b6 b7:
    case False{} False{} False{} False{} False{} False{} False{} False{}: {==}
    case True{} False{} False{} False{} False{} False{} False{} False{}: {==}
    case False{} True{} False{} False{} False{} False{} False{} False{}: {==}
    case True{} True{} False{} False{} False{} False{} False{} False{}: {==}
    case False{} False{} True{} False{} False{} False{} False{} False{}: {==}
    case True{} False{} True{} False{} False{} False{} False{} False{}: {==}
    case False{} True{} True{} False{} False{} False{} False{} False{}: {==}
    case True{} True{} True{} False{} False{} False{} False{} False{}: {==}
    case False{} False{} False{} True{} False{} False{} False{} False{}: {==}
    case True{} False{} False{} True{} False{} False{} False{} False{}: {==}
    case False{} True{} False{} True{} False{} False{} False{} False{}: {==}
    case True{} True{} False{} True{} False{} False{} False{} False{}: {==}
    case False{} False{} True{} True{} False{} False{} False{} False{}: {==}
    case True{} False{} True{} True{} False{} False{} False{} False{}: {==}
    case False{} True{} True{} True{} False{} False{} False{} False{}: {==}
    case True{} True{} True{} True{} False{} False{} False{} False{}: {==}
    case False{} False{} False{} False{} True{} False{} False{} False{}: {==}
    case True{} False{} False{} False{} True{} False{} False{} False{}: {==}
    case False{} True{} False{} False{} True{} False{} False{} False{}: {==}
    case True{} True{} False{} False{} True{} False{} False{} False{}: {==}
    case False{} False{} True{} False{} True{} False{} False{} False{}: {==}
    case True{} False{} True{} False{} True{} False{} False{} False{}: {==}
    case False{} True{} True{} False{} True{} False{} False{} False{}: {==}
    case True{} True{} True{} False{} True{} False{} False{} False{}: {==}
    case False{} False{} False{} True{} True{} False{} False{} False{}: {==}
    case True{} False{} False{} True{} True{} False{} False{} False{}: {==}
    case False{} True{} False{} True{} True{} False{} False{} False{}: {==}
    case True{} True{} False{} True{} True{} False{} False{} False{}: {==}
    case False{} False{} True{} True{} True{} False{} False{} False{}: {==}
    case True{} False{} True{} True{} True{} False{} False{} False{}: {==}
    case False{} True{} True{} True{} True{} False{} False{} False{}: {==}
    case True{} True{} True{} True{} True{} False{} False{} False{}: {==}
    case False{} False{} False{} False{} False{} True{} False{} False{}: {==}
    case True{} False{} False{} False{} False{} True{} False{} False{}: {==}
    case False{} True{} False{} False{} False{} True{} False{} False{}: {==}
    case True{} True{} False{} False{} False{} True{} False{} False{}: {==}
    case False{} False{} True{} False{} False{} True{} False{} False{}: {==}
    case True{} False{} True{} False{} False{} True{} False{} False{}: {==}
    case False{} True{} True{} False{} False{} True{} False{} False{}: {==}
    case True{} True{} True{} False{} False{} True{} False{} False{}: {==}
    case False{} False{} False{} True{} False{} True{} False{} False{}: {==}
    case True{} False{} False{} True{} False{} True{} False{} False{}: {==}
    case False{} True{} False{} True{} False{} True{} False{} False{}: {==}
    case True{} True{} False{} True{} False{} True{} False{} False{}: {==}
    case False{} False{} True{} True{} False{} True{} False{} False{}: {==}
    case True{} False{} True{} True{} False{} True{} False{} False{}: {==}
    case False{} True{} True{} True{} False{} True{} False{} False{}: {==}
    case True{} True{} True{} True{} False{} True{} False{} False{}: {==}
    case False{} False{} False{} False{} True{} True{} False{} False{}: {==}
    case True{} False{} False{} False{} True{} True{} False{} False{}: {==}
    case False{} True{} False{} False{} True{} True{} False{} False{}: {==}
    case True{} True{} False{} False{} True{} True{} False{} False{}: {==}
    case False{} False{} True{} False{} True{} True{} False{} False{}: {==}
    case True{} False{} True{} False{} True{} True{} False{} False{}: {==}
    case False{} True{} True{} False{} True{} True{} False{} False{}: {==}
    case True{} True{} True{} False{} True{} True{} False{} False{}: {==}
    case False{} False{} False{} True{} True{} True{} False{} False{}: {==}
    case True{} False{} False{} True{} True{} True{} False{} False{}: {==}
    case False{} True{} False{} True{} True{} True{} False{} False{}: {==}
    case True{} True{} False{} True{} True{} True{} False{} False{}: {==}
    case False{} False{} True{} True{} True{} True{} False{} False{}: {==}
    case True{} False{} True{} True{} True{} True{} False{} False{}: {==}
    case False{} True{} True{} True{} True{} True{} False{} False{}: {==}
    case True{} True{} True{} True{} True{} True{} False{} False{}: {==}
    case False{} False{} False{} False{} False{} False{} True{} False{}: {==}
    case True{} False{} False{} False{} False{} False{} True{} False{}: {==}
    case False{} True{} False{} False{} False{} False{} True{} False{}: {==}
    case True{} True{} False{} False{} False{} False{} True{} False{}: {==}
    case False{} False{} True{} False{} False{} False{} True{} False{}: {==}
    case True{} False{} True{} False{} False{} False{} True{} False{}: {==}
    case False{} True{} True{} False{} False{} False{} True{} False{}: {==}
    case True{} True{} True{} False{} False{} False{} True{} False{}: {==}
    case False{} False{} False{} True{} False{} False{} True{} False{}: {==}
    case True{} False{} False{} True{} False{} False{} True{} False{}: {==}
    case False{} True{} False{} True{} False{} False{} True{} False{}: {==}
    case True{} True{} False{} True{} False{} False{} True{} False{}: {==}
    case False{} False{} True{} True{} False{} False{} True{} False{}: {==}
    case True{} False{} True{} True{} False{} False{} True{} False{}: {==}
    case False{} True{} True{} True{} False{} False{} True{} False{}: {==}
    case True{} True{} True{} True{} False{} False{} True{} False{}: {==}
    case False{} False{} False{} False{} True{} False{} True{} False{}: {==}
    case True{} False{} False{} False{} True{} False{} True{} False{}: {==}
    case False{} True{} False{} False{} True{} False{} True{} False{}: {==}
    case True{} True{} False{} False{} True{} False{} True{} False{}: {==}
    case False{} False{} True{} False{} True{} False{} True{} False{}: {==}
    case True{} False{} True{} False{} True{} False{} True{} False{}: {==}
    case False{} True{} True{} False{} True{} False{} True{} False{}: {==}
    case True{} True{} True{} False{} True{} False{} True{} False{}: {==}
    case False{} False{} False{} True{} True{} False{} True{} False{}: {==}
    case True{} False{} False{} True{} True{} False{} True{} False{}: {==}
    case False{} True{} False{} True{} True{} False{} True{} False{}: {==}
    case True{} True{} False{} True{} True{} False{} True{} False{}: {==}
    case False{} False{} True{} True{} True{} False{} True{} False{}: {==}
    case True{} False{} True{} True{} True{} False{} True{} False{}: {==}
    case False{} True{} True{} True{} True{} False{} True{} False{}: {==}
    case True{} True{} True{} True{} True{} False{} True{} False{}: {==}
    case False{} False{} False{} False{} False{} True{} True{} False{}: {==}
    case True{} False{} False{} False{} False{} True{} True{} False{}: {==}
    case False{} True{} False{} False{} False{} True{} True{} False{}: {==}
    case True{} True{} False{} False{} False{} True{} True{} False{}: {==}
    case False{} False{} True{} False{} False{} True{} True{} False{}: {==}
    case True{} False{} True{} False{} False{} True{} True{} False{}: {==}
    case False{} True{} True{} False{} False{} True{} True{} False{}: {==}
    case True{} True{} True{} False{} False{} True{} True{} False{}: {==}
    case False{} False{} False{} True{} False{} True{} True{} False{}: {==}
    case True{} False{} False{} True{} False{} True{} True{} False{}: {==}
    case False{} True{} False{} True{} False{} True{} True{} False{}: {==}
    case True{} True{} False{} True{} False{} True{} True{} False{}: {==}
    case False{} False{} True{} True{} False{} True{} True{} False{}: {==}
    case True{} False{} True{} True{} False{} True{} True{} False{}: {==}
    case False{} True{} True{} True{} False{} True{} True{} False{}: {==}
    case True{} True{} True{} True{} False{} True{} True{} False{}: {==}
    case False{} False{} False{} False{} True{} True{} True{} False{}: {==}
    case True{} False{} False{} False{} True{} True{} True{} False{}: {==}
    case False{} True{} False{} False{} True{} True{} True{} False{}: {==}
    case True{} True{} False{} False{} True{} True{} True{} False{}: {==}
    case False{} False{} True{} False{} True{} True{} True{} False{}: {==}
    case True{} False{} True{} False{} True{} True{} True{} False{}: {==}
    case False{} True{} True{} False{} True{} True{} True{} False{}: {==}
    case True{} True{} True{} False{} True{} True{} True{} False{}: {==}
    case False{} False{} False{} True{} True{} True{} True{} False{}: {==}
    case True{} False{} False{} True{} True{} True{} True{} False{}: {==}
    case False{} True{} False{} True{} True{} True{} True{} False{}: {==}
    case True{} True{} False{} True{} True{} True{} True{} False{}: {==}
    case False{} False{} True{} True{} True{} True{} True{} False{}: {==}
    case True{} False{} True{} True{} True{} True{} True{} False{}: {==}
    case False{} True{} True{} True{} True{} True{} True{} False{}: {==}
    case True{} True{} True{} True{} True{} True{} True{} False{}: {==}
    case False{} False{} False{} False{} False{} False{} False{} True{}: {==}
    case True{} False{} False{} False{} False{} False{} False{} True{}: {==}
    case False{} True{} False{} False{} False{} False{} False{} True{}: {==}
    case True{} True{} False{} False{} False{} False{} False{} True{}: {==}
    case False{} False{} True{} False{} False{} False{} False{} True{}: {==}
    case True{} False{} True{} False{} False{} False{} False{} True{}: {==}
    case False{} True{} True{} False{} False{} False{} False{} True{}: {==}
    case True{} True{} True{} False{} False{} False{} False{} True{}: {==}
    case False{} False{} False{} True{} False{} False{} False{} True{}: {==}
    case True{} False{} False{} True{} False{} False{} False{} True{}: {==}
    case False{} True{} False{} True{} False{} False{} False{} True{}: {==}
    case True{} True{} False{} True{} False{} False{} False{} True{}: {==}
    case False{} False{} True{} True{} False{} False{} False{} True{}: {==}
    case True{} False{} True{} True{} False{} False{} False{} True{}: {==}
    case False{} True{} True{} True{} False{} False{} False{} True{}: {==}
    case True{} True{} True{} True{} False{} False{} False{} True{}: {==}
    case False{} False{} False{} False{} True{} False{} False{} True{}: {==}
    case True{} False{} False{} False{} True{} False{} False{} True{}: {==}
    case False{} True{} False{} False{} True{} False{} False{} True{}: {==}
    case True{} True{} False{} False{} True{} False{} False{} True{}: {==}
    case False{} False{} True{} False{} True{} False{} False{} True{}: {==}
    case True{} False{} True{} False{} True{} False{} False{} True{}: {==}
    case False{} True{} True{} False{} True{} False{} False{} True{}: {==}
    case True{} True{} True{} False{} True{} False{} False{} True{}: {==}
    case False{} False{} False{} True{} True{} False{} False{} True{}: {==}
    case True{} False{} False{} True{} True{} False{} False{} True{}: {==}
    case False{} True{} False{} True{} True{} False{} False{} True{}: {==}
    case True{} True{} False{} True{} True{} False{} False{} True{}: {==}
    case False{} False{} True{} True{} True{} False{} False{} True{}: {==}
    case True{} False{} True{} True{} True{} False{} False{} True{}: {==}
    case False{} True{} True{} True{} True{} False{} False{} True{}: {==}
    case True{} True{} True{} True{} True{} False{} False{} True{}: {==}
    case False{} False{} False{} False{} False{} True{} False{} True{}: {==}
    case True{} False{} False{} False{} False{} True{} False{} True{}: {==}
    case False{} True{} False{} False{} False{} True{} False{} True{}: {==}
    case True{} True{} False{} False{} False{} True{} False{} True{}: {==}
    case False{} False{} True{} False{} False{} True{} False{} True{}: {==}
    case True{} False{} True{} False{} False{} True{} False{} True{}: {==}
    case False{} True{} True{} False{} False{} True{} False{} True{}: {==}
    case True{} True{} True{} False{} False{} True{} False{} True{}: {==}
    case False{} False{} False{} True{} False{} True{} False{} True{}: {==}
    case True{} False{} False{} True{} False{} True{} False{} True{}: {==}
    case False{} True{} False{} True{} False{} True{} False{} True{}: {==}
    case True{} True{} False{} True{} False{} True{} False{} True{}: {==}
    case False{} False{} True{} True{} False{} True{} False{} True{}: {==}
    case True{} False{} True{} True{} False{} True{} False{} True{}: {==}
    case False{} True{} True{} True{} False{} True{} False{} True{}: {==}
    case True{} True{} True{} True{} False{} True{} False{} True{}: {==}
    case False{} False{} False{} False{} True{} True{} False{} True{}: {==}
    case True{} False{} False{} False{} True{} True{} False{} True{}: {==}
    case False{} True{} False{} False{} True{} True{} False{} True{}: {==}
    case True{} True{} False{} False{} True{} True{} False{} True{}: {==}
    case False{} False{} True{} False{} True{} True{} False{} True{}: {==}
    case True{} False{} True{} False{} True{} True{} False{} True{}: {==}
    case False{} True{} True{} False{} True{} True{} False{} True{}: {==}
    case True{} True{} True{} False{} True{} True{} False{} True{}: {==}
    case False{} False{} False{} True{} True{} True{} False{} True{}: {==}
    case True{} False{} False{} True{} True{} True{} False{} True{}: {==}
    case False{} True{} False{} True{} True{} True{} False{} True{}: {==}
    case True{} True{} False{} True{} True{} True{} False{} True{}: {==}
    case False{} False{} True{} True{} True{} True{} False{} True{}: {==}
    case True{} False{} True{} True{} True{} True{} False{} True{}: {==}
    case False{} True{} True{} True{} True{} True{} False{} True{}: {==}
    case True{} True{} True{} True{} True{} True{} False{} True{}: {==}
    case False{} False{} False{} False{} False{} False{} True{} True{}: {==}
    case True{} False{} False{} False{} False{} False{} True{} True{}: {==}
    case False{} True{} False{} False{} False{} False{} True{} True{}: {==}
    case True{} True{} False{} False{} False{} False{} True{} True{}: {==}
    case False{} False{} True{} False{} False{} False{} True{} True{}: {==}
    case True{} False{} True{} False{} False{} False{} True{} True{}: {==}
    case False{} True{} True{} False{} False{} False{} True{} True{}: {==}
    case True{} True{} True{} False{} False{} False{} True{} True{}: {==}
    case False{} False{} False{} True{} False{} False{} True{} True{}: {==}
    case True{} False{} False{} True{} False{} False{} True{} True{}: {==}
    case False{} True{} False{} True{} False{} False{} True{} True{}: {==}
    case True{} True{} False{} True{} False{} False{} True{} True{}: {==}
    case False{} False{} True{} True{} False{} False{} True{} True{}: {==}
    case True{} False{} True{} True{} False{} False{} True{} True{}: {==}
    case False{} True{} True{} True{} False{} False{} True{} True{}: {==}
    case True{} True{} True{} True{} False{} False{} True{} True{}: {==}
    case False{} False{} False{} False{} True{} False{} True{} True{}: {==}
    case True{} False{} False{} False{} True{} False{} True{} True{}: {==}
    case False{} True{} False{} False{} True{} False{} True{} True{}: {==}
    case True{} True{} False{} False{} True{} False{} True{} True{}: {==}
    case False{} False{} True{} False{} True{} False{} True{} True{}: {==}
    case True{} False{} True{} False{} True{} False{} True{} True{}: {==}
    case False{} True{} True{} False{} True{} False{} True{} True{}: {==}
    case True{} True{} True{} False{} True{} False{} True{} True{}: {==}
    case False{} False{} False{} True{} True{} False{} True{} True{}: {==}
    case True{} False{} False{} True{} True{} False{} True{} True{}: {==}
    case False{} True{} False{} True{} True{} False{} True{} True{}: {==}
    case True{} True{} False{} True{} True{} False{} True{} True{}: {==}
    case False{} False{} True{} True{} True{} False{} True{} True{}: {==}
    case True{} False{} True{} True{} True{} False{} True{} True{}: {==}
    case False{} True{} True{} True{} True{} False{} True{} True{}: {==}
    case True{} True{} True{} True{} True{} False{} True{} True{}: {==}
    case False{} False{} False{} False{} False{} True{} True{} True{}: {==}
    case True{} False{} False{} False{} False{} True{} True{} True{}: {==}
    case False{} True{} False{} False{} False{} True{} True{} True{}: {==}
    case True{} True{} False{} False{} False{} True{} True{} True{}: {==}
    case False{} False{} True{} False{} False{} True{} True{} True{}: {==}
    case True{} False{} True{} False{} False{} True{} True{} True{}: {==}
    case False{} True{} True{} False{} False{} True{} True{} True{}: {==}
    case True{} True{} True{} False{} False{} True{} True{} True{}: {==}
    case False{} False{} False{} True{} False{} True{} True{} True{}: {==}
    case True{} False{} False{} True{} False{} True{} True{} True{}: {==}
    case False{} True{} False{} True{} False{} True{} True{} True{}: {==}
    case True{} True{} False{} True{} False{} True{} True{} True{}: {==}
    case False{} False{} True{} True{} False{} True{} True{} True{}: {==}
    case True{} False{} True{} True{} False{} True{} True{} True{}: {==}
    case False{} True{} True{} True{} False{} True{} True{} True{}: {==}
    case True{} True{} True{} True{} False{} True{} True{} True{}: {==}
    case False{} False{} False{} False{} True{} True{} True{} True{}: {==}
    case True{} False{} False{} False{} True{} True{} True{} True{}: {==}
    case False{} True{} False{} False{} True{} True{} True{} True{}: {==}
    case True{} True{} False{} False{} True{} True{} True{} True{}: {==}
    case False{} False{} True{} False{} True{} True{} True{} True{}: {==}
    case True{} False{} True{} False{} True{} True{} True{} True{}: {==}
    case False{} True{} True{} False{} True{} True{} True{} True{}: {==}
    case True{} True{} True{} False{} True{} True{} True{} True{}: {==}
    case False{} False{} False{} True{} True{} True{} True{} True{}: {==}
    case True{} False{} False{} True{} True{} True{} True{} True{}: {==}
    case False{} True{} False{} True{} True{} True{} True{} True{}: {==}
    case True{} True{} False{} True{} True{} True{} True{} True{}: {==}
    case False{} False{} True{} True{} True{} True{} True{} True{}: {==}
    case True{} False{} True{} True{} True{} True{} True{} True{}: {==}
    case False{} True{} True{} True{} True{} True{} True{} True{}: {==}
    case True{} True{} True{} True{} True{} True{} True{} True{}: {==}

law octet_bound:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  {U32.is_lt(I.octet(b0, b1, b2, b3, b4, b5, b6, b7), 256) == True{} : Bool}
def octet_bound(b0, b1, b2, b3, b4, b5, b6, b7):
  match b0 b1 b2 b3 b4 b5 b6 b7:
    case False{} False{} False{} False{} False{} False{} False{} False{}: {==}
    case True{} False{} False{} False{} False{} False{} False{} False{}: {==}
    case False{} True{} False{} False{} False{} False{} False{} False{}: {==}
    case True{} True{} False{} False{} False{} False{} False{} False{}: {==}
    case False{} False{} True{} False{} False{} False{} False{} False{}: {==}
    case True{} False{} True{} False{} False{} False{} False{} False{}: {==}
    case False{} True{} True{} False{} False{} False{} False{} False{}: {==}
    case True{} True{} True{} False{} False{} False{} False{} False{}: {==}
    case False{} False{} False{} True{} False{} False{} False{} False{}: {==}
    case True{} False{} False{} True{} False{} False{} False{} False{}: {==}
    case False{} True{} False{} True{} False{} False{} False{} False{}: {==}
    case True{} True{} False{} True{} False{} False{} False{} False{}: {==}
    case False{} False{} True{} True{} False{} False{} False{} False{}: {==}
    case True{} False{} True{} True{} False{} False{} False{} False{}: {==}
    case False{} True{} True{} True{} False{} False{} False{} False{}: {==}
    case True{} True{} True{} True{} False{} False{} False{} False{}: {==}
    case False{} False{} False{} False{} True{} False{} False{} False{}: {==}
    case True{} False{} False{} False{} True{} False{} False{} False{}: {==}
    case False{} True{} False{} False{} True{} False{} False{} False{}: {==}
    case True{} True{} False{} False{} True{} False{} False{} False{}: {==}
    case False{} False{} True{} False{} True{} False{} False{} False{}: {==}
    case True{} False{} True{} False{} True{} False{} False{} False{}: {==}
    case False{} True{} True{} False{} True{} False{} False{} False{}: {==}
    case True{} True{} True{} False{} True{} False{} False{} False{}: {==}
    case False{} False{} False{} True{} True{} False{} False{} False{}: {==}
    case True{} False{} False{} True{} True{} False{} False{} False{}: {==}
    case False{} True{} False{} True{} True{} False{} False{} False{}: {==}
    case True{} True{} False{} True{} True{} False{} False{} False{}: {==}
    case False{} False{} True{} True{} True{} False{} False{} False{}: {==}
    case True{} False{} True{} True{} True{} False{} False{} False{}: {==}
    case False{} True{} True{} True{} True{} False{} False{} False{}: {==}
    case True{} True{} True{} True{} True{} False{} False{} False{}: {==}
    case False{} False{} False{} False{} False{} True{} False{} False{}: {==}
    case True{} False{} False{} False{} False{} True{} False{} False{}: {==}
    case False{} True{} False{} False{} False{} True{} False{} False{}: {==}
    case True{} True{} False{} False{} False{} True{} False{} False{}: {==}
    case False{} False{} True{} False{} False{} True{} False{} False{}: {==}
    case True{} False{} True{} False{} False{} True{} False{} False{}: {==}
    case False{} True{} True{} False{} False{} True{} False{} False{}: {==}
    case True{} True{} True{} False{} False{} True{} False{} False{}: {==}
    case False{} False{} False{} True{} False{} True{} False{} False{}: {==}
    case True{} False{} False{} True{} False{} True{} False{} False{}: {==}
    case False{} True{} False{} True{} False{} True{} False{} False{}: {==}
    case True{} True{} False{} True{} False{} True{} False{} False{}: {==}
    case False{} False{} True{} True{} False{} True{} False{} False{}: {==}
    case True{} False{} True{} True{} False{} True{} False{} False{}: {==}
    case False{} True{} True{} True{} False{} True{} False{} False{}: {==}
    case True{} True{} True{} True{} False{} True{} False{} False{}: {==}
    case False{} False{} False{} False{} True{} True{} False{} False{}: {==}
    case True{} False{} False{} False{} True{} True{} False{} False{}: {==}
    case False{} True{} False{} False{} True{} True{} False{} False{}: {==}
    case True{} True{} False{} False{} True{} True{} False{} False{}: {==}
    case False{} False{} True{} False{} True{} True{} False{} False{}: {==}
    case True{} False{} True{} False{} True{} True{} False{} False{}: {==}
    case False{} True{} True{} False{} True{} True{} False{} False{}: {==}
    case True{} True{} True{} False{} True{} True{} False{} False{}: {==}
    case False{} False{} False{} True{} True{} True{} False{} False{}: {==}
    case True{} False{} False{} True{} True{} True{} False{} False{}: {==}
    case False{} True{} False{} True{} True{} True{} False{} False{}: {==}
    case True{} True{} False{} True{} True{} True{} False{} False{}: {==}
    case False{} False{} True{} True{} True{} True{} False{} False{}: {==}
    case True{} False{} True{} True{} True{} True{} False{} False{}: {==}
    case False{} True{} True{} True{} True{} True{} False{} False{}: {==}
    case True{} True{} True{} True{} True{} True{} False{} False{}: {==}
    case False{} False{} False{} False{} False{} False{} True{} False{}: {==}
    case True{} False{} False{} False{} False{} False{} True{} False{}: {==}
    case False{} True{} False{} False{} False{} False{} True{} False{}: {==}
    case True{} True{} False{} False{} False{} False{} True{} False{}: {==}
    case False{} False{} True{} False{} False{} False{} True{} False{}: {==}
    case True{} False{} True{} False{} False{} False{} True{} False{}: {==}
    case False{} True{} True{} False{} False{} False{} True{} False{}: {==}
    case True{} True{} True{} False{} False{} False{} True{} False{}: {==}
    case False{} False{} False{} True{} False{} False{} True{} False{}: {==}
    case True{} False{} False{} True{} False{} False{} True{} False{}: {==}
    case False{} True{} False{} True{} False{} False{} True{} False{}: {==}
    case True{} True{} False{} True{} False{} False{} True{} False{}: {==}
    case False{} False{} True{} True{} False{} False{} True{} False{}: {==}
    case True{} False{} True{} True{} False{} False{} True{} False{}: {==}
    case False{} True{} True{} True{} False{} False{} True{} False{}: {==}
    case True{} True{} True{} True{} False{} False{} True{} False{}: {==}
    case False{} False{} False{} False{} True{} False{} True{} False{}: {==}
    case True{} False{} False{} False{} True{} False{} True{} False{}: {==}
    case False{} True{} False{} False{} True{} False{} True{} False{}: {==}
    case True{} True{} False{} False{} True{} False{} True{} False{}: {==}
    case False{} False{} True{} False{} True{} False{} True{} False{}: {==}
    case True{} False{} True{} False{} True{} False{} True{} False{}: {==}
    case False{} True{} True{} False{} True{} False{} True{} False{}: {==}
    case True{} True{} True{} False{} True{} False{} True{} False{}: {==}
    case False{} False{} False{} True{} True{} False{} True{} False{}: {==}
    case True{} False{} False{} True{} True{} False{} True{} False{}: {==}
    case False{} True{} False{} True{} True{} False{} True{} False{}: {==}
    case True{} True{} False{} True{} True{} False{} True{} False{}: {==}
    case False{} False{} True{} True{} True{} False{} True{} False{}: {==}
    case True{} False{} True{} True{} True{} False{} True{} False{}: {==}
    case False{} True{} True{} True{} True{} False{} True{} False{}: {==}
    case True{} True{} True{} True{} True{} False{} True{} False{}: {==}
    case False{} False{} False{} False{} False{} True{} True{} False{}: {==}
    case True{} False{} False{} False{} False{} True{} True{} False{}: {==}
    case False{} True{} False{} False{} False{} True{} True{} False{}: {==}
    case True{} True{} False{} False{} False{} True{} True{} False{}: {==}
    case False{} False{} True{} False{} False{} True{} True{} False{}: {==}
    case True{} False{} True{} False{} False{} True{} True{} False{}: {==}
    case False{} True{} True{} False{} False{} True{} True{} False{}: {==}
    case True{} True{} True{} False{} False{} True{} True{} False{}: {==}
    case False{} False{} False{} True{} False{} True{} True{} False{}: {==}
    case True{} False{} False{} True{} False{} True{} True{} False{}: {==}
    case False{} True{} False{} True{} False{} True{} True{} False{}: {==}
    case True{} True{} False{} True{} False{} True{} True{} False{}: {==}
    case False{} False{} True{} True{} False{} True{} True{} False{}: {==}
    case True{} False{} True{} True{} False{} True{} True{} False{}: {==}
    case False{} True{} True{} True{} False{} True{} True{} False{}: {==}
    case True{} True{} True{} True{} False{} True{} True{} False{}: {==}
    case False{} False{} False{} False{} True{} True{} True{} False{}: {==}
    case True{} False{} False{} False{} True{} True{} True{} False{}: {==}
    case False{} True{} False{} False{} True{} True{} True{} False{}: {==}
    case True{} True{} False{} False{} True{} True{} True{} False{}: {==}
    case False{} False{} True{} False{} True{} True{} True{} False{}: {==}
    case True{} False{} True{} False{} True{} True{} True{} False{}: {==}
    case False{} True{} True{} False{} True{} True{} True{} False{}: {==}
    case True{} True{} True{} False{} True{} True{} True{} False{}: {==}
    case False{} False{} False{} True{} True{} True{} True{} False{}: {==}
    case True{} False{} False{} True{} True{} True{} True{} False{}: {==}
    case False{} True{} False{} True{} True{} True{} True{} False{}: {==}
    case True{} True{} False{} True{} True{} True{} True{} False{}: {==}
    case False{} False{} True{} True{} True{} True{} True{} False{}: {==}
    case True{} False{} True{} True{} True{} True{} True{} False{}: {==}
    case False{} True{} True{} True{} True{} True{} True{} False{}: {==}
    case True{} True{} True{} True{} True{} True{} True{} False{}: {==}
    case False{} False{} False{} False{} False{} False{} False{} True{}: {==}
    case True{} False{} False{} False{} False{} False{} False{} True{}: {==}
    case False{} True{} False{} False{} False{} False{} False{} True{}: {==}
    case True{} True{} False{} False{} False{} False{} False{} True{}: {==}
    case False{} False{} True{} False{} False{} False{} False{} True{}: {==}
    case True{} False{} True{} False{} False{} False{} False{} True{}: {==}
    case False{} True{} True{} False{} False{} False{} False{} True{}: {==}
    case True{} True{} True{} False{} False{} False{} False{} True{}: {==}
    case False{} False{} False{} True{} False{} False{} False{} True{}: {==}
    case True{} False{} False{} True{} False{} False{} False{} True{}: {==}
    case False{} True{} False{} True{} False{} False{} False{} True{}: {==}
    case True{} True{} False{} True{} False{} False{} False{} True{}: {==}
    case False{} False{} True{} True{} False{} False{} False{} True{}: {==}
    case True{} False{} True{} True{} False{} False{} False{} True{}: {==}
    case False{} True{} True{} True{} False{} False{} False{} True{}: {==}
    case True{} True{} True{} True{} False{} False{} False{} True{}: {==}
    case False{} False{} False{} False{} True{} False{} False{} True{}: {==}
    case True{} False{} False{} False{} True{} False{} False{} True{}: {==}
    case False{} True{} False{} False{} True{} False{} False{} True{}: {==}
    case True{} True{} False{} False{} True{} False{} False{} True{}: {==}
    case False{} False{} True{} False{} True{} False{} False{} True{}: {==}
    case True{} False{} True{} False{} True{} False{} False{} True{}: {==}
    case False{} True{} True{} False{} True{} False{} False{} True{}: {==}
    case True{} True{} True{} False{} True{} False{} False{} True{}: {==}
    case False{} False{} False{} True{} True{} False{} False{} True{}: {==}
    case True{} False{} False{} True{} True{} False{} False{} True{}: {==}
    case False{} True{} False{} True{} True{} False{} False{} True{}: {==}
    case True{} True{} False{} True{} True{} False{} False{} True{}: {==}
    case False{} False{} True{} True{} True{} False{} False{} True{}: {==}
    case True{} False{} True{} True{} True{} False{} False{} True{}: {==}
    case False{} True{} True{} True{} True{} False{} False{} True{}: {==}
    case True{} True{} True{} True{} True{} False{} False{} True{}: {==}
    case False{} False{} False{} False{} False{} True{} False{} True{}: {==}
    case True{} False{} False{} False{} False{} True{} False{} True{}: {==}
    case False{} True{} False{} False{} False{} True{} False{} True{}: {==}
    case True{} True{} False{} False{} False{} True{} False{} True{}: {==}
    case False{} False{} True{} False{} False{} True{} False{} True{}: {==}
    case True{} False{} True{} False{} False{} True{} False{} True{}: {==}
    case False{} True{} True{} False{} False{} True{} False{} True{}: {==}
    case True{} True{} True{} False{} False{} True{} False{} True{}: {==}
    case False{} False{} False{} True{} False{} True{} False{} True{}: {==}
    case True{} False{} False{} True{} False{} True{} False{} True{}: {==}
    case False{} True{} False{} True{} False{} True{} False{} True{}: {==}
    case True{} True{} False{} True{} False{} True{} False{} True{}: {==}
    case False{} False{} True{} True{} False{} True{} False{} True{}: {==}
    case True{} False{} True{} True{} False{} True{} False{} True{}: {==}
    case False{} True{} True{} True{} False{} True{} False{} True{}: {==}
    case True{} True{} True{} True{} False{} True{} False{} True{}: {==}
    case False{} False{} False{} False{} True{} True{} False{} True{}: {==}
    case True{} False{} False{} False{} True{} True{} False{} True{}: {==}
    case False{} True{} False{} False{} True{} True{} False{} True{}: {==}
    case True{} True{} False{} False{} True{} True{} False{} True{}: {==}
    case False{} False{} True{} False{} True{} True{} False{} True{}: {==}
    case True{} False{} True{} False{} True{} True{} False{} True{}: {==}
    case False{} True{} True{} False{} True{} True{} False{} True{}: {==}
    case True{} True{} True{} False{} True{} True{} False{} True{}: {==}
    case False{} False{} False{} True{} True{} True{} False{} True{}: {==}
    case True{} False{} False{} True{} True{} True{} False{} True{}: {==}
    case False{} True{} False{} True{} True{} True{} False{} True{}: {==}
    case True{} True{} False{} True{} True{} True{} False{} True{}: {==}
    case False{} False{} True{} True{} True{} True{} False{} True{}: {==}
    case True{} False{} True{} True{} True{} True{} False{} True{}: {==}
    case False{} True{} True{} True{} True{} True{} False{} True{}: {==}
    case True{} True{} True{} True{} True{} True{} False{} True{}: {==}
    case False{} False{} False{} False{} False{} False{} True{} True{}: {==}
    case True{} False{} False{} False{} False{} False{} True{} True{}: {==}
    case False{} True{} False{} False{} False{} False{} True{} True{}: {==}
    case True{} True{} False{} False{} False{} False{} True{} True{}: {==}
    case False{} False{} True{} False{} False{} False{} True{} True{}: {==}
    case True{} False{} True{} False{} False{} False{} True{} True{}: {==}
    case False{} True{} True{} False{} False{} False{} True{} True{}: {==}
    case True{} True{} True{} False{} False{} False{} True{} True{}: {==}
    case False{} False{} False{} True{} False{} False{} True{} True{}: {==}
    case True{} False{} False{} True{} False{} False{} True{} True{}: {==}
    case False{} True{} False{} True{} False{} False{} True{} True{}: {==}
    case True{} True{} False{} True{} False{} False{} True{} True{}: {==}
    case False{} False{} True{} True{} False{} False{} True{} True{}: {==}
    case True{} False{} True{} True{} False{} False{} True{} True{}: {==}
    case False{} True{} True{} True{} False{} False{} True{} True{}: {==}
    case True{} True{} True{} True{} False{} False{} True{} True{}: {==}
    case False{} False{} False{} False{} True{} False{} True{} True{}: {==}
    case True{} False{} False{} False{} True{} False{} True{} True{}: {==}
    case False{} True{} False{} False{} True{} False{} True{} True{}: {==}
    case True{} True{} False{} False{} True{} False{} True{} True{}: {==}
    case False{} False{} True{} False{} True{} False{} True{} True{}: {==}
    case True{} False{} True{} False{} True{} False{} True{} True{}: {==}
    case False{} True{} True{} False{} True{} False{} True{} True{}: {==}
    case True{} True{} True{} False{} True{} False{} True{} True{}: {==}
    case False{} False{} False{} True{} True{} False{} True{} True{}: {==}
    case True{} False{} False{} True{} True{} False{} True{} True{}: {==}
    case False{} True{} False{} True{} True{} False{} True{} True{}: {==}
    case True{} True{} False{} True{} True{} False{} True{} True{}: {==}
    case False{} False{} True{} True{} True{} False{} True{} True{}: {==}
    case True{} False{} True{} True{} True{} False{} True{} True{}: {==}
    case False{} True{} True{} True{} True{} False{} True{} True{}: {==}
    case True{} True{} True{} True{} True{} False{} True{} True{}: {==}
    case False{} False{} False{} False{} False{} True{} True{} True{}: {==}
    case True{} False{} False{} False{} False{} True{} True{} True{}: {==}
    case False{} True{} False{} False{} False{} True{} True{} True{}: {==}
    case True{} True{} False{} False{} False{} True{} True{} True{}: {==}
    case False{} False{} True{} False{} False{} True{} True{} True{}: {==}
    case True{} False{} True{} False{} False{} True{} True{} True{}: {==}
    case False{} True{} True{} False{} False{} True{} True{} True{}: {==}
    case True{} True{} True{} False{} False{} True{} True{} True{}: {==}
    case False{} False{} False{} True{} False{} True{} True{} True{}: {==}
    case True{} False{} False{} True{} False{} True{} True{} True{}: {==}
    case False{} True{} False{} True{} False{} True{} True{} True{}: {==}
    case True{} True{} False{} True{} False{} True{} True{} True{}: {==}
    case False{} False{} True{} True{} False{} True{} True{} True{}: {==}
    case True{} False{} True{} True{} False{} True{} True{} True{}: {==}
    case False{} True{} True{} True{} False{} True{} True{} True{}: {==}
    case True{} True{} True{} True{} False{} True{} True{} True{}: {==}
    case False{} False{} False{} False{} True{} True{} True{} True{}: {==}
    case True{} False{} False{} False{} True{} True{} True{} True{}: {==}
    case False{} True{} False{} False{} True{} True{} True{} True{}: {==}
    case True{} True{} False{} False{} True{} True{} True{} True{}: {==}
    case False{} False{} True{} False{} True{} True{} True{} True{}: {==}
    case True{} False{} True{} False{} True{} True{} True{} True{}: {==}
    case False{} True{} True{} False{} True{} True{} True{} True{}: {==}
    case True{} True{} True{} False{} True{} True{} True{} True{}: {==}
    case False{} False{} False{} True{} True{} True{} True{} True{}: {==}
    case True{} False{} False{} True{} True{} True{} True{} True{}: {==}
    case False{} True{} False{} True{} True{} True{} True{} True{}: {==}
    case True{} True{} False{} True{} True{} True{} True{} True{}: {==}
    case False{} False{} True{} True{} True{} True{} True{} True{}: {==}
    case True{} False{} True{} True{} True{} True{} True{} True{}: {==}
    case False{} True{} True{} True{} True{} True{} True{} True{}: {==}
    case True{} True{} True{} True{} True{} True{} True{} True{}: {==}

law pack_correct:
  for +bits: +List<Bool>
  {I.pack(bits) == S.pack(bits) : +List<U32>}
def pack_correct(bits):
  match bits:
    case Nil{}: {==}
    case Con{b0, Nil{}}:
      Equal.cong(U32, +List<U32>, x => x <> [], I.octet(b0, False{}, False{}, False{}, False{}, False{}, False{}, False{}), S.octet(b0, False{}, False{}, False{}, False{}, False{}, False{}, False{}), octet_correct(b0, False{}, False{}, False{}, False{}, False{}, False{}, False{}))
    case Con{b0, Con{b1, Nil{}}}:
      Equal.cong(U32, +List<U32>, x => x <> [], I.octet(b0, b1, False{}, False{}, False{}, False{}, False{}, False{}), S.octet(b0, b1, False{}, False{}, False{}, False{}, False{}, False{}), octet_correct(b0, b1, False{}, False{}, False{}, False{}, False{}, False{}))
    case Con{b0, Con{b1, Con{b2, Nil{}}}}:
      Equal.cong(U32, +List<U32>, x => x <> [], I.octet(b0, b1, b2, False{}, False{}, False{}, False{}, False{}), S.octet(b0, b1, b2, False{}, False{}, False{}, False{}, False{}), octet_correct(b0, b1, b2, False{}, False{}, False{}, False{}, False{}))
    case Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}}:
      Equal.cong(U32, +List<U32>, x => x <> [], I.octet(b0, b1, b2, b3, False{}, False{}, False{}, False{}), S.octet(b0, b1, b2, b3, False{}, False{}, False{}, False{}), octet_correct(b0, b1, b2, b3, False{}, False{}, False{}, False{}))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}}:
      Equal.cong(U32, +List<U32>, x => x <> [], I.octet(b0, b1, b2, b3, b4, False{}, False{}, False{}), S.octet(b0, b1, b2, b3, b4, False{}, False{}, False{}), octet_correct(b0, b1, b2, b3, b4, False{}, False{}, False{}))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}}:
      Equal.cong(U32, +List<U32>, x => x <> [], I.octet(b0, b1, b2, b3, b4, b5, False{}, False{}), S.octet(b0, b1, b2, b3, b4, b5, False{}, False{}), octet_correct(b0, b1, b2, b3, b4, b5, False{}, False{}))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}}:
      Equal.cong(U32, +List<U32>, x => x <> [], I.octet(b0, b1, b2, b3, b4, b5, b6, False{}), S.octet(b0, b1, b2, b3, b4, b5, b6, False{}), octet_correct(b0, b1, b2, b3, b4, b5, b6, False{}))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, tail}}}}}}}}:
      %pack_correct(tail) : {I.pack(bits) == S.octet(b0, b1, b2, b3, b4, b5, b6, b7) <> _ : +List<U32>}
      Equal.cong(U32, +List<U32>, x => x <> I.pack(tail), I.octet(b0, b1, b2, b3, b4, b5, b6, b7), S.octet(b0, b1, b2, b3, b4, b5, b6, b7), octet_correct(b0, b1, b2, b3, b4, b5, b6, b7))

law pack_bytes:
  for +bits: +List<Bool>
  {P.bytes_domain(I.pack(bits)) == True{} : Bool}
def pack_bytes(bits):
  match bits:
    case Nil{}: {==}
    case Con{b0, Nil{}}: V.and_true(U32.is_lt(I.octet(b0, False{}, False{}, False{}, False{}, False{}, False{}, False{}), 256), P.bytes_domain([]), octet_bound(b0, False{}, False{}, False{}, False{}, False{}, False{}, False{}), {==})
    case Con{b0, Con{b1, Nil{}}}: V.and_true(U32.is_lt(I.octet(b0, b1, False{}, False{}, False{}, False{}, False{}, False{}), 256), P.bytes_domain([]), octet_bound(b0, b1, False{}, False{}, False{}, False{}, False{}, False{}), {==})
    case Con{b0, Con{b1, Con{b2, Nil{}}}}: V.and_true(U32.is_lt(I.octet(b0, b1, b2, False{}, False{}, False{}, False{}, False{}), 256), P.bytes_domain([]), octet_bound(b0, b1, b2, False{}, False{}, False{}, False{}, False{}), {==})
    case Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}}: V.and_true(U32.is_lt(I.octet(b0, b1, b2, b3, False{}, False{}, False{}, False{}), 256), P.bytes_domain([]), octet_bound(b0, b1, b2, b3, False{}, False{}, False{}, False{}), {==})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}}: V.and_true(U32.is_lt(I.octet(b0, b1, b2, b3, b4, False{}, False{}, False{}), 256), P.bytes_domain([]), octet_bound(b0, b1, b2, b3, b4, False{}, False{}, False{}), {==})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}}: V.and_true(U32.is_lt(I.octet(b0, b1, b2, b3, b4, b5, False{}, False{}), 256), P.bytes_domain([]), octet_bound(b0, b1, b2, b3, b4, b5, False{}, False{}), {==})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}}: V.and_true(U32.is_lt(I.octet(b0, b1, b2, b3, b4, b5, b6, False{}), 256), P.bytes_domain([]), octet_bound(b0, b1, b2, b3, b4, b5, b6, False{}), {==})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, tail}}}}}}}}: V.and_true(U32.is_lt(I.octet(b0, b1, b2, b3, b4, b5, b6, b7), 256), P.bytes_domain(I.pack(tail)), octet_bound(b0, b1, b2, b3, b4, b5, b6, b7), pack_bytes(tail))

law pack_length:
  for +bits: +List<Bool>
  {List.length(&2, U32, I.pack(bits)) == S.byte_count(List.length(&2, Bool, bits)) : Nat}
def pack_length(bits):
  match bits:
    case Nil{}: {==}
    case Con{b0, Nil{}}: {==}
    case Con{b0, Con{b1, Nil{}}}: {==}
    case Con{b0, Con{b1, Con{b2, Nil{}}}}: {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}}: {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}}: {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}}: {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}}: {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, tail}}}}}}}}: Equal.cong(Nat, Nat, n => 1n+n, List.length(&2, U32, I.pack(tail)), S.byte_count(List.length(&2, Bool, tail)), pack_length(tail))
