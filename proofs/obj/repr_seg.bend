import Base
import ../../proofs/compact/found.bend as F
import ./repr.bend as R

# Symbolic lemmas that carry repr.bend's `tree_words` to the literal tree of a
# buffer's words without evaluating it.
#
# A per-name law over every perfect tree t of depth d needs the array of t as the
# literal tree whose leaves are `R.w(t, 0n) .. R.w(t, 2^d - 1)`. Evaluating
# `build(d, lits(2^d, slots t))` against that literal compares every leaf
# `head0(tail0^k(..))` with `R.w(t, k)` by running both over a stuck list: cubic in
# the word count (MatrixEntry, 1024 leaves: 181M `tail0` calls, 31 s per law).
# Here the canonical tree of the 2^p words from index i, `seg(s, i, p)`, splits
# into its two halves for SYMBOLIC i and p (`split`), and a leaf is `R.w(t, i)`
# for symbolic i (`leaf`); codegen/spec_laws.py instantiates `leaf` and `node`
# once per node of the tree with literal indices, so every leaf it produces is
# syntactically the leaf of the law's statement.

# The canonical tree of the 2^p words of s from index i.
def seg(s: List<&2, U32>, +i: Nat, +p: Nat) -> F.array__Tree<U32>:
  R.build(p, R.lits(F.spec_common__pow2(p), R.tails(s, i)))

law tails_tail:
  for +xs: List<&2, U32>
  for +a: Nat
  {R.tails(R.tail0(xs), a) == R.tail0(R.tails(xs, a)) : List<&2, U32>}
def tails_tail(xs, a):
  match a:
    case 0n: {==}
    case 1n+p:
      Equal.cong(List<&2, U32>, List<&2, U32>, z => R.tail0(z), R.tails(R.tail0(xs), p), R.tail0(R.tails(xs, p)), tails_tail(xs, p))

law tails_comp:
  for +s: List<&2, U32>
  for +a: Nat
  for +b: Nat
  {R.tails(R.tails(s, a), b) == R.tails(s, Nat.add(b, a)) : List<&2, U32>}
def tails_comp(s, a, b):
  match b:
    case 0n: {==}
    case 1n+q:
      Equal.cong(List<&2, U32>, List<&2, U32>, z => R.tail0(z), R.tails(R.tails(s, a), q), R.tails(s, Nat.add(q, a)), tails_comp(s, a, q))

law len_lits:
  for +n: Nat
  for +xs: List<&2, U32>
  {F.spec_common__length(U32, R.lits(n, xs)) == n : Nat}
def len_lits(n, xs):
  match n:
    case 0n: {==}
    case 1n+p: F.nat__succ_cong(F.spec_common__length(U32, R.lits(p, R.tail0(xs))), p, len_lits(p, R.tail0(xs)))

law lits_add:
  for +a: Nat
  for +b: Nat
  for +xs: List<&2, U32>
  {R.lits(Nat.add(a, b), xs) == F.spec_common__append(U32, R.lits(a, xs), R.lits(b, R.tails(xs, a))) : List<&2, U32>}
def lits_add(a, b, xs):
  match a:
    case 0n: {==}
    case 1n+c:
      +ih = lits_add(c, b, R.tail0(xs))
      +tt = tails_tail(xs, c)
      F.list__cons_cong(U32, R.head0(xs), R.lits(Nat.add(c, b), R.tail0(xs)),
        F.spec_common__append(U32, R.lits(c, R.tail0(xs)), R.lits(b, R.tail0(R.tails(xs, c)))),
        Equal.trans(List<&2, U32>, R.lits(Nat.add(c, b), R.tail0(xs)),
          F.spec_common__append(U32, R.lits(c, R.tail0(xs)), R.lits(b, R.tails(R.tail0(xs), c))),
          F.spec_common__append(U32, R.lits(c, R.tail0(xs)), R.lits(b, R.tail0(R.tails(xs, c)))),
          ih,
          Equal.cong(List<&2, U32>, List<&2, U32>, z => F.spec_common__append(U32, R.lits(c, R.tail0(xs)), R.lits(b, z)),
            R.tails(R.tail0(xs), c), R.tail0(R.tails(xs, c)), tt)))

law double_add:
  for +n: Nat
  {Nat.double(n) == Nat.add(n, n) : Nat}
def double_add(n):
  match n:
    case 0n: {==}
    case 1n+p:
      Equal.trans(Nat, 2n+Nat.double(p), 2n+Nat.add(p, p), 1n+Nat.add(p, 1n+p),
        Equal.cong(Nat, Nat, k => 2n+k, Nat.double(p), Nat.add(p, p), double_add(p)),
        Equal.sym(Nat, 1n+Nat.add(p, 1n+p), 2n+Nat.add(p, p),
          Equal.cong(Nat, Nat, k => 1n+k, Nat.add(p, 1n+p), 1n+Nat.add(p, p), F.nat__add_succ(p, p))))

# lits over 2^(p+1) words from i: the 2^p words from i, then the 2^p words from i + 2^p
law lits_halves:
  for +p: Nat
  for +s: List<&2, U32>
  for +i: Nat
  {R.lits(F.spec_common__pow2(1n+p), R.tails(s, i)) == F.spec_common__append(U32, R.lits(F.spec_common__pow2(p), R.tails(s, i)), R.lits(F.spec_common__pow2(p), R.tails(s, Nat.add(F.spec_common__pow2(p), i)))) : List<&2, U32>}
def lits_halves(p, s, i):
  +P = F.spec_common__pow2(p)
  +X = R.tails(s, i)
  +e1 = Equal.cong(Nat, List<&2, U32>, k => R.lits(k, X), Nat.double(P), Nat.add(P, P), double_add(P))
  +e2 = lits_add(P, P, X)
  +e3 = Equal.cong(List<&2, U32>, List<&2, U32>, z => F.spec_common__append(U32, R.lits(P, X), R.lits(P, z)),
    R.tails(R.tails(s, i), P), R.tails(s, Nat.add(P, i)), tails_comp(s, i, P))
  Equal.trans(List<&2, U32>, R.lits(Nat.double(P), X), F.spec_common__append(U32, R.lits(P, X), R.lits(P, R.tails(X, P))),
    F.spec_common__append(U32, R.lits(P, X), R.lits(P, R.tails(s, Nat.add(P, i)))),
    Equal.trans(List<&2, U32>, R.lits(Nat.double(P), X), R.lits(Nat.add(P, P), X), F.spec_common__append(U32, R.lits(P, X), R.lits(P, R.tails(X, P))), e1, e2),
    e3)

# The tree of 2^(p+1) words from i is the node of the trees from i and from j = i + 2^p.
law split:
  for +s: List<&2, U32>
  for +i: Nat
  for +p: Nat
  for +j: Nat
  for +ej: {j == Nat.add(F.spec_common__pow2(p), i) : Nat}
  {seg(s, i, 1n+p) == F.TNode{seg(s, i, p), seg(s, j, p)} : F.array__Tree<U32>}
def split(s, i, p, j, ej):
  +P = F.spec_common__pow2(p)
  +A = R.lits(P, R.tails(s, i))
  +Bj = R.lits(P, R.tails(s, j))
  +B = R.lits(P, R.tails(s, Nat.add(P, i)))
  +L = F.spec_common__append(U32, A, B)
  +hl = lits_halves(p, s, i)
  +len = len_lits(P, R.tails(s, i))
  +ta = R.take_app(A, B)
  +da = R.drop_app(A, B)
  +eb = Equal.cong(Nat, List<&2, U32>, k => R.lits(P, R.tails(s, k)), j, Nat.add(P, i), ej)
  %Equal.sym(List<&2, U32>, R.lits(F.spec_common__pow2(1n+p), R.tails(s, i)), L, hl) :
    {F.TNode{R.build(p, F.spec_common__take(U32, _, P)), R.build(p, F.spec_common__drop(U32, _, P))} == F.TNode{R.build(p, A), R.build(p, Bj)} : F.array__Tree<U32>}
  %Equal.cong(Nat, List<&2, U32>, k => F.spec_common__take(U32, L, k), F.spec_common__length(U32, A), P, len) :
    {F.TNode{R.build(p, _), R.build(p, F.spec_common__drop(U32, L, P))} == F.TNode{R.build(p, A), R.build(p, Bj)} : F.array__Tree<U32>}
  %Equal.cong(Nat, List<&2, U32>, k => F.spec_common__drop(U32, L, k), F.spec_common__length(U32, A), P, len) :
    {F.TNode{R.build(p, F.spec_common__take(U32, L, F.spec_common__length(U32, A))), R.build(p, _)} == F.TNode{R.build(p, A), R.build(p, Bj)} : F.array__Tree<U32>}
  %Equal.sym(List<&2, U32>, F.spec_common__take(U32, L, F.spec_common__length(U32, A)), A, ta) :
    {F.TNode{R.build(p, _), R.build(p, F.spec_common__drop(U32, L, F.spec_common__length(U32, A)))} == F.TNode{R.build(p, A), R.build(p, Bj)} : F.array__Tree<U32>}
  %Equal.sym(List<&2, U32>, F.spec_common__drop(U32, L, F.spec_common__length(U32, A)), B, da) :
    {F.TNode{R.build(p, A), R.build(p, _)} == F.TNode{R.build(p, A), R.build(p, Bj)} : F.array__Tree<U32>}
  %eb : {F.TNode{R.build(p, A), R.build(p, _)} == F.TNode{R.build(p, A), R.build(p, Bj)} : F.array__Tree<U32>}
  {==}

# The tree from index 0 is tree_words' canonical tree.
law seg0:
  for +s: List<&2, U32>
  for +p: Nat
  {R.build(p, R.lits(F.spec_common__pow2(p), s)) == seg(s, 0n, p) : F.array__Tree<U32>}
def seg0(s, p):
  {==}

# A leaf: word i of t, for symbolic i.
law leaf:
  for +t: F.array__Tree<U32>
  for +i: Nat
  {F.array__thaw(U32, seg(F.array__slots(U32, t), i, 0n)) == ALeaf{R.w(t, i)} : Array<U32>}
def leaf(t, i):
  {==}

# A node: the arrays of the two halves, under q = p + 1 and j = i + 2^p (literals at the use).
def node(+s: List<&2, U32>, +i: Nat, +p: Nat, +q: Nat, +eq: {q == 1n+p : Nat}, +j: Nat, +ej: {j == Nat.add(F.spec_common__pow2(p), i) : Nat},
    -A: Array<U32>, -Bn: Array<U32>, ea: {F.array__thaw(U32, seg(s, i, p)) == A : Array<U32>}, eb: {F.array__thaw(U32, seg(s, j, p)) == Bn : Array<U32>})
    -> {F.array__thaw(U32, seg(s, i, q)) == ANode{A, Bn} : Array<U32>}:
  +sp = split(s, i, p, j, ej)
  %Equal.sym(Nat, q, 1n+p, eq) : {F.array__thaw(U32, seg(s, i, _)) == ANode{A, Bn} : Array<U32>}
  %Equal.sym(F.array__Tree<U32>, seg(s, i, 1n+p), F.TNode{seg(s, i, p), seg(s, j, p)}, sp) :
    {F.array__thaw(U32, _) == ANode{A, Bn} : Array<U32>}
  %Equal.sym(Array<U32>, F.array__thaw(U32, seg(s, i, p)), A, ea) : {ANode{_, F.array__thaw(U32, seg(s, j, p))} == ANode{A, Bn} : Array<U32>}
  %Equal.sym(Array<U32>, F.array__thaw(U32, seg(s, j, p)), Bn, eb) : {ANode{A, _} == ANode{A, Bn} : Array<U32>}
  {==}
