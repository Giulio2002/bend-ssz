@@ _top_size_chain_flat @@

# The size pass's value is the byte count.
def szS(${P}, +h: {CI.OKT(${OAS}) == ${TRUE}}, +k: Nat, +ek: {k == 28n : Nat}) -> {U32.to_nat(SZS(${OAS})) == ${ENDC} : Nat}:
  ${body}
  c${n - 1}

@@ _top_size_chain_grouped @@

# The size pass's value is the byte count.
def szS(${P}, +h: {CI.OKT(${OAS}) == ${TRUE}}, +k: Nat, +ek: {k == 28n : Nat}) -> {U32.to_nat(SZS(${OAS})) == ${ENDC} : Nat}:
  ${body}
  Equal.trans(Nat, U32.to_nat(SZS(${OAS})), ${NT}, ${ENDC}, ${root}, eN)

@@ _top_putx_law @@

# ---- ${C} at X = 0 ----
def OUTC(${P}) -> FD.array__Tree<U32>: K.PUTC(${MA0})

def putx0(${P}, +h: {CI.OKT(${OAS}) == ${TRUE}}, +k: Nat, +ek: {k == 28n : Nat})
    -> DK.P2(K.RTC(${MA0}), DK.P2(K.BYC(${MA0}), DK.P2(K.PFC(${MA0}), K.SZXC(${MA0})))):
  +es = szS(${OAS}, h, k, ek)
  +el = CI.lenE(${OAS}, h)
  +elc = CI.lenC(${MA0})
  +eLS = Equal.trans(Nat, ${LLC}, ${ENDC}, U32.to_nat(${S}), Equal.trans(Nat, ${LLC}, List.length(&2, U32, ${ENCC}), ${ENDC}, Equal.sym(Nat, List.length(&2, U32, ${ENCC}), ${LLC}, elc), el),
    Equal.sym(Nat, U32.to_nat(${S}), ${ENDC}, es))
  +hS = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(k))) == ${TRUE}}, ${ENDC}, U32.to_nat(${S}), Equal.sym(Nat, U32.to_nat(${S}), ${ENDC}, es), CI.okbk(${OAS}, h, k, ek))
  +eNW = VCN.nw_nat(${S}, k, FD.logic__subst(Nat, z => {Nat.is_lt(z, 29n) == ${TRUE}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==}), hS)
  +nw = VRX.nwn_le(U32.to_nat(${S}), VB.pw(k), hS)
  +nwp = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(VC.nwu(${S})), z) == ${TRUE}}, VB.pw(k), O.pow2n(k), VD.s_pow2_eq(k),
    FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(k)) == ${TRUE}}, WD.NWN(U32.to_nat(${S})), VC.NW(${S}), Equal.sym(Nat, VC.NW(${S}), WD.NWN(U32.to_nat(${S})), eNW), nw))
  +hd = FD.nat__le_lt_trans(${Dd}, k, 29n, VD.wd_min(VC.nwu(${S}), k, nwp), FD.logic__subst(Nat, z => {Nat.is_lt(z, 29n) == ${TRUE}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==}))
  +hcov = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(VC.nwu(${S})), z) == ${TRUE}}, O.pow2n(${Dd}), VB.pw(${Dd}), Equal.sym(Nat, VB.pw(${Dd}), O.pow2n(${Dd}), VD.s_pow2_eq(${Dd})),
    VD.wd_cover(VC.nwu(${S}), k, FD.logic__subst(Nat, z => {Nat.is_le(z, 32n) == ${TRUE}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==}), nwp))
  +hl0 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(${Dd})) == ${TRUE}}, VC.NW(${S}), WD.NWN(U32.to_nat(${S})), eNW, hcov)
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(WD.NWN(z), VB.pw(${Dd})) == ${TRUE}}, U32.to_nat(${S}), ${LLC}, Equal.sym(Nat, ${LLC}, U32.to_nat(${S}), eLS), hl0)
  +pf0 = FD.array__trep_perfect(U32, ${Dd}, 0)
  +m = Nat.add(${LLC}, WD.PADB(0n, ${LLC}))
  +hm = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(${Dd}))) == ${TRUE}}, A.quad(WD.NWN(${LLC})), m, Equal.sym(Nat, m, A.quad(WD.NWN(${LLC})), VCN.padb_id(0n, ${LLC})),
    VCN.VME4(WD.NWN(${LLC}), VB.pw(${Dd}), hl))
  +hz = FD.logic__subst(+List<U32>, z => {VS.bt(m, VS.bdr(Nat.add(A.quad(0n), 0n), z)) == UW.ZB(m) : +List<U32>}, UW.ZB(A.quad(VB.pw(${Dd}))), UA.BYT(VC.ZT(${Dd})),
    Equal.sym(+List<U32>, UA.BYT(VC.ZT(${Dd})), UW.ZB(A.quad(VB.pw(${Dd}))), UWB.zt_bytes(${Dd})), VE2.bt_zb_le(m, A.quad(VB.pw(${Dd})), hm))
  K.putx(${OAS}, ${HAC}, ${Dd}, VC.ZT(${Dd}), 0, 0n, 0n, {==}, {==}, hd, hl, pf0, hz)

def eval_go(${P}, +h: {CI.OKT(${OAS}) == ${TRUE}})
    -> {T.${C}_encode(${OBJ}) == (${OBJ}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}:
  +g = putx0(${OAS}, h, 28n, {==})
  +rt = CI.PA(K.RTC(${MA0}), DK.P2(K.BYC(${MA0}), DK.P2(K.PFC(${MA0}), K.SZXC(${MA0}))), g)
  %Equal.sym(T.${C} & U32, T.${C}_size(${OBJ}), (${OBJ}, ${S}), sizeC(${OAS}, h)) :
    {T.${C}_enc_sized(_) == (${OBJ}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu(${S}))), Array.new(U32, ${Dd}, 0),
      FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.nwu(${S}))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.nwu(${S}))), ${Dd}, VD.wdu(VC.nwu(${S})), VZG.zg(B.words_depth_u(VC.nwu(${S}))))) :
    {T.${C}_enc_put(${S}, T.${C}_putn(_, 0, ${OBJ})) == (${OBJ}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}
  %Equal.sym(Array<U32>, Array.new(U32, ${Dd}, 0), FD.array__thaw(U32, VC.ZT(${Dd})), FD.array__new(U32, ${Dd}, 0)) :
    {T.${C}_enc_put(${S}, T.${C}_putn(_, 0, ${OBJ})) == (${OBJ}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}
  %Equal.sym(${RTT}, T.${C}_putn(FD.array__thaw(U32, VC.ZT(${Dd})), 0, ${OBJ}), (FD.array__thaw(U32, K.PUTC(${MA0})), (${OBJ}, K.SZC(${OAS}))), rt) :
    {T.${C}_enc_put(${S}, _) == (${OBJ}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}
  {==}

# The output's first bytes, as many as the size, are the container's bytes.
def obytes(${P}, +h: {CI.OKT(${OAS}) == ${TRUE}}, +k: Nat, +ek: {k == 28n : Nat}) -> {VS.bt(U32.to_nat(${S}), FX.limbs(FD.array__slots(U32, ${OUT}))) == ${ENCC} : +List<U32>}:
  +es = szS(${OAS}, h, k, ek)
  +el = CI.lenE(${OAS}, h)
  +g = putx0(${OAS}, h, k, ek)
  +by = CI.PA(K.BYC(${MA0}), DK.P2(K.PFC(${MA0}), K.SZXC(${MA0})), CI.PB(K.RTC(${MA0}), DK.P2(K.BYC(${MA0}), DK.P2(K.PFC(${MA0}), K.SZXC(${MA0}))), g))
  +Y = VCN.AP(${ENCC}, UW.ZB(WD.PADB(0n, ${LLC})))
  +R = VS.bdr(VCN.LN(Y), UA.BYT(VC.ZT(${Dd})))
  +e1 = Equal.trans(+List<U32>, UA.BYT(${OUT}), VCN.AP(Y, R), VCN.AP(${ENCC}, VCN.AP(UW.ZB(WD.PADB(0n, ${LLC})), R)), by, VS.app_assoc(${ENCC}, UW.ZB(WD.PADB(0n, ${LLC})), R))
  +eN = Equal.trans(Nat, U32.to_nat(${S}), ${ENDC}, VCN.LN(${ENCC}), es, Equal.sym(Nat, VCN.LN(${ENCC}), ${ENDC}, el))
  %Equal.sym(Nat, U32.to_nat(${S}), VCN.LN(${ENCC}), eN) : {VS.bt(_, FX.limbs(FD.array__slots(U32, ${OUT}))) == ${ENCC} : +List<U32>}
  %Equal.sym(+List<U32>, UA.BYT(${OUT}), VCN.AP(${ENCC}, VCN.AP(UW.ZB(WD.PADB(0n, ${LLC})), R)), e1) : {VS.bt(VCN.LN(${ENCC}), _) == ${ENCC} : +List<U32>}
  VRX.bt_all(${ENCC}, VCN.AP(UW.ZB(WD.PADB(0n, ${LLC})), R))

def spec_go(${P}, +h: {CI.OKT(${OAS}) == ${TRUE}})
    -> Decoding.decodes(Spec.${C}(), VS.bt(U32.to_nat(${S}), FX.limbs(FD.array__slots(U32, ${OUT}))), CI.VALC(${OAS})):
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(CI.VALC(${OAS}), Spec.${C}()), Some{[S.Variable{${ENCC}}]}, CI.encx_spec(CI.MW{${OAS}}, h)) :
    {Codec.bytes(_) == Some{VS.bt(U32.to_nat(${S}), FX.limbs(FD.array__slots(U32, ${OUT})))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, VS.bt(U32.to_nat(${S}), FX.limbs(FD.array__slots(U32, ${OUT}))), ${ENCC}, obytes(${OAS}, h, 28n, {==})) :
    {Some{${ENCC}} == Some{_} : Maybe<&2, +List<U32>>}
  {==}

# ---- the laws, on the container's mirror ----
def SZSM(m: CI.MW) -> U32:
  match m:
    case CI.MW{${', '.join(('+' + x for x in OA))}}: SZS(${OAS})
def OUTE(m: CI.MW) -> FD.array__Tree<U32>:
  match m:
    case CI.MW{${', '.join(('+' + x for x in OA))}}: OUTC(${OAS})

# The encoder returns the object and the buffer of OUTE(m), its bytes.
law encode_eval:
  for +m: CI.MW
  for +hok: {CI.OK(m) == ${TRUE}}
  {T.${C}_encode(CI.TH(m)) == (CI.TH(m), B.Buf{FD.array__thaw(U32, OUTE(m)), SZSM(m)}) : T.${C} & B.Buf}
def encode_eval(m, hok):
  match m:
    case CI.MW{${', '.join(('+' + x for x in OA))}}: eval_go(${OAS}, hok)

# The buffer's bytes are the spec encoding of the object's value.
law encode_spec:
  for +m: CI.MW
  for +hok: {CI.OK(m) == ${TRUE}}
  Decoding.decodes(Spec.${C}(), VS.bt(U32.to_nat(SZSM(m)), FX.limbs(FD.array__slots(U32, OUTE(m)))), CI.VAL(m))
def encode_spec(m, hok):
  match m:
    case CI.MW{${', '.join(('+' + x for x in OA))}}: spec_go(${OAS}, hok)

@@ valid_text @@

# ---- ${C}: the runtime's validity pass ----
def validC(${P}, +h: {CI.OKT(${OAS}) == ${TRUE}}) -> {${start} == ${end} : ${RT}}:
${rw}  ${chain(0, first)}

@@ szsz @@

# the size pass and the writer return the same size
def szsz(m: CI.MW, +hok: {CI.OK(m) == True{} : Bool}) -> {U32.to_nat(SZSM(m)) == U32.to_nat(CI.SZ(m)) : Nat}:
  match m:
    case ${pat}: Equal.trans(Nat, U32.to_nat(SZS(${OAS})), CI.ENDCs(${OAS}, ${UF}), U32.to_nat(K.SZC(${OAS})), szS(${OAS}, hok, 28n, {==}),
      Equal.sym(Nat, U32.to_nat(K.SZC(${OAS})), CI.ENDCs(${OAS}, ${UF}), CI.szC(${OAS}, hok, 28n, {==})))

@@ full_texts @@

# ---- the size pass on the container's mirror ----
def SZSM(m: CI.MW) -> U32:
  match m:
    case CI.MW{${pat}}: SZS(${OAS})

law sizex:
  for +m: CI.MW
  for +hok: {CI.OK(m) == ${TRUE}}
  {T.${K.p}_size(CI.TH(m)) == (CI.TH(m), SZSM(m)) : T.${C} & U32}
def sizex(m, hok):
  match m:
    case CI.MW{${pat}}: sizeC(${OAS}, hok)

law szs:
  for +m: CI.MW
  for +hok: {CI.OK(m) == ${TRUE}}
  {U32.to_nat(SZSM(m)) == List.length(&2, U32, CI.ENC(m)) : Nat}
def szs(m, hok):
  match m:
    case CI.MW{${pat}}: Equal.trans(Nat, U32.to_nat(SZS(${OAS})), CI.ENDC(${OAS}), List.length(&2, U32, K.ENCC(${OAS})), szS(${OAS}, hok, 28n, {==}),
      Equal.sym(Nat, List.length(&2, U32, K.ENCC(${OAS})), CI.ENDC(${OAS}), CI.lenE(${OAS}, hok)))

# The size pass returns the writer's size CI.SZ (both are the byte count).
law sizez:
  for +m: CI.MW
  for +hok: {CI.OK(m) == ${TRUE}}
  {T.${K.p}_size(CI.TH(m)) == (CI.TH(m), CI.SZ(m)) : T.${C} & U32}
def sizez(m, hok):
  +e = FD.u32__injective(SZSM(m), CI.SZ(m), Equal.trans(Nat, U32.to_nat(SZSM(m)), List.length(&2, U32, CI.ENC(m)), U32.to_nat(CI.SZ(m)), szs(m, hok),
    Equal.sym(Nat, U32.to_nat(CI.SZ(m)), List.length(&2, U32, CI.ENC(m)), CI.szx(m, hok))))
  FD.logic__subst(U32, z => {T.${K.p}_size(CI.TH(m)) == (CI.TH(m), z) : T.${C} & U32}, SZSM(m), CI.SZ(m), e, sizex(m, hok))

@@ full_texts_validx @@

# The runtime's validity pass accepts the object.
law validx:
  for +m: CI.MW
  for +hok: {CI.OK(m) == ${TRUE}}
  {T.${K.p}_valid(CI.TH(m)) == (CI.TH(m), True{}) : T.${C} & Bool}
def validx(m, hok):
  match m:
    case CI.MW{${pat}}: validC(${OAS}, hok)

@@ body @@

# ---- ${C} at X = 0 of a zero tree ----
def OUTE(+m: CI.MW) -> FD.array__Tree<U32>: CI.PUTX(m, ${Dd}, VC.ZT(${Dd}), 0n, 0n)
def SZSM(+m: CI.MW) -> U32: ${S}

def HL(+m: CI.MW) -> Data: {Nat.is_le(Nat.add(0n, WD.NWN(Nat.add(0n, ${L}))), VB.pw(${Dd})) == ${TRUE}}
def HZ(+m: CI.MW) -> Data:
  {VS.bt(Nat.add(${L}, CI.PADB(0n, m)), VS.bdr(Nat.add(A.quad(0n), 0n), UA.BYT(VC.ZT(${Dd})))) == UW.ZB(Nat.add(${L}, CI.PADB(0n, m))) : +List<U32>}
def HD(+m: CI.MW) -> Data: {Nat.is_lt(${Dd}, 29n) == ${TRUE}}

def mk3(+m: CI.MW, +a: HD(m), +b: HL(m), +c: HZ(m)) -> DK.P2(HD(m), DK.P2(HL(m), HZ(m))): (a, (b, c))

# the writer's hypotheses at X = 0 of the zero tree of the size's depth
def room(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}}, +k: Nat, +ek: {k == 28n : Nat}) -> DK.P2(HD(m), DK.P2(HL(m), HZ(m))):
  +es = CI.szx(m, hok)
  +hS = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(k))) == ${TRUE}}, ${L}, U32.to_nat(${S}), Equal.sym(Nat, U32.to_nat(${S}), ${L}, es), CI.bndx(m, hok, k, ek))
  +eNW = VCN.nw_nat(${S}, k, FD.logic__subst(Nat, z => {Nat.is_lt(z, 29n) == ${TRUE}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==}), hS)
  +nw = VRX.nwn_le(U32.to_nat(${S}), VB.pw(k), hS)
  +nwp = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(VC.nwu(${S})), z) == ${TRUE}}, VB.pw(k), O.pow2n(k), VD.s_pow2_eq(k),
    FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(k)) == ${TRUE}}, WD.NWN(U32.to_nat(${S})), VC.NW(${S}), Equal.sym(Nat, VC.NW(${S}), WD.NWN(U32.to_nat(${S})), eNW), nw))
  +hd = FD.nat__le_lt_trans(${Dd}, k, 29n, VD.wd_min(VC.nwu(${S}), k, nwp), FD.logic__subst(Nat, z => {Nat.is_lt(z, 29n) == ${TRUE}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==}))
  +hcov = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(VC.nwu(${S})), z) == ${TRUE}}, O.pow2n(${Dd}), VB.pw(${Dd}), Equal.sym(Nat, VB.pw(${Dd}), O.pow2n(${Dd}), VD.s_pow2_eq(${Dd})),
    VD.wd_cover(VC.nwu(${S}), k, FD.logic__subst(Nat, z => {Nat.is_le(z, 32n) == ${TRUE}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==}), nwp))
  +hl0 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(${Dd})) == ${TRUE}}, VC.NW(${S}), WD.NWN(U32.to_nat(${S})), eNW, hcov)
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(WD.NWN(z), VB.pw(${Dd})) == ${TRUE}}, U32.to_nat(${S}), ${L}, es, hl0)
  +M = Nat.add(${L}, WD.PADB(0n, ${L}))
  +hm = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(${Dd}))) == ${TRUE}}, A.quad(WD.NWN(${L})), M, Equal.sym(Nat, M, A.quad(WD.NWN(${L})), VCN.padb_id(0n, ${L})),
    VCN.VME4(WD.NWN(${L}), VB.pw(${Dd}), hl))
  +hz = FD.logic__subst(+List<U32>, z => {VS.bt(M, VS.bdr(Nat.add(A.quad(0n), 0n), z)) == UW.ZB(M) : +List<U32>}, UW.ZB(A.quad(VB.pw(${Dd}))), UA.BYT(VC.ZT(${Dd})),
    Equal.sym(+List<U32>, UA.BYT(VC.ZT(${Dd})), UW.ZB(A.quad(VB.pw(${Dd}))), UWB.zt_bytes(${Dd})), VE2.bt_zb_le(M, A.quad(VB.pw(${Dd})), hm))
  mk3(m, hd, hl, hz)
@ROOMF
def RT0(+m: CI.MW) -> Data: {T.${C}_putk(FD.array__thaw(U32, VC.ZT(${Dd})), 0, ${TH}) == (FD.array__thaw(U32, ${OUT}), (${TH}, ${S})) : ${RTT}}

def rt0(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}}, +g: DK.P2(HD(m), DK.P2(HL(m), HZ(m)))) -> RT0(m):
  +hd = CI.PA(HD(m), DK.P2(HL(m), HZ(m)), g)
  +hl = CI.PA(HL(m), HZ(m), CI.PB(HD(m), DK.P2(HL(m), HZ(m)), g))
  +hz = CI.PB(HL(m), HZ(m), CI.PB(HD(m), DK.P2(HL(m), HZ(m)), g))
  CI.putx(m, ${Dd}, VC.ZT(${Dd}), 0, 0n, 0n, {==}, {==}, hd, FD.array__trep_perfect(U32, ${Dd}, 0), hl, hz, hok)

def BY0(+m: CI.MW) -> Data: {UA.BYT(${OUT}) == UW.SPL(UA.BYT(VC.ZT(${Dd})), Nat.add(A.quad(0n), 0n), List.append(&2, U32, CI.ENC(m), UW.ZB(CI.PADB(0n, m)))) : +List<U32>}

def by0(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}}, +g: DK.P2(HD(m), DK.P2(HL(m), HZ(m)))) -> BY0(m):
  +hd = CI.PA(HD(m), DK.P2(HL(m), HZ(m)), g)
  +hl = CI.PA(HL(m), HZ(m), CI.PB(HD(m), DK.P2(HL(m), HZ(m)), g))
  +hz = CI.PB(HL(m), HZ(m), CI.PB(HD(m), DK.P2(HL(m), HZ(m)), g))
  CI.putx_bytes(m, ${Dd}, VC.ZT(${Dd}), 0, 0n, 0n, {==}, {==}, hd, FD.array__trep_perfect(U32, ${Dd}, 0), hl, hz, hok)

@EVALF
def eval_go(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}})
    -> {T.${C}_encode(${TH}) == (${TH}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}:
  +rt = rt0(m, hok, room(m, hok, 28n, {==}))
  %Equal.sym(T.${C} & U32, T.${C}_size(${TH}), (${TH}, ${S}), ${SZX}(m, hok)) :
    {T.${C}_enc_sized(_) == (${TH}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu(${S}))), Array.new(U32, ${Dd}, 0),
      FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.nwu(${S}))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.nwu(${S}))), ${Dd}, VD.wdu(VC.nwu(${S})), VZG.zg(B.words_depth_u(VC.nwu(${S}))))) :
    {T.${C}_enc_put(${S}, T.${C}_putn(_, 0, ${TH})) == (${TH}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}
  %Equal.sym(Array<U32>, Array.new(U32, ${Dd}, 0), FD.array__thaw(U32, VC.ZT(${Dd})), FD.array__new(U32, ${Dd}, 0)) :
    {T.${C}_enc_put(${S}, T.${C}_putn(_, 0, ${TH})) == (${TH}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}
  %Equal.sym(${RTT}, T.${C}_putk(FD.array__thaw(U32, VC.ZT(${Dd})), 0, ${TH}), (FD.array__thaw(U32, ${OUT}), (${TH}, ${S})), rt) :
    {T.${C}_enc_put(${S}, _) == (${TH}, B.Buf{FD.array__thaw(U32, ${OUT}), ${S}}) : T.${C} & B.Buf}
  {==}

# The output's first bytes, as many as the size, are the container's bytes.
def obytes(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}}) -> {VS.bt(U32.to_nat(${S}), FX.limbs(FD.array__slots(U32, ${OUT}))) == CI.ENC(m) : +List<U32>}:
  +by = by0(m, hok, room(m, hok, 28n, {==}))
  +P = UW.ZB(CI.PADB(0n, m))
  +R = VS.bdr(VCN.LN(VCN.AP(CI.ENC(m), P)), UA.BYT(VC.ZT(${Dd})))
  +e1 = Equal.trans(+List<U32>, UA.BYT(${OUT}), VCN.AP(VCN.AP(CI.ENC(m), P), R), VCN.AP(CI.ENC(m), VCN.AP(P, R)), by, VS.app_assoc(CI.ENC(m), P, R))
  %Equal.sym(Nat, U32.to_nat(${S}), VCN.LN(CI.ENC(m)), CI.szx(m, hok)) : {VS.bt(_, FX.limbs(FD.array__slots(U32, ${OUT}))) == CI.ENC(m) : +List<U32>}
  %Equal.sym(+List<U32>, UA.BYT(${OUT}), VCN.AP(CI.ENC(m), VCN.AP(P, R)), e1) : {VS.bt(VCN.LN(CI.ENC(m)), _) == CI.ENC(m) : +List<U32>}
  VRX.bt_all(CI.ENC(m), VCN.AP(P, R))

# The encoder returns the object and the buffer of OUTE(m), its bytes.
law encode_eval:
  for +m: CI.MW
  for +hok: {CI.OK(m) == ${TRUE}}
  {T.${C}_encode(CI.TH(m)) == (CI.TH(m), B.Buf{FD.array__thaw(U32, OUTE(m)), SZSM(m)}) : T.${C} & B.Buf}
def encode_eval(m, hok): eval_go(m, hok)

# The buffer's bytes are the spec encoding of the object's value.
law encode_spec:
  for +m: CI.MW
  for +hok: {CI.OK(m) == ${TRUE}}
  Decoding.decodes(Spec.${C}(), VS.bt(U32.to_nat(SZSM(m)), FX.limbs(FD.array__slots(U32, OUTE(m)))), CI.VAL(m))
def encode_spec(m, hok):
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(CI.VAL(m), Spec.${C}()), Some{[S.Variable{CI.ENC(m)}]}, CI.encx_spec(m, hok)) :
    {Codec.bytes(_) == Some{VS.bt(U32.to_nat(${S}), FX.limbs(FD.array__slots(U32, ${OUT})))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, VS.bt(U32.to_nat(${S}), FX.limbs(FD.array__slots(U32, ${OUT}))), CI.ENC(m), obytes(m, hok)) :
    {Some{CI.ENC(m)} == Some{_} : Maybe<&2, +List<U32>>}
  {==}

@@ roomf @@

# the fixed depth ${fixd}: the bytes within its ${4 * 2 ** fixd} (CI.maxx: at most ${MX})
def roomf(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}}) -> DK.P2(HD(m), DK.P2(HL(m), HZ(m))):
  +hq = FD.nat__le_trans(${L_}, ${MX}n, A.quad(VB.pw(${Dd})), CI.maxx(m, hok), {==})
  +hl = VRX.nwn_le(${L_}, VB.pw(${Dd}), hq)
  +M = Nat.add(${L_}, WD.PADB(0n, ${L_}))
  +hm = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(${Dd}))) == ${TRUE}}, A.quad(WD.NWN(${L_})), M, Equal.sym(Nat, M, A.quad(WD.NWN(${L_})), VCN.padb_id(0n, ${L_})),
    VCN.VME4(WD.NWN(${L_}), VB.pw(${Dd}), hl))
  +hz = FD.logic__subst(+List<U32>, z => {VS.bt(M, VS.bdr(Nat.add(A.quad(0n), 0n), z)) == UW.ZB(M) : +List<U32>}, UW.ZB(A.quad(VB.pw(${Dd}))), UA.BYT(VC.ZT(${Dd})),
    Equal.sym(+List<U32>, UA.BYT(VC.ZT(${Dd})), UW.ZB(A.quad(VB.pw(${Dd}))), UWB.zt_bytes(${Dd})), VE2.bt_zb_le(M, A.quad(VB.pw(${Dd})), hm))
  mk3(m, {==}, hl, hz)

@@ evalf @@

# the size under the mask 0x7fffffff: below 2^${kb} (CI.szx, CI.maxx)
def a31(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}}) -> {U32.and(${S}, 2147483647) == ${S} : U32}:
  +hs = FD.logic__subst(Nat, z => {Nat.is_le(z, ${MX}n) == ${TRUE}}, ${L_}, U32.to_nat(${S}), Equal.sym(Nat, U32.to_nat(${S}), ${L_}, CI.szx(m, hok)), CI.maxx(m, hok))
  VBE.and31(${S}, ${kb}n, {==}, FD.nat__le_lt_trans(U32.to_nat(${S}), ${MX}n, FD.spec_common__pow2(${kb}n), hs, {==}))

def eval_go(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}})
    -> {T.${C}_encode(${TH}) == (${TH}, ${OUTB}) : T.${C} & B.Buf}:
  +rt = rt0(m, hok, roomf(m, hok))
  %Equal.sym(Array<U32>, Array.new(U32, ${Dd}, 0), FD.array__thaw(U32, VC.ZT(${Dd})), FD.array__new(U32, ${Dd}, 0)) :
    {T.${C}_enc_put(T.${C}_putn(_, 0, ${TH})) == (${TH}, ${OUTB}) : T.${C} & B.Buf}
  %Equal.sym(${RTT}, T.${C}_putk(FD.array__thaw(U32, VC.ZT(${Dd})), 0, ${TH}), (FD.array__thaw(U32, ${OUT}), (${TH}, ${S})), rt) :
    {T.${C}_enc_put(_) == (${TH}, ${OUTB}) : T.${C} & B.Buf}
  %Equal.sym(U32, U32.and(${S}, 2147483647), ${S}, a31(m, hok)) :
    {(${TH}, B.Buf{FD.array__thaw(U32, ${OUT}), _}) == (${TH}, ${OUTB}) : T.${C} & B.Buf}
  {==}

def eval_go_sized(+m: CI.MW, +hok: {CI.OK(m) == ${TRUE}})

@@ _top_size_chain_flat_lines @@
+bnd = CI.okbk(${OAS}, h, k, ek)
+hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, 29n) == ${TRUE}}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==})
+b${n} = bnd