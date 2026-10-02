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

def c157() -> {Codec.encoding_for_legal_type(F.Gwei(), T.UnsignedValue{P.UInt{4294967295, 2164260863, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c158() -> {Codec.encoding_for_legal_type(F.Gwei(), T.UnsignedValue{P.UInt{1227917620, 29028575, 0, 0, 0, 0, 0, 0}}) == Some{[52, 137, 48, 73, 223, 240, 186, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c159() -> {Codec.encoding_for_legal_type(F.Gwei(), T.UnsignedValue{P.UInt{1227917620, 4055560415, 0, 0, 0, 0, 0, 0}}) == Some{[52, 137, 48, 73, 223, 240, 186, 241]} : Maybe<&2, +List<U32>>}:
  {==}

def c160() -> {Codec.encoding_for_legal_type(F.Hash32(), T.BytesValue{[228, 3, 154, 137, 131, 117, 16, 11, 162, 248, 43, 143, 168, 102, 159, 126, 143, 229, 218, 96, 134, 222, 152, 235, 8, 156, 186, 125, 21, 149, 156, 128]}) == Some{[228, 3, 154, 137, 131, 117, 16, 11, 162, 248, 43, 143, 168, 102, 159, 126, 143, 229, 218, 96, 134, 222, 152, 235, 8, 156, 186, 125, 21, 149, 156, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c161() -> {Codec.encoding_for_legal_type(F.Hash32(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0]}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c162() -> {Codec.encoding_for_legal_type(F.Hash32(), T.BytesValue{[255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]}) == Some{[255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c163() -> {Codec.encoding_for_legal_type(F.HistoricalSummary(), T.Sequence{T.Items{T.BytesValue{[132, 66, 209, 254, 50, 219, 3, 108, 85, 28, 202, 36, 122, 196, 80, 170, 56, 249, 215, 174, 119, 16, 33, 231, 25, 1, 209, 23, 137, 109, 26, 35]}, T.Items{T.BytesValue{[63, 27, 237, 2, 216, 225, 33, 19, 19, 27, 231, 152, 63, 38, 218, 198, 67, 174, 134, 84, 111, 233, 14, 180, 68, 162, 24, 41, 4, 205, 133, 152]}, T.EmptyItems{}}}}) == Some{[132, 66, 209, 254, 50, 219, 3, 108, 85, 28, 202, 36, 122, 196, 80, 170, 56, 249, 215, 174, 119, 16, 33, 231, 25, 1, 209, 23, 137, 109, 26, 35, 63, 27, 237, 2, 216, 225, 33, 19, 19, 27, 231, 152, 63, 38, 218, 198, 67, 174, 134, 84, 111, 233, 14, 180, 68, 162, 24, 41, 4, 205, 133, 152]} : Maybe<&2, +List<U32>>}:
  {==}
