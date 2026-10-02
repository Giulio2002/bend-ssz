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

def c83() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c84() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c85() -> {Codec.encoding_for_legal_type(G.bitlist_17(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 255, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c86() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c87() -> {Codec.encoding_for_legal_type(G.bitlist_2(), T.BitsValue{[True{}, True{}]}) == Some{[7]} : Maybe<&2, +List<U32>>}:
  {==}

def c88() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c89() -> {Codec.encoding_for_legal_type(G.bitlist_3(), T.BitsValue{[True{}, True{}, True{}]}) == Some{[15]} : Maybe<&2, +List<U32>>}:
  {==}

def c90() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c91() -> {Codec.encoding_for_legal_type(G.bitlist_31(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c92() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c93() -> {Codec.encoding_for_legal_type(G.bitlist_32(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 255, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c94() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c95() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 255, 255, 255, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c96() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c97() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[True{}, True{}, True{}, True{}]}) == Some{[31]} : Maybe<&2, +List<U32>>}:
  {==}

def c98() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c99() -> {Codec.encoding_for_legal_type(G.bitlist_5(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}]}) == Some{[63]} : Maybe<&2, +List<U32>>}:
  {==}

def c100() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c101() -> {Codec.encoding_for_legal_type(G.bitlist_6(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[127]} : Maybe<&2, +List<U32>>}:
  {==}

def c102() -> {Codec.encoding_for_legal_type(G.bitlist_7(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}
