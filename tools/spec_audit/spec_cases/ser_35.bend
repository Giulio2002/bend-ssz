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

def c182() -> {Codec.encoding_for_legal_type(F.PendingAttestation(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[16, 200, 18, 189, 77, 126, 203, 181, 29, 207, 94, 57, 238, 98, 127, 238, 31, 202, 171, 151, 216, 83, 104, 32, 181, 15, 215, 88, 238, 12, 140, 90]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[15, 21, 205, 74, 52, 139, 187, 56, 199, 101, 234, 96, 226, 23, 104, 134, 160, 125, 187, 121, 184, 217, 161, 219, 73, 156, 166, 225, 207, 148, 47, 84]}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[238, 166, 134, 208, 39, 33, 16, 180, 234, 68, 48, 220, 39, 124, 205, 32, 61, 245, 245, 160, 230, 98, 159, 191, 7, 205, 17, 66, 58, 50, 89, 194]}, T.EmptyItems{}}}}, T.EmptyItems{}}}}}}}, T.Items{T.UnsignedValue{P.UInt{1, 256, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[148, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 16, 200, 18, 189, 77, 126, 203, 181, 29, 207, 94, 57, 238, 98, 127, 238, 31, 202, 171, 151, 216, 83, 104, 32, 181, 15, 215, 88, 238, 12, 140, 90, 0, 0, 0, 0, 0, 0, 0, 0, 15, 21, 205, 74, 52, 139, 187, 56, 199, 101, 234, 96, 226, 23, 104, 134, 160, 125, 187, 121, 184, 217, 161, 219, 73, 156, 166, 225, 207, 148, 47, 84, 0, 0, 0, 0, 0, 0, 0, 0, 238, 166, 134, 208, 39, 33, 16, 180, 234, 68, 48, 220, 39, 124, 205, 32, 61, 245, 245, 160, 230, 98, 159, 191, 7, 205, 17, 66, 58, 50, 89, 194, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 104, 99]} : Maybe<&2, +List<U32>>}:
  {==}

def c183() -> {Codec.encoding_for_legal_type(F.PendingAttestation(), T.Sequence{T.Items{T.BitsValue{[True{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{3228839174, 4194034195, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[144, 148, 245, 89, 117, 44, 221, 214, 197, 126, 231, 73, 50, 176, 205, 93, 253, 211, 192, 37, 174, 197, 101, 197, 190, 209, 118, 111, 39, 201, 229, 223]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{379525289, 3440493454, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[85, 19, 187, 183, 70, 19, 234, 184, 230, 238, 0, 75, 232, 120, 153, 32, 215, 238, 37, 205, 12, 58, 147, 25, 73, 199, 72, 109, 246, 117, 234, 7]}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[26, 21, 105, 152, 10, 212, 199, 166, 172, 7, 147, 174, 213, 108, 42, 225, 230, 146, 16, 212, 137, 125, 29, 118, 106, 236, 149, 41, 20, 205, 242, 171]}, T.EmptyItems{}}}}, T.EmptyItems{}}}}}}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[148, 0, 0, 0, 6, 45, 116, 192, 19, 226, 251, 249, 255, 255, 255, 255, 255, 255, 255, 255, 144, 148, 245, 89, 117, 44, 221, 214, 197, 126, 231, 73, 50, 176, 205, 93, 253, 211, 192, 37, 174, 197, 101, 197, 190, 209, 118, 111, 39, 201, 229, 223, 169, 24, 159, 22, 142, 195, 17, 205, 85, 19, 187, 183, 70, 19, 234, 184, 230, 238, 0, 75, 232, 120, 153, 32, 215, 238, 37, 205, 12, 58, 147, 25, 73, 199, 72, 109, 246, 117, 234, 7, 1, 0, 0, 0, 0, 0, 0, 0, 26, 21, 105, 152, 10, 212, 199, 166, 172, 7, 147, 174, 213, 108, 42, 225, 230, 146, 16, 212, 137, 125, 29, 118, 106, 236, 149, 41, 20, 205, 242, 171, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 105, 1]} : Maybe<&2, +List<U32>>}:
  {==}
