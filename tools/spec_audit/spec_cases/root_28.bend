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

def c56() -> {BitRoot.bitlist_at_depth(513n, 2n, []) == Some{[40, 186, 24, 52, 163, 167, 182, 87, 70, 12, 231, 159, 163, 161, 217, 9, 171, 136, 40, 253, 85, 118, 89, 212, 208, 85, 74, 155, 219, 192, 236, 48]} : Maybe<&2, +List<U32>>}:
  {==}

def c57() -> {BitRoot.bitlist_at_depth(513n, 2n, [False{}]) == Some{[165, 231, 58, 116, 216, 68, 205, 63, 131, 169, 183, 111, 77, 159, 250, 191, 65, 200, 192, 110, 204, 145, 223, 103, 245, 48, 203, 200, 241, 253, 207, 168]} : Maybe<&2, +List<U32>>}:
  {==}
