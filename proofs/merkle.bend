import Base
import ../src/merkle.bend as I
import ../src/sha256.bend as H
import ../spec/merkle.bend as S
import ../spec/primitives.bend as P
import ../src/primitives.bend as Runtime
import ../vendor/bend_sha256/fips.bend as FIPS
import ../HASH_PROOF.bend as Hash
import ./primitives.bend as Basic
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

law pair_branch:
  for ok: Bool
  for +left: +List<U32>
  for +right: +List<U32>
  {I.pair_checked(ok, left, right) == S.pair_checked(ok, left, right) : Maybe<&2, +List<U32>>}
def pair_branch(ok, left, right):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, xs => Some{xs},
        H.hash(List.append(&2, U32, left, right)), FIPS.sha256_bytes(List.append(&2, U32, left, right)),
        Hash.hash_refines_fips(List.append(&2, U32, left, right)))

law hash_pair_correct:
  for +left: +List<U32>
  for +right: +List<U32>
  {I.hash_pair(left, right) == S.hash_pair(left, right) : Maybe<&2, +List<U32>>}
def hash_pair_correct(left, right):
  %Basic.byte_scope_correct(32n, left) :
    {I.hash_pair(left, right) == S.pair_checked(Bool.and(_, P.byte_scope(32n, right)), left, right) : Maybe<&2, +List<U32>>}
  %Basic.byte_scope_correct(32n, right) :
    {I.hash_pair(left, right) == S.pair_checked(Bool.and(Runtime.valid_bytes(32n, left), _), left, right) : Maybe<&2, +List<U32>>}
  pair_branch(Bool.and(Runtime.valid_bytes(32n, left), Runtime.valid_bytes(32n, right)), left, right)

law pair_length:
  for ok: Bool
  for +left: +List<U32>
  for +right: +List<U32>
  {Basic.lengths(I.pair_checked(ok, left, right)) == Bool.pick(Maybe<&2, Nat>, ok, Some{32n}, None{}) : Maybe<&2, Nat>}
def pair_length(ok, left, right):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(Nat, Maybe<&2, Nat>, n => Some{n},
        List.length(&2, U32, H.hash(List.append(&2, U32, left, right))), 32n,
        Hash.hash_length(List.append(&2, U32, left, right)))

law hash_pair_length:
  for +left: +List<U32>
  for +right: +List<U32>
  {Basic.lengths(I.hash_pair(left, right)) == Bool.pick(Maybe<&2, Nat>, Bool.and(Runtime.valid_bytes(32n, left), Runtime.valid_bytes(32n, right)), Some{32n}, None{}) : Maybe<&2, Nat>}
def hash_pair_length(left, right):
  pair_length(Bool.and(Runtime.valid_bytes(32n, left), Runtime.valid_bytes(32n, right)), left, right)

law fips_word_bytes:
  for +w: U32
  {P.bytes_domain(FIPS.word_octets(w)) == True{} : Bool}
def fips_word_bytes(w):
  V.and_true(U32.is_lt(U32.and(U32.shrn(w, 24n), 255), 256), P.bytes_domain([U32.and(U32.shrn(w, 16n), 255), U32.and(U32.shrn(w, 8n), 255), U32.and(w, 255)]), W.masked_byte_bound(U32.shrn(w, 24n)), V.and_true(U32.is_lt(U32.and(U32.shrn(w, 16n), 255), 256), P.bytes_domain([U32.and(U32.shrn(w, 8n), 255), U32.and(w, 255)]), W.masked_byte_bound(U32.shrn(w, 16n)), V.and_true(U32.is_lt(U32.and(U32.shrn(w, 8n), 255), 256), P.bytes_domain([U32.and(w, 255)]), W.masked_byte_bound(U32.shrn(w, 8n)), V.and_true(U32.is_lt(U32.and(w, 255), 256), P.bytes_domain([]), W.masked_byte_bound(w), {==}))))

law fips_digest_bytes:
  for +ws: +List<U32>
  {P.bytes_domain(FIPS.digest_octets(ws)) == True{} : Bool}
def fips_digest_bytes(ws):
  match ws:
    case Nil{}: {==}
    case Con{w, t}:
      V.append_domain(FIPS.word_octets(w), FIPS.digest_octets(t), fips_word_bytes(w), fips_digest_bytes(t))

law runtime_hash_bytes:
  for +xs: +List<U32>
  {P.bytes_domain(H.hash(xs)) == True{} : Bool}
def runtime_hash_bytes(xs):
  %Equal.sym(+List<U32>, H.hash(xs), FIPS.sha256_bytes(xs), Hash.hash_refines_fips(xs)) :
    {P.bytes_domain(_) == True{} : Bool}
  fips_digest_bytes(FIPS.sha256(xs))

law pair_domain:
  for ok: Bool
  for +left: +List<U32>
  for +right: +List<U32>
  V.byte_result(I.pair_checked(ok, left, right))
def pair_domain(ok, left, right):
  match ok:
    case False{}: Unit{}
    case True{}: runtime_hash_bytes(List.append(&2, U32, left, right))

law hash_pair_byte_domain:
  for +left: +List<U32>
  for +right: +List<U32>
  V.byte_result(I.hash_pair(left, right))
def hash_pair_byte_domain(left, right):
  pair_domain(Bool.and(Runtime.valid_bytes(32n, left), Runtime.valid_bytes(32n, right)), left, right)

law pair_accepts:
  for ok: Bool
  for left: +List<U32>
  for right: +List<U32>
  {Runtime.is_some(I.pair_checked(ok, left, right)) == ok : Bool}
def pair_accepts(ok, left, right):
  match ok:
    case False{}: {==}
    case True{}: {==}

law hash_pair_rejection:
  for +left: +List<U32>
  for +right: +List<U32>
  {Runtime.is_some(I.hash_pair(left, right)) == Bool.and(P.byte_scope(32n, left), P.byte_scope(32n, right)) : Bool}
def hash_pair_rejection(left, right):
  %Basic.byte_scope_correct(32n, left) : {Runtime.is_some(I.hash_pair(left, right)) == Bool.and(_, P.byte_scope(32n, right)) : Bool}
  %Basic.byte_scope_correct(32n, right) : {Runtime.is_some(I.hash_pair(left, right)) == Bool.and(Runtime.valid_bytes(32n, left), _) : Bool}
  pair_accepts(Bool.and(Runtime.valid_bytes(32n, left), Runtime.valid_bytes(32n, right)), left, right)

law zero_hash_correct:
  for +depth: Nat
  {I.zero_hash(depth) == S.zero_subtree(depth) : +List<U32>}
def zero_hash_correct(depth):
  match depth:
    case 0n: {==}
    case 1n+p:
      %zero_hash_correct(p) :
        {I.zero_hash(1n+p) == FIPS.sha256_bytes(List.append(&2, U32, _, _)) : +List<U32>}
      Hash.hash_refines_fips(List.append(&2, U32, I.zero_hash(p), I.zero_hash(p)))

law zero_hash_length:
  for +depth: Nat
  {List.length(&2, U32, I.zero_hash(depth)) == 32n : Nat}
def zero_hash_length(depth):
  match depth:
    case 0n: {==}
    case 1n+p: Hash.hash_length(List.append(&2, U32, I.zero_hash(p), I.zero_hash(p)))

law zero_hash_bytes:
  for +depth: Nat
  {P.bytes_domain(I.zero_hash(depth)) == True{} : Bool}
def zero_hash_bytes(depth):
  match depth:
    case 0n: {==}
    case 1n+p: runtime_hash_bytes(List.append(&2, U32, I.zero_hash(p), I.zero_hash(p)))

law zero_hash_chunk:
  for +depth: Nat
  {P.byte_scope(32n, I.zero_hash(depth)) == True{} : Bool}
def zero_hash_chunk(depth):
  %zero_hash_length(depth) : {P.byte_scope(_, I.zero_hash(depth)) == True{} : Bool}
  %Equal.sym(Bool, P.byte_scope(List.length(&2, U32, I.zero_hash(depth)), I.zero_hash(depth)), P.bytes_domain(I.zero_hash(depth)), V.scope_of_domain(I.zero_hash(depth))) :
    {_ == True{} : Bool}
  zero_hash_bytes(depth)
