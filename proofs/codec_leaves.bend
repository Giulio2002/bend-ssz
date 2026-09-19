import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Types
import ../src/codec.bend as I
import ../spec/codec.bend as S
import ../src/primitives.bend as IP
import ../spec/primitives.bend as SP
import ../src/bytes.bend as IB
import ../spec/bytes.bend as SB
import ../src/byte_list.bend as IBL
import ../spec/byte_list.bend as SBL
import ../src/bitfields.bend as IF
import ../spec/bitfields.bend as SF
import ../src/lists.bend as Lists
import ./lists.bend as ListLaws
import ./codec_helpers.bend as Helpers
import ./primitives.bend as Primitives
import ./integer_encoding.bend as Integers
import ./bytes.bend as Bytes
import ./byte_list.bend as ByteList
import ./bitfields.bend as Bits

# Leaf dispatch reaches the real generic codec. These laws do not claim
# generic forest validity, recursive composition, or public schema legality.
law wrapped_refinement:
  for +actual: Maybe<&2, +List<U32>>
  for +meaning: Maybe<&2, +List<U32>>
  for +width: Maybe<&2, Nat>
  for refine: {actual == meaning : Maybe<&2, +List<U32>>}
  {I.wrap(actual, width) == S.one(meaning, width) : Maybe<&2, +List<T.Part>>}
def wrapped_refinement(actual, meaning, width, refine):
  %refine : {I.wrap(actual, width) == S.one(_, width) : Maybe<&2, +List<T.Part>>}
  Helpers.wrap_correct(actual, width)

law boolean_parts_correct:
  for +value: Bool
  for +schema: T.Schema
  for +acc: +List<T.Part>
  {I.encode_go(T.BooleanValue{value}, schema, acc) == S.parts(T.BooleanValue{value}, schema) : Maybe<&2, +List<T.Part>>}
def boolean_parts_correct(value, schema, acc):
  match schema:
    case T.Boolean{}:
      Equal.cong(+List<U32>, Maybe<&2, +List<T.Part>>, xs => Some{[T.Fixed{xs}]}, IP.boolean_serialize(value), SP.boolean_encoding(value), Primitives.boolean_serialize_correct(value))
    case T.Unsigned{x0}:
      {==}
    case T.ByteVector{x0}:
      {==}
    case T.ByteList{x0}:
      {==}
    case T.BitVector{x0}:
      {==}
    case T.BitList{x0}:
      {==}
    case T.Vector{x0, x1}:
      {==}
    case T.ListOf{x0, x1}:
      {==}
    case T.Container{x0, x1}:
      {==}
    case T.Union{x0}:
      {==}
    case T.Null{}:
      {==}
    case T.Chain{x0, x1}:
      {==}
    case T.End{}:
      {==}
    case T.Repeat{x0}:
      {==}
    case T.Named{x0, x1}:
      {==}
    case T.ProgressiveList{x0}:
      {==}
    case T.ProgressiveBits{}:
      {==}
    case T.ProgressiveContainer{x0, x1, x2}:
      {==}
    case T.CompatibleUnion{x0, x1}:
      {==}

law unsigned_parts_correct:
  for +value: Types.UInt
  for +schema: T.Schema
  for +acc: +List<T.Part>
  {I.encode_go(T.UnsignedValue{value}, schema, acc) == S.parts(T.UnsignedValue{value}, schema) : Maybe<&2, +List<T.Part>>}
def unsigned_parts_correct(value, schema, acc):
  match schema:
    case T.Boolean{}:
      {==}
    case T.Unsigned{x0}:
      %Primitives.width_correct(x0) : {I.wrap(IP.uint_serialize(x0, value), Some{IP.width(x0)}) == S.one(SP.uint_encoding(x0, value), Some{_}) : Maybe<&2, +List<T.Part>>}
      wrapped_refinement(IP.uint_serialize(x0, value), SP.uint_encoding(x0, value), Some{IP.width(x0)}, Integers.uint_serialize_correct(x0, value))
    case T.ByteVector{x0}:
      {==}
    case T.ByteList{x0}:
      {==}
    case T.BitVector{x0}:
      {==}
    case T.BitList{x0}:
      {==}
    case T.Vector{x0, x1}:
      {==}
    case T.ListOf{x0, x1}:
      {==}
    case T.Container{x0, x1}:
      {==}
    case T.Union{x0}:
      {==}
    case T.Null{}:
      {==}
    case T.Chain{x0, x1}:
      {==}
    case T.End{}:
      {==}
    case T.Repeat{x0}:
      {==}
    case T.Named{x0, x1}:
      {==}
    case T.ProgressiveList{x0}:
      {==}
    case T.ProgressiveBits{}:
      {==}
    case T.ProgressiveContainer{x0, x1, x2}:
      {==}
    case T.CompatibleUnion{x0, x1}:
      {==}

law bytes_parts_correct:
  for +value: +List<U32>
  for +schema: T.Schema
  for +acc: +List<T.Part>
  {I.encode_go(T.BytesValue{value}, schema, acc) == S.parts(T.BytesValue{value}, schema) : Maybe<&2, +List<T.Part>>}
def bytes_parts_correct(value, schema, acc):
  match schema:
    case T.Boolean{}:
      {==}
    case T.Unsigned{x0}:
      {==}
    case T.ByteVector{x0}:
      wrapped_refinement(IB.vector_serialize(x0, value), SB.vector_encoding(x0, value), Some{x0}, Bytes.vector_serialize_correct(x0, value))
    case T.ByteList{x0}:
      wrapped_refinement(IBL.serialize(x0, value), SBL.encoding(x0, value), None{}, ByteList.serialize_correct(x0, value))
    case T.BitVector{x0}:
      {==}
    case T.BitList{x0}:
      {==}
    case T.Vector{x0, x1}:
      {==}
    case T.ListOf{x0, x1}:
      {==}
    case T.Container{x0, x1}:
      {==}
    case T.Union{x0}:
      {==}
    case T.Null{}:
      {==}
    case T.Chain{x0, x1}:
      {==}
    case T.End{}:
      {==}
    case T.Repeat{x0}:
      {==}
    case T.Named{x0, x1}:
      {==}
    case T.ProgressiveList{x0}:
      {==}
    case T.ProgressiveBits{}:
      {==}
    case T.ProgressiveContainer{x0, x1, x2}:
      {==}
    case T.CompatibleUnion{x0, x1}:
      {==}

law bits_parts_correct:
  for +value: +List<Bool>
  for +schema: T.Schema
  for +acc: +List<T.Part>
  {I.encode_go(T.BitsValue{value}, schema, acc) == S.parts(T.BitsValue{value}, schema) : Maybe<&2, +List<T.Part>>}
def bits_parts_correct(value, schema, acc):
  match schema:
    case T.Boolean{}:
      {==}
    case T.Unsigned{x0}:
      {==}
    case T.ByteVector{x0}:
      {==}
    case T.ByteList{x0}:
      {==}
    case T.BitVector{x0}:
      wrapped_refinement(IF.bitvector_serialize(x0, value), SF.vector_encoding(x0, value), Some{Nat.div(Nat.add(x0, 7n), 8n)}, Bits.bitvector_serialize_correct(x0, value))
    case T.BitList{x0}:
      wrapped_refinement(IF.bitlist_serialize(x0, value), SF.list_encoding(x0, value), None{}, Bits.bitlist_serialize_correct(x0, value))
    case T.Vector{x0, x1}:
      {==}
    case T.ListOf{x0, x1}:
      {==}
    case T.Container{x0, x1}:
      {==}
    case T.Union{x0}:
      {==}
    case T.Null{}:
      {==}
    case T.Chain{x0, x1}:
      {==}
    case T.End{}:
      {==}
    case T.Repeat{x0}:
      {==}
    case T.Named{x0, x1}:
      {==}
    case T.ProgressiveList{x0}:
      {==}
    case T.ProgressiveBits{}:
      %ListLaws.length_correct(Bool, value) : {I.wrap(IF.bitlist_serialize(Lists.length(Bool, value), value), None{}) == S.one(SF.list_encoding(_, value), None{}) : Maybe<&2, +List<T.Part>>}
      wrapped_refinement(IF.bitlist_serialize(Lists.length(Bool, value), value), SF.list_encoding(Lists.length(Bool, value), value), None{}, Bits.bitlist_serialize_correct(Lists.length(Bool, value), value))
    case T.ProgressiveContainer{x0, x1, x2}:
      {==}
    case T.CompatibleUnion{x0, x1}:
      {==}
