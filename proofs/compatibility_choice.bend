import Base
import ../types/schema.bend as T
import ../spec/compatibility.bend as S
import ./compatibility_derivation.bend as D

# Sound composition of the normative identity rule with a recursive derivation.
# This helper does not assume that identity implies traversal acceptance.
law sound:
  for +a: T.Schema
  for +b: T.Schema
  for +identity: Bool
  for +recursive: Bool
  for direct: {identity == True{} : Bool} -> {S.identical(a, b) == True{} : Bool}
  for next: @+accepted: {recursive == True{} : Bool} -> D.evidence(S.Pair{}, a, b)
  for accepted: {Bool.or(identity, recursive) == True{} : Bool}
  D.evidence(S.Pair{}, a, b)
def sound(a, b, identity, recursive, direct, next, accepted):
  match identity:
    case True{}: (S.Leaf{}, direct({==}))
    case False{}: next(accepted)

law monotone:
  for +identity: Bool
  for +a: Bool
  for +b: Bool
  for next: @+accepted: {a == True{} : Bool} -> {b == True{} : Bool}
  for accepted: {Bool.or(identity, a) == True{} : Bool}
  {Bool.or(identity, b) == True{} : Bool}
def monotone(identity, a, b, next, accepted):
  match identity:
    case True{}: {==}
    case False{}: next(accepted)

law stable:
  for +identity: Bool
  for +a: Bool
  for +b: Bool
  for same: {a == b : Bool}
  {Bool.or(identity, a) == Bool.or(identity, b) : Bool}
def stable(identity, a, b, same):
  Equal.cong(Bool, Bool, x => Bool.or(identity, x), a, b, same)

law identity_accepts:
  for +identity: Bool
  for +recursive: Bool
  for same: {identity == True{} : Bool}
  {Bool.or(identity, recursive) == True{} : Bool}
def identity_accepts(identity, recursive, same):
  %Equal.sym(Bool, identity, True{}, same) : {Bool.or(_, recursive) == True{} : Bool}
  {==}

law recursive_accepts:
  for +identity: Bool
  for +recursive: Bool
  for accepted: {recursive == True{} : Bool}
  {Bool.or(identity, recursive) == True{} : Bool}
def recursive_accepts(identity, recursive, accepted):
  match identity:
    case True{}: {==}
    case False{}: accepted
