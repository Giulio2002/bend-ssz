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

def c364() -> {BitDec.bitlist_deserialize(15n, [1, 1]) == Some{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c365() -> {BitDec.bitlist_deserialize(15n, [202, 2]) == Some{[False{}, True{}, False{}, True{}, False{}, False{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c366() -> {BitDec.bitlist_deserialize(15n, [246, 118]) == Some{[False{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c367() -> {BitDec.bitlist_deserialize(15n, [255, 2]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c368() -> {BitDec.bitlist_deserialize(15n, [12, 1]) == Some{[False{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c369() -> {BitDec.bitlist_deserialize(15n, [1, 0, 2]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c370() -> {BitDec.bitlist_deserialize(15n, [1, 128]) == Some{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c371() -> {BitDec.bitlist_deserialize(15n, [0, 0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c372() -> {BitDec.bitlist_deserialize(15n, [2]) == Some{[False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c373() -> {BitDec.bitlist_deserialize(15n, [1, 2]) == Some{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c374() -> {BitDec.bitlist_deserialize(16n, [0, 2]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c375() -> {BitDec.bitlist_deserialize(16n, [189]) == Some{[True{}, False{}, True{}, True{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c376() -> {BitDec.bitlist_deserialize(16n, [0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c377() -> {BitDec.bitlist_deserialize(16n, [0, 5]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c378() -> {BitDec.bitlist_deserialize(16n, [13, 128]) == Some{[True{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c379() -> {BitDec.bitlist_deserialize(16n, [157, 3]) == Some{[True{}, False{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c380() -> {BitDec.bitlist_deserialize(16n, [2, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c381() -> {BitDec.bitlist_deserialize(16n, [128]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c382() -> {BitDec.bitlist_deserialize(16n, [50]) == Some{[False{}, True{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c383() -> {BitDec.bitlist_deserialize(16n, [0, 188]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c384() -> {BitDec.bitlist_deserialize(17n, [128]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c385() -> {BitDec.bitlist_deserialize(17n, [0, 5]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c386() -> {BitDec.bitlist_deserialize(17n, [3]) == Some{[True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c387() -> {BitDec.bitlist_deserialize(17n, [3, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c388() -> {BitDec.bitlist_deserialize(17n, [14]) == Some{[False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}
