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

def c380() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[False{}, True{}, True{}]}) == Some{[14]} : Maybe<&2, +List<U32>>}:
  {==}

def c381() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c382() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[True{}, True{}, True{}]}) == Some{[15]} : Maybe<&2, +List<U32>>}:
  {==}

def c383() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}]}) == Some{[32]} : Maybe<&2, +List<U32>>}:
  {==}

def c384() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[True{}, False{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c385() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[True{}, False{}, True{}, True{}]}) == Some{[29]} : Maybe<&2, +List<U32>>}:
  {==}

def c386() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[True{}, True{}, True{}, False{}]}) == Some{[23]} : Maybe<&2, +List<U32>>}:
  {==}

def c387() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c388() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[False{}, False{}, True{}, False{}]}) == Some{[20]} : Maybe<&2, +List<U32>>}:
  {==}

def c389() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[False{}, True{}, True{}, False{}]}) == Some{[22]} : Maybe<&2, +List<U32>>}:
  {==}

def c390() -> {Codec.encoding_for_legal_type(G.bitlist_511(), T.BitsValue{[False{}, False{}]}) == Some{[4]} : Maybe<&2, +List<U32>>}:
  {==}

def c391() -> {Codec.encoding_for_legal_type(G.bitlist_511(), T.BitsValue{[False{}, True{}, True{}]}) == Some{[14]} : Maybe<&2, +List<U32>>}:
  {==}
