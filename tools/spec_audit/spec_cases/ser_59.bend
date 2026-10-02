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

def c279() -> {Codec.encoding_for_legal_type(F.ValidatorIndex(), T.UnsignedValue{P.UInt{663358322, 2550173551, 0, 0, 0, 0, 0, 0}}) == Some{[114, 11, 138, 39, 111, 143, 0, 152]} : Maybe<&2, +List<U32>>}:
  {==}

def c280() -> {Codec.encoding_for_legal_type(F.ValidatorIndex(), T.UnsignedValue{P.UInt{4294967168, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[128, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c281() -> {Codec.encoding_for_legal_type(F.ValidatorIndex(), T.UnsignedValue{P.UInt{4294967295, 33554431, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c282() -> {Codec.encoding_for_legal_type(G.VarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{51178, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[234, 199, 7, 0, 0, 0, 255, 0, 0, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c283() -> {Codec.encoding_for_legal_type(G.VarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65279, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 254]} : Maybe<&2, +List<U32>>}:
  {==}

def c284() -> {Codec.encoding_for_legal_type(G.VarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 255, 7, 0, 0, 0, 0, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c285() -> {Codec.encoding_for_legal_type(G.VarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[128, 0, 7, 0, 0, 0, 0, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c286() -> {Codec.encoding_for_legal_type(G.VarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65279, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 0, 7, 0, 0, 0, 0, 255, 254]} : Maybe<&2, +List<U32>>}:
  {==}
