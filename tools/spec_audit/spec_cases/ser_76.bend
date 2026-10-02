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

def c454() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[True{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[49, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c455() -> {Codec.encoding_for_legal_type(G.bitvector_15(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c456() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}]}) == Some{[4, 30]} : Maybe<&2, +List<U32>>}:
  {==}

def c457() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[39, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c458() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c459() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[5, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c460() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}]}) == Some{[5, 30]} : Maybe<&2, +List<U32>>}:
  {==}

def c461() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[254, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c462() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[133, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c463() -> {Codec.encoding_for_legal_type(G.bitvector_16(), T.BitsValue{[True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[39, 255]} : Maybe<&2, +List<U32>>}:
  {==}
