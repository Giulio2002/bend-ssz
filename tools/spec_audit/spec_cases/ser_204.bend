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

def c1022() -> {Codec.encoding_for_legal_type(G.vec_uint8_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[128, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c1023() -> {Codec.encoding_for_legal_type(G.vec_uint8_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{125, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[125, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c1024() -> {Codec.encoding_for_legal_type(G.vec_uint8_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[128, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c1025() -> {Codec.encoding_for_legal_type(G.vec_uint8_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{242, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{76, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[242, 128, 76]} : Maybe<&2, +List<U32>>}:
  {==}

def c1026() -> {Codec.encoding_for_legal_type(G.vec_uint8_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c1027() -> {Codec.encoding_for_legal_type(G.vec_uint8_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{138, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{70, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{213, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[138, 70, 213]} : Maybe<&2, +List<U32>>}:
  {==}

def c1028() -> {Codec.encoding_for_legal_type(G.vec_uint8_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{109, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{76, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[128, 109, 76]} : Maybe<&2, +List<U32>>}:
  {==}

def c1029() -> {Codec.encoding_for_legal_type(G.vec_uint8_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c1030() -> {Codec.encoding_for_legal_type(G.vec_uint8_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{242, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{76, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[242, 0, 76]} : Maybe<&2, +List<U32>>}:
  {==}
