import Base
import ../types/schema.bend as T
import ../spec/type_legality.bend as S
import ../spec/compatibility.bend as C
import ../src/schema.bend as I
import ./identity_equivalence.bend as E
import ./primitive_invariants.bend as V

law legal_unnamed:
  for +schema: T.Schema
  for +forest: Bool
  for legal: S.legal(schema, forest)
  {E.unnamed(schema) == True{} : Bool}
def legal_unnamed(schema, forest, legal):
  match schema:
    case T.Boolean{}:
      {==}
    case T.Unsigned{x0}:
      {==}
    case T.ByteVector{x0}:
      {==}
    case T.ByteList{x0}:
      {==}
    case T.BitVector{x0}:
      {==}
    case T.BitList{x0}:
      {==}
    case T.Vector{x0, x1}:
      (context, positive, child) = legal
      legal_unnamed(x0, False{}, child)
    case T.ListOf{x0, x1}:
      (context, child) = legal
      legal_unnamed(x0, False{}, child)
    case T.Container{x0, x1}:
      (context, names, child) = legal
      legal_unnamed(x1, True{}, child)
    case T.Null{}:
      Empty.absurd({E.unnamed(T.Null{}) == True{} : Bool}, legal)
    case T.Chain{x0, x1}:
      (context, head, tail) = legal
      V.and_true(E.unnamed(x0), E.unnamed(x1), legal_unnamed(x0, False{}, head), legal_unnamed(x1, True{}, tail))
    case T.End{}:
      {==}
    case T.Repeat{x0}:
      Empty.absurd({E.unnamed(T.Repeat{x0}) == True{} : Bool}, legal)
    case T.Named{x0, x1}:
      Empty.absurd({E.unnamed(T.Named{x0, x1}) == True{} : Bool}, legal)
    case T.ProgressiveList{x0}:
      (context, child) = legal
      legal_unnamed(x0, False{}, child)
    case T.ProgressiveBits{}:
      {==}
    case T.ProgressiveContainer{x0, x1, x2}:
      (context, names, child, limit, last, count) = legal
      legal_unnamed(x1, True{}, child)
    case T.CompatibleUnion{x0, x1}:
      (context, nonempty, count, selectors, child, compatibility) = legal
      legal_unnamed(x1, True{}, child)
    case T.Union{T.Boolean{}}: Empty.absurd({E.unnamed(T.Union{T.Boolean{}}) == True{} : Bool}, legal)
    case T.Union{T.Unsigned{x0}}: Empty.absurd({E.unnamed(T.Union{T.Unsigned{x0}}) == True{} : Bool}, legal)
    case T.Union{T.ByteVector{x0}}: Empty.absurd({E.unnamed(T.Union{T.ByteVector{x0}}) == True{} : Bool}, legal)
    case T.Union{T.ByteList{x0}}: Empty.absurd({E.unnamed(T.Union{T.ByteList{x0}}) == True{} : Bool}, legal)
    case T.Union{T.BitVector{x0}}: Empty.absurd({E.unnamed(T.Union{T.BitVector{x0}}) == True{} : Bool}, legal)
    case T.Union{T.BitList{x0}}: Empty.absurd({E.unnamed(T.Union{T.BitList{x0}}) == True{} : Bool}, legal)
    case T.Union{T.Vector{x0, x1}}: Empty.absurd({E.unnamed(T.Union{T.Vector{x0, x1}}) == True{} : Bool}, legal)
    case T.Union{T.ListOf{x0, x1}}: Empty.absurd({E.unnamed(T.Union{T.ListOf{x0, x1}}) == True{} : Bool}, legal)
    case T.Union{T.Container{x0, x1}}: Empty.absurd({E.unnamed(T.Union{T.Container{x0, x1}}) == True{} : Bool}, legal)
    case T.Union{T.Union{x0}}: Empty.absurd({E.unnamed(T.Union{T.Union{x0}}) == True{} : Bool}, legal)
    case T.Union{T.Null{}}: Empty.absurd({E.unnamed(T.Union{T.Null{}}) == True{} : Bool}, legal)
    case T.Union{T.Chain{T.Boolean{}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.Boolean{}), E.unnamed(tail), legal_unnamed(T.Boolean{}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.Unsigned{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.Unsigned{h0}), E.unnamed(tail), legal_unnamed(T.Unsigned{h0}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.ByteVector{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.ByteVector{h0}), E.unnamed(tail), legal_unnamed(T.ByteVector{h0}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.ByteList{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.ByteList{h0}), E.unnamed(tail), legal_unnamed(T.ByteList{h0}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.BitVector{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.BitVector{h0}), E.unnamed(tail), legal_unnamed(T.BitVector{h0}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.BitList{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.BitList{h0}), E.unnamed(tail), legal_unnamed(T.BitList{h0}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.Vector{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.Vector{h0, h1}), E.unnamed(tail), legal_unnamed(T.Vector{h0, h1}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.ListOf{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.ListOf{h0, h1}), E.unnamed(tail), legal_unnamed(T.ListOf{h0, h1}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.Container{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.Container{h0, h1}), E.unnamed(tail), legal_unnamed(T.Container{h0, h1}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.Union{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.Union{h0}), E.unnamed(tail), legal_unnamed(T.Union{h0}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.Null{}, tail}}:
      (context, nonempty, limit, rest) = legal
      legal_unnamed(tail, True{}, rest)
    case T.Union{T.Chain{T.Chain{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.Chain{h0, h1}), E.unnamed(tail), legal_unnamed(T.Chain{h0, h1}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.End{}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.End{}), E.unnamed(tail), legal_unnamed(T.End{}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.Repeat{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.Repeat{h0}), E.unnamed(tail), legal_unnamed(T.Repeat{h0}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.Named{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.Named{h0, h1}), E.unnamed(tail), legal_unnamed(T.Named{h0, h1}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.ProgressiveList{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.ProgressiveList{h0}), E.unnamed(tail), legal_unnamed(T.ProgressiveList{h0}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.ProgressiveBits{}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.ProgressiveBits{}), E.unnamed(tail), legal_unnamed(T.ProgressiveBits{}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.ProgressiveContainer{h0, h1, h2}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.ProgressiveContainer{h0, h1, h2}), E.unnamed(tail), legal_unnamed(T.ProgressiveContainer{h0, h1, h2}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.Chain{T.CompatibleUnion{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(E.unnamed(T.CompatibleUnion{h0, h1}), E.unnamed(tail), legal_unnamed(T.CompatibleUnion{h0, h1}, False{}, child), legal_unnamed(tail, True{}, rest))
    case T.Union{T.End{}}: Empty.absurd({E.unnamed(T.Union{T.End{}}) == True{} : Bool}, legal)
    case T.Union{T.Repeat{x0}}: Empty.absurd({E.unnamed(T.Union{T.Repeat{x0}}) == True{} : Bool}, legal)
    case T.Union{T.Named{x0, x1}}: Empty.absurd({E.unnamed(T.Union{T.Named{x0, x1}}) == True{} : Bool}, legal)
    case T.Union{T.ProgressiveList{x0}}: Empty.absurd({E.unnamed(T.Union{T.ProgressiveList{x0}}) == True{} : Bool}, legal)
    case T.Union{T.ProgressiveBits{}}: Empty.absurd({E.unnamed(T.Union{T.ProgressiveBits{}}) == True{} : Bool}, legal)
    case T.Union{T.ProgressiveContainer{x0, x1, x2}}: Empty.absurd({E.unnamed(T.Union{T.ProgressiveContainer{x0, x1, x2}}) == True{} : Bool}, legal)
    case T.Union{T.CompatibleUnion{x0, x1}}: Empty.absurd({E.unnamed(T.Union{T.CompatibleUnion{x0, x1}}) == True{} : Bool}, legal)

# Equality of identity decisions, not merely sound acceptance. The second
# argument may be any schema; only the first needs public representation.
law identity_correct:
  for +a: T.Schema
  for +b: T.Schema
  for +forest: Bool
  for legal: S.legal(a, forest)
  {I.identical(a, b) == C.identical(a, b) : Bool}
def identity_correct(a, b, forest, legal):
  E.equal(a, b, legal_unnamed(a, forest, legal))
