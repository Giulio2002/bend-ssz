import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluPendingConsolidation_def_generated.bend as Pc
import ../../types/Fulu_list_PendingConsolidation_262144_def_generated.bend as Lc
import ../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 3, probe R: repeated (cset, cached_root) cycles on a cached list of SSZ_N elements, SSZ_K cycles: the cost per cycle must not grow with n.

def nx(+x: U32) -> U32: (x * 1664525 + 1013904223 : U32)

def elem(+x: U32) -> Pc.PendingConsolidation: Pc.PendingConsolidation_set_source_index(Pc.PendingConsolidation_default(), O.U64{x, nx(x)})

def ap2(pair: Lc.l262144_PendingConsolidation_Cached & Bool) -> Lc.l262144_PendingConsolidation_Cached:
  (c, ok) = pair
  c
def bl(+k: Nat, +x: U32, c: Lc.l262144_PendingConsolidation_Cached) -> Lc.l262144_PendingConsolidation_Cached:
  match k:
    case 0n: c
    case 1n+q: bl(q, nx(x), ap2(Lc.l262144_PendingConsolidation_capp(c, elem(x))))

def st3(pair: B.Buf & (Lc.l262144_PendingConsolidation_Cached & D.Digest)) -> Lc.l262144_PendingConsolidation_Cached:
  (h, r) = pair
  (c, d) = r
  c
def st2(pair: Lc.l262144_PendingConsolidation_Cached & Bool) -> Lc.l262144_PendingConsolidation_Cached:
  (c, ok) = pair
  st3(Lc.l262144_PendingConsolidation_cached_root(64n, O.hasher(), c, 0))
def step(+x: U32, +n: U32, c: Lc.l262144_PendingConsolidation_Cached) -> Lc.l262144_PendingConsolidation_Cached: st2(Lc.l262144_PendingConsolidation_cset(c, U32.mod(U32.shrn(x, 4n), n), elem(x)))
def rl(+k: Nat, +x: U32, +n: U32, c: Lc.l262144_PendingConsolidation_Cached) -> Lc.l262144_PendingConsolidation_Cached:
  match k:
    case 0n: c
    case 1n+q: rl(q, nx(x), n, step(x, n, c))

def fin(pair: B.Buf & (Lc.l262144_PendingConsolidation_Cached & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (c, d) = r
  IO.print("root=" ++ IOx.words(d))

def go(+n: U32, +k: U32) -> IO(Unit): fin(Lc.l262144_PendingConsolidation_cached_root(64n, O.hasher(), rl(U32.to_nat(k), 5, n, bl(U32.to_nat(n), 1, Lc.l262144_PendingConsolidation_cache(Lc.l262144_PendingConsolidation_default()))), 0))

def main() -> IO(Unit):
  do IO<Unit>:
    +n : U32 <- IOx.env_u32("SSZ_N")
    +k : U32 <- IOx.env_u32("SSZ_K")
    go(n, k)
