import Base
import ../src/bitfields.bend as API
import ../src/bit_decode.bend as I
import ../spec/bit_decode.bend as S
import ../src/bit_decoding.bend as Octets
import ../spec/bit_decoding.bend as Digits
import ../src/primitives.bend as P
import ../src/packing.bend as Pack
import ../spec/primitives.bend as Domain
import ../spec/bit_packing.bend as Counts
import ./bit_decoding.bend as OctetLaws
import ./primitive_invariants.bend as V
import ./integer_decoding.bend as Integer
import ./primitives.bend as Basic
import ./packing.bend as Packing
import ./bytes.bend as Bytes

law expand_correct:
  for +xs: +List<U32>
  for +e: {Domain.bytes_domain(xs) == True{} : Bool}
  {I.expand(xs) == S.expand(xs) : +List<Bool>}
def expand_correct(xs, e):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %OctetLaws.octet_correct(h, V.and_left(U32.is_lt(h, 256), Domain.bytes_domain(t), e)) : {I.expand(xs) == List.append(&2, Bool, _, S.expand(t)) : +List<Bool>}
      %expand_correct(t, V.and_right(U32.is_lt(h, 256), Domain.bytes_domain(t), e)) : {I.expand(xs) == List.append(&2, Bool, Octets.octet(h), _) : +List<Bool>}
      {==}

law zero_correct:
  for +bits: +List<Bool>
  {I.all_zero(bits) == S.all_zero(bits) : Bool}
def zero_correct(bits):
  match bits:
    case Nil{}: {==}
    case Con{h, t}:
      %zero_correct(t) : {I.all_zero(bits) == Bool.and(Bool.not(h), _) : Bool}
      {==}

law accept_correct:
  for ok: Bool
  for bits: +List<Bool>
  {I.accept(ok, bits) == S.accept(ok, bits) : Maybe<&2, +List<Bool>>}
def accept_correct(ok, bits):
  match ok:
    case False{}: {==}
    case True{}: {==}

law cons_correct:
  for b: Bool
  for r: Maybe<&2, +List<Bool>>
  {I.cons(b, r) == S.cons(b, r) : Maybe<&2, +List<Bool>>}
def cons_correct(b, r):
  match r:
    case None{}: {==}
    case Some{xs}: {==}

law take_correct:
  for +n: Nat
  for +bits: +List<Bool>
  {I.take(n, bits) == S.take(n, bits) : Maybe<&2, +List<Bool>>}
def take_correct(n, bits):
  match n:
    case 0n:
      %zero_correct(bits) : {I.take(0n, bits) == S.accept(_, []) : Maybe<&2, +List<Bool>>}
      accept_correct(I.all_zero(bits), [])
    case 1n+p:
      match bits:
        case Nil{}: {==}
        case Con{h, t}:
          %take_correct(p, t) : {I.take(n, bits) == S.cons(h, _) : Maybe<&2, +List<Bool>>}
          cons_correct(h, I.take(p, t))

law count_correct:
  for +n: Nat
  {I.byte_count(n) == Counts.byte_count(n) : Nat}
def count_correct(n):
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
      %count_correct(p) : {1n+I.byte_count(p) == 1n+_ : Nat}
      {==}

law vector_branch:
  for +ok: Bool
  for +size: Nat
  for +xs: +List<U32>
  for e: {ok == Bool.and(Nat.is_lt(0n, size), Domain.byte_scope(Counts.byte_count(size), xs)) : Bool}
  {I.vector_checked(ok, size, xs) == S.vector_checked(ok, size, xs) : Maybe<&2, +List<Bool>>}
def vector_branch(ok, size, xs, e):
  match ok:
    case False{}: {==}
    case True{}:
      %expand_correct(xs, Integer.scope_domain(Counts.byte_count(size), xs, V.and_right(Nat.is_lt(0n, size), Domain.byte_scope(Counts.byte_count(size), xs), Equal.sym(Bool, True{}, Bool.and(Nat.is_lt(0n, size), Domain.byte_scope(Counts.byte_count(size), xs)), e)))) : {I.vector_checked(True{}, size, xs) == S.take(size, _) : Maybe<&2, +List<Bool>>}
      take_correct(size, I.expand(xs))

law vector_check_correct:
  for +size: Nat
  for +xs: +List<U32>
  {Bool.and(Nat.is_lt(0n, size), P.valid_bytes(I.byte_count(size), xs)) == Bool.and(Nat.is_lt(0n, size), Domain.byte_scope(Counts.byte_count(size), xs)) : Bool}
def vector_check_correct(size, xs):
  %count_correct(size) : {Bool.and(Nat.is_lt(0n, size), P.valid_bytes(I.byte_count(size), xs)) == Bool.and(Nat.is_lt(0n, size), Domain.byte_scope(_, xs)) : Bool}
  %Basic.byte_scope_correct(I.byte_count(size), xs) : {Bool.and(Nat.is_lt(0n, size), P.valid_bytes(I.byte_count(size), xs)) == Bool.and(Nat.is_lt(0n, size), _) : Bool}
  {==}

law bitvector_deserialize_correct:
  for +size: Nat
  for +xs: +List<U32>
  {I.bitvector_deserialize(size, xs) == S.bitvector_deserialize(size, xs) : Maybe<&2, +List<Bool>>}
def bitvector_deserialize_correct(size, xs):
  %vector_check_correct(size, xs) : {I.bitvector_deserialize(size, xs) == S.vector_checked(_, size, xs) : Maybe<&2, +List<Bool>>}
  vector_branch(Bool.and(Nat.is_lt(0n, size), P.valid_bytes(I.byte_count(size), xs)), size, xs, vector_check_correct(size, xs))

law delimiter_correct:
  for +bits: +List<Bool>
  for +room: Nat
  {I.delimiter(bits, room) == S.delimiter(bits, room) : Maybe<&2, +List<Bool>>}
def delimiter_correct(bits, room):
  match bits:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case True{}: {==}
        case False{}:
          match room:
            case 0n: {==}
            case 1n+p: delimiter_correct(t, p)

law bounded_correct:
  for +capacity: Nat
  for +r: Maybe<&2, +List<Bool>>
  {I.bounded(capacity, r) == S.bounded(capacity, r) : Maybe<&2, +List<Bool>>}
def bounded_correct(capacity, r):
  match r:
    case None{}: {==}
    case Some{bits}: accept_correct(Nat.is_le(List.length(&2, Bool, bits), capacity), bits)

law list_branch:
  for +ok: Bool
  for +capacity: Nat
  for +xs: +List<U32>
  for e: {ok == Domain.bytes_domain(xs) : Bool}
  {I.list_checked(ok, capacity, xs) == S.list_checked(ok, capacity, xs) : Maybe<&2, +List<Bool>>}
def list_branch(ok, capacity, xs, e):
  match ok:
    case False{}: {==}
    case True{}:
      %expand_correct(xs, Equal.sym(Bool, True{}, Domain.bytes_domain(xs), e)) : {I.list_checked(True{}, capacity, xs) == S.bounded(capacity, S.delimiter(List.reverse(&2, Bool, _), 7n)) : Maybe<&2, +List<Bool>>}
      %delimiter_correct(List.reverse(&2, Bool, I.expand(xs)), 7n) : {I.list_checked(True{}, capacity, xs) == S.bounded(capacity, _) : Maybe<&2, +List<Bool>>}
      bounded_correct(capacity, I.delimiter(List.reverse(&2, Bool, I.expand(xs)), 7n))

law bitlist_deserialize_correct:
  for +capacity: Nat
  for +xs: +List<U32>
  {I.bitlist_deserialize(capacity, xs) == S.bitlist_deserialize(capacity, xs) : Maybe<&2, +List<Bool>>}
def bitlist_deserialize_correct(capacity, xs):
  %Packing.valid_go_correct(xs, True{}) : {I.bitlist_deserialize(capacity, xs) == S.list_checked(_, capacity, xs) : Maybe<&2, +List<Bool>>}
  list_branch(Pack.valid_go(xs, True{}), capacity, xs, Packing.valid_go_correct(xs, True{}))

law bitvector_decode_sound:
  for +size: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for e: {API.bitvector_deserialize(size, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {S.bitvector_deserialize(size, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
def bitvector_decode_sound(size, xs, bits, e):
  %bitvector_deserialize_correct(size, xs) : {_ == Some{bits} : Maybe<&2, +List<Bool>>}
  e

law bitvector_decode_complete:
  for +size: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for e: {S.bitvector_deserialize(size, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {API.bitvector_deserialize(size, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
def bitvector_decode_complete(size, xs, bits, e):
  Equal.trans(Maybe<&2, +List<Bool>>, API.bitvector_deserialize(size, xs), S.bitvector_deserialize(size, xs), Some{bits}, bitvector_deserialize_correct(size, xs), e)

law bitvector_rejection_complete:
  for +size: Nat
  for +xs: +List<U32>
  for e: {S.bitvector_deserialize(size, xs) == None{} : Maybe<&2, +List<Bool>>}
  {API.bitvector_deserialize(size, xs) == None{} : Maybe<&2, +List<Bool>>}
def bitvector_rejection_complete(size, xs, e):
  Equal.trans(Maybe<&2, +List<Bool>>, API.bitvector_deserialize(size, xs), S.bitvector_deserialize(size, xs), None{}, bitvector_deserialize_correct(size, xs), e)

law bitvector_rejection_sound:
  for +size: Nat
  for +xs: +List<U32>
  for e: {API.bitvector_deserialize(size, xs) == None{} : Maybe<&2, +List<Bool>>}
  {S.bitvector_deserialize(size, xs) == None{} : Maybe<&2, +List<Bool>>}
def bitvector_rejection_sound(size, xs, e):
  %bitvector_deserialize_correct(size, xs) : {_ == None{} : Maybe<&2, +List<Bool>>}
  e

law bitlist_decode_sound:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for e: {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {S.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
def bitlist_decode_sound(capacity, xs, bits, e):
  %bitlist_deserialize_correct(capacity, xs) : {_ == Some{bits} : Maybe<&2, +List<Bool>>}
  e

law bitlist_decode_complete:
  for +capacity: Nat
  for +xs: +List<U32>
  for +bits: +List<Bool>
  for e: {S.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
  {API.bitlist_deserialize(capacity, xs) == Some{bits} : Maybe<&2, +List<Bool>>}
def bitlist_decode_complete(capacity, xs, bits, e):
  Equal.trans(Maybe<&2, +List<Bool>>, API.bitlist_deserialize(capacity, xs), S.bitlist_deserialize(capacity, xs), Some{bits}, bitlist_deserialize_correct(capacity, xs), e)

law bitlist_rejection_complete:
  for +capacity: Nat
  for +xs: +List<U32>
  for e: {S.bitlist_deserialize(capacity, xs) == None{} : Maybe<&2, +List<Bool>>}
  {API.bitlist_deserialize(capacity, xs) == None{} : Maybe<&2, +List<Bool>>}
def bitlist_rejection_complete(capacity, xs, e):
  Equal.trans(Maybe<&2, +List<Bool>>, API.bitlist_deserialize(capacity, xs), S.bitlist_deserialize(capacity, xs), None{}, bitlist_deserialize_correct(capacity, xs), e)

law bitlist_rejection_sound:
  for +capacity: Nat
  for +xs: +List<U32>
  for e: {API.bitlist_deserialize(capacity, xs) == None{} : Maybe<&2, +List<Bool>>}
  {S.bitlist_deserialize(capacity, xs) == None{} : Maybe<&2, +List<Bool>>}
def bitlist_rejection_sound(capacity, xs, e):
  %bitlist_deserialize_correct(capacity, xs) : {_ == None{} : Maybe<&2, +List<Bool>>}
  e

# Successful parsers discharge the value length domain independently of any
# assumption about serialized input validity.
def sized(n: Nat, r: Maybe<&2, +List<Bool>>) -> Type:
  match r:
    case None{}: Unit
    case Some{bits}: {List.length(&2, Bool, bits) == n : Nat}

law cons_sized:
  for +n: Nat
  for +b: Bool
  for +r: Maybe<&2, +List<Bool>>
  for e: sized(n, r)
  sized(1n+n, I.cons(b, r))
def cons_sized(n, b, r, e):
  match r:
    case None{}: Unit{}
    case Some{bits}:
      Equal.cong(Nat, Nat, x => 1n+x, List.length(&2, Bool, bits), n, e)

law empty_sized:
  for ok: Bool
  sized(0n, I.accept(ok, []))
def empty_sized(ok):
  match ok:
    case False{}: Unit{}
    case True{}: {==}

law take_sized:
  for +n: Nat
  for +bits: +List<Bool>
  sized(n, I.take(n, bits))
def take_sized(n, bits):
  match n:
    case 0n: empty_sized(I.all_zero(bits))
    case 1n+p:
      match bits:
        case Nil{}: Unit{}
        case Con{h, t}: cons_sized(p, h, I.take(p, t), take_sized(p, t))

law vector_branch_sized:
  for ok: Bool
  for +size: Nat
  for +xs: +List<U32>
  sized(size, I.vector_checked(ok, size, xs))
def vector_branch_sized(ok, size, xs):
  match ok:
    case False{}: Unit{}
    case True{}: take_sized(size, I.expand(xs))

law bitvector_decoded_length:
  for +size: Nat
  for +xs: +List<U32>
  sized(size, API.bitvector_deserialize(size, xs))
def bitvector_decoded_length(size, xs):
  vector_branch_sized(Bool.and(Nat.is_lt(0n, size), P.valid_bytes(I.byte_count(size), xs)), size, xs)

def in_capacity(capacity: Nat, r: Maybe<&2, +List<Bool>>) -> Type:
  match r:
    case None{}: Unit
    case Some{bits}: {Nat.is_le(List.length(&2, Bool, bits), capacity) == True{} : Bool}

law accept_capacity:
  for +ok: Bool
  for +capacity: Nat
  for +bits: +List<Bool>
  for e: {ok == Nat.is_le(List.length(&2, Bool, bits), capacity) : Bool}
  in_capacity(capacity, I.accept(ok, bits))
def accept_capacity(ok, capacity, bits, e):
  match ok:
    case False{}: Unit{}
    case True{}: Equal.sym(Bool, True{}, Nat.is_le(List.length(&2, Bool, bits), capacity), e)

law bounded_capacity:
  for +capacity: Nat
  for +r: Maybe<&2, +List<Bool>>
  in_capacity(capacity, I.bounded(capacity, r))
def bounded_capacity(capacity, r):
  match r:
    case None{}: Unit{}
    case Some{bits}: accept_capacity(Nat.is_le(List.length(&2, Bool, bits), capacity), capacity, bits, {==})

law list_branch_capacity:
  for ok: Bool
  for +capacity: Nat
  for +xs: +List<U32>
  in_capacity(capacity, I.list_checked(ok, capacity, xs))
def list_branch_capacity(ok, capacity, xs):
  match ok:
    case False{}: Unit{}
    case True{}: bounded_capacity(capacity, I.delimiter(List.reverse(&2, Bool, I.expand(xs)), 7n))

law bitlist_decoded_capacity:
  for +capacity: Nat
  for +xs: +List<U32>
  in_capacity(capacity, API.bitlist_deserialize(capacity, xs))
def bitlist_decoded_capacity(capacity, xs):
  list_branch_capacity(Pack.valid_go(xs, True{}), capacity, xs)
