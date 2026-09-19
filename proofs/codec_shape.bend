import Base
import ../types/schema.bend as T
import ../spec/representation.bend as Shape
import ../spec/codec.bend as S
import ../spec/schema.bend as Schema
import ../spec/layout.bend as Layout
import ./primitive_invariants.bend as V

def result_shape(shape: Bool, result: Maybe<&2, +List<T.Part>>) -> Type:
  match result:
    case None{}: Unit
    case Some{parts}: {shape == True{} : Bool}

law true_result:
  for result: Maybe<&2, +List<T.Part>>
  result_shape(True{}, result)
def true_result(result):
  match result:
    case None{}: Unit{}
    case Some{parts}: {==}

law concatenate:
  for +a: Maybe<&2, +List<T.Part>>
  for +b: Maybe<&2, +List<T.Part>>
  for +sa: Bool
  for +sb: Bool
  for ha: result_shape(sa, a)
  for hb: result_shape(sb, b)
  result_shape(Bool.and(sa, sb), S.concatenate(a, b))
def concatenate(a, b, sa, sb, ha, hb):
  match a b:
    case None{} None{}: Unit{}
    case None{} Some{ys}: Unit{}
    case Some{xs} None{}: Unit{}
    case Some{xs} Some{ys}: V.and_true(sa, sb, ha, hb)

law one:
  for +shape: Bool
  for +encoded: Maybe<&2, +List<U32>>
  for +width: Maybe<&2, Nat>
  for valid: {shape == True{} : Bool}
  result_shape(shape, S.one(encoded, width))
def one(shape, encoded, width, valid):
  match encoded:
    case None{}: Unit{}
    case Some{xs}: valid

law aggregate:
  for +shape: Bool
  for +parts: Maybe<&2, +List<T.Part>>
  for +width: Maybe<&2, Nat>
  for valid: result_shape(shape, parts)
  result_shape(shape, S.aggregate(parts, width))
def aggregate(shape, parts, width, valid):
  match parts:
    case None{}: Unit{}
    case Some{xs}: one(shape, Layout.encoding(xs), width, valid)

law require:
  for +shape: Bool
  for +ok: Bool
  for +result: Maybe<&2, +List<T.Part>>
  for valid: result_shape(shape, result)
  result_shape(shape, S.require(ok, result))
def require(shape, ok, result, valid):
  match ok:
    case False{}: Unit{}
    case True{}: valid

law tagged:
  for +shape: Bool
  for +selector: U32
  for +result: Maybe<&2, +List<T.Part>>
  for valid: result_shape(shape, result)
  result_shape(shape, S.tagged(selector, result))
def tagged(shape, selector, result, valid):
  match result:
    case None{}: Unit{}
    case Some{Nil{}}: Unit{}
    case Some{Con{T.Fixed{xs}, Nil{}}}: valid
    case Some{Con{T.Variable{xs}, Nil{}}}: valid
    case Some{Con{T.Fixed{xs}, Con{h, t}}}: Unit{}
    case Some{Con{T.Variable{xs}, Con{h, t}}}: Unit{}

law selected:
  for +option: Maybe<&2, T.Schema>
  for +value: T.Value
  for +selector: U32
  for recur: @+s: T.Schema -> result_shape(Shape.shape(value, s), S.parts(value, s))
  result_shape(Shape.selected(option, s => Shape.shape(value, s)), S.with_option(option, s => S.tagged(selector, S.parts(value, s))))
def selected(option, value, selector, recur):
  match option:
    case None{}: Unit{}
    case Some{s}: tagged(Shape.shape(value, s), selector, S.parts(value, s), recur(s))

# Generated structural proof below.
law parts_shape:
  for +value: T.Value
  for +schema: T.Schema
  result_shape(Shape.shape(value, schema), S.parts(value, schema))
def parts_shape(value, schema):
  match value:
    case T.BooleanValue{+v}:
      match schema:
        case T.Boolean{}: true_result(S.parts(T.BooleanValue{v}, T.Boolean{}))
        case T.Unsigned{+s0}: Unit{}
        case T.ByteVector{+s0}: Unit{}
        case T.ByteList{+s0}: Unit{}
        case T.BitVector{+s0}: Unit{}
        case T.BitList{+s0}: Unit{}
        case T.Vector{+s0, +s1}: Unit{}
        case T.ListOf{+s0, +s1}: Unit{}
        case T.Container{+s0, +s1}: Unit{}
        case T.Union{+s0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{+s0, +s1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{+s0}: Unit{}
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{+s0, +s1, +s2}: Unit{}
        case T.CompatibleUnion{+s0, +s1}: Unit{}
    case T.UnsignedValue{+v}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{+s0}: true_result(S.parts(T.UnsignedValue{v}, T.Unsigned{s0}))
        case T.ByteVector{+s0}: Unit{}
        case T.ByteList{+s0}: Unit{}
        case T.BitVector{+s0}: Unit{}
        case T.BitList{+s0}: Unit{}
        case T.Vector{+s0, +s1}: Unit{}
        case T.ListOf{+s0, +s1}: Unit{}
        case T.Container{+s0, +s1}: Unit{}
        case T.Union{+s0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{+s0, +s1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{+s0}: Unit{}
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{+s0, +s1, +s2}: Unit{}
        case T.CompatibleUnion{+s0, +s1}: Unit{}
    case T.BytesValue{+v}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{+s0}: Unit{}
        case T.ByteVector{+s0}: true_result(S.parts(T.BytesValue{v}, T.ByteVector{s0}))
        case T.ByteList{+s0}: true_result(S.parts(T.BytesValue{v}, T.ByteList{s0}))
        case T.BitVector{+s0}: Unit{}
        case T.BitList{+s0}: Unit{}
        case T.Vector{+s0, +s1}: Unit{}
        case T.ListOf{+s0, +s1}: Unit{}
        case T.Container{+s0, +s1}: Unit{}
        case T.Union{+s0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{+s0, +s1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{+s0}: Unit{}
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{+s0, +s1, +s2}: Unit{}
        case T.CompatibleUnion{+s0, +s1}: Unit{}
    case T.BitsValue{+v}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{+s0}: Unit{}
        case T.ByteVector{+s0}: Unit{}
        case T.ByteList{+s0}: Unit{}
        case T.BitVector{+s0}: true_result(S.parts(T.BitsValue{v}, T.BitVector{s0}))
        case T.BitList{+s0}: true_result(S.parts(T.BitsValue{v}, T.BitList{s0}))
        case T.Vector{+s0, +s1}: Unit{}
        case T.ListOf{+s0, +s1}: Unit{}
        case T.Container{+s0, +s1}: Unit{}
        case T.Union{+s0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{+s0, +s1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{+s0}: Unit{}
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: Unit{}
        case T.ProgressiveBits{}: true_result(S.parts(T.BitsValue{v}, T.ProgressiveBits{}))
        case T.ProgressiveContainer{+s0, +s1, +s2}: Unit{}
        case T.CompatibleUnion{+s0, +s1}: Unit{}
    case T.NullValue{}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{+s0}: Unit{}
        case T.ByteVector{+s0}: Unit{}
        case T.ByteList{+s0}: Unit{}
        case T.BitVector{+s0}: Unit{}
        case T.BitList{+s0}: Unit{}
        case T.Vector{+s0, +s1}: Unit{}
        case T.ListOf{+s0, +s1}: Unit{}
        case T.Container{+s0, +s1}: Unit{}
        case T.Union{+s0}: Unit{}
        case T.Null{}: true_result(S.parts(T.NullValue{}, T.Null{}))
        case T.Chain{+s0, +s1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{+s0}: Unit{}
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{+s0, +s1, +s2}: Unit{}
        case T.CompatibleUnion{+s0, +s1}: Unit{}
    case T.EmptyItems{}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{+s0}: Unit{}
        case T.ByteVector{+s0}: Unit{}
        case T.ByteList{+s0}: Unit{}
        case T.BitVector{+s0}: Unit{}
        case T.BitList{+s0}: Unit{}
        case T.Vector{+s0, +s1}: Unit{}
        case T.ListOf{+s0, +s1}: Unit{}
        case T.Container{+s0, +s1}: Unit{}
        case T.Union{+s0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{+s0, +s1}: Unit{}
        case T.End{}: true_result(S.parts(T.EmptyItems{}, T.End{}))
        case T.Repeat{+s0}: true_result(S.parts(T.EmptyItems{}, T.Repeat{s0}))
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{+s0, +s1, +s2}: Unit{}
        case T.CompatibleUnion{+s0, +s1}: Unit{}
    case T.Items{+h, +t}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{+s0}: Unit{}
        case T.ByteVector{+s0}: Unit{}
        case T.ByteList{+s0}: Unit{}
        case T.BitVector{+s0}: Unit{}
        case T.BitList{+s0}: Unit{}
        case T.Vector{+s0, +s1}: Unit{}
        case T.ListOf{+s0, +s1}: Unit{}
        case T.Container{+s0, +s1}: Unit{}
        case T.Union{+s0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{+s0, +s1}: concatenate(S.parts(h, s0), S.parts(t, s1), Shape.shape(h, s0), Shape.shape(t, s1), parts_shape(h, s0), parts_shape(t, s1))
        case T.End{}: Unit{}
        case T.Repeat{+s0}: concatenate(S.parts(h, s0), S.parts(t, T.Repeat{s0}), Shape.shape(h, s0), Shape.shape(t, T.Repeat{s0}), parts_shape(h, s0), parts_shape(t, T.Repeat{s0}))
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{+s0, +s1, +s2}: Unit{}
        case T.CompatibleUnion{+s0, +s1}: Unit{}
    case T.Sequence{+items}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{+s0}: Unit{}
        case T.ByteVector{+s0}: Unit{}
        case T.ByteList{+s0}: Unit{}
        case T.BitVector{+s0}: Unit{}
        case T.BitList{+s0}: Unit{}
        case T.Vector{+s0, +s1}: require(Shape.shape(items, T.Repeat{s0}), Bool.and(Nat.is_lt(0n, s1), Nat.is_eq(S.count(items), s1)), S.aggregate(S.parts(items, T.Repeat{s0}), Schema.times(s1, Schema.fixed_size(s0))), aggregate(Shape.shape(items, T.Repeat{s0}), S.parts(items, T.Repeat{s0}), Schema.times(s1, Schema.fixed_size(s0)), parts_shape(items, T.Repeat{s0})))
        case T.ListOf{+s0, +s1}: require(Shape.shape(items, T.Repeat{s0}), Nat.is_le(S.count(items), s1), S.aggregate(S.parts(items, T.Repeat{s0}), None{}), aggregate(Shape.shape(items, T.Repeat{s0}), S.parts(items, T.Repeat{s0}), None{}, parts_shape(items, T.Repeat{s0})))
        case T.Container{+s0, +s1}: aggregate(Shape.shape(items, s1), S.parts(items, s1), Schema.fixed_size(s1), parts_shape(items, s1))
        case T.Union{+s0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{+s0, +s1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{+s0}: Unit{}
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: aggregate(Shape.shape(items, T.Repeat{s0}), S.parts(items, T.Repeat{s0}), None{}, parts_shape(items, T.Repeat{s0}))
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{+s0, +s1, +s2}: aggregate(Shape.shape(items, s1), S.parts(items, s1), Schema.fixed_size(s1), parts_shape(items, s1))
        case T.CompatibleUnion{+s0, +s1}: Unit{}
    case T.Selected{+selector, +v}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{+s0}: Unit{}
        case T.ByteVector{+s0}: Unit{}
        case T.ByteList{+s0}: Unit{}
        case T.BitVector{+s0}: Unit{}
        case T.BitList{+s0}: Unit{}
        case T.Vector{+s0, +s1}: Unit{}
        case T.ListOf{+s0, +s1}: Unit{}
        case T.Container{+s0, +s1}: Unit{}
        case T.Union{+s0}: selected(Schema.option(s0, U32.to_nat(selector)), v, selector, s => parts_shape(v, s))
        case T.Null{}: Unit{}
        case T.Chain{+s0, +s1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{+s0}: Unit{}
        case T.Named{+s0, +s1}: Unit{}
        case T.ProgressiveList{+s0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{+s0, +s1, +s2}: Unit{}
        case T.CompatibleUnion{+s0, +s1}: selected(Schema.compatible_option(s0, s1, selector), v, selector, s => parts_shape(v, s))


# Public encoding-image consequence (schema legality handled separately).
def bytes_shape(shape: Bool, result: Maybe<&2, +List<U32>>) -> Type:
  match result:
    case None{}: Unit
    case Some{bytes}: {shape == True{} : Bool}

law bytes_preserve_shape:
  for +shape: Bool
  for +parts: Maybe<&2, +List<T.Part>>
  for valid: result_shape(shape, parts)
  bytes_shape(shape, S.bytes(parts))
def bytes_preserve_shape(shape, parts, valid):
  match parts:
    case None{}: Unit{}
    case Some{Nil{}}: Unit{}
    case Some{Con{T.Fixed{xs}, Nil{}}}: valid
    case Some{Con{T.Variable{xs}, Nil{}}}: valid
    case Some{Con{T.Fixed{xs}, Con{h, t}}}: Unit{}
    case Some{Con{T.Variable{xs}, Con{h, t}}}: Unit{}

law encoding_shape:
  for +schema: T.Schema
  for +value: T.Value
  bytes_shape(Shape.shape(value, schema), S.encoding_for_legal_type(schema, value))
def encoding_shape(schema, value):
  bytes_preserve_shape(Shape.shape(value, schema), S.parts(value, schema), parts_shape(value, schema))

law accepted_shape:
  for +schema: T.Schema
  for +value: T.Value
  for +bytes: +List<U32>
  for accepted: {S.encoding_for_legal_type(schema, value) == Some{bytes} : Maybe<&2, +List<U32>>}
  {Shape.shape(value, schema) == True{} : Bool}
def accepted_shape(schema, value, bytes, accepted):
  %accepted : bytes_shape(Shape.shape(value, schema), _)
  encoding_shape(schema, value)
