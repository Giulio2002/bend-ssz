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

def c277() -> {Codec.encoding_for_legal_type(F.Validator(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BooleanValue{False{}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 256, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c278() -> {Codec.encoding_for_legal_type(F.Validator(), T.Sequence{T.Items{T.BytesValue{[176, 254, 30, 210, 230, 166, 103, 173, 21, 167, 48, 253, 29, 176, 177, 38, 169, 143, 134, 199, 6, 110, 210, 217, 217, 183, 110, 225, 141, 195, 22, 176, 69, 252, 28, 148, 33, 103, 197, 17, 129, 207, 183, 150, 54, 193, 31, 112]}, T.Items{T.BytesValue{[122, 163, 253, 23, 17, 22, 1, 176, 21, 202, 144, 209, 245, 150, 18, 193, 71, 0, 182, 122, 115, 153, 102, 244, 137, 52, 245, 119, 109, 150, 105, 45]}, T.Items{T.UnsignedValue{P.UInt{830765926, 1391351180, 0, 0, 0, 0, 0, 0}}, T.Items{T.BooleanValue{True{}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2645690922, 46995633, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{402262160, 3358333350, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}}}}}) == Some{[176, 254, 30, 210, 230, 166, 103, 173, 21, 167, 48, 253, 29, 176, 177, 38, 169, 143, 134, 199, 6, 110, 210, 217, 217, 183, 110, 225, 141, 195, 22, 176, 69, 252, 28, 148, 33, 103, 197, 17, 129, 207, 183, 150, 54, 193, 31, 112, 122, 163, 253, 23, 17, 22, 1, 176, 21, 202, 144, 209, 245, 150, 18, 193, 71, 0, 182, 122, 115, 153, 102, 244, 137, 52, 245, 119, 109, 150, 105, 45, 102, 123, 132, 49, 140, 85, 238, 82, 1, 0, 0, 0, 0, 0, 0, 0, 0, 42, 10, 178, 157, 177, 24, 205, 2, 0, 1, 0, 0, 0, 0, 0, 0, 144, 8, 250, 23, 166, 25, 44, 200]} : Maybe<&2, +List<U32>>}:
  {==}
