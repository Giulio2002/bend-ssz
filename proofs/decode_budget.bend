import Base
import ../types/schema.bend as T
import ../src/decode.bend as I
import ../src/schema.bend as S
import ../src/lists.bend as Lists
import ./decode_stability.bend as Stable
import ./decode_monotone.bend as Mono
import ./nat_algebra.bend as A

# A finite constructor-level inverse can choose any traversal witness. This law
# moves it to the actual public budget, discharging fuel sufficiency completely.
law accepts_finite:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +value: T.Value
  for +fuel: Nat
  for legal: {S.valid(schema) == True{} : Bool}
  for accepted: {I.decode_go(fuel, schema, xs, [], T.EmptyItems{}) == Some{value} : Maybe<&2, T.Value>}
  {I.decode_go(Nat.mul(2n+S.weight(schema), 2n+Lists.length(U32, xs)), schema, xs, [], T.EmptyItems{}) == Some{value} : Maybe<&2, T.Value>}
def accepts_finite(schema, xs, value, fuel, legal, accepted):
  %Equal.sym(Maybe<&2, T.Value>, I.decode_go(Nat.mul(2n+S.weight(schema), 2n+Lists.length(U32, xs)), schema, xs, [], T.EmptyItems{}), I.decode_go(Nat.add(Nat.mul(2n+S.weight(schema), 2n+Lists.length(U32, xs)), fuel), schema, xs, [], T.EmptyItems{}), Stable.public_budget(schema, xs, fuel, legal)) : {_ == Some{value} : Maybe<&2, T.Value>}
  %A.add_commute(fuel, Nat.mul(2n+S.weight(schema), 2n+Lists.length(U32, xs))) : {I.decode_go(_, schema, xs, [], T.EmptyItems{}) == Some{value} : Maybe<&2, T.Value>}
  Mono.successful_extension(fuel, Nat.mul(2n+S.weight(schema), 2n+Lists.length(U32, xs)), schema, xs, [], T.EmptyItems{}, value, accepted)

def unwrap(result: Maybe<&2, T.Value>) -> T.Value:
  match result:
    case None{}: T.NullValue{}
    case Some{value}: value

# Exact raw outcomes are unique across arbitrary successful finite budgets,
# even before public schema validation and the canonical re-encoding guard.
law finite_unique:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for +acc: T.Value
  for +a: T.Value
  for +b: T.Value
  for +fuel_a: Nat
  for +fuel_b: Nat
  for first: {I.decode_go(fuel_a, schema, xs, parts, acc) == Some{a} : Maybe<&2, T.Value>}
  for second: {I.decode_go(fuel_b, schema, xs, parts, acc) == Some{b} : Maybe<&2, T.Value>}
  {a == b : T.Value}
def finite_unique(schema, xs, parts, acc, a, b, fuel_a, fuel_b, first, second):
  Equal.cong(Maybe<&2, T.Value>, T.Value, unwrap, Some{a}, Some{b},
    Equal.trans(Maybe<&2, T.Value>, Some{a}, I.decode_go(Nat.add(fuel_a, fuel_b), schema, xs, parts, acc), Some{b},
      Equal.sym(Maybe<&2, T.Value>, I.decode_go(Nat.add(fuel_a, fuel_b), schema, xs, parts, acc), Some{a}, Mono.successful_extension(fuel_a, fuel_b, schema, xs, parts, acc, a, first)),
      %A.add_commute(fuel_b, fuel_a) : {I.decode_go(_, schema, xs, parts, acc) == Some{b} : Maybe<&2, T.Value>}
      Mono.successful_extension(fuel_b, fuel_a, schema, xs, parts, acc, b, second)))
