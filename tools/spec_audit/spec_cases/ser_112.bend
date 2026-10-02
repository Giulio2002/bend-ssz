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

def c604() -> {Codec.encoding_for_legal_type(G.proglist_uint128(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 65536, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c605() -> {Codec.encoding_for_legal_type(G.proglist_uint128(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 255, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c606() -> {Codec.encoding_for_legal_type(G.proglist_uint16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{26203, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65281, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{7794, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[91, 102, 1, 255, 114, 30]} : Maybe<&2, +List<U32>>}:
  {==}

def c607() -> {Codec.encoding_for_legal_type(G.proglist_uint16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{19688, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{37257, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{59015, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{56164, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{25727, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{14873, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{36860, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}) == Some{[0, 0, 232, 76, 137, 145, 135, 230, 255, 255, 100, 219, 0, 0, 255, 255, 1, 0, 1, 0, 127, 100, 0, 0, 25, 58, 0, 0, 0, 0, 255, 255, 255, 255, 252, 143, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c608() -> {Codec.encoding_for_legal_type(G.proglist_uint16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{26203, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{7794, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[91, 102, 128, 0, 114, 30]} : Maybe<&2, +List<U32>>}:
  {==}
