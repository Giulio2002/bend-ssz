import Base
import ./prefix.bend as Prefix
import ../src/byte_list.bend as I
import ../spec/byte_list.bend as S
import ../src/primitives.bend as R
import ../spec/primitives.bend as P
import ../src/packing.bend as Pack
import ../spec/packing.bend as SP
import ../src/limits.bend as M
import ../spec/limits.bend as MS
import ../src/nat_bytes.bend as L
import ../spec/nat_bytes.bend as LS
import ../src/bit_root.bend as Mix
import ../spec/bit_root.bend as SMix
import ./packing.bend as Packing
import ./bytes.bend as Bytes
import ./primitives.bend as Basic
import ./primitive_invariants.bend as V
import ./bit_chunk_count.bend as Count
import ./nat_bytes.bend as Length
import ./bit_list_root.bend as Mixing
import ./limits.bend as Limits
import ./tree.bend as Tree
import ./nat_order.bend as Order

law domain_correct:
  for +capacity: Nat
  for +xs: +List<U32>
  {I.valid(capacity, xs) == S.domain(capacity, xs) : Bool}
def domain_correct(capacity, xs):
  %Packing.valid_go_correct(xs, True{}) : {I.valid(capacity, xs) == Bool.and(Bool.and(_, Nat.is_le(List.length(&2, U32, xs), capacity)), LS.fits(4n, List.length(&2, U32, xs))) : Bool}
  Equal.cong(Bool, Bool, ok => Bool.and(Bool.and(Pack.valid_go(xs, True{}), Nat.is_le(List.length(&2, U32, xs), capacity)), ok), R.is_some(L.encode(4n, List.length(&2, U32, xs))), LS.fits(4n, List.length(&2, U32, xs)), Length.encode_acceptance(4n, List.length(&2, U32, xs)))

law serialize_correct:
  for +capacity: Nat
  for +xs: +List<U32>
  {I.serialize(capacity, xs) == S.encoding(capacity, xs) : Maybe<&2, +List<U32>>}
def serialize_correct(capacity, xs):
  %domain_correct(capacity, xs) : {I.serialize(capacity, xs) == P.optional(_, xs) : Maybe<&2, +List<U32>>}
  Prefix.accept_correct(I.valid(capacity, xs), xs)

law deserialize_correct:
  for +capacity: Nat
  for +xs: +List<U32>
  {I.deserialize(capacity, xs) == S.decoding(capacity, xs) : Maybe<&2, +List<U32>>}
def deserialize_correct(capacity, xs): serialize_correct(capacity, xs)

law rejection_correct:
  for +capacity: Nat
  for +xs: +List<U32>
  {R.is_some(I.deserialize(capacity, xs)) == S.domain(capacity, xs) : Bool}
def rejection_correct(capacity, xs):
  %Equal.sym(Maybe<&2, +List<U32>>, I.deserialize(capacity, xs), S.decoding(capacity, xs), deserialize_correct(capacity, xs)) : {R.is_some(_) == S.domain(capacity, xs) : Bool}
  Length.optional_acceptance(S.domain(capacity, xs), xs)

law accepted_canonical:
  for +capacity: Nat
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +e: {I.deserialize(capacity, xs) == Some{ys} : Maybe<&2, +List<U32>>}
  {S.encoding(capacity, ys) == Some{xs} : Maybe<&2, +List<U32>>}
def accepted_canonical(capacity, xs, ys, e):
  %Bytes.accepted_identity(I.valid(capacity, xs), xs, ys, e) : {S.encoding(capacity, _) == Some{xs} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, xs, ys, Bytes.accepted_identity(I.valid(capacity, xs), xs, ys, e)) : {S.encoding(capacity, xs) == Some{_} : Maybe<&2, +List<U32>>}
  Equal.trans(Maybe<&2, +List<U32>>, S.encoding(capacity, xs), I.deserialize(capacity, xs), Some{ys}, Equal.sym(Maybe<&2, +List<U32>>, I.deserialize(capacity, xs), S.encoding(capacity, xs), deserialize_correct(capacity, xs)), e)

law runtime_complete:
  for +capacity: Nat
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +e: {I.serialize(capacity, xs) == Some{ys} : Maybe<&2, +List<U32>>}
  {I.deserialize(capacity, ys) == Some{xs} : Maybe<&2, +List<U32>>}
def runtime_complete(capacity, xs, ys, e):
  %Bytes.accepted_identity(I.valid(capacity, xs), xs, ys, e) : {I.deserialize(capacity, _) == Some{xs} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, xs, ys, Bytes.accepted_identity(I.valid(capacity, xs), xs, ys, e)) : {I.deserialize(capacity, xs) == Some{_} : Maybe<&2, +List<U32>>}
  e

law decoding_complete:
  for +capacity: Nat
  for +xs: +List<U32>
  for +ys: +List<U32>
  for e: {S.encoding(capacity, xs) == Some{ys} : Maybe<&2, +List<U32>>}
  {I.deserialize(capacity, ys) == Some{xs} : Maybe<&2, +List<U32>>}
def decoding_complete(capacity, xs, ys, e):
  runtime_complete(capacity, xs, ys, Equal.trans(Maybe<&2, +List<U32>>, I.serialize(capacity, xs), S.encoding(capacity, xs), Some{ys}, serialize_correct(capacity, xs), e))

law gate_correct:
  for +ok: Bool
  for +capacity: Nat
  for +depth: Nat
  for +xs: +List<U32>
  for minimal: {MS.minimal(S.chunk_limit(capacity), depth) == True{} : Bool}
  for bytes: {ok == True{} : Bool} -> {P.bytes_domain(xs) == True{} : Bool}
  {I.root_gate(ok, capacity, xs) == S.root_gate(ok, capacity, depth, xs) : Maybe<&2, +List<U32>>}
def gate_correct(ok, capacity, depth, xs, minimal, bytes):
  match ok:
    case False{}: {==}
    case True{}:
      %Packing.scan_correct(xs, 31n, [], []) : {I.root_gate(True{}, capacity, xs) == SMix.mix_length_bytes(MS.at_depth(I.chunk_limit(capacity), depth, _), LS.encoding(32n, List.length(&2, U32, xs))) : Maybe<&2, +List<U32>>}
      %Limits.merkleize_correct(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], []), depth, minimal) : {I.root_gate(True{}, capacity, xs) == SMix.mix_length_bytes(_, LS.encoding(32n, List.length(&2, U32, xs))) : Maybe<&2, +List<U32>>}
      %Length.encode_correct(32n, List.length(&2, U32, xs)) : {I.root_gate(True{}, capacity, xs) == SMix.mix_length_bytes(M.merkleize(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], [])), _) : Maybe<&2, +List<U32>>}
      Mixing.mix_correct(M.merkleize(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], [])), L.encode(32n, List.length(&2, U32, xs)), Limits.merkleize_scope(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], [])), Length.length_scope(List.length(&2, U32, xs)))

law valid_bytes:
  for +capacity: Nat
  for +xs: +List<U32>
  for valid: {I.valid(capacity, xs) == True{} : Bool}
  {P.bytes_domain(xs) == True{} : Bool}
def valid_bytes(capacity, xs, valid):
  V.and_left(P.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), capacity), V.and_left(Bool.and(P.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), capacity)), LS.fits(4n, List.length(&2, U32, xs)), Equal.trans(Bool, S.domain(capacity, xs), I.valid(capacity, xs), True{}, Equal.sym(Bool, I.valid(capacity, xs), S.domain(capacity, xs), domain_correct(capacity, xs)), valid)))

law hash_tree_root_correct:
  for +capacity: Nat
  for +depth: Nat
  for +xs: +List<U32>
  for minimal: {MS.minimal(S.chunk_limit(capacity), depth) == True{} : Bool}
  {I.hash_tree_root(capacity, xs) == S.at_depth(capacity, depth, xs) : Maybe<&2, +List<U32>>}
def hash_tree_root_correct(capacity, depth, xs, minimal):
  %domain_correct(capacity, xs) : {I.hash_tree_root(capacity, xs) == S.root_gate(_, capacity, depth, xs) : Maybe<&2, +List<U32>>}
  gate_correct(I.valid(capacity, xs), capacity, depth, xs, minimal, e => valid_bytes(capacity, xs, e))

law selected_correct:
  for +capacity: Nat
  for +xs: +List<U32>
  {I.hash_tree_root(capacity, xs) == S.at_depth(capacity, M.depth(I.chunk_limit(capacity)), xs) : Maybe<&2, +List<U32>>}
def selected_correct(capacity, xs):
  hash_tree_root_correct(capacity, M.depth(I.chunk_limit(capacity)), xs, Limits.depth_minimal(I.chunk_limit(capacity)))

law gate_scope:
  for ok: Bool
  for +capacity: Nat
  for +xs: +List<U32>
  Tree.result_scope(I.root_gate(ok, capacity, xs))
def gate_scope(ok, capacity, xs):
  match ok:
    case False{}: Unit{}
    case True{}:
      Mixing.mix_scope(M.merkleize(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], [])), L.encode(32n, List.length(&2, U32, xs)), Limits.merkleize_scope(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], [])), Length.length_scope(List.length(&2, U32, xs)))

law root_scope:
  for +capacity: Nat
  for +xs: +List<U32>
  Tree.result_scope(I.hash_tree_root(capacity, xs))
def root_scope(capacity, xs): gate_scope(I.valid(capacity, xs), capacity, xs)

law count_bytes:
  for +n: Nat
  {Count.count(n, 31n, False{}) == I.chunk_limit(n) : Nat}
def count_bytes(n):
  match n:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n: {==}
    case 5n: {==}
    case 6n: {==}
    case 7n: {==}
    case 8n: {==}
    case 9n: {==}
    case 10n: {==}
    case 11n: {==}
    case 12n: {==}
    case 13n: {==}
    case 14n: {==}
    case 15n: {==}
    case 16n: {==}
    case 17n: {==}
    case 18n: {==}
    case 19n: {==}
    case 20n: {==}
    case 21n: {==}
    case 22n: {==}
    case 23n: {==}
    case 24n: {==}
    case 25n: {==}
    case 26n: {==}
    case 27n: {==}
    case 28n: {==}
    case 29n: {==}
    case 30n: {==}
    case 31n: {==}
    case 32n+p:
      %Equal.sym(Nat, Pair.fst(Nat, Nat, Nat.divmod.go(Nat.add(p, 31n), 31n, 1n, 0n)), 1n+I.chunk_limit(p), Count.quotient_successor(Nat.add(p, 31n), 31n, 0n, 0n)) : {1n+Count.count(p, 31n, False{}) == _ : Nat}
      Equal.cong(Nat, Nat, x => 1n+x, Count.count(p, 31n, False{}), I.chunk_limit(p), count_bytes(p))

law packed_count:
  for +xs: +List<U32>
  {List.length(&2, +List<U32>, Pack.scan(xs, 31n, [], [])) == I.chunk_limit(List.length(&2, U32, xs)) : Nat}
def packed_count(xs):
  %count_bytes(List.length(&2, U32, xs)) : {List.length(&2, +List<U32>, Pack.scan(xs, 31n, [], [])) == _ : Nat}
  %Packing.add_zero(Count.count(List.length(&2, U32, xs), 31n, False{})) : {List.length(&2, +List<U32>, Pack.scan(xs, 31n, [], [])) == _ : Nat}
  Count.scan_length(xs, 31n, [], [])

law packed_bound:
  for +capacity: Nat
  for +xs: +List<U32>
  for bound: {Nat.is_le(List.length(&2, U32, xs), capacity) == True{} : Bool}
  {Nat.is_le(List.length(&2, +List<U32>, Pack.scan(xs, 31n, [], [])), I.chunk_limit(capacity)) == True{} : Bool}
def packed_bound(capacity, xs, bound):
  %Equal.sym(Nat, List.length(&2, +List<U32>, Pack.scan(xs, 31n, [], [])), I.chunk_limit(List.length(&2, U32, xs)), packed_count(xs)) : {Nat.is_le(_, I.chunk_limit(capacity)) == True{} : Bool}
  Count.quotient_monotone(Nat.add(List.length(&2, U32, xs), 31n), Nat.add(capacity, 31n), 31n, 0n, 0n, Order.add_right(List.length(&2, U32, xs), capacity, 31n, bound))

law valid_bound:
  for +capacity: Nat
  for +xs: +List<U32>
  for valid: {I.valid(capacity, xs) == True{} : Bool}
  {Nat.is_le(List.length(&2, U32, xs), capacity) == True{} : Bool}
def valid_bound(capacity, xs, valid):
  V.and_right(P.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), capacity), V.and_left(Bool.and(P.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), capacity)), LS.fits(4n, List.length(&2, U32, xs)), Equal.trans(Bool, S.domain(capacity, xs), I.valid(capacity, xs), True{}, Equal.sym(Bool, I.valid(capacity, xs), S.domain(capacity, xs), domain_correct(capacity, xs)), valid)))

law data_total:
  for +capacity: Nat
  for +xs: +List<U32>
  for +valid: {I.valid(capacity, xs) == True{} : Bool}
  {R.is_some(M.merkleize(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], []))) == True{} : Bool}
def data_total(capacity, xs, valid):
  %V.and_true(SP.chunks_domain(Pack.scan(xs, 31n, [], [])), Nat.is_le(List.length(&2, +List<U32>, Pack.scan(xs, 31n, [], [])), I.chunk_limit(capacity)), Packing.scan_domain(xs, 31n, [], [], valid_bytes(capacity, xs, valid), {==}, {==}, {==}), packed_bound(capacity, xs, valid_bound(capacity, xs, valid))) : {R.is_some(M.merkleize(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], []))) == _ : Bool}
  Limits.merkleize_rejection(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], []))

law gate_acceptance:
  for +ok: Bool
  for +capacity: Nat
  for +xs: +List<U32>
  for valid: {ok == True{} : Bool} -> {I.valid(capacity, xs) == True{} : Bool}
  {R.is_some(I.root_gate(ok, capacity, xs)) == Bool.and(ok, LS.fits(32n, List.length(&2, U32, xs))) : Bool}
def gate_acceptance(ok, capacity, xs, valid):
  match ok:
    case False{}: {==}
    case True{}:
      %data_total(capacity, xs, valid({==})) : {R.is_some(I.root_gate(True{}, capacity, xs)) == Bool.and(_, LS.fits(32n, List.length(&2, U32, xs))) : Bool}
      %Length.encode_acceptance(32n, List.length(&2, U32, xs)) : {R.is_some(I.root_gate(True{}, capacity, xs)) == Bool.and(R.is_some(M.merkleize(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], []))), _) : Bool}
      Mixing.mix_acceptance(M.merkleize(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], [])), L.encode(32n, List.length(&2, U32, xs)), Limits.merkleize_scope(I.chunk_limit(capacity), Pack.scan(xs, 31n, [], [])), Length.length_scope(List.length(&2, U32, xs)))

law root_acceptance:
  for +capacity: Nat
  for +xs: +List<U32>
  {R.is_some(I.hash_tree_root(capacity, xs)) == Bool.and(I.valid(capacity, xs), LS.fits(32n, List.length(&2, U32, xs))) : Bool}
def root_acceptance(capacity, xs): gate_acceptance(I.valid(capacity, xs), capacity, xs, e => e)

law valid_size:
  for +capacity: Nat
  for +xs: +List<U32>
  for valid: {I.valid(capacity, xs) == True{} : Bool}
  {LS.fits(4n, List.length(&2, U32, xs)) == True{} : Bool}
def valid_size(capacity, xs, valid):
  V.and_right(Bool.and(P.bytes_domain(xs), Nat.is_le(List.length(&2, U32, xs), capacity)), LS.fits(4n, List.length(&2, U32, xs)), Equal.trans(Bool, S.domain(capacity, xs), I.valid(capacity, xs), True{}, Equal.sym(Bool, I.valid(capacity, xs), S.domain(capacity, xs), domain_correct(capacity, xs)), valid))

law root_total:
  for +capacity: Nat
  for +xs: +List<U32>
  for +valid: {I.valid(capacity, xs) == True{} : Bool}
  {R.is_some(I.hash_tree_root(capacity, xs)) == True{} : Bool}
def root_total(capacity, xs, valid):
  %V.and_true(I.valid(capacity, xs), LS.fits(32n, List.length(&2, U32, xs)), valid, Length.fits_extend(4n, 28n, List.length(&2, U32, xs), valid_size(capacity, xs, valid))) : {R.is_some(I.hash_tree_root(capacity, xs)) == _ : Bool}
  root_acceptance(capacity, xs)

law gate_exact_acceptance:
  for +ok: Bool
  for +capacity: Nat
  for +xs: +List<U32>
  for valid: {ok == True{} : Bool} -> {I.valid(capacity, xs) == True{} : Bool}
  {R.is_some(I.root_gate(ok, capacity, xs)) == ok : Bool}
def gate_exact_acceptance(ok, capacity, xs, valid):
  match ok:
    case False{}: {==}
    case True{}:
      +accepted = valid({==})
      %Length.fits_extend(4n, 28n, List.length(&2, U32, xs), valid_size(capacity, xs, accepted)) : {R.is_some(I.root_gate(True{}, capacity, xs)) == _ : Bool}
      gate_acceptance(True{}, capacity, xs, e => accepted)

law root_exact_acceptance:
  for +capacity: Nat
  for +xs: +List<U32>
  {R.is_some(I.hash_tree_root(capacity, xs)) == I.valid(capacity, xs) : Bool}
def root_exact_acceptance(capacity, xs): gate_exact_acceptance(I.valid(capacity, xs), capacity, xs, e => e)

law root_length:
  for +capacity: Nat
  for +xs: +List<U32>
  {Basic.lengths(I.hash_tree_root(capacity, xs)) == Basic.expected_root_length(I.hash_tree_root(capacity, xs)) : Maybe<&2, Nat>}
def root_length(capacity, xs): Tree.result_length(I.hash_tree_root(capacity, xs), root_scope(capacity, xs))
