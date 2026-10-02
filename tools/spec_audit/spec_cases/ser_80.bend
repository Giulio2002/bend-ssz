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

def c493() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 128, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c494() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}]}) == Some{[2, 64, 86, 150]} : Maybe<&2, +List<U32>>}:
  {==}

def c495() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[0, 0, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c496() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[True{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}]}) == Some{[205, 233, 25, 234]} : Maybe<&2, +List<U32>>}:
  {==}

def c497() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[0, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c498() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}]}) == Some{[2, 255, 86, 150]} : Maybe<&2, +List<U32>>}:
  {==}

def c499() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[255, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
