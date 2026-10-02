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

def c14() -> {ByteList.at_depth(33n, 1n, [1]) == Some{[144, 94, 251, 81, 194, 118, 76, 44, 122, 78, 251, 5, 72, 227, 114, 86, 157, 240, 109, 184, 33, 21, 195, 177, 137, 108, 24, 102, 50, 243, 254, 91]} : Maybe<&2, +List<U32>>}:
  {==}

def c15() -> {ByteList.at_depth(33n, 1n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75, 86]) == Some{[119, 123, 11, 0, 164, 193, 210, 252, 148, 161, 13, 132, 102, 102, 74, 35, 53, 10, 204, 14, 208, 224, 152, 136, 127, 169, 32, 26, 92, 197, 69, 149]} : Maybe<&2, +List<U32>>}:
  {==}
