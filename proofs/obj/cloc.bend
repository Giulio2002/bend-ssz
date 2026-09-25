import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./ctree.bend as CT
import ./cidx.bend as CX

# Locality of the cached Merkle tree's invariant (ctree.bend). Leaf i lies in
# the block of node (l, j) exactly when rng(l, i) = j. If two leaf lists XL, XL2
# agree at every leaf m other than i (the leaf's digest, and whether m is inside
# the list), every node whose block does not contain i has the same reference
# value over both (rtree_local). A node that is clean for a leaf range
# containing i is such a node (clean_out). So after a write or an append at
# leaf i, with the dirty range widened to cover i, every clean node still holds
# its value (cinv_move): this is how cset and capp keep the invariant. The
# change is dput(XL, i, x): replace leaf i, or append it when i is the length.

# ---- the block of a node ----------------------------------------------------------------------

# The first leaf of node (l, j) lies in its block.
law rng_sof:
  for +l: Nat
  for +j: Nat
  {CT.rng(l, CT.sof(l, j)) == j : Nat}
def rng_sof(l, j):
  match l:
    case 0n: {==}
    case 1n+ +k:
      %Equal.sym(Nat, CT.rng(k, CT.sof(k, Nat.double(j))), Nat.double(j), rng_sof(k, Nat.double(j))) : {CT.h2(_) == j : Nat}
      CX.h2_bit(False{}, j)

def h2_eq(+x: Nat, +j: Nat, +c: Bool, +ex: {x == Nat.add(F.spec_numeric__bit_value(c), Nat.double(j)) : Nat})
    -> {Nat.is_eq(CT.h2(x), j) == True{} : Bool}:
  %Equal.sym(Nat, x, Nat.add(F.spec_numeric__bit_value(c), Nat.double(j)), ex) : {Nat.is_eq(CT.h2(_), j) == True{} : Bool}
  %Equal.sym(Nat, CT.h2(Nat.add(F.spec_numeric__bit_value(c), Nat.double(j))), j, CX.h2_bit(c, j)) : {Nat.is_eq(_, j) == True{} : Bool}
  F.nat__is_eq_refl(j)

def no_true(+x: Bool, +ht: {x == True{} : Bool}, +hf: {x == False{} : Bool}) -> Empty:
  MD.true_false(Equal.trans(Bool, True{}, x, False{}, Equal.sym(Bool, x, True{}, ht), hf))

# Outside the parent's block, outside both children's blocks.
def half_ne(+x: Nat, +j: Nat, +c: Bool,
    +out: {Nat.is_eq(CT.h2(x), j) == False{} : Bool},
    +e: Bool, +ee: {Nat.is_eq(x, Nat.add(F.spec_numeric__bit_value(c), Nat.double(j))) == e : Bool})
    -> {Nat.is_eq(x, Nat.add(F.spec_numeric__bit_value(c), Nat.double(j))) == False{} : Bool}:
  match e:
    case False{}: ee
    case True{}:
      Empty.absurd({Nat.is_eq(x, Nat.add(F.spec_numeric__bit_value(c), Nat.double(j))) == False{} : Bool},
        no_true(Nat.is_eq(CT.h2(x), j), h2_eq(x, j, c, F.nat__eq_from_is_eq(x, Nat.add(F.spec_numeric__bit_value(c), Nat.double(j)), ee)), out))

def top_eq(+l: Nat, +j: Nat, +i: Nat, +ei: {i == CT.sof(l, j) : Nat}) -> {Nat.is_eq(CT.rng(l, i), j) == True{} : Bool}:
  %Equal.sym(Nat, i, CT.sof(l, j), ei) : {Nat.is_eq(CT.rng(l, _), j) == True{} : Bool}
  %Equal.sym(Nat, CT.rng(l, CT.sof(l, j)), j, rng_sof(l, j)) : {Nat.is_eq(_, j) == True{} : Bool}
  F.nat__is_eq_refl(j)

# Outside the block, not the block's first leaf.
def top_ne(+l: Nat, +j: Nat, +i: Nat,
    +out: {Nat.is_eq(CT.rng(l, i), j) == False{} : Bool},
    +e: Bool, +ee: {Nat.is_eq(i, CT.sof(l, j)) == e : Bool})
    -> {Nat.is_eq(i, CT.sof(l, j)) == False{} : Bool}:
  match e:
    case False{}: ee
    case True{}:
      Empty.absurd({Nat.is_eq(i, CT.sof(l, j)) == False{} : Bool},
        no_true(Nat.is_eq(CT.rng(l, i), j), top_eq(l, j, i, F.nat__eq_from_is_eq(i, CT.sof(l, j), ee)), out))

def mid_eq(+p: Nat, +j: Nat, +i: Nat, +ei: {i == CT.sof(p, 1n+Nat.double(j)) : Nat}) -> {Nat.is_eq(CT.rng(1n+p, i), j) == True{} : Bool}:
  %Equal.sym(Nat, i, CT.sof(p, 1n+Nat.double(j)), ei) : {Nat.is_eq(CT.h2(CT.rng(p, _)), j) == True{} : Bool}
  %Equal.sym(Nat, CT.rng(p, CT.sof(p, 1n+Nat.double(j))), 1n+Nat.double(j), rng_sof(p, 1n+Nat.double(j))) : {Nat.is_eq(CT.h2(_), j) == True{} : Bool}
  %Equal.sym(Nat, CT.h2(1n+Nat.double(j)), j, CX.h2_bit(True{}, j)) : {Nat.is_eq(_, j) == True{} : Bool}
  F.nat__is_eq_refl(j)

# Outside the block of (1 + p, j), not the first leaf of its right child.
def mid_ne(+p: Nat, +j: Nat, +i: Nat,
    +out: {Nat.is_eq(CT.rng(1n+p, i), j) == False{} : Bool},
    +e: Bool, +ee: {Nat.is_eq(i, CT.sof(p, 1n+Nat.double(j))) == e : Bool})
    -> {Nat.is_eq(i, CT.sof(p, 1n+Nat.double(j))) == False{} : Bool}:
  match e:
    case False{}: ee
    case True{}:
      Empty.absurd({Nat.is_eq(i, CT.sof(p, 1n+Nat.double(j))) == False{} : Bool},
        no_true(Nat.is_eq(CT.rng(1n+p, i), j), mid_eq(p, j, i, F.nat__eq_from_is_eq(i, CT.sof(p, 1n+Nat.double(j)), ee)), out))

# ---- a change at one leaf ------------------------------------------------------------------

# L with its element i replaced by x, or x appended when i is L's length.
def dput(L: List<&2, D.Digest>, +i: Nat, +x: D.Digest) -> List<&2, D.Digest>:
  match L i:
    case Nil{} 0n: [x]
    case Nil{} 1n+p: []
    case Con{h, t} 0n: x <> t
    case Con{h, t} 1n+p: h <> dput(t, p, x)

law ddrop_nil:
  for +q: Nat
  {MD.ddrop(q, []) == [] : List<&2, D.Digest>}
def ddrop_nil(q):
  match q:
    case 0n: {==}
    case 1n+ +p: {==}

# Away from i the leaf digest is unchanged.
law put_at:
  for +L: List<&2, D.Digest>
  for +i: Nat
  for +x: D.Digest
  for +m: Nat
  for +ne: {Nat.is_eq(i, m) == False{} : Bool}
  {MD.dhead(MD.ddrop(m, dput(L, i, x))) == MD.dhead(MD.ddrop(m, L)) : D.Digest}
def put_at(L, i, x, m, ne):
  match L i m:
    case Nil{} 0n 0n: Empty.absurd({MD.dhead(MD.ddrop(0n, dput(Nil{}, 0n, x))) == MD.dhead(MD.ddrop(0n, Nil{})) : D.Digest}, MD.true_false(ne))
    case Nil{} 0n 1n+ +q:
      %Equal.sym(List<&2, D.Digest>, MD.ddrop(q, []), [], ddrop_nil(q)) : {MD.dhead(_) == MD.dhead(MD.ddrop(1n+q, Nil{})) : D.Digest}
      {==}
    case Nil{} 1n+ +p _: {==}
    case Con{+h, +t} 0n 0n: Empty.absurd({MD.dhead(MD.ddrop(0n, dput(Con{h, t}, 0n, x))) == MD.dhead(MD.ddrop(0n, Con{h, t})) : D.Digest}, MD.true_false(ne))
    case Con{+h, +t} 0n 1n+ +q: {==}
    case Con{+h, +t} 1n+ +p 0n: {==}
    case Con{+h, +t} 1n+ +p 1n+ +q: put_at(t, p, x, q, ne)

# Away from i, being inside the list is unchanged.
law put_len:
  for +L: List<&2, D.Digest>
  for +i: Nat
  for +x: D.Digest
  for +m: Nat
  for +ne: {Nat.is_eq(i, m) == False{} : Bool}
  {Nat.is_lt(m, MD.dlen(dput(L, i, x))) == Nat.is_lt(m, MD.dlen(L)) : Bool}
def put_len(L, i, x, m, ne):
  match L i m:
    case Nil{} 0n 0n: Empty.absurd({Nat.is_lt(0n, MD.dlen(dput(Nil{}, 0n, x))) == Nat.is_lt(0n, MD.dlen(Nil{})) : Bool}, MD.true_false(ne))
    case Nil{} 0n 1n+ +q: F.nat__not_lt_zero(q)
    case Nil{} 1n+ +p _: {==}
    case Con{+h, +t} 0n 0n: Empty.absurd({Nat.is_lt(0n, MD.dlen(dput(Con{h, t}, 0n, x))) == Nat.is_lt(0n, MD.dlen(Con{h, t})) : Bool}, MD.true_false(ne))
    case Con{+h, +t} 0n 1n+ +q: {==}
    case Con{+h, +t} 1n+ +p 0n: {==}
    case Con{+h, +t} 1n+ +p 1n+ +q: put_len(t, p, x, q, ne)

# ---- locality of the reference tree ------------------------------------------------------------

# The reference value of a node whose block does not contain leaf i is the
# same before and after the change at i.
law rtree_local:
  for +l: Nat
  for +b: Bool
  for +hl: Nat
  for +XL: List<&2, D.Digest>
  for +i: Nat
  for +x: D.Digest
  for +j: Nat
  for +out: {Nat.is_eq(CT.rng(l, i), j) == False{} : Bool}
  {MD.rtree(l, b, hl, XL, CT.sof(l, j)) == MD.rtree(l, b, hl, dput(XL, i, x), CT.sof(l, j)) : D.Digest}
def rtree_local(l, b, hl, XL, i, x, j, out):
  match l b:
    case 0n False{}: {==}
    case 0n True{}: Equal.sym(D.Digest, MD.dhead(MD.ddrop(j, dput(XL, i, x))), MD.dhead(MD.ddrop(j, XL)), put_at(XL, i, x, j, out))
    case 1n+ +p False{}: {==}
    case 1n+ +p True{}:
      +XL2 = dput(XL, i, x)
      +sl = CT.sof(p, Nat.double(j))
      +sr = CT.sof(p, 1n+Nat.double(j))
      +f2 = Nat.is_lt(sr, MD.dlen(XL2))
      +ef = Equal.sym(Bool, f2, Nat.is_lt(sr, MD.dlen(XL)), put_len(XL, i, x, sr, mid_ne(p, j, i, out, Nat.is_eq(i, sr), {==})))
      +e1 = rtree_local(p, True{}, hl, XL, i, x, Nat.double(j),
        half_ne(CT.rng(p, i), j, False{}, out, Nat.is_eq(CT.rng(p, i), Nat.double(j)), {==}))
      +e2 = rtree_local(p, f2, hl, XL, i, x, 1n+Nat.double(j),
        half_ne(CT.rng(p, i), j, True{}, out, Nat.is_eq(CT.rng(p, i), 1n+Nat.double(j)), {==}))
      %CT.sof_right(p, j) :
        {D.node(hl, MD.rtree(p, True{}, hl, XL, sl), MD.rtree(p, Nat.is_lt(_, MD.dlen(XL)), hl, XL, _))
         == D.node(hl, MD.rtree(p, True{}, hl, XL2, sl), MD.rtree(p, Nat.is_lt(_, MD.dlen(XL2)), hl, XL2, _)) : D.Digest}
      %Equal.sym(Bool, Nat.is_lt(sr, MD.dlen(XL)), f2, ef) :
        {D.node(hl, MD.rtree(p, True{}, hl, XL, sl), MD.rtree(p, _, hl, XL, sr))
         == D.node(hl, MD.rtree(p, True{}, hl, XL2, sl), MD.rtree(p, f2, hl, XL2, sr)) : D.Digest}
      %Equal.sym(D.Digest, MD.rtree(p, True{}, hl, XL, sl), MD.rtree(p, True{}, hl, XL2, sl), e1) :
        {D.node(hl, _, MD.rtree(p, f2, hl, XL, sr)) == D.node(hl, MD.rtree(p, True{}, hl, XL2, sl), MD.rtree(p, f2, hl, XL2, sr)) : D.Digest}
      %Equal.sym(D.Digest, MD.rtree(p, f2, hl, XL, sr), MD.rtree(p, f2, hl, XL2, sr), e2) :
        {D.node(hl, MD.rtree(p, True{}, hl, XL2, sl), _) == D.node(hl, MD.rtree(p, True{}, hl, XL2, sl), MD.rtree(p, f2, hl, XL2, sr)) : D.Digest}
      {==}

# A node's value before and after the change (n, n2 the lists' lengths).
def mv_move(+l: Nat, +j: Nat, +n: Nat, +n2: Nat, +XL: List<&2, D.Digest>, +i: Nat, +x: D.Digest,
    +en: {MD.dlen(XL) == n : Nat}, +en2: {MD.dlen(dput(XL, i, x)) == n2 : Nat},
    +out: {Nat.is_eq(CT.rng(l, i), j) == False{} : Bool})
    -> {CT.mv(64n, l, j, n, XL) == CT.mv(64n, l, j, n2, dput(XL, i, x)) : D.Digest}:
  +XL2 = dput(XL, i, x)
  +s = CT.sof(l, j)
  +f2 = Nat.is_lt(s, MD.dlen(XL2))
  +ef = Equal.sym(Bool, f2, Nat.is_lt(s, MD.dlen(XL)), put_len(XL, i, x, s, top_ne(l, j, i, out, Nat.is_eq(i, s), {==})))
  %en : {MD.rtree(l, Nat.is_lt(s, _), 64n, XL, s) == MD.rtree(l, Nat.is_lt(s, n2), 64n, XL2, s) : D.Digest}
  %en2 : {MD.rtree(l, Nat.is_lt(s, MD.dlen(XL)), 64n, XL, s) == MD.rtree(l, Nat.is_lt(s, _), 64n, XL2, s) : D.Digest}
  %Equal.sym(Bool, Nat.is_lt(s, MD.dlen(XL)), f2, ef) : {MD.rtree(l, _, 64n, XL, s) == MD.rtree(l, f2, 64n, XL2, s) : D.Digest}
  rtree_local(l, f2, 64n, XL, i, x, j, out)

# ---- clean nodes are outside a leaf of the range ------------------------------------------------

def clean_out(+l: Nat, +j: Nat, +lo: Nat, +hi: Nat, +i: Nat,
    +hli: {Nat.is_le(lo, i) == True{} : Bool}, +hih: {Nat.is_le(i, hi) == True{} : Bool},
    +c1: Bool, +e1: {Nat.is_lt(hi, lo) == c1 : Bool},
    +c2: Bool, +e2: {Nat.is_lt(j, CT.rng(l, lo)) == c2 : Bool},
    +hc: {Bool.or(c1, Bool.or(c2, Nat.is_lt(CT.rng(l, hi), j))) == True{} : Bool})
    -> {Nat.is_eq(CT.rng(l, i), j) == False{} : Bool}:
  match c1:
    case True{}:
      Empty.absurd({Nat.is_eq(CT.rng(l, i), j) == False{} : Bool},
        no_true(Nat.is_lt(hi, lo), e1, F.nat__le_not_lt(hi, lo, F.nat__le_trans(lo, i, hi, hli, hih))))
    case False{}:
      match c2:
        case True{}:
          CT.neq_of_lt(CT.rng(l, i), j, F.nat__lt_le_trans(j, CT.rng(l, lo), CT.rng(l, i), e2, CT.rng_mono(l, lo, i, hli)))
        case False{}:
          F.nat__is_eq_lt(CT.rng(l, i), j, F.nat__le_lt_trans(CT.rng(l, i), CT.rng(l, hi), j, CT.rng_mono(l, i, hi, hih), hc))

# A node clean for [Lo2, Hi2] with Lo2 <= Lo, Hi <= Hi2 is clean for [Lo, Hi].
def rsub(+l: Nat, +j: Nat, +Lo: Nat, +Hi: Nat, +Lo2: Nat, +Hi2: Nat,
    +h1: {Nat.is_le(Lo2, Lo) == True{} : Bool}, +h2: {Nat.is_le(Hi, Hi2) == True{} : Bool},
    +c0: Bool, +e0: {Nat.is_lt(Hi, Lo) == c0 : Bool},
    +c1: Bool, +e1: {Nat.is_lt(Hi2, Lo2) == c1 : Bool},
    +c2: Bool, +e2: {Nat.is_lt(j, CT.rng(l, Lo2)) == c2 : Bool},
    +hc: {Bool.or(c1, Bool.or(c2, Nat.is_lt(CT.rng(l, Hi2), j))) == True{} : Bool})
    -> {CT.clean(l, j, Lo, Hi) == True{} : Bool}:
  match c0:
    case True{}: CT.or_l(Nat.is_lt(Hi, Lo), Bool.or(Nat.is_lt(j, CT.rng(l, Lo)), Nat.is_lt(CT.rng(l, Hi), j)), e0)
    case False{}:
      match c1:
        case True{}:
          Empty.absurd({CT.clean(l, j, Lo, Hi) == True{} : Bool},
            no_true(Nat.is_lt(Hi2, Lo2), e1, F.nat__le_not_lt(Hi2, Lo2,
              F.nat__le_trans(Lo2, Lo, Hi2, h1, F.nat__le_trans(Lo, Hi, Hi2, F.nat__not_lt_le(Hi, Lo, e0), h2)))))
        case False{}:
          match c2:
            case True{}:
              CT.or_r(Nat.is_lt(Hi, Lo), Bool.or(Nat.is_lt(j, CT.rng(l, Lo)), Nat.is_lt(CT.rng(l, Hi), j)),
                CT.or_l(Nat.is_lt(j, CT.rng(l, Lo)), Nat.is_lt(CT.rng(l, Hi), j),
                  F.nat__lt_le_trans(j, CT.rng(l, Lo2), CT.rng(l, Lo), e2, CT.rng_mono(l, Lo2, Lo, h1))))
            case False{}:
              CT.or_r(Nat.is_lt(Hi, Lo), Bool.or(Nat.is_lt(j, CT.rng(l, Lo)), Nat.is_lt(CT.rng(l, Hi), j)),
                CT.or_r(Nat.is_lt(j, CT.rng(l, Lo)), Nat.is_lt(CT.rng(l, Hi), j),
                  F.nat__le_lt_trans(CT.rng(l, Hi), CT.rng(l, Hi2), j, CT.rng_mono(l, Hi, Hi2, h2), hc)))

def ok_move(+NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +n2: Nat, +XL: List<&2, D.Digest>, +XL2: List<&2, D.Digest>,
    +e: {CT.mv(64n, l, j, n, XL) == CT.mv(64n, l, j, n2, XL2) : D.Digest},
    +ok: CT.ok_at(NS, d, l, j, n, XL)) -> CT.ok_at(NS, d, l, j, n2, XL2):
  %e : {F.spec_common__nth(D.Digest, NS, CT.hp(d, l, j)) == Some{_} : Maybe<&2, D.Digest>}
  ok

# ---- the invariant after a change at leaf i ----------------------------------------------------

# One node: clean for the new range means clean for the old range and outside leaf i.
def okif_move(c2: Bool, +NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +n2: Nat, +XL: List<&2, D.Digest>, +i: Nat, +x: D.Digest,
    +lo: Nat, +hi: Nat, +lo2: Nat, +hi2: Nat,
    +en: {MD.dlen(XL) == n : Nat}, +en2: {MD.dlen(dput(XL, i, x)) == n2 : Nat},
    +h1: {Nat.is_le(lo2, lo) == True{} : Bool}, +h2: {Nat.is_le(hi, hi2) == True{} : Bool},
    +hli: {Nat.is_le(lo2, i) == True{} : Bool}, +hih: {Nat.is_le(i, hi2) == True{} : Bool},
    +ec2: {CT.clean(l, j, lo2, hi2) == c2 : Bool},
    +old: CT.okif(CT.clean(l, j, lo, hi), NS, d, l, j, n, XL))
    -> CT.okif(c2, NS, d, l, j, n2, dput(XL, i, x)):
  match c2:
    case True{}:
      ok_move(NS, d, l, j, n, n2, XL, dput(XL, i, x),
        mv_move(l, j, n, n2, XL, i, x, en, en2,
          clean_out(l, j, lo2, hi2, i, hli, hih, Nat.is_lt(hi2, lo2), {==}, Nat.is_lt(j, CT.rng(l, lo2)), {==}, ec2)),
        CT.oi_get(CT.clean(l, j, lo, hi),
          rsub(l, j, lo, hi, lo2, hi2, h1, h2, Nat.is_lt(hi, lo), {==}, Nat.is_lt(hi2, lo2), {==}, Nat.is_lt(j, CT.rng(l, lo2)), {==}, ec2),
          NS, d, l, j, n, XL, old))
    case False{}: Unit{}

law cl_move:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +n2: Nat
  for +XL: List<&2, D.Digest>
  for +i: Nat
  for +x: D.Digest
  for +lo: Nat
  for +hi: Nat
  for +lo2: Nat
  for +hi2: Nat
  for +l: Nat
  for +j0: Nat
  for +en: {MD.dlen(XL) == n : Nat}
  for +en2: {MD.dlen(dput(XL, i, x)) == n2 : Nat}
  for +h1: {Nat.is_le(lo2, lo) == True{} : Bool}
  for +h2: {Nat.is_le(hi, hi2) == True{} : Bool}
  for +hli: {Nat.is_le(lo2, i) == True{} : Bool}
  for +hih: {Nat.is_le(i, hi2) == True{} : Bool}
  for +cl: CT.CL(NS, d, n, XL, lo, hi, l, j0, q)
  CT.CL(NS, d, n2, dput(XL, i, x), lo2, hi2, l, j0, q)
def cl_move(q, NS, d, n, n2, XL, i, x, lo, hi, lo2, hi2, l, j0, en, en2, h1, h2, hli, hih, cl):
  match q:
    case 0n: Unit{}
    case 1n+ +r:
      (+c0, +last) = cl
      (cl_move(r, NS, d, n, n2, XL, i, x, lo, hi, lo2, hi2, l, j0, en, en2, h1, h2, hli, hih, c0),
       okif_move(CT.clean(l, Nat.add(j0, r), lo2, hi2), NS, d, l, Nat.add(j0, r), n, n2, XL, i, x, lo, hi, lo2, hi2, en, en2, h1, h2, hli, hih, {==}, last))

law ci_move:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +n2: Nat
  for +XL: List<&2, D.Digest>
  for +i: Nat
  for +x: D.Digest
  for +lo: Nat
  for +hi: Nat
  for +lo2: Nat
  for +hi2: Nat
  for +en: {MD.dlen(XL) == n : Nat}
  for +en2: {MD.dlen(dput(XL, i, x)) == n2 : Nat}
  for +h1: {Nat.is_le(lo2, lo) == True{} : Bool}
  for +h2: {Nat.is_le(hi, hi2) == True{} : Bool}
  for +hli: {Nat.is_le(lo2, i) == True{} : Bool}
  for +hih: {Nat.is_le(i, hi2) == True{} : Bool}
  for +ci: CT.CI(NS, d, n, XL, lo, hi, k)
  CT.CI(NS, d, n2, dput(XL, i, x), lo2, hi2, k)
def ci_move(k, NS, d, n, n2, XL, i, x, lo, hi, lo2, hi2, en, en2, h1, h2, hli, hih, ci):
  match k:
    case 0n: Unit{}
    case 1n+ +r:
      (+c0, +last) = ci
      (ci_move(r, NS, d, n, n2, XL, i, x, lo, hi, lo2, hi2, en, en2, h1, h2, hli, hih, c0),
       cl_move(O.pow2n(Nat.sub(d, r)), NS, d, n, n2, XL, i, x, lo, hi, lo2, hi2, r, 0n, en, en2, h1, h2, hli, hih, last))

# The invariant after the change at leaf i, with the range widened to cover i.
def cinv_move(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +n2: Nat, +XL: List<&2, D.Digest>, +i: Nat, +x: D.Digest,
    +lo: Nat, +hi: Nat, +lo2: Nat, +hi2: Nat,
    +en: {MD.dlen(XL) == n : Nat}, +en2: {MD.dlen(dput(XL, i, x)) == n2 : Nat},
    +h1: {Nat.is_le(lo2, lo) == True{} : Bool}, +h2: {Nat.is_le(hi, hi2) == True{} : Bool},
    +hli: {Nat.is_le(lo2, i) == True{} : Bool}, +hih: {Nat.is_le(i, hi2) == True{} : Bool},
    +ci: CT.cinv(NS, d, n, XL, lo, hi))
    -> CT.cinv(NS, d, n2, dput(XL, i, x), lo2, hi2):
  ci_move(1n+d, NS, d, n, n2, XL, i, x, lo, hi, lo2, hi2, en, en2, h1, h2, hli, hih, ci)
