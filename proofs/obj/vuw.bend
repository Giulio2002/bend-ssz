import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found_generated.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vua.bend as UA
import ./vfix.bend as VF
import ./vua_copy.bend as UC
import ./vbrt.bend as VR
import ./vu32.bend as VU
import ./vcopy.bend as VC
import ./vdepth.bend as VD
import ../compact/reads.bend as RD
import ./vuw_bits_generated.bend as UWB
import ./word_mul_generated.bend as WM

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
def qpw(+d: Nat) -> {A.quad(VB.pw(d)) == VB.pw(2n+d) : Nat}: {==}

# 4 2^d <= 2^32 for d < 31.
def q32(+d: Nat, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}) -> {Nat.is_le(A.quad(VB.pw(d)), FD.spec_common__pow2(32n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(32n)) == True{} : Bool}, VB.pw(2n+d), A.quad(VB.pw(d)), Equal.sym(Nat, A.quad(VB.pw(d)), VB.pw(2n+d), qpw(d)), VB.pw2d32(d, hd))

# ua_add with its sum below 2^32 (any output depth).
def ua_addS(+pos: U32, +c: U32, +i: Nat, +k: Nat, +s: Nat, +e: {U32.to_nat(pos) == Nat.add(A.quad(i), s) : Nat}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hb: {Nat.is_lt(Nat.add(A.quad(k), Nat.add(A.quad(i), s)), FD.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(pos, c)) == Nat.add(A.quad(Nat.add(k, i)), s) : Nat}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, Nat.add(A.quad(i), s)), FD.spec_common__pow2(32n)) == True{} : Bool}, A.quad(k), U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), A.quad(k), ec), hb)
  %Equal.sym(Nat, U32.to_nat(U32.add(pos, c)), Nat.add(U32.to_nat(c), Nat.add(A.quad(i), s)), VB.add_lt32(pos, c, Nat.add(A.quad(i), s), e, h1)) :
    {_ == Nat.add(A.quad(Nat.add(k, i)), s) : Nat}
  %Equal.sym(Nat, U32.to_nat(c), A.quad(k), ec) : {Nat.add(_, Nat.add(A.quad(i), s)) == Nat.add(A.quad(Nat.add(k, i)), s) : Nat}
  %VF.quad_add(k, i) : {Nat.add(A.quad(k), Nat.add(A.quad(i), s)) == Nat.add(_, s) : Nat}
  Equal.sym(Nat, Nat.add(Nat.add(A.quad(k), A.quad(i)), s), Nat.add(A.quad(k), Nat.add(A.quad(i), s)), FD.nat__add_assoc(A.quad(k), A.quad(i), s))

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

# ---- the model in pieces ---------------------------------------------------------------------

# SWc without its last carry word, and that carry.
def SWo(+S: U32, ws: +List<U32>, +dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +c: U32) -> FD.array__Tree<U32>:
  match ws:
    case Nil{}: D
    case Con{+w, t}: SWo(S, t, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S))

def CRY(+S: U32, ws: +List<U32>, +c: U32) -> U32:
  match ws:
    case Nil{}: c
    case Con{+w, t}: CRY(S, t, O.shr_over(w, S))

law swc_swo:
  for +S: U32
  for +ws: +List<U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +i: Nat
  for +c: U32
  {SWc(S, ws, dd, D, i, c) == ORS(dd, SWo(S, ws, dd, D, i, c), Nat.add(List.length(&2, U32, ws), i), CRY(S, ws, c)) : FD.array__Tree<U32>}
def swc_swo(S, ws, dd, D, i, c):
  match ws:
    case Nil{}: {==}
    case Con{+w, +t}:
      %FD.nat__add_succ(List.length(&2, U32, t), i) :
        {SWc(S, t, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S)) == ORS(dd, SWo(S, t, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S)), _, CRY(S, t, O.shr_over(w, S))) : FD.array__Tree<U32>}
      swc_swo(S, t, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S))

law swo_app:
  for +S: U32
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +i: Nat
  for +c: U32
  {SWo(S, List.append(&2, U32, xs, ys), dd, D, i, c) == SWo(S, ys, dd, SWo(S, xs, dd, D, i, c), Nat.add(List.length(&2, U32, xs), i), CRY(S, xs, c)) : FD.array__Tree<U32>}
def swo_app(S, xs, ys, dd, D, i, c):
  match xs:
    case Nil{}: {==}
    case Con{+w, +t}:
      %FD.nat__add_succ(List.length(&2, U32, t), i) :
        {SWo(S, List.append(&2, U32, t, ys), dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S)) == SWo(S, ys, dd, SWo(S, t, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S)), _, CRY(S, t, O.shr_over(w, S))) : FD.array__Tree<U32>}
      swo_app(S, t, ys, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S))

law cry_app:
  for +S: U32
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +c: U32
  {CRY(S, List.append(&2, U32, xs, ys), c) == CRY(S, ys, CRY(S, xs, c)) : U32}
def cry_app(S, xs, ys, c):
  match xs:
    case Nil{}: {==}
    case Con{+w, +t}: cry_app(S, t, ys, O.shr_over(w, S))

# ---- zero windows ------------------------------------------------------------------------------

law zb_win:
  for +d: Nat
  for +a: Nat
  for +m: Nat
  for +h: {Nat.is_le(Nat.add(d, a), m) == True{} : Bool}
  {VS.bt(a, VS.bdr(d, ZB(m))) == ZB(a) : +List<U32>}
def zb_win(d, a, m, h):
  match d a m:
    case 0n 0n _: {==}
    case 0n 1n+ +p 0n: Empty.absurd({VS.bt(1n+p, VS.bdr(0n, ZB(0n))) == ZB(1n+p) : +List<U32>}, FD.logic__false_true(h))
    case 0n 1n+ +p 1n+ +q: Equal.cong(+List<U32>, +List<U32>, z => Con{0, z}, VS.bt(p, VS.bdr(0n, ZB(q))), ZB(p), zb_win(0n, p, q, h))
    case 1n+ +e +a2 0n: Empty.absurd({VS.bt(a2, VS.bdr(1n+e, ZB(0n))) == ZB(a2) : +List<U32>}, FD.logic__false_true(h))
    case 1n+ +e +a2 1n+ +q: zb_win(e, a2, q, h)

law bt_le_m:
  for +a: Nat
  for +m: Nat
  for +xs: +List<U32>
  for +h: {Nat.is_le(Nat.add(0n, a), m) == True{} : Bool}
  {VS.bt(a, VS.bt(m, xs)) == VS.bt(a, xs) : +List<U32>}
def bt_le_m(a, m, xs, h):
  match a m xs:
    case 0n _ _: {==}
    case 1n+ +p 0n _: Empty.absurd({VS.bt(1n+p, VS.bt(0n, xs)) == VS.bt(1n+p, xs) : +List<U32>}, FD.logic__false_true(h))
    case 1n+ +p 1n+ +q Nil{}: {==}
    case 1n+ +p 1n+ +q Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, VS.bt(p, VS.bt(q, t)), VS.bt(p, t), bt_le_m(p, q, t, h))

law bt_bdr_bt:
  for +a: Nat
  for +d: Nat
  for +m: Nat
  for +xs: +List<U32>
  for +h: {Nat.is_le(Nat.add(d, a), m) == True{} : Bool}
  {VS.bt(a, VS.bdr(d, xs)) == VS.bt(a, VS.bdr(d, VS.bt(m, xs))) : +List<U32>}
def bt_bdr_bt(a, d, m, xs, h):
  match d m xs:
    case 0n _ _:
      Equal.sym(+List<U32>, VS.bt(a, VS.bt(m, xs)), VS.bt(a, xs), bt_le_m(a, m, xs, h))
    case 1n+ +e 0n _: Empty.absurd({VS.bt(a, VS.bdr(1n+e, xs)) == VS.bt(a, VS.bdr(1n+e, VS.bt(0n, xs))) : +List<U32>}, FD.logic__false_true(h))
    case 1n+ +e 1n+ +q Nil{}: {==}
    case 1n+ +e 1n+ +q Con{+x, +t}: bt_bdr_bt(a, e, q, t, h)

# A word inside a zero window of the bytes at 4 i + s is zero (s + d = 4 k, d + 4 <= m).
def zslot_g(+dd: Nat, +U: FD.array__Tree<U32>, +i: Nat, +s: Nat, +m: Nat, +k: Nat, +d: Nat,
    +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool},
    +hz: {VS.bt(m, VS.bdr(Nat.add(A.quad(i), s), UA.BYT(U))) == ZB(m) : +List<U32>},
    +hk: {Nat.add(s, d) == A.quad(k) : Nat}, +hm: {Nat.is_le(Nat.add(d, 4n), m) == True{} : Bool},
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
  +e1 = Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(A.quad(Nat.add(k, i)), B)), VS.bt(4n, VS.bdr(Nat.add(Nat.add(A.quad(i), s), d), B)), VS.bt(4n, VS.bdr(d, X)),
    Equal.cong(Nat, +List<U32>, z => VS.bt(4n, VS.bdr(z, B)), A.quad(Nat.add(k, i)), Nat.add(Nat.add(A.quad(i), s), d), ep),
    Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, z), VS.bdr(Nat.add(Nat.add(A.quad(i), s), d), B), VS.bdr(d, X), bdr_add(Nat.add(A.quad(i), s), d, B)))
  +e2 = bt_bdr_bt(4n, d, m, X, hm)
  +e3 = FD.logic__subst(+List<U32>, z => {VS.bt(4n, VS.bdr(d, z)) == ZB(4n) : +List<U32>}, ZB(m), VS.bt(m, X), Equal.sym(+List<U32>, VS.bt(m, X), ZB(m), hz), zb_win(d, 4n, m, hm))
  UWB.zw(VB.slot(U, Nat.add(k, i)), Equal.trans(+List<U32>, I.limb(VB.slot(U, Nat.add(k, i))), VS.bt(4n, VS.bdr(A.quad(Nat.add(k, i)), B)), [0, 0, 0, 0],
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(A.quad(Nat.add(k, i)), B)), I.limb(VB.slot(U, Nat.add(k, i))), slot_limb(SLW(U), Nat.add(k, i), hl2)),
    Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(A.quad(Nat.add(k, i)), B)), VS.bt(4n, VS.bdr(d, X)), [0, 0, 0, 0], e1,
      Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(d, X)), VS.bt(4n, VS.bdr(d, VS.bt(m, X))), [0, 0, 0, 0], e2, e3))))

def quad_le(+x: Nat, +y: Nat, +h: {Nat.is_le(x, y) == True{} : Bool}) -> {Nat.is_le(A.quad(x), A.quad(y)) == True{} : Bool}:
  FD.nat__double_le(Nat.double(x), Nat.double(y), FD.nat__double_le(x, y, h))

law bdr_skip_l:
  for +X: +List<U32>
  for +k: Nat
  for +R: +List<U32>
  {VS.bdr(Nat.add(k, List.length(&2, U32, X)), List.append(&2, U32, X, R)) == VS.bdr(k, R) : +List<U32>}
def bdr_skip_l(X, k, R):
  match X:
    case Nil{}:
      %Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)) : {VS.bdr(_, R) == VS.bdr(k, R) : +List<U32>}
      {==}
    case Con{+x, +t}:
      %Equal.sym(Nat, Nat.add(k, 1n+List.length(&2, U32, t)), 1n+Nat.add(k, List.length(&2, U32, t)), FD.nat__add_succ(k, List.length(&2, U32, t))) : {VS.bdr(_, List.append(&2, U32, Con{x, t}, R)) == VS.bdr(k, R) : +List<U32>}
      bdr_skip_l(t, k, R)

def bdr_over(+X: +List<U32>, +n: Nat, +V: +List<U32>, +R: +List<U32>, +hn: {List.length(&2, U32, X) == n : Nat})
    -> {VS.bdr(4n+n, List.append(&2, U32, X, List.append(&2, U32, V, R))) == VS.bdr(4n, List.append(&2, U32, V, R)) : +List<U32>}:
  %hn : {VS.bdr(4n+_, List.append(&2, U32, X, List.append(&2, U32, V, R))) == VS.bdr(4n, List.append(&2, U32, V, R)) : +List<U32>}
  bdr_skip_l(X, 4n, List.append(&2, U32, V, R))

# The bytes after an updated word are the tree's.
def upd_frame(+dd: Nat, +D: FD.array__Tree<U32>, +j: Nat, +v: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_lt(j, VB.pw(dd)) == True{} : Bool})
    -> {VS.bdr(4n+A.quad(j), UA.BYT(FD.array__upd(U32, dd, D, j, v))) == VS.bdr(4n+A.quad(j), UA.BYT(D)) : +List<U32>}:
  +hl = FD.array__len_lt(U32, dd, D, j, pf, hj)
  +B = UA.BYT(D)
  +hq = FD.logic__subst(Nat, z => {Nat.is_le(A.quad(j), z) == True{} : Bool}, A.quad(VB.pw(dd)), List.length(&2, U32, B), Equal.sym(Nat, List.length(&2, U32, B), A.quad(VB.pw(dd)), VR.lenS(dd, D, pf)),
    quad_le(j, VB.pw(dd), FD.nat__lt_le(j, VB.pw(dd), hj)))
  %Equal.sym(List<&2, U32>, SLW(FD.array__upd(U32, dd, D, j, v)), FD.spec_common__update(U32, SLW(D), j, v), FD.array__upd_slots(U32, dd, D, j, v, hj, pf)) :
    {VS.bdr(4n+A.quad(j), FX.limbs(_)) == VS.bdr(4n+A.quad(j), B) : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(FD.spec_common__update(U32, SLW(D), j, v)), List.append(&2, U32, VS.bt(A.quad(j), B), List.append(&2, U32, I.limb(v), VS.bdr(4n+A.quad(j), B))), limbs_upd(SLW(D), j, v, hl)) :
    {VS.bdr(4n+A.quad(j), _) == VS.bdr(4n+A.quad(j), B) : +List<U32>}
  bdr_over(VS.bt(A.quad(j), B), A.quad(j), I.limb(v), VS.bdr(4n+A.quad(j), B), VS.bt_len(A.quad(j), B, hq))


law cry_take:
  for +S: U32
  for +p: Nat
  for +y: Nat
  for +L: List<&2, U32>
  for +c: U32
  for +h: {Nat.is_lt(Nat.add(p, y), VB.len(L)) == True{} : Bool}
  {CRY(S, VS.wtake(1n+p, VB.wdr(y, L)), c) == O.shr_over(FD.flat__nthc(L, Nat.add(p, y)), S) : U32}
def cry_take(S, p, y, L, c, h):
  match p:
    case 0n:
      +hy = FD.nat__le_lt_trans(y, Nat.add(0n, y), VB.len(L), Order.left_below_sum(0n, y), h)
      %Equal.sym(List<&2, U32>, VB.wdr(y, L), Con{FD.flat__nthc(L, y), VB.wdr(1n+y, L)}, wdr_con(L, y, hy)) :
        {CRY(S, VS.wtake(1n, _), c) == O.shr_over(FD.flat__nthc(L, y), S) : U32}
      {==}
    case 1n+ +e:
      +hy = FD.nat__le_lt_trans(y, Nat.add(1n+e, y), VB.len(L), Order.left_below_sum(1n+e, y), h)
      %Equal.sym(List<&2, U32>, VB.wdr(y, L), Con{FD.flat__nthc(L, y), VB.wdr(1n+y, L)}, wdr_con(L, y, hy)) :
        {CRY(S, VS.wtake(2n+e, _), c) == O.shr_over(FD.flat__nthc(L, 1n+Nat.add(e, y)), S) : U32}
      %FD.nat__add_succ(e, y) :
        {CRY(S, VS.wtake(1n+e, VB.wdr(1n+y, L)), O.shr_over(FD.flat__nthc(L, y), S)) == O.shr_over(FD.flat__nthc(L, _), S) : U32}
      cry_take(S, e, 1n+y, L, O.shr_over(FD.flat__nthc(L, y), S), FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(L)) == True{} : Bool}, 1n+Nat.add(e, y), Nat.add(e, 1n+y), Equal.sym(Nat, Nat.add(e, 1n+y), 1n+Nat.add(e, y), FD.nat__add_succ(e, y)), h))

law app_eq:
  for +xs: List<&2, U32>
  for +ys: List<&2, U32>
  {VF.app(xs, ys) == List.append(&2, U32, xs, ys) : List<&2, U32>}
def app_eq(xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{x, z}, VF.app(t, ys), List.append(&2, U32, t, ys), app_eq(t, ys))

law len_take:
  for +k: Nat
  for +L: List<&2, U32>
  for +h: {Nat.is_le(k, VB.len(L)) == True{} : Bool}
  {List.length(&2, U32, VS.wtake(k, L)) == k : Nat}
def len_take(k, L, h):
  match k L:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({List.length(&2, U32, VS.wtake(1n+p, Nil{})) == 1n+p : Nat}, FD.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: Equal.cong(Nat, Nat, z => 1n+z, List.length(&2, U32, VS.wtake(p, t)), p, len_take(p, t, h))

law le_wdr:
  for +i: Nat
  for +k: Nat
  for +L: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(i, k), VB.len(L)) == True{} : Bool}
  {Nat.is_le(k, VB.len(VB.wdr(i, L))) == True{} : Bool}
def le_wdr(i, k, L, h):
  match i L:
    case 0n _: h
    case 1n+ +p Nil{}: Empty.absurd({Nat.is_le(k, VB.len(VB.wdr(1n+p, Nil{}))) == True{} : Bool}, FD.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: le_wdr(p, k, t, h)

# The run's three pieces (its first word, the shifted copy of M words, the OR loop over
# KN words) and the carry after them are the model of the whole run.
def asm(+S: U32, +dd: Nat, +U: FD.array__Tree<U32>, +i: Nat, +L: List<&2, U32>, +M: Nat, +KN: Nat,
    +hl: {Nat.is_le(1n+Nat.add(M, KN), VB.len(L)) == True{} : Bool})
    -> {ORS(dd, SWo(S, VS.wtake(KN, VB.wdr(1n+M, L)), dd, SWo(S, VS.wtake(M, VB.wdr(1n, L)), dd, SWo(S, VS.wtake(1n, L), dd, U, i, 0), 1n+i, O.shr_over(FD.flat__nthc(L, 0n), S)), Nat.add(1n+M, i), CRY(S, VS.wtake(M, VB.wdr(1n, L)), O.shr_over(FD.flat__nthc(L, 0n), S))), Nat.add(1n+Nat.add(M, KN), i), CRY(S, VS.wtake(KN, VB.wdr(1n+M, L)), CRY(S, VS.wtake(M, VB.wdr(1n, L)), O.shr_over(FD.flat__nthc(L, 0n), S)))) == SWc(S, VS.wtake(1n+Nat.add(M, KN), L), dd, U, i, 0) : FD.array__Tree<U32>}:
  +C1 = O.shr_over(FD.flat__nthc(L, 0n), S)
  +A1 = VS.wtake(1n, L)
  +A2 = VS.wtake(M, VB.wdr(1n, L))
  +A3 = VS.wtake(KN, VB.wdr(1n+M, L))
  +W = VS.wtake(1n+Nat.add(M, KN), L)
  +D1 = SWo(S, A1, dd, U, i, 0)
  +C2 = CRY(S, A2, C1)
  +D2 = SWo(S, A2, dd, D1, 1n+i, C1)
  +D3 = SWo(S, A3, dd, D2, Nat.add(1n+M, i), C2)
  +C3 = CRY(S, A3, C2)
  +h1 = FD.nat__le_trans(1n, 1n+Nat.add(M, KN), VB.len(L), FD.nat__zero_le(Nat.add(M, KN)), hl)
  +hM = le_wdr(1n, M, L, FD.nat__le_trans(Nat.add(1n, M), 1n+Nat.add(M, KN), VB.len(L), Order.below_sum(M, KN), hl))
  +eA1 = len_take(1n, L, h1)
  +eA2 = len_take(M, VB.wdr(1n, L), hM)
  +eW = len_take(1n+Nat.add(M, KN), L, hl)
  +eC1 = cry_take(S, 0n, 0n, L, 0, FD.nat__lt_le_trans(0n, 1n, VB.len(L), {==}, h1))
  +eL = Equal.trans(List<&2, U32>, W, VF.app(A1, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L))), List.append(&2, U32, A1, List.append(&2, U32, A2, A3)),
    VF.take_split(1n, Nat.add(M, KN), L),
    Equal.trans(List<&2, U32>, VF.app(A1, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L))), VF.app(A1, List.append(&2, U32, A2, A3)), List.append(&2, U32, A1, List.append(&2, U32, A2, A3)),
      Equal.cong(List<&2, U32>, List<&2, U32>, z => VF.app(A1, z), VS.wtake(Nat.add(M, KN), VB.wdr(1n, L)), List.append(&2, U32, A2, A3),
        Equal.trans(List<&2, U32>, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L)), VF.app(A2, VS.wtake(KN, VB.wdr(M, VB.wdr(1n, L)))), List.append(&2, U32, A2, A3),
          VF.take_split(M, KN, VB.wdr(1n, L)),
          Equal.trans(List<&2, U32>, VF.app(A2, VS.wtake(KN, VB.wdr(M, VB.wdr(1n, L)))), VF.app(A2, A3), List.append(&2, U32, A2, A3),
            Equal.cong(List<&2, U32>, List<&2, U32>, z => VF.app(A2, VS.wtake(KN, z)), VB.wdr(M, VB.wdr(1n, L)), VB.wdr(1n+M, L), VF.wdr_add(M, 1n, L)),
            app_eq(A2, A3)))),
      app_eq(A1, List.append(&2, U32, A2, A3))))
  +s1 = swo_app(S, A1, List.append(&2, U32, A2, A3), dd, U, i, 0)
  +s2 = swo_app(S, A2, A3, dd, D1, 1n+i, C1)
  +eS = Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), dd, U, i, 0),
    SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)), D3, s1,
    Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)),
      SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1), D3,
      Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)),
        SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(1n, i), CRY(S, A1, 0)), SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1),
        Equal.cong(Nat, FD.array__Tree<U32>, z => SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(z, i), CRY(S, A1, 0)), List.length(&2, U32, A1), 1n, eA1),
        Equal.cong(U32, FD.array__Tree<U32>, z => SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, z), CRY(S, A1, 0), C1, eC1)),
      Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1), SWo(S, A3, dd, D2, Nat.add(List.length(&2, U32, A2), 1n+i), C2), D3, s2,
        Equal.cong(Nat, FD.array__Tree<U32>, z => SWo(S, A3, dd, D2, z, C2), Nat.add(List.length(&2, U32, A2), 1n+i), Nat.add(1n+M, i),
          Equal.trans(Nat, Nat.add(List.length(&2, U32, A2), 1n+i), Nat.add(M, 1n+i), Nat.add(1n+M, i),
            Equal.cong(Nat, Nat, z => Nat.add(z, 1n+i), List.length(&2, U32, A2), M, eA2), FD.nat__add_succ(M, i))))))
  +eC = Equal.trans(U32, CRY(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), 0), CRY(S, List.append(&2, U32, A2, A3), CRY(S, A1, 0)), C3,
    cry_app(S, A1, List.append(&2, U32, A2, A3), 0),
    Equal.trans(U32, CRY(S, List.append(&2, U32, A2, A3), CRY(S, A1, 0)), CRY(S, List.append(&2, U32, A2, A3), C1), C3,
      Equal.cong(U32, U32, z => CRY(S, List.append(&2, U32, A2, A3), z), CRY(S, A1, 0), C1, eC1),
      cry_app(S, A2, A3, C1)))
  %Equal.sym(FD.array__Tree<U32>, SWc(S, W, dd, U, i, 0), ORS(dd, SWo(S, W, dd, U, i, 0), Nat.add(List.length(&2, U32, W), i), CRY(S, W, 0)), swc_swo(S, W, dd, U, i, 0)) :
    {ORS(dd, D3, Nat.add(1n+Nat.add(M, KN), i), C3) == _ : FD.array__Tree<U32>}
  %Equal.sym(Nat, List.length(&2, U32, W), 1n+Nat.add(M, KN), eW) : {ORS(dd, D3, Nat.add(1n+Nat.add(M, KN), i), C3) == ORS(dd, SWo(S, W, dd, U, i, 0), Nat.add(_, i), CRY(S, W, 0)) : FD.array__Tree<U32>}
  %Equal.sym(List<&2, U32>, W, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), eL) :
    {ORS(dd, D3, Nat.add(1n+Nat.add(M, KN), i), C3) == ORS(dd, SWo(S, _, dd, U, i, 0), Nat.add(1n+Nat.add(M, KN), i), CRY(S, W, 0)) : FD.array__Tree<U32>}
  %Equal.sym(List<&2, U32>, W, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), eL) :
    {ORS(dd, D3, Nat.add(1n+Nat.add(M, KN), i), C3) == ORS(dd, SWo(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), dd, U, i, 0), Nat.add(1n+Nat.add(M, KN), i), CRY(S, _, 0)) : FD.array__Tree<U32>}
  %Equal.sym(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), dd, U, i, 0), D3, eS) :
    {ORS(dd, D3, Nat.add(1n+Nat.add(M, KN), i), C3) == ORS(dd, _, Nat.add(1n+Nat.add(M, KN), i), CRY(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), 0)) : FD.array__Tree<U32>}
  %Equal.sym(U32, CRY(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), 0), C3, eC) :
    {ORS(dd, D3, Nat.add(1n+Nat.add(M, KN), i), C3) == ORS(dd, D3, Nat.add(1n+Nat.add(M, KN), i), _) : FD.array__Tree<U32>}
  {==}

# The run's three pieces are the open model of the whole run, and their carry its carry.
def asm_o(+S: U32, +dd: Nat, +U: FD.array__Tree<U32>, +i: Nat, +L: List<&2, U32>, +M: Nat, +KN: Nat,
    +hl: {Nat.is_le(1n+Nat.add(M, KN), VB.len(L)) == True{} : Bool})
    -> {SWo(S, VS.wtake(KN, VB.wdr(1n+M, L)), dd, SWo(S, VS.wtake(M, VB.wdr(1n, L)), dd, SWo(S, VS.wtake(1n, L), dd, U, i, 0), 1n+i, O.shr_over(FD.flat__nthc(L, 0n), S)), Nat.add(1n+M, i), CRY(S, VS.wtake(M, VB.wdr(1n, L)), O.shr_over(FD.flat__nthc(L, 0n), S))) == SWo(S, VS.wtake(1n+Nat.add(M, KN), L), dd, U, i, 0) : FD.array__Tree<U32>}:
  +C1 = O.shr_over(FD.flat__nthc(L, 0n), S)
  +A1 = VS.wtake(1n, L)
  +A2 = VS.wtake(M, VB.wdr(1n, L))
  +A3 = VS.wtake(KN, VB.wdr(1n+M, L))
  +W = VS.wtake(1n+Nat.add(M, KN), L)
  +D1 = SWo(S, A1, dd, U, i, 0)
  +C2 = CRY(S, A2, C1)
  +D2 = SWo(S, A2, dd, D1, 1n+i, C1)
  +D3 = SWo(S, A3, dd, D2, Nat.add(1n+M, i), C2)
  +C3 = CRY(S, A3, C2)
  +h1 = FD.nat__le_trans(1n, 1n+Nat.add(M, KN), VB.len(L), FD.nat__zero_le(Nat.add(M, KN)), hl)
  +hM = le_wdr(1n, M, L, FD.nat__le_trans(Nat.add(1n, M), 1n+Nat.add(M, KN), VB.len(L), Order.below_sum(M, KN), hl))
  +eA1 = len_take(1n, L, h1)
  +eA2 = len_take(M, VB.wdr(1n, L), hM)
  +eW = len_take(1n+Nat.add(M, KN), L, hl)
  +eC1 = cry_take(S, 0n, 0n, L, 0, FD.nat__lt_le_trans(0n, 1n, VB.len(L), {==}, h1))
  +eL = Equal.trans(List<&2, U32>, W, VF.app(A1, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L))), List.append(&2, U32, A1, List.append(&2, U32, A2, A3)),
    VF.take_split(1n, Nat.add(M, KN), L),
    Equal.trans(List<&2, U32>, VF.app(A1, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L))), VF.app(A1, List.append(&2, U32, A2, A3)), List.append(&2, U32, A1, List.append(&2, U32, A2, A3)),
      Equal.cong(List<&2, U32>, List<&2, U32>, z => VF.app(A1, z), VS.wtake(Nat.add(M, KN), VB.wdr(1n, L)), List.append(&2, U32, A2, A3),
        Equal.trans(List<&2, U32>, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L)), VF.app(A2, VS.wtake(KN, VB.wdr(M, VB.wdr(1n, L)))), List.append(&2, U32, A2, A3),
          VF.take_split(M, KN, VB.wdr(1n, L)),
          Equal.trans(List<&2, U32>, VF.app(A2, VS.wtake(KN, VB.wdr(M, VB.wdr(1n, L)))), VF.app(A2, A3), List.append(&2, U32, A2, A3),
            Equal.cong(List<&2, U32>, List<&2, U32>, z => VF.app(A2, VS.wtake(KN, z)), VB.wdr(M, VB.wdr(1n, L)), VB.wdr(1n+M, L), VF.wdr_add(M, 1n, L)),
            app_eq(A2, A3)))),
      app_eq(A1, List.append(&2, U32, A2, A3))))
  +s1 = swo_app(S, A1, List.append(&2, U32, A2, A3), dd, U, i, 0)
  +s2 = swo_app(S, A2, A3, dd, D1, 1n+i, C1)
  +eS = Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), dd, U, i, 0),
    SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)), D3, s1,
    Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)),
      SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1), D3,
      Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)),
        SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(1n, i), CRY(S, A1, 0)), SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1),
        Equal.cong(Nat, FD.array__Tree<U32>, z => SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(z, i), CRY(S, A1, 0)), List.length(&2, U32, A1), 1n, eA1),
        Equal.cong(U32, FD.array__Tree<U32>, z => SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, z), CRY(S, A1, 0), C1, eC1)),
      Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1), SWo(S, A3, dd, D2, Nat.add(List.length(&2, U32, A2), 1n+i), C2), D3, s2,
        Equal.cong(Nat, FD.array__Tree<U32>, z => SWo(S, A3, dd, D2, z, C2), Nat.add(List.length(&2, U32, A2), 1n+i), Nat.add(1n+M, i),
          Equal.trans(Nat, Nat.add(List.length(&2, U32, A2), 1n+i), Nat.add(M, 1n+i), Nat.add(1n+M, i),
            Equal.cong(Nat, Nat, z => Nat.add(z, 1n+i), List.length(&2, U32, A2), M, eA2), FD.nat__add_succ(M, i))))))
  +eC = Equal.trans(U32, CRY(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), 0), CRY(S, List.append(&2, U32, A2, A3), CRY(S, A1, 0)), C3,
    cry_app(S, A1, List.append(&2, U32, A2, A3), 0),
    Equal.trans(U32, CRY(S, List.append(&2, U32, A2, A3), CRY(S, A1, 0)), CRY(S, List.append(&2, U32, A2, A3), C1), C3,
      Equal.cong(U32, U32, z => CRY(S, List.append(&2, U32, A2, A3), z), CRY(S, A1, 0), C1, eC1),
      cry_app(S, A2, A3, C1)))
  Equal.sym(FD.array__Tree<U32>, SWo(S, W, dd, U, i, 0), D3,
    Equal.trans(FD.array__Tree<U32>, SWo(S, W, dd, U, i, 0), SWo(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), dd, U, i, 0), D3,
      Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => SWo(S, z, dd, U, i, 0), W, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), eL), eS))

def asm_c(+S: U32, +dd: Nat, +U: FD.array__Tree<U32>, +i: Nat, +L: List<&2, U32>, +M: Nat, +KN: Nat,
    +hl: {Nat.is_le(1n+Nat.add(M, KN), VB.len(L)) == True{} : Bool})
    -> {CRY(S, VS.wtake(KN, VB.wdr(1n+M, L)), CRY(S, VS.wtake(M, VB.wdr(1n, L)), O.shr_over(FD.flat__nthc(L, 0n), S))) == CRY(S, VS.wtake(1n+Nat.add(M, KN), L), 0) : U32}:
  +C1 = O.shr_over(FD.flat__nthc(L, 0n), S)
  +A1 = VS.wtake(1n, L)
  +A2 = VS.wtake(M, VB.wdr(1n, L))
  +A3 = VS.wtake(KN, VB.wdr(1n+M, L))
  +W = VS.wtake(1n+Nat.add(M, KN), L)
  +D1 = SWo(S, A1, dd, U, i, 0)
  +C2 = CRY(S, A2, C1)
  +D2 = SWo(S, A2, dd, D1, 1n+i, C1)
  +D3 = SWo(S, A3, dd, D2, Nat.add(1n+M, i), C2)
  +C3 = CRY(S, A3, C2)
  +h1 = FD.nat__le_trans(1n, 1n+Nat.add(M, KN), VB.len(L), FD.nat__zero_le(Nat.add(M, KN)), hl)
  +hM = le_wdr(1n, M, L, FD.nat__le_trans(Nat.add(1n, M), 1n+Nat.add(M, KN), VB.len(L), Order.below_sum(M, KN), hl))
  +eA1 = len_take(1n, L, h1)
  +eA2 = len_take(M, VB.wdr(1n, L), hM)
  +eW = len_take(1n+Nat.add(M, KN), L, hl)
  +eC1 = cry_take(S, 0n, 0n, L, 0, FD.nat__lt_le_trans(0n, 1n, VB.len(L), {==}, h1))
  +eL = Equal.trans(List<&2, U32>, W, VF.app(A1, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L))), List.append(&2, U32, A1, List.append(&2, U32, A2, A3)),
    VF.take_split(1n, Nat.add(M, KN), L),
    Equal.trans(List<&2, U32>, VF.app(A1, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L))), VF.app(A1, List.append(&2, U32, A2, A3)), List.append(&2, U32, A1, List.append(&2, U32, A2, A3)),
      Equal.cong(List<&2, U32>, List<&2, U32>, z => VF.app(A1, z), VS.wtake(Nat.add(M, KN), VB.wdr(1n, L)), List.append(&2, U32, A2, A3),
        Equal.trans(List<&2, U32>, VS.wtake(Nat.add(M, KN), VB.wdr(1n, L)), VF.app(A2, VS.wtake(KN, VB.wdr(M, VB.wdr(1n, L)))), List.append(&2, U32, A2, A3),
          VF.take_split(M, KN, VB.wdr(1n, L)),
          Equal.trans(List<&2, U32>, VF.app(A2, VS.wtake(KN, VB.wdr(M, VB.wdr(1n, L)))), VF.app(A2, A3), List.append(&2, U32, A2, A3),
            Equal.cong(List<&2, U32>, List<&2, U32>, z => VF.app(A2, VS.wtake(KN, z)), VB.wdr(M, VB.wdr(1n, L)), VB.wdr(1n+M, L), VF.wdr_add(M, 1n, L)),
            app_eq(A2, A3)))),
      app_eq(A1, List.append(&2, U32, A2, A3))))
  +s1 = swo_app(S, A1, List.append(&2, U32, A2, A3), dd, U, i, 0)
  +s2 = swo_app(S, A2, A3, dd, D1, 1n+i, C1)
  +eS = Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), dd, U, i, 0),
    SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)), D3, s1,
    Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)),
      SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1), D3,
      Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(List.length(&2, U32, A1), i), CRY(S, A1, 0)),
        SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(1n, i), CRY(S, A1, 0)), SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1),
        Equal.cong(Nat, FD.array__Tree<U32>, z => SWo(S, List.append(&2, U32, A2, A3), dd, D1, Nat.add(z, i), CRY(S, A1, 0)), List.length(&2, U32, A1), 1n, eA1),
        Equal.cong(U32, FD.array__Tree<U32>, z => SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, z), CRY(S, A1, 0), C1, eC1)),
      Equal.trans(FD.array__Tree<U32>, SWo(S, List.append(&2, U32, A2, A3), dd, D1, 1n+i, C1), SWo(S, A3, dd, D2, Nat.add(List.length(&2, U32, A2), 1n+i), C2), D3, s2,
        Equal.cong(Nat, FD.array__Tree<U32>, z => SWo(S, A3, dd, D2, z, C2), Nat.add(List.length(&2, U32, A2), 1n+i), Nat.add(1n+M, i),
          Equal.trans(Nat, Nat.add(List.length(&2, U32, A2), 1n+i), Nat.add(M, 1n+i), Nat.add(1n+M, i),
            Equal.cong(Nat, Nat, z => Nat.add(z, 1n+i), List.length(&2, U32, A2), M, eA2), FD.nat__add_succ(M, i))))))
  +eC = Equal.trans(U32, CRY(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), 0), CRY(S, List.append(&2, U32, A2, A3), CRY(S, A1, 0)), C3,
    cry_app(S, A1, List.append(&2, U32, A2, A3), 0),
    Equal.trans(U32, CRY(S, List.append(&2, U32, A2, A3), CRY(S, A1, 0)), CRY(S, List.append(&2, U32, A2, A3), C1), C3,
      Equal.cong(U32, U32, z => CRY(S, List.append(&2, U32, A2, A3), z), CRY(S, A1, 0), C1, eC1),
      cry_app(S, A2, A3, C1)))
  Equal.sym(U32, CRY(S, W, 0), C3,
    Equal.trans(U32, CRY(S, W, 0), CRY(S, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), 0), C3,
      Equal.cong(List<&2, U32>, U32, z => CRY(S, z, 0), W, List.append(&2, U32, A1, List.append(&2, U32, A2, A3)), eL), eC))

# The middle-word count the runtime picks is at most a = nw - 1.
def mid_le_g(+b1: Bool, +b2: Bool, +a: U32, +t: U32, +eb2: {U32.is_lt(a, t) == b2 : Bool})
    -> {Nat.is_le(U32.to_nat(O.pick(b1, 0, O.pick(b2, a, t))), U32.to_nat(a)) == True{} : Bool}:
  match b1 b2:
    case True{} _: FD.nat__zero_le(U32.to_nat(a))
    case False{} True{}: FD.nat__le_refl(U32.to_nat(a))
    case False{} False{}:
      FD.nat__not_lt_le(U32.to_nat(a), U32.to_nat(t), Equal.trans(Bool, Nat.is_lt(U32.to_nat(a), U32.to_nat(t)), U32.is_lt(a, t), False{}, Equal.sym(Bool, U32.is_lt(a, t), Nat.is_lt(U32.to_nat(a), U32.to_nat(t)), FD.u32__is_lt_nat(a, t)), eb2))

law swo_perfect:
  for +S: U32
  for +ws: +List<U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +i: Nat
  for +c: U32
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  {FD.array__perfect(U32, dd, SWo(S, ws, dd, D, i, c)) == True{} : Bool}
def swo_perfect(S, ws, dd, D, i, c, pf):
  match ws:
    case Nil{}: pf
    case Con{+w, +t}:
      swo_perfect(S, t, dd, ORW(dd, D, i, U32.or(O.shl_bytes(w, S), c)), 1n+i, O.shr_over(w, S), orw_perfect(dd, D, i, U32.or(O.shl_bytes(w, S), c), pf))

# The runtime's eight-byte write at an unaligned byte position p = 4 i + s: two
# four-byte writes.
def w64u_rtW(+S: U32, +s: Nat, +eS: {U32.to_nat(S) == s : Nat}, +hs: {Nat.is_lt(s, 4n) == True{} : Bool}, +hS: {U32.is_eq(S, 0) == False{} : Bool},
    +dd: Nat, +D: FD.array__Tree<U32>, +p: U32, +i: Nat, +lo: U32, +hi: U32, +e: {U32.to_nat(p) == Nat.add(A.quad(i), s) : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hl: {Nat.is_lt(2n+i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w64(FD.array__thaw(U32, D), p, O.U64{lo, hi}) == FD.array__thaw(U32, W32M(S, dd, W32M(S, dd, D, i, lo), 1n+i, hi)) : Array<U32>}:
  +e3 = ua_3(p, i, s, S, eS, e, hs)
  +hd31 = hd
  +hl1 = FD.nat__lt_trans(1n+i, 2n+i, VB.pw(dd), FD.nat__lt_succ(1n+i), hl)
  +h8 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(4n, z), A.quad(VB.pw(dd))) == True{} : Bool}, 4n+A.quad(i), Nat.add(A.quad(i), 4n), FD.nat__add_comm(4n, A.quad(i)),
    quad_le(2n+i, VB.pw(dd), FD.nat__lt_le(2n+i, VB.pw(dd), hl)))
  +hb = FD.nat__le_trans(Nat.add(4n, Nat.add(A.quad(i), s)), Nat.add(4n, Nat.add(A.quad(i), 4n)), A.quad(VB.pw(dd)),
    Order.add_left(4n, Nat.add(A.quad(i), s), Nat.add(A.quad(i), 4n), Order.add_left(A.quad(i), s, 4n, FD.nat__lt_le(s, 4n, hs))), h8)
  +hbS = FD.nat__lt_le_trans(Nat.add(4n, Nat.add(A.quad(i), s)), Nat.add(4n, Nat.add(A.quad(i), 4n)), FD.spec_common__pow2(32n),
    FD.nat__lt_add_left(Nat.add(A.quad(i), s), Nat.add(A.quad(i), 4n), 4n, FD.nat__lt_add_left(s, 4n, A.quad(i), hs)),
    FD.nat__le_trans(Nat.add(4n, Nat.add(A.quad(i), 4n)), A.quad(VB.pw(dd)), FD.spec_common__pow2(32n), h8, q32(dd, hd)))
  +e4 = ua_addS(p, 4, i, 1n, s, e, {==}, hbS)
  %Equal.sym(U32, U32.and(p, 3), S, e3) : {O.w64_at(U32.is_eq(_, 0), FD.array__thaw(U32, D), p, lo, hi) == FD.array__thaw(U32, W32M(S, dd, W32M(S, dd, D, i, lo), 1n+i, hi)) : Array<U32>}
  %Equal.sym(Bool, U32.is_eq(S, 0), False{}, hS) : {O.w64_at(_, FD.array__thaw(U32, D), p, lo, hi) == FD.array__thaw(U32, W32M(S, dd, W32M(S, dd, D, i, lo), 1n+i, hi)) : Array<U32>}
  %Equal.sym(Array<U32>, O.w32(FD.array__thaw(U32, D), p, lo), FD.array__thaw(U32, W32M(S, dd, D, i, lo)), w32u_rt(S, s, eS, hs, hS, dd, D, p, i, lo, e, hd31, hl1, pf)) :
    {O.w32(_, U32.add(p, 4), hi) == FD.array__thaw(U32, W32M(S, dd, W32M(S, dd, D, i, lo), 1n+i, hi)) : Array<U32>}
  w32u_rt(S, s, eS, hs, hS, dd, W32M(S, dd, D, i, lo), U32.add(p, 4), 1n+i, hi, e4, hd31, hl, w32m_perfect(S, dd, D, i, lo, pf))

def w64u_rt(+S: U32, +s: Nat, +eS: {U32.to_nat(S) == s : Nat}, +hs: {Nat.is_lt(s, 4n) == True{} : Bool}, +hS: {U32.is_eq(S, 0) == False{} : Bool},
    +dd: Nat, +D: FD.array__Tree<U32>, +p: U32, +i: Nat, +lo: U32, +hi: U32, +e: {U32.to_nat(p) == Nat.add(A.quad(i), s) : Nat},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_lt(2n+i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w64(FD.array__thaw(U32, D), p, O.U64{lo, hi}) == FD.array__thaw(U32, W32M(S, dd, W32M(S, dd, D, i, lo), 1n+i, hi)) : Array<U32>}:
  w64u_rtW(S, s, eS, hs, hS, dd, D, p, i, lo, hi, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf)

# ---- splices within splices ------------------------------------------------------------------

law bt_app_le:
  for +k: Nat
  for +Z: +List<U32>
  for +R: +List<U32>
  for +h: {Nat.is_le(k, List.length(&2, U32, Z)) == True{} : Bool}
  {VS.bt(k, List.append(&2, U32, Z, R)) == VS.bt(k, Z) : +List<U32>}
def bt_app_le(k, Z, R, h):
  match k Z:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({VS.bt(1n+p, List.append(&2, U32, Nil{}, R)) == VS.bt(1n+p, Nil{}) : +List<U32>}, FD.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, VS.bt(p, List.append(&2, U32, t, R)), VS.bt(p, t), bt_app_le(p, t, R, h))

law bt_app_len:
  for +X: +List<U32>
  for +k: Nat
  for +R: +List<U32>
  {VS.bt(Nat.add(List.length(&2, U32, X), k), List.append(&2, U32, X, R)) == List.append(&2, U32, X, VS.bt(k, R)) : +List<U32>}
def bt_app_len(X, k, R):
  match X:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, VS.bt(Nat.add(List.length(&2, U32, t), k), List.append(&2, U32, t, R)), List.append(&2, U32, t, VS.bt(k, R)), bt_app_len(t, k, R))

law bdr_app_len:
  for +X: +List<U32>
  for +k: Nat
  for +R: +List<U32>
  {VS.bdr(Nat.add(List.length(&2, U32, X), k), List.append(&2, U32, X, R)) == VS.bdr(k, R) : +List<U32>}
def bdr_app_len(X, k, R):
  match X:
    case Nil{}: {==}
    case Con{+x, +t}: bdr_app_len(t, k, R)

law len_bdr:
  for +k: Nat
  for +Z: +List<U32>
  {List.length(&2, U32, VS.bdr(k, Z)) == Nat.sub(List.length(&2, U32, Z), k) : Nat}
def len_bdr(k, Z):
  match k Z:
    case 0n _: Equal.sym(Nat, Nat.sub(List.length(&2, U32, Z), 0n), List.length(&2, U32, Z), FD.nat__sub_zero(List.length(&2, U32, Z)))
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}: len_bdr(p, t)

# The splice keeps the length when Y fits.
def len_spl(+Z: +List<U32>, +a: Nat, +Y: +List<U32>, +h: {Nat.is_le(Nat.add(a, List.length(&2, U32, Y)), List.length(&2, U32, Z)) == True{} : Bool})
    -> {List.length(&2, U32, SPL(Z, a, Y)) == List.length(&2, U32, Z) : Nat}:
  +m = List.length(&2, U32, Y)
  +ha = FD.nat__le_trans(a, Nat.add(a, m), List.length(&2, U32, Z), Order.below_sum(a, m), h)
  +e1 = VS.len_app(VS.bt(a, Z), List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), Z)))
  +e2 = VS.len_app(Y, VS.bdr(Nat.add(a, m), Z))
  +e3 = VS.bt_len(a, Z, ha)
  +e4 = len_bdr(Nat.add(a, m), Z)
  Equal.trans(Nat, List.length(&2, U32, SPL(Z, a, Y)), Nat.add(a, Nat.add(m, Nat.sub(List.length(&2, U32, Z), Nat.add(a, m)))), List.length(&2, U32, Z),
    Equal.trans(Nat, List.length(&2, U32, SPL(Z, a, Y)), Nat.add(List.length(&2, U32, VS.bt(a, Z)), List.length(&2, U32, List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), Z)))), Nat.add(a, Nat.add(m, Nat.sub(List.length(&2, U32, Z), Nat.add(a, m)))), e1,
      Equal.trans(Nat, Nat.add(List.length(&2, U32, VS.bt(a, Z)), List.length(&2, U32, List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), Z)))), Nat.add(a, List.length(&2, U32, List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), Z)))), Nat.add(a, Nat.add(m, Nat.sub(List.length(&2, U32, Z), Nat.add(a, m)))),
        Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), Z)))), List.length(&2, U32, VS.bt(a, Z)), a, e3),
        Equal.cong(Nat, Nat, z => Nat.add(a, z), List.length(&2, U32, List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), Z))), Nat.add(m, Nat.sub(List.length(&2, U32, Z), Nat.add(a, m))),
          Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), Z))), Nat.add(m, List.length(&2, U32, VS.bdr(Nat.add(a, m), Z))), Nat.add(m, Nat.sub(List.length(&2, U32, Z), Nat.add(a, m))), e2,
            Equal.cong(Nat, Nat, z => Nat.add(m, z), List.length(&2, U32, VS.bdr(Nat.add(a, m), Z)), Nat.sub(List.length(&2, U32, Z), Nat.add(a, m)), e4))))),
    Equal.trans(Nat, Nat.add(a, Nat.add(m, Nat.sub(List.length(&2, U32, Z), Nat.add(a, m)))), Nat.add(Nat.add(a, m), Nat.sub(List.length(&2, U32, Z), Nat.add(a, m))), List.length(&2, U32, Z),
      Equal.sym(Nat, Nat.add(Nat.add(a, m), Nat.sub(List.length(&2, U32, Z), Nat.add(a, m))), Nat.add(a, Nat.add(m, Nat.sub(List.length(&2, U32, Z), Nat.add(a, m)))), FD.nat__add_assoc(a, m, Nat.sub(List.length(&2, U32, Z), Nat.add(a, m)))),
      FD.nat__sub_add(List.length(&2, U32, Z), Nat.add(a, m), h)))

law le_bdr:
  for +a: Nat
  for +m: Nat
  for +Z: +List<U32>
  for +h: {Nat.is_le(Nat.add(a, m), List.length(&2, U32, Z)) == True{} : Bool}
  {Nat.is_le(m, List.length(&2, U32, VS.bdr(a, Z))) == True{} : Bool}
def le_bdr(a, m, Z, h):
  match a Z:
    case 0n _: h
    case 1n+ +p Nil{}: Empty.absurd({Nat.is_le(m, List.length(&2, U32, VS.bdr(1n+p, Nil{}))) == True{} : Bool}, FD.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: le_bdr(p, m, t, h)

# The bytes of a splice at X0 of Z, from X0 + a: those of Z from a.
def win_spl(+B0: +List<U32>, +X0: Nat, +Z: +List<U32>, +a: Nat, +m: Nat,
    +hX: {Nat.is_le(X0, List.length(&2, U32, B0)) == True{} : Bool}, +h: {Nat.is_le(Nat.add(a, m), List.length(&2, U32, Z)) == True{} : Bool})
    -> {VS.bt(m, VS.bdr(Nat.add(X0, a), SPL(B0, X0, Z))) == VS.bt(m, VS.bdr(a, Z)) : +List<U32>}:
  +P = VS.bt(X0, B0)
  +R0 = VS.bdr(Nat.add(X0, List.length(&2, U32, Z)), B0)
  +eP = VS.bt_len(X0, B0, hX)
  +ha = FD.nat__le_trans(a, Nat.add(a, m), List.length(&2, U32, Z), Order.below_sum(a, m), h)
  +e1 = FD.logic__subst(Nat, z => {VS.bdr(Nat.add(z, a), List.append(&2, U32, P, List.append(&2, U32, Z, R0))) == VS.bdr(a, List.append(&2, U32, Z, R0)) : +List<U32>},
    List.length(&2, U32, P), X0, eP, bdr_app_len(P, a, List.append(&2, U32, Z, R0)))
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(X0, a), List.append(&2, U32, P, List.append(&2, U32, Z, R0))), VS.bdr(a, List.append(&2, U32, Z, R0)), e1) : {VS.bt(m, _) == VS.bt(m, VS.bdr(a, Z)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(a, List.append(&2, U32, Z, R0)), List.append(&2, U32, VS.bdr(a, Z), R0), UC.bdr_app_le(a, Z, R0, ha)) : {VS.bt(m, _) == VS.bt(m, VS.bdr(a, Z)) : +List<U32>}
  bt_app_le(m, VS.bdr(a, Z), R0, le_bdr(a, m, Z, h))

# A splice into a splice: writing Y at X0 + a of the bytes spliced with Z at X0
# splices Y into Z.
def spl_spl(+B0: +List<U32>, +X0: Nat, +Z: +List<U32>, +a: Nat, +Y: +List<U32>,
    +hX: {Nat.is_le(X0, List.length(&2, U32, B0)) == True{} : Bool}, +h: {Nat.is_le(Nat.add(a, List.length(&2, U32, Y)), List.length(&2, U32, Z)) == True{} : Bool})
    -> {SPL(SPL(B0, X0, Z), Nat.add(X0, a), Y) == SPL(B0, X0, SPL(Z, a, Y)) : +List<U32>}:
  +m = List.length(&2, U32, Y)
  +P = VS.bt(X0, B0)
  +R0 = VS.bdr(Nat.add(X0, List.length(&2, U32, Z)), B0)
  +W = List.append(&2, U32, Z, R0)
  +Q = VS.bt(a, Z)
  +Dz = VS.bdr(Nat.add(a, m), Z)
  +eP = VS.bt_len(X0, B0, hX)
  +ha = FD.nat__le_trans(a, Nat.add(a, m), List.length(&2, U32, Z), Order.below_sum(a, m), h)
  +eA = FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, a), List.append(&2, U32, P, W)) == List.append(&2, U32, P, VS.bt(a, W)) : +List<U32>}, List.length(&2, U32, P), X0, eP, bt_app_len(P, a, W))
  +eB0 = FD.logic__subst(Nat, z => {VS.bdr(Nat.add(z, Nat.add(a, m)), List.append(&2, U32, P, W)) == VS.bdr(Nat.add(a, m), W) : +List<U32>}, List.length(&2, U32, P), X0, eP, bdr_app_len(P, Nat.add(a, m), W))
  +eB = Equal.trans(+List<U32>, VS.bdr(Nat.add(Nat.add(X0, a), m), List.append(&2, U32, P, W)), VS.bdr(Nat.add(X0, Nat.add(a, m)), List.append(&2, U32, P, W)), VS.bdr(Nat.add(a, m), W),
    Equal.cong(Nat, +List<U32>, z => VS.bdr(z, List.append(&2, U32, P, W)), Nat.add(Nat.add(X0, a), m), Nat.add(X0, Nat.add(a, m)), FD.nat__add_assoc(X0, a, m)), eB0)
  +eL = len_spl(Z, a, Y, h)
  %Equal.sym(+List<U32>, VS.bt(Nat.add(X0, a), List.append(&2, U32, P, W)), List.append(&2, U32, P, VS.bt(a, W)), eA) : {List.append(&2, U32, _, List.append(&2, U32, Y, VS.bdr(Nat.add(Nat.add(X0, a), m), List.append(&2, U32, P, W)))) == SPL(B0, X0, SPL(Z, a, Y)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(Nat.add(X0, a), m), List.append(&2, U32, P, W)), VS.bdr(Nat.add(a, m), W), eB) : {List.append(&2, U32, List.append(&2, U32, P, VS.bt(a, W)), List.append(&2, U32, Y, _)) == SPL(B0, X0, SPL(Z, a, Y)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(a, W), Q, bt_app_le(a, Z, R0, ha)) : {List.append(&2, U32, List.append(&2, U32, P, _), List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), W))) == SPL(B0, X0, SPL(Z, a, Y)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(a, m), W), List.append(&2, U32, Dz, R0), UC.bdr_app_le(Nat.add(a, m), Z, R0, h)) : {List.append(&2, U32, List.append(&2, U32, P, Q), List.append(&2, U32, Y, _)) == SPL(B0, X0, SPL(Z, a, Y)) : +List<U32>}
  %Equal.sym(Nat, List.length(&2, U32, SPL(Z, a, Y)), List.length(&2, U32, Z), eL) : {List.append(&2, U32, List.append(&2, U32, P, Q), List.append(&2, U32, Y, List.append(&2, U32, Dz, R0))) == List.append(&2, U32, P, List.append(&2, U32, SPL(Z, a, Y), VS.bdr(Nat.add(X0, _), B0))) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, P, Q), List.append(&2, U32, Y, List.append(&2, U32, Dz, R0))), List.append(&2, U32, P, List.append(&2, U32, Q, List.append(&2, U32, Y, List.append(&2, U32, Dz, R0)))),
      VS.app_assoc(P, Q, List.append(&2, U32, Y, List.append(&2, U32, Dz, R0)))) :
    {_ == List.append(&2, U32, P, List.append(&2, U32, SPL(Z, a, Y), R0)) : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, P, z), List.append(&2, U32, Q, List.append(&2, U32, Y, List.append(&2, U32, Dz, R0))), List.append(&2, U32, SPL(Z, a, Y), R0),
    Equal.sym(+List<U32>, List.append(&2, U32, SPL(Z, a, Y), R0), List.append(&2, U32, Q, List.append(&2, U32, Y, List.append(&2, U32, Dz, R0))),
      Equal.trans(+List<U32>, List.append(&2, U32, SPL(Z, a, Y), R0), List.append(&2, U32, Q, List.append(&2, U32, List.append(&2, U32, Y, Dz), R0)), List.append(&2, U32, Q, List.append(&2, U32, Y, List.append(&2, U32, Dz, R0))),
        VS.app_assoc(Q, List.append(&2, U32, Y, Dz), R0),
        Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, Q, z), List.append(&2, U32, List.append(&2, U32, Y, Dz), R0), List.append(&2, U32, Y, List.append(&2, U32, Dz, R0)), VS.app_assoc(Y, Dz, R0)))))

# ---- the aligned copy's bytes ----------------------------------------------------------------

law lm_lmv:
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +L: List<&2, U32>
  for +SL: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(i, n), VB.len(SL)) == True{} : Bool}
  {VB.lm(n, i, j, L, SL) == VF.lmv(VS.wtake(n, VB.wdr(i, SL)), j, L) : List<&2, U32>}
def lm_lmv(n, i, j, L, SL, h):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +hi = FD.nat__lt_le_trans(i, Nat.add(i, 1n+p), VB.len(SL), FD.logic__subst(Nat, z => {Nat.is_lt(i, z) == True{} : Bool}, 1n+Nat.add(i, p), Nat.add(i, 1n+p), Equal.sym(Nat, Nat.add(i, 1n+p), 1n+Nat.add(i, p), FD.nat__add_succ(i, p)), FD.nat__le_lt_succ(i, Nat.add(i, p), Order.below_sum(i, p))), h)
      +h1 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(SL)) == True{} : Bool}, Nat.add(i, 1n+p), 1n+Nat.add(i, p), FD.nat__add_succ(i, p), h)
      %Equal.sym(List<&2, U32>, VB.wdr(i, SL), Con{FD.flat__nthc(SL, i), VB.wdr(1n+i, SL)}, wdr_con(SL, i, hi)) :
        {VB.lm(1n+p, i, j, L, SL) == VF.lmv(VS.wtake(1n+p, _), j, L) : List<&2, U32>}
      lm_lmv(p, 1n+i, 1n+j, FD.spec_common__update(U32, L, j, FD.flat__nthc(SL, i)), SL, h1)

# The aligned copy of n source words from word i to word j splices their bytes in.
def mone_bytes(+n: Nat, +i: Nat, +j: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +ds: Nat, +S: FD.array__Tree<U32>,
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {FD.array__perfect(U32, ds, S) == True{} : Bool},
    +hj: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool}, +hi: {Nat.is_le(Nat.add(i, n), VB.pw(ds)) == True{} : Bool})
    -> {UA.BYT(VB.mone(n, i, j, dd, D, S)) == SPL(UA.BYT(D), A.quad(j), FX.limbs(VS.wtake(n, VB.wdr(i, SLW(S))))) : +List<U32>}:
  +V = VS.wtake(n, VB.wdr(i, SLW(S)))
  +eS = Equal.sym(Nat, VB.len(SLW(S)), VB.pw(ds), FD.array__slots_length(U32, ds, S, pfS))
  +eD = Equal.sym(Nat, VB.len(SLW(D)), VB.pw(dd), FD.array__slots_length(U32, dd, D, pf))
  +hi2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(i, n), z) == True{} : Bool}, VB.pw(ds), VB.len(SLW(S)), eS, hi)
  +hn = le_wdr(i, n, SLW(S), hi2)
  +eV = len_take(n, VB.wdr(i, SLW(S)), hn)
  +hjn = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(n, j), Nat.add(j, n), FD.nat__add_comm(n, j), hj)
  +hjv = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(j, z), VB.len(SLW(D))) == True{} : Bool}, n, VB.len(V), Equal.sym(Nat, VB.len(V), n, Equal.trans(Nat, VB.len(V), List.length(&2, U32, V), n, Equal.sym(Nat, List.length(&2, U32, V), VB.len(V), VR.len_eq(V)), eV)),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(j, n), z) == True{} : Bool}, VB.pw(dd), VB.len(SLW(D)), eD, hjn))
  %Equal.sym(List<&2, U32>, SLW(VB.mone(n, i, j, dd, D, S)), VB.lm(n, i, j, SLW(D), SLW(S)), VB.slots_mone(n, i, j, dd, D, S, pf, hj)) : {FX.limbs(_) == SPL(UA.BYT(D), A.quad(j), FX.limbs(V)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.lm(n, i, j, SLW(D), SLW(S)), VF.lmv(V, j, SLW(D)), lm_lmv(n, i, j, SLW(D), SLW(S), hi2)) : {FX.limbs(_) == SPL(UA.BYT(D), A.quad(j), FX.limbs(V)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.lmv(V, j, SLW(D)), VF.app(VS.wtake(j, SLW(D)), VF.app(V, VB.wdr(Nat.add(j, VB.len(V)), SLW(D)))), lmv_split(V, j, SLW(D), hjv)) : {FX.limbs(_) == SPL(UA.BYT(D), A.quad(j), FX.limbs(V)) : +List<U32>}
  limbs_tvd(j, V, SLW(D))

# ---- the byte invariant of an unaligned write ------------------------------------------------

# Writing Y at a inside the first L bytes (a + |Y| + r = L).
def bt_spl(+L: Nat, +E: +List<U32>, +a: Nat, +Y: +List<U32>, +r: Nat,
    +hL: {Nat.add(Nat.add(a, List.length(&2, U32, Y)), r) == L : Nat}, +ha: {Nat.is_le(a, List.length(&2, U32, E)) == True{} : Bool})
    -> {SPL(VS.bt(L, E), a, Y) == VS.bt(L, SPL(E, a, Y)) : +List<U32>}:
  +m = List.length(&2, U32, Y)
  +P = VS.bt(a, E)
  +R = VS.bdr(Nat.add(a, m), E)
  +eP = VS.bt_len(a, E, ha)
  +haL = FD.logic__subst(Nat, z => {Nat.is_le(a, z) == True{} : Bool}, Nat.add(Nat.add(a, m), r), L, hL,
    FD.nat__le_trans(a, Nat.add(a, m), Nat.add(Nat.add(a, m), r), Order.below_sum(a, m), Order.below_sum(Nat.add(a, m), r)))
  +e1 = UC.bt_le(a, L, E, haL)
  +e2 = FD.logic__subst(Nat, z => {VS.bdr(Nat.add(a, m), VS.bt(z, E)) == VS.bt(r, R) : +List<U32>}, Nat.add(Nat.add(a, m), r), L, hL, VS.bdr_bt(Nat.add(a, m), r, E))
  +eLr = Equal.trans(Nat, L, Nat.add(Nat.add(a, m), r), Nat.add(List.length(&2, U32, P), Nat.add(m, r)), Equal.sym(Nat, Nat.add(Nat.add(a, m), r), L, hL),
    Equal.trans(Nat, Nat.add(Nat.add(a, m), r), Nat.add(a, Nat.add(m, r)), Nat.add(List.length(&2, U32, P), Nat.add(m, r)), FD.nat__add_assoc(a, m, r),
      Equal.cong(Nat, Nat, z => Nat.add(z, Nat.add(m, r)), a, List.length(&2, U32, P), Equal.sym(Nat, List.length(&2, U32, P), a, eP))))
  +eR = Equal.trans(+List<U32>, VS.bt(L, List.append(&2, U32, P, List.append(&2, U32, Y, R))), VS.bt(Nat.add(List.length(&2, U32, P), Nat.add(m, r)), List.append(&2, U32, P, List.append(&2, U32, Y, R))), List.append(&2, U32, P, List.append(&2, U32, Y, VS.bt(r, R))),
    Equal.cong(Nat, +List<U32>, z => VS.bt(z, List.append(&2, U32, P, List.append(&2, U32, Y, R))), L, Nat.add(List.length(&2, U32, P), Nat.add(m, r)), eLr),
    Equal.trans(+List<U32>, VS.bt(Nat.add(List.length(&2, U32, P), Nat.add(m, r)), List.append(&2, U32, P, List.append(&2, U32, Y, R))), List.append(&2, U32, P, VS.bt(Nat.add(m, r), List.append(&2, U32, Y, R))), List.append(&2, U32, P, List.append(&2, U32, Y, VS.bt(r, R))),
      bt_app_len(P, Nat.add(m, r), List.append(&2, U32, Y, R)),
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, P, z), VS.bt(Nat.add(m, r), List.append(&2, U32, Y, R)), List.append(&2, U32, Y, VS.bt(r, R)), bt_app_len(Y, r, R))))
  %Equal.sym(+List<U32>, VS.bt(a, VS.bt(L, E)), VS.bt(a, E), e1) : {List.append(&2, U32, _, List.append(&2, U32, Y, VS.bdr(Nat.add(a, m), VS.bt(L, E)))) == VS.bt(L, SPL(E, a, Y)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(a, m), VS.bt(L, E)), VS.bt(r, R), e2) : {List.append(&2, U32, P, List.append(&2, U32, Y, _)) == VS.bt(L, SPL(E, a, Y)) : +List<U32>}
  Equal.sym(+List<U32>, VS.bt(L, SPL(E, a, Y)), List.append(&2, U32, P, List.append(&2, U32, Y, VS.bt(r, R))), eR)

# The invariant of an unaligned writer at X0: its bytes are B0 spliced with the first L
# bytes of E. A write of Y at X0 + a (inside, and the bytes under it zero in E)
# keeps it, with Y spliced into E.
def inv_step(+B0: +List<U32>, +X0: Nat, +L: Nat, +E: +List<U32>, +a: Nat, +Y: +List<U32>, +r: Nat, +UB: +List<U32>, +UB2: +List<U32>,
    +hX: {Nat.is_le(X0, List.length(&2, U32, B0)) == True{} : Bool}, +hI: {UB == SPL(B0, X0, VS.bt(L, E)) : +List<U32>},
    +hop: {UB2 == SPL(UB, Nat.add(X0, a), Y) : +List<U32>},
    +hL: {Nat.add(Nat.add(a, List.length(&2, U32, Y)), r) == L : Nat}, +hE: {Nat.is_le(L, List.length(&2, U32, E)) == True{} : Bool})
    -> {UB2 == SPL(B0, X0, VS.bt(L, SPL(E, a, Y))) : +List<U32>}:
  +m = List.length(&2, U32, Y)
  +hLl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(a, m), z) == True{} : Bool}, Nat.add(Nat.add(a, m), r), L, hL, Order.below_sum(Nat.add(a, m), r))
  +eBL = VS.bt_len(L, E, hE)
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(a, m), z) == True{} : Bool}, L, List.length(&2, U32, VS.bt(L, E)), Equal.sym(Nat, List.length(&2, U32, VS.bt(L, E)), L, eBL), hLl)
  +ha = FD.nat__le_trans(a, L, List.length(&2, U32, E), FD.nat__le_trans(a, Nat.add(a, m), L, Order.below_sum(a, m), hLl), hE)
  %Equal.sym(+List<U32>, UB2, SPL(UB, Nat.add(X0, a), Y), hop) : {_ == SPL(B0, X0, VS.bt(L, SPL(E, a, Y))) : +List<U32>}
  %Equal.sym(+List<U32>, UB, SPL(B0, X0, VS.bt(L, E)), hI) : {SPL(_, Nat.add(X0, a), Y) == SPL(B0, X0, VS.bt(L, SPL(E, a, Y))) : +List<U32>}
  %Equal.sym(+List<U32>, SPL(SPL(B0, X0, VS.bt(L, E)), Nat.add(X0, a), Y), SPL(B0, X0, SPL(VS.bt(L, E), a, Y)), spl_spl(B0, X0, VS.bt(L, E), a, Y, hX, h2)) :
    {_ == SPL(B0, X0, VS.bt(L, SPL(E, a, Y))) : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => SPL(B0, X0, z), SPL(VS.bt(L, E), a, Y), VS.bt(L, SPL(E, a, Y)), bt_spl(L, E, a, Y, r, hL, ha))

# The zero bytes an unaligned write needs, from the invariant.
def inv_zero(+B0: +List<U32>, +X0: Nat, +L: Nat, +E: +List<U32>, +a: Nat, +m: Nat, +UB: +List<U32>,
    +hX: {Nat.is_le(X0, List.length(&2, U32, B0)) == True{} : Bool}, +hI: {UB == SPL(B0, X0, VS.bt(L, E)) : +List<U32>},
    +hm: {Nat.is_le(Nat.add(a, m), L) == True{} : Bool}, +hE: {Nat.is_le(L, List.length(&2, U32, E)) == True{} : Bool},
    +hz: {VS.bt(m, VS.bdr(a, E)) == ZB(m) : +List<U32>})
    -> {VS.bt(m, VS.bdr(Nat.add(X0, a), UB)) == ZB(m) : +List<U32>}:
  +eBL = VS.bt_len(L, E, hE)
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(a, m), z) == True{} : Bool}, L, List.length(&2, U32, VS.bt(L, E)), Equal.sym(Nat, List.length(&2, U32, VS.bt(L, E)), L, eBL), hm)
  %Equal.sym(+List<U32>, UB, SPL(B0, X0, VS.bt(L, E)), hI) : {VS.bt(m, VS.bdr(Nat.add(X0, a), _)) == ZB(m) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(m, VS.bdr(Nat.add(X0, a), SPL(B0, X0, VS.bt(L, E)))), VS.bt(m, VS.bdr(a, VS.bt(L, E))), win_spl(B0, X0, VS.bt(L, E), a, m, hX, h2)) : {_ == ZB(m) : +List<U32>}
  %bt_bdr_bt(m, a, L, E, hm) : {_ == ZB(m) : +List<U32>}
  hz

# A non-empty byte count has a word.
def nw_pos_mU(+N: U32, +m: Nat, +em: {U32.to_nat(N) == m : Nat}, +hy: {Nat.is_le(VC.YL(N), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hn: {U32.is_eq(N, 0) == False{} : Bool}) -> {Nat.is_le(1n, VC.NW(N)) == True{} : Bool}:
  match m:
    case 0n: Empty.absurd({Nat.is_le(1n, VC.NW(N)) == True{} : Bool}, FD.logic__true_false(FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, N, 0, FD.u32__injective(N, 0, em), hn)))
    case 1n+ +p:
      +e = Equal.trans(Nat, VC.NW(N), VD.s_rng(2n, 3n+U32.to_nat(N)), VD.s_rng(2n, 4n+p), VC.eNWu(N, hy), Equal.cong(Nat, Nat, z => VD.s_rng(2n, 3n+z), U32.to_nat(N), 1n+p, em))
      FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, VD.s_rng(2n, 4n+p), VC.NW(N), Equal.sym(Nat, VC.NW(N), VD.s_rng(2n, 4n+p), e), FD.nat__zero_le(VD.s_h2(VD.s_h2(p))))

def nw_pos_m(+N: U32, +m: Nat, +em: {U32.to_nat(N) == m : Nat}, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(N), VB.pw(k)) == True{} : Bool},
    +hn: {U32.is_eq(N, 0) == False{} : Bool}) -> {Nat.is_le(1n, VC.NW(N)) == True{} : Bool}:
  nw_pos_mU(N, m, em, VC.hyU(N, k, hk, hy), hn)

def nw_posU(+N: U32, +hy: {Nat.is_le(VC.YL(N), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hn: {U32.is_eq(N, 0) == False{} : Bool}) -> {Nat.is_le(1n, VC.NW(N)) == True{} : Bool}:
  nw_pos_mU(N, U32.to_nat(N), {==}, hy, hn)

def nw_pos(+N: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(N), VB.pw(k)) == True{} : Bool},
    +hn: {U32.is_eq(N, 0) == False{} : Bool}) -> {Nat.is_le(1n, VC.NW(N)) == True{} : Bool}:
  nw_posU(N, VC.hyU(N, k, hk, hy), hn)

# ---- positions inside a value written at 4 i + s ------------------------------------------------

def pos_eq(+k: Nat, +i: Nat, +s: Nat) -> {Nat.add(A.quad(Nat.add(k, i)), s) == Nat.add(Nat.add(A.quad(i), s), A.quad(k)) : Nat}:
  Equal.trans(Nat, Nat.add(A.quad(Nat.add(k, i)), s), Nat.add(Nat.add(A.quad(k), A.quad(i)), s), Nat.add(Nat.add(A.quad(i), s), A.quad(k)),
    Equal.cong(Nat, Nat, z => Nat.add(z, s), A.quad(Nat.add(k, i)), Nat.add(A.quad(k), A.quad(i)), Equal.sym(Nat, Nat.add(A.quad(k), A.quad(i)), A.quad(Nat.add(k, i)), VF.quad_add(k, i))),
    Equal.trans(Nat, Nat.add(Nat.add(A.quad(k), A.quad(i)), s), Nat.add(A.quad(k), Nat.add(A.quad(i), s)), Nat.add(Nat.add(A.quad(i), s), A.quad(k)),
      FD.nat__add_assoc(A.quad(k), A.quad(i), s), FD.nat__add_comm(A.quad(k), Nat.add(A.quad(i), s))))

# W words from word k + i lie below word R + i < 2^dd (k + W <= R).
def lt_idx(+k: Nat, +W: Nat, +i: Nat, +R: Nat, +dd: Nat, +hR: {Nat.is_lt(Nat.add(R, i), VB.pw(dd)) == True{} : Bool}, +hk: {Nat.is_le(Nat.add(k, W), R) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(W, Nat.add(k, i)), VB.pw(dd)) == True{} : Bool}:
  FD.nat__le_lt_trans(Nat.add(W, Nat.add(k, i)), Nat.add(R, i), VB.pw(dd),
    FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(R, i)) == True{} : Bool}, Nat.add(Nat.add(k, W), i), Nat.add(W, Nat.add(k, i)),
      Equal.trans(Nat, Nat.add(Nat.add(k, W), i), Nat.add(Nat.add(W, k), i), Nat.add(W, Nat.add(k, i)), Equal.cong(Nat, Nat, z => Nat.add(z, i), Nat.add(k, W), Nat.add(W, k), FD.nat__add_comm(k, W)), FD.nat__add_assoc(W, k, i)),
      Order.add_right(Nat.add(k, W), R, i, hk)),
    hR)

# The byte position 4 (k + i) + s is below 4 2^dd (k < R, R + i < 2^dd, s < 4).
def room_q(+k: Nat, +i: Nat, +R: Nat, +s: Nat, +dd: Nat, +hR: {Nat.is_lt(Nat.add(R, i), VB.pw(dd)) == True{} : Bool}, +hk: {Nat.is_lt(k, R) == True{} : Bool},
    +hs: {Nat.is_lt(s, 4n) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A.quad(k), Nat.add(A.quad(i), s)), A.quad(VB.pw(dd))) == True{} : Bool}:
  +h1 = lt_idx(k, 1n, i, R, dd, hR, FD.logic__subst(Nat, z => {Nat.is_le(z, R) == True{} : Bool}, 1n+k, Nat.add(k, 1n), Equal.sym(Nat, Nat.add(k, 1n), 1n+k, Equal.trans(Nat, Nat.add(k, 1n), 1n+Nat.add(k, 0n), 1n+k, FD.nat__add_succ(k, 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(k, 0n), k, FD.nat__add_zero(k)))), FD.nat__lt_succ_le_succ(k, R, hk)))
  +h2 = quad_le(1n+Nat.add(k, i), VB.pw(dd), FD.nat__lt_le(1n+Nat.add(k, i), VB.pw(dd), h1))
  +e1 = Equal.trans(Nat, Nat.add(A.quad(k), Nat.add(A.quad(i), s)), Nat.add(Nat.add(A.quad(k), A.quad(i)), s), Nat.add(A.quad(Nat.add(k, i)), s),
    Equal.sym(Nat, Nat.add(Nat.add(A.quad(k), A.quad(i)), s), Nat.add(A.quad(k), Nat.add(A.quad(i), s)), FD.nat__add_assoc(A.quad(k), A.quad(i), s)),
    Equal.cong(Nat, Nat, z => Nat.add(z, s), Nat.add(A.quad(k), A.quad(i)), A.quad(Nat.add(k, i)), VF.quad_add(k, i)))
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dd))) == True{} : Bool}, Nat.add(A.quad(Nat.add(k, i)), s), Nat.add(A.quad(k), Nat.add(A.quad(i), s)), Equal.sym(Nat, Nat.add(A.quad(k), Nat.add(A.quad(i), s)), Nat.add(A.quad(Nat.add(k, i)), s), e1),
    FD.nat__le_trans(Nat.add(A.quad(Nat.add(k, i)), s), 4n+A.quad(Nat.add(k, i)), A.quad(VB.pw(dd)),
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(Nat.add(k, i)), s), z) == True{} : Bool}, Nat.add(A.quad(Nat.add(k, i)), 4n), 4n+A.quad(Nat.add(k, i)), FD.nat__add_comm(A.quad(Nat.add(k, i)), 4n),
        Order.add_left(A.quad(Nat.add(k, i)), s, 4n, FD.nat__lt_le(s, 4n, hs))),
      h2))

law bt_bdr_split:
  for +a: Nat
  for +xs: +List<U32>
  {List.append(&2, U32, VS.bt(a, xs), VS.bdr(a, xs)) == xs : +List<U32>}
def bt_bdr_split(a, xs):
  match a xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, List.append(&2, U32, VS.bt(p, t), VS.bdr(p, t)), t, bt_bdr_split(p, t))

law len_zb:
  for +n: Nat
  {List.length(&2, U32, ZB(n)) == n : Nat}
def len_zb(n):
  match n:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, List.length(&2, U32, ZB(p)), p, len_zb(p))

# The invariant holds before any write: the L bytes at X0 are zero, as are E's first L.
def inv_init(+B: +List<U32>, +X0: Nat, +L: Nat, +E0: +List<U32>,
    +hz: {VS.bt(L, VS.bdr(X0, B)) == ZB(L) : +List<U32>}, +hE: {VS.bt(L, E0) == ZB(L) : +List<U32>})
    -> {B == SPL(B, X0, VS.bt(L, E0)) : +List<U32>}:
  +Z = VS.bt(L, E0)
  +eZ = Equal.trans(+List<U32>, VS.bt(L, VS.bdr(X0, B)), ZB(L), Z, hz, Equal.sym(+List<U32>, Z, ZB(L), hE))
  +eL = Equal.trans(Nat, List.length(&2, U32, Z), List.length(&2, U32, ZB(L)), L, Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), Z, ZB(L), hE), len_zb(L))
  +e1 = bt_bdr_split(X0, B)
  +e2 = bt_bdr_split(L, VS.bdr(X0, B))
  +e3 = bdr_add(X0, L, B)
  %e1 : {_ == SPL(B, X0, Z) : +List<U32>}
  %e2 : {List.append(&2, U32, VS.bt(X0, B), _) == SPL(B, X0, Z) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(L, VS.bdr(X0, B)), Z, eZ) : {List.append(&2, U32, VS.bt(X0, B), List.append(&2, U32, _, VS.bdr(L, VS.bdr(X0, B)))) == SPL(B, X0, Z) : +List<U32>}
  %e3 : {List.append(&2, U32, VS.bt(X0, B), List.append(&2, U32, Z, _)) == SPL(B, X0, Z) : +List<U32>}
  %Equal.sym(Nat, List.length(&2, U32, Z), L, eL) : {List.append(&2, U32, VS.bt(X0, B), List.append(&2, U32, Z, VS.bdr(Nat.add(X0, L), B))) == List.append(&2, U32, VS.bt(X0, B), List.append(&2, U32, Z, VS.bdr(Nat.add(X0, _), B))) : +List<U32>}
  {==}

# ---- the open model's words ----------------------------------------------------------------------

# The list model of the open write SWo: the words ws at byte S of the first of the words W,
# nothing after the last (its carry out is dropped).
def SWLo(+S: U32, ws: +List<U32>, W: List<&2, U32>, +c: U32) -> List<&2, U32>:
  match ws W:
    case Nil{} _: W
    case Con{+w, r} Nil{}: []
    case Con{+w, r} Con{+h, t}: Con{U32.or(h, U32.or(O.shl_bytes(w, S), c)), SWLo(S, r, t, O.shr_over(w, S))}

law swo_slots:
  for +S: U32
  for +ws: +List<U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +i: Nat
  for +c: U32
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(i, List.length(&2, U32, ws)), VB.pw(dd)) == True{} : Bool}
  {SLW(SWo(S, ws, dd, D, i, c)) == VF.app(VS.wtake(i, SLW(D)), SWLo(S, ws, VB.wdr(i, SLW(D)), c)) : List<&2, U32>}
def swo_slots(S, ws, dd, D, i, c, pf, hr):
  match ws:
    case Nil{}: Equal.sym(List<&2, U32>, VF.app(VS.wtake(i, SLW(D)), VB.wdr(i, SLW(D))), SLW(D), take_drop(i, SLW(D)))
    case Con{+w, +r}:
      +v = U32.or(O.shl_bytes(w, S), c)
      +V1 = U32.or(VB.slot(D, i), v)
      +D1 = ORW(dd, D, i, v)
      +hr2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(i, 1n+List.length(&2, U32, r)), 1n+Nat.add(i, List.length(&2, U32, r)), FD.nat__add_succ(i, List.length(&2, U32, r)), hr)
      +hi = lt_add_l(i, List.length(&2, U32, r), VB.pw(dd), FD.nat__succ_le_lt(Nat.add(i, List.length(&2, U32, r)), VB.pw(dd), hr2))
      +hl = FD.array__len_lt(U32, dd, D, i, pf, hi)
      +ih = swo_slots(S, r, dd, D1, 1n+i, O.shr_over(w, S), orw_perfect(dd, D, i, v, pf), hr2)
      %Equal.sym(List<&2, U32>, VB.wdr(i, SLW(D)), Con{FD.flat__nthc(SLW(D), i), VB.wdr(1n+i, SLW(D))}, wdr_con(SLW(D), i, hl)) :
        {SLW(SWo(S, Con{w, r}, dd, D, i, c)) == VF.app(VS.wtake(i, SLW(D)), SWLo(S, Con{w, r}, _, c)) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, SLW(SWo(S, r, dd, D1, 1n+i, O.shr_over(w, S))), VF.app(VS.wtake(1n+i, SLW(D1)), SWLo(S, r, VB.wdr(1n+i, SLW(D1)), O.shr_over(w, S))), ih) :
        {_ == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWLo(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, SLW(D1), FD.spec_common__update(U32, SLW(D), i, V1), FD.array__upd_slots(U32, dd, D, i, V1, hi, pf)) :
        {VF.app(VS.wtake(1n+i, _), SWLo(S, r, VB.wdr(1n+i, SLW(D1)), O.shr_over(w, S))) == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWLo(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, SLW(D1), FD.spec_common__update(U32, SLW(D), i, V1), FD.array__upd_slots(U32, dd, D, i, V1, hi, pf)) :
        {VF.app(VS.wtake(1n+i, FD.spec_common__update(U32, SLW(D), i, V1)), SWLo(S, r, VB.wdr(1n+i, _), O.shr_over(w, S))) == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWLo(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, VS.wtake(1n+i, FD.spec_common__update(U32, SLW(D), i, V1)), VF.app(VS.wtake(i, SLW(D)), [V1]), take_upd(SLW(D), i, V1, hl)) :
        {VF.app(_, SWLo(S, r, VB.wdr(1n+i, FD.spec_common__update(U32, SLW(D), i, V1)), O.shr_over(w, S))) == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWLo(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, VB.wdr(1n+i, FD.spec_common__update(U32, SLW(D), i, V1)), VB.wdr(1n+i, SLW(D)), drop_upd(SLW(D), i, V1)) :
        {VF.app(VF.app(VS.wtake(i, SLW(D)), [V1]), SWLo(S, r, _, O.shr_over(w, S))) == VF.app(VS.wtake(i, SLW(D)), Con{V1, SWLo(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S))}) : List<&2, U32>}
      app_assoc_l(VS.wtake(i, SLW(D)), [V1], SWLo(S, r, VB.wdr(1n+i, SLW(D)), O.shr_over(w, S)))

# ---- the word-by-word writers' interior stores, generically ----------------------------------------

# The runtime's stores of the words ws at word positions q + j for the offsets j in js (each
# word the shifted word OR the carry of the one before), as a recursion over ws: for literal
# lists it unfolds to the writers' <p>_pw<s> chains of Array.set, offsets as they are.
def RS2(+S: U32, ws: +List<U32>, js: List<&2, U32>, out: Array<U32>, +q: U32, +prev: U32) -> Array<U32>:
  match ws js:
    case Nil{} _: out
    case Con{+w, t} Nil{}: out
    case Con{+w, t} Con{+j, jt}: RS2(S, t, jt, Array.set(U32, out, U32.add(q, j), U32.or(O.shl_bytes(w, S), O.shr_over(prev, S))), q, w)

# The offsets are J, J + 1, .. (n of them).
def CJ(+n: Nat, js: List<&2, U32>, +J: Nat) -> Bool:
  match n js:
    case 0n _: True{}
    case 1n+k Nil{}: False{}
    case 1n+k Con{+j, jt}: Bool.and(Nat.is_eq(U32.to_nat(j), J), CJ(k, jt, 1n+J))

# Stored into zero words, they are the open model SWo.
law rs2_swo:
  for +S: U32
  for +ws: +List<U32>
  for +js: List<&2, U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +q: U32
  for +i: Nat
  for +J: Nat
  for +prev: U32
  for +eq: {U32.to_nat(q) == i : Nat}
  for +hj: {CJ(List.length(&2, U32, ws), js, J) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(Nat.add(J, i), List.length(&2, U32, ws)), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(A.quad(List.length(&2, U32, ws)), VS.bdr(A.quad(Nat.add(J, i)), UA.BYT(D))) == ZB(A.quad(List.length(&2, U32, ws))) : +List<U32>}
  {RS2(S, ws, js, FD.array__thaw(U32, D), q, prev) == FD.array__thaw(U32, SWo(S, ws, dd, D, Nat.add(J, i), O.shr_over(prev, S))) : Array<U32>}
def rs2_swo(S, ws, js, dd, D, q, i, J, prev, eq, hj, hd, pf, hl, hz):
  match ws js:
    case Nil{} _: {==}
    case Con{+w, +t} Nil{}: Empty.absurd({RS2(S, Con{w, t}, Nil{}, FD.array__thaw(U32, D), q, prev) == FD.array__thaw(U32, SWo(S, Con{w, t}, dd, D, Nat.add(J, i), O.shr_over(prev, S))) : Array<U32>}, FD.logic__false_true(hj))
    case Con{+w, +t} Con{+j, +jt}:
      +ej = FD.nat__eq_from_is_eq(U32.to_nat(j), J, FD.logic__and_left(Nat.is_eq(U32.to_nat(j), J), CJ(List.length(&2, U32, t), jt, 1n+J), hj))
      +hjt = FD.logic__and_right(Nat.is_eq(U32.to_nat(j), J), CJ(List.length(&2, U32, t), jt, 1n+J), hj)
      +K = Nat.add(J, i)
      +p = List.length(&2, U32, t)
      +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
      +hl1 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(K, 1n+p), 1n+Nat.add(K, p), FD.nat__add_succ(K, p), hl)
      +hK = FD.nat__lt_le_trans(K, 1n+Nat.add(K, p), VB.pw(dd), FD.nat__le_lt_succ(K, Nat.add(K, p), Order.below_sum(K, p)), hl1)
      +eqK = FD.logic__subst(Nat, z => {U32.to_nat(U32.add(q, j)) == Nat.add(z, i) : Nat}, U32.to_nat(j), J, ej,
        VB.add_at(q, j, i, dd, eq, hd32, FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, J, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), J, ej), hK)))
      +hzj = FD.logic__subst(Nat, z => {VS.bt(4n+A.quad(p), VS.bdr(z, UA.BYT(D))) == ZB(4n+A.quad(p)) : +List<U32>}, A.quad(K), Nat.add(A.quad(K), 0n),
        Equal.sym(Nat, Nat.add(A.quad(K), 0n), A.quad(K), FD.nat__add_zero(A.quad(K))), hz)
      +ez = zslot_g(dd, D, K, 0n, 4n+A.quad(p), 0n, 0n, pf, hzj, {==}, FD.nat__zero_le(A.quad(p)), hK)
      +v = U32.or(O.shl_bytes(w, S), O.shr_over(prev, S))
      +D1 = ORW(dd, D, K, v)
      +es = set_orw(dd, D, U32.add(q, j), K, v, eqK, hd32, hK, pf, ez)
      +fr = upd_frame(dd, D, K, U32.or(VB.slot(D, K), v), pf, hK)
      +hzb = Equal.trans(+List<U32>, VS.bt(A.quad(p), VS.bdr(4n, VS.bdr(A.quad(K), UA.BYT(D)))), VS.bdr(4n, VS.bt(Nat.add(4n, A.quad(p)), VS.bdr(A.quad(K), UA.BYT(D)))), ZB(A.quad(p)),
        Equal.sym(+List<U32>, VS.bdr(4n, VS.bt(Nat.add(4n, A.quad(p)), VS.bdr(A.quad(K), UA.BYT(D)))), VS.bt(A.quad(p), VS.bdr(4n, VS.bdr(A.quad(K), UA.BYT(D)))), VS.bdr_bt(4n, A.quad(p), VS.bdr(A.quad(K), UA.BYT(D)))),
        Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(4n, z), VS.bt(4n+A.quad(p), VS.bdr(A.quad(K), UA.BYT(D))), ZB(4n+A.quad(p)), hz))
      +eb4 = Equal.trans(+List<U32>, VS.bdr(4n+A.quad(K), UA.BYT(D1)), VS.bdr(4n+A.quad(K), UA.BYT(D)), VS.bdr(4n, VS.bdr(A.quad(K), UA.BYT(D))), fr,
        Equal.trans(+List<U32>, VS.bdr(4n+A.quad(K), UA.BYT(D)), VS.bdr(Nat.add(A.quad(K), 4n), UA.BYT(D)), VS.bdr(4n, VS.bdr(A.quad(K), UA.BYT(D))),
          Equal.cong(Nat, +List<U32>, z => VS.bdr(z, UA.BYT(D)), 4n+A.quad(K), Nat.add(A.quad(K), 4n), FD.nat__add_comm(4n, A.quad(K))),
          bdr_add(A.quad(K), 4n, UA.BYT(D))))
      +hz1 = FD.logic__subst(+List<U32>, z => {VS.bt(A.quad(p), z) == ZB(A.quad(p)) : +List<U32>}, VS.bdr(4n, VS.bdr(A.quad(K), UA.BYT(D))), VS.bdr(4n+A.quad(K), UA.BYT(D1)),
        Equal.sym(+List<U32>, VS.bdr(4n+A.quad(K), UA.BYT(D1)), VS.bdr(4n, VS.bdr(A.quad(K), UA.BYT(D))), eb4), hzb)
      +ih = rs2_swo(S, t, jt, dd, D1, q, i, 1n+J, w, eq, hjt, hd, orw_perfect(dd, D, K, v, pf), hl1, hz1)
      %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, D), U32.add(q, j), v), FD.array__thaw(U32, D1), es) :
        {RS2(S, t, jt, _, q, w) == FD.array__thaw(U32, SWo(S, Con{w, t}, dd, D, K, O.shr_over(prev, S))) : Array<U32>}
      ih

# ---- the aligned runs, generically -------------------------------------------------------------

# The runtime's stores of the words ws at word positions q + j for the offsets j in js.
def AS2(ws: +List<U32>, js: List<&2, U32>, out: Array<U32>, +q: U32) -> Array<U32>:
  match ws js:
    case Nil{} _: out
    case Con{+w, t} Nil{}: out
    case Con{+w, t} Con{+j, jt}: AS2(t, jt, Array.set(U32, out, U32.add(q, j), w), q)

# They are the aligned run VF.updv.
law as2_updv:
  for +ws: +List<U32>
  for +js: List<&2, U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +q: U32
  for +i: Nat
  for +J: Nat
  for +eq: {U32.to_nat(q) == i : Nat}
  for +hj: {CJ(List.length(&2, U32, ws), js, J) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(Nat.add(J, i), List.length(&2, U32, ws)), VB.pw(dd)) == True{} : Bool}
  {AS2(ws, js, FD.array__thaw(U32, D), q) == FD.array__thaw(U32, VF.updv(ws, dd, D, Nat.add(J, i))) : Array<U32>}
def as2_updv(ws, js, dd, D, q, i, J, eq, hj, hd, pf, hl):
  match ws js:
    case Nil{} _: {==}
    case Con{+w, +t} Nil{}: Empty.absurd({AS2(Con{w, t}, Nil{}, FD.array__thaw(U32, D), q) == FD.array__thaw(U32, VF.updv(Con{w, t}, dd, D, Nat.add(J, i))) : Array<U32>}, FD.logic__false_true(hj))
    case Con{+w, +t} Con{+j, +jt}:
      +ej = FD.nat__eq_from_is_eq(U32.to_nat(j), J, FD.logic__and_left(Nat.is_eq(U32.to_nat(j), J), CJ(List.length(&2, U32, t), jt, 1n+J), hj))
      +hjt = FD.logic__and_right(Nat.is_eq(U32.to_nat(j), J), CJ(List.length(&2, U32, t), jt, 1n+J), hj)
      +K = Nat.add(J, i)
      +p = List.length(&2, U32, t)
      +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
      +hl1 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(K, 1n+p), 1n+Nat.add(K, p), FD.nat__add_succ(K, p), hl)
      +hK = FD.nat__lt_le_trans(K, 1n+Nat.add(K, p), VB.pw(dd), FD.nat__le_lt_succ(K, Nat.add(K, p), Order.below_sum(K, p)), hl1)
      +eqK = FD.logic__subst(Nat, z => {U32.to_nat(U32.add(q, j)) == Nat.add(z, i) : Nat}, U32.to_nat(j), J, ej,
        VB.add_at(q, j, i, dd, eq, hd32, FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, i), VB.pw(dd)) == True{} : Bool}, J, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), J, ej), hK)))
      +D1 = FD.array__upd(U32, dd, D, K, w)
      +es = VB.set_n(dd, D, U32.add(q, j), K, w, eqK, hd32, hK, pf)
      +ih = as2_updv(t, jt, dd, D1, q, i, 1n+J, eq, hjt, hd, FD.array__upd_perfect(U32, dd, D, K, w, pf), hl1)
      %Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, D), U32.add(q, j), w), FD.array__thaw(U32, D1), es) :
        {AS2(t, jt, _, q) == FD.array__thaw(U32, VF.updv(Con{w, t}, dd, D, K)) : Array<U32>}
      ih

# An OR that contributes nothing is skipped.
def orskip0(+dd: Nat, +D: FD.array__Tree<U32>, +i: U32, +x: U32, +h: {x == 0 : U32})
    -> {O.or_skip(FD.array__thaw(U32, D), i, x) == FD.array__thaw(U32, D) : Array<U32>}:
  %Equal.sym(U32, x, 0, h) : {O.or_skip(FD.array__thaw(U32, D), i, _) == FD.array__thaw(U32, D) : Array<U32>}
  {==}

# A word past an aligned run is the tree's.
law slot_updv_ge:
  for +V: List<&2, U32>
  for +dd: Nat
  for +D: FD.array__Tree<U32>
  for +j: Nat
  for +k: Nat
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hk: {Nat.is_lt(Nat.add(j, VB.len(V)), 1n+k) == True{} : Bool}
  for +hp: {Nat.is_lt(k, VB.pw(dd)) == True{} : Bool}
  {VB.slot(VF.updv(V, dd, D, j), k) == VB.slot(D, k) : U32}
def slot_updv_ge(V, dd, D, j, k, pf, hk, hp):
  match V:
    case Nil{}: {==}
    case Con{+v, +t}:
      +hk1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, 1n+k) == True{} : Bool}, Nat.add(j, 1n+VB.len(t)), Nat.add(1n+j, VB.len(t)), FD.nat__add_succ(j, VB.len(t)), hk)
      +hjk = FD.nat__le_lt_trans(1n+j, Nat.add(1n+j, VB.len(t)), 1n+k, Order.below_sum(1n+j, VB.len(t)), hk1)
      +hj = FD.nat__lt_trans(j, k, VB.pw(dd), hjk, hp)
      +ne = FD.nat__is_eq_lt(j, k, hjk)
      +ih = slot_updv_ge(t, dd, FD.array__upd(U32, dd, D, j, v), 1n+j, k, FD.array__upd_perfect(U32, dd, D, j, v, pf), hk1, hp)
      Equal.trans(U32, VB.slot(VF.updv(t, dd, FD.array__upd(U32, dd, D, j, v), 1n+j), k), VB.slot(FD.array__upd(U32, dd, D, j, v), k), VB.slot(D, k), ih,
        Equal.trans(U32, VB.slot(FD.array__upd(U32, dd, D, j, v), k), FD.flat__nthc(FD.spec_common__update(U32, SLW(D), j, v), k), VB.slot(D, k),
          Equal.cong(List<&2, U32>, U32, z => FD.flat__nthc(z, k), SLW(FD.array__upd(U32, dd, D, j, v)), FD.spec_common__update(U32, SLW(D), j, v), FD.array__upd_slots(U32, dd, D, j, v, hj, pf)),
          nthc_upd_other(SLW(D), j, k, v, ne)))

# An OR into a zero word is a store.
def orw_zero(+dd: Nat, +D: FD.array__Tree<U32>, +i: Nat, +x: U32, +hz: {VB.slot(D, i) == 0 : U32})
    -> {ORW(dd, D, i, x) == FD.array__upd(U32, dd, D, i, x) : FD.array__Tree<U32>}:
  %Equal.sym(U32, VB.slot(D, i), 0, hz) : {FD.array__upd(U32, dd, D, i, U32.or(_, x)) == FD.array__upd(U32, dd, D, i, x) : FD.array__Tree<U32>}
  Equal.cong(U32, FD.array__Tree<U32>, z => FD.array__upd(U32, dd, D, i, z), U32.or(0, x), x, or0l(x))
