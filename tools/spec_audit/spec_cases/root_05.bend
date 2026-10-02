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

def c10() -> {ByteList.at_depth(32n, 0n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75]) == Some{[133, 224, 1, 87, 255, 157, 214, 228, 49, 196, 5, 228, 94, 201, 133, 148, 226, 84, 57, 214, 193, 14, 58, 161, 211, 150, 135, 98, 206, 2, 187, 221]} : Maybe<&2, +List<U32>>}:
  {==}

def c11() -> {ByteList.at_depth(32n, 0n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75, 86]) == Some{[39, 190, 226, 188, 12, 133, 176, 181, 182, 195, 81, 195, 56, 125, 224, 131, 229, 220, 239, 199, 63, 128, 69, 41, 8, 177, 84, 190, 105, 254, 85, 190]} : Maybe<&2, +List<U32>>}:
  {==}
