import Base
import ../src/bitfields.bend as API
import ../src/bit_decode.bend as D
import ../src/bit_packing.bend as P
import ../src/primitives.bend as Bytes
import ../spec/bitfields.bend as Spec
import ../spec/primitives.bend as Domain
import ./bit_take_unique.bend as Unique
import ./bit_decode.bend as Decode
import ./bit_vector_inverse.bend as Inverse
import ./bit_inverse.bend as Bits
import ./bit_packing.bend as Packing
import ./bitfields.bend as Refinement
import ./primitives.bend as Basic
import ./primitive_invariants.bend as V
import ./integer_decoding.bend as Integer
import ./codec_inverse.bend as ByteLength
import ./word_facts.bend as W

def expanded_size(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: 8n+expanded_size(p)

law expand_length:
  for +xs: +List<U32>
  {List.length(&2, Bool, D.expand(xs)) == expanded_size(List.length(&2, U32, xs)) : Nat}
def expand_length(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      Equal.cong(Nat, Nat, n => 8n+n, List.length(&2, Bool, D.expand(t)), expanded_size(List.length(&2, U32, t)), expand_length(t))

law accepted_size:
  for +n: Nat
  for +xs: +List<Bool>
  for +bits: +List<Bool>
  for e: {D.take(n, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {List.length(&2, Bool, bits) == n : Nat}
def accepted_size(n, xs, bits, e):
  %e : Decode.sized(n, _)
  Decode.take_sized(n, xs)

law equal_expansion_lengths:
  for +xs: +List<U32>
  for +ys: +List<U32>
  for e: {List.length(&2, U32, xs) == List.length(&2, U32, ys) : Nat}
  {List.length(&2, Bool, D.expand(xs)) == List.length(&2, Bool, D.expand(ys)) : Nat}
def equal_expansion_lengths(xs, ys, e):
  Equal.trans(Nat, List.length(&2, Bool, D.expand(xs)), expanded_size(List.length(&2, U32, xs)), List.length(&2, Bool, D.expand(ys)), expand_length(xs),
    Equal.trans(Nat, expanded_size(List.length(&2, U32, xs)), expanded_size(List.length(&2, U32, ys)), List.length(&2, Bool, D.expand(ys)), Equal.cong(Nat, Nat, expanded_size, List.length(&2, U32, xs), List.length(&2, U32, ys), e), Equal.sym(Nat, List.length(&2, Bool, D.expand(ys)), expanded_size(List.length(&2, U32, ys)), expand_length(ys))))

law packed_length:
  for +bits: +List<Bool>
  {List.length(&2, U32, P.pack(bits)) == D.byte_count(List.length(&2, Bool, bits)) : Nat}
def packed_length(bits):
  ByteLength.scope_length(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits), Equal.trans(Bool, Domain.byte_scope(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)), Bytes.valid_bytes(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)), True{}, Equal.sym(Bool, Bytes.valid_bytes(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)), Domain.byte_scope(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits)), Basic.byte_scope_correct(D.byte_count(List.length(&2, Bool, bits)), P.pack(bits))), Inverse.packed_scope(bits)))

law take_same_size:
  for +n: Nat
  for +bits: +List<Bool>
  for size: {List.length(&2, Bool, bits) == n : Nat}
  {D.take(n, D.expand(P.pack(bits))) == Some{bits} : Maybe<&2, +List<Bool>>}
def take_same_size(n, bits, size):
  %size : {D.take(_, D.expand(P.pack(bits))) == Some{bits} : Maybe<&2, +List<Bool>>}
  Bits.take_packed(bits)

law parser_canonical:
  for +n: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +scope: {Domain.byte_scope(D.byte_count(n), xs) == True{} : Bool}
  for +decoded: {D.take(n, D.expand(xs)) == Some{bits} : Maybe<&2, +List<Bool>>}
  {P.pack(bits) == xs : +List<U32>}
def parser_canonical(n, xs, bits, scope, decoded):
  +size = accepted_size(n, D.expand(xs), bits, decoded)
  +count = Equal.trans(Nat, List.length(&2, U32, xs), D.byte_count(n), List.length(&2, U32, P.pack(bits)), ByteLength.scope_length(D.byte_count(n), xs, scope), Equal.sym(Nat, List.length(&2, U32, P.pack(bits)), D.byte_count(n), Equal.trans(Nat, List.length(&2, U32, P.pack(bits)), D.byte_count(List.length(&2, Bool, bits)), D.byte_count(n), packed_length(bits), Equal.cong(Nat, Nat, D.byte_count, List.length(&2, Bool, bits), n, size))))
  +same = Unique.take_unique(n, D.expand(xs), D.expand(P.pack(bits)), equal_expansion_lengths(xs, P.pack(bits), count), Equal.trans(Maybe<&2, +List<Bool>>, D.take(n, D.expand(xs)), Some{bits}, D.take(n, D.expand(P.pack(bits))), decoded, Equal.sym(Maybe<&2, +List<Bool>>, D.take(n, D.expand(P.pack(bits))), Some{bits}, take_same_size(n, bits, size))), Equal.cong(Maybe<&2, +List<Bool>>, Bool, Unique.present, D.take(n, D.expand(xs)), Some{bits}, decoded))
  Equal.trans(+List<U32>, P.pack(bits), P.pack(D.expand(P.pack(bits))), xs, Equal.sym(+List<U32>, P.pack(D.expand(P.pack(bits))), P.pack(bits), Bits.repack_expanded(P.pack(bits), Packing.pack_bytes(bits))),
    Equal.trans(+List<U32>, P.pack(D.expand(P.pack(bits))), P.pack(D.expand(xs)), xs, Equal.cong(+List<Bool>, +List<U32>, P.pack, D.expand(P.pack(bits)), D.expand(xs), Equal.sym(+List<Bool>, D.expand(xs), D.expand(P.pack(bits)), same)), Bits.repack_expanded(xs, Integer.scope_domain(D.byte_count(n), xs, scope))))

law nat_equal_refl:
  for +n: Nat
  {Nat.is_eq(n, n) == True{} : Bool}
def nat_equal_refl(n):
  match n:
    case 0n: {==}
    case 1n+p: nat_equal_refl(p)

law valid_of_size:
  for +n: Nat
  for +bits: +List<Bool>
  for positive: {Nat.is_lt(0n, n) == True{} : Bool}
  for size: {List.length(&2, Bool, bits) == n : Nat}
  {API.vector_valid(n, bits) == True{} : Bool}
def valid_of_size(n, bits, positive, size):
  match n:
    case 0n: Empty.absurd({API.vector_valid(0n, bits) == True{} : Bool}, W.false_true(positive))
    case 1n+p:
      %Equal.sym(Nat, List.length(&2, Bool, bits), 1n+p, size) : {Nat.is_eq(_, 1n+p) == True{} : Bool}
      nat_equal_refl(1n+p)

law check_correct:
  for +n: Nat
  for +xs: +List<U32>
  {Bool.and(Nat.is_lt(0n, n), Bytes.valid_bytes(D.byte_count(n), xs)) == Bool.and(Nat.is_lt(0n, n), Domain.byte_scope(D.byte_count(n), xs)) : Bool}
def check_correct(n, xs):
  Equal.cong(Bool, Bool, b => Bool.and(Nat.is_lt(0n, n), b), Bytes.valid_bytes(D.byte_count(n), xs), Domain.byte_scope(D.byte_count(n), xs), Basic.byte_scope_correct(D.byte_count(n), xs))

law branch_valid:
  for +ok: Bool
  for +n: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +check: {ok == Bool.and(Nat.is_lt(0n, n), Domain.byte_scope(D.byte_count(n), xs)) : Bool}
  for decoded: {D.vector_checked(ok, n, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {API.vector_valid(n, bits) == True{} : Bool}
def branch_valid(ok, n, xs, bits, check, decoded):
  match ok:
    case False{}: Empty.absurd({API.vector_valid(n, bits) == True{} : Bool}, W.false_true(Equal.cong(Maybe<&2, +List<Bool>>, Bool, Unique.present, None{}, Some{bits}, decoded)))
    case True{}:
      valid_of_size(n, bits, V.and_left(Nat.is_lt(0n, n), Domain.byte_scope(D.byte_count(n), xs), Equal.sym(Bool, True{}, Bool.and(Nat.is_lt(0n, n), Domain.byte_scope(D.byte_count(n), xs)), check)), accepted_size(n, D.expand(xs), bits, decoded))

law accepted_valid:
  for +n: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for decoded: {API.bitvector_deserialize(n, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {API.vector_valid(n, bits) == True{} : Bool}
def accepted_valid(n, xs, bits, decoded):
  branch_valid(Bool.and(Nat.is_lt(0n, n), Bytes.valid_bytes(D.byte_count(n), xs)), n, xs, bits, check_correct(n, xs), decoded)

law branch_canonical:
  for +ok: Bool
  for +n: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +check: {ok == Bool.and(Nat.is_lt(0n, n), Domain.byte_scope(D.byte_count(n), xs)) : Bool}
  for decoded: {D.vector_checked(ok, n, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {P.pack(bits) == xs : +List<U32>}
def branch_canonical(ok, n, xs, bits, check, decoded):
  match ok:
    case False{}: Empty.absurd({P.pack(bits) == xs : +List<U32>}, W.false_true(Equal.cong(Maybe<&2, +List<Bool>>, Bool, Unique.present, None{}, Some{bits}, decoded)))
    case True{}:
      parser_canonical(n, xs, bits, V.and_right(Nat.is_lt(0n, n), Domain.byte_scope(D.byte_count(n), xs), Equal.sym(Bool, True{}, Bool.and(Nat.is_lt(0n, n), Domain.byte_scope(D.byte_count(n), xs)), check)), decoded)

law accepted_canonical:
  for +n: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +decoded: {API.bitvector_deserialize(n, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {API.bitvector_serialize(n, bits) == Some{xs} : Maybe<&2, +List<U32>>}
def accepted_canonical(n, xs, bits, decoded):
  %Equal.sym(Bool, API.vector_valid(n, bits), True{}, accepted_valid(n, xs, bits, decoded)) : {Bytes.accept_bytes(_, P.pack(bits)) == Some{xs} : Maybe<&2, +List<U32>>}
  Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, bs => Some{bs}, P.pack(bits), xs, branch_canonical(Bool.and(Nat.is_lt(0n, n), Bytes.valid_bytes(D.byte_count(n), xs)), n, xs, bits, check_correct(n, xs), decoded))

law accepted_normative_canonical:
  for +n: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +decoded: {API.bitvector_deserialize(n, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {Spec.vector_encoding(n, bits) == Some{xs} : Maybe<&2, +List<U32>>}
def accepted_normative_canonical(n, xs, bits, decoded):
  %Refinement.bitvector_serialize_correct(n, bits) : {_ == Some{xs} : Maybe<&2, +List<U32>>}
  accepted_canonical(n, xs, bits, decoded)

law normative_image_decodes:
  for +n: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for +valid: {API.vector_valid(n, bits) == True{} : Bool}
  for encoded: {Spec.vector_encoding(n, bits) == Some{xs} : Maybe<&2, +List<U32>>}
  {API.bitvector_deserialize(n, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
def normative_image_decodes(n, xs, bits, valid, encoded):
  %encoded : {Inverse.decode_encoding(n, _) == Some{bits} : Maybe<&2, +List<Bool>>}
  Inverse.vector_normative_encoding_complete(n, bits, valid)

law rejected_excludes_normative_image:
  for +n: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for valid: {API.vector_valid(n, bits) == True{} : Bool}
  for rejected: {API.bitvector_deserialize(n, xs) == None{} : Maybe<&2, +List<Bool>>}
  for encoded: {Spec.vector_encoding(n, bits) == Some{xs} : Maybe<&2, +List<U32>>}
  Empty
def rejected_excludes_normative_image(n, xs, bits, valid, rejected, encoded):
  W.false_true(Equal.cong(Maybe<&2, +List<Bool>>, Bool, Unique.present, None{}, Some{bits}, Equal.trans(Maybe<&2, +List<Bool>>, None{}, API.bitvector_deserialize(n, xs), Some{bits}, Equal.sym(Maybe<&2, +List<Bool>>, API.bitvector_deserialize(n, xs), None{}, rejected), normative_image_decodes(n, xs, bits, valid, encoded))))
