import Base
import ./bytes.bend as B
import ./packing.bend as Pack
import ./tree.bend as T
import ./limits.bend as Limits

# Bytes are basic SSZ elements. The normative root is merkleize(pack(value));
# no length mixing occurs for a fixed vector. A canonical depth is characterized
# independently by Limits.minimal at the number of packed chunks.
def chunks(xs: +List<U32>) -> +List<+List<U32>>: Pack.scan(xs, 31n, [], [])
def canonical_depth(+xs: +List<U32>, depth: Nat) -> Bool:
  Limits.minimal(List.length(&2, +List<U32>, chunks(xs)), depth)
def gate(ok: Bool, depth: Nat, xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{T.tree(depth, chunks(xs))}
def at_depth(n: Nat, depth: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  gate(B.vector_domain(n, xs), depth, xs)
