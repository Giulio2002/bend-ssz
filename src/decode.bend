import Base
import ./lists.bend as Lists
import ../types/primitive.bend as Primitive
import ../types/schema.bend as T
import ./schema.bend as S
import ./codec.bend as C
import ./layout.bend as L
import ./primitives.bend as P
import ./bytes.bend as B
import ./byte_list.bend as BL
import ./bitfields.bend as Bits
import ./packing.bend as Pack

def boolean(result: Maybe<&2, Bool>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: Some{T.BooleanValue{v}}

def unsigned(result: Maybe<&2, Primitive.UInt>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: Some{T.UnsignedValue{v}}

def bytes(result: Maybe<&2, +List<U32>>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: Some{T.BytesValue{v}}

def bits(result: Maybe<&2, +List<Bool>>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: Some{T.BitsValue{v}}

def sequence(result: Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: Some{T.Sequence{v}}

def cons(a: Maybe<&2, T.Value>, b: Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match a b:
    case Some{x} Some{y}: Some{T.Items{x, y}}
    case _ _: None{}

def selected(selector: U32, result: Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: Some{T.Selected{selector, v}}

def gate(ok: Bool, next: Unit -> Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match ok:
    case False{}: None{}
    case True{}: next(Unit{})

def slices(result: Maybe<&2, +List<+List<U32>>>, next: +List<+List<U32>> -> Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: next(v)

def option(result: Maybe<&2, T.Schema>, next: T.Schema -> Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: next(v)

def nat_gate(ok: Bool, n: Nat) -> Maybe<&2, Nat>:
  match ok:
    case False{}: None{}
    case True{}: Some{n}

def variable_count(+first: Nat, +length: Nat) -> Maybe<&2, Nat>:
  nat_gate(Bool.and(Nat.is_lt(0n, first), Bool.and(Nat.is_eq(Nat.mod(first, 4n), 0n), Nat.is_le(first, length))), Nat.div(first, 4n))

def item_count(+width: Maybe<&2, Nat>, +xs: +List<U32>) -> Maybe<&2, Nat>:
  match width:
    case Some{0n}: None{}
    case Some{1n+n}: nat_gate(Nat.is_eq(Nat.mod(Lists.length(U32, xs), 1n+n), 0n), Nat.div(Lists.length(U32, xs), 1n+n))
    case None{}:
      match xs:
        case Nil{}: Some{0n}
        case Con{a, Con{b, Con{c, Con{d, t}}}}: variable_count(L.offset([a, b, c, d]), 4n+Lists.length(U32, t))
        case _: None{}

def with_count(result: Maybe<&2, Nat>, next: Nat -> Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{n}: next(n)

def reverse_items(value: T.Value, acc: T.Value) -> T.Value:
  match value:
    case T.Items{h, t}: reverse_items(t, T.Items{h, acc})
    case _: acc

def accumulate(result: Maybe<&2, T.Value>, acc: T.Value, next: T.Value -> Maybe<&2, T.Value>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{v}: next(T.Items{v, acc})

# Fuel is computed from the input's schema structure and actual byte length.
# Sufficiency and all-input refinement are separate outstanding proof obligations.
def decode_go(+fuel: Nat, schema: T.Schema, +xs: +List<U32>, parts: +List<+List<U32>>, acc: T.Value) -> Maybe<&2, T.Value>:
  match fuel:
    case 0n: None{}
    case 1n+p:
      match schema:
        case T.Boolean{}: boolean(P.boolean_deserialize(xs))
        case T.Unsigned{w}: unsigned(P.uint_deserialize(w, xs))
        case T.ByteVector{n}: bytes(B.vector_deserialize(n, xs))
        case T.ByteList{n}: bytes(BL.deserialize(n, xs))
        case T.BitVector{n}: bits(Bits.bitvector_deserialize(n, xs))
        case T.BitList{n}: bits(Bits.bitlist_deserialize(n, xs))
        case T.ProgressiveBits{}: bits(Bits.bitlist_deserialize(Nat.mul(Lists.length(U32, xs), 8n), xs))
        case T.Null{}:
          match xs:
            case Nil{}: Some{T.NullValue{}}
            case _: None{}
        case T.End{}:
          match parts:
            case Nil{}: Some{reverse_items(acc, T.EmptyItems{})}
            case _: None{}
        case T.Chain{h, t}:
          match parts:
            case Con{first, rest}: accumulate(decode_go(p, h, first, [], T.EmptyItems{}), acc, next => decode_go(p, t, [], rest, next))
            case _: None{}
        case T.Repeat{+e}:
          match parts:
            case Nil{}: Some{reverse_items(acc, T.EmptyItems{})}
            case Con{first, rest}: accumulate(decode_go(p, e, first, [], T.EmptyItems{}), acc, next => decode_go(p, T.Repeat{e}, [], rest, next))
        case T.Vector{+e, +n}:
          with_count(item_count(S.fixed_size(e), xs), k => gate(Nat.is_eq(k, n), u => slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => sequence(decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})))))
        case T.ListOf{+e, +limit}:
          with_count(item_count(S.fixed_size(e), xs), +n => gate(Nat.is_le(n, limit), u => slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => sequence(decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})))))
        case T.ProgressiveList{+e}:
          with_count(item_count(S.fixed_size(e), xs), n => slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => sequence(decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}))))
        case T.Container{names, +fields}: slices(L.decode(S.widths(fields), xs), ps => sequence(decode_go(p, fields, [], ps, T.EmptyItems{})))
        case T.ProgressiveContainer{names, +fields, active}: slices(L.decode(S.widths(fields), xs), ps => sequence(decode_go(p, fields, [], ps, T.EmptyItems{})))
        case T.Union{options}:
          match xs:
            case Con{+selector, tail}: option(S.get(options, U32.to_nat(selector)), s => selected(selector, decode_go(p, s, tail, [], T.EmptyItems{})))
            case _: None{}
        case T.CompatibleUnion{selectors, options}:
          match xs:
            case Con{+selector, tail}: option(C.selected_schema(selectors, options, selector), s => selected(selector, decode_go(p, s, tail, [], T.EmptyItems{})))
            case _: None{}
        case _: None{}

def equal_bytes_go(a: +List<U32>, b: +List<U32>, ok: Bool) -> Bool:
  match a b:
    case Nil{} Nil{}: ok
    case Con{x, xs} Con{y, ys}: equal_bytes_go(xs, ys, Bool.and(ok, U32.is_eq(x, y)))
    case _ _: False{}

def equal_bytes(a: +List<U32>, b: +List<U32>) -> Bool: equal_bytes_go(a, b, True{})

def canonical_bytes(encoded: Maybe<&2, +List<U32>>, input: +List<U32>, value: T.Value) -> Maybe<&2, T.Value>:
  match encoded:
    case None{}: None{}
    case Some{xs}: gate(equal_bytes(xs, input), u => Some{value})

def canonical(result: Maybe<&2, T.Value>, schema: T.Schema, xs: +List<U32>) -> Maybe<&2, T.Value>:
  match result:
    case None{}: None{}
    case Some{+v}: canonical_bytes(C.serialize(schema, v), xs, v)

def deserialize(+schema: T.Schema, +xs: +List<U32>) -> Maybe<&2, T.Value>:
  gate(Bool.and(S.valid(schema), Pack.valid_go(xs, True{})), u =>
    canonical(decode_go(Nat.mul(2n+S.weight(schema), 2n+Lists.length(U32, xs)), schema, xs, [], T.EmptyItems{}), schema, xs))
