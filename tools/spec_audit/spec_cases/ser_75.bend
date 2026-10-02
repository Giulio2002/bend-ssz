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

def c442() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c443() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}]}) == Some{[197, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c444() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}]}) == Some{[239, 2]} : Maybe<&2, +List<U32>>}:
  {==}

def c445() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[False{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}]}) == Some{[18, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c446() -> {Codec.encoding_for_legal_type(G.bitvector_1(), T.BitsValue{[True{}]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c447() -> {Codec.encoding_for_legal_type(G.bitvector_1(), T.BitsValue{[False{}]}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c448() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c449() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}]}) == Some{[0, 115]} : Maybe<&2, +List<U32>>}:
  {==}

def c450() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}]}) == Some{[255, 24]} : Maybe<&2, +List<U32>>}:
  {==}

def c451() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[119, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c452() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[True{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}]}) == Some{[49, 96]} : Maybe<&2, +List<U32>>}:
  {==}

def c453() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 1]} : Maybe<&2, +List<U32>>}:
  {==}
