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

def c430() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[False{}, True{}]}) == Some{[6]} : Maybe<&2, +List<U32>>}:
  {==}

def c431() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[True{}, True{}]}) == Some{[7]} : Maybe<&2, +List<U32>>}:
  {==}

def c432() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[True{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}

def c433() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[False{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}]}) == Some{[166, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c434() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c435() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}]}) == Some{[15, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c436() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[2, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c437() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[True{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}]}) == Some{[179, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c438() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}]}) == Some{[15, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c439() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 2]} : Maybe<&2, +List<U32>>}:
  {==}

def c440() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c441() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[False{}, True{}, True{}]}) == Some{[14]} : Maybe<&2, +List<U32>>}:
  {==}
