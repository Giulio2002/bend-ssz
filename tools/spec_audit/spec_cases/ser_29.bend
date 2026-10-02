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

def c147() -> {Codec.encoding_for_legal_type(F.ForkData(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c148() -> {Codec.encoding_for_legal_type(F.ForkDigest(), T.BytesValue{[255, 254, 255, 255]}) == Some{[255, 254, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c149() -> {Codec.encoding_for_legal_type(F.ForkDigest(), T.BytesValue{[23, 121, 0, 255]}) == Some{[23, 121, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c150() -> {Codec.encoding_for_legal_type(F.ForkDigest(), T.BytesValue{[0, 0, 0, 1]}) == Some{[0, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c151() -> {Codec.encoding_for_legal_type(F.G1Point(), T.BytesValue{[90, 58, 74, 50, 42, 146, 38, 52, 234, 213, 164, 232, 170, 185, 100, 19, 26, 58, 55, 230, 26, 57, 187, 226, 206, 20, 81, 74, 41, 161, 120, 67, 19, 65, 137, 85, 168, 168, 54, 172, 241, 204, 58, 39, 253, 5, 17, 255]}) == Some{[90, 58, 74, 50, 42, 146, 38, 52, 234, 213, 164, 232, 170, 185, 100, 19, 26, 58, 55, 230, 26, 57, 187, 226, 206, 20, 81, 74, 41, 161, 120, 67, 19, 65, 137, 85, 168, 168, 54, 172, 241, 204, 58, 39, 253, 5, 17, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c152() -> {Codec.encoding_for_legal_type(F.G1Point(), T.BytesValue{[199, 89, 248, 223, 166, 233, 199, 60, 203, 37, 220, 203, 1, 141, 28, 46, 42, 161, 1, 193, 244, 255, 195, 164, 147, 134, 214, 20, 55, 138, 240, 55, 196, 86, 1, 173, 120, 43, 206, 78, 234, 173, 208, 110, 173, 35, 99, 85]}) == Some{[199, 89, 248, 223, 166, 233, 199, 60, 203, 37, 220, 203, 1, 141, 28, 46, 42, 161, 1, 193, 244, 255, 195, 164, 147, 134, 214, 20, 55, 138, 240, 55, 196, 86, 1, 173, 120, 43, 206, 78, 234, 173, 208, 110, 173, 35, 99, 85]} : Maybe<&2, +List<U32>>}:
  {==}

def c153() -> {Codec.encoding_for_legal_type(F.G1Point(), T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
