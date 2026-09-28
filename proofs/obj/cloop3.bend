import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./digest_facts.bend as DF
import ./ctree.bend as CT
import ./cidx.bend as CX
import ./cloop2.bend as CL2

# The root of the cached Merkle tree of BeaconState.validators
# (l1099511627776_Validator_cached_root, hl = 64). For a cache whose items
# are the thawed tree ta and whose node array is the thawed tree t of depth
# 1 + d, and which satisfies ctree's invariant for its dirty range [lo, hi]
# (every clean node holds its value), the digest returned is
#
#   mix_len(64, rtree(40, 0 < n, 64, XL, 0), n),   XL = the n element roots,
#
# the length-mixed reference tree of limit depth 40, i.e. the digest of the
# uncached list root laws (xd_*: mix_len(hl, rtree(limit depth, ...), n)).
# The cache it returns has the dirty range [n, 0] (empty for n > 0) and every
# node holding its value, so the invariant holds again for the next root.

def XLof(+n: U32, +ta: F.array__Tree<FuluValidator_d.Validator>) -> List<&2, D.Digest>:
  CL2.xl(U32.to_nat(n), F.array__slots(FuluValidator_d.Validator, ta), 0n, 64n)

# ---- the sweep ----------------------------------------------------------------------------

def msweep_t(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>) -> F.array__Tree<D.Digest>:
  CL2.mlevels_t(d, 0n, d, n, XL, lo, hi, CT.mlevel_t(CT.qn(0n, lo, hi), lo, d, n, XL, 0n, t))

def hq0(+d: Nat, +lo: Nat, +hi: Nat, +hlh: {Nat.is_le(lo, hi) == True{} : Bool}, +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(lo, CT.qn(0n, lo, hi)), O.pow2n(Nat.sub(d, 0n))) == True{} : Bool}:
  CT.end_le(lo, hi, O.pow2n(Nat.sub(d, 0n)), hlh, CT.lt_d0(d, hi, hhi))

def es0(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>,
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool}, +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool})
    -> {F.array__slots(D.Digest, CT.mlevel_t(CT.qn(0n, lo, hi), lo, d, n, XL, 0n, t)) == CT.mlevel(CT.qn(0n, lo, hi), lo, d, n, XL, 0n, F.array__slots(D.Digest, t)) : List<&2, D.Digest>}:
  CT.mlevel_t_slots(CT.qn(0n, lo, hi), lo, d, n, XL, 0n, t, pf, Order.zero_le(d), hq0(d, lo, hi, hlh, hhi))

# The tree after the sweep has the model's slots.
def msweep_t_slots(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>,
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool}, +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool})
    -> {F.array__slots(D.Digest, msweep_t(d, n, XL, lo, hi, t)) == CT.msweep(d, n, XL, lo, hi, F.array__slots(D.Digest, t)) : List<&2, D.Digest>}:
  +q = CT.qn(0n, lo, hi)
  +t0 = CT.mlevel_t(q, lo, d, n, XL, 0n, t)
  %es0(d, n, XL, lo, hi, t, pf, hlh, hhi) :
    {F.array__slots(D.Digest, CL2.mlevels_t(d, 0n, d, n, XL, lo, hi, t0)) == CT.mlevels(d, 0n, d, n, XL, lo, hi, _) : List<&2, D.Digest>}
  CL2.mlevels_t_slots(d, 0n, d, n, XL, lo, hi, t0, CT.mlevel_t_perfect(q, lo, d, n, XL, 0n, t, pf), F.nat__le_refl(d), hlh, hhi)

def msweep_t_perfect(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>,
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool})
    -> {F.array__perfect(D.Digest, 1n+d, msweep_t(d, n, XL, lo, hi, t)) == True{} : Bool}:
  +q = CT.qn(0n, lo, hi)
  CL2.mlevels_t_perfect(d, 0n, d, n, XL, lo, hi, CT.mlevel_t(q, lo, d, n, XL, 0n, t), CT.mlevel_t_perfect(q, lo, d, n, XL, 0n, t, pf))

# After the sweep every node holds its value.
def msweep_t_full(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>,
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +hlh: {Nat.is_le(lo, hi) == True{} : Bool}, +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, F.array__slots(D.Digest, t)) == O.pow2n(1n+d) : Nat},
    +ci: CT.cinv(F.array__slots(D.Digest, t), d, n, XL, lo, hi))
    -> CT.all_upto(F.array__slots(D.Digest, msweep_t(d, n, XL, lo, hi, t)), d, n, XL, d):
  CL2.up_tr(F.array__slots(D.Digest, msweep_t(d, n, XL, lo, hi, t)), CT.msweep(d, n, XL, lo, hi, F.array__slots(D.Digest, t)),
    msweep_t_slots(d, n, XL, lo, hi, t, pf, hlh, hhi), d, n, XL, d,
    CT.sweep_all(d, n, XL, lo, hi, F.array__slots(D.Digest, t), hlh, hhi, len, ci))

def msweep_t_len(+d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>,
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool})
    -> {F.spec_common__length(D.Digest, F.array__slots(D.Digest, msweep_t(d, n, XL, lo, hi, t))) == O.pow2n(1n+d) : Nat}:
  Equal.trans(Nat, F.spec_common__length(D.Digest, F.array__slots(D.Digest, msweep_t(d, n, XL, lo, hi, t))), F.spec_common__pow2(1n+d), O.pow2n(1n+d),
    F.array__slots_length(D.Digest, 1n+d, msweep_t(d, n, XL, lo, hi, t), msweep_t_perfect(d, n, XL, lo, hi, t, pf)), CT.pow2_eq(1n+d))

# The runtime sweep of a nonempty dirty range [lo, hi] is msweep_t.
def csweep(+d: Nat, +dw: Nat, +ta: F.array__Tree<FuluValidator_d.Validator>, +t: F.array__Tree<D.Digest>, +lo: U32, +hi: U32, +n: U32, +seg: U32, -h: B.Buf,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool},
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +hlh: {Nat.is_le(U32.to_nat(lo), U32.to_nat(hi)) == True{} : Bool},
    +hhi: {Nat.is_lt(U32.to_nat(hi), O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, F.array__slots(D.Digest, t)) == O.pow2n(1n+d) : Nat},
    +ci: CT.cinv(F.array__slots(D.Digest, t), d, U32.to_nat(n), XLof(n, ta), U32.to_nat(lo), U32.to_nat(hi)))
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_sweep(64n, d, lo, hi, n, seg, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, t)})
        == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta),
             F.array__thaw(D.Digest, msweep_t(d, U32.to_nat(n), XLof(n, ta), U32.to_nat(lo), U32.to_nat(hi), t))}
        : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}:
  +N = U32.to_nat(n)
  +Lo = U32.to_nat(lo)
  +Hi = U32.to_nat(hi)
  +XL = XLof(n, ta)
  +q = CT.qn(0n, Lo, Hi)
  +t0 = CT.mlevel_t(q, Lo, d, N, XL, 0n, t)
  +NS = F.array__slots(D.Digest, t)
  +NS0 = CT.mlevel(q, Lo, d, N, XL, 0n, NS)
  +h0 = hq0(d, Lo, Hi, hlh, hhi)
  +ci0 = CT.sw0_ci(d, N, XL, Lo, Hi, NS, hlh, hhi, len, ci)
  +up0 = CT.sw0_up(d, N, XL, Lo, Hi, NS, hlh, hhi, len, ci)
  +es = es0(d, N, XL, Lo, Hi, t, pf, hlh, hhi)
  +K1 = (O.pow2u(d) + lo : U32)
  +K2 = (O.pow2u(d) + hi : U32)
  %Equal.sym(Nat, U32.to_nat((hi - lo + 1 : U32)), q, CX.span_val(lo, hi, d, CL2.hd32(d, hd), hlh, hhi)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_levels(64n, d, K1, K2,
       Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_leaves(64n, _, lo, n, seg, O.pow2u(d), Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, t)}))
     == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, CL2.mlevels_t(d, 0n, d, N, XL, Lo, Hi, t0))} : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}
  %Equal.sym(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS,
      Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_leaves(64n, q, lo, n, seg, O.pow2u(d), Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, t)}),
      Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, t0)},
      CL2.cleaves(q, d, dw, ta, t, lo, Lo, n, seg, h, hd, hdw, pfa, hn, pf, {==}, CT.end_le(Lo, Hi, O.pow2n(d), hlh, hhi))) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_levels(64n, d, K1, K2, _)
     == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, CL2.mlevels_t(d, 0n, d, N, XL, Lo, Hi, t0))} : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}
  CL2.clevels(d, 0n, d, N, XL, Lo, Hi, K1, K2, t0, F.array__thaw(FuluValidator_d.Validator, ta), h, hd, F.nat__le_refl(d), hlh, hhi,
    CL2.cpos(lo, d, Lo, hd, {==}, F.nat__le_lt_trans(Lo, Hi, O.pow2n(d), hlh, hhi)),
    CL2.cpos(hi, d, Hi, hd, {==}, hhi),
    CL2.xlen(N, F.array__slots(FuluValidator_d.Validator, ta), 0n, 64n),
    CT.mlevel_t_perfect(q, Lo, d, N, XL, 0n, t, pf),
    CL2.len_tr(F.array__slots(D.Digest, t0), NS0, es, d, CT.lv_len(q, Lo, d, N, XL, 0n, NS, len)),
    CL2.ci_tr(F.array__slots(D.Digest, t0), NS0, es, d, N, XL, Lo, Hi, ci0),
    CL2.up_tr(F.array__slots(D.Digest, t0), NS0, es, d, N, XL, 0n, up0))

# ---- the padding to the limit depth -----------------------------------------------------------

# One padding level: the tree of depth p with the zero subtree of depth p beside it.
def pad_node(+p: Nat, +b: Bool, +XL: List<&2, D.Digest>,
    +hn: {Nat.is_le(MD.dlen(XL), O.pow2n(p)) == True{} : Bool},
    +hp: {Nat.is_lt(p, 63n) == True{} : Bool})
    -> {D.node(64n, MD.rtree(p, b, 64n, XL, 0n), D.zconst(p)) == MD.rtree(1n+p, b, 64n, XL, 0n) : D.Digest}:
  match b:
    case True{}:
      %Equal.sym(Bool, Nat.is_lt(O.pow2n(p), MD.dlen(XL)), False{}, F.nat__le_not_lt(O.pow2n(p), MD.dlen(XL), hn)) :
        {D.node(64n, MD.rtree(p, True{}, 64n, XL, 0n), D.zconst(p)) == D.node(64n, MD.rtree(p, True{}, 64n, XL, 0n), MD.rtree(p, _, 64n, XL, O.pow2n(p))) : D.Digest}
      %Equal.sym(D.Digest, MD.rtree(p, False{}, 64n, XL, O.pow2n(p)), D.zconst(p), CT.mv_z(p, 64n, XL, O.pow2n(p))) :
        {D.node(64n, MD.rtree(p, True{}, 64n, XL, 0n), D.zconst(p)) == D.node(64n, MD.rtree(p, True{}, 64n, XL, 0n), _) : D.Digest}
      {==}
    case False{}:
      %Equal.sym(D.Digest, MD.rtree(p, False{}, 64n, XL, 0n), D.zconst(p), CT.mv_z(p, 64n, XL, 0n)) :
        {D.node(64n, _, D.zconst(p)) == D.zconst(1n+p) : D.Digest}
      DF.zero_node(p, hp)

def plt(+p: Nat, +k: Nat, +hb: {Nat.is_lt(Nat.add(p, k), 63n) == True{} : Bool}) -> {Nat.is_lt(p, 63n) == True{} : Bool}:
  F.nat__le_lt_trans(p, Nat.add(p, k), 63n, Order.below_sum(p, k), hb)

def blvl(+lvl: U32, +p: Nat, +el: {U32.to_nat(lvl) == p : Nat}, +hp: {Nat.is_lt(p, 63n) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(lvl), U32.to_nat(1)), O.pow2n(6n)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(lvl), p, el) : {Nat.is_le(Nat.add(_, 1n), O.pow2n(6n)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(p, 1n), 1n+p, CX.NA_add1(p)) : {Nat.is_le(_, O.pow2n(6n)) == True{} : Bool}
  F.nat__lt_succ_le_succ(p, O.pow2n(6n), F.nat__lt_le_trans(p, 63n, 64n, hp, {==}))

def lvl_next(+lvl: U32, +p: Nat, +el: {U32.to_nat(lvl) == p : Nat}, +hp: {Nat.is_lt(p, 63n) == True{} : Bool})
    -> {U32.to_nat((lvl + 1 : U32)) == 1n+p : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(lvl, 1)), Nat.add(U32.to_nat(lvl), U32.to_nat(1)), CX.add_nat(lvl, 1, 6n, {==}, blvl(lvl, p, el, hp))) :
    {_ == 1n+p : Nat}
  %Equal.sym(Nat, U32.to_nat(lvl), p, el) : {Nat.add(_, 1n) == 1n+p : Nat}
  CX.NA_add1(p)

def hn_up(+XL: List<&2, D.Digest>, +p: Nat, +hn: {Nat.is_le(MD.dlen(XL), O.pow2n(p)) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(XL), O.pow2n(1n+p)) == True{} : Bool}:
  F.nat__le_trans(MD.dlen(XL), O.pow2n(p), Nat.double(O.pow2n(p)), hn, F.nat__double_self_le(O.pow2n(p)))

def hb_step(+p: Nat, +q: Nat, +hb: {Nat.is_lt(Nat.add(p, 1n+q), 63n) == True{} : Bool}) -> {Nat.is_lt(Nat.add(1n+p, q), 63n) == True{} : Bool}:
  %MR.add_succ(p, q) : {Nat.is_lt(_, 63n) == True{} : Bool}
  hb

def len_n(+XL: List<&2, D.Digest>, +N: Nat, +Bn: Nat, +en: {MD.dlen(XL) == N : Nat}, +hn: {Nat.is_le(N, Bn) == True{} : Bool})
    -> {Nat.is_le(MD.dlen(XL), Bn) == True{} : Bool}:
  %Equal.sym(Nat, MD.dlen(XL), N, en) : {Nat.is_le(_, Bn) == True{} : Bool}
  hn

# The runtime's padding loop from depth p, k levels up.
law pad_ok:
  for +k: Nat
  for +p: Nat
  for +lvl: U32
  for +b: Bool
  for +XL: List<&2, D.Digest>
  for -h: B.Buf
  for +el: {U32.to_nat(lvl) == p : Nat}
  for +hb: {Nat.is_lt(Nat.add(p, k), 63n) == True{} : Bool}
  for +hn: {Nat.is_le(MD.dlen(XL), O.pow2n(p)) == True{} : Bool}
  {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_pad_go(64n, k, lvl, MD.rtree(p, b, 64n, XL, 0n), (h, D.zconst(p))) == (h, MD.rtree(Nat.add(p, k), b, 64n, XL, 0n)) : B.Buf & D.Digest}
def pad_ok(k, p, lvl, b, XL, h, el, hb, hn):
  match k:
    case 0n:
      %Equal.sym(Nat, Nat.add(p, 0n), p, F.nat__add_zero(p)) : {(h, MD.rtree(p, b, 64n, XL, 0n)) == (h, MD.rtree(_, b, 64n, XL, 0n)) : B.Buf & D.Digest}
      {==}
    case 1n+ +q:
      +hp = plt(p, 1n+q, hb)
      %Equal.sym(Nat, U32.to_nat((lvl + 1 : U32)), 1n+p, lvl_next(lvl, p, el, hp)) :
        {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_pad_go(64n, q, (lvl + 1 : U32), D.node(64n, MD.rtree(p, b, 64n, XL, 0n), D.zconst(p)), (h, D.zconst(_)))
         == (h, MD.rtree(Nat.add(p, 1n+q), b, 64n, XL, 0n)) : B.Buf & D.Digest}
      %Equal.sym(D.Digest, D.node(64n, MD.rtree(p, b, 64n, XL, 0n), D.zconst(p)), MD.rtree(1n+p, b, 64n, XL, 0n), pad_node(p, b, XL, hn, hp)) :
        {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_pad_go(64n, q, (lvl + 1 : U32), _, (h, D.zconst(1n+p)))
         == (h, MD.rtree(Nat.add(p, 1n+q), b, 64n, XL, 0n)) : B.Buf & D.Digest}
      %Equal.sym(Nat, Nat.add(p, 1n+q), 1n+Nat.add(p, q), MR.add_succ(p, q)) :
        {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_pad_go(64n, q, (lvl + 1 : U32), MD.rtree(1n+p, b, 64n, XL, 0n), (h, D.zconst(1n+p)))
         == (h, MD.rtree(_, b, 64n, XL, 0n)) : B.Buf & D.Digest}
      pad_ok(q, 1n+p, (lvl + 1 : U32), b, XL, h, lvl_next(lvl, p, el, hp), hb_step(p, q, hb), hn_up(XL, p, hn))

law nat_u32_val:
  for +d: Nat
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  {U32.to_nat(O.nat_u32(d)) == d : Nat}
def nat_u32_val(d, hd):
  match d:
    case 0n: {==}
    case 1n+ +q:
      lvl_next(O.nat_u32(q), q, nat_u32_val(q, F.nat__lt_le_trans(q, 30n, 31n, hd, {==})), F.nat__lt_le_trans(q, 30n, 63n, hd, {==}))

# ---- the root ---------------------------------------------------------------------------

def one_lt(+d: Nat) -> {Nat.is_lt(1n, O.pow2n(1n+d)) == True{} : Bool}:
  %F.nat__sub_self(d) : {Nat.is_lt(Nat.add(O.pow2n(_), 0n), O.pow2n(1n+d)) == True{} : Bool}
  CT.hp_lt(d, d, 0n, F.nat__le_refl(d), CT.root_lt(d))

def d63(+d: Nat, +hdD: {Nat.is_le(d, 40n) == True{} : Bool}) -> {Nat.is_lt(Nat.add(d, Nat.sub(40n, d)), 63n) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(d, Nat.sub(40n, d)), 40n, F.nat__sub_add(40n, d, hdD)) : {Nat.is_lt(_, 63n) == True{} : Bool}
  {==}

# With every node holding its value: the root read, padded and length-mixed.
def croot_full(+d: Nat, +n: U32, +t: F.array__Tree<D.Digest>, -arr: Array<FuluValidator_d.Validator>, -h: B.Buf, +XL: List<&2, D.Digest>,
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +en: {MD.dlen(XL) == U32.to_nat(n) : Nat},
    +hn: {Nat.is_le(U32.to_nat(n), O.pow2n(d)) == True{} : Bool},
    +hdD: {Nat.is_le(d, 40n) == True{} : Bool},
    +up: CT.all_upto(F.array__slots(D.Digest, t), d, U32.to_nat(n), XL, d))
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_croot_top(64n, n, d, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, arr, F.array__thaw(D.Digest, t)})
        == (h, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{arr, n, d, F.array__thaw(D.Digest, t), n, 0},
                O.mix_len(64n, MD.rtree(40n, Nat.is_lt(0n, U32.to_nat(n)), 64n, XL, 0n), n)))
        : B.Buf & (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & D.Digest)}:
  +b = Nat.is_lt(0n, U32.to_nat(n))
  +r = MD.rtree(d, b, 64n, XL, 0n)
  +hnx = len_n(XL, U32.to_nat(n), O.pow2n(d), en, hn)
  %Equal.sym(Array<D.Digest> & D.Digest, Array.get(D.Digest, F.array__thaw(D.Digest, t), 1), (F.array__thaw(D.Digest, t), r),
      F.array__get(D.Digest, 1n+d, t, 1, r, hd, CX.rw_pow_lt(1n, 1n+d, one_lt(d)), CT.root_full(F.array__slots(D.Digest, t), d, U32.to_nat(n), XL, up), pf)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_croot_read(64n, n, d, h, arr, _)
     == (h, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{arr, n, d, F.array__thaw(D.Digest, t), n, 0}, O.mix_len(64n, MD.rtree(40n, b, 64n, XL, 0n), n)))
     : B.Buf & (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & D.Digest)}
  %Equal.sym(B.Buf & D.Digest, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_pad_go(64n, Nat.sub(40n, d), O.nat_u32(d), r, (h, D.zconst(d))),
      (h, MD.rtree(Nat.add(d, Nat.sub(40n, d)), b, 64n, XL, 0n)),
      pad_ok(Nat.sub(40n, d), d, O.nat_u32(d), b, XL, h, nat_u32_val(d, hd), d63(d, hdD), hnx)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_croot_fin(64n, n, d, arr, F.array__thaw(D.Digest, t), _)
     == (h, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{arr, n, d, F.array__thaw(D.Digest, t), n, 0}, O.mix_len(64n, MD.rtree(40n, b, 64n, XL, 0n), n)))
     : B.Buf & (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & D.Digest)}
  %Equal.sym(Nat, Nat.add(d, Nat.sub(40n, d)), 40n, F.nat__sub_add(40n, d, hdD)) :
    {(h, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{arr, n, d, F.array__thaw(D.Digest, t), n, 0}, O.mix_len(64n, MD.rtree(_, b, 64n, XL, 0n), n)))
     == (h, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{arr, n, d, F.array__thaw(D.Digest, t), n, 0}, O.mix_len(64n, MD.rtree(40n, b, 64n, XL, 0n), n)))
     : B.Buf & (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & D.Digest)}
  {==}

# ---- the cached root -------------------------------------------------------------------------

# The node tree after a root: swept if the range was nonempty.
def after(b: Bool, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>) -> F.array__Tree<D.Digest>:
  match b:
    case True{}: msweep_t(d, n, XL, lo, hi, t)
    case False{}: t

def full_after(+b: Bool, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>,
    +eb: {Nat.is_le(lo, hi) == b : Bool},
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +hhi: {Nat.is_lt(hi, O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, F.array__slots(D.Digest, t)) == O.pow2n(1n+d) : Nat},
    +ci: CT.cinv(F.array__slots(D.Digest, t), d, n, XL, lo, hi))
    -> CT.all_upto(F.array__slots(D.Digest, after(b, d, n, XL, lo, hi, t)), d, n, XL, d):
  match b:
    case True{}: msweep_t_full(d, n, XL, lo, hi, t, pf, eb, hhi, len, ci)
    case False{}: CT.clean_full(F.array__slots(D.Digest, t), d, n, XL, lo, hi, F.nat__not_le_lt(lo, hi, eb), ci)

def perfect_after(+b: Bool, +d: Nat, +n: Nat, +XL: List<&2, D.Digest>, +lo: Nat, +hi: Nat, +t: F.array__Tree<D.Digest>,
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool})
    -> {F.array__perfect(D.Digest, 1n+d, after(b, d, n, XL, lo, hi, t)) == True{} : Bool}:
  match b:
    case True{}: msweep_t_perfect(d, n, XL, lo, hi, t, pf)
    case False{}: pf

def sweep_after(+b: Bool, +d: Nat, +dw: Nat, +ta: F.array__Tree<FuluValidator_d.Validator>, +t: F.array__Tree<D.Digest>, +lo: U32, +hi: U32, +n: U32, +seg: U32, -h: B.Buf,
    +eb: {Nat.is_le(U32.to_nat(lo), U32.to_nat(hi)) == b : Bool},
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool},
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +hhi: {Nat.is_lt(U32.to_nat(hi), O.pow2n(d)) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, F.array__slots(D.Digest, t)) == O.pow2n(1n+d) : Nat},
    +ci: CT.cinv(F.array__slots(D.Digest, t), d, U32.to_nat(n), XLof(n, ta), U32.to_nat(lo), U32.to_nat(hi)))
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_sweep_pick(64n, b, d, lo, hi, n, seg, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, t)})
        == Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta),
             F.array__thaw(D.Digest, after(b, d, U32.to_nat(n), XLof(n, ta), U32.to_nat(lo), U32.to_nat(hi), t))}
        : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS}:
  match b:
    case True{}: csweep(d, dw, ta, t, lo, hi, n, seg, h, hd, hdw, pfa, hn, pf, eb, hhi, len, ci)
    case False{}: {==}

# The cached root of BeaconState.validators: the length-mixed reference tree of
# the element roots, and a returned cache with an empty range in which every
# node holds its value (full_after).
law cached_root_correct:
  for +d: Nat
  for +dw: Nat
  for +ta: F.array__Tree<FuluValidator_d.Validator>
  for +t: F.array__Tree<D.Digest>
  for +lo: U32
  for +hi: U32
  for +n: U32
  for +seg: U32
  for -h: B.Buf
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdD: {Nat.is_le(d, 40n) == True{} : Bool}
  for +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}
  for +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool}
  for +hnd: {Nat.is_le(U32.to_nat(n), O.pow2n(d)) == True{} : Bool}
  for +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool}
  for +hhi: {Nat.is_lt(U32.to_nat(hi), O.pow2n(d)) == True{} : Bool}
  for +len: {F.spec_common__length(D.Digest, F.array__slots(D.Digest, t)) == O.pow2n(1n+d) : Nat}
  for +ci: CT.cinv(F.array__slots(D.Digest, t), d, U32.to_nat(n), XLof(n, ta), U32.to_nat(lo), U32.to_nat(hi))
  {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cached_root(64n, h, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi}, seg)
   == (h, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{F.array__thaw(FuluValidator_d.Validator, ta), n, d,
             F.array__thaw(D.Digest, after(Nat.is_le(U32.to_nat(lo), U32.to_nat(hi)), d, U32.to_nat(n), XLof(n, ta), U32.to_nat(lo), U32.to_nat(hi), t)), n, 0},
           O.mix_len(64n, MD.rtree(40n, Nat.is_lt(0n, U32.to_nat(n)), 64n, XLof(n, ta), 0n), n)))
   : B.Buf & (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & D.Digest)}
def cached_root_correct(d, dw, ta, t, lo, hi, n, seg, h, hd, hdD, hdw, pfa, hn, hnd, pf, hhi, len, ci):
  +N = U32.to_nat(n)
  +XL = XLof(n, ta)
  +b = Nat.is_le(U32.to_nat(lo), U32.to_nat(hi))
  +t1 = after(b, d, N, XL, U32.to_nat(lo), U32.to_nat(hi), t)
  %Equal.sym(Bool, U32.is_le(lo, hi), b, CX.le_nat(lo, hi)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_croot_top(64n, n, d,
       Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_sweep_pick(64n, _, d, lo, hi, n, seg, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, t)}))
     == (h, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t1), n, 0},
           O.mix_len(64n, MD.rtree(40n, Nat.is_lt(0n, N), 64n, XL, 0n), n))) : B.Buf & (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & D.Digest)}
  %Equal.sym(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS,
      Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_sweep_pick(64n, b, d, lo, hi, n, seg, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, t)}),
      Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_TS{h, F.array__thaw(FuluValidator_d.Validator, ta), F.array__thaw(D.Digest, t1)},
      sweep_after(b, d, dw, ta, t, lo, hi, n, seg, h, {==}, hd, hdw, pfa, hn, pf, hhi, len, ci)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_croot_top(64n, n, d, _) == (h, (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t1), n, 0},
           O.mix_len(64n, MD.rtree(40n, Nat.is_lt(0n, N), 64n, XL, 0n), n))) : B.Buf & (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & D.Digest)}
  croot_full(d, n, t1, F.array__thaw(FuluValidator_d.Validator, ta), h, XL,
    hd, perfect_after(b, d, N, XL, U32.to_nat(lo), U32.to_nat(hi), t, pf),
    CL2.xlen(N, F.array__slots(FuluValidator_d.Validator, ta), 0n, 64n), hnd, hdD,
    full_after(b, d, N, XL, U32.to_nat(lo), U32.to_nat(hi), t, {==}, pf, hhi, len, ci))
