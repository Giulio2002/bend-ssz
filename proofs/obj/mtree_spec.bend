import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../spec/tree.bend as Tr
import ../../spec/merkle.bend as M
import 0xd9a2fae439ac7ff9e21e0853948f94fe/spec/crypto/sha.bend as VF
import ./mtree_defs.bend as MD
import ./sha_node.bend as SN
import ./zero_roots.bend as ZR
import ../compact/found.bend as F

# The Merkle layer, specification side: a reference tree over a list of
# digests, with the node and the zero-subtree roots abstract, is the
# specification's `tree` (spec/tree.bend) of the digests' bytes.
#
# `MD.rtree(d, inside, hl, L, s)` is the root of the digests L[s .. s + 2^d)
# (digests past the end of L count as absent): Z(d) when s is past the end,
# L[s] at depth 0, and node(hl, left, right) otherwise - the same recursion as
# the runtime trees O.mtree / O.ctree and the generated `{p}_mt`, so each of
# them is proved equal to it by a direct induction (proofs/obj/mtree_run.bend),
# and this module carries the result on to the specification. Nothing here
# normalizes SHA-256: `hl` stays abstract, and the node enters only through
# SN.node_at under the carried equation `hl == 64n`; the zero-subtree roots are
# the constants D.zconst, checked against the specification in
# proofs/obj/zero_roots.bend (trees are at most 63 levels deep).

# ---- list algebra -------------------------------------------------------------

law drop_bytes:
  for +n: Nat
  for +L: List<&2, D.Digest>
  {Tr.drop(n, MD.bytes_list(L)) == MD.bytes_list(MD.ddrop(n, L)) : +List<+List<U32>>}
def drop_bytes(n, L):
  match n:
    case 0n: {==}
    case 1n+ +p:
      match L:
        case Nil{}: {==}
        case Con{+x, +t}: drop_bytes(p, t)

law ddrop_add:
  for +a: Nat
  for +b: Nat
  for +L: List<&2, D.Digest>
  {MD.ddrop(b, MD.ddrop(a, L)) == MD.ddrop(Nat.add(a, b), L) : List<&2, D.Digest>}
def ddrop_add(a, b, L):
  match a:
    case 0n: {==}
    case 1n+ +p:
      match b:
        case 0n:
          match L:
            case Nil{}: {==}
            case Con{+x, +t}: ddrop_add(p, 0n, t)
        case 1n+ +q:
          match L:
            case Nil{}: {==}
            case Con{+x, +t}: ddrop_add(p, 1n+q, t)

law capacity_pow2:
  for +p: Nat
  {Tr.capacity(p) == O.pow2n(p) : Nat}
def capacity_pow2(p):
  match p:
    case 0n: {==}
    case 1n+ +q:
      %capacity_pow2(q) : {Nat.double(Tr.capacity(q)) == Nat.double(_) : Nat}
      {==}

# Past the end of L nothing is left.
law ddrop_past:
  for +s: Nat
  for +L: List<&2, D.Digest>
  for +e: {Nat.is_lt(s, MD.dlen(L)) == False{} : Bool}
  {MD.ddrop(s, L) == [] : List<&2, D.Digest>}
def ddrop_past(s, L, e):
  match s:
    case 0n:
      match L:
        case Nil{}: {==}
        case Con{x, t}: Empty.absurd({MD.ddrop(0n, Con{x, t}) == [] : List<&2, D.Digest>}, MD.true_false(e))
    case 1n+ +p:
      match L:
        case Nil{}: {==}
        case Con{+x, +t}: ddrop_past(p, t, e)

# Before the end of L the suffix is a nonempty list.
law ddrop_eta:
  for +s: Nat
  for +L: List<&2, D.Digest>
  for +e: {Nat.is_lt(s, MD.dlen(L)) == True{} : Bool}
  {MD.ddrop(s, L) == Con{MD.dhead(MD.ddrop(s, L)), MD.dtail(MD.ddrop(s, L))} : List<&2, D.Digest>}
def ddrop_eta(s, L, e):
  match s:
    case 0n:
      match L:
        case Nil{}: Empty.absurd({MD.ddrop(0n, Nil{}) == Con{MD.dhead(MD.ddrop(0n, Nil{})), MD.dtail(MD.ddrop(0n, Nil{}))} : List<&2, D.Digest>}, MD.false_true(e))
        case Con{x, t}: {==}
    case 1n+ +p:
      match L:
        case Nil{}: Empty.absurd({MD.ddrop(1n+p, Nil{}) == Con{MD.dhead(MD.ddrop(1n+p, Nil{})), MD.dtail(MD.ddrop(1n+p, Nil{}))} : List<&2, D.Digest>}, MD.false_true(e))
        case Con{+x, +t}: ddrop_eta(p, t, e)

# ---- the tree over a nonempty suffix -------------------------------------------

law tree_leaf:
  for +x: D.Digest
  for +t: List<&2, D.Digest>
  {Tr.tree(0n, MD.bytes_list(Con{x, t})) == D.bytes(x) : +List<U32>}
def tree_leaf(x, t): {==}

law tree_node:
  for +p: Nat
  for +x: D.Digest
  for +t: List<&2, D.Digest>
  {Tr.tree(1n+p, MD.bytes_list(Con{x, t}))
    == VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(Con{x, t})), Tr.tree(p, Tr.drop(Tr.capacity(p), MD.bytes_list(Con{x, t}))))) : +List<U32>}
def tree_node(p, x, t): {==}

law tree_empty:
  for +d: Nat
  {Tr.tree(d, MD.bytes_list([])) == M.zero_subtree(d) : +List<U32>}
def tree_empty(d):
  match d:
    case 0n: {==}
    case 1n+p: {==}

# ---- the reference tree is the specification's tree -----------------------------

# The node step, with both children's equations given.
def rtree_node(+p: Nat, +hl: Nat, +L: List<&2, D.Digest>, +s: Nat,
    +e: {Nat.is_lt(s, MD.dlen(L)) == True{} : Bool},
    +ehl: {hl == 64n : Nat},
    +il: {D.bytes(MD.rtree(p, True{}, hl, L, s)) == Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>},
    +ir: {D.bytes(MD.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), MD.dlen(L)), hl, L, Nat.add(s, O.pow2n(p)))) == Tr.tree(p, MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(p)), L))) : +List<U32>})
    -> {D.bytes(MD.rtree(1n+p, True{}, hl, L, s)) == Tr.tree(1n+p, MD.bytes_list(Con{MD.dhead(MD.ddrop(s, L)), MD.dtail(MD.ddrop(s, L))})) : +List<U32>}:
  +RL = MD.rtree(p, True{}, hl, L, s)
  +RR = MD.rtree(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), MD.dlen(L)), hl, L, Nat.add(s, O.pow2n(p)))
  +X = {Con{MD.dhead(MD.ddrop(s, L)), MD.dtail(MD.ddrop(s, L))} : List<&2, D.Digest>}
  %Equal.sym(+List<U32>, D.bytes(D.node(hl, RL, RR)), VF.sha256_bytes(List.append(&2, U32, D.bytes(RL), D.bytes(RR))), SN.node_at(hl, ehl, RL, RR)) :
    {_ == Tr.tree(1n+p, MD.bytes_list(X)) : +List<U32>}
  %Equal.sym(+List<U32>, D.bytes(RL), Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), il) :
    {VF.sha256_bytes(List.append(&2, U32, _, D.bytes(RR))) == Tr.tree(1n+p, MD.bytes_list(X)) : +List<U32>}
  %Equal.sym(+List<U32>, D.bytes(RR), Tr.tree(p, MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(p)), L))), ir) :
    {VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), _)) == Tr.tree(1n+p, MD.bytes_list(X)) : +List<U32>}
  %Equal.sym(+List<U32>, Tr.tree(1n+p, MD.bytes_list(X)),
      VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(X)), Tr.tree(p, Tr.drop(Tr.capacity(p), MD.bytes_list(X))))),
      tree_node(p, MD.dhead(MD.ddrop(s, L)), MD.dtail(MD.ddrop(s, L)))) :
    {VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), Tr.tree(p, MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(p)), L))))) == _ : +List<U32>}
  %Equal.sym(+List<+List<U32>>, Tr.drop(Tr.capacity(p), MD.bytes_list(X)), MD.bytes_list(MD.ddrop(Tr.capacity(p), X)), drop_bytes(Tr.capacity(p), X)) :
    {VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), Tr.tree(p, MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(p)), L)))))
      == VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(X)), Tr.tree(p, _))) : +List<U32>}
  %ddrop_eta(s, L, e) :
    {VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), Tr.tree(p, MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(p)), L)))))
      == VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(_)), Tr.tree(p, MD.bytes_list(MD.ddrop(Tr.capacity(p), _))))) : +List<U32>}
  %Equal.sym(List<&2, D.Digest>, MD.ddrop(Tr.capacity(p), MD.ddrop(s, L)), MD.ddrop(Nat.add(s, Tr.capacity(p)), L), ddrop_add(s, Tr.capacity(p), L)) :
    {VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), Tr.tree(p, MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(p)), L)))))
      == VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), Tr.tree(p, MD.bytes_list(_)))) : +List<U32>}
  %Equal.sym(Nat, Tr.capacity(p), O.pow2n(p), capacity_pow2(p)) :
    {VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), Tr.tree(p, MD.bytes_list(MD.ddrop(Nat.add(s, O.pow2n(p)), L)))))
      == VF.sha256_bytes(List.append(&2, U32, Tr.tree(p, MD.bytes_list(MD.ddrop(s, L))), Tr.tree(p, MD.bytes_list(MD.ddrop(Nat.add(s, _), L))))) : +List<U32>}
  {==}

law rtree_spec:
  for +d: Nat
  for +b: Bool
  for +hl: Nat
  for +L: List<&2, D.Digest>
  for +s: Nat
  for +e: {Nat.is_lt(s, MD.dlen(L)) == b : Bool}
  for +hd: {Nat.is_lt(d, 64n) == True{} : Bool}
  for +ehl: {hl == 64n : Nat}
  {D.bytes(MD.rtree(d, b, hl, L, s)) == Tr.tree(d, MD.bytes_list(MD.ddrop(s, L))) : +List<U32>}
def rtree_spec(d, b, hl, L, s, e, hd, ehl):
  match d:
    case 0n:
      match b:
        case False{}:
          %Equal.sym(List<&2, D.Digest>, MD.ddrop(s, L), [], ddrop_past(s, L, e)) :
            {D.bytes(MD.rtree(0n, False{}, hl, L, s)) == Tr.tree(0n, MD.bytes_list(_)) : +List<U32>}
          ZR.zconst_spec(0n, hd)
        case True{}:
          %Equal.sym(List<&2, D.Digest>, MD.ddrop(s, L), Con{MD.dhead(MD.ddrop(s, L)), MD.dtail(MD.ddrop(s, L))}, ddrop_eta(s, L, e)) :
            {D.bytes(MD.rtree(0n, True{}, hl, L, s)) == Tr.tree(0n, MD.bytes_list(_)) : +List<U32>}
          {==}
    case 1n+ +p:
      match b:
        case False{}:
          %Equal.sym(List<&2, D.Digest>, MD.ddrop(s, L), [], ddrop_past(s, L, e)) :
            {D.bytes(MD.rtree(1n+p, False{}, hl, L, s)) == Tr.tree(1n+p, MD.bytes_list(_)) : +List<U32>}
          ZR.zconst_spec(1n+p, hd)
        case True{}:
          %Equal.sym(List<&2, D.Digest>, MD.ddrop(s, L), Con{MD.dhead(MD.ddrop(s, L)), MD.dtail(MD.ddrop(s, L))}, ddrop_eta(s, L, e)) :
            {D.bytes(MD.rtree(1n+p, True{}, hl, L, s)) == Tr.tree(1n+p, MD.bytes_list(_)) : +List<U32>}
          rtree_node(p, hl, L, s, e, ehl,
            rtree_spec(p, True{}, hl, L, s, e, F.nat__lt_trans(p, 63n, 64n, hd, {==}), ehl),
            rtree_spec(p, Nat.is_lt(Nat.add(s, O.pow2n(p)), MD.dlen(L)), hl, L, Nat.add(s, O.pow2n(p)), {==}, F.nat__lt_trans(p, 63n, 64n, hd, {==}), ehl))

