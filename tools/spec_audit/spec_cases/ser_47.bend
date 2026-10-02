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

def c233() -> {Codec.encoding_for_legal_type(F.RowIndex(), T.UnsignedValue{P.UInt{2158935759, 2495908521, 0, 0, 0, 0, 0, 0}}) == Some{[207, 190, 174, 128, 169, 138, 196, 148]} : Maybe<&2, +List<U32>>}:
  {==}

def c234() -> {Codec.encoding_for_legal_type(F.RowIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967041, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 1, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c235() -> {Codec.encoding_for_legal_type(F.RowIndex(), T.UnsignedValue{P.UInt{2662252160, 2495908521, 0, 0, 0, 0, 0, 0}}) == Some{[128, 190, 174, 158, 169, 138, 196, 148]} : Maybe<&2, +List<U32>>}:
  {==}

def c236() -> {Codec.encoding_for_legal_type(F.SignedVoluntaryExit(), T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{2293281279, 1854867498, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{384744163, 2235701972, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.BytesValue{[11, 15, 192, 191, 217, 138, 159, 126, 93, 96, 192, 107, 102, 84, 179, 161, 198, 231, 9, 17, 87, 34, 113, 232, 66, 118, 226, 58, 213, 62, 155, 154, 69, 198, 10, 97, 8, 8, 114, 75, 159, 128, 199, 142, 198, 188, 239, 91, 201, 9, 230, 203, 198, 223, 54, 70, 25, 36, 131, 58, 1, 107, 65, 135, 196, 81, 129, 227, 102, 172, 167, 159, 197, 124, 186, 65, 134, 56, 55, 166, 44, 180, 43, 236, 184, 97, 217, 80, 163, 22, 244, 239, 170, 196, 213, 98]}, T.EmptyItems{}}}}) == Some{[255, 177, 176, 136, 42, 8, 143, 110, 227, 186, 238, 22, 212, 26, 66, 133, 11, 15, 192, 191, 217, 138, 159, 126, 93, 96, 192, 107, 102, 84, 179, 161, 198, 231, 9, 17, 87, 34, 113, 232, 66, 118, 226, 58, 213, 62, 155, 154, 69, 198, 10, 97, 8, 8, 114, 75, 159, 128, 199, 142, 198, 188, 239, 91, 201, 9, 230, 203, 198, 223, 54, 70, 25, 36, 131, 58, 1, 107, 65, 135, 196, 81, 129, 227, 102, 172, 167, 159, 197, 124, 186, 65, 134, 56, 55, 166, 44, 180, 43, 236, 184, 97, 217, 80, 163, 22, 244, 239, 170, 196, 213, 98]} : Maybe<&2, +List<U32>>}:
  {==}

def c237() -> {Codec.encoding_for_legal_type(F.SignedVoluntaryExit(), T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4096134193, 3521826297, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.BytesValue{[252, 145, 27, 42, 236, 174, 107, 30, 156, 240, 159, 48, 184, 27, 97, 151, 75, 251, 203, 206, 38, 126, 99, 163, 249, 16, 128, 42, 69, 147, 224, 43, 167, 22, 230, 77, 82, 232, 207, 74, 177, 179, 36, 218, 86, 138, 23, 189, 11, 203, 29, 169, 10, 243, 252, 227, 158, 148, 149, 244, 114, 50, 41, 50, 120, 60, 51, 181, 128, 101, 173, 184, 78, 142, 4, 118, 216, 138, 25, 16, 245, 57, 216, 213, 176, 7, 12, 114, 106, 10, 106, 55, 77, 20, 246, 94]}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 49, 12, 38, 244, 249, 205, 234, 209, 252, 145, 27, 42, 236, 174, 107, 30, 156, 240, 159, 48, 184, 27, 97, 151, 75, 251, 203, 206, 38, 126, 99, 163, 249, 16, 128, 42, 69, 147, 224, 43, 167, 22, 230, 77, 82, 232, 207, 74, 177, 179, 36, 218, 86, 138, 23, 189, 11, 203, 29, 169, 10, 243, 252, 227, 158, 148, 149, 244, 114, 50, 41, 50, 120, 60, 51, 181, 128, 101, 173, 184, 78, 142, 4, 118, 216, 138, 25, 16, 245, 57, 216, 213, 176, 7, 12, 114, 106, 10, 106, 55, 77, 20, 246, 94]} : Maybe<&2, +List<U32>>}:
  {==}
