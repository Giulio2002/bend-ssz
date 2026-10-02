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

def c169() -> {Codec.encoding_for_legal_type(F.KZGProof(), T.BytesValue{[83, 128, 77, 84, 116, 160, 50, 130, 16, 74, 101, 237, 219, 84, 255, 105, 246, 101, 250, 202, 45, 112, 235, 144, 150, 102, 226, 219, 152, 66, 212, 173, 119, 245, 21, 231, 194, 40, 238, 23, 127, 247, 59, 147, 90, 18, 165, 148]}) == Some{[83, 128, 77, 84, 116, 160, 50, 130, 16, 74, 101, 237, 219, 84, 255, 105, 246, 101, 250, 202, 45, 112, 235, 144, 150, 102, 226, 219, 152, 66, 212, 173, 119, 245, 21, 231, 194, 40, 238, 23, 127, 247, 59, 147, 90, 18, 165, 148]} : Maybe<&2, +List<U32>>}:
  {==}

def c170() -> {Codec.encoding_for_legal_type(F.KZGProof(), T.BytesValue{[0, 203, 70, 74, 20, 136, 166, 69, 155, 154, 4, 167, 224, 85, 28, 253, 251, 18, 103, 188, 225, 73, 99, 152, 104, 63, 255, 56, 140, 120, 3, 167, 12, 159, 28, 170, 32, 97, 68, 94, 94, 122, 164, 143, 12, 80, 94, 21]}) == Some{[0, 203, 70, 74, 20, 136, 166, 69, 155, 154, 4, 167, 224, 85, 28, 253, 251, 18, 103, 188, 225, 73, 99, 152, 104, 63, 255, 56, 140, 120, 3, 167, 12, 159, 28, 170, 32, 97, 68, 94, 94, 122, 164, 143, 12, 80, 94, 21]} : Maybe<&2, +List<U32>>}:
  {==}

def c171() -> {Codec.encoding_for_legal_type(F.KZGProof(), T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255]}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c172() -> {Codec.encoding_for_legal_type(F.NodeID(), T.UnsignedValue{P.UInt{3945375997, 1100302429, 3775378795, 3891331831, 3864835128, 2163679472, 4014615781, 2927054233}}) == Some{[253, 168, 41, 235, 93, 72, 149, 65, 107, 181, 7, 225, 247, 2, 241, 231, 56, 180, 92, 230, 240, 32, 247, 128, 229, 44, 74, 239, 153, 77, 119, 174]} : Maybe<&2, +List<U32>>}:
  {==}

def c173() -> {Codec.encoding_for_legal_type(F.NodeID(), T.UnsignedValue{P.UInt{0, 128, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c174() -> {Codec.encoding_for_legal_type(F.NodeID(), T.UnsignedValue{P.UInt{3673934592, 592782495, 657645502, 4286139342, 1663925263, 1461635962, 2486352933, 1873684971}}) == Some{[0, 203, 251, 218, 159, 36, 85, 35, 190, 223, 50, 39, 206, 75, 121, 255, 15, 124, 45, 99, 122, 203, 30, 87, 37, 188, 50, 148, 235, 41, 174, 111]} : Maybe<&2, +List<U32>>}:
  {==}
