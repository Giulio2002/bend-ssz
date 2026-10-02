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

def c332() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[True{}, True{}, True{}]}) == Some{[15]} : Maybe<&2, +List<U32>>}:
  {==}

def c333() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[12, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c334() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[1, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c335() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[False{}, False{}]}) == Some{[4]} : Maybe<&2, +List<U32>>}:
  {==}

def c336() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[False{}, True{}]}) == Some{[6]} : Maybe<&2, +List<U32>>}:
  {==}

def c337() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c338() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c339() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[True{}, True{}]}) == Some{[7]} : Maybe<&2, +List<U32>>}:
  {==}

def c340() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[True{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}

def c341() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[True{}, False{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c342() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[True{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}

def c343() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[False{}, False{}]}) == Some{[4]} : Maybe<&2, +List<U32>>}:
  {==}
