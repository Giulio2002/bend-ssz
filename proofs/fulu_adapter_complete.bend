import Base
import ../types/fulu.bend as F
import ../types/schema.bend as T
import ../spec/representation.bend as S
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

def present(-A: Data, result: Maybe<&2, A>) -> Bool:
  match result:
    case None{}: False{}
    case Some{value}: True{}

law impossible:
  for +goal: Bool
  for contradiction: {False{} == True{} : Bool}
  {goal == True{} : Bool}
def impossible(goal, contradiction): Empty.absurd({goal == True{} : Bool}, W.false_true(contradiction))

# Generated adapter completeness for representation shape (not numeric validity).
law peel:
  for +goal: Bool
  for +rest: T.Value
  for +s: T.Schema
  for +ss: T.Schema
  for +valid: {S.shape(rest, T.Chain{s, ss}) == True{} : Bool}
  for k: @+h: T.Value -> @+head_ok: {S.shape(h, s) == True{} : Bool} -> @+t: T.Value -> @+tail_ok: {S.shape(t, ss) == True{} : Bool} -> @+shape: {rest == T.Items{h, t} : T.Value} -> {goal == True{} : Bool}
  {goal == True{} : Bool}
def peel(goal, rest, s, ss, valid, k):
  match rest:
    case T.Items{h, t}: k(h, V.and_left(S.shape(h, s), S.shape(t, ss), valid), t, V.and_right(S.shape(h, s), S.shape(t, ss), valid), {==})
    case T.BooleanValue{bad0}: impossible(goal, valid)
    case T.UnsignedValue{bad0}: impossible(goal, valid)
    case T.BytesValue{bad0}: impossible(goal, valid)
    case T.BitsValue{bad0}: impossible(goal, valid)
    case T.Sequence{bad0}: impossible(goal, valid)
    case T.EmptyItems{}: impossible(goal, valid)
    case T.Selected{bad0, bad1}: impossible(goal, valid)
    case T.NullValue{}: impossible(goal, valid)

law finish:
  for +goal: Bool
  for +rest: T.Value
  for +valid: {S.shape(rest, T.End{}) == True{} : Bool}
  for k: @+shape: {rest == T.EmptyItems{} : T.Value} -> {goal == True{} : Bool}
  {goal == True{} : Bool}
def finish(goal, rest, valid, k):
  match rest:
    case T.EmptyItems{}: k({==})
    case T.BooleanValue{bad0}: impossible(goal, valid)
    case T.UnsignedValue{bad0}: impossible(goal, valid)
    case T.BytesValue{bad0}: impossible(goal, valid)
    case T.BitsValue{bad0}: impossible(goal, valid)
    case T.Sequence{bad0}: impossible(goal, valid)
    case T.Items{bad0, bad1}: impossible(goal, valid)
    case T.Selected{bad0, bad1}: impossible(goal, valid)
    case T.NullValue{}: impossible(goal, valid)

law Node0_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node0.schema())) == True{} : Bool}
  {present(F.Node0(), F.Node0.from_value(original)) == True{} : Bool}
def Node0_complete(original, valid):
  match original:
    case T.BooleanValue{value}: {==}
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node1_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node1.schema())) == True{} : Bool}
  {present(F.Node1(), F.Node1.from_value(original)) == True{} : Bool}
def Node1_complete(original, valid):
  match original:
    case T.UnsignedValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node2_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node2.schema())) == True{} : Bool}
  {present(F.Node2(), F.Node2.from_value(original)) == True{} : Bool}
def Node2_complete(original, valid):
  match original:
    case T.UnsignedValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node3_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node3.schema())) == True{} : Bool}
  {present(F.Node3(), F.Node3.from_value(original)) == True{} : Bool}
def Node3_complete(original, valid):
  match original:
    case T.UnsignedValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node4_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node4.schema())) == True{} : Bool}
  {present(F.Node4(), F.Node4.from_value(original)) == True{} : Bool}
def Node4_complete(original, valid):
  match original:
    case T.UnsignedValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node5_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node5.schema())) == True{} : Bool}
  {present(F.Node5(), F.Node5.from_value(original)) == True{} : Bool}
def Node5_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node6_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node6.schema())) == True{} : Bool}
  {present(F.Node6(), F.Node6.from_value(original)) == True{} : Bool}
def Node6_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node7_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node7.schema())) == True{} : Bool}
  {present(F.Node7(), F.Node7.from_value(original)) == True{} : Bool}
def Node7_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node8_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node8.schema())) == True{} : Bool}
  {present(F.Node8(), F.Node8.from_value(original)) == True{} : Bool}
def Node8_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node9_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node9.schema())) == True{} : Bool}
  {present(F.Node9(), F.Node9.from_value(original)) == True{} : Bool}
def Node9_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node10_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node10.schema())) == True{} : Bool}
  {present(F.Node10(), F.Node10.from_value(original)) == True{} : Bool}
def Node10_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node11_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node11.schema())) == True{} : Bool}
  {present(F.Node11(), F.Node11.from_value(original)) == True{} : Bool}
def Node11_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node12_step_complete:
  for +head: Maybe<&2, F.Node7()>
  for +acc: +List<F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_ok: {present(F.Node7(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node7()> -> {present(+List<F.Node7()>, next(a)) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_step(head, acc, next)) == True{} : Bool}
def Node12_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node12_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node7.schema())}) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_from_go(original, acc)) == True{} : Bool}
def Node12_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node12_step_complete(F.Node7.from_value(h), acc, next => F.Node7.seq_from_go(t, next), Node7_complete(h, V.and_left(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)), next => Node12_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node12_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node12.schema())) == True{} : Bool}
  {present(F.Node12(), F.Node12.from_value(original)) == True{} : Bool}
def Node12_complete(original, valid):
  match original:
    case T.Sequence{values}: Node12_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ForkValue_assemble_complete:
  for +a0: Maybe<&2, F.Node6()>
  for +a1: Maybe<&2, F.Node6()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: {present(F.Node6(), a0) == True{} : Bool}
  for p1: {present(F.Node6(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  {present(F.ForkValue(), F.ForkValue.assemble(a0, a1, a2)) == True{} : Bool}
def ForkValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law ForkValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node6.schema()), T.Chain{S.erase(F.Node6.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{items})) == True{} : Bool}
def ForkValue_fields_complete(items, valid):
  peel(present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{items})), items, S.erase(F.Node6.schema()), T.Chain{S.erase(F.Node6.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node6.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.ForkValue(), F.ForkValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          ForkValue_assemble_complete(F.Node6.from_value(o0), F.Node6.from_value(o1), F.Node3.from_value(o2), Node6_complete(o0, h0), Node6_complete(o1, h1), Node3_complete(o2, h2))))))

law ForkValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ForkValue.schema())) == True{} : Bool}
  {present(F.ForkValue(), F.ForkValue.from_value(original)) == True{} : Bool}
def ForkValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ForkValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node15_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node15.schema())) == True{} : Bool}
  {present(F.Node15(), F.Node15.from_value(original)) == True{} : Bool}
def Node15_complete(original, valid):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SyncAggregateValue_assemble_complete:
  for +a0: Maybe<&2, F.Node15()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: {present(F.Node15(), a0) == True{} : Bool}
  for p1: {present(F.Node9(), a1) == True{} : Bool}
  {present(F.SyncAggregateValue(), F.SyncAggregateValue.assemble(a0, a1)) == True{} : Bool}
def SyncAggregateValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SyncAggregateValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node15.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SyncAggregateValue(), F.SyncAggregateValue.from_value(T.Sequence{items})) == True{} : Bool}
def SyncAggregateValue_fields_complete(items, valid):
  peel(present(F.SyncAggregateValue(), F.SyncAggregateValue.from_value(T.Sequence{items})), items, S.erase(F.Node15.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SyncAggregateValue(), F.SyncAggregateValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SyncAggregateValue(), F.SyncAggregateValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node9.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SyncAggregateValue(), F.SyncAggregateValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SyncAggregateValue(), F.SyncAggregateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SyncAggregateValue(), F.SyncAggregateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SyncAggregateValue_assemble_complete(F.Node15.from_value(o0), F.Node9.from_value(o1), Node15_complete(o0, h0), Node9_complete(o1, h1)))))

law SyncAggregateValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncAggregateValue.schema())) == True{} : Bool}
  {present(F.SyncAggregateValue(), F.SyncAggregateValue.from_value(original)) == True{} : Bool}
def SyncAggregateValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SyncAggregateValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SyncAggregatorSelectionDataValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  {present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.assemble(a0, a1)) == True{} : Bool}
def SyncAggregatorSelectionDataValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SyncAggregatorSelectionDataValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.from_value(T.Sequence{items})) == True{} : Bool}
def SyncAggregatorSelectionDataValue_fields_complete(items, valid):
  peel(present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SyncAggregatorSelectionDataValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), Node3_complete(o0, h0), Node3_complete(o1, h1)))))

law SyncAggregatorSelectionDataValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncAggregatorSelectionDataValue.schema())) == True{} : Bool}
  {present(F.SyncAggregatorSelectionDataValue(), F.SyncAggregatorSelectionDataValue.from_value(original)) == True{} : Bool}
def SyncAggregatorSelectionDataValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SyncAggregatorSelectionDataValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law PowBlockValue_assemble_complete:
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node4()>
  for p0: {present(F.Node7(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node4(), a2) == True{} : Bool}
  {present(F.PowBlockValue(), F.PowBlockValue.assemble(a0, a1, a2)) == True{} : Bool}
def PowBlockValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law PowBlockValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node4.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{items})) == True{} : Bool}
def PowBlockValue_fields_complete(items, valid):
  peel(present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{items})), items, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node4.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node4.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node4.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.PowBlockValue(), F.PowBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          PowBlockValue_assemble_complete(F.Node7.from_value(o0), F.Node7.from_value(o1), F.Node4.from_value(o2), Node7_complete(o0, h0), Node7_complete(o1, h1), Node4_complete(o2, h2))))))

law PowBlockValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PowBlockValue.schema())) == True{} : Bool}
  {present(F.PowBlockValue(), F.PowBlockValue.from_value(original)) == True{} : Bool}
def PowBlockValue_complete(original, valid):
  match original:
    case T.Sequence{items}: PowBlockValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law PendingConsolidationValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  {present(F.PendingConsolidationValue(), F.PendingConsolidationValue.assemble(a0, a1)) == True{} : Bool}
def PendingConsolidationValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law PendingConsolidationValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}) == True{} : Bool}
  {present(F.PendingConsolidationValue(), F.PendingConsolidationValue.from_value(T.Sequence{items})) == True{} : Bool}
def PendingConsolidationValue_fields_complete(items, valid):
  peel(present(F.PendingConsolidationValue(), F.PendingConsolidationValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.PendingConsolidationValue(), F.PendingConsolidationValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.PendingConsolidationValue(), F.PendingConsolidationValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.PendingConsolidationValue(), F.PendingConsolidationValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.PendingConsolidationValue(), F.PendingConsolidationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.PendingConsolidationValue(), F.PendingConsolidationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        PendingConsolidationValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), Node3_complete(o0, h0), Node3_complete(o1, h1)))))

law PendingConsolidationValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PendingConsolidationValue.schema())) == True{} : Bool}
  {present(F.PendingConsolidationValue(), F.PendingConsolidationValue.from_value(original)) == True{} : Bool}
def PendingConsolidationValue_complete(original, valid):
  match original:
    case T.Sequence{items}: PendingConsolidationValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law PendingPartialWithdrawalValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  {present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.assemble(a0, a1, a2)) == True{} : Bool}
def PendingPartialWithdrawalValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law PendingPartialWithdrawalValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{items})) == True{} : Bool}
def PendingPartialWithdrawalValue_fields_complete(items, valid):
  peel(present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          PendingPartialWithdrawalValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node3.from_value(o2), Node3_complete(o0, h0), Node3_complete(o1, h1), Node3_complete(o2, h2))))))

law PendingPartialWithdrawalValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PendingPartialWithdrawalValue.schema())) == True{} : Bool}
  {present(F.PendingPartialWithdrawalValue(), F.PendingPartialWithdrawalValue.from_value(original)) == True{} : Bool}
def PendingPartialWithdrawalValue_complete(original, valid):
  match original:
    case T.Sequence{items}: PendingPartialWithdrawalValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law VoluntaryExitValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  {present(F.VoluntaryExitValue(), F.VoluntaryExitValue.assemble(a0, a1)) == True{} : Bool}
def VoluntaryExitValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law VoluntaryExitValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}) == True{} : Bool}
  {present(F.VoluntaryExitValue(), F.VoluntaryExitValue.from_value(T.Sequence{items})) == True{} : Bool}
def VoluntaryExitValue_fields_complete(items, valid):
  peel(present(F.VoluntaryExitValue(), F.VoluntaryExitValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.VoluntaryExitValue(), F.VoluntaryExitValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.VoluntaryExitValue(), F.VoluntaryExitValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.VoluntaryExitValue(), F.VoluntaryExitValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.VoluntaryExitValue(), F.VoluntaryExitValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.VoluntaryExitValue(), F.VoluntaryExitValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        VoluntaryExitValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), Node3_complete(o0, h0), Node3_complete(o1, h1)))))

law VoluntaryExitValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.VoluntaryExitValue.schema())) == True{} : Bool}
  {present(F.VoluntaryExitValue(), F.VoluntaryExitValue.from_value(original)) == True{} : Bool}
def VoluntaryExitValue_complete(original, valid):
  match original:
    case T.Sequence{items}: VoluntaryExitValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SignedVoluntaryExitValue_assemble_complete:
  for +a0: Maybe<&2, F.VoluntaryExitValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: {present(F.VoluntaryExitValue(), a0) == True{} : Bool}
  for p1: {present(F.Node9(), a1) == True{} : Bool}
  {present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.assemble(a0, a1)) == True{} : Bool}
def SignedVoluntaryExitValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SignedVoluntaryExitValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.VoluntaryExitValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.from_value(T.Sequence{items})) == True{} : Bool}
def SignedVoluntaryExitValue_fields_complete(items, valid):
  peel(present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.from_value(T.Sequence{items})), items, S.erase(F.VoluntaryExitValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node9.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SignedVoluntaryExitValue_assemble_complete(F.VoluntaryExitValue.from_value(o0), F.Node9.from_value(o1), VoluntaryExitValue_complete(o0, h0), Node9_complete(o1, h1)))))

law SignedVoluntaryExitValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedVoluntaryExitValue.schema())) == True{} : Bool}
  {present(F.SignedVoluntaryExitValue(), F.SignedVoluntaryExitValue.from_value(original)) == True{} : Bool}
def SignedVoluntaryExitValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SignedVoluntaryExitValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law HistoricalSummaryValue_assemble_complete:
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node7()>
  for p0: {present(F.Node7(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  {present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.assemble(a0, a1)) == True{} : Bool}
def HistoricalSummaryValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law HistoricalSummaryValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}) == True{} : Bool}
  {present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.from_value(T.Sequence{items})) == True{} : Bool}
def HistoricalSummaryValue_fields_complete(items, valid):
  peel(present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.from_value(T.Sequence{items})), items, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        HistoricalSummaryValue_assemble_complete(F.Node7.from_value(o0), F.Node7.from_value(o1), Node7_complete(o0, h0), Node7_complete(o1, h1)))))

law HistoricalSummaryValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.HistoricalSummaryValue.schema())) == True{} : Bool}
  {present(F.HistoricalSummaryValue(), F.HistoricalSummaryValue.from_value(original)) == True{} : Bool}
def HistoricalSummaryValue_complete(original, valid):
  match original:
    case T.Sequence{items}: HistoricalSummaryValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node24_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node24.schema())) == True{} : Bool}
  {present(F.Node24(), F.Node24.from_value(original)) == True{} : Bool}
def Node24_complete(original, valid):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SyncCommitteeContributionValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node24()>
  for +a4: Maybe<&2, F.Node9()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.Node24(), a3) == True{} : Bool}
  for p4: {present(F.Node9(), a4) == True{} : Bool}
  {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.assemble(a0, a1, a2, a3, a4)) == True{} : Bool}
def SyncCommitteeContributionValue_assemble_complete(a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: {==}
    case None{} _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: impossible(False{}, p4)
law SyncCommitteeContributionValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node24.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}}}) == True{} : Bool}
  {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{items})) == True{} : Bool}
def SyncCommitteeContributionValue_fields_complete(items, valid):
  peel(present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node24.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node24.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node24.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node24.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node9.schema()), T.End{}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            finish(present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, t4, e5 =>
              %Equal.sym(T.Value, r4, T.EmptyItems{}, e5) : {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              SyncCommitteeContributionValue_assemble_complete(F.Node3.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node24.from_value(o3), F.Node9.from_value(o4), Node3_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2), Node24_complete(o3, h3), Node9_complete(o4, h4))))))))

law SyncCommitteeContributionValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncCommitteeContributionValue.schema())) == True{} : Bool}
  {present(F.SyncCommitteeContributionValue(), F.SyncCommitteeContributionValue.from_value(original)) == True{} : Bool}
def SyncCommitteeContributionValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SyncCommitteeContributionValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ContributionAndProofValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.SyncCommitteeContributionValue()>
  for +a2: Maybe<&2, F.Node9()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.SyncCommitteeContributionValue(), a1) == True{} : Bool}
  for p2: {present(F.Node9(), a2) == True{} : Bool}
  {present(F.ContributionAndProofValue(), F.ContributionAndProofValue.assemble(a0, a1, a2)) == True{} : Bool}
def ContributionAndProofValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law ContributionAndProofValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.SyncCommitteeContributionValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{items})) == True{} : Bool}
def ContributionAndProofValue_fields_complete(items, valid):
  peel(present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.SyncCommitteeContributionValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.SyncCommitteeContributionValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node9.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          ContributionAndProofValue_assemble_complete(F.Node3.from_value(o0), F.SyncCommitteeContributionValue.from_value(o1), F.Node9.from_value(o2), Node3_complete(o0, h0), SyncCommitteeContributionValue_complete(o1, h1), Node9_complete(o2, h2))))))

law ContributionAndProofValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ContributionAndProofValue.schema())) == True{} : Bool}
  {present(F.ContributionAndProofValue(), F.ContributionAndProofValue.from_value(original)) == True{} : Bool}
def ContributionAndProofValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ContributionAndProofValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SignedContributionAndProofValue_assemble_complete:
  for +a0: Maybe<&2, F.ContributionAndProofValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: {present(F.ContributionAndProofValue(), a0) == True{} : Bool}
  for p1: {present(F.Node9(), a1) == True{} : Bool}
  {present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.assemble(a0, a1)) == True{} : Bool}
def SignedContributionAndProofValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SignedContributionAndProofValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.ContributionAndProofValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.from_value(T.Sequence{items})) == True{} : Bool}
def SignedContributionAndProofValue_fields_complete(items, valid):
  peel(present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.from_value(T.Sequence{items})), items, S.erase(F.ContributionAndProofValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node9.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SignedContributionAndProofValue_assemble_complete(F.ContributionAndProofValue.from_value(o0), F.Node9.from_value(o1), ContributionAndProofValue_complete(o0, h0), Node9_complete(o1, h1)))))

law SignedContributionAndProofValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedContributionAndProofValue.schema())) == True{} : Bool}
  {present(F.SignedContributionAndProofValue(), F.SignedContributionAndProofValue.from_value(original)) == True{} : Bool}
def SignedContributionAndProofValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SignedContributionAndProofValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SyncCommitteeMessageValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node9()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.Node9(), a3) == True{} : Bool}
  {present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.assemble(a0, a1, a2, a3)) == True{} : Bool}
def SyncCommitteeMessageValue_assemble_complete(a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: {==}
    case None{} _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{}: impossible(False{}, p3)
law SyncCommitteeMessageValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}}) == True{} : Bool}
  {present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{items})) == True{} : Bool}
def SyncCommitteeMessageValue_fields_complete(items, valid):
  peel(present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node9.schema()), T.End{}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          finish(present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, t3, e4 =>
            %Equal.sym(T.Value, r3, T.EmptyItems{}, e4) : {present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            SyncCommitteeMessageValue_assemble_complete(F.Node3.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node9.from_value(o3), Node3_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2), Node9_complete(o3, h3)))))))

law SyncCommitteeMessageValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncCommitteeMessageValue.schema())) == True{} : Bool}
  {present(F.SyncCommitteeMessageValue(), F.SyncCommitteeMessageValue.from_value(original)) == True{} : Bool}
def SyncCommitteeMessageValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SyncCommitteeMessageValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Eth1BlockValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  {present(F.Eth1BlockValue(), F.Eth1BlockValue.assemble(a0, a1, a2)) == True{} : Bool}
def Eth1BlockValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law Eth1BlockValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{items})) == True{} : Bool}
def Eth1BlockValue_fields_complete(items, valid):
  peel(present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          Eth1BlockValue_assemble_complete(F.Node3.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), Node3_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2))))))

law Eth1BlockValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Eth1BlockValue.schema())) == True{} : Bool}
  {present(F.Eth1BlockValue(), F.Eth1BlockValue.from_value(original)) == True{} : Bool}
def Eth1BlockValue_complete(original, valid):
  match original:
    case T.Sequence{items}: Eth1BlockValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law BeaconBlockHeaderValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.Node7()>
  for +a4: Maybe<&2, F.Node7()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  for p2: {present(F.Node7(), a2) == True{} : Bool}
  for p3: {present(F.Node7(), a3) == True{} : Bool}
  for p4: {present(F.Node7(), a4) == True{} : Bool}
  {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.assemble(a0, a1, a2, a3, a4)) == True{} : Bool}
def BeaconBlockHeaderValue_assemble_complete(a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: {==}
    case None{} _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: impossible(False{}, p4)
law BeaconBlockHeaderValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}}}}) == True{} : Bool}
  {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{items})) == True{} : Bool}
def BeaconBlockHeaderValue_fields_complete(items, valid):
  peel(present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node7.schema()), T.End{}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            finish(present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, t4, e5 =>
              %Equal.sym(T.Value, r4, T.EmptyItems{}, e5) : {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              BeaconBlockHeaderValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node7.from_value(o2), F.Node7.from_value(o3), F.Node7.from_value(o4), Node3_complete(o0, h0), Node3_complete(o1, h1), Node7_complete(o2, h2), Node7_complete(o3, h3), Node7_complete(o4, h4))))))))

law BeaconBlockHeaderValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BeaconBlockHeaderValue.schema())) == True{} : Bool}
  {present(F.BeaconBlockHeaderValue(), F.BeaconBlockHeaderValue.from_value(original)) == True{} : Bool}
def BeaconBlockHeaderValue_complete(original, valid):
  match original:
    case T.Sequence{items}: BeaconBlockHeaderValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SignedBeaconBlockHeaderValue_assemble_complete:
  for +a0: Maybe<&2, F.BeaconBlockHeaderValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: {present(F.BeaconBlockHeaderValue(), a0) == True{} : Bool}
  for p1: {present(F.Node9(), a1) == True{} : Bool}
  {present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.assemble(a0, a1)) == True{} : Bool}
def SignedBeaconBlockHeaderValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SignedBeaconBlockHeaderValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.from_value(T.Sequence{items})) == True{} : Bool}
def SignedBeaconBlockHeaderValue_fields_complete(items, valid):
  peel(present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.from_value(T.Sequence{items})), items, S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node9.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SignedBeaconBlockHeaderValue_assemble_complete(F.BeaconBlockHeaderValue.from_value(o0), F.Node9.from_value(o1), BeaconBlockHeaderValue_complete(o0, h0), Node9_complete(o1, h1)))))

law SignedBeaconBlockHeaderValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedBeaconBlockHeaderValue.schema())) == True{} : Bool}
  {present(F.SignedBeaconBlockHeaderValue(), F.SignedBeaconBlockHeaderValue.from_value(original)) == True{} : Bool}
def SignedBeaconBlockHeaderValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SignedBeaconBlockHeaderValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ProposerSlashingValue_assemble_complete:
  for +a0: Maybe<&2, F.SignedBeaconBlockHeaderValue()>
  for +a1: Maybe<&2, F.SignedBeaconBlockHeaderValue()>
  for p0: {present(F.SignedBeaconBlockHeaderValue(), a0) == True{} : Bool}
  for p1: {present(F.SignedBeaconBlockHeaderValue(), a1) == True{} : Bool}
  {present(F.ProposerSlashingValue(), F.ProposerSlashingValue.assemble(a0, a1)) == True{} : Bool}
def ProposerSlashingValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law ProposerSlashingValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.End{}}}) == True{} : Bool}
  {present(F.ProposerSlashingValue(), F.ProposerSlashingValue.from_value(T.Sequence{items})) == True{} : Bool}
def ProposerSlashingValue_fields_complete(items, valid):
  peel(present(F.ProposerSlashingValue(), F.ProposerSlashingValue.from_value(T.Sequence{items})), items, S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ProposerSlashingValue(), F.ProposerSlashingValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ProposerSlashingValue(), F.ProposerSlashingValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ProposerSlashingValue(), F.ProposerSlashingValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.ProposerSlashingValue(), F.ProposerSlashingValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.ProposerSlashingValue(), F.ProposerSlashingValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        ProposerSlashingValue_assemble_complete(F.SignedBeaconBlockHeaderValue.from_value(o0), F.SignedBeaconBlockHeaderValue.from_value(o1), SignedBeaconBlockHeaderValue_complete(o0, h0), SignedBeaconBlockHeaderValue_complete(o1, h1)))))

law ProposerSlashingValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ProposerSlashingValue.schema())) == True{} : Bool}
  {present(F.ProposerSlashingValue(), F.ProposerSlashingValue.from_value(original)) == True{} : Bool}
def ProposerSlashingValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ProposerSlashingValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node33_step_complete:
  for +head: Maybe<&2, F.Node7()>
  for +acc: +List<F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_ok: {present(F.Node7(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node7()> -> {present(+List<F.Node7()>, next(a)) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_step(head, acc, next)) == True{} : Bool}
def Node33_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node33_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node7.schema())}) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_from_go(original, acc)) == True{} : Bool}
def Node33_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node33_step_complete(F.Node7.from_value(h), acc, next => F.Node7.seq_from_go(t, next), Node7_complete(h, V.and_left(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)), next => Node33_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node33_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node33.schema())) == True{} : Bool}
  {present(F.Node33(), F.Node33.from_value(original)) == True{} : Bool}
def Node33_complete(original, valid):
  match original:
    case T.Sequence{values}: Node33_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law HistoricalBatchValue_assemble_complete:
  for +a0: Maybe<&2, F.Node33()>
  for +a1: Maybe<&2, F.Node33()>
  for p0: {present(F.Node33(), a0) == True{} : Bool}
  for p1: {present(F.Node33(), a1) == True{} : Bool}
  {present(F.HistoricalBatchValue(), F.HistoricalBatchValue.assemble(a0, a1)) == True{} : Bool}
def HistoricalBatchValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law HistoricalBatchValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.End{}}}) == True{} : Bool}
  {present(F.HistoricalBatchValue(), F.HistoricalBatchValue.from_value(T.Sequence{items})) == True{} : Bool}
def HistoricalBatchValue_fields_complete(items, valid):
  peel(present(F.HistoricalBatchValue(), F.HistoricalBatchValue.from_value(T.Sequence{items})), items, S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.HistoricalBatchValue(), F.HistoricalBatchValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.HistoricalBatchValue(), F.HistoricalBatchValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node33.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.HistoricalBatchValue(), F.HistoricalBatchValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.HistoricalBatchValue(), F.HistoricalBatchValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.HistoricalBatchValue(), F.HistoricalBatchValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        HistoricalBatchValue_assemble_complete(F.Node33.from_value(o0), F.Node33.from_value(o1), Node33_complete(o0, h0), Node33_complete(o1, h1)))))

law HistoricalBatchValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.HistoricalBatchValue.schema())) == True{} : Bool}
  {present(F.HistoricalBatchValue(), F.HistoricalBatchValue.from_value(original)) == True{} : Bool}
def HistoricalBatchValue_complete(original, valid):
  match original:
    case T.Sequence{items}: HistoricalBatchValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Eth1DataValue_assemble_complete:
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node7()>
  for p0: {present(F.Node7(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  for p2: {present(F.Node7(), a2) == True{} : Bool}
  {present(F.Eth1DataValue(), F.Eth1DataValue.assemble(a0, a1, a2)) == True{} : Bool}
def Eth1DataValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law Eth1DataValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{items})) == True{} : Bool}
def Eth1DataValue_fields_complete(items, valid):
  peel(present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{items})), items, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node7.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.Eth1DataValue(), F.Eth1DataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          Eth1DataValue_assemble_complete(F.Node7.from_value(o0), F.Node3.from_value(o1), F.Node7.from_value(o2), Node7_complete(o0, h0), Node3_complete(o1, h1), Node7_complete(o2, h2))))))

law Eth1DataValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Eth1DataValue.schema())) == True{} : Bool}
  {present(F.Eth1DataValue(), F.Eth1DataValue.from_value(original)) == True{} : Bool}
def Eth1DataValue_complete(original, valid):
  match original:
    case T.Sequence{items}: Eth1DataValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law CheckpointValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  {present(F.CheckpointValue(), F.CheckpointValue.assemble(a0, a1)) == True{} : Bool}
def CheckpointValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law CheckpointValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}) == True{} : Bool}
  {present(F.CheckpointValue(), F.CheckpointValue.from_value(T.Sequence{items})) == True{} : Bool}
def CheckpointValue_fields_complete(items, valid):
  peel(present(F.CheckpointValue(), F.CheckpointValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.CheckpointValue(), F.CheckpointValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.CheckpointValue(), F.CheckpointValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.CheckpointValue(), F.CheckpointValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.CheckpointValue(), F.CheckpointValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.CheckpointValue(), F.CheckpointValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        CheckpointValue_assemble_complete(F.Node3.from_value(o0), F.Node7.from_value(o1), Node3_complete(o0, h0), Node7_complete(o1, h1)))))

law CheckpointValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.CheckpointValue.schema())) == True{} : Bool}
  {present(F.CheckpointValue(), F.CheckpointValue.from_value(original)) == True{} : Bool}
def CheckpointValue_complete(original, valid):
  match original:
    case T.Sequence{items}: CheckpointValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law AttestationDataValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.CheckpointValue()>
  for +a4: Maybe<&2, F.CheckpointValue()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  for p2: {present(F.Node7(), a2) == True{} : Bool}
  for p3: {present(F.CheckpointValue(), a3) == True{} : Bool}
  for p4: {present(F.CheckpointValue(), a4) == True{} : Bool}
  {present(F.AttestationDataValue(), F.AttestationDataValue.assemble(a0, a1, a2, a3, a4)) == True{} : Bool}
def AttestationDataValue_assemble_complete(a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: {==}
    case None{} _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: impossible(False{}, p4)
law AttestationDataValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.End{}}}}}}) == True{} : Bool}
  {present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{items})) == True{} : Bool}
def AttestationDataValue_fields_complete(items, valid):
  peel(present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.End{}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.End{}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node7.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.End{}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.End{}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.CheckpointValue.schema()), T.End{}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            finish(present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, t4, e5 =>
              %Equal.sym(T.Value, r4, T.EmptyItems{}, e5) : {present(F.AttestationDataValue(), F.AttestationDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              AttestationDataValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node7.from_value(o2), F.CheckpointValue.from_value(o3), F.CheckpointValue.from_value(o4), Node3_complete(o0, h0), Node3_complete(o1, h1), Node7_complete(o2, h2), CheckpointValue_complete(o3, h3), CheckpointValue_complete(o4, h4))))))))

law AttestationDataValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.AttestationDataValue.schema())) == True{} : Bool}
  {present(F.AttestationDataValue(), F.AttestationDataValue.from_value(original)) == True{} : Bool}
def AttestationDataValue_complete(original, valid):
  match original:
    case T.Sequence{items}: AttestationDataValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SingleAttestationValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.AttestationDataValue()>
  for +a3: Maybe<&2, F.Node9()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  for p2: {present(F.AttestationDataValue(), a2) == True{} : Bool}
  for p3: {present(F.Node9(), a3) == True{} : Bool}
  {present(F.SingleAttestationValue(), F.SingleAttestationValue.assemble(a0, a1, a2, a3)) == True{} : Bool}
def SingleAttestationValue_assemble_complete(a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: {==}
    case None{} _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{}: impossible(False{}, p3)
law SingleAttestationValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}}) == True{} : Bool}
  {present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{items})) == True{} : Bool}
def SingleAttestationValue_fields_complete(items, valid):
  peel(present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node9.schema()), T.End{}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          finish(present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, t3, e4 =>
            %Equal.sym(T.Value, r3, T.EmptyItems{}, e4) : {present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            SingleAttestationValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), F.AttestationDataValue.from_value(o2), F.Node9.from_value(o3), Node3_complete(o0, h0), Node3_complete(o1, h1), AttestationDataValue_complete(o2, h2), Node9_complete(o3, h3)))))))

law SingleAttestationValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SingleAttestationValue.schema())) == True{} : Bool}
  {present(F.SingleAttestationValue(), F.SingleAttestationValue.from_value(original)) == True{} : Bool}
def SingleAttestationValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SingleAttestationValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node39_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node39.schema())) == True{} : Bool}
  {present(F.Node39(), F.Node39.from_value(original)) == True{} : Bool}
def Node39_complete(original, valid):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node40_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node40.schema())) == True{} : Bool}
  {present(F.Node40(), F.Node40.from_value(original)) == True{} : Bool}
def Node40_complete(original, valid):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law AttestationValue_assemble_complete:
  for +a0: Maybe<&2, F.Node39()>
  for +a1: Maybe<&2, F.AttestationDataValue()>
  for +a2: Maybe<&2, F.Node9()>
  for +a3: Maybe<&2, F.Node40()>
  for p0: {present(F.Node39(), a0) == True{} : Bool}
  for p1: {present(F.AttestationDataValue(), a1) == True{} : Bool}
  for p2: {present(F.Node9(), a2) == True{} : Bool}
  for p3: {present(F.Node40(), a3) == True{} : Bool}
  {present(F.AttestationValue(), F.AttestationValue.assemble(a0, a1, a2, a3)) == True{} : Bool}
def AttestationValue_assemble_complete(a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: {==}
    case None{} _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{}: impossible(False{}, p3)
law AttestationValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node39.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node40.schema()), T.End{}}}}}) == True{} : Bool}
  {present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{items})) == True{} : Bool}
def AttestationValue_fields_complete(items, valid):
  peel(present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{items})), items, S.erase(F.Node39.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node40.schema()), T.End{}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node40.schema()), T.End{}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node40.schema()), T.End{}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node40.schema()), T.End{}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          finish(present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, t3, e4 =>
            %Equal.sym(T.Value, r3, T.EmptyItems{}, e4) : {present(F.AttestationValue(), F.AttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            AttestationValue_assemble_complete(F.Node39.from_value(o0), F.AttestationDataValue.from_value(o1), F.Node9.from_value(o2), F.Node40.from_value(o3), Node39_complete(o0, h0), AttestationDataValue_complete(o1, h1), Node9_complete(o2, h2), Node40_complete(o3, h3)))))))

law AttestationValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.AttestationValue.schema())) == True{} : Bool}
  {present(F.AttestationValue(), F.AttestationValue.from_value(original)) == True{} : Bool}
def AttestationValue_complete(original, valid):
  match original:
    case T.Sequence{items}: AttestationValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law AggregateAndProofValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.AttestationValue()>
  for +a2: Maybe<&2, F.Node9()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.AttestationValue(), a1) == True{} : Bool}
  for p2: {present(F.Node9(), a2) == True{} : Bool}
  {present(F.AggregateAndProofValue(), F.AggregateAndProofValue.assemble(a0, a1, a2)) == True{} : Bool}
def AggregateAndProofValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law AggregateAndProofValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.AttestationValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{items})) == True{} : Bool}
def AggregateAndProofValue_fields_complete(items, valid):
  peel(present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.AttestationValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.AttestationValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node9.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          AggregateAndProofValue_assemble_complete(F.Node3.from_value(o0), F.AttestationValue.from_value(o1), F.Node9.from_value(o2), Node3_complete(o0, h0), AttestationValue_complete(o1, h1), Node9_complete(o2, h2))))))

law AggregateAndProofValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.AggregateAndProofValue.schema())) == True{} : Bool}
  {present(F.AggregateAndProofValue(), F.AggregateAndProofValue.from_value(original)) == True{} : Bool}
def AggregateAndProofValue_complete(original, valid):
  match original:
    case T.Sequence{items}: AggregateAndProofValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SignedAggregateAndProofValue_assemble_complete:
  for +a0: Maybe<&2, F.AggregateAndProofValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: {present(F.AggregateAndProofValue(), a0) == True{} : Bool}
  for p1: {present(F.Node9(), a1) == True{} : Bool}
  {present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.assemble(a0, a1)) == True{} : Bool}
def SignedAggregateAndProofValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SignedAggregateAndProofValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.AggregateAndProofValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.from_value(T.Sequence{items})) == True{} : Bool}
def SignedAggregateAndProofValue_fields_complete(items, valid):
  peel(present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.from_value(T.Sequence{items})), items, S.erase(F.AggregateAndProofValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node9.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SignedAggregateAndProofValue_assemble_complete(F.AggregateAndProofValue.from_value(o0), F.Node9.from_value(o1), AggregateAndProofValue_complete(o0, h0), Node9_complete(o1, h1)))))

law SignedAggregateAndProofValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedAggregateAndProofValue.schema())) == True{} : Bool}
  {present(F.SignedAggregateAndProofValue(), F.SignedAggregateAndProofValue.from_value(original)) == True{} : Bool}
def SignedAggregateAndProofValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SignedAggregateAndProofValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node44_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node44.schema())) == True{} : Bool}
  {present(F.Node44(), F.Node44.from_value(original)) == True{} : Bool}
def Node44_complete(original, valid):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law PendingAttestationValue_assemble_complete:
  for +a0: Maybe<&2, F.Node44()>
  for +a1: Maybe<&2, F.AttestationDataValue()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node3()>
  for p0: {present(F.Node44(), a0) == True{} : Bool}
  for p1: {present(F.AttestationDataValue(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.Node3(), a3) == True{} : Bool}
  {present(F.PendingAttestationValue(), F.PendingAttestationValue.assemble(a0, a1, a2, a3)) == True{} : Bool}
def PendingAttestationValue_assemble_complete(a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: {==}
    case None{} _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{}: impossible(False{}, p3)
law PendingAttestationValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node44.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}) == True{} : Bool}
  {present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{items})) == True{} : Bool}
def PendingAttestationValue_fields_complete(items, valid):
  peel(present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{items})), items, S.erase(F.Node44.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node3.schema()), T.End{}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          finish(present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, t3, e4 =>
            %Equal.sym(T.Value, r3, T.EmptyItems{}, e4) : {present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            PendingAttestationValue_assemble_complete(F.Node44.from_value(o0), F.AttestationDataValue.from_value(o1), F.Node3.from_value(o2), F.Node3.from_value(o3), Node44_complete(o0, h0), AttestationDataValue_complete(o1, h1), Node3_complete(o2, h2), Node3_complete(o3, h3)))))))

law PendingAttestationValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PendingAttestationValue.schema())) == True{} : Bool}
  {present(F.PendingAttestationValue(), F.PendingAttestationValue.from_value(original)) == True{} : Bool}
def PendingAttestationValue_complete(original, valid):
  match original:
    case T.Sequence{items}: PendingAttestationValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node46_step_complete:
  for +head: Maybe<&2, F.Node3()>
  for +acc: +List<F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_ok: {present(F.Node3(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node3()> -> {present(+List<F.Node3()>, next(a)) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_step(head, acc, next)) == True{} : Bool}
def Node46_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node46_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node3.schema())}) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_from_go(original, acc)) == True{} : Bool}
def Node46_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node46_step_complete(F.Node3.from_value(h), acc, next => F.Node3.seq_from_go(t, next), Node3_complete(h, V.and_left(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)), next => Node46_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node46_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node46.schema())) == True{} : Bool}
  {present(F.Node46(), F.Node46.from_value(original)) == True{} : Bool}
def Node46_complete(original, valid):
  match original:
    case T.Sequence{values}: Node46_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law IndexedAttestationValue_assemble_complete:
  for +a0: Maybe<&2, F.Node46()>
  for +a1: Maybe<&2, F.AttestationDataValue()>
  for +a2: Maybe<&2, F.Node9()>
  for p0: {present(F.Node46(), a0) == True{} : Bool}
  for p1: {present(F.AttestationDataValue(), a1) == True{} : Bool}
  for p2: {present(F.Node9(), a2) == True{} : Bool}
  {present(F.IndexedAttestationValue(), F.IndexedAttestationValue.assemble(a0, a1, a2)) == True{} : Bool}
def IndexedAttestationValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law IndexedAttestationValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node46.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{items})) == True{} : Bool}
def IndexedAttestationValue_fields_complete(items, valid):
  peel(present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{items})), items, S.erase(F.Node46.schema()), T.Chain{S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.AttestationDataValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node9.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          IndexedAttestationValue_assemble_complete(F.Node46.from_value(o0), F.AttestationDataValue.from_value(o1), F.Node9.from_value(o2), Node46_complete(o0, h0), AttestationDataValue_complete(o1, h1), Node9_complete(o2, h2))))))

law IndexedAttestationValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.IndexedAttestationValue.schema())) == True{} : Bool}
  {present(F.IndexedAttestationValue(), F.IndexedAttestationValue.from_value(original)) == True{} : Bool}
def IndexedAttestationValue_complete(original, valid):
  match original:
    case T.Sequence{items}: IndexedAttestationValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law AttesterSlashingValue_assemble_complete:
  for +a0: Maybe<&2, F.IndexedAttestationValue()>
  for +a1: Maybe<&2, F.IndexedAttestationValue()>
  for p0: {present(F.IndexedAttestationValue(), a0) == True{} : Bool}
  for p1: {present(F.IndexedAttestationValue(), a1) == True{} : Bool}
  {present(F.AttesterSlashingValue(), F.AttesterSlashingValue.assemble(a0, a1)) == True{} : Bool}
def AttesterSlashingValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law AttesterSlashingValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.IndexedAttestationValue.schema()), T.Chain{S.erase(F.IndexedAttestationValue.schema()), T.End{}}}) == True{} : Bool}
  {present(F.AttesterSlashingValue(), F.AttesterSlashingValue.from_value(T.Sequence{items})) == True{} : Bool}
def AttesterSlashingValue_fields_complete(items, valid):
  peel(present(F.AttesterSlashingValue(), F.AttesterSlashingValue.from_value(T.Sequence{items})), items, S.erase(F.IndexedAttestationValue.schema()), T.Chain{S.erase(F.IndexedAttestationValue.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.AttesterSlashingValue(), F.AttesterSlashingValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.AttesterSlashingValue(), F.AttesterSlashingValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.IndexedAttestationValue.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.AttesterSlashingValue(), F.AttesterSlashingValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.AttesterSlashingValue(), F.AttesterSlashingValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.AttesterSlashingValue(), F.AttesterSlashingValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        AttesterSlashingValue_assemble_complete(F.IndexedAttestationValue.from_value(o0), F.IndexedAttestationValue.from_value(o1), IndexedAttestationValue_complete(o0, h0), IndexedAttestationValue_complete(o1, h1)))))

law AttesterSlashingValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.AttesterSlashingValue.schema())) == True{} : Bool}
  {present(F.AttesterSlashingValue(), F.AttesterSlashingValue.from_value(original)) == True{} : Bool}
def AttesterSlashingValue_complete(original, valid):
  match original:
    case T.Sequence{items}: AttesterSlashingValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ForkDataValue_assemble_complete:
  for +a0: Maybe<&2, F.Node6()>
  for +a1: Maybe<&2, F.Node7()>
  for p0: {present(F.Node6(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  {present(F.ForkDataValue(), F.ForkDataValue.assemble(a0, a1)) == True{} : Bool}
def ForkDataValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law ForkDataValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node6.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}) == True{} : Bool}
  {present(F.ForkDataValue(), F.ForkDataValue.from_value(T.Sequence{items})) == True{} : Bool}
def ForkDataValue_fields_complete(items, valid):
  peel(present(F.ForkDataValue(), F.ForkDataValue.from_value(T.Sequence{items})), items, S.erase(F.Node6.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ForkDataValue(), F.ForkDataValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ForkDataValue(), F.ForkDataValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ForkDataValue(), F.ForkDataValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.ForkDataValue(), F.ForkDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.ForkDataValue(), F.ForkDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        ForkDataValue_assemble_complete(F.Node6.from_value(o0), F.Node7.from_value(o1), Node6_complete(o0, h0), Node7_complete(o1, h1)))))

law ForkDataValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ForkDataValue.schema())) == True{} : Bool}
  {present(F.ForkDataValue(), F.ForkDataValue.from_value(original)) == True{} : Bool}
def ForkDataValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ForkDataValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SigningDataValue_assemble_complete:
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node7()>
  for p0: {present(F.Node7(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  {present(F.SigningDataValue(), F.SigningDataValue.assemble(a0, a1)) == True{} : Bool}
def SigningDataValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SigningDataValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SigningDataValue(), F.SigningDataValue.from_value(T.Sequence{items})) == True{} : Bool}
def SigningDataValue_fields_complete(items, valid):
  peel(present(F.SigningDataValue(), F.SigningDataValue.from_value(T.Sequence{items})), items, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SigningDataValue(), F.SigningDataValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SigningDataValue(), F.SigningDataValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SigningDataValue(), F.SigningDataValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SigningDataValue(), F.SigningDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SigningDataValue(), F.SigningDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SigningDataValue_assemble_complete(F.Node7.from_value(o0), F.Node7.from_value(o1), Node7_complete(o0, h0), Node7_complete(o1, h1)))))

law SigningDataValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SigningDataValue.schema())) == True{} : Bool}
  {present(F.SigningDataValue(), F.SigningDataValue.from_value(original)) == True{} : Bool}
def SigningDataValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SigningDataValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law DepositRequestValue_assemble_complete:
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node9()>
  for +a4: Maybe<&2, F.Node3()>
  for p0: {present(F.Node8(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.Node9(), a3) == True{} : Bool}
  for p4: {present(F.Node3(), a4) == True{} : Bool}
  {present(F.DepositRequestValue(), F.DepositRequestValue.assemble(a0, a1, a2, a3, a4)) == True{} : Bool}
def DepositRequestValue_assemble_complete(a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: {==}
    case None{} _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: impossible(False{}, p4)
law DepositRequestValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}) == True{} : Bool}
  {present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{items})) == True{} : Bool}
def DepositRequestValue_fields_complete(items, valid):
  peel(present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{items})), items, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node3.schema()), T.End{}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            finish(present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, t4, e5 =>
              %Equal.sym(T.Value, r4, T.EmptyItems{}, e5) : {present(F.DepositRequestValue(), F.DepositRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              DepositRequestValue_assemble_complete(F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node9.from_value(o3), F.Node3.from_value(o4), Node8_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2), Node9_complete(o3, h3), Node3_complete(o4, h4))))))))

law DepositRequestValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DepositRequestValue.schema())) == True{} : Bool}
  {present(F.DepositRequestValue(), F.DepositRequestValue.from_value(original)) == True{} : Bool}
def DepositRequestValue_complete(original, valid):
  match original:
    case T.Sequence{items}: DepositRequestValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law PendingDepositValue_assemble_complete:
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node9()>
  for +a4: Maybe<&2, F.Node3()>
  for p0: {present(F.Node8(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.Node9(), a3) == True{} : Bool}
  for p4: {present(F.Node3(), a4) == True{} : Bool}
  {present(F.PendingDepositValue(), F.PendingDepositValue.assemble(a0, a1, a2, a3, a4)) == True{} : Bool}
def PendingDepositValue_assemble_complete(a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: {==}
    case None{} _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: impossible(False{}, p4)
law PendingDepositValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}) == True{} : Bool}
  {present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{items})) == True{} : Bool}
def PendingDepositValue_fields_complete(items, valid):
  peel(present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{items})), items, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node9.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node3.schema()), T.End{}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            finish(present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, t4, e5 =>
              %Equal.sym(T.Value, r4, T.EmptyItems{}, e5) : {present(F.PendingDepositValue(), F.PendingDepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              PendingDepositValue_assemble_complete(F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node9.from_value(o3), F.Node3.from_value(o4), Node8_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2), Node9_complete(o3, h3), Node3_complete(o4, h4))))))))

law PendingDepositValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PendingDepositValue.schema())) == True{} : Bool}
  {present(F.PendingDepositValue(), F.PendingDepositValue.from_value(original)) == True{} : Bool}
def PendingDepositValue_complete(original, valid):
  match original:
    case T.Sequence{items}: PendingDepositValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node53_step_complete:
  for +head: Maybe<&2, F.Node8()>
  for +acc: +List<F.Node8()>
  for next: +List<F.Node8()> -> Maybe<&2, +List<F.Node8()>>
  for head_ok: {present(F.Node8(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node8()> -> {present(+List<F.Node8()>, next(a)) == True{} : Bool}
  {present(+List<F.Node8()>, F.Node8.seq_step(head, acc, next)) == True{} : Bool}
def Node53_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node53_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node8()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node8.schema())}) == True{} : Bool}
  {present(+List<F.Node8()>, F.Node8.seq_from_go(original, acc)) == True{} : Bool}
def Node53_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node53_step_complete(F.Node8.from_value(h), acc, next => F.Node8.seq_from_go(t, next), Node8_complete(h, V.and_left(S.shape(h, S.erase(F.Node8.schema())), S.shape(t, T.Repeat{S.erase(F.Node8.schema())}), valid)), next => Node53_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node8.schema())), S.shape(t, T.Repeat{S.erase(F.Node8.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node53_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node53.schema())) == True{} : Bool}
  {present(F.Node53(), F.Node53.from_value(original)) == True{} : Bool}
def Node53_complete(original, valid):
  match original:
    case T.Sequence{values}: Node53_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SyncCommitteeValue_assemble_complete:
  for +a0: Maybe<&2, F.Node53()>
  for +a1: Maybe<&2, F.Node8()>
  for p0: {present(F.Node53(), a0) == True{} : Bool}
  for p1: {present(F.Node8(), a1) == True{} : Bool}
  {present(F.SyncCommitteeValue(), F.SyncCommitteeValue.assemble(a0, a1)) == True{} : Bool}
def SyncCommitteeValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SyncCommitteeValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node53.schema()), T.Chain{S.erase(F.Node8.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SyncCommitteeValue(), F.SyncCommitteeValue.from_value(T.Sequence{items})) == True{} : Bool}
def SyncCommitteeValue_fields_complete(items, valid):
  peel(present(F.SyncCommitteeValue(), F.SyncCommitteeValue.from_value(T.Sequence{items})), items, S.erase(F.Node53.schema()), T.Chain{S.erase(F.Node8.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SyncCommitteeValue(), F.SyncCommitteeValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SyncCommitteeValue(), F.SyncCommitteeValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node8.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SyncCommitteeValue(), F.SyncCommitteeValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SyncCommitteeValue(), F.SyncCommitteeValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SyncCommitteeValue(), F.SyncCommitteeValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SyncCommitteeValue_assemble_complete(F.Node53.from_value(o0), F.Node8.from_value(o1), Node53_complete(o0, h0), Node8_complete(o1, h1)))))

law SyncCommitteeValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncCommitteeValue.schema())) == True{} : Bool}
  {present(F.SyncCommitteeValue(), F.SyncCommitteeValue.from_value(original)) == True{} : Bool}
def SyncCommitteeValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SyncCommitteeValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law DepositDataValue_assemble_complete:
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node9()>
  for p0: {present(F.Node8(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.Node9(), a3) == True{} : Bool}
  {present(F.DepositDataValue(), F.DepositDataValue.assemble(a0, a1, a2, a3)) == True{} : Bool}
def DepositDataValue_assemble_complete(a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: {==}
    case None{} _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{}: impossible(False{}, p3)
law DepositDataValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}}) == True{} : Bool}
  {present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{items})) == True{} : Bool}
def DepositDataValue_fields_complete(items, valid):
  peel(present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{items})), items, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node9.schema()), T.End{}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          finish(present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, t3, e4 =>
            %Equal.sym(T.Value, r3, T.EmptyItems{}, e4) : {present(F.DepositDataValue(), F.DepositDataValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            DepositDataValue_assemble_complete(F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node9.from_value(o3), Node8_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2), Node9_complete(o3, h3)))))))

law DepositDataValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DepositDataValue.schema())) == True{} : Bool}
  {present(F.DepositDataValue(), F.DepositDataValue.from_value(original)) == True{} : Bool}
def DepositDataValue_complete(original, valid):
  match original:
    case T.Sequence{items}: DepositDataValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node56_step_complete:
  for +head: Maybe<&2, F.Node7()>
  for +acc: +List<F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_ok: {present(F.Node7(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node7()> -> {present(+List<F.Node7()>, next(a)) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_step(head, acc, next)) == True{} : Bool}
def Node56_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node56_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node7.schema())}) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_from_go(original, acc)) == True{} : Bool}
def Node56_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node56_step_complete(F.Node7.from_value(h), acc, next => F.Node7.seq_from_go(t, next), Node7_complete(h, V.and_left(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)), next => Node56_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node56_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node56.schema())) == True{} : Bool}
  {present(F.Node56(), F.Node56.from_value(original)) == True{} : Bool}
def Node56_complete(original, valid):
  match original:
    case T.Sequence{values}: Node56_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law DepositValue_assemble_complete:
  for +a0: Maybe<&2, F.Node56()>
  for +a1: Maybe<&2, F.DepositDataValue()>
  for p0: {present(F.Node56(), a0) == True{} : Bool}
  for p1: {present(F.DepositDataValue(), a1) == True{} : Bool}
  {present(F.DepositValue(), F.DepositValue.assemble(a0, a1)) == True{} : Bool}
def DepositValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law DepositValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node56.schema()), T.Chain{S.erase(F.DepositDataValue.schema()), T.End{}}}) == True{} : Bool}
  {present(F.DepositValue(), F.DepositValue.from_value(T.Sequence{items})) == True{} : Bool}
def DepositValue_fields_complete(items, valid):
  peel(present(F.DepositValue(), F.DepositValue.from_value(T.Sequence{items})), items, S.erase(F.Node56.schema()), T.Chain{S.erase(F.DepositDataValue.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.DepositValue(), F.DepositValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.DepositValue(), F.DepositValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.DepositDataValue.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.DepositValue(), F.DepositValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.DepositValue(), F.DepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.DepositValue(), F.DepositValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        DepositValue_assemble_complete(F.Node56.from_value(o0), F.DepositDataValue.from_value(o1), Node56_complete(o0, h0), DepositDataValue_complete(o1, h1)))))

law DepositValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DepositValue.schema())) == True{} : Bool}
  {present(F.DepositValue(), F.DepositValue.from_value(original)) == True{} : Bool}
def DepositValue_complete(original, valid):
  match original:
    case T.Sequence{items}: DepositValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law DepositMessageValue_assemble_complete:
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: {present(F.Node8(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  {present(F.DepositMessageValue(), F.DepositMessageValue.assemble(a0, a1, a2)) == True{} : Bool}
def DepositMessageValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law DepositMessageValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{items})) == True{} : Bool}
def DepositMessageValue_fields_complete(items, valid):
  peel(present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{items})), items, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.DepositMessageValue(), F.DepositMessageValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          DepositMessageValue_assemble_complete(F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), Node8_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2))))))

law DepositMessageValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DepositMessageValue.schema())) == True{} : Bool}
  {present(F.DepositMessageValue(), F.DepositMessageValue.from_value(original)) == True{} : Bool}
def DepositMessageValue_complete(original, valid):
  match original:
    case T.Sequence{items}: DepositMessageValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ValidatorValue_assemble_complete:
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node0()>
  for +a4: Maybe<&2, F.Node3()>
  for +a5: Maybe<&2, F.Node3()>
  for +a6: Maybe<&2, F.Node3()>
  for +a7: Maybe<&2, F.Node3()>
  for p0: {present(F.Node8(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.Node0(), a3) == True{} : Bool}
  for p4: {present(F.Node3(), a4) == True{} : Bool}
  for p5: {present(F.Node3(), a5) == True{} : Bool}
  for p6: {present(F.Node3(), a6) == True{} : Bool}
  for p7: {present(F.Node3(), a7) == True{} : Bool}
  {present(F.ValidatorValue(), F.ValidatorValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7)) == True{} : Bool}
def ValidatorValue_assemble_complete(a0, a1, a2, a3, a4, a5, a6, a7, p0, p1, p2, p3, p4, p5, p6, p7):
  match a0 a1 a2 a3 a4 a5 a6 a7:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7}: {==}
    case None{} _ _ _ _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _ _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _ _ _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _: impossible(False{}, p4)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _: impossible(False{}, p5)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _: impossible(False{}, p6)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{}: impossible(False{}, p7)
law ValidatorValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node0.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}) == True{} : Bool}
  {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{items})) == True{} : Bool}
def ValidatorValue_fields_complete(items, valid):
  peel(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{items})), items, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node0.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node0.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node0.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node0.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            peel(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t4, o5 => h5 => r5 => t5 => e5 =>
              %Equal.sym(T.Value, r4, T.Items{o5, r5}, e5) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              peel(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, r5}}}}}}})), r5, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t5, o6 => h6 => r6 => t6 => e6 =>
                %Equal.sym(T.Value, r5, T.Items{o6, r6}, e6) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, _}}}}}}})) == True{} : Bool}
                peel(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, r6}}}}}}}})), r6, S.erase(F.Node3.schema()), T.End{}, t6, o7 => h7 => r7 => t7 => e7 =>
                  %Equal.sym(T.Value, r6, T.Items{o7, r7}, e7) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, _}}}}}}}})) == True{} : Bool}
                  finish(present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, r7}}}}}}}}})), r7, t7, e8 =>
                    %Equal.sym(T.Value, r7, T.EmptyItems{}, e8) : {present(F.ValidatorValue(), F.ValidatorValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, _}}}}}}}}})) == True{} : Bool}
                    ValidatorValue_assemble_complete(F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node0.from_value(o3), F.Node3.from_value(o4), F.Node3.from_value(o5), F.Node3.from_value(o6), F.Node3.from_value(o7), Node8_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2), Node0_complete(o3, h3), Node3_complete(o4, h4), Node3_complete(o5, h5), Node3_complete(o6, h6), Node3_complete(o7, h7)))))))))))

law ValidatorValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ValidatorValue.schema())) == True{} : Bool}
  {present(F.ValidatorValue(), F.ValidatorValue.from_value(original)) == True{} : Bool}
def ValidatorValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ValidatorValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node59_step_complete:
  for +head: Maybe<&2, F.Node7()>
  for +acc: +List<F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_ok: {present(F.Node7(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node7()> -> {present(+List<F.Node7()>, next(a)) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_step(head, acc, next)) == True{} : Bool}
def Node59_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node59_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node7.schema())}) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_from_go(original, acc)) == True{} : Bool}
def Node59_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node59_step_complete(F.Node7.from_value(h), acc, next => F.Node7.seq_from_go(t, next), Node7_complete(h, V.and_left(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)), next => Node59_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node59_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node59.schema())) == True{} : Bool}
  {present(F.Node59(), F.Node59.from_value(original)) == True{} : Bool}
def Node59_complete(original, valid):
  match original:
    case T.Sequence{values}: Node59_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node60_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node60.schema())) == True{} : Bool}
  {present(F.Node60(), F.Node60.from_value(original)) == True{} : Bool}
def Node60_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ConsolidationRequestValue_assemble_complete:
  for +a0: Maybe<&2, F.Node11()>
  for +a1: Maybe<&2, F.Node8()>
  for +a2: Maybe<&2, F.Node8()>
  for p0: {present(F.Node11(), a0) == True{} : Bool}
  for p1: {present(F.Node8(), a1) == True{} : Bool}
  for p2: {present(F.Node8(), a2) == True{} : Bool}
  {present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.assemble(a0, a1, a2)) == True{} : Bool}
def ConsolidationRequestValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law ConsolidationRequestValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node8.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{items})) == True{} : Bool}
def ConsolidationRequestValue_fields_complete(items, valid):
  peel(present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{items})), items, S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node8.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node8.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node8.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          ConsolidationRequestValue_assemble_complete(F.Node11.from_value(o0), F.Node8.from_value(o1), F.Node8.from_value(o2), Node11_complete(o0, h0), Node8_complete(o1, h1), Node8_complete(o2, h2))))))

law ConsolidationRequestValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ConsolidationRequestValue.schema())) == True{} : Bool}
  {present(F.ConsolidationRequestValue(), F.ConsolidationRequestValue.from_value(original)) == True{} : Bool}
def ConsolidationRequestValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ConsolidationRequestValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law WithdrawalRequestValue_assemble_complete:
  for +a0: Maybe<&2, F.Node11()>
  for +a1: Maybe<&2, F.Node8()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: {present(F.Node11(), a0) == True{} : Bool}
  for p1: {present(F.Node8(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  {present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.assemble(a0, a1, a2)) == True{} : Bool}
def WithdrawalRequestValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law WithdrawalRequestValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{items})) == True{} : Bool}
def WithdrawalRequestValue_fields_complete(items, valid):
  peel(present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{items})), items, S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          WithdrawalRequestValue_assemble_complete(F.Node11.from_value(o0), F.Node8.from_value(o1), F.Node3.from_value(o2), Node11_complete(o0, h0), Node8_complete(o1, h1), Node3_complete(o2, h2))))))

law WithdrawalRequestValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.WithdrawalRequestValue.schema())) == True{} : Bool}
  {present(F.WithdrawalRequestValue(), F.WithdrawalRequestValue.from_value(original)) == True{} : Bool}
def WithdrawalRequestValue_complete(original, valid):
  match original:
    case T.Sequence{items}: WithdrawalRequestValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node64_step_complete:
  for +head: Maybe<&2, F.DepositRequestValue()>
  for +acc: +List<F.DepositRequestValue()>
  for next: +List<F.DepositRequestValue()> -> Maybe<&2, +List<F.DepositRequestValue()>>
  for head_ok: {present(F.DepositRequestValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.DepositRequestValue()> -> {present(+List<F.DepositRequestValue()>, next(a)) == True{} : Bool}
  {present(+List<F.DepositRequestValue()>, F.DepositRequestValue.seq_step(head, acc, next)) == True{} : Bool}
def Node64_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node64_items_complete:
  for +original: T.Value
  for +acc: +List<F.DepositRequestValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.DepositRequestValue.schema())}) == True{} : Bool}
  {present(+List<F.DepositRequestValue()>, F.DepositRequestValue.seq_from_go(original, acc)) == True{} : Bool}
def Node64_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node64_step_complete(F.DepositRequestValue.from_value(h), acc, next => F.DepositRequestValue.seq_from_go(t, next), DepositRequestValue_complete(h, V.and_left(S.shape(h, S.erase(F.DepositRequestValue.schema())), S.shape(t, T.Repeat{S.erase(F.DepositRequestValue.schema())}), valid)), next => Node64_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.DepositRequestValue.schema())), S.shape(t, T.Repeat{S.erase(F.DepositRequestValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node64_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node64.schema())) == True{} : Bool}
  {present(F.Node64(), F.Node64.from_value(original)) == True{} : Bool}
def Node64_complete(original, valid):
  match original:
    case T.Sequence{values}: Node64_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node65_step_complete:
  for +head: Maybe<&2, F.WithdrawalRequestValue()>
  for +acc: +List<F.WithdrawalRequestValue()>
  for next: +List<F.WithdrawalRequestValue()> -> Maybe<&2, +List<F.WithdrawalRequestValue()>>
  for head_ok: {present(F.WithdrawalRequestValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.WithdrawalRequestValue()> -> {present(+List<F.WithdrawalRequestValue()>, next(a)) == True{} : Bool}
  {present(+List<F.WithdrawalRequestValue()>, F.WithdrawalRequestValue.seq_step(head, acc, next)) == True{} : Bool}
def Node65_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node65_items_complete:
  for +original: T.Value
  for +acc: +List<F.WithdrawalRequestValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.WithdrawalRequestValue.schema())}) == True{} : Bool}
  {present(+List<F.WithdrawalRequestValue()>, F.WithdrawalRequestValue.seq_from_go(original, acc)) == True{} : Bool}
def Node65_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node65_step_complete(F.WithdrawalRequestValue.from_value(h), acc, next => F.WithdrawalRequestValue.seq_from_go(t, next), WithdrawalRequestValue_complete(h, V.and_left(S.shape(h, S.erase(F.WithdrawalRequestValue.schema())), S.shape(t, T.Repeat{S.erase(F.WithdrawalRequestValue.schema())}), valid)), next => Node65_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.WithdrawalRequestValue.schema())), S.shape(t, T.Repeat{S.erase(F.WithdrawalRequestValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node65_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node65.schema())) == True{} : Bool}
  {present(F.Node65(), F.Node65.from_value(original)) == True{} : Bool}
def Node65_complete(original, valid):
  match original:
    case T.Sequence{values}: Node65_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node66_step_complete:
  for +head: Maybe<&2, F.ConsolidationRequestValue()>
  for +acc: +List<F.ConsolidationRequestValue()>
  for next: +List<F.ConsolidationRequestValue()> -> Maybe<&2, +List<F.ConsolidationRequestValue()>>
  for head_ok: {present(F.ConsolidationRequestValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.ConsolidationRequestValue()> -> {present(+List<F.ConsolidationRequestValue()>, next(a)) == True{} : Bool}
  {present(+List<F.ConsolidationRequestValue()>, F.ConsolidationRequestValue.seq_step(head, acc, next)) == True{} : Bool}
def Node66_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node66_items_complete:
  for +original: T.Value
  for +acc: +List<F.ConsolidationRequestValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.ConsolidationRequestValue.schema())}) == True{} : Bool}
  {present(+List<F.ConsolidationRequestValue()>, F.ConsolidationRequestValue.seq_from_go(original, acc)) == True{} : Bool}
def Node66_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node66_step_complete(F.ConsolidationRequestValue.from_value(h), acc, next => F.ConsolidationRequestValue.seq_from_go(t, next), ConsolidationRequestValue_complete(h, V.and_left(S.shape(h, S.erase(F.ConsolidationRequestValue.schema())), S.shape(t, T.Repeat{S.erase(F.ConsolidationRequestValue.schema())}), valid)), next => Node66_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.ConsolidationRequestValue.schema())), S.shape(t, T.Repeat{S.erase(F.ConsolidationRequestValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node66_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node66.schema())) == True{} : Bool}
  {present(F.Node66(), F.Node66.from_value(original)) == True{} : Bool}
def Node66_complete(original, valid):
  match original:
    case T.Sequence{values}: Node66_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ExecutionRequestsValue_assemble_complete:
  for +a0: Maybe<&2, F.Node64()>
  for +a1: Maybe<&2, F.Node65()>
  for +a2: Maybe<&2, F.Node66()>
  for p0: {present(F.Node64(), a0) == True{} : Bool}
  for p1: {present(F.Node65(), a1) == True{} : Bool}
  for p2: {present(F.Node66(), a2) == True{} : Bool}
  {present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.assemble(a0, a1, a2)) == True{} : Bool}
def ExecutionRequestsValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law ExecutionRequestsValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node64.schema()), T.Chain{S.erase(F.Node65.schema()), T.Chain{S.erase(F.Node66.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{items})) == True{} : Bool}
def ExecutionRequestsValue_fields_complete(items, valid):
  peel(present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{items})), items, S.erase(F.Node64.schema()), T.Chain{S.erase(F.Node65.schema()), T.Chain{S.erase(F.Node66.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node65.schema()), T.Chain{S.erase(F.Node66.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node66.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          ExecutionRequestsValue_assemble_complete(F.Node64.from_value(o0), F.Node65.from_value(o1), F.Node66.from_value(o2), Node64_complete(o0, h0), Node65_complete(o1, h1), Node66_complete(o2, h2))))))

law ExecutionRequestsValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ExecutionRequestsValue.schema())) == True{} : Bool}
  {present(F.ExecutionRequestsValue(), F.ExecutionRequestsValue.from_value(original)) == True{} : Bool}
def ExecutionRequestsValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ExecutionRequestsValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law BLSToExecutionChangeValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node8()>
  for +a2: Maybe<&2, F.Node11()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node8(), a1) == True{} : Bool}
  for p2: {present(F.Node11(), a2) == True{} : Bool}
  {present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.assemble(a0, a1, a2)) == True{} : Bool}
def BLSToExecutionChangeValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law BLSToExecutionChangeValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node11.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{items})) == True{} : Bool}
def BLSToExecutionChangeValue_fields_complete(items, valid):
  peel(present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node11.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node11.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node11.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          BLSToExecutionChangeValue_assemble_complete(F.Node3.from_value(o0), F.Node8.from_value(o1), F.Node11.from_value(o2), Node3_complete(o0, h0), Node8_complete(o1, h1), Node11_complete(o2, h2))))))

law BLSToExecutionChangeValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BLSToExecutionChangeValue.schema())) == True{} : Bool}
  {present(F.BLSToExecutionChangeValue(), F.BLSToExecutionChangeValue.from_value(original)) == True{} : Bool}
def BLSToExecutionChangeValue_complete(original, valid):
  match original:
    case T.Sequence{items}: BLSToExecutionChangeValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SignedBLSToExecutionChangeValue_assemble_complete:
  for +a0: Maybe<&2, F.BLSToExecutionChangeValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: {present(F.BLSToExecutionChangeValue(), a0) == True{} : Bool}
  for p1: {present(F.Node9(), a1) == True{} : Bool}
  {present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.assemble(a0, a1)) == True{} : Bool}
def SignedBLSToExecutionChangeValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SignedBLSToExecutionChangeValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.BLSToExecutionChangeValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.from_value(T.Sequence{items})) == True{} : Bool}
def SignedBLSToExecutionChangeValue_fields_complete(items, valid):
  peel(present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.from_value(T.Sequence{items})), items, S.erase(F.BLSToExecutionChangeValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node9.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SignedBLSToExecutionChangeValue_assemble_complete(F.BLSToExecutionChangeValue.from_value(o0), F.Node9.from_value(o1), BLSToExecutionChangeValue_complete(o0, h0), Node9_complete(o1, h1)))))

law SignedBLSToExecutionChangeValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedBLSToExecutionChangeValue.schema())) == True{} : Bool}
  {present(F.SignedBLSToExecutionChangeValue(), F.SignedBLSToExecutionChangeValue.from_value(original)) == True{} : Bool}
def SignedBLSToExecutionChangeValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SignedBLSToExecutionChangeValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node70_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node70.schema())) == True{} : Bool}
  {present(F.Node70(), F.Node70.from_value(original)) == True{} : Bool}
def Node70_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node71_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node71.schema())) == True{} : Bool}
  {present(F.Node71(), F.Node71.from_value(original)) == True{} : Bool}
def Node71_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ExecutionPayloadHeaderValue_assemble_complete:
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node11()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.Node7()>
  for +a4: Maybe<&2, F.Node70()>
  for +a5: Maybe<&2, F.Node7()>
  for +a6: Maybe<&2, F.Node3()>
  for +a7: Maybe<&2, F.Node3()>
  for +a8: Maybe<&2, F.Node3()>
  for +a9: Maybe<&2, F.Node3()>
  for +a10: Maybe<&2, F.Node71()>
  for +a11: Maybe<&2, F.Node4()>
  for +a12: Maybe<&2, F.Node7()>
  for +a13: Maybe<&2, F.Node7()>
  for +a14: Maybe<&2, F.Node7()>
  for +a15: Maybe<&2, F.Node3()>
  for +a16: Maybe<&2, F.Node3()>
  for p0: {present(F.Node7(), a0) == True{} : Bool}
  for p1: {present(F.Node11(), a1) == True{} : Bool}
  for p2: {present(F.Node7(), a2) == True{} : Bool}
  for p3: {present(F.Node7(), a3) == True{} : Bool}
  for p4: {present(F.Node70(), a4) == True{} : Bool}
  for p5: {present(F.Node7(), a5) == True{} : Bool}
  for p6: {present(F.Node3(), a6) == True{} : Bool}
  for p7: {present(F.Node3(), a7) == True{} : Bool}
  for p8: {present(F.Node3(), a8) == True{} : Bool}
  for p9: {present(F.Node3(), a9) == True{} : Bool}
  for p10: {present(F.Node71(), a10) == True{} : Bool}
  for p11: {present(F.Node4(), a11) == True{} : Bool}
  for p12: {present(F.Node7(), a12) == True{} : Bool}
  for p13: {present(F.Node7(), a13) == True{} : Bool}
  for p14: {present(F.Node7(), a14) == True{} : Bool}
  for p15: {present(F.Node3(), a15) == True{} : Bool}
  for p16: {present(F.Node3(), a16) == True{} : Bool}
  {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)) == True{} : Bool}
def ExecutionPayloadHeaderValue_assemble_complete(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16):
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16}: {==}
    case None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p4)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p5)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _ _ _ _ _ _ _ _ _ _: impossible(False{}, p6)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{} _ _ _ _ _ _ _ _ _: impossible(False{}, p7)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} None{} _ _ _ _ _ _ _ _: impossible(False{}, p8)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} None{} _ _ _ _ _ _ _: impossible(False{}, p9)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} None{} _ _ _ _ _ _: impossible(False{}, p10)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} None{} _ _ _ _ _: impossible(False{}, p11)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} None{} _ _ _ _: impossible(False{}, p12)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} None{} _ _ _: impossible(False{}, p13)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} None{} _ _: impossible(False{}, p14)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} None{} _: impossible(False{}, p15)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} None{}: impossible(False{}, p16)
law ExecutionPayloadHeaderValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}}}}}) == True{} : Bool}
  {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{items})) == True{} : Bool}
def ExecutionPayloadHeaderValue_fields_complete(items, valid):
  peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{items})), items, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}, t4, o5 => h5 => r5 => t5 => e5 =>
              %Equal.sym(T.Value, r4, T.Items{o5, r5}, e5) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, r5}}}}}}})), r5, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}, t5, o6 => h6 => r6 => t6 => e6 =>
                %Equal.sym(T.Value, r5, T.Items{o6, r6}, e6) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, _}}}}}}})) == True{} : Bool}
                peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, r6}}}}}}}})), r6, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}, t6, o7 => h7 => r7 => t7 => e7 =>
                  %Equal.sym(T.Value, r6, T.Items{o7, r7}, e7) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, _}}}}}}}})) == True{} : Bool}
                  peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, r7}}}}}}}}})), r7, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}, t7, o8 => h8 => r8 => t8 => e8 =>
                    %Equal.sym(T.Value, r7, T.Items{o8, r8}, e8) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, _}}}}}}}}})) == True{} : Bool}
                    peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, r8}}}}}}}}}})), r8, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}, t8, o9 => h9 => r9 => t9 => e9 =>
                      %Equal.sym(T.Value, r8, T.Items{o9, r9}, e9) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, _}}}}}}}}}})) == True{} : Bool}
                      peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, r9}}}}}}}}}}})), r9, S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}, t9, o10 => h10 => r10 => t10 => e10 =>
                        %Equal.sym(T.Value, r9, T.Items{o10, r10}, e10) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, _}}}}}}}}}}})) == True{} : Bool}
                        peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, r10}}}}}}}}}}}})), r10, S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}, t10, o11 => h11 => r11 => t11 => e11 =>
                          %Equal.sym(T.Value, r10, T.Items{o11, r11}, e11) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, _}}}}}}}}}}}})) == True{} : Bool}
                          peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, r11}}}}}}}}}}}}})), r11, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}, t11, o12 => h12 => r12 => t12 => e12 =>
                            %Equal.sym(T.Value, r11, T.Items{o12, r12}, e12) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, _}}}}}}}}}}}}})) == True{} : Bool}
                            peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, r12}}}}}}}}}}}}}})), r12, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, t12, o13 => h13 => r13 => t13 => e13 =>
                              %Equal.sym(T.Value, r12, T.Items{o13, r13}, e13) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, _}}}}}}}}}}}}}})) == True{} : Bool}
                              peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, r13}}}}}}}}}}}}}}})), r13, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t13, o14 => h14 => r14 => t14 => e14 =>
                                %Equal.sym(T.Value, r13, T.Items{o14, r14}, e14) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, _}}}}}}}}}}}}}}})) == True{} : Bool}
                                peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, r14}}}}}}}}}}}}}}}})), r14, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t14, o15 => h15 => r15 => t15 => e15 =>
                                  %Equal.sym(T.Value, r14, T.Items{o15, r15}, e15) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, _}}}}}}}}}}}}}}}})) == True{} : Bool}
                                  peel(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, r15}}}}}}}}}}}}}}}}})), r15, S.erase(F.Node3.schema()), T.End{}, t15, o16 => h16 => r16 => t16 => e16 =>
                                    %Equal.sym(T.Value, r15, T.Items{o16, r16}, e16) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, _}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                    finish(present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, r16}}}}}}}}}}}}}}}}}})), r16, t16, e17 =>
                                      %Equal.sym(T.Value, r16, T.EmptyItems{}, e17) : {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, _}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                      ExecutionPayloadHeaderValue_assemble_complete(F.Node7.from_value(o0), F.Node11.from_value(o1), F.Node7.from_value(o2), F.Node7.from_value(o3), F.Node70.from_value(o4), F.Node7.from_value(o5), F.Node3.from_value(o6), F.Node3.from_value(o7), F.Node3.from_value(o8), F.Node3.from_value(o9), F.Node71.from_value(o10), F.Node4.from_value(o11), F.Node7.from_value(o12), F.Node7.from_value(o13), F.Node7.from_value(o14), F.Node3.from_value(o15), F.Node3.from_value(o16), Node7_complete(o0, h0), Node11_complete(o1, h1), Node7_complete(o2, h2), Node7_complete(o3, h3), Node70_complete(o4, h4), Node7_complete(o5, h5), Node3_complete(o6, h6), Node3_complete(o7, h7), Node3_complete(o8, h8), Node3_complete(o9, h9), Node71_complete(o10, h10), Node4_complete(o11, h11), Node7_complete(o12, h12), Node7_complete(o13, h13), Node7_complete(o14, h14), Node3_complete(o15, h15), Node3_complete(o16, h16))))))))))))))))))))

law ExecutionPayloadHeaderValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ExecutionPayloadHeaderValue.schema())) == True{} : Bool}
  {present(F.ExecutionPayloadHeaderValue(), F.ExecutionPayloadHeaderValue.from_value(original)) == True{} : Bool}
def ExecutionPayloadHeaderValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ExecutionPayloadHeaderValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law WithdrawalValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node11()>
  for +a3: Maybe<&2, F.Node3()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  for p2: {present(F.Node11(), a2) == True{} : Bool}
  for p3: {present(F.Node3(), a3) == True{} : Bool}
  {present(F.WithdrawalValue(), F.WithdrawalValue.assemble(a0, a1, a2, a3)) == True{} : Bool}
def WithdrawalValue_assemble_complete(a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: {==}
    case None{} _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{}: impossible(False{}, p3)
law WithdrawalValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}) == True{} : Bool}
  {present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{items})) == True{} : Bool}
def WithdrawalValue_fields_complete(items, valid):
  peel(present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node3.schema()), T.End{}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          finish(present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, t3, e4 =>
            %Equal.sym(T.Value, r3, T.EmptyItems{}, e4) : {present(F.WithdrawalValue(), F.WithdrawalValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            WithdrawalValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node11.from_value(o2), F.Node3.from_value(o3), Node3_complete(o0, h0), Node3_complete(o1, h1), Node11_complete(o2, h2), Node3_complete(o3, h3)))))))

law WithdrawalValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.WithdrawalValue.schema())) == True{} : Bool}
  {present(F.WithdrawalValue(), F.WithdrawalValue.from_value(original)) == True{} : Bool}
def WithdrawalValue_complete(original, valid):
  match original:
    case T.Sequence{items}: WithdrawalValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node74_step_complete:
  for +head: Maybe<&2, F.Node60()>
  for +acc: +List<F.Node60()>
  for next: +List<F.Node60()> -> Maybe<&2, +List<F.Node60()>>
  for head_ok: {present(F.Node60(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node60()> -> {present(+List<F.Node60()>, next(a)) == True{} : Bool}
  {present(+List<F.Node60()>, F.Node60.seq_step(head, acc, next)) == True{} : Bool}
def Node74_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node74_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node60()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node60.schema())}) == True{} : Bool}
  {present(+List<F.Node60()>, F.Node60.seq_from_go(original, acc)) == True{} : Bool}
def Node74_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node74_step_complete(F.Node60.from_value(h), acc, next => F.Node60.seq_from_go(t, next), Node60_complete(h, V.and_left(S.shape(h, S.erase(F.Node60.schema())), S.shape(t, T.Repeat{S.erase(F.Node60.schema())}), valid)), next => Node74_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node60.schema())), S.shape(t, T.Repeat{S.erase(F.Node60.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node74_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node74.schema())) == True{} : Bool}
  {present(F.Node74(), F.Node74.from_value(original)) == True{} : Bool}
def Node74_complete(original, valid):
  match original:
    case T.Sequence{values}: Node74_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node75_step_complete:
  for +head: Maybe<&2, F.WithdrawalValue()>
  for +acc: +List<F.WithdrawalValue()>
  for next: +List<F.WithdrawalValue()> -> Maybe<&2, +List<F.WithdrawalValue()>>
  for head_ok: {present(F.WithdrawalValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.WithdrawalValue()> -> {present(+List<F.WithdrawalValue()>, next(a)) == True{} : Bool}
  {present(+List<F.WithdrawalValue()>, F.WithdrawalValue.seq_step(head, acc, next)) == True{} : Bool}
def Node75_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node75_items_complete:
  for +original: T.Value
  for +acc: +List<F.WithdrawalValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.WithdrawalValue.schema())}) == True{} : Bool}
  {present(+List<F.WithdrawalValue()>, F.WithdrawalValue.seq_from_go(original, acc)) == True{} : Bool}
def Node75_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node75_step_complete(F.WithdrawalValue.from_value(h), acc, next => F.WithdrawalValue.seq_from_go(t, next), WithdrawalValue_complete(h, V.and_left(S.shape(h, S.erase(F.WithdrawalValue.schema())), S.shape(t, T.Repeat{S.erase(F.WithdrawalValue.schema())}), valid)), next => Node75_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.WithdrawalValue.schema())), S.shape(t, T.Repeat{S.erase(F.WithdrawalValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node75_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node75.schema())) == True{} : Bool}
  {present(F.Node75(), F.Node75.from_value(original)) == True{} : Bool}
def Node75_complete(original, valid):
  match original:
    case T.Sequence{values}: Node75_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law ExecutionPayloadValue_assemble_complete:
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node11()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.Node7()>
  for +a4: Maybe<&2, F.Node70()>
  for +a5: Maybe<&2, F.Node7()>
  for +a6: Maybe<&2, F.Node3()>
  for +a7: Maybe<&2, F.Node3()>
  for +a8: Maybe<&2, F.Node3()>
  for +a9: Maybe<&2, F.Node3()>
  for +a10: Maybe<&2, F.Node71()>
  for +a11: Maybe<&2, F.Node4()>
  for +a12: Maybe<&2, F.Node7()>
  for +a13: Maybe<&2, F.Node74()>
  for +a14: Maybe<&2, F.Node75()>
  for +a15: Maybe<&2, F.Node3()>
  for +a16: Maybe<&2, F.Node3()>
  for p0: {present(F.Node7(), a0) == True{} : Bool}
  for p1: {present(F.Node11(), a1) == True{} : Bool}
  for p2: {present(F.Node7(), a2) == True{} : Bool}
  for p3: {present(F.Node7(), a3) == True{} : Bool}
  for p4: {present(F.Node70(), a4) == True{} : Bool}
  for p5: {present(F.Node7(), a5) == True{} : Bool}
  for p6: {present(F.Node3(), a6) == True{} : Bool}
  for p7: {present(F.Node3(), a7) == True{} : Bool}
  for p8: {present(F.Node3(), a8) == True{} : Bool}
  for p9: {present(F.Node3(), a9) == True{} : Bool}
  for p10: {present(F.Node71(), a10) == True{} : Bool}
  for p11: {present(F.Node4(), a11) == True{} : Bool}
  for p12: {present(F.Node7(), a12) == True{} : Bool}
  for p13: {present(F.Node74(), a13) == True{} : Bool}
  for p14: {present(F.Node75(), a14) == True{} : Bool}
  for p15: {present(F.Node3(), a15) == True{} : Bool}
  for p16: {present(F.Node3(), a16) == True{} : Bool}
  {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)) == True{} : Bool}
def ExecutionPayloadValue_assemble_complete(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16):
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16}: {==}
    case None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p4)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p5)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _ _ _ _ _ _ _ _ _ _: impossible(False{}, p6)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{} _ _ _ _ _ _ _ _ _: impossible(False{}, p7)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} None{} _ _ _ _ _ _ _ _: impossible(False{}, p8)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} None{} _ _ _ _ _ _ _: impossible(False{}, p9)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} None{} _ _ _ _ _ _: impossible(False{}, p10)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} None{} _ _ _ _ _: impossible(False{}, p11)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} None{} _ _ _ _: impossible(False{}, p12)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} None{} _ _ _: impossible(False{}, p13)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} None{} _ _: impossible(False{}, p14)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} None{} _: impossible(False{}, p15)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} None{}: impossible(False{}, p16)
law ExecutionPayloadValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}}}}}) == True{} : Bool}
  {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{items})) == True{} : Bool}
def ExecutionPayloadValue_fields_complete(items, valid):
  peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{items})), items, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node11.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node70.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}}, t4, o5 => h5 => r5 => t5 => e5 =>
              %Equal.sym(T.Value, r4, T.Items{o5, r5}, e5) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, r5}}}}}}})), r5, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}}, t5, o6 => h6 => r6 => t6 => e6 =>
                %Equal.sym(T.Value, r5, T.Items{o6, r6}, e6) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, _}}}}}}})) == True{} : Bool}
                peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, r6}}}}}}}})), r6, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}}, t6, o7 => h7 => r7 => t7 => e7 =>
                  %Equal.sym(T.Value, r6, T.Items{o7, r7}, e7) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, _}}}}}}}})) == True{} : Bool}
                  peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, r7}}}}}}}}})), r7, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}}, t7, o8 => h8 => r8 => t8 => e8 =>
                    %Equal.sym(T.Value, r7, T.Items{o8, r8}, e8) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, _}}}}}}}}})) == True{} : Bool}
                    peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, r8}}}}}}}}}})), r8, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}, t8, o9 => h9 => r9 => t9 => e9 =>
                      %Equal.sym(T.Value, r8, T.Items{o9, r9}, e9) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, _}}}}}}}}}})) == True{} : Bool}
                      peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, r9}}}}}}}}}}})), r9, S.erase(F.Node71.schema()), T.Chain{S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}, t9, o10 => h10 => r10 => t10 => e10 =>
                        %Equal.sym(T.Value, r9, T.Items{o10, r10}, e10) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, _}}}}}}}}}}})) == True{} : Bool}
                        peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, r10}}}}}}}}}}}})), r10, S.erase(F.Node4.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}, t10, o11 => h11 => r11 => t11 => e11 =>
                          %Equal.sym(T.Value, r10, T.Items{o11, r11}, e11) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, _}}}}}}}}}}}})) == True{} : Bool}
                          peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, r11}}}}}}}}}}}}})), r11, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}, t11, o12 => h12 => r12 => t12 => e12 =>
                            %Equal.sym(T.Value, r11, T.Items{o12, r12}, e12) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, _}}}}}}}}}}}}})) == True{} : Bool}
                            peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, r12}}}}}}}}}}}}}})), r12, S.erase(F.Node74.schema()), T.Chain{S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, t12, o13 => h13 => r13 => t13 => e13 =>
                              %Equal.sym(T.Value, r12, T.Items{o13, r13}, e13) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, _}}}}}}}}}}}}}})) == True{} : Bool}
                              peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, r13}}}}}}}}}}}}}}})), r13, S.erase(F.Node75.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t13, o14 => h14 => r14 => t14 => e14 =>
                                %Equal.sym(T.Value, r13, T.Items{o14, r14}, e14) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, _}}}}}}}}}}}}}}})) == True{} : Bool}
                                peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, r14}}}}}}}}}}}}}}}})), r14, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t14, o15 => h15 => r15 => t15 => e15 =>
                                  %Equal.sym(T.Value, r14, T.Items{o15, r15}, e15) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, _}}}}}}}}}}}}}}}})) == True{} : Bool}
                                  peel(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, r15}}}}}}}}}}}}}}}}})), r15, S.erase(F.Node3.schema()), T.End{}, t15, o16 => h16 => r16 => t16 => e16 =>
                                    %Equal.sym(T.Value, r15, T.Items{o16, r16}, e16) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, _}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                    finish(present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, r16}}}}}}}}}}}}}}}}}})), r16, t16, e17 =>
                                      %Equal.sym(T.Value, r16, T.EmptyItems{}, e17) : {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, _}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                      ExecutionPayloadValue_assemble_complete(F.Node7.from_value(o0), F.Node11.from_value(o1), F.Node7.from_value(o2), F.Node7.from_value(o3), F.Node70.from_value(o4), F.Node7.from_value(o5), F.Node3.from_value(o6), F.Node3.from_value(o7), F.Node3.from_value(o8), F.Node3.from_value(o9), F.Node71.from_value(o10), F.Node4.from_value(o11), F.Node7.from_value(o12), F.Node74.from_value(o13), F.Node75.from_value(o14), F.Node3.from_value(o15), F.Node3.from_value(o16), Node7_complete(o0, h0), Node11_complete(o1, h1), Node7_complete(o2, h2), Node7_complete(o3, h3), Node70_complete(o4, h4), Node7_complete(o5, h5), Node3_complete(o6, h6), Node3_complete(o7, h7), Node3_complete(o8, h8), Node3_complete(o9, h9), Node71_complete(o10, h10), Node4_complete(o11, h11), Node7_complete(o12, h12), Node74_complete(o13, h13), Node75_complete(o14, h14), Node3_complete(o15, h15), Node3_complete(o16, h16))))))))))))))))))))

law ExecutionPayloadValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ExecutionPayloadValue.schema())) == True{} : Bool}
  {present(F.ExecutionPayloadValue(), F.ExecutionPayloadValue.from_value(original)) == True{} : Bool}
def ExecutionPayloadValue_complete(original, valid):
  match original:
    case T.Sequence{items}: ExecutionPayloadValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node77_step_complete:
  for +head: Maybe<&2, F.Node7()>
  for +acc: +List<F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_ok: {present(F.Node7(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node7()> -> {present(+List<F.Node7()>, next(a)) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_step(head, acc, next)) == True{} : Bool}
def Node77_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node77_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node7.schema())}) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_from_go(original, acc)) == True{} : Bool}
def Node77_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node77_step_complete(F.Node7.from_value(h), acc, next => F.Node7.seq_from_go(t, next), Node7_complete(h, V.and_left(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)), next => Node77_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node77_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node77.schema())) == True{} : Bool}
  {present(F.Node77(), F.Node77.from_value(original)) == True{} : Bool}
def Node77_complete(original, valid):
  match original:
    case T.Sequence{values}: Node77_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node78_step_complete:
  for +head: Maybe<&2, F.Eth1DataValue()>
  for +acc: +List<F.Eth1DataValue()>
  for next: +List<F.Eth1DataValue()> -> Maybe<&2, +List<F.Eth1DataValue()>>
  for head_ok: {present(F.Eth1DataValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Eth1DataValue()> -> {present(+List<F.Eth1DataValue()>, next(a)) == True{} : Bool}
  {present(+List<F.Eth1DataValue()>, F.Eth1DataValue.seq_step(head, acc, next)) == True{} : Bool}
def Node78_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node78_items_complete:
  for +original: T.Value
  for +acc: +List<F.Eth1DataValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Eth1DataValue.schema())}) == True{} : Bool}
  {present(+List<F.Eth1DataValue()>, F.Eth1DataValue.seq_from_go(original, acc)) == True{} : Bool}
def Node78_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node78_step_complete(F.Eth1DataValue.from_value(h), acc, next => F.Eth1DataValue.seq_from_go(t, next), Eth1DataValue_complete(h, V.and_left(S.shape(h, S.erase(F.Eth1DataValue.schema())), S.shape(t, T.Repeat{S.erase(F.Eth1DataValue.schema())}), valid)), next => Node78_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Eth1DataValue.schema())), S.shape(t, T.Repeat{S.erase(F.Eth1DataValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node78_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node78.schema())) == True{} : Bool}
  {present(F.Node78(), F.Node78.from_value(original)) == True{} : Bool}
def Node78_complete(original, valid):
  match original:
    case T.Sequence{values}: Node78_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node79_step_complete:
  for +head: Maybe<&2, F.ValidatorValue()>
  for +acc: +List<F.ValidatorValue()>
  for next: +List<F.ValidatorValue()> -> Maybe<&2, +List<F.ValidatorValue()>>
  for head_ok: {present(F.ValidatorValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.ValidatorValue()> -> {present(+List<F.ValidatorValue()>, next(a)) == True{} : Bool}
  {present(+List<F.ValidatorValue()>, F.ValidatorValue.seq_step(head, acc, next)) == True{} : Bool}
def Node79_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node79_items_complete:
  for +original: T.Value
  for +acc: +List<F.ValidatorValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.ValidatorValue.schema())}) == True{} : Bool}
  {present(+List<F.ValidatorValue()>, F.ValidatorValue.seq_from_go(original, acc)) == True{} : Bool}
def Node79_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node79_step_complete(F.ValidatorValue.from_value(h), acc, next => F.ValidatorValue.seq_from_go(t, next), ValidatorValue_complete(h, V.and_left(S.shape(h, S.erase(F.ValidatorValue.schema())), S.shape(t, T.Repeat{S.erase(F.ValidatorValue.schema())}), valid)), next => Node79_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.ValidatorValue.schema())), S.shape(t, T.Repeat{S.erase(F.ValidatorValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node79_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node79.schema())) == True{} : Bool}
  {present(F.Node79(), F.Node79.from_value(original)) == True{} : Bool}
def Node79_complete(original, valid):
  match original:
    case T.Sequence{values}: Node79_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node80_step_complete:
  for +head: Maybe<&2, F.Node3()>
  for +acc: +List<F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_ok: {present(F.Node3(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node3()> -> {present(+List<F.Node3()>, next(a)) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_step(head, acc, next)) == True{} : Bool}
def Node80_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node80_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node3.schema())}) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_from_go(original, acc)) == True{} : Bool}
def Node80_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node80_step_complete(F.Node3.from_value(h), acc, next => F.Node3.seq_from_go(t, next), Node3_complete(h, V.and_left(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)), next => Node80_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node80_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node80.schema())) == True{} : Bool}
  {present(F.Node80(), F.Node80.from_value(original)) == True{} : Bool}
def Node80_complete(original, valid):
  match original:
    case T.Sequence{values}: Node80_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node81_step_complete:
  for +head: Maybe<&2, F.Node7()>
  for +acc: +List<F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_ok: {present(F.Node7(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node7()> -> {present(+List<F.Node7()>, next(a)) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_step(head, acc, next)) == True{} : Bool}
def Node81_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node81_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node7.schema())}) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_from_go(original, acc)) == True{} : Bool}
def Node81_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node81_step_complete(F.Node7.from_value(h), acc, next => F.Node7.seq_from_go(t, next), Node7_complete(h, V.and_left(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)), next => Node81_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node81_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node81.schema())) == True{} : Bool}
  {present(F.Node81(), F.Node81.from_value(original)) == True{} : Bool}
def Node81_complete(original, valid):
  match original:
    case T.Sequence{values}: Node81_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node82_step_complete:
  for +head: Maybe<&2, F.Node3()>
  for +acc: +List<F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_ok: {present(F.Node3(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node3()> -> {present(+List<F.Node3()>, next(a)) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_step(head, acc, next)) == True{} : Bool}
def Node82_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node82_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node3.schema())}) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_from_go(original, acc)) == True{} : Bool}
def Node82_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node82_step_complete(F.Node3.from_value(h), acc, next => F.Node3.seq_from_go(t, next), Node3_complete(h, V.and_left(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)), next => Node82_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node82_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node82.schema())) == True{} : Bool}
  {present(F.Node82(), F.Node82.from_value(original)) == True{} : Bool}
def Node82_complete(original, valid):
  match original:
    case T.Sequence{values}: Node82_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node83_step_complete:
  for +head: Maybe<&2, F.Node1()>
  for +acc: +List<F.Node1()>
  for next: +List<F.Node1()> -> Maybe<&2, +List<F.Node1()>>
  for head_ok: {present(F.Node1(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node1()> -> {present(+List<F.Node1()>, next(a)) == True{} : Bool}
  {present(+List<F.Node1()>, F.Node1.seq_step(head, acc, next)) == True{} : Bool}
def Node83_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node83_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node1()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node1.schema())}) == True{} : Bool}
  {present(+List<F.Node1()>, F.Node1.seq_from_go(original, acc)) == True{} : Bool}
def Node83_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node83_step_complete(F.Node1.from_value(h), acc, next => F.Node1.seq_from_go(t, next), Node1_complete(h, V.and_left(S.shape(h, S.erase(F.Node1.schema())), S.shape(t, T.Repeat{S.erase(F.Node1.schema())}), valid)), next => Node83_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node1.schema())), S.shape(t, T.Repeat{S.erase(F.Node1.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node83_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node83.schema())) == True{} : Bool}
  {present(F.Node83(), F.Node83.from_value(original)) == True{} : Bool}
def Node83_complete(original, valid):
  match original:
    case T.Sequence{values}: Node83_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node84_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node84.schema())) == True{} : Bool}
  {present(F.Node84(), F.Node84.from_value(original)) == True{} : Bool}
def Node84_complete(original, valid):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node85_step_complete:
  for +head: Maybe<&2, F.HistoricalSummaryValue()>
  for +acc: +List<F.HistoricalSummaryValue()>
  for next: +List<F.HistoricalSummaryValue()> -> Maybe<&2, +List<F.HistoricalSummaryValue()>>
  for head_ok: {present(F.HistoricalSummaryValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.HistoricalSummaryValue()> -> {present(+List<F.HistoricalSummaryValue()>, next(a)) == True{} : Bool}
  {present(+List<F.HistoricalSummaryValue()>, F.HistoricalSummaryValue.seq_step(head, acc, next)) == True{} : Bool}
def Node85_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node85_items_complete:
  for +original: T.Value
  for +acc: +List<F.HistoricalSummaryValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.HistoricalSummaryValue.schema())}) == True{} : Bool}
  {present(+List<F.HistoricalSummaryValue()>, F.HistoricalSummaryValue.seq_from_go(original, acc)) == True{} : Bool}
def Node85_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node85_step_complete(F.HistoricalSummaryValue.from_value(h), acc, next => F.HistoricalSummaryValue.seq_from_go(t, next), HistoricalSummaryValue_complete(h, V.and_left(S.shape(h, S.erase(F.HistoricalSummaryValue.schema())), S.shape(t, T.Repeat{S.erase(F.HistoricalSummaryValue.schema())}), valid)), next => Node85_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.HistoricalSummaryValue.schema())), S.shape(t, T.Repeat{S.erase(F.HistoricalSummaryValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node85_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node85.schema())) == True{} : Bool}
  {present(F.Node85(), F.Node85.from_value(original)) == True{} : Bool}
def Node85_complete(original, valid):
  match original:
    case T.Sequence{values}: Node85_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node86_step_complete:
  for +head: Maybe<&2, F.PendingDepositValue()>
  for +acc: +List<F.PendingDepositValue()>
  for next: +List<F.PendingDepositValue()> -> Maybe<&2, +List<F.PendingDepositValue()>>
  for head_ok: {present(F.PendingDepositValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.PendingDepositValue()> -> {present(+List<F.PendingDepositValue()>, next(a)) == True{} : Bool}
  {present(+List<F.PendingDepositValue()>, F.PendingDepositValue.seq_step(head, acc, next)) == True{} : Bool}
def Node86_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node86_items_complete:
  for +original: T.Value
  for +acc: +List<F.PendingDepositValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.PendingDepositValue.schema())}) == True{} : Bool}
  {present(+List<F.PendingDepositValue()>, F.PendingDepositValue.seq_from_go(original, acc)) == True{} : Bool}
def Node86_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node86_step_complete(F.PendingDepositValue.from_value(h), acc, next => F.PendingDepositValue.seq_from_go(t, next), PendingDepositValue_complete(h, V.and_left(S.shape(h, S.erase(F.PendingDepositValue.schema())), S.shape(t, T.Repeat{S.erase(F.PendingDepositValue.schema())}), valid)), next => Node86_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.PendingDepositValue.schema())), S.shape(t, T.Repeat{S.erase(F.PendingDepositValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node86_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node86.schema())) == True{} : Bool}
  {present(F.Node86(), F.Node86.from_value(original)) == True{} : Bool}
def Node86_complete(original, valid):
  match original:
    case T.Sequence{values}: Node86_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node87_step_complete:
  for +head: Maybe<&2, F.PendingPartialWithdrawalValue()>
  for +acc: +List<F.PendingPartialWithdrawalValue()>
  for next: +List<F.PendingPartialWithdrawalValue()> -> Maybe<&2, +List<F.PendingPartialWithdrawalValue()>>
  for head_ok: {present(F.PendingPartialWithdrawalValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.PendingPartialWithdrawalValue()> -> {present(+List<F.PendingPartialWithdrawalValue()>, next(a)) == True{} : Bool}
  {present(+List<F.PendingPartialWithdrawalValue()>, F.PendingPartialWithdrawalValue.seq_step(head, acc, next)) == True{} : Bool}
def Node87_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node87_items_complete:
  for +original: T.Value
  for +acc: +List<F.PendingPartialWithdrawalValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.PendingPartialWithdrawalValue.schema())}) == True{} : Bool}
  {present(+List<F.PendingPartialWithdrawalValue()>, F.PendingPartialWithdrawalValue.seq_from_go(original, acc)) == True{} : Bool}
def Node87_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node87_step_complete(F.PendingPartialWithdrawalValue.from_value(h), acc, next => F.PendingPartialWithdrawalValue.seq_from_go(t, next), PendingPartialWithdrawalValue_complete(h, V.and_left(S.shape(h, S.erase(F.PendingPartialWithdrawalValue.schema())), S.shape(t, T.Repeat{S.erase(F.PendingPartialWithdrawalValue.schema())}), valid)), next => Node87_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.PendingPartialWithdrawalValue.schema())), S.shape(t, T.Repeat{S.erase(F.PendingPartialWithdrawalValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node87_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node87.schema())) == True{} : Bool}
  {present(F.Node87(), F.Node87.from_value(original)) == True{} : Bool}
def Node87_complete(original, valid):
  match original:
    case T.Sequence{values}: Node87_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node88_step_complete:
  for +head: Maybe<&2, F.PendingConsolidationValue()>
  for +acc: +List<F.PendingConsolidationValue()>
  for next: +List<F.PendingConsolidationValue()> -> Maybe<&2, +List<F.PendingConsolidationValue()>>
  for head_ok: {present(F.PendingConsolidationValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.PendingConsolidationValue()> -> {present(+List<F.PendingConsolidationValue()>, next(a)) == True{} : Bool}
  {present(+List<F.PendingConsolidationValue()>, F.PendingConsolidationValue.seq_step(head, acc, next)) == True{} : Bool}
def Node88_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node88_items_complete:
  for +original: T.Value
  for +acc: +List<F.PendingConsolidationValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.PendingConsolidationValue.schema())}) == True{} : Bool}
  {present(+List<F.PendingConsolidationValue()>, F.PendingConsolidationValue.seq_from_go(original, acc)) == True{} : Bool}
def Node88_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node88_step_complete(F.PendingConsolidationValue.from_value(h), acc, next => F.PendingConsolidationValue.seq_from_go(t, next), PendingConsolidationValue_complete(h, V.and_left(S.shape(h, S.erase(F.PendingConsolidationValue.schema())), S.shape(t, T.Repeat{S.erase(F.PendingConsolidationValue.schema())}), valid)), next => Node88_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.PendingConsolidationValue.schema())), S.shape(t, T.Repeat{S.erase(F.PendingConsolidationValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node88_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node88.schema())) == True{} : Bool}
  {present(F.Node88(), F.Node88.from_value(original)) == True{} : Bool}
def Node88_complete(original, valid):
  match original:
    case T.Sequence{values}: Node88_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node89_step_complete:
  for +head: Maybe<&2, F.Node3()>
  for +acc: +List<F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_ok: {present(F.Node3(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node3()> -> {present(+List<F.Node3()>, next(a)) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_step(head, acc, next)) == True{} : Bool}
def Node89_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node89_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node3.schema())}) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_from_go(original, acc)) == True{} : Bool}
def Node89_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node89_step_complete(F.Node3.from_value(h), acc, next => F.Node3.seq_from_go(t, next), Node3_complete(h, V.and_left(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)), next => Node89_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node89_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node89.schema())) == True{} : Bool}
  {present(F.Node89(), F.Node89.from_value(original)) == True{} : Bool}
def Node89_complete(original, valid):
  match original:
    case T.Sequence{values}: Node89_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law BeaconStateValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.ForkValue()>
  for +a4: Maybe<&2, F.BeaconBlockHeaderValue()>
  for +a5: Maybe<&2, F.Node33()>
  for +a6: Maybe<&2, F.Node33()>
  for +a7: Maybe<&2, F.Node77()>
  for +a8: Maybe<&2, F.Eth1DataValue()>
  for +a9: Maybe<&2, F.Node78()>
  for +a10: Maybe<&2, F.Node3()>
  for +a11: Maybe<&2, F.Node79()>
  for +a12: Maybe<&2, F.Node80()>
  for +a13: Maybe<&2, F.Node81()>
  for +a14: Maybe<&2, F.Node82()>
  for +a15: Maybe<&2, F.Node83()>
  for +a16: Maybe<&2, F.Node83()>
  for +a17: Maybe<&2, F.Node84()>
  for +a18: Maybe<&2, F.CheckpointValue()>
  for +a19: Maybe<&2, F.CheckpointValue()>
  for +a20: Maybe<&2, F.CheckpointValue()>
  for +a21: Maybe<&2, F.Node80()>
  for +a22: Maybe<&2, F.SyncCommitteeValue()>
  for +a23: Maybe<&2, F.SyncCommitteeValue()>
  for +a24: Maybe<&2, F.ExecutionPayloadHeaderValue()>
  for +a25: Maybe<&2, F.Node3()>
  for +a26: Maybe<&2, F.Node3()>
  for +a27: Maybe<&2, F.Node85()>
  for +a28: Maybe<&2, F.Node3()>
  for +a29: Maybe<&2, F.Node3()>
  for +a30: Maybe<&2, F.Node3()>
  for +a31: Maybe<&2, F.Node3()>
  for +a32: Maybe<&2, F.Node3()>
  for +a33: Maybe<&2, F.Node3()>
  for +a34: Maybe<&2, F.Node86()>
  for +a35: Maybe<&2, F.Node87()>
  for +a36: Maybe<&2, F.Node88()>
  for +a37: Maybe<&2, F.Node89()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node7(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.ForkValue(), a3) == True{} : Bool}
  for p4: {present(F.BeaconBlockHeaderValue(), a4) == True{} : Bool}
  for p5: {present(F.Node33(), a5) == True{} : Bool}
  for p6: {present(F.Node33(), a6) == True{} : Bool}
  for p7: {present(F.Node77(), a7) == True{} : Bool}
  for p8: {present(F.Eth1DataValue(), a8) == True{} : Bool}
  for p9: {present(F.Node78(), a9) == True{} : Bool}
  for p10: {present(F.Node3(), a10) == True{} : Bool}
  for p11: {present(F.Node79(), a11) == True{} : Bool}
  for p12: {present(F.Node80(), a12) == True{} : Bool}
  for p13: {present(F.Node81(), a13) == True{} : Bool}
  for p14: {present(F.Node82(), a14) == True{} : Bool}
  for p15: {present(F.Node83(), a15) == True{} : Bool}
  for p16: {present(F.Node83(), a16) == True{} : Bool}
  for p17: {present(F.Node84(), a17) == True{} : Bool}
  for p18: {present(F.CheckpointValue(), a18) == True{} : Bool}
  for p19: {present(F.CheckpointValue(), a19) == True{} : Bool}
  for p20: {present(F.CheckpointValue(), a20) == True{} : Bool}
  for p21: {present(F.Node80(), a21) == True{} : Bool}
  for p22: {present(F.SyncCommitteeValue(), a22) == True{} : Bool}
  for p23: {present(F.SyncCommitteeValue(), a23) == True{} : Bool}
  for p24: {present(F.ExecutionPayloadHeaderValue(), a24) == True{} : Bool}
  for p25: {present(F.Node3(), a25) == True{} : Bool}
  for p26: {present(F.Node3(), a26) == True{} : Bool}
  for p27: {present(F.Node85(), a27) == True{} : Bool}
  for p28: {present(F.Node3(), a28) == True{} : Bool}
  for p29: {present(F.Node3(), a29) == True{} : Bool}
  for p30: {present(F.Node3(), a30) == True{} : Bool}
  for p31: {present(F.Node3(), a31) == True{} : Bool}
  for p32: {present(F.Node3(), a32) == True{} : Bool}
  for p33: {present(F.Node3(), a33) == True{} : Bool}
  for p34: {present(F.Node86(), a34) == True{} : Bool}
  for p35: {present(F.Node87(), a35) == True{} : Bool}
  for p36: {present(F.Node88(), a36) == True{} : Bool}
  for p37: {present(F.Node89(), a37) == True{} : Bool}
  {present(F.BeaconStateValue(), F.BeaconStateValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37)) == True{} : Bool}
def BeaconStateValue_assemble_complete(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36, p37):
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 a32 a33 a34 a35 a36 a37:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} Some{v35} Some{v36} Some{v37}: {==}
    case None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p4)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p5)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p6)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p7)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p8)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p9)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p10)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p11)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p12)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p13)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p14)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p15)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p16)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p17)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p18)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p19)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p20)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p21)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p22)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p23)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} None{} _ _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p24)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} None{} _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p25)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} None{} _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p26)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} None{} _ _ _ _ _ _ _ _ _ _: impossible(False{}, p27)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} None{} _ _ _ _ _ _ _ _ _: impossible(False{}, p28)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} None{} _ _ _ _ _ _ _ _: impossible(False{}, p29)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} None{} _ _ _ _ _ _ _: impossible(False{}, p30)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} None{} _ _ _ _ _ _: impossible(False{}, p31)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} None{} _ _ _ _ _: impossible(False{}, p32)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} None{} _ _ _ _: impossible(False{}, p33)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} None{} _ _ _: impossible(False{}, p34)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} None{} _ _: impossible(False{}, p35)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} Some{v35} None{} _: impossible(False{}, p36)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} Some{v35} Some{v36} None{}: impossible(False{}, p37)
law BeaconStateValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.ForkValue.schema()), T.Chain{S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}) == True{} : Bool}
  {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{items})) == True{} : Bool}
def BeaconStateValue_fields_complete(items, valid):
  peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.ForkValue.schema()), T.Chain{S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.ForkValue.schema()), T.Chain{S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.ForkValue.schema()), T.Chain{S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.ForkValue.schema()), T.Chain{S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t4, o5 => h5 => r5 => t5 => e5 =>
              %Equal.sym(T.Value, r4, T.Items{o5, r5}, e5) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, r5}}}}}}})), r5, S.erase(F.Node33.schema()), T.Chain{S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t5, o6 => h6 => r6 => t6 => e6 =>
                %Equal.sym(T.Value, r5, T.Items{o6, r6}, e6) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, _}}}}}}})) == True{} : Bool}
                peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, r6}}}}}}}})), r6, S.erase(F.Node77.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t6, o7 => h7 => r7 => t7 => e7 =>
                  %Equal.sym(T.Value, r6, T.Items{o7, r7}, e7) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, _}}}}}}}})) == True{} : Bool}
                  peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, r7}}}}}}}}})), r7, S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t7, o8 => h8 => r8 => t8 => e8 =>
                    %Equal.sym(T.Value, r7, T.Items{o8, r8}, e8) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, _}}}}}}}}})) == True{} : Bool}
                    peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, r8}}}}}}}}}})), r8, S.erase(F.Node78.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t8, o9 => h9 => r9 => t9 => e9 =>
                      %Equal.sym(T.Value, r8, T.Items{o9, r9}, e9) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, _}}}}}}}}}})) == True{} : Bool}
                      peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, r9}}}}}}}}}}})), r9, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}, t9, o10 => h10 => r10 => t10 => e10 =>
                        %Equal.sym(T.Value, r9, T.Items{o10, r10}, e10) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, _}}}}}}}}}}})) == True{} : Bool}
                        peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, r10}}}}}}}}}}}})), r10, S.erase(F.Node79.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}, t10, o11 => h11 => r11 => t11 => e11 =>
                          %Equal.sym(T.Value, r10, T.Items{o11, r11}, e11) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, _}}}}}}}}}}}})) == True{} : Bool}
                          peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, r11}}}}}}}}}}}}})), r11, S.erase(F.Node80.schema()), T.Chain{S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}, t11, o12 => h12 => r12 => t12 => e12 =>
                            %Equal.sym(T.Value, r11, T.Items{o12, r12}, e12) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, _}}}}}}}}}}}}})) == True{} : Bool}
                            peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, r12}}}}}}}}}}}}}})), r12, S.erase(F.Node81.schema()), T.Chain{S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}, t12, o13 => h13 => r13 => t13 => e13 =>
                              %Equal.sym(T.Value, r12, T.Items{o13, r13}, e13) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, _}}}}}}}}}}}}}})) == True{} : Bool}
                              peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, r13}}}}}}}}}}}}}}})), r13, S.erase(F.Node82.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}}, t13, o14 => h14 => r14 => t14 => e14 =>
                                %Equal.sym(T.Value, r13, T.Items{o14, r14}, e14) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, _}}}}}}}}}}}}}}})) == True{} : Bool}
                                peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, r14}}}}}}}}}}}}}}}})), r14, S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}}, t14, o15 => h15 => r15 => t15 => e15 =>
                                  %Equal.sym(T.Value, r14, T.Items{o15, r15}, e15) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, _}}}}}}}}}}}}}}}})) == True{} : Bool}
                                  peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, r15}}}}}}}}}}}}}}}}})), r15, S.erase(F.Node83.schema()), T.Chain{S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}}, t15, o16 => h16 => r16 => t16 => e16 =>
                                    %Equal.sym(T.Value, r15, T.Items{o16, r16}, e16) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, _}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                    peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, r16}}}}}}}}}}}}}}}}}})), r16, S.erase(F.Node84.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}}, t16, o17 => h17 => r17 => t17 => e17 =>
                                      %Equal.sym(T.Value, r16, T.Items{o17, r17}, e17) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, _}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                      peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, r17}}}}}}}}}}}}}}}}}}})), r17, S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}}, t17, o18 => h18 => r18 => t18 => e18 =>
                                        %Equal.sym(T.Value, r17, T.Items{o18, r18}, e18) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, _}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                        peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, r18}}}}}}}}}}}}}}}}}}}})), r18, S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}}, t18, o19 => h19 => r19 => t19 => e19 =>
                                          %Equal.sym(T.Value, r18, T.Items{o19, r19}, e19) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, _}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                          peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, r19}}}}}}}}}}}}}}}}}}}}})), r19, S.erase(F.CheckpointValue.schema()), T.Chain{S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}}, t19, o20 => h20 => r20 => t20 => e20 =>
                                            %Equal.sym(T.Value, r19, T.Items{o20, r20}, e20) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, _}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                            peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, r20}}}}}}}}}}}}}}}}}}}}}})), r20, S.erase(F.Node80.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}}, t20, o21 => h21 => r21 => t21 => e21 =>
                                              %Equal.sym(T.Value, r20, T.Items{o21, r21}, e21) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, _}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                              peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, r21}}}}}}}}}}}}}}}}}}}}}}})), r21, S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}}, t21, o22 => h22 => r22 => t22 => e22 =>
                                                %Equal.sym(T.Value, r21, T.Items{o22, r22}, e22) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, _}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, r22}}}}}}}}}}}}}}}}}}}}}}}})), r22, S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}}, t22, o23 => h23 => r23 => t23 => e23 =>
                                                  %Equal.sym(T.Value, r22, T.Items{o23, r23}, e23) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, _}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                  peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, r23}}}}}}}}}}}}}}}}}}}}}}}}})), r23, S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}}, t23, o24 => h24 => r24 => t24 => e24 =>
                                                    %Equal.sym(T.Value, r23, T.Items{o24, r24}, e24) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, _}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                    peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, r24}}}}}}}}}}}}}}}}}}}}}}}}}})), r24, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}}, t24, o25 => h25 => r25 => t25 => e25 =>
                                                      %Equal.sym(T.Value, r24, T.Items{o25, r25}, e25) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, _}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                      peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, r25}}}}}}}}}}}}}}}}}}}}}}}}}}})), r25, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}}, t25, o26 => h26 => r26 => t26 => e26 =>
                                                        %Equal.sym(T.Value, r25, T.Items{o26, r26}, e26) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, _}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                        peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, r26}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r26, S.erase(F.Node85.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}}, t26, o27 => h27 => r27 => t27 => e27 =>
                                                          %Equal.sym(T.Value, r26, T.Items{o27, r27}, e27) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, _}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                          peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, r27}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r27, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}}, t27, o28 => h28 => r28 => t28 => e28 =>
                                                            %Equal.sym(T.Value, r27, T.Items{o28, r28}, e28) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                            peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, r28}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r28, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}}, t28, o29 => h29 => r29 => t29 => e29 =>
                                                              %Equal.sym(T.Value, r28, T.Items{o29, r29}, e29) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                              peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, r29}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r29, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}}, t29, o30 => h30 => r30 => t30 => e30 =>
                                                                %Equal.sym(T.Value, r29, T.Items{o30, r30}, e30) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, r30}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r30, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}}, t30, o31 => h31 => r31 => t31 => e31 =>
                                                                  %Equal.sym(T.Value, r30, T.Items{o31, r31}, e31) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                  peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, r31}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r31, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}}, t31, o32 => h32 => r32 => t32 => e32 =>
                                                                    %Equal.sym(T.Value, r31, T.Items{o32, r32}, e32) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                    peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, r32}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r32, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}}, t32, o33 => h33 => r33 => t33 => e33 =>
                                                                      %Equal.sym(T.Value, r32, T.Items{o33, r33}, e33) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                      peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, r33}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r33, S.erase(F.Node86.schema()), T.Chain{S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}}, t33, o34 => h34 => r34 => t34 => e34 =>
                                                                        %Equal.sym(T.Value, r33, T.Items{o34, r34}, e34) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                        peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, r34}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r34, S.erase(F.Node87.schema()), T.Chain{S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}}, t34, o35 => h35 => r35 => t35 => e35 =>
                                                                          %Equal.sym(T.Value, r34, T.Items{o35, r35}, e35) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                          peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, r35}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r35, S.erase(F.Node88.schema()), T.Chain{S.erase(F.Node89.schema()), T.End{}}, t35, o36 => h36 => r36 => t36 => e36 =>
                                                                            %Equal.sym(T.Value, r35, T.Items{o36, r36}, e36) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                            peel(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, r36}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r36, S.erase(F.Node89.schema()), T.End{}, t36, o37 => h37 => r37 => t37 => e37 =>
                                                                              %Equal.sym(T.Value, r36, T.Items{o37, r37}, e37) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                              finish(present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, r37}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), r37, t37, e38 =>
                                                                                %Equal.sym(T.Value, r37, T.EmptyItems{}, e38) : {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, _}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})) == True{} : Bool}
                                                                                BeaconStateValue_assemble_complete(F.Node3.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.ForkValue.from_value(o3), F.BeaconBlockHeaderValue.from_value(o4), F.Node33.from_value(o5), F.Node33.from_value(o6), F.Node77.from_value(o7), F.Eth1DataValue.from_value(o8), F.Node78.from_value(o9), F.Node3.from_value(o10), F.Node79.from_value(o11), F.Node80.from_value(o12), F.Node81.from_value(o13), F.Node82.from_value(o14), F.Node83.from_value(o15), F.Node83.from_value(o16), F.Node84.from_value(o17), F.CheckpointValue.from_value(o18), F.CheckpointValue.from_value(o19), F.CheckpointValue.from_value(o20), F.Node80.from_value(o21), F.SyncCommitteeValue.from_value(o22), F.SyncCommitteeValue.from_value(o23), F.ExecutionPayloadHeaderValue.from_value(o24), F.Node3.from_value(o25), F.Node3.from_value(o26), F.Node85.from_value(o27), F.Node3.from_value(o28), F.Node3.from_value(o29), F.Node3.from_value(o30), F.Node3.from_value(o31), F.Node3.from_value(o32), F.Node3.from_value(o33), F.Node86.from_value(o34), F.Node87.from_value(o35), F.Node88.from_value(o36), F.Node89.from_value(o37), Node3_complete(o0, h0), Node7_complete(o1, h1), Node3_complete(o2, h2), ForkValue_complete(o3, h3), BeaconBlockHeaderValue_complete(o4, h4), Node33_complete(o5, h5), Node33_complete(o6, h6), Node77_complete(o7, h7), Eth1DataValue_complete(o8, h8), Node78_complete(o9, h9), Node3_complete(o10, h10), Node79_complete(o11, h11), Node80_complete(o12, h12), Node81_complete(o13, h13), Node82_complete(o14, h14), Node83_complete(o15, h15), Node83_complete(o16, h16), Node84_complete(o17, h17), CheckpointValue_complete(o18, h18), CheckpointValue_complete(o19, h19), CheckpointValue_complete(o20, h20), Node80_complete(o21, h21), SyncCommitteeValue_complete(o22, h22), SyncCommitteeValue_complete(o23, h23), ExecutionPayloadHeaderValue_complete(o24, h24), Node3_complete(o25, h25), Node3_complete(o26, h26), Node85_complete(o27, h27), Node3_complete(o28, h28), Node3_complete(o29, h29), Node3_complete(o30, h30), Node3_complete(o31, h31), Node3_complete(o32, h32), Node3_complete(o33, h33), Node86_complete(o34, h34), Node87_complete(o35, h35), Node88_complete(o36, h36), Node89_complete(o37, h37)))))))))))))))))))))))))))))))))))))))))

law BeaconStateValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BeaconStateValue.schema())) == True{} : Bool}
  {present(F.BeaconStateValue(), F.BeaconStateValue.from_value(original)) == True{} : Bool}
def BeaconStateValue_complete(original, valid):
  match original:
    case T.Sequence{items}: BeaconStateValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node90_step_complete:
  for +head: Maybe<&2, F.Node7()>
  for +acc: +List<F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_ok: {present(F.Node7(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node7()> -> {present(+List<F.Node7()>, next(a)) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_step(head, acc, next)) == True{} : Bool}
def Node90_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node90_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node7.schema())}) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_from_go(original, acc)) == True{} : Bool}
def Node90_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node90_step_complete(F.Node7.from_value(h), acc, next => F.Node7.seq_from_go(t, next), Node7_complete(h, V.and_left(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)), next => Node90_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node90_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node90.schema())) == True{} : Bool}
  {present(F.Node90(), F.Node90.from_value(original)) == True{} : Bool}
def Node90_complete(original, valid):
  match original:
    case T.Sequence{values}: Node90_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law LightClientHeaderValue_assemble_complete:
  for +a0: Maybe<&2, F.BeaconBlockHeaderValue()>
  for +a1: Maybe<&2, F.ExecutionPayloadHeaderValue()>
  for +a2: Maybe<&2, F.Node90()>
  for p0: {present(F.BeaconBlockHeaderValue(), a0) == True{} : Bool}
  for p1: {present(F.ExecutionPayloadHeaderValue(), a1) == True{} : Bool}
  for p2: {present(F.Node90(), a2) == True{} : Bool}
  {present(F.LightClientHeaderValue(), F.LightClientHeaderValue.assemble(a0, a1, a2)) == True{} : Bool}
def LightClientHeaderValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law LightClientHeaderValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{items})) == True{} : Bool}
def LightClientHeaderValue_fields_complete(items, valid):
  peel(present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{items})), items, S.erase(F.BeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.ExecutionPayloadHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node90.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          LightClientHeaderValue_assemble_complete(F.BeaconBlockHeaderValue.from_value(o0), F.ExecutionPayloadHeaderValue.from_value(o1), F.Node90.from_value(o2), BeaconBlockHeaderValue_complete(o0, h0), ExecutionPayloadHeaderValue_complete(o1, h1), Node90_complete(o2, h2))))))

law LightClientHeaderValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientHeaderValue.schema())) == True{} : Bool}
  {present(F.LightClientHeaderValue(), F.LightClientHeaderValue.from_value(original)) == True{} : Bool}
def LightClientHeaderValue_complete(original, valid):
  match original:
    case T.Sequence{items}: LightClientHeaderValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law LightClientOptimisticUpdateValue_assemble_complete:
  for +a0: Maybe<&2, F.LightClientHeaderValue()>
  for +a1: Maybe<&2, F.SyncAggregateValue()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: {present(F.LightClientHeaderValue(), a0) == True{} : Bool}
  for p1: {present(F.SyncAggregateValue(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  {present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.assemble(a0, a1, a2)) == True{} : Bool}
def LightClientOptimisticUpdateValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law LightClientOptimisticUpdateValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{items})) == True{} : Bool}
def LightClientOptimisticUpdateValue_fields_complete(items, valid):
  peel(present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{items})), items, S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          LightClientOptimisticUpdateValue_assemble_complete(F.LightClientHeaderValue.from_value(o0), F.SyncAggregateValue.from_value(o1), F.Node3.from_value(o2), LightClientHeaderValue_complete(o0, h0), SyncAggregateValue_complete(o1, h1), Node3_complete(o2, h2))))))

law LightClientOptimisticUpdateValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientOptimisticUpdateValue.schema())) == True{} : Bool}
  {present(F.LightClientOptimisticUpdateValue(), F.LightClientOptimisticUpdateValue.from_value(original)) == True{} : Bool}
def LightClientOptimisticUpdateValue_complete(original, valid):
  match original:
    case T.Sequence{items}: LightClientOptimisticUpdateValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law LightClientFinalityUpdateValue_assemble_complete:
  for +a0: Maybe<&2, F.LightClientHeaderValue()>
  for +a1: Maybe<&2, F.LightClientHeaderValue()>
  for +a2: Maybe<&2, F.Node12()>
  for +a3: Maybe<&2, F.SyncAggregateValue()>
  for +a4: Maybe<&2, F.Node3()>
  for p0: {present(F.LightClientHeaderValue(), a0) == True{} : Bool}
  for p1: {present(F.LightClientHeaderValue(), a1) == True{} : Bool}
  for p2: {present(F.Node12(), a2) == True{} : Bool}
  for p3: {present(F.SyncAggregateValue(), a3) == True{} : Bool}
  for p4: {present(F.Node3(), a4) == True{} : Bool}
  {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.assemble(a0, a1, a2, a3, a4)) == True{} : Bool}
def LightClientFinalityUpdateValue_assemble_complete(a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: {==}
    case None{} _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: impossible(False{}, p4)
law LightClientFinalityUpdateValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}) == True{} : Bool}
  {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{items})) == True{} : Bool}
def LightClientFinalityUpdateValue_fields_complete(items, valid):
  peel(present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{items})), items, S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node3.schema()), T.End{}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            finish(present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, t4, e5 =>
              %Equal.sym(T.Value, r4, T.EmptyItems{}, e5) : {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              LightClientFinalityUpdateValue_assemble_complete(F.LightClientHeaderValue.from_value(o0), F.LightClientHeaderValue.from_value(o1), F.Node12.from_value(o2), F.SyncAggregateValue.from_value(o3), F.Node3.from_value(o4), LightClientHeaderValue_complete(o0, h0), LightClientHeaderValue_complete(o1, h1), Node12_complete(o2, h2), SyncAggregateValue_complete(o3, h3), Node3_complete(o4, h4))))))))

law LightClientFinalityUpdateValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientFinalityUpdateValue.schema())) == True{} : Bool}
  {present(F.LightClientFinalityUpdateValue(), F.LightClientFinalityUpdateValue.from_value(original)) == True{} : Bool}
def LightClientFinalityUpdateValue_complete(original, valid):
  match original:
    case T.Sequence{items}: LightClientFinalityUpdateValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law LightClientUpdateValue_assemble_complete:
  for +a0: Maybe<&2, F.LightClientHeaderValue()>
  for +a1: Maybe<&2, F.SyncCommitteeValue()>
  for +a2: Maybe<&2, F.Node59()>
  for +a3: Maybe<&2, F.LightClientHeaderValue()>
  for +a4: Maybe<&2, F.Node12()>
  for +a5: Maybe<&2, F.SyncAggregateValue()>
  for +a6: Maybe<&2, F.Node3()>
  for p0: {present(F.LightClientHeaderValue(), a0) == True{} : Bool}
  for p1: {present(F.SyncCommitteeValue(), a1) == True{} : Bool}
  for p2: {present(F.Node59(), a2) == True{} : Bool}
  for p3: {present(F.LightClientHeaderValue(), a3) == True{} : Bool}
  for p4: {present(F.Node12(), a4) == True{} : Bool}
  for p5: {present(F.SyncAggregateValue(), a5) == True{} : Bool}
  for p6: {present(F.Node3(), a6) == True{} : Bool}
  {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.assemble(a0, a1, a2, a3, a4, a5, a6)) == True{} : Bool}
def LightClientUpdateValue_assemble_complete(a0, a1, a2, a3, a4, a5, a6, p0, p1, p2, p3, p4, p5, p6):
  match a0 a1 a2 a3 a4 a5 a6:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6}: {==}
    case None{} _ _ _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _ _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _ _ _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _: impossible(False{}, p4)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _: impossible(False{}, p5)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{}: impossible(False{}, p6)
law LightClientUpdateValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.Node59.schema()), T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}}) == True{} : Bool}
  {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{items})) == True{} : Bool}
def LightClientUpdateValue_fields_complete(items, valid):
  peel(present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{items})), items, S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.Node59.schema()), T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.Node59.schema()), T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node59.schema()), T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node12.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            peel(present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t4, o5 => h5 => r5 => t5 => e5 =>
              %Equal.sym(T.Value, r4, T.Items{o5, r5}, e5) : {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              peel(present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, r5}}}}}}})), r5, S.erase(F.Node3.schema()), T.End{}, t5, o6 => h6 => r6 => t6 => e6 =>
                %Equal.sym(T.Value, r5, T.Items{o6, r6}, e6) : {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, _}}}}}}})) == True{} : Bool}
                finish(present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, r6}}}}}}}})), r6, t6, e7 =>
                  %Equal.sym(T.Value, r6, T.EmptyItems{}, e7) : {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, _}}}}}}}})) == True{} : Bool}
                  LightClientUpdateValue_assemble_complete(F.LightClientHeaderValue.from_value(o0), F.SyncCommitteeValue.from_value(o1), F.Node59.from_value(o2), F.LightClientHeaderValue.from_value(o3), F.Node12.from_value(o4), F.SyncAggregateValue.from_value(o5), F.Node3.from_value(o6), LightClientHeaderValue_complete(o0, h0), SyncCommitteeValue_complete(o1, h1), Node59_complete(o2, h2), LightClientHeaderValue_complete(o3, h3), Node12_complete(o4, h4), SyncAggregateValue_complete(o5, h5), Node3_complete(o6, h6))))))))))

law LightClientUpdateValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientUpdateValue.schema())) == True{} : Bool}
  {present(F.LightClientUpdateValue(), F.LightClientUpdateValue.from_value(original)) == True{} : Bool}
def LightClientUpdateValue_complete(original, valid):
  match original:
    case T.Sequence{items}: LightClientUpdateValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law LightClientBootstrapValue_assemble_complete:
  for +a0: Maybe<&2, F.LightClientHeaderValue()>
  for +a1: Maybe<&2, F.SyncCommitteeValue()>
  for +a2: Maybe<&2, F.Node59()>
  for p0: {present(F.LightClientHeaderValue(), a0) == True{} : Bool}
  for p1: {present(F.SyncCommitteeValue(), a1) == True{} : Bool}
  for p2: {present(F.Node59(), a2) == True{} : Bool}
  {present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.assemble(a0, a1, a2)) == True{} : Bool}
def LightClientBootstrapValue_assemble_complete(a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: {==}
    case None{} _ _: impossible(False{}, p0)
    case Some{v0} None{} _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{}: impossible(False{}, p2)
law LightClientBootstrapValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.Node59.schema()), T.End{}}}}) == True{} : Bool}
  {present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{items})) == True{} : Bool}
def LightClientBootstrapValue_fields_complete(items, valid):
  peel(present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{items})), items, S.erase(F.LightClientHeaderValue.schema()), T.Chain{S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.Node59.schema()), T.End{}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.SyncCommitteeValue.schema()), T.Chain{S.erase(F.Node59.schema()), T.End{}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node59.schema()), T.End{}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        finish(present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, t2, e3 =>
          %Equal.sym(T.Value, r2, T.EmptyItems{}, e3) : {present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          LightClientBootstrapValue_assemble_complete(F.LightClientHeaderValue.from_value(o0), F.SyncCommitteeValue.from_value(o1), F.Node59.from_value(o2), LightClientHeaderValue_complete(o0, h0), SyncCommitteeValue_complete(o1, h1), Node59_complete(o2, h2))))))

law LightClientBootstrapValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientBootstrapValue.schema())) == True{} : Bool}
  {present(F.LightClientBootstrapValue(), F.LightClientBootstrapValue.from_value(original)) == True{} : Bool}
def LightClientBootstrapValue_complete(original, valid):
  match original:
    case T.Sequence{items}: LightClientBootstrapValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law BlobIdentifierValue_assemble_complete:
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node3()>
  for p0: {present(F.Node7(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  {present(F.BlobIdentifierValue(), F.BlobIdentifierValue.assemble(a0, a1)) == True{} : Bool}
def BlobIdentifierValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law BlobIdentifierValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}) == True{} : Bool}
  {present(F.BlobIdentifierValue(), F.BlobIdentifierValue.from_value(T.Sequence{items})) == True{} : Bool}
def BlobIdentifierValue_fields_complete(items, valid):
  peel(present(F.BlobIdentifierValue(), F.BlobIdentifierValue.from_value(T.Sequence{items})), items, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.BlobIdentifierValue(), F.BlobIdentifierValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.BlobIdentifierValue(), F.BlobIdentifierValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.BlobIdentifierValue(), F.BlobIdentifierValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.BlobIdentifierValue(), F.BlobIdentifierValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.BlobIdentifierValue(), F.BlobIdentifierValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        BlobIdentifierValue_assemble_complete(F.Node7.from_value(o0), F.Node3.from_value(o1), Node7_complete(o0, h0), Node3_complete(o1, h1)))))

law BlobIdentifierValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BlobIdentifierValue.schema())) == True{} : Bool}
  {present(F.BlobIdentifierValue(), F.BlobIdentifierValue.from_value(original)) == True{} : Bool}
def BlobIdentifierValue_complete(original, valid):
  match original:
    case T.Sequence{items}: BlobIdentifierValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node98_step_complete:
  for +head: Maybe<&2, F.ProposerSlashingValue()>
  for +acc: +List<F.ProposerSlashingValue()>
  for next: +List<F.ProposerSlashingValue()> -> Maybe<&2, +List<F.ProposerSlashingValue()>>
  for head_ok: {present(F.ProposerSlashingValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.ProposerSlashingValue()> -> {present(+List<F.ProposerSlashingValue()>, next(a)) == True{} : Bool}
  {present(+List<F.ProposerSlashingValue()>, F.ProposerSlashingValue.seq_step(head, acc, next)) == True{} : Bool}
def Node98_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node98_items_complete:
  for +original: T.Value
  for +acc: +List<F.ProposerSlashingValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.ProposerSlashingValue.schema())}) == True{} : Bool}
  {present(+List<F.ProposerSlashingValue()>, F.ProposerSlashingValue.seq_from_go(original, acc)) == True{} : Bool}
def Node98_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node98_step_complete(F.ProposerSlashingValue.from_value(h), acc, next => F.ProposerSlashingValue.seq_from_go(t, next), ProposerSlashingValue_complete(h, V.and_left(S.shape(h, S.erase(F.ProposerSlashingValue.schema())), S.shape(t, T.Repeat{S.erase(F.ProposerSlashingValue.schema())}), valid)), next => Node98_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.ProposerSlashingValue.schema())), S.shape(t, T.Repeat{S.erase(F.ProposerSlashingValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node98_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node98.schema())) == True{} : Bool}
  {present(F.Node98(), F.Node98.from_value(original)) == True{} : Bool}
def Node98_complete(original, valid):
  match original:
    case T.Sequence{values}: Node98_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node99_step_complete:
  for +head: Maybe<&2, F.AttesterSlashingValue()>
  for +acc: +List<F.AttesterSlashingValue()>
  for next: +List<F.AttesterSlashingValue()> -> Maybe<&2, +List<F.AttesterSlashingValue()>>
  for head_ok: {present(F.AttesterSlashingValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.AttesterSlashingValue()> -> {present(+List<F.AttesterSlashingValue()>, next(a)) == True{} : Bool}
  {present(+List<F.AttesterSlashingValue()>, F.AttesterSlashingValue.seq_step(head, acc, next)) == True{} : Bool}
def Node99_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node99_items_complete:
  for +original: T.Value
  for +acc: +List<F.AttesterSlashingValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.AttesterSlashingValue.schema())}) == True{} : Bool}
  {present(+List<F.AttesterSlashingValue()>, F.AttesterSlashingValue.seq_from_go(original, acc)) == True{} : Bool}
def Node99_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node99_step_complete(F.AttesterSlashingValue.from_value(h), acc, next => F.AttesterSlashingValue.seq_from_go(t, next), AttesterSlashingValue_complete(h, V.and_left(S.shape(h, S.erase(F.AttesterSlashingValue.schema())), S.shape(t, T.Repeat{S.erase(F.AttesterSlashingValue.schema())}), valid)), next => Node99_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.AttesterSlashingValue.schema())), S.shape(t, T.Repeat{S.erase(F.AttesterSlashingValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node99_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node99.schema())) == True{} : Bool}
  {present(F.Node99(), F.Node99.from_value(original)) == True{} : Bool}
def Node99_complete(original, valid):
  match original:
    case T.Sequence{values}: Node99_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node100_step_complete:
  for +head: Maybe<&2, F.AttestationValue()>
  for +acc: +List<F.AttestationValue()>
  for next: +List<F.AttestationValue()> -> Maybe<&2, +List<F.AttestationValue()>>
  for head_ok: {present(F.AttestationValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.AttestationValue()> -> {present(+List<F.AttestationValue()>, next(a)) == True{} : Bool}
  {present(+List<F.AttestationValue()>, F.AttestationValue.seq_step(head, acc, next)) == True{} : Bool}
def Node100_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node100_items_complete:
  for +original: T.Value
  for +acc: +List<F.AttestationValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.AttestationValue.schema())}) == True{} : Bool}
  {present(+List<F.AttestationValue()>, F.AttestationValue.seq_from_go(original, acc)) == True{} : Bool}
def Node100_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node100_step_complete(F.AttestationValue.from_value(h), acc, next => F.AttestationValue.seq_from_go(t, next), AttestationValue_complete(h, V.and_left(S.shape(h, S.erase(F.AttestationValue.schema())), S.shape(t, T.Repeat{S.erase(F.AttestationValue.schema())}), valid)), next => Node100_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.AttestationValue.schema())), S.shape(t, T.Repeat{S.erase(F.AttestationValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node100_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node100.schema())) == True{} : Bool}
  {present(F.Node100(), F.Node100.from_value(original)) == True{} : Bool}
def Node100_complete(original, valid):
  match original:
    case T.Sequence{values}: Node100_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node101_step_complete:
  for +head: Maybe<&2, F.DepositValue()>
  for +acc: +List<F.DepositValue()>
  for next: +List<F.DepositValue()> -> Maybe<&2, +List<F.DepositValue()>>
  for head_ok: {present(F.DepositValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.DepositValue()> -> {present(+List<F.DepositValue()>, next(a)) == True{} : Bool}
  {present(+List<F.DepositValue()>, F.DepositValue.seq_step(head, acc, next)) == True{} : Bool}
def Node101_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node101_items_complete:
  for +original: T.Value
  for +acc: +List<F.DepositValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.DepositValue.schema())}) == True{} : Bool}
  {present(+List<F.DepositValue()>, F.DepositValue.seq_from_go(original, acc)) == True{} : Bool}
def Node101_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node101_step_complete(F.DepositValue.from_value(h), acc, next => F.DepositValue.seq_from_go(t, next), DepositValue_complete(h, V.and_left(S.shape(h, S.erase(F.DepositValue.schema())), S.shape(t, T.Repeat{S.erase(F.DepositValue.schema())}), valid)), next => Node101_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.DepositValue.schema())), S.shape(t, T.Repeat{S.erase(F.DepositValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node101_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node101.schema())) == True{} : Bool}
  {present(F.Node101(), F.Node101.from_value(original)) == True{} : Bool}
def Node101_complete(original, valid):
  match original:
    case T.Sequence{values}: Node101_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node102_step_complete:
  for +head: Maybe<&2, F.SignedVoluntaryExitValue()>
  for +acc: +List<F.SignedVoluntaryExitValue()>
  for next: +List<F.SignedVoluntaryExitValue()> -> Maybe<&2, +List<F.SignedVoluntaryExitValue()>>
  for head_ok: {present(F.SignedVoluntaryExitValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.SignedVoluntaryExitValue()> -> {present(+List<F.SignedVoluntaryExitValue()>, next(a)) == True{} : Bool}
  {present(+List<F.SignedVoluntaryExitValue()>, F.SignedVoluntaryExitValue.seq_step(head, acc, next)) == True{} : Bool}
def Node102_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node102_items_complete:
  for +original: T.Value
  for +acc: +List<F.SignedVoluntaryExitValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.SignedVoluntaryExitValue.schema())}) == True{} : Bool}
  {present(+List<F.SignedVoluntaryExitValue()>, F.SignedVoluntaryExitValue.seq_from_go(original, acc)) == True{} : Bool}
def Node102_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node102_step_complete(F.SignedVoluntaryExitValue.from_value(h), acc, next => F.SignedVoluntaryExitValue.seq_from_go(t, next), SignedVoluntaryExitValue_complete(h, V.and_left(S.shape(h, S.erase(F.SignedVoluntaryExitValue.schema())), S.shape(t, T.Repeat{S.erase(F.SignedVoluntaryExitValue.schema())}), valid)), next => Node102_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.SignedVoluntaryExitValue.schema())), S.shape(t, T.Repeat{S.erase(F.SignedVoluntaryExitValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node102_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node102.schema())) == True{} : Bool}
  {present(F.Node102(), F.Node102.from_value(original)) == True{} : Bool}
def Node102_complete(original, valid):
  match original:
    case T.Sequence{values}: Node102_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node103_step_complete:
  for +head: Maybe<&2, F.SignedBLSToExecutionChangeValue()>
  for +acc: +List<F.SignedBLSToExecutionChangeValue()>
  for next: +List<F.SignedBLSToExecutionChangeValue()> -> Maybe<&2, +List<F.SignedBLSToExecutionChangeValue()>>
  for head_ok: {present(F.SignedBLSToExecutionChangeValue(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.SignedBLSToExecutionChangeValue()> -> {present(+List<F.SignedBLSToExecutionChangeValue()>, next(a)) == True{} : Bool}
  {present(+List<F.SignedBLSToExecutionChangeValue()>, F.SignedBLSToExecutionChangeValue.seq_step(head, acc, next)) == True{} : Bool}
def Node103_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node103_items_complete:
  for +original: T.Value
  for +acc: +List<F.SignedBLSToExecutionChangeValue()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.SignedBLSToExecutionChangeValue.schema())}) == True{} : Bool}
  {present(+List<F.SignedBLSToExecutionChangeValue()>, F.SignedBLSToExecutionChangeValue.seq_from_go(original, acc)) == True{} : Bool}
def Node103_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node103_step_complete(F.SignedBLSToExecutionChangeValue.from_value(h), acc, next => F.SignedBLSToExecutionChangeValue.seq_from_go(t, next), SignedBLSToExecutionChangeValue_complete(h, V.and_left(S.shape(h, S.erase(F.SignedBLSToExecutionChangeValue.schema())), S.shape(t, T.Repeat{S.erase(F.SignedBLSToExecutionChangeValue.schema())}), valid)), next => Node103_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.SignedBLSToExecutionChangeValue.schema())), S.shape(t, T.Repeat{S.erase(F.SignedBLSToExecutionChangeValue.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node103_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node103.schema())) == True{} : Bool}
  {present(F.Node103(), F.Node103.from_value(original)) == True{} : Bool}
def Node103_complete(original, valid):
  match original:
    case T.Sequence{values}: Node103_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node104_step_complete:
  for +head: Maybe<&2, F.Node8()>
  for +acc: +List<F.Node8()>
  for next: +List<F.Node8()> -> Maybe<&2, +List<F.Node8()>>
  for head_ok: {present(F.Node8(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node8()> -> {present(+List<F.Node8()>, next(a)) == True{} : Bool}
  {present(+List<F.Node8()>, F.Node8.seq_step(head, acc, next)) == True{} : Bool}
def Node104_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node104_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node8()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node8.schema())}) == True{} : Bool}
  {present(+List<F.Node8()>, F.Node8.seq_from_go(original, acc)) == True{} : Bool}
def Node104_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node104_step_complete(F.Node8.from_value(h), acc, next => F.Node8.seq_from_go(t, next), Node8_complete(h, V.and_left(S.shape(h, S.erase(F.Node8.schema())), S.shape(t, T.Repeat{S.erase(F.Node8.schema())}), valid)), next => Node104_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node8.schema())), S.shape(t, T.Repeat{S.erase(F.Node8.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node104_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node104.schema())) == True{} : Bool}
  {present(F.Node104(), F.Node104.from_value(original)) == True{} : Bool}
def Node104_complete(original, valid):
  match original:
    case T.Sequence{values}: Node104_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law BeaconBlockBodyValue_assemble_complete:
  for +a0: Maybe<&2, F.Node9()>
  for +a1: Maybe<&2, F.Eth1DataValue()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.Node98()>
  for +a4: Maybe<&2, F.Node99()>
  for +a5: Maybe<&2, F.Node100()>
  for +a6: Maybe<&2, F.Node101()>
  for +a7: Maybe<&2, F.Node102()>
  for +a8: Maybe<&2, F.SyncAggregateValue()>
  for +a9: Maybe<&2, F.ExecutionPayloadValue()>
  for +a10: Maybe<&2, F.Node103()>
  for +a11: Maybe<&2, F.Node104()>
  for +a12: Maybe<&2, F.ExecutionRequestsValue()>
  for p0: {present(F.Node9(), a0) == True{} : Bool}
  for p1: {present(F.Eth1DataValue(), a1) == True{} : Bool}
  for p2: {present(F.Node7(), a2) == True{} : Bool}
  for p3: {present(F.Node98(), a3) == True{} : Bool}
  for p4: {present(F.Node99(), a4) == True{} : Bool}
  for p5: {present(F.Node100(), a5) == True{} : Bool}
  for p6: {present(F.Node101(), a6) == True{} : Bool}
  for p7: {present(F.Node102(), a7) == True{} : Bool}
  for p8: {present(F.SyncAggregateValue(), a8) == True{} : Bool}
  for p9: {present(F.ExecutionPayloadValue(), a9) == True{} : Bool}
  for p10: {present(F.Node103(), a10) == True{} : Bool}
  for p11: {present(F.Node104(), a11) == True{} : Bool}
  for p12: {present(F.ExecutionRequestsValue(), a12) == True{} : Bool}
  {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12)) == True{} : Bool}
def BeaconBlockBodyValue_assemble_complete(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12):
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12}: {==}
    case None{} _ _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _ _ _ _ _ _ _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _ _ _ _ _ _ _ _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _ _ _ _ _ _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _ _ _ _ _ _: impossible(False{}, p4)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _ _ _ _ _ _: impossible(False{}, p5)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _ _ _ _ _ _: impossible(False{}, p6)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{} _ _ _ _ _: impossible(False{}, p7)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} None{} _ _ _ _: impossible(False{}, p8)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} None{} _ _ _: impossible(False{}, p9)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} None{} _ _: impossible(False{}, p10)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} None{} _: impossible(False{}, p11)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} None{}: impossible(False{}, p12)
law BeaconBlockBodyValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node9.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node98.schema()), T.Chain{S.erase(F.Node99.schema()), T.Chain{S.erase(F.Node100.schema()), T.Chain{S.erase(F.Node101.schema()), T.Chain{S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}}}}}}}}}) == True{} : Bool}
  {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{items})) == True{} : Bool}
def BeaconBlockBodyValue_fields_complete(items, valid):
  peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{items})), items, S.erase(F.Node9.schema()), T.Chain{S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node98.schema()), T.Chain{S.erase(F.Node99.schema()), T.Chain{S.erase(F.Node100.schema()), T.Chain{S.erase(F.Node101.schema()), T.Chain{S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}}}}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Eth1DataValue.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node98.schema()), T.Chain{S.erase(F.Node99.schema()), T.Chain{S.erase(F.Node100.schema()), T.Chain{S.erase(F.Node101.schema()), T.Chain{S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}}}}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node98.schema()), T.Chain{S.erase(F.Node99.schema()), T.Chain{S.erase(F.Node100.schema()), T.Chain{S.erase(F.Node101.schema()), T.Chain{S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}}}}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node98.schema()), T.Chain{S.erase(F.Node99.schema()), T.Chain{S.erase(F.Node100.schema()), T.Chain{S.erase(F.Node101.schema()), T.Chain{S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}}}}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.Node99.schema()), T.Chain{S.erase(F.Node100.schema()), T.Chain{S.erase(F.Node101.schema()), T.Chain{S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}}}}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, S.erase(F.Node100.schema()), T.Chain{S.erase(F.Node101.schema()), T.Chain{S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}}}, t4, o5 => h5 => r5 => t5 => e5 =>
              %Equal.sym(T.Value, r4, T.Items{o5, r5}, e5) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, r5}}}}}}})), r5, S.erase(F.Node101.schema()), T.Chain{S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}}, t5, o6 => h6 => r6 => t6 => e6 =>
                %Equal.sym(T.Value, r5, T.Items{o6, r6}, e6) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, _}}}}}}})) == True{} : Bool}
                peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, r6}}}}}}}})), r6, S.erase(F.Node102.schema()), T.Chain{S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}}, t6, o7 => h7 => r7 => t7 => e7 =>
                  %Equal.sym(T.Value, r6, T.Items{o7, r7}, e7) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, _}}}}}}}})) == True{} : Bool}
                  peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, r7}}}}}}}}})), r7, S.erase(F.SyncAggregateValue.schema()), T.Chain{S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}}, t7, o8 => h8 => r8 => t8 => e8 =>
                    %Equal.sym(T.Value, r7, T.Items{o8, r8}, e8) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, _}}}}}}}}})) == True{} : Bool}
                    peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, r8}}}}}}}}}})), r8, S.erase(F.ExecutionPayloadValue.schema()), T.Chain{S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}}, t8, o9 => h9 => r9 => t9 => e9 =>
                      %Equal.sym(T.Value, r8, T.Items{o9, r9}, e9) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, _}}}}}}}}}})) == True{} : Bool}
                      peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, r9}}}}}}}}}}})), r9, S.erase(F.Node103.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}}, t9, o10 => h10 => r10 => t10 => e10 =>
                        %Equal.sym(T.Value, r9, T.Items{o10, r10}, e10) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, _}}}}}}}}}}})) == True{} : Bool}
                        peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, r10}}}}}}}}}}}})), r10, S.erase(F.Node104.schema()), T.Chain{S.erase(F.ExecutionRequestsValue.schema()), T.End{}}, t10, o11 => h11 => r11 => t11 => e11 =>
                          %Equal.sym(T.Value, r10, T.Items{o11, r11}, e11) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, _}}}}}}}}}}}})) == True{} : Bool}
                          peel(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, r11}}}}}}}}}}}}})), r11, S.erase(F.ExecutionRequestsValue.schema()), T.End{}, t11, o12 => h12 => r12 => t12 => e12 =>
                            %Equal.sym(T.Value, r11, T.Items{o12, r12}, e12) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, _}}}}}}}}}}}}})) == True{} : Bool}
                            finish(present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, r12}}}}}}}}}}}}}})), r12, t12, e13 =>
                              %Equal.sym(T.Value, r12, T.EmptyItems{}, e13) : {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, _}}}}}}}}}}}}}})) == True{} : Bool}
                              BeaconBlockBodyValue_assemble_complete(F.Node9.from_value(o0), F.Eth1DataValue.from_value(o1), F.Node7.from_value(o2), F.Node98.from_value(o3), F.Node99.from_value(o4), F.Node100.from_value(o5), F.Node101.from_value(o6), F.Node102.from_value(o7), F.SyncAggregateValue.from_value(o8), F.ExecutionPayloadValue.from_value(o9), F.Node103.from_value(o10), F.Node104.from_value(o11), F.ExecutionRequestsValue.from_value(o12), Node9_complete(o0, h0), Eth1DataValue_complete(o1, h1), Node7_complete(o2, h2), Node98_complete(o3, h3), Node99_complete(o4, h4), Node100_complete(o5, h5), Node101_complete(o6, h6), Node102_complete(o7, h7), SyncAggregateValue_complete(o8, h8), ExecutionPayloadValue_complete(o9, h9), Node103_complete(o10, h10), Node104_complete(o11, h11), ExecutionRequestsValue_complete(o12, h12))))))))))))))))

law BeaconBlockBodyValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BeaconBlockBodyValue.schema())) == True{} : Bool}
  {present(F.BeaconBlockBodyValue(), F.BeaconBlockBodyValue.from_value(original)) == True{} : Bool}
def BeaconBlockBodyValue_complete(original, valid):
  match original:
    case T.Sequence{items}: BeaconBlockBodyValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law BeaconBlockValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.Node7()>
  for +a4: Maybe<&2, F.BeaconBlockBodyValue()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node3(), a1) == True{} : Bool}
  for p2: {present(F.Node7(), a2) == True{} : Bool}
  for p3: {present(F.Node7(), a3) == True{} : Bool}
  for p4: {present(F.BeaconBlockBodyValue(), a4) == True{} : Bool}
  {present(F.BeaconBlockValue(), F.BeaconBlockValue.assemble(a0, a1, a2, a3, a4)) == True{} : Bool}
def BeaconBlockValue_assemble_complete(a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: {==}
    case None{} _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: impossible(False{}, p4)
law BeaconBlockValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.BeaconBlockBodyValue.schema()), T.End{}}}}}}) == True{} : Bool}
  {present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{items})) == True{} : Bool}
def BeaconBlockValue_fields_complete(items, valid):
  peel(present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.BeaconBlockBodyValue.schema()), T.End{}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.BeaconBlockBodyValue.schema()), T.End{}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.BeaconBlockBodyValue.schema()), T.End{}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node7.schema()), T.Chain{S.erase(F.BeaconBlockBodyValue.schema()), T.End{}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.BeaconBlockBodyValue.schema()), T.End{}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            finish(present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, t4, e5 =>
              %Equal.sym(T.Value, r4, T.EmptyItems{}, e5) : {present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              BeaconBlockValue_assemble_complete(F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node7.from_value(o2), F.Node7.from_value(o3), F.BeaconBlockBodyValue.from_value(o4), Node3_complete(o0, h0), Node3_complete(o1, h1), Node7_complete(o2, h2), Node7_complete(o3, h3), BeaconBlockBodyValue_complete(o4, h4))))))))

law BeaconBlockValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BeaconBlockValue.schema())) == True{} : Bool}
  {present(F.BeaconBlockValue(), F.BeaconBlockValue.from_value(original)) == True{} : Bool}
def BeaconBlockValue_complete(original, valid):
  match original:
    case T.Sequence{items}: BeaconBlockValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law SignedBeaconBlockValue_assemble_complete:
  for +a0: Maybe<&2, F.BeaconBlockValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: {present(F.BeaconBlockValue(), a0) == True{} : Bool}
  for p1: {present(F.Node9(), a1) == True{} : Bool}
  {present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.assemble(a0, a1)) == True{} : Bool}
def SignedBeaconBlockValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law SignedBeaconBlockValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.BeaconBlockValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}}) == True{} : Bool}
  {present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.from_value(T.Sequence{items})) == True{} : Bool}
def SignedBeaconBlockValue_fields_complete(items, valid):
  peel(present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.from_value(T.Sequence{items})), items, S.erase(F.BeaconBlockValue.schema()), T.Chain{S.erase(F.Node9.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node9.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        SignedBeaconBlockValue_assemble_complete(F.BeaconBlockValue.from_value(o0), F.Node9.from_value(o1), BeaconBlockValue_complete(o0, h0), Node9_complete(o1, h1)))))

law SignedBeaconBlockValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedBeaconBlockValue.schema())) == True{} : Bool}
  {present(F.SignedBeaconBlockValue(), F.SignedBeaconBlockValue.from_value(original)) == True{} : Bool}
def SignedBeaconBlockValue_complete(original, valid):
  match original:
    case T.Sequence{items}: SignedBeaconBlockValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node107_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node107.schema())) == True{} : Bool}
  {present(F.Node107(), F.Node107.from_value(original)) == True{} : Bool}
def Node107_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node109_step_complete:
  for +head: Maybe<&2, F.Node7()>
  for +acc: +List<F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_ok: {present(F.Node7(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node7()> -> {present(+List<F.Node7()>, next(a)) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_step(head, acc, next)) == True{} : Bool}
def Node109_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node109_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node7.schema())}) == True{} : Bool}
  {present(+List<F.Node7()>, F.Node7.seq_from_go(original, acc)) == True{} : Bool}
def Node109_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node109_step_complete(F.Node7.from_value(h), acc, next => F.Node7.seq_from_go(t, next), Node7_complete(h, V.and_left(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)), next => Node109_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node7.schema())), S.shape(t, T.Repeat{S.erase(F.Node7.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node109_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node109.schema())) == True{} : Bool}
  {present(F.Node109(), F.Node109.from_value(original)) == True{} : Bool}
def Node109_complete(original, valid):
  match original:
    case T.Sequence{values}: Node109_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law BlobSidecarValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node107()>
  for +a2: Maybe<&2, F.Node8()>
  for +a3: Maybe<&2, F.Node8()>
  for +a4: Maybe<&2, F.SignedBeaconBlockHeaderValue()>
  for +a5: Maybe<&2, F.Node109()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node107(), a1) == True{} : Bool}
  for p2: {present(F.Node8(), a2) == True{} : Bool}
  for p3: {present(F.Node8(), a3) == True{} : Bool}
  for p4: {present(F.SignedBeaconBlockHeaderValue(), a4) == True{} : Bool}
  for p5: {present(F.Node109(), a5) == True{} : Bool}
  {present(F.BlobSidecarValue(), F.BlobSidecarValue.assemble(a0, a1, a2, a3, a4, a5)) == True{} : Bool}
def BlobSidecarValue_assemble_complete(a0, a1, a2, a3, a4, a5, p0, p1, p2, p3, p4, p5):
  match a0 a1 a2 a3 a4 a5:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5}: {==}
    case None{} _ _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _ _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _: impossible(False{}, p4)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{}: impossible(False{}, p5)
law BlobSidecarValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node107.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node109.schema()), T.End{}}}}}}}) == True{} : Bool}
  {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{items})) == True{} : Bool}
def BlobSidecarValue_fields_complete(items, valid):
  peel(present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node107.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node109.schema()), T.End{}}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node107.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node109.schema()), T.End{}}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node109.schema()), T.End{}}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node8.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node109.schema()), T.End{}}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node109.schema()), T.End{}}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            peel(present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, S.erase(F.Node109.schema()), T.End{}, t4, o5 => h5 => r5 => t5 => e5 =>
              %Equal.sym(T.Value, r4, T.Items{o5, r5}, e5) : {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              finish(present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, r5}}}}}}})), r5, t5, e6 =>
                %Equal.sym(T.Value, r5, T.EmptyItems{}, e6) : {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, _}}}}}}})) == True{} : Bool}
                BlobSidecarValue_assemble_complete(F.Node3.from_value(o0), F.Node107.from_value(o1), F.Node8.from_value(o2), F.Node8.from_value(o3), F.SignedBeaconBlockHeaderValue.from_value(o4), F.Node109.from_value(o5), Node3_complete(o0, h0), Node107_complete(o1, h1), Node8_complete(o2, h2), Node8_complete(o3, h3), SignedBeaconBlockHeaderValue_complete(o4, h4), Node109_complete(o5, h5)))))))))

law BlobSidecarValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BlobSidecarValue.schema())) == True{} : Bool}
  {present(F.BlobSidecarValue(), F.BlobSidecarValue.from_value(original)) == True{} : Bool}
def BlobSidecarValue_complete(original, valid):
  match original:
    case T.Sequence{items}: BlobSidecarValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node110_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node110.schema())) == True{} : Bool}
  {present(F.Node110(), F.Node110.from_value(original)) == True{} : Bool}
def Node110_complete(original, valid):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node112_step_complete:
  for +head: Maybe<&2, F.Node3()>
  for +acc: +List<F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_ok: {present(F.Node3(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node3()> -> {present(+List<F.Node3()>, next(a)) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_step(head, acc, next)) == True{} : Bool}
def Node112_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node112_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node3.schema())}) == True{} : Bool}
  {present(+List<F.Node3()>, F.Node3.seq_from_go(original, acc)) == True{} : Bool}
def Node112_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node112_step_complete(F.Node3.from_value(h), acc, next => F.Node3.seq_from_go(t, next), Node3_complete(h, V.and_left(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)), next => Node112_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node3.schema())), S.shape(t, T.Repeat{S.erase(F.Node3.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node112_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node112.schema())) == True{} : Bool}
  {present(F.Node112(), F.Node112.from_value(original)) == True{} : Bool}
def Node112_complete(original, valid):
  match original:
    case T.Sequence{values}: Node112_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law DataColumnsByRootIdentifierValue_assemble_complete:
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node112()>
  for p0: {present(F.Node7(), a0) == True{} : Bool}
  for p1: {present(F.Node112(), a1) == True{} : Bool}
  {present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.assemble(a0, a1)) == True{} : Bool}
def DataColumnsByRootIdentifierValue_assemble_complete(a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}: {==}
    case None{} _: impossible(False{}, p0)
    case Some{v0} None{}: impossible(False{}, p1)
law DataColumnsByRootIdentifierValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node112.schema()), T.End{}}}) == True{} : Bool}
  {present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.from_value(T.Sequence{items})) == True{} : Bool}
def DataColumnsByRootIdentifierValue_fields_complete(items, valid):
  peel(present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.from_value(T.Sequence{items})), items, S.erase(F.Node7.schema()), T.Chain{S.erase(F.Node112.schema()), T.End{}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node112.schema()), T.End{}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      finish(present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, t1, e2 =>
        %Equal.sym(T.Value, r1, T.EmptyItems{}, e2) : {present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        DataColumnsByRootIdentifierValue_assemble_complete(F.Node7.from_value(o0), F.Node112.from_value(o1), Node7_complete(o0, h0), Node112_complete(o1, h1)))))

law DataColumnsByRootIdentifierValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DataColumnsByRootIdentifierValue.schema())) == True{} : Bool}
  {present(F.DataColumnsByRootIdentifierValue(), F.DataColumnsByRootIdentifierValue.from_value(original)) == True{} : Bool}
def DataColumnsByRootIdentifierValue_complete(original, valid):
  match original:
    case T.Sequence{items}: DataColumnsByRootIdentifierValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law MatrixEntryValue_assemble_complete:
  for +a0: Maybe<&2, F.Node110()>
  for +a1: Maybe<&2, F.Node8()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node3()>
  for p0: {present(F.Node110(), a0) == True{} : Bool}
  for p1: {present(F.Node8(), a1) == True{} : Bool}
  for p2: {present(F.Node3(), a2) == True{} : Bool}
  for p3: {present(F.Node3(), a3) == True{} : Bool}
  {present(F.MatrixEntryValue(), F.MatrixEntryValue.assemble(a0, a1, a2, a3)) == True{} : Bool}
def MatrixEntryValue_assemble_complete(a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: {==}
    case None{} _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{}: impossible(False{}, p3)
law MatrixEntryValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node110.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}}) == True{} : Bool}
  {present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{items})) == True{} : Bool}
def MatrixEntryValue_fields_complete(items, valid):
  peel(present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{items})), items, S.erase(F.Node110.schema()), T.Chain{S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node8.schema()), T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node3.schema()), T.End{}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node3.schema()), T.End{}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          finish(present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, t3, e4 =>
            %Equal.sym(T.Value, r3, T.EmptyItems{}, e4) : {present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            MatrixEntryValue_assemble_complete(F.Node110.from_value(o0), F.Node8.from_value(o1), F.Node3.from_value(o2), F.Node3.from_value(o3), Node110_complete(o0, h0), Node8_complete(o1, h1), Node3_complete(o2, h2), Node3_complete(o3, h3)))))))

law MatrixEntryValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.MatrixEntryValue.schema())) == True{} : Bool}
  {present(F.MatrixEntryValue(), F.MatrixEntryValue.from_value(original)) == True{} : Bool}
def MatrixEntryValue_complete(original, valid):
  match original:
    case T.Sequence{items}: MatrixEntryValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node115_step_complete:
  for +head: Maybe<&2, F.Node110()>
  for +acc: +List<F.Node110()>
  for next: +List<F.Node110()> -> Maybe<&2, +List<F.Node110()>>
  for head_ok: {present(F.Node110(), head) == True{} : Bool}
  for tail_ok: @+a: +List<F.Node110()> -> {present(+List<F.Node110()>, next(a)) == True{} : Bool}
  {present(+List<F.Node110()>, F.Node110.seq_step(head, acc, next)) == True{} : Bool}
def Node115_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{}: impossible(False{}, head_ok)
    case Some{x}: tail_ok(x <> acc)

law Node115_items_complete:
  for +original: T.Value
  for +acc: +List<F.Node110()>
  for +valid: {S.shape(original, T.Repeat{S.erase(F.Node110.schema())}) == True{} : Bool}
  {present(+List<F.Node110()>, F.Node110.seq_from_go(original, acc)) == True{} : Bool}
def Node115_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{}: {==}
    case T.Items{h, t}: Node115_step_complete(F.Node110.from_value(h), acc, next => F.Node110.seq_from_go(t, next), Node110_complete(h, V.and_left(S.shape(h, S.erase(F.Node110.schema())), S.shape(t, T.Repeat{S.erase(F.Node110.schema())}), valid)), next => Node115_items_complete(t, next, V.and_right(S.shape(h, S.erase(F.Node110.schema())), S.shape(t, T.Repeat{S.erase(F.Node110.schema())}), valid)))
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Sequence{bad0}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law Node115_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Node115.schema())) == True{} : Bool}
  {present(F.Node115(), F.Node115.from_value(original)) == True{} : Bool}
def Node115_complete(original, valid):
  match original:
    case T.Sequence{values}: Node115_items_complete(values, [], valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law DataColumnSidecarValue_assemble_complete:
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node115()>
  for +a2: Maybe<&2, F.Node104()>
  for +a3: Maybe<&2, F.Node104()>
  for +a4: Maybe<&2, F.SignedBeaconBlockHeaderValue()>
  for +a5: Maybe<&2, F.Node90()>
  for p0: {present(F.Node3(), a0) == True{} : Bool}
  for p1: {present(F.Node115(), a1) == True{} : Bool}
  for p2: {present(F.Node104(), a2) == True{} : Bool}
  for p3: {present(F.Node104(), a3) == True{} : Bool}
  for p4: {present(F.SignedBeaconBlockHeaderValue(), a4) == True{} : Bool}
  for p5: {present(F.Node90(), a5) == True{} : Bool}
  {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.assemble(a0, a1, a2, a3, a4, a5)) == True{} : Bool}
def DataColumnSidecarValue_assemble_complete(a0, a1, a2, a3, a4, a5, p0, p1, p2, p3, p4, p5):
  match a0 a1 a2 a3 a4 a5:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5}: {==}
    case None{} _ _ _ _ _: impossible(False{}, p0)
    case Some{v0} None{} _ _ _ _: impossible(False{}, p1)
    case Some{v0} Some{v1} None{} _ _ _: impossible(False{}, p2)
    case Some{v0} Some{v1} Some{v2} None{} _ _: impossible(False{}, p3)
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _: impossible(False{}, p4)
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{}: impossible(False{}, p5)
law DataColumnSidecarValue_fields_complete:
  for +items: T.Value
  for +valid: {S.shape(items, T.Chain{S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node115.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}}}}}}) == True{} : Bool}
  {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{items})) == True{} : Bool}
def DataColumnSidecarValue_fields_complete(items, valid):
  peel(present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{items})), items, S.erase(F.Node3.schema()), T.Chain{S.erase(F.Node115.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}}}}}, valid, o0 => h0 => r0 => t0 => e0 =>
    %Equal.sym(T.Value, items, T.Items{o0, r0}, e0) : {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{_})) == True{} : Bool}
    peel(present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, r0}})), r0, S.erase(F.Node115.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}}}}, t0, o1 => h1 => r1 => t1 => e1 =>
      %Equal.sym(T.Value, r0, T.Items{o1, r1}, e1) : {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, _}})) == True{} : Bool}
      peel(present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, r1}}})), r1, S.erase(F.Node104.schema()), T.Chain{S.erase(F.Node104.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}}}, t1, o2 => h2 => r2 => t2 => e2 =>
        %Equal.sym(T.Value, r1, T.Items{o2, r2}, e2) : {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, _}}})) == True{} : Bool}
        peel(present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, r2}}}})), r2, S.erase(F.Node104.schema()), T.Chain{S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}}, t2, o3 => h3 => r3 => t3 => e3 =>
          %Equal.sym(T.Value, r2, T.Items{o3, r3}, e3) : {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, _}}}})) == True{} : Bool}
          peel(present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, r3}}}}})), r3, S.erase(F.SignedBeaconBlockHeaderValue.schema()), T.Chain{S.erase(F.Node90.schema()), T.End{}}, t3, o4 => h4 => r4 => t4 => e4 =>
            %Equal.sym(T.Value, r3, T.Items{o4, r4}, e4) : {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, _}}}}})) == True{} : Bool}
            peel(present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, r4}}}}}})), r4, S.erase(F.Node90.schema()), T.End{}, t4, o5 => h5 => r5 => t5 => e5 =>
              %Equal.sym(T.Value, r4, T.Items{o5, r5}, e5) : {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, _}}}}}})) == True{} : Bool}
              finish(present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, r5}}}}}}})), r5, t5, e6 =>
                %Equal.sym(T.Value, r5, T.EmptyItems{}, e6) : {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, _}}}}}}})) == True{} : Bool}
                DataColumnSidecarValue_assemble_complete(F.Node3.from_value(o0), F.Node115.from_value(o1), F.Node104.from_value(o2), F.Node104.from_value(o3), F.SignedBeaconBlockHeaderValue.from_value(o4), F.Node90.from_value(o5), Node3_complete(o0, h0), Node115_complete(o1, h1), Node104_complete(o2, h2), Node104_complete(o3, h3), SignedBeaconBlockHeaderValue_complete(o4, h4), Node90_complete(o5, h5)))))))))

law DataColumnSidecarValue_complete:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DataColumnSidecarValue.schema())) == True{} : Bool}
  {present(F.DataColumnSidecarValue(), F.DataColumnSidecarValue.from_value(original)) == True{} : Bool}
def DataColumnSidecarValue_complete(original, valid):
  match original:
    case T.Sequence{items}: DataColumnSidecarValue_fields_complete(items, valid)
    case T.BooleanValue{bad0}: impossible(False{}, valid)
    case T.UnsignedValue{bad0}: impossible(False{}, valid)
    case T.BytesValue{bad0}: impossible(False{}, valid)
    case T.BitsValue{bad0}: impossible(False{}, valid)
    case T.Items{bad0, bad1}: impossible(False{}, valid)
    case T.EmptyItems{}: impossible(False{}, valid)
    case T.Selected{bad0, bad1}: impossible(False{}, valid)
    case T.NullValue{}: impossible(False{}, valid)

law boolean_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.boolean.schema())) == True{} : Bool}
  {present(F.boolean(), F.boolean.from_ssz(original)) == True{} : Bool}
def boolean_conversion_complete_erased(original, valid): Node0_complete(original, valid)

law uint8_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.uint8.schema())) == True{} : Bool}
  {present(F.uint8(), F.uint8.from_ssz(original)) == True{} : Bool}
def uint8_conversion_complete_erased(original, valid): Node1_complete(original, valid)

law uint32_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.uint32.schema())) == True{} : Bool}
  {present(F.uint32(), F.uint32.from_ssz(original)) == True{} : Bool}
def uint32_conversion_complete_erased(original, valid): Node2_complete(original, valid)

law uint64_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.uint64.schema())) == True{} : Bool}
  {present(F.uint64(), F.uint64.from_ssz(original)) == True{} : Bool}
def uint64_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law uint256_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.uint256.schema())) == True{} : Bool}
  {present(F.uint256(), F.uint256.from_ssz(original)) == True{} : Bool}
def uint256_conversion_complete_erased(original, valid): Node4_complete(original, valid)

law Bytes1_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Bytes1.schema())) == True{} : Bool}
  {present(F.Bytes1(), F.Bytes1.from_ssz(original)) == True{} : Bool}
def Bytes1_conversion_complete_erased(original, valid): Node5_complete(original, valid)

law Bytes4_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Bytes4.schema())) == True{} : Bool}
  {present(F.Bytes4(), F.Bytes4.from_ssz(original)) == True{} : Bool}
def Bytes4_conversion_complete_erased(original, valid): Node6_complete(original, valid)

law Bytes32_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Bytes32.schema())) == True{} : Bool}
  {present(F.Bytes32(), F.Bytes32.from_ssz(original)) == True{} : Bool}
def Bytes32_conversion_complete_erased(original, valid): Node7_complete(original, valid)

law Bytes48_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Bytes48.schema())) == True{} : Bool}
  {present(F.Bytes48(), F.Bytes48.from_ssz(original)) == True{} : Bool}
def Bytes48_conversion_complete_erased(original, valid): Node8_complete(original, valid)

law Bytes96_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Bytes96.schema())) == True{} : Bool}
  {present(F.Bytes96(), F.Bytes96.from_ssz(original)) == True{} : Bool}
def Bytes96_conversion_complete_erased(original, valid): Node9_complete(original, valid)

law Bytes8_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Bytes8.schema())) == True{} : Bool}
  {present(F.Bytes8(), F.Bytes8.from_ssz(original)) == True{} : Bool}
def Bytes8_conversion_complete_erased(original, valid): Node10_complete(original, valid)

law Bytes20_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Bytes20.schema())) == True{} : Bool}
  {present(F.Bytes20(), F.Bytes20.from_ssz(original)) == True{} : Bool}
def Bytes20_conversion_complete_erased(original, valid): Node11_complete(original, valid)

law Slot_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Slot.schema())) == True{} : Bool}
  {present(F.Slot(), F.Slot.from_ssz(original)) == True{} : Bool}
def Slot_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law Epoch_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Epoch.schema())) == True{} : Bool}
  {present(F.Epoch(), F.Epoch.from_ssz(original)) == True{} : Bool}
def Epoch_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law Gwei_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Gwei.schema())) == True{} : Bool}
  {present(F.Gwei(), F.Gwei.from_ssz(original)) == True{} : Bool}
def Gwei_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law Hash32_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Hash32.schema())) == True{} : Bool}
  {present(F.Hash32(), F.Hash32.from_ssz(original)) == True{} : Bool}
def Hash32_conversion_complete_erased(original, valid): Node7_complete(original, valid)

law Version_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Version.schema())) == True{} : Bool}
  {present(F.Version(), F.Version.from_ssz(original)) == True{} : Bool}
def Version_conversion_complete_erased(original, valid): Node6_complete(original, valid)

law DomainType_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DomainType.schema())) == True{} : Bool}
  {present(F.DomainType(), F.DomainType.from_ssz(original)) == True{} : Bool}
def DomainType_conversion_complete_erased(original, valid): Node6_complete(original, valid)

law BLSSignature_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BLSSignature.schema())) == True{} : Bool}
  {present(F.BLSSignature(), F.BLSSignature.from_ssz(original)) == True{} : Bool}
def BLSSignature_conversion_complete_erased(original, valid): Node9_complete(original, valid)

law FinalityBranch_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.FinalityBranch.schema())) == True{} : Bool}
  {present(F.FinalityBranch(), F.FinalityBranch.from_ssz(original)) == True{} : Bool}
def FinalityBranch_conversion_complete_erased(original, valid): Node12_complete(original, valid)

law VersionedHash_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.VersionedHash.schema())) == True{} : Bool}
  {present(F.VersionedHash(), F.VersionedHash.from_ssz(original)) == True{} : Bool}
def VersionedHash_conversion_complete_erased(original, valid): Node7_complete(original, valid)

law G1Point_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.G1Point.schema())) == True{} : Bool}
  {present(F.G1Point(), F.G1Point.from_ssz(original)) == True{} : Bool}
def G1Point_conversion_complete_erased(original, valid): Node8_complete(original, valid)

law G2Point_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.G2Point.schema())) == True{} : Bool}
  {present(F.G2Point(), F.G2Point.from_ssz(original)) == True{} : Bool}
def G2Point_conversion_complete_erased(original, valid): Node9_complete(original, valid)

law Fork_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Fork.schema())) == True{} : Bool}
  {present(F.Fork, F.Fork.from_ssz(original)) == True{} : Bool}
def Fork_conversion_complete_erased(original, valid): ForkValue_complete(original, valid)

law SyncAggregate_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncAggregate.schema())) == True{} : Bool}
  {present(F.SyncAggregate, F.SyncAggregate.from_ssz(original)) == True{} : Bool}
def SyncAggregate_conversion_complete_erased(original, valid): SyncAggregateValue_complete(original, valid)

law SyncAggregatorSelectionData_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncAggregatorSelectionData.schema())) == True{} : Bool}
  {present(F.SyncAggregatorSelectionData, F.SyncAggregatorSelectionData.from_ssz(original)) == True{} : Bool}
def SyncAggregatorSelectionData_conversion_complete_erased(original, valid): SyncAggregatorSelectionDataValue_complete(original, valid)

law PowBlock_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PowBlock.schema())) == True{} : Bool}
  {present(F.PowBlock, F.PowBlock.from_ssz(original)) == True{} : Bool}
def PowBlock_conversion_complete_erased(original, valid): PowBlockValue_complete(original, valid)

law CommitteeIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.CommitteeIndex.schema())) == True{} : Bool}
  {present(F.CommitteeIndex(), F.CommitteeIndex.from_ssz(original)) == True{} : Bool}
def CommitteeIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law ValidatorIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ValidatorIndex.schema())) == True{} : Bool}
  {present(F.ValidatorIndex(), F.ValidatorIndex.from_ssz(original)) == True{} : Bool}
def ValidatorIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law PendingConsolidation_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PendingConsolidation.schema())) == True{} : Bool}
  {present(F.PendingConsolidation, F.PendingConsolidation.from_ssz(original)) == True{} : Bool}
def PendingConsolidation_conversion_complete_erased(original, valid): PendingConsolidationValue_complete(original, valid)

law PendingPartialWithdrawal_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PendingPartialWithdrawal.schema())) == True{} : Bool}
  {present(F.PendingPartialWithdrawal, F.PendingPartialWithdrawal.from_ssz(original)) == True{} : Bool}
def PendingPartialWithdrawal_conversion_complete_erased(original, valid): PendingPartialWithdrawalValue_complete(original, valid)

law VoluntaryExit_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.VoluntaryExit.schema())) == True{} : Bool}
  {present(F.VoluntaryExit, F.VoluntaryExit.from_ssz(original)) == True{} : Bool}
def VoluntaryExit_conversion_complete_erased(original, valid): VoluntaryExitValue_complete(original, valid)

law SignedVoluntaryExit_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedVoluntaryExit.schema())) == True{} : Bool}
  {present(F.SignedVoluntaryExit, F.SignedVoluntaryExit.from_ssz(original)) == True{} : Bool}
def SignedVoluntaryExit_conversion_complete_erased(original, valid): SignedVoluntaryExitValue_complete(original, valid)

law Root_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Root.schema())) == True{} : Bool}
  {present(F.Root(), F.Root.from_ssz(original)) == True{} : Bool}
def Root_conversion_complete_erased(original, valid): Node7_complete(original, valid)

law HistoricalSummary_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.HistoricalSummary.schema())) == True{} : Bool}
  {present(F.HistoricalSummary, F.HistoricalSummary.from_ssz(original)) == True{} : Bool}
def HistoricalSummary_conversion_complete_erased(original, valid): HistoricalSummaryValue_complete(original, valid)

law SyncCommitteeContribution_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncCommitteeContribution.schema())) == True{} : Bool}
  {present(F.SyncCommitteeContribution, F.SyncCommitteeContribution.from_ssz(original)) == True{} : Bool}
def SyncCommitteeContribution_conversion_complete_erased(original, valid): SyncCommitteeContributionValue_complete(original, valid)

law ContributionAndProof_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ContributionAndProof.schema())) == True{} : Bool}
  {present(F.ContributionAndProof, F.ContributionAndProof.from_ssz(original)) == True{} : Bool}
def ContributionAndProof_conversion_complete_erased(original, valid): ContributionAndProofValue_complete(original, valid)

law SignedContributionAndProof_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedContributionAndProof.schema())) == True{} : Bool}
  {present(F.SignedContributionAndProof, F.SignedContributionAndProof.from_ssz(original)) == True{} : Bool}
def SignedContributionAndProof_conversion_complete_erased(original, valid): SignedContributionAndProofValue_complete(original, valid)

law SyncCommitteeMessage_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncCommitteeMessage.schema())) == True{} : Bool}
  {present(F.SyncCommitteeMessage, F.SyncCommitteeMessage.from_ssz(original)) == True{} : Bool}
def SyncCommitteeMessage_conversion_complete_erased(original, valid): SyncCommitteeMessageValue_complete(original, valid)

law Eth1Block_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Eth1Block.schema())) == True{} : Bool}
  {present(F.Eth1Block, F.Eth1Block.from_ssz(original)) == True{} : Bool}
def Eth1Block_conversion_complete_erased(original, valid): Eth1BlockValue_complete(original, valid)

law BeaconBlockHeader_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BeaconBlockHeader.schema())) == True{} : Bool}
  {present(F.BeaconBlockHeader, F.BeaconBlockHeader.from_ssz(original)) == True{} : Bool}
def BeaconBlockHeader_conversion_complete_erased(original, valid): BeaconBlockHeaderValue_complete(original, valid)

law SignedBeaconBlockHeader_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedBeaconBlockHeader.schema())) == True{} : Bool}
  {present(F.SignedBeaconBlockHeader, F.SignedBeaconBlockHeader.from_ssz(original)) == True{} : Bool}
def SignedBeaconBlockHeader_conversion_complete_erased(original, valid): SignedBeaconBlockHeaderValue_complete(original, valid)

law ProposerSlashing_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ProposerSlashing.schema())) == True{} : Bool}
  {present(F.ProposerSlashing, F.ProposerSlashing.from_ssz(original)) == True{} : Bool}
def ProposerSlashing_conversion_complete_erased(original, valid): ProposerSlashingValue_complete(original, valid)

law HistoricalBatch_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.HistoricalBatch.schema())) == True{} : Bool}
  {present(F.HistoricalBatch, F.HistoricalBatch.from_ssz(original)) == True{} : Bool}
def HistoricalBatch_conversion_complete_erased(original, valid): HistoricalBatchValue_complete(original, valid)

law Eth1Data_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Eth1Data.schema())) == True{} : Bool}
  {present(F.Eth1Data, F.Eth1Data.from_ssz(original)) == True{} : Bool}
def Eth1Data_conversion_complete_erased(original, valid): Eth1DataValue_complete(original, valid)

law Checkpoint_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Checkpoint.schema())) == True{} : Bool}
  {present(F.Checkpoint, F.Checkpoint.from_ssz(original)) == True{} : Bool}
def Checkpoint_conversion_complete_erased(original, valid): CheckpointValue_complete(original, valid)

law AttestationData_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.AttestationData.schema())) == True{} : Bool}
  {present(F.AttestationData, F.AttestationData.from_ssz(original)) == True{} : Bool}
def AttestationData_conversion_complete_erased(original, valid): AttestationDataValue_complete(original, valid)

law SingleAttestation_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SingleAttestation.schema())) == True{} : Bool}
  {present(F.SingleAttestation, F.SingleAttestation.from_ssz(original)) == True{} : Bool}
def SingleAttestation_conversion_complete_erased(original, valid): SingleAttestationValue_complete(original, valid)

law Attestation_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Attestation.schema())) == True{} : Bool}
  {present(F.Attestation, F.Attestation.from_ssz(original)) == True{} : Bool}
def Attestation_conversion_complete_erased(original, valid): AttestationValue_complete(original, valid)

law AggregateAndProof_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.AggregateAndProof.schema())) == True{} : Bool}
  {present(F.AggregateAndProof, F.AggregateAndProof.from_ssz(original)) == True{} : Bool}
def AggregateAndProof_conversion_complete_erased(original, valid): AggregateAndProofValue_complete(original, valid)

law SignedAggregateAndProof_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedAggregateAndProof.schema())) == True{} : Bool}
  {present(F.SignedAggregateAndProof, F.SignedAggregateAndProof.from_ssz(original)) == True{} : Bool}
def SignedAggregateAndProof_conversion_complete_erased(original, valid): SignedAggregateAndProofValue_complete(original, valid)

law PendingAttestation_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PendingAttestation.schema())) == True{} : Bool}
  {present(F.PendingAttestation, F.PendingAttestation.from_ssz(original)) == True{} : Bool}
def PendingAttestation_conversion_complete_erased(original, valid): PendingAttestationValue_complete(original, valid)

law IndexedAttestation_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.IndexedAttestation.schema())) == True{} : Bool}
  {present(F.IndexedAttestation, F.IndexedAttestation.from_ssz(original)) == True{} : Bool}
def IndexedAttestation_conversion_complete_erased(original, valid): IndexedAttestationValue_complete(original, valid)

law AttesterSlashing_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.AttesterSlashing.schema())) == True{} : Bool}
  {present(F.AttesterSlashing, F.AttesterSlashing.from_ssz(original)) == True{} : Bool}
def AttesterSlashing_conversion_complete_erased(original, valid): AttesterSlashingValue_complete(original, valid)

law ForkData_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ForkData.schema())) == True{} : Bool}
  {present(F.ForkData, F.ForkData.from_ssz(original)) == True{} : Bool}
def ForkData_conversion_complete_erased(original, valid): ForkDataValue_complete(original, valid)

law ForkDigest_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ForkDigest.schema())) == True{} : Bool}
  {present(F.ForkDigest(), F.ForkDigest.from_ssz(original)) == True{} : Bool}
def ForkDigest_conversion_complete_erased(original, valid): Node6_complete(original, valid)

law Domain_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Domain.schema())) == True{} : Bool}
  {present(F.Domain(), F.Domain.from_ssz(original)) == True{} : Bool}
def Domain_conversion_complete_erased(original, valid): Node7_complete(original, valid)

law SigningData_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SigningData.schema())) == True{} : Bool}
  {present(F.SigningData, F.SigningData.from_ssz(original)) == True{} : Bool}
def SigningData_conversion_complete_erased(original, valid): SigningDataValue_complete(original, valid)

law BLSPubkey_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BLSPubkey.schema())) == True{} : Bool}
  {present(F.BLSPubkey(), F.BLSPubkey.from_ssz(original)) == True{} : Bool}
def BLSPubkey_conversion_complete_erased(original, valid): Node8_complete(original, valid)

law DepositRequest_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DepositRequest.schema())) == True{} : Bool}
  {present(F.DepositRequest, F.DepositRequest.from_ssz(original)) == True{} : Bool}
def DepositRequest_conversion_complete_erased(original, valid): DepositRequestValue_complete(original, valid)

law PendingDeposit_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PendingDeposit.schema())) == True{} : Bool}
  {present(F.PendingDeposit, F.PendingDeposit.from_ssz(original)) == True{} : Bool}
def PendingDeposit_conversion_complete_erased(original, valid): PendingDepositValue_complete(original, valid)

law SyncCommittee_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SyncCommittee.schema())) == True{} : Bool}
  {present(F.SyncCommittee, F.SyncCommittee.from_ssz(original)) == True{} : Bool}
def SyncCommittee_conversion_complete_erased(original, valid): SyncCommitteeValue_complete(original, valid)

law DepositData_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DepositData.schema())) == True{} : Bool}
  {present(F.DepositData, F.DepositData.from_ssz(original)) == True{} : Bool}
def DepositData_conversion_complete_erased(original, valid): DepositDataValue_complete(original, valid)

law Deposit_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Deposit.schema())) == True{} : Bool}
  {present(F.Deposit, F.Deposit.from_ssz(original)) == True{} : Bool}
def Deposit_conversion_complete_erased(original, valid): DepositValue_complete(original, valid)

law DepositMessage_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DepositMessage.schema())) == True{} : Bool}
  {present(F.DepositMessage, F.DepositMessage.from_ssz(original)) == True{} : Bool}
def DepositMessage_conversion_complete_erased(original, valid): DepositMessageValue_complete(original, valid)

law Validator_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Validator.schema())) == True{} : Bool}
  {present(F.Validator, F.Validator.from_ssz(original)) == True{} : Bool}
def Validator_conversion_complete_erased(original, valid): ValidatorValue_complete(original, valid)

law NodeID_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.NodeID.schema())) == True{} : Bool}
  {present(F.NodeID(), F.NodeID.from_ssz(original)) == True{} : Bool}
def NodeID_conversion_complete_erased(original, valid): Node4_complete(original, valid)

law SubnetID_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SubnetID.schema())) == True{} : Bool}
  {present(F.SubnetID(), F.SubnetID.from_ssz(original)) == True{} : Bool}
def SubnetID_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law Ether_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Ether.schema())) == True{} : Bool}
  {present(F.Ether(), F.Ether.from_ssz(original)) == True{} : Bool}
def Ether_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law ParticipationFlags_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ParticipationFlags.schema())) == True{} : Bool}
  {present(F.ParticipationFlags(), F.ParticipationFlags.from_ssz(original)) == True{} : Bool}
def ParticipationFlags_conversion_complete_erased(original, valid): Node1_complete(original, valid)

law CurrentSyncCommitteeBranch_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.CurrentSyncCommitteeBranch.schema())) == True{} : Bool}
  {present(F.CurrentSyncCommitteeBranch(), F.CurrentSyncCommitteeBranch.from_ssz(original)) == True{} : Bool}
def CurrentSyncCommitteeBranch_conversion_complete_erased(original, valid): Node59_complete(original, valid)

law NextSyncCommitteeBranch_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.NextSyncCommitteeBranch.schema())) == True{} : Bool}
  {present(F.NextSyncCommitteeBranch(), F.NextSyncCommitteeBranch.from_ssz(original)) == True{} : Bool}
def NextSyncCommitteeBranch_conversion_complete_erased(original, valid): Node59_complete(original, valid)

law Transaction_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Transaction.schema())) == True{} : Bool}
  {present(F.Transaction(), F.Transaction.from_ssz(original)) == True{} : Bool}
def Transaction_conversion_complete_erased(original, valid): Node60_complete(original, valid)

law ExecutionAddress_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ExecutionAddress.schema())) == True{} : Bool}
  {present(F.ExecutionAddress(), F.ExecutionAddress.from_ssz(original)) == True{} : Bool}
def ExecutionAddress_conversion_complete_erased(original, valid): Node11_complete(original, valid)

law ConsolidationRequest_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ConsolidationRequest.schema())) == True{} : Bool}
  {present(F.ConsolidationRequest, F.ConsolidationRequest.from_ssz(original)) == True{} : Bool}
def ConsolidationRequest_conversion_complete_erased(original, valid): ConsolidationRequestValue_complete(original, valid)

law WithdrawalRequest_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.WithdrawalRequest.schema())) == True{} : Bool}
  {present(F.WithdrawalRequest, F.WithdrawalRequest.from_ssz(original)) == True{} : Bool}
def WithdrawalRequest_conversion_complete_erased(original, valid): WithdrawalRequestValue_complete(original, valid)

law ExecutionRequests_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ExecutionRequests.schema())) == True{} : Bool}
  {present(F.ExecutionRequests, F.ExecutionRequests.from_ssz(original)) == True{} : Bool}
def ExecutionRequests_conversion_complete_erased(original, valid): ExecutionRequestsValue_complete(original, valid)

law BLSToExecutionChange_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BLSToExecutionChange.schema())) == True{} : Bool}
  {present(F.BLSToExecutionChange, F.BLSToExecutionChange.from_ssz(original)) == True{} : Bool}
def BLSToExecutionChange_conversion_complete_erased(original, valid): BLSToExecutionChangeValue_complete(original, valid)

law SignedBLSToExecutionChange_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedBLSToExecutionChange.schema())) == True{} : Bool}
  {present(F.SignedBLSToExecutionChange, F.SignedBLSToExecutionChange.from_ssz(original)) == True{} : Bool}
def SignedBLSToExecutionChange_conversion_complete_erased(original, valid): SignedBLSToExecutionChangeValue_complete(original, valid)

law ExecutionPayloadHeader_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ExecutionPayloadHeader.schema())) == True{} : Bool}
  {present(F.ExecutionPayloadHeader, F.ExecutionPayloadHeader.from_ssz(original)) == True{} : Bool}
def ExecutionPayloadHeader_conversion_complete_erased(original, valid): ExecutionPayloadHeaderValue_complete(original, valid)

law PayloadId_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.PayloadId.schema())) == True{} : Bool}
  {present(F.PayloadId(), F.PayloadId.from_ssz(original)) == True{} : Bool}
def PayloadId_conversion_complete_erased(original, valid): Node10_complete(original, valid)

law WithdrawalIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.WithdrawalIndex.schema())) == True{} : Bool}
  {present(F.WithdrawalIndex(), F.WithdrawalIndex.from_ssz(original)) == True{} : Bool}
def WithdrawalIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law Withdrawal_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Withdrawal.schema())) == True{} : Bool}
  {present(F.Withdrawal, F.Withdrawal.from_ssz(original)) == True{} : Bool}
def Withdrawal_conversion_complete_erased(original, valid): WithdrawalValue_complete(original, valid)

law ExecutionPayload_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ExecutionPayload.schema())) == True{} : Bool}
  {present(F.ExecutionPayload, F.ExecutionPayload.from_ssz(original)) == True{} : Bool}
def ExecutionPayload_conversion_complete_erased(original, valid): ExecutionPayloadValue_complete(original, valid)

law BeaconState_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BeaconState.schema())) == True{} : Bool}
  {present(F.BeaconState, F.BeaconState.from_ssz(original)) == True{} : Bool}
def BeaconState_conversion_complete_erased(original, valid): BeaconStateValue_complete(original, valid)

law ExecutionBranch_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ExecutionBranch.schema())) == True{} : Bool}
  {present(F.ExecutionBranch(), F.ExecutionBranch.from_ssz(original)) == True{} : Bool}
def ExecutionBranch_conversion_complete_erased(original, valid): Node90_complete(original, valid)

law LightClientHeader_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientHeader.schema())) == True{} : Bool}
  {present(F.LightClientHeader, F.LightClientHeader.from_ssz(original)) == True{} : Bool}
def LightClientHeader_conversion_complete_erased(original, valid): LightClientHeaderValue_complete(original, valid)

law LightClientOptimisticUpdate_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientOptimisticUpdate.schema())) == True{} : Bool}
  {present(F.LightClientOptimisticUpdate, F.LightClientOptimisticUpdate.from_ssz(original)) == True{} : Bool}
def LightClientOptimisticUpdate_conversion_complete_erased(original, valid): LightClientOptimisticUpdateValue_complete(original, valid)

law LightClientFinalityUpdate_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientFinalityUpdate.schema())) == True{} : Bool}
  {present(F.LightClientFinalityUpdate, F.LightClientFinalityUpdate.from_ssz(original)) == True{} : Bool}
def LightClientFinalityUpdate_conversion_complete_erased(original, valid): LightClientFinalityUpdateValue_complete(original, valid)

law LightClientUpdate_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientUpdate.schema())) == True{} : Bool}
  {present(F.LightClientUpdate, F.LightClientUpdate.from_ssz(original)) == True{} : Bool}
def LightClientUpdate_conversion_complete_erased(original, valid): LightClientUpdateValue_complete(original, valid)

law LightClientBootstrap_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.LightClientBootstrap.schema())) == True{} : Bool}
  {present(F.LightClientBootstrap, F.LightClientBootstrap.from_ssz(original)) == True{} : Bool}
def LightClientBootstrap_conversion_complete_erased(original, valid): LightClientBootstrapValue_complete(original, valid)

law BlobIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BlobIndex.schema())) == True{} : Bool}
  {present(F.BlobIndex(), F.BlobIndex.from_ssz(original)) == True{} : Bool}
def BlobIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law BlobIdentifier_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BlobIdentifier.schema())) == True{} : Bool}
  {present(F.BlobIdentifier, F.BlobIdentifier.from_ssz(original)) == True{} : Bool}
def BlobIdentifier_conversion_complete_erased(original, valid): BlobIdentifierValue_complete(original, valid)

law KZGCommitment_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.KZGCommitment.schema())) == True{} : Bool}
  {present(F.KZGCommitment(), F.KZGCommitment.from_ssz(original)) == True{} : Bool}
def KZGCommitment_conversion_complete_erased(original, valid): Node8_complete(original, valid)

law BeaconBlockBody_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BeaconBlockBody.schema())) == True{} : Bool}
  {present(F.BeaconBlockBody, F.BeaconBlockBody.from_ssz(original)) == True{} : Bool}
def BeaconBlockBody_conversion_complete_erased(original, valid): BeaconBlockBodyValue_complete(original, valid)

law BeaconBlock_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BeaconBlock.schema())) == True{} : Bool}
  {present(F.BeaconBlock, F.BeaconBlock.from_ssz(original)) == True{} : Bool}
def BeaconBlock_conversion_complete_erased(original, valid): BeaconBlockValue_complete(original, valid)

law SignedBeaconBlock_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.SignedBeaconBlock.schema())) == True{} : Bool}
  {present(F.SignedBeaconBlock, F.SignedBeaconBlock.from_ssz(original)) == True{} : Bool}
def SignedBeaconBlock_conversion_complete_erased(original, valid): SignedBeaconBlockValue_complete(original, valid)

law KZGProof_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.KZGProof.schema())) == True{} : Bool}
  {present(F.KZGProof(), F.KZGProof.from_ssz(original)) == True{} : Bool}
def KZGProof_conversion_complete_erased(original, valid): Node8_complete(original, valid)

law Blob_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Blob.schema())) == True{} : Bool}
  {present(F.Blob(), F.Blob.from_ssz(original)) == True{} : Bool}
def Blob_conversion_complete_erased(original, valid): Node107_complete(original, valid)

law BlobSidecar_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.BlobSidecar.schema())) == True{} : Bool}
  {present(F.BlobSidecar, F.BlobSidecar.from_ssz(original)) == True{} : Bool}
def BlobSidecar_conversion_complete_erased(original, valid): BlobSidecarValue_complete(original, valid)

law Cell_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.Cell.schema())) == True{} : Bool}
  {present(F.Cell(), F.Cell.from_ssz(original)) == True{} : Bool}
def Cell_conversion_complete_erased(original, valid): Node110_complete(original, valid)

law CellIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.CellIndex.schema())) == True{} : Bool}
  {present(F.CellIndex(), F.CellIndex.from_ssz(original)) == True{} : Bool}
def CellIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law CommitmentIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.CommitmentIndex.schema())) == True{} : Bool}
  {present(F.CommitmentIndex(), F.CommitmentIndex.from_ssz(original)) == True{} : Bool}
def CommitmentIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law RowIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.RowIndex.schema())) == True{} : Bool}
  {present(F.RowIndex(), F.RowIndex.from_ssz(original)) == True{} : Bool}
def RowIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law ColumnIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.ColumnIndex.schema())) == True{} : Bool}
  {present(F.ColumnIndex(), F.ColumnIndex.from_ssz(original)) == True{} : Bool}
def ColumnIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

law DataColumnsByRootIdentifier_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DataColumnsByRootIdentifier.schema())) == True{} : Bool}
  {present(F.DataColumnsByRootIdentifier, F.DataColumnsByRootIdentifier.from_ssz(original)) == True{} : Bool}
def DataColumnsByRootIdentifier_conversion_complete_erased(original, valid): DataColumnsByRootIdentifierValue_complete(original, valid)

law MatrixEntry_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.MatrixEntry.schema())) == True{} : Bool}
  {present(F.MatrixEntry, F.MatrixEntry.from_ssz(original)) == True{} : Bool}
def MatrixEntry_conversion_complete_erased(original, valid): MatrixEntryValue_complete(original, valid)

law DataColumnSidecar_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.DataColumnSidecar.schema())) == True{} : Bool}
  {present(F.DataColumnSidecar, F.DataColumnSidecar.from_ssz(original)) == True{} : Bool}
def DataColumnSidecar_conversion_complete_erased(original, valid): DataColumnSidecarValue_complete(original, valid)

law CustodyIndex_conversion_complete_erased:
  for +original: T.Value
  for +valid: {S.shape(original, S.erase(F.CustodyIndex.schema())) == True{} : Bool}
  {present(F.CustodyIndex(), F.CustodyIndex.from_ssz(original)) == True{} : Bool}
def CustodyIndex_conversion_complete_erased(original, valid): Node3_complete(original, valid)

