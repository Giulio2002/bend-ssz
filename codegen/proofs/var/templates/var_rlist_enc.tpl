@@ rec_text @@

# ---- ${R}: its ${W} words, value, parts and writer ----

def RWD_${R}(r: T.${R}) -> List<&2, U32>:
${body}
${pad}${WL}

def RVW_${R}(r: T.${R}) -> S.Value:
${body}
${pad}${val}

@RPARTS

def rlen_${R}(+r: T.${R}) -> {VF.slen(RWD_${R}(r)) == ${W}n : Nat}:
${body}
${pad}{==}

def putR_${R}(+dd: Nat, +D: ${TR}, +pos: U32, +P: Nat, +e: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}},
    +hb: {Nat.is_le(Nat.add(${W}n, P), VB.pw(dd)) == ${TRUE}}, +r: T.${R})
    -> {T.${R}_put(FD.array__thaw(U32, D), pos, r) == FD.array__thaw(U32, VF.updv(RWD_${R}(r), dd, D, P)) : Array<U32>}:
${body}
${pad}VT2.put_${ft.p}(dd, D, pos, P, e, hdd, pf, hb, ${', '.join(words)})

@@ rec_text_2 @@
 to the value first)
def rvq_${R}(${ws_}) -> {${val} == RVW_${R}(${obj}) : S.Value}: {==}
def rpc_${R}(${ws_}) -> {Codec.parts(${val}, ${sch}) == ${RS_}}:
  ${proof}
def rparts_${R}(+r: T.${R}) -> {Codec.parts(RVW_${R}(r), ${sch}) == Some{[S.Fixed{F.limbs(RWD_${R}(r))}]} : Maybe<&2, +List<S.Part>>}:
${body}
${pad}%rvq_${R}(${wa}) : {Codec.parts(_, ${sch}) == ${RS_}}
${pad}rpc_${R}(${wa})

@@ list_text @@

# ---- ${p}: the write loop and the list writer ----

def EL_${p}(+A: ${TRR}, +j: Nat) -> T.${R}: ${EL('j')}

# the records j, j + 1, ..., j + k of A written from word Q + ${W} j on
def WT_${p}(k: Nat, +j: Nat, +dd: Nat, D: ${TR}, +Q: Nat, +A: ${TRR}) -> ${TR}:
  match k:
    case 0n: VF.updv(RWD_${R}(EL_${p}(A, j)), dd, D, ${POS('j')})
    case 1n+q: WT_${p}(q, 1n+j, dd, VF.updv(RWD_${R}(EL_${p}(A, j)), dd, D, ${POS('j')}), Q, A)

def ptl_${p}(k: Nat, +i: U32, +j: Nat, +pos: U32, +Q: Nat, +dd: Nat, +D: ${TR}, +da: Nat, +A: ${TRR},
    +ei: {U32.to_nat(i) == j : Nat}, +ep: {U32.to_nat(pos) == A.quad(Q) : Nat}, +hdd: {Nat.is_lt(dd, 29n) == ${TRUE}},
    +pfD: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +hb: {Nat.is_le(${POS('Nat.add(1n+k, j)')}, VB.pw(dd)) == ${TRUE}},
    +pfA: {FD.array__perfect(T.${R}, da, A) == ${TRUE}}, +hda: {Nat.is_lt(da, 31n) == ${TRUE}}, +hk: {Nat.is_lt(Nat.add(k, j), VB.pw(da)) == ${TRUE}})
    -> {T.${p}_pt(k, i, pos, FD.array__thaw(U32, D), (FD.array__thaw(T.${R}, A), EL_${p}(A, j))) == (FD.array__thaw(U32, WT_${p}(k, j, dd, D, Q, A)), FD.array__thaw(T.${R}, A)) : ${RT}}:
  match k:
    case 0n:
      %Equal.sym(Array<U32>, T.${R}_put(FD.array__thaw(U32, D), U32.add(pos, U32.mul(i, ${RS})), EL_${p}(A, j)), FD.array__thaw(U32, VF.updv(RWD_${R}(EL_${p}(A, j)), dd, D, ${POS('j')})),
          putR_${R}(dd, D, U32.add(pos, U32.mul(i, ${RS})), ${POS('j')}, VRL.posW(dd, pos, Q, i, j, ${RS}, ${W}n, {==}, ep, ei, hdd, VRL.fit0(j, ${W}n, Q, VB.pw(dd), hb)), hdd, pfD,
            VRL.fit0(j, ${W}n, Q, VB.pw(dd), hb), EL_${p}(A, j))) :
        {(_, FD.array__thaw(T.${R}, A)) == (FD.array__thaw(U32, WT_${p}(0n, j, dd, D, Q, A)), FD.array__thaw(T.${R}, A)) : ${RT}}
      {==}
    case 1n+ +q:
      +D1 = VF.updv(RWD_${R}(EL_${p}(A, j)), dd, D, ${POS('j')})
      +hbj = VRL.fitk(j, q, ${W}n, Q, VB.pw(dd), hb)
      +hb2 = FD.logic__subst(Nat, z => {Nat.is_le(VRL.pos(1n+z, ${W}n, Q), VB.pw(dd)) == ${TRUE}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb)
      +hk2 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == ${TRUE}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hk)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(q, j), VB.pw(da), Order.left_below_sum(q, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +hi1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(da)) == ${TRUE}}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1), h1)
      +hx = FD.logic__subst(Nat, z => {FD.spec_common__nth(T.${R}, FD.array__slots(T.${R}, A), z) == Some{EL_${p}(A, 1n+j)} : Maybe<&2, T.${R}>}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1),
        VRL.nth_get(T.${R}, FD.array__slots(T.${R}, A), 1n+j, T.${R}_default(), FD.array__len_lt(T.${R}, da, A, 1n+j, pfA, h1)))
      %Equal.sym(Array<U32>, T.${R}_put(FD.array__thaw(U32, D), U32.add(pos, U32.mul(i, ${RS})), EL_${p}(A, j)), FD.array__thaw(U32, D1),
          putR_${R}(dd, D, U32.add(pos, U32.mul(i, ${RS})), ${POS('j')}, VRL.posW(dd, pos, Q, i, j, ${RS}, ${W}n, {==}, ep, ei, hdd, hbj), hdd, pfD, hbj, EL_${p}(A, j))) :
        {T.${p}_pt(q, U32.add(i, 1), pos, _, Array.get(T.${R}, FD.array__thaw(T.${R}, A), U32.add(i, 1))) == (FD.array__thaw(U32, WT_${p}(1n+q, j, dd, D, Q, A)), FD.array__thaw(T.${R}, A)) : ${RT}}
      %Equal.sym(Array<T.${R}> & T.${R}, Array.get(T.${R}, FD.array__thaw(T.${R}, A), U32.add(i, 1)), (FD.array__thaw(T.${R}, A), EL_${p}(A, 1n+j)),
          FD.array__get(T.${R}, da, A, U32.add(i, 1), EL_${p}(A, 1n+j), VB.lt32(da, hda), hi1, hx, pfA)) :
        {T.${p}_pt(q, U32.add(i, 1), pos, FD.array__thaw(U32, D1), _) == (FD.array__thaw(U32, WT_${p}(1n+q, j, dd, D, Q, A)), FD.array__thaw(T.${R}, A)) : ${RT}}
      ptl_${p}(q, U32.add(i, 1), 1n+j, pos, Q, dd, D1, da, A, ei1, ep, hdd, VF.updv_perfect(RWD_${R}(EL_${p}(A, j)), dd, D, ${POS('j')}, pfD), hb2, pfA, hda, hk2)

law pfWT_${p}:
  for +k: Nat
  for +j: Nat
  for +dd: Nat
  for +D: ${TR}
  for +Q: Nat
  for +A: ${TRR}
  for +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}}
  {FD.array__perfect(U32, dd, WT_${p}(k, j, dd, D, Q, A)) == ${TRUE}}
def pfWT_${p}(k, j, dd, D, Q, A, pf):
  match k:
    case 0n: VF.updv_perfect(RWD_${R}(EL_${p}(A, j)), dd, D, ${POS('j')}, pf)
    case 1n+ +q: pfWT_${p}(q, 1n+j, dd, VF.updv(RWD_${R}(EL_${p}(A, j)), dd, D, ${POS('j')}), Q, A, VF.updv_perfect(RWD_${R}(EL_${p}(A, j)), dd, D, ${POS('j')}, pf))

# the list's output: nothing when it is empty, else the records' runs
def LW_${p}(e: Bool, +n: U32, +dd: Nat, D: ${TR}, +Q: Nat, +A: ${TRR}) -> ${TR}:
  match e:
    case True{}: D
    case False{}: WT_${p}(U32.to_nat(U32.sub(n, 1)), 0n, dd, D, Q, A)

def pfLW_${p}(+e: Bool, +n: U32, +dd: Nat, +D: ${TR}, +Q: Nat, +A: ${TRR}, +pf: {FD.array__perfect(U32, dd, D) == ${TRUE}})
    -> {FD.array__perfect(U32, dd, LW_${p}(e, n, dd, D, Q, A)) == ${TRUE}}:
  match e:
    case True{}: pf
    case False{}: pfWT_${p}(U32.to_nat(U32.sub(n, 1)), 0n, dd, D, Q, A, pf)

def ptnz_${p}(+n: U32, +c: Nat, +ec: {U32.to_nat(n) == c : Nat}, +S: U32, +Q: Nat, +eS: {U32.to_nat(S) == A.quad(Q) : Nat}, +dd: Nat, +D: ${TR}, +da: Nat, +A: ${TRR},
    +hdd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +pfD: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +hbd: {Nat.is_le(${POS('c')}, VB.pw(dd)) == ${TRUE}},
    +pfA: {FD.array__perfect(T.${R}, da, A) == ${TRUE}}, +hda: {Nat.is_lt(da, 31n) == ${TRUE}}, +hca: {Nat.is_le(c, VB.pw(da)) == ${TRUE}},
    +e: Bool, +ee: {U32.is_eq(n, 0) == e : Bool})
    -> {T.${p}_pt_nz(e, S, n, FD.array__thaw(U32, D), FD.array__thaw(T.${R}, A)) == (FD.array__thaw(U32, LW_${p}(e, n, dd, D, Q, A)), T.${p}_Seq{FD.array__thaw(T.${R}, A), n}) : Array<U32> & T.${p}_Seq}:
  match e:
    case True{}: {==}
    case False{}:
      +h1 = VRL.cposu(n, c, ec, ee)
      +k = U32.to_nat(U32.sub(n, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.logic__subst(Nat, z => {U32.to_nat(U32.sub(n, 1)) == Nat.sub(z, 1n) : Nat}, U32.to_nat(n), c, ec,
        FD.u32__sub_nat(n, 1, FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == ${TRUE}}, c, U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), c, ec), h1)))), FD.nat__sub_add(c, 1n, h1))
      +hb = FD.logic__subst(Nat, z => {Nat.is_le(${POS('z')}, VB.pw(dd)) == ${TRUE}}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), hbd)
      +hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == ${TRUE}}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {Nat.is_lt(k, z) == ${TRUE}}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      %Equal.sym(Array<T.${R}> & T.${R}, Array.get(T.${R}, FD.array__thaw(T.${R}, A), 0), (FD.array__thaw(T.${R}, A), EL_${p}(A, 0n)),
          FD.array__get(T.${R}, da, A, 0, EL_${p}(A, 0n), VB.lt32(da, hda), h0, VRL.nth_get(T.${R}, FD.array__slots(T.${R}, A), 0n, T.${R}_default(), FD.array__len_lt(T.${R}, da, A, 0n, pfA, h0)), pfA)) :
        {T.${p}_pt_fin(n, T.${p}_pt(k, 0, S, FD.array__thaw(U32, D), _)) == (FD.array__thaw(U32, LW_${p}(False{}, n, dd, D, Q, A)), T.${p}_Seq{FD.array__thaw(T.${R}, A), n}) : Array<U32> & T.${p}_Seq}
      %Equal.sym(${RT}, T.${p}_pt(k, 0, S, FD.array__thaw(U32, D), (FD.array__thaw(T.${R}, A), EL_${p}(A, 0n))), (FD.array__thaw(U32, WT_${p}(k, 0n, dd, D, Q, A)), FD.array__thaw(T.${R}, A)),
          ptl_${p}(k, 0, 0n, S, Q, dd, D, da, A, {==}, eS, hdd, pfD, hb, pfA, hda, hk)) :
        {T.${p}_pt_fin(n, _) == (FD.array__thaw(U32, LW_${p}(False{}, n, dd, D, Q, A)), T.${p}_Seq{FD.array__thaw(T.${R}, A), n}) : Array<U32> & T.${p}_Seq}
      {==}

# The list writer at header word h (byte 4 h) and word position Q (byte S = 4 Q).
def pvl_${p}(+dd: Nat, +D: ${TR}, +h: Nat, +hB: U32, +S: U32, +Q: Nat, +eS: {U32.to_nat(S) == A.quad(Q) : Nat},
    +n: U32, +c: Nat, +ec: {U32.to_nat(n) == c : Nat}, +da: Nat, +A: ${TRR},
    +hdd: {Nat.is_lt(dd, 29n) == ${TRUE}}, +pfD: {FD.array__perfect(U32, dd, D) == ${TRUE}}, +hh: {Nat.is_lt(h, VB.pw(dd)) == ${TRUE}},
    +ehh: {U32.to_nat(U32.from_nat(h)) == h : Nat}, +hbd: {Nat.is_le(${POS('c')}, VB.pw(dd)) == ${TRUE}},
    +pfA: {FD.array__perfect(T.${R}, da, A) == ${TRUE}}, +hda: {Nat.is_lt(da, 31n) == ${TRUE}}, +hca: {Nat.is_le(c, VB.pw(da)) == ${TRUE}},
    +hlim: {Nat.is_le(c, U32.to_nat(${LIM})) == ${TRUE}}, +w32: {O.w32(FD.array__thaw(U32, D), U32.add(0, hB), S) == Array.set(U32, FD.array__thaw(U32, D), U32.from_nat(h), S) : Array<U32>},
    +pa: {U32.add(0, S) == S : U32})
    -> {T.${p}_putv(FD.array__thaw(U32, D), 0, hB, S, T.${p}_Seq{FD.array__thaw(T.${R}, A), n})
        == (FD.array__thaw(U32, LW_${p}(U32.is_eq(n, 0), n, dd, VF.updv([S], dd, D, h), Q, A)), (T.${p}_Seq{FD.array__thaw(T.${R}, A), n}, O.padd(S, U32.mul(n, ${RS})))) : Array<U32> & (T.${p}_Seq & U32)}:
  +D1 = VF.updv([S], dd, D, h)
  +RHS = (FD.array__thaw(U32, LW_${p}(U32.is_eq(n, 0), n, dd, D1, Q, A)), (T.${p}_Seq{FD.array__thaw(T.${R}, A), n}, O.padd(S, U32.mul(n, ${RS}))))
  +hn = VRL.u32le_n(n, ${LIM}, c, ec, hlim)
  +hc = VRL.u32le_n(n, FD.u32__pow2u(da), c, ec, FD.logic__subst(Nat, z => {Nat.is_le(c, z) == ${TRUE}}, VB.pw(da), U32.to_nat(FD.u32__pow2u(da)),
    Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(da)), VB.pw(da), FD.u32__pow2u_value(da, VB.lt32(da, hda))), hca))
  %Equal.sym(Array<U32>, O.w32(FD.array__thaw(U32, D), U32.add(0, hB), S), Array.set(U32, FD.array__thaw(U32, D), U32.from_nat(h), S), w32) : {T.${p}_pvb(S, T.${p}_putk(_, U32.add(0, S), T.${p}_Seq{FD.array__thaw(T.${R}, A), n})) == RHS : Array<U32> & (T.${p}_Seq & U32)}
  %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, D), U32.from_nat(h), S), FD.array__thaw(U32, FD.array__upd(U32, dd, D, h, S)),
      VB.set_n(dd, D, U32.from_nat(h), h, S, ehh, VB.lt32(dd, FD.nat__lt_trans(dd, 29n, 31n, hdd, {==})), hh, pfD)) :
    {T.${p}_pvb(S, T.${p}_putk(_, U32.add(0, S), T.${p}_Seq{FD.array__thaw(T.${R}, A), n})) == RHS : Array<U32> & (T.${p}_Seq & U32)}
  %Equal.sym(U32, U32.add(0, S), S, pa) : {T.${p}_pvb(S, T.${p}_putk(FD.array__thaw(U32, D1), _, T.${p}_Seq{FD.array__thaw(T.${R}, A), n})) == RHS : Array<U32> & (T.${p}_Seq & U32)}
  %Equal.sym(Array<T.${R}> & U32, Array.size(T.${R}, FD.array__thaw(T.${R}, A)), (FD.array__thaw(T.${R}, A), FD.u32__pow2u(da)), FD.array__size_thaw(T.${R}, da, A, pfA)) :
    {T.${p}_pvb(S, T.${p}_pk(FD.array__thaw(U32, D1), S, T.${p}_va_cap(Bool.or(False{}, U32.is_le(n, ${LIM})), n, _))) == RHS : Array<U32> & (T.${p}_Seq & U32)}
  %Equal.sym(Bool, U32.is_le(n, ${LIM}), True{}, hn) :
    {T.${p}_pvb(S, T.${p}_pk(FD.array__thaw(U32, D1), S, (T.${p}_Seq{FD.array__thaw(T.${R}, A), n}, Bool.and(Bool.or(False{}, _), U32.is_le(n, FD.u32__pow2u(da)))))) == RHS : Array<U32> & (T.${p}_Seq & U32)}
  %Equal.sym(Bool, U32.is_le(n, FD.u32__pow2u(da)), True{}, hc) :
    {T.${p}_pvb(S, T.${p}_pk(FD.array__thaw(U32, D1), S, (T.${p}_Seq{FD.array__thaw(T.${R}, A), n}, Bool.and(True{}, _)))) == RHS : Array<U32> & (T.${p}_Seq & U32)}
  %Equal.sym(Array<U32> & T.${p}_Seq, T.${p}_pt_nz(U32.is_eq(n, 0), S, n, FD.array__thaw(U32, D1), FD.array__thaw(T.${R}, A)), (FD.array__thaw(U32, LW_${p}(U32.is_eq(n, 0), n, dd, D1, Q, A)), T.${p}_Seq{FD.array__thaw(T.${R}, A), n}),
      ptnz_${p}(n, c, ec, S, Q, eS, dd, D1, da, A, hdd, VF.updv_perfect([S], dd, D, h, pfD), hbd, pfA, hda, hca, U32.is_eq(n, 0), {==})) :
    {T.${p}_pvb(S, T.${p}_ptn_fin(n, _)) == RHS : Array<U32> & (T.${p}_Seq & U32)}
  {==}

@@ _bg_offsets @@

# ---- sizes ------------------------------------------------------------------------------------

def M0(+n0: U32) -> Nat: Nat.mul(U32.to_nat(n0), ${W[0]}n)
def M1(+n1: U32) -> Nat: Nat.mul(U32.to_nat(n1), ${W[1]}n)
def M2(+n2: U32) -> Nat: Nat.mul(U32.to_nat(n2), ${W[2]}n)
def Q1(+n0: U32) -> Nat: Nat.add(3n, M0(n0))
def Q2(+n0: U32, +n1: U32) -> Nat: Nat.add(Q1(n0), M1(n1))
def QN(+n0: U32, +n1: U32, +n2: U32) -> Nat: Nat.add(Q2(n0, n1), M2(n2))
def MX0() -> Nat: Nat.mul(U32.to_nat(${LIM[0]}), ${W[0]}n)
def MX1() -> Nat: Nat.mul(U32.to_nat(${LIM[1]}), ${W[1]}n)
def MX2() -> Nat: Nat.mul(U32.to_nat(${LIM[2]}), ${W[2]}n)
def N0(+n0: U32) -> U32: U32.mul(n0, ${RS[0]})
def N1(+n1: U32) -> U32: U32.mul(n1, ${RS[1]})
def N2(+n2: U32) -> U32: U32.mul(n2, ${RS[2]})
def S1(+n0: U32) -> U32: U32.add(12, N0(n0))
def S2(+n0: U32, +n1: U32) -> U32: U32.add(S1(n0), N1(n1))
def S3(+n0: U32, +n1: U32, +n2: U32) -> U32: U32.add(S2(n0, n1), N2(n2))
def DO(+n0: U32, +n1: U32, +n2: U32) -> Nat: B.words_depth(VC.nwu(S3(n0, n1, n2)))

# the closed bounds (big), on words: ${QXT} is the word ${QXV}, 4 QX the word QW (no carry), and the powers of
# two words (VBG.u32pow); only the sum of the limits is evaluated in unary, once (esq: a few 10^5 steps)
def esq() -> {${QXS} == ${QXT} : Nat}: FD.nat__eq_from_is_eq(${QXS}, ${QXT}, {==})
def eqd(+w: U32, +h: {VA.CY(w, w) == False{} : Bool}) -> {Nat.double(U32.to_nat(w)) == U32.to_nat(U32.add(w, w)) : Nat}:
  Equal.sym(Nat, U32.to_nat(U32.add(w, w)), Nat.double(U32.to_nat(w)),
    Equal.trans(Nat, U32.to_nat(U32.add(w, w)), Nat.add(U32.to_nat(w), U32.to_nat(w)), Nat.double(U32.to_nat(w)), VA.add_nc(w, w, h), VBG.two_pw(U32.to_nat(w))))
def eQ4() -> {A.quad(${QXT}) == U32.to_nat(${QW}) : Nat}:
  Equal.trans(Nat, Nat.double(Nat.double(U32.to_nat(${QXV}))), Nat.double(U32.to_nat(U32.add(${QXV}, ${QXV}))), U32.to_nat(${QW}),
    Equal.cong(Nat, Nat, z => Nat.double(z), Nat.double(U32.to_nat(${QXV})), U32.to_nat(U32.add(${QXV}, ${QXV})), eqd(${QXV}, {==})), eqd(U32.add(${QXV}, ${QXV}), {==}))
def lew(+z: Nat, +a: U32, +b: U32, +e: {U32.to_nat(a) == z : Nat}, +h: {U32.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(z, U32.to_nat(b)) == True{} : Bool}:
  FD.logic__subst(Nat, y => {Nat.is_le(y, U32.to_nat(b)) == True{} : Bool}, U32.to_nat(a), z, e, VA.le_nat(a, b, h))
def cS() -> {Nat.is_le(A.quad(${QXT}), U32.to_nat(16777216)) == ${TRUE}}:
  lew(A.quad(${QXT}), ${QW}, 16777216, Equal.sym(Nat, A.quad(${QXT}), U32.to_nat(${QW}), eQ4()), {==})
def cQ() -> {Nat.is_le(Nat.add(31n, A.quad(${QXT})), VB.pw(24n)) == ${TRUE}}:
  +e = Equal.trans(Nat, U32.to_nat(U32.add(31, ${QW})), Nat.add(U32.to_nat(31), U32.to_nat(${QW})), Nat.add(31n, A.quad(${QXT})), VA.add_nc(31, ${QW}, {==}),
    Equal.trans(Nat, Nat.add(U32.to_nat(31), U32.to_nat(${QW})), Nat.add(31n, U32.to_nat(${QW})), Nat.add(31n, A.quad(${QXT})),
      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(${QW})), U32.to_nat(31), 31n, FD.nat__eq_from_is_eq(U32.to_nat(31), 31n, {==})),
      Equal.cong(Nat, Nat, z => Nat.add(31n, z), U32.to_nat(${QW}), A.quad(${QXT}), Equal.sym(Nat, A.quad(${QXT}), U32.to_nat(${QW}), eQ4()))))
  %VBG.u32pow(16777216, 24n, {==}, {==}) : {Nat.is_le(Nat.add(31n, A.quad(${QXT})), _) == ${TRUE}}
  lew(Nat.add(31n, A.quad(${QXT})), U32.add(31, ${QW}), 16777216, e, {==})
def cD() -> {Nat.is_le(${QXT}, O.pow2n(23n)) == ${TRUE}}:
  VBG.blep(${QXT}, 23n, FD.logic__subst(Nat, z => {Nat.is_le(${QXT}, z) == ${TRUE}}, U32.to_nat(8388608), VB.pw(23n), VBG.u32pow(8388608, 23n, {==}, {==}), VA.le_nat(${QXV}, 8388608, {==})))

def lQX(${NP}) -> {Nat.is_le(QN(n0, n1, n2), ${QXT}) == ${TRUE}}:
  +m0 = VRL.mul_mono(U32.to_nat(n0), U32.to_nat(${LIM[0]}), ${W[0]}n, hl0)
  +m1 = VRL.mul_mono(U32.to_nat(n1), U32.to_nat(${LIM[1]}), ${W[1]}n, hl1)
  +m2 = VRL.mul_mono(U32.to_nat(n2), U32.to_nat(${LIM[2]}), ${W[2]}n, hl2)
  +l1 = Order.add_left(3n, M0(n0), MX0(), m0)
  +l2 = FD.nat__le_trans(Q2(n0, n1), Nat.add(Nat.add(3n, MX0()), M1(n1)), Nat.add(Nat.add(3n, MX0()), MX1()),
    Order.add_right(Q1(n0), Nat.add(3n, MX0()), M1(n1), l1), Order.add_left(Nat.add(3n, MX0()), M1(n1), MX1(), m1))
  FD.logic__subst(Nat, z => {Nat.is_le(QN(n0, n1, n2), z) == ${TRUE}}, ${QXS}, ${QXT}, esq(),
    FD.nat__le_trans(QN(n0, n1, n2), Nat.add(Nat.add(Nat.add(3n, MX0()), MX1()), M2(n2)), ${QXS},
      Order.add_right(Q2(n0, n1), Nat.add(Nat.add(3n, MX0()), MX1()), M2(n2), l2), Order.add_left(Nat.add(Nat.add(3n, MX0()), MX1()), M2(n2), MX2(), m2)))
def lQ1N(+n0: U32, +n1: U32, +n2: U32) -> {Nat.is_le(Q1(n0), QN(n0, n1, n2)) == ${TRUE}}:
  FD.nat__le_trans(Q1(n0), Q2(n0, n1), QN(n0, n1, n2), Order.below_sum(Q1(n0), M1(n1)), Order.below_sum(Q2(n0, n1), M2(n2)))
def lM0N(+n0: U32, +n1: U32, +n2: U32) -> {Nat.is_le(M0(n0), QN(n0, n1, n2)) == ${TRUE}}:
  FD.nat__le_trans(M0(n0), Q1(n0), QN(n0, n1, n2), Order.left_below_sum(3n, M0(n0)), lQ1N(n0, n1, n2))
def lM1N(+n0: U32, +n1: U32, +n2: U32) -> {Nat.is_le(M1(n1), QN(n0, n1, n2)) == ${TRUE}}:
  FD.nat__le_trans(M1(n1), Q2(n0, n1), QN(n0, n1, n2), Order.left_below_sum(Q1(n0), M1(n1)), Order.below_sum(Q2(n0, n1), M2(n2)))
def lM2N(+n0: U32, +n1: U32, +n2: U32) -> {Nat.is_le(M2(n2), QN(n0, n1, n2)) == ${TRUE}}: Order.left_below_sum(Q2(n0, n1), M2(n2))

def qy(${NP}, +x: Nat, +h: {Nat.is_le(x, QN(n0, n1, n2)) == ${TRUE}})
    -> {Nat.is_le(Nat.add(31n, A.quad(x)), VB.pw(24n)) == ${TRUE}}:
  FD.nat__le_trans(Nat.add(31n, A.quad(x)), Nat.add(31n, A.quad(${QXT})), VB.pw(24n),
    Order.add_left(31n, A.quad(x), A.quad(${QXT}), VME.quad_mono(x, ${QXT}, FD.nat__le_trans(x, QN(n0, n1, n2), ${QXT}, h, lQX(${NA})))), cQ())
def qlt(${NP}, +x: Nat, +h: {Nat.is_le(x, QN(n0, n1, n2)) == ${TRUE}})
    -> {Nat.is_lt(A.quad(x), VB.pw(24n)) == ${TRUE}}:
  FD.nat__lt_le_trans(A.quad(x), Nat.add(31n, A.quad(x)), VB.pw(24n), FD.nat__lt_le_trans(A.quad(x), 1n+A.quad(x), Nat.add(31n, A.quad(x)), FD.nat__lt_succ(A.quad(x)), Order.add_right(1n, 31n, A.quad(x), {==})), qy(${NA}, x, h))
def qle(${NP}, +x: Nat, +h: {Nat.is_le(x, QN(n0, n1, n2)) == ${TRUE}})
    -> {Nat.is_le(A.quad(x), U32.to_nat(16777216)) == ${TRUE}}:
  FD.nat__le_trans(A.quad(x), A.quad(${QXT}), U32.to_nat(16777216), VME.quad_mono(x, ${QXT}, FD.nat__le_trans(x, QN(n0, n1, n2), ${QXT}, h, lQX(${NA}))), cS())

@@ _bg_offsets_2 @@
def eN${k}(${NP}) -> {{U32.to_nat(N${k}(n${k})) == A.quad(M${k}(n${k})) : Nat}}:
  Equal.trans(Nat, U32.to_nat(N${k}(n${k})), Nat.mul(U32.to_nat(n${k}), U32.to_nat(${RS[k]})), A.quad(M${k}(n${k})),
    VU.mul_le(n${k}, ${RS[k]}, 16777216, FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(16777216)) == ${TRUE}}}, A.quad(M${k}(n${k})), Nat.mul(U32.to_nat(n${k}), U32.to_nat(${RS[k]})),
      Equal.sym(Nat, Nat.mul(U32.to_nat(n${k}), A.quad(${W[k]}n)), A.quad(M${k}(n${k})), VRL.mul_quad(U32.to_nat(n${k}), ${W[k]}n)), qle(${NA}, M${k}(n${k}), lM${k}N(n0, n1, n2)))),
    VRL.mul_quad(U32.to_nat(n${k}), ${W[k]}n))

@@ _bg_offsets_3 @@
def eN${k}(${NP}) -> {U32.to_nat(N${k}(n${k})) == A.quad(M${k}(n${k})) : Nat}:
  Equal.trans(Nat, U32.to_nat(N${k}(n${k})), Nat.mul(U32.to_nat(n${k}), U32.to_nat(${RS[k]})), A.quad(M${k}(n${k})),
    VU.mul_le(n${k}, ${RS[k]}, 16777216, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(16777216)) == ${TRUE}}, A.quad(M${k}(n${k})), Nat.mul(U32.to_nat(n${k}), U32.to_nat(${RS[k]})),
      Equal.sym(Nat, Nat.mul(U32.to_nat(n${k}), A.quad(${W[k]}n)), A.quad(M${k}(n${k})), VRL.mul_quad(U32.to_nat(n${k}), ${W[k]}n)), qle(${NA}, M${k}(n${k}), lM${k}N(n0, n1, n2)))),
    VRL.mul_quad(U32.to_nat(n${k}), ${W[k]}n))

@@ _bg_models @@

def eS1(${NP}) -> {U32.to_nat(S1(n0)) == A.quad(Q1(n0)) : Nat}:
  +h = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(12), z), U32.to_nat(16777216)) == ${TRUE}}, A.quad(M0(n0)), U32.to_nat(N0(n0)), Equal.sym(Nat, U32.to_nat(N0(n0)), A.quad(M0(n0)), eN0(${NA})),
    qle(${NA}, Q1(n0), lQ1N(n0, n1, n2)))
  Equal.trans(Nat, U32.to_nat(S1(n0)), Nat.add(U32.to_nat(12), U32.to_nat(N0(n0))), A.quad(Q1(n0)), A.add_le(12, N0(n0), 16777216, h),
    Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(12), z), U32.to_nat(N0(n0)), A.quad(M0(n0)), eN0(${NA})))

def eS2(${NP}) -> {U32.to_nat(S2(n0, n1)) == A.quad(Q2(n0, n1)) : Nat}:
  +q = Equal.trans(Nat, Nat.add(U32.to_nat(S1(n0)), U32.to_nat(N1(n1))), Nat.add(A.quad(Q1(n0)), A.quad(M1(n1))), A.quad(Q2(n0, n1)),
    Equal.trans(Nat, Nat.add(U32.to_nat(S1(n0)), U32.to_nat(N1(n1))), Nat.add(A.quad(Q1(n0)), U32.to_nat(N1(n1))), Nat.add(A.quad(Q1(n0)), A.quad(M1(n1))),
      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(N1(n1))), U32.to_nat(S1(n0)), A.quad(Q1(n0)), eS1(${NA})),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(Q1(n0)), z), U32.to_nat(N1(n1)), A.quad(M1(n1)), eN1(${NA}))),
    Equal.sym(Nat, A.quad(Q2(n0, n1)), Nat.add(A.quad(Q1(n0)), A.quad(M1(n1))), VM.quad_add(Q1(n0), M1(n1))))
  +h = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(16777216)) == ${TRUE}}, A.quad(Q2(n0, n1)), Nat.add(U32.to_nat(S1(n0)), U32.to_nat(N1(n1))),
    Equal.sym(Nat, Nat.add(U32.to_nat(S1(n0)), U32.to_nat(N1(n1))), A.quad(Q2(n0, n1)), q), qle(${NA}, Q2(n0, n1), Order.below_sum(Q2(n0, n1), M2(n2))))
  Equal.trans(Nat, U32.to_nat(S2(n0, n1)), Nat.add(U32.to_nat(S1(n0)), U32.to_nat(N1(n1))), A.quad(Q2(n0, n1)), A.add_le(S1(n0), N1(n1), 16777216, h), q)

def eS3(${NP}) -> {U32.to_nat(S3(n0, n1, n2)) == A.quad(QN(n0, n1, n2)) : Nat}:
  +q = Equal.trans(Nat, Nat.add(U32.to_nat(S2(n0, n1)), U32.to_nat(N2(n2))), Nat.add(A.quad(Q2(n0, n1)), A.quad(M2(n2))), A.quad(QN(n0, n1, n2)),
    Equal.trans(Nat, Nat.add(U32.to_nat(S2(n0, n1)), U32.to_nat(N2(n2))), Nat.add(A.quad(Q2(n0, n1)), U32.to_nat(N2(n2))), Nat.add(A.quad(Q2(n0, n1)), A.quad(M2(n2))),
      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(N2(n2))), U32.to_nat(S2(n0, n1)), A.quad(Q2(n0, n1)), eS2(${NA})),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(Q2(n0, n1)), z), U32.to_nat(N2(n2)), A.quad(M2(n2)), eN2(${NA}))),
    Equal.sym(Nat, A.quad(QN(n0, n1, n2)), Nat.add(A.quad(Q2(n0, n1)), A.quad(M2(n2))), VM.quad_add(Q2(n0, n1), M2(n2))))
  +h = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(16777216)) == ${TRUE}}, A.quad(QN(n0, n1, n2)), Nat.add(U32.to_nat(S2(n0, n1)), U32.to_nat(N2(n2))),
    Equal.sym(Nat, Nat.add(U32.to_nat(S2(n0, n1)), U32.to_nat(N2(n2))), A.quad(QN(n0, n1, n2)), q), qle(${NA}, QN(n0, n1, n2), Order.reflexive(QN(n0, n1, n2))))
  Equal.trans(Nat, U32.to_nat(S3(n0, n1, n2)), Nat.add(U32.to_nat(S2(n0, n1)), U32.to_nat(N2(n2))), A.quad(QN(n0, n1, n2)), A.add_le(S2(n0, n1), N2(n2), 16777216, h), q)

def eNWS(${NP}) -> {VC.NW(S3(n0, n1, n2)) == QN(n0, n1, n2) : Nat}:
  %Equal.sym(Nat, VC.NW(S3(n0, n1, n2)), VD.s_rng(2n, 3n+U32.to_nat(S3(n0, n1, n2))), VC.eNW(S3(n0, n1, n2), 24n, {==},
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, z), VB.pw(24n)) == ${TRUE}}, A.quad(QN(n0, n1, n2)), U32.to_nat(S3(n0, n1, n2)), Equal.sym(Nat, U32.to_nat(S3(n0, n1, n2)), A.quad(QN(n0, n1, n2)), eS3(${NA})),
        qy(${NA}, QN(n0, n1, n2), Order.reflexive(QN(n0, n1, n2)))))) :
    {_ == QN(n0, n1, n2) : Nat}
  %Equal.sym(Nat, U32.to_nat(S3(n0, n1, n2)), A.quad(QN(n0, n1, n2)), eS3(${NA})) : {VD.s_rng(2n, 3n+_) == QN(n0, n1, n2) : Nat}
  VL.rng2_q(QN(n0, n1, n2))

def hDO(${NP}) -> {Nat.is_le(${DOe}, 23n) == ${TRUE}}:
  VD.wd_min(VC.nwu(S3(n0, n1, n2)), 23n,
    FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(23n)) == ${TRUE}}, QN(n0, n1, n2), VC.NW(S3(n0, n1, n2)), Equal.sym(Nat, VC.NW(S3(n0, n1, n2)), QN(n0, n1, n2), eNWS(${NA})),
      FD.nat__le_trans(QN(n0, n1, n2), ${QXT}, O.pow2n(23n), lQX(${NA}), cD())))
def hDO29(${NP}) -> {Nat.is_lt(${DOe}, 29n) == ${TRUE}}: FD.nat__le_lt_trans(${DOe}, 23n, 29n, hDO(${NA}), {==})
def hDO32(${NP}) -> {Nat.is_lt(${DOe}, 32n) == ${TRUE}}: FD.nat__le_lt_trans(${DOe}, 23n, 32n, hDO(${NA}), {==})
def roomS(${NP}) -> {Nat.is_le(QN(n0, n1, n2), VB.pw(${DOe})) == ${TRUE}}:
  %Equal.sym(Nat, VB.pw(${DOe}), O.pow2n(${DOe}), VD.s_pow2_eq(${DOe})) : {Nat.is_le(QN(n0, n1, n2), _) == ${TRUE}}
  %eNWS(${NA}) : {Nat.is_le(_, O.pow2n(${DOe})) == ${TRUE}}
  VD.wd_cover(VC.nwu(S3(n0, n1, n2)), 23n, {==},
    FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(23n)) == ${TRUE}}, QN(n0, n1, n2), VC.NW(S3(n0, n1, n2)), Equal.sym(Nat, VC.NW(S3(n0, n1, n2)), QN(n0, n1, n2), eNWS(${NA})),
      FD.nat__le_trans(QN(n0, n1, n2), ${QXT}, O.pow2n(23n), lQX(${NA}), cD())))
def lQ1P(${NP}) -> {Nat.is_le(Q1(n0), VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(Q1(n0), QN(n0, n1, n2), VB.pw(${DOe}), lQ1N(n0, n1, n2), roomS(${NA}))
def lQ2P(${NP}) -> {Nat.is_le(Q2(n0, n1), VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(Q2(n0, n1), QN(n0, n1, n2), VB.pw(${DOe}), Order.below_sum(Q2(n0, n1), M2(n2)), roomS(${NA}))
def l3P(${NP}) -> {Nat.is_le(3n, VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(3n, Q1(n0), VB.pw(${DOe}), Order.below_sum(3n, M0(n0)), lQ1P(${NA}))
def ltP(${NP}, +k: Nat, +hk: {Nat.is_lt(k, 3n) == ${TRUE}}) -> {Nat.is_lt(k, VB.pw(${DOe})) == ${TRUE}}: FD.nat__lt_le_trans(k, 3n, VB.pw(${DOe}), hk, l3P(${NA}))

# each list's runs end within the output
def hbd0(${NP}) -> {Nat.is_le(VRL.pos(U32.to_nat(n0), ${W[0]}n, 3n), VB.pw(${DOe})) == ${TRUE}}:
  %FD.nat__add_comm(3n, M0(n0)) : {Nat.is_le(_, VB.pw(${DOe})) == ${TRUE}}
  lQ1P(${NA})
def hbd1(${NP}) -> {Nat.is_le(VRL.pos(U32.to_nat(n1), ${W[1]}n, Q1(n0)), VB.pw(${DOe})) == ${TRUE}}:
  %FD.nat__add_comm(Q1(n0), M1(n1)) : {Nat.is_le(_, VB.pw(${DOe})) == ${TRUE}}
  lQ2P(${NA})
def hbd2(${NP}) -> {Nat.is_le(VRL.pos(U32.to_nat(n2), ${W[2]}n, Q2(n0, n1)), VB.pw(${DOe})) == ${TRUE}}:
  %FD.nat__add_comm(Q2(n0, n1), M2(n2)) : {Nat.is_le(_, VB.pw(${DOe})) == ${TRUE}}
  roomS(${NA})

# no top bit
def ltN(${NP}, +L: U32, +m: Nat, +em: {U32.to_nat(L) == A.quad(m) : Nat}, +hm: {Nat.is_le(m, QN(n0, n1, n2)) == ${TRUE}})
    -> {L == U32{Word.shr.pad(31n, VE.winit(31n, VE.bits32(L)))} : U32}:
  VE.small_pad(L, 24n, {==}, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(24n)) == ${TRUE}}, A.quad(m), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(m), em), qlt(${NA}, m, hm)))
def pd1(${NP}) -> {O.padd(12, N0(n0)) == S1(n0) : U32}:
  VE.padd_ok(12, N0(n0), VE.winit(31n, VE.bits32(12)), VE.winit(31n, VE.bits32(N0(n0))), {==}, ltN(${NA}, N0(n0), M0(n0), eN0(${NA}), lM0N(n0, n1, n2)))
def pd2(${NP}) -> {O.padd(S1(n0), N1(n1)) == S2(n0, n1) : U32}:
  VE.padd_ok(S1(n0), N1(n1), VE.winit(31n, VE.bits32(S1(n0))), VE.winit(31n, VE.bits32(N1(n1))), ltN(${NA}, S1(n0), Q1(n0), eS1(${NA}), lQ1N(n0, n1, n2)), ltN(${NA}, N1(n1), M1(n1), eN1(${NA}), lM1N(n0, n1, n2)))
def pd3(${NP}) -> {O.padd(S2(n0, n1), N2(n2)) == S3(n0, n1, n2) : U32}:
  VE.padd_ok(S2(n0, n1), N2(n2), VE.winit(31n, VE.bits32(S2(n0, n1))), VE.winit(31n, VE.bits32(N2(n2))), ltN(${NA}, S2(n0, n1), Q2(n0, n1), eS2(${NA}), Order.below_sum(Q2(n0, n1), M2(n2))), ltN(${NA}, N2(n2), M2(n2), eN2(${NA}), lM2N(n0, n1, n2)))

# ---- the output trees ---------------------------------------------------------------------------

def ZD(${DP}) -> ${TR}: VC.ZT(${DOe})
def D1(${DP}) -> ${TR}: VF.updv([12], ${DOe}, ZD(${DA}), 0n)
def D2(${DP}) -> ${TR}: EN.LW_${p[0]}(U32.is_eq(n0, 0), n0, ${DOe}, D1(${DA}), 3n, A0)
def D3(${DP}) -> ${TR}: VF.updv([S1(n0)], ${DOe}, D2(${DA}), 1n)
def D4(${DP}) -> ${TR}: EN.LW_${p[1]}(U32.is_eq(n1, 0), n1, ${DOe}, D3(${DA}), Q1(n0), A1)
def D5(${DP}) -> ${TR}: VF.updv([S2(n0, n1)], ${DOe}, D4(${DA}), 2n)
def D6(${DP}) -> ${TR}: EN.LW_${p[2]}(U32.is_eq(n2, 0), n2, ${DOe}, D5(${DA}), Q2(n0, n1), A2)

@@ _bg_models_2 @@

def pvs0(${ALLP})
    -> {T.${p[0]}_putv(${TH('ZD')}, 0, 0, 12, ${SEQ(0)}) == (${TH('D2')}, (${SEQ(0)}, S1(n0))) : Array<U32> & (T.${p[0]}_Seq & U32)}:
  %pd1(${NA}) :
    {T.${p[0]}_putv(${TH('ZD')}, 0, 0, 12, ${SEQ(0)}) == (${TH('D2')}, (${SEQ(0)}, _)) : Array<U32> & (T.${p[0]}_Seq & U32)}
  EN.pvl_${p[0]}(${DOe}, ZD(${DA}), 0n, 0, 12, 3n, {==}, n0, U32.to_nat(n0), {==}, da0, A0, ${HD29}, FD.array__trep_perfect(U32, ${DOe}, 0), ltP(${NA}, 0n, {==}), {==},
    hbd0(${NA}), pfa0, hda0, hca0, hl0, {==}, {==})

@@ _bg_perfect_and_size @@

def pvs1(${ALLP})
    -> {T.${p[1]}_putv(${TH('D2')}, 0, 4, S1(n0), ${SEQ(1)}) == (${TH('D4')}, (${SEQ(1)}, S2(n0, n1))) : Array<U32> & (T.${p[1]}_Seq & U32)}:
  %pd2(${NA}) :
    {T.${p[1]}_putv(${TH('D2')}, 0, 4, S1(n0), ${SEQ(1)}) == (${TH('D4')}, (${SEQ(1)}, _)) : Array<U32> & (T.${p[1]}_Seq & U32)}
  EN.pvl_${p[1]}(${DOe}, D2(${DA}), 1n, 4, S1(n0), Q1(n0), eS1(${NA}), n1, U32.to_nat(n1), {==}, da1, A1, ${HD29}, pfD2(${ALLA}), ltP(${NA}, 1n, {==}), {==},
    hbd1(${NA}), pfa1, hda1, hca1, hl1, {==}, FD.u32alg__zero_add(S1(n0)))

def pvs2(${ALLP})
    -> {T.${p[2]}_putv(${TH('D4')}, 0, 8, S2(n0, n1), ${SEQ(2)}) == (${TH('D6')}, (${SEQ(2)}, S3(n0, n1, n2))) : Array<U32> & (T.${p[2]}_Seq & U32)}:
  %pd3(${NA}) :
    {T.${p[2]}_putv(${TH('D4')}, 0, 8, S2(n0, n1), ${SEQ(2)}) == (${TH('D6')}, (${SEQ(2)}, _)) : Array<U32> & (T.${p[2]}_Seq & U32)}
  EN.pvl_${p[2]}(${DOe}, D4(${DA}), 2n, 8, S2(n0, n1), Q2(n0, n1), eS2(${NA}), n2, U32.to_nat(n2), {==}, da2, A2, ${HD29}, pfD4(${ALLA}), ltP(${NA}, 2n, {==}), {==},
    hbd2(${NA}), pfa2, hda2, hca2, hl2, {==}, FD.u32alg__zero_add(S2(n0, n1)))

def put_eval(${ALLP})
    -> {T.${X}_putn(${TH('ZD')}, 0, ${OE}) == (${TH('D6')}, (${OE}, S3(n0, n1, n2))) : ${RT}}:
  +RHS = (${TH('D6')}, (${OE}, S3(n0, n1, n2)))
  %Equal.sym(Array<U32> & (T.${p[0]}_Seq & U32), T.${p[0]}_putv(${TH('ZD')}, 0, 0, 12, ${SEQ(0)}), (${TH('D2')}, (${SEQ(0)}, S1(n0))), pvs0(${ALLA})) :
    {T.${X}_pw0(0, ${SEQ(1)}, ${SEQ(2)}, _) == RHS : ${RT}}
  %Equal.sym(Array<U32> & (T.${p[1]}_Seq & U32), T.${p[1]}_putv(${TH('D2')}, 0, 4, S1(n0), ${SEQ(1)}), (${TH('D4')}, (${SEQ(1)}, S2(n0, n1))), pvs1(${ALLA})) :
    {T.${X}_pw1(0, ${SEQ(0)}, ${SEQ(2)}, _) == RHS : ${RT}}
  %Equal.sym(Array<U32> & (T.${p[2]}_Seq & U32), T.${p[2]}_putv(${TH('D4')}, 0, 8, S2(n0, n1), ${SEQ(2)}), (${TH('D6')}, (${SEQ(2)}, S3(n0, n1, n2))), pvs2(${ALLA})) :
    {T.${X}_pw2(0, ${SEQ(0)}, ${SEQ(1)}, _) == RHS : ${RT}}
  {==}

@@ _bg_perfect_and_size_2 @@

def size_eval(${ALLP})
    -> {T.${X}_size(${OE}) == (${OE}, S3(n0, n1, n2)) : ${SZ}}:
  +RHS = (${OE}, S3(n0, n1, n2))
  %Equal.sym(Array<T.${R[0]}> & U32, Array.size(T.${R[0]}, FD.array__thaw(T.${R[0]}, A0)), (FD.array__thaw(T.${R[0]}, A0), FD.u32__pow2u(da0)), FD.array__size_thaw(T.${R[0]}, da0, A0, pfa0)) :
    {T.${X}_sz0(${SEQ(1)}, ${SEQ(2)}, 12, T.${p[0]}_szf(n0, _)) == RHS : ${SZ}}
  %Equal.sym(Bool, U32.is_le(n0, FD.u32__pow2u(da0)), True{}, ${CAPS[0]}) :
    {T.${X}_sz0(${SEQ(1)}, ${SEQ(2)}, 12, (${SEQ(0)}, O.pick(_, U32.mul(n0, ${RS[0]}), 2147483648))) == RHS : ${SZ}}
  %Equal.sym(U32, O.padd(12, N0(n0)), S1(n0), pd1(${NA})) :
    {T.${X}_sz1(${SEQ(2)}, ${SEQ(0)}, _, T.${p[1]}_size(${SEQ(1)})) == RHS : ${SZ}}
  %Equal.sym(Array<T.${R[1]}> & U32, Array.size(T.${R[1]}, FD.array__thaw(T.${R[1]}, A1)), (FD.array__thaw(T.${R[1]}, A1), FD.u32__pow2u(da1)), FD.array__size_thaw(T.${R[1]}, da1, A1, pfa1)) :
    {T.${X}_sz1(${SEQ(2)}, ${SEQ(0)}, S1(n0), T.${p[1]}_szf(n1, _)) == RHS : ${SZ}}
  %Equal.sym(Bool, U32.is_le(n1, FD.u32__pow2u(da1)), True{}, ${CAPS[1]}) :
    {T.${X}_sz1(${SEQ(2)}, ${SEQ(0)}, S1(n0), (${SEQ(1)}, O.pick(_, U32.mul(n1, ${RS[1]}), 2147483648))) == RHS : ${SZ}}
  %Equal.sym(U32, O.padd(S1(n0), N1(n1)), S2(n0, n1), pd2(${NA})) :
    {T.${X}_sz2(${SEQ(0)}, ${SEQ(1)}, _, T.${p[2]}_size(${SEQ(2)})) == RHS : ${SZ}}
  %Equal.sym(Array<T.${R[2]}> & U32, Array.size(T.${R[2]}, FD.array__thaw(T.${R[2]}, A2)), (FD.array__thaw(T.${R[2]}, A2), FD.u32__pow2u(da2)), FD.array__size_thaw(T.${R[2]}, da2, A2, pfa2)) :
    {T.${X}_sz2(${SEQ(0)}, ${SEQ(1)}, S2(n0, n1), T.${p[2]}_szf(n2, _)) == RHS : ${SZ}}
  %Equal.sym(Bool, U32.is_le(n2, FD.u32__pow2u(da2)), True{}, ${CAPS[2]}) :
    {T.${X}_sz2(${SEQ(0)}, ${SEQ(1)}, S2(n0, n1), (${SEQ(2)}, O.pick(_, U32.mul(n2, ${RS[2]}), 2147483648))) == RHS : ${SZ}}
  %Equal.sym(U32, O.padd(S2(n0, n1), N2(n2)), S3(n0, n1, n2), pd3(${NA})) :
    {(${OE}, _) == RHS : ${SZ}}
  {==}

# The encoder returns the object and the buffer of D6, S3 bytes.
def encode_eval(${ALLP})
    -> {T.${X}_encode(${OE}) == (${OE}, B.Buf{${TH('D6')}, S3(n0, n1, n2)}) : T.${X} & B.Buf}:
  +RHS = (${OE}, B.Buf{${TH('D6')}, S3(n0, n1, n2)})
  %Equal.sym(${SZ}, T.${X}_size(${OE}), (${OE}, S3(n0, n1, n2)), size_eval(${ALLA})) :
    {T.${X}_enc_sized(_) == RHS : T.${X} & B.Buf}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu(S3(n0, n1, n2)))), Array.new(U32, ${DOe}, 0), VZ.zat(B.words_depth_u(VC.nwu(S3(n0, n1, n2))), ${DOe}, VD.wdu(VC.nwu(S3(n0, n1, n2))), hDO(${NA}))) :
    {T.${X}_enc_put(S3(n0, n1, n2), T.${X}_putn(_, 0, ${OE})) == RHS : T.${X} & B.Buf}
  %Equal.sym(Array<U32>, Array.new(U32, ${DOe}, 0), FD.array__thaw(U32, VC.ZT(${DOe})), FD.array__new(U32, ${DOe}, 0)) :
    {T.${X}_enc_put(S3(n0, n1, n2), T.${X}_putn(_, 0, ${OE})) == RHS : T.${X} & B.Buf}
  %Equal.sym(${RT}, T.${X}_putn(${TH('ZD')}, 0, ${OE}), (${TH('D6')}, (${OE}, S3(n0, n1, n2))), put_eval(${ALLA})) :
    {T.${X}_enc_put(S3(n0, n1, n2), _) == RHS : T.${X} & B.Buf}
  {==}

@@ lw_text @@
      +h1 = VRL.cposu(n, c, ec, ee)
      +k = U32.to_nat(U32.sub(n, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.logic__subst(Nat, z => {U32.to_nat(U32.sub(n, 1)) == Nat.sub(z, 1n) : Nat}, U32.to_nat(n), c, ec,
        FD.u32__sub_nat(n, 1, FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == ${TRUE}}, c, U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), c, ec), h1)))), FD.nat__sub_add(c, 1n, h1))
      +e0 = Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k)))
      +hb = FD.logic__subst(Nat, z => {Nat.is_le(${POS('z')}, VB.pw(dd)) == ${TRUE}}, c, Nat.add(1n+k, 0n), e0, hbd)

@@ spec_big_text @@

# ---- the spec side ------------------------------------------------------------------------------

def XE(${ALLP}) -> S.Value: ${XE}
def ENC(${ALLP}) -> +List<U32>: ${ENC}

@@ spec_big_text_2 @@
def lenY${k}(${NP}, +A${k}: FD.array__Tree<T.${R[k]}>) -> {List.length(&2, U32, ${Y[k]}) == A.quad(${M[k]}) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, ${Y[k]}), F.wlen(${RWA[k]}), VS.len_limbs(${RWA[k]})) : {_ == A.quad(${M[k]}) : Nat}
  %Equal.sym(Nat, F.wlen(${RWA[k]}), A.quad(List.length(&2, U32, ${RWA[k]})), VS.wlen_quad(${RWA[k]})) : {_ == A.quad(${M[k]}) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, ${RWA[k]}), FD.spec_common__length(U32, ${RWA[k]}), VMR.len_eq(${RWA[k]})) : {A.quad(_) == A.quad(${M[k]}) : Nat}
  %Equal.sym(Nat, VF.slen(${RWA[k]}), Nat.mul(${C[k]}, ${W[k]}n), EN.lenW_${p[k]}(${C[k]}, A${k}, 0n)) : {A.quad(_) == A.quad(${M[k]}) : Nat}
  {==}
def fitY${k}(${NP}, +A${k}: FD.array__Tree<T.${R[k]}>) -> {N.fits(4n, List.length(&2, U32, ${Y[k]})) == ${TRUE}}:
  %Equal.sym(Nat, List.length(&2, U32, ${Y[k]}), A.quad(${M[k]}), lenY${k}(${NA}, A${k})) : {N.fits(4n, _) == ${TRUE}}
  VFT.fits4(24n, A.quad(${M[k]}), FD.nat__le_trans(A.quad(${M[k]}), Nat.add(31n, A.quad(${M[k]})), VB.pw(24n), Order.left_below_sum(31n, A.quad(${M[k]})), qy(${NA}, ${M[k]}, lM${k}N(n0, n1, n2))), {==})

@@ spec_big_text_3 @@

def ce1(${ALLP}) -> {U32.to_nat(${S1}) == Nat.add(12n, List.length(&2, U32, ${Y[0]})) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, ${Y[0]}), A.quad(${M[0]}), lenY0(${NA}, A0)) : {U32.to_nat(${S1}) == Nat.add(12n, _) : Nat}
  eS1(${NA})
def ce2(${ALLP}) -> {U32.to_nat(${S2}) == Nat.add(Nat.add(12n, List.length(&2, U32, ${Y[0]})), List.length(&2, U32, ${Y[1]})) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, ${Y[0]}), A.quad(${M[0]}), lenY0(${NA}, A0)) : {U32.to_nat(${S2}) == Nat.add(Nat.add(12n, _), List.length(&2, U32, ${Y[1]})) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, ${Y[1]}), A.quad(${M[1]}), lenY1(${NA}, A1)) : {U32.to_nat(${S2}) == Nat.add(Nat.add(12n, A.quad(${M[0]})), _) : Nat}
  Equal.trans(Nat, U32.to_nat(${S2}), A.quad(Q2(n0, n1)), Nat.add(A.quad(Q1(n0)), A.quad(${M[1]})), eS2(${NA}), VM.quad_add(Q1(n0), ${M[1]}))
def cfit(${ALLP}) -> {N.fits(4n, Nat.add(U32.to_nat(${S2}), List.length(&2, U32, ${Y[2]}))) == ${TRUE}}:
  %Equal.sym(Nat, List.length(&2, U32, ${Y[2]}), A.quad(${M[2]}), lenY2(${NA}, A2)) : {N.fits(4n, Nat.add(U32.to_nat(${S2}), _)) == ${TRUE}}
  %Equal.sym(Nat, U32.to_nat(${S2}), A.quad(Q2(n0, n1)), eS2(${NA})) : {N.fits(4n, Nat.add(_, A.quad(${M[2]}))) == ${TRUE}}
  %VM.quad_add(Q2(n0, n1), ${M[2]}) : {N.fits(4n, _) == ${TRUE}}
  VFT.fits4(24n, A.quad(QN(n0, n1, n2)), FD.nat__le_trans(A.quad(QN(n0, n1, n2)), Nat.add(31n, A.quad(QN(n0, n1, n2))), VB.pw(24n), Order.left_below_sum(31n, A.quad(QN(n0, n1, n2))), qy(${NA}, QN(n0, n1, n2), Order.reflexive(QN(n0, n1, n2)))), {==})

def encE(${ALLP}) -> {Codec.encoding_for_legal_type(Spec.${X}(), XE(${ALLA})) == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(${items(0)}, ${chain(0)}), Some{[${', '.join(PARTS)}]}, ${cat(0)}) :
    {Codec.bytes(Codec.aggregate(_, None{})) == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(VRC.PV3(${Y[0]}, ${Y[1]}, ${Y[2]})), Some{ENC(${ALLA})},
      VRC.enc3v(${Y[0]}, ${Y[1]}, ${Y[2]}, 12, ${S1}, ${S2}, F.domain_limbs(${RWA[0]}), F.domain_limbs(${RWA[1]}), F.domain_limbs(${RWA[2]}), {==}, ce1(${ALLA}), ce2(${ALLA}), cfit(${ALLA}))) :
    {Codec.bytes(Codec.one(_, None{})) == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}
  {==}

@@ spec_big_text_4 @@

def pfZD(${ALLP}) -> {FD.array__perfect(U32, ${DOe}, ZD(${DA})) == ${TRUE}}: FD.array__trep_perfect(U32, ${DOe}, 0)
def pfD1(${ALLP}) -> {FD.array__perfect(U32, ${DOe}, D1(${DA})) == ${TRUE}}: VF.updv_perfect([12], ${DOe}, ZD(${DA}), 0n, pfZD(${ALLA}))
def lkQ1(+n0: U32, +k: Nat, +hk: {Nat.is_le(k, 3n) == ${TRUE}}) -> {Nat.is_le(k, Q1(n0)) == ${TRUE}}: FD.nat__le_trans(k, 3n, Q1(n0), hk, Order.below_sum(3n, M0(n0)))
def lkQ2(+n0: U32, +n1: U32, +k: Nat, +hk: {Nat.is_le(k, 3n) == ${TRUE}}) -> {Nat.is_le(k, Q2(n0, n1)) == ${TRUE}}: FD.nat__le_trans(k, Q1(n0), Q2(n0, n1), lkQ1(n0, k, hk), Order.below_sum(Q1(n0), M1(n1)))
def lkP(${NP}, +k: Nat, +hk: {Nat.is_le(k, 3n) == ${TRUE}}) -> {Nat.is_le(k, VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(k, 3n, VB.pw(${DOe}), hk, l3P(${NA}))
def lW0(${NP}) -> {Nat.is_le(Nat.add(M0(n0), 3n), Q1(n0)) == ${TRUE}}:
  %FD.nat__add_comm(3n, M0(n0)) : {Nat.is_le(_, Q1(n0)) == ${TRUE}}
  Order.reflexive(Q1(n0))
def lW1(${NP}) -> {Nat.is_le(Nat.add(M1(n1), Q1(n0)), Q2(n0, n1)) == ${TRUE}}:
  %FD.nat__add_comm(Q1(n0), M1(n1)) : {Nat.is_le(_, Q2(n0, n1)) == ${TRUE}}
  Order.reflexive(Q2(n0, n1))
def lW0Q2(${NP}) -> {Nat.is_le(Nat.add(M0(n0), 3n), Q2(n0, n1)) == ${TRUE}}: FD.nat__le_trans(Nat.add(M0(n0), 3n), Q1(n0), Q2(n0, n1), lW0(${NA}), Order.below_sum(Q1(n0), M1(n1)))

@@ spec_big_text_5 @@

def hdr3(${ALLP}) -> {VF.WIN(3n, 0n, ${SD}) == ${HW} : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, VF.WIN(Nat.add(1n, 2n), 0n, ${SD}), VF.app(VF.WIN(1n, 0n, ${SD}), VF.WIN(2n, Nat.add(0n, 1n), ${SD})), VF.win_split(1n, 2n, 0n, ${SD})) : {_ == ${HW} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(Nat.add(1n, 1n), 1n, ${SD}), VF.app(VF.WIN(1n, 1n, ${SD}), VF.WIN(1n, Nat.add(1n, 1n), ${SD})), VF.win_split(1n, 1n, 1n, ${SD})) : {VF.app(VF.WIN(1n, 0n, ${SD}), _) == ${HW} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(1n, 0n, ${SD}), [12], s0(${ALLA})) : {VF.app(_, VF.app(VF.WIN(1n, 1n, ${SD}), VF.WIN(1n, 2n, ${SD}))) == ${HW} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(1n, 1n, ${SD}), [${S1}], s1(${ALLA})) : {VF.app([12], VF.app(_, VF.WIN(1n, 2n, ${SD}))) == ${HW} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(1n, 2n, ${SD}), [${S2}], s2(${ALLA})) : {VF.app([12], VF.app([${S1}], _)) == ${HW} : List<&2, U32>}
  {==}

# The output's bytes are the encoding.
def out_eq(${ALLP}) -> {${Ew} == VS.bt(U32.to_nat(${S3}), F.limbs(${SD})) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(${S3}), A.quad(QN(n0, n1, n2)), eS3(${NA})) : {${Ew} == VS.bt(_, F.limbs(${SD})) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(QN(n0, n1, n2)), F.limbs(${SD})), F.limbs(VS.wtake(QN(n0, n1, n2), ${SD})), VS.bt_limbs(QN(n0, n1, n2), ${SD})) : {${Ew} == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(QN(n0, n1, n2), ${SD}), VF.app(VS.wtake(Q2(n0, n1), ${SD}), ${X2}), VF.take_split(Q2(n0, n1), ${M[2]}, ${SD})) : {${Ew} == F.limbs(_) : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(VF.app(VS.wtake(Q2(n0, n1), ${SD}), ${X2})), List.append(&2, U32, F.limbs(VS.wtake(Q2(n0, n1), ${SD})), F.limbs(${X2})), VF.limbs_app(VS.wtake(Q2(n0, n1), ${SD}), ${X2})) :
    {${Ew} == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Q2(n0, n1), ${SD}), VF.app(VS.wtake(Q1(n0), ${SD}), ${X1}), VF.take_split(Q1(n0), ${M[1]}, ${SD})) :
    {${Ew} == List.append(&2, U32, F.limbs(_), F.limbs(${X2})) : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(VF.app(VS.wtake(Q1(n0), ${SD}), ${X1})), List.append(&2, U32, F.limbs(VS.wtake(Q1(n0), ${SD})), F.limbs(${X1})), VF.limbs_app(VS.wtake(Q1(n0), ${SD}), ${X1})) :
    {${Ew} == List.append(&2, U32, _, F.limbs(${X2})) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Q1(n0), ${SD}), VF.app(VS.wtake(3n, ${SD}), ${X0}), VF.take_split(3n, ${M[0]}, ${SD})) :
    {${Ew} == List.append(&2, U32, List.append(&2, U32, F.limbs(_), F.limbs(${X1})), F.limbs(${X2})) : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(VF.app(VS.wtake(3n, ${SD}), ${X0})), List.append(&2, U32, F.limbs(VS.wtake(3n, ${SD})), F.limbs(${X0})), VF.limbs_app(VS.wtake(3n, ${SD}), ${X0})) :
    {${Ew} == List.append(&2, U32, List.append(&2, U32, _, F.limbs(${X1})), F.limbs(${X2})) : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(3n, 0n, ${SD}), ${HW}, hdr3(${ALLA})) :
    {${Ew} == List.append(&2, U32, List.append(&2, U32, List.append(&2, U32, F.limbs(_), F.limbs(${X0})), F.limbs(${X1})), F.limbs(${X2})) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, List.append(&2, U32, ${LH}, F.limbs(${X0})), F.limbs(${X1})), F.limbs(${X2})),
      List.append(&2, U32, List.append(&2, U32, ${LH}, F.limbs(${X0})), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2}))),
      VS.app_assoc(List.append(&2, U32, ${LH}, F.limbs(${X0})), F.limbs(${X1}), F.limbs(${X2}))) :
    {${Ew} == _ : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, ${LH}, F.limbs(${X0})), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2}))),
      List.append(&2, U32, ${LH}, List.append(&2, U32, F.limbs(${X0}), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2})))),
      VS.app_assoc(${LH}, F.limbs(${X0}), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2})))) :
    {${Ew} == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(${M[0]}, 3n, ${SD}), ${RWA[0]}, x0(${ALLA})) :
    {${Ew} == List.append(&2, U32, ${LH}, List.append(&2, U32, F.limbs(_), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2})))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(${M[1]}, Q1(n0), ${SD}), ${RWA[1]}, x1(${ALLA})) :
    {${Ew} == List.append(&2, U32, ${LH}, List.append(&2, U32, ${Y[0]}, List.append(&2, U32, F.limbs(_), F.limbs(${X2})))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(${M[2]}, Q2(n0, n1), ${SD}), ${RWA[2]}, x2(${ALLA})) :
    {${Ew} == List.append(&2, U32, ${LH}, List.append(&2, U32, ${Y[0]}, List.append(&2, U32, ${Y[1]}, F.limbs(_)))) : +List<U32>}
  {==}

# The bytes the encoder writes are the spec/codec.bend encoding of the object's value.
def encode_spec(${ALLP})
    -> Decoding.decodes(Spec.${X}(), VS.bt(U32.to_nat(${S3}), F.limbs(${SD})), XE(${ALLA})):
  Equal.trans(Maybe<&2, +List<U32>>, Codec.encoding_for_legal_type(Spec.${X}(), XE(${ALLA})), Some{${Ew}}, Some{VS.bt(U32.to_nat(${S3}), F.limbs(${SD}))},
    encE(${ALLA}), Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, z => Some{z}, ${Ew}, VS.bt(U32.to_nat(${S3}), F.limbs(${SD})), out_eq(${ALLA})))
