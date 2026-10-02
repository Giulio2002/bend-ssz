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

def c244() -> {Prim.uint_decoding(P.U256{}, [253, 168, 41, 235, 93, 72, 149, 65, 107, 181, 7, 225, 247, 1, 241, 231, 56, 180, 92, 230, 240, 32, 247, 22, 229, 44, 74, 239, 153, 77, 119, 174]) == Some{P.UInt{3945375997, 1100302429, 3775378795, 3891331575, 3864835128, 385294576, 4014615781, 2927054233}} : Maybe<&2, P.UInt>}:
  {==}

def c245() -> {Prim.uint_decoding(P.U256{}, [253, 168, 41, 235, 93, 72, 149, 65, 107, 181, 7, 225, 247, 2, 241, 231, 56, 180, 92, 230, 240, 255, 247, 22, 229, 44, 74, 239, 153, 77, 119, 174]) == Some{P.UInt{3945375997, 1100302429, 3775378795, 3891331831, 3864835128, 385351664, 4014615781, 2927054233}} : Maybe<&2, P.UInt>}:
  {==}

def c246() -> {Prim.uint_decoding(P.U256{}, [81, 187, 76, 29, 182, 31, 42, 187, 130, 14, 217, 21, 206, 72, 51, 119, 79, 27, 197, 124, 138, 82, 98, 124, 47, 191, 35, 16, 222, 61, 33, 128]) == Some{P.UInt{491567953, 3140100022, 366546562, 1999849678, 2093292367, 2086818442, 270778159, 2149662174}} : Maybe<&2, P.UInt>}:
  {==}

def c247() -> {Prim.uint_decoding(P.U256{}, [81, 187, 76, 29, 182, 31, 42, 255, 130, 14, 217, 21, 206, 72, 51, 119, 79, 27, 197, 124, 138, 82, 98, 124, 47, 191, 35, 16, 222, 61, 33, 180]) == Some{P.UInt{491567953, 4280950710, 366546562, 1999849678, 2093292367, 2086818442, 270778159, 3022077406}} : Maybe<&2, P.UInt>}:
  {==}

def c248() -> {Prim.uint_decoding(P.U256{}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c249() -> {Prim.uint_decoding(P.U256{}, [255, 203, 251, 218, 159, 36, 85, 35, 190, 223, 50, 39, 206, 75, 121, 255, 15, 124, 45, 99, 122, 203, 30, 87, 37, 188, 50, 148, 235, 41, 174, 111]) == Some{P.UInt{3673934847, 592782495, 657645502, 4286139342, 1663925263, 1461635962, 2486352933, 1873684971}} : Maybe<&2, P.UInt>}:
  {==}

def c250() -> {Prim.uint_decoding(P.U256{}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 0, 0, 0, 32768, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c251() -> {Prim.uint_decoding(P.U256{}, [255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{P.UInt{4294967295, 4294902015, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}} : Maybe<&2, P.UInt>}:
  {==}

def c252() -> {Prim.uint_decoding(P.U256{}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{P.UInt{0, 0, 0, 0, 0, 2147483648, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c253() -> {Prim.uint_decoding(P.U256{}, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c254() -> {Prim.uint_decoding(P.U8{}, [0, 57]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c255() -> {Prim.uint_decoding(P.U8{}, [255, 0]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c256() -> {Prim.uint_decoding(P.U8{}, []) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c257() -> {Prim.uint_decoding(P.U8{}, [118]) == Some{P.UInt{118, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c258() -> {Prim.uint_decoding(P.U8{}, [1, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c259() -> {Prim.uint_decoding(P.U8{}, [255, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c260() -> {Prim.uint_decoding(P.U8{}, [254]) == Some{P.UInt{254, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c261() -> {Prim.uint_decoding(P.U8{}, [1]) == Some{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c262() -> {Prim.uint_decoding(P.U8{}, [0, 1]) == None{} : Maybe<&2, P.UInt>}:
  {==}

def c263() -> {Prim.uint_decoding(P.U8{}, [57]) == Some{P.UInt{57, 0, 0, 0, 0, 0, 0, 0}} : Maybe<&2, P.UInt>}:
  {==}

def c264() -> {Bytes.vector_decoding(8n, [0, 0, 0, 0, 1, 0, 0, 0]) == Some{[0, 0, 0, 0, 1, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c265() -> {Bytes.vector_decoding(8n, [25, 217, 208, 0, 216, 0, 89, 86]) == Some{[25, 217, 208, 0, 216, 0, 89, 86]} : Maybe<&2, +List<U32>>}:
  {==}

def c266() -> {Bytes.vector_decoding(8n, [255, 1, 255, 255, 255, 255, 255, 255]) == Some{[255, 1, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c267() -> {Bytes.vector_decoding(8n, [0, 0, 0, 255, 0, 0, 0, 0]) == Some{[0, 0, 0, 255, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c268() -> {Bytes.vector_decoding(8n, [255, 255, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, +List<U32>>}:
  {==}
