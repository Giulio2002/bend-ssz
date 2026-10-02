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

def c14() -> {Codec.encoding_for_legal_type(F.BeaconBlockHeader(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[229, 232, 81, 209, 132, 253, 218, 102, 110, 180, 87, 181, 228, 177, 12, 254, 86, 108, 197, 29, 246, 28, 244, 156, 206, 234, 71, 0, 107, 191, 176, 212]}, T.Items{T.BytesValue{[174, 75, 215, 218, 196, 113, 3, 116, 241, 224, 138, 182, 7, 153, 214, 83, 204, 88, 181, 242, 197, 121, 169, 226, 44, 119, 96, 4, 36, 235, 221, 63]}, T.Items{T.BytesValue{[90, 252, 103, 127, 237, 166, 162, 116, 28, 223, 115, 173, 243, 192, 40, 69, 49, 218, 80, 94, 223, 91, 54, 254, 143, 31, 76, 25, 45, 193, 15, 85]}, T.EmptyItems{}}}}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 229, 232, 81, 209, 132, 253, 218, 102, 110, 180, 87, 181, 228, 177, 12, 254, 86, 108, 197, 29, 246, 28, 244, 156, 206, 234, 71, 0, 107, 191, 176, 212, 174, 75, 215, 218, 196, 113, 3, 116, 241, 224, 138, 182, 7, 153, 214, 83, 204, 88, 181, 242, 197, 121, 169, 226, 44, 119, 96, 4, 36, 235, 221, 63, 90, 252, 103, 127, 237, 166, 162, 116, 28, 223, 115, 173, 243, 192, 40, 69, 49, 218, 80, 94, 223, 91, 54, 254, 143, 31, 76, 25, 45, 193, 15, 85]} : Maybe<&2, +List<U32>>}:
  {==}

def c15() -> {Codec.encoding_for_legal_type(G.BitsStruct(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}]}, T.Items{T.BitsValue{[True{}, False{}]}, T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[False{}, False{}, False{}, False{}]}, T.Items{T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}}) == Some{[11, 0, 0, 0, 1, 0, 12, 0, 0, 0, 0, 4, 16]} : Maybe<&2, +List<U32>>}:
  {==}

def c16() -> {Codec.encoding_for_legal_type(G.BitsStruct(), T.Sequence{T.Items{T.BitsValue{[]}, T.Items{T.BitsValue{[False{}, False{}]}, T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[]}, T.Items{T.BitsValue{[True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}, T.EmptyItems{}}}}}}}) == Some{[11, 0, 0, 0, 0, 0, 12, 0, 0, 0, 1, 1, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c17() -> {Codec.encoding_for_legal_type(G.BitsStruct(), T.Sequence{T.Items{T.BitsValue{[False{}, False{}]}, T.Items{T.BitsValue{[True{}, False{}]}, T.Items{T.BitsValue{[False{}]}, T.Items{T.BitsValue{[False{}, False{}, False{}, False{}]}, T.Items{T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}, T.EmptyItems{}}}}}}}) == Some{[11, 0, 0, 0, 1, 0, 12, 0, 0, 0, 255, 4, 16]} : Maybe<&2, +List<U32>>}:
  {==}
