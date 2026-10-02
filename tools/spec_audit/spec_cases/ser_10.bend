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

def c49() -> {Codec.encoding_for_legal_type(F.Bytes96(), T.BytesValue{[244, 253, 130, 27, 245, 45, 110, 109, 198, 87, 29, 75, 181, 196, 136, 40, 203, 6, 5, 139, 230, 240, 110, 61, 9, 67, 243, 121, 33, 104, 135, 255, 131, 205, 187, 82, 102, 115, 76, 104, 122, 114, 126, 86, 243, 92, 28, 122, 40, 192, 45, 194, 41, 245, 133, 170, 173, 114, 132, 44, 158, 78, 129, 223, 13, 158, 13, 151, 223, 39, 195, 24, 234, 235, 153, 219, 251, 226, 160, 222, 97, 106, 27, 244, 111, 236, 148, 73, 227, 14, 158, 216, 244, 235, 172, 204]}) == Some{[244, 253, 130, 27, 245, 45, 110, 109, 198, 87, 29, 75, 181, 196, 136, 40, 203, 6, 5, 139, 230, 240, 110, 61, 9, 67, 243, 121, 33, 104, 135, 255, 131, 205, 187, 82, 102, 115, 76, 104, 122, 114, 126, 86, 243, 92, 28, 122, 40, 192, 45, 194, 41, 245, 133, 170, 173, 114, 132, 44, 158, 78, 129, 223, 13, 158, 13, 151, 223, 39, 195, 24, 234, 235, 153, 219, 251, 226, 160, 222, 97, 106, 27, 244, 111, 236, 148, 73, 227, 14, 158, 216, 244, 235, 172, 204]} : Maybe<&2, +List<U32>>}:
  {==}

def c50() -> {Codec.encoding_for_legal_type(F.CellIndex(), T.UnsignedValue{P.UInt{0, 1, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 0, 1, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c51() -> {Codec.encoding_for_legal_type(F.CellIndex(), T.UnsignedValue{P.UInt{2404131310, 3458859017, 0, 0, 0, 0, 0, 0}}) == Some{[238, 33, 76, 143, 9, 0, 42, 206]} : Maybe<&2, +List<U32>>}:
  {==}

def c52() -> {Codec.encoding_for_legal_type(F.CellIndex(), T.UnsignedValue{P.UInt{2404131310, 3458919689, 0, 0, 0, 0, 0, 0}}) == Some{[238, 33, 76, 143, 9, 237, 42, 206]} : Maybe<&2, +List<U32>>}:
  {==}

def c53() -> {Codec.encoding_for_legal_type(F.Checkpoint(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255]}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c54() -> {Codec.encoding_for_legal_type(F.Checkpoint(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
