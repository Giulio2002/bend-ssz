import Base
import ../types/primitive.bend as Primitive
import ../spec/primitives.bend as SP
import ../spec/bytes.bend as SBytes
import ../spec/bitfields.bend as SBits
import ../spec/bit_packing.bend as SPack
import ../src/bit_decode.bend as D
import ../src/bit_packing.bend as IPack
import ./primitive_invariants.bend as V
import ./codec_inverse.bend as ByteLength
import ./bit_vector_canonical.bend as BitLength
import ./bit_vector_inverse.bend as Eq
import ./bit_packing.bend as Packing
import ./bit_chunk_count.bend as Count
import ./word_facts.bend as W

# Exact serialized sizes of the independently specified fixed-size leaves.
law optional_sized:
  for +ok: Bool
  for +out: +List<U32>
  for +n: Nat
  for size: {ok == True{} : Bool} -> {List.length(&2, U32, out) == n : Nat}
  V.sized(n, SP.optional(ok, out))
def optional_sized(ok, out, n, size):
  match ok:
    case False{}: Unit{}
    case True{}: size({==})

law prefix_length:
  for +n: Nat
  for +xs: +List<U32>
  for e: {SP.fits(n, xs) == True{} : Bool}
  {List.length(&2, U32, SP.prefix(n, xs)) == n : Nat}
def prefix_length(n, xs, e):
  match n:
    case 0n: {==}
    case 1n+p:
      match xs:
        case Nil{}: Empty.absurd({0n == 1n+p : Nat}, W.false_true(e))
        case Con{h, t}: Equal.cong(Nat, Nat, k => 1n+k, List.length(&2, U32, SP.prefix(p, t)), p, prefix_length(p, t, e))

law uint_sized:
  for +w: Primitive.Width
  for +v: Primitive.UInt
  V.sized(SP.byte_width(w), SP.uint_encoding(w, v))
def uint_sized(w, v):
  optional_sized(SP.uint_domain(w, v), SP.prefix(SP.byte_width(w), SP.full_digits(v)), SP.byte_width(w), e => prefix_length(SP.byte_width(w), SP.full_digits(v), e))

law byte_vector_sized:
  for +n: Nat
  for +xs: +List<U32>
  V.sized(n, SBytes.vector_encoding(n, xs))
def byte_vector_sized(n, xs):
  match n:
    case 0n: Unit{}
    case 1n+p: optional_sized(Bool.and(SP.byte_scope(1n+p, xs), SBytes.size_fits(1n+p)), xs, 1n+p, e => ByteLength.scope_length(1n+p, xs, V.and_left(SP.byte_scope(1n+p, xs), SBytes.size_fits(1n+p), e)))

law byte_count_division:
  for +n: Nat
  {SPack.byte_count(n) == Nat.div(Nat.add(n, 7n), 8n) : Nat}
def byte_count_division(n):
  match n:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n: {==}
    case 5n: {==}
    case 6n: {==}
    case 7n: {==}
    case 8n+p:
      Equal.trans(Nat, 1n+SPack.byte_count(p), 1n+Nat.div(Nat.add(p, 7n), 8n), Nat.div(Nat.add(8n+p, 7n), 8n),
        Equal.cong(Nat, Nat, k => 1n+k, SPack.byte_count(p), Nat.div(Nat.add(p, 7n), 8n), byte_count_division(p)),
        Equal.sym(Nat, Nat.div(Nat.add(8n+p, 7n), 8n), 1n+Nat.div(Nat.add(p, 7n), 8n), Count.quotient_successor(Nat.add(p, 7n), 7n, 0n, 0n)))

law spec_pack_length:
  for +bits: +List<Bool>
  {List.length(&2, U32, SPack.pack(bits)) == SPack.byte_count(List.length(&2, Bool, bits)) : Nat}
def spec_pack_length(bits):
  %Packing.pack_correct(bits) : {List.length(&2, U32, _) == SPack.byte_count(List.length(&2, Bool, bits)) : Nat}
  Packing.pack_length(bits)

law bits_sized:
  for +ok: Bool
  for +bits: +List<Bool>
  for +n: Nat
  for size: {ok == True{} : Bool} -> {List.length(&2, U32, SPack.pack(bits)) == n : Nat}
  V.sized(n, SBits.encoding(ok, bits))
def bits_sized(ok, bits, n, size):
  match ok:
    case False{}: Unit{}
    case True{}: size({==})

law vector_pack_length:
  for +n: Nat
  for +bits: +List<Bool>
  for e: {SBits.vector_domain(n, bits) == True{} : Bool}
  {List.length(&2, U32, SPack.pack(bits)) == Nat.div(Nat.add(n, 7n), 8n) : Nat}
def vector_pack_length(n, bits, e):
  %Eq.nat_equal_sound(List.length(&2, Bool, bits), n, V.and_right(Nat.is_lt(0n, n), Nat.is_eq(List.length(&2, Bool, bits), n), e)) : {List.length(&2, U32, SPack.pack(bits)) == Nat.div(Nat.add(_, 7n), 8n) : Nat}
  Equal.trans(Nat, List.length(&2, U32, SPack.pack(bits)), SPack.byte_count(List.length(&2, Bool, bits)), Nat.div(Nat.add(List.length(&2, Bool, bits), 7n), 8n), spec_pack_length(bits), byte_count_division(List.length(&2, Bool, bits)))

law bit_vector_sized:
  for +n: Nat
  for +bits: +List<Bool>
  V.sized(Nat.div(Nat.add(n, 7n), 8n), SBits.vector_encoding(n, bits))
def bit_vector_sized(n, bits):
  bits_sized(SBits.vector_domain(n, bits), bits, Nat.div(Nat.add(n, 7n), 8n), e => vector_pack_length(n, bits, e))
