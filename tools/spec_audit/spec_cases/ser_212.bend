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

def c1058() -> {Codec.encoding_for_legal_type(G.vec_uint8_8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{74, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{94, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{43, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{17, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{54, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{113, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{155, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}) == Some{[74, 94, 43, 17, 54, 128, 113, 155]} : Maybe<&2, +List<U32>>}:
  {==}

def c1059() -> {Codec.encoding_for_legal_type(G.vec_uint8_8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 0, 1, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c1060() -> {Codec.encoding_for_legal_type(G.vec_uint8_8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{94, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{43, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{17, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{54, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{226, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{113, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{155, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 94, 43, 17, 54, 226, 113, 155]} : Maybe<&2, +List<U32>>}:
  {==}

def c1061() -> {Codec.encoding_for_legal_type(G.vec_uint8_8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{211, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{52, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{131, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{45, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{236, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{163, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{40, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}) == Some{[211, 52, 131, 45, 236, 163, 1, 40]} : Maybe<&2, +List<U32>>}:
  {==}
