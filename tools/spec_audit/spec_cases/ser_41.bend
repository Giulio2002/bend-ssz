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

def c204() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleFieldContainerTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c205() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleFieldContainerTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{254, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[254]} : Maybe<&2, +List<U32>>}:
  {==}

def c206() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleListContainerTestStruct(), T.Sequence{T.Items{T.BitsValue{[True{}, True{}, True{}]}, T.EmptyItems{}}}) == Some{[4, 0, 0, 0, 15]} : Maybe<&2, +List<U32>>}:
  {==}

def c207() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleListContainerTestStruct(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}, False{}, True{}, True{}, True{}, True{}]}, T.EmptyItems{}}}) == Some{[4, 0, 0, 0, 248]} : Maybe<&2, +List<U32>>}:
  {==}

def c208() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleListContainerTestStruct(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}) == Some{[4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32]} : Maybe<&2, +List<U32>>}:
  {==}

def c209() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleListContainerTestStruct(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}, False{}]}, T.EmptyItems{}}}) == Some{[4, 0, 0, 0, 8]} : Maybe<&2, +List<U32>>}:
  {==}

def c210() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleListContainerTestStruct(), T.Sequence{T.Items{T.BitsValue{[False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}) == Some{[4, 0, 0, 0, 2, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c211() -> {Codec.encoding_for_legal_type(G.ProgressiveSingleListContainerTestStruct(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}, True{}]}, T.EmptyItems{}}}) == Some{[4, 0, 0, 0, 12]} : Maybe<&2, +List<U32>>}:
  {==}
