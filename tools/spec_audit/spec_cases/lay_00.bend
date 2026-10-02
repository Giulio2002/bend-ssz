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

def c0() -> {Lay.decoding([Some{8n}, None{}, Some{96n}], []) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c1() -> {Lay.decoding([None{}, Some{128n}, Some{96n}, Some{8n}], []) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c2() -> {Lay.decoding([None{}, None{}], []) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c3() -> {Lay.decoding([Some{8n}, Some{8n}, Some{32n}, Some{32n}, None{}], []) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c4() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 1, 5]) == Some{[[1], [0], [0], [5], [0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c5() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 1, 32]) == Some{[[1], [0], [0], [32], [0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c6() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 1, 1, 12, 0, 0, 0, 1, 6, 25]) == Some{[[6], [1], [1], [25], [1]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c7() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 255, 5, 1]) == Some{[[5], [0], [0], [1], [255]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c8() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 1, 4]) == Some{[[1], [0], [0], [4], [0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c9() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [255, 0, 0, 0, 1, 0, 12, 0, 0, 0, 207, 4, 16]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c10() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 4]) == Some{[[4], [0], [0], [], [0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c11() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [0, 0, 0, 128, 3, 1, 12, 0, 0, 0, 255, 15, 15]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c12() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 128, 0, 0, 0, 12, 0, 0, 0, 0, 1, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c13() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], []) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c14() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 128, 0, 0, 12, 0, 0, 0, 0, 4, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c15() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c16() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 3, 1, 255, 255, 255, 255, 235, 9, 8]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c17() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [3, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 5, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c18() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [10, 0, 0, 0, 3, 1, 12, 0, 0, 0, 235, 9, 8]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c19() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [10, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 1, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c20() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 255, 0, 0, 12, 0, 0, 0, 0, 4, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c21() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 0, 0, 0, 1, 1, 12, 255, 0, 0, 1, 6, 25]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c22() -> {Lay.decoding([None{}, Some{1n}, Some{1n}, None{}, Some{1n}], [11, 128, 0, 0, 0, 0, 12, 0, 0, 0, 0, 5, 1]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c23() -> {Lay.decoding([Some{2n}, None{}, Some{1n}, None{}, None{}, Some{52n}, None{}], [0, 0, 71, 0, 0, 0, 0, 71, 0, 0, 0, 72, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 79, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 8, 0, 0, 0, 15, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0]) == Some{[[0, 0], [], [0], [0], [0, 0, 7, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [8, 0, 0, 0, 15, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c24() -> {Lay.decoding([Some{2n}, None{}, Some{1n}, None{}, None{}, Some{52n}, None{}], [0, 0, 71, 0, 0, 0, 0, 71, 0, 0, 0, 71, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 78, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 8, 0, 0, 0, 15, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0]) == Some{[[0, 0], [], [0], [], [0, 0, 7, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [8, 0, 0, 0, 15, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}
