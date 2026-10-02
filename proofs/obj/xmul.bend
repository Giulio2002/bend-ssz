import Base
import ../compact/found_generated.bend as F
import ./vmul_generated.bend as VM

# Products of powers of two for vmul.mulE (E * k by repeated addition), symbolically:
# the evaluated 512 * 4096 == 2^21 (var_multi_u32 eM0) counted two million unary steps (5 s).

# ---- products of powers of two (vmul.mulE: E * k by repeated addition) ------------------

law add2_dbl:
  for +e: Nat
  for +m: Nat
  {Nat.add(e, Nat.add(e, Nat.double(m))) == Nat.double(Nat.add(e, m)) : Nat}
def add2_dbl(e, m):
  match e:
    case 0n: {==}
    case 1n+ +c:
      %Equal.sym(Nat, Nat.add(c, 1n+Nat.add(c, Nat.double(m))), 1n+Nat.add(c, Nat.add(c, Nat.double(m))), F.nat__add_succ(c, Nat.add(c, Nat.double(m)))) :
        {1n+_ == Nat.double(1n+Nat.add(c, m)) : Nat}
      %Equal.sym(Nat, Nat.add(c, Nat.add(c, Nat.double(m))), Nat.double(Nat.add(c, m)), add2_dbl(c, m)) :
        {2n+_ == Nat.double(1n+Nat.add(c, m)) : Nat}
      {==}

law mulE_dbl:
  for +E: Nat
  for +k: Nat
  {VM.mulE(E, Nat.double(k)) == Nat.double(VM.mulE(E, k)) : Nat}
def mulE_dbl(E, k):
  match k:
    case 0n: {==}
    case 1n+ +c:
      %Equal.sym(Nat, VM.mulE(E, Nat.double(c)), Nat.double(VM.mulE(E, c)), mulE_dbl(E, c)) :
        {Nat.add(E, Nat.add(E, _)) == Nat.double(Nat.add(E, VM.mulE(E, c))) : Nat}
      add2_dbl(E, VM.mulE(E, c))

# 2^a * 2^b = 2^r (r = a + b as its own parameter).
law mulp:
  for +a: Nat
  for +b: Nat
  for +r: Nat
  for +er: {r == Nat.add(b, a) : Nat}
  {VM.mulE(F.spec_common__pow2(a), F.spec_common__pow2(b)) == F.spec_common__pow2(r) : Nat}
def mulp(a, b, r, er):
  match b:
    case 0n:
      %Equal.sym(Nat, r, a, er) : {VM.mulE(F.spec_common__pow2(a), 1n) == F.spec_common__pow2(_) : Nat}
      F.nat__add_zero(F.spec_common__pow2(a))
    case 1n+ +c:
      %Equal.sym(Nat, r, 1n+Nat.add(c, a), er) : {VM.mulE(F.spec_common__pow2(a), Nat.double(F.spec_common__pow2(c))) == F.spec_common__pow2(_) : Nat}
      %Equal.sym(Nat, VM.mulE(F.spec_common__pow2(a), Nat.double(F.spec_common__pow2(c))), Nat.double(VM.mulE(F.spec_common__pow2(a), F.spec_common__pow2(c))), mulE_dbl(F.spec_common__pow2(a), F.spec_common__pow2(c))) :
        {_ == Nat.double(F.spec_common__pow2(Nat.add(c, a))) : Nat}
      Equal.cong(Nat, Nat, z => Nat.double(z), VM.mulE(F.spec_common__pow2(a), F.spec_common__pow2(c)), F.spec_common__pow2(Nat.add(c, a)), mulp(a, c, Nat.add(c, a), {==}))

# mulE(E, to_nat(K)) == to_nat(W) from E = 2^a, K = 2^b (words), W = 2^r (a word), r = a + b.
def mulw(+E: Nat, +K: U32, +W: U32, +a: Nat, +b: Nat, +r: Nat, +eE: {E == F.spec_common__pow2(a) : Nat},
    +eK: {K == F.u32__pow2u(b) : U32}, +hb: {Nat.is_lt(b, 32n) == True{} : Bool},
    +eW: {W == F.u32__pow2u(r) : U32}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool}, +er: {r == Nat.add(b, a) : Nat})
    -> {VM.mulE(E, U32.to_nat(K)) == U32.to_nat(W) : Nat}:
  +kK = Equal.trans(Nat, U32.to_nat(K), U32.to_nat(F.u32__pow2u(b)), F.spec_common__pow2(b), Equal.cong(U32, Nat, z => U32.to_nat(z), K, F.u32__pow2u(b), eK), F.u32__pow2u_value(b, hb))
  +kW = Equal.trans(Nat, U32.to_nat(W), U32.to_nat(F.u32__pow2u(r)), F.spec_common__pow2(r), Equal.cong(U32, Nat, z => U32.to_nat(z), W, F.u32__pow2u(r), eW), F.u32__pow2u_value(r, hr))
  %Equal.sym(Nat, E, F.spec_common__pow2(a), eE) : {VM.mulE(_, U32.to_nat(K)) == U32.to_nat(W) : Nat}
  %Equal.sym(Nat, U32.to_nat(K), F.spec_common__pow2(b), kK) : {VM.mulE(F.spec_common__pow2(a), _) == U32.to_nat(W) : Nat}
  %Equal.sym(Nat, U32.to_nat(W), F.spec_common__pow2(r), kW) : {VM.mulE(F.spec_common__pow2(a), F.spec_common__pow2(b)) == _ : Nat}
  mulp(a, b, r, er)
