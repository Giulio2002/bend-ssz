import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/lists.bend as Lists
import ../spec/type_legality.bend as S
import ./validator_metadata.bend as M
import ./lists.bend as L
import ./primitive_invariants.bend as V
import ./bit_vector_inverse.bend as Eq
import ./bit_vector_canonical.bend as Refl

law last_nonempty:
  for +tail: +List<Bool>
  for +head: Bool
  for +previous: Bool
  {I.ends_active(head <> tail, previous) == S.last_active(head <> tail) : Bool}
def last_nonempty(tail, head, previous):
  match tail:
    case Nil{}: {==}
    case Con{next, rest}: last_nonempty(rest, next, head)

law last_active:
  for +active: +List<Bool>
  {I.ends_active(active, False{}) == S.last_active(active) : Bool}
def last_active(active):
  match active:
    case Nil{}: {==}
    case Con{head, tail}: last_nonempty(tail, head, False{})

law named_metadata:
  for +names: +List<String>
  for +fields: T.Schema
  {I.named_fields_valid(names, fields) == Bool.and(Nat.is_lt(0n, S.field_count(fields)), Bool.and(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names))) : Bool}
def named_metadata(names, fields):
  %M.field_count(fields) : {I.named_fields_valid(names, fields) == Bool.and(Nat.is_lt(0n, _), Bool.and(Nat.is_eq(List.length(&2, String, names), _), S.distinct_names(names))) : Bool}
  %L.length_correct(String, names) : {I.named_fields_valid(names, fields) == Bool.and(Nat.is_lt(0n, I.count(fields)), Bool.and(Nat.is_eq(_, I.count(fields)), S.distinct_names(names))) : Bool}
  %M.unique_names(names) : {I.named_fields_valid(names, fields) == Bool.and(Nat.is_lt(0n, I.count(fields)), Bool.and(Nat.is_eq(Lists.length(String, names), I.count(fields)), _)) : Bool}
  {==}

law named_sound_body:
  for +names: +List<String>
  for +fields: T.Schema
  for +accepted: {Bool.and(Nat.is_lt(0n, S.field_count(fields)), Bool.and(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names))) == True{} : Bool}
  S.named_fields(names, fields)
def named_sound_body(names, fields, accepted):
  (V.and_left(Nat.is_lt(0n, S.field_count(fields)), Bool.and(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names)), accepted),
   Eq.nat_equal_sound(List.length(&2, String, names), S.field_count(fields), V.and_left(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names), V.and_right(Nat.is_lt(0n, S.field_count(fields)), Bool.and(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names)), accepted))),
   V.and_right(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names), V.and_right(Nat.is_lt(0n, S.field_count(fields)), Bool.and(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names)), accepted)))

law named_sound:
  for +names: +List<String>
  for +fields: T.Schema
  for accepted: {I.named_fields_valid(names, fields) == True{} : Bool}
  S.named_fields(names, fields)
def named_sound(names, fields, accepted):
  named_sound_body(names, fields,
    %named_metadata(names, fields) : {_ == True{} : Bool}
    accepted)

law equality_complete:
  for +a: Nat
  for +b: Nat
  for equal: {a == b : Nat}
  {Nat.is_eq(a, b) == True{} : Bool}
def equality_complete(a, b, equal):
  %equal : {Nat.is_eq(a, _) == True{} : Bool}
  Refl.nat_equal_refl(a)

law named_complete_body:
  for +names: +List<String>
  for +fields: T.Schema
  for legal: S.named_fields(names, fields)
  {Bool.and(Nat.is_lt(0n, S.field_count(fields)), Bool.and(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names))) == True{} : Bool}
def named_complete_body(names, fields, legal):
  (nonempty, count, distinct) = legal
  V.and_true(Nat.is_lt(0n, S.field_count(fields)), Bool.and(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names)), nonempty,
    V.and_true(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names), equality_complete(List.length(&2, String, names), S.field_count(fields), count), distinct))

law named_complete:
  for +names: +List<String>
  for +fields: T.Schema
  for legal: S.named_fields(names, fields)
  {I.named_fields_valid(names, fields) == True{} : Bool}
def named_complete(names, fields, legal):
  %Equal.sym(Bool, I.named_fields_valid(names, fields), Bool.and(Nat.is_lt(0n, S.field_count(fields)), Bool.and(Nat.is_eq(List.length(&2, String, names), S.field_count(fields)), S.distinct_names(names))), named_metadata(names, fields)) : {_ == True{} : Bool}
  named_complete_body(names, fields, legal)
