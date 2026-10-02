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

def c418() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[False{}, False{}]}) == Some{[4]} : Maybe<&2, +List<U32>>}:
  {==}

def c419() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[65]} : Maybe<&2, +List<U32>>}:
  {==}

def c420() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[True{}, True{}, True{}]}) == Some{[15]} : Maybe<&2, +List<U32>>}:
  {==}

def c421() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[False{}, True{}]}) == Some{[6]} : Maybe<&2, +List<U32>>}:
  {==}

def c422() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[False{}, False{}, False{}, True{}]}) == Some{[24]} : Maybe<&2, +List<U32>>}:
  {==}

def c423() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[True{}, False{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c424() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[False{}, True{}, False{}, True{}]}) == Some{[26]} : Maybe<&2, +List<U32>>}:
  {==}

def c425() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[64]} : Maybe<&2, +List<U32>>}:
  {==}

def c426() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c427() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[False{}, True{}, True{}]}) == Some{[14]} : Maybe<&2, +List<U32>>}:
  {==}

def c428() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c429() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[False{}, True{}]}) == Some{[6]} : Maybe<&2, +List<U32>>}:
  {==}
