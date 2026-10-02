import Base
import ../../src/primitives.bend as I
import ../../spec/primitives.bend as SP
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../codec_inverse.bend as CI
import ./spec_fixed.bend as FX
import ./words_spec.bend as WS
import ./mtree_run.bend as MR

# The bytes of a chunk past the length of byte storage are zero (the invariant of words_obj.bend: WS.bdrop(r, WS.cb(slots, q)) is zero_bytes)
# means the words that hold only such bytes are zero. The runtime root checks that (O.wcn, docs/CRASH_HUNT.md R2-02) before it reads the
# whole chunk of the storage; these lemmas show that the check passes for every object the proofs represent.

def hd0(+xs: +List<U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, t}: h

def tl0(+xs: +List<U32>) -> +List<U32>:
  match xs:
    case Nil{}: []
    case Con{h, t}: t

def pr(+m: Nat) -> Nat:
  match m:
    case 0n: 0n
    case 1n+p: p

def hd_zero(+m: Nat) -> {hd0(SP.zero_bytes(m)) == 0 : U32}:
  match m:
    case 0n: {==}
    case 1n+p: {==}

def tl_zero(+m: Nat) -> {tl0(SP.zero_bytes(m)) == SP.zero_bytes(pr(m)) : +List<U32>}:
  match m:
    case 0n: {==}
    case 1n+p: {==}

# The first byte and the others of a list of zero bytes.
def pz_hd(+xs: +List<U32>, +m: Nat, +h: {xs == SP.zero_bytes(m) : +List<U32>}) -> {hd0(xs) == 0 : U32}:
  Equal.trans(U32, hd0(xs), hd0(SP.zero_bytes(m)), 0, Equal.cong(+List<U32>, U32, x => hd0(x), xs, SP.zero_bytes(m), h), hd_zero(m))

def pz_tl(+xs: +List<U32>, +m: Nat, +h: {xs == SP.zero_bytes(m) : +List<U32>}) -> {tl0(xs) == SP.zero_bytes(pr(m)) : +List<U32>}:
  Equal.trans(+List<U32>, tl0(xs), tl0(SP.zero_bytes(m)), SP.zero_bytes(pr(m)), Equal.cong(+List<U32>, +List<U32>, x => tl0(x), xs, SP.zero_bytes(m), h), tl_zero(m))

def limb_list(+h: U32, +e0: {U32.and(h, 255) == 0 : U32}, +e1: {U32.and(U32.shrn(h, 8n), 255) == 0 : U32},
    +e2: {U32.and(U32.shrn(h, 16n), 255) == 0 : U32}, +e3: {U32.shrn(h, 24n) == 0 : U32}) -> {I.limb(h) == [0, 0, 0, 0] : +List<U32>}:
  %Equal.sym(U32, U32.and(h, 255), 0, e0) : {[_, U32.and(U32.shrn(h, 8n), 255), U32.and(U32.shrn(h, 16n), 255), U32.shrn(h, 24n)] == [0, 0, 0, 0] : +List<U32>}
  %Equal.sym(U32, U32.and(U32.shrn(h, 8n), 255), 0, e1) : {[0, _, U32.and(U32.shrn(h, 16n), 255), U32.shrn(h, 24n)] == [0, 0, 0, 0] : +List<U32>}
  %Equal.sym(U32, U32.and(U32.shrn(h, 16n), 255), 0, e2) : {[0, 0, _, U32.shrn(h, 24n)] == [0, 0, 0, 0] : +List<U32>}
  %Equal.sym(U32, U32.shrn(h, 24n), 0, e3) : {[0, 0, 0, _] == [0, 0, 0, 0] : +List<U32>}
  {==}

# A word whose four bytes are zero is zero.
def limb_zero(+h: U32, +e0: {U32.and(h, 255) == 0 : U32}, +e1: {U32.and(U32.shrn(h, 8n), 255) == 0 : U32},
    +e2: {U32.and(U32.shrn(h, 16n), 255) == 0 : U32}, +e3: {U32.shrn(h, 24n) == 0 : U32}) -> {h == 0 : U32}:
  Equal.sym(U32, I.read_limb([0, 0, 0, 0], 0n), h, F.logic__subst(+List<U32>, z => {I.read_limb(z, 0n) == h : U32}, I.limb(h), [0, 0, 0, 0], limb_list(h, e0, e1, e2, e3), CI.limb_inverse(h)))

def le0(+x: Nat) -> {Nat.is_le(0n, x) == True{} : Bool}:
  match x:
    case 0n: {==}
    case 1n+p: {==}

# Z. If the bytes of FX.limbs(W) from byte r on are zero, the words from word ceil(r / 4) on are zero: for every word index k with r <= 4k.
# By recursion on the word list; a word whose four bytes are in the zero part is zero (limb_zero).
def zw(+W: List<&2, U32>, +r: Nat, +m: Nat, +k: Nat, +hbd: {WS.bdrop(r, FX.limbs(W)) == SP.zero_bytes(m) : +List<U32>},
    +hk: {Nat.is_le(r, A.quad(k)) == True{} : Bool}) -> {MR.wd(W, k) == 0 : U32}:
  match W r k:
    case Nil{} _ _: {==}
    case Con{h, t} 0n 0n:
      limb_zero(h, pz_hd(FX.limbs(Con{h, t}), m, hbd), pz_hd(tl0(FX.limbs(Con{h, t})), pr(m), pz_tl(FX.limbs(Con{h, t}), m, hbd)),
        pz_hd(tl0(tl0(FX.limbs(Con{h, t}))), pr(pr(m)), pz_tl(tl0(FX.limbs(Con{h, t})), pr(m), pz_tl(FX.limbs(Con{h, t}), m, hbd))),
        pz_hd(tl0(tl0(tl0(FX.limbs(Con{h, t})))), pr(pr(pr(m))), pz_tl(tl0(tl0(FX.limbs(Con{h, t}))), pr(pr(m)), pz_tl(tl0(FX.limbs(Con{h, t})), pr(m), pz_tl(FX.limbs(Con{h, t}), m, hbd)))))
    case Con{h, t} 0n 1n+k1:
      zw(t, 0n, pr(pr(pr(pr(m)))), k1,
        pz_tl(tl0(tl0(tl0(FX.limbs(Con{h, t})))), pr(pr(pr(m))), pz_tl(tl0(tl0(FX.limbs(Con{h, t}))), pr(pr(m)), pz_tl(tl0(FX.limbs(Con{h, t})), pr(m), pz_tl(FX.limbs(Con{h, t}), m, hbd)))),
        le0(A.quad(k1)))
    case Con{h, t} 1n+0n 0n: Empty.absurd({MR.wd(Con{h, t}, 0n) == 0 : U32}, F.logic__false_true(hk))
    case Con{h, t} 1n+0n 1n+k1:
      zw(t, 0n, pr(pr(pr(m))), k1,
        pz_tl(tl0(tl0(WS.bdrop(1n, FX.limbs(Con{h, t})))), pr(pr(m)), pz_tl(tl0(WS.bdrop(1n, FX.limbs(Con{h, t}))), pr(m), pz_tl(WS.bdrop(1n, FX.limbs(Con{h, t})), m, hbd))),
        le0(A.quad(k1)))
    case Con{h, t} 1n+1n+0n 0n: Empty.absurd({MR.wd(Con{h, t}, 0n) == 0 : U32}, F.logic__false_true(hk))
    case Con{h, t} 1n+1n+0n 1n+k1:
      zw(t, 0n, pr(pr(m)), k1,
        pz_tl(tl0(WS.bdrop(2n, FX.limbs(Con{h, t}))), pr(m), pz_tl(WS.bdrop(2n, FX.limbs(Con{h, t})), m, hbd)),
        le0(A.quad(k1)))
    case Con{h, t} 1n+1n+1n+0n 0n: Empty.absurd({MR.wd(Con{h, t}, 0n) == 0 : U32}, F.logic__false_true(hk))
    case Con{h, t} 1n+1n+1n+0n 1n+k1:
      zw(t, 0n, pr(m), k1, pz_tl(WS.bdrop(3n, FX.limbs(Con{h, t})), m, hbd), le0(A.quad(k1)))
    case Con{h, t} 1n+1n+1n+1n+r4 0n: Empty.absurd({MR.wd(Con{h, t}, 0n) == 0 : U32}, F.logic__false_true(hk))
    case Con{h, t} 1n+1n+1n+1n+r4 1n+k1: zw(t, r4, m, k1, hbd, hk)
