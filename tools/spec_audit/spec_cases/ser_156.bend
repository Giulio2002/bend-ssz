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

def c839() -> {Codec.encoding_for_legal_type(G.vec_uint16_8(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{33023, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 128, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c840() -> {Codec.encoding_for_legal_type(G.vec_uint256_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2611377053, 856005457, 370471751, 2683226876, 1968016228, 3902230298, 2459542920, 1934904590}}, T.EmptyItems{}}}) == Some{[157, 115, 166, 155, 81, 155, 5, 51, 71, 243, 20, 22, 252, 202, 238, 159, 100, 139, 77, 117, 26, 79, 151, 232, 136, 165, 153, 146, 14, 77, 84, 115]} : Maybe<&2, +List<U32>>}:
  {==}

def c841() -> {Codec.encoding_for_legal_type(G.vec_uint256_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2790979795, 3441566412, 2901352679, 2282426558, 2650979599, 3326274513, 3644139740, 1389547264}}, T.EmptyItems{}}}) == Some{[211, 248, 90, 166, 204, 34, 34, 205, 231, 32, 239, 172, 190, 16, 11, 136, 15, 189, 2, 158, 209, 235, 66, 198, 220, 40, 53, 217, 0, 207, 210, 82]} : Maybe<&2, +List<U32>>}:
  {==}

def c842() -> {Codec.encoding_for_legal_type(G.vec_uint256_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 16711680, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c843() -> {Codec.encoding_for_legal_type(G.vec_uint256_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 4278190080, 0, 0, 0, 0}}, T.EmptyItems{}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c844() -> {Codec.encoding_for_legal_type(G.vec_uint256_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2790979795, 3441566412, 2901352679, 2282426558, 2650979839, 3326274513, 3644139740, 1389547488}}, T.EmptyItems{}}}) == Some{[211, 248, 90, 166, 204, 34, 34, 205, 231, 32, 239, 172, 190, 16, 11, 136, 255, 189, 2, 158, 209, 235, 66, 198, 220, 40, 53, 217, 224, 207, 210, 82]} : Maybe<&2, +List<U32>>}:
  {==}
