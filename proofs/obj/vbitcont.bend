import Base
import ../../spec/bit_packing.bend as Bp
import ../compact/found_generated.bend as F
import ./spec_fixed.bend as FX
import ./bitlist_pack_generated.bend as BK
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./dk.bend as DK
import ./vdepth.bend as VD
import ./vu32.bend as VU
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./vcopy.bend as VC
import ./vbytes.bend as VY
import ./vbenc.bend as VBE
import ./vbitenc.bend as VBT
import ./vbitdl.bend as DL
import ./vbitcore.bend as CO
import ./vbitat.bend as AT
import ./var_bits_enc_bw_generated.bend as BW
import ../../src/obj.bend as O
import ../../src/merkle_fast.bend as MF
import ./vfix.bend as VF
import ./vuwb.bend as VWB

# A container's bit list field: the runtime's validity check (O.bits_ok) and the
# writer O.put_bits_n at a word-aligned position p = 4 H of the container's output.

# x = 4 Q + R, R < 4: x >> 2 is Q.
def T4q(+x: U32, +Q: Nat, +R: Nat, +e: {U32.to_nat(x) == Nat.add(A.quad(Q), R) : Nat}, +hR: {Nat.is_lt(R, 4n) == True{} : Bool})
    -> {U32.to_nat(U32.shrn(x, 2n)) == Q : Nat}:
  +Qx = U32.to_nat(U32.shrn(x, 2n))
  +Rx = U32.to_nat(U32.and(x, 3))
  +e1 = Equal.trans(Nat, Nat.add(Nat.mul(Qx, 4n), Rx), Nat.add(A.quad(Qx), Rx), Nat.add(Nat.mul(Q, 4n), R),
    Equal.cong(Nat, Nat, z => Nat.add(z, Rx), Nat.mul(Qx, 4n), A.quad(Qx), VC.quad_mul(Qx)),
    Equal.trans(Nat, Nat.add(A.quad(Qx), Rx), U32.to_nat(x), Nat.add(Nat.mul(Q, 4n), R), Equal.sym(Nat, U32.to_nat(x), Nat.add(A.quad(Qx), Rx), VC.split4(x)),
      Equal.trans(Nat, U32.to_nat(x), Nat.add(A.quad(Q), R), Nat.add(Nat.mul(Q, 4n), R), e,
        Equal.cong(Nat, Nat, z => Nat.add(z, R), A.quad(Q), Nat.mul(Q, 4n), Equal.sym(Nat, Nat.mul(Q, 4n), A.quad(Q), VC.quad_mul(Q))))))
  Pair.fst({Qx == Q : Nat}, {Rx == R : Nat}, VU.dm_unique(Qx, Rx, Q, R, 4n, e1, F.nat__le_lt_trans(Rx, 3n, 4n, RD.and_le(x, 3), {==}), hR))

# ---- the validity check ------------------------------------------------------------------------

def VOK(+T: F.array__Tree<U32>, +K: U32, +Nu: U32) -> Data:
  {O.bits_ok(O.Bits{F.array__thaw(U32, T), K}, Nu, False{}) == (O.Bits{F.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}

def valid_eval(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat, +Nu: U32,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +eN: {U32.to_nat(Nu) == N : Nat},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},
    +hv: {O.bits_above_zero(U32.and(K, 31), VB.slot(T, VBT.QK(K))) == True{} : Bool})
    -> VOK(T, K, Nu):
  +hle = F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(K), U32.to_nat(Nu)), U32.is_le(K, Nu),
    Equal.sym(Bool, U32.is_le(K, Nu), Nat.is_le(U32.to_nat(K), U32.to_nat(Nu)), VD.s_le_nat(K, Nu)),
    F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(K), z) == True{} : Bool}, N, U32.to_nat(Nu), Equal.sym(Nat, U32.to_nat(Nu), N, eN), hN))
  +eq = CO.eq5(K, kb, N, hkb, hN, hNk)
  +hq = CO.qs_sized(dw, K, kb, N, hkb, hN, hNk, hcap)
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, T)), (F.array__thaw(U32, T), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, T, pfT)) :
    {O.bk_cap(Bool.or(False{}, U32.is_le(K, Nu)), K, _) == (O.Bits{F.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  %Equal.sym(Bool, U32.is_le(K, Nu), True{}, hle) :
    {O.bk_cap(Bool.or(False{}, _), K, (F.array__thaw(U32, T), F.u32__pow2u(dw))) == (O.Bits{F.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  %Equal.sym(Bool, U32.is_le(U32.add(U32.shrn(K, 5n), 1), F.u32__pow2u(dw)), True{}, CO.capT(K, dw, hdw, hcap)) :
    {O.bk_last(Bool.and(True{}, _), K, Array.get(U32, F.array__thaw(U32, T), U32.shrn(K, 5n))) == (O.Bits{F.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, T), U32.shrn(K, 5n)), (F.array__thaw(U32, T), VB.slot(T, VBT.QK(K))),
      VB.get_n(dw, T, U32.shrn(K, 5n), VBT.QK(K), eq, VB.lt32(dw, hdw), hq, pfT)) :
    {O.bk_last(True{}, K, _) == (O.Bits{F.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  %Equal.sym(Bool, O.bits_above_zero(U32.and(K, 31), VB.slot(T, VBT.QK(K))), True{}, hv) :
    {(O.Bits{F.array__thaw(U32, T), K}, Bool.and(True{}, _)) == (O.Bits{F.array__thaw(U32, T), K}, True{}) : O.Bits & Bool}
  {==}

# ---- the writer at 4 H ----

# The bound of p + K / 8 for U32.add.
def pdb(+DO: Nat, +p: U32, +H: Nat, +K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: VBT.HK(K, kb),
    +ep: {U32.to_nat(p) == A.quad(H) : Nat},
    +hDq: {Nat.is_le(Nat.add(H, Nat.add(VBT.QK(K), 1n)), VB.pw(DO)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(p), U32.to_nat(U32.shrn(K, 3n))), O.pow2n(2n+DO)) == True{} : Bool}:
  +q = VBT.QK(K)
  +j = VBT.JK(K)
  +hj = RD.and_le(VBT.PDK(K), 3)
  +hA = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(A.quad(q), 3n)) == True{} : Bool}, Nat.add(A.quad(q), j), VBT.AK(K),
    Equal.sym(Nat, VBT.AK(K), Nat.add(A.quad(q), j), VBT.E2(K, kb, hkb, hK)), Order.add_left(A.quad(q), j, 3n, hj))
  +hA2 = F.nat__le_trans(VBT.AK(K), Nat.add(A.quad(q), 3n), A.quad(Nat.add(q, 1n)), hA,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), 3n), z) == True{} : Bool}, Nat.add(A.quad(q), A.quad(1n)), A.quad(Nat.add(q, 1n)), VF.quad_add(q, 1n),
      Order.add_left(A.quad(q), 3n, 4n, {==})))
  +hs = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, VBT.AK(K)), A.quad(Nat.add(H, Nat.add(q, 1n)))) == True{} : Bool}, A.quad(H), U32.to_nat(p), Equal.sym(Nat, U32.to_nat(p), A.quad(H), ep),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(H), VBT.AK(K)), z) == True{} : Bool}, Nat.add(A.quad(H), A.quad(Nat.add(q, 1n))), A.quad(Nat.add(H, Nat.add(q, 1n))), VF.quad_add(H, Nat.add(q, 1n)),
      Order.add_left(A.quad(H), VBT.AK(K), A.quad(Nat.add(q, 1n)), hA2)))
  +hDq2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(H, Nat.add(q, 1n)), z) == True{} : Bool}, VB.pw(DO), O.pow2n(DO), VD.s_pow2_eq(DO), hDq)
  F.nat__le_trans(Nat.add(U32.to_nat(p), VBT.AK(K)), A.quad(Nat.add(H, Nat.add(q, 1n))), O.pow2n(2n+DO), hs,
    Order.double_monotone(Nat.double(Nat.add(H, Nat.add(q, 1n))), Nat.double(O.pow2n(DO)), Order.double_monotone(Nat.add(H, Nat.add(q, 1n)), O.pow2n(DO), hDq2)))

# All K bits are in the storage: K = 32 q + r <= 32 (q + 1) <= 32 2^dw.
def lenK(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hWq: {Nat.is_le(Nat.add(VBT.QK(K), 1n), VB.pw(dw)) == True{} : Bool})
    -> CO.CR3(T, K):
  +q = VBT.QK(K)
  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +r = DL.RK(K)
  +S = F.array__slots(U32, T)
  +hK = F.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  +hj = F.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = F.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)
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
  VBT.len_btk(U32.to_nat(K), BK.bitsof(S), hKS)

# ---- the writer ---------------------------------------------------------------------------------

def OA(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32) -> F.array__Tree<U32>: AT.OA(dd, D, T, p, H, K)

def CRA(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32) -> Data:
  DK.P2({O.put_bits_n(F.array__thaw(U32, D), p, O.Bits{F.array__thaw(U32, T), K})
          == (F.array__thaw(U32, OA(dd, D, T, p, H, K)), (O.Bits{F.array__thaw(U32, T), K}, CO.NK(K))) : Array<U32> & (O.Bits & U32)},
        DK.P2({Bp.pack(List.append(&2, Bool, CO.BITS(T, K), [True{}])) == VS.bt(U32.to_nat(CO.NK(K)), FX.limbs(VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K))))) : +List<U32>},
          {List.length(&2, Bool, CO.BITS(T, K)) == U32.to_nat(K) : Nat}))
def CRA1(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32) -> Data:
  {O.put_bits_n(F.array__thaw(U32, D), p, O.Bits{F.array__thaw(U32, T), K})
    == (F.array__thaw(U32, OA(dd, D, T, p, H, K)), (O.Bits{F.array__thaw(U32, T), K}, CO.NK(K))) : Array<U32> & (O.Bits & U32)}
def CRA2(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32) -> Data:
  {Bp.pack(List.append(&2, Bool, CO.BITS(T, K), [True{}])) == VS.bt(U32.to_nat(CO.NK(K)), FX.limbs(VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K))))) : +List<U32>}
def cra1(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32, +c: CRA(dd, D, T, p, H, K)) -> CRA1(dd, D, T, p, H, K):
  DL.p1(CRA1(dd, D, T, p, H, K), DK.P2(CRA2(dd, D, T, p, H, K), CO.CR3(T, K)), c)
def cra2(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32, +c: CRA(dd, D, T, p, H, K)) -> CRA2(dd, D, T, p, H, K):
  DL.p1(CRA2(dd, D, T, p, H, K), CO.CR3(T, K), DL.p2(CRA1(dd, D, T, p, H, K), DK.P2(CRA2(dd, D, T, p, H, K), CO.CR3(T, K)), c))
def cra3(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32, +c: CRA(dd, D, T, p, H, K)) -> CO.CR3(T, K):
  DL.p2(CRA2(dd, D, T, p, H, K), CO.CR3(T, K), DL.p2(CRA1(dd, D, T, p, H, K), DK.P2(CRA2(dd, D, T, p, H, K), CO.CR3(T, K)), c))

def enc_at(+DO: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32, +kb: Nat, +KY: Nat, +N: Nat,
    +pfD: {F.array__perfect(U32, DO, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hDO: {Nat.is_lt(DO, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hKY: {Nat.is_lt(KY, 31n) == True{} : Bool},
    +ep: {U32.to_nat(p) == A.quad(H) : Nat}, +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == H : Nat},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNY: {Nat.is_le(Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY)) == True{} : Bool},
    +hDq: {Nat.is_le(Nat.add(H, Nat.add(VBT.QK(K), 1n)), VB.pw(DO)) == True{} : Bool},
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool},
    +hz0: {VB.slot(D, Nat.add(H, VBT.QK(K))) == 0 : U32},
    +hzq: {VB.slot(D, Nat.add(VY.QL(O.bits_nbytes(K)), H)) == 0 : U32})
    -> CRA(DO, D, T, p, H, K):
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
  +cE = DL.p1(DL.TE(j, b), DL.TF(j, b), DL.p2(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf)))))
  +hd31 = F.nat__lt_trans(DO, 29n, 31n, hDO, {==})
  +eNW = Equal.trans(Nat, NB, Nat.add(q, VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n))), Nat.add(q, BW.CWr(r)),
    VBT.FNWnb(K, kb, hkb, hK, j, b, Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), {==}, {==}, {==}, cB, {==}),
    Equal.cong(Nat, Nat, z => Nat.add(q, z), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), BW.CWr(r), cA))
  +hNW0 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(q, 1n)) == True{} : Bool}, Nat.add(q, BW.CWr(r)), NB,
    Equal.sym(Nat, NB, Nat.add(q, BW.CWr(r)), eNW), Order.add_left(q, BW.CWr(r), 1n, CO.cwle(r)))
  # room: NW + H <= H + q + 1 <= 2^DO
  +hdst = F.nat__le_trans(Nat.add(NB, H), Nat.add(H, Nat.add(q, 1n)), VB.pw(DO),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(NB, H), z) == True{} : Bool}, Nat.add(Nat.add(q, 1n), H), Nat.add(H, Nat.add(q, 1n)), F.nat__add_comm(Nat.add(q, 1n), H),
      Order.add_right(NB, Nat.add(q, 1n), H, hNW0)), hDq)
  +hQ = F.nat__lt_le_trans(Nat.add(H, q), Nat.add(H, Nat.add(q, 1n)), VB.pw(DO),
    F.nat__lt_add_left(q, Nat.add(q, 1n), H, DL.lt_add1(q)), hDq)
  +hc2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), VB.pw(dw)) == True{} : Bool}, U32.to_nat(U32.shrn(K, 5n)), q, CO.eq5(K, kb, N, hkb, hN, hNk), hcap)
  +hns = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, NB, Nat.add(NB, 0n), Equal.sym(Nat, Nat.add(NB, 0n), NB, F.nat__add_zero(NB)),
    F.nat__le_trans(NB, Nat.add(q, 1n), VB.pw(dw), hNW0, hc2))
  +hqs = F.nat__lt_le_trans(q, Nat.add(q, 1n), VB.pw(dw), DL.lt_add1(q), hc2)
  # 31 + nb <= 2^KY
  +e3 = VBT.E3(K, kb, hkb, hK)
  +hnb = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(VBT.AK(K), 1n)) == True{} : Bool}, Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n))), U32.to_nat(O.bits_nbytes(K)),
    Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n))), e3), Order.add_left(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n)), 1n, cB))
  +hnbN = F.nat__le_trans(U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), 1n), Nat.add(N, 1n), hnb,
    F.nat__le_trans(Nat.add(VBT.AK(K), 1n), Nat.add(U32.to_nat(K), 1n), Nat.add(N, 1n), Order.add_right(VBT.AK(K), U32.to_nat(K), 1n, VBT.lAK(K)), Order.add_right(U32.to_nat(K), N, 1n, hN)))
  +hy = F.nat__le_trans(VC.YL(O.bits_nbytes(K)), Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY), Order.add_left(31n, U32.to_nat(O.bits_nbytes(K)), Nat.add(N, 1n), hnbN), hNY)
  # the delimiter's word H + q and byte j
  +ePD = Equal.trans(Nat, U32.to_nat(VBT.PD(p, K)), Nat.add(A.quad(H), VBT.AK(K)), Nat.add(A.quad(Nat.add(H, q)), j),
    Equal.trans(Nat, U32.to_nat(VBT.PD(p, K)), Nat.add(U32.to_nat(p), VBT.AK(K)), Nat.add(A.quad(H), VBT.AK(K)),
      VD.s_add_nat(p, U32.shrn(K, 3n), 2n+DO, F.nat__lt_trans(DO, 29n, 30n, hDO, {==}),
        pdb(DO, p, H, K, kb, hkb, hK, ep, hDq)),
      Equal.cong(Nat, Nat, z => Nat.add(z, VBT.AK(K)), U32.to_nat(p), A.quad(H), ep)),
    Equal.trans(Nat, Nat.add(A.quad(H), VBT.AK(K)), Nat.add(A.quad(H), Nat.add(A.quad(q), j)), Nat.add(A.quad(Nat.add(H, q)), j),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(H), z), VBT.AK(K), Nat.add(A.quad(q), j), VBT.E2(K, kb, hkb, hK)),
      Equal.trans(Nat, Nat.add(A.quad(H), Nat.add(A.quad(q), j)), Nat.add(Nat.add(A.quad(H), A.quad(q)), j), Nat.add(A.quad(Nat.add(H, q)), j),
        Equal.sym(Nat, Nat.add(Nat.add(A.quad(H), A.quad(q)), j), Nat.add(A.quad(H), Nat.add(A.quad(q), j)), F.nat__add_assoc(A.quad(H), A.quad(q), j)),
        Equal.cong(Nat, Nat, z => Nat.add(z, j), Nat.add(A.quad(H), A.quad(q)), A.quad(Nat.add(H, q)), VF.quad_add(H, q)))))
  +eQ = T4q(VBT.PD(p, K), Nat.add(H, q), j, ePD, hj)
  +ej = VBT.T4(VBT.PD(p, K), Nat.add(H, q), j, ePD, hj)
  +e3p = F.u32__injective(U32.and(VBT.PD(p, K), 3), U32.and(VBT.PD(0, K), 3), ej)
  +hDL = Equal.trans(U32, VBT.DMK(p, K), VBT.DMK(0, K), BW.DL(j, b),
    Equal.cong(U32, U32, z => O.shl_bytes(U32.and(MF.shl_by(1, U32.and(K, 7)), 255), z), U32.and(VBT.PD(p, K), 3), U32.and(VBT.PD(0, K), 3), e3p),
    BW.dmk_dl(K, j, b, {==}, {==}, hj, hb))
  +pb = VBT.put_bits2(DO, dw, D, T, p, H, K, Nat.add(H, q), KY, pfD, pfT, hd31, hdw, hp3, eP, hKY, hy, hns, hdst, hzq, eQ, hQ)
  +ev = Equal.cong(Array<U32> & O.Bits, Array<U32> & (O.Bits & U32), z => O.pbn(z),
    O.put_bits(F.array__thaw(U32, D), p, O.Bits{F.array__thaw(U32, T), K}), (F.array__thaw(U32, OA(DO, D, T, p, H, K)), O.Bits{F.array__thaw(U32, T), K}), pb)
  +wp = AT.words_pack_at(DO, dw, D, T, p, H, K, kb, pfD, pfT, hkb, hK, hdst, hns, hQ, hqs, hz, hz0, hDL)
  +W = VB.wdr(H, F.array__slots(U32, OA(DO, D, T, p, H, K)))
  +S = F.array__slots(U32, T)
  +eBC = Equal.trans(Nat, Bp.byte_count(Nat.add(VBT.m32(q), 1n+r)), Nat.add(A.quad(q), Bp.byte_count(1n+r)), U32.to_nat(CO.NK(K)),
    VBT.bc32(q, 1n+r),
    Equal.trans(Nat, Nat.add(A.quad(q), Bp.byte_count(1n+r)), Nat.add(A.quad(q), Nat.add(j, 1n)), U32.to_nat(CO.NK(K)),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(q), z), Bp.byte_count(1n+r), Nat.add(j, 1n), cF),
      Equal.sym(Nat, U32.to_nat(CO.NK(K)), Nat.add(A.quad(q), Nat.add(j, 1n)), VBT.G4(K, kb, hkb, hK, j, {==}))))
  +wp2 = F.logic__subst(Nat, z => {Bp.pack(List.append(&2, Bool, BK.btk(Nat.add(VBT.m32(q), r), BK.bitsof(S)), [True{}])) == VS.bt(z, FX.limbs(W)) : +List<U32>},
    Bp.byte_count(Nat.add(VBT.m32(q), 1n+r)), U32.to_nat(CO.NK(K)), eBC, wp)
  +wp3 = F.logic__subst(Nat, z => {Bp.pack(List.append(&2, Bool, BK.btk(z, BK.bitsof(S)), [True{}])) == VS.bt(U32.to_nat(CO.NK(K)), FX.limbs(W)) : +List<U32>},
    Nat.add(VBT.m32(q), r), U32.to_nat(K), Equal.sym(Nat, U32.to_nat(K), Nat.add(VBT.m32(q), r), VBT.Ka(K, kb, hkb, hK, j, b, {==}, {==})), wp2)
  (ev, (wp3, lenK(dw, T, K, kb, N, pfT, hkb, hN, hNk, hc2)))

# pdb at any output depth DO < 31: the sum p + K / 8 is strictly below 4 (H + q + 1) <= 4 2^DO <= 2^32, so U32.add is exact.
def pdbW(+DO: Nat, +p: U32, +H: Nat, +K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: VBT.HK(K, kb),
    +ep: {U32.to_nat(p) == A.quad(H) : Nat}, +hDO: {Nat.is_lt(DO, 31n) == True{} : Bool},
    +hDq: {Nat.is_le(Nat.add(H, Nat.add(VBT.QK(K), 1n)), VB.pw(DO)) == True{} : Bool})
    -> {U32.to_nat(VBT.PD(p, K)) == Nat.add(U32.to_nat(p), VBT.AK(K)) : Nat}:
  +q = VBT.QK(K)
  +j = VBT.JK(K)
  +hj = RD.and_le(VBT.PDK(K), 3)
  +hA = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(A.quad(q), 3n)) == True{} : Bool}, Nat.add(A.quad(q), j), VBT.AK(K),
    Equal.sym(Nat, VBT.AK(K), Nat.add(A.quad(q), j), VBT.E2(K, kb, hkb, hK)), Order.add_left(A.quad(q), j, 3n, hj))
  +hA2 = F.nat__le_lt_trans(VBT.AK(K), Nat.add(A.quad(q), 3n), A.quad(Nat.add(q, 1n)), hA,
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(q), 3n), z) == True{} : Bool}, Nat.add(A.quad(q), A.quad(1n)), A.quad(Nat.add(q, 1n)), VF.quad_add(q, 1n),
      F.nat__lt_add_left(3n, 4n, A.quad(q), {==})))
  +hs = F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, VBT.AK(K)), A.quad(Nat.add(H, Nat.add(q, 1n)))) == True{} : Bool}, A.quad(H), U32.to_nat(p), Equal.sym(Nat, U32.to_nat(p), A.quad(H), ep),
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(H), VBT.AK(K)), z) == True{} : Bool}, Nat.add(A.quad(H), A.quad(Nat.add(q, 1n))), A.quad(Nat.add(H, Nat.add(q, 1n))), VF.quad_add(H, Nat.add(q, 1n)),
      F.nat__lt_add_left(VBT.AK(K), A.quad(Nat.add(q, 1n)), A.quad(H), hA2)))
  +hq = F.nat__lt_le_trans(Nat.add(U32.to_nat(p), VBT.AK(K)), A.quad(Nat.add(H, Nat.add(q, 1n))), A.quad(VB.pw(DO)), hs,
    Order.double_monotone(Nat.double(Nat.add(H, Nat.add(q, 1n))), Nat.double(VB.pw(DO)), Order.double_monotone(Nat.add(H, Nat.add(q, 1n)), VB.pw(DO), hDq)))
  VWB.addXK(p, K, DO, hDO, hq)

def enc_atW(+DO: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32, +kb: Nat, +KY: Nat, +N: Nat,
    +pfD: {F.array__perfect(U32, DO, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hDO: {Nat.is_lt(DO, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hKY: {Nat.is_lt(KY, 31n) == True{} : Bool},
    +ep: {U32.to_nat(p) == A.quad(H) : Nat}, +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == H : Nat},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hNY: {Nat.is_le(Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY)) == True{} : Bool},
    +hDq: {Nat.is_le(Nat.add(H, Nat.add(VBT.QK(K), 1n)), VB.pw(DO)) == True{} : Bool},
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool},
    +hz0: {VB.slot(D, Nat.add(H, VBT.QK(K))) == 0 : U32},
    +hzq: {VB.slot(D, Nat.add(VY.QL(O.bits_nbytes(K)), H)) == 0 : U32})
    -> CRA(DO, D, T, p, H, K):
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
  +cE = DL.p1(DL.TE(j, b), DL.TF(j, b), DL.p2(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf)))))
  +hd31 = hDO
  +eNW = Equal.trans(Nat, NB, Nat.add(q, VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n))), Nat.add(q, BW.CWr(r)),
    VBT.FNWnb(K, kb, hkb, hK, j, b, Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), {==}, {==}, {==}, cB, {==}),
    Equal.cong(Nat, Nat, z => Nat.add(q, z), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), BW.CWr(r), cA))
  +hNW0 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(q, 1n)) == True{} : Bool}, Nat.add(q, BW.CWr(r)), NB,
    Equal.sym(Nat, NB, Nat.add(q, BW.CWr(r)), eNW), Order.add_left(q, BW.CWr(r), 1n, CO.cwle(r)))
  # room: NW + H <= H + q + 1 <= 2^DO
  +hdst = F.nat__le_trans(Nat.add(NB, H), Nat.add(H, Nat.add(q, 1n)), VB.pw(DO),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(NB, H), z) == True{} : Bool}, Nat.add(Nat.add(q, 1n), H), Nat.add(H, Nat.add(q, 1n)), F.nat__add_comm(Nat.add(q, 1n), H),
      Order.add_right(NB, Nat.add(q, 1n), H, hNW0)), hDq)
  +hQ = F.nat__lt_le_trans(Nat.add(H, q), Nat.add(H, Nat.add(q, 1n)), VB.pw(DO),
    F.nat__lt_add_left(q, Nat.add(q, 1n), H, DL.lt_add1(q)), hDq)
  +hc2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), VB.pw(dw)) == True{} : Bool}, U32.to_nat(U32.shrn(K, 5n)), q, CO.eq5(K, kb, N, hkb, hN, hNk), hcap)
  +hns = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, NB, Nat.add(NB, 0n), Equal.sym(Nat, Nat.add(NB, 0n), NB, F.nat__add_zero(NB)),
    F.nat__le_trans(NB, Nat.add(q, 1n), VB.pw(dw), hNW0, hc2))
  +hqs = F.nat__lt_le_trans(q, Nat.add(q, 1n), VB.pw(dw), DL.lt_add1(q), hc2)
  # 31 + nb <= 2^KY
  +e3 = VBT.E3(K, kb, hkb, hK)
  +hnb = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(VBT.AK(K), 1n)) == True{} : Bool}, Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n))), U32.to_nat(O.bits_nbytes(K)),
    Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n))), e3), Order.add_left(VBT.AK(K), VD.s_rng(3n, Nat.add(b, 7n)), 1n, cB))
  +hnbN = F.nat__le_trans(U32.to_nat(O.bits_nbytes(K)), Nat.add(VBT.AK(K), 1n), Nat.add(N, 1n), hnb,
    F.nat__le_trans(Nat.add(VBT.AK(K), 1n), Nat.add(U32.to_nat(K), 1n), Nat.add(N, 1n), Order.add_right(VBT.AK(K), U32.to_nat(K), 1n, VBT.lAK(K)), Order.add_right(U32.to_nat(K), N, 1n, hN)))
  +hy = F.nat__le_trans(VC.YL(O.bits_nbytes(K)), Nat.add(31n, Nat.add(N, 1n)), VB.pw(KY), Order.add_left(31n, U32.to_nat(O.bits_nbytes(K)), Nat.add(N, 1n), hnbN), hNY)
  # the delimiter's word H + q and byte j
  +ePD = Equal.trans(Nat, U32.to_nat(VBT.PD(p, K)), Nat.add(A.quad(H), VBT.AK(K)), Nat.add(A.quad(Nat.add(H, q)), j),
    Equal.trans(Nat, U32.to_nat(VBT.PD(p, K)), Nat.add(U32.to_nat(p), VBT.AK(K)), Nat.add(A.quad(H), VBT.AK(K)),
      pdbW(DO, p, H, K, kb, hkb, hK, ep, hDO, hDq),
      Equal.cong(Nat, Nat, z => Nat.add(z, VBT.AK(K)), U32.to_nat(p), A.quad(H), ep)),
    Equal.trans(Nat, Nat.add(A.quad(H), VBT.AK(K)), Nat.add(A.quad(H), Nat.add(A.quad(q), j)), Nat.add(A.quad(Nat.add(H, q)), j),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(H), z), VBT.AK(K), Nat.add(A.quad(q), j), VBT.E2(K, kb, hkb, hK)),
      Equal.trans(Nat, Nat.add(A.quad(H), Nat.add(A.quad(q), j)), Nat.add(Nat.add(A.quad(H), A.quad(q)), j), Nat.add(A.quad(Nat.add(H, q)), j),
        Equal.sym(Nat, Nat.add(Nat.add(A.quad(H), A.quad(q)), j), Nat.add(A.quad(H), Nat.add(A.quad(q), j)), F.nat__add_assoc(A.quad(H), A.quad(q), j)),
        Equal.cong(Nat, Nat, z => Nat.add(z, j), Nat.add(A.quad(H), A.quad(q)), A.quad(Nat.add(H, q)), VF.quad_add(H, q)))))
  +eQ = T4q(VBT.PD(p, K), Nat.add(H, q), j, ePD, hj)
  +ej = VBT.T4(VBT.PD(p, K), Nat.add(H, q), j, ePD, hj)
  +e3p = F.u32__injective(U32.and(VBT.PD(p, K), 3), U32.and(VBT.PD(0, K), 3), ej)
  +hDL = Equal.trans(U32, VBT.DMK(p, K), VBT.DMK(0, K), BW.DL(j, b),
    Equal.cong(U32, U32, z => O.shl_bytes(U32.and(MF.shl_by(1, U32.and(K, 7)), 255), z), U32.and(VBT.PD(p, K), 3), U32.and(VBT.PD(0, K), 3), e3p),
    BW.dmk_dl(K, j, b, {==}, {==}, hj, hb))
  +pb = VBT.put_bits2(DO, dw, D, T, p, H, K, Nat.add(H, q), KY, pfD, pfT, hd31, hdw, hp3, eP, hKY, hy, hns, hdst, hzq, eQ, hQ)
  +ev = Equal.cong(Array<U32> & O.Bits, Array<U32> & (O.Bits & U32), z => O.pbn(z),
    O.put_bits(F.array__thaw(U32, D), p, O.Bits{F.array__thaw(U32, T), K}), (F.array__thaw(U32, OA(DO, D, T, p, H, K)), O.Bits{F.array__thaw(U32, T), K}), pb)
  +wp = AT.words_pack_at(DO, dw, D, T, p, H, K, kb, pfD, pfT, hkb, hK, hdst, hns, hQ, hqs, hz, hz0, hDL)
  +W = VB.wdr(H, F.array__slots(U32, OA(DO, D, T, p, H, K)))
  +S = F.array__slots(U32, T)
  +eBC = Equal.trans(Nat, Bp.byte_count(Nat.add(VBT.m32(q), 1n+r)), Nat.add(A.quad(q), Bp.byte_count(1n+r)), U32.to_nat(CO.NK(K)),
    VBT.bc32(q, 1n+r),
    Equal.trans(Nat, Nat.add(A.quad(q), Bp.byte_count(1n+r)), Nat.add(A.quad(q), Nat.add(j, 1n)), U32.to_nat(CO.NK(K)),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(q), z), Bp.byte_count(1n+r), Nat.add(j, 1n), cF),
      Equal.sym(Nat, U32.to_nat(CO.NK(K)), Nat.add(A.quad(q), Nat.add(j, 1n)), VBT.G4(K, kb, hkb, hK, j, {==}))))
  +wp2 = F.logic__subst(Nat, z => {Bp.pack(List.append(&2, Bool, BK.btk(Nat.add(VBT.m32(q), r), BK.bitsof(S)), [True{}])) == VS.bt(z, FX.limbs(W)) : +List<U32>},
    Bp.byte_count(Nat.add(VBT.m32(q), 1n+r)), U32.to_nat(CO.NK(K)), eBC, wp)
  +wp3 = F.logic__subst(Nat, z => {Bp.pack(List.append(&2, Bool, BK.btk(z, BK.bitsof(S)), [True{}])) == VS.bt(U32.to_nat(CO.NK(K)), FX.limbs(W)) : +List<U32>},
    Nat.add(VBT.m32(q), r), U32.to_nat(K), Equal.sym(Nat, U32.to_nat(K), Nat.add(VBT.m32(q), r), VBT.Ka(K, kb, hkb, hK, j, b, {==}, {==})), wp2)
  (ev, (wp3, lenK(dw, T, K, kb, N, pfT, hkb, hN, hNk, hc2)))
