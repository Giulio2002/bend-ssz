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

def c560() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[False{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[126]} : Maybe<&2, +List<U32>>}:
  {==}

def c561() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[True{}, False{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[125]} : Maybe<&2, +List<U32>>}:
  {==}

def c562() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[True{}, True{}, True{}, False{}, True{}, True{}, False{}]}) == Some{[55]} : Maybe<&2, +List<U32>>}:
  {==}

def c563() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[127]} : Maybe<&2, +List<U32>>}:
  {==}

def c564() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[False{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}]}) == Some{[120]} : Maybe<&2, +List<U32>>}:
  {==}

def c565() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c566() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c567() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c568() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[254]} : Maybe<&2, +List<U32>>}:
  {==}

def c569() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[128]} : Maybe<&2, +List<U32>>}:
  {==}

def c570() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}]}) == Some{[148]} : Maybe<&2, +List<U32>>}:
  {==}

def c571() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}]}) == Some{[95]} : Maybe<&2, +List<U32>>}:
  {==}
