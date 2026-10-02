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

def c629() -> {Codec.encoding_for_legal_type(G.proglist_uint32(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1547558784, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3030390463, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[128, 223, 61, 92, 191, 22, 160, 180]} : Maybe<&2, +List<U32>>}:
  {==}

def c630() -> {Codec.encoding_for_legal_type(G.proglist_uint64(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 33554431, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c631() -> {Codec.encoding_for_legal_type(G.proglist_uint64(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4286644223, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c632() -> {Codec.encoding_for_legal_type(G.proglist_uint64(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{320138561, 503593328, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 16711680, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{559648445, 1586749618, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[65, 237, 20, 19, 112, 57, 4, 30, 0, 0, 0, 0, 0, 0, 255, 0, 189, 142, 91, 33, 178, 224, 147, 94]} : Maybe<&2, +List<U32>>}:
  {==}

def c633() -> {Codec.encoding_for_legal_type(G.proglist_uint64(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c634() -> {Codec.encoding_for_legal_type(G.proglist_uint64(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 2164260863, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c635() -> {Codec.encoding_for_legal_type(G.proglist_uint64(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{214753924, 1420042911, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[132, 226, 204, 12, 159, 34, 164, 84, 0, 255, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
