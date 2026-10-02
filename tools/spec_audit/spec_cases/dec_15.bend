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

def c289() -> {Prim.uint_decoding(P.U64{}, [207, 190, 174, 158, 169, 128, 196, 148]) == Some{P.UInt{2662252239, 2495905961, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c290() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 0, 255, 255, 255]) == Some{P.UInt{4294967295, 4294967040, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c291() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 0, 255]) == Some{P.UInt{4294967295, 4278255615, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c292() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 1, 0, 0, 0, 0]) == Some{P.UInt{16777216, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c293() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 128, 0, 0]) == Some{P.UInt{0, 32768, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c294() -> {Prim.uint_decoding(P.U64{}, [255, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c295() -> {Prim.uint_decoding(P.U64{}, [255, 128, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294934783, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c296() -> {Prim.uint_decoding(P.U64{}, [18, 198, 178, 32, 245, 25, 4, 68]) == Some{P.UInt{548587026, 1141119477, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c297() -> {Prim.uint_decoding(P.U64{}, [19, 198, 178, 32, 245, 25, 1, 68]) == Some{P.UInt{548587027, 1140922869, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c298() -> {Prim.uint_decoding(P.U64{}, [19, 198, 178, 32, 245, 128, 4, 68]) == Some{P.UInt{548587027, 1141145845, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c299() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 1, 0, 0]) == Some{P.UInt{0, 256, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c300() -> {Prim.uint_decoding(P.U64{}, [19, 199, 178, 32, 245, 25, 4, 68]) == Some{P.UInt{548587283, 1141119477, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c301() -> {Prim.uint_decoding(P.U64{}, [19, 198, 178, 32, 245, 25, 5, 68]) == Some{P.UInt{548587027, 1141185013, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c302() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 255, 0, 0, 0]) == Some{P.UInt{0, 255, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c303() -> {Prim.uint_decoding(P.U64{}, [19, 198, 178, 32]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c304() -> {Prim.uint_decoding(P.U64{}, [255, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c305() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 0, 0, 0, 0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c306() -> {Prim.uint_decoding(P.U64{}, [0, 1, 0, 0, 0, 0, 0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c307() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255, 255, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c308() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 128, 0, 0, 0, 0]) == Some{P.UInt{2147483649, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c309() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 254, 255, 255, 255, 255]) == Some{P.UInt{4278190079, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c310() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c311() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c312() -> {Prim.uint_decoding(P.U64{}, [128, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c313() -> {Prim.uint_decoding(P.U64{}, [128, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967168, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}
