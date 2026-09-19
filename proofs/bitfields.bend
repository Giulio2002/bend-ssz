import Base
import ../src/bitfields.bend as I
import ../src/bit_packing.bend as Bits
import ../src/primitives.bend as P
import ../spec/bitfields.bend as S
import ../spec/bit_packing.bend as Model
import ./bit_packing.bend as Packing
import ./primitive_invariants.bend as V
import ./primitives.bend as Basic

law vector_domain_correct:
  for +size: Nat
  for +bits: +List<Bool>
  {I.vector_valid(size, bits) == S.vector_domain(size, bits) : Bool}
def vector_domain_correct(size, bits):
  match size:
    case 0n: {==}
    case 1n+p: {==}

law encoding_correct:
  for ok: Bool
  for +bits: +List<Bool>
  {P.accept_bytes(ok, Bits.pack(bits)) == S.encoding(ok, bits) : Maybe<&2, +List<U32>>}
def encoding_correct(ok, bits):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, xs => Some{xs}, Bits.pack(bits), Model.pack(bits), Packing.pack_correct(bits))

law bitvector_serialize_correct:
  for +size: Nat
  for +bits: +List<Bool>
  {I.bitvector_serialize(size, bits) == S.vector_encoding(size, bits) : Maybe<&2, +List<U32>>}
def bitvector_serialize_correct(size, bits):
  %vector_domain_correct(size, bits) : {I.bitvector_serialize(size, bits) == S.encoding(_, bits) : Maybe<&2, +List<U32>>}
  encoding_correct(I.vector_valid(size, bits), bits)

law bitlist_serialize_correct:
  for +capacity: Nat
  for +bits: +List<Bool>
  {I.bitlist_serialize(capacity, bits) == S.list_encoding(capacity, bits) : Maybe<&2, +List<U32>>}
def bitlist_serialize_correct(capacity, bits):
  encoding_correct(I.list_valid(capacity, bits), List.append(&2, Bool, bits, [True{}]))

law encoding_accepts:
  for ok: Bool
  for bits: +List<Bool>
  {P.is_some(P.accept_bytes(ok, Bits.pack(bits))) == ok : Bool}
def encoding_accepts(ok, bits):
  match ok:
    case False{}: {==}
    case True{}: {==}

law bitvector_rejection:
  for +size: Nat
  for +bits: +List<Bool>
  {P.is_some(I.bitvector_serialize(size, bits)) == S.vector_domain(size, bits) : Bool}
def bitvector_rejection(size, bits):
  %vector_domain_correct(size, bits) : {P.is_some(I.bitvector_serialize(size, bits)) == _ : Bool}
  encoding_accepts(I.vector_valid(size, bits), bits)

law bitlist_rejection:
  for +capacity: Nat
  for +bits: +List<Bool>
  {P.is_some(I.bitlist_serialize(capacity, bits)) == S.list_domain(capacity, bits) : Bool}
def bitlist_rejection(capacity, bits):
  encoding_accepts(I.list_valid(capacity, bits), List.append(&2, Bool, bits, [True{}]))

law encoding_bytes:
  for ok: Bool
  for +bits: +List<Bool>
  V.byte_result(P.accept_bytes(ok, Bits.pack(bits)))
def encoding_bytes(ok, bits):
  match ok:
    case False{}: Unit{}
    case True{}: Packing.pack_bytes(bits)

law bitvector_bytes:
  for +size: Nat
  for +bits: +List<Bool>
  V.byte_result(I.bitvector_serialize(size, bits))
def bitvector_bytes(size, bits):
  encoding_bytes(I.vector_valid(size, bits), bits)

law bitlist_bytes:
  for +capacity: Nat
  for +bits: +List<Bool>
  V.byte_result(I.bitlist_serialize(capacity, bits))
def bitlist_bytes(capacity, bits):
  encoding_bytes(I.list_valid(capacity, bits), List.append(&2, Bool, bits, [True{}]))

law encoding_length:
  for +ok: Bool
  for +bits: +List<Bool>
  {Basic.lengths(P.accept_bytes(ok, Bits.pack(bits))) == Bool.pick(Maybe<&2, Nat>, ok, Some{Model.byte_count(List.length(&2, Bool, bits))}, None{}) : Maybe<&2, Nat>}
def encoding_length(ok, bits):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(Nat, Maybe<&2, Nat>, n => Some{n}, List.length(&2, U32, Bits.pack(bits)), Model.byte_count(List.length(&2, Bool, bits)), Packing.pack_length(bits))

law bitvector_length:
  for +size: Nat
  for +bits: +List<Bool>
  {Basic.lengths(I.bitvector_serialize(size, bits)) == Bool.pick(Maybe<&2, Nat>, S.vector_domain(size, bits), Some{Model.byte_count(List.length(&2, Bool, bits))}, None{}) : Maybe<&2, Nat>}
def bitvector_length(size, bits):
  %vector_domain_correct(size, bits) : {Basic.lengths(I.bitvector_serialize(size, bits)) == Bool.pick(Maybe<&2, Nat>, _, Some{Model.byte_count(List.length(&2, Bool, bits))}, None{}) : Maybe<&2, Nat>}
  encoding_length(I.vector_valid(size, bits), bits)

law bitlist_length:
  for +capacity: Nat
  for +bits: +List<Bool>
  {Basic.lengths(I.bitlist_serialize(capacity, bits)) == Bool.pick(Maybe<&2, Nat>, S.list_domain(capacity, bits), Some{Model.byte_count(List.length(&2, Bool, List.append(&2, Bool, bits, [True{}])))}, None{}) : Maybe<&2, Nat>}
def bitlist_length(capacity, bits):
  encoding_length(I.list_valid(capacity, bits), List.append(&2, Bool, bits, [True{}]))
