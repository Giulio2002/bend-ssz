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
import ../proofs/obj/vmul_generated.bend as VM
import ../proofs/obj/elems48_light.bend as E48
import ../proofs/obj/cells_light.bend as CE
import ./e2e_ve_DataColumnSidecar_generated.bend as VEV

# DataColumnSidecar's three decoded lists (proofs/obj/var_codec_DataColumnSidecar_acc_generated.bend): a whole number of 2048-byte cells and of
# 48-byte commitments / proofs, copied unmasked from word q of the buffer into a zero tree of depth DZ(L): the storage premise sdd,
# the representation invariant's tree wfe and the units' check. Hand written, like e2e_dkz.bend.

def MM(+t: FD.array__Tree<U32>, +q: Nat, +L: U32) -> FD.array__Tree<U32>: VB.mone(VC.NW(L), q, 0n, VLS.DZ(L), VC.ZT(VLS.DZ(L)), t)

def mpf(+t: FD.array__Tree<U32>, +q: Nat, +L: U32) -> {FD.array__perfect(U32, VLS.DZ(L), MM(t, q, L)) == True{} : Bool}:
  VB.mone_perfect(VC.NW(L), q, 0n, VLS.DZ(L), VC.ZT(VLS.DZ(L)), t, FD.array__trep_perfect(U32, VLS.DZ(L), 0))

def dz31(+L: U32, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}) -> {Nat.is_lt(VLS.DZ(L), 31n) == True{} : Bool}:
  FD.nat__le_lt_trans(VLS.DZ(L), 30n, 31n, VC.dz30(L, hy), {==})

# the storage premise at depth below 31
def sddL(+t: FD.array__Tree<U32>, +q: Nat, +L: U32, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool})
    -> VEV.sdd(O.Words{FD.array__thaw(U32, MM(t, q, L)), L}, 31n):
  (MM(t, q, L), (VLS.DZ(L), (L, ({==}, (mpf(t, q, L), dz31(L, hy))))))

# its words fit the tree
def hrg0(+L: U32, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}) -> {Nat.is_le(VC.NW(L), O.pow2n(VLS.DZ(L))) == True{} : Bool}:
  FD.nat__le_trans(VC.NW(L), U32.to_nat(VC.WZ(L)), O.pow2n(VLS.DZ(L)), VC.nw_le_wzu(L, hy), VD.wd_cover(VC.WZ(L), 30n, {==}, VC.wz30(L, hy)))

def hrgL(+L: U32, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}) -> {Nat.is_le(VC.NW(L), FD.spec_common__pow2(VLS.DZ(L))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(VC.NW(L), z) == True{} : Bool}, O.pow2n(VLS.DZ(L)), FD.spec_common__pow2(VLS.DZ(L)), Equal.sym(Nat, FD.spec_common__pow2(VLS.DZ(L)), O.pow2n(VLS.DZ(L)), VD.s_pow2_eq(VLS.DZ(L))), hrg0(L, hy))

def meE(+E: Nat, +c: Nat) -> {VM.mulE(E, c) == Nat.mul(c, E) : Nat}:
  match c:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => Nat.add(E, z), VM.mulE(E, p), Nat.mul(p, E), meE(E, p))

# the commitments' / proofs' tree invariant (wfe of elems48_light)
def wfe48L(+t: FD.array__Tree<U32>, +q: Nat, +L: U32, +c: Nat, +ec: {E48.k48(L) == c : Nat}, +em: {U32.to_nat(L) == A.quad(VM.mulE(12n, c)) : Nat},
    +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}) -> E48.wfe(O.Words{FD.array__thaw(U32, MM(t, q, L)), L}):
  (MM(t, q, L), (VLS.DZ(L), (L, ({==}, (mpf(t, q, L), (FD.nat__le_lt_trans(VLS.DZ(L), 30n, 32n, VC.dz30(L, hy), {==}),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(z, 12n), FD.spec_common__pow2(VLS.DZ(L))) == True{} : Bool}, c, E48.k48(L), Equal.sym(Nat, E48.k48(L), c, ec),
      FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(VLS.DZ(L))) == True{} : Bool}, VC.NW(L), Nat.mul(c, 12n),
        Equal.trans(Nat, VC.NW(L), VM.mulE(12n, c), Nat.mul(c, 12n), VL.nwmA(L, VM.mulE(12n, c), em), meE(12n, c)), hrgL(L, hy)))))))))

# the cells' tree invariant (wfe of cells_light)
def wfecL(+t: FD.array__Tree<U32>, +q: Nat, +L: U32, +c: Nat, +ec: {CE.kc(L) == c : Nat}, +em: {U32.to_nat(L) == A.quad(VM.mulE(512n, c)) : Nat},
    +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}) -> CE.wfe(O.Words{FD.array__thaw(U32, MM(t, q, L)), L}):
  (MM(t, q, L), (VLS.DZ(L), (L, ({==}, (mpf(t, q, L), (FD.nat__le_lt_trans(VLS.DZ(L), 30n, 32n, VC.dz30(L, hy), {==}),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(z, 512n), FD.spec_common__pow2(VLS.DZ(L))) == True{} : Bool}, c, CE.kc(L), Equal.sym(Nat, CE.kc(L), c, ec),
      FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(VLS.DZ(L))) == True{} : Bool}, VC.NW(L), Nat.mul(c, 512n),
        Equal.trans(Nat, VC.NW(L), VM.mulE(512n, c), Nat.mul(c, 512n), VL.nwmA(L, VM.mulE(512n, c), em), meE(512n, c)), hrgL(L, hy)))))))))

# a whole number of units (the object API's own validity: its unit conjunct)
def mod0(+L: U32, +e: U32, +lim: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool}, +hz: {U32.is_zero(e) == False{} : Bool},
    +h: {Bool.and(U32.is_eq(L, U32.mul(U32.div(L, e), e)), U32.is_le(U32.div(L, e), lim)) == True{} : Bool})
    -> {U32.is_eq(U32.mod(L, e), 0) == True{} : Bool}:
  +ec = Pair.fst({U32.to_nat(L) == Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)) : Nat}, {Nat.is_le(U32.to_nat(U32.div(L, e)), U32.to_nat(lim)) == True{} : Bool}, VU.whole_t(L, e, lim, v, eb, hb, hz, h))
  +er = Pair.snd({U32.to_nat(U32.div(L, e)) == U32.to_nat(U32.div(L, e)) : Nat}, {U32.to_nat(U32.mod(L, e)) == 0n : Nat},
    VU.whole_q(L, e, U32.to_nat(U32.div(L, e)), ec, hb, VU.div_u32(L, e, v, eb, hb, hz)))
  FD.u32alg__eq_true(U32.mod(L, e), 0, FD.u32__injective(U32.mod(L, e), 0, er))

# the count within the limit
def cntL(+L: U32, +e: U32, +lim: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool}, +hz: {U32.is_zero(e) == False{} : Bool},
    +h: {Bool.and(U32.is_eq(L, U32.mul(U32.div(L, e), e)), U32.is_le(U32.div(L, e), lim)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(U32.div(L, e)), U32.to_nat(lim)) == True{} : Bool}:
  Pair.snd({U32.to_nat(L) == Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)) : Nat}, {Nat.is_le(U32.to_nat(U32.div(L, e)), U32.to_nat(lim)) == True{} : Bool}, VU.whole_t(L, e, lim, v, eb, hb, hz, h))
