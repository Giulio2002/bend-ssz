import Base
import ../types/schema.bend as T
import ../src/schema.bend as S
import ../src/codec.bend as C
import ./nat_order.bend as O

def bound(maximum: Nat, result: Maybe<&2, T.Schema>) -> Type:
  match result:
    case None{}: Unit
    case Some{schema}: {Nat.is_le(S.weight(schema), maximum) == True{} : Bool}

law weaken:
  for +a: Nat
  for +b: Nat
  for +result: Maybe<&2, T.Schema>
  for limit: {Nat.is_le(a, b) == True{} : Bool}
  for child: bound(a, result)
  bound(b, result)
def weaken(a, b, result, limit, child):
  match result:
    case None{}: Unit{}
    case Some{schema}: O.transitive(S.weight(schema), a, b, child, limit)

law head:
  for +h: T.Schema
  for +t: T.Schema
  {Nat.is_le(S.weight(h), S.weight(T.Chain{h, t})) == True{} : Bool}
def head(h, t):
  O.step_right(S.weight(h), Nat.add(S.weight(h), S.weight(t)), O.below_sum(S.weight(h), S.weight(t)))

law tail:
  for +h: T.Schema
  for +t: T.Schema
  {Nat.is_le(S.weight(t), S.weight(T.Chain{h, t})) == True{} : Bool}
def tail(h, t):
  O.step_right(S.weight(t), Nat.add(S.weight(h), S.weight(t)), O.left_below_sum(S.weight(h), S.weight(t)))

law get:
  for +schema: T.Schema
  for +index: Nat
  bound(S.weight(schema), S.get(schema, index))
def get(schema, index):
  match schema:
    case T.Boolean{}: Unit{}
    case T.Unsigned{x0}: Unit{}
    case T.ByteVector{x0}: Unit{}
    case T.ByteList{x0}: Unit{}
    case T.BitVector{x0}: Unit{}
    case T.BitList{x0}: Unit{}
    case T.Vector{x0, x1}: Unit{}
    case T.ListOf{x0, x1}: Unit{}
    case T.Container{x0, x1}: Unit{}
    case T.Union{x0}: Unit{}
    case T.Null{}: Unit{}
    case T.Chain{h, t}:
      match index:
        case 0n: head(h, t)
        case 1n+p: weaken(S.weight(t), S.weight(T.Chain{h, t}), S.get(t, p), tail(h, t), get(t, p))
    case T.End{}: Unit{}
    case T.Repeat{x0}: Unit{}
    case T.Named{x0, x1}: Unit{}
    case T.ProgressiveList{x0}: Unit{}
    case T.ProgressiveBits{}: Unit{}
    case T.ProgressiveContainer{x0, x1, x2}: Unit{}
    case T.CompatibleUnion{x0, x1}: Unit{}

law select:
  for +ok: Bool
  for +schema: T.Schema
  for +maximum: Nat
  for -next: Unit -> Maybe<&2, T.Schema>
  for item: {Nat.is_le(S.weight(schema), maximum) == True{} : Bool}
  for rest: bound(maximum, next(Unit{}))
  bound(maximum, C.select_option(ok, schema, next))
def select(ok, schema, maximum, next, item, rest):
  match ok:
    case False{}: rest
    case True{}: item

law selected:
  for +ids: +List<U32>
  for +options: T.Schema
  for +selector: U32
  bound(S.weight(options), C.selected_schema(ids, options, selector))
def selected(ids, options, selector):
  match ids options:
    case Nil{} T.Boolean{}: Unit{}
    case Con{id, ids_tail} T.Boolean{}: Unit{}
    case Nil{} T.Unsigned{x0}: Unit{}
    case Con{id, ids_tail} T.Unsigned{x0}: Unit{}
    case Nil{} T.ByteVector{x0}: Unit{}
    case Con{id, ids_tail} T.ByteVector{x0}: Unit{}
    case Nil{} T.ByteList{x0}: Unit{}
    case Con{id, ids_tail} T.ByteList{x0}: Unit{}
    case Nil{} T.BitVector{x0}: Unit{}
    case Con{id, ids_tail} T.BitVector{x0}: Unit{}
    case Nil{} T.BitList{x0}: Unit{}
    case Con{id, ids_tail} T.BitList{x0}: Unit{}
    case Nil{} T.Vector{x0, x1}: Unit{}
    case Con{id, ids_tail} T.Vector{x0, x1}: Unit{}
    case Nil{} T.ListOf{x0, x1}: Unit{}
    case Con{id, ids_tail} T.ListOf{x0, x1}: Unit{}
    case Nil{} T.Container{x0, x1}: Unit{}
    case Con{id, ids_tail} T.Container{x0, x1}: Unit{}
    case Nil{} T.Union{x0}: Unit{}
    case Con{id, ids_tail} T.Union{x0}: Unit{}
    case Nil{} T.Null{}: Unit{}
    case Con{id, ids_tail} T.Null{}: Unit{}
    case Nil{} T.Chain{x0, x1}: Unit{}
    case Con{id, ids_tail} T.Chain{h, t}:
      select(U32.is_eq(id, selector), h, S.weight(T.Chain{h, t}), u => C.selected_schema(ids_tail, t, selector), head(h, t), weaken(S.weight(t), S.weight(T.Chain{h, t}), C.selected_schema(ids_tail, t, selector), tail(h, t), selected(ids_tail, t, selector)))
    case Nil{} T.End{}: Unit{}
    case Con{id, ids_tail} T.End{}: Unit{}
    case Nil{} T.Repeat{x0}: Unit{}
    case Con{id, ids_tail} T.Repeat{x0}: Unit{}
    case Nil{} T.Named{x0, x1}: Unit{}
    case Con{id, ids_tail} T.Named{x0, x1}: Unit{}
    case Nil{} T.ProgressiveList{x0}: Unit{}
    case Con{id, ids_tail} T.ProgressiveList{x0}: Unit{}
    case Nil{} T.ProgressiveBits{}: Unit{}
    case Con{id, ids_tail} T.ProgressiveBits{}: Unit{}
    case Nil{} T.ProgressiveContainer{x0, x1, x2}: Unit{}
    case Con{id, ids_tail} T.ProgressiveContainer{x0, x1, x2}: Unit{}
    case Nil{} T.CompatibleUnion{x0, x1}: Unit{}
    case Con{id, ids_tail} T.CompatibleUnion{x0, x1}: Unit{}
