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

def c474() -> {Codec.encoding_for_legal_type(G.bitvector_2(), T.BitsValue{[True{}, False{}]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c475() -> {Codec.encoding_for_legal_type(G.bitvector_2(), T.BitsValue{[False{}, True{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c476() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[False{}, False{}, False{}]}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c477() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[True{}, True{}, False{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}

def c478() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[False{}, True{}, False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c479() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[True{}, False{}, False{}]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c480() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[False{}, True{}, True{}]}) == Some{[6]} : Maybe<&2, +List<U32>>}:
  {==}

def c481() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[True{}, True{}, True{}]}) == Some{[7]} : Maybe<&2, +List<U32>>}:
  {==}

def c482() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[True{}, False{}, True{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c483() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[False{}, False{}, True{}]}) == Some{[4]} : Maybe<&2, +List<U32>>}:
  {==}

def c484() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}]}) == Some{[128, 245, 155, 50]} : Maybe<&2, +List<U32>>}:
  {==}

def c485() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[0, 255, 255, 127]} : Maybe<&2, +List<U32>>}:
  {==}
