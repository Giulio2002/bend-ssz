import Base
import ../src/obj.bend as O
import ../proofs/compact/found_generated.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/nat_order.bend as Order
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vlist.bend as VLS
import ../proofs/obj/vlist.bend as VL
import ../proofs/obj/vu32.bend as VU
import ../proofs/obj/vbrt.bend as VR
import ../proofs/obj/vua_ct.bend as UCT
import ../proofs/obj/elems48_light.bend as E48
import ../proofs/obj/var_winx_l4096_b48_generated.bend as V
import ../proofs/obj/var_plist_proglist_uint32_generated.bend as P32
import ./e2e_bvw_generated.bend as BVW
import ./e2e_bl48_generated.bend as K11
import ./e2e_dep_generated.bend as DEP

# The decoded list of KZG commitments (the reader's object of a window whose check passed): its bytes copied at any byte offset
# (UCT.CT), 48 bytes per element, at most 4096 of them: the root laws' E48.rep_el, the encode premise K11.sdk48 (the tree below
# depth 28) and the length's unit check. Hand written, like e2e_dtx.bend.

def v48() -> Word(31n): FD.spec_numeric__from_nat(31n, 48n)

def cqf(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {V.CHKw(t, x, off, len) == True{} : Bool})
    -> {U32.to_nat(len) == Nat.mul(U32.to_nat(U32.div(len, 48)), U32.to_nat(48)) : Nat} & {Nat.is_le(U32.to_nat(U32.div(len, 48)), U32.to_nat(4096)) == True{} : Bool}:
  VU.whole_t(len, 48, 4096, v48(), {==}, {==}, {==}, hc)

# c <= d gives k c <= k d
def mmono(+k: Nat, +c: Nat, +d: Nat, +h: {Nat.is_le(c, d) == True{} : Bool}) -> {Nat.is_le(Nat.mul(k, c), Nat.mul(k, d)) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+ +p: FD.nat__le_trans(Nat.add(c, Nat.mul(p, c)), Nat.add(d, Nat.mul(p, c)), Nat.add(d, Nat.mul(p, d)), Order.add_right(c, d, Nat.mul(p, c), h), Order.add_left(d, Nat.mul(p, c), Nat.mul(p, d), mmono(p, c, d, h)))

# k (2 x) = 2 (k x)
def mdbl(+k: Nat, +x: Nat) -> {Nat.mul(k, Nat.double(x)) == Nat.double(Nat.mul(k, x)) : Nat}:
  match k:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.mul(p, Nat.double(x)), Nat.double(Nat.mul(p, x)), mdbl(p, x)) : {Nat.add(Nat.double(x), _) == Nat.double(Nat.add(x, Nat.mul(p, x))) : Nat}
      Equal.sym(Nat, Nat.double(Nat.add(x, Nat.mul(p, x))), Nat.add(Nat.double(x), Nat.double(Nat.mul(p, x))), DEP.dadd(x, Nat.mul(p, x)))

# 48 2^k <= 2^(6 + k)
def mpw(+k: Nat) -> {Nat.is_le(Nat.mul(48n, O.pow2n(k)), O.pow2n(Nat.add(6n, k))) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.mul(48n, Nat.double(O.pow2n(p))), Nat.double(Nat.mul(48n, O.pow2n(p))), mdbl(48n, O.pow2n(p))) : {Nat.is_le(_, O.pow2n(Nat.add(6n, 1n+p))) == True{} : Bool}
      FD.nat__double_le(Nat.mul(48n, O.pow2n(p)), O.pow2n(Nat.add(6n, p)), mpw(p))

def hB(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {V.CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(len), O.pow2n(18n)) == True{} : Bool}:
  +e = Pair.fst({U32.to_nat(len) == Nat.mul(U32.to_nat(U32.div(len, 48)), U32.to_nat(48)) : Nat}, {Nat.is_le(U32.to_nat(U32.div(len, 48)), U32.to_nat(4096)) == True{} : Bool}, cqf(t, x, off, len, hc))
  +hk = Pair.snd({U32.to_nat(len) == Nat.mul(U32.to_nat(U32.div(len, 48)), U32.to_nat(48)) : Nat}, {Nat.is_le(U32.to_nat(U32.div(len, 48)), U32.to_nat(4096)) == True{} : Bool}, cqf(t, x, off, len, hc))
  +e2 = Equal.trans(Nat, U32.to_nat(len), Nat.mul(U32.to_nat(U32.div(len, 48)), 48n), Nat.mul(48n, U32.to_nat(U32.div(len, 48))), e, FD.lru_nat_algebra__mul_comm(U32.to_nat(U32.div(len, 48)), 48n))
  +hk2 = FD.nat__le_trans(U32.to_nat(U32.div(len, 48)), 4096n, O.pow2n(12n), hk, {==})
  FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(18n)) == True{} : Bool}, Nat.mul(48n, U32.to_nat(U32.div(len, 48))), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.mul(48n, U32.to_nat(U32.div(len, 48))), e2),
    FD.nat__le_trans(Nat.mul(48n, U32.to_nat(U32.div(len, 48))), Nat.mul(48n, O.pow2n(12n)), O.pow2n(18n), mmono(48n, U32.to_nat(U32.div(len, 48)), O.pow2n(12n), hk2), mpw(12n)))

# 31 + len <= 2^19
def hyB(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), O.pow2n(18n)) == True{} : Bool}) -> {Nat.is_le(VC.YL(len), VB.pw(19n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(VC.YL(len), z) == True{} : Bool}, Nat.add(FD.spec_common__pow2(18n), FD.spec_common__pow2(18n)), VB.pw(19n),
    Equal.trans(Nat, Nat.add(FD.spec_common__pow2(18n), FD.spec_common__pow2(18n)), FD.spec_common__pow2(19n), VB.pw(19n),
      Equal.sym(Nat, Nat.double(FD.spec_common__pow2(18n)), Nat.add(FD.spec_common__pow2(18n), FD.spec_common__pow2(18n)), FD.lru_nat_algebra__double_self(FD.spec_common__pow2(18n))), {==}),
    VC.NA_mono(31n, FD.spec_common__pow2(18n), U32.to_nat(len), FD.spec_common__pow2(18n), FD.nat__le_trans(31n, FD.spec_common__pow2(5n), FD.spec_common__pow2(18n), {==}, FD.nat__pow2_mono(5n, 18n, {==})),
      FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(len), z) == True{} : Bool}, O.pow2n(18n), FD.spec_common__pow2(18n), VD.s_pow2_eq(18n), hb)))

# the storage is at most 2^18 words: (31 + len) >> 2 + 8 <= 2^17 + 8
def hWZ(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), O.pow2n(18n)) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(VC.WZ(len)), O.pow2n(18n)) == True{} : Bool}:
  +hr = FD.logic__subst(Nat, z => {Nat.is_le(VD.s_rng(2n, VC.YL(len)), z) == True{} : Bool}, VD.s_rng(2n, VB.pw(2n+17n)), FD.spec_common__pow2(17n), VL.rp(17n),
    VC.rng_mono(2n, VC.YL(len), VB.pw(2n+17n), hyB(len, hb)))
  +h8 = FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(FD.spec_common__pow2(17n), 8n), Nat.add(FD.spec_common__pow2(17n), FD.spec_common__pow2(17n)),
    Order.add_right(VD.s_rng(2n, VC.YL(len)), FD.spec_common__pow2(17n), 8n, hr),
    Order.add_left(FD.spec_common__pow2(17n), 8n, FD.spec_common__pow2(17n), FD.nat__pow2_mono(3n, 17n, {==})))
  +h18 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), z) == True{} : Bool}, Nat.add(FD.spec_common__pow2(17n), FD.spec_common__pow2(17n)), O.pow2n(18n),
    Equal.trans(Nat, Nat.add(FD.spec_common__pow2(17n), FD.spec_common__pow2(17n)), FD.spec_common__pow2(18n), O.pow2n(18n),
      Equal.sym(Nat, Nat.double(FD.spec_common__pow2(17n)), Nat.add(FD.spec_common__pow2(17n), FD.spec_common__pow2(17n)), FD.lru_nat_algebra__double_self(FD.spec_common__pow2(17n))),
      VD.s_pow2_eq(18n)),
    h8)
  FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(18n), VC.wz_le(len, 19n, {==}, hyB(len, hb)), h18)

def hdzK(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), O.pow2n(18n)) == True{} : Bool}) -> {Nat.is_le(VLS.DZ(len), 18n) == True{} : Bool}:
  VD.wd_min(VC.WZ(len), 18n, hWZ(len, hb))

def hrgB(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), O.pow2n(18n)) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(len), 0n), VB.pw(VLS.DZ(len))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(len), 0n), VC.NW(len), FD.nat__add_zero(VC.NW(len))) : {Nat.is_le(_, VB.pw(VLS.DZ(len))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(VLS.DZ(len)), O.pow2n(VLS.DZ(len)), VD.s_pow2_eq(VLS.DZ(len))) : {Nat.is_le(VC.NW(len), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(len), U32.to_nat(VC.WZ(len)), O.pow2n(VLS.DZ(len)), VC.nw_le_wz(len, 19n, {==}, hyB(len, hb)), VD.wd_cover(VC.WZ(len), 18n, {==}, hWZ(len, hb)))

# the unit check: the byte count is a whole number of commitments
def hvK(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {V.CHKw(t, x, off, len) == True{} : Bool}) -> {O.unit_ok(48, len) == True{} : Bool}:
  +ec = Pair.fst({U32.to_nat(len) == Nat.mul(U32.to_nat(U32.div(len, 48)), U32.to_nat(48)) : Nat}, {Nat.is_le(U32.to_nat(U32.div(len, 48)), U32.to_nat(4096)) == True{} : Bool}, cqf(t, x, off, len, hc))
  +er = Pair.snd({U32.to_nat(U32.div(len, 48)) == U32.to_nat(U32.div(len, 48)) : Nat}, {U32.to_nat(U32.mod(len, 48)) == 0n : Nat},
    VU.whole_q(len, 48, U32.to_nat(U32.div(len, 48)), ec, {==}, VU.div_u32(len, 48, v48(), {==}, {==}, {==})))
  FD.u32alg__eq_true(U32.mod(len, 48), 0, FD.u32__injective(U32.mod(len, 48), 0, er))

# the decoded object's storage: perfect of depth DZ(len) < 32 holding k48(len) 12-word commitments
def wfK(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {V.CHKw(t, x, off, len) == True{} : Bool}) -> E48.wfe(V.OBJw(d, t, x, off, len)):
  +hb = hB(t, x, off, len, hc)
  +ec = Pair.fst({U32.to_nat(len) == Nat.mul(U32.to_nat(U32.div(len, 48)), U32.to_nat(48)) : Nat}, {Nat.is_le(U32.to_nat(U32.div(len, 48)), U32.to_nat(4096)) == True{} : Bool}, cqf(t, x, off, len, hc))
  +hy = FD.nat__le_trans(VC.YL(len), VB.pw(19n), U32.to_nat(VB.UMAX()), hyB(len, hb), {==})
  +eq4 = Equal.trans(Nat, U32.to_nat(len), Nat.mul(E48.k48(len), 48n), A.quad(Nat.mul(E48.k48(len), 12n)), ec, Equal.sym(Nat, A.quad(Nat.mul(E48.k48(len), 12n)), Nat.mul(E48.k48(len), 48n), DEP.qmul(E48.k48(len), 12n)))
  +enw = P32.nwmU(len, Nat.mul(E48.k48(len), 12n), hy, eq4)
  +hr = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 0n), VB.pw(VLS.DZ(len))) == True{} : Bool}, VC.NW(len), Nat.mul(E48.k48(len), 12n), enw, hrgB(len, hb))
  (UCT.CT(d, t, off, len, VLS.DZ(len)), (VLS.DZ(len), (len, ({==}, (BVW.ctps(VR.RX(off), d, t, off, len, VLS.DZ(len)),
    (FD.nat__le_lt_trans(VLS.DZ(len), 18n, 32n, hdzK(len, hb), {==}),
     FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(VLS.DZ(len))) == True{} : Bool}, Nat.add(Nat.mul(E48.k48(len), 12n), 0n), Nat.mul(E48.k48(len), 12n), FD.nat__add_zero(Nat.mul(E48.k48(len), 12n)), hr)))))))

def skK(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {V.CHKw(t, x, off, len) == True{} : Bool}) -> K11.sdk48(V.OBJw(d, t, x, off, len)):
  (UCT.CT(d, t, off, len, VLS.DZ(len)), (VLS.DZ(len), (len, ({==}, (BVW.ctps(VR.RX(off), d, t, off, len, VLS.DZ(len)),
    FD.nat__le_lt_trans(VLS.DZ(len), 18n, 28n, hdzK(len, hB(t, x, off, len, hc)), {==}))))))

def cnK(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {V.CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(E48.k48(len), 4096n) == True{} : Bool}:
  Pair.snd({U32.to_nat(len) == Nat.mul(U32.to_nat(U32.div(len, 48)), U32.to_nat(48)) : Nat}, {Nat.is_le(U32.to_nat(U32.div(len, 48)), U32.to_nat(4096)) == True{} : Bool}, cqf(t, x, off, len, hc))
