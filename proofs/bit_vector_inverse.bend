import Base
import ../spec/bitfields.bend as Spec
import ./bitfields.bend as Refinement
import ../src/bitfields.bend as API
import ../src/bit_decode.bend as D
import ../src/bit_packing.bend as P
import ../src/primitives.bend as Bytes
import ../spec/bit_packing.bend as Counts
import ../spec/primitives.bend as Domain
import ./bit_inverse.bend as Inverse
import ./bit_decode.bend as Decode
import ./bit_packing.bend as Packing
import ./packing.bend as Scope
import ./primitives.bend as Basic
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

law packed_scope:
  for +bits: +List<Bool>
  {Bytes.valid_bytes(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)) == True{} : Bool}
def packed_scope(bits):
  Equal.trans(Bool, Bytes.valid_bytes(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)), Domain.byte_scope(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)), True{}, Basic.byte_scope_correct(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)), Scope.scope_from_size(P.pack(bits), D.byte_count(List.length(&2, Bool, bits)), Equal.trans(Nat, List.length(&2, U32, P.pack(bits)), Counts.byte_count(List.length(&2, Bool, bits)), D.byte_count(List.length(&2, Bool, bits)), Packing.pack_length(bits), Equal.sym(Nat, D.byte_count(List.length(&2, Bool, bits)), Counts.byte_count(List.length(&2, Bool, bits)), Decode.count_correct(List.length(&2, Bool, bits)))), Packing.pack_bytes(bits)))

law decode_packed:
  for +bits: +List<Bool>
  for positive: {Nat.is_lt(0n, List.length(&2, Bool, bits)) == True{} : Bool}
  {API.bitvector_deserialize(List.length(&2, Bool, bits), P.pack(bits)) == Some{bits} : Maybe<&2, +List<Bool>>}
def decode_packed(bits, positive):
  %Equal.sym(Bool, Bool.and(Nat.is_lt(0n, List.length(&2, Bool, bits)), Bytes.valid_bytes(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits))), True{}, V.and_true(Nat.is_lt(0n, List.length(&2, Bool, bits)), Bytes.valid_bytes(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)), positive, packed_scope(bits))) : {D.vector_checked(_, List.length(&2, Bool, bits), P.pack(bits)) == Some{bits} : Maybe<&2, +List<Bool>>}
  Inverse.take_packed(bits)

law nat_equal_sound:
  for +a: Nat
  for +b: Nat
  for e: {Nat.is_eq(a, b) == True{} : Bool}
  {a == b : Nat}
def nat_equal_sound(a, b, e):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: Empty.absurd({0n == 1n+q : Nat}, W.false_true(e))
    case 1n+p 0n: Empty.absurd({1n+p == 0n : Nat}, W.false_true(e))
    case 1n+p 1n+q:
      Equal.cong(Nat, Nat, n => 1n+n, p, q, nat_equal_sound(p, q, e))

law valid_size:
  for +size: Nat
  for +bits: +List<Bool>
  for e: {API.vector_valid(size, bits) == True{} : Bool}
  {List.length(&2, Bool, bits) == size : Nat}
def valid_size(size, bits, e):
  match size:
    case 0n: Empty.absurd({List.length(&2, Bool, bits) == 0n : Nat}, W.false_true(e))
    case 1n+p: nat_equal_sound(List.length(&2, Bool, bits), 1n+p, e)

law valid_positive:
  for +size: Nat
  for +bits: +List<Bool>
  for e: {API.vector_valid(size, bits) == True{} : Bool}
  {Nat.is_lt(0n, size) == True{} : Bool}
def valid_positive(size, bits, e):
  match size:
    case 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, W.false_true(e))
    case 1n+p: {==}

law vector_decode_packed:
  for +size: Nat
  for +bits: +List<Bool>
  for +e: {API.vector_valid(size, bits) == True{} : Bool}
  {API.bitvector_deserialize(size, P.pack(bits)) == Some{bits} : Maybe<&2, +List<Bool>>}
def vector_decode_packed(size, bits, e):
  %valid_size(size, bits, e) : {API.bitvector_deserialize(_, P.pack(bits)) == Some{bits} : Maybe<&2, +List<Bool>>}
  decode_packed(bits, Equal.trans(Bool, Nat.is_lt(0n, List.length(&2, Bool, bits)), Nat.is_lt(0n, size), True{}, Equal.cong(Nat, Bool, n => Nat.is_lt(0n, n), List.length(&2, Bool, bits), size, valid_size(size, bits, e)), valid_positive(size, bits, e)))

# Bind the actual serializer result into the actual public decoder.
def decode_encoding(size: Nat, encoded: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<Bool>>:
  match encoded:
    case None{}: None{}
    case Some{xs}: API.bitvector_deserialize(size, xs)

law vector_roundtrip:
  for +size: Nat
  for +bits: +List<Bool>
  for +e: {API.vector_valid(size, bits) == True{} : Bool}
  {decode_encoding(size, API.bitvector_serialize(size, bits)) == Some{bits} : Maybe<&2, +List<Bool>>}
def vector_roundtrip(size, bits, e):
  %Equal.sym(Bool, API.vector_valid(size, bits), True{}, e) : {decode_encoding(size, Bytes.accept_bytes(_, P.pack(bits))) == Some{bits} : Maybe<&2, +List<Bool>>}
  vector_decode_packed(size, bits, e)


law vector_normative_encoding_complete:
  for +size: Nat
  for +bits: +List<Bool>
  for +e: {API.vector_valid(size, bits) == True{} : Bool}
  {decode_encoding(size, Spec.vector_encoding(size, bits)) == Some{bits} : Maybe<&2, +List<Bool>>}
def vector_normative_encoding_complete(size, bits, e):
  %Refinement.bitvector_serialize_correct(size, bits) : {decode_encoding(size, _) == Some{bits} : Maybe<&2, +List<Bool>>}
  vector_roundtrip(size, bits, e)
