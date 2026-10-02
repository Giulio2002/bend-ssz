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

def c506() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}]}) == Some{[0, 16, 5, 208, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c507() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 0, 1, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c508() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[False{}, True{}, False{}, True{}]}) == Some{[10]} : Maybe<&2, +List<U32>>}:
  {==}

def c509() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[True{}, True{}, False{}, True{}]}) == Some{[11]} : Maybe<&2, +List<U32>>}:
  {==}

def c510() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[False{}, True{}, True{}, True{}]}) == Some{[14]} : Maybe<&2, +List<U32>>}:
  {==}

def c511() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[True{}, False{}, False{}, True{}]}) == Some{[9]} : Maybe<&2, +List<U32>>}:
  {==}

def c512() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[False{}, False{}, False{}, True{}]}) == Some{[8]} : Maybe<&2, +List<U32>>}:
  {==}

def c513() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[False{}, False{}, False{}, False{}]}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c514() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[True{}, False{}, False{}, False{}]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c515() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[True{}, True{}, True{}, True{}]}) == Some{[15]} : Maybe<&2, +List<U32>>}:
  {==}

def c516() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[False{}, True{}, True{}, False{}, True{}]}) == Some{[22]} : Maybe<&2, +List<U32>>}:
  {==}

def c517() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[False{}, False{}, True{}, False{}, False{}]}) == Some{[4]} : Maybe<&2, +List<U32>>}:
  {==}
