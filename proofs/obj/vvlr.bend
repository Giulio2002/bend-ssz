import Base
import ../../src/buffer.bend as B
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vbrt.bend as VR
import ./vua.bend as UA
import ./vua_copy.bend as UC

# Word reads anywhere in a buffer, the last one included: B.word at index 2^d wraps to
# slot 0 (vua_copy.get_wrap), so B.read32 at any X < 4 2^d returns the buffer and the
# join RN of word X / 4 and the next word (slot 0 past the end). For validators that read
# a four-byte offset before knowing their window holds four bytes (codegen/var_vlist.py).

def WSb(b: Bool, +t: F.array__Tree<U32>, +k: Nat) -> U32:
  match b:
    case True{}: VB.slot(t, k)
    case False{}: VB.slot(t, 0n)

def WS(+d: Nat, +t: F.array__Tree<U32>, +k: Nat) -> U32: WSb(Nat.is_lt(k, VB.pw(d)), t, k)

def rdw_b(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hi: {Nat.is_le(i, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +b: Bool, +eb: {Nat.is_lt(i, VB.pw(d)) == b : Bool})
    -> {B.word(UA.BF(t, n), q) == (UA.BF(t, n), WSb(b, t, i)) : B.Buf & U32}:
  match b:
    case True{}: VR.rdw(d, t, n, q, i, eq, VB.lt32(d, hd), eb, pf)
    case False{}:
      +ei = F.nat__le_antisym(i, VB.pw(d), hi, F.nat__not_lt_le(i, VB.pw(d), eb))
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, t), q), (F.array__thaw(U32, t), VB.slot(t, 0n)),
          UC.get_wrap(d, t, q, Equal.trans(Nat, U32.to_nat(q), i, VB.pw(d), eq, ei), VB.lt32(d, hd), pf)) :
        {B.rewrap(n, _) == (UA.BF(t, n), VB.slot(t, 0n)) : B.Buf & U32}
      {==}

def rdw_any(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hi: {Nat.is_le(i, VB.pw(d)) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(UA.BF(t, n), q) == (UA.BF(t, n), WS(d, t, i)) : B.Buf & U32}:
  rdw_b(d, t, n, q, i, eq, hd, hi, pf, Nat.is_lt(i, VB.pw(d)), {==})

def RN(+d: Nat, +t: F.array__Tree<U32>, +X: U32) -> U32: UA.jn(VR.RX(X), VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))

def qlt(+d: Nat, +X: U32, +h: {Nat.is_lt(U32.to_nat(X), A.quad(VB.pw(d))) == True{} : Bool}) -> {Nat.is_lt(VR.QX(X), VB.pw(d)) == True{} : Bool}:
  +h1 = F.nat__le_lt_trans(A.quad(VR.QX(X)), U32.to_nat(X), A.quad(VB.pw(d)),
    F.logic__subst(Nat, z => {Nat.is_le(A.quad(VR.QX(X)), z) == True{} : Bool}, Nat.add(A.quad(VR.QX(X)), VR.RX(X)), U32.to_nat(X), Equal.sym(Nat, U32.to_nat(X), Nat.add(A.quad(VR.QX(X)), VR.RX(X)), VC.split4(X)),
      F.nat__le_add_right(A.quad(VR.QX(X)), VR.RX(X))), h)
  VR.lt_quad(VR.QX(X), VB.pw(d), h1)

def rd_nr(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +X: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hq: {Nat.is_lt(VR.QX(X), VB.pw(d)) == True{} : Bool},
    +w0: {B.word(UA.BF(t, n), U32.shrn(X, 2n)) == (UA.BF(t, n), VB.slot(t, VR.QX(X))) : B.Buf & U32},
    +w1: {B.word(UA.BF(t, n), U32.add(U32.shrn(X, 2n), 1)) == (UA.BF(t, n), WS(d, t, 1n+VR.QX(X))) : B.Buf & U32},
    +r: Nat, +er: {VR.RX(X) == r : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool})
    -> {B.read32(UA.BF(t, n), X) == (UA.BF(t, n), UA.jn(r, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}:
  match r:
    case 0n:
      +e3 = F.u32__injective(U32.and(X, 3), 0, er)
      %Equal.sym(U32, U32.and(X, 3), 0, e3) : {B.read32_choose(X, _, U32.is_eq(_, 0), UA.BF(t, n)) == (UA.BF(t, n), VB.slot(t, VR.QX(X))) : B.Buf & U32}
      w0
    case 1n:
      +e3 = F.u32__injective(U32.and(X, 3), 1, er)
      %Equal.sym(U32, U32.and(X, 3), 1, e3) : {B.read32_choose(X, _, U32.is_eq(_, 0), UA.BF(t, n)) == (UA.BF(t, n), B.join_sel(1, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.shrn(X, 2n)), (UA.BF(t, n), VB.slot(t, VR.QX(X))), w0) :
        {B.read32_split(X, 1, _) == (UA.BF(t, n), B.join_sel(1, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.add(U32.shrn(X, 2n), 1)), (UA.BF(t, n), WS(d, t, 1n+VR.QX(X))), w1) :
        {B.join_words(1, VB.slot(t, VR.QX(X)), _) == (UA.BF(t, n), B.join_sel(1, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      {==}
    case 2n:
      +e3 = F.u32__injective(U32.and(X, 3), 2, er)
      %Equal.sym(U32, U32.and(X, 3), 2, e3) : {B.read32_choose(X, _, U32.is_eq(_, 0), UA.BF(t, n)) == (UA.BF(t, n), B.join_sel(2, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.shrn(X, 2n)), (UA.BF(t, n), VB.slot(t, VR.QX(X))), w0) :
        {B.read32_split(X, 2, _) == (UA.BF(t, n), B.join_sel(2, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.add(U32.shrn(X, 2n), 1)), (UA.BF(t, n), WS(d, t, 1n+VR.QX(X))), w1) :
        {B.join_words(2, VB.slot(t, VR.QX(X)), _) == (UA.BF(t, n), B.join_sel(2, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      {==}
    case 3n:
      +e3 = F.u32__injective(U32.and(X, 3), 3, er)
      %Equal.sym(U32, U32.and(X, 3), 3, e3) : {B.read32_choose(X, _, U32.is_eq(_, 0), UA.BF(t, n)) == (UA.BF(t, n), B.join_sel(3, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.shrn(X, 2n)), (UA.BF(t, n), VB.slot(t, VR.QX(X))), w0) :
        {B.read32_split(X, 3, _) == (UA.BF(t, n), B.join_sel(3, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      %Equal.sym(B.Buf & U32, B.word(UA.BF(t, n), U32.add(U32.shrn(X, 2n), 1)), (UA.BF(t, n), WS(d, t, 1n+VR.QX(X))), w1) :
        {B.join_words(3, VB.slot(t, VR.QX(X)), _) == (UA.BF(t, n), B.join_sel(3, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}
      {==}
    case 4n+s: Empty.absurd({B.read32(UA.BF(t, n), X) == (UA.BF(t, n), UA.jn(4n+s, VB.slot(t, VR.QX(X)), WS(d, t, 1n+VR.QX(X)))) : B.Buf & U32}, F.nat__lt_zero_absurd(s, hr))

# B.read32 at any X < 4 2^d.
def rd_near(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +X: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +h: {Nat.is_lt(U32.to_nat(X), A.quad(VB.pw(d))) == True{} : Bool})
    -> {B.read32(UA.BF(t, n), X) == (UA.BF(t, n), RN(d, t, X)) : B.Buf & U32}:
  +hq = qlt(d, X, h)
  +w0 = VR.rdw(d, t, n, U32.shrn(X, 2n), VR.QX(X), {==}, VB.lt32(d, hd), hq, pf)
  +w1 = rdw_any(d, t, n, U32.add(U32.shrn(X, 2n), 1), 1n+VR.QX(X), VB.add_le_at(U32.shrn(X, 2n), 1, VR.QX(X), d, {==}, hd, F.nat__lt_succ_le_succ(VR.QX(X), VB.pw(d), hq)), hd,
    F.nat__lt_succ_le_succ(VR.QX(X), VB.pw(d), hq), pf)
  rd_nr(d, t, n, X, hd, pf, hq, w0, w1, VR.RX(X), {==}, UA.rx_lt(X))
