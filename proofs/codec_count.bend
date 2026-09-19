import Base
import ../types/schema.bend as T
import ../src/codec.bend as I
import ../spec/codec.bend as S
import ./packing.bend as P

law count_go_correct:
  for +value: T.Value
  for +acc: Nat
  {I.count_go(value, acc) == Nat.add(S.count(value), acc) : Nat}
def count_go_correct(value, acc):
  match value:
    case T.Items{h, t}:
      %P.add_succ(S.count(t), acc) : {I.count_go(t, 1n+acc) == _ : Nat}
      count_go_correct(t, 1n+acc)
    case T.BooleanValue{v0}: {==}
    case T.UnsignedValue{v0}: {==}
    case T.BytesValue{v0}: {==}
    case T.BitsValue{v0}: {==}
    case T.Sequence{v0}: {==}
    case T.EmptyItems{}: {==}
    case T.Selected{v0, v1}: {==}
    case T.NullValue{}: {==}

law count_correct:
  for +value: T.Value
  {I.count(value) == S.count(value) : Nat}
def count_correct(value):
  Equal.trans(Nat, I.count(value), Nat.add(S.count(value), 0n), S.count(value), count_go_correct(value, 0n), P.add_zero(S.count(value)))
