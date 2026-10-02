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

def c406() -> {Codec.encoding_for_legal_type(G.bitlist_513(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[128]} : Maybe<&2, +List<U32>>}:
  {==}

def c407() -> {Codec.encoding_for_legal_type(G.bitlist_513(), T.BitsValue{[True{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[153, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c408() -> {Codec.encoding_for_legal_type(G.bitlist_513(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c409() -> {Codec.encoding_for_legal_type(G.bitlist_513(), T.BitsValue{[False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c410() -> {Codec.encoding_for_legal_type(G.bitlist_513(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}]}) == Some{[0, 29]} : Maybe<&2, +List<U32>>}:
  {==}

def c411() -> {Codec.encoding_for_legal_type(G.bitlist_513(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 4]} : Maybe<&2, +List<U32>>}:
  {==}

def c412() -> {Codec.encoding_for_legal_type(G.bitlist_513(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c413() -> {Codec.encoding_for_legal_type(G.bitlist_513(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}]}) == Some{[0, 153, 15]} : Maybe<&2, +List<U32>>}:
  {==}

def c414() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}]}) == Some{[33]} : Maybe<&2, +List<U32>>}:
  {==}

def c415() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[False{}, True{}, True{}]}) == Some{[14]} : Maybe<&2, +List<U32>>}:
  {==}

def c416() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c417() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[True{}, False{}, False{}, True{}, True{}]}) == Some{[57]} : Maybe<&2, +List<U32>>}:
  {==}
