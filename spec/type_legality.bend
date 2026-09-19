import Base
import ../types/schema.bend as T
import ./compatibility.bend as Compatibility

# Normative legal-type judgement, transcribed from simple-serialize.md:
# Type system / Illegal types / Union / Compatible Merkleization.
# It is independent of the runtime validator and has no traversal budget.
# Chain/End are field/option forests only; Repeat/Named are internal helpers.
def field_count(fields: T.Schema) -> Nat:
  match fields:
    case T.Chain{head, tail}: 1n+field_count(tail)
    case _: 0n

def contains_name(+name: String, names: +List<String>) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, tail}: Bool.or(String.eq(name, head), contains_name(name, tail))

def distinct_names(names: +List<String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{head, +tail}: Bool.and(Bool.not(contains_name(head, tail)), distinct_names(tail))

def named_fields(+names: +List<String>, +fields: T.Schema) -> Type:
  {Nat.is_lt(0n, field_count(fields)) == True{} : Bool} & {List.length(&2, String, names) == field_count(fields) : Nat} & {distinct_names(names) == True{} : Bool}

def active_count(active: +List<Bool>) -> Nat:
  match active:
    case Nil{}: 0n
    case Con{False{}, tail}: active_count(tail)
    case Con{True{}, tail}: 1n+active_count(tail)

def last_active(active: +List<Bool>) -> Bool:
  match active:
    case Nil{}: False{}
    case Con{bit, Nil{}}: bit
    case Con{bit, Con{next, tail}}: last_active(next <> tail)

def contains_selector(+selector: U32, selectors: +List<U32>) -> Bool:
  match selectors:
    case Nil{}: False{}
    case Con{head, tail}: Bool.or(U32.is_eq(selector, head), contains_selector(selector, tail))

def selectors(ids: +List<U32>) -> Type:
  match ids:
    case Nil{}: Unit
    case Con{+head, +tail}: {U32.is_lt(0, head) == True{} : Bool} & {U32.is_lt(head, 128) == True{} : Bool} & {contains_selector(head, tail) == False{} : Bool} & selectors(tail)

def legal(schema: T.Schema, +forest: Bool) -> Type:
  match schema:
    case T.Boolean{}: {forest == False{} : Bool}
    case T.Unsigned{width}: {forest == False{} : Bool}
    case T.ByteVector{n}: {forest == False{} : Bool} & {Nat.is_lt(0n, n) == True{} : Bool}
    case T.ByteList{n}: {forest == False{} : Bool}
    case T.BitVector{n}: {forest == False{} : Bool} & {Nat.is_lt(0n, n) == True{} : Bool}
    case T.BitList{n}: {forest == False{} : Bool}
    case T.Vector{element, n}: {forest == False{} : Bool} & {Nat.is_lt(0n, n) == True{} : Bool} & legal(element, False{})
    case T.ListOf{element, n}: {forest == False{} : Bool} & legal(element, False{})
    case T.ProgressiveList{element}: {forest == False{} : Bool} & legal(element, False{})
    case T.ProgressiveBits{}: {forest == False{} : Bool}
    case T.Container{names, +fields}: {forest == False{} : Bool} & named_fields(names, fields) & legal(fields, True{})
    case T.ProgressiveContainer{names, +fields, +active}: {forest == False{} : Bool} & named_fields(names, fields) & legal(fields, True{}) & {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool} & {last_active(active) == True{} : Bool} & {active_count(active) == field_count(fields) : Nat}
    case T.Union{T.Chain{T.Null{}, +rest}}: {forest == False{} : Bool} & {Nat.is_lt(0n, field_count(rest)) == True{} : Bool} & {Nat.is_le(field_count(rest), 127n) == True{} : Bool} & legal(rest, True{})
    case T.Union{T.Chain{head, +rest}}: {forest == False{} : Bool} & {Nat.is_le(field_count(rest), 127n) == True{} : Bool} & legal(head, False{}) & legal(rest, True{})
    case T.Union{other}: Empty
    case T.CompatibleUnion{+ids, +options}: {forest == False{} : Bool} & {Nat.is_lt(0n, field_count(options)) == True{} : Bool} & {List.length(&2, U32, ids) == field_count(options) : Nat} & selectors(ids) & legal(options, True{}) & Compatibility.mutually_compatible(options)
    case T.Chain{head, tail}: {forest == True{} : Bool} & legal(head, False{}) & legal(tail, True{})
    case T.End{}: {forest == True{} : Bool}
    case T.Null{}: Empty
    case T.Repeat{element}: Empty
    case T.Named{name, element}: Empty

def type_legal(schema: T.Schema) -> Type: legal(schema, False{})
