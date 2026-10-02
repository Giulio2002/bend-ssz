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

def c25() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{5, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c26() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{128, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c27() -> {Codec.encoding_for_legal_type(G.CompatibleUnionABCA(), T.Selected{255, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c28() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{0, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c29() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{4, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c30() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{128, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c31() -> {Codec.encoding_for_legal_type(G.CompatibleUnionBC(), T.Selected{255, T.NullValue{}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c32() -> {Codec.encoding_for_legal_type(F.CurrentSyncCommitteeBranch(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c33() -> {Codec.encoding_for_legal_type(F.CurrentSyncCommitteeBranch(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c34() -> {Codec.encoding_for_legal_type(F.CustodyIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c35() -> {Codec.encoding_for_legal_type(F.CustodyIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c36() -> {Codec.encoding_for_legal_type(F.Domain(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c37() -> {Codec.encoding_for_legal_type(F.Domain(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c38() -> {Codec.encoding_for_legal_type(F.DomainType(), T.BytesValue{[0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c39() -> {Codec.encoding_for_legal_type(F.DomainType(), T.BytesValue{[0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c40() -> {Codec.encoding_for_legal_type(F.Epoch(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c41() -> {Codec.encoding_for_legal_type(F.Epoch(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c42() -> {Codec.encoding_for_legal_type(F.Ether(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c43() -> {Codec.encoding_for_legal_type(F.Ether(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c44() -> {Codec.encoding_for_legal_type(F.ExecutionAddress(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c45() -> {Codec.encoding_for_legal_type(F.ExecutionAddress(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c46() -> {Codec.encoding_for_legal_type(F.ExecutionBranch(), T.Sequence{T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.Items{T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, T.EmptyItems{}}}}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}
