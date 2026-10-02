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

def c16() -> {ByteList.at_depth(33n, 1n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75, 86, 97]) == Some{[37, 189, 226, 140, 47, 74, 143, 90, 242, 21, 138, 211, 208, 6, 192, 184, 105, 244, 91, 192, 24, 228, 114, 29, 67, 220, 53, 174, 183, 72, 30, 195]} : Maybe<&2, +List<U32>>}:
  {==}

def c17() -> {ByteList.at_depth(33n, 1n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75, 86, 97, 108]) == None{} : Maybe<&2, +List<U32>>}:
  {==}
