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

def c308() -> {Codec.encoding_for_legal_type(G.bitlist_1(), T.BitsValue{[False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c309() -> {Codec.encoding_for_legal_type(G.bitlist_1(), T.BitsValue{[True{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}

def c310() -> {Codec.encoding_for_legal_type(G.bitlist_1(), T.BitsValue{[]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c311() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[1, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c312() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c313() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c314() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]}) == Some{[0, 5]} : Maybe<&2, +List<U32>>}:
  {==}

def c315() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[True{}, False{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c316() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[True{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[203, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c317() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[0, 12]} : Maybe<&2, +List<U32>>}:
  {==}

def c318() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[False{}, False{}, True{}]}) == Some{[12]} : Maybe<&2, +List<U32>>}:
  {==}

def c319() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[5, 1]} : Maybe<&2, +List<U32>>}:
  {==}
