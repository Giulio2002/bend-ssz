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

def c776() -> {Codec.encoding_for_legal_type(G.vec_uint16_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c777() -> {Codec.encoding_for_legal_type(G.vec_uint16_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c778() -> {Codec.encoding_for_legal_type(G.vec_uint16_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{21690, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[186, 84]} : Maybe<&2, +List<U32>>}:
  {==}

def c779() -> {Codec.encoding_for_legal_type(G.vec_uint16_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c780() -> {Codec.encoding_for_legal_type(G.vec_uint16_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65467, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[187, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c781() -> {Codec.encoding_for_legal_type(G.vec_uint16_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c782() -> {Codec.encoding_for_legal_type(G.vec_uint16_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65534, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[254, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c783() -> {Codec.encoding_for_legal_type(G.vec_uint16_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{21504, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 84]} : Maybe<&2, +List<U32>>}:
  {==}

def c784() -> {Codec.encoding_for_legal_type(G.vec_uint16_16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65534, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}) == Some{[255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
