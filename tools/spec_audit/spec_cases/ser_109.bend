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

def c572() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[254, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c573() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}]}) == Some{[128, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c574() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}]}) == Some{[95, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c575() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]}) == Some{[1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c576() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]}) == Some{[128, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c577() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[3, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c578() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}]}) == Some{[95, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c579() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[False{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}]}) == Some{[94, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c580() -> {Codec.encoding_for_legal_type(F.boolean(), T.BooleanValue{True{}}) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c581() -> {Codec.encoding_for_legal_type(F.boolean(), T.BooleanValue{False{}}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c582() -> {Codec.encoding_for_legal_type(G.progbitlist(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == Some{[0, 4]} : Maybe<&2, +List<U32>>}:
  {==}

def c583() -> {Codec.encoding_for_legal_type(G.progbitlist(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}]}) == Some{[0, 7]} : Maybe<&2, +List<U32>>}:
  {==}
