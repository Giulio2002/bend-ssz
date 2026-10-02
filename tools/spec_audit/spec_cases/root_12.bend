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

def c24() -> {ByteList.at_depth(65n, 2n, [1]) == Some{[118, 249, 67, 155, 38, 54, 121, 117, 187, 151, 161, 1, 14, 244, 48, 151, 137, 209, 129, 74, 246, 52, 2, 162, 115, 185, 219, 105, 45, 200, 159, 72]} : Maybe<&2, +List<U32>>}:
  {==}

def c25() -> {ByteList.at_depth(65n, 2n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75, 86, 97, 108, 119, 130, 141, 152, 163, 174, 185, 196, 207, 218, 229, 240, 251, 6, 17, 28, 39, 50, 61, 72, 83, 94, 105, 116, 127, 138, 149, 160, 171, 182]) == Some{[209, 125, 190, 87, 199, 153, 14, 33, 37, 156, 226, 176, 26, 198, 28, 153, 107, 61, 233, 33, 152, 121, 130, 171, 42, 141, 197, 18, 232, 194, 45, 185]} : Maybe<&2, +List<U32>>}:
  {==}
