import Base
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ./words_rw.bend as WR
import ./words_win.bend as WW
import ./words_list.bend as WL

# The block copies of packed storage, for a list whose elements are whole packed values (O.Words):
# O.words_blit writes the words of a value into the storage at word B (the loop O.bl_go), and
# O.words_slice reads them back out into a fresh array (the loop O.sl_go). Over storage thaw(t), t a
# perfect tree of U32 words of depth d < 32, the blit is the tree bcp(..) and the slice the tree
# scp(..) (Nat indices), and word m of what the slice reads is word m of the value blitted.
# codegen/coll_laws.py composes these into the read-back law of such a list.

# ---- the tree each loop builds ----
# bcp: words S .. S + k of the source tree s go to words B + S .. B + S + k of T
def bcp(+d: Nat, +s: F.array__Tree<U32>, +k: Nat, +S: Nat, +B: Nat, +T: F.array__Tree<U32>) -> F.array__Tree<U32>:
  match k:
    case 0n: F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S))
    case 1n+q: bcp(d, s, q, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)))

# scp: words B + S .. B + S + k of the storage tree t go to words S .. S + k of OUT
def scp(+d: Nat, +t: F.array__Tree<U32>, +k: Nat, +S: Nat, +B: Nat, +OUT: F.array__Tree<U32>) -> F.array__Tree<U32>:
  match k:
    case 0n: F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))
    case 1n+q: scp(d, t, q, 1n+S, B, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S))))

def bcp_perfect(+d: Nat, +s: F.array__Tree<U32>, +k: Nat, +S: Nat, +B: Nat, +T: F.array__Tree<U32>, +pf: {F.array__perfect(U32, d, T) == True{} : Bool})
    -> {F.array__perfect(U32, d, bcp(d, s, k, S, B, T)) == True{} : Bool}:
  match k:
    case 0n: F.array__upd_perfect(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S), pf)
    case 1n+q: bcp_perfect(d, s, q, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)), F.array__upd_perfect(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S), pf))

# ---- index arithmetic ----
# B + (1 + S) is 1 + (B + S)
def bsucc(+B: Nat, +S: Nat) -> {1n+Nat.add(B, S) == Nat.add(B, 1n+S) : Nat}:
  Equal.sym(Nat, Nat.add(B, 1n+S), 1n+Nat.add(B, S), F.nat__add_succ(B, S))

# the destination bound after one step: (B + (1 + S)) + (1 + q) <= P from (B + S) + (2 + q) <= P
def bnext(+B: Nat, +S: Nat, +q: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(B, S), 2n+q), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(B, 1n+S), 1n+q), P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n+q), P) == True{} : Bool}, 1n+Nat.add(B, S), Nat.add(B, 1n+S), bsucc(B, S), WR.shift_b(Nat.add(B, S), q, P, h))

# the first index written is below P
def bfirst(+X: Nat, +k: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(X, 1n+k), P) == True{} : Bool}) -> {Nat.is_lt(X, P) == True{} : Bool}:
  WR.j_lt(X, P, WR.bound(X, 0n, 1n+k, P, h, {==}))

# the run-time index (base + j) + 1 is B + (1 + S)
def ix_next(+base: U32, +j: U32, +B: Nat, +S: Nat, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +eb: {U32.to_nat(base) == B : Nat}, +ej: {U32.to_nat(j) == S : Nat},
    +h0: {Nat.is_lt(Nat.add(B, S), F.spec_common__pow2(d)) == True{} : Bool}, +h1: {Nat.is_lt(Nat.add(Nat.add(B, S), 1n), F.spec_common__pow2(d)) == True{} : Bool})
    -> {U32.to_nat((base + j + 1 : U32)) == Nat.add(B, 1n+S) : Nat}:
  Equal.trans(Nat, U32.to_nat((base + j + 1 : U32)), Nat.add(Nat.add(B, S), 1n), Nat.add(B, 1n+S),
    WR.idx((base + j : U32), Nat.add(B, S), 1, 1n, d, hd, WR.idx(base, B, j, S, d, hd, eb, ej, h0), {==}, h1),
    Equal.trans(Nat, Nat.add(Nat.add(B, S), 1n), 1n+Nat.add(B, S), Nat.add(B, 1n+S), WR.add1(Nat.add(B, S)), bsucc(B, S)))

# ---- the blit loop ----
def blc0(+j: U32, +S: Nat, +base: U32, +B: Nat, +s: F.array__Tree<U32>, +d: Nat, +t: F.array__Tree<U32>, +n: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == S : Nat}, +eb: {U32.to_nat(base) == B : Nat},
    +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 1n), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {O.bl_go(0n, j, base, O.Words{F.array__thaw(U32, t), n}, (F.array__thaw(U32, s), WR.at(F.array__slots(U32, s), S))) == (O.Words{F.array__thaw(U32, bcp(d, s, 0n, S, B, t)), n}, F.array__thaw(U32, s)) : O.Words & Array<U32>}:
  +h0 = bfirst(Nat.add(B, S), 0n, F.spec_common__pow2(d), bt)
  %Equal.sym(O.Words, O.words_setw(O.Words{F.array__thaw(U32, t), n}, (base + j : U32), WR.at(F.array__slots(U32, s), S)), O.Words{F.array__thaw(U32, F.array__upd(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S))), n},
      WR.setw_thaw(d, t, n, (base + j : U32), Nat.add(B, S), WR.at(F.array__slots(U32, s), S), hd, WR.idx(base, B, j, S, d, hd, eb, ej, h0), h0, pf)) :
    {(_, F.array__thaw(U32, s)) == (O.Words{F.array__thaw(U32, bcp(d, s, 0n, S, B, t)), n}, F.array__thaw(U32, s)) : O.Words & Array<U32>}
  {==}

def blc_step(+q: Nat, +j: U32, +S: Nat, +base: U32, +B: Nat, +ds: Nat, +s: F.array__Tree<U32>, +d: Nat, +t: F.array__Tree<U32>, +n: U32,
    +hds: {Nat.is_lt(ds, 32n) == True{} : Bool}, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == S : Nat}, +eb: {U32.to_nat(base) == B : Nat},
    +bs: {Nat.is_le(Nat.add(S, 2n+q), F.spec_common__pow2(ds)) == True{} : Bool}, +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 2n+q), F.spec_common__pow2(d)) == True{} : Bool},
    +pfs: {F.array__perfect(U32, ds, s) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +ih: {O.bl_go(q, (j + 1 : U32), base, O.Words{F.array__thaw(U32, F.array__upd(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S))), n}, (F.array__thaw(U32, s), WR.at(F.array__slots(U32, s), 1n+S))) == (O.Words{F.array__thaw(U32, bcp(d, s, q, 1n+S, B, F.array__upd(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)))), n}, F.array__thaw(U32, s)) : O.Words & Array<U32>})
    -> {O.bl_go(1n+q, j, base, O.Words{F.array__thaw(U32, t), n}, (F.array__thaw(U32, s), WR.at(F.array__slots(U32, s), S))) == (O.Words{F.array__thaw(U32, bcp(d, s, 1n+q, S, B, t)), n}, F.array__thaw(U32, s)) : O.Words & Array<U32>}:
  +h0 = bfirst(Nat.add(B, S), 1n+q, F.spec_common__pow2(d), bt)
  +h1 = WR.bound(S, 1n, 2n+q, F.spec_common__pow2(ds), bs, {==})
  %Equal.sym(O.Words, O.words_setw(O.Words{F.array__thaw(U32, t), n}, (base + j : U32), WR.at(F.array__slots(U32, s), S)), O.Words{F.array__thaw(U32, F.array__upd(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S))), n},
      WR.setw_thaw(d, t, n, (base + j : U32), Nat.add(B, S), WR.at(F.array__slots(U32, s), S), hd, WR.idx(base, B, j, S, d, hd, eb, ej, h0), h0, pf)) :
    {O.bl_go(q, (j + 1 : U32), base, _, Array.get(U32, F.array__thaw(U32, s), (j + 1 : U32))) == (O.Words{F.array__thaw(U32, bcp(d, s, q, 1n+S, B, F.array__upd(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)))), n}, F.array__thaw(U32, s)) : O.Words & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, s), (j + 1 : U32)), (F.array__thaw(U32, s), WR.at(F.array__slots(U32, s), 1n+S)),
      WR.get_thaw(ds, s, (j + 1 : U32), 1n+S, hds, WR.next_ix(j, S, ds, hds, ej, h1), WR.j1_lt(S, F.spec_common__pow2(ds), h1), pfs)) :
    {O.bl_go(q, (j + 1 : U32), base, O.Words{F.array__thaw(U32, F.array__upd(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S))), n}, _) == (O.Words{F.array__thaw(U32, bcp(d, s, q, 1n+S, B, F.array__upd(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)))), n}, F.array__thaw(U32, s)) : O.Words & Array<U32>}
  ih

# O.bl_go writes words S .. S + k of the source (tree s, depth ds) at words B + S .. of the storage
def blc(+k: Nat, +j: U32, +S: Nat, +base: U32, +B: Nat, +ds: Nat, +s: F.array__Tree<U32>, +d: Nat, +t: F.array__Tree<U32>, +n: U32,
    +hds: {Nat.is_lt(ds, 32n) == True{} : Bool}, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == S : Nat}, +eb: {U32.to_nat(base) == B : Nat},
    +bs: {Nat.is_le(Nat.add(S, 1n+k), F.spec_common__pow2(ds)) == True{} : Bool}, +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 1n+k), F.spec_common__pow2(d)) == True{} : Bool},
    +pfs: {F.array__perfect(U32, ds, s) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {O.bl_go(k, j, base, O.Words{F.array__thaw(U32, t), n}, (F.array__thaw(U32, s), WR.at(F.array__slots(U32, s), S))) == (O.Words{F.array__thaw(U32, bcp(d, s, k, S, B, t)), n}, F.array__thaw(U32, s)) : O.Words & Array<U32>}:
  match k:
    case 0n: blc0(j, S, base, B, s, d, t, n, hd, ej, eb, bt, pf)
    case 1n+q:
      blc_step(q, j, S, base, B, ds, s, d, t, n, hds, hd, ej, eb, bs, bt, pfs, pf,
        blc(q, (j + 1 : U32), 1n+S, base, B, ds, s, d, F.array__upd(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)), n, hds, hd,
          WR.next_ix(j, S, ds, hds, ej, WR.bound(S, 1n, 2n+q, F.spec_common__pow2(ds), bs, {==})), eb,
          WR.shift_b(S, q, F.spec_common__pow2(ds), bs), bnext(B, S, q, F.spec_common__pow2(d), bt), pfs,
          F.array__upd_perfect(U32, d, t, Nat.add(B, S), WR.at(F.array__slots(U32, s), S), pf)))

# ---- the slice loop ----
def slc0(+j: U32, +S: Nat, +base: U32, +B: Nat, +t: F.array__Tree<U32>, +n: U32, +d2: Nat, +OUT: F.array__Tree<U32>,
    +hd2: {Nat.is_lt(d2, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == S : Nat},
    +bo: {Nat.is_le(Nat.add(S, 1n), F.spec_common__pow2(d2)) == True{} : Bool}, +pfo: {F.array__perfect(U32, d2, OUT) == True{} : Bool})
    -> {O.sl_go(0n, j, base, F.array__thaw(U32, OUT), (O.Words{F.array__thaw(U32, t), n}, WR.at(F.array__slots(U32, t), Nat.add(B, S)))) == (O.Words{F.array__thaw(U32, t), n}, F.array__thaw(U32, scp(d2, t, 0n, S, B, OUT))) : O.Words & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, OUT), j, WR.at(F.array__slots(U32, t), Nat.add(B, S))), F.array__thaw(U32, F.array__upd(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))),
      WR.set_thaw(d2, OUT, j, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)), hd2, ej, bfirst(S, 0n, F.spec_common__pow2(d2), bo), pfo)) :
    {(O.Words{F.array__thaw(U32, t), n}, _) == (O.Words{F.array__thaw(U32, t), n}, F.array__thaw(U32, scp(d2, t, 0n, S, B, OUT))) : O.Words & Array<U32>}
  {==}

def slc_step(+q: Nat, +j: U32, +S: Nat, +base: U32, +B: Nat, +d: Nat, +t: F.array__Tree<U32>, +n: U32, +d2: Nat, +OUT: F.array__Tree<U32>,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hd2: {Nat.is_lt(d2, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == S : Nat}, +eb: {U32.to_nat(base) == B : Nat},
    +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 2n+q), F.spec_common__pow2(d)) == True{} : Bool}, +bo: {Nat.is_le(Nat.add(S, 2n+q), F.spec_common__pow2(d2)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +pfo: {F.array__perfect(U32, d2, OUT) == True{} : Bool},
    +ih: {O.sl_go(q, (j + 1 : U32), base, F.array__thaw(U32, F.array__upd(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))), (O.Words{F.array__thaw(U32, t), n}, WR.at(F.array__slots(U32, t), Nat.add(B, 1n+S)))) == (O.Words{F.array__thaw(U32, t), n}, F.array__thaw(U32, scp(d2, t, q, 1n+S, B, F.array__upd(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))))) : O.Words & Array<U32>})
    -> {O.sl_go(1n+q, j, base, F.array__thaw(U32, OUT), (O.Words{F.array__thaw(U32, t), n}, WR.at(F.array__slots(U32, t), Nat.add(B, S)))) == (O.Words{F.array__thaw(U32, t), n}, F.array__thaw(U32, scp(d2, t, 1n+q, S, B, OUT))) : O.Words & Array<U32>}:
  +h0 = bfirst(Nat.add(B, S), 1n+q, F.spec_common__pow2(d), bt)
  +h1 = WR.bound(Nat.add(B, S), 1n, 2n+q, F.spec_common__pow2(d), bt, {==})
  +e1 = ix_next(base, j, B, S, d, hd, eb, ej, h0, h1)
  +k1 = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(d)) == True{} : Bool}, Nat.add(Nat.add(B, S), 1n), Nat.add(B, 1n+S),
      Equal.trans(Nat, Nat.add(Nat.add(B, S), 1n), 1n+Nat.add(B, S), Nat.add(B, 1n+S), WR.add1(Nat.add(B, S)), bsucc(B, S)), h1)
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, OUT), j, WR.at(F.array__slots(U32, t), Nat.add(B, S))), F.array__thaw(U32, F.array__upd(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))),
      WR.set_thaw(d2, OUT, j, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)), hd2, ej, bfirst(S, 1n+q, F.spec_common__pow2(d2), bo), pfo)) :
    {O.sl_go(q, (j + 1 : U32), base, _, O.words_word(O.Words{F.array__thaw(U32, t), n}, (base + j + 1 : U32))) == (O.Words{F.array__thaw(U32, t), n}, F.array__thaw(U32, scp(d2, t, q, 1n+S, B, F.array__upd(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))))) : O.Words & Array<U32>}
  %Equal.sym(O.Words & U32, O.words_word(O.Words{F.array__thaw(U32, t), n}, (base + j + 1 : U32)), (O.Words{F.array__thaw(U32, t), n}, WR.at(F.array__slots(U32, t), Nat.add(B, 1n+S))),
      WR.word_thaw(d, t, n, (base + j + 1 : U32), Nat.add(B, 1n+S), hd, e1, k1, pf)) :
    {O.sl_go(q, (j + 1 : U32), base, F.array__thaw(U32, F.array__upd(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))), _) == (O.Words{F.array__thaw(U32, t), n}, F.array__thaw(U32, scp(d2, t, q, 1n+S, B, F.array__upd(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))))) : O.Words & Array<U32>}
  ih

# O.sl_go reads words B + S .. B + S + k of the storage (tree t, depth d) into words S .. of OUT
def slc(+k: Nat, +j: U32, +S: Nat, +base: U32, +B: Nat, +d: Nat, +t: F.array__Tree<U32>, +n: U32, +d2: Nat, +OUT: F.array__Tree<U32>,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hd2: {Nat.is_lt(d2, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == S : Nat}, +eb: {U32.to_nat(base) == B : Nat},
    +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 1n+k), F.spec_common__pow2(d)) == True{} : Bool}, +bo: {Nat.is_le(Nat.add(S, 1n+k), F.spec_common__pow2(d2)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +pfo: {F.array__perfect(U32, d2, OUT) == True{} : Bool})
    -> {O.sl_go(k, j, base, F.array__thaw(U32, OUT), (O.Words{F.array__thaw(U32, t), n}, WR.at(F.array__slots(U32, t), Nat.add(B, S)))) == (O.Words{F.array__thaw(U32, t), n}, F.array__thaw(U32, scp(d2, t, k, S, B, OUT))) : O.Words & Array<U32>}:
  match k:
    case 0n: slc0(j, S, base, B, t, n, d2, OUT, hd2, ej, bo, pfo)
    case 1n+q:
      slc_step(q, j, S, base, B, d, t, n, d2, OUT, hd, hd2, ej, eb, bt, bo, pf, pfo,
        slc(q, (j + 1 : U32), 1n+S, base, B, d, t, n, d2, F.array__upd(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S))), hd, hd2,
          WR.next_ix(j, S, d2, hd2, ej, WR.bound(S, 1n, 2n+q, F.spec_common__pow2(d2), bo, {==})), eb,
          bnext(B, S, q, F.spec_common__pow2(d), bt), WR.shift_b(S, q, F.spec_common__pow2(d2), bo), pf,
          F.array__upd_perfect(U32, d2, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)), pfo)))

# ---- what the copies hold ----
# below the first word written, bcp leaves T alone
def bcp_out(+d: Nat, +s: F.array__Tree<U32>, +k: Nat, +S: Nat, +B: Nat, +T: F.array__Tree<U32>, +y: Nat,
    +hy: {Nat.is_lt(y, Nat.add(B, S)) == True{} : Bool}, +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 1n+k), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, T) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, bcp(d, s, k, S, B, T)), y) == WR.at(F.array__slots(U32, T), y) : U32}:
  match k:
    case 0n: WR.at_upd_other(d, T, Nat.add(B, S), y, WR.at(F.array__slots(U32, s), S), WR.neq_sym(y, Nat.add(B, S), F.nat__is_eq_lt(y, Nat.add(B, S), hy)), bfirst(Nat.add(B, S), 0n, F.spec_common__pow2(d), bt), pf)
    case 1n+q:
      Equal.trans(U32, WR.at(F.array__slots(U32, bcp(d, s, q, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)))), y),
        WR.at(F.array__slots(U32, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S))), y), WR.at(F.array__slots(U32, T), y),
        bcp_out(d, s, q, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)), y,
          F.nat__lt_le_trans(y, Nat.add(B, S), Nat.add(B, 1n+S), hy, F.nat__le_add_left(S, 1n+S, B, F.nat__le_succ(S))),
          bnext(B, S, q, F.spec_common__pow2(d), bt), F.array__upd_perfect(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S), pf)),
        WR.at_upd_other(d, T, Nat.add(B, S), y, WR.at(F.array__slots(U32, s), S), WR.neq_sym(y, Nat.add(B, S), F.nat__is_eq_lt(y, Nat.add(B, S), hy)), bfirst(Nat.add(B, S), 1n+q, F.spec_common__pow2(d), bt), pf))

def bcp_in0(+d: Nat, +s: F.array__Tree<U32>, +S: Nat, +B: Nat, +T: F.array__Tree<U32>,
    +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 1n), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, T) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, bcp(d, s, 0n, S, B, T)), Nat.add(B, Nat.add(S, 0n))) == WR.at(F.array__slots(U32, s), Nat.add(S, 0n)) : U32}:
  %Equal.sym(Nat, Nat.add(S, 0n), S, F.nat__add_zero(S)) : {WR.at(F.array__slots(U32, bcp(d, s, 0n, S, B, T)), Nat.add(B, _)) == WR.at(F.array__slots(U32, s), _) : U32}
  WR.at_upd_same(d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S), bfirst(Nat.add(B, S), 0n, F.spec_common__pow2(d), bt), pf)

def bcp_in_first(+d: Nat, +s: F.array__Tree<U32>, +q: Nat, +S: Nat, +B: Nat, +T: F.array__Tree<U32>,
    +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 2n+q), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, T) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, bcp(d, s, 1n+q, S, B, T)), Nat.add(B, Nat.add(S, 0n))) == WR.at(F.array__slots(U32, s), Nat.add(S, 0n)) : U32}:
  %Equal.sym(Nat, Nat.add(S, 0n), S, F.nat__add_zero(S)) : {WR.at(F.array__slots(U32, bcp(d, s, 1n+q, S, B, T)), Nat.add(B, _)) == WR.at(F.array__slots(U32, s), _) : U32}
  Equal.trans(U32, WR.at(F.array__slots(U32, bcp(d, s, q, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)))), Nat.add(B, S)),
    WR.at(F.array__slots(U32, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S))), Nat.add(B, S)), WR.at(F.array__slots(U32, s), S),
    bcp_out(d, s, q, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)), Nat.add(B, S),
      F.nat__lt_add_left(S, 1n+S, B, F.nat__lt_succ(S)), bnext(B, S, q, F.spec_common__pow2(d), bt),
      F.array__upd_perfect(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S), pf)),
    WR.at_upd_same(d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S), bfirst(Nat.add(B, S), 1n+q, F.spec_common__pow2(d), bt), pf))

def bcp_in_next(+d: Nat, +s: F.array__Tree<U32>, +q: Nat, +p: Nat, +S: Nat, +B: Nat, +T: F.array__Tree<U32>,
    +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 2n+q), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, T) == True{} : Bool},
    +ih: {WR.at(F.array__slots(U32, bcp(d, s, q, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)))), Nat.add(B, 1n+Nat.add(S, p))) == WR.at(F.array__slots(U32, s), 1n+Nat.add(S, p)) : U32})
    -> {WR.at(F.array__slots(U32, bcp(d, s, 1n+q, S, B, T)), Nat.add(B, Nat.add(S, 1n+p))) == WR.at(F.array__slots(U32, s), Nat.add(S, 1n+p)) : U32}:
  %Equal.sym(Nat, Nat.add(S, 1n+p), 1n+Nat.add(S, p), F.nat__add_succ(S, p)) : {WR.at(F.array__slots(U32, bcp(d, s, 1n+q, S, B, T)), Nat.add(B, _)) == WR.at(F.array__slots(U32, s), _) : U32}
  ih

# word B + (S + m), m <= k, of bcp is word S + m of the source
def bcp_in(+d: Nat, +s: F.array__Tree<U32>, +k: Nat, +m: Nat, +S: Nat, +B: Nat, +T: F.array__Tree<U32>,
    +hm: {Nat.is_le(m, k) == True{} : Bool}, +bt: {Nat.is_le(Nat.add(Nat.add(B, S), 1n+k), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, T) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, bcp(d, s, k, S, B, T)), Nat.add(B, Nat.add(S, m))) == WR.at(F.array__slots(U32, s), Nat.add(S, m)) : U32}:
  match k m:
    case 0n 0n: bcp_in0(d, s, S, B, T, bt, pf)
    case 0n 1n+p: Empty.absurd({WR.at(F.array__slots(U32, bcp(d, s, 0n, S, B, T)), Nat.add(B, Nat.add(S, 1n+p))) == WR.at(F.array__slots(U32, s), Nat.add(S, 1n+p)) : U32}, F.logic__false_true(hm))
    case 1n+q 0n: bcp_in_first(d, s, q, S, B, T, bt, pf)
    case 1n+q 1n+p: bcp_in_next(d, s, q, p, S, B, T, bt, pf, bcp_in(d, s, q, p, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)), hm, bnext(B, S, q, F.spec_common__pow2(d), bt), F.array__upd_perfect(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S), pf)))

# below the first word written, scp leaves OUT alone
def scp_out(+d: Nat, +t: F.array__Tree<U32>, +k: Nat, +S: Nat, +B: Nat, +OUT: F.array__Tree<U32>, +y: Nat,
    +hy: {Nat.is_lt(y, S) == True{} : Bool}, +bo: {Nat.is_le(Nat.add(S, 1n+k), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, OUT) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, scp(d, t, k, S, B, OUT)), y) == WR.at(F.array__slots(U32, OUT), y) : U32}:
  match k:
    case 0n: WR.at_upd_other(d, OUT, S, y, WR.at(F.array__slots(U32, t), Nat.add(B, S)), WR.neq_sym(y, S, F.nat__is_eq_lt(y, S, hy)), bfirst(S, 0n, F.spec_common__pow2(d), bo), pf)
    case 1n+q:
      Equal.trans(U32, WR.at(F.array__slots(U32, scp(d, t, q, 1n+S, B, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S))))), y),
        WR.at(F.array__slots(U32, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))), y), WR.at(F.array__slots(U32, OUT), y),
        scp_out(d, t, q, 1n+S, B, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S))), y,
          F.nat__lt_le_trans(y, S, 1n+S, hy, F.nat__le_succ(S)),
          WR.shift_b(S, q, F.spec_common__pow2(d), bo), F.array__upd_perfect(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)), pf)),
        WR.at_upd_other(d, OUT, S, y, WR.at(F.array__slots(U32, t), Nat.add(B, S)), WR.neq_sym(y, S, F.nat__is_eq_lt(y, S, hy)), bfirst(S, 1n+q, F.spec_common__pow2(d), bo), pf))

def scp_in0(+d: Nat, +t: F.array__Tree<U32>, +S: Nat, +B: Nat, +OUT: F.array__Tree<U32>,
    +bo: {Nat.is_le(Nat.add(S, 1n), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, OUT) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, scp(d, t, 0n, S, B, OUT)), Nat.add(S, 0n)) == WR.at(F.array__slots(U32, t), Nat.add(B, Nat.add(S, 0n))) : U32}:
  %Equal.sym(Nat, Nat.add(S, 0n), S, F.nat__add_zero(S)) : {WR.at(F.array__slots(U32, scp(d, t, 0n, S, B, OUT)), _) == WR.at(F.array__slots(U32, t), Nat.add(B, _)) : U32}
  WR.at_upd_same(d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)), bfirst(S, 0n, F.spec_common__pow2(d), bo), pf)

def scp_in_first(+d: Nat, +t: F.array__Tree<U32>, +q: Nat, +S: Nat, +B: Nat, +OUT: F.array__Tree<U32>,
    +bo: {Nat.is_le(Nat.add(S, 2n+q), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, OUT) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, scp(d, t, 1n+q, S, B, OUT)), Nat.add(S, 0n)) == WR.at(F.array__slots(U32, t), Nat.add(B, Nat.add(S, 0n))) : U32}:
  %Equal.sym(Nat, Nat.add(S, 0n), S, F.nat__add_zero(S)) : {WR.at(F.array__slots(U32, scp(d, t, 1n+q, S, B, OUT)), _) == WR.at(F.array__slots(U32, t), Nat.add(B, _)) : U32}
  Equal.trans(U32, WR.at(F.array__slots(U32, scp(d, t, q, 1n+S, B, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S))))), S),
    WR.at(F.array__slots(U32, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)))), S), WR.at(F.array__slots(U32, t), Nat.add(B, S)),
    scp_out(d, t, q, 1n+S, B, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S))), S,
      F.nat__lt_succ(S), WR.shift_b(S, q, F.spec_common__pow2(d), bo),
      F.array__upd_perfect(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)), pf)),
    WR.at_upd_same(d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)), bfirst(S, 1n+q, F.spec_common__pow2(d), bo), pf))

def scp_in_next(+d: Nat, +t: F.array__Tree<U32>, +q: Nat, +p: Nat, +S: Nat, +B: Nat, +OUT: F.array__Tree<U32>,
    +bo: {Nat.is_le(Nat.add(S, 2n+q), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, OUT) == True{} : Bool},
    +ih: {WR.at(F.array__slots(U32, scp(d, t, q, 1n+S, B, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S))))), 1n+Nat.add(S, p)) == WR.at(F.array__slots(U32, t), Nat.add(B, 1n+Nat.add(S, p))) : U32})
    -> {WR.at(F.array__slots(U32, scp(d, t, 1n+q, S, B, OUT)), Nat.add(S, 1n+p)) == WR.at(F.array__slots(U32, t), Nat.add(B, Nat.add(S, 1n+p))) : U32}:
  %Equal.sym(Nat, Nat.add(S, 1n+p), 1n+Nat.add(S, p), F.nat__add_succ(S, p)) : {WR.at(F.array__slots(U32, scp(d, t, 1n+q, S, B, OUT)), _) == WR.at(F.array__slots(U32, t), Nat.add(B, _)) : U32}
  ih

# word S + m, m <= k, of scp is word B + (S + m) of the storage
def scp_in(+d: Nat, +t: F.array__Tree<U32>, +k: Nat, +m: Nat, +S: Nat, +B: Nat, +OUT: F.array__Tree<U32>,
    +hm: {Nat.is_le(m, k) == True{} : Bool}, +bo: {Nat.is_le(Nat.add(S, 1n+k), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, OUT) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, scp(d, t, k, S, B, OUT)), Nat.add(S, m)) == WR.at(F.array__slots(U32, t), Nat.add(B, Nat.add(S, m))) : U32}:
  match k m:
    case 0n 0n: scp_in0(d, t, S, B, OUT, bo, pf)
    case 0n 1n+p: Empty.absurd({WR.at(F.array__slots(U32, scp(d, t, 0n, S, B, OUT)), Nat.add(S, 1n+p)) == WR.at(F.array__slots(U32, t), Nat.add(B, Nat.add(S, 1n+p))) : U32}, F.logic__false_true(hm))
    case 1n+q 0n: scp_in_first(d, t, q, S, B, OUT, bo, pf)
    case 1n+q 1n+p: scp_in_next(d, t, q, p, S, B, OUT, bo, pf, scp_in(d, t, q, p, 1n+S, B, F.array__upd(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S))), hm, WR.shift_b(S, q, F.spec_common__pow2(d), bo), F.array__upd_perfect(U32, d, OUT, S, WR.at(F.array__slots(U32, t), Nat.add(B, S)), pf)))

# (B + 0) + (1 + k) <= P from B + (1 + k) <= P
def bzero(+B: Nat, +k: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(B, 1n+k), P) == True{} : Bool}) -> {Nat.is_le(Nat.add(Nat.add(B, 0n), 1n+k), P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n+k), P) == True{} : Bool}, B, Nat.add(B, 0n), Equal.sym(Nat, Nat.add(B, 0n), B, F.nat__add_zero(B)), h)


# ---- blit then slice ----
# the value's words 0 .. k blitted at word B and sliced back into OUT: word m <= k is word m of the value
def cell_word(+d: Nat, +t: F.array__Tree<U32>, +s: F.array__Tree<U32>, +d2: Nat, +OUT: F.array__Tree<U32>, +k: Nat, +B: Nat, +m: Nat,
    +hm: {Nat.is_le(m, k) == True{} : Bool}, +hr: {Nat.is_le(Nat.add(B, 1n+k), F.spec_common__pow2(d)) == True{} : Bool},
    +bo: {Nat.is_le(1n+k, F.spec_common__pow2(d2)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +pfo: {F.array__perfect(U32, d2, OUT) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, scp(d2, bcp(d, s, k, 0n, B, t), k, 0n, B, OUT)), m) == WR.at(F.array__slots(U32, s), m) : U32}:
  Equal.trans(U32, WR.at(F.array__slots(U32, scp(d2, bcp(d, s, k, 0n, B, t), k, 0n, B, OUT)), m), WR.at(F.array__slots(U32, bcp(d, s, k, 0n, B, t)), Nat.add(B, m)), WR.at(F.array__slots(U32, s), m),
    scp_in(d2, bcp(d, s, k, 0n, B, t), k, m, 0n, B, OUT, hm, bo, pfo),
    bcp_in(d, s, k, m, 0n, B, t, hm, bzero(B, k, F.spec_common__pow2(d), hr), pf))
# the blit tree is the run of the source's words written at the place (words_win.bend's tk)
def bcp_tk(+k: Nat, +S: Nat, +B: Nat, +d: Nat, +s: F.array__Tree<U32>, +T: F.array__Tree<U32>)
    -> {bcp(d, s, k, S, B, T) == WW.tk(WL.alist(1n+k, F.array__slots(U32, s), S), d, T, B, S) : F.array__Tree<U32>}:
  match k:
    case 0n: {==}
    case 1n+q:
      %Equal.sym(F.array__Tree<U32>, bcp(d, s, q, 1n+S, B, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S))),
          WW.tk(WL.alist(1n+q, F.array__slots(U32, s), 1n+S), d, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)), B, 1n+S),
          bcp_tk(q, 1n+S, B, d, s, F.array__upd(U32, d, T, Nat.add(B, S), WR.at(F.array__slots(U32, s), S)))) :
        {_ == WW.tk(WL.alist(2n+q, F.array__slots(U32, s), S), d, T, B, S) : F.array__Tree<U32>}
      {==}
