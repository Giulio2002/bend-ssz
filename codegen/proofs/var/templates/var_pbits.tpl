@@ dec_text @@
def cL(+t: FD.array__Tree<U32>, +n: U32, +h: {chk1(True{}, t, n) == True{} : Bool}, +nz: {U32.is_eq(V(t, n), 0) == False{} : Bool})
    -> {@LT29 == True{} : Bool}:
  FD.logic__subst(Bool, z => {O.bsel(z, False{}, O.bsel(True{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N)))) == True{} : Bool}, U32.is_eq(V(t, n), 0), False{}, nz, h)

def c1(