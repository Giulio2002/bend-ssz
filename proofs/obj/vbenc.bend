import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vdepth.bend as VD
import ./vcopy.bend as VC
import ./vfix.bend as VF
import ./venc.bend as VE
import ./vbytes.bend as VY
import ./spec_fixed.bend as FX

# The encoder's runtime pieces for byte lists at any length (codegen/var_bytes.py):
# the aligned bulk write O.put_words of a partial last word (put_words_any), the
# storage check of a byte list (words_ok_b), and small word facts.

# ---- words -----------------------------------------------------------------------------------

law zero_or_w:
  for +n: Nat
  for +w: Word(n)
  {Word.or(n, Word.zero(n), w) == w : Word(n)}
def zero_or_w(n, w):
  match n w:
    case 0n WNil{}: {==}
    case 1n+ +p WCon{+b, +t}:
      %Equal.sym(Word(p), Word.or(p, Word.zero(p), t), t, zero_or_w(p, t)) : {WCon{b, _} == WCon{b, t} : Word(1n+p)}
      {==}

def zero_or(+x: U32) -> {U32.or(0, x) == x : U32}:
  match x:
    case U32{+w}: Equal.cong(Word(32n), U32, v => U32{v}, Word.or(32n, Word.zero(32n), w), w, zero_or_w(32n, w))

def ones(n: Nat) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+p: WCon{True{}, ones(p)}

law and_ones:
  for +n: Nat
  for +w: Word(n)
  {Word.and(n, w, ones(n)) == w : Word(n)}
def and_ones(n, w):
  match n w:
    case 0n WNil{}: {==}
    case 1n+ +p WCon{False{}, +t}:
      %Equal.sym(Word(p), Word.and(p, t, ones(p)), t, and_ones(p, t)) : {WCon{False{}, _} == WCon{False{}, t} : Word(1n+p)}
      {==}
    case 1n+ +p WCon{True{}, +t}:
      %Equal.sym(Word(p), Word.and(p, t, ones(p)), t, and_ones(p, t)) : {WCon{True{}, _} == WCon{True{}, t} : Word(1n+p)}
      {==}

# A value below 2^k (k <= 31) keeps its bits under the size mask 0x7fffffff.
def and31(+x: U32, +k: Nat, +hk: {Nat.is_le(k, 31n) == True{} : Bool}, +h: {Nat.is_lt(U32.to_nat(x), F.spec_common__pow2(k)) == True{} : Bool}) -> {U32.and(x, 2147483647) == x : U32}:
  +a = VE.winit(31n, VE.bits32(x))
  %Equal.sym(U32, x, U32{Word.shr.pad(31n, a)}, VE.small_pad(x, k, hk, h)) : {U32.and(_, 2147483647) == _ : U32}
  %VY.pad_and(31n, a, ones(31n)) :
    {U32{_} == U32{Word.shr.pad(31n, a)} : U32}
  %Equal.sym(Word(31n), Word.and(31n, a, ones(31n)), a, and_ones(31n, a)) : {U32{Word.shr.pad(31n, _)} == U32{Word.shr.pad(31n, a)} : U32}
  {==}

# ---- slots -----------------------------------------------------------------------------------

def slot_zt(+d: Nat, +k: Nat) -> {VB.slot(VC.ZT(d), k) == 0 : U32}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VC.ZT(d)), F.spec_common__replicate(U32, F.spec_common__pow2(d), 0), F.array__trep_slots(U32, d, 0)) :
    {F.flat__nthc(_, k) == 0 : U32}
  F.flat__nthc_rep(F.spec_common__pow2(d), k)

law lt_ne:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_lt(a, b) == True{} : Bool}
  {Nat.is_eq(a, b) == False{} : Bool}

def lt_ne(a, b, h):
  match a b:
    case 0n 0n: Empty.absurd({Nat.is_eq(0n, 0n) == False{} : Bool}, F.logic__false_true(h))
    case 0n 1n+ +q: {==}
    case 1n+ +p 0n: {==}
    case 1n+ +p 1n+ +q: lt_ne(p, q, h)

# A run of word writes below k leaves slot k.
law slot_updv_hi:
  for +V: List<&2, U32>
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +j: Nat
  for +k: Nat
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hb: {Nat.is_le(Nat.add(F.spec_common__length(U32, V), j), VB.pw(dd)) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(F.spec_common__length(U32, V), j), k) == True{} : Bool}
  {VB.slot(VF.updv(V, dd, D, j), k) == VB.slot(D, k) : U32}
def slot_updv_hi(V, dd, D, j, k, pf, hb, h):
  match V:
    case Nil{}: {==}
    case Con{+v, +t}:
      +hb1 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, 1n+Nat.add(F.spec_common__length(U32, t), j), Nat.add(F.spec_common__length(U32, t), 1n+j), Equal.sym(Nat, Nat.add(F.spec_common__length(U32, t), 1n+j), 1n+Nat.add(F.spec_common__length(U32, t), j), F.nat__add_succ(F.spec_common__length(U32, t), j)), hb)
      +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, k) == True{} : Bool}, 1n+Nat.add(F.spec_common__length(U32, t), j), Nat.add(F.spec_common__length(U32, t), 1n+j), Equal.sym(Nat, Nat.add(F.spec_common__length(U32, t), 1n+j), 1n+Nat.add(F.spec_common__length(U32, t), j), F.nat__add_succ(F.spec_common__length(U32, t), j)), h)
      +hj = F.nat__le_lt_trans(j, Nat.add(F.spec_common__length(U32, t), j), VB.pw(dd), Order.left_below_sum(F.spec_common__length(U32, t), j), VY.succ_le_lt(Nat.add(F.spec_common__length(U32, t), j), VB.pw(dd), hb))
      +hjk = F.nat__le_lt_trans(j, Nat.add(F.spec_common__length(U32, t), j), k, Order.left_below_sum(F.spec_common__length(U32, t), j), VY.succ_le_lt(Nat.add(F.spec_common__length(U32, t), j), k, h))
      %Equal.sym(U32, VB.slot(VF.updv(t, dd, F.array__upd(U32, dd, D, j, v), 1n+j), k), VB.slot(F.array__upd(U32, dd, D, j, v), k),
          slot_updv_hi(t, dd, F.array__upd(U32, dd, D, j, v), 1n+j, k, F.array__upd_perfect(U32, dd, D, j, v, pf), hb1, h1)) :
        {_ == VB.slot(D, k) : U32}
      %Equal.sym(List<&2, U32>, F.array__slots(U32, F.array__upd(U32, dd, D, j, v)), F.spec_common__update(U32, F.array__slots(U32, D), j, v), F.array__upd_slots(U32, dd, D, j, v, hj, pf)) :
        {F.flat__nthc(_, k) == VB.slot(D, k) : U32}
      F.flat__nthc_other(F.array__slots(U32, D), j, k, v, lt_ne(j, k, hjk))

# A run of single-word copies below k leaves slot k.
law slot_mone_hi:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +k: Nat
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hb: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(n, j), k) == True{} : Bool}
  {VB.slot(VB.mone(n, i, j, dd, D, S), k) == VB.slot(D, k) : U32}
def slot_mone_hi(n, i, j, dd, D, S, k, pf, hb, h):
  match n:
    case 0n: {==}
    case 1n+ +m:
      +v = VB.slot(S, i)
      +hb1 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, 1n+Nat.add(m, j), Nat.add(m, 1n+j), Equal.sym(Nat, Nat.add(m, 1n+j), 1n+Nat.add(m, j), F.nat__add_succ(m, j)), hb)
      +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, k) == True{} : Bool}, 1n+Nat.add(m, j), Nat.add(m, 1n+j), Equal.sym(Nat, Nat.add(m, 1n+j), 1n+Nat.add(m, j), F.nat__add_succ(m, j)), h)
      +hj = F.nat__le_lt_trans(j, Nat.add(m, j), VB.pw(dd), Order.left_below_sum(m, j), VY.succ_le_lt(Nat.add(m, j), VB.pw(dd), hb))
      +hjk = F.nat__le_lt_trans(j, Nat.add(m, j), k, Order.left_below_sum(m, j), VY.succ_le_lt(Nat.add(m, j), k, h))
      %Equal.sym(U32, VB.slot(VB.mone(m, 1n+i, 1n+j, dd, F.array__upd(U32, dd, D, j, v), S), k), VB.slot(F.array__upd(U32, dd, D, j, v), k),
          slot_mone_hi(m, 1n+i, 1n+j, dd, F.array__upd(U32, dd, D, j, v), S, k, F.array__upd_perfect(U32, dd, D, j, v, pf), hb1, h1)) :
        {_ == VB.slot(D, k) : U32}
      %Equal.sym(List<&2, U32>, F.array__slots(U32, F.array__upd(U32, dd, D, j, v)), F.spec_common__update(U32, F.array__slots(U32, D), j, v), F.array__upd_slots(U32, dd, D, j, v, hj, pf)) :
        {F.flat__nthc(_, k) == VB.slot(D, k) : U32}
      F.flat__nthc_other(F.array__slots(U32, D), j, k, v, lt_ne(j, k, hjk))

# ---- the aligned bulk write of any byte length -------------------------------------------------

# (q + nw - 1): the index of the last word written, P + KW.
def e_lastU(+p: U32, +P: Nat, +n: U32, +dd: Nat, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hb: {U32.is_eq(VY.RM(n), 0) == False{} : Bool}, +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1)) == Nat.add(VY.QL(n), P) : Nat}:
  +enw = VY.nw_qU(n, hy, hb)
  +hsum = F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(F.u32__pow2u(dd))) == True{} : Bool}, Nat.add(VC.NW(n), P), Nat.add(P, VC.NW(n)), F.nat__add_comm(VC.NW(n), P),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(n), P), z) == True{} : Bool}, VB.pw(dd), U32.to_nat(F.u32__pow2u(dd)), Equal.sym(Nat, U32.to_nat(F.u32__pow2u(dd)), VB.pw(dd), F.u32__pow2u_value(dd, VB.lt32(dd, hdd))), hdst))
  +ea = Equal.trans(Nat, U32.to_nat(U32.add(U32.shrn(p, 2n), VC.nwu(n))), Nat.add(U32.to_nat(U32.shrn(p, 2n)), VC.NW(n)), Nat.add(P, 1n+VY.QL(n)),
    A.add_le(U32.shrn(p, 2n), VC.nwu(n), F.u32__pow2u(dd), F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, VC.NW(n)), U32.to_nat(F.u32__pow2u(dd))) == True{} : Bool}, P, U32.to_nat(U32.shrn(p, 2n)), Equal.sym(Nat, U32.to_nat(U32.shrn(p, 2n)), P, eP), hsum)),
    Equal.trans(Nat, Nat.add(U32.to_nat(U32.shrn(p, 2n)), VC.NW(n)), Nat.add(P, VC.NW(n)), Nat.add(P, 1n+VY.QL(n)),
      Equal.cong(Nat, Nat, z => Nat.add(z, VC.NW(n)), U32.to_nat(U32.shrn(p, 2n)), P, eP),
      Equal.cong(Nat, Nat, z => Nat.add(P, z), VC.NW(n), 1n+VY.QL(n), enw)))
  +e1 = Equal.trans(Nat, Nat.add(P, 1n+VY.QL(n)), 1n+Nat.add(P, VY.QL(n)), 1n+Nat.add(VY.QL(n), P), F.nat__add_succ(P, VY.QL(n)),
    Equal.cong(Nat, Nat, z => 1n+z, Nat.add(P, VY.QL(n)), Nat.add(VY.QL(n), P), F.nat__add_comm(P, VY.QL(n))))
  +ex = Equal.trans(Nat, U32.to_nat(U32.add(U32.shrn(p, 2n), VC.nwu(n))), Nat.add(P, 1n+VY.QL(n)), 1n+Nat.add(VY.QL(n), P), ea, e1)
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+Nat.add(VY.QL(n), P), U32.to_nat(U32.add(U32.shrn(p, 2n), VC.nwu(n))), Equal.sym(Nat, U32.to_nat(U32.add(U32.shrn(p, 2n), VC.nwu(n))), 1n+Nat.add(VY.QL(n), P), ex), Order.zero_le(Nat.add(VY.QL(n), P)))
  %Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1)), Nat.sub(U32.to_nat(U32.add(U32.shrn(p, 2n), VC.nwu(n))), 1n), F.u32__sub_nat(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1, h1)) :
    {_ == Nat.add(VY.QL(n), P) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.add(U32.shrn(p, 2n), VC.nwu(n))), 1n+Nat.add(VY.QL(n), P), ex) : {Nat.sub(_, 1n) == Nat.add(VY.QL(n), P) : Nat}
  F.nat__sub_zero(Nat.add(VY.QL(n), P))

def e_last(+p: U32, +P: Nat, +n: U32, +dd: Nat, +k: Nat, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hb: {U32.is_eq(VY.RM(n), 0) == False{} : Bool}, +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1)) == Nat.add(VY.QL(n), P) : Nat}:
  e_lastU(p, P, n, dd, eP, VC.hyU(n, k, hk, hy), hb, hdd, hdst)

def pw_partU(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hz: {VB.slot(D, Nat.add(VY.QL(n), P)) == 0 : U32}, +hb: {U32.is_eq(VY.RM(n), 0) == False{} : Bool})
    -> {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(False{}, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  +Q = VY.QL(n)
  +ekw = VY.kw_qU(n, hy, hb)
  +enw = VY.nw_qU(n, hy, hb)
  +hQ1 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, Nat.add(VC.NW(n), 0n), 1n+Nat.add(Q, 0n), Equal.cong(Nat, Nat, z => Nat.add(z, 0n), VC.NW(n), 1n+Q, enw), hsrc)
  +hQ2 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), P), 1n+Nat.add(Q, P), Equal.cong(Nat, Nat, z => Nat.add(z, P), VC.NW(n), 1n+Q, enw), hdst)
  +M1 = VB.mone(Q, 0n, P, dd, D, T)
  +pf1 = VB.mone_perfect(Q, 0n, P, dd, D, T, pfD)
  +ecp = Equal.trans(Nat, U32.to_nat(U32.sub(VC.nwu(n), 1)), VY.KW(n), Q, {==}, ekw)
  +hi0 = VY.succ_le_lt(Nat.add(Q, 0n), VB.pw(dw), hQ1)
  +hiP = VY.succ_le_lt(Nat.add(Q, P), VB.pw(dd), hQ2)
  +eL = e_lastU(p, P, n, dd, eP, hy, hb, hdd, hdst)
  %Equal.sym(Array<U32> & Array<U32>, O.acopy(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)),
      (F.array__thaw(U32, VB.mone(U32.to_nat(U32.sub(VC.nwu(n), 1)), 0n, P, dd, D, T)), F.array__thaw(U32, T)),
      VB.acopy_ok(U32.sub(VC.nwu(n), 1), 0, U32.shrn(p, 2n), 0n, P, dd, dw, D, T, {==}, eP, hdd, hdw,
        F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 0n), VB.pw(dw)) == True{} : Bool}, Q, U32.to_nat(U32.sub(VC.nwu(n), 1)), Equal.sym(Nat, U32.to_nat(U32.sub(VC.nwu(n), 1)), Q, ecp), F.nat__lt_le(Nat.add(Q, 0n), VB.pw(dw), hi0)),
        F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, P), VB.pw(dd)) == True{} : Bool}, Q, U32.to_nat(U32.sub(VC.nwu(n), 1)), Equal.sym(Nat, U32.to_nat(U32.sub(VC.nwu(n), 1)), Q, ecp), F.nat__lt_le(Nat.add(Q, P), VB.pw(dd), hiP)),
        pfD, pfT)) :
    {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), _) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Nat, U32.to_nat(U32.sub(VC.nwu(n), 1)), Q, ecp) :
    {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), (F.array__thaw(U32, VB.mone(_, 0n, P, dd, D, T)), F.array__thaw(U32, T))) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, T), U32.sub(VC.nwu(n), 1)), (F.array__thaw(U32, T), VB.slot(T, Q)),
      VB.get_n(dw, T, U32.sub(VC.nwu(n), 1), Q, ecp, VB.lt32(dw, hdw), F.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dw)) == True{} : Bool}, Nat.add(Q, 0n), Q, F.nat__add_zero(Q), hi0), pfT)) :
    {O.pw_al_or_w(VC.nwu(n), U32.shrn(p, 2n), F.array__thaw(U32, M1), _) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, M1), U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1)), (F.array__thaw(U32, M1), VB.slot(M1, Nat.add(Q, P))),
      VB.get_n(dd, M1, U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1), Nat.add(Q, P), eL, VB.lt32(dd, hdd), hiP, pf1)) :
    {(O.or_at(U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1), VB.slot(T, Q), _), F.array__thaw(U32, T)) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(U32, VB.slot(M1, Nat.add(Q, P)), 0, Equal.trans(U32, VB.slot(M1, Nat.add(Q, P)), VB.slot(D, Nat.add(Q, P)), 0, slot_mone_hi(Q, 0n, P, dd, D, T, Nat.add(Q, P), pfD, F.nat__lt_le(Nat.add(Q, P), VB.pw(dd), hiP), F.nat__le_refl(Nat.add(Q, P))), hz)) :
    {(Array.set(U32, F.array__thaw(U32, M1), U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1), U32.or(_, VB.slot(T, Q))), F.array__thaw(U32, T)) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(U32, U32.or(0, VB.slot(T, Q)), VB.slot(T, Q), zero_or(VB.slot(T, Q))) :
    {(Array.set(U32, F.array__thaw(U32, M1), U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1), _), F.array__thaw(U32, T)) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32>, Array.set(U32, F.array__thaw(U32, M1), U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1), VB.slot(T, Q)), F.array__thaw(U32, F.array__upd(U32, dd, M1, Nat.add(Q, P), VB.slot(T, Q))),
      VB.set_n(dd, M1, U32.sub(U32.add(U32.shrn(p, 2n), VC.nwu(n)), 1), Nat.add(Q, P), VB.slot(T, Q), eL, VB.lt32(dd, hdd), hiP, pf1)) :
    {(_, F.array__thaw(U32, T)) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Nat, VC.NW(n), 1n+Q, enw) :
    {(F.array__thaw(U32, F.array__upd(U32, dd, M1, Nat.add(Q, P), VB.slot(T, Q))), F.array__thaw(U32, T)) == (F.array__thaw(U32, VB.mone(_, 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Nat, 1n+Q, Nat.add(Q, 1n), Equal.trans(Nat, 1n+Q, 1n+Nat.add(Q, 0n), Nat.add(Q, 1n), Equal.cong(Nat, Nat, z => 1n+z, Q, Nat.add(Q, 0n), Equal.sym(Nat, Nat.add(Q, 0n), Q, F.nat__add_zero(Q))), Equal.sym(Nat, Nat.add(Q, 1n), 1n+Nat.add(Q, 0n), F.nat__add_succ(Q, 0n)))) :
    {(F.array__thaw(U32, F.array__upd(U32, dd, M1, Nat.add(Q, P), VB.slot(T, Q))), F.array__thaw(U32, T)) == (F.array__thaw(U32, VB.mone(_, 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %VB.mone_add(Q, 1n, 0n, P, dd, D, T) :
    {(F.array__thaw(U32, F.array__upd(U32, dd, M1, Nat.add(Q, P), VB.slot(T, Q))), F.array__thaw(U32, T)) == (F.array__thaw(U32, _), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  %Equal.sym(Nat, Nat.add(Q, 0n), Q, F.nat__add_zero(Q)) :
    {(F.array__thaw(U32, F.array__upd(U32, dd, M1, Nat.add(Q, P), VB.slot(T, Q))), F.array__thaw(U32, T)) == (F.array__thaw(U32, VB.mone(1n, _, Nat.add(Q, P), dd, M1, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}
  {==}

def pw_part(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32, +k: Nat,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hz: {VB.slot(D, Nat.add(VY.QL(n), P)) == 0 : U32}, +hb: {U32.is_eq(VY.RM(n), 0) == False{} : Bool})
    -> {O.pw_al_tail(False{}, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(False{}, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  pw_partU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, hz, hb)

def pwa_caseU(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hz: {VB.slot(D, Nat.add(VY.QL(n), P)) == 0 : U32}, +b: Bool, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {O.pw_al_tail(b, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(b, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  match b:
    case True{}: VB.acopy_ok(VC.nwu(n), 0, U32.shrn(p, 2n), 0n, P, dd, dw, D, T, {==}, eP, hdd, hdw, hsrc, hdst, pfD, pfT)
    case False{}: pw_partU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, hy, hsrc, hdst, hz, eb)

def pwa_case(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32, +k: Nat,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hz: {VB.slot(D, Nat.add(VY.QL(n), P)) == 0 : U32}, +b: Bool, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {O.pw_al_tail(b, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(b, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  pwa_caseU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, hz, b, eb)

def pwn_caseU(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hz: {VB.slot(D, Nat.add(VY.QL(n), P)) == 0 : U32}, +z: Bool, +ez: {U32.is_eq(n, 0) == z : Bool})
    -> {O.put_fin(n, O.pw_empty(z, U32.and(p, 3), n, VC.nwu(n), U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match z:
    case True{}:
      %Equal.sym(U32, n, 0, F.u32alg__eq_of(n, 0, ez)) :
        {(F.array__thaw(U32, D), O.Words{F.array__thaw(U32, T), n}) == (F.array__thaw(U32, VB.mone(VC.NW(_), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}
    case False{}:
      %Equal.sym(U32, U32.and(p, 3), 0, hp3) :
        {O.put_fin(n, O.pw_go(U32.is_eq(_, 0), _, n, VC.nwu(n), U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
          == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      %Equal.sym(Array<U32> & Array<U32>, O.pw_aligned(n, VC.nwu(n), U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)),
          (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)),
          pwa_caseU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, hy, hsrc, hdst, hz, U32.is_eq(VY.RM(n), 0), {==})) :
        {O.put_fin(n, _) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}

def pwn_case(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32, +k: Nat,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hz: {VB.slot(D, Nat.add(VY.QL(n), P)) == 0 : U32}, +z: Bool, +ez: {U32.is_eq(n, 0) == z : Bool})
    -> {O.put_fin(n, O.pw_empty(z, U32.and(p, 3), n, VC.nwu(n), U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)))
        == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  pwn_caseU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, hz, z, ez)

# O.put_words of any byte length at a word-aligned position copies the words,
# when the destination's word under the partial last word is zero.
law put_words_anyU:
  for +dd: Nat
  for +dw: Nat
  for +D: F.array__Tree<U32>
  for +T: F.array__Tree<U32>
  for +p: U32
  for +P: Nat
  for +n: U32
  for +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}
  for +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}
  for +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}
  for +hp3: {U32.and(p, 3) == 0 : U32}
  for +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}
  for +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}
  for +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool}
  for +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool}
  for +hz: {VB.slot(D, Nat.add(VY.QL(n), P)) == 0 : U32}
  {O.put_words(F.array__thaw(U32, D), p, O.Words{F.array__thaw(U32, T), n}) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
def put_words_anyU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, hy, hsrc, hdst, hz):
  pwn_caseU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, hy, hsrc, hdst, hz, U32.is_eq(n, 0), {==})

law put_words_any:
  for +dd: Nat
  for +dw: Nat
  for +D: F.array__Tree<U32>
  for +T: F.array__Tree<U32>
  for +p: U32
  for +P: Nat
  for +n: U32
  for +k: Nat
  for +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}
  for +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}
  for +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}
  for +hp3: {U32.and(p, 3) == 0 : U32}
  for +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}
  for +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool}
  for +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool}
  for +hz: {VB.slot(D, Nat.add(VY.QL(n), P)) == 0 : U32}
  {O.put_words(F.array__thaw(U32, D), p, O.Words{F.array__thaw(U32, T), n}) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
def put_words_any(dd, dw, D, T, p, P, n, k, pfD, pfT, hdd, hdw, hp3, eP, hk, hy, hsrc, hdst, hz):
  put_words_anyU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, hz)

# ---- the storage check of a byte list ----------------------------------------------------------

def wob_goU(+dw: Nat, +T: F.array__Tree<U32>, +n: U32, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hroom: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +b: Bool, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {O.wk_last(True{}, n, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}:
  match b:
    case True{}:
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n)), (F.array__thaw(U32, T), RD.wd(T, dw, U32.shrn(n, 2n))), VE.get_any(dw, T, U32.shrn(n, 2n), VB.lt32(dw, hdw), pfT)) :
        {O.wk_last(True{}, n, _) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
      %Equal.sym(U32, U32.and(n, 3), 0, F.u32alg__eq_of(U32.and(n, 3), 0, eb)) :
        {(O.Words{F.array__thaw(U32, T), n}, O.tail_zero(_, RD.wd(T, dw, U32.shrn(n, 2n)))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
      {==}
    case False{}:
      +hr1 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, Nat.add(VC.NW(n), 0n), VC.NW(n), F.nat__add_zero(VC.NW(n)), hroom)
      +hq = F.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dw)) == True{} : Bool}, VY.KW(n), VY.QL(n), VY.kw_qU(n, hy, eb), VY.kw_ltU(n, dw, hy, eb, hr1))
      %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n)), (F.array__thaw(U32, T), VB.slot(T, VY.QL(n))), VB.get_n(dw, T, U32.shrn(n, 2n), VY.QL(n), {==}, VB.lt32(dw, hdw), hq, pfT)) :
        {O.wk_last(True{}, n, _) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
      %Equal.sym(Bool, O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))), True{}, htz) :
        {(O.Words{F.array__thaw(U32, T), n}, _) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
      {==}

def wob_go(+dw: Nat, +T: F.array__Tree<U32>, +n: U32, +k: Nat, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hroom: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +b: Bool, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {O.wk_last(True{}, n, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}:
  wob_goU(dw, T, n, pfT, hdw, VC.hyU(n, k, hk, hy), hroom, htz, b, eb)

# The storage check of a byte list of lo <= n <= hi bytes whose storage has room
# for them and no bytes past them in the last word.
law words_ok_bU:
  for +dw: Nat
  for +T: F.array__Tree<U32>
  for +n: U32
  for +lo: U32
  for +hi: U32
  for +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}
  for +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}
  for +hlo: {Nat.is_le(U32.to_nat(lo), U32.to_nat(n)) == True{} : Bool}
  for +hhi: {Nat.is_le(U32.to_nat(n), U32.to_nat(hi)) == True{} : Bool}
  for +hroom: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool}
  for +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool}
  for +unit: U32
  for +hu: {O.unit_ok(unit, n) == True{} : Bool}
  {O.words_ok(O.Words{F.array__thaw(U32, T), n}, lo, hi, False{}, unit) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
def words_ok_bU(dw, T, n, lo, hi, pfT, hdw, hy, hlo, hhi, hroom, htz, unit, hu):
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, T)), (F.array__thaw(U32, T), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, T, pfT)) :
    {O.wk_cap(Bool.and(Bool.and(U32.is_le(lo, n), Bool.or(False{}, U32.is_le(n, hi))), O.unit_ok(unit, n)), n, _) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(lo, n), True{}, VE.le_hi(lo, n, hlo)) :
    {O.wk_last(Bool.and(Bool.and(Bool.and(_, Bool.or(False{}, U32.is_le(n, hi))), O.unit_ok(unit, n)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), n, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(n, hi), True{}, VE.le_hi(n, hi, hhi)) :
    {O.wk_last(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, _)), O.unit_ok(unit, n)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), n, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(VC.nwu(n), F.u32__pow2u(dw)), True{}, VE.le_room(n, dw, hdw, hroom)) :
    {O.wk_last(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, True{})), O.unit_ok(unit, n)), _), n, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, O.unit_ok(unit, n), True{}, hu) :
    {O.wk_last(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, True{})), _), True{}), n, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  wob_goU(dw, T, n, pfT, hdw, hy, hroom, htz, U32.is_eq(VY.RM(n), 0), {==})

law words_ok_b:
  for +dw: Nat
  for +T: F.array__Tree<U32>
  for +n: U32
  for +lo: U32
  for +hi: U32
  for +k: Nat
  for +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}
  for +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}
  for +hlo: {Nat.is_le(U32.to_nat(lo), U32.to_nat(n)) == True{} : Bool}
  for +hhi: {Nat.is_le(U32.to_nat(n), U32.to_nat(hi)) == True{} : Bool}
  for +hroom: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool}
  for +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool}
  for +unit: U32
  for +hu: {O.unit_ok(unit, n) == True{} : Bool}
  {O.words_ok(O.Words{F.array__thaw(U32, T), n}, lo, hi, False{}, unit) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
def words_ok_b(dw, T, n, lo, hi, k, pfT, hdw, hk, hy, hlo, hhi, hroom, htz, unit, hu):
  words_ok_bU(dw, T, n, lo, hi, pfT, hdw, VC.hyU(n, k, hk, hy), hlo, hhi, hroom, htz, unit, hu)

# ---- windows of a copied run (VB.mone) -----------------------------------------------------------

def peel_mone_hi(+n: Nat, +i: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>, +m: Nat, +p: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(m, p), j) == True{} : Bool})
    -> {VF.WIN(m, p, F.array__slots(U32, VB.mone(n, i, j, dd, D, S))) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, i, j, dd, D, S)), VB.lm(n, i, j, F.array__slots(U32, D), F.array__slots(U32, S)), VB.slots_mone(n, i, j, dd, D, S, pf, hb)) :
    {VF.WIN(m, p, _) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}
  VF.lm_hi(n, i, j, m, p, F.array__slots(U32, D), F.array__slots(U32, S), h)

def peel_mone_lo(+n: Nat, +i: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>, +m: Nat, +p: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(n, j), p) == True{} : Bool})
    -> {VF.WIN(m, p, F.array__slots(U32, VB.mone(n, i, j, dd, D, S))) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, i, j, dd, D, S)), VB.lm(n, i, j, F.array__slots(U32, D), F.array__slots(U32, S)), VB.slots_mone(n, i, j, dd, D, S, pf, hb)) :
    {VF.WIN(m, p, _) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}
  VF.lm_lo(n, i, j, m, p, F.array__slots(U32, D), F.array__slots(U32, S), h)

# The run's own window holds the source's first n words.
def own_mone(+n: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +dS: Nat, +S: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, dS, S) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool}, +hS: {Nat.is_le(Nat.add(n, 0n), VB.pw(dS)) == True{} : Bool})
    -> {VF.WIN(n, j, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, S))) == VS.wtake(n, F.array__slots(U32, S)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, S)), VB.lm(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, S)), VB.slots_mone(n, 0n, j, dd, D, S, pf, hb)) :
    {VF.WIN(n, j, _) == VS.wtake(n, F.array__slots(U32, S)) : List<&2, U32>}
  VB.lm_win(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, S),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(n, j), z) == True{} : Bool}, VB.pw(dd), VB.len(F.array__slots(U32, D)), Equal.sym(Nat, VB.len(F.array__slots(U32, D)), VB.pw(dd), F.array__slots_length(U32, dd, D, pf)), hb),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(n, 0n), z) == True{} : Bool}, VB.pw(dS), VB.len(F.array__slots(U32, S)), Equal.sym(Nat, VB.len(F.array__slots(U32, S)), VB.pw(dS), F.array__slots_length(U32, dS, S, pfS)), hS))

# A window at k + P split after its first a words (k, a literal; P symbolic).
def win_splitP(+a: Nat, +b: Nat, +k: Nat, +P: Nat, +X: List<&2, U32>)
    -> {VF.WIN(Nat.add(a, b), Nat.add(k, P), X) == VF.app(VF.WIN(a, Nat.add(k, P), X), VF.WIN(b, Nat.add(Nat.add(k, a), P), X)) : List<&2, U32>}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(k, P), a), Nat.add(k, Nat.add(P, a)), Nat.add(Nat.add(k, a), P), F.nat__add_assoc(k, P, a),
    Equal.trans(Nat, Nat.add(k, Nat.add(P, a)), Nat.add(k, Nat.add(a, P)), Nat.add(Nat.add(k, a), P),
      Equal.cong(Nat, Nat, z => Nat.add(k, z), Nat.add(P, a), Nat.add(a, P), F.nat__add_comm(P, a)),
      Equal.sym(Nat, Nat.add(Nat.add(k, a), P), Nat.add(k, Nat.add(a, P)), F.nat__add_assoc(k, a, P))))
  %e : {VF.WIN(Nat.add(a, b), Nat.add(k, P), X) == VF.app(VF.WIN(a, Nat.add(k, P), X), VF.WIN(b, _, X)) : List<&2, U32>}
  VF.win_split(a, b, Nat.add(k, P), X)

# win_splitP with the split point written b + a: when a is a large literal and b a small one, Nat.add(b, a)
# converts to their sum's literal in b steps, where Nat.add(a, b) would recurse a times
def win_splitR(+a: Nat, +b: Nat, +k: Nat, +P: Nat, +X: List<&2, U32>)
    -> {VF.WIN(Nat.add(b, a), Nat.add(k, P), X) == VF.app(VF.WIN(a, Nat.add(k, P), X), VF.WIN(b, Nat.add(Nat.add(k, a), P), X)) : List<&2, U32>}:
  F.logic__subst(Nat, z => {VF.WIN(z, Nat.add(k, P), X) == VF.app(VF.WIN(a, Nat.add(k, P), X), VF.WIN(b, Nat.add(Nat.add(k, a), P), X)) : List<&2, U32>},
    Nat.add(a, b), Nat.add(b, a), F.nat__add_comm(a, b), win_splitP(a, b, k, P, X))

# win_splitP and win_splitR with the next window's position written (a + k) + P, for when k is the larger
# literal (Nat.add recurses on its first argument)
def win_splitK(+a: Nat, +b: Nat, +k: Nat, +P: Nat, +X: List<&2, U32>)
    -> {VF.WIN(Nat.add(a, b), Nat.add(k, P), X) == VF.app(VF.WIN(a, Nat.add(k, P), X), VF.WIN(b, Nat.add(Nat.add(a, k), P), X)) : List<&2, U32>}:
  F.logic__subst(Nat, z => {VF.WIN(Nat.add(a, b), Nat.add(k, P), X) == VF.app(VF.WIN(a, Nat.add(k, P), X), VF.WIN(b, Nat.add(z, P), X)) : List<&2, U32>},
    Nat.add(k, a), Nat.add(a, k), F.nat__add_comm(k, a), win_splitP(a, b, k, P, X))

def win_splitS(+a: Nat, +b: Nat, +k: Nat, +P: Nat, +X: List<&2, U32>)
    -> {VF.WIN(Nat.add(b, a), Nat.add(k, P), X) == VF.app(VF.WIN(a, Nat.add(k, P), X), VF.WIN(b, Nat.add(Nat.add(a, k), P), X)) : List<&2, U32>}:
  F.logic__subst(Nat, z => {VF.WIN(Nat.add(b, a), Nat.add(k, P), X) == VF.app(VF.WIN(a, Nat.add(k, P), X), VF.WIN(b, Nat.add(z, P), X)) : List<&2, U32>},
    Nat.add(k, a), Nat.add(a, k), F.nat__add_comm(k, a), win_splitR(a, b, k, P, X))

# Byte prefixes of two word lists at p agree when the windows of m >= L/4 words there agree.
def bytes_frame(+L: Nat, +m: Nat, +p: Nat, +X1: List<&2, U32>, +X2: List<&2, U32>, +hq: {Nat.is_le(L, A.quad(m)) == True{} : Bool},
    +h: {VF.WIN(m, p, X1) == VF.WIN(m, p, X2) : List<&2, U32>})
    -> {VS.bt(L, FX.limbs(VB.wdr(p, X1))) == VS.bt(L, FX.limbs(VB.wdr(p, X2))) : +List<U32>}:
  %VY.bt_take(m, L, VB.wdr(p, X1), hq) : {_ == VS.bt(L, FX.limbs(VB.wdr(p, X2))) : +List<U32>}
  %VY.bt_take(m, L, VB.wdr(p, X2), hq) : {VS.bt(L, FX.limbs(VS.wtake(m, VB.wdr(p, X1)))) == _ : +List<U32>}
  Equal.cong(List<&2, U32>, +List<U32>, z => VS.bt(L, FX.limbs(z)), VF.WIN(m, p, X1), VF.WIN(m, p, X2), h)
