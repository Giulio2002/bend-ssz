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

def c339() -> {Bytes.vector_decoding(32n, [117, 171, 38, 81, 89, 204, 19, 60, 2, 189, 90, 128, 168, 43, 43, 169, 92, 217, 201, 248, 28, 36, 29, 250, 0, 67, 122, 183, 23, 240, 102, 0]) == Some{[117, 171, 38, 81, 89, 204, 19, 60, 2, 189, 90, 128, 168, 43, 43, 169, 92, 217, 201, 248, 28, 36, 29, 250, 0, 67, 122, 183, 23, 240, 102, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c340() -> {Bytes.vector_decoding(32n, [46, 0, 123, 135, 128, 9, 130, 176, 57, 119, 240, 228, 55, 11, 47, 80, 69, 220, 2, 236, 54, 229, 174, 213, 205, 42, 160, 61, 25, 169, 15, 30]) == Some{[46, 0, 123, 135, 128, 9, 130, 176, 57, 119, 240, 228, 55, 11, 47, 80, 69, 220, 2, 236, 54, 229, 174, 213, 205, 42, 160, 61, 25, 169, 15, 30]} : Maybe<&2, +List<U32>>}:
  {==}

def c341() -> {Bytes.vector_decoding(32n, [46, 227, 123, 135, 128, 9, 0, 176, 57, 119, 240, 228, 55, 11, 47, 80, 69, 220, 2, 236, 54, 229, 174, 213, 205, 42, 160, 61, 25, 169, 15, 30]) == Some{[46, 227, 123, 135, 128, 9, 0, 176, 57, 119, 240, 228, 55, 11, 47, 80, 69, 220, 2, 236, 54, 229, 174, 213, 205, 42, 160, 61, 25, 169, 15, 30]} : Maybe<&2, +List<U32>>}:
  {==}

def c342() -> {Bytes.vector_decoding(32n, [46, 227, 123, 135, 128, 9, 130, 176, 57, 119, 240, 228, 55, 11, 47, 80, 69, 220, 2, 236, 54, 229, 174, 213, 205, 42, 160, 61, 25, 0, 15, 30]) == Some{[46, 227, 123, 135, 128, 9, 130, 176, 57, 119, 240, 228, 55, 11, 47, 80, 69, 220, 2, 236, 54, 229, 174, 213, 205, 42, 160, 61, 25, 0, 15, 30]} : Maybe<&2, +List<U32>>}:
  {==}

def c343() -> {Bytes.vector_decoding(32n, [117, 171, 38, 81, 89, 204, 19, 60, 2, 189, 90, 128, 168, 1, 43, 169, 92, 217, 201, 248, 28, 36, 29, 250, 81, 67, 122, 183, 23, 240, 102, 0]) == Some{[117, 171, 38, 81, 89, 204, 19, 60, 2, 189, 90, 128, 168, 1, 43, 169, 92, 217, 201, 248, 28, 36, 29, 250, 81, 67, 122, 183, 23, 240, 102, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c344() -> {Prim.uint_decoding(P.U64{}, [98, 168, 206, 53, 5, 68, 36, 156, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c345() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 255, 255, 255, 255, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c346() -> {Prim.uint_decoding(P.U64{}, [0, 128, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{32768, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c347() -> {Prim.uint_decoding(P.U64{}, [0, 0, 255, 0, 0, 0, 0, 0]) == Some{P.UInt{16711680, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c348() -> {Prim.uint_decoding(P.U64{}, [0, 0, 0, 0, 0, 0, 0, 255]) == Some{P.UInt{0, 4278190080, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c349() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 1, 255, 255, 255]) == Some{P.UInt{4294967295, 4294967041, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c350() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 128, 255, 255, 255, 255]) == Some{P.UInt{2164260863, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c351() -> {Prim.uint_decoding(P.U64{}, [255, 255, 255, 255, 0, 255, 255, 255]) == Some{P.UInt{4294967295, 4294967040, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c352() -> {Prim.uint_decoding(P.U64{}, [255, 255, 1, 255, 255, 255, 255, 255]) == Some{P.UInt{4278321151, 4294967295, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c353() -> {Prim.uint_decoding(P.U64{}, [0, 255, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c354() -> {BitDec.bitlist_deserialize(1n, [128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c355() -> {BitDec.bitlist_deserialize(1n, [2, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c356() -> {BitDec.bitlist_deserialize(1n, [255, 255, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c357() -> {BitDec.bitlist_deserialize(1n, [1, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c358() -> {BitDec.bitlist_deserialize(1n, [2]) == Some{[False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c359() -> {BitDec.bitlist_deserialize(1n, [0, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c360() -> {BitDec.bitlist_deserialize(1n, [8]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c361() -> {BitDec.bitlist_deserialize(1n, [0, 2]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c362() -> {BitDec.bitlist_deserialize(1n, [1]) == Some{[]} : Maybe<&2, +List<Bool>>}:
  {==}

def c363() -> {BitDec.bitlist_deserialize(1n, [3, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}
