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

def c70() -> {Bytes.vector_decoding(48n, []) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c71() -> {Bytes.vector_decoding(8n, [56, 1, 6, 234, 42, 212, 12, 90]) == Some{[56, 1, 6, 234, 42, 212, 12, 90]} : Maybe<&2, +List<U32>>}:
  {==}

def c72() -> {Bytes.vector_decoding(8n, [255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c73() -> {Bytes.vector_decoding(8n, [187, 19, 85, 229, 0, 53, 127, 55]) == Some{[187, 19, 85, 229, 0, 53, 127, 55]} : Maybe<&2, +List<U32>>}:
  {==}

def c74() -> {Bytes.vector_decoding(8n, [56, 65, 6, 234, 42, 212, 12]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c75() -> {Bytes.vector_decoding(8n, [255, 1, 255, 255, 255, 255, 255, 255]) == Some{[255, 1, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c76() -> {Bytes.vector_decoding(8n, [121, 135, 255, 252, 99, 81, 149, 33]) == Some{[121, 135, 255, 252, 99, 81, 149, 33]} : Maybe<&2, +List<U32>>}:
  {==}

def c77() -> {Bytes.vector_decoding(8n, [187, 19, 85, 229, 150, 53, 127, 55]) == Some{[187, 19, 85, 229, 150, 53, 127, 55]} : Maybe<&2, +List<U32>>}:
  {==}

def c78() -> {Bytes.vector_decoding(8n, [56, 65, 6, 234]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c79() -> {Bytes.vector_decoding(8n, [187, 19, 85, 229, 150, 53, 127, 255]) == Some{[187, 19, 85, 229, 150, 53, 127, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c80() -> {Bytes.vector_decoding(8n, [121, 0, 126, 252, 99, 81, 149, 33]) == Some{[121, 0, 126, 252, 99, 81, 149, 33]} : Maybe<&2, +List<U32>>}:
  {==}

def c81() -> {Bytes.vector_decoding(96n, []) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c82() -> {Bytes.vector_decoding(2048n, []) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c83() -> {Prim.uint_decoding(P.U64{}, [238, 33, 76, 143, 9, 1, 42, 206]) == Some{P.UInt{2404131310, 3458859273, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c84() -> {Prim.uint_decoding(P.U64{}, [255, 255, 0, 255, 255, 255, 255, 255]) == Some{P.UInt{4278255615, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c85() -> {Prim.uint_decoding(P.U64{}, [238, 33, 76, 143, 9, 237, 42, 1]) == Some{P.UInt{2404131310, 19590409, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c86() -> {Prim.uint_decoding(P.U64{}, [238, 33, 76, 143, 9, 237, 1, 206]) == Some{P.UInt{2404131310, 3456232713, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c87() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 255, 0, 0, 0, 0]) == Some{P.UInt{4278190080, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c88() -> {Prim.uint_decoding(P.U64{}, [238, 33, 76, 143, 9, 237, 128, 206]) == Some{P.UInt{2404131310, 3464555785, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c89() -> {Prim.uint_decoding(P.U64{}, [255, 255, 1, 255, 255, 255, 255, 255]) == Some{P.UInt{4278321151, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c90() -> {Prim.uint_decoding(P.U64{}, [238, 33, 76, 143, 9, 237, 255, 206]) == Some{P.UInt{2404131310, 3472878857, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c91() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 254, 255, 255]) == Some{P.UInt{4294967295, 4294967039, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c92() -> {Prim.uint_decoding(P.U64{}, [255, 128, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294934783, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c93() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 1, 0]) == Some{P.UInt{0, 65536, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c94() -> {Prim.uint_decoding(P.U64{}, [0, 1, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}
