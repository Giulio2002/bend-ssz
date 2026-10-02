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

def c18() -> {Codec.encoding_for_legal_type(G.BitsStruct(), T.Sequence{T.Items{T.BitsValue{[True{}, True{}, True{}, True{}]}, T.Items{T.BitsValue{[False{}, False{}]}, T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[]}, T.Items{T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}}) == Some{[11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 31, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c19() -> {Codec.encoding_for_legal_type(G.BitsStruct(), T.Sequence{T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[False{}, False{}]}, T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[]}, T.Items{T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}}) == Some{[11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 1, 2, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c20() -> {Codec.encoding_for_legal_type(G.BitsStruct(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}]}, T.Items{T.BitsValue{[False{}, False{}]}, T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[]}, T.Items{T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}}) == Some{[11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 4, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c21() -> {Codec.encoding_for_legal_type(G.BitsStruct(), T.Sequence{T.Items{T.BitsValue{[]}, T.Items{T.BitsValue{[True{}, False{}]}, T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[]}, T.Items{T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}}) == Some{[11, 0, 0, 0, 1, 0, 12, 0, 0, 0, 0, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c22() -> {Codec.encoding_for_legal_type(G.BitsStruct(), T.Sequence{T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[True{}, False{}]}, T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[]}, T.Items{T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}}) == Some{[11, 0, 0, 0, 1, 0, 12, 0, 0, 0, 0, 2, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c23() -> {Codec.encoding_for_legal_type(F.BlobIdentifier(), T.Sequence{T.Items{T.BytesValue{[159, 240, 185, 143, 57, 83, 244, 234, 212, 47, 77, 119, 202, 19, 187, 102, 220, 82, 86, 213, 87, 52, 126, 10, 40, 199, 178, 129, 83, 54, 214, 17]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[159, 240, 185, 143, 57, 83, 244, 234, 212, 47, 77, 119, 202, 19, 187, 102, 220, 82, 86, 213, 87, 52, 126, 10, 40, 199, 178, 129, 83, 54, 214, 17, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}
