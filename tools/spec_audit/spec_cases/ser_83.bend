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

def c518() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}]}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c519() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}]}) == Some{[31]} : Maybe<&2, +List<U32>>}:
  {==}

def c520() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[False{}, True{}, True{}, True{}, True{}]}) == Some{[30]} : Maybe<&2, +List<U32>>}:
  {==}

def c521() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[True{}, True{}, True{}, False{}, True{}]}) == Some{[23]} : Maybe<&2, +List<U32>>}:
  {==}

def c522() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}]}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c523() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c524() -> {Codec.encoding_for_legal_type(G.bitvector_511(), T.BitsValue{[False{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}]}) == Some{[116, 122, 83, 222, 93, 110, 44, 204, 163, 195, 33, 187, 61, 195, 12, 181, 192, 169, 222, 73, 19, 0, 208, 38, 174, 122, 138, 92, 119, 72, 29, 66, 66, 49, 213, 66, 255, 63, 92, 156, 112, 117, 37, 45, 149, 197, 69, 50, 168, 104, 47, 8, 18, 115, 226, 25, 69, 74, 130, 201, 167, 102, 170, 100]} : Maybe<&2, +List<U32>>}:
  {==}
