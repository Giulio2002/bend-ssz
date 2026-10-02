import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d
import ../../proofs/nat_order.bend as Order
import ../compact/found_generated.bend as F
import ./mtree_defs.bend as MD
import ./dk.bend as DK
import ./ctree.bend as CT
import ./cidx.bend as CX
import ./cloop2.bend as L2
import ./cloop3.bend as L3
import ./cset.bend as CS
import ./cmut.bend as CM
import ./wdstage.bend as WS2

# The public cache API of BeaconState.validators (l1099511627776_Validator:
# cache, cset, capp, cached_root) on the cache invariant. A cache
# Cached{thaw ta, n, d, thaw t, lo, hi} is valid when inv(ta, dw, t, n, d, lo,
# hi) holds: the items are a perfect tree of depth dw >= d, n <= 2^d, the node
# array is a perfect tree of depth 1 + d, and every node clean for [lo, hi]
# holds its value over the element roots (ctree's cinv). Then:
#
#   cache_inv     cache(Seq{thaw ta, n}) is valid, for n <= 2^dw with dw <= 30 and
#                 dw <= the limit depth 40;
#   root_eq       cached_root returns mix_len(64, rtree(40, 0 < n, 64, XL, 0), n),
#                 XL the element roots (cloop3), and root_inv: its cache is valid;
#   cset_eq/_inv  a write at i < n is the tree update and keeps validity;
#   capp_eq/_inv  an append that fits the capacity (n < 2^d) likewise.
#
# So after any history of writes and fitting appends from a fresh cache, every
# root is the reference root of the current elements. Not covered here: the
# append that grows the capacity (the `room` copy loop).

def xroots(+n: U32, +ta: F.array__Tree<FuluValidator_d.Validator>) -> List<&2, D.Digest>: L3.XLof(n, ta)

def inv(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +t: F.array__Tree<D.Digest>, +n: U32, +d: Nat, +lo: U32, +hi: U32) -> Data:
  DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
  DK.P2({F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
  DK.P2({Nat.is_le(O.pow2n(d), F.spec_common__pow2(dw)) == True{} : Bool},
  DK.P2({Nat.is_lt(d, 31n) == True{} : Bool},
  DK.P2({Nat.is_le(d, 40n) == True{} : Bool},
  DK.P2({Nat.is_le(U32.to_nat(n), O.pow2n(d)) == True{} : Bool},
  DK.P2({F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
  DK.P2({Nat.is_lt(U32.to_nat(hi), O.pow2n(d)) == True{} : Bool},
  DK.P2({F.spec_common__length(D.Digest, F.array__slots(D.Digest, t)) == O.pow2n(1n+d) : Nat},
        CT.cinv(F.array__slots(D.Digest, t), d, U32.to_nat(n), xroots(n, ta), U32.to_nat(lo), U32.to_nat(hi)))))))))))

def cached(+ta: F.array__Tree<FuluValidator_d.Validator>, +t: F.array__Tree<D.Digest>, +n: U32, +d: Nat, +lo: U32, +hi: U32) -> Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached:
  Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi}

# ---- the root ------------------------------------------------------------------------------

def dig(+n: U32, +ta: F.array__Tree<FuluValidator_d.Validator>) -> D.Digest:
  O.mix_len(64n, MD.rtree(40n, Nat.is_lt(0n, U32.to_nat(n)), 64n, xroots(n, ta), 0n), n)

def tafter(+ta: F.array__Tree<FuluValidator_d.Validator>, +t: F.array__Tree<D.Digest>, +n: U32, +d: Nat, +lo: U32, +hi: U32) -> F.array__Tree<D.Digest>:
  L3.after(Nat.is_le(U32.to_nat(lo), U32.to_nat(hi)), d, U32.to_nat(n), xroots(n, ta), U32.to_nat(lo), U32.to_nat(hi), t)

law root_eq:
  for -h: B.Buf
  for +ta: F.array__Tree<FuluValidator_d.Validator>
  for +dw: Nat
  for +t: F.array__Tree<D.Digest>
  for +n: U32
  for +d: Nat
  for +lo: U32
  for +hi: U32
  for +seg: U32
  for +iv: inv(ta, dw, t, n, d, lo, hi)
  {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cached_root(64n, h, cached(ta, t, n, d, lo, hi), seg) == (h, (cached(ta, tafter(ta, t, n, d, lo, hi), n, d, n, 0), dig(n, ta)))
   : B.Buf & (Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & D.Digest)}
def root_eq(h, ta, dw, t, n, d, lo, hi, seg, iv):
  (+hdw, w1) = iv
  (+pfa, w2) = w1
  (+hcap, w3) = w2
  (+hd, w4) = w3
  (+hdD, w5) = w4
  (+hnd, w6) = w5
  (+pf, w7) = w6
  (+hhi, w8) = w7
  (+len, +ci) = w8
  L3.cached_root_correct(d, dw, ta, t, lo, hi, n, seg, h, hd, hdD, hdw, pfa,
    F.nat__le_trans(U32.to_nat(n), O.pow2n(d), F.spec_common__pow2(dw), hnd, hcap), hnd, pf, hhi, len, ci)

def len_after(+b: Bool, +d: Nat, +N: Nat, +XLs: List<&2, D.Digest>, +Lo: Nat, +Hi: Nat, +t: F.array__Tree<D.Digest>,
    +pf: {F.array__perfect(D.Digest, 1n+d, t) == True{} : Bool},
    +len: {F.spec_common__length(D.Digest, F.array__slots(D.Digest, t)) == O.pow2n(1n+d) : Nat})
    -> {F.spec_common__length(D.Digest, F.array__slots(D.Digest, L3.after(b, d, N, XLs, Lo, Hi, t))) == O.pow2n(1n+d) : Nat}:
  match b:
    case True{}: L3.msweep_t_len(d, N, XLs, Lo, Hi, t, pf)
    case False{}: len

# The cache a root returns is valid, with the range [n, 0].
law root_inv:
  for +ta: F.array__Tree<FuluValidator_d.Validator>
  for +dw: Nat
  for +t: F.array__Tree<D.Digest>
  for +n: U32
  for +d: Nat
  for +lo: U32
  for +hi: U32
  for +iv: inv(ta, dw, t, n, d, lo, hi)
  inv(ta, dw, tafter(ta, t, n, d, lo, hi), n, d, n, 0)
def root_inv(ta, dw, t, n, d, lo, hi, iv):
  (+hdw, w1) = iv
  (+pfa, w2) = w1
  (+hcap, w3) = w2
  (+hd, w4) = w3
  (+hdD, w5) = w4
  (+hnd, w6) = w5
  (+pf, w7) = w6
  (+hhi, w8) = w7
  (+len, +ci) = w8
  +b = Nat.is_le(U32.to_nat(lo), U32.to_nat(hi))
  +N = U32.to_nat(n)
  +t2 = tafter(ta, t, n, d, lo, hi)
  (hdw, (pfa, (hcap, (hd, (hdD, (hnd,
    (L3.perfect_after(b, d, N, xroots(n, ta), U32.to_nat(lo), U32.to_nat(hi), t, pf),
    (F.nat__lt_le_trans(0n, 1n, O.pow2n(d), {==}, CT.pow2_pos(d)),
    (len_after(b, d, N, xroots(n, ta), U32.to_nat(lo), U32.to_nat(hi), t, pf, len),
     CT.full_cinv(F.array__slots(D.Digest, t2), d, N, xroots(n, ta), N, 0n,
       L3.full_after(b, d, N, xroots(n, ta), U32.to_nat(lo), U32.to_nat(hi), t, {==}, pf, hhi, len, ci)))))))))))

# ---- a write --------------------------------------------------------------------------------

def item_lt(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +d: Nat, +I: Nat,
    +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
    +hcap: {Nat.is_le(O.pow2n(d), F.spec_common__pow2(dw)) == True{} : Bool},
    +hI: {Nat.is_lt(I, O.pow2n(d)) == True{} : Bool})
    -> {Nat.is_lt(I, F.spec_common__pow2(dw)) == True{} : Bool}:
  F.nat__lt_le_trans(I, O.pow2n(d), F.spec_common__pow2(dw), hI, hcap)

def item_len(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +I: Nat,
    +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
    +h: {Nat.is_lt(I, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_lt(I, F.spec_common__length(FuluValidator_d.Validator, F.array__slots(FuluValidator_d.Validator, ta))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(FuluValidator_d.Validator, F.array__slots(FuluValidator_d.Validator, ta)), F.spec_common__pow2(dw), F.array__slots_length(FuluValidator_d.Validator, dw, ta, pfa)) : {Nat.is_lt(I, _) == True{} : Bool}
  h

# Writing the items at i.
def set_items(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +i: U32, +v: FuluValidator_d.Validator,
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
    +h: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Array.set(FuluValidator_d.Validator, F.array__thaw(FuluValidator_d.Validator, ta), i, v) == F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v)) : Array<FuluValidator_d.Validator>}:
  +W = F.array__slots(FuluValidator_d.Validator, ta)
  F.array__set(FuluValidator_d.Validator, dw, ta, i, v, L2.xat(W, U32.to_nat(i)), hdw, h, L2.xnth(W, U32.to_nat(i), item_len(ta, dw, U32.to_nat(i), pfa, h)), pfa)

def set_state(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +t: F.array__Tree<D.Digest>, +n: U32, +d: Nat, +lo: U32, +hi: U32, +i: U32, +v: FuluValidator_d.Validator,
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
    +h: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset_in(True{}, F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, i, v)
        == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v), t, n, d, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)), True{})
        : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}:
  %Equal.sym(Array<FuluValidator_d.Validator>, Array.set(FuluValidator_d.Validator, F.array__thaw(FuluValidator_d.Validator, ta), i, v), F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v)),
      set_items(ta, dw, i, v, hdw, pfa, h)) :
    {(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{_, n, d, F.array__thaw(D.Digest, t), O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)}, True{})
     == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v), t, n, d, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)), True{})
     : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}
  {==}

# A write at i < n: the items tree updated at i, the range widened.
law cset_eq:
  for +ta: F.array__Tree<FuluValidator_d.Validator>
  for +dw: Nat
  for +t: F.array__Tree<D.Digest>
  for +n: U32
  for +d: Nat
  for +lo: U32
  for +hi: U32
  for +i: U32
  for +v: FuluValidator_d.Validator
  for +hin: {Nat.is_lt(U32.to_nat(i), U32.to_nat(n)) == True{} : Bool}
  for +iv: inv(ta, dw, t, n, d, lo, hi)
  {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset(cached(ta, t, n, d, lo, hi), i, v)
   == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v), t, n, d, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)), True{})
   : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}
def cset_eq(ta, dw, t, n, d, lo, hi, i, v, hin, iv):
  (+hdw, w1) = iv
  (+pfa, w2) = w1
  (+hcap, w3) = w2
  (+hd, w4) = w3
  (+hdD, w5) = w4
  (+hnd, w6) = w5
  %Equal.sym(Bool, U32.is_lt(i, n), Nat.is_lt(U32.to_nat(i), U32.to_nat(n)), CX.lt_nat(i, n)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset_in(_, F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, i, v)
     == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v), t, n, d, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)), True{})
     : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Bool, Nat.is_lt(U32.to_nat(i), U32.to_nat(n)), True{}, hin) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset_in(_, F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, i, v)
     == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v), t, n, d, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)), True{})
     : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}
  set_state(ta, dw, t, n, d, lo, hi, i, v, hdw, pfa,
    item_lt(ta, dw, d, U32.to_nat(i), pfa, hcap, F.nat__lt_le_trans(U32.to_nat(i), U32.to_nat(n), O.pow2n(d), hin, hnd)))

def up_slots(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +I: Nat, +v: FuluValidator_d.Validator,
    +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
    +h: {Nat.is_lt(I, F.spec_common__pow2(dw)) == True{} : Bool})
    -> {F.array__slots(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, dw, ta, I, v)) == F.spec_common__update(FuluValidator_d.Validator, F.array__slots(FuluValidator_d.Validator, ta), I, v) : List<&2, FuluValidator_d.Validator>}:
  F.array__upd_slots(FuluValidator_d.Validator, dw, ta, I, v, h, pfa)

def ci_items(+t: F.array__Tree<D.Digest>, +d: Nat, +N: Nat, +n2: U32, +Lo: Nat, +Hi: Nat, +W2: List<&2, FuluValidator_d.Validator>, +ta2: F.array__Tree<FuluValidator_d.Validator>,
    +e: {F.array__slots(FuluValidator_d.Validator, ta2) == W2 : List<&2, FuluValidator_d.Validator>},
    +en: {U32.to_nat(n2) == N : Nat},
    +c: CT.cinv(F.array__slots(D.Digest, t), d, N, L2.xl(N, W2, 0n, 64n), Lo, Hi))
    -> CT.cinv(F.array__slots(D.Digest, t), d, U32.to_nat(n2), xroots(n2, ta2), Lo, Hi):
  %Equal.sym(List<&2, FuluValidator_d.Validator>, F.array__slots(FuluValidator_d.Validator, ta2), W2, e) : CT.cinv(F.array__slots(D.Digest, t), d, U32.to_nat(n2), L2.xl(U32.to_nat(n2), _, 0n, 64n), Lo, Hi)
  %Equal.sym(Nat, U32.to_nat(n2), N, en) : CT.cinv(F.array__slots(D.Digest, t), d, _, L2.xl(_, W2, 0n, 64n), Lo, Hi)
  c

# The written cache is valid.
law cset_inv:
  for +ta: F.array__Tree<FuluValidator_d.Validator>
  for +dw: Nat
  for +t: F.array__Tree<D.Digest>
  for +n: U32
  for +d: Nat
  for +lo: U32
  for +hi: U32
  for +i: U32
  for +v: FuluValidator_d.Validator
  for +hin: {Nat.is_lt(U32.to_nat(i), U32.to_nat(n)) == True{} : Bool}
  for +iv: inv(ta, dw, t, n, d, lo, hi)
  inv(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v), dw, t, n, d, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i))
def cset_inv(ta, dw, t, n, d, lo, hi, i, v, hin, iv):
  (+hdw, w1) = iv
  (+pfa, w2) = w1
  (+hcap, w3) = w2
  (+hd, w4) = w3
  (+hdD, w5) = w4
  (+hnd, w6) = w5
  (+pf, w7) = w6
  (+hhi, w8) = w7
  (+len, +ci) = w8
  +I = U32.to_nat(i)
  +N = U32.to_nat(n)
  +ib = F.nat__lt_le_trans(I, N, O.pow2n(d), hin, hnd)
  +hI = item_lt(ta, dw, d, I, pfa, hcap, ib)
  +c1 = U32.is_le(lo, i)
  +c2 = U32.is_le(i, hi)
  (hdw, (F.array__upd_perfect(FuluValidator_d.Validator, dw, ta, I, v, pfa), (hcap, (hd, (hdD, (hnd, (pf,
    (CS.cset_hi(d, i, hi, c2, hhi, ib),
    (len,
     ci_items(t, d, N, n, U32.to_nat(O.pick(c1, lo, i)), U32.to_nat(O.pick(c2, hi, i)),
       F.spec_common__update(FuluValidator_d.Validator, F.array__slots(FuluValidator_d.Validator, ta), I, v), F.array__upd(FuluValidator_d.Validator, dw, ta, I, v),
       up_slots(ta, dw, I, v, pfa, hI), {==},
       CS.cset_cinv(d, t, N, F.array__slots(FuluValidator_d.Validator, ta), i, v, lo, hi,
         c1, Equal.sym(Bool, U32.is_le(lo, i), Nat.is_le(U32.to_nat(lo), I), CX.le_nat(lo, i)),
         c2, Equal.sym(Bool, U32.is_le(i, hi), Nat.is_le(I, U32.to_nat(hi)), CX.le_nat(i, hi)),
         hhi, ib, hin, item_len(ta, dw, I, pfa, hI), ci)))))))))))

def WS2hd32(+d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}) -> {Nat.is_lt(d, 32n) == True{} : Bool}:
  F.nat__lt_le_trans(d, 31n, 32n, hd, {==})

# ---- an append inside the capacity ------------------------------------------------------------

def fit_true(+n: U32, +d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hfit: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == True{} : Bool})
    -> {U32.is_lt(n, O.pow2u(d)) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_lt(n, O.pow2u(d)), Nat.is_lt(U32.to_nat(n), U32.to_nat(O.pow2u(d))), CX.lt_nat(n, O.pow2u(d))) : {_ == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(O.pow2u(d)), O.pow2n(d), CX.pow2u_val(d, WS2hd32(d, hd))) : {Nat.is_lt(U32.to_nat(n), _) == True{} : Bool}
  hfit

def app_state(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +t: F.array__Tree<D.Digest>, +n: U32, +d: Nat, +lo: U32, +hi: U32, +v: FuluValidator_d.Validator,
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool},
    +h: {Nat.is_lt(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp_fit(True{}, F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, v)
        == cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n))
        : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached}:
  %Equal.sym(Array<FuluValidator_d.Validator>, Array.set(FuluValidator_d.Validator, F.array__thaw(FuluValidator_d.Validator, ta), n, v), F.array__thaw(FuluValidator_d.Validator, F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v)),
      set_items(ta, dw, n, v, hdw, pfa, h)) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{_, (n + 1 : U32), d, F.array__thaw(D.Digest, t), O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)}
     == cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n))
     : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached}
  {==}

# The runtime's append guard: `capp` appends only when it holds. This list's
# limit (2^40) is above every U32 length, so its guard is the largest count, n < 2^32 - 1 (docs/CRASH_HUNT.md CH-04: the older
# `n + 1 <= limit` wrapped at 2^32 - 1); each generated list (codegen/proofs/laws/cached_root_laws.py) substitutes its own n < limit.
def guard(+n: U32) -> Bool: U32.is_lt(n, 4294967295)

# An append into a cache with room (n < 2^d): the items tree updated at n, n + 1 elements.
law capp_eq:
  for +ta: F.array__Tree<FuluValidator_d.Validator>
  for +dw: Nat
  for +t: F.array__Tree<D.Digest>
  for +n: U32
  for +d: Nat
  for +lo: U32
  for +hi: U32
  for +v: FuluValidator_d.Validator
  for +hfit: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == True{} : Bool}
  for +hgd: {guard(n) == True{} : Bool}
  for +iv: inv(ta, dw, t, n, d, lo, hi)
  {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp(cached(ta, t, n, d, lo, hi), v)
   == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)), True{})
   : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}
def capp_eq(ta, dw, t, n, d, lo, hi, v, hfit, hgd, iv):
  (+hdw, w1) = iv
  (+pfa, w2) = w1
  (+hcap, w3) = w2
  (+hd, w4) = w3
  %Equal.sym(Bool, guard(n), True{}, hgd) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp_in(_, F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, v)
     == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)), True{})
     : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Bool, U32.is_lt(n, O.pow2u(d)), True{}, fit_true(n, d, hd, hfit)) :
    {(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp_fit(_, F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, v), True{})
     == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)), True{})
     : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached,
      Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp_fit(True{}, F.array__thaw(FuluValidator_d.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, v),
      cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)),
      app_state(ta, dw, t, n, d, lo, hi, v, hdw, pfa, item_lt(ta, dw, d, U32.to_nat(n), pfa, hcap, hfit))) :
    {(_, True{})
     == (cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)), True{})
     : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool}
  {==}

def app_bnext(+n: U32, +d: Nat, +hfit: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(n), U32.to_nat(1)), O.pow2n(d)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(U32.to_nat(n), 1n), 1n+U32.to_nat(n), CX.NA_add1(U32.to_nat(n))) : {Nat.is_le(_, O.pow2n(d)) == True{} : Bool}
  F.nat__lt_succ_le_succ(U32.to_nat(n), O.pow2n(d), hfit)

# The length after the append: 1 + n.
def n_next(+n: U32, +d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hfit: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == True{} : Bool})
    -> {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(n, 1)), Nat.add(U32.to_nat(n), U32.to_nat(1)), CX.add_nat(n, 1, d, WS2hd32(d, hd), app_bnext(n, d, hfit))) : {_ == 1n+U32.to_nat(n) : Nat}
  CX.NA_add1(U32.to_nat(n))

def hnd_next(+n: U32, +d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hfit: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat((n + 1 : U32)), 1n+U32.to_nat(n), n_next(n, d, hd, hfit)) : {Nat.is_le(_, O.pow2n(d)) == True{} : Bool}
  F.nat__lt_succ_le_succ(U32.to_nat(n), O.pow2n(d), hfit)

# The appended cache is valid.
law capp_inv:
  for +ta: F.array__Tree<FuluValidator_d.Validator>
  for +dw: Nat
  for +t: F.array__Tree<D.Digest>
  for +n: U32
  for +d: Nat
  for +lo: U32
  for +hi: U32
  for +v: FuluValidator_d.Validator
  for +hfit: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == True{} : Bool}
  for +iv: inv(ta, dw, t, n, d, lo, hi)
  inv(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), dw, t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n))
def capp_inv(ta, dw, t, n, d, lo, hi, v, hfit, iv):
  (+hdw, w1) = iv
  (+pfa, w2) = w1
  (+hcap, w3) = w2
  (+hd, w4) = w3
  (+hdD, w5) = w4
  (+hnd, w6) = w5
  (+pf, w7) = w6
  (+hhi, w8) = w7
  (+len, +ci) = w8
  +N = U32.to_nat(n)
  +hI = item_lt(ta, dw, d, N, pfa, hcap, hfit)
  +c1 = U32.is_le(lo, n)
  +c2 = U32.is_le(n, hi)
  (hdw, (F.array__upd_perfect(FuluValidator_d.Validator, dw, ta, N, v, pfa), (hcap, (hd, (hdD, (hnd_next(n, d, hd, hfit), (pf,
    (CS.cset_hi(d, n, hi, c2, hhi, hfit),
    (len,
     ci_items(t, d, 1n+N, (n + 1 : U32), U32.to_nat(O.pick(c1, lo, n)), U32.to_nat(O.pick(c2, hi, n)),
       F.spec_common__update(FuluValidator_d.Validator, F.array__slots(FuluValidator_d.Validator, ta), N, v), F.array__upd(FuluValidator_d.Validator, dw, ta, N, v),
       up_slots(ta, dw, N, v, pfa, hI), n_next(n, d, hd, hfit),
       CM.capp_cinv(d, t, F.array__slots(FuluValidator_d.Validator, ta), n, v, lo, hi,
         c1, Equal.sym(Bool, U32.is_le(lo, n), Nat.is_le(U32.to_nat(lo), N), CX.le_nat(lo, n)),
         c2, Equal.sym(Bool, U32.is_le(n, hi), Nat.is_le(N, U32.to_nat(hi)), CX.le_nat(n, hi)),
         hhi, hfit, item_len(ta, dw, N, pfa, hI), ci)))))))))))

# ---- a fresh cache -------------------------------------------------------------------------

def dnew(+d: Nat) -> F.array__Tree<D.Digest>: F.array__trep(D.Digest, 1n+d, D.zero())

def hi_fresh(+d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool})
    -> {U32.to_nat((O.pow2u(d) - 1 : U32)) == Nat.sub(O.pow2n(d), 1n) : Nat}:
  +ev = CX.pow2u_val(d, WS2hd32(d, hd))
  +h1 = CT.rw_le(O.pow2n(d), U32.to_nat(O.pow2u(d)), 1n, Equal.sym(Nat, U32.to_nat(O.pow2u(d)), O.pow2n(d), ev), CT.pow2_pos(d))
  %Equal.sym(Nat, U32.to_nat(U32.sub(O.pow2u(d), 1)), Nat.sub(U32.to_nat(O.pow2u(d)), U32.to_nat(1)), F.u32__sub_nat(O.pow2u(d), 1, h1)) : {_ == Nat.sub(O.pow2n(d), 1n) : Nat}
  %Equal.sym(Nat, U32.to_nat(O.pow2u(d)), O.pow2n(d), ev) : {Nat.sub(_, 1n) == Nat.sub(O.pow2n(d), 1n) : Nat}
  {==}

def fresh_len(+d: Nat) -> {F.spec_common__length(D.Digest, F.array__slots(D.Digest, dnew(d))) == O.pow2n(1n+d) : Nat}:
  Equal.trans(Nat, F.spec_common__length(D.Digest, F.array__slots(D.Digest, dnew(d))), F.spec_common__pow2(1n+d), O.pow2n(1n+d),
    F.array__slots_length(D.Digest, 1n+d, dnew(d), F.array__trep_perfect(D.Digest, 1n+d, D.zero())), CT.pow2_eq(1n+d))

# The node array a fresh cache allocates.
def fresh_nodes(+d: Nat) -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_dfill(1n+d) == F.array__thaw(D.Digest, dnew(d)) : Array<D.Digest>}:
  F.array__new(D.Digest, 1n+d, D.zero())

def pw_le_dw(+n: U32, +dw: Nat, +hn: {Nat.is_le(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(n), O.pow2n(dw)) == True{} : Bool}:
  %CT.pow2_eq(dw) : {Nat.is_le(U32.to_nat(n), _) == True{} : Bool}
  hn

# cache(Seq{thaw ta, n}): the fresh cache at depth words_depth(n), every leaf dirty.
def cache_eq(+ta: F.array__Tree<FuluValidator_d.Validator>, +n: U32)
    -> {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cache(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Seq{F.array__thaw(FuluValidator_d.Validator, ta), n})
        == cached(ta, dnew(B.words_depth(n)), n, B.words_depth(n), 0, (O.pow2u(B.words_depth(n)) - 1 : U32))
        : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached}:
  %Equal.sym(Array<D.Digest>, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_dfill(1n+B.words_depth(n)), F.array__thaw(D.Digest, dnew(B.words_depth(n))), fresh_nodes(B.words_depth(n))) :
    {Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{F.array__thaw(FuluValidator_d.Validator, ta), n, B.words_depth(n), _, 0, (O.pow2u(B.words_depth(n)) - 1 : U32)}
     == cached(ta, dnew(B.words_depth(n)), n, B.words_depth(n), 0, (O.pow2u(B.words_depth(n)) - 1 : U32))
     : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached}
  {==}

def hi_lt(+d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}) -> {Nat.is_lt(U32.to_nat((O.pow2u(d) - 1 : U32)), O.pow2n(d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat((O.pow2u(d) - 1 : U32)), Nat.sub(O.pow2n(d), 1n), hi_fresh(d, hd)) : {Nat.is_lt(_, O.pow2n(d)) == True{} : Bool}
  WS2.sub1_lt(O.pow2n(d), CT.pow2_pos(d))

def fresh_ci(+d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +n: U32, +ta: F.array__Tree<FuluValidator_d.Validator>)
    -> CT.cinv(F.array__slots(D.Digest, dnew(d)), d, U32.to_nat(n), xroots(n, ta), U32.to_nat(0), U32.to_nat((O.pow2u(d) - 1 : U32))):
  %Equal.sym(Nat, U32.to_nat((O.pow2u(d) - 1 : U32)), Nat.sub(O.pow2n(d), 1n), hi_fresh(d, hd)) : CT.cinv(F.array__slots(D.Digest, dnew(d)), d, U32.to_nat(n), xroots(n, ta), 0n, _)
  CM.fresh_cinv(F.array__slots(D.Digest, dnew(d)), d, U32.to_nat(n), xroots(n, ta))

# The fresh cache of a list with n <= 2^dw, dw <= 30 and dw <= 40, is valid.
law cache_inv:
  for +ta: F.array__Tree<FuluValidator_d.Validator>
  for +dw: Nat
  for +n: U32
  for +hdw: {Nat.is_le(dw, 30n) == True{} : Bool}
  for +hdwD: {Nat.is_le(dw, 40n) == True{} : Bool}
  for +pfa: {F.array__perfect(FuluValidator_d.Validator, dw, ta) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool}
  inv(ta, dw, dnew(B.words_depth(n)), n, B.words_depth(n), 0, (O.pow2u(B.words_depth(n)) - 1 : U32))
def cache_inv(ta, dw, n, hdw, hdwD, pfa, hn):
  +d = B.words_depth(n)
  +hn2 = pw_le_dw(n, dw, hn)
  +hdd = WS2.wd_min(n, dw, hn2)
  +hd30 = F.nat__le_trans(d, dw, 30n, hdd, hdw)
  +hd = F.nat__le_lt_trans(d, 30n, 31n, hd30, {==})
  +hdw32 = F.nat__le_lt_trans(dw, 30n, 32n, hdw, {==})
  (hdw32, (pfa,
    (CT.rw_le(O.pow2n(dw), F.spec_common__pow2(dw), O.pow2n(d), Equal.sym(Nat, F.spec_common__pow2(dw), O.pow2n(dw), CT.pow2_eq(dw)), CT.pow2_mono(d, dw, hdd)),
    (hd, (F.nat__le_trans(d, dw, 40n, hdd, hdwD),
    (WS2.wd_cover(n, dw, F.nat__le_trans(dw, 30n, 32n, hdw, {==}), hn2),
    (F.array__trep_perfect(D.Digest, 1n+d, D.zero()),
    (hi_lt(d, hd),
    (fresh_len(d),
     fresh_ci(d, hd, n, ta))))))))))
