import Base
import ../../src/obj.bend as O
import ../../src/buffer.bend as B
import ../compact/found.bend as F
import ../compact/arith.bend as A

# Word-level laws of packed object storage O.Words{thaw(t), n}, t a perfect tree of U32 words of
# depth d < 32: writing word k (O.words_setw) is updating slot k of the tree, and reading word k
# (O.words_word) returns slot k, which after a write at k is the value written and after a write
# elsewhere is what it was. Word indices are U32 at run time and Nat in the tree; `ek` relates them.
# codegen/coll_laws.py composes these into the read-back laws of the packed collections.

# the word in slot k (0 past the end)
def at(xs: List<&2, U32>, +k: Nat) -> U32:
  match xs k:
    case Nil{} _: 0
    case Con{h, t} 0n: h
    case Con{h, t} 1n+p: at(t, p)

def nth_at(+xs: List<&2, U32>, +k: Nat, +h: {Nat.is_lt(k, F.spec_common__length(U32, xs)) == True{} : Bool})
    -> {F.spec_common__nth(U32, xs, k) == Some{at(xs, k)} : Maybe<&2, U32>}:
  match xs k:
    case Nil{} _: Empty.absurd({F.spec_common__nth(U32, Nil{}, k) == Some{at(Nil{}, k)} : Maybe<&2, U32>}, F.nat__lt_zero_absurd(k, h))
    case Con{x, t} 0n: {==}
    case Con{x, t} 1n+p: nth_at(t, p, h)

def at_update_same(+xs: List<&2, U32>, +k: Nat, +x: U32, +h: {Nat.is_lt(k, F.spec_common__length(U32, xs)) == True{} : Bool})
    -> {at(F.spec_common__update(U32, xs, k, x), k) == x : U32}:
  match xs k:
    case Nil{} _: Empty.absurd({at(F.spec_common__update(U32, Nil{}, k, x), k) == x : U32}, F.nat__lt_zero_absurd(k, h))
    case Con{y, t} 0n: {==}
    case Con{y, t} 1n+p: at_update_same(t, p, x, h)

def at_update_other(+xs: List<&2, U32>, +k: Nat, +l: Nat, +x: U32, +ne: {Nat.is_eq(k, l) == False{} : Bool})
    -> {at(F.spec_common__update(U32, xs, k, x), l) == at(xs, l) : U32}:
  match xs k l:
    case Nil{} _ _: {==}
    case Con{y, t} 0n 0n: Empty.absurd({at(F.spec_common__update(U32, Con{y, t}, 0n, x), 0n) == at(Con{y, t}, 0n) : U32}, F.logic__true_false(ne))
    case Con{y, t} 0n 1n+q: {==}
    case Con{y, t} 1n+p 0n: {==}
    case Con{y, t} 1n+p 1n+q: at_update_other(t, p, q, x, ne)

# k < 2^d is k < the number of slots
def slots_lt(+d: Nat, +t: F.array__Tree<U32>, +k: Nat, +hk: {Nat.is_lt(k, F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}) -> {Nat.is_lt(k, F.spec_common__length(U32, F.array__slots(U32, t))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(U32, F.array__slots(U32, t)), F.spec_common__pow2(d), F.array__slots_length(U32, d, t, pf)) : {Nat.is_lt(k, _) == True{} : Bool}
  hk

def setw_thaw(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +j: U32, +k: Nat, +x: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ek: {U32.to_nat(j) == k : Nat}, +hk: {Nat.is_lt(k, F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {O.words_setw(O.Words{F.array__thaw(U32, t), n}, j, x) == O.Words{F.array__thaw(U32, F.array__upd(U32, d, t, k, x)), n} : O.Words}:
  +hj = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(d)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ek), hk)
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, t), j, x), F.array__thaw(U32, F.array__upd(U32, d, t, U32.to_nat(j), x)),
      F.array__set(U32, d, t, j, x, at(F.array__slots(U32, t), U32.to_nat(j)), hd, hj, nth_at(F.array__slots(U32, t), U32.to_nat(j), slots_lt(d, t, U32.to_nat(j), hj, pf)), pf)) :
    {O.Words{_, n} == O.Words{F.array__thaw(U32, F.array__upd(U32, d, t, k, x)), n} : O.Words}
  %Equal.sym(Nat, U32.to_nat(j), k, ek) : {O.Words{F.array__thaw(U32, F.array__upd(U32, d, t, _, x)), n} == O.Words{F.array__thaw(U32, F.array__upd(U32, d, t, k, x)), n} : O.Words}
  {==}

def word_thaw(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +j: U32, +k: Nat,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ek: {U32.to_nat(j) == k : Nat}, +hk: {Nat.is_lt(k, F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {O.words_word(O.Words{F.array__thaw(U32, t), n}, j) == (O.Words{F.array__thaw(U32, t), n}, at(F.array__slots(U32, t), k)) : O.Words & U32}:
  +hj = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(d)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ek), hk)
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), j), (F.array__thaw(U32, t), at(F.array__slots(U32, t), U32.to_nat(j))),
      F.array__get(U32, d, t, j, at(F.array__slots(U32, t), U32.to_nat(j)), hd, hj, nth_at(F.array__slots(U32, t), U32.to_nat(j), slots_lt(d, t, U32.to_nat(j), hj, pf)), pf)) :
    {O.rewrap_w(n, _) == (O.Words{F.array__thaw(U32, t), n}, at(F.array__slots(U32, t), k)) : O.Words & U32}
  %Equal.sym(Nat, U32.to_nat(j), k, ek) : {(O.Words{F.array__thaw(U32, t), n}, at(F.array__slots(U32, t), _)) == (O.Words{F.array__thaw(U32, t), n}, at(F.array__slots(U32, t), k)) : O.Words & U32}
  {==}

# the same two laws for bit storage O.Bits{thaw(t), n} (its words are read and written the same way)
def bsetw_thaw(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +j: U32, +k: Nat, +x: U32,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ek: {U32.to_nat(j) == k : Nat}, +hk: {Nat.is_lt(k, F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {O.bits_setw(O.Bits{F.array__thaw(U32, t), n}, j, x) == O.Bits{F.array__thaw(U32, F.array__upd(U32, d, t, k, x)), n} : O.Bits}:
  +hj = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(d)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ek), hk)
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, t), j, x), F.array__thaw(U32, F.array__upd(U32, d, t, U32.to_nat(j), x)),
      F.array__set(U32, d, t, j, x, at(F.array__slots(U32, t), U32.to_nat(j)), hd, hj, nth_at(F.array__slots(U32, t), U32.to_nat(j), slots_lt(d, t, U32.to_nat(j), hj, pf)), pf)) :
    {O.Bits{_, n} == O.Bits{F.array__thaw(U32, F.array__upd(U32, d, t, k, x)), n} : O.Bits}
  %Equal.sym(Nat, U32.to_nat(j), k, ek) : {O.Bits{F.array__thaw(U32, F.array__upd(U32, d, t, _, x)), n} == O.Bits{F.array__thaw(U32, F.array__upd(U32, d, t, k, x)), n} : O.Bits}
  {==}

def bword_thaw(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +j: U32, +k: Nat,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ek: {U32.to_nat(j) == k : Nat}, +hk: {Nat.is_lt(k, F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {O.bits_word(O.Bits{F.array__thaw(U32, t), n}, j) == (O.Bits{F.array__thaw(U32, t), n}, at(F.array__slots(U32, t), k)) : O.Bits & U32}:
  +hj = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(d)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ek), hk)
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), j), (F.array__thaw(U32, t), at(F.array__slots(U32, t), U32.to_nat(j))),
      F.array__get(U32, d, t, j, at(F.array__slots(U32, t), U32.to_nat(j)), hd, hj, nth_at(F.array__slots(U32, t), U32.to_nat(j), slots_lt(d, t, U32.to_nat(j), hj, pf)), pf)) :
    {O.rewrap_b(n, _) == (O.Bits{F.array__thaw(U32, t), n}, at(F.array__slots(U32, t), k)) : O.Bits & U32}
  %Equal.sym(Nat, U32.to_nat(j), k, ek) : {(O.Bits{F.array__thaw(U32, t), n}, at(F.array__slots(U32, t), _)) == (O.Bits{F.array__thaw(U32, t), n}, at(F.array__slots(U32, t), k)) : O.Bits & U32}
  {==}

def at_upd_same(+d: Nat, +t: F.array__Tree<U32>, +k: Nat, +x: U32, +hk: {Nat.is_lt(k, F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}) -> {at(F.array__slots(U32, F.array__upd(U32, d, t, k, x)), k) == x : U32}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, F.array__upd(U32, d, t, k, x)), F.spec_common__update(U32, F.array__slots(U32, t), k, x), F.array__upd_slots(U32, d, t, k, x, hk, pf)) :
    {at(_, k) == x : U32}
  at_update_same(F.array__slots(U32, t), k, x, slots_lt(d, t, k, hk, pf))

def at_upd_other(+d: Nat, +t: F.array__Tree<U32>, +k: Nat, +l: Nat, +x: U32, +ne: {Nat.is_eq(k, l) == False{} : Bool},
    +hk: {Nat.is_lt(k, F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {at(F.array__slots(U32, F.array__upd(U32, d, t, k, x)), l) == at(F.array__slots(U32, t), l) : U32}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, F.array__upd(U32, d, t, k, x)), F.spec_common__update(U32, F.array__slots(U32, t), k, x), F.array__upd_slots(U32, d, t, k, x, hk, pf)) :
    {at(_, l) == at(F.array__slots(U32, t), l) : U32}
  at_update_other(F.array__slots(U32, t), k, l, x, ne)

# q + a and q + b differ when a and b do
def neq_add(+q: Nat, +a: Nat, +b: Nat, +h: {Nat.is_eq(a, b) == False{} : Bool}) -> {Nat.is_eq(Nat.add(q, a), Nat.add(q, b)) == False{} : Bool}:
  match q:
    case 0n: h
    case 1n+p: neq_add(p, a, b, h)

# word m < W of an element whose W words start at q and fit below P
def bound(+q: Nat, +m: Nat, +W: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(q, W), P) == True{} : Bool}, +hm: {Nat.is_lt(m, W) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(q, m), P) == True{} : Bool}:
  match q P:
    case 0n _: F.nat__lt_le_trans(m, W, P, hm, h)
    case 1n+p 0n: Empty.absurd({Nat.is_lt(Nat.add(1n+p, m), 0n) == True{} : Bool}, F.logic__false_true(h))
    case 1n+p 1n+R: bound(p, m, W, R, h, hm)

# the run-time index j + m of word m, as a Nat: q + m (no wrap: the word is below 2^d, d < 32)
def idx_le(+j: U32, +q: Nat, +m: U32, +mm: Nat, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +eq: {U32.to_nat(j) == q : Nat},
    +em: {U32.to_nat(m) == mm : Nat}, +hb: {Nat.is_lt(Nat.add(q, mm), F.spec_common__pow2(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(j), U32.to_nat(m)), U32.to_nat(F.u32__pow2u(d))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(j), q, eq) : {Nat.is_le(Nat.add(_, U32.to_nat(m)), U32.to_nat(F.u32__pow2u(d))) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(m), mm, em) : {Nat.is_le(Nat.add(q, _), U32.to_nat(F.u32__pow2u(d))) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(F.u32__pow2u(d)), F.spec_common__pow2(d), F.u32__pow2u_value(d, hd)) : {Nat.is_le(Nat.add(q, mm), _) == True{} : Bool}
  F.nat__lt_le(Nat.add(q, mm), F.spec_common__pow2(d), hb)

def idx(+j: U32, +q: Nat, +m: U32, +mm: Nat, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +eq: {U32.to_nat(j) == q : Nat},
    +em: {U32.to_nat(m) == mm : Nat}, +hb: {Nat.is_lt(Nat.add(q, mm), F.spec_common__pow2(d)) == True{} : Bool})
    -> {U32.to_nat((j + m : U32)) == Nat.add(q, mm) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(j, m)), Nat.add(U32.to_nat(j), U32.to_nat(m)), A.add_le(j, m, F.u32__pow2u(d), idx_le(j, q, m, mm, d, hd, eq, em, hb))) :
    {_ == Nat.add(q, mm) : Nat}
  %Equal.sym(Nat, U32.to_nat(j), q, eq) : {Nat.add(_, U32.to_nat(m)) == Nat.add(q, mm) : Nat}
  %Equal.sym(Nat, U32.to_nat(m), mm, em) : {Nat.add(q, _) == Nat.add(q, mm) : Nat}
  {==}

# word 0 is at q itself
def idx0(+j: U32, +q: Nat, +eq: {U32.to_nat(j) == q : Nat}) -> {U32.to_nat(j) == Nat.add(q, 0n) : Nat}:
  Equal.trans(Nat, U32.to_nat(j), q, Nat.add(q, 0n), eq, Equal.sym(Nat, Nat.add(q, 0n), q, F.nat__add_zero(q)))

# ---- room ----
# O.words_fit leaves the storage alone when it has room for `want` bytes (no reallocation): the
# capacity it asks for, 8 * ceil(want / 32) + 8 words, is within the 2^d words of the tree
def fit_roomy(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +want: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hroom: {U32.is_le((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32), F.u32__pow2u(d)) == True{} : Bool})
    -> {O.words_fit(O.Words{F.array__thaw(U32, t), n}, want) == O.Words{F.array__thaw(U32, t), n} : O.Words}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(d)), F.array__size_thaw(U32, d, t, pf)) :
    {O.fit_sized(n, want, _) == O.Words{F.array__thaw(U32, t), n} : O.Words}
  %Equal.sym(Bool, U32.is_le((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32), F.u32__pow2u(d)), True{}, hroom) :
    {O.fit_pick(_, n, want, F.u32__pow2u(d), F.array__thaw(U32, t)) == O.Words{F.array__thaw(U32, t), n} : O.Words}
  {==}

# ---- disjoint elements ----
# a != b gives b != a
def neq_sym(+a: Nat, +b: Nat, +h: {Nat.is_eq(a, b) == False{} : Bool}) -> {Nat.is_eq(b, a) == False{} : Bool}:
  match a b:
    case 0n 0n: h
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: neq_sym(p, q, h)

# word a of an element at q (W words) and word b of an element at r that starts at or after q + W differ
def ne_lo(+q: Nat, +a: Nat, +W: Nat, +r: Nat, +b: Nat, +h: {Nat.is_le(Nat.add(q, W), r) == True{} : Bool}, +ha: {Nat.is_lt(a, W) == True{} : Bool})
    -> {Nat.is_eq(Nat.add(q, a), Nat.add(r, b)) == False{} : Bool}:
  F.nat__is_eq_lt(Nat.add(q, a), Nat.add(r, b), F.nat__lt_le_trans(Nat.add(q, a), r, Nat.add(r, b), bound(q, a, W, r, h, ha), F.nat__le_add_right(r, b)))

# the same when the other element ends at or before q
def ne_hi(+q: Nat, +a: Nat, +W: Nat, +r: Nat, +b: Nat, +h: {Nat.is_le(Nat.add(r, W), q) == True{} : Bool}, +hb: {Nat.is_lt(b, W) == True{} : Bool})
    -> {Nat.is_eq(Nat.add(q, a), Nat.add(r, b)) == False{} : Bool}:
  neq_sym(Nat.add(r, b), Nat.add(q, a), ne_lo(r, b, W, q, a, h, hb))

# ---- growth: O.gcopy copies words J .. J + k of the old storage into the new one ----
# the new storage tree after the copy (Nat indices)
def cpy(+d2: Nat, +t1: F.array__Tree<U32>, +k: Nat, +J: Nat, +T2: F.array__Tree<U32>) -> F.array__Tree<U32>:
  match k:
    case 0n: F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J))
    case 1n+q: cpy(d2, t1, q, 1n+J, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J)))

def cpy_perfect(+d2: Nat, +t1: F.array__Tree<U32>, +k: Nat, +J: Nat, +T2: F.array__Tree<U32>, +pf: {F.array__perfect(U32, d2, T2) == True{} : Bool})
    -> {F.array__perfect(U32, d2, cpy(d2, t1, k, J, T2)) == True{} : Bool}:
  match k:
    case 0n: F.array__upd_perfect(U32, d2, T2, J, at(F.array__slots(U32, t1), J), pf)
    case 1n+q: cpy_perfect(d2, t1, q, 1n+J, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J)), F.array__upd_perfect(U32, d2, T2, J, at(F.array__slots(U32, t1), J), pf))

def set_thaw(+d: Nat, +t: F.array__Tree<U32>, +j: U32, +J: Nat, +x: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == J : Nat},
    +hJ: {Nat.is_lt(J, F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.set(U32, F.array__thaw(U32, t), j, x) == F.array__thaw(U32, F.array__upd(U32, d, t, J, x)) : Array<U32>}:
  +hj = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(d)) == True{} : Bool}, J, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), J, ej), hJ)
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, t), j, x), F.array__thaw(U32, F.array__upd(U32, d, t, U32.to_nat(j), x)),
      F.array__set(U32, d, t, j, x, at(F.array__slots(U32, t), U32.to_nat(j)), hd, hj, nth_at(F.array__slots(U32, t), U32.to_nat(j), slots_lt(d, t, U32.to_nat(j), hj, pf)), pf)) :
    {_ == F.array__thaw(U32, F.array__upd(U32, d, t, J, x)) : Array<U32>}
  %Equal.sym(Nat, U32.to_nat(j), J, ej) : {F.array__thaw(U32, F.array__upd(U32, d, t, _, x)) == F.array__thaw(U32, F.array__upd(U32, d, t, J, x)) : Array<U32>}
  {==}

def get_thaw(+d: Nat, +t: F.array__Tree<U32>, +j: U32, +J: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == J : Nat},
    +hJ: {Nat.is_lt(J, F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.get(U32, F.array__thaw(U32, t), j) == (F.array__thaw(U32, t), at(F.array__slots(U32, t), J)) : Array<U32> & U32}:
  +hj = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(d)) == True{} : Bool}, J, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), J, ej), hJ)
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), j), (F.array__thaw(U32, t), at(F.array__slots(U32, t), U32.to_nat(j))),
      F.array__get(U32, d, t, j, at(F.array__slots(U32, t), U32.to_nat(j)), hd, hj, nth_at(F.array__slots(U32, t), U32.to_nat(j), slots_lt(d, t, U32.to_nat(j), hj, pf)), pf)) :
    {_ == (F.array__thaw(U32, t), at(F.array__slots(U32, t), J)) : Array<U32> & U32}
  %Equal.sym(Nat, U32.to_nat(j), J, ej) : {(F.array__thaw(U32, t), at(F.array__slots(U32, t), _)) == (F.array__thaw(U32, t), at(F.array__slots(U32, t), J)) : Array<U32> & U32}
  {==}

# J + 1 as the successor
def add1(+J: Nat) -> {Nat.add(J, 1n) == 1n+J : Nat}:
  Equal.trans(Nat, Nat.add(J, 1n), 1n+Nat.add(J, 0n), 1n+J, F.nat__add_succ(J, 0n), F.nat__succ_cong(Nat.add(J, 0n), J, F.nat__add_zero(J)))

def j_lt(+J: Nat, +P: Nat, +h: {Nat.is_lt(Nat.add(J, 0n), P) == True{} : Bool}) -> {Nat.is_lt(J, P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(z, P) == True{} : Bool}, Nat.add(J, 0n), J, F.nat__add_zero(J), h)

def j1_lt(+J: Nat, +P: Nat, +h: {Nat.is_lt(Nat.add(J, 1n), P) == True{} : Bool}) -> {Nat.is_lt(1n+J, P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(z, P) == True{} : Bool}, Nat.add(J, 1n), 1n+J, add1(J), h)

# the index after j: J + 1, no wrap (it is below 2^d, d < 32)
def next_ix(+j: U32, +J: Nat, +d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == J : Nat}, +hb: {Nat.is_lt(Nat.add(J, 1n), F.spec_common__pow2(d)) == True{} : Bool})
    -> {U32.to_nat((j + 1 : U32)) == 1n+J : Nat}:
  Equal.trans(Nat, U32.to_nat((j + 1 : U32)), Nat.add(J, 1n), 1n+J, idx(j, J, 1, 1n, d, hd, ej, {==}, hb), add1(J))

# J + (2 + q) is 1 + (J + (1 + q))
def shift_b(+J: Nat, +q: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(J, 2n+q), P) == True{} : Bool}) -> {Nat.is_le(Nat.add(1n+J, 1n+q), P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(J, 2n+q), 1n+Nat.add(J, 1n+q), F.nat__add_succ(J, 1n+q), h)

def gcp0(+j: U32, +J: Nat, +t1: F.array__Tree<U32>, +d2: Nat, +T2: F.array__Tree<U32>, +hd2: {Nat.is_lt(d2, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == J : Nat},
    +hJ: {Nat.is_lt(J, F.spec_common__pow2(d2)) == True{} : Bool}, +pf2: {F.array__perfect(U32, d2, T2) == True{} : Bool})
    -> {O.gcopy(0n, j, F.array__thaw(U32, T2), (F.array__thaw(U32, t1), at(F.array__slots(U32, t1), J))) == (F.array__thaw(U32, cpy(d2, t1, 0n, J, T2)), F.array__thaw(U32, t1)) : Array<U32> & Array<U32>}:
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, T2), j, at(F.array__slots(U32, t1), J)), F.array__thaw(U32, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J))), set_thaw(d2, T2, j, J, at(F.array__slots(U32, t1), J), hd2, ej, hJ, pf2)) :
    {(_, F.array__thaw(U32, t1)) == (F.array__thaw(U32, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J))), F.array__thaw(U32, t1)) : Array<U32> & Array<U32>}
  {==}

def gcp_step(+q: Nat, +j: U32, +J: Nat, +d1: Nat, +t1: F.array__Tree<U32>, +d2: Nat, +T2: F.array__Tree<U32>,
    +hd1: {Nat.is_lt(d1, 32n) == True{} : Bool}, +hd2: {Nat.is_lt(d2, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == J : Nat},
    +b1: {Nat.is_le(Nat.add(J, 2n+q), F.spec_common__pow2(d1)) == True{} : Bool}, +b2: {Nat.is_le(Nat.add(J, 2n+q), F.spec_common__pow2(d2)) == True{} : Bool},
    +pf1: {F.array__perfect(U32, d1, t1) == True{} : Bool}, +pf2: {F.array__perfect(U32, d2, T2) == True{} : Bool},
    +ih: {O.gcopy(q, (j + 1 : U32), F.array__thaw(U32, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J))), (F.array__thaw(U32, t1), at(F.array__slots(U32, t1), 1n+J))) == (F.array__thaw(U32, cpy(d2, t1, q, 1n+J, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J)))), F.array__thaw(U32, t1)) : Array<U32> & Array<U32>})
    -> {O.gcopy(1n+q, j, F.array__thaw(U32, T2), (F.array__thaw(U32, t1), at(F.array__slots(U32, t1), J))) == (F.array__thaw(U32, cpy(d2, t1, 1n+q, J, T2)), F.array__thaw(U32, t1)) : Array<U32> & Array<U32>}:
  +hJ = j_lt(J, F.spec_common__pow2(d2), bound(J, 0n, 2n+q, F.spec_common__pow2(d2), b2, {==}))
  +h1 = bound(J, 1n, 2n+q, F.spec_common__pow2(d1), b1, {==})
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, T2), j, at(F.array__slots(U32, t1), J)), F.array__thaw(U32, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J))), set_thaw(d2, T2, j, J, at(F.array__slots(U32, t1), J), hd2, ej, hJ, pf2)) :
    {O.gcopy(q, (j + 1 : U32), _, Array.get(U32, F.array__thaw(U32, t1), (j + 1 : U32))) == (F.array__thaw(U32, cpy(d2, t1, q, 1n+J, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J)))), F.array__thaw(U32, t1)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t1), (j + 1 : U32)), (F.array__thaw(U32, t1), at(F.array__slots(U32, t1), 1n+J)), get_thaw(d1, t1, (j + 1 : U32), 1n+J, hd1, next_ix(j, J, d1, hd1, ej, h1), j1_lt(J, F.spec_common__pow2(d1), h1), pf1)) :
    {O.gcopy(q, (j + 1 : U32), F.array__thaw(U32, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J))), _) == (F.array__thaw(U32, cpy(d2, t1, q, 1n+J, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J)))), F.array__thaw(U32, t1)) : Array<U32> & Array<U32>}
  ih

# The copy of words J .. J + k of the old storage (tree t1, depth d1) into the new one (T2, depth d2):
# the new storage is the tree cpy(..), and the old one is handed back unchanged.
def gcp(+k: Nat, +j: U32, +J: Nat, +d1: Nat, +t1: F.array__Tree<U32>, +d2: Nat, +T2: F.array__Tree<U32>,
    +hd1: {Nat.is_lt(d1, 32n) == True{} : Bool}, +hd2: {Nat.is_lt(d2, 32n) == True{} : Bool}, +ej: {U32.to_nat(j) == J : Nat},
    +b1: {Nat.is_le(Nat.add(J, 1n+k), F.spec_common__pow2(d1)) == True{} : Bool}, +b2: {Nat.is_le(Nat.add(J, 1n+k), F.spec_common__pow2(d2)) == True{} : Bool},
    +pf1: {F.array__perfect(U32, d1, t1) == True{} : Bool}, +pf2: {F.array__perfect(U32, d2, T2) == True{} : Bool})
    -> {O.gcopy(k, j, F.array__thaw(U32, T2), (F.array__thaw(U32, t1), at(F.array__slots(U32, t1), J))) == (F.array__thaw(U32, cpy(d2, t1, k, J, T2)), F.array__thaw(U32, t1)) : Array<U32> & Array<U32>}:
  match k:
    case 0n: gcp0(j, J, t1, d2, T2, hd2, ej, j_lt(J, F.spec_common__pow2(d2), bound(J, 0n, 1n, F.spec_common__pow2(d2), b2, {==})), pf2)
    case 1n+q:
      gcp_step(q, j, J, d1, t1, d2, T2, hd1, hd2, ej, b1, b2, pf1, pf2,
        gcp(q, (j + 1 : U32), 1n+J, d1, t1, d2, F.array__upd(U32, d2, T2, J, at(F.array__slots(U32, t1), J)), hd1, hd2,
          next_ix(j, J, d1, hd1, ej, bound(J, 1n, 2n+q, F.spec_common__pow2(d1), b1, {==})), shift_b(J, q, F.spec_common__pow2(d1), b1), shift_b(J, q, F.spec_common__pow2(d2), b2), pf1,
          F.array__upd_perfect(U32, d2, T2, J, at(F.array__slots(U32, t1), J), pf2)))

# U32.is_eq as equality of the numbers
def u32_eq_nat(+d: U32, +k: U32, +et: {U32.is_eq(d, k) == True{} : Bool}) -> {U32.to_nat(d) == U32.to_nat(k) : Nat}:
  F.nat__eq_from_is_eq(U32.to_nat(d), U32.to_nat(k), F.logic__subst(Cmp, c => {Cmp.is_eq(c) == True{} : Bool}, U32.cmp(d, k), Nat.cmp(U32.to_nat(d), U32.to_nat(k)), F.u32__u32_cmp(d, k), et))

# O.words_fit reallocates when the storage has no room: the new storage is the zero tree of the depth
# it asks for (B.zeros, hz: coll_words.bend's zeros_new) with the old words 0 .. (n + 3) / 4 copied in
def fit_grow(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +want: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hfull: {U32.is_le((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32), F.u32__pow2u(d)) == False{} : Bool},
    +hz: {B.zeros(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))) == Array.new(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0) : Array<U32>}, +hd2: {Nat.is_lt(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 32n) == True{} : Bool},
    +b1: {Nat.is_le(Nat.add(0n, 1n+U32.to_nat(U32.shrn((n + 3 : U32), 2n))), F.spec_common__pow2(d)) == True{} : Bool}, +b2: {Nat.is_le(Nat.add(0n, 1n+U32.to_nat(U32.shrn((n + 3 : U32), 2n))), F.spec_common__pow2(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))))) == True{} : Bool})
    -> {O.words_fit(O.Words{F.array__thaw(U32, t), n}, want) == O.Words{F.array__thaw(U32, cpy(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), t, U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0n, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))), n} : O.Words}:
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(d)), F.array__size_thaw(U32, d, t, pf)) :
    {O.fit_sized(n, want, _) == O.Words{F.array__thaw(U32, cpy(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), t, U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0n, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))), n} : O.Words}
  %Equal.sym(Bool, U32.is_le((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32), F.u32__pow2u(d)), False{}, hfull) :
    {O.fit_pick(_, n, want, F.u32__pow2u(d), F.array__thaw(U32, t)) == O.Words{F.array__thaw(U32, cpy(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), t, U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0n, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))), n} : O.Words}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), Array.new(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0), hz) :
    {O.gfin(n, O.gcopy(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, _, Array.get(U32, F.array__thaw(U32, t), 0))) == O.Words{F.array__thaw(U32, cpy(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), t, U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0n, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))), n} : O.Words}
  %Equal.sym(Array<U32>, Array.new(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0), F.array__thaw(U32, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0)), F.array__new(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0)) :
    {O.gfin(n, O.gcopy(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, _, Array.get(U32, F.array__thaw(U32, t), 0))) == O.Words{F.array__thaw(U32, cpy(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), t, U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0n, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))), n} : O.Words}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), 0), (F.array__thaw(U32, t), at(F.array__slots(U32, t), 0n)), get_thaw(d, t, 0, 0n, hd, {==}, bound(0n, 0n, 1n+U32.to_nat(U32.shrn((n + 3 : U32), 2n)), F.spec_common__pow2(d), b1, {==}), pf)) :
    {O.gfin(n, O.gcopy(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, F.array__thaw(U32, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0)), _)) == O.Words{F.array__thaw(U32, cpy(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), t, U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0n, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))), n} : O.Words}
  %Equal.sym(Array<U32> & Array<U32>, O.gcopy(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, F.array__thaw(U32, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0)), (F.array__thaw(U32, t), at(F.array__slots(U32, t), 0n))), (F.array__thaw(U32, cpy(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), t, U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0n, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))), F.array__thaw(U32, t)),
      gcp(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, 0n, d, t, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0), hd, hd2, {==}, b1, b2, pf, F.array__trep_perfect(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))) :
    {O.gfin(n, _) == O.Words{F.array__thaw(U32, cpy(U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), t, U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0n, F.array__trep(U32, U32.to_nat(B.words_depth_u((U32.shrn((want + 31 : U32), 5n) * 8 + 8 : U32))), 0))), n} : O.Words}
  {==}
