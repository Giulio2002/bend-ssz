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

def c500() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}]}) == Some{[176, 16, 4, 208, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c501() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 254, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c502() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[True{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}]}) == Some{[215, 168, 1, 106, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c503() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[True{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[215, 168, 124, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c504() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}]}) == Some{[176, 16, 5, 208, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c505() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}]}) == Some{[176, 16, 0, 208, 1]} : Maybe<&2, +List<U32>>}:
  {==}
