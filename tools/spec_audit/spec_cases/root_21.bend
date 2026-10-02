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

def c42() -> {BitRoot.bitlist_at_depth(256n, 0n, [False{}]) == Some{[203, 89, 40, 68, 18, 29, 146, 111, 28, 163, 173, 78, 29, 111, 185, 216, 226, 96, 237, 110, 50, 22, 54, 31, 119, 50, 233, 117, 160, 232, 187, 246]} : Maybe<&2, +List<U32>>}:
  {==}

def c43() -> {BitRoot.bitlist_at_depth(256n, 0n, [False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}]) == Some{[5, 231, 48, 14, 149, 219, 223, 69, 226, 55, 45, 243, 151, 168, 12, 20, 196, 137, 11, 177, 58, 0, 65, 158, 46, 136, 146, 18, 47, 92, 109, 132]} : Maybe<&2, +List<U32>>}:
  {==}
