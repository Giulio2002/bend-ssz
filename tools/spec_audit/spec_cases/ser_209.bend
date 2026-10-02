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

def c1040() -> {Codec.encoding_for_legal_type(G.vec_uint8_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c1041() -> {Codec.encoding_for_legal_type(G.vec_uint8_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{250, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{163, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[250, 128, 163, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c1042() -> {Codec.encoding_for_legal_type(G.vec_uint8_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{253, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{150, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[253, 255, 150, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c1043() -> {Codec.encoding_for_legal_type(G.vec_uint8_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{250, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{126, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{163, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[250, 126, 163, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c1044() -> {Codec.encoding_for_legal_type(G.vec_uint8_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[1, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c1045() -> {Codec.encoding_for_legal_type(G.vec_uint8_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{253, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{106, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{150, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[253, 106, 150, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c1046() -> {Codec.encoding_for_legal_type(G.vec_uint8_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{250, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{126, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{163, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[250, 126, 163, 255]} : Maybe<&2, +List<U32>>}:
  {==}
