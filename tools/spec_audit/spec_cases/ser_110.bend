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

def c584() -> {Codec.encoding_for_legal_type(G.progbitlist(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 8]} : Maybe<&2, +List<U32>>}:
  {==}

def c585() -> {Codec.encoding_for_legal_type(G.progbitlist(), T.BitsValue{[True{}, True{}, True{}, False{}]}) == Some{[23]} : Maybe<&2, +List<U32>>}:
  {==}

def c586() -> {Codec.encoding_for_legal_type(G.progbitlist(), T.BitsValue{[True{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}]}) == Some{[177, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c587() -> {Codec.encoding_for_legal_type(G.progbitlist(), T.BitsValue{[False{}, False{}, False{}]}) == Some{[8]} : Maybe<&2, +List<U32>>}:
  {==}

def c588() -> {Codec.encoding_for_legal_type(G.progbitlist(), T.BitsValue{[True{}, False{}, False{}]}) == Some{[9]} : Maybe<&2, +List<U32>>}:
  {==}

def c589() -> {Codec.encoding_for_legal_type(G.progbitlist(), T.BitsValue{[True{}, False{}, True{}, True{}, False{}]}) == Some{[45]} : Maybe<&2, +List<U32>>}:
  {==}

def c590() -> {Codec.encoding_for_legal_type(G.proglist_bool(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}) == Some{[1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c591() -> {Codec.encoding_for_legal_type(G.proglist_bool(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}) == Some{[1, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c592() -> {Codec.encoding_for_legal_type(G.proglist_bool(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}) == Some{[0, 1, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c593() -> {Codec.encoding_for_legal_type(G.proglist_bool(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c594() -> {Codec.encoding_for_legal_type(G.proglist_bool(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}) == Some{[1, 1, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c595() -> {Codec.encoding_for_legal_type(G.proglist_bool(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}) == Some{[0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}
