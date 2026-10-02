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

def c797() -> {Codec.encoding_for_legal_type(G.vec_uint16_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[128, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c798() -> {Codec.encoding_for_legal_type(G.vec_uint16_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{22742, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{30180, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[214, 88, 228, 117]} : Maybe<&2, +List<U32>>}:
  {==}

def c799() -> {Codec.encoding_for_legal_type(G.vec_uint16_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 0, 128, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c800() -> {Codec.encoding_for_legal_type(G.vec_uint16_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{34012, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{32769, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[220, 132, 1, 128, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c801() -> {Codec.encoding_for_legal_type(G.vec_uint16_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c802() -> {Codec.encoding_for_legal_type(G.vec_uint16_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{33023, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 128, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c803() -> {Codec.encoding_for_legal_type(G.vec_uint16_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{34012, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[220, 132, 1, 0, 128, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c804() -> {Codec.encoding_for_legal_type(G.vec_uint16_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{33792, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 132, 1, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
