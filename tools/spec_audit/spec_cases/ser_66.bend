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

def c344() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[False{}, True{}, True{}]}) == Some{[14]} : Maybe<&2, +List<U32>>}:
  {==}

def c345() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[False{}, False{}, False{}]}) == Some{[8]} : Maybe<&2, +List<U32>>}:
  {==}

def c346() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c347() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[True{}, True{}, True{}]}) == Some{[15]} : Maybe<&2, +List<U32>>}:
  {==}

def c348() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[True{}, False{}, False{}]}) == Some{[9]} : Maybe<&2, +List<U32>>}:
  {==}

def c349() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[False{}, True{}]}) == Some{[6]} : Maybe<&2, +List<U32>>}:
  {==}

def c350() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[True{}, False{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c351() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 2]} : Maybe<&2, +List<U32>>}:
  {==}

def c352() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[True{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}]}) == Some{[221, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c353() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[1, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c354() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 0, 0, 64]} : Maybe<&2, +List<U32>>}:
  {==}

def c355() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[True{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}]}) == Some{[201, 3]} : Maybe<&2, +List<U32>>}:
  {==}
