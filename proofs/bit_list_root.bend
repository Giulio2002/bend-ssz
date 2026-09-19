import Base
import ../src/bit_root.bend as I
import ../src/bitfields.bend as Fields
import ../src/limits.bend as M
import ../src/nat_bytes.bend as L
import ../src/merkle.bend as Node
import ../src/primitives.bend as R
import ../spec/bit_root.bend as S
import ../spec/nat_bytes.bend as LS
import ../spec/primitives.bend as P
import ../spec/merkle.bend as NS
import ../spec/limits.bend as MS
import ./bit_root.bend as Vector
import ./bit_chunk_count.bend as Count
import ./nat_bytes.bend as Length
import ./merkle.bend as Nodes
import ./tree.bend as Tree
import ./limits.bend as Limits
import ./primitives.bend as Basic
import ./primitive_invariants.bend as V

law mix_correct:
  for +root: Maybe<&2, +List<U32>>
  for +length: Maybe<&2, +List<U32>>
  for rs: Tree.result_scope(root)
  for ls: Tree.result_scope(length)
  {I.mix_length_bytes(root, length) == S.mix_length_bytes(root, length) : Maybe<&2, +List<U32>>}
def mix_correct(root, length, rs, ls):
  match root length:
    case None{} None{}: {==}
    case None{} Some{ys}: {==}
    case Some{xs} None{}: {==}
    case Some{xs} Some{ys}:
      %V.and_true(P.byte_scope(32n, xs), P.byte_scope(32n, ys), rs, ls) : {Node.hash_pair(xs, ys) == NS.pair_checked(_, xs, ys) : Maybe<&2, +List<U32>>}
      Nodes.hash_pair_correct(xs, ys)

law list_gate_correct:
  for +ok: Bool
  for +capacity: Nat
  for +depth: Nat
  for +bits: +List<Bool>
  for minimal: {S.canonical_depth(capacity, depth) == True{} : Bool}
  {I.list_gate(ok, capacity, bits) == S.list_gate(ok, capacity, depth, bits) : Maybe<&2, +List<U32>>}
def list_gate_correct(ok, capacity, depth, bits, minimal):
  match ok:
    case False{}: {==}
    case True{}:
      %Vector.chunks_correct(bits) : {I.list_gate(True{}, capacity, bits) == S.mix_length_bytes(MS.at_depth(I.chunk_limit(capacity), depth, _), LS.encoding(32n, List.length(&2, Bool, bits))) : Maybe<&2, +List<U32>>}
      %Limits.merkleize_correct(I.chunk_limit(capacity), I.chunks(bits), depth, minimal) : {I.list_gate(True{}, capacity, bits) == S.mix_length_bytes(_, LS.encoding(32n, List.length(&2, Bool, bits))) : Maybe<&2, +List<U32>>}
      %Length.encode_correct(32n, List.length(&2, Bool, bits)) : {I.list_gate(True{}, capacity, bits) == S.mix_length_bytes(M.merkleize(I.chunk_limit(capacity), I.chunks(bits)), _) : Maybe<&2, +List<U32>>}
      mix_correct(M.merkleize(I.chunk_limit(capacity), I.chunks(bits)), L.encode(32n, List.length(&2, Bool, bits)), Limits.merkleize_scope(I.chunk_limit(capacity), I.chunks(bits)), Length.length_scope(List.length(&2, Bool, bits)))

law bitlist_root_correct:
  for +capacity: Nat
  for +depth: Nat
  for +bits: +List<Bool>
  for minimal: {S.canonical_depth(capacity, depth) == True{} : Bool}
  {I.bitlist_hash_tree_root(capacity, bits) == S.bitlist_at_depth(capacity, depth, bits) : Maybe<&2, +List<U32>>}
def bitlist_root_correct(capacity, depth, bits, minimal):
  list_gate_correct(Fields.list_valid(capacity, bits), capacity, depth, bits, minimal)

law bitlist_selected_correct:
  for +capacity: Nat
  for +bits: +List<Bool>
  {I.bitlist_hash_tree_root(capacity, bits) == S.bitlist_at_depth(capacity, M.depth(I.chunk_limit(capacity)), bits) : Maybe<&2, +List<U32>>}
def bitlist_selected_correct(capacity, bits):
  bitlist_root_correct(capacity, M.depth(I.chunk_limit(capacity)), bits, Vector.selected_depth_is_canonical(capacity))

law model_mix_scope:
  for +root: Maybe<&2, +List<U32>>
  for +length: Maybe<&2, +List<U32>>
  Tree.result_scope(S.mix_length_bytes(root, length))
def model_mix_scope(root, length):
  match root length:
    case None{} None{}: Unit{}
    case None{} Some{ys}: Unit{}
    case Some{xs} None{}: Unit{}
    case Some{xs} Some{ys}: Tree.fips_scope(List.append(&2, U32, xs, ys))

law mix_scope:
  for +root: Maybe<&2, +List<U32>>
  for +length: Maybe<&2, +List<U32>>
  for rs: Tree.result_scope(root)
  for ls: Tree.result_scope(length)
  Tree.result_scope(I.mix_length_bytes(root, length))
def mix_scope(root, length, rs, ls):
  %Equal.sym(Maybe<&2, +List<U32>>, I.mix_length_bytes(root, length), S.mix_length_bytes(root, length), mix_correct(root, length, rs, ls)) : Tree.result_scope(_)
  model_mix_scope(root, length)

law list_gate_scope:
  for ok: Bool
  for +capacity: Nat
  for +bits: +List<Bool>
  Tree.result_scope(I.list_gate(ok, capacity, bits))
def list_gate_scope(ok, capacity, bits):
  match ok:
    case False{}: Unit{}
    case True{}:
      mix_scope(M.merkleize(I.chunk_limit(capacity), I.chunks(bits)), L.encode(32n, List.length(&2, Bool, bits)), Limits.merkleize_scope(I.chunk_limit(capacity), I.chunks(bits)), Length.length_scope(List.length(&2, Bool, bits)))

law bitlist_root_scope:
  for +capacity: Nat
  for +bits: +List<Bool>
  Tree.result_scope(I.bitlist_hash_tree_root(capacity, bits))
def bitlist_root_scope(capacity, bits): list_gate_scope(Fields.list_valid(capacity, bits), capacity, bits)

law mix_acceptance:
  for +root: Maybe<&2, +List<U32>>
  for +length: Maybe<&2, +List<U32>>
  for rs: Tree.result_scope(root)
  for ls: Tree.result_scope(length)
  {R.is_some(I.mix_length_bytes(root, length)) == Bool.and(R.is_some(root), R.is_some(length)) : Bool}
def mix_acceptance(root, length, rs, ls):
  match root length:
    case None{} None{}: {==}
    case None{} Some{ys}: {==}
    case Some{xs} None{}: {==}
    case Some{xs} Some{ys}:
      %V.and_true(P.byte_scope(32n, xs), P.byte_scope(32n, ys), rs, ls) : {R.is_some(Node.hash_pair(xs, ys)) == _ : Bool}
      Nodes.hash_pair_rejection(xs, ys)

law data_root_total:
  for +capacity: Nat
  for +bits: +List<Bool>
  for valid: {Fields.list_valid(capacity, bits) == True{} : Bool}
  {R.is_some(M.merkleize(I.chunk_limit(capacity), I.chunks(bits))) == True{} : Bool}
def data_root_total(capacity, bits, valid):
  %Count.list_chunk_bound(capacity, bits, valid) : {R.is_some(M.merkleize(I.chunk_limit(capacity), I.chunks(bits))) == _ : Bool}
  Vector.gate_acceptance(True{}, capacity, bits)

law list_gate_acceptance:
  for +ok: Bool
  for +capacity: Nat
  for +bits: +List<Bool>
  for valid: {ok == True{} : Bool} -> {Fields.list_valid(capacity, bits) == True{} : Bool}
  {R.is_some(I.list_gate(ok, capacity, bits)) == Bool.and(ok, LS.fits(32n, List.length(&2, Bool, bits))) : Bool}
def list_gate_acceptance(ok, capacity, bits, valid):
  match ok:
    case False{}: {==}
    case True{}:
      %data_root_total(capacity, bits, valid({==})) : {R.is_some(I.list_gate(True{}, capacity, bits)) == Bool.and(_, LS.fits(32n, List.length(&2, Bool, bits))) : Bool}
      %Length.encode_acceptance(32n, List.length(&2, Bool, bits)) : {R.is_some(I.list_gate(True{}, capacity, bits)) == Bool.and(R.is_some(M.merkleize(I.chunk_limit(capacity), I.chunks(bits))), _) : Bool}
      mix_acceptance(M.merkleize(I.chunk_limit(capacity), I.chunks(bits)), L.encode(32n, List.length(&2, Bool, bits)), Limits.merkleize_scope(I.chunk_limit(capacity), I.chunks(bits)), Length.length_scope(List.length(&2, Bool, bits)))

law bitlist_root_acceptance:
  for +capacity: Nat
  for +bits: +List<Bool>
  {R.is_some(I.bitlist_hash_tree_root(capacity, bits)) == Bool.and(Fields.list_valid(capacity, bits), LS.fits(32n, List.length(&2, Bool, bits))) : Bool}
def bitlist_root_acceptance(capacity, bits):
  list_gate_acceptance(Fields.list_valid(capacity, bits), capacity, bits, e => e)

# uint256 representability is a normative length-mixing domain, not a runtime
# resource bound. The public API rejects length overflow explicitly.
law bitlist_root_total:
  for +capacity: Nat
  for +bits: +List<Bool>
  for valid: {Fields.list_valid(capacity, bits) == True{} : Bool}
  for length_domain: {LS.fits(32n, List.length(&2, Bool, bits)) == True{} : Bool}
  {R.is_some(I.bitlist_hash_tree_root(capacity, bits)) == True{} : Bool}
def bitlist_root_total(capacity, bits, valid, length_domain):
  %V.and_true(Fields.list_valid(capacity, bits), LS.fits(32n, List.length(&2, Bool, bits)), valid, length_domain) : {R.is_some(I.bitlist_hash_tree_root(capacity, bits)) == _ : Bool}
  bitlist_root_acceptance(capacity, bits)

law bitlist_capacity_total:
  for +capacity: Nat
  for +bits: +List<Bool>
  for +valid: {Fields.list_valid(capacity, bits) == True{} : Bool}
  for capacity_domain: {LS.fits(32n, capacity) == True{} : Bool}
  {R.is_some(I.bitlist_hash_tree_root(capacity, bits)) == True{} : Bool}
def bitlist_capacity_total(capacity, bits, valid, capacity_domain):
  bitlist_root_total(capacity, bits, valid, Length.fits_monotone(32n, List.length(&2, Bool, bits), capacity, valid, capacity_domain))

law bitlist_root_length:
  for +capacity: Nat
  for +bits: +List<Bool>
  {Basic.lengths(I.bitlist_hash_tree_root(capacity, bits)) == Basic.expected_root_length(I.bitlist_hash_tree_root(capacity, bits)) : Maybe<&2, Nat>}
def bitlist_root_length(capacity, bits):
  Tree.result_length(I.bitlist_hash_tree_root(capacity, bits), bitlist_root_scope(capacity, bits))
