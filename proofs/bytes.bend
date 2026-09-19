import Base
import ../src/bytes.bend as I
import ../src/primitives.bend as P
import ../spec/bytes.bend as S
import ../spec/primitives.bend as SP
import ./primitives.bend as Basic
import ./prefix.bend as Prefix
import ./primitive_invariants.bend as V
import ./basic_root.bend as Root
import ./word_facts.bend as W

law and_identity:
  for b: Bool
  {Bool.and(b, True{}) == b : Bool}
def and_identity(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law and_zero:
  for b: Bool
  {Bool.and(b, False{}) == False{} : Bool}
def and_zero(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law and_associative:
  for a: Bool
  for b: Bool
  for c: Bool
  {Bool.and(Bool.and(a, b), c) == Bool.and(a, Bool.and(b, c)) : Bool}
def and_associative(a, b, c):
  match a:
    case False{}: {==}
    case True{}: {==}

law scope_go_correct:
  for +xs: +List<U32>
  for +n: Nat
  for +ok: Bool
  {I.scope_go(xs, n, ok) == Bool.and(ok, SP.byte_scope(n, xs)) : Bool}
def scope_go_correct(xs, n, ok):
  match xs n:
    case Nil{} 0n: Equal.sym(Bool, Bool.and(ok, True{}), ok, and_identity(ok))
    case Nil{} 1n+p: Equal.sym(Bool, Bool.and(ok, False{}), False{}, and_zero(ok))
    case Con{h, t} 0n: Equal.sym(Bool, Bool.and(ok, False{}), False{}, and_zero(ok))
    case Con{h, t} 1n+p:
      %and_associative(ok, U32.is_lt(h, 256), SP.byte_scope(p, t)) :
        {I.scope_go(t, p, Bool.and(ok, U32.is_lt(h, 256))) == _ : Bool}
      scope_go_correct(t, p, Bool.and(ok, U32.is_lt(h, 256)))

law vector_domain_correct:
  for +n: Nat
  for +xs: +List<U32>
  {I.vector_valid(n, xs) == S.vector_domain(n, xs) : Bool}
def vector_domain_correct(n, xs):
  match n:
    case 0n: {==}
    case 1n+p:
      Equal.cong(Bool, Bool, ok => Bool.and(ok, I.size_fits(1n+p)), I.scope_go(xs, 1n+p, True{}), SP.byte_scope(1n+p, xs), scope_go_correct(xs, 1n+p, True{}))

law vector_serialize_correct:
  for +n: Nat
  for +xs: +List<U32>
  {I.vector_serialize(n, xs) == S.vector_encoding(n, xs) : Maybe<&2, +List<U32>>}
def vector_serialize_correct(n, xs):
  %vector_domain_correct(n, xs) : {P.accept_bytes(I.vector_valid(n, xs), xs) == SP.optional(_, xs) : Maybe<&2, +List<U32>>}
  Prefix.accept_correct(I.vector_valid(n, xs), xs)

law vector_deserialize_correct:
  for +n: Nat
  for +xs: +List<U32>
  {I.vector_deserialize(n, xs) == S.vector_decoding(n, xs) : Maybe<&2, +List<U32>>}
def vector_deserialize_correct(n, xs): vector_serialize_correct(n, xs)

law vector_rejection_correct:
  for +n: Nat
  for +xs: +List<U32>
  {P.is_some(I.vector_deserialize(n, xs)) == S.vector_domain(n, xs) : Bool}
def vector_rejection_correct(n, xs):
  %Equal.sym(Maybe<&2, +List<U32>>, I.vector_deserialize(n, xs), S.vector_decoding(n, xs), vector_deserialize_correct(n, xs)) :
    {P.is_some(_) == S.vector_domain(n, xs) : Bool}
  Prefix.optional_accepted(S.vector_domain(n, xs), xs)

law sub_zero:
  for n: Nat
  {Nat.sub(n, 0n) == n : Nat}
def sub_zero(n):
  match n:
    case 0n: {==}
    case 1n+p: {==}

law bounded_padding:
  for +n: Nat
  for +xs: +List<U32>
  for e: {Nat.is_le(List.length(&2, U32, xs), n) == True{} : Bool}
  {P.pad(n, xs) == List.append(&2, U32, xs, SP.zero_bytes(Nat.sub(n, List.length(&2, U32, xs)))) : +List<U32>}
def bounded_padding(n, xs, e):
  match n:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{h, t}: Empty.absurd({P.pad(0n, h <> t) == List.append(&2, U32, h <> t, SP.zero_bytes(Nat.sub(0n, 1n+List.length(&2, U32, t)))) : +List<U32>}, W.false_true(e))
    case 1n+p:
      match xs:
        case Nil{}:
          %Equal.sym(Nat, Nat.sub(1n+p, 0n), 1n+p, sub_zero(1n+p)) : {P.pad(1n+p, []) == SP.zero_bytes(_) : +List<U32>}
          Root.empty_padding(1n+p)
        case Con{h, t}:
          %bounded_padding(p, t, e) : {h <> P.pad(p, t) == h <> _ : +List<U32>}
          {==}

law and_swap:
  for a: Bool
  for b: Bool
  for c: Bool
  {Bool.and(a, Bool.and(b, c)) == Bool.and(b, Bool.and(a, c)) : Bool}
def and_swap(a, b, c):
  match a b:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}: {==}

law zero_le:
  for n: Nat
  {Nat.is_le(0n, n) == True{} : Bool}
def zero_le(n):
  match n:
    case 0n: {==}
    case 1n+p: {==}

law chunk_scope_correct:
  for +xs: +List<U32>
  for +n: Nat
  {I.chunk_scope(xs, n) == Bool.and(Nat.is_le(List.length(&2, U32, xs), n), SP.bytes_domain(xs)) : Bool}
def chunk_scope_correct(xs, n):
  match xs:
    case Nil{}:
      %Equal.sym(Bool, Nat.is_le(0n, n), True{}, zero_le(n)) : {True{} == Bool.and(_, True{}) : Bool}
      {==}
    case Con{h, t}:
      match n:
        case 0n: {==}
        case 1n+p:
          %and_swap(U32.is_lt(h, 256), Nat.is_le(List.length(&2, U32, t), p), SP.bytes_domain(t)) :
            {Bool.and(U32.is_lt(h, 256), I.chunk_scope(t, p)) == _ : Bool}
          %chunk_scope_correct(t, p) :
            {Bool.and(U32.is_lt(h, 256), I.chunk_scope(t, p)) == Bool.and(U32.is_lt(h, 256), _) : Bool}
          {==}

law chunk_domain_correct:
  for +xs: +List<U32>
  {I.chunk_valid(xs) == S.chunk_domain(xs) : Bool}
def chunk_domain_correct(xs): chunk_scope_correct(xs, 32n)

law chunk_branch:
  for ok: Bool
  for +xs: +List<U32>
  for e: {S.chunk_domain(xs) == ok : Bool}
  {I.chunk_checked(ok, xs) == SP.optional(ok, List.append(&2, U32, xs, SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, xs))))) : Maybe<&2, +List<U32>>}
def chunk_branch(ok, xs, e):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, xs => Some{xs}, P.pad(32n, xs),
        List.append(&2, U32, xs, SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, xs)))),
        bounded_padding(32n, xs, V.and_left(Nat.is_le(List.length(&2, U32, xs), 32n), SP.bytes_domain(xs), e)))

law pack_chunk_correct:
  for +xs: +List<U32>
  {I.pack_chunk(xs) == S.chunk_encoding(xs) : Maybe<&2, +List<U32>>}
def pack_chunk_correct(xs):
  %chunk_domain_correct(xs) :
    {I.chunk_checked(I.chunk_valid(xs), xs) == SP.optional(_, List.append(&2, U32, xs, SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, xs))))) : Maybe<&2, +List<U32>>}
  chunk_branch(I.chunk_valid(xs), xs, Equal.sym(Bool, I.chunk_valid(xs), S.chunk_domain(xs), chunk_domain_correct(xs)))

def unwrap(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case None{}: []
    case Some{xs}: xs

law accepted_identity:
  for ok: Bool
  for +xs: +List<U32>
  for +ys: +List<U32>
  for e: {P.accept_bytes(ok, xs) == Some{ys} : Maybe<&2, +List<U32>>}
  {xs == ys : +List<U32>}
def accepted_identity(ok, xs, ys, e):
  match ok:
    case False{}:
      Empty.absurd({xs == ys : +List<U32>}, W.false_true(
        Equal.cong(Maybe<&2, +List<U32>>, Bool, r => P.is_some(r), None{}, Some{ys}, e)))
    case True{}:
      Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, r => unwrap(r), Some{xs}, Some{ys}, e)

law vector_accepted_sound:
  for +n: Nat
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +e: {I.vector_deserialize(n, xs) == Some{ys} : Maybe<&2, +List<U32>>}
  {S.vector_encoding(n, ys) == Some{xs} : Maybe<&2, +List<U32>>}
def vector_accepted_sound(n, xs, ys, e):
  %accepted_identity(I.vector_valid(n, xs), xs, ys, e) :
    {S.vector_encoding(n, _) == Some{xs} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, xs, ys, accepted_identity(I.vector_valid(n, xs), xs, ys, e)) :
    {S.vector_encoding(n, xs) == Some{_} : Maybe<&2, +List<U32>>}
  Equal.trans(Maybe<&2, +List<U32>>, S.vector_encoding(n, xs), I.vector_deserialize(n, xs), Some{ys},
    Equal.sym(Maybe<&2, +List<U32>>, I.vector_deserialize(n, xs), S.vector_encoding(n, xs), vector_serialize_correct(n, xs)), e)

law vector_runtime_complete:
  for +n: Nat
  for +v: +List<U32>
  for +encoded: +List<U32>
  for +e: {I.vector_serialize(n, v) == Some{encoded} : Maybe<&2, +List<U32>>}
  {I.vector_deserialize(n, encoded) == Some{v} : Maybe<&2, +List<U32>>}
def vector_runtime_complete(n, v, encoded, e):
  %accepted_identity(I.vector_valid(n, v), v, encoded, e) :
    {I.vector_deserialize(n, _) == Some{v} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, v, encoded, accepted_identity(I.vector_valid(n, v), v, encoded, e)) :
    {I.vector_deserialize(n, v) == Some{_} : Maybe<&2, +List<U32>>}
  e

law vector_decoding_complete:
  for +n: Nat
  for +v: +List<U32>
  for +encoded: +List<U32>
  for e: {S.vector_encoding(n, v) == Some{encoded} : Maybe<&2, +List<U32>>}
  {I.vector_deserialize(n, encoded) == Some{v} : Maybe<&2, +List<U32>>}
def vector_decoding_complete(n, v, encoded, e):
  vector_runtime_complete(n, v, encoded, Equal.trans(Maybe<&2, +List<U32>>,
    I.vector_serialize(n, v), S.vector_encoding(n, v), Some{encoded}, vector_serialize_correct(n, v), e))

law chunk_length_branch:
  for ok: Bool
  for +xs: +List<U32>
  {Basic.lengths(I.chunk_checked(ok, xs)) == Bool.pick(Maybe<&2, Nat>, ok, Some{32n}, None{}) : Maybe<&2, Nat>}
def chunk_length_branch(ok, xs):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(Nat, Maybe<&2, Nat>, n => Some{n}, List.length(&2, U32, P.pad(32n, xs)), 32n, Basic.padded_length(32n, xs))

law pack_chunk_length:
  for +xs: +List<U32>
  {Basic.lengths(I.pack_chunk(xs)) == Bool.pick(Maybe<&2, Nat>, I.chunk_valid(xs), Some{32n}, None{}) : Maybe<&2, Nat>}
def pack_chunk_length(xs): chunk_length_branch(I.chunk_valid(xs), xs)
