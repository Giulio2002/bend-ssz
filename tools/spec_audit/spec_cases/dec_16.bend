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

def c314() -> {Prim.uint_decoding(P.U64{}, [114, 11, 138, 39, 111, 143, 93, 152, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c315() -> {Prim.uint_decoding(P.U64{}, [114, 11, 138, 39, 111, 143, 128, 152]) == Some{P.UInt{663358322, 2558562159, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c316() -> {Prim.uint_decoding(P.U64{}, [114, 11, 138, 39, 1, 143, 93, 152]) == Some{P.UInt{663358322, 2556268289, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c317() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 1, 255, 255, 255, 255]) == Some{P.UInt{33554431, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c318() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255, 255, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c319() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 254, 255, 255, 255]) == Some{P.UInt{4294967295, 4294967294, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c320() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c321() -> {Prim.uint_decoding(P.U64{}, [255, 0, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294902015, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c322() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 254, 255, 255, 255, 255]) == Some{P.UInt{4278190079, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c323() -> {Prim.uint_decoding(P.U64{}, [1, 1, 1, 1, 1, 1, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c324() -> {Bytes.vector_decoding(4n, [183, 60, 160, 47, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c325() -> {Bytes.vector_decoding(4n, [1, 255, 255, 255]) == Some{[1, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c326() -> {Bytes.vector_decoding(4n, [211, 117, 128, 181]) == Some{[211, 117, 128, 181]} : Maybe<&2, +List<U32>>}:
  {==}

def c327() -> {Bytes.vector_decoding(4n, [255, 255, 255, 1]) == Some{[255, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c328() -> {Bytes.vector_decoding(4n, [1, 117, 53, 181]) == Some{[1, 117, 53, 181]} : Maybe<&2, +List<U32>>}:
  {==}

def c329() -> {Bytes.vector_decoding(4n, [0, 0, 255, 0]) == Some{[0, 0, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c330() -> {Bytes.vector_decoding(4n, [211, 1, 53, 181]) == Some{[211, 1, 53, 181]} : Maybe<&2, +List<U32>>}:
  {==}

def c331() -> {Bytes.vector_decoding(4n, [0, 255, 255, 255, 255]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c332() -> {Bytes.vector_decoding(4n, [211, 117, 1, 181]) == Some{[211, 117, 1, 181]} : Maybe<&2, +List<U32>>}:
  {==}

def c333() -> {Bytes.vector_decoding(4n, [0, 0, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c334() -> {Bytes.vector_decoding(32n, [46, 227, 123, 135, 128, 9, 130, 176, 57, 119, 240, 228, 55, 11, 0, 80, 69, 220, 2, 236, 54, 229, 174, 213, 205, 42, 160, 61, 25, 169, 15, 30]) == Some{[46, 227, 123, 135, 128, 9, 130, 176, 57, 119, 240, 228, 55, 11, 0, 80, 69, 220, 2, 236, 54, 229, 174, 213, 205, 42, 160, 61, 25, 169, 15, 30]} : Maybe<&2, +List<U32>>}:
  {==}

def c335() -> {Bytes.vector_decoding(32n, [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c336() -> {Bytes.vector_decoding(32n, [145, 92, 13, 113, 17, 41, 38, 249, 233, 101, 48, 192, 36, 196, 152, 38, 113, 147, 148, 209, 189, 187, 136, 34, 36, 143, 250, 225, 134, 198, 126, 255]) == Some{[145, 92, 13, 113, 17, 41, 38, 249, 233, 101, 48, 192, 36, 196, 152, 38, 113, 147, 148, 209, 189, 187, 136, 34, 36, 143, 250, 225, 134, 198, 126, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c337() -> {Bytes.vector_decoding(32n, [145, 92, 13, 113, 17, 41, 38, 249, 233, 101, 48, 192, 36, 196, 152, 38, 113, 147, 148, 209, 189, 187, 136, 34, 36, 143, 250, 225, 135, 198, 126, 255, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c338() -> {Bytes.vector_decoding(32n, [145, 92, 13, 113, 17, 1, 38, 249, 233, 101, 48, 192, 36, 196, 152, 38, 113, 147, 148, 209, 189, 187, 136, 34, 36, 143, 250, 225, 135, 198, 126, 255]) == Some{[145, 92, 13, 113, 17, 1, 38, 249, 233, 101, 48, 192, 36, 196, 152, 38, 113, 147, 148, 209, 189, 187, 136, 34, 36, 143, 250, 225, 135, 198, 126, 255]} : Maybe<&2, +List<U32>>}:
  {==}
