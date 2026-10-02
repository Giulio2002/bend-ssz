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

def c100() -> {Limits.at_depth(4n, 2n, []) == Some{[219, 86, 17, 78, 0, 253, 212, 193, 248, 92, 137, 43, 243, 90, 201, 168, 146, 137, 170, 236, 177, 235, 208, 169, 108, 222, 96, 106, 116, 139, 93, 113]} : Maybe<&2, +List<U32>>}:
  {==}

def c101() -> {Limits.at_depth(4n, 2n, [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]) == Some{[41, 121, 126, 222, 208, 232, 51, 118, 183, 15, 43, 240, 52, 204, 8, 17, 174, 127, 20, 20, 101, 59, 29, 114, 13, 253, 24, 247, 76, 241, 51, 9]} : Maybe<&2, +List<U32>>}:
  {==}
