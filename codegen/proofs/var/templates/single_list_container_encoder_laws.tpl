@@ _em_object_laws @@

def leN(${NC}) -> {Nat.is_le(${toN}, VS.x8(${LIMN})) == True{} : Bool}:
  %Equal.sym(Nat, ${toN}, VS.x8(c), ec) : {Nat.is_le(_, VS.x8(${LIMN})) == True{} : Bool}
  VS.x8_mono(c, ${LIMN}, hc)

def padd(${NC}) -> {O.padd(${FS}, N) == SFS(N) : U32}:
  VE.padd_ok(${FS}, N, VE.winit(31n, VE.bits32(${FS})), VE.winit(31n, VE.bits32(N)), {==},
    VE.small_pad(N, ${PB}n, {==}, FD.nat__le_lt_trans(${toN}, VS.x8(${LIMN}), VB.pw(${PB}n), leN(${NCa}), ${K_PB})))

def eS(${NC}) -> {U32.to_nat(SFS(N)) == Nat.add(${FS}n, ${toN}) : Nat}:
  A.add_le(${FS}, N, ${BS}, FD.nat__le_trans(Nat.add(${FS}n, ${toN}), Nat.add(${FS}n, VS.x8(${LIMN})), U32.to_nat(${BS}),
    Order.add_left(${FS}n, ${toN}, VS.x8(${LIMN}), leN(${NCa})), ${K_ES}))

def hyN(${NC}) -> {Nat.is_le(VC.YL(N), VB.pw(${P2}n)) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(31n, ${toN}), Nat.add(31n, VS.x8(${LIMN})), VB.pw(${P2}n), Order.add_left(31n, ${toN}, VS.x8(${LIMN}), leN(${NCa})), ${K_YN})

def hyS(${NC}) -> {Nat.is_le(VC.YL(SFS(N)), VB.pw(${P2}n)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(SFS(N)), Nat.add(${FS}n, ${toN}), eS(${NCa})) : {Nat.is_le(Nat.add(31n, _), VB.pw(${P2}n)) == True{} : Bool}
  FD.nat__le_trans(Nat.add(31n, Nat.add(${FS}n, ${toN})), Nat.add(31n, Nat.add(${FS}n, VS.x8(${LIMN}))), VB.pw(${P2}n),
    Order.add_left(31n, Nat.add(${FS}n, ${toN}), Nat.add(${FS}n, VS.x8(${LIMN})), Order.add_left(${FS}n, ${toN}, VS.x8(${LIMN}), leN(${NCa}))), ${K_YS})

def npS(${NC}) -> {O.is_poisoned(SFS(N)) == False{} : Bool}:
  VE.np31y(SFS(N), ${P2}n, {==}, hyS(${NCa}))

def nwN(${NC}) -> {VC.NW(N) == Nat.double(c) : Nat}:
  %Equal.sym(Nat, VC.NW(N), VD.s_rng(2n, 3n+${toN}), VC.eNW(N, ${P2}n, {==}, hyN(${NCa}))) : {_ == Nat.double(c) : Nat}
  %Equal.sym(Nat, ${toN}, VS.x8(c), ec) : {VD.s_rng(2n, 3n+_) == Nat.double(c) : Nat}
  VC.rng2_x8(c)

def nwS(${NC}) -> {VC.NW(SFS(N)) == ${H}n+Nat.double(c) : Nat}:
  %Equal.sym(Nat, VC.NW(SFS(N)), VD.s_rng(2n, 3n+U32.to_nat(SFS(N))), VC.eNW(SFS(N), ${P2}n, {==}, hyS(${NCa}))) : {_ == ${H}n+Nat.double(c) : Nat}
  %Equal.sym(Nat, U32.to_nat(SFS(N)), Nat.add(${FS}n, ${toN}), eS(${NCa})) : {VD.s_rng(2n, 3n+_) == ${H}n+Nat.double(c) : Nat}
  %Equal.sym(Nat, ${toN}, VS.x8(c), ec) : {VD.s_rng(2n, ${3 + FS}n+_) == ${H}n+Nat.double(c) : Nat}
  Equal.cong(Nat, Nat, z => ${H}n+z, VD.s_rng(2n, 3n+VS.x8(c)), Nat.double(c), VC.rng2_x8(c))

def leKO(${NC}) -> {Nat.is_le(${H}n+Nat.double(c), O.pow2n(${KO}n)) == True{} : Bool}:
  FD.nat__le_trans(${H}n+Nat.double(c), ${MKO}, O.pow2n(${KO}n),
    Order.add_left(${H}n, Nat.double(c), Nat.double(${LIMN}), FD.nat__double_le(c, ${LIMN}, hc)), ${K_KO})

def leW(${NC}) -> {Nat.is_le(U32.to_nat(VC.nwu(SFS(N))), O.pow2n(${KO}n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(${KO}n)) == True{} : Bool}, ${H}n+Nat.double(c), VC.NW(SFS(N)),
    Equal.sym(Nat, VC.NW(SFS(N)), ${H}n+Nat.double(c), nwS(${NCa})), leKO(${NCa}))

def hDOK(${NC}) -> {Nat.is_le(DO(N), ${KO}n) == True{} : Bool}:
  VD.wd_min(VC.nwu(SFS(N)), ${KO}n, leW(${NCa}))

def roomS(${NC}) -> {Nat.is_le(${H}n+Nat.double(c), VB.pw(DO(N))) == True{} : Bool}:
  %Equal.sym(Nat, VB.pw(DO(N)), O.pow2n(DO(N)), VD.s_pow2_eq(DO(N))) : {Nat.is_le(${H}n+Nat.double(c), _) == True{} : Bool}
  %nwS(${NCa}) : {Nat.is_le(_, O.pow2n(DO(N))) == True{} : Bool}
  VD.wd_cover(VC.nwu(SFS(N)), ${KO}n, {==}, leW(${NCa}))

def hDO29(${NC}) -> {Nat.is_lt(DO(N), 29n) == True{} : Bool}:
  FD.nat__le_lt_trans(DO(N), ${KO}n, 29n, hDOK(${NCa}), {==})

def hDO31(${NC}) -> {Nat.is_lt(DO(N), 31n) == True{} : Bool}:
  FD.nat__le_lt_trans(DO(N), ${KO}n, 31n, hDOK(${NCa}), {==})

# a <= H: a <= 2^DO.
def hbk(+a: Nat, ${NC}, +ha: {Nat.is_le(a, ${H}n) == True{} : Bool}) -> {Nat.is_le(a, VB.pw(DO(N))) == True{} : Bool}:
  FD.nat__le_trans(a, ${H}n, VB.pw(DO(N)), ha, FD.nat__le_trans(${H}n, ${H}n+Nat.double(c), VB.pw(DO(N)), Order.below_sum(${H}n, Nat.double(c)), roomS(${NCa})))

def ltH(+k: Nat, ${NC}, +hk: {Nat.is_lt(k, ${H}n) == True{} : Bool}) -> {Nat.is_lt(k, VB.pw(DO(N))) == True{} : Bool}:
  FD.nat__lt_le_trans(k, ${H}n, VB.pw(DO(N)), hk, hbk(${H}n, ${NCa}, {==}))

def hdst(${NC}) -> {Nat.is_le(Nat.add(VC.NW(N), ${H}n), VB.pw(DO(N))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, ${H}n), VB.pw(DO(N))) == True{} : Bool}, Nat.double(c), VC.NW(N), Equal.sym(Nat, VC.NW(N), Nat.double(c), nwN(${NCa})),
    FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(DO(N))) == True{} : Bool}, ${H}n+Nat.double(c), Nat.add(Nat.double(c), ${H}n), FD.nat__add_comm(${H}n, Nat.double(c)), roomS(${NCa})))

def pf0(+N: U32) -> {FD.array__perfect(U32, DO(N), VC.ZT(DO(N))) == True{} : Bool}: FD.array__trep_perfect(U32, DO(N), 0)
def pf1(+N: U32) -> {FD.array__perfect(U32, DO(N), OUT1(N)) == True{} : Bool}: FD.array__upd_perfect(U32, DO(N), VC.ZT(DO(N)), ${po}n, ${FS}, pf0(N))
def pfD0(${WS}, +N: U32, +T: FD.array__Tree<U32>) -> {FD.array__perfect(U32, DO(N), ${TD(0)}) == True{} : Bool}:
  VB.mone_perfect(VC.NW(N), 0n, ${H}n, DO(N), OUT1(N), T, pf1(N))
@@ _em_object_laws_2 @@

def size_eval(${ALLP})
    -> {${Tn}_size(${OBJ}) == ${RS} : ${Tn} & U32}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T)), (FD.array__thaw(U32, T), FD.u32__pow2u(dw)), FD.array__size_thaw(U32, dw, T, pfT)) :
    {${Tn}_sz0(${FIXOBJS}, ${FS}, O.wsz_pick(N, _)) == ${RS} : ${Tn} & U32}
  %Equal.sym(Bool, U32.is_le(VC.nwu(N), FD.u32__pow2u(dw)), True{}, VE.le_room(N, dw, hdw, hroom)) :
    {(${OBJ}, O.padd(${FS}, O.pick(_, N, 4294967295))) == ${RS} : ${Tn} & U32}
  %Equal.sym(U32, O.padd(${FS}, N), SFS(N), padd(${NCa})) : {(${OBJ}, _) == ${RS} : ${Tn} & U32}
  {==}

@@ _em_encode_eval @@

# The encoder returns the object and the buffer of OUT3, ${FS} + N bytes.
def encode_eval(${ALLP})
    -> {${Tn}_encode(${OBJ}) == ${RE} : ${TE}}:
  %Equal.sym(${Tn} & U32, ${Tn}_size(${OBJ}), ${RS}, size_eval(${ALLa})) :
    {${Tn}_enc_sized(_) == ${RE} : ${TE}}
  %Equal.sym(Bool, O.is_poisoned(SFS(N)), False{}, npS(${NCa})) :
    {${Tn}_enc_go(_, SFS(N), ${OBJ}) == ${RE} : ${TE}}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu(SFS(N)))), Array.new(U32, DO(N), 0),
      DC.zeros_at(B.words_depth_u(VC.nwu(SFS(N))), DO(N), VD.wdu(VC.nwu(SFS(N))), FD.nat__le_trans(DO(N), ${KO}n, ${KK}n, hDOK(${NCa}), {==}))) :
    {${Tn}_enc_put(SFS(N), ${Tn}_putn(_, 0, ${OBJ})) == ${RE} : ${TE}}
  %Equal.sym(Array<U32>, Array.new(U32, DO(N), 0), FD.array__thaw(U32, VC.ZT(DO(N))), FD.array__new(U32, DO(N), 0)) :
    {${Tn}_enc_put(SFS(N), ${Tn}_putn(_, 0, ${OBJ})) == ${RE} : ${TE}}
  %Equal.sym(${TP}, ${Tn}_putn(FD.array__thaw(U32, VC.ZT(DO(N))), 0, ${OBJ}), ${RP}, put_eval(${ALLa})) :
    {${Tn}_enc_put(SFS(N), _) == ${RE} : ${TE}}
  {==}

@@ _em_windows @@
Equal.trans(${LT}, VF.WIN(1n, ${po}n, FD.array__slots(U32, OUT2(N, T))), VF.WIN(1n, ${po}n, ${LM}), [${FS}],
    Equal.cong(${LT}, ${LT}, z => VF.WIN(1n, ${po}n, z), FD.array__slots(U32, OUT2(N, T)), ${LM}, VB.slots_mone(${NW}, 0n, ${H}n, DO(N), OUT1(N), T, pf1(N), hdst(${NCa}))),
    Equal.trans(${LT}, VF.WIN(1n, ${po}n, ${LM}), VF.WIN(1n, ${po}n, FD.array__slots(U32, OUT1(N))), [${FS}],
      VF.lm_hi(${NW}, 0n, ${H}n, 1n, ${po}n, FD.array__slots(U32, OUT1(N)), ${ST}, {==}),
      V2.own([${FS}], DO(N), VC.ZT(DO(N)), ${po}n, pf0(N), hbk(Nat.add(1n, ${po}n), ${NCa}, {==}))))
@@ _em_windows_2 @@
Equal.trans(${LT}, VF.WIN(${NW}, ${H}n, FD.array__slots(U32, OUT2(N, T))), VF.WIN(${NW}, ${H}n, ${LM}), VS.wtake(${NW}, ${ST}),
    Equal.cong(${LT}, ${LT}, z => VF.WIN(${NW}, ${H}n, z), FD.array__slots(U32, OUT2(N, T)), ${LM}, VB.slots_mone(${NW}, 0n, ${H}n, DO(N), OUT1(N), T, pf1(N), hdst(${NCa}))),
    VB.lm_win(${NW}, 0n, ${H}n, FD.array__slots(U32, OUT1(N)), ${ST},
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${NW}, ${H}n), z) == True{} : Bool}, VB.pw(DO(N)), VB.len(FD.array__slots(U32, OUT1(N))), Equal.sym(Nat, VB.len(FD.array__slots(U32, OUT1(N))), VB.pw(DO(N)), FD.array__slots_length(U32, DO(N), OUT1(N), pf1(N))), hdst(${NCa})),
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${NW}, 0n), z) == True{} : Bool}, VB.pw(dw), VB.len(${ST}), Equal.sym(Nat, VB.len(${ST}), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hroom)))
@@ _em_spec_side @@
def XE(${WS}, +k: Nat, +W: List<&2, U32>) -> S.Value: S.Sequence{${ITEMS}}

# The spec encoding of the value of words w.. and list words W (k elements).
def encE(${WS}, +k: Nat, +W: List<&2, U32>,
    +hk: {Nat.is_le(k, ${LIMN}) == True{} : Bool},
    +hl: {Nat.is_le(Nat.double(k), FD.spec_common__length(U32, W)) == True{} : Bool})
    -> {Codec.encoding_for_legal_type(Spec.${n}(), XE(${WA}, k, W)) == ${RHSk} : ${M}}:
  +le2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(${LIMN})) == True{} : Bool}, VS.x8(k), List.length(&2, U32, F.limbs(${YS})),
    Equal.sym(Nat, List.length(&2, U32, F.limbs(${YS})), VS.x8(k), VS.len_limbs_wtake2(k, W, hl)), VS.x8_mono(k, ${LIMN}, hk))
  +fit = VS.fits_mono(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, F.limbs(${YS}))), Nat.add(${FS}n, VS.x8(${LIMN})),
    Order.add_left(${FS}n, List.length(&2, U32, F.limbs(${YS})), VS.x8(${LIMN}), le2), ${K_FIT})
  %Equal.sym(${MP}, Codec.parts(${ITEMS}, ${CHAIN}), Some{${PL}},
      ${CAT}) :
    {Codec.bytes(Codec.aggregate(_, None{})) == ${RHSk} : ${M}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, F.limbs(${YS}), ${POST})), Some{${ENCR}}, VS.enc_fpv(${PRE}, ${YS}, ${POST}, fit)) :
    {Codec.bytes(Codec.one(_, None{})) == ${RHSk} : ${M}}
  {==}

def eSq(${NC}) -> {A.quad(${Kx}) == U32.to_nat(SFS(N)) : Nat}:
  %Equal.sym(Nat, ${NW}, Nat.double(c), nwN(${NCa})) : {A.quad(Nat.add(${H}n, _)) == U32.to_nat(SFS(N)) : Nat}
  %Equal.sym(Nat, U32.to_nat(SFS(N)), Nat.add(${FS}n, ${toN}), eS(${NCa})) : {A.quad(Nat.add(${H}n, Nat.double(c))) == _ : Nat}
  %Equal.sym(Nat, ${toN}, VS.x8(c), ec) : {A.quad(Nat.add(${H}n, Nat.double(c))) == Nat.add(${FS}n, _) : Nat}
  %Equal.sym(Nat, VS.x8(c), VB.d3(c), VB.x8_d3(c)) : {A.quad(Nat.add(${H}n, Nat.double(c))) == Nat.add(${FS}n, _) : Nat}
  {==}

# The output's bytes are the limbs of the header words and the list's words.
def out_eq(${ALLP})
    -> {${BT} == ${RHS} : +List<U32>}:
  %eSq(${NCa}) : {VS.bt(_, F.limbs(${S3})) == ${RHS} : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(${Kx}), F.limbs(${S3})), F.limbs(VS.wtake(${Kx}, ${S3})), VS.bt_limbs(${Kx}, ${S3})) :
    {_ == ${RHS} : +List<U32>}
  %Equal.sym(${LT}, VF.WIN(${Kx}, 0n, ${S3}), VF.app(VF.WIN(${H}n, 0n, ${S3}), VF.WIN(${NW}, Nat.add(0n, ${H}n), ${S3})), VF.win_split(${H}n, ${NW}, 0n, ${S3})) :
    {F.limbs(_) == ${RHS} : +List<U32>}
  %Equal.sym(${LT}, VF.WIN(${H}n, 0n, ${S3}), ${HDRL}, hdr_eq(${SPa})) :
    {F.limbs(VF.app(_, VF.WIN(${NW}, ${H}n, ${S3}))) == ${RHS} : +List<U32>}
  %Equal.sym(${LT}, VF.WIN(${NW}, ${H}n, ${S3}), VS.wtake(${NW}, ${ST}), pay_eq(${SPa}, dw, pfT, hroom)) :
    {F.limbs(VF.app(${HDRL}, _)) == ${RHS} : +List<U32>}
  %Equal.sym(Nat, ${NW}, Nat.double(c), nwN(${NCa})) :
    {F.limbs(VF.app(${HDRL}, VS.wtake(_, ${ST}))) == ${RHS} : +List<U32>}
  {==}

def hl_t(${ALLP})
    -> {Nat.is_le(Nat.double(c), FD.spec_common__length(U32, ${ST})) == True{} : Bool}:
  %Equal.sym(Nat, FD.spec_common__length(U32, ${ST}), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)) : {Nat.is_le(Nat.double(c), _) == True{} : Bool}
  %nwN(${NCa}) : {Nat.is_le(_, VB.pw(dw)) == True{} : Bool}
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, Nat.add(${NW}, 0n), ${NW}, FD.nat__add_zero(${NW}), hroom)

# The bytes the encoder writes are the spec/codec.bend encoding of the object's value.
def encode_spec(${ALLP})
    -> Decoding.decodes(Spec.${n}(), ${BT}, XE(${WA}, c, ${ST})):
  Equal.trans(${M}, Codec.encoding_for_legal_type(Spec.${n}(), XE(${WA}, c, ${ST})), Some{${RHS}}, Some{${BT}},
    encE(${WA}, c, ${ST}, hc, hl_t(${ALLa})),
    Equal.cong(+List<U32>, ${M}, z => Some{z}, ${RHS}, ${BT}, Equal.sym(+List<U32>, ${BT}, ${RHS}, out_eq(${ALLa}))))
