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

def c117() -> {Codec.encoding_for_legal_type(F.Eth1Block(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c118() -> {Codec.encoding_for_legal_type(F.Eth1Block(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.UnsignedValue{P.UInt{32768, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c119() -> {Codec.encoding_for_legal_type(F.Eth1Data(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128]}, T.EmptyItems{}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c120() -> {Codec.encoding_for_legal_type(F.Eth1Data(), T.Sequence{T.Items{T.BytesValue{[64, 167, 120, 2, 167, 13, 247, 250, 228, 241, 171, 104, 155, 54, 159, 120, 193, 108, 127, 67, 252, 63, 163, 143, 16, 166, 178, 166, 105, 76, 153, 226]}, T.Items{T.UnsignedValue{P.UInt{3175110666, 2114853804, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[53, 95, 248, 73, 167, 154, 57, 11, 79, 162, 47, 147, 114, 4, 246, 189, 183, 106, 192, 151, 116, 143, 209, 0, 240, 31, 227, 207, 125, 252, 8, 59]}, T.EmptyItems{}}}}}) == Some{[64, 167, 120, 2, 167, 13, 247, 250, 228, 241, 171, 104, 155, 54, 159, 120, 193, 108, 127, 67, 252, 63, 163, 143, 16, 166, 178, 166, 105, 76, 153, 226, 10, 88, 64, 189, 172, 27, 14, 126, 53, 95, 248, 73, 167, 154, 57, 11, 79, 162, 47, 147, 114, 4, 246, 189, 183, 106, 192, 151, 116, 143, 209, 0, 240, 31, 227, 207, 125, 252, 8, 59]} : Maybe<&2, +List<U32>>}:
  {==}
