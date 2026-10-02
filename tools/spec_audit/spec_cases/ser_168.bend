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

def c880() -> {Codec.encoding_for_legal_type(G.vec_uint32_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c881() -> {Codec.encoding_for_legal_type(G.vec_uint32_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{20203268, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[4, 71, 52, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c882() -> {Codec.encoding_for_legal_type(G.vec_uint32_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{3962849024, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 71, 52, 236]} : Maybe<&2, +List<U32>>}:
  {==}

def c883() -> {Codec.encoding_for_legal_type(G.vec_uint32_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4281616132, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[4, 71, 52, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c884() -> {Codec.encoding_for_legal_type(G.vec_uint32_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{3962830852, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[4, 0, 52, 236]} : Maybe<&2, +List<U32>>}:
  {==}

def c885() -> {Codec.encoding_for_legal_type(G.vec_uint32_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2150909700, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[4, 71, 52, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c886() -> {Codec.encoding_for_legal_type(G.vec_uint32_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{3962849029, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[5, 71, 52, 236]} : Maybe<&2, +List<U32>>}:
  {==}

def c887() -> {Codec.encoding_for_legal_type(G.vec_uint32_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{3962896132, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[4, 255, 52, 236]} : Maybe<&2, +List<U32>>}:
  {==}

def c888() -> {Codec.encoding_for_legal_type(G.vec_uint32_16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3401413462, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3794473968, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2006603398, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2123163010, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1402864754, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2164260863, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}) == Some{[0, 0, 0, 0, 86, 115, 189, 202, 240, 19, 43, 226, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 1, 0, 0, 0, 134, 86, 154, 119, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 0, 130, 229, 140, 126, 114, 4, 158, 83, 255, 255, 255, 128]} : Maybe<&2, +List<U32>>}:
  {==}
