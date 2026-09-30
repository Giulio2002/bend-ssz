import Base
import ../compact/found.bend as F
import ./words_rw.bend as WR
import ./mtree_run.bend as MR

# Writing a run of words into packed storage: tk(xs, d, t, q, m) is the perfect tree t (depth d) after word q + m is set to the
# head of xs, word q + m + 1 to the next, and so on (the chain of F.array__upd that the runtime's element writes are, in
# proofs/obj/coll_words.bend). Over a perfect tree whose words q + m .. q + m + len(xs) are below 2^d:
#   - a word before the run, or after it, is unchanged       (at_tk_before, at_tk_after)
#   - word q + m + j of the run is the j-th of xs            (at_tk_in)
# (WR.at is the word of a slot list, 0 past the end.) codegen/coll_laws.py's view laws use them to read the written
# storage back through the spec view of a list.

def tk(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +m: Nat) -> F.array__Tree<U32>:
  match xs:
    case Nil{}: t
    case Con{x, r}: tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)

def tk_perfect(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +m: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {F.array__perfect(U32, d, tk(xs, d, t, q, m)) == True{} : Bool}:
  match xs:
    case Nil{}: pf
    case Con{x, r}: tk_perfect(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m, F.array__upd_perfect(U32, d, t, Nat.add(q, m), x, pf))

# ---- index arithmetic ----
# (q + m) + (1 + l) is (q + (1 + m)) + l
def add_shift(+q: Nat, +m: Nat, +l: Nat) -> {Nat.add(Nat.add(q, m), 1n+l) == Nat.add(Nat.add(q, 1n+m), l) : Nat}:
  Equal.trans(Nat, Nat.add(Nat.add(q, m), 1n+l), 1n+Nat.add(Nat.add(q, m), l), Nat.add(Nat.add(q, 1n+m), l),
    F.nat__add_succ(Nat.add(q, m), l),
    Equal.cong(Nat, Nat, z => Nat.add(z, l), 1n+Nat.add(q, m), Nat.add(q, 1n+m), Equal.sym(Nat, Nat.add(q, 1n+m), 1n+Nat.add(q, m), F.nat__add_succ(q, m))))

def shift_le(+q: Nat, +m: Nat, +l: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(q, m), 1n+l), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(q, 1n+m), l), P) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(Nat.add(q, m), 1n+l), Nat.add(Nat.add(q, 1n+m), l), add_shift(q, m, l), h)

# the first index of a run is below the bound
def first_lt(+q: Nat, +m: Nat, +l: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(q, m), 1n+l), P) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(q, m), P) == True{} : Bool}:
  F.nat__lt_le_trans(Nat.add(q, m), Nat.add(Nat.add(q, m), 1n+l), P,
    F.nat__lt_le_trans(Nat.add(q, m), 1n+Nat.add(q, m), Nat.add(Nat.add(q, m), 1n+l), F.nat__lt_succ(Nat.add(q, m)),
      F.logic__subst(Nat, z => {Nat.is_le(1n+Nat.add(q, m), z) == True{} : Bool}, 1n+Nat.add(Nat.add(q, m), l), Nat.add(Nat.add(q, m), 1n+l),
        Equal.sym(Nat, Nat.add(Nat.add(q, m), 1n+l), 1n+Nat.add(Nat.add(q, m), l), F.nat__add_succ(Nat.add(q, m), l)),
        F.nat__le_add_right(Nat.add(q, m), l))), h)

# the index one step on is above any index below this one
def lt_next(+q: Nat, +m: Nat, +y: Nat, +h: {Nat.is_lt(y, Nat.add(q, m)) == True{} : Bool}) -> {Nat.is_lt(y, Nat.add(q, 1n+m)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(y, z) == True{} : Bool}, 1n+Nat.add(q, m), Nat.add(q, 1n+m), Equal.sym(Nat, Nat.add(q, 1n+m), 1n+Nat.add(q, m), F.nat__add_succ(q, m)),
    F.nat__lt_trans(y, Nat.add(q, m), 1n+Nat.add(q, m), h, F.nat__lt_succ(Nat.add(q, m))))

# ---- before and after the run ----
def at_tk_before(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +m: Nat, +y: Nat,
    +hy: {Nat.is_lt(y, Nat.add(q, m)) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(Nat.add(q, m), F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, tk(xs, d, t, q, m)), y) == WR.at(F.array__slots(U32, t), y) : U32}:
  match xs:
    case Nil{}: {==}
    case Con{x, r}:
      Equal.trans(U32, WR.at(F.array__slots(U32, tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), y),
        WR.at(F.array__slots(U32, F.array__upd(U32, d, t, Nat.add(q, m), x)), y), WR.at(F.array__slots(U32, t), y),
        at_tk_before(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m, y, lt_next(q, m, y, hy), shift_le(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb),
          F.array__upd_perfect(U32, d, t, Nat.add(q, m), x, pf)),
        WR.at_upd_other(d, t, Nat.add(q, m), y, x, WR.neq_sym(y, Nat.add(q, m), F.nat__is_eq_lt(y, Nat.add(q, m), hy)),
          first_lt(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb), pf))

def at_tk_after(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +m: Nat, +y: Nat,
    +hy: {Nat.is_le(Nat.add(Nat.add(q, m), F.spec_common__length(U32, xs)), y) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(Nat.add(q, m), F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, tk(xs, d, t, q, m)), y) == WR.at(F.array__slots(U32, t), y) : U32}:
  match xs:
    case Nil{}: {==}
    case Con{x, r}:
      Equal.trans(U32, WR.at(F.array__slots(U32, tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), y),
        WR.at(F.array__slots(U32, F.array__upd(U32, d, t, Nat.add(q, m), x)), y), WR.at(F.array__slots(U32, t), y),
        at_tk_after(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m, y, shift_le(q, m, F.spec_common__length(U32, r), y, hy),
          shift_le(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb), F.array__upd_perfect(U32, d, t, Nat.add(q, m), x, pf)),
        WR.at_upd_other(d, t, Nat.add(q, m), y, x, F.nat__is_eq_lt(Nat.add(q, m), y, first_lt(q, m, F.spec_common__length(U32, r), y, hy)),
          first_lt(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb), pf))

# ---- in the run ----
def at_tk_in(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +m: Nat, +j: Nat,
    +hj: {Nat.is_lt(j, F.spec_common__length(U32, xs)) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(Nat.add(q, m), F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {WR.at(F.array__slots(U32, tk(xs, d, t, q, m)), Nat.add(Nat.add(q, m), j)) == WR.at(xs, j) : U32}:
  match xs j:
    case Nil{} _: Empty.absurd({WR.at(F.array__slots(U32, tk(Nil{}, d, t, q, m)), Nat.add(Nat.add(q, m), j)) == WR.at(Nil{}, j) : U32}, F.nat__lt_zero_absurd(j, hj))
    case Con{x, r} 0n:
      %Equal.sym(Nat, Nat.add(Nat.add(q, m), 0n), Nat.add(q, m), F.nat__add_zero(Nat.add(q, m))) :
        {WR.at(F.array__slots(U32, tk(Con{x, r}, d, t, q, m)), _) == x : U32}
      Equal.trans(U32, WR.at(F.array__slots(U32, tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), Nat.add(q, m)),
        WR.at(F.array__slots(U32, F.array__upd(U32, d, t, Nat.add(q, m), x)), Nat.add(q, m)), x,
        at_tk_before(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m, Nat.add(q, m),
          F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, m), z) == True{} : Bool}, 1n+Nat.add(q, m), Nat.add(q, 1n+m), Equal.sym(Nat, Nat.add(q, 1n+m), 1n+Nat.add(q, m), F.nat__add_succ(q, m)), F.nat__lt_succ(Nat.add(q, m))),
          shift_le(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb), F.array__upd_perfect(U32, d, t, Nat.add(q, m), x, pf)),
        WR.at_upd_same(d, t, Nat.add(q, m), x, first_lt(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb), pf))
    case Con{x, r} 1n+p:
      %Equal.sym(Nat, Nat.add(Nat.add(q, m), 1n+p), Nat.add(Nat.add(q, 1n+m), p), add_shift(q, m, p)) :
        {WR.at(F.array__slots(U32, tk(Con{x, r}, d, t, q, m)), _) == WR.at(r, p) : U32}
      at_tk_in(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m, p, hj, shift_le(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb), F.array__upd_perfect(U32, d, t, Nat.add(q, m), x, pf))

# ---- reading the written storage through the spec's word lookup MR.wd ----
def wd_at(+W: List<&2, U32>, +k: Nat) -> {MR.wd(W, k) == WR.at(W, k) : U32}:
  match W k:
    case Nil{} _: {==}
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: wd_at(t, p)

# ---- the words of the written storage ----
def wd_before(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +y: Nat, +hy: {Nat.is_lt(y, q) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(q, F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {MR.wd(F.array__slots(U32, tk(xs, d, t, q, 0n)), y) == MR.wd(F.array__slots(U32, t), y) : U32}:
  Equal.trans(U32, MR.wd(F.array__slots(U32, tk(xs, d, t, q, 0n)), y), WR.at(F.array__slots(U32, tk(xs, d, t, q, 0n)), y), MR.wd(F.array__slots(U32, t), y),
    wd_at(F.array__slots(U32, tk(xs, d, t, q, 0n)), y),
    Equal.trans(U32, WR.at(F.array__slots(U32, tk(xs, d, t, q, 0n)), y), WR.at(F.array__slots(U32, t), y), MR.wd(F.array__slots(U32, t), y),
      at_tk_before(xs, d, t, q, 0n, y,
        F.logic__subst(Nat, z => {Nat.is_lt(y, z) == True{} : Bool}, q, Nat.add(q, 0n), Equal.sym(Nat, Nat.add(q, 0n), q, F.nat__add_zero(q)), hy),
        F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, q, Nat.add(q, 0n), Equal.sym(Nat, Nat.add(q, 0n), q, F.nat__add_zero(q)), hb), pf),
      Equal.sym(U32, MR.wd(F.array__slots(U32, t), y), WR.at(F.array__slots(U32, t), y), wd_at(F.array__slots(U32, t), y))))

def wd_after(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +y: Nat, +hy: {Nat.is_le(Nat.add(q, F.spec_common__length(U32, xs)), y) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(q, F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {MR.wd(F.array__slots(U32, tk(xs, d, t, q, 0n)), y) == MR.wd(F.array__slots(U32, t), y) : U32}:
  Equal.trans(U32, MR.wd(F.array__slots(U32, tk(xs, d, t, q, 0n)), y), WR.at(F.array__slots(U32, tk(xs, d, t, q, 0n)), y), MR.wd(F.array__slots(U32, t), y),
    wd_at(F.array__slots(U32, tk(xs, d, t, q, 0n)), y),
    Equal.trans(U32, WR.at(F.array__slots(U32, tk(xs, d, t, q, 0n)), y), WR.at(F.array__slots(U32, t), y), MR.wd(F.array__slots(U32, t), y),
      at_tk_after(xs, d, t, q, 0n, y,
        F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, F.spec_common__length(U32, xs)), y) == True{} : Bool}, q, Nat.add(q, 0n), Equal.sym(Nat, Nat.add(q, 0n), q, F.nat__add_zero(q)), hy),
        F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, q, Nat.add(q, 0n), Equal.sym(Nat, Nat.add(q, 0n), q, F.nat__add_zero(q)), hb), pf),
      Equal.sym(U32, MR.wd(F.array__slots(U32, t), y), WR.at(F.array__slots(U32, t), y), wd_at(F.array__slots(U32, t), y))))

def wd_in(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +j: Nat, +hj: {Nat.is_lt(j, F.spec_common__length(U32, xs)) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(q, F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {MR.wd(F.array__slots(U32, tk(xs, d, t, q, 0n)), Nat.add(q, j)) == WR.at(xs, j) : U32}:
  Equal.trans(U32, MR.wd(F.array__slots(U32, tk(xs, d, t, q, 0n)), Nat.add(q, j)), WR.at(F.array__slots(U32, tk(xs, d, t, q, 0n)), Nat.add(q, j)), WR.at(xs, j),
    wd_at(F.array__slots(U32, tk(xs, d, t, q, 0n)), Nat.add(q, j)),
    F.logic__subst(Nat, z => {WR.at(F.array__slots(U32, tk(xs, d, t, q, 0n)), z) == WR.at(xs, j) : U32}, Nat.add(Nat.add(q, 0n), j), Nat.add(q, j),
      Equal.cong(Nat, Nat, z => Nat.add(z, j), Nat.add(q, 0n), q, F.nat__add_zero(q)),
      at_tk_in(xs, d, t, q, 0n, j, hj,
        F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, q, Nat.add(q, 0n), Equal.sym(Nat, Nat.add(q, 0n), q, F.nat__add_zero(q)), hb), pf)))

