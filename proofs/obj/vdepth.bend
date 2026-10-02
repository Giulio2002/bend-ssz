import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../proofs/nat_order.bend as Order
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A

# The depth B.words_depth computes, as a bit length (cover and minimality).
# A copy of proofs/obj/wdepth.bend and proofs/obj/wdstage.bend with the few
# facts they take from ctree/cidx/mtree_* restated here (s_*), so a module
# that needs only the depth does not re-check the cached-tree development.

def s_false_true(e: {False{} == True{} : Bool}) -> Empty: F.logic__false_true(e)
def s_true_false(e: {True{} == False{} : Bool}) -> Empty: F.logic__true_false(e)

def s_h2(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p:
      match p:
        case 0n: 0n
        case 1n+q: 1n+s_h2(q)

def s_rng(l: Nat, +x: Nat) -> Nat:
  match l:
    case 0n: x
    case 1n+k: s_h2(s_rng(k, x))

law s_h2_lt:
  for +x: Nat
  for +P: Nat
  for +h: {Nat.is_lt(x, Nat.double(P)) == True{} : Bool}
  {Nat.is_lt(s_h2(x), P) == True{} : Bool}
def s_h2_lt(x, P, h):
  match x P:
    case 0n 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, s_false_true(h))
    case 0n 1n+Q: {==}
    case 1n 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, s_false_true(h))
    case 1n 1n+Q: {==}
    case 2n+p 0n: Empty.absurd({Nat.is_lt(s_h2(2n+p), 0n) == True{} : Bool}, s_false_true(h))
    case 2n+ +p 1n+ +Q: s_h2_lt(p, Q, h)

def s_lt_zero_absurd(+l: Nat, +h: {Nat.is_lt(l, 0n) == True{} : Bool}) -> Empty:
  s_false_true(Equal.trans(Bool, False{}, Nat.is_lt(l, 0n), True{}, Equal.sym(Bool, Nat.is_lt(l, 0n), False{}, F.nat__not_lt_zero(l)), h))

law s_pow2_pos:
  for +d: Nat
  {Nat.is_le(1n, O.pow2n(d)) == True{} : Bool}
def s_pow2_pos(d):
  match d:
    case 0n: {==}
    case 1n+ +p: Order.transitive(1n, O.pow2n(p), Nat.double(O.pow2n(p)), s_pow2_pos(p), F.nat__double_self_le(O.pow2n(p)))

law s_pow2_mono:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(O.pow2n(a), O.pow2n(b)) == True{} : Bool}
def s_pow2_mono(a, b, e):
  match a b:
    case 0n _: s_pow2_pos(b)
    case 1n+p 0n: Empty.absurd({Nat.is_le(O.pow2n(1n+p), 1n) == True{} : Bool}, s_false_true(e))
    case 1n+ +p 1n+ +q: Order.double_monotone(O.pow2n(p), O.pow2n(q), s_pow2_mono(p, q, e))

law s_pow2_eq:
  for +d: Nat
  {F.spec_common__pow2(d) == O.pow2n(d) : Nat}
def s_pow2_eq(d):
  match d:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, F.spec_common__pow2(p), O.pow2n(p), s_pow2_eq(p)) : {Nat.double(_) == Nat.double(O.pow2n(p)) : Nat}
      {==}

law s_sub_le:
  for +a: Nat
  for +b: Nat
  {Nat.is_le(Nat.sub(a, b), a) == True{} : Bool}
def s_sub_le(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+ +p 0n: F.nat__le_refl(1n+p)
    case 1n+ +p 1n+ +q: F.nat__le_trans(Nat.sub(p, q), p, 1n+p, s_sub_le(p, q), F.nat__le_succ(p))

law s_add_succ:
  for +a: Nat
  for +b: Nat
  {Nat.add(a, 1n+b) == 1n+Nat.add(a, b) : Nat}
def s_add_succ(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p:
      %s_add_succ(p, b) : {1n+Nat.add(p, 1n+b) == 1n+_ : Nat}
      {==}

def s_add_commute(+a: Nat, +b: Nat) -> {Nat.add(a, b) == Nat.add(b, a) : Nat}: F.nat__add_comm(a, b)

def s_add_assoc(+x: Nat, +y: Nat, +z: Nat) -> {Nat.add(Nat.add(x, y), z) == Nat.add(x, Nat.add(y, z)) : Nat}: F.nat__add_assoc(x, y, z)

law s_pow2u_eq:
  for +d: Nat
  {O.pow2u(d) == F.u32__pow2u(d) : U32}
def s_pow2u_eq(d):
  match d:
    case 0n: {==}
    case 1n+ +p:
      %s_pow2u_eq(p) : {U32.shl(O.pow2u(p)) == U32.shl(_) : U32}
      {==}

def s_pow2u_val(+d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}) -> {U32.to_nat(O.pow2u(d)) == O.pow2n(d) : Nat}:
  %Equal.sym(U32, O.pow2u(d), F.u32__pow2u(d), s_pow2u_eq(d)) : {U32.to_nat(_) == O.pow2n(d) : Nat}
  Equal.trans(Nat, U32.to_nat(F.u32__pow2u(d)), F.spec_common__pow2(d), O.pow2n(d), F.u32__pow2u_value(d, hd), s_pow2_eq(d))

def s_rw_bound(+x: Nat, +k: Nat, +hk: {Nat.is_lt(k, 32n) == True{} : Bool}, +h: {Nat.is_le(x, O.pow2n(k)) == True{} : Bool})
    -> {Nat.is_le(x, U32.to_nat(O.pow2u(k))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(O.pow2u(k)), O.pow2n(k), s_pow2u_val(k, hk)) : {Nat.is_le(x, _) == True{} : Bool}
  h

def s_add_nat(+a: U32, +b: U32, +k: Nat, +hk: {Nat.is_lt(k, 32n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), O.pow2n(k)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, b)) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}:
  A.add_le(a, b, O.pow2u(k), s_rw_bound(Nat.add(U32.to_nat(a), U32.to_nat(b)), k, hk, h))

law s_h2_bit:
  for +b: Bool
  for +y: Nat
  {s_h2(Nat.add(F.spec_numeric__bit_value(b), Nat.double(y))) == y : Nat}
def s_h2_bit(b, y):
  match b y:
    case False{} 0n: {==}
    case False{} 1n+ +q:
      %Equal.sym(Nat, s_h2(Nat.add(F.spec_numeric__bit_value(False{}), Nat.double(q))), q, s_h2_bit(False{}, q)) : {1n+_ == 1n+q : Nat}
      {==}
    case True{} 0n: {==}
    case True{} 1n+ +q:
      %Equal.sym(Nat, s_h2(Nat.add(F.spec_numeric__bit_value(True{}), Nat.double(q))), q, s_h2_bit(True{}, q)) : {1n+_ == 1n+q : Nat}
      {==}

def s_shr1(+x: U32) -> {U32.to_nat(U32.shrn(x, 1n)) == s_h2(U32.to_nat(x)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(x), Nat.add(F.spec_numeric__bit_value(F.u32__low_bit(x)), Nat.double(U32.to_nat(U32.shr(x)))), F.u32__shr_split(x)) : {U32.to_nat(U32.shr(x)) == s_h2(_) : Nat}
  Equal.sym(Nat, s_h2(Nat.add(F.spec_numeric__bit_value(F.u32__low_bit(x)), Nat.double(U32.to_nat(U32.shr(x))))), U32.to_nat(U32.shr(x)),
    s_h2_bit(F.u32__low_bit(x), U32.to_nat(U32.shr(x))))

def s_le_nat(+a: U32, +b: U32) -> {U32.is_le(a, b) == Nat.is_le(U32.to_nat(a), U32.to_nat(b)) : Bool}:
  %Equal.sym(Cmp, U32.cmp(a, b), Nat.cmp(U32.to_nat(a), U32.to_nat(b)), F.u32__u32_cmp(a, b)) : {Cmp.is_le(_) == Nat.is_le(U32.to_nat(a), U32.to_nat(b)) : Bool}
  {==}

# ==== wdepth.bend ====

# The bit length used by B.words_depth, as a Nat model. blen(k, M) is the
# number of bits of M below width k, by structural recursion on k, testing
# M >> j < 1 (rng(j, M) < 1) rather than M < 2^j, so no statement mentions a
# power of two: the pinned checker evaluates closed Nat terms in unary, and a
# closed 2^16 or 2^32 overflows it (proofs/compact/arith.bend). Facts:
# M < 2^blen(k, M) when M >> k = 0 (blen_cover), blen(k, M) <= j whenever
# M < 2^j (blen_min), and splitting a width K + j at K (blen_hi, blen_lo), the
# runtime's halving. Shifts are halvings: to_nat(x >> k) = rng(k, to_nat(x)).

# ---- shifts and halvings ----------------------------------------------------------------

# A shift by k halves k times.
law shrk:
  for +k: Nat
  for +x: U32
  {U32.to_nat(U32.shrn(x, k)) == s_rng(k, U32.to_nat(x)) : Nat}
def shrk(k, x):
  match k:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32.shrn(x, p), 1n)), s_h2(U32.to_nat(U32.shrn(x, p))), s_shr1(U32.shrn(x, p))) :
        {_ == s_h2(s_rng(p, U32.to_nat(x))) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(x, p)), s_rng(p, U32.to_nat(x)), shrk(p, x)) :
        {s_h2(_) == s_h2(s_rng(p, U32.to_nat(x))) : Nat}
      {==}

law h2_lt_inv:
  for +y: Nat
  for +P: Nat
  for +h: {Nat.is_lt(s_h2(y), P) == True{} : Bool}
  {Nat.is_lt(y, Nat.double(P)) == True{} : Bool}
def h2_lt_inv(y, P, h):
  match y P:
    case 0n 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, s_false_true(h))
    case 0n 1n+Q: {==}
    case 1n 0n: Empty.absurd({Nat.is_lt(1n, 0n) == True{} : Bool}, s_false_true(h))
    case 1n 1n+Q: {==}
    case 2n+p 0n: Empty.absurd({Nat.is_lt(2n+p, 0n) == True{} : Bool}, s_false_true(h))
    case 2n+ +p 1n+ +Q: h2_lt_inv(p, Q, h)

def shift_pow(+K: Nat, +j: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(Nat.add(1n+K, j))) == True{} : Bool})
    -> {Nat.is_lt(X, O.pow2n(Nat.add(K, 1n+j))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(K, 1n+j), 1n+Nat.add(K, j), s_add_succ(K, j)) : {Nat.is_lt(X, O.pow2n(_)) == True{} : Bool}
  h

def shift_pow_inv(+K: Nat, +j: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(Nat.add(K, 1n+j))) == True{} : Bool})
    -> {Nat.is_lt(X, O.pow2n(Nat.add(1n+K, j))) == True{} : Bool}:
  %s_add_succ(K, j) : {Nat.is_lt(X, O.pow2n(_)) == True{} : Bool}
  h

# X < 2^(K + j) exactly when X >> K < 2^j.
law rlt:
  for +K: Nat
  for +j: Nat
  for +X: Nat
  for +h: {Nat.is_lt(X, O.pow2n(Nat.add(K, j))) == True{} : Bool}
  {Nat.is_lt(s_rng(K, X), O.pow2n(j)) == True{} : Bool}
def rlt(K, j, X, h):
  match K:
    case 0n: h
    case 1n+ +K2: s_h2_lt(s_rng(K2, X), O.pow2n(j), rlt(K2, 1n+j, X, shift_pow(K2, j, X, h)))

law rlt_inv:
  for +K: Nat
  for +j: Nat
  for +X: Nat
  for +h: {Nat.is_lt(s_rng(K, X), O.pow2n(j)) == True{} : Bool}
  {Nat.is_lt(X, O.pow2n(Nat.add(K, j))) == True{} : Bool}
def rlt_inv(K, j, X, h):
  match K:
    case 0n: h
    case 1n+ +K2: shift_pow_inv(K2, j, X, rlt_inv(K2, 1n+j, X, h2_lt_inv(s_rng(K2, X), O.pow2n(j), h)))

def k0(+K: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(K)) == True{} : Bool}) -> {Nat.is_lt(X, O.pow2n(Nat.add(K, 0n))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(K, 0n), K, F.nat__add_zero(K)) : {Nat.is_lt(X, O.pow2n(_)) == True{} : Bool}
  h

def k0_inv(+K: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(Nat.add(K, 0n))) == True{} : Bool}) -> {Nat.is_lt(X, O.pow2n(K)) == True{} : Bool}:
  %F.nat__add_zero(K) : {Nat.is_lt(X, O.pow2n(_)) == True{} : Bool}
  h

# X < 2^K exactly when X >> K < 1.
def small_rng(+K: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(K)) == True{} : Bool}) -> {Nat.is_lt(s_rng(K, X), 1n) == True{} : Bool}:
  rlt(K, 0n, X, k0(K, X, h))

def small_inv(+K: Nat, +X: Nat, +h: {Nat.is_lt(s_rng(K, X), 1n) == True{} : Bool}) -> {Nat.is_lt(X, O.pow2n(K)) == True{} : Bool}:
  k0_inv(K, X, rlt_inv(K, 0n, X, h))

# Two Bools that imply each other are equal.
def beq(+a: Bool, +b: Bool, f: {a == True{} : Bool} -> {b == True{} : Bool}, g: {b == True{} : Bool} -> {a == True{} : Bool}) -> {a == b : Bool}:
  match a:
    case True{}: Equal.sym(Bool, b, True{}, f({==}))
    case False{}:
      match b:
        case True{}: Empty.absurd({False{} == True{} : Bool}, s_false_true(g({==})))
        case False{}: {==}

def small_eq(+K: Nat, +X: Nat) -> {Nat.is_lt(X, O.pow2n(K)) == Nat.is_lt(s_rng(K, X), 1n) : Bool}:
  beq(Nat.is_lt(X, O.pow2n(K)), Nat.is_lt(s_rng(K, X), 1n), e => small_rng(K, X, e), e => small_inv(K, X, e))

def le_of_not_lt(+a: Nat, +b: Nat, +c: Bool, +ec: {Nat.is_lt(a, b) == c : Bool}) -> {Nat.is_le(b, a) == Bool.not(c) : Bool}:
  match c:
    case True{}: F.nat__lt_not_le(a, b, ec)
    case False{}: F.nat__not_lt_le(a, b, ec)

# 2^K <= X exactly when X >> K >= 1.
def pw_le(+K: Nat, +X: Nat) -> {Nat.is_le(O.pow2n(K), X) == Nat.is_le(1n, s_rng(K, X)) : Bool}:
  Equal.trans(Bool, Nat.is_le(O.pow2n(K), X), Bool.not(Nat.is_lt(X, O.pow2n(K))), Nat.is_le(1n, s_rng(K, X)),
    le_of_not_lt(X, O.pow2n(K), Nat.is_lt(X, O.pow2n(K)), {==}),
    Equal.trans(Bool, Bool.not(Nat.is_lt(X, O.pow2n(K))), Bool.not(Nat.is_lt(s_rng(K, X), 1n)), Nat.is_le(1n, s_rng(K, X)),
      Equal.cong(Bool, Bool, z => Bool.not(z), Nat.is_lt(X, O.pow2n(K)), Nat.is_lt(s_rng(K, X), 1n), small_eq(K, X)),
      Equal.sym(Bool, Nat.is_le(1n, s_rng(K, X)), Bool.not(Nat.is_lt(s_rng(K, X), 1n)), le_of_not_lt(s_rng(K, X), 1n, Nat.is_lt(s_rng(K, X), 1n), {==}))))

# rng composes: (x >> K) >> q = x >> (q + K).
law rng_comp:
  for +q: Nat
  for +K: Nat
  for +X: Nat
  {s_rng(q, s_rng(K, X)) == s_rng(Nat.add(q, K), X) : Nat}
def rng_comp(q, K, X):
  match q:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, s_rng(p, s_rng(K, X)), s_rng(Nat.add(p, K), X), rng_comp(p, K, X)) : {s_h2(_) == s_h2(s_rng(Nat.add(p, K), X)) : Nat}
      {==}

def rng_comp2(+K: Nat, +q: Nat, +X: Nat) -> {s_rng(Nat.add(K, q), X) == s_rng(q, s_rng(K, X)) : Nat}:
  %Equal.sym(Nat, Nat.add(K, q), Nat.add(q, K), s_add_commute(K, q)) : {s_rng(_, X) == s_rng(q, s_rng(K, X)) : Nat}
  Equal.sym(Nat, s_rng(q, s_rng(K, X)), s_rng(Nat.add(q, K), X), rng_comp(q, K, X))

law rng_zero:
  for +l: Nat
  {s_rng(l, 0n) == 0n : Nat}
def rng_zero(l):
  match l:
    case 0n: {==}
    case 1n+ +k:
      %Equal.sym(Nat, s_rng(k, 0n), 0n, rng_zero(k)) : {s_h2(_) == 0n : Nat}
      {==}

def lt1_zero(+x: Nat, +h: {Nat.is_lt(x, 1n) == True{} : Bool}) -> {x == 0n : Nat}:
  match x:
    case 0n: {==}
    case 1n+ +p: Empty.absurd({1n+p == 0n : Nat}, s_false_true(Equal.trans(Bool, False{}, Nat.is_lt(p, 0n), True{}, Equal.sym(Bool, Nat.is_lt(p, 0n), False{}, F.nat__not_lt_zero(p)), h)))

# ---- the bit length ------------------------------------------------------------------------

def blen(+k: Nat, +M: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n+ +j: O.npick(Nat.is_lt(s_rng(j, M), 1n), blen(j, M), 1n+j)

def bc_pick(+j: Nat, +M: Nat, +h: {Nat.is_lt(s_rng(1n+j, M), 1n) == True{} : Bool},
    ih: {Nat.is_lt(s_rng(j, M), 1n) == True{} : Bool} -> {Nat.is_lt(M, O.pow2n(blen(j, M))) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_lt(s_rng(j, M), 1n) == c : Bool})
    -> {Nat.is_lt(M, O.pow2n(O.npick(c, blen(j, M), 1n+j))) == True{} : Bool}:
  match c:
    case True{}: ih(ec)
    case False{}: small_inv(1n+j, M, h)

# M < 2^blen(k, M) when M >> k = 0.
law blen_cover:
  for +k: Nat
  for +M: Nat
  for +h: {Nat.is_lt(s_rng(k, M), 1n) == True{} : Bool}
  {Nat.is_lt(M, O.pow2n(blen(k, M))) == True{} : Bool}
def blen_cover(k, M, h):
  match k:
    case 0n: h
    case 1n+ +j: bc_pick(j, M, h, e => blen_cover(j, M, e), Nat.is_lt(s_rng(j, M), 1n), {==})

# 2^i <= M < 2^j: i < j.
def pow2_between(+i: Nat, +j: Nat, +M: Nat, +h1: {Nat.is_lt(M, O.pow2n(i)) == False{} : Bool}, +h2: {Nat.is_lt(M, O.pow2n(j)) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(j, i) == c : Bool}) -> {Nat.is_le(1n+i, j) == True{} : Bool}:
  match c:
    case True{}:
      Empty.absurd({Nat.is_le(1n+i, j) == True{} : Bool},
        Order.le_lt_conflict(O.pow2n(j), M,
          F.nat__le_trans(O.pow2n(j), O.pow2n(i), M, s_pow2_mono(j, i, ec), F.nat__not_lt_le(M, O.pow2n(i), h1)), h2))
    case False{}: F.nat__lt_succ_le_succ(i, j, F.nat__not_le_lt(j, i, ec))

def not_small(+i: Nat, +M: Nat, +ec: {Nat.is_lt(s_rng(i, M), 1n) == False{} : Bool}) -> {Nat.is_lt(M, O.pow2n(i)) == False{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(M, O.pow2n(i)), Nat.is_lt(s_rng(i, M), 1n), False{}, small_eq(i, M), ec)

def bm_pick(+i: Nat, +M: Nat, +j: Nat, +h: {Nat.is_lt(M, O.pow2n(j)) == True{} : Bool},
    ih: {Nat.is_lt(s_rng(i, M), 1n) == True{} : Bool} -> {Nat.is_le(blen(i, M), j) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_lt(s_rng(i, M), 1n) == c : Bool})
    -> {Nat.is_le(O.npick(c, blen(i, M), 1n+i), j) == True{} : Bool}:
  match c:
    case True{}: ih(ec)
    case False{}: pow2_between(i, j, M, not_small(i, M, ec), h, Nat.is_le(j, i), {==})

# blen(k, M) <= j whenever M < 2^j.
law blen_min:
  for +k: Nat
  for +M: Nat
  for +j: Nat
  for +h: {Nat.is_lt(M, O.pow2n(j)) == True{} : Bool}
  {Nat.is_le(blen(k, M), j) == True{} : Bool}
def blen_min(k, M, j, h):
  match k:
    case 0n: Order.zero_le(j)
    case 1n+ +i: bm_pick(i, M, j, h, e => blen_min(i, M, j, h), Nat.is_lt(s_rng(i, M), 1n), {==})

# ---- saturation and splitting ----------------------------------------------------------------

law h2_ge1:
  for +y: Nat
  for +h: {Nat.is_le(1n, s_h2(y)) == True{} : Bool}
  {Nat.is_lt(y, 1n) == False{} : Bool}
def h2_ge1(y, h):
  match y:
    case 0n: Empty.absurd({Nat.is_lt(0n, 1n) == False{} : Bool}, s_false_true(h))
    case 1n+ +p: F.nat__not_lt_zero(p)

def sat_pick(+k: Nat, +M: Nat, +c: Bool, +ec: {Nat.is_lt(s_rng(k, M), 1n) == c : Bool}, +h: {Nat.is_lt(s_rng(k, M), 1n) == False{} : Bool})
    -> {O.npick(c, blen(k, M), 1n+k) == 1n+k : Nat}:
  match c:
    case True{}: Empty.absurd({blen(k, M) == 1n+k : Nat}, s_true_false(Equal.trans(Bool, True{}, Nat.is_lt(s_rng(k, M), 1n), False{}, Equal.sym(Bool, Nat.is_lt(s_rng(k, M), 1n), True{}, ec), h)))
    case False{}: {==}

# M >> K >= 1: the bit length within width K is K.
law blen_sat:
  for +K: Nat
  for +M: Nat
  for +hge: {Nat.is_le(1n, s_rng(K, M)) == True{} : Bool}
  {blen(K, M) == K : Nat}
def blen_sat(K, M, hge):
  match K:
    case 0n: {==}
    case 1n+ +k: sat_pick(k, M, Nat.is_lt(s_rng(k, M), 1n), {==}, h2_ge1(s_rng(k, M), hge))

def npick_add(+K: Nat, +c: Bool, +x: Nat, +y: Nat) -> {Nat.add(K, O.npick(c, x, y)) == O.npick(c, Nat.add(K, x), Nat.add(K, y)) : Nat}:
  match c:
    case True{}: {==}
    case False{}: {==}

def hi_pick(+K: Nat, +j: Nat, +M: Nat,
    ih: {Nat.is_lt(s_rng(j, s_rng(K, M)), 1n) == True{} : Bool} -> {blen(Nat.add(K, j), M) == Nat.add(K, blen(j, s_rng(K, M))) : Nat},
    +c: Bool, +ec: {Nat.is_lt(s_rng(j, s_rng(K, M)), 1n) == c : Bool})
    -> {O.npick(c, blen(Nat.add(K, j), M), 1n+Nat.add(K, j)) == O.npick(c, Nat.add(K, blen(j, s_rng(K, M))), Nat.add(K, 1n+j)) : Nat}:
  match c:
    case True{}: ih(ec)
    case False{}: Equal.sym(Nat, Nat.add(K, 1n+j), 1n+Nat.add(K, j), s_add_succ(K, j))

# M >> K >= 1: the bit length within width K + j is K plus that of M >> K within j.
law blen_hi:
  for +K: Nat
  for +j: Nat
  for +M: Nat
  for +hge: {Nat.is_le(1n, s_rng(K, M)) == True{} : Bool}
  {blen(Nat.add(K, j), M) == Nat.add(K, blen(j, s_rng(K, M))) : Nat}
def blen_hi(K, j, M, hge):
  match j:
    case 0n:
      %Equal.sym(Nat, Nat.add(K, 0n), K, F.nat__add_zero(K)) : {blen(_, M) == _ : Nat}
      blen_sat(K, M, hge)
    case 1n+ +q:
      +R = s_rng(K, M)
      %Equal.sym(Nat, Nat.add(K, 1n+q), 1n+Nat.add(K, q), s_add_succ(K, q)) : {blen(_, M) == Nat.add(K, blen(1n+q, R)) : Nat}
      %Equal.sym(Nat, Nat.add(K, O.npick(Nat.is_lt(s_rng(q, R), 1n), blen(q, R), 1n+q)),
          O.npick(Nat.is_lt(s_rng(q, R), 1n), Nat.add(K, blen(q, R)), Nat.add(K, 1n+q)),
          npick_add(K, Nat.is_lt(s_rng(q, R), 1n), blen(q, R), 1n+q)) :
        {O.npick(Nat.is_lt(s_rng(Nat.add(K, q), M), 1n), blen(Nat.add(K, q), M), 1n+Nat.add(K, q)) == _ : Nat}
      %Equal.sym(Nat, s_rng(Nat.add(K, q), M), s_rng(q, R), rng_comp2(K, q, M)) :
        {O.npick(Nat.is_lt(_, 1n), blen(Nat.add(K, q), M), 1n+Nat.add(K, q)) == O.npick(Nat.is_lt(s_rng(q, R), 1n), Nat.add(K, blen(q, R)), Nat.add(K, 1n+q)) : Nat}
      hi_pick(K, q, M, e => blen_hi(K, q, M, hge), Nat.is_lt(s_rng(q, R), 1n), {==})

def rng_small(+K: Nat, +q: Nat, +M: Nat, +hlt: {Nat.is_lt(s_rng(K, M), 1n) == True{} : Bool})
    -> {Nat.is_lt(s_rng(Nat.add(K, q), M), 1n) == True{} : Bool}:
  %Equal.sym(Nat, s_rng(Nat.add(K, q), M), s_rng(q, s_rng(K, M)), rng_comp2(K, q, M)) : {Nat.is_lt(_, 1n) == True{} : Bool}
  %Equal.sym(Nat, s_rng(K, M), 0n, lt1_zero(s_rng(K, M), hlt)) : {Nat.is_lt(s_rng(q, _), 1n) == True{} : Bool}
  %Equal.sym(Nat, s_rng(q, 0n), 0n, rng_zero(q)) : {Nat.is_lt(_, 1n) == True{} : Bool}
  {==}

# M >> K = 0: the bit length within a wider width is the same.
law blen_lo:
  for +K: Nat
  for +j: Nat
  for +M: Nat
  for +hlt: {Nat.is_lt(s_rng(K, M), 1n) == True{} : Bool}
  {blen(Nat.add(K, j), M) == blen(K, M) : Nat}
def blen_lo(K, j, M, hlt):
  match j:
    case 0n:
      %Equal.sym(Nat, Nat.add(K, 0n), K, F.nat__add_zero(K)) : {blen(_, M) == blen(K, M) : Nat}
      {==}
    case 1n+ +q:
      %Equal.sym(Nat, Nat.add(K, 1n+q), 1n+Nat.add(K, q), s_add_succ(K, q)) : {blen(_, M) == blen(K, M) : Nat}
      %Equal.sym(Bool, Nat.is_lt(s_rng(Nat.add(K, q), M), 1n), True{}, rng_small(K, q, M, hlt)) :
        {O.npick(_, blen(Nat.add(K, q), M), 1n+Nat.add(K, q)) == blen(K, M) : Nat}
      blen_lo(K, q, M, hlt)


# B.words_depth(w) (src/buffer.bend) is the smallest depth d with w <= 2^d:
# w <= 2^words_depth(w) (wd_cover) and words_depth(w) <= k whenever w <= 2^k
# (wd_min), for w <= 2^k with k <= 32 (every length the runtime stores is
# bounded so, relative to some array depth). The runtime computes the bit
# length of w - 1 by halving the width: bits16 splits 32 bits at 16, bits8 16
# at 8, ..., bits1 2 at 1, each stage adding the width of the high half when
# the value reaches 2^K. Each stage is blen of its width (st1 .. st16). The
# thresholds 2, 4, 16, 256, 65536 are the runtime's O.pow2u(K) (compared as
# 32-bit words), and a stage condition is m >> K >= 1, so no statement
# mentions a closed number above 32.

# ---- thresholds and small sums ---------------------------------------------------------------

# 2^K <= m, as words and as m >> K >= 1.
def le_pow(+K: Nat, +m: U32, +hK: {Nat.is_lt(K, 32n) == True{} : Bool})
    -> {U32.is_le(O.pow2u(K), m) == Nat.is_le(1n, s_rng(K, U32.to_nat(m))) : Bool}:
  %Equal.sym(Bool, U32.is_le(O.pow2u(K), m), Nat.is_le(U32.to_nat(O.pow2u(K)), U32.to_nat(m)), s_le_nat(O.pow2u(K), m)) :
    {_ == Nat.is_le(1n, s_rng(K, U32.to_nat(m))) : Bool}
  %Equal.sym(Nat, U32.to_nat(O.pow2u(K)), O.pow2n(K), s_pow2u_val(K, hK)) :
    {Nat.is_le(_, U32.to_nat(m)) == Nat.is_le(1n, s_rng(K, U32.to_nat(m))) : Bool}
  pw_le(K, U32.to_nat(m))

def lit2() -> {O.pow2u(1n) == 2 : U32}: {==}
def lit4() -> {O.pow2u(2n) == 4 : U32}: {==}
def lit16() -> {O.pow2u(4n) == 16 : U32}: {==}
def lit256() -> {O.pow2u(8n) == 256 : U32}: {==}
def lit65536() -> {O.pow2u(16n) == 65536 : U32}: {==}

def le2(+m: U32) -> {U32.is_le(2, m) == Nat.is_le(1n, s_rng(1n, U32.to_nat(m))) : Bool}:
  %lit2() : {U32.is_le(_, m) == Nat.is_le(1n, s_rng(1n, U32.to_nat(m))) : Bool}
  le_pow(1n, m, {==})

def le4(+m: U32) -> {U32.is_le(4, m) == Nat.is_le(1n, s_rng(2n, U32.to_nat(m))) : Bool}:
  %lit4() : {U32.is_le(_, m) == Nat.is_le(1n, s_rng(2n, U32.to_nat(m))) : Bool}
  le_pow(2n, m, {==})

def le16(+m: U32) -> {U32.is_le(16, m) == Nat.is_le(1n, s_rng(4n, U32.to_nat(m))) : Bool}:
  %lit16() : {U32.is_le(_, m) == Nat.is_le(1n, s_rng(4n, U32.to_nat(m))) : Bool}
  le_pow(4n, m, {==})

def le256(+m: U32) -> {U32.is_le(256, m) == Nat.is_le(1n, s_rng(8n, U32.to_nat(m))) : Bool}:
  %lit256() : {U32.is_le(_, m) == Nat.is_le(1n, s_rng(8n, U32.to_nat(m))) : Bool}
  le_pow(8n, m, {==})

def le65536(+m: U32) -> {U32.is_le(65536, m) == Nat.is_le(1n, s_rng(16n, U32.to_nat(m))) : Bool}:
  %lit65536() : {U32.is_le(_, m) == Nat.is_le(1n, s_rng(16n, U32.to_nat(m))) : Bool}
  le_pow(16n, m, {==})

def acc_add(+acc: U32, +c: U32, +h: {Nat.is_le(Nat.add(U32.to_nat(acc), U32.to_nat(c)), 32n) == True{} : Bool})
    -> {U32.to_nat(U32.add(acc, c)) == Nat.add(U32.to_nat(acc), U32.to_nat(c)) : Nat}:
  s_add_nat(acc, c, 6n, {==}, F.nat__le_trans(Nat.add(U32.to_nat(acc), U32.to_nat(c)), 32n, O.pow2n(6n), h, {==}))

def eq0(+m: U32) -> {U32.is_eq(m, 0) == Nat.is_eq(U32.to_nat(m), 0n) : Bool}:
  %Equal.sym(Cmp, U32.cmp(m, 0), Nat.cmp(U32.to_nat(m), U32.to_nat(0)), F.u32__u32_cmp(m, 0)) : {Cmp.is_eq(_) == Nat.is_eq(U32.to_nat(m), 0n) : Bool}
  {==}

def lt1_eq(+X: Nat) -> {Nat.is_lt(X, 1n) == Nat.is_eq(X, 0n) : Bool}:
  match X:
    case 0n: {==}
    case 1n+ +p: F.nat__not_lt_zero(p)

def ha_less(+A: Nat, +c: Nat, +d: Nat, +h: {Nat.is_le(Nat.add(A, d), 32n) == True{} : Bool}, +cd: {Nat.is_le(c, d) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A, c), 32n) == True{} : Bool}:
  F.nat__le_trans(Nat.add(A, c), Nat.add(A, d), 32n, F.nat__le_add_left(c, d, A, cd), h)

# The accumulator after adding c: (A + c) + d <= 32 from A + (c + d) <= 32.
def ha_shift(+acc: U32, +c: U32, +d: Nat, +h: {Nat.is_le(Nat.add(U32.to_nat(acc), Nat.add(U32.to_nat(c), d)), 32n) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(U32.add(acc, c)), d), 32n) == True{} : Bool}:
  +h1 = ha_less(U32.to_nat(acc), U32.to_nat(c), Nat.add(U32.to_nat(c), d), h, Order.below_sum(U32.to_nat(c), d))
  %Equal.sym(Nat, U32.to_nat(U32.add(acc, c)), Nat.add(U32.to_nat(acc), U32.to_nat(c)), acc_add(acc, c, h1)) : {Nat.is_le(Nat.add(_, d), 32n) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(acc), U32.to_nat(c)), d), Nat.add(U32.to_nat(acc), Nat.add(U32.to_nat(c), d)), s_add_assoc(U32.to_nat(acc), U32.to_nat(c), d)) :
    {Nat.is_le(_, 32n) == True{} : Bool}
  h

# The high half: (A + K) + X = A + Y for Y = K + X.
def hi_eq(+A: Nat, +K: Nat, +X: Nat, +Y: Nat, +e: {Y == Nat.add(K, X) : Nat})
    -> {Nat.add(Nat.add(A, K), X) == Nat.add(A, Y) : Nat}:
  %Equal.sym(Nat, Y, Nat.add(K, X), e) : {Nat.add(Nat.add(A, K), X) == Nat.add(A, _) : Nat}
  s_add_assoc(A, K, X)

def lt1_of(+x: Nat, +c: {Nat.is_le(1n, x) == False{} : Bool}) -> {Nat.is_lt(x, 1n) == True{} : Bool}:
  F.nat__not_le_lt(1n, x, c)

# ---- widths 1 and 2 ----------------------------------------------------------------------

def st0c(+acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 1n), 32n) == True{} : Bool}, +z: Bool)
    -> {B.bits0(z, acc) == Nat.add(U32.to_nat(acc), O.npick(z, 0n, 1n)) : Nat}:
  match z:
    case True{}: Equal.sym(Nat, Nat.add(U32.to_nat(acc), 0n), U32.to_nat(acc), F.nat__add_zero(U32.to_nat(acc)))
    case False{}: acc_add(acc, 1, ha)

def st1c(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 2n), 32n) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(1n, s_rng(1n, U32.to_nat(m))) == c : Bool})
    -> {B.bits1(c, m, acc) == Nat.add(U32.to_nat(acc), blen(2n, U32.to_nat(m))) : Nat}:
  match c:
    case True{}:
      %Equal.sym(Bool, Nat.is_lt(s_rng(1n, U32.to_nat(m)), 1n), False{}, F.nat__le_not_lt(s_rng(1n, U32.to_nat(m)), 1n, ec)) :
        {U32.to_nat((acc + 2 : U32)) == Nat.add(U32.to_nat(acc), O.npick(_, blen(1n, U32.to_nat(m)), 2n)) : Nat}
      acc_add(acc, 2, ha)
    case False{}:
      %Equal.sym(Bool, Nat.is_lt(s_rng(1n, U32.to_nat(m)), 1n), True{}, lt1_of(s_rng(1n, U32.to_nat(m)), ec)) :
        {B.bits0(U32.is_eq(m, 0), acc) == Nat.add(U32.to_nat(acc), O.npick(_, blen(1n, U32.to_nat(m)), 2n)) : Nat}
      %Equal.sym(Bool, Nat.is_lt(U32.to_nat(m), 1n), Nat.is_eq(U32.to_nat(m), 0n), lt1_eq(U32.to_nat(m))) :
        {B.bits0(U32.is_eq(m, 0), acc) == Nat.add(U32.to_nat(acc), O.npick(_, 0n, 1n)) : Nat}
      %Equal.sym(Bool, U32.is_eq(m, 0), Nat.is_eq(U32.to_nat(m), 0n), eq0(m)) :
        {B.bits0(_, acc) == Nat.add(U32.to_nat(acc), O.npick(Nat.is_eq(U32.to_nat(m), 0n), 0n, 1n)) : Nat}
      st0c(acc, ha_less(U32.to_nat(acc), 1n, 2n, ha, {==}), Nat.is_eq(U32.to_nat(m), 0n))

def st1(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 2n), 32n) == True{} : Bool})
    -> {B.bits1(U32.is_le(2, m), m, acc) == Nat.add(U32.to_nat(acc), blen(2n, U32.to_nat(m))) : Nat}:
  %Equal.sym(Bool, U32.is_le(2, m), Nat.is_le(1n, s_rng(1n, U32.to_nat(m))), le2(m)) :
    {B.bits1(_, m, acc) == Nat.add(U32.to_nat(acc), blen(2n, U32.to_nat(m))) : Nat}
  st1c(m, acc, ha, Nat.is_le(1n, s_rng(1n, U32.to_nat(m))), {==})

# ---- the halving stages ------------------------------------------------------------------

def st2c(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 4n), 32n) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(1n, s_rng(2n, U32.to_nat(m))) == c : Bool})
    -> {B.bits2(c, m, acc) == Nat.add(U32.to_nat(acc), blen(4n, U32.to_nat(m))) : Nat}:
  match c:
    case True{}:
      +Mm = U32.to_nat(m)
      +m2 = U32.shrn(m, 2n)
      +a2 = (acc + 2 : U32)
      +s = st1(m2, a2, ha_shift(acc, 2, 2n, ha))
      %Equal.sym(Nat, B.bits1(U32.is_le(2, m2), m2, a2), Nat.add(U32.to_nat(a2), blen(2n, U32.to_nat(m2))), s) : {_ == Nat.add(U32.to_nat(acc), blen(4n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(a2), Nat.add(U32.to_nat(acc), 2n), acc_add(acc, 2, ha_less(U32.to_nat(acc), 2n, 4n, ha, {==}))) :
        {Nat.add(_, blen(2n, U32.to_nat(m2))) == Nat.add(U32.to_nat(acc), blen(4n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(m2), s_rng(2n, Mm), shrk(2n, m)) :
        {Nat.add(Nat.add(U32.to_nat(acc), 2n), blen(2n, _)) == Nat.add(U32.to_nat(acc), blen(4n, Mm)) : Nat}
      hi_eq(U32.to_nat(acc), 2n, blen(2n, s_rng(2n, Mm)), blen(4n, Mm), blen_hi(2n, 2n, Mm, ec))
    case False{}:
      +Mm = U32.to_nat(m)
      %Equal.sym(Nat, blen(4n, Mm), blen(2n, Mm), blen_lo(2n, 2n, Mm, lt1_of(s_rng(2n, Mm), ec))) :
        {B.bits1(U32.is_le(2, m), m, acc) == Nat.add(U32.to_nat(acc), _) : Nat}
      st1(m, acc, ha_less(U32.to_nat(acc), 2n, 4n, ha, {==}))

def st2(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 4n), 32n) == True{} : Bool})
    -> {B.bits2(U32.is_le(4, m), m, acc) == Nat.add(U32.to_nat(acc), blen(4n, U32.to_nat(m))) : Nat}:
  %Equal.sym(Bool, U32.is_le(4, m), Nat.is_le(1n, s_rng(2n, U32.to_nat(m))), le4(m)) :
    {B.bits2(_, m, acc) == Nat.add(U32.to_nat(acc), blen(4n, U32.to_nat(m))) : Nat}
  st2c(m, acc, ha, Nat.is_le(1n, s_rng(2n, U32.to_nat(m))), {==})

def st4c(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 8n), 32n) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(1n, s_rng(4n, U32.to_nat(m))) == c : Bool})
    -> {B.bits4(c, m, acc) == Nat.add(U32.to_nat(acc), blen(8n, U32.to_nat(m))) : Nat}:
  match c:
    case True{}:
      +Mm = U32.to_nat(m)
      +m2 = U32.shrn(m, 4n)
      +a2 = (acc + 4 : U32)
      +s = st2(m2, a2, ha_shift(acc, 4, 4n, ha))
      %Equal.sym(Nat, B.bits2(U32.is_le(4, m2), m2, a2), Nat.add(U32.to_nat(a2), blen(4n, U32.to_nat(m2))), s) : {_ == Nat.add(U32.to_nat(acc), blen(8n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(a2), Nat.add(U32.to_nat(acc), 4n), acc_add(acc, 4, ha_less(U32.to_nat(acc), 4n, 8n, ha, {==}))) :
        {Nat.add(_, blen(4n, U32.to_nat(m2))) == Nat.add(U32.to_nat(acc), blen(8n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(m2), s_rng(4n, Mm), shrk(4n, m)) :
        {Nat.add(Nat.add(U32.to_nat(acc), 4n), blen(4n, _)) == Nat.add(U32.to_nat(acc), blen(8n, Mm)) : Nat}
      hi_eq(U32.to_nat(acc), 4n, blen(4n, s_rng(4n, Mm)), blen(8n, Mm), blen_hi(4n, 4n, Mm, ec))
    case False{}:
      +Mm = U32.to_nat(m)
      %Equal.sym(Nat, blen(8n, Mm), blen(4n, Mm), blen_lo(4n, 4n, Mm, lt1_of(s_rng(4n, Mm), ec))) :
        {B.bits2(U32.is_le(4, m), m, acc) == Nat.add(U32.to_nat(acc), _) : Nat}
      st2(m, acc, ha_less(U32.to_nat(acc), 4n, 8n, ha, {==}))

def st4(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 8n), 32n) == True{} : Bool})
    -> {B.bits4(U32.is_le(16, m), m, acc) == Nat.add(U32.to_nat(acc), blen(8n, U32.to_nat(m))) : Nat}:
  %Equal.sym(Bool, U32.is_le(16, m), Nat.is_le(1n, s_rng(4n, U32.to_nat(m))), le16(m)) :
    {B.bits4(_, m, acc) == Nat.add(U32.to_nat(acc), blen(8n, U32.to_nat(m))) : Nat}
  st4c(m, acc, ha, Nat.is_le(1n, s_rng(4n, U32.to_nat(m))), {==})

# Width 16 = 8 + 8 and 32 = 16 + 16, by small equations.
def e88() -> {Nat.add(8n, 8n) == 16n : Nat}: {==}
def e1616() -> {Nat.add(16n, 16n) == 32n : Nat}: {==}

def bh8(+X: Nat, +ge: {Nat.is_le(1n, s_rng(8n, X)) == True{} : Bool}) -> {blen(16n, X) == Nat.add(8n, blen(8n, s_rng(8n, X))) : Nat}:
  %e88() : {blen(_, X) == Nat.add(8n, blen(8n, s_rng(8n, X))) : Nat}
  blen_hi(8n, 8n, X, ge)

def bl8(+X: Nat, +h: {Nat.is_lt(s_rng(8n, X), 1n) == True{} : Bool}) -> {blen(16n, X) == blen(8n, X) : Nat}:
  %e88() : {blen(_, X) == blen(8n, X) : Nat}
  blen_lo(8n, 8n, X, h)

def bh16(+X: Nat, +ge: {Nat.is_le(1n, s_rng(16n, X)) == True{} : Bool}) -> {blen(32n, X) == Nat.add(16n, blen(16n, s_rng(16n, X))) : Nat}:
  %e1616() : {blen(_, X) == Nat.add(16n, blen(16n, s_rng(16n, X))) : Nat}
  blen_hi(16n, 16n, X, ge)

def bl16(+X: Nat, +h: {Nat.is_lt(s_rng(16n, X), 1n) == True{} : Bool}) -> {blen(32n, X) == blen(16n, X) : Nat}:
  %e1616() : {blen(_, X) == blen(16n, X) : Nat}
  blen_lo(16n, 16n, X, h)

def st8c(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 16n), 32n) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(1n, s_rng(8n, U32.to_nat(m))) == c : Bool})
    -> {B.bits8(c, m, acc) == Nat.add(U32.to_nat(acc), blen(16n, U32.to_nat(m))) : Nat}:
  match c:
    case True{}:
      +Mm = U32.to_nat(m)
      +m2 = U32.shrn(m, 8n)
      +a2 = (acc + 8 : U32)
      +s = st4(m2, a2, ha_shift(acc, 8, 8n, ha))
      %Equal.sym(Nat, B.bits4(U32.is_le(16, m2), m2, a2), Nat.add(U32.to_nat(a2), blen(8n, U32.to_nat(m2))), s) : {_ == Nat.add(U32.to_nat(acc), blen(16n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(a2), Nat.add(U32.to_nat(acc), 8n), acc_add(acc, 8, ha_less(U32.to_nat(acc), 8n, 16n, ha, {==}))) :
        {Nat.add(_, blen(8n, U32.to_nat(m2))) == Nat.add(U32.to_nat(acc), blen(16n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(m2), s_rng(8n, Mm), shrk(8n, m)) :
        {Nat.add(Nat.add(U32.to_nat(acc), 8n), blen(8n, _)) == Nat.add(U32.to_nat(acc), blen(16n, Mm)) : Nat}
      hi_eq(U32.to_nat(acc), 8n, blen(8n, s_rng(8n, Mm)), blen(16n, Mm), bh8(Mm, ec))
    case False{}:
      +Mm = U32.to_nat(m)
      %Equal.sym(Nat, blen(16n, Mm), blen(8n, Mm), bl8(Mm, lt1_of(s_rng(8n, Mm), ec))) :
        {B.bits4(U32.is_le(16, m), m, acc) == Nat.add(U32.to_nat(acc), _) : Nat}
      st4(m, acc, ha_less(U32.to_nat(acc), 8n, 16n, ha, {==}))

def st8(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 16n), 32n) == True{} : Bool})
    -> {B.bits8(U32.is_le(256, m), m, acc) == Nat.add(U32.to_nat(acc), blen(16n, U32.to_nat(m))) : Nat}:
  %Equal.sym(Bool, U32.is_le(256, m), Nat.is_le(1n, s_rng(8n, U32.to_nat(m))), le256(m)) :
    {B.bits8(_, m, acc) == Nat.add(U32.to_nat(acc), blen(16n, U32.to_nat(m))) : Nat}
  st8c(m, acc, ha, Nat.is_le(1n, s_rng(8n, U32.to_nat(m))), {==})

def st16c(+m: U32, +c: Bool, +ec: {Nat.is_le(1n, s_rng(16n, U32.to_nat(m))) == c : Bool})
    -> {B.bits16(c, m) == blen(32n, U32.to_nat(m)) : Nat}:
  match c:
    case True{}:
      +Mm = U32.to_nat(m)
      +m2 = U32.shrn(m, 16n)
      +s = st8(m2, 16, {==})
      %Equal.sym(Nat, B.bits8(U32.is_le(256, m2), m2, 16), Nat.add(U32.to_nat(16), blen(16n, U32.to_nat(m2))), s) : {_ == blen(32n, Mm) : Nat}
      %Equal.sym(Nat, U32.to_nat(m2), s_rng(16n, Mm), shrk(16n, m)) : {Nat.add(16n, blen(16n, _)) == blen(32n, Mm) : Nat}
      Equal.sym(Nat, blen(32n, Mm), Nat.add(16n, blen(16n, s_rng(16n, Mm))), bh16(Mm, ec))
    case False{}:
      +Mm = U32.to_nat(m)
      %Equal.sym(Nat, blen(32n, Mm), blen(16n, Mm), bl16(Mm, lt1_of(s_rng(16n, Mm), ec))) : {B.bits8(U32.is_le(256, m), m, 0) == _ : Nat}
      st8(m, 0, {==})

def st16(+m: U32) -> {B.bits16(U32.is_le(65536, m), m) == blen(32n, U32.to_nat(m)) : Nat}:
  %Equal.sym(Bool, U32.is_le(65536, m), Nat.is_le(1n, s_rng(16n, U32.to_nat(m))), le65536(m)) :
    {B.bits16(_, m) == blen(32n, U32.to_nat(m)) : Nat}
  st16c(m, Nat.is_le(1n, s_rng(16n, U32.to_nat(m))), {==})

# ---- words_depth ---------------------------------------------------------------------------

def one_le(+W: Nat, +ez: {Nat.is_eq(W, 0n) == False{} : Bool}) -> {Nat.is_le(1n, W) == True{} : Bool}:
  F.nat__lt_succ_le_succ(0n, W, F.nat__lt_or_eq(0n, W, Order.zero_le(W),
    Equal.trans(Bool, Nat.is_eq(0n, W), Nat.is_eq(W, 0n), False{}, F.flat__is_eq_sym(0n, W), ez)))

def sub1_lt(+W: Nat, +h: {Nat.is_le(1n, W) == True{} : Bool}) -> {Nat.is_lt(Nat.sub(W, 1n), W) == True{} : Bool}:
  match W:
    case 0n: Empty.absurd({Nat.is_lt(Nat.sub(0n, 1n), 0n) == True{} : Bool}, s_lt_zero_absurd(0n, h))
    case 1n+ +p:
      %Equal.sym(Nat, Nat.sub(p, 0n), p, F.nat__sub_zero(p)) : {Nat.is_lt(_, 1n+p) == True{} : Bool}
      F.nat__le_lt_succ(p, p, F.nat__le_refl(p))

# For w > 0: words_depth(w) is the bit length of w - 1.
def wd_nz(+w: U32, +ez: {Nat.is_eq(U32.to_nat(w), 0n) == False{} : Bool})
    -> {B.words_depth_nz(False{}, w) == blen(32n, Nat.sub(U32.to_nat(w), 1n)) : Nat}:
  %F.u32__sub_nat(w, 1, one_le(U32.to_nat(w), ez)) : {B.words_depth_nz(False{}, w) == blen(32n, _) : Nat}
  st16((w - 1 : U32))

# Below width k <= 32, the 32-bit length is the width-k length.
def b32(+k: Nat, +M: Nat, +hk: {Nat.is_le(k, 32n) == True{} : Bool}, +hM: {Nat.is_lt(M, O.pow2n(k)) == True{} : Bool})
    -> {blen(32n, M) == blen(k, M) : Nat}:
  %F.nat__sub_add(32n, k, hk) : {blen(_, M) == blen(k, M) : Nat}
  blen_lo(k, Nat.sub(32n, k), M, small_rng(k, M, hM))

def wdc(+w: U32, +k: Nat, +hk: {Nat.is_le(k, 32n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(w), O.pow2n(k)) == True{} : Bool},
    +z: Bool, +ez: {Nat.is_eq(U32.to_nat(w), 0n) == z : Bool})
    -> {Nat.is_le(U32.to_nat(w), O.pow2n(B.words_depth_nz(z, w))) == True{} : Bool}:
  match z:
    case True{}:
      %Equal.sym(Nat, U32.to_nat(w), 0n, F.nat__eq_from_is_eq(U32.to_nat(w), 0n, ez)) : {Nat.is_le(_, 1n) == True{} : Bool}
      {==}
    case False{}:
      +W = U32.to_nat(w)
      +M = Nat.sub(W, 1n)
      +h1 = one_le(W, ez)
      +hM = F.nat__lt_le_trans(M, W, O.pow2n(k), sub1_lt(W, h1), h)
      %Equal.sym(Nat, B.words_depth_nz(False{}, w), blen(32n, M), wd_nz(w, ez)) : {Nat.is_le(W, O.pow2n(_)) == True{} : Bool}
      %Equal.sym(Nat, blen(32n, M), blen(k, M), b32(k, M, hk, hM)) : {Nat.is_le(W, O.pow2n(_)) == True{} : Bool}
      %F.nat__sub_add(W, 1n, h1) : {Nat.is_le(_, O.pow2n(blen(k, M))) == True{} : Bool}
      F.nat__lt_succ_le_succ(M, O.pow2n(blen(k, M)), blen_cover(k, M, small_rng(k, M, hM)))

# w <= 2^words_depth(w), for w <= 2^k with k <= 32.
def wd_cover(+w: U32, +k: Nat, +hk: {Nat.is_le(k, 32n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(w), O.pow2n(k)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(w), O.pow2n(B.words_depth(w))) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_eq(w, 0), Nat.is_eq(U32.to_nat(w), 0n), eq0(w)) : {Nat.is_le(U32.to_nat(w), O.pow2n(B.words_depth_nz(_, w))) == True{} : Bool}
  wdc(w, k, hk, h, Nat.is_eq(U32.to_nat(w), 0n), {==})

def wdm(+w: U32, +k: Nat, +h: {Nat.is_le(U32.to_nat(w), O.pow2n(k)) == True{} : Bool}, +z: Bool, +ez: {Nat.is_eq(U32.to_nat(w), 0n) == z : Bool})
    -> {Nat.is_le(B.words_depth_nz(z, w), k) == True{} : Bool}:
  match z:
    case True{}: Order.zero_le(k)
    case False{}:
      +W = U32.to_nat(w)
      +h1 = one_le(W, ez)
      +lt = F.nat__lt_le_trans(Nat.sub(W, 1n), W, O.pow2n(k), sub1_lt(W, h1), h)
      %Equal.sym(Nat, B.words_depth_nz(False{}, w), blen(32n, Nat.sub(W, 1n)), wd_nz(w, ez)) : {Nat.is_le(_, k) == True{} : Bool}
      blen_min(32n, Nat.sub(W, 1n), k, lt)

# words_depth(w) <= k whenever w <= 2^k.
def wd_min(+w: U32, +k: Nat, +h: {Nat.is_le(U32.to_nat(w), O.pow2n(k)) == True{} : Bool}) -> {Nat.is_le(B.words_depth(w), k) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_eq(w, 0), Nat.is_eq(U32.to_nat(w), 0n), eq0(w)) : {Nat.is_le(B.words_depth_nz(_, w), k) == True{} : Bool}
  wdm(w, k, h, Nat.is_eq(U32.to_nat(w), 0n), {==})

# ==== the U32 depth (B.words_depth_u) is the Nat depth ====

def u0(+z: Bool, +acc: U32) -> {U32.to_nat(B.ubits0(z, acc)) == B.bits0(z, acc) : Nat}:
  match z:
    case True{}: {==}
    case False{}: {==}

def u1(+big: Bool, +m: U32, +acc: U32) -> {U32.to_nat(B.ubits1(big, m, acc)) == B.bits1(big, m, acc) : Nat}:
  match big:
    case True{}: {==}
    case False{}: u0(U32.is_eq(m, 0), acc)

def u2(+big: Bool, +m: U32, +acc: U32) -> {U32.to_nat(B.ubits2(big, m, acc)) == B.bits2(big, m, acc) : Nat}:
  match big:
    case True{}: u1(U32.is_le(2, U32.shrn(m, 2n)), U32.shrn(m, 2n), (acc + 2 : U32))
    case False{}: u1(U32.is_le(2, m), m, acc)

def u4(+big: Bool, +m: U32, +acc: U32) -> {U32.to_nat(B.ubits4(big, m, acc)) == B.bits4(big, m, acc) : Nat}:
  match big:
    case True{}: u2(U32.is_le(4, U32.shrn(m, 4n)), U32.shrn(m, 4n), (acc + 4 : U32))
    case False{}: u2(U32.is_le(4, m), m, acc)

def u8(+big: Bool, +m: U32, +acc: U32) -> {U32.to_nat(B.ubits8(big, m, acc)) == B.bits8(big, m, acc) : Nat}:
  match big:
    case True{}: u4(U32.is_le(16, U32.shrn(m, 8n)), U32.shrn(m, 8n), (acc + 8 : U32))
    case False{}: u4(U32.is_le(16, m), m, acc)

def u16(+big: Bool, +m: U32) -> {U32.to_nat(B.ubits16(big, m)) == B.bits16(big, m) : Nat}:
  match big:
    case True{}: u8(U32.is_le(256, U32.shrn(m, 16n)), U32.shrn(m, 16n), 16)
    case False{}: u8(U32.is_le(256, m), m, 0)

def unz(+z: Bool, +w: U32) -> {U32.to_nat(B.words_depth_unz(z, w)) == B.words_depth_nz(z, w) : Nat}:
  match z:
    case True{}: {==}
    case False{}: u16(U32.is_le(65536, (w - 1 : U32)), (w - 1 : U32))

def wdu(+w: U32) -> {U32.to_nat(B.words_depth_u(w)) == B.words_depth(w) : Nat}:
  unz(U32.is_eq(w, 0), w)
