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

def c774() -> {Prim.uint_decoding(P.U8{}, [255]) == Some{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c775() -> {Prim.uint_decoding(P.U8{}, [0]) == Some{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c776() -> {Prim.uint_decoding(P.U8{}, [255, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c777() -> {Prim.uint_decoding(P.U8{}, [1]) == Some{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c778() -> {Prim.uint_decoding(P.U8{}, [0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c779() -> {Prim.uint_decoding(P.U8{}, [255, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c780() -> {Prim.uint_decoding(P.U8{}, [129]) == Some{P.UInt{129, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c781() -> {Prim.uint_decoding(P.U8{}, [128]) == Some{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c782() -> {Prim.uint_decoding(P.U8{}, [0, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c783() -> {Prim.uint_decoding(P.U8{}, [129, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c784() -> {Bytes.vector_decoding(1n, [255]) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c785() -> {Bytes.vector_decoding(1n, [0, 255]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c786() -> {Bytes.vector_decoding(1n, [194]) == Some{[194]} : Maybe<&2, +List<U32>>}:
  {==}

def c787() -> {Bytes.vector_decoding(1n, [1]) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c788() -> {Bytes.vector_decoding(1n, []) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c789() -> {Bytes.vector_decoding(1n, [0]) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c790() -> {Bytes.vector_decoding(1n, [0, 41]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c791() -> {Bytes.vector_decoding(1n, [182, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c792() -> {Bytes.vector_decoding(1n, [0, 195]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c793() -> {Bytes.vector_decoding(1n, [195]) == Some{[195]} : Maybe<&2, +List<U32>>}:
  {==}

def c794() -> {Bytes.vector_decoding(16n, [118, 127, 2, 175, 213, 242, 11, 109, 124, 241, 42, 234, 63, 196, 139, 99]) == Some{[118, 127, 2, 175, 213, 242, 11, 109, 124, 241, 42, 234, 63, 196, 139, 99]} : Maybe<&2, +List<U32>>}:
  {==}

def c795() -> {Bytes.vector_decoding(16n, [107, 167, 159, 48, 25, 106, 19, 199, 242, 219, 125, 74, 15, 18, 200, 61, 1]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c796() -> {Bytes.vector_decoding(16n, [0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{[0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c797() -> {Bytes.vector_decoding(16n, [0, 107, 167, 159, 48, 25, 106, 19, 199, 242, 219, 125, 74, 15, 18, 200, 61]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c798() -> {Bytes.vector_decoding(16n, [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}
