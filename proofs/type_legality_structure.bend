import Base
import ../types/schema.bend as T
import ../spec/type_legality.bend as S
import ../spec/schema_forest.bend as F
import ./primitive_invariants.bend as V

def forest_condition(forest: Bool, schema: T.Schema) -> Type:
  match forest:
    case False{}: Unit
    case True{}: {F.finite(schema) == True{} : Bool}

def structure(+schema: T.Schema, forest: Bool) -> Type:
  {F.well_formed(schema) == True{} : Bool} & forest_condition(forest, schema)

law public_context:
  for +forest: Bool
  for +schema: T.Schema
  for context: {forest == False{} : Bool}
  forest_condition(forest, schema)
def public_context(forest, schema, context):
  %Equal.sym(Bool, forest, False{}, context) : forest_condition(_, schema)
  Unit{}

law forest_context:
  for +forest: Bool
  for +schema: T.Schema
  for context: {forest == True{} : Bool}
  for finite: {F.finite(schema) == True{} : Bool}
  forest_condition(forest, schema)
def forest_context(forest, schema, context, finite):
  %Equal.sym(Bool, forest, True{}, context) : forest_condition(_, schema)
  finite

law assembled_fields:
  for +head: T.Schema
  for +tail: T.Schema
  for +head_wf: {F.well_formed(head) == True{} : Bool}
  for +tail_wf: {F.well_formed(tail) == True{} : Bool}
  for +tail_finite: {F.finite(tail) == True{} : Bool}
  {Bool.and(F.finite(T.Chain{head, tail}), F.well_formed(T.Chain{head, tail})) == True{} : Bool}
def assembled_fields(head, tail, head_wf, tail_wf, tail_finite):
  V.and_true(F.finite(tail), Bool.and(F.well_formed(head), Bool.and(F.finite(tail), F.well_formed(tail))), tail_finite, V.and_true(F.well_formed(head), Bool.and(F.finite(tail), F.well_formed(tail)), head_wf, V.and_true(F.finite(tail), F.well_formed(tail), tail_finite, tail_wf)))

law well_formed_of:
  for +schema: T.Schema
  for +forest: Bool
  for evidence: structure(schema, forest)
  {F.well_formed(schema) == True{} : Bool}
def well_formed_of(schema, forest, evidence):
  (well_formed, context) = evidence
  well_formed

law fields_body:
  for +fields: T.Schema
  for evidence: structure(fields, True{})
  {Bool.and(F.finite(fields), F.well_formed(fields)) == True{} : Bool}
def fields_body(fields, evidence):
  (well_formed, finite) = evidence
  V.and_true(F.finite(fields), F.well_formed(fields), finite, well_formed)

law union_body:
  for +head: T.Schema
  for +tail: T.Schema
  for head_wf: {F.well_formed(head) == True{} : Bool}
  for evidence: structure(tail, True{})
  {Bool.and(F.finite(T.Chain{head, tail}), F.well_formed(T.Chain{head, tail})) == True{} : Bool}
def union_body(head, tail, head_wf, evidence):
  (tail_wf, finite) = evidence
  assembled_fields(head, tail, head_wf, tail_wf, finite)

law chain_join:
  for +forest: Bool
  for +head: T.Schema
  for +tail: T.Schema
  for context: {forest == True{} : Bool}
  for head_wf: {F.well_formed(head) == True{} : Bool}
  for tail_wf: {F.well_formed(tail) == True{} : Bool}
  for +finite: {F.finite(tail) == True{} : Bool}
  structure(T.Chain{head, tail}, forest)
def chain_join(forest, head, tail, context, head_wf, tail_wf, finite):
  (V.and_true(F.well_formed(head), Bool.and(F.finite(tail), F.well_formed(tail)), head_wf, V.and_true(F.finite(tail), F.well_formed(tail), finite, tail_wf)), forest_context(forest, T.Chain{head, tail}, context, finite))

law chain_body:
  for +forest: Bool
  for +head: T.Schema
  for +tail: T.Schema
  for context: {forest == True{} : Bool}
  for head_wf: {F.well_formed(head) == True{} : Bool}
  for evidence: structure(tail, True{})
  structure(T.Chain{head, tail}, forest)
def chain_body(forest, head, tail, context, head_wf, evidence):
  (tail_wf, finite) = evidence
  chain_join(forest, head, tail, context, head_wf, tail_wf, finite)

# Generated structural induction; compatibility witnesses are not assumed away.
law legal_structure:
  for +schema: T.Schema
  for +forest: Bool
  for legal: S.legal(schema, forest)
  structure(schema, forest)
def legal_structure(schema, forest, legal):
  match schema:
    case T.Boolean{}:
      ({==}, public_context(forest, T.Boolean{}, legal))
    case T.Unsigned{+s0}:
      ({==}, public_context(forest, T.Unsigned{s0}, legal))
    case T.ByteVector{+s0}:
      (context, positive) = legal
      ({==}, public_context(forest, T.ByteVector{s0}, context))
    case T.ByteList{+s0}:
      ({==}, public_context(forest, T.ByteList{s0}, legal))
    case T.BitVector{+s0}:
      (context, positive) = legal
      ({==}, public_context(forest, T.BitVector{s0}, context))
    case T.BitList{+s0}:
      ({==}, public_context(forest, T.BitList{s0}, legal))
    case T.Vector{+s0, +s1}:
      (context, (positive, element)) = legal
      (well_formed_of(s0, False{}, legal_structure(s0, False{}, element)), public_context(forest, T.Vector{s0, s1}, context))
    case T.ListOf{+s0, +s1}:
      (context, element) = legal
      (well_formed_of(s0, False{}, legal_structure(s0, False{}, element)), public_context(forest, T.ListOf{s0, s1}, context))
    case T.Container{+s0, +s1}:
      (context, (names, fields)) = legal
      (fields_body(s1, legal_structure(s1, True{}, fields)), public_context(forest, T.Container{s0, s1}, context))
    case T.Union{s0}:
      match s0:
        case T.Boolean{}:
          Empty.absurd(structure(T.Union{T.Boolean{}}, forest), legal)
        case T.Unsigned{+o0}:
          Empty.absurd(structure(T.Union{T.Unsigned{o0}}, forest), legal)
        case T.ByteVector{+o0}:
          Empty.absurd(structure(T.Union{T.ByteVector{o0}}, forest), legal)
        case T.ByteList{+o0}:
          Empty.absurd(structure(T.Union{T.ByteList{o0}}, forest), legal)
        case T.BitVector{+o0}:
          Empty.absurd(structure(T.Union{T.BitVector{o0}}, forest), legal)
        case T.BitList{+o0}:
          Empty.absurd(structure(T.Union{T.BitList{o0}}, forest), legal)
        case T.Vector{+o0, +o1}:
          Empty.absurd(structure(T.Union{T.Vector{o0, o1}}, forest), legal)
        case T.ListOf{+o0, +o1}:
          Empty.absurd(structure(T.Union{T.ListOf{o0, o1}}, forest), legal)
        case T.Container{+o0, +o1}:
          Empty.absurd(structure(T.Union{T.Container{o0, o1}}, forest), legal)
        case T.Union{+o0}:
          Empty.absurd(structure(T.Union{T.Union{o0}}, forest), legal)
        case T.Null{}:
          Empty.absurd(structure(T.Union{T.Null{}}, forest), legal)
        case T.Chain{o0, +o1}:
          match o0:
            case T.Boolean{}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.Boolean{}, o1, well_formed_of(T.Boolean{}, False{}, legal_structure(T.Boolean{}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Boolean{}, o1}}, context))
            case T.Unsigned{+h0}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.Unsigned{h0}, o1, well_formed_of(T.Unsigned{h0}, False{}, legal_structure(T.Unsigned{h0}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Unsigned{h0}, o1}}, context))
            case T.ByteVector{+h0}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.ByteVector{h0}, o1, well_formed_of(T.ByteVector{h0}, False{}, legal_structure(T.ByteVector{h0}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.ByteVector{h0}, o1}}, context))
            case T.ByteList{+h0}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.ByteList{h0}, o1, well_formed_of(T.ByteList{h0}, False{}, legal_structure(T.ByteList{h0}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.ByteList{h0}, o1}}, context))
            case T.BitVector{+h0}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.BitVector{h0}, o1, well_formed_of(T.BitVector{h0}, False{}, legal_structure(T.BitVector{h0}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.BitVector{h0}, o1}}, context))
            case T.BitList{+h0}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.BitList{h0}, o1, well_formed_of(T.BitList{h0}, False{}, legal_structure(T.BitList{h0}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.BitList{h0}, o1}}, context))
            case T.Vector{+h0, +h1}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.Vector{h0, h1}, o1, well_formed_of(T.Vector{h0, h1}, False{}, legal_structure(T.Vector{h0, h1}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Vector{h0, h1}, o1}}, context))
            case T.ListOf{+h0, +h1}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.ListOf{h0, h1}, o1, well_formed_of(T.ListOf{h0, h1}, False{}, legal_structure(T.ListOf{h0, h1}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.ListOf{h0, h1}, o1}}, context))
            case T.Container{+h0, +h1}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.Container{h0, h1}, o1, well_formed_of(T.Container{h0, h1}, False{}, legal_structure(T.Container{h0, h1}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Container{h0, h1}, o1}}, context))
            case T.Union{+h0}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.Union{h0}, o1, well_formed_of(T.Union{h0}, False{}, legal_structure(T.Union{h0}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Union{h0}, o1}}, context))
            case T.Null{}:
              (context, (positive, (limit, tail))) = legal
              (union_body(T.Null{}, o1, {==}, legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Null{}, o1}}, context))
            case T.Chain{+h0, +h1}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.Chain{h0, h1}, o1, well_formed_of(T.Chain{h0, h1}, False{}, legal_structure(T.Chain{h0, h1}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Chain{h0, h1}, o1}}, context))
            case T.End{}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.End{}, o1, well_formed_of(T.End{}, False{}, legal_structure(T.End{}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.End{}, o1}}, context))
            case T.Repeat{+h0}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.Repeat{h0}, o1, well_formed_of(T.Repeat{h0}, False{}, legal_structure(T.Repeat{h0}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Repeat{h0}, o1}}, context))
            case T.Named{+h0, +h1}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.Named{h0, h1}, o1, well_formed_of(T.Named{h0, h1}, False{}, legal_structure(T.Named{h0, h1}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.Named{h0, h1}, o1}}, context))
            case T.ProgressiveList{+h0}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.ProgressiveList{h0}, o1, well_formed_of(T.ProgressiveList{h0}, False{}, legal_structure(T.ProgressiveList{h0}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.ProgressiveList{h0}, o1}}, context))
            case T.ProgressiveBits{}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.ProgressiveBits{}, o1, well_formed_of(T.ProgressiveBits{}, False{}, legal_structure(T.ProgressiveBits{}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.ProgressiveBits{}, o1}}, context))
            case T.ProgressiveContainer{+h0, +h1, +h2}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.ProgressiveContainer{h0, h1, h2}, o1, well_formed_of(T.ProgressiveContainer{h0, h1, h2}, False{}, legal_structure(T.ProgressiveContainer{h0, h1, h2}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.ProgressiveContainer{h0, h1, h2}, o1}}, context))
            case T.CompatibleUnion{+h0, +h1}:
              (context, (limit, (head, tail))) = legal
              (union_body(T.CompatibleUnion{h0, h1}, o1, well_formed_of(T.CompatibleUnion{h0, h1}, False{}, legal_structure(T.CompatibleUnion{h0, h1}, False{}, head)), legal_structure(o1, True{}, tail)), public_context(forest, T.Union{T.Chain{T.CompatibleUnion{h0, h1}, o1}}, context))
        case T.End{}:
          Empty.absurd(structure(T.Union{T.End{}}, forest), legal)
        case T.Repeat{+o0}:
          Empty.absurd(structure(T.Union{T.Repeat{o0}}, forest), legal)
        case T.Named{+o0, +o1}:
          Empty.absurd(structure(T.Union{T.Named{o0, o1}}, forest), legal)
        case T.ProgressiveList{+o0}:
          Empty.absurd(structure(T.Union{T.ProgressiveList{o0}}, forest), legal)
        case T.ProgressiveBits{}:
          Empty.absurd(structure(T.Union{T.ProgressiveBits{}}, forest), legal)
        case T.ProgressiveContainer{+o0, +o1, +o2}:
          Empty.absurd(structure(T.Union{T.ProgressiveContainer{o0, o1, o2}}, forest), legal)
        case T.CompatibleUnion{+o0, +o1}:
          Empty.absurd(structure(T.Union{T.CompatibleUnion{o0, o1}}, forest), legal)
    case T.Null{}:
      Empty.absurd(structure(T.Null{}, forest), legal)
    case T.Chain{+s0, +s1}:
      (context, (head, tail)) = legal
      chain_body(forest, s0, s1, context, well_formed_of(s0, False{}, legal_structure(s0, False{}, head)), legal_structure(s1, True{}, tail))
    case T.End{}:
      ({==}, forest_context(forest, T.End{}, legal, {==}))
    case T.Repeat{+s0}:
      Empty.absurd(structure(T.Repeat{s0}, forest), legal)
    case T.Named{+s0, +s1}:
      Empty.absurd(structure(T.Named{s0, s1}, forest), legal)
    case T.ProgressiveList{+s0}:
      (context, element) = legal
      (well_formed_of(s0, False{}, legal_structure(s0, False{}, element)), public_context(forest, T.ProgressiveList{s0}, context))
    case T.ProgressiveBits{}:
      ({==}, public_context(forest, T.ProgressiveBits{}, legal))
    case T.ProgressiveContainer{+s0, +s1, +s2}:
      (context, (names, (fields, (limit, (last, count))))) = legal
      (fields_body(s1, legal_structure(s1, True{}, fields)), public_context(forest, T.ProgressiveContainer{s0, s1, s2}, context))
    case T.CompatibleUnion{+s0, +s1}:
      (context, (positive, (count, (selectors, (fields, compatible))))) = legal
      (fields_body(s1, legal_structure(s1, True{}, fields)), public_context(forest, T.CompatibleUnion{s0, s1}, context))

law public_legal_well_formed:
  for +schema: T.Schema
  for legal: S.type_legal(schema)
  {F.well_formed(schema) == True{} : Bool}
def public_legal_well_formed(schema, legal):
  well_formed_of(schema, False{}, legal_structure(schema, False{}, legal))
