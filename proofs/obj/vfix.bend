import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vcopy.bend as VC
import ./spec_fixed.bend as FX
import ../../src/primitives.bend as I

# Word-aligned reads and writes at a symbolic byte offset `off` whose value is
# 4 i: the index facts, the aligned four-byte read, and runs of word writes
# (updv) with their list model (lmv).

def BF(t: F.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{F.array__thaw(U32, t), n}

# ---- off = 4 i: low bits zero, off >> 2 = i ------------------------------------------------

def al_pair(+off: U32, +i: Nat, +e: {U32.to_nat(off) == A.quad(i) : Nat})
    -> {U32.to_nat(U32.shrn(off, 2n)) == i : Nat} & {U32.to_nat(U32.and(off, 3)) == 0n : Nat}:
  +q = U32.to_nat(U32.shrn(off, 2n))
  +r = U32.to_nat(U32.and(off, 3))
  +e1 = Equal.trans(Nat, Nat.add(Nat.mul(q, 4n), r), Nat.add(A.quad(q), r), Nat.add(Nat.mul(i, 4n), 0n),
    Equal.cong(Nat, Nat, z => Nat.add(z, r), Nat.mul(q, 4n), A.quad(q), VC.quad_mul(q)),
    Equal.trans(Nat, Nat.add(A.quad(q), r), U32.to_nat(off), Nat.add(Nat.mul(i, 4n), 0n), Equal.sym(Nat, U32.to_nat(off), Nat.add(A.quad(q), r), VC.split4(off)),
      Equal.trans(Nat, U32.to_nat(off), A.quad(i), Nat.add(Nat.mul(i, 4n), 0n), e,
        Equal.trans(Nat, A.quad(i), Nat.mul(i, 4n), Nat.add(Nat.mul(i, 4n), 0n), Equal.sym(Nat, Nat.mul(i, 4n), A.quad(i), VC.quad_mul(i)),
          Equal.sym(Nat, Nat.add(Nat.mul(i, 4n), 0n), Nat.mul(i, 4n), F.nat__add_zero(Nat.mul(i, 4n)))))))
  +hr = F.nat__le_lt_trans(r, 3n, 4n, RD.and_le(off, 3), {==})
  VU.dm_unique(q, r, i, 0n, 4n, e1, hr, {==})

def al_q(+off: U32, +i: Nat, +e: {U32.to_nat(off) == A.quad(i) : Nat}) -> {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}:
  Pair.fst({U32.to_nat(U32.shrn(off, 2n)) == i : Nat}, {U32.to_nat(U32.and(off, 3)) == 0n : Nat}, al_pair(off, i, e))

def al_3(+off: U32, +i: Nat, +e: {U32.to_nat(off) == A.quad(i) : Nat}) -> {U32.and(off, 3) == 0 : U32}:
  F.u32__injective(U32.and(off, 3), 0, Pair.snd({U32.to_nat(U32.shrn(off, 2n)) == i : Nat}, {U32.to_nat(U32.and(off, 3)) == 0n : Nat}, al_pair(off, i, e)))

# The aligned four-byte read at off = 4 i is word i.
def rd32a(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +e: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.read32(BF(t, n), off) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}:
  %Equal.sym(U32, U32.and(off, 3), 0, al_3(off, i, e)) :
    {B.read32_choose(off, _, U32.is_eq(_, 0), BF(t, n)) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), U32.shrn(off, 2n)), (F.array__thaw(U32, t), VB.slot(t, i)), VB.get_n(d, t, U32.shrn(off, 2n), i, al_q(off, i, e), hd, hi, pf)) :
    {B.rewrap(n, _) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}
  {==}

# off + 4k = 4 (k + i), below a bound 2^d (d < 31).
def quad_add(+k: Nat, +i: Nat) -> {Nat.add(A.quad(k), A.quad(i)) == A.quad(Nat.add(k, i)) : Nat}:
  %Equal.sym(Nat, Nat.add(Nat.double(Nat.double(k)), Nat.double(Nat.double(i))), Nat.double(Nat.add(Nat.double(k), Nat.double(i))), F.nat__add_double(Nat.double(k), Nat.double(i))) :
    {_ == A.quad(Nat.add(k, i)) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.double(k), Nat.double(i)), Nat.double(Nat.add(k, i)), F.nat__add_double(k, i)) : {Nat.double(_) == A.quad(Nat.add(k, i)) : Nat}
  {==}

def off_add(+off: U32, +c: U32, +i: Nat, +k: Nat, +d: Nat, +e: {U32.to_nat(off) == A.quad(i) : Nat}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hb: {Nat.is_le(A.quad(Nat.add(k, i)), VB.pw(d)) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, c)) == A.quad(Nat.add(k, i)) : Nat}:
  +h0 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(d)) == True{} : Bool}, A.quad(Nat.add(k, i)), Nat.add(A.quad(k), A.quad(i)), Equal.sym(Nat, Nat.add(A.quad(k), A.quad(i)), A.quad(Nat.add(k, i)), quad_add(k, i)), hb)
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, A.quad(i)), VB.pw(d)) == True{} : Bool}, A.quad(k), U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), A.quad(k), ec), h0)
  %Equal.sym(Nat, U32.to_nat(U32.add(off, c)), Nat.add(U32.to_nat(c), A.quad(i)), VB.add_le_at(off, c, A.quad(i), d, e, hd, h1)) : {_ == A.quad(Nat.add(k, i)) : Nat}
  %Equal.sym(Nat, U32.to_nat(c), A.quad(k), ec) : {Nat.add(_, A.quad(i)) == A.quad(Nat.add(k, i)) : Nat}
  quad_add(k, i)

# ---- runs of word writes -------------------------------------------------------------------

def updv(V: List<&2, U32>, +dd: Nat, D: F.array__Tree<U32>, +j: Nat) -> F.array__Tree<U32>:
  match V:
    case Nil{}: D
    case Con{+v, t}: updv(t, dd, F.array__upd(U32, dd, D, j, v), 1n+j)

def lmv(V: List<&2, U32>, +j: Nat, L: List<&2, U32>) -> List<&2, U32>:
  match V:
    case Nil{}: L
    case Con{+v, t}: lmv(t, 1n+j, F.spec_common__update(U32, L, j, v))

law updv_perfect:
  for +V: List<&2, U32>
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +j: Nat
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  {F.array__perfect(U32, dd, updv(V, dd, D, j)) == True{} : Bool}
def updv_perfect(V, dd, D, j, pf):
  match V:
    case Nil{}: pf
    case Con{+v, +t}: updv_perfect(t, dd, F.array__upd(U32, dd, D, j, v), 1n+j, F.array__upd_perfect(U32, dd, D, j, v, pf))

law slots_updv:
  for +V: List<&2, U32>
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +j: Nat
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hb: {Nat.is_le(Nat.add(F.spec_common__length(U32, V), j), VB.pw(dd)) == True{} : Bool}
  {F.array__slots(U32, updv(V, dd, D, j)) == lmv(V, j, F.array__slots(U32, D)) : List<&2, U32>}
def slots_updv(V, dd, D, j, pf, hb):
  match V:
    case Nil{}: {==}
    case Con{+v, +t}:
      %Equal.sym(List<&2, U32>, F.array__slots(U32, updv(t, dd, F.array__upd(U32, dd, D, j, v), 1n+j)), lmv(t, 1n+j, F.array__slots(U32, F.array__upd(U32, dd, D, j, v))),
          slots_updv(t, dd, F.array__upd(U32, dd, D, j, v), 1n+j, F.array__upd_perfect(U32, dd, D, j, v, pf), VB.le1_shift(F.spec_common__length(U32, t), j, VB.pw(dd), hb))) :
        {_ == lmv(t, 1n+j, F.spec_common__update(U32, F.array__slots(U32, D), j, v)) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, F.array__slots(U32, F.array__upd(U32, dd, D, j, v)), F.spec_common__update(U32, F.array__slots(U32, D), j, v),
          F.array__upd_slots(U32, dd, D, j, v, VB.le1_head(F.spec_common__length(U32, t), j, VB.pw(dd), hb), pf)) :
        {lmv(t, 1n+j, _) == lmv(t, 1n+j, F.spec_common__update(U32, F.array__slots(U32, D), j, v)) : List<&2, U32>}
      {==}

# ---- windows of a word list ---------------------------------------------------------------

def WIN(+m: Nat, +p: Nat, X: List<&2, U32>) -> List<&2, U32>: VS.wtake(m, VB.wdr(p, X))

law upd_len:
  for +L: List<&2, U32>
  for +j: Nat
  for +v: U32
  {VB.len(F.spec_common__update(U32, L, j, v)) == VB.len(L) : Nat}
def upd_len(L, j, v): F.list__length_update(U32, L, j, v)

# A write outside a window leaves the window.
def win_upd_lo(+m: Nat, +p: Nat, +L: List<&2, U32>, +j: Nat, +v: U32, +h: {Nat.is_lt(j, p) == True{} : Bool})
    -> {WIN(m, p, F.spec_common__update(U32, L, j, v)) == WIN(m, p, L) : List<&2, U32>}:
  Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(m, z), VB.wdr(p, F.spec_common__update(U32, L, j, v)), VB.wdr(p, L), VB.wdr_upd(p, L, j, v, h))

law take_upd:
  for +m: Nat
  for +L: List<&2, U32>
  for +j: Nat
  for +v: U32
  for +h: {Nat.is_le(m, j) == True{} : Bool}
  {VS.wtake(m, F.spec_common__update(U32, L, j, v)) == VS.wtake(m, L) : List<&2, U32>}
def take_upd(m, L, j, v, h):
  match m L j:
    case 0n +L1 +j1: {==}
    case 1n+ +q Nil{} +j1: {==}
    case 1n+ +q Con{+x, +t} 0n: Empty.absurd({VS.wtake(1n+q, F.spec_common__update(U32, Con{x, t}, 0n, v)) == VS.wtake(1n+q, Con{x, t}) : List<&2, U32>}, F.logic__false_true(h))
    case 1n+ +q Con{+x, +t} 1n+ +k:
      %Equal.sym(List<&2, U32>, VS.wtake(q, F.spec_common__update(U32, t, k, v)), VS.wtake(q, t), take_upd(q, t, k, v, h)) :
        {Con{x, _} == Con{x, VS.wtake(q, t)} : List<&2, U32>}
      {==}

law win_upd_hi:
  for +m: Nat
  for +p: Nat
  for +L: List<&2, U32>
  for +j: Nat
  for +v: U32
  for +h: {Nat.is_le(Nat.add(m, p), j) == True{} : Bool}
  {WIN(m, p, F.spec_common__update(U32, L, j, v)) == WIN(m, p, L) : List<&2, U32>}
def win_upd_hi(m, p, L, j, v, h):
  match p L j:
    case 0n +L1 +j1:
      take_upd(m, L1, j1, v, F.logic__subst(Nat, z => {Nat.is_le(z, j1) == True{} : Bool}, Nat.add(m, 0n), m, F.nat__add_zero(m), h))
    case 1n+ +r Nil{} +j1: {==}
    case 1n+ +r Con{+x, +t} 0n:
      Empty.absurd({WIN(m, 1n+r, F.spec_common__update(U32, Con{x, t}, 0n, v)) == WIN(m, 1n+r, Con{x, t}) : List<&2, U32>},
        F.logic__false_true(F.logic__subst(Nat, z => {Nat.is_le(z, 0n) == True{} : Bool}, Nat.add(m, 1n+r), 1n+Nat.add(m, r), F.nat__add_succ(m, r), h)))
    case 1n+ +r Con{+x, +t} 1n+ +k:
      win_upd_hi(m, r, t, k, v, F.logic__subst(Nat, z => {Nat.is_le(z, 1n+k) == True{} : Bool}, Nat.add(m, 1n+r), 1n+Nat.add(m, r), F.nat__add_succ(m, r), h))

def slen(V: List<&2, U32>) -> Nat: F.spec_common__length(U32, V)

law lmv_len:
  for +V: List<&2, U32>
  for +j: Nat
  for +L: List<&2, U32>
  {VB.len(lmv(V, j, L)) == VB.len(L) : Nat}
def lmv_len(V, j, L):
  match V:
    case Nil{}: {==}
    case Con{+v, +t}:
      %Equal.sym(Nat, VB.len(lmv(t, 1n+j, F.spec_common__update(U32, L, j, v))), VB.len(F.spec_common__update(U32, L, j, v)), lmv_len(t, 1n+j, F.spec_common__update(U32, L, j, v))) :
        {_ == VB.len(L) : Nat}
      upd_len(L, j, v)

law lmv_pre:
  for +V: List<&2, U32>
  for +j: Nat
  for +L: List<&2, U32>
  for +k: Nat
  for +hk: {Nat.is_lt(k, j) == True{} : Bool}
  {F.flat__nthc(lmv(V, j, L), k) == F.flat__nthc(L, k) : U32}
def lmv_pre(V, j, L, k, hk):
  match V:
    case Nil{}: {==}
    case Con{+v, +t}:
      %Equal.sym(U32, F.flat__nthc(lmv(t, 1n+j, F.spec_common__update(U32, L, j, v)), k), F.flat__nthc(F.spec_common__update(U32, L, j, v), k),
          lmv_pre(t, 1n+j, F.spec_common__update(U32, L, j, v), k, F.nat__lt_trans(k, j, 1n+j, hk, F.nat__lt_succ(j)))) : {_ == F.flat__nthc(L, k) : U32}
      F.flat__nthc_other(L, j, k, v, F.flat__ne_gt(j, k, hk))

# A run of writes is read back from its own window.
law lmv_own:
  for +V: List<&2, U32>
  for +j: Nat
  for +L: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(slen(V), j), VB.len(L)) == True{} : Bool}
  {WIN(slen(V), j, lmv(V, j, L)) == V : List<&2, U32>}
def lmv_own(V, j, L, h):
  match V:
    case Nil{}: {==}
    case Con{+v, +t}:
      +L1 = F.spec_common__update(U32, L, j, v)
      +A = lmv(t, 1n+j, L1)
      +hjL = VB.le1_head(slen(t), j, VB.len(L), h)
      +hjA = F.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, VB.len(L), VB.len(A),
        Equal.sym(Nat, VB.len(A), VB.len(L), Equal.trans(Nat, VB.len(A), VB.len(L1), VB.len(L), lmv_len(t, 1n+j, L1), upd_len(L, j, v))), hjL)
      %Equal.sym(List<&2, U32>, VB.wdr(j, A), Con{F.flat__nthc(A, j), VB.wdr(1n+j, A)}, VB.wdr_eta(j, A, hjA)) :
        {VS.wtake(1n+slen(t), _) == Con{v, t} : List<&2, U32>}
      %Equal.sym(U32, F.flat__nthc(A, j), F.flat__nthc(L1, j), lmv_pre(t, 1n+j, L1, j, F.nat__lt_succ(j))) :
        {Con{_, VS.wtake(slen(t), VB.wdr(1n+j, A))} == Con{v, t} : List<&2, U32>}
      %Equal.sym(U32, F.flat__nthc(L1, j), v, F.flat__nthc_same(L, j, v, hjL)) :
        {Con{_, VS.wtake(slen(t), VB.wdr(1n+j, A))} == Con{v, t} : List<&2, U32>}
      %Equal.sym(List<&2, U32>, WIN(slen(t), 1n+j, A), t,
          lmv_own(t, 1n+j, L1, F.logic__subst(Nat, z => {Nat.is_le(Nat.add(slen(t), 1n+j), z) == True{} : Bool}, VB.len(L), VB.len(L1), Equal.sym(Nat, VB.len(L1), VB.len(L), upd_len(L, j, v)), VB.le1_shift(slen(t), j, VB.len(L), h)))) :
        {Con{v, _} == Con{v, t} : List<&2, U32>}
      {==}

# Writes before or after a window leave it.
law lmv_lo:
  for +V: List<&2, U32>
  for +j: Nat
  for +m: Nat
  for +p: Nat
  for +L: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(slen(V), j), p) == True{} : Bool}
  {WIN(m, p, lmv(V, j, L)) == WIN(m, p, L) : List<&2, U32>}
def lmv_lo(V, j, m, p, L, h):
  match V:
    case Nil{}: {==}
    case Con{+v, +t}:
      %Equal.sym(List<&2, U32>, WIN(m, p, lmv(t, 1n+j, F.spec_common__update(U32, L, j, v))), WIN(m, p, F.spec_common__update(U32, L, j, v)),
          lmv_lo(t, 1n+j, m, p, F.spec_common__update(U32, L, j, v), VB.le1_shift(slen(t), j, p, h))) : {_ == WIN(m, p, L) : List<&2, U32>}
      win_upd_lo(m, p, L, j, v, VB.le1_head(slen(t), j, p, h))

law lmv_hi:
  for +V: List<&2, U32>
  for +j: Nat
  for +m: Nat
  for +p: Nat
  for +L: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(m, p), j) == True{} : Bool}
  {WIN(m, p, lmv(V, j, L)) == WIN(m, p, L) : List<&2, U32>}
def lmv_hi(V, j, m, p, L, h):
  match V:
    case Nil{}: {==}
    case Con{+v, +t}:
      %Equal.sym(List<&2, U32>, WIN(m, p, lmv(t, 1n+j, F.spec_common__update(U32, L, j, v))), WIN(m, p, F.spec_common__update(U32, L, j, v)),
          lmv_hi(t, 1n+j, m, p, F.spec_common__update(U32, L, j, v), F.nat__le_trans(Nat.add(m, p), j, 1n+j, h, F.nat__le_succ(j)))) : {_ == WIN(m, p, L) : List<&2, U32>}
      win_upd_hi(m, p, L, j, v, h)

# The copy loop's list model leaves windows outside its target.
law lm_lo:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +m: Nat
  for +p: Nat
  for +L: List<&2, U32>
  for +SL: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(n, j), p) == True{} : Bool}
  {WIN(m, p, VB.lm(n, i, j, L, SL)) == WIN(m, p, L) : List<&2, U32>}
def lm_lo(n, i, j, m, p, L, SL, h):
  match n:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(List<&2, U32>, WIN(m, p, VB.lm(q, 1n+i, 1n+j, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i)), SL)), WIN(m, p, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i))),
          lm_lo(q, 1n+i, 1n+j, m, p, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i)), SL, VB.le1_shift(q, j, p, h))) : {_ == WIN(m, p, L) : List<&2, U32>}
      win_upd_lo(m, p, L, j, F.flat__nthc(SL, i), VB.le1_head(q, j, p, h))

law lm_hi:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +m: Nat
  for +p: Nat
  for +L: List<&2, U32>
  for +SL: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(m, p), j) == True{} : Bool}
  {WIN(m, p, VB.lm(n, i, j, L, SL)) == WIN(m, p, L) : List<&2, U32>}
def lm_hi(n, i, j, m, p, L, SL, h):
  match n:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(List<&2, U32>, WIN(m, p, VB.lm(q, 1n+i, 1n+j, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i)), SL)), WIN(m, p, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i))),
          lm_hi(q, 1n+i, 1n+j, m, p, F.spec_common__update(U32, L, j, F.flat__nthc(SL, i)), SL, F.nat__le_trans(Nat.add(m, p), j, 1n+j, h, F.nat__le_succ(j)))) : {_ == WIN(m, p, L) : List<&2, U32>}
      win_upd_hi(m, p, L, j, F.flat__nthc(SL, i), h)

# ---- splitting windows ---------------------------------------------------------------------

def app(+a: List<&2, U32>, +b: List<&2, U32>) -> List<&2, U32>: F.spec_common__append(U32, a, b)

law take_split:
  for +a: Nat
  for +b: Nat
  for +Y: List<&2, U32>
  {VS.wtake(Nat.add(a, b), Y) == app(VS.wtake(a, Y), VS.wtake(b, VB.wdr(a, Y))) : List<&2, U32>}
def take_split(a, b, Y):
  match a b Y:
    case 0n +b1 +Y1: {==}
    case 1n+ +q 0n Nil{}: {==}
    case 1n+ +q 1n+ +r Nil{}: {==}
    case 1n+ +q +b1 Con{+x, +t}:
      %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(q, b1), t), app(VS.wtake(q, t), VS.wtake(b1, VB.wdr(q, t))), take_split(q, b1, t)) :
        {Con{x, _} == Con{x, app(VS.wtake(q, t), VS.wtake(b1, VB.wdr(q, t)))} : List<&2, U32>}
      {==}

law wdr_add:
  for +a: Nat
  for +p: Nat
  for +X: List<&2, U32>
  {VB.wdr(a, VB.wdr(p, X)) == VB.wdr(Nat.add(p, a), X) : List<&2, U32>}
def wdr_add(a, p, X):
  match a p X:
    case +a1 0n +X1: {==}
    case 0n 1n+ +q Nil{}: {==}
    case 1n+ +r 1n+ +q Nil{}: {==}
    case +a1 1n+ +q Con{+x, +t}: wdr_add(a1, q, t)

# A window of a + b words is the window of a words followed by that of b.
def win_split(+a: Nat, +b: Nat, +p: Nat, +X: List<&2, U32>)
    -> {WIN(Nat.add(a, b), p, X) == app(WIN(a, p, X), WIN(b, Nat.add(p, a), X)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, VB.wdr(Nat.add(p, a), X), VB.wdr(a, VB.wdr(p, X)), Equal.sym(List<&2, U32>, VB.wdr(a, VB.wdr(p, X)), VB.wdr(Nat.add(p, a), X), wdr_add(a, p, X))) :
    {WIN(Nat.add(a, b), p, X) == app(WIN(a, p, X), VS.wtake(b, _)) : List<&2, U32>}
  take_split(a, b, VB.wdr(p, X))

law limbs_app:
  for +a: List<&2, U32>
  for +b: List<&2, U32>
  {FX.limbs(app(a, b)) == List.append(&2, U32, FX.limbs(a), FX.limbs(b)) : +List<U32>}
def limbs_app(a, b):
  match a:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(+List<U32>, FX.limbs(app(t, b)), List.append(&2, U32, FX.limbs(t), FX.limbs(b)), limbs_app(t, b)) :
        {List.append(&2, U32, I.limb(h), _) == List.append(&2, U32, List.append(&2, U32, I.limb(h), FX.limbs(t)), FX.limbs(b)) : +List<U32>}
      Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, I.limb(h), FX.limbs(t)), FX.limbs(b)), List.append(&2, U32, I.limb(h), List.append(&2, U32, FX.limbs(t), FX.limbs(b))),
        VS.app_assoc(I.limb(h), FX.limbs(t), FX.limbs(b)))
