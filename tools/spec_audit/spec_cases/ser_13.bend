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

def c77() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c78() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c79() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{3, T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}]}, T.EmptyItems{}}}}}}) == Some{[3, 0, 9, 0, 0, 0, 9, 0, 0, 0, 255, 4]} : Maybe<&2, +List<U32>>}:
  {==}

def c80() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{2, T.Sequence{T.Items{T.BitsValue{[False{}, True{}, False{}]}, T.EmptyItems{}}}}) == Some{[2, 4, 0, 0, 0, 10]} : Maybe<&2, +List<U32>>}:
  {==}

def c81() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{2, T.Sequence{T.Items{T.BitsValue{[]}, T.EmptyItems{}}}}) == Some{[2, 4, 0, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c82() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{3, T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[True{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}]}, T.EmptyItems{}}}}}}) == Some{[3, 0, 9, 0, 0, 0, 9, 0, 0, 0, 87, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c83() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{3, T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[True{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}) == Some{[3, 255, 9, 0, 0, 0, 9, 0, 0, 0, 87, 4]} : Maybe<&2, +List<U32>>}:
  {==}

def c84() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{3, T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.BitsValue{[True{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}) == Some{[3, 1, 9, 0, 0, 0, 9, 0, 0, 0, 87, 4]} : Maybe<&2, +List<U32>>}:
  {==}

def c85() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{2, T.Sequence{T.Items{T.BitsValue{[True{}]}, T.EmptyItems{}}}}) == Some{[2, 4, 0, 0, 0, 3]} : Maybe<&2, +List<U32>>}:
  {==}
