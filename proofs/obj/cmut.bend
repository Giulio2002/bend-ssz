import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./ctree.bend as CT
import ./cidx.bend as CX
import ./cloc.bend as LC
import ./cloop2.bend as CL2
import ./cset.bend as CS
import ./root_names.bend as RN

# The cache invariant of ctree.bend after an append into the cached validators
# list (l1099511627776_Validator_capp inside the capacity), and for a fresh
# cache (cache_at: every leaf dirty). An append stores v at index n: the
# element roots gain leaf n (xl_app: dput at n, the list's length), and the
# range widens to cover n, so cloc.bend's cinv_move applies with n + 1
# elements. A fresh cache marks [0, 2^d - 1] dirty: no node is clean for it,
# so the invariant holds whatever the node array holds (fresh_cinv).

# ---- an append ------------------------------------------------------------------------------

law xl_app:
  for +k: Nat
  for +W: List<&2, FuluValidator_d.Validator>
  for +i0: Nat
  for +v: FuluValidator_d.Validator
  for +hl: Nat
  for +hW: {Nat.is_lt(Nat.add(k, i0), F.spec_common__length(FuluValidator_d.Validator, W)) == True{} : Bool}
  {CL2.xl(1n+k, F.spec_common__update(FuluValidator_d.Validator, W, Nat.add(k, i0), v), i0, hl) == LC.dput(CL2.xl(k, W, i0, hl), k, RN.d_Validator(hl, v)) : List<&2, D.Digest>}
def xl_app(k, W, i0, v, hl, hW):
  match k:
    case 0n:
      %Equal.sym(FuluValidator_d.Validator, CL2.xat(F.spec_common__update(FuluValidator_d.Validator, W, i0, v), i0), v, CS.xat_upd_same(W, i0, v, hW)) :
        {RN.d_Validator(hl, _) <> CL2.xl(0n, F.spec_common__update(FuluValidator_d.Validator, W, i0, v), 1n+i0, hl) == [RN.d_Validator(hl, v)] : List<&2, D.Digest>}
      {==}
    case 1n+ +q:
      +J = Nat.add(1n+q, i0)
      +W2 = F.spec_common__update(FuluValidator_d.Validator, W, J, v)
      +x = RN.d_Validator(hl, v)
      +ne = CT.neq_of_lt(J, i0, F.nat__le_lt_succ(i0, Nat.add(q, i0), CS.le_add_l(q, i0)))
      %Equal.sym(FuluValidator_d.Validator, CL2.xat(W2, i0), CL2.xat(W, i0), CS.xat_upd(W, J, v, i0, ne)) :
        {RN.d_Validator(hl, _) <> CL2.xl(1n+q, W2, 1n+i0, hl) == RN.d_Validator(hl, CL2.xat(W, i0)) <> LC.dput(CL2.xl(q, W, 1n+i0, hl), q, x) : List<&2, D.Digest>}
      %MR.add_succ(q, i0) :
        {RN.d_Validator(hl, CL2.xat(W, i0)) <> CL2.xl(1n+q, F.spec_common__update(FuluValidator_d.Validator, W, _, v), 1n+i0, hl)
         == RN.d_Validator(hl, CL2.xat(W, i0)) <> LC.dput(CL2.xl(q, W, 1n+i0, hl), q, x) : List<&2, D.Digest>}
      %Equal.sym(List<&2, D.Digest>, CL2.xl(1n+q, F.spec_common__update(FuluValidator_d.Validator, W, Nat.add(q, 1n+i0), v), 1n+i0, hl), LC.dput(CL2.xl(q, W, 1n+i0, hl), q, x),
          xl_app(q, W, 1n+i0, v, hl, CS.hw_shift(q, i0, F.spec_common__length(FuluValidator_d.Validator, W), hW))) :
        {RN.d_Validator(hl, CL2.xat(W, i0)) <> _ == RN.d_Validator(hl, CL2.xat(W, i0)) <> LC.dput(CL2.xl(q, W, 1n+i0, hl), q, x) : List<&2, D.Digest>}
      {==}

# The element roots after appending v to N elements.
def xl_app0(+N: Nat, +W: List<&2, FuluValidator_d.Validator>, +v: FuluValidator_d.Validator,
    +hW: {Nat.is_lt(N, F.spec_common__length(FuluValidator_d.Validator, W)) == True{} : Bool})
    -> {CL2.xl(1n+N, F.spec_common__update(FuluValidator_d.Validator, W, N, v), 0n, 64n) == LC.dput(CL2.xl(N, W, 0n, 64n), N, RN.d_Validator(64n, v)) : List<&2, D.Digest>}:
  %F.nat__add_zero(N) :
    {CL2.xl(1n+N, F.spec_common__update(FuluValidator_d.Validator, W, _, v), 0n, 64n) == LC.dput(CL2.xl(N, W, 0n, 64n), N, RN.d_Validator(64n, v)) : List<&2, D.Digest>}
  xl_app(N, W, 0n, v, 64n, CS.hw0(N, F.spec_common__length(FuluValidator_d.Validator, W), hW))

# The invariant for the appended items, n + 1 elements and the range [min(lo, n), max(hi, n)].
def capp_cinv(+d: Nat, +t: F.array__Tree<D.Digest>, +W: List<&2, FuluValidator_d.Validator>, +n: U32, +v: FuluValidator_d.Validator,
    +lo: U32, +hi: U32, +c1: Bool, +e1: {Nat.is_le(U32.to_nat(lo), U32.to_nat(n)) == c1 : Bool},
    +c2: Bool, +e2: {Nat.is_le(U32.to_nat(n), U32.to_nat(hi)) == c2 : Bool},
    +hb: {Nat.is_lt(U32.to_nat(hi), O.pow2n(d)) == True{} : Bool}, +nb: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == True{} : Bool},
    +hW: {Nat.is_lt(U32.to_nat(n), F.spec_common__length(FuluValidator_d.Validator, W)) == True{} : Bool},
    +ci: CT.cinv(F.array__slots(D.Digest, t), d, U32.to_nat(n), CL2.xl(U32.to_nat(n), W, 0n, 64n), U32.to_nat(lo), U32.to_nat(hi)))
    -> CT.cinv(F.array__slots(D.Digest, t), d, 1n+U32.to_nat(n), CL2.xl(1n+U32.to_nat(n), F.spec_common__update(FuluValidator_d.Validator, W, U32.to_nat(n), v), 0n, 64n),
         U32.to_nat(O.pick(c1, lo, n)), U32.to_nat(O.pick(c2, hi, n))):
  +N = U32.to_nat(n)
  +XL = CL2.xl(N, W, 0n, 64n)
  +x = RN.d_Validator(64n, v)
  +XL2 = CL2.xl(1n+N, F.spec_common__update(FuluValidator_d.Validator, W, N, v), 0n, 64n)
  +es = xl_app0(N, W, v, hW)
  %Equal.sym(List<&2, D.Digest>, XL2, LC.dput(XL, N, x), es) : CT.cinv(F.array__slots(D.Digest, t), d, 1n+N, _, U32.to_nat(O.pick(c1, lo, n)), U32.to_nat(O.pick(c2, hi, n)))
  LC.cinv_move(F.array__slots(D.Digest, t), d, N, 1n+N, XL, N, x,
    U32.to_nat(lo), U32.to_nat(hi), U32.to_nat(O.pick(c1, lo, n)), U32.to_nat(O.pick(c2, hi, n)),
    CL2.xlen(N, W, 0n, 64n), CS.put_len_n(LC.dput(XL, N, x), XL2, 1n+N, es, CL2.xlen(1n+N, F.spec_common__update(FuluValidator_d.Validator, W, N, v), 0n, 64n)),
    CS.lo1(lo, n, c1, e1), CS.hi1(n, hi, c2, e2), CS.lo2(lo, n, c1, e1), CS.hi2(n, hi, c2, e2), ci)

# ---- a fresh cache ----------------------------------------------------------------------------

law rng_zero:
  for +l: Nat
  {CT.rng(l, 0n) == 0n : Nat}
def rng_zero(l):
  match l:
    case 0n: {==}
    case 1n+ +k:
      %Equal.sym(Nat, CT.rng(k, 0n), 0n, rng_zero(k)) : {CT.h2(_) == 0n : Nat}
      {==}

# (2P - 1) / 2 = P - 1 for P >= 1.
def h2_pd(+P: Nat, +hP: {Nat.is_le(1n, P) == True{} : Bool}) -> {CT.h2(Nat.sub(Nat.double(P), 1n)) == Nat.sub(P, 1n) : Nat}:
  match P:
    case 0n: Empty.absurd({CT.h2(Nat.sub(Nat.double(0n), 1n)) == Nat.sub(0n, 1n) : Nat}, MD.false_true(hP))
    case 1n+ +q:
      %Equal.sym(Nat, Nat.sub(q, 0n), q, F.nat__sub_zero(q)) : {CT.h2(1n+Nat.double(q)) == _ : Nat}
      CX.h2_bit(True{}, q)

# The range of level l for the last leaf 2^d - 1: the last node 2^(d - l) - 1.
law rng_top:
  for +l: Nat
  for +d: Nat
  for +hl: {Nat.is_le(l, d) == True{} : Bool}
  {CT.rng(l, Nat.sub(O.pow2n(d), 1n)) == Nat.sub(O.pow2n(Nat.sub(d, l)), 1n) : Nat}
def rng_top(l, d, hl):
  match l:
    case 0n:
      %Equal.sym(Nat, Nat.sub(d, 0n), d, F.nat__sub_zero(d)) : {Nat.sub(O.pow2n(d), 1n) == Nat.sub(O.pow2n(_), 1n) : Nat}
      {==}
    case 1n+ +k:
      +hk = F.nat__le_trans(k, 1n+k, d, F.nat__le_succ(k), hl)
      %Equal.sym(Nat, CT.rng(k, Nat.sub(O.pow2n(d), 1n)), Nat.sub(O.pow2n(Nat.sub(d, k)), 1n), rng_top(k, d, hk)) :
        {CT.h2(_) == Nat.sub(O.pow2n(Nat.sub(d, 1n+k)), 1n) : Nat}
      %Equal.sym(Nat, Nat.sub(d, k), 1n+Nat.sub(d, 1n+k), CT.sub_succ(d, k, hl)) :
        {CT.h2(Nat.sub(O.pow2n(_), 1n)) == Nat.sub(O.pow2n(Nat.sub(d, 1n+k)), 1n) : Nat}
      h2_pd(O.pow2n(Nat.sub(d, 1n+k)), CT.pow2_pos(Nat.sub(d, 1n+k)))

def lt_pred_f(+j: Nat, +P: Nat, +hj: {Nat.is_lt(j, P) == True{} : Bool}) -> {Nat.is_lt(Nat.sub(P, 1n), j) == False{} : Bool}:
  match P:
    case 0n: Empty.absurd({Nat.is_lt(Nat.sub(0n, 1n), j) == False{} : Bool}, CT.lt_zero_absurd(j, hj))
    case 1n+ +q:
      %Equal.sym(Nat, Nat.sub(q, 0n), q, F.nat__sub_zero(q)) : {Nat.is_lt(_, j) == False{} : Bool}
      F.nat__le_not_lt(q, j, F.nat__lt_succ_le(j, q, hj))

# No node is clean for the full range [0, 2^d - 1].
def full_dirty(+l: Nat, +j: Nat, +d: Nat, +hl: {Nat.is_le(l, d) == True{} : Bool},
    +hj: {Nat.is_lt(j, O.pow2n(Nat.sub(d, l))) == True{} : Bool})
    -> {CT.clean(l, j, 0n, Nat.sub(O.pow2n(d), 1n)) == False{} : Bool}:
  +H = Nat.sub(O.pow2n(d), 1n)
  %Equal.sym(Bool, Nat.is_lt(H, 0n), False{}, F.nat__not_lt_zero(H)) :
    {Bool.or(_, Bool.or(Nat.is_lt(j, CT.rng(l, 0n)), Nat.is_lt(CT.rng(l, H), j))) == False{} : Bool}
  %Equal.sym(Nat, CT.rng(l, 0n), 0n, rng_zero(l)) :
    {Bool.or(Nat.is_lt(j, _), Nat.is_lt(CT.rng(l, H), j)) == False{} : Bool}
  %Equal.sym(Bool, Nat.is_lt(j, 0n), False{}, F.nat__not_lt_zero(j)) :
    {Bool.or(_, Nat.is_lt(CT.rng(l, H), j)) == False{} : Bool}
  %Equal.sym(Nat, CT.rng(l, H), Nat.sub(O.pow2n(Nat.sub(d, l)), 1n), rng_top(l, d, hl)) :
    {Nat.is_lt(_, j) == False{} : Bool}
  lt_pred_f(j, O.pow2n(Nat.sub(d, l)), hj)

def okif_f(c: Bool, +ec: {c == False{} : Bool}, +NS: List<&2, D.Digest>, +d: Nat, +l: Nat, +j: Nat, +n: Nat, +XL: List<&2, D.Digest>)
    -> CT.okif(c, NS, d, l, j, n, XL):
  match c:
    case True{}: Empty.absurd(CT.okif(True{}, NS, d, l, j, n, XL), MD.true_false(ec))
    case False{}: Unit{}

law cl_fresh:
  for +q: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +l: Nat
  for +hl: {Nat.is_le(l, d) == True{} : Bool}
  for +hq: {Nat.is_le(q, O.pow2n(Nat.sub(d, l))) == True{} : Bool}
  CT.CL(NS, d, n, XL, 0n, Nat.sub(O.pow2n(d), 1n), l, 0n, q)
def cl_fresh(q, NS, d, n, XL, l, hl, hq):
  match q:
    case 0n: Unit{}
    case 1n+ +r:
      +hr = F.nat__lt_le_trans(r, 1n+r, O.pow2n(Nat.sub(d, l)), F.nat__le_lt_succ(r, r, F.nat__le_refl(r)), hq)
      (cl_fresh(r, NS, d, n, XL, l, hl, F.nat__lt_le(r, O.pow2n(Nat.sub(d, l)), hr)),
       okif_f(CT.clean(l, r, 0n, Nat.sub(O.pow2n(d), 1n)), full_dirty(l, r, d, hl, hr), NS, d, l, r, n, XL))

law ci_fresh:
  for +k: Nat
  for +NS: List<&2, D.Digest>
  for +d: Nat
  for +n: Nat
  for +XL: List<&2, D.Digest>
  for +hk: {Nat.is_le(k, 1n+d) == True{} : Bool}
  CT.CI(NS, d, n, XL, 0n, Nat.sub(O.pow2n(d), 1n), k)
def ci_fresh(k, NS, d, n, XL, hk):
  match k:
    case 0n: Unit{}
    case 1n+ +r:
      (ci_fresh(r, NS, d, n, XL, F.nat__le_trans(r, d, 1n+d, hk, F.nat__le_succ(d))),
       cl_fresh(O.pow2n(Nat.sub(d, r)), NS, d, n, XL, r, hk, F.nat__le_refl(O.pow2n(Nat.sub(d, r)))))

# With every leaf dirty the invariant holds, whatever the node slots hold.
def fresh_cinv(+NS: List<&2, D.Digest>, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>)
    -> CT.cinv(NS, d, n, XL, 0n, Nat.sub(O.pow2n(d), 1n)):
  ci_fresh(1n+d, NS, d, n, XL, F.nat__le_refl(1n+d))
