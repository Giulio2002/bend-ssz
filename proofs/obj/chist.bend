import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d
import ../compact/found.bend as F
import ./dk.bend as DK
import ./capi.bend as CA
import ./cgrow.bend as CG

# Histories of writes and appends on the cached list l1099511627776_Validator. A history is
# a list of operations; `run` applies them to a cache through the public API
# (`cset`, `capp`), keeping the returned cache. `ok` is each operation's
# precondition against the length at that point: a write inside the list, an
# append that the runtime guard accepts (`CA.guard`) and that keeps n + 1 <= 2^k
# (k <= 30, k <= the limit depth 40).
#
# hist_inv: from a valid cache, running an ok history ends in a valid cache,
# i.e. one of the form cached(ta, t, n, d, lo, hi) with CA.inv. With CA.root_eq
# its root is then the reference root of its elements (dig(n, ta)); with
# CA.cache_inv the history can start from cache(o) of a list o.

type Op is Data:
  HWrite{i: U32, v: FuluValidator_d.Validator}
  HAppend{v: FuluValidator_d.Validator}

def keep(pr: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool) -> Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached:
  (c, +b) = pr
  c

def step(op: Op, c: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached) -> Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached:
  match op:
    case HWrite{+i, +v}: keep(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset(c, i, v))
    case HAppend{+v}: keep(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp(c, v))

def run(ops: List<&2, Op>, c: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached) -> Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached:
  match ops:
    case Nil{}: c
    case Con{+op, rest}: run(rest, step(op, c))

def okop(op: Op, +n: U32, +k: Nat) -> Data:
  match op:
    case HWrite{+i, +v}: {Nat.is_lt(U32.to_nat(i), U32.to_nat(n)) == True{} : Bool}
    case HAppend{+v}: DK.P2({CA.guard(n) == True{} : Bool}, {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool})

def op_len(op: Op, +n: U32) -> U32:
  match op:
    case HWrite{+i, +v}: n
    case HAppend{+v}: (n + 1 : U32)

def ok(ops: List<&2, Op>, +n: U32, +k: Nat) -> Data:
  match ops:
    case Nil{}: Unit
    case Con{+op, rest}: DK.P2(okop(op, n, k), ok(rest, op_len(op, n), k))

# A valid cache, as data: its components and their facts.
def valid(-c: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached) -> Data:
  DK.Ex(F.array__Tree<FuluValidator_d.Validator>, ta => DK.Ex(Nat, dw => DK.Ex(F.array__Tree<D.Digest>, t =>
  DK.Ex(U32, n => DK.Ex(Nat, d => DK.Ex(U32, lo => DK.Ex(U32, hi =>
  DK.P2({c == CA.cached(ta, t, n, d, lo, hi) : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached}, CA.inv(ta, dw, t, n, d, lo, hi)))))))))

def len_of(c: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached) -> U32:
  match c:
    case Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached{arr, +n, +d, nodes, +lo, +hi}: n

# ---- one step ----------------------------------------------------------------------------

def keep_eq(-c2: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, -pr: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool, +e: {pr == (c2, True{}) : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool})
    -> {c2 == keep(pr) : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached}:
  %Equal.sym(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached & Bool, pr, (c2, True{}), e) : {c2 == keep(_) : Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached}
  {==}

def fit_case(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +t: F.array__Tree<D.Digest>, +n: U32, +d: Nat, +lo: U32, +hi: U32, +v: FuluValidator_d.Validator,
    +k: Nat, +hk: {Nat.is_le(k, 30n) == True{} : Bool}, +hkD: {Nat.is_le(k, 40n) == True{} : Bool},
    +hgd: {CA.guard(n) == True{} : Bool},
    +hn1: {Nat.is_le(U32.to_nat((n + 1 : U32)), O.pow2n(k)) == True{} : Bool},
    +iv: CA.inv(ta, dw, t, n, d, lo, hi),
    +b: Bool, +eb: {Nat.is_lt(U32.to_nat(n), O.pow2n(d)) == b : Bool})
    -> DK.P2(valid(keep(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp(CA.cached(ta, t, n, d, lo, hi), v))),
             {len_of(keep(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp(CA.cached(ta, t, n, d, lo, hi), v))) == (n + 1 : U32) : U32}):
  match b:
    case True{}:
      -c2 = CA.cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), t, (n + 1 : U32), d, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n))
      %keep_eq(c2, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp(CA.cached(ta, t, n, d, lo, hi), v), CA.capp_eq(ta, dw, t, n, d, lo, hi, v, eb, hgd, iv)) :
        DK.P2(valid(_), {len_of(_) == (n + 1 : U32) : U32})
      ((F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(n), v), (dw, (t, ((n + 1 : U32), (d, (O.pick(U32.is_le(lo, n), lo, n), (O.pick(U32.is_le(n, hi), hi, n),
        ({==}, CA.capp_inv(ta, dw, t, n, d, lo, hi, v, eb, iv))))))))), {==})
    case False{}:
      -c2 = CA.cached(CG.gitems(dw, n, ta, v), CA.dnew(1n+d), (n + 1 : U32), 1n+d, 0, (O.pow2u(1n+d) - 1 : U32))
      %keep_eq(c2, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_capp(CA.cached(ta, t, n, d, lo, hi), v), CG.grow_eq(ta, dw, t, n, d, lo, hi, v, k, hk, hn1, hgd, eb, iv)) :
        DK.P2(valid(_), {len_of(_) == (n + 1 : U32) : U32})
      ((CG.gitems(dw, n, ta, v), (CG.rdepth(CG.fits(dw, n), dw, n), (CA.dnew(1n+d), ((n + 1 : U32), (1n+d, (0, ((O.pow2u(1n+d) - 1 : U32),
        ({==}, CG.grow_inv(ta, dw, t, n, d, lo, hi, v, k, hk, hn1, hkD, eb, iv))))))))), {==})

# One ok step keeps a valid cache valid, and moves the length as op_len says.
def step_inv(op: Op, +ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +t: F.array__Tree<D.Digest>, +n: U32, +d: Nat, +lo: U32, +hi: U32,
    +k: Nat, +hk: {Nat.is_le(k, 30n) == True{} : Bool}, +hkD: {Nat.is_le(k, 40n) == True{} : Bool},
    +hop: okop(op, n, k), +iv: CA.inv(ta, dw, t, n, d, lo, hi))
    -> DK.P2(valid(step(op, CA.cached(ta, t, n, d, lo, hi))), {len_of(step(op, CA.cached(ta, t, n, d, lo, hi))) == op_len(op, n) : U32}):
  match op:
    case HWrite{+i, +v}:
      -c2 = CA.cached(F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v), t, n, d, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i))
      %keep_eq(c2, Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_cset(CA.cached(ta, t, n, d, lo, hi), i, v), CA.cset_eq(ta, dw, t, n, d, lo, hi, i, v, hop, iv)) :
        DK.P2(valid(_), {len_of(_) == n : U32})
      ((F.array__upd(FuluValidator_d.Validator, dw, ta, U32.to_nat(i), v), (dw, (t, (n, (d, (O.pick(U32.is_le(lo, i), lo, i), (O.pick(U32.is_le(i, hi), hi, i),
        ({==}, CA.cset_inv(ta, dw, t, n, d, lo, hi, i, v, hop, iv))))))))), {==})
    case HAppend{+v}:
      (+hgd, +hn1) = hop
      fit_case(ta, dw, t, n, d, lo, hi, v, k, hk, hkD, hgd, hn1, iv, Nat.is_lt(U32.to_nat(n), O.pow2n(d)), {==})

def rebase(+ta: F.array__Tree<FuluValidator_d.Validator>, +dw: Nat, +t: F.array__Tree<D.Digest>, +n2: U32, +n: U32, +d: Nat, +lo: U32, +hi: U32,
    +e: {n2 == n : U32}, +iv: CA.inv(ta, dw, t, n2, d, lo, hi)) -> CA.inv(ta, dw, t, n, d, lo, hi):
  %e : CA.inv(ta, dw, t, _, d, lo, hi)
  iv

# The two facts of a pair (a destructured pair's sibling cannot be destructured again).
def pa(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:
  (+a, +b) = p
  a

def pb(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:
  (+a, +b) = p
  b

# ---- histories ------------------------------------------------------------------------------

def run_valid(ops: List<&2, Op>, -c: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, +n: U32, +k: Nat,
    +hk: {Nat.is_le(k, 30n) == True{} : Bool}, +hkD: {Nat.is_le(k, 40n) == True{} : Bool},
    +pk: DK.P2(ok(ops, n, k), DK.P2(valid(c), {len_of(c) == n : U32}))) -> valid(run(ops, c)):
  match ops:
    case Nil{}:
      (+hok, +st) = pk
      (+vc, +en) = st
      vc
    case Con{+op, rest}:
      (+hok, +st) = pk
      (+vc, +en) = st
      (+ta, w1) = vc
      (+dw, w2) = w1
      (+t, w3) = w2
      (+n2, w4) = w3
      (+d, w5) = w4
      (+lo, w6) = w5
      (+hi, w7) = w6
      (+ec, +iv) = w7
      +hop = pa(okop(op, n, k), ok(rest, op_len(op, n), k), hok)
      +hrest = pb(okop(op, n, k), ok(rest, op_len(op, n), k), hok)
      %Equal.sym(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, c, CA.cached(ta, t, n2, d, lo, hi), ec) : valid(run(rest, step(op, _)))
      +en2 = Equal.trans(U32, n2, len_of(c), n, Equal.sym(U32, len_of(c), n2, Equal.cong(Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached, U32, x => len_of(x), c, CA.cached(ta, t, n2, d, lo, hi), ec)), en)
      %Equal.sym(U32, n2, n, en2) : valid(run(rest, step(op, CA.cached(ta, t, _, d, lo, hi))))
      run_valid(rest, step(op, CA.cached(ta, t, n, d, lo, hi)), op_len(op, n), k, hk, hkD,
        (hrest, step_inv(op, ta, dw, t, n, d, lo, hi, k, hk, hkD, hop, rebase(ta, dw, t, n2, n, d, lo, hi, en2, iv))))

# From a valid cache of length n, an ok history of writes and appends ends in a valid cache.
law hist_inv:
  for ops: List<&2, Op>
  for -c: Fulu_list_Validator_1099511627776_d.l1099511627776_Validator_Cached
  for +n: U32
  for +k: Nat
  for +hk: {Nat.is_le(k, 30n) == True{} : Bool}
  for +hkD: {Nat.is_le(k, 40n) == True{} : Bool}
  for +hok: ok(ops, n, k)
  for +vc: valid(c)
  for +en: {len_of(c) == n : U32}
  valid(run(ops, c))
def hist_inv(ops, c, n, k, hk, hkD, hok, vc, en): run_valid(ops, c, n, k, hk, hkD, (hok, (vc, en)))
