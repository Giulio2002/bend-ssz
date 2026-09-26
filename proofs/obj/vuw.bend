import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vua.bend as UA
import ./vfix.bend as VF
import ./vuw_bits.bend as UWB
import ./word_mul.bend as WM

# The unaligned-offset WRITE layer, W1: the runtime's writers at a byte offset
# X = 4 q + s (s = 1, 2, 3) OR the value's bytes into the output words q, q + 1, ...
# Their tree models (ORW: OR into one word; ORS: the same, skipped for zero; SWc: the
# words of a value written at byte s of word i, with the carry c of the word before)
# and the bytes of the models: writing the words ws at byte 4 i + s splices their
# limbs into the output's bytes there, when those bytes were zero.

# ---- the models -------------------------------------------------------------------------

def ORW(+dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +x: U32) -> FD.array__Tree<U32>: FD.array__upd(U32, dd, D, i, U32.or(VB.slot(D, i), x))

def ORSb(b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +x: U32) -> FD.array__Tree<U32>:
  match b:
    case True{}: D
    case False{}: ORW(dd, D, i, x)

def ORS(+dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +x: U32) -> FD.array__Tree<U32>: ORSb(U32.is_eq(x, 0), dd, D, i, x)

# The words ws at byte S of word i, after the carry c of the word before.
def SWc(+S: U32, ws: +List<U32>, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +c: U32) -> FD.array__Tree<U32>:
  match ws:
    case Nil{}: ORS(dd, D, i, c)
    case Con{+w, t}: SWc(S, t, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S))

def orw_perfect(+dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, ORW(dd, D, i, x)) == True{} : Bool}:
  FD.array__upd_perfect(U32, dd, D, i, U32.or(VB.slot(D, i), x), pf)

def orsb_perfect(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, ORSb(b, dd, D, i, x)) == True{} : Bool}:
  match b:
    case True{}: pf
    case False{}: orw_perfect(dd, D, i, x, pf)

law swc_perfect:
  for +S: U32
  for +ws: +List<U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +i: Nat
  for +c: U32
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  {FD.array__perfect(U32, dd, SWc(S, ws, dd, D, i, c)) == True{} : Bool}
def swc_perfect(S, ws, dd, D, i, c, pf):
  match ws:
    case Nil{}: orsb_perfect(U32.is_eq(c, 0), dd, D, i, c, pf)
    case Con{+w, +t}:
      swc_perfect(S, t, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S), orw_perfect(dd, D, i, U32.or(O.shl_bytes(w, S), c), pf))

# ---- the runtime's word writes ------------------------------------------------------------

def orw_rt(+dd: Nat, +D: FD.array__Tree<U32>, +q: U32, +i: Nat, +x: U32, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.or_word(FD.array__thaw(U32, D), q, x) == FD.array__thaw(U32, ORW(dd, D, i, x)) : Array<U32>}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, D), q), (FD.array__thaw(U32, D), VB.slot(D, i)), VB.get_n(dd, D, q, i, eq, hd, hi, pf)) :
    {O.or_at(q, x, _) == FD.array__thaw(U32, ORW(dd, D, i, x)) : Array<U32>}
  VB.set_n(dd, D, q, i, U32.or(VB.slot(D, i), x), eq, hd, hi, pf)

def or0l(+v: U32) -> {U32.or(0, v) == v : U32}:
  Equal.trans(U32, U32.or(0, v), U32.or(v, 0), v, UWB.orc(0, v), UWB.or0r(v))

# A store into a zero word is an OR.
def set_orw(+dd: Nat, +D: FD.array__Tree<U32>, +q: U32, +i: Nat, +v: U32, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VB.slot(D, i) == 0 : U32})
    -> {Array.set(U32, FD.array__thaw(U32, D), q, v) == FD.array__thaw(U32, ORW(dd, D, i, v)) : Array<U32>}:
  %Equal.sym(U32, VB.slot(D, i), 0, hz) : {Array.set(U32, FD.array__thaw(U32, D), q, v) == FD.array__thaw(U32, FD.array__upd(U32, dd, D, i, U32.or(_, v))) : Array<U32>}
  %Equal.sym(U32, U32.or(0, v), v, or0l(v)) : {Array.set(U32, FD.array__thaw(U32, D), q, v) == FD.array__thaw(U32, FD.array__upd(U32, dd, D, i, _)) : Array<U32>}
  VB.set_n(dd, D, q, i, v, eq, hd, hi, pf)

def orskip_go(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +q: U32, +i: Nat, +x: U32, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.or_skip_go(b, FD.array__thaw(U32, D), q, x) == FD.array__thaw(U32, ORSb(b, dd, D, i, x)) : Array<U32>}:
  match b:
    case True{}: {==}
    case False{}: orw_rt(dd, D, q, i, x, eq, hd, hi, pf)

def orskip_rt(+dd: Nat, +D: FD.array__Tree<U32>, +q: U32, +i: Nat, +x: U32, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.or_skip(FD.array__thaw(U32, D), q, x) == FD.array__thaw(U32, ORS(dd, D, i, x)) : Array<U32>}:
  orskip_go(U32.is_eq(x, 0), dd, D, q, i, x, eq, hd, hi, pf)

# ---- the bytes of an updated word ---------------------------------------------------------

law limbs_upd:
  for +L: List<&2, U32>
  for +i: Nat
  for +v: U32
  for +h: {Nat.is_lt(i, VB.len(L)) == True{} : Bool}
  {FX.limbs(FD.spec_common__update(U32, L, i, v)) == List.append(&2, U32, VS.bt(A.quad(i), FX.limbs(L)), List.append(&2, U32, I.limb(v), VS.bdr(4n+A.quad(i), FX.limbs(L)))) : +List<U32>}
def limbs_upd(L, i, v, h):
  match L i:
    case Nil{} _: Empty.absurd({FX.limbs(FD.spec_common__update(U32, Nil{}, i, v)) == List.append(&2, U32, VS.bt(A.quad(i), FX.limbs(Nil{})), List.append(&2, U32, I.limb(v), VS.bdr(4n+A.quad(i), FX.limbs(Nil{})))) : +List<U32>}, FD.nat__lt_zero_absurd(i, h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p:
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, I.limb(x), z), FX.limbs(FD.spec_common__update(U32, t, p, v)),
        List.append(&2, U32, VS.bt(A.quad(p), FX.limbs(t)), List.append(&2, U32, I.limb(v), VS.bdr(4n+A.quad(p), FX.limbs(t)))), limbs_upd(t, p, v, h))

# The four bytes of word i.
law slot_limb:
  for +L: List<&2, U32>
  for +i: Nat
  for +h: {Nat.is_lt(i, VB.len(L)) == True{} : Bool}
  {VS.bt(4n, VS.bdr(A.quad(i), FX.limbs(L))) == I.limb(FD.flat__nthc(L, i)) : +List<U32>}
def slot_limb(L, i, h):
  match L i:
    case Nil{} _: Empty.absurd({VS.bt(4n, VS.bdr(A.quad(i), FX.limbs(Nil{}))) == I.limb(FD.flat__nthc(Nil{}, i)) : +List<U32>}, FD.nat__lt_zero_absurd(i, h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p: slot_limb(t, p, h)

# Another word of an updated list.
law nthc_upd_other:
  for +L: List<&2, U32>
  for +i: Nat
  for +j: Nat
  for +v: U32
  for +ne: {Nat.is_eq(i, j) == False{} : Bool}
  {FD.flat__nthc(FD.spec_common__update(U32, L, i, v), j) == FD.flat__nthc(L, j) : U32}
def nthc_upd_other(L, i, j, v, ne):
  match L i j:
    case Nil{} _ _: {==}
    case Con{+x, +t} 0n 0n: Empty.absurd({FD.flat__nthc(Con{v, t}, 0n) == x : U32}, FD.logic__true_false(ne))
    case Con{+x, +t} 0n 1n+ +q: {==}
    case Con{+x, +t} 1n+ +p 0n: {==}
    case Con{+x, +t} 1n+ +p 1n+ +q: nthc_upd_other(t, p, q, v, ne)

# ---- the list model ------------------------------------------------------------------------

def ORVb(b: Bool, +h: U32, +c: U32) -> U32:
  match b:
    case True{}: h
    case False{}: U32.or(h, c)

# The words W (from word i on) after writing ws at byte S of their first word, after the
# carry c of the word before.
def SWL(+S: U32, ws: +List<U32>, W: List<&2, U32>, +c: U32) -> List<&2, U32>:
  match ws W:
    case _ Nil{}: []
    case Nil{} Con{+h, t}: Con{ORVb(U32.is_eq(c, 0), h, c), t}
    case Con{+w, r} Con{+h, t}: Con{U32.or(h, U32.or(O.shl_bytes(w, S), c)), SWL(S, r, t, O.shr_over(w, S))}

def ZB(n: Nat) -> +List<U32>:
  match n:
    case 0n: []
    case 1n+p: Con{0, ZB(p)}

law upd_same_l:
  for +L: List<&2, U32>
  for +i: Nat
  {FD.spec_common__update(U32, L, i, FD.flat__nthc(L, i)) == L : List<&2, U32>}
def upd_same_l(L, i):
  match L i:
    case Nil{} _: {==}
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p:
      Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{x, z}, FD.spec_common__update(U32, t, p, FD.flat__nthc(t, p)), t, upd_same_l(t, p))

# A list is its first i words, word i, and the rest.
law split_at:
  for +L: List<&2, U32>
  for +i: Nat
  for +h: {Nat.is_lt(i, VB.len(L)) == True{} : Bool}
  {L == VF.app(VS.wtake(i, L), Con{FD.flat__nthc(L, i), VB.wdr(1n+i, L)}) : List<&2, U32>}
def split_at(L, i, h):
  match L i:
    case Nil{} _: Empty.absurd({Nil{} == VF.app(VS.wtake(i, Nil{}), Con{FD.flat__nthc(Nil{}, i), VB.wdr(1n+i, Nil{})}) : List<&2, U32>}, FD.nat__lt_zero_absurd(i, h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p:
      Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{x, z}, t, VF.app(VS.wtake(p, t), Con{FD.flat__nthc(t, p), VB.wdr(1n+p, t)}), split_at(t, p, h))

law upd_split:
  for +L: List<&2, U32>
  for +i: Nat
  for +v: U32
  for +h: {Nat.is_lt(i, VB.len(L)) == True{} : Bool}
  {FD.spec_common__update(U32, L, i, v) == VF.app(VS.wtake(i, L), Con{v, VB.wdr(1n+i, L)}) : List<&2, U32>}
def upd_split(L, i, v, h):
  match L i:
    case Nil{} _: Empty.absurd({FD.spec_common__update(U32, Nil{}, i, v) == VF.app(VS.wtake(i, Nil{}), Con{v, VB.wdr(1n+i, Nil{})}) : List<&2, U32>}, FD.nat__lt_zero_absurd(i, h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p:
      Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{x, z}, FD.spec_common__update(U32, t, p, v), VF.app(VS.wtake(p, t), Con{v, VB.wdr(1n+p, t)}), upd_split(t, p, v, h))

law wdr_con:
  for +L: List<&2, U32>
  for +i: Nat
  for +h: {Nat.is_lt(i, VB.len(L)) == True{} : Bool}
  {VB.wdr(i, L) == Con{FD.flat__nthc(L, i), VB.wdr(1n+i, L)} : List<&2, U32>}
def wdr_con(L, i, h):
  match L i:
    case Nil{} _: Empty.absurd({VB.wdr(i, Nil{}) == Con{FD.flat__nthc(Nil{}, i), VB.wdr(1n+i, Nil{})} : List<&2, U32>}, FD.nat__lt_zero_absurd(i, h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p: wdr_con(t, p, h)

law take_upd:
  for +L: List<&2, U32>
  for +i: Nat
  for +v: U32
  for +h: {Nat.is_lt(i, VB.len(L)) == True{} : Bool}
  {VS.wtake(1n+i, FD.spec_common__update(U32, L, i, v)) == VF.app(VS.wtake(i, L), [v]) : List<&2, U32>}
def take_upd(L, i, v, h):
  match L i:
    case Nil{} _: Empty.absurd({VS.wtake(1n+i, FD.spec_common__update(U32, Nil{}, i, v)) == VF.app(VS.wtake(i, Nil{}), [v]) : List<&2, U32>}, FD.nat__lt_zero_absurd(i, h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p:
      Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{x, z}, VS.wtake(1n+p, FD.spec_common__update(U32, t, p, v)), VF.app(VS.wtake(p, t), [v]), take_upd(t, p, v, h))

law drop_upd:
  for +L: List<&2, U32>
  for +i: Nat
  for +v: U32
  {VB.wdr(1n+i, FD.spec_common__update(U32, L, i, v)) == VB.wdr(1n+i, L) : List<&2, U32>}
def drop_upd(L, i, v):
  match L i:
    case Nil{} _: {==}
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p: drop_upd(t, p, v)

law app_assoc_l:
  for +a: List<&2, U32>
  for +b: List<&2, U32>
  for +c: List<&2, U32>
  {VF.app(VF.app(a, b), c) == VF.app(a, VF.app(b, c)) : List<&2, U32>}
def app_assoc_l(a, b, c):
  match a:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{x, z}, VF.app(VF.app(t, b), c), VF.app(t, VF.app(b, c)), app_assoc_l(t, b, c))

law len_upd_l:
  for +L: List<&2, U32>
  for +i: Nat
  for +v: U32
  {VB.len(FD.spec_common__update(U32, L, i, v)) == VB.len(L) : Nat}
def len_upd_l(L, i, v): FD.list__length_update(U32, L, i, v)

def is_eq_succ(+i: Nat) -> {Nat.is_eq(i, 1n+i) == False{} : Bool}: FD.nat__is_eq_lt(i, 1n+i, FD.nat__lt_succ(i))

def lt_add_l(+i: Nat, +k: Nat, +P: Nat, +h: {Nat.is_lt(Nat.add(i, k), P) == True{} : Bool}) -> {Nat.is_lt(i, P) == True{} : Bool}:
  FD.nat__le_lt_trans(i, Nat.add(i, k), P, Order.below_sum(i, k), h)

# ---- the tree model's words ------------------------------------------------------------------

def SLW(+D: FD.array__Tree<U32>) -> List<&2, U32>: FD.array__slots(U32, D)

def ors_slots(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +c: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hi: {Nat.is_lt(i, VB.pw(dd)) == True{} : Bool})
    -> {SLW(ORSb(b, dd, D, i, c)) == VF.app(VS.wtake(i, SLW(D)), Con{ORVb(b, FD.flat__nthc(SLW(D), i), c), VB.wdr(1n+i, SLW(D))}) : List<&2, U32>}:
  match b:
    case True{}: split_at(SLW(D), i, FD.array__len_lt(U32, dd, D, i, pf, hi))
    case False{}:
      Equal.trans(List<&2, U32>, SLW(ORW(dd, D, i, c)), FD.spec_common__update(U32, SLW(D), i, U32.or(VB.slot(D, i), c)),
        VF.app(VS.wtake(i, SLW(D)), Con{U32.or(FD.flat__nthc(SLW(D), i), c), VB.wdr(1n+i, SLW(D))}),
        FD.array__upd_slots(U32, dd, D, i, U32.or(VB.slot(D, i), c), hi, pf), upd_split(SLW(D), i, U32.or(VB.slot(D, i), c), FD.array__len_lt(U32, dd, D, i, pf, hi)))

law swc_slots:
  for +S: U32
  for +ws: +List<U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +i: Nat
  for +c: U32
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hr: {Nat.is_lt(Nat.add(i, List.length(&2, U32, ws)), VB.pw(dd)) == True{} : Bool}
  {SLW(SWc(S, ws, dd, D, i, c)) == VF.app(VS.wtake(i, SLW(D)), SWL(S, ws, VB.wdr(i, SLW(D)), c)) : List<&2, U32>}
def swc_slots(S, ws, dd, D, i, c, pf, hr):
  match ws:
    case Nil{}:
      +hi = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(i, 0n), i, FD.nat__add_zero(i), hr)
      %Equal.sym(List<&2, U32>, VB.wdr(i, SLW(D)), Con{FD.flat__nthc(SLW(D), i), VB.wdr(1n+i, SLW(D))}, wdr_con(SLW(D), i, FD.array__len_lt(U32, dd, D, i, pf, hi))) :
        {SLW(SWc(S, Nil{}, dd, D, i, c)) == VF.app(VS.wtake(i, SLW(D)), SWL(S, Nil{}, _, c)) : List<&2, U32>}
      ors_slots(U32.is_eq(c, 0), dd, D, i, c, pf, hi)
    case Con{+w, +r}:
      +v = U32.or(O.shl_bytes(w, S), c)
      +V1 = U32.or(VB.slot(D, i), v)
      +D1 = ORW(dd, D, i, v)
      +hi = lt_add_l(i, List.length(&2, U32, Con{w, r}), VB.pw(dd), hr)
      +hl = FD.array__len_lt(U32, dd, D, i, pf, hi)
      +hr1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(i, 1n+List.length(&2, U32, r)), 1n+Nat.add(i, List.length(&2, U32, r)), FD.nat__add_succ(i, List.length(&2, U32, r)), hr)
      +ih = swc_slots(S, r, dd, D1, 1n+i, O.shr_over(w, S), orw_perfect(dd, D, i, v, pf), hr1)
      %Equal.sym(List<&2, U32>, VB.wdr(i, SLW(D)), Con{FD.flat__nthc(SLW(D), i), VB.wdr(1n+i, SLW(D))}, wdr_con(SLW(D), i, hl)) :
        {SLW(SWc(S, Con{w, r}, dd, D, i, c)) == VF.app(VS.wtake(i, SLW(D)), SWL(S, Con{w, r}, _, c)) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, SLW(SWc(S, r, dd, D1, 1n+i, O.shr_over(w, S))), VF.app(VS.wtake(1n+i, SLW(D1)), SWL(S, r, VB.wdr(1n+i, SLW(D1)), O.shr_over(w, S))), ih) :
        {_ == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWL(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, SLW(D1), FD.spec_common__update(U32, SLW(D), i, V1), FD.array__upd_slots(U32, dd, D, i, V1, hi, pf)) :
        {VF.app(VS.wtake(1n+i, _), SWL(S, r, VB.wdr(1n+i, SLW(D1)), O.shr_over(w, S))) == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWL(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, SLW(D1), FD.spec_common__update(U32, SLW(D), i, V1), FD.array__upd_slots(U32, dd, D, i, V1, hi, pf)) :
        {VF.app(VS.wtake(1n+i, FD.spec_common__update(U32, SLW(D), i, V1)), SWL(S, r, VB.wdr(1n+i, _), O.shr_over(w, S))) == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWL(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, VS.wtake(1n+i, FD.spec_common__update(U32, SLW(D), i, V1)), VF.app(VS.wtake(i, SLW(D)), [V1]), take_upd(SLW(D), i, V1, hl)) :
        {VF.app(_, SWL(S, r, VB.wdr(1n+i, FD.spec_common__update(U32, SLW(D), i, V1)), O.shr_over(w, S))) == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWL(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, VB.wdr(1n+i, FD.spec_common__update(U32, SLW(D), i, V1)), VB.wdr(1n+i, SLW(D)), drop_upd(SLW(D), i, V1)) :
        {VF.app(VF.app(VS.wtake(i, SLW(D)), [V1]), SWL(S, r, _, O.shr_over(w, S))) == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWL(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      app_assoc_l(VS.wtake(i, SLW(D)), [V1], SWL(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S)))
