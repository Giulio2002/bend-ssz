import Base
import ../types/schema.bend as T
import ./codec.bend as Codec
import ./schema.bend as Schema
import ./nat_bytes.bend as Length

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

def root_domain(+schema: T.Schema, +value: T.Value) -> Bool:
  Bool.and(serializable(schema, value), mixing_lengths(value, schema))
