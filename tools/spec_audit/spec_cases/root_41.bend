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

def c82() -> {ByteRoot.at_depth(33n, 1n, [2, 15, 28, 41, 54, 67, 80, 93, 106, 119, 132, 145, 158, 171, 184, 197, 210, 223, 236, 249, 6, 19, 32, 45, 58, 71, 84, 97, 110, 123, 136, 149, 162]) == Some{[175, 214, 187, 196, 201, 202, 197, 191, 8, 19, 166, 114, 10, 156, 33, 140, 241, 1, 88, 124, 240, 254, 24, 193, 82, 178, 216, 51, 151, 178, 131, 187]} : Maybe<&2, +List<U32>>}:
  {==}

def c83() -> {ByteRoot.at_depth(48n, 1n, [2, 15, 28, 41, 54, 67, 80, 93, 106, 119, 132, 145, 158, 171, 184, 197, 210, 223, 236, 249, 6, 19, 32, 45, 58, 71, 84, 97, 110, 123, 136, 149, 162, 175, 188, 201, 214, 227, 240, 253, 10, 23, 36, 49, 62, 75, 88, 101]) == Some{[171, 240, 121, 248, 23, 216, 237, 95, 186, 4, 52, 195, 205, 93, 207, 83, 96, 82, 8, 234, 229, 21, 152, 81, 153, 76, 119, 45, 225, 172, 49, 249]} : Maybe<&2, +List<U32>>}:
  {==}
