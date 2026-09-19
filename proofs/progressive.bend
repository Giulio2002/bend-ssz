import Base
import ../spec/packing.bend as Pack
import ../spec/primitives.bend as P
import ../src/primitives.bend as R
import ../src/progressive.bend as I
import ../spec/progressive.bend as S
import ../src/tree.bend as T
import ../spec/tree.bend as TS
import ../src/lists.bend as Lists
import ../src/sha256.bend as Hash
import ../vendor/bend_sha256/fips.bend as FIPS
import ../HASH_PROOF.bend as H
import ./tree.bend as Tree
import ./lists.bend as L
import ./basic_root.bend as Basic
import ./nat_order.bend as Order
import ./limits.bend as Limits
import ./word_facts.bend as W

# Recursive refinement. public_traversal_complete below discharges the
# traversal index for every finite input; no fixture bound is used.
law tree_correct:
  for +fuel: Nat
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  {I.tree(fuel, depth, chunks) == S.tree(fuel, depth, chunks) : +List<U32>}
def tree_correct(fuel, depth, chunks):
  match fuel:
    case 0n: Basic.empty_padding(32n)
    case 1n+p:
      match chunks:
        case Nil{}: Basic.empty_padding(32n)
        case Con{h, t}:
          %Equal.sym((+List<U32> & +List<+List<U32>>), T.consume(depth, h <> t), (TS.tree(depth, h <> t), TS.drop(TS.capacity(depth), h <> t)), Tree.consume_correct(depth, h <> t)) : {I.join(_, rest => I.tree(p, 2n+depth, rest)) == S.tree(1n+p, depth, h <> t) : +List<U32>}
          %Equal.sym(+List<U32>, I.tree(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t)), S.tree(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t)), tree_correct(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t))) : {Hash.hash(Lists.append(U32, _, TS.tree(depth, h <> t))) == S.tree(1n+p, depth, h <> t) : +List<U32>}
          %Equal.sym(+List<U32>, Lists.append(U32, S.tree(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t)), TS.tree(depth, h <> t)), List.append(&2, U32, S.tree(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t)), TS.tree(depth, h <> t)), L.append_correct(U32, S.tree(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t)), TS.tree(depth, h <> t))) : {Hash.hash(_) == S.tree(1n+p, depth, h <> t) : +List<U32>}
          H.hash_refines_fips(List.append(&2, U32, S.tree(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t)), TS.tree(depth, h <> t)))


law drop_length:
  for +n: Nat
  for +xs: +List<+List<U32>>
  {Nat.is_le(List.length(&2, +List<U32>, TS.drop(n, xs)), List.length(&2, +List<U32>, xs)) == True{} : Bool}
def drop_length(n, xs):
  match n:
    case 0n: Order.reflexive(List.length(&2, +List<U32>, xs))
    case 1n+p:
      match xs:
        case Nil{}: {==}
        case Con{h, t}: Order.step_right(List.length(&2, +List<U32>, TS.drop(p, t)), List.length(&2, +List<U32>, t), drop_length(p, t))

law drop_progress:
  for +n: Nat
  for +h: +List<U32>
  for +t: +List<+List<U32>>
  for positive: {Nat.is_le(1n, n) == True{} : Bool}
  {Nat.is_le(List.length(&2, +List<U32>, TS.drop(n, h <> t)), List.length(&2, +List<U32>, t)) == True{} : Bool}
def drop_progress(n, h, t, positive):
  match n:
    case 0n: Empty.absurd({Nat.is_le(List.length(&2, +List<U32>, h <> t), List.length(&2, +List<U32>, t)) == True{} : Bool}, W.false_true(positive))
    case 1n+p: drop_length(p, t)

law traversal_complete:
  for +fuel: Nat
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  for budget: {Nat.is_le(List.length(&2, +List<U32>, chunks), fuel) == True{} : Bool}
  {S.complete(fuel, depth, chunks) == True{} : Bool}
def traversal_complete(fuel, depth, chunks, budget):
  match fuel:
    case 0n:
      match chunks:
        case Nil{}: {==}
        case Con{h, t}: Empty.absurd({False{} == True{} : Bool}, W.false_true(budget))
    case 1n+p:
      match chunks:
        case Nil{}: {==}
        case Con{h, t}:
          traversal_complete(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t), Order.transitive(List.length(&2, +List<U32>, TS.drop(TS.capacity(depth), h <> t)), List.length(&2, +List<U32>, t), p, drop_progress(TS.capacity(depth), h, t, Limits.capacity_positive(depth)), budget))

law public_traversal_complete:
  for +chunks: +List<+List<U32>>
  {S.complete(Lists.length(+List<U32>, chunks), 0n, chunks) == True{} : Bool}
def public_traversal_complete(chunks):
  %Equal.sym(Nat, Lists.length(+List<U32>, chunks), List.length(&2, +List<U32>, chunks), L.length_correct(+List<U32>, chunks)) : {S.complete(_, 0n, chunks) == True{} : Bool}
  traversal_complete(List.length(&2, +List<U32>, chunks), 0n, chunks, Order.reflexive(List.length(&2, +List<U32>, chunks)))

law gate_correct:
  for ok: Bool
  for +chunks: +List<+List<U32>>
  {I.gate(ok, chunks) == S.gate(ok, chunks) : Maybe<&2, +List<U32>>}
def gate_correct(ok, chunks):
  match ok:
    case False{}: {==}
    case True{}:
      %L.length_correct(+List<U32>, chunks) : {I.gate(True{}, chunks) == Some{S.tree(_, 0n, chunks)} : Maybe<&2, +List<U32>>}
      Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, xs => Some{xs}, I.tree(Lists.length(+List<U32>, chunks), 0n, chunks), S.tree(Lists.length(+List<U32>, chunks), 0n, chunks), tree_correct(Lists.length(+List<U32>, chunks), 0n, chunks))

law merkleize_correct:
  for +chunks: +List<+List<U32>>
  {I.merkleize(chunks) == S.merkleize(chunks) : Maybe<&2, +List<U32>>}
def merkleize_correct(chunks):
  %Tree.valid_go_correct(chunks, True{}) : {I.merkleize(chunks) == S.gate(_, chunks) : Maybe<&2, +List<U32>>}
  gate_correct(T.valid_go(chunks, True{}), chunks)

law gate_acceptance:
  for +ok: Bool
  for chunks: +List<+List<U32>>
  {R.is_some(I.gate(ok, chunks)) == ok : Bool}
def gate_acceptance(ok, chunks):
  match ok:
    case False{}: {==}
    case True{}: {==}

law exact_acceptance:
  for +chunks: +List<+List<U32>>
  {R.is_some(I.merkleize(chunks)) == Pack.chunks_domain(chunks) : Bool}
def exact_acceptance(chunks):
  %Tree.valid_go_correct(chunks, True{}) : {R.is_some(I.merkleize(chunks)) == _ : Bool}
  gate_acceptance(T.valid_go(chunks, True{}), chunks)

law spec_scope:
  for +fuel: Nat
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  {P.byte_scope(32n, S.tree(fuel, depth, chunks)) == True{} : Bool}
def spec_scope(fuel, depth, chunks):
  match fuel:
    case 0n: Tree.zero_scope(0n)
    case 1n+p:
      match chunks:
        case Nil{}: Tree.zero_scope(0n)
        case Con{h, t}: Tree.fips_scope(List.append(&2, U32, S.tree(p, 2n+depth, TS.drop(TS.capacity(depth), h <> t)), TS.tree(depth, h <> t)))

law gate_scope:
  for ok: Bool
  for +chunks: +List<+List<U32>>
  Tree.result_scope(S.gate(ok, chunks))
def gate_scope(ok, chunks):
  match ok:
    case False{}: Unit{}
    case True{}: spec_scope(List.length(&2, +List<U32>, chunks), 0n, chunks)

law merkleize_scope:
  for +chunks: +List<+List<U32>>
  Tree.result_scope(I.merkleize(chunks))
def merkleize_scope(chunks):
  %Equal.sym(Maybe<&2, +List<U32>>, I.merkleize(chunks), S.merkleize(chunks), merkleize_correct(chunks)) : Tree.result_scope(_)
  gate_scope(Pack.chunks_domain(chunks), chunks)
