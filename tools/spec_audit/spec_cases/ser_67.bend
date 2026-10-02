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

def c356() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[128]} : Maybe<&2, +List<U32>>}:
  {==}

def c357() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[3, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c358() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[True{}, True{}, True{}]}) == Some{[15]} : Maybe<&2, +List<U32>>}:
  {==}

def c359() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}]}) == Some{[23, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c360() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}]}) == Some{[22, 198]} : Maybe<&2, +List<U32>>}:
  {==}

def c361() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 0, 2]} : Maybe<&2, +List<U32>>}:
  {==}

def c362() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 0, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c363() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[False{}, True{}, True{}]}) == Some{[14]} : Maybe<&2, +List<U32>>}:
  {==}

def c364() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[True{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}

def c365() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[True{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}]}) == Some{[233, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c366() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}]}) == Some{[229, 88]} : Maybe<&2, +List<U32>>}:
  {==}

def c367() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[True{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}]}) == Some{[215, 77]} : Maybe<&2, +List<U32>>}:
  {==}
