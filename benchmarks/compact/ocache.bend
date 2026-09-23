import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ./objio.bend as IOx

# Cached element roots of a list of objects: BeaconState.validators.
# SSZ_MODE selects what to do with the list a real state decodes to, and the
# program prints the root it ends up with. benchmarks/checks/object_cache.py
# compares the modes with each other and with the independent Python oracle,
# and times them.
#
#  0 root of the list, no cache
#  1 root through a fresh cache (every element hashed)
#  2 root through the cache twice; the second root is printed (every element
#    read out of the cache)
#  3 cache, root, write validator 0's effective_balance := SSZ_ARG, root again
#  4 the same write without a cache, root
#  5 cache, root, append a default validator, root again
#  6 the same append without a cache, root
#  7 decode and force the list, then hash nothing but an empty list: the
#    baseline the other modes are measured against
#  8 apply a history of SSZ_OPS operations seeded by SSZ_ARG to the cached
#    list, then take the cached root
#  9 apply the very same history to the plain list and take the uncached root
#
# The history is a small pseudo-random program: step k writes a seeded
# validator at an index inside or outside the list, or appends one, and the
# seed advances by the usual multiplicative generator. The same history is
# replayed by benchmarks/checks/object_cache.py against the independent oracle,
# so modes 8 and 9 must agree with each other and with it.

def show(d: D.Digest) -> IO(Unit): IO.print("ROOT=" ++ IOx.words(d))

def fin_u(pair: B.Buf & (T.l1099511627776_Validator_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (lst, d) = r
  show(d)

def fin_c(pair: B.Buf & (T.l1099511627776_Validator_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  show(d)

# ---- 0, 1, 2 ---------------------------------------------------------------

def m_uncached(lst: T.l1099511627776_Validator_Seq) -> IO(Unit):
  fin_u(T.l1099511627776_Validator_root(O.hasher(), lst, 0))

def m_first(lst: T.l1099511627776_Validator_Seq) -> IO(Unit):
  fin_c(T.l1099511627776_Validator_cached_root(64n, O.hasher(), T.l1099511627776_Validator_cache(lst), 0))

def warm_again(pair: B.Buf & (T.l1099511627776_Validator_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  fin_c(T.l1099511627776_Validator_cached_root(64n, h, c, 0))

def m_warm(lst: T.l1099511627776_Validator_Seq) -> IO(Unit):
  warm_again(T.l1099511627776_Validator_cached_root(64n, O.hasher(), T.l1099511627776_Validator_cache(lst), 0))

# ---- 3: a write through the cache ------------------------------------------

def set_done(h: B.Buf, res: T.l1099511627776_Validator_Cached & Bool) -> IO(Unit):
  (c, ok) = res
  fin_c(T.l1099511627776_Validator_cached_root(64n, h, c, 0))

def set_elem(+arg: U32, h: B.Buf, c: T.l1099511627776_Validator_Cached, m: Maybe<&1, T.Validator>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "EMPTY")
    case Some{+v}:
      set_done(h, T.l1099511627776_Validator_cset(c, 0, T.Validator_set_effective_balance(v, O.U64{arg, 0})))

def set_got(+arg: U32, h: B.Buf, pr: T.l1099511627776_Validator_Cached & Maybe<&1, T.Validator>) -> IO(Unit):
  (c, m) = pr
  set_elem(arg, h, c, m)

def set_after(+arg: U32, pair: B.Buf & (T.l1099511627776_Validator_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  set_got(arg, h, T.l1099511627776_Validator_cget(c, 0))

def m_update(+arg: U32, lst: T.l1099511627776_Validator_Seq) -> IO(Unit):
  set_after(arg, T.l1099511627776_Validator_cached_root(64n, O.hasher(), T.l1099511627776_Validator_cache(lst), 0))

# ---- 4: the same write with no cache ---------------------------------------

def u_set_done(res: T.l1099511627776_Validator_Seq & Bool) -> IO(Unit):
  (lst, ok) = res
  fin_u(T.l1099511627776_Validator_root(O.hasher(), lst, 0))

def u_set_elem(+arg: U32, lst: T.l1099511627776_Validator_Seq, m: Maybe<&1, T.Validator>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "EMPTY")
    case Some{+v}:
      u_set_done(T.l1099511627776_Validator_set(lst, 0, T.Validator_set_effective_balance(v, O.U64{arg, 0})))

def m_update_plain(+arg: U32, pr: T.l1099511627776_Validator_Seq & Maybe<&1, T.Validator>) -> IO(Unit):
  (lst, m) = pr
  u_set_elem(arg, lst, m)

# ---- 5, 6: an append -------------------------------------------------------

def app_done(h: B.Buf, res: T.l1099511627776_Validator_Cached & Bool) -> IO(Unit):
  (c, ok) = res
  fin_c(T.l1099511627776_Validator_cached_root(64n, h, c, 0))

def app_after(pair: B.Buf & (T.l1099511627776_Validator_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  app_done(h, T.l1099511627776_Validator_capp(c, T.Validator_default()))

def m_append(lst: T.l1099511627776_Validator_Seq) -> IO(Unit):
  app_after(T.l1099511627776_Validator_cached_root(64n, O.hasher(), T.l1099511627776_Validator_cache(lst), 0))

def m_append_plain(res: T.l1099511627776_Validator_Seq & Bool) -> IO(Unit):
  (lst, ok) = res
  fin_u(T.l1099511627776_Validator_root(O.hasher(), lst, 0))

# ---- 7: the baseline: decode and force the list, hash nothing of it --------

def m_baseline(pr: T.l1099511627776_Validator_Seq & U32) -> IO(Unit):
  (lst, +n) = pr
  do IO<Unit>:
    IO.print("FORCED=" ++ U32.show(n))
    fin_u(T.l1099511627776_Validator_root(O.hasher(), T.l1099511627776_Validator_default(), 0))

# ---- 8, 9: a seeded history of writes and appends ---------------------------

def next_seed(+s: U32) -> U32: (s * 1103515245 + 12345 : U32)

def hist_index(+s: U32) -> U32: O.pick(U32.is_eq((s .&. 2 : U32), 0), (U32.shrn(s, 2n) .&. 63 : U32), 100000)

def hist_drop_c(pr: T.l1099511627776_Validator_Cached & Bool) -> T.l1099511627776_Validator_Cached:
  (c, ok) = pr
  c

def hist_step_c(+op: U32, +idx: U32, +s: U32, c: T.l1099511627776_Validator_Cached) -> T.l1099511627776_Validator_Cached:
  match op:
    case 0: hist_drop_c(T.l1099511627776_Validator_cset(c, idx, T.Validator_seed(s)))
    case _: hist_drop_c(T.l1099511627776_Validator_capp(c, T.Validator_seed(s)))

def hist_c(+k: Nat, +s: U32, c: T.l1099511627776_Validator_Cached) -> T.l1099511627776_Validator_Cached:
  match k:
    case 0n: c
    case 1n+q: hist_c(q, next_seed(s), hist_step_c((s .&. 1 : U32), hist_index(s), s, c))

def m_history_cached(+ops: U32, +arg: U32, lst: T.l1099511627776_Validator_Seq) -> IO(Unit):
  fin_c(T.l1099511627776_Validator_cached_root(64n, O.hasher(),
    hist_c(U32.to_nat(ops), arg, T.l1099511627776_Validator_cache(lst)), 0))

def hist_drop_u(pr: T.l1099511627776_Validator_Seq & Bool) -> T.l1099511627776_Validator_Seq:
  (l, ok) = pr
  l

def hist_step_u(+op: U32, +idx: U32, +s: U32, l: T.l1099511627776_Validator_Seq) -> T.l1099511627776_Validator_Seq:
  match op:
    case 0: hist_drop_u(T.l1099511627776_Validator_set(l, idx, T.Validator_seed(s)))
    case _: hist_drop_u(T.l1099511627776_Validator_append(l, T.Validator_seed(s)))

def hist_u(+k: Nat, +s: U32, l: T.l1099511627776_Validator_Seq) -> T.l1099511627776_Validator_Seq:
  match k:
    case 0n: l
    case 1n+q: hist_u(q, next_seed(s), hist_step_u((s .&. 1 : U32), hist_index(s), s, l))

def m_history_plain(+ops: U32, +arg: U32, lst: T.l1099511627776_Validator_Seq) -> IO(Unit):
  fin_u(T.l1099511627776_Validator_root(O.hasher(), hist_u(U32.to_nat(ops), arg, lst), 0))

# ---- dispatch --------------------------------------------------------------

def on_list(+mode: U32, +arg: U32, +ops: U32, lst: T.l1099511627776_Validator_Seq) -> IO(Unit):
  match mode:
    case 8: m_history_cached(ops, arg, lst)
    case 9: m_history_plain(ops, arg, lst)
    case 0: m_uncached(lst)
    case 1: m_first(lst)
    case 2: m_warm(lst)
    case 3: m_update(arg, lst)
    case 4: m_update_plain(arg, T.l1099511627776_Validator_get(lst, 0))
    case 5: m_append(lst)
    case 6: m_append_plain(T.l1099511627776_Validator_append(lst, T.Validator_default()))
    case _: m_baseline(T.l1099511627776_Validator_force(lst))

def with_list(+mode: U32, +arg: U32, +ops: U32, pr: T.BeaconState & T.l1099511627776_Validator_Seq) -> IO(Unit):
  (st, lst) = pr
  on_list(mode, arg, ops, lst)

def on_state(+mode: U32, +arg: U32, +ops: U32, m: Maybe<&1, T.BeaconState>) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{st}:
      with_list(mode, arg, ops, T.BeaconState_swap_validators(st, T.l1099511627776_Validator_default()))

def decoded(+mode: U32, +arg: U32, +ops: U32, pair: B.Buf & Maybe<&1, T.BeaconState>) -> IO(Unit):
  (buf, m) = pair
  on_state(mode, arg, ops, m)

def with_input(+mode: U32, +arg: U32, +ops: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  decoded(mode, arg, ops, T.BeaconState_decode(buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +arg : U32 <- IOx.env_u32("SSZ_ARG")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    input : B.Buf & U32 <- IOx.load()
    with_input(mode, arg, ops, input)
