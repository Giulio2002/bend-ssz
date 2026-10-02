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

def c199() -> {Codec.encoding_for_legal_type(G.ProgressiveComplexTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[]}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[False{}, True{}, False{}, True{}, True{}]}, T.EmptyItems{}}}}}, T.EmptyItems{}}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 29, 0, 0, 0, 29, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 1, 4, 0, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, 58]} : Maybe<&2, +List<U32>>}:
  {==}

def c200() -> {Codec.encoding_for_legal_type(G.ProgressiveComplexTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[]}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.EmptyItems{}}}}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 29, 0, 0, 0, 29, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 42, 0, 0, 0, 42, 0, 0, 0, 42, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c201() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleFieldContainerTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[128]} : Maybe<&2, +List<U32>>}:
  {==}

def c202() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleFieldContainerTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c203() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleFieldContainerTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}
