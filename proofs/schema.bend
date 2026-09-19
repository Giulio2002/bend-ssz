import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/schema.bend as S
import ../src/primitives.bend as IP
import ../spec/primitives.bend as SP
import ./primitives.bend as P

law times_correct:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  {I.scale_size(n, width) == S.times(n, width) : Maybe<&2, Nat>}
def times_correct(n, width):
  match width:
    case None{}: {==}
    case Some{w}: {==}

law sum_correct:
  for +a: Maybe<&2, Nat>
  for +b: Maybe<&2, Nat>
  {I.add_size(a, b) == S.sum(a, b) : Maybe<&2, Nat>}
def sum_correct(a, b):
  match a b:
    case None{} None{}: {==}
    case None{} Some{y}: {==}
    case Some{x} None{}: {==}
    case Some{x} Some{y}: {==}

law fixed_size_correct:
  for +schema: T.Schema
  {I.fixed_size(schema) == S.fixed_size(schema) : Maybe<&2, Nat>}
def fixed_size_correct(schema):
  match schema:
    case T.Boolean{}: {==}
    case T.Unsigned{w}: Equal.cong(Nat, Maybe<&2, Nat>, n => Some{n}, IP.width(w), SP.byte_width(w), P.width_correct(w))
    case T.ByteVector{n}: {==}
    case T.BitVector{n}: {==}
    case T.Vector{e, n}:
      Equal.trans(Maybe<&2, Nat>, I.scale_size(n, I.fixed_size(e)), I.scale_size(n, S.fixed_size(e)), S.times(n, S.fixed_size(e)), Equal.cong(Maybe<&2, Nat>, Maybe<&2, Nat>, width => I.scale_size(n, width), I.fixed_size(e), S.fixed_size(e), fixed_size_correct(e)), times_correct(n, S.fixed_size(e)))
    case T.Container{names, fields}: fixed_size_correct(fields)
    case T.ProgressiveContainer{names, fields, active}: fixed_size_correct(fields)
    case T.Chain{h, t}:
      %fixed_size_correct(h) : {I.add_size(I.fixed_size(h), I.fixed_size(t)) == S.sum(_, S.fixed_size(t)) : Maybe<&2, Nat>}
      %fixed_size_correct(t) : {I.add_size(I.fixed_size(h), I.fixed_size(t)) == S.sum(I.fixed_size(h), _) : Maybe<&2, Nat>}
      sum_correct(I.fixed_size(h), I.fixed_size(t))
    case T.End{}: {==}
    case T.Null{}: {==}
    case T.ByteList{n}: {==}
    case T.BitList{n}: {==}
    case T.ListOf{e, n}: {==}
    case T.Union{opts}: {==}
    case T.Repeat{e}: {==}
    case T.Named{name, e}: {==}
    case T.ProgressiveList{e}: {==}
    case T.ProgressiveBits{}: {==}
    case T.CompatibleUnion{selectors, opts}: {==}

law option_correct:
  for +types: T.Schema
  for +selector: Nat
  {I.get(types, selector) == S.option(types, selector) : Maybe<&2, T.Schema>}
def option_correct(types, selector):
  match types:
    case T.Chain{h, t}:
      match selector:
        case 0n: {==}
        case 1n+p: option_correct(t, p)
    case T.Boolean{}: {==}
    case T.Unsigned{v0}: {==}
    case T.ByteVector{v0}: {==}
    case T.ByteList{v0}: {==}
    case T.BitVector{v0}: {==}
    case T.BitList{v0}: {==}
    case T.Vector{v0, v1}: {==}
    case T.ListOf{v0, v1}: {==}
    case T.Container{v0, v1}: {==}
    case T.Union{v0}: {==}
    case T.Null{}: {==}
    case T.End{}: {==}
    case T.Repeat{v0}: {==}
    case T.Named{v0, v1}: {==}
    case T.ProgressiveList{v0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{v0, v1, v2}: {==}
    case T.CompatibleUnion{v0, v1}: {==}
