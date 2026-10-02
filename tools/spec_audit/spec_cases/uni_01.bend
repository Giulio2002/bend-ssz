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

def c10() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, T.Selected{0, T.BooleanValue{False{}}}) == Some{[0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c11() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.ByteList{3n}, T.Chain{T.Vector{T.Boolean{}, 2n}, T.End{}}}}, T.Selected{0, T.BytesValue{[9, 8]}}) == Some{[0, 9, 8]} : Maybe<&2, +List<U32>>}:
  {==}

def c12() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.ByteList{3n}, T.Chain{T.Vector{T.Boolean{}, 2n}, T.End{}}}}, T.Selected{0, T.BytesValue{[]}}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c13() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.ByteList{3n}, T.Chain{T.Vector{T.Boolean{}, 2n}, T.End{}}}}, T.Selected{0, T.BytesValue{[1, 2, 3, 4]}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c14() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.ByteList{3n}, T.Chain{T.Vector{T.Boolean{}, 2n}, T.End{}}}}, T.Selected{1, T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}) == Some{[1, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}
