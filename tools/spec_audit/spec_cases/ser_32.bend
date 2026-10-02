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

def c164() -> {Codec.encoding_for_legal_type(F.HistoricalSummary(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c165() -> {Codec.encoding_for_legal_type(F.HistoricalSummary(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c166() -> {Codec.encoding_for_legal_type(F.KZGCommitment(), T.BytesValue{[112, 62, 64, 9, 0, 222, 160, 91, 236, 130, 63, 95, 208, 38, 183, 20, 64, 153, 87, 73, 29, 64, 213, 35, 107, 26, 249, 162, 118, 15, 45, 167, 69, 68, 58, 91, 74, 174, 25, 171, 222, 97, 59, 239, 192, 131, 74, 15]}) == Some{[112, 62, 64, 9, 0, 222, 160, 91, 236, 130, 63, 95, 208, 38, 183, 20, 64, 153, 87, 73, 29, 64, 213, 35, 107, 26, 249, 162, 118, 15, 45, 167, 69, 68, 58, 91, 74, 174, 25, 171, 222, 97, 59, 239, 192, 131, 74, 15]} : Maybe<&2, +List<U32>>}:
  {==}

def c167() -> {Codec.encoding_for_legal_type(F.KZGCommitment(), T.BytesValue{[8, 207, 14, 83, 10, 255, 133, 42, 205, 106, 47, 68, 102, 120, 166, 127, 2, 169, 188, 104, 215, 227, 154, 131, 45, 1, 146, 76, 8, 126, 21, 169, 204, 154, 44, 165, 123, 236, 171, 247, 197, 195, 115, 110, 38, 36, 65, 108]}) == Some{[8, 207, 14, 83, 10, 255, 133, 42, 205, 106, 47, 68, 102, 120, 166, 127, 2, 169, 188, 104, 215, 227, 154, 131, 45, 1, 146, 76, 8, 126, 21, 169, 204, 154, 44, 165, 123, 236, 171, 247, 197, 195, 115, 110, 38, 36, 65, 108]} : Maybe<&2, +List<U32>>}:
  {==}

def c168() -> {Codec.encoding_for_legal_type(F.KZGCommitment(), T.BytesValue{[234, 197, 98, 137, 122, 169, 0, 105, 127, 191, 11, 194, 60, 155, 197, 182, 82, 51, 17, 236, 48, 119, 37, 245, 43, 200, 26, 12, 137, 198, 128, 191, 230, 35, 180, 213, 7, 71, 215, 114, 44, 127, 146, 71, 18, 139, 101, 178]}) == Some{[234, 197, 98, 137, 122, 169, 0, 105, 127, 191, 11, 194, 60, 155, 197, 182, 82, 51, 17, 236, 48, 119, 37, 245, 43, 200, 26, 12, 137, 198, 128, 191, 230, 35, 180, 213, 7, 71, 215, 114, 44, 127, 146, 71, 18, 139, 101, 178]} : Maybe<&2, +List<U32>>}:
  {==}
