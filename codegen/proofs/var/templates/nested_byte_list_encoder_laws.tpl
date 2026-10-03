@@ enc_module_text @@
def hNW(+N: U32, ${HN}) -> {Nat.is_le(VC.NW(N), 8n) == True{} : Bool}: YE.hNW(N, hN)
def room_hp(+N: U32, +P: Nat) -> {Nat.is_le(P, ROOM(N, P)) == True{} : Bool}:
  FD.nat__le_trans(P, ${PC}, ROOM(N, P), Order.left_below_sum(${H}n, P), YE.room_hp(N, ${PC}))
def kz_hp(+N: U32, +P: Nat) -> {Nat.is_le(${PC}, KZ(N, P)) == True{} : Bool}:
  FD.nat__le_trans(${PC}, Nat.add(${HY}n, ${PC}), KZ(N, P), Order.left_below_sum(${HY}n, ${PC}), YE.kz_hp(N, ${PC}))

def eS(+N: U32, ${HN}) -> {U32.to_nat(SFS(N)) == Nat.add(${FSN}, U32.to_nat(YE.SFS(N))) : Nat}:
  A.add_le(${FS}, YE.SFS(N), ${MAX}, FD.nat__le_trans(Nat.add(${FSN}, U32.to_nat(YE.SFS(N))), Nat.add(${FSN}, ${CM}n), U32.to_nat(${MAX}),
    Order.add_left(${FSN}, U32.to_nat(YE.SFS(N)), ${CM}n, YE.hSle(N, hN)), {==}))

def hSle(+N: U32, ${HN}) -> {Nat.is_le(U32.to_nat(SFS(N)), ${MAX}n) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(SFS(N)), Nat.add(${FSN}, U32.to_nat(YE.SFS(N))), eS(N, hN)) : {Nat.is_le(_, ${MAX}n) == True{} : Bool}
  Order.add_left(${FSN}, U32.to_nat(YE.SFS(N)), ${CM}n, YE.hSle(N, hN))

def hS(+N: U32, ${HN}) -> {Nat.is_lt(U32.to_nat(SFS(N)), VB.pw(${KS}n)) == True{} : Bool}:
  FD.nat__le_lt_trans(U32.to_nat(SFS(N)), ${MAX}n, VB.pw(${KS}n), hSle(N, hN), {==})

def paddS(+N: U32, ${HN}) -> {O.padd(${FS}, YE.SFS(N)) == SFS(N) : U32}:
  VE.padd_ok(${FS}, YE.SFS(N), VE.winit(31n, VE.bits32(${FS})), VE.winit(31n, VE.bits32(YE.SFS(N))), {==},
    VE.small_pad(YE.SFS(N), ${C.KS}n, {==}, YE.hS(N, hN)))

# pos + c = 4 (k + P) for a header byte c = 4 k.
def eoc(+k: Nat, +c: U32, +P: Nat, +pos: U32, +dd: Nat, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hq: {Nat.is_le(A.quad(Nat.add(k, P)), VB.pw(2n+dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(pos, c)) == A.quad(Nat.add(k, P)) : Nat}:
  VF.off_add(pos, c, P, k, 2n+dd, eP, ec, hdd, hq)

def hHP(+N: U32, +dd: Nat, +P: Nat, ${HDST}) -> {Nat.is_le(${PC}, VB.pw(dd)) == True{} : Bool}:
  FD.nat__le_trans(${PC}, ROOM(N, P), VB.pw(dd), YE.room_hp(N, ${PC}), hdst)

def hb(+W: Nat, +k: Nat, +P: Nat, +dd: Nat, +hWk: {Nat.is_le(Nat.add(W, k), ${H}n) == True{} : Bool},
    +hH: {Nat.is_le(${PC}, VB.pw(dd)) == True{} : Bool}) -> {Nat.is_le(Nat.add(W, Nat.add(k, P)), VB.pw(dd)) == True{} : Bool}:
  %FD.nat__add_assoc(W, k, P) : {Nat.is_le(_, VB.pw(dd)) == True{} : Bool}
  FD.nat__le_trans(Nat.add(Nat.add(W, k), P), ${PC}, VB.pw(dd), Order.add_right(Nat.add(W, k), ${H}n, P, hWk), hH)

def hbq(+W: Nat, +k: Nat, +P: Nat, +dd: Nat, +h: {Nat.is_le(Nat.add(W, Nat.add(k, P)), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(A.quad(Nat.add(k, P)), VB.pw(2n+dd)) == True{} : Bool}:
  +h1 = FD.nat__le_trans(Nat.add(k, P), Nat.add(W, Nat.add(k, P)), VB.pw(dd), Order.left_below_sum(W, Nat.add(k, P)), h)
  Order.double_monotone(Nat.double(Nat.add(k, P)), Nat.double(VB.pw(dd)), Order.double_monotone(Nat.add(k, P), VB.pw(dd), h1))

@@ enc_module_text_2 @@
def bxput_${ft.p}(+dd: Nat, +D: FD.array__Tree<U32>, +pos: U32, +P: Nat, +e: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, ${PFD}, +hb: {Nat.is_le(Nat.add(${f['W']}n, P), VB.pw(dd)) == True{} : Bool}, ${', '.join(('+' + q + ': U32' for q in xs))})
    -> {T.${ft.p}_bx_putk(FD.array__thaw(U32, D), pos, O.BSome{${ob}, O.BNone{}}) == ${RHS} : Array<U32> & (O.Boxed<T.${ft.s.rep}> & U32)}:
  %Equal.sym(Array<U32>, T.${ft.p}_put(FD.array__thaw(U32, D), pos, ${ob}), FD.array__thaw(U32, VF.updv([${', '.join(xs)}], dd, D, P)),
      VT.put_${ft.p}(dd, D, pos, P, e, hdd, pf, hb, ${', '.join(xs)})) :
    {(_, (O.BSome{${ob}, O.BNone{}}, O.pz(T.${ft.p}_valid(${ob})))) == ${RHS} : Array<U32> & (O.Boxed<T.${ft.s.rep}> & U32)}
  {==}

@@ enc_module_text_3 @@
# The nested field's writer: its offset word at ${po} + P, the child's encoding at ${H} + P.
def vput(+dd: Nat, +D1: FD.array__Tree<U32>, +pos: U32, +P: Nat, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf1: {FD.array__perfect(U32, dd, D1) == True{} : Bool},
    ${C.P}, ${HDST}, ${', '.join(C.hyps)}, +hz1: {VB.slot(D1, KZ(N, P)) == 0 : U32})
    -> {T.${vp}_putv(FD.array__thaw(U32, D1), pos, ${cvar}, ${FS}, ${VOBJ}) == ${RX} : ${TX_}}:
  +hd31 = FD.nat__lt_trans(dd, 29n, 31n, hdd, {==})
  +pf2 = VF.updv_perfect([${FS}], dd, D1, Nat.add(${po}n, P), pf1)
  %Equal.sym(U32, U32.and(U32.add(pos, ${cvar}), 3), 0, VF.al_3(U32.add(pos, ${cvar}), Nat.add(${po}n, P), ${ecv})) :
    {T.${vp}_pvb(${FS}, T.${vp}_putk(O.w32_pick(U32.is_eq(_, 0), FD.array__thaw(U32, D1), U32.add(pos, ${cvar}), ${FS}), U32.add(pos, ${FS}), ${VOBJ})) == ${RX} : ${TX_}}
  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, D1), U32.shrn(U32.add(pos, ${cvar}), 2n), ${FS}), FD.array__thaw(U32, ${D2}),
      VB.set_n(dd, D1, U32.shrn(U32.add(pos, ${cvar}), 2n), Nat.add(${po}n, P), ${FS}, VF.al_q(U32.add(pos, ${cvar}), Nat.add(${po}n, P), ${ecv}),
        VB.lt32(dd, hd31), VF.in_lt(0n, 1n, Nat.add(${po}n, P), VB.pw(dd), {==}, ${hbw(1, po)}), pf1)) :
    {T.${vp}_pvb(${FS}, T.${vp}_putk(_, U32.add(pos, ${FS}), ${VOBJ})) == ${RX} : ${TX_}}
  %Equal.sym(Array<U32> & (T.${Y} & U32), T.${Y}_putn(FD.array__thaw(U32, ${D2}), U32.add(pos, ${FS}), YE.OBJE(${C.A})),
      (FD.array__thaw(U32, YE.OUTW(${C.A}, dd, ${D2}, ${PC})), (YE.OBJE(${C.A}), YE.SFS(N))),
      YE.putw(${C.A}, dd, ${D2}, ${PC}, ${', '.join(C.hargs)}, U32.add(pos, ${FS}), ${ecF}, hdd, pf2, hdst,
        Equal.trans(U32, VB.slot(${D2}, KZ(N, P)), VB.slot(D1, KZ(N, P)), 0,
          VBE.slot_updv_hi([${FS}], dd, D1, Nat.add(${po}n, P), KZ(N, P), pf1, ${hbw(1, po)},
            FD.nat__le_trans(Nat.add(1n, Nat.add(${po}n, P)), ${PC}, KZ(N, P), Order.add_right(${1 + po}n, ${H}n, P, {==}), kz_hp(N, P))), hz1))) :
    {T.${vp}_pvb(${FS}, ${inner}) == ${RX} : ${TX_}}
  %Equal.sym(U32, O.padd(${FS}, YE.SFS(N)), SFS(N), paddS(N, hN)) :
    {(FD.array__thaw(U32, YE.OUTW(${C.A}, dd, ${D2}, ${PC})), (${VOBJ}, _)) == ${RX} : ${TX_}}
  {==}

@@ spec_text @@
# The bytes of the output window: the header's words and the child's encoding.
def bytesw_enc(${WP_}, ${HDD})
    -> {${BYTES} == ${RB} : +List<U32>}:
  +hls = FD.logic__subst(Nat, z => {Nat.is_le(${PC}, z) == True{} : Bool}, VB.pw(dd), VB.len(${S_}),
    Equal.sym(Nat, VB.len(${S_}), VB.pw(dd), FD.array__slots_length(U32, dd, OUTW(${DA}), pfO(${DA}, pf))), hHP(N, dd, P, hdst))
  %Equal.sym(Nat, U32.to_nat(SFS(N)), Nat.add(${FSN}, U32.to_nat(YE.SFS(N))), eS(N, hN)) : {VS.bt(_, F.limbs(VB.wdr(P, ${S_}))) == ${RB} : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(${H}n), U32.to_nat(YE.SFS(N))), F.limbs(VB.wdr(P, ${S_}))),
      List.append(&2, U32, F.limbs(VS.wtake(${H}n, VB.wdr(P, ${S_}))), VS.bt(U32.to_nat(YE.SFS(N)), F.limbs(VB.wdr(${H}n, VB.wdr(P, ${S_}))))),
      VY.bt_split(${H}n, U32.to_nat(YE.SFS(N)), VB.wdr(P, ${S_}), VZ.wdr_len_le(${H}n, P, ${S_}, hls))) :
    {_ == ${RB} : +List<U32>}
  %Equal.sym(${LT}, VF.WIN(${H}n, Nat.add(0n, P), ${S_}), ${HDRE}, hdr_eq(${WA_})) :
    {List.append(&2, U32, F.limbs(_), VS.bt(U32.to_nat(YE.SFS(N)), F.limbs(VB.wdr(${H}n, VB.wdr(P, ${S_}))))) == ${RB} : +List<U32>}
  %Equal.sym(${LT}, VB.wdr(${H}n, VB.wdr(P, ${S_})), VB.wdr(Nat.add(P, ${H}n), ${S_}), VF.wdr_add(${H}n, P, ${S_})) :
    {List.append(&2, U32, F.limbs(${HDRE}), VS.bt(U32.to_nat(YE.SFS(N)), F.limbs(_))) == ${RB} : +List<U32>}
  %Equal.sym(Nat, Nat.add(P, ${H}n), ${PC}, FD.nat__add_comm(P, ${H}n)) :
    {List.append(&2, U32, F.limbs(${HDRE}), VS.bt(U32.to_nat(YE.SFS(N)), F.limbs(VB.wdr(_, ${S_})))) == ${RB} : +List<U32>}
  {==}

@@ spec_text_2 @@
def child_win(${WP_}) -> {${win(m, PC, NL)} == ${win(m, PC, vj + 1)} : ${LT}}:
  ${out}

def child_bytes(${WP_}) -> {${CB} == ${YBW} : +List<U32>}:
  +hq = VZ.quad_nw_ge(YE.SFS(N), ${KYc}n, {==}, FD.nat__le_trans(VC.YL(YE.SFS(N)), Nat.add(31n, ${C.MAX}n), VB.pw(${KYc}n),
    Order.add_left(31n, U32.to_nat(YE.SFS(N)), ${C.MAX}n, YE.hSle(N, hN)), {==}))
  VBE.bytes_frame(U32.to_nat(YE.SFS(N)), ${m}, ${PC}, FD.array__slots(U32, ${tree(vj + 1)}), ${S_}, hq,
    Equal.sym(${LT}, ${win(m, PC, NL)}, ${win(m, PC, vj + 1)}, child_win(${WA_})))

@@ spec_text_3 @@

  {${Tn}_encode(${OBJ}) == ${RE} : ${Tn} & B.Buf}
def encode_eval(${E.AH}):
  %Equal.sym(Array<U32>, Array.new(U32, ${DO}n, 0), FD.array__thaw(U32, VC.ZT(${DO}n)), FD.array__new(U32, ${DO}n, 0)) :
    {${Tn}_enc_put(${Tn}_putn(_, 0, ${OBJ})) == ${RE} : ${Tn} & B.Buf}
  %Equal.sym(${TY}, ${Tn}_putn(FD.array__thaw(U32, VC.ZT(${DO}n)), 0, ${OBJ}), (FD.array__thaw(U32, ${T0}), (${OBJ}, SFS(N))),
      putw(${A0}, ${', '.join(E.hargs)}, 0, {==}, {==}, FD.array__trep_perfect(U32, ${DO}n, 0), ${HD0},
        VBE.slot_zt(${DO}n, KZ(N, 0n)))) :
    {${Tn}_enc_put(_) == ${RE} : ${Tn} & B.Buf}
  %Equal.sym(Bool, O.is_poisoned(SFS(N)), False{}, VBE.np31(SFS(N), ${E.KS}n, {==}, hS(N, hN))) :
    {(${OBJ}, O.out_donep(_, SFS(N), FD.array__thaw(U32, ${T0}))) == ${RE} : ${Tn} & B.Buf}
  {==}

# The bytes the encoder writes are the spec/codec.bend encoding of the object's value.
law encode_spec:

@@ spec_text_4 @@

  Decoding.decodes(Spec.${n}(), ${BY0}, XE(${E.A}))
def encode_spec(${E.AH}):
  # the encoding opened over variables first (F.efl_bytes): the parts rewrite's motive over
  # Codec.bytes was compared with the spec encoding by running the encoder
  %F.efl_bytes(Spec.${n}(), XE(${E.A})) : {_ == Some{${BY0}} : ${M}}
  %Equal.sym(${MP}, Codec.parts(XE(${E.A}), Spec.${n}()), Some{[S.Variable{${BY0}}]},
      partsw(${A0}, ${', '.join(E.hargs)}, FD.array__trep_perfect(U32, ${DO}n, 0), ${HD0}, {==})) :
    {Codec.bytes(_) == Some{${BY0}} : ${M}}
  {==}
