import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluPendingDeposit_def_generated.bend as PDd
import ../../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as LPD
import ../../types/Fulu_list_PendingDeposit_134217728_hashtreeroot_generated.bend as LPDH
import ../../types/proglist_uint8_def_generated.bend as P8
import ../../types/proglist_SmallTestStruct_def_generated.bend as PS
import ../../types/proglist_SmallTestStruct_hashtreeroot_generated.bend as PSH
import ../../types/SmallTestStruct_def_generated.bend as STd
import ../../types/progbitlist_def_generated.bend as PbD
import ../../types/Fulu_bitlist_2048_def_generated.bend as B2048
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt round 2, probe J: repeated appends (time), and the cached root against the plain root after mixed
# capp / cset sequences. SSZ_CASE / SSZ_ARG (count) / SSZ_N (check period).

def d_eq(a: D.Digest, b: D.Digest) -> Bool:
  match a:
    case D.D{+a0, +a1, +a2, +a3, +a4, +a5, +a6, +a7}:
      match b:
        case D.D{+b0, +b1, +b2, +b3, +b4, +b5, +b6, +b7}:
          Bool.and(Bool.and(Bool.and(U32.is_eq(a0, b0), U32.is_eq(a1, b1)), Bool.and(U32.is_eq(a2, b2), U32.is_eq(a3, b3))),
                   Bool.and(Bool.and(U32.is_eq(a4, b4), U32.is_eq(a5, b5)), Bool.and(U32.is_eq(a6, b6), U32.is_eq(a7, b7))))

type St is Type:
  St{c: LPD.l134217728_PendingDeposit_Cached, s: LPD.l134217728_PendingDeposit_Seq, n: U32, bad: U32}

def fst_c(pair: LPD.l134217728_PendingDeposit_Cached & Bool) -> LPD.l134217728_PendingDeposit_Cached:
  (c, ok) = pair
  c
def fst_s(pair: LPD.l134217728_PendingDeposit_Seq & Bool) -> LPD.l134217728_PendingDeposit_Seq:
  (s, ok) = pair
  s

def do_set(+i: U32, +n: U32, +bad: U32, c: LPD.l134217728_PendingDeposit_Cached, s: LPD.l134217728_PendingDeposit_Seq) -> St:
  St{fst_c(LPD.l134217728_PendingDeposit_cset(c, U32.mod((i * 7919 : U32), n), PDd.PendingDeposit_seed(i))),
     fst_s(LPD.l134217728_PendingDeposit_set(s, U32.mod((i * 7919 : U32), n), PDd.PendingDeposit_seed(i))), n, bad}

def do_app(+i: U32, +n: U32, +bad: U32, c: LPD.l134217728_PendingDeposit_Cached, s: LPD.l134217728_PendingDeposit_Seq) -> St:
  St{fst_c(LPD.l134217728_PendingDeposit_capp(c, PDd.PendingDeposit_seed(i))),
     fst_s(LPD.l134217728_PendingDeposit_append(s, PDd.PendingDeposit_seed(i))), (n + 1 : U32), bad}

def pick_op(isset: Bool, +i: U32, +n: U32, +bad: U32, c: LPD.l134217728_PendingDeposit_Cached, s: LPD.l134217728_PendingDeposit_Seq) -> St:
  match isset:
    case True{}: do_set(i, n, bad, c, s)
    case False{}: do_app(i, n, bad, c, s)

def op(+i: U32, st: St) -> St:
  match st:
    case St{c, s, +n, +bad}: pick_op(Bool.and(U32.is_eq(U32.mod(i, 3), 2), U32.is_lt(0, n)), i, n, bad, c, s)

def cmp3(+n: U32, +bad: U32, rc: B.Buf & (LPD.l134217728_PendingDeposit_Cached & D.Digest), rs: B.Buf & (LPD.l134217728_PendingDeposit_Seq & D.Digest)) -> St:
  (h1, r1) = rc
  (c, d1) = r1
  (h2, r2) = rs
  (s, d2) = r2
  St{c, s, n, (bad + O.pick(d_eq(d1, d2), 0, 1) : U32)}

def check(st: St) -> St:
  match st:
    case St{c, s, +n, +bad}: cmp3(n, bad, LPD.l134217728_PendingDeposit_cached_root(64n, O.hasher(), c, 0), LPDH.l134217728_PendingDeposit_root(64n, O.hasher(), s, 0))

def maybe_check(due: Bool, st: St) -> St:
  match due:
    case True{}: check(st)
    case False{}: st

def step(+k: Nat, +i: U32, +per: U32, st: St) -> St:
  match k:
    case 0n: check(st)
    case 1n+q: step(q, (i + 1 : U32), per, maybe_check(U32.is_eq(U32.mod(i, per), 0), op(i, st)))

def report(st: St) -> IO(Unit):
  match st:
    case St{c, s, +n, +bad}: IO.print("n=" ++ U32.show(n) ++ " mismatches=" ++ U32.show(bad))

def c1(+k: U32, +per: U32) -> IO(Unit): report(step(U32.to_nat(k), 0, per, St{LPD.l134217728_PendingDeposit_cache(LPD.l134217728_PendingDeposit_default()), LPD.l134217728_PendingDeposit_default(), 0, 0}))

# ---- repeated appends (time only) -------------------------------------------------------------------
def len_w(pair: O.Words & U32) -> IO(Unit):
  (w, +n) = pair
  IO.print("len=" ++ U32.show(n))

def ap8(+k: Nat, +i: U32, w: O.Words) -> O.Words:
  match k:
    case 0n: w
    case 1n+q: ap8(q, (i + 1 : U32), Pair.fst(O.Words, Bool, P8.pl_u8_append(w, (i .&. 255 : U32))))

def c2(+k: U32) -> IO(Unit): len_w(P8.pl_u8_len(ap8(U32.to_nat(k), 0, P8.pl_u8_default())))

def aps(+k: Nat, +i: U32, l: PS.pl_SmallTestStruct_Seq) -> PS.pl_SmallTestStruct_Seq:
  match k:
    case 0n: l
    case 1n+q: aps(q, (i + 1 : U32), Pair.fst(PS.pl_SmallTestStruct_Seq, Bool, PS.pl_SmallTestStruct_append(l, STd.SmallTestStruct_seed(i))))

def rs(pair: B.Buf & (PS.pl_SmallTestStruct_Seq & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (s, d) = r
  IO.print("root=" ++ IOx.words(d))

def c3(+k: U32) -> IO(Unit): rs(PSH.pl_SmallTestStruct_root(64n, O.hasher(), aps(U32.to_nat(k), 0, PS.pl_SmallTestStruct_default()), 0))

def apb(+k: Nat, +i: U32, b: O.Bits) -> O.Bits:
  match k:
    case 0n: b
    case 1n+q: apb(q, (i + 1 : U32), Pair.fst(O.Bits, Bool, PbD.pbits_append(b, U32.is_eq((i .&. 3 : U32), 1))))

def len_b(pair: O.Bits & U32) -> IO(Unit):
  (w, +n) = pair
  IO.print("bits=" ++ U32.show(n))

def c4(+k: U32) -> IO(Unit): len_b(PbD.pbits_len(apb(U32.to_nat(k), 0, O.Bits{Array.new(U32, 0n, 0), 0})))

def dispatch(+c: U32, +a: U32, +n: U32) -> IO(Unit):
  match c:
    case 1: c1(a, n)
    case 2: c2(a)
    case 3: c3(a)
    case _: c4(a)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    +n : U32 <- IOx.env_u32("SSZ_N")
    dispatch(c, a, n)
