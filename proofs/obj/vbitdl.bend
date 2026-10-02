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
import ./vbenc.bend as VBE
import ./vbitenc.bend as VBT
import ./var_bits_enc_bw_generated.bend as BW
import ../../src/obj.bend as O

# The words a bit list encodes to at offset 0 of a zero buffer: the first q
# words of the object, then word q with the delimiter bit OR-ed in; they pack
# to the spec encoding of the object's bits and the delimiter.

# The object invariant at word q: its bits r..31 are zero (none needed at r = 0,
# where the copy stops before word q).
def HZ(+r: Nat, +x: U32) -> Bool:
  match r:
    case 0n: True{}
    case 1n+p: BW.hzw(1n+p, x)

def cw1(+r: Nat, +h: {Nat.is_lt(0n, r) == True{} : Bool}) -> {BW.CWr(r) == 1n : Nat}:
  match r:
    case 0n: Empty.absurd({BW.CWr(0n) == 1n : Nat}, F.logic__false_true(h))
    case 1n+ +p: {==}

def lt_add1(+q: Nat) -> {Nat.is_lt(q, Nat.add(q, 1n)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(q, 1n), 1n+q, F.nat__add_comm(q, 1n)) : {Nat.is_lt(q, _) == True{} : Bool}
  F.nat__lt_succ(q)

# The word the copy leaves at q, before the delimiter: the object's (r > 0) or zero (r = 0).
law xr:
  for +r: Nat
  for +X: U32
  for +Sq: U32
  for +hz: {HZ(r, Sq) == True{} : Bool}
  for hX: {Nat.is_lt(0n, r) == True{} : Bool} -> {X == Sq : U32}
  for h0: {r == 0n : Nat} -> {X == 0 : U32}
  DK.P2({BK.btk(r, BLf.wbits(X)) == BK.btk(r, BLf.wbits(Sq)) : +List<Bool>}, {BW.hzw(r, X) == True{} : Bool})
def xr(r, X, Sq, hz, hX, h0):
  match r:
    case 0n:
      %Equal.sym(U32, X, 0, h0({==})) : DK.P2({BK.btk(0n, BLf.wbits(_)) == BK.btk(0n, BLf.wbits(Sq)) : +List<Bool>}, {BW.hzw(0n, _) == True{} : Bool})
      ({==}, {==})
    case 1n+ +p:
      %Equal.sym(U32, X, Sq, hX({==})) : DK.P2({BK.btk(1n+p, BLf.wbits(_)) == BK.btk(1n+p, BLf.wbits(Sq)) : +List<Bool>}, {BW.hzw(1n+p, _) == True{} : Bool})
      ({==}, hz)

def p1(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:
  (+a, +b) = p
  a

def p2(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:
  (+a, +b) = p
  b

# The parts of BW.cfj, BW.dlc and xr, for projecting.
def TA(+j: Nat, +b: Nat) -> Data: {VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)) == BW.CWr(Nat.add(VS.x8(j), b)) : Nat}
def TB(+b: Nat) -> Data: {Nat.is_le(VD.s_rng(3n, Nat.add(b, 7n)), 1n) == True{} : Bool}
def TC(+j: Nat, +b: Nat) -> Data: {VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b))) == 0n : Nat}
def TD(+j: Nat) -> Data: {VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n)) == 1n : Nat}
def TE(+j: Nat, +b: Nat) -> Data: {Nat.is_le(Nat.add(VS.x8(j), b), 31n) == True{} : Bool}
def TF(+j: Nat, +b: Nat) -> Data: {Bp.byte_count(1n+Nat.add(VS.x8(j), b)) == Nat.add(j, 1n) : Nat}
def CE(+j: Nat, +b: Nat) -> Data: DK.P2(TE(j, b), TF(j, b))
def CD(+j: Nat, +b: Nat) -> Data: DK.P2(TD(j), CE(j, b))
def CC(+j: Nat, +b: Nat) -> Data: DK.P2(TC(j, b), CD(j, b))
def CB(+j: Nat, +b: Nat) -> Data: DK.P2(TB(b), CC(j, b))
def CA(+j: Nat, +b: Nat) -> Data: DK.P2(TA(j, b), CB(j, b))
def TD1(+j: Nat, +b: Nat, +x: U32) -> Data: {BK.btk(1n+Nat.add(VS.x8(j), b), BLf.wbits(U32.or(x, BW.DL(j, b)))) == List.append(&2, Bool, BK.btk(Nat.add(VS.x8(j), b), BLf.wbits(x)), [True{}]) : +List<Bool>}
def TD2(+j: Nat, +b: Nat, +x: U32) -> Data: {BK.zw(1n+Nat.add(VS.x8(j), b), U32.or(x, BW.DL(j, b))) == True{} : Bool}
def TX1(+r: Nat, +X: U32, +Sq: U32) -> Data: {BK.btk(r, BLf.wbits(X)) == BK.btk(r, BLf.wbits(Sq)) : +List<Bool>}
def TX2(+r: Nat, +X: U32) -> Data: {BW.hzw(r, X) == True{} : Bool}

def MZ(+dd: Nat, +T: F.array__Tree<U32>, +K: U32) -> F.array__Tree<U32>: VBT.MT(dd, VC.ZT(dd), T, 0n, K)
def OZ(+dd: Nat, +T: F.array__Tree<U32>, +K: U32) -> F.array__Tree<U32>: VBT.OUTB(dd, VC.ZT(dd), T, 0, 0n, K, VBT.QK(K))
def RK(+K: U32) -> Nat: Nat.add(VS.x8(VBT.JK(K)), VBT.BKk(K))

def words_pack(+dd: Nat, +dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: VBT.HK(K, kb),
    +hnd: {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), 0n), VB.pw(dd)) == True{} : Bool},
    +hns: {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), 0n), VB.pw(dw)) == True{} : Bool},
    +hqd: {Nat.is_lt(VBT.QK(K), VB.pw(dd)) == True{} : Bool}, +hqs: {Nat.is_lt(VBT.QK(K), VB.pw(dw)) == True{} : Bool},
    +hz: {HZ(RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool})
    -> {Bp.pack(List.append(&2, Bool, BK.btk(Nat.add(VBT.m32(VBT.QK(K)), RK(K)), BK.bitsof(F.array__slots(U32, T))), [True{}]))
        == VS.bt(Bp.byte_count(Nat.add(VBT.m32(VBT.QK(K)), 1n+RK(K))), FX.limbs(F.array__slots(U32, OZ(dd, T, K)))) : +List<U32>}:
  +q = VBT.QK(K)
  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +r = RK(K)
  +S = F.array__slots(U32, T)
  +Z = F.array__slots(U32, VC.ZT(dd))
  +M = MZ(dd, T, K)
  +NB = VC.NW(O.bits_nbytes(K))
  +X = VB.slot(M, q)
  +hj = F.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = F.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)
  +cA = p1(TA(j, b), CB(j, b), cf)
  +cB = p1(TB(b), CC(j, b), p2(TA(j, b), CB(j, b), cf))
  +cE = p1(TE(j, b), TF(j, b), p2(TD(j), CE(j, b), p2(TC(j, b), CD(j, b), p2(TB(b), CC(j, b), p2(TA(j, b), CB(j, b), cf)))))
  +pfZ = F.array__trep_perfect(U32, dd, 0)
  +pfM = VB.mone_perfect(NB, 0n, 0n, dd, VC.ZT(dd), T, pfZ)
  +pfO = F.array__upd_perfect(U32, dd, M, q, U32.or(X, VBT.DMK(0, K)), pfM)
  # NW of the byte count: q, plus one when the last word is partial.
  +eNW = Equal.trans(Nat, NB, Nat.add(q, VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n))), Nat.add(q, BW.CWr(r)),
    VBT.FNWnb(K, kb, hkb, hK, j, b, Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), {==}, {==}, {==}, cB, {==}),
    Equal.cong(Nat, Nat, z => Nat.add(q, z), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), BW.CWr(r), cA))
  +lZ = F.array__slots_length(U32, dd, VC.ZT(dd), pfZ)
  +lS = F.array__slots_length(U32, dw, T, pfT)
  +lM = F.array__slots_length(U32, dd, M, pfM)
  +lO = F.array__slots_length(U32, dd, OZ(dd, T, K), pfO)
  +hZ = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(NB, 0n), z) == True{} : Bool}, VB.pw(dd), VB.len(Z), Equal.sym(Nat, VB.len(Z), VB.pw(dd), lZ), hnd)
  +hS = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(NB, 0n), z) == True{} : Bool}, VB.pw(dw), VB.len(S), Equal.sym(Nat, VB.len(S), VB.pw(dw), lS), hns)
  +eM = VB.slots_mone(NB, 0n, 0n, dd, VC.ZT(dd), T, pfZ, hnd)
  +eO = F.array__upd_slots(U32, dd, M, q, U32.or(X, VBT.DMK(0, K)), hqd, pfM)
  # q <= NW
  +hqN = F.logic__subst(Nat, z => {Nat.is_le(q, z) == True{} : Bool}, Nat.add(q, BW.CWr(r)), NB, Equal.sym(Nat, NB, Nat.add(q, BW.CWr(r)), eNW), F.nat__le_add_right(q, BW.CWr(r)))
  # the first q words
  +ep = Equal.trans(List<&2, U32>, VS.wtake(q, F.array__slots(U32, OZ(dd, T, K))), VS.wtake(q, F.array__slots(U32, M)), VS.wtake(q, S),
    Equal.trans(List<&2, U32>, VS.wtake(q, F.array__slots(U32, OZ(dd, T, K))), VS.wtake(q, F.spec_common__update(U32, F.array__slots(U32, M), q, U32.or(X, VBT.DMK(0, K)))), VS.wtake(q, F.array__slots(U32, M)),
      Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(q, z), F.array__slots(U32, OZ(dd, T, K)), F.spec_common__update(U32, F.array__slots(U32, M), q, U32.or(X, VBT.DMK(0, K))), eO),
      VF.take_upd(q, F.array__slots(U32, M), q, U32.or(X, VBT.DMK(0, K)), F.nat__le_refl(q))),
    Equal.trans(List<&2, U32>, VS.wtake(q, F.array__slots(U32, M)), VS.wtake(q, VB.lm(NB, 0n, 0n, Z, S)), VS.wtake(q, S),
      Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(q, z), F.array__slots(U32, M), VB.lm(NB, 0n, 0n, Z, S), eM),
      VBT.take_lm(q, NB, Z, S, hqN, hZ, hS)))
  # word q
  +hqM = F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, VB.pw(dd), VB.len(F.array__slots(U32, M)), Equal.sym(Nat, VB.len(F.array__slots(U32, M)), VB.pw(dd), lM), hqd)
  +eWq = Equal.trans(U32, F.flat__nthc(F.array__slots(U32, OZ(dd, T, K)), q), F.flat__nthc(F.spec_common__update(U32, F.array__slots(U32, M), q, U32.or(X, VBT.DMK(0, K))), q), U32.or(X, BW.DL(j, b)),
    Equal.cong(List<&2, U32>, U32, z => F.flat__nthc(z, q), F.array__slots(U32, OZ(dd, T, K)), F.spec_common__update(U32, F.array__slots(U32, M), q, U32.or(X, VBT.DMK(0, K))), eO),
    Equal.trans(U32, F.flat__nthc(F.spec_common__update(U32, F.array__slots(U32, M), q, U32.or(X, VBT.DMK(0, K))), q), U32.or(X, VBT.DMK(0, K)), U32.or(X, BW.DL(j, b)),
      F.flat__nthc_same(F.array__slots(U32, M), q, U32.or(X, VBT.DMK(0, K)), hqM),
      Equal.cong(U32, U32, z => U32.or(X, z), VBT.DMK(0, K), BW.DL(j, b), BW.dmk_dl(K, j, b, {==}, {==}, hj, hb))))
  # X: the object's word q when r > 0, zero when r = 0
  +xx = xr(r, X, VB.slot(T, q), hz,
    h =>
      Equal.trans(U32, X, F.flat__nthc(VB.lm(NB, 0n, 0n, Z, S), q), F.flat__nthc(S, q),
        Equal.cong(List<&2, U32>, U32, z => F.flat__nthc(z, q), F.array__slots(U32, M), VB.lm(NB, 0n, 0n, Z, S), eM),
        VBT.nth_lm_in(q, NB, Z, S,
          F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, Nat.add(q, 1n), NB,
            Equal.trans(Nat, Nat.add(q, 1n), Nat.add(q, BW.CWr(r)), NB, Equal.cong(Nat, Nat, z => Nat.add(q, z), 1n, BW.CWr(r), Equal.sym(Nat, BW.CWr(r), 1n, cw1(r, h))), Equal.sym(Nat, NB, Nat.add(q, BW.CWr(r)), eNW)),
            lt_add1(q)),
          hZ, hS)),
    e =>
      Equal.trans(U32, X, VB.slot(VC.ZT(dd), q), 0,
        VBE.slot_mone_hi(NB, 0n, 0n, dd, VC.ZT(dd), T, q, pfZ, hnd,
          F.logic__subst(Nat, z => {Nat.is_le(z, q) == True{} : Bool}, q, Nat.add(NB, 0n),
            Equal.sym(Nat, Nat.add(NB, 0n), q, Equal.trans(Nat, Nat.add(NB, 0n), NB, q, F.nat__add_zero(NB),
              Equal.trans(Nat, NB, Nat.add(q, BW.CWr(r)), q, eNW,
                Equal.trans(Nat, Nat.add(q, BW.CWr(r)), Nat.add(q, 0n), q, Equal.cong(Nat, Nat, z => Nat.add(q, BW.CWr(z)), r, 0n, e), F.nat__add_zero(q))))),
            F.nat__le_refl(q))),
        VBE.slot_zt(dd, q)))
  +eX = p1(TX1(r, X, VB.slot(T, q)), TX2(r, X), xx)
  +hzX = p2(TX1(r, X, VB.slot(T, q)), TX2(r, X), xx)
  +dd2 = BW.dlc(j, b, X, hj, hb, hzX)
  +d1 = p1(TD1(j, b, X), TD2(j, b, X), dd2)
  +d2 = p2(TD1(j, b, X), TD2(j, b, X), dd2)
  +h1 = Equal.trans(+List<Bool>, BK.btk(1n+r, BLf.wbits(F.flat__nthc(F.array__slots(U32, OZ(dd, T, K)), q))), BK.btk(1n+r, BLf.wbits(U32.or(X, BW.DL(j, b)))),
      List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}]),
    Equal.cong(U32, +List<Bool>, z => BK.btk(1n+r, BLf.wbits(z)), F.flat__nthc(F.array__slots(U32, OZ(dd, T, K)), q), U32.or(X, BW.DL(j, b)), eWq),
    Equal.trans(+List<Bool>, BK.btk(1n+r, BLf.wbits(U32.or(X, BW.DL(j, b)))), List.append(&2, Bool, BK.btk(r, BLf.wbits(X)), [True{}]), List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}]),
      d1, Equal.cong(+List<Bool>, +List<Bool>, z => List.append(&2, Bool, z, [True{}]), BK.btk(r, BLf.wbits(X)), BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), eX)))
  +h2 = F.logic__subst(U32, z => {BK.zw(1n+r, z) == True{} : Bool}, U32.or(X, BW.DL(j, b)), F.flat__nthc(F.array__slots(U32, OZ(dd, T, K)), q),
    Equal.sym(U32, F.flat__nthc(F.array__slots(U32, OZ(dd, T, K)), q), U32.or(X, BW.DL(j, b)), eWq), d2)
  +hqW = F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, VB.pw(dd), VB.len(F.array__slots(U32, OZ(dd, T, K))), Equal.sym(Nat, VB.len(F.array__slots(U32, OZ(dd, T, K))), VB.pw(dd), lO), hqd)
  +hqS = F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, VB.pw(dw), VB.len(S), Equal.sym(Nat, VB.len(S), VB.pw(dw), lS), hqs)
  VBT.pack_delim(F.array__slots(U32, OZ(dd, T, K)), S, q, r, cE, hqW, hqS, ep, h1, h2)
