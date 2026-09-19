import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./compatibility_measure.bend as Measure
import ./active_slot_bound.bend as Active
import ./nat_algebra.bend as A
import ./nat_order.bend as O
import ./packing.bend as P

# A proof rank. Public execution still uses the retained input-derived fuel.
def regular(+a: T.Schema, +b: T.Schema) -> Nat:
  1n+Nat.mul(512n, Nat.add(I.weight(a), I.weight(b)))

def slots(+a: T.Schema, +b: T.Schema) -> Nat:
  1n+Nat.add(Nat.add(I.count(a), I.count(b)), Nat.mul(512n, Nat.add(Measure.payload(a), Measure.payload(b))))

def rank(mode: S.Judgement, a: T.Schema, b: T.Schema) -> Nat:
  match mode:
    case S.Slots{}: slots(a, b)
    case _: regular(a, b)

law regular_step:
  for +a: T.Schema
  for +b: T.Schema
  for +parent_a: T.Schema
  for +parent_b: T.Schema
  for decreases: {Nat.is_le(1n+Nat.add(I.weight(a), I.weight(b)), Nat.add(I.weight(parent_a), I.weight(parent_b))) == True{} : Bool}
  {Nat.is_le(1n+regular(a, b), regular(parent_a, parent_b)) == True{} : Bool}
def regular_step(a, b, parent_a, parent_b, decreases):
  A.mul_strict(512n, Nat.add(I.weight(a), I.weight(b)), Nat.add(I.weight(parent_a), I.weight(parent_b)), {==}, decreases)

law left_step:
  for +a: T.Schema
  for +b: T.Schema
  for +parent_a: T.Schema
  for +parent_b: T.Schema
  for left: {Nat.is_le(1n+I.weight(a), I.weight(parent_a)) == True{} : Bool}
  for right: {Nat.is_le(I.weight(b), I.weight(parent_b)) == True{} : Bool}
  {Nat.is_le(1n+regular(a, b), regular(parent_a, parent_b)) == True{} : Bool}
def left_step(a, b, parent_a, parent_b, left, right):
  regular_step(a, b, parent_a, parent_b, A.add_monotone(1n+I.weight(a), I.weight(b), I.weight(parent_a), I.weight(parent_b), left, right))

law right_step:
  for +a: T.Schema
  for +b: T.Schema
  for +parent_a: T.Schema
  for +parent_b: T.Schema
  for left: {Nat.is_le(I.weight(a), I.weight(parent_a)) == True{} : Bool}
  for right: {Nat.is_le(1n+I.weight(b), I.weight(parent_b)) == True{} : Bool}
  {Nat.is_le(1n+regular(a, b), regular(parent_a, parent_b)) == True{} : Bool}
def right_step(a, b, parent_a, parent_b, left, right):
  regular_step(a, b, parent_a, parent_b,
    %P.add_succ(I.weight(a), I.weight(b)) : {Nat.is_le(_, Nat.add(I.weight(parent_a), I.weight(parent_b))) == True{} : Bool}
    A.add_monotone(I.weight(a), 1n+I.weight(b), I.weight(parent_a), I.weight(parent_b), left, right))

law chain_head:
  for +head: T.Schema
  for +tail: T.Schema
  {Nat.is_le(1n+I.weight(head), I.weight(T.Chain{head, tail})) == True{} : Bool}
def chain_head(head, tail): O.below_sum(I.weight(head), I.weight(tail))

law chain_tail:
  for +head: T.Schema
  for +tail: T.Schema
  {Nat.is_le(1n+I.weight(tail), I.weight(T.Chain{head, tail})) == True{} : Bool}
def chain_tail(head, tail): O.left_below_sum(I.weight(head), I.weight(tail))

law public_pair_budget:
  for +a: T.Schema
  for +b: T.Schema
  {Nat.is_le(regular(a, b), Nat.mul(1024n, 1n+Nat.add(I.weight(a), I.weight(b)))) == True{} : Bool}
def public_pair_budget(a, b):
  O.transitive(regular(a, b), Nat.mul(512n, 1n+Nat.add(I.weight(a), I.weight(b))), Nat.mul(1024n, 1n+Nat.add(I.weight(a), I.weight(b))),
    A.mul_strict(512n, Nat.add(I.weight(a), I.weight(b)), 1n+Nat.add(I.weight(a), I.weight(b)), {==}, O.reflexive(1n+Nat.add(I.weight(a), I.weight(b)))),
    A.mul_coefficient(512n, 1024n, 1n+Nat.add(I.weight(a), I.weight(b)), {==}))

law doubled_scale:
  for +n: Nat
  {Nat.mul(512n, Nat.add(n, n)) == Nat.mul(1024n, n) : Nat}
def doubled_scale(n):
  Equal.trans(Nat, Nat.mul(512n, Nat.add(n, n)), Nat.add(Nat.mul(512n, n), Nat.mul(512n, n)), Nat.mul(1024n, n), A.mul_distribute(512n, n, n), Equal.sym(Nat, Nat.mul(1024n, n), Nat.add(Nat.mul(512n, n), Nat.mul(512n, n)), A.mul_add_left(512n, 512n, n)))

law public_options_budget:
  for +options: T.Schema
  {Nat.is_le(regular(options, options), Nat.mul(1024n, 1n+I.weight(options))) == True{} : Bool}
def public_options_budget(options):
  %Equal.sym(Nat, Nat.mul(512n, Nat.add(I.weight(options), I.weight(options))), Nat.mul(1024n, I.weight(options)), doubled_scale(I.weight(options))) : {Nat.is_le(1n+_, Nat.mul(1024n, 1n+I.weight(options))) == True{} : Bool}
  A.mul_strict(1024n, I.weight(options), 1n+I.weight(options), {==}, O.reflexive(1n+I.weight(options)))

law scale_two:
  for +n: Nat
  {Nat.mul(512n, 2n+n) == Nat.add(1024n, Nat.mul(512n, n)) : Nat}
def scale_two(n):
  Equal.trans(Nat, Nat.mul(512n, 2n+n), Nat.add(512n, Nat.mul(512n, 1n+n)), Nat.add(1024n, Nat.mul(512n, n)), A.mul_succ_right(512n, 1n+n),
    Equal.cong(Nat, Nat, r => Nat.add(512n, r), Nat.mul(512n, 1n+n), Nat.add(512n, Nat.mul(512n, n)), A.mul_succ_right(512n, n)))

law expansion_headroom:
  for +count_a: Nat
  for +count_b: Nat
  for +payload_a: Nat
  for +payload_b: Nat
  for +fields_a: Nat
  for +fields_b: Nat
  for count_left: {Nat.is_le(count_a, 256n) == True{} : Bool}
  for count_right: {Nat.is_le(count_b, 256n) == True{} : Bool}
  for payload_left: {Nat.is_le(payload_a, fields_a) == True{} : Bool}
  for payload_right: {Nat.is_le(payload_b, fields_b) == True{} : Bool}
  {Nat.is_le(1n+Nat.add(Nat.add(count_a, count_b), Nat.mul(512n, Nat.add(payload_a, payload_b))), Nat.mul(512n, 2n+Nat.add(fields_a, fields_b))) == True{} : Bool}
def expansion_headroom(count_a, count_b, payload_a, payload_b, fields_a, fields_b, count_left, count_right, payload_left, payload_right):
  %Equal.sym(Nat, Nat.mul(512n, 2n+Nat.add(fields_a, fields_b)), Nat.add(1024n, Nat.mul(512n, Nat.add(fields_a, fields_b))), scale_two(Nat.add(fields_a, fields_b))) : {Nat.is_le(1n+Nat.add(Nat.add(count_a, count_b), Nat.mul(512n, Nat.add(payload_a, payload_b))), _) == True{} : Bool}
  A.add_monotone(1n+Nat.add(count_a, count_b), Nat.mul(512n, Nat.add(payload_a, payload_b)), 1024n, Nat.mul(512n, Nat.add(fields_a, fields_b)),
    O.transitive(1n+Nat.add(count_a, count_b), 513n, 1024n, A.add_monotone(count_a, count_b, 256n, 256n, count_left, count_right), {==}),
    A.mul_monotone(512n, Nat.add(payload_a, payload_b), Nat.add(fields_a, fields_b), A.add_monotone(payload_a, payload_b, fields_a, fields_b, payload_left, payload_right)))

law progressive_step:
  for +na: +List<String>
  for +fa: T.Schema
  for +aa: +List<Bool>
  for +nb: +List<String>
  for +fb: T.Schema
  for +ab: +List<Bool>
  for left_bound: {Nat.is_le(List.length(&2, Bool, aa), 256n) == True{} : Bool}
  for right_bound: {Nat.is_le(List.length(&2, Bool, ab), 256n) == True{} : Bool}
  {Nat.is_le(1n+slots(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb)), regular(T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab})) == True{} : Bool}
def progressive_step(na, fa, aa, nb, fb, ab, left_bound, right_bound):
  %Equal.sym(Nat, Nat.add(I.weight(fa), 1n+I.weight(fb)), 1n+Nat.add(I.weight(fa), I.weight(fb)), P.add_succ(I.weight(fa), I.weight(fb))) : {Nat.is_le(1n+Nat.add(Nat.add(I.count(I.active_fields(aa, na, fa)), I.count(I.active_fields(ab, nb, fb))), Nat.mul(512n, Nat.add(Measure.payload(I.active_fields(aa, na, fa)), Measure.payload(I.active_fields(ab, nb, fb))))), Nat.mul(512n, 1n+_)) == True{} : Bool}
  expansion_headroom(I.count(I.active_fields(aa, na, fa)), I.count(I.active_fields(ab, nb, fb)), Measure.payload(I.active_fields(aa, na, fa)), Measure.payload(I.active_fields(ab, nb, fb)), I.weight(fa), I.weight(fb), Active.bounded_slots(aa, na, fa, left_bound), Active.bounded_slots(ab, nb, fb, right_bound), Measure.expansion_payload_bound(aa, na, fa), Measure.expansion_payload_bound(ab, nb, fb))

law null_payload:
  for +tail: T.Schema
  {Nat.is_le(Measure.payload(tail), Measure.payload(T.Chain{T.Null{}, tail})) == True{} : Bool}
def null_payload(tail): O.reflexive(Measure.payload(tail))

law named_payload:
  for +name: String
  for +field: T.Schema
  for +tail: T.Schema
  {Nat.is_le(Measure.payload(tail), Measure.payload(T.Chain{T.Named{name, field}, tail})) == True{} : Bool}
def named_payload(name, field, tail):
  O.left_below_sum(1n+I.weight(field), Measure.payload(tail))

law slots_tail_step:
  for +ha: T.Schema
  for +a: T.Schema
  for +hb: T.Schema
  for +b: T.Schema
  for left: {Nat.is_le(Measure.payload(a), Measure.payload(T.Chain{ha, a})) == True{} : Bool}
  for right: {Nat.is_le(Measure.payload(b), Measure.payload(T.Chain{hb, b})) == True{} : Bool}
  {Nat.is_le(1n+slots(a, b), slots(T.Chain{ha, a}, T.Chain{hb, b})) == True{} : Bool}
def slots_tail_step(ha, a, hb, b, left, right):
  %Equal.sym(Nat, Nat.add(I.count(a), 1n+I.count(b)), 1n+Nat.add(I.count(a), I.count(b)), P.add_succ(I.count(a), I.count(b))) : {Nat.is_le(1n+Nat.add(Nat.add(I.count(a), I.count(b)), Nat.mul(512n, Nat.add(Measure.payload(a), Measure.payload(b)))), Nat.add(1n+_, Nat.mul(512n, Nat.add(Measure.payload(T.Chain{ha, a}), Measure.payload(T.Chain{hb, b}))))) == True{} : Bool}
  A.add_monotone(1n+Nat.add(I.count(a), I.count(b)), Nat.mul(512n, Nat.add(Measure.payload(a), Measure.payload(b))), 2n+Nat.add(I.count(a), I.count(b)), Nat.mul(512n, Nat.add(Measure.payload(T.Chain{ha, a}), Measure.payload(T.Chain{hb, b}))), O.step_right(1n+Nat.add(I.count(a), I.count(b)), 1n+Nat.add(I.count(a), I.count(b)), O.reflexive(1n+Nat.add(I.count(a), I.count(b)))), A.mul_monotone(512n, Nat.add(Measure.payload(a), Measure.payload(b)), Nat.add(Measure.payload(T.Chain{ha, a}), Measure.payload(T.Chain{hb, b})), A.add_monotone(Measure.payload(a), Measure.payload(b), Measure.payload(T.Chain{ha, a}), Measure.payload(T.Chain{hb, b}), left, right)))

law named_slot_pair_step:
  for +na: String
  for +fa: T.Schema
  for +a: T.Schema
  for +nb: String
  for +fb: T.Schema
  for +b: T.Schema
  {Nat.is_le(1n+regular(T.Named{na, fa}, T.Named{nb, fb}), slots(T.Chain{T.Named{na, fa}, a}, T.Chain{T.Named{nb, fb}, b})) == True{} : Bool}
def named_slot_pair_step(na, fa, a, nb, fb, b):
  A.add_monotone(1n, Nat.mul(512n, Nat.add(I.weight(T.Named{na, fa}), I.weight(T.Named{nb, fb}))), Nat.add(I.count(T.Chain{T.Named{na, fa}, a}), I.count(T.Chain{T.Named{nb, fb}, b})), Nat.mul(512n, Nat.add(Measure.payload(T.Chain{T.Named{na, fa}, a}), Measure.payload(T.Chain{T.Named{nb, fb}, b}))),
    O.zero_le(Nat.add(I.count(a), 1n+I.count(b))),
    A.mul_monotone(512n, Nat.add(I.weight(T.Named{na, fa}), I.weight(T.Named{nb, fb})), Nat.add(Measure.payload(T.Chain{T.Named{na, fa}, a}), Measure.payload(T.Chain{T.Named{nb, fb}, b})),
      A.add_monotone(I.weight(T.Named{na, fa}), I.weight(T.Named{nb, fb}), Measure.payload(T.Chain{T.Named{na, fa}, a}), Measure.payload(T.Chain{T.Named{nb, fb}, b}), O.below_sum(I.weight(fa), Measure.payload(a)), O.below_sum(I.weight(fb), Measure.payload(b)))))

law positive:
  for +mode: S.Judgement
  for +a: T.Schema
  for +b: T.Schema
  {Nat.is_le(1n, rank(mode, a, b)) == True{} : Bool}
def positive(mode, a, b):
  match mode:
    case S.Pair{}: O.zero_le(Nat.mul(512n, Nat.add(I.weight(a), I.weight(b))))
    case S.All{}: O.zero_le(Nat.mul(512n, Nat.add(I.weight(a), I.weight(b))))
    case S.Row{}: O.zero_le(Nat.mul(512n, Nat.add(I.weight(a), I.weight(b))))
    case S.Slots{}: O.zero_le(Nat.add(Nat.add(I.count(a), I.count(b)), Nat.mul(512n, Nat.add(Measure.payload(a), Measure.payload(b)))))

law child_budget:
  for +child: Nat
  for +parent: Nat
  for +fuel: Nat
  for decrease: {Nat.is_le(1n+child, parent) == True{} : Bool}
  for enough: {Nat.is_le(parent, 1n+fuel) == True{} : Bool}
  {Nat.is_le(child, fuel) == True{} : Bool}
def child_budget(child, parent, fuel, decrease, enough):
  O.transitive(1n+child, parent, 1n+fuel, decrease, enough)
