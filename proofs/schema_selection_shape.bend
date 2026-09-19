import Base
import ../types/schema.bend as T
import ../src/schema.bend as S
import ../src/codec.bend as C
import ../spec/schema_forest.bend as F
import ./primitive_invariants.bend as V

def result_shape(result: Maybe<&2, T.Schema>) -> Type:
  match result:
    case None{}: Unit
    case Some{schema}: {F.well_formed(schema) == True{} : Bool}

law get:
  for +schema: T.Schema
  for +index: Nat
  for +shape: {F.well_formed(schema) == True{} : Bool}
  result_shape(S.get(schema, index))
def get(schema, index, shape):
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
        case 0n: V.and_left(F.well_formed(h), Bool.and(F.finite(t), F.well_formed(t)), shape)
        case 1n+p: get(t, p, V.and_right(F.finite(t), F.well_formed(t), V.and_right(F.well_formed(h), Bool.and(F.finite(t), F.well_formed(t)), shape)))
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
  for -next: Unit -> Maybe<&2, T.Schema>
  for item: {F.well_formed(schema) == True{} : Bool}
  for rest: result_shape(next(Unit{}))
  result_shape(C.select_option(ok, schema, next))
def select(ok, schema, next, item, rest):
  match ok:
    case False{}: rest
    case True{}: item

law selected:
  for +ids: +List<U32>
  for +options: T.Schema
  for +selector: U32
  for +shape: {F.well_formed(options) == True{} : Bool}
  result_shape(C.selected_schema(ids, options, selector))
def selected(ids, options, selector, shape):
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
      select(U32.is_eq(id, selector), h, u => C.selected_schema(ids_tail, t, selector), V.and_left(F.well_formed(h), Bool.and(F.finite(t), F.well_formed(t)), shape), selected(ids_tail, t, selector, V.and_right(F.finite(t), F.well_formed(t), V.and_right(F.well_formed(h), Bool.and(F.finite(t), F.well_formed(t)), shape))))
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
