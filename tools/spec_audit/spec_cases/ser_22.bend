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

def c107() -> {Codec.encoding_for_legal_type(F.Domain(), T.BytesValue{[142, 143, 55, 128, 209, 123, 108, 196, 180, 128, 47, 164, 215, 90, 161, 207, 143, 16, 6, 108, 107, 250, 230, 105, 70, 129, 19, 148, 187, 36, 153, 159]}) == Some{[142, 143, 55, 128, 209, 123, 108, 196, 180, 128, 47, 164, 215, 90, 161, 207, 143, 16, 6, 108, 107, 250, 230, 105, 70, 129, 19, 148, 187, 36, 153, 159]} : Maybe<&2, +List<U32>>}:
  {==}

def c108() -> {Codec.encoding_for_legal_type(F.Domain(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0]}) == Some{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c109() -> {Codec.encoding_for_legal_type(F.Domain(), T.BytesValue{[8, 120, 138, 198, 223, 118, 233, 176, 161, 14, 100, 40, 80, 217, 75, 76, 189, 46, 188, 145, 64, 0, 200, 155, 87, 185, 185, 81, 137, 23, 71, 90]}) == Some{[8, 120, 138, 198, 223, 118, 233, 176, 161, 14, 100, 40, 80, 217, 75, 76, 189, 46, 188, 145, 64, 0, 200, 155, 87, 185, 185, 81, 137, 23, 71, 90]} : Maybe<&2, +List<U32>>}:
  {==}

def c110() -> {Codec.encoding_for_legal_type(F.DomainType(), T.BytesValue{[128, 207, 170, 12]}) == Some{[128, 207, 170, 12]} : Maybe<&2, +List<U32>>}:
  {==}

def c111() -> {Codec.encoding_for_legal_type(F.DomainType(), T.BytesValue{[128, 118, 148, 155]}) == Some{[128, 118, 148, 155]} : Maybe<&2, +List<U32>>}:
  {==}

def c112() -> {Codec.encoding_for_legal_type(F.DomainType(), T.BytesValue{[254, 255, 255, 255]}) == Some{[254, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c113() -> {Codec.encoding_for_legal_type(F.Epoch(), T.UnsignedValue{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}}) == Some{[0, 1, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c114() -> {Codec.encoding_for_legal_type(F.Epoch(), T.UnsignedValue{P.UInt{0, 16711680, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 0, 0, 0, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c115() -> {Codec.encoding_for_legal_type(F.Epoch(), T.UnsignedValue{P.UInt{4294967295, 4286644223, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 128, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c116() -> {Codec.encoding_for_legal_type(F.Eth1Block(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]}, T.Items{T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}
