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

def c104() -> {Codec.encoding_for_legal_type(F.DepositMessage(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c105() -> {Codec.encoding_for_legal_type(F.DepositMessage(), T.Sequence{T.Items{T.BytesValue{[67, 150, 249, 63, 72, 218, 142, 15, 201, 193, 255, 5, 42, 132, 2, 235, 250, 113, 37, 7, 236, 138, 110, 99, 94, 16, 164, 90, 182, 140, 21, 182, 166, 154, 187, 193, 239, 131, 196, 111, 112, 72, 200, 111, 227, 141, 242, 114]}, T.Items{T.BytesValue{[224, 37, 138, 63, 62, 200, 218, 75, 75, 59, 136, 157, 188, 248, 19, 62, 85, 131, 228, 198, 67, 117, 243, 179, 227, 203, 199, 116, 8, 1, 96, 45]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[67, 150, 249, 63, 72, 218, 142, 15, 201, 193, 255, 5, 42, 132, 2, 235, 250, 113, 37, 7, 236, 138, 110, 99, 94, 16, 164, 90, 182, 140, 21, 182, 166, 154, 187, 193, 239, 131, 196, 111, 112, 72, 200, 111, 227, 141, 242, 114, 224, 37, 138, 63, 62, 200, 218, 75, 75, 59, 136, 157, 188, 248, 19, 62, 85, 131, 228, 198, 67, 117, 243, 179, 227, 203, 199, 116, 8, 1, 96, 45, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c106() -> {Codec.encoding_for_legal_type(F.DepositMessage(), T.Sequence{T.Items{T.BytesValue{[67, 150, 249, 63, 72, 218, 142, 15, 201, 193, 55, 5, 42, 132, 2, 235, 250, 113, 37, 7, 236, 138, 110, 99, 94, 16, 164, 90, 182, 140, 21, 182, 166, 154, 187, 193, 239, 131, 196, 111, 112, 72, 200, 111, 227, 141, 242, 114]}, T.Items{T.BytesValue{[224, 37, 138, 63, 62, 200, 218, 75, 75, 59, 136, 157, 188, 248, 19, 62, 85, 131, 228, 198, 255, 117, 243, 179, 227, 203, 199, 116, 8, 1, 96, 45]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[67, 150, 249, 63, 72, 218, 142, 15, 201, 193, 55, 5, 42, 132, 2, 235, 250, 113, 37, 7, 236, 138, 110, 99, 94, 16, 164, 90, 182, 140, 21, 182, 166, 154, 187, 193, 239, 131, 196, 111, 112, 72, 200, 111, 227, 141, 242, 114, 224, 37, 138, 63, 62, 200, 218, 75, 75, 59, 136, 157, 188, 248, 19, 62, 85, 131, 228, 198, 255, 117, 243, 179, 227, 203, 199, 116, 8, 1, 96, 45, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
