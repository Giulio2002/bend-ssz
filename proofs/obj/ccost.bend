import Base
import ../compact/found_generated.bend as F
import ./ctree.bend as CT

# The work of the cached root: how many nodes a sweep rehashes.
#
# cloop2.bend's `clevels` proves that the runtime's level loops
# (`<list>_levels`) are `mlevels_t(k, l, ...)`, which at level 1 + l runs
# `mlevel_t(CT.qn(1 + l, lo, hi), ...)`: one node hash per step, over the
# level's dirty range [rng(1 + l, lo), rng(1 + l, hi)]. The leaf loop hashes
# hi - lo + 1 elements, and the padding to the limit depth hashes one node per
# missing level. `ncost(k, l, lo, hi)` is the number of node hashes of
# `mlevels_t(k, l, ...)`: the sum of those step counts, by the same recursion.
#
# sweep_cost: ncost(k, l, lo, hi) <= (rng(l, hi) - rng(l, lo)) + 3k. For the
# whole sweep (l = 0, k = d) that is (hi - lo) + 3d node hashes; after one
# write (lo = hi) at most 3d, i.e. O(log n) for a list of n <= 2^d elements,
# where hashing the whole tree takes 2^d - 1.

def ncost(k: Nat, +l: Nat, +lo: Nat, +hi: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n+r: Nat.add(CT.qn(1n+l, lo, hi), ncost(r, 1n+l, lo, hi))

def tri(k: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n+r: 3n+tri(r)

# 2 * floor(A / 2) <= A.
def dh(+A: Nat) -> {Nat.is_le(Nat.double(CT.h2(A)), A) == True{} : Bool}:
  match A:
    case 0n: {==}
    case 1n+ +p:
      match p:
        case 0n: {==}
        case 1n+ +q: dh(q)

def sub0(+x: Nat) -> {Nat.sub(0n, x) == 0n : Nat}:
  match x:
    case 0n: {==}
    case 1n+ +p: {==}

def ad(+m: Nat) -> {Nat.add(m, m) == Nat.double(m) : Nat}:
  match m:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.add(p, 1n+p), 1n+Nat.add(p, p), F.nat__add_succ(p, p)) : {1n+_ == Nat.double(1n+p) : Nat}
      %Equal.sym(Nat, Nat.add(p, p), Nat.double(p), ad(p)) : {2n+_ == Nat.double(1n+p) : Nat}
      {==}

def le_rw(+a: Nat, +b: Nat, +d: Nat, +h: {Nat.is_le(Nat.add(d, a), Nat.add(d, b)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(a, d), Nat.add(b, d)) == True{} : Bool}:
  %F.nat__add_comm(d, a) : {Nat.is_le(_, Nat.add(b, d)) == True{} : Bool}
  %F.nat__add_comm(d, b) : {Nat.is_le(Nat.add(d, a), _) == True{} : Bool}
  h

def le_mono_add(+a: Nat, +b: Nat, +c: Nat, +d: Nat, +h1: {Nat.is_le(a, b) == True{} : Bool}, +h2: {Nat.is_le(c, d) == True{} : Bool})
    -> {Nat.is_le(Nat.add(a, c), Nat.add(b, d)) == True{} : Bool}:
  F.nat__le_trans(Nat.add(a, c), Nat.add(a, d), Nat.add(b, d), F.nat__le_add_left(c, d, a, h2), le_rw(a, b, d, F.nat__le_add_left(a, b, d, h1)))

# Halving at most halves a difference, up to rounding: 2 (A/2 - B/2) <= (A - B) + 2.
law half_diff:
  for +A: Nat
  for +B: Nat
  {Nat.is_le(Nat.double(Nat.sub(CT.h2(A), CT.h2(B))), Nat.add(Nat.sub(A, B), 2n)) == True{} : Bool}
def half_diff(A, B):
  match A:
    case 0n:
      %Equal.sym(Nat, Nat.sub(0n, CT.h2(B)), 0n, sub0(CT.h2(B))) : {Nat.is_le(Nat.double(_), Nat.add(Nat.sub(0n, B), 2n)) == True{} : Bool}
      F.nat__zero_le(Nat.add(Nat.sub(0n, B), 2n))
    case 1n+ +p:
      match p:
        case 0n:
          %Equal.sym(Nat, Nat.sub(0n, CT.h2(B)), 0n, sub0(CT.h2(B))) : {Nat.is_le(Nat.double(_), Nat.add(Nat.sub(1n, B), 2n)) == True{} : Bool}
          F.nat__zero_le(Nat.add(Nat.sub(1n, B), 2n))
        case 1n+ +a:
          match B:
            case 0n: F.nat__le_trans(Nat.double(CT.h2(a)), a, Nat.add(a, 2n), dh(a), F.nat__le_add_right(a, 2n))
            case 1n+ +q:
              match q:
                case 0n:
                  %F.nat__add_comm(2n, a) : {Nat.is_le(1n+Nat.double(CT.h2(a)), _) == True{} : Bool}
                  F.nat__le_trans(Nat.double(CT.h2(a)), a, 1n+a, dh(a), F.nat__le_succ(a))
                case 1n+ +b: half_diff(a, b)

def step_rw(+m0: Nat, +m1: Nat, +T: Nat, +hd: {Nat.is_le(Nat.double(m1), Nat.add(m0, 2n)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(m1, Nat.add(m1, T)), Nat.add(m0, 2n+T)) == True{} : Bool}:
  +e3 = Equal.trans(Nat, Nat.add(m1, Nat.add(m1, T)), Nat.add(Nat.add(m1, m1), T), Nat.add(Nat.double(m1), T),
    Equal.sym(Nat, Nat.add(Nat.add(m1, m1), T), Nat.add(m1, Nat.add(m1, T)), F.nat__add_assoc(m1, m1, T)),
    Equal.cong(Nat, Nat, x => Nat.add(x, T), Nat.add(m1, m1), Nat.double(m1), ad(m1)))
  %Equal.sym(Nat, Nat.add(m1, Nat.add(m1, T)), Nat.add(Nat.double(m1), T), e3) : {Nat.is_le(_, Nat.add(m0, 2n+T)) == True{} : Bool}
  %F.nat__add_assoc(m0, 2n, T) : {Nat.is_le(Nat.add(Nat.double(m1), T), _) == True{} : Bool}
  le_mono_add(Nat.double(m1), Nat.add(m0, 2n), T, T, hd, F.nat__le_refl(T))

# The node hashes of levels l + 1 .. l + k are at most the dirty width of level l plus 3 per level.
law sweep_cost:
  for +k: Nat
  for +l: Nat
  for +lo: Nat
  for +hi: Nat
  {Nat.is_le(ncost(k, l, lo, hi), Nat.add(Nat.sub(CT.rng(l, hi), CT.rng(l, lo)), tri(k))) == True{} : Bool}
def sweep_cost(k, l, lo, hi):
  match k:
    case 0n: F.nat__zero_le(Nat.add(Nat.sub(CT.rng(l, hi), CT.rng(l, lo)), 0n))
    case 1n+ +r:
      +m0 = Nat.sub(CT.rng(l, hi), CT.rng(l, lo))
      +m1 = Nat.sub(CT.rng(1n+l, hi), CT.rng(1n+l, lo))
      +N = ncost(r, 1n+l, lo, hi)
      +T = tri(r)
      %Equal.sym(Nat, Nat.add(m0, 3n+T), 1n+Nat.add(m0, 2n+T), F.nat__add_succ(m0, 2n+T)) :
        {Nat.is_le(1n+Nat.add(m1, N), _) == True{} : Bool}
      +c1 = F.nat__le_add_left(N, Nat.add(m1, T), m1, sweep_cost(r, 1n+l, lo, hi))
      F.nat__le_trans(Nat.add(m1, N), Nat.add(m1, Nat.add(m1, T)), Nat.add(m0, 2n+T), c1, step_rw(m0, m1, T, half_diff(CT.rng(l, hi), CT.rng(l, lo))))
