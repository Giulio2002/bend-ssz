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

def c159() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c160() -> {Codec.encoding_for_legal_type(G.vec_bool_5(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c161() -> {Codec.encoding_for_legal_type(G.vec_bool_5(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c162() -> {Codec.encoding_for_legal_type(G.vec_bool_8(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c163() -> {Codec.encoding_for_legal_type(G.vec_bool_8(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c164() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.EmptyItems{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c165() -> {Codec.encoding_for_legal_type(G.vec_uint128_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c166() -> {Codec.encoding_for_legal_type(G.vec_uint128_16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c167() -> {Codec.encoding_for_legal_type(G.vec_uint128_16(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c168() -> {Codec.encoding_for_legal_type(G.vec_uint128_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c169() -> {Codec.encoding_for_legal_type(G.vec_uint128_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c170() -> {Codec.encoding_for_legal_type(G.vec_uint128_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c171() -> {Codec.encoding_for_legal_type(G.vec_uint128_3(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}
