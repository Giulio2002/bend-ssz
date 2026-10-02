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

def c674() -> {BitDec.bitvector_deserialize(6n, [64]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c675() -> {BitDec.bitvector_deserialize(6n, [55, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c676() -> {BitDec.bitvector_deserialize(6n, [128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c677() -> {BitDec.bitvector_deserialize(6n, [55]) == Some{[True{}, True{}, True{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c678() -> {BitDec.bitvector_deserialize(6n, [63, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c679() -> {BitDec.bitvector_deserialize(6n, [0]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c680() -> {BitDec.bitvector_deserialize(6n, [42]) == Some{[False{}, True{}, False{}, True{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c681() -> {BitDec.bitvector_deserialize(6n, [63, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c682() -> {BitDec.bitvector_deserialize(6n, [37, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c683() -> {BitDec.bitvector_deserialize(6n, [255]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c684() -> {BitDec.bitvector_deserialize(7n, [55]) == Some{[True{}, True{}, True{}, False{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c685() -> {BitDec.bitvector_deserialize(7n, [127, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c686() -> {BitDec.bitvector_deserialize(7n, [124]) == Some{[False{}, False{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c687() -> {BitDec.bitvector_deserialize(7n, [128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c688() -> {BitDec.bitvector_deserialize(7n, [127]) == Some{[True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c689() -> {BitDec.bitvector_deserialize(7n, [125]) == Some{[True{}, False{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c690() -> {BitDec.bitvector_deserialize(7n, [124, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c691() -> {BitDec.bitvector_deserialize(7n, [1]) == Some{[True{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c692() -> {BitDec.bitvector_deserialize(7n, [0, 127]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c693() -> {BitDec.bitvector_deserialize(7n, [0]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c694() -> {BitDec.bitvector_deserialize(8n, [0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c695() -> {BitDec.bitvector_deserialize(8n, [0, 255]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c696() -> {BitDec.bitvector_deserialize(8n, [0, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c697() -> {BitDec.bitvector_deserialize(8n, [95]) == Some{[True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c698() -> {BitDec.bitvector_deserialize(8n, [0, 149]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}
