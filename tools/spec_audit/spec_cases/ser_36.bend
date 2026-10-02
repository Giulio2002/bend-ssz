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

def c184() -> {Codec.encoding_for_legal_type(F.PendingConsolidation(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{239914047, 3134718076, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[63, 204, 76, 14, 124, 0, 216, 186, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c185() -> {Codec.encoding_for_legal_type(F.PendingConsolidation(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{239914047, 3134768508, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294902015, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[63, 204, 76, 14, 124, 197, 216, 186, 255, 255, 255, 255, 255, 0, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c186() -> {Codec.encoding_for_legal_type(F.PendingConsolidation(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{243321919, 3134768508, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[63, 204, 128, 14, 124, 197, 216, 186, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c187() -> {Codec.encoding_for_legal_type(F.PendingPartialWithdrawal(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4043044259, 2280941175, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3221289985, 3655026363, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[163, 245, 251, 240, 119, 102, 244, 135, 0, 0, 0, 0, 0, 0, 0, 0, 1, 252, 0, 192, 187, 70, 219, 217]} : Maybe<&2, +List<U32>>}:
  {==}

def c188() -> {Codec.encoding_for_legal_type(F.PendingPartialWithdrawal(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 255, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[1, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c189() -> {Codec.encoding_for_legal_type(F.PendingPartialWithdrawal(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294902271, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c190() -> {Codec.encoding_for_legal_type(F.PowBlock(), T.Sequence{T.Items{T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]}, T.Items{T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
