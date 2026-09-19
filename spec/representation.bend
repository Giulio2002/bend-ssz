import Base
import ../types/schema.bend as T
import ./schema.bend as Schema

# Neutral value representation shape, deliberately weaker than SSZ validity:
# numeric ranges, lengths, bounds and offsets remain codec/domain obligations.
def selected(option: Maybe<&2, T.Schema>, next: T.Schema -> Bool) -> Bool:
  match option:
    case None{}: False{}
    case Some{s}: next(s)

def shape(value: T.Value, schema: T.Schema) -> Bool:
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: True{}
        case _: False{}
    case T.UnsignedValue{v}:
      match schema:
        case T.Unsigned{w}: True{}
        case _: False{}
    case T.BytesValue{v}:
      match schema:
        case T.ByteVector{n}: True{}
        case T.ByteList{n}: True{}
        case _: False{}
    case T.BitsValue{v}:
      match schema:
        case T.BitVector{n}: True{}
        case T.BitList{n}: True{}
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
        case T.Chain{s, rest}: Bool.and(shape(h, s), shape(t, rest))
        case T.Repeat{+s}: Bool.and(shape(h, s), shape(t, T.Repeat{s}))
        case _: False{}
    case T.Sequence{items}:
      match schema:
        case T.Vector{e, n}: shape(items, T.Repeat{e})
        case T.ListOf{e, n}: shape(items, T.Repeat{e})
        case T.ProgressiveList{e}: shape(items, T.Repeat{e})
        case T.Container{names, fields}: shape(items, fields)
        case T.ProgressiveContainer{names, fields, active}: shape(items, fields)
        case _: False{}
    case T.Selected{selector, v}:
      match schema:
        case T.Union{options}: selected(Schema.option(options, U32.to_nat(selector)), s => shape(v, s))
        case T.CompatibleUnion{selectors, options}: selected(Schema.compatible_option(selectors, options, selector), s => shape(v, s))
        case _: False{}

# Structural erasure for adapter proofs only. It removes metadata which cannot
# affect the neutral value tag/field shape. These are NOT legal SSZ schemas and
# must never be passed as replacement protocol schemas to codecs or roots.
def erase(schema: T.Schema) -> T.Schema:
  match schema:
    case T.Boolean{}: T.Boolean{}
    case T.Unsigned{w}: T.Unsigned{w}
    case T.ByteVector{n}: T.ByteVector{0n}
    case T.ByteList{n}: T.ByteVector{0n}
    case T.BitVector{n}: T.BitVector{0n}
    case T.BitList{n}: T.BitVector{0n}
    case T.ProgressiveBits{}: T.BitVector{0n}
    case T.Vector{e, n}: T.Vector{erase(e), 0n}
    case T.ListOf{e, n}: T.Vector{erase(e), 0n}
    case T.ProgressiveList{e}: T.Vector{erase(e), 0n}
    case T.Container{names, fields}: T.Container{[], erase(fields)}
    case T.ProgressiveContainer{names, fields, active}: T.Container{[], erase(fields)}
    case T.Chain{h, t}: T.Chain{erase(h), erase(t)}
    case T.Repeat{e}: T.Repeat{erase(e)}
    case T.Union{options}: T.Union{erase(options)}
    case T.CompatibleUnion{selectors, options}: T.CompatibleUnion{selectors, erase(options)}
    case T.Null{}: T.Null{}
    case T.End{}: T.End{}
    case T.Named{name, e}: T.Named{name, erase(e)}
