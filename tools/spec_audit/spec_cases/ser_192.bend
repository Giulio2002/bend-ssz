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

def c962() -> {Codec.encoding_for_legal_type(G.vec_uint64_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c963() -> {Codec.encoding_for_legal_type(G.vec_uint64_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 2147483648, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c964() -> {Codec.encoding_for_legal_type(G.vec_uint64_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{16777216, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c965() -> {Codec.encoding_for_legal_type(G.vec_uint64_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{16777215, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c966() -> {Codec.encoding_for_legal_type(G.vec_uint64_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 16777216, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c967() -> {Codec.encoding_for_legal_type(G.vec_uint64_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 255, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c968() -> {Codec.encoding_for_legal_type(G.vec_uint64_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{962592014, 4235604675, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2458389688, 518355585, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 4278190080, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[14, 253, 95, 57, 195, 50, 118, 252, 184, 12, 136, 146, 129, 122, 229, 30, 1, 0, 0, 0, 0, 0, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c969() -> {Codec.encoding_for_legal_type(G.vec_uint64_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{962592014, 4235604675, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2458389688, 518355585, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 32768, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[14, 253, 95, 57, 195, 50, 118, 252, 184, 12, 136, 146, 129, 122, 229, 30, 1, 0, 0, 0, 0, 128, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
