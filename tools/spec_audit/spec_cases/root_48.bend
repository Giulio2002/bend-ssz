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

def c96() -> {Limits.at_depth(3n, 2n, [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]) == Some{[41, 121, 126, 222, 208, 232, 51, 118, 183, 15, 43, 240, 52, 204, 8, 17, 174, 127, 20, 20, 101, 59, 29, 114, 13, 253, 24, 247, 76, 241, 51, 9]} : Maybe<&2, +List<U32>>}:
  {==}

def c97() -> {Limits.at_depth(3n, 2n, [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]]) == Some{[149, 177, 210, 191, 103, 145, 209, 248, 128, 62, 245, 169, 225, 224, 33, 116, 68, 107, 249, 242, 102, 177, 24, 79, 116, 46, 29, 81, 48, 178, 212, 144]} : Maybe<&2, +List<U32>>}:
  {==}
