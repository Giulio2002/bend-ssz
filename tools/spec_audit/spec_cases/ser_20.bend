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

def c98() -> {Codec.encoding_for_legal_type(F.CustodyIndex(), T.UnsignedValue{P.UInt{32356584, 53180027, 0, 0, 0, 0, 0, 0}}) == Some{[232, 184, 237, 1, 123, 118, 43, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c99() -> {Codec.encoding_for_legal_type(F.CustodyIndex(), T.UnsignedValue{P.UInt{3018701032, 53215099, 0, 0, 0, 0, 0, 0}}) == Some{[232, 184, 237, 179, 123, 255, 43, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c100() -> {Codec.encoding_for_legal_type(F.CustodyIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967168, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 128, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c101() -> {Codec.encoding_for_legal_type(F.DataColumnsByRootIdentifier(), T.Sequence{T.Items{T.BytesValue{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.EmptyItems{}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c102() -> {Codec.encoding_for_legal_type(F.DataColumnsByRootIdentifier(), T.Sequence{T.Items{T.BytesValue{[177, 171, 31, 154, 233, 59, 132, 80, 33, 128, 247, 227, 41, 170, 170, 160, 255, 234, 62, 71, 99, 71, 175, 33, 227, 248, 240, 154, 128, 79, 47, 102]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{4135609568, 4178929520, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.EmptyItems{}}}}) == Some{[177, 171, 31, 154, 233, 59, 132, 80, 33, 128, 247, 227, 41, 170, 170, 160, 255, 234, 62, 71, 99, 71, 175, 33, 227, 248, 240, 154, 128, 79, 47, 102, 36, 0, 0, 0, 224, 100, 128, 246, 112, 103, 21, 249, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c103() -> {Codec.encoding_for_legal_type(F.DataColumnsByRootIdentifier(), T.Sequence{T.Items{T.BytesValue{[177, 171, 31, 154, 233, 59, 132, 80, 33, 128, 247, 227, 41, 170, 170, 160, 255, 234, 62, 71, 99, 71, 175, 33, 227, 248, 240, 154, 95, 79, 47, 102]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{4135609568, 4279592816, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.EmptyItems{}}}}) == Some{[177, 171, 31, 154, 233, 59, 132, 80, 33, 128, 247, 227, 41, 170, 170, 160, 255, 234, 62, 71, 99, 71, 175, 33, 227, 248, 240, 154, 95, 79, 47, 102, 36, 0, 0, 0, 224, 100, 128, 246, 112, 103, 21, 255, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
