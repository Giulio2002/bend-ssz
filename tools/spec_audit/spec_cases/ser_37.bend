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

def c191() -> {Codec.encoding_for_legal_type(F.PowBlock(), T.Sequence{T.Items{T.BytesValue{[185, 230, 99, 89, 224, 136, 120, 60, 44, 207, 181, 109, 238, 17, 188, 177, 212, 93, 227, 68, 196, 70, 215, 131, 250, 56, 44, 116, 74, 223, 245, 4]}, T.Items{T.BytesValue{[88, 68, 143, 178, 172, 227, 196, 240, 159, 24, 242, 144, 238, 60, 237, 187, 3, 157, 8, 48, 85, 109, 114, 229, 134, 132, 69, 95, 131, 71, 118, 199]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 8388608, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[185, 230, 99, 89, 224, 136, 120, 60, 44, 207, 181, 109, 238, 17, 188, 177, 212, 93, 227, 68, 196, 70, 215, 131, 250, 56, 44, 116, 74, 223, 245, 4, 88, 68, 143, 178, 172, 227, 196, 240, 159, 24, 242, 144, 238, 60, 237, 187, 3, 157, 8, 48, 85, 109, 114, 229, 134, 132, 69, 95, 131, 71, 118, 199, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c192() -> {Codec.encoding_for_legal_type(F.PowBlock(), T.Sequence{T.Items{T.BytesValue{[3, 13, 168, 158, 121, 88, 255, 160, 95, 75, 65, 135, 219, 57, 170, 177, 228, 185, 123, 202, 248, 98, 71, 100, 28, 206, 10, 163, 97, 66, 75, 5]}, T.Items{T.BytesValue{[86, 56, 153, 204, 155, 164, 240, 80, 225, 101, 10, 231, 100, 10, 210, 71, 50, 72, 161, 45, 177, 157, 36, 184, 193, 65, 148, 227, 135, 45, 248, 13]}, T.Items{T.UnsignedValue{P.UInt{1151561553, 91658071, 1201233683, 2473382102, 2517023474, 4221609636, 514422528, 2210613051}}, T.EmptyItems{}}}}}) == Some{[3, 13, 168, 158, 121, 88, 255, 160, 95, 75, 65, 135, 219, 57, 170, 177, 228, 185, 123, 202, 248, 98, 71, 100, 28, 206, 10, 163, 97, 66, 75, 5, 86, 56, 153, 204, 155, 164, 240, 80, 225, 101, 10, 231, 100, 10, 210, 71, 50, 72, 161, 45, 177, 157, 36, 184, 193, 65, 148, 227, 135, 45, 248, 13, 81, 111, 163, 68, 87, 151, 118, 5, 19, 95, 153, 71, 214, 208, 108, 147, 242, 186, 6, 150, 164, 166, 160, 251, 0, 119, 169, 30, 59, 71, 195, 131]} : Maybe<&2, +List<U32>>}:
  {==}

def c193() -> {Codec.encoding_for_legal_type(G.ProgressiveComplexTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}, T.Items{T.BitsValue{[False{}, True{}, False{}, True{}, False{}, False{}, False{}, True{}, True{}, True{}]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{24325, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.EmptyItems{}}}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{247, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}, T.EmptyItems{}}}}}, T.Items{T.Sequence{T.EmptyItems{}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 29, 0, 0, 0, 35, 0, 0, 0, 37, 0, 0, 0, 53, 0, 0, 0, 61, 0, 0, 0, 61, 0, 0, 0, 64, 0, 0, 0, 0, 0, 255, 255, 255, 255, 138, 7, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 5, 95, 0, 0, 0, 255, 247]} : Maybe<&2, +List<U32>>}:
  {==}
