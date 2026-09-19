import Base
import ../src/tree.bend as RuntimeTree
import ../src/primitives.bend as R
import ../spec/packing.bend as Chunks
import ./tree.bend as Tree
import ./bytes.bend as B
import ./primitives.bend as Basic
import ../src/limits.bend as I
import ../spec/limits.bend as S
import ../spec/tree.bend as T
import ./nat_order.bend as N
import ./packing.bend as Pack
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

law double_positive:
  for +n: Nat
  for e: {Nat.is_le(1n, n) == True{} : Bool}
  {Nat.is_le(1n, Nat.double(n)) == True{} : Bool}
def double_positive(n, e):
  match n:
    case 0n: Empty.absurd({False{} == True{} : Bool}, W.false_true(e))
    case 1n+p: {==}

law capacity_positive:
  for +depth: Nat
  {Nat.is_le(1n, T.capacity(depth)) == True{} : Bool}
def capacity_positive(depth):
  match depth:
    case 0n: {==}
    case 1n+p: double_positive(T.capacity(p), capacity_positive(p))

law choose_minimal:
  for +ok: Bool
  for +limit: Nat
  for +depth: Nat
  for -next: Unit -> Nat
  for e: {ok == Nat.is_le(limit, T.capacity(depth)) : Bool}
  for lower: {S.lower(limit, depth) == True{} : Bool}
  for advance: {Nat.is_le(limit, T.capacity(depth)) == False{} : Bool} -> {S.minimal(limit, next(Unit{})) == True{} : Bool}
  {S.minimal(limit, I.choose(ok, depth, next)) == True{} : Bool}
def choose_minimal(ok, limit, depth, next, e, lower, advance):
  match ok:
    case True{}:
      V.and_true(Nat.is_le(limit, T.capacity(depth)), S.lower(limit, depth), Equal.sym(Bool, True{}, Nat.is_le(limit, T.capacity(depth)), e), lower)
    case False{}: advance(Equal.sym(Bool, False{}, Nat.is_le(limit, T.capacity(depth)), e))

law search_minimal:
  for +fuel: Nat
  for +limit: Nat
  for +depth: Nat
  for budget: {Nat.is_le(limit, Nat.add(T.capacity(depth), fuel)) == True{} : Bool}
  for lower: {S.lower(limit, depth) == True{} : Bool}
  {S.minimal(limit, I.search(fuel, limit, depth, T.capacity(depth))) == True{} : Bool}
def search_minimal(fuel, limit, depth, budget, lower):
  match fuel:
    case 0n:
      %Pack.add_zero(T.capacity(depth)) :
        {Bool.and(Nat.is_le(limit, _), S.lower(limit, depth)) == True{} : Bool}
      V.and_true(Nat.is_le(limit, Nat.add(T.capacity(depth), 0n)), S.lower(limit, depth), budget, lower)
    case 1n+p:
      choose_minimal(Nat.is_le(limit, T.capacity(depth)), limit, depth,
        u => I.search(p, limit, 1n+depth, Nat.double(T.capacity(depth))), {==}, lower,
        e => search_minimal(p, limit, 1n+depth,
          N.advance_budget(limit, T.capacity(depth), p, capacity_positive(depth), budget),
          N.not_le_lt(limit, T.capacity(depth), e)))

law depth_minimal:
  for +limit: Nat
  {S.minimal(limit, I.depth(limit)) == True{} : Bool}
def depth_minimal(limit):
  search_minimal(limit, limit, 0n, N.step_right(limit, limit, N.reflexive(limit)), {==})

law depth_covers:
  for +limit: Nat
  {Nat.is_le(limit, T.capacity(I.depth(limit))) == True{} : Bool}
def depth_covers(limit):
  V.and_left(Nat.is_le(limit, T.capacity(I.depth(limit))), S.lower(limit, I.depth(limit)), depth_minimal(limit))

law capacity_monotone:
  for +a: Nat
  for +b: Nat
  for e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(T.capacity(a), T.capacity(b)) == True{} : Bool}
def capacity_monotone(a, b, e):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: capacity_positive(1n+q)
    case 1n+p 0n: Empty.absurd({Nat.is_le(T.capacity(1n+p), 1n) == True{} : Bool}, W.false_true(e))
    case 1n+p 1n+q: N.double_monotone(T.capacity(p), T.capacity(q), capacity_monotone(p, q, e))

law no_shallower:
  for +limit: Nat
  for +a: Nat
  for +b: Nat
  for cover: {Nat.is_le(limit, T.capacity(a)) == True{} : Bool}
  for lower: {S.lower(limit, b) == True{} : Bool}
  for less: {Nat.is_lt(a, b) == True{} : Bool}
  Empty
def no_shallower(limit, a, b, cover, lower, less):
  match b:
    case 0n: N.lt_zero(a, less)
    case 1n+q:
      N.le_lt_conflict(limit, T.capacity(q), N.transitive(limit, T.capacity(a), T.capacity(q), cover, capacity_monotone(a, q, N.lt_succ_le(a, q, less))), lower)

law minimal_unique:
  for +limit: Nat
  for +a: Nat
  for +b: Nat
  for +ea: {S.minimal(limit, a) == True{} : Bool}
  for +eb: {S.minimal(limit, b) == True{} : Bool}
  {a == b : Nat}
def minimal_unique(limit, a, b, ea, eb):
  N.equal_if_neither_less(a, b,
    e => no_shallower(limit, a, b,
      V.and_left(Nat.is_le(limit, T.capacity(a)), S.lower(limit, a), ea),
      V.and_right(Nat.is_le(limit, T.capacity(b)), S.lower(limit, b), eb), e),
    e => no_shallower(limit, b, a,
      V.and_left(Nat.is_le(limit, T.capacity(b)), S.lower(limit, b), eb),
      V.and_right(Nat.is_le(limit, T.capacity(a)), S.lower(limit, a), ea), e))

law model_when_fits:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  for e: {Nat.is_le(List.length(&2, +List<U32>, chunks), T.capacity(depth)) == True{} : Bool}
  {T.merkleize_at_depth(depth, chunks) == T.checked(Chunks.chunks_domain(chunks), depth, chunks) : Maybe<&2, +List<U32>>}
def model_when_fits(depth, chunks, e):
  %B.and_identity(Chunks.chunks_domain(chunks)) : {T.merkleize_at_depth(depth, chunks) == T.checked(_, depth, chunks) : Maybe<&2, +List<U32>>}
  %e : {T.merkleize_at_depth(depth, chunks) == T.checked(Bool.and(Chunks.chunks_domain(chunks), _), depth, chunks) : Maybe<&2, +List<U32>>}
  {==}

law tree_when_fits:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  for e: {Nat.is_le(List.length(&2, +List<U32>, chunks), T.capacity(depth)) == True{} : Bool}
  {RuntimeTree.merkleize_at_depth(depth, chunks) == T.checked(Chunks.chunks_domain(chunks), depth, chunks) : Maybe<&2, +List<U32>>}
def tree_when_fits(depth, chunks, e):
  Equal.trans(Maybe<&2, +List<U32>>, RuntimeTree.merkleize_at_depth(depth, chunks), T.merkleize_at_depth(depth, chunks), T.checked(Chunks.chunks_domain(chunks), depth, chunks), Tree.merkleize_at_depth_correct(depth, chunks), model_when_fits(depth, chunks, e))

law gate_correct:
  for +ok: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for e: {ok == Nat.is_le(List.length(&2, +List<U32>, chunks), limit) : Bool}
  {I.gate(ok, limit, chunks) == T.checked(Bool.and(Chunks.chunks_domain(chunks), ok), I.depth(limit), chunks) : Maybe<&2, +List<U32>>}
def gate_correct(ok, limit, chunks, e):
  match ok:
    case False{}:
      %Equal.sym(Bool, Bool.and(Chunks.chunks_domain(chunks), False{}), False{}, B.and_zero(Chunks.chunks_domain(chunks))) :
        {None{} == T.checked(_, I.depth(limit), chunks) : Maybe<&2, +List<U32>>}
      {==}
    case True{}:
      %Equal.sym(Bool, Bool.and(Chunks.chunks_domain(chunks), True{}), Chunks.chunks_domain(chunks), B.and_identity(Chunks.chunks_domain(chunks))) :
        {I.gate(True{}, limit, chunks) == T.checked(_, I.depth(limit), chunks) : Maybe<&2, +List<U32>>}
      tree_when_fits(I.depth(limit), chunks,
        N.transitive(List.length(&2, +List<U32>, chunks), limit, T.capacity(I.depth(limit)), Equal.sym(Bool, True{}, Nat.is_le(List.length(&2, +List<U32>, chunks), limit), e), depth_covers(limit)))

law merkleize_selected_correct:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  {I.merkleize(limit, chunks) == S.at_depth(limit, I.depth(limit), chunks) : Maybe<&2, +List<U32>>}
def merkleize_selected_correct(limit, chunks):
  gate_correct(Nat.is_le(List.length(&2, +List<U32>, chunks), limit), limit, chunks, {==})

# The spec depth is universally quantified and characterized independently.
# depth_minimal discharges existence for the public selector; minimal_unique
# ensures this API refines every depth permitted by normative semantics.
law merkleize_correct:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +depth: Nat
  for minimal: {S.minimal(limit, depth) == True{} : Bool}
  {I.merkleize(limit, chunks) == S.at_depth(limit, depth, chunks) : Maybe<&2, +List<U32>>}
def merkleize_correct(limit, chunks, depth, minimal):
  %minimal_unique(limit, I.depth(limit), depth, depth_minimal(limit), minimal) :
    {I.merkleize(limit, chunks) == S.at_depth(limit, _, chunks) : Maybe<&2, +List<U32>>}
  merkleize_selected_correct(limit, chunks)

law merkleize_rejection:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  {R.is_some(I.merkleize(limit, chunks)) == Bool.and(Chunks.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), limit)) : Bool}
def merkleize_rejection(limit, chunks):
  %Equal.sym(Maybe<&2, +List<U32>>, I.merkleize(limit, chunks), S.at_depth(limit, I.depth(limit), chunks), merkleize_selected_correct(limit, chunks)) :
    {R.is_some(_) == Bool.and(Chunks.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), limit)) : Bool}
  Tree.checked_acceptance(Bool.and(Chunks.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), limit)), I.depth(limit), chunks)

law gate_scope:
  for ok: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  Tree.result_scope(I.gate(ok, limit, chunks))
def gate_scope(ok, limit, chunks):
  match ok:
    case False{}: Unit{}
    case True{}: Tree.merkleize_at_depth_scope(I.depth(limit), chunks)

law merkleize_scope:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  Tree.result_scope(I.merkleize(limit, chunks))
def merkleize_scope(limit, chunks): gate_scope(Nat.is_le(List.length(&2, +List<U32>, chunks), limit), limit, chunks)

law merkleize_length:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  {Basic.lengths(I.merkleize(limit, chunks)) == Basic.expected_root_length(I.merkleize(limit, chunks)) : Maybe<&2, Nat>}
def merkleize_length(limit, chunks): Tree.result_length(I.merkleize(limit, chunks), merkleize_scope(limit, chunks))

law default_correct:
  for +chunks: +List<+List<U32>>
  for +depth: Nat
  for minimal: {S.minimal(List.length(&2, +List<U32>, chunks), depth) == True{} : Bool}
  {I.merkleize_default(chunks) == S.at_depth(List.length(&2, +List<U32>, chunks), depth, chunks) : Maybe<&2, +List<U32>>}
def default_correct(chunks, depth, minimal): merkleize_correct(List.length(&2, +List<U32>, chunks), chunks, depth, minimal)

law default_rejection:
  for +chunks: +List<+List<U32>>
  {R.is_some(I.merkleize_default(chunks)) == Chunks.chunks_domain(chunks) : Bool}
def default_rejection(chunks):
  %B.and_identity(Chunks.chunks_domain(chunks)) : {R.is_some(I.merkleize_default(chunks)) == _ : Bool}
  %N.reflexive(List.length(&2, +List<U32>, chunks)) : {R.is_some(I.merkleize_default(chunks)) == Bool.and(Chunks.chunks_domain(chunks), _) : Bool}
  merkleize_rejection(List.length(&2, +List<U32>, chunks), chunks)
