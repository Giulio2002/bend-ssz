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

def c791() -> {Codec.encoding_for_legal_type(G.vec_uint16_16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{21306, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{34228, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{11854, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3831, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{11921, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65504, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}) == Some{[1, 0, 58, 83, 0, 0, 180, 133, 78, 46, 255, 255, 255, 255, 255, 255, 247, 14, 1, 0, 145, 46, 1, 0, 1, 0, 224, 255, 1, 0, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c792() -> {Codec.encoding_for_legal_type(G.vec_uint16_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c793() -> {Codec.encoding_for_legal_type(G.vec_uint16_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{22742, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{29953, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[214, 88, 1, 117]} : Maybe<&2, +List<U32>>}:
  {==}

def c794() -> {Codec.encoding_for_legal_type(G.vec_uint16_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{22656, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{30181, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[128, 88, 229, 117]} : Maybe<&2, +List<U32>>}:
  {==}

def c795() -> {Codec.encoding_for_legal_type(G.vec_uint16_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{22742, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{29952, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[214, 88, 0, 117]} : Maybe<&2, +List<U32>>}:
  {==}

def c796() -> {Codec.encoding_for_legal_type(G.vec_uint16_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65408, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 128, 255]} : Maybe<&2, +List<U32>>}:
  {==}
