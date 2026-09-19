import Base
import ../types/schema.bend as T
import ../src/decode.bend as I
import ../src/schema.bend as S
import ../src/codec.bend as C
import ../src/layout.bend as L
import ../src/lists.bend as Lists

# Fuel extension preserves the exact successful value. This is a traversal
# lemma only; it does not assert completeness or reinterpret failure as success.
def preserved(a: Maybe<&2, T.Value>, b: Maybe<&2, T.Value>) -> Type:
  match a:
    case None{}: Unit
    case Some{v}: {b == Some{v} : Maybe<&2, T.Value>}

law reflexive:
  for +result: Maybe<&2, T.Value>
  preserved(result, result)
def reflexive(result):
  match result:
    case None{}: Unit{}
    case Some{v}: {==}

law sequence:
  for +a: Maybe<&2, T.Value>
  for +b: Maybe<&2, T.Value>
  for step: preserved(a, b)
  preserved(I.sequence(a), I.sequence(b))
def sequence(a, b, step):
  match a:
    case None{}: Unit{}
    case Some{v}: Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, I.sequence, b, Some{v}, step)

law selected:
  for +selector: U32
  for +a: Maybe<&2, T.Value>
  for +b: Maybe<&2, T.Value>
  for step: preserved(a, b)
  preserved(I.selected(selector, a), I.selected(selector, b))
def selected(selector, a, b, step):
  match a:
    case None{}: Unit{}
    case Some{v}: Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, r => I.selected(selector, r), b, Some{v}, step)

law accumulate:
  for +a: Maybe<&2, T.Value>
  for +b: Maybe<&2, T.Value>
  for +acc: T.Value
  for -f: T.Value -> Maybe<&2, T.Value>
  for -g: T.Value -> Maybe<&2, T.Value>
  for step: preserved(a, b)
  for next: @+value: T.Value -> preserved(f(value), g(value))
  preserved(I.accumulate(a, acc, f), I.accumulate(b, acc, g))
def accumulate(a, b, acc, f, g, step, next):
  match a:
    case None{}: Unit{}
    case Some{v}:
      %Equal.sym(Maybe<&2, T.Value>, b, Some{v}, step) : preserved(f(T.Items{v, acc}), I.accumulate(_, acc, g))
      next(T.Items{v, acc})

law gate:
  for +ok: Bool
  for -f: Unit -> Maybe<&2, T.Value>
  for -g: Unit -> Maybe<&2, T.Value>
  for next: preserved(f(Unit{}), g(Unit{}))
  preserved(I.gate(ok, f), I.gate(ok, g))
def gate(ok, f, g, next):
  match ok:
    case False{}: Unit{}
    case True{}: next

law slices:
  for +result: Maybe<&2, +List<+List<U32>>>
  for -f: +List<+List<U32>> -> Maybe<&2, T.Value>
  for -g: +List<+List<U32>> -> Maybe<&2, T.Value>
  for next: @+parts: +List<+List<U32>> -> preserved(f(parts), g(parts))
  preserved(I.slices(result, f), I.slices(result, g))
def slices(result, f, g, next):
  match result:
    case None{}: Unit{}
    case Some{parts}: next(parts)

law option:
  for +result: Maybe<&2, T.Schema>
  for -f: T.Schema -> Maybe<&2, T.Value>
  for -g: T.Schema -> Maybe<&2, T.Value>
  for next: @+schema: T.Schema -> preserved(f(schema), g(schema))
  preserved(I.option(result, f), I.option(result, g))
def option(result, f, g, next):
  match result:
    case None{}: Unit{}
    case Some{schema}: next(schema)

law count:
  for +result: Maybe<&2, Nat>
  for -f: Nat -> Maybe<&2, T.Value>
  for -g: Nat -> Maybe<&2, T.Value>
  for next: @+n: Nat -> preserved(f(n), g(n))
  preserved(I.with_count(result, f), I.with_count(result, g))
def count(result, f, g, next):
  match result:
    case None{}: Unit{}
    case Some{n}: next(n)

law grow:
  for +fuel: Nat
  for +extra: Nat
  for +schema: T.Schema
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for +acc: T.Value
  preserved(I.decode_go(fuel, schema, xs, parts, acc), I.decode_go(Nat.add(fuel, extra), schema, xs, parts, acc))
def grow(fuel, extra, schema, xs, parts, acc):
  match fuel:
    case 0n: Unit{}
    case 1n+p:
      match schema:
        case T.Boolean{}: reflexive(I.decode_go(1n+p, T.Boolean{}, xs, parts, acc))
        case T.Unsigned{w}: reflexive(I.decode_go(1n+p, T.Unsigned{w}, xs, parts, acc))
        case T.ByteVector{n}: reflexive(I.decode_go(1n+p, T.ByteVector{n}, xs, parts, acc))
        case T.ByteList{n}: reflexive(I.decode_go(1n+p, T.ByteList{n}, xs, parts, acc))
        case T.BitVector{n}: reflexive(I.decode_go(1n+p, T.BitVector{n}, xs, parts, acc))
        case T.BitList{n}: reflexive(I.decode_go(1n+p, T.BitList{n}, xs, parts, acc))
        case T.ProgressiveBits{}: reflexive(I.decode_go(1n+p, T.ProgressiveBits{}, xs, parts, acc))
        case T.Null{}:
          match xs:
            case Nil{}: {==}
            case Con{h, t}: Unit{}
        case T.End{}:
          match parts:
            case Nil{}: {==}
            case Con{h, t}: Unit{}
        case T.Named{name, child}: Unit{}
        case T.Chain{h, t}:
          match parts:
            case Nil{}: Unit{}
            case Con{first, rest}:
              accumulate(I.decode_go(p, h, first, [], T.EmptyItems{}), I.decode_go(Nat.add(p, extra), h, first, [], T.EmptyItems{}), acc, next => I.decode_go(p, t, [], rest, next), next => I.decode_go(Nat.add(p, extra), t, [], rest, next), grow(p, extra, h, first, [], T.EmptyItems{}), next => grow(p, extra, t, [], rest, next))
        case T.Repeat{e}:
          match parts:
            case Nil{}: reflexive(Some{I.reverse_items(acc, T.EmptyItems{})})
            case Con{first, rest}:
              accumulate(I.decode_go(p, e, first, [], T.EmptyItems{}), I.decode_go(Nat.add(p, extra), e, first, [], T.EmptyItems{}), acc, next => I.decode_go(p, T.Repeat{e}, [], rest, next), next => I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], rest, next), grow(p, extra, e, first, [], T.EmptyItems{}), next => grow(p, extra, T.Repeat{e}, [], rest, next))
        # Generated layout/selection branches.
        case T.Vector{e, n}:
          count(I.item_count(S.fixed_size(e), xs), k => I.gate(Nat.is_eq(k, n), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})))), k => I.gate(Nat.is_eq(k, n), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})))), k => gate(Nat.is_eq(k, n), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}))), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}))), slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})), ps => sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}), grow(p, extra, T.Repeat{e}, [], ps, T.EmptyItems{})))))
        case T.ListOf{e, limit}:
          count(I.item_count(S.fixed_size(e), xs), k => I.gate(Nat.is_le(k, limit), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})))), k => I.gate(Nat.is_le(k, limit), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})))), k => gate(Nat.is_le(k, limit), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}))), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}))), slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})), ps => sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}), grow(p, extra, T.Repeat{e}, [], ps, T.EmptyItems{})))))
        case T.ProgressiveList{e}:
          count(I.item_count(S.fixed_size(e), xs), k => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}))), k => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}))), k => slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})), ps => sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}), grow(p, extra, T.Repeat{e}, [], ps, T.EmptyItems{}))))
        case T.Container{names, fields}:
          slices(L.decode(S.widths(fields), xs), ps => I.sequence(I.decode_go(p, fields, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), fields, [], ps, T.EmptyItems{})), ps => sequence(I.decode_go(p, fields, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), fields, [], ps, T.EmptyItems{}), grow(p, extra, fields, [], ps, T.EmptyItems{})))
        case T.ProgressiveContainer{names, fields, active}:
          slices(L.decode(S.widths(fields), xs), ps => I.sequence(I.decode_go(p, fields, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), fields, [], ps, T.EmptyItems{})), ps => sequence(I.decode_go(p, fields, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), fields, [], ps, T.EmptyItems{}), grow(p, extra, fields, [], ps, T.EmptyItems{})))
        case T.Union{options}:
          match xs:
            case Nil{}: Unit{}
            case Con{selector, tail}:
              option(S.get(options, U32.to_nat(selector)), child => I.selected(selector, I.decode_go(p, child, tail, [], T.EmptyItems{})), child => I.selected(selector, I.decode_go(Nat.add(p, extra), child, tail, [], T.EmptyItems{})), child => selected(selector, I.decode_go(p, child, tail, [], T.EmptyItems{}), I.decode_go(Nat.add(p, extra), child, tail, [], T.EmptyItems{}), grow(p, extra, child, tail, [], T.EmptyItems{})))
        case T.CompatibleUnion{selectors, options}:
          match xs:
            case Nil{}: Unit{}
            case Con{selector, tail}:
              option(C.selected_schema(selectors, options, selector), child => I.selected(selector, I.decode_go(p, child, tail, [], T.EmptyItems{})), child => I.selected(selector, I.decode_go(Nat.add(p, extra), child, tail, [], T.EmptyItems{})), child => selected(selector, I.decode_go(p, child, tail, [], T.EmptyItems{}), I.decode_go(Nat.add(p, extra), child, tail, [], T.EmptyItems{}), grow(p, extra, child, tail, [], T.EmptyItems{})))

# Successful raw traversals retain precisely the same value, even for malformed
# input schemas. Public completeness needs the separate sufficient-budget proof.
law successful_extension:
  for +fuel: Nat
  for +extra: Nat
  for +schema: T.Schema
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for +acc: T.Value
  for +value: T.Value
  for success: {I.decode_go(fuel, schema, xs, parts, acc) == Some{value} : Maybe<&2, T.Value>}
  {I.decode_go(Nat.add(fuel, extra), schema, xs, parts, acc) == Some{value} : Maybe<&2, T.Value>}
def successful_extension(fuel, extra, schema, xs, parts, acc, value, success):
  %success : preserved(_, I.decode_go(Nat.add(fuel, extra), schema, xs, parts, acc))
  grow(fuel, extra, schema, xs, parts, acc)
