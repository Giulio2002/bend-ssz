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

def c175() -> {Codec.encoding_for_legal_type(F.ParticipationFlags(), T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c176() -> {Codec.encoding_for_legal_type(F.ParticipationFlags(), T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}) == Some{[128]} : Maybe<&2, +List<U32>>}:
  {==}

def c177() -> {Codec.encoding_for_legal_type(F.ParticipationFlags(), T.UnsignedValue{P.UInt{254, 0, 0, 0, 0, 0, 0, 0}}) == Some{[254]} : Maybe<&2, +List<U32>>}:
  {==}

def c178() -> {Codec.encoding_for_legal_type(F.PayloadId(), T.BytesValue{[112, 110, 64, 171, 255, 122, 0, 58]}) == Some{[112, 110, 64, 171, 255, 122, 0, 58]} : Maybe<&2, +List<U32>>}:
  {==}

def c179() -> {Codec.encoding_for_legal_type(F.PayloadId(), T.BytesValue{[38, 66, 118, 58, 195, 128, 90, 44]}) == Some{[38, 66, 118, 58, 195, 128, 90, 44]} : Maybe<&2, +List<U32>>}:
  {==}

def c180() -> {Codec.encoding_for_legal_type(F.PayloadId(), T.BytesValue{[38, 66, 0, 58, 195, 125, 90, 44]}) == Some{[38, 66, 0, 58, 195, 125, 90, 44]} : Maybe<&2, +List<U32>>}:
  {==}

def c181() -> {Codec.encoding_for_legal_type(F.PendingAttestation(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[16, 200, 18, 189, 77, 126, 203, 181, 29, 207, 94, 57, 238, 98, 127, 238, 31, 202, 171, 255, 216, 83, 104, 32, 181, 15, 215, 88, 238, 12, 140, 90]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[15, 21, 205, 74, 52, 139, 187, 56, 199, 101, 234, 96, 226, 23, 104, 134, 160, 125, 187, 121, 184, 217, 161, 219, 73, 156, 166, 225, 207, 148, 47, 84]}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[238, 166, 134, 208, 39, 33, 16, 180, 234, 68, 48, 220, 39, 124, 205, 32, 61, 245, 245, 160, 230, 98, 159, 191, 7, 205, 17, 66, 58, 50, 89, 194]}, T.EmptyItems{}}}}, T.EmptyItems{}}}}}}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[148, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 16, 200, 18, 189, 77, 126, 203, 181, 29, 207, 94, 57, 238, 98, 127, 238, 31, 202, 171, 255, 216, 83, 104, 32, 181, 15, 215, 88, 238, 12, 140, 90, 0, 0, 0, 0, 0, 0, 0, 0, 15, 21, 205, 74, 52, 139, 187, 56, 199, 101, 234, 96, 226, 23, 104, 134, 160, 125, 187, 121, 184, 217, 161, 219, 73, 156, 166, 225, 207, 148, 47, 84, 0, 0, 0, 0, 0, 0, 0, 0, 238, 166, 134, 208, 39, 33, 16, 180, 234, 68, 48, 220, 39, 124, 205, 32, 61, 245, 245, 160, 230, 98, 159, 191, 7, 205, 17, 66, 58, 50, 89, 194, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 104, 99]} : Maybe<&2, +List<U32>>}:
  {==}
