@@ rd_comp_lemma @@
# The masked storage of a whole-word copy is the copy's words.
def mkid(+L: U32, +dz: Nat, +M: FD.array__Tree<U32>, +h: {U32.is_eq(VY.RM(L), 0) == True{} : Bool}) -> {VY.MK(L, dz, M) == M : FD.array__Tree<U32>}:
  %Equal.sym(Bool, U32.is_eq(VY.RM(L), 0), True{}, h) : {VY.mk(_, L, dz, M) == M : FD.array__Tree<U32>}
  {==}

# The word count as a literal, reached by evaluating Nat.is_eq (the checker's machine loops over a unary
# numeral without recursing) instead of by a conversion, which would recurse once per unit of ${wW}.
def nwq_${p}() -> {VC.NW(${ws}) == ${wW}n : Nat}:
  FD.nat__eq_from_is_eq(VC.NW(${ws}), ${wW}n, {==})

# copy_into_any's words at off = 4 i, as the ${wW} words from i (the rewrite keeps both trees unevaluated).
def cpeq_${p}(+t: FD.array__Tree<U32>, +i: Nat) -> {${MKT} == ${MO} : FD.array__Tree<U32>}:
  Equal.trans(FD.array__Tree<U32>, ${MKT}, ${MN}, ${MO}, mkid(${ws}, ${dz}n, ${MN}, {==}),
    Equal.cong(Nat, FD.array__Tree<U32>, z => VB.mone(z, i, 0n, ${dz}n, VC.ZT(${dz}n), t), VC.NW(${ws}), ${wW}n, nwq_${p}()))

def cp_${p}(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hd31: {Nat.is_lt(d, 31n) == True{} : Bool}, +e0: {U32.to_nat(U32.shrn(U32.add(off, 0), 2n)) == i : Nat}, +h3: {U32.and(U32.add(off, 0), 3) == 0 : U32},
    +hbw: {Nat.is_le(Nat.add(${wW}n, Nat.add(0n, i)), VB.pw(d)) == True{} : Bool})
    -> {T.${f['wp']}_read(VF.BF(t, n), U32.add(off, 0), ${ws}) == (VF.BF(t, n), ${WO}) : B.Buf & O.Words}:
  %cpeq_${p}(t, i) : {T.${f['wp']}_read(VF.BF(t, n), U32.add(off, 0), ${ws}) == (VF.BF(t, n), O.Words{FD.array__thaw(U32, _), ${ws}}) : B.Buf & O.Words}
  # hbw with the word count named (VC.NW(${ws}), as copy_into_any states it): each step is a motive
  # over a variable, so no conversion evaluates ${wW} in unary
  +hbi = FD.logic__subst(Nat, w => {Nat.is_le(Nat.add(${wW}n, w), VB.pw(d)) == True{} : Bool}, Nat.add(0n, i), i, {==}, hbw)
  +hbN = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, i), VB.pw(d)) == True{} : Bool}, ${wW}n, VC.NW(${ws}), Equal.sym(Nat, VC.NW(${ws}), ${wW}n, nwq_${p}()), hbi)
  VY.copy_into_any(d, t, n, U32.add(off, 0), i, ${ws}, ${dz}n, ${kw}n, pf, hd31, {==}, h3, e0, hbN, {==}, {==}, {==})

# The ${p} reader at off = 4 i: its packed words are a copy of words i .., its record the next words.
def hq4(+k: Nat, +i: Nat, +d: Nat, +W: Nat, +h: {Nat.is_le(Nat.add(W, Nat.add(k, i)), VB.pw(d)) == True{} : Bool})
    -> {Nat.is_le(A.quad(Nat.add(k, i)), VB.pw(2n+d)) == True{} : Bool}:
  +h1 = FD.nat__le_trans(Nat.add(k, i), Nat.add(W, Nat.add(k, i)), VB.pw(d), Order.left_below_sum(W, Nat.add(k, i)), h)
  Order.double_monotone(Nat.double(Nat.add(k, i)), Nat.double(VB.pw(d)), Order.double_monotone(Nat.add(k, i), VB.pw(d), h1))

def rd_comp_${p}(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +e: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, ${VBY.PF}, +hb: {Nat.is_le(Nat.add(${W}n, i), VB.pw(d)) == True{} : Bool})
    -> {T.${p}_read(VF.BF(t, n), off, ${f['size']}) == ${RHS} : ${TY}}:
  +hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {==})
  +hbw = FD.nat__le_trans(Nat.add(${wW}n, Nat.add(0n, i)), Nat.add(${W}n, i), VB.pw(d), Order.add_right(${wW}n, ${W}n, i, {==}), hb)
  +hbr = FD.nat__le_trans(Nat.add(${rft.W}n, Nat.add(${wW}n, i)), Nat.add(${W}n, i), VB.pw(d), Order.add_right(${rft.W + wW}n, ${W}n, i, {==}), hb)
  +e0 = VF.off_add(off, 0, i, 0n, 2n+d, e, {==}, hd, hq4(0n, i, d, ${wW}n, hbw))
  %Equal.sym(B.Buf & O.Words, T.${f['wp']}_read(VF.BF(t, n), U32.add(off, 0), ${ws}), (VF.BF(t, n), ${WO}),
      cp_${p}(d, t, n, off, i, pf, hd31, VF.al_q(U32.add(off, 0), i, e0), VF.al_3(U32.add(off, 0), i, e0), hbw)) :
    {T.${p}_rd0(off, ${f['size']}, _) == ${RHS} : ${TY}}
  %Equal.sym(${'B.Buf & ' + rft.rep()}, T.${rft.p}_read(VF.BF(t, n), U32.add(off, ${ws}), ${rft.size}), (VF.BF(t, n), ${RO}),
      VT.rd_${rft.p}(d, t, n, U32.add(off, ${ws}), Nat.add(${wW}n, i), VF.off_add(off, ${ws}, i, ${wW}n, 2n+d, e, ${VBN.ecq(wW, ws)}, hd, hq4(${wW}n, i, d, ${rft.W}n, hbr)), hd, pf, hbr)) :
    {T.${p}_rd1(off, ${f['size']}, ${WO}, _) == ${RHS} : ${TY}}
  {==}

@@ shk @@
# at a symbolic K: Nat.add(K, a + i) == Nat.add(a + K, i); instantiated at literals it converts
# without walking K in unary
def shiftk(+a: Nat, +K: Nat, +i: Nat) -> {Nat.add(K, Nat.add(a, i)) == Nat.add(Nat.add(a, K), i) : Nat}:
  Equal.trans(Nat, Nat.add(K, Nat.add(a, i)), Nat.add(Nat.add(K, a), i), Nat.add(Nat.add(a, K), i),
    Equal.sym(Nat, Nat.add(Nat.add(K, a), i), Nat.add(K, Nat.add(a, i)), FD.nat__add_assoc(K, a, i)),
    Equal.cong(Nat, Nat, z => Nat.add(z, i), Nat.add(K, a), Nat.add(a, K), FD.nat__add_comm(K, a)))

@@ spec_part_seg @@

# ---- the spec side (header segments, one of them the ${cf['p']}'s symbolic words) ---------------

def lcomp(+t: FD.array__Tree<U32>, +i: Nat, ${HLW}) -> {List.length(&2, U32, ${CT}) == ${cf['W']}n : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, ${CT}), Nat.add(List.length(&2, U32, ${WPK}), List.length(&2, U32, [${G}])), VZ.len_sapp(${WPK}, [${G}])) : {_ == ${cf['W']}n : Nat}
  %Equal.sym(Nat, List.length(&2, U32, ${WPK}), FD.spec_common__length(U32, ${WPK}), VZ.len_list(${WPK})) : {Nat.add(_, List.length(&2, U32, [${G}])) == ${cf['W']}n : Nat}
  %Equal.sym(Nat, FD.spec_common__length(U32, ${WPK}), ${cf['wW']}n, hlW) : {Nat.add(_, List.length(&2, U32, [${G}])) == ${cf['W']}n : Nat}
  FD.nat__eq_from_is_eq(Nat.add(${cf['wW']}n, List.length(&2, U32, [${G}])), ${cf['W']}n, {==})

def hF(+t: FD.array__Tree<U32>, +i: Nat, ${HLW}) -> {VS.FSZ(${PRE}, ${POST}) == ${FSN} : Nat}:
${HFS}

# The value of the window's fixed words and the child's value V.
def XVw(+t: FD.array__Tree<U32>, +i: Nat, +V: S.Value) -> S.Value: S.Sequence{${ITEMS}}

# Its spec parts: one variable part, the header's bytes (the offset is ${FS}) and the child's bytes Yb.
def encpw(+t: FD.array__Tree<U32>, +i: Nat, +V: S.Value, +Yb: +List<U32>,
    +hv: {Codec.parts(V, Spec.${Y}()) == Some{[S.Variable{Yb}]} : ${MP}}, +hdom: {SP.bytes_domain(Yb) == True{} : Bool},
    +fit: {N.fits(4n, Nat.add(${FSN}, List.length(&2, U32, Yb))) == True{} : Bool}, ${HLW})
    -> {Codec.parts(XVw(t, i, V), Spec.${n}()) == Some{[S.Variable{${ENC}}]} : ${MP}}:
  +hf = hF(t, i, hlW)
  %Equal.sym(${MP}, Codec.parts(${ITEMS}, ${CHAIN}), Some{${PL}},
      ${CAT}) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{${ENC}}]} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, Yb, ${POST})), Some{${ENCR}},
      VZ.enc_fpvb(${PRE}, Yb, ${POST}, hdom, FD.logic__subst(Nat, z => {N.fits(4n, Nat.add(z, List.length(&2, U32, Yb))) == True{} : Bool}, ${FSN}, VS.FSZ(${PRE}, ${POST}), Equal.sym(Nat, VS.FSZ(${PRE}, ${POST}), ${FSN}, hf), fit))) :
    {Codec.one(_, None{}) == Some{[S.Variable{${ENC}}]} : ${MP}}
  %Equal.sym(Nat, VS.FSZ(${PRE}, ${POST}), ${FSN}, hf) :
    {Some{[S.Variable{List.append(&2, U32, List.append(&2, U32, F.flat(${PRE}), List.append(&2, U32, N.digits(4n, _), F.flat(${POST}))), Yb)}]} == Some{[S.Variable{${ENC}}]} : ${MP}}
  %Equal.sym(+List<U32>, List.append(&2, U32, F.flat(${PRE}), List.append(&2, U32, F.limbs([${FS}]), F.flat(${POST}))), F.limbs(VZ.cat(List.append(&2, +List<U32>, ${PRE}, Con{[${FS}], ${POST}}))), VZ.hdr_flat(${PRE}, ${FS}, ${POST})) :
    {Some{[S.Variable{List.append(&2, U32, _, Yb)}]} == Some{[S.Variable{${ENC}}]} : ${MP}}
  {==}

def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: XVw(t, i, ${VY_})

@@ spec_part_seg_hlWw @@
def hlWw(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +len: U32, ${VBY.PF}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA})
    -> {FD.spec_common__length(U32, ${WPK}) == ${cf['wW']}n : Nat}:
  +hsl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${H}n, i), z) == True{} : Bool}, VB.pw(d), VB.len(${s}), Equal.sym(Nat, VB.len(${s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hHi(d, i, len, hw, ha))
  VBZ.len_WIN(${cf['wW']}n, Nat.add(${cf['k']}n, i), ${s},
    FD.nat__le_trans(Nat.add(${cf['wW']}n, Nat.add(${cf['k']}n, i)), Nat.add(${H}n, i), VB.len(${s}), Order.left_below_sum(${H - cf['wW'] - cf['k']}n, Nat.add(${cf['wW']}n, Nat.add(${cf['k']}n, i))), hsl))

# The header's bytes and the child's window's bytes are the window's bytes.
def bytesw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${VBY.PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32})
    -> {List.append(&2, U32, ${HDRB}, ${YT}) == ${WIN} : +List<U32>}:
  +hsl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${H}n, i), z) == True{} : Bool}, VB.pw(d), VB.len(${s}), Equal.sym(Nat, VB.len(${s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hHi(d, i, len, hw, ha))
  %${ENH}(len, ha) : {List.append(&2, U32, ${HDRB}, ${YT}) == VS.bt(_, F.limbs(VB.wdr(i, ${s}))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(${H}n), U32.to_nat(LL(len))), F.limbs(VB.wdr(i, ${s}))),
      List.append(&2, U32, F.limbs(VS.wtake(${H}n, VB.wdr(i, ${s}))), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(${H}n, VB.wdr(i, ${s}))))),
      VY.bt_split(${H}n, U32.to_nat(LL(len)), VB.wdr(i, ${s}), VZ.wdr_len_le(${H}n, i, ${s}, hsl))) :
    {List.append(&2, U32, ${HDRB}, ${YT}) == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(${H}n, VB.wdr(i, ${s})), VB.wdr(Nat.add(i, ${H}n), ${s}), VF.wdr_add(${H}n, i, ${s})) :
    {List.append(&2, U32, ${HDRB}, ${YT}) == List.append(&2, U32, F.limbs(VS.wtake(${H}n, VB.wdr(i, ${s}))), VS.bt(U32.to_nat(LL(len)), F.limbs(_))) : +List<U32>}
  %Equal.sym(Nat, Nat.add(i, ${H}n), Nat.add(${H}n, i), FD.nat__add_comm(i, ${H}n)) :
    {List.append(&2, U32, ${HDRB}, ${YT}) == List.append(&2, U32, F.limbs(VS.wtake(${H}n, VB.wdr(i, ${s}))), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(_, ${s})))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(${H}n, VB.wdr(i, ${s})), VZ.cat(${SEGSs}), winH(d, t, i, len, pf, hw, ha)) :
    {List.append(&2, U32, ${HDRB}, ${YT}) == List.append(&2, U32, F.limbs(_), ${YT}) : +List<U32>}
  %epo : {List.append(&2, U32, F.limbs(VZ.cat(${SEGSh})), ${YT}) == List.append(&2, U32, F.limbs(VZ.cat(${SEGSs})), ${YT}) : +List<U32>}
  {==}

def fitw(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +len: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA})
    -> {N.fits(4n, Nat.add(${FSN}, List.length(&2, U32, ${YT}))) == True{} : Bool}:
  VBZ.fit_b(d, ${FSN}, LL(len), len, ${YT}, VZ.bt_len_le(U32.to_nat(LL(len)), F.limbs(VB.wdr(Nat.add(${H}n, i), ${s}))), enFS(len, ha),
    FD.nat__le_trans(U32.to_nat(len), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(i), U32.to_nat(len)), hw),
    FD.nat__lt_trans(d, 29n, 30n, hd, {==}))

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${VBY.PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32},
    +hY: {YW.CHKw(t, Nat.add(${H}n, i), LL(len)) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WIN}}]} : ${MP}}:
  %bytesw(d, t, n, i, len, pf, hd, hw, ha, epo) :
    {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{_}]} : ${MP}}
  encpw(t, i, ${VY_}, ${YT}, YW.specw(d, t, n, Nat.add(${H}n, i), LL(len), pf, hd, hwY(d, i, len, hw, ha), hY),
    VZ.bd_btl(U32.to_nat(LL(len)), VB.wdr(Nat.add(${H}n, i), ${s})), fitw(d, t, i, len, hd, hw, ha), hlWw(d, t, i, len, pf, hw, ha))

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${VBY.PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHKw(t, i, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WIN}}]} : ${MP}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, i), ${FS})
  +c = YW.CHKw(t, Nat.add(${H}n, i), LL(len))
  +epo = FD.u32alg__eq_of(SPOw(t, i), ${FS}, chk_b(a, b, c, hchk))
  specw_go(d, t, n, i, len, pf, hd, hw, chk_a(a, b, c, hchk), epo, chk_c(a, b, c, hchk))
