@@ rec_text @@
def RT_${n}(${WSIG}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data: ${RT}
def BY_${n}(${WSIG}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data: ${BY}

# T.${n}_put at X = 4 q + r writes the value's words' limbs into the ${4 * W} zero bytes there.
def putx_${n}(${WSIG}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${Ln}))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${Ln}, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${Ln}) : +List<U32>})
    -> DK.P2(RT_${n}(${WA}, dd, D, X, q, r), BY_${n}(${WA}, dd, D, q, r)):
  +hX = VRX.xstart(q, r, ${Ln}, dd, D, pf, hl)
  +I0 = UW.inv_init(UA.BYT(D), ${X0}, ${Ln}, UW.ZB(${Ln}), hz, {==})
@@ obj_text @@

# ---- ${R}: its writer at any byte position, on the object ----

def PXo_${R}(o: T.${R}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
${body}
${pad}ERC.PX_${R}(${WA}, dd, D, q, r)

def pfo_${R}(+o: T.${R}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PXo_${R}(o, dd, D, q, r)) == ${TRUE}}:
${body}
${pad}ERC.pf_${R}(${WA}, dd, D, q, r, pf)

def RTo_${R}(+o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${R}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_${R}(o, dd, D, q, r)) : Array<U32>}
def BYo_${R}(+o: T.${R}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXo_${R}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, F.limbs(RWD_${R}(o))) : +List<U32>}

def putxo_${R}(+o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${RS}n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${RS}n, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${RS}n) : +List<U32>})
    -> DK.P2(RTo_${R}(o, dd, D, X, q, r), BYo_${R}(o, dd, D, q, r)):
${body}
${pad}ERC.putx_${R}(${WA}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)

def lenb_${R}(+o: T.${R}) -> {VRX.LN(F.limbs(RWD_${R}(o))) == ${RS}n : Nat}:
${body}
${pad}{==}

@@ loop_text @@

# ---- ${p}: the write loop at X = 4 q + r (record j at byte X + ${RS} j) ----

def EL_${p}(+A: ${TRR}, +j: Nat) -> T.${R}: VRL.mget(T.${R}, FD.spec_common__nth(T.${R}, FD.array__slots(T.${R}, A), j), T.${R}_default())

def AG_${p}(+A: ${TRR}, +i: U32) -> Array<T.${R}> & T.${R}: Array.get(T.${R}, ${TH}, i)

# the records j, j + 1, ..., j + k of A written from byte X + ${RS} j on
def WX_${p}(k: Nat, +j: Nat, +dd: Nat, D: ${TR}, +q: Nat, +r: Nat, +A: ${TRR}) -> ${TR}:
  match k:
    case 0n: PXo_${R}(EL_${p}(A, j), dd, D, ${QJ}, r)
    case 1n+p: WX_${p}(p, 1n+j, dd, PXo_${R}(EL_${p}(A, j), dd, D, ${QJ}, r), q, r, A)

law pfWX_${p}:
  for +k: Nat
  for +j: Nat
  for +dd: Nat
  for +D: ${TR}
  for +q: Nat
  for +r: Nat
  for +A: ${TRR}
  for +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}}
  {FD.array__perfect(U32, dd, WX_${p}(k, j, dd, D, q, r, A)) == ${TRUE}}
def pfWX_${p}(k, j, dd, D, q, r, A, pf):
  match k:
    case 0n: pfo_${R}(EL_${p}(A, j), dd, D, ${QJ}, r, pf)
    case 1n+ +p: pfWX_${p}(p, 1n+j, dd, PXo_${R}(EL_${p}(A, j), dd, D, ${QJ}, r), q, r, A, pfo_${R}(EL_${p}(A, j), dd, D, ${QJ}, r, pf))

def RTK_${p}(k: Nat, +i: U32, +j: Nat, +X: U32, +q: Nat, +r: Nat, +dd: Nat, +D: ${TR}, +A: ${TRR}) -> Data:
  {T.${p}_pt(k, i, X, FD.array__thaw(U32, D), (${TH}, EL_${p}(A, j))) == (FD.array__thaw(U32, WX_${p}(k, j, dd, D, q, r, A)), ${TH}) : ${RTP}}
def BYK_${p}(k: Nat, +j: Nat, +q: Nat, +r: Nat, +dd: Nat, +D: ${TR}, +A: ${TRR}) -> Data:
  {UA.BYT(WX_${p}(k, j, dd, D, q, r, A)) == UW.SPL(UA.BYT(D), VRX.YP(j, ${Wn}, q, r), F.flat(CHW_${p}(1n+k, A, j))) : +List<U32>}

# The loop from record j (index i) on, k + 1 records, into LT bytes at X whose last k + 1 records' bytes are zero.
def ptx_${p}(k: Nat, +i: U32, +j: Nat, +X: U32, +q: Nat, +r: Nat, +dd: Nat, +D: ${TR}, +da: Nat, +A: ${TRR}, +LT: Nat,
    +ei: {U32.to_nat(i) == j : Nat}, +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +pfD: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +hj: {Nat.is_le(A.quad(Nat.mul(Nat.add(1n+k, j), ${Wn})), LT) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == ${TRUE}},
    +hz: {VS.bt(A.quad(Nat.mul(1n+k, ${Wn})), VS.bdr(VRX.YP(j, ${Wn}, q, r), UA.BYT(D))) == UW.ZB(A.quad(Nat.mul(1n+k, ${Wn}))) : +List<U32>},
    +pfA: {FD.array__perfect(T.${R}, da, A) == ${TRUE}}, +hda: {Nat.is_lt(da, 31n) == ${TRUE}}, +hk: {Nat.is_lt(Nat.add(k, j), VB.pw(da)) == ${TRUE}})
    -> DK.P2(RTK_${p}(k, i, j, X, q, r, dd, D, A), BYK_${p}(k, j, q, r, dd, D, A)):
  match k:
    case 0n:
      +o = EL_${p}(A, j)
      +qj = ${QJ}
      +Xj = U32.add(X, U32.mul(i, ${RS}))
      +ej = VRX.rpos(X, i, j, 0n, q, r, ${Wn}, ${RS}, LT, dd, e, {==}, ei, hd, hj, hl)
      +hlj = VRX.rroom(j, 0n, q, r, ${Wn}, LT, dd, hj, hl)
      +g = putxo_${R}(o, dd, D, Xj, qj, r, ej, hr, hd, hlj, pfD, hz)
      +rt = PA(RTo_${R}(o, dd, D, Xj, qj, r), BYo_${R}(o, dd, D, qj, r), g)
      +by = PB(RTo_${R}(o, dd, D, Xj, qj, r), BYo_${R}(o, dd, D, qj, r), g)
      +D1 = PXo_${R}(o, dd, D, qj, r)
      +Y = F.limbs(RWD_${R}(o))
      +rt0 = Equal.cong(Array<U32>, ${RTP}, z => (z, ${TH}), T.${R}_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +by0 = FD.logic__subst(+List<U32>, z => {UA.BYT(D1) == UW.SPL(UA.BYT(D), VRX.YP(j, ${Wn}, q, r), z) : +List<U32>}, Y, List.append(&2, U32, Y, []),
        Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)), by)
      (rt0, by0)
    case 1n+ +p:
      +o = EL_${p}(A, j)
      +qj = ${QJ}
      +Xj = U32.add(X, U32.mul(i, ${RS}))
      +ej = VRX.rpos(X, i, j, 1n+p, q, r, ${Wn}, ${RS}, LT, dd, e, {==}, ei, hd, hj, hl)
      +hlj = VRX.rroom(j, 1n+p, q, r, ${Wn}, LT, dd, hj, hl)
      +bm = A.quad(Nat.mul(1n+p, ${Wn}))
      +B0 = UA.BYT(D)
      +Yj = VRX.YP(j, ${Wn}, q, r)
      +hz0 = VRX.zhead(${RS}n, bm, VS.bdr(Yj, B0), hz)
      +g = putxo_${R}(o, dd, D, Xj, qj, r, ej, hr, hd, hlj, pfD, hz0)
      +rt = PA(RTo_${R}(o, dd, D, Xj, qj, r), BYo_${R}(o, dd, D, qj, r), g)
      +by = PB(RTo_${R}(o, dd, D, Xj, qj, r), BYo_${R}(o, dd, D, qj, r), g)
      +D1 = PXo_${R}(o, dd, D, qj, r)
      +pf1 = pfo_${R}(o, dd, D, qj, r, pfD)
      +Y = F.limbs(RWD_${R}(o))
      +hX = VRX.xstart(qj, r, ${RS}n, dd, D, pfD, hlj)
      +ey = VRX.ynext(j, ${Wn}, q, r)
      +z1 = VRX.znext(B0, Yj, Y, VRX.YP(1n+j, ${Wn}, q, r), ${RS}n, bm, UA.BYT(D1), hX, lenb_${R}(o), ey, by, hz)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(p, j), VB.pw(da), Order.left_below_sum(p, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +hi1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(da)) == ${TRUE}}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1), h1)
      +hx = FD.logic__subst(Nat, z => {FD.spec_common__nth(T.${R}, FD.array__slots(T.${R}, A), z) == Some{EL_${p}(A, 1n+j)} : Maybe<&2, T.${R}>}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1),
        VRL.nth_get(T.${R}, FD.array__slots(T.${R}, A), 1n+j, T.${R}_default(), FD.array__len_lt(T.${R}, da, A, 1n+j, pfA, h1)))
      +eg = FD.array__get(T.${R}, da, A, U32.add(i, 1), EL_${p}(A, 1n+j), VB.lt32(da, hda), hi1, hx, pfA)
      +hj2 = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(Nat.mul(1n+z, ${Wn})), LT) == ${TRUE}}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hj)
      +hk2 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == ${TRUE}}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hk)
      +ih = ptx_${p}(p, U32.add(i, 1), 1n+j, X, q, r, dd, D1, da, A, LT, ei1, e, hr, hd, pf1, hj2, hl, z1, pfA, hda, hk2)
      +rt2 = PA(RTK_${p}(p, U32.add(i, 1), 1n+j, X, q, r, dd, D1, A), BYK_${p}(p, 1n+j, q, r, dd, D1, A), ih)
      +by2 = PB(RTK_${p}(p, U32.add(i, 1), 1n+j, X, q, r, dd, D1, A), BYK_${p}(p, 1n+j, q, r, dd, D1, A), ih)
      +ea = Equal.cong(Array<U32>, ${RTP}, z => T.${p}_pt(p, U32.add(i, 1), X, z, AG_${p}(A, U32.add(i, 1))), T.${R}_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +eb = Equal.cong(Array<T.${R}> & T.${R}, ${RTP}, z => T.${p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), z), AG_${p}(A, U32.add(i, 1)), (${TH}, EL_${p}(A, 1n+j)), eg)
      +rt3 = Equal.trans(${RTP}, T.${p}_pt(p, U32.add(i, 1), X, T.${R}_put(FD.array__thaw(U32, D), Xj, o), AG_${p}(A, U32.add(i, 1))), T.${p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG_${p}(A, U32.add(i, 1))),
        (FD.array__thaw(U32, WX_${p}(p, 1n+j, dd, D1, q, r, A)), ${TH}), ea,
        Equal.trans(${RTP}, T.${p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG_${p}(A, U32.add(i, 1))), T.${p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), (${TH}, EL_${p}(A, 1n+j))),
          (FD.array__thaw(U32, WX_${p}(p, 1n+j, dd, D1, q, r, A)), ${TH}), eb, rt2))
      +rest = F.flat(CHW_${p}(1n+p, A, 1n+j))
      +eXn = Equal.trans(Nat, VRX.YP(1n+j, ${Wn}, q, r), Nat.add(Yj, A.quad(${Wn})), Nat.add(Yj, VRX.LN(Y)), ey,
        Equal.cong(Nat, Nat, z => Nat.add(Yj, z), A.quad(${Wn}), VRX.LN(Y), Equal.sym(Nat, VRX.LN(Y), A.quad(${Wn}), lenb_${R}(o))))
      +by3 = Equal.trans(+List<U32>, UA.BYT(WX_${p}(p, 1n+j, dd, D1, q, r, A)), UW.SPL(UA.BYT(D1), VRX.YP(1n+j, ${Wn}, q, r), rest), UW.SPL(B0, Yj, VRX.AP(Y, rest)), by2,
        VRX.spl_catx(B0, Yj, Y, rest, VRX.YP(1n+j, ${Wn}, q, r), UA.BYT(D1), hX, eXn, by))
      (rt3, by3)

# ---- ${p}: the list's encoder window ----

def TDM_${p}(t: ${TRR}) -> Nat:
  match t:
    case FD.TLeaf{x}: 0n
    case FD.TNode{l, r}: 1n+TDM_${p}(l)

# The list object Seq{thaw(A), N} and its facts: a perfect tree of depth < 31 holding the N records,
# N within the limit ${LIM}.
def THL_${p}(+A: ${TRR}, +N: U32) -> T.${p}_Seq: T.${p}_Seq{${TH}, N}
def OKL_${p}(+A: ${TRR}, +N: U32) -> Bool:
  Bool.and(Nat.is_lt(TDM_${p}(A), 31n), Bool.and(FD.array__perfect(T.${R}, TDM_${p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM}))))
def okl_d_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {Nat.is_lt(TDM_${p}(A), 31n) == ${TRUE}}:
  and_l(Nat.is_lt(TDM_${p}(A), 31n), Bool.and(FD.array__perfect(T.${R}, TDM_${p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM}))), h)
def okl_1_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}})
    -> {Bool.and(FD.array__perfect(T.${R}, TDM_${p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM}))) == ${TRUE}}:
  and_r(Nat.is_lt(TDM_${p}(A), 31n), Bool.and(FD.array__perfect(T.${R}, TDM_${p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM}))), h)
def okl_pf_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {FD.array__perfect(T.${R}, TDM_${p}(A), A) == ${TRUE}}:
  and_l(FD.array__perfect(T.${R}, TDM_${p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM})), okl_1_${p}(A, N, h))
def okl_2_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM})) == ${TRUE}}:
  and_r(FD.array__perfect(T.${R}, TDM_${p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM})), okl_1_${p}(A, N, h))
def okl_n_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))) == ${TRUE}}:
  and_l(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM}), okl_2_${p}(A, N, h))
def okl_lim_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {U32.is_le(N, ${LIM}) == ${TRUE}}:
  and_r(Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), U32.is_le(N, ${LIM}), okl_2_${p}(A, N, h))

# N <= 2^d as the runtime compares it.
def le_cap_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {U32.is_le(N, FD.u32__pow2u(TDM_${p}(A))) == ${TRUE}}:
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(TDM_${p}(A))), Nat.is_le(U32.to_nat(N), U32.to_nat(FD.u32__pow2u(TDM_${p}(A)))), VU.le_u32(N, FD.u32__pow2u(TDM_${p}(A)))) : {_ == ${TRUE}}
  %Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(TDM_${p}(A))), VB.pw(TDM_${p}(A)), FD.u32__pow2u_value(TDM_${p}(A), FD.nat__lt_trans(TDM_${p}(A), 31n, 32n, okl_d_${p}(A, N, h), {==}))) : {Nat.is_le(U32.to_nat(N), _) == ${TRUE}}
  okl_n_${p}(A, N, h)

# The list's bytes, their count, and the writer's model.
def LL_${p}(+A: ${TRR}, +N: U32) -> Nat: A.quad(Nat.mul(U32.to_nat(N), ${Wn}))
def ENCL_${p}(+A: ${TRR}, +N: U32) -> +List<U32>: F.limbs(RWA_${p}(U32.to_nat(N), A, 0n))
def PUTLb_${p}(b: Bool, +A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
  match b:
    case True{}: D
    case False{}: WX_${p}(U32.to_nat(U32.sub(N, 1)), 0n, dd, D, q, r, A)
def PUTL_${p}(+A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}: PUTLb_${p}(U32.is_eq(N, 0), A, N, dd, D, q, r)
def pfLb_${p}(+b: Bool, +A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PUTLb_${p}(b, A, N, dd, D, q, r)) == ${TRUE}}:
  match b:
    case True{}: pf
    case False{}: pfWX_${p}(U32.to_nat(U32.sub(N, 1)), 0n, dd, D, q, r, A, pf)

def RTN_${p}(+b: Bool, +A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${p}_pt_nz(b, X, N, FD.array__thaw(U32, D), ${TH}) == (FD.array__thaw(U32, PUTLb_${p}(b, A, N, dd, D, q, r)), THL_${p}(A, N)) : Array<U32> & T.${p}_Seq}
def BYN_${p}(+b: Bool, +A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PUTLb_${p}(b, A, N, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, F.flat(CHW_${p}(U32.to_nat(N), A, 0n))) : +List<U32>}

# The writer's non-empty test, and its loop.
def ptnz_${p}(+A: ${TRR}, +N: U32, +b: Bool, +eb: {U32.is_eq(N, 0) == b : Bool}, +h: {OKL_${p}(A, N) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL_${p}(A, N)))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(LL_${p}(A, N), VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(LL_${p}(A, N)) : +List<U32>})
    -> DK.P2(RTN_${p}(b, A, N, dd, D, X, q, r), BYN_${p}(b, A, N, dd, D, q, r)):
  match b:
    case True{}:
      +eN = Equal.cong(U32, Nat, z => U32.to_nat(z), N, 0, FD.u32alg__eq_of(N, 0, eb))
      ({==}, FD.logic__subst(Nat, z => {UA.BYT(D) == UW.SPL(UA.BYT(D), ${X0}, F.flat(CHW_${p}(z, A, 0n))) : +List<U32>}, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, eN),
        Equal.sym(+List<U32>, UW.SPL(UA.BYT(D), ${X0}, []), UA.BYT(D), VRX.spl_nil(UA.BYT(D), ${X0}))))
    case False{}:
      +c = U32.to_nat(N)
      +da = TDM_${p}(A)
      +pfA = okl_pf_${p}(A, N, h)
      +hda = okl_d_${p}(A, N, h)
      +hca = okl_n_${p}(A, N, h)
      +h1 = VRL.cposu(N, c, {==}, eb)
      +k = U32.to_nat(U32.sub(N, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(N, 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +hj = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(Nat.mul(z, ${Wn})), LL_${p}(A, N)) == ${TRUE}}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), FD.nat__le_refl(LL_${p}(A, N)))
      +hz2 = FD.logic__subst(Nat, z => {VS.bt(A.quad(Nat.mul(z, ${Wn})), VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(A.quad(Nat.mul(z, ${Wn}))) : +List<U32>}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), hz)
      +hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == ${TRUE}}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {Nat.is_lt(k, z) == ${TRUE}}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      +eg0 = FD.array__get(T.${R}, da, A, 0, EL_${p}(A, 0n), VB.lt32(da, hda), h0, VRL.nth_get(T.${R}, FD.array__slots(T.${R}, A), 0n, T.${R}_default(), FD.array__len_lt(T.${R}, da, A, 0n, pfA, h0)), pfA)
      +g = ptx_${p}(k, 0, 0n, X, q, r, dd, D, da, A, LL_${p}(A, N), {==}, e, hr, hd, pf, hj, hl, hz2, pfA, hda, hk)
      +rt = PA(RTK_${p}(k, 0, 0n, X, q, r, dd, D, A), BYK_${p}(k, 0n, q, r, dd, D, A), g)
      +by = PB(RTK_${p}(k, 0, 0n, X, q, r, dd, D, A), BYK_${p}(k, 0n, q, r, dd, D, A), g)
      +ea = Equal.cong(Array<T.${R}> & T.${R}, Array<U32> & T.${p}_Seq, z => T.${p}_pt_fin(N, T.${p}_pt(k, 0, X, FD.array__thaw(U32, D), z)), Array.get(T.${R}, ${TH}, 0), (${TH}, EL_${p}(A, 0n)), eg0)
      +eb2 = Equal.cong(${RTP}, Array<U32> & T.${p}_Seq, z => T.${p}_pt_fin(N, z), T.${p}_pt(k, 0, X, FD.array__thaw(U32, D), (${TH}, EL_${p}(A, 0n))), (FD.array__thaw(U32, WX_${p}(k, 0n, dd, D, q, r, A)), ${TH}), rt)
      (Equal.trans(Array<U32> & T.${p}_Seq, T.${p}_pt_fin(N, T.${p}_pt(k, 0, X, FD.array__thaw(U32, D), Array.get(T.${R}, ${TH}, 0))), T.${p}_pt_fin(N, T.${p}_pt(k, 0, X, FD.array__thaw(U32, D), (${TH}, EL_${p}(A, 0n)))),
         T.${p}_pt_fin(N, (FD.array__thaw(U32, WX_${p}(k, 0n, dd, D, q, r, A)), ${TH})), ea, eb2),
       FD.logic__subst(Nat, z => {UA.BYT(WX_${p}(k, 0n, dd, D, q, r, A)) == UW.SPL(UA.BYT(D), ${X0}, F.flat(CHW_${p}(z, A, 0n))) : +List<U32>}, 1n+k, c, e1, by))

# The runtime's validity check of the list.
def valid_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {T.${p}_valid(THL_${p}(A, N)) == (THL_${p}(A, N), True{}) : T.${p}_Seq & Bool}:
  +d = TDM_${p}(A)
  %Equal.sym(Array<T.${R}> & U32, Array.size(T.${R}, ${TH}), (${TH}, FD.u32__pow2u(d)), FD.array__size_thaw(T.${R}, d, A, okl_pf_${p}(A, N, h))) :
    {T.${p}_va_cap(Bool.or(False{}, U32.is_le(N, ${LIM})), N, _) == (THL_${p}(A, N), True{}) : T.${p}_Seq & Bool}
  %Equal.sym(Bool, U32.is_le(N, ${LIM}), True{}, okl_lim_${p}(A, N, h)) :
    {(THL_${p}(A, N), Bool.and(Bool.or(False{}, _), U32.is_le(N, FD.u32__pow2u(d)))) == (THL_${p}(A, N), True{}) : T.${p}_Seq & Bool}
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(d)), True{}, le_cap_${p}(A, N, h)) :
    {(THL_${p}(A, N), Bool.and(Bool.or(False{}, True{}), _)) == (THL_${p}(A, N), True{}) : T.${p}_Seq & Bool}
  {==}

def RTL_${p}(+A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${p}_putk(FD.array__thaw(U32, D), X, THL_${p}(A, N)) == (FD.array__thaw(U32, PUTL_${p}(A, N, dd, D, q, r)), (THL_${p}(A, N), O.mulc(N, ${RS}))) : Array<U32> & (T.${p}_Seq & U32)}
def BYL_${p}(+A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PUTL_${p}(A, N, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, ENCL_${p}(A, N)) : +List<U32>}
def PFL_${p}(+A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {FD.array__perfect(U32, dd, PUTL_${p}(A, N, dd, D, q, r)) == ${TRUE}}

# The runtime's write, with its validity check.
def putk_rt_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +rtb: RTN_${p}(U32.is_eq(N, 0), A, N, dd, D, X, q, r)) -> RTL_${p}(A, N, dd, D, X, q, r):
  %Equal.sym(T.${p}_Seq & Bool, T.${p}_valid(THL_${p}(A, N)), (THL_${p}(A, N), True{}), valid_${p}(A, N, h)) :
    {T.${p}_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PUTL_${p}(A, N, dd, D, q, r)), (THL_${p}(A, N), O.mulc(N, ${RS}))) : Array<U32> & (T.${p}_Seq & U32)}
  %Equal.sym(Array<U32> & T.${p}_Seq, T.${p}_pt_nz(U32.is_eq(N, 0), X, N, FD.array__thaw(U32, D), ${TH}), (FD.array__thaw(U32, PUTL_${p}(A, N, dd, D, q, r)), THL_${p}(A, N)), rtb) :
    {T.${p}_ptn_fin(N, _) == (FD.array__thaw(U32, PUTL_${p}(A, N, dd, D, q, r)), (THL_${p}(A, N), O.mulc(N, ${RS}))) : Array<U32> & (T.${p}_Seq & U32)}
  {==}

# putx: the runtime writer at X = 4 q + r is the model PUTL, whose bytes splice the list's bytes
# into D's (its records write their data bytes only), and whose tree is perfect.
def putx_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL_${p}(A, N)))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(LL_${p}(A, N), VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(LL_${p}(A, N)) : +List<U32>})
    -> DK.P2(RTL_${p}(A, N, dd, D, X, q, r), DK.P2(BYL_${p}(A, N, dd, D, q, r), PFL_${p}(A, N, dd, D, q, r))):
  +b = U32.is_eq(N, 0)
  +g = ptnz_${p}(A, N, b, {==}, h, dd, D, X, q, r, e, hr, hd, hl, pf, hz)
  +rtb = PA(RTN_${p}(b, A, N, dd, D, X, q, r), BYN_${p}(b, A, N, dd, D, q, r), g)
  +byb = PB(RTN_${p}(b, A, N, dd, D, X, q, r), BYN_${p}(b, A, N, dd, D, q, r), g)
  +by = Equal.trans(+List<U32>, UA.BYT(PUTL_${p}(A, N, dd, D, q, r)), UW.SPL(UA.BYT(D), ${X0}, F.flat(CHW_${p}(U32.to_nat(N), A, 0n))), UW.SPL(UA.BYT(D), ${X0}, ENCL_${p}(A, N)), byb,
    Equal.cong(+List<U32>, +List<U32>, z => UW.SPL(UA.BYT(D), ${X0}, z), F.flat(CHW_${p}(U32.to_nat(N), A, 0n)), ENCL_${p}(A, N), flatW_${p}(U32.to_nat(N), A, 0n)))
  (putk_rt_${p}(A, N, h, dd, D, X, q, r, rtb), (by, pfLb_${p}(b, A, N, dd, D, q, r, pf)))

# ---- sizes ----

# The runtime's size pass.
def sizex_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {T.${p}_size(THL_${p}(A, N)) == (THL_${p}(A, N), O.mulc(N, ${RS})) : T.${p}_Seq & U32}:
  +d = TDM_${p}(A)
  %Equal.sym(Array<T.${R}> & U32, Array.size(T.${R}, ${TH}), (${TH}, FD.u32__pow2u(d)), FD.array__size_thaw(T.${R}, d, A, okl_pf_${p}(A, N, h))) :
    {T.${p}_szf(N, _) == (THL_${p}(A, N), O.mulc(N, ${RS})) : T.${p}_Seq & U32}
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(d)), True{}, le_cap_${p}(A, N, h)) :
    {(THL_${p}(A, N), O.pick(_, O.mulc(N, ${RS}), 4294967295)) == (THL_${p}(A, N), O.mulc(N, ${RS})) : T.${p}_Seq & U32}
  {==}

# szxB: the size pass's O.mulc is the list's byte count when the bytes are at most NMAX (no tree).
def szxB_${p}(+A: ${TRR}, +N: U32, +hN: {Nat.is_le(LL_${p}(A, N), U32.to_nat(VB.NMAX())) == ${TRUE}}) -> {U32.to_nat(O.mulc(N, ${RS})) == LL_${p}(A, N) : Nat}:
  VRX.mulqcW(N, U32.to_nat(N), ${RS}, ${Wn}, {==}, {==}, hN, {==}, {==}, {==})

# szx at any depth dd < 31 (hs31: the bytes within NMAX; hl32 is not used).
def szx_${p}W(+A: ${TRR}, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 31n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL_${p}(A, N)))), VB.pw(dd)) == ${TRUE}}, +hs31: {Nat.is_le(LL_${p}(A, N), U32.to_nat(VB.NMAX())) == ${TRUE}},
    +hl32: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, LL_${p}(A, N))), FD.spec_common__pow2(32n)) == ${TRUE}}) -> {U32.to_nat(O.mulc(N, ${RS})) == LL_${p}(A, N) : Nat}:
  szxB_${p}(A, N, hs31)

# szx: the size the writer returns is the list's byte count, when the list lies in the tree.
def szx_${p}(+A: ${TRR}, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL_${p}(A, N)))), VB.pw(dd)) == ${TRUE}}) -> {U32.to_nat(O.mulc(N, ${RS})) == LL_${p}(A, N) : Nat}:
  szxB_${p}(A, N, VRX.hs31w(q, r, LL_${p}(A, N), dd, hd, hl))


@@ spec_x_text @@

# ---- ${p}: the spec side ----

# The value of the list: the records' values.
def VALL_${p}(+A: ${TRR}, +N: U32) -> S.Value: S.Sequence{ITW_${p}(U32.to_nat(N), A, 0n)}

def len_encl_${p}(+A: ${TRR}, +N: U32) -> {List.length(&2, U32, ENCL_${p}(A, N)) == LL_${p}(A, N) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, F.limbs(${RWA})), F.wlen(${RWA}), VS.len_limbs(${RWA})) : {_ == LL_${p}(A, N) : Nat}
  %Equal.sym(Nat, F.wlen(${RWA}), A.quad(List.length(&2, U32, ${RWA})), VS.wlen_quad(${RWA})) : {_ == LL_${p}(A, N) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, ${RWA}), FD.spec_common__length(U32, ${RWA}), VMR.len_eq(${RWA})) : {A.quad(_) == LL_${p}(A, N) : Nat}
  %Equal.sym(Nat, VF.slen(${RWA}), Nat.mul(U32.to_nat(N), ${Wn}), lenW_${p}(U32.to_nat(N), A, 0n)) : {A.quad(_) == LL_${p}(A, N) : Nat}
  {==}

# encx_spec: the list's value has its bytes as one variable part, when they fit a tree of depth dx < 30.
def encx_spec_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}, +dx: Nat, +hdx: {Nat.is_lt(dx, 30n) == ${TRUE}},
    +hL: {Nat.is_le(LL_${p}(A, N), A.quad(VB.pw(dx))) == ${TRUE}})
    -> {Codec.parts(VALL_${p}(A, N), ${LSCH}) == Some{[S.Variable{ENCL_${p}(A, N)}]} : Maybe<&2, +List<S.Part>>}:
  +hlim = FD.logic__subst(Bool, z => {z == ${TRUE}}, U32.is_le(N, ${LIM}), Nat.is_le(U32.to_nat(N), U32.to_nat(${LIM})), VU.le_u32(N, ${LIM}), okl_lim_${p}(A, N, h))
  +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == ${TRUE}}, LL_${p}(A, N), List.length(&2, U32, ENCL_${p}(A, N)), Equal.sym(Nat, List.length(&2, U32, ENCL_${p}(A, N)), LL_${p}(A, N), len_encl_${p}(A, N)),
    VBZ.fitq(dx, LL_${p}(A, N), hL, hdx))
  lpart_${p}(U32.to_nat(N), A, hlim, fit)

@@ valid @@

def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {OKT(dw, T, N) == True{} : Bool})
    -> {T.${p}_valid(O.Words{FD.array__thaw(U32, T), N}) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}:
  %Equal.sym(Bool, U32.is_le(N, ${LIM}), True{}, ok_ex(dw, T, N, h)) :
    {O.wk_cap(Bool.and(Bool.and(U32.is_le(0, N), Bool.or(False{}, _)), O.unit_ok(1, N)), N, Array.size(U32, FD.array__thaw(U32, T))) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}
  wok(dw, T, N, 1, ok_pf(dw, T, N, h), ok_hd(dw, T, N, h), ok_hN(dw, T, N, h), ok_tz(dw, T, N, h), {==})

@@ bl_text @@

law maxx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {Nat.is_le(List.length(&2, U32, ENC(m)), ${LIM}n) == True{} : Bool}
def maxx(m, hok):
  match m:
    case MW{+dw, +T, +N}:
      FD.logic__subst(Nat, z => {Nat.is_le(z, ${LIM}n) == True{} : Bool}, U32.to_nat(N), List.length(&2, U32, ENC(MW{dw, T, N})),
        Equal.sym(Nat, List.length(&2, U32, ENC(MW{dw, T, N})), U32.to_nat(N), eL(dw, T, N, hok)),
        FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(N, ${LIM}), Nat.is_le(U32.to_nat(N), U32.to_nat(${LIM})), VU.le_u32(N, ${LIM}), ok_ex(dw, T, N, hok)))

@@ _wvalid @@

def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {OKT(dw, T, N) == True{} : Bool})
    -> {T.${p}_valid(O.Words{FD.array__thaw(U32, T), N}) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}:
  %Equal.sym(Bool, U32.is_le(N, 4294967264), True{}, VB.u_le_nmax_dw(N, dw, ok_hd(dw, T, N, h), ok_hN(dw, T, N, h))) :
    {O.wk_cap(Bool.and(Bool.and(U32.is_le(0, N), Bool.or(False{}, _)), O.unit_ok(${unit}, N)), N, Array.size(U32, FD.array__thaw(U32, T))) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}
  wok(dw, T, N, ${unit}, ok_pf(dw, T, N, h), ok_hd(dw, T, N, h), ok_hN(dw, T, N, h), ok_tz(dw, T, N, h), ${hu})

@@ _flist_kinds @@

def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {OKT(dw, T, N) == True{} : Bool})
    -> {T.${p32}_valid(O.Words{FD.array__thaw(U32, T), N}) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}:
  +ex = ok_ex(dw, T, N, h)
  +hdw = ok_hd(dw, T, N, h)
  +hN = ok_hN(dw, T, N, h)
  VBE.words_ok_b(dw, T, N, 0, 536870912, VLS.KK(dw), ok_pf(dw, T, N, h), FD.nat__lt_trans(dw, 28n, 31n, hdw, {==}), VLS.kk_lt(dw, hdw), VLS.hyn(dw, N, hN),
    FD.nat__zero_le(U32.to_nat(N)), FD.logic__and_left(${b32c1}, Bool.and(${b32c2}, W.CHKw(T, 0n, 0, N)), ex), hsrc(dw, N, hdw, hN), ok_tz(dw, T, N, h), 32,
    FD.logic__and_left(${b32c2}, W.CHKw(T, 0n, 0, N), FD.logic__and_right(${b32c1}, Bool.and(${b32c2}, W.CHKw(T, 0n, 0, N)), ex)))

@@ _flist_kinds_valid @@

def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {OKT(dw, T, N) == True{} : Bool})
    -> {T.l4096_b48_valid(O.Words{FD.array__thaw(U32, T), N}) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}:
  +ex = ok_ex(dw, T, N, h)
  %Equal.sym(Bool, U32.is_le(N, 196608), True{}, FD.logic__and_left(U32.is_le(N, 196608), Bool.and(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N)), ex)) :
    {O.wk_cap(Bool.and(Bool.and(U32.is_le(0, N), Bool.or(False{}, _)), O.unit_ok(48, N)), N, Array.size(U32, FD.array__thaw(U32, T))) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}
  wok(dw, T, N, 48, ok_pf(dw, T, N, h), ok_hd(dw, T, N, h), ok_hN(dw, T, N, h), ok_tz(dw, T, N, h),
    FD.logic__and_left(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N), FD.logic__and_right(U32.is_le(N, 196608), Bool.and(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N)), ex)))

@@ _flist_kinds_2 @@

def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {OKT(dw, T, N) == True{} : Bool})
    -> {T.l131072_u64_valid(O.Words{FD.array__thaw(U32, T), N}) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}:
  +ex = ok_ex(dw, T, N, h)
  %Equal.sym(Bool, U32.is_le(N, 1048576), True{}, FD.logic__and_left(U32.is_le(N, 1048576), Bool.and(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N)), ex)) :
    {O.wk_cap(Bool.and(Bool.and(U32.is_le(0, N), Bool.or(False{}, _)), O.unit_ok(8, N)), N, Array.size(U32, FD.array__thaw(U32, T))) == (O.Words{FD.array__thaw(U32, T), N}, True{}) : O.Words & Bool}
  wok(dw, T, N, 8, ok_pf(dw, T, N, h), ok_hd(dw, T, N, h), ok_hN(dw, T, N, h), ok_tz(dw, T, N, h),
    FD.logic__and_left(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N), FD.logic__and_right(U32.is_le(N, 1048576), Bool.and(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N)), ex)))

@@ UREC_PRE @@

# ---- the one-byte bool: True writes 1 (vuwl_u8's w8 at any X), False leaves the (zero) byte ----
def BB(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0
def PBo(b: Bool, +r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat) -> FD.array__Tree<U32>:
  match b:
    case True{}: W8.W8X(r, dd, D, q, 1)
    case False{}: D
def boolx_perfect(+b: Bool, +r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PBo(b, r, dd, D, q)) == True{} : Bool}:
  match b:
    case True{}: W8.w8x_perfect(r, dd, D, q, 1, pf)
    case False{}: pf
def bool_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +b: Bool, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {T.bool_put(FD.array__thaw(U32, D), X, b) == FD.array__thaw(U32, PBo(b, r, dd, D, q)) : Array<U32>}:
  match b:
    case True{}: W8.w8_any(dd, D, X, q, r, 1, e, hr, hd, hl, pf)
    case False{}: {==}
def bool_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +b: Bool, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(1n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(1n) : +List<U32>})
    -> {UA.BYT(PBo(b, r, dd, D, q)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), [BB(b)]) : +List<U32>}:
  match b:
    case True{}: W8.w8_any_bytes(dd, D, X, q, r, 1, e, hr, hd, hl, pf, hz)
    case False{}: UW.inv_init(UA.BYT(D), Nat.add(A.quad(q), r), 1n, [0], hz, {==})

@@ urec_text @@
def RTR_${n}(${WSIG}, +dd: Nat, +D: ${TR}, +X: U32) -> Data: ${RT}
def BYR_${n}(${WSIG}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data: ${BY}
def lenb_${n}(${WSIG}) -> {List.length(&2, U32, BY_${n}(${WA})) == ${Ln} : Nat}: {==}

@@ urec_text_putx_ @@
# T.${n}_put at X = 4 q + r writes the value's ${L} bytes (BY_${n}) into the zero bytes there.
def putx_${n}(${WSIG}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${Ln}))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${Ln}, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${Ln}) : +List<U32>})
    -> DK.P2(RTR_${n}(${WA}, dd, D, X), BYR_${n}(${WA}, dd, D, X, q, r)):
  +hX = VRX.xstart(q, r, ${Ln}, dd, D, pf, hl)
  +I0 = UW.inv_init(UA.BYT(D), ${X0}, ${Ln}, UW.ZB(${Ln}), hz, {==})
@@ _vlist_shared_lemmas @@

def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:
  (+a, +b) = p
  a
def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:
  (+a, +b) = p
  b
def and_l(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == ${TRUE}}) -> {a == ${TRUE}}:
  match a:
    case True{}: {==}
    case False{}: h
def and_r(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == ${TRUE}}) -> {b == ${TRUE}}:
  match a:
    case True{}: h
    case False{}: Empty.absurd({b == ${TRUE}}, FD.logic__false_true(h))


@@ _vlist_record_laws @@
# ---- ${R}: the object's bytes, value and parts; its writer at any X ----

def RWB(o: T.${R}) -> +List<U32>:
${NEST}
${PAD}${BYV}
def RVV(o: T.${R}) -> S.Value:
${NEST}
${PAD}${VAL}

def rbeq(${WSG}) -> {${BYV} == ${SPB} : +List<U32>}:
  match ${bv}:
${rbeq_cases}

def rparts(+o: T.${R}) -> {Codec.parts(RVV(o), Spec.Schema58()) == Some{[S.Fixed{RWB(o)}]} : Maybe<&2, +List<S.Part>>}:
${NEST}
${PAD}%Equal.sym(+List<U32>, ${BYV}, ${SPB}, rbeq(${WA})) : {Codec.parts(${VAL}, Spec.Schema58()) == Some{[S.Fixed{_}]} : Maybe<&2, +List<S.Part>>}
${PAD}SRV.${R}_spec_parts(${', '.join(xs)}, ${bv}, ${', '.join(es)})

def domBB(+b: Bool) -> {SP.bytes_domain([EV.BB(b)]) == ${TRUE}}:
  match b:
    case True{}: {==}
    case False{}: {==}
def rdom(+o: T.${R}) -> {SP.bytes_domain(RWB(o)) == ${TRUE}}:
${NEST}
${PAD}${DOM}

def lenb(+o: T.${R}) -> {List.length(&2, U32, RWB(o)) == ${S} : Nat}:
${NEST}
${PAD}EV.lenb_${R}(${WA})

def PXo(o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32) -> ${TR}:
${NEST}
${PAD}EV.PX_${R}(${WA}, dd, D, X)
def pfo(+o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}}) -> {FD.array__perfect(U32, dd, PXo(o, dd, D, X)) == ${TRUE}}:
${NEST}
${PAD}EV.pf_${R}(${WA}, dd, D, X, pf)
def RTo(+o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32) -> Data:
  {T.${R}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo(o, dd, D, X)) : Array<U32>}
def BYo(+o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXo(o, dd, D, X)) == UW.SPL(UA.BYT(D), ${X0}, RWB(o)) : +List<U32>}
def putxo(+o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${S}))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${S}, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${S}) : +List<U32>})
    -> DK.P2(RTo(o, dd, D, X), BYo(o, dd, D, X, q, r)):
${NEST}
${PAD}EV.putx_${R}(${WA}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)


@@ _vlist_positions @@
# ---- positions at byte stride S ----

def bmul(+dd: Nat, +i: U32, +j: Nat, +Su: U32, +S: Nat, +eS: {U32.to_nat(Su) == S : Nat}, +ei: {U32.to_nat(i) == j : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hm: {Nat.is_le(Nat.mul(j, S), VB.pw(2n+dd)) == ${TRUE}})
    -> {U32.to_nat(U32.mul(i, Su)) == Nat.mul(j, S) : Nat}:
  +P2 = VB.pw(2n+dd)
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, U32.to_nat(Su)), Nat.mul(j, S),
    Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Su)), U32.to_nat(i), j, ei), Equal.cong(Nat, Nat, z => Nat.mul(j, z), U32.to_nat(Su), S, eS))
  Equal.trans(Nat, U32.to_nat(U32.mul(i, Su)), Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, S),
    VU.mul_le(i, Su, FD.u32__pow2u(2n+dd), FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(U32.to_nat(i), U32.to_nat(Su)), z) == ${TRUE}}, P2, U32.to_nat(FD.u32__pow2u(2n+dd)),
      Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(2n+dd)), P2, FD.u32__pow2u_value(2n+dd, FD.nat__lt_trans(2n+dd, 31n, 32n, hdd, {==}))),
      FD.logic__subst(Nat, z => {Nat.is_le(z, P2) == ${TRUE}}, Nat.mul(j, S), Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Equal.sym(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, S), em), hm))),
    em)

def YB(+j: Nat, +q: Nat, +r: Nat) -> Nat: Nat.add(${X0}, Nat.mul(j, ${S}))

# record j of a run of LT bytes at X (records j .. j + k inside it): its position, and its room
def spos(+X: U32, +i: U32, +j: Nat, +k: Nat, +q: Nat, +r: Nat, +LT: Nat, +dd: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +ei: {U32.to_nat(i) == j : Nat},
    +hd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +hj: {Nat.is_le(Nat.mul(Nat.add(1n+k, j), ${S}), LT) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == ${TRUE}})
    -> {U32.to_nat(${XJ}) == YB(j, q, r) : Nat}:
  +h1 = FD.nat__le_trans(Nat.mul(j, ${S}), Nat.mul(Nat.add(1n+k, j), ${S}), LT,
    VRL.mul_mono(j, Nat.add(1n+k, j), ${S}, FD.nat__le_trans(j, Nat.add(k, j), 1n+Nat.add(k, j), Order.left_below_sum(k, j), Order.left_below_sum(1n, Nat.add(k, j)))), hj)
  +hm = FD.nat__le_trans(Nat.mul(j, ${S}), LT, VB.pw(2n+dd), h1,
    FD.nat__le_trans(LT, Nat.add(${X0}, LT), VB.pw(2n+dd), Order.left_below_sum(${X0}, LT), VRX.xend(q, r, LT, dd, hl)))
  VCN.vpos(X, U32.mul(i, ${RS}), Nat.mul(j, ${S}), q, r, LT, dd, e, bmul(dd, i, j, ${RS}, ${S}, {==}, ei, hd, hm), hd, h1, hl)

def sroom(+Xj: U32, +j: Nat, +k: Nat, +q: Nat, +r: Nat, +LT: Nat, +dd: Nat, +ep: {U32.to_nat(Xj) == YB(j, q, r) : Nat},
    +hj: {Nat.is_le(Nat.mul(Nat.add(1n+k, j), ${S}), LT) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == ${TRUE}})
    -> {Nat.is_le(Nat.add(VCN.QX(Xj), WD.NWN(Nat.add(VCN.RX(Xj), ${S}))), VB.pw(dd)) == ${TRUE}}:
  +h1 = FD.nat__le_trans(Nat.mul(1n+j, ${S}), Nat.mul(Nat.add(1n+k, j), ${S}), LT, VRL.mul_mono(1n+j, Nat.add(1n+k, j), ${S}, Order.left_below_sum(k, j)), hj)
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(z, LT) == ${TRUE}}, Nat.add(${S}, Nat.mul(j, ${S})), Nat.add(Nat.mul(j, ${S}), ${S}), FD.nat__add_comm(${S}, Nat.mul(j, ${S})), h1)
  VCN.croom(Xj, q, r, Nat.mul(j, ${S}), ${S}, LT, dd, ep, h2, hl)

def ynext(+j: Nat, +q: Nat, +r: Nat) -> {YB(1n+j, q, r) == Nat.add(YB(j, q, r), ${S}) : Nat}:
  Equal.trans(Nat, Nat.add(${X0}, Nat.add(${S}, Nat.mul(j, ${S}))), Nat.add(${X0}, Nat.add(Nat.mul(j, ${S}), ${S})), Nat.add(Nat.add(${X0}, Nat.mul(j, ${S})), ${S}),
    Equal.cong(Nat, Nat, z => Nat.add(${X0}, z), Nat.add(${S}, Nat.mul(j, ${S})), Nat.add(Nat.mul(j, ${S}), ${S}), FD.nat__add_comm(${S}, Nat.mul(j, ${S}))),
    Equal.sym(Nat, Nat.add(Nat.add(${X0}, Nat.mul(j, ${S})), ${S}), Nat.add(${X0}, Nat.add(Nat.mul(j, ${S}), ${S})), FD.nat__add_assoc(${X0}, Nat.mul(j, ${S}), ${S})))


@@ _vlist_record_values @@
# ---- ${p}: the object's records, their bytes and values ----

def EL_${p}(+A: ${TRR}, +j: Nat) -> T.${R}: VRL.mget(T.${R}, FD.spec_common__nth(T.${R}, FD.array__slots(T.${R}, A), j), T.${R}_default())
def AG_${p}(+A: ${TRR}, +i: U32) -> Array<T.${R}> & T.${R}: Array.get(T.${R}, ${TH}, i)

def ITV_${p}(c: Nat, +A: ${TRR}, +j: Nat) -> S.Value:
  match c:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{RVV(EL_${p}(A, j)), ITV_${p}(q, A, 1n+j)}

def FPV_${p}(c: Nat, +A: ${TRR}, +j: Nat) -> +List<S.Part>:
  match c:
    case 0n: []
    case 1n+q: S.Fixed{RWB(EL_${p}(A, j))} <> FPV_${p}(q, A, 1n+j)

def CHV_${p}(c: Nat, +A: ${TRR}, +j: Nat) -> +List<U32>:
  match c:
    case 0n: []
    case 1n+q: List.append(&2, U32, RWB(EL_${p}(A, j)), CHV_${p}(q, A, 1n+j))

law cntV_${p}:
  for +c: Nat
  for +A: ${TRR}
  for +j: Nat
  {Codec.count(ITV_${p}(c, A, j)) == c : Nat}
def cntV_${p}(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +q: FD.nat__succ_cong(Codec.count(ITV_${p}(q, A, 1n+j)), q, cntV_${p}(q, A, 1n+j))

law prtV_${p}:
  for +c: Nat
  for +A: ${TRR}
  for +j: Nat
  {Codec.parts(ITV_${p}(c, A, j), S.Repeat{Spec.Schema58()}) == Some{FPV_${p}(c, A, j)} : Maybe<&2, +List<S.Part>>}
def prtV_${p}(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +q:
      F.cat_fixed(Codec.parts(RVV(EL_${p}(A, j)), Spec.Schema58()), RWB(EL_${p}(A, j)), Codec.parts(ITV_${p}(q, A, 1n+j), S.Repeat{Spec.Schema58()}),
        FPV_${p}(q, A, 1n+j), rparts(EL_${p}(A, j)), prtV_${p}(q, A, 1n+j))

law fsV_${p}:
  for +c: Nat
  for +A: ${TRR}
  for +j: Nat
  {Layout.fixed_size(FPV_${p}(c, A, j)) == Nat.mul(c, ${S}) : Nat}
def fsV_${p}(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, List.length(&2, U32, RWB(EL_${p}(A, j))), ${S}, lenb(EL_${p}(A, j))) :
        {Nat.add(_, Layout.fixed_size(FPV_${p}(q, A, 1n+j))) == Nat.mul(1n+q, ${S}) : Nat}
      Equal.cong(Nat, Nat, z => Nat.add(${S}, z), Layout.fixed_size(FPV_${p}(q, A, 1n+j)), Nat.mul(q, ${S}), fsV_${p}(q, A, 1n+j))

law fpV_${p}:
  for +c: Nat
  for +A: ${TRR}
  for +j: Nat
  for +o: Nat
  {Layout.fixed_parts(FPV_${p}(c, A, j), o) == CHV_${p}(c, A, j) : +List<U32>}
def fpV_${p}(c, A, j, o):
  match c:
    case 0n: {==}
    case 1n+ +q: Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, RWB(EL_${p}(A, j)), z), Layout.fixed_parts(FPV_${p}(q, A, 1n+j), o), CHV_${p}(q, A, 1n+j), fpV_${p}(q, A, 1n+j, o))

law payV_${p}:
  for +c: Nat
  for +A: ${TRR}
  for +j: Nat
  {Layout.payloads(FPV_${p}(c, A, j)) == [] : +List<U32>}
def payV_${p}(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +q: payV_${p}(q, A, 1n+j)

law validV_${p}:
  for +c: Nat
  for +A: ${TRR}
  for +j: Nat
  {Layout.bytes_valid(FPV_${p}(c, A, j)) == ${TRUE}}
def validV_${p}(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +q: FD.logic__and_intro(SP.bytes_domain(RWB(EL_${p}(A, j))), Layout.bytes_valid(FPV_${p}(q, A, 1n+j)), rdom(EL_${p}(A, j)), validV_${p}(q, A, 1n+j))

law lenV_${p}:
  for +c: Nat
  for +A: ${TRR}
  for +j: Nat
  {List.length(&2, U32, (CHV_${p}(c, A, j))) == Nat.mul(c, ${S}) : Nat}
def lenV_${p}(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +q:
      +Y = RWB(EL_${p}(A, j))
      +Rs = CHV_${p}(q, A, 1n+j)
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, Y, Rs)), Nat.add(List.length(&2, U32, Y), List.length(&2, U32, Rs)), Nat.add(${S}, Nat.mul(q, ${S})),
        VS.len_app(Y, Rs),
        Equal.trans(Nat, Nat.add(List.length(&2, U32, Y), List.length(&2, U32, Rs)), Nat.add(${S}, List.length(&2, U32, Rs)), Nat.add(${S}, Nat.mul(q, ${S})),
          Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, Rs)), List.length(&2, U32, Y), ${S}, lenb(EL_${p}(A, j))),
          Equal.cong(Nat, Nat, z => Nat.add(${S}, z), List.length(&2, U32, Rs), Nat.mul(q, ${S}), lenV_${p}(q, A, 1n+j))))


@@ _vlist_write_loop @@
# ---- ${p}: the write loop at X = 4 q + r (record j at byte X + ${RS} j) ----

# the records j, j + 1, ..., j + k of A (index i = j) written from X + ${RS} j on
def WX_${p}(k: Nat, +i: U32, +j: Nat, +dd: Nat, D: ${TR}, +X: U32, +A: ${TRR}) -> ${TR}:
  match k:
    case 0n: PXo(EL_${p}(A, j), dd, D, ${XJ})
    case 1n+p: WX_${p}(p, U32.add(i, 1), 1n+j, dd, PXo(EL_${p}(A, j), dd, D, ${XJ}), X, A)

law pfWX_${p}:
  for +k: Nat
  for +i: U32
  for +j: Nat
  for +dd: Nat
  for +D: ${TR}
  for +X: U32
  for +A: ${TRR}
  for +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}}
  {FD.array__perfect(U32, dd, WX_${p}(k, i, j, dd, D, X, A)) == ${TRUE}}
def pfWX_${p}(k, i, j, dd, D, X, A, pf):
  match k:
    case 0n: pfo(EL_${p}(A, j), dd, D, ${XJ}, pf)
    case 1n+ +p: pfWX_${p}(p, U32.add(i, 1), 1n+j, dd, PXo(EL_${p}(A, j), dd, D, ${XJ}), X, A, pfo(EL_${p}(A, j), dd, D, ${XJ}, pf))

def RTK_${p}(k: Nat, +i: U32, +j: Nat, +X: U32, +dd: Nat, +D: ${TR}, +A: ${TRR}) -> Data:
  {T.${p}_pt(k, i, X, FD.array__thaw(U32, D), (${TH}, EL_${p}(A, j))) == (FD.array__thaw(U32, WX_${p}(k, i, j, dd, D, X, A)), ${TH}) : ${RTP}}
def BYK_${p}(k: Nat, +i: U32, +j: Nat, +q: Nat, +r: Nat, +dd: Nat, +D: ${TR}, +X: U32, +A: ${TRR}) -> Data:
  {UA.BYT(WX_${p}(k, i, j, dd, D, X, A)) == UW.SPL(UA.BYT(D), YB(j, q, r), (CHV_${p}(1n+k, A, j))) : +List<U32>}

# record j's write: its runtime fact, its bytes at YB(j), its perfect tree, its start in the bytes
def one(+o: T.${R}, +i: U32, +j: Nat, +k: Nat, +X: U32, +q: Nat, +r: Nat, +dd: Nat, +D: ${TR}, +LT: Nat,
    +ei: {U32.to_nat(i) == j : Nat}, +e: {U32.to_nat(X) == ${X0} : Nat}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +pfD: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +hj: {Nat.is_le(Nat.mul(Nat.add(1n+k, j), ${S}), LT) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == ${TRUE}},
    +hz: {VS.bt(${S}, VS.bdr(YB(j, q, r), UA.BYT(D))) == UW.ZB(${S}) : +List<U32>})
    -> DK.P2(RTo(o, dd, D, ${XJ}), DK.P2({UA.BYT(PXo(o, dd, D, ${XJ})) == UW.SPL(UA.BYT(D), YB(j, q, r), RWB(o)) : +List<U32>},
         {Nat.is_le(YB(j, q, r), List.length(&2, U32, UA.BYT(D))) == ${TRUE}})):
  +Xj = ${XJ}
  +ep = spos(X, i, j, k, q, r, LT, dd, e, ei, hd, hj, hl)
  +hlj = sroom(Xj, j, k, q, r, LT, dd, ep, hj, hl)
  +pj = Nat.add(A.quad(VCN.QX(Xj)), VCN.RX(Xj))
  +epj = Equal.trans(Nat, YB(j, q, r), U32.to_nat(Xj), pj, Equal.sym(Nat, U32.to_nat(Xj), YB(j, q, r), ep), VC.split4(Xj))
  +hzj = FD.logic__subst(Nat, z => {VS.bt(${S}, VS.bdr(z, UA.BYT(D))) == UW.ZB(${S}) : +List<U32>}, YB(j, q, r), pj, epj, hz)
  +g = putxo(o, dd, D, Xj, VCN.QX(Xj), VCN.RX(Xj), VC.split4(Xj), VCN.rx_lt(Xj), hd, hlj, pfD, hzj)
  +rt = PA(RTo(o, dd, D, Xj), BYo(o, dd, D, Xj, VCN.QX(Xj), VCN.RX(Xj)), g)
  +by = PB(RTo(o, dd, D, Xj), BYo(o, dd, D, Xj, VCN.QX(Xj), VCN.RX(Xj)), g)
  +by2 = FD.logic__subst(Nat, z => {UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(UA.BYT(D), z, RWB(o)) : +List<U32>}, pj, YB(j, q, r), Equal.sym(Nat, YB(j, q, r), pj, epj), by)
  +hX = FD.logic__subst(Nat, z => {Nat.is_le(z, List.length(&2, U32, UA.BYT(D))) == ${TRUE}}, pj, YB(j, q, r), Equal.sym(Nat, YB(j, q, r), pj, epj),
    VRX.xstart(VCN.QX(Xj), VCN.RX(Xj), ${S}, dd, D, pfD, hlj))
  (rt, (by2, hX))

# The loop from record j (index i) on, k + 1 records, into LT bytes at X whose last k + 1 records' bytes are zero.
def ptx_${p}(k: Nat, +i: U32, +j: Nat, +X: U32, +q: Nat, +r: Nat, +dd: Nat, +D: ${TR}, +da: Nat, +A: ${TRR}, +LT: Nat,
    +ei: {U32.to_nat(i) == j : Nat}, +e: {U32.to_nat(X) == ${X0} : Nat}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +pfD: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +hj: {Nat.is_le(Nat.mul(Nat.add(1n+k, j), ${S}), LT) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == ${TRUE}},
    +hz: {VS.bt(Nat.mul(1n+k, ${S}), VS.bdr(YB(j, q, r), UA.BYT(D))) == UW.ZB(Nat.mul(1n+k, ${S})) : +List<U32>},
    +pfA: {FD.array__perfect(T.${R}, da, A) == ${TRUE}}, +hda: {Nat.is_lt(da, 31n) == ${TRUE}}, +hk: {Nat.is_lt(Nat.add(k, j), VB.pw(da)) == ${TRUE}})
    -> DK.P2(RTK_${p}(k, i, j, X, dd, D, A), BYK_${p}(k, i, j, q, r, dd, D, X, A)):
  match k:
    case 0n:
      +o = EL_${p}(A, j)
      +Xj = ${XJ}
      +g = one(o, i, j, 0n, X, q, r, dd, D, LT, ei, e, hd, pfD, hj, hl, hz)
      +rt = PA(RTo(o, dd, D, Xj), DK.P2({UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(UA.BYT(D), YB(j, q, r), RWB(o)) : +List<U32>}, {Nat.is_le(YB(j, q, r), List.length(&2, U32, UA.BYT(D))) == ${TRUE}}), g)
      +gb = PB(RTo(o, dd, D, Xj), DK.P2({UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(UA.BYT(D), YB(j, q, r), RWB(o)) : +List<U32>}, {Nat.is_le(YB(j, q, r), List.length(&2, U32, UA.BYT(D))) == ${TRUE}}), g)
      +by = PA({UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(UA.BYT(D), YB(j, q, r), RWB(o)) : +List<U32>}, {Nat.is_le(YB(j, q, r), List.length(&2, U32, UA.BYT(D))) == ${TRUE}}, gb)
      +D1 = PXo(o, dd, D, Xj)
      +Y = RWB(o)
      +rt0 = Equal.cong(Array<U32>, ${RTP}, z => (z, ${TH}), T.${R}_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +by0 = FD.logic__subst(+List<U32>, z => {UA.BYT(D1) == UW.SPL(UA.BYT(D), YB(j, q, r), z) : +List<U32>}, Y, List.append(&2, U32, Y, []),
        Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)), by)
      (rt0, by0)
    case 1n+ +p:
      +o = EL_${p}(A, j)
      +Xj = ${XJ}
      +bm = Nat.mul(1n+p, ${S})
      +B0 = UA.BYT(D)
      +Yj = YB(j, q, r)
      +hz0 = VRX.zhead(${S}, bm, VS.bdr(Yj, B0), hz)
      +g = one(o, i, j, 1n+p, X, q, r, dd, D, LT, ei, e, hd, pfD, hj, hl, hz0)
      +rt = PA(RTo(o, dd, D, Xj), DK.P2({UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(B0, Yj, RWB(o)) : +List<U32>}, {Nat.is_le(Yj, List.length(&2, U32, B0)) == ${TRUE}}), g)
      +gb = PB(RTo(o, dd, D, Xj), DK.P2({UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(B0, Yj, RWB(o)) : +List<U32>}, {Nat.is_le(Yj, List.length(&2, U32, B0)) == ${TRUE}}), g)
      +by = PA({UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(B0, Yj, RWB(o)) : +List<U32>}, {Nat.is_le(Yj, List.length(&2, U32, B0)) == ${TRUE}}, gb)
      +hX = PB({UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(B0, Yj, RWB(o)) : +List<U32>}, {Nat.is_le(Yj, List.length(&2, U32, B0)) == ${TRUE}}, gb)
      +D1 = PXo(o, dd, D, Xj)
      +pf1 = pfo(o, dd, D, Xj, pfD)
      +Y = RWB(o)
      +ey = ynext(j, q, r)
      +z1 = VRX.znext(B0, Yj, Y, YB(1n+j, q, r), ${S}, bm, UA.BYT(D1), hX, lenb(o), ey, by, hz)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(p, j), VB.pw(da), Order.left_below_sum(p, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +hi1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(da)) == ${TRUE}}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1), h1)
      +hx = FD.logic__subst(Nat, z => {FD.spec_common__nth(T.${R}, FD.array__slots(T.${R}, A), z) == Some{EL_${p}(A, 1n+j)} : Maybe<&2, T.${R}>}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1),
        VRL.nth_get(T.${R}, FD.array__slots(T.${R}, A), 1n+j, T.${R}_default(), FD.array__len_lt(T.${R}, da, A, 1n+j, pfA, h1)))
      +eg = FD.array__get(T.${R}, da, A, U32.add(i, 1), EL_${p}(A, 1n+j), VB.lt32(da, hda), hi1, hx, pfA)
      +hj2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(1n+z, ${S}), LT) == ${TRUE}}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hj)
      +hk2 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == ${TRUE}}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hk)
      +ih = ptx_${p}(p, U32.add(i, 1), 1n+j, X, q, r, dd, D1, da, A, LT, ei1, e, hd, pf1, hj2, hl, z1, pfA, hda, hk2)
      +rt2 = PA(RTK_${p}(p, U32.add(i, 1), 1n+j, X, dd, D1, A), BYK_${p}(p, U32.add(i, 1), 1n+j, q, r, dd, D1, X, A), ih)
      +by2 = PB(RTK_${p}(p, U32.add(i, 1), 1n+j, X, dd, D1, A), BYK_${p}(p, U32.add(i, 1), 1n+j, q, r, dd, D1, X, A), ih)
      +ea = Equal.cong(Array<U32>, ${RTP}, z => T.${p}_pt(p, U32.add(i, 1), X, z, AG_${p}(A, U32.add(i, 1))), T.${R}_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +eb = Equal.cong(Array<T.${R}> & T.${R}, ${RTP}, z => T.${p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), z), AG_${p}(A, U32.add(i, 1)), (${TH}, EL_${p}(A, 1n+j)), eg)
      +rt3 = Equal.trans(${RTP}, T.${p}_pt(p, U32.add(i, 1), X, T.${R}_put(FD.array__thaw(U32, D), Xj, o), AG_${p}(A, U32.add(i, 1))), T.${p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG_${p}(A, U32.add(i, 1))),
        (FD.array__thaw(U32, WX_${p}(p, U32.add(i, 1), 1n+j, dd, D1, X, A)), ${TH}), ea,
        Equal.trans(${RTP}, T.${p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG_${p}(A, U32.add(i, 1))), T.${p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), (${TH}, EL_${p}(A, 1n+j))),
          (FD.array__thaw(U32, WX_${p}(p, U32.add(i, 1), 1n+j, dd, D1, X, A)), ${TH}), eb, rt2))
      +rest = (CHV_${p}(1n+p, A, 1n+j))
      +eXn = Equal.trans(Nat, YB(1n+j, q, r), Nat.add(Yj, ${S}), Nat.add(Yj, VRX.LN(Y)), ey,
        Equal.cong(Nat, Nat, z => Nat.add(Yj, z), ${S}, VRX.LN(Y), Equal.sym(Nat, VRX.LN(Y), ${S}, lenb(o))))
      +by3 = Equal.trans(+List<U32>, UA.BYT(WX_${p}(p, U32.add(i, 1), 1n+j, dd, D1, X, A)), UW.SPL(UA.BYT(D1), YB(1n+j, q, r), rest), UW.SPL(B0, Yj, VRX.AP(Y, rest)), by2,
        VRX.spl_catx(B0, Yj, Y, rest, YB(1n+j, q, r), UA.BYT(D1), hX, eXn, by))
      (rt3, by3)


@@ _vlist_encoder_window @@
# ---- ${p}: the list's encoder window ----

def TDM_${p}(t: ${TRR}) -> Nat:
  match t:
    case FD.TLeaf{x}: 0n
    case FD.TNode{l, r}: 1n+TDM_${p}(l)

# The list object Seq{thaw(A), N} and its facts: a perfect tree of depth < 31 holding the N records (no bound past U32).
def THL_${p}(+A: ${TRR}, +N: U32) -> T.${p}_Seq: T.${p}_Seq{${TH}, N}
def OKL_${p}(+A: ${TRR}, +N: U32) -> Bool:
  Bool.and(Nat.is_lt(TDM_${p}(A), 31n), Bool.and(FD.array__perfect(T.${R}, TDM_${p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A)))))
def okl_d_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {Nat.is_lt(TDM_${p}(A), 31n) == ${TRUE}}:
  and_l(Nat.is_lt(TDM_${p}(A), 31n), Bool.and(FD.array__perfect(T.${R}, TDM_${p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A)))), h)
def okl_1_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}})
    -> {Bool.and(FD.array__perfect(T.${R}, TDM_${p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A)))) == ${TRUE}}:
  and_r(Nat.is_lt(TDM_${p}(A), 31n), Bool.and(FD.array__perfect(T.${R}, TDM_${p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A)))), h)
def okl_pf_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {FD.array__perfect(T.${R}, TDM_${p}(A), A) == ${TRUE}}:
  and_l(FD.array__perfect(T.${R}, TDM_${p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), okl_1_${p}(A, N, h))
def okl_n_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))) == ${TRUE}}:
  and_r(FD.array__perfect(T.${R}, TDM_${p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_${p}(A))), okl_1_${p}(A, N, h))

# N <= 2^d as the runtime compares it.
def le_cap_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {U32.is_le(N, FD.u32__pow2u(TDM_${p}(A))) == ${TRUE}}:
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(TDM_${p}(A))), Nat.is_le(U32.to_nat(N), U32.to_nat(FD.u32__pow2u(TDM_${p}(A)))), VU.le_u32(N, FD.u32__pow2u(TDM_${p}(A)))) : {_ == ${TRUE}}
  %Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(TDM_${p}(A))), VB.pw(TDM_${p}(A)), FD.u32__pow2u_value(TDM_${p}(A), FD.nat__lt_trans(TDM_${p}(A), 31n, 32n, okl_d_${p}(A, N, h), {==}))) : {Nat.is_le(U32.to_nat(N), _) == ${TRUE}}
  okl_n_${p}(A, N, h)

# The list's bytes, their count, and the writer's model.
def LL_${p}(+A: ${TRR}, +N: U32) -> Nat: Nat.mul(U32.to_nat(N), ${S})
def ENCL_${p}(+A: ${TRR}, +N: U32) -> +List<U32>: ${ENC}
def PUTLb_${p}(b: Bool, +A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32) -> ${TR}:
  match b:
    case True{}: D
    case False{}: WX_${p}(U32.to_nat(U32.sub(N, 1)), 0, 0n, dd, D, X, A)
def PUTL_${p}(+A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32) -> ${TR}: PUTLb_${p}(U32.is_eq(N, 0), A, N, dd, D, X)
def pfLb_${p}(+b: Bool, +A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PUTLb_${p}(b, A, N, dd, D, X)) == ${TRUE}}:
  match b:
    case True{}: pf
    case False{}: pfWX_${p}(U32.to_nat(U32.sub(N, 1)), 0, 0n, dd, D, X, A, pf)

def RTN_${p}(+b: Bool, +A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32) -> Data:
  {T.${p}_pt_nz(b, X, N, FD.array__thaw(U32, D), ${TH}) == (FD.array__thaw(U32, PUTLb_${p}(b, A, N, dd, D, X)), THL_${p}(A, N)) : Array<U32> & T.${p}_Seq}
def BYN_${p}(+b: Bool, +A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PUTLb_${p}(b, A, N, dd, D, X)) == UW.SPL(UA.BYT(D), ${X0}, ${ENC}) : +List<U32>}

# The writer's non-empty test, and its loop.
def ptnz_${p}(+A: ${TRR}, +N: U32, +b: Bool, +eb: {U32.is_eq(N, 0) == b : Bool}, +h: {OKL_${p}(A, N) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${LLv}))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${LLv}, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${LLv}) : +List<U32>})
    -> DK.P2(RTN_${p}(b, A, N, dd, D, X), BYN_${p}(b, A, N, dd, D, X, q, r)):
  match b:
    case True{}:
      +eN = Equal.cong(U32, Nat, z => U32.to_nat(z), N, 0, FD.u32alg__eq_of(N, 0, eb))
      ({==}, FD.logic__subst(Nat, z => {UA.BYT(D) == UW.SPL(UA.BYT(D), ${X0}, (CHV_${p}(z, A, 0n))) : +List<U32>}, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, eN),
        Equal.sym(+List<U32>, UW.SPL(UA.BYT(D), ${X0}, []), UA.BYT(D), VRX.spl_nil(UA.BYT(D), ${X0}))))
    case False{}:
      +c = U32.to_nat(N)
      +da = TDM_${p}(A)
      +pfA = okl_pf_${p}(A, N, h)
      +hda = okl_d_${p}(A, N, h)
      +hca = okl_n_${p}(A, N, h)
      +h1 = VRL.cposu(N, c, {==}, eb)
      +k = U32.to_nat(U32.sub(N, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(N, 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +hj = FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(z, ${S}), ${LLv}) == ${TRUE}}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), FD.nat__le_refl(${LLv}))
      +hz1 = FD.logic__subst(Nat, z => {VS.bt(Nat.mul(z, ${S}), VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(Nat.mul(z, ${S})) : +List<U32>}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), hz)
      +hz2 = FD.logic__subst(Nat, z => {VS.bt(Nat.mul(1n+k, ${S}), VS.bdr(z, UA.BYT(D))) == UW.ZB(Nat.mul(1n+k, ${S})) : +List<U32>}, ${X0}, YB(0n, q, r), Equal.sym(Nat, YB(0n, q, r), ${X0}, FD.nat__add_zero(${X0})), hz1)
      +hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == ${TRUE}}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {Nat.is_lt(k, z) == ${TRUE}}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      +eg0 = FD.array__get(T.${R}, da, A, 0, EL_${p}(A, 0n), VB.lt32(da, hda), h0, VRL.nth_get(T.${R}, FD.array__slots(T.${R}, A), 0n, T.${R}_default(), FD.array__len_lt(T.${R}, da, A, 0n, pfA, h0)), pfA)
      +g = ptx_${p}(k, 0, 0n, X, q, r, dd, D, da, A, ${LLv}, {==}, e, hd, pf, hj, hl, hz2, pfA, hda, hk)
      +rt = PA(RTK_${p}(k, 0, 0n, X, dd, D, A), BYK_${p}(k, 0, 0n, q, r, dd, D, X, A), g)
      +by = PB(RTK_${p}(k, 0, 0n, X, dd, D, A), BYK_${p}(k, 0, 0n, q, r, dd, D, X, A), g)
      +by1 = FD.logic__subst(Nat, z => {UA.BYT(WX_${p}(k, 0, 0n, dd, D, X, A)) == UW.SPL(UA.BYT(D), z, (CHV_${p}(1n+k, A, 0n))) : +List<U32>}, YB(0n, q, r), ${X0}, FD.nat__add_zero(${X0}), by)
      +ea = Equal.cong(Array<T.${R}> & T.${R}, Array<U32> & T.${p}_Seq, z => T.${p}_pt_fin(N, T.${p}_pt(k, 0, X, FD.array__thaw(U32, D), z)), Array.get(T.${R}, ${TH}, 0), (${TH}, EL_${p}(A, 0n)), eg0)
      +eb2 = Equal.cong(${RTP}, Array<U32> & T.${p}_Seq, z => T.${p}_pt_fin(N, z), T.${p}_pt(k, 0, X, FD.array__thaw(U32, D), (${TH}, EL_${p}(A, 0n))), (FD.array__thaw(U32, WX_${p}(k, 0, 0n, dd, D, X, A)), ${TH}), rt)
      (Equal.trans(Array<U32> & T.${p}_Seq, T.${p}_pt_fin(N, T.${p}_pt(k, 0, X, FD.array__thaw(U32, D), Array.get(T.${R}, ${TH}, 0))), T.${p}_pt_fin(N, T.${p}_pt(k, 0, X, FD.array__thaw(U32, D), (${TH}, EL_${p}(A, 0n)))),
         T.${p}_pt_fin(N, (FD.array__thaw(U32, WX_${p}(k, 0, 0n, dd, D, X, A)), ${TH})), ea, eb2),
       FD.logic__subst(Nat, z => {UA.BYT(WX_${p}(k, 0, 0n, dd, D, X, A)) == UW.SPL(UA.BYT(D), ${X0}, (CHV_${p}(z, A, 0n))) : +List<U32>}, 1n+k, c, e1, by1))

# The runtime's validity check of the list (no bound on N past the storage's size).
def valid_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {T.${p}_valid(THL_${p}(A, N)) == (THL_${p}(A, N), True{}) : T.${p}_Seq & Bool}:
  +d = TDM_${p}(A)
  %Equal.sym(Array<T.${R}> & U32, Array.size(T.${R}, ${TH}), (${TH}, FD.u32__pow2u(d)), FD.array__size_thaw(T.${R}, d, A, okl_pf_${p}(A, N, h))) :
    {T.${p}_va_cap(Bool.or(True{}, U32.is_le(N, 0)), N, _) == (THL_${p}(A, N), True{}) : T.${p}_Seq & Bool}
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(d)), True{}, le_cap_${p}(A, N, h)) :
    {(THL_${p}(A, N), Bool.and(Bool.or(True{}, U32.is_le(N, 0)), _)) == (THL_${p}(A, N), True{}) : T.${p}_Seq & Bool}
  {==}

def RTL_${p}(+A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${p}_putk(FD.array__thaw(U32, D), X, THL_${p}(A, N)) == (FD.array__thaw(U32, PUTL_${p}(A, N, dd, D, X)), (THL_${p}(A, N), O.mulc(N, ${RS}))) : Array<U32> & (T.${p}_Seq & U32)}
def BYL_${p}(+A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PUTL_${p}(A, N, dd, D, X)) == UW.SPL(UA.BYT(D), ${X0}, ENCL_${p}(A, N)) : +List<U32>}
def PFL_${p}(+A: ${TRR}, +N: U32, +dd: Nat, +D: ${TR}, +X: U32) -> Data:
  {FD.array__perfect(U32, dd, PUTL_${p}(A, N, dd, D, X)) == ${TRUE}}

# The runtime's write, with its validity check.
def putk_rt_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +rtb: RTN_${p}(U32.is_eq(N, 0), A, N, dd, D, X)) -> RTL_${p}(A, N, dd, D, X, q, r):
  %Equal.sym(T.${p}_Seq & Bool, T.${p}_valid(THL_${p}(A, N)), (THL_${p}(A, N), True{}), valid_${p}(A, N, h)) :
    {T.${p}_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PUTL_${p}(A, N, dd, D, X)), (THL_${p}(A, N), O.mulc(N, ${RS}))) : Array<U32> & (T.${p}_Seq & U32)}
  %Equal.sym(Array<U32> & T.${p}_Seq, T.${p}_pt_nz(U32.is_eq(N, 0), X, N, FD.array__thaw(U32, D), ${TH}), (FD.array__thaw(U32, PUTL_${p}(A, N, dd, D, X)), THL_${p}(A, N)), rtb) :
    {T.${p}_ptn_fin(N, _) == (FD.array__thaw(U32, PUTL_${p}(A, N, dd, D, X)), (THL_${p}(A, N), O.mulc(N, ${RS}))) : Array<U32> & (T.${p}_Seq & U32)}
  {==}

# putx: the runtime writer at X = 4 q + r is the model PUTL, whose bytes splice the list's bytes
# into D's (its records write their data bytes only), and whose tree is perfect.
def putx_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${LLv}))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${LLv}, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${LLv}) : +List<U32>})
    -> DK.P2(RTL_${p}(A, N, dd, D, X, q, r), DK.P2(BYL_${p}(A, N, dd, D, X, q, r), PFL_${p}(A, N, dd, D, X))):
  +b = U32.is_eq(N, 0)
  +g = ptnz_${p}(A, N, b, {==}, h, dd, D, X, q, r, e, hd, hl, pf, hz)
  +rtb = PA(RTN_${p}(b, A, N, dd, D, X), BYN_${p}(b, A, N, dd, D, X, q, r), g)
  +byb = PB(RTN_${p}(b, A, N, dd, D, X), BYN_${p}(b, A, N, dd, D, X, q, r), g)
  (putk_rt_${p}(A, N, h, dd, D, X, q, r, rtb), (byb, pfLb_${p}(b, A, N, dd, D, X, pf)))


@@ _vlist_sizes @@
# ---- sizes ----

# The runtime's size pass.
def sizex_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}) -> {T.${p}_size(THL_${p}(A, N)) == (THL_${p}(A, N), O.mulc(N, ${RS})) : T.${p}_Seq & U32}:
  +d = TDM_${p}(A)
  %Equal.sym(Array<T.${R}> & U32, Array.size(T.${R}, ${TH}), (${TH}, FD.u32__pow2u(d)), FD.array__size_thaw(T.${R}, d, A, okl_pf_${p}(A, N, h))) :
    {T.${p}_szf(N, _) == (THL_${p}(A, N), O.mulc(N, ${RS})) : T.${p}_Seq & U32}
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(d)), True{}, le_cap_${p}(A, N, h)) :
    {(THL_${p}(A, N), O.pick(_, O.mulc(N, ${RS}), 4294967295)) == (THL_${p}(A, N), O.mulc(N, ${RS})) : T.${p}_Seq & U32}
  {==}

# szxB: the size pass's O.mulc is the list's byte count when the bytes are at most NMAX (no tree).
def szxB_${p}(+A: ${TRR}, +N: U32, +hN: {Nat.is_le(${LLv}, U32.to_nat(VB.NMAX())) == ${TRUE}}) -> {U32.to_nat(O.mulc(N, ${RS})) == ${LLv} : Nat}:
  VRX.mulck(N, ${RS}, 31n, {==}, {==}, {==}, {==}, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(VB.NMAX())) == ${TRUE}}, ${LLv}, Nat.mul(U32.to_nat(N), U32.to_nat(${RS})), {==}, hN))

# szx at any depth dd < 31 (hs31: the bytes within NMAX; hl32 is not used).
def szx_${p}W(+A: ${TRR}, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 31n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${LLv}))), VB.pw(dd)) == ${TRUE}}, +hs31: {Nat.is_le(${LLv}, U32.to_nat(VB.NMAX())) == ${TRUE}},
    +hl32: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, ${LLv})), FD.spec_common__pow2(32n)) == ${TRUE}}) -> {U32.to_nat(O.mulc(N, ${RS})) == ${LLv} : Nat}:
  szxB_${p}(A, N, hs31)

# szx: the size the writer returns is the list's byte count, when the list lies in the tree.
def szx_${p}(+A: ${TRR}, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${LLv}))), VB.pw(dd)) == ${TRUE}}) -> {U32.to_nat(O.mulc(N, ${RS})) == ${LLv} : Nat}:
  szxB_${p}(A, N, VRX.hs31w(q, r, ${LLv}, dd, hd, hl))



@@ _vlist_spec_side @@
# ---- ${p}: the spec side ----

# The value of the list: the records' values.
def VALL_${p}(+A: ${TRR}, +N: U32) -> S.Value: S.Sequence{ITV_${p}(U32.to_nat(N), A, 0n)}

def len_encl_${p}(+A: ${TRR}, +N: U32) -> {List.length(&2, U32, ENCL_${p}(A, N)) == ${LLv} : Nat}: lenV_${p}(U32.to_nat(N), A, 0n)

# encx_spec: the list's value has its bytes as one variable part, when they fit a tree of depth dx < 30.
def encx_spec_${p}(+A: ${TRR}, +N: U32, +h: {OKL_${p}(A, N) == ${TRUE}}, +dx: Nat, +hdx: {Nat.is_lt(dx, 30n) == ${TRUE}},
    +hL: {Nat.is_le(${LLv}, A.quad(VB.pw(dx))) == ${TRUE}})
    -> {Codec.parts(VALL_${p}(A, N), Spec.Schema78()) == Some{[S.Variable{ENCL_${p}(A, N)}]} : Maybe<&2, +List<S.Part>>}:
  +c = U32.to_nat(N)
  +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == ${TRUE}}, ${LLv}, List.length(&2, U32, (CHV_${p}(c, A, 0n))), Equal.sym(Nat, List.length(&2, U32, (CHV_${p}(c, A, 0n))), ${LLv}, len_encl_${p}(A, N)),
    VBZ.fitq(dx, ${LLv}, hL, hdx))
  %Equal.sym(Nat, Codec.count(ITV_${p}(c, A, 0n)), c, cntV_${p}(c, A, 0n)) :
    {Codec.require(Nat.is_le(_, Nat.mul(U32.to_nat(1073741824), 1024n)), Codec.aggregate(Codec.parts(ITV_${p}(c, A, 0n), S.Repeat{Spec.Schema58()}), None{})) == Some{[S.Variable{(CHV_${p}(c, A, 0n))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Nat.is_le(c, Nat.mul(U32.to_nat(1073741824), 1024n)), True{}, V40.u32le40(N)) :
    {Codec.require(_, Codec.aggregate(Codec.parts(ITV_${p}(c, A, 0n), S.Repeat{Spec.Schema58()}), None{})) == Some{[S.Variable{(CHV_${p}(c, A, 0n))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(ITV_${p}(c, A, 0n), S.Repeat{Spec.Schema58()}), Some{FPV_${p}(c, A, 0n)}, prtV_${p}(c, A, 0n)) :
    {Codec.require(True{}, Codec.aggregate(_, None{})) == Some{[S.Variable{(CHV_${p}(c, A, 0n))}]} : Maybe<&2, +List<S.Part>>}
  +M = Nat.mul(c, ${S})
  +fit2 = FD.logic__subst(Nat, z => {N.fits(4n, z) == ${TRUE}}, List.length(&2, U32, CHV_${p}(c, A, 0n)), Nat.add(M, 0n),
    Equal.trans(Nat, List.length(&2, U32, CHV_${p}(c, A, 0n)), M, Nat.add(M, 0n), lenV_${p}(c, A, 0n), Equal.sym(Nat, Nat.add(M, 0n), M, FD.nat__add_zero(M))), fit)
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(FPV_${p}(c, A, 0n)), Some{List.append(&2, U32, CHV_${p}(c, A, 0n), [])},
      VMV.enc_gen(FPV_${p}(c, A, 0n), M, CHV_${p}(c, A, 0n), [], fsV_${p}(c, A, 0n), fpV_${p}(c, A, 0n, M), payV_${p}(c, A, 0n), validV_${p}(c, A, 0n), fit2)) :
    {Codec.one(_, None{}) == Some{[S.Variable{(CHV_${p}(c, A, 0n))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, CHV_${p}(c, A, 0n), []), CHV_${p}(c, A, 0n), VS.app_nil(CHV_${p}(c, A, 0n))) :
    {Codec.one(Some{_}, None{}) == Some{[S.Variable{(CHV_${p}(c, A, 0n))}]} : Maybe<&2, +List<S.Part>>}
  {==}

@@ COMMON @@
def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:
  (+a, +b) = p
  a
def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:
  (+a, +b) = p
  b
def and_l(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case True{}: {==}
    case False{}: h
def and_r(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {b == True{} : Bool}:
  match a:
    case True{}: h
    case False{}: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))

@@ sub_rec_text @@

# ---- the record ${R} (${RS} bytes) at a byte position P ----

def RB_${R}(o: T.${R}) -> +List<U32>:
  match o:
    case ${pat}: ${RB}
def lenr_${R}(+o: T.${R}) -> {List.length(&2, U32, RB_${R}(o)) == ${RS}n : Nat}:
  match o:
    case ${pat}: {==}
def PR_${R}(o: T.${R}, +dd: Nat, +D: ${TR}, +P: Nat) -> ${TR}:
  match o:
    case ${pat}: ${tree(n)}
def pfr_${R}(+o: T.${R}, +dd: Nat, +D: ${TR}, +P: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PR_${R}(o, dd, D, P)) == ${TRUE}}:
  match o:
    case ${pat}: ${pfs}

def RTR_${R}(+o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32, +P: Nat) -> Data:
  {T.${R}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PR_${R}(o, dd, D, P)) : Array<U32>}
def BYR_${R}(+o: T.${R}, +dd: Nat, +D: ${TR}, +P: Nat) -> Data:
  {UA.BYT(PR_${R}(o, dd, D, P)) == UW.SPL(UA.BYT(D), P, RB_${R}(o)) : +List<U32>}

# T.${R}_put at X (byte P) writes the record's bytes into the ${RS} zero bytes there.
def putr_${R}(+o: T.${R}, +dd: Nat, +D: ${TR}, +X: U32, +P: Nat, +e: {U32.to_nat(X) == P : Nat}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hb: {Nat.is_le(Nat.add(P, ${RS}n), A.quad(VB.pw(dd))) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${RS}n, VS.bdr(P, UA.BYT(D))) == UW.ZB(${RS}n) : +List<U32>})
    -> DK.P2(RTR_${R}(o, dd, D, X, P), BYR_${R}(o, dd, D, P)):
  match o:
    case ${pat}:
      +B = UA.BYT(D)
      +hX = VRB.hxb(P, ${RS}n, dd, D, pf, hb)
@@ sub_rec_text_RV_ @@


def RV_${R}(o: T.${R}) -> S.Value:
  match o:
    case ${pat}: S.Sequence{${items}}

# Its parts: its bytes, one fixed part.
def RPRF_${R}(+o: T.${R}) -> {Codec.parts(RV_${R}(o), ${sch}) == Some{[S.Fixed{RB_${R}(o)}]} : Maybe<&2, +List<S.Part>>}:
  match o:
    case ${pat}:
      %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(${items}, ${chain_from(0)}), Some{${PL}},
        ${cat(0)}) :
        {Codec.aggregate(_, Some{${RS}n}) == Some{[S.Fixed{${RB}}]} : Maybe<&2, +List<S.Part>>}
      SP2.agg(${PL}, ${RS}n, ${RS}n, {==}, ${domc(0)}, {==}, {==})

def domr_${R}(+o: T.${R}) -> {SP.bytes_domain(RB_${R}(o)) == ${TRUE}}:
  match o:
    case ${pat}: ${domc(0)}

@@ SUBLIST @@

# ---- @p: the list's bytes, value and parts ----

def EL(+A: @TRR, +j: Nat) -> T.@R: VRL.mget(T.@R, FD.spec_common__nth(T.@R, FD.array__slots(T.@R, A), j), T.@R_default())

# the records j, j + 1, ..., j + c - 1: their bytes, values, parts, and the runtime's validity of each
def RBS(c: Nat, +A: @TRR, +j: Nat) -> +List<U32>:
  match c:
    case 0n: []
    case 1n+p: VRX.AP(RB_@R(EL(A, j)), RBS(p, A, 1n+j))
def ITS(c: Nat, +A: @TRR, +j: Nat) -> S.Value:
  match c:
    case 0n: S.EmptyItems{}
    case 1n+p: S.Items{RV_@R(EL(A, j)), ITS(p, A, 1n+j)}
def BPS(c: Nat, +A: @TRR, +j: Nat) -> +List<S.Part>:
  match c:
    case 0n: []
    case 1n+p: Con{S.Fixed{RB_@R(EL(A, j))}, BPS(p, A, 1n+j)}
def VOK(c: Nat, +A: @TRR, +j: Nat) -> Bool:
  match c:
    case 0n: True{}
    case 1n+p: Bool.and(T.@R_valid(EL(A, j)), VOK(p, A, 1n+j))

law len_rbs:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {List.length(&2, U32, RBS(c, A, j)) == Nat.mul(c, @RSn) : Nat}
def len_rbs(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p:
      %len_rbs(p, A, 1n+j) :
        {List.length(&2, U32, VRX.AP(RB_@R(EL(A, j)), RBS(p, A, 1n+j))) == Nat.add(@RSn, _) : Nat}
      %lenr_@R(EL(A, j)) :
        {List.length(&2, U32, VRX.AP(RB_@R(EL(A, j)), RBS(p, A, 1n+j))) == Nat.add(_, List.length(&2, U32, RBS(p, A, 1n+j))) : Nat}
      VRX.len_app(RB_@R(EL(A, j)), RBS(p, A, 1n+j))

law dom_rbs:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {SP.bytes_domain(RBS(c, A, j)) == True{} : Bool}
def dom_rbs(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p: SP2.bd_app(RB_@R(EL(A, j)), RBS(p, A, 1n+j), domr_@R(EL(A, j)), dom_rbs(p, A, 1n+j))

law cnt_its:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {Codec.count(ITS(c, A, j)) == c : Nat}
def cnt_its(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p: FD.nat__succ_cong(Codec.count(ITS(p, A, 1n+j)), p, cnt_its(p, A, 1n+j))

law bps_all:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {SP2.allfx(BPS(c, A, j)) == True{} : Bool}
def bps_all(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p: bps_all(p, A, 1n+j)

law bps_cat:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {SP2.fcat(BPS(c, A, j)) == RBS(c, A, j) : +List<U32>}
def bps_cat(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p: Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, RB_@R(EL(A, j)), z), SP2.fcat(BPS(p, A, 1n+j)), RBS(p, A, 1n+j), bps_cat(p, A, 1n+j))

law prt_its:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {Codec.parts(ITS(c, A, j), S.Repeat{@SCH}) == Some{BPS(c, A, j)} : Maybe<&2, +List<S.Part>>}
def prt_its(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p:
      F.cat_fixed(Codec.parts(RV_@R(EL(A, j)), @SCH), RB_@R(EL(A, j)), Codec.parts(ITS(p, A, 1n+j), S.Repeat{@SCH}), BPS(p, A, 1n+j),
        RPRF_@R(EL(A, j)), prt_its(p, A, 1n+j))

# ---- @p: the runtime's validity check ----

def AG(+A: @TRR, +i: U32) -> Array<T.@R> & T.@R: Array.get(T.@R, @TH, i)

# get i+1 of the records' array, i = j and 1 + j < 2^da
def geti(+i: U32, +j: Nat, +da: Nat, +A: @TRR, +ei: {U32.to_nat(i) == j : Nat}, +pfA: {FD.array__perfect(T.@R, da, A) == True{} : Bool},
    +hda: {Nat.is_lt(da, 31n) == True{} : Bool}, +h1: {Nat.is_lt(1n+j, VB.pw(da)) == True{} : Bool})
    -> {AG(A, U32.add(i, 1)) == (@TH, EL(A, 1n+j)) : Array<T.@R> & T.@R}:
  +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
  +hi1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(da)) == True{} : Bool}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1), h1)
  +hx = FD.logic__subst(Nat, z => {FD.spec_common__nth(T.@R, FD.array__slots(T.@R, A), z) == Some{EL(A, 1n+j)} : Maybe<&2, T.@R>}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1),
    VRL.nth_get(T.@R, FD.array__slots(T.@R, A), 1n+j, T.@R_default(), FD.array__len_lt(T.@R, da, A, 1n+j, pfA, h1)))
  FD.array__get(T.@R, da, A, U32.add(i, 1), EL(A, 1n+j), VB.lt32(da, hda), hi1, hx, pfA)

def get0(+da: Nat, +A: @TRR, +pfA: {FD.array__perfect(T.@R, da, A) == True{} : Bool}, +hda: {Nat.is_lt(da, 31n) == True{} : Bool},
    +h0: {Nat.is_lt(0n, VB.pw(da)) == True{} : Bool})
    -> {AG(A, 0) == (@TH, EL(A, 0n)) : Array<T.@R> & T.@R}:
  FD.array__get(T.@R, da, A, 0, EL(A, 0n), VB.lt32(da, hda), h0, VRL.nth_get(T.@R, FD.array__slots(T.@R, A), 0n, T.@R_default(), FD.array__len_lt(T.@R, da, A, 0n, pfA, h0)), pfA)

# The validity loop from record j (index i) on, k + 1 records, all valid.
def vax(k: Nat, +i: U32, +j: Nat, +da: Nat, +A: @TRR, +ei: {U32.to_nat(i) == j : Nat}, +h: {VOK(1n+k, A, j) == True{} : Bool},
    +pfA: {FD.array__perfect(T.@R, da, A) == True{} : Bool}, +hda: {Nat.is_lt(da, 31n) == True{} : Bool}, +hk: {Nat.is_lt(Nat.add(k, j), VB.pw(da)) == True{} : Bool})
    -> {T.@p_va(k, i, True{}, (@TH, EL(A, j))) == (@TH, True{}) : Array<T.@R> & Bool}:
  match k:
    case 0n:
      %Equal.sym(Bool, T.@R_valid(EL(A, j)), True{}, and_l(T.@R_valid(EL(A, j)), VOK(0n, A, 1n+j), h)) : {(@TH, _) == (@TH, True{}) : Array<T.@R> & Bool}
      {==}
    case 1n+ +p:
      +hv = and_l(T.@R_valid(EL(A, j)), VOK(1n+p, A, 1n+j), h)
      +hr = and_r(T.@R_valid(EL(A, j)), VOK(1n+p, A, 1n+j), h)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(p, j), VB.pw(da), Order.left_below_sum(p, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +hk2 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hk)
      %Equal.sym(Bool, T.@R_valid(EL(A, j)), True{}, hv) : {T.@p_va(p, U32.add(i, 1), _, AG(A, U32.add(i, 1))) == (@TH, True{}) : Array<T.@R> & Bool}
      %Equal.sym(Array<T.@R> & T.@R, AG(A, U32.add(i, 1)), (@TH, EL(A, 1n+j)), geti(i, j, da, A, ei, pfA, hda, h1)) : {T.@p_va(p, U32.add(i, 1), True{}, _) == (@TH, True{}) : Array<T.@R> & Bool}
      vax(p, U32.add(i, 1), 1n+j, da, A, ei1, hr, pfA, hda, hk2)

# ---- @p: the write loop (record j at byte P0 + @RS j) ----

def WX(k: Nat, +j: Nat, +dd: Nat, D: @TR, +P0: Nat, +A: @TRR) -> @TR:
  match k:
    case 0n: PR_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0))
    case 1n+p: WX(p, 1n+j, dd, PR_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0)), P0, A)

law pfWX:
  for +k: Nat
  for +j: Nat
  for +dd: Nat
  for +D: @TR
  for +P0: Nat
  for +A: @TRR
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  {FD.array__perfect(U32, dd, WX(k, j, dd, D, P0, A)) == True{} : Bool}
def pfWX(k, j, dd, D, P0, A, pf):
  match k:
    case 0n: pfr_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0), pf)
    case 1n+ +p: pfWX(p, 1n+j, dd, PR_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0)), P0, A, pfr_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0), pf))

def RTK(k: Nat, +i: U32, +j: Nat, +X: U32, +P0: Nat, +dd: Nat, +D: @TR, +A: @TRR) -> Data:
  {T.@p_pt(k, i, X, FD.array__thaw(U32, D), (@TH, EL(A, j))) == (FD.array__thaw(U32, WX(k, j, dd, D, P0, A)), @TH) : @RTP}
def BYK(k: Nat, +j: Nat, +P0: Nat, +dd: Nat, +D: @TR, +A: @TRR) -> Data:
  {UA.BYT(WX(k, j, dd, D, P0, A)) == UW.SPL(UA.BYT(D), VRL.pos(j, @RSn, P0), RBS(1n+k, A, j)) : +List<U32>}

# The loop from record j (index i) on, k + 1 records, into LT bytes at X (byte P0) whose last k + 1 records' bytes are zero.
def ptx(k: Nat, +i: U32, +j: Nat, +X: U32, +P0: Nat, +dd: Nat, +D: @TR, +da: Nat, +A: @TRR, +LT: Nat,
    +ei: {U32.to_nat(i) == j : Nat}, +e: {U32.to_nat(X) == P0 : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_le(Nat.mul(Nat.add(1n+k, j), @RSn), LT) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P0, LT), A.quad(VB.pw(dd))) == True{} : Bool},
    +hz: {VS.bt(Nat.mul(1n+k, @RSn), VS.bdr(VRL.pos(j, @RSn, P0), UA.BYT(D))) == UW.ZB(Nat.mul(1n+k, @RSn)) : +List<U32>},
    +pfA: {FD.array__perfect(T.@R, da, A) == True{} : Bool}, +hda: {Nat.is_lt(da, 31n) == True{} : Bool}, +hk: {Nat.is_lt(Nat.add(k, j), VB.pw(da)) == True{} : Bool})
    -> DK.P2(RTK(k, i, j, X, P0, dd, D, A), BYK(k, j, P0, dd, D, A)):
  match k:
    case 0n:
      +o = EL(A, j)
      +Pj = VRL.pos(j, @RSn, P0)
      +Xj = U32.add(X, U32.mul(i, @RS))
      +hbj = VRB.rroomb(j, 0n, @RSn, P0, LT, A.quad(VB.pw(dd)), hj, hb)
      +ej = VRB.posb(dd, X, i, j, @RS, @RSn, P0, {==}, e, ei, hd, hbj)
      +g = putr_@R(o, dd, D, Xj, Pj, ej, hd, hbj, pfD, hz)
      +rt = PA(RTR_@R(o, dd, D, Xj, Pj), BYR_@R(o, dd, D, Pj), g)
      +by = PB(RTR_@R(o, dd, D, Xj, Pj), BYR_@R(o, dd, D, Pj), g)
      +D1 = PR_@R(o, dd, D, Pj)
      +Y = RB_@R(o)
      +rt0 = Equal.cong(Array<U32>, @RTP, z => (z, @TH), T.@R_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +by0 = FD.logic__subst(+List<U32>, z => {UA.BYT(D1) == UW.SPL(UA.BYT(D), Pj, z) : +List<U32>}, Y, List.append(&2, U32, Y, []),
        Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)), by)
      (rt0, by0)
    case 1n+ +p:
      +o = EL(A, j)
      +Pj = VRL.pos(j, @RSn, P0)
      +Xj = U32.add(X, U32.mul(i, @RS))
      +hbj = VRB.rroomb(j, 1n+p, @RSn, P0, LT, A.quad(VB.pw(dd)), hj, hb)
      +ej = VRB.posb(dd, X, i, j, @RS, @RSn, P0, {==}, e, ei, hd, hbj)
      +bm = Nat.mul(1n+p, @RSn)
      +B0 = UA.BYT(D)
      +hz0 = VRX.zhead(@RSn, bm, VS.bdr(Pj, B0), hz)
      +g = putr_@R(o, dd, D, Xj, Pj, ej, hd, hbj, pfD, hz0)
      +rt = PA(RTR_@R(o, dd, D, Xj, Pj), BYR_@R(o, dd, D, Pj), g)
      +by = PB(RTR_@R(o, dd, D, Xj, Pj), BYR_@R(o, dd, D, Pj), g)
      +D1 = PR_@R(o, dd, D, Pj)
      +pf1 = pfr_@R(o, dd, D, Pj, pfD)
      +Y = RB_@R(o)
      +hX = VRB.hxb(Pj, @RSn, dd, D, pfD, hbj)
      +ey = VRB.pnext(j, @RSn, P0)
      +z1 = VRX.znext(B0, Pj, Y, VRL.pos(1n+j, @RSn, P0), @RSn, bm, UA.BYT(D1), hX, lenr_@R(o), ey, by, hz)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(p, j), VB.pw(da), Order.left_below_sum(p, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +eg = geti(i, j, da, A, ei, pfA, hda, h1)
      +hj2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(1n+z, @RSn), LT) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hj)
      +hk2 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hk)
      +ih = ptx(p, U32.add(i, 1), 1n+j, X, P0, dd, D1, da, A, LT, ei1, e, hd, pf1, hj2, hb, z1, pfA, hda, hk2)
      +rt2 = PA(RTK(p, U32.add(i, 1), 1n+j, X, P0, dd, D1, A), BYK(p, 1n+j, P0, dd, D1, A), ih)
      +by2 = PB(RTK(p, U32.add(i, 1), 1n+j, X, P0, dd, D1, A), BYK(p, 1n+j, P0, dd, D1, A), ih)
      +ea = Equal.cong(Array<U32>, @RTP, z => T.@p_pt(p, U32.add(i, 1), X, z, AG(A, U32.add(i, 1))), T.@R_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +eb = Equal.cong(Array<T.@R> & T.@R, @RTP, z => T.@p_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), z), AG(A, U32.add(i, 1)), (@TH, EL(A, 1n+j)), eg)
      +rt3 = Equal.trans(@RTP, T.@p_pt(p, U32.add(i, 1), X, T.@R_put(FD.array__thaw(U32, D), Xj, o), AG(A, U32.add(i, 1))), T.@p_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG(A, U32.add(i, 1))),
        (FD.array__thaw(U32, WX(p, 1n+j, dd, D1, P0, A)), @TH), ea,
        Equal.trans(@RTP, T.@p_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG(A, U32.add(i, 1))), T.@p_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), (@TH, EL(A, 1n+j))),
          (FD.array__thaw(U32, WX(p, 1n+j, dd, D1, P0, A)), @TH), eb, rt2))
      +rest = RBS(1n+p, A, 1n+j)
      +eXn = Equal.trans(Nat, VRL.pos(1n+j, @RSn, P0), Nat.add(Pj, @RSn), Nat.add(Pj, VRX.LN(Y)), ey,
        Equal.cong(Nat, Nat, z => Nat.add(Pj, z), @RSn, VRX.LN(Y), Equal.sym(Nat, VRX.LN(Y), @RSn, lenr_@R(o))))
      +by3 = Equal.trans(+List<U32>, UA.BYT(WX(p, 1n+j, dd, D1, P0, A)), UW.SPL(UA.BYT(D1), VRL.pos(1n+j, @RSn, P0), rest), UW.SPL(B0, Pj, VRX.AP(Y, rest)), by2,
        VRX.spl_catx(B0, Pj, Y, rest, VRL.pos(1n+j, @RSn, P0), UA.BYT(D1), hX, eXn, by))
      (rt3, by3)

# ---- @p: the encoder-window interface ----

# The object's Data mirror: the tree A of depth da holding the N records.
type MW is Data:
  MW{da: Nat, A: @TRR, N: U32}

def TH(m: MW) -> T.@p_Seq:
  match m:
    case MW{+da, +A, +N}: T.@p_Seq{@TH, N}

# A valid object: a perfect tree of depth < 28 with room for the N records, whose @RS N bytes fit
# 4 2^da@OKDOC, and whose records pass the runtime's check.
@OKDEFS
def OK(m: MW) -> Bool:
  match m:
    case MW{+da, +A, +N}: OKT(da, A, N)

def ENC(m: MW) -> +List<U32>:
  match m:
    case MW{+da, +A, +N}: RBS(U32.to_nat(N), A, 0n)
def VAL(m: MW) -> S.Value:
  match m:
    case MW{+da, +A, +N}: S.Sequence{ITS(U32.to_nat(N), A, 0n)}
def SZ(m: MW) -> U32:
  match m:
    case MW{+da, +A, +N}: O.mulc(N, @RS)
def PUTLb(b: Bool, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +P0: Nat) -> @TR:
  match b:
    case True{}: D
    case False{}: WX(U32.to_nat(U32.sub(N, 1)), 0n, dd, D, P0, A)
def PUTX(m: MW, +dd: Nat, +D: @TR, +q: Nat, +r: Nat) -> @TR:
  match m:
    case MW{+da, +A, +N}: PUTLb(U32.is_eq(N, 0), A, N, dd, D, Nat.add(A.quad(q), r))
def PADB(+r: Nat, m: MW) -> Nat: WD.PADB(r, List.length(&2, U32, ENC(m)))

def pfLb(+b: Bool, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +P0: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PUTLb(b, A, N, dd, D, P0)) == True{} : Bool}:
  match b:
    case True{}: pf
    case False{}: pfWX(U32.to_nat(U32.sub(N, 1)), 0n, dd, D, P0, A, pf)

# N <= 2^da as the runtime compares it.
def le_cap(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}) -> {U32.is_le(N, FD.u32__pow2u(da)) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(da)), Nat.is_le(U32.to_nat(N), U32.to_nat(FD.u32__pow2u(da))), VU.le_u32(N, FD.u32__pow2u(da))) : {_ == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(da)), VB.pw(da), FD.u32__pow2u_value(da, FD.nat__lt_trans(da, 28n, 32n, ok_0(da, A, N, h), {==}))) : {Nat.is_le(U32.to_nat(N), _) == True{} : Bool}
  ok_2(da, A, N, h)
def hda31(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}) -> {Nat.is_lt(da, 31n) == True{} : Bool}:
  FD.nat__lt_trans(da, 28n, 31n, ok_0(da, A, N, h), {==})

# The runtime's validity check.
def vnz(+da: Nat, +A: @TRR, +N: U32, +b: Bool, +eb: {U32.is_eq(N, 0) == b : Bool}, +h: {OKT(da, A, N) == True{} : Bool})
    -> {T.@p_va_fin(N, True{}, T.@p_va_nz(b, N, @TH)) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}:
  match b:
    case True{}: {==}
    case False{}:
      +c = U32.to_nat(N)
      +pfA = ok_1(da, A, N, h)
      +hca = ok_2(da, A, N, h)
      +h1 = VRL.cposu(N, c, {==}, eb)
      +k = U32.to_nat(U32.sub(N, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(N, 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +hv = FD.logic__subst(Nat, z => {VOK(z, A, 0n) == True{} : Bool}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), ok_@VI(da, A, N, h))
      +hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == True{} : Bool}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {Nat.is_lt(k, z) == True{} : Bool}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      %Equal.sym(Array<T.@R> & T.@R, AG(A, 0), (@TH, EL(A, 0n)), get0(da, A, pfA, hda31(da, A, N, h), h0)) :
        {T.@p_va_fin(N, True{}, T.@p_va(k, 0, True{}, _)) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}
      %Equal.sym(Array<T.@R> & Bool, T.@p_va(k, 0, True{}, (@TH, EL(A, 0n))), (@TH, True{}), vax(k, 0, 0n, da, A, {==}, hv, pfA, hda31(da, A, N, h), hk)) :
        {T.@p_va_fin(N, True{}, _) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}
      {==}

def valid(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}) -> {T.@p_valid(T.@p_Seq{@TH, N}) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}:
  %Equal.sym(Array<T.@R> & U32, Array.size(T.@R, @TH), (@TH, FD.u32__pow2u(da)), FD.array__size_thaw(T.@R, da, A, ok_1(da, A, N, h))) :
    {T.@p_va_cap(@OKARG, N, _) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}
@LIMRW  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(da)), True{}, le_cap(da, A, N, h)) :
    {T.@p_va_go(Bool.and(@OKARG1, _), N, @TH) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}
  vnz(da, A, N, U32.is_eq(N, 0), {==}, h)

def RTN(+b: Bool, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +X: U32, +P0: Nat) -> Data:
  {T.@p_pt_nz(b, X, N, FD.array__thaw(U32, D), @TH) == (FD.array__thaw(U32, PUTLb(b, A, N, dd, D, P0)), T.@p_Seq{@TH, N}) : Array<U32> & T.@p_Seq}
def BYN(+b: Bool, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +P0: Nat) -> Data:
  {UA.BYT(PUTLb(b, A, N, dd, D, P0)) == UW.SPL(UA.BYT(D), P0, RBS(U32.to_nat(N), A, 0n)) : +List<U32>}

# The writer's non-empty test, and its loop.
def ptnz(+da: Nat, +A: @TRR, +N: U32, +b: Bool, +eb: {U32.is_eq(N, 0) == b : Bool}, +h: {OKT(da, A, N) == True{} : Bool}, +dd: Nat, +D: @TR, +X: U32, +P0: Nat,
    +e: {U32.to_nat(X) == P0 : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P0, Nat.mul(U32.to_nat(N), @RSn)), A.quad(VB.pw(dd))) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(Nat.mul(U32.to_nat(N), @RSn), VS.bdr(P0, UA.BYT(D))) == UW.ZB(Nat.mul(U32.to_nat(N), @RSn)) : +List<U32>})
    -> DK.P2(RTN(b, A, N, dd, D, X, P0), BYN(b, A, N, dd, D, P0)):
  match b:
    case True{}:
      +eN = Equal.cong(U32, Nat, z => U32.to_nat(z), N, 0, FD.u32alg__eq_of(N, 0, eb))
      ({==}, FD.logic__subst(Nat, z => {UA.BYT(D) == UW.SPL(UA.BYT(D), P0, RBS(z, A, 0n)) : +List<U32>}, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, eN),
        Equal.sym(+List<U32>, UW.SPL(UA.BYT(D), P0, []), UA.BYT(D), VRX.spl_nil(UA.BYT(D), P0))))
    case False{}:
      +c = U32.to_nat(N)
      +LL = Nat.mul(c, @RSn)
      +pfA = ok_1(da, A, N, h)
      +hda = hda31(da, A, N, h)
      +hca = ok_2(da, A, N, h)
      +h1 = VRL.cposu(N, c, {==}, eb)
      +k = U32.to_nat(U32.sub(N, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(N, 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +hj = FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(z, @RSn), LL) == True{} : Bool}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), FD.nat__le_refl(LL))
      +hz2 = FD.logic__subst(Nat, z => {VS.bt(Nat.mul(z, @RSn), VS.bdr(P0, UA.BYT(D))) == UW.ZB(Nat.mul(z, @RSn)) : +List<U32>}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), hz)
      +hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == True{} : Bool}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {Nat.is_lt(k, z) == True{} : Bool}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      +eg0 = get0(da, A, pfA, hda, h0)
      +g = ptx(k, 0, 0n, X, P0, dd, D, da, A, LL, {==}, e, hd, pf, hj, hb, hz2, pfA, hda, hk)
      +rt = PA(RTK(k, 0, 0n, X, P0, dd, D, A), BYK(k, 0n, P0, dd, D, A), g)
      +by = PB(RTK(k, 0, 0n, X, P0, dd, D, A), BYK(k, 0n, P0, dd, D, A), g)
      +ea = Equal.cong(Array<T.@R> & T.@R, Array<U32> & T.@p_Seq, z => T.@p_pt_fin(N, T.@p_pt(k, 0, X, FD.array__thaw(U32, D), z)), AG(A, 0), (@TH, EL(A, 0n)), eg0)
      +eb2 = Equal.cong(@RTP, Array<U32> & T.@p_Seq, z => T.@p_pt_fin(N, z), T.@p_pt(k, 0, X, FD.array__thaw(U32, D), (@TH, EL(A, 0n))), (FD.array__thaw(U32, WX(k, 0n, dd, D, P0, A)), @TH), rt)
      (Equal.trans(Array<U32> & T.@p_Seq, T.@p_pt_fin(N, T.@p_pt(k, 0, X, FD.array__thaw(U32, D), AG(A, 0))), T.@p_pt_fin(N, T.@p_pt(k, 0, X, FD.array__thaw(U32, D), (@TH, EL(A, 0n)))),
         T.@p_pt_fin(N, (FD.array__thaw(U32, WX(k, 0n, dd, D, P0, A)), @TH)), ea, eb2),
       FD.logic__subst(Nat, z => {UA.BYT(WX(k, 0n, dd, D, P0, A)) == UW.SPL(UA.BYT(D), P0, RBS(z, A, 0n)) : +List<U32>}, 1n+k, c, e1, by))

# The hypotheses of the interface, on the mirror's pieces.
def hbx(+da: Nat, +A: @TRR, +N: U32, +dd: Nat, +q: Nat, +r: Nat,
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(MW{da, A, N}))))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), Nat.mul(U32.to_nat(N), @RSn)), A.quad(VB.pw(dd))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), z), A.quad(VB.pw(dd))) == True{} : Bool}, List.length(&2, U32, ENC(MW{da, A, N})), Nat.mul(U32.to_nat(N), @RSn),
    len_rbs(U32.to_nat(N), A, 0n), VRX.xend(q, r, List.length(&2, U32, ENC(MW{da, A, N})), dd, hl))
def hzx(+da: Nat, +A: @TRR, +N: U32, +r: Nat, +P0: Nat, +D: @TR,
    +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N})), VS.bdr(P0, UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N}))) : +List<U32>})
    -> {VS.bt(Nat.mul(U32.to_nat(N), @RSn), VS.bdr(P0, UA.BYT(D))) == UW.ZB(Nat.mul(U32.to_nat(N), @RSn)) : +List<U32>}:
  FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(P0, UA.BYT(D))) == UW.ZB(z) : +List<U32>}, List.length(&2, U32, ENC(MW{da, A, N})), Nat.mul(U32.to_nat(N), @RSn),
    len_rbs(U32.to_nat(N), A, 0n), WD.zpre(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N}), VS.bdr(P0, UA.BYT(D)), hz))

def RTX(+da: Nat, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +X: U32, +P0: Nat) -> Data:
  {T.@p_putk(FD.array__thaw(U32, D), X, T.@p_Seq{@TH, N}) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, O.mulc(N, @RS))) : Array<U32> & (T.@p_Seq & U32)}

def putk_rt(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}, +dd: Nat, +D: @TR, +X: U32, +P0: Nat,
    +rtb: RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0)) -> RTX(da, A, N, dd, D, X, P0):
  %Equal.sym(T.@p_Seq & Bool, T.@p_valid(T.@p_Seq{@TH, N}), (T.@p_Seq{@TH, N}, True{}), valid(da, A, N, h)) :
    {T.@p_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, O.mulc(N, @RS))) : Array<U32> & (T.@p_Seq & U32)}
  %Equal.sym(Array<U32> & T.@p_Seq, T.@p_pt_nz(U32.is_eq(N, 0), X, N, FD.array__thaw(U32, D), @TH), (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), T.@p_Seq{@TH, N}), rtb) :
    {T.@p_ptn_fin(N, _) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, O.mulc(N, @RS))) : Array<U32> & (T.@p_Seq & U32)}
  {==}

def go(+da: Nat, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(MW{da, A, N}))))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N})), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N}))) : +List<U32>},
    +h: {OKT(da, A, N) == True{} : Bool})
    -> DK.P2(RTN(U32.is_eq(N, 0), A, N, dd, D, X, Nat.add(A.quad(q), r)), BYN(U32.is_eq(N, 0), A, N, dd, D, Nat.add(A.quad(q), r))):
  ptnz(da, A, N, U32.is_eq(N, 0), {==}, h, dd, D, X, Nat.add(A.quad(q), r), e, hd, hbx(da, A, N, dd, q, r, hl), pf, hzx(da, A, N, r, Nat.add(A.quad(q), r), D, hz))

# ---- the interface's laws ----------------------------------------------------------------------

law putx:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {T.@p_putk(FD.array__thaw(U32, D), X, TH(m)) == (FD.array__thaw(U32, PUTX(m, dd, D, q, r)), (TH(m), SZ(m))) : Array<U32> & (T.@p_Seq & U32)}
def putx(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case MW{+da, +A, +N}:
      +P0 = Nat.add(A.quad(q), r)
      +g = go(da, A, N, dd, D, X, q, r, e, hd, pf, hl, hz, hok)
      putk_rt(da, A, N, hok, dd, D, X, P0, PA(RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0), BYN(U32.is_eq(N, 0), A, N, dd, D, P0), g))

law putx_bytes:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {UA.BYT(PUTX(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, ENC(m), UW.ZB(PADB(r, m)))) : +List<U32>}
def putx_bytes(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case MW{+da, +A, +N}:
      +P0 = Nat.add(A.quad(q), r)
      +g = go(da, A, N, dd, D, X, q, r, e, hd, pf, hl, hz, hok)
      +E = RBS(U32.to_nat(N), A, 0n)
      Equal.trans(+List<U32>, UA.BYT(PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), UW.SPL(UA.BYT(D), P0, E), UW.SPL(UA.BYT(D), P0, List.append(&2, U32, E, UW.ZB(PADB(r, MW{da, A, N})))),
        PB(RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0), BYN(U32.is_eq(N, 0), A, N, dd, D, P0), g),
        VRB.spl_pad(UA.BYT(D), P0, E, List.length(&2, U32, E), PADB(r, MW{da, A, N}), {==}, hz))

law pfx:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +q: Nat
  for +r: Nat
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  {FD.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == True{} : Bool}
def pfx(m, dd, D, q, r, pf):
  match m:
    case MW{+da, +A, +N}: pfLb(U32.is_eq(N, 0), A, N, dd, D, Nat.add(A.quad(q), r), pf)

law szx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {U32.to_nat(SZ(m)) == List.length(&2, U32, ENC(m)) : Nat}
def szx(m, hok):
  match m:
    case MW{+da, +A, +N}:
      +Q = A.quad(VB.pw(da))
      +hp = FD.u32__pow2u_value(2n+da, FD.nat__lt_trans(2n+da, 30n, 32n, ok_0(da, A, N, hok), {==}))
      Equal.trans(Nat, U32.to_nat(O.mulc(N, @RS)), Nat.mul(U32.to_nat(N), @RSn), List.length(&2, U32, RBS(U32.to_nat(N), A, 0n)),
        VRX.mulck(N, @RS, 31n, {==}, {==}, {==}, {==}, VB.le_pw30_nmax(Nat.mul(U32.to_nat(N), @RSn), FD.nat__le_trans(Nat.mul(U32.to_nat(N), @RSn), Q, VB.pw(30n), ok_3(da, A, N, hok),
          FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(30n)) == True{} : Bool}, VB.pw(2n+da), Q, Equal.sym(Nat, Q, VB.pw(2n+da), UW.qpw(da)),
            FD.nat__pow2_mono(2n+da, 30n, FD.nat__lt_le(2n+da, 30n, ok_0(da, A, N, hok))))))),
        Equal.sym(Nat, List.length(&2, U32, RBS(U32.to_nat(N), A, 0n)), Nat.mul(U32.to_nat(N), @RSn), len_rbs(U32.to_nat(N), A, 0n)))

law sizex:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.@p_size(TH(m)) == (TH(m), SZ(m)) : T.@p_Seq & U32}
def sizex(m, hok):
  match m:
    case MW{+da, +A, +N}:
      %Equal.sym(Array<T.@R> & U32, Array.size(T.@R, @TH), (@TH, FD.u32__pow2u(da)), FD.array__size_thaw(T.@R, da, A, ok_1(da, A, N, hok))) :
        {T.@p_szf(N, _) == (T.@p_Seq{@TH, N}, O.mulc(N, @RS)) : T.@p_Seq & U32}
      %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(da)), True{}, le_cap(da, A, N, hok)) :
        {(T.@p_Seq{@TH, N}, O.pick(_, O.mulc(N, @RS), 4294967295)) == (T.@p_Seq{@TH, N}, O.mulc(N, @RS)) : T.@p_Seq & U32}
      {==}

law validx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.@p_valid(TH(m)) == (TH(m), True{}) : T.@p_Seq & Bool}
def validx(m, hok):
  match m:
    case MW{+da, +A, +N}: valid(da, A, N, hok)

law encx_spec:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {Codec.parts(VAL(m), @LSCH) == Some{[S.Variable{ENC(m)}]} : Maybe<&2, +List<S.Part>>}
def encx_spec(m, hok):
  match m:
    case MW{+da, +A, +N}:
      +c = U32.to_nat(N)
      +FS = Nat.mul(c, @RSn)
      +Y = RBS(c, A, 0n)
      +ha = bps_all(c, A, 0n)
      +cat = bps_cat(c, A, 0n)
      +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, FS, Nat.add(FS, 0n), Equal.sym(Nat, Nat.add(FS, 0n), FS, FD.nat__add_zero(FS)),
        VFT.fits4(2n+da, FS, ok_3(da, A, N, hok), FD.nat__lt_trans(da, 28n, 30n, ok_0(da, A, N, hok), {==})))
      +hs = Equal.trans(Nat, Layout.fixed_size(BPS(c, A, 0n)), List.length(&2, U32, SP2.fcat(BPS(c, A, 0n))), FS, SP2.fsz(BPS(c, A, 0n), ha),
        Equal.trans(Nat, List.length(&2, U32, SP2.fcat(BPS(c, A, 0n))), List.length(&2, U32, Y), FS, Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), SP2.fcat(BPS(c, A, 0n)), Y, cat), len_rbs(c, A, 0n)))
      +hfp = Equal.trans(+List<U32>, Layout.fixed_parts(BPS(c, A, 0n), FS), SP2.fcat(BPS(c, A, 0n)), Y, SP2.fxp(BPS(c, A, 0n), FS, ha), cat)
      +hv = SP2.bvl(BPS(c, A, 0n), ha, FD.logic__subst(+List<U32>, z => {SP.bytes_domain(z) == True{} : Bool}, Y, SP2.fcat(BPS(c, A, 0n)), Equal.sym(+List<U32>, SP2.fcat(BPS(c, A, 0n)), Y, cat), dom_rbs(c, A, 0n)))
@SPECRW      %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(ITS(c, A, 0n), S.Repeat{@SCH}), Some{BPS(c, A, 0n)}, prt_its(c, A, 0n)) :
        {@AGG(Codec.aggregate(_, None{})) == Some{[S.Variable{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(BPS(c, A, 0n)), Some{List.append(&2, U32, Y, [])},
          VMV.enc_gen(BPS(c, A, 0n), FS, Y, [], hs, hfp, SP2.pay0(BPS(c, A, 0n), ha), hv, fit)) :
        {Codec.one(_, None{}) == Some{[S.Variable{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)) : {Codec.one(Some{_}, None{}) == Some{[S.Variable{Y}]} : Maybe<&2, +List<S.Part>>}
      {==}

@@ specrw @@
      +hlim = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(N, ${LIM}), Nat.is_le(U32.to_nat(N), U32.to_nat(${LIM})), VU.le_u32(N, ${LIM}), ok_4(da, A, N, hok))
      %Equal.sym(Nat, Codec.count(ITS(c, A, 0n)), c, cnt_its(c, A, 0n)) :
        {Codec.require(Nat.is_le(_, ${LIM}n), Codec.aggregate(Codec.parts(ITS(c, A, 0n), S.Repeat{@SCH}), None{})) == Some{[S.Variable{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(Bool, Nat.is_le(c, ${LIM}n), True{}, hlim) :
        {Codec.require(_, Codec.aggregate(Codec.parts(ITS(c, A, 0n), S.Repeat{@SCH}), None{})) == Some{[S.Variable{Y}]} : Maybe<&2, +List<S.Part>>}

@@ VEC_TAIL @@

def RTX(+da: Nat, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +X: U32, +P0: Nat) -> Data:
  {T.@p_putk(FD.array__thaw(U32, D), X, T.@p_Seq{@TH, N}) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, 0)) : Array<U32> & (T.@p_Seq & U32)}

# The vector's checked writer: its check passes, then the loop, its size flag 0.
def putk_rt(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}, +dd: Nat, +D: @TR, +X: U32, +P0: Nat,
    +rtb: RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0)) -> RTX(da, A, N, dd, D, X, P0):
  %Equal.sym(T.@p_Seq & Bool, T.@p_valid(T.@p_Seq{@TH, N}), (T.@p_Seq{@TH, N}, True{}), valid(da, A, N, h)) :
    {T.@p_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, 0)) : Array<U32> & (T.@p_Seq & U32)}
  %Equal.sym(Array<U32> & T.@p_Seq, T.@p_pt_nz(U32.is_eq(N, 0), X, N, FD.array__thaw(U32, D), @TH), (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), T.@p_Seq{@TH, N}), rtb) :
    {T.@p_pk_ok(_) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, 0)) : Array<U32> & (T.@p_Seq & U32)}
  {==}

# N = @NV, and the bytes' count
def en(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}) -> {U32.to_nat(N) == @NVn : Nat}:
  Equal.cong(U32, Nat, z => U32.to_nat(z), N, @NV, FD.u32alg__eq_of(N, @NV, ok_3(da, A, N, h)))
def enb(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}) -> {Nat.mul(U32.to_nat(N), @RSn) == @NBn : Nat}:
  Equal.cong(Nat, Nat, z => Nat.mul(z, @RSn), U32.to_nat(N), @NVn, en(da, A, N, h))

# The loop over exactly the @NB bytes at X = 4 q + r (zero there), data-only.
def fwgo(+da: Nat, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, @NBn))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(@NBn, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(@NBn) : +List<U32>},
    +h: {OKT(da, A, N) == True{} : Bool})
    -> DK.P2(RTN(U32.is_eq(N, 0), A, N, dd, D, X, Nat.add(A.quad(q), r)), BYN(U32.is_eq(N, 0), A, N, dd, D, Nat.add(A.quad(q), r))):
  +P0 = Nat.add(A.quad(q), r)
  +eb = enb(da, A, N, h)
  +hb = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(P0, z), A.quad(VB.pw(dd))) == True{} : Bool}, @NBn, Nat.mul(U32.to_nat(N), @RSn), Equal.sym(Nat, Nat.mul(U32.to_nat(N), @RSn), @NBn, eb),
    VRX.xend(q, r, @NBn, dd, hl))
  +hz2 = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(P0, UA.BYT(D))) == UW.ZB(z) : +List<U32>}, @NBn, Nat.mul(U32.to_nat(N), @RSn), Equal.sym(Nat, Nat.mul(U32.to_nat(N), @RSn), @NBn, eb), hz)
  ptnz(da, A, N, U32.is_eq(N, 0), {==}, h, dd, D, X, P0, e, hd, hb, pf, hz2)

# ---- the vector as a fixed field (codegen/proofs/var/container_encoder_windows.py's FixW) ---------------------------------

law lenv:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {List.length(&2, U32, ENC(m)) == @NBn : Nat}
def lenv(m, hok):
  match m:
    case MW{+da, +A, +N}: Equal.trans(Nat, List.length(&2, U32, RBS(U32.to_nat(N), A, 0n)), Nat.mul(U32.to_nat(N), @RSn), @NBn, len_rbs(U32.to_nat(N), A, 0n), enb(da, A, N, hok))

law fwrt:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, @NBn))), VB.pw(dd)) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hz: {VS.bt(@NBn, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(@NBn) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {T.@p_putk(FD.array__thaw(U32, D), X, TH(m)) == (FD.array__thaw(U32, PUTX(m, dd, D, q, r)), (TH(m), 0)) : Array<U32> & (T.@p_Seq & U32)}
def fwrt(m, dd, D, X, q, r, e, hr, hd, hl, pf, hz, hok):
  match m:
    case MW{+da, +A, +N}:
      +P0 = Nat.add(A.quad(q), r)
      +g = fwgo(da, A, N, dd, D, X, q, r, e, hd, pf, hl, hz, hok)
      putk_rt(da, A, N, hok, dd, D, X, P0, PA(RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0), BYN(U32.is_eq(N, 0), A, N, dd, D, P0), g))

law fwby:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, @NBn))), VB.pw(dd)) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hz: {VS.bt(@NBn, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(@NBn) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {UA.BYT(PUTX(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), ENC(m)) : +List<U32>}
def fwby(m, dd, D, X, q, r, e, hr, hd, hl, pf, hz, hok):
  match m:
    case MW{+da, +A, +N}:
      +P0 = Nat.add(A.quad(q), r)
      +g = fwgo(da, A, N, dd, D, X, q, r, e, hd, pf, hl, hz, hok)
      PB(RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0), BYN(U32.is_eq(N, 0), A, N, dd, D, P0), g)

law pfx:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +q: Nat
  for +r: Nat
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  {FD.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == True{} : Bool}
def pfx(m, dd, D, q, r, pf):
  match m:
    case MW{+da, +A, +N}: pfLb(U32.is_eq(N, 0), A, N, dd, D, Nat.add(A.quad(q), r), pf)

law validx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.@p_valid(TH(m)) == (TH(m), True{}) : T.@p_Seq & Bool}
def validx(m, hok):
  match m:
    case MW{+da, +A, +N}: valid(da, A, N, hok)

# The spec: the vector's parts are one fixed part, its bytes.
law vspec:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {Codec.parts(VAL(m), S.Vector{@SCH, @NVn}) == Some{[S.Fixed{ENC(m)}]} : Maybe<&2, +List<S.Part>>}
def vspec(m, hok):
  match m:
    case MW{+da, +A, +N}:
      +c = U32.to_nat(N)
      +FS = Nat.mul(c, @RSn)
      +Y = RBS(c, A, 0n)
      +ha = bps_all(c, A, 0n)
      +cat = bps_cat(c, A, 0n)
      +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, @NBn, Nat.add(FS, 0n),
        Equal.trans(Nat, @NBn, FS, Nat.add(FS, 0n), Equal.sym(Nat, FS, @NBn, enb(da, A, N, hok)), Equal.sym(Nat, Nat.add(FS, 0n), FS, FD.nat__add_zero(FS))), {==})
      +hs = Equal.trans(Nat, Layout.fixed_size(BPS(c, A, 0n)), List.length(&2, U32, SP2.fcat(BPS(c, A, 0n))), FS, SP2.fsz(BPS(c, A, 0n), ha),
        Equal.trans(Nat, List.length(&2, U32, SP2.fcat(BPS(c, A, 0n))), List.length(&2, U32, Y), FS, Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), SP2.fcat(BPS(c, A, 0n)), Y, cat), len_rbs(c, A, 0n)))
      +hfp = Equal.trans(+List<U32>, Layout.fixed_parts(BPS(c, A, 0n), FS), SP2.fcat(BPS(c, A, 0n)), Y, SP2.fxp(BPS(c, A, 0n), FS, ha), cat)
      +hv = SP2.bvl(BPS(c, A, 0n), ha, FD.logic__subst(+List<U32>, z => {SP.bytes_domain(z) == True{} : Bool}, Y, SP2.fcat(BPS(c, A, 0n)), Equal.sym(+List<U32>, SP2.fcat(BPS(c, A, 0n)), Y, cat), dom_rbs(c, A, 0n)))
      +hc = FD.logic__subst(Nat, z => {Nat.is_eq(z, @NVn) == True{} : Bool}, @NVn, c, Equal.sym(Nat, c, @NVn, en(da, A, N, hok)), {==})
      %Equal.sym(Nat, Codec.count(ITS(c, A, 0n)), c, cnt_its(c, A, 0n)) :
        {Codec.require(Bool.and(Nat.is_lt(0n, @NVn), Nat.is_eq(_, @NVn)), Codec.aggregate(Codec.parts(ITS(c, A, 0n), S.Repeat{@SCH}), SS.times(@NVn, SS.fixed_size(@SCH)))) == Some{[S.Fixed{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(Bool, Nat.is_eq(c, @NVn), True{}, hc) :
        {Codec.require(Bool.and(Nat.is_lt(0n, @NVn), _), Codec.aggregate(Codec.parts(ITS(c, A, 0n), S.Repeat{@SCH}), SS.times(@NVn, SS.fixed_size(@SCH)))) == Some{[S.Fixed{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(ITS(c, A, 0n), S.Repeat{@SCH}), Some{BPS(c, A, 0n)}, prt_its(c, A, 0n)) :
        {Codec.aggregate(_, SS.times(@NVn, SS.fixed_size(@SCH))) == Some{[S.Fixed{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(BPS(c, A, 0n)), Some{List.append(&2, U32, Y, [])},
          VMV.enc_gen(BPS(c, A, 0n), FS, Y, [], hs, hfp, SP2.pay0(BPS(c, A, 0n), ha), hv, fit)) :
        {Codec.one(_, SS.times(@NVn, SS.fixed_size(@SCH))) == Some{[S.Fixed{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)) : {Codec.one(Some{_}, SS.times(@NVn, SS.fixed_size(@SCH))) == Some{[S.Fixed{Y}]} : Maybe<&2, +List<S.Part>>}
      {==}

@@ _ETOT @@

# The encoding of fixed parts of words, as aggregate_fixed takes it.
def etot(+wss: +List<+List<U32>>, +n: Nat, +fit: {N.fits(4n, List.length(&2, U32, F.flat(wss))) == True{} : Bool})
    -> {Codec.one(Layout.encoding(F.fparts(wss)), Some{n}) == Codec.one(SP.optional(Bool.and(Layout.bytes_valid(F.fparts(wss)), True{}), F.flat(wss)), Some{n}) : Maybe<&2, +List<S.Part>>}:
  Equal.trans(Maybe<&2, +List<S.Part>>, Codec.one(Layout.encoding(F.fparts(wss)), Some{n}), Codec.one(Some{F.flat(wss)}, Some{n}),
    Codec.one(SP.optional(Bool.and(Layout.bytes_valid(F.fparts(wss)), True{}), F.flat(wss)), Some{n}),
    Equal.cong(Maybe<&2, +List<U32>>, Maybe<&2, +List<S.Part>>, z => Codec.one(z, Some{n}), Layout.encoding(F.fparts(wss)), Some{F.flat(wss)}, VS.encoding_fparts(wss, fit)),
    Equal.cong(Bool, Maybe<&2, +List<S.Part>>, z => Codec.one(SP.optional(Bool.and(z, True{}), F.flat(wss)), Some{n}), True{}, Layout.bytes_valid(F.fparts(wss)),
      Equal.sym(Bool, Layout.bytes_valid(F.fparts(wss)), True{}, F.valid_fparts(wss))))

@@ _em_text @@

def PXEm(+m: MB<${M}>, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
  match m:
    case MNone{}: D
    case MSome{+v}: PXE(v, dd, D, q, r)
def YEm(+m: MB<${M}>) -> +List<U32>:
  match m:
    case MNone{}: UW.ZB(${RS}n)
    case MSome{+v}: YE(v)
def pfEm(+m: MB<${M}>, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PXEm(m, dd, D, q, r)) == ${TRUE}}:
  match m:
    case MNone{}: pf
    case MSome{+v}: pfE(v, dd, D, q, r, pf)
def lenEz(+m: MB<${M}>) -> {VRX.LN(YEm(m)) == ${RS}n : Nat}:
  match m:
    case MNone{}: {==}
    case MSome{+v}: lenE0(v)
def lenEm(+m: MB<${M}>, +h: {EOK(m) == ${TRUE}}) -> {VRX.LN(YEm(m)) == ${RS}n : Nat}: lenEz(m)
def RTEm(+m: MB<${M}>, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${E}_bx_put(FD.array__thaw(U32, D), X, th_${E}_bx(m)) == (FD.array__thaw(U32, PXEm(m, dd, D, q, r)), th_${E}_bx(m)) : Array<U32> & O.Boxed<T.${E}>}
def BYEm(+m: MB<${M}>, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXEm(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, YEm(m)) : +List<U32>}
def mkEm(+m: MB<${M}>, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +a: RTEm(m, dd, D, X, q, r), +b: BYEm(m, dd, D, q, r)) -> DK.P2(RTEm(m, dd, D, X, q, r), BYEm(m, dd, D, q, r)):
  (a, b)
def putxEm(+m: MB<${M}>, +h: {EOK(m) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${RS}n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${RS}n, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${RS}n) : +List<U32>})
    -> DK.P2(RTEm(m, dd, D, X, q, r), BYEm(m, dd, D, q, r)):
  match m:
    case MNone{}: Empty.absurd(DK.P2(RTEm(MNone{}, dd, D, X, q, r), BYEm(MNone{}, dd, D, q, r)), FD.logic__false_true(h))
    case MSome{+v}:
      +g = putxE(v, h, dd, D, X, q, r, e, hr, hd, hl, pf, hz)
      +rt = PA(RTE(v, dd, D, X, q, r), BYE(v, dd, D, q, r), g)
      +by = PB(RTE(v, dd, D, X, q, r), BYE(v, dd, D, q, r), g)
      mkEm(MSome{v}, dd, D, X, q, r, Equal.cong(${ty}, Array<U32> & O.Boxed<T.${E}>, z => T.${E}_bx_put_back(z), T.${E}_put(FD.array__thaw(U32, D), X, th_${E}(v)),
        (FD.array__thaw(U32, PXE(v, dd, D, q, r)), th_${E}(v)), rt), by)
def EVm(+m: MB<${M}>) -> S.Value:
  match m:
    case MNone{}: S.NullValue{}
    case MSome{+v}: EV(v)
def specEm(+m: MB<${M}>, +h: {EOK(m) == ${TRUE}}) -> {Codec.parts(EVm(m), ${ES}) == Some{[S.Fixed{YEm(m)}]} : Maybe<&2, +List<S.Part>>}:
  match m:
    case MNone{}: Empty.absurd({Codec.parts(EVm(MNone{}), ${ES}) == Some{[S.Fixed{YEm(MNone{})}]} : Maybe<&2, +List<S.Part>>}, FD.logic__false_true(h))
    case MSome{+v}: specE(v, h)

@@ lenp @@
Equal.trans(Nat, VRX.LN(${cat(k)}), Nat.add(VRX.LN(${Y[k]}), VRX.LN(${cat(k + 1)})), ${tot}n, VCN.len_app(${Y[k]}, ${cat(k + 1)}), Equal.trans(Nat, Nat.add(VRX.LN(${Y[k]}), VRX.LN(${cat(k + 1)})), Nat.add(${S[k]}n, VRX.LN(${cat(k + 1)})), ${tot}n, Equal.cong(Nat, Nat, z => Nat.add(z, VRX.LN(${cat(k + 1)})), VRX.LN(${Y[k]}), ${S[k]}n, lenb_${R[k]}(a${k})), Equal.cong(Nat, Nat, z => Nat.add(${S[k]}n, z), VRX.LN(${cat(k + 1)}), ${rest}n, ${lenp(k + 1)})))
@@ belem_text @@

# ---- ${E}: its writer on the mirror ----

def OKE(+v: ${M}) -> Bool: True{}
def EOK(+m: MB<${M}>) -> Bool:
  match m:
    case MNone{}: False{}
    case MSome{+v}: OKE(v)
def PXE(+v: ${M}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
  match v:
    case ${pat}: ${model(n - 1)}
def YE(+v: ${M}) -> +List<U32>:
  match v:
    case ${pat}: ${cat(0)}
def lenE0(+v: ${M}) -> {VRX.LN(YE(v)) == ${RS}n : Nat}:
  match v:
    case ${pat}: ${lenp(0)}
def lenE(+v: ${M}, +h: {OKE(v) == ${TRUE}}) -> {VRX.LN(YE(v)) == ${RS}n : Nat}: lenE0(v)
def pfE(+v: ${M}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PXE(v, dd, D, q, r)) == ${TRUE}}:
  match v:
    case ${pat}: ${pfs(n - 1)}
def validE(+v: ${M}, +h: {OKE(v) == ${TRUE}}) -> {T.${E}_valid(th_${E}(v)) == (th_${E}(v), True{}) : T.${E} & Bool}:
  match v:
    case ${pat}: {==}
def RTE(+v: ${M}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${E}_put(FD.array__thaw(U32, D), X, th_${E}(v)) == (FD.array__thaw(U32, PXE(v, dd, D, q, r)), th_${E}(v)) : Array<U32> & T.${E}}
def BYE(+v: ${M}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXE(v, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, YE(v)) : +List<U32>}
def mkE(+v: ${M}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +a: RTE(v, dd, D, X, q, r), +b: BYE(v, dd, D, q, r)) -> DK.P2(RTE(v, dd, D, X, q, r), BYE(v, dd, D, q, r)):
  (a, b)

@@ belem_text_putxE @@
def putxE(+v: ${M}, +h: {OKE(v) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, ${RS}n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(${RS}n, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(${RS}n) : +List<U32>})
    -> DK.P2(RTE(v, dd, D, X, q, r), BYE(v, dd, D, q, r)):
  match v:
    case ${pat}:
      ${body}
      mkE(${M}{${', '.join(av)}}, dd, D, X, q, r, ${chain(0, start)}, S0)

@@ belem_text_EV @@

# ---- ${E}: its value (its records' values) and its parts, one fixed part of its bytes ----
def EV(+v: ${M}) -> S.Value:
  match v:
    case ${pat}: S.Sequence{${items(0)}}
def specE(+v: ${M}, +h: {OKE(v) == ${TRUE}}) -> {Codec.parts(EV(v), ${ES}) == Some{[S.Fixed{YE(v)}]} : Maybe<&2, +List<S.Part>>}:
  match v:
    case ${pat}:
      +ef = ${ef}
      +fit = FD.logic__subst(+List<U32>, z => {N.fits(4n, List.length(&2, U32, z)) == ${TRUE}}, ${c0}, F.flat(${wss}), Equal.sym(+List<U32>, F.flat(${wss}), ${c0}, ef),
        FD.logic__subst(Nat, z => {N.fits(4n, z) == ${TRUE}}, ${RS}n, VRX.LN(${c0}), Equal.sym(Nat, VRX.LN(${c0}), ${RS}n, ${lenp(0)}), {==}))
      FD.logic__subst(+List<U32>, z => {Codec.parts(S.Sequence{${items(0)}}, ${ES}) == Some{[S.Fixed{z}]} : Maybe<&2, +List<S.Part>>}, F.flat(${wss}), ${c0}, ef,
        F.aggregate_fixed(Codec.parts(${items(0)}, ${chn(0)}), ${wss}, ${RS}n, ${cf(0)}, etot(${wss}, ${RS}n, fit)))

@@ belem_deposit_text @@

# ---- Deposit: its writer on the mirror ----

def TDW(t: FD.array__Tree<U32>) -> Nat:
  match t:
    case FD.TLeaf{x}: 0n
    case FD.TNode{l, r}: 1n+TDW(l)
# The proof's storage: a perfect tree of depth < 28 with room for its 264 words, 1056 bytes.
def OKW(+t: FD.array__Tree<U32>, +n: U32) -> Bool: ${OKW}
def okw_d(+t: FD.array__Tree<U32>, +n: U32, +h: {OKW(t, n) == ${TRUE}}) -> {Nat.is_lt(TDW(t), 28n) == ${TRUE}}:
  and_l(Nat.is_lt(TDW(t), 28n), Bool.and(FD.array__perfect(U32, TDW(t), t), Bool.and(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056))), h)
def okw_1(+t: FD.array__Tree<U32>, +n: U32, +h: {OKW(t, n) == ${TRUE}}) -> {Bool.and(FD.array__perfect(U32, TDW(t), t), Bool.and(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056))) == ${TRUE}}:
  and_r(Nat.is_lt(TDW(t), 28n), Bool.and(FD.array__perfect(U32, TDW(t), t), Bool.and(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056))), h)
def okw_pf(+t: FD.array__Tree<U32>, +n: U32, +h: {OKW(t, n) == ${TRUE}}) -> {FD.array__perfect(U32, TDW(t), t) == ${TRUE}}:
  and_l(FD.array__perfect(U32, TDW(t), t), Bool.and(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056)), okw_1(t, n, h))
def okw_2(+t: FD.array__Tree<U32>, +n: U32, +h: {OKW(t, n) == ${TRUE}}) -> {Bool.and(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056)) == ${TRUE}}:
  and_r(FD.array__perfect(U32, TDW(t), t), Bool.and(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056)), okw_1(t, n, h))
def okw_room(+t: FD.array__Tree<U32>, +n: U32, +h: {OKW(t, n) == ${TRUE}}) -> {Nat.is_le(264n, VB.pw(TDW(t))) == ${TRUE}}:
  and_l(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056), okw_2(t, n, h))
def okw_n(+t: FD.array__Tree<U32>, +n: U32, +h: {OKW(t, n) == ${TRUE}}) -> {n == 1056 : U32}:
  FD.u32alg__eq_of(n, 1056, and_r(Nat.is_le(264n, VB.pw(TDW(t))), U32.is_eq(n, 1056), okw_2(t, n, h)))
# its bytes fit its tree: 1056 <= 4 2^d
def okw_hn(+t: FD.array__Tree<U32>, +n: U32, +h: {OKW(t, n) == ${TRUE}}) -> {Nat.is_le(1056n, A.quad(VB.pw(TDW(t)))) == ${TRUE}}:
  VCN.VME4(264n, VB.pw(TDW(t)), okw_room(t, n, h))

def OKE(+v: ${M}) -> Bool:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}: OKW(t, n)
def EOK(+m: MB<${M}>) -> Bool:
  match m:
    case MNone{}: False{}
    case MSome{+v}: OKE(v)
def TW(+v: ${M}) -> FD.array__Tree<U32>:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}: t
def PXE(+v: ${M}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> ${TR}:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}: ${D2}
def YE(+v: ${M}) -> +List<U32>:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}: VCN.CAT([VCN.PC(1056n, ${Y1}), VCN.PC(184n, ${Y2})])
def lenE0(+v: ${M}) -> {VRX.LN(YE(v)) == 1240n : Nat}:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}: {==}
def lenE(+v: ${M}, +h: {OKE(v) == ${TRUE}}) -> {VRX.LN(YE(v)) == 1240n : Nat}: lenE0(v)
def pfE(+v: ${M}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PXE(v, dd, D, q, r)) == ${TRUE}}:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}: pfo_DepositData(a1, dd, ${D1}, Nat.add(264n, q), r, WD.pwm_perfect(r, dd, D, q, t, 1056, pf))

# The proof's validity check, for its 1056 bytes.
def wvalid(+t: FD.array__Tree<U32>, +n: U32, +h: {OKW(t, n) == ${TRUE}}) -> {T.v33_b32_valid(${WOB}) == (${WOB}, True{}) : O.Words & Bool}:
  +d = TDW(t)
  +hd = okw_d(t, n, h)
  VBE.words_ok_b(d, t, 1056, 1056, 1056, VL.KK(d), okw_pf(t, n, h), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), VL.kk_lt(d, hd), VL.hyn(d, 1056, okw_hn(t, n, h)),
    {==}, {==}, okw_room(t, n, h), {==}, 32, {==})

def validE(+v: ${M}, +h: {OKE(v) == ${TRUE}}) -> {T.${E}_valid(th_${E}(v)) == (th_${E}(v), True{}) : T.${E} & Bool}:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}:
          %Equal.sym(U32, n, 1056, okw_n(t, n, h)) : {T.${E}_valid(T.Deposit{O.Words{FD.array__thaw(U32, t), _}, O.BSome{a1, O.BNone{}}}) == (T.Deposit{O.Words{FD.array__thaw(U32, t), _}, O.BSome{a1, O.BNone{}}}, True{}) : T.${E} & Bool}
          %Equal.sym(O.Words & Bool, T.v33_b32_valid(${WOB}), (${WOB}, True{}), wvalid(t, n, h)) :
            {T.${E}_va0(O.BSome{a1, O.BNone{}}, True{}, _) == (${OBJ}, True{}) : T.${E} & Bool}
          {==}

def RTE(+v: ${M}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${E}_put(FD.array__thaw(U32, D), X, th_${E}(v)) == (FD.array__thaw(U32, PXE(v, dd, D, q, r)), th_${E}(v)) : Array<U32> & T.${E}}
def BYE(+v: ${M}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PXE(v, dd, D, q, r)) == UW.SPL(UA.BYT(D), ${X0}, YE(v)) : +List<U32>}
def mkE(+v: ${M}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +a: RTE(v, dd, D, X, q, r), +b: BYE(v, dd, D, q, r)) -> DK.P2(RTE(v, dd, D, X, q, r), BYE(v, dd, D, q, r)):
  (a, b)

# With the proof's length n, then 1056 (its storage t).
def RTEn(+t: FD.array__Tree<U32>, +n: U32, +a1: T.DepositData, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${E}_put(FD.array__thaw(U32, D), X, T.Deposit{O.Words{FD.array__thaw(U32, t), n}, O.BSome{a1, O.BNone{}}}) == (FD.array__thaw(U32, ${D2}), T.Deposit{O.Words{FD.array__thaw(U32, t), n}, O.BSome{a1, O.BNone{}}}) : Array<U32> & T.${E}}
def RTE1(+t: FD.array__Tree<U32>, +a1: T.DepositData, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.${E}_put(FD.array__thaw(U32, D), X, ${OBJ}) == (FD.array__thaw(U32, ${D2}), ${OBJ}) : Array<U32> & T.${E}}
def BYE1(+t: FD.array__Tree<U32>, +a1: T.DepositData, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(${D2}) == UW.SPL(UA.BYT(D), ${X0}, VCN.CAT([VCN.PC(1056n, ${Y1}), VCN.PC(184n, ${Y2})])) : +List<U32>}
def mkE1(+t: FD.array__Tree<U32>, +a1: T.DepositData, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat, +a: RTE1(t, a1, dd, D, X, q, r), +b: BYE1(t, a1, dd, D, q, r))
    -> DK.P2(RTE1(t, a1, dd, D, X, q, r), BYE1(t, a1, dd, D, q, r)):
  (a, b)

def putx1(+t: FD.array__Tree<U32>, +n: U32, +a1: T.DepositData, +h: {OKW(t, n) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1240n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(1240n, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(1240n) : +List<U32>})
    -> DK.P2(RTE1(t, a1, dd, D, X, q, r), BYE1(t, a1, dd, D, q, r)):
  +dw = TDW(t)
  +hdw = okw_d(t, n, h)
  +pfT = okw_pf(t, n, h)
  +B0 = UA.BYT(D)
  +hX = VRX.xstart(q, r, 1240n, dd, D, pf, hl)
  +I0r = VCN.reg_init(B0, ${X0}, [1056n, 184n], hz)
  +I0 = FD.logic__subst(+List<+List<U32>>, zz => {B0 == UW.SPL(B0, ${X0}, VCN.CAT(zz)) : +List<U32>}, VCN.ZBS([1056n, 184n]),
    VCN.LAP([], Con{UW.ZB(1056n), [UW.ZB(184n)]}), {==}, I0r)
  +ep0 = VRX.fpos(X, q, r, 0n, 0, 1240n, dd, e, {==}, hd, {==}, hl)
  +hl0 = VRX.froom(q, r, dd, 0n, 1056n, 1240n, {==}, hl)
  +hp0 = VCN.zb_pre(184n, [], ${PT}, FD.nat__le_trans(${PT}, 3n, 184n, VCN.padb3(r, 1056n), {==}))
  +z0 = VCN.reg_zero(B0, ${X0}, [], 1056n, [UW.ZB(184n)], ${PT}, B0, hX, I0, hp0)
  +hz0 = FD.logic__subst(Nat, zz => {VS.bt(Nat.add(1056n, ${PT}), VS.bdr(zz, B0)) == UW.ZB(Nat.add(1056n, ${PT})) : +List<U32>}, Nat.add(${X0}, 0n), Nat.add(A.quad(Nat.add(0n, q)), r),
    FD.nat__add_zero(${X0}), z0)
  +hsrc = FD.nat__le_trans(Nat.add(VC.NW(1056), 0n), 264n, VB.pw(dw), {==}, okw_room(t, n, h))
  +w0 = WD.putw_any(dd, D, U32.add(X, 0), Nat.add(0n, q), r, dw, t, 1056, VL.KK(dw), ep0, hr, hd, FD.nat__lt_trans(dw, 28n, 31n, hdw, {==}), VL.kk_lt(dw, hdw),
    VL.hyn(dw, 1056, okw_hn(t, n, h)), hsrc, hl0, pf, pfT, {==}, hz0)
  +b0 = WD.putw_any_bytes(dd, D, U32.add(X, 0), Nat.add(0n, q), r, dw, t, 1056, VL.KK(dw), ep0, hr, hd, FD.nat__lt_trans(dw, 28n, 31n, hdw, {==}), VL.kk_lt(dw, hdw),
    VL.hyn(dw, 1056, okw_hn(t, n, h)), hsrc, hl0, pf, pfT, {==}, hz0)
  +hop0 = FD.logic__subst(Nat, zz => {UA.BYT(${D1}) == UW.SPL(B0, zz, VCN.AP(${Y1}, UW.ZB(${PT}))) : +List<U32>}, Nat.add(A.quad(Nat.add(0n, q)), r), Nat.add(${X0}, 0n),
    Equal.sym(Nat, Nat.add(${X0}, 0n), ${X0}, FD.nat__add_zero(${X0})), b0)
  +h264 = FD.logic__subst(Nat, zz => {Nat.is_le(264n, zz) == ${TRUE}}, VB.pw(dw), List.length(&2, U32, UW.SLW(t)), Equal.sym(Nat, List.length(&2, U32, UW.SLW(t)), VB.pw(dw),
    Equal.trans(Nat, List.length(&2, U32, UW.SLW(t)), FD.spec_common__length(U32, UW.SLW(t)), VB.pw(dw), VMR.len_eq(UW.SLW(t)), FD.array__slots_length(U32, dw, t, pfT))), okw_room(t, n, h))
  +h1056 = FD.logic__subst(Nat, zz => {Nat.is_le(1056n, zz) == ${TRUE}}, A.quad(List.length(&2, U32, UW.SLW(t))), List.length(&2, U32, F.limbs(UW.SLW(t))),
    Equal.sym(Nat, List.length(&2, U32, F.limbs(UW.SLW(t))), A.quad(List.length(&2, U32, UW.SLW(t))), UW.len_limbs_q(UW.SLW(t))), VCN.VME4(264n, List.length(&2, U32, UW.SLW(t)), h264))
  +I1 = VCN.reg_putc(B0, ${X0}, [], 1056n, [UW.ZB(184n)], ${Y1}, ${PT}, B0, UA.BYT(${D1}), hX, I0, VS.bt_len(1056n, F.limbs(UW.SLW(t)), h1056), hp0, hop0)
  +I1s = FD.logic__subst(+List<+List<U32>>, zz => {UA.BYT(${D1}) == UW.SPL(B0, ${X0}, VCN.CAT(zz)) : +List<U32>}, VCN.LAP([], Con{VCN.PC(1056n, ${Y1}), [UW.ZB(184n)]}),
    VCN.LAP([VCN.PC(1056n, ${Y1})], Con{UW.ZB(184n), []}), {==}, I1)
  +pf1 = WD.pwm_perfect(r, dd, D, q, t, 1056, pf)
  +ep1 = VRX.fpos(X, q, r, 264n, 1056, 1240n, dd, e, {==}, hd, {==}, hl)
  +hl1 = VRX.froom(q, r, dd, 264n, 184n, 1240n, {==}, hl)
  +z1 = VCN.reg_zero(B0, ${X0}, [VCN.PC(1056n, ${Y1})], 184n, [], 0n, UA.BYT(${D1}), hX, I1s, {==})
  +hz1 = FD.logic__subst(Nat, zz => {VS.bt(184n, VS.bdr(zz, UA.BYT(${D1}))) == UW.ZB(184n) : +List<U32>}, Nat.add(${X0}, VCN.LN(VCN.CAT([VCN.PC(1056n, ${Y1})]))), Nat.add(A.quad(Nat.add(264n, q)), r),
    VRX.fpx(q, r, 264n), z1)
  +g1 = putxo_DepositData(a1, dd, ${D1}, U32.add(X, 1056), Nat.add(264n, q), r, ep1, hr, hd, hl1, pf1, hz1)
  +rt1 = PA(RTo_DepositData(a1, dd, ${D1}, U32.add(X, 1056), Nat.add(264n, q), r), BYo_DepositData(a1, dd, ${D1}, Nat.add(264n, q), r), g1)
  +by1 = PB(RTo_DepositData(a1, dd, ${D1}, U32.add(X, 1056), Nat.add(264n, q), r), BYo_DepositData(a1, dd, ${D1}, Nat.add(264n, q), r), g1)
  +hop1 = FD.logic__subst(Nat, zz => {UA.BYT(${D2}) == UW.SPL(UA.BYT(${D1}), zz, ${Y2}) : +List<U32>}, Nat.add(A.quad(Nat.add(264n, q)), r),
    Nat.add(${X0}, VCN.LN(VCN.CAT([VCN.PC(1056n, ${Y1})]))), Equal.sym(Nat, Nat.add(${X0}, VCN.LN(VCN.CAT([VCN.PC(1056n, ${Y1})]))), Nat.add(A.quad(Nat.add(264n, q)), r), VRX.fpx(q, r, 264n)), by1)
  +I2 = VCN.reg_putc0(B0, ${X0}, [VCN.PC(1056n, ${Y1})], 184n, [], ${Y2}, UA.BYT(${D1}), UA.BYT(${D2}), hX, I1s, lenb_DepositData(a1), hop1)
  +s1 = Equal.cong(O.Words & Bool, Array<U32> & (O.Words & U32), z => T.v33_b32_pk(FD.array__thaw(U32, D), U32.add(X, 0), z), T.v33_b32_valid(${WOB}), (${WOB}, True{}), wvalid(t, n, h))
  +s2 = Equal.cong(Array<U32> & O.Words, Array<U32> & (O.Words & U32), z => T.v33_b32_pk_ok(z), O.put_words(FD.array__thaw(U32, D), U32.add(X, 0), ${WOB}), (FD.array__thaw(U32, ${D1}), ${WOB}), w0)
  +pw = Equal.trans(Array<U32> & (O.Words & U32), T.v33_b32_pk(FD.array__thaw(U32, D), U32.add(X, 0), T.v33_b32_valid(${WOB})), T.v33_b32_pk(FD.array__thaw(U32, D), U32.add(X, 0), (${WOB}, True{})),
    (FD.array__thaw(U32, ${D1}), (${WOB}, 0)), s1, s2)
  +c1 = Equal.cong(Array<U32> & (O.Words & U32), Array<U32> & T.${E}, z => T.${E}_put_drop(T.${E}_pw0(X, 0, O.BSome{a1, O.BNone{}}, z)),
    T.v33_b32_putk(FD.array__thaw(U32, D), U32.add(X, 0), ${WOB}), (FD.array__thaw(U32, ${D1}), (${WOB}, 0)), pw)
  +c2 = Equal.cong(Array<U32>, Array<U32> & T.${E}, z => T.${E}_put_drop(T.${E}_pw1(X, (0 .|. 0 : U32), ${WOB}, (z, (O.BSome{a1, O.BNone{}}, O.pz(T.DepositData_valid(a1)))))),
    T.DepositData_put(FD.array__thaw(U32, ${D1}), U32.add(X, 1056), a1), FD.array__thaw(U32, ${D2}), rt1)
  +rtf = Equal.trans(Array<U32> & T.${E}, T.${E}_put_drop(T.${E}_pw0(X, 0, O.BSome{a1, O.BNone{}}, T.v33_b32_putk(FD.array__thaw(U32, D), U32.add(X, 0), ${WOB}))),
    T.${E}_put_drop(T.${E}_pw0(X, 0, O.BSome{a1, O.BNone{}}, (FD.array__thaw(U32, ${D1}), (${WOB}, 0)))), (FD.array__thaw(U32, ${D2}), ${OBJ}), c1, c2)
  +I2s = FD.logic__subst(+List<+List<U32>>, zz => {UA.BYT(${D2}) == UW.SPL(UA.BYT(D), ${X0}, VCN.CAT(zz)) : +List<U32>}, VCN.LAP([VCN.PC(1056n, ${Y1})], Con{VCN.PC(184n, ${Y2}), []}),
    [VCN.PC(1056n, ${Y1}), VCN.PC(184n, ${Y2})], {==}, I2)
  mkE1(t, a1, dd, D, X, q, r, rtf, I2s)

def putxE(+v: ${M}, +h: {OKE(v) == ${TRUE}}, +dd: Nat, +D: ${TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == ${X0} : Nat}, +hr: {Nat.is_lt(r, 4n) == ${TRUE}}, +hd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1240n))), VB.pw(dd)) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hz: {VS.bt(1240n, VS.bdr(${X0}, UA.BYT(D))) == UW.ZB(1240n) : +List<U32>})
    -> DK.P2(RTE(v, dd, D, X, q, r), BYE(v, dd, D, q, r)):
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}:
          FD.logic__subst(U32, z => DK.P2(RTEn(t, z, a1, dd, D, X, q, r), BYE1(t, a1, dd, D, q, r)), 1056, n, Equal.sym(U32, n, 1056, okw_n(t, n, h)),
            putx1(t, n, a1, h, dd, D, X, q, r, e, hr, hd, hl, pf, hz))

@@ belem_deposit_text_EV @@

# ---- Deposit: its value (the proof's 33 byte vectors, then the DepositData) and its parts ----
def EV(+v: ${M}) -> S.Value:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}: S.Sequence{${ITEMS}}
def specE(+v: ${M}, +h: {OKE(v) == ${TRUE}}) -> {Codec.parts(EV(v), ${ES}) == Some{[S.Fixed{YE(v)}]} : Maybe<&2, +List<S.Part>>}:
  match v:
    case ${M}{+a0, +a1}:
      match a0:
        case WMr{+t, +n}:
          +dw = TDW(t)
          +pfT = okw_pf(t, n, h)
          +h264 = FD.logic__subst(Nat, zz => {Nat.is_le(264n, zz) == ${TRUE}}, VB.pw(dw), List.length(&2, U32, UW.SLW(t)), Equal.sym(Nat, List.length(&2, U32, UW.SLW(t)), VB.pw(dw),
            Equal.trans(Nat, List.length(&2, U32, UW.SLW(t)), FD.spec_common__length(U32, UW.SLW(t)), VB.pw(dw), VMR.len_eq(UW.SLW(t)), FD.array__slots_length(U32, dw, t, pfT))), okw_room(t, n, h))
          +h1056 = FD.logic__subst(Nat, zz => {Nat.is_le(1056n, zz) == ${TRUE}}, A.quad(List.length(&2, U32, UW.SLW(t))), List.length(&2, U32, F.limbs(UW.SLW(t))),
            Equal.sym(Nat, List.length(&2, U32, F.limbs(UW.SLW(t))), A.quad(List.length(&2, U32, UW.SLW(t))), UW.len_limbs_q(UW.SLW(t))), VCN.VME4(264n, List.length(&2, U32, UW.SLW(t)), h264))
          +hN = Equal.trans(Nat, F.wlen(${WSP}), List.length(&2, U32, F.limbs(${WSP})), 1056n, Equal.sym(Nat, List.length(&2, U32, F.limbs(${WSP})), F.wlen(${WSP}), VS.len_limbs(${WSP})),
            VCN.len_wt(264n, UW.SLW(t), h264))
          +vp = AV.vparts8(${FS[0]}, ${WSP}, 33n, 264n, 1056n, {==}, {==}, {==}, {==}, VCN.len_wtk(264n, UW.SLW(t), h264), {==}, hN, {==})
          +e1 = Equal.trans(+List<U32>, F.limbs(${WSP}), ${Y1}, VCN.PC(1056n, ${Y1}), Equal.sym(+List<U32>, ${Y1}, F.limbs(${WSP}), VS.bt_limbs(264n, UW.SLW(t))),
            Equal.sym(+List<U32>, VCN.PC(1056n, ${Y1}), ${Y1}, VCN.pc_id(1056n, ${Y1}, VS.bt_len(1056n, F.limbs(UW.SLW(t)), h1056))))
          +eA = Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, z, List.append(&2, U32, ${Y2}, [])), F.limbs(${WSP}), VCN.PC(1056n, ${Y1}), e1)
          +eB = Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, VCN.PC(1056n, ${Y1}), List.append(&2, U32, z, [])), ${Y2}, VCN.PC(184n, ${Y2}),
            Equal.sym(+List<U32>, VCN.PC(184n, ${Y2}), ${Y2}, VCN.pc_id(184n, ${Y2}, lenb_DepositData(a1))))
          +ef = Equal.trans(+List<U32>, F.flat(${wss}), List.append(&2, U32, VCN.PC(1056n, ${Y1}), List.append(&2, U32, ${Y2}, [])), ${YEv}, eA, eB)
          +fit = FD.logic__subst(+List<U32>, z => {N.fits(4n, List.length(&2, U32, z)) == ${TRUE}}, ${YEv}, F.flat(${wss}), Equal.sym(+List<U32>, F.flat(${wss}), ${YEv}, ef), {==})
          FD.logic__subst(+List<U32>, z => {Codec.parts(S.Sequence{${ITEMS}}, ${ES}) == Some{[S.Fixed{z}]} : Maybe<&2, +List<S.Part>>}, F.flat(${wss}), ${YEv}, ef,
            F.aggregate_fixed(Codec.parts(${ITEMS}, ${CH}), ${wss}, 1240n,
              F.cat_fixed(Codec.parts(S.Sequence{AV.ch8(${WSP})}, ${FS[0]}), F.limbs(${WSP}), Codec.parts(S.Items{RVW_DepositData(a1), S.EmptyItems{}}, S.Chain{${FS[1]}, S.End{}}),
                [S.Fixed{${Y2}}], vp, F.cat_fixed(Codec.parts(RVW_DepositData(a1), ${FS[1]}), ${Y2}, Codec.parts(S.EmptyItems{}, S.End{}), [], rparts_DepositData(a1), {==})),
              etot(${wss}, 1240n, fit)))

@@ BMULW @@
def bmulW(+i: U32, +j: Nat, +Su: U32, +S: Nat, +eS: {U32.to_nat(Su) == S : Nat}, +ei: {U32.to_nat(i) == j : Nat},
    +hm: {Nat.is_lt(Nat.mul(j, S), FD.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.mul(i, Su)) == Nat.mul(j, S) : Nat}:
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, U32.to_nat(Su)), Nat.mul(j, S),
    Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Su)), U32.to_nat(i), j, ei), Equal.cong(Nat, Nat, z => Nat.mul(j, z), U32.to_nat(Su), S, eS))
  Equal.trans(Nat, U32.to_nat(U32.mul(i, Su)), Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, S),
    VU.mul_lt32(i, Su, FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, Nat.mul(j, S), Nat.mul(U32.to_nat(i), U32.to_nat(Su)),
      Equal.sym(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, S), em), hm)),
    em)


@@ rec_text_lines @@
def pf_${n}(${WSIG}, +dd: Nat, +D: ${TR}, +q: Nat, +r: Nat, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PX_${n}(${WA}, dd, D, q, r)) == ${TRUE}}:
  ${pfs}
@@ rec_text_lines_2 @@
  +ep${i} = VRX.fpos(X, q, r, ${c // 4}n, ${c}, ${Ln}, dd, e, {==}, hd, {==}, hl)
  +hl${i} = VRX.froom(q, r, dd, ${c // 4}n, ${m}n, ${Ln}, {==}, hl)
  +z${i} = UW.inv_zero(UA.BYT(D), ${X0}, ${Ln}, ${E}, ${c}n, ${m}n, UA.BYT(${Di}), hX, I${i}, {==}, {==}, {==})
  +hz${i} = FD.logic__subst(Nat, zz => {VS.bt(${m}n, VS.bdr(zz, UA.BYT(${Di}))) == UW.ZB(${m}n) : +List<U32>}, Nat.add(${X0}, ${c}n), Nat.add(A.quad(${pos}), r), VRX.fpx(q, r, ${c // 4}n), z${i})
@@ urec_text_lines @@
def pf_${n}(${WSIG}, +dd: Nat, +D: ${TR}, +X: U32, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, PX_${n}(${WA}, dd, D, X)) == ${TRUE}}:
  ${pfs}
def BY_${n}(${WSIG}) -> +List<U32>: ${BYTES}
@@ urec_text_lines_2 @@
  +pp${i} = VP.ppos(X, ${c}, ${c}n, q, r, ${Ln}, ${m}n, dd, e, {==}, hd, {==}, hl)
  +hl${i} = VP.proom(X, ${c}, ${c}n, q, r, ${Ln}, ${m}n, dd, e, {==}, hd, {==}, hl)
  +z${i} = UW.inv_zero(UA.BYT(D), ${X0}, ${Ln}, ${E}, ${c}n, ${m}n, UA.BYT(${Di}), hX, I${i}, {==}, {==}, {==})
  +hz${i} = FD.logic__subst(Nat, zz => {VS.bt(${m}n, VS.bdr(zz, UA.BYT(${Di}))) == UW.ZB(${m}n) : +List<U32>}, Nat.add(${X0}, ${c}n), ${pos}, pp${i}, z${i})
@@ belem_text_lines @@
+ep${k} = VRX.fpos(X, q, r, ${C[k] // 4}n, ${C[k]}, ${RS}n, dd, e, {==}, hd, {==}, hl)
+hl${k} = VRX.froom(q, r, dd, ${C[k] // 4}n, ${S[k]}n, ${RS}n, {==}, hl)
+hz${k} = VRX.zhead(${S[k]}n, ${rem}n, VS.bdr(${Xk(k)}, UA.BYT(${Dk(k)})), ${Zk})
@@ belem_text_lines_2 @@
+g${k} = putxo_${R[k]}(a${k}, dd, ${Dk(k)}, U32.add(X, ${C[k]}), ${qk[k]}, r, ep${k}, hr, hd, hl${k}, ${pfk}, hz${k})
+rt${k} = PA(RTo_${R[k]}(a${k}, dd, ${Dk(k)}, U32.add(X, ${C[k]}), ${qk[k]}, r), BYo_${R[k]}(a${k}, dd, ${Dk(k)}, ${qk[k]}, r), g${k})
+by${k} = PB(RTo_${R[k]}(a${k}, dd, ${Dk(k)}, U32.add(X, ${C[k]}), ${qk[k]}, r), BYo_${R[k]}(a${k}, dd, ${Dk(k)}, ${qk[k]}, r), g${k})
+pf${k + 1} = pfo_${R[k]}(a${k}, dd, ${Dk(k)}, ${qk[k]}, r, ${pfk})
+hX${k} = VRX.xstart(${qk[k]}, r, ${S[k]}n, dd, ${Dk(k)}, ${pfk}, hl${k})