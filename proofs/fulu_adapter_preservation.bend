import Base
import ../types/fulu.bend as F
import ../types/schema.bend as T
import ./lists.bend as Lists

def Node0_preserves(original: T.Value, result: Maybe<&2, F.Node0()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node0.to_value(value) == original : T.Value}

law Node0_sound:
  for +original: T.Value
  Node0_preserves(original, F.Node0.from_value(original))
def Node0_sound(original):
  match original:
    case T.BooleanValue{value}: {==}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node1_preserves(original: T.Value, result: Maybe<&2, F.Node1()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node1.to_value(value) == original : T.Value}

law Node1_sound:
  for +original: T.Value
  Node1_preserves(original, F.Node1.from_value(original))
def Node1_sound(original):
  match original:
    case T.UnsignedValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node2_preserves(original: T.Value, result: Maybe<&2, F.Node2()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node2.to_value(value) == original : T.Value}

law Node2_sound:
  for +original: T.Value
  Node2_preserves(original, F.Node2.from_value(original))
def Node2_sound(original):
  match original:
    case T.UnsignedValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node3_preserves(original: T.Value, result: Maybe<&2, F.Node3()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node3.to_value(value) == original : T.Value}

law Node3_sound:
  for +original: T.Value
  Node3_preserves(original, F.Node3.from_value(original))
def Node3_sound(original):
  match original:
    case T.UnsignedValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node4_preserves(original: T.Value, result: Maybe<&2, F.Node4()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node4.to_value(value) == original : T.Value}

law Node4_sound:
  for +original: T.Value
  Node4_preserves(original, F.Node4.from_value(original))
def Node4_sound(original):
  match original:
    case T.UnsignedValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node5_preserves(original: T.Value, result: Maybe<&2, F.Node5()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node5.to_value(value) == original : T.Value}

law Node5_sound:
  for +original: T.Value
  Node5_preserves(original, F.Node5.from_value(original))
def Node5_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node6_preserves(original: T.Value, result: Maybe<&2, F.Node6()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node6.to_value(value) == original : T.Value}

law Node6_sound:
  for +original: T.Value
  Node6_preserves(original, F.Node6.from_value(original))
def Node6_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node7_preserves(original: T.Value, result: Maybe<&2, F.Node7()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node7.to_value(value) == original : T.Value}

law Node7_sound:
  for +original: T.Value
  Node7_preserves(original, F.Node7.from_value(original))
def Node7_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node8_preserves(original: T.Value, result: Maybe<&2, F.Node8()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node8.to_value(value) == original : T.Value}

law Node8_sound:
  for +original: T.Value
  Node8_preserves(original, F.Node8.from_value(original))
def Node8_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node9_preserves(original: T.Value, result: Maybe<&2, F.Node9()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node9.to_value(value) == original : T.Value}

law Node9_sound:
  for +original: T.Value
  Node9_preserves(original, F.Node9.from_value(original))
def Node9_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node10_preserves(original: T.Value, result: Maybe<&2, F.Node10()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node10.to_value(value) == original : T.Value}

law Node10_sound:
  for +original: T.Value
  Node10_preserves(original, F.Node10.from_value(original))
def Node10_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node11_preserves(original: T.Value, result: Maybe<&2, F.Node11()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node11.to_value(value) == original : T.Value}

law Node11_sound:
  for +original: T.Value
  Node11_preserves(original, F.Node11.from_value(original))
def Node11_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node12_preserves(original: T.Value, result: Maybe<&2, F.Node12()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node12.to_value(value) == original : T.Value}

def Node12_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node7()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node7.seq_to(values) == original : T.Value}

law Node12_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node7()>
  for +head: Maybe<&2, F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_preserves: Node7_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node7()> -> Node12_items_preserve(F.Node7.seq_to_go(a, t), next(a))
  Node12_items_preserve(F.Node7.seq_to_go(acc, T.Items{h, t}), F.Node7.seq_step(head, acc, next))
def Node12_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node12_items_preserve(F.Node7.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node12_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  Node12_items_preserve(F.Node7.seq_to_go(acc, original), F.Node7.seq_from_go(original, acc))
def Node12_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node7()>, T.Value, xs => F.Node7.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node7(), List.reverse(&2, F.Node7(), acc)), acc, Lists.reverse_twice(F.Node7(), acc))
    case T.Items{h, t}: Node12_step(h, t, acc, F.Node7.from_value(h), next => F.Node7.seq_from_go(t, next), Node7_sound(h), next => Node12_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node12_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node7()>>
  for preserved: Node12_items_preserve(original, result)
  Node12_preserves(T.Sequence{original}, result)
def Node12_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node7.seq_to(xs), original, preserved)

law Node12_sound:
  for +original: T.Value
  Node12_preserves(original, F.Node12.from_value(original))
def Node12_sound(original):
  match original:
    case T.Sequence{values}: Node12_sequence_sound(values, F.Node7.seq_from_go(values, []), Node12_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def ForkValue_preserves(original: T.Value, result: Maybe<&2, F.ForkValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ForkValue.to_value(value) == original : T.Value}

law ForkValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node6()>
  for +a1: Maybe<&2, F.Node6()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: Node6_preserves(o0, a0)
  for p1: Node6_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  ForkValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.ForkValue.assemble(a0, a1, a2))
def ForkValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.ForkValue.to_value(F.Fork{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.ForkValue.to_value(F.Fork{v0, v1, v2}) == T.Sequence{T.Items{F.Node6.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.ForkValue.to_value(F.Fork{v0, v1, v2}) == T.Sequence{T.Items{F.Node6.to_value(v0), T.Items{F.Node6.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law ForkValue_sound:
  for +original: T.Value
  ForkValue_preserves(original, F.ForkValue.from_value(original))
def ForkValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: ForkValue_assemble_sound(o0, o1, o2, F.Node6.from_value(o0), F.Node6.from_value(o1), F.Node3.from_value(o2), Node6_sound(o0), Node6_sound(o1), Node3_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def Node15_preserves(original: T.Value, result: Maybe<&2, F.Node15()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node15.to_value(value) == original : T.Value}

law Node15_sound:
  for +original: T.Value
  Node15_preserves(original, F.Node15.from_value(original))
def Node15_sound(original):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def SyncAggregateValue_preserves(original: T.Value, result: Maybe<&2, F.SyncAggregateValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SyncAggregateValue.to_value(value) == original : T.Value}

law SyncAggregateValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node15()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: Node15_preserves(o0, a0)
  for p1: Node9_preserves(o1, a1)
  SyncAggregateValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SyncAggregateValue.assemble(a0, a1))
def SyncAggregateValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SyncAggregateValue.to_value(F.SyncAggregate{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SyncAggregateValue.to_value(F.SyncAggregate{v0, v1}) == T.Sequence{T.Items{F.Node15.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SyncAggregateValue_sound:
  for +original: T.Value
  SyncAggregateValue_preserves(original, F.SyncAggregateValue.from_value(original))
def SyncAggregateValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SyncAggregateValue_assemble_sound(o0, o1, F.Node15.from_value(o0), F.Node9.from_value(o1), Node15_sound(o0), Node9_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def SyncAggregatorSelectionDataValue_preserves(original: T.Value, result: Maybe<&2, F.SyncAggregatorSelectionDataValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SyncAggregatorSelectionDataValue.to_value(value) == original : T.Value}

law SyncAggregatorSelectionDataValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  SyncAggregatorSelectionDataValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SyncAggregatorSelectionDataValue.assemble(a0, a1))
def SyncAggregatorSelectionDataValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SyncAggregatorSelectionDataValue.to_value(F.SyncAggregatorSelectionData{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SyncAggregatorSelectionDataValue.to_value(F.SyncAggregatorSelectionData{v0, v1}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SyncAggregatorSelectionDataValue_sound:
  for +original: T.Value
  SyncAggregatorSelectionDataValue_preserves(original, F.SyncAggregatorSelectionDataValue.from_value(original))
def SyncAggregatorSelectionDataValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SyncAggregatorSelectionDataValue_assemble_sound(o0, o1, F.Node3.from_value(o0), F.Node3.from_value(o1), Node3_sound(o0), Node3_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def PowBlockValue_preserves(original: T.Value, result: Maybe<&2, F.PowBlockValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.PowBlockValue.to_value(value) == original : T.Value}

law PowBlockValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node4()>
  for p0: Node7_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node4_preserves(o2, a2)
  PowBlockValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.PowBlockValue.assemble(a0, a1, a2))
def PowBlockValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.PowBlockValue.to_value(F.PowBlock{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.PowBlockValue.to_value(F.PowBlock{v0, v1, v2}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.PowBlockValue.to_value(F.PowBlock{v0, v1, v2}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law PowBlockValue_sound:
  for +original: T.Value
  PowBlockValue_preserves(original, F.PowBlockValue.from_value(original))
def PowBlockValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: PowBlockValue_assemble_sound(o0, o1, o2, F.Node7.from_value(o0), F.Node7.from_value(o1), F.Node4.from_value(o2), Node7_sound(o0), Node7_sound(o1), Node4_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def PendingConsolidationValue_preserves(original: T.Value, result: Maybe<&2, F.PendingConsolidationValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.PendingConsolidationValue.to_value(value) == original : T.Value}

law PendingConsolidationValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  PendingConsolidationValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.PendingConsolidationValue.assemble(a0, a1))
def PendingConsolidationValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.PendingConsolidationValue.to_value(F.PendingConsolidation{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.PendingConsolidationValue.to_value(F.PendingConsolidation{v0, v1}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law PendingConsolidationValue_sound:
  for +original: T.Value
  PendingConsolidationValue_preserves(original, F.PendingConsolidationValue.from_value(original))
def PendingConsolidationValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: PendingConsolidationValue_assemble_sound(o0, o1, F.Node3.from_value(o0), F.Node3.from_value(o1), Node3_sound(o0), Node3_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def PendingPartialWithdrawalValue_preserves(original: T.Value, result: Maybe<&2, F.PendingPartialWithdrawalValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.PendingPartialWithdrawalValue.to_value(value) == original : T.Value}

law PendingPartialWithdrawalValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  PendingPartialWithdrawalValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.PendingPartialWithdrawalValue.assemble(a0, a1, a2))
def PendingPartialWithdrawalValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.PendingPartialWithdrawalValue.to_value(F.PendingPartialWithdrawal{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.PendingPartialWithdrawalValue.to_value(F.PendingPartialWithdrawal{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.PendingPartialWithdrawalValue.to_value(F.PendingPartialWithdrawal{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law PendingPartialWithdrawalValue_sound:
  for +original: T.Value
  PendingPartialWithdrawalValue_preserves(original, F.PendingPartialWithdrawalValue.from_value(original))
def PendingPartialWithdrawalValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: PendingPartialWithdrawalValue_assemble_sound(o0, o1, o2, F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node3.from_value(o2), Node3_sound(o0), Node3_sound(o1), Node3_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def VoluntaryExitValue_preserves(original: T.Value, result: Maybe<&2, F.VoluntaryExitValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.VoluntaryExitValue.to_value(value) == original : T.Value}

law VoluntaryExitValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  VoluntaryExitValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.VoluntaryExitValue.assemble(a0, a1))
def VoluntaryExitValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.VoluntaryExitValue.to_value(F.VoluntaryExit{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.VoluntaryExitValue.to_value(F.VoluntaryExit{v0, v1}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law VoluntaryExitValue_sound:
  for +original: T.Value
  VoluntaryExitValue_preserves(original, F.VoluntaryExitValue.from_value(original))
def VoluntaryExitValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: VoluntaryExitValue_assemble_sound(o0, o1, F.Node3.from_value(o0), F.Node3.from_value(o1), Node3_sound(o0), Node3_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def SignedVoluntaryExitValue_preserves(original: T.Value, result: Maybe<&2, F.SignedVoluntaryExitValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SignedVoluntaryExitValue.to_value(value) == original : T.Value}

law SignedVoluntaryExitValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.VoluntaryExitValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: VoluntaryExitValue_preserves(o0, a0)
  for p1: Node9_preserves(o1, a1)
  SignedVoluntaryExitValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SignedVoluntaryExitValue.assemble(a0, a1))
def SignedVoluntaryExitValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SignedVoluntaryExitValue.to_value(F.SignedVoluntaryExit{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SignedVoluntaryExitValue.to_value(F.SignedVoluntaryExit{v0, v1}) == T.Sequence{T.Items{F.VoluntaryExitValue.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SignedVoluntaryExitValue_sound:
  for +original: T.Value
  SignedVoluntaryExitValue_preserves(original, F.SignedVoluntaryExitValue.from_value(original))
def SignedVoluntaryExitValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SignedVoluntaryExitValue_assemble_sound(o0, o1, F.VoluntaryExitValue.from_value(o0), F.Node9.from_value(o1), VoluntaryExitValue_sound(o0), Node9_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def HistoricalSummaryValue_preserves(original: T.Value, result: Maybe<&2, F.HistoricalSummaryValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.HistoricalSummaryValue.to_value(value) == original : T.Value}

law HistoricalSummaryValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node7()>
  for p0: Node7_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  HistoricalSummaryValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.HistoricalSummaryValue.assemble(a0, a1))
def HistoricalSummaryValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.HistoricalSummaryValue.to_value(F.HistoricalSummary{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.HistoricalSummaryValue.to_value(F.HistoricalSummary{v0, v1}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law HistoricalSummaryValue_sound:
  for +original: T.Value
  HistoricalSummaryValue_preserves(original, F.HistoricalSummaryValue.from_value(original))
def HistoricalSummaryValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: HistoricalSummaryValue_assemble_sound(o0, o1, F.Node7.from_value(o0), F.Node7.from_value(o1), Node7_sound(o0), Node7_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def Node24_preserves(original: T.Value, result: Maybe<&2, F.Node24()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node24.to_value(value) == original : T.Value}

law Node24_sound:
  for +original: T.Value
  Node24_preserves(original, F.Node24.from_value(original))
def Node24_sound(original):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def SyncCommitteeContributionValue_preserves(original: T.Value, result: Maybe<&2, F.SyncCommitteeContributionValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SyncCommitteeContributionValue.to_value(value) == original : T.Value}

law SyncCommitteeContributionValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node24()>
  for +a4: Maybe<&2, F.Node9()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: Node24_preserves(o3, a3)
  for p4: Node9_preserves(o4, a4)
  SyncCommitteeContributionValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}, F.SyncCommitteeContributionValue.assemble(a0, a1, a2, a3, a4))
def SyncCommitteeContributionValue_assemble_sound(o0, o1, o2, o3, o4, a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}:
      %p0 : {F.SyncCommitteeContributionValue.to_value(F.SyncCommitteeContribution{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p1 : {F.SyncCommitteeContributionValue.to_value(F.SyncCommitteeContribution{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p2 : {F.SyncCommitteeContributionValue.to_value(F.SyncCommitteeContribution{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p3 : {F.SyncCommitteeContributionValue.to_value(F.SyncCommitteeContribution{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p4 : {F.SyncCommitteeContributionValue.to_value(F.SyncCommitteeContribution{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.Node24.to_value(v3), T.Items{_, T.EmptyItems{}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: Unit{}

law SyncCommitteeContributionValue_sound:
  for +original: T.Value
  SyncCommitteeContributionValue_preserves(original, F.SyncCommitteeContributionValue.from_value(original))
def SyncCommitteeContributionValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: SyncCommitteeContributionValue_assemble_sound(o0, o1, o2, o3, o4, F.Node3.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node24.from_value(o3), F.Node9.from_value(o4), Node3_sound(o0), Node7_sound(o1), Node3_sound(o2), Node24_sound(o3), Node9_sound(o4))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}

def ContributionAndProofValue_preserves(original: T.Value, result: Maybe<&2, F.ContributionAndProofValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ContributionAndProofValue.to_value(value) == original : T.Value}

law ContributionAndProofValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.SyncCommitteeContributionValue()>
  for +a2: Maybe<&2, F.Node9()>
  for p0: Node3_preserves(o0, a0)
  for p1: SyncCommitteeContributionValue_preserves(o1, a1)
  for p2: Node9_preserves(o2, a2)
  ContributionAndProofValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.ContributionAndProofValue.assemble(a0, a1, a2))
def ContributionAndProofValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.ContributionAndProofValue.to_value(F.ContributionAndProof{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.ContributionAndProofValue.to_value(F.ContributionAndProof{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.ContributionAndProofValue.to_value(F.ContributionAndProof{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.SyncCommitteeContributionValue.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law ContributionAndProofValue_sound:
  for +original: T.Value
  ContributionAndProofValue_preserves(original, F.ContributionAndProofValue.from_value(original))
def ContributionAndProofValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: ContributionAndProofValue_assemble_sound(o0, o1, o2, F.Node3.from_value(o0), F.SyncCommitteeContributionValue.from_value(o1), F.Node9.from_value(o2), Node3_sound(o0), SyncCommitteeContributionValue_sound(o1), Node9_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def SignedContributionAndProofValue_preserves(original: T.Value, result: Maybe<&2, F.SignedContributionAndProofValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SignedContributionAndProofValue.to_value(value) == original : T.Value}

law SignedContributionAndProofValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.ContributionAndProofValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: ContributionAndProofValue_preserves(o0, a0)
  for p1: Node9_preserves(o1, a1)
  SignedContributionAndProofValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SignedContributionAndProofValue.assemble(a0, a1))
def SignedContributionAndProofValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SignedContributionAndProofValue.to_value(F.SignedContributionAndProof{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SignedContributionAndProofValue.to_value(F.SignedContributionAndProof{v0, v1}) == T.Sequence{T.Items{F.ContributionAndProofValue.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SignedContributionAndProofValue_sound:
  for +original: T.Value
  SignedContributionAndProofValue_preserves(original, F.SignedContributionAndProofValue.from_value(original))
def SignedContributionAndProofValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SignedContributionAndProofValue_assemble_sound(o0, o1, F.ContributionAndProofValue.from_value(o0), F.Node9.from_value(o1), ContributionAndProofValue_sound(o0), Node9_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def SyncCommitteeMessageValue_preserves(original: T.Value, result: Maybe<&2, F.SyncCommitteeMessageValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SyncCommitteeMessageValue.to_value(value) == original : T.Value}

law SyncCommitteeMessageValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node9()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: Node9_preserves(o3, a3)
  SyncCommitteeMessageValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}, F.SyncCommitteeMessageValue.assemble(a0, a1, a2, a3))
def SyncCommitteeMessageValue_assemble_sound(o0, o1, o2, o3, a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}:
      %p0 : {F.SyncCommitteeMessageValue.to_value(F.SyncCommitteeMessage{v0, v1, v2, v3}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p1 : {F.SyncCommitteeMessageValue.to_value(F.SyncCommitteeMessage{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p2 : {F.SyncCommitteeMessageValue.to_value(F.SyncCommitteeMessage{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p3 : {F.SyncCommitteeMessageValue.to_value(F.SyncCommitteeMessage{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.EmptyItems{}}}}}} : T.Value}
      {==}
    case None{} _ _ _: Unit{}
    case Some{v0} None{} _ _: Unit{}
    case Some{v0} Some{v1} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{}: Unit{}

law SyncCommitteeMessageValue_sound:
  for +original: T.Value
  SyncCommitteeMessageValue_preserves(original, F.SyncCommitteeMessageValue.from_value(original))
def SyncCommitteeMessageValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: SyncCommitteeMessageValue_assemble_sound(o0, o1, o2, o3, F.Node3.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node9.from_value(o3), Node3_sound(o0), Node7_sound(o1), Node3_sound(o2), Node9_sound(o3))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}

def Eth1BlockValue_preserves(original: T.Value, result: Maybe<&2, F.Eth1BlockValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Eth1BlockValue.to_value(value) == original : T.Value}

law Eth1BlockValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  Eth1BlockValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.Eth1BlockValue.assemble(a0, a1, a2))
def Eth1BlockValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.Eth1BlockValue.to_value(F.Eth1Block{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.Eth1BlockValue.to_value(F.Eth1Block{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.Eth1BlockValue.to_value(F.Eth1Block{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law Eth1BlockValue_sound:
  for +original: T.Value
  Eth1BlockValue_preserves(original, F.Eth1BlockValue.from_value(original))
def Eth1BlockValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Eth1BlockValue_assemble_sound(o0, o1, o2, F.Node3.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), Node3_sound(o0), Node7_sound(o1), Node3_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def BeaconBlockHeaderValue_preserves(original: T.Value, result: Maybe<&2, F.BeaconBlockHeaderValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.BeaconBlockHeaderValue.to_value(value) == original : T.Value}

law BeaconBlockHeaderValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.Node7()>
  for +a4: Maybe<&2, F.Node7()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  for p2: Node7_preserves(o2, a2)
  for p3: Node7_preserves(o3, a3)
  for p4: Node7_preserves(o4, a4)
  BeaconBlockHeaderValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}, F.BeaconBlockHeaderValue.assemble(a0, a1, a2, a3, a4))
def BeaconBlockHeaderValue_assemble_sound(o0, o1, o2, o3, o4, a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}:
      %p0 : {F.BeaconBlockHeaderValue.to_value(F.BeaconBlockHeader{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p1 : {F.BeaconBlockHeaderValue.to_value(F.BeaconBlockHeader{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p2 : {F.BeaconBlockHeaderValue.to_value(F.BeaconBlockHeader{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p3 : {F.BeaconBlockHeaderValue.to_value(F.BeaconBlockHeader{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{_, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p4 : {F.BeaconBlockHeaderValue.to_value(F.BeaconBlockHeader{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{_, T.EmptyItems{}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: Unit{}

law BeaconBlockHeaderValue_sound:
  for +original: T.Value
  BeaconBlockHeaderValue_preserves(original, F.BeaconBlockHeaderValue.from_value(original))
def BeaconBlockHeaderValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: BeaconBlockHeaderValue_assemble_sound(o0, o1, o2, o3, o4, F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node7.from_value(o2), F.Node7.from_value(o3), F.Node7.from_value(o4), Node3_sound(o0), Node3_sound(o1), Node7_sound(o2), Node7_sound(o3), Node7_sound(o4))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}

def SignedBeaconBlockHeaderValue_preserves(original: T.Value, result: Maybe<&2, F.SignedBeaconBlockHeaderValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SignedBeaconBlockHeaderValue.to_value(value) == original : T.Value}

law SignedBeaconBlockHeaderValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.BeaconBlockHeaderValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: BeaconBlockHeaderValue_preserves(o0, a0)
  for p1: Node9_preserves(o1, a1)
  SignedBeaconBlockHeaderValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SignedBeaconBlockHeaderValue.assemble(a0, a1))
def SignedBeaconBlockHeaderValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SignedBeaconBlockHeaderValue.to_value(F.SignedBeaconBlockHeader{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SignedBeaconBlockHeaderValue.to_value(F.SignedBeaconBlockHeader{v0, v1}) == T.Sequence{T.Items{F.BeaconBlockHeaderValue.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SignedBeaconBlockHeaderValue_sound:
  for +original: T.Value
  SignedBeaconBlockHeaderValue_preserves(original, F.SignedBeaconBlockHeaderValue.from_value(original))
def SignedBeaconBlockHeaderValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SignedBeaconBlockHeaderValue_assemble_sound(o0, o1, F.BeaconBlockHeaderValue.from_value(o0), F.Node9.from_value(o1), BeaconBlockHeaderValue_sound(o0), Node9_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def ProposerSlashingValue_preserves(original: T.Value, result: Maybe<&2, F.ProposerSlashingValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ProposerSlashingValue.to_value(value) == original : T.Value}

law ProposerSlashingValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.SignedBeaconBlockHeaderValue()>
  for +a1: Maybe<&2, F.SignedBeaconBlockHeaderValue()>
  for p0: SignedBeaconBlockHeaderValue_preserves(o0, a0)
  for p1: SignedBeaconBlockHeaderValue_preserves(o1, a1)
  ProposerSlashingValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.ProposerSlashingValue.assemble(a0, a1))
def ProposerSlashingValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.ProposerSlashingValue.to_value(F.ProposerSlashing{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.ProposerSlashingValue.to_value(F.ProposerSlashing{v0, v1}) == T.Sequence{T.Items{F.SignedBeaconBlockHeaderValue.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law ProposerSlashingValue_sound:
  for +original: T.Value
  ProposerSlashingValue_preserves(original, F.ProposerSlashingValue.from_value(original))
def ProposerSlashingValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: ProposerSlashingValue_assemble_sound(o0, o1, F.SignedBeaconBlockHeaderValue.from_value(o0), F.SignedBeaconBlockHeaderValue.from_value(o1), SignedBeaconBlockHeaderValue_sound(o0), SignedBeaconBlockHeaderValue_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def Node33_preserves(original: T.Value, result: Maybe<&2, F.Node33()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node33.to_value(value) == original : T.Value}

def Node33_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node7()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node7.seq_to(values) == original : T.Value}

law Node33_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node7()>
  for +head: Maybe<&2, F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_preserves: Node7_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node7()> -> Node33_items_preserve(F.Node7.seq_to_go(a, t), next(a))
  Node33_items_preserve(F.Node7.seq_to_go(acc, T.Items{h, t}), F.Node7.seq_step(head, acc, next))
def Node33_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node33_items_preserve(F.Node7.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node33_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  Node33_items_preserve(F.Node7.seq_to_go(acc, original), F.Node7.seq_from_go(original, acc))
def Node33_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node7()>, T.Value, xs => F.Node7.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node7(), List.reverse(&2, F.Node7(), acc)), acc, Lists.reverse_twice(F.Node7(), acc))
    case T.Items{h, t}: Node33_step(h, t, acc, F.Node7.from_value(h), next => F.Node7.seq_from_go(t, next), Node7_sound(h), next => Node33_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node33_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node7()>>
  for preserved: Node33_items_preserve(original, result)
  Node33_preserves(T.Sequence{original}, result)
def Node33_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node7.seq_to(xs), original, preserved)

law Node33_sound:
  for +original: T.Value
  Node33_preserves(original, F.Node33.from_value(original))
def Node33_sound(original):
  match original:
    case T.Sequence{values}: Node33_sequence_sound(values, F.Node7.seq_from_go(values, []), Node33_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def HistoricalBatchValue_preserves(original: T.Value, result: Maybe<&2, F.HistoricalBatchValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.HistoricalBatchValue.to_value(value) == original : T.Value}

law HistoricalBatchValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node33()>
  for +a1: Maybe<&2, F.Node33()>
  for p0: Node33_preserves(o0, a0)
  for p1: Node33_preserves(o1, a1)
  HistoricalBatchValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.HistoricalBatchValue.assemble(a0, a1))
def HistoricalBatchValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.HistoricalBatchValue.to_value(F.HistoricalBatch{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.HistoricalBatchValue.to_value(F.HistoricalBatch{v0, v1}) == T.Sequence{T.Items{F.Node33.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law HistoricalBatchValue_sound:
  for +original: T.Value
  HistoricalBatchValue_preserves(original, F.HistoricalBatchValue.from_value(original))
def HistoricalBatchValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: HistoricalBatchValue_assemble_sound(o0, o1, F.Node33.from_value(o0), F.Node33.from_value(o1), Node33_sound(o0), Node33_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def Eth1DataValue_preserves(original: T.Value, result: Maybe<&2, F.Eth1DataValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Eth1DataValue.to_value(value) == original : T.Value}

law Eth1DataValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node7()>
  for p0: Node7_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  for p2: Node7_preserves(o2, a2)
  Eth1DataValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.Eth1DataValue.assemble(a0, a1, a2))
def Eth1DataValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.Eth1DataValue.to_value(F.Eth1Data{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.Eth1DataValue.to_value(F.Eth1Data{v0, v1, v2}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.Eth1DataValue.to_value(F.Eth1Data{v0, v1, v2}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law Eth1DataValue_sound:
  for +original: T.Value
  Eth1DataValue_preserves(original, F.Eth1DataValue.from_value(original))
def Eth1DataValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Eth1DataValue_assemble_sound(o0, o1, o2, F.Node7.from_value(o0), F.Node3.from_value(o1), F.Node7.from_value(o2), Node7_sound(o0), Node3_sound(o1), Node7_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def CheckpointValue_preserves(original: T.Value, result: Maybe<&2, F.CheckpointValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.CheckpointValue.to_value(value) == original : T.Value}

law CheckpointValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node7()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  CheckpointValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.CheckpointValue.assemble(a0, a1))
def CheckpointValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.CheckpointValue.to_value(F.Checkpoint{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.CheckpointValue.to_value(F.Checkpoint{v0, v1}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law CheckpointValue_sound:
  for +original: T.Value
  CheckpointValue_preserves(original, F.CheckpointValue.from_value(original))
def CheckpointValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: CheckpointValue_assemble_sound(o0, o1, F.Node3.from_value(o0), F.Node7.from_value(o1), Node3_sound(o0), Node7_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def AttestationDataValue_preserves(original: T.Value, result: Maybe<&2, F.AttestationDataValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.AttestationDataValue.to_value(value) == original : T.Value}

law AttestationDataValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.CheckpointValue()>
  for +a4: Maybe<&2, F.CheckpointValue()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  for p2: Node7_preserves(o2, a2)
  for p3: CheckpointValue_preserves(o3, a3)
  for p4: CheckpointValue_preserves(o4, a4)
  AttestationDataValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}, F.AttestationDataValue.assemble(a0, a1, a2, a3, a4))
def AttestationDataValue_assemble_sound(o0, o1, o2, o3, o4, a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}:
      %p0 : {F.AttestationDataValue.to_value(F.AttestationData{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p1 : {F.AttestationDataValue.to_value(F.AttestationData{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p2 : {F.AttestationDataValue.to_value(F.AttestationData{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p3 : {F.AttestationDataValue.to_value(F.AttestationData{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{_, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p4 : {F.AttestationDataValue.to_value(F.AttestationData{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.CheckpointValue.to_value(v3), T.Items{_, T.EmptyItems{}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: Unit{}

law AttestationDataValue_sound:
  for +original: T.Value
  AttestationDataValue_preserves(original, F.AttestationDataValue.from_value(original))
def AttestationDataValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: AttestationDataValue_assemble_sound(o0, o1, o2, o3, o4, F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node7.from_value(o2), F.CheckpointValue.from_value(o3), F.CheckpointValue.from_value(o4), Node3_sound(o0), Node3_sound(o1), Node7_sound(o2), CheckpointValue_sound(o3), CheckpointValue_sound(o4))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}

def SingleAttestationValue_preserves(original: T.Value, result: Maybe<&2, F.SingleAttestationValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SingleAttestationValue.to_value(value) == original : T.Value}

law SingleAttestationValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.AttestationDataValue()>
  for +a3: Maybe<&2, F.Node9()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  for p2: AttestationDataValue_preserves(o2, a2)
  for p3: Node9_preserves(o3, a3)
  SingleAttestationValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}, F.SingleAttestationValue.assemble(a0, a1, a2, a3))
def SingleAttestationValue_assemble_sound(o0, o1, o2, o3, a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}:
      %p0 : {F.SingleAttestationValue.to_value(F.SingleAttestation{v0, v1, v2, v3}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p1 : {F.SingleAttestationValue.to_value(F.SingleAttestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p2 : {F.SingleAttestationValue.to_value(F.SingleAttestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{_, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p3 : {F.SingleAttestationValue.to_value(F.SingleAttestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{F.AttestationDataValue.to_value(v2), T.Items{_, T.EmptyItems{}}}}}} : T.Value}
      {==}
    case None{} _ _ _: Unit{}
    case Some{v0} None{} _ _: Unit{}
    case Some{v0} Some{v1} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{}: Unit{}

law SingleAttestationValue_sound:
  for +original: T.Value
  SingleAttestationValue_preserves(original, F.SingleAttestationValue.from_value(original))
def SingleAttestationValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: SingleAttestationValue_assemble_sound(o0, o1, o2, o3, F.Node3.from_value(o0), F.Node3.from_value(o1), F.AttestationDataValue.from_value(o2), F.Node9.from_value(o3), Node3_sound(o0), Node3_sound(o1), AttestationDataValue_sound(o2), Node9_sound(o3))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}

def Node39_preserves(original: T.Value, result: Maybe<&2, F.Node39()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node39.to_value(value) == original : T.Value}

law Node39_sound:
  for +original: T.Value
  Node39_preserves(original, F.Node39.from_value(original))
def Node39_sound(original):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node40_preserves(original: T.Value, result: Maybe<&2, F.Node40()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node40.to_value(value) == original : T.Value}

law Node40_sound:
  for +original: T.Value
  Node40_preserves(original, F.Node40.from_value(original))
def Node40_sound(original):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def AttestationValue_preserves(original: T.Value, result: Maybe<&2, F.AttestationValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.AttestationValue.to_value(value) == original : T.Value}

law AttestationValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +a0: Maybe<&2, F.Node39()>
  for +a1: Maybe<&2, F.AttestationDataValue()>
  for +a2: Maybe<&2, F.Node9()>
  for +a3: Maybe<&2, F.Node40()>
  for p0: Node39_preserves(o0, a0)
  for p1: AttestationDataValue_preserves(o1, a1)
  for p2: Node9_preserves(o2, a2)
  for p3: Node40_preserves(o3, a3)
  AttestationValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}, F.AttestationValue.assemble(a0, a1, a2, a3))
def AttestationValue_assemble_sound(o0, o1, o2, o3, a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}:
      %p0 : {F.AttestationValue.to_value(F.Attestation{v0, v1, v2, v3}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p1 : {F.AttestationValue.to_value(F.Attestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node39.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p2 : {F.AttestationValue.to_value(F.Attestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node39.to_value(v0), T.Items{F.AttestationDataValue.to_value(v1), T.Items{_, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p3 : {F.AttestationValue.to_value(F.Attestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node39.to_value(v0), T.Items{F.AttestationDataValue.to_value(v1), T.Items{F.Node9.to_value(v2), T.Items{_, T.EmptyItems{}}}}}} : T.Value}
      {==}
    case None{} _ _ _: Unit{}
    case Some{v0} None{} _ _: Unit{}
    case Some{v0} Some{v1} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{}: Unit{}

law AttestationValue_sound:
  for +original: T.Value
  AttestationValue_preserves(original, F.AttestationValue.from_value(original))
def AttestationValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: AttestationValue_assemble_sound(o0, o1, o2, o3, F.Node39.from_value(o0), F.AttestationDataValue.from_value(o1), F.Node9.from_value(o2), F.Node40.from_value(o3), Node39_sound(o0), AttestationDataValue_sound(o1), Node9_sound(o2), Node40_sound(o3))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}

def AggregateAndProofValue_preserves(original: T.Value, result: Maybe<&2, F.AggregateAndProofValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.AggregateAndProofValue.to_value(value) == original : T.Value}

law AggregateAndProofValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.AttestationValue()>
  for +a2: Maybe<&2, F.Node9()>
  for p0: Node3_preserves(o0, a0)
  for p1: AttestationValue_preserves(o1, a1)
  for p2: Node9_preserves(o2, a2)
  AggregateAndProofValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.AggregateAndProofValue.assemble(a0, a1, a2))
def AggregateAndProofValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.AggregateAndProofValue.to_value(F.AggregateAndProof{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.AggregateAndProofValue.to_value(F.AggregateAndProof{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.AggregateAndProofValue.to_value(F.AggregateAndProof{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.AttestationValue.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law AggregateAndProofValue_sound:
  for +original: T.Value
  AggregateAndProofValue_preserves(original, F.AggregateAndProofValue.from_value(original))
def AggregateAndProofValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: AggregateAndProofValue_assemble_sound(o0, o1, o2, F.Node3.from_value(o0), F.AttestationValue.from_value(o1), F.Node9.from_value(o2), Node3_sound(o0), AttestationValue_sound(o1), Node9_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def SignedAggregateAndProofValue_preserves(original: T.Value, result: Maybe<&2, F.SignedAggregateAndProofValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SignedAggregateAndProofValue.to_value(value) == original : T.Value}

law SignedAggregateAndProofValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.AggregateAndProofValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: AggregateAndProofValue_preserves(o0, a0)
  for p1: Node9_preserves(o1, a1)
  SignedAggregateAndProofValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SignedAggregateAndProofValue.assemble(a0, a1))
def SignedAggregateAndProofValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SignedAggregateAndProofValue.to_value(F.SignedAggregateAndProof{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SignedAggregateAndProofValue.to_value(F.SignedAggregateAndProof{v0, v1}) == T.Sequence{T.Items{F.AggregateAndProofValue.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SignedAggregateAndProofValue_sound:
  for +original: T.Value
  SignedAggregateAndProofValue_preserves(original, F.SignedAggregateAndProofValue.from_value(original))
def SignedAggregateAndProofValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SignedAggregateAndProofValue_assemble_sound(o0, o1, F.AggregateAndProofValue.from_value(o0), F.Node9.from_value(o1), AggregateAndProofValue_sound(o0), Node9_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def Node44_preserves(original: T.Value, result: Maybe<&2, F.Node44()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node44.to_value(value) == original : T.Value}

law Node44_sound:
  for +original: T.Value
  Node44_preserves(original, F.Node44.from_value(original))
def Node44_sound(original):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def PendingAttestationValue_preserves(original: T.Value, result: Maybe<&2, F.PendingAttestationValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.PendingAttestationValue.to_value(value) == original : T.Value}

law PendingAttestationValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +a0: Maybe<&2, F.Node44()>
  for +a1: Maybe<&2, F.AttestationDataValue()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node3()>
  for p0: Node44_preserves(o0, a0)
  for p1: AttestationDataValue_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: Node3_preserves(o3, a3)
  PendingAttestationValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}, F.PendingAttestationValue.assemble(a0, a1, a2, a3))
def PendingAttestationValue_assemble_sound(o0, o1, o2, o3, a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}:
      %p0 : {F.PendingAttestationValue.to_value(F.PendingAttestation{v0, v1, v2, v3}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p1 : {F.PendingAttestationValue.to_value(F.PendingAttestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node44.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p2 : {F.PendingAttestationValue.to_value(F.PendingAttestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node44.to_value(v0), T.Items{F.AttestationDataValue.to_value(v1), T.Items{_, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p3 : {F.PendingAttestationValue.to_value(F.PendingAttestation{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node44.to_value(v0), T.Items{F.AttestationDataValue.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.EmptyItems{}}}}}} : T.Value}
      {==}
    case None{} _ _ _: Unit{}
    case Some{v0} None{} _ _: Unit{}
    case Some{v0} Some{v1} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{}: Unit{}

law PendingAttestationValue_sound:
  for +original: T.Value
  PendingAttestationValue_preserves(original, F.PendingAttestationValue.from_value(original))
def PendingAttestationValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: PendingAttestationValue_assemble_sound(o0, o1, o2, o3, F.Node44.from_value(o0), F.AttestationDataValue.from_value(o1), F.Node3.from_value(o2), F.Node3.from_value(o3), Node44_sound(o0), AttestationDataValue_sound(o1), Node3_sound(o2), Node3_sound(o3))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}

def Node46_preserves(original: T.Value, result: Maybe<&2, F.Node46()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node46.to_value(value) == original : T.Value}

def Node46_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node3()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node3.seq_to(values) == original : T.Value}

law Node46_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node3()>
  for +head: Maybe<&2, F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_preserves: Node3_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node3()> -> Node46_items_preserve(F.Node3.seq_to_go(a, t), next(a))
  Node46_items_preserve(F.Node3.seq_to_go(acc, T.Items{h, t}), F.Node3.seq_step(head, acc, next))
def Node46_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node46_items_preserve(F.Node3.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node46_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  Node46_items_preserve(F.Node3.seq_to_go(acc, original), F.Node3.seq_from_go(original, acc))
def Node46_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node3()>, T.Value, xs => F.Node3.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node3(), List.reverse(&2, F.Node3(), acc)), acc, Lists.reverse_twice(F.Node3(), acc))
    case T.Items{h, t}: Node46_step(h, t, acc, F.Node3.from_value(h), next => F.Node3.seq_from_go(t, next), Node3_sound(h), next => Node46_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node46_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node3()>>
  for preserved: Node46_items_preserve(original, result)
  Node46_preserves(T.Sequence{original}, result)
def Node46_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node3.seq_to(xs), original, preserved)

law Node46_sound:
  for +original: T.Value
  Node46_preserves(original, F.Node46.from_value(original))
def Node46_sound(original):
  match original:
    case T.Sequence{values}: Node46_sequence_sound(values, F.Node3.seq_from_go(values, []), Node46_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def IndexedAttestationValue_preserves(original: T.Value, result: Maybe<&2, F.IndexedAttestationValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.IndexedAttestationValue.to_value(value) == original : T.Value}

law IndexedAttestationValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node46()>
  for +a1: Maybe<&2, F.AttestationDataValue()>
  for +a2: Maybe<&2, F.Node9()>
  for p0: Node46_preserves(o0, a0)
  for p1: AttestationDataValue_preserves(o1, a1)
  for p2: Node9_preserves(o2, a2)
  IndexedAttestationValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.IndexedAttestationValue.assemble(a0, a1, a2))
def IndexedAttestationValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.IndexedAttestationValue.to_value(F.IndexedAttestation{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.IndexedAttestationValue.to_value(F.IndexedAttestation{v0, v1, v2}) == T.Sequence{T.Items{F.Node46.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.IndexedAttestationValue.to_value(F.IndexedAttestation{v0, v1, v2}) == T.Sequence{T.Items{F.Node46.to_value(v0), T.Items{F.AttestationDataValue.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law IndexedAttestationValue_sound:
  for +original: T.Value
  IndexedAttestationValue_preserves(original, F.IndexedAttestationValue.from_value(original))
def IndexedAttestationValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: IndexedAttestationValue_assemble_sound(o0, o1, o2, F.Node46.from_value(o0), F.AttestationDataValue.from_value(o1), F.Node9.from_value(o2), Node46_sound(o0), AttestationDataValue_sound(o1), Node9_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def AttesterSlashingValue_preserves(original: T.Value, result: Maybe<&2, F.AttesterSlashingValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.AttesterSlashingValue.to_value(value) == original : T.Value}

law AttesterSlashingValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.IndexedAttestationValue()>
  for +a1: Maybe<&2, F.IndexedAttestationValue()>
  for p0: IndexedAttestationValue_preserves(o0, a0)
  for p1: IndexedAttestationValue_preserves(o1, a1)
  AttesterSlashingValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.AttesterSlashingValue.assemble(a0, a1))
def AttesterSlashingValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.AttesterSlashingValue.to_value(F.AttesterSlashing{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.AttesterSlashingValue.to_value(F.AttesterSlashing{v0, v1}) == T.Sequence{T.Items{F.IndexedAttestationValue.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law AttesterSlashingValue_sound:
  for +original: T.Value
  AttesterSlashingValue_preserves(original, F.AttesterSlashingValue.from_value(original))
def AttesterSlashingValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: AttesterSlashingValue_assemble_sound(o0, o1, F.IndexedAttestationValue.from_value(o0), F.IndexedAttestationValue.from_value(o1), IndexedAttestationValue_sound(o0), IndexedAttestationValue_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def ForkDataValue_preserves(original: T.Value, result: Maybe<&2, F.ForkDataValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ForkDataValue.to_value(value) == original : T.Value}

law ForkDataValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node6()>
  for +a1: Maybe<&2, F.Node7()>
  for p0: Node6_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  ForkDataValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.ForkDataValue.assemble(a0, a1))
def ForkDataValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.ForkDataValue.to_value(F.ForkData{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.ForkDataValue.to_value(F.ForkData{v0, v1}) == T.Sequence{T.Items{F.Node6.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law ForkDataValue_sound:
  for +original: T.Value
  ForkDataValue_preserves(original, F.ForkDataValue.from_value(original))
def ForkDataValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: ForkDataValue_assemble_sound(o0, o1, F.Node6.from_value(o0), F.Node7.from_value(o1), Node6_sound(o0), Node7_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def SigningDataValue_preserves(original: T.Value, result: Maybe<&2, F.SigningDataValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SigningDataValue.to_value(value) == original : T.Value}

law SigningDataValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node7()>
  for p0: Node7_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  SigningDataValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SigningDataValue.assemble(a0, a1))
def SigningDataValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SigningDataValue.to_value(F.SigningData{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SigningDataValue.to_value(F.SigningData{v0, v1}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SigningDataValue_sound:
  for +original: T.Value
  SigningDataValue_preserves(original, F.SigningDataValue.from_value(original))
def SigningDataValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SigningDataValue_assemble_sound(o0, o1, F.Node7.from_value(o0), F.Node7.from_value(o1), Node7_sound(o0), Node7_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def DepositRequestValue_preserves(original: T.Value, result: Maybe<&2, F.DepositRequestValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.DepositRequestValue.to_value(value) == original : T.Value}

law DepositRequestValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node9()>
  for +a4: Maybe<&2, F.Node3()>
  for p0: Node8_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: Node9_preserves(o3, a3)
  for p4: Node3_preserves(o4, a4)
  DepositRequestValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}, F.DepositRequestValue.assemble(a0, a1, a2, a3, a4))
def DepositRequestValue_assemble_sound(o0, o1, o2, o3, o4, a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}:
      %p0 : {F.DepositRequestValue.to_value(F.DepositRequest{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p1 : {F.DepositRequestValue.to_value(F.DepositRequest{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p2 : {F.DepositRequestValue.to_value(F.DepositRequest{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p3 : {F.DepositRequestValue.to_value(F.DepositRequest{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p4 : {F.DepositRequestValue.to_value(F.DepositRequest{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.Node9.to_value(v3), T.Items{_, T.EmptyItems{}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: Unit{}

law DepositRequestValue_sound:
  for +original: T.Value
  DepositRequestValue_preserves(original, F.DepositRequestValue.from_value(original))
def DepositRequestValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: DepositRequestValue_assemble_sound(o0, o1, o2, o3, o4, F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node9.from_value(o3), F.Node3.from_value(o4), Node8_sound(o0), Node7_sound(o1), Node3_sound(o2), Node9_sound(o3), Node3_sound(o4))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}

def PendingDepositValue_preserves(original: T.Value, result: Maybe<&2, F.PendingDepositValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.PendingDepositValue.to_value(value) == original : T.Value}

law PendingDepositValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node9()>
  for +a4: Maybe<&2, F.Node3()>
  for p0: Node8_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: Node9_preserves(o3, a3)
  for p4: Node3_preserves(o4, a4)
  PendingDepositValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}, F.PendingDepositValue.assemble(a0, a1, a2, a3, a4))
def PendingDepositValue_assemble_sound(o0, o1, o2, o3, o4, a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}:
      %p0 : {F.PendingDepositValue.to_value(F.PendingDeposit{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p1 : {F.PendingDepositValue.to_value(F.PendingDeposit{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p2 : {F.PendingDepositValue.to_value(F.PendingDeposit{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p3 : {F.PendingDepositValue.to_value(F.PendingDeposit{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p4 : {F.PendingDepositValue.to_value(F.PendingDeposit{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.Node9.to_value(v3), T.Items{_, T.EmptyItems{}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: Unit{}

law PendingDepositValue_sound:
  for +original: T.Value
  PendingDepositValue_preserves(original, F.PendingDepositValue.from_value(original))
def PendingDepositValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: PendingDepositValue_assemble_sound(o0, o1, o2, o3, o4, F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node9.from_value(o3), F.Node3.from_value(o4), Node8_sound(o0), Node7_sound(o1), Node3_sound(o2), Node9_sound(o3), Node3_sound(o4))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}

def Node53_preserves(original: T.Value, result: Maybe<&2, F.Node53()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node53.to_value(value) == original : T.Value}

def Node53_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node8()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node8.seq_to(values) == original : T.Value}

law Node53_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node8()>
  for +head: Maybe<&2, F.Node8()>
  for next: +List<F.Node8()> -> Maybe<&2, +List<F.Node8()>>
  for head_preserves: Node8_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node8()> -> Node53_items_preserve(F.Node8.seq_to_go(a, t), next(a))
  Node53_items_preserve(F.Node8.seq_to_go(acc, T.Items{h, t}), F.Node8.seq_step(head, acc, next))
def Node53_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node53_items_preserve(F.Node8.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node53_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node8()>
  Node53_items_preserve(F.Node8.seq_to_go(acc, original), F.Node8.seq_from_go(original, acc))
def Node53_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node8()>, T.Value, xs => F.Node8.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node8(), List.reverse(&2, F.Node8(), acc)), acc, Lists.reverse_twice(F.Node8(), acc))
    case T.Items{h, t}: Node53_step(h, t, acc, F.Node8.from_value(h), next => F.Node8.seq_from_go(t, next), Node8_sound(h), next => Node53_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node53_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node8()>>
  for preserved: Node53_items_preserve(original, result)
  Node53_preserves(T.Sequence{original}, result)
def Node53_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node8.seq_to(xs), original, preserved)

law Node53_sound:
  for +original: T.Value
  Node53_preserves(original, F.Node53.from_value(original))
def Node53_sound(original):
  match original:
    case T.Sequence{values}: Node53_sequence_sound(values, F.Node8.seq_from_go(values, []), Node53_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def SyncCommitteeValue_preserves(original: T.Value, result: Maybe<&2, F.SyncCommitteeValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SyncCommitteeValue.to_value(value) == original : T.Value}

law SyncCommitteeValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node53()>
  for +a1: Maybe<&2, F.Node8()>
  for p0: Node53_preserves(o0, a0)
  for p1: Node8_preserves(o1, a1)
  SyncCommitteeValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SyncCommitteeValue.assemble(a0, a1))
def SyncCommitteeValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SyncCommitteeValue.to_value(F.SyncCommittee{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SyncCommitteeValue.to_value(F.SyncCommittee{v0, v1}) == T.Sequence{T.Items{F.Node53.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SyncCommitteeValue_sound:
  for +original: T.Value
  SyncCommitteeValue_preserves(original, F.SyncCommitteeValue.from_value(original))
def SyncCommitteeValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SyncCommitteeValue_assemble_sound(o0, o1, F.Node53.from_value(o0), F.Node8.from_value(o1), Node53_sound(o0), Node8_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def DepositDataValue_preserves(original: T.Value, result: Maybe<&2, F.DepositDataValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.DepositDataValue.to_value(value) == original : T.Value}

law DepositDataValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node9()>
  for p0: Node8_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: Node9_preserves(o3, a3)
  DepositDataValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}, F.DepositDataValue.assemble(a0, a1, a2, a3))
def DepositDataValue_assemble_sound(o0, o1, o2, o3, a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}:
      %p0 : {F.DepositDataValue.to_value(F.DepositData{v0, v1, v2, v3}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p1 : {F.DepositDataValue.to_value(F.DepositData{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p2 : {F.DepositDataValue.to_value(F.DepositData{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p3 : {F.DepositDataValue.to_value(F.DepositData{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.EmptyItems{}}}}}} : T.Value}
      {==}
    case None{} _ _ _: Unit{}
    case Some{v0} None{} _ _: Unit{}
    case Some{v0} Some{v1} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{}: Unit{}

law DepositDataValue_sound:
  for +original: T.Value
  DepositDataValue_preserves(original, F.DepositDataValue.from_value(original))
def DepositDataValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: DepositDataValue_assemble_sound(o0, o1, o2, o3, F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node9.from_value(o3), Node8_sound(o0), Node7_sound(o1), Node3_sound(o2), Node9_sound(o3))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}

def Node56_preserves(original: T.Value, result: Maybe<&2, F.Node56()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node56.to_value(value) == original : T.Value}

def Node56_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node7()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node7.seq_to(values) == original : T.Value}

law Node56_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node7()>
  for +head: Maybe<&2, F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_preserves: Node7_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node7()> -> Node56_items_preserve(F.Node7.seq_to_go(a, t), next(a))
  Node56_items_preserve(F.Node7.seq_to_go(acc, T.Items{h, t}), F.Node7.seq_step(head, acc, next))
def Node56_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node56_items_preserve(F.Node7.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node56_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  Node56_items_preserve(F.Node7.seq_to_go(acc, original), F.Node7.seq_from_go(original, acc))
def Node56_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node7()>, T.Value, xs => F.Node7.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node7(), List.reverse(&2, F.Node7(), acc)), acc, Lists.reverse_twice(F.Node7(), acc))
    case T.Items{h, t}: Node56_step(h, t, acc, F.Node7.from_value(h), next => F.Node7.seq_from_go(t, next), Node7_sound(h), next => Node56_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node56_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node7()>>
  for preserved: Node56_items_preserve(original, result)
  Node56_preserves(T.Sequence{original}, result)
def Node56_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node7.seq_to(xs), original, preserved)

law Node56_sound:
  for +original: T.Value
  Node56_preserves(original, F.Node56.from_value(original))
def Node56_sound(original):
  match original:
    case T.Sequence{values}: Node56_sequence_sound(values, F.Node7.seq_from_go(values, []), Node56_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def DepositValue_preserves(original: T.Value, result: Maybe<&2, F.DepositValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.DepositValue.to_value(value) == original : T.Value}

law DepositValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node56()>
  for +a1: Maybe<&2, F.DepositDataValue()>
  for p0: Node56_preserves(o0, a0)
  for p1: DepositDataValue_preserves(o1, a1)
  DepositValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.DepositValue.assemble(a0, a1))
def DepositValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.DepositValue.to_value(F.Deposit{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.DepositValue.to_value(F.Deposit{v0, v1}) == T.Sequence{T.Items{F.Node56.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law DepositValue_sound:
  for +original: T.Value
  DepositValue_preserves(original, F.DepositValue.from_value(original))
def DepositValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: DepositValue_assemble_sound(o0, o1, F.Node56.from_value(o0), F.DepositDataValue.from_value(o1), Node56_sound(o0), DepositDataValue_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def DepositMessageValue_preserves(original: T.Value, result: Maybe<&2, F.DepositMessageValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.DepositMessageValue.to_value(value) == original : T.Value}

law DepositMessageValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: Node8_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  DepositMessageValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.DepositMessageValue.assemble(a0, a1, a2))
def DepositMessageValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.DepositMessageValue.to_value(F.DepositMessage{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.DepositMessageValue.to_value(F.DepositMessage{v0, v1, v2}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.DepositMessageValue.to_value(F.DepositMessage{v0, v1, v2}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law DepositMessageValue_sound:
  for +original: T.Value
  DepositMessageValue_preserves(original, F.DepositMessageValue.from_value(original))
def DepositMessageValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: DepositMessageValue_assemble_sound(o0, o1, o2, F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), Node8_sound(o0), Node7_sound(o1), Node3_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def ValidatorValue_preserves(original: T.Value, result: Maybe<&2, F.ValidatorValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ValidatorValue.to_value(value) == original : T.Value}

law ValidatorValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +o5: T.Value
  for +o6: T.Value
  for +o7: T.Value
  for +a0: Maybe<&2, F.Node8()>
  for +a1: Maybe<&2, F.Node7()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node0()>
  for +a4: Maybe<&2, F.Node3()>
  for +a5: Maybe<&2, F.Node3()>
  for +a6: Maybe<&2, F.Node3()>
  for +a7: Maybe<&2, F.Node3()>
  for p0: Node8_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: Node0_preserves(o3, a3)
  for p4: Node3_preserves(o4, a4)
  for p5: Node3_preserves(o5, a5)
  for p6: Node3_preserves(o6, a6)
  for p7: Node3_preserves(o7, a7)
  ValidatorValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}}, F.ValidatorValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7))
def ValidatorValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, a0, a1, a2, a3, a4, a5, a6, a7, p0, p1, p2, p3, p4, p5, p6, p7):
  match a0 a1 a2 a3 a4 a5 a6 a7:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7}:
      %p0 : {F.ValidatorValue.to_value(F.Validator{v0, v1, v2, v3, v4, v5, v6, v7}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}} : T.Value}
      %p1 : {F.ValidatorValue.to_value(F.Validator{v0, v1, v2, v3, v4, v5, v6, v7}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}} : T.Value}
      %p2 : {F.ValidatorValue.to_value(F.Validator{v0, v1, v2, v3, v4, v5, v6, v7}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}} : T.Value}
      %p3 : {F.ValidatorValue.to_value(F.Validator{v0, v1, v2, v3, v4, v5, v6, v7}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}} : T.Value}
      %p4 : {F.ValidatorValue.to_value(F.Validator{v0, v1, v2, v3, v4, v5, v6, v7}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.Node0.to_value(v3), T.Items{_, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}} : T.Value}
      %p5 : {F.ValidatorValue.to_value(F.Validator{v0, v1, v2, v3, v4, v5, v6, v7}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.Node0.to_value(v3), T.Items{F.Node3.to_value(v4), T.Items{_, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}} : T.Value}
      %p6 : {F.ValidatorValue.to_value(F.Validator{v0, v1, v2, v3, v4, v5, v6, v7}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.Node0.to_value(v3), T.Items{F.Node3.to_value(v4), T.Items{F.Node3.to_value(v5), T.Items{_, T.Items{o7, T.EmptyItems{}}}}}}}}}} : T.Value}
      %p7 : {F.ValidatorValue.to_value(F.Validator{v0, v1, v2, v3, v4, v5, v6, v7}) == T.Sequence{T.Items{F.Node8.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.Node0.to_value(v3), T.Items{F.Node3.to_value(v4), T.Items{F.Node3.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{_, T.EmptyItems{}}}}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{}: Unit{}

law ValidatorValue_sound:
  for +original: T.Value
  ValidatorValue_preserves(original, F.ValidatorValue.from_value(original))
def ValidatorValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}}: ValidatorValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, F.Node8.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.Node0.from_value(o3), F.Node3.from_value(o4), F.Node3.from_value(o5), F.Node3.from_value(o6), F.Node3.from_value(o7), Node8_sound(o0), Node7_sound(o1), Node3_sound(o2), Node0_sound(o3), Node3_sound(o4), Node3_sound(o5), Node3_sound(o6), Node3_sound(o7))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BooleanValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.UnsignedValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BytesValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BitsValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Sequence{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Selected{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.NullValue{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BooleanValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.UnsignedValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BytesValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BitsValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Sequence{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Selected{bad0, bad1}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.NullValue{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BooleanValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.UnsignedValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BytesValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BitsValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Sequence{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{bad0, bad1}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Selected{bad0, bad1}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.NullValue{}}}}}}}}}}: Unit{}

def Node59_preserves(original: T.Value, result: Maybe<&2, F.Node59()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node59.to_value(value) == original : T.Value}

def Node59_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node7()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node7.seq_to(values) == original : T.Value}

law Node59_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node7()>
  for +head: Maybe<&2, F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_preserves: Node7_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node7()> -> Node59_items_preserve(F.Node7.seq_to_go(a, t), next(a))
  Node59_items_preserve(F.Node7.seq_to_go(acc, T.Items{h, t}), F.Node7.seq_step(head, acc, next))
def Node59_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node59_items_preserve(F.Node7.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node59_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  Node59_items_preserve(F.Node7.seq_to_go(acc, original), F.Node7.seq_from_go(original, acc))
def Node59_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node7()>, T.Value, xs => F.Node7.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node7(), List.reverse(&2, F.Node7(), acc)), acc, Lists.reverse_twice(F.Node7(), acc))
    case T.Items{h, t}: Node59_step(h, t, acc, F.Node7.from_value(h), next => F.Node7.seq_from_go(t, next), Node7_sound(h), next => Node59_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node59_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node7()>>
  for preserved: Node59_items_preserve(original, result)
  Node59_preserves(T.Sequence{original}, result)
def Node59_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node7.seq_to(xs), original, preserved)

law Node59_sound:
  for +original: T.Value
  Node59_preserves(original, F.Node59.from_value(original))
def Node59_sound(original):
  match original:
    case T.Sequence{values}: Node59_sequence_sound(values, F.Node7.seq_from_go(values, []), Node59_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node60_preserves(original: T.Value, result: Maybe<&2, F.Node60()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node60.to_value(value) == original : T.Value}

law Node60_sound:
  for +original: T.Value
  Node60_preserves(original, F.Node60.from_value(original))
def Node60_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def ConsolidationRequestValue_preserves(original: T.Value, result: Maybe<&2, F.ConsolidationRequestValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ConsolidationRequestValue.to_value(value) == original : T.Value}

law ConsolidationRequestValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node11()>
  for +a1: Maybe<&2, F.Node8()>
  for +a2: Maybe<&2, F.Node8()>
  for p0: Node11_preserves(o0, a0)
  for p1: Node8_preserves(o1, a1)
  for p2: Node8_preserves(o2, a2)
  ConsolidationRequestValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.ConsolidationRequestValue.assemble(a0, a1, a2))
def ConsolidationRequestValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.ConsolidationRequestValue.to_value(F.ConsolidationRequest{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.ConsolidationRequestValue.to_value(F.ConsolidationRequest{v0, v1, v2}) == T.Sequence{T.Items{F.Node11.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.ConsolidationRequestValue.to_value(F.ConsolidationRequest{v0, v1, v2}) == T.Sequence{T.Items{F.Node11.to_value(v0), T.Items{F.Node8.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law ConsolidationRequestValue_sound:
  for +original: T.Value
  ConsolidationRequestValue_preserves(original, F.ConsolidationRequestValue.from_value(original))
def ConsolidationRequestValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: ConsolidationRequestValue_assemble_sound(o0, o1, o2, F.Node11.from_value(o0), F.Node8.from_value(o1), F.Node8.from_value(o2), Node11_sound(o0), Node8_sound(o1), Node8_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def WithdrawalRequestValue_preserves(original: T.Value, result: Maybe<&2, F.WithdrawalRequestValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.WithdrawalRequestValue.to_value(value) == original : T.Value}

law WithdrawalRequestValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node11()>
  for +a1: Maybe<&2, F.Node8()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: Node11_preserves(o0, a0)
  for p1: Node8_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  WithdrawalRequestValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.WithdrawalRequestValue.assemble(a0, a1, a2))
def WithdrawalRequestValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.WithdrawalRequestValue.to_value(F.WithdrawalRequest{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.WithdrawalRequestValue.to_value(F.WithdrawalRequest{v0, v1, v2}) == T.Sequence{T.Items{F.Node11.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.WithdrawalRequestValue.to_value(F.WithdrawalRequest{v0, v1, v2}) == T.Sequence{T.Items{F.Node11.to_value(v0), T.Items{F.Node8.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law WithdrawalRequestValue_sound:
  for +original: T.Value
  WithdrawalRequestValue_preserves(original, F.WithdrawalRequestValue.from_value(original))
def WithdrawalRequestValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: WithdrawalRequestValue_assemble_sound(o0, o1, o2, F.Node11.from_value(o0), F.Node8.from_value(o1), F.Node3.from_value(o2), Node11_sound(o0), Node8_sound(o1), Node3_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def Node64_preserves(original: T.Value, result: Maybe<&2, F.Node64()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node64.to_value(value) == original : T.Value}

def Node64_items_preserve(original: T.Value, result: Maybe<&2, +List<F.DepositRequestValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.DepositRequestValue.seq_to(values) == original : T.Value}

law Node64_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.DepositRequestValue()>
  for +head: Maybe<&2, F.DepositRequestValue()>
  for next: +List<F.DepositRequestValue()> -> Maybe<&2, +List<F.DepositRequestValue()>>
  for head_preserves: DepositRequestValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.DepositRequestValue()> -> Node64_items_preserve(F.DepositRequestValue.seq_to_go(a, t), next(a))
  Node64_items_preserve(F.DepositRequestValue.seq_to_go(acc, T.Items{h, t}), F.DepositRequestValue.seq_step(head, acc, next))
def Node64_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node64_items_preserve(F.DepositRequestValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node64_items_sound:
  for +original: T.Value
  for +acc: +List<F.DepositRequestValue()>
  Node64_items_preserve(F.DepositRequestValue.seq_to_go(acc, original), F.DepositRequestValue.seq_from_go(original, acc))
def Node64_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.DepositRequestValue()>, T.Value, xs => F.DepositRequestValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.DepositRequestValue(), List.reverse(&2, F.DepositRequestValue(), acc)), acc, Lists.reverse_twice(F.DepositRequestValue(), acc))
    case T.Items{h, t}: Node64_step(h, t, acc, F.DepositRequestValue.from_value(h), next => F.DepositRequestValue.seq_from_go(t, next), DepositRequestValue_sound(h), next => Node64_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node64_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.DepositRequestValue()>>
  for preserved: Node64_items_preserve(original, result)
  Node64_preserves(T.Sequence{original}, result)
def Node64_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.DepositRequestValue.seq_to(xs), original, preserved)

law Node64_sound:
  for +original: T.Value
  Node64_preserves(original, F.Node64.from_value(original))
def Node64_sound(original):
  match original:
    case T.Sequence{values}: Node64_sequence_sound(values, F.DepositRequestValue.seq_from_go(values, []), Node64_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node65_preserves(original: T.Value, result: Maybe<&2, F.Node65()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node65.to_value(value) == original : T.Value}

def Node65_items_preserve(original: T.Value, result: Maybe<&2, +List<F.WithdrawalRequestValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.WithdrawalRequestValue.seq_to(values) == original : T.Value}

law Node65_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.WithdrawalRequestValue()>
  for +head: Maybe<&2, F.WithdrawalRequestValue()>
  for next: +List<F.WithdrawalRequestValue()> -> Maybe<&2, +List<F.WithdrawalRequestValue()>>
  for head_preserves: WithdrawalRequestValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.WithdrawalRequestValue()> -> Node65_items_preserve(F.WithdrawalRequestValue.seq_to_go(a, t), next(a))
  Node65_items_preserve(F.WithdrawalRequestValue.seq_to_go(acc, T.Items{h, t}), F.WithdrawalRequestValue.seq_step(head, acc, next))
def Node65_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node65_items_preserve(F.WithdrawalRequestValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node65_items_sound:
  for +original: T.Value
  for +acc: +List<F.WithdrawalRequestValue()>
  Node65_items_preserve(F.WithdrawalRequestValue.seq_to_go(acc, original), F.WithdrawalRequestValue.seq_from_go(original, acc))
def Node65_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.WithdrawalRequestValue()>, T.Value, xs => F.WithdrawalRequestValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.WithdrawalRequestValue(), List.reverse(&2, F.WithdrawalRequestValue(), acc)), acc, Lists.reverse_twice(F.WithdrawalRequestValue(), acc))
    case T.Items{h, t}: Node65_step(h, t, acc, F.WithdrawalRequestValue.from_value(h), next => F.WithdrawalRequestValue.seq_from_go(t, next), WithdrawalRequestValue_sound(h), next => Node65_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node65_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.WithdrawalRequestValue()>>
  for preserved: Node65_items_preserve(original, result)
  Node65_preserves(T.Sequence{original}, result)
def Node65_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.WithdrawalRequestValue.seq_to(xs), original, preserved)

law Node65_sound:
  for +original: T.Value
  Node65_preserves(original, F.Node65.from_value(original))
def Node65_sound(original):
  match original:
    case T.Sequence{values}: Node65_sequence_sound(values, F.WithdrawalRequestValue.seq_from_go(values, []), Node65_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node66_preserves(original: T.Value, result: Maybe<&2, F.Node66()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node66.to_value(value) == original : T.Value}

def Node66_items_preserve(original: T.Value, result: Maybe<&2, +List<F.ConsolidationRequestValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.ConsolidationRequestValue.seq_to(values) == original : T.Value}

law Node66_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.ConsolidationRequestValue()>
  for +head: Maybe<&2, F.ConsolidationRequestValue()>
  for next: +List<F.ConsolidationRequestValue()> -> Maybe<&2, +List<F.ConsolidationRequestValue()>>
  for head_preserves: ConsolidationRequestValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.ConsolidationRequestValue()> -> Node66_items_preserve(F.ConsolidationRequestValue.seq_to_go(a, t), next(a))
  Node66_items_preserve(F.ConsolidationRequestValue.seq_to_go(acc, T.Items{h, t}), F.ConsolidationRequestValue.seq_step(head, acc, next))
def Node66_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node66_items_preserve(F.ConsolidationRequestValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node66_items_sound:
  for +original: T.Value
  for +acc: +List<F.ConsolidationRequestValue()>
  Node66_items_preserve(F.ConsolidationRequestValue.seq_to_go(acc, original), F.ConsolidationRequestValue.seq_from_go(original, acc))
def Node66_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.ConsolidationRequestValue()>, T.Value, xs => F.ConsolidationRequestValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.ConsolidationRequestValue(), List.reverse(&2, F.ConsolidationRequestValue(), acc)), acc, Lists.reverse_twice(F.ConsolidationRequestValue(), acc))
    case T.Items{h, t}: Node66_step(h, t, acc, F.ConsolidationRequestValue.from_value(h), next => F.ConsolidationRequestValue.seq_from_go(t, next), ConsolidationRequestValue_sound(h), next => Node66_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node66_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.ConsolidationRequestValue()>>
  for preserved: Node66_items_preserve(original, result)
  Node66_preserves(T.Sequence{original}, result)
def Node66_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.ConsolidationRequestValue.seq_to(xs), original, preserved)

law Node66_sound:
  for +original: T.Value
  Node66_preserves(original, F.Node66.from_value(original))
def Node66_sound(original):
  match original:
    case T.Sequence{values}: Node66_sequence_sound(values, F.ConsolidationRequestValue.seq_from_go(values, []), Node66_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def ExecutionRequestsValue_preserves(original: T.Value, result: Maybe<&2, F.ExecutionRequestsValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ExecutionRequestsValue.to_value(value) == original : T.Value}

law ExecutionRequestsValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node64()>
  for +a1: Maybe<&2, F.Node65()>
  for +a2: Maybe<&2, F.Node66()>
  for p0: Node64_preserves(o0, a0)
  for p1: Node65_preserves(o1, a1)
  for p2: Node66_preserves(o2, a2)
  ExecutionRequestsValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.ExecutionRequestsValue.assemble(a0, a1, a2))
def ExecutionRequestsValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.ExecutionRequestsValue.to_value(F.ExecutionRequests{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.ExecutionRequestsValue.to_value(F.ExecutionRequests{v0, v1, v2}) == T.Sequence{T.Items{F.Node64.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.ExecutionRequestsValue.to_value(F.ExecutionRequests{v0, v1, v2}) == T.Sequence{T.Items{F.Node64.to_value(v0), T.Items{F.Node65.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law ExecutionRequestsValue_sound:
  for +original: T.Value
  ExecutionRequestsValue_preserves(original, F.ExecutionRequestsValue.from_value(original))
def ExecutionRequestsValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: ExecutionRequestsValue_assemble_sound(o0, o1, o2, F.Node64.from_value(o0), F.Node65.from_value(o1), F.Node66.from_value(o2), Node64_sound(o0), Node65_sound(o1), Node66_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def BLSToExecutionChangeValue_preserves(original: T.Value, result: Maybe<&2, F.BLSToExecutionChangeValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.BLSToExecutionChangeValue.to_value(value) == original : T.Value}

law BLSToExecutionChangeValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node8()>
  for +a2: Maybe<&2, F.Node11()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node8_preserves(o1, a1)
  for p2: Node11_preserves(o2, a2)
  BLSToExecutionChangeValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.BLSToExecutionChangeValue.assemble(a0, a1, a2))
def BLSToExecutionChangeValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.BLSToExecutionChangeValue.to_value(F.BLSToExecutionChange{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.BLSToExecutionChangeValue.to_value(F.BLSToExecutionChange{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.BLSToExecutionChangeValue.to_value(F.BLSToExecutionChange{v0, v1, v2}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node8.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law BLSToExecutionChangeValue_sound:
  for +original: T.Value
  BLSToExecutionChangeValue_preserves(original, F.BLSToExecutionChangeValue.from_value(original))
def BLSToExecutionChangeValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: BLSToExecutionChangeValue_assemble_sound(o0, o1, o2, F.Node3.from_value(o0), F.Node8.from_value(o1), F.Node11.from_value(o2), Node3_sound(o0), Node8_sound(o1), Node11_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def SignedBLSToExecutionChangeValue_preserves(original: T.Value, result: Maybe<&2, F.SignedBLSToExecutionChangeValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SignedBLSToExecutionChangeValue.to_value(value) == original : T.Value}

law SignedBLSToExecutionChangeValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.BLSToExecutionChangeValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: BLSToExecutionChangeValue_preserves(o0, a0)
  for p1: Node9_preserves(o1, a1)
  SignedBLSToExecutionChangeValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SignedBLSToExecutionChangeValue.assemble(a0, a1))
def SignedBLSToExecutionChangeValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SignedBLSToExecutionChangeValue.to_value(F.SignedBLSToExecutionChange{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SignedBLSToExecutionChangeValue.to_value(F.SignedBLSToExecutionChange{v0, v1}) == T.Sequence{T.Items{F.BLSToExecutionChangeValue.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SignedBLSToExecutionChangeValue_sound:
  for +original: T.Value
  SignedBLSToExecutionChangeValue_preserves(original, F.SignedBLSToExecutionChangeValue.from_value(original))
def SignedBLSToExecutionChangeValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SignedBLSToExecutionChangeValue_assemble_sound(o0, o1, F.BLSToExecutionChangeValue.from_value(o0), F.Node9.from_value(o1), BLSToExecutionChangeValue_sound(o0), Node9_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def Node70_preserves(original: T.Value, result: Maybe<&2, F.Node70()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node70.to_value(value) == original : T.Value}

law Node70_sound:
  for +original: T.Value
  Node70_preserves(original, F.Node70.from_value(original))
def Node70_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node71_preserves(original: T.Value, result: Maybe<&2, F.Node71()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node71.to_value(value) == original : T.Value}

law Node71_sound:
  for +original: T.Value
  Node71_preserves(original, F.Node71.from_value(original))
def Node71_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def ExecutionPayloadHeaderValue_preserves(original: T.Value, result: Maybe<&2, F.ExecutionPayloadHeaderValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ExecutionPayloadHeaderValue.to_value(value) == original : T.Value}

law ExecutionPayloadHeaderValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +o5: T.Value
  for +o6: T.Value
  for +o7: T.Value
  for +o8: T.Value
  for +o9: T.Value
  for +o10: T.Value
  for +o11: T.Value
  for +o12: T.Value
  for +o13: T.Value
  for +o14: T.Value
  for +o15: T.Value
  for +o16: T.Value
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
  for p0: Node7_preserves(o0, a0)
  for p1: Node11_preserves(o1, a1)
  for p2: Node7_preserves(o2, a2)
  for p3: Node7_preserves(o3, a3)
  for p4: Node70_preserves(o4, a4)
  for p5: Node7_preserves(o5, a5)
  for p6: Node3_preserves(o6, a6)
  for p7: Node3_preserves(o7, a7)
  for p8: Node3_preserves(o8, a8)
  for p9: Node3_preserves(o9, a9)
  for p10: Node71_preserves(o10, a10)
  for p11: Node4_preserves(o11, a11)
  for p12: Node7_preserves(o12, a12)
  for p13: Node7_preserves(o13, a13)
  for p14: Node7_preserves(o14, a14)
  for p15: Node3_preserves(o15, a15)
  for p16: Node3_preserves(o16, a16)
  ExecutionPayloadHeaderValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}}, F.ExecutionPayloadHeaderValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16))
def ExecutionPayloadHeaderValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16):
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16}:
      %p0 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p1 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p2 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p3 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{_, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p4 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{_, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p5 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{_, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p6 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{_, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p7 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{_, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p8 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{_, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p9 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{_, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p10 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{_, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p11 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{_, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p12 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{_, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p13 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{F.Node7.to_value(v12), T.Items{_, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p14 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{F.Node7.to_value(v12), T.Items{F.Node7.to_value(v13), T.Items{_, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p15 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{F.Node7.to_value(v12), T.Items{F.Node7.to_value(v13), T.Items{F.Node7.to_value(v14), T.Items{_, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p16 : {F.ExecutionPayloadHeaderValue.to_value(F.ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{F.Node7.to_value(v12), T.Items{F.Node7.to_value(v13), T.Items{F.Node7.to_value(v14), T.Items{F.Node3.to_value(v15), T.Items{_, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{} _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} None{} _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} None{} _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} None{} _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} None{} _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} None{} _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} None{}: Unit{}

law ExecutionPayloadHeaderValue_sound:
  for +original: T.Value
  ExecutionPayloadHeaderValue_preserves(original, F.ExecutionPayloadHeaderValue.from_value(original))
def ExecutionPayloadHeaderValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}}: ExecutionPayloadHeaderValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, F.Node7.from_value(o0), F.Node11.from_value(o1), F.Node7.from_value(o2), F.Node7.from_value(o3), F.Node70.from_value(o4), F.Node7.from_value(o5), F.Node3.from_value(o6), F.Node3.from_value(o7), F.Node3.from_value(o8), F.Node3.from_value(o9), F.Node71.from_value(o10), F.Node4.from_value(o11), F.Node7.from_value(o12), F.Node7.from_value(o13), F.Node7.from_value(o14), F.Node3.from_value(o15), F.Node3.from_value(o16), Node7_sound(o0), Node11_sound(o1), Node7_sound(o2), Node7_sound(o3), Node70_sound(o4), Node7_sound(o5), Node3_sound(o6), Node3_sound(o7), Node3_sound(o8), Node3_sound(o9), Node71_sound(o10), Node4_sound(o11), Node7_sound(o12), Node7_sound(o13), Node7_sound(o14), Node3_sound(o15), Node3_sound(o16))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BooleanValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.UnsignedValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BytesValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BitsValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Sequence{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Selected{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.NullValue{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BooleanValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.UnsignedValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BytesValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BitsValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Sequence{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Selected{bad0, bad1}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.NullValue{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BooleanValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.UnsignedValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BytesValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BitsValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Sequence{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Selected{bad0, bad1}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.NullValue{}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BooleanValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.UnsignedValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BytesValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BitsValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Sequence{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.EmptyItems{}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Selected{bad0, bad1}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.NullValue{}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BooleanValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.UnsignedValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BytesValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BitsValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Sequence{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.EmptyItems{}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Selected{bad0, bad1}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.NullValue{}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BooleanValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.UnsignedValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BytesValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BitsValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Sequence{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.EmptyItems{}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Selected{bad0, bad1}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.NullValue{}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BooleanValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.UnsignedValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BytesValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BitsValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Sequence{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.EmptyItems{}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Selected{bad0, bad1}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.NullValue{}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BooleanValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.UnsignedValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BytesValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BitsValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Sequence{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Selected{bad0, bad1}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.NullValue{}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BooleanValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BytesValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BitsValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Sequence{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.EmptyItems{}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.NullValue{}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BytesValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BitsValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Sequence{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.EmptyItems{}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.NullValue{}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Sequence{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.EmptyItems{}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.NullValue{}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{bad0, bad1}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.NullValue{}}}}}}}}}}}}}}}}}}}: Unit{}

def WithdrawalValue_preserves(original: T.Value, result: Maybe<&2, F.WithdrawalValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.WithdrawalValue.to_value(value) == original : T.Value}

law WithdrawalValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node11()>
  for +a3: Maybe<&2, F.Node3()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  for p2: Node11_preserves(o2, a2)
  for p3: Node3_preserves(o3, a3)
  WithdrawalValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}, F.WithdrawalValue.assemble(a0, a1, a2, a3))
def WithdrawalValue_assemble_sound(o0, o1, o2, o3, a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}:
      %p0 : {F.WithdrawalValue.to_value(F.Withdrawal{v0, v1, v2, v3}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p1 : {F.WithdrawalValue.to_value(F.Withdrawal{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p2 : {F.WithdrawalValue.to_value(F.Withdrawal{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{_, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p3 : {F.WithdrawalValue.to_value(F.Withdrawal{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{F.Node11.to_value(v2), T.Items{_, T.EmptyItems{}}}}}} : T.Value}
      {==}
    case None{} _ _ _: Unit{}
    case Some{v0} None{} _ _: Unit{}
    case Some{v0} Some{v1} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{}: Unit{}

law WithdrawalValue_sound:
  for +original: T.Value
  WithdrawalValue_preserves(original, F.WithdrawalValue.from_value(original))
def WithdrawalValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: WithdrawalValue_assemble_sound(o0, o1, o2, o3, F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node11.from_value(o2), F.Node3.from_value(o3), Node3_sound(o0), Node3_sound(o1), Node11_sound(o2), Node3_sound(o3))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}

def Node74_preserves(original: T.Value, result: Maybe<&2, F.Node74()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node74.to_value(value) == original : T.Value}

def Node74_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node60()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node60.seq_to(values) == original : T.Value}

law Node74_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node60()>
  for +head: Maybe<&2, F.Node60()>
  for next: +List<F.Node60()> -> Maybe<&2, +List<F.Node60()>>
  for head_preserves: Node60_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node60()> -> Node74_items_preserve(F.Node60.seq_to_go(a, t), next(a))
  Node74_items_preserve(F.Node60.seq_to_go(acc, T.Items{h, t}), F.Node60.seq_step(head, acc, next))
def Node74_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node74_items_preserve(F.Node60.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node74_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node60()>
  Node74_items_preserve(F.Node60.seq_to_go(acc, original), F.Node60.seq_from_go(original, acc))
def Node74_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node60()>, T.Value, xs => F.Node60.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node60(), List.reverse(&2, F.Node60(), acc)), acc, Lists.reverse_twice(F.Node60(), acc))
    case T.Items{h, t}: Node74_step(h, t, acc, F.Node60.from_value(h), next => F.Node60.seq_from_go(t, next), Node60_sound(h), next => Node74_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node74_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node60()>>
  for preserved: Node74_items_preserve(original, result)
  Node74_preserves(T.Sequence{original}, result)
def Node74_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node60.seq_to(xs), original, preserved)

law Node74_sound:
  for +original: T.Value
  Node74_preserves(original, F.Node74.from_value(original))
def Node74_sound(original):
  match original:
    case T.Sequence{values}: Node74_sequence_sound(values, F.Node60.seq_from_go(values, []), Node74_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node75_preserves(original: T.Value, result: Maybe<&2, F.Node75()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node75.to_value(value) == original : T.Value}

def Node75_items_preserve(original: T.Value, result: Maybe<&2, +List<F.WithdrawalValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.WithdrawalValue.seq_to(values) == original : T.Value}

law Node75_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.WithdrawalValue()>
  for +head: Maybe<&2, F.WithdrawalValue()>
  for next: +List<F.WithdrawalValue()> -> Maybe<&2, +List<F.WithdrawalValue()>>
  for head_preserves: WithdrawalValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.WithdrawalValue()> -> Node75_items_preserve(F.WithdrawalValue.seq_to_go(a, t), next(a))
  Node75_items_preserve(F.WithdrawalValue.seq_to_go(acc, T.Items{h, t}), F.WithdrawalValue.seq_step(head, acc, next))
def Node75_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node75_items_preserve(F.WithdrawalValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node75_items_sound:
  for +original: T.Value
  for +acc: +List<F.WithdrawalValue()>
  Node75_items_preserve(F.WithdrawalValue.seq_to_go(acc, original), F.WithdrawalValue.seq_from_go(original, acc))
def Node75_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.WithdrawalValue()>, T.Value, xs => F.WithdrawalValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.WithdrawalValue(), List.reverse(&2, F.WithdrawalValue(), acc)), acc, Lists.reverse_twice(F.WithdrawalValue(), acc))
    case T.Items{h, t}: Node75_step(h, t, acc, F.WithdrawalValue.from_value(h), next => F.WithdrawalValue.seq_from_go(t, next), WithdrawalValue_sound(h), next => Node75_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node75_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.WithdrawalValue()>>
  for preserved: Node75_items_preserve(original, result)
  Node75_preserves(T.Sequence{original}, result)
def Node75_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.WithdrawalValue.seq_to(xs), original, preserved)

law Node75_sound:
  for +original: T.Value
  Node75_preserves(original, F.Node75.from_value(original))
def Node75_sound(original):
  match original:
    case T.Sequence{values}: Node75_sequence_sound(values, F.WithdrawalValue.seq_from_go(values, []), Node75_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def ExecutionPayloadValue_preserves(original: T.Value, result: Maybe<&2, F.ExecutionPayloadValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.ExecutionPayloadValue.to_value(value) == original : T.Value}

law ExecutionPayloadValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +o5: T.Value
  for +o6: T.Value
  for +o7: T.Value
  for +o8: T.Value
  for +o9: T.Value
  for +o10: T.Value
  for +o11: T.Value
  for +o12: T.Value
  for +o13: T.Value
  for +o14: T.Value
  for +o15: T.Value
  for +o16: T.Value
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
  for p0: Node7_preserves(o0, a0)
  for p1: Node11_preserves(o1, a1)
  for p2: Node7_preserves(o2, a2)
  for p3: Node7_preserves(o3, a3)
  for p4: Node70_preserves(o4, a4)
  for p5: Node7_preserves(o5, a5)
  for p6: Node3_preserves(o6, a6)
  for p7: Node3_preserves(o7, a7)
  for p8: Node3_preserves(o8, a8)
  for p9: Node3_preserves(o9, a9)
  for p10: Node71_preserves(o10, a10)
  for p11: Node4_preserves(o11, a11)
  for p12: Node7_preserves(o12, a12)
  for p13: Node74_preserves(o13, a13)
  for p14: Node75_preserves(o14, a14)
  for p15: Node3_preserves(o15, a15)
  for p16: Node3_preserves(o16, a16)
  ExecutionPayloadValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}}, F.ExecutionPayloadValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16))
def ExecutionPayloadValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16):
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16}:
      %p0 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p1 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p2 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p3 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{_, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p4 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{_, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p5 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{_, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p6 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{_, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p7 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{_, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p8 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{_, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p9 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{_, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p10 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{_, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p11 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{_, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p12 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{_, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p13 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{F.Node7.to_value(v12), T.Items{_, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p14 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{F.Node7.to_value(v12), T.Items{F.Node74.to_value(v13), T.Items{_, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p15 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{F.Node7.to_value(v12), T.Items{F.Node74.to_value(v13), T.Items{F.Node75.to_value(v14), T.Items{_, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      %p16 : {F.ExecutionPayloadValue.to_value(F.ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{F.Node11.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{F.Node70.to_value(v4), T.Items{F.Node7.to_value(v5), T.Items{F.Node3.to_value(v6), T.Items{F.Node3.to_value(v7), T.Items{F.Node3.to_value(v8), T.Items{F.Node3.to_value(v9), T.Items{F.Node71.to_value(v10), T.Items{F.Node4.to_value(v11), T.Items{F.Node7.to_value(v12), T.Items{F.Node74.to_value(v13), T.Items{F.Node75.to_value(v14), T.Items{F.Node3.to_value(v15), T.Items{_, T.EmptyItems{}}}}}}}}}}}}}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{} _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} None{} _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} None{} _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} None{} _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} None{} _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} None{} _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} None{}: Unit{}

law ExecutionPayloadValue_sound:
  for +original: T.Value
  ExecutionPayloadValue_preserves(original, F.ExecutionPayloadValue.from_value(original))
def ExecutionPayloadValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}}: ExecutionPayloadValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, F.Node7.from_value(o0), F.Node11.from_value(o1), F.Node7.from_value(o2), F.Node7.from_value(o3), F.Node70.from_value(o4), F.Node7.from_value(o5), F.Node3.from_value(o6), F.Node3.from_value(o7), F.Node3.from_value(o8), F.Node3.from_value(o9), F.Node71.from_value(o10), F.Node4.from_value(o11), F.Node7.from_value(o12), F.Node74.from_value(o13), F.Node75.from_value(o14), F.Node3.from_value(o15), F.Node3.from_value(o16), Node7_sound(o0), Node11_sound(o1), Node7_sound(o2), Node7_sound(o3), Node70_sound(o4), Node7_sound(o5), Node3_sound(o6), Node3_sound(o7), Node3_sound(o8), Node3_sound(o9), Node71_sound(o10), Node4_sound(o11), Node7_sound(o12), Node74_sound(o13), Node75_sound(o14), Node3_sound(o15), Node3_sound(o16))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BooleanValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.UnsignedValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BytesValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BitsValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Sequence{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Selected{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.NullValue{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BooleanValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.UnsignedValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BytesValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BitsValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Sequence{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Selected{bad0, bad1}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.NullValue{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BooleanValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.UnsignedValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BytesValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BitsValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Sequence{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Selected{bad0, bad1}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.NullValue{}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BooleanValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.UnsignedValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BytesValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BitsValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Sequence{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.EmptyItems{}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Selected{bad0, bad1}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.NullValue{}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BooleanValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.UnsignedValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BytesValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BitsValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Sequence{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.EmptyItems{}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Selected{bad0, bad1}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.NullValue{}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BooleanValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.UnsignedValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BytesValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BitsValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Sequence{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.EmptyItems{}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Selected{bad0, bad1}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.NullValue{}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BooleanValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.UnsignedValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BytesValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BitsValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Sequence{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.EmptyItems{}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Selected{bad0, bad1}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.NullValue{}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BooleanValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.UnsignedValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BytesValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BitsValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Sequence{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Selected{bad0, bad1}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.NullValue{}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BooleanValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BytesValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BitsValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Sequence{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.EmptyItems{}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.NullValue{}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BytesValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BitsValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Sequence{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.EmptyItems{}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.NullValue{}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Sequence{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.EmptyItems{}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.NullValue{}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{bad0, bad1}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.NullValue{}}}}}}}}}}}}}}}}}}}: Unit{}

def Node77_preserves(original: T.Value, result: Maybe<&2, F.Node77()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node77.to_value(value) == original : T.Value}

def Node77_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node7()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node7.seq_to(values) == original : T.Value}

law Node77_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node7()>
  for +head: Maybe<&2, F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_preserves: Node7_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node7()> -> Node77_items_preserve(F.Node7.seq_to_go(a, t), next(a))
  Node77_items_preserve(F.Node7.seq_to_go(acc, T.Items{h, t}), F.Node7.seq_step(head, acc, next))
def Node77_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node77_items_preserve(F.Node7.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node77_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  Node77_items_preserve(F.Node7.seq_to_go(acc, original), F.Node7.seq_from_go(original, acc))
def Node77_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node7()>, T.Value, xs => F.Node7.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node7(), List.reverse(&2, F.Node7(), acc)), acc, Lists.reverse_twice(F.Node7(), acc))
    case T.Items{h, t}: Node77_step(h, t, acc, F.Node7.from_value(h), next => F.Node7.seq_from_go(t, next), Node7_sound(h), next => Node77_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node77_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node7()>>
  for preserved: Node77_items_preserve(original, result)
  Node77_preserves(T.Sequence{original}, result)
def Node77_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node7.seq_to(xs), original, preserved)

law Node77_sound:
  for +original: T.Value
  Node77_preserves(original, F.Node77.from_value(original))
def Node77_sound(original):
  match original:
    case T.Sequence{values}: Node77_sequence_sound(values, F.Node7.seq_from_go(values, []), Node77_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node78_preserves(original: T.Value, result: Maybe<&2, F.Node78()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node78.to_value(value) == original : T.Value}

def Node78_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Eth1DataValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Eth1DataValue.seq_to(values) == original : T.Value}

law Node78_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Eth1DataValue()>
  for +head: Maybe<&2, F.Eth1DataValue()>
  for next: +List<F.Eth1DataValue()> -> Maybe<&2, +List<F.Eth1DataValue()>>
  for head_preserves: Eth1DataValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.Eth1DataValue()> -> Node78_items_preserve(F.Eth1DataValue.seq_to_go(a, t), next(a))
  Node78_items_preserve(F.Eth1DataValue.seq_to_go(acc, T.Items{h, t}), F.Eth1DataValue.seq_step(head, acc, next))
def Node78_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node78_items_preserve(F.Eth1DataValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node78_items_sound:
  for +original: T.Value
  for +acc: +List<F.Eth1DataValue()>
  Node78_items_preserve(F.Eth1DataValue.seq_to_go(acc, original), F.Eth1DataValue.seq_from_go(original, acc))
def Node78_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Eth1DataValue()>, T.Value, xs => F.Eth1DataValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Eth1DataValue(), List.reverse(&2, F.Eth1DataValue(), acc)), acc, Lists.reverse_twice(F.Eth1DataValue(), acc))
    case T.Items{h, t}: Node78_step(h, t, acc, F.Eth1DataValue.from_value(h), next => F.Eth1DataValue.seq_from_go(t, next), Eth1DataValue_sound(h), next => Node78_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node78_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Eth1DataValue()>>
  for preserved: Node78_items_preserve(original, result)
  Node78_preserves(T.Sequence{original}, result)
def Node78_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Eth1DataValue.seq_to(xs), original, preserved)

law Node78_sound:
  for +original: T.Value
  Node78_preserves(original, F.Node78.from_value(original))
def Node78_sound(original):
  match original:
    case T.Sequence{values}: Node78_sequence_sound(values, F.Eth1DataValue.seq_from_go(values, []), Node78_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node79_preserves(original: T.Value, result: Maybe<&2, F.Node79()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node79.to_value(value) == original : T.Value}

def Node79_items_preserve(original: T.Value, result: Maybe<&2, +List<F.ValidatorValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.ValidatorValue.seq_to(values) == original : T.Value}

law Node79_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.ValidatorValue()>
  for +head: Maybe<&2, F.ValidatorValue()>
  for next: +List<F.ValidatorValue()> -> Maybe<&2, +List<F.ValidatorValue()>>
  for head_preserves: ValidatorValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.ValidatorValue()> -> Node79_items_preserve(F.ValidatorValue.seq_to_go(a, t), next(a))
  Node79_items_preserve(F.ValidatorValue.seq_to_go(acc, T.Items{h, t}), F.ValidatorValue.seq_step(head, acc, next))
def Node79_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node79_items_preserve(F.ValidatorValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node79_items_sound:
  for +original: T.Value
  for +acc: +List<F.ValidatorValue()>
  Node79_items_preserve(F.ValidatorValue.seq_to_go(acc, original), F.ValidatorValue.seq_from_go(original, acc))
def Node79_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.ValidatorValue()>, T.Value, xs => F.ValidatorValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.ValidatorValue(), List.reverse(&2, F.ValidatorValue(), acc)), acc, Lists.reverse_twice(F.ValidatorValue(), acc))
    case T.Items{h, t}: Node79_step(h, t, acc, F.ValidatorValue.from_value(h), next => F.ValidatorValue.seq_from_go(t, next), ValidatorValue_sound(h), next => Node79_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node79_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.ValidatorValue()>>
  for preserved: Node79_items_preserve(original, result)
  Node79_preserves(T.Sequence{original}, result)
def Node79_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.ValidatorValue.seq_to(xs), original, preserved)

law Node79_sound:
  for +original: T.Value
  Node79_preserves(original, F.Node79.from_value(original))
def Node79_sound(original):
  match original:
    case T.Sequence{values}: Node79_sequence_sound(values, F.ValidatorValue.seq_from_go(values, []), Node79_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node80_preserves(original: T.Value, result: Maybe<&2, F.Node80()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node80.to_value(value) == original : T.Value}

def Node80_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node3()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node3.seq_to(values) == original : T.Value}

law Node80_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node3()>
  for +head: Maybe<&2, F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_preserves: Node3_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node3()> -> Node80_items_preserve(F.Node3.seq_to_go(a, t), next(a))
  Node80_items_preserve(F.Node3.seq_to_go(acc, T.Items{h, t}), F.Node3.seq_step(head, acc, next))
def Node80_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node80_items_preserve(F.Node3.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node80_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  Node80_items_preserve(F.Node3.seq_to_go(acc, original), F.Node3.seq_from_go(original, acc))
def Node80_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node3()>, T.Value, xs => F.Node3.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node3(), List.reverse(&2, F.Node3(), acc)), acc, Lists.reverse_twice(F.Node3(), acc))
    case T.Items{h, t}: Node80_step(h, t, acc, F.Node3.from_value(h), next => F.Node3.seq_from_go(t, next), Node3_sound(h), next => Node80_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node80_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node3()>>
  for preserved: Node80_items_preserve(original, result)
  Node80_preserves(T.Sequence{original}, result)
def Node80_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node3.seq_to(xs), original, preserved)

law Node80_sound:
  for +original: T.Value
  Node80_preserves(original, F.Node80.from_value(original))
def Node80_sound(original):
  match original:
    case T.Sequence{values}: Node80_sequence_sound(values, F.Node3.seq_from_go(values, []), Node80_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node81_preserves(original: T.Value, result: Maybe<&2, F.Node81()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node81.to_value(value) == original : T.Value}

def Node81_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node7()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node7.seq_to(values) == original : T.Value}

law Node81_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node7()>
  for +head: Maybe<&2, F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_preserves: Node7_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node7()> -> Node81_items_preserve(F.Node7.seq_to_go(a, t), next(a))
  Node81_items_preserve(F.Node7.seq_to_go(acc, T.Items{h, t}), F.Node7.seq_step(head, acc, next))
def Node81_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node81_items_preserve(F.Node7.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node81_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  Node81_items_preserve(F.Node7.seq_to_go(acc, original), F.Node7.seq_from_go(original, acc))
def Node81_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node7()>, T.Value, xs => F.Node7.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node7(), List.reverse(&2, F.Node7(), acc)), acc, Lists.reverse_twice(F.Node7(), acc))
    case T.Items{h, t}: Node81_step(h, t, acc, F.Node7.from_value(h), next => F.Node7.seq_from_go(t, next), Node7_sound(h), next => Node81_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node81_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node7()>>
  for preserved: Node81_items_preserve(original, result)
  Node81_preserves(T.Sequence{original}, result)
def Node81_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node7.seq_to(xs), original, preserved)

law Node81_sound:
  for +original: T.Value
  Node81_preserves(original, F.Node81.from_value(original))
def Node81_sound(original):
  match original:
    case T.Sequence{values}: Node81_sequence_sound(values, F.Node7.seq_from_go(values, []), Node81_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node82_preserves(original: T.Value, result: Maybe<&2, F.Node82()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node82.to_value(value) == original : T.Value}

def Node82_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node3()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node3.seq_to(values) == original : T.Value}

law Node82_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node3()>
  for +head: Maybe<&2, F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_preserves: Node3_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node3()> -> Node82_items_preserve(F.Node3.seq_to_go(a, t), next(a))
  Node82_items_preserve(F.Node3.seq_to_go(acc, T.Items{h, t}), F.Node3.seq_step(head, acc, next))
def Node82_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node82_items_preserve(F.Node3.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node82_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  Node82_items_preserve(F.Node3.seq_to_go(acc, original), F.Node3.seq_from_go(original, acc))
def Node82_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node3()>, T.Value, xs => F.Node3.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node3(), List.reverse(&2, F.Node3(), acc)), acc, Lists.reverse_twice(F.Node3(), acc))
    case T.Items{h, t}: Node82_step(h, t, acc, F.Node3.from_value(h), next => F.Node3.seq_from_go(t, next), Node3_sound(h), next => Node82_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node82_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node3()>>
  for preserved: Node82_items_preserve(original, result)
  Node82_preserves(T.Sequence{original}, result)
def Node82_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node3.seq_to(xs), original, preserved)

law Node82_sound:
  for +original: T.Value
  Node82_preserves(original, F.Node82.from_value(original))
def Node82_sound(original):
  match original:
    case T.Sequence{values}: Node82_sequence_sound(values, F.Node3.seq_from_go(values, []), Node82_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node83_preserves(original: T.Value, result: Maybe<&2, F.Node83()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node83.to_value(value) == original : T.Value}

def Node83_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node1()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node1.seq_to(values) == original : T.Value}

law Node83_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node1()>
  for +head: Maybe<&2, F.Node1()>
  for next: +List<F.Node1()> -> Maybe<&2, +List<F.Node1()>>
  for head_preserves: Node1_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node1()> -> Node83_items_preserve(F.Node1.seq_to_go(a, t), next(a))
  Node83_items_preserve(F.Node1.seq_to_go(acc, T.Items{h, t}), F.Node1.seq_step(head, acc, next))
def Node83_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node83_items_preserve(F.Node1.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node83_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node1()>
  Node83_items_preserve(F.Node1.seq_to_go(acc, original), F.Node1.seq_from_go(original, acc))
def Node83_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node1()>, T.Value, xs => F.Node1.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node1(), List.reverse(&2, F.Node1(), acc)), acc, Lists.reverse_twice(F.Node1(), acc))
    case T.Items{h, t}: Node83_step(h, t, acc, F.Node1.from_value(h), next => F.Node1.seq_from_go(t, next), Node1_sound(h), next => Node83_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node83_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node1()>>
  for preserved: Node83_items_preserve(original, result)
  Node83_preserves(T.Sequence{original}, result)
def Node83_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node1.seq_to(xs), original, preserved)

law Node83_sound:
  for +original: T.Value
  Node83_preserves(original, F.Node83.from_value(original))
def Node83_sound(original):
  match original:
    case T.Sequence{values}: Node83_sequence_sound(values, F.Node1.seq_from_go(values, []), Node83_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node84_preserves(original: T.Value, result: Maybe<&2, F.Node84()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node84.to_value(value) == original : T.Value}

law Node84_sound:
  for +original: T.Value
  Node84_preserves(original, F.Node84.from_value(original))
def Node84_sound(original):
  match original:
    case T.BitsValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node85_preserves(original: T.Value, result: Maybe<&2, F.Node85()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node85.to_value(value) == original : T.Value}

def Node85_items_preserve(original: T.Value, result: Maybe<&2, +List<F.HistoricalSummaryValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.HistoricalSummaryValue.seq_to(values) == original : T.Value}

law Node85_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.HistoricalSummaryValue()>
  for +head: Maybe<&2, F.HistoricalSummaryValue()>
  for next: +List<F.HistoricalSummaryValue()> -> Maybe<&2, +List<F.HistoricalSummaryValue()>>
  for head_preserves: HistoricalSummaryValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.HistoricalSummaryValue()> -> Node85_items_preserve(F.HistoricalSummaryValue.seq_to_go(a, t), next(a))
  Node85_items_preserve(F.HistoricalSummaryValue.seq_to_go(acc, T.Items{h, t}), F.HistoricalSummaryValue.seq_step(head, acc, next))
def Node85_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node85_items_preserve(F.HistoricalSummaryValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node85_items_sound:
  for +original: T.Value
  for +acc: +List<F.HistoricalSummaryValue()>
  Node85_items_preserve(F.HistoricalSummaryValue.seq_to_go(acc, original), F.HistoricalSummaryValue.seq_from_go(original, acc))
def Node85_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.HistoricalSummaryValue()>, T.Value, xs => F.HistoricalSummaryValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.HistoricalSummaryValue(), List.reverse(&2, F.HistoricalSummaryValue(), acc)), acc, Lists.reverse_twice(F.HistoricalSummaryValue(), acc))
    case T.Items{h, t}: Node85_step(h, t, acc, F.HistoricalSummaryValue.from_value(h), next => F.HistoricalSummaryValue.seq_from_go(t, next), HistoricalSummaryValue_sound(h), next => Node85_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node85_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.HistoricalSummaryValue()>>
  for preserved: Node85_items_preserve(original, result)
  Node85_preserves(T.Sequence{original}, result)
def Node85_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.HistoricalSummaryValue.seq_to(xs), original, preserved)

law Node85_sound:
  for +original: T.Value
  Node85_preserves(original, F.Node85.from_value(original))
def Node85_sound(original):
  match original:
    case T.Sequence{values}: Node85_sequence_sound(values, F.HistoricalSummaryValue.seq_from_go(values, []), Node85_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node86_preserves(original: T.Value, result: Maybe<&2, F.Node86()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node86.to_value(value) == original : T.Value}

def Node86_items_preserve(original: T.Value, result: Maybe<&2, +List<F.PendingDepositValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.PendingDepositValue.seq_to(values) == original : T.Value}

law Node86_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.PendingDepositValue()>
  for +head: Maybe<&2, F.PendingDepositValue()>
  for next: +List<F.PendingDepositValue()> -> Maybe<&2, +List<F.PendingDepositValue()>>
  for head_preserves: PendingDepositValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.PendingDepositValue()> -> Node86_items_preserve(F.PendingDepositValue.seq_to_go(a, t), next(a))
  Node86_items_preserve(F.PendingDepositValue.seq_to_go(acc, T.Items{h, t}), F.PendingDepositValue.seq_step(head, acc, next))
def Node86_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node86_items_preserve(F.PendingDepositValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node86_items_sound:
  for +original: T.Value
  for +acc: +List<F.PendingDepositValue()>
  Node86_items_preserve(F.PendingDepositValue.seq_to_go(acc, original), F.PendingDepositValue.seq_from_go(original, acc))
def Node86_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.PendingDepositValue()>, T.Value, xs => F.PendingDepositValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.PendingDepositValue(), List.reverse(&2, F.PendingDepositValue(), acc)), acc, Lists.reverse_twice(F.PendingDepositValue(), acc))
    case T.Items{h, t}: Node86_step(h, t, acc, F.PendingDepositValue.from_value(h), next => F.PendingDepositValue.seq_from_go(t, next), PendingDepositValue_sound(h), next => Node86_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node86_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.PendingDepositValue()>>
  for preserved: Node86_items_preserve(original, result)
  Node86_preserves(T.Sequence{original}, result)
def Node86_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.PendingDepositValue.seq_to(xs), original, preserved)

law Node86_sound:
  for +original: T.Value
  Node86_preserves(original, F.Node86.from_value(original))
def Node86_sound(original):
  match original:
    case T.Sequence{values}: Node86_sequence_sound(values, F.PendingDepositValue.seq_from_go(values, []), Node86_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node87_preserves(original: T.Value, result: Maybe<&2, F.Node87()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node87.to_value(value) == original : T.Value}

def Node87_items_preserve(original: T.Value, result: Maybe<&2, +List<F.PendingPartialWithdrawalValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.PendingPartialWithdrawalValue.seq_to(values) == original : T.Value}

law Node87_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.PendingPartialWithdrawalValue()>
  for +head: Maybe<&2, F.PendingPartialWithdrawalValue()>
  for next: +List<F.PendingPartialWithdrawalValue()> -> Maybe<&2, +List<F.PendingPartialWithdrawalValue()>>
  for head_preserves: PendingPartialWithdrawalValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.PendingPartialWithdrawalValue()> -> Node87_items_preserve(F.PendingPartialWithdrawalValue.seq_to_go(a, t), next(a))
  Node87_items_preserve(F.PendingPartialWithdrawalValue.seq_to_go(acc, T.Items{h, t}), F.PendingPartialWithdrawalValue.seq_step(head, acc, next))
def Node87_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node87_items_preserve(F.PendingPartialWithdrawalValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node87_items_sound:
  for +original: T.Value
  for +acc: +List<F.PendingPartialWithdrawalValue()>
  Node87_items_preserve(F.PendingPartialWithdrawalValue.seq_to_go(acc, original), F.PendingPartialWithdrawalValue.seq_from_go(original, acc))
def Node87_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.PendingPartialWithdrawalValue()>, T.Value, xs => F.PendingPartialWithdrawalValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.PendingPartialWithdrawalValue(), List.reverse(&2, F.PendingPartialWithdrawalValue(), acc)), acc, Lists.reverse_twice(F.PendingPartialWithdrawalValue(), acc))
    case T.Items{h, t}: Node87_step(h, t, acc, F.PendingPartialWithdrawalValue.from_value(h), next => F.PendingPartialWithdrawalValue.seq_from_go(t, next), PendingPartialWithdrawalValue_sound(h), next => Node87_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node87_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.PendingPartialWithdrawalValue()>>
  for preserved: Node87_items_preserve(original, result)
  Node87_preserves(T.Sequence{original}, result)
def Node87_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.PendingPartialWithdrawalValue.seq_to(xs), original, preserved)

law Node87_sound:
  for +original: T.Value
  Node87_preserves(original, F.Node87.from_value(original))
def Node87_sound(original):
  match original:
    case T.Sequence{values}: Node87_sequence_sound(values, F.PendingPartialWithdrawalValue.seq_from_go(values, []), Node87_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node88_preserves(original: T.Value, result: Maybe<&2, F.Node88()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node88.to_value(value) == original : T.Value}

def Node88_items_preserve(original: T.Value, result: Maybe<&2, +List<F.PendingConsolidationValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.PendingConsolidationValue.seq_to(values) == original : T.Value}

law Node88_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.PendingConsolidationValue()>
  for +head: Maybe<&2, F.PendingConsolidationValue()>
  for next: +List<F.PendingConsolidationValue()> -> Maybe<&2, +List<F.PendingConsolidationValue()>>
  for head_preserves: PendingConsolidationValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.PendingConsolidationValue()> -> Node88_items_preserve(F.PendingConsolidationValue.seq_to_go(a, t), next(a))
  Node88_items_preserve(F.PendingConsolidationValue.seq_to_go(acc, T.Items{h, t}), F.PendingConsolidationValue.seq_step(head, acc, next))
def Node88_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node88_items_preserve(F.PendingConsolidationValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node88_items_sound:
  for +original: T.Value
  for +acc: +List<F.PendingConsolidationValue()>
  Node88_items_preserve(F.PendingConsolidationValue.seq_to_go(acc, original), F.PendingConsolidationValue.seq_from_go(original, acc))
def Node88_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.PendingConsolidationValue()>, T.Value, xs => F.PendingConsolidationValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.PendingConsolidationValue(), List.reverse(&2, F.PendingConsolidationValue(), acc)), acc, Lists.reverse_twice(F.PendingConsolidationValue(), acc))
    case T.Items{h, t}: Node88_step(h, t, acc, F.PendingConsolidationValue.from_value(h), next => F.PendingConsolidationValue.seq_from_go(t, next), PendingConsolidationValue_sound(h), next => Node88_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node88_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.PendingConsolidationValue()>>
  for preserved: Node88_items_preserve(original, result)
  Node88_preserves(T.Sequence{original}, result)
def Node88_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.PendingConsolidationValue.seq_to(xs), original, preserved)

law Node88_sound:
  for +original: T.Value
  Node88_preserves(original, F.Node88.from_value(original))
def Node88_sound(original):
  match original:
    case T.Sequence{values}: Node88_sequence_sound(values, F.PendingConsolidationValue.seq_from_go(values, []), Node88_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node89_preserves(original: T.Value, result: Maybe<&2, F.Node89()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node89.to_value(value) == original : T.Value}

def Node89_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node3()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node3.seq_to(values) == original : T.Value}

law Node89_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node3()>
  for +head: Maybe<&2, F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_preserves: Node3_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node3()> -> Node89_items_preserve(F.Node3.seq_to_go(a, t), next(a))
  Node89_items_preserve(F.Node3.seq_to_go(acc, T.Items{h, t}), F.Node3.seq_step(head, acc, next))
def Node89_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node89_items_preserve(F.Node3.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node89_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  Node89_items_preserve(F.Node3.seq_to_go(acc, original), F.Node3.seq_from_go(original, acc))
def Node89_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node3()>, T.Value, xs => F.Node3.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node3(), List.reverse(&2, F.Node3(), acc)), acc, Lists.reverse_twice(F.Node3(), acc))
    case T.Items{h, t}: Node89_step(h, t, acc, F.Node3.from_value(h), next => F.Node3.seq_from_go(t, next), Node3_sound(h), next => Node89_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node89_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node3()>>
  for preserved: Node89_items_preserve(original, result)
  Node89_preserves(T.Sequence{original}, result)
def Node89_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node3.seq_to(xs), original, preserved)

law Node89_sound:
  for +original: T.Value
  Node89_preserves(original, F.Node89.from_value(original))
def Node89_sound(original):
  match original:
    case T.Sequence{values}: Node89_sequence_sound(values, F.Node3.seq_from_go(values, []), Node89_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def BeaconStateValue_preserves(original: T.Value, result: Maybe<&2, F.BeaconStateValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.BeaconStateValue.to_value(value) == original : T.Value}

law BeaconStateValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +o5: T.Value
  for +o6: T.Value
  for +o7: T.Value
  for +o8: T.Value
  for +o9: T.Value
  for +o10: T.Value
  for +o11: T.Value
  for +o12: T.Value
  for +o13: T.Value
  for +o14: T.Value
  for +o15: T.Value
  for +o16: T.Value
  for +o17: T.Value
  for +o18: T.Value
  for +o19: T.Value
  for +o20: T.Value
  for +o21: T.Value
  for +o22: T.Value
  for +o23: T.Value
  for +o24: T.Value
  for +o25: T.Value
  for +o26: T.Value
  for +o27: T.Value
  for +o28: T.Value
  for +o29: T.Value
  for +o30: T.Value
  for +o31: T.Value
  for +o32: T.Value
  for +o33: T.Value
  for +o34: T.Value
  for +o35: T.Value
  for +o36: T.Value
  for +o37: T.Value
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
  for p0: Node3_preserves(o0, a0)
  for p1: Node7_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: ForkValue_preserves(o3, a3)
  for p4: BeaconBlockHeaderValue_preserves(o4, a4)
  for p5: Node33_preserves(o5, a5)
  for p6: Node33_preserves(o6, a6)
  for p7: Node77_preserves(o7, a7)
  for p8: Eth1DataValue_preserves(o8, a8)
  for p9: Node78_preserves(o9, a9)
  for p10: Node3_preserves(o10, a10)
  for p11: Node79_preserves(o11, a11)
  for p12: Node80_preserves(o12, a12)
  for p13: Node81_preserves(o13, a13)
  for p14: Node82_preserves(o14, a14)
  for p15: Node83_preserves(o15, a15)
  for p16: Node83_preserves(o16, a16)
  for p17: Node84_preserves(o17, a17)
  for p18: CheckpointValue_preserves(o18, a18)
  for p19: CheckpointValue_preserves(o19, a19)
  for p20: CheckpointValue_preserves(o20, a20)
  for p21: Node80_preserves(o21, a21)
  for p22: SyncCommitteeValue_preserves(o22, a22)
  for p23: SyncCommitteeValue_preserves(o23, a23)
  for p24: ExecutionPayloadHeaderValue_preserves(o24, a24)
  for p25: Node3_preserves(o25, a25)
  for p26: Node3_preserves(o26, a26)
  for p27: Node85_preserves(o27, a27)
  for p28: Node3_preserves(o28, a28)
  for p29: Node3_preserves(o29, a29)
  for p30: Node3_preserves(o30, a30)
  for p31: Node3_preserves(o31, a31)
  for p32: Node3_preserves(o32, a32)
  for p33: Node3_preserves(o33, a33)
  for p34: Node86_preserves(o34, a34)
  for p35: Node87_preserves(o35, a35)
  for p36: Node88_preserves(o36, a36)
  for p37: Node89_preserves(o37, a37)
  BeaconStateValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, F.BeaconStateValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37))
def BeaconStateValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, o17, o18, o19, o20, o21, o22, o23, o24, o25, o26, o27, o28, o29, o30, o31, o32, o33, o34, o35, o36, o37, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36, p37):
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 a32 a33 a34 a35 a36 a37:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} Some{v35} Some{v36} Some{v37}:
      %p0 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p1 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p2 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p3 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p4 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{_, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p5 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{_, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p6 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{_, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p7 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{_, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p8 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{_, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p9 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{_, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p10 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{_, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p11 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{_, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p12 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{_, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p13 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{_, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p14 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{_, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p15 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{_, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p16 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{_, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p17 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{_, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p18 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{_, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p19 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{_, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p20 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{_, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p21 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{_, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p22 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{_, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p23 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{_, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p24 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{_, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p25 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{_, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p26 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{_, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p27 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{_, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p28 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{_, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p29 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{_, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p30 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{F.Node3.to_value(v29), T.Items{_, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p31 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{F.Node3.to_value(v29), T.Items{F.Node3.to_value(v30), T.Items{_, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p32 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{F.Node3.to_value(v29), T.Items{F.Node3.to_value(v30), T.Items{F.Node3.to_value(v31), T.Items{_, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p33 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{F.Node3.to_value(v29), T.Items{F.Node3.to_value(v30), T.Items{F.Node3.to_value(v31), T.Items{F.Node3.to_value(v32), T.Items{_, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p34 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{F.Node3.to_value(v29), T.Items{F.Node3.to_value(v30), T.Items{F.Node3.to_value(v31), T.Items{F.Node3.to_value(v32), T.Items{F.Node3.to_value(v33), T.Items{_, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p35 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{F.Node3.to_value(v29), T.Items{F.Node3.to_value(v30), T.Items{F.Node3.to_value(v31), T.Items{F.Node3.to_value(v32), T.Items{F.Node3.to_value(v33), T.Items{F.Node86.to_value(v34), T.Items{_, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p36 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{F.Node3.to_value(v29), T.Items{F.Node3.to_value(v30), T.Items{F.Node3.to_value(v31), T.Items{F.Node3.to_value(v32), T.Items{F.Node3.to_value(v33), T.Items{F.Node86.to_value(v34), T.Items{F.Node87.to_value(v35), T.Items{_, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      %p37 : {F.BeaconStateValue.to_value(F.BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node7.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{F.ForkValue.to_value(v3), T.Items{F.BeaconBlockHeaderValue.to_value(v4), T.Items{F.Node33.to_value(v5), T.Items{F.Node33.to_value(v6), T.Items{F.Node77.to_value(v7), T.Items{F.Eth1DataValue.to_value(v8), T.Items{F.Node78.to_value(v9), T.Items{F.Node3.to_value(v10), T.Items{F.Node79.to_value(v11), T.Items{F.Node80.to_value(v12), T.Items{F.Node81.to_value(v13), T.Items{F.Node82.to_value(v14), T.Items{F.Node83.to_value(v15), T.Items{F.Node83.to_value(v16), T.Items{F.Node84.to_value(v17), T.Items{F.CheckpointValue.to_value(v18), T.Items{F.CheckpointValue.to_value(v19), T.Items{F.CheckpointValue.to_value(v20), T.Items{F.Node80.to_value(v21), T.Items{F.SyncCommitteeValue.to_value(v22), T.Items{F.SyncCommitteeValue.to_value(v23), T.Items{F.ExecutionPayloadHeaderValue.to_value(v24), T.Items{F.Node3.to_value(v25), T.Items{F.Node3.to_value(v26), T.Items{F.Node85.to_value(v27), T.Items{F.Node3.to_value(v28), T.Items{F.Node3.to_value(v29), T.Items{F.Node3.to_value(v30), T.Items{F.Node3.to_value(v31), T.Items{F.Node3.to_value(v32), T.Items{F.Node3.to_value(v33), T.Items{F.Node86.to_value(v34), T.Items{F.Node87.to_value(v35), T.Items{F.Node88.to_value(v36), T.Items{_, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} None{} _ _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} None{} _ _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} None{} _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} None{} _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} None{} _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} None{} _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} None{} _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} None{} _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} None{} _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} None{} _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} None{} _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} Some{v35} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} Some{v35} Some{v36} None{}: Unit{}

law BeaconStateValue_sound:
  for +original: T.Value
  BeaconStateValue_preserves(original, F.BeaconStateValue.from_value(original))
def BeaconStateValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: BeaconStateValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, o17, o18, o19, o20, o21, o22, o23, o24, o25, o26, o27, o28, o29, o30, o31, o32, o33, o34, o35, o36, o37, F.Node3.from_value(o0), F.Node7.from_value(o1), F.Node3.from_value(o2), F.ForkValue.from_value(o3), F.BeaconBlockHeaderValue.from_value(o4), F.Node33.from_value(o5), F.Node33.from_value(o6), F.Node77.from_value(o7), F.Eth1DataValue.from_value(o8), F.Node78.from_value(o9), F.Node3.from_value(o10), F.Node79.from_value(o11), F.Node80.from_value(o12), F.Node81.from_value(o13), F.Node82.from_value(o14), F.Node83.from_value(o15), F.Node83.from_value(o16), F.Node84.from_value(o17), F.CheckpointValue.from_value(o18), F.CheckpointValue.from_value(o19), F.CheckpointValue.from_value(o20), F.Node80.from_value(o21), F.SyncCommitteeValue.from_value(o22), F.SyncCommitteeValue.from_value(o23), F.ExecutionPayloadHeaderValue.from_value(o24), F.Node3.from_value(o25), F.Node3.from_value(o26), F.Node85.from_value(o27), F.Node3.from_value(o28), F.Node3.from_value(o29), F.Node3.from_value(o30), F.Node3.from_value(o31), F.Node3.from_value(o32), F.Node3.from_value(o33), F.Node86.from_value(o34), F.Node87.from_value(o35), F.Node88.from_value(o36), F.Node89.from_value(o37), Node3_sound(o0), Node7_sound(o1), Node3_sound(o2), ForkValue_sound(o3), BeaconBlockHeaderValue_sound(o4), Node33_sound(o5), Node33_sound(o6), Node77_sound(o7), Eth1DataValue_sound(o8), Node78_sound(o9), Node3_sound(o10), Node79_sound(o11), Node80_sound(o12), Node81_sound(o13), Node82_sound(o14), Node83_sound(o15), Node83_sound(o16), Node84_sound(o17), CheckpointValue_sound(o18), CheckpointValue_sound(o19), CheckpointValue_sound(o20), Node80_sound(o21), SyncCommitteeValue_sound(o22), SyncCommitteeValue_sound(o23), ExecutionPayloadHeaderValue_sound(o24), Node3_sound(o25), Node3_sound(o26), Node85_sound(o27), Node3_sound(o28), Node3_sound(o29), Node3_sound(o30), Node3_sound(o31), Node3_sound(o32), Node3_sound(o33), Node86_sound(o34), Node87_sound(o35), Node88_sound(o36), Node89_sound(o37))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BooleanValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.UnsignedValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BytesValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BitsValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Sequence{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Selected{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.NullValue{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BooleanValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.UnsignedValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BytesValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BitsValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Sequence{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Selected{bad0, bad1}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.NullValue{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BooleanValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.UnsignedValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BytesValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BitsValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Sequence{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Selected{bad0, bad1}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.NullValue{}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BooleanValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.UnsignedValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BytesValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BitsValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Sequence{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.EmptyItems{}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Selected{bad0, bad1}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.NullValue{}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BooleanValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.UnsignedValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BytesValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BitsValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Sequence{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.EmptyItems{}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Selected{bad0, bad1}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.NullValue{}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BooleanValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.UnsignedValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BytesValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BitsValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Sequence{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.EmptyItems{}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Selected{bad0, bad1}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.NullValue{}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BooleanValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.UnsignedValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BytesValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BitsValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Sequence{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.EmptyItems{}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Selected{bad0, bad1}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.NullValue{}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BooleanValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.UnsignedValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BytesValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BitsValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Sequence{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Selected{bad0, bad1}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.NullValue{}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BooleanValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BytesValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.BitsValue{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Sequence{bad0}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.EmptyItems{}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.NullValue{}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BytesValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.BitsValue{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Sequence{bad0}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.EmptyItems{}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.NullValue{}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Sequence{bad0}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.EmptyItems{}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.NullValue{}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.EmptyItems{}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.NullValue{}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.NullValue{}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.NullValue{}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.BooleanValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.UnsignedValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.BytesValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.BitsValue{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.Sequence{bad0}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.Items{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.Selected{bad0, bad1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{o13, T.Items{o14, T.Items{o15, T.Items{o16, T.Items{o17, T.Items{o18, T.Items{o19, T.Items{o20, T.Items{o21, T.Items{o22, T.Items{o23, T.Items{o24, T.Items{o25, T.Items{o26, T.Items{o27, T.Items{o28, T.Items{o29, T.Items{o30, T.Items{o31, T.Items{o32, T.Items{o33, T.Items{o34, T.Items{o35, T.Items{o36, T.Items{o37, T.NullValue{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: Unit{}

def Node90_preserves(original: T.Value, result: Maybe<&2, F.Node90()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node90.to_value(value) == original : T.Value}

def Node90_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node7()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node7.seq_to(values) == original : T.Value}

law Node90_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node7()>
  for +head: Maybe<&2, F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_preserves: Node7_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node7()> -> Node90_items_preserve(F.Node7.seq_to_go(a, t), next(a))
  Node90_items_preserve(F.Node7.seq_to_go(acc, T.Items{h, t}), F.Node7.seq_step(head, acc, next))
def Node90_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node90_items_preserve(F.Node7.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node90_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  Node90_items_preserve(F.Node7.seq_to_go(acc, original), F.Node7.seq_from_go(original, acc))
def Node90_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node7()>, T.Value, xs => F.Node7.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node7(), List.reverse(&2, F.Node7(), acc)), acc, Lists.reverse_twice(F.Node7(), acc))
    case T.Items{h, t}: Node90_step(h, t, acc, F.Node7.from_value(h), next => F.Node7.seq_from_go(t, next), Node7_sound(h), next => Node90_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node90_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node7()>>
  for preserved: Node90_items_preserve(original, result)
  Node90_preserves(T.Sequence{original}, result)
def Node90_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node7.seq_to(xs), original, preserved)

law Node90_sound:
  for +original: T.Value
  Node90_preserves(original, F.Node90.from_value(original))
def Node90_sound(original):
  match original:
    case T.Sequence{values}: Node90_sequence_sound(values, F.Node7.seq_from_go(values, []), Node90_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def LightClientHeaderValue_preserves(original: T.Value, result: Maybe<&2, F.LightClientHeaderValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.LightClientHeaderValue.to_value(value) == original : T.Value}

law LightClientHeaderValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.BeaconBlockHeaderValue()>
  for +a1: Maybe<&2, F.ExecutionPayloadHeaderValue()>
  for +a2: Maybe<&2, F.Node90()>
  for p0: BeaconBlockHeaderValue_preserves(o0, a0)
  for p1: ExecutionPayloadHeaderValue_preserves(o1, a1)
  for p2: Node90_preserves(o2, a2)
  LightClientHeaderValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.LightClientHeaderValue.assemble(a0, a1, a2))
def LightClientHeaderValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.LightClientHeaderValue.to_value(F.LightClientHeader{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.LightClientHeaderValue.to_value(F.LightClientHeader{v0, v1, v2}) == T.Sequence{T.Items{F.BeaconBlockHeaderValue.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.LightClientHeaderValue.to_value(F.LightClientHeader{v0, v1, v2}) == T.Sequence{T.Items{F.BeaconBlockHeaderValue.to_value(v0), T.Items{F.ExecutionPayloadHeaderValue.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law LightClientHeaderValue_sound:
  for +original: T.Value
  LightClientHeaderValue_preserves(original, F.LightClientHeaderValue.from_value(original))
def LightClientHeaderValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: LightClientHeaderValue_assemble_sound(o0, o1, o2, F.BeaconBlockHeaderValue.from_value(o0), F.ExecutionPayloadHeaderValue.from_value(o1), F.Node90.from_value(o2), BeaconBlockHeaderValue_sound(o0), ExecutionPayloadHeaderValue_sound(o1), Node90_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def LightClientOptimisticUpdateValue_preserves(original: T.Value, result: Maybe<&2, F.LightClientOptimisticUpdateValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.LightClientOptimisticUpdateValue.to_value(value) == original : T.Value}

law LightClientOptimisticUpdateValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.LightClientHeaderValue()>
  for +a1: Maybe<&2, F.SyncAggregateValue()>
  for +a2: Maybe<&2, F.Node3()>
  for p0: LightClientHeaderValue_preserves(o0, a0)
  for p1: SyncAggregateValue_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  LightClientOptimisticUpdateValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.LightClientOptimisticUpdateValue.assemble(a0, a1, a2))
def LightClientOptimisticUpdateValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.LightClientOptimisticUpdateValue.to_value(F.LightClientOptimisticUpdate{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.LightClientOptimisticUpdateValue.to_value(F.LightClientOptimisticUpdate{v0, v1, v2}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.LightClientOptimisticUpdateValue.to_value(F.LightClientOptimisticUpdate{v0, v1, v2}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.SyncAggregateValue.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law LightClientOptimisticUpdateValue_sound:
  for +original: T.Value
  LightClientOptimisticUpdateValue_preserves(original, F.LightClientOptimisticUpdateValue.from_value(original))
def LightClientOptimisticUpdateValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: LightClientOptimisticUpdateValue_assemble_sound(o0, o1, o2, F.LightClientHeaderValue.from_value(o0), F.SyncAggregateValue.from_value(o1), F.Node3.from_value(o2), LightClientHeaderValue_sound(o0), SyncAggregateValue_sound(o1), Node3_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def LightClientFinalityUpdateValue_preserves(original: T.Value, result: Maybe<&2, F.LightClientFinalityUpdateValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.LightClientFinalityUpdateValue.to_value(value) == original : T.Value}

law LightClientFinalityUpdateValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +a0: Maybe<&2, F.LightClientHeaderValue()>
  for +a1: Maybe<&2, F.LightClientHeaderValue()>
  for +a2: Maybe<&2, F.Node12()>
  for +a3: Maybe<&2, F.SyncAggregateValue()>
  for +a4: Maybe<&2, F.Node3()>
  for p0: LightClientHeaderValue_preserves(o0, a0)
  for p1: LightClientHeaderValue_preserves(o1, a1)
  for p2: Node12_preserves(o2, a2)
  for p3: SyncAggregateValue_preserves(o3, a3)
  for p4: Node3_preserves(o4, a4)
  LightClientFinalityUpdateValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}, F.LightClientFinalityUpdateValue.assemble(a0, a1, a2, a3, a4))
def LightClientFinalityUpdateValue_assemble_sound(o0, o1, o2, o3, o4, a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}:
      %p0 : {F.LightClientFinalityUpdateValue.to_value(F.LightClientFinalityUpdate{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p1 : {F.LightClientFinalityUpdateValue.to_value(F.LightClientFinalityUpdate{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p2 : {F.LightClientFinalityUpdateValue.to_value(F.LightClientFinalityUpdate{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.LightClientHeaderValue.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p3 : {F.LightClientFinalityUpdateValue.to_value(F.LightClientFinalityUpdate{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.LightClientHeaderValue.to_value(v1), T.Items{F.Node12.to_value(v2), T.Items{_, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p4 : {F.LightClientFinalityUpdateValue.to_value(F.LightClientFinalityUpdate{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.LightClientHeaderValue.to_value(v1), T.Items{F.Node12.to_value(v2), T.Items{F.SyncAggregateValue.to_value(v3), T.Items{_, T.EmptyItems{}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: Unit{}

law LightClientFinalityUpdateValue_sound:
  for +original: T.Value
  LightClientFinalityUpdateValue_preserves(original, F.LightClientFinalityUpdateValue.from_value(original))
def LightClientFinalityUpdateValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: LightClientFinalityUpdateValue_assemble_sound(o0, o1, o2, o3, o4, F.LightClientHeaderValue.from_value(o0), F.LightClientHeaderValue.from_value(o1), F.Node12.from_value(o2), F.SyncAggregateValue.from_value(o3), F.Node3.from_value(o4), LightClientHeaderValue_sound(o0), LightClientHeaderValue_sound(o1), Node12_sound(o2), SyncAggregateValue_sound(o3), Node3_sound(o4))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}

def LightClientUpdateValue_preserves(original: T.Value, result: Maybe<&2, F.LightClientUpdateValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.LightClientUpdateValue.to_value(value) == original : T.Value}

law LightClientUpdateValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +o5: T.Value
  for +o6: T.Value
  for +a0: Maybe<&2, F.LightClientHeaderValue()>
  for +a1: Maybe<&2, F.SyncCommitteeValue()>
  for +a2: Maybe<&2, F.Node59()>
  for +a3: Maybe<&2, F.LightClientHeaderValue()>
  for +a4: Maybe<&2, F.Node12()>
  for +a5: Maybe<&2, F.SyncAggregateValue()>
  for +a6: Maybe<&2, F.Node3()>
  for p0: LightClientHeaderValue_preserves(o0, a0)
  for p1: SyncCommitteeValue_preserves(o1, a1)
  for p2: Node59_preserves(o2, a2)
  for p3: LightClientHeaderValue_preserves(o3, a3)
  for p4: Node12_preserves(o4, a4)
  for p5: SyncAggregateValue_preserves(o5, a5)
  for p6: Node3_preserves(o6, a6)
  LightClientUpdateValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}}, F.LightClientUpdateValue.assemble(a0, a1, a2, a3, a4, a5, a6))
def LightClientUpdateValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, a0, a1, a2, a3, a4, a5, a6, p0, p1, p2, p3, p4, p5, p6):
  match a0 a1 a2 a3 a4 a5 a6:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6}:
      %p0 : {F.LightClientUpdateValue.to_value(F.LightClientUpdate{v0, v1, v2, v3, v4, v5, v6}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}} : T.Value}
      %p1 : {F.LightClientUpdateValue.to_value(F.LightClientUpdate{v0, v1, v2, v3, v4, v5, v6}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}} : T.Value}
      %p2 : {F.LightClientUpdateValue.to_value(F.LightClientUpdate{v0, v1, v2, v3, v4, v5, v6}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.SyncCommitteeValue.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}} : T.Value}
      %p3 : {F.LightClientUpdateValue.to_value(F.LightClientUpdate{v0, v1, v2, v3, v4, v5, v6}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.SyncCommitteeValue.to_value(v1), T.Items{F.Node59.to_value(v2), T.Items{_, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}} : T.Value}
      %p4 : {F.LightClientUpdateValue.to_value(F.LightClientUpdate{v0, v1, v2, v3, v4, v5, v6}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.SyncCommitteeValue.to_value(v1), T.Items{F.Node59.to_value(v2), T.Items{F.LightClientHeaderValue.to_value(v3), T.Items{_, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}} : T.Value}
      %p5 : {F.LightClientUpdateValue.to_value(F.LightClientUpdate{v0, v1, v2, v3, v4, v5, v6}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.SyncCommitteeValue.to_value(v1), T.Items{F.Node59.to_value(v2), T.Items{F.LightClientHeaderValue.to_value(v3), T.Items{F.Node12.to_value(v4), T.Items{_, T.Items{o6, T.EmptyItems{}}}}}}}}} : T.Value}
      %p6 : {F.LightClientUpdateValue.to_value(F.LightClientUpdate{v0, v1, v2, v3, v4, v5, v6}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.SyncCommitteeValue.to_value(v1), T.Items{F.Node59.to_value(v2), T.Items{F.LightClientHeaderValue.to_value(v3), T.Items{F.Node12.to_value(v4), T.Items{F.SyncAggregateValue.to_value(v5), T.Items{_, T.EmptyItems{}}}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{}: Unit{}

law LightClientUpdateValue_sound:
  for +original: T.Value
  LightClientUpdateValue_preserves(original, F.LightClientUpdateValue.from_value(original))
def LightClientUpdateValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}}: LightClientUpdateValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, F.LightClientHeaderValue.from_value(o0), F.SyncCommitteeValue.from_value(o1), F.Node59.from_value(o2), F.LightClientHeaderValue.from_value(o3), F.Node12.from_value(o4), F.SyncAggregateValue.from_value(o5), F.Node3.from_value(o6), LightClientHeaderValue_sound(o0), SyncCommitteeValue_sound(o1), Node59_sound(o2), LightClientHeaderValue_sound(o3), Node12_sound(o4), SyncAggregateValue_sound(o5), Node3_sound(o6))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BooleanValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.UnsignedValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BytesValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BitsValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Sequence{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Selected{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.NullValue{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BooleanValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.UnsignedValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BytesValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BitsValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Sequence{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{bad0, bad1}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Selected{bad0, bad1}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.NullValue{}}}}}}}}}: Unit{}

def LightClientBootstrapValue_preserves(original: T.Value, result: Maybe<&2, F.LightClientBootstrapValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.LightClientBootstrapValue.to_value(value) == original : T.Value}

law LightClientBootstrapValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +a0: Maybe<&2, F.LightClientHeaderValue()>
  for +a1: Maybe<&2, F.SyncCommitteeValue()>
  for +a2: Maybe<&2, F.Node59()>
  for p0: LightClientHeaderValue_preserves(o0, a0)
  for p1: SyncCommitteeValue_preserves(o1, a1)
  for p2: Node59_preserves(o2, a2)
  LightClientBootstrapValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}, F.LightClientBootstrapValue.assemble(a0, a1, a2))
def LightClientBootstrapValue_assemble_sound(o0, o1, o2, a0, a1, a2, p0, p1, p2):
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}:
      %p0 : {F.LightClientBootstrapValue.to_value(F.LightClientBootstrap{v0, v1, v2}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p1 : {F.LightClientBootstrapValue.to_value(F.LightClientBootstrap{v0, v1, v2}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{_, T.Items{o2, T.EmptyItems{}}}}} : T.Value}
      %p2 : {F.LightClientBootstrapValue.to_value(F.LightClientBootstrap{v0, v1, v2}) == T.Sequence{T.Items{F.LightClientHeaderValue.to_value(v0), T.Items{F.SyncCommitteeValue.to_value(v1), T.Items{_, T.EmptyItems{}}}}} : T.Value}
      {==}
    case None{} _ _: Unit{}
    case Some{v0} None{} _: Unit{}
    case Some{v0} Some{v1} None{}: Unit{}

law LightClientBootstrapValue_sound:
  for +original: T.Value
  LightClientBootstrapValue_preserves(original, F.LightClientBootstrapValue.from_value(original))
def LightClientBootstrapValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: LightClientBootstrapValue_assemble_sound(o0, o1, o2, F.LightClientHeaderValue.from_value(o0), F.SyncCommitteeValue.from_value(o1), F.Node59.from_value(o2), LightClientHeaderValue_sound(o0), SyncCommitteeValue_sound(o1), Node59_sound(o2))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}

def BlobIdentifierValue_preserves(original: T.Value, result: Maybe<&2, F.BlobIdentifierValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.BlobIdentifierValue.to_value(value) == original : T.Value}

law BlobIdentifierValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node3()>
  for p0: Node7_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  BlobIdentifierValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.BlobIdentifierValue.assemble(a0, a1))
def BlobIdentifierValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.BlobIdentifierValue.to_value(F.BlobIdentifier{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.BlobIdentifierValue.to_value(F.BlobIdentifier{v0, v1}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law BlobIdentifierValue_sound:
  for +original: T.Value
  BlobIdentifierValue_preserves(original, F.BlobIdentifierValue.from_value(original))
def BlobIdentifierValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: BlobIdentifierValue_assemble_sound(o0, o1, F.Node7.from_value(o0), F.Node3.from_value(o1), Node7_sound(o0), Node3_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def Node98_preserves(original: T.Value, result: Maybe<&2, F.Node98()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node98.to_value(value) == original : T.Value}

def Node98_items_preserve(original: T.Value, result: Maybe<&2, +List<F.ProposerSlashingValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.ProposerSlashingValue.seq_to(values) == original : T.Value}

law Node98_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.ProposerSlashingValue()>
  for +head: Maybe<&2, F.ProposerSlashingValue()>
  for next: +List<F.ProposerSlashingValue()> -> Maybe<&2, +List<F.ProposerSlashingValue()>>
  for head_preserves: ProposerSlashingValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.ProposerSlashingValue()> -> Node98_items_preserve(F.ProposerSlashingValue.seq_to_go(a, t), next(a))
  Node98_items_preserve(F.ProposerSlashingValue.seq_to_go(acc, T.Items{h, t}), F.ProposerSlashingValue.seq_step(head, acc, next))
def Node98_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node98_items_preserve(F.ProposerSlashingValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node98_items_sound:
  for +original: T.Value
  for +acc: +List<F.ProposerSlashingValue()>
  Node98_items_preserve(F.ProposerSlashingValue.seq_to_go(acc, original), F.ProposerSlashingValue.seq_from_go(original, acc))
def Node98_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.ProposerSlashingValue()>, T.Value, xs => F.ProposerSlashingValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.ProposerSlashingValue(), List.reverse(&2, F.ProposerSlashingValue(), acc)), acc, Lists.reverse_twice(F.ProposerSlashingValue(), acc))
    case T.Items{h, t}: Node98_step(h, t, acc, F.ProposerSlashingValue.from_value(h), next => F.ProposerSlashingValue.seq_from_go(t, next), ProposerSlashingValue_sound(h), next => Node98_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node98_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.ProposerSlashingValue()>>
  for preserved: Node98_items_preserve(original, result)
  Node98_preserves(T.Sequence{original}, result)
def Node98_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.ProposerSlashingValue.seq_to(xs), original, preserved)

law Node98_sound:
  for +original: T.Value
  Node98_preserves(original, F.Node98.from_value(original))
def Node98_sound(original):
  match original:
    case T.Sequence{values}: Node98_sequence_sound(values, F.ProposerSlashingValue.seq_from_go(values, []), Node98_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node99_preserves(original: T.Value, result: Maybe<&2, F.Node99()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node99.to_value(value) == original : T.Value}

def Node99_items_preserve(original: T.Value, result: Maybe<&2, +List<F.AttesterSlashingValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.AttesterSlashingValue.seq_to(values) == original : T.Value}

law Node99_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.AttesterSlashingValue()>
  for +head: Maybe<&2, F.AttesterSlashingValue()>
  for next: +List<F.AttesterSlashingValue()> -> Maybe<&2, +List<F.AttesterSlashingValue()>>
  for head_preserves: AttesterSlashingValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.AttesterSlashingValue()> -> Node99_items_preserve(F.AttesterSlashingValue.seq_to_go(a, t), next(a))
  Node99_items_preserve(F.AttesterSlashingValue.seq_to_go(acc, T.Items{h, t}), F.AttesterSlashingValue.seq_step(head, acc, next))
def Node99_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node99_items_preserve(F.AttesterSlashingValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node99_items_sound:
  for +original: T.Value
  for +acc: +List<F.AttesterSlashingValue()>
  Node99_items_preserve(F.AttesterSlashingValue.seq_to_go(acc, original), F.AttesterSlashingValue.seq_from_go(original, acc))
def Node99_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.AttesterSlashingValue()>, T.Value, xs => F.AttesterSlashingValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.AttesterSlashingValue(), List.reverse(&2, F.AttesterSlashingValue(), acc)), acc, Lists.reverse_twice(F.AttesterSlashingValue(), acc))
    case T.Items{h, t}: Node99_step(h, t, acc, F.AttesterSlashingValue.from_value(h), next => F.AttesterSlashingValue.seq_from_go(t, next), AttesterSlashingValue_sound(h), next => Node99_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node99_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.AttesterSlashingValue()>>
  for preserved: Node99_items_preserve(original, result)
  Node99_preserves(T.Sequence{original}, result)
def Node99_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.AttesterSlashingValue.seq_to(xs), original, preserved)

law Node99_sound:
  for +original: T.Value
  Node99_preserves(original, F.Node99.from_value(original))
def Node99_sound(original):
  match original:
    case T.Sequence{values}: Node99_sequence_sound(values, F.AttesterSlashingValue.seq_from_go(values, []), Node99_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node100_preserves(original: T.Value, result: Maybe<&2, F.Node100()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node100.to_value(value) == original : T.Value}

def Node100_items_preserve(original: T.Value, result: Maybe<&2, +List<F.AttestationValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.AttestationValue.seq_to(values) == original : T.Value}

law Node100_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.AttestationValue()>
  for +head: Maybe<&2, F.AttestationValue()>
  for next: +List<F.AttestationValue()> -> Maybe<&2, +List<F.AttestationValue()>>
  for head_preserves: AttestationValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.AttestationValue()> -> Node100_items_preserve(F.AttestationValue.seq_to_go(a, t), next(a))
  Node100_items_preserve(F.AttestationValue.seq_to_go(acc, T.Items{h, t}), F.AttestationValue.seq_step(head, acc, next))
def Node100_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node100_items_preserve(F.AttestationValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node100_items_sound:
  for +original: T.Value
  for +acc: +List<F.AttestationValue()>
  Node100_items_preserve(F.AttestationValue.seq_to_go(acc, original), F.AttestationValue.seq_from_go(original, acc))
def Node100_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.AttestationValue()>, T.Value, xs => F.AttestationValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.AttestationValue(), List.reverse(&2, F.AttestationValue(), acc)), acc, Lists.reverse_twice(F.AttestationValue(), acc))
    case T.Items{h, t}: Node100_step(h, t, acc, F.AttestationValue.from_value(h), next => F.AttestationValue.seq_from_go(t, next), AttestationValue_sound(h), next => Node100_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node100_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.AttestationValue()>>
  for preserved: Node100_items_preserve(original, result)
  Node100_preserves(T.Sequence{original}, result)
def Node100_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.AttestationValue.seq_to(xs), original, preserved)

law Node100_sound:
  for +original: T.Value
  Node100_preserves(original, F.Node100.from_value(original))
def Node100_sound(original):
  match original:
    case T.Sequence{values}: Node100_sequence_sound(values, F.AttestationValue.seq_from_go(values, []), Node100_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node101_preserves(original: T.Value, result: Maybe<&2, F.Node101()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node101.to_value(value) == original : T.Value}

def Node101_items_preserve(original: T.Value, result: Maybe<&2, +List<F.DepositValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.DepositValue.seq_to(values) == original : T.Value}

law Node101_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.DepositValue()>
  for +head: Maybe<&2, F.DepositValue()>
  for next: +List<F.DepositValue()> -> Maybe<&2, +List<F.DepositValue()>>
  for head_preserves: DepositValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.DepositValue()> -> Node101_items_preserve(F.DepositValue.seq_to_go(a, t), next(a))
  Node101_items_preserve(F.DepositValue.seq_to_go(acc, T.Items{h, t}), F.DepositValue.seq_step(head, acc, next))
def Node101_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node101_items_preserve(F.DepositValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node101_items_sound:
  for +original: T.Value
  for +acc: +List<F.DepositValue()>
  Node101_items_preserve(F.DepositValue.seq_to_go(acc, original), F.DepositValue.seq_from_go(original, acc))
def Node101_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.DepositValue()>, T.Value, xs => F.DepositValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.DepositValue(), List.reverse(&2, F.DepositValue(), acc)), acc, Lists.reverse_twice(F.DepositValue(), acc))
    case T.Items{h, t}: Node101_step(h, t, acc, F.DepositValue.from_value(h), next => F.DepositValue.seq_from_go(t, next), DepositValue_sound(h), next => Node101_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node101_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.DepositValue()>>
  for preserved: Node101_items_preserve(original, result)
  Node101_preserves(T.Sequence{original}, result)
def Node101_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.DepositValue.seq_to(xs), original, preserved)

law Node101_sound:
  for +original: T.Value
  Node101_preserves(original, F.Node101.from_value(original))
def Node101_sound(original):
  match original:
    case T.Sequence{values}: Node101_sequence_sound(values, F.DepositValue.seq_from_go(values, []), Node101_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node102_preserves(original: T.Value, result: Maybe<&2, F.Node102()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node102.to_value(value) == original : T.Value}

def Node102_items_preserve(original: T.Value, result: Maybe<&2, +List<F.SignedVoluntaryExitValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.SignedVoluntaryExitValue.seq_to(values) == original : T.Value}

law Node102_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.SignedVoluntaryExitValue()>
  for +head: Maybe<&2, F.SignedVoluntaryExitValue()>
  for next: +List<F.SignedVoluntaryExitValue()> -> Maybe<&2, +List<F.SignedVoluntaryExitValue()>>
  for head_preserves: SignedVoluntaryExitValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.SignedVoluntaryExitValue()> -> Node102_items_preserve(F.SignedVoluntaryExitValue.seq_to_go(a, t), next(a))
  Node102_items_preserve(F.SignedVoluntaryExitValue.seq_to_go(acc, T.Items{h, t}), F.SignedVoluntaryExitValue.seq_step(head, acc, next))
def Node102_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node102_items_preserve(F.SignedVoluntaryExitValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node102_items_sound:
  for +original: T.Value
  for +acc: +List<F.SignedVoluntaryExitValue()>
  Node102_items_preserve(F.SignedVoluntaryExitValue.seq_to_go(acc, original), F.SignedVoluntaryExitValue.seq_from_go(original, acc))
def Node102_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.SignedVoluntaryExitValue()>, T.Value, xs => F.SignedVoluntaryExitValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.SignedVoluntaryExitValue(), List.reverse(&2, F.SignedVoluntaryExitValue(), acc)), acc, Lists.reverse_twice(F.SignedVoluntaryExitValue(), acc))
    case T.Items{h, t}: Node102_step(h, t, acc, F.SignedVoluntaryExitValue.from_value(h), next => F.SignedVoluntaryExitValue.seq_from_go(t, next), SignedVoluntaryExitValue_sound(h), next => Node102_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node102_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.SignedVoluntaryExitValue()>>
  for preserved: Node102_items_preserve(original, result)
  Node102_preserves(T.Sequence{original}, result)
def Node102_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.SignedVoluntaryExitValue.seq_to(xs), original, preserved)

law Node102_sound:
  for +original: T.Value
  Node102_preserves(original, F.Node102.from_value(original))
def Node102_sound(original):
  match original:
    case T.Sequence{values}: Node102_sequence_sound(values, F.SignedVoluntaryExitValue.seq_from_go(values, []), Node102_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node103_preserves(original: T.Value, result: Maybe<&2, F.Node103()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node103.to_value(value) == original : T.Value}

def Node103_items_preserve(original: T.Value, result: Maybe<&2, +List<F.SignedBLSToExecutionChangeValue()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.SignedBLSToExecutionChangeValue.seq_to(values) == original : T.Value}

law Node103_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.SignedBLSToExecutionChangeValue()>
  for +head: Maybe<&2, F.SignedBLSToExecutionChangeValue()>
  for next: +List<F.SignedBLSToExecutionChangeValue()> -> Maybe<&2, +List<F.SignedBLSToExecutionChangeValue()>>
  for head_preserves: SignedBLSToExecutionChangeValue_preserves(h, head)
  for tail_preserves: @+a: +List<F.SignedBLSToExecutionChangeValue()> -> Node103_items_preserve(F.SignedBLSToExecutionChangeValue.seq_to_go(a, t), next(a))
  Node103_items_preserve(F.SignedBLSToExecutionChangeValue.seq_to_go(acc, T.Items{h, t}), F.SignedBLSToExecutionChangeValue.seq_step(head, acc, next))
def Node103_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node103_items_preserve(F.SignedBLSToExecutionChangeValue.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node103_items_sound:
  for +original: T.Value
  for +acc: +List<F.SignedBLSToExecutionChangeValue()>
  Node103_items_preserve(F.SignedBLSToExecutionChangeValue.seq_to_go(acc, original), F.SignedBLSToExecutionChangeValue.seq_from_go(original, acc))
def Node103_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.SignedBLSToExecutionChangeValue()>, T.Value, xs => F.SignedBLSToExecutionChangeValue.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.SignedBLSToExecutionChangeValue(), List.reverse(&2, F.SignedBLSToExecutionChangeValue(), acc)), acc, Lists.reverse_twice(F.SignedBLSToExecutionChangeValue(), acc))
    case T.Items{h, t}: Node103_step(h, t, acc, F.SignedBLSToExecutionChangeValue.from_value(h), next => F.SignedBLSToExecutionChangeValue.seq_from_go(t, next), SignedBLSToExecutionChangeValue_sound(h), next => Node103_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node103_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.SignedBLSToExecutionChangeValue()>>
  for preserved: Node103_items_preserve(original, result)
  Node103_preserves(T.Sequence{original}, result)
def Node103_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.SignedBLSToExecutionChangeValue.seq_to(xs), original, preserved)

law Node103_sound:
  for +original: T.Value
  Node103_preserves(original, F.Node103.from_value(original))
def Node103_sound(original):
  match original:
    case T.Sequence{values}: Node103_sequence_sound(values, F.SignedBLSToExecutionChangeValue.seq_from_go(values, []), Node103_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node104_preserves(original: T.Value, result: Maybe<&2, F.Node104()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node104.to_value(value) == original : T.Value}

def Node104_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node8()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node8.seq_to(values) == original : T.Value}

law Node104_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node8()>
  for +head: Maybe<&2, F.Node8()>
  for next: +List<F.Node8()> -> Maybe<&2, +List<F.Node8()>>
  for head_preserves: Node8_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node8()> -> Node104_items_preserve(F.Node8.seq_to_go(a, t), next(a))
  Node104_items_preserve(F.Node8.seq_to_go(acc, T.Items{h, t}), F.Node8.seq_step(head, acc, next))
def Node104_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node104_items_preserve(F.Node8.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node104_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node8()>
  Node104_items_preserve(F.Node8.seq_to_go(acc, original), F.Node8.seq_from_go(original, acc))
def Node104_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node8()>, T.Value, xs => F.Node8.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node8(), List.reverse(&2, F.Node8(), acc)), acc, Lists.reverse_twice(F.Node8(), acc))
    case T.Items{h, t}: Node104_step(h, t, acc, F.Node8.from_value(h), next => F.Node8.seq_from_go(t, next), Node8_sound(h), next => Node104_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node104_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node8()>>
  for preserved: Node104_items_preserve(original, result)
  Node104_preserves(T.Sequence{original}, result)
def Node104_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node8.seq_to(xs), original, preserved)

law Node104_sound:
  for +original: T.Value
  Node104_preserves(original, F.Node104.from_value(original))
def Node104_sound(original):
  match original:
    case T.Sequence{values}: Node104_sequence_sound(values, F.Node8.seq_from_go(values, []), Node104_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def BeaconBlockBodyValue_preserves(original: T.Value, result: Maybe<&2, F.BeaconBlockBodyValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.BeaconBlockBodyValue.to_value(value) == original : T.Value}

law BeaconBlockBodyValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +o5: T.Value
  for +o6: T.Value
  for +o7: T.Value
  for +o8: T.Value
  for +o9: T.Value
  for +o10: T.Value
  for +o11: T.Value
  for +o12: T.Value
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
  for p0: Node9_preserves(o0, a0)
  for p1: Eth1DataValue_preserves(o1, a1)
  for p2: Node7_preserves(o2, a2)
  for p3: Node98_preserves(o3, a3)
  for p4: Node99_preserves(o4, a4)
  for p5: Node100_preserves(o5, a5)
  for p6: Node101_preserves(o6, a6)
  for p7: Node102_preserves(o7, a7)
  for p8: SyncAggregateValue_preserves(o8, a8)
  for p9: ExecutionPayloadValue_preserves(o9, a9)
  for p10: Node103_preserves(o10, a10)
  for p11: Node104_preserves(o11, a11)
  for p12: ExecutionRequestsValue_preserves(o12, a12)
  BeaconBlockBodyValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}}, F.BeaconBlockBodyValue.assemble(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12))
def BeaconBlockBodyValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12):
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12}:
      %p0 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p1 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p2 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p3 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{_, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p4 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{_, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p5 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{F.Node99.to_value(v4), T.Items{_, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p6 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{F.Node99.to_value(v4), T.Items{F.Node100.to_value(v5), T.Items{_, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p7 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{F.Node99.to_value(v4), T.Items{F.Node100.to_value(v5), T.Items{F.Node101.to_value(v6), T.Items{_, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p8 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{F.Node99.to_value(v4), T.Items{F.Node100.to_value(v5), T.Items{F.Node101.to_value(v6), T.Items{F.Node102.to_value(v7), T.Items{_, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p9 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{F.Node99.to_value(v4), T.Items{F.Node100.to_value(v5), T.Items{F.Node101.to_value(v6), T.Items{F.Node102.to_value(v7), T.Items{F.SyncAggregateValue.to_value(v8), T.Items{_, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p10 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{F.Node99.to_value(v4), T.Items{F.Node100.to_value(v5), T.Items{F.Node101.to_value(v6), T.Items{F.Node102.to_value(v7), T.Items{F.SyncAggregateValue.to_value(v8), T.Items{F.ExecutionPayloadValue.to_value(v9), T.Items{_, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p11 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{F.Node99.to_value(v4), T.Items{F.Node100.to_value(v5), T.Items{F.Node101.to_value(v6), T.Items{F.Node102.to_value(v7), T.Items{F.SyncAggregateValue.to_value(v8), T.Items{F.ExecutionPayloadValue.to_value(v9), T.Items{F.Node103.to_value(v10), T.Items{_, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      %p12 : {F.BeaconBlockBodyValue.to_value(F.BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}) == T.Sequence{T.Items{F.Node9.to_value(v0), T.Items{F.Eth1DataValue.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node98.to_value(v3), T.Items{F.Node99.to_value(v4), T.Items{F.Node100.to_value(v5), T.Items{F.Node101.to_value(v6), T.Items{F.Node102.to_value(v7), T.Items{F.SyncAggregateValue.to_value(v8), T.Items{F.ExecutionPayloadValue.to_value(v9), T.Items{F.Node103.to_value(v10), T.Items{F.Node104.to_value(v11), T.Items{_, T.EmptyItems{}}}}}}}}}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _ _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _ _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{} _ _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} None{} _ _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} None{} _ _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} None{} _ _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} None{}: Unit{}

law BeaconBlockBodyValue_sound:
  for +original: T.Value
  BeaconBlockBodyValue_preserves(original, F.BeaconBlockBodyValue.from_value(original))
def BeaconBlockBodyValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.EmptyItems{}}}}}}}}}}}}}}}: BeaconBlockBodyValue_assemble_sound(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, F.Node9.from_value(o0), F.Eth1DataValue.from_value(o1), F.Node7.from_value(o2), F.Node98.from_value(o3), F.Node99.from_value(o4), F.Node100.from_value(o5), F.Node101.from_value(o6), F.Node102.from_value(o7), F.SyncAggregateValue.from_value(o8), F.ExecutionPayloadValue.from_value(o9), F.Node103.from_value(o10), F.Node104.from_value(o11), F.ExecutionRequestsValue.from_value(o12), Node9_sound(o0), Eth1DataValue_sound(o1), Node7_sound(o2), Node98_sound(o3), Node99_sound(o4), Node100_sound(o5), Node101_sound(o6), Node102_sound(o7), SyncAggregateValue_sound(o8), ExecutionPayloadValue_sound(o9), Node103_sound(o10), Node104_sound(o11), ExecutionRequestsValue_sound(o12))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BooleanValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.UnsignedValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BytesValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BitsValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Sequence{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Selected{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.NullValue{}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BooleanValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.UnsignedValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BytesValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.BitsValue{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Sequence{bad0}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.EmptyItems{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Selected{bad0, bad1}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.NullValue{}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BooleanValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.UnsignedValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BytesValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.BitsValue{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Sequence{bad0}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.EmptyItems{}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Selected{bad0, bad1}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.NullValue{}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BooleanValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.UnsignedValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BytesValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.BitsValue{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Sequence{bad0}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.EmptyItems{}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Selected{bad0, bad1}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.NullValue{}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BooleanValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.UnsignedValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BytesValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.BitsValue{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Sequence{bad0}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.EmptyItems{}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Selected{bad0, bad1}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.NullValue{}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BooleanValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.UnsignedValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BytesValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.BitsValue{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Sequence{bad0}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.EmptyItems{}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Selected{bad0, bad1}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.NullValue{}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BooleanValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.UnsignedValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BytesValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.BitsValue{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Sequence{bad0}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.EmptyItems{}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Selected{bad0, bad1}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.NullValue{}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BooleanValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.UnsignedValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BytesValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.BitsValue{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Sequence{bad0}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Items{bad0, bad1}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.Selected{bad0, bad1}}}}}}}}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{o6, T.Items{o7, T.Items{o8, T.Items{o9, T.Items{o10, T.Items{o11, T.Items{o12, T.NullValue{}}}}}}}}}}}}}}}: Unit{}

def BeaconBlockValue_preserves(original: T.Value, result: Maybe<&2, F.BeaconBlockValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.BeaconBlockValue.to_value(value) == original : T.Value}

law BeaconBlockValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node3()>
  for +a2: Maybe<&2, F.Node7()>
  for +a3: Maybe<&2, F.Node7()>
  for +a4: Maybe<&2, F.BeaconBlockBodyValue()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node3_preserves(o1, a1)
  for p2: Node7_preserves(o2, a2)
  for p3: Node7_preserves(o3, a3)
  for p4: BeaconBlockBodyValue_preserves(o4, a4)
  BeaconBlockValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}, F.BeaconBlockValue.assemble(a0, a1, a2, a3, a4))
def BeaconBlockValue_assemble_sound(o0, o1, o2, o3, o4, a0, a1, a2, a3, a4, p0, p1, p2, p3, p4):
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}:
      %p0 : {F.BeaconBlockValue.to_value(F.BeaconBlock{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p1 : {F.BeaconBlockValue.to_value(F.BeaconBlock{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p2 : {F.BeaconBlockValue.to_value(F.BeaconBlock{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p3 : {F.BeaconBlockValue.to_value(F.BeaconBlock{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{_, T.Items{o4, T.EmptyItems{}}}}}}} : T.Value}
      %p4 : {F.BeaconBlockValue.to_value(F.BeaconBlock{v0, v1, v2, v3, v4}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node3.to_value(v1), T.Items{F.Node7.to_value(v2), T.Items{F.Node7.to_value(v3), T.Items{_, T.EmptyItems{}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{}: Unit{}

law BeaconBlockValue_sound:
  for +original: T.Value
  BeaconBlockValue_preserves(original, F.BeaconBlockValue.from_value(original))
def BeaconBlockValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: BeaconBlockValue_assemble_sound(o0, o1, o2, o3, o4, F.Node3.from_value(o0), F.Node3.from_value(o1), F.Node7.from_value(o2), F.Node7.from_value(o3), F.BeaconBlockBodyValue.from_value(o4), Node3_sound(o0), Node3_sound(o1), Node7_sound(o2), Node7_sound(o3), BeaconBlockBodyValue_sound(o4))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}

def SignedBeaconBlockValue_preserves(original: T.Value, result: Maybe<&2, F.SignedBeaconBlockValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.SignedBeaconBlockValue.to_value(value) == original : T.Value}

law SignedBeaconBlockValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.BeaconBlockValue()>
  for +a1: Maybe<&2, F.Node9()>
  for p0: BeaconBlockValue_preserves(o0, a0)
  for p1: Node9_preserves(o1, a1)
  SignedBeaconBlockValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.SignedBeaconBlockValue.assemble(a0, a1))
def SignedBeaconBlockValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.SignedBeaconBlockValue.to_value(F.SignedBeaconBlock{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.SignedBeaconBlockValue.to_value(F.SignedBeaconBlock{v0, v1}) == T.Sequence{T.Items{F.BeaconBlockValue.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law SignedBeaconBlockValue_sound:
  for +original: T.Value
  SignedBeaconBlockValue_preserves(original, F.SignedBeaconBlockValue.from_value(original))
def SignedBeaconBlockValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: SignedBeaconBlockValue_assemble_sound(o0, o1, F.BeaconBlockValue.from_value(o0), F.Node9.from_value(o1), BeaconBlockValue_sound(o0), Node9_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def Node107_preserves(original: T.Value, result: Maybe<&2, F.Node107()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node107.to_value(value) == original : T.Value}

law Node107_sound:
  for +original: T.Value
  Node107_preserves(original, F.Node107.from_value(original))
def Node107_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node109_preserves(original: T.Value, result: Maybe<&2, F.Node109()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node109.to_value(value) == original : T.Value}

def Node109_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node7()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node7.seq_to(values) == original : T.Value}

law Node109_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node7()>
  for +head: Maybe<&2, F.Node7()>
  for next: +List<F.Node7()> -> Maybe<&2, +List<F.Node7()>>
  for head_preserves: Node7_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node7()> -> Node109_items_preserve(F.Node7.seq_to_go(a, t), next(a))
  Node109_items_preserve(F.Node7.seq_to_go(acc, T.Items{h, t}), F.Node7.seq_step(head, acc, next))
def Node109_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node109_items_preserve(F.Node7.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node109_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node7()>
  Node109_items_preserve(F.Node7.seq_to_go(acc, original), F.Node7.seq_from_go(original, acc))
def Node109_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node7()>, T.Value, xs => F.Node7.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node7(), List.reverse(&2, F.Node7(), acc)), acc, Lists.reverse_twice(F.Node7(), acc))
    case T.Items{h, t}: Node109_step(h, t, acc, F.Node7.from_value(h), next => F.Node7.seq_from_go(t, next), Node7_sound(h), next => Node109_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node109_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node7()>>
  for preserved: Node109_items_preserve(original, result)
  Node109_preserves(T.Sequence{original}, result)
def Node109_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node7.seq_to(xs), original, preserved)

law Node109_sound:
  for +original: T.Value
  Node109_preserves(original, F.Node109.from_value(original))
def Node109_sound(original):
  match original:
    case T.Sequence{values}: Node109_sequence_sound(values, F.Node7.seq_from_go(values, []), Node109_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def BlobSidecarValue_preserves(original: T.Value, result: Maybe<&2, F.BlobSidecarValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.BlobSidecarValue.to_value(value) == original : T.Value}

law BlobSidecarValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +o5: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node107()>
  for +a2: Maybe<&2, F.Node8()>
  for +a3: Maybe<&2, F.Node8()>
  for +a4: Maybe<&2, F.SignedBeaconBlockHeaderValue()>
  for +a5: Maybe<&2, F.Node109()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node107_preserves(o1, a1)
  for p2: Node8_preserves(o2, a2)
  for p3: Node8_preserves(o3, a3)
  for p4: SignedBeaconBlockHeaderValue_preserves(o4, a4)
  for p5: Node109_preserves(o5, a5)
  BlobSidecarValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}, F.BlobSidecarValue.assemble(a0, a1, a2, a3, a4, a5))
def BlobSidecarValue_assemble_sound(o0, o1, o2, o3, o4, o5, a0, a1, a2, a3, a4, a5, p0, p1, p2, p3, p4, p5):
  match a0 a1 a2 a3 a4 a5:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5}:
      %p0 : {F.BlobSidecarValue.to_value(F.BlobSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p1 : {F.BlobSidecarValue.to_value(F.BlobSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p2 : {F.BlobSidecarValue.to_value(F.BlobSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node107.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p3 : {F.BlobSidecarValue.to_value(F.BlobSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node107.to_value(v1), T.Items{F.Node8.to_value(v2), T.Items{_, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p4 : {F.BlobSidecarValue.to_value(F.BlobSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node107.to_value(v1), T.Items{F.Node8.to_value(v2), T.Items{F.Node8.to_value(v3), T.Items{_, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p5 : {F.BlobSidecarValue.to_value(F.BlobSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node107.to_value(v1), T.Items{F.Node8.to_value(v2), T.Items{F.Node8.to_value(v3), T.Items{F.SignedBeaconBlockHeaderValue.to_value(v4), T.Items{_, T.EmptyItems{}}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{}: Unit{}

law BlobSidecarValue_sound:
  for +original: T.Value
  BlobSidecarValue_preserves(original, F.BlobSidecarValue.from_value(original))
def BlobSidecarValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}: BlobSidecarValue_assemble_sound(o0, o1, o2, o3, o4, o5, F.Node3.from_value(o0), F.Node107.from_value(o1), F.Node8.from_value(o2), F.Node8.from_value(o3), F.SignedBeaconBlockHeaderValue.from_value(o4), F.Node109.from_value(o5), Node3_sound(o0), Node107_sound(o1), Node8_sound(o2), Node8_sound(o3), SignedBeaconBlockHeaderValue_sound(o4), Node109_sound(o5))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BooleanValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.UnsignedValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BytesValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BitsValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Sequence{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Selected{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.NullValue{}}}}}}}}: Unit{}

def Node110_preserves(original: T.Value, result: Maybe<&2, F.Node110()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node110.to_value(value) == original : T.Value}

law Node110_sound:
  for +original: T.Value
  Node110_preserves(original, F.Node110.from_value(original))
def Node110_sound(original):
  match original:
    case T.BytesValue{value}: {==}
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def Node112_preserves(original: T.Value, result: Maybe<&2, F.Node112()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node112.to_value(value) == original : T.Value}

def Node112_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node3()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node3.seq_to(values) == original : T.Value}

law Node112_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node3()>
  for +head: Maybe<&2, F.Node3()>
  for next: +List<F.Node3()> -> Maybe<&2, +List<F.Node3()>>
  for head_preserves: Node3_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node3()> -> Node112_items_preserve(F.Node3.seq_to_go(a, t), next(a))
  Node112_items_preserve(F.Node3.seq_to_go(acc, T.Items{h, t}), F.Node3.seq_step(head, acc, next))
def Node112_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node112_items_preserve(F.Node3.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node112_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node3()>
  Node112_items_preserve(F.Node3.seq_to_go(acc, original), F.Node3.seq_from_go(original, acc))
def Node112_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node3()>, T.Value, xs => F.Node3.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node3(), List.reverse(&2, F.Node3(), acc)), acc, Lists.reverse_twice(F.Node3(), acc))
    case T.Items{h, t}: Node112_step(h, t, acc, F.Node3.from_value(h), next => F.Node3.seq_from_go(t, next), Node3_sound(h), next => Node112_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node112_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node3()>>
  for preserved: Node112_items_preserve(original, result)
  Node112_preserves(T.Sequence{original}, result)
def Node112_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node3.seq_to(xs), original, preserved)

law Node112_sound:
  for +original: T.Value
  Node112_preserves(original, F.Node112.from_value(original))
def Node112_sound(original):
  match original:
    case T.Sequence{values}: Node112_sequence_sound(values, F.Node3.seq_from_go(values, []), Node112_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def DataColumnsByRootIdentifierValue_preserves(original: T.Value, result: Maybe<&2, F.DataColumnsByRootIdentifierValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.DataColumnsByRootIdentifierValue.to_value(value) == original : T.Value}

law DataColumnsByRootIdentifierValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +a0: Maybe<&2, F.Node7()>
  for +a1: Maybe<&2, F.Node112()>
  for p0: Node7_preserves(o0, a0)
  for p1: Node112_preserves(o1, a1)
  DataColumnsByRootIdentifierValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}, F.DataColumnsByRootIdentifierValue.assemble(a0, a1))
def DataColumnsByRootIdentifierValue_assemble_sound(o0, o1, a0, a1, p0, p1):
  match a0 a1:
    case Some{v0} Some{v1}:
      %p0 : {F.DataColumnsByRootIdentifierValue.to_value(F.DataColumnsByRootIdentifier{v0, v1}) == T.Sequence{T.Items{_, T.Items{o1, T.EmptyItems{}}}} : T.Value}
      %p1 : {F.DataColumnsByRootIdentifierValue.to_value(F.DataColumnsByRootIdentifier{v0, v1}) == T.Sequence{T.Items{F.Node7.to_value(v0), T.Items{_, T.EmptyItems{}}}} : T.Value}
      {==}
    case None{} _: Unit{}
    case Some{v0} None{}: Unit{}

law DataColumnsByRootIdentifierValue_sound:
  for +original: T.Value
  DataColumnsByRootIdentifierValue_preserves(original, F.DataColumnsByRootIdentifierValue.from_value(original))
def DataColumnsByRootIdentifierValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: DataColumnsByRootIdentifierValue_assemble_sound(o0, o1, F.Node7.from_value(o0), F.Node112.from_value(o1), Node7_sound(o0), Node112_sound(o1))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}

def MatrixEntryValue_preserves(original: T.Value, result: Maybe<&2, F.MatrixEntryValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.MatrixEntryValue.to_value(value) == original : T.Value}

law MatrixEntryValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +a0: Maybe<&2, F.Node110()>
  for +a1: Maybe<&2, F.Node8()>
  for +a2: Maybe<&2, F.Node3()>
  for +a3: Maybe<&2, F.Node3()>
  for p0: Node110_preserves(o0, a0)
  for p1: Node8_preserves(o1, a1)
  for p2: Node3_preserves(o2, a2)
  for p3: Node3_preserves(o3, a3)
  MatrixEntryValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}, F.MatrixEntryValue.assemble(a0, a1, a2, a3))
def MatrixEntryValue_assemble_sound(o0, o1, o2, o3, a0, a1, a2, a3, p0, p1, p2, p3):
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}:
      %p0 : {F.MatrixEntryValue.to_value(F.MatrixEntry{v0, v1, v2, v3}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p1 : {F.MatrixEntryValue.to_value(F.MatrixEntry{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node110.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p2 : {F.MatrixEntryValue.to_value(F.MatrixEntry{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node110.to_value(v0), T.Items{F.Node8.to_value(v1), T.Items{_, T.Items{o3, T.EmptyItems{}}}}}} : T.Value}
      %p3 : {F.MatrixEntryValue.to_value(F.MatrixEntry{v0, v1, v2, v3}) == T.Sequence{T.Items{F.Node110.to_value(v0), T.Items{F.Node8.to_value(v1), T.Items{F.Node3.to_value(v2), T.Items{_, T.EmptyItems{}}}}}} : T.Value}
      {==}
    case None{} _ _ _: Unit{}
    case Some{v0} None{} _ _: Unit{}
    case Some{v0} Some{v1} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{}: Unit{}

law MatrixEntryValue_sound:
  for +original: T.Value
  MatrixEntryValue_preserves(original, F.MatrixEntryValue.from_value(original))
def MatrixEntryValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: MatrixEntryValue_assemble_sound(o0, o1, o2, o3, F.Node110.from_value(o0), F.Node8.from_value(o1), F.Node3.from_value(o2), F.Node3.from_value(o3), Node110_sound(o0), Node8_sound(o1), Node3_sound(o2), Node3_sound(o3))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}

def Node115_preserves(original: T.Value, result: Maybe<&2, F.Node115()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.Node115.to_value(value) == original : T.Value}

def Node115_items_preserve(original: T.Value, result: Maybe<&2, +List<F.Node110()>>) -> Type:
  match result:
    case None{}: Unit
    case Some{values}: {F.Node110.seq_to(values) == original : T.Value}

law Node115_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<F.Node110()>
  for +head: Maybe<&2, F.Node110()>
  for next: +List<F.Node110()> -> Maybe<&2, +List<F.Node110()>>
  for head_preserves: Node110_preserves(h, head)
  for tail_preserves: @+a: +List<F.Node110()> -> Node115_items_preserve(F.Node110.seq_to_go(a, t), next(a))
  Node115_items_preserve(F.Node110.seq_to_go(acc, T.Items{h, t}), F.Node110.seq_step(head, acc, next))
def Node115_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{}: Unit{}
    case Some{x}:
      %head_preserves : Node115_items_preserve(F.Node110.seq_to_go(acc, T.Items{_, t}), next(x <> acc))
      tail_preserves(x <> acc)

law Node115_items_sound:
  for +original: T.Value
  for +acc: +List<F.Node110()>
  Node115_items_preserve(F.Node110.seq_to_go(acc, original), F.Node110.seq_from_go(original, acc))
def Node115_items_sound(original, acc):
  match original:
    case T.EmptyItems{}: Equal.cong(+List<F.Node110()>, T.Value, xs => F.Node110.seq_to_go(xs, T.EmptyItems{}), List.reverse(&2, F.Node110(), List.reverse(&2, F.Node110(), acc)), acc, Lists.reverse_twice(F.Node110(), acc))
    case T.Items{h, t}: Node115_step(h, t, acc, F.Node110.from_value(h), next => F.Node110.seq_from_go(t, next), Node110_sound(h), next => Node115_items_sound(t, next))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Sequence{bad0}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

law Node115_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<F.Node110()>>
  for preserved: Node115_items_preserve(original, result)
  Node115_preserves(T.Sequence{original}, result)
def Node115_sequence_sound(original, result, preserved):
  match result:
    case None{}: Unit{}
    case Some{xs}: Equal.cong(T.Value, T.Value, value => T.Sequence{value}, F.Node110.seq_to(xs), original, preserved)

law Node115_sound:
  for +original: T.Value
  Node115_preserves(original, F.Node115.from_value(original))
def Node115_sound(original):
  match original:
    case T.Sequence{values}: Node115_sequence_sound(values, F.Node110.seq_from_go(values, []), Node115_items_sound(values, []))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}

def DataColumnSidecarValue_preserves(original: T.Value, result: Maybe<&2, F.DataColumnSidecarValue()>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {F.DataColumnSidecarValue.to_value(value) == original : T.Value}

law DataColumnSidecarValue_assemble_sound:
  for +o0: T.Value
  for +o1: T.Value
  for +o2: T.Value
  for +o3: T.Value
  for +o4: T.Value
  for +o5: T.Value
  for +a0: Maybe<&2, F.Node3()>
  for +a1: Maybe<&2, F.Node115()>
  for +a2: Maybe<&2, F.Node104()>
  for +a3: Maybe<&2, F.Node104()>
  for +a4: Maybe<&2, F.SignedBeaconBlockHeaderValue()>
  for +a5: Maybe<&2, F.Node90()>
  for p0: Node3_preserves(o0, a0)
  for p1: Node115_preserves(o1, a1)
  for p2: Node104_preserves(o2, a2)
  for p3: Node104_preserves(o3, a3)
  for p4: SignedBeaconBlockHeaderValue_preserves(o4, a4)
  for p5: Node90_preserves(o5, a5)
  DataColumnSidecarValue_preserves(T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}, F.DataColumnSidecarValue.assemble(a0, a1, a2, a3, a4, a5))
def DataColumnSidecarValue_assemble_sound(o0, o1, o2, o3, o4, o5, a0, a1, a2, a3, a4, a5, p0, p1, p2, p3, p4, p5):
  match a0 a1 a2 a3 a4 a5:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5}:
      %p0 : {F.DataColumnSidecarValue.to_value(F.DataColumnSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{_, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p1 : {F.DataColumnSidecarValue.to_value(F.DataColumnSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{_, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p2 : {F.DataColumnSidecarValue.to_value(F.DataColumnSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node115.to_value(v1), T.Items{_, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p3 : {F.DataColumnSidecarValue.to_value(F.DataColumnSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node115.to_value(v1), T.Items{F.Node104.to_value(v2), T.Items{_, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p4 : {F.DataColumnSidecarValue.to_value(F.DataColumnSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node115.to_value(v1), T.Items{F.Node104.to_value(v2), T.Items{F.Node104.to_value(v3), T.Items{_, T.Items{o5, T.EmptyItems{}}}}}}}} : T.Value}
      %p5 : {F.DataColumnSidecarValue.to_value(F.DataColumnSidecar{v0, v1, v2, v3, v4, v5}) == T.Sequence{T.Items{F.Node3.to_value(v0), T.Items{F.Node115.to_value(v1), T.Items{F.Node104.to_value(v2), T.Items{F.Node104.to_value(v3), T.Items{F.SignedBeaconBlockHeaderValue.to_value(v4), T.Items{_, T.EmptyItems{}}}}}}}} : T.Value}
      {==}
    case None{} _ _ _ _ _: Unit{}
    case Some{v0} None{} _ _ _ _: Unit{}
    case Some{v0} Some{v1} None{} _ _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} None{} _ _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} None{} _: Unit{}
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} None{}: Unit{}

law DataColumnSidecarValue_sound:
  for +original: T.Value
  DataColumnSidecarValue_preserves(original, F.DataColumnSidecarValue.from_value(original))
def DataColumnSidecarValue_sound(original):
  match original:
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.EmptyItems{}}}}}}}}: DataColumnSidecarValue_assemble_sound(o0, o1, o2, o3, o4, o5, F.Node3.from_value(o0), F.Node115.from_value(o1), F.Node104.from_value(o2), F.Node104.from_value(o3), F.SignedBeaconBlockHeaderValue.from_value(o4), F.Node90.from_value(o5), Node3_sound(o0), Node115_sound(o1), Node104_sound(o2), Node104_sound(o3), SignedBeaconBlockHeaderValue_sound(o4), Node90_sound(o5))
    case T.BooleanValue{bad0}: Unit{}
    case T.UnsignedValue{bad0}: Unit{}
    case T.BytesValue{bad0}: Unit{}
    case T.BitsValue{bad0}: Unit{}
    case T.Items{bad0, bad1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{bad0, bad1}: Unit{}
    case T.NullValue{}: Unit{}
    case T.Sequence{T.BooleanValue{bad0}}: Unit{}
    case T.Sequence{T.UnsignedValue{bad0}}: Unit{}
    case T.Sequence{T.BytesValue{bad0}}: Unit{}
    case T.Sequence{T.BitsValue{bad0}}: Unit{}
    case T.Sequence{T.Sequence{bad0}}: Unit{}
    case T.Sequence{T.EmptyItems{}}: Unit{}
    case T.Sequence{T.Selected{bad0, bad1}}: Unit{}
    case T.Sequence{T.NullValue{}}: Unit{}
    case T.Sequence{T.Items{o0, T.BooleanValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.UnsignedValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BytesValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.BitsValue{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Sequence{bad0}}}: Unit{}
    case T.Sequence{T.Items{o0, T.EmptyItems{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Selected{bad0, bad1}}}: Unit{}
    case T.Sequence{T.Items{o0, T.NullValue{}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BooleanValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.UnsignedValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BytesValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.BitsValue{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Sequence{bad0}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.EmptyItems{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Selected{bad0, bad1}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.NullValue{}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BooleanValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.UnsignedValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BytesValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.BitsValue{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Sequence{bad0}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.EmptyItems{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Selected{bad0, bad1}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.NullValue{}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BooleanValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.UnsignedValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BytesValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.BitsValue{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Sequence{bad0}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.EmptyItems{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Selected{bad0, bad1}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.NullValue{}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BooleanValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.UnsignedValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BytesValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.BitsValue{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Sequence{bad0}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.EmptyItems{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Selected{bad0, bad1}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.NullValue{}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BooleanValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.UnsignedValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BytesValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.BitsValue{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Sequence{bad0}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Items{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.Selected{bad0, bad1}}}}}}}}: Unit{}
    case T.Sequence{T.Items{o0, T.Items{o1, T.Items{o2, T.Items{o3, T.Items{o4, T.Items{o5, T.NullValue{}}}}}}}}: Unit{}

law boolean_representation_preserved:
  for +original: T.Value
  Node0_preserves(original, F.boolean.from_ssz(original))
def boolean_representation_preserved(original): Node0_sound(original)

law uint8_representation_preserved:
  for +original: T.Value
  Node1_preserves(original, F.uint8.from_ssz(original))
def uint8_representation_preserved(original): Node1_sound(original)

law uint32_representation_preserved:
  for +original: T.Value
  Node2_preserves(original, F.uint32.from_ssz(original))
def uint32_representation_preserved(original): Node2_sound(original)

law uint64_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.uint64.from_ssz(original))
def uint64_representation_preserved(original): Node3_sound(original)

law uint256_representation_preserved:
  for +original: T.Value
  Node4_preserves(original, F.uint256.from_ssz(original))
def uint256_representation_preserved(original): Node4_sound(original)

law Bytes1_representation_preserved:
  for +original: T.Value
  Node5_preserves(original, F.Bytes1.from_ssz(original))
def Bytes1_representation_preserved(original): Node5_sound(original)

law Bytes4_representation_preserved:
  for +original: T.Value
  Node6_preserves(original, F.Bytes4.from_ssz(original))
def Bytes4_representation_preserved(original): Node6_sound(original)

law Bytes32_representation_preserved:
  for +original: T.Value
  Node7_preserves(original, F.Bytes32.from_ssz(original))
def Bytes32_representation_preserved(original): Node7_sound(original)

law Bytes48_representation_preserved:
  for +original: T.Value
  Node8_preserves(original, F.Bytes48.from_ssz(original))
def Bytes48_representation_preserved(original): Node8_sound(original)

law Bytes96_representation_preserved:
  for +original: T.Value
  Node9_preserves(original, F.Bytes96.from_ssz(original))
def Bytes96_representation_preserved(original): Node9_sound(original)

law Bytes8_representation_preserved:
  for +original: T.Value
  Node10_preserves(original, F.Bytes8.from_ssz(original))
def Bytes8_representation_preserved(original): Node10_sound(original)

law Bytes20_representation_preserved:
  for +original: T.Value
  Node11_preserves(original, F.Bytes20.from_ssz(original))
def Bytes20_representation_preserved(original): Node11_sound(original)

law Slot_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.Slot.from_ssz(original))
def Slot_representation_preserved(original): Node3_sound(original)

law Epoch_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.Epoch.from_ssz(original))
def Epoch_representation_preserved(original): Node3_sound(original)

law Gwei_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.Gwei.from_ssz(original))
def Gwei_representation_preserved(original): Node3_sound(original)

law Hash32_representation_preserved:
  for +original: T.Value
  Node7_preserves(original, F.Hash32.from_ssz(original))
def Hash32_representation_preserved(original): Node7_sound(original)

law Version_representation_preserved:
  for +original: T.Value
  Node6_preserves(original, F.Version.from_ssz(original))
def Version_representation_preserved(original): Node6_sound(original)

law DomainType_representation_preserved:
  for +original: T.Value
  Node6_preserves(original, F.DomainType.from_ssz(original))
def DomainType_representation_preserved(original): Node6_sound(original)

law BLSSignature_representation_preserved:
  for +original: T.Value
  Node9_preserves(original, F.BLSSignature.from_ssz(original))
def BLSSignature_representation_preserved(original): Node9_sound(original)

law FinalityBranch_representation_preserved:
  for +original: T.Value
  Node12_preserves(original, F.FinalityBranch.from_ssz(original))
def FinalityBranch_representation_preserved(original): Node12_sound(original)

law VersionedHash_representation_preserved:
  for +original: T.Value
  Node7_preserves(original, F.VersionedHash.from_ssz(original))
def VersionedHash_representation_preserved(original): Node7_sound(original)

law G1Point_representation_preserved:
  for +original: T.Value
  Node8_preserves(original, F.G1Point.from_ssz(original))
def G1Point_representation_preserved(original): Node8_sound(original)

law G2Point_representation_preserved:
  for +original: T.Value
  Node9_preserves(original, F.G2Point.from_ssz(original))
def G2Point_representation_preserved(original): Node9_sound(original)

law Fork_representation_preserved:
  for +original: T.Value
  ForkValue_preserves(original, F.Fork.from_ssz(original))
def Fork_representation_preserved(original): ForkValue_sound(original)

law SyncAggregate_representation_preserved:
  for +original: T.Value
  SyncAggregateValue_preserves(original, F.SyncAggregate.from_ssz(original))
def SyncAggregate_representation_preserved(original): SyncAggregateValue_sound(original)

law SyncAggregatorSelectionData_representation_preserved:
  for +original: T.Value
  SyncAggregatorSelectionDataValue_preserves(original, F.SyncAggregatorSelectionData.from_ssz(original))
def SyncAggregatorSelectionData_representation_preserved(original): SyncAggregatorSelectionDataValue_sound(original)

law PowBlock_representation_preserved:
  for +original: T.Value
  PowBlockValue_preserves(original, F.PowBlock.from_ssz(original))
def PowBlock_representation_preserved(original): PowBlockValue_sound(original)

law CommitteeIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.CommitteeIndex.from_ssz(original))
def CommitteeIndex_representation_preserved(original): Node3_sound(original)

law ValidatorIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.ValidatorIndex.from_ssz(original))
def ValidatorIndex_representation_preserved(original): Node3_sound(original)

law PendingConsolidation_representation_preserved:
  for +original: T.Value
  PendingConsolidationValue_preserves(original, F.PendingConsolidation.from_ssz(original))
def PendingConsolidation_representation_preserved(original): PendingConsolidationValue_sound(original)

law PendingPartialWithdrawal_representation_preserved:
  for +original: T.Value
  PendingPartialWithdrawalValue_preserves(original, F.PendingPartialWithdrawal.from_ssz(original))
def PendingPartialWithdrawal_representation_preserved(original): PendingPartialWithdrawalValue_sound(original)

law VoluntaryExit_representation_preserved:
  for +original: T.Value
  VoluntaryExitValue_preserves(original, F.VoluntaryExit.from_ssz(original))
def VoluntaryExit_representation_preserved(original): VoluntaryExitValue_sound(original)

law SignedVoluntaryExit_representation_preserved:
  for +original: T.Value
  SignedVoluntaryExitValue_preserves(original, F.SignedVoluntaryExit.from_ssz(original))
def SignedVoluntaryExit_representation_preserved(original): SignedVoluntaryExitValue_sound(original)

law Root_representation_preserved:
  for +original: T.Value
  Node7_preserves(original, F.Root.from_ssz(original))
def Root_representation_preserved(original): Node7_sound(original)

law HistoricalSummary_representation_preserved:
  for +original: T.Value
  HistoricalSummaryValue_preserves(original, F.HistoricalSummary.from_ssz(original))
def HistoricalSummary_representation_preserved(original): HistoricalSummaryValue_sound(original)

law SyncCommitteeContribution_representation_preserved:
  for +original: T.Value
  SyncCommitteeContributionValue_preserves(original, F.SyncCommitteeContribution.from_ssz(original))
def SyncCommitteeContribution_representation_preserved(original): SyncCommitteeContributionValue_sound(original)

law ContributionAndProof_representation_preserved:
  for +original: T.Value
  ContributionAndProofValue_preserves(original, F.ContributionAndProof.from_ssz(original))
def ContributionAndProof_representation_preserved(original): ContributionAndProofValue_sound(original)

law SignedContributionAndProof_representation_preserved:
  for +original: T.Value
  SignedContributionAndProofValue_preserves(original, F.SignedContributionAndProof.from_ssz(original))
def SignedContributionAndProof_representation_preserved(original): SignedContributionAndProofValue_sound(original)

law SyncCommitteeMessage_representation_preserved:
  for +original: T.Value
  SyncCommitteeMessageValue_preserves(original, F.SyncCommitteeMessage.from_ssz(original))
def SyncCommitteeMessage_representation_preserved(original): SyncCommitteeMessageValue_sound(original)

law Eth1Block_representation_preserved:
  for +original: T.Value
  Eth1BlockValue_preserves(original, F.Eth1Block.from_ssz(original))
def Eth1Block_representation_preserved(original): Eth1BlockValue_sound(original)

law BeaconBlockHeader_representation_preserved:
  for +original: T.Value
  BeaconBlockHeaderValue_preserves(original, F.BeaconBlockHeader.from_ssz(original))
def BeaconBlockHeader_representation_preserved(original): BeaconBlockHeaderValue_sound(original)

law SignedBeaconBlockHeader_representation_preserved:
  for +original: T.Value
  SignedBeaconBlockHeaderValue_preserves(original, F.SignedBeaconBlockHeader.from_ssz(original))
def SignedBeaconBlockHeader_representation_preserved(original): SignedBeaconBlockHeaderValue_sound(original)

law ProposerSlashing_representation_preserved:
  for +original: T.Value
  ProposerSlashingValue_preserves(original, F.ProposerSlashing.from_ssz(original))
def ProposerSlashing_representation_preserved(original): ProposerSlashingValue_sound(original)

law HistoricalBatch_representation_preserved:
  for +original: T.Value
  HistoricalBatchValue_preserves(original, F.HistoricalBatch.from_ssz(original))
def HistoricalBatch_representation_preserved(original): HistoricalBatchValue_sound(original)

law Eth1Data_representation_preserved:
  for +original: T.Value
  Eth1DataValue_preserves(original, F.Eth1Data.from_ssz(original))
def Eth1Data_representation_preserved(original): Eth1DataValue_sound(original)

law Checkpoint_representation_preserved:
  for +original: T.Value
  CheckpointValue_preserves(original, F.Checkpoint.from_ssz(original))
def Checkpoint_representation_preserved(original): CheckpointValue_sound(original)

law AttestationData_representation_preserved:
  for +original: T.Value
  AttestationDataValue_preserves(original, F.AttestationData.from_ssz(original))
def AttestationData_representation_preserved(original): AttestationDataValue_sound(original)

law SingleAttestation_representation_preserved:
  for +original: T.Value
  SingleAttestationValue_preserves(original, F.SingleAttestation.from_ssz(original))
def SingleAttestation_representation_preserved(original): SingleAttestationValue_sound(original)

law Attestation_representation_preserved:
  for +original: T.Value
  AttestationValue_preserves(original, F.Attestation.from_ssz(original))
def Attestation_representation_preserved(original): AttestationValue_sound(original)

law AggregateAndProof_representation_preserved:
  for +original: T.Value
  AggregateAndProofValue_preserves(original, F.AggregateAndProof.from_ssz(original))
def AggregateAndProof_representation_preserved(original): AggregateAndProofValue_sound(original)

law SignedAggregateAndProof_representation_preserved:
  for +original: T.Value
  SignedAggregateAndProofValue_preserves(original, F.SignedAggregateAndProof.from_ssz(original))
def SignedAggregateAndProof_representation_preserved(original): SignedAggregateAndProofValue_sound(original)

law PendingAttestation_representation_preserved:
  for +original: T.Value
  PendingAttestationValue_preserves(original, F.PendingAttestation.from_ssz(original))
def PendingAttestation_representation_preserved(original): PendingAttestationValue_sound(original)

law IndexedAttestation_representation_preserved:
  for +original: T.Value
  IndexedAttestationValue_preserves(original, F.IndexedAttestation.from_ssz(original))
def IndexedAttestation_representation_preserved(original): IndexedAttestationValue_sound(original)

law AttesterSlashing_representation_preserved:
  for +original: T.Value
  AttesterSlashingValue_preserves(original, F.AttesterSlashing.from_ssz(original))
def AttesterSlashing_representation_preserved(original): AttesterSlashingValue_sound(original)

law ForkData_representation_preserved:
  for +original: T.Value
  ForkDataValue_preserves(original, F.ForkData.from_ssz(original))
def ForkData_representation_preserved(original): ForkDataValue_sound(original)

law ForkDigest_representation_preserved:
  for +original: T.Value
  Node6_preserves(original, F.ForkDigest.from_ssz(original))
def ForkDigest_representation_preserved(original): Node6_sound(original)

law Domain_representation_preserved:
  for +original: T.Value
  Node7_preserves(original, F.Domain.from_ssz(original))
def Domain_representation_preserved(original): Node7_sound(original)

law SigningData_representation_preserved:
  for +original: T.Value
  SigningDataValue_preserves(original, F.SigningData.from_ssz(original))
def SigningData_representation_preserved(original): SigningDataValue_sound(original)

law BLSPubkey_representation_preserved:
  for +original: T.Value
  Node8_preserves(original, F.BLSPubkey.from_ssz(original))
def BLSPubkey_representation_preserved(original): Node8_sound(original)

law DepositRequest_representation_preserved:
  for +original: T.Value
  DepositRequestValue_preserves(original, F.DepositRequest.from_ssz(original))
def DepositRequest_representation_preserved(original): DepositRequestValue_sound(original)

law PendingDeposit_representation_preserved:
  for +original: T.Value
  PendingDepositValue_preserves(original, F.PendingDeposit.from_ssz(original))
def PendingDeposit_representation_preserved(original): PendingDepositValue_sound(original)

law SyncCommittee_representation_preserved:
  for +original: T.Value
  SyncCommitteeValue_preserves(original, F.SyncCommittee.from_ssz(original))
def SyncCommittee_representation_preserved(original): SyncCommitteeValue_sound(original)

law DepositData_representation_preserved:
  for +original: T.Value
  DepositDataValue_preserves(original, F.DepositData.from_ssz(original))
def DepositData_representation_preserved(original): DepositDataValue_sound(original)

law Deposit_representation_preserved:
  for +original: T.Value
  DepositValue_preserves(original, F.Deposit.from_ssz(original))
def Deposit_representation_preserved(original): DepositValue_sound(original)

law DepositMessage_representation_preserved:
  for +original: T.Value
  DepositMessageValue_preserves(original, F.DepositMessage.from_ssz(original))
def DepositMessage_representation_preserved(original): DepositMessageValue_sound(original)

law Validator_representation_preserved:
  for +original: T.Value
  ValidatorValue_preserves(original, F.Validator.from_ssz(original))
def Validator_representation_preserved(original): ValidatorValue_sound(original)

law NodeID_representation_preserved:
  for +original: T.Value
  Node4_preserves(original, F.NodeID.from_ssz(original))
def NodeID_representation_preserved(original): Node4_sound(original)

law SubnetID_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.SubnetID.from_ssz(original))
def SubnetID_representation_preserved(original): Node3_sound(original)

law Ether_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.Ether.from_ssz(original))
def Ether_representation_preserved(original): Node3_sound(original)

law ParticipationFlags_representation_preserved:
  for +original: T.Value
  Node1_preserves(original, F.ParticipationFlags.from_ssz(original))
def ParticipationFlags_representation_preserved(original): Node1_sound(original)

law CurrentSyncCommitteeBranch_representation_preserved:
  for +original: T.Value
  Node59_preserves(original, F.CurrentSyncCommitteeBranch.from_ssz(original))
def CurrentSyncCommitteeBranch_representation_preserved(original): Node59_sound(original)

law NextSyncCommitteeBranch_representation_preserved:
  for +original: T.Value
  Node59_preserves(original, F.NextSyncCommitteeBranch.from_ssz(original))
def NextSyncCommitteeBranch_representation_preserved(original): Node59_sound(original)

law Transaction_representation_preserved:
  for +original: T.Value
  Node60_preserves(original, F.Transaction.from_ssz(original))
def Transaction_representation_preserved(original): Node60_sound(original)

law ExecutionAddress_representation_preserved:
  for +original: T.Value
  Node11_preserves(original, F.ExecutionAddress.from_ssz(original))
def ExecutionAddress_representation_preserved(original): Node11_sound(original)

law ConsolidationRequest_representation_preserved:
  for +original: T.Value
  ConsolidationRequestValue_preserves(original, F.ConsolidationRequest.from_ssz(original))
def ConsolidationRequest_representation_preserved(original): ConsolidationRequestValue_sound(original)

law WithdrawalRequest_representation_preserved:
  for +original: T.Value
  WithdrawalRequestValue_preserves(original, F.WithdrawalRequest.from_ssz(original))
def WithdrawalRequest_representation_preserved(original): WithdrawalRequestValue_sound(original)

law ExecutionRequests_representation_preserved:
  for +original: T.Value
  ExecutionRequestsValue_preserves(original, F.ExecutionRequests.from_ssz(original))
def ExecutionRequests_representation_preserved(original): ExecutionRequestsValue_sound(original)

law BLSToExecutionChange_representation_preserved:
  for +original: T.Value
  BLSToExecutionChangeValue_preserves(original, F.BLSToExecutionChange.from_ssz(original))
def BLSToExecutionChange_representation_preserved(original): BLSToExecutionChangeValue_sound(original)

law SignedBLSToExecutionChange_representation_preserved:
  for +original: T.Value
  SignedBLSToExecutionChangeValue_preserves(original, F.SignedBLSToExecutionChange.from_ssz(original))
def SignedBLSToExecutionChange_representation_preserved(original): SignedBLSToExecutionChangeValue_sound(original)

law ExecutionPayloadHeader_representation_preserved:
  for +original: T.Value
  ExecutionPayloadHeaderValue_preserves(original, F.ExecutionPayloadHeader.from_ssz(original))
def ExecutionPayloadHeader_representation_preserved(original): ExecutionPayloadHeaderValue_sound(original)

law PayloadId_representation_preserved:
  for +original: T.Value
  Node10_preserves(original, F.PayloadId.from_ssz(original))
def PayloadId_representation_preserved(original): Node10_sound(original)

law WithdrawalIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.WithdrawalIndex.from_ssz(original))
def WithdrawalIndex_representation_preserved(original): Node3_sound(original)

law Withdrawal_representation_preserved:
  for +original: T.Value
  WithdrawalValue_preserves(original, F.Withdrawal.from_ssz(original))
def Withdrawal_representation_preserved(original): WithdrawalValue_sound(original)

law ExecutionPayload_representation_preserved:
  for +original: T.Value
  ExecutionPayloadValue_preserves(original, F.ExecutionPayload.from_ssz(original))
def ExecutionPayload_representation_preserved(original): ExecutionPayloadValue_sound(original)

law BeaconState_representation_preserved:
  for +original: T.Value
  BeaconStateValue_preserves(original, F.BeaconState.from_ssz(original))
def BeaconState_representation_preserved(original): BeaconStateValue_sound(original)

law ExecutionBranch_representation_preserved:
  for +original: T.Value
  Node90_preserves(original, F.ExecutionBranch.from_ssz(original))
def ExecutionBranch_representation_preserved(original): Node90_sound(original)

law LightClientHeader_representation_preserved:
  for +original: T.Value
  LightClientHeaderValue_preserves(original, F.LightClientHeader.from_ssz(original))
def LightClientHeader_representation_preserved(original): LightClientHeaderValue_sound(original)

law LightClientOptimisticUpdate_representation_preserved:
  for +original: T.Value
  LightClientOptimisticUpdateValue_preserves(original, F.LightClientOptimisticUpdate.from_ssz(original))
def LightClientOptimisticUpdate_representation_preserved(original): LightClientOptimisticUpdateValue_sound(original)

law LightClientFinalityUpdate_representation_preserved:
  for +original: T.Value
  LightClientFinalityUpdateValue_preserves(original, F.LightClientFinalityUpdate.from_ssz(original))
def LightClientFinalityUpdate_representation_preserved(original): LightClientFinalityUpdateValue_sound(original)

law LightClientUpdate_representation_preserved:
  for +original: T.Value
  LightClientUpdateValue_preserves(original, F.LightClientUpdate.from_ssz(original))
def LightClientUpdate_representation_preserved(original): LightClientUpdateValue_sound(original)

law LightClientBootstrap_representation_preserved:
  for +original: T.Value
  LightClientBootstrapValue_preserves(original, F.LightClientBootstrap.from_ssz(original))
def LightClientBootstrap_representation_preserved(original): LightClientBootstrapValue_sound(original)

law BlobIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.BlobIndex.from_ssz(original))
def BlobIndex_representation_preserved(original): Node3_sound(original)

law BlobIdentifier_representation_preserved:
  for +original: T.Value
  BlobIdentifierValue_preserves(original, F.BlobIdentifier.from_ssz(original))
def BlobIdentifier_representation_preserved(original): BlobIdentifierValue_sound(original)

law KZGCommitment_representation_preserved:
  for +original: T.Value
  Node8_preserves(original, F.KZGCommitment.from_ssz(original))
def KZGCommitment_representation_preserved(original): Node8_sound(original)

law BeaconBlockBody_representation_preserved:
  for +original: T.Value
  BeaconBlockBodyValue_preserves(original, F.BeaconBlockBody.from_ssz(original))
def BeaconBlockBody_representation_preserved(original): BeaconBlockBodyValue_sound(original)

law BeaconBlock_representation_preserved:
  for +original: T.Value
  BeaconBlockValue_preserves(original, F.BeaconBlock.from_ssz(original))
def BeaconBlock_representation_preserved(original): BeaconBlockValue_sound(original)

law SignedBeaconBlock_representation_preserved:
  for +original: T.Value
  SignedBeaconBlockValue_preserves(original, F.SignedBeaconBlock.from_ssz(original))
def SignedBeaconBlock_representation_preserved(original): SignedBeaconBlockValue_sound(original)

law KZGProof_representation_preserved:
  for +original: T.Value
  Node8_preserves(original, F.KZGProof.from_ssz(original))
def KZGProof_representation_preserved(original): Node8_sound(original)

law Blob_representation_preserved:
  for +original: T.Value
  Node107_preserves(original, F.Blob.from_ssz(original))
def Blob_representation_preserved(original): Node107_sound(original)

law BlobSidecar_representation_preserved:
  for +original: T.Value
  BlobSidecarValue_preserves(original, F.BlobSidecar.from_ssz(original))
def BlobSidecar_representation_preserved(original): BlobSidecarValue_sound(original)

law Cell_representation_preserved:
  for +original: T.Value
  Node110_preserves(original, F.Cell.from_ssz(original))
def Cell_representation_preserved(original): Node110_sound(original)

law CellIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.CellIndex.from_ssz(original))
def CellIndex_representation_preserved(original): Node3_sound(original)

law CommitmentIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.CommitmentIndex.from_ssz(original))
def CommitmentIndex_representation_preserved(original): Node3_sound(original)

law RowIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.RowIndex.from_ssz(original))
def RowIndex_representation_preserved(original): Node3_sound(original)

law ColumnIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.ColumnIndex.from_ssz(original))
def ColumnIndex_representation_preserved(original): Node3_sound(original)

law DataColumnsByRootIdentifier_representation_preserved:
  for +original: T.Value
  DataColumnsByRootIdentifierValue_preserves(original, F.DataColumnsByRootIdentifier.from_ssz(original))
def DataColumnsByRootIdentifier_representation_preserved(original): DataColumnsByRootIdentifierValue_sound(original)

law MatrixEntry_representation_preserved:
  for +original: T.Value
  MatrixEntryValue_preserves(original, F.MatrixEntry.from_ssz(original))
def MatrixEntry_representation_preserved(original): MatrixEntryValue_sound(original)

law DataColumnSidecar_representation_preserved:
  for +original: T.Value
  DataColumnSidecarValue_preserves(original, F.DataColumnSidecar.from_ssz(original))
def DataColumnSidecar_representation_preserved(original): DataColumnSidecarValue_sound(original)

law CustodyIndex_representation_preserved:
  for +original: T.Value
  Node3_preserves(original, F.CustodyIndex.from_ssz(original))
def CustodyIndex_representation_preserved(original): Node3_sound(original)

