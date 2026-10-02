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

def c636() -> {Codec.encoding_for_legal_type(G.proglist_uint64(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967168, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c637() -> {Codec.encoding_for_legal_type(G.proglist_uint64(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294902015, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c638() -> {Codec.encoding_for_legal_type(G.proglist_uint8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{36, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 36]} : Maybe<&2, +List<U32>>}:
  {==}

def c639() -> {Codec.encoding_for_legal_type(G.proglist_uint8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c640() -> {Codec.encoding_for_legal_type(G.proglist_uint8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{254, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[254, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c641() -> {Codec.encoding_for_legal_type(G.proglist_uint8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c642() -> {Codec.encoding_for_legal_type(G.proglist_uint8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c643() -> {Codec.encoding_for_legal_type(G.proglist_uint8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{252, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[252, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c644() -> {Codec.encoding_for_legal_type(G.proglist_uint8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{37, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 37]} : Maybe<&2, +List<U32>>}:
  {==}
