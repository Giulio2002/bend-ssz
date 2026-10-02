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

def c166() -> {Prim.uint_decoding(P.U64{}, [79, 255, 228, 241, 228, 99, 187, 114]) == Some{P.UInt{4058316623, 1924883428, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c167() -> {Prim.uint_decoding(P.U64{}, [79, 0, 228, 241, 228, 99, 187, 114]) == Some{P.UInt{4058251343, 1924883428, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c168() -> {Prim.uint_decoding(P.U64{}, [79, 34, 228, 241, 228, 99, 187, 128]) == Some{P.UInt{4058260047, 2159764452, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c169() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0, 1]) == Some{P.UInt{0, 16777216, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c170() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 128, 255]) == Some{P.UInt{4294967295, 4286644223, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c171() -> {Prim.uint_decoding(P.U64{}, [255, 34, 228, 241, 228, 99, 187, 114]) == Some{P.UInt{4058260223, 1924883428, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c172() -> {Prim.uint_decoding(P.U64{}, [128, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c173() -> {Bytes.vector_decoding(20n, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0]) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c174() -> {Bytes.vector_decoding(20n, [255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c175() -> {Bytes.vector_decoding(20n, [255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{[255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c176() -> {Bytes.vector_decoding(20n, [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255]) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c177() -> {Bytes.vector_decoding(20n, [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c178() -> {Bytes.vector_decoding(20n, [222, 0, 208, 251, 68, 125, 138, 152, 132, 136, 113, 98, 128, 162, 87, 94, 99, 223, 87, 48]) == Some{[222, 0, 208, 251, 68, 125, 138, 152, 132, 136, 113, 98, 128, 162, 87, 94, 99, 223, 87, 48]} : Maybe<&2, +List<U32>>}:
  {==}

def c179() -> {Bytes.vector_decoding(20n, [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c180() -> {Bytes.vector_decoding(20n, [13, 22, 79, 86, 109, 25, 85, 89, 70, 133, 76, 210, 176, 89, 140, 27, 116, 253, 210, 0]) == Some{[13, 22, 79, 86, 109, 25, 85, 89, 70, 133, 76, 210, 176, 89, 140, 27, 116, 253, 210, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c181() -> {Bytes.vector_decoding(20n, [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255]) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c182() -> {Bytes.vector_decoding(20n, [222, 8, 208, 251, 68, 125, 138, 255, 132, 136, 113, 98, 128, 162, 87, 94, 99, 223, 87, 48]) == Some{[222, 8, 208, 251, 68, 125, 138, 255, 132, 136, 113, 98, 128, 162, 87, 94, 99, 223, 87, 48]} : Maybe<&2, +List<U32>>}:
  {==}

def c183() -> {Bytes.vector_decoding(4n, [196, 51, 122, 0]) == Some{[196, 51, 122, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c184() -> {Bytes.vector_decoding(4n, [74, 132, 87, 55]) == Some{[74, 132, 87, 55]} : Maybe<&2, +List<U32>>}:
  {==}

def c185() -> {Bytes.vector_decoding(4n, [196, 51, 128, 203]) == Some{[196, 51, 128, 203]} : Maybe<&2, +List<U32>>}:
  {==}

def c186() -> {Bytes.vector_decoding(4n, [23, 121, 0, 86]) == Some{[23, 121, 0, 86]} : Maybe<&2, +List<U32>>}:
  {==}

def c187() -> {Bytes.vector_decoding(4n, [196, 51, 1, 203]) == Some{[196, 51, 1, 203]} : Maybe<&2, +List<U32>>}:
  {==}

def c188() -> {Bytes.vector_decoding(4n, [23, 0, 0, 87]) == Some{[23, 0, 0, 87]} : Maybe<&2, +List<U32>>}:
  {==}

def c189() -> {Bytes.vector_decoding(4n, [196, 51, 0, 203]) == Some{[196, 51, 0, 203]} : Maybe<&2, +List<U32>>}:
  {==}

def c190() -> {Bytes.vector_decoding(4n, [23, 121, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}
