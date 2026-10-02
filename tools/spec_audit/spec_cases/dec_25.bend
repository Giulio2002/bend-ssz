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

def c514() -> {BitDec.bitlist_deserialize(8n, [238, 1]) == Some{[False{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c515() -> {BitDec.bitlist_deserialize(8n, [0, 1]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c516() -> {BitDec.bitlist_deserialize(8n, [0, 11]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c517() -> {BitDec.bitlist_deserialize(8n, [14]) == Some{[False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c518() -> {BitDec.bitlist_deserialize(8n, [255, 255, 255, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c519() -> {BitDec.bitlist_deserialize(8n, [4]) == Some{[False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c520() -> {BitDec.bitlist_deserialize(8n, [0, 0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c521() -> {BitDec.bitlist_deserialize(8n, [255, 1]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c522() -> {BitDec.bitlist_deserialize(8n, [0, 179, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c523() -> {BitDec.bitlist_deserialize(8n, [7]) == Some{[True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c524() -> {BitDec.bitlist_deserialize(9n, [197, 1]) == Some{[True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c525() -> {BitDec.bitlist_deserialize(9n, [2]) == Some{[False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c526() -> {BitDec.bitlist_deserialize(9n, [128, 3]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c527() -> {BitDec.bitlist_deserialize(9n, [239, 3, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c528() -> {BitDec.bitlist_deserialize(9n, [2, 1]) == Some{[False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c529() -> {BitDec.bitlist_deserialize(9n, [1, 8]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c530() -> {BitDec.bitlist_deserialize(9n, [239, 1]) == Some{[True{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c531() -> {BitDec.bitlist_deserialize(9n, [0, 5]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c532() -> {BitDec.bitlist_deserialize(9n, [197, 2]) == Some{[True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c533() -> {BitDec.bitlist_deserialize(9n, [14]) == Some{[False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c534() -> {BitDec.bitvector_deserialize(1n, [255]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c535() -> {BitDec.bitvector_deserialize(1n, [1]) == Some{[True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c536() -> {BitDec.bitvector_deserialize(1n, [128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c537() -> {BitDec.bitvector_deserialize(1n, []) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c538() -> {BitDec.bitvector_deserialize(1n, [1, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}
