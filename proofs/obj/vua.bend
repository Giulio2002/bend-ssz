import Base
import ../../src/buffer.bend as B
import ../../src/primitives.bend as I
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vfix.bend as VF
import ./vnest.bend as VN
import ./vbrt.bend as VR
import ./vua_bits.bend as UB

# The unaligned-offset layer, U1: the runtime's four-byte read B.read32 at ANY
# byte offset X of a buffer returns the word RW(t, X), whose limbs are the
# buffer's spec bytes [X, X + 4) (rd_any, rd_bytes). At X = 4 q it is word q;
# otherwise the join of words q and q + 1 at byte X mod 4.

def BF(t: F.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{F.array__thaw(U32, t), n}
def SL(t: F.array__Tree<U32>) -> List<&2, U32>: F.array__slots(U32, t)

# The spec bytes of the buffer's words.
def BYT(+t: F.array__Tree<U32>) -> +List<U32>: FX.limbs(SL(t))

def jn(r: Nat, +lo: U32, +hi: U32) -> U32:
  match r:
    case 0n: lo
    case 1n: B.join_sel(1, lo, hi)
    case 2n: B.join_sel(2, lo, hi)
    case 3n+s: B.join_sel(3, lo, hi)

def RW(+t: F.array__Tree<U32>, +X: U32) -> U32: jn(VR.RX(X), VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))

def rx_lt(+X: U32) -> {Nat.is_lt(VR.RX(X), 4n) == True{} : Bool}:
  F.nat__le_lt_trans(VR.RX(X), 3n, 4n, RD.and_le(X, 3), {==})

# 4 q + r + 4 <= 4 P with r > 0 gives q + 1 < P.
def q1_lt(+q: Nat, +r: Nat, +P: Nat, +hr: {Nat.is_lt(0n, r) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), 4n), A.quad(P)) == True{} : Bool}) -> {Nat.is_lt(1n+q, P) == True{} : Bool}:
  +h1 = F.nat__le_trans(Nat.add(A.quad(q), 5n), Nat.add(Nat.add(A.quad(q), r), 4n), A.quad(P),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), 5n), z) == True{} : Bool}, Nat.add(A.quad(q), Nat.add(r, 4n)), Nat.add(Nat.add(A.quad(q), r), 4n),
      Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), r), 4n), Nat.add(A.quad(q), Nat.add(r, 4n)), F.nat__add_assoc(A.quad(q), r, 4n)),
      Order.add_left(A.quad(q), 5n, Nat.add(r, 4n), F.logic__subst(Nat, z => {Nat.is_le(5n, z) == True{} : Bool}, Nat.add(4n, r), Nat.add(r, 4n), F.nat__add_comm(4n, r), F.nat__lt_succ_le_succ(0n, r, hr)))),
    h)
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(P)) == True{} : Bool}, Nat.add(A.quad(q), 5n), 1n+A.quad(1n+q),
    Equal.trans(Nat, Nat.add(A.quad(q), 5n), Nat.add(5n, A.quad(q)), 1n+A.quad(1n+q), F.nat__add_comm(A.quad(q), 5n), {==}), h1)
  VR.lt_quad(1n+q, P, F.nat__succ_le_lt(A.quad(1n+q), A.quad(P), h2))

def q0_lt(+q: Nat, +r: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), 4n), A.quad(P)) == True{} : Bool}) -> {Nat.is_lt(q, P) == True{} : Bool}:
  +h1 = F.nat__le_trans(A.quad(1n+q), Nat.add(Nat.add(A.quad(q), r), 4n), A.quad(P),
    F.logic__subst(Nat, z => {Nat.is_le(A.quad(1n+q), z) == True{} : Bool}, Nat.add(4n, Nat.add(A.quad(q), r)), Nat.add(Nat.add(A.quad(q), r), 4n), F.nat__add_comm(4n, Nat.add(A.quad(q), r)),
      Order.add_left(4n, A.quad(q), Nat.add(A.quad(q), r), F.nat__le_add_right(A.quad(q), r))), h)
  VR.lt_quad(q, P, F.nat__lt_le_trans(A.quad(q), A.quad(1n+q), A.quad(P), VB.lt_kk(0n, 4n, A.quad(q), {==}), h1))

# ---- the runtime read ------------------------------------------------------------------------

def rd_r(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +X: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(Nat.add(A.quad(VR.QX(X)), VR.RX(X)), 4n), A.quad(VB.pw(d))) == True{} : Bool},
    +r: Nat, +er: {VR.RX(X) == r : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool})
    -> {B.read32(BF(t, n), X) == (BF(t, n), jn(r, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}:
  match r:
    case 0n:
      +e3 = F.u32__injective(U32.and(X, 3), 0, er)
      %Equal.sym(U32, U32.and(X, 3), 0, e3) : {B.read32_choose(X, _, U32.is_eq(_, 0), BF(t, n)) == (BF(t, n), VB.slot(t, VR.QX(X))) : B.Buf & U32}
      VR.rdw(d, t, n, U32.shrn(X, 2n), VR.QX(X), {==}, VB.lt32(d, hd), q0_lt(VR.QX(X), VR.RX(X), VB.pw(d), h), pf)
    case 1n:
      +e3 = F.u32__injective(U32.and(X, 3), 1, er)
      +hq1 = q1_lt(VR.QX(X), VR.RX(X), VB.pw(d), F.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 1n, VR.RX(X), Equal.sym(Nat, VR.RX(X), 1n, er), {==}), h)
      %Equal.sym(U32, U32.and(X, 3), 1, e3) : {B.read32_choose(X, _, U32.is_eq(_, 0), BF(t, n)) == (BF(t, n), B.join_sel(1, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), U32.shrn(X, 2n)), (BF(t, n), VB.slot(t, VR.QX(X))), VR.rdw(d, t, n, U32.shrn(X, 2n), VR.QX(X), {==}, VB.lt32(d, hd), q0_lt(VR.QX(X), VR.RX(X), VB.pw(d), h), pf)) :
        {B.read32_split(X, 1, _) == (BF(t, n), B.join_sel(1, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), U32.add(U32.shrn(X, 2n), 1)), (BF(t, n), VB.slot(t, 1n+VR.QX(X))),
          VR.rdw(d, t, n, U32.add(U32.shrn(X, 2n), 1), 1n+VR.QX(X), VB.add_le_at(U32.shrn(X, 2n), 1, VR.QX(X), d, {==}, hd, F.nat__lt_le(1n+VR.QX(X), VB.pw(d), hq1)), VB.lt32(d, hd), hq1, pf)) :
        {B.join_words(1, VB.slot(t, VR.QX(X)), _) == (BF(t, n), B.join_sel(1, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      {==}
    case 2n:
      +e3 = F.u32__injective(U32.and(X, 3), 2, er)
      +hq1 = q1_lt(VR.QX(X), VR.RX(X), VB.pw(d), F.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 2n, VR.RX(X), Equal.sym(Nat, VR.RX(X), 2n, er), {==}), h)
      %Equal.sym(U32, U32.and(X, 3), 2, e3) : {B.read32_choose(X, _, U32.is_eq(_, 0), BF(t, n)) == (BF(t, n), B.join_sel(2, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), U32.shrn(X, 2n)), (BF(t, n), VB.slot(t, VR.QX(X))), VR.rdw(d, t, n, U32.shrn(X, 2n), VR.QX(X), {==}, VB.lt32(d, hd), q0_lt(VR.QX(X), VR.RX(X), VB.pw(d), h), pf)) :
        {B.read32_split(X, 2, _) == (BF(t, n), B.join_sel(2, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), U32.add(U32.shrn(X, 2n), 1)), (BF(t, n), VB.slot(t, 1n+VR.QX(X))),
          VR.rdw(d, t, n, U32.add(U32.shrn(X, 2n), 1), 1n+VR.QX(X), VB.add_le_at(U32.shrn(X, 2n), 1, VR.QX(X), d, {==}, hd, F.nat__lt_le(1n+VR.QX(X), VB.pw(d), hq1)), VB.lt32(d, hd), hq1, pf)) :
        {B.join_words(2, VB.slot(t, VR.QX(X)), _) == (BF(t, n), B.join_sel(2, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      {==}
    case 3n:
      +e3 = F.u32__injective(U32.and(X, 3), 3, er)
      +hq1 = q1_lt(VR.QX(X), VR.RX(X), VB.pw(d), F.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 3n, VR.RX(X), Equal.sym(Nat, VR.RX(X), 3n, er), {==}), h)
      %Equal.sym(U32, U32.and(X, 3), 3, e3) : {B.read32_choose(X, _, U32.is_eq(_, 0), BF(t, n)) == (BF(t, n), B.join_sel(3, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), U32.shrn(X, 2n)), (BF(t, n), VB.slot(t, VR.QX(X))), VR.rdw(d, t, n, U32.shrn(X, 2n), VR.QX(X), {==}, VB.lt32(d, hd), q0_lt(VR.QX(X), VR.RX(X), VB.pw(d), h), pf)) :
        {B.read32_split(X, 3, _) == (BF(t, n), B.join_sel(3, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), U32.add(U32.shrn(X, 2n), 1)), (BF(t, n), VB.slot(t, 1n+VR.QX(X))),
          VR.rdw(d, t, n, U32.add(U32.shrn(X, 2n), 1), 1n+VR.QX(X), VB.add_le_at(U32.shrn(X, 2n), 1, VR.QX(X), d, {==}, hd, F.nat__lt_le(1n+VR.QX(X), VB.pw(d), hq1)), VB.lt32(d, hd), hq1, pf)) :
        {B.join_words(3, VB.slot(t, VR.QX(X)), _) == (BF(t, n), B.join_sel(3, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}
      {==}
    case 4n+s: Empty.absurd({B.read32(BF(t, n), X) == (BF(t, n), jn(4n+s, VB.slot(t, VR.QX(X)), VB.slot(t, 1n+VR.QX(X)))) : B.Buf & U32}, F.nat__lt_zero_absurd(s, hr))

def xbound(+X: U32, +P: Nat, +h: {Nat.is_le(Nat.add(U32.to_nat(X), 4n), A.quad(P)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(A.quad(VR.QX(X)), VR.RX(X)), 4n), A.quad(P)) == True{} : Bool}:
  %VC.split4(X) : {Nat.is_le(Nat.add(_, 4n), A.quad(P)) == True{} : Bool}
  h

# U1: the four-byte read at any offset X with X + 4 <= 4 2^d.
law rd_any:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +X: U32
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(U32.to_nat(X), 4n), A.quad(VB.pw(d))) == True{} : Bool}
  {B.read32(BF(t, n), X) == (BF(t, n), RW(t, X)) : B.Buf & U32}
def rd_any(d, t, n, X, hd, pf, h):
  rd_r(d, t, n, X, hd, pf, xbound(X, VB.pw(d), h), VR.RX(X), {==}, rx_lt(X))

# ---- the bytes of the read word ------------------------------------------------------------------

def wtwo(+q: Nat, +W: List<&2, U32>, +h: {Nat.is_lt(1n+q, VB.len(W)) == True{} : Bool})
    -> {VB.wdr(q, W) == Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}} : List<&2, U32>}:
  +h0 = F.nat__lt_trans(q, 1n+q, VB.len(W), F.nat__lt_succ(q), h)
  %Equal.sym(List<&2, U32>, VB.wdr(q, W), Con{F.flat__nthc(W, q), VB.wdr(1n+q, W)}, VB.wdr_eta(q, W, h0)) : {_ == Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(1n+q, W), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}, VB.wdr_eta(1n+q, W, h)) : {Con{F.flat__nthc(W, q), _} == Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}} : List<&2, U32>}
  {==}

# Bytes [4 q + r, 4 q + r + 4) of the limbs of W, for the words q and q + 1 lying in W.
def byt(+W: List<&2, U32>, +q: Nat, +r: Nat) -> +List<U32>: VS.bt(4n, VS.bdr(Nat.add(A.quad(q), r), FX.limbs(W)))

def byt_split(+W: List<&2, U32>, +q: Nat, +r: Nat) -> {byt(W, q, r) == VS.bt(4n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(A.quad(q), r), FX.limbs(W)), VS.bdr(r, VS.bdr(A.quad(q), FX.limbs(W))), VN.bdr_add(A.quad(q), r, FX.limbs(W))) : {VS.bt(4n, _) == VS.bt(4n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(q), FX.limbs(W)), FX.limbs(VS.wdr0(q, W)), VS.bdr_limbs(q, W)) : {VS.bt(4n, VS.bdr(r, _)) == VS.bt(4n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(q, W), VB.wdr(q, W), VN.wdr0_eq(q, W)) : {VS.bt(4n, VS.bdr(r, FX.limbs(_))) == VS.bt(4n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}
  {==}

def bytes_r2(+W: List<&2, U32>, +q: Nat, +r: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +h0: {Nat.is_lt(q, VB.len(W)) == True{} : Bool}, h1: {Nat.is_lt(0n, r) == True{} : Bool} -> {Nat.is_lt(1n+q, VB.len(W)) == True{} : Bool})
    -> {FX.limbs([jn(r, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))]) == VS.bt(4n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(List<&2, U32>, VB.wdr(q, W), Con{F.flat__nthc(W, q), VB.wdr(1n+q, W)}, VB.wdr_eta(q, W, h0)) :
        {FX.limbs([F.flat__nthc(W, q)]) == VS.bt(4n, VS.bdr(0n, FX.limbs(_))) : +List<U32>}
      {==}
    case 1n:
      %Equal.sym(List<&2, U32>, VB.wdr(q, W), Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}}, wtwo(q, W, h1({==}))) :
        {FX.limbs([B.join_sel(1, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))]) == VS.bt(4n, VS.bdr(1n, FX.limbs(_))) : +List<U32>}
      %Equal.sym(List<&2, U32>, I.limb(B.join_sel(1, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))), [I.at(I.limb(F.flat__nthc(W, q)), 1n), I.at(I.limb(F.flat__nthc(W, q)), 2n), I.at(I.limb(F.flat__nthc(W, q)), 3n), I.at(I.limb(F.flat__nthc(W, 1n+q)), 0n)], UB.join1(F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))) : {List.append(&2, U32, _, []) == VS.bt(4n, VS.bdr(1n, FX.limbs(Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}}))) : +List<U32>}
      {==}
    case 2n:
      %Equal.sym(List<&2, U32>, VB.wdr(q, W), Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}}, wtwo(q, W, h1({==}))) :
        {FX.limbs([B.join_sel(2, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))]) == VS.bt(4n, VS.bdr(2n, FX.limbs(_))) : +List<U32>}
      %Equal.sym(List<&2, U32>, I.limb(B.join_sel(2, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))), [I.at(I.limb(F.flat__nthc(W, q)), 2n), I.at(I.limb(F.flat__nthc(W, q)), 3n), I.at(I.limb(F.flat__nthc(W, 1n+q)), 0n), I.at(I.limb(F.flat__nthc(W, 1n+q)), 1n)], UB.join2(F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))) : {List.append(&2, U32, _, []) == VS.bt(4n, VS.bdr(2n, FX.limbs(Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}}))) : +List<U32>}
      {==}
    case 3n:
      %Equal.sym(List<&2, U32>, VB.wdr(q, W), Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}}, wtwo(q, W, h1({==}))) :
        {FX.limbs([B.join_sel(3, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))]) == VS.bt(4n, VS.bdr(3n, FX.limbs(_))) : +List<U32>}
      %Equal.sym(List<&2, U32>, I.limb(B.join_sel(3, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))), [I.at(I.limb(F.flat__nthc(W, q)), 3n), I.at(I.limb(F.flat__nthc(W, 1n+q)), 0n), I.at(I.limb(F.flat__nthc(W, 1n+q)), 1n), I.at(I.limb(F.flat__nthc(W, 1n+q)), 2n)], UB.join3(F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))) : {List.append(&2, U32, _, []) == VS.bt(4n, VS.bdr(3n, FX.limbs(Con{F.flat__nthc(W, q), Con{F.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}}))) : +List<U32>}
      {==}
    case 4n+s: Empty.absurd({FX.limbs([jn(4n+s, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))]) == VS.bt(4n, VS.bdr(4n+s, FX.limbs(VB.wdr(q, W)))) : +List<U32>}, F.nat__lt_zero_absurd(s, hr))

def bytes_r(+W: List<&2, U32>, +q: Nat, +r: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +h0: {Nat.is_lt(q, VB.len(W)) == True{} : Bool}, h1: {Nat.is_lt(0n, r) == True{} : Bool} -> {Nat.is_lt(1n+q, VB.len(W)) == True{} : Bool})
    -> {FX.limbs([jn(r, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))]) == byt(W, q, r) : +List<U32>}:
  %Equal.sym(+List<U32>, byt(W, q, r), VS.bt(4n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))), byt_split(W, q, r)) : {FX.limbs([jn(r, F.flat__nthc(W, q), F.flat__nthc(W, 1n+q))]) == _ : +List<U32>}
  bytes_r2(W, q, r, hr, h0, h1)

# U1, bytes: the limbs of the word read at X are the buffer's spec bytes [X, X + 4).
law rd_bytes:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +X: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(U32.to_nat(X), 4n), A.quad(VB.pw(d))) == True{} : Bool}
  {FX.limbs([RW(t, X)]) == VS.bt(4n, VS.bdr(U32.to_nat(X), BYT(t))) : +List<U32>}
def rd_bytes(d, t, X, pf, h):
  +hx = xbound(X, VB.pw(d), h)
  +eL = Equal.sym(Nat, VB.len(SL(t)), VB.pw(d), F.array__slots_length(U32, d, t, pf))
  +h0 = F.logic__subst(Nat, z => {Nat.is_lt(VR.QX(X), z) == True{} : Bool}, VB.pw(d), VB.len(SL(t)), eL, q0_lt(VR.QX(X), VR.RX(X), VB.pw(d), hx))
  %Equal.sym(Nat, U32.to_nat(X), Nat.add(A.quad(VR.QX(X)), VR.RX(X)), VC.split4(X)) : {FX.limbs([RW(t, X)]) == VS.bt(4n, VS.bdr(_, BYT(t))) : +List<U32>}
  bytes_r(SL(t), VR.QX(X), VR.RX(X), rx_lt(X), h0,
    hp => F.logic__subst(Nat, z => {Nat.is_lt(1n+VR.QX(X), z) == True{} : Bool}, VB.pw(d), VB.len(SL(t)), eL, q1_lt(VR.QX(X), VR.RX(X), VB.pw(d), hp, hx)))
