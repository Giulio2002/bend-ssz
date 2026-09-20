import Base
import ./bytes.bend as B
import ./packing.bend as Pack
import ./limits.bend as M

# Fixed byte-vector roots: validation establishes the packing input domain.
def gate(ok: Bool, xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: M.merkleize_default(Pack.scan(xs, 31n, [], []))

def hash_tree_root(n: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  gate(B.vector_valid(n, xs), xs)

# Root-only domain for ByteVector[n] inside the generic Merkleization path:
# n > 0, exactly n bytes, each in 0..255. A byte vector's root packs its own
# bytes; the serializer's whole-object 2^32 size bound is not a root condition.
def root_valid(+n: Nat, xs: +List<U32>) -> Bool:
  match n:
    case 0n: False{}
    case 1n+p: B.scope_go(xs, 1n+p, True{})

def merkle_root(+n: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  gate(root_valid(n, xs), xs)
