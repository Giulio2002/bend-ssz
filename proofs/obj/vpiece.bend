import Base
import ../../src/obj.bend as O
import ../../types/uint8_encode_ssz_generated.bend as uint8_e
import ../../types/uint16_encode_ssz_generated.bend as uint16_e
import ../../types/bitvector_1281_encode_ssz_generated.bend as bitvector_1281_e
import ../compact/found.bend as FD
import ../../proofs/nat_order.bend as Order
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vbytes.bend as VYS
import ./vua.bend as UA
import ./vuw.bend as UW
import ./vuwd.bend as WD
import ./spec_fixed.bend as FX
import ./vcont.bend as VCN
import ./vuwl_u8.bend as W8
import ./vuwl_u16.bend as W16
import ./vuwl_bv1281.bend as W1281
import ./dk.bend as DK

# The sub-word leaves as pieces of a container's region (hand-written; for codegen/var_cont_enc.py):
# a leaf of m bytes at byte a of a region of L bytes at X = 4 q + r (a + m <= L), written by the
# runtime at Xc = X + c (c = a) at the word position 4 QX(Xc) + RX(Xc) (vcont.vpos / croom,
# vcopy.split4), with its bytes spliced at X0 + a, the region's position of the piece (vcont's
# reg_zero / reg_put): uint8 [x & 255], uint16 [x & 255, (x >> 8) & 255] (vuwl_u8 / vuwl_u16), and
# Bitvector[1281] (vuwl_bv1281: its 161 bytes and the zeros to the end of its last word).

def X0(+q: Nat, +r: Nat) -> Nat: Nat.add(A.quad(q), r)
def QC(+X: U32, +c: U32) -> Nat: VCN.QX(U32.add(X, c))
def RC(+X: U32, +c: U32) -> Nat: VCN.RX(U32.add(X, c))

# The piece's region position is the runtime's word position.
# a < a + m for m >= 1 (a fixed-size piece lies strictly inside its region).
def lt_am(+a: Nat, +m: Nat, +hm: {Nat.is_le(1n, m) == True{} : Bool}, +L: Nat, +hk: {Nat.is_le(Nat.add(a, m), L) == True{} : Bool}) -> {Nat.is_lt(a, L) == True{} : Bool}:
  FD.nat__lt_le_trans(a, Nat.add(a, m), L,
    FD.logic__subst(Nat, z => {Nat.is_lt(a, z) == True{} : Bool}, Nat.add(m, a), Nat.add(a, m), FD.nat__add_comm(m, a),
      FD.nat__lt_le_trans(a, 1n+a, Nat.add(m, a), FD.nat__lt_succ(a), Order.add_right(1n, m, a, hm))), hk)

def pposW(+X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +m: Nat, +dd: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hk: {Nat.is_le(Nat.add(a, m), L) == True{} : Bool}, +hm: {Nat.is_le(1n, m) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.add(X0(q, r), a) == Nat.add(A.quad(QC(X, c)), RC(X, c)) : Nat}:
  +Xc = U32.add(X, c)
  +ep = VCN.vposS(X, c, a, q, r, L, dd, e, ec, hd, lt_am(a, m, hm, L, hk), hl)
  Equal.trans(Nat, Nat.add(X0(q, r), a), U32.to_nat(Xc), Nat.add(A.quad(QC(X, c)), RC(X, c)), Equal.sym(Nat, U32.to_nat(Xc), Nat.add(X0(q, r), a), ep), VC.split4(Xc))

def ppos(+X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +m: Nat, +dd: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hk: {Nat.is_le(Nat.add(a, m), L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.add(X0(q, r), a) == Nat.add(A.quad(QC(X, c)), RC(X, c)) : Nat}:
  +Xc = U32.add(X, c)
  +ep = VCN.vpos(X, c, a, q, r, L, dd, e, ec, hd, FD.nat__le_trans(a, Nat.add(a, m), L, FD.nat__le_add_right(a, m), hk), hl)
  Equal.trans(Nat, Nat.add(X0(q, r), a), U32.to_nat(Xc), Nat.add(A.quad(QC(X, c)), RC(X, c)), Equal.sym(Nat, U32.to_nat(Xc), Nat.add(X0(q, r), a), ep), VC.split4(Xc))

def proomW(+X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +m: Nat, +dd: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hk: {Nat.is_le(Nat.add(a, m), L) == True{} : Bool}, +hm: {Nat.is_le(1n, m) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(QC(X, c), WD.NWN(Nat.add(RC(X, c), m))), VB.pw(dd)) == True{} : Bool}:
  VCN.croom(U32.add(X, c), q, r, a, m, L, dd,
    VCN.vposS(X, c, a, q, r, L, dd, e, ec, hd, lt_am(a, m, hm, L, hk), hl), hk, hl)

def proom(+X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +m: Nat, +dd: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hk: {Nat.is_le(Nat.add(a, m), L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(QC(X, c), WD.NWN(Nat.add(RC(X, c), m))), VB.pw(dd)) == True{} : Bool}:
  VCN.croom(U32.add(X, c), q, r, a, m, L, dd,
    VCN.vpos(X, c, a, q, r, L, dd, e, ec, hd, FD.nat__le_trans(a, Nat.add(a, m), L, FD.nat__le_add_right(a, m), hk), hl), hk, hl)

# ---- uint8 ------------------------------------------------------------------------------------------

def P8(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +x: U32) -> FD.array__Tree<U32>: W8.W8X(RC(X, c), dd, D, QC(X, c), x)
def p8_perfect(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, P8(dd, D, X, c, x)) == True{} : Bool}:
  W8.w8x_perfect(RC(X, c), dd, D, QC(X, c), x, pf)

def u8pieceW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +x: U32,
    +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hk: {Nat.is_le(Nat.add(a, 1n), L) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hz: {VS.bt(1n, VS.bdr(Nat.add(X0(q, r), a), UA.BYT(D))) == UW.ZB(1n) : +List<U32>})
    -> DK.P2({uint8_e.u8_put(FD.array__thaw(U32, D), U32.add(X, c), x) == FD.array__thaw(U32, P8(dd, D, X, c, x)) : Array<U32>},
             {UA.BYT(P8(dd, D, X, c, x)) == UW.SPL(UA.BYT(D), Nat.add(X0(q, r), a), [U32.and(x, 255)]) : +List<U32>}):
  +Xc = U32.add(X, c)
  +pos = Nat.add(A.quad(QC(X, c)), RC(X, c))
  +pp = pposW(X, c, a, q, r, L, 1n, dd, e, ec, hd, hk, {==}, hl)
  +hlc = proomW(X, c, a, q, r, L, 1n, dd, e, ec, hd, hk, {==}, hl)
  +hz2 = FD.logic__subst(Nat, zz => {VS.bt(1n, VS.bdr(zz, UA.BYT(D))) == UW.ZB(1n) : +List<U32>}, Nat.add(X0(q, r), a), pos, pp, hz)
  +by = W8.w8_any_bytesW(dd, D, Xc, QC(X, c), RC(X, c), x, VC.split4(Xc), VCN.rx_lt(Xc), hd, hlc, pf, hz2)
  (W8.w8_anyW(dd, D, Xc, QC(X, c), RC(X, c), x, VC.split4(Xc), VCN.rx_lt(Xc), hd, hlc, pf),
   FD.logic__subst(Nat, zz => {UA.BYT(P8(dd, D, X, c, x)) == UW.SPL(UA.BYT(D), zz, [U32.and(x, 255)]) : +List<U32>}, pos, Nat.add(X0(q, r), a), Equal.sym(Nat, Nat.add(X0(q, r), a), pos, pp), by))

def u8piece(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +x: U32,
    +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hk: {Nat.is_le(Nat.add(a, 1n), L) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hz: {VS.bt(1n, VS.bdr(Nat.add(X0(q, r), a), UA.BYT(D))) == UW.ZB(1n) : +List<U32>})
    -> DK.P2({uint8_e.u8_put(FD.array__thaw(U32, D), U32.add(X, c), x) == FD.array__thaw(U32, P8(dd, D, X, c, x)) : Array<U32>},
             {UA.BYT(P8(dd, D, X, c, x)) == UW.SPL(UA.BYT(D), Nat.add(X0(q, r), a), [U32.and(x, 255)]) : +List<U32>}):
  u8pieceW(dd, D, X, c, a, q, r, L, x, e, ec, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hk, hl, pf, hz)

# ---- uint16 -----------------------------------------------------------------------------------------

def P16(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +x: U32) -> FD.array__Tree<U32>: W16.W16X(RC(X, c), dd, D, QC(X, c), x)
def p16_perfect(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, P16(dd, D, X, c, x)) == True{} : Bool}:
  W16.w16x_perfect(RC(X, c), dd, D, QC(X, c), x, pf)

def u16pieceW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +x: U32,
    +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hk: {Nat.is_le(Nat.add(a, 2n), L) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hz: {VS.bt(2n, VS.bdr(Nat.add(X0(q, r), a), UA.BYT(D))) == UW.ZB(2n) : +List<U32>})
    -> DK.P2({uint16_e.u16_put(FD.array__thaw(U32, D), U32.add(X, c), x) == FD.array__thaw(U32, P16(dd, D, X, c, x)) : Array<U32>},
             {UA.BYT(P16(dd, D, X, c, x)) == UW.SPL(UA.BYT(D), Nat.add(X0(q, r), a), [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)]) : +List<U32>}):
  +Xc = U32.add(X, c)
  +pos = Nat.add(A.quad(QC(X, c)), RC(X, c))
  +pp = pposW(X, c, a, q, r, L, 2n, dd, e, ec, hd, hk, {==}, hl)
  +hlc = proomW(X, c, a, q, r, L, 2n, dd, e, ec, hd, hk, {==}, hl)
  +hz2 = FD.logic__subst(Nat, zz => {VS.bt(2n, VS.bdr(zz, UA.BYT(D))) == UW.ZB(2n) : +List<U32>}, Nat.add(X0(q, r), a), pos, pp, hz)
  +by = W16.w16_any_bytesW(dd, D, Xc, QC(X, c), RC(X, c), x, VC.split4(Xc), VCN.rx_lt(Xc), hd, hlc, pf, hz2)
  (W16.w16_anyW(dd, D, Xc, QC(X, c), RC(X, c), x, VC.split4(Xc), VCN.rx_lt(Xc), hd, hlc, pf),
   FD.logic__subst(Nat, zz => {UA.BYT(P16(dd, D, X, c, x)) == UW.SPL(UA.BYT(D), zz, [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)]) : +List<U32>}, pos, Nat.add(X0(q, r), a),
     Equal.sym(Nat, Nat.add(X0(q, r), a), pos, pp), by))

def u16piece(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +x: U32,
    +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hk: {Nat.is_le(Nat.add(a, 2n), L) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hz: {VS.bt(2n, VS.bdr(Nat.add(X0(q, r), a), UA.BYT(D))) == UW.ZB(2n) : +List<U32>})
    -> DK.P2({uint16_e.u16_put(FD.array__thaw(U32, D), U32.add(X, c), x) == FD.array__thaw(U32, P16(dd, D, X, c, x)) : Array<U32>},
             {UA.BYT(P16(dd, D, X, c, x)) == UW.SPL(UA.BYT(D), Nat.add(X0(q, r), a), [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)]) : +List<U32>}):
  u16pieceW(dd, D, X, c, a, q, r, L, x, e, ec, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hk, hl, pf, hz)

# ---- Bitvector[1281]: 161 bytes and the zeros to the end of the last word -----------------------------

def P1281(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +TB: FD.array__Tree<U32>) -> FD.array__Tree<U32>: W1281.PX_bv1281(RC(X, c), dd, D, QC(X, c), TB)
def p1281_perfect(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +TB: FD.array__Tree<U32>, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, P1281(dd, D, X, c, TB)) == True{} : Bool}:
  W1281.bv1281x_perfect(RC(X, c), dd, D, QC(X, c), TB, pf)

def bv1281pieceW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +dB: Nat, +TB: FD.array__Tree<U32>,
    +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hk: {Nat.is_le(Nat.add(a, 161n), L) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == True{} : Bool},
    +hbz: {O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(161n, WD.PADB(RC(X, c), 161n)), VS.bdr(Nat.add(X0(q, r), a), UA.BYT(D))) == UW.ZB(Nat.add(161n, WD.PADB(RC(X, c), 161n))) : +List<U32>})
    -> DK.P2({bitvector_1281_e.bv1281_putk(FD.array__thaw(U32, D), U32.add(X, c), O.Words{FD.array__thaw(U32, TB), 161}) == (FD.array__thaw(U32, P1281(dd, D, X, c, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)},
             {UA.BYT(P1281(dd, D, X, c, TB)) == UW.SPL(UA.BYT(D), Nat.add(X0(q, r), a), List.append(&2, U32, VS.bt(161n, FX.limbs(UW.SLW(TB))), UW.ZB(WD.PADB(RC(X, c), 161n)))) : +List<U32>}):
  +Xc = U32.add(X, c)
  +pos = Nat.add(A.quad(QC(X, c)), RC(X, c))
  +W = Nat.add(161n, WD.PADB(RC(X, c), 161n))
  +pp = pposW(X, c, a, q, r, L, 161n, dd, e, ec, hd, hk, {==}, hl)
  +hlc = proomW(X, c, a, q, r, L, 161n, dd, e, ec, hd, hk, {==}, hl)
  +hz2 = FD.logic__subst(Nat, zz => {VS.bt(W, VS.bdr(zz, UA.BYT(D))) == UW.ZB(W) : +List<U32>}, Nat.add(X0(q, r), a), pos, pp, hz)
  +by = W1281.bv1281_any_bytesW(dd, D, Xc, QC(X, c), RC(X, c), dB, TB, VC.split4(Xc), VCN.rx_lt(Xc), hd, hlc, pf, pfB, hdB, hrB, htz, hz2)
  (W1281.bv1281_anyW(dd, D, Xc, QC(X, c), RC(X, c), dB, TB, VC.split4(Xc), VCN.rx_lt(Xc), hd, hlc, pf, pfB, hdB, hrB, htz, hbz, hz2),
   FD.logic__subst(Nat, zz => {UA.BYT(P1281(dd, D, X, c, TB)) == UW.SPL(UA.BYT(D), zz, List.append(&2, U32, VS.bt(161n, FX.limbs(UW.SLW(TB))), UW.ZB(WD.PADB(RC(X, c), 161n)))) : +List<U32>},
     pos, Nat.add(X0(q, r), a), Equal.sym(Nat, Nat.add(X0(q, r), a), pos, pp), by))

def bv1281piece(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +dB: Nat, +TB: FD.array__Tree<U32>,
    +e: {U32.to_nat(X) == X0(q, r) : Nat}, +ec: {U32.to_nat(c) == a : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hk: {Nat.is_le(Nat.add(a, 161n), L) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == True{} : Bool},
    +hbz: {O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(161n, WD.PADB(RC(X, c), 161n)), VS.bdr(Nat.add(X0(q, r), a), UA.BYT(D))) == UW.ZB(Nat.add(161n, WD.PADB(RC(X, c), 161n))) : +List<U32>})
    -> DK.P2({bitvector_1281_e.bv1281_putk(FD.array__thaw(U32, D), U32.add(X, c), O.Words{FD.array__thaw(U32, TB), 161}) == (FD.array__thaw(U32, P1281(dd, D, X, c, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)},
             {UA.BYT(P1281(dd, D, X, c, TB)) == UW.SPL(UA.BYT(D), Nat.add(X0(q, r), a), List.append(&2, U32, VS.bt(161n, FX.limbs(UW.SLW(TB))), UW.ZB(WD.PADB(RC(X, c), 161n)))) : +List<U32>}):
  bv1281pieceW(dd, D, X, c, a, q, r, L, dB, TB, e, ec, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hk, hl, pf, pfB, hdB, hrB, htz, hbz, hz)
