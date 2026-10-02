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

def c596() -> {Codec.encoding_for_legal_type(G.proglist_bool(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c597() -> {Codec.encoding_for_legal_type(G.proglist_bool(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}) == Some{[0, 1, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c598() -> {Codec.encoding_for_legal_type(G.proglist_uint128(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c599() -> {Codec.encoding_for_legal_type(G.proglist_uint128(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 2147483648, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c600() -> {Codec.encoding_for_legal_type(G.proglist_uint128(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2157004738, 2103327179, 1387874519, 3304904909, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 194, 71, 145, 128, 203, 57, 94, 125, 215, 72, 185, 82, 205, 216, 252, 196]} : Maybe<&2, +List<U32>>}:
  {==}

def c601() -> {Codec.encoding_for_legal_type(G.proglist_uint128(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2185458241, 3230891299, 290856449, 883796103, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[65, 114, 67, 130, 35, 125, 147, 192, 1, 30, 86, 17, 135, 168, 173, 52]} : Maybe<&2, +List<U32>>}:
  {==}

def c602() -> {Codec.encoding_for_legal_type(G.proglist_uint128(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294902015, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c603() -> {Codec.encoding_for_legal_type(G.proglist_uint128(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 8388608, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[1, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
