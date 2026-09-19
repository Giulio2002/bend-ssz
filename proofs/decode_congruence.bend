import Base
import ../types/schema.bend as T
import ../src/decode.bend as I

law accumulate:
  for +a: Maybe<&2, T.Value>
  for +b: Maybe<&2, T.Value>
  for +acc: T.Value
  for -f: T.Value -> Maybe<&2, T.Value>
  for -g: T.Value -> Maybe<&2, T.Value>
  for same: {a == b : Maybe<&2, T.Value>}
  for next: @+value: T.Value -> {f(value) == g(value) : Maybe<&2, T.Value>}
  {I.accumulate(a, acc, f) == I.accumulate(b, acc, g) : Maybe<&2, T.Value>}
def accumulate(a, b, acc, f, g, same, next):
  match a:
    case None{}:
      %same : {I.accumulate(None{}, acc, f) == I.accumulate(_, acc, g) : Maybe<&2, T.Value>}
      {==}
    case Some{v}:
      %same : {I.accumulate(Some{v}, acc, f) == I.accumulate(_, acc, g) : Maybe<&2, T.Value>}
      next(T.Items{v, acc})

law gate:
  for +ok: Bool
  for -f: Unit -> Maybe<&2, T.Value>
  for -g: Unit -> Maybe<&2, T.Value>
  for next: {ok == True{} : Bool} -> {f(Unit{}) == g(Unit{}) : Maybe<&2, T.Value>}
  {I.gate(ok, f) == I.gate(ok, g) : Maybe<&2, T.Value>}
def gate(ok, f, g, next):
  match ok:
    case False{}: {==}
    case True{}: next({==})

law slices:
  for +result: Maybe<&2, +List<+List<U32>>>
  for -f: +List<+List<U32>> -> Maybe<&2, T.Value>
  for -g: +List<+List<U32>> -> Maybe<&2, T.Value>
  for next: @+parts: +List<+List<U32>> -> @+decoded: {result == Some{parts} : Maybe<&2, +List<+List<U32>>>} -> {f(parts) == g(parts) : Maybe<&2, T.Value>}
  {I.slices(result, f) == I.slices(result, g) : Maybe<&2, T.Value>}
def slices(result, f, g, next):
  match result:
    case None{}: {==}
    case Some{parts}: next(parts, {==})

law count:
  for +result: Maybe<&2, Nat>
  for -f: Nat -> Maybe<&2, T.Value>
  for -g: Nat -> Maybe<&2, T.Value>
  for next: @+n: Nat -> {result == Some{n} : Maybe<&2, Nat>} -> {f(n) == g(n) : Maybe<&2, T.Value>}
  {I.with_count(result, f) == I.with_count(result, g) : Maybe<&2, T.Value>}
def count(result, f, g, next):
  match result:
    case None{}: {==}
    case Some{n}: next(n, {==})

law option:
  for +result: Maybe<&2, T.Schema>
  for -f: T.Schema -> Maybe<&2, T.Value>
  for -g: T.Schema -> Maybe<&2, T.Value>
  for next: @+schema: T.Schema -> @+chosen: {result == Some{schema} : Maybe<&2, T.Schema>} -> {f(schema) == g(schema) : Maybe<&2, T.Value>}
  {I.option(result, f) == I.option(result, g) : Maybe<&2, T.Value>}
def option(result, f, g, next):
  match result:
    case None{}: {==}
    case Some{schema}: next(schema, {==})
