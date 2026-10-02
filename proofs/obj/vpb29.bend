import Base
import ../../src/obj.bend as O
import ../compact/found_generated.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vdepth.bend as VD
import ./vlist.bend as VL

# The progressive bit list's representation bound. Its validator (O.bitlist_pick with no
# declared limit) accepts a window of len bytes only when len - 1 < 2^29 (536870912):
# the decoded bit count 8 (len - 1) + the delimiter's high bit is a U32 exactly then.
# Every window of a buffer on a word tree of depth d < 28 (len <= 4 2^d <= 2^29) passes,
# proved symbolically in d (the one closed power, 2^29, is only ever compared syntactically).

def lt29(+d: Nat, +len: U32, +m: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hl: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(len) == 1n+m : Nat})
    -> {U32.is_lt(U32.sub(len, 1), 536870912) == True{} : Bool}:
  # len <= 4 2^d = 2^(2+d) <= 2^29
  +hq = FD.nat__le_trans(U32.to_nat(len), FD.spec_common__pow2(2n+d), FD.spec_common__pow2(29n), hl,
    FD.nat__pow2_mono(2n+d, 29n, FD.nat__lt_succ_le(d, 27n, hd)))
  +h1m = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(29n)) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hq)
  +hm = FD.nat__succ_le_lt(m, FD.spec_common__pow2(29n), h1m)
  # U32.to_nat(len - 1) == m
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1),
    FD.nat__zero_le(m))
  +es = Equal.trans(Nat, U32.to_nat(U32.sub(len, 1)), Nat.sub(U32.to_nat(len), 1n), m,
    FD.u32__sub_nat(len, 1, h1),
    FD.logic__subst(Nat, z => {Nat.sub(z, 1n) == m : Nat}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1), FD.nat__add_sub_cancel(1n, m)))
  +hs = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(29n)) == True{} : Bool}, m, U32.to_nat(U32.sub(len, 1)), Equal.sym(Nat, U32.to_nat(U32.sub(len, 1)), m, es), hm)
  # the U32 comparison, through 2^29 == pow2u(29)
  Equal.trans(Bool, U32.is_lt(U32.sub(len, 1), FD.u32__pow2u(29n)), Nat.is_lt(U32.to_nat(U32.sub(len, 1)), FD.spec_common__pow2(29n)), True{},
    Equal.sym(Bool, Nat.is_lt(U32.to_nat(U32.sub(len, 1)), FD.spec_common__pow2(29n)), U32.is_lt(U32.sub(len, 1), FD.u32__pow2u(29n)),
      FD.array__lt_bridge(U32.sub(len, 1), 29n, {==}, U32.is_lt(U32.sub(len, 1), FD.u32__pow2u(29n)), {==})),
    hs)

# ---- the decoder's list storage for a window the check accepts (len - 1 < 2^29), any tree depth ----

def em1(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}) -> {U32.to_nat(U32.sub(n, 1)) == m : Nat}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+m, U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), 1n+m, e1), FD.nat__zero_le(m))
  Equal.trans(Nat, U32.to_nat(U32.sub(n, 1)), Nat.sub(U32.to_nat(n), 1n), m, FD.u32__sub_nat(n, 1, h1),
    FD.logic__subst(Nat, z => {Nat.sub(z, 1n) == m : Nat}, 1n+m, U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), 1n+m, e1), FD.nat__add_sub_cancel(1n, m)))

# n <= 2^29.
def le29(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}, +h29: {U32.is_lt(U32.sub(n, 1), 536870912) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(n), FD.spec_common__pow2(29n)) == True{} : Bool}:
  +hb = Equal.trans(Bool, Nat.is_lt(U32.to_nat(U32.sub(n, 1)), FD.spec_common__pow2(29n)), U32.is_lt(U32.sub(n, 1), FD.u32__pow2u(29n)), True{},
    FD.array__lt_bridge(U32.sub(n, 1), 29n, {==}, U32.is_lt(U32.sub(n, 1), FD.u32__pow2u(29n)), {==}), h29)
  +hm = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(29n)) == True{} : Bool}, U32.to_nat(U32.sub(n, 1)), m, em1(n, m, e1), hb)
  FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(29n)) == True{} : Bool}, 1n+m, U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), 1n+m, e1),
    FD.nat__lt_succ_le_succ(m, FD.spec_common__pow2(29n), hm))

# 31 + n <= 2^30.
def hyP(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}, +h29: {U32.is_lt(U32.sub(n, 1), 536870912) == True{} : Bool})
    -> {Nat.is_le(VC.YL(n), VB.pw(30n)) == True{} : Bool}:

  FD.logic__subst(Nat, z => {Nat.is_le(VC.YL(n), z) == True{} : Bool}, Nat.add(FD.spec_common__pow2(29n), FD.spec_common__pow2(29n)), VB.pw(30n),
    Equal.sym(Nat, Nat.double(FD.spec_common__pow2(29n)), Nat.add(FD.spec_common__pow2(29n), FD.spec_common__pow2(29n)), FD.lru_nat_algebra__double_self(FD.spec_common__pow2(29n))),
    VC.NA_mono(31n, FD.spec_common__pow2(29n), U32.to_nat(n), FD.spec_common__pow2(29n), FD.nat__le_trans(31n, FD.spec_common__pow2(5n), FD.spec_common__pow2(29n), {==}, FD.nat__pow2_mono(5n, 29n, {==})),
      le29(n, m, e1, h29)))

# The storage is at most 2^29 words: ((31 + n) >> 5) 8 + 8 <= 2^28 + 8.
def hWZP(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}, +h29: {U32.is_lt(U32.sub(n, 1), 536870912) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.WZ(n)), O.pow2n(29n)) == True{} : Bool}:

  +hr = FD.logic__subst(Nat, z => {Nat.is_le(VD.s_rng(2n, VC.YL(n)), z) == True{} : Bool}, VD.s_rng(2n, VB.pw(2n+28n)), FD.spec_common__pow2(28n), VL.rp(28n),
    VC.rng_mono(2n, VC.YL(n), VB.pw(2n+28n), hyP(n, m, e1, h29)))
  +h8 = FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(n)), 8n), Nat.add(FD.spec_common__pow2(28n), 8n), Nat.add(FD.spec_common__pow2(28n), FD.spec_common__pow2(28n)),
    Order.add_right(VD.s_rng(2n, VC.YL(n)), FD.spec_common__pow2(28n), 8n, hr),
    Order.add_left(FD.spec_common__pow2(28n), 8n, FD.spec_common__pow2(28n), FD.nat__pow2_mono(3n, 28n, {==})))
  +h29w = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(VD.s_rng(2n, VC.YL(n)), 8n), z) == True{} : Bool}, Nat.add(FD.spec_common__pow2(28n), FD.spec_common__pow2(28n)), O.pow2n(29n),
    Equal.trans(Nat, Nat.add(FD.spec_common__pow2(28n), FD.spec_common__pow2(28n)), FD.spec_common__pow2(29n), O.pow2n(29n),
      Equal.sym(Nat, Nat.double(FD.spec_common__pow2(28n)), Nat.add(FD.spec_common__pow2(28n), FD.spec_common__pow2(28n)), FD.lru_nat_algebra__double_self(FD.spec_common__pow2(28n))),
      VD.s_pow2_eq(29n)),
    h8)
  FD.nat__le_trans(U32.to_nat(VC.WZ(n)), Nat.add(VD.s_rng(2n, VC.YL(n)), 8n), O.pow2n(29n), VC.wz_le(n, 30n, {==}, hyP(n, m, e1, h29)), h29w)

def hdzP(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}, +h29: {U32.is_lt(U32.sub(n, 1), 536870912) == True{} : Bool})
    -> {Nat.is_le(VL.DZ(n), 29n) == True{} : Bool}:
  VD.wd_min(VC.WZ(n), 29n, hWZP(n, m, e1, h29))

def hrgP(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}, +h29: {U32.is_lt(U32.sub(n, 1), 536870912) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(VL.DZ(n))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), FD.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(VL.DZ(n))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(VL.DZ(n)), O.pow2n(VL.DZ(n)), VD.s_pow2_eq(VL.DZ(n))) : {Nat.is_le(VC.NW(n), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(n), U32.to_nat(VC.WZ(n)), O.pow2n(VL.DZ(n)), VC.nw_le_wz(n, 30n, {==}, hyP(n, m, e1, h29)), VD.wd_cover(VC.WZ(n), 29n, {==}, hWZP(n, m, e1, h29)))

# ---- the progressive bit list's own input limit -----------------------------------------------
# PMAX = 2^29: the runtime's progressive bit list accepts no longer window (its bit count is a U32),
# so a valid spec encoding longer than PMAX bytes is refused: decode_reject takes n <= PMAX.
def PMAX() -> U32: 536870912

def lt29P(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}, +hP: {U32.is_le(n, PMAX()) == True{} : Bool})
    -> {U32.is_lt(U32.sub(n, 1), 536870912) == True{} : Bool}:
  +hn = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(n, PMAX()), Nat.is_le(U32.to_nat(n), U32.to_nat(PMAX())), VB.le_u32n(n, PMAX()), hP)
  +hm = FD.nat__succ_le_lt(m, U32.to_nat(PMAX()), FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(PMAX())) == True{} : Bool}, U32.to_nat(n), 1n+m, e1, hn))
  +hs = FD.logic__subst(Nat, z => {Nat.is_lt(z, U32.to_nat(PMAX())) == True{} : Bool}, m, U32.to_nat(U32.sub(n, 1)), Equal.sym(Nat, U32.to_nat(U32.sub(n, 1)), m, em1(n, m, e1)), hm)
  Equal.trans(Bool, U32.is_lt(U32.sub(n, 1), PMAX()), Nat.is_lt(U32.to_nat(U32.sub(n, 1)), U32.to_nat(PMAX())), True{},
    VB.lt_u32n(U32.sub(n, 1), PMAX()), hs)
