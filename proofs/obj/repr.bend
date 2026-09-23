import Base
import ../../proofs/compact/found.bend as F

# The representation bridge for buffers: a buffer array is determined by its
# indexed words, whatever tree it is.
#
# Base's `Array<U32>` is a tree (`ALeaf`/`ANode`); `Array.new` builds a perfect
# tree and `Array.set`/`Array.get` keep it perfect (proofs/compact/found.bend
# `array__new`, `array__set`, `array__upd_perfect`), and found.bend's model
# `array__thaw(t)` covers exactly those arrays. This module proves that every
# perfect tree of depth d IS the canonical tree `build(d, ...)` of its slot list,
# and that the slot list IS the list of its words `w(t, 0) .. w(t, 2^d - 1)`.
# So a law proved for the literal tree of free words (the per-name
# `*_spec_decode`/`*_spec_view` laws) holds for every buffer array of that
# depth: proofs/obj/spec_repr_*.bend instantiate it name by name.

def head0(xs: List<&2, U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, t}: h

def tail0(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, t}: t

def tails(xs: List<&2, U32>, +i: Nat) -> List<&2, U32>:
  match i:
    case 0n: xs
    case 1n+p: tail0(tails(xs, p))

# Word i of the tree (0 past the end, never reached for i < 2^d).
def w(t: F.array__Tree<U32>, +i: Nat) -> U32:
  head0(tails(F.array__slots(U32, t), i))

# The first n elements of a list, one by one.
def lits(+n: Nat, +xs: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{head0(xs), lits(p, tail0(xs))}

# The canonical perfect tree of depth d over a slot list.
def build(+d: Nat, +xs: List<&2, U32>) -> F.array__Tree<U32>:
  match d:
    case 0n: F.TLeaf{head0(xs)}
    case 1n+p: F.TNode{build(p, F.spec_common__take(U32, xs, F.spec_common__pow2(p))), build(p, F.spec_common__drop(U32, xs, F.spec_common__pow2(p)))}

law take_app:
  for +xs: List<&2, U32>
  for +ys: List<&2, U32>
  {F.spec_common__take(U32, F.spec_common__append(U32, xs, ys), F.spec_common__length(U32, xs)) == xs : List<&2, U32>}
def take_app(xs, ys):
  match xs:
    case Nil{}:
      match ys:
        case Nil{}: {==}
        case Con{h, t}: {==}
    case Con{+h, +t}:
      F.list__cons_cong(U32, h, F.spec_common__take(U32, F.spec_common__append(U32, t, ys), F.spec_common__length(U32, t)), t, take_app(t, ys))

law drop_app:
  for +xs: List<&2, U32>
  for +ys: List<&2, U32>
  {F.spec_common__drop(U32, F.spec_common__append(U32, xs, ys), F.spec_common__length(U32, xs)) == ys : List<&2, U32>}
def drop_app(xs, ys):
  match xs:
    case Nil{}:
      match ys:
        case Nil{}: {==}
        case Con{h, t}: {==}
    case Con{+h, +t}: drop_app(t, ys)

law canon:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  {build(d, F.array__slots(U32, t)) == t : F.array__Tree<U32>}
def canon(d, t, pf):
  match d t:
    case 0n F.TLeaf{x}: {==}
    case 0n F.TNode{l, r}:
      Empty.absurd({build(0n, F.array__slots(U32, F.TNode{l, r})) == F.TNode{l, r} : F.array__Tree<U32>}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{x}:
      Empty.absurd({build(1n+p, F.array__slots(U32, F.TLeaf{x})) == F.TLeaf{x} : F.array__Tree<U32>}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r}:
      +pl = F.array__pf_left(U32, p, l, r, pf)
      +pr = F.array__pf_right(U32, p, l, r, pf)
      +sl = F.array__slots(U32, l)
      +sr = F.array__slots(U32, r)
      +len = F.array__slots_length(U32, p, l, pl)
      %Equal.cong(Nat, List<&2, U32>, n => F.spec_common__take(U32, F.spec_common__append(U32, sl, sr), n), F.spec_common__length(U32, sl), F.spec_common__pow2(p), len) :
        {F.TNode{build(p, _), build(p, F.spec_common__drop(U32, F.spec_common__append(U32, sl, sr), F.spec_common__pow2(p)))} == F.TNode{l, r} : F.array__Tree<U32>}
      %Equal.cong(Nat, List<&2, U32>, n => F.spec_common__drop(U32, F.spec_common__append(U32, sl, sr), n), F.spec_common__length(U32, sl), F.spec_common__pow2(p), len) :
        {F.TNode{build(p, F.spec_common__take(U32, F.spec_common__append(U32, sl, sr), F.spec_common__length(U32, sl))), build(p, _)} == F.TNode{l, r} : F.array__Tree<U32>}
      %Equal.sym(List<&2, U32>, F.spec_common__take(U32, F.spec_common__append(U32, sl, sr), F.spec_common__length(U32, sl)), sl, take_app(sl, sr)) :
        {F.TNode{build(p, _), build(p, F.spec_common__drop(U32, F.spec_common__append(U32, sl, sr), F.spec_common__length(U32, sl)))} == F.TNode{l, r} : F.array__Tree<U32>}
      %Equal.sym(List<&2, U32>, F.spec_common__drop(U32, F.spec_common__append(U32, sl, sr), F.spec_common__length(U32, sl)), sr, drop_app(sl, sr)) :
        {F.TNode{build(p, sl), build(p, _)} == F.TNode{l, r} : F.array__Tree<U32>}
      %Equal.sym(F.array__Tree<U32>, build(p, sl), l, canon(p, l, pl)) :
        {F.TNode{_, build(p, sr)} == F.TNode{l, r} : F.array__Tree<U32>}
      %Equal.sym(F.array__Tree<U32>, build(p, sr), r, canon(p, r, pr)) :
        {F.TNode{l, _} == F.TNode{l, r} : F.array__Tree<U32>}
      {==}

law eta:
  for +n: Nat
  for +xs: List<&2, U32>
  for +e: {F.spec_common__length(U32, xs) == n : Nat}
  {xs == lits(n, xs) : List<&2, U32>}
def eta(n, xs, e):
  match n xs:
    case 0n Nil{}: {==}
    case 0n Con{h, t}: Empty.absurd({Con{h, t} == Nil{} : List<&2, U32>}, F.nat__zero_succ(F.spec_common__length(U32, t), Equal.sym(Nat, 1n+F.spec_common__length(U32, t), 0n, e)))
    case 1n+p Nil{}: Empty.absurd({Nil{} == lits(1n+p, Nil{}) : List<&2, U32>}, F.nat__zero_succ(p, e))
    case 1n+ +p Con{+h, +t}:
      F.list__cons_cong(U32, h, t, lits(p, t), eta(p, t, F.nat__succ_inj(F.spec_common__length(U32, t), p, e)))

# Every perfect tree of depth d is the canonical tree of its words.
law tree_words:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  {build(d, lits(F.spec_common__pow2(d), F.array__slots(U32, t))) == t : F.array__Tree<U32>}
def tree_words(d, t, pf):
  %eta(F.spec_common__pow2(d), F.array__slots(U32, t), F.array__slots_length(U32, d, t, pf)) :
    {build(d, _) == t : F.array__Tree<U32>}
  canon(d, t, pf)
