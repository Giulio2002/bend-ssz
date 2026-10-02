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

def c55() -> {Codec.encoding_for_legal_type(F.Checkpoint(), T.Sequence{T.Items{T.UnsignedValue{P.UInt{1, 0, 0, 0, 0, 0, 0, 0}}, T.Items{T.BytesValue{[180, 62, 106, 132, 128, 179, 169, 211, 93, 76, 140, 6, 253, 217, 133, 214, 5, 171, 225, 170, 122, 14, 159, 194, 79, 157, 88, 220, 195, 76, 53, 177]}, T.EmptyItems{}}}}) == Some{[1, 0, 0, 0, 0, 0, 0, 0, 180, 62, 106, 132, 128, 179, 169, 211, 93, 76, 140, 6, 253, 217, 133, 214, 5, 171, 225, 170, 122, 14, 159, 194, 79, 157, 88, 220, 195, 76, 53, 177]} : Maybe<&2, +List<U32>>}:
  {==}

def c56() -> {Codec.encoding_for_legal_type(F.ColumnIndex(), T.UnsignedValue{P.UInt{1, 16711680, 0, 0, 0, 0, 0, 0}}) == Some{[1, 0, 0, 0, 0, 0, 255, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c57() -> {Codec.encoding_for_legal_type(F.ColumnIndex(), T.UnsignedValue{P.UInt{2147483648, 0, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 128, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c58() -> {Codec.encoding_for_legal_type(F.ColumnIndex(), T.UnsignedValue{P.UInt{1, 32768, 0, 0, 0, 0, 0, 0}}) == Some{[1, 0, 0, 0, 0, 128, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c59() -> {Codec.encoding_for_legal_type(F.CommitmentIndex(), T.UnsignedValue{P.UInt{4294967295, 33554431, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 1]} : Maybe<&2, +List<U32>>}:
  {==}

def c60() -> {Codec.encoding_for_legal_type(F.CommitmentIndex(), T.UnsignedValue{P.UInt{32768, 0, 0, 0, 0, 0, 0, 0}}) == Some{[0, 128, 0, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c61() -> {Codec.encoding_for_legal_type(F.CommitmentIndex(), T.UnsignedValue{P.UInt{16711681, 0, 0, 0, 0, 0, 0, 0}}) == Some{[1, 0, 255, 0, 0, 0, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c62() -> {Codec.encoding_for_legal_type(F.CommitteeIndex(), T.UnsignedValue{P.UInt{29189958, 4177675520, 0, 0, 0, 0, 0, 0}}) == Some{[70, 103, 189, 1, 0, 69, 2, 249]} : Maybe<&2, +List<U32>>}:
  {==}

def c63() -> {Codec.encoding_for_legal_type(F.CommitteeIndex(), T.UnsignedValue{P.UInt{4294967039, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 254, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c64() -> {Codec.encoding_for_legal_type(F.CommitteeIndex(), T.UnsignedValue{P.UInt{0, 65280, 0, 0, 0, 0, 0, 0}}) == Some{[0, 0, 0, 0, 0, 255, 0, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c65() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{0, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 0]} : Maybe<&2, +List<U32>>}:
  {==}

def c66() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{1, T.Sequence{T.Items{T.UnsignedValue{P.UInt{62, 0, 0, 0, 0, 0, 0, 0}}, T.EmptyItems{}}}}) == Some{[1, 62]} : Maybe<&2, +List<U32>>}:
  {==}
