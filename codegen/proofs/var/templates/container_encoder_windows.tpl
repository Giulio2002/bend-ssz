@@ GCV @@

# one field's parts before the rest's, over opaque values: the untyped cat steps' concatenate form against
# parts(Items, Chain) would evaluate the fields' parts (the big fixed pieces)
def gcv_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +y: +List<U32>, +rest: +List<S.Part>,
    +ea: {Codec.parts(v, s) == Some{[S.Variable{y}]} : Maybe<&2, +List<S.Part>>}, +eb: {Codec.parts(vs, rs) == Some{rest} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(S.Items{v, vs}, S.Chain{s, rs}) == Some{S.Variable{y} <> rest} : Maybe<&2, +List<S.Part>>}:
  VS.cat_var(Codec.parts(v, s), y, Codec.parts(vs, rs), rest, ea, eb)
def gcf_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +xs: +List<U32>, +rest: +List<S.Part>,
    +ea: {Codec.parts(v, s) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>}, +eb: {Codec.parts(vs, rs) == Some{rest} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(S.Items{v, vs}, S.Chain{s, rs}) == Some{S.Fixed{xs} <> rest} : Maybe<&2, +List<S.Part>>}:
  FX.cat_fixed(Codec.parts(v, s), xs, Codec.parts(vs, rs), rest, ea, eb)

@@ rec_leaf_text @@

# ---- ${p}: its writer on the object (the record's words; proofs/obj/encx_recs.bend) ----
def RW_${p}(o: ${lf.ctor}) -> List<&2, U32>:
${body}
${pad}[${WA}]
def PXo_${p}(o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
${body}
${pad}ER.PX_${p}(${WA}, dd, D, q, r)
def pfo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PXo_${p}(o, dd, D, q, r)) == ${TRUE}}:
${body}
${pad}ER.pf_${p}(${WA}, dd, D, q, r, pf)
def RTo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${p}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_${p}(o, dd, D, q, r)) : Array<U32>}
def BYo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXo_${p}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, FX.limbs(RW_${p}(o))) : +List<U32>}
def putxo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${B}n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${B}n, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${B}n) : +List<U32>})
    -> DK.P2(RTo_${p}(o, dd, D, X, q, r), BYo_${p}(o, dd, D, q, r)):
${body}
${pad}ER.putx_${p}(${WA}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)
def lenb_${p}(+o: ${lf.ctor}) -> {VCN.LN(FX.limbs(RW_${p}(o))) == ${B}n : Nat}:
${body}
${pad}{==}

@@ pad_leaf_text @@

# ---- ${p}: its writer on the object (one byte, zero-padded to its word's end; vuwv_${p}) ----
def OK_${p}(o: ${lf.ctor}) -> Bool:
  match o:
    case ${lf.ctor}{+w0}: Bool.and(U32.is_eq(U32.and(w0, U32.not(O.low_mask(4))), 0), U32.is_lt(w0, 256))
def RW_${p}(o: ${lf.ctor}) -> List<&2, U32>:
  match o:
    case ${lf.ctor}{+w0}: [w0]
def PXo_${p}(o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
  match o:
    case ${lf.ctor}{+w0}: ${lf.model}(r, dd, D, q, w0)
def pfo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PXo_${p}(o, dd, D, q, r)) == ${TRUE}}:
  match o:
    case ${lf.ctor}{+w0}: ${lf.pf}(r, dd, D, q, w0, pf)
def RTo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${p}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_${p}(o, dd, D, q, r)) : Array<U32>}
def BYo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXo_${p}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, List.append(&2, U32, VS.bt(1n, FX.limbs(RW_${p}(o))), UW.ZB(${PD}))) : +List<U32>}
def putxo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hv: {OK_${p}(o) == ${TRUE}}, +hz: {VS.bt(Nat.add(1n, ${PD}), VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(Nat.add(1n, ${PD})) : +List<U32>})
    -> DK.P2(RTo_${p}(o, dd, D, X, q, r), BYo_${p}(o, dd, D, q, r)):
  match o:
    case ${lf.ctor}{+w0}:
      +vt = VBB.z8(w0, FD.logic__and_right(U32.is_eq(U32.and(w0, U32.not(O.low_mask(4))), 0), U32.is_lt(w0, 256), hv))
      (${lf.rt}(dd, D, X, q, r, w0, e, hr, hd, hl, pf, vt, hz), ${lf.by}(dd, D, X, q, r, w0, e, hr, hd, hl, pf, vt, hz))
def lenb_${p}(+o: ${lf.ctor}) -> {VCN.LN(VS.bt(1n, FX.limbs(RW_${p}(o)))) == 1n : Nat}:
  match o:
    case ${lf.ctor}{+w0}: {==}

@@ pad_spec_text @@

# its spec value and parts (the decoder's vfx_${p}: VB4, bvp)
def VBo_${p}(o: ${lf.ctor}) -> S.Value:
  match o:
    case ${lf.ctor}{+w0}: VFB4.VB4(w0)
def bt1_${p}(+w0: U32) -> {VS.bt(1n, FX.limbs([w0])) == [U32.and(w0, 255)] : +List<U32>}:
  {==}
def prto_${p}(+o: ${lf.ctor}, +hv: {K.OK_${p}(o) == ${TRUE_}})
    -> {Codec.parts(VBo_${p}(o), S.BitVector{4n}) == Some{[S.Fixed{VS.bt(1n, FX.limbs(K.RW_${p}(o)))}]} : Maybe<&2, +List<S.Part>>}:
  match o:
    case ${lf.ctor}{+w0}:
      +hc = FD.logic__and_left(U32.is_eq(U32.and(w0, U32.not(O.low_mask(4))), 0), U32.is_lt(w0, 256), hv)
      +hl = FD.logic__and_right(U32.is_eq(U32.and(w0, U32.not(O.low_mask(4))), 0), U32.is_lt(w0, 256), hv)
      %Equal.sym(+List<U32>, VS.bt(1n, FX.limbs([w0])), [U32.and(w0, 255)], bt1_${p}(w0)) :
        {Codec.parts(VFB4.VB4(w0), S.BitVector{4n}) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(U32, U32.and(w0, 255), w0, VBB.ea(w0, hl)) :
        {Codec.parts(VFB4.VB4(w0), S.BitVector{4n}) == Some{[S.Fixed{[_]}]} : Maybe<&2, +List<S.Part>>}
      VFB4.bvp(w0, hc)

@@ tail_leaf_text @@

# ---- ${p}: its writer on the object (${B} bytes, data-only; vbv257) ----
def PXo_${p}(o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
  match o:
    case ${pat}: ${lf.model}(r, dd, D, q, ${WA})
def pfo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PXo_${p}(o, dd, D, q, r)) == ${TRUE}}:
  match o:
    case ${pat}: ${lf.pf}(r, dd, D, q, ${WA}, pf)
def RTo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${p}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_${p}(o, dd, D, q, r)) : Array<U32>}
def BYo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXo_${p}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, V_${p}.BYW(o)) : +List<U32>}
def putxo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${B}n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hv: {T.${p}_valid(o) == ${TRUE}}, +hz: {VS.bt(${B}n, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${B}n) : +List<U32>})
    -> DK.P2(RTo_${p}(o, dd, D, X, q, r), BYo_${p}(o, dd, D, q, r)):
  match o:
    case ${pat}:
      +e8 = VBB.e1(w${W}, hv)
      (${lf.rt}(dd, D, X, q, r, ${WA}, e, hr, hd, hl, pf, e8, hz), ${lf.by}(dd, D, X, q, r, ${WA}, e, hr, hd, hl, pf, e8, hz))
def lenb_${p}(+o: ${lf.ctor}) -> {VCN.LN(V_${p}.BYW(o)) == ${B}n : Nat}:
  match o:
    case ${pat}: {==}

@@ leaf_text @@

# ---- ${p}: its writer on the object ----
def RW_${p}(o: ${lf.ctor}) -> List<&2, U32>:
  match o:
    case ${pat}: [${WA}]
def PXo_${p}(o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
  match o:
    case ${pat}: ${lf.model}(r, dd, D, q, ${WA})
def pfo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PXo_${p}(o, dd, D, q, r)) == ${TRUE}}:
  match o:
    case ${pat}: ${lf.pf}(r, dd, D, q, ${WA}, pf)
def RTo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${p}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_${p}(o, dd, D, q, r)) : Array<U32>}
def BYo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXo_${p}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, FX.limbs(RW_${p}(o))) : +List<U32>}
def putxo_${p}(+o: ${lf.ctor}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${B}n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${B}n, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${B}n) : +List<U32>})
    -> DK.P2(RTo_${p}(o, dd, D, X, q, r), BYo_${p}(o, dd, D, q, r)):
  match o:
    case ${pat}: (${lf.rt}(dd, D, X, q, r, ${WA}, e, hr, hd, hl, pf${hz}), ${lf.by}(dd, D, X, q, r, ${WA}, e, hr, hd, hl, pf, hz))
def lenb_${p}(+o: ${lf.ctor}) -> {VCN.LN(FX.limbs(RW_${p}(o))) == ${B}n : Nat}:
  match o:
    case ${pat}: {==}

@@ generate_cont @@

# ---- ${C}: the object, its bytes and byte count ----
def OBJC(${OPS}) -> T.${C}: ${OBJ}
def LLC(${OPS}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Nat: ${LLCB}
def SZC(${OPS}) -> U32: ${SZC}

@@ module_text @@

# ${f}: its offset word, then its bytes (T.${ch.p}_putv).
def putv_${f}(${', '.join(ch.params)}, +D: ${TR}, +D1: ${TR}, +D2: ${TR}, +X: U32, +hoff: U32, +cur: U32,
    +e1: {O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur) == FD.array__thaw(U32, D1) : Array<U32>},
    +e2: {T.${ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), ${V}) == (FD.array__thaw(U32, D2), (${V}, ${ch.sz})) : ${RT}})
    -> {T.${ch.p}_putv(FD.array__thaw(U32, D), X, hoff, cur, ${V}) == (FD.array__thaw(U32, D2), (${V}, O.padd(cur, ${ch.sz}))) : ${RT}}:
  Equal.trans(${RT}, T.${ch.p}_pvb(cur, T.${ch.p}_putk(O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur), U32.add(X, cur), ${V})),
    T.${ch.p}_pvb(cur, T.${ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), ${V})), (FD.array__thaw(U32, D2), (${V}, O.padd(cur, ${ch.sz}))),
    Equal.cong(Array<U32>, ${RT}, z => T.${ch.p}_pvb(cur, T.${ch.p}_putk(z, U32.add(X, cur), ${V})), O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur), FD.array__thaw(U32, D1), e1),
    Equal.cong(${RT}, ${RT}, z => T.${ch.p}_pvb(cur, z), T.${ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), ${V}), (FD.array__thaw(U32, D2), (${V}, ${ch.sz})), e2))

@@ module_text_2 @@

# the runtime's ${gp} writes, from its writes' facts
def rt_${gp.replace(p, 'G') if gk is not None else 'C'}(${MP},
    ${FPS})
    -> {${start} == ${end} : ${RTg}}:
  ${chain(RTg, steps, start, end)}

@@ module_text_3 @@

# the runtime's put of ${C} at X
def rt_all(${MP},
    ${FPS}${GPZP})
    -> {${START} == ${ENDC} : ${RTC}}:
  ${chain_rt}

@@ _iface_writer_laws @@

def encE(${OPS}, +h: {OKT(${OAS}) == ${TRUE_}}, +k: Nat, +ek: {k == 28n : Nat})
    -> {Layout.encoding(PSC(${OAS})) == Some{${ENCCt}} : Maybe<&2, +List<U32>>}:
  +FP = LY.HDRW(PSC(${OAS}), OSC(${OAS}))
  +PAY = Layout.payloads(PSC(${OAS}))
  +hf = LY.hdr_fp(PSC(${OAS}), ${FIX}n, OSC(${OAS}), okoC(${OAS}, h, k, ek))
  +fit = CS.fitc(${FIX}n, PAY, ENDC(${OAS}), k, ek, LY.lay_end(PSC(${OAS}), ${FIX}n), okbk(${OAS}, h, k, ek))
  +e1 = LY.enc_genL(PSC(${OAS}), ${FIX}n, FP, PAY, {==}, hf, {==}, validC(${OAS}, h, k, ek), fit)
  FD.logic__subst(+List<U32>, z => {Layout.encoding(PSC(${OAS})) == Some{z} : Maybe<&2, +List<U32>>}, VCN.AP(FP, PAY), ${ENCCt},
    Equal.sym(+List<U32>, ${ENCCt}, VCN.AP(FP, PAY), cellsC(${OAS}, h)), e1)

# encx_spec, on the parameters
def specC(${OPS}, +h: {OKT(${OAS}) == ${TRUE_}}, +k: Nat, +ek: {k == 28n : Nat})
    -> {Codec.parts(VALC(${OAS}), ${SCH}) == Some{[S.Variable{${ENCCt}}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(${items(0)}, ${chain(0)}), Some{PSC(${OAS})}, partsC(${OAS}, h, k, ek)) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{${ENCCt}}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(PSC(${OAS})), Some{${ENCCt}}, encE(${OAS}, h, k, ek)) :
    {Codec.one(_, None{}) == Some{[S.Variable{${ENCCt}}]} : Maybe<&2, +List<S.Part>>}
  {==}

# the writer's byte count
def lenC(${OPS}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> {List.length(&2, U32, ${ENCCt}) == K.LLC(${OAS}, dd, D, X, q, r) : Nat}:
  +SL = Nat.add(${FIX}n, VCN.SUM([${', '.join((K.children[x['f']].len for x in VV))}]))
  +e1 = FD.logic__subst(+List<U32>, z => {List.length(&2, U32, z) == SL : Nat}, VCN.CAT([${', '.join(EP)}]), ${ENCCt}, Equal.sym(+List<U32>, ${ENCCt}, VCN.CAT([${', '.join(EP)}]), eENC(${OAS}, Unit{})),
    VCN.eposv([${', '.join(fw)}], [${', '.join((x['enc'] for x in VV))}], [${', '.join((K.children[x['f']].len for x in VV))}]))
  Equal.trans(Nat, List.length(&2, U32, ${ENCCt}), SL, K.LLC(${OAS}, dd, D, X, q, r), e1, Equal.sym(Nat, K.LLC(${OAS}, dd, D, X, q, r), SL, eLLC(${OAS}, dd, D, X, q, r)))
def lenE(${OPS}, +h: {OKT(${OAS}) == ${TRUE_}}) -> {List.length(&2, U32, ${ENCCt}) == ENDC(${OAS}) : Nat}:
  +PAY = Layout.payloads(PSC(${OAS}))
  +FP = LY.HDRW(PSC(${OAS}), OSC(${OAS}))
  +e1 = Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), ${ENCCt}, VCN.AP(VCN.CAT([${', '.join(fw)}]), PAY), cellsC(${OAS}, h))
  +e2 = VS.len_app(VCN.CAT([${', '.join(fw)}]), PAY)
  +e3 = Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, PAY)), List.length(&2, U32, FP), ${FIX}n,
    Equal.trans(Nat, List.length(&2, U32, FP), List.length(&2, U32, Layout.fixed_parts(PSC(${OAS}), ${FIX}n)), ${FIX}n,
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), FP, Layout.fixed_parts(PSC(${OAS}), ${FIX}n), Equal.sym(+List<U32>, Layout.fixed_parts(PSC(${OAS}), ${FIX}n), FP, LY.hdr_fp(PSC(${OAS}), ${FIX}n, OSC(${OAS}), okoC(${OAS}, h, 28n, {==})))),
      LY.lay_len(PSC(${OAS}), ${FIX}n)))
  Equal.trans(Nat, List.length(&2, U32, ${ENCCt}), Nat.add(${FIX}n, List.length(&2, U32, PAY)), ENDC(${OAS}),
    Equal.trans(Nat, List.length(&2, U32, ${ENCCt}), Nat.add(List.length(&2, U32, FP), List.length(&2, U32, PAY)), Nat.add(${FIX}n, List.length(&2, U32, PAY)),
      Equal.trans(Nat, List.length(&2, U32, ${ENCCt}), List.length(&2, U32, VCN.AP(FP, PAY)), Nat.add(List.length(&2, U32, FP), List.length(&2, U32, PAY)), e1, e2), e3),
    LY.lay_end(PSC(${OAS}), ${FIX}n))

@@ _iface_mw_text @@

# ==== ${C} in the encoder-window interface ====

type MW is Data:
  MW{${MWF}}

def TH(m: MW) -> T.${C}:
  match m:
    case ${MP}: K.OBJC(${OAS})
def OK(m: MW) -> Bool:
  match m:
    case ${MP}: OKT(${OAS})
def ENC(m: MW) -> +List<U32>:
  match m:
    case ${MP}: ${ENCCt}
def VAL(m: MW) -> S.Value:
  match m:
    case ${MP}: VALC(${OAS})
def SZ(m: MW) -> U32:
  match m:
    case ${MP}: K.SZC(${OAS})
def XQ(+q: Nat, +r: Nat) -> U32: U32.from_nat(Nat.add(A.quad(q), r))
def PUTX(m: MW, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
  match m:
    case ${MP}: K.PUTC(${MA})
def PADB(+r: Nat, m: MW) -> Nat: WD.PADB(r, List.length(&2, U32, ENC(m)))

def RTX(${OPS}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${K.p}_putk(FD.array__thaw(U32, D), X, K.OBJC(${OAS})) == (FD.array__thaw(U32, K.PUTC(${MA})), (K.OBJC(${OAS}), K.SZC(${OAS}))) : Array<U32> & (T.${C} & U32)}
def BYX(${OPS}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(K.PUTC(${MA})) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VCN.AP(${ENCCt}, UW.ZB(WD.PADB(r, List.length(&2, U32, ${ENCCt}))))) : +List<U32>}

def go(${OPS}, +h: {OKT(${OAS}) == ${TRUE_}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE_}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE_}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE_}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ${ENCCt})))), VB.pw(dd)) == ${TRUE_}},
    +hz: {VS.bt(Nat.add(List.length(&2, U32, ${ENCCt}), WD.PADB(r, List.length(&2, U32, ${ENCCt}))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ${ENCCt}), WD.PADB(r, List.length(&2, U32, ${ENCCt})))) : +List<U32>})
    -> DK.P2(RTX(${OAS}, dd, D, X, q, r), BYX(${OAS}, dd, D, q, r)):
  +LLv = K.LLC(${OAS}, dd, D, XQ(q, r), q, r)
  +el = lenC(${OAS}, dd, D, XQ(q, r), q, r)
  +hl2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, z))), VB.pw(dd)) == ${TRUE_}}, List.length(&2, U32, ${ENCCt}), LLv, el, hl)
  +hz2 = FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, WD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, WD.PADB(r, z))) : +List<U32>}, List.length(&2, U32, ${ENCCt}), LLv, el, hz)
  +ex = CS.exq(X, q, r, LLv, dd, e, hd, hl2)
  +e2 = FD.logic__subst(U32, z => {U32.to_nat(z) == Nat.add(A.quad(q), r) : Nat}, X, XQ(q, r), ex, e)
  +g = K.putx(${OAS}, ${HA2}, dd, D, XQ(q, r), q, r, e2, hr, hd, hl2, pf, hz2)
  +rt = K.putk_bridge(${MA}, PA(K.RTC(${MA}), DK.P2(K.BYC(${MA}), DK.P2(K.PFC(${MA}), K.SZXC(${MA}))), g))
  +g2 = PB(K.RTC(${MA}), DK.P2(K.BYC(${MA}), DK.P2(K.PFC(${MA}), K.SZXC(${MA}))), g)
  +by = PA(K.BYC(${MA}), DK.P2(K.PFC(${MA}), K.SZXC(${MA})), g2)
  +rt2 = FD.logic__subst(U32, z => {T.${K.p}_putk(FD.array__thaw(U32, D), z, K.OBJC(${OAS})) == (FD.array__thaw(U32, K.PUTC(${MA})), (K.OBJC(${OAS}), K.SZC(${OAS}))) : Array<U32> & (T.${C} & U32)},
    XQ(q, r), X, Equal.sym(U32, X, XQ(q, r), ex), rt)
  +by2 = FD.logic__subst(Nat, z => {UA.BYT(K.PUTC(${MA})) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VCN.AP(${ENCCt}, UW.ZB(WD.PADB(r, z)))) : +List<U32>},
    LLv, List.length(&2, U32, ${ENCCt}), Equal.sym(Nat, List.length(&2, U32, ${ENCCt}), LLv, el), by)
  (rt2, by2)

@@ _iface_hyps_text @@

# ---- the interface's laws ----------------------------------------------------------------------

law putx:
${HYPS}  {T.${K.p}_putk(FD.array__thaw(U32, D), X, TH(m)) == (FD.array__thaw(U32, PUTX(m, dd, D, q, r)), (TH(m), SZ(m))) : Array<U32> & (T.${C} & U32)}
def putx(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case ${MP}: PA(RTX(${OAS}, dd, D, X, q, r), BYX(${OAS}, dd, D, q, r), go(${OAS}, hok, dd, D, X, q, r, e, hr, hd, pf, hl, hz))

law putx_bytes:
${HYPS}  {UA.BYT(PUTX(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, ENC(m), UW.ZB(PADB(r, m)))) : +List<U32>}
def putx_bytes(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case ${MP}: PB(RTX(${OAS}, dd, D, X, q, r), BYX(${OAS}, dd, D, q, r), go(${OAS}, hok, dd, D, X, q, r, e, hr, hd, pf, hl, hz))

law szx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {U32.to_nat(SZ(m)) == List.length(&2, U32, ENC(m)) : Nat}
def szx(m, hok):
  match m:
    case ${MP}: Equal.trans(Nat, U32.to_nat(K.SZC(${OAS})), ENDC(${OAS}), List.length(&2, U32, ${ENCCt}), szC(${OAS}, hok, 28n, {==}), Equal.sym(Nat, List.length(&2, U32, ${ENCCt}), ENDC(${OAS}), lenE(${OAS}, hok)))

# The bytes within 4 2^k (k = 28, kept symbolic).
law bndx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  for +k: Nat
  for +ek: {k == 28n : Nat}
  {Nat.is_le(List.length(&2, U32, ENC(m)), A.quad(VB.pw(k))) == True{} : Bool}
def bndx(m, hok, k, ek):
  match m:
    case ${MP}: FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(k))) == True{} : Bool}, ENDC(${OAS}), List.length(&2, U32, ${ENCCt}), Equal.sym(Nat, List.length(&2, U32, ${ENCCt}), ENDC(${OAS}), lenE(${OAS}, hok)), okbk(${OAS}, hok, k, ek))

law encx_spec:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {Codec.parts(VAL(m), ${SCH}) == Some{[S.Variable{ENC(m)}]} : Maybe<&2, +List<S.Part>>}
def encx_spec(m, hok):
  match m:
    case ${MP}: specC(${OAS}, hok, 28n, {==})

law domx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {SP.bytes_domain(ENC(m)) == True{} : Bool}
def domx(m, hok):
  match m:
    case ${MP}: CS.domv(VALC(${OAS}), ${SCH}, ${ENCCt}, {==}, specC(${OAS}, hok, 28n, {==}))

@@ _iface_child_max @@

# The bytes' bound: the fixed part and the children's bounds.
def maxC(${OPS}, +h: {OKT(${OAS}) == ${TRUE_}}) -> {Nat.is_le(ENDC(${OAS}), ${B_}n) == ${TRUE_}}:
  ${prf}

law maxx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {Nat.is_le(List.length(&2, U32, ENC(m)), ${B_}n) == True{} : Bool}
def maxx(m, hok):
  match m:
    case ${MP}: FD.logic__subst(Nat, z => {Nat.is_le(z, ${B_}n) == True{} : Bool}, ENDC(${OAS}), List.length(&2, U32, ${ENCCt}), Equal.sym(Nat, List.length(&2, U32, ${ENCCt}), ENDC(${OAS}), lenE(${OAS}, hok)), maxC(${OAS}, hok))

@@ iface_text @@

law pfx:
  for +m: MW
  for +dd: Nat
  for +D: ${TR}
  for +q: Nat
  for +r: Nat
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  {FD.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == True{} : Bool}
def pfx(m, dd, D, q, r, pf):
  match m:
    case ${MP}: ${pfs}

@@ iface_text_2 @@

def sizeC(${OPS}, +h: {OKT(${OAS}) == ${TRUE_}}) -> {T.${K.p}_size(K.OBJC(${OAS})) == (K.OBJC(${OAS}), K.SZC(${OAS})) : T.${C} & U32}:
${RTS}

law sizex:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.${K.p}_size(TH(m)) == (TH(m), SZ(m)) : T.${C} & U32}
def sizex(m, hok):
  match m:
    case ${MP}: sizeC(${OAS}, hok)

@@ iface_text_3 @@

def rvalidC(${OPS}, +h: {OKT(${OAS}) == ${TRUE_}}) -> {T.${K.p}_valid(K.OBJC(${OAS})) == (K.OBJC(${OAS}), True{}) : T.${C} & Bool}:
${RTV}

law validx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.${K.p}_valid(TH(m)) == (TH(m), True{}) : T.${C} & Bool}
def validx(m, hok):
  match m:
    case ${MP}: rvalidC(${OAS}, hok)

@@ iface_text_3f @@

def rvalidC(${OPS}, +h: {OKT(${OAS}) == ${TRUE_}}) -> {T.${K.p}_valid_f(K.OBJC(${OAS})) == (K.OBJC(${OAS}), True{}) : T.${C} & Bool}:
${RTV}

# the fields' validity (`_valid_f`) and the size pass within NMAX (docs/CRASH_HUNT.md R4-05)
def validx_f(m: MW, +hok: {OK(m) == True{} : Bool}) -> {T.${K.p}_valid_f(TH(m)) == (TH(m), True{}) : T.${C} & Bool}:
  match m:
    case ${MP}: rvalidC(${OAS}, hok)
law validx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.${K.p}_valid(TH(m)) == (TH(m), True{}) : T.${C} & Bool}
def validx(m, hok):
  %Equal.sym(T.${C} & Bool, T.${K.p}_valid_f(TH(m)), (TH(m), True{}), validx_f(m, hok)) : {T.${K.p}_vsz(_) == (TH(m), True{}) : T.${C} & Bool}
  %Equal.sym(T.${C} & U32, T.${K.p}_size(TH(m)), (TH(m), SZ(m)), sizex(m, hok)) : {T.${K.p}_vsz_go(True{}, _) == (TH(m), True{}) : T.${C} & Bool}
  %Equal.sym(Bool, O.is_poisoned(SZ(m)), False{}, VB.np_qk(SZ(m), List.length(&2, U32, ENC(m)), 28n, {==}, szx(m, hok), bndx(m, hok, 28n, {==}))) :
    {(TH(m), Bool.and(True{}, Bool.not(_))) == (TH(m), True{}) : T.${C} & Bool}
  {==}


@@ full_text @@

# The container's checked writer T.${K.p}_putk is its putn (one definitional step): the writer's fact
# as a parent's putv states it.
def putk_bridge(${OPS_}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +h: RTC(${MA_}))
    -> {T.${K.p}_putk(FD.array__thaw(U32, D), X, OBJC(${OAS_})) == (FD.array__thaw(U32, PUTC(${MA_})), (OBJC(${OAS_}), SZC(${OAS_}))) : Array<U32> & (T.${C} & U32)}:
  h
@@ putx_core @@
def putcq(${pp}) -> {${mcall} == PUTC${margs} : FD.array__Tree<U32>}:
  {==}

def encq(${pe}, ${szp}) -> {${cat} == ENCCs(${oas}, ${szs}) : +List<U32>}:
  {==}


@@ spec_one_step @@
def vwcU(${pp}) -> {S.Sequence{${items}} == ${VALC} : S.Value}:
  {==}
def lctU(+it: S.Value) -> {Codec.aggregate(Codec.parts(it, ${chain}), None{}) == Codec.parts(S.Sequence{it}, ${SP_}) : ${MB}}:
  {==}

@@ u32_encE @@
def fsS${n_}(${sig})
    -> {Layout.fixed_size([${', '.join(ps_)}]) == U32.to_nat(${tot[0]}) : Nat}:
  ${cp}


@@ u32_encE_2 @@
# the fixed size at F (a variable)
def fszC(${OPSp}, ${PSP}, +SZF: Nat, +eSZF: {SZF == ${UF} : Nat})
    -> {Layout.fixed_size(${PSS}) == SZF : Nat}:
  Equal.trans(Nat, Layout.fixed_size(${PSS}), ${UF}, SZF, FD.logic__subst(+List<S.Part>, zl => {Layout.fixed_size(zl) == ${UF} : Nat}, ${LST}, ${PSS}, {==}, ${prf}), Equal.sym(Nat, SZF, ${UF}, eSZF))


@@ chunk_putx @@


def putx_ch${c}(${sig})
    -> CT${c}_0(${ALL}):

@@ pfc_text @@

# the transactions list's writer: its tree is perfect
law etwlm:
  for +k: Nat
  for +W: List<&2, ET.MB<ET.WMr>>
  for +s: Nat
  for +cur: U32
  for +dd: Nat
  for +D: ${TR}
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}}
  {FD.array__perfect(U32, dd, ET.WLM(k, W, s, cur, dd, D, X, q, r)) == ${TRUE}}
def etwlm(k, W, s, cur, dd, D, X, q, r, pf):
  match k:
    case 0n: pf
    case 1n+ +j:
      etwlm(j, W, 1n+s, O.padd(cur, ET.NE(ET.xat_${P}(W, s))), dd, ET.PWE(ET.xat_${P}(W, s), dd, WD.W32X(r, dd, D, Nat.add(s, q), cur), ET.QX(U32.add(X, cur)), ET.RX(U32.add(X, cur))), X, q, r,
        ET.pwe_perfect(ET.xat_${P}(W, s), dd, WD.W32X(r, dd, D, Nat.add(s, q), cur), ET.QX(U32.add(X, cur)), ET.RX(U32.add(X, cur)), WD.w32x_perfect(r, dd, D, Nat.add(s, q), cur, pf)))
def etpflb(+b: Bool, +t: FD.array__Tree<ET.MB<ET.WMr>>, +N: U32, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, ET.PUTLb(b, t, N, dd, D, X, q, r)) == ${TRUE}}:
  match b:
    case True{}: pf
    case False{}: etwlm(U32.to_nat(N), ET.SL(t), 0n, U32.mul(4, N), dd, D, X, q, r, pf)

@@ _union_arm_go_lemma @@
def go${j}(${HYP})
    -> DK.P2(RT${j}(x, dd, D, X, q, r), BY${j}(x, dd, D, q, r)):
  +E = ${E}
  +hok0 = and_l(${ea}.OK(x), ${B}, hok)
  +rts = VU.sel_rt(dd, D, X, q, r, ${S_}, E, e, hr, hd, hl, pf)
  +bys = VU.sel_by(dd, D, X, q, r, ${S_}, E, WD.PADB(r, 1n+E), e, hr, hd, hl, pf, hz)
  +pfs = VU.sel_pf(dd, D, q, r, ${S_}, pf)
  +hX = VRX.xstart(q, r, 1n+E, dd, D, pf, hl)
  +ea = VU.arm_e(dd, X, q, r, E, e, hr, hd, hl)
  +hla = VU.aroom(q, r, E, dd, hr, hl)
  +hza = VU.arm_hz(dd, D, q, r, ${S_}, E, hr, hX, bys, hz)
  +rta = ${ea}.putx(x, dd, ${DS}, U32.add(X, 1), VU.AQ(q, r), VU.AR(r), ea, VU.ar_lt(r), hd, pfs, hla, hza, hok0)
  +bya = ${ea}.putx_bytes(x, dd, ${DS}, U32.add(X, 1), VU.AQ(q, r), VU.AR(r), ea, VU.ar_lt(r), hd, pfs, hla, hza, hok0)
  +by = VU.ubytes(dd, D, PUTX${j}(x, dd, D, q, r), q, r, ${S_}, ${ea}.ENC(x), hr, hX, bys, bya)
  +rt = rt${j}(x, dd, D, X, q, r, hok0, rts, rta)
  mk${j}(x, dd, D, X, q, r, rt, by)

@@ _union_arm_go_lemma_2 @@

def rt${j}(+x: ${xt}, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +hok0: {${ea}.OK(x) == ${TRU}},
    +rts: {O.w8(FD.array__thaw(U32, D), X, ${S_}) == FD.array__thaw(U32, ${DS}) : Array<U32>},
    +rta: {T.${A}_putk(FD.array__thaw(U32, ${DS}), U32.add(X, 1), ${ea}.TH(x)) == (FD.array__thaw(U32, PUTX${j}(x, dd, D, q, r)), (${ea}.TH(x), ${ea}.SZ(x))) : Array<U32> & (T.${A} & U32)})
    -> RT${j}(x, dd, D, X, q, r):
  %Equal.sym(T.${A} & Bool, T.${A}_valid(${ea}.TH(x)), (${ea}.TH(x), True{}), ${ea}.validx(x, hok0)) :
    {T.${U}_pk(FD.array__thaw(U32, D), X, T.${U}_va${j}(_)) == ${END} : ${TY}}
  %Equal.sym(T.${A} & U32, T.${A}_size(${ea}.TH(x)), (${ea}.TH(x), ${ea}.SZ(x)), ${ea}.sizex(x, hok0)) :
    {T.${U}_putn_sz(FD.array__thaw(U32, D), X, T.${U}_sz${j}(_)) == ${END} : ${TY}}
  %Equal.sym(Array<U32>, O.w8(FD.array__thaw(U32, D), X, ${S_}), FD.array__thaw(U32, ${DS}), rts) :
    {T.${U}_putn_fin(SZ${j}(x), T.${U}_pb${j}(T.${A}_put(_, U32.add(X, 1), ${ea}.TH(x)))) == ${END} : ${TY}}
  %Equal.sym(Array<U32> & (T.${A} & U32), T.${A}_putk(FD.array__thaw(U32, ${DS}), U32.add(X, 1), ${ea}.TH(x)), (FD.array__thaw(U32, PUTX${j}(x, dd, D, q, r)), (${ea}.TH(x), ${ea}.SZ(x))), rta) :
    {T.${U}_putn_fin(SZ${j}(x), T.${U}_pb${j}(T.${A}_put_drop(_))) == ${END} : ${TY}}
  {==}
@@ _union_arm_go_lemma_3 @@
def go${j}(${HYP})
    -> DK.P2(RT${j}(x, dd, D, X, q, r), BY${j}(x, dd, D, q, r)):
  +rts = VU.sel_rt(dd, D, X, q, r, ${S_}, 1n, e, hr, hd, hl, pf)
  +bys = VU.sel_by(dd, D, X, q, r, ${S_}, 1n, WD.PADB(r, 2n), e, hr, hd, hl, pf, hz)
  +pfs = VU.sel_pf(dd, D, q, r, ${S_}, pf)
  +hX = VRX.xstart(q, r, 2n, dd, D, pf, hl)
  +eY = Equal.trans(Nat, U32.to_nat(U32.add(X, 1)), ${Xn}, 1n+VU.X0(q, r), VU.arm_e(dd, X, q, r, 1n, e, hr, hd, hl), VU.apos(q, r, hr))
  +hb = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dd))) == ${TRU}}, Nat.add(VU.X0(q, r), 2n), 1n+Nat.add(VU.X0(q, r), 1n), FD.nat__add_succ(VU.X0(q, r), 1n),
    VRX.xend(q, r, 2n, dd, hl))
  +e0 = VRB.fposb(dd, U32.add(X, 1), 0, 1n+VU.X0(q, r), 1n, eY, hd, hb, {==})
  +rtw = VRB.w8p_rt(dd, ${DS}, ${Y0}, ${P_}, x, e0, hd, hb, pfs)
  +hza = VU.arm_hz(dd, D, q, r, ${S_}, 1n, hr, hX, bys, hz)
  +hz1 = FD.logic__subst(Nat, z => {VS.bt(1n, VS.bdr(z, UA.BYT(${DS}))) == UW.ZB(1n) : +List<U32>}, ${Xn}, ${P_}, VU.apos(q, r, hr),
    VRX.zhead(1n, ${PB_}, VS.bdr(${Xn}, UA.BYT(${DS})), hza))
  +byw = VRB.w8p_bytes(dd, ${DS}, ${Y0}, ${P_}, x, e0, hd, hb, pfs, hz1)
  +zt = VRX.ztail(1n, ${PB_}, VS.bdr(${Xn}, UA.BYT(${DS})), hza)
  +zt2 = FD.logic__subst(+List<U32>, zz => {VS.bt(${PB_}, zz) == UW.ZB(${PB_}) : +List<U32>}, VS.bdr(1n, VS.bdr(${Xn}, UA.BYT(${DS}))), VS.bdr(Nat.add(${Xn}, 1n), UA.BYT(${DS})),
    Equal.sym(+List<U32>, VS.bdr(Nat.add(${Xn}, 1n), UA.BYT(${DS})), VS.bdr(1n, VS.bdr(${Xn}, UA.BYT(${DS}))), UW.bdr_add(${Xn}, 1n, UA.BYT(${DS}))), zt)
  +hzt = FD.logic__subst(Nat, z => {VS.bt(${PB_}, VS.bdr(Nat.add(z, 1n), UA.BYT(${DS}))) == UW.ZB(${PB_}) : +List<U32>}, ${Xn}, ${P_}, VU.apos(q, r, hr), zt2)
  +ext = WD.spl_ext(UA.BYT(${DS}), ${P_}, ${b8}, ${PB_}, hzt)
  +by2p = Equal.trans(+List<U32>, UA.BYT(PUTX${j}(x, dd, D, q, r)), UW.SPL(UA.BYT(${DS}), ${P_}, ${b8}), UW.SPL(UA.BYT(${DS}), ${P_}, List.append(&2, U32, ${b8}, UW.ZB(${PB_}))), byw, ext)
  +by2 = FD.logic__subst(Nat, z => {UA.BYT(PUTX${j}(x, dd, D, q, r)) == UW.SPL(UA.BYT(${DS}), z, List.append(&2, U32, ${b8}, UW.ZB(${PB_}))) : +List<U32>}, ${P_}, ${Xn},
    Equal.sym(Nat, ${Xn}, ${P_}, VU.apos(q, r, hr)), by2p)
  +by = VU.ubytes(dd, D, PUTX${j}(x, dd, D, q, r), q, r, ${S_}, ${b8}, hr, hX, bys, by2)
  +rt = rt${j}(x, dd, D, X, q, r, hok, rts, rtw)
  mk${j}(x, dd, D, X, q, r, rt, by)

@@ _union_arm_go_lemma_4 @@

def rt${j}(+x: U32, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +hok: {OK${j}(x) == ${TRU}},
    +rts: {O.w8(FD.array__thaw(U32, D), X, ${S_}) == FD.array__thaw(U32, ${DS}) : Array<U32>},
    +rtw: {T.u8_put(FD.array__thaw(U32, ${DS}), ${Y0}, x) == FD.array__thaw(U32, PUTX${j}(x, dd, D, q, r)) : Array<U32>})
    -> RT${j}(x, dd, D, X, q, r):
  %Equal.sym(Bool, U32.is_le(x, 255), True{}, hok) :
    {T.${U}_pk(FD.array__thaw(U32, D), X, (TH${j}(x), _)) == ${END} : ${TY}}
  %Equal.sym(Array<U32>, O.w8(FD.array__thaw(U32, D), X, ${S_}), FD.array__thaw(U32, ${DS}), rts) :
    {T.${U}_putn_fin(2, (T.${A}_put(_, U32.add(X, 1), T.${A}{x}), TH${j}(x))) == ${END} : ${TY}}
  %Equal.sym(Array<U32>, T.u8_put(FD.array__thaw(U32, ${DS}), ${Y0}, x), FD.array__thaw(U32, PUTX${j}(x, dd, D, q, r)), rtw) :
    {T.${U}_putn_fin(2, (_, TH${j}(x))) == ${END} : ${TY}}
  {==}
@@ _union_arm_prefix_lemma @@
def pfx${j}(+x: ${xt}, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRU}})
    -> {FD.array__perfect(U32, dd, PUTX${j}(x, dd, D, q, r)) == ${TRU}}:
  ${ea}.pfx(x, dd, ${DS}, VU.AQ(q, r), VU.AR(r), VU.sel_pf(dd, D, q, r, ${S_}, pf))
def bnd${j}(+x: ${xt}, +hok: {OK${j}(x) == ${TRU}}, +k: Nat, +ek: {k == 28n : Nat}) -> {Nat.is_le(List.length(&2, U32, ENC${j}(x)), A.quad(VB.pw(k))) == ${TRU}}:
  FD.logic__subst(Nat, z => {Nat.is_le(1n+${E}, A.quad(VB.pw(z))) == ${TRU}}, 28n, k, Equal.sym(Nat, k, 28n, ek), and_r(${ea}.OK(x), ${B}, hok))
def szk${j}(+x: ${xt}, +hok: {OK${j}(x) == ${TRU}}, +k: Nat, +ek: {k == 28n : Nat}) -> {U32.to_nat(SZ${j}(x)) == List.length(&2, U32, ENC${j}(x)) : Nat}:
  VU.padd1_at(${ea}.SZ(x), ${E}, k, ek, ${ea}.szx(x, and_l(${ea}.OK(x), ${B}, hok)), bnd${j}(x, hok, k, ek))
def spec${j}(+x: ${xt}, +hok: {OK${j}(x) == ${TRU}}) -> {Codec.parts(VAL${j}(x), Spec.${U}()) == Some{[S.Variable{ENC${j}(x)}]} : Maybe<&2, +List<S.Part>>}:
  VU.tag_v(${S_}, ${ea}.VAL(x), Spec.${A}(), ${ea}.ENC(x), ${ea}.encx_spec(x, and_l(${ea}.OK(x), ${B}, hok)))
def size${j}(+x: ${xt}, +hok: {OK${j}(x) == ${TRU}}) -> {T.${U}_size(TH${j}(x)) == (TH${j}(x), SZ${j}(x)) : T.${U} & U32}:
  %Equal.sym(T.${A} & U32, T.${A}_size(${ea}.TH(x)), (${ea}.TH(x), ${ea}.SZ(x)), ${ea}.sizex(x, and_l(${ea}.OK(x), ${B}, hok))) : {T.${U}_sz${j}(_) == (TH${j}(x), SZ${j}(x)) : T.${U} & U32}
  {==}
def valid${j}(+x: ${xt}, +hok: {OK${j}(x) == ${TRU}}) -> {T.${U}_valid(TH${j}(x)) == (TH${j}(x), True{}) : T.${U} & Bool}:
  %Equal.sym(T.${A} & Bool, T.${A}_valid(${ea}.TH(x)), (${ea}.TH(x), True{}), ${ea}.validx(x, and_l(${ea}.OK(x), ${B}, hok))) : {T.${U}_va${j}(_) == (TH${j}(x), True{}) : T.${U} & Bool}
  {==}
@@ _union_arm_prefix_lemma_2 @@
def pfx${j}(+x: U32, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRU}})
    -> {FD.array__perfect(U32, dd, PUTX${j}(x, dd, D, q, r)) == ${TRU}}:
  VRB.w8p_perfect(dd, ${DS}, Nat.add(0n, 1n+VU.X0(q, r)), x, VU.sel_pf(dd, D, q, r, ${S_}, pf))
def bnd${j}(+x: U32, +hok: {OK${j}(x) == ${TRU}}, +k: Nat, +ek: {k == 28n : Nat}) -> {Nat.is_le(List.length(&2, U32, ENC${j}(x)), A.quad(VB.pw(k))) == ${TRU}}:
  FD.nat__le_trans(2n, 4n, A.quad(VB.pw(k)), {==}, VCN.VME4(1n, VB.pw(k), FD.nat__pow2_pos(k)))
def szk${j}(+x: U32, +hok: {OK${j}(x) == ${TRU}}, +k: Nat, +ek: {k == 28n : Nat}) -> {U32.to_nat(SZ${j}(x)) == List.length(&2, U32, ENC${j}(x)) : Nat}: {==}
def spec${j}(+x: U32, +hok: {OK${j}(x) == ${TRU}}) -> {Codec.parts(VAL${j}(x), Spec.${U}()) == Some{[S.Variable{ENC${j}(x)}]} : Maybe<&2, +List<S.Part>>}:
  VU.tag_f(${S_}, RV8(x), Spec.${A}(), [U32.and(x, 255)], rprf(x))
def size${j}(+x: U32, +hok: {OK${j}(x) == ${TRU}}) -> {T.${U}_size(TH${j}(x)) == (TH${j}(x), SZ${j}(x)) : T.${U} & U32}: {==}
def valid${j}(+x: U32, +hok: {OK${j}(x) == ${TRU}}) -> {T.${U}_valid(TH${j}(x)) == (TH${j}(x), True{}) : T.${U} & Bool}:
  %Equal.sym(Bool, U32.is_le(x, 255), True{}, hok) : {(TH${j}(x), _) == (TH${j}(x), True{}) : T.${U} & Bool}
  {==}
@@ _union_ctor_text @@

# ---- the union's mirror and its interface ----
type MW is Data:
${ctors}
def TH(m: MW) -> T.${U}:
${mt('', 'TH')}
def OK(m: MW) -> Bool:
${mt('', 'OK')}
def ENC(m: MW) -> +List<U32>:
${mt('', 'ENC')}
def VAL(m: MW) -> S.Value:
${mt('', 'VAL')}
def SZ(m: MW) -> U32:
${mt('', 'SZ')}
def PUTX(m: MW, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat) -> FD.array__Tree<U32>:
${mt('', 'PUTX', args=', dd, D, q, r')}
def PADB(+r: Nat, m: MW) -> Nat: WD.PADB(r, List.length(&2, U32, ENC(m)))

@@ union_text @@

# ---- arm ${j}: ${A}, selector ${s} ----
def TH${j}(+x: ${xt}) -> T.${U}: ${TH}
def OK${j}(+x: ${xt}) -> Bool: ${OK}
def ENC${j}(+x: ${xt}) -> +List<U32>: ${ENC}
def VAL${j}(+x: ${xt}) -> S.Value: ${VAL}
def SZ${j}(+x: ${xt}) -> U32: ${SZ}
def PUTX${j}(+x: ${xt}, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat) -> FD.array__Tree<U32>: ${PUTX}
def RT${j}(+x: ${xt}, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${U}_putk(FD.array__thaw(U32, D), X, TH${j}(x)) == (FD.array__thaw(U32, PUTX${j}(x, dd, D, q, r)), (TH${j}(x), SZ${j}(x))) : ${TY}}
def BY${j}(+x: ${xt}, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PUTX${j}(x, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, List.append(&2, U32, ENC${j}(x), UW.ZB(WD.PADB(r, List.length(&2, U32, ENC${j}(x)))))) : +List<U32>}
def mk${j}(+x: ${xt}, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +a: RT${j}(x, dd, D, X, q, r), +b: BY${j}(x, dd, D, q, r)) -> DK.P2(RT${j}(x, dd, D, X, q, r), BY${j}(x, dd, D, q, r)):
  (a, b)
@@ union_text_2 @@
+x: ${xt}, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRU}},
    +hd: {Nat.is_lt(dd, 29n) == ${TRU}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRU}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC${j}(x))))), VB.pw(dd)) == ${TRU}},
    +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC${j}(x)), WD.PADB(r, List.length(&2, U32, ENC${j}(x)))), VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC${j}(x)), WD.PADB(r, List.length(&2, U32, ENC${j}(x))))) : +List<U32>},
    +hok: {OK${j}(x) == ${TRU}}