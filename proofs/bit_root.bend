import Base
import ../src/bit_root.bend as I
import ../src/bitfields.bend as Fields
import ../src/bit_packing.bend as Bits
import ../src/packing.bend as Pack
import ../src/limits.bend as Merkle
import ../spec/bit_root.bend as S
import ../spec/bit_packing.bend as SB
import ../spec/packing.bend as SP
import ../spec/bitfields.bend as SF
import ../spec/limits.bend as SL
import ../src/primitives.bend as R
import ./bitfields.bend as FieldProof
import ./bit_packing.bend as BitProof
import ./packing.bend as Packing
import ./limits.bend as Limits
import ./tree.bend as Tree
import ./primitives.bend as Basic
import ./bit_chunk_count.bend as Count
import ./bit_vector_inverse.bend as Inverse
import ./nat_order.bend as Order

law chunks_correct:
  for +bits: +List<Bool>
  {I.chunks(bits) == S.chunks(bits) : +List<+List<U32>>}
def chunks_correct(bits):
  %BitProof.pack_correct(bits) : {I.chunks(bits) == SP.scan(_, 31n, [], []) : +List<+List<U32>>}
  Packing.scan_correct(Bits.pack(bits), 31n, [], [])

law chunks_domain:
  for +bits: +List<Bool>
  {SP.chunks_domain(I.chunks(bits)) == True{} : Bool}
def chunks_domain(bits):
  Packing.scan_domain(Bits.pack(bits), 31n, [], [], BitProof.pack_bytes(bits), {==}, {==}, {==})

law vector_gate_correct:
  for +ok: Bool
  for +size: Nat
  for +depth: Nat
  for +bits: +List<Bool>
  for minimal: {S.canonical_depth(size, depth) == True{} : Bool}
  {I.vector_gate(ok, size, bits) == S.vector_gate(ok, size, depth, bits) : Maybe<&2, +List<U32>>}
def vector_gate_correct(ok, size, depth, bits, minimal):
  match ok:
    case False{}: {==}
    case True{}:
      %chunks_correct(bits) : {Merkle.merkleize(I.chunk_limit(size), I.chunks(bits)) == SL.at_depth(I.chunk_limit(size), depth, _) : Maybe<&2, +List<U32>>}
      Limits.merkleize_correct(I.chunk_limit(size), I.chunks(bits), depth, minimal)

law bitvector_hash_tree_root_correct:
  for +size: Nat
  for +bits: +List<Bool>
  for +depth: Nat
  for minimal: {S.canonical_depth(size, depth) == True{} : Bool}
  {I.bitvector_hash_tree_root(size, bits) == S.bitvector_at_depth(size, depth, bits) : Maybe<&2, +List<U32>>}
def bitvector_hash_tree_root_correct(size, bits, depth, minimal):
  %FieldProof.vector_domain_correct(size, bits) : {I.bitvector_hash_tree_root(size, bits) == S.vector_gate(_, size, depth, bits) : Maybe<&2, +List<U32>>}
  vector_gate_correct(Fields.vector_valid(size, bits), size, depth, bits, minimal)

law vector_gate_scope:
  for ok: Bool
  for +size: Nat
  for +bits: +List<Bool>
  Tree.result_scope(I.vector_gate(ok, size, bits))
def vector_gate_scope(ok, size, bits):
  match ok:
    case False{}: Unit{}
    case True{}: Limits.merkleize_scope(I.chunk_limit(size), I.chunks(bits))

law bitvector_root_scope:
  for +size: Nat
  for +bits: +List<Bool>
  Tree.result_scope(I.bitvector_hash_tree_root(size, bits))
def bitvector_root_scope(size, bits): vector_gate_scope(Fields.vector_valid(size, bits), size, bits)

law bitvector_root_length:
  for +size: Nat
  for +bits: +List<Bool>
  {Basic.lengths(I.bitvector_hash_tree_root(size, bits)) == Basic.expected_root_length(I.bitvector_hash_tree_root(size, bits)) : Maybe<&2, Nat>}
def bitvector_root_length(size, bits): Tree.result_length(I.bitvector_hash_tree_root(size, bits), bitvector_root_scope(size, bits))

law selected_depth_is_canonical:
  for +size: Nat
  {S.canonical_depth(size, Merkle.depth(I.chunk_limit(size))) == True{} : Bool}
def selected_depth_is_canonical(size): Limits.depth_minimal(I.chunk_limit(size))

law bitvector_selected_correct:
  for +size: Nat
  for +bits: +List<Bool>
  {I.bitvector_hash_tree_root(size, bits) == S.bitvector_at_depth(size, Merkle.depth(I.chunk_limit(size)), bits) : Maybe<&2, +List<U32>>}
def bitvector_selected_correct(size, bits):
  bitvector_hash_tree_root_correct(size, bits, Merkle.depth(I.chunk_limit(size)), selected_depth_is_canonical(size))

law gate_acceptance:
  for +ok: Bool
  for +size: Nat
  for +bits: +List<Bool>
  {R.is_some(I.vector_gate(ok, size, bits)) == Bool.and(ok, Nat.is_le(List.length(&2, +List<U32>, I.chunks(bits)), I.chunk_limit(size))) : Bool}
def gate_acceptance(ok, size, bits):
  match ok:
    case False{}: {==}
    case True{}:
      %chunks_domain(bits) : {R.is_some(Merkle.merkleize(I.chunk_limit(size), I.chunks(bits))) == Bool.and(_, Nat.is_le(List.length(&2, +List<U32>, I.chunks(bits)), I.chunk_limit(size))) : Bool}
      Limits.merkleize_rejection(I.chunk_limit(size), I.chunks(bits))

# Internal acceptance formula. The exact public acceptance and totality laws
# below discharge the count check for every valid vector.
law bitvector_root_acceptance:
  for +size: Nat
  for +bits: +List<Bool>
  {R.is_some(I.bitvector_hash_tree_root(size, bits)) == Bool.and(Fields.vector_valid(size, bits), Nat.is_le(List.length(&2, +List<U32>, I.chunks(bits)), I.chunk_limit(size))) : Bool}
def bitvector_root_acceptance(size, bits): gate_acceptance(Fields.vector_valid(size, bits), size, bits)


law valid_vector_chunk_count:
  for +size: Nat
  for +bits: +List<Bool>
  for valid: {Fields.vector_valid(size, bits) == True{} : Bool}
  {List.length(&2, +List<U32>, I.chunks(bits)) == I.chunk_limit(size) : Nat}
def valid_vector_chunk_count(size, bits, valid):
  %Inverse.valid_size(size, bits, valid) : {List.length(&2, +List<U32>, I.chunks(bits)) == I.chunk_limit(_) : Nat}
  Count.chunks_length(bits)

law valid_vector_chunk_bound:
  for +size: Nat
  for +bits: +List<Bool>
  for valid: {Fields.vector_valid(size, bits) == True{} : Bool}
  {Nat.is_le(List.length(&2, +List<U32>, I.chunks(bits)), I.chunk_limit(size)) == True{} : Bool}
def valid_vector_chunk_bound(size, bits, valid):
  %Equal.sym(Nat, List.length(&2, +List<U32>, I.chunks(bits)), I.chunk_limit(size), valid_vector_chunk_count(size, bits, valid)) : {Nat.is_le(_, I.chunk_limit(size)) == True{} : Bool}
  Order.reflexive(I.chunk_limit(size))

law bitvector_root_total:
  for +size: Nat
  for +bits: +List<Bool>
  for +valid: {Fields.vector_valid(size, bits) == True{} : Bool}
  {R.is_some(I.bitvector_hash_tree_root(size, bits)) == True{} : Bool}
def bitvector_root_total(size, bits, valid):
  %valid_vector_chunk_bound(size, bits, valid) : {R.is_some(I.bitvector_hash_tree_root(size, bits)) == Bool.and(True{}, _) : Bool}
  %valid : {R.is_some(I.bitvector_hash_tree_root(size, bits)) == Bool.and(_, Nat.is_le(List.length(&2, +List<U32>, I.chunks(bits)), I.chunk_limit(size))) : Bool}
  bitvector_root_acceptance(size, bits)

law gate_valid_acceptance:
  for +ok: Bool
  for +size: Nat
  for +bits: +List<Bool>
  for valid: {ok == True{} : Bool} -> {Fields.vector_valid(size, bits) == True{} : Bool}
  {R.is_some(I.vector_gate(ok, size, bits)) == ok : Bool}
def gate_valid_acceptance(ok, size, bits, valid):
  match ok:
    case False{}: {==}
    case True{}:
      %valid_vector_chunk_bound(size, bits, valid({==})) : {R.is_some(I.vector_gate(True{}, size, bits)) == _ : Bool}
      gate_acceptance(True{}, size, bits)

law bitvector_root_exact_acceptance:
  for +size: Nat
  for +bits: +List<Bool>
  {R.is_some(I.bitvector_hash_tree_root(size, bits)) == Fields.vector_valid(size, bits) : Bool}
def bitvector_root_exact_acceptance(size, bits):
  gate_valid_acceptance(Fields.vector_valid(size, bits), size, bits, e => e)
