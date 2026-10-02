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

def c464() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c465() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[True{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}]}) == Some{[79, 96, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c466() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}]}) == Some{[128, 96, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c467() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]}) == Some{[255, 130, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c468() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[255, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c469() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[False{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]}) == Some{[158, 131, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c470() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]}) == Some{[159, 130, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c471() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[255, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c472() -> {Codec.encoding_for_legal_type(G.bitvector_2(), T.BitsValue{[False{}, False{}]}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c473() -> {Codec.encoding_for_legal_type(G.bitvector_2(), T.BitsValue{[True{}, True{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}
