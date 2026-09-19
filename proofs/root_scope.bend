import Base
import ../src/ssz.bend as API
import ../src/schema.bend as Schema
import ../src/codec.bend as Codec
import ../src/lists.bend as Lists
import ../src/byte_root.bend as ByteRoot
import ../src/byte_list.bend as ByteList
import ./byte_root.bend as ByteRootLaws
import ./byte_list.bend as ByteListLaws
import ./bit_root.bend as BitRootLaws
import ./bit_list_root.bend as BitListLaws
import ../src/bit_packing.bend as BitPack
import ../types/schema.bend as T
import ../types/primitive.bend as Types
import ../src/root.bend as I
import ../src/primitives.bend as P
import ../src/bit_root.bend as Bits
import ../src/merkle.bend as Node
import ../src/sha256.bend as Hash
import ../src/cached_tree.bend as Cache
import ../src/limits.bend as Limits
import ../src/progressive.bend as Progressive
import ../src/nat_bytes.bend as Length
import ../src/mixing.bend as Mixing
import ../spec/primitives.bend as SP
import ../spec/packing.bend as Chunks
import ./tree.bend as Tree
import ./primitive_invariants.bend as V
import ./primitives.bend as Basic
import ./basic_root.bend as BasicRoot
import ./packing.bend as Pack
import ./merkle.bend as Nodes
import ./cached_tree.bend as Cached
import ./limits.bend as LimitLaws
import ./progressive.bend as ProgressiveLaws
import ../HASH_PROOF.bend as SHA

# Scope is only successful-output shape/content range, not root correctness
# or valid-value totality. All inputs and every cache size are quantified.
def roots_scope(result: Maybe<&2, +List<+List<U32>>>) -> Type:
  match result:
    case None{}: Unit
    case Some{roots}: {Chunks.chunks_domain(roots) == True{} : Bool}

law single_scope:
  for +root: Maybe<&2, +List<U32>>
  for scoped: Tree.result_scope(root)
  roots_scope(I.single(root))
def single_scope(root, scoped):
  match root:
    case None{}: Unit{}
    case Some{xs}: V.and_true(SP.byte_scope(32n, xs), True{}, scoped, {==})

law unwrap_scope:
  for +result: Maybe<&2, +List<+List<U32>>>
  for scoped: roots_scope(result)
  Tree.result_scope(I.unwrap(result))
def unwrap_scope(result, scoped):
  match result:
    case None{}: Unit{}
    case Some{roots}:
      match roots:
        case Nil{}: Unit{}
        case Con{h, t}:
          match t:
            case Nil{}: V.and_left(SP.byte_scope(32n, h), True{}, scoped)
            case Con{x, xs}: Unit{}

law pair_scope:
  for +ok: Bool
  for +left: +List<U32>
  for +right: +List<U32>
  Tree.result_scope(Node.pair_checked(ok, left, right))
def pair_scope(ok, left, right):
  match ok:
    case False{}: Unit{}
    case True{}: Pack.scope_from_size(Hash.hash(List.append(&2, U32, left, right)), 32n, SHA.hash_length(List.append(&2, U32, left, right)), Nodes.runtime_hash_bytes(List.append(&2, U32, left, right)))

law mix_scope:
  for +root: Maybe<&2, +List<U32>>
  for +length: Maybe<&2, +List<U32>>
  Tree.result_scope(Bits.mix_length_bytes(root, length))
def mix_scope(root, length):
  match root length:
    case None{} None{}: Unit{}
    case None{} Some{ys}: Unit{}
    case Some{xs} None{}: Unit{}
    case Some{xs} Some{ys}: pair_scope(Bool.and(P.valid_bytes(32n, xs), P.valid_bytes(32n, ys)), xs, ys)

law length_mix_scope:
  for +root: Maybe<&2, +List<U32>>
  for +count: Maybe<&2, Nat>
  for scoped: Tree.result_scope(root)
  Tree.result_scope(I.length_mix(root, count))
def length_mix_scope(root, count, scoped):
  match count:
    case None{}: scoped
    case Some{n}: mix_scope(root, Length.encode(32n, n))

law selector_scope:
  for +root: Maybe<&2, +List<U32>>
  for +selector: U32
  roots_scope(I.selector_mix(root, selector))
def selector_scope(root, selector):
  match root:
    case None{}: Unit{}
    case Some{xs}: single_scope(Mixing.mix_in_selector(xs, selector), pair_scope(Bool.and(P.valid_bytes(32n, xs), U32.is_lt(selector, 256)), xs, P.pad(32n, [selector])))

law merkle_scope:
  for +chunks: Maybe<&2, +List<+List<U32>>>
  for +limit: Nat
  for +progressive: Bool
  for +size: Nat
  Tree.result_scope(I.merkle(chunks, limit, progressive, Cache.zeros(size)))
def merkle_scope(chunks, limit, progressive, size):
  match chunks:
    case None{}: Unit{}
    case Some{xs}:
      match progressive:
        case False{}:
          %Equal.sym(Maybe<&2, +List<U32>>, Cache.merkleize(limit, xs, Cache.zeros(size)), Limits.merkleize(limit, xs), Cached.merkleize_correct(limit, xs, size)) : Tree.result_scope(_)
          LimitLaws.merkleize_scope(limit, xs)
        case True{}:
          %Equal.sym(Maybe<&2, +List<U32>>, Cache.progressive(xs, Cache.zeros(size)), Progressive.merkleize(xs), Cached.progressive_correct(xs, size)) : Tree.result_scope(_)
          ProgressiveLaws.merkleize_scope(xs)

law active_scope:
  for +roots: Maybe<&2, +List<+List<U32>>>
  for +active: +List<Bool>
  for +table: +List<+List<U32>>
  roots_scope(I.active_root(roots, active, table))
def active_scope(roots, active, table):
  match roots:
    case None{}: Unit{}
    case Some{rs}: single_scope(Bits.mix_length_bytes(Cache.progressive(I.active_chunks(active, rs), table), Some{P.pad(32n, BitPack.pack(active))}), mix_scope(Cache.progressive(I.active_chunks(active, rs), table), Some{P.pad(32n, BitPack.pack(active))}))

law padded_scope:
  for +xs: +List<U32>
  for valid: {SP.bytes_domain(xs) == True{} : Bool}
  {SP.byte_scope(32n, P.pad(32n, xs)) == True{} : Bool}
def padded_scope(xs, valid): Pack.scope_from_size(P.pad(32n, xs), 32n, Basic.padded_length(32n, xs), BasicRoot.pad_preserves_domain(32n, xs, valid))

law integer_checked_scope:
  for +result: Maybe<&2, +List<U32>>
  for valid: V.byte_result(result)
  Tree.result_scope(P.root_checked(result))
def integer_checked_scope(result, valid):
  match result:
    case None{}: Unit{}
    case Some{xs}: padded_scope(xs, valid)

law integer_scope:
  for +width: Types.Width
  for +value: Types.UInt
  Tree.result_scope(P.uint_root(width, value))
def integer_scope(width, value): integer_checked_scope(P.uint_serialize(width, value), V.uint_serialized_bytes(width, value))

law reverse_scope:
  for +xs: +List<+List<U32>>
  for +acc: +List<+List<U32>>
  for +xs_scope: {Chunks.chunks_domain(xs) == True{} : Bool}
  for acc_scope: {Chunks.chunks_domain(acc) == True{} : Bool}
  {Chunks.chunks_domain(List.reverse.go(&2, +List<U32>, xs, acc)) == True{} : Bool}
def reverse_scope(xs, acc, xs_scope, acc_scope):
  match xs:
    case Nil{}: acc_scope
    case Con{h, t}: reverse_scope(t, h <> acc, V.and_right(SP.byte_scope(32n, h), Chunks.chunks_domain(t), xs_scope), V.and_true(SP.byte_scope(32n, h), Chunks.chunks_domain(acc), V.and_left(SP.byte_scope(32n, h), Chunks.chunks_domain(t), xs_scope), acc_scope))

law accumulate_scope:
  for +result: Maybe<&2, +List<+List<U32>>>
  for +acc: +List<+List<U32>>
  for -next: +List<+List<U32>> -> Maybe<&2, +List<+List<U32>>>
  for result_valid: roots_scope(result)
  for acc_valid: {Chunks.chunks_domain(acc) == True{} : Bool}
  for recur: @+new_acc: +List<+List<U32>> -> {Chunks.chunks_domain(new_acc) == True{} : Bool} -> roots_scope(next(new_acc))
  roots_scope(I.accumulate(result, acc, next))
def accumulate_scope(result, acc, next, result_valid, acc_valid, recur):
  match result:
    case None{}: Unit{}
    case Some{rs}: recur(List.reverse.go(&2, +List<U32>, rs, acc), reverse_scope(rs, acc, result_valid, acc_valid))

law option_scope:
  for +option: Maybe<&2, T.Schema>
  for -next: T.Schema -> Maybe<&2, +List<+List<U32>>>
  for recur: @+s: T.Schema -> roots_scope(next(s))
  roots_scope(I.with_schema(option, next))
def option_scope(option, next, recur):
  match option:
    case None{}: Unit{}
    case Some{s}: recur(s)
# Generated structural public scope composition.
law boolean_scope:
  for +b: Bool
  {SP.byte_scope(32n, P.boolean_root(b)) == True{} : Bool}
def boolean_scope(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law roots_go_scope:
  for +value: T.Value
  for +schema: T.Schema
  for +acc: +List<+List<U32>>
  for +size: Nat
  for valid: {Chunks.chunks_domain(acc) == True{} : Bool}
  roots_scope(I.roots_go(value, schema, acc, Cache.zeros(size)))
def roots_go_scope(value, schema, acc, size, valid):
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: V.and_true(SP.byte_scope(32n, P.boolean_root(b)), True{}, boolean_scope(b), {==})
        case T.Unsigned{x0}: Unit{}
        case T.ByteVector{x0}: Unit{}
        case T.ByteList{x0}: Unit{}
        case T.BitVector{x0}: Unit{}
        case T.BitList{x0}: Unit{}
        case T.Vector{x0, x1}: Unit{}
        case T.ListOf{x0, x1}: Unit{}
        case T.Container{x0, x1}: Unit{}
        case T.Union{x0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{x0, x1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{x0}: Unit{}
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{x0, x1, x2}: Unit{}
        case T.CompatibleUnion{x0, x1}: Unit{}
    case T.UnsignedValue{v}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{x0}: single_scope(P.uint_root(x0, v), integer_scope(x0, v))
        case T.ByteVector{x0}: Unit{}
        case T.ByteList{x0}: Unit{}
        case T.BitVector{x0}: Unit{}
        case T.BitList{x0}: Unit{}
        case T.Vector{x0, x1}: Unit{}
        case T.ListOf{x0, x1}: Unit{}
        case T.Container{x0, x1}: Unit{}
        case T.Union{x0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{x0, x1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{x0}: Unit{}
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{x0, x1, x2}: Unit{}
        case T.CompatibleUnion{x0, x1}: Unit{}
    case T.BytesValue{xs}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{x0}: Unit{}
        case T.ByteVector{x0}: single_scope(ByteRoot.hash_tree_root(x0, xs), ByteRootLaws.hash_tree_root_scope(x0, xs))
        case T.ByteList{x0}: single_scope(ByteList.hash_tree_root(x0, xs), ByteListLaws.root_scope(x0, xs))
        case T.BitVector{x0}: Unit{}
        case T.BitList{x0}: Unit{}
        case T.Vector{x0, x1}: Unit{}
        case T.ListOf{x0, x1}: Unit{}
        case T.Container{x0, x1}: Unit{}
        case T.Union{x0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{x0, x1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{x0}: Unit{}
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{x0, x1, x2}: Unit{}
        case T.CompatibleUnion{x0, x1}: Unit{}
    case T.BitsValue{bits}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{x0}: Unit{}
        case T.ByteVector{x0}: Unit{}
        case T.ByteList{x0}: Unit{}
        case T.BitVector{x0}: single_scope(Bits.bitvector_hash_tree_root(x0, bits), BitRootLaws.bitvector_root_scope(x0, bits))
        case T.BitList{x0}: single_scope(Bits.bitlist_hash_tree_root(x0, bits), BitListLaws.bitlist_root_scope(x0, bits))
        case T.Vector{x0, x1}: Unit{}
        case T.ListOf{x0, x1}: Unit{}
        case T.Container{x0, x1}: Unit{}
        case T.Union{x0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{x0, x1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{x0}: Unit{}
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: Unit{}
        case T.ProgressiveBits{}: single_scope(I.length_mix(Cache.progressive(Bits.chunks(bits), Cache.zeros(size)), Some{Lists.length(Bool, bits)}), mix_scope(Cache.progressive(Bits.chunks(bits), Cache.zeros(size)), Length.encode(32n, Lists.length(Bool, bits))))
        case T.ProgressiveContainer{x0, x1, x2}: Unit{}
        case T.CompatibleUnion{x0, x1}: Unit{}
    case T.NullValue{}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{x0}: Unit{}
        case T.ByteVector{x0}: Unit{}
        case T.ByteList{x0}: Unit{}
        case T.BitVector{x0}: Unit{}
        case T.BitList{x0}: Unit{}
        case T.Vector{x0, x1}: Unit{}
        case T.ListOf{x0, x1}: Unit{}
        case T.Container{x0, x1}: Unit{}
        case T.Union{x0}: Unit{}
        case T.Null{}: V.and_true(SP.byte_scope(32n, P.pad(32n, [])), True{}, padded_scope([], {==}), {==})
        case T.Chain{x0, x1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{x0}: Unit{}
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{x0, x1, x2}: Unit{}
        case T.CompatibleUnion{x0, x1}: Unit{}
    case T.EmptyItems{}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{x0}: Unit{}
        case T.ByteVector{x0}: Unit{}
        case T.ByteList{x0}: Unit{}
        case T.BitVector{x0}: Unit{}
        case T.BitList{x0}: Unit{}
        case T.Vector{x0, x1}: Unit{}
        case T.ListOf{x0, x1}: Unit{}
        case T.Container{x0, x1}: Unit{}
        case T.Union{x0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{x0, x1}: Unit{}
        case T.End{}: reverse_scope(acc, [], valid, {==})
        case T.Repeat{x0}: reverse_scope(acc, [], valid, {==})
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{x0, x1, x2}: Unit{}
        case T.CompatibleUnion{x0, x1}: Unit{}
    case T.Items{h, t}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{x0}: Unit{}
        case T.ByteVector{x0}: Unit{}
        case T.ByteList{x0}: Unit{}
        case T.BitVector{x0}: Unit{}
        case T.BitList{x0}: Unit{}
        case T.Vector{x0, x1}: Unit{}
        case T.ListOf{x0, x1}: Unit{}
        case T.Container{x0, x1}: Unit{}
        case T.Union{x0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{x0, x1}: accumulate_scope(I.roots_go(h, x0, [], Cache.zeros(size)), acc, next => I.roots_go(t, x1, next, Cache.zeros(size)), roots_go_scope(h, x0, [], size, {==}), valid, next => scope => roots_go_scope(t, x1, next, size, scope))
        case T.End{}: Unit{}
        case T.Repeat{x0}: accumulate_scope(I.roots_go(h, x0, [], Cache.zeros(size)), acc, next => I.roots_go(t, T.Repeat{x0}, next, Cache.zeros(size)), roots_go_scope(h, x0, [], size, {==}), valid, next => scope => roots_go_scope(t, T.Repeat{x0}, next, size, scope))
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{x0, x1, x2}: Unit{}
        case T.CompatibleUnion{x0, x1}: Unit{}
    case T.Sequence{items}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{x0}: Unit{}
        case T.ByteVector{x0}: Unit{}
        case T.ByteList{x0}: Unit{}
        case T.BitVector{x0}: Unit{}
        case T.BitList{x0}: Unit{}
        case T.Vector{x0, x1}: single_scope(I.merkle(I.choose_chunks(Schema.basic_size(x0), u => Codec.unwrap(Codec.encode(T.Sequence{items}, T.Vector{x0, x1})), u => I.roots_go(items, T.Repeat{x0}, [], Cache.zeros(size))), I.count_limit(Schema.basic_size(x0), x1), False{}, Cache.zeros(size)), merkle_scope(I.choose_chunks(Schema.basic_size(x0), u => Codec.unwrap(Codec.encode(T.Sequence{items}, T.Vector{x0, x1})), u => I.roots_go(items, T.Repeat{x0}, [], Cache.zeros(size))), I.count_limit(Schema.basic_size(x0), x1), False{}, size))
        case T.ListOf{x0, x1}: single_scope(I.length_mix(I.merkle(I.choose_chunks(Schema.basic_size(x0), u => Codec.unwrap(Codec.encode(T.Sequence{items}, T.ListOf{x0, x1})), u => I.roots_go(items, T.Repeat{x0}, [], Cache.zeros(size))), I.count_limit(Schema.basic_size(x0), x1), False{}, Cache.zeros(size)), Some{Codec.count(items)}), mix_scope(I.merkle(I.choose_chunks(Schema.basic_size(x0), u => Codec.unwrap(Codec.encode(T.Sequence{items}, T.ListOf{x0, x1})), u => I.roots_go(items, T.Repeat{x0}, [], Cache.zeros(size))), I.count_limit(Schema.basic_size(x0), x1), False{}, Cache.zeros(size)), Length.encode(32n, Codec.count(items))))
        case T.Container{x0, x1}: single_scope(I.merkle(I.roots_go(items, x1, [], Cache.zeros(size)), Schema.count(x1), False{}, Cache.zeros(size)), merkle_scope(I.roots_go(items, x1, [], Cache.zeros(size)), Schema.count(x1), False{}, size))
        case T.Union{x0}: Unit{}
        case T.Null{}: Unit{}
        case T.Chain{x0, x1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{x0}: Unit{}
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: single_scope(I.length_mix(I.merkle(I.choose_chunks(Schema.basic_size(x0), u => Codec.unwrap(Codec.encode(T.Sequence{items}, T.ProgressiveList{x0})), u => I.roots_go(items, T.Repeat{x0}, [], Cache.zeros(size))), 0n, True{}, Cache.zeros(size)), Some{Codec.count(items)}), mix_scope(I.merkle(I.choose_chunks(Schema.basic_size(x0), u => Codec.unwrap(Codec.encode(T.Sequence{items}, T.ProgressiveList{x0})), u => I.roots_go(items, T.Repeat{x0}, [], Cache.zeros(size))), 0n, True{}, Cache.zeros(size)), Length.encode(32n, Codec.count(items))))
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{x0, x1, x2}: active_scope(I.roots_go(items, x1, [], Cache.zeros(size)), x2, Cache.zeros(size))
        case T.CompatibleUnion{x0, x1}: Unit{}
    case T.Selected{selector, v}:
      match schema:
        case T.Boolean{}: Unit{}
        case T.Unsigned{x0}: Unit{}
        case T.ByteVector{x0}: Unit{}
        case T.ByteList{x0}: Unit{}
        case T.BitVector{x0}: Unit{}
        case T.BitList{x0}: Unit{}
        case T.Vector{x0, x1}: Unit{}
        case T.ListOf{x0, x1}: Unit{}
        case T.Container{x0, x1}: Unit{}
        case T.Union{x0}: option_scope(Schema.get(x0, U32.to_nat(selector)), s => I.selector_mix(I.unwrap(I.roots_go(v, s, [], Cache.zeros(size))), selector), s => selector_scope(I.unwrap(I.roots_go(v, s, [], Cache.zeros(size))), selector))
        case T.Null{}: Unit{}
        case T.Chain{x0, x1}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{x0}: Unit{}
        case T.Named{x0, x1}: Unit{}
        case T.ProgressiveList{x0}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{x0, x1, x2}: Unit{}
        case T.CompatibleUnion{x0, x1}: option_scope(Codec.selected_schema(x0, x1, selector), s => I.selector_mix(I.unwrap(I.roots_go(v, s, [], Cache.zeros(size))), selector), s => selector_scope(I.unwrap(I.roots_go(v, s, [], Cache.zeros(size))), selector))

law roots_public_scope:
  for +schema: T.Schema
  for +value: T.Value
  roots_scope(I.roots(value, schema))
def roots_public_scope(schema, value):
  roots_go_scope(value, schema, [], Bool.pick(Nat, Nat.is_lt(Schema.weight(schema), 24n), Schema.weight(schema), 24n), {==})

law root_gate_scope:
  for +ok: Bool
  for +schema: T.Schema
  for +value: T.Value
  Tree.result_scope(I.gate(ok, u => I.unwrap(I.roots(value, schema))))
def root_gate_scope(ok, schema, value):
  match ok:
    case False{}: Unit{}
    case True{}: unwrap_scope(I.roots(value, schema), roots_public_scope(schema, value))

law hash_tree_root_scope:
  for +schema: T.Schema
  for +value: T.Value
  Tree.result_scope(I.hash_tree_root(schema, value))
def hash_tree_root_scope(schema, value): root_gate_scope(Codec.valid(schema, value), schema, value)

law accepted_root_scope:
  for +schema: T.Schema
  for +value: T.Value
  for +root: +List<U32>
  for accepted: {I.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}
  {SP.byte_scope(32n, root) == True{} : Bool}
def accepted_root_scope(schema, value, root, accepted):
  %accepted : Tree.result_scope(_)
  hash_tree_root_scope(schema, value)

# The exported standalone API is definitionally the root implementation above.
law public_root_scope:
  for +schema: T.Schema
  for +value: T.Value
  Tree.result_scope(API.hash_tree_root(schema, value))
def public_root_scope(schema, value): hash_tree_root_scope(schema, value)

law public_root_length:
  for +schema: T.Schema
  for +value: T.Value
  {Basic.lengths(API.hash_tree_root(schema, value)) == Basic.expected_root_length(API.hash_tree_root(schema, value)) : Maybe<&2, Nat>}
def public_root_length(schema, value):
  Tree.result_length(API.hash_tree_root(schema, value), public_root_scope(schema, value))
