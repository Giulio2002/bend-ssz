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

def c84() -> {ByteRoot.at_depth(64n, 1n, [2, 15, 28, 41, 54, 67, 80, 93, 106, 119, 132, 145, 158, 171, 184, 197, 210, 223, 236, 249, 6, 19, 32, 45, 58, 71, 84, 97, 110, 123, 136, 149, 162, 175, 188, 201, 214, 227, 240, 253, 10, 23, 36, 49, 62, 75, 88, 101, 114, 127, 140, 153, 166, 179, 192, 205, 218, 231, 244, 1, 14, 27, 40, 53]) == Some{[91, 151, 181, 196, 163, 95, 154, 195, 25, 189, 121, 60, 71, 245, 248, 33, 111, 94, 42, 223, 45, 215, 217, 41, 26, 40, 188, 131, 149, 76, 199, 44]} : Maybe<&2, +List<U32>>}:
  {==}

def c85() -> {ByteRoot.at_depth(65n, 2n, [2, 15, 28, 41, 54, 67, 80, 93, 106, 119, 132, 145, 158, 171, 184, 197, 210, 223, 236, 249, 6, 19, 32, 45, 58, 71, 84, 97, 110, 123, 136, 149, 162, 175, 188, 201, 214, 227, 240, 253, 10, 23, 36, 49, 62, 75, 88, 101, 114, 127, 140, 153, 166, 179, 192, 205, 218, 231, 244, 1, 14, 27, 40, 53, 66]) == Some{[133, 155, 121, 182, 52, 51, 121, 135, 56, 130, 189, 68, 34, 155, 86, 94, 178, 209, 34, 64, 15, 7, 119, 95, 128, 118, 22, 248, 41, 75, 118, 147]} : Maybe<&2, +List<U32>>}:
  {==}
