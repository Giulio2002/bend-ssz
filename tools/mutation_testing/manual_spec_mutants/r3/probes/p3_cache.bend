import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/FuluProposerSlashing_def_generated.bend as PD
import ../../../../../types/FuluSignedBeaconBlockHeader_def_generated.bend as SH
import ../../../../../types/Fulu_list_ProposerSlashing_16_def_generated.bend as LP
import ../../../../../types/Fulu_list_ProposerSlashing_16_hashtreeroot_generated.bend as LH
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-3 probe: the cached tree of List[ProposerSlashing, 16] through the public X_cache, X_cached_root, X_cset, X_capp, X_cget.
# SSZ_CASE: 1..6 cached root of build(k) for k = 0, 1, 3, 5, 9, 16 (elements with distinct seeds); 7 plain root of build(9) (reference);
# 8 cache(build(3)), 6 cached appends, cached root; 9 cache(build(5)), root, cset(2, new), root; 10 cget(5) of build(5); 11 cget(4) of build(5);
# 12 capp at 16; 13 cset(i = n); 14 cache(build(5)), root, cset(0), cset(4), root; 15 cache(build(0)), capp x9, root.

def pr(label: String, d: D.Digest) -> IO(Unit):
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}:
      IO.print(label ++ " root=" ++ U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d1) ++ "," ++ U32.show(e) ++ "," ++ U32.show(f) ++ "," ++ U32.show(g) ++ "," ++ U32.show(h))

def el(+x: U32) -> PD.ProposerSlashing:
  PD.ProposerSlashing_set_signed_header_1(PD.ProposerSlashing_default(), SH.SignedBeaconBlockHeader_bx_wrap(SH.SignedBeaconBlockHeader_seed(x)))

def build(+k: Nat, +i: U32, o: LP.l16_ProposerSlashing_Seq) -> LP.l16_ProposerSlashing_Seq:
  match k:
    case 0n: o
    case 1n+q: build(q, (i + 1 : U32), Pair.fst(LP.l16_ProposerSlashing_Seq, Bool, LP.l16_ProposerSlashing_append(o, el((i + 1 : U32)))))

def cr_fin(label: String, pair: B.Buf & (LP.l16_ProposerSlashing_Cached & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (c, d) = r
  pr(label, d)

def cr(label: String, c: LP.l16_ProposerSlashing_Cached) -> IO(Unit): cr_fin(label, LP.l16_ProposerSlashing_cached_root(64n, O.hasher(), c, 0))

def cached_root_of(c: LP.l16_ProposerSlashing_Cached) -> LP.l16_ProposerSlashing_Cached:
  Pair.fst(LP.l16_ProposerSlashing_Cached, D.Digest, Pair.snd(B.Buf, LP.l16_ProposerSlashing_Cached & D.Digest, LP.l16_ProposerSlashing_cached_root(64n, O.hasher(), c, 0)))

def cset_c(c: LP.l16_ProposerSlashing_Cached, +i: U32, +x: U32) -> LP.l16_ProposerSlashing_Cached:
  Pair.fst(LP.l16_ProposerSlashing_Cached, Bool, LP.l16_ProposerSlashing_cset(c, i, el(x)))

def capp_c(c: LP.l16_ProposerSlashing_Cached, +x: U32) -> LP.l16_ProposerSlashing_Cached:
  Pair.fst(LP.l16_ProposerSlashing_Cached, Bool, LP.l16_ProposerSlashing_capp(c, el(x)))

def capp_n(+k: Nat, +x: U32, c: LP.l16_ProposerSlashing_Cached) -> LP.l16_ProposerSlashing_Cached:
  match k:
    case 0n: c
    case 1n+q: capp_n(q, (x + 1 : U32), capp_c(c, x))

def rk(label: String, +k: Nat) -> IO(Unit): cr(label, LP.l16_ProposerSlashing_cache(build(k, 0, LP.l16_ProposerSlashing_default())))

def plain(pair: B.Buf & (LP.l16_ProposerSlashing_Seq & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  pr("plain9", d)

def flag_c(label: String, pair: LP.l16_ProposerSlashing_Cached & Bool) -> IO(Unit):
  (c, ok) = pair
  IO.print(label ++ " ok=" ++ O.pick_str(ok))

def get_c(label: String, pair: LP.l16_ProposerSlashing_Cached & Maybe<&1, PD.ProposerSlashing>) -> IO(Unit):
  (c, m) = pair
  match m:
    case Some{v}: IO.print(label ++ "=some")
    case None{}: IO.print(label ++ "=none")

def cb(+k: Nat) -> LP.l16_ProposerSlashing_Cached: LP.l16_ProposerSlashing_cache(build(k, 0, LP.l16_ProposerSlashing_default()))

def c1() -> IO(Unit): rk("k0", 0n)
def c2() -> IO(Unit): rk("k1", 1n)
def c3() -> IO(Unit): rk("k3", 3n)
def c4() -> IO(Unit): rk("k5", 5n)
def c5() -> IO(Unit): rk("k9", 9n)
def c6() -> IO(Unit): rk("k16", 16n)
def c7() -> IO(Unit): plain(LH.l16_ProposerSlashing_root(64n, O.hasher(), build(9n, 0, LP.l16_ProposerSlashing_default()), 0))
def c8() -> IO(Unit): cr("k3_capp6", capp_n(6n, 50, cb(3n)))
def c9() -> IO(Unit): cr("k5_cset2", cset_c(cached_root_of(cb(5n)), 2, 99))
def c10() -> IO(Unit): get_c("cget5_of5", LP.l16_ProposerSlashing_cget(cb(5n), 5))
def c11() -> IO(Unit): get_c("cget4_of5", LP.l16_ProposerSlashing_cget(cb(5n), 4))
def c12() -> IO(Unit): flag_c("capp_at_16", LP.l16_ProposerSlashing_capp(cb(16n), el(77)))
def c13() -> IO(Unit): flag_c("cset_at_n", LP.l16_ProposerSlashing_cset(cb(5n), 5, el(77)))
def c14() -> IO(Unit): cr("k5_cset04", cset_c(cset_c(cached_root_of(cb(5n)), 0, 61), 4, 62))
def c16() -> IO(Unit): flag_c("capp_at_15", LP.l16_ProposerSlashing_capp(cb(15n), el(77)))
def c15() -> IO(Unit): cr("k0_capp9", capp_n(9n, 30, cb(0n)))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: c1()
    case 2: c2()
    case 3: c3()
    case 4: c4()
    case 5: c5()
    case 6: c6()
    case 7: c7()
    case 8: c8()
    case 9: c9()
    case 10: c10()
    case 11: c11()
    case 12: c12()
    case 13: c13()
    case 14: c14()
    case 15: c15()
    case _: c16()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
