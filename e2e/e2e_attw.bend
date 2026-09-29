import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../types/primitive.bend as P
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/spec_fixed.bend as F
import ../proofs/obj/spec_bits.bend as FB
import ./e2e_cap.bend as C
import ./e2e_bits.bend as E2B
import ../proofs/obj/root_types_light.bend as RT
import ../proofs/obj/var_win_Attestation.bend as CHA
import ../proofs/obj/var_win_bits131072.bend as CHB
import ../proofs/obj/bitlist_rep.bend as BR
import ../proofs/obj/bitlist_pack.bend as BK
import ../proofs/obj/vbitl.bend as VBL
import ../proofs/obj/vbyte.bend as VY
import ../proofs/obj/vspec.bend as VSP
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/vlist.bend as VLS
import ../proofs/obj/vbrt.bend as VR
import ../proofs/obj/vu32.bend as VU
import ../proofs/obj/vua.bend as UA
import ../proofs/obj/vua_win.bend as UW
import ../proofs/obj/vua_ct.bend as UCT
import ./e2e_bview.bend as BV
import ./e2e_bvw.bend as BVW
import ./e2e_hv.bend as HV
import ./e2e_bitv.bend as BTV

def bl_bwa(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHB.CHKw(t, i, off, len) == True{} : Bool})
    -> {S.BitsValue{BR.bview(CHB.OBJw(t, i, off, len))} == CHB.VALw(t, i, len) : S.Value}:
  +e1 = CHB.cE(t, i, off, len, hchk)
  +h1 = CHB.c1(t, i, off, len, hchk)
  +nz = CHB.cB(t, off, len, h1)
  +bd = CHB.cC(t, off, len, h1, nz)
  +m = CHB.M1(len)
  +hb = CHB.hB(t, off, len, e1, bd)
  +hL = CHB.hlen(d, i, len, hw, hw32)
  +dz = VLS.DZ(len)
  +M = VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t)
  +pfM = VB.mone_perfect(VC.NW(len), i, 0n, dz, VC.ZT(dz), t, FD.array__trep_perfect(U32, dz, 0))
  +hdz = FD.nat__le_lt_trans(dz, 13n, 32n, CHB.hdzK(d, len, hd, hL, hb), {==})
  +hr0 = CHB.hrgB(len, hb)
  +hy = CHB.hyB(len, hb)
  +V = CHB.V(t, off, len)
  +h = VY.hb(V)
  +hm8 = FD.nat__le_trans(Nat.mul(8n, m), CHB.BD(t, off, len), U32.to_nat(131072), FD.nat__le_add_right(Nat.mul(8n, m), h), bd)
  +emul = VU.mul_le(8, U32.sub(len, 1), 131072, hm8)
  +hadd = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, h), U32.to_nat(131072)) == True{} : Bool}, Nat.mul(8n, m), U32.to_nat(U32.mul(8, U32.sub(len, 1))), Equal.sym(Nat, U32.to_nat(U32.mul(8, U32.sub(len, 1))), Nat.mul(8n, m), emul), bd)
  +eNB = Equal.trans(Nat, U32.to_nat(CHB.NB(t, off, len)), Nat.add(U32.to_nat(U32.mul(8, U32.sub(len, 1))), h), Nat.add(VSP.x8(m), h), A.add_le(U32.mul(8, U32.sub(len, 1)), O.high_bit(V), 131072, hadd),
    Equal.cong(Nat, Nat, z => Nat.add(z, h), U32.to_nat(U32.mul(8, U32.sub(len, 1))), VSP.x8(m), Equal.trans(Nat, U32.to_nat(U32.mul(8, U32.sub(len, 1))), Nat.mul(8n, m), VSP.x8(m), emul, VR.mul8(m))))
  +hNW = VC.eNW(len, 15n, {==}, hy)
  +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(dz)) == True{} : Bool}, Nat.add(VC.NW(len), 0n), C.nwn(U32.to_nat(len)),
    Equal.trans(Nat, Nat.add(VC.NW(len), 0n), VC.NW(len), C.nwn(U32.to_nat(len)), FD.nat__add_zero(VC.NW(len)), hNW), hr0)
  +hn3 = BVW.hn3y(len, 15n, {==}, hy)
  +hh = BV.hb7(V)
  +A1 = BV.vobj(len, dz, M, CHB.NB(t, off, len), m, h, pfM, hdz, hh, eNB, hN, hn3, e1)
  +W1 = VR.WB(t, i, 1n+m)
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hw)
  +ew = BV.winG(d, t, len, i, m, dz, pf, hw, e1, hNW, hr0)
  +hlM = VR.lenS(dz, M, pfM)
  +hq4 = FD.nat__le_trans(1n+m, A.quad(C.nwn(U32.to_nat(len))), A.quad(VB.pw(dz)),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(C.nwn(U32.to_nat(len)))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, C.ng(U32.to_nat(len))), C.q4(C.nwn(U32.to_nat(len)), VB.pw(dz), hN))
  +hl = FD.logic__subst(Nat, z => {Nat.is_lt(m, z) == True{} : Bool}, A.quad(VB.pw(dz)), List.length(&2, U32, F.limbs(FD.array__slots(U32, M))), Equal.sym(Nat, List.length(&2, U32, F.limbs(FD.array__slots(U32, M))), A.quad(VB.pw(dz)), hlM),
    FD.nat__succ_le_lt(m, A.quad(VB.pw(dz)), hq4))
  +hlv = VR.lenWB(d, t, i, 1n+m, pf, hw1)
  +eh = Equal.cong(U32, Nat, z => VY.hb(z), VBL.lastb(W1), V, VR.lastWB(d, t, i, m, VR.XN(off, len), pf, hw1, UW.eXNw(off, A.quad(i), len, m, eo, hw32, e1)))
  +B1 = BV.vbits(M, m, h, W1, hh, ew, hl, hlv, eh)
  +eVW = Equal.cong(Nat, +List<U32>, z => VR.WB(t, i, z), U32.to_nat(len), 1n+m, e1)
  Equal.cong(+List<Bool>, S.Value, z => S.BitsValue{z}, BK.btk(U32.to_nat(CHB.NB(t, off, len)), BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), CHB.NB(t, off, len)))))), VBL.bl(VR.WB(t, i, U32.to_nat(len))),
    Equal.trans(+List<Bool>, BK.btk(U32.to_nat(CHB.NB(t, off, len)), BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), CHB.NB(t, off, len)))))), BK.btk(U32.to_nat(CHB.NB(t, off, len)), BK.bitsof(FD.array__slots(U32, M))), VBL.bl(VR.WB(t, i, U32.to_nat(len))), A1,
      FD.logic__subst(Nat, z => {BK.btk(z, BK.bitsof(FD.array__slots(U32, M))) == VBL.bl(VR.WB(t, i, U32.to_nat(len))) : +List<Bool>}, Nat.add(VSP.x8(m), h), U32.to_nat(CHB.NB(t, off, len)), Equal.sym(Nat, U32.to_nat(CHB.NB(t, off, len)), Nat.add(VSP.x8(m), h), eNB),
        FD.logic__subst(+List<U32>, z => {BK.btk(Nat.add(VSP.x8(m), h), BK.bitsof(FD.array__slots(U32, M))) == VBL.bl(z) : +List<Bool>}, W1, VR.WB(t, i, U32.to_nat(len)), Equal.sym(+List<U32>, VR.WB(t, i, U32.to_nat(len)), W1, eVW), B1))))

# the bit list it builds satisfies the encode records' storage premise (e2e_bitv.sdbv, hv included)
def bl_bwa_hv(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHB.CHKw(t, i, off, len) == True{} : Bool})
    -> BTV.sdbv(CHB.OBJw(t, i, off, len)):
  +e1 = CHB.cE(t, i, off, len, hchk)
  +h1 = CHB.c1(t, i, off, len, hchk)
  +nz = CHB.cB(t, off, len, h1)
  +bd = CHB.cC(t, off, len, h1, nz)
  +m = CHB.M1(len)
  +hb = CHB.hB(t, off, len, e1, bd)
  +hL = CHB.hlen(d, i, len, hw, hw32)
  +dz = VLS.DZ(len)
  +M = VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t)
  +pfM = VB.mone_perfect(VC.NW(len), i, 0n, dz, VC.ZT(dz), t, FD.array__trep_perfect(U32, dz, 0))
  +hdz = FD.nat__le_lt_trans(dz, 13n, 32n, CHB.hdzK(d, len, hd, hL, hb), {==})
  +hr0 = CHB.hrgB(len, hb)
  +hy = CHB.hyB(len, hb)
  +V = CHB.V(t, off, len)
  +h = VY.hb(V)
  +hm8 = FD.nat__le_trans(Nat.mul(8n, m), CHB.BD(t, off, len), U32.to_nat(131072), FD.nat__le_add_right(Nat.mul(8n, m), h), bd)
  +emul = VU.mul_le(8, U32.sub(len, 1), 131072, hm8)
  +hadd = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, h), U32.to_nat(131072)) == True{} : Bool}, Nat.mul(8n, m), U32.to_nat(U32.mul(8, U32.sub(len, 1))), Equal.sym(Nat, U32.to_nat(U32.mul(8, U32.sub(len, 1))), Nat.mul(8n, m), emul), bd)
  +eNB = Equal.trans(Nat, U32.to_nat(CHB.NB(t, off, len)), Nat.add(U32.to_nat(U32.mul(8, U32.sub(len, 1))), h), Nat.add(VSP.x8(m), h), A.add_le(U32.mul(8, U32.sub(len, 1)), O.high_bit(V), 131072, hadd),
    Equal.cong(Nat, Nat, z => Nat.add(z, h), U32.to_nat(U32.mul(8, U32.sub(len, 1))), VSP.x8(m), Equal.trans(Nat, U32.to_nat(U32.mul(8, U32.sub(len, 1))), Nat.mul(8n, m), VSP.x8(m), emul, VR.mul8(m))))
  +hNW = VC.eNW(len, 15n, {==}, hy)
  +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(dz)) == True{} : Bool}, Nat.add(VC.NW(len), 0n), C.nwn(U32.to_nat(len)),
    Equal.trans(Nat, Nat.add(VC.NW(len), 0n), VC.NW(len), C.nwn(U32.to_nat(len)), FD.nat__add_zero(VC.NW(len)), hNW), hr0)
  +hn3 = BVW.hn3y(len, 15n, {==}, hy)
  +hh = BV.hb7(V)
  +W1 = VR.WB(t, i, 1n+m)
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hw)
  +ew = BV.winG(d, t, len, i, m, dz, pf, hw, e1, hNW, hr0)
  +hlM = VR.lenS(dz, M, pfM)
  +hq4 = FD.nat__le_trans(1n+m, A.quad(C.nwn(U32.to_nat(len))), A.quad(VB.pw(dz)),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(C.nwn(U32.to_nat(len)))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, C.ng(U32.to_nat(len))), C.q4(C.nwn(U32.to_nat(len)), VB.pw(dz), hN))
  +hl = FD.logic__subst(Nat, z => {Nat.is_lt(m, z) == True{} : Bool}, A.quad(VB.pw(dz)), List.length(&2, U32, F.limbs(FD.array__slots(U32, M))), Equal.sym(Nat, List.length(&2, U32, F.limbs(FD.array__slots(U32, M))), A.quad(VB.pw(dz)), hlM),
    FD.nat__succ_le_lt(m, A.quad(VB.pw(dz)), hq4))
  +hlv = VR.lenWB(d, t, i, 1n+m, pf, hw1)
  +eh = Equal.cong(U32, Nat, z => VY.hb(z), VBL.lastb(W1), V, VR.lastWB(d, t, i, m, VR.XN(off, len), pf, hw1, UW.eXNw(off, A.quad(i), len, m, eo, hw32, e1)))
  +LM = F.limbs(FD.array__slots(U32, M))
  +elast = Equal.trans(U32, VBL.lastb(W1), VBL.lastb(VSP.bt(1n+m, LM)), VBL.nthb(LM, m), Equal.cong(+List<U32>, U32, z => VBL.lastb(z), W1, VSP.bt(1n+m, LM), Equal.sym(+List<U32>, VSP.bt(1n+m, LM), W1, ew)), BV.lbt(m, LM, hl))
  +eh2 = Equal.trans(Nat, VY.hb(VBL.nthb(LM, m)), VY.hb(VBL.lastb(W1)), h, Equal.cong(U32, Nat, z => VY.hb(z), VBL.nthb(LM, m), VBL.lastb(W1), Equal.sym(U32, VBL.lastb(W1), VBL.nthb(LM, m), elast)), eh)
  HV.sdbx(O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), CHB.NB(t, off, len)), CHB.NB(t, off, len), dz, FD.nat__le_lt_trans(dz, 13n, 31n, CHB.hdzK(d, len, hd, hL, hb), {==}),
    HV.hvobj(len, dz, M, CHB.NB(t, off, len), m, h, pfM, hdz, hh, eNB, hN, hn3, e1, eh2))

# The Attestation a word-aligned window reader builds (window at word i, off = 4 i) views as the value the codec reads there.
def att_w(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHA.CHKw(t, i, off, len) == True{} : Bool})
    -> {RT.v_Attestation(CHA.OBJw(t, i, off, len)) == CHA.VALw(t, i, len) : S.Value}:
  +a = U32.is_le(236, len)
  +b = U32.is_eq(CHA.SPOw(t, i), 236)
  +c = CHB.CHKw(t, CHA.JW(i), CHA.OWc(off), CHA.LLw(len))
  +ha = CHA.ch_a(a, b, c, hchk)
  +hc = CHA.ch_c(a, b, c, hchk)
  +e1 = bl_bwa(d, t, CHA.JW(i), CHA.OWc(off), CHA.LLw(len), CHA.eoF(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), hd, CHA.hwc(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), CHA.hwc32(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), pf, hc)
  Equal.trans(S.Value, RT.v_Attestation(CHA.OBJw(t, i, off, len)), S.Sequence{S.Items{CHB.VALw(t, CHA.JW(i), CHA.LLw(len)), S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(1n, i)), VB.slot(t, Nat.add(2n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(3n, i)), VB.slot(t, Nat.add(4n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(5n, i)), VB.slot(t, Nat.add(6n, i)), VB.slot(t, Nat.add(7n, i)), VB.slot(t, Nat.add(8n, i)), VB.slot(t, Nat.add(9n, i)), VB.slot(t, Nat.add(10n, i)), VB.slot(t, Nat.add(11n, i)), VB.slot(t, Nat.add(12n, i))])}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(13n, i)), VB.slot(t, Nat.add(14n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(15n, i)), VB.slot(t, Nat.add(16n, i)), VB.slot(t, Nat.add(17n, i)), VB.slot(t, Nat.add(18n, i)), VB.slot(t, Nat.add(19n, i)), VB.slot(t, Nat.add(20n, i)), VB.slot(t, Nat.add(21n, i)), VB.slot(t, Nat.add(22n, i))])}, S.EmptyItems{}}}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(23n, i)), VB.slot(t, Nat.add(24n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(25n, i)), VB.slot(t, Nat.add(26n, i)), VB.slot(t, Nat.add(27n, i)), VB.slot(t, Nat.add(28n, i)), VB.slot(t, Nat.add(29n, i)), VB.slot(t, Nat.add(30n, i)), VB.slot(t, Nat.add(31n, i)), VB.slot(t, Nat.add(32n, i))])}, S.EmptyItems{}}}}, S.EmptyItems{}}}}}}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(33n, i)), VB.slot(t, Nat.add(34n, i)), VB.slot(t, Nat.add(35n, i)), VB.slot(t, Nat.add(36n, i)), VB.slot(t, Nat.add(37n, i)), VB.slot(t, Nat.add(38n, i)), VB.slot(t, Nat.add(39n, i)), VB.slot(t, Nat.add(40n, i)), VB.slot(t, Nat.add(41n, i)), VB.slot(t, Nat.add(42n, i)), VB.slot(t, Nat.add(43n, i)), VB.slot(t, Nat.add(44n, i)), VB.slot(t, Nat.add(45n, i)), VB.slot(t, Nat.add(46n, i)), VB.slot(t, Nat.add(47n, i)), VB.slot(t, Nat.add(48n, i)), VB.slot(t, Nat.add(49n, i)), VB.slot(t, Nat.add(50n, i)), VB.slot(t, Nat.add(51n, i)), VB.slot(t, Nat.add(52n, i)), VB.slot(t, Nat.add(53n, i)), VB.slot(t, Nat.add(54n, i)), VB.slot(t, Nat.add(55n, i)), VB.slot(t, Nat.add(56n, i))])}, S.Items{S.BitsValue{E2B.wcat([VB.slot(t, Nat.add(57n, i)), VB.slot(t, Nat.add(58n, i))])}, S.EmptyItems{}}}}}}, S.Sequence{S.Items{CHB.VALw(t, CHA.JW(i), CHA.LLw(len)), S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(1n, i)), VB.slot(t, Nat.add(2n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(3n, i)), VB.slot(t, Nat.add(4n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(5n, i)), VB.slot(t, Nat.add(6n, i)), VB.slot(t, Nat.add(7n, i)), VB.slot(t, Nat.add(8n, i)), VB.slot(t, Nat.add(9n, i)), VB.slot(t, Nat.add(10n, i)), VB.slot(t, Nat.add(11n, i)), VB.slot(t, Nat.add(12n, i))])}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(13n, i)), VB.slot(t, Nat.add(14n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(15n, i)), VB.slot(t, Nat.add(16n, i)), VB.slot(t, Nat.add(17n, i)), VB.slot(t, Nat.add(18n, i)), VB.slot(t, Nat.add(19n, i)), VB.slot(t, Nat.add(20n, i)), VB.slot(t, Nat.add(21n, i)), VB.slot(t, Nat.add(22n, i))])}, S.EmptyItems{}}}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(23n, i)), VB.slot(t, Nat.add(24n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(25n, i)), VB.slot(t, Nat.add(26n, i)), VB.slot(t, Nat.add(27n, i)), VB.slot(t, Nat.add(28n, i)), VB.slot(t, Nat.add(29n, i)), VB.slot(t, Nat.add(30n, i)), VB.slot(t, Nat.add(31n, i)), VB.slot(t, Nat.add(32n, i))])}, S.EmptyItems{}}}}, S.EmptyItems{}}}}}}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(33n, i)), VB.slot(t, Nat.add(34n, i)), VB.slot(t, Nat.add(35n, i)), VB.slot(t, Nat.add(36n, i)), VB.slot(t, Nat.add(37n, i)), VB.slot(t, Nat.add(38n, i)), VB.slot(t, Nat.add(39n, i)), VB.slot(t, Nat.add(40n, i)), VB.slot(t, Nat.add(41n, i)), VB.slot(t, Nat.add(42n, i)), VB.slot(t, Nat.add(43n, i)), VB.slot(t, Nat.add(44n, i)), VB.slot(t, Nat.add(45n, i)), VB.slot(t, Nat.add(46n, i)), VB.slot(t, Nat.add(47n, i)), VB.slot(t, Nat.add(48n, i)), VB.slot(t, Nat.add(49n, i)), VB.slot(t, Nat.add(50n, i)), VB.slot(t, Nat.add(51n, i)), VB.slot(t, Nat.add(52n, i)), VB.slot(t, Nat.add(53n, i)), VB.slot(t, Nat.add(54n, i)), VB.slot(t, Nat.add(55n, i)), VB.slot(t, Nat.add(56n, i))])}, S.Items{S.BitsValue{FB.bitsof([VB.slot(t, Nat.add(57n, i)), VB.slot(t, Nat.add(58n, i))])}, S.EmptyItems{}}}}}},
    Equal.cong(S.Value, S.Value, z => S.Sequence{S.Items{z, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(1n, i)), VB.slot(t, Nat.add(2n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(3n, i)), VB.slot(t, Nat.add(4n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(5n, i)), VB.slot(t, Nat.add(6n, i)), VB.slot(t, Nat.add(7n, i)), VB.slot(t, Nat.add(8n, i)), VB.slot(t, Nat.add(9n, i)), VB.slot(t, Nat.add(10n, i)), VB.slot(t, Nat.add(11n, i)), VB.slot(t, Nat.add(12n, i))])}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(13n, i)), VB.slot(t, Nat.add(14n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(15n, i)), VB.slot(t, Nat.add(16n, i)), VB.slot(t, Nat.add(17n, i)), VB.slot(t, Nat.add(18n, i)), VB.slot(t, Nat.add(19n, i)), VB.slot(t, Nat.add(20n, i)), VB.slot(t, Nat.add(21n, i)), VB.slot(t, Nat.add(22n, i))])}, S.EmptyItems{}}}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(23n, i)), VB.slot(t, Nat.add(24n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(25n, i)), VB.slot(t, Nat.add(26n, i)), VB.slot(t, Nat.add(27n, i)), VB.slot(t, Nat.add(28n, i)), VB.slot(t, Nat.add(29n, i)), VB.slot(t, Nat.add(30n, i)), VB.slot(t, Nat.add(31n, i)), VB.slot(t, Nat.add(32n, i))])}, S.EmptyItems{}}}}, S.EmptyItems{}}}}}}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(33n, i)), VB.slot(t, Nat.add(34n, i)), VB.slot(t, Nat.add(35n, i)), VB.slot(t, Nat.add(36n, i)), VB.slot(t, Nat.add(37n, i)), VB.slot(t, Nat.add(38n, i)), VB.slot(t, Nat.add(39n, i)), VB.slot(t, Nat.add(40n, i)), VB.slot(t, Nat.add(41n, i)), VB.slot(t, Nat.add(42n, i)), VB.slot(t, Nat.add(43n, i)), VB.slot(t, Nat.add(44n, i)), VB.slot(t, Nat.add(45n, i)), VB.slot(t, Nat.add(46n, i)), VB.slot(t, Nat.add(47n, i)), VB.slot(t, Nat.add(48n, i)), VB.slot(t, Nat.add(49n, i)), VB.slot(t, Nat.add(50n, i)), VB.slot(t, Nat.add(51n, i)), VB.slot(t, Nat.add(52n, i)), VB.slot(t, Nat.add(53n, i)), VB.slot(t, Nat.add(54n, i)), VB.slot(t, Nat.add(55n, i)), VB.slot(t, Nat.add(56n, i))])}, S.Items{S.BitsValue{E2B.wcat([VB.slot(t, Nat.add(57n, i)), VB.slot(t, Nat.add(58n, i))])}, S.EmptyItems{}}}}}}, S.BitsValue{BR.bview(CHB.OBJw(t, CHA.JW(i), CHA.OWc(off), CHA.LLw(len)))}, CHB.VALw(t, CHA.JW(i), CHA.LLw(len)), e1),
    Equal.cong(+List<Bool>, S.Value, z => S.Sequence{S.Items{CHB.VALw(t, CHA.JW(i), CHA.LLw(len)), S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(1n, i)), VB.slot(t, Nat.add(2n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(3n, i)), VB.slot(t, Nat.add(4n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(5n, i)), VB.slot(t, Nat.add(6n, i)), VB.slot(t, Nat.add(7n, i)), VB.slot(t, Nat.add(8n, i)), VB.slot(t, Nat.add(9n, i)), VB.slot(t, Nat.add(10n, i)), VB.slot(t, Nat.add(11n, i)), VB.slot(t, Nat.add(12n, i))])}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(13n, i)), VB.slot(t, Nat.add(14n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(15n, i)), VB.slot(t, Nat.add(16n, i)), VB.slot(t, Nat.add(17n, i)), VB.slot(t, Nat.add(18n, i)), VB.slot(t, Nat.add(19n, i)), VB.slot(t, Nat.add(20n, i)), VB.slot(t, Nat.add(21n, i)), VB.slot(t, Nat.add(22n, i))])}, S.EmptyItems{}}}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(23n, i)), VB.slot(t, Nat.add(24n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(25n, i)), VB.slot(t, Nat.add(26n, i)), VB.slot(t, Nat.add(27n, i)), VB.slot(t, Nat.add(28n, i)), VB.slot(t, Nat.add(29n, i)), VB.slot(t, Nat.add(30n, i)), VB.slot(t, Nat.add(31n, i)), VB.slot(t, Nat.add(32n, i))])}, S.EmptyItems{}}}}, S.EmptyItems{}}}}}}}, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(33n, i)), VB.slot(t, Nat.add(34n, i)), VB.slot(t, Nat.add(35n, i)), VB.slot(t, Nat.add(36n, i)), VB.slot(t, Nat.add(37n, i)), VB.slot(t, Nat.add(38n, i)), VB.slot(t, Nat.add(39n, i)), VB.slot(t, Nat.add(40n, i)), VB.slot(t, Nat.add(41n, i)), VB.slot(t, Nat.add(42n, i)), VB.slot(t, Nat.add(43n, i)), VB.slot(t, Nat.add(44n, i)), VB.slot(t, Nat.add(45n, i)), VB.slot(t, Nat.add(46n, i)), VB.slot(t, Nat.add(47n, i)), VB.slot(t, Nat.add(48n, i)), VB.slot(t, Nat.add(49n, i)), VB.slot(t, Nat.add(50n, i)), VB.slot(t, Nat.add(51n, i)), VB.slot(t, Nat.add(52n, i)), VB.slot(t, Nat.add(53n, i)), VB.slot(t, Nat.add(54n, i)), VB.slot(t, Nat.add(55n, i)), VB.slot(t, Nat.add(56n, i))])}, S.Items{S.BitsValue{z}, S.EmptyItems{}}}}}}, E2B.wcat([VB.slot(t, Nat.add(57n, i)), VB.slot(t, Nat.add(58n, i))]), FB.bitsof([VB.slot(t, Nat.add(57n, i)), VB.slot(t, Nat.add(58n, i))]),
      Equal.sym(+List<Bool>, FB.bitsof([VB.slot(t, Nat.add(57n, i)), VB.slot(t, Nat.add(58n, i))]), E2B.wcat([VB.slot(t, Nat.add(57n, i)), VB.slot(t, Nat.add(58n, i))]), E2B.bw([VB.slot(t, Nat.add(57n, i)), VB.slot(t, Nat.add(58n, i))]))))

# ... and its bit list satisfies the encode records' storage premise (e2e_bitv.sdbv, hv included)
def att_w_hv(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHA.CHKw(t, i, off, len) == True{} : Bool})
    -> BTV.sdbv(RT.pj_Attestation_0(CHA.OBJw(t, i, off, len))):
  +a = U32.is_le(236, len)
  +b = U32.is_eq(CHA.SPOw(t, i), 236)
  +c = CHB.CHKw(t, CHA.JW(i), CHA.OWc(off), CHA.LLw(len))
  +ha = CHA.ch_a(a, b, c, hchk)
  +hc = CHA.ch_c(a, b, c, hchk)
  bl_bwa_hv(d, t, CHA.JW(i), CHA.OWc(off), CHA.LLw(len), CHA.eoF(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), hd, CHA.hwc(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), CHA.hwc32(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), pf, hc)
