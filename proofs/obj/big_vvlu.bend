import Base
import ../compact/found.bend as F
import ../compact/arith.bend as A

# Word arithmetic of the offsets-table loops (codegen/var_vlist.py): every word is below
# 2^32, 4 y and i + k do not wrap when bounded by some word.

def u32lt(+x: U32) -> {Nat.is_lt(U32.to_nat(x), F.spec_common__pow2(32n)) == True{} : Bool}:
  match x:
    case U32{+w}:
      %Equal.sym(Nat, U32.to_nat(U32{w}), F.spec_numeric__unsigned(32n, w), F.u32__to_nat_word(w)) : {Nat.is_lt(_, F.spec_common__pow2(32n)) == True{} : Bool}
      %Equal.sym(Nat, F.spec_common__pow2(32n), F.spec_numeric__scale_binary(32n, 1n), F.u32__pow2_scale(32n)) : {Nat.is_lt(F.spec_numeric__unsigned(32n, w), _) == True{} : Bool}
      F.u32__WB_unsigned(32n, w)

def mulshl(+y: U32) -> {U32.mul(4, y) == U32.shl(U32.shl(y)) : U32}:
  match y:
    case U32{+w}:
      Equal.cong(Word(32n), U32, v => U32{v}, Word.add(32n, Word.zero(32n), Word.shl(32n, Word.shl(32n, w))), Word.shl(32n, Word.shl(32n, w)),
        F.u32alg__w_zero_add(32n, Word.shl(32n, Word.shl(32n, w))))

# 4 y, when 4 y is at most the value of some word c.
def mul4(+y: U32, +c: U32, +h: {Nat.is_le(A.quad(U32.to_nat(y)), U32.to_nat(c)) == True{} : Bool})
    -> {U32.to_nat(U32.mul(4, y)) == A.quad(U32.to_nat(y)) : Nat}:
  +hq = F.nat__le_lt_trans(A.quad(U32.to_nat(y)), U32.to_nat(c), F.spec_common__pow2(32n), h, u32lt(c))
  +h1 = F.nat__le_lt_trans(Nat.double(U32.to_nat(y)), A.quad(U32.to_nat(y)), F.spec_common__pow2(32n), F.nat__double_self_le(Nat.double(U32.to_nat(y))), hq)
  +e1 = F.u32__shl_value(y, 32n, {==}, h1)
  +h2 = F.logic__subst(Nat, z => {Nat.is_lt(Nat.double(z), F.spec_common__pow2(32n)) == True{} : Bool}, Nat.double(U32.to_nat(y)), U32.to_nat(U32.shl(y)), Equal.sym(Nat, U32.to_nat(U32.shl(y)), Nat.double(U32.to_nat(y)), e1), hq)
  +e2 = F.u32__shl_value(U32.shl(y), 32n, {==}, h2)
  %Equal.sym(U32, U32.mul(4, y), U32.shl(U32.shl(y)), mulshl(y)) : {U32.to_nat(_) == A.quad(U32.to_nat(y)) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.shl(U32.shl(y))), Nat.double(U32.to_nat(U32.shl(y))), e2) : {_ == A.quad(U32.to_nat(y)) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.shl(y)), Nat.double(U32.to_nat(y)), e1) : {Nat.double(_) == A.quad(U32.to_nat(y)) : Nat}
  {==}

# i + k, when it is at most the value of some word c.
def addk(+i: U32, +k: U32, +c: U32, +h: {Nat.is_le(Nat.add(U32.to_nat(k), U32.to_nat(i)), U32.to_nat(c)) == True{} : Bool})
    -> {U32.to_nat(U32.add(i, k)) == Nat.add(U32.to_nat(k), U32.to_nat(i)) : Nat}:
  %F.nat__add_comm(U32.to_nat(i), U32.to_nat(k)) : {U32.to_nat(U32.add(i, k)) == _ : Nat}
  A.add_le(i, k, c, F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(c)) == True{} : Bool}, Nat.add(U32.to_nat(k), U32.to_nat(i)), Nat.add(U32.to_nat(i), U32.to_nat(k)), F.nat__add_comm(U32.to_nat(k), U32.to_nat(i)), h))

# A word test that fails: the values differ.
def eqf(+a: U32, +b: U32, +h: {U32.is_eq(a, b) == False{} : Bool}) -> {Nat.is_eq(U32.to_nat(a), U32.to_nat(b)) == False{} : Bool}:
  %F.u32__u32_cmp(a, b) : {Cmp.is_eq(_) == False{} : Bool}
  h

def eqt(+a: U32, +b: U32, +h: {U32.is_eq(a, b) == True{} : Bool}) -> {U32.to_nat(a) == U32.to_nat(b) : Nat}:
  Equal.cong(U32, Nat, z => U32.to_nat(z), a, b, F.u32alg__eq_of(a, b, h))
