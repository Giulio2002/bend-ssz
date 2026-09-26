import Base
import ../../spec/bit_packing.bend as Bp
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./bitlist_pack.bend as BK
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
import ./var_bits_enc_bw.bend as BW
import ../../src/obj.bend as O

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
        {Bp.pack(List.append(&2, Bool, BITS(T, K), [True{}])) == VS.bt(U32.to_nat(NK(K)), FX.limbs(F.array__slots(U32, DL.OZ(dd, T, K)))) : +List<U32>})

def enc_core(+DO: Nat, +dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +KY: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hDO: {Nat.is_lt(DO, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hKY: {Nat.is_lt(KY, 31n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNY: {Nat.is_le(Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY)) == True{} : Bool},
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
  # 31 + nb <= 2^KY
  +e3 = VBT.E3(K, kb, hkb, hK)
  +hnb = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(VBT.AK(K), 1n)) == True{} : Bool}, Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n))), U32.to_nat(O.bits_nbytes(K)),
    Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n))), e3), Order.add_left(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n)), 1n, cB))
  +hnbN = F.nat__le_trans(U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), 1n), Nat.add(N, 1n), hnb,
    F.nat__le_trans(Nat.add(VBT.AK(K), 1n), Nat.add(U32.to_nat(K), 1n), Nat.add(N, 1n), Order.add_right(VBT.AK(K), U32.to_nat(K), 1n, VBT.lAK(K)), Order.add_right(U32.to_nat(K), N, 1n, hN)))
  +hy = F.nat__le_trans(VC.YL(O.bits_nbytes(K)), Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY), Order.add_left(31n, U32.to_nat(O.bits_nbytes(K)), Nat.add(N, 1n), hnbN), hNY)
  +pfZ = F.array__trep_perfect(U32, DO, 0)
  +pb = VBT.put_bits2(DO, dw, VC.ZT(DO), T, 0, 0n, K, q, KY, pfZ, pfT, hDO, hdw, {==}, {==}, hKY, hy, hns, hnd,
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
  (ev, wp3)
