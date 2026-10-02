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

def c4() -> {ByteList.at_depth(31n, 0n, [1]) == Some{[86, 216, 166, 111, 186, 224, 48, 14, 251, 167, 236, 44, 83, 25, 115, 170, 174, 34, 231, 162, 237, 109, 237, 8, 27, 91, 50, 208, 122, 50, 120, 10]} : Maybe<&2, +List<U32>>}:
  {==}

def c5() -> {ByteList.at_depth(31n, 0n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64]) == Some{[80, 177, 252, 31, 97, 216, 45, 114, 167, 5, 44, 64, 12, 13, 0, 116, 98, 97, 6, 216, 51, 157, 114, 203, 206, 140, 44, 30, 216, 69, 171, 249]} : Maybe<&2, +List<U32>>}:
  {==}
