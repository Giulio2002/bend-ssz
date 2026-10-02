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

def c124() -> {Lay.decoding([Some{1n}, None{}, None{}, None{}, None{}, None{}, None{}, None{}], [0, 29, 0, 0, 0, 35, 0, 0, 0, 36, 0, 0, 0, 60, 0, 0, 0, 68, 0, 0, 0, 68, 0, 0, 0, 70, 0, 0, 0, 255, 255, 152, 78, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 15, 208, 246, 135, 81, 201, 175, 25, 0, 0, 197, 171, 43, 190, 1, 0, 255, 255, 4, 0, 0, 0, 255, 10, 0, 0, 0, 15, 0, 0, 0, 255, 255, 1, 0, 175, 85, 215, 91]) == Some{[[0], [255, 255, 152, 78, 0, 0], [1], [1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 15, 208, 246, 135, 81, 201, 175, 25], [0, 0, 197, 171, 43, 190, 1, 0], [], [255, 255], [4, 0, 0, 0, 255, 10, 0, 0, 0, 15, 0, 0, 0, 255, 255, 1, 0, 175, 85, 215, 91]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c125() -> {Lay.decoding([None{}], [4, 0, 0, 0, 2, 1]) == Some{[[2, 1]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c126() -> {Lay.decoding([None{}], [4, 0, 0, 0, 14]) == Some{[[14]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c127() -> {Lay.decoding([None{}], [4, 0, 0, 0, 1, 1]) == Some{[[1, 1]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c128() -> {Lay.decoding([None{}], [4, 0, 0, 0, 12]) == Some{[[12]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c129() -> {Lay.decoding([None{}], [4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]) == Some{[[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c130() -> {Lay.decoding([None{}], [4, 0, 1, 0, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c131() -> {Lay.decoding([None{}], [4, 0, 0, 128, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c132() -> {Lay.decoding([None{}], [4, 0, 0, 1, 2]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c133() -> {Lay.decoding([None{}], [4, 0, 0, 0, 8, 0]) == Some{[[8, 0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c134() -> {Lay.decoding([None{}], [4, 0, 0, 128, 15]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c135() -> {Lay.decoding([None{}], [4, 0, 0, 255, 62]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c136() -> {Lay.decoding([None{}], [3, 0, 0, 0, 8]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c137() -> {Lay.decoding([None{}], [4, 0, 0, 0, 4, 0]) == Some{[[4, 0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c138() -> {Lay.decoding([None{}], [4, 128, 0, 0, 2]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c139() -> {Lay.decoding([None{}], [4, 255, 0, 0, 4]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c140() -> {Lay.decoding([None{}], [4, 0, 0, 255, 8]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c141() -> {Lay.decoding([None{}], [0, 4, 0, 0, 0, 5]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c142() -> {Lay.decoding([None{}], [5, 0, 0, 0, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c143() -> {Lay.decoding([None{}], [8, 0, 0, 0, 8]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c144() -> {Lay.decoding([None{}, None{}, None{}, None{}], [16, 0, 0, 0, 19, 0, 0, 0, 19, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0]) == Some{[[0, 0, 0], [], [], []]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c145() -> {Lay.decoding([None{}, None{}, None{}, None{}], [16, 0, 0, 0, 18, 0, 0, 0, 34, 0, 0, 0, 42, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 8, 0, 0, 0, 38, 0, 0, 0, 8, 0, 0, 0, 19, 0, 0, 0, 255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 8, 0, 0, 0, 19, 0, 0, 0, 254, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255]) == Some{[[255, 255], [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255], [255, 255, 255, 255, 255, 255, 255, 255], [8, 0, 0, 0, 38, 0, 0, 0, 8, 0, 0, 0, 19, 0, 0, 0, 255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 8, 0, 0, 0, 19, 0, 0, 0, 254, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c146() -> {Lay.decoding([None{}, None{}, None{}, None{}], [16, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0]) == Some{[[], [], [], [20, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0, 20, 0, 0, 0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c147() -> {Lay.decoding([None{}, None{}, None{}, None{}], [16, 0, 0, 0, 16, 0, 0, 0, 48, 0, 0, 0, 48, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255]) == Some{[[], [255, 255, 255, 255, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255], [], []]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c148() -> {Lay.decoding([None{}, None{}, None{}, None{}], [16, 0, 0, 0, 17, 0, 0, 0, 17, 0, 0, 0, 17, 0, 0, 0, 0]) == Some{[[0], [], [], []]} : Maybe<&2, +List<+List<U32>>>}:
  {==}
