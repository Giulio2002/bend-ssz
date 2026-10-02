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

def c141() -> {Bytes.vector_decoding(32n, [142, 143, 55, 128, 209, 123, 108, 196, 180, 9, 47, 164, 215, 90, 161, 207, 128, 16, 6, 108, 107, 250, 230, 105, 70, 129, 19, 148, 187, 36, 153, 159]) == Some{[142, 143, 55, 128, 209, 123, 108, 196, 180, 9, 47, 164, 215, 90, 161, 207, 128, 16, 6, 108, 107, 250, 230, 105, 70, 129, 19, 148, 187, 36, 153, 159]} : Maybe<&2, +List<U32>>}:
  {==}

def c142() -> {Bytes.vector_decoding(32n, [8, 120, 138, 198, 223, 118, 1, 176, 161, 14, 100, 40, 80, 217, 75, 76, 189, 46, 188, 145, 64, 21, 200, 155, 87, 185, 185, 81, 137, 23, 71, 90]) == Some{[8, 120, 138, 198, 223, 118, 1, 176, 161, 14, 100, 40, 80, 217, 75, 76, 189, 46, 188, 145, 64, 21, 200, 155, 87, 185, 185, 81, 137, 23, 71, 90]} : Maybe<&2, +List<U32>>}:
  {==}

def c143() -> {Bytes.vector_decoding(4n, [243, 179, 18, 136, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c144() -> {Bytes.vector_decoding(4n, [0, 179, 18, 136]) == Some{[0, 179, 18, 136]} : Maybe<&2, +List<U32>>}:
  {==}

def c145() -> {Bytes.vector_decoding(4n, [255, 255, 255, 255]) == Some{[255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c146() -> {Bytes.vector_decoding(4n, [254, 255, 255, 255]) == Some{[254, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c147() -> {Bytes.vector_decoding(4n, [130, 118, 148, 155, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c148() -> {Bytes.vector_decoding(4n, [144, 207, 170]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c149() -> {Bytes.vector_decoding(4n, [0, 255, 0, 0]) == Some{[0, 255, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c150() -> {Bytes.vector_decoding(4n, [144, 207, 1, 12]) == Some{[144, 207, 1, 12]} : Maybe<&2, +List<U32>>}:
  {==}

def c151() -> {Bytes.vector_decoding(4n, [144, 207, 170, 12]) == Some{[144, 207, 170, 12]} : Maybe<&2, +List<U32>>}:
  {==}

def c152() -> {Bytes.vector_decoding(4n, [130, 118, 148, 1]) == Some{[130, 118, 148, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c153() -> {Prim.uint_decoding(P.U64{}, [255, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c154() -> {Prim.uint_decoding(P.U64{}, [128, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967168, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c155() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0, 0, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c156() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 0, 255, 255, 255]) == Some{P.UInt{4294967295, 4294967040, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c157() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 1, 255, 255]) == Some{P.UInt{4294967295, 4294902271, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c158() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 128, 255]) == Some{P.UInt{4294967295, 4286644223, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c159() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 0, 255, 255, 255, 255]) == Some{P.UInt{16777215, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c160() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255, 128]) == Some{P.UInt{4294967295, 2164260863, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c161() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c162() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c163() -> {Prim.uint_decoding(P.U64{}, [1, 0, 0, 255, 0, 0, 0, 0]) == Some{P.UInt{4278190081, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c164() -> {Prim.uint_decoding(P.U64{}, [79, 34, 228, 241, 228, 99, 187]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c165() -> {Prim.uint_decoding(P.U64{}, [79, 34, 228, 240, 228, 99, 187, 114]) == Some{P.UInt{4041482831, 1924883428, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}
