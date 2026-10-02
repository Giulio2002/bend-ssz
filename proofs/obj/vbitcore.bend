import Base
import ../../spec/bit_packing.bend as Bp
import ../compact/found_generated.bend as F
import ./spec_fixed.bend as FX
import ./bitlist_pack_generated.bend as BK
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./dk.bend as DK
import ./vdepth.bend as VD
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./vcopy.bend as VC
import ./vbenc.bend as VBE
import ./vbytes.bend as VY
import ./vbitenc.bend as VBT
import ./vbitdl.bend as DL
import ./var_bits_enc_bw_generated.bend as BW
import ../../src/obj.bend as O
import ../../src/buffer.bend as B

# The bit list writer at offset 0 of a zero tree of depth DO: O.put_bits_n
# returns the explicit tree DL.OZ and the size K / 8 + 1, and those bytes of the
# tree pack the object's bits and the delimiter.

def NK(+K: U32) -> U32: U32.add(U32.shrn(K, 3n), 1)
def BITS(+T: F.array__Tree<U32>, +K: U32) -> +List<Bool>: BK.btk(U32.to_nat(K), BK.bitsof(F.array__slots(U32, T)))

def cwle(+r: Nat) -> {Nat.is_le(BW.CWr(r), 1n) == True{} : Bool}:
  match r:
    case 0n: {==}
    case 1n+ +p: {==}

def CR(+dd: Nat, +T: F.array__Tree<U32>, +K: U32) -> Data:
  DK.P2({O.put_bits_n(F.array__thaw(U32, VC.ZT(dd)), 0, O.Bits{F.array__thaw(U32, T), K})
          == (F.array__thaw(U32, DL.OZ(dd, T, K)), (O.Bits{F.array__thaw(U32, T), K}, NK(K))) : Array<U32> & (O.Bits & U32)},
        DK.P2({Bp.pack(List.append(&2, Bool, BITS(T, K), [True{}])) == VS.bt(U32.to_nat(NK(K)), FX.limbs(F.array__slots(U32, DL.OZ(dd, T, K)))) : +List<U32>},
          {List.length(&2, Bool, BITS(T, K)) == U32.to_nat(K) : Nat}))

def enc_core2(+DO: Nat, +dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hDO: {Nat.is_lt(DO, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hDq: {Nat.is_le(Nat.add(VBT.QK(K), 1n), VB.pw(DO)) == True{} : Bool},
    +hWq: {Nat.is_le(Nat.add(VBT.QK(K), 1n), VB.pw(dw)) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool})
    -> CR(DO, T, K):
  +q = VBT.QK(K)
  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +r = DL.RK(K)
  +NB = VC.NW(O.bits_nbytes(K))
  +hK = F.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  +hj = F.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = F.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)
  +cA = DL.p1(DL.TA(j, b), DL.CB(j, b), cf)
  +cB = DL.p1(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf))
  +cF = DL.p2(DL.TE(j, b), DL.TF(j, b), DL.p2(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf)))))
  +eNW = Equal.trans(Nat, NB, Nat.add(q, VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n))), Nat.add(q, BW.CWr(r)),
    VBT.FNWnb(K, kb, hkb, hK, j, b, Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), {==}, {==}, {==}, cB, {==}),
    Equal.cong(Nat, Nat, z => Nat.add(q, z), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), BW.CWr(r), cA))
  +hNW0 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(q, 1n)) == True{} : Bool}, Nat.add(q, BW.CWr(r)), Nat.add(NB, 0n),
    Equal.sym(Nat, Nat.add(NB, 0n), Nat.add(q, BW.CWr(r)), Equal.trans(Nat, Nat.add(NB, 0n), NB, Nat.add(q, BW.CWr(r)), F.nat__add_zero(NB), eNW)),
    Order.add_left(q, BW.CWr(r), 1n, cwle(r)))
  +hnd = F.nat__le_trans(Nat.add(NB, 0n), Nat.add(q, 1n), VB.pw(DO), hNW0, hDq)
  +hns = F.nat__le_trans(Nat.add(NB, 0n), Nat.add(q, 1n), VB.pw(dw), hNW0, hWq)
  +hqd = F.nat__lt_le_trans(q, Nat.add(q, 1n), VB.pw(DO), DL.lt_add1(q), hDq)
  +hqs = F.nat__lt_le_trans(q, Nat.add(q, 1n), VB.pw(dw), DL.lt_add1(q), hWq)
  # 31 + nb <= 2^30
  +e3 = VBT.E3(K, kb, hkb, hK)
  +hnb = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(VBT.AK(K), 1n)) == True{} : Bool}, Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n))), U32.to_nat(O.bits_nbytes(K)),
    Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n))), e3), Order.add_left(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n)), 1n, cB))
  +hy = VBT.y30(K, kb, hkb, hK, hnb)
  +pfZ = F.array__trep_perfect(U32, DO, 0)
  +pb = VBT.put_bits2(DO, dw, VC.ZT(DO), T, 0, 0n, K, q, 30n, pfZ, pfT, hDO, hdw, {==}, {==}, {==}, hy, hns, hnd,
    VBE.slot_zt(DO, Nat.add(VY.QL(O.bits_nbytes(K)), 0n)), {==}, hqd)
  +ev = Equal.cong(Array<U32> & O.Bits, Array<U32> & (O.Bits & U32), z => O.pbn(z),
    O.put_bits(F.array__thaw(U32, VC.ZT(DO)), 0, O.Bits{F.array__thaw(U32, T), K}), (F.array__thaw(U32, DL.OZ(DO, T, K)), O.Bits{F.array__thaw(U32, T), K}), pb)
  # the bytes
  +wp = DL.words_pack(DO, dw, T, K, kb, pfT, hkb, hK, hnd, hns, hqd, hqs, hz)
  +W = F.array__slots(U32, DL.OZ(DO, T, K))
  +S = F.array__slots(U32, T)
  +eBC = Equal.trans(Nat, Bp.byte_count(Nat.add(VBT.m32(q), 1n+r)), Nat.add(A.quad(q), Bp.byte_count(1n+r)), U32.to_nat(NK(K)),
    VBT.bc32(q, 1n+r),
    Equal.trans(Nat, Nat.add(A.quad(q), Bp.byte_count(1n+r)), Nat.add(A.quad(q), Nat.add(j, 1n)), U32.to_nat(NK(K)),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(q), z), Bp.byte_count(1n+r), Nat.add(j, 1n), cF),
      Equal.sym(Nat, U32.to_nat(NK(K)), Nat.add(A.quad(q), Nat.add(j, 1n)), VBT.G4(K, kb, hkb, hK, j, {==}))))
  +wp2 = F.logic__subst(Nat, z => {Bp.pack(List.append(&2, Bool, BK.btk(Nat.add(VBT.m32(q), r), BK.bitsof(S)), [True{}])) == VS.bt(z, FX.limbs(W)) : +List<U32>},
    Bp.byte_count(Nat.add(VBT.m32(q), 1n+r)), U32.to_nat(NK(K)), eBC, wp)
  +wp3 = F.logic__subst(Nat, z => {Bp.pack(List.append(&2, Bool, BK.btk(z, BK.bitsof(S)), [True{}])) == VS.bt(U32.to_nat(NK(K)), FX.limbs(W)) : +List<U32>},
    Nat.add(VBT.m32(q), r), U32.to_nat(K), Equal.sym(Nat, U32.to_nat(K), Nat.add(VBT.m32(q), r), VBT.Ka(K, kb, hkb, hK, j, b, {==}, {==})), wp2)
  # all K bits are in the storage: K = 32 q + r <= 32 (q + 1) <= 32 2^dw
  +cE = DL.p1(DL.TE(j, b), DL.TF(j, b), DL.p2(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf)))))
  +eK = VBT.Ka(K, kb, hkb, hK, j, b, {==}, {==})
  +h1q = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, Nat.add(q, 1n), 1n+q, F.nat__add_comm(q, 1n), hWq)
  +hKm = F.logic__subst(Nat, z => {Nat.is_le(z, VBT.m32(1n+q)) == True{} : Bool}, Nat.add(VBT.m32(q), r), U32.to_nat(K), Equal.sym(Nat, U32.to_nat(K), Nat.add(VBT.m32(q), r), eK),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VBT.m32(q), r), z) == True{} : Bool}, Nat.add(VBT.m32(q), 32n), VBT.m32(1n+q), F.nat__add_comm(VBT.m32(q), 32n),
      Order.add_left(VBT.m32(q), r, 32n, F.nat__le_trans(r, 31n, 32n, cE, {==}))))
  +hKS = F.nat__le_trans(U32.to_nat(K), VBT.m32(1n+q), List.length(&2, Bool, BK.bitsof(S)), hKm,
    F.logic__subst(Nat, z => {Nat.is_le(VBT.m32(1n+q), z) == True{} : Bool}, VBT.m32(VB.len(S)), List.length(&2, Bool, BK.bitsof(S)), Equal.sym(Nat, List.length(&2, Bool, BK.bitsof(S)), VBT.m32(VB.len(S)), VBT.len_bitsof(S)),
      F.logic__subst(Nat, z => {Nat.is_le(VBT.m32(1n+q), VBT.m32(z)) == True{} : Bool}, VB.pw(dw), VB.len(S), Equal.sym(Nat, VB.len(S), VB.pw(dw), F.array__slots_length(U32, dw, T, pfT)),
        VBT.m32_mono(1n+q, VB.pw(dw), h1q))))
  (ev, (wp3, VBT.len_btk(U32.to_nat(K), BK.bitsof(S), hKS)))


def enc_core(+DO: Nat, +dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +KY: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hDO: {Nat.is_lt(DO, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hKY: {Nat.is_lt(KY, 31n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNY: {Nat.is_le(Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY)) == True{} : Bool},
    +hDq: {Nat.is_le(Nat.add(VBT.QK(K), 1n), VB.pw(DO)) == True{} : Bool},
    +hWq: {Nat.is_le(Nat.add(VBT.QK(K), 1n), VB.pw(dw)) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool})
    -> CR(DO, T, K):
  enc_core2(DO, dw, T, K, kb, N, pfT, hDO, hdw, hkb, hN, hNk, hDq, hWq, hz)


# ---- the two encoder shapes ----------------------------------------------------------------------

def TQ(+K: U32) -> Data: {U32.to_nat(U32.shrn(K, 5n)) == VBT.QK(K) : Nat}

# K >> 5 is the word index q.
def eq5(+K: U32, +kb: Nat, +N: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool}) -> TQ(K):
  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +hK = F.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  +hj = F.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = F.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)
  +cC = DL.p1(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf)))
  Equal.trans(Nat, U32.to_nat(U32.shrn(K, 5n)), Nat.add(VBT.QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))), VBT.QK(K), VBT.G6(K, kb, hkb, hK, j, b, {==}, {==}),
    Equal.trans(Nat, Nat.add(VBT.QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))), Nat.add(VBT.QK(K), 0n), VBT.QK(K),
      Equal.cong(Nat, Nat, z => Nat.add(VBT.QK(K), z), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b))), 0n, cC), F.nat__add_zero(VBT.QK(K))))

# q <= N >> 5.
def qle(+K: U32, +kb: Nat, +N: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VBT.QK(K), 1n), Nat.add(VD.s_rng(5n, N), 1n)) == True{} : Bool}:
  +e = Equal.trans(Nat, VBT.QK(K), U32.to_nat(U32.shrn(K, 5n)), VD.s_rng(5n, U32.to_nat(K)), Equal.sym(Nat, U32.to_nat(U32.shrn(K, 5n)), VBT.QK(K), eq5(K, kb, N, hkb, hN, hNk)), VD.shrk(5n, K))
  Order.add_right(VBT.QK(K), VD.s_rng(5n, N), 1n,
    F.logic__subst(Nat, z => {Nat.is_le(z, VD.s_rng(5n, N)) == True{} : Bool}, VD.s_rng(5n, U32.to_nat(K)), VBT.QK(K), Equal.sym(Nat, VBT.QK(K), VD.s_rng(5n, U32.to_nat(K)), e),
      VC.rng_mono(5n, U32.to_nat(K), N, hN)))

def pw_pos(+d: Nat) -> {Nat.is_le(1n, VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, VB.pw(d), O.pow2n(d), VD.s_pow2_eq(d)) : {Nat.is_le(1n, _) == True{} : Bool}
  VD.s_pow2_pos(d)

# A bit list of at most 31 bits: one output word (O.out_at(0n)).
def enc_small(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +KY: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hKY: {Nat.is_lt(KY, 31n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNY: {Nat.is_le(Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY)) == True{} : Bool},
    +hN5: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), 1n) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool})
    -> CR(0n, T, K):
  +q1 = F.nat__le_trans(Nat.add(VBT.QK(K), 1n), Nat.add(VD.s_rng(5n, N), 1n), 1n, qle(K, kb, N, hkb, hN, hNk), hN5)
  enc_core(0n, dw, T, K, kb, KY, N, pfT, {==}, hdw, hkb, hKY, hN, hNk, hNY, q1,
    F.nat__le_trans(Nat.add(VBT.QK(K), 1n), 1n, VB.pw(dw), q1, pw_pos(dw)), hz)

def enc_small2(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hN5: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), 1n) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool})
    -> CR(0n, T, K):
  +q1 = F.nat__le_trans(Nat.add(VBT.QK(K), 1n), Nat.add(VD.s_rng(5n, N), 1n), 1n, qle(K, kb, N, hkb, hN, hNk), hN5)
  enc_core2(0n, dw, T, K, kb, N, pfT, {==}, hdw, hkb, hN, hNk, q1,
    F.nat__le_trans(Nat.add(VBT.QK(K), 1n), 1n, VB.pw(dw), q1, pw_pos(dw)), hz)

# The runtime's capacity check (O.bsz_pick) passes.
def capT(+K: U32, +dw: Nat, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool})
    -> {U32.is_le(U32.add(U32.shrn(K, 5n), 1), F.u32__pow2u(dw)) == True{} : Bool}:
  +hdw32 = F.nat__lt_le_trans(dw, 31n, 32n, hdw, {==})
  +bd = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), z) == True{} : Bool}, VB.pw(dw), O.pow2n(dw), VD.s_pow2_eq(dw), hcap)
  +eL = VD.s_add_nat(U32.shrn(K, 5n), 1, dw, hdw32, bd)
  +eR = F.u32__pow2u_value(dw, hdw32)
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), U32.to_nat(U32.add(U32.shrn(K, 5n), 1)), Equal.sym(Nat, U32.to_nat(U32.add(U32.shrn(K, 5n), 1)), Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), eL), hcap)
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(U32.add(U32.shrn(K, 5n), 1)), z) == True{} : Bool}, VB.pw(dw), U32.to_nat(F.u32__pow2u(dw)), Equal.sym(Nat, U32.to_nat(F.u32__pow2u(dw)), VB.pw(dw), eR), h1)
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(U32.add(U32.shrn(K, 5n), 1)), U32.to_nat(F.u32__pow2u(dw))), U32.is_le(U32.add(U32.shrn(K, 5n), 1), F.u32__pow2u(dw)),
    Equal.sym(Bool, U32.is_le(U32.add(U32.shrn(K, 5n), 1), F.u32__pow2u(dw)), Nat.is_le(U32.to_nat(U32.add(U32.shrn(K, 5n), 1)), U32.to_nat(F.u32__pow2u(dw))), VD.s_le_nat(U32.add(U32.shrn(K, 5n), 1), F.u32__pow2u(dw))), h2)

# The output depth of a sized encoding (O.out_new of K / 8 + 1 bytes).
def DOK(+K: U32) -> Nat: B.words_depth(VC.nwu(NK(K)))

def nwNK(+K: U32, +kb: Nat, +N: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool})
    -> {VC.NW(NK(K)) == Nat.add(VBT.QK(K), 1n) : Nat}:
  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +hK = F.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  +hj = F.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = F.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)
  +cD = DL.p1(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf))))
  VBT.FNWn(K, kb, hkb, hK, j, {==}, cD)

def hwO(+K: U32, +kb: Nat, +KO: Nat, +N: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNO: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), O.pow2n(KO)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.nwu(NK(K))), O.pow2n(KO)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(KO)) == True{} : Bool}, Nat.add(VBT.QK(K), 1n), U32.to_nat(VC.nwu(NK(K))),
    Equal.sym(Nat, U32.to_nat(VC.nwu(NK(K))), Nat.add(VBT.QK(K), 1n), nwNK(K, kb, N, hkb, hN, hNk)),
    F.nat__le_trans(Nat.add(VBT.QK(K), 1n), Nat.add(VD.s_rng(5n, N), 1n), O.pow2n(KO), qle(K, kb, N, hkb, hN, hNk), hNO))

def hDOK(+K: U32, +kb: Nat, +KO: Nat, +N: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNO: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), O.pow2n(KO)) == True{} : Bool})
    -> {Nat.is_le(DOK(K), KO) == True{} : Bool}:
  VD.wd_min(VC.nwu(NK(K)), KO, hwO(K, kb, KO, N, hkb, hN, hNk, hNO))

# A bit list of any size: the zero tree of depth DOK(K), after the capacity check.
def enc_sized(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +KY: Nat, +KO: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hKY: {Nat.is_lt(KY, 31n) == True{} : Bool}, +hKO: {Nat.is_lt(KO, 31n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNY: {Nat.is_le(Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY)) == True{} : Bool},
    +hNO: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), O.pow2n(KO)) == True{} : Bool},
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool})
    -> CR(DOK(K), T, K):
  +hw = hwO(K, kb, KO, N, hkb, hN, hNk, hNO)
  +hDO = F.nat__le_lt_trans(DOK(K), KO, 31n, VD.wd_min(VC.nwu(NK(K)), KO, hw), hKO)
  +hcov = VD.wd_cover(VC.nwu(NK(K)), KO, F.nat__le_trans(KO, 30n, 32n, F.nat__lt_succ_le(KO, 30n, hKO), {==}), hw)
  +hDq = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VBT.QK(K), 1n), z) == True{} : Bool}, O.pow2n(DOK(K)), VB.pw(DOK(K)), Equal.sym(Nat, VB.pw(DOK(K)), O.pow2n(DOK(K)), VD.s_pow2_eq(DOK(K))),
    F.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(DOK(K))) == True{} : Bool}, U32.to_nat(VC.nwu(NK(K))), Nat.add(VBT.QK(K), 1n), nwNK(K, kb, N, hkb, hN, hNk), hcov))
  +hc2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), VB.pw(dw)) == True{} : Bool}, U32.to_nat(U32.shrn(K, 5n)), VBT.QK(K), eq5(K, kb, N, hkb, hN, hNk), hcap)
  enc_core(DOK(K), dw, T, K, kb, KY, N, pfT, hDO, hdw, hkb, hKY, hN, hNk, hNY, hDq, hc2, hz)

def enc_sized2(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +KO: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hKO: {Nat.is_lt(KO, 31n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNO: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), O.pow2n(KO)) == True{} : Bool},
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool})
    -> CR(DOK(K), T, K):
  +hw = hwO(K, kb, KO, N, hkb, hN, hNk, hNO)
  +hDO = F.nat__le_lt_trans(DOK(K), KO, 31n, VD.wd_min(VC.nwu(NK(K)), KO, hw), hKO)
  +hcov = VD.wd_cover(VC.nwu(NK(K)), KO, F.nat__le_trans(KO, 30n, 32n, F.nat__lt_succ_le(KO, 30n, hKO), {==}), hw)
  +hDq = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VBT.QK(K), 1n), z) == True{} : Bool}, O.pow2n(DOK(K)), VB.pw(DOK(K)), Equal.sym(Nat, VB.pw(DOK(K)), O.pow2n(DOK(K)), VD.s_pow2_eq(DOK(K))),
    F.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(DOK(K))) == True{} : Bool}, U32.to_nat(VC.nwu(NK(K))), Nat.add(VBT.QK(K), 1n), nwNK(K, kb, N, hkb, hN, hNk), hcov))
  +hc2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), VB.pw(dw)) == True{} : Bool}, U32.to_nat(U32.shrn(K, 5n)), VBT.QK(K), eq5(K, kb, N, hkb, hN, hNk), hcap)
  enc_core2(DOK(K), dw, T, K, kb, N, pfT, hDO, hdw, hkb, hN, hNk, hDq, hc2, hz)

# The size K / 8 + 1 is at most N + 1.
def nk_le(+K: U32, +kb: Nat, +N: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(NK(K)), Nat.add(N, 1n)) == True{} : Bool}:
  +hK = F.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(N, 1n)) == True{} : Bool}, Nat.add(VBT.AK(K), 1n), U32.to_nat(NK(K)), Equal.sym(Nat, U32.to_nat(NK(K)), Nat.add(VBT.AK(K), 1n), VBT.E4(K, kb, hkb, hK)),
    F.nat__le_trans(Nat.add(VBT.AK(K), 1n), Nat.add(U32.to_nat(K), 1n), Nat.add(N, 1n), Order.add_right(VBT.AK(K), U32.to_nat(K), 1n, VBT.lAK(K)), Order.add_right(U32.to_nat(K), N, 1n, hN)))

# The parts of CR, for projecting.
def CR1(+dd: Nat, +T: F.array__Tree<U32>, +K: U32) -> Data:
  {O.put_bits_n(F.array__thaw(U32, VC.ZT(dd)), 0, O.Bits{F.array__thaw(U32, T), K})
    == (F.array__thaw(U32, DL.OZ(dd, T, K)), (O.Bits{F.array__thaw(U32, T), K}, NK(K))) : Array<U32> & (O.Bits & U32)}
def CR2(+dd: Nat, +T: F.array__Tree<U32>, +K: U32) -> Data:
  {Bp.pack(List.append(&2, Bool, BITS(T, K), [True{}])) == VS.bt(U32.to_nat(NK(K)), FX.limbs(F.array__slots(U32, DL.OZ(dd, T, K)))) : +List<U32>}
def CR3(+T: F.array__Tree<U32>, +K: U32) -> Data: {List.length(&2, Bool, BITS(T, K)) == U32.to_nat(K) : Nat}
def cr1(+dd: Nat, +T: F.array__Tree<U32>, +K: U32, +c: CR(dd, T, K)) -> CR1(dd, T, K): DL.p1(CR1(dd, T, K), DK.P2(CR2(dd, T, K), CR3(T, K)), c)
def cr2(+dd: Nat, +T: F.array__Tree<U32>, +K: U32, +c: CR(dd, T, K)) -> CR2(dd, T, K): DL.p1(CR2(dd, T, K), CR3(T, K), DL.p2(CR1(dd, T, K), DK.P2(CR2(dd, T, K), CR3(T, K)), c))
def cr3(+dd: Nat, +T: F.array__Tree<U32>, +K: U32, +c: CR(dd, T, K)) -> CR3(T, K): DL.p2(CR2(dd, T, K), CR3(T, K), DL.p2(CR1(dd, T, K), DK.P2(CR2(dd, T, K), CR3(T, K)), c))

# The word index K / 32 is inside the storage.
def qs_small(+dw: Nat, +K: U32, +kb: Nat, +N: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hN5: {Nat.is_le(Nat.add(VD.s_rng(5n, N), 1n), 1n) == True{} : Bool})
    -> {Nat.is_lt(VBT.QK(K), VB.pw(dw)) == True{} : Bool}:
  F.nat__lt_le_trans(VBT.QK(K), Nat.add(VBT.QK(K), 1n), VB.pw(dw), DL.lt_add1(VBT.QK(K)),
    F.nat__le_trans(Nat.add(VBT.QK(K), 1n), 1n, VB.pw(dw), F.nat__le_trans(Nat.add(VBT.QK(K), 1n), Nat.add(VD.s_rng(5n, N), 1n), 1n, qle(K, kb, N, hkb, hN, hNk), hN5), pw_pos(dw)))

def qs_sized(+dw: Nat, +K: U32, +kb: Nat, +N: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}, +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool})
    -> {Nat.is_lt(VBT.QK(K), VB.pw(dw)) == True{} : Bool}:
  F.nat__lt_le_trans(VBT.QK(K), Nat.add(VBT.QK(K), 1n), VB.pw(dw), DL.lt_add1(VBT.QK(K)),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), VB.pw(dw)) == True{} : Bool}, U32.to_nat(U32.shrn(K, 5n)), VBT.QK(K), eq5(K, kb, N, hkb, hN, hNk), hcap))
