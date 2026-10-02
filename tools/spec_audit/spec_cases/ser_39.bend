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

def c195() -> {Codec.encoding_for_legal_type(G.ProgressiveComplexTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}]}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 29, 0, 0, 0, 31, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 0, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c196() -> {Codec.encoding_for_legal_type(G.ProgressiveComplexTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[True{}, False{}]}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 29, 0, 0, 0, 29, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 5]} : Maybe<&2, +List<U32>>}:
  {==}

def c197() -> {Codec.encoding_for_legal_type(G.ProgressiveComplexTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[False{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}]}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 29, 0, 0, 0, 29, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 228, 122, 23]} : Maybe<&2, +List<U32>>}:
  {==}

def c198() -> {Codec.encoding_for_legal_type(G.ProgressiveComplexTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{48958, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.BitsValue{[]}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 29, 0, 0, 0, 31, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 32, 0, 0, 0, 62, 191, 1]} : Maybe<&2, +List<U32>>}:
  {==}
