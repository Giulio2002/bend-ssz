@@ CF @@
DK.P2({VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)) == CWr(Nat.add(VS.x8(j), b)) : Nat}, DK.P2({Nat.is_le(VD.s_rng(3n, Nat.add(b, 7n)), 1n) == True{} : Bool}, DK.P2({VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b))) == 0n : Nat}, DK.P2({VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n)) == 1n : Nat}, DK.P2({Nat.is_le(Nat.add(VS.x8(j), b), 31n) == True{} : Bool}, {Bp.byte_count(1n+Nat.add(VS.x8(j), b)) == Nat.add(j, 1n) : Nat})))))
@@ ALLP @@
${WS}, +dw: Nat, +T: FD.array__Tree<U32>, +K: U32,
    +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +rep: BO.rep_bits(OB(T, K), S.BitList{${LIMN}}),
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},
    +hv: {O.bits_above_zero(U32.and(K, 31), VB.slot(T, VBT.QK(K))) == True{} : Bool}
@@ CF_2 @@
  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +hj = FD.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = FD.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)
  +cD = DL.p1(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf))))
@@ _cm_tree_laws @@

# The closed bounds, compared on VB.pw.
def hNk0() -> {Nat.is_le(Nat.add(${N}n, 8n), O.pow2n(${kb}n)) == True{} : Bool}:
  %VD.s_pow2_eq(${kb}n) : {Nat.is_le(Nat.add(${N}n, 8n), _) == True{} : Bool}
  {==}

def hNk2() -> {Nat.is_le(Nat.add(Nat.add(${FS}n, Nat.add(${N}n, 1n)), 3n), O.pow2n(${kb2}n)) == True{} : Bool}:
  %VD.s_pow2_eq(${kb2}n) : {Nat.is_le(Nat.add(Nat.add(${FS}n, Nat.add(${N}n, 1n)), 3n), _) == True{} : Bool}
  {==}

def hKk(${NC}) -> VBT.HK(K, ${kb}n):
  FD.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(${N}n, 8n), O.pow2n(${kb}n), Order.add_right(U32.to_nat(K), ${N}n, 8n, hN), hNk0())

def eNK(${NC}) -> {Nat.is_le(U32.to_nat(CO.NK(K)), Nat.add(${N}n, 1n)) == True{} : Bool}:
  CO.nk_le(K, ${kb}n, ${N}n, {==}, hN, hNk0())

def eS(${NC}) -> {U32.to_nat(SFS(K)) == Nat.add(${FS}n, U32.to_nat(CO.NK(K))) : Nat}:
  A.add_le(${FS}, CO.NK(K), ${FS + N + 1}, FD.nat__le_trans(Nat.add(${FS}n, U32.to_nat(CO.NK(K))), Nat.add(${FS}n, Nat.add(${N}n, 1n)), U32.to_nat(${FS + N + 1}),
    Order.add_left(${FS}n, U32.to_nat(CO.NK(K)), Nat.add(${N}n, 1n), eNK(${NCa})), {==}))

def padd(${NC}) -> {O.padd(${FS}, CO.NK(K)) == SFS(K) : U32}:
  VE.padd_ok(${FS}, CO.NK(K), VE.winit(31n, VE.bits32(${FS})), VE.winit(31n, VE.bits32(CO.NK(K))), {==},
    VE.small_pad(CO.NK(K), ${PB}n, {==}, FD.nat__le_lt_trans(U32.to_nat(CO.NK(K)), Nat.add(${N}n, 1n), FD.spec_common__pow2(${PB}n), eNK(${NCa}), {==})))

# The encoding's words: the header's ${H}, then the bit list's q + 1.
def nwS(${NC}) -> {VC.NW(SFS(K)) == Nat.add(${H}n, Nat.add(${q}, 1n)) : Nat}:
${CF}
  +e1 = Equal.trans(Nat, U32.to_nat(SFS(K)), Nat.add(${FS}n, U32.to_nat(CO.NK(K))), Nat.add(A.quad(Nat.add(${H}n, ${q})), Nat.add(j, 1n)), eS(${NCa}),
    Equal.trans(Nat, Nat.add(${FS}n, U32.to_nat(CO.NK(K))), Nat.add(A.quad(${H}n), Nat.add(A.quad(${q}), Nat.add(j, 1n))), Nat.add(A.quad(Nat.add(${H}n, ${q})), Nat.add(j, 1n)),
      Equal.cong(Nat, Nat, z => Nat.add(${FS}n, z), U32.to_nat(CO.NK(K)), Nat.add(A.quad(${q}), Nat.add(j, 1n)), VBT.G4(K, ${kb}n, {==}, hKk(${NCa}), j, {==})),
      Equal.trans(Nat, Nat.add(A.quad(${H}n), Nat.add(A.quad(${q}), Nat.add(j, 1n))), Nat.add(Nat.add(A.quad(${H}n), A.quad(${q})), Nat.add(j, 1n)), Nat.add(A.quad(Nat.add(${H}n, ${q})), Nat.add(j, 1n)),
        Equal.sym(Nat, Nat.add(Nat.add(A.quad(${H}n), A.quad(${q})), Nat.add(j, 1n)), Nat.add(A.quad(${H}n), Nat.add(A.quad(${q}), Nat.add(j, 1n))), FD.nat__add_assoc(A.quad(${H}n), A.quad(${q}), Nat.add(j, 1n))),
        Equal.cong(Nat, Nat, z => Nat.add(z, Nat.add(j, 1n)), Nat.add(A.quad(${H}n), A.quad(${q})), A.quad(Nat.add(${H}n, ${q})), VF.quad_add(${H}n, ${q})))))
  +h3 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 3n), O.pow2n(${kb2}n)) == True{} : Bool}, Nat.add(${FS}n, U32.to_nat(CO.NK(K))), U32.to_nat(SFS(K)), Equal.sym(Nat, U32.to_nat(SFS(K)), Nat.add(${FS}n, U32.to_nat(CO.NK(K))), eS(${NCa})),
    FD.nat__le_trans(Nat.add(Nat.add(${FS}n, U32.to_nat(CO.NK(K))), 3n), Nat.add(Nat.add(${FS}n, Nat.add(${N}n, 1n)), 3n), O.pow2n(${kb2}n),
      Order.add_right(Nat.add(${FS}n, U32.to_nat(CO.NK(K))), Nat.add(${FS}n, Nat.add(${N}n, 1n)), 3n, Order.add_left(${FS}n, U32.to_nat(CO.NK(K)), Nat.add(${N}n, 1n), eNK(${NCa}))), hNk2()))
  +e2 = VBT.NWq(SFS(K), Nat.add(${H}n, ${q}), Nat.add(j, 1n), ${kb2}n, {==}, h3, e1)
  Equal.trans(Nat, VC.NW(SFS(K)), Nat.add(Nat.add(${H}n, ${q}), VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n))), Nat.add(${H}n, Nat.add(${q}, 1n)), e2,
    Equal.trans(Nat, Nat.add(Nat.add(${H}n, ${q}), VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n))), Nat.add(Nat.add(${H}n, ${q}), 1n), Nat.add(${H}n, Nat.add(${q}, 1n)),
      Equal.cong(Nat, Nat, z => Nat.add(Nat.add(${H}n, ${q}), z), VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n)), 1n, cD),
      FD.nat__add_assoc(${H}n, ${q}, 1n)))

# (N >> 5) + 1 words past the header fit 2^${KO}: computed on U32.
def e5le() -> {Nat.is_le(Nat.add(${H}n, Nat.add(VD.s_rng(5n, ${N}n), 1n)), O.pow2n(${KO}n)) == True{} : Bool}:
  %VD.shrk(5n, ${N}) : {Nat.is_le(Nat.add(${H}n, Nat.add(_, 1n)), O.pow2n(${KO}n)) == True{} : Bool}
  %VD.s_pow2_eq(${KO}n) : {Nat.is_le(Nat.add(${H}n, Nat.add(U32.to_nat(U32.shrn(${N}, 5n)), 1n)), _) == True{} : Bool}
  {==}

def hwO(${NC}) -> {Nat.is_le(U32.to_nat(VC.nwu(SFS(K))), O.pow2n(${KO}n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(${KO}n)) == True{} : Bool}, Nat.add(${H}n, Nat.add(${q}, 1n)), U32.to_nat(VC.nwu(SFS(K))),
    Equal.sym(Nat, U32.to_nat(VC.nwu(SFS(K))), Nat.add(${H}n, Nat.add(${q}, 1n)), nwS(${NCa})),
    FD.nat__le_trans(Nat.add(${H}n, Nat.add(${q}, 1n)), Nat.add(${H}n, Nat.add(VD.s_rng(5n, ${N}n), 1n)), O.pow2n(${KO}n),
      Order.add_left(${H}n, Nat.add(${q}, 1n), Nat.add(VD.s_rng(5n, ${N}n), 1n), CO.qle(K, ${kb}n, ${N}n, {==}, hN, hNk0())), e5le()))

def hDOK(${NC}) -> {Nat.is_le(DO(K), ${KO}n) == True{} : Bool}: VD.wd_min(VC.nwu(SFS(K)), ${KO}n, hwO(${NCa}))
def hDO29(${NC}) -> {Nat.is_lt(DO(K), 29n) == True{} : Bool}: FD.nat__le_lt_trans(DO(K), ${KO}n, 29n, hDOK(${NCa}), {==})
def hDO31(${NC}) -> {Nat.is_lt(DO(K), 31n) == True{} : Bool}: FD.nat__le_lt_trans(DO(K), ${KO}n, 31n, hDOK(${NCa}), {==})

# The room of the output tree: H + q + 1 <= 2^DO.
def hDq(${NC}) -> {Nat.is_le(Nat.add(${H}n, Nat.add(${q}, 1n)), VB.pw(DO(K))) == True{} : Bool}:
  %Equal.sym(Nat, VB.pw(DO(K)), O.pow2n(DO(K)), VD.s_pow2_eq(DO(K))) : {Nat.is_le(Nat.add(${H}n, Nat.add(${q}, 1n)), _) == True{} : Bool}
  %nwS(${NCa}) : {Nat.is_le(_, O.pow2n(DO(K))) == True{} : Bool}
  VD.wd_cover(VC.nwu(SFS(K)), ${KO}n, {==}, hwO(${NCa}))

# a <= H: a <= 2^DO.
def hbk(+a: Nat, ${NC}, +ha: {Nat.is_le(a, ${H}n) == True{} : Bool}) -> {Nat.is_le(a, VB.pw(DO(K))) == True{} : Bool}:
  FD.nat__le_trans(a, ${H}n, VB.pw(DO(K)), ha, FD.nat__le_trans(${H}n, Nat.add(${H}n, Nat.add(${q}, 1n)), VB.pw(DO(K)), Order.below_sum(${H}n, Nat.add(${q}, 1n)), hDq(${NCa})))

def pf0(+K: U32) -> {FD.array__perfect(U32, DO(K), VC.ZT(DO(K))) == True{} : Bool}: FD.array__trep_perfect(U32, DO(K), 0)
def pf1(+K: U32) -> {FD.array__perfect(U32, DO(K), OUT1(K)) == True{} : Bool}: FD.array__upd_perfect(U32, DO(K), VC.ZT(DO(K)), ${po}n, ${FS}, pf0(K))

# The words of OUT1 past the header are zero.
def sl1(${NC}, +k: Nat, +hk: {Nat.is_le(${H}n, k) == True{} : Bool}) -> {VB.slot(OUT1(K), k) == 0 : U32}:
  %Equal.sym(${LT}, FD.array__slots(U32, OUT1(K)), FD.spec_common__update(U32, FD.array__slots(U32, VC.ZT(DO(K))), ${po}n, ${FS}),
      FD.array__upd_slots(U32, DO(K), VC.ZT(DO(K)), ${po}n, ${FS}, FD.nat__lt_le_trans(${po}n, ${H}n, VB.pw(DO(K)), {==}, hbk(${H}n, ${NCa}, {==})), pf0(K))) :
    {FD.flat__nthc(_, k) == 0 : U32}
  Equal.trans(U32, FD.flat__nthc(FD.spec_common__update(U32, FD.array__slots(U32, VC.ZT(DO(K))), ${po}n, ${FS}), k), FD.flat__nthc(FD.array__slots(U32, VC.ZT(DO(K))), k), 0,
    FD.flat__nthc_other(FD.array__slots(U32, VC.ZT(DO(K))), ${po}n, k, ${FS}, FD.nat__is_eq_lt(${po}n, k, FD.nat__lt_le_trans(${po}n, ${H}n, k, {==}, hk))),
    VBT.zslot(DO(K), k))

@@ _cm_tree_laws_cra @@

def cra(${ALLP}) -> CT.CRA(DO(K), OUT1(K), T, U32.add(0, ${FS}), ${H}n, K):
  (+wf, +r1) = rep
  +hN = ${HN}
  +hz = VR.rep_hz(dw, T, K, ${kb}n, ${N}n, pfT, {==}, hN, hNk0(), CO.qs_sized(dw, K, ${kb}n, ${N}n, {==}, hN, hNk0(), hcap), wf)
  CT.enc_at(DO(K), dw, OUT1(K), T, U32.add(0, ${FS}), ${H}n, K, ${kb}n, ${KY}n, ${N}n, pf1(K), pfT, hDO29(${NCa}), hdw, {==}, {==},
    {==}, {==}, {==}, hN, hNk0(), {==}, hDq(${NCa}), hcap, hz,
    sl1(${NCa}, Nat.add(${H}n, ${q}), Order.below_sum(${H}n, ${q})),
    sl1(${NCa}, Nat.add(VY.QL(O.bits_nbytes(K)), ${H}n), FD.logic__subst(Nat, z => {Nat.is_le(${H}n, z) == True{} : Bool}, Nat.add(${H}n, VY.QL(O.bits_nbytes(K))), Nat.add(VY.QL(O.bits_nbytes(K)), ${H}n),
      FD.nat__add_comm(${H}n, VY.QL(O.bits_nbytes(K))), Order.below_sum(${H}n, VY.QL(O.bits_nbytes(K))))))

@@ _cm_size_put_eval @@
def size_eval(${ALLP})
    -> {${Tn}_size(${OBJ}) == ${RS} : ${Tn} & U32}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T)), (FD.array__thaw(U32, T), FD.u32__pow2u(dw)), FD.array__size_thaw(U32, dw, T, pfT)) :
    {${Tn}_sz0(${FIXOBJS}, ${FS}, O.bsz_pick(K, _)) == ${RS} : ${Tn} & U32}
  %Equal.sym(Bool, U32.is_le(U32.add(U32.shrn(K, 5n), 1), FD.u32__pow2u(dw)), True{}, CO.capT(K, dw, hdw, hcap)) :
    {${Tn}_sz0(${FIXOBJS}, ${FS}, (${OBB}, O.pick(_, U32.add(U32.shrn(K, 3n), 1), 2147483648))) == ${RS} : ${Tn} & U32}
  %Equal.sym(U32, O.padd(${FS}, CO.NK(K)), SFS(K), padd(K, ${HN})) : {(${OBJ}, _) == ${RS} : ${Tn} & U32}
  {==}

@@ _cm_hdstw @@
def hdstW(${NC}) -> {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), ${H}n), VB.pw(DO(K))) == True{} : Bool}:
${CF}
  +cA = DL.p1(DL.TA(j, b), DL.CB(j, b), cf)
  +cB = DL.p1(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf))
  +eNW = Equal.trans(Nat, VC.NW(O.bits_nbytes(K)), Nat.add(${q}, VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n))), Nat.add(${q}, BW.CWr(DL.RK(K))),
    VBT.FNWnb(K, ${kb}n, {==}, hKk(${NCa}), j, b, Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), {==}, {==}, {==}, cB, {==}),
    Equal.cong(Nat, Nat, z => Nat.add(${q}, z), VD.s_rng(2n, Nat.add(Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), 3n)), BW.CWr(DL.RK(K)), cA))
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(${q}, 1n)) == True{} : Bool}, Nat.add(${q}, BW.CWr(DL.RK(K))), VC.NW(O.bits_nbytes(K)),
    Equal.sym(Nat, VC.NW(O.bits_nbytes(K)), Nat.add(${q}, BW.CWr(DL.RK(K))), eNW), Order.add_left(${q}, BW.CWr(DL.RK(K)), 1n, CO.cwle(DL.RK(K))))
  FD.nat__le_trans(Nat.add(VC.NW(O.bits_nbytes(K)), ${H}n), Nat.add(${H}n, Nat.add(${q}, 1n)), VB.pw(DO(K)),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), ${H}n), z) == True{} : Bool}, Nat.add(Nat.add(${q}, 1n), ${H}n), Nat.add(${H}n, Nat.add(${q}, 1n)),
      FD.nat__add_comm(Nat.add(${q}, 1n), ${H}n), Order.add_right(VC.NW(O.bits_nbytes(K)), Nat.add(${q}, 1n), ${H}n, h1)), hDq(${NCa}))


@@ tail @@
Equal.trans(${LT}, VF.WIN(1n, ${po}n, ${SA}), VS.wtake(1n, FD.spec_common__update(U32, FD.array__slots(U32, ${MTK}), Nat.add(${H}n, ${q}), ${VV})), [${FS}],
    Equal.cong(${LT}, ${LT}, z => VS.wtake(1n, z), ${SA}, FD.spec_common__update(U32, FD.array__slots(U32, ${MTK}), Nat.add(${H}n, ${q}), ${VV}),
      FD.array__upd_slots(U32, DO(K), ${MTK}, Nat.add(${H}n, ${q}), ${VV}, FD.nat__lt_le_trans(Nat.add(${H}n, ${q}), Nat.add(${H}n, Nat.add(${q}, 1n)), VB.pw(DO(K)), FD.nat__lt_add_left(${q}, Nat.add(${q}, 1n), ${H}n, DL.lt_add1(${q})), hDq(${NCa})),
        VB.mone_perfect(VC.NW(O.bits_nbytes(K)), 0n, ${H}n, DO(K), OUT1(K), T, pf1(K)))),
    Equal.trans(${LT}, VS.wtake(1n, FD.spec_common__update(U32, FD.array__slots(U32, ${MTK}), Nat.add(${H}n, ${q}), ${VV})), VF.WIN(1n, ${po}n, FD.array__slots(U32, ${MTK})), [${FS}],
      VF.take_upd(1n, FD.array__slots(U32, ${MTK}), Nat.add(${H}n, ${q}), ${VV}, FD.nat__le_trans(1n, ${H}n, Nat.add(${H}n, ${q}), {==}, Order.below_sum(${H}n, ${q}))),
      Equal.trans(${LT}, VF.WIN(1n, ${po}n, FD.array__slots(U32, ${MTK})), VF.WIN(1n, ${po}n, ${LM}), [${FS}],
        Equal.cong(${LT}, ${LT}, z => VF.WIN(1n, ${po}n, z), FD.array__slots(U32, ${MTK}), ${LM}, VB.slots_mone(VC.NW(O.bits_nbytes(K)), 0n, ${H}n, DO(K), OUT1(K), T, pf1(K), hdstW(${NCa}))),
        Equal.trans(${LT}, VF.WIN(1n, ${po}n, ${LM}), VF.WIN(1n, ${po}n, FD.array__slots(U32, OUT1(K))), [${FS}],
          VF.lm_hi(VC.NW(O.bits_nbytes(K)), 0n, ${H}n, 1n, ${po}n, FD.array__slots(U32, OUT1(K)), ${ST}, {==}),
          V2.own([${FS}], DO(K), VC.ZT(DO(K)), ${po}n, pf0(K), hbk(Nat.add(1n, ${po}n), ${NCa}, {==}))))))
@@ _cm_window_eqs @@
# K / 8 + 1 <= 4 (q + 1).
def nkq(${NC}) -> {Nat.is_le(U32.to_nat(CO.NK(K)), A.quad(Nat.add(${q}, 1n))) == True{} : Bool}:
  +j = VBT.JK(K)
  +hj = RD.and_le(VBT.PDK(K), 3)
  %Equal.sym(Nat, U32.to_nat(CO.NK(K)), Nat.add(A.quad(${q}), Nat.add(j, 1n)), VBT.G4(K, ${kb}n, {==}, hKk(${NCa}), j, {==})) : {Nat.is_le(_, A.quad(Nat.add(${q}, 1n))) == True{} : Bool}
  %VF.quad_add(${q}, 1n) : {Nat.is_le(Nat.add(A.quad(${q}), Nat.add(j, 1n)), _) == True{} : Bool}
  Order.add_left(A.quad(${q}), Nat.add(j, 1n), 4n, Order.add_right(j, 3n, 1n, hj))

# The output's bytes: the header's words, then the bit list's bytes.
def out_eq(${ALLP})
    -> {${BY} == ${RHS} : +List<U32>}:
  +hN = ${HN}
  +hH = FD.logic__subst(Nat, z => {Nat.is_le(${H}n, z) == True{} : Bool}, VB.pw(DO(K)), VB.len(${SO}),
    Equal.sym(Nat, VB.len(${SO}), VB.pw(DO(K)), FD.array__slots_length(U32, DO(K), ${OUT}, pfD${len(fixed)}(${WA}, T, K))), hbk(${H}n, ${NCa}, {==}))
  %Equal.sym(Nat, U32.to_nat(SFS(K)), Nat.add(${FS}n, U32.to_nat(CO.NK(K))), eS(${NCa})) : {VS.bt(_, F.limbs(${SO})) == ${RHS} : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(${H}n), U32.to_nat(CO.NK(K))), F.limbs(${SO})),
      List.append(&2, U32, F.limbs(VS.wtake(${H}n, ${SO})), VS.bt(U32.to_nat(CO.NK(K)), F.limbs(VB.wdr(${H}n, ${SO})))), VY.bt_split(${H}n, U32.to_nat(CO.NK(K)), ${SO}, hH)) :
    {_ == ${RHS} : +List<U32>}
  %Equal.sym(${LT}, VF.WIN(${H}n, 0n, ${SO}), ${HDRL}, hdr_eq(${SPa})) :
    {List.append(&2, U32, F.limbs(_), VS.bt(U32.to_nat(CO.NK(K)), F.limbs(VB.wdr(${H}n, ${SO})))) == ${RHS} : +List<U32>}
  %VY.bt_take(${MQ}, U32.to_nat(CO.NK(K)), VB.wdr(${H}n, ${SO}), nkq(${NCa})) :
    {List.append(&2, U32, F.limbs(${HDRL}), _) == ${RHS} : +List<U32>}
  %Equal.sym(${LT}, VF.WIN(${MQ}, ${H}n, ${SO}), VF.WIN(${MQ}, ${H}n, ${SA}), pay_eq(${SPa})) :
    {List.append(&2, U32, F.limbs(${HDRL}), VS.bt(U32.to_nat(CO.NK(K)), F.limbs(_))) == ${RHS} : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(U32.to_nat(CO.NK(K)), F.limbs(VF.WIN(${MQ}, ${H}n, ${SA}))), ${Y}, VY.bt_take(${MQ}, U32.to_nat(CO.NK(K)), VB.wdr(${H}n, ${SA}), nkq(${NCa}))) :
    {List.append(&2, U32, F.limbs(${HDRL}), _) == ${RHS} : +List<U32>}
  {==}

@@ _cm_spec_side @@
def VAL(${WS}, +T: FD.array__Tree<U32>, +K: U32) -> S.Value: S.Sequence{${items(0)}}

# The bit list's spec part is the window's bytes.
def bparts(${ALLP})
    -> {Codec.parts(${VALB}, S.BitList{${LIMN}}) == Some{[S.Variable{${Y}}]} : ${MP}}:
  +hN = ${HN}
  +c = cra(${ALLa})
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, T)), T, FD.array__freeze_thaw(U32, T)) :
    {Codec.parts(S.BitsValue{BK.btk(U32.to_nat(K), BK.bitsof(FD.array__slots(U32, _)))}, S.BitList{${LIMN}}) == Some{[S.Variable{${Y}}]} : ${MP}}
  %Equal.sym(Nat, List.length(&2, Bool, ${BITS}), U32.to_nat(K), CT.cra3(DO(K), OUT1(K), T, U32.add(0, ${FS}), ${H}n, K, c)) :
    {Codec.one(Bits.encoding(Nat.is_le(_, ${LIMN}), List.append(&2, Bool, ${BITS}, [True{}])), None{}) == Some{[S.Variable{${Y}}]} : ${MP}}
  %Equal.sym(Bool, Nat.is_le(U32.to_nat(K), ${LIMN}), True{}, hN) :
    {Codec.one(Bits.encoding(_, List.append(&2, Bool, ${BITS}, [True{}])), None{}) == Some{[S.Variable{${Y}}]} : ${MP}}
  %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, ${BITS}, [True{}])), ${Y}, CT.cra2(DO(K), OUT1(K), T, U32.add(0, ${FS}), ${H}n, K, c)) :
    {Codec.one(Some{_}, None{}) == Some{[S.Variable{${Y}}]} : ${MP}}
  {==}

def fitY(${ALLP})
    -> {N.fits(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, ${Y}))) == True{} : Bool}:
  +hN = ${HN}
  VS.fits_mono(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, ${Y})), Nat.add(${FS}n, Nat.add(${N}n, 1n)),
    Order.add_left(${FS}n, List.length(&2, U32, ${Y}), Nat.add(${N}n, 1n),
      FD.nat__le_trans(List.length(&2, U32, ${Y}), U32.to_nat(CO.NK(K)), Nat.add(${N}n, 1n), VZ.bt_len_le(U32.to_nat(CO.NK(K)), F.limbs(VB.wdr(${H}n, ${SA}))), eNK(${NCa}))),
    {==})

# Codec's own steps over variables (stuck on them, so these conversions stay small): an instance
# rewrites the goal syntactically, where a conversion between the heads would evaluate the parts
# (Codec.aggregate and Layout.encoding are strict: scratchpad checker_findings item 2b).
def efl(+sch: S.Schema, +v: S.Value) -> {Codec.encoding_for_legal_type(sch, v) == Codec.bytes(Codec.parts(v, sch)) : ${M}}: {==}
def agg1(+xs: +List<S.Part>, +w: Maybe<&2, Nat>) -> {Codec.aggregate(Some{xs}, w) == Codec.one(Layout.encoding(xs), w) : ${MP}}: {==}

# The spec encoding of the object's value: the header words' limbs, then the window's bytes.
def encE(${ALLP})
    -> {Codec.encoding_for_legal_type(Spec.${n}(), VAL(${WA}, T, K)) == ${RHSk} : ${M}}:
  %Equal.sym(${M}, Codec.encoding_for_legal_type(Spec.${n}(), VAL(${WA}, T, K)), Codec.bytes(Codec.parts(VAL(${WA}, T, K), Spec.${n}())), efl(Spec.${n}(), VAL(${WA}, T, K))) :
    {_ == ${RHSk} : ${M}}
  %Equal.sym(${MP}, Codec.parts(VAL(${WA}, T, K), Spec.${n}()), Codec.aggregate(Codec.parts(${items(0)}, ${chain(0)}), SC.fixed_size(${chain(0)})),
      VSQ.seq_parts(VAL(${WA}, T, K), Spec.${n}(), ${items(0)}, ${NAMES}, ${chain(0)}, {==}, {==})) :
    {Codec.bytes(_) == ${RHSk} : ${M}}
  %Equal.sym(Maybe<&2, Nat>, SC.fixed_size(${chain(0)}), None{}, {==}) :
    {Codec.bytes(Codec.aggregate(Codec.parts(${items(0)}, ${chain(0)}), _)) == ${RHSk} : ${M}}
  %Equal.sym(${MP}, Codec.parts(${items(0)}, ${chain(0)}), Some{[${', '.join(parts)}]},
      ${VL.seqwrap(cat(0))}) :
    {Codec.bytes(Codec.aggregate(_, None{})) == ${RHSk} : ${M}}
  %Equal.sym(${MP}, Codec.aggregate(Some{[${', '.join(parts)}]}, None{}), Codec.one(Layout.encoding([${', '.join(parts)}]), None{}), agg1([${', '.join(parts)}], None{})) :
    {Codec.bytes(_) == ${RHSk} : ${M}}
  %Equal.sym(+List<S.Part>, [${', '.join(parts)}], VS.fpv(${PRE}, ${Y}, ${POST}), {==}) :
    {Codec.bytes(Codec.one(Layout.encoding(_), None{})) == ${RHSk} : ${M}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, ${Y}, ${POST})), Some{${ENCR}}, VBC.enc_fpvb(${PRE}, ${Y}, ${POST}, VZ.bd_btl(U32.to_nat(CO.NK(K)), VB.wdr(${H}n, ${SA})), fitY(${ALLa}))) :
    {Codec.bytes(Codec.one(_, None{})) == ${RHSk} : ${M}}
  {==}
