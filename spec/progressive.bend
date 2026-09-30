import Base
import ./tree.bend as Tree
import ./primitives.bend as P
import ./packing.bend as Pack
import 0xd9a2fae439ac7ff9e21e0853948f94fe/spec/crypto/sha.bend as FIPS

# SSZ merkleize_progressive: right subtree capacities are 1, 4, 16, ...;
# the recursive remainder is the LEFT hash input. depth denotes log2(capacity).
# The recursion index is a mathematical traversal bound, not a fixture/runtime
# cutoff. proofs/progressive.bend proves it sufficient for every input:
# each nonempty step removes at least one chunk.
def tree(fuel: Nat, +depth: Nat, +chunks: +List<+List<U32>>) -> +List<U32>:
  match fuel:
    case 0n: P.zero_bytes(32n)
    case 1n+p:
      match chunks:
        case Nil{}: P.zero_bytes(32n)
        case Con{h, t}: FIPS.sha256_bytes(List.append(&2, U32, tree(p, 2n+depth, Tree.drop(Tree.capacity(depth), h <> t)), Tree.tree(depth, h <> t)))

def gate(ok: Bool, +chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{tree(List.length(&2, +List<U32>, chunks), 0n, chunks)}

def merkleize(+chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  gate(Pack.chunks_domain(chunks), chunks)

# This proposition distinguishes a complete recursive evaluation from an
# exhausted index. It mentions no runtime limits or implementation functions.
def complete(fuel: Nat, +depth: Nat, +chunks: +List<+List<U32>>) -> Bool:
  match fuel:
    case 0n:
      match chunks:
        case Nil{}: True{}
        case Con{h, t}: False{}
    case 1n+p:
      match chunks:
        case Nil{}: True{}
        case Con{h, t}: complete(p, 2n+depth, Tree.drop(Tree.capacity(depth), h <> t))
