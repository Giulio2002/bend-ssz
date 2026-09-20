import Base
import ../../../types/schema.bend as T
import ../../../types/primitive.bend as P
import ../../../src/ssz.bend as API
import ../../../spec/fulu_schemas.bend as Spec

def Node0() -> Data: Bool
def Node0.to_value(v: Node0()) -> T.Value: T.BooleanValue{v}
def Node0.from_value(value: T.Value) -> Maybe<&2, Node0()>:
  match value:
    case T.BooleanValue{v}: Some{v}
    case _: None{}
def Node0.schema() -> T.Schema: Spec.Schema0()

def Node1() -> Data: P.UInt
def Node1.to_value(v: Node1()) -> T.Value: T.UnsignedValue{v}
def Node1.from_value(value: T.Value) -> Maybe<&2, Node1()>:
  match value:
    case T.UnsignedValue{v}: Some{v}
    case _: None{}
def Node1.schema() -> T.Schema: Spec.Schema1()

def Node2() -> Data: P.UInt
def Node2.to_value(v: Node2()) -> T.Value: T.UnsignedValue{v}
def Node2.from_value(value: T.Value) -> Maybe<&2, Node2()>:
  match value:
    case T.UnsignedValue{v}: Some{v}
    case _: None{}
def Node2.schema() -> T.Schema: Spec.Schema2()

def Node3() -> Data: P.UInt
def Node3.to_value(v: Node3()) -> T.Value: T.UnsignedValue{v}
def Node3.from_value(value: T.Value) -> Maybe<&2, Node3()>:
  match value:
    case T.UnsignedValue{v}: Some{v}
    case _: None{}
def Node3.schema() -> T.Schema: Spec.Schema3()

def Node4() -> Data: P.UInt
def Node4.to_value(v: Node4()) -> T.Value: T.UnsignedValue{v}
def Node4.from_value(value: T.Value) -> Maybe<&2, Node4()>:
  match value:
    case T.UnsignedValue{v}: Some{v}
    case _: None{}
def Node4.schema() -> T.Schema: Spec.Schema4()

def Node5() -> Data: +List<U32>
def Node5.to_value(v: Node5()) -> T.Value: T.BytesValue{v}
def Node5.from_value(value: T.Value) -> Maybe<&2, Node5()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node5.schema() -> T.Schema: Spec.Schema5()

def Node6() -> Data: +List<U32>
def Node6.to_value(v: Node6()) -> T.Value: T.BytesValue{v}
def Node6.from_value(value: T.Value) -> Maybe<&2, Node6()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node6.schema() -> T.Schema: Spec.Schema6()

def Node7() -> Data: +List<U32>
def Node7.to_value(v: Node7()) -> T.Value: T.BytesValue{v}
def Node7.from_value(value: T.Value) -> Maybe<&2, Node7()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node7.schema() -> T.Schema: Spec.Schema7()

def Node8() -> Data: +List<U32>
def Node8.to_value(v: Node8()) -> T.Value: T.BytesValue{v}
def Node8.from_value(value: T.Value) -> Maybe<&2, Node8()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node8.schema() -> T.Schema: Spec.Schema8()

def Node9() -> Data: +List<U32>
def Node9.to_value(v: Node9()) -> T.Value: T.BytesValue{v}
def Node9.from_value(value: T.Value) -> Maybe<&2, Node9()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node9.schema() -> T.Schema: Spec.Schema9()

def Node10() -> Data: +List<U32>
def Node10.to_value(v: Node10()) -> T.Value: T.BytesValue{v}
def Node10.from_value(value: T.Value) -> Maybe<&2, Node10()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node10.schema() -> T.Schema: Spec.Schema10()

def Node11() -> Data: +List<U32>
def Node11.to_value(v: Node11()) -> T.Value: T.BytesValue{v}
def Node11.from_value(value: T.Value) -> Maybe<&2, Node11()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node11.schema() -> T.Schema: Spec.Schema11()

def Node7.seq_to_go(xs: +List<Node7()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: Node7.seq_to_go(t, T.Items{Node7.to_value(h), acc})

def Node7.seq_to(xs: +List<Node7()>) -> T.Value:
  Node7.seq_to_go(List.reverse(&2, Node7(), xs), T.EmptyItems{})

def Node7.seq_step(result: Maybe<&2, Node7()>, acc: +List<Node7()>, next: +List<Node7()> -> Maybe<&2, +List<Node7()>>) -> Maybe<&2, +List<Node7()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def Node7.seq_from_go(value: T.Value, acc: +List<Node7()>) -> Maybe<&2, +List<Node7()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, Node7(), acc)}
    case T.Items{h, t}: Node7.seq_step(Node7.from_value(h), acc, next => Node7.seq_from_go(t, next))
    case _: None{}

def Node7.seq_from(value: T.Value) -> Maybe<&2, +List<Node7()>>:
  Node7.seq_from_go(value, [])

type Fork is Data:
  Fork{previous_version: Node6(), current_version: Node6(), epoch: Node3()}
def ForkValue() -> Data: Fork
def ForkValue.to_value(v: ForkValue()) -> T.Value:
  Fork{previous_version, current_version, epoch} = v
  T.Sequence{T.Items{Node6.to_value(previous_version), T.Items{Node6.to_value(current_version), T.Items{Node3.to_value(epoch), T.EmptyItems{}}}}}
def ForkValue.assemble(a0: Maybe<&2, Node6()>, a1: Maybe<&2, Node6()>, a2: Maybe<&2, Node3()>) -> Maybe<&2, ForkValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{Fork{v0, v1, v2}}
    case _ _ _: None{}
def ForkValue.from_value(v: T.Value) -> Maybe<&2, ForkValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: ForkValue.assemble(Node6.from_value(v0), Node6.from_value(v1), Node3.from_value(v2))
    case _: None{}
def ForkValue.schema() -> T.Schema: Spec.Schema13()


def main() -> Maybe<&2, ForkValue()>: ForkValue.from_value(T.NullValue{})
