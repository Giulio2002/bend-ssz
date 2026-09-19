import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./nat_order.bend as Order
import ./validator_metadata.bend as Metadata

# Count field subtrees once while ignoring inserted inactive slots and names.
# This is a proof measure, never a protocol capacity or an execution limit.
def payload(schema: T.Schema) -> Nat:
  match schema:
    case T.Chain{T.Null{}, tail}: payload(tail)
    case T.Chain{T.Named{name, field}, tail}: 1n+Nat.add(I.weight(field), payload(tail))
    case _: 1n

law weight_positive:
  for +schema: T.Schema
  {Nat.is_le(1n, I.weight(schema)) == True{} : Bool}
def weight_positive(schema):
  match schema:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: Order.zero_le(I.weight(x0))
    case T.ListOf{x0, x1}: Order.zero_le(I.weight(x0))
    case T.Container{x0, x1}: Order.zero_le(I.weight(x1))
    case T.Union{x0}: Order.zero_le(I.weight(x0))
    case T.Null{}: {==}
    case T.Chain{x0, x1}: Order.zero_le(Nat.add(I.weight(x0), I.weight(x1)))
    case T.End{}: {==}
    case T.Repeat{x0}: Order.zero_le(I.weight(x0))
    case T.Named{x0, x1}: Order.zero_le(I.weight(x1))
    case T.ProgressiveList{x0}: Order.zero_le(I.weight(x0))
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: Order.zero_le(I.weight(x1))
    case T.CompatibleUnion{x0, x1}: Order.zero_le(I.weight(x1))

law expansion_payload_bound:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {Nat.is_le(payload(I.active_fields(active, names, fields)), I.weight(fields)) == True{} : Bool}
def expansion_payload_bound(active, names, fields):
  match active:
    case Nil{}: weight_positive(fields)
    case Con{False{}, tail}: expansion_payload_bound(tail, names, fields)
    case Con{True{}, tail}:
      match names fields:
        case Nil{} T.Boolean{}: weight_positive(T.Boolean{})
        case Con{name, ns} T.Boolean{}: weight_positive(T.Boolean{})
        case Nil{} T.Unsigned{x0}: weight_positive(T.Unsigned{x0})
        case Con{name, ns} T.Unsigned{x0}: weight_positive(T.Unsigned{x0})
        case Nil{} T.ByteVector{x0}: weight_positive(T.ByteVector{x0})
        case Con{name, ns} T.ByteVector{x0}: weight_positive(T.ByteVector{x0})
        case Nil{} T.ByteList{x0}: weight_positive(T.ByteList{x0})
        case Con{name, ns} T.ByteList{x0}: weight_positive(T.ByteList{x0})
        case Nil{} T.BitVector{x0}: weight_positive(T.BitVector{x0})
        case Con{name, ns} T.BitVector{x0}: weight_positive(T.BitVector{x0})
        case Nil{} T.BitList{x0}: weight_positive(T.BitList{x0})
        case Con{name, ns} T.BitList{x0}: weight_positive(T.BitList{x0})
        case Nil{} T.Vector{x0, x1}: weight_positive(T.Vector{x0, x1})
        case Con{name, ns} T.Vector{x0, x1}: weight_positive(T.Vector{x0, x1})
        case Nil{} T.ListOf{x0, x1}: weight_positive(T.ListOf{x0, x1})
        case Con{name, ns} T.ListOf{x0, x1}: weight_positive(T.ListOf{x0, x1})
        case Nil{} T.Container{x0, x1}: weight_positive(T.Container{x0, x1})
        case Con{name, ns} T.Container{x0, x1}: weight_positive(T.Container{x0, x1})
        case Nil{} T.Union{x0}: weight_positive(T.Union{x0})
        case Con{name, ns} T.Union{x0}: weight_positive(T.Union{x0})
        case Nil{} T.Null{}: weight_positive(T.Null{})
        case Con{name, ns} T.Null{}: weight_positive(T.Null{})
        case Nil{} T.Chain{x0, x1}: weight_positive(T.Chain{x0, x1})
        case Con{name, ns} T.Chain{field, fs}:
          Order.add_left(I.weight(field), payload(I.active_fields(tail, ns, fs)), I.weight(fs), expansion_payload_bound(tail, ns, fs))
        case Nil{} T.End{}: weight_positive(T.End{})
        case Con{name, ns} T.End{}: weight_positive(T.End{})
        case Nil{} T.Repeat{x0}: weight_positive(T.Repeat{x0})
        case Con{name, ns} T.Repeat{x0}: weight_positive(T.Repeat{x0})
        case Nil{} T.Named{x0, x1}: weight_positive(T.Named{x0, x1})
        case Con{name, ns} T.Named{x0, x1}: weight_positive(T.Named{x0, x1})
        case Nil{} T.ProgressiveList{x0}: weight_positive(T.ProgressiveList{x0})
        case Con{name, ns} T.ProgressiveList{x0}: weight_positive(T.ProgressiveList{x0})
        case Nil{} T.ProgressiveBits{}: weight_positive(T.ProgressiveBits{})
        case Con{name, ns} T.ProgressiveBits{}: weight_positive(T.ProgressiveBits{})
        case Nil{} T.ProgressiveContainer{x0, x1, x2}: weight_positive(T.ProgressiveContainer{x0, x1, x2})
        case Con{name, ns} T.ProgressiveContainer{x0, x1, x2}: weight_positive(T.ProgressiveContainer{x0, x1, x2})
        case Nil{} T.CompatibleUnion{x0, x1}: weight_positive(T.CompatibleUnion{x0, x1})
        case Con{name, ns} T.CompatibleUnion{x0, x1}: weight_positive(T.CompatibleUnion{x0, x1})

law normative_expansion_payload_bound:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {Nat.is_le(payload(S.slots(active, names, fields)), I.weight(fields)) == True{} : Bool}
def normative_expansion_payload_bound(active, names, fields):
  %Metadata.active_slots(active, names, fields) : {Nat.is_le(payload(_), I.weight(fields)) == True{} : Bool}
  expansion_payload_bound(active, names, fields)
