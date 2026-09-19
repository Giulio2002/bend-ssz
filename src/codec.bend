import Base
import ./lists.bend as Lists
import ../types/schema.bend as T
import ./schema.bend as S
import ./layout.bend as L
import ./primitives.bend as P
import ./bytes.bend as B
import ./byte_list.bend as BL
import ./bitfields.bend as Bits

# Sequence values are explicit recursive spines, so induction/termination is
# structural even for arbitrarily nested schemas and values.
def count_go(value: T.Value, acc: Nat) -> Nat:
  match value:
    case T.Items{h, t}: count_go(t, 1n+acc)
    case _: acc

def count(value: T.Value) -> Nat: count_go(value, 0n)

def join(a: Maybe<&2, +List<T.Part>>, b: Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match a b:
    case Some{x} Some{y}: Some{Lists.append(T.Part, x, y)}
    case _ _: None{}

def part(width: Maybe<&2, Nat>, xs: +List<U32>) -> T.Part:
  match width:
    case None{}: T.Variable{xs}
    case Some{n}: T.Fixed{xs}

def wrap(result: Maybe<&2, +List<U32>>, width: Maybe<&2, Nat>) -> Maybe<&2, +List<T.Part>>:
  match result:
    case None{}: None{}
    case Some{xs}: Some{[part(width, xs)]}

def layout(result: Maybe<&2, +List<T.Part>>, width: Maybe<&2, Nat>) -> Maybe<&2, +List<T.Part>>:
  match result:
    case None{}: None{}
    case Some{parts}: wrap(L.encode(parts), width)

def gate(ok: Bool, next: Unit -> Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match ok:
    case False{}: None{}
    case True{}: next(Unit{})

def unwrap(result: Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<U32>>:
  match result:
    case Some{Con{T.Fixed{xs}, Nil{}}}: Some{xs}
    case Some{Con{T.Variable{xs}, Nil{}}}: Some{xs}
    case _: None{}

def select_option(ok: Bool, s: T.Schema, next: Unit -> Maybe<&2, T.Schema>) -> Maybe<&2, T.Schema>:
  match ok:
    case False{}: next(Unit{})
    case True{}: Some{s}

def selected_schema(selectors: +List<U32>, options: T.Schema, +selector: U32) -> Maybe<&2, T.Schema>:
  match selectors options:
    case Con{h, t} T.Chain{s, rest}: select_option(U32.is_eq(h, selector), s, u => selected_schema(t, rest, selector))
    case _ _: None{}

def with_schema(option: Maybe<&2, T.Schema>, next: T.Schema -> Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match option:
    case None{}: None{}
    case Some{s}: next(s)

def accumulate(encoded: Maybe<&2, +List<T.Part>>, acc: +List<T.Part>, next: +List<T.Part> -> Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match encoded:
    case None{}: None{}
    case Some{parts}: next(List.reverse.go(&2, T.Part, parts, acc))

# Internal recursion also handles schema forests and repeated element schemas.
# Public entry points validate the schema, excluding those internal constructors.
def encode_go(value: T.Value, schema: T.Schema, acc: +List<T.Part>) -> Maybe<&2, +List<T.Part>>:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: Some{[T.Fixed{P.boolean_serialize(b)}]}
        case _: None{}
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{+w}: wrap(P.uint_serialize(w, v), Some{P.width(w)})
        case _: None{}
    case T.BytesValue{xs}:
      match schema:
        case T.ByteVector{+n}: wrap(B.vector_serialize(n, xs), Some{n})
        case T.ByteList{n}: wrap(BL.serialize(n, xs), None{})
        case _: None{}
    case T.BitsValue{+bs}:
      match schema:
        case T.BitVector{+n}: wrap(Bits.bitvector_serialize(n, bs), Some{Nat.div(Nat.add(n, 7n), 8n)})
        case T.BitList{n}: wrap(Bits.bitlist_serialize(n, bs), None{})
        case T.ProgressiveBits{}: wrap(Bits.bitlist_serialize(Lists.length(Bool, bs), bs), None{})
        case _: None{}
    case T.NullValue{}:
      match schema:
        case T.Null{}: Some{[T.Fixed{[]}]}
        case _: None{}
    case T.Items{h, t}:
      match schema:
        case T.Chain{s, rest}: accumulate(encode_go(h, s, []), acc, next => encode_go(t, rest, next))
        case T.Repeat{+s}: accumulate(encode_go(h, s, []), acc, next => encode_go(t, T.Repeat{s}, next))
        case _: None{}
    case T.EmptyItems{}:
      match schema:
        case T.End{}: Some{List.reverse(&2, T.Part, acc)}
        case T.Repeat{s}: Some{List.reverse(&2, T.Part, acc)}
        case _: None{}
    case T.Sequence{+items}:
      match schema:
        case T.Vector{+s, +n}: gate(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(count(items), n)), u => layout(encode_go(items, T.Repeat{s}, []), S.scale_size(n, S.fixed_size(s))))
        case T.ListOf{s, n}: gate(Nat.is_le(count(items), n), u => layout(encode_go(items, T.Repeat{s}, []), None{}))
        case T.ProgressiveList{s}: layout(encode_go(items, T.Repeat{s}, []), None{})
        case T.Container{names, +fields}: layout(encode_go(items, fields, []), S.fixed_size(fields))
        case T.ProgressiveContainer{names, +fields, active}: layout(encode_go(items, fields, []), S.fixed_size(fields))
        case _: None{}
    case T.Selected{+selector, v}:
      match schema:
        case T.Union{options}: with_schema(S.get(options, U32.to_nat(selector)), s => wrap(L.append(Some{[selector]}, unwrap(encode_go(v, s, []))), None{}))
        case T.CompatibleUnion{selectors, options}: with_schema(selected_schema(selectors, options, selector), s => wrap(L.append(Some{[selector]}, unwrap(encode_go(v, s, []))), None{}))
        case _: None{}

def encode(value: T.Value, schema: T.Schema) -> Maybe<&2, +List<T.Part>>: encode_go(value, schema, [])

def serialize(+schema: T.Schema, value: T.Value) -> Maybe<&2, +List<U32>>:
  unwrap(gate(S.valid(schema), u => encode(value, schema)))

def valid(schema: T.Schema, value: T.Value) -> Bool: P.is_some(serialize(schema, value))
