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

def c749() -> {Prim.uint_decoding(P.U256{}, [104, 249, 239, 155, 0, 227, 222, 34, 97, 126, 198, 253, 88, 70, 157, 127, 161, 155, 168, 237, 201, 192, 245, 149, 59, 33, 25, 248, 108, 245, 55, 93]) == Some{P.UInt{2616195432, 585032448, 4257644129, 2141013592, 3987250081, 2515910857, 4162396475, 1563948396}} : Maybe<&2, P.UInt>}:
  {==}

def c750() -> {Prim.uint_decoding(P.U256{}, [0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 255, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c751() -> {Prim.uint_decoding(P.U256{}, [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c752() -> {Prim.uint_decoding(P.U256{}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 0, 16777216, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c753() -> {Prim.uint_decoding(P.U256{}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 0, 4278190080, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c754() -> {Prim.uint_decoding(P.U32Width{}, [255, 255, 254, 255]) == Some{P.UInt{4294901759, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c755() -> {Prim.uint_decoding(P.U32Width{}, [1, 0, 0, 0, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c756() -> {Prim.uint_decoding(P.U32Width{}, [0, 0, 1, 0]) == Some{P.UInt{65536, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c757() -> {Prim.uint_decoding(P.U32Width{}, [255, 0, 255, 255]) == Some{P.UInt{4294902015, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c758() -> {Prim.uint_decoding(P.U32Width{}, [1, 255, 0, 0]) == Some{P.UInt{65281, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c759() -> {Prim.uint_decoding(P.U32Width{}, [255, 255, 1, 255]) == Some{P.UInt{4278321151, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c760() -> {Prim.uint_decoding(P.U32Width{}, [0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c761() -> {Prim.uint_decoding(P.U32Width{}, [1, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c762() -> {Prim.uint_decoding(P.U32Width{}, [0, 1, 0, 0]) == Some{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c763() -> {Prim.uint_decoding(P.U32Width{}, [1, 1, 1, 1, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c764() -> {Prim.uint_decoding(P.U64{}, [128, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967168, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c765() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0, 128]) == Some{P.UInt{0, 2147483648, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c766() -> {Prim.uint_decoding(P.U64{}, [255, 0, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294902015, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c767() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 128, 0]) == Some{P.UInt{0, 8388608, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c768() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255, 255, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c769() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c770() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 254, 255, 255, 255, 255]) == Some{P.UInt{4278190079, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c771() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 128, 255, 255, 255, 255]) == Some{P.UInt{2164260863, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c772() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 1, 255, 255, 255, 255]) == Some{P.UInt{33554431, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c773() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 1, 0]) == Some{P.UInt{0, 65536, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}
