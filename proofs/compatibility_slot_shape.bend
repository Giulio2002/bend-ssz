import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./validator_metadata.bend as M

# Invariant required when relating mode 3 to the independent Slots judgement.
# Arbitrary raw Chain forests need not satisfy it, even if mode 3 accepts them.
def slot_forest(schema: T.Schema) -> Bool:
  match schema:
    case T.End{}: True{}
    case T.Chain{T.Null{}, tail}: slot_forest(tail)
    case T.Chain{T.Named{name, field}, tail}: slot_forest(tail)
    case _: False{}

law active_fields_establish_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {slot_forest(I.active_fields(active, names, fields)) == True{} : Bool}
def active_fields_establish_slots(active, names, fields):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}: active_fields_establish_slots(tail, names, fields)
    case Con{True{}, tail}:
      match names fields:
        case Nil{} T.Boolean{}: {==}
        case Con{name, ns} T.Boolean{}: {==}
        case Nil{} T.Unsigned{x0}: {==}
        case Con{name, ns} T.Unsigned{x0}: {==}
        case Nil{} T.ByteVector{x0}: {==}
        case Con{name, ns} T.ByteVector{x0}: {==}
        case Nil{} T.ByteList{x0}: {==}
        case Con{name, ns} T.ByteList{x0}: {==}
        case Nil{} T.BitVector{x0}: {==}
        case Con{name, ns} T.BitVector{x0}: {==}
        case Nil{} T.BitList{x0}: {==}
        case Con{name, ns} T.BitList{x0}: {==}
        case Nil{} T.Vector{x0, x1}: {==}
        case Con{name, ns} T.Vector{x0, x1}: {==}
        case Nil{} T.ListOf{x0, x1}: {==}
        case Con{name, ns} T.ListOf{x0, x1}: {==}
        case Nil{} T.Container{x0, x1}: {==}
        case Con{name, ns} T.Container{x0, x1}: {==}
        case Nil{} T.Union{x0}: {==}
        case Con{name, ns} T.Union{x0}: {==}
        case Nil{} T.Null{}: {==}
        case Con{name, ns} T.Null{}: {==}
        case Nil{} T.Chain{x0, x1}: {==}
        case Con{name, ns} T.Chain{field, fs}: active_fields_establish_slots(tail, ns, fs)
        case Nil{} T.End{}: {==}
        case Con{name, ns} T.End{}: {==}
        case Nil{} T.Repeat{x0}: {==}
        case Con{name, ns} T.Repeat{x0}: {==}
        case Nil{} T.Named{x0, x1}: {==}
        case Con{name, ns} T.Named{x0, x1}: {==}
        case Nil{} T.ProgressiveList{x0}: {==}
        case Con{name, ns} T.ProgressiveList{x0}: {==}
        case Nil{} T.ProgressiveBits{}: {==}
        case Con{name, ns} T.ProgressiveBits{}: {==}
        case Nil{} T.ProgressiveContainer{x0, x1, x2}: {==}
        case Con{name, ns} T.ProgressiveContainer{x0, x1, x2}: {==}
        case Nil{} T.CompatibleUnion{x0, x1}: {==}
        case Con{name, ns} T.CompatibleUnion{x0, x1}: {==}

law normative_slots_establish_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {slot_forest(S.slots(active, names, fields)) == True{} : Bool}
def normative_slots_establish_slots(active, names, fields):
  %M.active_slots(active, names, fields) : {slot_forest(_) == True{} : Bool}
  active_fields_establish_slots(active, names, fields)
