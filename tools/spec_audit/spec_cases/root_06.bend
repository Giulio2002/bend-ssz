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

def c12() -> {ByteList.at_depth(32n, 0n, [1, 12, 23, 34, 45, 56, 67, 78, 89, 100, 111, 122, 133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 254, 9, 20, 31, 42, 53, 64, 75, 86, 97]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c13() -> {ByteList.at_depth(33n, 1n, []) == Some{[122, 5, 1, 245, 149, 123, 223, 156, 179, 168, 255, 73, 102, 240, 34, 101, 249, 104, 101, 139, 122, 156, 98, 100, 44, 186, 17, 101, 232, 102, 66, 245]} : Maybe<&2, +List<U32>>}:
  {==}
