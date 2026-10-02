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

def c221() -> {Codec.encoding_for_legal_type(G.ProgressiveTestStruct(), T.Sequence{T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.EmptyItems{}}, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}, T.EmptyItems{}}}}}}) == Some{[16, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0, 80, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c222() -> {Codec.encoding_for_legal_type(G.ProgressiveVarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.BitsValue{[]}, T.EmptyItems{}}}}}) == Some{[0, 9, 0, 0, 0, 13, 0, 0, 0, 0, 255, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c223() -> {Codec.encoding_for_legal_type(G.ProgressiveVarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[False{}, False{}, True{}, False{}, False{}]}, T.EmptyItems{}}}}}) == Some{[128, 9, 0, 0, 0, 9, 0, 0, 0, 36]} : Maybe<&2, +List<U32>>}:
  {==}

def c224() -> {Codec.encoding_for_legal_type(G.ProgressiveVarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[]}, T.EmptyItems{}}}}}) == Some{[255, 9, 0, 0, 0, 9, 0, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c225() -> {Codec.encoding_for_legal_type(G.ProgressiveVarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}]}, T.EmptyItems{}}}}}) == Some{[0, 9, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}
