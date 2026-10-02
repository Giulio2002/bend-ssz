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

def c124() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c125() -> {Codec.encoding_for_legal_type(G.bitvector_33(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c126() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c127() -> {Codec.encoding_for_legal_type(G.bitvector_4(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c128() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c129() -> {Codec.encoding_for_legal_type(G.bitvector_5(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c130() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c131() -> {Codec.encoding_for_legal_type(G.bitvector_6(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c132() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c133() -> {Codec.encoding_for_legal_type(G.bitvector_7(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c134() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c135() -> {Codec.encoding_for_legal_type(G.bitvector_8(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c136() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c137() -> {Codec.encoding_for_legal_type(G.bitvector_9(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c138() -> {Codec.encoding_for_legal_type(G.uint128(), T.UnsignedValue{P.UInt{0, 0, 0, 0, 1, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c139() -> {Codec.encoding_for_legal_type(G.uint128(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c140() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{65536, 0, 0, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c141() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c142() -> {Codec.encoding_for_legal_type(F.uint32(), T.UnsignedValue{P.UInt{0, 1, 0, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c143() -> {Codec.encoding_for_legal_type(F.uint32(), T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c144() -> {Codec.encoding_for_legal_type(F.uint64(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c145() -> {Codec.encoding_for_legal_type(F.uint64(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c146() -> {Codec.encoding_for_legal_type(F.uint8(), T.UnsignedValue{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c147() -> {Codec.encoding_for_legal_type(F.uint8(), T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c148() -> {Codec.encoding_for_legal_type(G.vec_bool_1(), T.Sequence{T.EmptyItems{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}
