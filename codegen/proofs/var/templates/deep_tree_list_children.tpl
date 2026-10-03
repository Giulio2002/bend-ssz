@@ VL_HELP @@
# the cursor lemmas at a strict bound: x < 2^k with k == 31 (the poison bit's; the base ones take k == 30 and x <= 2^k)
def bsucD(+x: Nat, +k: Nat, +h: {Nat.is_lt(x, VB.pw(k)) == True{} : Bool}) -> {Nat.is_lt(x, VB.pw(k)) == True{} : Bool}: h
def lsucD(+x: Nat, +k: Nat, +h: {Nat.is_lt(x, VB.pw(k)) == True{} : Bool}) -> {Nat.is_le(x, VB.pw(k)) == True{} : Bool}:
  F.nat__lt_le(x, VB.pw(k), h)
def t31D(+x: Nat, +k: Nat, +ek: {k == 31n : Nat}, +h: {Nat.is_le(x, VB.pw(k)) == True{} : Bool}) -> {Nat.is_le(x, U32.to_nat(VB.NMAX())) == True{} : Bool}:
  VB.le31_nmax(x, F.logic__subst(Nat, z => {Nat.is_le(x, VB.pw(z)) == True{} : Bool}, k, 31n, ek, h))
def t31sD(+x: Nat, +k: Nat, +ek: {k == 31n : Nat}, +h: {Nat.is_lt(x, VB.pw(k)) == True{} : Bool}) -> {Nat.is_le(x, U32.to_nat(VB.NMAX())) == True{} : Bool}:
  VB.le_pw31_nmax(x, F.logic__subst(Nat, z => {Nat.is_lt(x, VB.pw(z)) == True{} : Bool}, k, 31n, ek, h))

@@ VL_OKB @@
def ok_bk(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 31n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {Nat.is_lt(LL(t, N), VB.pw(k)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(LL(t, N), VB.pw(z)) == True{} : Bool}, 31n, k, Equal.sym(Nat, k, 31n, ek), ok_b(t, N, h))
def ok_bq(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 29n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {Nat.is_le(LL(t, N), A.quad(VB.pw(k))) == True{} : Bool}:
  +e2 = Equal.cong(Nat, Nat, z => 2n+z, k, 29n, ek)
  F.nat__lt_le(LL(t, N), VB.pw(2n+k), F.logic__subst(Nat, z => {Nat.is_lt(LL(t, N), VB.pw(z)) == True{} : Bool}, 31n, 2n+k, Equal.sym(Nat, 2n+k, 31n, e2), ok_b(t, N, h)))
def hk30q(+k: Nat, +ek: {k == 29n : Nat}) -> {Nat.is_lt(k, 30n) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(z, 30n) == True{} : Bool}, 29n, k, Equal.sym(Nat, k, 29n, ek), {==})
def szsk(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 31n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {U32.to_nat(SZS(t, N)) == LL(t, N) : Nat}:
  szsD(t, N, ok_l(t, N, h), k, ek, ok_bk(t, N, k, ek, h))
def szwk(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 31n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {U32.to_nat(SZW(t, N)) == LL(t, N) : Nat}:
  szlD(t, N, ok_l(t, N, h), k, ek, ok_bk(t, N, k, ek, h))
def speck(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 29n : Nat}, +h: {OKT(t, N) == True{} : Bool})
    -> @SPECRET@:
  specl(t, N, ok_l(t, N, h), k, hk30q(k, ek), ok_bq(t, N, k, ek, h))
