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

def c486() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 128, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c487() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, True{}]}) == Some{[44, 45, 67, 71]} : Maybe<&2, +List<U32>>}:
  {==}

def c488() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[True{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}]}) == Some{[123, 255, 232, 10]} : Maybe<&2, +List<U32>>}:
  {==}

def c489() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[1, 255, 255, 127]} : Maybe<&2, +List<U32>>}:
  {==}

def c490() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[True{}, True{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}]}) == Some{[227, 128, 155, 50]} : Maybe<&2, +List<U32>>}:
  {==}

def c491() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 1, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c492() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[True{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}]}) == Some{[205, 255, 25, 234]} : Maybe<&2, +List<U32>>}:
  {==}
