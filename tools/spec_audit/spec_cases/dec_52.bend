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

def c847() -> {Bytes.vector_decoding(5n, [64, 194, 32, 128, 249]) == Some{[64, 194, 32, 128, 249]} : Maybe<&2, +List<U32>>}:
  {==}

def c848() -> {Bytes.vector_decoding(5n, [0, 0, 0, 0, 128]) == Some{[0, 0, 0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c849() -> {Bytes.vector_decoding(5n, [0, 0, 128, 0, 0]) == Some{[0, 0, 128, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c850() -> {Bytes.vector_decoding(5n, [133, 0, 102, 128, 101]) == Some{[133, 0, 102, 128, 101]} : Maybe<&2, +List<U32>>}:
  {==}

def c851() -> {Bytes.vector_decoding(5n, [0, 64, 194, 32, 58, 249]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c852() -> {Bytes.vector_decoding(5n, [255, 128, 255, 255, 255]) == Some{[255, 128, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c853() -> {Bytes.vector_decoding(5n, [225, 170, 0, 41, 89]) == Some{[225, 170, 0, 41, 89]} : Maybe<&2, +List<U32>>}:
  {==}

def c854() -> {Bytes.vector_decoding(512n, []) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c855() -> {Bytes.vector_decoding(513n, []) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c856() -> {Bytes.vector_decoding(8n, [255, 255, 255, 255]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c857() -> {Bytes.vector_decoding(8n, [0, 0, 0, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c858() -> {Bytes.vector_decoding(8n, [74, 94, 43, 17, 54, 128, 113, 155]) == Some{[74, 94, 43, 17, 54, 128, 113, 155]} : Maybe<&2, +List<U32>>}:
  {==}

def c859() -> {Bytes.vector_decoding(8n, [234, 186, 217, 158, 113, 16, 206, 57]) == Some{[234, 186, 217, 158, 113, 16, 206, 57]} : Maybe<&2, +List<U32>>}:
  {==}

def c860() -> {Bytes.vector_decoding(8n, [211, 52, 130, 45, 236, 163, 211, 40]) == Some{[211, 52, 130, 45, 236, 163, 211, 40]} : Maybe<&2, +List<U32>>}:
  {==}

def c861() -> {Bytes.vector_decoding(8n, [74, 95, 43, 17, 54, 226, 113, 155]) == Some{[74, 95, 43, 17, 54, 226, 113, 155]} : Maybe<&2, +List<U32>>}:
  {==}

def c862() -> {Bytes.vector_decoding(8n, [234, 186, 217, 158, 113, 1, 207, 57]) == Some{[234, 186, 217, 158, 113, 1, 207, 57]} : Maybe<&2, +List<U32>>}:
  {==}

def c863() -> {Bytes.vector_decoding(8n, [75, 94, 43, 17, 54, 226, 113, 155]) == Some{[75, 94, 43, 17, 54, 226, 113, 155]} : Maybe<&2, +List<U32>>}:
  {==}

def c864() -> {Bytes.vector_decoding(8n, [1, 255, 255, 255, 255, 255, 255, 255]) == Some{[1, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c865() -> {Bytes.vector_decoding(8n, [211, 52, 131, 45]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c866() -> {ByteList.decoding(1n, []) == Some{[]} : Maybe<&2, +List<U32>>}:
  {==}

def c867() -> {ByteList.decoding(1n, [5]) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c868() -> {ByteList.decoding(1n, []) == Some{[]} : Maybe<&2, +List<U32>>}:
  {==}

def c869() -> {ByteList.decoding(1n, [5]) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c870() -> {ByteList.decoding(1n, [5, 42]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c871() -> {ByteList.decoding(2n, []) == Some{[]} : Maybe<&2, +List<U32>>}:
  {==}
