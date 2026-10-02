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

def c986() -> {Codec.encoding_for_legal_type(G.vec_uint64_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1459059331, 1844350536, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4131726097, 217155816, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4102173847, 15876339, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[131, 122, 247, 86, 72, 142, 238, 109, 17, 35, 69, 246, 232, 136, 241, 12, 0, 0, 0, 0, 0, 0, 0, 0, 151, 52, 130, 244, 243, 64, 242, 0, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c987() -> {Codec.encoding_for_legal_type(G.vec_uint64_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 255, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{709940937, 2517269901, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[1, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 201, 214, 80, 42, 141, 125, 10, 150, 255, 255, 255, 255, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c988() -> {Codec.encoding_for_legal_type(G.vec_uint64_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 16777215, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c989() -> {Codec.encoding_for_legal_type(G.vec_uint64_5(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1459059331, 1844350536, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4131726097, 217155816, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4102173847, 2415018227, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4278190079, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}) == Some{[131, 122, 247, 86, 72, 142, 238, 109, 17, 35, 69, 246, 232, 136, 241, 12, 0, 0, 0, 0, 0, 0, 0, 0, 151, 52, 130, 244, 243, 64, 242, 143, 255, 255, 255, 254, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
