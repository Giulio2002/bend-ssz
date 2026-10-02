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

def c8() -> {Codec.encoding_for_legal_type(F.BLSSignature(), T.BytesValue{[245, 252, 113, 159, 246, 250, 194, 110, 215, 45, 26, 239, 47, 171, 73, 86, 50, 200, 137, 67, 129, 228, 255, 61, 22, 54, 242, 91, 213, 114, 49, 253, 12, 160, 60, 104, 223, 243, 182, 100, 195, 93, 11, 160, 127, 76, 23, 163, 190, 242, 35, 216, 54, 238, 173, 16, 248, 8, 112, 52, 122, 9, 85, 136, 215, 9, 79, 146, 42, 137, 50, 184, 177, 132, 64, 178, 246, 169, 194, 152, 144, 243, 243, 78, 201, 139, 245, 209, 236, 157, 182, 100, 156, 138, 206, 188]}) == Some{[245, 252, 113, 159, 246, 250, 194, 110, 215, 45, 26, 239, 47, 171, 73, 86, 50, 200, 137, 67, 129, 228, 255, 61, 22, 54, 242, 91, 213, 114, 49, 253, 12, 160, 60, 104, 223, 243, 182, 100, 195, 93, 11, 160, 127, 76, 23, 163, 190, 242, 35, 216, 54, 238, 173, 16, 248, 8, 112, 52, 122, 9, 85, 136, 215, 9, 79, 146, 42, 137, 50, 184, 177, 132, 64, 178, 246, 169, 194, 152, 144, 243, 243, 78, 201, 139, 245, 209, 236, 157, 182, 100, 156, 138, 206, 188]} : Maybe<&2, +List<U32>>}:
  {==}

def c9() -> {Codec.encoding_for_legal_type(F.BLSToExecutionChange(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c10() -> {Codec.encoding_for_legal_type(F.BLSToExecutionChange(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1365875552, 295002529, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[246, 183, 86, 4, 167, 58, 65, 206, 105, 156, 198, 50, 2, 60, 140, 191, 189, 17, 209, 223, 77, 206, 55, 68, 124, 239, 139, 199, 131, 75, 134, 226, 245, 114, 218, 147, 254, 241, 75, 131, 29, 170, 152, 78, 32, 197, 225, 51]}, T.Items{T.BytesValue{[18, 92, 112, 16, 81, 94, 108, 196, 180, 57, 42, 149, 164, 89, 117, 233, 66, 128, 157, 128]}, T.EmptyItems{}}}}}) == Some{[96, 155, 105, 81, 161, 97, 149, 17, 246, 183, 86, 4, 167, 58, 65, 206, 105, 156, 198, 50, 2, 60, 140, 191, 189, 17, 209, 223, 77, 206, 55, 68, 124, 239, 139, 199, 131, 75, 134, 226, 245, 114, 218, 147, 254, 241, 75, 131, 29, 170, 152, 78, 32, 197, 225, 51, 18, 92, 112, 16, 81, 94, 108, 196, 180, 57, 42, 149, 164, 89, 117, 233, 66, 128, 157, 128]} : Maybe<&2, +List<U32>>}:
  {==}
