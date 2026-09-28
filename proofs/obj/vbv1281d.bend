import Base
import ../../src/obj.bend as O
import ../../types/bitvector_1281_encode_ssz_generated.bend as bitvector_1281_e
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vua.bend as UA
import ./vuw.bend as UW
import ./vuwd.bend as UWD
import ./spec_fixed.bend as FX
import ./vcopy.bend as VC
import ./vbytes.bend as VYS
import ./vlist.bend as VLS
import ../compact/reads.bend as RD
import ./vuwl_bv1281.bend as W1281
import ./vputwd.bend as VPW
import ./vbrt.bend as VR

# Bitvector[1281] (161 bytes held as O.Words) written data-only at any byte position (hand-written):
# vuwl_bv1281's check, then vputwd's O.put_words; only its 161 bytes zero beforehand, room for one more
# word after them (q + NWN(r + 165) <= 2^dd).

def PXD(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +TB: FD.array__Tree<U32>) -> FD.array__Tree<U32>: VPW.PWD(r, dd, D, q, TB, 161)
def pxd_perfect(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +TB: FD.array__Tree<U32>, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PXD(r, dd, D, q, TB)) == True{} : Bool}:
  VPW.pwd_perfect(r, dd, D, q, TB, 161, pf)

def n42(+r: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}) -> {Nat.is_le(42n, UWD.NWN(Nat.add(r, 165n))) == True{} : Bool}:
  match r:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +t: Empty.absurd({Nat.is_le(42n, UWD.NWN(Nat.add(4n+t, 165n))) == True{} : Bool}, FD.nat__lt_zero_absurd(t, hr))


# 41 words and one more: q + 41 < 2^dd
def room(+q: Nat, +r: Nat, +dd: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 165n))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(VC.NW(161), q), VB.pw(dd)) == True{} : Bool}:
  +h42 = FD.nat__le_trans(Nat.add(q, 42n), Nat.add(q, UWD.NWN(Nat.add(r, 165n))), VB.pw(dd), Order.add_left(q, 42n, UWD.NWN(Nat.add(r, 165n)), n42(r, hr)), hl)
  FD.nat__succ_le_lt(Nat.add(41n, q), VB.pw(dd), FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 42n), 42n+q, FD.nat__add_comm(q, 42n), h42))
def hsrc(+dB: Nat, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool}, +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}) -> {Nat.is_le(VC.NW(161), VB.pw(dB)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dB)) == True{} : Bool}, Nat.add(VC.NW(161), 0n), VC.NW(161), FD.nat__add_zero(VC.NW(161)), W1281.hrm(dB, hdB, hrB))

# T.bv1281_putk at X = 4 q + r: its check passes, the write is the model, its size flag 0.
def bv1281d_anyW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 165n))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == True{} : Bool},
    +hbz: {O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))) == True{} : Bool}, +hz: {VS.bt(161n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(161n) : +List<U32>})
    -> {bitvector_1281_e.bv1281_putk(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, TB), 161}) == (FD.array__thaw(U32, PXD(r, dd, D, q, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)}:
  %Equal.sym(O.Words & Bool, bitvector_1281_e.bv1281_valid(O.Words{FD.array__thaw(U32, TB), 161}), (O.Words{FD.array__thaw(U32, TB), 161}, True{}), W1281.valid(dB, TB, pfB, hdB, hrB, htz, hbz)) :
    {bitvector_1281_e.bv1281_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PXD(r, dd, D, q, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)}
  %Equal.sym(Array<U32> & O.Words, O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, TB), 161}), (FD.array__thaw(U32, PXD(r, dd, D, q, TB)), O.Words{FD.array__thaw(U32, TB), 161}),
      VPW.putwd_anyW(dd, D, X, q, r, dB, TB, 161, VLS.KK(dB), e, hr, hd, FD.nat__lt_trans(dB, 28n, 31n, hdB, {==}), VLS.kk_lt(dB, hdB), VLS.hyn(dB, 161, hrB),
        hsrc(dB, hdB, hrB), room(q, r, dd, hr, hl), pf, pfB, hz)) :
    {bitvector_1281_e.bv1281_pk_ok(_) == (FD.array__thaw(U32, PXD(r, dd, D, q, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)}
  {==}

def bv1281d_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 165n))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == True{} : Bool},
    +hbz: {O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n))) == True{} : Bool}, +hz: {VS.bt(161n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(161n) : +List<U32>})
    -> {bitvector_1281_e.bv1281_putk(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, TB), 161}) == (FD.array__thaw(U32, PXD(r, dd, D, q, TB)), (O.Words{FD.array__thaw(U32, TB), 161}, 0)) : Array<U32> & (O.Words & U32)}:
  bv1281d_anyW(dd, D, X, q, r, dB, TB, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf, pfB, hdB, hrB, htz, hbz, hz)

# Its bytes: the 161 bytes spliced in, the bytes after them kept.
def bv1281d_any_bytesW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 165n))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == True{} : Bool}, +hz: {VS.bt(161n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(161n) : +List<U32>})
    -> {UA.BYT(PXD(r, dd, D, q, TB)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VS.bt(161n, FX.limbs(UW.SLW(TB)))) : +List<U32>}:
  VPW.putwd_any_bytesW(dd, D, X, q, r, dB, TB, 161, VLS.KK(dB), e, hr, hd, FD.nat__lt_trans(dB, 28n, 31n, hdB, {==}), VLS.kk_lt(dB, hdB), VLS.hyn(dB, 161, hrB),
    hsrc(dB, hdB, hrB), room(q, r, dd, hr, hl), pf, pfB, hz, htz)

def bv1281d_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 165n))), VB.pw(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +htz: {O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161))) == True{} : Bool}, +hz: {VS.bt(161n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(161n) : +List<U32>})
    -> {UA.BYT(PXD(r, dd, D, q, TB)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VS.bt(161n, FX.limbs(UW.SLW(TB)))) : +List<U32>}:
  bv1281d_any_bytesW(dd, D, X, q, r, dB, TB, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf, pfB, hdB, hrB, htz, hz)

# ---- for the containers (codegen/var_cont_enc.py's FixW) ----
def HTZ(+TB: FD.array__Tree<U32>) -> Bool: O.tail_zero(U32.and(161, 3), VB.slot(TB, VYS.QL(161)))
def HBZ(+dB: Nat, +TB: FD.array__Tree<U32>) -> Bool: O.bits_above_zero(U32.and(1281, 31), RD.wd(TB, dB, U32.shrn(1281, 5n)))
def lenY(+dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool})
    -> {List.length(&2, U32, VS.bt(161n, FX.limbs(UW.SLW(TB)))) == 161n : Nat}:
  VS.bt_len(161n, FX.limbs(UW.SLW(TB)), FD.logic__subst(Nat, z => {Nat.is_le(161n, z) == True{} : Bool}, A.quad(VB.pw(dB)), List.length(&2, U32, FX.limbs(UW.SLW(TB))),
    Equal.sym(Nat, List.length(&2, U32, FX.limbs(UW.SLW(TB))), A.quad(VB.pw(dB)), VR.lenS(dB, TB, pfB)), hrB))
def valid_ok(+dB: Nat, +TB: FD.array__Tree<U32>, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 28n) == True{} : Bool},
    +hrB: {Nat.is_le(161n, A.quad(VB.pw(dB))) == True{} : Bool}, +htz: {HTZ(TB) == True{} : Bool}, +hbz: {HBZ(dB, TB) == True{} : Bool})
    -> {bitvector_1281_e.bv1281_valid(O.Words{FD.array__thaw(U32, TB), 161}) == (O.Words{FD.array__thaw(U32, TB), 161}, True{}) : O.Words & Bool}:
  W1281.valid(dB, TB, pfB, hdB, hrB, htz, hbz)
