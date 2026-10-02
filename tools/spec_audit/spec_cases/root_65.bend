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

def c130() -> {Mix.mix_in_selector([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31], 128) == Some{[77, 171, 109, 59, 197, 26, 6, 79, 173, 93, 23, 197, 155, 47, 147, 147, 165, 89, 80, 244, 105, 209, 181, 253, 230, 210, 128, 230, 16, 101, 197, 183]} : Maybe<&2, +List<U32>>}:
  {==}

def c131() -> {Mix.mix_in_selector([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31], 255) == Some{[105, 203, 106, 17, 31, 86, 0, 131, 236, 44, 222, 43, 56, 251, 233, 74, 209, 202, 123, 247, 115, 153, 0, 148, 161, 58, 47, 205, 180, 219, 162, 225]} : Maybe<&2, +List<U32>>}:
  {==}
