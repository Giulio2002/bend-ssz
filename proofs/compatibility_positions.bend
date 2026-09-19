import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./packing.bend as Pack

def offset(value: Maybe<&2, Nat>, +start: Nat) -> Maybe<&2, Nat>:
  match value:
    case None{}: None{}
    case Some{n}: Some{Nat.add(n, start)}

law offset_shift:
  for +value: Maybe<&2, Nat>
  for +start: Nat
  {offset(value, 1n+start) == offset(S.shift(value), start) : Maybe<&2, Nat>}
def offset_shift(value, start):
  match value:
    case None{}: {==}
    case Some{n}: Equal.cong(Nat, Maybe<&2, Nat>, x => Some{x}, Nat.add(n, 1n+start), 1n+Nat.add(n, start), Pack.add_succ(n, start))

law offset_zero:
  for +value: Maybe<&2, Nat>
  {offset(value, 0n) == value : Maybe<&2, Nat>}
def offset_zero(value):
  match value:
    case None{}: {==}
    case Some{n}: Equal.cong(Nat, Maybe<&2, Nat>, x => Some{x}, Nat.add(n, 0n), n, Pack.add_zero(n))

law choice:
  for +found: Bool
  for +start: Nat
  for next: Unit -> Maybe<&2, Nat>
  for +tail: Maybe<&2, Nat>
  for correct: {next(Unit{}) == offset(tail, 1n+start) : Maybe<&2, Nat>}
  {I.position_choice(found, start, next) == offset(S.choose(found, tail), start) : Maybe<&2, Nat>}
def choice(found, start, next, tail, correct):
  match found:
    case True{}: {==}
    case False{}: Equal.trans(Maybe<&2, Nat>, next(Unit{}), offset(tail, 1n+start), offset(S.shift(tail), start), correct, offset_shift(tail, start))

law field_position:
  for +fields: T.Schema
  for +name: String
  for +start: Nat
  {I.field_position(fields, name, start) == offset(S.position(name, fields), start) : Maybe<&2, Nat>}
def field_position(fields, name, start):
  match fields:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: {==}
    case T.ListOf{x0, x1}: {==}
    case T.Container{x0, x1}: {==}
    case T.Union{x0}: {==}
    case T.Null{}: {==}
    case T.Chain{head, tail}:
      match head:
        case T.Boolean{}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.Unsigned{x0}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.ByteVector{x0}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.ByteList{x0}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.BitVector{x0}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.BitList{x0}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.Vector{x0, x1}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.ListOf{x0, x1}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.Container{x0, x1}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.Union{x0}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.Null{}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.Chain{x0, x1}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.End{}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.Repeat{x0}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.Named{n, f}:
          choice(String.eq(name, n), start, u => I.field_position(tail, name, 1n+start), S.position(name, tail), field_position(tail, name, 1n+start))
        case T.ProgressiveList{x0}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.ProgressiveBits{}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.ProgressiveContainer{x0, x1, x2}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
        case T.CompatibleUnion{x0, x1}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
    case T.End{}: {==}
    case T.Repeat{x0}: {==}
    case T.Named{x0, x1}: {==}
    case T.ProgressiveList{x0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: {==}
    case T.CompatibleUnion{x0, x1}: {==}

law position:
  for +fields: T.Schema
  for +name: String
  {I.field_position(fields, name, 0n) == S.position(name, fields) : Maybe<&2, Nat>}
def position(fields, name):
  Equal.trans(Maybe<&2, Nat>, I.field_position(fields, name, 0n), offset(S.position(name, fields), 0n), S.position(name, fields), field_position(fields, name, 0n), offset_zero(S.position(name, fields)))

law eq_symmetric:
  for +a: Nat
  for +b: Nat
  {Nat.is_eq(a, b) == Nat.is_eq(b, a) : Bool}
def eq_symmetric(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+y: {==}
    case 1n+x 0n: {==}
    case 1n+x 1n+y: eq_symmetric(x, y)

law agrees:
  for +value: Maybe<&2, Nat>
  for +index: Nat
  {I.same_position(value, index) == S.agrees(index, value) : Bool}
def agrees(value, index):
  match value:
    case None{}: {==}
    case Some{n}: eq_symmetric(n, index)

law shared_positions:
  for +a: T.Schema
  for +b: T.Schema
  for +index: Nat
  {I.shared_positions(a, b, index) == S.shared_positions(a, b, index) : Bool}
def shared_positions(a, b, index):
  match a:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: {==}
    case T.ListOf{x0, x1}: {==}
    case T.Container{x0, x1}: {==}
    case T.Union{x0}: {==}
    case T.Null{}: {==}
    case T.Chain{head, tail}:
      match head:
        case T.Boolean{}: shared_positions(tail, b, 1n+index)
        case T.Unsigned{x0}: shared_positions(tail, b, 1n+index)
        case T.ByteVector{x0}: shared_positions(tail, b, 1n+index)
        case T.ByteList{x0}: shared_positions(tail, b, 1n+index)
        case T.BitVector{x0}: shared_positions(tail, b, 1n+index)
        case T.BitList{x0}: shared_positions(tail, b, 1n+index)
        case T.Vector{x0, x1}: shared_positions(tail, b, 1n+index)
        case T.ListOf{x0, x1}: shared_positions(tail, b, 1n+index)
        case T.Container{x0, x1}: shared_positions(tail, b, 1n+index)
        case T.Union{x0}: shared_positions(tail, b, 1n+index)
        case T.Null{}: shared_positions(tail, b, 1n+index)
        case T.Chain{x0, x1}: shared_positions(tail, b, 1n+index)
        case T.End{}: shared_positions(tail, b, 1n+index)
        case T.Repeat{x0}: shared_positions(tail, b, 1n+index)
        case T.Named{n, f}:
          %position(b, n) : {I.shared_positions(T.Chain{T.Named{n, f}, tail}, b, index) == Bool.and(S.agrees(index, _), S.shared_positions(tail, b, 1n+index)) : Bool}
          %agrees(I.field_position(b, n, 0n), index) : {I.shared_positions(T.Chain{T.Named{n, f}, tail}, b, index) == Bool.and(_, S.shared_positions(tail, b, 1n+index)) : Bool}
          %shared_positions(tail, b, 1n+index) : {I.shared_positions(T.Chain{T.Named{n, f}, tail}, b, index) == Bool.and(I.same_position(I.field_position(b, n, 0n), index), _) : Bool}
          {==}
        case T.ProgressiveList{x0}: shared_positions(tail, b, 1n+index)
        case T.ProgressiveBits{}: shared_positions(tail, b, 1n+index)
        case T.ProgressiveContainer{x0, x1, x2}: shared_positions(tail, b, 1n+index)
        case T.CompatibleUnion{x0, x1}: shared_positions(tail, b, 1n+index)
    case T.End{}: {==}
    case T.Repeat{x0}: {==}
    case T.Named{x0, x1}: {==}
    case T.ProgressiveList{x0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: {==}
    case T.CompatibleUnion{x0, x1}: {==}
