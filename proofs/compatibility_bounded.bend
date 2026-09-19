import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/type_legality.bend as S
import ./primitive_invariants.bend as V

# Recursive protocol invariant used only for compatibility termination bounds.
def bounded(schema: T.Schema) -> Bool:
  match schema:
    case T.Vector{child, n}: bounded(child)
    case T.ListOf{child, n}: bounded(child)
    case T.ProgressiveList{child}: bounded(child)
    case T.Repeat{child}: bounded(child)
    case T.Named{name, child}: bounded(child)
    case T.Container{names, fields}: bounded(fields)
    case T.ProgressiveContainer{names, fields, active}: Bool.and(Nat.is_le(List.length(&2, Bool, active), 256n), bounded(fields))
    case T.Union{options}: bounded(options)
    case T.CompatibleUnion{ids, options}: bounded(options)
    case T.Chain{head, tail}: Bool.and(bounded(head), bounded(tail))
    case _: True{}

law legal_bounded:
  for +schema: T.Schema
  for +forest: Bool
  for legal: S.legal(schema, forest)
  {bounded(schema) == True{} : Bool}
def legal_bounded(schema, forest, legal):
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
      legal_bounded(x0, False{}, child)
    case T.ListOf{x0, x1}:
      (context, child) = legal
      legal_bounded(x0, False{}, child)
    case T.Container{x0, x1}:
      (context, names, child) = legal
      legal_bounded(x1, True{}, child)
    case T.Null{}:
      Empty.absurd({bounded(T.Null{}) == True{} : Bool}, legal)
    case T.Chain{x0, x1}:
      (context, head, tail) = legal
      V.and_true(bounded(x0), bounded(x1), legal_bounded(x0, False{}, head), legal_bounded(x1, True{}, tail))
    case T.End{}:
      {==}
    case T.Repeat{x0}:
      Empty.absurd({bounded(T.Repeat{x0}) == True{} : Bool}, legal)
    case T.Named{x0, x1}:
      Empty.absurd({bounded(T.Named{x0, x1}) == True{} : Bool}, legal)
    case T.ProgressiveList{x0}:
      (context, child) = legal
      legal_bounded(x0, False{}, child)
    case T.ProgressiveBits{}:
      {==}
    case T.ProgressiveContainer{x0, x1, x2}:
      (context, names, child, limit, last, count) = legal
      V.and_true(Nat.is_le(List.length(&2, Bool, x2), 256n), bounded(x1), limit, legal_bounded(x1, True{}, child))
    case T.CompatibleUnion{x0, x1}:
      (context, nonempty, count, selectors, child, compatibility) = legal
      legal_bounded(x1, True{}, child)
    case T.Union{T.Boolean{}}: Empty.absurd({bounded(T.Union{T.Boolean{}}) == True{} : Bool}, legal)
    case T.Union{T.Unsigned{x0}}: Empty.absurd({bounded(T.Union{T.Unsigned{x0}}) == True{} : Bool}, legal)
    case T.Union{T.ByteVector{x0}}: Empty.absurd({bounded(T.Union{T.ByteVector{x0}}) == True{} : Bool}, legal)
    case T.Union{T.ByteList{x0}}: Empty.absurd({bounded(T.Union{T.ByteList{x0}}) == True{} : Bool}, legal)
    case T.Union{T.BitVector{x0}}: Empty.absurd({bounded(T.Union{T.BitVector{x0}}) == True{} : Bool}, legal)
    case T.Union{T.BitList{x0}}: Empty.absurd({bounded(T.Union{T.BitList{x0}}) == True{} : Bool}, legal)
    case T.Union{T.Vector{x0, x1}}: Empty.absurd({bounded(T.Union{T.Vector{x0, x1}}) == True{} : Bool}, legal)
    case T.Union{T.ListOf{x0, x1}}: Empty.absurd({bounded(T.Union{T.ListOf{x0, x1}}) == True{} : Bool}, legal)
    case T.Union{T.Container{x0, x1}}: Empty.absurd({bounded(T.Union{T.Container{x0, x1}}) == True{} : Bool}, legal)
    case T.Union{T.Union{x0}}: Empty.absurd({bounded(T.Union{T.Union{x0}}) == True{} : Bool}, legal)
    case T.Union{T.Null{}}: Empty.absurd({bounded(T.Union{T.Null{}}) == True{} : Bool}, legal)
    case T.Union{T.Chain{T.Boolean{}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.Boolean{}), bounded(tail), legal_bounded(T.Boolean{}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.Unsigned{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.Unsigned{h0}), bounded(tail), legal_bounded(T.Unsigned{h0}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.ByteVector{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.ByteVector{h0}), bounded(tail), legal_bounded(T.ByteVector{h0}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.ByteList{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.ByteList{h0}), bounded(tail), legal_bounded(T.ByteList{h0}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.BitVector{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.BitVector{h0}), bounded(tail), legal_bounded(T.BitVector{h0}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.BitList{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.BitList{h0}), bounded(tail), legal_bounded(T.BitList{h0}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.Vector{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.Vector{h0, h1}), bounded(tail), legal_bounded(T.Vector{h0, h1}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.ListOf{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.ListOf{h0, h1}), bounded(tail), legal_bounded(T.ListOf{h0, h1}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.Container{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.Container{h0, h1}), bounded(tail), legal_bounded(T.Container{h0, h1}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.Union{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.Union{h0}), bounded(tail), legal_bounded(T.Union{h0}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.Null{}, tail}}:
      (context, nonempty, limit, rest) = legal
      legal_bounded(tail, True{}, rest)
    case T.Union{T.Chain{T.Chain{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.Chain{h0, h1}), bounded(tail), legal_bounded(T.Chain{h0, h1}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.End{}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.End{}), bounded(tail), legal_bounded(T.End{}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.Repeat{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.Repeat{h0}), bounded(tail), legal_bounded(T.Repeat{h0}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.Named{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.Named{h0, h1}), bounded(tail), legal_bounded(T.Named{h0, h1}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.ProgressiveList{h0}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.ProgressiveList{h0}), bounded(tail), legal_bounded(T.ProgressiveList{h0}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.ProgressiveBits{}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.ProgressiveBits{}), bounded(tail), legal_bounded(T.ProgressiveBits{}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.ProgressiveContainer{h0, h1, h2}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.ProgressiveContainer{h0, h1, h2}), bounded(tail), legal_bounded(T.ProgressiveContainer{h0, h1, h2}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.Chain{T.CompatibleUnion{h0, h1}, tail}}:
      (context, limit, child, rest) = legal
      V.and_true(bounded(T.CompatibleUnion{h0, h1}), bounded(tail), legal_bounded(T.CompatibleUnion{h0, h1}, False{}, child), legal_bounded(tail, True{}, rest))
    case T.Union{T.End{}}: Empty.absurd({bounded(T.Union{T.End{}}) == True{} : Bool}, legal)
    case T.Union{T.Repeat{x0}}: Empty.absurd({bounded(T.Union{T.Repeat{x0}}) == True{} : Bool}, legal)
    case T.Union{T.Named{x0, x1}}: Empty.absurd({bounded(T.Union{T.Named{x0, x1}}) == True{} : Bool}, legal)
    case T.Union{T.ProgressiveList{x0}}: Empty.absurd({bounded(T.Union{T.ProgressiveList{x0}}) == True{} : Bool}, legal)
    case T.Union{T.ProgressiveBits{}}: Empty.absurd({bounded(T.Union{T.ProgressiveBits{}}) == True{} : Bool}, legal)
    case T.Union{T.ProgressiveContainer{x0, x1, x2}}: Empty.absurd({bounded(T.Union{T.ProgressiveContainer{x0, x1, x2}}) == True{} : Bool}, legal)
    case T.Union{T.CompatibleUnion{x0, x1}}: Empty.absurd({bounded(T.Union{T.CompatibleUnion{x0, x1}}) == True{} : Bool}, legal)

law expansion_bounded:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  for +safe: {bounded(fields) == True{} : Bool}
  {bounded(I.active_fields(active, names, fields)) == True{} : Bool}
def expansion_bounded(active, names, fields, safe):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}: expansion_bounded(tail, names, fields, safe)
    case Con{True{}, tail}:
      match names fields:
        case Nil{} T.Boolean{}: {==}
        case Con{name, ns} T.Boolean{}: {==}
        case Nil{} T.Unsigned{x0}: {==}
        case Con{name, ns} T.Unsigned{x0}: {==}
        case Nil{} T.ByteVector{x0}: {==}
        case Con{name, ns} T.ByteVector{x0}: {==}
        case Nil{} T.ByteList{x0}: {==}
        case Con{name, ns} T.ByteList{x0}: {==}
        case Nil{} T.BitVector{x0}: {==}
        case Con{name, ns} T.BitVector{x0}: {==}
        case Nil{} T.BitList{x0}: {==}
        case Con{name, ns} T.BitList{x0}: {==}
        case Nil{} T.Vector{x0, x1}: {==}
        case Con{name, ns} T.Vector{x0, x1}: {==}
        case Nil{} T.ListOf{x0, x1}: {==}
        case Con{name, ns} T.ListOf{x0, x1}: {==}
        case Nil{} T.Container{x0, x1}: {==}
        case Con{name, ns} T.Container{x0, x1}: {==}
        case Nil{} T.Union{x0}: {==}
        case Con{name, ns} T.Union{x0}: {==}
        case Nil{} T.Null{}: {==}
        case Con{name, ns} T.Null{}: {==}
        case Nil{} T.Chain{x0, x1}: {==}
        case Con{name, ns} T.Chain{field, fs}:
          V.and_true(bounded(field), bounded(I.active_fields(tail, ns, fs)), V.and_left(bounded(field), bounded(fs), safe), expansion_bounded(tail, ns, fs, V.and_right(bounded(field), bounded(fs), safe)))
        case Nil{} T.End{}: {==}
        case Con{name, ns} T.End{}: {==}
        case Nil{} T.Repeat{x0}: {==}
        case Con{name, ns} T.Repeat{x0}: {==}
        case Nil{} T.Named{x0, x1}: {==}
        case Con{name, ns} T.Named{x0, x1}: {==}
        case Nil{} T.ProgressiveList{x0}: {==}
        case Con{name, ns} T.ProgressiveList{x0}: {==}
        case Nil{} T.ProgressiveBits{}: {==}
        case Con{name, ns} T.ProgressiveBits{}: {==}
        case Nil{} T.ProgressiveContainer{x0, x1, x2}: {==}
        case Con{name, ns} T.ProgressiveContainer{x0, x1, x2}: {==}
        case Nil{} T.CompatibleUnion{x0, x1}: {==}
        case Con{name, ns} T.CompatibleUnion{x0, x1}: {==}
