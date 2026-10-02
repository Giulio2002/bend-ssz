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

def c368() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[229, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c369() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 0, 0, 0, 2]} : Maybe<&2, +List<U32>>}:
  {==}

def c370() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}]}) == Some{[255, 12]} : Maybe<&2, +List<U32>>}:
  {==}

def c371() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}]}) == Some{[255, 88]} : Maybe<&2, +List<U32>>}:
  {==}

def c372() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[0, 3]} : Maybe<&2, +List<U32>>}:
  {==}

def c373() -> {Codec.encoding_for_legal_type(G.bitlist_33(), T.BitsValue{[True{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}]}) == Some{[155, 234]} : Maybe<&2, +List<U32>>}:
  {==}

def c374() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[False{}, True{}, True{}, False{}]}) == Some{[22]} : Maybe<&2, +List<U32>>}:
  {==}

def c375() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[False{}, False{}, False{}, False{}]}) == Some{[16]} : Maybe<&2, +List<U32>>}:
  {==}

def c376() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[False{}, False{}, False{}]}) == Some{[8]} : Maybe<&2, +List<U32>>}:
  {==}

def c377() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[False{}]}) == Some{[2]} : Maybe<&2, +List<U32>>}:
  {==}

def c378() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[True{}, False{}]}) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c379() -> {Codec.encoding_for_legal_type(G.bitlist_4(), T.BitsValue{[True{}, True{}, True{}, False{}]}) == Some{[23]} : Maybe<&2, +List<U32>>}:
  {==}
