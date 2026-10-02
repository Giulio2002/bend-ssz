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

def c609() -> {BitDec.bitvector_deserialize(32n, [233, 0, 250, 160]) == Some{[True{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c610() -> {BitDec.bitvector_deserialize(32n, [233, 114, 250, 160]) == Some{[True{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c611() -> {BitDec.bitvector_deserialize(32n, [255, 255, 254, 255]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c612() -> {BitDec.bitvector_deserialize(32n, [0, 2, 65, 86, 150]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c613() -> {BitDec.bitvector_deserialize(32n, [2, 65, 255, 150]) == Some{[False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c614() -> {BitDec.bitvector_deserialize(33n, [103, 157, 136, 128, 255]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c615() -> {BitDec.bitvector_deserialize(33n, [103, 157, 136, 0, 1]) == Some{[True{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c616() -> {BitDec.bitvector_deserialize(33n, [215, 168, 124, 106, 255]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c617() -> {BitDec.bitvector_deserialize(33n, [255, 255, 255, 255, 128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c618() -> {BitDec.bitvector_deserialize(33n, [103, 157, 136, 128, 1]) == Some{[True{}, True{}, True{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c619() -> {BitDec.bitvector_deserialize(33n, [215, 168, 124, 1, 0]) == Some{[True{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c620() -> {BitDec.bitvector_deserialize(33n, [0, 0, 0, 0, 0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c621() -> {BitDec.bitvector_deserialize(33n, [128, 0, 0, 0, 0]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c622() -> {BitDec.bitvector_deserialize(33n, [255, 255, 255, 1, 1]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c623() -> {BitDec.bitvector_deserialize(33n, [176, 16, 0, 208, 1]) == Some{[False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c624() -> {BitDec.bitvector_deserialize(4n, [15, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c625() -> {BitDec.bitvector_deserialize(4n, [10]) == Some{[False{}, True{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c626() -> {BitDec.bitvector_deserialize(4n, [16]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c627() -> {BitDec.bitvector_deserialize(4n, [9]) == Some{[True{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c628() -> {BitDec.bitvector_deserialize(4n, [15]) == Some{[True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}
