import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluWithdrawal_def_generated.bend as V
import ../../types/Fulu_list_Withdrawal_16_def_generated.bend as W
import ../../types/Fulu_list_Withdrawal_16_hashtreeroot_generated.bend as WH
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt probe D: the cached-root API of a list of objects at its boundaries, against the plain root.
# SSZ_CASE 1: root of a list of SSZ_ARG elements, plain and through a fresh cache.
# SSZ_CASE 2: cache a list of SSZ_ARG elements, capp elements up to SSZ_ARG2 (17 tries the limit 16), root; the plain root of
#             the list that was built to the same length is printed too.
# SSZ_CASE 3: cget / cset at index 2^32 - 1 and at the length.

def app_fst(pair: W.l16_Withdrawal_Seq & Bool) -> W.l16_Withdrawal_Seq:
  (o, ok) = pair
  o

def elem(+i: U32) -> V.Withdrawal: V.Withdrawal_set_index(V.Withdrawal_default(), O.U64{i, 0})

def build(k: Nat, +i: U32, o: W.l16_Withdrawal_Seq) -> W.l16_Withdrawal_Seq:
  match k:
    case 0n: o
    case 1n+q: build(q, (i + 1 : U32), app_fst(W.l16_Withdrawal_append(o, elem(i))))

def uline(label: String, pair: B.Buf & (W.l16_Withdrawal_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (o, d) = r
  IO.print(label ++ "=" ++ IOx.words(d))

def cline(label: String, pair: B.Buf & (W.l16_Withdrawal_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  IO.print(label ++ "=" ++ IOx.words(d))

def case1(+n: U32) -> IO(Unit):
  do IO<Unit>:
    uline("plain", WH.l16_Withdrawal_root(64n, O.hasher(), build(U32.to_nat(n), 0, W.l16_Withdrawal_default()), 0))
    cline("cached", W.l16_Withdrawal_cached_root(64n, O.hasher(), W.l16_Withdrawal_cache(build(U32.to_nat(n), 0, W.l16_Withdrawal_default())), 0))

def capp_fst(pair: W.l16_Withdrawal_Cached & Bool) -> W.l16_Withdrawal_Cached:
  (c, ok) = pair
  c

def cbuild(k: Nat, +i: U32, c: W.l16_Withdrawal_Cached) -> W.l16_Withdrawal_Cached:
  match k:
    case 0n: c
    case 1n+q: cbuild(q, (i + 1 : U32), capp_fst(W.l16_Withdrawal_capp(c, elem(i))))

def case2(+n: U32, +m: U32) -> IO(Unit):
  do IO<Unit>:
    cline("cached_grown", W.l16_Withdrawal_cached_root(64n, O.hasher(), cbuild(U32.to_nat((m - n : U32)), n, W.l16_Withdrawal_cache(build(U32.to_nat(n), 0, W.l16_Withdrawal_default()))), 0))
    uline("plain_same_len", WH.l16_Withdrawal_root(64n, O.hasher(), build(U32.to_nat(O.pick(U32.is_le(m, 16), m, 16)), 0, W.l16_Withdrawal_default()), 0))

def get_line(pair: W.l16_Withdrawal_Cached & Maybe<&1, V.Withdrawal>) -> IO(Unit):
  (c, m) = pair
  match m:
    case Some{v}: IO.print("cget=some")
    case None{}: IO.print("cget=none")

def set_line(pair: W.l16_Withdrawal_Cached & Bool) -> IO(Unit):
  (c, ok) = pair
  IO.print("cset_ok=" ++ O.pick_str(ok))

def case3(+n: U32) -> IO(Unit):
  do IO<Unit>:
    get_line(W.l16_Withdrawal_cget(W.l16_Withdrawal_cache(build(3n, 0, W.l16_Withdrawal_default())), n))
    set_line(W.l16_Withdrawal_cset(W.l16_Withdrawal_cache(build(3n, 0, W.l16_Withdrawal_default())), n, elem(9)))

def dispatch(+c: U32, +a: U32, +b: U32) -> IO(Unit):
  match c:
    case 1: case1(a)
    case 2: case2(a, b)
    case _: case3(a)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    +b : U32 <- IOx.env_u32("SSZ_ARG2")
    dispatch(c, a, b)
