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

def c748() -> {Codec.encoding_for_legal_type(G.vec_uint128_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294901759, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c749() -> {Codec.encoding_for_legal_type(G.vec_uint128_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967039, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c750() -> {Codec.encoding_for_legal_type(G.vec_uint128_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 65536, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c751() -> {Codec.encoding_for_legal_type(G.vec_uint128_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294902015, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c752() -> {Codec.encoding_for_legal_type(G.vec_uint128_4(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967294, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
