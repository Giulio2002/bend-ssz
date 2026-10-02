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

def c663() -> {Codec.encoding_for_legal_type(F.uint256(), T.UnsignedValue{P.UInt{2616195432, 585032678, 4257644129, 2141013592, 3992951713, 2515910857, 4162396475, 1563948396}}) == Some{[104, 249, 239, 155, 230, 227, 222, 34, 97, 126, 198, 253, 88, 70, 157, 127, 161, 155, 255, 237, 201, 192, 245, 149, 59, 33, 25, 248, 108, 245, 55, 93]} : Maybe<&2, +List<U32>>}:
  {==}

def c664() -> {Codec.encoding_for_legal_type(F.uint256(), T.UnsignedValue{P.UInt{4286644223, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}) == Some{[255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c665() -> {Codec.encoding_for_legal_type(F.uint32(), T.UnsignedValue{P.UInt{2147483648, 0, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c666() -> {Codec.encoding_for_legal_type(F.uint32(), T.UnsignedValue{P.UInt{4278190079, 0, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 254]} : Maybe<&2, +List<U32>>}:
  {==}

def c667() -> {Codec.encoding_for_legal_type(F.uint32(), T.UnsignedValue{P.UInt{65537, 0, 0, 0, 0, 0, 0, 0}}) == Some{[1, 0, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c668() -> {Codec.encoding_for_legal_type(F.uint64(), T.UnsignedValue{P.UInt{0, 16711680, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 0, 0, 0, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c669() -> {Codec.encoding_for_legal_type(F.uint64(), T.UnsignedValue{P.UInt{0, 255, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 0, 255, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c670() -> {Codec.encoding_for_legal_type(F.uint64(), T.UnsignedValue{P.UInt{4294967295, 4286644223, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 128, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c671() -> {Codec.encoding_for_legal_type(F.uint8(), T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}) == Some{[128]} : Maybe<&2, +List<U32>>}:
  {==}

def c672() -> {Codec.encoding_for_legal_type(F.uint8(), T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c673() -> {Codec.encoding_for_legal_type(F.uint8(), T.UnsignedValue{P.UInt{254, 0, 0, 0, 0, 0, 0, 0}}) == Some{[254]} : Maybe<&2, +List<U32>>}:
  {==}

def c674() -> {Codec.encoding_for_legal_type(G.vec_bool_1(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}
