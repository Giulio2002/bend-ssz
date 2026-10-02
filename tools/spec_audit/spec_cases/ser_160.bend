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

def c859() -> {Codec.encoding_for_legal_type(G.vec_uint256_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 65280, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3072781624, 1249690562, 331825465, 2043933344, 1968542562, 1083447452, 1764312746, 223563117}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 56, 237, 38, 183, 194, 195, 124, 74, 57, 65, 199, 19, 160, 242, 211, 121, 98, 147, 85, 117, 156, 24, 148, 64, 170, 70, 41, 105, 109, 77, 83, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c860() -> {Codec.encoding_for_legal_type(G.vec_uint256_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{3801091347, 2504017259, 3974021980, 2830794989, 3746436440, 278528575, 3502491998, 839311969}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 256, 0}}, T.EmptyItems{}}}}}) == Some{[19, 13, 144, 226, 107, 69, 64, 149, 92, 195, 222, 236, 237, 128, 186, 168, 88, 21, 78, 223, 63, 2, 154, 16, 94, 201, 195, 208, 97, 226, 6, 50, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c861() -> {Codec.encoding_for_legal_type(G.vec_uint256_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{3801091347, 2504017153, 3974021980, 2830794989, 3746436440, 278528575, 3502491998, 839311969}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[19, 13, 144, 226, 1, 69, 64, 149, 92, 195, 222, 236, 237, 128, 186, 168, 88, 21, 78, 223, 63, 2, 154, 16, 94, 201, 195, 208, 97, 226, 6, 50, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c862() -> {Codec.encoding_for_legal_type(G.vec_uint256_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{3801091347, 2504017259, 3974021980, 2830794989, 3746436440, 278528575, 3502491998, 839311969}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[19, 13, 144, 226, 107, 69, 64, 149, 92, 195, 222, 236, 237, 128, 186, 168, 88, 21, 78, 223, 63, 2, 154, 16, 94, 201, 195, 208, 97, 226, 6, 50, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
