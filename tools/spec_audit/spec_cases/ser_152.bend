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
import ../../../proofs/obj/generic_specs_generated.bend as G
import ../../../spec/fulu_schemas.bend as F

def c817() -> {Codec.encoding_for_legal_type(G.vec_uint16_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{15115, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[1, 0, 255, 255, 0, 1, 11, 59]} : Maybe<&2, +List<U32>>}:
  {==}

def c818() -> {Codec.encoding_for_legal_type(G.vec_uint16_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65534, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[255, 255, 255, 255, 254, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c819() -> {Codec.encoding_for_legal_type(G.vec_uint16_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{55561, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{257, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[1, 0, 9, 217, 0, 0, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c820() -> {Codec.encoding_for_legal_type(G.vec_uint16_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3176, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[255, 255, 1, 0, 104, 12, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c821() -> {Codec.encoding_for_legal_type(G.vec_uint16_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{265, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[1, 0, 9, 1, 0, 0, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c822() -> {Codec.encoding_for_legal_type(G.vec_uint16_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{32768, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c823() -> {Codec.encoding_for_legal_type(G.vec_uint16_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{55561, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[1, 0, 9, 217, 0, 0, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}
