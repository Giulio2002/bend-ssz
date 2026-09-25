import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ./ctree.bend as CT
import ./cidx.bend as CX
import ./cloop2.bend as L2
import ./wdstage.bend as WS2
import ./capi.bend as CA
import ./wdepth.bend as WD

# The append that grows the capacity of the cached validators list
# (l1099511627776_Validator_capp when n = 2^d). The runtime moves the items into
# room (`room`: kept when the items array already has space, otherwise copied
# into a fresh array of depth words_depth(n + 1)), stores the element at n and
# starts a fresh node tree of depth 1 + d with every leaf dirty. The new cache
# is valid (grow_inv): its node invariant holds vacuously (every leaf dirty),
# and its items are a perfect tree of depth at least 1 + d. `copy_t` is the
# tree the copy loop builds; copy_eq relates the loop to it.

# ---- the copy loop -------------------------------------------------------------------------

def dft() -> T.Validator: T.Validator_default()

def copy_t(k: Nat, +I: Nat, +df: Nat, +dO: Nat, +tf: F.array__Tree<T.Validator>, +to: F.array__Tree<T.Validator>) -> F.array__Tree<T.Validator>:
  match k:
    case 0n: tf
    case 1n+q:
      copy_t(q, 1n+I, df, dO, F.array__upd(T.Validator, df, tf, I, L2.xat(F.array__slots(T.Validator, to), I)),
        F.array__upd(T.Validator, dO, to, I, dft()))

def copy_perfect(k: Nat, +I: Nat, +df: Nat, +dO: Nat, +tf: F.array__Tree<T.Validator>, +to: F.array__Tree<T.Validator>,
    +pff: {F.array__perfect(T.Validator, df, tf) == True{} : Bool}, +pfo: {F.array__perfect(T.Validator, dO, to) == True{} : Bool})
    -> {F.array__perfect(T.Validator, df, copy_t(k, I, df, dO, tf, to)) == True{} : Bool}:
  match k:
    case 0n: pff
    case 1n+q:
      copy_perfect(q, 1n+I, df, dO, F.array__upd(T.Validator, df, tf, I, L2.xat(F.array__slots(T.Validator, to), I)),
        F.array__upd(T.Validator, dO, to, I, dft()),
        F.array__upd_perfect(T.Validator, df, tf, I, L2.xat(F.array__slots(T.Validator, to), I), pff),
        F.array__upd_perfect(T.Validator, dO, to, I, dft(), pfo))

def lt_len(+t: F.array__Tree<T.Validator>, +d: Nat, +I: Nat,
    +pf: {F.array__perfect(T.Validator, d, t) == True{} : Bool},
    +h: {Nat.is_lt(I, F.spec_common__pow2(d)) == True{} : Bool})
    -> {Nat.is_lt(I, F.spec_common__length(T.Validator, F.array__slots(T.Validator, t))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(T.Validator, F.array__slots(T.Validator, t)), F.spec_common__pow2(d), F.array__slots_length(T.Validator, d, t, pf)) :
    {Nat.is_lt(I, _) == True{} : Bool}
  h

def item_nth(+t: F.array__Tree<T.Validator>, +d: Nat, +i: U32,
    +pf: {F.array__perfect(T.Validator, d, t) == True{} : Bool},
    +h: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool})
    -> {F.spec_common__nth(T.Validator, F.array__slots(T.Validator, t), U32.to_nat(i)) == Some{L2.xat(F.array__slots(T.Validator, t), U32.to_nat(i))} : Maybe<&2, T.Validator>}:
  L2.xnth(F.array__slots(T.Validator, t), U32.to_nat(i), lt_len(t, d, U32.to_nat(i), pf, h))

def step_lt(+I: Nat, +q: Nat, +B: Nat, +h: {Nat.is_le(Nat.add(I, 1n+q), B) == True{} : Bool}) -> {Nat.is_lt(I, B) == True{} : Bool}:
  CT.step_lt(I, q, B, h)

def succ_bound(+i: U32, +q: Nat, +d: Nat, +h: {Nat.is_le(Nat.add(U32.to_nat(i), 1n+q), F.spec_common__pow2(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(i), U32.to_nat(1)), O.pow2n(d)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(U32.to_nat(i), 1n), 1n+U32.to_nat(i), CX.NA_add1(U32.to_nat(i))) : {Nat.is_le(_, O.pow2n(d)) == True{} : Bool}
  %CT.pow2_eq(d) : {Nat.is_le(1n+U32.to_nat(i), _) == True{} : Bool}
  F.nat__lt_succ_le_succ(U32.to_nat(i), F.spec_common__pow2(d), step_lt(U32.to_nat(i), q, F.spec_common__pow2(d), h))

def i_next(+i: U32, +q: Nat, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(i), 1n+q), F.spec_common__pow2(d)) == True{} : Bool})
    -> {U32.to_nat((i + 1 : U32)) == 1n+U32.to_nat(i) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), Nat.add(U32.to_nat(i), U32.to_nat(1)), CX.add_nat(i, 1, d, hd, succ_bound(i, q, d, h))) : {_ == 1n+U32.to_nat(i) : Nat}
  CX.NA_add1(U32.to_nat(i))

def bump(+i: U32, +q: Nat, +B: Nat, +e: {U32.to_nat((i + 1 : U32)) == 1n+U32.to_nat(i) : Nat},
    +h: {Nat.is_le(Nat.add(U32.to_nat(i), 1n+q), B) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat((i + 1 : U32)), q), B) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat((i + 1 : U32)), 1n+U32.to_nat(i), e) : {Nat.is_le(Nat.add(_, q), B) == True{} : Bool}
  CT.step_le(U32.to_nat(i), q, B, h)

# The copy loop over k items from i: the tree copy_t builds.
law copy_eq:
  for +k: Nat
  for +i: U32
  for +df: Nat
  for +dO: Nat
  for +tf: F.array__Tree<T.Validator>
  for +to: F.array__Tree<T.Validator>
  for +hdf: {Nat.is_lt(df, 32n) == True{} : Bool}
  for +hdO: {Nat.is_lt(dO, 32n) == True{} : Bool}
  for +pff: {F.array__perfect(T.Validator, df, tf) == True{} : Bool}
  for +pfo: {F.array__perfect(T.Validator, dO, to) == True{} : Bool}
  for +hkf: {Nat.is_le(Nat.add(U32.to_nat(i), k), F.spec_common__pow2(df)) == True{} : Bool}
  for +hko: {Nat.is_le(Nat.add(U32.to_nat(i), k), F.spec_common__pow2(dO)) == True{} : Bool}
  {T.l1099511627776_Validator_copy(k, i, (F.array__thaw(T.Validator, tf), F.array__thaw(T.Validator, to)))
   == F.array__thaw(T.Validator, copy_t(k, U32.to_nat(i), df, dO, tf, to)) : Array<T.Validator>}
def copy_eq(k, i, df, dO, tf, to, hdf, hdO, pff, pfo, hkf, hko):
  match k:
    case 0n: {==}
    case 1n+ +q:
      +I = U32.to_nat(i)
      +x = L2.xat(F.array__slots(T.Validator, to), I)
      +y = L2.xat(F.array__slots(T.Validator, tf), I)
      +hio = step_lt(I, q, F.spec_common__pow2(dO), hko)
      +hif = step_lt(I, q, F.spec_common__pow2(df), hkf)
      +to2 = F.array__upd(T.Validator, dO, to, I, dft())
      +tf2 = F.array__upd(T.Validator, df, tf, I, x)
      +ei = i_next(i, q, df, hdf, hkf)
      %Equal.sym(Array<T.Validator> & T.Validator, Array.swap(T.Validator, F.array__thaw(T.Validator, to), i, dft()), (F.array__thaw(T.Validator, to2), x),
          F.array__swap(T.Validator, dO, to, i, dft(), x, hdO, hio, item_nth(to, dO, i, pfo, hio), pfo)) :
        {T.l1099511627776_Validator_copy(q, (i + 1 : U32), T.l1099511627776_Validator_moved(i, F.array__thaw(T.Validator, tf), _))
         == F.array__thaw(T.Validator, copy_t(q, 1n+I, df, dO, tf2, to2)) : Array<T.Validator>}
      %Equal.sym(Array<T.Validator>, Array.set(T.Validator, F.array__thaw(T.Validator, tf), i, x), F.array__thaw(T.Validator, tf2),
          F.array__set(T.Validator, df, tf, i, x, y, hdf, hif, item_nth(tf, df, i, pff, hif), pff)) :
        {T.l1099511627776_Validator_copy(q, (i + 1 : U32), (_, F.array__thaw(T.Validator, to2)))
         == F.array__thaw(T.Validator, copy_t(q, 1n+I, df, dO, tf2, to2)) : Array<T.Validator>}
      %ei : {T.l1099511627776_Validator_copy(q, (i + 1 : U32), (F.array__thaw(T.Validator, tf2), F.array__thaw(T.Validator, to2)))
         == F.array__thaw(T.Validator, copy_t(q, _, df, dO, tf2, to2)) : Array<T.Validator>}
      copy_eq(q, (i + 1 : U32), df, dO, tf2, to2, hdf, hdO,
        F.array__upd_perfect(T.Validator, df, tf, I, x, pff), F.array__upd_perfect(T.Validator, dO, to, I, dft(), pfo),
        bump(i, q, F.spec_common__pow2(df), ei, hkf), bump(i, q, F.spec_common__pow2(dO), ei, hko))

# ---- room -------------------------------------------------------------------------------------

# The items after `room`: kept when n < 2^dw, else the copy into depth words_depth(n + 1).
def rdepth(c: Bool, +dw: Nat, +n: U32) -> Nat:
  match c:
    case True{}: dw
    case False{}: B.words_depth((n + 1 : U32))

def rtree(c: Bool, +dw: Nat, +n: U32, +ta: F.array__Tree<T.Validator>) -> F.array__Tree<T.Validator>:
  match c:
    case True{}: ta
    case False{}: copy_t(U32.to_nat(n), 0n, B.words_depth((n + 1 : U32)), dw, F.array__trep(T.Validator, B.words_depth((n + 1 : U32)), dft()), ta)

def fits(+dw: Nat, +n: U32) -> Bool: Nat.is_lt(U32.to_nat(n), F.spec_common__pow2(dw))

def size_cmp(+dw: Nat, +n: U32, +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool}) -> {U32.is_lt(n, F.u32__pow2u(dw)) == fits(dw, n) : Bool}:
  %Equal.sym(Bool, U32.is_lt(n, F.u32__pow2u(dw)), Nat.is_lt(U32.to_nat(n), U32.to_nat(F.u32__pow2u(dw))), CX.lt_nat(n, F.u32__pow2u(dw))) : {_ == fits(dw, n) : Bool}
  %Equal.sym(Nat, U32.to_nat(F.u32__pow2u(dw)), F.spec_common__pow2(dw), F.u32__pow2u_value(dw, hdw)) : {Nat.is_lt(U32.to_nat(n), _) == fits(dw, n) : Bool}
  {==}

def WS2_cover(+n: U32, +k: Nat, +hk: {Nat.is_le(k, 30n) == True{} : Bool}, +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat((n + 1 : U32)), F.spec_common__pow2(B.words_depth((n + 1 : U32)))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__pow2(B.words_depth((n + 1 : U32))), O.pow2n(B.words_depth((n + 1 : U32))), CT.pow2_eq(B.words_depth((n + 1 : U32)))) : {Nat.is_le(U32.to_nat((n + 1 : U32)), _) == True{} : Bool}
  WS2.wd_cover((n + 1 : U32), k, F.nat__le_trans(k, 30n, 32n, hk, {==}), hn1)

def le_next(+n: U32, +en1: {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat})
    -> {Nat.is_le(U32.to_nat(n), U32.to_nat((n + 1 : U32))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat((n + 1 : U32)), 1n+U32.to_nat(n), en1) : {Nat.is_le(U32.to_nat(n), _) == True{} : Bool}
  F.nat__le_succ(U32.to_nat(n))

# n <= n + 1 <= 2^D2: the items the copy moves fit the fresh array.
def n_in(+n: U32, +D2: Nat, +en1: {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat},
    +h: {Nat.is_le(U32.to_nat((n + 1 : U32)), F.spec_common__pow2(D2)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(0), U32.to_nat(n)), F.spec_common__pow2(D2)) == True{} : Bool}:
  F.nat__le_trans(U32.to_nat(n), U32.to_nat((n + 1 : U32)), F.spec_common__pow2(D2), le_next(n, en1), h)

# Hypotheses of the copy branch: the fresh array of depth words_depth(n + 1) <= k <= 30 holds n items.
def room_pick_eq(+c: Bool, +dw: Nat, +n: U32, +k: Nat, +ta: F.array__Tree<T.Validator>,
    +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool},
    +pfa: {F.array__perfect(T.Validator, dw, ta) == True{} : Bool},
    +hnw: {Nat.is_le(U32.to_nat(n), F.spec_common__pow2(dw)) == True{} : Bool},
    +hk: {Nat.is_le(k, 30n) == True{} : Bool},
    +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool},
    +en1: {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat},
    +ec: {fits(dw, n) == c : Bool})
    -> {T.l1099511627776_Validator_room_pick(c, F.array__thaw(T.Validator, ta), n) == F.array__thaw(T.Validator, rtree(c, dw, n, ta)) : Array<T.Validator>}:
  match c:
    case True{}: {==}
    case False{}:
      +D2 = B.words_depth((n + 1 : U32))
      +hD2 = F.nat__le_lt_trans(D2, 30n, 32n, F.nat__le_trans(D2, k, 30n, WS2.wd_min((n + 1 : U32), k, hn1), hk), {==})
      +hcov = WS2_cover(n, k, hk, hn1)
      %Equal.sym(Array<T.Validator>, T.l1099511627776_Validator_fill(D2), F.array__thaw(T.Validator, F.array__trep(T.Validator, D2, dft())), F.array__new(T.Validator, D2, dft())) :
        {T.l1099511627776_Validator_copy(U32.to_nat(n), 0, (_, F.array__thaw(T.Validator, ta))) == F.array__thaw(T.Validator, rtree(False{}, dw, n, ta)) : Array<T.Validator>}
      copy_eq(U32.to_nat(n), 0, D2, dw, F.array__trep(T.Validator, D2, dft()), ta, hD2, hdw,
        F.array__trep_perfect(T.Validator, D2, dft()), pfa, n_in(n, D2, en1, hcov), hnw)

# n + 1 without wrapping, for n < 2^k with k < 32.
def n_next2(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 32n) == True{} : Bool}, +h: {Nat.is_lt(U32.to_nat(n), O.pow2n(k)) == True{} : Bool})
    -> {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(n, 1)), Nat.add(U32.to_nat(n), U32.to_nat(1)), CX.add_nat(n, 1, k, hk, CA.app_bnext(n, k, h))) : {_ == 1n+U32.to_nat(n) : Nat}
  CX.NA_add1(U32.to_nat(n))

# ---- the growing append ---------------------------------------------------------------------

# n = 2^d when the append does not fit (n <= 2^d always).
def n_full(+n: U32, +d: Nat, +hnd: {Nat.is_le(U32.to_nat(n), O.pow2n(d)) == True{} : Bool},
    +hg: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == False{} : Bool}) -> {U32.to_nat(n) == O.pow2n(d) : Nat}:
  F.nat__le_antisym(U32.to_nat(n), O.pow2n(d), hnd, F.nat__not_lt_le(U32.to_nat(n), O.pow2n(d), hg))

def nofit(+n: U32, +d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hg: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == False{} : Bool})
    -> {U32.is_lt(n, O.pow2u(d)) == False{} : Bool}:
  %Equal.sym(Bool, U32.is_lt(n, O.pow2u(d)), Nat.is_lt(U32.to_nat(n), U32.to_nat(O.pow2u(d))), CX.lt_nat(n, O.pow2u(d))) : {_ == False{} : Bool}
  %Equal.sym(Nat, U32.to_nat(O.pow2u(d)), O.pow2n(d), CX.pow2u_val(d, CA.WS2hd32(d, hd))) : {Nat.is_lt(U32.to_nat(n), _) == False{} : Bool}
  hg

def lt_dbl(+x: Nat, +h: {Nat.is_le(1n, x) == True{} : Bool}) -> {Nat.is_lt(x, Nat.double(x)) == True{} : Bool}:
  F.nat__lt_le_trans(x, 1n+x, Nat.double(x), F.nat__le_lt_succ(x, x, F.nat__le_refl(x)), F.nat__double_succ_le(x, h))

# n < 2^(1 + d), so n + 1 does not wrap.
def n_lt2(+n: U32, +d: Nat, +en: {U32.to_nat(n) == O.pow2n(d) : Nat}) -> {Nat.is_lt(U32.to_nat(n), O.pow2n(1n+d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(n), O.pow2n(d), en) : {Nat.is_lt(_, O.pow2n(1n+d)) == True{} : Bool}
  lt_dbl(O.pow2n(d), CT.pow2_pos(d))

def rt_depth(c: Bool, +dw: Nat, +n: U32, +k: Nat, +hk: {Nat.is_le(k, 30n) == True{} : Bool},
    +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 32n) == True{} : Bool})
    -> {Nat.is_lt(rdepth(c, dw, n), 32n) == True{} : Bool}:
  match c:
    case True{}: hdw
    case False{}: F.nat__le_lt_trans(B.words_depth((n + 1 : U32)), 30n, 32n, F.nat__le_trans(B.words_depth((n + 1 : U32)), k, 30n, WS2.wd_min((n + 1 : U32), k, hn1), hk), {==})

def rt_perfect(c: Bool, +dw: Nat, +n: U32, +ta: F.array__Tree<T.Validator>, +pfa: {F.array__perfect(T.Validator, dw, ta) == True{} : Bool})
    -> {F.array__perfect(T.Validator, rdepth(c, dw, n), rtree(c, dw, n, ta)) == True{} : Bool}:
  match c:
    case True{}: pfa
    case False{}:
      copy_perfect(U32.to_nat(n), 0n, B.words_depth((n + 1 : U32)), dw, F.array__trep(T.Validator, B.words_depth((n + 1 : U32)), dft()), ta,
        F.array__trep_perfect(T.Validator, B.words_depth((n + 1 : U32)), dft()), pfa)

def lt_to(+N: Nat, +m: Nat, +e: {m == 1n+N : Nat}) -> {Nat.is_lt(N, m) == True{} : Bool}:
  %Equal.sym(Nat, m, 1n+N, e) : {Nat.is_lt(N, _) == True{} : Bool}
  F.nat__le_lt_succ(N, N, F.nat__le_refl(N))

def succ_lt(+N: Nat, +m: Nat, +B: Nat, +e: {m == 1n+N : Nat}, +h: {Nat.is_le(m, B) == True{} : Bool}) -> {Nat.is_lt(N, B) == True{} : Bool}:
  F.nat__lt_le_trans(N, m, B, lt_to(N, m, e), h)

# Position n lies inside the moved items.
def rt_room(c: Bool, +dw: Nat, +n: U32, +k: Nat, +hk: {Nat.is_le(k, 30n) == True{} : Bool},
    +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool},
    +en1: {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat},
    +ec: {fits(dw, n) == c : Bool})
    -> {Nat.is_lt(U32.to_nat(n), F.spec_common__pow2(rdepth(c, dw, n))) == True{} : Bool}:
  match c:
    case True{}: ec
    case False{}: succ_lt(U32.to_nat(n), U32.to_nat((n + 1 : U32)), F.spec_common__pow2(B.words_depth((n + 1 : U32))), en1, WS2_cover(n, k, hk, hn1))

def to_pow2n(+N: Nat, +D2: Nat, +h: {Nat.is_lt(N, F.spec_common__pow2(D2)) == True{} : Bool}) -> {Nat.is_lt(N, O.pow2n(D2)) == True{} : Bool}:
  %CT.pow2_eq(D2) : {Nat.is_lt(N, _) == True{} : Bool}
  h

def full_not_lt(+n: U32, +d: Nat, +en: {U32.to_nat(n) == O.pow2n(d) : Nat}) -> {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == False{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(n), O.pow2n(d), en) : {Nat.is_lt(_, O.pow2n(d)) == False{} : Bool}
  F.nat__lt_irrefl(O.pow2n(d))

# 1 + d <= the moved items' depth: they hold the doubled capacity.
def rt_cap(+c: Bool, +dw: Nat, +n: U32, +d: Nat, +k: Nat, +hk: {Nat.is_le(k, 30n) == True{} : Bool},
    +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool},
    +en1: {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat},
    +en: {U32.to_nat(n) == O.pow2n(d) : Nat},
    +ec: {fits(dw, n) == c : Bool})
    -> {Nat.is_le(O.pow2n(1n+d), F.spec_common__pow2(rdepth(c, dw, n))) == True{} : Bool}:
  +D2 = rdepth(c, dw, n)
  +hD = WD.pow2_between(d, D2, U32.to_nat(n), full_not_lt(n, d, en), to_pow2n(U32.to_nat(n), D2, rt_room(c, dw, n, k, hk, hn1, en1, ec)), Nat.is_le(D2, d), {==})
  CT.rw_le(O.pow2n(D2), F.spec_common__pow2(D2), O.pow2n(1n+d), Equal.sym(Nat, F.spec_common__pow2(D2), O.pow2n(D2), CT.pow2_eq(D2)), CT.pow2_mono(1n+d, D2, hD))

# 1 + d <= k: the grown depth is within the size bound's width.
def d_grow(+n: U32, +d: Nat, +k: Nat, +hk: {Nat.is_le(k, 30n) == True{} : Bool},
    +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool},
    +en1: {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat},
    +en: {U32.to_nat(n) == O.pow2n(d) : Nat})
    -> {Nat.is_le(1n+d, k) == True{} : Bool}:
  WD.pow2_between(d, k, U32.to_nat(n), full_not_lt(n, d, en), succ_lt(U32.to_nat(n), U32.to_nat((n + 1 : U32)), O.pow2n(k), en1, hn1), Nat.is_le(k, d), {==})

def hnd_grow(+n: U32, +d: Nat, +en1: {U32.to_nat((n + 1 : U32)) == 1n+U32.to_nat(n) : Nat}, +en: {U32.to_nat(n) == O.pow2n(d) : Nat})
    -> {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(1n+d)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat((n + 1 : U32)), 1n+U32.to_nat(n), en1) : {Nat.is_le(_, O.pow2n(1n+d)) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(n), O.pow2n(d), en) : {Nat.is_le(1n+_, O.pow2n(1n+d)) == True{} : Bool}
  F.nat__double_succ_le(O.pow2n(d), CT.pow2_pos(d))

def gitems(+dw: Nat, +n: U32, +ta: F.array__Tree<T.Validator>, +v: T.Validator) -> F.array__Tree<T.Validator>:
  F.array__upd(T.Validator, rdepth(fits(dw, n), dw, n), rtree(fits(dw, n), dw, n, ta), U32.to_nat(n), v)

# The append that does not fit: items moved and v stored at n, n + 1 elements,
# a fresh node tree of depth 1 + d with every leaf dirty.
law grow_eq:
  for +ta: F.array__Tree<T.Validator>
  for +dw: Nat
  for +t: F.array__Tree<D.Digest>
  for +n: U32
  for +d: Nat
  for +lo: U32
  for +hi: U32
  for +v: T.Validator
  for +k: Nat
  for +hk: {Nat.is_le(k, 30n) == True{} : Bool}
  for +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool}
  for +hgd: {CA.guard(n) == True{} : Bool}
  for +hg: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == False{} : Bool}
  for +iv: CA.inv(ta, dw, t, n, d, lo, hi)
  {T.l1099511627776_Validator_capp(CA.cached(ta, t, n, d, lo, hi), v)
   == (CA.cached(gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32)), True{})
   : T.l1099511627776_Validator_Cached & Bool}
def grow_eq(ta, dw, t, n, d, lo, hi, v, k, hk, hn1, hgd, hg, iv):
  (+hdw, w1) = iv
  (+pfa, w2) = w1
  (+hcap, w3) = w2
  (+hd, w4) = w3
  (+hdD, w5) = w4
  (+hnd, w6) = w5
  +N = U32.to_nat(n)
  +en = n_full(n, d, hnd, hg)
  +en1 = n_next2(n, 1n+d, hd, n_lt2(n, d, en))
  +c = fits(dw, n)
  +D2 = rdepth(c, dw, n)
  +R = rtree(c, dw, n, ta)
  +hr = rt_room(c, dw, n, k, hk, hn1, en1, {==})
  +pr = rt_perfect(c, dw, n, ta, pfa)
  %Equal.sym(Bool, CA.guard(n), True{}, hgd) :
    {T.l1099511627776_Validator_capp_in(_, F.array__thaw(T.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, v)
     == (CA.cached(gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32)), True{})
     : T.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Bool, U32.is_lt(n, O.pow2u(d)), False{}, nofit(n, d, hd, hg)) :
    {(T.l1099511627776_Validator_capp_fit(_, F.array__thaw(T.Validator, ta), n, d, F.array__thaw(D.Digest, t), lo, hi, v), True{}) == (CA.cached(gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32)), True{})
     : T.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Array<D.Digest>, T.l1099511627776_Validator_dfill(2n+d), F.array__thaw(D.Digest, CA.dnew(1n+d)), CA.fresh_nodes(1n+d)) :
    {(T.l1099511627776_Validator_Cached{Array.set(T.Validator, T.l1099511627776_Validator_room(F.array__thaw(T.Validator, ta), n), n, v), (n + 1 : U32), 1n+d, _, 0, (O.pow2u(1n+d) - 1 : U32)}, True{}) == (CA.cached(gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32)), True{})
     : T.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Array<T.Validator> & U32, Array.size(T.Validator, F.array__thaw(T.Validator, ta)), (F.array__thaw(T.Validator, ta), F.u32__pow2u(dw)),
      F.array__size_thaw(T.Validator, dw, ta, pfa)) :
    {(T.l1099511627776_Validator_Cached{Array.set(T.Validator, T.l1099511627776_Validator_room_sized(n, _), n, v), (n + 1 : U32), 1n+d, F.array__thaw(D.Digest, CA.dnew(1n+d)), 0, (O.pow2u(1n+d) - 1 : U32)}, True{}) == (CA.cached(gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32)), True{})
     : T.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Bool, U32.is_lt(n, F.u32__pow2u(dw)), c, size_cmp(dw, n, hdw)) :
    {(T.l1099511627776_Validator_Cached{Array.set(T.Validator, T.l1099511627776_Validator_room_pick(_, F.array__thaw(T.Validator, ta), n), n, v), (n + 1 : U32), 1n+d, F.array__thaw(D.Digest, CA.dnew(1n+d)), 0, (O.pow2u(1n+d) - 1 : U32)}, True{}) == (CA.cached(gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32)), True{})
     : T.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Array<T.Validator>, T.l1099511627776_Validator_room_pick(c, F.array__thaw(T.Validator, ta), n), F.array__thaw(T.Validator, R),
      room_pick_eq(c, dw, n, k, ta, hdw, pfa, F.nat__le_trans(N, O.pow2n(d), F.spec_common__pow2(dw), hnd, hcap), hk, hn1, en1, {==})) :
    {(T.l1099511627776_Validator_Cached{Array.set(T.Validator, _, n, v), (n + 1 : U32), 1n+d, F.array__thaw(D.Digest, CA.dnew(1n+d)), 0, (O.pow2u(1n+d) - 1 : U32)}, True{}) == (CA.cached(gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32)), True{})
     : T.l1099511627776_Validator_Cached & Bool}
  %Equal.sym(Array<T.Validator>, Array.set(T.Validator, F.array__thaw(T.Validator, R), n, v), F.array__thaw(T.Validator, F.array__upd(T.Validator, D2, R, N, v)),
      F.array__set(T.Validator, D2, R, n, v, L2.xat(F.array__slots(T.Validator, R), N), rt_depth(c, dw, n, k, hk, hn1, hdw), hr, item_nth(R, D2, n, pr, hr), pr)) :
    {(T.l1099511627776_Validator_Cached{_, (n + 1 : U32), 1n+d, F.array__thaw(D.Digest, CA.dnew(1n+d)), 0, (O.pow2u(1n+d) - 1 : U32)}, True{}) == (CA.cached(gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32)), True{})
     : T.l1099511627776_Validator_Cached & Bool}
  {==}

# The grown cache is valid, for n + 1 <= 2^k with k <= 30 and k <= the limit depth 40.
law grow_inv:
  for +ta: F.array__Tree<T.Validator>
  for +dw: Nat
  for +t: F.array__Tree<D.Digest>
  for +n: U32
  for +d: Nat
  for +lo: U32
  for +hi: U32
  for +v: T.Validator
  for +k: Nat
  for +hk: {Nat.is_le(k, 30n) == True{} : Bool}
  for +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool}
  for +hkD: {Nat.is_le(k, 40n) == True{} : Bool}
  for +hg: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == False{} : Bool}
  for +iv: CA.inv(ta, dw, t, n, d, lo, hi)
  CA.inv(gitems(dw, n, ta, v), rdepth(fits(dw, n), dw, n), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32))
def grow_inv(ta, dw, t, n, d, lo, hi, v, k, hk, hn1, hkD, hg, iv):
  (+hdw, w1) = iv
  (+pfa, w2) = w1
  (+hcap, w3) = w2
  (+hd, w4) = w3
  (+hdD, w5) = w4
  (+hnd, w6) = w5
  +N = U32.to_nat(n)
  +en = n_full(n, d, hnd, hg)
  +en1 = n_next2(n, 1n+d, hd, n_lt2(n, d, en))
  +c = fits(dw, n)
  +dk = d_grow(n, d, k, hk, hn1, en1, en)
  +hd2 = F.nat__le_lt_trans(1n+d, 30n, 31n, F.nat__le_trans(1n+d, k, 30n, dk, hk), {==})
  (rt_depth(c, dw, n, k, hk, hn1, hdw),
  (F.array__upd_perfect(T.Validator, rdepth(c, dw, n), rtree(c, dw, n, ta), N, v, rt_perfect(c, dw, n, ta, pfa)),
  (rt_cap(c, dw, n, d, k, hk, hn1, en1, en, {==}),
  (hd2,
  (F.nat__le_trans(1n+d, k, 40n, dk, hkD),
  (hnd_grow(n, d, en1, en),
  (F.array__trep_perfect(D.Digest, 2n+d, D.zero()),
  (CA.hi_lt(1n+d, hd2),
  (CA.fresh_len(1n+d),
   CA.fresh_ci(1n+d, hd2, (n + 1 : U32), gitems(dw, n, ta, v)))))))))))
