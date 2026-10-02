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

def c92() -> {Limits.at_depth(2n, 1n, [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]) == Some{[3, 125, 109, 251, 58, 54, 154, 65, 224, 17, 0, 253, 213, 60, 53, 238, 63, 182, 157, 222, 197, 131, 13, 97, 225, 19, 141, 6, 106, 76, 34, 133]} : Maybe<&2, +List<U32>>}:
  {==}

def c93() -> {Limits.at_depth(2n, 1n, [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]]) == Some{[248, 24, 175, 211, 122, 109, 195, 188, 146, 251, 68, 115, 16, 17, 39, 112, 6, 219, 78, 250, 110, 144, 35, 205, 116, 104, 192, 35, 53, 210, 42, 77]} : Maybe<&2, +List<U32>>}:
  {==}
