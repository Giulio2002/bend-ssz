import Base
import ../types/primitive.bend as P

# Neutral recursive representations only. Names participate in compatibility,
# while container values retain declaration order in their sequence.
type Schema is Data:
  Boolean{}
  Unsigned{width: P.Width}
  ByteVector{length: Nat}
  ByteList{limit: Nat}
  BitVector{length: Nat}
  BitList{limit: Nat}
  Vector{element: Schema, length: Nat}
  ListOf{element: Schema, limit: Nat}
  Container{names: +List<String>, fields: Schema}
  Union{options: Schema}
  Null{}
  Chain{head: Schema, tail: Schema}
  End{}
  Repeat{element: Schema}
  Named{name: String, schema: Schema}
  ProgressiveList{element: Schema}
  ProgressiveBits{}
  ProgressiveContainer{names: +List<String>, fields: Schema, active: +List<Bool>}
  CompatibleUnion{selectors: +List<U32>, options: Schema}

type Value is Data:
  BooleanValue{value: Bool}
  UnsignedValue{value: P.UInt}
  BytesValue{value: +List<U32>}
  BitsValue{value: +List<Bool>}
  Sequence{items: Value}
  Items{head: Value, tail: Value}
  EmptyItems{}
  Selected{selector: U32, value: Value}
  NullValue{}

# Layout fragments are transport-free, already recursively serialized data.
type Part is Data:
  Fixed{bytes: +List<U32>}
  Variable{bytes: +List<U32>}

type Header is Data:
  Inline{bytes: +List<U32>}
  Offset{position: Nat}
