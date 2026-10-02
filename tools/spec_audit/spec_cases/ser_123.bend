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

def c684() -> {Codec.encoding_for_legal_type(G.vec_bool_2(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}) == Some{[1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c685() -> {Codec.encoding_for_legal_type(G.vec_bool_2(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}) == Some{[0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c686() -> {Codec.encoding_for_legal_type(G.vec_bool_2(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}) == Some{[0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c687() -> {Codec.encoding_for_legal_type(G.vec_bool_2(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}) == Some{[1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c688() -> {Codec.encoding_for_legal_type(G.vec_bool_3(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}) == Some{[0, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c689() -> {Codec.encoding_for_legal_type(G.vec_bool_3(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}) == Some{[0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c690() -> {Codec.encoding_for_legal_type(G.vec_bool_3(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}) == Some{[1, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c691() -> {Codec.encoding_for_legal_type(G.vec_bool_3(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}) == Some{[0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c692() -> {Codec.encoding_for_legal_type(G.vec_bool_3(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}) == Some{[1, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c693() -> {Codec.encoding_for_legal_type(G.vec_bool_3(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}) == Some{[1, 1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c694() -> {Codec.encoding_for_legal_type(G.vec_bool_3(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}) == Some{[1, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}
