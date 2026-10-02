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

def c103() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c104() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c105() -> {Codec.encoding_for_legal_type(G.bitlist_8(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c106() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c107() -> {Codec.encoding_for_legal_type(G.bitlist_9(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c108() -> {Codec.encoding_for_legal_type(G.bitvector_1(), T.BitsValue{[]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c109() -> {Codec.encoding_for_legal_type(G.bitvector_1(), T.BitsValue{[False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c110() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c111() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c112() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c113() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c114() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c115() -> {Codec.encoding_for_legal_type(G.bitvector_17(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c116() -> {Codec.encoding_for_legal_type(G.bitvector_2(), T.BitsValue{[False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c117() -> {Codec.encoding_for_legal_type(G.bitvector_2(), T.BitsValue{[False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c118() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c119() -> {Codec.encoding_for_legal_type(G.bitvector_3(), T.BitsValue{[False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c120() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c121() -> {Codec.encoding_for_legal_type(G.bitvector_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c122() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c123() -> {Codec.encoding_for_legal_type(G.bitvector_32(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}
