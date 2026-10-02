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

def c12() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 254, 255]) == Some{P.UInt{4294967295, 4294901759, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c13() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 255, 0, 0, 0, 0]) == Some{P.UInt{4278190080, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c14() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c15() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c16() -> {Prim.uint_decoding(P.U64{}, [0, 0, 255, 0, 0, 0, 0, 0]) == Some{P.UInt{16711680, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c17() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0, 1]) == Some{P.UInt{0, 16777216, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c18() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c19() -> {Prim.uint_decoding(P.U64{}, [255, 255, 1, 255, 255, 255, 255, 255]) == Some{P.UInt{4278321151, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c20() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 1, 0, 0, 0, 0]) == Some{P.UInt{16777217, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c21() -> {Bytes.vector_decoding(1n, [0, 212]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c22() -> {Bytes.vector_decoding(1n, [212, 1]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c23() -> {Bytes.vector_decoding(1n, [0, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c24() -> {Bytes.vector_decoding(1n, [1]) == Some{[1]} : Maybe<&2, +List<U32>>}:
  {==}

def c25() -> {Bytes.vector_decoding(1n, [153]) == Some{[153]} : Maybe<&2, +List<U32>>}:
  {==}

def c26() -> {Bytes.vector_decoding(1n, [153, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c27() -> {Bytes.vector_decoding(1n, [121]) == Some{[121]} : Maybe<&2, +List<U32>>}:
  {==}

def c28() -> {Bytes.vector_decoding(1n, [153, 1]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c29() -> {Bytes.vector_decoding(1n, [0, 120]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c30() -> {Bytes.vector_decoding(1n, [213]) == Some{[213]} : Maybe<&2, +List<U32>>}:
  {==}

def c31() -> {Bytes.vector_decoding(20n, [255, 223, 80, 153, 53, 188, 238, 143, 156, 142, 209, 7, 178, 111, 90, 49, 106, 237, 7, 237]) == Some{[255, 223, 80, 153, 53, 188, 238, 143, 156, 142, 209, 7, 178, 111, 90, 49, 106, 237, 7, 237]} : Maybe<&2, +List<U32>>}:
  {==}

def c32() -> {Bytes.vector_decoding(20n, [88, 70, 238, 138, 61, 126, 219, 180, 93, 237, 128, 31, 254, 236, 213, 46, 189, 171, 99, 198]) == Some{[88, 70, 238, 138, 61, 126, 219, 180, 93, 237, 128, 31, 254, 236, 213, 46, 189, 171, 99, 198]} : Maybe<&2, +List<U32>>}:
  {==}

def c33() -> {Bytes.vector_decoding(20n, [88, 70, 238, 138, 61, 126, 219, 180, 93, 237, 190, 128, 254, 236, 213, 46, 189, 171, 99, 198]) == Some{[88, 70, 238, 138, 61, 126, 219, 180, 93, 237, 190, 128, 254, 236, 213, 46, 189, 171, 99, 198]} : Maybe<&2, +List<U32>>}:
  {==}

def c34() -> {Bytes.vector_decoding(20n, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0]) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c35() -> {Bytes.vector_decoding(20n, [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0]) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c36() -> {Bytes.vector_decoding(20n, [183, 229, 43, 117, 110, 41, 53, 12, 251, 7, 182, 157, 176, 199, 135, 12, 143, 81, 166, 72]) == Some{[183, 229, 43, 117, 110, 41, 53, 12, 251, 7, 182, 157, 176, 199, 135, 12, 143, 81, 166, 72]} : Maybe<&2, +List<U32>>}:
  {==}
