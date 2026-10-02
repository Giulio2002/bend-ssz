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

def c1000() -> {Codec.encoding_for_legal_type(G.vec_uint8_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[128]} : Maybe<&2, +List<U32>>}:
  {==}

def c1001() -> {Codec.encoding_for_legal_type(G.vec_uint8_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{182, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[182]} : Maybe<&2, +List<U32>>}:
  {==}

def c1002() -> {Codec.encoding_for_legal_type(G.vec_uint8_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{183, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[183]} : Maybe<&2, +List<U32>>}:
  {==}

def c1003() -> {Codec.encoding_for_legal_type(G.vec_uint8_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c1004() -> {Codec.encoding_for_legal_type(G.vec_uint8_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{40, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[40]} : Maybe<&2, +List<U32>>}:
  {==}

def c1005() -> {Codec.encoding_for_legal_type(G.vec_uint8_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{195, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[195]} : Maybe<&2, +List<U32>>}:
  {==}

def c1006() -> {Codec.encoding_for_legal_type(G.vec_uint8_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{41, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[41]} : Maybe<&2, +List<U32>>}:
  {==}

def c1007() -> {Codec.encoding_for_legal_type(G.vec_uint8_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c1008() -> {Codec.encoding_for_legal_type(G.vec_uint8_16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{118, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{127, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{175, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{213, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{242, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{11, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{109, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{124, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{240, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{42, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{234, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{63, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{196, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{99, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}) == Some{[118, 127, 2, 175, 213, 242, 11, 109, 124, 240, 42, 234, 63, 196, 255, 99]} : Maybe<&2, +List<U32>>}:
  {==}
