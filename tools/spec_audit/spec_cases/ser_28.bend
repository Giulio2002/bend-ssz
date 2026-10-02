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

def c140() -> {Codec.encoding_for_legal_type(G.FixedTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{32769, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{3736492405, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 1, 128, 0, 0, 0, 0, 0, 0, 117, 89, 182, 222]} : Maybe<&2, +List<U32>>}:
  {==}

def c141() -> {Codec.encoding_for_legal_type(G.FixedTestStruct(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{178, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{4286644223, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.UnsignedValue{P.UInt{2918869605, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[178, 255, 255, 128, 255, 255, 255, 255, 255, 101, 106, 250, 173]} : Maybe<&2, +List<U32>>}:
  {==}

def c142() -> {Codec.encoding_for_legal_type(F.Fork(), T.Sequence{T.Items{T.BytesValue{[0, 128, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0]}, T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c143() -> {Codec.encoding_for_legal_type(F.Fork(), T.Sequence{T.Items{T.BytesValue{[255, 255, 255, 255]}, T.Items{T.BytesValue{[255, 255, 255, 255]}, T.Items{T.UnsignedValue{P.UInt{4294967294, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c144() -> {Codec.encoding_for_legal_type(F.Fork(), T.Sequence{T.Items{T.BytesValue{[251, 15, 39, 118]}, T.Items{T.BytesValue{[181, 224, 13, 164]}, T.Items{T.UnsignedValue{P.UInt{4294967041, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[251, 15, 39, 118, 181, 224, 13, 164, 1, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c145() -> {Codec.encoding_for_legal_type(F.ForkData(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}) == Some{[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c146() -> {Codec.encoding_for_legal_type(F.ForkData(), T.Sequence{T.Items{T.BytesValue{[255, 178, 229, 115]}, T.Items{T.BytesValue{[173, 126, 198, 205, 106, 95, 156, 193, 116, 89, 139, 131, 41, 126, 5, 26, 154, 219, 102, 196, 180, 69, 149, 107, 43, 150, 28, 170, 93, 33, 84, 163]}, T.EmptyItems{}}}}) == Some{[255, 178, 229, 115, 173, 126, 198, 205, 106, 95, 156, 193, 116, 89, 139, 131, 41, 126, 5, 26, 154, 219, 102, 196, 180, 69, 149, 107, 43, 150, 28, 170, 93, 33, 84, 163]} : Maybe<&2, +List<U32>>}:
  {==}
