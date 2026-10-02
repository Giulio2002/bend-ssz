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

def c0() -> {Codec.encoding_for_legal_type(F.BlobIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c1() -> {Codec.encoding_for_legal_type(F.BlobIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c2() -> {Codec.encoding_for_legal_type(F.Bytes1(), T.BytesValue{[]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c3() -> {Codec.encoding_for_legal_type(F.Bytes1(), T.BytesValue{[0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c4() -> {Codec.encoding_for_legal_type(F.Bytes20(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c5() -> {Codec.encoding_for_legal_type(F.Bytes20(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c6() -> {Codec.encoding_for_legal_type(F.Bytes32(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c7() -> {Codec.encoding_for_legal_type(F.Bytes32(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c8() -> {Codec.encoding_for_legal_type(F.Bytes4(), T.BytesValue{[0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c9() -> {Codec.encoding_for_legal_type(F.Bytes4(), T.BytesValue{[0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c10() -> {Codec.encoding_for_legal_type(F.Bytes8(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c11() -> {Codec.encoding_for_legal_type(F.Bytes8(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c12() -> {Codec.encoding_for_legal_type(F.CellIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c13() -> {Codec.encoding_for_legal_type(F.CellIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c14() -> {Codec.encoding_for_legal_type(F.ColumnIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c15() -> {Codec.encoding_for_legal_type(F.ColumnIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c16() -> {Codec.encoding_for_legal_type(F.CommitmentIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c17() -> {Codec.encoding_for_legal_type(F.CommitmentIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c18() -> {Codec.encoding_for_legal_type(F.CommitteeIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c19() -> {Codec.encoding_for_legal_type(F.CommitteeIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c20() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{0, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c21() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{2, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c22() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{128, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c23() -> {Codec.encoding_for_legal_type(G.CompatibleUnionA(), T.Selected{255, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c24() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{0, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}
