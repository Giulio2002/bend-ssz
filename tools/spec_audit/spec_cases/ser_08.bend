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

def c34() -> {Codec.encoding_for_legal_type(F.Bytes20(), T.BytesValue{[88, 70, 238, 138, 61, 126, 219, 180, 93, 237, 190, 31, 254, 236, 213, 46, 189, 0, 99, 198]}) == Some{[88, 70, 238, 138, 61, 126, 219, 180, 93, 237, 190, 31, 254, 236, 213, 46, 189, 0, 99, 198]} : Maybe<&2, +List<U32>>}:
  {==}

def c35() -> {Codec.encoding_for_legal_type(F.Bytes32(), T.BytesValue{[150, 128, 100, 65, 124, 145, 170, 36, 81, 168, 221, 114, 86, 14, 208, 121, 131, 28, 69, 240, 90, 20, 188, 170, 27, 8, 168, 28, 12, 155, 75, 34]}) == Some{[150, 128, 100, 65, 124, 145, 170, 36, 81, 168, 221, 114, 86, 14, 208, 121, 131, 28, 69, 240, 90, 20, 188, 170, 27, 8, 168, 28, 12, 155, 75, 34]} : Maybe<&2, +List<U32>>}:
  {==}

def c36() -> {Codec.encoding_for_legal_type(F.Bytes32(), T.BytesValue{[150, 182, 100, 65, 124, 145, 170, 36, 81, 168, 221, 114, 86, 14, 208, 121, 131, 28, 69, 240, 90, 20, 188, 170, 27, 8, 168, 255, 12, 155, 75, 34]}) == Some{[150, 182, 100, 65, 124, 145, 170, 36, 81, 168, 221, 114, 86, 14, 208, 121, 131, 28, 69, 240, 90, 20, 188, 170, 27, 8, 168, 255, 12, 155, 75, 34]} : Maybe<&2, +List<U32>>}:
  {==}

def c37() -> {Codec.encoding_for_legal_type(F.Bytes32(), T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255]}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c38() -> {Codec.encoding_for_legal_type(F.Bytes4(), T.BytesValue{[255, 255, 255, 254]}) == Some{[255, 255, 255, 254]} : Maybe<&2, +List<U32>>}:
  {==}

def c39() -> {Codec.encoding_for_legal_type(F.Bytes4(), T.BytesValue{[255, 1, 255, 255]}) == Some{[255, 1, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c40() -> {Codec.encoding_for_legal_type(F.Bytes4(), T.BytesValue{[196, 0, 111, 9]}) == Some{[196, 0, 111, 9]} : Maybe<&2, +List<U32>>}:
  {==}

def c41() -> {Codec.encoding_for_legal_type(F.Bytes48(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c42() -> {Codec.encoding_for_legal_type(F.Bytes48(), T.BytesValue{[55, 35, 29, 234, 173, 15, 174, 77, 8, 150, 142, 130, 240, 7, 245, 230, 248, 54, 94, 30, 143, 143, 205, 48, 4, 40, 253, 92, 226, 41, 79, 191, 37, 159, 50, 163, 26, 230, 183, 11, 10, 177, 145, 234, 46, 22, 20, 242]}) == Some{[55, 35, 29, 234, 173, 15, 174, 77, 8, 150, 142, 130, 240, 7, 245, 230, 248, 54, 94, 30, 143, 143, 205, 48, 4, 40, 253, 92, 226, 41, 79, 191, 37, 159, 50, 163, 26, 230, 183, 11, 10, 177, 145, 234, 46, 22, 20, 242]} : Maybe<&2, +List<U32>>}:
  {==}
