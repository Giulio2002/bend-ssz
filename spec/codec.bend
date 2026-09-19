import Base
import ../types/schema.bend as T
import ./schema.bend as S
import ./layout.bend as Layout
import ./primitives.bend as P
import ./bytes.bend as Bytes
import ./byte_list.bend as ByteList
import ./bitfields.bend as Bits

# Recursive normative serialization for a LEGAL schema. Public type legality
# and its composition are separate unfinished obligations; this is not yet
# the complete public SSZ specification. Child encodings feed the independent
# fixed_parts/variable_parts offset formula, never a source codec.
def count(items: T.Value) -> Nat:
  match items:
    case T.Items{h, t}: 1n+count(t)
    case _: 0n

def fragment(width: Maybe<&2, Nat>, xs: +List<U32>) -> T.Part:
  match width:
    case None{}: T.Variable{xs}
    case Some{n}: T.Fixed{xs}

def one(encoded: Maybe<&2, +List<U32>>, width: Maybe<&2, Nat>) -> Maybe<&2, +List<T.Part>>:
  match encoded:
    case None{}: None{}
    case Some{xs}: Some{[fragment(width, xs)]}

def concatenate(a: Maybe<&2, +List<T.Part>>, b: Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match a b:
    case Some{x} Some{y}: Some{List.append(&2, T.Part, x, y)}
    case _ _: None{}

def aggregate(parts: Maybe<&2, +List<T.Part>>, width: Maybe<&2, Nat>) -> Maybe<&2, +List<T.Part>>:
  match parts:
    case None{}: None{}
    case Some{xs}: one(Layout.encoding(xs), width)

def require(ok: Bool, result: Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match ok:
    case False{}: None{}
    case True{}: result

def bytes(parts: Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<U32>>:
  match parts:
    case Some{Con{T.Fixed{xs}, Nil{}}}: Some{xs}
    case Some{Con{T.Variable{xs}, Nil{}}}: Some{xs}
    case _: None{}

def tagged(selector: U32, content: Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match content:
    case Some{Con{T.Fixed{xs}, Nil{}}}: Some{[T.Variable{selector <> xs}]}
    case Some{Con{T.Variable{xs}, Nil{}}}: Some{[T.Variable{selector <> xs}]}
    case _: None{}

def with_option(option: Maybe<&2, T.Schema>, next: T.Schema -> Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match option:
    case None{}: None{}
    case Some{s}: next(s)

def parts(value: T.Value, schema: T.Schema) -> Maybe<&2, +List<T.Part>>:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: Some{[T.Fixed{P.boolean_encoding(b)}]}
        case _: None{}
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{+w}: one(P.uint_encoding(w, v), Some{P.byte_width(w)})
        case _: None{}
    case T.BytesValue{xs}:
      match schema:
        case T.ByteVector{+n}: one(Bytes.vector_encoding(n, xs), Some{n})
        case T.ByteList{n}: one(ByteList.encoding(n, xs), None{})
        case _: None{}
    case T.BitsValue{+bs}:
      match schema:
        case T.BitVector{+n}: one(Bits.vector_encoding(n, bs), Some{Nat.div(Nat.add(n, 7n), 8n)})
        case T.BitList{n}: one(Bits.list_encoding(n, bs), None{})
        case T.ProgressiveBits{}: one(Bits.list_encoding(List.length(&2, Bool, bs), bs), None{})
        case _: None{}
    case T.NullValue{}:
      match schema:
        case T.Null{}: Some{[T.Fixed{[]}]}
        case _: None{}
    case T.EmptyItems{}:
      match schema:
        case T.End{}: Some{[]}
        case T.Repeat{e}: Some{[]}
        case _: None{}
    case T.Items{h, t}:
      match schema:
        case T.Chain{s, rest}: concatenate(parts(h, s), parts(t, rest))
        case T.Repeat{+s}: concatenate(parts(h, s), parts(t, T.Repeat{s}))
        case _: None{}
    case T.Sequence{+items}:
      match schema:
        case T.Vector{+s, +n}: require(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(count(items), n)), aggregate(parts(items, T.Repeat{s}), S.times(n, S.fixed_size(s))))
        case T.ListOf{s, n}: require(Nat.is_le(count(items), n), aggregate(parts(items, T.Repeat{s}), None{}))
        case T.ProgressiveList{s}: aggregate(parts(items, T.Repeat{s}), None{})
        case T.Container{names, +fields}: aggregate(parts(items, fields), S.fixed_size(fields))
        case T.ProgressiveContainer{names, +fields, active}: aggregate(parts(items, fields), S.fixed_size(fields))
        case _: None{}
    case T.Selected{+selector, v}:
      match schema:
        case T.Union{options}: with_option(S.option(options, U32.to_nat(selector)), s => tagged(selector, parts(v, s)))
        case T.CompatibleUnion{selectors, options}: with_option(S.compatible_option(selectors, options, selector), s => tagged(selector, parts(v, s)))
        case _: None{}

def encoding_for_legal_type(schema: T.Schema, value: T.Value) -> Maybe<&2, +List<U32>>:
  bytes(parts(value, schema))
