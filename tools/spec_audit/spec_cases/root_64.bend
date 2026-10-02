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

def c128() -> {Mix.mix_in_selector([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31], 1) == Some{[233, 135, 180, 43, 213, 1, 35, 254, 119, 100, 235, 174, 79, 65, 85, 190, 235, 217, 155, 158, 222, 38, 19, 166, 50, 72, 74, 160, 144, 226, 112, 223]} : Maybe<&2, +List<U32>>}:
  {==}

def c129() -> {Mix.mix_in_selector([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31], 127) == Some{[192, 6, 92, 115, 220, 191, 184, 2, 51, 49, 234, 110, 57, 14, 130, 43, 223, 154, 71, 120, 52, 123, 247, 98, 60, 178, 36, 239, 97, 170, 253, 70]} : Maybe<&2, +List<U32>>}:
  {==}
