import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../spec/fulu_schemas.bend as Spec
import ../proofs/compact/found_generated.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/schema_shapes_generated.bend as SH
import ../proofs/obj/spec_fixed.bend as SF
import ../proofs/obj/vspec.bend as VSP
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vlist.bend as VLS
import ../proofs/obj/vua_ct.bend as UCT
import ../proofs/obj/root_types_light_generated.bend as RT
import ../proofs/obj/ulist_obj_light.bend as UL
import ../proofs/obj/var_winx_l131072_u64_generated.bend as WU
import ../proofs/obj/var_winx_IndexedAttestation_generated.bend as YI
import ../proofs/obj/var_winx_AttesterSlashing_generated.bend as YS
import ../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
import ../types/FuluAttesterSlashing_def_generated.bend as FuluAttesterSlashing_d
import ./e2e_dz_generated.bend as DZ
import ./e2e_ulist_generated.bend as UW
import ./e2e_wxa_generated.bend as WXA
import ./e2e_bbsl_generated.bend as BBS
import ./e2e_u64l_generated.bend as U
import ../proofs/obj/encx_l131072_u64_generated.bend as EXu
import ../proofs/obj/encx_IndexedAttestation_iface_generated.bend as EI
import ../proofs/obj/encx_AttesterSlashing_iface_generated.bend as ES
import ../proofs/obj/encx_l1_AttesterSlashing_generated.bend as W1
import ../proofs/obj/vua_lay.bend as LY
import ../proofs/nat_order.bend as Order
import ../proofs/obj/vu32.bend as VU
import ../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../types/FuluBytes96_def_generated.bend as FuluBytes96_d

# Element hooks for the attester slashing list (e2e_dvl_l1_AttesterSlashing): the AttesterSlashing a byte-window reader builds
# (var_winx_AttesterSlashing) at the window (x, off, len): two IndexedAttestation windows, each with a uint64 list window.

# ---- a uint64 list window (var_winx_l131072_u64) ----
def hyU(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {WU.CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(VC.YL(len), U32.to_nat(VB.UMAX())) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(len), VB.pw(21n), U32.to_nat(VB.UMAX()), WU.hyL(t, x, off, len, hc), VC.pw_umax(21n, {==}))

def dz20(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {WU.CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(VLS.DZ(len), 20n) == True{} : Bool}:
  VD.wd_min(VC.WZ(len), 20n, WU.hWZ(t, x, off, len, hc))

# the copy's storage at any depth bound k >= 28
def ul_any(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {WU.CHKw(t, x, off, len) == True{} : Bool}, +k: Nat, +hk: {Nat.is_le(28n, k) == True{} : Bool})
    -> U.sdk(O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}, k):
  DZ.ct_any(d, t, off, len, VLS.DZ(len), k, FD.nat__lt_le_trans(VLS.DZ(len), 28n, k, FD.nat__le_lt_trans(VLS.DZ(len), 20n, 28n, dz20(t, x, off, len, hc), {==}), hk),
    hyU(t, x, off, len, hc), VD.wd_cover(VC.WZ(len), 30n, {==}, VC.wz30(len, hyU(t, x, off, len, hc))))

def ul_rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {WU.CHKw(t, x, off, len) == True{} : Bool}, +s: S.Schema, +es: {SH.ListOf_limit(s) == U32.to_nat(131072) : Nat})
    -> UL.rep_ul(WU.OBJw(d, t, x, off, len), s):
  +CQ = WU.CQ(len)
  +eL = WU.eLc(t, x, off, len, hc)
  +ecq = Equal.trans(Nat, U32.to_nat(U32.shrn(len, 3n)), VD.s_rng(3n, U32.to_nat(len)), CQ, VD.shrk(3n, len),
    Equal.trans(Nat, VD.s_rng(3n, U32.to_nat(len)), VD.s_rng(3n, VSP.x8(CQ)), CQ, Equal.cong(Nat, Nat, z => VD.s_rng(3n, z), U32.to_nat(len), VSP.x8(CQ), eL), UW.r8(CQ)))
  (ul_any(d, t, x, off, len, hc, 32n, {==}),
   (Equal.trans(Nat, U32.to_nat(len), VSP.x8(CQ), O.e8(U32.to_nat(U32.shrn(len, 3n))), eL, Equal.trans(Nat, VSP.x8(CQ), O.e8(CQ), O.e8(U32.to_nat(U32.shrn(len, 3n))), UW.x8e(CQ),
      Equal.cong(Nat, Nat, z => O.e8(z), CQ, U32.to_nat(U32.shrn(len, 3n)), Equal.sym(Nat, U32.to_nat(U32.shrn(len, 3n)), CQ, ecq)))),
    FD.logic__subst(Nat, z => {Nat.is_le(z, SH.ListOf_limit(s)) == True{} : Bool}, CQ, U32.to_nat(U32.shrn(len, 3n)), Equal.sym(Nat, U32.to_nat(U32.shrn(len, 3n)), CQ, ecq),
      FD.logic__subst(Nat, z => {Nat.is_le(CQ, z) == True{} : Bool}, U32.to_nat(131072), SH.ListOf_limit(s), Equal.sym(Nat, SH.ListOf_limit(s), U32.to_nat(131072), es), WU.hcL(t, x, off, len, hc)))))

# ---- an IndexedAttestation window (var_winx_IndexedAttestation) ----
def ia_ch(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {YI.CHKw(t, x, off, len) == True{} : Bool}) -> {WU.CHKw(t, YI.JW(x), YI.OWc(off), YI.LLw(len)) == True{} : Bool}:
  YI.ch_c(U32.is_le(228, len), U32.is_eq(YI.SPOw(t, x), 228), WU.CHKw(t, YI.JW(x), YI.OWc(off), YI.LLw(len)), hc)

def ia_rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {YI.CHKw(t, x, off, len) == True{} : Bool}, +s: S.Schema, +ee: {s == Spec.IndexedAttestation() : S.Schema})
    -> RT.rep_IndexedAttestation(YI.OBJw(d, t, x, off, len), s):
  FD.logic__subst(S.Schema, z => RT.rep_IndexedAttestation(YI.OBJw(d, t, x, off, len), z), Spec.IndexedAttestation(), s, Equal.sym(S.Schema, s, Spec.IndexedAttestation(), ee),
    (WXA.adI(YI.OBJw(d, t, x, off, len)), (WXA.sgI(YI.OBJw(d, t, x, off, len)), ({==},
      ul_rep(d, t, YI.JW(x), YI.OWc(off), YI.LLw(len), ia_ch(t, x, off, len, hc), SH.Chain_head(SH.Container_fields(Spec.IndexedAttestation())), {==})))))

def ia_sd(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {YI.CHKw(t, x, off, len) == True{} : Bool})
    -> BBS.sdI(RT.fz_IndexedAttestation(YI.OBJw(d, t, x, off, len))):
  FD.logic__subst(FD.array__Tree<U32>, z => U.sdk(O.Words{FD.array__thaw(U32, z), YI.LLw(len)}, 28n),
    UCT.CT(d, t, YI.OWc(off), YI.LLw(len), VLS.DZ(YI.LLw(len))), FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YI.OWc(off), YI.LLw(len), VLS.DZ(YI.LLw(len))))),
    Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YI.OWc(off), YI.LLw(len), VLS.DZ(YI.LLw(len))))), UCT.CT(d, t, YI.OWc(off), YI.LLw(len), VLS.DZ(YI.LLw(len))),
      FD.array__freeze_thaw(U32, UCT.CT(d, t, YI.OWc(off), YI.LLw(len), VLS.DZ(YI.LLw(len))))),
    ul_any(d, t, YI.JW(x), YI.OWc(off), YI.LLw(len), ia_ch(t, x, off, len, hc), 28n, {==}))

# ---- an AttesterSlashing window (var_winx_AttesterSlashing) ----
def as_d0(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {YS.CHKw(t, x, off, len) == True{} : Bool}) -> {YI.CHKw(t, YS.J0(t, x), YS.W0(t, x, off), YS.L0(t, x)) == True{} : Bool}:
  +r1 = YS.ck(U32.is_eq(YS.O0(t, x), 8), YS.ck(YS.RR(t, x, len), YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len))))
  +r2 = YS.ck(YS.RR(t, x, len), YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len)))
  +r3 = YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len))
  YS.ck_a(YS.D0(t, x, off), YS.D1(t, x, off, len), YS.ck_b(YS.RR(t, x, len), r3, YS.ck_b(U32.is_eq(YS.O0(t, x), 8), r2, YS.ck_b(U32.is_le(8, len), r1, hc))))

def as_d1(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {YS.CHKw(t, x, off, len) == True{} : Bool}) -> {YI.CHKw(t, YS.J1(t, x), YS.W1(t, x, off), YS.L1(t, x, len)) == True{} : Bool}:
  +r1 = YS.ck(U32.is_eq(YS.O0(t, x), 8), YS.ck(YS.RR(t, x, len), YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len))))
  +r2 = YS.ck(YS.RR(t, x, len), YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len)))
  +r3 = YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len))
  YS.ck_b(YS.D0(t, x, off), YS.D1(t, x, off, len), YS.ck_b(YS.RR(t, x, len), r3, YS.ck_b(U32.is_eq(YS.O0(t, x), 8), r2, YS.ck_b(U32.is_le(8, len), r1, hc))))

def rep(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YS.CHKw(t, x, off, len) == True{} : Bool}, +s: S.Schema, +ee: {s == Spec.AttesterSlashing() : S.Schema})
    -> RT.rep_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len)), s):
  FD.logic__subst(S.Schema, z => RT.rep_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len)), z), Spec.AttesterSlashing(), s, Equal.sym(S.Schema, s, Spec.AttesterSlashing(), ee),
    ({==}, ({==}, (({==}, ia_rep(d, t, YS.J0(t, x), YS.W0(t, x, off), YS.L0(t, x), as_d0(t, x, off, len, hchk), SH.Chain_head(SH.Container_fields(Spec.AttesterSlashing())), {==})),
                   ({==}, ia_rep(d, t, YS.J1(t, x), YS.W1(t, x, off), YS.L1(t, x, len), as_d1(t, x, off, len, hchk), SH.Chain_head(SH.Chain_tail(SH.Container_fields(Spec.AttesterSlashing()))), {==}))))))

def sde(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YS.CHKw(t, x, off, len) == True{} : Bool})
    -> BBS.SDE(RT.fz_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len)))):
  (ia_sd(d, t, YS.J0(t, x), YS.W0(t, x, off), YS.L0(t, x), as_d0(t, x, off, len, hchk)), ia_sd(d, t, YS.J1(t, x), YS.W1(t, x, off), YS.L1(t, x, len), as_d1(t, x, off, len, hchk)))

# the rep of the box the list library builds (freeze then thaw of the element)
def repT(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YS.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +s: S.Schema, +ee: {s == Spec.AttesterSlashing() : S.Schema})
    -> RT.rep_AttesterSlashing_bx(RT.th_AttesterSlashing_bx(RT.fz_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len)))), s):
  FD.logic__subst(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, z => RT.rep_AttesterSlashing_bx(z, s), FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len)),
    RT.th_AttesterSlashing_bx(RT.fz_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len)))),
    Equal.cong(FuluAttesterSlashing_d.AttesterSlashing, O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, z => O.BSome{z, O.BNone{}}, YS.OBJw(d, t, x, off, len), RT.th_AttesterSlashing(RT.fz_AttesterSlashing(YS.OBJw(d, t, x, off, len))),
      Equal.sym(FuluAttesterSlashing_d.AttesterSlashing, RT.th_AttesterSlashing(RT.fz_AttesterSlashing(YS.OBJw(d, t, x, off, len))), YS.OBJw(d, t, x, off, len), WXA.tf_AttesterSlashing(d, t, x, off, len, eo, hd, hw, hw32, pf, hchk))),
    rep(d, t, x, off, len, hchk, s, ee))

# ---- the element's encoded size ----
# an IndexedAttestation the encoder accepts has 228 + (its list's bytes)
def szI(+tb: FD.array__Tree<U32>, +n: U32, +p1: FuluAttestationData_d.AttestationData, +p2: FuluBytes96_d.Bytes96,
    +eok: {EI.OKT(EXu.MW{U.LDEP(U32, tb), tb, n}, p1, p2) == True{} : Bool})
    -> {LY.LN(EI.ENC(EI.MW{EXu.MW{U.LDEP(U32, tb), tb, n}, p1, p2})) == Nat.add(228n, U32.to_nat(n)) : Nat}:
  Equal.trans(Nat, LY.LN(EI.ENC(EI.MW{EXu.MW{U.LDEP(U32, tb), tb, n}, p1, p2})), Nat.add(228n, LY.LN(EXu.ENC(EXu.MW{U.LDEP(U32, tb), tb, n}))), Nat.add(228n, U32.to_nat(n)),
    EI.lenE(EXu.MW{U.LDEP(U32, tb), tb, n}, p1, p2, eok),
    Equal.cong(Nat, Nat, z => Nat.add(228n, z), LY.LN(EXu.ENC(EXu.MW{U.LDEP(U32, tb), tb, n})), U32.to_nat(n),
      EXu.eL(U.LDEP(U32, tb), tb, n, EI.ok_hok_attesting_indices(EXu.MW{U.LDEP(U32, tb), tb, n}, p1, p2, eok))))

# 228 + (len - 228) = len
def s228(+len: U32, +k: Nat, +ek: {k == U32.to_nat(YI.LLw(len)) : Nat}, +h: {Nat.is_le(U32.to_nat(228), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.add(228n, k) == U32.to_nat(len) : Nat}:
  Equal.trans(Nat, Nat.add(228n, k), Nat.add(U32.to_nat(228), Nat.sub(U32.to_nat(len), U32.to_nat(228))), U32.to_nat(len),
    Equal.cong(Nat, Nat, z => Nat.add(228n, z), k, Nat.sub(U32.to_nat(len), U32.to_nat(228)), Equal.trans(Nat, k, U32.to_nat(YI.LLw(len)), Nat.sub(U32.to_nat(len), U32.to_nat(228)), ek, FD.u32__sub_nat(len, 228, h))),
    FD.nat__sub_add(U32.to_nat(len), U32.to_nat(228), h))

# the child's window is at least its fixed part
def ia_fix(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {YI.CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(228), U32.to_nat(len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(228, len), Nat.is_le(U32.to_nat(228), U32.to_nat(len)), VU.le_u32(228, len),
    YI.ch_a(U32.is_le(228, len), U32.is_eq(YI.SPOw(t, x), 228), WU.CHKw(t, YI.JW(x), YI.OWc(off), YI.LLw(len)), hc))

# 8 + (O1 - 8) + (len - O1) = len
def s8(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {YS.CHKw(t, x, off, len) == True{} : Bool})
    -> {Nat.add(Nat.add(8n, U32.to_nat(YS.L0(t, x))), U32.to_nat(YS.L1(t, x, len))) == U32.to_nat(len) : Nat}:
  +r1 = YS.ck(U32.is_eq(YS.O0(t, x), 8), YS.ck(YS.RR(t, x, len), YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len))))
  +r2 = YS.ck(YS.RR(t, x, len), YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len)))
  +h1 = YS.ck_b(U32.is_le(8, len), r1, hc)
  +h2 = YS.ck_b(U32.is_eq(YS.O0(t, x), 8), r2, h1)
  +hr = YS.ck_a(YS.RR(t, x, len), YS.ck(YS.D0(t, x, off), YS.D1(t, x, off, len)), h2)
  +h01 = YS.le_nat(YS.O0(t, x), YS.O1(t, x), FD.logic__and_left(U32.is_le(YS.O0(t, x), YS.O1(t, x)), U32.is_le(YS.O1(t, x), len), hr))
  +h1n = YS.le_nat(YS.O1(t, x), len, FD.logic__and_right(U32.is_le(YS.O0(t, x), YS.O1(t, x)), U32.is_le(YS.O1(t, x), len), hr))
  +e8 = FD.u32alg__eq_of(YS.O0(t, x), 8, YS.ck_a(U32.is_eq(YS.O0(t, x), 8), r2, h1))
  +n8 = Equal.cong(U32, Nat, z => U32.to_nat(z), YS.O0(t, x), 8, e8)
  +h8 = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(YS.O1(t, x))) == True{} : Bool}, U32.to_nat(YS.O0(t, x)), 8n, n8, h01)
  Equal.trans(Nat, Nat.add(Nat.add(8n, U32.to_nat(YS.L0(t, x))), U32.to_nat(YS.L1(t, x, len))), Nat.add(U32.to_nat(YS.O1(t, x)), U32.to_nat(YS.L1(t, x, len))), U32.to_nat(len),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(YS.L1(t, x, len))), Nat.add(8n, U32.to_nat(YS.L0(t, x))), U32.to_nat(YS.O1(t, x)),
      Equal.trans(Nat, Nat.add(8n, U32.to_nat(YS.L0(t, x))), Nat.add(8n, Nat.sub(U32.to_nat(YS.O1(t, x)), 8n)), U32.to_nat(YS.O1(t, x)),
        Equal.cong(Nat, Nat, z => Nat.add(8n, z), U32.to_nat(YS.L0(t, x)), Nat.sub(U32.to_nat(YS.O1(t, x)), 8n),
          Equal.trans(Nat, U32.to_nat(YS.L0(t, x)), Nat.sub(U32.to_nat(YS.O1(t, x)), U32.to_nat(YS.O0(t, x))), Nat.sub(U32.to_nat(YS.O1(t, x)), 8n), FD.u32__sub_nat(YS.O1(t, x), YS.O0(t, x), h01),
            Equal.cong(Nat, Nat, z => Nat.sub(U32.to_nat(YS.O1(t, x)), z), U32.to_nat(YS.O0(t, x)), 8n, n8))),
        FD.nat__sub_add(U32.to_nat(YS.O1(t, x)), 8n, h8))),
    Equal.trans(Nat, Nat.add(U32.to_nat(YS.O1(t, x)), U32.to_nat(YS.L1(t, x, len))), Nat.add(U32.to_nat(YS.O1(t, x)), Nat.sub(U32.to_nat(len), U32.to_nat(YS.O1(t, x)))), U32.to_nat(len),
      Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(YS.O1(t, x)), z), U32.to_nat(YS.L1(t, x, len)), Nat.sub(U32.to_nat(len), U32.to_nat(YS.O1(t, x))), FD.u32__sub_nat(len, YS.O1(t, x), h1n)),
      FD.nat__sub_add(U32.to_nat(len), U32.to_nat(YS.O1(t, x)), h1n)))

def mw0(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> EI.MW:
  EI.MW{EXu.MW{U.LDEP(U32, FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YI.OWc(YS.W0(t, x, off)), YI.LLw(YS.L0(t, x)), VLS.DZ(YI.LLw(YS.L0(t, x))))))),
    FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YI.OWc(YS.W0(t, x, off)), YI.LLw(YS.L0(t, x)), VLS.DZ(YI.LLw(YS.L0(t, x)))))), YI.LLw(YS.L0(t, x))},
    WXA.adI(YI.OBJw(d, t, YS.J0(t, x), YS.W0(t, x, off), YS.L0(t, x))), WXA.sgI(YI.OBJw(d, t, YS.J0(t, x), YS.W0(t, x, off), YS.L0(t, x)))}

def mw1(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> EI.MW:
  EI.MW{EXu.MW{U.LDEP(U32, FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YI.OWc(YS.W1(t, x, off)), YI.LLw(YS.L1(t, x, len)), VLS.DZ(YI.LLw(YS.L1(t, x, len))))))),
    FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YI.OWc(YS.W1(t, x, off)), YI.LLw(YS.L1(t, x, len)), VLS.DZ(YI.LLw(YS.L1(t, x, len)))))), YI.LLw(YS.L1(t, x, len))},
    WXA.adI(YI.OBJw(d, t, YS.J1(t, x), YS.W1(t, x, off), YS.L1(t, x, len))), WXA.sgI(YI.OBJw(d, t, YS.J1(t, x), YS.W1(t, x, off), YS.L1(t, x, len)))}

def eokAS(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YS.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {ES.OKT(mw0(d, t, x, off, len), mw1(d, t, x, off, len)) == True{} : Bool}:
  BBS.PA({W1.EOK(BBS.cvE(RT.fz_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len))))) == True{} : Bool},
    {RT.v_AttesterSlashing_bx(RT.th_AttesterSlashing_bx(RT.fz_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len))))) == W1.EV(BBS.cvE(RT.fz_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len))))) : S.Value},
    BBS.elx(RT.fz_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len))), Spec.AttesterSlashing(), ({==}, {==}),
      repT(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf, Spec.AttesterSlashing(), {==}), sde(d, t, x, off, len, hchk)))

def szA0(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YS.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {LY.LN(EI.ENC(mw0(d, t, x, off, len))) == U32.to_nat(YS.L0(t, x)) : Nat}:
  Equal.trans(Nat, LY.LN(EI.ENC(mw0(d, t, x, off, len))), Nat.add(228n, U32.to_nat(YI.LLw(YS.L0(t, x)))), U32.to_nat(YS.L0(t, x)),
    szI(FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YI.OWc(YS.W0(t, x, off)), YI.LLw(YS.L0(t, x)), VLS.DZ(YI.LLw(YS.L0(t, x)))))), YI.LLw(YS.L0(t, x)),
      WXA.adI(YI.OBJw(d, t, YS.J0(t, x), YS.W0(t, x, off), YS.L0(t, x))), WXA.sgI(YI.OBJw(d, t, YS.J0(t, x), YS.W0(t, x, off), YS.L0(t, x))),
      ES.ok_hok_attestation_1(mw0(d, t, x, off, len), mw1(d, t, x, off, len), eokAS(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf))),
    s228(YS.L0(t, x), U32.to_nat(YI.LLw(YS.L0(t, x))), {==}, ia_fix(t, YS.J0(t, x), YS.W0(t, x, off), YS.L0(t, x), as_d0(t, x, off, len, hchk))))

def szA1(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YS.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {LY.LN(EI.ENC(mw1(d, t, x, off, len))) == U32.to_nat(YS.L1(t, x, len)) : Nat}:
  Equal.trans(Nat, LY.LN(EI.ENC(mw1(d, t, x, off, len))), Nat.add(228n, U32.to_nat(YI.LLw(YS.L1(t, x, len)))), U32.to_nat(YS.L1(t, x, len)),
    szI(FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YI.OWc(YS.W1(t, x, off)), YI.LLw(YS.L1(t, x, len)), VLS.DZ(YI.LLw(YS.L1(t, x, len)))))), YI.LLw(YS.L1(t, x, len)),
      WXA.adI(YI.OBJw(d, t, YS.J1(t, x), YS.W1(t, x, off), YS.L1(t, x, len))), WXA.sgI(YI.OBJw(d, t, YS.J1(t, x), YS.W1(t, x, off), YS.L1(t, x, len))),
      ES.ok_hok_attestation_2(mw0(d, t, x, off, len), mw1(d, t, x, off, len), eokAS(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf))),
    s228(YS.L1(t, x, len), U32.to_nat(YI.LLw(YS.L1(t, x, len))), {==}, ia_fix(t, YS.J1(t, x), YS.W1(t, x, off), YS.L1(t, x, len), as_d1(t, x, off, len, hchk))))

# the element's encoded byte count (as the list's encoder sums it) is the window's length
def sz(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {YS.CHKw(t, x, off, len) == True{} : Bool},
    +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {List.length(&2, U32, W1.YE(BBS.cvE(RT.fz_AttesterSlashing_bx(FuluAttesterSlashing_d.AttesterSlashing_bx_wrap(YS.OBJw(d, t, x, off, len)))))) == U32.to_nat(len) : Nat}:
  Equal.trans(Nat, List.length(&2, U32, ES.ENC(ES.MW{mw0(d, t, x, off, len), mw1(d, t, x, off, len)})), Nat.add(Nat.add(8n, U32.to_nat(YS.L0(t, x))), U32.to_nat(YS.L1(t, x, len))), U32.to_nat(len),
    Equal.trans(Nat, List.length(&2, U32, ES.ENC(ES.MW{mw0(d, t, x, off, len), mw1(d, t, x, off, len)})), Nat.add(Nat.add(8n, LY.LN(EI.ENC(mw0(d, t, x, off, len)))), LY.LN(EI.ENC(mw1(d, t, x, off, len)))),
      Nat.add(Nat.add(8n, U32.to_nat(YS.L0(t, x))), U32.to_nat(YS.L1(t, x, len))),
      ES.lenE(mw0(d, t, x, off, len), mw1(d, t, x, off, len), eokAS(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf)),
      Equal.trans(Nat, Nat.add(Nat.add(8n, LY.LN(EI.ENC(mw0(d, t, x, off, len)))), LY.LN(EI.ENC(mw1(d, t, x, off, len)))),
        Nat.add(Nat.add(8n, U32.to_nat(YS.L0(t, x))), LY.LN(EI.ENC(mw1(d, t, x, off, len)))), Nat.add(Nat.add(8n, U32.to_nat(YS.L0(t, x))), U32.to_nat(YS.L1(t, x, len))),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(8n, z), LY.LN(EI.ENC(mw1(d, t, x, off, len)))), LY.LN(EI.ENC(mw0(d, t, x, off, len))), U32.to_nat(YS.L0(t, x)), szA0(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(8n, U32.to_nat(YS.L0(t, x))), z), LY.LN(EI.ENC(mw1(d, t, x, off, len))), U32.to_nat(YS.L1(t, x, len)), szA1(d, t, x, off, len, hchk, eo, hd, hw, hw32, pf)))),
    s8(t, x, off, len, hchk))
