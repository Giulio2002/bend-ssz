import Base
import ../../src/buffer.bend as B
import ../../spec/nat_bytes.bend as N
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../compact/bits_generated.bend as BT
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC

# Reading back the buffer's words from its bytes, for the rejection laws of
# nested variable-size containers: a word is determined by its limbs, the four
# bytes at 4 k of the buffer are the limbs of word k, and cutting a prefix off
# a concatenation.

def q0(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: h
    case Nil{}: 0
def q1(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q0(t)
    case Nil{}: 0
def q2(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q1(t)
    case Nil{}: 0
def q3(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q2(t)
    case Nil{}: 0

# Two words with the same limbs are equal.
def wordc(+x: U32, +y: U32, +h: {FX.limbs([x]) == FX.limbs([y]) : +List<U32>}) -> {x == y : U32}:
  Equal.trans(U32, x, BT.asm(B.byte_sel(0, x), B.byte_sel(1, x), B.byte_sel(2, x), B.byte_sel(3, x)), y, BT.reassemble(x),
    Equal.trans(U32, BT.asm(B.byte_sel(0, x), B.byte_sel(1, x), B.byte_sel(2, x), B.byte_sel(3, x)), BT.asm(B.byte_sel(0, y), B.byte_sel(1, y), B.byte_sel(2, y), B.byte_sel(3, y)), y,
      BT.asm_cong(B.byte_sel(0, x), B.byte_sel(1, x), B.byte_sel(2, x), B.byte_sel(3, x), B.byte_sel(0, y), B.byte_sel(1, y), B.byte_sel(2, y), B.byte_sel(3, y),
        Equal.cong(+List<U32>, U32, l => q0(l), FX.limbs([x]), FX.limbs([y]), h),
        Equal.cong(+List<U32>, U32, l => q1(l), FX.limbs([x]), FX.limbs([y]), h),
        Equal.cong(+List<U32>, U32, l => q2(l), FX.limbs([x]), FX.limbs([y]), h),
        Equal.cong(+List<U32>, U32, l => q3(l), FX.limbs([x]), FX.limbs([y]), h)),
      Equal.sym(U32, y, BT.asm(B.byte_sel(0, y), B.byte_sel(1, y), B.byte_sel(2, y), B.byte_sel(3, y)), BT.reassemble(y))))

law wdr0_eq:
  for +n: Nat
  for +W: List<&2, U32>
  {VS.wdr0(n, W) == VB.wdr(n, W) : List<&2, U32>}
def wdr0_eq(n, W):
  match n W:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}: wdr0_eq(p, t)

def VWg(+t: F.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), FX.limbs(F.array__slots(U32, t)))

# The four bytes at 4 k are the limbs of word k.
def byteK(+t: F.array__Tree<U32>, +n: U32, +k: Nat, +X: Nat, +en: {U32.to_nat(n) == Nat.add(A.quad(k), 4n+X) : Nat},
    +hp: {Nat.is_lt(k, VB.len(F.array__slots(U32, t))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(A.quad(k), VWg(t, n))) == FX.limbs([VB.slot(t, k)]) : +List<U32>}:
  +s = F.array__slots(U32, t)
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(A.quad(k), 4n+X), en) : {VS.bt(4n, VS.bdr(A.quad(k), VS.bt(_, FX.limbs(s)))) == FX.limbs([VB.slot(t, k)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(k), VS.bt(Nat.add(A.quad(k), 4n+X), FX.limbs(s))), VS.bt(4n+X, VS.bdr(A.quad(k), FX.limbs(s))), VS.bdr_bt(A.quad(k), 4n+X, FX.limbs(s))) :
    {VS.bt(4n, _) == FX.limbs([VB.slot(t, k)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bt(4n+X, VS.bdr(A.quad(k), FX.limbs(s)))), VS.bt(4n, VS.bdr(A.quad(k), FX.limbs(s))), VS.bt_bt(4n, X, VS.bdr(A.quad(k), FX.limbs(s)))) :
    {_ == FX.limbs([VB.slot(t, k)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(k), FX.limbs(s)), FX.limbs(VS.wdr0(k, s)), VS.bdr_limbs(k, s)) :
    {VS.bt(4n, _) == FX.limbs([VB.slot(t, k)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, FX.limbs(VS.wdr0(k, s))), FX.limbs(VS.wtake(1n, VS.wdr0(k, s))), VS.bt_limbs(1n, VS.wdr0(k, s))) :
    {_ == FX.limbs([VB.slot(t, k)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(k, s), VB.wdr(k, s), wdr0_eq(k, s)) :
    {FX.limbs(VS.wtake(1n, _)) == FX.limbs([VB.slot(t, k)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(1n, VB.wdr(k, s)), Con{F.flat__nthc(s, k), VS.wtake(0n, VB.wdr(1n+k, s))}, VB.wt_eta(0n, k, s, hp)) :
    {FX.limbs(_) == FX.limbs([VB.slot(t, k)]) : +List<U32>}
  {==}

# The same, from 4 k + 4 <= n <= 4 2^d.
def byteK2(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +k: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(A.quad(k), 4n), U32.to_nat(n)) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(A.quad(k), VWg(t, n))) == FX.limbs([VB.slot(t, k)]) : +List<U32>}:
  +X = Nat.sub(U32.to_nat(n), Nat.add(A.quad(k), 4n))
  +e1 = Equal.sym(Nat, Nat.add(Nat.add(A.quad(k), 4n), X), U32.to_nat(n), F.nat__sub_add(U32.to_nat(n), Nat.add(A.quad(k), 4n), h))
  +en = Equal.trans(Nat, U32.to_nat(n), Nat.add(Nat.add(A.quad(k), 4n), X), Nat.add(A.quad(k), 4n+X), e1, F.nat__add_assoc(A.quad(k), 4n, X))
  # 4 (k + 1) <= 4 2^d, so k < 2^d
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(n)) == True{} : Bool}, Nat.add(A.quad(k), 4n), 4n+A.quad(k), F.nat__add_comm(A.quad(k), 4n), h)
  +hq = F.nat__succ_le_lt(k, VB.pw(d), VC.quad_inv(1n+k, VB.pw(d), F.nat__le_trans(4n+A.quad(k), U32.to_nat(n), A.quad(VB.pw(d)), h1, hn)))
  +hp = F.logic__subst(Nat, z => {Nat.is_lt(k, z) == True{} : Bool}, VB.pw(d), VB.len(F.array__slots(U32, t)), Equal.sym(Nat, VB.len(F.array__slots(U32, t)), VB.pw(d), F.array__slots_length(U32, d, t, pf)), hq)
  byteK(t, n, k, X, en, hp)

law bt_app:
  for +m: Nat
  for +xs: +List<U32>
  for +R: +List<U32>
  for +h: {Nat.is_le(m, List.length(&2, U32, xs)) == True{} : Bool}
  {VS.bt(m, List.append(&2, U32, xs, R)) == VS.bt(m, xs) : +List<U32>}
def bt_app(m, xs, R, h):
  match m xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({VS.bt(1n+p, List.append(&2, U32, Nil{}, R)) == VS.bt(1n+p, Nil{}) : +List<U32>}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +r}:
      %bt_app(p, r, R, h) : {x <> VS.bt(p, List.append(&2, U32, r, R)) == x <> _ : +List<U32>}
      {==}

# The four bytes at P < |xs| - 3 of a concatenation are those of its first part.
law btbdr_app:
  for +P: Nat
  for +xs: +List<U32>
  for +R: +List<U32>
  for +h: {Nat.is_le(Nat.add(P, 4n), List.length(&2, U32, xs)) == True{} : Bool}
  {VS.bt(4n, VS.bdr(P, List.append(&2, U32, xs, R))) == VS.bt(4n, VS.bdr(P, xs)) : +List<U32>}
def btbdr_app(P, xs, R, h):
  match P xs:
    case 0n _: bt_app(4n, xs, R, h)
    case 1n+ +q Nil{}: Empty.absurd({VS.bt(4n, VS.bdr(1n+q, List.append(&2, U32, Nil{}, R))) == VS.bt(4n, VS.bdr(1n+q, Nil{})) : +List<U32>}, F.logic__false_true(h))
    case 1n+ +q Con{+x, +r}: btbdr_app(q, r, R, h)

law bdr_nil:
  for +b: Nat
  {VS.bdr(b, []) == [] : +List<U32>}
def bdr_nil(b):
  match b:
    case 0n: {==}
    case 1n+ +p: {==}

law bdr_add:
  for +a: Nat
  for +b: Nat
  for +xs: +List<U32>
  {VS.bdr(Nat.add(a, b), xs) == VS.bdr(b, VS.bdr(a, xs)) : +List<U32>}
def bdr_add(a, b, xs):
  match a xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: Equal.sym(+List<U32>, VS.bdr(b, []), [], bdr_nil(b))
    case 1n+ +p Con{+x, +r}: bdr_add(p, b, r)
