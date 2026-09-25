import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./ctree.bend as CT
import ./cidx.bend as CX
import ./cloc.bend as LC
import ./cloop2.bend as CL2
import ./root_names.bend as RN

# A write into the cached validators list (l1099511627776_Validator_cset) keeps
# the cache invariant of ctree.bend: the element at i < n is replaced, so the
# element roots change at leaf i only, and the dirty range is widened to
# [min(lo, i), max(hi, i)], which covers i and contains the old range; the new
# element roots are dput(old roots, i, root of v) (xl_set), so by cloc.bend's
# cinv_move every node clean for the new range still holds its value.

# ---- the element roots after a write -------------------------------------------------------

law xat_upd:
  for +W: List<&2, T.Validator>
  for +I: Nat
  for +v: T.Validator
  for +m: Nat
  for +ne: {Nat.is_eq(I, m) == False{} : Bool}
  {CL2.xat(F.spec_common__update(T.Validator, W, I, v), m) == CL2.xat(W, m) : T.Validator}
def xat_upd(W, I, v, m, ne):
  match W I m:
    case Nil{} _ _: {==}
    case Con{+x, +t} 0n 0n: Empty.absurd({CL2.xat(F.spec_common__update(T.Validator, Con{x, t}, 0n, v), 0n) == CL2.xat(Con{x, t}, 0n) : T.Validator}, MD.true_false(ne))
    case Con{+x, +t} 0n 1n+ +q: {==}
    case Con{+x, +t} 1n+ +p 0n: {==}
    case Con{+x, +t} 1n+ +p 1n+ +q: xat_upd(t, p, v, q, ne)

law xat_upd_same:
  for +W: List<&2, T.Validator>
  for +I: Nat
  for +v: T.Validator
  for +hI: {Nat.is_lt(I, F.spec_common__length(T.Validator, W)) == True{} : Bool}
  {CL2.xat(F.spec_common__update(T.Validator, W, I, v), I) == v : T.Validator}
def xat_upd_same(W, I, v, hI):
  match W I:
    case Nil{} _: Empty.absurd({CL2.xat(F.spec_common__update(T.Validator, Nil{}, I, v), I) == v : T.Validator}, CT.lt_zero_absurd(I, hI))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p: xat_upd_same(t, p, v, hI)

# Past the updated index the element roots are unchanged.
law xl_upd_after:
  for +k: Nat
  for +W: List<&2, T.Validator>
  for +I: Nat
  for +v: T.Validator
  for +i0: Nat
  for +hl: Nat
  for +h: {Nat.is_lt(I, i0) == True{} : Bool}
  {CL2.xl(k, F.spec_common__update(T.Validator, W, I, v), i0, hl) == CL2.xl(k, W, i0, hl) : List<&2, D.Digest>}
def xl_upd_after(k, W, I, v, i0, hl, h):
  match k:
    case 0n: {==}
    case 1n+ +q:
      +W2 = F.spec_common__update(T.Validator, W, I, v)
      %Equal.sym(T.Validator, CL2.xat(W2, i0), CL2.xat(W, i0), xat_upd(W, I, v, i0, F.nat__is_eq_lt(I, i0, h))) :
        {RN.d_Validator(hl, _) <> CL2.xl(q, W2, 1n+i0, hl) == RN.d_Validator(hl, CL2.xat(W, i0)) <> CL2.xl(q, W, 1n+i0, hl) : List<&2, D.Digest>}
      %Equal.sym(List<&2, D.Digest>, CL2.xl(q, W2, 1n+i0, hl), CL2.xl(q, W, 1n+i0, hl),
          xl_upd_after(q, W, I, v, 1n+i0, hl, F.nat__lt_le_trans(I, i0, 1n+i0, h, F.nat__le_succ(i0)))) :
        {RN.d_Validator(hl, CL2.xat(W, i0)) <> _ == RN.d_Validator(hl, CL2.xat(W, i0)) <> CL2.xl(q, W, 1n+i0, hl) : List<&2, D.Digest>}
      {==}

law le_add_l:
  for +p: Nat
  for +i0: Nat
  {Nat.is_le(i0, Nat.add(p, i0)) == True{} : Bool}
def le_add_l(p, i0):
  match p:
    case 0n: F.nat__le_refl(i0)
    case 1n+ +q: F.nat__le_trans(i0, Nat.add(q, i0), 1n+Nat.add(q, i0), le_add_l(q, i0), F.nat__le_succ(Nat.add(q, i0)))

def hw_shift(+p: Nat, +i0: Nat, +B: Nat, +hW: {Nat.is_lt(Nat.add(1n+p, i0), B) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(p, 1n+i0), B) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(p, 1n+i0), 1n+Nat.add(p, i0), MR.add_succ(p, i0)) : {Nat.is_lt(_, B) == True{} : Bool}
  hW

# Writing element P + i0 of the items writes leaf P of the element roots from i0.
law xl_set:
  for +k: Nat
  for +W: List<&2, T.Validator>
  for +P: Nat
  for +i0: Nat
  for +v: T.Validator
  for +hl: Nat
  for +hP: {Nat.is_lt(P, k) == True{} : Bool}
  for +hW: {Nat.is_lt(Nat.add(P, i0), F.spec_common__length(T.Validator, W)) == True{} : Bool}
  {CL2.xl(k, F.spec_common__update(T.Validator, W, Nat.add(P, i0), v), i0, hl) == LC.dput(CL2.xl(k, W, i0, hl), P, RN.d_Validator(hl, v)) : List<&2, D.Digest>}
def xl_set(k, W, P, i0, v, hl, hP, hW):
  match k P:
    case 0n _:
      Empty.absurd({CL2.xl(0n, F.spec_common__update(T.Validator, W, Nat.add(P, i0), v), i0, hl) == LC.dput(CL2.xl(0n, W, i0, hl), P, RN.d_Validator(hl, v)) : List<&2, D.Digest>},
        CT.lt_zero_absurd(P, hP))
    case 1n+ +q 0n:
      +W2 = F.spec_common__update(T.Validator, W, i0, v)
      %Equal.sym(T.Validator, CL2.xat(W2, i0), v, xat_upd_same(W, i0, v, hW)) :
        {RN.d_Validator(hl, _) <> CL2.xl(q, W2, 1n+i0, hl) == RN.d_Validator(hl, v) <> CL2.xl(q, W, 1n+i0, hl) : List<&2, D.Digest>}
      %Equal.sym(List<&2, D.Digest>, CL2.xl(q, W2, 1n+i0, hl), CL2.xl(q, W, 1n+i0, hl),
          xl_upd_after(q, W, i0, v, 1n+i0, hl, F.nat__le_lt_succ(i0, i0, F.nat__le_refl(i0)))) :
        {RN.d_Validator(hl, v) <> _ == RN.d_Validator(hl, v) <> CL2.xl(q, W, 1n+i0, hl) : List<&2, D.Digest>}
      {==}
    case 1n+ +q 1n+ +p:
      +J = Nat.add(1n+p, i0)
      +W2 = F.spec_common__update(T.Validator, W, J, v)
      +ne = CT.neq_of_lt(J, i0, F.nat__le_lt_succ(i0, Nat.add(p, i0), le_add_l(p, i0)))
      %Equal.sym(T.Validator, CL2.xat(W2, i0), CL2.xat(W, i0), xat_upd(W, J, v, i0, ne)) :
        {RN.d_Validator(hl, _) <> CL2.xl(q, W2, 1n+i0, hl) == RN.d_Validator(hl, CL2.xat(W, i0)) <> LC.dput(CL2.xl(q, W, 1n+i0, hl), p, RN.d_Validator(hl, v)) : List<&2, D.Digest>}
      %MR.add_succ(p, i0) :
        {RN.d_Validator(hl, CL2.xat(W, i0)) <> CL2.xl(q, F.spec_common__update(T.Validator, W, _, v), 1n+i0, hl)
         == RN.d_Validator(hl, CL2.xat(W, i0)) <> LC.dput(CL2.xl(q, W, 1n+i0, hl), p, RN.d_Validator(hl, v)) : List<&2, D.Digest>}
      %Equal.sym(List<&2, D.Digest>, CL2.xl(q, F.spec_common__update(T.Validator, W, Nat.add(p, 1n+i0), v), 1n+i0, hl), LC.dput(CL2.xl(q, W, 1n+i0, hl), p, RN.d_Validator(hl, v)),
          xl_set(q, W, p, 1n+i0, v, hl, hP, hw_shift(p, i0, F.spec_common__length(T.Validator, W), hW))) :
        {RN.d_Validator(hl, CL2.xat(W, i0)) <> _ == RN.d_Validator(hl, CL2.xat(W, i0)) <> LC.dput(CL2.xl(q, W, 1n+i0, hl), p, RN.d_Validator(hl, v)) : List<&2, D.Digest>}
      {==}

def hw0(+I: Nat, +B: Nat, +hW: {Nat.is_lt(I, B) == True{} : Bool}) -> {Nat.is_lt(Nat.add(I, 0n), B) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(I, 0n), I, F.nat__add_zero(I)) : {Nat.is_lt(_, B) == True{} : Bool}
  hW

# The element roots after writing v at I < N.
def xl_set0(+N: Nat, +W: List<&2, T.Validator>, +I: Nat, +v: T.Validator,
    +hIN: {Nat.is_lt(I, N) == True{} : Bool},
    +hW: {Nat.is_lt(I, F.spec_common__length(T.Validator, W)) == True{} : Bool})
    -> {CL2.xl(N, F.spec_common__update(T.Validator, W, I, v), 0n, 64n) == LC.dput(CL2.xl(N, W, 0n, 64n), I, RN.d_Validator(64n, v)) : List<&2, D.Digest>}:
  %F.nat__add_zero(I) :
    {CL2.xl(N, F.spec_common__update(T.Validator, W, _, v), 0n, 64n) == LC.dput(CL2.xl(N, W, 0n, 64n), I, RN.d_Validator(64n, v)) : List<&2, D.Digest>}
  xl_set(N, W, I, 0n, v, 64n, hIN, hw0(I, F.spec_common__length(T.Validator, W), hW))

# The new low end min(lo, i): at most lo and at most i.
def lo1(+lo: U32, +i: U32, +c: Bool, +ec: {Nat.is_le(U32.to_nat(lo), U32.to_nat(i)) == c : Bool})
    -> {Nat.is_le(U32.to_nat(O.pick(c, lo, i)), U32.to_nat(lo)) == True{} : Bool}:
  match c:
    case True{}: F.nat__le_refl(U32.to_nat(lo))
    case False{}: F.nat__lt_le(U32.to_nat(i), U32.to_nat(lo), F.nat__not_le_lt(U32.to_nat(lo), U32.to_nat(i), ec))

def lo2(+lo: U32, +i: U32, +c: Bool, +ec: {Nat.is_le(U32.to_nat(lo), U32.to_nat(i)) == c : Bool})
    -> {Nat.is_le(U32.to_nat(O.pick(c, lo, i)), U32.to_nat(i)) == True{} : Bool}:
  match c:
    case True{}: ec
    case False{}: F.nat__le_refl(U32.to_nat(i))

# The new high end max(hi, i): at least hi and i, and below the capacity.
def hi1(+i: U32, +hi: U32, +c: Bool, +ec: {Nat.is_le(U32.to_nat(i), U32.to_nat(hi)) == c : Bool})
    -> {Nat.is_le(U32.to_nat(hi), U32.to_nat(O.pick(c, hi, i))) == True{} : Bool}:
  match c:
    case True{}: F.nat__le_refl(U32.to_nat(hi))
    case False{}: F.nat__lt_le(U32.to_nat(hi), U32.to_nat(i), F.nat__not_le_lt(U32.to_nat(i), U32.to_nat(hi), ec))

def hi2(+i: U32, +hi: U32, +c: Bool, +ec: {Nat.is_le(U32.to_nat(i), U32.to_nat(hi)) == c : Bool})
    -> {Nat.is_le(U32.to_nat(i), U32.to_nat(O.pick(c, hi, i))) == True{} : Bool}:
  match c:
    case True{}: ec
    case False{}: F.nat__le_refl(U32.to_nat(i))

def hi3(+i: U32, +hi: U32, +B: Nat, +c: Bool,
    +hb: {Nat.is_lt(U32.to_nat(hi), B) == True{} : Bool}, +ib: {Nat.is_lt(U32.to_nat(i), B) == True{} : Bool})
    -> {Nat.is_lt(U32.to_nat(O.pick(c, hi, i)), B) == True{} : Bool}:
  match c:
    case True{}: hb
    case False{}: ib

# ---- the write ------------------------------------------------------------------------------

def put_len_n(+XL: List<&2, D.Digest>, +XL2: List<&2, D.Digest>, +N: Nat, +es: {XL2 == XL : List<&2, D.Digest>}, +en: {MD.dlen(XL2) == N : Nat})
    -> {MD.dlen(XL) == N : Nat}:
  %es : {MD.dlen(_) == N : Nat}
  en

# The invariant for the written items and the widened range [min(lo, i), max(hi, i)].
def cset_cinv(+d: Nat, +t: F.array__Tree<D.Digest>, +N: Nat, +W: List<&2, T.Validator>, +i: U32, +v: T.Validator,
    +lo: U32, +hi: U32, +c1: Bool, +e1: {Nat.is_le(U32.to_nat(lo), U32.to_nat(i)) == c1 : Bool},
    +c2: Bool, +e2: {Nat.is_le(U32.to_nat(i), U32.to_nat(hi)) == c2 : Bool},
    +hb: {Nat.is_lt(U32.to_nat(hi), O.pow2n(d)) == True{} : Bool}, +ib: {Nat.is_lt(U32.to_nat(i), O.pow2n(d)) == True{} : Bool},
    +hIN: {Nat.is_lt(U32.to_nat(i), N) == True{} : Bool},
    +hW: {Nat.is_lt(U32.to_nat(i), F.spec_common__length(T.Validator, W)) == True{} : Bool},
    +ci: CT.cinv(F.array__slots(D.Digest, t), d, N, CL2.xl(N, W, 0n, 64n), U32.to_nat(lo), U32.to_nat(hi)))
    -> CT.cinv(F.array__slots(D.Digest, t), d, N, CL2.xl(N, F.spec_common__update(T.Validator, W, U32.to_nat(i), v), 0n, 64n),
         U32.to_nat(O.pick(c1, lo, i)), U32.to_nat(O.pick(c2, hi, i))):
  +I = U32.to_nat(i)
  +XL = CL2.xl(N, W, 0n, 64n)
  +x = RN.d_Validator(64n, v)
  +XL2 = CL2.xl(N, F.spec_common__update(T.Validator, W, I, v), 0n, 64n)
  +es = xl_set0(N, W, I, v, hIN, hW)
  %Equal.sym(List<&2, D.Digest>, XL2, LC.dput(XL, I, x), es) : CT.cinv(F.array__slots(D.Digest, t), d, N, _, U32.to_nat(O.pick(c1, lo, i)), U32.to_nat(O.pick(c2, hi, i)))
  LC.cinv_move(F.array__slots(D.Digest, t), d, N, N, XL, I, x,
    U32.to_nat(lo), U32.to_nat(hi), U32.to_nat(O.pick(c1, lo, i)), U32.to_nat(O.pick(c2, hi, i)),
    CL2.xlen(N, W, 0n, 64n), put_len_n(LC.dput(XL, I, x), XL2, N, es, CL2.xlen(N, F.spec_common__update(T.Validator, W, I, v), 0n, 64n)),
    lo1(lo, i, c1, e1), hi1(i, hi, c2, e2), lo2(lo, i, c1, e1), hi2(i, hi, c2, e2), ci)

def cset_hi(+d: Nat, +i: U32, +hi: U32, +c2: Bool,
    +hb: {Nat.is_lt(U32.to_nat(hi), O.pow2n(d)) == True{} : Bool}, +ib: {Nat.is_lt(U32.to_nat(i), O.pow2n(d)) == True{} : Bool})
    -> {Nat.is_lt(U32.to_nat(O.pick(c2, hi, i)), O.pow2n(d)) == True{} : Bool}:
  hi3(i, hi, O.pow2n(d), c2, hb, ib)
