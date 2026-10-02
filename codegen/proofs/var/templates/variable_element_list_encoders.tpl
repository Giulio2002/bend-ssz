@@ GNEYE @@
# An element's byte count, bytes and value.
def NE(+m: MB<@EW>) -> U32:
  match m:
    case MNone{}: 0
    case MSome{+w}: EM.SZ(w)
def YE(+m: MB<@EW>) -> +List<U32>:
  match m:
    case MNone{}: []
    case MSome{+w}: EM.ENC(w)
def EV(+m: MB<@EW>) -> S.Value:
  match m:
    case MNone{}: S.EmptyItems{}
    case MSome{+w}: EM.VAL(w)


@@ GPUT @@
# The output tree after the element's boxed write at X = 4 q + r.
def PWE(+m: MB<@EW>, +dd: Nat, +D: F.array__Tree<U32>, +q: Nat, +r: Nat) -> F.array__Tree<U32>:
  match m:
    case MNone{}: D
    case MSome{+w}: EM.PUTX(w, dd, D, q, r)

# Its footprint: the element's bytes and the zeros to the end of the last word.
def FPE(+r: Nat, +m: MB<@EW>) -> Nat: Nat.add(U32.to_nat(NE(m)), WD.PADB(r, U32.to_nat(NE(m))))

def bxput(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, U32.to_nat(NE(m))))), VB.pw(dd)) == True{} : Bool}, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(FPE(r, m), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(FPE(r, m)) : +List<U32>})
    -> {T.@E_bx_putk(F.array__thaw(U32, D), X, th_@E_bx(m)) == (F.array__thaw(U32, PWE(m, dd, D, q, r)), (th_@E_bx(m), NE(m))) : Array<U32> & (O.Boxed<@EO> & U32)}:
  match m:
    case MNone{}: Empty.absurd({T.@E_bx_putk(F.array__thaw(U32, D), X, th_@E_bx(MNone{})) == (F.array__thaw(U32, PWE(MNone{}, dd, D, q, r)), (th_@E_bx(MNone{}), NE(MNone{}))) : Array<U32> & (O.Boxed<@EO> & U32)}, F.logic__false_true(h))
    case MSome{+w}:
      +es = EM.szx(w, h)
      +hl2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es, hl)
      +hz2 = F.logic__subst(Nat, z => {VS.bt(Nat.add(z, WD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, WD.PADB(r, z))) : +List<U32>}, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es, hz)
      %Equal.sym(Array<U32> & (@EO & U32), T.@E_putk(F.array__thaw(U32, D), X, EM.TH(w)), (F.array__thaw(U32, EM.PUTX(w, dd, D, q, r)), (EM.TH(w), EM.SZ(w))),
          EM.putx(w, dd, D, X, q, r, e, hr, hd, pf, hl2, hz2, h)) :
        {T.@E_bx_pk_back(_) == (F.array__thaw(U32, EM.PUTX(w, dd, D, q, r)), (O.BSome{EM.TH(w), O.BNone{}}, EM.SZ(w))) : Array<U32> & (O.Boxed<@EO> & U32)}
      {==}

def bxput_bytes(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, U32.to_nat(NE(m))))), VB.pw(dd)) == True{} : Bool}, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(FPE(r, m), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(FPE(r, m)) : +List<U32>})
    -> {UA.BYT(PWE(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(YE(m), UW.ZB(WD.PADB(r, U32.to_nat(NE(m)))))) : +List<U32>}:
  match m:
    case MNone{}: Empty.absurd({UA.BYT(PWE(MNone{}, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(YE(MNone{}), UW.ZB(WD.PADB(r, U32.to_nat(NE(MNone{})))))) : +List<U32>}, F.logic__false_true(h))
    case MSome{+w}:
      +es = EM.szx(w, h)
      +hl2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es, hl)
      +hz2 = F.logic__subst(Nat, z => {VS.bt(Nat.add(z, WD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, WD.PADB(r, z))) : +List<U32>}, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es, hz)
      F.logic__subst(Nat, z => {UA.BYT(EM.PUTX(w, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(EM.ENC(w), UW.ZB(WD.PADB(r, z)))) : +List<U32>},
        VE2.LEN(EM.ENC(w)), U32.to_nat(EM.SZ(w)), Equal.sym(Nat, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es), EM.putx_bytes(w, dd, D, X, q, r, e, hr, hd, pf, hl2, hz2, h))


@@ GDOM @@
def dom_ye(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {SP.bytes_domain(YE(m)) == True{} : Bool}:
  match m:
    case MNone{}: {==}
    case MSome{+w}: EM.domx(w, h)

# One element's spec parts: its bytes, one variable part.
def el_parts(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {Codec.parts(EV(m), @ESCH) == Some{[S.Variable{YE(m)}]} : Maybe<&2, +List<S.Part>>}:
  match m:
    case MNone{}: Empty.absurd({Codec.parts(EV(MNone{}), @ESCH) == Some{[S.Variable{YE(MNone{})}]} : Maybe<&2, +List<S.Part>>}, F.logic__false_true(h))
    case MSome{+w}: EM.encx_spec(w, h)


@@ GIFACE @@

# ==== @P in the encoder-window interface (codegen/proofs/var/progressive_small_list_codec_laws.py's ENCX, with validx and domx) ====

# The writer loop's tree is perfect.
law wlm_pf:
  for +k: Nat
  for +W: List<&2, MB<@EW>>
  for +s: Nat
  for +cur: U32
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  {F.array__perfect(U32, dd, WLM(k, W, s, cur, dd, D, X, q, r)) == True{} : Bool}
def wlm_pf(k, W, s, cur, dd, D, X, q, r, pf):
  match k:
    case 0n: pf
    case 1n+ +j:
      wlm_pf(j, W, 1n+s, O.padd(cur, NE(xat_@P(W, s))), dd, PWE(xat_@P(W, s), dd, WD.W32X(r, dd, D, Nat.add(s, q), cur), QX(U32.add(X, cur)), RX(U32.add(X, cur))), X, q, r,
        pwe_perfect(xat_@P(W, s), dd, WD.W32X(r, dd, D, Nat.add(s, q), cur), QX(U32.add(X, cur)), RX(U32.add(X, cur)), WD.w32x_perfect(r, dd, D, Nat.add(s, q), cur, pf)))

def pflb(+b: Bool, +t: F.array__Tree<MB<@EW>>, +N: U32, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool})
    -> PFLb(b, t, N, dd, D, X, q, r):
  match b:
    case True{}: pf
    case False{}: wlm_pf(U32.to_nat(N), SL(t), 0n, U32.mul(4, N), dd, D, X, q, r, pf)

# The object's Data mirror: the tree t of the boxed elements' mirrors, and the count N.
type MW is Data:
  MW{t: F.array__Tree<MB<@EW>>, N: U32}

def TH(m: MW) -> T.@P_Seq:
  match m:
    case MW{+t, +N}: THL(t, N)
# A valid object: the list's facts, and its bytes within 2^30.
def OKT(+t: F.array__Tree<MB<@EW>>, +N: U32) -> Bool: Bool.and(OKL(t, N), Nat.is_le(LL(t, N), A.quad(VB.pw(28n))))
def OK(m: MW) -> Bool:
  match m:
    case MW{+t, +N}: OKT(t, N)
def ENC(m: MW) -> +List<U32>:
  match m:
    case MW{+t, +N}: ENCL(t, N)
def VAL(m: MW) -> S.Value:
  match m:
    case MW{+t, +N}: VALL(t, N)
def SZ(m: MW) -> U32:
  match m:
    case MW{+t, +N}: SZS(t, N)
# the writer's model at the byte X = 4 q + r, as a U32
def XQ(+q: Nat, +r: Nat) -> U32: U32.from_nat(Nat.add(A.quad(q), r))
def PUTX(m: MW, +dd: Nat, +D: F.array__Tree<U32>, +q: Nat, +r: Nat) -> F.array__Tree<U32>:
  match m:
    case MW{+t, +N}: PUTL(t, N, dd, D, XQ(q, r), q, r)
def PADB(+r: Nat, m: MW) -> Nat: WD.PADB(r, VE2.LEN(ENC(m)))

def ok_l(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKT(t, N) == True{} : Bool}) -> {OKL(t, N) == True{} : Bool}:
  and_l(OKL(t, N), Nat.is_le(LL(t, N), A.quad(VB.pw(28n))), h)
def ok_b(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKT(t, N) == True{} : Bool}) -> {Nat.is_le(LL(t, N), A.quad(VB.pw(28n))) == True{} : Bool}:
  and_r(OKL(t, N), Nat.is_le(LL(t, N), A.quad(VB.pw(28n))), h)
# (the bound with its exponent symbolic, k = 28: a literal 2^30 in a conversion would be expanded)
def ok_bk(+t: F.array__Tree<MB<@EW>>, +N: U32, +k: Nat, +ek: {k == 28n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {Nat.is_le(LL(t, N), A.quad(VB.pw(k))) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(LL(t, N), A.quad(VB.pw(z))) == True{} : Bool}, 28n, k, Equal.sym(Nat, k, 28n, ek), ok_b(t, N, h))
def ek2(+k: Nat, +ek: {k == 28n : Nat}) -> {2n+k == 30n : Nat}: Equal.cong(Nat, Nat, z => 2n+z, k, 28n, ek)
def hk30(+k: Nat, +ek: {k == 28n : Nat}) -> {Nat.is_lt(k, 30n) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(z, 30n) == True{} : Bool}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==})
def szsk(+t: F.array__Tree<MB<@EW>>, +N: U32, +k: Nat, +ek: {k == 28n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {U32.to_nat(SZS(t, N)) == LL(t, N) : Nat}:
  szs(t, N, ok_l(t, N, h), 2n+k, ek2(k, ek), ok_bk(t, N, k, ek, h))
def szwk(+t: F.array__Tree<MB<@EW>>, +N: U32, +k: Nat, +ek: {k == 28n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {U32.to_nat(SZW(t, N)) == LL(t, N) : Nat}:
  szl(t, N, ok_l(t, N, h), 2n+k, ek2(k, ek), ok_bk(t, N, k, ek, h))
def speck(+t: F.array__Tree<MB<@EW>>, +N: U32, +k: Nat, +ek: {k == 28n : Nat}, +h: {OKT(t, N) == True{} : Bool})
    -> {Codec.parts(VALL(t, N), @LSCH) == Some{[S.Variable{ENCL(t, N)}]} : Maybe<&2, +List<S.Part>>}:
  specl(t, N, ok_l(t, N, h), k, hk30(k, ek), ok_bk(t, N, k, ek, h))

# The returned size of the writer is the size pass's.
def eqsz(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKT(t, N) == True{} : Bool}) -> {SZW(t, N) == SZS(t, N) : U32}:
  F.u32__injective(SZW(t, N), SZS(t, N), Equal.trans(Nat, U32.to_nat(SZW(t, N)), LL(t, N), U32.to_nat(SZS(t, N)), szwk(t, N, 28n, {==}, h),
    Equal.sym(Nat, U32.to_nat(SZS(t, N)), LL(t, N), szsk(t, N, 28n, {==}, h))))

# The runtime's X is XQ(q, r).
def exq(+X: U32, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool}) -> {X == XQ(q, r) : U32}:
  +X0 = Nat.add(A.quad(q), r)
  +E = A.quad(Nat.add(q, WD.NWN(Nat.add(r, L))))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(X0, z) == True{} : Bool}, Nat.add(X0, Nat.add(L, WD.PADB(r, L))), E, e_end(q, r, L), Order.below_sum(X0, Nat.add(L, WD.PADB(r, L))))
  +h2 = F.nat__le_trans(X0, E, VB.pw(30n), h1, F.nat__le_trans(E, A.quad(VB.pw(dd)), VB.pw(30n), UW.quad_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd), hl), q30(dd, hd)))
  F.u32__injective(X, XQ(q, r), Equal.trans(Nat, U32.to_nat(X), X0, U32.to_nat(XQ(q, r)), e, Equal.sym(Nat, U32.to_nat(XQ(q, r)), X0, F.u32__to_nat_from_nat(X0, 31n, {==}, b31n(X0, h2)))))

# exq at any output depth dd < 31: X0 = to_nat X is below 2^32 anyway.
def exqW(+X: U32, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool}) -> {X == XQ(q, r) : U32}:
  +X0 = Nat.add(A.quad(q), r)
  +hx = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(32n)) == True{} : Bool}, U32.to_nat(X), X0, e, VB.u32_lt(X))
  F.u32__injective(X, XQ(q, r), Equal.trans(Nat, U32.to_nat(X), X0, U32.to_nat(XQ(q, r)), e, Equal.sym(Nat, U32.to_nat(XQ(q, r)), X0, F.u32__to_nat_from_nat(X0, 32n, {==}, hx))))

def hlx(+t: F.array__Tree<MB<@EW>>, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, VE2.LEN(ENCL(t, N))))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL(t, N)))), VB.pw(dd)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N), hl)
def hlx32(+t: F.array__Tree<MB<@EW>>, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hl32: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, VE2.LEN(ENCL(t, N)))), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, LL(t, N))), F.spec_common__pow2(32n)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, z)), F.spec_common__pow2(32n)) == True{} : Bool}, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N), hl32)
def hlx31(+t: F.array__Tree<MB<@EW>>, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hs31: {Nat.is_lt(VE2.LEN(ENCL(t, N)), VB.pw(31n)) == True{} : Bool})
    -> {Nat.is_lt(LL(t, N), VB.pw(31n)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(31n)) == True{} : Bool}, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N), hs31)
def hzx(+t: F.array__Tree<MB<@EW>>, +N: U32, +q: Nat, +r: Nat, +D: F.array__Tree<U32>,
    +hz: {VS.bt(Nat.add(VE2.LEN(ENCL(t, N)), WD.PADB(r, VE2.LEN(ENCL(t, N)))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(VE2.LEN(ENCL(t, N)), WD.PADB(r, VE2.LEN(ENCL(t, N))))) : +List<U32>})
    -> {VS.bt(Nat.add(LL(t, N), WD.PADB(r, LL(t, N))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(LL(t, N), WD.PADB(r, LL(t, N)))) : +List<U32>}:
  F.logic__subst(Nat, z => {VS.bt(Nat.add(z, WD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, WD.PADB(r, z))) : +List<U32>}, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N), hz)

def RTX(+t: F.array__Tree<MB<@EW>>, +N: U32, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.@P_putk(F.array__thaw(U32, D), X, THL(t, N)) == (F.array__thaw(U32, PUTL(t, N, dd, D, XQ(q, r), q, r)), (THL(t, N), SZS(t, N))) : Array<U32> & (T.@P_Seq & U32)}
def BYX(+t: F.array__Tree<MB<@EW>>, +N: U32, +dd: Nat, +D: F.array__Tree<U32>, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PUTL(t, N, dd, D, XQ(q, r), q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(ENCL(t, N), UW.ZB(WD.PADB(r, VE2.LEN(ENCL(t, N)))))) : +List<U32>}

def go(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKT(t, N) == True{} : Bool}, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, VE2.LEN(ENCL(t, N))))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(VE2.LEN(ENCL(t, N)), WD.PADB(r, VE2.LEN(ENCL(t, N)))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(VE2.LEN(ENCL(t, N)), WD.PADB(r, VE2.LEN(ENCL(t, N))))) : +List<U32>})
    -> DK.P2(RTX(t, N, dd, D, X, q, r), BYX(t, N, dd, D, q, r)):
  +hl2 = hlx(t, N, q, r, dd, hl)
  +ex = exq(X, q, r, LL(t, N), dd, e, hd, hl2)
  +e2 = F.logic__subst(U32, z => {U32.to_nat(z) == Nat.add(A.quad(q), r) : Nat}, X, XQ(q, r), ex, e)
  +b = U32.is_eq(N, 0)
  +g = putl(t, N, ok_l(t, N, h), dd, D, XQ(q, r), q, r, e2, hr, hd, hl2, pf, hzx(t, N, q, r, D, hz))
  +rt = PA(RTL(t, N, dd, D, XQ(q, r), q, r), DK.P2(BYLb(b, t, N, dd, D, XQ(q, r), q, r), PFLb(b, t, N, dd, D, XQ(q, r), q, r)), g)
  +g2 = PB(RTL(t, N, dd, D, XQ(q, r), q, r), DK.P2(BYLb(b, t, N, dd, D, XQ(q, r), q, r), PFLb(b, t, N, dd, D, XQ(q, r), q, r)), g)
  +by = PA(BYLb(b, t, N, dd, D, XQ(q, r), q, r), PFLb(b, t, N, dd, D, XQ(q, r), q, r), g2)
  +rt2 = F.logic__subst(U32, z => {T.@P_putk(F.array__thaw(U32, D), z, THL(t, N)) == (F.array__thaw(U32, PUTL(t, N, dd, D, XQ(q, r), q, r)), (THL(t, N), SZW(t, N))) : Array<U32> & (T.@P_Seq & U32)},
    XQ(q, r), X, Equal.sym(U32, X, XQ(q, r), ex), rt)
  +rt3 = F.logic__subst(U32, z => {T.@P_putk(F.array__thaw(U32, D), X, THL(t, N)) == (F.array__thaw(U32, PUTL(t, N, dd, D, XQ(q, r), q, r)), (THL(t, N), z)) : Array<U32> & (T.@P_Seq & U32)},
    SZW(t, N), SZS(t, N), eqsz(t, N, h), rt2)
  +by2 = F.logic__subst(Nat, z => {UA.BYT(PUTL(t, N, dd, D, XQ(q, r), q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(ENCL(t, N), UW.ZB(WD.PADB(r, z)))) : +List<U32>},
    LL(t, N), VE2.LEN(ENCL(t, N)), Equal.sym(Nat, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N)), by)
  (rt3, by2)

# ---- the interface's laws ----------------------------------------------------------------------

law putx:
  for +m: MW
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {T.@P_putk(F.array__thaw(U32, D), X, TH(m)) == (F.array__thaw(U32, PUTX(m, dd, D, q, r)), (TH(m), SZ(m))) : Array<U32> & (T.@P_Seq & U32)}
def putx(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case MW{+t, +N}: PA(RTX(t, N, dd, D, X, q, r), BYX(t, N, dd, D, q, r), go(t, N, hok, dd, D, X, q, r, e, hr, hd, pf, hl, hz))

law putx_bytes:
  for +m: MW
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {UA.BYT(PUTX(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, ENC(m), UW.ZB(PADB(r, m)))) : +List<U32>}
def putx_bytes(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case MW{+t, +N}: PB(RTX(t, N, dd, D, X, q, r), BYX(t, N, dd, D, q, r), go(t, N, hok, dd, D, X, q, r, e, hr, hd, pf, hl, hz))

law pfx:
  for +m: MW
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +q: Nat
  for +r: Nat
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  {F.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == True{} : Bool}
def pfx(m, dd, D, q, r, pf):
  match m:
    case MW{+t, +N}: pflb(U32.is_eq(N, 0), t, N, dd, D, XQ(q, r), q, r, pf)

law szx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {U32.to_nat(SZ(m)) == List.length(&2, U32, ENC(m)) : Nat}
def szx(m, hok):
  match m:
    case MW{+t, +N}: Equal.trans(Nat, U32.to_nat(SZS(t, N)), LL(t, N), VE2.LEN(ENCL(t, N)), szsk(t, N, 28n, {==}, hok), Equal.sym(Nat, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N)))

law sizex:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.@P_size(TH(m)) == (TH(m), SZ(m)) : T.@P_Seq & U32}
def sizex(m, hok):
  match m:
    case MW{+t, +N}: sizel(t, N, ok_l(t, N, hok))

law validx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.@P_valid(TH(m)) == (TH(m), True{}) : T.@P_Seq & Bool}
def validx(m, hok):
  match m:
    case MW{+t, +N}: valid_l(t, N, ok_l(t, N, hok))

law domx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {SP.bytes_domain(ENC(m)) == True{} : Bool}
def domx(m, hok):
  match m:
    case MW{+t, +N}: domxl(t, N, ok_l(t, N, hok))

law encx_spec:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {Codec.parts(VAL(m), @LSCH) == Some{[S.Variable{ENC(m)}]} : Maybe<&2, +List<S.Part>>}
def encx_spec(m, hok):
  match m:
    case MW{+t, +N}: speck(t, N, 28n, {==}, hok)
