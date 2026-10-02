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

def c799() -> {Bytes.vector_decoding(16n, [118, 127, 2, 175, 213, 255, 11, 109, 124, 240, 42, 234, 63, 196, 139, 99]) == Some{[118, 127, 2, 175, 213, 255, 11, 109, 124, 240, 42, 234, 63, 196, 139, 99]} : Maybe<&2, +List<U32>>}:
  {==}

def c800() -> {Bytes.vector_decoding(16n, [107, 167, 159, 48, 1, 106, 19, 199, 242, 219, 125, 74, 15, 18, 200, 61]) == Some{[107, 167, 159, 48, 1, 106, 19, 199, 242, 219, 125, 74, 15, 18, 200, 61]} : Maybe<&2, +List<U32>>}:
  {==}

def c801() -> {Bytes.vector_decoding(16n, [128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{[128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c802() -> {Bytes.vector_decoding(16n, [118, 127, 2, 175, 213, 242, 11, 109, 124, 128, 42, 234, 63, 196, 139, 99]) == Some{[118, 127, 2, 175, 213, 242, 11, 109, 124, 128, 42, 234, 63, 196, 139, 99]} : Maybe<&2, +List<U32>>}:
  {==}

def c803() -> {Bytes.vector_decoding(16n, [0, 127, 2, 175, 213, 242, 11, 109, 124, 240, 42, 234, 63, 196, 139, 99]) == Some{[0, 127, 2, 175, 213, 242, 11, 109, 124, 240, 42, 234, 63, 196, 139, 99]} : Maybe<&2, +List<U32>>}:
  {==}

def c804() -> {Bytes.vector_decoding(2n, [255]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c805() -> {Bytes.vector_decoding(2n, [0, 0]) == Some{[0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c806() -> {Bytes.vector_decoding(2n, [0, 148]) == Some{[0, 148]} : Maybe<&2, +List<U32>>}:
  {==}

def c807() -> {Bytes.vector_decoding(2n, [125, 243]) == Some{[125, 243]} : Maybe<&2, +List<U32>>}:
  {==}

def c808() -> {Bytes.vector_decoding(2n, [187, 1]) == Some{[187, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c809() -> {Bytes.vector_decoding(2n, [81, 129, 1]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c810() -> {Bytes.vector_decoding(2n, [1, 243]) == Some{[1, 243]} : Maybe<&2, +List<U32>>}:
  {==}

def c811() -> {Bytes.vector_decoding(2n, [0, 255, 255]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c812() -> {Bytes.vector_decoding(2n, [0, 125, 243]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c813() -> {Bytes.vector_decoding(2n, [81, 129]) == Some{[81, 129]} : Maybe<&2, +List<U32>>}:
  {==}

def c814() -> {Bytes.vector_decoding(3n, [255, 1, 255]) == Some{[255, 1, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c815() -> {Bytes.vector_decoding(3n, [1, 255, 255]) == Some{[1, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c816() -> {Bytes.vector_decoding(3n, [138, 71, 213]) == Some{[138, 71, 213]} : Maybe<&2, +List<U32>>}:
  {==}

def c817() -> {Bytes.vector_decoding(3n, [255, 0, 255]) == Some{[255, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c818() -> {Bytes.vector_decoding(3n, [255, 255, 255, 1]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c819() -> {Bytes.vector_decoding(3n, [255, 255, 255, 0]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c820() -> {Bytes.vector_decoding(3n, [1, 70, 213]) == Some{[1, 70, 213]} : Maybe<&2, +List<U32>>}:
  {==}

def c821() -> {Bytes.vector_decoding(3n, [255, 255, 254]) == Some{[255, 255, 254]} : Maybe<&2, +List<U32>>}:
  {==}

def c822() -> {Bytes.vector_decoding(3n, [0, 0, 128]) == Some{[0, 0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c823() -> {Bytes.vector_decoding(3n, [139, 70, 213]) == Some{[139, 70, 213]} : Maybe<&2, +List<U32>>}:
  {==}
