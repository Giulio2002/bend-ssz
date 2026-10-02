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

def c845() -> {Codec.encoding_for_legal_type(G.vec_uint256_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4278190079}}, T.EmptyItems{}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254]} : Maybe<&2, +List<U32>>}:
  {==}

def c846() -> {Codec.encoding_for_legal_type(G.vec_uint256_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{5961939, 3441566412, 2901352679, 2282426558, 2650979599, 3326274513, 3644139740, 1389547488}}, T.EmptyItems{}}}) == Some{[211, 248, 90, 0, 204, 34, 34, 205, 231, 32, 239, 172, 190, 16, 11, 136, 15, 189, 2, 158, 209, 235, 66, 198, 220, 40, 53, 217, 224, 207, 210, 82]} : Maybe<&2, +List<U32>>}:
  {==}

def c847() -> {Codec.encoding_for_legal_type(G.vec_uint256_1(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{2611377053, 856005457, 369226311, 2683226876, 1968016228, 3902230298, 2459542920, 1934904590}}, T.EmptyItems{}}}) == Some{[157, 115, 166, 155, 81, 155, 5, 51, 71, 242, 1, 22, 252, 202, 238, 159, 100, 139, 77, 117, 26, 79, 151, 232, 136, 165, 153, 146, 14, 77, 84, 115]} : Maybe<&2, +List<U32>>}:
  {==}

def c848() -> {Codec.encoding_for_legal_type(G.vec_uint256_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.EmptyItems{}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c849() -> {Codec.encoding_for_legal_type(G.vec_uint256_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3321427257, 2128379651, 2922103036, 2492823365, 2583306894, 1953118671, 4251960369, 1061241}}, T.EmptyItems{}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 245, 248, 197, 3, 127, 220, 126, 252, 192, 43, 174, 69, 119, 149, 148, 142, 34, 250, 153, 207, 57, 106, 116, 49, 196, 111, 253, 121, 49, 16, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c850() -> {Codec.encoding_for_legal_type(G.vec_uint256_2(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.Items{T.UnsignedValue{P.UInt{4294967040, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
