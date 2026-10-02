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

def c121() -> {Codec.encoding_for_legal_type(F.Eth1Data(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c122() -> {Codec.encoding_for_legal_type(F.Ether(), T.UnsignedValue{P.UInt{14950991, 1924883428, 0, 0, 0, 0, 0, 0}}) == Some{[79, 34, 228, 0, 228, 99, 187, 114]} : Maybe<&2, +List<U32>>}:
  {==}

def c123() -> {Codec.encoding_for_legal_type(F.Ether(), T.UnsignedValue{P.UInt{4058260047, 1924883328, 0, 0, 0, 0, 0, 0}}) == Some{[79, 34, 228, 241, 128, 99, 187, 114]} : Maybe<&2, +List<U32>>}:
  {==}

def c124() -> {Codec.encoding_for_legal_type(F.Ether(), T.UnsignedValue{P.UInt{4058316623, 1924883428, 0, 0, 0, 0, 0, 0}}) == Some{[79, 255, 228, 241, 228, 99, 187, 114]} : Maybe<&2, +List<U32>>}:
  {==}

def c125() -> {Codec.encoding_for_legal_type(F.ExecutionAddress(), T.BytesValue{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c126() -> {Codec.encoding_for_legal_type(F.ExecutionAddress(), T.BytesValue{[222, 1, 208, 251, 68, 125, 138, 152, 132, 136, 113, 98, 128, 162, 87, 94, 99, 223, 87, 48]}) == Some{[222, 1, 208, 251, 68, 125, 138, 152, 132, 136, 113, 98, 128, 162, 87, 94, 99, 223, 87, 48]} : Maybe<&2, +List<U32>>}:
  {==}

def c127() -> {Codec.encoding_for_legal_type(F.ExecutionAddress(), T.BytesValue{[199, 203, 46, 48, 130, 231, 231, 2, 18, 200, 70, 209, 172, 254, 128, 57, 0, 99, 232, 117]}) == Some{[199, 203, 46, 48, 130, 231, 231, 2, 18, 200, 70, 209, 172, 254, 128, 57, 0, 99, 232, 117]} : Maybe<&2, +List<U32>>}:
  {==}

def c128() -> {Codec.encoding_for_legal_type(F.ExecutionBranch(), T.Sequence{T.Items{T.BytesValue{[210, 73, 156, 33, 103, 203, 128, 241, 128, 214, 161, 180, 112, 119, 107, 155, 68, 134, 112, 184, 24, 123, 184, 135, 222, 202, 150, 167, 194, 34, 91, 75]}, T.Items{T.BytesValue{[143, 222, 223, 75, 1, 254, 236, 238, 38, 14, 59, 38, 95, 19, 135, 251, 241, 40, 193, 116, 62, 147, 69, 70, 166, 77, 126, 215, 254, 192, 245, 9]}, T.Items{T.BytesValue{[30, 24, 17, 252, 85, 76, 227, 0, 64, 124, 69, 127, 70, 33, 225, 108, 70, 77, 40, 239, 58, 119, 114, 173, 245, 220, 181, 204, 205, 133, 42, 32]}, T.Items{T.BytesValue{[122, 107, 180, 158, 223, 215, 171, 246, 0, 201, 31, 186, 5, 246, 105, 130, 164, 73, 29, 40, 10, 167, 108, 191, 153, 71, 68, 122, 213, 197, 161, 179]}, T.EmptyItems{}}}}}}) == Some{[210, 73, 156, 33, 103, 203, 128, 241, 128, 214, 161, 180, 112, 119, 107, 155, 68, 134, 112, 184, 24, 123, 184, 135, 222, 202, 150, 167, 194, 34, 91, 75, 143, 222, 223, 75, 1, 254, 236, 238, 38, 14, 59, 38, 95, 19, 135, 251, 241, 40, 193, 116, 62, 147, 69, 70, 166, 77, 126, 215, 254, 192, 245, 9, 30, 24, 17, 252, 85, 76, 227, 0, 64, 124, 69, 127, 70, 33, 225, 108, 70, 77, 40, 239, 58, 119, 114, 173, 245, 220, 181, 204, 205, 133, 42, 32, 122, 107, 180, 158, 223, 215, 171, 246, 0, 201, 31, 186, 5, 246, 105, 130, 164, 73, 29, 40, 10, 167, 108, 191, 153, 71, 68, 122, 213, 197, 161, 179]} : Maybe<&2, +List<U32>>}:
  {==}
