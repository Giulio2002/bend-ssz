import Base
import ../src/cached_tree.bend as I
import ../src/limits.bend as IL
import ../src/progressive.bend as IP
import ../spec/limits.bend as SL
import ../spec/progressive.bend as SP
import ../spec/root_relation.bend as S
import ./cached_tree.bend as Cache
import ./limits.bend as Limits
import ./progressive.bend as Progressive

law cached_refines_depth:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +cache_size: Nat
  for +depth: Nat
  for minimal: {SL.minimal(limit, depth) == True{} : Bool}
  {I.merkleize(limit, chunks, I.zeros(cache_size)) == SL.at_depth(limit, depth, chunks) : Maybe<&2, +List<U32>>}
def cached_refines_depth(limit, chunks, cache_size, depth, minimal):
  Equal.trans(Maybe<&2, +List<U32>>, I.merkleize(limit, chunks, I.zeros(cache_size)), IL.merkleize(limit, chunks), SL.at_depth(limit, depth, chunks), Cache.merkleize_correct(limit, chunks, cache_size), Limits.merkleize_correct(limit, chunks, depth, minimal))

law accepted_merkle:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +cache_size: Nat
  for +root: +List<U32>
  for accepted: {I.merkleize(limit, chunks, I.zeros(cache_size)) == Some{root} : Maybe<&2, +List<U32>>}
  S.merkle(limit, chunks, root)
def accepted_merkle(limit, chunks, cache_size, root, accepted):
  (IL.depth(limit), (Limits.depth_minimal(limit), Equal.trans(Maybe<&2, +List<U32>>, SL.at_depth(limit, IL.depth(limit), chunks), I.merkleize(limit, chunks, I.zeros(cache_size)), Some{root}, Equal.sym(Maybe<&2, +List<U32>>, I.merkleize(limit, chunks, I.zeros(cache_size)), SL.at_depth(limit, IL.depth(limit), chunks), cached_refines_depth(limit, chunks, cache_size, IL.depth(limit), Limits.depth_minimal(limit))), accepted)))

# The converse uses any independently minimal depth witness; no caller supplies
# a cache invariant or assumed Merkle equality. The actual zero table is built.
law merkle_complete:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +cache_size: Nat
  for +root: +List<U32>
  for witness: S.merkle(limit, chunks, root)
  {I.merkleize(limit, chunks, I.zeros(cache_size)) == Some{root} : Maybe<&2, +List<U32>>}
def merkle_complete(limit, chunks, cache_size, root, witness):
  (depth, (minimal, encoded)) = witness
  Equal.trans(Maybe<&2, +List<U32>>, I.merkleize(limit, chunks, I.zeros(cache_size)), SL.at_depth(limit, depth, chunks), Some{root}, cached_refines_depth(limit, chunks, cache_size, depth, minimal), encoded)

law cached_progressive_correct:
  for +chunks: +List<+List<U32>>
  for +cache_size: Nat
  {I.progressive(chunks, I.zeros(cache_size)) == SP.merkleize(chunks) : Maybe<&2, +List<U32>>}
def cached_progressive_correct(chunks, cache_size):
  Equal.trans(Maybe<&2, +List<U32>>, I.progressive(chunks, I.zeros(cache_size)), IP.merkleize(chunks), SP.merkleize(chunks), Cache.progressive_correct(chunks, cache_size), Progressive.merkleize_correct(chunks))
