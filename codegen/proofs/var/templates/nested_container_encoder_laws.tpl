@@ encw_text @@

def hq(+a: Nat, +dd: Nat, +P: Nat, +N: U32, +ha: {Nat.is_le(a, ${H}n) == True{} : Bool}, ${HR})
    -> {Nat.is_le(Nat.add(a, P), VB.pw(dd)) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(a, P), Nat.add(Nat.add(${H}n, ${NW}), P), VB.pw(dd),
    Order.add_right(a, Nat.add(${H}n, ${NW}), P, FD.nat__le_trans(a, ${H}n, Nat.add(${H}n, ${NW}), ha, Order.below_sum(${H}n, ${NW}))), hR)

def hdstw(+dd: Nat, +P: Nat, +N: U32, ${HR})
    -> {Nat.is_le(Nat.add(${NW}, Nat.add(${H}n, P)), VB.pw(dd)) == True{} : Bool}:
  %VN.sw(${H}n, ${NW}, P) : {Nat.is_le(_, VB.pw(dd)) == True{} : Bool}
  hR

def eoff(+pos: U32, +c: U32, +k: Nat, +dd: Nat, +P: Nat, +N: U32, +e: {U32.to_nat(pos) == A.quad(P) : Nat}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hk: {Nat.is_le(k, ${H}n) == True{} : Bool}, +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, ${HR})
    -> {U32.to_nat(U32.add(pos, c)) == A.quad(Nat.add(k, P)) : Nat}:
  VF.off_add(pos, c, P, k, 2n+dd, e, ec, hdd, VF.in_q(k, P, dd, hq(k, dd, P, N, hk, hR)))

def pfW0(${CW}, +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}) -> {FD.array__perfect(U32, dd, ${IW(0)}) == True{} : Bool}:
  FD.array__upd_perfect(U32, dd, D, Nat.add(${po}n, P), ${FS}, pfD)
def pfW1(${CW}, +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}) -> {FD.array__perfect(U32, dd, ${IW(1)}) == True{} : Bool}:
  VB.mone_perfect(${NW}, 0n, Nat.add(${H}n, P), dd, ${IW(0)}, T, pfW0(${CWa}, pfD))
@@ encw_text_2 @@
# The spec parts of the value: one variable part, the limbs of its words.
def partsE(${WS}, +k: Nat, +W: List<&2, U32>,
    +hk: {Nat.is_le(k, ${LIMN}) == True{} : Bool},
    +hl: {Nat.is_le(Nat.double(k), FD.spec_common__length(U32, W)) == True{} : Bool})
    -> {Codec.parts(E.XE(${WA}, k, W), Spec.${n}()) == ${RHSp} : ${MP}}:
  +le2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(${LIMN})) == True{} : Bool}, VS.x8(k), List.length(&2, U32, F.limbs(${YS})),
    Equal.sym(Nat, List.length(&2, U32, F.limbs(${YS})), VS.x8(k), VS.len_limbs_wtake2(k, W, hl)), VS.x8_mono(k, ${LIMN}, hk))
  +fit = VS.fits_mono(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, F.limbs(${YS}))), Nat.add(${FS}n, VS.x8(${LIMN})),
    Order.add_left(${FS}n, List.length(&2, U32, F.limbs(${YS})), VS.x8(${LIMN}), le2), ${K_FIT})
  %Equal.sym(${MP}, Codec.parts(${ITEMS}, ${CHAIN}), Some{${PL}},
      ${CAT}) :
    {Codec.aggregate(_, None{}) == ${RHSp} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, F.limbs(${YS}), ${POST})), Some{${ENCR}}, VS.enc_fpv(${PRE}, ${YS}, ${POST}, fit)) :
    {Codec.one(_, None{}) == ${RHSp} : ${MP}}
  {==}

def lenY(${WS}, +k: Nat, +W: List<&2, U32>, +hl: {Nat.is_le(Nat.double(k), FD.spec_common__length(U32, W)) == True{} : Bool})
    -> {List.length(&2, U32, F.limbs(${HDR} <> ${YS})) == Nat.add(${FS}n, VS.x8(k)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, F.limbs(${YS})), VS.x8(k), VS.len_limbs_wtake2(k, W, hl)) : {Nat.add(${FS}n, _) == Nat.add(${FS}n, VS.x8(k)) : Nat}
  {==}

@@ _ae_object_laws @@
def C1(+N1: U32) -> U32: U32.add(8, ${S1})
def C2(+N1: U32, +N2: U32) -> U32: U32.add(C1(N1), ${S2})
def DOA(+N1: U32, +N2: U32) -> Nat: B.words_depth(VC.nwu(${C2}))
def A1(+N1: U32, +N2: U32) -> FD.array__Tree<U32>: FD.array__upd(U32, ${DO}, VC.ZT(${DO}), 0n, 8)
def AW1(${TW}) -> FD.array__Tree<U32>: IW.${IWl}(${A_['WA']}, ${DO}, ${A1}, 2n, N1, T1)
def A2(${TW}) -> FD.array__Tree<U32>: FD.array__upd(U32, ${DO}, ${W1}, 1n, ${C1})
def AW2(${TW}) -> FD.array__Tree<U32>: IW.${IWl}(${B_['WA']}, ${DO}, ${A2}, ${P2}, N2, T2)

def sB(${NC}) -> {Nat.is_le(U32.to_nat(E.SFS(N)), ${XL}) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(E.SFS(N)), Nat.add(${FS}n, U32.to_nat(N)), E.eS(N, c, ec, hc)) : {Nat.is_le(_, ${XL}) == True{} : Bool}
  Order.add_left(${FS}n, U32.to_nat(N), VS.x8(${LIMN}), E.leN(N, c, ec, hc))

def eC1(+N1: U32, +c1: Nat, +ec1: {U32.to_nat(N1) == VS.x8(c1) : Nat}, +hc1: {Nat.is_le(c1, ${LIMN}) == True{} : Bool})
    -> {U32.to_nat(${C1}) == Nat.add(8n, U32.to_nat(${S1})) : Nat}:
  A.add_le(8, ${S1}, ${BC1}, FD.nat__le_trans(Nat.add(8n, U32.to_nat(${S1})), Nat.add(8n, ${XL}), U32.to_nat(${BC1}),
    Order.add_left(8n, U32.to_nat(${S1}), ${XL}, sB(N1, c1, ec1, hc1)), ${K_C1}))

def leC1(+N1: U32, +c1: Nat, +ec1: {U32.to_nat(N1) == VS.x8(c1) : Nat}, +hc1: {Nat.is_le(c1, ${LIMN}) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(${C1}), Nat.add(8n, ${XL})) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(${C1}), Nat.add(8n, U32.to_nat(${S1})), eC1(N1, c1, ec1, hc1)) : {Nat.is_le(_, Nat.add(8n, ${XL})) == True{} : Bool}
  Order.add_left(8n, U32.to_nat(${S1}), ${XL}, sB(N1, c1, ec1, hc1))

def eC2(${NCP}) -> {U32.to_nat(${C2}) == Nat.add(U32.to_nat(${C1}), U32.to_nat(${S2})) : Nat}:
  A.add_le(${C1}, ${S2}, ${BC2}, FD.nat__le_trans(Nat.add(U32.to_nat(${C1}), U32.to_nat(${S2})), Nat.add(Nat.add(8n, ${XL}), ${XL}), U32.to_nat(${BC2}),
    VN.le_add2(U32.to_nat(${C1}), Nat.add(8n, ${XL}), U32.to_nat(${S2}), ${XL}, leC1(N1, c1, ec1, hc1), sB(N2, c2, ec2, hc2)), ${K_C2}))

def leC2(${NCP}) -> {Nat.is_le(U32.to_nat(${C2}), Nat.add(Nat.add(8n, ${XL}), ${XL})) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(${C2}), Nat.add(U32.to_nat(${C1}), U32.to_nat(${S2})), eC2(${NCa})) : {Nat.is_le(_, Nat.add(Nat.add(8n, ${XL}), ${XL})) == True{} : Bool}
  VN.le_add2(U32.to_nat(${C1}), Nat.add(8n, ${XL}), U32.to_nat(${S2}), ${XL}, leC1(N1, c1, ec1, hc1), sB(N2, c2, ec2, hc2))

def paddC1(+N1: U32, +c1: Nat, +ec1: {U32.to_nat(N1) == VS.x8(c1) : Nat}, +hc1: {Nat.is_le(c1, ${LIMN}) == True{} : Bool})
    -> {O.padd(8, ${S1}) == ${C1} : U32}:
  VE.padd_ok(8, ${S1}, VE.winit(31n, VE.bits32(8)), VE.winit(31n, VE.bits32(${S1})), {==},
    VE.small_pad(${S1}, ${PB}n, {==}, FD.nat__le_lt_trans(U32.to_nat(${S1}), ${XL}, VB.pw(${PB}n), sB(N1, c1, ec1, hc1), ${K_P1})))

def paddC2(${NCP}) -> {O.padd(${C1}, ${S2}) == ${C2} : U32}:
  VE.padd_ok(${C1}, ${S2}, VE.winit(31n, VE.bits32(${C1})), VE.winit(31n, VE.bits32(${S2})),
    VE.small_pad(${C1}, ${PB}n, {==}, FD.nat__le_lt_trans(U32.to_nat(${C1}), Nat.add(8n, ${XL}), VB.pw(${PB}n), leC1(N1, c1, ec1, hc1), ${K_P8})),
    VE.small_pad(${S2}, ${PB}n, {==}, FD.nat__le_lt_trans(U32.to_nat(${S2}), ${XL}, VB.pw(${PB}n), sB(N2, c2, ec2, hc2), ${K_P1})))

def npC2(${NCP}) -> {O.is_poisoned(${C2}) == False{} : Bool}:
  VE.np31y(${C2}, ${P3}n, {==}, FD.nat__le_trans(Nat.add(31n, U32.to_nat(${C2})), Nat.add(31n, Nat.add(Nat.add(8n, ${XL}), ${XL})), VB.pw(${P3}n),
    Order.add_left(31n, U32.to_nat(${C2}), Nat.add(Nat.add(8n, ${XL}), ${XL}), leC2(${NCa})), ${K_Y2}))

def eQ(${NCP}) -> {A.quad(${Q}) == U32.to_nat(${C2}) : Nat}:
  %Equal.sym(Nat, U32.to_nat(${C2}), Nat.add(U32.to_nat(${C1}), U32.to_nat(${S2})), eC2(${NCa})) : {A.quad(${Q}) == _ : Nat}
  %Equal.sym(Nat, U32.to_nat(${C1}), Nat.add(8n, U32.to_nat(${S1})), eC1(N1, c1, ec1, hc1)) : {A.quad(${Q}) == Nat.add(_, U32.to_nat(${S2})) : Nat}
  %E.eSq(N1, c1, ec1, hc1) : {A.quad(${Q}) == Nat.add(Nat.add(8n, _), U32.to_nat(${S2})) : Nat}
  %E.eSq(N2, c2, ec2, hc2) : {A.quad(${Q}) == Nat.add(Nat.add(8n, A.quad(${X1})), _) : Nat}
  %Equal.sym(Nat, A.quad(Nat.add(${X1}, ${X2})), Nat.add(A.quad(${X1}), A.quad(${X2})), Equal.sym(Nat, Nat.add(A.quad(${X1}), A.quad(${X2})), A.quad(Nat.add(${X1}, ${X2})), VF.quad_add(${X1}, ${X2}))) :
    {Nat.add(8n, _) == Nat.add(Nat.add(8n, A.quad(${X1})), A.quad(${X2})) : Nat}
  {==}

def nwC2(${NCP}) -> {VC.NW(${C2}) == ${Q} : Nat}:
  +hy = FD.nat__le_trans(Nat.add(31n, U32.to_nat(${C2})), Nat.add(31n, Nat.add(Nat.add(8n, ${XL}), ${XL})), VB.pw(${P3}n),
    Order.add_left(31n, U32.to_nat(${C2}), Nat.add(Nat.add(8n, ${XL}), ${XL}), leC2(${NCa})), ${K_Y2})
  %Equal.sym(Nat, VC.NW(${C2}), VD.s_rng(2n, 3n+U32.to_nat(${C2})), VC.eNW(${C2}, ${P3}n, {==}, hy)) : {_ == ${Q} : Nat}
  %eQ(${NCa}) : {VD.s_rng(2n, 3n+_) == ${Q} : Nat}
  VN.rngq(${Q})

def xB(${NC}) -> {Nat.is_le(1n+Nat.add(${H}n, VC.NW(N)), O.pow2n(${KO}n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(1n+Nat.add(${H}n, z), O.pow2n(${KO}n)) == True{} : Bool}, Nat.double(c), VC.NW(N), Equal.sym(Nat, VC.NW(N), Nat.double(c), E.nwN(N, c, ec, hc)),
    FD.nat__le_trans(${H + 1}n+Nat.double(c), ${MXB}, O.pow2n(${KO}n),
      Order.add_left(${H + 1}n, Nat.double(c), Nat.double(${LIMN}), FD.nat__double_le(c, ${LIMN}, hc)), ${K_XB}))

def hW(${NCP}) -> {Nat.is_le(U32.to_nat(VC.nwu(${C2})), O.pow2n(${KA}n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(${KA}n)) == True{} : Bool}, ${Q}, VC.NW(${C2}), Equal.sym(Nat, VC.NW(${C2}), ${Q}, nwC2(${NCa})),
    VN.le_q(${X1}, ${X2}, O.pow2n(${KO}n), xB(N1, c1, ec1, hc1), xB(N2, c2, ec2, hc2)))

def hDO(${NCP}) -> {Nat.is_le(${DO}, ${KA}n) == True{} : Bool}: VD.wd_min(VC.nwu(${C2}), ${KA}n, hW(${NCa}))
def hdd(${NCP}) -> {Nat.is_lt(${DO}, 29n) == True{} : Bool}: FD.nat__le_lt_trans(${DO}, ${KA}n, 29n, hDO(${NCa}), {==})

def roomA(${NCP}) -> {Nat.is_le(${Q}, VB.pw(${DO})) == True{} : Bool}:
  %Equal.sym(Nat, VB.pw(${DO}), O.pow2n(${DO}), VD.s_pow2_eq(${DO})) : {Nat.is_le(${Q}, _) == True{} : Bool}
  %nwC2(${NCa}) : {Nat.is_le(_, O.pow2n(${DO})) == True{} : Bool}
  VD.wd_cover(VC.nwu(${C2}), ${KA}n, {==}, hW(${NCa}))

def hQ(+a: Nat, ${NCP}, +ha: {Nat.is_le(a, ${Q}) == True{} : Bool}) -> {Nat.is_le(a, VB.pw(${DO})) == True{} : Bool}:
  FD.nat__le_trans(a, ${Q}, VB.pw(${DO}), ha, roomA(${NCa}))

def hR1(${NCP}) -> {Nat.is_le(Nat.add(${X1}, 2n), VB.pw(${DO})) == True{} : Bool}:
  hQ(Nat.add(${X1}, 2n), ${NCa}, VN.le_zx(2n, ${X1}, ${X2}))

def hR2(${NCP}) -> {Nat.is_le(Nat.add(${X2}, ${P2}), VB.pw(${DO})) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(${DO})) == True{} : Bool}, ${Q}, Nat.add(${X2}, ${P2}), Equal.sym(Nat, Nat.add(${X2}, ${P2}), ${Q}, VN.e_yzx(2n, ${X1}, ${X2})), roomA(${NCa}))

def pf0(+N1: U32, +N2: U32) -> {FD.array__perfect(U32, ${DO}, VC.ZT(${DO})) == True{} : Bool}: FD.array__trep_perfect(U32, ${DO}, 0)
def pfA1(+N1: U32, +N2: U32) -> {FD.array__perfect(U32, ${DO}, ${A1}) == True{} : Bool}: FD.array__upd_perfect(U32, ${DO}, VC.ZT(${DO}), 0n, 8, pf0(N1, N2))
def pfW1(${TW}) -> {FD.array__perfect(U32, ${DO}, ${W1}) == True{} : Bool}: IW.pfW${IWl[2:]}(${A_['WA']}, ${DO}, ${A1}, 2n, N1, T1, pfA1(N1, N2))
def pfA2(${TW}) -> {FD.array__perfect(U32, ${DO}, ${A2}) == True{} : Bool}: FD.array__upd_perfect(U32, ${DO}, ${W1}, 1n, ${C1}, pfW1(${TWa}))

def eP2(+N1: U32, +c1: Nat, +ec1: {U32.to_nat(N1) == VS.x8(c1) : Nat}, +hc1: {Nat.is_le(c1, ${LIMN}) == True{} : Bool})
    -> {U32.to_nat(U32.add(0, ${C1})) == A.quad(${P2}) : Nat}:
  Equal.trans(Nat, U32.to_nat(U32.add(0, ${C1})), U32.to_nat(${C1}), A.quad(${P2}),
    A.add_le(0, ${C1}, ${BC1}, FD.nat__le_trans(U32.to_nat(${C1}), Nat.add(8n, ${XL}), U32.to_nat(${BC1}), leC1(N1, c1, ec1, hc1), ${K_C1})),
    Equal.trans(Nat, U32.to_nat(${C1}), Nat.add(8n, U32.to_nat(${S1})), A.quad(${P2}), eC1(N1, c1, ec1, hc1),
      Equal.cong(Nat, Nat, z => Nat.add(8n, z), U32.to_nat(${S1}), A.quad(${X1}), Equal.sym(Nat, A.quad(${X1}), U32.to_nat(${S1}), E.eSq(N1, c1, ec1, hc1)))))

@@ _ae_size_put_eval @@
def size_eval(${ALLP})
    -> {${Tp}_size(${OBJ}) == ${RS} : ${Tp} & U32}:
  %Equal.sym(${IT}, ${Tc}_size(${A_['OBJ']}), (${A_['OBJ']}, ${S1}), E.size_eval(${A_['ALLa']})) :
    {${Tp}_sz0(${BX2}, 8, ${Tc}_bx_size_back(_)) == ${RS} : ${Tp} & U32}
  %Equal.sym(${IT}, ${Tc}_size(${B_['OBJ']}), (${B_['OBJ']}, ${S2}), E.size_eval(${B_['ALLa']})) :
    {${Tp}_sz1(${BX1}, O.padd(8, ${S1}), ${Tc}_bx_size_back(_)) == ${RS} : ${Tp} & U32}
  %Equal.sym(U32, O.padd(8, ${S1}), ${C1}, paddC1(N1, c1, ec1, hc1)) : {(${OBJ}, O.padd(_, ${S2})) == ${RS} : ${Tp} & U32}
  %Equal.sym(U32, O.padd(${C1}, ${S2}), ${C2}, paddC2(${NCa})) : {(${OBJ}, _) == ${RS} : ${Tp} & U32}
  {==}

@@ _ae_size_put_eval_2 @@
def put_eval(${ALLP})
    -> {${Tp}_putn(FD.array__thaw(U32, VC.ZT(${DO})), 0, ${OBJ}) == ${RP} : ${TP}}:
  +hd = hdd(${NCa})
  +hd32 = VB.lt32(${DO}, FD.nat__lt_trans(${DO}, 29n, 31n, hd, {==}))
  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, VC.ZT(${DO})), 0, 8), FD.array__thaw(U32, ${A1}),
      VB.set_n(${DO}, VC.ZT(${DO}), 0, 0n, 8, {==}, hd32, FD.nat__lt_le_trans(0n, ${Q}, VB.pw(${DO}), {==}, roomA(${NCa})), pf0(N1, N2))) :
    {${Tp}_pw0(0, ${BX2}, ${Tc}_bx_pvb(8, ${Tc}_bx_putk(_, U32.add(0, 8), ${BX1}))) == ${RP} : ${TP}}
  %Equal.sym(${TPc}, ${Tc}_putn(FD.array__thaw(U32, ${A1}), U32.add(0, 8), ${A_['OBJ']}), (FD.array__thaw(U32, ${W1}), (${A_['OBJ']}, ${S1})),
      IW.putw(${A_['WA']}, ${DO}, ${A1}, 2n, N1, T1, U32.add(0, 8), {==}, pfA1(N1, N2), hd, hR1(${NCa}), dw1, c1, pfT1, hdw1, ec1, hc1, hroom1)) :
    {${Tp}_pw0(0, ${BX2}, ${Tc}_bx_pvb(8, ${Tc}_bx_pk_back(_))) == ${RP} : ${TP}}
  %Equal.sym(U32, O.padd(8, ${S1}), ${C1}, paddC1(N1, c1, ec1, hc1)) :
    {${Tp}_pw1(0, ${BX1}, ${Tc}_bx_putv(FD.array__thaw(U32, ${W1}), 0, 4, _, ${BX2})) == ${RP} : ${TP}}
  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, ${W1}), 1, ${C1}), FD.array__thaw(U32, ${A2}),
      VB.set_n(${DO}, ${W1}, 1, 1n, ${C1}, {==}, hd32, FD.nat__lt_le_trans(1n, ${Q}, VB.pw(${DO}), {==}, roomA(${NCa})), pfW1(${TWa}))) :
    {${Tp}_pw1(0, ${BX1}, ${Tc}_bx_pvb(${C1}, ${Tc}_bx_putk(_, U32.add(0, ${C1}), ${BX2}))) == ${RP} : ${TP}}
  %Equal.sym(${TPc}, ${Tc}_putn(FD.array__thaw(U32, ${A2}), U32.add(0, ${C1}), ${B_['OBJ']}), (FD.array__thaw(U32, ${W2}), (${B_['OBJ']}, ${S2})),
      IW.putw(${B_['WA']}, ${DO}, ${A2}, ${P2}, N2, T2, U32.add(0, ${C1}), eP2(N1, c1, ec1, hc1), pfA2(${TWa}), hd, hR2(${NCa}), dw2, c2, pfT2, hdw2, ec2, hc2, hroom2)) :
    {${Tp}_pw1(0, ${BX1}, ${Tc}_bx_pvb(${C1}, ${Tc}_bx_pk_back(_))) == ${RP} : ${TP}}
  %Equal.sym(U32, O.padd(${C1}, ${S2}), ${C2}, paddC2(${NCa})) : {(FD.array__thaw(U32, ${W2}), (${OBJ}, _)) == ${RP} : ${TP}}
  {==}

@@ _ae_size_put_eval_3 @@

# The encoder returns the object and the buffer of AW2, C2 bytes.
def encode_eval(${ALLP})
    -> {${Tp}_encode(${OBJ}) == ${RE} : ${TE}}:
  %Equal.sym(${Tp} & U32, ${Tp}_size(${OBJ}), ${RS}, size_eval(${ALLa})) :
    {${Tp}_enc_sized(_) == ${RE} : ${TE}}
  %Equal.sym(Bool, O.is_poisoned(${C2}), False{}, npC2(${NCa})) :
    {${Tp}_enc_go(_, ${C2}, ${OBJ}) == ${RE} : ${TE}}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu(${C2}))), Array.new(U32, ${DO}, 0),
      zeros_at(B.words_depth_u(VC.nwu(${C2})), ${DO}, VD.wdu(VC.nwu(${C2})), hDO(${NCa}))) :
    {${Tp}_enc_put(${C2}, ${Tp}_putn(_, 0, ${OBJ})) == ${RE} : ${TE}}
  %Equal.sym(Array<U32>, Array.new(U32, ${DO}, 0), FD.array__thaw(U32, VC.ZT(${DO})), FD.array__new(U32, ${DO}, 0)) :
    {${Tp}_enc_put(${C2}, ${Tp}_putn(_, 0, ${OBJ})) == ${RE} : ${TE}}
  %Equal.sym(${TP}, ${Tp}_putn(FD.array__thaw(U32, VC.ZT(${DO})), 0, ${OBJ}), ${RP}, put_eval(${ALLa})) :
    {${Tp}_enc_put(${C2}, _) == ${RE} : ${TE}}
  {==}

@@ _ae_window_laws @@
def w0(${WPAR}) -> {${win('1n', '0n')} == [8] : ${LT}}:
  +hd = hdd(${NCa})
  Equal.trans(${LT}, ${win('1n', '0n')}, ${win('1n', '0n', A2)}, [8], IW.ow_hi(${IWc2}, 1n, 0n, {==}),
    Equal.trans(${LT}, ${win('1n', '0n', A2)}, ${win('1n', '0n', W1)}, [8], V2.peel_hi([${C1}], ${DO}, ${W1}, 1n, 1n, 0n, pfW1(${TWa}), ${hb2}, {==}),
      Equal.trans(${LT}, ${win('1n', '0n', W1)}, ${win('1n', '0n', A1)}, [8], IW.ow_hi(${IWc1}, 1n, 0n, {==}),
        V2.own([8], ${DO}, VC.ZT(${DO}), 0n, pf0(N1, N2), hQ(Nat.add(1n, 0n), ${NCa}, {==})))))

def w1(${WPAR}) -> {${win('1n', '1n')} == [${C1}] : ${LT}}:
  +hd = hdd(${NCa})
  Equal.trans(${LT}, ${win('1n', '1n')}, ${win('1n', '1n', A2)}, [${C1}], IW.ow_hi(${IWc2}, 1n, 1n, {==}),
    V2.own([${C1}], ${DO}, ${W1}, 1n, pfW1(${TWa}), ${hb2}))

def wA(${WPAR}) -> {${win(X1, '2n')} == ${RA} : ${LT}}:
  +hd = hdd(${NCa})
  Equal.trans(${LT}, ${win(X1, '2n')}, ${win(X1, '2n', A2)}, ${RA}, IW.ow_hi(${IWc2}, ${X1}, 2n, ${hmA}),
    Equal.trans(${LT}, ${win(X1, '2n', A2)}, ${win(X1, '2n', W1)}, ${RA}, V2.peel_lo([${C1}], ${DO}, ${W1}, 1n, ${X1}, 2n, pfW1(${TWa}), ${hb2}, {==}),
      IW.winw(${IWc1}, dw1, c1, pfT1, hdw1, ec1, hc1, hroom1)))

def wB(${WPAR}) -> {${win(X2, P2)} == ${RBw} : ${LT}}:
  +hd = hdd(${NCa})
  IW.winw(${IWc2}, dw2, c2, pfT2, hdw2, ec2, hc2, hroom2)

@@ _ae_spec_bytes @@
# The bytes of one ${n} value: its header words and its list's words.
def YY(${wsY}, +k: Nat, +W: List<&2, U32>) -> +List<U32>: F.limbs(${hdrY} <> ${YS})

def VAL(${A_['WS']}, ${B_['WS']}, +c1: Nat, +c2: Nat, +W1: List<&2, U32>, +W2: List<&2, U32>) -> S.Value: ${VALs}

def fit2(${SPP}) -> {N.fits(4n, Nat.add(8n, List.length(&2, U32, List.append(&2, U32, ${y1}, ${y2})))) == True{} : Bool}:
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, ${y1}, ${y2})), Nat.add(List.length(&2, U32, ${y1}), List.length(&2, U32, ${y2})), VS.len_app(${y1}, ${y2})) :
    {N.fits(4n, Nat.add(8n, _)) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, ${y1}), Nat.add(${FS}n, VS.x8(c1)), IW.lenY(${A_['WA']}, c1, W1, hl1)) :
    {N.fits(4n, Nat.add(8n, Nat.add(_, List.length(&2, U32, ${y2})))) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, ${y2}), Nat.add(${FS}n, VS.x8(c2)), IW.lenY(${B_['WA']}, c2, W2, hl2)) :
    {N.fits(4n, Nat.add(8n, Nat.add(Nat.add(${FS}n, VS.x8(c1)), _))) == True{} : Bool}
  VFT.fits4(${FA + 1}n, Nat.add(8n, Nat.add(Nat.add(${FS}n, VS.x8(c1)), Nat.add(${FS}n, VS.x8(c2)))),
    VN.le_q4(Nat.add(${FS}n, VS.x8(c1)), Nat.add(${FS}n, VS.x8(c2)), FD.spec_common__pow2(${FA}n),
      FD.nat__le_trans(Nat.add(${FS + 4}n, VS.x8(c1)), Nat.add(${FS + 4}n, VS.x8(${LIMN})), FD.spec_common__pow2(${FA}n), Order.add_left(${FS + 4}n, VS.x8(c1), VS.x8(${LIMN}), VS.x8_mono(c1, ${LIMN}, hc1)), ${K_FA}),
      FD.nat__le_trans(Nat.add(${FS + 4}n, VS.x8(c2)), Nat.add(${FS + 4}n, VS.x8(${LIMN})), FD.spec_common__pow2(${FA}n), Order.add_left(${FS + 4}n, VS.x8(c2), VS.x8(${LIMN}), VS.x8_mono(c2, ${LIMN}, hc2)), ${K_FA})),
    {==})

def eL(${SPP}) -> {U32.to_nat(${C1}) == Nat.add(8n, List.length(&2, U32, ${y1})) : Nat}:
  Equal.trans(Nat, U32.to_nat(${C1}), Nat.add(8n, Nat.add(${FS}n, VS.x8(c1))), Nat.add(8n, List.length(&2, U32, ${y1})), eC1x(N1, c1, ec1, hc1),
    Equal.cong(Nat, Nat, z => Nat.add(8n, z), Nat.add(${FS}n, VS.x8(c1)), List.length(&2, U32, ${y1}),
      Equal.sym(Nat, List.length(&2, U32, ${y1}), Nat.add(${FS}n, VS.x8(c1)), IW.lenY(${A_['WA']}, c1, W1, hl1))))

def ed(${SPP}) -> {N.digits(4n, Nat.add(8n, List.length(&2, U32, ${y1}))) == I.limb(${C1}) : +List<U32>}:
  VN.ed_g(${C1}, ${y1}, eL(${SPa}))

def e8(+N1: U32) -> {F.limbs([8, ${C1}]) == List.append(&2, U32, N.digits(4n, 8n), I.limb(${C1})) : +List<U32>}:
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(8)), I.limb(8), VG.digits_limb(8)) : {F.limbs([8, ${C1}]) == List.append(&2, U32, _, I.limb(${C1})) : +List<U32>}
  {==}

def sp1(${SPP}) -> {Codec.parts(S.Items{${XEa}, S.Items{${XEb}, S.EmptyItems{}}}, S.Chain{Spec.${n}(), S.Chain{Spec.${n}(), S.End{}}}) == Some{${PLs}} : ${MP}}:
  VS.cat_var(Codec.parts(${XEa}, Spec.${n}()), ${y1}, Codec.parts(S.Items{${XEb}, S.EmptyItems{}}, S.Chain{Spec.${n}(), S.End{}}), [S.Variable{${y2}}],
    IW.partsE(${A_['WA']}, c1, W1, hc1, hl1),
    VS.cat_var(Codec.parts(${XEb}, Spec.${n}()), ${y2}, Codec.parts(S.EmptyItems{}, S.End{}), [], IW.partsE(${B_['WA']}, c2, W2, hc2, hl2), {==}))

def sp2(${SPP}) -> {Layout.encoding(${PLs}) == Some{${RBe}} : ${M}}:
  VN.enc2(${y1}, ${y2}, I.limb(${C1}), F.domain_limbs(${A_['HDR']} <> ${VT(1)}), F.domain_limbs(${B_['HDR']} <> ${VT(2)}), fit2(${SPa}), ed(${SPa}))

# The spec encoding of the container of the two values.
def encS(${SPP})
    -> {Codec.encoding_for_legal_type(Spec.${parent}(), VAL(${A_['WA']}, ${B_['WA']}, c1, c2, W1, W2)) == Some{${RBs}} : ${M}}:
  %Equal.sym(${MP}, Codec.parts(S.Items{${XEa}, S.Items{${XEb}, S.EmptyItems{}}}, S.Chain{Spec.${n}(), S.Chain{Spec.${n}(), S.End{}}}), Some{${PLs}}, sp1(${SPa})) :
    {Codec.bytes(Codec.aggregate(_, None{})) == Some{${RBs}} : ${M}}
  %Equal.sym(${M}, Layout.encoding(${PLs}), Some{${RBe}}, sp2(${SPa})) :
    {Codec.bytes(Codec.one(_, None{})) == Some{${RBs}} : ${M}}
  %e8(N1) : {Some{List.append(&2, U32, _, List.append(&2, U32, ${y1}, ${y2}))} == Some{${RBs}} : ${M}}
  {==}

# The bytes the encoder writes are the spec/codec.bend encoding of the object's value.
def encode_spec(${ALLP})
    -> Decoding.decodes(Spec.${parent}(), ${BT}, VAL(${A_['WA']}, ${B_['WA']}, c1, c2, ${A_['ST']}, ${B_['ST']})):
  Equal.trans(${M}, Codec.encoding_for_legal_type(Spec.${parent}(), VAL(${A_['WA']}, ${B_['WA']}, c1, c2, ${A_['ST']}, ${B_['ST']})), Some{${RB}}, Some{${BT}},
    encS(${A_['WA']}, ${B_['WA']}, ${NCa}, ${A_['ST']}, ${B_['ST']}, E.hl_t(${A_['ALLa']}), E.hl_t(${B_['ALLa']})),
    Equal.cong(+List<U32>, ${M}, z => Some{z}, ${RB}, ${BT}, Equal.sym(+List<U32>, ${BT}, ${RB}, out_eq(${ALLa}))))

@@ as_enc_text @@
def eC1x(+N1: U32, +c1: Nat, +ec1: {U32.to_nat(N1) == VS.x8(c1) : Nat}, +hc1: {Nat.is_le(c1, ${LIMN}) == True{} : Bool})
    -> {U32.to_nat(${C1}) == Nat.add(8n, Nat.add(${FS}n, VS.x8(c1))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(${C1}), Nat.add(8n, U32.to_nat(${S1})), eC1(N1, c1, ec1, hc1)) : {_ == Nat.add(8n, Nat.add(${FS}n, VS.x8(c1))) : Nat}
  %Equal.sym(Nat, U32.to_nat(${S1}), Nat.add(${FS}n, U32.to_nat(N1)), E.eS(N1, c1, ec1, hc1)) : {Nat.add(8n, _) == Nat.add(8n, Nat.add(${FS}n, VS.x8(c1))) : Nat}
  %Equal.sym(Nat, U32.to_nat(N1), VS.x8(c1), ec1) : {Nat.add(8n, Nat.add(${FS}n, _)) == Nat.add(8n, Nat.add(${FS}n, VS.x8(c1))) : Nat}
  {==}
