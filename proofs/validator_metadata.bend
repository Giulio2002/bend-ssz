import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as C
import ../spec/type_legality.bend as S
import ./packing.bend as Pack
import ./nat_order.bend as Order

# These laws compare independent metadata definitions; no compatibility or
# validator conclusion is assumed. Slot bounds hold even for malformed inputs.

law names_equal:
  for +a: +List<String>
  for +b: +List<String>
  {I.names_equal(a, b) == C.names_equal(a, b) : Bool}
def names_equal(a, b):
  match a b:
    case Nil{} Nil{}: {==}
    case Nil{} Con{y, ys}: {==}
    case Con{x, xs} Nil{}: {==}
    case Con{x, xs} Con{y, ys}:
      %names_equal(xs, ys) : {I.names_equal(x <> xs, y <> ys) == Bool.and(String.eq(x, y), _) : Bool}
      {==}

law bits_equal:
  for +a: +List<Bool>
  for +b: +List<Bool>
  {I.bools_equal(a, b) == C.bits_equal(a, b) : Bool}
def bits_equal(a, b):
  match a b:
    case Nil{} Nil{}: {==}
    case Nil{} Con{y, ys}: {==}
    case Con{x, xs} Nil{}: {==}
    case Con{x, xs} Con{y, ys}:
      %bits_equal(xs, ys) : {I.bools_equal(x <> xs, y <> ys) == Bool.and(Bool.not(Bool.xor(x, y)), _) : Bool}
      {==}

law selectors_equal:
  for +a: +List<U32>
  for +b: +List<U32>
  {I.selectors_equal(a, b) == C.selectors_equal(a, b) : Bool}
def selectors_equal(a, b):
  match a b:
    case Nil{} Nil{}: {==}
    case Nil{} Con{y, ys}: {==}
    case Con{x, xs} Nil{}: {==}
    case Con{x, xs} Con{y, ys}:
      %selectors_equal(xs, ys) : {I.selectors_equal(x <> xs, y <> ys) == Bool.and(U32.is_eq(x, y), _) : Bool}
      {==}

law field_count:
  for +schema: T.Schema
  {I.count(schema) == S.field_count(schema) : Nat}
def field_count(schema):
  match schema:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: {==}
    case T.ListOf{x0, x1}: {==}
    case T.Container{x0, x1}: {==}
    case T.Union{x0}: {==}
    case T.Null{}: {==}
    case T.Chain{x0, x1}: Equal.cong(Nat, Nat, k => 1n+k, I.count(x1), S.field_count(x1), field_count(x1))
    case T.End{}: {==}
    case T.Repeat{x0}: {==}
    case T.Named{x0, x1}: {==}
    case T.ProgressiveList{x0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: {==}
    case T.CompatibleUnion{x0, x1}: {==}

law contains_name:
  for +name: String
  for +names: +List<String>
  {I.contains_name(name, names) == S.contains_name(name, names) : Bool}
def contains_name(name, names):
  match names:
    case Nil{}: {==}
    case Con{h, t}:
      %contains_name(name, t) : {I.contains_name(name, h <> t) == Bool.or(String.eq(name, h), _) : Bool}
      {==}

law contains_selector:
  for +name: U32
  for +names: +List<U32>
  {I.has_selector(name, names) == S.contains_selector(name, names) : Bool}
def contains_selector(name, names):
  match names:
    case Nil{}: {==}
    case Con{h, t}:
      %contains_selector(name, t) : {I.has_selector(name, h <> t) == Bool.or(U32.is_eq(name, h), _) : Bool}
      {==}

law unique_names:
  for +names: +List<String>
  {I.unique_names(names) == S.distinct_names(names) : Bool}
def unique_names(names):
  match names:
    case Nil{}: {==}
    case Con{h, t}:
      %contains_name(h, t) : {I.unique_names(h <> t) == Bool.and(Bool.not(_), S.distinct_names(t)) : Bool}
      %unique_names(t) : {I.unique_names(h <> t) == Bool.and(Bool.not(I.contains_name(h, t)), _) : Bool}
      {==}

law active_count_acc:
  for +active: +List<Bool>
  for +acc: Nat
  {I.active_count(active, acc) == Nat.add(S.active_count(active), acc) : Nat}
def active_count_acc(active, acc):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}: active_count_acc(tail, acc)
    case Con{True{}, tail}:
      %Pack.add_succ(S.active_count(tail), acc) : {I.active_count(tail, 1n+acc) == _ : Nat}
      active_count_acc(tail, 1n+acc)

law active_count:
  for +active: +List<Bool>
  {I.active_count(active, 0n) == S.active_count(active) : Nat}
def active_count(active):
  Equal.trans(Nat, I.active_count(active, 0n), Nat.add(S.active_count(active), 0n), S.active_count(active), active_count_acc(active, 0n), Pack.add_zero(S.active_count(active)))

law active_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {I.active_fields(active, names, fields) == C.slots(active, names, fields) : T.Schema}
def active_slots(active, names, fields):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}:
      Equal.cong(T.Schema, T.Schema, rest => T.Chain{T.Null{}, rest}, I.active_fields(tail, names, fields), C.slots(tail, names, fields), active_slots(tail, names, fields))
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
        case Con{name, ns} T.Chain{field, fs}:
          Equal.cong(T.Schema, T.Schema, rest => T.Chain{T.Named{name, field}, rest}, I.active_fields(tail, ns, fs), C.slots(tail, ns, fs), active_slots(tail, ns, fs))
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

law slot_count_bound:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {Nat.is_le(I.count(I.active_fields(active, names, fields)), List.length(&2, Bool, active)) == True{} : Bool}
def slot_count_bound(active, names, fields):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}: slot_count_bound(tail, names, fields)
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
        case Con{name, ns} T.Chain{field, fs}: slot_count_bound(tail, ns, fs)
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
