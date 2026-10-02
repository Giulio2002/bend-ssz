import Base
import ../../spec/bit_packing.bend as Bp
import ../compact/found_generated.bend as F
import ./spec_fixed.bend as FX
import ./bits_leaf_generated.bend as BLf
import ./bitlist_pack_generated.bend as BK
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./dk.bend as DK
import ./vdepth.bend as VD
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./vcopy.bend as VC
import ./vfix.bend as VF
import ./vbspec.bend as VZ
import ./vbenc.bend as VBE
import ./vbitenc.bend as VBT
import ./vbitdl.bend as DL
import ./var_bits_enc_bw_generated.bend as BW
import ../../src/obj.bend as O

# The bit list writer at a word-aligned position p = 4 H of any perfect tree D
# (a container's output, the header below word H): the window of the output from
# word H packs the object's bits and the delimiter.

law nth_wdr:
  for +j: Nat
  for +L: List<&2, U32>
  for +q: Nat
  {F.flat__nthc(VB.wdr(j, L), q) == F.flat__nthc(L, Nat.add(j, q)) : U32}
def nth_wdr(j, L, q):
  match j L:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}: nth_wdr(p, t, q)

law wdr_updh:
  for +j: Nat
  for +L: List<&2, U32>
  for +q: Nat
  for +v: U32
  {VB.wdr(j, F.spec_common__update(U32, L, Nat.add(j, q), v)) == F.spec_common__update(U32, VB.wdr(j, L), q, v) : List<&2, U32>}
def wdr_updh(j, L, q, v):
  match j L:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}: wdr_updh(p, t, q, v)

# q < NW when the offset r is positive; q = NW when it is zero.
def hlt(+q: Nat, +NB: Nat, +r: Nat, +e: {NB == Nat.add(q, BW.CWr(r)) : Nat}, +h: {Nat.is_lt(0n, r) == True{} : Bool})
    -> {Nat.is_lt(q, NB) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, Nat.add(q, 1n), NB,
    Equal.trans(Nat, Nat.add(q, 1n), Nat.add(q, BW.CWr(r)), NB, Equal.cong(Nat, Nat, z => Nat.add(q, z), 1n, BW.CWr(r), Equal.sym(Nat, BW.CWr(r), 1n, DL.cw1(r, h))), Equal.sym(Nat, NB, Nat.add(q, BW.CWr(r)), e)),
    DL.lt_add1(q))

def nb0(+q: Nat, +NB: Nat, +r: Nat, +e: {NB == Nat.add(q, BW.CWr(r)) : Nat}, +e0: {r == 0n : Nat}) -> {NB == q : Nat}:
  Equal.trans(Nat, NB, Nat.add(q, BW.CWr(r)), q, e,
    Equal.trans(Nat, Nat.add(q, BW.CWr(r)), Nat.add(q, 0n), q, Equal.cong(Nat, Nat, z => Nat.add(q, BW.CWr(z)), r, 0n, e0), F.nat__add_zero(q)))

def xq(+Mp: List<&2, U32>, +S: List<&2, U32>, +q: Nat, +NB: Nat, +X: U32, +eXw: {X == F.flat__nthc(Mp, q) : U32},
    +eWin: {VS.wtake(NB, Mp) == VS.wtake(NB, S) : List<&2, U32>}, +hq: {Nat.is_lt(q, NB) == True{} : Bool})
    -> {X == F.flat__nthc(S, q) : U32}:
  Equal.trans(U32, X, F.flat__nthc(Mp, q), F.flat__nthc(S, q), eXw,
    Equal.trans(U32, F.flat__nthc(Mp, q), F.flat__nthc(VS.wtake(NB, Mp), q), F.flat__nthc(S, q),
      Equal.sym(U32, F.flat__nthc(VS.wtake(NB, Mp), q), F.flat__nthc(Mp, q), VBT.nth_take(q, NB, Mp, hq)),
      Equal.trans(U32, F.flat__nthc(VS.wtake(NB, Mp), q), F.flat__nthc(VS.wtake(NB, S), q), F.flat__nthc(S, q),
        Equal.cong(List<&2, U32>, U32, z => F.flat__nthc(z, q), VS.wtake(NB, Mp), VS.wtake(NB, S), eWin),
        VBT.nth_take(q, NB, S, hq))))

def MTA(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +H: Nat, +K: U32) -> F.array__Tree<U32>: VBT.MT(dd, D, T, H, K)
def OA(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32) -> F.array__Tree<U32>:
  VBT.OUTB(dd, D, T, p, H, K, Nat.add(H, VBT.QK(K)))

def words_pack_at(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +H: Nat, +K: U32, +kb: Nat,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: VBT.HK(K, kb),
    +hnd: {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), H), VB.pw(dd)) == True{} : Bool},
    +hns: {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), 0n), VB.pw(dw)) == True{} : Bool},
    +hqd: {Nat.is_lt(Nat.add(H, VBT.QK(K)), VB.pw(dd)) == True{} : Bool}, +hqs: {Nat.is_lt(VBT.QK(K), VB.pw(dw)) == True{} : Bool},
    +hz: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool},
    +hz0: {VB.slot(D, Nat.add(H, VBT.QK(K))) == 0 : U32},
    +hDL: {VBT.DMK(p, K) == BW.DL(VBT.JK(K), VBT.BKk(K)) : U32})
    -> {Bp.pack(List.append(&2, Bool, BK.btk(Nat.add(VBT.m32(VBT.QK(K)), DL.RK(K)), BK.bitsof(F.array__slots(U32, T))), [True{}]))
        == VS.bt(Bp.byte_count(Nat.add(VBT.m32(VBT.QK(K)), 1n+DL.RK(K))), FX.limbs(VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K))))) : +List<U32>}:
  +q = VBT.QK(K)
  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +r = DL.RK(K)
  +S = F.array__slots(U32, T)
  +LD = F.array__slots(U32, D)
  +M = MTA(dd, D, T, H, K)
  +LM = F.array__slots(U32, M)
  +NB = VC.NW(O.bits_nbytes(K))
  +X = VB.slot(M, Nat.add(H, q))
  +v = U32.or(X, VBT.DMK(p, K))
  +Mp = VB.wdr(H, LM)
  +hj = F.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = F.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)
  +cA = DL.p1(DL.TA(j, b), DL.CB(j, b), cf)
  +cB = DL.p1(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf))
  +cE = DL.p1(DL.TE(j, b), DL.TF(j, b), DL.p2(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf)))))
  +pfM = VB.mone_perfect(NB, 0n, H, dd, D, T, pfD)
  +pfO = F.array__upd_perfect(U32, dd, M, Nat.add(H, q), v, pfM)
  +eNW = Equal.trans(Nat, NB, Nat.add(q, VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n))), Nat.add(q, BW.CWr(r)),
    VBT.FNWnb(K, kb, hkb, hK, j, b, Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), {==}, {==}, {==}, cB, {==}),
    Equal.cong(Nat, Nat, z => Nat.add(q, z), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), BW.CWr(r), cA))
  +lS = F.array__slots_length(U32, dw, T, pfT)
  +lM = F.array__slots_length(U32, dd, M, pfM)
  +lD = F.array__slots_length(U32, dd, D, pfD)
  +hLD = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(NB, H), z) == True{} : Bool}, VB.pw(dd), VB.len(LD), Equal.sym(Nat, VB.len(LD), VB.pw(dd), lD), hnd)
  +hS = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(NB, 0n), z) == True{} : Bool}, VB.pw(dw), VB.len(S), Equal.sym(Nat, VB.len(S), VB.pw(dw), lS), hns)
  +eM = VB.slots_mone(NB, 0n, H, dd, D, T, pfD, hnd)
  +eO = F.array__upd_slots(U32, dd, M, Nat.add(H, q), v, hqd, pfM)
  +eW = Equal.trans(List<&2, U32>, VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K))), VB.wdr(H, F.spec_common__update(U32, LM, Nat.add(H, q), v)), F.spec_common__update(U32, Mp, q, v),
    Equal.cong(List<&2, U32>, List<&2, U32>, z => VB.wdr(H, z), F.array__slots(U32, OA(dd, D, T, p, H, K)), F.spec_common__update(U32, LM, Nat.add(H, q), v), eO),
    wdr_updh(H, LM, q, v))
  # the window of the copy is the object's words
  +eWin = Equal.trans(List<&2, U32>, VS.wtake(NB, Mp), VS.wtake(NB, VB.wdr(H, VB.lm(NB, 0n, H, LD, S))), VS.wtake(NB, S),
    Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(NB, VB.wdr(H, z)), LM, VB.lm(NB, 0n, H, LD, S), eM),
    VB.lm_win(NB, 0n, H, LD, S, hLD, hS))
  +hqN = F.logic__subst(Nat, z => {Nat.is_le(q, z) == True{} : Bool}, Nat.add(q, BW.CWr(r)), NB, Equal.sym(Nat, NB, Nat.add(q, BW.CWr(r)), eNW), F.nat__le_add_right(q, BW.CWr(r)))
  +ep = Equal.trans(List<&2, U32>, VS.wtake(q, VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K)))), VS.wtake(q, F.spec_common__update(U32, Mp, q, v)), VS.wtake(q, S),
    Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(q, z), VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K))), F.spec_common__update(U32, Mp, q, v), eW),
    Equal.trans(List<&2, U32>, VS.wtake(q, F.spec_common__update(U32, Mp, q, v)), VS.wtake(q, Mp), VS.wtake(q, S),
      VF.take_upd(q, Mp, q, v, F.nat__le_refl(q)),
      Equal.trans(List<&2, U32>, VS.wtake(q, Mp), VS.wtake(q, VS.wtake(NB, Mp)), VS.wtake(q, S),
        Equal.sym(List<&2, U32>, VS.wtake(q, VS.wtake(NB, Mp)), VS.wtake(q, Mp), VBT.take_take(q, NB, Mp, hqN)),
        Equal.trans(List<&2, U32>, VS.wtake(q, VS.wtake(NB, Mp)), VS.wtake(q, VS.wtake(NB, S)), VS.wtake(q, S),
          Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(q, z), VS.wtake(NB, Mp), VS.wtake(NB, S), eWin),
          VBT.take_take(q, NB, S, hqN)))))
  # word q of the window
  +hq1 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, 1n+Nat.add(H, q), Nat.add(1n+q, H),
    Equal.trans(Nat, 1n+Nat.add(H, q), 1n+Nat.add(q, H), Nat.add(1n+q, H), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(H, q), Nat.add(q, H), F.nat__add_comm(H, q)), {==}),
    F.nat__lt_succ_le_succ(Nat.add(H, q), VB.pw(dd), hqd))
  +hqMp = F.nat__succ_le_lt(q, VB.len(Mp), VZ.wdr_len_le(1n+q, H, LM,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n+q, H), z) == True{} : Bool}, VB.pw(dd), VB.len(LM), Equal.sym(Nat, VB.len(LM), VB.pw(dd), lM), hq1)))
  +eWq = Equal.trans(U32, F.flat__nthc(VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K))), q), F.flat__nthc(F.spec_common__update(U32, Mp, q, v), q), U32.or(X, BW.DL(j, b)),
    Equal.cong(List<&2, U32>, U32, z => F.flat__nthc(z, q), VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K))), F.spec_common__update(U32, Mp, q, v), eW),
    Equal.trans(U32, F.flat__nthc(F.spec_common__update(U32, Mp, q, v), q), v, U32.or(X, BW.DL(j, b)),
      F.flat__nthc_same(Mp, q, v, hqMp),
      Equal.cong(U32, U32, z => U32.or(X, z), VBT.DMK(p, K), BW.DL(j, b), hDL)))
  +eXw = Equal.sym(U32, F.flat__nthc(Mp, q), X, nth_wdr(H, LM, q))
  +xx = DL.xr(r, X, VB.slot(T, q), hz,
    h => xq(Mp, S, q, NB, X, eXw, eWin, hlt(q, NB, r, eNW, h)),
    e =>
      Equal.trans(U32, X, VB.slot(D, Nat.add(H, q)), 0,
        VBE.slot_mone_hi(NB, 0n, H, dd, D, T, Nat.add(H, q), pfD, hnd,
          F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(H, q)) == True{} : Bool}, Nat.add(q, H), Nat.add(NB, H),
            Equal.cong(Nat, Nat, z => Nat.add(z, H), q, NB, Equal.sym(Nat, NB, q, nb0(q, NB, r, eNW, e))),
            F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(H, q)) == True{} : Bool}, Nat.add(H, q), Nat.add(q, H), F.nat__add_comm(H, q), F.nat__le_refl(Nat.add(H, q))))),
        hz0))
  +eX = DL.p1(DL.TX1(r, X, VB.slot(T, q)), DL.TX2(r, X), xx)
  +hzX = DL.p2(DL.TX1(r, X, VB.slot(T, q)), DL.TX2(r, X), xx)
  +dd2 = BW.dlc(j, b, X, hj, hb, hzX)
  +d1 = DL.p1(DL.TD1(j, b, X), DL.TD2(j, b, X), dd2)
  +d2 = DL.p2(DL.TD1(j, b, X), DL.TD2(j, b, X), dd2)
  +Wn = VB.wdr(H, F.array__slots(U32, OA(dd, D, T, p, H, K)))
  +h1 = Equal.trans(+List<Bool>, BK.btk(1n+r, BLf.wbits(F.flat__nthc(Wn, q))), BK.btk(1n+r, BLf.wbits(U32.or(X, BW.DL(j, b)))),
      List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}]),
    Equal.cong(U32, +List<Bool>, z => BK.btk(1n+r, BLf.wbits(z)), F.flat__nthc(Wn, q), U32.or(X, BW.DL(j, b)), eWq),
    Equal.trans(+List<Bool>, BK.btk(1n+r, BLf.wbits(U32.or(X, BW.DL(j, b)))), List.append(&2, Bool, BK.btk(r, BLf.wbits(X)), [True{}]), List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}]),
      d1, Equal.cong(+List<Bool>, +List<Bool>, z => List.append(&2, Bool, z, [True{}]), BK.btk(r, BLf.wbits(X)), BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), eX)))
  +h2 = F.logic__subst(U32, z => {BK.zw(1n+r, z) == True{} : Bool}, U32.or(X, BW.DL(j, b)), F.flat__nthc(Wn, q),
    Equal.sym(U32, F.flat__nthc(Wn, q), U32.or(X, BW.DL(j, b)), eWq), d2)
  +hqS = F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, VB.pw(dw), VB.len(S), Equal.sym(Nat, VB.len(S), VB.pw(dw), lS), hqs)
  +hqW = F.logic__subst(List<&2, U32>, z => {Nat.is_lt(q, VB.len(z)) == True{} : Bool}, F.spec_common__update(U32, Mp, q, v), Wn,
    Equal.sym(List<&2, U32>, Wn, F.spec_common__update(U32, Mp, q, v), eW),
    F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, VB.len(Mp), VB.len(F.spec_common__update(U32, Mp, q, v)), Equal.sym(Nat, VB.len(F.spec_common__update(U32, Mp, q, v)), VB.len(Mp), VF.upd_len(Mp, q, v)), hqMp))
  VBT.pack_delim(Wn, S, q, r, cE, hqW, hqS, ep, h1, h2)

