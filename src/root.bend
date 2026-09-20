import Base
import ./cached_tree.bend as Cached
import ./lists.bend as Lists
import ../types/schema.bend as T
import ./schema.bend as S
import ./codec.bend as C
import ./primitives.bend as P
import ./byte_root.bend as Bytes
import ./byte_list.bend as ByteList
import ./bit_root.bend as Bits
import ./bit_packing.bend as BitPack
import ./limits.bend as Merkle
import ./progressive.bend as Progressive
import ./packing.bend as Pack
import ./nat_bytes.bend as Length
import ./mixing.bend as Mixing
import ./bitfields.bend as Fields

def single(root: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<+List<U32>>>:
  match root:
    case None{}: None{}
    case Some{xs}: Some{[xs]}

def unwrap(roots: Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<U32>>:
  match roots:
    case Some{Con{xs, Nil{}}}: Some{xs}
    case _: None{}

def append(a: Maybe<&2, +List<+List<U32>>>, b: Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match a b:
    case Some{x} Some{y}: Some{Lists.append(+List<U32>, x, y)}
    case _ _: None{}

def packed(bytes: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<+List<U32>>>:
  match bytes:
    case None{}: None{}
    case Some{xs}: Pack.pack(xs)

def count_limit(size: Maybe<&2, Nat>, limit: Nat) -> Nat:
  match size:
    case None{}: limit
    case Some{s}: Nat.div(Nat.add(Nat.mul(limit, s), 31n), 32n)

def choose_chunks(size: Maybe<&2, Nat>, encoded: Unit -> Maybe<&2, +List<U32>>, roots: Unit -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match size:
    case None{}: roots(Unit{})
    case Some{s}: packed(encoded(Unit{}))

def merkle(chunks: Maybe<&2, +List<+List<U32>>>, limit: Nat, progressive: Bool, table: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match chunks:
    case None{}: None{}
    case Some{xs}:
      match progressive:
        case False{}: Cached.merkleize(limit, xs, table)
        case True{}: Cached.progressive(xs, table)

def length_mix(root: Maybe<&2, +List<U32>>, count: Maybe<&2, Nat>) -> Maybe<&2, +List<U32>>:
  match count:
    case None{}: root
    case Some{n}: Bits.mix_length_bytes(root, Length.encode(32n, n))

def selector_mix(root: Maybe<&2, +List<U32>>, selector: U32) -> Maybe<&2, +List<+List<U32>>>:
  match root:
    case None{}: None{}
    case Some{xs}: single(Mixing.mix_in_selector(xs, selector))

def with_schema(schema: Maybe<&2, T.Schema>, next: T.Schema -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match schema:
    case None{}: None{}
    case Some{s}: next(s)

def active_chunks(active: +List<Bool>, chunks: +List<+List<U32>>) -> +List<+List<U32>>:
  match active:
    case Nil{}: []
    case Con{h, t}:
      match h:
        case False{}: P.pad(32n, []) <> active_chunks(t, chunks)
        case True{}:
          match chunks:
            case Nil{}: []
            case Con{x, xs}: x <> active_chunks(t, xs)

def active_root(roots: Maybe<&2, +List<+List<U32>>>, +active: +List<Bool>, table: +List<+List<U32>>) -> Maybe<&2, +List<+List<U32>>>:
  match roots:
    case None{}: None{}
    case Some{rs}: single(Bits.mix_length_bytes(Cached.progressive(active_chunks(active, rs), table), Some{P.pad(32n, BitPack.pack(active))}))

def accumulate(result: Maybe<&2, +List<+List<U32>>>, acc: +List<+List<U32>>, next: +List<+List<U32>> -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match result:
    case None{}: None{}
    case Some{rs}: next(List.reverse.go(&2, +List<U32>, rs, acc))

# Basic sequences pack the concatenation of their elements' own basic
# serializations (pack(values)). The parent is never serialized, so no offset
# layout or whole-object size bound enters Merkleization. Continuation-passing
# keeps the element traversal in tail position.
def basic_one(value: T.Value, schema: T.Schema) -> Maybe<&2, +List<U32>>:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: Some{P.boolean_serialize(b)}
        case _: None{}
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{w}: P.uint_serialize(w, v)
        case _: None{}
    case _: None{}

def basic_bind(one: Maybe<&2, +List<U32>>, next: +List<U32> -> Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match one:
    case None{}: None{}
    case Some{xs}: next(xs)

def basic_bytes_k(items: T.Value, +element: T.Schema, k: +List<U32> -> Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match items:
    case T.Items{h, t}: basic_bind(basic_one(h, element), x => basic_bytes_k(t, element, ys => k(Lists.append(U32, x, ys))))
    case T.EmptyItems{}: k([])
    case _: None{}

def basic_bytes(items: T.Value, +element: T.Schema) -> Maybe<&2, +List<U32>>:
  basic_bytes_k(items, element, ys => Some{ys})

def roots_go(value: T.Value, schema: T.Schema, acc: +List<+List<U32>>, +table: +List<+List<U32>>) -> Maybe<&2, +List<+List<U32>>>:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: Some{[P.boolean_root(b)]}
        case _: None{}
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{w}: single(P.uint_root(w, v))
        case _: None{}
    case T.BytesValue{xs}:
      match schema:
        case T.ByteVector{n}: single(Bytes.merkle_root(n, xs))
        case T.ByteList{n}: single(ByteList.merkle_root(n, xs))
        case _: None{}
    case T.BitsValue{+bs}:
      match schema:
        case T.BitVector{n}: single(Bits.bitvector_hash_tree_root(n, bs))
        case T.BitList{n}: single(Bits.bitlist_hash_tree_root(n, bs))
        case T.ProgressiveBits{}: single(length_mix(Cached.progressive(Bits.chunks(bs), table), Some{Lists.length(Bool, bs)}))
        case _: None{}
    case T.NullValue{}:
      match schema:
        case T.Null{}: Some{[P.pad(32n, [])]}
        case _: None{}
    case T.Items{h, t}:
      match schema:
        case T.Chain{s, rest}: accumulate(roots_go(h, s, [], table), acc, next => roots_go(t, rest, next, table))
        case T.Repeat{+s}: accumulate(roots_go(h, s, [], table), acc, next => roots_go(t, T.Repeat{s}, next, table))
        case _: None{}
    case T.EmptyItems{}:
      match schema:
        case T.End{}: Some{List.reverse(&2, +List<U32>, acc)}
        case T.Repeat{s}: Some{List.reverse(&2, +List<U32>, acc)}
        case _: None{}
    case T.Sequence{+items}:
      match schema:
        case T.Vector{+s, +n}: single(merkle(choose_chunks(S.basic_size(s), u => basic_bytes(items, s), u => roots_go(items, T.Repeat{s}, [], table)), count_limit(S.basic_size(s), n), False{}, table))
        case T.ListOf{+s, +n}: single(length_mix(merkle(choose_chunks(S.basic_size(s), u => basic_bytes(items, s), u => roots_go(items, T.Repeat{s}, [], table)), count_limit(S.basic_size(s), n), False{}, table), Some{C.count(items)}))
        case T.ProgressiveList{+s}: single(length_mix(merkle(choose_chunks(S.basic_size(s), u => basic_bytes(items, s), u => roots_go(items, T.Repeat{s}, [], table)), 0n, True{}, table), Some{C.count(items)}))
        case T.Container{names, +fields}: single(merkle(roots_go(items, fields, [], table), S.count(fields), False{}, table))
        case T.ProgressiveContainer{names, fields, active}: active_root(roots_go(items, fields, [], table), active, table)
        case _: None{}
    case T.Selected{+selector, v}:
      match schema:
        case T.Union{options}: with_schema(S.get(options, U32.to_nat(selector)), s => selector_mix(unwrap(roots_go(v, s, [], table)), selector))
        case T.CompatibleUnion{selectors, options}: with_schema(C.selected_schema(selectors, options, selector), s => selector_mix(unwrap(roots_go(v, s, [], table)), selector))
        case _: None{}

def roots(value: T.Value, +schema: T.Schema) -> Maybe<&2, +List<+List<U32>>>: roots_go(value, schema, [], Cached.zeros(Bool.pick(Nat, Nat.is_lt(S.weight(schema), 24n), S.weight(schema), 24n)))

# Runtime decision of the independent structural root domain
# (spec/value_domain.root_valid): value shape, exact vector counts, list
# capacities, byte/bit/uint ranges and union selections. No serialization,
# offset or whole-object size condition. The accumulator keeps the item
# traversal in tail position.
def valid_selected(option: Maybe<&2, T.Schema>, next: T.Schema -> Bool) -> Bool:
  match option:
    case None{}: False{}
    case Some{s}: next(s)

def valid_value(value: T.Value, schema: T.Schema, ok: Bool) -> Bool:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: ok
        case _: False{}
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{w}: Bool.and(ok, P.uint_valid(w, v))
        case _: False{}
    case T.BytesValue{xs}:
      match schema:
        case T.ByteVector{n}: Bool.and(ok, Bytes.root_valid(n, xs))
        case T.ByteList{n}: Bool.and(ok, ByteList.root_valid(n, xs))
        case _: False{}
    case T.BitsValue{bs}:
      match schema:
        case T.BitVector{n}: Bool.and(ok, Fields.vector_valid(n, bs))
        case T.BitList{n}: Bool.and(ok, Fields.list_valid(n, bs))
        case T.ProgressiveBits{}: ok
        case _: False{}
    case T.NullValue{}:
      match schema:
        case T.Null{}: ok
        case _: False{}
    case T.EmptyItems{}:
      match schema:
        case T.End{}: ok
        case T.Repeat{e}: ok
        case _: False{}
    case T.Items{h, t}:
      match schema:
        case T.Chain{s, rest}: valid_value(t, rest, Bool.and(ok, valid_value(h, s, True{})))
        case T.Repeat{+s}: valid_value(t, T.Repeat{s}, Bool.and(ok, valid_value(h, s, True{})))
        case _: False{}
    case T.Sequence{+items}:
      match schema:
        case T.Vector{s, +n}: valid_value(items, T.Repeat{s}, Bool.and(ok, Bool.and(Nat.is_lt(0n, n), Nat.is_eq(C.count(items), n))))
        case T.ListOf{s, n}: valid_value(items, T.Repeat{s}, Bool.and(ok, Nat.is_le(C.count(items), n)))
        case T.ProgressiveList{s}: valid_value(items, T.Repeat{s}, ok)
        case T.Container{names, fields}: valid_value(items, fields, ok)
        case T.ProgressiveContainer{names, fields, active}: valid_value(items, fields, ok)
        case _: False{}
    case T.Selected{+selector, v}:
      match schema:
        case T.Union{options}: Bool.and(ok, valid_selected(S.get(options, U32.to_nat(selector)), s => valid_value(v, s, True{})))
        case T.CompatibleUnion{selectors, options}: Bool.and(ok, valid_selected(C.selected_schema(selectors, options, selector), s => valid_value(v, s, True{})))
        case _: False{}

def gate(ok: Bool, next: Unit -> Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: next(Unit{})

# Public root: legal schema and structurally valid value; the uint256 length
# mixes are checked by the recursive computation itself.
def hash_tree_root(+schema: T.Schema, +value: T.Value) -> Maybe<&2, +List<U32>>:
  gate(Bool.and(S.valid(schema), valid_value(value, schema, True{})), u => unwrap(roots(value, schema)))
