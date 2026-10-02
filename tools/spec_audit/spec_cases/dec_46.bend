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

def c699() -> {BitDec.bitvector_deserialize(8n, [121, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c700() -> {BitDec.bitvector_deserialize(8n, [121]) == Some{[True{}, False{}, False{}, True{}, True{}, True{}, True{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c701() -> {BitDec.bitvector_deserialize(8n, [0]) == Some{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c702() -> {BitDec.bitvector_deserialize(8n, [94, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c703() -> {BitDec.bitvector_deserialize(8n, [255, 1]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c704() -> {BitDec.bitvector_deserialize(9n, [3, 1]) == Some{[True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c705() -> {BitDec.bitvector_deserialize(9n, [95, 0]) == Some{[True{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c706() -> {BitDec.bitvector_deserialize(9n, [0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c707() -> {BitDec.bitvector_deserialize(9n, [254, 1]) == Some{[False{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c708() -> {BitDec.bitvector_deserialize(9n, [3, 128]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c709() -> {BitDec.bitvector_deserialize(9n, [0, 0, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c710() -> {BitDec.bitvector_deserialize(9n, [3, 0]) == Some{[True{}, True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c711() -> {BitDec.bitvector_deserialize(9n, [1, 1]) == Some{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c712() -> {BitDec.bitvector_deserialize(9n, [0, 3, 0]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}

def c713() -> {BitDec.bitvector_deserialize(9n, [94, 1]) == Some{[False{}, True{}, True{}, True{}, True{}, False{}, True{}, False{}, True{}]} : Maybe<&2, +List<Bool>>}:
  {==}

def c714() -> {Prim.boolean_decoding([2]) == None{} : Maybe<&2, Bool>}:
  {==}

def c715() -> {Prim.boolean_decoding([]) == None{} : Maybe<&2, Bool>}:
  {==}

def c716() -> {Prim.boolean_decoding([1]) == Some{True{}} : Maybe<&2, Bool>}:
  {==}

def c717() -> {Prim.boolean_decoding([255]) == None{} : Maybe<&2, Bool>}:
  {==}

def c718() -> {Prim.boolean_decoding([1, 1]) == None{} : Maybe<&2, Bool>}:
  {==}

def c719() -> {Prim.boolean_decoding([1, 0]) == None{} : Maybe<&2, Bool>}:
  {==}

def c720() -> {Prim.boolean_decoding([0, 0]) == None{} : Maybe<&2, Bool>}:
  {==}

def c721() -> {Prim.boolean_decoding([128]) == None{} : Maybe<&2, Bool>}:
  {==}

def c722() -> {Prim.boolean_decoding([0]) == Some{False{}} : Maybe<&2, Bool>}:
  {==}

def c723() -> {Prim.boolean_decoding([0, 1]) == None{} : Maybe<&2, Bool>}:
  {==}
