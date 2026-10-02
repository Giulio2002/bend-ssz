@@ hyps @@
+e: {U32.to_nat(pos) == A.quad(P) : Nat}, +pfD: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +hdd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hR: ${HR},
    +hz0: {VB.slot(D, Nat.add(Nat.add(${HX}n, P), ${q})) == 0 : U32}, +hzq: {VB.slot(D, Nat.add(VY.QL(O.bits_nbytes(K)), Nat.add(${HX}n, P))) == 0 : U32},
    +dw: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +rep: BO.rep_bits(E.OB(T, K), S.BitList{${LIMN}}),
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},
    +hv: {O.bits_above_zero(U32.and(K, 31), VB.slot(T, VBT.QK(K))) == True{} : Bool}
@@ hyps_2 @@
${wsig(ws)}, +dw: Nat, +T: ${TR}, +K: U32,
    +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +rep: BO.rep_bits(E.OB(T, K), S.BitList{${LIMN}}),
    +hcap: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool},
    +hv: {O.bits_above_zero(U32.and(K, 31), VB.slot(T, VBT.QK(K))) == True{} : Bool}
@@ common_lemmas @@

# a <= HX: a + P <= 2^dd.
def hq(+a: Nat, +dd: Nat, +P: Nat, +K: U32, +ha: {Nat.is_le(a, ${HX}n) == ${TRUE}}, +hR: ${HR})
    -> {Nat.is_le(Nat.add(a, P), VB.pw(dd)) == ${TRUE}}:
  FD.nat__le_trans(Nat.add(a, P), Nat.add(${HX}n, P), VB.pw(dd), Order.add_right(a, ${HX}n, P, ha),
    FD.nat__le_trans(Nat.add(${HX}n, P), Nat.add(Nat.add(${HX}n, P), Nat.add(${q}, 1n)), VB.pw(dd), Order.below_sum(Nat.add(${HX}n, P), Nat.add(${q}, 1n)), hR))

def eoff(+pos: U32, +c: U32, +k: Nat, +dd: Nat, +P: Nat, +K: U32, +e: {U32.to_nat(pos) == A.quad(P) : Nat}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hk: {Nat.is_le(k, ${HX}n) == ${TRUE}}, +hdd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hR: ${HR})
    -> {U32.to_nat(U32.add(pos, c)) == A.quad(Nat.add(k, P)) : Nat}:
  VF.off_add(pos, c, P, k, 2n+dd, e, ec, hdd, VF.in_q(k, P, dd, hq(k, dd, P, K, hk, hR)))

# A slot of D past a word i it wrote is D's.
def sl_up(+dd: Nat, +D: ${TR}, +i: Nat, +v: U32, +k: Nat, +pfD: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hi: {Nat.is_lt(i, VB.pw(dd)) == ${TRUE}}, +hk: {Nat.is_lt(i, k) == ${TRUE}}, +hz: {VB.slot(D, k) == 0 : U32})
    -> {VB.slot(FD.array__upd(U32, dd, D, i, v), k) == 0 : U32}:
  %Equal.sym(${LT}, FD.array__slots(U32, FD.array__upd(U32, dd, D, i, v)), FD.spec_common__update(U32, FD.array__slots(U32, D), i, v),
      FD.array__upd_slots(U32, dd, D, i, v, hi, pfD)) :
    {FD.flat__nthc(_, k) == 0 : U32}
  Equal.trans(U32, FD.flat__nthc(FD.spec_common__update(U32, FD.array__slots(U32, D), i, v), k), FD.flat__nthc(FD.array__slots(U32, D), k), 0,
    FD.flat__nthc_other(FD.array__slots(U32, D), i, k, v, FD.nat__is_eq_lt(i, k, hk)), hz)

def bd_app(+xs: +List<U32>, +ys: +List<U32>, +hx: {SP.bytes_domain(xs) == ${TRUE}}, +hy: {SP.bytes_domain(ys) == ${TRUE}})
    -> {SP.bytes_domain(List.append(&2, U32, xs, ys)) == ${TRUE}}:
  match xs:
    case Nil{}: hy
    case Con{+x, +t}:
      V.and_true(U32.is_lt(x, 256), SP.bytes_domain(List.append(&2, U32, t, ys)), V.and_left(U32.is_lt(x, 256), SP.bytes_domain(t), hx),
        bd_app(t, ys, V.and_right(U32.is_lt(x, 256), SP.bytes_domain(t), hx), hy))

@@ leaf_text @@

# vbitcont.enc_at: the bit list's writer at P + 59.
def cra(${CW}, ${HW}) -> CT.CRA(dd, ${X(0)}, T, ${pF}, ${Hs}, K):
  (+wf, +r1) = rep
  +hN = ${HN}
  +hz = VR.rep_hz(dw, T, K, ${KB}n, ${LIMN}, pfT, {==}, hN, E.hNk0(), CO.qs_sized(dw, K, ${KB}n, ${LIMN}, {==}, hN, E.hNk0(), hcap), wf)
  +eF = eoff(pos, 236, ${HX}n, dd, P, K, e, {==}, {==}, hdd, hR)
  +hP = hP0(${CWa}, ${HWa})
  +z0 = sl_up(dd, D, Nat.add(0n, P), 236, Nat.add(${Hs}, ${q}), pfD, hP,
    FD.nat__lt_le_trans(Nat.add(0n, P), ${Hs}, Nat.add(${Hs}, ${q}), VB.lt_kk(0n, ${HX}n, P, {==}), Order.below_sum(${Hs}, ${q})), hz0)
  +zq = sl_up(dd, D, Nat.add(0n, P), 236, Nat.add(VY.QL(O.bits_nbytes(K)), ${Hs}), pfD, hP,
    FD.nat__lt_le_trans(Nat.add(0n, P), ${Hs}, Nat.add(VY.QL(O.bits_nbytes(K)), ${Hs}), VB.lt_kk(0n, ${HX}n, P, {==}), Order.left_below_sum(VY.QL(O.bits_nbytes(K)), ${Hs})), hzq)
  CT.enc_at(dd, dw, ${X(0)}, T, ${pF}, ${Hs}, K, ${KB}n, ${KY}n, ${LIMN}, pf0(${CWa}, ${HWa}), pfT, hdd, hdw, {==}, {==},
    eF, VF.al_3(${pF}, ${Hs}, eF), VF.al_q(${pF}, ${Hs}, eF), hN, E.hNk0(), {==}, hR, hcap, hz, z0, zq)

@@ leaf_text_2 @@
# The spec parts of the value: one variable part, the header's limbs and the bit list's bytes.
def partsE(${SRC})
    -> {Codec.parts(${I.val}, Spec.Attestation()) == ${RHSp} : ${MP}}:
${SH_}
  %Equal.sym(${MP}, Codec.parts(${items(0)}, ${chn(0)}), Some{[${', '.join(parts)}]},
      ${VL.seqwrap(cat(0))}) :
    {Codec.aggregate(_, None{}) == ${RHSp} : ${MP}}
${ST_}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, ${Y}, ${POST})), Some{${ENCR}}, VBC.enc_fpvb(${PRE}, ${Y}, ${POST}, VZ.bd_btl(U32.to_nat(CO.NK(K)), VB.wdr(59n, FD.array__slots(U32, E.OUTA(T, K)))), E.fitY(${SRCa}))) :
    {Codec.one(_, None{}) == ${RHSp} : ${MP}}
  {==}

# The value's spec bytes are bytes.
def domX(${SRC}) -> {SP.bytes_domain(List.append(&2, U32, F.limbs(${HDRL}), ${Y})) == ${TRUE}}:
  bd_app(F.limbs(${HDRL}), ${Y}, F.domain_limbs(${HDRL}), VZ.bd_btl(U32.to_nat(CO.NK(K)), VB.wdr(59n, FD.array__slots(U32, E.OUTA(T, K)))))
