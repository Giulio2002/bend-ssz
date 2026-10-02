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

def c414() -> {BitDec.bitlist_deserialize(31n, [0, 0, 1]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c415() -> {BitDec.bitlist_deserialize(31n, [52, 255]) == Some{[False{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c416() -> {BitDec.bitlist_deserialize(31n, [0, 0, 2]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c417() -> {BitDec.bitlist_deserialize(31n, [1, 0, 0, 0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c418() -> {BitDec.bitlist_deserialize(31n, [5]) == Some{[True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c419() -> {BitDec.bitlist_deserialize(31n, [15, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c420() -> {BitDec.bitlist_deserialize(31n, [255]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c421() -> {BitDec.bitlist_deserialize(31n, [52, 14]) == Some{[False{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c422() -> {BitDec.bitlist_deserialize(31n, [1, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c423() -> {BitDec.bitlist_deserialize(31n, [0, 4]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c424() -> {BitDec.bitlist_deserialize(32n, [0, 0, 0, 128]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c425() -> {BitDec.bitlist_deserialize(32n, [255, 255, 255, 255, 255, 255, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c426() -> {BitDec.bitlist_deserialize(32n, [22]) == Some{[False{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c427() -> {BitDec.bitlist_deserialize(32n, [15, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c428() -> {BitDec.bitlist_deserialize(32n, [0, 15]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c429() -> {BitDec.bitlist_deserialize(32n, [13]) == Some{[True{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c430() -> {BitDec.bitlist_deserialize(32n, [23]) == Some{[True{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c431() -> {BitDec.bitlist_deserialize(32n, [22, 198]) == Some{[False{}, True{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c432() -> {BitDec.bitlist_deserialize(32n, [5]) == Some{[True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c433() -> {BitDec.bitlist_deserialize(32n, [0, 128]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c434() -> {BitDec.bitlist_deserialize(33n, [215, 128]) == Some{[True{}, True{}, True{}, False{}, True{}, False{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c435() -> {BitDec.bitlist_deserialize(33n, [255, 255, 255, 255, 255, 255, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c436() -> {BitDec.bitlist_deserialize(33n, [0, 0, 2]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c437() -> {BitDec.bitlist_deserialize(33n, [128, 88]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c438() -> {BitDec.bitlist_deserialize(33n, [3, 1]) == Some{[True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}
