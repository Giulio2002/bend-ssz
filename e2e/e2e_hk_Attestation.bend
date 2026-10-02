import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../spec/fulu_schemas.bend as Spec
import ../proofs/compact/found_generated.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/spec_fixed.bend as SF
import ../proofs/obj/vspec.bend as VSP
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vbyte_generated.bend as VY
import ../proofs/obj/vbrt.bend as VR
import ../proofs/obj/vu32.bend as VU
import ../proofs/obj/vbitcore.bend as CO
import ../proofs/obj/vua_ct.bend as UCT
import ../proofs/obj/vlist.bend as VLS
import ../proofs/obj/root_types_light_generated.bend as RT
import ../proofs/obj/var_winx_Attestation_generated.bend as YW
import ../proofs/obj/var_winx_bits131072_generated.bend as W131
import ../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ./e2e_bview_generated.bend as BV
import ./e2e_bvw_generated.bend as BVW
import ./e2e_wxa_generated.bend as WXA
import ./e2e_wxah_generated.bend as WXH
import ./e2e_wxar_generated.bend as WXR
import ./e2e_bbatt_generated.bend as BBA
import ../proofs/obj/encx_bits131072_generated.bend as EXb
import ../proofs/obj/encx_Attestation_iface_generated.bend as EM
import ../proofs/obj/encx_l8_Attestation_generated.bend as W8
import ../proofs/obj/vua_lay.bend as LY
import ./e2e_u64l_generated.bend as ER
import ../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../types/Fulu_bitvector_64_def_generated.bend as Fulu_bitvector_64_d

# Element hooks for the attestation lists (e2e_dvl_l8_Attestation): the Attestation a byte-window reader builds (var_winx_Attestation) at the window
# (x, off, len), with the window facts eo, hd, hw, hw32, pf after hchk.

def rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YW.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +s: S.Schema, +ee: {s == Spec.Attestation() : S.Schema})
    -> RT.rep_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)), s):
  +a = U32.is_le(236, len)
  +b = U32.is_eq(YW.SPOw(t, x), 236)
  +c = W131.CHKw(t, YW.JW(x), YW.OWc(off), YW.LLw(len))
  +ha = YW.ch_a(a, b, c, hchk)
  FD.logic__subst(S.Schema, z => RT.rep_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)), z), Spec.Attestation(), s, Equal.sym(S.Schema, s, Spec.Attestation(), ee),
    ({==}, (WXA.adA(YW.OBJw(d, t, x, off, len)), (WXA.sgA(YW.OBJw(d, t, x, off, len)), (WXA.bvA(YW.OBJw(d, t, x, off, len)), ({==},
      WXR.bx_bw_rep(d, t, YW.JW(x), YW.OWc(off), YW.LLw(len), YW.eoF(d, t, 0, x, off, len, eo, hd, hw, hw32, pf, ha), hd,
        YW.hwc(d, t, 0, x, off, len, eo, hd, hw, hw32, pf, ha), YW.hwc32(d, t, 0, x, off, len, eo, hd, hw, hw32, pf, ha), pf, YW.ch_c(a, b, c, hchk))))))))

# the element's storage premise (the bit list's SDB, hv included) as BBA.SDKS holds it of the list's element
def sde(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YW.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> BBA.SDE(RT.fz_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)))):
  +x0 = WXH.hv_Attestation(d, t, x, off, len, eo, hd, hw, hw32, pf, hchk)
  FD.logic__subst(O.Bits, z => BBA.SDB(z, 31n), RT.pj_Attestation_0(YW.OBJw(d, t, x, off, len)), RT.th_b(RT.fz_b(RT.pj_Attestation_0(YW.OBJw(d, t, x, off, len)))),
    Equal.sym(O.Bits, RT.th_b(RT.fz_b(RT.pj_Attestation_0(YW.OBJw(d, t, x, off, len)))), RT.pj_Attestation_0(YW.OBJw(d, t, x, off, len)),
      WXH.thbits(UCT.CT(d, t, YW.OWc(off), YW.LLw(len), VLS.DZ(YW.LLw(len))), W131.NB(t, YW.OWc(off), YW.LLw(len)))), x0)

# the rep of the box the list library builds (freeze then thaw of the element)
def repT(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YW.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +s: S.Schema, +ee: {s == Spec.Attestation() : S.Schema})
    -> RT.rep_Attestation_bx(RT.th_Attestation_bx(RT.fz_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)))), s):
  FD.logic__subst(O.Boxed<FuluAttestation_d.Attestation>, z => RT.rep_Attestation_bx(z, s), FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)),
    RT.th_Attestation_bx(RT.fz_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)))),
    Equal.cong(FuluAttestation_d.Attestation, O.Boxed<FuluAttestation_d.Attestation>, z => O.BSome{z, O.BNone{}}, YW.OBJw(d, t, x, off, len), RT.th_Attestation(RT.fz_Attestation(YW.OBJw(d, t, x, off, len))),
      Equal.sym(FuluAttestation_d.Attestation, RT.th_Attestation(RT.fz_Attestation(YW.OBJw(d, t, x, off, len))), YW.OBJw(d, t, x, off, len), WXA.tf_Attestation(d, t, x, off, len, eo, hd, hw, hw32, pf, hchk))),
    rep(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf, s, ee))

# ---- the element's encoded size ----
def t1(+mb: EXb.MB, +a1: FuluAttestationData_d.AttestationData, +a2: FuluBytes96_d.Bytes96, +a3: Fulu_bitvector_64_d.Bitvector64, +eok: {EM.OKT(mb, a1, a2, a3) == True{} : Bool})
    -> {List.length(&2, U32, EM.ENC(EM.MW{mb, a1, a2, a3})) == Nat.add(236n, LY.LN(EXb.ENC(mb))) : Nat}:
  EM.lenE(mb, a1, a2, a3, eok)

def szq0(+tb: FD.array__Tree<U32>, +k: U32, +a1: FuluAttestationData_d.AttestationData, +a2: FuluBytes96_d.Bytes96, +a3: Fulu_bitvector_64_d.Bitvector64,
    +eok: {EM.OKT(EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n}, a1, a2, a3) == True{} : Bool})
    -> {LY.LN(EXb.ENC(EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n})) == U32.to_nat(CO.NK(k)) : Nat}:
  EXb.eL(ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n, EM.ok_hok_aggregation_bits(EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n}, a1, a2, a3, eok))

def szq(+tb: FD.array__Tree<U32>, +k: U32, +a1: FuluAttestationData_d.AttestationData, +a2: FuluBytes96_d.Bytes96, +a3: Fulu_bitvector_64_d.Bitvector64,
    +eok: {EM.OKT(EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n}, a1, a2, a3) == True{} : Bool})
    -> {List.length(&2, U32, EM.ENC(EM.MW{EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n}, a1, a2, a3})) == Nat.add(236n, U32.to_nat(CO.NK(k))) : Nat}:
  Equal.trans(Nat, List.length(&2, U32, EM.ENC(EM.MW{EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n}, a1, a2, a3})), Nat.add(236n, LY.LN(EXb.ENC(EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n}))), Nat.add(236n, U32.to_nat(CO.NK(k))),
    t1(EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n}, a1, a2, a3, eok),
    Equal.cong(Nat, Nat, z => Nat.add(236n, z), LY.LN(EXb.ENC(EXb.MB{ER.LDEP(U32, tb), tb, k, U32.to_nat(131072), 18n, 18n})), U32.to_nat(CO.NK(k)), szq0(tb, k, a1, a2, a3, eok)))

# the bit list of K = 8 m + h bits (the window of 1 + m bytes) has K / 8 + 1 = len bytes
def nkq(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {W131.CHKw(t, x, off, len) == True{} : Bool})
    -> {U32.to_nat(CO.NK(W131.NB(t, off, len))) == U32.to_nat(len) : Nat}:
  +e1 = W131.cE(t, x, off, len, hchk)
  +h1 = W131.c1(t, x, off, len, hchk)
  +nz = W131.cB(t, off, len, h1)
  +bd = W131.cC(t, off, len, h1, nz)
  +m = W131.M1(len)
  +hb = W131.hB(t, off, len, e1, bd)
  +V = W131.V(t, off, len)
  +h = VY.hb(V)
  +hm8 = FD.nat__le_trans(Nat.mul(8n, m), W131.BD(t, off, len), U32.to_nat(131072), FD.nat__le_add_right(Nat.mul(8n, m), h), bd)
  +emul = VU.mul_le(8, U32.sub(len, 1), 131072, hm8)
  +hadd = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, h), U32.to_nat(131072)) == True{} : Bool}, Nat.mul(8n, m), U32.to_nat(U32.mul(8, U32.sub(len, 1))), Equal.sym(Nat, U32.to_nat(U32.mul(8, U32.sub(len, 1))), Nat.mul(8n, m), emul), bd)
  +eNB = Equal.trans(Nat, U32.to_nat(W131.NB(t, off, len)), Nat.add(U32.to_nat(U32.mul(8, U32.sub(len, 1))), h), Nat.add(VSP.x8(m), h), A.add_le(U32.mul(8, U32.sub(len, 1)), O.high_bit(V), 131072, hadd),
    Equal.cong(Nat, Nat, z => Nat.add(z, h), U32.to_nat(U32.mul(8, U32.sub(len, 1))), VSP.x8(m), Equal.trans(Nat, U32.to_nat(U32.mul(8, U32.sub(len, 1))), Nat.mul(8n, m), VSP.x8(m), emul, VR.mul8(m))))
  +hh = BV.hb7(V)
  +e3 = Equal.trans(Nat, U32.to_nat(U32.shrn(W131.NB(t, off, len), 3n)), VD.s_rng(3n, U32.to_nat(W131.NB(t, off, len))), m, VD.shrk(3n, W131.NB(t, off, len)),
    Equal.trans(Nat, VD.s_rng(3n, U32.to_nat(W131.NB(t, off, len))), VD.s_rng(3n, Nat.add(VSP.x8(m), h)), m, Equal.cong(Nat, Nat, z => VD.s_rng(3n, z), U32.to_nat(W131.NB(t, off, len)), Nat.add(VSP.x8(m), h), eNB), BVW.s3h(m, h, hh)))
  +hm1 = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(131072)) == True{} : Bool}, 1n+m, Nat.add(m, 1n), Equal.sym(Nat, Nat.add(m, 1n), 1n+m, FD.nat__add_comm(m, 1n)),
    FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(131072)) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, FD.nat__le_trans(U32.to_nat(len), 16385n, U32.to_nat(131072), hb, {==})))
  +hm2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(1)), U32.to_nat(131072)) == True{} : Bool}, m, U32.to_nat(U32.shrn(W131.NB(t, off, len), 3n)), Equal.sym(Nat, U32.to_nat(U32.shrn(W131.NB(t, off, len), 3n)), m, e3), hm1)
  Equal.trans(Nat, U32.to_nat(CO.NK(W131.NB(t, off, len))), Nat.add(U32.to_nat(U32.shrn(W131.NB(t, off, len), 3n)), U32.to_nat(1)), U32.to_nat(len), A.add_le(U32.shrn(W131.NB(t, off, len), 3n), 1, 131072, hm2),
    Equal.trans(Nat, Nat.add(U32.to_nat(U32.shrn(W131.NB(t, off, len), 3n)), U32.to_nat(1)), Nat.add(m, 1n), U32.to_nat(len), Equal.cong(Nat, Nat, z => Nat.add(z, 1n), U32.to_nat(U32.shrn(W131.NB(t, off, len), 3n)), m, e3),
      Equal.trans(Nat, Nat.add(m, 1n), 1n+m, U32.to_nat(len), FD.nat__add_comm(m, 1n), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1))))

def sz1(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YW.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {W8.EOK(BBA.cvE(RT.fz_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len))))) == True{} : Bool}:
  +m0 = RT.fz_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)))
  BBA.PA({W8.EOK(BBA.cvE(m0)) == True{} : Bool}, {RT.v_Attestation_bx(RT.th_Attestation_bx(m0)) == W8.EV(BBA.cvE(m0)) : S.Value},
    BBA.elx(m0, Spec.Attestation(), {==}, repT(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf, Spec.Attestation(), {==}), sde(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf)))

def sz2(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YW.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {List.length(&2, U32, W8.YE(BBA.cvE(RT.fz_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)))))) == Nat.add(236n, U32.to_nat(CO.NK(W131.NB(t, YW.OWc(off), YW.LLw(len))))) : Nat}:
  szq(FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, UCT.CT(d, t, YW.OWc(off), YW.LLw(len), VLS.DZ(YW.LLw(len)))), W131.NB(t, YW.OWc(off), YW.LLw(len)))), W131.NB(t, YW.OWc(off), YW.LLw(len)),
      WXA.adA(YW.OBJw(d, t, x, off, len)), WXA.sgA(YW.OBJw(d, t, x, off, len)), WXA.bvA(YW.OBJw(d, t, x, off, len)), sz1(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf))

def sz3(+len: U32, +k: Nat, +ek: {k == U32.to_nat(YW.LLw(len)) : Nat}, +h236: {Nat.is_le(U32.to_nat(236), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.add(236n, k) == U32.to_nat(len) : Nat}:
  +esub = FD.u32__sub_nat(len, 236, h236)
  Equal.trans(Nat, Nat.add(236n, k), Nat.add(U32.to_nat(236), Nat.sub(U32.to_nat(len), U32.to_nat(236))), U32.to_nat(len),
    Equal.cong(Nat, Nat, z => Nat.add(236n, z), k, Nat.sub(U32.to_nat(len), U32.to_nat(236)), Equal.trans(Nat, k, U32.to_nat(YW.LLw(len)), Nat.sub(U32.to_nat(len), U32.to_nat(236)), ek, esub)),
    FD.nat__sub_add(U32.to_nat(len), U32.to_nat(236), h236))

# the element's encoded byte count (as the list's encoder sums it) is the window's length
def sz(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YW.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {List.length(&2, U32, W8.YE(BBA.cvE(RT.fz_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)))))) == U32.to_nat(len) : Nat}:
  +a = U32.is_le(236, len)
  +b = U32.is_eq(YW.SPOw(t, x), 236)
  +c = W131.CHKw(t, YW.JW(x), YW.OWc(off), YW.LLw(len))
  +ha = YW.ch_a(a, b, c, hchk)
  +h236 = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(236, len), Nat.is_le(U32.to_nat(236), U32.to_nat(len)), VU.le_u32(236, len), ha)
  Equal.trans(Nat, List.length(&2, U32, W8.YE(BBA.cvE(RT.fz_Attestation_bx(FuluAttestation_d.Attestation_bx_wrap(YW.OBJw(d, t, x, off, len)))))),
    Nat.add(236n, U32.to_nat(CO.NK(W131.NB(t, YW.OWc(off), YW.LLw(len))))), U32.to_nat(len),
    sz2(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf),
    sz3(len, U32.to_nat(CO.NK(W131.NB(t, YW.OWc(off), YW.LLw(len)))),
      Equal.trans(Nat, U32.to_nat(CO.NK(W131.NB(t, YW.OWc(off), YW.LLw(len)))), U32.to_nat(YW.LLw(len)), U32.to_nat(YW.LLw(len)), nkq(t, YW.JW(x), YW.OWc(off), YW.LLw(len), YW.ch_c(a, b, c, hchk)), {==}), h236))
