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

def c28() -> {BitRoot.bitlist_at_depth(1n, 0n, []) == Some{[245, 165, 253, 66, 209, 106, 32, 48, 39, 152, 239, 110, 211, 9, 151, 155, 67, 0, 61, 35, 32, 217, 240, 232, 234, 152, 49, 169, 39, 89, 251, 75]} : Maybe<&2, +List<U32>>}:
  {==}

def c29() -> {BitRoot.bitlist_at_depth(1n, 0n, [False{}]) == Some{[203, 89, 40, 68, 18, 29, 146, 111, 28, 163, 173, 78, 29, 111, 185, 216, 226, 96, 237, 110, 50, 22, 54, 31, 119, 50, 233, 117, 160, 232, 187, 246]} : Maybe<&2, +List<U32>>}:
  {==}
