import Base
import ../../src/obj.bend as O
import ../../proofs/nat_order.bend as Order
import ../../proofs/nat_algebra.bend as NA
import ../compact/found.bend as F
import ./mtree_defs.bend as MD
import ./mtree_run.bend as MR
import ./ctree.bend as CT
import ./cidx.bend as CX

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
  {U32.to_nat(U32.shrn(x, k)) == CT.rng(k, U32.to_nat(x)) : Nat}
def shrk(k, x):
  match k:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32.shrn(x, p), 1n)), CT.h2(U32.to_nat(U32.shrn(x, p))), CX.shr1(U32.shrn(x, p))) :
        {_ == CT.h2(CT.rng(p, U32.to_nat(x))) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(x, p)), CT.rng(p, U32.to_nat(x)), shrk(p, x)) :
        {CT.h2(_) == CT.h2(CT.rng(p, U32.to_nat(x))) : Nat}
      {==}

law h2_lt_inv:
  for +y: Nat
  for +P: Nat
  for +h: {Nat.is_lt(CT.h2(y), P) == True{} : Bool}
  {Nat.is_lt(y, Nat.double(P)) == True{} : Bool}
def h2_lt_inv(y, P, h):
  match y P:
    case 0n 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, MD.false_true(h))
    case 0n 1n+Q: {==}
    case 1n 0n: Empty.absurd({Nat.is_lt(1n, 0n) == True{} : Bool}, MD.false_true(h))
    case 1n 1n+Q: {==}
    case 2n+p 0n: Empty.absurd({Nat.is_lt(2n+p, 0n) == True{} : Bool}, MD.false_true(h))
    case 2n+ +p 1n+ +Q: h2_lt_inv(p, Q, h)

def shift_pow(+K: Nat, +j: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(Nat.add(1n+K, j))) == True{} : Bool})
    -> {Nat.is_lt(X, O.pow2n(Nat.add(K, 1n+j))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(K, 1n+j), 1n+Nat.add(K, j), MR.add_succ(K, j)) : {Nat.is_lt(X, O.pow2n(_)) == True{} : Bool}
  h

def shift_pow_inv(+K: Nat, +j: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(Nat.add(K, 1n+j))) == True{} : Bool})
    -> {Nat.is_lt(X, O.pow2n(Nat.add(1n+K, j))) == True{} : Bool}:
  %MR.add_succ(K, j) : {Nat.is_lt(X, O.pow2n(_)) == True{} : Bool}
  h

# X < 2^(K + j) exactly when X >> K < 2^j.
law rlt:
  for +K: Nat
  for +j: Nat
  for +X: Nat
  for +h: {Nat.is_lt(X, O.pow2n(Nat.add(K, j))) == True{} : Bool}
  {Nat.is_lt(CT.rng(K, X), O.pow2n(j)) == True{} : Bool}
def rlt(K, j, X, h):
  match K:
    case 0n: h
    case 1n+ +K2: CT.h2_lt(CT.rng(K2, X), O.pow2n(j), rlt(K2, 1n+j, X, shift_pow(K2, j, X, h)))

law rlt_inv:
  for +K: Nat
  for +j: Nat
  for +X: Nat
  for +h: {Nat.is_lt(CT.rng(K, X), O.pow2n(j)) == True{} : Bool}
  {Nat.is_lt(X, O.pow2n(Nat.add(K, j))) == True{} : Bool}
def rlt_inv(K, j, X, h):
  match K:
    case 0n: h
    case 1n+ +K2: shift_pow_inv(K2, j, X, rlt_inv(K2, 1n+j, X, h2_lt_inv(CT.rng(K2, X), O.pow2n(j), h)))

def k0(+K: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(K)) == True{} : Bool}) -> {Nat.is_lt(X, O.pow2n(Nat.add(K, 0n))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(K, 0n), K, F.nat__add_zero(K)) : {Nat.is_lt(X, O.pow2n(_)) == True{} : Bool}
  h

def k0_inv(+K: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(Nat.add(K, 0n))) == True{} : Bool}) -> {Nat.is_lt(X, O.pow2n(K)) == True{} : Bool}:
  %F.nat__add_zero(K) : {Nat.is_lt(X, O.pow2n(_)) == True{} : Bool}
  h

# X < 2^K exactly when X >> K < 1.
def small_rng(+K: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(K)) == True{} : Bool}) -> {Nat.is_lt(CT.rng(K, X), 1n) == True{} : Bool}:
  rlt(K, 0n, X, k0(K, X, h))

def small_inv(+K: Nat, +X: Nat, +h: {Nat.is_lt(CT.rng(K, X), 1n) == True{} : Bool}) -> {Nat.is_lt(X, O.pow2n(K)) == True{} : Bool}:
  k0_inv(K, X, rlt_inv(K, 0n, X, h))

# Two Bools that imply each other are equal.
def beq(+a: Bool, +b: Bool, f: {a == True{} : Bool} -> {b == True{} : Bool}, g: {b == True{} : Bool} -> {a == True{} : Bool}) -> {a == b : Bool}:
  match a:
    case True{}: Equal.sym(Bool, b, True{}, f({==}))
    case False{}:
      match b:
        case True{}: Empty.absurd({False{} == True{} : Bool}, MD.false_true(g({==})))
        case False{}: {==}

def small_eq(+K: Nat, +X: Nat) -> {Nat.is_lt(X, O.pow2n(K)) == Nat.is_lt(CT.rng(K, X), 1n) : Bool}:
  beq(Nat.is_lt(X, O.pow2n(K)), Nat.is_lt(CT.rng(K, X), 1n), e => small_rng(K, X, e), e => small_inv(K, X, e))

def le_of_not_lt(+a: Nat, +b: Nat, +c: Bool, +ec: {Nat.is_lt(a, b) == c : Bool}) -> {Nat.is_le(b, a) == Bool.not(c) : Bool}:
  match c:
    case True{}: F.nat__lt_not_le(a, b, ec)
    case False{}: F.nat__not_lt_le(a, b, ec)

# 2^K <= X exactly when X >> K >= 1.
def pw_le(+K: Nat, +X: Nat) -> {Nat.is_le(O.pow2n(K), X) == Nat.is_le(1n, CT.rng(K, X)) : Bool}:
  Equal.trans(Bool, Nat.is_le(O.pow2n(K), X), Bool.not(Nat.is_lt(X, O.pow2n(K))), Nat.is_le(1n, CT.rng(K, X)),
    le_of_not_lt(X, O.pow2n(K), Nat.is_lt(X, O.pow2n(K)), {==}),
    Equal.trans(Bool, Bool.not(Nat.is_lt(X, O.pow2n(K))), Bool.not(Nat.is_lt(CT.rng(K, X), 1n)), Nat.is_le(1n, CT.rng(K, X)),
      Equal.cong(Bool, Bool, z => Bool.not(z), Nat.is_lt(X, O.pow2n(K)), Nat.is_lt(CT.rng(K, X), 1n), small_eq(K, X)),
      Equal.sym(Bool, Nat.is_le(1n, CT.rng(K, X)), Bool.not(Nat.is_lt(CT.rng(K, X), 1n)), le_of_not_lt(CT.rng(K, X), 1n, Nat.is_lt(CT.rng(K, X), 1n), {==}))))

# rng composes: (x >> K) >> q = x >> (q + K).
law rng_comp:
  for +q: Nat
  for +K: Nat
  for +X: Nat
  {CT.rng(q, CT.rng(K, X)) == CT.rng(Nat.add(q, K), X) : Nat}
def rng_comp(q, K, X):
  match q:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, CT.rng(p, CT.rng(K, X)), CT.rng(Nat.add(p, K), X), rng_comp(p, K, X)) : {CT.h2(_) == CT.h2(CT.rng(Nat.add(p, K), X)) : Nat}
      {==}

def rng_comp2(+K: Nat, +q: Nat, +X: Nat) -> {CT.rng(Nat.add(K, q), X) == CT.rng(q, CT.rng(K, X)) : Nat}:
  %Equal.sym(Nat, Nat.add(K, q), Nat.add(q, K), NA.add_commute(K, q)) : {CT.rng(_, X) == CT.rng(q, CT.rng(K, X)) : Nat}
  Equal.sym(Nat, CT.rng(q, CT.rng(K, X)), CT.rng(Nat.add(q, K), X), rng_comp(q, K, X))

law rng_zero:
  for +l: Nat
  {CT.rng(l, 0n) == 0n : Nat}
def rng_zero(l):
  match l:
    case 0n: {==}
    case 1n+ +k:
      %Equal.sym(Nat, CT.rng(k, 0n), 0n, rng_zero(k)) : {CT.h2(_) == 0n : Nat}
      {==}

def lt1_zero(+x: Nat, +h: {Nat.is_lt(x, 1n) == True{} : Bool}) -> {x == 0n : Nat}:
  match x:
    case 0n: {==}
    case 1n+ +p: Empty.absurd({1n+p == 0n : Nat}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(p, 0n), True{}, Equal.sym(Bool, Nat.is_lt(p, 0n), False{}, F.nat__not_lt_zero(p)), h)))

# ---- the bit length ------------------------------------------------------------------------

def blen(+k: Nat, +M: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n+ +j: O.npick(Nat.is_lt(CT.rng(j, M), 1n), blen(j, M), 1n+j)

def bc_pick(+j: Nat, +M: Nat, +h: {Nat.is_lt(CT.rng(1n+j, M), 1n) == True{} : Bool},
    ih: {Nat.is_lt(CT.rng(j, M), 1n) == True{} : Bool} -> {Nat.is_lt(M, O.pow2n(blen(j, M))) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_lt(CT.rng(j, M), 1n) == c : Bool})
    -> {Nat.is_lt(M, O.pow2n(O.npick(c, blen(j, M), 1n+j))) == True{} : Bool}:
  match c:
    case True{}: ih(ec)
    case False{}: small_inv(1n+j, M, h)

# M < 2^blen(k, M) when M >> k = 0.
law blen_cover:
  for +k: Nat
  for +M: Nat
  for +h: {Nat.is_lt(CT.rng(k, M), 1n) == True{} : Bool}
  {Nat.is_lt(M, O.pow2n(blen(k, M))) == True{} : Bool}
def blen_cover(k, M, h):
  match k:
    case 0n: h
    case 1n+ +j: bc_pick(j, M, h, e => blen_cover(j, M, e), Nat.is_lt(CT.rng(j, M), 1n), {==})

# 2^i <= M < 2^j: i < j.
def pow2_between(+i: Nat, +j: Nat, +M: Nat, +h1: {Nat.is_lt(M, O.pow2n(i)) == False{} : Bool}, +h2: {Nat.is_lt(M, O.pow2n(j)) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(j, i) == c : Bool}) -> {Nat.is_le(1n+i, j) == True{} : Bool}:
  match c:
    case True{}:
      Empty.absurd({Nat.is_le(1n+i, j) == True{} : Bool},
        Order.le_lt_conflict(O.pow2n(j), M,
          F.nat__le_trans(O.pow2n(j), O.pow2n(i), M, CT.pow2_mono(j, i, ec), F.nat__not_lt_le(M, O.pow2n(i), h1)), h2))
    case False{}: F.nat__lt_succ_le_succ(i, j, F.nat__not_le_lt(j, i, ec))

def not_small(+i: Nat, +M: Nat, +ec: {Nat.is_lt(CT.rng(i, M), 1n) == False{} : Bool}) -> {Nat.is_lt(M, O.pow2n(i)) == False{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(M, O.pow2n(i)), Nat.is_lt(CT.rng(i, M), 1n), False{}, small_eq(i, M), ec)

def bm_pick(+i: Nat, +M: Nat, +j: Nat, +h: {Nat.is_lt(M, O.pow2n(j)) == True{} : Bool},
    ih: {Nat.is_lt(CT.rng(i, M), 1n) == True{} : Bool} -> {Nat.is_le(blen(i, M), j) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_lt(CT.rng(i, M), 1n) == c : Bool})
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
    case 1n+ +i: bm_pick(i, M, j, h, e => blen_min(i, M, j, h), Nat.is_lt(CT.rng(i, M), 1n), {==})

# ---- saturation and splitting ----------------------------------------------------------------

law h2_ge1:
  for +y: Nat
  for +h: {Nat.is_le(1n, CT.h2(y)) == True{} : Bool}
  {Nat.is_lt(y, 1n) == False{} : Bool}
def h2_ge1(y, h):
  match y:
    case 0n: Empty.absurd({Nat.is_lt(0n, 1n) == False{} : Bool}, MD.false_true(h))
    case 1n+ +p: F.nat__not_lt_zero(p)

def sat_pick(+k: Nat, +M: Nat, +c: Bool, +ec: {Nat.is_lt(CT.rng(k, M), 1n) == c : Bool}, +h: {Nat.is_lt(CT.rng(k, M), 1n) == False{} : Bool})
    -> {O.npick(c, blen(k, M), 1n+k) == 1n+k : Nat}:
  match c:
    case True{}: Empty.absurd({blen(k, M) == 1n+k : Nat}, MD.true_false(Equal.trans(Bool, True{}, Nat.is_lt(CT.rng(k, M), 1n), False{}, Equal.sym(Bool, Nat.is_lt(CT.rng(k, M), 1n), True{}, ec), h)))
    case False{}: {==}

# M >> K >= 1: the bit length within width K is K.
law blen_sat:
  for +K: Nat
  for +M: Nat
  for +hge: {Nat.is_le(1n, CT.rng(K, M)) == True{} : Bool}
  {blen(K, M) == K : Nat}
def blen_sat(K, M, hge):
  match K:
    case 0n: {==}
    case 1n+ +k: sat_pick(k, M, Nat.is_lt(CT.rng(k, M), 1n), {==}, h2_ge1(CT.rng(k, M), hge))

def npick_add(+K: Nat, +c: Bool, +x: Nat, +y: Nat) -> {Nat.add(K, O.npick(c, x, y)) == O.npick(c, Nat.add(K, x), Nat.add(K, y)) : Nat}:
  match c:
    case True{}: {==}
    case False{}: {==}

def hi_pick(+K: Nat, +j: Nat, +M: Nat,
    ih: {Nat.is_lt(CT.rng(j, CT.rng(K, M)), 1n) == True{} : Bool} -> {blen(Nat.add(K, j), M) == Nat.add(K, blen(j, CT.rng(K, M))) : Nat},
    +c: Bool, +ec: {Nat.is_lt(CT.rng(j, CT.rng(K, M)), 1n) == c : Bool})
    -> {O.npick(c, blen(Nat.add(K, j), M), 1n+Nat.add(K, j)) == O.npick(c, Nat.add(K, blen(j, CT.rng(K, M))), Nat.add(K, 1n+j)) : Nat}:
  match c:
    case True{}: ih(ec)
    case False{}: Equal.sym(Nat, Nat.add(K, 1n+j), 1n+Nat.add(K, j), MR.add_succ(K, j))

# M >> K >= 1: the bit length within width K + j is K plus that of M >> K within j.
law blen_hi:
  for +K: Nat
  for +j: Nat
  for +M: Nat
  for +hge: {Nat.is_le(1n, CT.rng(K, M)) == True{} : Bool}
  {blen(Nat.add(K, j), M) == Nat.add(K, blen(j, CT.rng(K, M))) : Nat}
def blen_hi(K, j, M, hge):
  match j:
    case 0n:
      %Equal.sym(Nat, Nat.add(K, 0n), K, F.nat__add_zero(K)) : {blen(_, M) == _ : Nat}
      blen_sat(K, M, hge)
    case 1n+ +q:
      +R = CT.rng(K, M)
      %Equal.sym(Nat, Nat.add(K, 1n+q), 1n+Nat.add(K, q), MR.add_succ(K, q)) : {blen(_, M) == Nat.add(K, blen(1n+q, R)) : Nat}
      %Equal.sym(Nat, Nat.add(K, O.npick(Nat.is_lt(CT.rng(q, R), 1n), blen(q, R), 1n+q)),
          O.npick(Nat.is_lt(CT.rng(q, R), 1n), Nat.add(K, blen(q, R)), Nat.add(K, 1n+q)),
          npick_add(K, Nat.is_lt(CT.rng(q, R), 1n), blen(q, R), 1n+q)) :
        {O.npick(Nat.is_lt(CT.rng(Nat.add(K, q), M), 1n), blen(Nat.add(K, q), M), 1n+Nat.add(K, q)) == _ : Nat}
      %Equal.sym(Nat, CT.rng(Nat.add(K, q), M), CT.rng(q, R), rng_comp2(K, q, M)) :
        {O.npick(Nat.is_lt(_, 1n), blen(Nat.add(K, q), M), 1n+Nat.add(K, q)) == O.npick(Nat.is_lt(CT.rng(q, R), 1n), Nat.add(K, blen(q, R)), Nat.add(K, 1n+q)) : Nat}
      hi_pick(K, q, M, e => blen_hi(K, q, M, hge), Nat.is_lt(CT.rng(q, R), 1n), {==})

def rng_small(+K: Nat, +q: Nat, +M: Nat, +hlt: {Nat.is_lt(CT.rng(K, M), 1n) == True{} : Bool})
    -> {Nat.is_lt(CT.rng(Nat.add(K, q), M), 1n) == True{} : Bool}:
  %Equal.sym(Nat, CT.rng(Nat.add(K, q), M), CT.rng(q, CT.rng(K, M)), rng_comp2(K, q, M)) : {Nat.is_lt(_, 1n) == True{} : Bool}
  %Equal.sym(Nat, CT.rng(K, M), 0n, lt1_zero(CT.rng(K, M), hlt)) : {Nat.is_lt(CT.rng(q, _), 1n) == True{} : Bool}
  %Equal.sym(Nat, CT.rng(q, 0n), 0n, rng_zero(q)) : {Nat.is_lt(_, 1n) == True{} : Bool}
  {==}

# M >> K = 0: the bit length within a wider width is the same.
law blen_lo:
  for +K: Nat
  for +j: Nat
  for +M: Nat
  for +hlt: {Nat.is_lt(CT.rng(K, M), 1n) == True{} : Bool}
  {blen(Nat.add(K, j), M) == blen(K, M) : Nat}
def blen_lo(K, j, M, hlt):
  match j:
    case 0n:
      %Equal.sym(Nat, Nat.add(K, 0n), K, F.nat__add_zero(K)) : {blen(_, M) == blen(K, M) : Nat}
      {==}
    case 1n+ +q:
      %Equal.sym(Nat, Nat.add(K, 1n+q), 1n+Nat.add(K, q), MR.add_succ(K, q)) : {blen(_, M) == blen(K, M) : Nat}
      %Equal.sym(Bool, Nat.is_lt(CT.rng(Nat.add(K, q), M), 1n), True{}, rng_small(K, q, M, hlt)) :
        {O.npick(_, blen(Nat.add(K, q), M), 1n+Nat.add(K, q)) == blen(K, M) : Nat}
      blen_lo(K, q, M, hlt)
