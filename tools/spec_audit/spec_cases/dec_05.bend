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

def c95() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 1, 0, 0, 0, 0]) == Some{P.UInt{16777217, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c96() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0, 1]) == Some{P.UInt{0, 16777216, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c97() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 0, 0, 0, 128, 0]) == Some{P.UInt{1, 8388608, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c98() -> {Prim.uint_decoding(P.U64{}, [0, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967040, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c99() -> {Prim.uint_decoding(P.U64{}, [255, 255, 1, 255, 255, 255, 255, 255]) == Some{P.UInt{4278321151, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c100() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0, 255]) == Some{P.UInt{0, 4278190080, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c101() -> {Prim.uint_decoding(P.U64{}, [255, 0, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294902015, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c102() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 128, 0, 0, 0]) == Some{P.UInt{0, 128, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c103() -> {Prim.uint_decoding(P.U64{}, [0, 255, 255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c104() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 1, 0, 0, 0, 0]) == Some{P.UInt{16777216, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c105() -> {Prim.uint_decoding(P.U64{}, [0, 1, 0, 0, 0, 0, 0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c106() -> {Prim.uint_decoding(P.U64{}, [1, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967041, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c107() -> {Prim.uint_decoding(P.U64{}, [0, 0, 1, 0, 0, 0, 0, 0]) == Some{P.UInt{65536, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c108() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c109() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c110() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 128, 0, 0, 0]) == Some{P.UInt{0, 128, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c111() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 1, 255, 255, 255, 255]) == Some{P.UInt{33554431, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c112() -> {Prim.uint_decoding(P.U64{}, [128, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967168, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c113() -> {Prim.uint_decoding(P.U64{}, [70, 103, 189, 1, 0, 69, 2, 249]) == Some{P.UInt{29189958, 4177675520, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c114() -> {Prim.uint_decoding(P.U64{}, [0, 0, 128, 0, 0, 0, 0, 0]) == Some{P.UInt{8388608, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c115() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 255, 0]) == Some{P.UInt{0, 16711680, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c116() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c117() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 1, 0]) == Some{P.UInt{0, 65536, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c118() -> {Prim.uint_decoding(P.U64{}, [128, 103, 189, 1, 28, 69, 2, 249]) == Some{P.UInt{29190016, 4177675548, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c119() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255, 255, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}
