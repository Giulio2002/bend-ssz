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

def c46() -> {BitRoot.bitlist_at_depth(257n, 1n, []) == Some{[122, 5, 1, 245, 149, 123, 223, 156, 179, 168, 255, 73, 102, 240, 34, 101, 249, 104, 101, 139, 122, 156, 98, 100, 44, 186, 17, 101, 232, 102, 66, 245]} : Maybe<&2, +List<U32>>}:
  {==}

def c47() -> {BitRoot.bitlist_at_depth(257n, 1n, [False{}]) == Some{[232, 50, 210, 99, 170, 168, 249, 65, 125, 159, 69, 167, 2, 131, 79, 105, 97, 238, 123, 21, 173, 77, 61, 39, 242, 176, 244, 254, 121, 211, 48, 49]} : Maybe<&2, +List<U32>>}:
  {==}
