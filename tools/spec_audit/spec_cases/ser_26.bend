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

def c131() -> {Codec.encoding_for_legal_type(F.ExecutionRequests(), T.Sequence{T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.Items{T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}}, T.EmptyItems{}}}, T.EmptyItems{}}}}}) == Some{[12, 0, 0, 0, 12, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c132() -> {Codec.encoding_for_legal_type(F.ExecutionRequests(), T.Sequence{T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.Items{T.Sequence{T.Items{T.BytesValue{[212, 115, 221, 198, 194, 9, 24, 60, 197, 183, 83, 112, 150, 153, 24, 224, 195, 96, 224, 87]}, T.Items{T.BytesValue{[9, 114, 186, 80, 96, 39, 105, 227, 212, 234, 1, 57, 148, 134, 9, 86, 39, 155, 29, 55, 67, 87, 182, 123, 198, 170, 26, 65, 83, 83, 189, 55, 227, 233, 141, 199, 159, 216, 72, 142, 87, 8, 32, 23, 235, 178, 115, 41]}, T.Items{T.BytesValue{[9, 199, 92, 186, 157, 55, 72, 62, 14, 14, 187, 228, 245, 56, 36, 180, 102, 53, 128, 13, 166, 77, 93, 82, 222, 190, 119, 70, 86, 64, 239, 56, 55, 70, 8, 220, 19, 79, 119, 125, 235, 163, 105, 74, 106, 234, 117, 132]}, T.EmptyItems{}}}}}, T.EmptyItems{}}}, T.EmptyItems{}}}}}) == Some{[12, 0, 0, 0, 12, 0, 0, 0, 12, 0, 0, 0, 212, 115, 221, 198, 194, 9, 24, 60, 197, 183, 83, 112, 150, 153, 24, 224, 195, 96, 224, 87, 9, 114, 186, 80, 96, 39, 105, 227, 212, 234, 1, 57, 148, 134, 9, 86, 39, 155, 29, 55, 67, 87, 182, 123, 198, 170, 26, 65, 83, 83, 189, 55, 227, 233, 141, 199, 159, 216, 72, 142, 87, 8, 32, 23, 235, 178, 115, 41, 9, 199, 92, 186, 157, 55, 72, 62, 14, 14, 187, 228, 245, 56, 36, 180, 102, 53, 128, 13, 166, 77, 93, 82, 222, 190, 119, 70, 86, 64, 239, 56, 55, 70, 8, 220, 19, 79, 119, 125, 235, 163, 105, 74, 106, 234, 117, 132]} : Maybe<&2, +List<U32>>}:
  {==}
