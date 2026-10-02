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

def c564() -> {BitDec.bitvector_deserialize(17n, [0, 96, 0]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c565() -> {BitDec.bitvector_deserialize(17n, [158, 131, 0]) == Some{[False{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, True{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c566() -> {BitDec.bitvector_deserialize(17n, [19, 31]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c567() -> {BitDec.bitvector_deserialize(17n, [0, 19, 31, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c568() -> {BitDec.bitvector_deserialize(17n, [19, 31, 128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c569() -> {BitDec.bitvector_deserialize(17n, [79, 1, 0]) == Some{[True{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c570() -> {BitDec.bitvector_deserialize(17n, [158, 130, 255]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c571() -> {BitDec.bitvector_deserialize(17n, [0, 128, 0]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c572() -> {BitDec.bitvector_deserialize(17n, [0, 255, 0]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c573() -> {BitDec.bitvector_deserialize(17n, [158, 130, 1]) == Some{[False{}, True{}, True{}, True{}, True{}, False{}, False{}, True{}, False{}, True{}, False{}, False{}, False{}, False{}, False{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c574() -> {BitDec.bitvector_deserialize(2n, [3, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c575() -> {BitDec.bitvector_deserialize(2n, []) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c576() -> {BitDec.bitvector_deserialize(2n, [255]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c577() -> {BitDec.bitvector_deserialize(2n, [128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c578() -> {BitDec.bitvector_deserialize(2n, [2, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c579() -> {BitDec.bitvector_deserialize(2n, [4]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c580() -> {BitDec.bitvector_deserialize(2n, [1, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c581() -> {BitDec.bitvector_deserialize(2n, [0]) == Some{[False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c582() -> {BitDec.bitvector_deserialize(2n, [0, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c583() -> {BitDec.bitvector_deserialize(2n, [2]) == Some{[False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c584() -> {BitDec.bitvector_deserialize(3n, [255]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c585() -> {BitDec.bitvector_deserialize(3n, [0, 7]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c586() -> {BitDec.bitvector_deserialize(3n, [0, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c587() -> {BitDec.bitvector_deserialize(3n, [8]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c588() -> {BitDec.bitvector_deserialize(3n, [5, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}
