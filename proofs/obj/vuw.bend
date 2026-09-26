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
import ./vu32.bend as VU
import ./vcopy.bend as VC
import ../compact/reads.bend as RD
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

# ---- byte positions X = 4 i + s ---------------------------------------------------------------

def ua_pair(+off: U32, +i: Nat, +s: Nat, +e: {U32.to_nat(off) == Nat.add(A.quad(i), s) : Nat}, +hs: {Nat.is_lt(s, 4n) == True{} : Bool})
    -> {U32.to_nat(U32.shrn(off, 2n)) == i : Nat} & {U32.to_nat(U32.and(off, 3)) == s : Nat}:
  +q = U32.to_nat(U32.shrn(off, 2n))
  +r = U32.to_nat(U32.and(off, 3))
  +e1 = Equal.trans(Nat, Nat.add(Nat.mul(q, 4n), r), Nat.add(A.quad(q), r), Nat.add(Nat.mul(i, 4n), s),
    Equal.cong(Nat, Nat, z => Nat.add(z, r), Nat.mul(q, 4n), A.quad(q), VC.quad_mul(q)),
    Equal.trans(Nat, Nat.add(A.quad(q), r), U32.to_nat(off), Nat.add(Nat.mul(i, 4n), s), Equal.sym(Nat, U32.to_nat(off), Nat.add(A.quad(q), r), VC.split4(off)),
      Equal.trans(Nat, U32.to_nat(off), Nat.add(A.quad(i), s), Nat.add(Nat.mul(i, 4n), s), e,
        Equal.cong(Nat, Nat, z => Nat.add(z, s), A.quad(i), Nat.mul(i, 4n), Equal.sym(Nat, Nat.mul(i, 4n), A.quad(i), VC.quad_mul(i))))))
  +hr = FD.nat__le_lt_trans(r, 3n, 4n, RD.and_le(off, 3), {==})
  VU.dm_unique(q, r, i, s, 4n, e1, hr, hs)

def ua_q(+off: U32, +i: Nat, +s: Nat, +e: {U32.to_nat(off) == Nat.add(A.quad(i), s) : Nat}, +hs: {Nat.is_lt(s, 4n) == True{} : Bool})
    -> {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}:
  Pair.fst({U32.to_nat(U32.shrn(off, 2n)) == i : Nat}, {U32.to_nat(U32.and(off, 3)) == s : Nat}, ua_pair(off, i, s, e, hs))

def ua_3(+off: U32, +i: Nat, +s: Nat, +S: U32, +eS: {U32.to_nat(S) == s : Nat}, +e: {U32.to_nat(off) == Nat.add(A.quad(i), s) : Nat}, +hs: {Nat.is_lt(s, 4n) == True{} : Bool})
    -> {U32.and(off, 3) == S : U32}:
  FD.u32__injective(U32.and(off, 3), S, Equal.trans(Nat, U32.to_nat(U32.and(off, 3)), s, U32.to_nat(S),
    Pair.snd({U32.to_nat(U32.shrn(off, 2n)) == i : Nat}, {U32.to_nat(U32.and(off, 3)) == s : Nat}, ua_pair(off, i, s, e, hs)), Equal.sym(Nat, U32.to_nat(S), s, eS)))

# pos + 4 k at 4 (k + i) + s (no wrap: pos + 4 k + ... fits the index bound).
def ua_add(+pos: U32, +c: U32, +i: Nat, +k: Nat, +s: Nat, +d: Nat, +e: {U32.to_nat(pos) == Nat.add(A.quad(i), s) : Nat}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(A.quad(k), Nat.add(A.quad(i), s)), VB.pw(d)) == True{} : Bool})
    -> {U32.to_nat(U32.add(pos, c)) == Nat.add(A.quad(Nat.add(k, i)), s) : Nat}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, Nat.add(A.quad(i), s)), VB.pw(d)) == True{} : Bool}, A.quad(k), U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), A.quad(k), ec), hb)
  %Equal.sym(Nat, U32.to_nat(U32.add(pos, c)), Nat.add(U32.to_nat(c), Nat.add(A.quad(i), s)), VB.add_le_at(pos, c, Nat.add(A.quad(i), s), d, e, hd, h1)) :
    {_ == Nat.add(A.quad(Nat.add(k, i)), s) : Nat}
  %Equal.sym(Nat, U32.to_nat(c), A.quad(k), ec) : {Nat.add(_, Nat.add(A.quad(i), s)) == Nat.add(A.quad(Nat.add(k, i)), s) : Nat}
  %VF.quad_add(k, i) : {Nat.add(A.quad(k), Nat.add(A.quad(i), s)) == Nat.add(_, s) : Nat}
  Equal.sym(Nat, Nat.add(Nat.add(A.quad(k), A.quad(i)), s), Nat.add(A.quad(k), Nat.add(A.quad(i), s)), FD.nat__add_assoc(A.quad(k), A.quad(i), s))

# ---- a four-byte write at byte s of word i ---------------------------------------------------

def W32M(+S: U32, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +x: U32) -> FD.array__Tree<U32>: ORW(dd, ORW(dd, D, i, O.shl_bytes(x, S)), 1n+i, O.shr_over(x, S))

def w32m_perfect(+S: U32, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, W32M(S, dd, D, i, x)) == True{} : Bool}:
  orw_perfect(dd, ORW(dd, D, i, O.shl_bytes(x, S)), 1n+i, O.shr_over(x, S), orw_perfect(dd, D, i, O.shl_bytes(x, S), pf))

# The runtime's four-byte write at an unaligned byte position p = 4 i + s (S = s).
def w32u_rt(+S: U32, +s: Nat, +eS: {U32.to_nat(S) == s : Nat}, +hs: {Nat.is_lt(s, 4n) == True{} : Bool}, +hS: {U32.is_eq(S, 0) == False{} : Bool},
    +dd: Nat, +D: FD.array__Tree<U32>, +p: U32, +i: Nat, +x: U32, +e: {U32.to_nat(p) == Nat.add(A.quad(i), s) : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hi: {Nat.is_lt(1n+i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w32(FD.array__thaw(U32, D), p, x) == FD.array__thaw(U32, W32M(S, dd, D, i, x)) : Array<U32>}:
  +e3 = ua_3(p, i, s, S, eS, e, hs)
  +eq = ua_q(p, i, s, e, hs)
  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
  +hi0 = FD.nat__lt_trans(i, 1n+i, VB.pw(dd), FD.nat__lt_succ(i), hi)
  +D1 = ORW(dd, D, i, O.shl_bytes(x, S))
  %Equal.sym(U32, U32.and(p, 3), S, e3) : {O.w32_pick(U32.is_eq(_, 0), FD.array__thaw(U32, D), p, x) == FD.array__thaw(U32, W32M(S, dd, D, i, x)) : Array<U32>}
  %Equal.sym(Bool, U32.is_eq(S, 0), False{}, hS) : {O.w32_pick(_, FD.array__thaw(U32, D), p, x) == FD.array__thaw(U32, W32M(S, dd, D, i, x)) : Array<U32>}
  %Equal.sym(U32, U32.and(p, 3), S, e3) : {O.w32_split(FD.array__thaw(U32, D), p, x, _) == FD.array__thaw(U32, W32M(S, dd, D, i, x)) : Array<U32>}
  %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, D), U32.shrn(p, 2n), O.shl_bytes(x, S)), FD.array__thaw(U32, D1), orw_rt(dd, D, U32.shrn(p, 2n), i, O.shl_bytes(x, S), eq, hd32, hi0, pf)) :
    {O.or_word(_, U32.add(U32.shrn(p, 2n), 1), O.shr_over(x, S)) == FD.array__thaw(U32, W32M(S, dd, D, i, x)) : Array<U32>}
  orw_rt(dd, D1, U32.add(U32.shrn(p, 2n), 1), 1n+i, O.shr_over(x, S),
    Equal.trans(Nat, U32.to_nat(U32.add(U32.shrn(p, 2n), 1)), Nat.add(1n, i), 1n+i, VB.add_at(U32.shrn(p, 2n), 1, i, dd, eq, hd32, hi), {==}),
    hd32, hi, orw_perfect(dd, D, i, O.shl_bytes(x, S), pf))

def orw_orsb_slots(+b: Bool, +dd: Nat, +E: FD.array__Tree<U32>, +j: Nat, +c: U32, +eb: {U32.is_eq(c, 0) == b : Bool},
    +pf: {FD.array__perfect(U32, dd, E) == True{} : Bool}, +hj: {Nat.is_lt(j, VB.pw(dd)) == True{} : Bool})
    -> {SLW(ORW(dd, E, j, c)) == SLW(ORSb(b, dd, E, j, c)) : List<&2, U32>}:
  match b:
    case False{}: {==}
    case True{}:
      %Equal.sym(List<&2, U32>, SLW(ORW(dd, E, j, c)), FD.spec_common__update(U32, SLW(E), j, U32.or(VB.slot(E, j), c)), FD.array__upd_slots(U32, dd, E, j, U32.or(VB.slot(E, j), c), hj, pf)) :
        {_ == SLW(E) : List<&2, U32>}
      %Equal.sym(U32, c, 0, FD.u32alg__eq_of(c, 0, eb)) : {FD.spec_common__update(U32, SLW(E), j, U32.or(VB.slot(E, j), _)) == SLW(E) : List<&2, U32>}
      %Equal.sym(U32, U32.or(VB.slot(E, j), 0), VB.slot(E, j), UWB.or0r(VB.slot(E, j))) : {FD.spec_common__update(U32, SLW(E), j, _) == SLW(E) : List<&2, U32>}
      upd_same_l(SLW(E), j)

def orw_ors_slots(+dd: Nat, +E: FD.array__Tree<U32>, +j: Nat, +c: U32, +pf: {FD.array__perfect(U32, dd, E) == True{} : Bool}, +hj: {Nat.is_lt(j, VB.pw(dd)) == True{} : Bool})
    -> {SLW(ORW(dd, E, j, c)) == SLW(ORS(dd, E, j, c)) : List<&2, U32>}:
  orw_orsb_slots(U32.is_eq(c, 0), dd, E, j, c, {==}, pf, hj)

# ---- words the writers store into ----------------------------------------------------------

def slot_orw_other(+dd: Nat, +E: FD.array__Tree<U32>, +j: Nat, +m: Nat, +v: U32, +pf: {FD.array__perfect(U32, dd, E) == True{} : Bool},
    +hj: {Nat.is_lt(j, VB.pw(dd)) == True{} : Bool}, +ne: {Nat.is_eq(j, m) == False{} : Bool})
    -> {VB.slot(ORW(dd, E, j, v), m) == VB.slot(E, m) : U32}:
  %Equal.sym(List<&2, U32>, SLW(ORW(dd, E, j, v)), FD.spec_common__update(U32, SLW(E), j, U32.or(VB.slot(E, j), v)), FD.array__upd_slots(U32, dd, E, j, U32.or(VB.slot(E, j), v), hj, pf)) :
    {FD.flat__nthc(_, m) == VB.slot(E, m) : U32}
  nthc_upd_other(SLW(E), j, m, U32.or(VB.slot(E, j), v), ne)

# A word wholly inside a zero byte window is zero: word k + i, when the window at
# 4 i + s of m bytes covers its bytes d .. d + 3 (s + d = 4 k, d + r = m', 4 + r' = m', ...).
def zslot(+dd: Nat, +U: FD.array__Tree<U32>, +i: Nat, +s: Nat, +m: Nat, +k: Nat, +d: Nat, +m2: Nat, +r: Nat,
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool},
    +hz: {VS.bt(m, VS.bdr(Nat.add(A.quad(i), s), UA.BYT(U))) == ZB(m) : +List<U32>},
    +hk: {Nat.add(s, d) == A.quad(k) : Nat}, +hm: {Nat.add(d, m2) == m : Nat}, +hr: {Nat.add(4n, r) == m2 : Nat},
    +hw: {VS.bt(4n, VS.bdr(d, ZB(m))) == [0, 0, 0, 0] : +List<U32>},
    +hl: {Nat.is_lt(Nat.add(k, i), VB.pw(dd)) == True{} : Bool})
    -> {VB.slot(U, Nat.add(k, i)) == 0 : U32}:
  +B = UA.BYT(U)
  +X = VS.bdr(Nat.add(A.quad(i), s), UA.BYT(U))
  +hl2 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(k, i), z) == True{} : Bool}, VB.pw(dd), VB.len(SLW(U)), Equal.sym(Nat, VB.len(SLW(U)), VB.pw(dd), FD.array__slots_length(U32, dd, U, pf)), hl)
  +ep = Equal.trans(Nat, A.quad(Nat.add(k, i)), Nat.add(A.quad(k), A.quad(i)), Nat.add(Nat.add(A.quad(i), s), d),
    Equal.sym(Nat, Nat.add(A.quad(k), A.quad(i)), A.quad(Nat.add(k, i)), VF.quad_add(k, i)),
    Equal.trans(Nat, Nat.add(A.quad(k), A.quad(i)), Nat.add(A.quad(i), A.quad(k)), Nat.add(Nat.add(A.quad(i), s), d), FD.nat__add_comm(A.quad(k), A.quad(i)),
      Equal.trans(Nat, Nat.add(A.quad(i), A.quad(k)), Nat.add(A.quad(i), Nat.add(s, d)), Nat.add(Nat.add(A.quad(i), s), d),
        Equal.cong(Nat, Nat, z => Nat.add(A.quad(i), z), A.quad(k), Nat.add(s, d), Equal.sym(Nat, Nat.add(s, d), A.quad(k), hk)),
        Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), s), d), Nat.add(A.quad(i), Nat.add(s, d)), FD.nat__add_assoc(A.quad(i), s, d)))))
  +Y = VS.bdr(d, X)
  +e1 = Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(A.quad(Nat.add(k, i)), B)), VS.bt(4n, VS.bdr(Nat.add(Nat.add(A.quad(i), s), d), B)), VS.bt(4n, VS.bdr(d, X)),
    Equal.cong(Nat, +List<U32>, z => VS.bt(4n, VS.bdr(z, B)), A.quad(Nat.add(k, i)), Nat.add(Nat.add(A.quad(i), s), d), ep),
    Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, z), VS.bdr(Nat.add(Nat.add(A.quad(i), s), d), B), VS.bdr(d, X), bdr_add(Nat.add(A.quad(i), s), d, B)))
  +e2 = FD.logic__subst(Nat, z => {VS.bt(4n, VS.bdr(d, X)) == VS.bt(4n, VS.bt(z, VS.bdr(d, X))) : +List<U32>}, Nat.add(4n, r), m2, hr,
    Equal.sym(+List<U32>, VS.bt(4n, VS.bt(Nat.add(4n, r), VS.bdr(d, X))), VS.bt(4n, VS.bdr(d, X)), VS.bt_bt(4n, r, VS.bdr(d, X))))
  +e3a = FD.logic__subst(Nat, z => {VS.bt(m2, VS.bdr(d, X)) == VS.bdr(d, VS.bt(z, X)) : +List<U32>}, Nat.add(d, m2), m, hm,
    Equal.sym(+List<U32>, VS.bdr(d, VS.bt(Nat.add(d, m2), X)), VS.bt(m2, VS.bdr(d, X)), VS.bdr_bt(d, m2, X)))
  +e3 = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, z), VS.bt(m2, VS.bdr(d, X)), VS.bdr(d, VS.bt(m, X)), e3a)
  +e4 = FD.logic__subst(+List<U32>, z => {VS.bt(4n, VS.bdr(d, z)) == [0, 0, 0, 0] : +List<U32>}, ZB(m), VS.bt(m, X), Equal.sym(+List<U32>, VS.bt(m, X), ZB(m), hz), hw)
  +w4 = Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(A.quad(Nat.add(k, i)), B)), VS.bt(4n, VS.bdr(d, X)), [0, 0, 0, 0], e1,
    Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(d, X)), VS.bt(4n, VS.bt(m2, VS.bdr(d, X))), [0, 0, 0, 0], e2,
      Equal.trans(+List<U32>, VS.bt(4n, VS.bt(m2, VS.bdr(d, X))), VS.bt(4n, VS.bdr(d, VS.bt(m, X))), [0, 0, 0, 0], e3, e4)))
  UWB.zw(VB.slot(U, Nat.add(k, i)), Equal.trans(+List<U32>, I.limb(VB.slot(U, Nat.add(k, i))), VS.bt(4n, VS.bdr(A.quad(Nat.add(k, i)), B)), [0, 0, 0, 0],
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(A.quad(Nat.add(k, i)), B)), I.limb(VB.slot(U, Nat.add(k, i))), slot_limb(SLW(U), Nat.add(k, i), hl2)), w4))

def ne_off(+a: Nat, +b: Nat, +i: Nat, +h: {Nat.is_le(1n+a, b) == True{} : Bool}) -> {Nat.is_eq(Nat.add(a, i), Nat.add(b, i)) == False{} : Bool}:
  FD.nat__is_eq_lt(Nat.add(a, i), Nat.add(b, i), FD.nat__succ_le_lt(Nat.add(a, i), Nat.add(b, i), Order.add_right(1n+a, b, i, h)))

def lt_off(+a: Nat, +b: Nat, +i: Nat, +P: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}, +hb: {Nat.is_lt(Nat.add(b, i), P) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(a, i), P) == True{} : Bool}:
  FD.nat__le_lt_trans(Nat.add(a, i), Nat.add(b, i), P, Order.add_right(a, b, i, h), hb)
