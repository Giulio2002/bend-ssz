import Base
import ../../spec/bit_packing.bend as Bp
import ../compact/found.bend as F
import ./spec_fixed.bend as FX
import ./words_spec.bend as WS
import ./bits_leaf.bend as BLf
import ./bitlist_pack.bend as BK
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vbitl.bend as VBL
import ./dk.bend as DK
import ./vu32.bend as VU
import ../compact/reads.bend as RD
import ./vdepth.bend as VD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ../../proofs/word_split.bend as WSp
import ./vcopy.bend as VC
import ../../src/obj.bend as O
import ../../src/merkle_fast.bend as MF
import ./vbenc.bend as VBE
import ./vbytes.bend as VY

# Bit lists, encoder side: the bits of a word list whose word q gained the
# delimiter bit r (and whose words before q are unchanged) are the first
# 32 q + r bits and True; they pack to the bytes of the words (bitlist_pack
# bpack).

def m32(q: Nat) -> Nat:
  match q:
    case 0n: 0n
    case 1n+p: 32n+m32(p)

law len_wbits:
  for +x: U32
  {List.length(&2, Bool, BLf.wbits(x)) == 32n : Nat}
def len_wbits(x):
  match x:
    case U32{WCon{+a0, WCon{+a1, WCon{+a2, WCon{+a3, WCon{+a4, WCon{+a5, WCon{+a6, WCon{+a7, WCon{+a8, WCon{+a9, WCon{+a10, WCon{+a11, WCon{+a12, WCon{+a13, WCon{+a14, WCon{+a15, WCon{+a16, WCon{+a17, WCon{+a18, WCon{+a19, WCon{+a20, WCon{+a21, WCon{+a22, WCon{+a23, WCon{+a24, WCon{+a25, WCon{+a26, WCon{+a27, WCon{+a28, WCon{+a29, WCon{+a30, WCon{+a31, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: {==}

law btk_short:
  for +s: Nat
  for +xs: +List<Bool>
  for +R: +List<Bool>
  for +h: {Nat.is_le(s, List.length(&2, Bool, xs)) == True{} : Bool}
  {BK.btk(s, List.append(&2, Bool, xs, R)) == BK.btk(s, xs) : +List<Bool>}
def btk_short(s, xs, R, h):
  match s xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({BK.btk(1n+p, List.append(&2, Bool, Nil{}, R)) == BK.btk(1n+p, Nil{}) : +List<Bool>}, F.logic__false_true(h))
    case 1n+ +p Con{+b, +t}:
      %btk_short(p, t, R, h) : {b <> BK.btk(p, List.append(&2, Bool, t, R)) == b <> _ : +List<Bool>}
      {==}

# The first 32 q + s bits (s <= 32): q whole words, then s bits of word q.
law btk_at:
  for +W: List<&2, U32>
  for +q: Nat
  for +s: Nat
  for +hs: {Nat.is_le(s, 32n) == True{} : Bool}
  for +hq: {Nat.is_lt(q, VB.len(W)) == True{} : Bool}
  {BK.btk(Nat.add(m32(q), s), BK.bitsof(W)) == List.append(&2, Bool, BK.bitsof(VS.wtake(q, W)), BK.btk(s, BLf.wbits(F.flat__nthc(W, q)))) : +List<Bool>}
def btk_at(W, q, s, hs, hq):
  match W q:
    case Nil{} _: Empty.absurd({BK.btk(Nat.add(m32(q), s), BK.bitsof(Nil{})) == List.append(&2, Bool, BK.bitsof(VS.wtake(q, Nil{})), BK.btk(s, BLf.wbits(F.flat__nthc(Nil{}, q)))) : +List<Bool>}, F.nat__lt_zero_absurd(q, hq))
    case Con{+x, +rest} 0n:
      btk_short(s, BLf.wbits(x), BK.bitsof(rest), F.logic__subst(Nat, z => {Nat.is_le(s, z) == True{} : Bool}, 32n, List.length(&2, Bool, BLf.wbits(x)), Equal.sym(Nat, List.length(&2, Bool, BLf.wbits(x)), 32n, len_wbits(x)), hs))
    case Con{+x, +rest} 1n+ +p:
      %Equal.sym(+List<Bool>, BK.btk(32n+Nat.add(m32(p), s), List.append(&2, Bool, BLf.wbits(x), BK.bitsof(rest))), List.append(&2, Bool, BLf.wbits(x), BK.btk(Nat.add(m32(p), s), BK.bitsof(rest))), BK.btk_w(Nat.add(m32(p), s), x, BK.bitsof(rest))) :
        {_ == List.append(&2, Bool, List.append(&2, Bool, BLf.wbits(x), BK.bitsof(VS.wtake(p, rest))), BK.btk(s, BLf.wbits(F.flat__nthc(rest, p)))) : +List<Bool>}
      %Equal.sym(+List<Bool>, BK.btk(Nat.add(m32(p), s), BK.bitsof(rest)), List.append(&2, Bool, BK.bitsof(VS.wtake(p, rest)), BK.btk(s, BLf.wbits(F.flat__nthc(rest, p)))), btk_at(rest, p, s, hs, hq)) :
        {List.append(&2, Bool, BLf.wbits(x), _) == List.append(&2, Bool, List.append(&2, Bool, BLf.wbits(x), BK.bitsof(VS.wtake(p, rest))), BK.btk(s, BLf.wbits(F.flat__nthc(rest, p)))) : +List<Bool>}
      Equal.sym(+List<Bool>, List.append(&2, Bool, List.append(&2, Bool, BLf.wbits(x), BK.bitsof(VS.wtake(p, rest))), BK.btk(s, BLf.wbits(F.flat__nthc(rest, p)))),
        List.append(&2, Bool, BLf.wbits(x), List.append(&2, Bool, BK.bitsof(VS.wtake(p, rest)), BK.btk(s, BLf.wbits(F.flat__nthc(rest, p))))),
        VBL.appB_assoc(BLf.wbits(x), BK.bitsof(VS.wtake(p, rest)), BK.btk(s, BLf.wbits(F.flat__nthc(rest, p)))))

def zt0(+rest: List<&2, U32>) -> {BK.zt(rest, 0n) == True{} : Bool}:
  match rest:
    case Nil{}: {==}
    case Con{+y, +r}: {==}

# zt at the head word, for s <= 32.
def zt_head(+x: U32, +rest: List<&2, U32>, +s: Nat, +hs: {Nat.is_le(s, 32n) == True{} : Bool}, +hz: {BK.zw(s, x) == True{} : Bool})
    -> {BK.zt(Con{x, rest}, s) == True{} : Bool}:
  match s:
    case 0n: hz
    case 1n: hz
    case 2n: hz
    case 3n: hz
    case 4n: hz
    case 5n: hz
    case 6n: hz
    case 7n: hz
    case 8n: hz
    case 9n: hz
    case 10n: hz
    case 11n: hz
    case 12n: hz
    case 13n: hz
    case 14n: hz
    case 15n: hz
    case 16n: hz
    case 17n: hz
    case 18n: hz
    case 19n: hz
    case 20n: hz
    case 21n: hz
    case 22n: hz
    case 23n: hz
    case 24n: hz
    case 25n: hz
    case 26n: hz
    case 27n: hz
    case 28n: hz
    case 29n: hz
    case 30n: hz
    case 31n: hz
    case 32n+ +p:
      match p:
        case 0n: zt0(rest)
        case 1n+ +e: Empty.absurd({BK.zt(Con{x, rest}, 33n+e) == True{} : Bool}, F.logic__false_true(hs))

# zt at 32 q + s from zw at word q.
law zt_at:
  for +W: List<&2, U32>
  for +q: Nat
  for +s: Nat
  for +hs: {Nat.is_le(s, 32n) == True{} : Bool}
  for +hz: {BK.zw(s, F.flat__nthc(W, q)) == True{} : Bool}
  {BK.zt(W, Nat.add(m32(q), s)) == True{} : Bool}
def zt_at(W, q, s, hs, hz):
  match W q:
    case Nil{} _: {==}
    case Con{+x, +rest} 0n: zt_head(x, rest, s, hs, hz)
    case Con{+x, +rest} 1n+ +p: zt_at(rest, p, s, hs, hz)

law btake_bt:
  for +n: Nat
  for +xs: +List<U32>
  {WS.btake(n, xs) == VS.bt(n, xs) : +List<U32>}
def btake_bt(n, xs):
  match n xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}:
      %Equal.sym(+List<U32>, WS.btake(p, t), VS.bt(p, t), btake_bt(p, t)) : {h <> _ == h <> VS.bt(p, t) : +List<U32>}
      {==}

def eb_bits(+W: List<&2, U32>, +S: List<&2, U32>, +q: Nat, +r: Nat, +hr: {Nat.is_le(r, 31n) == True{} : Bool},
    +hqW: {Nat.is_lt(q, VB.len(W)) == True{} : Bool}, +hqS: {Nat.is_lt(q, VB.len(S)) == True{} : Bool},
    +ep: {VS.wtake(q, W) == VS.wtake(q, S) : List<&2, U32>},
    +h1: {BK.btk(1n+r, BLf.wbits(F.flat__nthc(W, q))) == List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}]) : +List<Bool>})
    -> {BK.btk(Nat.add(m32(q), 1n+r), BK.bitsof(W)) == List.append(&2, Bool, BK.btk(Nat.add(m32(q), r), BK.bitsof(S)), [True{}]) : +List<Bool>}:
  %Equal.sym(+List<Bool>, BK.btk(Nat.add(m32(q), 1n+r), BK.bitsof(W)), List.append(&2, Bool, BK.bitsof(VS.wtake(q, W)), BK.btk(1n+r, BLf.wbits(F.flat__nthc(W, q)))), btk_at(W, q, 1n+r, F.nat__le_trans(1n+r, 32n, 32n, hr, {==}), hqW)) : {_ == List.append(&2, Bool, BK.btk(Nat.add(m32(q), r), BK.bitsof(S)), [True{}]) : +List<Bool>}
  %Equal.sym(List<&2, U32>, VS.wtake(q, W), VS.wtake(q, S), ep) : {List.append(&2, Bool, BK.bitsof(_), BK.btk(1n+r, BLf.wbits(F.flat__nthc(W, q)))) == List.append(&2, Bool, BK.btk(Nat.add(m32(q), r), BK.bitsof(S)), [True{}]) : +List<Bool>}
  %Equal.sym(+List<Bool>, BK.btk(1n+r, BLf.wbits(F.flat__nthc(W, q))), List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}]), h1) : {List.append(&2, Bool, BK.bitsof(VS.wtake(q, S)), _) == List.append(&2, Bool, BK.btk(Nat.add(m32(q), r), BK.bitsof(S)), [True{}]) : +List<Bool>}
  %Equal.sym(+List<Bool>, BK.btk(Nat.add(m32(q), r), BK.bitsof(S)), List.append(&2, Bool, BK.bitsof(VS.wtake(q, S)), BK.btk(r, BLf.wbits(F.flat__nthc(S, q)))), btk_at(S, q, r, F.nat__le_trans(r, 31n, 32n, hr, {==}), hqS)) :
    {List.append(&2, Bool, BK.bitsof(VS.wtake(q, S)), List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}])) == List.append(&2, Bool, _, [True{}]) : +List<Bool>}
  Equal.sym(+List<Bool>, List.append(&2, Bool, List.append(&2, Bool, BK.bitsof(VS.wtake(q, S)), BK.btk(r, BLf.wbits(F.flat__nthc(S, q)))), [True{}]),
    List.append(&2, Bool, BK.bitsof(VS.wtake(q, S)), List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}])),
    VBL.appB_assoc(BK.bitsof(VS.wtake(q, S)), BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}]))

# The delimiter bit at K = 32 q + r: the bits and True pack to the words' bytes.
def pack_delim(+W: List<&2, U32>, +S: List<&2, U32>, +q: Nat, +r: Nat, +hr: {Nat.is_le(r, 31n) == True{} : Bool},
    +hqW: {Nat.is_lt(q, VB.len(W)) == True{} : Bool}, +hqS: {Nat.is_lt(q, VB.len(S)) == True{} : Bool},
    +ep: {VS.wtake(q, W) == VS.wtake(q, S) : List<&2, U32>},
    +h1: {BK.btk(1n+r, BLf.wbits(F.flat__nthc(W, q))) == List.append(&2, Bool, BK.btk(r, BLf.wbits(F.flat__nthc(S, q))), [True{}]) : +List<Bool>},
    +h2: {BK.zw(1n+r, F.flat__nthc(W, q)) == True{} : Bool})
    -> {Bp.pack(List.append(&2, Bool, BK.btk(Nat.add(m32(q), r), BK.bitsof(S)), [True{}])) == VS.bt(Bp.byte_count(Nat.add(m32(q), 1n+r)), FX.limbs(W)) : +List<U32>}:
  %eb_bits(W, S, q, r, hr, hqW, hqS, ep, h1) : {Bp.pack(_) == VS.bt(Bp.byte_count(Nat.add(m32(q), 1n+r)), FX.limbs(W)) : +List<U32>}
  %btake_bt(Bp.byte_count(Nat.add(m32(q), 1n+r)), FX.limbs(W)) : {Bp.pack(BK.btk(Nat.add(m32(q), 1n+r), BK.bitsof(W))) == _ : +List<U32>}
  BK.bpack(W, Nat.add(m32(q), 1n+r), zt_at(W, q, 1n+r, F.nat__le_trans(1n+r, 32n, 32n, hr, {==}), h2))


# ---- the bit list writer ---------------------------------------------------------------------

def PD(+p: U32, +K: U32) -> U32: U32.add(p, U32.shrn(K, 3n))
def DMK(+p: U32, +K: U32) -> U32: O.shl_bytes(U32.and(MF.shl_by(1, U32.and(K, 7)), 255), U32.and(PD(p, K), 3))
# The words copied (main's VBE.put_words_any), then the delimiter OR-ed into word QD.
def MT(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +P: Nat, +K: U32) -> F.array__Tree<U32>:
  VB.mone(VC.NW(O.bits_nbytes(K)), 0n, P, dd, D, T)
def OUTB(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +K: U32, +QD: Nat) -> F.array__Tree<U32>:
  F.array__upd(U32, dd, MT(dd, D, T, P, K), QD, U32.or(VB.slot(MT(dd, D, T, P, K), QD), DMK(p, K)))

def put_bits2(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +K: U32, +QD: Nat, +k: Nat,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(O.bits_nbytes(K)), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), P), VB.pw(dd)) == True{} : Bool},
    +hz: {VB.slot(D, Nat.add(VY.QL(O.bits_nbytes(K)), P)) == 0 : U32},
    +eQ: {U32.to_nat(U32.shrn(PD(p, K), 2n)) == QD : Nat}, +hQ: {Nat.is_lt(QD, VB.pw(dd)) == True{} : Bool})
    -> {O.put_bits(F.array__thaw(U32, D), p, O.Bits{F.array__thaw(U32, T), K}) == (F.array__thaw(U32, OUTB(dd, D, T, p, P, K, QD)), O.Bits{F.array__thaw(U32, T), K}) : Array<U32> & O.Bits}:
  +W1 = MT(dd, D, T, P, K)
  +pf1 = VB.mone_perfect(VC.NW(O.bits_nbytes(K)), 0n, P, dd, D, T, pfD)
  %Equal.sym(Array<U32> & O.Words, O.put_words(F.array__thaw(U32, D), p, O.Words{F.array__thaw(U32, T), O.bits_nbytes(K)}), (F.array__thaw(U32, W1), O.Words{F.array__thaw(U32, T), O.bits_nbytes(K)}),
      VBE.put_words_any(dd, dw, D, T, p, P, O.bits_nbytes(K), k, pfD, pfT, hdd, hdw, hp3, eP, hk, hy, hsrc, hdst, hz)) :
    {O.bits_fin(K, O.w8_delim(p, K, _)) == (F.array__thaw(U32, OUTB(dd, D, T, p, P, K, QD)), O.Bits{F.array__thaw(U32, T), K}) : Array<U32> & O.Bits}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, W1), U32.shrn(PD(p, K), 2n)), (F.array__thaw(U32, W1), VB.slot(W1, QD)),
      VB.get_n(dd, W1, U32.shrn(PD(p, K), 2n), QD, eQ, VB.lt32(dd, hdd), hQ, pf1)) :
    {O.bits_fin(K, (O.or_at(U32.shrn(PD(p, K), 2n), DMK(p, K), _), O.Words{F.array__thaw(U32, T), O.bits_nbytes(K)})) == (F.array__thaw(U32, OUTB(dd, D, T, p, P, K, QD)), O.Bits{F.array__thaw(U32, T), K}) : Array<U32> & O.Bits}
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, W1), U32.shrn(PD(p, K), 2n), U32.or(VB.slot(W1, QD), DMK(p, K))),
      F.array__thaw(U32, OUTB(dd, D, T, p, P, K, QD)),
      VB.set_n(dd, W1, U32.shrn(PD(p, K), 2n), QD, U32.or(VB.slot(W1, QD), DMK(p, K)), eQ, VB.lt32(dd, hdd), hQ, pf1)) :
    {O.bits_fin(K, (_, O.Words{F.array__thaw(U32, T), O.bits_nbytes(K)})) == (F.array__thaw(U32, OUTB(dd, D, T, p, P, K, QD)), O.Bits{F.array__thaw(U32, T), K}) : Array<U32> & O.Bits}
  {==}

# ---- the words of the output -------------------------------------------------------------------

law nth_lm_out:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +L: List<&2, U32>
  for +SL: List<&2, U32>
  for +k: Nat
  for +h: {Nat.is_le(Nat.add(n, j), k) == True{} : Bool}
  {F.flat__nthc(VB.lm(n, i, j, L, SL), k) == F.flat__nthc(L, k) : U32}
def nth_lm_out(n, i, j, L, SL, k, h):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +L1 = F.spec_common__update(U32, L, j, F.flat__nthc(SL, i))
      +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, k) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), F.nat__add_succ(p, j)), h)
      +ne = F.nat__is_eq_lt(j, k, VB.le1_head(p, j, k, h))
      Equal.trans(U32, F.flat__nthc(VB.lm(p, 1n+i, 1n+j, L1, SL), k), F.flat__nthc(L1, k), F.flat__nthc(L, k),
        nth_lm_out(p, 1n+i, 1n+j, L1, SL, k, h1), F.flat__nthc_other(L, j, k, F.flat__nthc(SL, i), ne))

law take_take:
  for +m: Nat
  for +n: Nat
  for +X: List<&2, U32>
  for +h: {Nat.is_le(m, n) == True{} : Bool}
  {VS.wtake(m, VS.wtake(n, X)) == VS.wtake(m, X) : List<&2, U32>}
def take_take(m, n, X, h):
  match m n X:
    case 0n _ _: {==}
    case 1n+ +p 0n _: Empty.absurd({VS.wtake(1n+p, VS.wtake(0n, X)) == VS.wtake(1n+p, X) : List<&2, U32>}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q Nil{}: {==}
    case 1n+ +p 1n+ +q Con{+x, +t}:
      %Equal.sym(List<&2, U32>, VS.wtake(p, VS.wtake(q, t)), VS.wtake(p, t), take_take(p, q, t, h)) : {x <> _ == x <> VS.wtake(p, t) : List<&2, U32>}
      {==}

law nth_take:
  for +k: Nat
  for +n: Nat
  for +X: List<&2, U32>
  for +h: {Nat.is_lt(k, n) == True{} : Bool}
  {F.flat__nthc(VS.wtake(n, X), k) == F.flat__nthc(X, k) : U32}
def nth_take(k, n, X, h):
  match k n X:
    case _ 0n _: Empty.absurd({F.flat__nthc(VS.wtake(0n, X), k) == F.flat__nthc(X, k) : U32}, F.nat__lt_zero_absurd(k, h))
    case _ 1n+ +q Nil{}: {==}
    case 0n 1n+ +q Con{+x, +t}: {==}
    case 1n+ +p 1n+ +q Con{+x, +t}: nth_take(p, q, t, h)

# The first m words of a copy of n >= m words.
def take_lm(+m: Nat, +n: Nat, +Z: List<&2, U32>, +S: List<&2, U32>, +hm: {Nat.is_le(m, n) == True{} : Bool},
    +hZ: {Nat.is_le(Nat.add(n, 0n), VB.len(Z)) == True{} : Bool}, +hS: {Nat.is_le(Nat.add(n, 0n), VB.len(S)) == True{} : Bool})
    -> {VS.wtake(m, VB.lm(n, 0n, 0n, Z, S)) == VS.wtake(m, S) : List<&2, U32>}:
  %take_take(m, n, VB.lm(n, 0n, 0n, Z, S), hm) :
    {_ == VS.wtake(m, S) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(n, VB.lm(n, 0n, 0n, Z, S)), VS.wtake(n, S), VB.lm_win(n, 0n, 0n, Z, S, hZ, hS)) : {VS.wtake(m, _) == VS.wtake(m, S) : List<&2, U32>}
  take_take(m, n, S, hm)

def nth_lm_in(+k: Nat, +n: Nat, +Z: List<&2, U32>, +S: List<&2, U32>, +hk: {Nat.is_lt(k, n) == True{} : Bool},
    +hZ: {Nat.is_le(Nat.add(n, 0n), VB.len(Z)) == True{} : Bool}, +hS: {Nat.is_le(Nat.add(n, 0n), VB.len(S)) == True{} : Bool})
    -> {F.flat__nthc(VB.lm(n, 0n, 0n, Z, S), k) == F.flat__nthc(S, k) : U32}:
  %nth_take(k, n, VB.lm(n, 0n, 0n, Z, S), hk) :
    {_ == F.flat__nthc(S, k) : U32}
  %Equal.sym(List<&2, U32>, VS.wtake(n, VB.lm(n, 0n, 0n, Z, S)), VS.wtake(n, S), VB.lm_win(n, 0n, 0n, Z, S, hZ, hS)) : {F.flat__nthc(_, k) == F.flat__nthc(S, k) : U32}
  nth_take(k, n, S, hk)

def zslot(+d: Nat, +k: Nat) -> {F.flat__nthc(F.array__slots(U32, VC.ZT(d)), k) == 0 : U32}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VC.ZT(d)), F.spec_common__replicate(U32, F.spec_common__pow2(d), 0), F.array__trep_slots(U32, d, 0)) :
    {F.flat__nthc(_, k) == 0 : U32}
  F.flat__nthc_rep(F.spec_common__pow2(d), k)

# ---- numbers of a bit count K ----------------------------------------------------------------

law h2a:
  for +k: Nat
  for +y: Nat
  {VD.s_h2(Nat.add(Nat.double(k), y)) == Nat.add(k, VD.s_h2(y)) : Nat}
def h2a(k, y):
  match k:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, VD.s_h2(Nat.add(Nat.double(p), y)), Nat.add(p, VD.s_h2(y)), h2a(p, y)) : {1n+_ == 1n+Nat.add(p, VD.s_h2(y)) : Nat}
      {==}

def r2a(+h: Nat, +y: Nat) -> {VD.s_rng(2n, Nat.add(A.quad(h), y)) == Nat.add(h, VD.s_rng(2n, y)) : Nat}:
  %Equal.sym(Nat, VD.s_h2(Nat.add(Nat.double(Nat.double(h)), y)), Nat.add(Nat.double(h), VD.s_h2(y)), h2a(Nat.double(h), y)) : {VD.s_h2(_) == Nat.add(h, VD.s_h2(VD.s_h2(y))) : Nat}
  h2a(h, VD.s_h2(y))

def r3a(+h: Nat, +y: Nat) -> {VD.s_rng(3n, Nat.add(VS.x8(h), y)) == Nat.add(h, VD.s_rng(3n, y)) : Nat}:
  %Equal.sym(Nat, VS.x8(h), VB.d3(h), VB.x8_d3(h)) : {VD.s_rng(3n, Nat.add(_, y)) == Nat.add(h, VD.s_rng(3n, y)) : Nat}
  %Equal.sym(Nat, VD.s_h2(Nat.add(Nat.double(Nat.double(Nat.double(h))), y)), Nat.add(Nat.double(Nat.double(h)), VD.s_h2(y)), h2a(Nat.double(Nat.double(h)), y)) :
    {VD.s_h2(VD.s_h2(_)) == Nat.add(h, VD.s_rng(3n, y)) : Nat}
  %Equal.sym(Nat, VD.s_h2(Nat.add(Nat.double(Nat.double(h)), VD.s_h2(y))), Nat.add(Nat.double(h), VD.s_h2(VD.s_h2(y))), h2a(Nat.double(h), VD.s_h2(y))) :
    {VD.s_h2(_) == Nat.add(h, VD.s_rng(3n, y)) : Nat}
  h2a(h, VD.s_h2(VD.s_h2(y)))

law le_x8:
  for +a: Nat
  {Nat.is_le(a, VS.x8(a)) == True{} : Bool}
def le_x8(a):
  match a:
    case 0n: {==}
    case 1n+ +p: F.nat__le_trans(p, VS.x8(p), 7n+VS.x8(p), le_x8(p), Order.left_below_sum(7n, VS.x8(p)))

# a + b <= K + 7 < K + 8 <= 2^kb <= 2^32: the U32 sum does not wrap.
def sadd33(+a: U32, +b: U32, +K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hK: {Nat.is_le(Nat.add(U32.to_nat(K), 8n), O.pow2n(kb)) == True{} : Bool},
    +hs: {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(U32.to_nat(K), 7n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, b)) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}:
  +S = Nat.add(U32.to_nat(a), U32.to_nat(b))
  +h1 = F.nat__le_lt_trans(S, Nat.add(U32.to_nat(K), 7n), O.pow2n(kb), hs,
    F.nat__lt_le_trans(Nat.add(U32.to_nat(K), 7n), Nat.add(U32.to_nat(K), 8n), O.pow2n(kb), F.nat__lt_add_left(7n, 8n, U32.to_nat(K), {==}), hK))
  +h2 = F.logic__subst(Nat, z => {Nat.is_lt(S, z) == True{} : Bool}, O.pow2n(kb), VB.pw(kb), Equal.sym(Nat, VB.pw(kb), O.pow2n(kb), VD.s_pow2_eq(kb)), h1)
  +h3 = F.nat__lt_le_trans(S, VB.pw(kb), F.spec_common__pow2(32n), h2, F.nat__pow2_mono(kb, 32n, F.nat__lt_succ_le(kb, 32n, hkb)))
  +h4 = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(32n)) == True{} : Bool}, S, Nat.add(U32.to_nat(b), U32.to_nat(a)), F.nat__add_comm(U32.to_nat(a), U32.to_nat(b)), h3)
  Equal.trans(Nat, U32.to_nat(U32.add(a, b)), Nat.add(U32.to_nat(b), U32.to_nat(a)), S, VB.add_lt32(a, b, U32.to_nat(a), {==}, h4), F.nat__add_comm(U32.to_nat(b), U32.to_nat(a)))

def AK(+K: U32) -> Nat: U32.to_nat(U32.shrn(K, 3n))
def BKk(+K: U32) -> Nat: U32.to_nat(U32.and(K, 7))
def PDK(+K: U32) -> U32: PD(0, K)
def QK(+K: U32) -> Nat: U32.to_nat(U32.shrn(PDK(K), 2n))
def JK(+K: U32) -> Nat: U32.to_nat(U32.and(PDK(K), 3))

def HK(+K: U32, +kb: Nat) -> Data: {Nat.is_le(Nat.add(U32.to_nat(K), 8n), O.pow2n(kb)) == True{} : Bool}

def E1(+K: U32) -> {U32.to_nat(K) == Nat.add(VS.x8(AK(K)), BKk(K)) : Nat}: VB.split8(K)

def leA(+K: U32, +kb: Nat, +hK: HK(K, kb)) -> {Nat.is_le(Nat.add(U32.to_nat(K), 8n), O.pow2n(kb)) == True{} : Bool}: hK

def lK(+K: U32, +kb: Nat, +hK: HK(K, kb)) -> {Nat.is_le(U32.to_nat(K), O.pow2n(kb)) == True{} : Bool}:
  F.nat__le_trans(U32.to_nat(K), Nat.add(U32.to_nat(K), 8n), O.pow2n(kb), F.nat__le_add_right(U32.to_nat(K), 8n), hK)

def lAK(+K: U32) -> {Nat.is_le(AK(K), U32.to_nat(K)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(K), Nat.add(VS.x8(AK(K)), BKk(K)), E1(K)) : {Nat.is_le(AK(K), _) == True{} : Bool}
  F.nat__le_trans(AK(K), VS.x8(AK(K)), Nat.add(VS.x8(AK(K)), BKk(K)), le_x8(AK(K)), F.nat__le_add_right(VS.x8(AK(K)), BKk(K)))

def Epd(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb)) -> {U32.to_nat(PDK(K)) == AK(K) : Nat}:
  sadd33(0, U32.shrn(K, 3n), K, kb, hkb, hK, F.nat__le_trans(AK(K), U32.to_nat(K), Nat.add(U32.to_nat(K), 7n), lAK(K), F.nat__le_add_right(U32.to_nat(K), 7n)))

def E2(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb)) -> {AK(K) == Nat.add(A.quad(QK(K)), JK(K)) : Nat}:
  %Epd(K, kb, hkb, hK) : {_ == Nat.add(A.quad(QK(K)), JK(K)) : Nat}
  VC.split4(PDK(K))

# The byte count ceil(K / 8).
def E3(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb))
    -> {U32.to_nat(O.bits_nbytes(K)) == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(U32.add(K, 7), 3n)), VD.s_rng(3n, U32.to_nat(U32.add(K, 7))), VD.shrk(3n, U32.add(K, 7))) : {_ == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(K, 7)), Nat.add(U32.to_nat(K), 7n), sadd33(K, 7, K, kb, hkb, hK, F.nat__le_refl(Nat.add(U32.to_nat(K), 7n)))) :
    {VD.s_rng(3n, _) == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}
  %Equal.sym(Nat, U32.to_nat(K), Nat.add(VS.x8(AK(K)), BKk(K)), E1(K)) : {VD.s_rng(3n, Nat.add(_, 7n)) == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(VS.x8(AK(K)), BKk(K)), 7n), Nat.add(VS.x8(AK(K)), Nat.add(BKk(K), 7n)), F.nat__add_assoc(VS.x8(AK(K)), BKk(K), 7n)) : {VD.s_rng(3n, _) == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}
  r3a(AK(K), Nat.add(BKk(K), 7n))

# The output size K / 8 + 1.
def E4(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb))
    -> {U32.to_nat(U32.add(U32.shrn(K, 3n), 1)) == Nat.add(AK(K), 1n) : Nat}:
  sadd33(U32.shrn(K, 3n), 1, K, kb, hkb, hK, F.nat__le_trans(Nat.add(AK(K), 1n), Nat.add(U32.to_nat(K), 1n), Nat.add(U32.to_nat(K), 7n), Order.add_right(AK(K), U32.to_nat(K), 1n, lAK(K)), Order.add_left(U32.to_nat(K), 1n, 7n, {==})))

# The word of the bit K: K / 32.
def E5(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb))
    -> {U32.to_nat(U32.shrn(K, 5n)) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(K, 5n)), VD.s_rng(5n, U32.to_nat(K)), VD.shrk(5n, K)) : {_ == Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))) : Nat}
  %Equal.sym(Nat, VD.s_rng(Nat.add(3n, 2n), U32.to_nat(K)), VD.s_rng(2n, VD.s_rng(3n, U32.to_nat(K))), VD.rng_comp2(3n, 2n, U32.to_nat(K))) : {_ == Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))) : Nat}
  %Equal.sym(Nat, U32.to_nat(K), Nat.add(VS.x8(AK(K)), BKk(K)), E1(K)) : {VD.s_rng(2n, VD.s_rng(3n, _)) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))) : Nat}
  %Equal.sym(Nat, VD.s_rng(3n, Nat.add(VS.x8(AK(K)), BKk(K))), Nat.add(AK(K), VD.s_rng(3n, BKk(K))), r3a(AK(K), BKk(K))) : {VD.s_rng(2n, _) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))) : Nat}
  %Equal.sym(Nat, AK(K), Nat.add(A.quad(QK(K)), JK(K)), E2(K, kb, hkb, hK)) : {VD.s_rng(2n, Nat.add(_, VD.s_rng(3n, BKk(K)))) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(QK(K)), JK(K)), VD.s_rng(3n, BKk(K))), Nat.add(A.quad(QK(K)), Nat.add(JK(K), VD.s_rng(3n, BKk(K)))), F.nat__add_assoc(A.quad(QK(K)), JK(K), VD.s_rng(3n, BKk(K)))) : {VD.s_rng(2n, _) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))) : Nat}
  r2a(QK(K), Nat.add(JK(K), VD.s_rng(3n, BKk(K))))

# ceil(L / 4) words.
def NWE(+L: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +h: {Nat.is_le(Nat.add(U32.to_nat(L), 3n), O.pow2n(kb)) == True{} : Bool})
    -> {VC.NW(L) == VD.s_rng(2n, Nat.add(U32.to_nat(L), 3n)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(U32.add(L, 3), 2n)), VD.s_rng(2n, U32.to_nat(U32.add(L, 3))), VD.shrk(2n, U32.add(L, 3))) : {_ == VD.s_rng(2n, Nat.add(U32.to_nat(L), 3n)) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(L, 3)), Nat.add(U32.to_nat(L), 3n), VD.s_add_nat(L, 3, kb, hkb, h)) : {VD.s_rng(2n, _) == VD.s_rng(2n, Nat.add(U32.to_nat(L), 3n)) : Nat}
  {==}

law x8q:
  for +q: Nat
  for +j: Nat
  {VS.x8(Nat.add(A.quad(q), j)) == Nat.add(m32(q), VS.x8(j)) : Nat}
def x8q(q, j):
  match q:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, VS.x8(Nat.add(A.quad(p), j)), Nat.add(m32(p), VS.x8(j)), x8q(p, j)) : {32n+_ == 32n+Nat.add(m32(p), VS.x8(j)) : Nat}
      {==}

law bc32:
  for +q: Nat
  for +s: Nat
  {Bp.byte_count(Nat.add(m32(q), s)) == Nat.add(A.quad(q), Bp.byte_count(s)) : Nat}
def bc32(q, s):
  match q:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Bp.byte_count(Nat.add(m32(p), s)), Nat.add(A.quad(p), Bp.byte_count(s)), bc32(p, s)) : {4n+_ == 4n+Nat.add(A.quad(p), Bp.byte_count(s)) : Nat}
      {==}

# K = 32 q + 8 j + b.
def Ka(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat,
    +ej: {JK(K) == j : Nat}, +eb: {BKk(K) == b : Nat})
    -> {U32.to_nat(K) == Nat.add(m32(QK(K)), Nat.add(VS.x8(j), b)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(K), Nat.add(VS.x8(AK(K)), BKk(K)), E1(K)) : {_ == Nat.add(m32(QK(K)), Nat.add(VS.x8(j), b)) : Nat}
  %Equal.sym(Nat, AK(K), Nat.add(A.quad(QK(K)), JK(K)), E2(K, kb, hkb, hK)) : {Nat.add(VS.x8(_), BKk(K)) == Nat.add(m32(QK(K)), Nat.add(VS.x8(j), b)) : Nat}
  %Equal.sym(Nat, JK(K), j, ej) : {Nat.add(VS.x8(Nat.add(A.quad(QK(K)), _)), BKk(K)) == Nat.add(m32(QK(K)), Nat.add(VS.x8(j), b)) : Nat}
  %Equal.sym(Nat, BKk(K), b, eb) : {Nat.add(VS.x8(Nat.add(A.quad(QK(K)), j)), _) == Nat.add(m32(QK(K)), Nat.add(VS.x8(j), b)) : Nat}
  %Equal.sym(Nat, VS.x8(Nat.add(A.quad(QK(K)), j)), Nat.add(m32(QK(K)), VS.x8(j)), x8q(QK(K), j)) : {Nat.add(_, b) == Nat.add(m32(QK(K)), Nat.add(VS.x8(j), b)) : Nat}
  F.nat__add_assoc(m32(QK(K)), VS.x8(j), b)

# x = 4 Q + R, R < 4: the low two bits are R.
def T4(+x: U32, +Q: Nat, +R: Nat, +e: {U32.to_nat(x) == Nat.add(A.quad(Q), R) : Nat}, +hR: {Nat.is_lt(R, 4n) == True{} : Bool})
    -> {U32.to_nat(U32.and(x, 3)) == R : Nat}:
  +Qx = U32.to_nat(U32.shrn(x, 2n))
  +Rx = U32.to_nat(U32.and(x, 3))
  +e1 = Equal.trans(Nat, Nat.add(Nat.mul(Qx, 4n), Rx), Nat.add(A.quad(Qx), Rx), Nat.add(Nat.mul(Q, 4n), R),
    Equal.cong(Nat, Nat, z => Nat.add(z, Rx), Nat.mul(Qx, 4n), A.quad(Qx), VC.quad_mul(Qx)),
    Equal.trans(Nat, Nat.add(A.quad(Qx), Rx), U32.to_nat(x), Nat.add(Nat.mul(Q, 4n), R), Equal.sym(Nat, U32.to_nat(x), Nat.add(A.quad(Qx), Rx), VC.split4(x)),
      Equal.trans(Nat, U32.to_nat(x), Nat.add(A.quad(Q), R), Nat.add(Nat.mul(Q, 4n), R), e,
        Equal.cong(Nat, Nat, z => Nat.add(z, R), A.quad(Q), Nat.mul(Q, 4n), Equal.sym(Nat, Nat.mul(Q, 4n), A.quad(Q), VC.quad_mul(Q))))))
  Pair.snd({Qx == Q : Nat}, {Rx == R : Nat}, VU.dm_unique(Qx, Rx, Q, R, 4n, e1, F.nat__le_lt_trans(Rx, 3n, 4n, RD.and_le(x, 3), {==}), hR))

def sub1(+x: U32, +m: Nat, +e: {U32.to_nat(x) == 1n+m : Nat}) -> {U32.to_nat(U32.sub(x, 1)) == m : Nat}:
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+m, U32.to_nat(x), Equal.sym(Nat, U32.to_nat(x), 1n+m, e), F.nat__zero_le(m))
  %Equal.sym(Nat, U32.to_nat(U32.sub(x, 1)), Nat.sub(U32.to_nat(x), 1n), F.u32__sub_nat(x, 1, h1)) : {_ == m : Nat}
  %Equal.sym(Nat, U32.to_nat(x), 1n+m, e) : {Nat.sub(_, 1n) == m : Nat}
  F.nat__add_sub_cancel(1n, m)

# 8 m < 2^(3 + m') gives m < 2^m'.
def rng3(+m: Nat, +X: Nat, +h: {Nat.is_lt(X, O.pow2n(Nat.add(3n, m))) == True{} : Bool}) -> {Nat.is_lt(VD.s_rng(3n, X), O.pow2n(m)) == True{} : Bool}:
  VD.small_inv(m, VD.s_rng(3n, X), F.logic__subst(Nat, z => {Nat.is_lt(z, 1n) == True{} : Bool}, VD.s_rng(Nat.add(3n, m), X), VD.s_rng(m, VD.s_rng(3n, X)), VD.rng_comp2(3n, m, X), VD.small_rng(Nat.add(3n, m), X, h)))

# K + 8 <= 2^kb, kb <= 32: K < 2^32, so K / 8 < 2^29.
def ak29(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb)) -> {Nat.is_lt(AK(K), O.pow2n(29n)) == True{} : Bool}:
  +h32 = F.nat__lt_le_trans(U32.to_nat(K), Nat.add(U32.to_nat(K), 8n), O.pow2n(32n),
    F.logic__subst(Nat, z => {Nat.is_lt(z, Nat.add(U32.to_nat(K), 8n)) == True{} : Bool}, Nat.add(U32.to_nat(K), 0n), U32.to_nat(K), F.nat__add_zero(U32.to_nat(K)), F.nat__lt_add_left(0n, 8n, U32.to_nat(K), {==})),
    F.nat__le_trans(Nat.add(U32.to_nat(K), 8n), O.pow2n(kb), O.pow2n(32n), hK, VD.s_pow2_mono(kb, 32n, F.nat__lt_succ_le(kb, 32n, hkb))))
  F.logic__subst(Nat, z => {Nat.is_lt(z, O.pow2n(29n)) == True{} : Bool}, VD.s_rng(3n, U32.to_nat(K)), AK(K), Equal.sym(Nat, AK(K), VD.s_rng(3n, U32.to_nat(K)), VD.shrk(3n, K)),
    rng3(29n, U32.to_nat(K), h32))

# The copy size of the byte count: 31 + ceil(K / 8) <= 2^30.
def y30(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb),
    +hnb: {Nat.is_le(U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), 1n)) == True{} : Bool})
    -> {Nat.is_le(VC.YL(O.bits_nbytes(K)), VB.pw(30n)) == True{} : Bool}:
  +P = O.pow2n(29n)
  +h1 = F.nat__le_trans(VC.YL(O.bits_nbytes(K)), Nat.add(31n, Nat.add(AK(K), 1n)), Nat.add(31n, P), Order.add_left(31n, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), 1n), hnb),
    Order.add_left(31n, Nat.add(AK(K), 1n), P, F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, 1n+AK(K), Nat.add(AK(K), 1n), F.nat__add_comm(1n, AK(K)),
      F.nat__lt_succ_le_succ(AK(K), P, ak29(K, kb, hkb, hK)))))
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, P), z) == True{} : Bool}, Nat.add(P, P), Nat.double(P), Equal.sym(Nat, Nat.double(P), Nat.add(P, P), F.lru_nat_algebra__double_self(P)),
    Order.add_right(31n, P, P, F.nat__le_trans(31n, O.pow2n(5n), P, {==}, VD.s_pow2_mono(5n, 29n, {==}))))
  %Equal.sym(Nat, VB.pw(30n), O.pow2n(30n), VD.s_pow2_eq(30n)) : {Nat.is_le(VC.YL(O.bits_nbytes(K)), _) == True{} : Bool}
  F.nat__le_trans(VC.YL(O.bits_nbytes(K)), Nat.add(31n, P), Nat.double(P), h1, h2)

# ceil(L / 4) for L = 4 q + c, L + 3 <= K + 7 (any bit count K + 8 <= 2^kb, kb <= 32).
def NWq7(+L: U32, +q: Nat, +c: Nat, +K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb),
    +h: {Nat.is_le(Nat.add(U32.to_nat(L), 3n), Nat.add(U32.to_nat(K), 7n)) == True{} : Bool}, +e: {U32.to_nat(L) == Nat.add(A.quad(q), c) : Nat})
    -> {VC.NW(L) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(U32.add(L, 3), 2n)), VD.s_rng(2n, U32.to_nat(U32.add(L, 3))), VD.shrk(2n, U32.add(L, 3))) : {_ == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(L, 3)), Nat.add(U32.to_nat(L), 3n), sadd33(L, 3, K, kb, hkb, hK, h)) : {VD.s_rng(2n, _) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  %Equal.sym(Nat, U32.to_nat(L), Nat.add(A.quad(q), c), e) : {VD.s_rng(2n, Nat.add(_, 3n)) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), c), 3n), Nat.add(A.quad(q), Nat.add(c, 3n)), F.nat__add_assoc(A.quad(q), c, 3n)) : {VD.s_rng(2n, _) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  r2a(q, Nat.add(c, 3n))

# ceil(L / 4) for L = 4 q + c.
def NWq(+L: U32, +q: Nat, +c: Nat, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(L), 3n), O.pow2n(kb)) == True{} : Bool}, +e: {U32.to_nat(L) == Nat.add(A.quad(q), c) : Nat})
    -> {VC.NW(L) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}:
  %Equal.sym(Nat, VC.NW(L), VD.s_rng(2n, Nat.add(U32.to_nat(L), 3n)), NWE(L, kb, hkb, h)) : {_ == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  %Equal.sym(Nat, U32.to_nat(L), Nat.add(A.quad(q), c), e) : {VD.s_rng(2n, Nat.add(_, 3n)) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), c), 3n), Nat.add(A.quad(q), Nat.add(c, 3n)), F.nat__add_assoc(A.quad(q), c, 3n)) : {VD.s_rng(2n, _) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  r2a(q, Nat.add(c, 3n))

# The byte count, for K = 32 q + 8 j + b.
def G2(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat,
    +ej: {JK(K) == j : Nat}, +eb: {BKk(K) == b : Nat})
    -> {U32.to_nat(O.bits_nbytes(K)) == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))), E3(K, kb, hkb, hK)) :
    {_ == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}
  %Equal.sym(Nat, AK(K), Nat.add(A.quad(QK(K)), JK(K)), E2(K, kb, hkb, hK)) : {Nat.add(_, VD.s_rng(3n, Nat.add(BKk(K), 7n))) == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}
  %Equal.sym(Nat, JK(K), j, ej) : {Nat.add(Nat.add(A.quad(QK(K)), _), VD.s_rng(3n, Nat.add(BKk(K), 7n))) == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}
  %Equal.sym(Nat, BKk(K), b, eb) : {Nat.add(Nat.add(A.quad(QK(K)), j), VD.s_rng(3n, Nat.add(_, 7n))) == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}
  F.nat__add_assoc(A.quad(QK(K)), j, VD.s_rng(3n, Nat.add(b, 7n)))

def G4(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +ej: {JK(K) == j : Nat})
    -> {U32.to_nat(U32.add(U32.shrn(K, 3n), 1)) == Nat.add(A.quad(QK(K)), Nat.add(j, 1n)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(U32.shrn(K, 3n), 1)), Nat.add(AK(K), 1n), E4(K, kb, hkb, hK)) : {_ == Nat.add(A.quad(QK(K)), Nat.add(j, 1n)) : Nat}
  %Equal.sym(Nat, AK(K), Nat.add(A.quad(QK(K)), JK(K)), E2(K, kb, hkb, hK)) : {Nat.add(_, 1n) == Nat.add(A.quad(QK(K)), Nat.add(j, 1n)) : Nat}
  %Equal.sym(Nat, JK(K), j, ej) : {Nat.add(Nat.add(A.quad(QK(K)), _), 1n) == Nat.add(A.quad(QK(K)), Nat.add(j, 1n)) : Nat}
  F.nat__add_assoc(A.quad(QK(K)), j, 1n)

def G6(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat,
    +ej: {JK(K) == j : Nat}, +eb: {BKk(K) == b : Nat})
    -> {U32.to_nat(U32.shrn(K, 5n)) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(K, 5n)), Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))), E5(K, kb, hkb, hK)) :
    {_ == Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))) : Nat}
  %Equal.sym(Nat, JK(K), j, ej) : {Nat.add(QK(K), VD.s_rng(2n, Nat.add(_, VD.s_rng(3n, BKk(K))))) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))) : Nat}
  %Equal.sym(Nat, BKk(K), b, eb) : {Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, _)))) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))) : Nat}
  {==}

# ---- more structure ---------------------------------------------------------------------------

# put_words of a whole number of words: a copy (also for n = 0: NW(0) = 0).
law m32_mono:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(m32(a), m32(b)) == True{} : Bool}
def m32_mono(a, b, h):
  match a b:
    case 0n _: F.nat__zero_le(m32(b))
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(m32(1n+p), m32(0n)) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: m32_mono(p, q, h)

law len_btk:
  for +k: Nat
  for +xs: +List<Bool>
  for +h: {Nat.is_le(k, List.length(&2, Bool, xs)) == True{} : Bool}
  {List.length(&2, Bool, BK.btk(k, xs)) == k : Nat}
def len_btk(k, xs, h):
  match k xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({List.length(&2, Bool, BK.btk(1n+p, Nil{})) == 1n+p : Nat}, F.logic__false_true(h))
    case 1n+ +p Con{+b, +t}:
      %Equal.sym(Nat, List.length(&2, Bool, BK.btk(p, t)), p, len_btk(p, t, h)) : {1n+_ == 1n+p : Nat}
      {==}

law len_bitsof:
  for +ws: List<&2, U32>
  {List.length(&2, Bool, BK.bitsof(ws)) == m32(VB.len(ws)) : Nat}
def len_bitsof(ws):
  match ws:
    case Nil{}: {==}
    case Con{+x, +t}:
      %Equal.sym(Nat, List.length(&2, Bool, List.append(&2, Bool, BLf.wbits(x), BK.bitsof(t))), Nat.add(List.length(&2, Bool, BLf.wbits(x)), List.length(&2, Bool, BK.bitsof(t))),
          VBL.lenB_app(BLf.wbits(x), BK.bitsof(t))) : {_ == 32n+m32(VB.len(t)) : Nat}
      %Equal.sym(Nat, List.length(&2, Bool, BLf.wbits(x)), 32n, len_wbits(x)) : {Nat.add(_, List.length(&2, Bool, BK.bitsof(t))) == 32n+m32(VB.len(t)) : Nat}
      %Equal.sym(Nat, List.length(&2, Bool, BK.bitsof(t)), m32(VB.len(t)), len_bitsof(t)) : {Nat.add(32n, _) == 32n+m32(VB.len(t)) : Nat}
      {==}

def cq(+c: Nat, +q: Nat) -> {Nat.add(A.quad(q), c) == Nat.add(c, A.quad(q)) : Nat}: F.nat__add_comm(A.quad(q), c)

# U32.is_eq(x, 0) is False for x = 4 q + c, c >= 1.
def nz_of(+x: U32, +q: Nat, +c: Nat, +e: {U32.to_nat(x) == Nat.add(A.quad(q), 1n+c) : Nat}) -> {U32.is_eq(x, 0) == False{} : Bool}:
  %Equal.sym(Cmp, U32.cmp(x, 0), Nat.cmp(U32.to_nat(x), 0n), F.u32__u32_cmp(x, 0)) : {Cmp.is_eq(_) == False{} : Bool}
  %Equal.sym(Nat, U32.to_nat(x), Nat.add(A.quad(q), 1n+c), e) : {Cmp.is_eq(Nat.cmp(_, 0n)) == False{} : Bool}
  %Equal.sym(Nat, Nat.add(A.quad(q), 1n+c), 1n+Nat.add(A.quad(q), c), F.nat__add_succ(A.quad(q), c)) : {Cmp.is_eq(Nat.cmp(_, 0n)) == False{} : Bool}
  {==}

# ---- the numbers of K = 32 q + 8 j + b, with the closed facts of (j, b) -----------------------

def Fnb(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat, +c: Nat,
    +ej: {JK(K) == j : Nat}, +eb: {BKk(K) == b : Nat}, +ec: {Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))) == c : Nat})
    -> {U32.to_nat(O.bits_nbytes(K)) == Nat.add(A.quad(QK(K)), c) : Nat}:
  %ec : {U32.to_nat(O.bits_nbytes(K)) == Nat.add(A.quad(QK(K)), _) : Nat}
  G2(K, kb, hkb, hK, j, b, ej, eb)

# The byte count is at most K + 1.
def lnb(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +b: Nat, +eb: {BKk(K) == b : Nat},
    +hs3: {Nat.is_le(VD.s_rng(3n, Nat.add(b, 7n)), 1n) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(O.bits_nbytes(K)), 3n), O.pow2n(kb)) == True{} : Bool}:
  +e3 = Equal.trans(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))), Nat.add(AK(K), VD.s_rng(3n, Nat.add(b, 7n))), E3(K, kb, hkb, hK),
    Equal.cong(Nat, Nat, z => Nat.add(AK(K), VD.s_rng(3n, Nat.add(z, 7n))), BKk(K), b, eb))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(AK(K), 1n)) == True{} : Bool}, Nat.add(AK(K), VD.s_rng(3n, Nat.add(b, 7n))), U32.to_nat(O.bits_nbytes(K)),
    Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), VD.s_rng(3n, Nat.add(b, 7n))), e3), Order.add_left(AK(K), VD.s_rng(3n, Nat.add(b, 7n)), 1n, hs3))
  F.nat__le_trans(Nat.add(U32.to_nat(O.bits_nbytes(K)), 3n), Nat.add(U32.to_nat(K), 8n), O.pow2n(kb),
    F.nat__le_trans(Nat.add(U32.to_nat(O.bits_nbytes(K)), 3n), Nat.add(Nat.add(AK(K), 1n), 3n), Nat.add(U32.to_nat(K), 8n),
      Order.add_right(U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), 1n), 3n, h1),
      F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(U32.to_nat(K), 8n)) == True{} : Bool}, Nat.add(AK(K), 4n), Nat.add(Nat.add(AK(K), 1n), 3n),
        Equal.sym(Nat, Nat.add(Nat.add(AK(K), 1n), 3n), Nat.add(AK(K), 4n), F.nat__add_assoc(AK(K), 1n, 3n)),
        F.nat__le_trans(Nat.add(AK(K), 4n), Nat.add(U32.to_nat(K), 4n), Nat.add(U32.to_nat(K), 8n), Order.add_right(AK(K), U32.to_nat(K), 4n, lAK(K)), Order.add_left(U32.to_nat(K), 4n, 8n, {==})))),
    hK)

def lnb7(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +b: Nat, +eb: {BKk(K) == b : Nat},
    +hs3: {Nat.is_le(VD.s_rng(3n, Nat.add(b, 7n)), 1n) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(O.bits_nbytes(K)), 3n), Nat.add(U32.to_nat(K), 7n)) == True{} : Bool}:
  +e3 = Equal.trans(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))), Nat.add(AK(K), VD.s_rng(3n, Nat.add(b, 7n))), E3(K, kb, hkb, hK),
    Equal.cong(Nat, Nat, z => Nat.add(AK(K), VD.s_rng(3n, Nat.add(z, 7n))), BKk(K), b, eb))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(AK(K), 1n)) == True{} : Bool}, Nat.add(AK(K), VD.s_rng(3n, Nat.add(b, 7n))), U32.to_nat(O.bits_nbytes(K)),
    Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), VD.s_rng(3n, Nat.add(b, 7n))), e3), Order.add_left(AK(K), VD.s_rng(3n, Nat.add(b, 7n)), 1n, hs3))
  F.nat__le_trans(Nat.add(U32.to_nat(O.bits_nbytes(K)), 3n), Nat.add(U32.to_nat(K), 7n), Nat.add(U32.to_nat(K), 7n),
    F.nat__le_trans(Nat.add(U32.to_nat(O.bits_nbytes(K)), 3n), Nat.add(Nat.add(AK(K), 1n), 3n), Nat.add(U32.to_nat(K), 7n),
      Order.add_right(U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), 1n), 3n, h1),
      F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(U32.to_nat(K), 7n)) == True{} : Bool}, Nat.add(AK(K), 4n), Nat.add(Nat.add(AK(K), 1n), 3n),
        Equal.sym(Nat, Nat.add(Nat.add(AK(K), 1n), 3n), Nat.add(AK(K), 4n), F.nat__add_assoc(AK(K), 1n, 3n)),
        F.nat__le_trans(Nat.add(AK(K), 4n), Nat.add(U32.to_nat(K), 4n), Nat.add(U32.to_nat(K), 7n), Order.add_right(AK(K), U32.to_nat(K), 4n, lAK(K)), Order.add_left(U32.to_nat(K), 4n, 7n, {==})))),
    F.nat__le_refl(Nat.add(U32.to_nat(K), 7n)))

def ln4(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb))
    -> {Nat.is_le(Nat.add(U32.to_nat(U32.add(U32.shrn(K, 3n), 1)), 3n), O.pow2n(kb)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(U32.add(U32.shrn(K, 3n), 1)), Nat.add(AK(K), 1n), E4(K, kb, hkb, hK)) : {Nat.is_le(Nat.add(_, 3n), O.pow2n(kb)) == True{} : Bool}
  F.nat__le_trans(Nat.add(Nat.add(AK(K), 1n), 3n), Nat.add(U32.to_nat(K), 8n), O.pow2n(kb),
    F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(U32.to_nat(K), 8n)) == True{} : Bool}, Nat.add(AK(K), 4n), Nat.add(Nat.add(AK(K), 1n), 3n),
      Equal.sym(Nat, Nat.add(Nat.add(AK(K), 1n), 3n), Nat.add(AK(K), 4n), F.nat__add_assoc(AK(K), 1n, 3n)),
      F.nat__le_trans(Nat.add(AK(K), 4n), Nat.add(U32.to_nat(K), 4n), Nat.add(U32.to_nat(K), 8n), Order.add_right(AK(K), U32.to_nat(K), 4n, lAK(K)), Order.add_left(U32.to_nat(K), 4n, 8n, {==}))),
    hK)

def ln47(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb))
    -> {Nat.is_le(Nat.add(U32.to_nat(U32.add(U32.shrn(K, 3n), 1)), 3n), Nat.add(U32.to_nat(K), 7n)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(U32.add(U32.shrn(K, 3n), 1)), Nat.add(AK(K), 1n), E4(K, kb, hkb, hK)) : {Nat.is_le(Nat.add(_, 3n), Nat.add(U32.to_nat(K), 7n)) == True{} : Bool}
  F.nat__le_trans(Nat.add(Nat.add(AK(K), 1n), 3n), Nat.add(U32.to_nat(K), 7n), Nat.add(U32.to_nat(K), 7n),
    F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(U32.to_nat(K), 7n)) == True{} : Bool}, Nat.add(AK(K), 4n), Nat.add(Nat.add(AK(K), 1n), 3n),
      Equal.sym(Nat, Nat.add(Nat.add(AK(K), 1n), 3n), Nat.add(AK(K), 4n), F.nat__add_assoc(AK(K), 1n, 3n)),
      F.nat__le_trans(Nat.add(AK(K), 4n), Nat.add(U32.to_nat(K), 4n), Nat.add(U32.to_nat(K), 7n), Order.add_right(AK(K), U32.to_nat(K), 4n, lAK(K)), Order.add_left(U32.to_nat(K), 4n, 7n, {==}))),
    F.nat__le_refl(Nat.add(U32.to_nat(K), 7n)))

def FNWnb(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat, +c: Nat, +cw: Nat,
    +ej: {JK(K) == j : Nat}, +eb: {BKk(K) == b : Nat}, +ec: {Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))) == c : Nat},
    +hs3: {Nat.is_le(VD.s_rng(3n, Nat.add(b, 7n)), 1n) == True{} : Bool}, +ecw: {VD.s_rng(2n, Nat.add(c, 3n)) == cw : Nat})
    -> {VC.NW(O.bits_nbytes(K)) == Nat.add(QK(K), cw) : Nat}:
  %ecw : {VC.NW(O.bits_nbytes(K)) == Nat.add(QK(K), _) : Nat}
  NWq7(O.bits_nbytes(K), QK(K), c, K, kb, hkb, hK, lnb7(K, kb, hkb, hK, b, eb, hs3), Fnb(K, kb, hkb, hK, j, b, c, ej, eb, ec))

def FNWn(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +ej: {JK(K) == j : Nat},
    +e1: {VD.s_rng(2n, Nat.add(Nat.add(j, 1n), 3n)) == 1n : Nat})
    -> {VC.NW(U32.add(U32.shrn(K, 3n), 1)) == Nat.add(QK(K), 1n) : Nat}:
  %e1 : {VC.NW(U32.add(U32.shrn(K, 3n), 1)) == Nat.add(QK(K), _) : Nat}
  NWq7(U32.add(U32.shrn(K, 3n), 1), QK(K), Nat.add(j, 1n), K, kb, hkb, hK, ln47(K, kb, hkb, hK), G4(K, kb, hkb, hK, j, ej))

def Fsz(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat,
    +ej: {JK(K) == j : Nat}, +eb: {BKk(K) == b : Nat}, +e0: {VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b))) == 0n : Nat},
    +P: Nat, +h: {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), P) == True{} : Bool})
    -> {Nat.is_le(1n+QK(K), P) == True{} : Bool}:
  +e6 = Equal.trans(Nat, U32.to_nat(U32.shrn(K, 5n)), Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))), QK(K), G6(K, kb, hkb, hK, j, b, ej, eb),
    Equal.trans(Nat, Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))), Nat.add(QK(K), 0n), QK(K), Equal.cong(Nat, Nat, z => Nat.add(QK(K), z), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b))), 0n, e0), F.nat__add_zero(QK(K))))
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), P) == True{} : Bool}, U32.to_nat(U32.shrn(K, 5n)), QK(K), e6, h)
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(QK(K), 1n), 1n+QK(K), F.nat__add_comm(QK(K), 1n), h2)
