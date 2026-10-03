@@ VL_OKB @@
def ok_bk(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 31n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {Nat.is_le(LL(t, N), U32.to_nat(VB.NMAX())) == True{} : Bool}:
  ok_b(t, N, h)
def szsk(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 31n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {U32.to_nat(SZS(t, N)) == LL(t, N) : Nat}:
  szsS(t, N, ok_l(t, N, h), ok_b(t, N, h))
def szwk(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 31n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {U32.to_nat(SZW(t, N)) == LL(t, N) : Nat}:
  szlS(t, N, ok_l(t, N, h), ok_b(t, N, h))
@@ VL_SPECK @@
def speck(+t: F.array__Tree<MB<EM.MW>>, +N: U32, +k: Nat, +ek: {k == 29n : Nat}, +h: {OKT(t, N) == True{} : Bool})
    -> @SPECRET@:
  speclB(t, N, ok_l(t, N, h), LL(t, N), ok_b(t, N, h), F.nat__le_refl(LL(t, N)))
