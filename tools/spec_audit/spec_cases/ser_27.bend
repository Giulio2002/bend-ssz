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

def c133() -> {Codec.encoding_for_legal_type(F.ExecutionRequests(), T.Sequence{T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.EmptyItems{}}}}}) == Some{[12, 0, 0, 0, 12, 0, 0, 0, 12, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c134() -> {Codec.encoding_for_legal_type(G.FixedTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c135() -> {Codec.encoding_for_legal_type(G.FixedTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4278190079, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c136() -> {Codec.encoding_for_legal_type(G.FixedTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 16777215, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c137() -> {Codec.encoding_for_legal_type(G.FixedTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3732953461, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 1, 0, 0, 0, 0, 0, 0, 0, 117, 89, 128, 222]} : Maybe<&2, +List<U32>>}:
  {==}

def c138() -> {Codec.encoding_for_legal_type(G.FixedTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{33554431, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c139() -> {Codec.encoding_for_legal_type(G.FixedTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3736492405, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 1, 0, 0, 0, 0, 0, 0, 0, 117, 89, 182, 222]} : Maybe<&2, +List<U32>>}:
  {==}
