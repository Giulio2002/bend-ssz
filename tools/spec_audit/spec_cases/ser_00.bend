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

def c0() -> {Codec.encoding_for_legal_type(F.AttestationData(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3601020529, 2456725443, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[240, 13, 234, 54, 47, 252, 172, 37, 12, 46, 114, 85, 183, 88, 228, 145, 53, 50, 195, 1, 228, 152, 120, 8, 201, 17, 104, 40, 147, 72, 21, 86]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[118, 46, 52, 137, 166, 77, 137, 26, 108, 171, 208, 191, 115, 162, 106, 218, 127, 197, 245, 23, 193, 65, 209, 226, 213, 52, 152, 51, 251, 83, 146, 143]}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[129, 188, 41, 226, 200, 188, 65, 205, 145, 185, 180, 142, 195, 10, 127, 238, 11, 187, 53, 152, 221, 168, 51, 142, 65, 50, 49, 95, 58, 84, 84, 38]}, T.EmptyItems{}}}}, T.EmptyItems{}}}}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 113, 54, 163, 214, 195, 167, 110, 146, 240, 13, 234, 54, 47, 252, 172, 37, 12, 46, 114, 85, 183, 88, 228, 145, 53, 50, 195, 1, 228, 152, 120, 8, 201, 17, 104, 40, 147, 72, 21, 86, 255, 255, 255, 255, 255, 255, 255, 255, 118, 46, 52, 137, 166, 77, 137, 26, 108, 171, 208, 191, 115, 162, 106, 218, 127, 197, 245, 23, 193, 65, 209, 226, 213, 52, 152, 51, 251, 83, 146, 143, 0, 0, 0, 0, 0, 0, 0, 0, 129, 188, 41, 226, 200, 188, 65, 205, 145, 185, 180, 142, 195, 10, 127, 238, 11, 187, 53, 152, 221, 168, 51, 142, 65, 50, 49, 95, 58, 84, 84, 38]} : Maybe<&2, +List<U32>>}:
  {==}

def c1() -> {Codec.encoding_for_legal_type(F.AttestationData(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[130, 220, 1, 227, 164, 96, 215, 76, 83, 59, 196, 247, 5, 101, 66, 156, 25, 94, 18, 115, 151, 11, 23, 89, 220, 162, 131, 128, 199, 158, 58, 113]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[155, 86, 139, 161, 253, 135, 147, 63, 239, 86, 183, 226, 189, 48, 103, 207, 26, 103, 143, 94, 121, 222, 133, 41, 160, 78, 93, 236, 58, 164, 135, 95]}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{3922433049, 3353285723, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[204, 44, 102, 56, 159, 223, 18, 178, 224, 40, 216, 252, 198, 211, 216, 36, 247, 114, 49, 106, 245, 204, 8, 159, 16, 157, 188, 239, 58, 243, 53, 29]}, T.EmptyItems{}}}}, T.EmptyItems{}}}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 130, 220, 1, 227, 164, 96, 215, 76, 83, 59, 196, 247, 5, 101, 66, 156, 25, 94, 18, 115, 151, 11, 23, 89, 220, 162, 131, 128, 199, 158, 58, 113, 255, 255, 255, 255, 255, 255, 255, 255, 155, 86, 139, 161, 253, 135, 147, 63, 239, 86, 183, 226, 189, 48, 103, 207, 26, 103, 143, 94, 121, 222, 133, 41, 160, 78, 93, 236, 58, 164, 135, 95, 25, 148, 203, 233, 91, 20, 223, 199, 204, 44, 102, 56, 159, 223, 18, 178, 224, 40, 216, 252, 198, 211, 216, 36, 247, 114, 49, 106, 245, 204, 8, 159, 16, 157, 188, 239, 58, 243, 53, 29]} : Maybe<&2, +List<U32>>}:
  {==}
