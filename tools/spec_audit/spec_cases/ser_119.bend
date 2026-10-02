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

def c651() -> {Codec.encoding_for_legal_type(G.uint128(), T.UnsignedValue{P.UInt{341835762, 2654317095, 202617631, 3754497792, 0, 0, 0, 0}}) == Some{[242, 255, 95, 20, 39, 170, 53, 158, 31, 179, 19, 12, 0, 23, 201, 223]} : Maybe<&2, +List<U32>>}:
  {==}

def c652() -> {Codec.encoding_for_legal_type(G.uint128(), T.UnsignedValue{P.UInt{4278255615, 4294967295, 4294967295, 4294967295, 0, 0, 0, 0}}) == Some{[255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c653() -> {Codec.encoding_for_legal_type(G.uint128(), T.UnsignedValue{P.UInt{4294967295, 2164260863, 4294967295, 4294967295, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 128, 255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c654() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{19708, 0, 0, 0, 0, 0, 0, 0}}) == Some{[252, 76]} : Maybe<&2, +List<U32>>}:
  {==}

def c655() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{128, 0, 0, 0, 0, 0, 0, 0}}) == Some{[128, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c656() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{65281, 0, 0, 0, 0, 0, 0, 0}}) == Some{[1, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c657() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{32768, 0, 0, 0, 0, 0, 0, 0}}) == Some{[0, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c658() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{32769, 0, 0, 0, 0, 0, 0, 0}}) == Some{[1, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c659() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{509, 0, 0, 0, 0, 0, 0, 0}}) == Some{[253, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c660() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c661() -> {Codec.encoding_for_legal_type(G.uint16(), T.UnsignedValue{P.UInt{65280, 0, 0, 0, 0, 0, 0, 0}}) == Some{[0, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c662() -> {Codec.encoding_for_legal_type(F.uint256(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4278321151}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 255]} : Maybe<&2, +List<U32>>}:
  {==}
