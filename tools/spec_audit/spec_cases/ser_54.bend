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

def c268() -> {Codec.encoding_for_legal_type(F.SyncCommitteeContribution(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[249, 186, 19, 104, 137, 37, 85, 175, 83, 33, 80, 0, 237, 42, 76, 223, 192, 131, 121, 201, 77, 146, 213, 75, 99, 169, 1, 2, 187, 132, 177, 2]}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BitsValue{[False{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}]}, T.Items{T.BytesValue{[31, 43, 29, 121, 128, 112, 143, 115, 75, 12, 55, 21, 67, 250, 149, 0, 176, 115, 209, 179, 62, 11, 72, 224, 195, 131, 55, 156, 51, 164, 5, 78, 45, 220, 105, 52, 121, 135, 230, 29, 223, 0, 78, 231, 67, 9, 209, 1, 172, 55, 165, 121, 18, 204, 155, 49, 254, 97, 165, 161, 90, 253, 195, 117, 180, 143, 45, 54, 153, 26, 135, 178, 35, 4, 203, 224, 147, 131, 215, 251, 156, 163, 153, 168, 189, 37, 161, 225, 41, 141, 226, 227, 10, 52, 218, 137]}, T.EmptyItems{}}}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 249, 186, 19, 104, 137, 37, 85, 175, 83, 33, 80, 0, 237, 42, 76, 223, 192, 131, 121, 201, 77, 146, 213, 75, 99, 169, 1, 2, 187, 132, 177, 2, 255, 255, 255, 255, 255, 255, 255, 255, 92, 84, 233, 7, 67, 81, 178, 216, 188, 124, 223, 1, 251, 208, 131, 197, 31, 43, 29, 121, 128, 112, 143, 115, 75, 12, 55, 21, 67, 250, 149, 0, 176, 115, 209, 179, 62, 11, 72, 224, 195, 131, 55, 156, 51, 164, 5, 78, 45, 220, 105, 52, 121, 135, 230, 29, 223, 0, 78, 231, 67, 9, 209, 1, 172, 55, 165, 121, 18, 204, 155, 49, 254, 97, 165, 161, 90, 253, 195, 117, 180, 143, 45, 54, 153, 26, 135, 178, 35, 4, 203, 224, 147, 131, 215, 251, 156, 163, 153, 168, 189, 37, 161, 225, 41, 141, 226, 227, 10, 52, 218, 137]} : Maybe<&2, +List<U32>>}:
  {==}
