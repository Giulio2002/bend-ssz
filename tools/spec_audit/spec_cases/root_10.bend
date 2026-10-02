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

def c20() -> {ByteList.at_depth(64n, 1n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75, 86, 97, 108, 119, 130, 141, 152, 163, 174, 185, 196, 207, 218, 229, 240, 251, 6, 17, 28, 39, 50, 61, 72, 83, 94, 105, 116, 127, 138, 149, 160, 171]) == Some{[156, 212, 248, 106, 40, 228, 22, 69, 10, 203, 80, 206, 217, 254, 47, 236, 184, 109, 153, 103, 103, 132, 81, 156, 89, 6, 229, 67, 171, 155, 125, 137]} : Maybe<&2, +List<U32>>}:
  {==}

def c21() -> {ByteList.at_depth(64n, 1n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75, 86, 97, 108, 119, 130, 141, 152, 163, 174, 185, 196, 207, 218, 229, 240, 251, 6, 17, 28, 39, 50, 61, 72, 83, 94, 105, 116, 127, 138, 149, 160, 171, 182]) == Some{[172, 38, 253, 209, 71, 28, 14, 224, 241, 140, 16, 36, 53, 66, 21, 147, 0, 185, 103, 244, 181, 97, 219, 149, 180, 198, 151, 95, 90, 23, 92, 43]} : Maybe<&2, +List<U32>>}:
  {==}
