@@ enc_text @@
def OBJE(${EP}) -> ${Tn}: ${OBJE}
def SFS(+N: U32) -> U32: U32.add(${FS}, YE.SFS(N))
def ROOM(+N: U32, +P: Nat) -> Nat: YE.ROOM(N, ${PC})
def KZ(+N: U32, +P: Nat) -> Nat: YE.KZ(N, ${PC})
def room_hp(+N: U32, +P: Nat) -> {Nat.is_le(P, ROOM(N, P)) == ${TRUE}}:
  FD.nat__le_trans(P, ${PC}, ROOM(N, P), Order.left_below_sum(${H}n, P), YE.room_hp(N, ${PC}))
def kz_hp(+N: U32, +P: Nat) -> {Nat.is_le(${PC}, KZ(N, P)) == ${TRUE}}:
  FD.nat__le_trans(${PC}, Nat.add(${HY_}n, ${PC}), KZ(N, P), Order.left_below_sum(${HY_}n, ${PC}), YE.kz_hp(N, ${PC}))

# The encoding's size, with the header size symbolic (F = ${FS}, Fn its value).
def eS_g(+F: U32, +Fn: Nat, +eF: {U32.to_nat(F) == Fn : Nat}, +c: U32, +K: Nat, +M: Nat, +MU: U32, +eM: {U32.to_nat(MU) == M : Nat},
    +hc: {Nat.is_le(U32.to_nat(c), K) == ${TRUE}}, +hM: {Nat.is_le(Nat.add(Fn, K), M) == ${TRUE}})
    -> {U32.to_nat(U32.add(F, c)) == Nat.add(Fn, U32.to_nat(c)) : Nat}:
  +h1 = FD.nat__le_trans(Nat.add(Fn, U32.to_nat(c)), Nat.add(Fn, K), M, Order.add_left(Fn, U32.to_nat(c), K, hc), hM)
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(c)), U32.to_nat(MU)) == ${TRUE}}, Fn, U32.to_nat(F), Equal.sym(Nat, U32.to_nat(F), Fn, eF),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Fn, U32.to_nat(c)), z) == ${TRUE}}, M, U32.to_nat(MU), Equal.sym(Nat, U32.to_nat(MU), M, eM), h1))
  Equal.trans(Nat, U32.to_nat(U32.add(F, c)), Nat.add(U32.to_nat(F), U32.to_nat(c)), Nat.add(Fn, U32.to_nat(c)), A.add_le(F, c, MU, h2),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(c)), U32.to_nat(F), Fn, eF))

def eS(+N: U32, ${HN}) -> {U32.to_nat(SFS(N)) == Nat.add(${FS}n, U32.to_nat(YE.SFS(N))) : Nat}:
  eS_g(${FS}, ${FS}n, FD.nat__eq_from_is_eq(U32.to_nat(${FS}), ${FS}n, {==}), YE.SFS(N), ${C.MAX}n, ${MAX}n, ${MAX}, FD.nat__eq_from_is_eq(U32.to_nat(${MAX}), ${MAX}n, {==}),
    YE.hSle(N, hN), {==})

def hSle_g(+s: U32, +Fn: Nat, +c: U32, +K: Nat, +M: Nat, +es: {U32.to_nat(s) == Nat.add(Fn, U32.to_nat(c)) : Nat},
    +hc: {Nat.is_le(U32.to_nat(c), K) == ${TRUE}}, +hM: {Nat.is_le(Nat.add(Fn, K), M) == ${TRUE}}) -> {Nat.is_le(U32.to_nat(s), M) == ${TRUE}}:
  %Equal.sym(Nat, U32.to_nat(s), Nat.add(Fn, U32.to_nat(c)), es) : {Nat.is_le(_, M) == ${TRUE}}
  FD.nat__le_trans(Nat.add(Fn, U32.to_nat(c)), Nat.add(Fn, K), M, Order.add_left(Fn, U32.to_nat(c), K, hc), hM)

def hSle(+N: U32, ${HN}) -> {Nat.is_le(U32.to_nat(SFS(N)), ${MAX}n) == ${TRUE}}:
  hSle_g(SFS(N), ${FS}n, YE.SFS(N), ${C.MAX}n, ${MAX}n, eS(N, hN), YE.hSle(N, hN), {==})

def hS(+N: U32, ${HN}) -> {Nat.is_lt(U32.to_nat(SFS(N)), VB.pw(${KS}n)) == ${TRUE}}:
  FD.nat__le_lt_trans(U32.to_nat(SFS(N)), ${MAX}n, VB.pw(${KS}n), hSle(N, hN), {==})

def paddS(+N: U32, ${HN}) -> {O.padd(${FS}, YE.SFS(N)) == SFS(N) : U32}:
  VE.padd_ok(${FS}, YE.SFS(N), VE.winit(31n, VE.bits32(${FS})), VE.winit(31n, VE.bits32(YE.SFS(N))), {==},
    VE.small_pad(YE.SFS(N), ${C.KS}n, {==}, YE.hS(N, hN)))

# pos + c = 4 (k + P) for a header byte c = 4 k.
def eoc(+k: Nat, +c: U32, +P: Nat, +pos: U32, +dd: Nat, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},
    ${HDD}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hq: {Nat.is_le(A.quad(Nat.add(k, P)), VB.pw(2n+dd)) == ${TRUE}})
    -> {U32.to_nat(U32.add(pos, c)) == A.quad(Nat.add(k, P)) : Nat}:
  VF.off_add(pos, c, P, k, 2n+dd, eP, ec, hdd, hq)

def hHP(+N: U32, +dd: Nat, +P: Nat, ${HDST}) -> {Nat.is_le(${PC}, VB.pw(dd)) == ${TRUE}}:
  FD.nat__le_trans(${PC}, ROOM(N, P), VB.pw(dd), YE.room_hp(N, ${PC}), hdst)

def hb(+W: Nat, +k: Nat, +P: Nat, +dd: Nat, +hWk: {Nat.is_le(Nat.add(W, k), ${H}n) == ${TRUE}},
    +hH: {Nat.is_le(${PC}, VB.pw(dd)) == ${TRUE}}) -> {Nat.is_le(Nat.add(W, Nat.add(k, P)), VB.pw(dd)) == ${TRUE}}:
  %FD.nat__add_assoc(W, k, P) : {Nat.is_le(_, VB.pw(dd)) == ${TRUE}}
  FD.nat__le_trans(Nat.add(Nat.add(W, k), P), ${PC}, VB.pw(dd), Order.add_right(Nat.add(W, k), ${H}n, P, hWk), hH)

def hbq(+W: Nat, +k: Nat, +P: Nat, +dd: Nat, +h: {Nat.is_le(Nat.add(W, Nat.add(k, P)), VB.pw(dd)) == ${TRUE}})
    -> {Nat.is_le(A.quad(Nat.add(k, P)), VB.pw(2n+dd)) == ${TRUE}}:
  +h1 = FD.nat__le_trans(Nat.add(k, P), Nat.add(W, Nat.add(k, P)), VB.pw(dd), Order.left_below_sum(W, Nat.add(k, P)), h)
  Order.double_monotone(Nat.double(Nat.add(k, P)), Nat.double(VB.pw(dd)), Order.double_monotone(Nat.add(k, P), VB.pw(dd), h1))

# ---- the output tree ----------------------------------------------------------------------------

def pfL1(${DP}, ${PFD}) -> {FD.array__perfect(U32, dd, ${L1}) == ${TRUE}}:
  YE.pfO(${C.A}, dd, ${D2}, ${PC}, VF.updv_perfect([${FS}], dd, D, Nat.add(0n, P), pf))
def pfL2(${DP}, ${PFD}) -> {FD.array__perfect(U32, dd, ${L2}) == ${TRUE}}: VB.mone_perfect(VC.NW(${SCW * 4}), 0n, Nat.add(1n, P), dd, ${L1}, TS, pfL1(${DA}, pf))
def pfL3(${DP}, ${PFD}) -> {FD.array__perfect(U32, dd, ${L3}) == ${TRUE}}: VF.updv_perfect(${GL}, dd, ${L2}, Nat.add(VC.NW(${SCW * 4}), Nat.add(1n, P)), pfL2(${DA}, pf))
def pfL4(${DP}, ${PFD}) -> {FD.array__perfect(U32, dd, ${L4}) == ${TRUE}}: VF.updv_perfect(${WLB}, dd, ${L3}, Nat.add(${KB}n, P), pfL3(${DA}, pf))

@@ enc_text_vput @@
# The nested field's writer: its offset word at P, the child's encoding at ${H} + P.
def vput(+dd: Nat, +D1: FD.array__Tree<U32>, +pos: U32, +P: Nat, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},
    ${HDD}, +pf1: {FD.array__perfect(U32, dd, D1) == ${TRUE}},
    ${C.P}, ${HDST}, ${', '.join(C.hyps)}, +hz1: {VB.slot(D1, KZ(N, P)) == 0 : U32})
    -> {T.${Y}_putv(FD.array__thaw(U32, D1), pos, 0, ${FS}, ${YO}) == ${RX} : ${TX_}}:
  +hd31 = FD.nat__lt_trans(dd, 29n, 31n, hdd, {==})
  +pf2 = VF.updv_perfect([${FS}], dd, D1, Nat.add(0n, P), pf1)
  %Equal.sym(U32, U32.and(U32.add(pos, 0), 3), 0, VF.al_3(U32.add(pos, 0), Nat.add(0n, P), ${ecv})) :
    {T.${Y}_pvb(${FS}, T.${Y}_putk(O.w32_pick(U32.is_eq(_, 0), FD.array__thaw(U32, D1), U32.add(pos, 0), ${FS}), U32.add(pos, ${FS}), ${YO})) == ${RX} : ${TX_}}
  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, D1), U32.shrn(U32.add(pos, 0), 2n), ${FS}), FD.array__thaw(U32, ${D2v}),
      VB.set_n(dd, D1, U32.shrn(U32.add(pos, 0), 2n), Nat.add(0n, P), ${FS}, VF.al_q(U32.add(pos, 0), Nat.add(0n, P), ${ecv}),
        VB.lt32(dd, hd31), VF.in_lt(0n, 1n, Nat.add(0n, P), VB.pw(dd), {==}, ${hbw(1, 0)}), pf1)) :
    {T.${Y}_pvb(${FS}, T.${Y}_putk(_, U32.add(pos, ${FS}), ${YO})) == ${RX} : ${TX_}}
  %Equal.sym(Array<U32> & (T.${Y} & U32), T.${Y}_putn(FD.array__thaw(U32, ${D2v}), U32.add(pos, ${FS}), ${YO}),
      (FD.array__thaw(U32, YE.OUTW(${C.A}, dd, ${D2v}, ${PC})), (${YO}, YE.SFS(N))),
      YE.putw(${C.A}, dd, ${D2v}, ${PC}, ${', '.join(C.hargs)}, U32.add(pos, ${FS}), ${ecF}, hdd, pf2, hdst,
        Equal.trans(U32, VB.slot(${D2v}, KZ(N, P)), VB.slot(D1, KZ(N, P)), 0,
          VBE.slot_updv_hi([${FS}], dd, D1, Nat.add(0n, P), KZ(N, P), pf1, ${hbw(1, 0)},
            FD.nat__le_trans(Nat.add(1n, Nat.add(0n, P)), ${PC}, KZ(N, P), Order.add_right(1n, ${H}n, P, {==}), kz_hp(N, P))), hz1))) :
    {T.${Y}_pvb(${FS}, _) == ${RX} : ${TX_}}
  %Equal.sym(U32, O.padd(${FS}, YE.SFS(N)), SFS(N), paddS(N, hN)) :
    {(FD.array__thaw(U32, YE.OUTW(${C.A}, dd, ${D2v}, ${PC})), (${YO}, _)) == ${RX} : ${TX_}}
  {==}

@@ enc_text_hq4 @@
def hq4(+k: Nat, +i: Nat, +d: Nat, +W: Nat, +h: {Nat.is_le(Nat.add(W, Nat.add(k, i)), VB.pw(d)) == ${TRUE}})
    -> {Nat.is_le(A.quad(Nat.add(k, i)), VB.pw(2n+d)) == ${TRUE}}:
  +h1 = FD.nat__le_trans(Nat.add(k, i), Nat.add(W, Nat.add(k, i)), VB.pw(d), Order.left_below_sum(W, Nat.add(k, i)), h)
  Order.double_monotone(Nat.double(Nat.add(k, i)), Nat.double(VB.pw(d)), Order.double_monotone(Nat.add(k, i), VB.pw(d), h1))

# The pubkeys' word count and word offset as literals, reached by evaluating Nat.is_eq (the checker's
# machine loops over a unary numeral without recursing) instead of by a conversion, which would recurse
# once per unit of ${SCW}.
def nwS() -> {${SCW}n == VC.NW(${SCW * 4}) : Nat}:
  FD.nat__eq_from_is_eq(${SCW}n, VC.NW(${SCW * 4}), {==})

def qlS() -> {${SCW}n == VY.QL(${SCW * 4}) : Nat}:
  FD.nat__eq_from_is_eq(${SCW}n, VY.QL(${SCW * 4}), {==})

def le45() -> {Nat.is_le(Nat.add(${SCG}n, Nat.add(1n, ${SCW}n)), ${H}n) == ${TRUE}}:
  {==}

# The SyncCommittee's writer at pos1 = 4 P1: the pubkeys' words copied from TS, the aggregate after them.
def scput(+dd: Nat, +D1: FD.array__Tree<U32>, +pos1: U32, +P1: Nat, +e1: {U32.to_nat(pos1) == A.quad(P1) : Nat}, ${HDD},
    +pf1: {FD.array__perfect(U32, dd, D1) == ${TRUE}}, ${', '.join(own_p[:2 + SCG])}, ${', '.join(own_h[:3])},
    +hbs: {Nat.is_le(Nat.add(${SCW + SCG}n, P1), VB.pw(dd)) == ${TRUE}}, +hz: {VB.slot(D1, Nat.add(${SCW}n, P1)) == 0 : U32})
    -> {T.SyncCommittee_putk(FD.array__thaw(U32, D1), pos1, ${SCO}) == ${SCR} : ${STY}}:
  +hd31 = FD.nat__lt_trans(dd, 29n, 31n, hdd, {==})
  +hbw = FD.nat__le_trans(Nat.add(${SCW}n, Nat.add(0n, P1)), Nat.add(${SCW + SCG}n, P1), VB.pw(dd), Order.add_right(${SCW}n, ${SCW + SCG}n, P1, {==}), hbs)
  +hbr = FD.nat__le_trans(Nat.add(${SCG}n, Nat.add(VC.NW(${SCW * 4}), P1)), Nat.add(${SCW + SCG}n, P1), VB.pw(dd), FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(${SCW + SCG}n, P1)) == ${TRUE}}, Nat.add(Nat.add(${SCG}n, VC.NW(${SCW * 4})), P1), Nat.add(${SCG}n, Nat.add(VC.NW(${SCW * 4}), P1)), FD.nat__add_assoc(${SCG}n, VC.NW(${SCW * 4}), P1), Order.add_right(Nat.add(${SCG}n, VC.NW(${SCW * 4})), ${SCW + SCG}n, P1, {==})), hbs)
  # hbw and hz with the pubkeys' word count named (VC.NW / VY.QL of ${SCW * 4}, as put_words_any
  # states them), so no conversion compares ${SCW}n with an unevaluated Nat.add over it
  +hbwN = FD.nat__le_trans(Nat.add(VC.NW(${SCW * 4}), P1), Nat.add(${SCW + SCG}n, P1), VB.pw(dd), FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, P1), Nat.add(${SCW + SCG}n, P1)) == ${TRUE}}, ${SCW}n, VC.NW(${SCW * 4}), nwS(), Order.add_right(${SCW}n, ${SCW + SCG}n, P1, {==})), hbs)
  +hzN = FD.logic__subst(Nat, z => {VB.slot(D1, Nat.add(z, P1)) == 0 : U32}, ${SCW}n, VY.QL(${SCW * 4}), qlS(), hz)
  +hrSN = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dS)) == ${TRUE}}, ${SCW}n, Nat.add(VC.NW(${SCW * 4}), 0n), FD.nat__eq_from_is_eq(${SCW}n, Nat.add(VC.NW(${SCW * 4}), 0n), {==}), hrS)
  +e0 = VF.off_add(pos1, 0, P1, 0n, 2n+dd, e1, {==}, hdd, hq4(0n, P1, dd, ${SCW}n, hbw))
  +e2 = VF.off_add(pos1, ${SCW * 4}, P1, VC.NW(${SCW * 4}), 2n+dd, e1, FD.nat__eq_from_is_eq(U32.to_nat(${SCW * 4}), A.quad(VC.NW(${SCW * 4})), {==}), hdd, hq4(VC.NW(${SCW * 4}), P1, dd, ${SCG}n, hbr))
  %Equal.sym(O.Words & Bool, T.v512_b48_valid(${PUB}), (${PUB}, True{}),
      VBE.words_ok_b(dS, TS, ${SCW * 4}, ${SCW * 4}, ${SCW * 4}, ${KYS}n, pfS, hdS, {==}, {==}, {==}, {==}, hrSN, {==}, 48, {==})) :
    {T.SyncCommittee_pw0(pos1, 0, ${AGG}, T.v512_b48_pk(FD.array__thaw(U32, D1), U32.add(pos1, 0), _)) == ${SCR} : ${STY}}
  %Equal.sym(Array<U32> & O.Words, O.put_words(FD.array__thaw(U32, D1), U32.add(pos1, 0), ${PUB}), (FD.array__thaw(U32, ${MON}), ${PUB}),
      VBE.put_words_any(dd, dS, D1, TS, U32.add(pos1, 0), P1, ${SCW * 4}, ${KYS}n, pf1, pfS, hd31, hdS, VF.al_3(U32.add(pos1, 0), P1, e0), VF.al_q(U32.add(pos1, 0), P1, e0),
        {==}, {==}, hrSN, hbwN, hzN)) :
    {T.SyncCommittee_pw0(pos1, 0, ${AGG}, T.v512_b48_pk_ok(_)) == ${SCR} : ${STY}}
  %Equal.sym(Array<U32>, T.b48_put(FD.array__thaw(U32, ${MON}), U32.add(pos1, ${SCW * 4}), ${AGG}), FD.array__thaw(U32, VF.updv(${GL}, dd, ${MON}, Nat.add(VC.NW(${SCW * 4}), P1))),
      VT.put_b48(dd, ${MON}, U32.add(pos1, ${SCW * 4}), Nat.add(VC.NW(${SCW * 4}), P1), e2, hdd, VB.mone_perfect(VC.NW(${SCW * 4}), 0n, P1, dd, D1, TS, pf1), hbr, ${', '.join(G)})) :
    {(_, (${SCO}, U32.or(0, 0))) == ${SCR} : ${STY}}
  {==}

@@ enc_text_sh2 @@
# 1 + (k + (1 + P)) as (2 + k) + P at a symbolic k: instantiated at a literal k it converts without
# walking k in unary (the literal's own Nat.add would recurse once per unit)
def sh2(+k: Nat, +P: Nat) -> {Nat.add(1n, Nat.add(k, Nat.add(1n, P))) == Nat.add(Nat.add(2n, k), P) : Nat}:
  Equal.cong(Nat, Nat, z => Nat.add(1n, z), Nat.add(k, Nat.add(1n, P)), Nat.add(1n, Nat.add(k, P)), FD.nat__add_succ(k, P))

@@ enc_text_encode_eval @@
def encode_eval(${', '.join(args + hargs)}):
  %Equal.sym(Array<U32>, Array.new(U32, ${DO}n, 0), FD.array__thaw(U32, VC.ZT(${DO}n)), FD.array__new(U32, ${DO}n, 0)) :
    {${Tn}_enc_put(${Tn}_putn(_, 0, ${OBJ})) == ${RE} : ${Tn} & B.Buf}
  %Equal.sym(${TY}, ${Tn}_putn(FD.array__thaw(U32, VC.ZT(${DO}n)), 0, ${OBJ}), (FD.array__thaw(U32, ${T0}), (${OBJ}, SFS(N))),
      putw(${A0}, ${', '.join(hargs)}, 0, {==}, {==}, FD.array__trep_perfect(U32, ${DO}n, 0), ${HD0},
        VBE.slot_zt(${DO}n, KZ(N, 0n)), VBE.slot_zt(${DO}n, Nat.add(${SCW}n, Nat.add(1n, 0n))))) :
    {${Tn}_enc_put(_) == ${RE} : ${Tn} & B.Buf}
  %Equal.sym(Bool, O.is_poisoned(SFS(N)), False{}, VBE.np31(SFS(N), ${KS}n, {==}, hS(N, hN))) :
    {(${OBJ}, O.out_donep(_, SFS(N), FD.array__thaw(U32, ${T0}))) == ${RE} : ${Tn} & B.Buf}
  {==}

@@ spec_text @@

# ---- the spec side: the header as segments [[${FS}], the SyncCommittee's words, the branch's words] ----

def lcomp(${OWN}, ${HLW}) -> {List.length(&2, U32, ${SEGC}) == ${SCW + SCG}n : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, ${SEGC}), Nat.add(List.length(&2, U32, ${WPK}), List.length(&2, U32, ${GL})), VZ.len_sapp(${WPK}, ${GL})) : {_ == ${SCW + SCG}n : Nat}
  %Equal.sym(Nat, List.length(&2, U32, ${WPK}), FD.spec_common__length(U32, ${WPK}), VZ.len_list(${WPK})) : {Nat.add(_, List.length(&2, U32, ${GL})) == ${SCW + SCG}n : Nat}
  %Equal.sym(Nat, FD.spec_common__length(U32, ${WPK}), ${SCW}n, hlW) : {Nat.add(_, List.length(&2, U32, ${GL})) == ${SCW + SCG}n : Nat}
  {==}

def hF(${OWN}, ${HLW}) -> {VS.FSZ(${PRE}, ${POST}) == ${FS}n : Nat}:
  Equal.trans(Nat, VS.FSZ(${PRE}, ${POST}), ${SUM}, ${FS}n,
    VBZ.fsz_lsum(${PRE}, ${POST}, 0n, Nat.add(${SCW + SCG}n, Nat.add(${WB}n, 0n)), VBZ.lsum_nil(),
      VBZ.lsum_c(${SEGC}, [${BWL}], ${SCW + SCG}n, Nat.add(${WB}n, 0n), lcomp(${OWA}, hlW), VBZ.lsum_c(${BWL}, [], ${WB}n, 0n, {==}, VBZ.lsum_nil()))),
    FD.nat__eq_from_is_eq(${SUM}, ${FS}n, {==}))

# The value of an object of own words and the child's value V.
def XEY(${OWN}, +V: S.Value) -> S.Value: S.Sequence{${ITEMS}}

# Its spec parts: one variable part, the header's segments (the offset is ${FS}) and the child's bytes Yb.
def encE(${OWN}, +V: S.Value, +Yb: +List<U32>,
    +hv: {Codec.parts(V, Spec.${Y}()) == Some{[S.Variable{Yb}]} : ${MP}}, +hdom: {SP.bytes_domain(Yb) == True{} : Bool},
    +fit: {N.fits(4n, Nat.add(${FS}n, List.length(&2, U32, Yb))) == True{} : Bool}, ${HLW})
    -> {Codec.parts(XEY(${OWA}, V), Spec.${x.n}()) == Some{[S.Variable{${ENC}}]} : ${MP}}:
  +hf = hF(${OWA}, hlW)
  %Equal.sym(${MP}, Codec.parts(${ITEMS}, ${CHAIN}), Some{${PL}},
      ${CAT}) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{${ENC}}]} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, Yb, ${POST})), Some{${ENCR}},
      VZ.enc_fpvb(${PRE}, Yb, ${POST}, hdom, FD.logic__subst(Nat, z => {N.fits(4n, Nat.add(z, List.length(&2, U32, Yb))) == True{} : Bool}, ${FS}n, VS.FSZ(${PRE}, ${POST}), Equal.sym(Nat, VS.FSZ(${PRE}, ${POST}), ${FS}n, hf), fit))) :
    {Codec.one(_, None{}) == Some{[S.Variable{${ENC}}]} : ${MP}}
  %Equal.sym(Nat, VS.FSZ(${PRE}, ${POST}), ${FS}n, hf) :
    {Some{[S.Variable{List.append(&2, U32, List.append(&2, U32, F.flat(${PRE}), List.append(&2, U32, N.digits(4n, _), F.flat(${POST}))), Yb)}]} == Some{[S.Variable{${ENC}}]} : ${MP}}
  %Equal.sym(+List<U32>, List.append(&2, U32, F.flat(${PRE}), List.append(&2, U32, F.limbs([${FS}]), F.flat(${POST}))), F.limbs(VZ.cat(List.append(&2, +List<U32>, ${PRE}, Con{[${FS}], ${POST}}))), VZ.hdr_flat(${PRE}, ${FS}, ${POST})) :
    {Some{[S.Variable{List.append(&2, U32, _, Yb)}]} == Some{[S.Variable{${ENC}}]} : ${MP}}
  {==}

# The value of the object.
def XE(${EP}) -> S.Value: XEY(${OWA}, YE.XE(${C.A}))

@@ spec_text_posle @@

def posle(+a: Nat, +b: Nat, +cc: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(a, b), cc) == ${TRUE}}) -> {Nat.is_le(Nat.add(a, Nat.add(b, P)), Nat.add(cc, P)) == ${TRUE}}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(cc, P)) == ${TRUE}}, Nat.add(Nat.add(a, b), P), Nat.add(a, Nat.add(b, P)), FD.nat__add_assoc(a, b, P), Order.add_right(Nat.add(a, b), cc, P, h))

# at a symbolic n, so that no conversion evaluates the word count VC.NW(${SCW * 4}) (${SCW}) in unary
def add1_swap(+n: Nat, +P: Nat) -> {Nat.add(Nat.add(1n, n), P) == Nat.add(n, Nat.add(1n, P)) : Nat}:
  Equal.sym(Nat, Nat.add(n, Nat.add(1n, P)), Nat.add(Nat.add(1n, n), P), FD.nat__add_succ(n, P))

def eqg(+P: Nat) -> {${p45} == ${pg} : Nat}:
  add1_swap(VC.NW(${SCW * 4}), P)


@@ spec_text_child_win @@
def child_win(${WP_}) -> {${cw[0]} == ${cw[-1]} : ${LT}}:
  ${chain(cw, cpr)}

def child_bytes(${WP_}) -> {${CB} == ${YBW} : +List<U32>}:
  +hq = VZ.quad_nw_ge(YE.SFS(N), ${KYc}n, {==}, FD.nat__le_trans(VC.YL(YE.SFS(N)), Nat.add(31n, ${C.MAX}n), VB.pw(${KYc}n),
    Order.add_left(31n, U32.to_nat(YE.SFS(N)), ${C.MAX}n, YE.hSle(N, hN)), {==}))
  VBE.bytes_frame(U32.to_nat(YE.SFS(N)), ${m}, ${PC}, ${SL(L1)}, ${S_}, hq,
    Equal.sym(${LT}, ${cw[0]}, ${cw[-1]}, child_win(${WA_})))

def fitE(${WP_}) -> {N.fits(4n, Nat.add(${FS}n, List.length(&2, U32, ${YBW}))) == True{} : Bool}:
  VFT.fits4(${c['KS']}n, Nat.add(${FS}n, List.length(&2, U32, ${YBW})),
    FD.nat__le_trans(Nat.add(${FS}n, List.length(&2, U32, ${YBW})), ${c['MAX']}n, VB.pw(${c['KS']}n),
      Order.add_left(${FS}n, List.length(&2, U32, ${YBW}), ${C.MAX}n,
        FD.nat__le_trans(List.length(&2, U32, ${YBW}), U32.to_nat(YE.SFS(N)), ${C.MAX}n, VZ.bt_len_le(U32.to_nat(YE.SFS(N)), F.limbs(VB.wdr(${PC}, ${S_}))), YE.hSle(N, hN))),
      {==}),
    {==})

def hlWo(+dS: Nat, +TS: FD.array__Tree<U32>, +pfS: {FD.array__perfect(U32, dS, TS) == ${TRUE}}, +hrS: {Nat.is_le(${SCW}n, VB.pw(dS)) == ${TRUE}})
    -> {FD.spec_common__length(U32, ${WPK}) == ${SCW}n : Nat}:
  VBZ.len_WIN(${SCW}n, 0n, ${SL('TS')}, FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${SCW}n, 0n), z) == ${TRUE}}, VB.pw(dS), VB.len(${SL('TS')}),
    Equal.sym(Nat, VB.len(${SL('TS')}), VB.pw(dS), FD.array__slots_length(U32, dS, TS, pfS)), hrS))

# The spec parts of the object's value are one variable part: the bytes of the encoder's output window.
def partsw(${WP_}, ${HDD})
    -> {Codec.parts(XE(${EA}), Spec.${x.n}()) == Some{[S.Variable{${BYTES}}]} : ${MP}}:
  +hv0 = YE.partsw(${C.A}, dd, ${D2}, ${PC}, ${', '.join(C.hargs)}, ${pf2}, hdst, hdd)
  +hv = Equal.trans(${MP}, Codec.parts(YE.XE(${C.A}), Spec.${Y}()), Some{[S.Variable{${CB}}]}, Some{[S.Variable{${YBW}}]}, hv0,
    Equal.cong(+List<U32>, ${MP}, z => Some{[S.Variable{z}]}, ${CB}, ${YBW}, child_bytes(${WA_})))
  %Equal.sym(+List<U32>, ${BYTES}, ${RB}, bytesw_enc(${WA_}, hdd)) :
    {Codec.parts(XE(${EA}), Spec.${x.n}()) == Some{[S.Variable{_}]} : ${MP}}
  encE(${OWA}, YE.XE(${C.A}), ${YBW}, hv, VZ.bd_btl(U32.to_nat(YE.SFS(N)), VB.wdr(${PC}, ${S_})), fitE(${WA_}), hlWo(dS, TS, pfS, hrS))

@@ spec_text_encode_spec @@
def encode_spec(${', '.join(c['args'] + hargs)}):
  # the encoding opened over variables first (F.efl_bytes): the parts rewrite's motive over
  # Codec.bytes was compared with the spec encoding by running the encoder
  %F.efl_bytes(Spec.${x.n}(), XE(${EA})) : {_ == Some{${BY0}} : ${M}}
  %Equal.sym(${MP}, Codec.parts(XE(${EA}), Spec.${x.n}()), Some{[S.Variable{${BY0}}]},
      partsw(${A0}, ${', '.join(hargs)}, FD.array__trep_perfect(U32, ${DO}n, 0), ${HD0}, {==})) :
    {Codec.bytes(_) == Some{${BY0}} : ${M}}
  {==}

@@ spec_text_lines @@
  %Equal.sym(${LT}, VZ.cat([]), [], VBZ.cat_nil()) : {${LHSF} == ${rpre('_')} : ${LT}}
  {==}
