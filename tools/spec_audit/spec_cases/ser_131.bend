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

def c727() -> {Codec.encoding_for_legal_type(G.vec_bool_8(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}}}}}}) == Some{[1, 1, 1, 0, 1, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c728() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2409422191, 649716942, 3176130764, 4216520559, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[111, 221, 156, 143, 206, 228, 185, 38, 204, 232, 79, 189, 111, 255, 82, 251]} : Maybe<&2, +List<U32>>}:
  {==}

def c729() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2409422191, 649716942, 4283427020, 4216512879, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[111, 221, 156, 143, 206, 228, 185, 38, 204, 232, 79, 255, 111, 225, 82, 251]} : Maybe<&2, +List<U32>>}:
  {==}

def c730() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2409422191, 649716942, 2152720588, 4216512879, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[111, 221, 156, 143, 206, 228, 185, 38, 204, 232, 79, 128, 111, 225, 82, 251]} : Maybe<&2, +List<U32>>}:
  {==}

def c731() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2409422191, 649716942, 3176136652, 4216512879, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[111, 221, 156, 143, 206, 228, 185, 38, 204, 255, 79, 189, 111, 225, 82, 251]} : Maybe<&2, +List<U32>>}:
  {==}

def c732() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967040, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c733() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 255, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c734() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294902015, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
