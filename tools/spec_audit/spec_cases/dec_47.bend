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

def c724() -> {Prim.uint_decoding(P.U128{}, [0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 65280, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c725() -> {Prim.uint_decoding(P.U128{}, [255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4286644223, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c726() -> {Prim.uint_decoding(P.U128{}, [242, 15, 95, 20, 39, 170, 53, 158, 0, 179, 19, 12, 0, 23, 201, 223]) == Some{P.UInt{341774322, 2654317095, 202617600, 3754497792, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c727() -> {Prim.uint_decoding(P.U128{}, [242, 15, 95, 20, 39, 170, 53, 158, 31, 179, 19, 12, 0, 23, 201, 1]) == Some{P.UInt{341774322, 2654317095, 202617631, 29955840, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c728() -> {Prim.uint_decoding(P.U128{}, [0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{32768, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c729() -> {Prim.uint_decoding(P.U128{}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0]) == Some{P.UInt{0, 0, 0, 32768, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c730() -> {Prim.uint_decoding(P.U128{}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 0, 32768, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c731() -> {Prim.uint_decoding(P.U128{}, [0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c732() -> {Prim.uint_decoding(P.U128{}, [0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 8388608, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c733() -> {Prim.uint_decoding(P.U128{}, [255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{16777215, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c734() -> {Prim.uint_decoding(P.U16{}, [253, 76]) == Some{P.UInt{19709, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c735() -> {Prim.uint_decoding(P.U16{}, [0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c736() -> {Prim.uint_decoding(P.U16{}, [0, 76]) == Some{P.UInt{19456, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c737() -> {Prim.uint_decoding(P.U16{}, [255, 0]) == Some{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c738() -> {Prim.uint_decoding(P.U16{}, [253, 128]) == Some{P.UInt{33021, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c739() -> {Prim.uint_decoding(P.U16{}, [253]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c740() -> {Prim.uint_decoding(P.U16{}, [1, 255]) == Some{P.UInt{65281, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c741() -> {Prim.uint_decoding(P.U16{}, []) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c742() -> {Prim.uint_decoding(P.U16{}, [0, 255, 255]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c743() -> {Prim.uint_decoding(P.U16{}, [0, 128]) == Some{P.UInt{32768, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c744() -> {Prim.uint_decoding(P.U256{}, [104, 249, 239, 155, 230, 227, 222, 34, 97, 126, 198, 253, 88, 70, 157, 127, 161, 155, 168, 237, 201, 192, 245, 149, 59, 33, 25, 248, 108, 245, 55, 0]) == Some{P.UInt{2616195432, 585032678, 4257644129, 2141013592, 3987250081, 2515910857, 4162396475, 3667308}} : Maybe<&2, P.UInt>}:
  {==}

def c745() -> {Prim.uint_decoding(P.U256{}, [0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c746() -> {Prim.uint_decoding(P.U256{}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 0, 0, 0, 0, 65536, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c747() -> {Prim.uint_decoding(P.U256{}, [104, 249, 239, 155, 230, 227, 222, 34, 97, 126, 198, 253, 88, 70, 157, 127, 161, 155, 128, 237, 201, 192, 245, 149, 59, 33, 25, 248, 108, 245, 55, 93]) == Some{P.UInt{2616195432, 585032678, 4257644129, 2141013592, 3984628641, 2515910857, 4162396475, 1563948396}} : Maybe<&2, P.UInt>}:
  {==}

def c748() -> {Prim.uint_decoding(P.U256{}, [255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967295, 4294967294, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}} : Maybe<&2, P.UInt>}:
  {==}
