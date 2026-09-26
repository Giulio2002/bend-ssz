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


# ---- O.put_words of any length at a word-aligned position ------------------------------------

def NWm(+n: U32) -> Nat: U32.to_nat(U32.sub(VC.nwu(n), 1))

def PWM(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +n: U32, +P: Nat) -> F.array__Tree<U32>:
  VB.mone(NWm(n), 0n, P, dd, D, T)

# The tree put_words leaves: D, the whole words copied, or all but the last
# copied and the last OR-ed in.
def pwt(z: Bool, a: Bool, +dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +n: U32, +P: Nat) -> F.array__Tree<U32>:
  match z:
    case True{}: D
    case False{}:
      match a:
        case True{}: VB.mone(VC.NW(n), 0n, P, dd, D, T)
        case False{}: F.array__upd(U32, dd, PWM(dd, D, T, n, P), Nat.add(NWm(n), P), U32.or(VB.slot(PWM(dd, D, T, n, P), Nat.add(NWm(n), P)), VB.slot(T, NWm(n))))

def PWT(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +n: U32, +P: Nat) -> F.array__Tree<U32>:
  pwt(U32.is_eq(n, 0), U32.is_eq(U32.and(n, 3), 0), dd, D, T, n, P)

def pw_part(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hi: {Nat.is_le(Nat.add(NWm(n), 0n), VB.pw(dw)) == True{} : Bool}, +hj: {Nat.is_le(Nat.add(NWm(n), P), VB.pw(dd)) == True{} : Bool},
    +hT: {Nat.is_lt(NWm(n), VB.pw(dw)) == True{} : Bool}, +hD: {Nat.is_lt(Nat.add(NWm(n), P), VB.pw(dd)) == True{} : Bool},
    +ei: {U32.to_nat(U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1)) == Nat.add(NWm(n), P) : Nat})
    -> {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), O.acopy(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, pwt(False{}, False{}, dd, D, T, n, P)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  +M = PWM(dd, D, T, n, P)
  +pfM = VB.mone_perfect(NWm(n), 0n, P, dd, D, T, pfD)
  +i = U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1)
  %Equal.sym(Array<U32> & Array<U32>, O.acopy(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)),
      (F.array__thaw(U32, M), F.array__thaw(U32, T)),
      VB.acopy_ok(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), 0n, P, dd, dw, D, T, {==}, eP, hdd, hdw, hi, hj, pfD, pfT)) :
    {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), _) == (F.array__thaw(U32, pwt(False{}, False{}, dd, D, T, n, P)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, T), U32.sub(VC.nwu(n), 1)), (F.array__thaw(U32, T), VB.slot(T, NWm(n))),
      VB.get_n(dw, T, U32.sub(VC.nwu(n), 1), NWm(n), {==}, VB.lt32(dw, hdw), hT, pfT)) :
    {O.pw_al_or_w(VC.nwu(n), U32.shrn(p, 2n), F.array__thaw(U32, M), _) == (F.array__thaw(U32, pwt(False{}, False{}, dd, D, T, n, P)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, M), i), (F.array__thaw(U32, M), VB.slot(M, Nat.add(NWm(n), P))),
      VB.get_n(dd, M, i, Nat.add(NWm(n), P), ei, VB.lt32(dd, hdd), hD, pfM)) :
    {(O.or_at(i, VB.slot(T, NWm(n)), _), F.array__thaw(U32, T)) == (F.array__thaw(U32, pwt(False{}, False{}, dd, D, T, n, P)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, M), i, U32.or(VB.slot(M, Nat.add(NWm(n), P)), VB.slot(T, NWm(n)))),
      F.array__thaw(U32, F.array__upd(U32, dd, M, Nat.add(NWm(n), P), U32.or(VB.slot(M, Nat.add(NWm(n), P)), VB.slot(T, NWm(n))))),
      VB.set_n(dd, M, i, Nat.add(NWm(n), P), U32.or(VB.slot(M, Nat.add(NWm(n), P)), VB.slot(T, NWm(n))), ei, VB.lt32(dd, hdd), hD, pfM)) :
    {(_, F.array__thaw(U32, T)) == (F.array__thaw(U32, pwt(False{}, False{}, dd, D, T, n, P)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  {==}

def PF(+dd: Nat, +dw: Nat, +p: U32, +P: Nat, +n: U32) -> Data:
  DK.P2({Nat.is_le(Nat.add(NWm(n), 0n), VB.pw(dw)) == True{} : Bool}, DK.P2({Nat.is_le(Nat.add(NWm(n), P), VB.pw(dd)) == True{} : Bool},
  DK.P2({Nat.is_lt(NWm(n), VB.pw(dw)) == True{} : Bool}, DK.P2({Nat.is_lt(Nat.add(NWm(n), P), VB.pw(dd)) == True{} : Bool},
    {U32.to_nat(U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1)) == Nat.add(NWm(n), P) : Nat}))))

def pw_part2(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +pf: PF(dd, dw, p, P, n))
    -> {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), O.acopy(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, pwt(False{}, False{}, dd, D, T, n, P)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  (+hi, +r1) = pf
  (+hj, +r2) = r1
  (+hT, +r3) = r2
  (+hD, +ei) = r3
  pw_part(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, hi, hj, hT, hD, ei)

def pw_tail(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    part: {U32.is_eq(U32.and(n, 3), 0) == False{} : Bool} -> PF(dd, dw, p, P, n),
    +a: Bool, +ea: {U32.is_eq(U32.and(n, 3), 0) == a : Bool})
    -> {O.put_fin(n, O.pw_al_tail(a, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(a, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T))))
        == (F.array__thaw(U32, pwt(False{}, a, dd, D, T, n, P)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match a:
    case True{}:
      %Equal.sym(Array<U32> & Array<U32>, O.acopy(VC.nwu(n), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)),
          (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)),
          VB.acopy_ok(VC.nwu(n), 0, U32.shrn(p, 2n), 0n, P, dd, dw, D, T, {==}, eP, hdd, hdw, hsrc, hdst, pfD, pfT)) :
        {O.put_fin(n, O.pw_al_tail(True{}, VC.nwu(n), U32.shrn(p, 2n), _)) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}
    case False{}:
      %Equal.sym(Array<U32> & Array<U32>, O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), O.acopy(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T))),
          (F.array__thaw(U32, pwt(False{}, False{}, dd, D, T, n, P)), F.array__thaw(U32, T)), pw_part2(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, part(ea))) :
        {O.put_fin(n, _) == (F.array__thaw(U32, pwt(False{}, False{}, dd, D, T, n, P)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}

def pw_case2(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    part: {U32.is_eq(n, 0) == False{} : Bool} -> {U32.is_eq(U32.and(n, 3), 0) == False{} : Bool} -> PF(dd, dw, p, P, n),
    +z: Bool, +ez: {U32.is_eq(n, 0) == z : Bool}, +a: Bool, +ea: {U32.is_eq(U32.and(n, 3), 0) == a : Bool})
    -> {O.put_fin(n, O.pw_empty(z, U32.and(p, 3), n, VC.nwu(n), U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, pwt(z, a, dd, D, T, n, P)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match z:
    case True{}: {==}
    case False{}:
      %Equal.sym(U32, U32.and(p, 3), 0, hp3) :
        {O.put_fin(n, O.pw_go(U32.is_eq(_, 0), _, n, VC.nwu(n), U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
          == (F.array__thaw(U32, pwt(False{}, a, dd, D, T, n, P)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      %Equal.sym(Bool, U32.is_eq(U32.and(n, 3), 0), a, ea) :
        {O.put_fin(n, O.pw_al_tail(_, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(_, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T))))
          == (F.array__thaw(U32, pwt(False{}, a, dd, D, T, n, P)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      pw_tail(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, hsrc, hdst, part(ez), a, ea)

# O.put_words of n bytes at a word-aligned position p = 4 P.
def put_words2(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    part: {U32.is_eq(n, 0) == False{} : Bool} -> {U32.is_eq(U32.and(n, 3), 0) == False{} : Bool} -> PF(dd, dw, p, P, n))
    -> {O.put_words(F.array__thaw(U32, D), p, O.Words{F.array__thaw(U32, T), n}) == (F.array__thaw(U32, PWT(dd, D, T, n, P)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  pw_case2(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, hsrc, hdst, part, U32.is_eq(n, 0), {==}, U32.is_eq(U32.and(n, 3), 0), {==})


def pwtp(+z: Bool, +a: Bool, +dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +n: U32, +P: Nat, +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool})
    -> {F.array__perfect(U32, dd, pwt(z, a, dd, D, T, n, P)) == True{} : Bool}:
  match z a:
    case True{} _: pfD
    case False{} True{}: VB.mone_perfect(VC.NW(n), 0n, P, dd, D, T, pfD)
    case False{} False{}: F.array__upd_perfect(U32, dd, PWM(dd, D, T, n, P), Nat.add(NWm(n), P), U32.or(VB.slot(PWM(dd, D, T, n, P), Nat.add(NWm(n), P)), VB.slot(T, NWm(n))), VB.mone_perfect(NWm(n), 0n, P, dd, D, T, pfD))

def pwt_perfect(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +n: U32, +P: Nat, +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool})
    -> {F.array__perfect(U32, dd, PWT(dd, D, T, n, P)) == True{} : Bool}:
  pwtp(U32.is_eq(n, 0), U32.is_eq(U32.and(n, 3), 0), dd, D, T, n, P, pfD)

# ---- the bit list writer ---------------------------------------------------------------------

def PD(+p: U32, +K: U32) -> U32: U32.add(p, U32.shrn(K, 3n))
def DMK(+p: U32, +K: U32) -> U32: O.shl_bytes(U32.and(MF.shl_by(1, U32.and(K, 7)), 255), U32.and(PD(p, K), 3))
def OUTB(+dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +K: U32, +QD: Nat) -> F.array__Tree<U32>:
  F.array__upd(U32, dd, PWT(dd, D, T, O.bits_nbytes(K), P), QD, U32.or(VB.slot(PWT(dd, D, T, O.bits_nbytes(K), P), QD), DMK(p, K)))

# O.put_bits: the bytes, then the delimiter OR-ed into word QD.
def put_bits2(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +K: U32, +QD: Nat,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(O.bits_nbytes(K)), P), VB.pw(dd)) == True{} : Bool},
    part: {U32.is_eq(O.bits_nbytes(K), 0) == False{} : Bool} -> {U32.is_eq(U32.and(O.bits_nbytes(K), 3), 0) == False{} : Bool} -> PF(dd, dw, p, P, O.bits_nbytes(K)),
    +eQ: {U32.to_nat(U32.shrn(PD(p, K), 2n)) == QD : Nat}, +hQ: {Nat.is_lt(QD, VB.pw(dd)) == True{} : Bool})
    -> {O.put_bits(F.array__thaw(U32, D), p, O.Bits{F.array__thaw(U32, T), K}) == (F.array__thaw(U32, OUTB(dd, D, T, p, P, K, QD)), O.Bits{F.array__thaw(U32, T), K}) : Array<U32> & O.Bits}:
  +W1 = PWT(dd, D, T, O.bits_nbytes(K), P)
  +pf1 = pwt_perfect(dd, D, T, O.bits_nbytes(K), P, pfD)
  %Equal.sym(Array<U32> & O.Words, O.put_words(F.array__thaw(U32, D), p, O.Words{F.array__thaw(U32, T), O.bits_nbytes(K)}), (F.array__thaw(U32, W1), O.Words{F.array__thaw(U32, T), O.bits_nbytes(K)}),
      put_words2(dd, dw, D, T, p, P, O.bits_nbytes(K), pfD, pfT, hdd, hdw, hp3, eP, hsrc, hdst, part)) :
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

law or0:
  for +x: U32
  {U32.or(0, x) == x : U32}
def or0(x):
  match x:
    case U32{+w}: Equal.cong(Word(32n), U32, v => U32{v}, Word.or(32n, Word.zero(32n), w), w, WSp.or_zero_left(32n, w))

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

def Epd(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb)) -> {U32.to_nat(PDK(K)) == AK(K) : Nat}:
  VD.s_add_nat(0, U32.shrn(K, 3n), kb, hkb, F.nat__le_trans(AK(K), U32.to_nat(K), O.pow2n(kb), lAK(K), lK(K, kb, hK)))

def E2(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb)) -> {AK(K) == Nat.add(A.quad(QK(K)), JK(K)) : Nat}:
  %Epd(K, kb, hkb, hK) : {_ == Nat.add(A.quad(QK(K)), JK(K)) : Nat}
  VC.split4(PDK(K))

# The byte count ceil(K / 8).
def E3(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb))
    -> {U32.to_nat(O.bits_nbytes(K)) == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(U32.add(K, 7), 3n)), VD.s_rng(3n, U32.to_nat(U32.add(K, 7))), VD.shrk(3n, U32.add(K, 7))) : {_ == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(K, 7)), Nat.add(U32.to_nat(K), 7n), VD.s_add_nat(K, 7, kb, hkb, F.nat__le_trans(Nat.add(U32.to_nat(K), 7n), Nat.add(U32.to_nat(K), 8n), O.pow2n(kb), Order.add_left(U32.to_nat(K), 7n, 8n, {==}), hK))) :
    {VD.s_rng(3n, _) == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}
  %Equal.sym(Nat, U32.to_nat(K), Nat.add(VS.x8(AK(K)), BKk(K)), E1(K)) : {VD.s_rng(3n, Nat.add(_, 7n)) == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(VS.x8(AK(K)), BKk(K)), 7n), Nat.add(VS.x8(AK(K)), Nat.add(BKk(K), 7n)), F.nat__add_assoc(VS.x8(AK(K)), BKk(K), 7n)) : {VD.s_rng(3n, _) == Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))) : Nat}
  r3a(AK(K), Nat.add(BKk(K), 7n))

# The output size K / 8 + 1.
def E4(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb))
    -> {U32.to_nat(U32.add(U32.shrn(K, 3n), 1)) == Nat.add(AK(K), 1n) : Nat}:
  VD.s_add_nat(U32.shrn(K, 3n), 1, kb, hkb,
    F.nat__le_trans(Nat.add(AK(K), 1n), Nat.add(U32.to_nat(K), 8n), O.pow2n(kb), F.nat__le_trans(Nat.add(AK(K), 1n), Nat.add(U32.to_nat(K), 1n), Nat.add(U32.to_nat(K), 8n), Order.add_right(AK(K), U32.to_nat(K), 1n, lAK(K)), Order.add_left(U32.to_nat(K), 1n, 8n, {==})), hK))

# The word of the bit K: K / 32.
def E5(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb))
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
def Ka(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat,
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

# ceil(L / 4) for L = 4 q + c.
def NWq(+L: U32, +q: Nat, +c: Nat, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(L), 3n), O.pow2n(kb)) == True{} : Bool}, +e: {U32.to_nat(L) == Nat.add(A.quad(q), c) : Nat})
    -> {VC.NW(L) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}:
  %Equal.sym(Nat, VC.NW(L), VD.s_rng(2n, Nat.add(U32.to_nat(L), 3n)), NWE(L, kb, hkb, h)) : {_ == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  %Equal.sym(Nat, U32.to_nat(L), Nat.add(A.quad(q), c), e) : {VD.s_rng(2n, Nat.add(_, 3n)) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), c), 3n), Nat.add(A.quad(q), Nat.add(c, 3n)), F.nat__add_assoc(A.quad(q), c, 3n)) : {VD.s_rng(2n, _) == Nat.add(q, VD.s_rng(2n, Nat.add(c, 3n))) : Nat}
  r2a(q, Nat.add(c, 3n))

# The byte count, for K = 32 q + 8 j + b.
def G2(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat,
    +ej: {JK(K) == j : Nat}, +eb: {BKk(K) == b : Nat})
    -> {U32.to_nat(O.bits_nbytes(K)) == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(AK(K), VD.s_rng(3n, Nat.add(BKk(K), 7n))), E3(K, kb, hkb, hK)) :
    {_ == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}
  %Equal.sym(Nat, AK(K), Nat.add(A.quad(QK(K)), JK(K)), E2(K, kb, hkb, hK)) : {Nat.add(_, VD.s_rng(3n, Nat.add(BKk(K), 7n))) == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}
  %Equal.sym(Nat, JK(K), j, ej) : {Nat.add(Nat.add(A.quad(QK(K)), _), VD.s_rng(3n, Nat.add(BKk(K), 7n))) == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}
  %Equal.sym(Nat, BKk(K), b, eb) : {Nat.add(Nat.add(A.quad(QK(K)), j), VD.s_rng(3n, Nat.add(_, 7n))) == Nat.add(A.quad(QK(K)), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))) : Nat}
  F.nat__add_assoc(A.quad(QK(K)), j, VD.s_rng(3n, Nat.add(b, 7n)))

def G4(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +ej: {JK(K) == j : Nat})
    -> {U32.to_nat(U32.add(U32.shrn(K, 3n), 1)) == Nat.add(A.quad(QK(K)), Nat.add(j, 1n)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.add(U32.shrn(K, 3n), 1)), Nat.add(AK(K), 1n), E4(K, kb, hkb, hK)) : {_ == Nat.add(A.quad(QK(K)), Nat.add(j, 1n)) : Nat}
  %Equal.sym(Nat, AK(K), Nat.add(A.quad(QK(K)), JK(K)), E2(K, kb, hkb, hK)) : {Nat.add(_, 1n) == Nat.add(A.quad(QK(K)), Nat.add(j, 1n)) : Nat}
  %Equal.sym(Nat, JK(K), j, ej) : {Nat.add(Nat.add(A.quad(QK(K)), _), 1n) == Nat.add(A.quad(QK(K)), Nat.add(j, 1n)) : Nat}
  F.nat__add_assoc(A.quad(QK(K)), j, 1n)

def G6(+K: U32, +kb: Nat, +hkb: {Nat.is_lt(kb, 32n) == True{} : Bool}, +hK: HK(K, kb), +j: Nat, +b: Nat,
    +ej: {JK(K) == j : Nat}, +eb: {BKk(K) == b : Nat})
    -> {U32.to_nat(U32.shrn(K, 5n)) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(K, 5n)), Nat.add(QK(K), VD.s_rng(2n, Nat.add(JK(K), VD.s_rng(3n, BKk(K))))), E5(K, kb, hkb, hK)) :
    {_ == Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))) : Nat}
  %Equal.sym(Nat, JK(K), j, ej) : {Nat.add(QK(K), VD.s_rng(2n, Nat.add(_, VD.s_rng(3n, BKk(K))))) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))) : Nat}
  %Equal.sym(Nat, BKk(K), b, eb) : {Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, _)))) == Nat.add(QK(K), VD.s_rng(2n, Nat.add(j, VD.s_rng(3n, b)))) : Nat}
  {==}

# ---- more structure ---------------------------------------------------------------------------

# put_words of a whole number of words: a copy (also for n = 0: NW(0) = 0).
def pwt_zt(+z: Bool, +dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +n: U32, +P: Nat, +ez: {U32.is_eq(n, 0) == z : Bool})
    -> {pwt(z, True{}, dd, D, T, n, P) == VB.mone(VC.NW(n), 0n, P, dd, D, T) : F.array__Tree<U32>}:
  match z:
    case False{}: {==}
    case True{}:
      %Equal.sym(U32, n, 0, F.u32alg__eq_of(n, 0, ez)) : {D == VB.mone(VC.NW(_), 0n, P, dd, D, T) : F.array__Tree<U32>}
      {==}

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
