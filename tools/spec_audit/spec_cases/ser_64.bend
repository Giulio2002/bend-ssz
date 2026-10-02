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

def c320() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[4, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c321() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}]}) == Some{[0, 15]} : Maybe<&2, +List<U32>>}:
  {==}

def c322() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}]}) == Some{[15, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c323() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[1, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c324() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c325() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}]}) == Some{[0, 188]} : Maybe<&2, +List<U32>>}:
  {==}

def c326() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[True{}, False{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c327() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[True{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[13, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c328() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}]}) == Some{[160, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c329() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, True{}]}) == Some{[149, 219]} : Maybe<&2, +List<U32>>}:
  {==}

def c330() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[True{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}

def c331() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}
