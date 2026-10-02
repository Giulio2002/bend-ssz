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

def c58() -> {Codec.encoding_for_legal_type(F.ParticipationFlags(), T.UnsignedValue{P.UInt{256, 0, 0, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c59() -> {Codec.encoding_for_legal_type(F.ParticipationFlags(), T.UnsignedValue{P.UInt{255, 0, 0, 0, 0, 0, 0, 0}}) == Some{[255]} : Maybe<&2, +List<U32>>}:
  {==}

def c60() -> {Codec.encoding_for_legal_type(F.PayloadId(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c61() -> {Codec.encoding_for_legal_type(F.PayloadId(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c62() -> {Codec.encoding_for_legal_type(F.Root(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c63() -> {Codec.encoding_for_legal_type(F.Root(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c64() -> {Codec.encoding_for_legal_type(F.RowIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c65() -> {Codec.encoding_for_legal_type(F.RowIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c66() -> {Codec.encoding_for_legal_type(F.Slot(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c67() -> {Codec.encoding_for_legal_type(F.Slot(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c68() -> {Codec.encoding_for_legal_type(F.SubnetID(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c69() -> {Codec.encoding_for_legal_type(F.SubnetID(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c70() -> {Codec.encoding_for_legal_type(F.ValidatorIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c71() -> {Codec.encoding_for_legal_type(F.ValidatorIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c72() -> {Codec.encoding_for_legal_type(F.Version(), T.BytesValue{[0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c73() -> {Codec.encoding_for_legal_type(F.Version(), T.BytesValue{[0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c74() -> {Codec.encoding_for_legal_type(F.VersionedHash(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c75() -> {Codec.encoding_for_legal_type(F.VersionedHash(), T.BytesValue{[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c76() -> {Codec.encoding_for_legal_type(F.WithdrawalIndex(), T.UnsignedValue{P.UInt{0, 0, 1, 0, 0, 0, 0, 0}}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c77() -> {Codec.encoding_for_legal_type(F.WithdrawalIndex(), T.UnsignedValue{P.UInt{4294967295, 4294967295, 0, 0, 0, 0, 0, 0}}) == Some{[255, 255, 255, 255, 255, 255, 255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c78() -> {Codec.encoding_for_legal_type(G.bitlist_1(), T.BitsValue{[False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c79() -> {Codec.encoding_for_legal_type(G.bitlist_1(), T.BitsValue{[True{}]}) == Some{[3]} : Maybe<&2, +List<U32>>}:
  {==}

def c80() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c81() -> {Codec.encoding_for_legal_type(G.bitlist_15(), T.BitsValue{[True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}, True{}]}) == Some{[255, 255]} : Maybe<&2, +List<U32>>}:
  {==}

def c82() -> {Codec.encoding_for_legal_type(G.bitlist_16(), T.BitsValue{[False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}]}) == None{} : Maybe<&2, +List<U32>>}:
  {==}
