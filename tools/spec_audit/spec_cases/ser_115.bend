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

def c620() -> {Codec.encoding_for_legal_type(G.proglist_uint256(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 8388608, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c621() -> {Codec.encoding_for_legal_type(G.proglist_uint256(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{8388608, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c622() -> {Codec.encoding_for_legal_type(G.proglist_uint32(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{16711680, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 0, 0, 0, 0, 0, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c623() -> {Codec.encoding_for_legal_type(G.proglist_uint32(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2568617794, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1521554228, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[66, 255, 25, 153, 52, 19, 177, 90]} : Maybe<&2, +List<U32>>}:
  {==}

def c624() -> {Codec.encoding_for_legal_type(G.proglist_uint32(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967040, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 0, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c625() -> {Codec.encoding_for_legal_type(G.proglist_uint32(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{16777216, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 1, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c626() -> {Codec.encoding_for_legal_type(G.proglist_uint32(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2568571202, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1521553972, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[66, 73, 25, 153, 52, 18, 177, 90]} : Maybe<&2, +List<U32>>}:
  {==}

def c627() -> {Codec.encoding_for_legal_type(G.proglist_uint32(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{8388609, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[1, 0, 128, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c628() -> {Codec.encoding_for_legal_type(G.proglist_uint32(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 255, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
