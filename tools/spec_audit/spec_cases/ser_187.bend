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

def c945() -> {Codec.encoding_for_legal_type(G.vec_uint64_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4278255615, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255, 255, 0, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c946() -> {Codec.encoding_for_legal_type(G.vec_uint64_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{568811161, 2306871606, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[153, 94, 231, 33, 54, 17, 128, 137]} : Maybe<&2, +List<U32>>}:
  {==}

def c947() -> {Codec.encoding_for_legal_type(G.vec_uint64_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c948() -> {Codec.encoding_for_legal_type(G.vec_uint64_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{568811161, 2298482998, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[153, 94, 231, 33, 54, 17, 0, 137]} : Maybe<&2, +List<U32>>}:
  {==}

def c949() -> {Codec.encoding_for_legal_type(G.vec_uint64_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{568852377, 2308247862, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[153, 255, 231, 33, 54, 17, 149, 137]} : Maybe<&2, +List<U32>>}:
  {==}

def c950() -> {Codec.encoding_for_legal_type(G.vec_uint64_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 65536, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 0, 0, 0, 0, 0, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c951() -> {Codec.encoding_for_legal_type(G.vec_uint64_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{568811161, 2308247809, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[153, 94, 231, 33, 1, 17, 149, 137]} : Maybe<&2, +List<U32>>}:
  {==}

def c952() -> {Codec.encoding_for_legal_type(G.vec_uint64_16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967294, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
