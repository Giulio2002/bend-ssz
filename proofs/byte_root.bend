import Base
import ../src/byte_root.bend as I
import ../src/bytes.bend as B
import ../src/packing.bend as Pack
import ../src/limits.bend as M
import ../src/primitives.bend as R
import ../spec/byte_root.bend as S
import ../spec/bytes.bend as SB
import ../spec/packing.bend as SP
import ../spec/primitives.bend as P
import ../spec/limits.bend as SL
import ../spec/tree.bend as ST
import ./bytes.bend as Bytes
import ./packing.bend as Packing
import ./limits.bend as Limits
import ./tree.bend as Tree
import ./integer_decoding.bend as Decode
import ./nat_order.bend as N
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./primitives.bend as Basic

law vector_bytes:
  for +n: Nat
  for +xs: +List<U32>
  for e: {SB.vector_domain(n, xs) == True{} : Bool}
  {P.bytes_domain(xs) == True{} : Bool}
def vector_bytes(n, xs, e):
  match n:
    case 0n: Empty.absurd({P.bytes_domain(xs) == True{} : Bool}, W.false_true(e))
    case 1n+p: Decode.scope_domain(1n+p, xs, V.and_left(P.byte_scope(1n+p, xs), SB.size_fits(1n+p), e))

law packed_domain:
  for +xs: +List<U32>
  for e: {P.bytes_domain(xs) == True{} : Bool}
  {SP.chunks_domain(S.chunks(xs)) == True{} : Bool}
def packed_domain(xs, e):
  %Packing.scan_correct(xs, 31n, [], []) : {SP.chunks_domain(_) == True{} : Bool}
  Packing.scan_domain(xs, 31n, [], [], e, {==}, {==}, {==})

law default_valid:
  for +chunks: +List<+List<U32>>
  for +depth: Nat
  for minimal: {SL.minimal(List.length(&2, +List<U32>, chunks), depth) == True{} : Bool}
  for domain: {SP.chunks_domain(chunks) == True{} : Bool}
  {M.merkleize_default(chunks) == Some{ST.tree(depth, chunks)} : Maybe<&2, +List<U32>>}
def default_valid(chunks, depth, minimal, domain):
  %Equal.sym(Maybe<&2, +List<U32>>, M.merkleize_default(chunks), SL.at_depth(List.length(&2, +List<U32>, chunks), depth, chunks), Limits.default_correct(chunks, depth, minimal)) :
    {_ == Some{ST.tree(depth, chunks)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Bool.and(SP.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), List.length(&2, +List<U32>, chunks))), True{}, V.and_true(SP.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), List.length(&2, +List<U32>, chunks)), domain, N.reflexive(List.length(&2, +List<U32>, chunks)))) :
    {ST.checked(_, depth, chunks) == Some{ST.tree(depth, chunks)} : Maybe<&2, +List<U32>>}
  {==}

law gate_correct:
  for +ok: Bool
  for +xs: +List<U32>
  for +depth: Nat
  for minimal: {S.canonical_depth(xs, depth) == True{} : Bool}
  for valid: {ok == True{} : Bool} -> {P.bytes_domain(xs) == True{} : Bool}
  {I.gate(ok, xs) == S.gate(ok, depth, xs) : Maybe<&2, +List<U32>>}
def gate_correct(ok, xs, depth, minimal, valid):
  match ok:
    case False{}: {==}
    case True{}:
      %Equal.sym(+List<+List<U32>>, Pack.scan(xs, 31n, [], []), S.chunks(xs), Packing.scan_correct(xs, 31n, [], [])) :
        {M.merkleize_default(_) == Some{ST.tree(depth, S.chunks(xs))} : Maybe<&2, +List<U32>>}
      default_valid(S.chunks(xs), depth, minimal, packed_domain(xs, valid({==})))

law hash_tree_root_correct:
  for +n: Nat
  for +xs: +List<U32>
  for +depth: Nat
  for minimal: {S.canonical_depth(xs, depth) == True{} : Bool}
  {I.hash_tree_root(n, xs) == S.at_depth(n, depth, xs) : Maybe<&2, +List<U32>>}
def hash_tree_root_correct(n, xs, depth, minimal):
  %Bytes.vector_domain_correct(n, xs) : {I.hash_tree_root(n, xs) == S.gate(_, depth, xs) : Maybe<&2, +List<U32>>}
  gate_correct(B.vector_valid(n, xs), xs, depth, minimal,
    e => vector_bytes(n, xs, Equal.trans(Bool, SB.vector_domain(n, xs), B.vector_valid(n, xs), True{}, Equal.sym(Bool, B.vector_valid(n, xs), SB.vector_domain(n, xs), Bytes.vector_domain_correct(n, xs)), e)))

law gate_scope:
  for ok: Bool
  for +xs: +List<U32>
  Tree.result_scope(I.gate(ok, xs))
def gate_scope(ok, xs):
  match ok:
    case False{}: Unit{}
    case True{}: Limits.merkleize_scope(List.length(&2, +List<U32>, Pack.scan(xs, 31n, [], [])), Pack.scan(xs, 31n, [], []))

law hash_tree_root_scope:
  for +n: Nat
  for +xs: +List<U32>
  Tree.result_scope(I.hash_tree_root(n, xs))
def hash_tree_root_scope(n, xs): gate_scope(B.vector_valid(n, xs), xs)

law hash_tree_root_length:
  for +n: Nat
  for +xs: +List<U32>
  {Basic.lengths(I.hash_tree_root(n, xs)) == Basic.expected_root_length(I.hash_tree_root(n, xs)) : Maybe<&2, Nat>}
def hash_tree_root_length(n, xs): Tree.result_length(I.hash_tree_root(n, xs), hash_tree_root_scope(n, xs))

# A witness is constructed for EVERY raw input, independently of vector validity.
# It is proved to satisfy the independent canonical-depth predicate.
def witness(+xs: +List<U32>) -> Nat: M.depth(List.length(&2, +List<U32>, S.chunks(xs)))

law witness_valid:
  for +xs: +List<U32>
  {S.canonical_depth(xs, witness(xs)) == True{} : Bool}
def witness_valid(xs): Limits.depth_minimal(List.length(&2, +List<U32>, S.chunks(xs)))

law hash_tree_root_refinement:
  for +n: Nat
  for +xs: +List<U32>
  {I.hash_tree_root(n, xs) == S.at_depth(n, witness(xs), xs) : Maybe<&2, +List<U32>>}
def hash_tree_root_refinement(n, xs): hash_tree_root_correct(n, xs, witness(xs), witness_valid(xs))

law model_acceptance:
  for +ok: Bool
  for depth: Nat
  for xs: +List<U32>
  {R.is_some(S.gate(ok, depth, xs)) == ok : Bool}
def model_acceptance(ok, depth, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law hash_tree_root_rejection:
  for +n: Nat
  for +xs: +List<U32>
  {R.is_some(I.hash_tree_root(n, xs)) == SB.vector_domain(n, xs) : Bool}
def hash_tree_root_rejection(n, xs):
  %Equal.sym(Maybe<&2, +List<U32>>, I.hash_tree_root(n, xs), S.at_depth(n, witness(xs), xs), hash_tree_root_refinement(n, xs)) :
    {R.is_some(_) == SB.vector_domain(n, xs) : Bool}
  model_acceptance(SB.vector_domain(n, xs), witness(xs), xs)
