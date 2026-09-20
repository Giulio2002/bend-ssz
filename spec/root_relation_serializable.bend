import Base
import ../types/schema.bend as T
import ./schema.bend as Schema
import ./codec.bend as Codec
import ./primitives.bend as P
import ./byte_root.bend as Bytes
import ./byte_list.bend as ByteList
import ./bit_root.bend as Bits
import ./mixing.bend as Mixing
import ./limits.bend as Limits
import ./root_relation.bend as R

# SERIALIZABLE-DOMAIN ROOT RELATION: the pre-correction root relation.
# `roots` and `root_for_legal_type` below are the previous snapshot's
# definitions verbatim, except that the helper definitions single, merkle,
# tree, length_mixed, aggregate, basic_size, count, sequence_chunks,
# sequence_limit, sequence, placed, active_root and selected -- which are
# textually identical in both snapshots (checked by
# tools/generate_root_domain_compat.py) -- are referenced from
# spec/root_relation.bend instead of being duplicated. Differences from the
# current relation: root_for_legal_type requires a whole-object normative
# encoding; basic sequences are packed from the whole-PARENT encoding; the
# ByteVector / ByteList leaves use the serialization-gated protected leaf
# specifications. Retained ONLY to state serializable_root_compatibility.
def roots(value: T.Value, schema: T.Schema, +outputs: +List<+List<U32>>) -> Type:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: R.single(Some{List.append(&2, U32, P.boolean_encoding(b), P.zero_bytes(31n))}, outputs)
        case _: Empty
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{w}: R.single(P.uint_hash_tree_root(w, v), outputs)
        case _: Empty
    case T.BytesValue{+bytes}:
      match schema:
        case T.ByteVector{+n}: Exists(Nat, depth => {Bytes.canonical_depth(bytes, depth) == True{} : Bool} & R.single(Bytes.at_depth(n, depth, bytes), outputs))
        case T.ByteList{+n}: Exists(Nat, depth => {Limits.minimal(ByteList.chunk_limit(n), depth) == True{} : Bool} & R.single(ByteList.at_depth(n, depth, bytes), outputs))
        case _: Empty
    case T.BitsValue{+bits}:
      match schema:
        case T.BitVector{+n}: Exists(Nat, depth => {Bits.canonical_depth(n, depth) == True{} : Bool} & R.single(Bits.bitvector_at_depth(n, depth, bits), outputs))
        case T.BitList{+n}: Exists(Nat, depth => {Bits.canonical_depth(n, depth) == True{} : Bool} & R.single(Bits.bitlist_at_depth(n, depth, bits), outputs))
        case T.ProgressiveBits{}: R.aggregate(True{}, 0n, Bits.chunks(bits), Some{List.length(&2, Bool, bits)}, outputs)
        case _: Empty
    case T.NullValue{}:
      match schema:
        case T.Null{}: {outputs == [P.zero_bytes(32n)] : +List<+List<U32>>}
        case _: Empty
    case T.EmptyItems{}:
      match schema:
        case T.End{}: {outputs == [] : +List<+List<U32>>}
        case T.Repeat{e}: {outputs == [] : +List<+List<U32>>}
        case _: Empty
    case T.Items{+h, +t}:
      match schema:
        case T.Chain{+s, +rest}: Exists(+List<+List<U32>>, head => Exists(+List<+List<U32>>, tail => roots(h, s, head) & roots(t, rest, tail) & {outputs == List.append(&2, +List<U32>, head, tail) : +List<+List<U32>>}))
        case T.Repeat{+s}: Exists(+List<+List<U32>>, head => Exists(+List<+List<U32>>, tail => roots(h, s, head) & roots(t, T.Repeat{s}, tail) & {outputs == List.append(&2, +List<U32>, head, tail) : +List<+List<U32>>}))
        case _: Empty
    case T.Sequence{+items}:
      match schema:
        case T.Vector{+s, +n}: R.sequence(R.basic_size(s), Codec.encoding_for_legal_type(T.Vector{s, n}, T.Sequence{items}), chunks => roots(items, T.Repeat{s}, chunks), n, False{}, None{}, outputs)
        case T.ListOf{+s, +n}: R.sequence(R.basic_size(s), Codec.encoding_for_legal_type(T.ListOf{s, n}, T.Sequence{items}), chunks => roots(items, T.Repeat{s}, chunks), n, False{}, Some{Codec.count(items)}, outputs)
        case T.ProgressiveList{+s}: R.sequence(R.basic_size(s), Codec.encoding_for_legal_type(T.ProgressiveList{s}, T.Sequence{items}), chunks => roots(items, T.Repeat{s}, chunks), 0n, True{}, Some{Codec.count(items)}, outputs)
        case T.Container{names, +fields}: Exists(+List<+List<U32>>, chunks => roots(items, fields, chunks) & R.aggregate(False{}, R.count(fields), chunks, None{}, outputs))
        case T.ProgressiveContainer{names, +fields, +active}: Exists(+List<+List<U32>>, chunks => roots(items, fields, chunks) & R.active_root(active, chunks, outputs))
        case _: Empty
    case T.Selected{+selector, +v}:
      match schema:
        case T.Union{options}: R.selected(Schema.option(options, U32.to_nat(selector)), s => Exists(+List<U32>, root => roots(v, s, [root]) & R.single(Mixing.mix_in_selector(root, selector), outputs)))
        case T.CompatibleUnion{selectors, options}: R.selected(Schema.compatible_option(selectors, options, selector), s => Exists(+List<U32>, root => roots(v, s, [root]) & R.single(Mixing.mix_in_selector(root, selector), outputs)))
        case _: Empty

def root_for_legal_type(+schema: T.Schema, +value: T.Value, output: +List<U32>) -> Type:
  Exists(+List<U32>, encoded => {Codec.encoding_for_legal_type(schema, value) == Some{encoded} : Maybe<&2, +List<U32>>}) & roots(value, schema, [output])

def serializable_root_for_legal_type(+schema: T.Schema, +value: T.Value, output: +List<U32>) -> Type:
  root_for_legal_type(schema, value, output)
