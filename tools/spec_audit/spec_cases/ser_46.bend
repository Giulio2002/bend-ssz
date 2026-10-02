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

def c226() -> {Codec.encoding_for_legal_type(G.ProgressiveVarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{153, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.BitsValue{[True{}, True{}, False{}, True{}, True{}, False{}]}, T.EmptyItems{}}}}}) == Some{[153, 9, 0, 0, 0, 11, 0, 0, 0, 1, 0, 91]} : Maybe<&2, +List<U32>>}:
  {==}

def c227() -> {Codec.encoding_for_legal_type(G.ProgressiveVarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{153, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.BitsValue{[True{}, True{}, False{}, True{}, True{}, False{}]}, T.EmptyItems{}}}}}) == Some{[153, 9, 0, 0, 0, 11, 0, 0, 0, 255, 0, 91]} : Maybe<&2, +List<U32>>}:
  {==}

def c228() -> {Codec.encoding_for_legal_type(G.ProgressiveVarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{156, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.BitsValue{[]}, T.EmptyItems{}}}}}) == Some{[0, 9, 0, 0, 0, 11, 0, 0, 0, 156, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c229() -> {Codec.encoding_for_legal_type(G.ProgressiveVarTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{22172, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}) == Some{[0, 9, 0, 0, 0, 11, 0, 0, 0, 156, 86, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c230() -> {Codec.encoding_for_legal_type(F.Root(), T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255]}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c231() -> {Codec.encoding_for_legal_type(F.Root(), T.BytesValue{[219, 1, 109, 232, 52, 215, 171, 141, 255, 229, 104, 167, 120, 130, 162, 242, 101, 187, 164, 53, 231, 102, 201, 186, 252, 202, 238, 132, 147, 28, 204, 108]}) == Some{[219, 1, 109, 232, 52, 215, 171, 141, 255, 229, 104, 167, 120, 130, 162, 242, 101, 187, 164, 53, 231, 102, 201, 186, 252, 202, 238, 132, 147, 28, 204, 108]} : Maybe<&2, +List<U32>>}:
  {==}

def c232() -> {Codec.encoding_for_legal_type(F.Root(), T.BytesValue{[116, 107, 84, 220, 178, 103, 129, 117, 217, 121, 10, 13, 66, 78, 110, 62, 86, 176, 15, 28, 186, 0, 73, 52, 217, 215, 243, 178, 91, 175, 33, 175]}) == Some{[116, 107, 84, 220, 178, 103, 129, 117, 217, 121, 10, 13, 66, 78, 110, 62, 86, 176, 15, 28, 186, 0, 73, 52, 217, 215, 243, 178, 91, 175, 33, 175]} : Maybe<&2, +List<U32>>}:
  {==}
