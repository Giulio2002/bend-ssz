@@ wput_module @@

def wput_${p}(+dd: Nat, +D: F.array__Tree<U32>, +pos: U32, +P: Nat, +e: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(${W}n, P), VB.pw(dd)) == True{} : Bool}, +dB: Nat, +TB: F.array__Tree<U32>,
    +pfB: {F.array__perfect(U32, dB, TB) == True{} : Bool}, +hdB: {Nat.is_lt(dB, 31n) == True{} : Bool},
    +hrB: {Nat.is_le(${W}n, VB.pw(dB)) == True{} : Bool})
    -> {T.${p}_putk(F.array__thaw(U32, D), pos, ${OB}) == ${RHS} : ${TY}}:
  +hd32 = VB.lt32(dd, F.nat__lt_trans(dd, 29n, 31n, hdd, {==}))
  +hB32 = VB.lt32(dB, hdB)
  %Equal.sym(O.Words & Bool, T.${p}_valid(${OB}), (${OB}, True{}),
      VBE.words_ok_b(dB, TB, ${S}, ${S}, ${S}, ${kw}n, pfB, hdB, {==}, {==}, {==}, {==}, hrB, {==}, ${unit}, {==})) :
    {T.${p}_pk(F.array__thaw(U32, D), pos, _) == ${RHS} : ${TY}}
  %Equal.sym(U32, U32.and(pos, 3), 0, VF.al_3(pos, P, e)) :
    {T.${p}_pk_ok(T.${p}_pw(U32.is_eq(_, 0), F.array__thaw(U32, D), pos, F.array__thaw(U32, TB), ${S})) == ${RHS} : ${TY}}
@@ enc_text @@

def hyN(+N: U32, ${HN}) -> {Nat.is_le(VC.YL(N), VB.pw(${KY}n)) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(N), ${31 + LIM}n, VB.pw(${KY}n), hN, {==})

def paddN(+N: U32, ${HN}) -> {O.padd(${FS}, N) == SFS(N) : U32}:
  VE.padd_ok(${FS}, N, VE.winit(31n, VE.bits32(${FS})), VE.winit(31n, VE.bits32(N)), {==},
    VE.small_pad(N, ${KL}n, {==}, FD.nat__le_lt_trans(U32.to_nat(N), ${LIM}n, VB.pw(${KL}n), hN, {==})))

def eS(+N: U32, ${HN}) -> {U32.to_nat(SFS(N)) == Nat.add(${FS}n, U32.to_nat(N)) : Nat}:
  A.add_le(${FS}, N, ${FS + LIM}, FD.nat__le_trans(Nat.add(${FS}n, U32.to_nat(N)), Nat.add(${FS}n, ${LIM}n), U32.to_nat(${FS + LIM}),
    Order.add_left(${FS}n, U32.to_nat(N), ${LIM}n, hN), {==}))

# pos + c = 4 (k + P) for a header byte c = 4 k.
def eoc(+k: Nat, +c: U32, +P: Nat, +pos: U32, +dd: Nat, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hq: {Nat.is_le(A.quad(Nat.add(k, P)), VB.pw(2n+dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(pos, c)) == A.quad(Nat.add(k, P)) : Nat}:
  VF.off_add(pos, c, P, k, 2n+dd, eP, ec, hdd, hq)

def hHP(+N: U32, +dd: Nat, +P: Nat, ${HDST}) -> {Nat.is_le(Nat.add(${H}n, P), VB.pw(dd)) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(${H}n, P), Nat.add(VC.NW(N), Nat.add(${H}n, P)), VB.pw(dd), Order.left_below_sum(VC.NW(N), Nat.add(${H}n, P)), hdst)

# A run of W words at word k (W + k <= ${H}) of the window lies in the tree.
def hb(+W: Nat, +k: Nat, +P: Nat, +dd: Nat, +hWk: {Nat.is_le(Nat.add(W, k), ${H}n) == True{} : Bool},
    +hH: {Nat.is_le(Nat.add(${H}n, P), VB.pw(dd)) == True{} : Bool}) -> {Nat.is_le(Nat.add(W, Nat.add(k, P)), VB.pw(dd)) == True{} : Bool}:
  %FD.nat__add_assoc(W, k, P) : {Nat.is_le(_, VB.pw(dd)) == True{} : Bool}
  FD.nat__le_trans(Nat.add(Nat.add(W, k), P), Nat.add(${H}n, P), VB.pw(dd), Order.add_right(Nat.add(W, k), ${H}n, P, hWk), hH)

def hbq(+W: Nat, +k: Nat, +P: Nat, +dd: Nat, +h: {Nat.is_le(Nat.add(W, Nat.add(k, P)), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(A.quad(Nat.add(k, P)), VB.pw(2n+dd)) == True{} : Bool}:
  +h1 = FD.nat__le_trans(Nat.add(k, P), Nat.add(W, Nat.add(k, P)), VB.pw(dd), Order.left_below_sum(W, Nat.add(k, P)), h)
  Order.double_monotone(Nat.double(Nat.add(k, P)), Nat.double(VB.pw(dd)), Order.double_monotone(Nat.add(k, P), VB.pw(dd), h1))

# A run of W words at word k (W + k <= ${H}) lies below the byte list's last word.
def hbz(+W: Nat, +k: Nat, +N: U32, +P: Nat, +hWk: {Nat.is_le(Nat.add(W, k), ${H}n) == True{} : Bool})
    -> {Nat.is_le(Nat.add(W, Nat.add(k, P)), ${K}) == True{} : Bool}:
  %FD.nat__add_assoc(W, k, P) : {Nat.is_le(_, ${K}) == True{} : Bool}
  FD.nat__le_trans(Nat.add(Nat.add(W, k), P), Nat.add(${H}n, P), ${K}, Order.add_right(Nat.add(W, k), ${H}n, P, hWk),
    Order.left_below_sum(VY.QL(N), Nat.add(${H}n, P)))

@@ enc_text_xput @@
# The byte list's writer: its offset word at ${po} + P, its words at ${H} + P.
def xput(+dd: Nat, +D1: FD.array__Tree<U32>, +pos: U32, +P: Nat, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf1: {FD.array__perfect(U32, dd, D1) == True{} : Bool},
    +dX: Nat, +TX: FD.array__Tree<U32>, +N: U32, ${HDST}, ${XH}, +hz1: {VB.slot(D1, ${K}) == 0 : U32})
    -> {T.${lp}_putv(FD.array__thaw(U32, D1), pos, ${cvar}, ${FS}, ${XOBJ}) == ${RX} : ${TX_}}:
  +hd31 = FD.nat__lt_trans(dd, 29n, 31n, hdd, {==})
  +pf2 = VF.updv_perfect([${FS}], dd, D1, Nat.add(${po}n, P), pf1)
  %Equal.sym(U32, U32.and(U32.add(pos, ${cvar}), 3), 0, VF.al_3(U32.add(pos, ${cvar}), Nat.add(${po}n, P), ${ecv})) :
    {T.${lp}_pvb(${FS}, T.${lp}_putk(O.w32_pick(U32.is_eq(_, 0), FD.array__thaw(U32, D1), U32.add(pos, ${cvar}), ${FS}), U32.add(pos, ${FS}), ${XOBJ})) == ${RX} : ${TX_}}
  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, D1), U32.shrn(U32.add(pos, ${cvar}), 2n), ${FS}), FD.array__thaw(U32, ${D2}),
      VB.set_n(dd, D1, U32.shrn(U32.add(pos, ${cvar}), 2n), Nat.add(${po}n, P), ${FS}, VF.al_q(U32.add(pos, ${cvar}), Nat.add(${po}n, P), ${ecv}),
        VB.lt32(dd, hd31), VF.in_lt(0n, 1n, Nat.add(${po}n, P), VB.pw(dd), {==}, ${hbw(1, po)}), pf1)) :
    {T.${lp}_pvb(${FS}, T.${lp}_putk(_, U32.add(pos, ${FS}), ${XOBJ})) == ${RX} : ${TX_}}
  %Equal.sym(O.Words & Bool, T.${lp}_valid(${XOBJ}), (${XOBJ}, True{}),
      VBE.words_ok_b(dX, TX, N, 0, ${LIM}, ${KY}n, pfX, hdX, {==}, hyN(N, hN), Order.zero_le(U32.to_nat(N)), hN, hrX, htz, 1, {==})) :
    {T.${lp}_pvb(${FS}, T.${lp}_pk(FD.array__thaw(U32, ${D2}), U32.add(pos, ${FS}), _)) == ${RX} : ${TX_}}
  %Equal.sym(Array<U32> & O.Words, O.put_words(FD.array__thaw(U32, ${D2}), U32.add(pos, ${FS}), ${XOBJ}), (FD.array__thaw(U32, ${D3}), ${XOBJ}),
      VBE.put_words_any(dd, dX, ${D2}, TX, U32.add(pos, ${FS}), Nat.add(${H}n, P), N, ${KY}n, pf2, pfX, hd31, hdX,
        VF.al_3(U32.add(pos, ${FS}), Nat.add(${H}n, P), ${ecF}), VF.al_q(U32.add(pos, ${FS}), Nat.add(${H}n, P), ${ecF}),
        {==}, hyN(N, hN), hrX, hdst,
        Equal.trans(U32, VB.slot(${D2}, ${K}), VB.slot(D1, ${K}), 0,
          VBE.slot_updv_hi([${FS}], dd, D1, Nat.add(${po}n, P), ${K}, pf1, ${hbw(1, po)}, hbz(1n, ${po}n, N, P, {==})), hz1))) :
    {T.${lp}_pvb(${FS}, O.pwn(_)) == ${RX} : ${TX_}}
  %Equal.sym(U32, O.padd(${FS}, N), SFS(N), paddN(N, hN)) :
    {(FD.array__thaw(U32, ${D3}), (${XOBJ}, _)) == ${RX} : ${TX_}}
  {==}

@@ enc_spec_text @@

def hNW(+N: U32, ${HN}) -> {Nat.is_le(VC.NW(N), ${NWM}n) == True{} : Bool}:
  %Equal.sym(Nat, VC.NW(N), VD.s_rng(2n, 3n+U32.to_nat(N)), VC.eNW(N, ${KY}n, {==}, hyN(N, hN))) : {Nat.is_le(_, ${NWM}n) == True{} : Bool}
  VC.rng_mono(2n, 3n+U32.to_nat(N), ${3 + LIM}n, hN)

def hSle(+N: U32, ${HN}) -> {Nat.is_le(U32.to_nat(SFS(N)), ${FS + LIM}n) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(SFS(N)), Nat.add(${FS}n, U32.to_nat(N)), eS(N, hN)) : {Nat.is_le(_, ${FS + LIM}n) == True{} : Bool}
  Order.add_left(${FS}n, U32.to_nat(N), ${LIM}n, hN)

def hS(+N: U32, ${HN}) -> {Nat.is_lt(U32.to_nat(SFS(N)), VB.pw(${KS}n)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(SFS(N)), Nat.add(${FS}n, U32.to_nat(N)), eS(N, hN)) : {Nat.is_lt(_, VB.pw(${KS}n)) == True{} : Bool}
  FD.nat__le_lt_trans(Nat.add(${FS}n, U32.to_nat(N)), ${FS + LIM}n, VB.pw(${KS}n), Order.add_left(${FS}n, U32.to_nat(N), ${LIM}n, hN), {==})

# The encoder returns the object and the buffer of the output tree, ${FS} + N bytes.
law encode_eval:

@@ enc_spec_text_encode_eval @@

  {${Tn}_encode(${OBJ}) == ${RE} : ${Tn} & B.Buf}
def encode_eval(${E.AH}):
  %Equal.sym(Array<U32>, Array.new(U32, ${DO}n, 0), FD.array__thaw(U32, VC.ZT(${DO}n)), FD.array__new(U32, ${DO}n, 0)) :
    {${Tn}_enc_put(${Tn}_putn(_, 0, ${OBJ})) == ${RE} : ${Tn} & B.Buf}
  %Equal.sym(${TY}, ${Tn}_putn(FD.array__thaw(U32, VC.ZT(${DO}n)), 0, ${OBJ}), (FD.array__thaw(U32, ${T0}), (${OBJ}, SFS(N))),
      putw(${A0}, ${', '.join(E.hargs)}, 0, {==}, {==}, FD.array__trep_perfect(U32, ${DO}n, 0), ${HD0},
        VBE.slot_zt(${DO}n, Nat.add(VY.QL(N), ${H}n)))) :
    {${Tn}_enc_put(_) == ${RE} : ${Tn} & B.Buf}
  %Equal.sym(Bool, O.is_poisoned(SFS(N)), False{}, VBE.np31(SFS(N), ${KS}n, {==}, hS(N, hN))) :
    {(${OBJ}, O.out_donep(_, SFS(N), FD.array__thaw(U32, ${T0}))) == ${RE} : ${Tn} & B.Buf}
  {==}

@@ own @@
Equal.trans(${LT}, ${win(m, p, j + 1)}, VF.WIN(${m}, ${p}, FD.array__slots(U32, ${D2})), ${Vs},
    VBE.peel_mone_hi(VC.NW(N), 0n, Nat.add(${H}n, P), dd, ${D2}, TX, ${m}, ${p}, VF.updv_perfect([${FS}], dd, ${tree(j)}, Nat.add(${po}n, P), ${pfl(j)}), hdst, Order.add_right(${1 + po}n, ${H}n, P, {==})),
    V2.own([${FS}], dd, ${tree(j)}, Nat.add(${po}n, P), ${pfl(j)}, ${hbw(1, po)}))
@@ enc_spec_text_bytesw_enc @@
# The bytes of the output window: the header's words and the byte list's bytes.
def bytesw_enc(${WP_}, ${HDD})
    -> {${BYTES} == ${RB} : +List<U32>}:
  +hq = VZ.quad_nw_ge(N, ${KY}n, {==}, hyN(N, hN))
  +hls = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${H}n, P), z) == True{} : Bool}, VB.pw(dd), VB.len(${S_}),
    Equal.sym(Nat, VB.len(${S_}), VB.pw(dd), FD.array__slots_length(U32, dd, OUTW(${DA}), pfL${NL}(${DA}, pf))), hHP(N, dd, P, hdst))
  %Equal.sym(Nat, U32.to_nat(SFS(N)), Nat.add(${FS}n, U32.to_nat(N)), eS(N, hN)) : {VS.bt(_, F.limbs(VB.wdr(P, ${S_}))) == ${RB} : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(${H}n), U32.to_nat(N)), F.limbs(VB.wdr(P, ${S_}))),
      List.append(&2, U32, F.limbs(VS.wtake(${H}n, VB.wdr(P, ${S_}))), VS.bt(U32.to_nat(N), F.limbs(VB.wdr(${H}n, VB.wdr(P, ${S_}))))),
      VY.bt_split(${H}n, U32.to_nat(N), VB.wdr(P, ${S_}), VZ.wdr_len_le(${H}n, P, ${S_}, hls))) :
    {_ == ${RB} : +List<U32>}
  %Equal.sym(${LT}, VF.WIN(${H}n, Nat.add(0n, P), ${S_}), ${HDRE}, hdr_eq(${WA_})) :
    {List.append(&2, U32, F.limbs(_), VS.bt(U32.to_nat(N), F.limbs(VB.wdr(${H}n, VB.wdr(P, ${S_}))))) == ${RB} : +List<U32>}
  %Equal.sym(${LT}, VB.wdr(${H}n, VB.wdr(P, ${S_})), VB.wdr(Nat.add(P, ${H}n), ${S_}), VF.wdr_add(${H}n, P, ${S_})) :
    {List.append(&2, U32, F.limbs(${HDRE}), VS.bt(U32.to_nat(N), F.limbs(_))) == ${RB} : +List<U32>}
  %Equal.sym(Nat, Nat.add(P, ${H}n), Nat.add(${H}n, P), FD.nat__add_comm(P, ${H}n)) :
    {List.append(&2, U32, F.limbs(${HDRE}), VS.bt(U32.to_nat(N), F.limbs(VB.wdr(_, ${S_})))) == ${RB} : +List<U32>}
  %VY.bt_take(VC.NW(N), U32.to_nat(N), VB.wdr(Nat.add(${H}n, P), ${S_}), hq) :
    {List.append(&2, U32, F.limbs(${HDRE}), _) == ${RB} : +List<U32>}
  %Equal.sym(${LT}, VF.WIN(VC.NW(N), Nat.add(${H}n, P), ${S_}), VS.wtake(VC.NW(N), FD.array__slots(U32, TX)), pay_eq(${WA_})) :
    {List.append(&2, U32, F.limbs(${HDRE}), VS.bt(U32.to_nat(N), F.limbs(_))) == ${RB} : +List<U32>}
  %Equal.sym(+List<U32>, ${WT}, ${YE}, VY.bt_take(VC.NW(N), U32.to_nat(N), FD.array__slots(U32, TX), hq)) :
    {List.append(&2, U32, F.limbs(${HDRE}), _) == ${RB} : +List<U32>}
  {==}

@@ enc_spec_text_encode_spec @@

  Decoding.decodes(Spec.${n}(), ${BY0}, XE(${E.A}))
def encode_spec(${E.AH}):
  # the encoding opened over variables first (F.efl_bytes): the parts rewrite's motive over
  # Codec.bytes was compared with the spec encoding by running the encoder
  %F.efl_bytes(Spec.${n}(), XE(${E.A})) : {_ == Some{${BY0}} : ${M}}
  %Equal.sym(${MP}, Codec.parts(XE(${E.A}), Spec.${n}()), Some{[S.Variable{${BY0}}]},
      partsw(${A0}, ${', '.join(E.hargs)}, FD.array__trep_perfect(U32, ${DO}n, 0), ${HD0}, {==})) :
    {Codec.bytes(_) == Some{${BY0}} : ${M}}
  {==}

@@ wput_module_lines @@
  %Equal.sym(Array<U32>, Array.set(U32, ${pre}, U32.add(U32.shrn(pos, 2n), ${j}), VB.slot(TB, ${j}n)), ${post},
      VB.set_at(dd, VF.updv(WP${j}_${p}(TB), dd, D, P), U32.shrn(pos, 2n), ${j}, P, VB.slot(TB, ${j}n), VF.al_q(pos, P, e), hd32,
        VF.in_lt(${j}n, ${W}n, P, VB.pw(dd), {==}, hb), VF.updv_perfect(WP${j}_${p}(TB), dd, D, P, pf))) :
    {T.${p}_pk_ok(T.${p}_pal(${S}, ${nxt})) == ${RHS} : ${TY}}
@@ enc_text_lines @@
def OBJE(${E.P}) -> ${Tn}: ${E.objterm()}
def SFS(+N: U32) -> U32: U32.add(${FS}, N)
# The words the encoding occupies past word P, and the word under the byte list's partial last word.
def ROOM(+N: U32, +P: Nat) -> Nat: Nat.add(VC.NW(N), Nat.add(${H}n, P))
def KZ(+N: U32, +P: Nat) -> Nat: Nat.add(VY.QL(N), Nat.add(${H}n, P))
def room_hp(+N: U32, +P: Nat) -> {Nat.is_le(P, ROOM(N, P)) == True{} : Bool}:
  FD.nat__le_trans(P, Nat.add(${H}n, P), ROOM(N, P), Order.left_below_sum(${H}n, P), Order.left_below_sum(VC.NW(N), Nat.add(${H}n, P)))
def kz_hp(+N: U32, +P: Nat) -> {Nat.is_le(Nat.add(${H}n, P), KZ(N, P)) == True{} : Bool}:
  Order.left_below_sum(VY.QL(N), Nat.add(${H}n, P))
@@ enc_text_lines_3 @@
def hzL${j + 1}(${DP}, ${PFD}, ${HDST}, ${HZ}) -> {VB.slot(${tree(j + 1)}, ${K}) == 0 : U32}:
  Equal.trans(U32, VB.slot(${tree(j + 1)}, ${K}), VB.slot(${tree(j)}, ${K}), 0,
    VBE.slot_updv_hi(${vterm(kind, V, i)}, dd, ${tree(j)}, Nat.add(${k}n, P), ${K}, ${pfp}, ${hbw(f['W'], k)}, hbz(${f['W']}n, ${k}n, N, P, {==})),
    ${prev})
@@ enc_text_lines_2 @@
# The writer at pos = 4 P over any perfect tree D (depth dd < 29) with room for the
# encoding and a zero word under the byte list's partial last word.
def putw(${DP}, ${', '.join(E.hyps)}, +pos: U32, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, ${PFD}, ${HDST}, ${HZ})
    -> {${Tn}_putn(FD.array__thaw(U32, D), pos, ${OBJ}) == ${RHS} : ${TY}}:
@@ enc_text_lines_4 @@
  %Equal.sym(${ty}, ${call}, ${res},
      ${pr}) :
    {${pat} == ${RHS} : ${TY}}
@@ enc_spec_text_lines @@
# The encoder leaves every window below word P alone.
def frame_lo(${DP}, ${PFD}, ${HDST}, +m: Nat, +p: Nat, +h: {Nat.is_le(Nat.add(m, p), P) == True{} : Bool})
    -> {VF.WIN(m, p, FD.array__slots(U32, OUTW(${DA}))) == VF.WIN(m, p, FD.array__slots(U32, D)) : ${LT}}: