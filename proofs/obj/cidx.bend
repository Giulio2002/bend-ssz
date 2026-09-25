import Base
import ../../src/obj.bend as O
import ../../proofs/nat_order.bend as Order
import ../../proofs/word_split.bend as WSp
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./mtree_defs.bend as MD
import ./ctree.bend as CT

# The U32 index arithmetic of the cached Merkle trees, as Nat facts: the
# capacity O.pow2u(d), a heap position 2^d + i, the children 2j and 2j + 1, a
# parent j >> 1 and the loop counts. Every fact carries the bound that keeps
# the U32 operation from wrapping; the bounds are relative (2^d for a depth
# d < 31, the depth of the cache tree), never a closed large number.

# ---- the capacity ---------------------------------------------------------------

law pow2u_eq:
  for +d: Nat
  {O.pow2u(d) == F.u32__pow2u(d) : U32}
def pow2u_eq(d):
  match d:
    case 0n: {==}
    case 1n+ +p:
      %pow2u_eq(p) : {U32.shl(O.pow2u(p)) == U32.shl(_) : U32}
      {==}

def pow2u_val(+d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}) -> {U32.to_nat(O.pow2u(d)) == O.pow2n(d) : Nat}:
  %Equal.sym(U32, O.pow2u(d), F.u32__pow2u(d), pow2u_eq(d)) : {U32.to_nat(_) == O.pow2n(d) : Nat}
  Equal.trans(Nat, U32.to_nat(F.u32__pow2u(d)), F.spec_common__pow2(d), O.pow2n(d), F.u32__pow2u_value(d, hd), CT.pow2_eq(d))

def rw_bound(+x: Nat, +k: Nat, +hk: {Nat.is_lt(k, 32n) == True{} : Bool}, +h: {Nat.is_le(x, O.pow2n(k)) == True{} : Bool})
    -> {Nat.is_le(x, U32.to_nat(O.pow2u(k))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(O.pow2u(k)), O.pow2n(k), pow2u_val(k, hk)) : {Nat.is_le(x, _) == True{} : Bool}
  h

# ---- sums that do not wrap ----------------------------------------------------------

# a + b for to_nat(a) + to_nat(b) <= 2^k, k < 32.
def add_nat(+a: U32, +b: U32, +k: Nat, +hk: {Nat.is_lt(k, 32n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), O.pow2n(k)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, b)) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}:
  A.add_le(a, b, O.pow2u(k), rw_bound(Nat.add(U32.to_nat(a), U32.to_nat(b)), k, hk, h))

# ---- 2j and 2j + 1 ----------------------------------------------------------------

# The literal 2 on the left: U32.mul walks its bits, and adds the shifted j once.
def mul2(+j: U32) -> {(2 * j : U32) == U32.shl(j) : U32}:
  match j:
    case U32{+w}:
      Equal.cong(Word(32n), U32, x => U32{x}, Word.add(32n, Word.zero(32n), Word.shl(32n, w)), Word.shl(32n, w), WSp.add_zero_left(32n, Word.shl(32n, w)))

def rw_pow_lt(+x: Nat, +k: Nat, +h: {Nat.is_lt(x, O.pow2n(k)) == True{} : Bool}) -> {Nat.is_lt(x, F.spec_common__pow2(k)) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__pow2(k), O.pow2n(k), CT.pow2_eq(k)) : {Nat.is_lt(x, _) == True{} : Bool}
  h

def dbl_val(+j: U32, +k: Nat, +hk: {Nat.is_lt(k, 32n) == True{} : Bool},
    +h: {Nat.is_lt(Nat.double(U32.to_nat(j)), O.pow2n(k)) == True{} : Bool})
    -> {U32.to_nat((2 * j : U32)) == Nat.double(U32.to_nat(j)) : Nat}:
  %Equal.sym(U32, (2 * j : U32), U32.shl(j), mul2(j)) : {U32.to_nat(_) == Nat.double(U32.to_nat(j)) : Nat}
  F.u32__shl_value(j, k, F.nat__lt_le(k, 32n, hk), rw_pow_lt(Nat.double(U32.to_nat(j)), k, h))

# ---- halves --------------------------------------------------------------------------

law h2_bit:
  for +b: Bool
  for +y: Nat
  {CT.h2(Nat.add(F.spec_numeric__bit_value(b), Nat.double(y))) == y : Nat}
def h2_bit(b, y):
  match b y:
    case False{} 0n: {==}
    case False{} 1n+ +q:
      %Equal.sym(Nat, CT.h2(Nat.add(F.spec_numeric__bit_value(False{}), Nat.double(q))), q, h2_bit(False{}, q)) : {1n+_ == 1n+q : Nat}
      {==}
    case True{} 0n: {==}
    case True{} 1n+ +q:
      %Equal.sym(Nat, CT.h2(Nat.add(F.spec_numeric__bit_value(True{}), Nat.double(q))), q, h2_bit(True{}, q)) : {1n+_ == 1n+q : Nat}
      {==}

# x >> 1 is the half of x.
def shr1(+x: U32) -> {U32.to_nat(U32.shrn(x, 1n)) == CT.h2(U32.to_nat(x)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(x), Nat.add(F.spec_numeric__bit_value(F.u32__low_bit(x)), Nat.double(U32.to_nat(U32.shr(x)))), F.u32__shr_split(x)) : {U32.to_nat(U32.shr(x)) == CT.h2(_) : Nat}
  Equal.sym(Nat, CT.h2(Nat.add(F.spec_numeric__bit_value(F.u32__low_bit(x)), Nat.double(U32.to_nat(U32.shr(x))))), U32.to_nat(U32.shr(x)),
    h2_bit(F.u32__low_bit(x), U32.to_nat(U32.shr(x))))

# ---- comparisons --------------------------------------------------------------------------

def lt_nat(+a: U32, +b: U32) -> {U32.is_lt(a, b) == Nat.is_lt(U32.to_nat(a), U32.to_nat(b)) : Bool}: F.u32__is_lt_nat(a, b)

def le_nat(+a: U32, +b: U32) -> {U32.is_le(a, b) == Nat.is_le(U32.to_nat(a), U32.to_nat(b)) : Bool}:
  %Equal.sym(Cmp, U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), F.u32__u32_cmp(a, b)) : {Cmp.is_le(_) == Nat.is_le(U32.to_nat(a), U32.to_nat(b)) : Bool}
  {==}

def MD_add_succ(+x: Nat) -> {Nat.add(x, 1n) == 1n+Nat.add(x, 0n) : Nat}: F.nat__add_succ(x, 0n)

def NA_add1(+x: Nat) -> {Nat.add(x, 1n) == 1n+x : Nat}:
  %Equal.sym(Nat, Nat.add(x, 1n), 1n+Nat.add(x, 0n), MD_add_succ(x)) : {_ == 1n+x : Nat}
  Equal.cong(Nat, Nat, y => 1n+y, Nat.add(x, 0n), x, F.nat__add_zero(x))

# (b - a) + 1 <= 2^k from b - a <= b < 2^k.
def span_bound(+u: Nat, +s: Nat, +b: Nat, +k: Nat, +e: {u == s : Nat},
    +hs: {Nat.is_le(s, b) == True{} : Bool}, +hb: {Nat.is_lt(b, O.pow2n(k)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(u, U32.to_nat(1)), O.pow2n(k)) == True{} : Bool}:
  %Equal.sym(Nat, u, s, e) : {Nat.is_le(Nat.add(_, 1n), O.pow2n(k)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(s, 1n), 1n+s, NA_add1(s)) : {Nat.is_le(_, O.pow2n(k)) == True{} : Bool}
  F.nat__lt_succ_le_succ(s, O.pow2n(k), F.nat__le_lt_trans(s, b, O.pow2n(k), hs, hb))

# b - a + 1 for a <= b <= 2^k - 1.
def span_val(+a: U32, +b: U32, +k: Nat, +hk: {Nat.is_lt(k, 32n) == True{} : Bool},
    +hab: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool},
    +hb: {Nat.is_lt(U32.to_nat(b), O.pow2n(k)) == True{} : Bool})
    -> {U32.to_nat((b - a + 1 : U32)) == 1n+Nat.sub(U32.to_nat(b), U32.to_nat(a)) : Nat}:
  +e1 = F.u32__sub_nat(b, a, hab)
  +hs = F.nat__le_trans(Nat.sub(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(b), U32.to_nat(b), CT.sub_le(U32.to_nat(b), U32.to_nat(a)), F.nat__le_refl(U32.to_nat(b)))
  +h1 = span_bound(U32.to_nat(U32.sub(b, a)), Nat.sub(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(b), k, e1, hs, hb)
  %Equal.sym(Nat, U32.to_nat(U32.add(U32.sub(b, a), 1)), Nat.add(U32.to_nat(U32.sub(b, a)), U32.to_nat(1)), add_nat(U32.sub(b, a), 1, k, hk, h1)) :
    {_ == 1n+Nat.sub(U32.to_nat(b), U32.to_nat(a)) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.sub(b, a)), Nat.sub(U32.to_nat(b), U32.to_nat(a)), e1) : {Nat.add(_, 1n) == 1n+Nat.sub(U32.to_nat(b), U32.to_nat(a)) : Nat}
  NA_add1(Nat.sub(U32.to_nat(b), U32.to_nat(a)))
