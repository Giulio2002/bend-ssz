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
import ./vbrt.bend as VR
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

# ---- splices ------------------------------------------------------------------------------

# The bytes B with Y written at X.
def SPL(+B: +List<U32>, +X: Nat, +Y: +List<U32>) -> +List<U32>: List.append(&2, U32, VS.bt(X, B), List.append(&2, U32, Y, VS.bdr(Nat.add(X, List.length(&2, U32, Y)), B)))

def len_limbs_q(+ws: +List<U32>) -> {List.length(&2, U32, FX.limbs(ws)) == A.quad(List.length(&2, U32, ws)) : Nat}:
  Equal.trans(Nat, List.length(&2, U32, FX.limbs(ws)), FX.wlen(ws), A.quad(List.length(&2, U32, ws)), VS.len_limbs(ws), VS.wlen_quad(ws))

def len_limbs_v(+ws: List<&2, U32>) -> {List.length(&2, U32, FX.limbs(ws)) == A.quad(VB.len(ws)) : Nat}:
  Equal.trans(Nat, List.length(&2, U32, FX.limbs(ws)), A.quad(List.length(&2, U32, ws)), A.quad(VB.len(ws)), len_limbs_q(ws),
    Equal.cong(Nat, Nat, z => A.quad(z), List.length(&2, U32, ws), VB.len(ws), VR.len_eq(ws)))

law bdr_limbs_w:
  for +k: Nat
  for +W: List<&2, U32>
  {VS.bdr(A.quad(k), FX.limbs(W)) == FX.limbs(VB.wdr(k, W)) : +List<U32>}
def bdr_limbs_w(k, W):
  match k W:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}: bdr_limbs_w(p, t)

law take_drop:
  for +j: Nat
  for +L: List<&2, U32>
  {VF.app(VS.wtake(j, L), VB.wdr(j, L)) == L : List<&2, U32>}
def take_drop(j, L):
  match j L:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}: Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{h, z}, VF.app(VS.wtake(p, t), VB.wdr(p, t)), t, take_drop(p, t))

law drop_upd_ge:
  for +L: List<&2, U32>
  for +j: Nat
  for +m: Nat
  for +v: U32
  {VB.wdr(Nat.add(1n+j, m), FD.spec_common__update(U32, L, j, v)) == VB.wdr(Nat.add(1n+j, m), L) : List<&2, U32>}
def drop_upd_ge(L, j, m, v):
  match L j:
    case Nil{} _: {==}
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +p: drop_upd_ge(t, p, m, v)

# The sequential word writes: the words before j, V, then the words after.
law lmv_split:
  for +V: List<&2, U32>
  for +j: Nat
  for +L: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(j, VB.len(V)), VB.len(L)) == True{} : Bool}
  {VF.lmv(V, j, L) == VF.app(VS.wtake(j, L), VF.app(V, VB.wdr(Nat.add(j, VB.len(V)), L))) : List<&2, U32>}
def lmv_split(V, j, L, h):
  match V:
    case Nil{}:
      %Equal.sym(Nat, Nat.add(j, 0n), j, FD.nat__add_zero(j)) : {L == VF.app(VS.wtake(j, L), VB.wdr(_, L)) : List<&2, U32>}
      Equal.sym(List<&2, U32>, VF.app(VS.wtake(j, L), VB.wdr(j, L)), L, take_drop(j, L))
    case Con{+v, +t}:
      +m = VB.len(t)
      +hl = FD.nat__lt_le_trans(j, Nat.add(j, 1n+m), VB.len(L), FD.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, 1n+Nat.add(j, m), Nat.add(j, 1n+m), Equal.sym(Nat, Nat.add(j, 1n+m), 1n+Nat.add(j, m), FD.nat__add_succ(j, m)), FD.nat__le_lt_trans(j, Nat.add(j, m), 1n+Nat.add(j, m), Order.below_sum(j, m), FD.nat__lt_succ(Nat.add(j, m)))), h)
      +L1 = FD.spec_common__update(U32, L, j, v)
      +h1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n+j, m), z) == True{} : Bool}, VB.len(L), VB.len(L1), Equal.sym(Nat, VB.len(L1), VB.len(L), len_upd_l(L, j, v)),
        FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(L)) == True{} : Bool}, Nat.add(j, 1n+m), 1n+Nat.add(j, m), FD.nat__add_succ(j, m), h))
      +ih = lmv_split(t, 1n+j, L1, h1)
      %Equal.sym(List<&2, U32>, VF.lmv(t, 1n+j, L1), VF.app(VS.wtake(1n+j, L1), VF.app(t, VB.wdr(Nat.add(1n+j, m), L1))), ih) :
        {_ == VF.app(VS.wtake(j, L), VF.app(Con{v, t}, VB.wdr(Nat.add(j, 1n+m), L))) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, VS.wtake(1n+j, L1), VF.app(VS.wtake(j, L), [v]), take_upd(L, j, v, hl)) :
        {VF.app(_, VF.app(t, VB.wdr(Nat.add(1n+j, m), L1))) == VF.app(VS.wtake(j, L), VF.app(Con{v, t}, VB.wdr(Nat.add(j, 1n+m), L))) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, VB.wdr(Nat.add(1n+j, m), L1), VB.wdr(Nat.add(1n+j, m), L), drop_upd_ge(L, j, m, v)) :
        {VF.app(VF.app(VS.wtake(j, L), [v]), VF.app(t, _)) == VF.app(VS.wtake(j, L), VF.app(Con{v, t}, VB.wdr(Nat.add(j, 1n+m), L))) : List<&2, U32>}
      %Equal.sym(Nat, Nat.add(j, 1n+m), 1n+Nat.add(j, m), FD.nat__add_succ(j, m)) :
        {VF.app(VF.app(VS.wtake(j, L), [v]), VF.app(t, VB.wdr(Nat.add(1n+j, m), L))) == VF.app(VS.wtake(j, L), VF.app(Con{v, t}, VB.wdr(_, L))) : List<&2, U32>}
      app_assoc_l(VS.wtake(j, L), [v], VF.app(t, VB.wdr(Nat.add(1n+j, m), L)))

# The bytes of a list of words: the words before j, V, then the words after, as a splice.
def limbs_tvd(+j: Nat, +V: List<&2, U32>, +L: List<&2, U32>)
    -> {FX.limbs(VF.app(VS.wtake(j, L), VF.app(V, VB.wdr(Nat.add(j, VB.len(V)), L)))) == SPL(FX.limbs(L), A.quad(j), FX.limbs(V)) : +List<U32>}:
  %Equal.sym(+List<U32>, FX.limbs(VF.app(VS.wtake(j, L), VF.app(V, VB.wdr(Nat.add(j, VB.len(V)), L)))), List.append(&2, U32, FX.limbs(VS.wtake(j, L)), FX.limbs(VF.app(V, VB.wdr(Nat.add(j, VB.len(V)), L)))),
      VF.limbs_app(VS.wtake(j, L), VF.app(V, VB.wdr(Nat.add(j, VB.len(V)), L)))) : {_ == SPL(FX.limbs(L), A.quad(j), FX.limbs(V)) : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(VF.app(V, VB.wdr(Nat.add(j, VB.len(V)), L))), List.append(&2, U32, FX.limbs(V), FX.limbs(VB.wdr(Nat.add(j, VB.len(V)), L))),
      VF.limbs_app(V, VB.wdr(Nat.add(j, VB.len(V)), L))) : {List.append(&2, U32, FX.limbs(VS.wtake(j, L)), _) == SPL(FX.limbs(L), A.quad(j), FX.limbs(V)) : +List<U32>}
  %VS.bt_limbs(j, L) : {List.append(&2, U32, _, List.append(&2, U32, FX.limbs(V), FX.limbs(VB.wdr(Nat.add(j, VB.len(V)), L)))) == SPL(FX.limbs(L), A.quad(j), FX.limbs(V)) : +List<U32>}
  %bdr_limbs_w(Nat.add(j, VB.len(V)), L) : {List.append(&2, U32, VS.bt(A.quad(j), FX.limbs(L)), List.append(&2, U32, FX.limbs(V), _)) == SPL(FX.limbs(L), A.quad(j), FX.limbs(V)) : +List<U32>}
  %VF.quad_add(j, VB.len(V)) :
    {List.append(&2, U32, VS.bt(A.quad(j), FX.limbs(L)), List.append(&2, U32, FX.limbs(V), VS.bdr(_, FX.limbs(L)))) == SPL(FX.limbs(L), A.quad(j), FX.limbs(V)) : +List<U32>}
  %len_limbs_v(V) :
    {List.append(&2, U32, VS.bt(A.quad(j), FX.limbs(L)), List.append(&2, U32, FX.limbs(V), VS.bdr(Nat.add(A.quad(j), _), FX.limbs(L)))) == SPL(FX.limbs(L), A.quad(j), FX.limbs(V)) : +List<U32>}
  {==}

# The aligned run of word writes at word j splices their bytes in.
def updv_bytes(+V: List<&2, U32>, +dd: Nat, +D: FD.array__Tree<U32>, +j: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(j, VB.len(V)), VB.pw(dd)) == True{} : Bool})
    -> {UA.BYT(VF.updv(V, dd, D, j)) == SPL(UA.BYT(D), A.quad(j), FX.limbs(V)) : +List<U32>}:
  +hb2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(j, VB.len(V)), Nat.add(VB.len(V), j), FD.nat__add_comm(j, VB.len(V)), hb)
  +hL = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(j, VB.len(V)), z) == True{} : Bool}, VB.pw(dd), VB.len(SLW(D)), Equal.sym(Nat, VB.len(SLW(D)), VB.pw(dd), FD.array__slots_length(U32, dd, D, pf)), hb)
  %Equal.sym(List<&2, U32>, SLW(VF.updv(V, dd, D, j)), VF.lmv(V, j, SLW(D)), VF.slots_updv(V, dd, D, j, pf, hb2)) : {FX.limbs(_) == SPL(UA.BYT(D), A.quad(j), FX.limbs(V)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.lmv(V, j, SLW(D)), VF.app(VS.wtake(j, SLW(D)), VF.app(V, VB.wdr(Nat.add(j, VB.len(V)), SLW(D)))), lmv_split(V, j, SLW(D), hL)) : {FX.limbs(_) == SPL(UA.BYT(D), A.quad(j), FX.limbs(V)) : +List<U32>}
  limbs_tvd(j, V, SLW(D))

law bt_add:
  for +a: Nat
  for +b: Nat
  for +xs: +List<U32>
  {VS.bt(Nat.add(a, b), xs) == List.append(&2, U32, VS.bt(a, xs), VS.bt(b, VS.bdr(a, xs))) : +List<U32>}
def bt_add(a, b, xs):
  match a b xs:
    case 0n _ _: {==}
    case 1n+ +p 0n Nil{}: {==}
    case 1n+ +p 1n+ +q Nil{}: {==}
    case 1n+ +p +b2 Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, VS.bt(Nat.add(p, b2), t), List.append(&2, U32, VS.bt(p, t), VS.bt(b2, VS.bdr(p, t))), bt_add(p, b2, t))

law bdr_add:
  for +a: Nat
  for +b: Nat
  for +xs: +List<U32>
  {VS.bdr(Nat.add(a, b), xs) == VS.bdr(b, VS.bdr(a, xs)) : +List<U32>}
def bdr_add(a, b, xs):
  match a b xs:
    case 0n _ _: {==}
    case 1n+ +p 0n Nil{}: {==}
    case 1n+ +p 1n+ +q Nil{}: {==}
    case 1n+ +p +b2 Con{+x, +t}: bdr_add(p, b2, t)

law nthc_wdr:
  for +i: Nat
  for +L: List<&2, U32>
  {FD.flat__nthc(VB.wdr(i, L), 0n) == FD.flat__nthc(L, i) : U32}
def nthc_wdr(i, L):
  match i L:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}: nthc_wdr(p, t)

law lt_wdr:
  for +i: Nat
  for +k: Nat
  for +L: List<&2, U32>
  for +h: {Nat.is_lt(Nat.add(i, k), VB.len(L)) == True{} : Bool}
  {Nat.is_lt(k, VB.len(VB.wdr(i, L))) == True{} : Bool}
def lt_wdr(i, k, L, h):
  match i L:
    case 0n _: h
    case 1n+ +p Nil{}: Empty.absurd({Nat.is_lt(k, VB.len(VB.wdr(1n+p, Nil{}))) == True{} : Bool}, FD.nat__lt_zero_absurd(Nat.add(1n+p, k), h))
    case 1n+ +p Con{+x, +t}: lt_wdr(p, k, t, h)

# Bytes up to a, the s bytes after, then Y and the bytes after it, as a splice at a + s.
def spl_comb(+B: +List<U32>, +a: Nat, +s: Nat, +Y: +List<U32>)
    -> {List.append(&2, U32, VS.bt(a, B), List.append(&2, U32, VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, VS.bdr(Nat.add(s, List.length(&2, U32, Y)), VS.bdr(a, B))))) == SPL(B, Nat.add(a, s), Y) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bt(Nat.add(a, s), B), List.append(&2, U32, VS.bt(a, B), VS.bt(s, VS.bdr(a, B))), bt_add(a, s, B)) : {List.append(&2, U32, VS.bt(a, B), List.append(&2, U32, VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, VS.bdr(Nat.add(s, List.length(&2, U32, Y)), VS.bdr(a, B))))) == List.append(&2, U32, _, List.append(&2, U32, Y, VS.bdr(Nat.add(Nat.add(a, s), List.length(&2, U32, Y)), B))) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, VS.bt(a, B), VS.bt(s, VS.bdr(a, B))), List.append(&2, U32, Y, VS.bdr(Nat.add(Nat.add(a, s), List.length(&2, U32, Y)), B))), List.append(&2, U32, VS.bt(a, B), List.append(&2, U32, VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, VS.bdr(Nat.add(Nat.add(a, s), List.length(&2, U32, Y)), B)))),
      VS.app_assoc(VS.bt(a, B), VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, VS.bdr(Nat.add(Nat.add(a, s), List.length(&2, U32, Y)), B)))) :
    {List.append(&2, U32, VS.bt(a, B), List.append(&2, U32, VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, VS.bdr(Nat.add(s, List.length(&2, U32, Y)), VS.bdr(a, B))))) == _ : +List<U32>}
  %Equal.sym(Nat, Nat.add(Nat.add(a, s), List.length(&2, U32, Y)), Nat.add(a, Nat.add(s, List.length(&2, U32, Y))), FD.nat__add_assoc(a, s, List.length(&2, U32, Y))) :
    {List.append(&2, U32, VS.bt(a, B), List.append(&2, U32, VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, VS.bdr(Nat.add(s, List.length(&2, U32, Y)), VS.bdr(a, B))))) == List.append(&2, U32, VS.bt(a, B), List.append(&2, U32, VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, VS.bdr(_, B)))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(a, Nat.add(s, List.length(&2, U32, Y))), B), VS.bdr(Nat.add(s, List.length(&2, U32, Y)), VS.bdr(a, B)), bdr_add(a, Nat.add(s, List.length(&2, U32, Y)), B)) :
    {List.append(&2, U32, VS.bt(a, B), List.append(&2, U32, VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, VS.bdr(Nat.add(s, List.length(&2, U32, Y)), VS.bdr(a, B))))) == List.append(&2, U32, VS.bt(a, B), List.append(&2, U32, VS.bt(s, VS.bdr(a, B)), List.append(&2, U32, Y, _))) : +List<U32>}
  {==}
