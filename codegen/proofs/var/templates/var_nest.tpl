@@ win_module_text @@
def SPOw(t: FD.array__Tree<U32>, +i: Nat) -> U32: VB.slot(t, Nat.add(${po}n, i))

def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> Bool:
  DC.chk3(U32.is_le(${FS}, len), U32.is_eq(SPOw(t, i), ${FS}), DC.whole(U32.sub(len, SPOw(t, i))))

def winb(+k: Nat, +i: Nat, +len: U32, +P: Nat, +hk: {Nat.is_le(A.quad(k), U32.to_nat(len)) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), P) == True{} : Bool}) -> {Nat.is_le(A.quad(Nat.add(k, i)), P) == True{} : Bool}:
  %VF.quad_add(k, i) : {Nat.is_le(_, P) == True{} : Bool}
  FD.nat__le_trans(Nat.add(A.quad(k), A.quad(i)), Nat.add(U32.to_nat(len), A.quad(i)), P, Order.add_right(A.quad(k), U32.to_nat(len), A.quad(i), hk),
    FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(U32.to_nat(len), A.quad(i)), FD.nat__add_comm(A.quad(i), U32.to_nat(len)), hw))

def hlen(+d: Nat, +i: Nat, +len: U32,
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(len), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(i), U32.to_nat(len)), hw)

# The byte offset off + c of header byte c = 4 k (k <= H) is word k + i.
def eoc(+d: Nat, +i: Nat, +off: U32, +len: U32, +k: Nat, +c: U32, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hkF: {Nat.is_le(A.quad(k), ${FS}n) == True{} : Bool}, ${WH}, ${HA})
    -> {U32.to_nat(U32.add(off, c)) == A.quad(Nat.add(k, i)) : Nat}:
  VF.off_add_lt(off, c, i, k, eo, ec,
    FD.nat__le_lt_trans(A.quad(Nat.add(k, i)), Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n),
      winb(k, i, len, Nat.add(A.quad(i), U32.to_nat(len)), FD.nat__le_trans(A.quad(k), ${FS}n, U32.to_nat(len), hkF, DC.leFS(len, ha)), FD.nat__le_refl(Nat.add(A.quad(i), U32.to_nat(len)))), hw32))

# Header words k < H of the window are below 2^d.
def hiw(+d: Nat, +i: Nat, +len: U32, +k: Nat, +hk: {Nat.is_lt(k, ${H}n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA})
    -> {Nat.is_lt(Nat.add(k, i), VB.pw(d)) == True{} : Bool}:
  FD.nat__lt_le_trans(Nat.add(k, i), Nat.add(${H}n, i), VB.pw(d), VB.lt_kk(k, ${H}n, i, hk),
    VC.quad_inv(Nat.add(${H}n, i), VB.pw(d), winb(${H}n, i, len, A.quad(VB.pw(d)), DC.leFS(len, ha), hw)))

def okw_c0(+t: FD.array__Tree<U32>, +n: U32, +off: U32, +len: U32, +i: Nat, +b: Bool)
    -> {${Tn}_c0(b, DC.BF(t, n), off, len, SPOw(t, i)) == (DC.BF(t, n), DC.chk3(True{}, b, DC.whole(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}: DC.c1_id(DC.whole(U32.sub(len, SPOw(t, i))), DC.BF(t, n), off, len, SPOw(t, i))

def okw_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF},
    +a: Bool, +ea: {U32.is_le(${FS}, len) == a : Bool})
    -> {${Tn}_ok_len(a, DC.BF(t, n), off, len) == (DC.BF(t, n), DC.chk3(a, U32.is_eq(SPOw(t, i), ${FS}), DC.whole(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(DC.BF(t, n), U32.add(off, ${cvar})), (DC.BF(t, n), SPOw(t, i)),
          VF.rd32a(d, t, n, U32.add(off, ${cvar}), Nat.add(${po}n, i), eoc(d, i, off, len, ${po}n, ${cvar}, {==}, {==}, eo, hd, hw, hw32, ea),
            VB.lt32(d, hd), hiw(d, i, len, ${po}n, {==}, hw, ea), pf)) :
        {${Tn}_v0(off, len, _) == (DC.BF(t, n), DC.chk3(True{}, U32.is_eq(SPOw(t, i), ${FS}), DC.whole(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}
      okw_c0(t, n, off, len, i, U32.is_eq(SPOw(t, i), ${FS}))

# The validator on the window returns the buffer and CHKw(t, i, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF})
    -> {${Tn}_ok(DC.BF(t, n), off, len) == (DC.BF(t, n), CHKw(t, i, len)) : B.Buf & Bool}:
  okw_len(d, t, n, i, off, len, eo, hd, hw, hw32, pf, U32.is_le(${FS}, len), {==})

# NW + H + i <= 2^d: the window's header and list words lie in the buffer.
def hsw(+d: Nat, +i: Nat, +len: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, ${HC})
    -> {Nat.is_le(Nat.add(${NW}, Nat.add(${H}n, i)), VB.pw(d)) == True{} : Bool}:
  +q = DC.CQ(len)
  +elen = Equal.trans(Nat, U32.to_nat(len), Nat.add(${FS}n, U32.to_nat(DC.LL(len))), Nat.add(${FS}n, VB.d3(q)),
    Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(DC.LL(len))), U32.to_nat(len), DC.enFS(len, ha)),
    Equal.cong(Nat, Nat, z => Nat.add(${FS}n, z), U32.to_nat(DC.LL(len)), VB.d3(q), Equal.trans(Nat, U32.to_nat(DC.LL(len)), VS.x8(q), VB.d3(q), DC.eLc(len, hc), VB.x8_d3(q))))
  +e1 = Equal.trans(Nat, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(i), A.quad(Nat.add(${H}n, Nat.double(q)))), A.quad(Nat.add(i, Nat.add(${H}n, Nat.double(q)))),
    Equal.cong(Nat, Nat, z => Nat.add(A.quad(i), z), U32.to_nat(len), A.quad(Nat.add(${H}n, Nat.double(q))), elen),
    VF.quad_add(i, Nat.add(${H}n, Nat.double(q))))
  +h2 = VC.quad_inv(Nat.add(i, Nat.add(${H}n, Nat.double(q))), VB.pw(d),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(len)), A.quad(Nat.add(i, Nat.add(${H}n, Nat.double(q)))), e1, hw))
  +h3 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(d)) == True{} : Bool}, Nat.add(i, Nat.add(${H}n, Nat.double(q))), Nat.add(Nat.add(${H}n, Nat.double(q)), i),
    FD.nat__add_comm(i, Nat.add(${H}n, Nat.double(q))), h2)
  %Equal.sym(Nat, ${NW}, Nat.double(q), DC.eNWc(d, len, hd, ha, hlen(d, i, len, hw), hc)) : {Nat.is_le(Nat.add(_, Nat.add(${H}n, i)), VB.pw(d)) == True{} : Bool}
  %FD.nat__add_comm(Nat.add(${H}n, i), Nat.double(q)) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %FD.nat__add_comm(Nat.double(q), i) : {Nat.is_le(Nat.add(${H}n, _), VB.pw(d)) == True{} : Bool}
  h3

@@ win_module_text_rdw_go @@

def rdw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF},
    ${HA}, +epo: {SPOw(t, i) == ${FS} : U32}, ${HC})
    -> {${Tn}_read(DC.BF(t, n), off, len) == (DC.BF(t, n), OBJw(t, i, len)) : ${TY}}:
  +hl = hlen(d, i, len, hw)
  +hz = DC.hdzK(d, len, hd, ha, hl, hc)
  +ez = DC.zeros_at(B.words_depth_u(VC.WZ(DC.LL(len))), DC.DZ(len), VD.wdu(VC.WZ(DC.LL(len))), FD.nat__le_trans(DC.DZ(len), ${K}n, ${KK}n, hz, {==}))
  rd_okw(d, t, n, i, off, len, DC.DZ(len), eo, hd, hw, hw32, pf, ha, FD.nat__le_lt_trans(DC.DZ(len), ${K}n, 31n, hz, {==}), epo, ez,
    VC.and3_x8(DC.LL(len), DC.CQ(len), DC.eLc(len, hc)), DC.hr(d, len, hd, ha, hl, hc), hsw(d, i, len, hd, hw, ha, hc))

# When the window's checks hold, the reader returns OBJw(t, i, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF},
    +hchk: {CHKw(t, i, len) == True{} : Bool})
    -> {${Tn}_read(DC.BF(t, n), off, len) == (DC.BF(t, n), OBJw(t, i, len)) : ${TY}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, i), ${FS})
  +c = DC.whole(U32.sub(len, SPOw(t, i)))
  +epo = FD.u32alg__eq_of(SPOw(t, i), ${FS}, DC.chk_b(a, b, c, hchk))
  rdw_go(d, t, n, i, off, len, eo, hd, hw, hw32, pf, DC.chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {DC.whole(U32.sub(len, z)) == True{} : Bool}, SPOw(t, i), ${FS}, epo, DC.chk_c(a, b, c, hchk)))

@@ win_module_text_XVw @@
# ---- the spec side -------------------------------------------------------------------------

def XVw(+t: FD.array__Tree<U32>, +i: Nat, +k: Nat, +W: List<&2, U32>) -> S.Value: S.Sequence{${ITEMS}}

# The spec parts of the value: one variable part, the limbs of the header words and the list's words.
def encpw(+t: FD.array__Tree<U32>, +i: Nat, +k: Nat, +W: List<&2, U32>,
    +hk: {Nat.is_le(k, ${LIMN}) == True{} : Bool},
    +hl: {Nat.is_le(Nat.double(k), FD.spec_common__length(U32, W)) == True{} : Bool})
    -> {Codec.parts(XVw(t, i, k, W), Spec.${n}()) == ${RP} : ${MP}}:
  +le2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(${LIMN})) == True{} : Bool}, VS.x8(k), List.length(&2, U32, F.limbs(${YS})),
    Equal.sym(Nat, List.length(&2, U32, F.limbs(${YS})), VS.x8(k), VS.len_limbs_wtake2(k, W, hl)), VS.x8_mono(k, ${LIMN}, hk))
  +fit = VS.fits_mono(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, F.limbs(${YS}))), Nat.add(${FS}n, VS.x8(${LIMN})),
    Order.add_left(${FS}n, List.length(&2, U32, F.limbs(${YS})), VS.x8(${LIMN}), le2), ${K_FIT})
  %Equal.sym(${MP}, Codec.parts(${ITEMS}, ${CHAIN}), Some{${PL}},
      ${CAT}) :
    {Codec.aggregate(_, None{}) == ${RP} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, F.limbs(${YS}), ${POST})), Some{${ENCR}}, VS.enc_fpv(${PRE}, ${YS}, ${POST}, fit)) :
    {Codec.one(_, None{}) == ${RP} : ${MP}}
  {==}

def MMw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> FD.array__Tree<U32>: ${MM}
def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: XVw(t, i, DC.CQ(len), FD.array__slots(U32, MMw(t, i, len)))

# Those bytes are the window's words.
def lim_eqw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32}, ${HC})
    -> {F.limbs(${HDR} <> VS.wtake(Nat.double(DC.CQ(len)), FD.array__slots(U32, MMw(t, i, len)))) == ${WIN} : +List<U32>}:
  +hl = hlen(d, i, len, hw)
  +hr0 = DC.hr(d, len, hd, ha, hl, hc)
  +hsl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${NW}, Nat.add(${H}n, i)), z) == True{} : Bool}, VB.pw(d), VB.len(${s}), Equal.sym(Nat, VB.len(${s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hsw(d, i, len, hd, hw, ha, hc))
  +hpre = FD.nat__le_trans(Nat.add(${H}n, i), Nat.add(${NW}, Nat.add(${H}n, i)), VB.len(${s}), Order.left_below_sum(${NW}, Nat.add(${H}n, i)), hsl)
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(${H}n, ${NW}), VB.wdr(i, ${s})), VF.app(VF.wpre(${H}n, i, ${s}), VS.wtake(${NW}, VB.wdr(Nat.add(${H}n, i), ${s}))), VF.wt_pre(${H}n, ${NW}, i, ${s}, hpre)) :
    {F.limbs(${HDR} <> VS.wtake(Nat.double(DC.CQ(len)), FD.array__slots(U32, MMw(t, i, len)))) == F.limbs(_) : +List<U32>}
  %epo : {F.limbs(${hdrh} <> VS.wtake(Nat.double(DC.CQ(len)), FD.array__slots(U32, MMw(t, i, len)))) == ${RW} : +List<U32>}
  %Equal.sym(List<&2, U32>, FD.array__slots(U32, MMw(t, i, len)), ${LM},
      VB.slots_mone(${NW}, Nat.add(${H}n, i), 0n, DC.DZ(len), VC.ZT(DC.DZ(len)), t, FD.array__trep_perfect(U32, DC.DZ(len), 0), hr0)) :
    {F.limbs(${hdrs} <> VS.wtake(Nat.double(DC.CQ(len)), _)) == ${RW} : +List<U32>}
  %DC.eNWc(d, len, hd, ha, hl, hc) : {F.limbs(${hdrs} <> VS.wtake(_, ${LM})) == ${RW} : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(${NW}, VB.wdr(0n, ${LM})), VS.wtake(${NW}, VB.wdr(Nat.add(${H}n, i), ${s})),
      VB.lm_win(${NW}, Nat.add(${H}n, i), 0n, FD.array__slots(U32, VC.ZT(DC.DZ(len))), ${s},
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${NW}, 0n), z) == True{} : Bool}, VB.pw(DC.DZ(len)), VB.len(FD.array__slots(U32, VC.ZT(DC.DZ(len)))), Equal.sym(Nat, VB.len(FD.array__slots(U32, VC.ZT(DC.DZ(len)))), VB.pw(DC.DZ(len)), DC.len_z(len)), hr0),
        hsl)) :
    {F.limbs(${hdrs} <> _) == ${RW} : +List<U32>}
  {==}

def hl_mmw(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +len: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hl: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, ${HC})
    -> {Nat.is_le(Nat.double(DC.CQ(len)), FD.spec_common__length(U32, FD.array__slots(U32, MMw(t, i, len)))) == True{} : Bool}:
  %Equal.sym(Nat, FD.spec_common__length(U32, FD.array__slots(U32, MMw(t, i, len))), VB.pw(DC.DZ(len)),
      FD.array__slots_length(U32, DC.DZ(len), MMw(t, i, len), VB.mone_perfect(${NW}, Nat.add(${H}n, i), 0n, DC.DZ(len), VC.ZT(DC.DZ(len)), t, FD.array__trep_perfect(U32, DC.DZ(len), 0)))) :
    {Nat.is_le(Nat.double(DC.CQ(len)), _) == True{} : Bool}
  %DC.eNWc(d, len, hd, ha, hl, hc) : {Nat.is_le(_, VB.pw(DC.DZ(len))) == True{} : Bool}
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(DC.DZ(len))) == True{} : Bool}, Nat.add(${NW}, 0n), ${NW}, FD.nat__add_zero(${NW}), DC.hr(d, len, hd, ha, hl, hc))

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32}, ${HC})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WIN}}]} : ${MP}}:
  %lim_eqw(d, t, n, i, len, pf, hd, hw, ha, epo, hc) :
    {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{_}]} : ${MP}}
  encpw(t, i, DC.CQ(len), FD.array__slots(U32, MMw(t, i, len)), DC.hcL(len, hc), hl_mmw(d, t, i, len, hd, hlen(d, i, len, hw), ha, hc))

# When the window's checks hold, the spec parts of VALw are its words, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHKw(t, i, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WIN}}]} : ${MP}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, i), ${FS})
  +c = DC.whole(U32.sub(len, SPOw(t, i)))
  +epo = FD.u32alg__eq_of(SPOw(t, i), ${FS}, DC.chk_b(a, b, c, hchk))
  specw_go(d, t, n, i, len, pf, hd, hw, DC.chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {DC.whole(U32.sub(len, z)) == True{} : Bool}, SPOw(t, i), ${FS}, epo, DC.chk_c(a, b, c, hchk)))

@@ AS_DEC @@

def O0(t: FD.array__Tree<U32>) -> U32: VB.slot(t, 0n)
def O1(t: FD.array__Tree<U32>) -> U32: VB.slot(t, 1n)
def L1(+t: FD.array__Tree<U32>) -> U32: U32.sub(O1(t), 8)
def J(+t: FD.array__Tree<U32>) -> Nat: Nat.add(2n, Nat.add(@Hn, VC.NW(DC.LL(L1(t)))))
def L2(+t: FD.array__Tree<U32>, +n: U32) -> U32: U32.sub(n, O1(t))

def chk5(a: Bool, b: Bool, c: Bool, d: Bool, e: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}:
          match c:
            case False{}: False{}
            case True{}:
              match d:
                case False{}: False{}
                case True{}: e

# The Bool of the validator's checks: the fixed part is there, the first
# offset is 8, the second lies between it and the end, and both windows pass
# the child's checks (the second window starts at word J(t)).
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool:
  chk5(U32.is_le(8, n), U32.is_eq(O0(t), 8), Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n)), W.CHKw(t, 2n, L1(t)), W.CHKw(t, J(t), L2(t, n)))

def c3_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32, +o1: U32) -> {@P_c3(ok, buf, off, len, o0, o1) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def le_nat(+a: U32, +b: U32, +h: {U32.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

# The first window: 8 + (O1 - 8) = O1 <= n.
def hw1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A.quad(2n), U32.to_nat(L1(t))), A.quad(VB.pw(d))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(L1(t)), Nat.sub(U32.to_nat(O1(t)), 8n), FD.u32__sub_nat(O1(t), 8, h8)) : {Nat.is_le(Nat.add(8n, _), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(8n, Nat.sub(U32.to_nat(O1(t)), 8n)), U32.to_nat(O1(t)), FD.nat__sub_add(U32.to_nat(O1(t)), 8n, h8)) : {Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}
  FD.nat__le_trans(U32.to_nat(O1(t)), U32.to_nat(n), A.quad(VB.pw(d)), h1n, hn)

# The first window ends below 2^32 (at O1 <= n).
def hw1s(+t: FD.array__Tree<U32>, +n: U32,
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(A.quad(2n), U32.to_nat(L1(t))), FD.spec_common__pow2(32n)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(L1(t)), Nat.sub(U32.to_nat(O1(t)), 8n), FD.u32__sub_nat(O1(t), 8, h8)) : {Nat.is_lt(Nat.add(8n, _), FD.spec_common__pow2(32n)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(8n, Nat.sub(U32.to_nat(O1(t)), 8n)), U32.to_nat(O1(t)), FD.nat__sub_add(U32.to_nat(O1(t)), 8n, h8)) : {Nat.is_lt(_, FD.spec_common__pow2(32n)) == True{} : Bool}
  VB.le_n_lt32(U32.to_nat(O1(t)), n, h1n)

# The second window starts at word J: O1 = 4 J.
def eJ(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool},
    +ha: {U32.is_le(@FS, L1(t)) == True{} : Bool}, +hc: {DC.whole(DC.LL(L1(t))) == True{} : Bool})
    -> {U32.to_nat(O1(t)) == A.quad(J(t)) : Nat}:
  +hl = W.hlen(d, 2n, L1(t), hw1(d, t, n, hn, h8, h1n))
  %Equal.sym(Nat, VC.NW(DC.LL(L1(t))), Nat.double(DC.CQ(L1(t))), DC.eNWc(d, L1(t), hd, ha, hl, hc)) :
    {U32.to_nat(O1(t)) == A.quad(Nat.add(2n, Nat.add(@Hn, _))) : Nat}
  %FD.nat__sub_add(U32.to_nat(O1(t)), 8n, h8) : {_ == A.quad(Nat.add(2n, Nat.add(@Hn, Nat.double(DC.CQ(L1(t)))))) : Nat}
  %FD.u32__sub_nat(O1(t), 8, h8) : {Nat.add(8n, _) == A.quad(Nat.add(2n, Nat.add(@Hn, Nat.double(DC.CQ(L1(t)))))) : Nat}
  %DC.enFS(L1(t), ha) : {Nat.add(8n, _) == A.quad(Nat.add(2n, Nat.add(@Hn, Nat.double(DC.CQ(L1(t)))))) : Nat}
  %Equal.sym(Nat, U32.to_nat(DC.LL(L1(t))), VS.x8(DC.CQ(L1(t))), DC.eLc(L1(t), hc)) :
    {Nat.add(8n, Nat.add(@FSn, _)) == A.quad(Nat.add(2n, Nat.add(@Hn, Nat.double(DC.CQ(L1(t)))))) : Nat}
  %Equal.sym(Nat, VS.x8(DC.CQ(L1(t))), VB.d3(DC.CQ(L1(t))), VB.x8_d3(DC.CQ(L1(t)))) :
    {Nat.add(8n, Nat.add(@FSn, _)) == A.quad(Nat.add(2n, Nat.add(@Hn, Nat.double(DC.CQ(L1(t)))))) : Nat}
  {==}

def e0J(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool},
    +ha: {U32.is_le(@FS, L1(t)) == True{} : Bool}, +hc: {DC.whole(DC.LL(L1(t))) == True{} : Bool})
    -> {U32.to_nat(U32.add(0, O1(t))) == A.quad(J(t)) : Nat}:
  +hb = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, U32.to_nat(O1(t)), Nat.add(U32.to_nat(O1(t)), 0n),
    Equal.sym(Nat, Nat.add(U32.to_nat(O1(t)), 0n), U32.to_nat(O1(t)), FD.nat__add_zero(U32.to_nat(O1(t)))),
    VB.le_n_lt32(U32.to_nat(O1(t)), n, h1n))
  %Equal.sym(Nat, U32.to_nat(U32.add(0, O1(t))), Nat.add(U32.to_nat(O1(t)), 0n), VB.add_lt32(0, O1(t), 0n, {==}, hb)) : {_ == A.quad(J(t)) : Nat}
  %Equal.sym(Nat, Nat.add(U32.to_nat(O1(t)), 0n), U32.to_nat(O1(t)), FD.nat__add_zero(U32.to_nat(O1(t)))) : {_ == A.quad(J(t)) : Nat}
  eJ(d, t, n, hd, hn, h8, h1n, ha, hc)

# The second window: 4 J + (n - O1) = n.
def hw2(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool}, +ej: {U32.to_nat(O1(t)) == A.quad(J(t)) : Nat})
    -> {Nat.is_le(Nat.add(A.quad(J(t)), U32.to_nat(L2(t, n))), A.quad(VB.pw(d))) == True{} : Bool}:
  %ej : {Nat.is_le(Nat.add(_, U32.to_nat(L2(t, n))), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(L2(t, n)), Nat.sub(U32.to_nat(n), U32.to_nat(O1(t))), FD.u32__sub_nat(n, O1(t), h1n)) :
    {Nat.is_le(Nat.add(U32.to_nat(O1(t)), _), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(U32.to_nat(O1(t)), Nat.sub(U32.to_nat(n), U32.to_nat(O1(t)))), U32.to_nat(n), FD.nat__sub_add(U32.to_nat(n), U32.to_nat(O1(t)), h1n)) :
    {Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}
  hn

# ... and ends at n < 2^32.
def hw2s(+t: FD.array__Tree<U32>, +n: U32,
    +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool}, +ej: {U32.to_nat(O1(t)) == A.quad(J(t)) : Nat})
    -> {Nat.is_lt(Nat.add(A.quad(J(t)), U32.to_nat(L2(t, n))), FD.spec_common__pow2(32n)) == True{} : Bool}:
  %ej : {Nat.is_lt(Nat.add(_, U32.to_nat(L2(t, n))), FD.spec_common__pow2(32n)) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(L2(t, n)), Nat.sub(U32.to_nat(n), U32.to_nat(O1(t))), FD.u32__sub_nat(n, O1(t), h1n)) :
    {Nat.is_lt(Nat.add(U32.to_nat(O1(t)), _), FD.spec_common__pow2(32n)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(U32.to_nat(O1(t)), Nat.sub(U32.to_nat(n), U32.to_nat(O1(t)))), U32.to_nat(n), FD.nat__sub_add(U32.to_nat(n), U32.to_nat(O1(t)), h1n)) :
    {Nat.is_lt(_, FD.spec_common__pow2(32n)) == True{} : Bool}
  VB.u32_lt(n)

def st_d(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool},
    +dd: Bool, +ed: {W.CHKw(t, 2n, L1(t)) == dd : Bool})
    -> {@P_c2(dd, DC.BF(t, n), 0, n, 8, O1(t)) == (DC.BF(t, n), chk5(True{}, True{}, True{}, dd, W.CHKw(t, J(t), L2(t, n)))) : B.Buf & Bool}:
  match dd:
    case False{}: {==}
    case True{}:
      +a = U32.is_le(@FS, L1(t))
      +b = U32.is_eq(W.SPOw(t, 2n), @FS)
      +c = DC.whole(U32.sub(L1(t), W.SPOw(t, 2n)))
      +epo = FD.u32alg__eq_of(W.SPOw(t, 2n), @FS, DC.chk_b(a, b, c, ed))
      +hc = FD.logic__subst(U32, z => {DC.whole(U32.sub(L1(t), z)) == True{} : Bool}, W.SPOw(t, 2n), @FS, epo, DC.chk_c(a, b, c, ed))
      +ej = e0J(d, t, n, hd, hn, h8, h1n, DC.chk_a(a, b, c, ed), hc)
      +ej1 = eJ(d, t, n, hd, hn, h8, h1n, DC.chk_a(a, b, c, ed), hc)
      %Equal.sym(B.Buf & Bool, @C_ok(DC.BF(t, n), U32.add(0, O1(t)), L2(t, n)), (DC.BF(t, n), W.CHKw(t, J(t), L2(t, n))),
          W.ok_evalw(d, t, n, J(t), U32.add(0, O1(t)), L2(t, n), ej, hd, hw2(d, t, n, hn, h1n, ej1), hw2s(t, n, h1n, ej1), pf)) :
        {@P_v3(0, n, 8, O1(t), _) == (DC.BF(t, n), W.CHKw(t, J(t), L2(t, n))) : B.Buf & Bool}
      c3_id(W.CHKw(t, J(t), L2(t, n)), DC.BF(t, n), 0, n, 8, O1(t))

def st_c(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e0: {O0(t) == 8 : U32},
    +c: Bool, +ec: {Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n)) == c : Bool})
    -> {@P_c1(c, DC.BF(t, n), 0, n, O0(t), O1(t)) == (DC.BF(t, n), chk5(True{}, True{}, c, W.CHKw(t, 2n, L1(t)), W.CHKw(t, J(t), L2(t, n)))) : B.Buf & Bool}:
  match c:
    case False{}: {==}
    case True{}:
      +h01 = FD.logic__and_left(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n), ec)
      +h1n = le_nat(O1(t), n, FD.logic__and_right(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n), ec))
      +h8 = le_nat(8, O1(t), FD.logic__subst(U32, z => {U32.is_le(z, O1(t)) == True{} : Bool}, O0(t), 8, e0, h01))
      %Equal.sym(U32, O0(t), 8, e0) :
        {@P_v2(0, n, _, O1(t), @C_ok(DC.BF(t, n), U32.add(0, _), U32.sub(O1(t), _))) == (DC.BF(t, n), chk5(True{}, True{}, True{}, W.CHKw(t, 2n, L1(t)), W.CHKw(t, J(t), L2(t, n)))) : B.Buf & Bool}
      %Equal.sym(B.Buf & Bool, @C_ok(DC.BF(t, n), U32.add(0, 8), L1(t)), (DC.BF(t, n), W.CHKw(t, 2n, L1(t))),
          W.ok_evalw(d, t, n, 2n, U32.add(0, 8), L1(t), {==}, hd, hw1(d, t, n, hn, h8, h1n), hw1s(t, n, h8, h1n), pf)) :
        {@P_v2(0, n, 8, O1(t), _) == (DC.BF(t, n), chk5(True{}, True{}, True{}, W.CHKw(t, 2n, L1(t)), W.CHKw(t, J(t), L2(t, n)))) : B.Buf & Bool}
      st_d(d, t, n, pf, hd, hn, h8, h1n, W.CHKw(t, 2n, L1(t)), {==})

def hi2(+d: Nat, +n: U32, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +h8: {Nat.is_le(8n, U32.to_nat(n)) == True{} : Bool})
    -> {Nat.is_le(2n, VB.pw(d)) == True{} : Bool}:
  VC.quad_inv(2n, VB.pw(d), FD.nat__le_trans(8n, U32.to_nat(n), A.quad(VB.pw(d)), h8, hn))

def st_b(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +h2: {Nat.is_le(2n, VB.pw(d)) == True{} : Bool},
    +b: Bool, +eb: {U32.is_eq(O0(t), 8) == b : Bool})
    -> {@P_c0(b, DC.BF(t, n), 0, n, O0(t)) == (DC.BF(t, n), chk5(True{}, b, Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n)), W.CHKw(t, 2n, L1(t)), W.CHKw(t, J(t), L2(t, n)))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      +hd32 = VB.lt32(d, hd)
      %Equal.sym(B.Buf & U32, B.word(DC.BF(t, n), 1), (DC.BF(t, n), O1(t)), DC.rd32(d, t, n, 1, 1n, {==}, hd32, FD.nat__lt_le_trans(1n, 2n, VB.pw(d), {==}, h2), pf)) :
        {@P_v1(0, n, O0(t), _) == (DC.BF(t, n), chk5(True{}, True{}, Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n)), W.CHKw(t, 2n, L1(t)), W.CHKw(t, J(t), L2(t, n)))) : B.Buf & Bool}
      st_c(d, t, n, pf, hd, hn, FD.u32alg__eq_of(O0(t), 8, eb), Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n)), {==})

def st_a(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +a: Bool, +ea: {U32.is_le(8, n) == a : Bool})
    -> {@P_ok_len(a, DC.BF(t, n), 0, n) == (DC.BF(t, n), chk5(a, U32.is_eq(O0(t), 8), Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n)), W.CHKw(t, 2n, L1(t)), W.CHKw(t, J(t), L2(t, n)))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      +h2 = hi2(d, n, hn, le_nat(8, n, ea))
      +hd32 = VB.lt32(d, hd)
      %Equal.sym(B.Buf & U32, B.word(DC.BF(t, n), 0), (DC.BF(t, n), O0(t)), DC.rd32(d, t, n, 0, 0n, {==}, hd32, FD.nat__lt_le_trans(0n, 2n, VB.pw(d), {==}, h2), pf)) :
        {@P_v0(0, n, _) == (DC.BF(t, n), chk5(True{}, U32.is_eq(O0(t), 8), Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n)), W.CHKw(t, 2n, L1(t)), W.CHKw(t, J(t), L2(t, n)))) : B.Buf & Bool}
      st_b(d, t, n, pf, hd, hn, h2, U32.is_eq(O0(t), 8), {==})

# The validator returns the buffer and CHK(t, n).
def ok_eval(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {@P_ok(DC.BF(t, n), 0, n) == (DC.BF(t, n), CHK(t, n)) : B.Buf & Bool}:
  st_a(d, t, n, pf, hd, hn, U32.is_le(8, n), {==})
# ---- decoding -------------------------------------------------------------------------------

def c5a(+a: Bool, +b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(a, b, c, d, e) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}
def c5b(+a: Bool, +b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(a, b, c, d, e) == True{} : Bool}) -> {b == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: h
    case True{} True{}: {==}
def c5c(+a: Bool, +b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(a, b, c, d, e) == True{} : Bool}) -> {c == True{} : Bool}:
  match a b c:
    case False{} _ _: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{} _: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{} False{}: h
    case True{} True{} True{}: {==}
def c5d(+a: Bool, +b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(a, b, c, d, e) == True{} : Bool}) -> {d == True{} : Bool}:
  match a b c d:
    case False{} _ _ _: Empty.absurd({d == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{} _ _: Empty.absurd({d == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{} False{} _: Empty.absurd({d == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{} True{} False{}: h
    case True{} True{} True{} True{}: {==}
def c5e(+a: Bool, +b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(a, b, c, d, e) == True{} : Bool}) -> {e == True{} : Bool}:
  match a b c d:
    case False{} _ _ _: Empty.absurd({e == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{} _ _: Empty.absurd({e == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{} False{} _: Empty.absurd({e == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{} True{} False{}: Empty.absurd({e == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{} True{} True{}: h

# A window's checks give its length facts.
def wha(+t: FD.array__Tree<U32>, +i: Nat, +len: U32, +h: {W.CHKw(t, i, len) == True{} : Bool}) -> {U32.is_le(@FS, len) == True{} : Bool}:
  DC.chk_a(U32.is_le(@FS, len), U32.is_eq(W.SPOw(t, i), @FS), DC.whole(U32.sub(len, W.SPOw(t, i))), h)
def whc(+t: FD.array__Tree<U32>, +i: Nat, +len: U32, +h: {W.CHKw(t, i, len) == True{} : Bool}) -> {DC.whole(DC.LL(len)) == True{} : Bool}:
  +a = U32.is_le(@FS, len)
  +b = U32.is_eq(W.SPOw(t, i), @FS)
  +c = DC.whole(U32.sub(len, W.SPOw(t, i)))
  +epo = FD.u32alg__eq_of(W.SPOw(t, i), @FS, DC.chk_b(a, b, c, h))
  FD.logic__subst(U32, z => {DC.whole(U32.sub(len, z)) == True{} : Bool}, W.SPOw(t, i), @FS, epo, DC.chk_c(a, b, c, h))

def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> @P:
  @P{O.BSome{W.OBJw(t, 2n, L1(t)), O.BNone{}}, O.BSome{W.OBJw(t, J(t), L2(t, n)), O.BNone{}}}

def rd_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e0: {O0(t) == 8 : U32},
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool},
    +hk1: {W.CHKw(t, 2n, L1(t)) == True{} : Bool}, +hk2: {W.CHKw(t, J(t), L2(t, n)) == True{} : Bool})
    -> {@P_read(DC.BF(t, n), 0, n) == (DC.BF(t, n), OBJ(t, n)) : B.Buf & @P}:
  +hd32 = VB.lt32(d, hd)
  +h2 = hi2(d, n, hn, FD.nat__le_trans(8n, U32.to_nat(O1(t)), U32.to_nat(n), h8, h1n))
  +ej = e0J(d, t, n, hd, hn, h8, h1n, wha(t, 2n, L1(t), hk1), whc(t, 2n, L1(t), hk1))
  +ej1 = eJ(d, t, n, hd, hn, h8, h1n, wha(t, 2n, L1(t), hk1), whc(t, 2n, L1(t), hk1))
  %Equal.sym(B.Buf & U32, B.word(DC.BF(t, n), 0), (DC.BF(t, n), O0(t)), DC.rd32(d, t, n, 0, 0n, {==}, hd32, FD.nat__lt_le_trans(0n, 2n, VB.pw(d), {==}, h2), pf)) :
    {@P_rd0(0, n, _) == (DC.BF(t, n), OBJ(t, n)) : B.Buf & @P}
  %Equal.sym(B.Buf & U32, B.word(DC.BF(t, n), 1), (DC.BF(t, n), O1(t)), DC.rd32(d, t, n, 1, 1n, {==}, hd32, FD.nat__lt_le_trans(1n, 2n, VB.pw(d), {==}, h2), pf)) :
    {@P_rd1(0, n, O0(t), _) == (DC.BF(t, n), OBJ(t, n)) : B.Buf & @P}
  %Equal.sym(U32, O0(t), 8, e0) :
    {@P_rd2(0, n, _, O1(t), @C_bx_read(DC.BF(t, n), U32.add(0, _), U32.sub(O1(t), _))) == (DC.BF(t, n), OBJ(t, n)) : B.Buf & @P}
  %Equal.sym(B.Buf & @C, @C_read(DC.BF(t, n), U32.add(0, 8), L1(t)), (DC.BF(t, n), W.OBJw(t, 2n, L1(t))),
      W.readw(d, t, n, 2n, U32.add(0, 8), L1(t), {==}, hd, hw1(d, t, n, hn, h8, h1n), hw1s(t, n, h8, h1n), pf, hk1)) :
    {@P_rd2(0, n, 8, O1(t), @C_bx_rd(_)) == (DC.BF(t, n), OBJ(t, n)) : B.Buf & @P}
  %Equal.sym(B.Buf & @C, @C_read(DC.BF(t, n), U32.add(0, O1(t)), L2(t, n)), (DC.BF(t, n), W.OBJw(t, J(t), L2(t, n))),
      W.readw(d, t, n, J(t), U32.add(0, O1(t)), L2(t, n), ej, hd, hw2(d, t, n, hn, h1n, ej1), hw2s(t, n, h1n, ej1), pf, hk2)) :
    {@P_rd3(0, n, 8, O1(t), O.BSome{W.OBJw(t, 2n, L1(t)), O.BNone{}}, @C_bx_rd(_)) == (DC.BF(t, n), OBJ(t, n)) : B.Buf & @P}
  {==}

def acc_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHK(t, n) == True{} : Bool}, +e0: {O0(t) == 8 : U32},
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool},
    +hk1: {W.CHKw(t, 2n, L1(t)) == True{} : Bool}, +hk2: {W.CHKw(t, J(t), L2(t, n)) == True{} : Bool})
    -> {@P_decode(DC.BF(t, n), n) == (DC.BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @P>}:
  %Equal.sym(B.Buf & Bool, @P_ok(DC.BF(t, n), 0, n), (DC.BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {@P_built(n, _) == (DC.BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @P>}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {@P_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @P>}
  %Equal.sym(B.Buf & @P, @P_read(DC.BF(t, n), 0, n), (DC.BF(t, n), OBJ(t, n)), rd_go(d, t, n, pf, hd, hn, e0, h8, h1n, hk1, hk2)) :
    {@P_some(_) == (DC.BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @P>}
  {==}

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {@P_decode(DC.BF(t, n), n) == (DC.BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @P>}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(8, n)
  +b = U32.is_eq(O0(t), 8)
  +c = Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n))
  +dd = W.CHKw(t, 2n, L1(t))
  +e = W.CHKw(t, J(t), L2(t, n))
  +e0 = FD.u32alg__eq_of(O0(t), 8, c5b(a, b, c, dd, e, hchk))
  +ec = c5c(a, b, c, dd, e, hchk)
  +h01 = FD.logic__and_left(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n), ec)
  +h1n = le_nat(O1(t), n, FD.logic__and_right(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n), ec))
  +h8 = le_nat(8, O1(t), FD.logic__subst(U32, z => {U32.is_le(z, O1(t)) == True{} : Bool}, O0(t), 8, e0, h01))
  acc_go(d, t, n, pf, hd, hn, hchk, e0, h8, h1n, c5d(a, b, c, dd, e, hchk), c5e(a, b, c, dd, e, hchk))
# ---- the spec side ----------------------------------------------------------------------------

law wtl:
  for +m: Nat
  for +X: List<&2, U32>
  for +h: {Nat.is_le(m, VB.len(X)) == True{} : Bool}
  {List.length(&2, U32, VS.wtake(m, X)) == m : Nat}
def wtl(m, X, h):
  match m X:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({List.length(&2, U32, VS.wtake(1n+p, Nil{})) == 1n+p : Nat}, FD.logic__false_true(h))
    case 1n+ +p Con{+x, +r}:
      %wtl(p, r, h) : {1n+List.length(&2, U32, VS.wtake(p, r)) == 1n+_ : Nat}
      {==}

law wtl2:
  for +m: Nat
  for +i: Nat
  for +X: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(i, m), VB.len(X)) == True{} : Bool}
  {List.length(&2, U32, VS.wtake(m, VB.wdr(i, X))) == m : Nat}
def wtl2(m, i, X, h):
  match i X:
    case 0n _: wtl(m, X, h)
    case 1n+ +j Nil{}: Empty.absurd({List.length(&2, U32, VS.wtake(m, VB.wdr(1n+j, Nil{}))) == m : Nat}, FD.logic__false_true(h))
    case 1n+ +j Con{+x, +r}: wtl2(m, j, r, h)

# The bytes of m words from word i on: 4 m of them.
def lenY(+m: Nat, +i: Nat, +X: List<&2, U32>, +h: {Nat.is_le(Nat.add(i, m), VB.len(X)) == True{} : Bool})
    -> {List.length(&2, U32, F.limbs(VS.wtake(m, VB.wdr(i, X)))) == A.quad(m) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, F.limbs(VS.wtake(m, VB.wdr(i, X)))), F.wlen(VS.wtake(m, VB.wdr(i, X))), VS.len_limbs(VS.wtake(m, VB.wdr(i, X)))) : {_ == A.quad(m) : Nat}
  %Equal.sym(Nat, F.wlen(VS.wtake(m, VB.wdr(i, X))), A.quad(List.length(&2, U32, VS.wtake(m, VB.wdr(i, X)))), VS.wlen_quad(VS.wtake(m, VB.wdr(i, X)))) : {_ == A.quad(m) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, VS.wtake(m, VB.wdr(i, X))), m, wtl2(m, i, X, h)) : {A.quad(_) == A.quad(m) : Nat}
  {==}

law len_eq:
  for +X: List<&2, U32>
  {List.length(&2, U32, X) == FD.spec_common__length(U32, X) : Nat}
def len_eq(X):
  match X:
    case Nil{}: {==}
    case Con{+h, +r}:
      %Equal.sym(Nat, List.length(&2, U32, r), FD.spec_common__length(U32, r), len_eq(r)) : {1n+_ == 1n+FD.spec_common__length(U32, r) : Nat}
      {==}

# A window of length len holds H + NW words.
def eL(+d: Nat, +len: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +ha: {U32.is_le(@FS, len) == True{} : Bool},
    +hl: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {DC.whole(DC.LL(len)) == True{} : Bool})
    -> {U32.to_nat(len) == A.quad(Nat.add(@Hn, VC.NW(DC.LL(len)))) : Nat}:
  %Equal.sym(Nat, VC.NW(DC.LL(len)), Nat.double(DC.CQ(len)), DC.eNWc(d, len, hd, ha, hl, hc)) : {U32.to_nat(len) == A.quad(Nat.add(@Hn, _)) : Nat}
  %DC.enFS(len, ha) : {_ == A.quad(Nat.add(@Hn, Nat.double(DC.CQ(len)))) : Nat}
  %Equal.sym(Nat, U32.to_nat(DC.LL(len)), VS.x8(DC.CQ(len)), DC.eLc(len, hc)) : {Nat.add(@FSn, _) == A.quad(Nat.add(@Hn, Nat.double(DC.CQ(len)))) : Nat}
  %Equal.sym(Nat, VS.x8(DC.CQ(len)), VB.d3(DC.CQ(len)), VB.x8_d3(DC.CQ(len))) : {Nat.add(@FSn, _) == A.quad(Nat.add(@Hn, Nat.double(DC.CQ(len)))) : Nat}
  {==}

def X1(+t: FD.array__Tree<U32>) -> Nat: Nat.add(@Hn, VC.NW(DC.LL(L1(t))))
def X2(+t: FD.array__Tree<U32>, +n: U32) -> Nat: Nat.add(@Hn, VC.NW(DC.LL(L2(t, n))))
def SS(+t: FD.array__Tree<U32>) -> List<&2, U32>: FD.array__slots(U32, t)
def Y1(+t: FD.array__Tree<U32>) -> +List<U32>: F.limbs(VS.wtake(X1(t), VB.wdr(2n, SS(t))))
def Y2(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: F.limbs(VS.wtake(X2(t, n), VB.wdr(J(t), SS(t))))
def PL(+t: FD.array__Tree<U32>, +n: U32) -> +List<S.Part>: [S.Variable{Y1(t)}, S.Variable{Y2(t, n)}]
def OUTL(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts(PL(t, n), Layout.fixed_size(PL(t, n))), Layout.payloads(PL(t, n)))

def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(SS(t)))
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value:
  S.Sequence{S.Items{W.VALw(t, 2n, L1(t)), S.Items{W.VALw(t, J(t), L2(t, n)), S.EmptyItems{}}}}

def lenVW(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, VW(t, n)) == U32.to_nat(n) : Nat}:
  +S = FD.array__slots(U32, t)
  +lS = Equal.trans(Nat, List.length(&2, U32, F.limbs(S)), F.wlen(S), A.quad(VB.pw(d)), VS.len_limbs(S),
    Equal.trans(Nat, F.wlen(S), A.quad(List.length(&2, U32, S)), A.quad(VB.pw(d)), VS.wlen_quad(S),
      Equal.cong(Nat, Nat, z => A.quad(z), List.length(&2, U32, S), VB.pw(d), Equal.trans(Nat, List.length(&2, U32, S), FD.spec_common__length(U32, S), VB.pw(d), len_eq(S), FD.array__slots_length(U32, d, t, pf)))))
  VS.bt_len(U32.to_nat(n), F.limbs(S),
    FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(n), z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, F.limbs(S)), Equal.sym(Nat, List.length(&2, U32, F.limbs(S)), A.quad(VB.pw(d)), lS), hn))

# The layout of the two windows is the buffer's bytes.
def main_eq(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e0: {O0(t) == 8 : U32},
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool},
    +hk1: {W.CHKw(t, 2n, L1(t)) == True{} : Bool}, +hk2: {W.CHKw(t, J(t), L2(t, n)) == True{} : Bool})
    -> {OUTL(t, n) == VW(t, n) : +List<U32>}:
  +ej = eJ(d, t, n, hd, hn, h8, h1n, wha(t, 2n, L1(t), hk1), whc(t, 2n, L1(t), hk1))
  +hl2 = W.hlen(d, J(t), L2(t, n), hw2(d, t, n, hn, h1n, ej))
  +e2 = eL(d, L2(t, n), hd, wha(t, J(t), L2(t, n), hk2), hl2, whc(t, J(t), L2(t, n), hk2))
  +l2 = FD.u32__sub_nat(n, O1(t), h1n)
  +sa = FD.nat__sub_add(U32.to_nat(n), U32.to_nat(O1(t)), h1n)
  # n = 4 (J + X2)
  +en = Equal.trans(Nat, U32.to_nat(n), Nat.add(U32.to_nat(O1(t)), U32.to_nat(L2(t, n))), A.quad(Nat.add(J(t), X2(t, n))),
    Equal.trans(Nat, U32.to_nat(n), Nat.add(U32.to_nat(O1(t)), Nat.sub(U32.to_nat(n), U32.to_nat(O1(t)))), Nat.add(U32.to_nat(O1(t)), U32.to_nat(L2(t, n))),
      Equal.sym(Nat, Nat.add(U32.to_nat(O1(t)), Nat.sub(U32.to_nat(n), U32.to_nat(O1(t)))), U32.to_nat(n), sa),
      Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(O1(t)), z), Nat.sub(U32.to_nat(n), U32.to_nat(O1(t))), U32.to_nat(L2(t, n)), Equal.sym(Nat, U32.to_nat(L2(t, n)), Nat.sub(U32.to_nat(n), U32.to_nat(O1(t))), l2))),
    Equal.trans(Nat, Nat.add(U32.to_nat(O1(t)), U32.to_nat(L2(t, n))), Nat.add(A.quad(J(t)), A.quad(X2(t, n))), A.quad(Nat.add(J(t), X2(t, n))),
      Equal.trans(Nat, Nat.add(U32.to_nat(O1(t)), U32.to_nat(L2(t, n))), Nat.add(A.quad(J(t)), U32.to_nat(L2(t, n))), Nat.add(A.quad(J(t)), A.quad(X2(t, n))),
        Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(L2(t, n))), U32.to_nat(O1(t)), A.quad(J(t)), ej),
        Equal.cong(Nat, Nat, z => Nat.add(A.quad(J(t)), z), U32.to_nat(L2(t, n)), A.quad(X2(t, n)), e2)),
      VF.quad_add(J(t), X2(t, n))))
  +hM = VC.quad_inv(Nat.add(J(t), X2(t, n)), VB.pw(d), FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), A.quad(Nat.add(J(t), X2(t, n))), en, hn))
  +hMs = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(J(t), X2(t, n)), z) == True{} : Bool}, VB.pw(d), VB.len(SS(t)), Equal.sym(Nat, VB.len(SS(t)), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hM)
  +hJ = FD.nat__le_trans(J(t), Nat.add(J(t), X2(t, n)), VB.len(SS(t)), FD.nat__le_add_right(J(t), X2(t, n)), hMs)
  +hpre = FD.nat__le_trans(2n, J(t), VB.len(SS(t)), Order.below_sum(2n, X1(t)), hJ)
  %Equal.sym(Nat, U32.to_nat(n), A.quad(Nat.add(J(t), X2(t, n))), en) : {OUTL(t, n) == VS.bt(_, F.limbs(SS(t))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(Nat.add(J(t), X2(t, n))), F.limbs(SS(t))), F.limbs(VS.wtake(Nat.add(J(t), X2(t, n)), SS(t))), VS.bt_limbs(Nat.add(J(t), X2(t, n)), SS(t))) :
    {OUTL(t, n) == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(2n, Nat.add(X1(t), X2(t, n))), VB.wdr(0n, SS(t))), VF.app(VF.wpre(2n, 0n, SS(t)), VS.wtake(Nat.add(X1(t), X2(t, n)), VB.wdr(Nat.add(2n, 0n), SS(t)))),
      VF.wt_pre(2n, Nat.add(X1(t), X2(t, n)), 0n, SS(t), hpre)) :
    {OUTL(t, n) == F.limbs(_) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(X1(t), X2(t, n)), VB.wdr(2n, SS(t))), VF.app(VS.wtake(X1(t), VB.wdr(2n, SS(t))), VS.wtake(X2(t, n), VB.wdr(X1(t), VB.wdr(2n, SS(t))))),
      VF.take_split(X1(t), X2(t, n), VB.wdr(2n, SS(t)))) :
    {OUTL(t, n) == F.limbs(VF.app(VF.wpre(2n, 0n, SS(t)), _)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(X1(t), VB.wdr(2n, SS(t))), VB.wdr(Nat.add(2n, X1(t)), SS(t)), VF.wdr_add(X1(t), 2n, SS(t))) :
    {OUTL(t, n) == F.limbs(VF.app(VF.wpre(2n, 0n, SS(t)), VF.app(VS.wtake(X1(t), VB.wdr(2n, SS(t))), VS.wtake(X2(t, n), _)))) : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(VF.app(VS.wtake(X1(t), VB.wdr(2n, SS(t))), VS.wtake(X2(t, n), VB.wdr(J(t), SS(t))))), List.append(&2, U32, Y1(t), Y2(t, n)),
      VF.limbs_app(VS.wtake(X1(t), VB.wdr(2n, SS(t))), VS.wtake(X2(t, n), VB.wdr(J(t), SS(t))))) :
    {OUTL(t, n) == List.append(&2, U32, F.limbs([VB.slot(t, 0n), VB.slot(t, 1n)]), _) : +List<U32>}
  %Equal.sym(U32, O0(t), 8, e0) :
    {OUTL(t, n) == List.append(&2, U32, F.limbs([_, VB.slot(t, 1n)]), List.append(&2, U32, Y1(t), Y2(t, n))) : +List<U32>}
  %Equal.sym(Nat, List.length(&2, U32, Y1(t)), A.quad(X1(t)), lenY(X1(t), 2n, SS(t), hJ)) :
    {List.append(&2, U32, [8, 0, 0, 0], List.append(&2, U32, N.digits(4n, Nat.add(8n, _)), List.append(&2, U32, Y1(t), List.append(&2, U32, Y2(t, n), []))))
      == List.append(&2, U32, F.limbs([8, VB.slot(t, 1n)]), List.append(&2, U32, Y1(t), Y2(t, n))) : +List<U32>}
  %ej :
    {List.append(&2, U32, [8, 0, 0, 0], List.append(&2, U32, N.digits(4n, _), List.append(&2, U32, Y1(t), List.append(&2, U32, Y2(t, n), []))))
      == List.append(&2, U32, F.limbs([8, VB.slot(t, 1n)]), List.append(&2, U32, Y1(t), Y2(t, n))) : +List<U32>}
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(O1(t))), I.limb(O1(t)), VG.digits_limb(O1(t))) :
    {List.append(&2, U32, [8, 0, 0, 0], List.append(&2, U32, _, List.append(&2, U32, Y1(t), List.append(&2, U32, Y2(t, n), []))))
      == List.append(&2, U32, F.limbs([8, VB.slot(t, 1n)]), List.append(&2, U32, Y1(t), Y2(t, n))) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y2(t, n), []), Y2(t, n), VS.app_nil(Y2(t, n))) :
    {List.append(&2, U32, [8, 0, 0, 0], List.append(&2, U32, I.limb(O1(t)), List.append(&2, U32, Y1(t), _)))
      == List.append(&2, U32, F.limbs([8, VB.slot(t, 1n)]), List.append(&2, U32, Y1(t), Y2(t, n))) : +List<U32>}
  {==}

def fitsO(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +me: {OUTL(t, n) == VW(t, n) : +List<U32>})
    -> {N.fits(4n, Nat.add(Layout.fixed_size(PL(t, n)), List.length(&2, U32, Layout.payloads(PL(t, n))))) == True{} : Bool}:
  %Equal.sym(+List<U32>, OUTL(t, n), VW(t, n), me) : {N.fits(4n, List.length(&2, U32, _)) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, VW(t, n)), U32.to_nat(n), lenVW(d, t, n, pf, hn)) : {N.fits(4n, _) == True{} : Bool}
  VFT.fits4lt(U32.to_nat(n), VB.u32_lt(n))

def spec_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e0: {O0(t) == 8 : U32},
    +h8: {Nat.is_le(8n, U32.to_nat(O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t)), U32.to_nat(n)) == True{} : Bool},
    +hk1: {W.CHKw(t, 2n, L1(t)) == True{} : Bool}, +hk2: {W.CHKw(t, J(t), L2(t, n)) == True{} : Bool})
    -> Decoding.decodes(Spec.@N(), VW(t, n), VAL(t, n)):
  +ej1 = eJ(d, t, n, hd, hn, h8, h1n, wha(t, 2n, L1(t), hk1), whc(t, 2n, L1(t), hk1))
  +me = main_eq(d, t, n, pf, hd, hn, e0, h8, h1n, hk1, hk2)
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(W.VALw(t, 2n, L1(t)), Spec.@C()), Some{[S.Variable{Y1(t)}]}, W.specw(d, t, n, 2n, L1(t), pf, hd, hw1(d, t, n, hn, h8, h1n), hk1)) :
    {Codec.bytes(Codec.aggregate(Codec.concatenate(_, Codec.concatenate(Codec.parts(W.VALw(t, J(t), L2(t, n)), Spec.@C()), Some{[]})), None{})) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(W.VALw(t, J(t), L2(t, n)), Spec.@C()), Some{[S.Variable{Y2(t, n)}]}, W.specw(d, t, n, J(t), L2(t, n), pf, hd, hw2(d, t, n, hn, h1n, ej1), hk2)) :
    {Codec.bytes(Codec.aggregate(Codec.concatenate(Some{[S.Variable{Y1(t)}]}, Codec.concatenate(_, Some{[]})), None{})) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Layout.bytes_valid(PL(t, n)), True{},
      FD.logic__and_intro(SP.bytes_domain(Y1(t)), Layout.bytes_valid([S.Variable{Y2(t, n)}]), F.domain_limbs(VS.wtake(X1(t), VB.wdr(2n, SS(t)))),
        FD.logic__and_intro(SP.bytes_domain(Y2(t, n)), True{}, F.domain_limbs(VS.wtake(X2(t, n), VB.wdr(J(t), SS(t)))), {==}))) :
    {Codec.bytes(Codec.one(SP.optional(Bool.and(_, N.fits(4n, Nat.add(Layout.fixed_size(PL(t, n)), List.length(&2, U32, Layout.payloads(PL(t, n)))))), OUTL(t, n)), None{})) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(Layout.fixed_size(PL(t, n)), List.length(&2, U32, Layout.payloads(PL(t, n))))), True{}, fitsO(d, t, n, pf, hd, hn, me)) :
    {Codec.bytes(Codec.one(SP.optional(Bool.and(True{}, _), OUTL(t, n)), None{})) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, OUTL(t, n), VW(t, n), me) :
    {Codec.bytes(Codec.one(SP.optional(Bool.and(True{}, True{}), _), None{})) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  {==}

# The bytes of every buffer the validator accepts are the spec encoding of the
# decoded object's value.
law decode_spec:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(Spec.@N(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(8, n)
  +b = U32.is_eq(O0(t), 8)
  +c = Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n))
  +dd = W.CHKw(t, 2n, L1(t))
  +e = W.CHKw(t, J(t), L2(t, n))
  +e0 = FD.u32alg__eq_of(O0(t), 8, c5b(a, b, c, dd, e, hchk))
  +ec = c5c(a, b, c, dd, e, hchk)
  +h01 = FD.logic__and_left(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n), ec)
  +h1n = le_nat(O1(t), n, FD.logic__and_right(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n), ec))
  +h8 = le_nat(8, O1(t), FD.logic__subst(U32, z => {U32.is_le(z, O1(t)) == True{} : Bool}, O0(t), 8, e0, h01))
  spec_go(d, t, n, pf, hd, hn, e0, h8, h1n, c5d(a, b, c, dd, e, hchk), c5e(a, b, c, dd, e, hchk))
# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == False{} : Bool}
  {@P_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @P>}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, @P_ok(DC.BF(t, n), 0, n), (DC.BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {@P_built(n, _) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @P>}
  %Equal.sym(Bool, CHK(t, n), False{}, hchk) :
    {@P_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @P>}
  {==}

@@ AS_REJ @@

def OUT2(+y1: +List<U32>, +y2: +List<U32>) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts([S.Variable{y1}, S.Variable{y2}], Layout.fixed_size([S.Variable{y1}, S.Variable{y2}])), Layout.payloads([S.Variable{y1}, S.Variable{y2}]))

# A window whose bytes have the child's shape passes the child's checks.
def chk_truew(+t: FD.array__Tree<U32>, +i: Nat, +len: U32, +k: Nat, +en: {U32.to_nat(len) == @FSn+VS.x8(k) : Nat}, +hk: {Nat.is_le(k, @LIMN) == True{} : Bool},
    +epo: {W.SPOw(t, i) == @FS : U32}) -> {W.CHKw(t, i, len) == True{} : Bool}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, @FSn+VS.x8(k), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), @FSn+VS.x8(k), en), Order.below_sum(@FSn, VS.x8(k)))
  %Equal.sym(Bool, U32.is_le(@FS, len), True{}, u32le(@FS, len, le)) :
    {DC.chk3(_, U32.is_eq(W.SPOw(t, i), @FS), DC.whole(U32.sub(len, W.SPOw(t, i)))) == True{} : Bool}
  %Equal.sym(U32, W.SPOw(t, i), @FS, epo) :
    {DC.chk3(True{}, U32.is_eq(_, @FS), DC.whole(U32.sub(len, _))) == True{} : Bool}
  VU.whole_i(DC.LL(len), 8, @LIM, DC.v8(), {==}, {==}, {==}, k, R.ec_sub(len, k, en), hk)

def fitsn(+d: Nat, +n: U32, +x: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +hx: {Nat.is_le(x, U32.to_nat(n)) == True{} : Bool}) -> {N.fits(4n, x) == True{} : Bool}:
  VFT.fits4lt(x, VB.le_n_lt32(x, n, hx))

def hb0(+t: FD.array__Tree<U32>, +n: U32, +y1: +List<U32>, +y2: +List<U32>, +eo: {OUT2(y1, y2) == M.VW(t, n) : +List<U32>})
    -> {VS.bt(4n, VS.bdr(0n, M.VW(t, n))) == [8, 0, 0, 0] : +List<U32>}:
  %eo : {VS.bt(4n, VS.bdr(0n, _)) == [8, 0, 0, 0] : +List<U32>}
  {==}

def hd1(+t: FD.array__Tree<U32>, +n: U32, +y1: +List<U32>, +y2: +List<U32>, +eo: {OUT2(y1, y2) == M.VW(t, n) : +List<U32>})
    -> {VS.bt(4n, VS.bdr(4n, M.VW(t, n))) == N.digits(4n, Nat.add(8n, List.length(&2, U32, y1))) : +List<U32>}:
  %eo : {VS.bt(4n, VS.bdr(4n, _)) == N.digits(4n, Nat.add(8n, List.length(&2, U32, y1))) : +List<U32>}
  {==}

def hw1b(+t: FD.array__Tree<U32>, +n: U32, +y1: +List<U32>, +y2: +List<U32>, +eo: {OUT2(y1, y2) == M.VW(t, n) : +List<U32>},
    +h: {Nat.is_le(Nat.add(@Pn, 4n), List.length(&2, U32, y1)) == True{} : Bool}, +hb: {VS.bt(4n, VS.bdr(@Pn, y1)) == @FSL : +List<U32>})
    -> {VS.bt(4n, VS.bdr(A.quad(Nat.add(@POn, 2n)), M.VW(t, n))) == @FSL : +List<U32>}:
  %eo : {VS.bt(4n, VS.bdr(A.quad(Nat.add(@POn, 2n)), _)) == @FSL : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, List.append(&2, U32, y1, List.append(&2, U32, y2, [])))), VS.bt(4n, VS.bdr(@Pn, y1)), VN.btbdr_app(@Pn, y1, List.append(&2, U32, y2, []), h)) :
    {_ == @FSL : +List<U32>}
  hb

def hw2b(+t: FD.array__Tree<U32>, +n: U32, +y1: +List<U32>, +y2: +List<U32>, +eo: {OUT2(y1, y2) == M.VW(t, n) : +List<U32>},
    +eq2: {A.quad(Nat.add(@POn, M.J(t))) == Nat.add(8n, Nat.add(List.length(&2, U32, y1), @Pn)) : Nat},
    +h: {Nat.is_le(Nat.add(@Pn, 4n), List.length(&2, U32, y2)) == True{} : Bool}, +hb: {VS.bt(4n, VS.bdr(@Pn, y2)) == @FSL : +List<U32>})
    -> {VS.bt(4n, VS.bdr(A.quad(Nat.add(@POn, M.J(t))), M.VW(t, n))) == @FSL : +List<U32>}:
  +Z = List.append(&2, U32, y1, List.append(&2, U32, y2, []))
  %Equal.sym(Nat, A.quad(Nat.add(@POn, M.J(t))), Nat.add(8n, Nat.add(List.length(&2, U32, y1), @Pn)), eq2) : {VS.bt(4n, VS.bdr(_, M.VW(t, n))) == @FSL : +List<U32>}
  %eo : {VS.bt(4n, VS.bdr(Nat.add(8n, Nat.add(List.length(&2, U32, y1), @Pn)), _)) == @FSL : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(List.length(&2, U32, y1), @Pn), Z), VS.bdr(@Pn, VS.bdr(List.length(&2, U32, y1), Z)), VN.bdr_add(List.length(&2, U32, y1), @Pn, Z)) :
    {VS.bt(4n, _) == @FSL : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(List.length(&2, U32, y1), Z), List.append(&2, U32, y2, []), VS.bdr_app(y1, List.append(&2, U32, y2, []))) :
    {VS.bt(4n, VS.bdr(@Pn, _)) == @FSL : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, List.append(&2, U32, y2, []))), VS.bt(4n, VS.bdr(@Pn, y2)), VN.btbdr_app(@Pn, y2, [], h)) :
    {_ == @FSL : +List<U32>}
  hb

def chk_all(+t: FD.array__Tree<U32>, +n: U32, +e0: {M.O0(t) == 8 : U32},
    +h8: {Nat.is_le(8n, U32.to_nat(M.O1(t))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(M.O1(t)), U32.to_nat(n)) == True{} : Bool},
    +hk1: {W.CHKw(t, 2n, M.L1(t)) == True{} : Bool}, +hk2: {W.CHKw(t, M.J(t), M.L2(t, n)) == True{} : Bool})
    -> {M.CHK(t, n) == True{} : Bool}:
  %Equal.sym(U32, M.O0(t), 8, e0) :
    {M.chk5(U32.is_le(8, n), U32.is_eq(_, 8), Bool.and(U32.is_le(_, M.O1(t)), U32.is_le(M.O1(t), n)), W.CHKw(t, 2n, M.L1(t)), W.CHKw(t, M.J(t), M.L2(t, n))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(8, n), True{}, u32le(8, n, FD.nat__le_trans(8n, U32.to_nat(M.O1(t)), U32.to_nat(n), h8, h1n))) :
    {M.chk5(_, True{}, Bool.and(U32.is_le(8, M.O1(t)), U32.is_le(M.O1(t), n)), W.CHKw(t, 2n, M.L1(t)), W.CHKw(t, M.J(t), M.L2(t, n))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(8, M.O1(t)), True{}, u32le(8, M.O1(t), h8)) :
    {M.chk5(True{}, True{}, Bool.and(_, U32.is_le(M.O1(t), n)), W.CHKw(t, 2n, M.L1(t)), W.CHKw(t, M.J(t), M.L2(t, n))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(M.O1(t), n), True{}, u32le(M.O1(t), n, h1n)) :
    {M.chk5(True{}, True{}, Bool.and(True{}, _), W.CHKw(t, 2n, M.L1(t)), W.CHKw(t, M.J(t), M.L2(t, n))) == True{} : Bool}
  %Equal.sym(Bool, W.CHKw(t, 2n, M.L1(t)), True{}, hk1) :
    {M.chk5(True{}, True{}, True{}, _, W.CHKw(t, M.J(t), M.L2(t, n))) == True{} : Bool}
  hk2

def en_lo(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +y1: +List<U32>, +y2: +List<U32>, +eo: {OUT2(y1, y2) == M.VW(t, n) : +List<U32>})
    -> {U32.to_nat(n) == Nat.add(8n, Nat.add(List.length(&2, U32, y1), List.length(&2, U32, y2))) : Nat}:
  %M.lenVW(d, t, n, pf, hn) : {_ == Nat.add(8n, Nat.add(List.length(&2, U32, y1), List.length(&2, U32, y2))) : Nat}
  %eo : {List.length(&2, U32, _) == Nat.add(8n, Nat.add(List.length(&2, U32, y1), List.length(&2, U32, y2))) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, y1, List.append(&2, U32, y2, []))), Nat.add(List.length(&2, U32, y1), List.length(&2, U32, List.append(&2, U32, y2, []))), VS.len_app(y1, List.append(&2, U32, y2, []))) : {Nat.add(8n, _) == Nat.add(8n, Nat.add(List.length(&2, U32, y1), List.length(&2, U32, y2))) : Nat}
  %Equal.sym(+List<U32>, List.append(&2, U32, y2, []), y2, VS.app_nil(y2)) : {Nat.add(8n, Nat.add(List.length(&2, U32, y1), List.length(&2, U32, _))) == Nat.add(8n, Nat.add(List.length(&2, U32, y1), List.length(&2, U32, y2))) : Nat}
  {==}

def eqJ(+t: FD.array__Tree<U32>, +ly1: Nat, +ej: {U32.to_nat(M.O1(t)) == A.quad(M.J(t)) : Nat}, +e1: {U32.to_nat(M.O1(t)) == Nat.add(8n, ly1) : Nat})
    -> {A.quad(Nat.add(@POn, M.J(t))) == Nat.add(8n, Nat.add(ly1, @Pn)) : Nat}:
  %VF.quad_add(@POn, M.J(t)) : {_ == Nat.add(8n, Nat.add(ly1, @Pn)) : Nat}
  %ej : {Nat.add(@Pn, _) == Nat.add(8n, Nat.add(ly1, @Pn)) : Nat}
  %Equal.sym(Nat, U32.to_nat(M.O1(t)), Nat.add(8n, ly1), e1) : {Nat.add(@Pn, _) == Nat.add(8n, Nat.add(ly1, @Pn)) : Nat}
  %FD.nat__add_comm(Nat.add(8n, ly1), @Pn) : {_ == Nat.add(8n, Nat.add(ly1, @Pn)) : Nat}
  FD.nat__add_assoc(8n, ly1, @Pn)

def le_w2(+ly1: Nat, +ly2: Nat, +h: {Nat.is_le(Nat.add(@Pn, 4n), ly2) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(8n, Nat.add(ly1, @Pn)), 4n), Nat.add(8n, Nat.add(ly1, ly2))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(Nat.add(ly1, @Pn), 4n), Nat.add(ly1, Nat.add(@Pn, 4n)), FD.nat__add_assoc(ly1, @Pn, 4n)) : {Nat.is_le(_, Nat.add(ly1, ly2)) == True{} : Bool}
  Order.add_left(ly1, Nat.add(@Pn, 4n), ly2, h)

# The two windows' shapes make every check pass.
def contra(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {M.CHK(t, n) == False{} : Bool},
    +y1: +List<U32>, +y2: +List<U32>, f1: R.FACTS(y1), f2: R.FACTS(y2), +eo: {OUT2(y1, y2) == M.VW(t, n) : +List<U32>}) -> Empty:
  (+hb1, ex1) = f1
  (+k1, +pr1) = ex1
  (+hl1, +hk1) = pr1
  (+hb2, ex2) = f2
  (+k2, +pr2) = ex2
  (+hl2, +hk2) = pr2
  +ly1 = List.length(&2, U32, y1)
  +ly2 = List.length(&2, U32, y2)
  +en = en_lo(d, t, n, pf, hn, y1, y2, eo)
  +le8y1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(8n, ly1), z) == True{} : Bool}, Nat.add(8n, Nat.add(ly1, ly2)), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(8n, Nat.add(ly1, ly2)), en),
    Order.add_left(8n, ly1, Nat.add(ly1, ly2), FD.nat__le_add_right(ly1, ly2)))
  +hy1 = FD.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, @FSn+VS.x8(k1), ly1, Equal.sym(Nat, ly1, @FSn+VS.x8(k1), hl1), Order.below_sum(@FSn, VS.x8(k1)))
  +hy2 = FD.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, @FSn+VS.x8(k2), ly2, Equal.sym(Nat, ly2, @FSn+VS.x8(k2), hl2), Order.below_sum(@FSn, VS.x8(k2)))
  +hP1 = FD.nat__le_trans(Nat.add(@Pn, 4n), @FSn, ly1, {==}, hy1)
  +hP2 = FD.nat__le_trans(Nat.add(@Pn, 4n), @FSn, ly2, {==}, hy2)
  # word 0 is 8
  +b0 = VN.byteK2(d, t, n, 0n, pf, hn, FD.nat__le_trans(4n, Nat.add(8n, ly1), U32.to_nat(n), {==}, le8y1))
  +e0 = VN.wordc(M.O0(t), 8, Equal.trans(+List<U32>, F.limbs([M.O0(t)]), VS.bt(4n, VS.bdr(0n, M.VW(t, n))), [8, 0, 0, 0],
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(0n, M.VW(t, n))), F.limbs([M.O0(t)]), b0), hb0(t, n, y1, y2, eo)))
  # word 1 is 8 + |y1|
  +b1 = VN.byteK2(d, t, n, 1n, pf, hn, FD.nat__le_trans(8n, Nat.add(8n, ly1), U32.to_nat(n), Order.below_sum(8n, ly1), le8y1))
  +d1 = Equal.trans(+List<U32>, F.limbs([M.O1(t)]), VS.bt(4n, VS.bdr(4n, M.VW(t, n))), N.digits(4n, Nat.add(8n, ly1)),
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(4n, M.VW(t, n))), F.limbs([M.O1(t)]), b1), hd1(t, n, y1, y2, eo))
  +e1 = VG.digits_word(M.O1(t), Nat.add(8n, ly1), fitsn(d, n, Nat.add(8n, ly1), hd, hn, le8y1), d1)
  +h8 = FD.logic__subst(Nat, z => {Nat.is_le(8n, z) == True{} : Bool}, Nat.add(8n, ly1), U32.to_nat(M.O1(t)), Equal.sym(Nat, U32.to_nat(M.O1(t)), Nat.add(8n, ly1), e1), Order.below_sum(8n, ly1))
  +h1n = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(n)) == True{} : Bool}, Nat.add(8n, ly1), U32.to_nat(M.O1(t)), Equal.sym(Nat, U32.to_nat(M.O1(t)), Nat.add(8n, ly1), e1), le8y1)
  # window 1: [8, 8 + |y1|)
  +eL1 = Equal.trans(Nat, U32.to_nat(M.L1(t)), Nat.sub(U32.to_nat(M.O1(t)), 8n), ly1, FD.u32__sub_nat(M.O1(t), 8, h8),
    Equal.trans(Nat, Nat.sub(U32.to_nat(M.O1(t)), 8n), Nat.sub(Nat.add(8n, ly1), 8n), ly1, Equal.cong(Nat, Nat, z => Nat.sub(z, 8n), U32.to_nat(M.O1(t)), Nat.add(8n, ly1), e1), FD.nat__add_sub_cancel(8n, ly1)))
  +bw1 = VN.byteK2(d, t, n, Nat.add(@POn, 2n), pf, hn, FD.nat__le_trans(Nat.add(A.quad(Nat.add(@POn, 2n)), 4n), Nat.add(8n, ly1), U32.to_nat(n),
    Order.add_left(8n, Nat.add(@Pn, 4n), ly1, hP1), le8y1))
  +epo1 = R.wordFS(W.SPOw(t, 2n), Equal.trans(+List<U32>, F.limbs([W.SPOw(t, 2n)]), VS.bt(4n, VS.bdr(A.quad(Nat.add(@POn, 2n)), M.VW(t, n))), @FSL,
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(A.quad(Nat.add(@POn, 2n)), M.VW(t, n))), F.limbs([W.SPOw(t, 2n)]), bw1), hw1b(t, n, y1, y2, eo, hP1, hb1)))
  +hk1c = chk_truew(t, 2n, M.L1(t), k1, Equal.trans(Nat, U32.to_nat(M.L1(t)), ly1, @FSn+VS.x8(k1), eL1, hl1), hk1, epo1)
  # window 2: [8 + |y1|, n)
  +ej = M.eJ(d, t, n, hd, hn, h8, h1n, M.wha(t, 2n, M.L1(t), hk1c), M.whc(t, 2n, M.L1(t), hk1c))
  +eL2 = Equal.trans(Nat, U32.to_nat(M.L2(t, n)), Nat.sub(U32.to_nat(n), U32.to_nat(M.O1(t))), ly2, FD.u32__sub_nat(n, M.O1(t), h1n),
    Equal.trans(Nat, Nat.sub(U32.to_nat(n), U32.to_nat(M.O1(t))), Nat.sub(Nat.add(Nat.add(8n, ly1), ly2), Nat.add(8n, ly1)), ly2,
      Equal.trans(Nat, Nat.sub(U32.to_nat(n), U32.to_nat(M.O1(t))), Nat.sub(U32.to_nat(n), Nat.add(8n, ly1)), Nat.sub(Nat.add(Nat.add(8n, ly1), ly2), Nat.add(8n, ly1)),
        Equal.cong(Nat, Nat, z => Nat.sub(U32.to_nat(n), z), U32.to_nat(M.O1(t)), Nat.add(8n, ly1), e1),
        Equal.cong(Nat, Nat, z => Nat.sub(z, Nat.add(8n, ly1)), U32.to_nat(n), Nat.add(Nat.add(8n, ly1), ly2),
          Equal.trans(Nat, U32.to_nat(n), Nat.add(8n, Nat.add(ly1, ly2)), Nat.add(Nat.add(8n, ly1), ly2), en, Equal.sym(Nat, Nat.add(Nat.add(8n, ly1), ly2), Nat.add(8n, Nat.add(ly1, ly2)), FD.nat__add_assoc(8n, ly1, ly2))))),
      FD.nat__add_sub_cancel(Nat.add(8n, ly1), ly2)))
  +eq2 = eqJ(t, ly1, ej, e1)
  +hq2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 4n), U32.to_nat(n)) == True{} : Bool}, Nat.add(8n, Nat.add(ly1, @Pn)), A.quad(Nat.add(@POn, M.J(t))),
    Equal.sym(Nat, A.quad(Nat.add(@POn, M.J(t))), Nat.add(8n, Nat.add(ly1, @Pn)), eq2),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(8n, Nat.add(ly1, @Pn)), 4n), z) == True{} : Bool}, Nat.add(8n, Nat.add(ly1, ly2)), U32.to_nat(n),
      Equal.sym(Nat, U32.to_nat(n), Nat.add(8n, Nat.add(ly1, ly2)), en), le_w2(ly1, ly2, hP2)))
  +bw2 = VN.byteK2(d, t, n, Nat.add(@POn, M.J(t)), pf, hn, hq2)
  +epo2 = R.wordFS(W.SPOw(t, M.J(t)), Equal.trans(+List<U32>, F.limbs([W.SPOw(t, M.J(t))]), VS.bt(4n, VS.bdr(A.quad(Nat.add(@POn, M.J(t))), M.VW(t, n))), @FSL,
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(A.quad(Nat.add(@POn, M.J(t))), M.VW(t, n))), F.limbs([W.SPOw(t, M.J(t))]), bw2), hw2b(t, n, y1, y2, eo, eq2, hP2, hb2)))
  +hk2c = chk_truew(t, M.J(t), M.L2(t, n), k2, Equal.trans(Nat, U32.to_nat(M.L2(t, n)), ly2, @FSn+VS.x8(k2), eL2, hl2), hk2, epo2)
  FD.logic__true_false(Equal.trans(Bool, True{}, M.CHK(t, n), False{}, Equal.sym(Bool, M.CHK(t, n), True{}, chk_all(t, n, e0, h8, h1n, hk1c, hk2c)), hchk))

@@ as_rej_text @@

def fin(${CTX}, +y1: +List<U32>, f1: R.FACTS(y1), +y2: +List<U32>, f2: R.FACTS(y2), +b5: Bool,
    +e: {Codec.bytes(Codec.one(SP.optional(b5, OUT2(y1, y2)), None{})) == Some{${VWt}} : ${MB}}) -> Empty:
  match b5:
    case False{}: ${absurd()}
    case True{}: contra(${CA}, y1, y2, f1, f2, FD.logic__some_inj(+List<U32>, OUT2(y1, y2), ${VWt}, e))

@@ as_rej_text_decode_reject @@

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {M.CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.${parent}(), ${VWt})
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => inv_v(${CA}, v, e)
