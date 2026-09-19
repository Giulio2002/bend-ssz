"""Emit structural leaf proofs; reads neither fixtures nor expected outputs."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
constructors={'Boolean':0,'Unsigned':1,'ByteVector':1,'ByteList':1,'BitVector':1,'BitList':1,'Vector':2,'ListOf':2,'Container':2,'Union':1,'Null':0,'Chain':2,'End':0,'Repeat':1,'Named':2,'ProgressiveList':1,'ProgressiveBits':0,'ProgressiveContainer':3,'CompatibleUnion':2}
imports='''import Base
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
'''
branches={
 'boolean':('Bool','T.BooleanValue{value}', {'Boolean':'''Equal.cong(+List<U32>, Maybe<&2, +List<T.Part>>, xs => Some{[T.Fixed{xs}]}, IP.boolean_serialize(value), SP.boolean_encoding(value), Primitives.boolean_serialize_correct(value))'''}),
 'unsigned':('Types.UInt','T.UnsignedValue{value}', {'Unsigned':'''%Primitives.width_correct(x0) : {I.wrap(IP.uint_serialize(x0, value), Some{IP.width(x0)}) == S.one(SP.uint_encoding(x0, value), Some{_}) : Maybe<&2, +List<T.Part>>}
      wrapped_refinement(IP.uint_serialize(x0, value), SP.uint_encoding(x0, value), Some{IP.width(x0)}, Integers.uint_serialize_correct(x0, value))'''}),
 'bytes':('+List<U32>','T.BytesValue{value}', {
 'ByteVector':'wrapped_refinement(IB.vector_serialize(x0, value), SB.vector_encoding(x0, value), Some{x0}, Bytes.vector_serialize_correct(x0, value))',
 'ByteList':'wrapped_refinement(IBL.serialize(x0, value), SBL.encoding(x0, value), None{}, ByteList.serialize_correct(x0, value))'}),
 'bits':('+List<Bool>','T.BitsValue{value}', {
 'BitVector':'wrapped_refinement(IF.bitvector_serialize(x0, value), SF.vector_encoding(x0, value), Some{Nat.div(Nat.add(x0, 7n), 8n)}, Bits.bitvector_serialize_correct(x0, value))',
 'BitList':'wrapped_refinement(IF.bitlist_serialize(x0, value), SF.list_encoding(x0, value), None{}, Bits.bitlist_serialize_correct(x0, value))',
 'ProgressiveBits':'''%ListLaws.length_correct(Bool, value) : {I.wrap(IF.bitlist_serialize(Lists.length(Bool, value), value), None{}) == S.one(SF.list_encoding(_, value), None{}) : Maybe<&2, +List<T.Part>>}
      wrapped_refinement(IF.bitlist_serialize(Lists.length(Bool, value), value), SF.list_encoding(Lists.length(Bool, value), value), None{}, Bits.bitlist_serialize_correct(Lists.length(Bool, value), value))'''}),
}
out=imports
for name,(typ,value,cases) in branches.items():
 out+=f'''
law {name}_parts_correct:
  for +value: {typ}
  for +schema: T.Schema
  for +acc: +List<T.Part>
  {{I.encode_go({value}, schema, acc) == S.parts({value}, schema) : Maybe<&2, +List<T.Part>>}}
def {name}_parts_correct(value, schema, acc):
  match schema:
'''
 for ctor,n in constructors.items():
  body=cases.get(ctor,'{==}')
  out+='    case T.'+ctor+'{'+', '.join('x'+str(i) for i in range(n))+'}:\n      '+body+'\n'
(root/'proofs/codec_leaves.bend').write_text(out)
