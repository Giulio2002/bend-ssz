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

def c264() -> {Codec.encoding_for_legal_type(F.SyncAggregatorSelectionData(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294901759, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c265() -> {Codec.encoding_for_legal_type(F.SyncAggregatorSelectionData(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{16711680, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 255, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c266() -> {Codec.encoding_for_legal_type(F.SyncAggregatorSelectionData(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c267() -> {Codec.encoding_for_legal_type(F.SyncCommitteeContribution(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1699094300, 3588941060, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[182, 155, 105, 238, 157, 254, 125, 15, 158, 144, 57, 54, 49, 73, 112, 40, 13, 15, 29, 211, 20, 152, 118, 12, 105, 106, 89, 47, 155, 126, 209, 104]}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BitsValue{[True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}]}, T.Items{T.BytesValue{[201, 13, 139, 141, 13, 7, 42, 117, 212, 27, 19, 54, 27, 56, 250, 157, 202, 35, 1, 237, 21, 155, 63, 123, 236, 245, 127, 250, 128, 209, 20, 215, 131, 159, 206, 0, 135, 52, 65, 54, 62, 54, 93, 160, 170, 199, 86, 75, 138, 141, 34, 83, 130, 195, 2, 40, 59, 65, 27, 98, 193, 104, 121, 43, 230, 23, 215, 108, 183, 83, 205, 240, 83, 84, 86, 245, 184, 171, 136, 72, 48, 214, 174, 128, 125, 65, 141, 229, 183, 12, 236, 234, 112, 144, 155, 32]}, T.EmptyItems{}}}}}}}) == Some{[28, 31, 70, 101, 4, 229, 234, 213, 182, 155, 105, 238, 157, 254, 125, 15, 158, 144, 57, 54, 49, 73, 112, 40, 13, 15, 29, 211, 20, 152, 118, 12, 105, 106, 89, 47, 155, 126, 209, 104, 1, 0, 0, 0, 0, 0, 0, 0, 253, 130, 114, 47, 154, 59, 155, 151, 100, 214, 53, 14, 139, 108, 72, 117, 201, 13, 139, 141, 13, 7, 42, 117, 212, 27, 19, 54, 27, 56, 250, 157, 202, 35, 1, 237, 21, 155, 63, 123, 236, 245, 127, 250, 128, 209, 20, 215, 131, 159, 206, 0, 135, 52, 65, 54, 62, 54, 93, 160, 170, 199, 86, 75, 138, 141, 34, 83, 130, 195, 2, 40, 59, 65, 27, 98, 193, 104, 121, 43, 230, 23, 215, 108, 183, 83, 205, 240, 83, 84, 86, 245, 184, 171, 136, 72, 48, 214, 174, 128, 125, 65, 141, 229, 183, 12, 236, 234, 112, 144, 155, 32]} : Maybe<&2, +List<U32>>}:
  {==}
