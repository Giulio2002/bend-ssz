import Base
import ../types/schema.bend as T
import ./codec.bend as Codec
import ./schema.bend as Schema
import ./nat_bytes.bend as Length
import ./primitives.bend as P
import ./bitfields.bend as Fields

# Canonical serialization domain for a legal type, defined only by the
# independent normative byte formula. Type legality is a separate obligation.
def present(result: Maybe<&2, +List<U32>>) -> Bool:
  match result:
    case None{}: False{}
    case Some{bytes}: True{}

def serializable(schema: T.Schema, value: T.Value) -> Bool:
  present(Codec.encoding_for_legal_type(schema, value))

def selected(option: Maybe<&2, T.Schema>, next: T.Schema -> Bool) -> Bool:
  match option:
    case None{}: False{}
    case Some{schema}: next(schema)

# The SSZ length mixer is uint256, not a native machine integer. This separate
# recursive condition makes its mathematical representability obligation
# explicit even for unbounded progressive bitlists. It is not a resource limit.
def mixing_lengths(value: T.Value, schema: T.Schema) -> Bool:
  match value:
    case T.BitsValue{bits}:
      match schema:
        case T.BitList{n}: Length.fits(32n, List.length(&2, Bool, bits))
        case T.ProgressiveBits{}: Length.fits(32n, List.length(&2, Bool, bits))
        case _: True{}
    case T.BytesValue{bytes}:
      match schema:
        case T.ByteList{n}: Length.fits(32n, List.length(&2, U32, bytes))
        case _: True{}
    case T.Items{h, t}:
      match schema:
        case T.Chain{s, rest}: Bool.and(mixing_lengths(h, s), mixing_lengths(t, rest))
        case T.Repeat{+s}: Bool.and(mixing_lengths(h, s), mixing_lengths(t, T.Repeat{s}))
        case _: False{}
    case T.Sequence{+items}:
      match schema:
        case T.Vector{s, n}: mixing_lengths(items, T.Repeat{s})
        case T.ListOf{s, n}: Bool.and(Length.fits(32n, Codec.count(items)), mixing_lengths(items, T.Repeat{s}))
        case T.ProgressiveList{s}: Bool.and(Length.fits(32n, Codec.count(items)), mixing_lengths(items, T.Repeat{s}))
        case T.Container{names, fields}: mixing_lengths(items, fields)
        case T.ProgressiveContainer{names, fields, active}: mixing_lengths(items, fields)
        case _: False{}
    case T.Selected{+selector, v}:
      match schema:
        case T.Union{options}: selected(Schema.option(options, U32.to_nat(selector)), s => mixing_lengths(v, s))
        case T.CompatibleUnion{selectors, options}: selected(Schema.compatible_option(selectors, options, selector), s => mixing_lengths(v, s))
        case _: False{}
    case _: True{}

# ---------------------------------------------------------------------------
# Independent STRUCTURAL root domain (simple-serialize.md, Typing and
# Merkleization). A value is root-valid for a schema when it has the schema's
# shape and satisfies the type's value constraints: boolean; uintN range;
# ByteVector[N] exactly N bytes (N > 0); ByteList[N] at most N bytes; bytes in
# 0..255; Bitvector[N] exactly N bits (N > 0); Bitlist[N] at most N bits;
# Vector[T, N] exactly N elements; List[T, N] at most N elements; container
# fields in declaration order; union / compatible-union selector naming an
# option, with the value of that option. Type legality is the separate
# spec/type_legality judgement. Merkleization recurses over child roots
# and packs basic objects only, so NO serialization, offset or whole-object
# 2^32 size condition appears here.
def items_length(items: T.Value) -> Nat:
  match items:
    case T.Items{h, t}: 1n+items_length(t)
    case _: 0n

def bytevector_domain(+n: Nat, xs: +List<U32>) -> Bool:
  match n:
    case 0n: False{}
    case 1n+p: P.byte_scope(1n+p, xs)

def bytelist_domain(+capacity: Nat, +xs: +List<U32>) -> Bool:
  Bool.and(P.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), capacity))

def root_valid(value: T.Value, schema: T.Schema) -> Bool:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: True{}
        case _: False{}
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{w}: P.uint_domain(w, v)
        case _: False{}
    case T.BytesValue{bytes}:
      match schema:
        case T.ByteVector{n}: bytevector_domain(n, bytes)
        case T.ByteList{n}: bytelist_domain(n, bytes)
        case _: False{}
    case T.BitsValue{bits}:
      match schema:
        case T.BitVector{n}: Fields.vector_domain(n, bits)
        case T.BitList{n}: Fields.list_domain(n, bits)
        case T.ProgressiveBits{}: True{}
        case _: False{}
    case T.NullValue{}:
      match schema:
        case T.Null{}: True{}
        case _: False{}
    case T.EmptyItems{}:
      match schema:
        case T.End{}: True{}
        case T.Repeat{e}: True{}
        case _: False{}
    case T.Items{h, t}:
      match schema:
        case T.Chain{s, rest}: Bool.and(root_valid(h, s), root_valid(t, rest))
        case T.Repeat{+s}: Bool.and(root_valid(h, s), root_valid(t, T.Repeat{s}))
        case _: False{}
    case T.Sequence{+items}:
      match schema:
        case T.Vector{s, +n}: Bool.and(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(items_length(items), n)), root_valid(items, T.Repeat{s}))
        case T.ListOf{s, n}: Bool.and(Nat.is_le(items_length(items), n), root_valid(items, T.Repeat{s}))
        case T.ProgressiveList{s}: root_valid(items, T.Repeat{s})
        case T.Container{names, fields}: root_valid(items, fields)
        case T.ProgressiveContainer{names, fields, active}: root_valid(items, fields)
        case _: False{}
    case T.Selected{+selector, v}:
      match schema:
        case T.Union{options}: selected(Schema.option(options, U32.to_nat(selector)), s => root_valid(v, s))
        case T.CompatibleUnion{selectors, options}: selected(Schema.compatible_option(selectors, options, selector), s => root_valid(v, s))
        case _: False{}

# Root domain: structural validity plus the normative uint256 representability
# of every mixed length (mix_in_length serializes len(value) as uint256).
def root_domain(+schema: T.Schema, +value: T.Value) -> Bool:
  Bool.and(root_valid(value, schema), mixing_lengths(value, schema))

# The PREVIOUS (pre-correction) root domain, retained under an explicit name
# for serializable_root_compatibility: a whole-object normative encoding
# exists, and every mixed length is a uint256.
def serializable_root_domain(+schema: T.Schema, +value: T.Value) -> Bool:
  Bool.and(serializable(schema, value), mixing_lengths(value, schema))
