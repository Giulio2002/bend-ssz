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

def c238() -> {Codec.encoding_for_legal_type(F.SignedVoluntaryExit(), T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967041, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.BytesValue{[232, 88, 28, 123, 162, 12, 69, 8, 80, 118, 196, 112, 156, 8, 88, 34, 82, 105, 87, 139, 253, 134, 80, 91, 218, 122, 140, 197, 216, 85, 2, 91, 36, 163, 208, 86, 191, 134, 115, 88, 114, 236, 151, 252, 105, 43, 70, 5, 92, 45, 161, 235, 76, 233, 113, 137, 210, 153, 9, 25, 228, 169, 25, 221, 169, 184, 27, 31, 227, 97, 174, 100, 66, 127, 55, 189, 210, 74, 21, 203, 25, 145, 84, 255, 202, 144, 5, 241, 64, 187, 179, 10, 207, 172, 135, 177]}, T.EmptyItems{}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 1, 255, 255, 255, 232, 88, 28, 123, 162, 12, 69, 8, 80, 118, 196, 112, 156, 8, 88, 34, 82, 105, 87, 139, 253, 134, 80, 91, 218, 122, 140, 197, 216, 85, 2, 91, 36, 163, 208, 86, 191, 134, 115, 88, 114, 236, 151, 252, 105, 43, 70, 5, 92, 45, 161, 235, 76, 233, 113, 137, 210, 153, 9, 25, 228, 169, 25, 221, 169, 184, 27, 31, 227, 97, 174, 100, 66, 127, 55, 189, 210, 74, 21, 203, 25, 145, 84, 255, 202, 144, 5, 241, 64, 187, 179, 10, 207, 172, 135, 177]} : Maybe<&2, +List<U32>>}:
  {==}

def c239() -> {Codec.encoding_for_legal_type(F.SigningData(), T.Sequence{T.Items{T.BytesValue{[119, 243, 243, 109, 30, 17, 30, 229, 148, 34, 198, 142, 48, 221, 210, 186, 167, 163, 61, 106, 152, 202, 33, 206, 17, 225, 115, 197, 44, 154, 194, 156]}, T.Items{T.BytesValue{[191, 219, 20, 123, 128, 206, 149, 46, 15, 206, 224, 130, 158, 94, 73, 123, 237, 66, 136, 35, 189, 32, 188, 217, 154, 99, 150, 28, 22, 37, 16, 114]}, T.EmptyItems{}}}}) == Some{[119, 243, 243, 109, 30, 17, 30, 229, 148, 34, 198, 142, 48, 221, 210, 186, 167, 163, 61, 106, 152, 202, 33, 206, 17, 225, 115, 197, 44, 154, 194, 156, 191, 219, 20, 123, 128, 206, 149, 46, 15, 206, 224, 130, 158, 94, 73, 123, 237, 66, 136, 35, 189, 32, 188, 217, 154, 99, 150, 28, 22, 37, 16, 114]} : Maybe<&2, +List<U32>>}:
  {==}

def c240() -> {Codec.encoding_for_legal_type(F.SigningData(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
