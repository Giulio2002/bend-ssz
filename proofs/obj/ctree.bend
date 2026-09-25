import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../proofs/nat_order.bend as Order
import ../../proofs/nat_algebra.bend as NA
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./words_spec.bend as WS
import ./digest_facts.bend as DF

# The heap model of the cached Merkle trees (the `_Cached` lists of the
# generated object API: element roots at the leaves of a perfect tree of depth
# d, stored heap-ordered in a node array: node k has children 2k and 2k + 1,
# the leaves are 2^d .. 2^(d+1) - 1, the root is node 1).
#
# The value a node must hold is the reference tree (mtree_defs rtree) of the
# leaves below it: node j of level l (level 0 = the leaves) covers the leaf
# digests XL[j 2^l .. (j + 1) 2^l); past the n element roots it is the
# zero-subtree root of its height. `node_rule` is the one step the runtime's
# sweep performs: the node of two correct children is the correct parent.

def sof(l: Nat, +j: Nat) -> Nat:
  match l:
    case 0n: j
    case 1n+k: sof(k, Nat.double(j))

def mv(+hl: Nat, +l: Nat, +j: Nat, +n: Nat, +XL: List<&2, D.Digest>) -> D.Digest:
  MD.rtree(l, Nat.is_lt(sof(l, j), n), hl, XL, sof(l, j))

# ---- arithmetic of the leaf ranges -----------------------------------------------

law dbl_add:
  for +a: Nat
  for +b: Nat
  {Nat.double(Nat.add(a, b)) == Nat.add(Nat.double(a), Nat.double(b)) : Nat}
def dbl_add(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.double(Nat.add(p, b)), Nat.add(Nat.double(p), Nat.double(b)), dbl_add(p, b)) : {2n+_ == 2n+Nat.add(Nat.double(p), Nat.double(b)) : Nat}
      {==}

law dbl_self:
  for +p: Nat
  {Nat.double(p) == Nat.add(p, p) : Nat}
def dbl_self(p):
  match p:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Nat.double(q), Nat.add(q, q), dbl_self(q)) : {2n+_ == 1n+Nat.add(q, 1n+q) : Nat}
      %Equal.sym(Nat, Nat.add(q, 1n+q), 1n+Nat.add(q, q), MR.add_succ(q, q)) : {2n+Nat.add(q, q) == 1n+_ : Nat}
      {==}

# The first leaf of the left child of (l + 1, j) is the node's first leaf.
def sof_left(+l: Nat, +j: Nat) -> {sof(l, Nat.double(j)) == sof(1n+l, j) : Nat}: {==}

# One more index at level l moves the first leaf by 2^l.
law sof_succ:
  for +l: Nat
  for +x: Nat
  {sof(l, 1n+x) == Nat.add(sof(l, x), O.pow2n(l)) : Nat}
def sof_succ(l, x):
  match l:
    case 0n:
      NA.add_commute(1n, x)
    case 1n+ +k:
      # sof(k, 2 + 2x) = sof(k, 1 + 2x) + 2^k = sof(k, 2x) + 2^k + 2^k
      %Equal.sym(Nat, sof(k, 2n+Nat.double(x)), Nat.add(sof(k, 1n+Nat.double(x)), O.pow2n(k)), sof_succ(k, 1n+Nat.double(x))) :
        {_ == Nat.add(sof(k, Nat.double(x)), Nat.double(O.pow2n(k))) : Nat}
      %Equal.sym(Nat, sof(k, 1n+Nat.double(x)), Nat.add(sof(k, Nat.double(x)), O.pow2n(k)), sof_succ(k, Nat.double(x))) :
        {Nat.add(_, O.pow2n(k)) == Nat.add(sof(k, Nat.double(x)), Nat.double(O.pow2n(k))) : Nat}
      %Equal.sym(Nat, Nat.double(O.pow2n(k)), Nat.add(O.pow2n(k), O.pow2n(k)), dbl_self(O.pow2n(k))) :
        {Nat.add(Nat.add(sof(k, Nat.double(x)), O.pow2n(k)), O.pow2n(k)) == Nat.add(sof(k, Nat.double(x)), _) : Nat}
      WS.add_assoc(sof(k, Nat.double(x)), O.pow2n(k), O.pow2n(k))

# The first leaf of the right child is the node's first leaf plus 2^l.
def sof_right(+l: Nat, +j: Nat) -> {sof(l, 1n+Nat.double(j)) == Nat.add(sof(1n+l, j), O.pow2n(l)) : Nat}:
  sof_succ(l, Nat.double(j))

def mv_z(+l: Nat, +hl: Nat, +XL: List<&2, D.Digest>, +s: Nat) -> {MD.rtree(l, False{}, hl, XL, s) == D.zconst(l) : D.Digest}:
  match l:
    case 0n: {==}
    case 1n+p: {==}

# ---- the node rule ----------------------------------------------------------------

# Past the elements, a node of height l is Z(l).
def mv_out(+l: Nat, +j: Nat, +hl: Nat, +n: Nat, +XL: List<&2, D.Digest>,
    +e: {Nat.is_lt(sof(l, j), n) == False{} : Bool}) -> {mv(hl, l, j, n, XL) == D.zconst(l) : D.Digest}:
  %Equal.sym(Bool, Nat.is_lt(sof(l, j), n), False{}, e) : {MD.rtree(l, _, hl, XL, sof(l, j)) == D.zconst(l) : D.Digest}
  mv_z(l, hl, XL, sof(l, j))

law le_lt_add:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +e: {Nat.is_lt(Nat.add(a, b), c) == True{} : Bool}
  {Nat.is_lt(a, c) == True{} : Bool}
def le_lt_add(a, b, c, e): F.nat__le_lt_trans(a, Nat.add(a, b), c, Order.below_sum(a, b), e)

def out_right(+s: Nat, +P: Nat, +n: Nat, +e: {Nat.is_lt(s, n) == False{} : Bool}) -> {Nat.is_lt(Nat.add(s, P), n) == False{} : Bool}:
  F.nat__le_not_lt(Nat.add(s, P), n, F.nat__le_trans(n, s, Nat.add(s, P), F.nat__not_lt_le(s, n, e), Order.below_sum(s, P)))

def node_case(+l: Nat, +s: Nat, +n: Nat, +XL: List<&2, D.Digest>, +en: {MD.dlen(XL) == n : Nat},
    +hl63: {Nat.is_lt(l, 63n) == True{} : Bool}, +b: Bool, +eb: {Nat.is_lt(s, n) == b : Bool})
    -> {D.node(64n, MD.rtree(l, Nat.is_lt(s, n), 64n, XL, s), MD.rtree(l, Nat.is_lt(Nat.add(s, O.pow2n(l)), n), 64n, XL, Nat.add(s, O.pow2n(l)))) == MD.rtree(1n+l, Nat.is_lt(s, n), 64n, XL, s) : D.Digest}:
  match b:
    case True{}:
      %Equal.sym(Bool, Nat.is_lt(s, n), True{}, eb) : {D.node(64n, MD.rtree(l, _, 64n, XL, s), MD.rtree(l, Nat.is_lt(Nat.add(s, O.pow2n(l)), n), 64n, XL, Nat.add(s, O.pow2n(l)))) == MD.rtree(1n+l, _, 64n, XL, s) : D.Digest}
      # inside: the reference tree's own step (its right flag reads dlen(XL) = n)
      %en :
        {D.node(64n, MD.rtree(l, True{}, 64n, XL, s), MD.rtree(l, Nat.is_lt(Nat.add(s, O.pow2n(l)), _), 64n, XL, Nat.add(s, O.pow2n(l)))) == MD.rtree(1n+l, True{}, 64n, XL, s) : D.Digest}
      {==}
    case False{}:
      # outside: both children are past the elements, Z(l) and Z(l), and the node is Z(l + 1)
      %Equal.sym(Bool, Nat.is_lt(s, n), False{}, eb) : {D.node(64n, MD.rtree(l, _, 64n, XL, s), MD.rtree(l, Nat.is_lt(Nat.add(s, O.pow2n(l)), n), 64n, XL, Nat.add(s, O.pow2n(l)))) == MD.rtree(1n+l, _, 64n, XL, s) : D.Digest}
      %Equal.sym(Bool, Nat.is_lt(Nat.add(s, O.pow2n(l)), n), False{}, out_right(s, O.pow2n(l), n, eb)) :
        {D.node(64n, MD.rtree(l, False{}, 64n, XL, s), MD.rtree(l, _, 64n, XL, Nat.add(s, O.pow2n(l)))) == MD.rtree(1n+l, False{}, 64n, XL, s) : D.Digest}
      %Equal.sym(D.Digest, MD.rtree(l, False{}, 64n, XL, s), D.zconst(l), mv_z(l, 64n, XL, s)) :
        {D.node(64n, _, MD.rtree(l, False{}, 64n, XL, Nat.add(s, O.pow2n(l)))) == D.zconst(1n+l) : D.Digest}
      %Equal.sym(D.Digest, MD.rtree(l, False{}, 64n, XL, Nat.add(s, O.pow2n(l))), D.zconst(l), mv_z(l, 64n, XL, Nat.add(s, O.pow2n(l)))) :
        {D.node(64n, D.zconst(l), _) == D.zconst(1n+l) : D.Digest}
      DF.zero_node(l, hl63)

# The runtime node of the two children of (l + 1, j), each holding its value,
# holds the parent's value (hl = 64: the zero-subtree roots are SHA-256 nodes).
law node_rule:
  for +l: Nat
  for +j: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +en: {MD.dlen(XL) == n : Nat}
  for +hl63: {Nat.is_lt(l, 63n) == True{} : Bool}
  {D.node(64n, mv(64n, l, Nat.double(j), n, XL), mv(64n, l, 1n+Nat.double(j), n, XL)) == mv(64n, 1n+l, j, n, XL) : D.Digest}
def node_rule(l, j, n, XL, en, hl63):
  +s = sof(1n+l, j)
  %Equal.sym(Nat, sof(l, Nat.double(j)), s, sof_left(l, j)) :
    {D.node(64n, MD.rtree(l, Nat.is_lt(_, n), 64n, XL, _), mv(64n, l, 1n+Nat.double(j), n, XL)) == mv(64n, 1n+l, j, n, XL) : D.Digest}
  %Equal.sym(Nat, sof(l, 1n+Nat.double(j)), Nat.add(s, O.pow2n(l)), sof_right(l, j)) :
    {D.node(64n, MD.rtree(l, Nat.is_lt(s, n), 64n, XL, s), MD.rtree(l, Nat.is_lt(_, n), 64n, XL, _)) == mv(64n, 1n+l, j, n, XL) : D.Digest}
  node_case(l, s, n, XL, en, hl63, Nat.is_lt(s, n), {==})

# ---- the invariant ----------------------------------------------------------------

# The heap position of node j of level l in a tree of depth d.
def hp(+d: Nat, +l: Nat, +j: Nat) -> Nat: Nat.add(O.pow2n(Nat.sub(d, l)), j)

# Half, rounded down, and the dirty range of level l: the runtime sweeps level
# l + 1 over the halves of level l's range (heap indices shifted right by one).
def h2(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p:
      match p:
        case 0n: 0n
        case 1n+q: 1n+h2(q)

def rng(l: Nat, +x: Nat) -> Nat:
  match l:
    case 0n: x
    case 1n+k: h2(rng(k, x))

# Node (l, j) is clean for the dirty leaf range [lo, hi] (no range when hi < lo):
# it is outside level l's range [rng(l, lo), rng(l, hi)].
def clean(+l: Nat, +j: Nat, +lo: Nat, +hi: Nat) -> Bool:
  Bool.or(Nat.is_lt(hi, lo), Bool.or(Nat.is_lt(j, rng(l, lo)), Nat.is_lt(rng(l, hi), j)))

# Node (l, j) holds its value in the node slots NS.
def ok_at(+NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +XL: List<&2, D.Digest>) -> Data:
  {F.spec_common__nth(D.Digest, NS, hp(d, l, j)) == Some{mv(64n, l, j, n, XL)} : Maybe<&2, D.Digest>}

# A write at another position leaves a node's value alone.
def ok_other(+NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +XL: List<&2, D.Digest>, +k: Nat, +v: D.Digest,
    +ne: {Nat.is_eq(k, hp(d, l, j)) == False{} : Bool},
    +ok: ok_at(NS, d, l, j, n, XL)) -> ok_at(F.spec_common__update(D.Digest, NS, k, v), d, l, j, n, XL):
  %Equal.sym(Maybe<&2, D.Digest>, F.spec_common__nth(D.Digest, F.spec_common__update(D.Digest, NS, k, v), hp(d, l, j)), F.spec_common__nth(D.Digest, NS, hp(d, l, j)),
      F.list__nth_update_other(D.Digest, NS, k, hp(d, l, j), v, ne)) :
    {_ == Some{mv(64n, l, j, n, XL)} : Maybe<&2, D.Digest>}
  ok

# A write of a node's value at its position.
def ok_same(+NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +XL: List<&2, D.Digest>,
    +hk: {Nat.is_lt(hp(d, l, j), F.spec_common__length(D.Digest, NS)) == True{} : Bool})
    -> ok_at(F.spec_common__update(D.Digest, NS, hp(d, l, j), mv(64n, l, j, n, XL)), d, l, j, n, XL):
  F.list__nth_update_same(D.Digest, NS, hp(d, l, j), mv(64n, l, j, n, XL), hk)

def root_lt(+d: Nat) -> {Nat.is_lt(0n, O.pow2n(Nat.sub(d, d))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.sub(d, d), 0n, F.nat__sub_self(d)) : {Nat.is_lt(0n, O.pow2n(_)) == True{} : Bool}
  {==}

def clean_emp(+l: Nat, +j: Nat, +lo: Nat, +hi: Nat, +emp: {Nat.is_lt(hi, lo) == True{} : Bool}) -> {clean(l, j, lo, hi) == True{} : Bool}:
  %Equal.sym(Bool, Nat.is_lt(hi, lo), True{}, emp) :
    {Bool.or(_, Bool.or(Nat.is_lt(j, rng(l, lo)), Nat.is_lt(rng(l, hi), j))) == True{} : Bool}
  {==}

# ---- heap positions are unique ----------------------------------------------------------

# 2^a + j with j < 2^a lies in [2^a, 2^(a+1)).
def hp_lo(+a: Nat, +j: Nat) -> {Nat.is_le(O.pow2n(a), Nat.add(O.pow2n(a), j)) == True{} : Bool}: Order.below_sum(O.pow2n(a), j)

def hp_hi(+a: Nat, +j: Nat, +hj: {Nat.is_lt(j, O.pow2n(a)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(O.pow2n(a), j), O.pow2n(1n+a)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.double(O.pow2n(a)), Nat.add(O.pow2n(a), O.pow2n(a)), dbl_self(O.pow2n(a))) : {Nat.is_lt(Nat.add(O.pow2n(a), j), _) == True{} : Bool}
  F.nat__lt_add_left(j, O.pow2n(a), O.pow2n(a), hj)

law pow2_pos:
  for +d: Nat
  {Nat.is_le(1n, O.pow2n(d)) == True{} : Bool}
def pow2_pos(d):
  match d:
    case 0n: {==}
    case 1n+ +p: Order.transitive(1n, O.pow2n(p), Nat.double(O.pow2n(p)), pow2_pos(p), F.nat__double_self_le(O.pow2n(p)))

def lt_one_dbl(+p: Nat) -> {Nat.is_lt(1n, Nat.double(O.pow2n(p))) == True{} : Bool}:
  F.nat__lt_le_trans(1n, 2n, Nat.double(O.pow2n(p)), {==}, Order.double_monotone(1n, O.pow2n(p), pow2_pos(p)))

law dbl_le_cancel:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(Nat.double(a), Nat.double(b)) == True{} : Bool}
  {Nat.is_le(a, b) == True{} : Bool}
def dbl_le_cancel(a, b, e):
  match a b:
    case 0n _: Order.zero_le(b)
    case 1n+p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, MD.false_true(e))
    case 1n+ +p 1n+ +q: dbl_le_cancel(p, q, e)

law pow2_le_inv:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(O.pow2n(a), O.pow2n(b)) == True{} : Bool}
  {Nat.is_le(a, b) == True{} : Bool}
def pow2_le_inv(a, b, h):
  match a b:
    case 0n _: Order.zero_le(b)
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(1n+p, 0n) == True{} : Bool}, Order.le_lt_conflict(Nat.double(O.pow2n(p)), 1n, h, lt_one_dbl(p)))
    case 1n+ +p 1n+ +q: pow2_le_inv(p, q, dbl_le_cancel(O.pow2n(p), O.pow2n(q), h))

# rw_le(x, y, c, e: x == y, h: c <= x) : c <= y
def rw_le(+x: Nat, +y: Nat, +c: Nat, +e: {x == y : Nat}, +h: {Nat.is_le(c, x) == True{} : Bool}) -> {Nat.is_le(c, y) == True{} : Bool}:
  %e : {Nat.is_le(c, _) == True{} : Bool}
  h

law pow2_mono:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(O.pow2n(a), O.pow2n(b)) == True{} : Bool}
def pow2_mono(a, b, e):
  match a b:
    case 0n _: pow2_pos(b)
    case 1n+p 0n: Empty.absurd({Nat.is_le(O.pow2n(1n+p), 1n) == True{} : Bool}, MD.false_true(e))
    case 1n+ +p 1n+ +q: Order.double_monotone(O.pow2n(p), O.pow2n(q), pow2_mono(p, q, e))

# Two positions 2^a + j and 2^b + k (j < 2^a, k < 2^b) are equal only for a = b.
def hp_level(+a: Nat, +b: Nat, +j: Nat, +k: Nat,
    +hj: {Nat.is_lt(j, O.pow2n(a)) == True{} : Bool}, +hk: {Nat.is_lt(k, O.pow2n(b)) == True{} : Bool},
    +e: {Nat.add(O.pow2n(a), j) == Nat.add(O.pow2n(b), k) : Nat}) -> {a == b : Nat}:
  Order.equal_if_neither_less(a, b,
    ab => Order.le_lt_conflict(O.pow2n(b), Nat.add(O.pow2n(a), j),
      rw_le(Nat.add(O.pow2n(b), k), Nat.add(O.pow2n(a), j), O.pow2n(b), Equal.sym(Nat, Nat.add(O.pow2n(a), j), Nat.add(O.pow2n(b), k), e), hp_lo(b, k)) ,
      F.nat__lt_le_trans(Nat.add(O.pow2n(a), j), O.pow2n(1n+a), O.pow2n(b), hp_hi(a, j, hj), pow2_mono(1n+a, b, F.nat__lt_succ_le_succ(a, b, ab)))),
    ba => Order.le_lt_conflict(O.pow2n(a), Nat.add(O.pow2n(b), k),
      rw_le(Nat.add(O.pow2n(a), j), Nat.add(O.pow2n(b), k), O.pow2n(a), e, hp_lo(a, j)),
      F.nat__lt_le_trans(Nat.add(O.pow2n(b), k), O.pow2n(1n+b), O.pow2n(a), hp_hi(b, k, hk), pow2_mono(1n+b, a, F.nat__lt_succ_le_succ(b, a, ba)))))

# ---- small Nat facts ---------------------------------------------------------------

law sub_le:
  for +a: Nat
  for +b: Nat
  {Nat.is_le(Nat.sub(a, b), a) == True{} : Bool}
def sub_le(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+ +p 0n: F.nat__le_refl(1n+p)
    case 1n+ +p 1n+ +q: F.nat__le_trans(Nat.sub(p, q), p, 1n+p, sub_le(p, q), F.nat__le_succ(p))

law sub_lt_self:
  for +d: Nat
  for +p: Nat
  for +hl: {Nat.is_le(1n+p, d) == True{} : Bool}
  {Nat.is_lt(Nat.sub(d, 1n+p), d) == True{} : Bool}
def sub_lt_self(d, p, hl):
  match d:
    case 0n: Empty.absurd({Nat.is_lt(Nat.sub(0n, 1n+p), 0n) == True{} : Bool}, MD.false_true(hl))
    case 1n+ +q: F.nat__le_lt_succ(Nat.sub(q, p), q, sub_le(q, p))

# d - l = d with l <= d forces l = 0.
law sub_self_zero:
  for +d: Nat
  for +l: Nat
  for +hl: {Nat.is_le(l, d) == True{} : Bool}
  for +e: {Nat.sub(d, l) == d : Nat}
  {l == 0n : Nat}
def sub_self_zero(d, l, hl, e):
  match l:
    case 0n: {==}
    case 1n+ +p: Empty.absurd({1n+p == 0n : Nat}, F.nat__lt_ne(Nat.sub(d, 1n+p), d, sub_lt_self(d, p, hl), e))

def rw_lt(+x: Nat, +y: Nat, +c: Nat, +e: {x == y : Nat}, +h: {Nat.is_lt(c, x) == True{} : Bool}) -> {Nat.is_lt(c, y) == True{} : Bool}:
  %e : {Nat.is_lt(c, _) == True{} : Bool}
  h

law add_cancel:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +e: {Nat.add(a, b) == Nat.add(a, c) : Nat}
  {b == c : Nat}
def add_cancel(a, b, c, e):
  match a:
    case 0n: e
    case 1n+ +p: add_cancel(p, b, c, F.nat__succ_inj(Nat.add(p, b), Nat.add(p, c), e))

law neq_of_lt:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_lt(b, a) == True{} : Bool}
  {Nat.is_eq(a, b) == False{} : Bool}
def neq_of_lt(a, b, h):
  match a b:
    case 0n 0n: Empty.absurd({Nat.is_eq(0n, 0n) == False{} : Bool}, MD.false_true(h))
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+ +p 1n+ +q: neq_of_lt(p, q, h)

# ---- writing the nodes of one level -------------------------------------------------

law sub_inj:
  for +d: Nat
  for +a: Nat
  for +b: Nat
  for +ha: {Nat.is_le(a, d) == True{} : Bool}
  for +hb: {Nat.is_le(b, d) == True{} : Bool}
  for +e: {Nat.sub(d, a) == Nat.sub(d, b) : Nat}
  {a == b : Nat}
def sub_inj(d, a, b, ha, hb, e):
  # a + (d - a) = d = b + (d - b), and d - a = d - b
  +ea = F.nat__sub_add(d, a, ha)
  +eb = F.nat__sub_add(d, b, hb)
  +e2 = Equal.trans(Nat, Nat.add(a, Nat.sub(d, a)), d, Nat.add(b, Nat.sub(d, a)), ea,
    Equal.trans(Nat, d, Nat.add(b, Nat.sub(d, b)), Nat.add(b, Nat.sub(d, a)), Equal.sym(Nat, Nat.add(b, Nat.sub(d, b)), d, eb),
      Equal.cong(Nat, Nat, x => Nat.add(b, x), Nat.sub(d, b), Nat.sub(d, a), Equal.sym(Nat, Nat.sub(d, a), Nat.sub(d, b), e))))
  add_cancel(Nat.sub(d, a), a, b, Equal.trans(Nat, Nat.add(Nat.sub(d, a), a), Nat.add(a, Nat.sub(d, a)), Nat.add(Nat.sub(d, a), b),
    NA.add_commute(Nat.sub(d, a), a), Equal.trans(Nat, Nat.add(a, Nat.sub(d, a)), Nat.add(b, Nat.sub(d, a)), Nat.add(Nat.sub(d, a), b), e2, NA.add_commute(b, Nat.sub(d, a)))))

def or_l(+a: Bool, +b: Bool, +e: {a == True{} : Bool}) -> {Bool.or(a, b) == True{} : Bool}:
  %Equal.sym(Bool, a, True{}, e) : {Bool.or(_, b) == True{} : Bool}
  {==}

def or_r(+a: Bool, +b: Bool, +e: {b == True{} : Bool}) -> {Bool.or(a, b) == True{} : Bool}:
  match a:
    case True{}: {==}
    case False{}: e

def hp_lt(+d: Nat, +L: Nat, +i: Nat, +hL: {Nat.is_le(L, d) == True{} : Bool}, +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool})
    -> {Nat.is_lt(hp(d, L, i), O.pow2n(1n+d)) == True{} : Bool}:
  F.nat__lt_le_trans(hp(d, L, i), O.pow2n(1n+Nat.sub(d, L)), O.pow2n(1n+d), hp_hi(Nat.sub(d, L), i, hi),
    pow2_mono(1n+Nat.sub(d, L), 1n+d, sub_le(d, L)))

def lt_len(+NS: List<&2, D.Digest>, +d: Nat, +k: Nat, +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat},
    +h: {Nat.is_lt(k, O.pow2n(1n+d)) == True{} : Bool}) -> {Nat.is_lt(k, F.spec_common__length(D.Digest, NS)) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(D.Digest, NS), O.pow2n(1n+d), len) : {Nat.is_lt(k, _) == True{} : Bool}
  h

# The write of node (L, i)'s value at its position: a node at that position is
# (L, i) itself, so it holds its value.
def w_same(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat, +i: Nat, +l: Nat, +j: Nat,
    +hL: {Nat.is_le(L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat},
    +hl: {Nat.is_le(l, d) == True{} : Bool},
    +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, l))) == True{} : Bool},
    +e: {hp(d, L, i) == hp(d, l, j) : Nat})
    -> ok_at(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, l, j, n, XL):
  +ea = hp_level(Nat.sub(d, L), Nat.sub(d, l), i, j, hi, hj, e)
  +el = sub_inj(d, l, L, hl, hL, Equal.sym(Nat, Nat.sub(d, L), Nat.sub(d, l), ea))
  +e0 = Equal.trans(Nat, Nat.add(O.pow2n(Nat.sub(d, L)), i), Nat.add(O.pow2n(Nat.sub(d, l)), j), Nat.add(O.pow2n(Nat.sub(d, L)), j), e,
    Equal.cong(Nat, Nat, x => Nat.add(O.pow2n(Nat.sub(d, x)), j), l, L, el))
  +ej = add_cancel(O.pow2n(Nat.sub(d, L)), i, j, e0)
  %Equal.sym(Nat, l, L, el) : ok_at(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, _, j, n, XL)
  %ej : ok_at(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, L, _, n, XL)
  ok_same(NS, d, L, i, n, XL, lt_len(NS, d, hp(d, L, i), len, hp_lt(d, L, i, hL, hi)))

def w_cl1(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat, +i: Nat, +l: Nat, +j: Nat,
    +hL: {Nat.is_le(L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat},
    +hl: {Nat.is_le(l, d) == True{} : Bool},
    +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, l))) == True{} : Bool},
    +ok: ok_at(NS, d, l, j, n, XL),
    +b: Bool, +eb: {Nat.is_eq(hp(d, L, i), hp(d, l, j)) == b : Bool})
    -> ok_at(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, l, j, n, XL):
  match b:
    case False{}: ok_other(NS, d, l, j, n, XL, hp(d, L, i), mv(64n, L, i, n, XL), eb, ok)
    case True{}: w_same(NS, d, n, XL, L, i, l, j, hL, hi, len, hl, hj, F.nat__eq_from_is_eq(hp(d, L, i), hp(d, l, j), eb))

def is_eq_of_eq(+a: Nat, +b: Nat, +e: {a == b : Nat}) -> {Nat.is_eq(a, b) == True{} : Bool}:
  %e : {Nat.is_eq(a, _) == True{} : Bool}
  F.nat__is_eq_refl(a)

# The write of a node's value keeps every node of another level.
def w_lvl1(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat, +i: Nat, +l: Nat, +j: Nat,
    +ne: {Nat.is_eq(L, l) == False{} : Bool},
    +hL: {Nat.is_le(L, d) == True{} : Bool},
    +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool},
    +hl: {Nat.is_le(l, d) == True{} : Bool},
    +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, l))) == True{} : Bool},
    +ok: ok_at(NS, d, l, j, n, XL),
    +b: Bool, +eb: {Nat.is_eq(hp(d, L, i), hp(d, l, j)) == b : Bool})
    -> ok_at(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, l, j, n, XL):
  match b:
    case False{}: ok_other(NS, d, l, j, n, XL, hp(d, L, i), mv(64n, L, i, n, XL), eb, ok)
    case True{}:
      Empty.absurd(ok_at(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, l, j, n, XL),
        MD.true_false(Equal.trans(Bool, True{}, Nat.is_eq(L, l), False{},
          Equal.sym(Bool, Nat.is_eq(L, l), True{}, is_eq_of_eq(L, l, sub_inj(d, L, l, hL, hl,
            hp_level(Nat.sub(d, L), Nat.sub(d, l), i, j, hi, hj, F.nat__eq_from_is_eq(hp(d, L, i), hp(d, l, j), eb))))), ne)))

# ---- one level's loop ------------------------------------------------------------------

# The runtime's loop over a level: node (L, i)'s value written at its position,
# for i = i0 .. i0 + q - 1 (the leaves are level 0).
def mlevel(q: Nat, +i: Nat, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat, +NS: List<&2, D.Digest>) -> List<&2, D.Digest>:
  match q:
    case 0n: NS
    case 1n+r: mlevel(r, 1n+i, d, n, XL, L, F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)))

def upd_len(+NS: List<&2, D.Digest>, +d: Nat, +k: Nat, +v: D.Digest, +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat})
    -> {F.spec_common__length(D.Digest, F.spec_common__update(D.Digest, NS, k, v)) == O.pow2n(1n+d) : Nat}:
  Equal.trans(Nat, F.spec_common__length(D.Digest, F.spec_common__update(D.Digest, NS, k, v)), F.spec_common__length(D.Digest, NS), O.pow2n(1n+d),
    F.list__length_update(D.Digest, NS, k, v), len)

def step_lt1(+i: Nat, +r: Nat) -> {Nat.is_lt(i, Nat.add(i, 1n+r)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(i, 1n+r), 1n+Nat.add(i, r), MR.add_succ(i, r)) : {Nat.is_lt(i, _) == True{} : Bool}
  F.nat__le_lt_succ(i, Nat.add(i, r), Order.below_sum(i, r))

# i < i + (1 + r) <= bound gives i < bound, and i + 1 + r = (i + 1) + r.
def step_lt(+i: Nat, +r: Nat, +B: Nat, +h: {Nat.is_le(Nat.add(i, 1n+r), B) == True{} : Bool}) -> {Nat.is_lt(i, B) == True{} : Bool}:
  F.nat__lt_le_trans(i, Nat.add(i, 1n+r), B, step_lt1(i, r), h)

def step_le(+i: Nat, +r: Nat, +B: Nat, +h: {Nat.is_le(Nat.add(i, 1n+r), B) == True{} : Bool}) -> {Nat.is_le(Nat.add(1n+i, r), B) == True{} : Bool}:
  %MR.add_succ(i, r) : {Nat.is_le(_, B) == True{} : Bool}
  h

law lv_len:
  for +q: Nat
  for +i: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +NS: List<&2, D.Digest>
  for +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat}
  {F.spec_common__length(D.Digest, mlevel(q, i, d, n, XL, L, NS)) == O.pow2n(1n+d) : Nat}
def lv_len(q, i, d, n, XL, L, NS, len):
  match q:
    case 0n: len
    case 1n+ +r: lv_len(r, 1n+i, d, n, XL, L, F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), upd_len(NS, d, hp(d, L, i), mv(64n, L, i, n, XL), len))

def lt_add0(+k: Nat, +i: Nat, +h: {Nat.is_lt(k, Nat.add(i, 0n)) == True{} : Bool}) -> {Nat.is_lt(k, i) == True{} : Bool}:
  %F.nat__add_zero(i) : {Nat.is_lt(k, _) == True{} : Bool}
  h

def lt_succ_add(+k: Nat, +i: Nat, +r: Nat, +h: {Nat.is_lt(k, Nat.add(i, 1n+r)) == True{} : Bool}) -> {Nat.is_lt(k, Nat.add(1n+i, r)) == True{} : Bool}:
  %MR.add_succ(i, r) : {Nat.is_lt(k, _) == True{} : Bool}
  h

# ---- halves --------------------------------------------------------------------------

law h2_mono:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(h2(a), h2(b)) == True{} : Bool}
def h2_mono(a, b, e):
  match a b:
    case 0n _: Order.zero_le(h2(b))
    case 1n 0n: Empty.absurd({Nat.is_le(0n, 0n) == True{} : Bool}, MD.false_true(e))
    case 1n 1n+ +q: Order.zero_le(h2(1n+q))
    case 2n+p 0n: Empty.absurd({Nat.is_le(h2(2n+p), 0n) == True{} : Bool}, MD.false_true(e))
    case 2n+p 1n: Empty.absurd({Nat.is_le(h2(2n+p), 0n) == True{} : Bool}, MD.false_true(e))
    case 2n+ +p 2n+ +q: h2_mono(p, q, e)

law h2_lt:
  for +x: Nat
  for +P: Nat
  for +h: {Nat.is_lt(x, Nat.double(P)) == True{} : Bool}
  {Nat.is_lt(h2(x), P) == True{} : Bool}
def h2_lt(x, P, h):
  match x P:
    case 0n 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, MD.false_true(h))
    case 0n 1n+Q: {==}
    case 1n 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, MD.false_true(h))
    case 1n 1n+Q: {==}
    case 2n+p 0n: Empty.absurd({Nat.is_lt(h2(2n+p), 0n) == True{} : Bool}, MD.false_true(h))
    case 2n+ +p 1n+ +Q: h2_lt(p, Q, h)

law rng_mono:
  for +L: Nat
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(rng(L, a), rng(L, b)) == True{} : Bool}
def rng_mono(L, a, b, e):
  match L:
    case 0n: e
    case 1n+ +k: h2_mono(rng(k, a), rng(k, b), rng_mono(k, a, b, e))

# d - k = 1 + (d - (1 + k)) for 1 + k <= d.
law sub_succ:
  for +d: Nat
  for +k: Nat
  for +h: {Nat.is_le(1n+k, d) == True{} : Bool}
  {Nat.sub(d, k) == 1n+Nat.sub(d, 1n+k) : Nat}
def sub_succ(d, k, h):
  match d k:
    case 0n 0n: Empty.absurd({Nat.sub(0n, 0n) == 1n+Nat.sub(0n, 1n) : Nat}, MD.false_true(h))
    case 0n 1n+q: Empty.absurd({Nat.sub(0n, 1n+q) == 1n+Nat.sub(0n, 2n+q) : Nat}, MD.false_true(h))
    case 1n+ +p 0n: Equal.sym(Nat, 1n+Nat.sub(p, 0n), 1n+p, Equal.cong(Nat, Nat, x => 1n+x, Nat.sub(p, 0n), p, F.nat__sub_zero(p)))
    case 1n+ +p 1n+ +q: sub_succ(p, q, h)

def rw_pow(+k: Nat, +d: Nat, +hL: {Nat.is_le(1n+k, d) == True{} : Bool}, +y: Nat, +ih: {Nat.is_lt(y, O.pow2n(Nat.sub(d, k))) == True{} : Bool})
    -> {Nat.is_lt(y, Nat.double(O.pow2n(Nat.sub(d, 1n+k)))) == True{} : Bool}:
  %sub_succ(d, k, hL) : {Nat.is_lt(y, O.pow2n(_)) == True{} : Bool}
  ih

law rng_lt:
  for +L: Nat
  for +x: Nat
  for +d: Nat
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +h: {Nat.is_lt(x, O.pow2n(d)) == True{} : Bool}
  {Nat.is_lt(rng(L, x), O.pow2n(Nat.sub(d, L))) == True{} : Bool}
def rng_lt(L, x, d, hL, h):
  match L:
    case 0n:
      %Equal.sym(Nat, Nat.sub(d, 0n), d, F.nat__sub_zero(d)) : {Nat.is_lt(x, O.pow2n(_)) == True{} : Bool}
      h
    case 1n+ +k:
      +ih = rng_lt(k, x, d, F.nat__le_trans(k, 1n+k, d, F.nat__le_succ(k), hL), h)
      h2_lt(rng(k, x), O.pow2n(Nat.sub(d, 1n+k)), rw_pow(k, d, hL, rng(k, x), ih))

# ---- the sweep ----------------------------------------------------------------------------

# The number of nodes the sweep writes at level L.
def qn(+L: Nat, +lo: Nat, +hi: Nat) -> Nat: 1n+Nat.sub(rng(L, hi), rng(L, lo))

# The runtime's level loops: levels l + 1 .. l + k, each over its dirty range.
def mlevels(k: Nat, +l: Nat, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +NS: List<&2, D.Digest>) -> List<&2, D.Digest>:
  match k:
    case 0n: NS
    case 1n+r: mlevels(r, 1n+l, d, n, XL, lo, hi, mlevel(qn(1n+l, lo, hi), rng(1n+l, lo), d, n, XL, 1n+l, NS))

# The whole sweep: the dirty leaves, then every level above them.
def msweep(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +NS: List<&2, D.Digest>) -> List<&2, D.Digest>:
  mlevels(d, 0n, d, n, XL, lo, hi, mlevel(qn(0n, lo, hi), lo, d, n, XL, 0n, NS))

# a + (1 + (b - a)) = 1 + b for a <= b.
def end_eq(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.add(a, 1n+Nat.sub(b, a)) == 1n+b : Nat}:
  %Equal.sym(Nat, Nat.add(a, 1n+Nat.sub(b, a)), 1n+Nat.add(a, Nat.sub(b, a)), MR.add_succ(a, Nat.sub(b, a))) : {_ == 1n+b : Nat}
  Equal.cong(Nat, Nat, x => 1n+x, Nat.add(a, Nat.sub(b, a)), b, F.nat__sub_add(b, a, h))

def end_le(+a: Nat, +b: Nat, +B: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}, +hb: {Nat.is_lt(b, B) == True{} : Bool})
    -> {Nat.is_le(Nat.add(a, 1n+Nat.sub(b, a)), B) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(a, 1n+Nat.sub(b, a)), 1n+b, end_eq(a, b, h)) : {Nat.is_le(_, B) == True{} : Bool}
  F.nat__lt_succ_le_succ(b, B, hb)

def lt_end(+k: Nat, +a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}, +h2: {Nat.is_lt(k, 1n+b) == True{} : Bool})
    -> {Nat.is_lt(k, Nat.add(a, 1n+Nat.sub(b, a))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(a, 1n+Nat.sub(b, a)), 1n+b, end_eq(a, b, h)) : {Nat.is_lt(k, _) == True{} : Bool}
  h2

def ne_below(+l2: Nat, +l: Nat, +h: {Nat.is_le(l2, l) == True{} : Bool}) -> {Nat.is_eq(1n+l, l2) == False{} : Bool}:
  neq_of_lt(1n+l, l2, F.nat__le_lt_succ(l2, l, h))

def step_le1(+l: Nat, +r: Nat) -> {Nat.is_le(1n+l, Nat.add(l, 1n+r)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(l, 1n+r), 1n+Nat.add(l, r), MR.add_succ(l, r)) : {Nat.is_le(1n+l, _) == True{} : Bool}
  Order.below_sum(l, r)

law le_zero_eq:
  for +l: Nat
  for +h: {Nat.is_le(l, 0n) == True{} : Bool}
  {l == 0n : Nat}
def le_zero_eq(l, h):
  match l:
    case 0n: {==}
    case 1n+p: Empty.absurd({1n+p == 0n : Nat}, MD.false_true(h))

def lt_d0(+d: Nat, +hi: Nat, +h: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool}) -> {Nat.is_lt(hi, O.pow2n(Nat.sub(d, 0n))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.sub(d, 0n), d, F.nat__sub_zero(d)) : {Nat.is_lt(hi, O.pow2n(_)) == True{} : Bool}
  h

# ---- the node array -----------------------------------------------------------------------

law pow2_eq:
  for +d: Nat
  {F.spec_common__pow2(d) == O.pow2n(d) : Nat}
def pow2_eq(d):
  match d:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, F.spec_common__pow2(p), O.pow2n(p), pow2_eq(p)) : {Nat.double(_) == Nat.double(O.pow2n(p)) : Nat}
      {==}

# The writes of one level's loop on the node array's tree.
def mlevel_t(q: Nat, +i: Nat, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat, +t: F.array__Tree<D.Digest>) -> F.array__Tree<D.Digest>:
  match q:
    case 0n: t
    case 1n+r: mlevel_t(r, 1n+i, d, n, XL, L, F.array__upd(D.Digest, 1n+d, t, hp(d, L, i), mv(64n, L, i, n, XL)))

def hp_lt2(+d: Nat, +L: Nat, +i: Nat, +hL: {Nat.is_le(L, d) == True{} : Bool}, +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool})
    -> {Nat.is_lt(hp(d, L, i), F.spec_common__pow2(1n+d)) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__pow2(1n+d), O.pow2n(1n+d), pow2_eq(1n+d)) : {Nat.is_lt(hp(d, L, i), _) == True{} : Bool}
  hp_lt(d, L, i, hL, hi)

law mlevel_t_perfect:
  for +q: Nat
  for +i: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +t: F.array__Tree<D.Digest>
  for +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool}
  {F.array__perfect(D.Digest, 1n+d, mlevel_t(q, i, d, n, XL, L, t)) == True{} : Bool}
def mlevel_t_perfect(q, i, d, n, XL, L, t, pf):
  match q:
    case 0n: pf
    case 1n+ +r:
      mlevel_t_perfect(r, 1n+i, d, n, XL, L, F.array__upd(D.Digest, 1n+d, t, hp(d, L, i), mv(64n, L, i, n, XL)),
        F.array__upd_perfect(D.Digest, 1n+d, t, hp(d, L, i), mv(64n, L, i, n, XL), pf))

law mlevel_t_slots:
  for +q: Nat
  for +i: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +t: F.array__Tree<D.Digest>
  for +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool}
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +hq: {Nat.is_le(Nat.add(i, q), O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  {F.array__slots(D.Digest, mlevel_t(q, i, d, n, XL, L, t)) == mlevel(q, i, d, n, XL, L, F.array__slots(D.Digest, t)) : List<&2, D.Digest>}
def mlevel_t_slots(q, i, d, n, XL, L, t, pf, hL, hq):
  match q:
    case 0n: {==}
    case 1n+ +r:
      +t1 = F.array__upd(D.Digest, 1n+d, t, hp(d, L, i), mv(64n, L, i, n, XL))
      %F.array__upd_slots(D.Digest, 1n+d, t, hp(d, L, i), mv(64n, L, i, n, XL), hp_lt2(d, L, i, hL, step_lt(i, r, O.pow2n(Nat.sub(d, L)), hq)), pf) :
        {F.array__slots(D.Digest, mlevel_t(r, 1n+i, d, n, XL, L, t1)) == mlevel(r, 1n+i, d, n, XL, L, _) : List<&2, D.Digest>}
      mlevel_t_slots(r, 1n+i, d, n, XL, L, t1, F.array__upd_perfect(D.Digest, 1n+d, t, hp(d, L, i), mv(64n, L, i, n, XL), pf), hL, step_le(i, r, O.pow2n(Nat.sub(d, L)), hq))

# ---- the invariant, as data ------------------------------------------------------------
#
# Every "for all nodes" fact is a finite product of node facts, built by
# recursion on a count. Products of equalities are data, so a lemma can use
# them any number of times (a function-typed hypothesis is linear in Bend and
# could be applied only once).

def okif(c: Bool, +NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +XL: List<&2, D.Digest>) -> Data:
  match c:
    case True{}: ok_at(NS, d, l, j, n, XL)
    case False{}: Unit

# Nodes j0 .. j0 + q - 1 of level l hold their values.
def LV(+NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +n: Nat, +XL: List<&2, D.Digest>, +j0: Nat, q: Nat) -> Data:
  match q:
    case 0n: Unit
    case 1n+r: Sigma<&2, &2, LV(NS, d, l, n, XL, j0, r), _ => ok_at(NS, d, l, Nat.add(j0, r), n, XL)>

# The clean nodes among j0 .. j0 + q - 1 of level l hold their values.
def CL(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +l: Nat, +j0: Nat, q: Nat) -> Data:
  match q:
    case 0n: Unit
    case 1n+r: Sigma<&2, &2, CL(NS, d, n, XL, lo, hi, l, j0, r), _ => okif(clean(l, Nat.add(j0, r), lo, hi), NS, d, l, Nat.add(j0, r), n, XL)>

# Level l complete.
def lvl_ok(+NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +n: Nat, +XL: List<&2, D.Digest>) -> Data:
  LV(NS, d, l, n, XL, 0n, O.pow2n(Nat.sub(d, l)))

# Level l's clean nodes hold their values.
def lvl_cl(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +l: Nat) -> Data:
  CL(NS, d, n, XL, lo, hi, l, 0n, O.pow2n(Nat.sub(d, l)))

# Levels 0 .. k - 1 complete.
def AU(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, k: Nat) -> Data:
  match k:
    case 0n: Unit
    case 1n+r: Sigma<&2, &2, AU(NS, d, n, XL, r), _ => lvl_ok(NS, d, r, n, XL)>

# The clean nodes of levels 0 .. k - 1 hold their values.
def CI(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, k: Nat) -> Data:
  match k:
    case 0n: Unit
    case 1n+r: Sigma<&2, &2, CI(NS, d, n, XL, lo, hi, r), _ => lvl_cl(NS, d, n, XL, lo, hi, r)>

# The cache invariant on the node slots NS: every clean node holds its value.
def cinv(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat) -> Data:
  CI(NS, d, n, XL, lo, hi, 1n+d)

# Every level up to L complete.
def all_upto(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat) -> Data:
  AU(NS, d, n, XL, 1n+L)

# ---- reading the products -------------------------------------------------------------

# j < 1 + x and not j < x: j = x.
def last_eq(+j: Nat, +x: Nat, +h2: {Nat.is_lt(j, 1n+x) == True{} : Bool}, +c: {Nat.is_lt(j, x) == False{} : Bool}) -> {j == x : Nat}:
  F.nat__le_antisym(j, x, F.nat__lt_succ_le(j, x, h2), F.nat__not_lt_le(j, x, c))

def lt_zero_absurd(+l: Nat, +h: {Nat.is_lt(l, 0n) == True{} : Bool}) -> Empty:
  MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(l, 0n), True{}, Equal.sym(Bool, Nat.is_lt(l, 0n), False{}, F.nat__not_lt_zero(l)), h))

def lv_pick(+r: Nat, +NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +n: Nat, +XL: List<&2, D.Digest>, +j0: Nat, +j: Nat,
    +h2: {Nat.is_lt(j, Nat.add(j0, 1n+r)) == True{} : Bool},
    ih: {Nat.is_lt(j, Nat.add(j0, r)) == True{} : Bool} -> ok_at(NS, d, l, j, n, XL),
    +last: ok_at(NS, d, l, Nat.add(j0, r), n, XL),
    +c: Bool, +ec: {Nat.is_lt(j, Nat.add(j0, r)) == c : Bool})
    -> ok_at(NS, d, l, j, n, XL):
  match c:
    case True{}: ih(ec)
    case False{}:
      %Equal.sym(Nat, j, Nat.add(j0, r), last_eq(j, Nat.add(j0, r), lt_succ_add(j, j0, r, h2), ec)) : ok_at(NS, d, l, _, n, XL)
      last

# Node j of a range product.
law lv_get:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +l: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +j0: Nat
  for +lv: LV(NS, d, l, n, XL, j0, q)
  for +j: Nat
  for +h1: {Nat.is_le(j0, j) == True{} : Bool}
  for +h2: {Nat.is_lt(j, Nat.add(j0, q)) == True{} : Bool}
  ok_at(NS, d, l, j, n, XL)
def lv_get(q, NS, d, l, n, XL, j0, lv, j, h1, h2):
  match q:
    case 0n: Empty.absurd(ok_at(NS, d, l, j, n, XL), Order.le_lt_conflict(j0, j, h1, lt_add0(j, j0, h2)))
    case 1n+ +r:
      (+lv0, +last) = lv
      lv_pick(r, NS, d, l, n, XL, j0, j, h2, e => lv_get(r, NS, d, l, n, XL, j0, lv0, j, h1, e), last, Nat.is_lt(j, Nat.add(j0, r)), {==})

def oi_get(+c: Bool, +hc: {c == True{} : Bool}, +NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +XL: List<&2, D.Digest>,
    +x: okif(c, NS, d, l, j, n, XL)) -> ok_at(NS, d, l, j, n, XL):
  match c:
    case True{}: x
    case False{}: Empty.absurd(ok_at(NS, d, l, j, n, XL), MD.false_true(hc))

def cl_rw(+l: Nat, +j: Nat, +k: Nat, +lo: Nat, +hi: Nat, +e: {j == k : Nat}, +hc: {clean(l, j, lo, hi) == True{} : Bool})
    -> {clean(l, k, lo, hi) == True{} : Bool}:
  %e : {clean(l, _, lo, hi) == True{} : Bool}
  hc

def cl_pick(+r: Nat, +NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +l: Nat, +j0: Nat, +j: Nat,
    +h2: {Nat.is_lt(j, Nat.add(j0, 1n+r)) == True{} : Bool},
    +hc: {clean(l, j, lo, hi) == True{} : Bool},
    ih: {Nat.is_lt(j, Nat.add(j0, r)) == True{} : Bool} -> ok_at(NS, d, l, j, n, XL),
    +last: okif(clean(l, Nat.add(j0, r), lo, hi), NS, d, l, Nat.add(j0, r), n, XL),
    +c: Bool, +ec: {Nat.is_lt(j, Nat.add(j0, r)) == c : Bool})
    -> ok_at(NS, d, l, j, n, XL):
  match c:
    case True{}: ih(ec)
    case False{}:
      +e = last_eq(j, Nat.add(j0, r), lt_succ_add(j, j0, r, h2), ec)
      %Equal.sym(Nat, j, Nat.add(j0, r), e) : ok_at(NS, d, l, _, n, XL)
      oi_get(clean(l, Nat.add(j0, r), lo, hi), cl_rw(l, j, Nat.add(j0, r), lo, hi, e, hc), NS, d, l, Nat.add(j0, r), n, XL, last)

# A clean node j of a range product.
law cl_get:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +l: Nat
  for +j0: Nat
  for +cl: CL(NS, d, n, XL, lo, hi, l, j0, q)
  for +j: Nat
  for +h1: {Nat.is_le(j0, j) == True{} : Bool}
  for +h2: {Nat.is_lt(j, Nat.add(j0, q)) == True{} : Bool}
  for +hc: {clean(l, j, lo, hi) == True{} : Bool}
  ok_at(NS, d, l, j, n, XL)
def cl_get(q, NS, d, n, XL, lo, hi, l, j0, cl, j, h1, h2, hc):
  match q:
    case 0n: Empty.absurd(ok_at(NS, d, l, j, n, XL), Order.le_lt_conflict(j0, j, h1, lt_add0(j, j0, h2)))
    case 1n+ +r:
      (+cl0, +last) = cl
      cl_pick(r, NS, d, n, XL, lo, hi, l, j0, j, h2, hc, e => cl_get(r, NS, d, n, XL, lo, hi, l, j0, cl0, j, h1, e, hc), last, Nat.is_lt(j, Nat.add(j0, r)), {==})

def au_pick(+r: Nat, +NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +l: Nat,
    +h2: {Nat.is_lt(l, 1n+r) == True{} : Bool},
    ih: {Nat.is_lt(l, r) == True{} : Bool} -> lvl_ok(NS, d, l, n, XL),
    +last: lvl_ok(NS, d, r, n, XL),
    +c: Bool, +ec: {Nat.is_lt(l, r) == c : Bool})
    -> lvl_ok(NS, d, l, n, XL):
  match c:
    case True{}: ih(ec)
    case False{}:
      %Equal.sym(Nat, l, r, last_eq(l, r, h2, ec)) : lvl_ok(NS, d, _, n, XL)
      last

# Level l of a level product.
law au_get:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +au: AU(NS, d, n, XL, k)
  for +l: Nat
  for +hl: {Nat.is_lt(l, k) == True{} : Bool}
  lvl_ok(NS, d, l, n, XL)
def au_get(k, NS, d, n, XL, au, l, hl):
  match k:
    case 0n: Empty.absurd(lvl_ok(NS, d, l, n, XL), lt_zero_absurd(l, hl))
    case 1n+ +r:
      (+au0, +last) = au
      au_pick(r, NS, d, n, XL, l, hl, e => au_get(r, NS, d, n, XL, au0, l, e), last, Nat.is_lt(l, r), {==})

def ci_pick(+r: Nat, +NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +l: Nat,
    +h2: {Nat.is_lt(l, 1n+r) == True{} : Bool},
    ih: {Nat.is_lt(l, r) == True{} : Bool} -> lvl_cl(NS, d, n, XL, lo, hi, l),
    +last: lvl_cl(NS, d, n, XL, lo, hi, r),
    +c: Bool, +ec: {Nat.is_lt(l, r) == c : Bool})
    -> lvl_cl(NS, d, n, XL, lo, hi, l):
  match c:
    case True{}: ih(ec)
    case False{}:
      %Equal.sym(Nat, l, r, last_eq(l, r, h2, ec)) : lvl_cl(NS, d, n, XL, lo, hi, _)
      last

law ci_lvl:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +ci: CI(NS, d, n, XL, lo, hi, k)
  for +l: Nat
  for +hl: {Nat.is_lt(l, k) == True{} : Bool}
  lvl_cl(NS, d, n, XL, lo, hi, l)
def ci_lvl(k, NS, d, n, XL, lo, hi, ci, l, hl):
  match k:
    case 0n: Empty.absurd(lvl_cl(NS, d, n, XL, lo, hi, l), lt_zero_absurd(l, hl))
    case 1n+ +r:
      (+ci0, +last) = ci
      ci_pick(r, NS, d, n, XL, lo, hi, l, hl, e => ci_lvl(r, NS, d, n, XL, lo, hi, ci0, l, e), last, Nat.is_lt(l, r), {==})

def lvl_get(+NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lv: lvl_ok(NS, d, l, n, XL),
    +j: Nat, +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, l))) == True{} : Bool}) -> ok_at(NS, d, l, j, n, XL):
  lv_get(O.pow2n(Nat.sub(d, l)), NS, d, l, n, XL, 0n, lv, j, Order.zero_le(j), hj)

# A clean node holds its value.
def ci_get(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +ci: cinv(NS, d, n, XL, lo, hi),
    +l: Nat, +j: Nat, +hl: {Nat.is_le(l, d) == True{} : Bool}, +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, l))) == True{} : Bool},
    +hc: {clean(l, j, lo, hi) == True{} : Bool}) -> ok_at(NS, d, l, j, n, XL):
  cl_get(O.pow2n(Nat.sub(d, l)), NS, d, n, XL, lo, hi, l, 0n, ci_lvl(1n+d, NS, d, n, XL, lo, hi, ci, l, F.nat__le_lt_succ(l, d, hl)), j, Order.zero_le(j), hj, hc)

# A node of a complete level l <= L.
def up_at(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat, +l: Nat, +j: Nat,
    +h1: {Nat.is_le(l, L) == True{} : Bool},
    +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, l))) == True{} : Bool},
    +up: all_upto(NS, d, n, XL, L)) -> ok_at(NS, d, l, j, n, XL):
  lvl_get(NS, d, l, n, XL, au_get(1n+L, NS, d, n, XL, up, l, F.nat__le_lt_succ(l, L, h1)), j, hj)

# ---- one write ------------------------------------------------------------------------

def pstep_lt0(+j0: Nat, +r: Nat) -> {Nat.is_lt(Nat.add(j0, r), Nat.add(j0, 1n+r)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(j0, 1n+r), 1n+Nat.add(j0, r), MR.add_succ(j0, r)) : {Nat.is_lt(Nat.add(j0, r), _) == True{} : Bool}
  F.nat__le_lt_succ(Nat.add(j0, r), Nat.add(j0, r), F.nat__le_refl(Nat.add(j0, r)))

def pstep_lt(+j0: Nat, +r: Nat, +B: Nat, +hq: {Nat.is_le(Nat.add(j0, 1n+r), B) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(j0, r), B) == True{} : Bool}:
  F.nat__lt_le_trans(Nat.add(j0, r), Nat.add(j0, 1n+r), B, pstep_lt0(j0, r), hq)

def pstep_le(+j0: Nat, +r: Nat, +B: Nat, +hq: {Nat.is_le(Nat.add(j0, 1n+r), B) == True{} : Bool})
    -> {Nat.is_le(Nat.add(j0, r), B) == True{} : Bool}:
  F.nat__lt_le(Nat.add(j0, r), B, pstep_lt(j0, r, B, hq))

# A write at level L keeps the nodes of another level l.
law lv_wo:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +i: Nat
  for +l: Nat
  for +j0: Nat
  for +ne: {Nat.is_eq(L, l) == False{} : Bool}
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +hi: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  for +hl: {Nat.is_le(l, d) == True{} : Bool}
  for +hq: {Nat.is_le(Nat.add(j0, q), O.pow2n(Nat.sub(d, l))) == True{} : Bool}
  for +lv: LV(NS, d, l, n, XL, j0, q)
  LV(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, l, n, XL, j0, q)
def lv_wo(q, NS, d, n, XL, L, i, l, j0, ne, hL, hi, hl, hq, lv):
  match q:
    case 0n: Unit{}
    case 1n+ +r:
      (+lv0, +last) = lv
      (lv_wo(r, NS, d, n, XL, L, i, l, j0, ne, hL, hi, hl, pstep_le(j0, r, O.pow2n(Nat.sub(d, l)), hq), lv0),
       w_lvl1(NS, d, n, XL, L, i, l, Nat.add(j0, r), ne, hL, hi, hl, pstep_lt(j0, r, O.pow2n(Nat.sub(d, l)), hq), last,
         Nat.is_eq(hp(d, L, i), hp(d, l, Nat.add(j0, r))), {==}))

# A write of a node's value keeps a clean node's value (okif form).
def okif_w(c: Bool, +NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat, +i: Nat, +l: Nat, +j: Nat,
    +hL: {Nat.is_le(L, d) == True{} : Bool},
    +hii: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat},
    +hl: {Nat.is_le(l, d) == True{} : Bool},
    +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, l))) == True{} : Bool},
    +x: okif(c, NS, d, l, j, n, XL))
    -> okif(c, F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, l, j, n, XL):
  match c:
    case True{}: w_cl1(NS, d, n, XL, L, i, l, j, hL, hii, len, hl, hj, x, Nat.is_eq(hp(d, L, i), hp(d, l, j)), {==})
    case False{}: Unit{}

law cl_w:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +L: Nat
  for +i: Nat
  for +l: Nat
  for +j0: Nat
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +hii: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  for +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat}
  for +hl: {Nat.is_le(l, d) == True{} : Bool}
  for +hq: {Nat.is_le(Nat.add(j0, q), O.pow2n(Nat.sub(d, l))) == True{} : Bool}
  for +cl: CL(NS, d, n, XL, lo, hi, l, j0, q)
  CL(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, n, XL, lo, hi, l, j0, q)
def cl_w(q, NS, d, n, XL, lo, hi, L, i, l, j0, hL, hii, len, hl, hq, cl):
  match q:
    case 0n: Unit{}
    case 1n+ +r:
      (+cl0, +last) = cl
      (cl_w(r, NS, d, n, XL, lo, hi, L, i, l, j0, hL, hii, len, hl, pstep_le(j0, r, O.pow2n(Nat.sub(d, l)), hq), cl0),
       okif_w(clean(l, Nat.add(j0, r), lo, hi), NS, d, n, XL, L, i, l, Nat.add(j0, r), hL, hii, len, hl, pstep_lt(j0, r, O.pow2n(Nat.sub(d, l)), hq), last))

# A write of a node's value keeps the invariant.
law ci_w:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +L: Nat
  for +i: Nat
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +hii: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  for +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat}
  for +hk: {Nat.is_le(k, 1n+d) == True{} : Bool}
  for +ci: CI(NS, d, n, XL, lo, hi, k)
  CI(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, n, XL, lo, hi, k)
def ci_w(k, NS, d, n, XL, lo, hi, L, i, hL, hii, len, hk, ci):
  match k:
    case 0n: Unit{}
    case 1n+ +r:
      (+ci0, +last) = ci
      (ci_w(r, NS, d, n, XL, lo, hi, L, i, hL, hii, len, F.nat__le_trans(r, d, 1n+d, hk, F.nat__le_succ(d)), ci0),
       cl_w(O.pow2n(Nat.sub(d, r)), NS, d, n, XL, lo, hi, L, i, r, 0n, hL, hii, len, hk, F.nat__le_refl(O.pow2n(Nat.sub(d, r))), last))

# A write at level L keeps the levels below k <= L.
law au_w:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +i: Nat
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +hii: {Nat.is_lt(i, O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  for +hkL: {Nat.is_le(k, L) == True{} : Bool}
  for +au: AU(NS, d, n, XL, k)
  AU(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, n, XL, k)
def au_w(k, NS, d, n, XL, L, i, hL, hii, hkL, au):
  match k:
    case 0n: Unit{}
    case 1n+ +r:
      (+au0, +last) = au
      +hrL = F.nat__lt_le_trans(r, 1n+r, L, F.nat__le_lt_succ(r, r, F.nat__le_refl(r)), hkL)
      (au_w(r, NS, d, n, XL, L, i, hL, hii, F.nat__lt_le(r, L, hrL), au0),
       lv_wo(O.pow2n(Nat.sub(d, r)), NS, d, n, XL, L, i, r, 0n, neq_of_lt(L, r, hrL), hL, hii,
         F.nat__le_trans(r, L, d, F.nat__lt_le(r, L, hrL), hL), F.nat__le_refl(O.pow2n(Nat.sub(d, r))), last))

# A write at node i of level L keeps the nodes a .. a + k - 1 < i of the same level.
law lv_below:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +a: Nat
  for +i: Nat
  for +hk: {Nat.is_le(Nat.add(a, k), i) == True{} : Bool}
  for +pre: LV(NS, d, L, n, XL, a, k)
  LV(F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), d, L, n, XL, a, k)
def lv_below(k, NS, d, n, XL, L, a, i, hk, pre):
  match k:
    case 0n: Unit{}
    case 1n+ +r:
      (+p0, +last) = pre
      (lv_below(r, NS, d, n, XL, L, a, i, pstep_le(a, r, i, hk), p0),
       ok_other(NS, d, L, Nat.add(a, r), n, XL, hp(d, L, i), mv(64n, L, i, n, XL),
         neq_of_lt(hp(d, L, i), hp(d, L, Nat.add(a, r)), F.nat__lt_add_left(Nat.add(a, r), i, O.pow2n(Nat.sub(d, L)), pstep_lt(a, r, i, hk))), last))

# ---- one level's loop ------------------------------------------------------------------

law lv_ci:
  for +q: Nat
  for +i: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +lo: Nat
  for +hi: Nat
  for +NS: List<&2, D.Digest>
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +hq: {Nat.is_le(Nat.add(i, q), O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  for +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat}
  for +ci: cinv(NS, d, n, XL, lo, hi)
  cinv(mlevel(q, i, d, n, XL, L, NS), d, n, XL, lo, hi)
def lv_ci(q, i, d, n, XL, L, lo, hi, NS, hL, hq, len, ci):
  match q:
    case 0n: ci
    case 1n+ +r:
      lv_ci(r, 1n+i, d, n, XL, L, lo, hi, F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), hL,
        step_le(i, r, O.pow2n(Nat.sub(d, L)), hq), upd_len(NS, d, hp(d, L, i), mv(64n, L, i, n, XL), len),
        ci_w(1n+d, NS, d, n, XL, lo, hi, L, i, hL, step_lt(i, r, O.pow2n(Nat.sub(d, L)), hq), len, F.nat__le_refl(1n+d), ci))

law lv_au:
  for +q: Nat
  for +i: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +hkL: {Nat.is_le(k, L) == True{} : Bool}
  for +hq: {Nat.is_le(Nat.add(i, q), O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  for +au: AU(NS, d, n, XL, k)
  AU(mlevel(q, i, d, n, XL, L, NS), d, n, XL, k)
def lv_au(q, i, d, n, XL, L, k, NS, hL, hkL, hq, au):
  match q:
    case 0n: au
    case 1n+ +r:
      lv_au(r, 1n+i, d, n, XL, L, k, F.spec_common__update(D.Digest, NS, hp(d, L, i), mv(64n, L, i, n, XL)), hL, hkL,
        step_le(i, r, O.pow2n(Nat.sub(d, L)), hq),
        au_w(k, NS, d, n, XL, L, i, hL, step_lt(i, r, O.pow2n(Nat.sub(d, L)), hq), hkL, au))

def pre_rw1(+a: Nat, +k: Nat, +r: Nat, +B: Nat, +hq: {Nat.is_le(Nat.add(Nat.add(a, k), 1n+r), B) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(a, 1n+k), r), B) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(a, 1n+k), 1n+Nat.add(a, k), MR.add_succ(a, k)) : {Nat.is_le(Nat.add(_, r), B) == True{} : Bool}
  step_le(Nat.add(a, k), r, B, hq)

# The written prefix: after the loop over q nodes from a + k, nodes a .. a + k + q - 1 hold their values.
law lv_pre:
  for +q: Nat
  for +a: Nat
  for +k: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +L: Nat
  for +NS: List<&2, D.Digest>
  for +hL: {Nat.is_le(L, d) == True{} : Bool}
  for +hq: {Nat.is_le(Nat.add(Nat.add(a, k), q), O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  for +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat}
  for +pre: LV(NS, d, L, n, XL, a, k)
  LV(mlevel(q, Nat.add(a, k), d, n, XL, L, NS), d, L, n, XL, a, Nat.add(k, q))
def lv_pre(q, a, k, d, n, XL, L, NS, hL, hq, len, pre):
  match q:
    case 0n:
      %Equal.sym(Nat, Nat.add(k, 0n), k, F.nat__add_zero(k)) : LV(NS, d, L, n, XL, a, _)
      pre
    case 1n+ +r:
      +i = Nat.add(a, k)
      +B = O.pow2n(Nat.sub(d, L))
      +v = mv(64n, L, i, n, XL)
      +NS1 = F.spec_common__update(D.Digest, NS, hp(d, L, i), v)
      +hi = step_lt(i, r, B, hq)
      %MR.add_succ(a, k) : LV(mlevel(r, _, d, n, XL, L, NS1), d, L, n, XL, a, Nat.add(k, 1n+r))
      %Equal.sym(Nat, Nat.add(k, 1n+r), 1n+Nat.add(k, r), MR.add_succ(k, r)) : LV(mlevel(r, Nat.add(a, 1n+k), d, n, XL, L, NS1), d, L, n, XL, a, _)
      lv_pre(r, a, 1n+k, d, n, XL, L, NS1, hL, pre_rw1(a, k, r, B, hq), upd_len(NS, d, hp(d, L, i), v, len),
        (lv_below(k, NS, d, n, XL, L, a, i, F.nat__le_refl(i), pre), ok_same(NS, d, L, i, n, XL, lt_len(NS, d, hp(d, L, i), len, hp_lt(d, L, i, hL, hi)))))

def hq_z(+a: Nat, +q: Nat, +B: Nat, +hq: {Nat.is_le(Nat.add(a, q), B) == True{} : Bool}) -> {Nat.is_le(Nat.add(Nat.add(a, 0n), q), B) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(a, 0n), a, F.nat__add_zero(a)) : {Nat.is_le(Nat.add(_, q), B) == True{} : Bool}
  hq

# The loop from a writes the prefix a .. a + q - 1.
def lv_pre0(+q: Nat, +a: Nat, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +L: Nat, +NS: List<&2, D.Digest>,
    +hL: {Nat.is_le(L, d) == True{} : Bool},
    +hq: {Nat.is_le(Nat.add(a, q), O.pow2n(Nat.sub(d, L))) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat})
    -> LV(mlevel(q, a, d, n, XL, L, NS), d, L, n, XL, a, q):
  %F.nat__add_zero(a) : LV(mlevel(q, _, d, n, XL, L, NS), d, L, n, XL, a, q)
  lv_pre(q, a, 0n, d, n, XL, L, NS, hL, hq_z(a, q, O.pow2n(Nat.sub(d, L)), hq), len, Unit{})

# ---- a level complete ----------------------------------------------------------------------

# Node j of level L: clean nodes by the invariant, dirty ones by the written range.
def ld1(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +L: Nat, +j: Nat,
    +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, L))) == True{} : Bool},
    +cl: lvl_cl(NS, d, n, XL, lo, hi, L),
    +pre: LV(NS, d, L, n, XL, rng(L, lo), qn(L, lo, hi)),
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool},
    +b1: Bool, +eb1: {Nat.is_lt(j, rng(L, lo)) == b1 : Bool},
    +b2: Bool, +eb2: {Nat.is_lt(rng(L, hi), j) == b2 : Bool})
    -> ok_at(NS, d, L, j, n, XL):
  match b1:
    case True{}:
      cl_get(O.pow2n(Nat.sub(d, L)), NS, d, n, XL, lo, hi, L, 0n, cl, j, Order.zero_le(j), hj,
        or_r(Nat.is_lt(hi, lo), Bool.or(Nat.is_lt(j, rng(L, lo)), Nat.is_lt(rng(L, hi), j)),
          or_l(Nat.is_lt(j, rng(L, lo)), Nat.is_lt(rng(L, hi), j), eb1)))
    case False{}:
      match b2:
        case True{}:
          cl_get(O.pow2n(Nat.sub(d, L)), NS, d, n, XL, lo, hi, L, 0n, cl, j, Order.zero_le(j), hj,
            or_r(Nat.is_lt(hi, lo), Bool.or(Nat.is_lt(j, rng(L, lo)), Nat.is_lt(rng(L, hi), j)),
              or_r(Nat.is_lt(j, rng(L, lo)), Nat.is_lt(rng(L, hi), j), eb2)))
        case False{}:
          lv_get(qn(L, lo, hi), NS, d, L, n, XL, rng(L, lo), pre, j, F.nat__not_lt_le(j, rng(L, lo), eb1),
            lt_end(j, rng(L, lo), rng(L, hi), rng_mono(L, lo, hi, hlh), F.nat__le_lt_succ(j, rng(L, hi), F.nat__not_lt_le(rng(L, hi), j, eb2))))

# Nodes 0 .. q - 1 of level L hold their values.
law lv_build:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +L: Nat
  for +hq: {Nat.is_le(q, O.pow2n(Nat.sub(d, L))) == True{} : Bool}
  for +cl: lvl_cl(NS, d, n, XL, lo, hi, L)
  for +pre: LV(NS, d, L, n, XL, rng(L, lo), qn(L, lo, hi))
  for +hlh: {Nat.is_le(lo, hi) == True{} : Bool}
  LV(NS, d, L, n, XL, 0n, q)
def lv_build(q, NS, d, n, XL, lo, hi, L, hq, cl, pre, hlh):
  match q:
    case 0n: Unit{}
    case 1n+ +r:
      +hr = F.nat__lt_le_trans(r, 1n+r, O.pow2n(Nat.sub(d, L)), F.nat__le_lt_succ(r, r, F.nat__le_refl(r)), hq)
      (lv_build(r, NS, d, n, XL, lo, hi, L, F.nat__lt_le(r, O.pow2n(Nat.sub(d, L)), hr), cl, pre, hlh),
       ld1(NS, d, n, XL, lo, hi, L, r, hr, cl, pre, hlh, Nat.is_lt(r, rng(L, lo)), {==}, Nat.is_lt(rng(L, hi), r), {==}))

# ---- the sweep ----------------------------------------------------------------------------

# One level of the sweep: levels 0 .. 1 + l complete afterwards.
def lvl_step(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +l: Nat,
    +hl: {Nat.is_le(1n+l, d) == True{} : Bool},
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool},
    +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat},
    +ci: cinv(NS, d, n, XL, lo, hi),
    +up: all_upto(NS, d, n, XL, l))
    -> all_upto(mlevel(qn(1n+l, lo, hi), rng(1n+l, lo), d, n, XL, 1n+l, NS), d, n, XL, 1n+l):
  +a = rng(1n+l, lo)
  +q = qn(1n+l, lo, hi)
  +B = O.pow2n(Nat.sub(d, 1n+l))
  +hq = end_le(a, rng(1n+l, hi), B, rng_mono(1n+l, lo, hi, hlh), rng_lt(1n+l, hi, d, hl, hhi))
  +NS1 = mlevel(q, a, d, n, XL, 1n+l, NS)
  +ci1 = lv_ci(q, a, d, n, XL, 1n+l, lo, hi, NS, hl, hq, len, ci)
  (lv_au(q, a, d, n, XL, 1n+l, 1n+l, NS, hl, F.nat__le_refl(1n+l), hq, up),
   lv_build(B, NS1, d, n, XL, lo, hi, 1n+l, F.nat__le_refl(B),
     ci_lvl(1n+d, NS1, d, n, XL, lo, hi, ci1, 1n+l, F.nat__le_lt_succ(1n+l, d, hl)),
     lv_pre0(q, a, d, n, XL, 1n+l, NS, hl, hq, len), hlh))

def lvl_step_len(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +l: Nat,
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat})
    -> {F.spec_common__length(D.Digest, mlevel(qn(1n+l, lo, hi), rng(1n+l, lo), d, n, XL, 1n+l, NS)) == O.pow2n(1n+d) : Nat}:
  lv_len(qn(1n+l, lo, hi), rng(1n+l, lo), d, n, XL, 1n+l, NS, len)

def lvl_step_ci(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +l: Nat,
    +hl: {Nat.is_le(1n+l, d) == True{} : Bool},
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool},
    +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat},
    +ci: cinv(NS, d, n, XL, lo, hi))
    -> cinv(mlevel(qn(1n+l, lo, hi), rng(1n+l, lo), d, n, XL, 1n+l, NS), d, n, XL, lo, hi):
  lv_ci(qn(1n+l, lo, hi), rng(1n+l, lo), d, n, XL, 1n+l, lo, hi, NS, hl,
    end_le(rng(1n+l, lo), rng(1n+l, hi), O.pow2n(Nat.sub(d, 1n+l)), rng_mono(1n+l, lo, hi, hlh), rng_lt(1n+l, hi, d, hl, hhi)), len, ci)

# The levels l + 1 .. l + k of the sweep: every level up to l + k complete.
law levels_ok:
  for +k: Nat
  for +l: Nat
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +NS: List<&2, D.Digest>
  for +hk: {Nat.is_le(Nat.add(l, k), d) == True{} : Bool}
  for +hlh: {Nat.is_le(lo, hi) == True{} : Bool}
  for +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool}
  for +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat}
  for +ci: cinv(NS, d, n, XL, lo, hi)
  for +up: all_upto(NS, d, n, XL, l)
  all_upto(mlevels(k, l, d, n, XL, lo, hi, NS), d, n, XL, Nat.add(l, k))
def levels_ok(k, l, d, n, XL, lo, hi, NS, hk, hlh, hhi, len, ci, up):
  match k:
    case 0n:
      %Equal.sym(Nat, Nat.add(l, 0n), l, F.nat__add_zero(l)) : all_upto(NS, d, n, XL, _)
      up
    case 1n+ +r:
      +hl = F.nat__le_trans(1n+l, Nat.add(l, 1n+r), d, step_le1(l, r), hk)
      %Equal.sym(Nat, Nat.add(l, 1n+r), 1n+Nat.add(l, r), MR.add_succ(l, r)) : all_upto(mlevels(1n+r, l, d, n, XL, lo, hi, NS), d, n, XL, _)
      levels_ok(r, 1n+l, d, n, XL, lo, hi, mlevel(qn(1n+l, lo, hi), rng(1n+l, lo), d, n, XL, 1n+l, NS),
        step_le(l, r, d, hk), hlh, hhi, lvl_step_len(NS, d, n, XL, lo, hi, l, len), lvl_step_ci(NS, d, n, XL, lo, hi, l, hl, hlh, hhi, len, ci),
        lvl_step(NS, d, n, XL, lo, hi, l, hl, hlh, hhi, len, ci, up))

def up_zero(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lv: lvl_ok(NS, d, 0n, n, XL))
    -> all_upto(NS, d, n, XL, 0n):
  (Unit{}, lv)

# The slots after the sweep's leaf loop.
def sw0(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +NS: List<&2, D.Digest>) -> List<&2, D.Digest>:
  mlevel(qn(0n, lo, hi), lo, d, n, XL, 0n, NS)

def sw0_hq(+d: Nat, +lo: Nat, +hi: Nat, +hlh: {Nat.is_le(lo, hi) == True{} : Bool}, +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(lo, qn(0n, lo, hi)), O.pow2n(Nat.sub(d, 0n))) == True{} : Bool}:
  end_le(lo, hi, O.pow2n(Nat.sub(d, 0n)), hlh, lt_d0(d, hi, hhi))

def sw0_ci(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +NS: List<&2, D.Digest>,
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool}, +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat}, +ci: cinv(NS, d, n, XL, lo, hi))
    -> cinv(sw0(d, n, XL, lo, hi, NS), d, n, XL, lo, hi):
  lv_ci(qn(0n, lo, hi), lo, d, n, XL, 0n, lo, hi, NS, Order.zero_le(d), sw0_hq(d, lo, hi, hlh, hhi), len, ci)

def sw0_up(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +NS: List<&2, D.Digest>,
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool}, +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat}, +ci: cinv(NS, d, n, XL, lo, hi))
    -> all_upto(sw0(d, n, XL, lo, hi, NS), d, n, XL, 0n):
  +NS0 = sw0(d, n, XL, lo, hi, NS)
  up_zero(NS0, d, n, XL,
    lv_build(O.pow2n(Nat.sub(d, 0n)), NS0, d, n, XL, lo, hi, 0n, F.nat__le_refl(O.pow2n(Nat.sub(d, 0n))),
      ci_lvl(1n+d, NS0, d, n, XL, lo, hi, sw0_ci(d, n, XL, lo, hi, NS, hlh, hhi, len, ci), 0n, F.nat__le_lt_succ(0n, d, Order.zero_le(d))),
      lv_pre0(qn(0n, lo, hi), lo, d, n, XL, 0n, NS, Order.zero_le(d), sw0_hq(d, lo, hi, hlh, hhi), len), hlh))

# After the sweep of a nonempty dirty range, every node holds its value.
def sweep_all(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +NS: List<&2, D.Digest>,
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool},
    +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, NS) == O.pow2n(1n+d) : Nat},
    +ci: cinv(NS, d, n, XL, lo, hi))
    -> all_upto(msweep(d, n, XL, lo, hi, NS), d, n, XL, d):
  levels_ok(d, 0n, d, n, XL, lo, hi, sw0(d, n, XL, lo, hi, NS), F.nat__le_refl(d), hlh, hhi,
    lv_len(qn(0n, lo, hi), lo, d, n, XL, 0n, NS, len),
    sw0_ci(d, n, XL, lo, hi, NS, hlh, hhi, len, ci),
    sw0_up(d, n, XL, lo, hi, NS, hlh, hhi, len, ci))

law sof_zero:
  for +l: Nat
  {sof(l, 0n) == 0n : Nat}
def sof_zero(l):
  match l:
    case 0n: {==}
    case 1n+ +k: sof_zero(k)

# With every node's value, the root node (position 1) is the tree of all leaves.
def root_full(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +up: all_upto(NS, d, n, XL, d))
    -> {F.spec_common__nth(D.Digest, NS, 1n) == Some{MD.rtree(d, Nat.is_lt(0n, n), 64n, XL, 0n)} : Maybe<&2, D.Digest>}:
  %F.nat__sub_self(d) :
    {F.spec_common__nth(D.Digest, NS, Nat.add(O.pow2n(_), 0n)) == Some{MD.rtree(d, Nat.is_lt(0n, n), 64n, XL, 0n)} : Maybe<&2, D.Digest>}
  %sof_zero(d) :
    {F.spec_common__nth(D.Digest, NS, Nat.add(O.pow2n(Nat.sub(d, d)), 0n)) == Some{MD.rtree(d, Nat.is_lt(_, n), 64n, XL, _)} : Maybe<&2, D.Digest>}
  up_at(NS, d, n, XL, d, d, 0n, F.nat__le_refl(d), root_lt(d), up)

# ---- complete trees and empty ranges -------------------------------------------------------

def okif_of(c: Bool, +NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +XL: List<&2, D.Digest>,
    +x: ok_at(NS, d, l, j, n, XL)) -> okif(c, NS, d, l, j, n, XL):
  match c:
    case True{}: x
    case False{}: Unit{}

law lv_cl:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +l: Nat
  for +j0: Nat
  for +lv: LV(NS, d, l, n, XL, j0, q)
  CL(NS, d, n, XL, lo, hi, l, j0, q)
def lv_cl(q, NS, d, n, XL, lo, hi, l, j0, lv):
  match q:
    case 0n: Unit{}
    case 1n+ +r:
      (+lv0, +last) = lv
      (lv_cl(r, NS, d, n, XL, lo, hi, l, j0, lv0), okif_of(clean(l, Nat.add(j0, r), lo, hi), NS, d, l, Nat.add(j0, r), n, XL, last))

law au_ci:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +au: AU(NS, d, n, XL, k)
  CI(NS, d, n, XL, lo, hi, k)
def au_ci(k, NS, d, n, XL, lo, hi, au):
  match k:
    case 0n: Unit{}
    case 1n+ +r:
      (+a0, +last) = au
      (au_ci(r, NS, d, n, XL, lo, hi, a0), lv_cl(O.pow2n(Nat.sub(d, r)), NS, d, n, XL, lo, hi, r, 0n, last))

# With every node's value, the invariant holds for any range (the empty one after a root).
def full_cinv(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +up: all_upto(NS, d, n, XL, d))
    -> cinv(NS, d, n, XL, lo, hi):
  au_ci(1n+d, NS, d, n, XL, lo, hi, up)

law cl_lv:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +l: Nat
  for +j0: Nat
  for +emp: {Nat.is_lt(hi, lo) == True{} : Bool}
  for +cl: CL(NS, d, n, XL, lo, hi, l, j0, q)
  LV(NS, d, l, n, XL, j0, q)
def cl_lv(q, NS, d, n, XL, lo, hi, l, j0, emp, cl):
  match q:
    case 0n: Unit{}
    case 1n+ +r:
      (+c0, +last) = cl
      (cl_lv(r, NS, d, n, XL, lo, hi, l, j0, emp, c0),
       oi_get(clean(l, Nat.add(j0, r), lo, hi), clean_emp(l, Nat.add(j0, r), lo, hi, emp), NS, d, l, Nat.add(j0, r), n, XL, last))

law ci_au:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +lo: Nat
  for +hi: Nat
  for +emp: {Nat.is_lt(hi, lo) == True{} : Bool}
  for +ci: CI(NS, d, n, XL, lo, hi, k)
  AU(NS, d, n, XL, k)
def ci_au(k, NS, d, n, XL, lo, hi, emp, ci):
  match k:
    case 0n: Unit{}
    case 1n+ +r:
      (+c0, +last) = ci
      (ci_au(r, NS, d, n, XL, lo, hi, emp, c0), cl_lv(O.pow2n(Nat.sub(d, r)), NS, d, n, XL, lo, hi, r, 0n, emp, last))

# An empty dirty range: every node is clean, so every node holds its value.
def clean_full(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat,
    +emp: {Nat.is_lt(hi, lo) == True{} : Bool}, +ci: cinv(NS, d, n, XL, lo, hi)) -> all_upto(NS, d, n, XL, d):
  ci_au(1n+d, NS, d, n, XL, lo, hi, emp, ci)
