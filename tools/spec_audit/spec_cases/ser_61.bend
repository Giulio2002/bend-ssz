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

def c296() -> {Codec.encoding_for_legal_type(F.VoluntaryExit(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4124438015, 2519592638, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 237, 213, 245, 190, 238, 45, 150, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c297() -> {Codec.encoding_for_legal_type(F.VoluntaryExit(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 65280, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c298() -> {Codec.encoding_for_legal_type(F.VoluntaryExit(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{16711681, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 1, 0, 255, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c299() -> {Codec.encoding_for_legal_type(F.Withdrawal(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[73, 117, 234, 215, 189, 92, 115, 146, 13, 164, 75, 120, 140, 144, 229, 60, 89, 137, 78, 1]}, T.Items{T.UnsignedValue{P.UInt{4294967295, 33554431, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 73, 117, 234, 215, 189, 92, 115, 146, 13, 164, 75, 120, 140, 144, 229, 60, 89, 137, 78, 1, 255, 255, 255, 255, 255, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c300() -> {Codec.encoding_for_legal_type(F.Withdrawal(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.UnsignedValue{P.UInt{0, 8388608, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c301() -> {Codec.encoding_for_legal_type(F.Withdrawal(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2288354510, 3857216061, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[120, 132, 207, 13, 232, 169, 211, 214, 206, 80, 84, 136, 170, 190, 172, 208, 62, 83, 100, 103]}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 206, 132, 101, 136, 61, 114, 232, 229, 120, 132, 207, 13, 232, 169, 211, 214, 206, 80, 84, 136, 170, 190, 172, 208, 62, 83, 100, 103, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
