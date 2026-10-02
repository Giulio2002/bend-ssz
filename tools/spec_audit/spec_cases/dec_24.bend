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

def c491() -> {BitDec.bitlist_deserialize(513n, [80, 1]) == Some{[False{}, False{}, False{}, False{}, True{}, False{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c492() -> {BitDec.bitlist_deserialize(513n, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c493() -> {BitDec.bitlist_deserialize(513n, [0, 0, 1]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c494() -> {BitDec.bitlist_deserialize(6n, [56]) == Some{[False{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c495() -> {BitDec.bitlist_deserialize(6n, [0, 32]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c496() -> {BitDec.bitlist_deserialize(6n, [14]) == Some{[False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c497() -> {BitDec.bitlist_deserialize(6n, [3, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c498() -> {BitDec.bitlist_deserialize(6n, [32, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c499() -> {BitDec.bitlist_deserialize(6n, [0, 0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c500() -> {BitDec.bitlist_deserialize(6n, [4, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c501() -> {BitDec.bitlist_deserialize(6n, [57, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c502() -> {BitDec.bitlist_deserialize(6n, [57, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c503() -> {BitDec.bitlist_deserialize(6n, [128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c504() -> {BitDec.bitlist_deserialize(7n, [4, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c505() -> {BitDec.bitlist_deserialize(7n, [26]) == Some{[False{}, True{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c506() -> {BitDec.bitlist_deserialize(7n, [4, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c507() -> {BitDec.bitlist_deserialize(7n, [1]) == Some{[]} : Maybe<&2, +List<Bool>>}:
  {==}

def c508() -> {BitDec.bitlist_deserialize(7n, [2, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c509() -> {BitDec.bitlist_deserialize(7n, [0, 7]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c510() -> {BitDec.bitlist_deserialize(7n, [83]) == Some{[True{}, True{}, False{}, False{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c511() -> {BitDec.bitlist_deserialize(7n, [7, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c512() -> {BitDec.bitlist_deserialize(7n, [0, 4]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c513() -> {BitDec.bitlist_deserialize(7n, [2, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}
