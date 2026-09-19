import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/lists.bend as Lists
import ../spec/type_legality.bend as S
import ./validator_metadata.bend as Metadata
import ./lists.bend as L
import ./nat_order.bend as Order
import ./primitive_invariants.bend as V

# The 256-slot bound comes from protocol type legality, not a runtime limit.
law bounded_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  for bounded: {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool}
  {Nat.is_le(I.count(I.active_fields(active, names, fields)), 256n) == True{} : Bool}
def bounded_slots(active, names, fields, bounded):
  Order.transitive(I.count(I.active_fields(active, names, fields)), List.length(&2, Bool, active), 256n, Metadata.slot_count_bound(active, names, fields), bounded)

law validator_length:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  for accepted: {I.valid(T.ProgressiveContainer{names, fields, active}) == True{} : Bool}
  {Nat.is_le(Lists.length(Bool, active), 256n) == True{} : Bool}
def validator_length(active, names, fields, accepted):
  V.and_left(Nat.is_le(Lists.length(Bool, active), 256n), Bool.and(I.ends_active(active, False{}), Nat.is_eq(I.active_count(active, 0n), I.count(fields))),
    V.and_right(I.valid_go(fields, True{}), Bool.and(Nat.is_le(Lists.length(Bool, active), 256n), Bool.and(I.ends_active(active, False{}), Nat.is_eq(I.active_count(active, 0n), I.count(fields)))),
      V.and_right(I.named_fields_valid(names, fields), Bool.and(I.valid_go(fields, True{}), Bool.and(Nat.is_le(Lists.length(Bool, active), 256n), Bool.and(I.ends_active(active, False{}), Nat.is_eq(I.active_count(active, 0n), I.count(fields))))), accepted)))

law validator_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  for accepted: {I.valid(T.ProgressiveContainer{names, fields, active}) == True{} : Bool}
  {Nat.is_le(I.count(I.active_fields(active, names, fields)), 256n) == True{} : Bool}
def validator_slots(active, names, fields, accepted):
  bounded_slots(active, names, fields,
    %L.length_correct(Bool, active) : {Nat.is_le(_, 256n) == True{} : Bool}
    validator_length(active, names, fields, accepted))

law normative_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  for legal: S.type_legal(T.ProgressiveContainer{names, fields, active})
  {Nat.is_le(I.count(I.active_fields(active, names, fields)), 256n) == True{} : Bool}
def normative_slots(active, names, fields, legal):
  (context, named, children, bounded, last, count) = legal
  bounded_slots(active, names, fields, bounded)
