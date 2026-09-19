import Base
import ../src/schema.bend as I
import ../spec/type_legality.bend as S
import ./validator_metadata.bend as M
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./decode_canonical.bend as Eq

law conflict:
  for +b: Bool
  for absent: {b == False{} : Bool}
  for present: {b == True{} : Bool}
  Empty
def conflict(b, absent, present):
  W.false_true(Equal.trans(Bool, False{}, b, True{}, Equal.sym(Bool, b, False{}, absent), present))

law refute:
  for +b: Bool
  for contradiction: {b == True{} : Bool} -> Empty
  {b == False{} : Bool}
def refute(b, contradiction):
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, contradiction({==}))

law not_true:
  for +b: Bool
  for yes: {Bool.not(b) == True{} : Bool}
  {b == False{} : Bool}
def not_true(b, yes):
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, W.false_true(yes))

law or_right:
  for +a: Bool
  for +b: Bool
  for yes: {b == True{} : Bool}
  {Bool.or(a, b) == True{} : Bool}
def or_right(a, b, yes):
  match a:
    case False{}: yes
    case True{}: {==}

law or_left:
  for +a: Bool
  for +b: Bool
  for yes: {a == True{} : Bool}
  {Bool.or(a, b) == True{} : Bool}
def or_left(a, b, yes):
  match a:
    case False{}: Empty.absurd({b == True{} : Bool}, W.false_true(yes))
    case True{}: {==}

law or_false:
  for +a: Bool
  for +b: Bool
  for absent_a: {a == False{} : Bool}
  for absent_b: {b == False{} : Bool}
  {Bool.or(a, b) == False{} : Bool}
def or_false(a, b, absent_a, absent_b):
  %Equal.sym(Bool, a, False{}, absent_a) : {Bool.or(_, b) == False{} : Bool}
  absent_b

law unequal:
  for +key: U32
  for +head: U32
  for +seen: +List<U32>
  for present: {I.has_selector(key, seen) == True{} : Bool}
  for absent: {I.has_selector(head, seen) == False{} : Bool}
  {U32.is_eq(key, head) == False{} : Bool}
def unequal(key, head, seen, present, absent):
  refute(U32.is_eq(key, head), equal => conflict(I.has_selector(head, seen), absent,
    %W.u32_equal_sound(key, head, equal) : {I.has_selector(_, seen) == True{} : Bool}
    present))

law head_range:
  for +head: U32
  for +tail: +List<U32>
  for +seen: +List<U32>
  for accepted: {I.selectors_valid(head <> tail, seen) == True{} : Bool}
  {Bool.and(U32.is_lt(0, head), U32.is_lt(head, 128)) == True{} : Bool}
def head_range(head, tail, seen, accepted):
  V.and_left(Bool.and(U32.is_lt(0, head), U32.is_lt(head, 128)), Bool.and(Bool.not(I.has_selector(head, seen)), I.selectors_valid(tail, head <> seen)), accepted)

law head_absent:
  for +head: U32
  for +tail: +List<U32>
  for +seen: +List<U32>
  for accepted: {I.selectors_valid(head <> tail, seen) == True{} : Bool}
  {I.has_selector(head, seen) == False{} : Bool}
def head_absent(head, tail, seen, accepted):
  not_true(I.has_selector(head, seen), V.and_left(Bool.not(I.has_selector(head, seen)), I.selectors_valid(tail, head <> seen), V.and_right(Bool.and(U32.is_lt(0, head), U32.is_lt(head, 128)), Bool.and(Bool.not(I.has_selector(head, seen)), I.selectors_valid(tail, head <> seen)), accepted)))

law tail_accepted:
  for +head: U32
  for +tail: +List<U32>
  for +seen: +List<U32>
  for accepted: {I.selectors_valid(head <> tail, seen) == True{} : Bool}
  {I.selectors_valid(tail, head <> seen) == True{} : Bool}
def tail_accepted(head, tail, seen, accepted):
  V.and_right(Bool.not(I.has_selector(head, seen)), I.selectors_valid(tail, head <> seen), V.and_right(Bool.and(U32.is_lt(0, head), U32.is_lt(head, 128)), Bool.and(Bool.not(I.has_selector(head, seen)), I.selectors_valid(tail, head <> seen)), accepted))

law exclusion:
  for +xs: +List<U32>
  for +seen: +List<U32>
  for +key: U32
  for +accepted: {I.selectors_valid(xs, seen) == True{} : Bool}
  for +present: {I.has_selector(key, seen) == True{} : Bool}
  {I.has_selector(key, xs) == False{} : Bool}
def exclusion(xs, seen, key, accepted, present):
  match xs:
    case Nil{}: {==}
    case Con{head, tail}:
      or_false(U32.is_eq(key, head), I.has_selector(key, tail), unequal(key, head, seen, present, head_absent(head, tail, seen, accepted)), exclusion(tail, head <> seen, key, tail_accepted(head, tail, seen, accepted), or_right(U32.is_eq(key, head), I.has_selector(key, seen), present)))

law sound:
  for +xs: +List<U32>
  for +seen: +List<U32>
  for +accepted: {I.selectors_valid(xs, seen) == True{} : Bool}
  S.selectors(xs)
def sound(xs, seen, accepted):
  match xs:
    case Nil{}: Unit{}
    case Con{head, tail}:
      (V.and_left(U32.is_lt(0, head), U32.is_lt(head, 128), head_range(head, tail, seen, accepted)),
       V.and_right(U32.is_lt(0, head), U32.is_lt(head, 128), head_range(head, tail, seen, accepted)),
       %M.contains_selector(head, tail) : {_ == False{} : Bool}
       exclusion(tail, head <> seen, head, tail_accepted(head, tail, seen, accepted), or_left(U32.is_eq(head, head), I.has_selector(head, seen), Eq.word_equal_reflexive(head))),
       sound(tail, head <> seen, tail_accepted(head, tail, seen, accepted)))

# Disjointness is the accumulator invariant, not an assumed validator result.
def apart(xs: +List<U32>, +seen: +List<U32>) -> Type:
  match xs:
    case Nil{}: Unit
    case Con{head, tail}: {I.has_selector(head, seen) == False{} : Bool} & apart(tail, seen)

law or_no_left:
  for +a: Bool
  for +b: Bool
  for no: {Bool.or(a, b) == False{} : Bool}
  {a == False{} : Bool}
def or_no_left(a, b, no):
  match a:
    case False{}: {==}
    case True{}: no

law or_no_right:
  for +a: Bool
  for +b: Bool
  for no: {Bool.or(a, b) == False{} : Bool}
  {b == False{} : Bool}
def or_no_right(a, b, no):
  match a:
    case False{}: no
    case True{}: Empty.absurd({b == False{} : Bool}, conflict(True{}, no, {==}))

law unequal_symmetric:
  for +a: U32
  for +b: U32
  for no: {U32.is_eq(a, b) == False{} : Bool}
  {U32.is_eq(b, a) == False{} : Bool}
def unequal_symmetric(a, b, no):
  refute(U32.is_eq(b, a), equal => conflict(U32.is_eq(a, b), no,
    %Equal.sym(U32, b, a, W.u32_equal_sound(b, a, equal)) : {U32.is_eq(a, _) == True{} : Bool}
    Eq.word_equal_reflexive(a)))

law apart_empty:
  for +xs: +List<U32>
  apart(xs, [])
def apart_empty(xs):
  match xs:
    case Nil{}: Unit{}
    case Con{head, tail}: ({==}, apart_empty(tail))

law apart_extend:
  for +xs: +List<U32>
  for +seen: +List<U32>
  for +key: U32
  for +absent: {I.has_selector(key, xs) == False{} : Bool}
  for separated: apart(xs, seen)
  apart(xs, key <> seen)
def apart_extend(xs, seen, key, absent, separated):
  match xs:
    case Nil{}: Unit{}
    case Con{head, tail}:
      (fresh, rest) = separated
      (or_false(U32.is_eq(head, key), I.has_selector(head, seen), unequal_symmetric(key, head, or_no_left(U32.is_eq(key, head), I.has_selector(key, tail), absent)), fresh),
       apart_extend(tail, seen, key, or_no_right(U32.is_eq(key, head), I.has_selector(key, tail), absent), rest))

law not_false:
  for +b: Bool
  for no: {b == False{} : Bool}
  {Bool.not(b) == True{} : Bool}
def not_false(b, no):
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({False{} == True{} : Bool}, conflict(True{}, no, {==}))

law complete_acc:
  for +xs: +List<U32>
  for +seen: +List<U32>
  for legal: S.selectors(xs)
  for separated: apart(xs, seen)
  {I.selectors_valid(xs, seen) == True{} : Bool}
def complete_acc(xs, seen, legal, separated):
  match xs:
    case Nil{}: {==}
    case Con{head, tail}:
      (lower, upper, unique, rest) = legal
      (fresh, apart_tail) = separated
      V.and_true(Bool.and(U32.is_lt(0, head), U32.is_lt(head, 128)), Bool.and(Bool.not(I.has_selector(head, seen)), I.selectors_valid(tail, head <> seen)),
        V.and_true(U32.is_lt(0, head), U32.is_lt(head, 128), lower, upper),
        V.and_true(Bool.not(I.has_selector(head, seen)), I.selectors_valid(tail, head <> seen), not_false(I.has_selector(head, seen), fresh),
          complete_acc(tail, head <> seen, rest, apart_extend(tail, seen, head,
            %Equal.sym(Bool, I.has_selector(head, tail), S.contains_selector(head, tail), M.contains_selector(head, tail)) : {_ == False{} : Bool}
            unique,
            apart_tail))))

law complete:
  for +xs: +List<U32>
  for legal: S.selectors(xs)
  {I.selectors_valid(xs, []) == True{} : Bool}
def complete(xs, legal): complete_acc(xs, [], legal, apart_empty(xs))
