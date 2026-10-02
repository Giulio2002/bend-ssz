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

def c194() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [255, 255, 0, 0, 0, 128, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c195() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == Some{[[0, 0], [0, 0, 0, 0, 0], [0]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c196() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [235, 199, 7, 0, 0, 0, 255, 0, 0, 1, 0, 0]) == Some{[[235, 199], [0, 0, 1, 0, 0], [255]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c197() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [0, 0, 0, 0, 0, 128, 0, 255, 255]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c198() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 1]) == Some{[[255, 255], [255, 255, 255, 255, 1], [255]]} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c199() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [255, 255, 12, 0, 0, 0, 255, 255, 255, 255, 255]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c200() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [255, 255, 255, 0, 0, 0, 255, 0, 0]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c201() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [235, 199, 12, 0, 0, 0, 255, 0, 0, 1, 0]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}

def c202() -> {Lay.decoding([Some{2n}, None{}, Some{1n}], [255, 255, 7, 128, 0, 0, 255, 0, 0]) == None{} : Maybe<&2, +List<+List<U32>>>}:
  {==}
