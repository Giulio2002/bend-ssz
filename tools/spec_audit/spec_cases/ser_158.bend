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

def c851() -> {Codec.encoding_for_legal_type(G.vec_uint256_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3321427257, 2128379649, 2922103036, 2492823365, 2583306894, 1953118671, 4251960369, 2668638585}}, T.EmptyItems{}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 245, 248, 197, 1, 127, 220, 126, 252, 192, 43, 174, 69, 119, 149, 148, 142, 34, 250, 153, 207, 57, 106, 116, 49, 196, 111, 253, 121, 49, 16, 159]} : Maybe<&2, +List<U32>>}:
  {==}

def c852() -> {Codec.encoding_for_legal_type(G.vec_uint256_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.Items{T.UnsignedValue{P.UInt{4294967041, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c853() -> {Codec.encoding_for_legal_type(G.vec_uint256_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.Items{T.UnsignedValue{P.UInt{4294967168, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c854() -> {Codec.encoding_for_legal_type(G.vec_uint256_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4278190079, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
