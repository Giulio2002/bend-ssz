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

def c302() -> {Codec.encoding_for_legal_type(F.WithdrawalIndex(), T.UnsignedValue{P.UInt{902735970, 2619670277, 0, 0, 0, 0, 0, 0}}) == Some{[98, 168, 206, 53, 5, 255, 36, 156]} : Maybe<&2, +List<U32>>}:
  {==}

def c303() -> {Codec.encoding_for_legal_type(F.WithdrawalIndex(), T.UnsignedValue{P.UInt{902735970, 2617263109, 0, 0, 0, 0, 0, 0}}) == Some{[98, 168, 206, 53, 5, 68, 0, 156]} : Maybe<&2, +List<U32>>}:
  {==}

def c304() -> {Codec.encoding_for_legal_type(F.WithdrawalIndex(), T.UnsignedValue{P.UInt{0, 128, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 0, 128, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c305() -> {Codec.encoding_for_legal_type(F.WithdrawalRequest(), T.Sequence{T.Items{T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255]}, T.Items{T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c306() -> {Codec.encoding_for_legal_type(F.WithdrawalRequest(), T.Sequence{T.Items{T.BytesValue{[6, 225, 201, 172, 173, 197, 216, 203, 187, 121, 94, 105, 212, 12, 95, 103, 90, 136, 3, 241]}, T.Items{T.BytesValue{[47, 54, 165, 231, 129, 83, 3, 137, 250, 226, 221, 16, 36, 12, 48, 182, 47, 66, 45, 216, 42, 88, 21, 5, 57, 3, 59, 120, 193, 41, 29, 43, 232, 210, 8, 204, 222, 38, 82, 74, 119, 86, 95, 142, 255, 176, 76, 242]}, T.Items{T.UnsignedValue{P.UInt{1, 4278190080, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[6, 225, 201, 172, 173, 197, 216, 203, 187, 121, 94, 105, 212, 12, 95, 103, 90, 136, 3, 241, 47, 54, 165, 231, 129, 83, 3, 137, 250, 226, 221, 16, 36, 12, 48, 182, 47, 66, 45, 216, 42, 88, 21, 5, 57, 3, 59, 120, 193, 41, 29, 43, 232, 210, 8, 204, 222, 38, 82, 74, 119, 86, 95, 142, 255, 176, 76, 242, 1, 0, 0, 0, 0, 0, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c307() -> {Codec.encoding_for_legal_type(F.WithdrawalRequest(), T.Sequence{T.Items{T.BytesValue{[6, 225, 201, 172, 173, 197, 216, 203, 187, 121, 94, 105, 212, 12, 95, 103, 90, 136, 3, 241]}, T.Items{T.BytesValue{[47, 54, 165, 231, 129, 83, 3, 137, 250, 226, 220, 16, 36, 12, 48, 182, 47, 66, 45, 216, 42, 88, 21, 5, 57, 3, 59, 120, 193, 41, 29, 43, 232, 210, 8, 204, 222, 38, 82, 74, 119, 86, 95, 142, 255, 176, 76, 242]}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[6, 225, 201, 172, 173, 197, 216, 203, 187, 121, 94, 105, 212, 12, 95, 103, 90, 136, 3, 241, 47, 54, 165, 231, 129, 83, 3, 137, 250, 226, 220, 16, 36, 12, 48, 182, 47, 66, 45, 216, 42, 88, 21, 5, 57, 3, 59, 120, 193, 41, 29, 43, 232, 210, 8, 204, 222, 38, 82, 74, 119, 86, 95, 142, 255, 176, 76, 242, 1, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
