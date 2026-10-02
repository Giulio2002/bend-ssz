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

def c704() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}}) == Some{[1, 0, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c705() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}}) == Some{[1, 1, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c706() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}}) == Some{[1, 1, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c707() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}) == Some{[1, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c708() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}}) == Some{[0, 1, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c709() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c710() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c711() -> {Codec.encoding_for_legal_type(G.vec_bool_4(), T.Sequence{T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{True{}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c712() -> {Codec.encoding_for_legal_type(G.vec_bool_5(), T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}}}) == Some{[1, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
