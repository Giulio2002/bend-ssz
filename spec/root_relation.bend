import Base
import ../types/schema.bend as T
import ./schema.bend as Schema
import ./codec.bend as Codec
import ./primitives.bend as P
import ./packing.bend as Pack
import ./limits.bend as Limits
import ./byte_root.bend as Bytes
import ./byte_list.bend as ByteList
import ./bit_root.bend as Bits
import ./bit_packing.bend as BitPack
import ./nat_bytes.bend as Length
import ./mixing.bend as Mixing
import ./progressive.bend as Progressive

# Relational normative root semantics, for legal schemas. Existential depths
# satisfy the independent least-perfect-tree characterization. No runtime depth
# selector, cache, accumulator, traversal fuel or implementation root is used.
# The relation describes successful roots; public domain/totality and rejection
# equivalence are separate proof obligations, not assumptions of this relation.
def single(expected: Maybe<&2, +List<U32>>, outputs: +List<+List<U32>>) -> Type:
  match outputs:
    case Con{root, Nil{}}: {expected == Some{root} : Maybe<&2, +List<U32>>}
    case _: Empty

def merkle(+limit: Nat, +chunks: +List<+List<U32>>, +root: +List<U32>) -> Type:
  Exists(Nat, depth => {Limits.minimal(limit, depth) == True{} : Bool} & {Limits.at_depth(limit, depth, chunks) == Some{root} : Maybe<&2, +List<U32>>})

def tree(progressive: Bool, limit: Nat, chunks: +List<+List<U32>>, root: +List<U32>) -> Type:
  match progressive:
    case False{}: merkle(limit, chunks, root)
    case True{}: {Progressive.merkleize(chunks) == Some{root} : Maybe<&2, +List<U32>>}

def length_mixed(+root: +List<U32>, length: Maybe<&2, Nat>, outputs: +List<+List<U32>>) -> Type:
  match length:
    case None{}: {outputs == [root] : +List<+List<U32>>}
    case Some{n}: single(Bits.mix_length_bytes(Some{root}, Length.encoding(32n, n)), outputs)

def aggregate(+progressive: Bool, +limit: Nat, +chunks: +List<+List<U32>>, +length: Maybe<&2, Nat>, +outputs: +List<+List<U32>>) -> Type:
  Exists(+List<U32>, root => tree(progressive, limit, chunks, root) & length_mixed(root, length, outputs))

def basic_size(schema: T.Schema) -> Maybe<&2, Nat>:
  match schema:
    case T.Boolean{}: Some{1n}
    case T.Unsigned{w}: Some{P.byte_width(w)}
    case _: None{}

def count(fields: T.Schema) -> Nat:
  match fields:
    case T.Chain{h, t}: 1n+count(t)
    case _: 0n

# For basic sequences the independent canonical encoding is packed; composite
# sequences contribute one recursively computed root per element.
def sequence_chunks(size: Maybe<&2, Nat>, +encoded: Maybe<&2, +List<U32>>, composite: +List<+List<U32>> -> Type, +chunks: +List<+List<U32>>) -> Type:
  match size:
    case None{}: composite(chunks)
    case Some{width}:
      Exists(+List<U32>, bytes => {encoded == Some{bytes} : Maybe<&2, +List<U32>>} & {Pack.pack(bytes) == Some{chunks} : Maybe<&2, +List<+List<U32>>>})

def sequence_limit(size: Maybe<&2, Nat>, limit: Nat) -> Nat:
  match size:
    case None{}: limit
    case Some{width}: Nat.div(Nat.add(Nat.mul(limit, width), 31n), 32n)

def sequence(size: Maybe<&2, Nat>, encoded: Maybe<&2, +List<U32>>, composite: +List<+List<U32>> -> Type, +limit: Nat, +progressive: Bool, +length: Maybe<&2, Nat>, +outputs: +List<+List<U32>>) -> Type:
  Exists(+List<+List<U32>>, chunks => sequence_chunks(size, encoded, composite, chunks) & aggregate(progressive, sequence_limit(size, limit), chunks, length, outputs))

# Active-slot placement consumes exactly one field root for every set bit.
# Unlike a total truncating helper, malformed shape has no witness.
def placed(active: +List<Bool>, fields: +List<+List<U32>>, slots: +List<+List<U32>>) -> Type:
  match active fields slots:
    case Nil{} Nil{} Nil{}: Unit
    case Con{False{}, rest} fs Con{slot, tail}: {slot == P.zero_bytes(32n) : +List<U32>} & placed(rest, fs, tail)
    case Con{True{}, rest} Con{field, fs} Con{slot, tail}: {slot == field : +List<U32>} & placed(rest, fs, tail)
    case _ _ _: Empty

def active_root(+active: +List<Bool>, +fields: +List<+List<U32>>, +outputs: +List<+List<U32>>) -> Type:
  Exists(+List<+List<U32>>, slots => placed(active, fields, slots) & Exists(+List<U32>, root => {Progressive.merkleize(slots) == Some{root} : Maybe<&2, +List<U32>>} & single(Bits.mix_length_bytes(Some{root}, Some{List.append(&2, U32, BitPack.pack(active), P.zero_bytes(Nat.sub(32n, List.length(&2, U32, BitPack.pack(active)))))}), outputs)))

def selected(option: Maybe<&2, T.Schema>, relation: T.Schema -> Type) -> Type:
  match option:
    case None{}: Empty
    case Some{schema}: relation(schema)

def roots(value: T.Value, schema: T.Schema, +outputs: +List<+List<U32>>) -> Type:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: single(Some{List.append(&2, U32, P.boolean_encoding(b), P.zero_bytes(31n))}, outputs)
        case _: Empty
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{w}: single(P.uint_hash_tree_root(w, v), outputs)
        case _: Empty
    case T.BytesValue{+bytes}:
      match schema:
        case T.ByteVector{+n}: Exists(Nat, depth => {Bytes.canonical_depth(bytes, depth) == True{} : Bool} & single(Bytes.at_depth(n, depth, bytes), outputs))
        case T.ByteList{+n}: Exists(Nat, depth => {Limits.minimal(ByteList.chunk_limit(n), depth) == True{} : Bool} & single(ByteList.at_depth(n, depth, bytes), outputs))
        case _: Empty
    case T.BitsValue{+bits}:
      match schema:
        case T.BitVector{+n}: Exists(Nat, depth => {Bits.canonical_depth(n, depth) == True{} : Bool} & single(Bits.bitvector_at_depth(n, depth, bits), outputs))
        case T.BitList{+n}: Exists(Nat, depth => {Bits.canonical_depth(n, depth) == True{} : Bool} & single(Bits.bitlist_at_depth(n, depth, bits), outputs))
        case T.ProgressiveBits{}: aggregate(True{}, 0n, Bits.chunks(bits), Some{List.length(&2, Bool, bits)}, outputs)
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
        case T.Vector{+s, +n}: sequence(basic_size(s), Codec.encoding_for_legal_type(T.Vector{s, n}, T.Sequence{items}), chunks => roots(items, T.Repeat{s}, chunks), n, False{}, None{}, outputs)
        case T.ListOf{+s, +n}: sequence(basic_size(s), Codec.encoding_for_legal_type(T.ListOf{s, n}, T.Sequence{items}), chunks => roots(items, T.Repeat{s}, chunks), n, False{}, Some{Codec.count(items)}, outputs)
        case T.ProgressiveList{+s}: sequence(basic_size(s), Codec.encoding_for_legal_type(T.ProgressiveList{s}, T.Sequence{items}), chunks => roots(items, T.Repeat{s}, chunks), 0n, True{}, Some{Codec.count(items)}, outputs)
        case T.Container{names, +fields}: Exists(+List<+List<U32>>, chunks => roots(items, fields, chunks) & aggregate(False{}, count(fields), chunks, None{}, outputs))
        case T.ProgressiveContainer{names, +fields, +active}: Exists(+List<+List<U32>>, chunks => roots(items, fields, chunks) & active_root(active, chunks, outputs))
        case _: Empty
    case T.Selected{+selector, +v}:
      match schema:
        case T.Union{options}: selected(Schema.option(options, U32.to_nat(selector)), s => Exists(+List<U32>, root => roots(v, s, [root]) & single(Mixing.mix_in_selector(root, selector), outputs)))
        case T.CompatibleUnion{selectors, options}: selected(Schema.compatible_option(selectors, options, selector), s => Exists(+List<U32>, root => roots(v, s, [root]) & single(Mixing.mix_in_selector(root, selector), outputs)))
        case _: Empty

def root_for_legal_type(+schema: T.Schema, +value: T.Value, output: +List<U32>) -> Type:
  Exists(+List<U32>, encoded => {Codec.encoding_for_legal_type(schema, value) == Some{encoded} : Maybe<&2, +List<U32>>}) & roots(value, schema, [output])
