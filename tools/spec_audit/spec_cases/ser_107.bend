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

def c548() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[False{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[62]} : Maybe<&2, +List<U32>>}:
  {==}

def c549() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[False{}, False{}, True{}, False{}, False{}, True{}]}) == Some{[36]} : Maybe<&2, +List<U32>>}:
  {==}

def c550() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}, True{}]}) == Some{[37]} : Maybe<&2, +List<U32>>}:
  {==}

def c551() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c552() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[False{}, True{}, True{}, False{}, True{}, True{}]}) == Some{[54]} : Maybe<&2, +List<U32>>}:
  {==}

def c553() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[True{}, True{}, False{}, True{}, False{}, True{}]}) == Some{[43]} : Maybe<&2, +List<U32>>}:
  {==}

def c554() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c555() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[63]} : Maybe<&2, +List<U32>>}:
  {==}

def c556() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[False{}, False{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[124]} : Maybe<&2, +List<U32>>}:
  {==}

def c557() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[False{}, True{}, False{}, True{}, True{}, False{}, False{}]}) == Some{[26]} : Maybe<&2, +List<U32>>}:
  {==}

def c558() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c559() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[False{}, True{}, True{}, False{}, True{}, True{}, False{}]}) == Some{[54]} : Maybe<&2, +List<U32>>}:
  {==}
