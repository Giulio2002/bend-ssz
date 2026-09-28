import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ../../spec/nat_bytes.bend as N
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vdepth.bend as VD
import ./vcopy.bend as VC
import ./vfits.bend as VFT

# Bare lists of whole words (the progressive lists of codegen/var_plist.py):
# the element-agnostic facts of a buffer of n = 4 m bytes on a perfect word
# tree of depth d < 28, and of an object whose list holds m words in a tree of
# depth dw < 28. Everything is symbolic in d, n and m; no closed power of two
# is evaluated.

# ---- word arithmetic ----------------------------------------------------------------------------

def and3_q(+L: U32, +m: Nat, +e: {U32.to_nat(L) == A.quad(m) : Nat}) -> {U32.and(L, 3) == 0 : U32}:
  +q = U32.to_nat(U32.shrn(L, 2n))
  +r = U32.to_nat(U32.and(L, 3))
  +e1 = Equal.trans(Nat, Nat.add(Nat.mul(q, 4n), r), Nat.add(A.quad(q), r), Nat.add(Nat.mul(m, 4n), 0n),
    Equal.cong(Nat, Nat, z => Nat.add(z, r), Nat.mul(q, 4n), A.quad(q), VC.quad_mul(q)),
    Equal.trans(Nat, Nat.add(A.quad(q), r), U32.to_nat(L), Nat.add(Nat.mul(m, 4n), 0n), Equal.sym(Nat, U32.to_nat(L), Nat.add(A.quad(q), r), VC.split4(L)),
      Equal.trans(Nat, U32.to_nat(L), A.quad(m), Nat.add(Nat.mul(m, 4n), 0n), e,
        Equal.trans(Nat, A.quad(m), Nat.mul(m, 4n), Nat.add(Nat.mul(m, 4n), 0n), Equal.sym(Nat, Nat.mul(m, 4n), A.quad(m), VC.quad_mul(m)),
          Equal.sym(Nat, Nat.add(Nat.mul(m, 4n), 0n), Nat.mul(m, 4n), F.nat__add_zero(Nat.mul(m, 4n)))))))
  +hr = F.nat__le_lt_trans(r, 3n, 4n, RD.and_le(L, 3), {==})
  F.u32__injective(U32.and(L, 3), 0, Pair.snd({q == m : Nat}, {r == 0n : Nat}, VU.dm_unique(q, r, m, 0n, 4n, e1, hr, {==})))

law rng2_q:
  for +m: Nat
  {VD.s_rng(2n, 3n+A.quad(m)) == m : Nat}
def rng2_q(m):
  match m:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, VD.s_rng(2n, 3n+A.quad(p)), p, rng2_q(p)) : {1n+_ == 1n+p : Nat}
      {==}

law hd2:
  for +y: Nat
  {VD.s_h2(Nat.double(y)) == y : Nat}
def hd2(y):
  match y:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, VD.s_h2(Nat.double(p)), p, hd2(p)) : {1n+_ == 1n+p : Nat}
      {==}

def rp(+j: Nat) -> {VD.s_rng(2n, VB.pw(2n+j)) == VB.pw(j) : Nat}:
  %Equal.sym(Nat, VD.s_h2(Nat.double(Nat.double(VB.pw(j)))), Nat.double(VB.pw(j)), hd2(Nat.double(VB.pw(j)))) : {VD.s_h2(_) == VB.pw(j) : Nat}
  hd2(VB.pw(j))

# The validator's check with no element limit (Bool.and(whole, True)).
def whole_t1(+L: U32, +e: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool},
    +hz: {U32.is_zero(e) == False{} : Bool},
    +h: {Bool.and(U32.is_eq(L, U32.mul(U32.div(L, e), e)), True{}) == True{} : Bool})
    -> {U32.to_nat(L) == Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)) : Nat}:
  +h1 = F.logic__and_left(U32.is_eq(L, U32.mul(U32.div(L, e), e)), True{}, h)
  +mv = VU.mul_le(U32.div(L, e), e, L, VU.whole_parts(L, e, v, eb, hb, hz, VU.div_u32(L, e, v, eb, hb, hz)))
  Equal.trans(Nat, U32.to_nat(L), U32.to_nat(U32.mul(U32.div(L, e), e)), Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)),
    Equal.cong(U32, Nat, x => U32.to_nat(x), L, U32.mul(U32.div(L, e), e), F.u32alg__eq_of(L, U32.mul(U32.div(L, e), e), h1)), mv)

def whole_i1go(+L: U32, +e: U32, +c: Nat,
    +ec: {U32.to_nat(L) == Nat.mul(c, U32.to_nat(e)) : Nat},
    +mv: {U32.to_nat(U32.mul(U32.div(L, e), e)) == Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)) : Nat},
    uq: {U32.to_nat(U32.div(L, e)) == c : Nat} & {U32.to_nat(U32.mod(L, e)) == 0n : Nat})
    -> {Bool.and(U32.is_eq(L, U32.mul(U32.div(L, e), e)), True{}) == True{} : Bool}:
  (+eq, +er) = uq
  +M = U32.mul(U32.div(L, e), e)
  +tM = Equal.trans(Nat, U32.to_nat(M), Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), U32.to_nat(L), mv,
    Equal.trans(Nat, Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), Nat.mul(c, U32.to_nat(e)), U32.to_nat(L),
      Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(e)), U32.to_nat(U32.div(L, e)), c, eq), Equal.sym(Nat, U32.to_nat(L), Nat.mul(c, U32.to_nat(e)), ec)))
  +i1 = F.u32alg__eq_true(L, M, F.u32__injective(L, M, Equal.sym(Nat, U32.to_nat(M), U32.to_nat(L), tM)))
  F.logic__and_intro(U32.is_eq(L, M), True{}, i1, {==})

# A whole number of elements passes the check.
def whole_i1(+L: U32, +e: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool},
    +hz: {U32.is_zero(e) == False{} : Bool}, +c: Nat,
    +ec: {U32.to_nat(L) == Nat.mul(c, U32.to_nat(e)) : Nat})
    -> {Bool.and(U32.is_eq(L, U32.mul(U32.div(L, e), e)), True{}) == True{} : Bool}:
  whole_i1go(L, e, c, ec, VU.mul_le(U32.div(L, e), e, L, VU.whole_parts(L, e, v, eb, hb, hz, VU.div_u32(L, e, v, eb, hb, hz))),
    VU.whole_q(L, e, c, ec, hb, VU.div_u32(L, e, v, eb, hb, hz)))

# ---- the depth bound kk(d) for the U32-overflow lemmas of vcopy -----------------------------------

def kj(d: Nat) -> Nat:
  match d:
    case 0n: 4n
    case 1n: 4n
    case 2n: 4n
    case 3n+e: 4n+e

def KK(+d: Nat) -> Nat: 2n+kj(d)

def kk_lt(+d: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}) -> {Nat.is_lt(KK(d), 31n) == True{} : Bool}:
  match d:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n+ +e: hd

def kj_le(+d: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}) -> {Nat.is_le(1n+kj(d), 29n) == True{} : Bool}:
  match d:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n+ +e: F.nat__lt_succ_le(e, 24n, hd)

def kj_ge(+d: Nat) -> {Nat.is_le(4n, kj(d)) == True{} : Bool}:
  match d:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n+ +e: F.nat__zero_le(e)

# 31 + x <= 2^kk(d) for every x <= 4 2^d.
def yl_kk(+d: Nat, +x: Nat, +hx: {Nat.is_le(x, A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(31n, x), VB.pw(KK(d))) == True{} : Bool}:
  match d:
    case 0n: F.nat__le_trans(Nat.add(31n, x), Nat.add(31n, A.quad(VB.pw(0n))), VB.pw(6n), Order.add_left(31n, x, A.quad(VB.pw(0n)), hx), {==})
    case 1n: F.nat__le_trans(Nat.add(31n, x), Nat.add(31n, A.quad(VB.pw(1n))), VB.pw(6n), Order.add_left(31n, x, A.quad(VB.pw(1n)), hx), {==})
    case 2n: F.nat__le_trans(Nat.add(31n, x), Nat.add(31n, A.quad(VB.pw(2n))), VB.pw(6n), Order.add_left(31n, x, A.quad(VB.pw(2n)), hx), {==})
    case 3n+ +e:
      +Q = A.quad(VB.pw(3n+e))
      +h32 = F.nat__double_le(Nat.double(VB.pw(3n)), Nat.double(VB.pw(3n+e)), F.nat__double_le(VB.pw(3n), VB.pw(3n+e), F.nat__pow2_mono(3n, 3n+e, F.nat__zero_le(e))))
      +h31 = F.nat__le_trans(31n, 32n, Q, {==}, h32)
      +hq = Order.add_right(31n, Q, Q, h31)
      +hdq = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, Q), z) == True{} : Bool}, Nat.add(Q, Q), Nat.double(Q), Equal.sym(Nat, Nat.double(Q), Nat.add(Q, Q), F.lru_nat_algebra__double_self(Q)), hq)
      F.nat__le_trans(Nat.add(31n, x), Nat.add(31n, Q), Nat.double(Q), Order.add_left(31n, x, Q, hx), hdq)

# ---- a buffer of n = 4 m bytes ---------------------------------------------------------------------

def DZ(+n: U32) -> Nat: B.words_depth(VC.WZ(n))
def MMg(+t: F.array__Tree<U32>, +n: U32) -> F.array__Tree<U32>: VB.mone(VC.NW(n), 0n, 0n, DZ(n), VC.ZT(DZ(n)), t)

def hyn(+d: Nat, +n: U32, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(VC.YL(n), VB.pw(KK(d))) == True{} : Bool}:
  yl_kk(d, U32.to_nat(n), hn)

def nwm(+d: Nat, +n: U32, +m: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +em: {U32.to_nat(n) == A.quad(m) : Nat}) -> {VC.NW(n) == m : Nat}:
  %Equal.sym(Nat, VC.NW(n), VD.s_rng(2n, 3n+U32.to_nat(n)), VC.eNW(n, KK(d), kk_lt(d, hd), hyn(d, n, hn))) : {_ == m : Nat}
  %Equal.sym(Nat, U32.to_nat(n), A.quad(m), em) : {VD.s_rng(2n, 3n+_) == m : Nat}
  rng2_q(m)

def hsg(+d: Nat, +n: U32, +m: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +em: {U32.to_nat(n) == A.quad(m) : Nat}) -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), F.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %Equal.sym(Nat, VC.NW(n), m, nwm(d, n, m, hd, hn, em)) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  VC.quad_inv(m, VB.pw(d), F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), A.quad(m), em, hn))

# 2^kj(d) + 8 <= 2^(1 + kj(d)).
def pk8(+d: Nat) -> {Nat.is_le(Nat.add(VB.pw(kj(d)), 8n), VB.pw(1n+kj(d))) == True{} : Bool}:
  +P = VB.pw(kj(d))
  +h8 = F.nat__le_trans(8n, 16n, P, {==}, F.nat__pow2_mono(4n, kj(d), kj_ge(d)))
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(P, 8n), z) == True{} : Bool}, Nat.add(P, P), Nat.double(P), Equal.sym(Nat, Nat.double(P), Nat.add(P, P), F.lru_nat_algebra__double_self(P)),
    Order.add_left(P, 8n, P, h8))

def hwz(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.WZ(n)), O.pow2n(1n+kj(d))) == True{} : Bool}:
  +hy = hyn(d, n, hn)
  +hr2 = F.logic__subst(Nat, z => {Nat.is_le(VD.s_rng(2n, VC.YL(n)), z) == True{} : Bool}, VD.s_rng(2n, VB.pw(KK(d))), VB.pw(kj(d)), rp(kj(d)),
    VC.rng_mono(2n, VC.YL(n), VB.pw(KK(d)), hy))
  +hp = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VB.pw(kj(d)), 8n), z) == True{} : Bool}, VB.pw(1n+kj(d)), O.pow2n(1n+kj(d)), VD.s_pow2_eq(1n+kj(d)), pk8(d))
  F.nat__le_trans(U32.to_nat(VC.WZ(n)), Nat.add(VD.s_rng(2n, VC.YL(n)), 8n), O.pow2n(1n+kj(d)),
    VC.wz_le(n, KK(d), kk_lt(d, hd), hy),
    F.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(n)), 8n), Nat.add(VB.pw(kj(d)), 8n), O.pow2n(1n+kj(d)),
      Order.add_right(VD.s_rng(2n, VC.YL(n)), VB.pw(kj(d)), 8n, hr2), hp))

# The decoder's list storage depth is at most 29.
def hdz29(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(DZ(n), 29n) == True{} : Bool}:
  F.nat__le_trans(DZ(n), 1n+kj(d), 29n, VD.wd_min(VC.WZ(n), 1n+kj(d), hwz(d, n, hd, hn)), kj_le(d, hd))

def hrg(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(DZ(n))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), F.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(DZ(n))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(DZ(n)), O.pow2n(DZ(n)), VD.s_pow2_eq(DZ(n))) : {Nat.is_le(VC.NW(n), _) == True{} : Bool}
  F.nat__le_trans(VC.NW(n), U32.to_nat(VC.WZ(n)), O.pow2n(DZ(n)),
    VC.nw_le_wz(n, KK(d), kk_lt(d, hd), hyn(d, n, hn)),
    VD.wd_cover(VC.WZ(n), 1n+kj(d), F.nat__le_trans(1n+kj(d), 29n, 32n, kj_le(d, hd), {==}), hwz(d, n, hd, hn)))

# The spec's four-byte size bound for the buffer's length.
def hfit(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {N.fits(4n, U32.to_nat(n)) == True{} : Bool}:
  VFT.fits4(2n+d, U32.to_nat(n), hn, F.nat__lt_trans(d, 28n, 30n, hd, {==}))

# The buffer's bytes are the limbs of the list storage's first m words.
def lim_eq_g(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +m: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +em: {U32.to_nat(n) == A.quad(m) : Nat})
    -> {FX.limbs(VS.wtake(m, F.array__slots(U32, MMg(t, n)))) == VS.bt(U32.to_nat(n), FX.limbs(F.array__slots(U32, t))) : +List<U32>}:
  +s = F.array__slots(U32, t)
  +Z = F.array__slots(U32, VC.ZT(DZ(n)))
  +LM = VB.lm(VC.NW(n), 0n, 0n, Z, s)
  +hr0 = hrg(d, n, hd, hn)
  +hsl = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(n), 0n), z) == True{} : Bool}, VB.pw(d), VB.len(s), Equal.sym(Nat, VB.len(s), VB.pw(d), F.array__slots_length(U32, d, t, pf)), hsg(d, n, m, hd, hn, em))
  +hz = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(n), 0n), z) == True{} : Bool}, VB.pw(DZ(n)), VB.len(Z),
    Equal.sym(Nat, VB.len(Z), VB.pw(DZ(n)), F.array__slots_length(U32, DZ(n), VC.ZT(DZ(n)), F.array__trep_perfect(U32, DZ(n), 0))), hr0)
  %Equal.sym(Nat, U32.to_nat(n), A.quad(m), em) : {FX.limbs(VS.wtake(m, F.array__slots(U32, MMg(t, n)))) == VS.bt(_, FX.limbs(s)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(m), FX.limbs(s)), FX.limbs(VS.wtake(m, s)), VS.bt_limbs(m, s)) :
    {FX.limbs(VS.wtake(m, F.array__slots(U32, MMg(t, n)))) == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, F.array__slots(U32, MMg(t, n)), LM,
      VB.slots_mone(VC.NW(n), 0n, 0n, DZ(n), VC.ZT(DZ(n)), t, F.array__trep_perfect(U32, DZ(n), 0), hr0)) :
    {FX.limbs(VS.wtake(m, _)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %nwm(d, n, m, hd, hn, em) : {FX.limbs(VS.wtake(_, LM)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(VC.NW(n), VB.wdr(0n, LM)), VS.wtake(VC.NW(n), VB.wdr(0n, s)), VB.lm_win(VC.NW(n), 0n, 0n, Z, s, hz, hsl)) :
    {FX.limbs(_) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(Nat, VC.NW(n), m, nwm(d, n, m, hd, hn, em)) : {FX.limbs(VS.wtake(_, s)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  {==}

# ---- an object whose list holds m words in a tree of depth dw ----------------------------------------

def DO(+N: U32) -> Nat: B.words_depth(VC.nwu(N))
def OUTP(+N: U32, +T: F.array__Tree<U32>) -> F.array__Tree<U32>: VB.mone(VC.NW(N), 0n, 0n, DO(N), VC.ZT(DO(N)), T)

def hNq(+dw: Nat, +N: U32, +m: Nat, +em: {U32.to_nat(N) == A.quad(m) : Nat}, +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(N), A.quad(VB.pw(dw))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(N), A.quad(m), em) : {Nat.is_le(_, A.quad(VB.pw(dw))) == True{} : Bool}
  F.nat__double_le(Nat.double(m), Nat.double(VB.pw(dw)), F.nat__double_le(m, VB.pw(dw), hroom))

def nwo(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 28n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {VC.NW(N) == m : Nat}:
  nwm(dw, N, m, hdw, hNq(dw, N, m, em, hroom), em)

def roomw(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 28n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(N), 0n), VB.pw(dw)) == True{} : Bool}:
  hsg(dw, N, m, hdw, hNq(dw, N, m, em, hroom), em)

def leWo(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 28n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(VC.nwu(N)), O.pow2n(dw)) == True{} : Bool}:
  %Equal.sym(Nat, VC.NW(N), m, nwo(dw, N, m, hdw, em, hroom)) : {Nat.is_le(_, O.pow2n(dw)) == True{} : Bool}
  F.logic__subst(Nat, z => {Nat.is_le(m, z) == True{} : Bool}, VB.pw(dw), O.pow2n(dw), VD.s_pow2_eq(dw), hroom)

# The encoder's output depth is at most dw.
def hDO(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 28n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {Nat.is_le(DO(N), dw) == True{} : Bool}:
  VD.wd_min(VC.nwu(N), dw, leWo(dw, N, m, hdw, em, hroom))

def hdsto(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 28n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(N), 0n), VB.pw(DO(N))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(N), 0n), VC.NW(N), F.nat__add_zero(VC.NW(N))) : {Nat.is_le(_, VB.pw(DO(N))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(DO(N)), O.pow2n(DO(N)), VD.s_pow2_eq(DO(N))) : {Nat.is_le(VC.NW(N), _) == True{} : Bool}
  VD.wd_cover(VC.nwu(N), dw, F.nat__le_trans(dw, 28n, 32n, F.nat__lt_le(dw, 28n, hdw), {==}), leWo(dw, N, m, hdw, em, hroom))

# The encoder's output bytes are the limbs of the list's first m words.
def out_eq_g(+dw: Nat, +T: F.array__Tree<U32>, +N: U32, +m: Nat, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdw: {Nat.is_lt(dw, 28n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat}, +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool})
    -> {VS.bt(U32.to_nat(N), FX.limbs(F.array__slots(U32, OUTP(N, T)))) == FX.limbs(VS.wtake(m, F.array__slots(U32, T))) : +List<U32>}:
  +s = F.array__slots(U32, T)
  +Z = F.array__slots(U32, VC.ZT(DO(N)))
  +LM = VB.lm(VC.NW(N), 0n, 0n, Z, s)
  +hd0 = hdsto(dw, N, m, hdw, em, hroom)
  +hsl = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(N), 0n), z) == True{} : Bool}, VB.pw(dw), VB.len(s), Equal.sym(Nat, VB.len(s), VB.pw(dw), F.array__slots_length(U32, dw, T, pfT)), roomw(dw, N, m, hdw, em, hroom))
  +hz = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(N), 0n), z) == True{} : Bool}, VB.pw(DO(N)), VB.len(Z),
    Equal.sym(Nat, VB.len(Z), VB.pw(DO(N)), F.array__slots_length(U32, DO(N), VC.ZT(DO(N)), F.array__trep_perfect(U32, DO(N), 0))), hd0)
  %Equal.sym(Nat, U32.to_nat(N), A.quad(m), em) : {VS.bt(_, FX.limbs(F.array__slots(U32, OUTP(N, T)))) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(m), FX.limbs(F.array__slots(U32, OUTP(N, T)))), FX.limbs(VS.wtake(m, F.array__slots(U32, OUTP(N, T)))), VS.bt_limbs(m, F.array__slots(U32, OUTP(N, T)))) :
    {_ == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(List<&2, U32>, F.array__slots(U32, OUTP(N, T)), LM,
      VB.slots_mone(VC.NW(N), 0n, 0n, DO(N), VC.ZT(DO(N)), T, F.array__trep_perfect(U32, DO(N), 0), hd0)) :
    {FX.limbs(VS.wtake(m, _)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %nwo(dw, N, m, hdw, em, hroom) : {FX.limbs(VS.wtake(_, LM)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(VC.NW(N), VB.wdr(0n, LM)), VS.wtake(VC.NW(N), VB.wdr(0n, s)), VB.lm_win(VC.NW(N), 0n, 0n, Z, s, hz, hsl)) :
    {FX.limbs(_) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(Nat, VC.NW(N), m, nwo(dw, N, m, hdw, em, hroom)) : {FX.limbs(VS.wtake(_, s)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  {==}

# ---- the same at any tree depth dw < 31, for word-aligned lengths N = 4 m (a U32: 4 m < 2^32, so N + 3 does not wrap) ----

law ltq:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_lt(A.quad(a), A.quad(b)) == True{} : Bool}
  {Nat.is_lt(a, b) == True{} : Bool}
def ltq(a, b, h):
  match a b:
    case _ 0n: Empty.absurd({Nat.is_lt(a, 0n) == True{} : Bool}, F.nat__lt_zero_absurd(A.quad(a), h))
    case 0n 1n+ +q: {==}
    case 1n+ +p 1n+ +q: ltq(p, q, h)

# 4 m < 2^(2+k) gives 3 + 4 m < 2^(2+k).
def q3lt(+k: Nat, +m: Nat, +h: {Nat.is_lt(A.quad(m), F.spec_common__pow2(2n+k)) == True{} : Bool})
    -> {Nat.is_lt(3n+A.quad(m), F.spec_common__pow2(2n+k)) == True{} : Bool}:
  +hm = ltq(m, F.spec_common__pow2(k), h)
  F.nat__lt_le_trans(3n+A.quad(m), A.quad(1n+m), A.quad(F.spec_common__pow2(k)), F.nat__lt_succ(3n+A.quad(m)),
    F.nat__double_le(Nat.double(1n+m), Nat.double(F.spec_common__pow2(k)), F.nat__double_le(1n+m, F.spec_common__pow2(k), F.nat__lt_succ_le_succ(m, F.spec_common__pow2(k), hm))))

# A word-aligned U32 length: (N + 3) >> 2 = m.
def eNWa(+L: U32, +h3: {Nat.is_lt(3n+U32.to_nat(L), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {VC.NW(L) == VD.s_rng(2n, 3n+U32.to_nat(L)) : Nat}:
  %Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), U32.to_nat(U32.add(L, 3)), 3n+U32.to_nat(L), VB.add_lt32(L, 3, U32.to_nat(L), {==}, h3)) :
    {VC.NW(L) == _ : Nat}
  VD.shrk(2n, U32.add(L, 3))

def nwmA(+n: U32, +m: Nat, +em: {U32.to_nat(n) == A.quad(m) : Nat}) -> {VC.NW(n) == m : Nat}:
  +h32 = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(32n)) == True{} : Bool}, U32.to_nat(n), A.quad(m), em, VB.u32_lt(n))
  +h3 = F.logic__subst(Nat, z => {Nat.is_lt(3n+z, F.spec_common__pow2(32n)) == True{} : Bool}, A.quad(m), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), A.quad(m), em), q3lt(30n, m, h32))
  Equal.trans(Nat, VC.NW(n), VD.s_rng(2n, 3n+U32.to_nat(n)), m, eNWa(n, h3),
    F.logic__subst(Nat, z => {VD.s_rng(2n, 3n+z) == m : Nat}, A.quad(m), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), A.quad(m), em), rng2_q(m)))

# ... and N fits four bytes.
def hfitA(+n: U32) -> {N.fits(4n, U32.to_nat(n)) == True{} : Bool}: VFT.fits4lt(U32.to_nat(n), VB.u32_lt(n))

def hsgA(+d: Nat, +n: U32, +m: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +em: {U32.to_nat(n) == A.quad(m) : Nat}) -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), F.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %Equal.sym(Nat, VC.NW(n), m, nwmA(n, m, em)) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  VC.quad_inv(m, VB.pw(d), F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), A.quad(m), em, hn))

def nwoA(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {VC.NW(N) == m : Nat}:
  nwmA(N, m, em)

def roomwA(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(N), 0n), VB.pw(dw)) == True{} : Bool}:
  hsgA(dw, N, m, hdw, hNq(dw, N, m, em, hroom), em)

def leWoA(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(VC.nwu(N)), O.pow2n(dw)) == True{} : Bool}:
  %Equal.sym(Nat, VC.NW(N), m, nwoA(dw, N, m, hdw, em, hroom)) : {Nat.is_le(_, O.pow2n(dw)) == True{} : Bool}
  F.logic__subst(Nat, z => {Nat.is_le(m, z) == True{} : Bool}, VB.pw(dw), O.pow2n(dw), VD.s_pow2_eq(dw), hroom)

def hDOA(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {Nat.is_le(DO(N), dw) == True{} : Bool}:
  VD.wd_min(VC.nwu(N), dw, leWoA(dw, N, m, hdw, em, hroom))

def hdstoA(+dw: Nat, +N: U32, +m: Nat, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat},
    +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(N), 0n), VB.pw(DO(N))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(N), 0n), VC.NW(N), F.nat__add_zero(VC.NW(N))) : {Nat.is_le(_, VB.pw(DO(N))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(DO(N)), O.pow2n(DO(N)), VD.s_pow2_eq(DO(N))) : {Nat.is_le(VC.NW(N), _) == True{} : Bool}
  VD.wd_cover(VC.nwu(N), dw, F.nat__le_trans(dw, 31n, 32n, F.nat__lt_le(dw, 31n, hdw), {==}), leWoA(dw, N, m, hdw, em, hroom))

def out_eq_gA(+dw: Nat, +T: F.array__Tree<U32>, +N: U32, +m: Nat, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +em: {U32.to_nat(N) == A.quad(m) : Nat}, +hroom: {Nat.is_le(m, VB.pw(dw)) == True{} : Bool})
    -> {VS.bt(U32.to_nat(N), FX.limbs(F.array__slots(U32, OUTP(N, T)))) == FX.limbs(VS.wtake(m, F.array__slots(U32, T))) : +List<U32>}:
  +s = F.array__slots(U32, T)
  +Z = F.array__slots(U32, VC.ZT(DO(N)))
  +LM = VB.lm(VC.NW(N), 0n, 0n, Z, s)
  +hd0 = hdstoA(dw, N, m, hdw, em, hroom)
  +hsl = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(N), 0n), z) == True{} : Bool}, VB.pw(dw), VB.len(s), Equal.sym(Nat, VB.len(s), VB.pw(dw), F.array__slots_length(U32, dw, T, pfT)), roomwA(dw, N, m, hdw, em, hroom))
  +hz = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(N), 0n), z) == True{} : Bool}, VB.pw(DO(N)), VB.len(Z),
    Equal.sym(Nat, VB.len(Z), VB.pw(DO(N)), F.array__slots_length(U32, DO(N), VC.ZT(DO(N)), F.array__trep_perfect(U32, DO(N), 0))), hd0)
  %Equal.sym(Nat, U32.to_nat(N), A.quad(m), em) : {VS.bt(_, FX.limbs(F.array__slots(U32, OUTP(N, T)))) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(m), FX.limbs(F.array__slots(U32, OUTP(N, T)))), FX.limbs(VS.wtake(m, F.array__slots(U32, OUTP(N, T)))), VS.bt_limbs(m, F.array__slots(U32, OUTP(N, T)))) :
    {_ == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(List<&2, U32>, F.array__slots(U32, OUTP(N, T)), LM,
      VB.slots_mone(VC.NW(N), 0n, 0n, DO(N), VC.ZT(DO(N)), T, F.array__trep_perfect(U32, DO(N), 0), hd0)) :
    {FX.limbs(VS.wtake(m, _)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %nwoA(dw, N, m, hdw, em, hroom) : {FX.limbs(VS.wtake(_, LM)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(VC.NW(N), VB.wdr(0n, LM)), VS.wtake(VC.NW(N), VB.wdr(0n, s)), VB.lm_win(VC.NW(N), 0n, 0n, Z, s, hz, hsl)) :
    {FX.limbs(_) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  %Equal.sym(Nat, VC.NW(N), m, nwoA(dw, N, m, hdw, em, hroom)) : {FX.limbs(VS.wtake(_, s)) == FX.limbs(VS.wtake(m, s)) : +List<U32>}
  {==}
