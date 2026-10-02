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

def c539() -> {BitDec.bitvector_deserialize(1n, [0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c540() -> {BitDec.bitvector_deserialize(1n, [0]) == Some{[False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c541() -> {BitDec.bitvector_deserialize(1n, [1, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c542() -> {BitDec.bitvector_deserialize(1n, [0, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c543() -> {BitDec.bitvector_deserialize(1n, [2]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c544() -> {BitDec.bitvector_deserialize(15n, [128, 115]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c545() -> {BitDec.bitvector_deserialize(15n, [119]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c546() -> {BitDec.bitvector_deserialize(15n, [0, 230, 115]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c547() -> {BitDec.bitvector_deserialize(15n, [255, 115]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c548() -> {BitDec.bitvector_deserialize(15n, [128, 127]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c549() -> {BitDec.bitvector_deserialize(15n, [255, 1]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c550() -> {BitDec.bitvector_deserialize(15n, [1, 96]) == Some{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c551() -> {BitDec.bitvector_deserialize(15n, [255, 128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c552() -> {BitDec.bitvector_deserialize(15n, [48, 96]) == Some{[False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c553() -> {BitDec.bitvector_deserialize(15n, [255, 127]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c554() -> {BitDec.bitvector_deserialize(16n, [128, 128]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c555() -> {BitDec.bitvector_deserialize(16n, [0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c556() -> {BitDec.bitvector_deserialize(16n, [0, 171]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, True{}, False{}, True{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c557() -> {BitDec.bitvector_deserialize(16n, [39, 129]) == Some{[True{}, True{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c558() -> {BitDec.bitvector_deserialize(16n, [0, 133, 171]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c559() -> {BitDec.bitvector_deserialize(16n, [128, 0]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c560() -> {BitDec.bitvector_deserialize(16n, [0, 1]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c561() -> {BitDec.bitvector_deserialize(16n, [0, 0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c562() -> {BitDec.bitvector_deserialize(16n, [255, 254]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c563() -> {BitDec.bitvector_deserialize(16n, [255, 1]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}
