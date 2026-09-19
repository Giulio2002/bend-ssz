import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ../spec/type_legality.bend as Legal
import ./compatibility_bounded.bend as B
import ./compatibility_rank.bend as R
import ./compatibility_stability.bend as Stable
import ./compatibility_monotone.bend as Mono
import ./nat_algebra.bend as A

# No budget premise is required of callers: legality supplies recursive active
# bounds and the actual public formula dominates the checked structural rank.
law public_stable:
  for +a: T.Schema
  for +b: T.Schema
  for +extra: Nat
  for legal_a: Legal.type_legal(a)
  for legal_b: Legal.type_legal(b)
  {I.compatible(a, b) == I.compatible_go(Nat.add(Nat.mul(1024n, 1n+Nat.add(I.weight(a), I.weight(b))), extra), 0, a, b) : Bool}
def public_stable(a, b, extra, legal_a, legal_b):
  Stable.stable(Nat.mul(1024n, 1n+Nat.add(I.weight(a), I.weight(b))), extra, S.Pair{}, a, b, Unit{}, B.legal_bounded(a, False{}, legal_a), B.legal_bounded(b, False{}, legal_b), R.public_pair_budget(a, b))

law options_stable_bounded:
  for +options: T.Schema
  for +extra: Nat
  for +safe: {B.bounded(options) == True{} : Bool}
  {I.compatible_go(Nat.mul(1024n, 1n+I.weight(options)), 1, options, options) == I.compatible_go(Nat.add(Nat.mul(1024n, 1n+I.weight(options)), extra), 1, options, options) : Bool}
def options_stable_bounded(options, extra, safe):
  Stable.stable(Nat.mul(1024n, 1n+I.weight(options)), extra, S.All{}, options, options, Unit{}, safe, safe, R.public_options_budget(options))

law options_stable:
  for +options: T.Schema
  for +extra: Nat
  for legal: Legal.legal(options, True{})
  {I.compatible_go(Nat.mul(1024n, 1n+I.weight(options)), 1, options, options) == I.compatible_go(Nat.add(Nat.mul(1024n, 1n+I.weight(options)), extra), 1, options, options) : Bool}
def options_stable(options, extra, legal):
  options_stable_bounded(options, extra, B.legal_bounded(options, True{}, legal))

# An arbitrary finite successful traversal can be moved to the actual public
# budget. This does not assume that a normative derivation has such a traversal;
# the independent derivation-completeness construction remains separate.
law public_accepts_finite:
  for +a: T.Schema
  for +b: T.Schema
  for +fuel: Nat
  for legal_a: Legal.type_legal(a)
  for legal_b: Legal.type_legal(b)
  for accepted: {I.compatible_go(fuel, 0, a, b) == True{} : Bool}
  {I.compatible(a, b) == True{} : Bool}
def public_accepts_finite(a, b, fuel, legal_a, legal_b, accepted):
  %Equal.sym(Bool, I.compatible(a, b), I.compatible_go(Nat.add(Nat.mul(1024n, 1n+Nat.add(I.weight(a), I.weight(b))), fuel), 0, a, b), public_stable(a, b, fuel, legal_a, legal_b)) : {_ == True{} : Bool}
  %A.add_commute(fuel, Nat.mul(1024n, 1n+Nat.add(I.weight(a), I.weight(b)))) : {I.compatible_go(_, 0, a, b) == True{} : Bool}
  Mono.monotone(fuel, Nat.mul(1024n, 1n+Nat.add(I.weight(a), I.weight(b))), Mono.Pair{}, a, b, accepted)

law options_accept_finite:
  for +options: T.Schema
  for +fuel: Nat
  for legal: Legal.legal(options, True{})
  for accepted: {I.compatible_go(fuel, 1, options, options) == True{} : Bool}
  {I.compatible_go(Nat.mul(1024n, 1n+I.weight(options)), 1, options, options) == True{} : Bool}
def options_accept_finite(options, fuel, legal, accepted):
  %Equal.sym(Bool, I.compatible_go(Nat.mul(1024n, 1n+I.weight(options)), 1, options, options), I.compatible_go(Nat.add(Nat.mul(1024n, 1n+I.weight(options)), fuel), 1, options, options), options_stable(options, fuel, legal)) : {_ == True{} : Bool}
  %A.add_commute(fuel, Nat.mul(1024n, 1n+I.weight(options))) : {I.compatible_go(_, 1, options, options) == True{} : Bool}
  Mono.monotone(fuel, Nat.mul(1024n, 1n+I.weight(options)), Mono.All{}, options, options, accepted)
