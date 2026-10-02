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

def c94() -> {Codec.encoding_for_legal_type(G.ComplexTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[255, 255, 255]}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}, T.Items{T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}, T.EmptyItems{}}}}}}, T.Items{T.Sequence{T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}, T.Items{T.Sequence{T.Items{T.UnsignedValue{P.UInt{65535, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.Sequence{T.EmptyItems{}}, T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}, T.EmptyItems{}}}}, T.EmptyItems{}}}}}}}}}) == Some{[255, 255, 71, 0, 0, 0, 255, 75, 0, 0, 0, 78, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 89, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 8, 0, 0, 0, 19, 0, 0, 0, 255, 255, 7, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 7, 0, 0, 0, 255]} : Maybe<&2, +List<U32>>}:
  {==}
