import Base
import ../compact/found.bend as F
import ../../proofs/nat_order.bend as Order

# U32 multiplication and division as Nat arithmetic, for products and
# quotients that do not wrap. The bounds are relative (`< sc(n, 1)`, the
# symbolic 2^n of found.bend), never a closed large number.

def uw(+n: Nat, +w: Word(n)) -> Nat: F.u32alg__uw(n, w)
def sc1(+n: Nat) -> Nat: F.u32alg__sc(n, 1n)
# sc1 unfolded for a symbolic n: instantiated at 32n, it relates the two spellings of 2^32 without
# evaluating either.
def sc1_is(+n: Nat) -> {sc1(n) == F.spec_numeric__scale_binary(n, 1n) : Nat}: {==}

# ---- Nat algebra -------------------------------------------------------------------------

law mul_dbl:
  for +u: Nat
  for +B: Nat
  {Nat.mul(u, Nat.double(B)) == Nat.mul(Nat.double(u), B) : Nat}
def mul_dbl(u, B):
  match u:
    case 0n: {==}
    case 1n+ +v:
      %mul_dbl(v, B) : {Nat.add(Nat.double(B), Nat.mul(v, Nat.double(B))) == Nat.add(B, Nat.add(B, _)) : Nat}
      %Equal.sym(Nat, Nat.double(B), Nat.add(B, B), F.lru_nat_algebra__double_self(B)) : {Nat.add(_, Nat.mul(v, Nat.double(B))) == Nat.add(B, Nat.add(B, Nat.mul(v, Nat.double(B)))) : Nat}
      F.nat__add_assoc(B, B, Nat.mul(v, Nat.double(B)))

def le_add_l(+A: Nat, +X: Nat, +P: Nat, +h: {Nat.is_lt(Nat.add(A, X), P) == True{} : Bool}) -> {Nat.is_lt(X, P) == True{} : Bool}:
  F.nat__le_lt_trans(X, Nat.add(A, X), P, Order.left_below_sum(A, X), h)

def le_add_r(+A: Nat, +X: Nat, +P: Nat, +h: {Nat.is_lt(Nat.add(A, X), P) == True{} : Bool}) -> {Nat.is_lt(A, P) == True{} : Bool}:
  F.nat__le_lt_trans(A, Nat.add(A, X), P, Order.below_sum(A, X), h)

# ---- shifting b left inside a product ------------------------------------------------------

def shl_exact(+n: Nat, +b: Word(n), +h: {Nat.is_lt(Nat.double(uw(n, b)), sc1(n)) == True{} : Bool})
    -> {uw(n, Word.shl(n, b)) == Nat.double(uw(n, b)) : Nat}:
  F.lru_word_shift__exact(n, b, h)

def shl_mul(+n: Nat, +b: Word(n), +u: Nat, +h: {Nat.is_lt(Nat.mul(Nat.double(u), uw(n, b)), sc1(n)) == True{} : Bool})
    -> {Nat.mul(u, uw(n, Word.shl(n, b))) == Nat.mul(Nat.double(u), uw(n, b)) : Nat}:
  match u:
    case 0n: {==}
    case 1n+ +v:
      +B = uw(n, b)
      # 2B <= B + (B + 2vB) = (2 + 2v) B
      +le = Order.add_left(B, B, Nat.add(B, Nat.mul(Nat.double(v), B)), Order.below_sum(B, Nat.mul(Nat.double(v), B)))
      +h2 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(B, Nat.add(B, Nat.mul(Nat.double(v), B)))) == True{} : Bool}, Nat.add(B, B), Nat.double(B), Equal.sym(Nat, Nat.double(B), Nat.add(B, B), F.lru_nat_algebra__double_self(B)), le)
      +ex = shl_exact(n, b, F.nat__le_lt_trans(Nat.double(B), Nat.add(B, Nat.add(B, Nat.mul(Nat.double(v), B))), sc1(n), h2, h))
      %Equal.sym(Nat, uw(n, Word.shl(n, b)), Nat.double(B), ex) : {Nat.mul(1n+v, _) == Nat.mul(Nat.double(1n+v), B) : Nat}
      mul_dbl(1n+v, B)

# ---- the multiplication loop -----------------------------------------------------------------

def add_exact(+n: Nat, +a: Word(n), +b: Word(n), +h: {Nat.is_lt(Nat.add(uw(n, a), uw(n, b)), sc1(n)) == True{} : Bool})
    -> {uw(n, Word.add(n, a, b)) == Nat.add(uw(n, a), uw(n, b)) : Nat}:
  F.lru_addition_bounds__no_wrap(n, uw(n, Word.add(n, a, b)), Nat.add(uw(n, a), uw(n, b)), F.lru_addition__carry_out(n, a, b, False{}), F.u32alg__cons(n, a, b), h)

law mul_go_val:
  for +n: Nat
  for +m: Nat
  for +a: Word(m)
  for +b: Word(n)
  for +acc: Word(n)
  for +h: {Nat.is_lt(Nat.add(uw(n, acc), Nat.mul(uw(m, a), uw(n, b))), sc1(n)) == True{} : Bool}
  {uw(n, Word.mul.go(n, m, a, b, acc)) == Nat.add(uw(n, acc), Nat.mul(uw(m, a), uw(n, b))) : Nat}
def mul_go_val(n, m, a, b, acc, h):
  match m a:
    case 0n WNil{}: Equal.sym(Nat, Nat.add(uw(n, acc), 0n), uw(n, acc), F.nat__add_zero(uw(n, acc)))
    case 1n+ +p WCon{False{}, +at}:
      +u = uw(p, at)
      +B = uw(n, b)
      +A = uw(n, acc)
      +e = shl_mul(n, b, u, le_add_l(A, Nat.mul(Nat.double(u), B), sc1(n), h))
      +h1 = F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A, z), sc1(n)) == True{} : Bool}, Nat.mul(Nat.double(u), B), Nat.mul(u, uw(n, Word.shl(n, b))), Equal.sym(Nat, Nat.mul(u, uw(n, Word.shl(n, b))), Nat.mul(Nat.double(u), B), e), h)
      %e : {uw(n, Word.mul.go(n, p, at, Word.shl(n, b), acc)) == Nat.add(A, _) : Nat}
      mul_go_val(n, p, at, Word.shl(n, b), acc, h1)
    case 1n+ +p WCon{True{}, +at}:
      +u = uw(p, at)
      +B = uw(n, b)
      +A = uw(n, acc)
      # h : A + (B + 2uB) < 2^n
      +hAB = F.logic__subst(Nat, z => {Nat.is_lt(z, sc1(n)) == True{} : Bool}, Nat.add(A, Nat.add(B, Nat.mul(Nat.double(u), B))), Nat.add(Nat.add(A, B), Nat.mul(Nat.double(u), B)), Equal.sym(Nat, Nat.add(Nat.add(A, B), Nat.mul(Nat.double(u), B)), Nat.add(A, Nat.add(B, Nat.mul(Nat.double(u), B))), F.nat__add_assoc(A, B, Nat.mul(Nat.double(u), B))), h)
      +ea = add_exact(n, acc, b, le_add_r(Nat.add(A, B), Nat.mul(Nat.double(u), B), sc1(n), hAB))
      +e = shl_mul(n, b, u, le_add_l(Nat.add(A, B), Nat.mul(Nat.double(u), B), sc1(n), hAB))
      +h1 = F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, Nat.mul(u, uw(n, Word.shl(n, b)))), sc1(n)) == True{} : Bool}, Nat.add(A, B), uw(n, Word.add(n, acc, b)), Equal.sym(Nat, uw(n, Word.add(n, acc, b)), Nat.add(A, B), ea),
        F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(Nat.add(A, B), z), sc1(n)) == True{} : Bool}, Nat.mul(Nat.double(u), B), Nat.mul(u, uw(n, Word.shl(n, b))), Equal.sym(Nat, Nat.mul(u, uw(n, Word.shl(n, b))), Nat.mul(Nat.double(u), B), e), hAB))
      %Equal.sym(Nat, uw(n, Word.mul.go(n, p, at, Word.shl(n, b), Word.add(n, acc, b))), Nat.add(uw(n, Word.add(n, acc, b)), Nat.mul(u, uw(n, Word.shl(n, b)))), mul_go_val(n, p, at, Word.shl(n, b), Word.add(n, acc, b), h1)) : {_ == Nat.add(A, Nat.add(B, Nat.mul(Nat.double(u), B))) : Nat}
      %Equal.sym(Nat, uw(n, Word.add(n, acc, b)), Nat.add(A, B), ea) : {Nat.add(_, Nat.mul(u, uw(n, Word.shl(n, b)))) == Nat.add(A, Nat.add(B, Nat.mul(Nat.double(u), B))) : Nat}
      %Equal.sym(Nat, Nat.mul(u, uw(n, Word.shl(n, b))), Nat.mul(Nat.double(u), B), e) : {Nat.add(Nat.add(A, B), _) == Nat.add(A, Nat.add(B, Nat.mul(Nat.double(u), B))) : Nat}
      F.nat__add_assoc(A, B, Nat.mul(Nat.double(u), B))

# Generic width: a product bounded by some n-bit word does not wrap.
def mul_le_w(+n: Nat, +a: Word(n), +b: Word(n), +z: Word(n),
    +h: {Nat.is_le(Nat.mul(uw(n, a), uw(n, b)), uw(n, z)) == True{} : Bool})
    -> {uw(n, Word.mul(n, a, b)) == Nat.mul(uw(n, a), uw(n, b)) : Nat}:
  +M = Nat.mul(uw(n, a), uw(n, b))
  +hl = F.nat__le_lt_trans(M, uw(n, z), sc1(n), h, F.u32__WB_unsigned(n, z))
  +h1 = F.logic__subst(Nat, q => {Nat.is_lt(Nat.add(q, M), sc1(n)) == True{} : Bool}, 0n, uw(n, Word.zero(n)), Equal.sym(Nat, uw(n, Word.zero(n)), 0n, F.u32alg__uw_zero(n)), hl)
  %Equal.sym(Nat, uw(n, Word.mul.go(n, n, a, b, Word.zero(n))), Nat.add(uw(n, Word.zero(n)), M), mul_go_val(n, n, a, b, Word.zero(n), h1)) : {_ == M : Nat}
  %Equal.sym(Nat, uw(n, Word.zero(n)), 0n, F.u32alg__uw_zero(n)) : {Nat.add(_, M) == M : Nat}
  {==}

# U32: a product bounded by the value of some word does not wrap.
def mul_le(+x: U32, +y: U32, +c: U32, +h: {Nat.is_le(Nat.mul(U32.to_nat(x), U32.to_nat(y)), U32.to_nat(c)) == True{} : Bool})
    -> {U32.to_nat(U32.mul(x, y)) == Nat.mul(U32.to_nat(x), U32.to_nat(y)) : Nat}:
  match x y c:
    case U32{+a} U32{+b} U32{+z}:
      +ta = U32.to_nat(U32{a})
      +tb = U32.to_nat(U32{b})
      +ua = uw(32n, a)
      +ub = uw(32n, b)
      +prod = Equal.trans(Nat, Nat.mul(ta, tb), Nat.mul(ua, tb), Nat.mul(ua, ub),
        Equal.cong(Nat, Nat, q => Nat.mul(q, tb), ta, ua, F.u32__to_nat_word(a)),
        Equal.cong(Nat, Nat, q => Nat.mul(ua, q), tb, ub, F.u32__to_nat_word(b)))
      +hz = F.logic__subst(Nat, q => {Nat.is_le(q, uw(32n, z)) == True{} : Bool}, Nat.mul(ta, tb), Nat.mul(ua, ub), prod,
        F.logic__subst(Nat, q => {Nat.is_le(Nat.mul(ta, tb), q) == True{} : Bool}, U32.to_nat(U32{z}), uw(32n, z), F.u32__to_nat_word(z), h))
      Equal.trans(Nat, U32.to_nat(U32{Word.mul(32n, a, b)}), uw(32n, Word.mul(32n, a, b)), Nat.mul(ta, tb),
        F.u32__to_nat_word(Word.mul(32n, a, b)),
        Equal.trans(Nat, uw(32n, Word.mul(32n, a, b)), Nat.mul(ua, ub), Nat.mul(ta, tb),
          mul_le_w(32n, a, b, z, hz), Equal.sym(Nat, Nat.mul(ta, tb), Nat.mul(ua, ub), prod)))

# U32: a product below 2^32 does not wrap (no bounding word needed: any buffer length, n <= NMAX).
def mul_lt32(+x: U32, +y: U32, +h: {Nat.is_lt(Nat.mul(U32.to_nat(x), U32.to_nat(y)), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.mul(x, y)) == Nat.mul(U32.to_nat(x), U32.to_nat(y)) : Nat}:
  match x y:
    case U32{+a} U32{+b}:
      +ta = U32.to_nat(U32{a})
      +tb = U32.to_nat(U32{b})
      +ua = uw(32n, a)
      +ub = uw(32n, b)
      +M = Nat.mul(ua, ub)
      +prod = Equal.trans(Nat, Nat.mul(ta, tb), Nat.mul(ua, tb), Nat.mul(ua, ub),
        Equal.cong(Nat, Nat, q => Nat.mul(q, tb), ta, ua, F.u32__to_nat_word(a)),
        Equal.cong(Nat, Nat, q => Nat.mul(ua, q), tb, ub, F.u32__to_nat_word(b)))
      +hs = F.logic__subst(Nat, q => {Nat.is_lt(q, sc1(32n)) == True{} : Bool}, Nat.mul(ta, tb), M, prod,
        F.logic__subst(Nat, q => {Nat.is_lt(Nat.mul(ta, tb), q) == True{} : Bool}, F.spec_common__pow2(32n), sc1(32n),
          Equal.trans(Nat, F.spec_common__pow2(32n), F.spec_numeric__scale_binary(32n, 1n), sc1(32n), F.u32__pow2_scale(32n),
            Equal.sym(Nat, sc1(32n), F.spec_numeric__scale_binary(32n, 1n), sc1_is(32n))), h))
      +h0 = F.logic__subst(Nat, q => {Nat.is_lt(q, sc1(32n)) == True{} : Bool}, M, Nat.add(0n, M), {==}, hs)
      +h1 = F.logic__subst(Nat, q => {Nat.is_lt(Nat.add(q, M), sc1(32n)) == True{} : Bool}, 0n, uw(32n, Word.zero(32n)), Equal.sym(Nat, uw(32n, Word.zero(32n)), 0n, F.u32alg__uw_zero(32n)), h0)
      +ew = Equal.trans(Nat, uw(32n, Word.mul.go(32n, 32n, a, b, Word.zero(32n))), Nat.add(uw(32n, Word.zero(32n)), M), M,
        mul_go_val(32n, 32n, a, b, Word.zero(32n), h1), Equal.cong(Nat, Nat, q => Nat.add(q, M), uw(32n, Word.zero(32n)), 0n, F.u32alg__uw_zero(32n)))
      Equal.trans(Nat, U32.to_nat(U32{Word.mul(32n, a, b)}), uw(32n, Word.mul(32n, a, b)), Nat.mul(ta, tb),
        F.u32__to_nat_word(Word.mul(32n, a, b)),
        Equal.trans(Nat, uw(32n, Word.mul(32n, a, b)), M, Nat.mul(ta, tb), ew, Equal.sym(Nat, Nat.mul(ta, tb), M, prod)))

# ---- division ----------------------------------------------------------------------------

def cmp_ge_t(+c: Cmp, +e: {Cmp.is_ge(c) == True{} : Bool}) -> {Cmp.is_lt(c) == False{} : Bool}:
  match c:
    case LT{}: Empty.absurd({Cmp.is_lt(LT{}) == False{} : Bool}, F.logic__false_true(e))
    case EQ{}: {==}
    case GT{}: {==}

def cmp_ge_f(+c: Cmp, +e: {Cmp.is_ge(c) == False{} : Bool}) -> {Cmp.is_lt(c) == True{} : Bool}:
  match c:
    case LT{}: {==}
    case EQ{}: Empty.absurd({Cmp.is_lt(EQ{}) == True{} : Bool}, F.logic__true_false(e))
    case GT{}: Empty.absurd({Cmp.is_lt(GT{}) == True{} : Bool}, F.logic__true_false(e))

# Shifting a word whose value is below that of a word with a clear top bit
# loses no bit (generic width 1 + p, so no closed 2^32 appears).
law shl_out_go:
  for +p: Nat
  for +b: Bool
  for +t: Word(p)
  for +c: Bool
  {Word.shl.out.con(p, c, Word.shl.out(p, b, t)) == (F.lru_word_shift__carry(p, b, t), WCon{c, Word.shl.put(p, b, t)}) : Bool & Word(1n+p)}
def shl_out_go(p, b, t, c):
  match p t:
    case 0n WNil{}: {==}
    case 1n+ +q WCon{+b2, +t2}:
      %Equal.sym(Bool & Word(1n+q), Word.shl.out(1n+q, b, WCon{b2, t2}), (F.lru_word_shift__carry(q, b2, t2), WCon{b, Word.shl.put(q, b2, t2)}), shl_out_go(q, b2, t2, b)) :
        {Word.shl.out.con(1n+q, c, _) == (F.lru_word_shift__carry(q, b2, t2), WCon{c, WCon{b, Word.shl.put(q, b2, t2)}}) : Bool & Word(2n+q)}
      {==}

law shl_out_nc:
  for +p: Nat
  for +c: Bool
  for +w: Word(1n+p)
  {Word.shl.out(1n+p, c, w) == (F.lru_word_shift__carry(1n+p, c, w), Word.shl.put(1n+p, c, w)) : Bool & Word(1n+p)}
def shl_out_nc(p, c, w):
  match w:
    case WCon{+b, +t}: shl_out_go(p, b, t, c)


def carry_t(+p: Nat, +c: Bool, +w: Word(1n+p), +v: Word(p),
    +h: {Nat.is_lt(uw(1n+p, w), uw(1n+p, Word.shr.pad(p, v))) == True{} : Bool},
    +ek: {F.lru_word_shift__carry(1n+p, c, w) == True{} : Bool}) -> Empty:
  +U = uw(1n+p, w)
  +hv = F.logic__subst(Nat, z => {Nat.is_lt(U, z) == True{} : Bool}, uw(1n+p, Word.shr.pad(p, v)), uw(p, v), F.u32__pad_value(p, v), h)
  +hU = F.nat__lt_trans(U, uw(p, v), sc1(p), hv, F.u32__WB_unsigned(p, v))
  +rhs = F.nat__double_lt_bit(c, U, sc1(p), hU)
  +cons = F.lru_word_shift__conservation(1n+p, c, w)
  +cons1 = F.logic__subst(Bool, k => {Nat.add(uw(1n+p, Word.shl.put(1n+p, c, w)), F.spec_numeric__scale_binary(1n+p, F.spec_numeric__bit_value(k))) == Nat.add(F.spec_numeric__bit_value(c), Nat.double(U)) : Nat},
    F.lru_word_shift__carry(1n+p, c, w), True{}, ek, cons)
  +ge = F.logic__subst(Nat, z => {Nat.is_le(sc1(1n+p), z) == True{} : Bool}, Nat.add(uw(1n+p, Word.shl.put(1n+p, c, w)), sc1(1n+p)), Nat.add(F.spec_numeric__bit_value(c), Nat.double(U)), cons1,
    Order.left_below_sum(uw(1n+p, Word.shl.put(1n+p, c, w)), sc1(1n+p)))
  F.nat__lt_ne(sc1(1n+p), sc1(1n+p), F.nat__le_lt_trans(sc1(1n+p), Nat.add(F.spec_numeric__bit_value(c), Nat.double(U)), sc1(1n+p), ge, rhs), {==})

def carry_go(+p: Nat, +c: Bool, +w: Word(1n+p), +v: Word(p),
    +h: {Nat.is_lt(uw(1n+p, w), uw(1n+p, Word.shr.pad(p, v))) == True{} : Bool},
    +k: Bool, +ek: {F.lru_word_shift__carry(1n+p, c, w) == k : Bool}) -> {F.lru_word_shift__carry(1n+p, c, w) == False{} : Bool}:
  match k:
    case False{}: ek
    case True{}: Empty.absurd({F.lru_word_shift__carry(1n+p, c, w) == False{} : Bool}, carry_t(p, c, w, v, h, ek))

# A shift of a value below that of a word with a clear top bit loses no bit.
def shl_nc(+p: Nat, +c: Bool, +w: Word(1n+p), +v: Word(p),
    +h: {Nat.is_lt(uw(1n+p, w), uw(1n+p, Word.shr.pad(p, v))) == True{} : Bool})
    -> {Word.shl.out(1n+p, c, w) == (False{}, Word.shl.put(1n+p, c, w)) : Bool & Word(1n+p)}:
  %carry_go(p, c, w, v, h, F.lru_word_shift__carry(1n+p, c, w), {==}) :
    {Word.shl.out(1n+p, c, w) == (_, Word.shl.put(1n+p, c, w)) : Bool & Word(1n+p)}
  shl_out_nc(p, c, w)

def put_val(+p: Nat, +c: Bool, +w: Word(1n+p), +v: Word(p),
    +h: {Nat.is_lt(uw(1n+p, w), uw(1n+p, Word.shr.pad(p, v))) == True{} : Bool})
    -> {uw(1n+p, Word.shl.put(1n+p, c, w)) == Nat.add(F.spec_numeric__bit_value(c), Nat.double(uw(1n+p, w))) : Nat}:
  +cons = F.lru_word_shift__conservation(1n+p, c, w)
  +c0 = F.logic__subst(Bool, k => {Nat.add(uw(1n+p, Word.shl.put(1n+p, c, w)), F.spec_numeric__scale_binary(1n+p, F.spec_numeric__bit_value(k))) == Nat.add(F.spec_numeric__bit_value(c), Nat.double(uw(1n+p, w))) : Nat},
    F.lru_word_shift__carry(1n+p, c, w), False{}, carry_go(p, c, w, v, h, F.lru_word_shift__carry(1n+p, c, w), {==}), cons)
  %F.nat__add_zero(uw(1n+p, Word.shl.put(1n+p, c, w))) : {_ == Nat.add(F.spec_numeric__bit_value(c), Nat.double(uw(1n+p, w))) : Nat}
  %F.u32alg__sc_zero(1n+p) : {Nat.add(uw(1n+p, Word.shl.put(1n+p, c, w)), _) == Nat.add(F.spec_numeric__bit_value(c), Nat.double(uw(1n+p, w))) : Nat}
  c0

law mul_dbl_l:
  for +Q: Nat
  for +B: Nat
  {Nat.mul(Nat.double(Q), B) == Nat.double(Nat.mul(Q, B)) : Nat}
def mul_dbl_l(Q, B):
  match Q:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Nat.mul(Nat.double(q), B), Nat.double(Nat.mul(q, B)), mul_dbl_l(q, B)) : {Nat.add(B, Nat.add(B, _)) == Nat.double(Nat.add(B, Nat.mul(q, B))) : Nat}
      %Equal.sym(Nat, Nat.double(Nat.add(B, Nat.mul(q, B))), Nat.add(Nat.double(B), Nat.double(Nat.mul(q, B))), Equal.sym(Nat, Nat.add(Nat.double(B), Nat.double(Nat.mul(q, B))), Nat.double(Nat.add(B, Nat.mul(q, B))), F.nat__add_double(B, Nat.mul(q, B)))) :
        {Nat.add(B, Nat.add(B, Nat.double(Nat.mul(q, B)))) == _ : Nat}
      %Equal.sym(Nat, Nat.double(B), Nat.add(B, B), F.lru_nat_algebra__double_self(B)) : {Nat.add(B, Nat.add(B, Nat.double(Nat.mul(q, B)))) == Nat.add(_, Nat.double(Nat.mul(q, B))) : Nat}
      Equal.sym(Nat, Nat.add(Nat.add(B, B), Nat.double(Nat.mul(q, B))), Nat.add(B, Nat.add(B, Nat.double(Nat.mul(q, B)))), F.nat__add_assoc(B, B, Nat.double(Nat.mul(q, B))))

# 2M + (c + 2R) == c + 2 (M + R)
def alg2(+M: Nat, +c: Nat, +R: Nat) -> {Nat.add(Nat.double(M), Nat.add(c, Nat.double(R))) == Nat.add(c, Nat.double(Nat.add(M, R))) : Nat}:
  %F.nat__add_double(M, R) : {Nat.add(Nat.double(M), Nat.add(c, Nat.double(R))) == Nat.add(c, _) : Nat}
  F.lru_nat_algebra__add_swap(Nat.double(M), c, Nat.double(R))

# (B + M2) + (S - B) == M2 + S, for B <= S
def alg1(+B: Nat, +M2: Nat, +S: Nat, +le: {Nat.is_le(B, S) == True{} : Bool}) -> {Nat.add(Nat.add(B, M2), Nat.sub(S, B)) == Nat.add(M2, S) : Nat}:
  %Equal.sym(Nat, Nat.add(B, M2), Nat.add(M2, B), F.nat__add_comm(B, M2)) : {Nat.add(_, Nat.sub(S, B)) == Nat.add(M2, S) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(M2, B), Nat.sub(S, B)), Nat.add(M2, Nat.add(B, Nat.sub(S, B))), F.nat__add_assoc(M2, B, Nat.sub(S, B))) : {_ == Nat.add(M2, S) : Nat}
  %Equal.sym(Nat, Nat.add(B, Nat.sub(S, B)), S, F.nat__sub_add(S, B, le)) : {Nat.add(M2, _) == Nat.add(M2, S) : Nat}
  {==}

def ge_le(+s: U32, +b: U32, +eg: {U32.is_ge(s, b) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(b), U32.to_nat(s)) == True{} : Bool}:
  F.nat__not_lt_le(U32.to_nat(s), U32.to_nat(b), cmp_ge_t(Nat.cmp(U32.to_nat(s), U32.to_nat(b)),
    F.logic__subst(Cmp, k => {Cmp.is_ge(k) == True{} : Bool}, U32.cmp(s, b), Nat.cmp(U32.to_nat(s), U32.to_nat(b)), F.u32__u32_cmp(s, b), eg)))

def ge_lt(+s: U32, +b: U32, +eg: {U32.is_ge(s, b) == False{} : Bool}) -> {Nat.is_lt(U32.to_nat(s), U32.to_nat(b)) == True{} : Bool}:
  cmp_ge_f(Nat.cmp(U32.to_nat(s), U32.to_nat(b)),
    F.logic__subst(Cmp, k => {Cmp.is_ge(k) == False{} : Bool}, U32.cmp(s, b), Nat.cmp(U32.to_nat(s), U32.to_nat(b)), F.u32__u32_cmp(s, b), eg))

def bc(+c: Bool) -> Nat: F.spec_numeric__bit_value(c)

def teq(+B: Nat, +Q: Nat, +R: Nat, +c: Bool, +ts: Nat, +tsub: Nat,
    +es: {ts == Nat.add(bc(c), Nat.double(R)) : Nat},
    +le: {Nat.is_le(B, Nat.add(bc(c), Nat.double(R))) == True{} : Bool},
    +esub: {tsub == Nat.sub(ts, B) : Nat})
    -> {Nat.add(Nat.add(B, Nat.mul(Nat.double(Q), B)), tsub) == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(Q, B), R))) : Nat}:
  +S = Nat.add(bc(c), Nat.double(R))
  %Equal.sym(Nat, tsub, Nat.sub(ts, B), esub) :
    {Nat.add(Nat.add(B, Nat.mul(Nat.double(Q), B)), _) == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(Q, B), R))) : Nat}
  %Equal.sym(Nat, ts, S, es) :
    {Nat.add(Nat.add(B, Nat.mul(Nat.double(Q), B)), Nat.sub(_, B)) == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(Q, B), R))) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(B, Nat.mul(Nat.double(Q), B)), Nat.sub(S, B)), Nat.add(Nat.mul(Nat.double(Q), B), S), alg1(B, Nat.mul(Nat.double(Q), B), S, le)) :
    {_ == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(Q, B), R))) : Nat}
  %Equal.sym(Nat, Nat.mul(Nat.double(Q), B), Nat.double(Nat.mul(Q, B)), mul_dbl_l(Q, B)) :
    {Nat.add(_, S) == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(Q, B), R))) : Nat}
  alg2(Nat.mul(Q, B), bc(c), R)

def tbound(+B: Nat, +R: Nat, +c: Bool, +ts: Nat, +tsub: Nat,
    +es: {ts == Nat.add(bc(c), Nat.double(R)) : Nat},
    +le: {Nat.is_le(B, Nat.add(bc(c), Nat.double(R))) == True{} : Bool},
    +esub: {tsub == Nat.sub(ts, B) : Nat},
    +hr: {Nat.is_lt(R, B) == True{} : Bool})
    -> {Nat.is_lt(tsub, B) == True{} : Bool}:
  +S = Nat.add(bc(c), Nat.double(R))
  +lt2 = F.logic__subst(Nat, z => {Nat.is_lt(S, z) == True{} : Bool}, Nat.double(B), Nat.add(B, B), F.lru_nat_algebra__double_self(B), F.nat__double_lt_bit(c, R, B, hr))
  %Equal.sym(Nat, tsub, Nat.sub(ts, B), esub) : {Nat.is_lt(_, B) == True{} : Bool}
  %Equal.sym(Nat, ts, S, es) : {Nat.is_lt(Nat.sub(_, B), B) == True{} : Bool}
  F.nat__sub_lt(S, B, B, le, lt2)

def feq(+B: Nat, +Q: Nat, +R: Nat, +c: Bool, +ts: Nat, +es: {ts == Nat.add(bc(c), Nat.double(R)) : Nat})
    -> {Nat.add(Nat.mul(Nat.double(Q), B), ts) == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(Q, B), R))) : Nat}:
  %Equal.sym(Nat, ts, Nat.add(bc(c), Nat.double(R)), es) :
    {Nat.add(Nat.mul(Nat.double(Q), B), _) == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(Q, B), R))) : Nat}
  %Equal.sym(Nat, Nat.mul(Nat.double(Q), B), Nat.double(Nat.mul(Q, B)), mul_dbl_l(Q, B)) :
    {Nat.add(_, Nat.add(bc(c), Nat.double(R))) == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(Q, B), R))) : Nat}
  alg2(Nat.mul(Q, B), bc(c), R)

law fin_ok:
  for +p: Nat
  for +q: Word(p)
  for +s: U32
  for +b: U32
  for +g: Bool
  for +eg: {U32.is_ge(s, b) == g : Bool}
  for +c: Bool
  for +R: Nat
  for +es: {U32.to_nat(s) == Nat.add(bc(c), Nat.double(R)) : Nat}
  for +hr: {Nat.is_lt(R, U32.to_nat(b)) == True{} : Bool}
  {Nat.add(Nat.mul(uw(1n+p, Pair.fst(Word(1n+p), U32, U32.divmod.go.fin(p, q, s, b, g))), U32.to_nat(b)), U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.fin(p, q, s, b, g))))
    == Nat.add(bc(c), Nat.double(Nat.add(Nat.mul(uw(p, q), U32.to_nat(b)), R))) : Nat}
  & {Nat.is_lt(U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.fin(p, q, s, b, g))), U32.to_nat(b)) == True{} : Bool}
def fin_ok(p, q, s, b, g, eg, c, R, es, hr):
  match g:
    case True{}:
      +B = U32.to_nat(b)
      +le = F.logic__subst(Nat, z => {Nat.is_le(B, z) == True{} : Bool}, U32.to_nat(s), Nat.add(bc(c), Nat.double(R)), es, ge_le(s, b, eg))
      +esub = F.u32__sub_nat(s, b, ge_le(s, b, eg))
      (teq(B, uw(p, q), R, c, U32.to_nat(s), U32.to_nat(U32.sub(s, b)), es, le, esub),
       tbound(B, R, c, U32.to_nat(s), U32.to_nat(U32.sub(s, b)), es, le, esub, hr))
    case False{}:
      (feq(U32.to_nat(b), uw(p, q), R, c, U32.to_nat(s), es), ge_lt(s, b, eg))

def DQ(m: Nat, a: Word(m), +b: U32) -> Word(m): Pair.fst(Word(m), U32, U32.divmod.go(m, a, b))
def DR(m: Nat, a: Word(m), +b: U32) -> U32: Pair.snd(Word(m), U32, U32.divmod.go(m, a, b))

def lt31(+rw: Word(32n), +b: U32, +v: Word(31n), +eb: {b == U32{Word.shr.pad(31n, v)} : U32},
    +hr: {Nat.is_lt(U32.to_nat(U32{rw}), U32.to_nat(b)) == True{} : Bool})
    -> {Nat.is_lt(uw(32n, rw), uw(32n, Word.shr.pad(31n, v))) == True{} : Bool}:
  %Equal.sym(Nat, uw(32n, rw), U32.to_nat(U32{rw}), Equal.sym(Nat, U32.to_nat(U32{rw}), uw(32n, rw), F.u32__to_nat_word(rw))) : {Nat.is_lt(_, uw(32n, Word.shr.pad(31n, v))) == True{} : Bool}
  %Equal.sym(Nat, uw(32n, Word.shr.pad(31n, v)), U32.to_nat(U32{Word.shr.pad(31n, v)}), Equal.sym(Nat, U32.to_nat(U32{Word.shr.pad(31n, v)}), uw(32n, Word.shr.pad(31n, v)), F.u32__to_nat_word(Word.shr.pad(31n, v)))) : {Nat.is_lt(U32.to_nat(U32{rw}), _) == True{} : Bool}
  %Equal.sym(U32, U32{Word.shr.pad(31n, v)}, b, Equal.sym(U32, b, U32{Word.shr.pad(31n, v)}, eb)) : {Nat.is_lt(U32.to_nat(U32{rw}), U32.to_nat(_)) == True{} : Bool}
  hr

def put_nat(+a0: Bool, +rw: Word(32n), +v: Word(31n),
    +h: {Nat.is_lt(uw(32n, rw), uw(32n, Word.shr.pad(31n, v))) == True{} : Bool})
    -> {U32.to_nat(U32{Word.shl.put(32n, a0, rw)}) == Nat.add(bc(a0), Nat.double(U32.to_nat(U32{rw}))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32{Word.shl.put(32n, a0, rw)}), uw(32n, Word.shl.put(32n, a0, rw)), F.u32__to_nat_word(Word.shl.put(32n, a0, rw))) : {_ == Nat.add(bc(a0), Nat.double(U32.to_nat(U32{rw}))) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32{rw}), uw(32n, rw), F.u32__to_nat_word(rw)) : {uw(32n, Word.shl.put(32n, a0, rw)) == Nat.add(bc(a0), Nat.double(_)) : Nat}
  put_val(31n, a0, rw, v, h)

law rec_ok:
  for +p: Nat
  for +q: Word(p)
  for +r: U32
  for +a0: Bool
  for +b: U32
  for +v: Word(31n)
  for +eb: {b == U32{Word.shr.pad(31n, v)} : U32}
  for +hr: {Nat.is_lt(U32.to_nat(r), U32.to_nat(b)) == True{} : Bool}
  {Nat.add(Nat.mul(uw(1n+p, Pair.fst(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, (q, r)))), U32.to_nat(b)), U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, (q, r)))))
    == Nat.add(bc(a0), Nat.double(Nat.add(Nat.mul(uw(p, q), U32.to_nat(b)), U32.to_nat(r)))) : Nat}
  & {Nat.is_lt(U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, (q, r)))), U32.to_nat(b)) == True{} : Bool}
def rec_ok(p, q, r, a0, b, v, eb, hr):
  match r:
    case U32{+rw}:
      +h = lt31(rw, b, v, eb, hr)
      %Equal.sym(Bool & Word(32n), Word.shl.out(32n, a0, rw), (False{}, Word.shl.put(32n, a0, rw)), shl_nc(31n, a0, rw, v, h)) :
        {Nat.add(Nat.mul(uw(1n+p, Pair.fst(Word(1n+p), U32, U32.divmod.go.shl(p, q, b, _))), U32.to_nat(b)), U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.shl(p, q, b, _))))
          == Nat.add(bc(a0), Nat.double(Nat.add(Nat.mul(uw(p, q), U32.to_nat(b)), U32.to_nat(U32{rw})))) : Nat}
        & {Nat.is_lt(U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.shl(p, q, b, _))), U32.to_nat(b)) == True{} : Bool}
      fin_ok(p, q, U32{Word.shl.put(32n, a0, rw)}, b, U32.is_ge(U32{Word.shl.put(32n, a0, rw)}, b), {==}, a0, U32.to_nat(U32{rw}), put_nat(a0, rw, v, h), hr)

def div_step(+p: Nat, +a0: Bool, +hi: Word(p), +b: U32, +v: Word(31n), +eb: {b == U32{Word.shr.pad(31n, v)} : U32},
    ih: {Nat.add(Nat.mul(uw(p, DQ(p, hi, b)), U32.to_nat(b)), U32.to_nat(DR(p, hi, b))) == uw(p, hi) : Nat}
      & {Nat.is_lt(U32.to_nat(DR(p, hi, b)), U32.to_nat(b)) == True{} : Bool})
    -> {Nat.add(Nat.mul(uw(1n+p, DQ(1n+p, WCon{a0, hi}, b)), U32.to_nat(b)), U32.to_nat(DR(1n+p, WCon{a0, hi}, b))) == uw(1n+p, WCon{a0, hi}) : Nat}
      & {Nat.is_lt(U32.to_nat(DR(1n+p, WCon{a0, hi}, b)), U32.to_nat(b)) == True{} : Bool}:
  (+ie, +ib) = ih
  %Equal.sym(Word(p) & U32, U32.divmod.go(p, hi, b), (DQ(p, hi, b), DR(p, hi, b)), F.logic__pair_eta(Word(p), U32, U32.divmod.go(p, hi, b))) :
    {Nat.add(Nat.mul(uw(1n+p, Pair.fst(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, _))), U32.to_nat(b)), U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, _))))
      == Nat.add(bc(a0), Nat.double(uw(p, hi))) : Nat}
    & {Nat.is_lt(U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, _))), U32.to_nat(b)) == True{} : Bool}
  %ie :
    {Nat.add(Nat.mul(uw(1n+p, Pair.fst(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, (DQ(p, hi, b), DR(p, hi, b))))), U32.to_nat(b)), U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, (DQ(p, hi, b), DR(p, hi, b))))))
      == Nat.add(bc(a0), Nat.double(_)) : Nat}
    & {Nat.is_lt(U32.to_nat(Pair.snd(Word(1n+p), U32, U32.divmod.go.rec(p, a0, b, (DQ(p, hi, b), DR(p, hi, b))))), U32.to_nat(b)) == True{} : Bool}
  rec_ok(p, DQ(p, hi, b), DR(p, hi, b), a0, b, v, eb, ib)

law div_ok:
  for +m: Nat
  for +a: Word(m)
  for +b: U32
  for +v: Word(31n)
  for +eb: {b == U32{Word.shr.pad(31n, v)} : U32}
  for +hb: {Nat.is_le(1n, U32.to_nat(b)) == True{} : Bool}
  {Nat.add(Nat.mul(uw(m, DQ(m, a, b)), U32.to_nat(b)), U32.to_nat(DR(m, a, b))) == uw(m, a) : Nat}
  & {Nat.is_lt(U32.to_nat(DR(m, a, b)), U32.to_nat(b)) == True{} : Bool}
def div_ok(m, a, b, v, eb, hb):
  match m a:
    case 0n WNil{}: ({==}, F.nat__succ_le_lt(0n, U32.to_nat(b), hb))
    case 1n+ +p WCon{+a0, +hi}: div_step(p, a0, hi, b, v, eb, div_ok(p, hi, b, v, eb, hb))

# ---- U32.div and U32.mod --------------------------------------------------------------

def div_is(+w: Word(32n), +b: U32, +hz: {U32.is_zero(b) == False{} : Bool}) -> {U32.div(U32{w}, b) == U32{DQ(32n, w, b)} : U32}:
  # Base 2.0.33+ opens b before it copies it (U32{+bw} = b), so the proof opens it too.
  match b:
    case U32{+bw}:
      %Equal.sym(Bool, U32.is_zero(U32{bw}), False{}, hz) : {U32.div.if(w, U32{bw}, _) == U32{DQ(32n, w, U32{bw})} : U32}
      %Equal.sym(Word(32n) & U32, U32.divmod.go(32n, w, U32{bw}), (DQ(32n, w, U32{bw}), DR(32n, w, U32{bw})), F.logic__pair_eta(Word(32n), U32, U32.divmod.go(32n, w, U32{bw}))) :
        {U32.div.fin(_) == U32{DQ(32n, w, U32{bw})} : U32}
      {==}

def mod_is(+w: Word(32n), +b: U32, +hz: {U32.is_zero(b) == False{} : Bool}) -> {U32.mod(U32{w}, b) == DR(32n, w, b) : U32}:
  # Base 2.0.33+ opens b before it copies it (U32{+bw} = b), so the proof opens it too.
  match b:
    case U32{+bw}:
      %Equal.sym(Bool, U32.is_zero(U32{bw}), False{}, hz) : {U32.mod.if(w, U32{bw}, _) == DR(32n, w, U32{bw}) : U32}
      %Equal.sym(Word(32n) & U32, U32.divmod.go(32n, w, U32{bw}), (DQ(32n, w, U32{bw}), DR(32n, w, U32{bw})), F.logic__pair_eta(Word(32n), U32, U32.divmod.go(32n, w, U32{bw}))) :
        {U32.mod.fin(_) == DR(32n, w, U32{bw}) : U32}
      {==}

def div_eq(+w: Word(32n), +b: U32,
    +ie: {Nat.add(Nat.mul(uw(32n, DQ(32n, w, b)), U32.to_nat(b)), U32.to_nat(DR(32n, w, b))) == uw(32n, w) : Nat})
    -> {Nat.add(Nat.mul(U32.to_nat(U32{DQ(32n, w, b)}), U32.to_nat(b)), U32.to_nat(DR(32n, w, b))) == U32.to_nat(U32{w}) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32{DQ(32n, w, b)}), uw(32n, DQ(32n, w, b)), F.u32__to_nat_word(DQ(32n, w, b))) :
    {Nat.add(Nat.mul(_, U32.to_nat(b)), U32.to_nat(DR(32n, w, b))) == U32.to_nat(U32{w}) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32{w}), uw(32n, w), F.u32__to_nat_word(w)) :
    {Nat.add(Nat.mul(uw(32n, DQ(32n, w, b)), U32.to_nat(b)), U32.to_nat(DR(32n, w, b))) == _ : Nat}
  ie

def div_pair(+w: Word(32n), +b: U32,
    ih: {Nat.add(Nat.mul(uw(32n, DQ(32n, w, b)), U32.to_nat(b)), U32.to_nat(DR(32n, w, b))) == uw(32n, w) : Nat}
      & {Nat.is_lt(U32.to_nat(DR(32n, w, b)), U32.to_nat(b)) == True{} : Bool})
    -> {Nat.add(Nat.mul(U32.to_nat(U32{DQ(32n, w, b)}), U32.to_nat(b)), U32.to_nat(DR(32n, w, b))) == U32.to_nat(U32{w}) : Nat}
      & {Nat.is_lt(U32.to_nat(DR(32n, w, b)), U32.to_nat(b)) == True{} : Bool}:
  (+ie, +ib) = ih
  (div_eq(w, b, ie), ib)

# x == (x / b) b + x % b with x % b < b, for b > 0 with a clear top bit.
def div_u32(+x: U32, +b: U32, +v: Word(31n), +eb: {b == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(b)) == True{} : Bool},
    +hz: {U32.is_zero(b) == False{} : Bool})
    -> {Nat.add(Nat.mul(U32.to_nat(U32.div(x, b)), U32.to_nat(b)), U32.to_nat(U32.mod(x, b))) == U32.to_nat(x) : Nat}
      & {Nat.is_lt(U32.to_nat(U32.mod(x, b)), U32.to_nat(b)) == True{} : Bool}:
  match x:
    case U32{+w}:
      %Equal.sym(U32, U32.div(U32{w}, b), U32{DQ(32n, w, b)}, div_is(w, b, hz)) :
        {Nat.add(Nat.mul(U32.to_nat(_), U32.to_nat(b)), U32.to_nat(U32.mod(U32{w}, b))) == U32.to_nat(U32{w}) : Nat}
        & {Nat.is_lt(U32.to_nat(U32.mod(U32{w}, b)), U32.to_nat(b)) == True{} : Bool}
      %Equal.sym(U32, U32.mod(U32{w}, b), DR(32n, w, b), mod_is(w, b, hz)) :
        {Nat.add(Nat.mul(U32.to_nat(U32{DQ(32n, w, b)}), U32.to_nat(b)), U32.to_nat(_)) == U32.to_nat(U32{w}) : Nat}
        & {Nat.is_lt(U32.to_nat(_), U32.to_nat(b)) == True{} : Bool}
      div_pair(w, b, div_ok(32n, w, b, v, eb, hb))

# ---- uniqueness of quotient and remainder ---------------------------------------------

def dm_gap(+r1: Nat, +q: Nat, +r2: Nat, +B: Nat, +e: {r1 == Nat.add(Nat.add(B, Nat.mul(q, B)), r2) : Nat}, +h1: {Nat.is_lt(r1, B) == True{} : Bool}) -> Empty:
  +ge = F.logic__subst(Nat, z => {Nat.is_le(B, z) == True{} : Bool}, Nat.add(Nat.add(B, Nat.mul(q, B)), r2), r1, Equal.sym(Nat, r1, Nat.add(Nat.add(B, Nat.mul(q, B)), r2), e),
    F.nat__le_trans(B, Nat.add(B, Nat.mul(q, B)), Nat.add(Nat.add(B, Nat.mul(q, B)), r2), Order.below_sum(B, Nat.mul(q, B)), Order.below_sum(Nat.add(B, Nat.mul(q, B)), r2)))
  F.nat__lt_ne(r1, r1, F.nat__lt_le_trans(r1, B, r1, h1, ge), {==})

def dm_succ(+p: Nat, +q: Nat, +r1: Nat, +r2: Nat, u: {p == q : Nat} & {r1 == r2 : Nat}) -> {1n+p == 1n+q : Nat} & {r1 == r2 : Nat}:
  (+ep, +er) = u
  (F.nat__succ_cong(p, q, ep), er)

law dm_unique:
  for +q1: Nat
  for +r1: Nat
  for +q2: Nat
  for +r2: Nat
  for +B: Nat
  for +e: {Nat.add(Nat.mul(q1, B), r1) == Nat.add(Nat.mul(q2, B), r2) : Nat}
  for +h1: {Nat.is_lt(r1, B) == True{} : Bool}
  for +h2: {Nat.is_lt(r2, B) == True{} : Bool}
  {q1 == q2 : Nat} & {r1 == r2 : Nat}
def dm_unique(q1, r1, q2, r2, B, e, h1, h2):
  match q1 q2:
    case 0n 0n: ({==}, e)
    case 0n 1n+ +q: Empty.absurd({0n == 1n+q : Nat} & {r1 == r2 : Nat}, dm_gap(r1, q, r2, B, e, h1))
    case 1n+ +p 0n: Empty.absurd({1n+p == 0n : Nat} & {r1 == r2 : Nat}, dm_gap(r2, p, r1, B, Equal.sym(Nat, Nat.add(Nat.add(B, Nat.mul(p, B)), r1), r2, e), h2))
    case 1n+ +p 1n+ +q:
      +e2 = F.lru_subtraction_bounds__cancel_left(B, Nat.add(Nat.mul(p, B), r1), Nat.add(Nat.mul(q, B), r2),
        Equal.trans(Nat, Nat.add(B, Nat.add(Nat.mul(p, B), r1)), Nat.add(Nat.add(B, Nat.mul(p, B)), r1), Nat.add(B, Nat.add(Nat.mul(q, B), r2)),
          Equal.sym(Nat, Nat.add(Nat.add(B, Nat.mul(p, B)), r1), Nat.add(B, Nat.add(Nat.mul(p, B), r1)), F.nat__add_assoc(B, Nat.mul(p, B), r1)),
          Equal.trans(Nat, Nat.add(Nat.add(B, Nat.mul(p, B)), r1), Nat.add(Nat.add(B, Nat.mul(q, B)), r2), Nat.add(B, Nat.add(Nat.mul(q, B), r2)),
            e, F.nat__add_assoc(B, Nat.mul(q, B), r2))))
      dm_succ(p, q, r1, r2, dm_unique(p, r1, q, r2, B, e2, h1, h2))


# ---- "a whole number of elements, at most lim": the list decoders' check ----------------

def le_u32(+a: U32, +b: U32) -> {U32.is_le(a, b) == Nat.is_le(U32.to_nat(a), U32.to_nat(b)) : Bool}:
  %Equal.sym(Cmp, U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), F.u32__u32_cmp(a, b)) : {Cmp.is_le(_) == Nat.is_le(U32.to_nat(a), U32.to_nat(b)) : Bool}
  {==}

def whole_parts(+L: U32, +e: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool},
    +hz: {U32.is_zero(e) == False{} : Bool},
    dv: {Nat.add(Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), U32.to_nat(U32.mod(L, e))) == U32.to_nat(L) : Nat}
      & {Nat.is_lt(U32.to_nat(U32.mod(L, e)), U32.to_nat(e)) == True{} : Bool})
    -> {Nat.is_le(Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), U32.to_nat(L)) == True{} : Bool}:
  (+de, +dr) = dv
  F.logic__subst(Nat, z => {Nat.is_le(Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), z) == True{} : Bool},
    Nat.add(Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), U32.to_nat(U32.mod(L, e))), U32.to_nat(L), de,
    Order.below_sum(Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), U32.to_nat(U32.mod(L, e))))

# The check accepted: the length is a whole number of elements, at most lim.
def whole_t(+L: U32, +e: U32, +lim: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool},
    +hz: {U32.is_zero(e) == False{} : Bool},
    +h: {Bool.and(U32.is_eq(L, U32.mul(U32.div(L, e), e)), U32.is_le(U32.div(L, e), lim)) == True{} : Bool})
    -> {U32.to_nat(L) == Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)) : Nat} & {Nat.is_le(U32.to_nat(U32.div(L, e)), U32.to_nat(lim)) == True{} : Bool}:
  +h1 = F.logic__and_left(U32.is_eq(L, U32.mul(U32.div(L, e), e)), U32.is_le(U32.div(L, e), lim), h)
  +h2 = F.logic__and_right(U32.is_eq(L, U32.mul(U32.div(L, e), e)), U32.is_le(U32.div(L, e), lim), h)
  +mv = mul_le(U32.div(L, e), e, L, whole_parts(L, e, v, eb, hb, hz, div_u32(L, e, v, eb, hb, hz)))
  (Equal.trans(Nat, U32.to_nat(L), U32.to_nat(U32.mul(U32.div(L, e), e)), Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)),
     Equal.cong(U32, Nat, x => U32.to_nat(x), L, U32.mul(U32.div(L, e), e), F.u32alg__eq_of(L, U32.mul(U32.div(L, e), e), h1)), mv),
   F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(U32.div(L, e), lim), Nat.is_le(U32.to_nat(U32.div(L, e)), U32.to_nat(lim)), le_u32(U32.div(L, e), lim), h2))

def whole_q(+L: U32, +e: U32, +c: Nat,
    +ec: {U32.to_nat(L) == Nat.mul(c, U32.to_nat(e)) : Nat},
    +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool},
    dv: {Nat.add(Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), U32.to_nat(U32.mod(L, e))) == U32.to_nat(L) : Nat}
      & {Nat.is_lt(U32.to_nat(U32.mod(L, e)), U32.to_nat(e)) == True{} : Bool})
    -> {U32.to_nat(U32.div(L, e)) == c : Nat} & {U32.to_nat(U32.mod(L, e)) == 0n : Nat}:
  (+de, +dr) = dv
  +E = U32.to_nat(e)
  dm_unique(U32.to_nat(U32.div(L, e)), U32.to_nat(U32.mod(L, e)), c, 0n, E,
    Equal.trans(Nat, Nat.add(Nat.mul(U32.to_nat(U32.div(L, e)), E), U32.to_nat(U32.mod(L, e))), U32.to_nat(L), Nat.add(Nat.mul(c, E), 0n),
      de, Equal.trans(Nat, U32.to_nat(L), Nat.mul(c, E), Nat.add(Nat.mul(c, E), 0n), ec, Equal.sym(Nat, Nat.add(Nat.mul(c, E), 0n), Nat.mul(c, E), F.nat__add_zero(Nat.mul(c, E))))),
    dr, F.nat__succ_le_lt(0n, E, hb))

def whole_i2(+L: U32, +e: U32, +lim: U32, +c: Nat,
    +ec: {U32.to_nat(L) == Nat.mul(c, U32.to_nat(e)) : Nat},
    +hc: {Nat.is_le(c, U32.to_nat(lim)) == True{} : Bool},
    +mv: {U32.to_nat(U32.mul(U32.div(L, e), e)) == Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)) : Nat},
    uq: {U32.to_nat(U32.div(L, e)) == c : Nat} & {U32.to_nat(U32.mod(L, e)) == 0n : Nat})
    -> {Bool.and(U32.is_eq(L, U32.mul(U32.div(L, e), e)), U32.is_le(U32.div(L, e), lim)) == True{} : Bool}:
  (+eq, +er) = uq
  +M = U32.mul(U32.div(L, e), e)
  +tM = Equal.trans(Nat, U32.to_nat(M), Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), U32.to_nat(L), mv,
    Equal.trans(Nat, Nat.mul(U32.to_nat(U32.div(L, e)), U32.to_nat(e)), Nat.mul(c, U32.to_nat(e)), U32.to_nat(L),
      Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(e)), U32.to_nat(U32.div(L, e)), c, eq), Equal.sym(Nat, U32.to_nat(L), Nat.mul(c, U32.to_nat(e)), ec)))
  +i1 = F.u32alg__eq_true(L, M, F.u32__injective(L, M, Equal.sym(Nat, U32.to_nat(M), U32.to_nat(L), tM)))
  +i2 = F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(U32.div(L, e)), U32.to_nat(lim)), U32.is_le(U32.div(L, e), lim), Equal.sym(Bool, U32.is_le(U32.div(L, e), lim), Nat.is_le(U32.to_nat(U32.div(L, e)), U32.to_nat(lim)), le_u32(U32.div(L, e), lim)),
    F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(lim)) == True{} : Bool}, c, U32.to_nat(U32.div(L, e)), Equal.sym(Nat, U32.to_nat(U32.div(L, e)), c, eq), hc))
  F.logic__and_intro(U32.is_eq(L, M), U32.is_le(U32.div(L, e), lim), i1, i2)

# A whole number c <= lim of elements passes the check.
def whole_i(+L: U32, +e: U32, +lim: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool},
    +hz: {U32.is_zero(e) == False{} : Bool}, +c: Nat,
    +ec: {U32.to_nat(L) == Nat.mul(c, U32.to_nat(e)) : Nat},
    +hc: {Nat.is_le(c, U32.to_nat(lim)) == True{} : Bool})
    -> {Bool.and(U32.is_eq(L, U32.mul(U32.div(L, e), e)), U32.is_le(U32.div(L, e), lim)) == True{} : Bool}:
  whole_i2(L, e, lim, c, ec, hc, mul_le(U32.div(L, e), e, L, whole_parts(L, e, v, eb, hb, hz, div_u32(L, e, v, eb, hb, hz))),
    whole_q(L, e, c, ec, hb, div_u32(L, e, v, eb, hb, hz)))
