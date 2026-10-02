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

def c80() -> {ByteRoot.at_depth(31n, 0n, [2, 15, 28, 41, 54, 67, 80, 93, 106, 119, 132, 145, 158, 171, 184, 197, 210, 223, 236, 249, 6, 19, 32, 45, 58, 71, 84, 97, 110, 123, 136]) == Some{[2, 15, 28, 41, 54, 67, 80, 93, 106, 119, 132, 145, 158, 171, 184, 197, 210, 223, 236, 249, 6, 19, 32, 45, 58, 71, 84, 97, 110, 123, 136, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c81() -> {ByteRoot.at_depth(32n, 0n, [2, 15, 28, 41, 54, 67, 80, 93, 106, 119, 132, 145, 158, 171, 184, 197, 210, 223, 236, 249, 6, 19, 32, 45, 58, 71, 84, 97, 110, 123, 136, 149]) == Some{[2, 15, 28, 41, 54, 67, 80, 93, 106, 119, 132, 145, 158, 171, 184, 197, 210, 223, 236, 249, 6, 19, 32, 45, 58, 71, 84, 97, 110, 123, 136, 149]} : Maybe<&2, +List<U32>>}:
  {==}
