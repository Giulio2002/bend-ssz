import Base
import ../../../types/schema.bend as T
import ../../../types/primitive.bend as P
import ../../../spec/codec.bend as Codec
import ../../../spec/primitives.bend as Prim
import ../../../spec/bit_decode.bend as BitDec
import ../../../spec/bytes.bend as Bytes
import ../../../spec/byte_list.bend as ByteList
import ../../../spec/bit_root.bend as BitRoot
import ../../../spec/byte_root.bend as ByteRoot
import ../../../spec/layout_decoding.bend as Lay
import ../../../spec/limits.bend as Limits
import ../../../spec/progressive.bend as Prog
import ../../../spec/mixing.bend as Mix
import ../../../spec/packing.bend as Pack
import ../../../proofs/obj/generic_specs.bend as G
import ../../../spec/fulu_schemas.bend as F

def c241() -> {Codec.encoding_for_legal_type(F.SigningData(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c242() -> {Codec.encoding_for_legal_type(G.SingleFieldTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{254, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[254]} : Maybe<&2, +List<U32>>}:
  {==}

def c243() -> {Codec.encoding_for_legal_type(G.SingleFieldTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[128]} : Maybe<&2, +List<U32>>}:
  {==}

def c244() -> {Codec.encoding_for_legal_type(G.SingleFieldTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c245() -> {Codec.encoding_for_legal_type(G.SingleFieldTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c246() -> {Codec.encoding_for_legal_type(G.SingleFieldTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c247() -> {Codec.encoding_for_legal_type(F.Slot(), T.UnsignedValue{P.UInt{548587263, 1141119477, 0, 0, 0, 0, 0, 0}}) == Some{[255, 198, 178, 32, 245, 25, 4, 68]} : Maybe<&2, +List<U32>>}:
  {==}

def c248() -> {Codec.encoding_for_legal_type(F.Slot(), T.UnsignedValue{P.UInt{4294902271, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 1, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c249() -> {Codec.encoding_for_legal_type(F.Slot(), T.UnsignedValue{P.UInt{28493331, 1141119477, 0, 0, 0, 0, 0, 0}}) == Some{[19, 198, 178, 1, 245, 25, 4, 68]} : Maybe<&2, +List<U32>>}:
  {==}

def c250() -> {Codec.encoding_for_legal_type(G.SmallTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{33023, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{46956, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 128, 108, 183]} : Maybe<&2, +List<U32>>}:
  {==}

def c251() -> {Codec.encoding_for_legal_type(G.SmallTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 255, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
