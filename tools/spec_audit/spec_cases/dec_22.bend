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

def c464() -> {BitDec.bitlist_deserialize(511n, [1]) == Some{[]} : Maybe<&2, +List<Bool>>}:
  {==}

def c465() -> {BitDec.bitlist_deserialize(511n, [114, 255]) == Some{[False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c466() -> {BitDec.bitlist_deserialize(511n, [0, 3]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c467() -> {BitDec.bitlist_deserialize(511n, [0, 114, 11]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c468() -> {BitDec.bitlist_deserialize(511n, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c469() -> {BitDec.bitlist_deserialize(511n, [2, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c470() -> {BitDec.bitlist_deserialize(511n, [128, 11]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c471() -> {BitDec.bitlist_deserialize(511n, [1, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c472() -> {BitDec.bitlist_deserialize(511n, [6]) == Some{[False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c473() -> {BitDec.bitlist_deserialize(511n, [1, 11]) == Some{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c474() -> {BitDec.bitlist_deserialize(512n, [80, 128]) == Some{[False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c475() -> {BitDec.bitlist_deserialize(512n, [221, 255]) == Some{[True{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c476() -> {BitDec.bitlist_deserialize(512n, [0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c477() -> {BitDec.bitlist_deserialize(512n, [0, 80, 183]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}, True{}, True{}, True{}, False{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c478() -> {BitDec.bitlist_deserialize(512n, [15, 1]) == Some{[True{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}
