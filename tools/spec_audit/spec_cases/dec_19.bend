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

def c389() -> {BitDec.bitlist_deserialize(17n, [36, 3]) == Some{[False{}, False{}, True{}, False{}, False{}, True{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c390() -> {BitDec.bitlist_deserialize(17n, [128, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c391() -> {BitDec.bitlist_deserialize(17n, [0, 0, 4]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c392() -> {BitDec.bitlist_deserialize(17n, [0, 128]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c393() -> {BitDec.bitlist_deserialize(17n, [0, 4]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c394() -> {BitDec.bitlist_deserialize(2n, [0, 0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c395() -> {BitDec.bitlist_deserialize(2n, []) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c396() -> {BitDec.bitlist_deserialize(2n, [6]) == Some{[False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c397() -> {BitDec.bitlist_deserialize(2n, [4, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c398() -> {BitDec.bitlist_deserialize(2n, [9]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c399() -> {BitDec.bitlist_deserialize(2n, [8]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c400() -> {BitDec.bitlist_deserialize(2n, [5]) == Some{[True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c401() -> {BitDec.bitlist_deserialize(2n, [7]) == Some{[True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c402() -> {BitDec.bitlist_deserialize(2n, [7, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c403() -> {BitDec.bitlist_deserialize(2n, [255, 255, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c404() -> {BitDec.bitlist_deserialize(3n, [2]) == Some{[False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c405() -> {BitDec.bitlist_deserialize(3n, [1, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c406() -> {BitDec.bitlist_deserialize(3n, [4, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c407() -> {BitDec.bitlist_deserialize(3n, [0, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c408() -> {BitDec.bitlist_deserialize(3n, [15, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c409() -> {BitDec.bitlist_deserialize(3n, [128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c410() -> {BitDec.bitlist_deserialize(3n, [4]) == Some{[False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c411() -> {BitDec.bitlist_deserialize(3n, [16]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c412() -> {BitDec.bitlist_deserialize(3n, [255, 255, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c413() -> {BitDec.bitlist_deserialize(3n, [33]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}
