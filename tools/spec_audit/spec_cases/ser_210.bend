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

def c1047() -> {Codec.encoding_for_legal_type(G.vec_uint8_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[255, 1, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c1048() -> {Codec.encoding_for_legal_type(G.vec_uint8_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{133, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{102, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{74, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{101, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[133, 0, 102, 74, 101]} : Maybe<&2, +List<U32>>}:
  {==}

def c1049() -> {Codec.encoding_for_legal_type(G.vec_uint8_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{225, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{171, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{193, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{41, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{89, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[225, 171, 193, 41, 89]} : Maybe<&2, +List<U32>>}:
  {==}

def c1050() -> {Codec.encoding_for_legal_type(G.vec_uint8_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[0, 0, 128, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c1051() -> {Codec.encoding_for_legal_type(G.vec_uint8_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{133, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{74, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{101, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[133, 0, 0, 74, 101]} : Maybe<&2, +List<U32>>}:
  {==}

def c1052() -> {Codec.encoding_for_legal_type(G.vec_uint8_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{225, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{170, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{193, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{41, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[225, 170, 193, 41, 255]} : Maybe<&2, +List<U32>>}:
  {==}
