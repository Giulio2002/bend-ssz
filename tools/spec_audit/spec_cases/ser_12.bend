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

def c67() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{63, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 63]} : Maybe<&2, +List<U32>>}:
  {==}

def c68() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c69() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c70() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c71() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{2, T.Sequence{T.Items{T.BitsValue{[False{}, True{}, False{}, True{}, True{}, False{}]}, T.EmptyItems{}}}}) == Some{[2, 4, 0, 0, 0, 90]} : Maybe<&2, +List<U32>>}:
  {==}

def c72() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{2, T.Sequence{T.Items{T.BitsValue{[True{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}]}, T.EmptyItems{}}}}) == Some{[2, 4, 0, 0, 0, 91, 18]} : Maybe<&2, +List<U32>>}:
  {==}

def c73() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{2, T.Sequence{T.Items{T.BitsValue{[False{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}) == Some{[2, 4, 0, 0, 0, 90, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c74() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{2, T.Sequence{T.Items{T.BitsValue{[False{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}]}, T.EmptyItems{}}}}) == Some{[2, 4, 0, 0, 0, 90, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c75() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{2, T.Sequence{T.Items{T.BitsValue{[False{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}]}, T.EmptyItems{}}}}) == Some{[2, 4, 0, 0, 0, 90, 19]} : Maybe<&2, +List<U32>>}:
  {==}

def c76() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{254, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 254]} : Maybe<&2, +List<U32>>}:
  {==}
