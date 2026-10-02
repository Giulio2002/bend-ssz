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

def c24() -> {Codec.encoding_for_legal_type(F.BlobIdentifier(), T.Sequence{T.Items{T.BytesValue{[237, 53, 115, 185, 25, 42, 53, 217, 216, 167, 158, 103, 58, 0, 103, 250, 13, 116, 59, 122, 182, 106, 25, 9, 92, 120, 84, 108, 140, 129, 5, 41]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[237, 53, 115, 185, 25, 42, 53, 217, 216, 167, 158, 103, 58, 0, 103, 250, 13, 116, 59, 122, 182, 106, 25, 9, 92, 120, 84, 108, 140, 129, 5, 41, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c25() -> {Codec.encoding_for_legal_type(F.BlobIdentifier(), T.Sequence{T.Items{T.BytesValue{[237, 53, 115, 185, 25, 42, 53, 217, 216, 167, 158, 103, 58, 37, 103, 250, 13, 116, 59, 122, 182, 106, 25, 9, 92, 120, 84, 108, 140, 1, 5, 41]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[237, 53, 115, 185, 25, 42, 53, 217, 216, 167, 158, 103, 58, 37, 103, 250, 13, 116, 59, 122, 182, 106, 25, 9, 92, 120, 84, 108, 140, 1, 5, 41, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c26() -> {Codec.encoding_for_legal_type(F.BlobIndex(), T.UnsignedValue{P.UInt{1, 2147483648, 0, 0, 0, 0, 0, 0}}) == Some{[1, 0, 0, 0, 0, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c27() -> {Codec.encoding_for_legal_type(F.BlobIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967040, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 0, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c28() -> {Codec.encoding_for_legal_type(F.BlobIndex(), T.UnsignedValue{P.UInt{1, 65280, 0, 0, 0, 0, 0, 0}}) == Some{[1, 0, 0, 0, 0, 255, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c29() -> {Codec.encoding_for_legal_type(F.Bytes1(), T.BytesValue{[121]}) == Some{[121]} : Maybe<&2, +List<U32>>}:
  {==}

def c30() -> {Codec.encoding_for_legal_type(F.Bytes1(), T.BytesValue{[120]}) == Some{[120]} : Maybe<&2, +List<U32>>}:
  {==}

def c31() -> {Codec.encoding_for_legal_type(F.Bytes1(), T.BytesValue{[1]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c32() -> {Codec.encoding_for_legal_type(F.Bytes20(), T.BytesValue{[128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == Some{[128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c33() -> {Codec.encoding_for_legal_type(F.Bytes20(), T.BytesValue{[88, 70, 238, 138, 61, 126, 219, 180, 93, 237, 190, 31, 254, 236, 255, 46, 189, 171, 99, 198]}) == Some{[88, 70, 238, 138, 61, 126, 219, 180, 93, 237, 190, 31, 254, 236, 255, 46, 189, 171, 99, 198]} : Maybe<&2, +List<U32>>}:
  {==}
