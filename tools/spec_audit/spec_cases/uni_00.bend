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

def c0() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}, T.Selected{0, T.NullValue{}}) == Some{[0]} : Maybe<&2, +List<U32>>}:
  {==}

def c1() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}, T.Selected{1, T.UnsignedValue{P.UInt{5, 0, 0, 0, 0, 0, 0, 0}}}) == Some{[1, 5, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c2() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}, T.Selected{2, T.UnsignedValue{P.UInt{7, 0, 0, 0, 0, 0, 0, 0}}}) == Some{[2, 7, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c3() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}, T.Selected{2, T.UnsignedValue{P.UInt{0, 1, 0, 0, 0, 0, 0, 0}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c4() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}, T.Selected{3, T.UnsignedValue{P.UInt{7, 0, 0, 0, 0, 0, 0, 0}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c5() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}, T.Selected{0, T.UnsignedValue{P.UInt{7, 0, 0, 0, 0, 0, 0, 0}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c6() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}, T.Selected{1, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c7() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}, T.Selected{255, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c8() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, T.Selected{127, T.BooleanValue{True{}}}) == Some{[127, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c9() -> {Codec.encoding_for_legal_type(T.Union{T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}, T.Selected{128, T.BooleanValue{True{}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}
