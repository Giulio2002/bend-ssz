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

def c959() -> {Codec.encoding_for_legal_type(G.vec_uint64_16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1770814014, 2517088752, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 16711680, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4182603628, 329496049, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{640304225, 1045255930, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3429132012, 1908982050, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2298537307, 2572232077, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2808281181, 3657368813, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{754036355, 1794007711, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 62, 122, 140, 105, 240, 185, 7, 150, 0, 0, 0, 0, 0, 0, 255, 0, 108, 119, 77, 249, 241, 181, 163, 19, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 97, 68, 42, 38, 250, 86, 77, 62, 236, 102, 100, 204, 34, 193, 200, 113, 91, 229, 0, 137, 141, 37, 81, 153, 255, 255, 255, 255, 255, 255, 255, 255, 93, 248, 98, 167, 237, 4, 255, 217, 131, 174, 241, 44, 159, 98, 238, 106, 1, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c960() -> {Codec.encoding_for_legal_type(G.vec_uint64_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c961() -> {Codec.encoding_for_legal_type(G.vec_uint64_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967168, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
