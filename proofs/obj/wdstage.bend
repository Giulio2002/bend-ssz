import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../proofs/nat_order.bend as Order
import ../compact/found_generated.bend as F
import ./mtree_run.bend as MR
import ./words_spec.bend as WS
import ./ctree.bend as CT
import ./cidx.bend as CX
import ./wdepth.bend as WD

# B.words_depth(w) (src/buffer.bend) is the smallest depth d with w <= 2^d:
# w <= 2^words_depth(w) (wd_cover) and words_depth(w) <= k whenever w <= 2^k
# (wd_min), for w <= 2^k with k <= 32 (every length the runtime stores is
# bounded so, relative to some array depth). The runtime computes the bit
# length of w - 1 by halving the width: bits16 splits 32 bits at 16, bits8 16
# at 8, ..., bits1 2 at 1, each stage adding the width of the high half when
# the value reaches 2^K. Each stage is WD.blen of its width (st1 .. st16). The
# thresholds 2, 4, 16, 256, 65536 are the runtime's O.pow2u(K) (compared as
# 32-bit words), and a stage condition is m >> K >= 1, so no statement
# mentions a closed number above 32.

# ---- thresholds and small sums ---------------------------------------------------------------

# 2^K <= m, as words and as m >> K >= 1.
def le_pow(+K: Nat, +m: U32, +hK: {Nat.is_lt(K, 32n) == True{} : Bool})
    -> {U32.is_le(O.pow2u(K), m) == Nat.is_le(1n, CT.rng(K, U32.to_nat(m))) : Bool}:
  %Equal.sym(Bool, U32.is_le(O.pow2u(K), m), Nat.is_le(U32.to_nat(O.pow2u(K)), U32.to_nat(m)), CX.le_nat(O.pow2u(K), m)) :
    {_ == Nat.is_le(1n, CT.rng(K, U32.to_nat(m))) : Bool}
  %Equal.sym(Nat, U32.to_nat(O.pow2u(K)), O.pow2n(K), CX.pow2u_val(K, hK)) :
    {Nat.is_le(_, U32.to_nat(m)) == Nat.is_le(1n, CT.rng(K, U32.to_nat(m))) : Bool}
  WD.pw_le(K, U32.to_nat(m))

def lit2() -> {O.pow2u(1n) == 2 : U32}: {==}
def lit4() -> {O.pow2u(2n) == 4 : U32}: {==}
def lit16() -> {O.pow2u(4n) == 16 : U32}: {==}
def lit256() -> {O.pow2u(8n) == 256 : U32}: {==}
def lit65536() -> {O.pow2u(16n) == 65536 : U32}: {==}

def le2(+m: U32) -> {U32.is_le(2, m) == Nat.is_le(1n, CT.rng(1n, U32.to_nat(m))) : Bool}:
  %lit2() : {U32.is_le(_, m) == Nat.is_le(1n, CT.rng(1n, U32.to_nat(m))) : Bool}
  le_pow(1n, m, {==})

def le4(+m: U32) -> {U32.is_le(4, m) == Nat.is_le(1n, CT.rng(2n, U32.to_nat(m))) : Bool}:
  %lit4() : {U32.is_le(_, m) == Nat.is_le(1n, CT.rng(2n, U32.to_nat(m))) : Bool}
  le_pow(2n, m, {==})

def le16(+m: U32) -> {U32.is_le(16, m) == Nat.is_le(1n, CT.rng(4n, U32.to_nat(m))) : Bool}:
  %lit16() : {U32.is_le(_, m) == Nat.is_le(1n, CT.rng(4n, U32.to_nat(m))) : Bool}
  le_pow(4n, m, {==})

def le256(+m: U32) -> {U32.is_le(256, m) == Nat.is_le(1n, CT.rng(8n, U32.to_nat(m))) : Bool}:
  %lit256() : {U32.is_le(_, m) == Nat.is_le(1n, CT.rng(8n, U32.to_nat(m))) : Bool}
  le_pow(8n, m, {==})

def le65536(+m: U32) -> {U32.is_le(65536, m) == Nat.is_le(1n, CT.rng(16n, U32.to_nat(m))) : Bool}:
  %lit65536() : {U32.is_le(_, m) == Nat.is_le(1n, CT.rng(16n, U32.to_nat(m))) : Bool}
  le_pow(16n, m, {==})

def acc_add(+acc: U32, +c: U32, +h: {Nat.is_le(Nat.add(U32.to_nat(acc), U32.to_nat(c)), 32n) == True{} : Bool})
    -> {U32.to_nat(U32.add(acc, c)) == Nat.add(U32.to_nat(acc), U32.to_nat(c)) : Nat}:
  CX.add_nat(acc, c, 6n, {==}, F.nat__le_trans(Nat.add(U32.to_nat(acc), U32.to_nat(c)), 32n, O.pow2n(6n), h, {==}))

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
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(acc), U32.to_nat(c)), d), Nat.add(U32.to_nat(acc), Nat.add(U32.to_nat(c), d)), WS.add_assoc(U32.to_nat(acc), U32.to_nat(c), d)) :
    {Nat.is_le(_, 32n) == True{} : Bool}
  h

# The high half: (A + K) + X = A + Y for Y = K + X.
def hi_eq(+A: Nat, +K: Nat, +X: Nat, +Y: Nat, +e: {Y == Nat.add(K, X) : Nat})
    -> {Nat.add(Nat.add(A, K), X) == Nat.add(A, Y) : Nat}:
  %Equal.sym(Nat, Y, Nat.add(K, X), e) : {Nat.add(Nat.add(A, K), X) == Nat.add(A, _) : Nat}
  WS.add_assoc(A, K, X)

def lt1_of(+x: Nat, +c: {Nat.is_le(1n, x) == False{} : Bool}) -> {Nat.is_lt(x, 1n) == True{} : Bool}:
  F.nat__not_le_lt(1n, x, c)

# ---- widths 1 and 2 ----------------------------------------------------------------------

def st0c(+acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 1n), 32n) == True{} : Bool}, +z: Bool)
    -> {B.bits0(z, acc) == Nat.add(U32.to_nat(acc), O.npick(z, 0n, 1n)) : Nat}:
  match z:
    case True{}: Equal.sym(Nat, Nat.add(U32.to_nat(acc), 0n), U32.to_nat(acc), F.nat__add_zero(U32.to_nat(acc)))
    case False{}: acc_add(acc, 1, ha)

def st1c(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 2n), 32n) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(1n, CT.rng(1n, U32.to_nat(m))) == c : Bool})
    -> {B.bits1(c, m, acc) == Nat.add(U32.to_nat(acc), WD.blen(2n, U32.to_nat(m))) : Nat}:
  match c:
    case True{}:
      %Equal.sym(Bool, Nat.is_lt(CT.rng(1n, U32.to_nat(m)), 1n), False{}, F.nat__le_not_lt(CT.rng(1n, U32.to_nat(m)), 1n, ec)) :
        {U32.to_nat((acc + 2 : U32)) == Nat.add(U32.to_nat(acc), O.npick(_, WD.blen(1n, U32.to_nat(m)), 2n)) : Nat}
      acc_add(acc, 2, ha)
    case False{}:
      %Equal.sym(Bool, Nat.is_lt(CT.rng(1n, U32.to_nat(m)), 1n), True{}, lt1_of(CT.rng(1n, U32.to_nat(m)), ec)) :
        {B.bits0(U32.is_eq(m, 0), acc) == Nat.add(U32.to_nat(acc), O.npick(_, WD.blen(1n, U32.to_nat(m)), 2n)) : Nat}
      %Equal.sym(Bool, Nat.is_lt(U32.to_nat(m), 1n), Nat.is_eq(U32.to_nat(m), 0n), lt1_eq(U32.to_nat(m))) :
        {B.bits0(U32.is_eq(m, 0), acc) == Nat.add(U32.to_nat(acc), O.npick(_, 0n, 1n)) : Nat}
      %Equal.sym(Bool, U32.is_eq(m, 0), Nat.is_eq(U32.to_nat(m), 0n), eq0(m)) :
        {B.bits0(_, acc) == Nat.add(U32.to_nat(acc), O.npick(Nat.is_eq(U32.to_nat(m), 0n), 0n, 1n)) : Nat}
      st0c(acc, ha_less(U32.to_nat(acc), 1n, 2n, ha, {==}), Nat.is_eq(U32.to_nat(m), 0n))

def st1(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 2n), 32n) == True{} : Bool})
    -> {B.bits1(U32.is_le(2, m), m, acc) == Nat.add(U32.to_nat(acc), WD.blen(2n, U32.to_nat(m))) : Nat}:
  %Equal.sym(Bool, U32.is_le(2, m), Nat.is_le(1n, CT.rng(1n, U32.to_nat(m))), le2(m)) :
    {B.bits1(_, m, acc) == Nat.add(U32.to_nat(acc), WD.blen(2n, U32.to_nat(m))) : Nat}
  st1c(m, acc, ha, Nat.is_le(1n, CT.rng(1n, U32.to_nat(m))), {==})

# ---- the halving stages ------------------------------------------------------------------

def st2c(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 4n), 32n) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(1n, CT.rng(2n, U32.to_nat(m))) == c : Bool})
    -> {B.bits2(c, m, acc) == Nat.add(U32.to_nat(acc), WD.blen(4n, U32.to_nat(m))) : Nat}:
  match c:
    case True{}:
      +Mm = U32.to_nat(m)
      +m2 = U32.shrn(m, 2n)
      +a2 = (acc + 2 : U32)
      +s = st1(m2, a2, ha_shift(acc, 2, 2n, ha))
      %Equal.sym(Nat, B.bits1(U32.is_le(2, m2), m2, a2), Nat.add(U32.to_nat(a2), WD.blen(2n, U32.to_nat(m2))), s) : {_ == Nat.add(U32.to_nat(acc), WD.blen(4n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(a2), Nat.add(U32.to_nat(acc), 2n), acc_add(acc, 2, ha_less(U32.to_nat(acc), 2n, 4n, ha, {==}))) :
        {Nat.add(_, WD.blen(2n, U32.to_nat(m2))) == Nat.add(U32.to_nat(acc), WD.blen(4n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(m2), CT.rng(2n, Mm), WD.shrk(2n, m)) :
        {Nat.add(Nat.add(U32.to_nat(acc), 2n), WD.blen(2n, _)) == Nat.add(U32.to_nat(acc), WD.blen(4n, Mm)) : Nat}
      hi_eq(U32.to_nat(acc), 2n, WD.blen(2n, CT.rng(2n, Mm)), WD.blen(4n, Mm), WD.blen_hi(2n, 2n, Mm, ec))
    case False{}:
      +Mm = U32.to_nat(m)
      %Equal.sym(Nat, WD.blen(4n, Mm), WD.blen(2n, Mm), WD.blen_lo(2n, 2n, Mm, lt1_of(CT.rng(2n, Mm), ec))) :
        {B.bits1(U32.is_le(2, m), m, acc) == Nat.add(U32.to_nat(acc), _) : Nat}
      st1(m, acc, ha_less(U32.to_nat(acc), 2n, 4n, ha, {==}))

def st2(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 4n), 32n) == True{} : Bool})
    -> {B.bits2(U32.is_le(4, m), m, acc) == Nat.add(U32.to_nat(acc), WD.blen(4n, U32.to_nat(m))) : Nat}:
  %Equal.sym(Bool, U32.is_le(4, m), Nat.is_le(1n, CT.rng(2n, U32.to_nat(m))), le4(m)) :
    {B.bits2(_, m, acc) == Nat.add(U32.to_nat(acc), WD.blen(4n, U32.to_nat(m))) : Nat}
  st2c(m, acc, ha, Nat.is_le(1n, CT.rng(2n, U32.to_nat(m))), {==})

def st4c(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 8n), 32n) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(1n, CT.rng(4n, U32.to_nat(m))) == c : Bool})
    -> {B.bits4(c, m, acc) == Nat.add(U32.to_nat(acc), WD.blen(8n, U32.to_nat(m))) : Nat}:
  match c:
    case True{}:
      +Mm = U32.to_nat(m)
      +m2 = U32.shrn(m, 4n)
      +a2 = (acc + 4 : U32)
      +s = st2(m2, a2, ha_shift(acc, 4, 4n, ha))
      %Equal.sym(Nat, B.bits2(U32.is_le(4, m2), m2, a2), Nat.add(U32.to_nat(a2), WD.blen(4n, U32.to_nat(m2))), s) : {_ == Nat.add(U32.to_nat(acc), WD.blen(8n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(a2), Nat.add(U32.to_nat(acc), 4n), acc_add(acc, 4, ha_less(U32.to_nat(acc), 4n, 8n, ha, {==}))) :
        {Nat.add(_, WD.blen(4n, U32.to_nat(m2))) == Nat.add(U32.to_nat(acc), WD.blen(8n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(m2), CT.rng(4n, Mm), WD.shrk(4n, m)) :
        {Nat.add(Nat.add(U32.to_nat(acc), 4n), WD.blen(4n, _)) == Nat.add(U32.to_nat(acc), WD.blen(8n, Mm)) : Nat}
      hi_eq(U32.to_nat(acc), 4n, WD.blen(4n, CT.rng(4n, Mm)), WD.blen(8n, Mm), WD.blen_hi(4n, 4n, Mm, ec))
    case False{}:
      +Mm = U32.to_nat(m)
      %Equal.sym(Nat, WD.blen(8n, Mm), WD.blen(4n, Mm), WD.blen_lo(4n, 4n, Mm, lt1_of(CT.rng(4n, Mm), ec))) :
        {B.bits2(U32.is_le(4, m), m, acc) == Nat.add(U32.to_nat(acc), _) : Nat}
      st2(m, acc, ha_less(U32.to_nat(acc), 4n, 8n, ha, {==}))

def st4(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 8n), 32n) == True{} : Bool})
    -> {B.bits4(U32.is_le(16, m), m, acc) == Nat.add(U32.to_nat(acc), WD.blen(8n, U32.to_nat(m))) : Nat}:
  %Equal.sym(Bool, U32.is_le(16, m), Nat.is_le(1n, CT.rng(4n, U32.to_nat(m))), le16(m)) :
    {B.bits4(_, m, acc) == Nat.add(U32.to_nat(acc), WD.blen(8n, U32.to_nat(m))) : Nat}
  st4c(m, acc, ha, Nat.is_le(1n, CT.rng(4n, U32.to_nat(m))), {==})

# Width 16 = 8 + 8 and 32 = 16 + 16, by small equations.
def e88() -> {Nat.add(8n, 8n) == 16n : Nat}: {==}
def e1616() -> {Nat.add(16n, 16n) == 32n : Nat}: {==}

def bh8(+X: Nat, +ge: {Nat.is_le(1n, CT.rng(8n, X)) == True{} : Bool}) -> {WD.blen(16n, X) == Nat.add(8n, WD.blen(8n, CT.rng(8n, X))) : Nat}:
  %e88() : {WD.blen(_, X) == Nat.add(8n, WD.blen(8n, CT.rng(8n, X))) : Nat}
  WD.blen_hi(8n, 8n, X, ge)

def bl8(+X: Nat, +h: {Nat.is_lt(CT.rng(8n, X), 1n) == True{} : Bool}) -> {WD.blen(16n, X) == WD.blen(8n, X) : Nat}:
  %e88() : {WD.blen(_, X) == WD.blen(8n, X) : Nat}
  WD.blen_lo(8n, 8n, X, h)

def bh16(+X: Nat, +ge: {Nat.is_le(1n, CT.rng(16n, X)) == True{} : Bool}) -> {WD.blen(32n, X) == Nat.add(16n, WD.blen(16n, CT.rng(16n, X))) : Nat}:
  %e1616() : {WD.blen(_, X) == Nat.add(16n, WD.blen(16n, CT.rng(16n, X))) : Nat}
  WD.blen_hi(16n, 16n, X, ge)

def bl16(+X: Nat, +h: {Nat.is_lt(CT.rng(16n, X), 1n) == True{} : Bool}) -> {WD.blen(32n, X) == WD.blen(16n, X) : Nat}:
  %e1616() : {WD.blen(_, X) == WD.blen(16n, X) : Nat}
  WD.blen_lo(16n, 16n, X, h)

def st8c(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 16n), 32n) == True{} : Bool},
    +c: Bool, +ec: {Nat.is_le(1n, CT.rng(8n, U32.to_nat(m))) == c : Bool})
    -> {B.bits8(c, m, acc) == Nat.add(U32.to_nat(acc), WD.blen(16n, U32.to_nat(m))) : Nat}:
  match c:
    case True{}:
      +Mm = U32.to_nat(m)
      +m2 = U32.shrn(m, 8n)
      +a2 = (acc + 8 : U32)
      +s = st4(m2, a2, ha_shift(acc, 8, 8n, ha))
      %Equal.sym(Nat, B.bits4(U32.is_le(16, m2), m2, a2), Nat.add(U32.to_nat(a2), WD.blen(8n, U32.to_nat(m2))), s) : {_ == Nat.add(U32.to_nat(acc), WD.blen(16n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(a2), Nat.add(U32.to_nat(acc), 8n), acc_add(acc, 8, ha_less(U32.to_nat(acc), 8n, 16n, ha, {==}))) :
        {Nat.add(_, WD.blen(8n, U32.to_nat(m2))) == Nat.add(U32.to_nat(acc), WD.blen(16n, Mm)) : Nat}
      %Equal.sym(Nat, U32.to_nat(m2), CT.rng(8n, Mm), WD.shrk(8n, m)) :
        {Nat.add(Nat.add(U32.to_nat(acc), 8n), WD.blen(8n, _)) == Nat.add(U32.to_nat(acc), WD.blen(16n, Mm)) : Nat}
      hi_eq(U32.to_nat(acc), 8n, WD.blen(8n, CT.rng(8n, Mm)), WD.blen(16n, Mm), bh8(Mm, ec))
    case False{}:
      +Mm = U32.to_nat(m)
      %Equal.sym(Nat, WD.blen(16n, Mm), WD.blen(8n, Mm), bl8(Mm, lt1_of(CT.rng(8n, Mm), ec))) :
        {B.bits4(U32.is_le(16, m), m, acc) == Nat.add(U32.to_nat(acc), _) : Nat}
      st4(m, acc, ha_less(U32.to_nat(acc), 8n, 16n, ha, {==}))

def st8(+m: U32, +acc: U32, +ha: {Nat.is_le(Nat.add(U32.to_nat(acc), 16n), 32n) == True{} : Bool})
    -> {B.bits8(U32.is_le(256, m), m, acc) == Nat.add(U32.to_nat(acc), WD.blen(16n, U32.to_nat(m))) : Nat}:
  %Equal.sym(Bool, U32.is_le(256, m), Nat.is_le(1n, CT.rng(8n, U32.to_nat(m))), le256(m)) :
    {B.bits8(_, m, acc) == Nat.add(U32.to_nat(acc), WD.blen(16n, U32.to_nat(m))) : Nat}
  st8c(m, acc, ha, Nat.is_le(1n, CT.rng(8n, U32.to_nat(m))), {==})

def st16c(+m: U32, +c: Bool, +ec: {Nat.is_le(1n, CT.rng(16n, U32.to_nat(m))) == c : Bool})
    -> {B.bits16(c, m) == WD.blen(32n, U32.to_nat(m)) : Nat}:
  match c:
    case True{}:
      +Mm = U32.to_nat(m)
      +m2 = U32.shrn(m, 16n)
      +s = st8(m2, 16, {==})
      %Equal.sym(Nat, B.bits8(U32.is_le(256, m2), m2, 16), Nat.add(U32.to_nat(16), WD.blen(16n, U32.to_nat(m2))), s) : {_ == WD.blen(32n, Mm) : Nat}
      %Equal.sym(Nat, U32.to_nat(m2), CT.rng(16n, Mm), WD.shrk(16n, m)) : {Nat.add(16n, WD.blen(16n, _)) == WD.blen(32n, Mm) : Nat}
      Equal.sym(Nat, WD.blen(32n, Mm), Nat.add(16n, WD.blen(16n, CT.rng(16n, Mm))), bh16(Mm, ec))
    case False{}:
      +Mm = U32.to_nat(m)
      %Equal.sym(Nat, WD.blen(32n, Mm), WD.blen(16n, Mm), bl16(Mm, lt1_of(CT.rng(16n, Mm), ec))) : {B.bits8(U32.is_le(256, m), m, 0) == _ : Nat}
      st8(m, 0, {==})

def st16(+m: U32) -> {B.bits16(U32.is_le(65536, m), m) == WD.blen(32n, U32.to_nat(m)) : Nat}:
  %Equal.sym(Bool, U32.is_le(65536, m), Nat.is_le(1n, CT.rng(16n, U32.to_nat(m))), le65536(m)) :
    {B.bits16(_, m) == WD.blen(32n, U32.to_nat(m)) : Nat}
  st16c(m, Nat.is_le(1n, CT.rng(16n, U32.to_nat(m))), {==})

# ---- words_depth ---------------------------------------------------------------------------

def one_le(+W: Nat, +ez: {Nat.is_eq(W, 0n) == False{} : Bool}) -> {Nat.is_le(1n, W) == True{} : Bool}:
  F.nat__lt_succ_le_succ(0n, W, F.nat__lt_or_eq(0n, W, Order.zero_le(W),
    Equal.trans(Bool, Nat.is_eq(0n, W), Nat.is_eq(W, 0n), False{}, F.flat__is_eq_sym(0n, W), ez)))

def sub1_lt(+W: Nat, +h: {Nat.is_le(1n, W) == True{} : Bool}) -> {Nat.is_lt(Nat.sub(W, 1n), W) == True{} : Bool}:
  match W:
    case 0n: Empty.absurd({Nat.is_lt(Nat.sub(0n, 1n), 0n) == True{} : Bool}, CT.lt_zero_absurd(0n, h))
    case 1n+ +p:
      %Equal.sym(Nat, Nat.sub(p, 0n), p, F.nat__sub_zero(p)) : {Nat.is_lt(_, 1n+p) == True{} : Bool}
      F.nat__le_lt_succ(p, p, F.nat__le_refl(p))

# For w > 0: words_depth(w) is the bit length of w - 1.
def wd_nz(+w: U32, +ez: {Nat.is_eq(U32.to_nat(w), 0n) == False{} : Bool})
    -> {B.words_depth_nz(False{}, w) == WD.blen(32n, Nat.sub(U32.to_nat(w), 1n)) : Nat}:
  %F.u32__sub_nat(w, 1, one_le(U32.to_nat(w), ez)) : {B.words_depth_nz(False{}, w) == WD.blen(32n, _) : Nat}
  st16((w - 1 : U32))

# Below width k <= 32, the 32-bit length is the width-k length.
def b32(+k: Nat, +M: Nat, +hk: {Nat.is_le(k, 32n) == True{} : Bool}, +hM: {Nat.is_lt(M, O.pow2n(k)) == True{} : Bool})
    -> {WD.blen(32n, M) == WD.blen(k, M) : Nat}:
  %F.nat__sub_add(32n, k, hk) : {WD.blen(_, M) == WD.blen(k, M) : Nat}
  WD.blen_lo(k, Nat.sub(32n, k), M, WD.small_rng(k, M, hM))

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
      %Equal.sym(Nat, B.words_depth_nz(False{}, w), WD.blen(32n, M), wd_nz(w, ez)) : {Nat.is_le(W, O.pow2n(_)) == True{} : Bool}
      %Equal.sym(Nat, WD.blen(32n, M), WD.blen(k, M), b32(k, M, hk, hM)) : {Nat.is_le(W, O.pow2n(_)) == True{} : Bool}
      %F.nat__sub_add(W, 1n, h1) : {Nat.is_le(_, O.pow2n(WD.blen(k, M))) == True{} : Bool}
      F.nat__lt_succ_le_succ(M, O.pow2n(WD.blen(k, M)), WD.blen_cover(k, M, WD.small_rng(k, M, hM)))

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
      %Equal.sym(Nat, B.words_depth_nz(False{}, w), WD.blen(32n, Nat.sub(W, 1n)), wd_nz(w, ez)) : {Nat.is_le(_, k) == True{} : Bool}
      WD.blen_min(32n, Nat.sub(W, 1n), k, lt)

# words_depth(w) <= k whenever w <= 2^k.
def wd_min(+w: U32, +k: Nat, +h: {Nat.is_le(U32.to_nat(w), O.pow2n(k)) == True{} : Bool}) -> {Nat.is_le(B.words_depth(w), k) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_eq(w, 0), Nat.is_eq(U32.to_nat(w), 0n), eq0(w)) : {Nat.is_le(B.words_depth_nz(_, w), k) == True{} : Bool}
  wdm(w, k, h, Nat.is_eq(U32.to_nat(w), 0n), {==})
