import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/type_legality.bend as Legal
import ../spec/compatibility.bend as S
import ./compatibility_complete.bend as Complete
import ./compatibility_finite.bend as Finite
import ./compatibility_public_budget.bend as Budget

law finite_public:
  for +a: T.Schema
  for +b: T.Schema
  for legal_a: Legal.type_legal(a)
  for legal_b: Legal.type_legal(b)
  for witness: Finite.finite(S.Pair{}, a, b)
  {I.compatible(a, b) == True{} : Bool}
def finite_public(a, b, legal_a, legal_b, witness):
  (+fuel, accepted) = witness
  Budget.public_accepts_finite(a, b, fuel, legal_a, legal_b, accepted)

law public_complete:
  for +a: T.Schema
  for +b: T.Schema
  for legal_a: Legal.type_legal(a)
  for legal_b: Legal.type_legal(b)
  for compatible: S.compatible(a, b)
  {I.compatible(a, b) == True{} : Bool}
def public_complete(a, b, legal_a, legal_b, compatible):
  (+witness, derived) = compatible
  finite_public(a, b, legal_a, legal_b, Complete.complete(witness, S.Pair{}, a, b, derived))

law finite_options:
  for +options: T.Schema
  for legal: Legal.legal(options, True{})
  for witness: Finite.finite(S.All{}, options, options)
  {I.compatible_go(Nat.mul(1024n, 1n+I.weight(options)), 1, options, options) == True{} : Bool}
def finite_options(options, legal, witness):
  (+fuel, accepted) = witness
  Budget.options_accept_finite(options, fuel, legal, accepted)

law options_complete:
  for +options: T.Schema
  for legal: Legal.legal(options, True{})
  for compatible: S.mutually_compatible(options)
  {I.compatible_go(Nat.mul(1024n, 1n+I.weight(options)), 1, options, options) == True{} : Bool}
def options_complete(options, legal, compatible):
  (+witness, derived) = compatible
  finite_options(options, legal, Complete.complete(witness, S.All{}, options, options, derived))
