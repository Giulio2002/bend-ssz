import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vfix.bend as VF
import ./vnest.bend as VN
import ./vbrt.bend as VR
import ./vbitc.bend as VBC
import ./vdepth.bend as VD
import ./vbytes.bend as VBY
import ./word_mul_generated.bend as WM
import ./vua_bits_generated.bend as UB
import ./vua.bend as UA

# The unaligned-offset layer, U2: the runtime's shifted word copies
# O.scopy1/2/3 (the input copy at a byte offset s = 1, 2, 3 into a word) on the
# array model. Word x of the copy is the join at byte s of source words i + x
# and i + x + 1. The last source read may be one past the array, where Base
# Array masks the index to 0 (rdw).

# ---- a read one past the array wraps to slot 0 -----------------------------------------

def and_f(+b: Bool) -> {Bool.and(b, False{}) == False{} : Bool}:
  match b:
    case True{}: {==}
    case False{}: {==}

law and_zero:
  for +n: Nat
  for +x: Word(n)
  {Word.and(n, x, Word.zero(n)) == Word.zero(n) : Word(n)}
def and_zero(n, x):
  match n:
    case 0n:
      match x:
        case WNil{}: {==}
    case 1n+ +m:
      match x:
        case WCon{+xb, +xt}:
          %Equal.sym(Bool, Bool.and(xb, False{}), False{}, and_f(xb)) : {WCon{_, Word.and(m, xt, Word.zero(m))} == Word.zero(1n+m) : Word(1n+m)}
          %Equal.sym(Word(m), Word.and(m, xt, Word.zero(m)), Word.zero(m), and_zero(m, xt)) : {WCon{False{}, _} == Word.zero(1n+m) : Word(1n+m)}
          {==}

law zero_val:
  for +n: Nat
  for +y: Word(n)
  for +h: {F.spec_numeric__unsigned(n, y) == 0n : Nat}
  {y == Word.zero(n) : Word(n)}
def zero_val(n, y, h):
  match n:
    case 0n:
      match y:
        case WNil{}: {==}
    case 1n+ +m:
      match y:
        case WCon{+yb, +yt}:
          %Equal.sym(Bool, yb, False{}, F.nat__bit_split_bit(yb, False{}, F.spec_numeric__unsigned(m, yt), 0n, h)) : {WCon{_, yt} == Word.zero(1n+m) : Word(1n+m)}
          %Equal.sym(Word(m), yt, Word.zero(m), zero_val(m, yt, F.nat__bit_split_val(yb, False{}, F.spec_numeric__unsigned(m, yt), 0n, h))) : {WCon{False{}, _} == Word.zero(1n+m) : Word(1n+m)}
          {==}

# A word of value 2^d and a word of value 2^d - 1 share no bit.
law and_top:
  for +n: Nat
  for +d: Nat
  for +x: Word(n)
  for +y: Word(n)
  for +hx: {F.spec_numeric__unsigned(n, x) == F.spec_common__pow2(d) : Nat}
  for +hy: {F.spec_numeric__unsigned(n, y) == Nat.sub(F.spec_common__pow2(d), 1n) : Nat}
  {Word.and(n, x, y) == Word.zero(n) : Word(n)}
def and_top(n, d, x, y, hx, hy):
  match n:
    case 0n:
      match x y:
        case WNil{} WNil{}: {==}
    case 1n+ +m:
      match d x y:
        case 0n WCon{+xb, +xt} WCon{+yb, +yt}:
          %Equal.sym(Bool, yb, False{}, F.nat__bit_split_bit(yb, False{}, F.spec_numeric__unsigned(m, yt), 0n, hy)) :
            {WCon{Bool.and(xb, _), Word.and(m, xt, yt)} == Word.zero(1n+m) : Word(1n+m)}
          %Equal.sym(Word(m), yt, Word.zero(m), zero_val(m, yt, F.nat__bit_split_val(yb, False{}, F.spec_numeric__unsigned(m, yt), 0n, hy))) :
            {WCon{Bool.and(xb, False{}), Word.and(m, xt, _)} == Word.zero(1n+m) : Word(1n+m)}
          %Equal.sym(Bool, Bool.and(xb, False{}), False{}, and_f(xb)) : {WCon{_, Word.and(m, xt, Word.zero(m))} == Word.zero(1n+m) : Word(1n+m)}
          %Equal.sym(Word(m), Word.and(m, xt, Word.zero(m)), Word.zero(m), and_zero(m, xt)) : {WCon{False{}, _} == Word.zero(1n+m) : Word(1n+m)}
          {==}
        case 1n+ +k WCon{+xb, +xt} WCon{+yb, +yt}:
          %Equal.sym(Bool, xb, False{}, F.nat__bit_split_bit(xb, False{}, F.spec_numeric__unsigned(m, xt), F.spec_common__pow2(k), hx)) :
            {WCon{Bool.and(_, yb), Word.and(m, xt, yt)} == Word.zero(1n+m) : Word(1n+m)}
          %Equal.sym(Word(m), Word.and(m, xt, yt), Word.zero(m),
              and_top(m, k, xt, yt, F.nat__bit_split_val(xb, False{}, F.spec_numeric__unsigned(m, xt), F.spec_common__pow2(k), hx),
                F.u32__and_low_hy(m, 1n+k, yb, yt, hy))) :
            {WCon{False{}, _} == Word.zero(1n+m) : Word(1n+m)}
          {==}

def mask_top(+x: U32, +y: U32, +d: Nat, +hx: {U32.to_nat(x) == F.spec_common__pow2(d) : Nat},
    +hy: {U32.to_nat(y) == Nat.sub(F.spec_common__pow2(d), 1n) : Nat}) -> {U32.and(x, y) == 0 : U32}:
  match x y:
    case U32{+wx} U32{+wy}:
      Equal.cong(Word(32n), U32, w => U32{w}, Word.and(32n, wx, wy), Word.zero(32n),
        and_top(32n, d, wx, wy,
          Equal.trans(Nat, F.spec_numeric__unsigned(32n, wx), U32.to_nat(U32{wx}), F.spec_common__pow2(d), Equal.sym(Nat, U32.to_nat(U32{wx}), F.spec_numeric__unsigned(32n, wx), F.u32__to_nat_word(wx)), hx),
          Equal.trans(Nat, F.spec_numeric__unsigned(32n, wy), U32.to_nat(U32{wy}), Nat.sub(F.spec_common__pow2(d), 1n), Equal.sym(Nat, U32.to_nat(U32{wy}), F.spec_numeric__unsigned(32n, wy), F.u32__to_nat_word(wy)), hy)))

def pmask(+d: Nat, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}) -> {U32.to_nat(U32.sub(F.u32__pow2u(d), 1)) == Nat.sub(F.spec_common__pow2(d), 1n) : Nat}:
  Equal.trans(Nat, U32.to_nat(U32.sub(F.u32__pow2u(d), 1)), Nat.sub(U32.to_nat(F.u32__pow2u(d)), 1n), Nat.sub(F.spec_common__pow2(d), 1n),
    F.u32__sub_nat(F.u32__pow2u(d), 1, F.u32__one_le_pow2u(d, hd)),
    Equal.cong(Nat, Nat, v => Nat.sub(v, 1n), U32.to_nat(F.u32__pow2u(d)), F.spec_common__pow2(d), F.u32__pow2u_value(d, hd)))

# Reading index 2^d of a 2^d-word array reads slot 0.
def get_wrap(+d: Nat, +t: F.array__Tree<U32>, +q: U32, +eq: {U32.to_nat(q) == VB.pw(d) : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.get(U32, F.array__thaw(U32, t), q) == (F.array__thaw(U32, t), VB.slot(t, 0n)) : Array<U32> & U32}:
  +h0 = F.nat__succ_le_lt(0n, VB.pw(d), F.nat__pow2_pos(d))
  +g0 = VB.get_n(d, t, 0, 0n, {==}, hd, h0, pf)
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(d)), F.array__size_thaw(U32, d, t, pf)) :
    {Array.get.at(U32, q, _) == (F.array__thaw(U32, t), VB.slot(t, 0n)) : Array<U32> & U32}
  %Equal.sym(U32, U32.and(q, U32.sub(F.u32__pow2u(d), 1)), 0, mask_top(q, U32.sub(F.u32__pow2u(d), 1), d, eq, pmask(d, hd))) :
    {Array.get.go(U32, F.array__thaw(U32, t), F.u32__pow2u(d), _, U32.is_lt(_, U32.shr(F.u32__pow2u(d)))) == (F.array__thaw(U32, t), VB.slot(t, 0n)) : Array<U32> & U32}
  +M = U32.sub(F.u32__pow2u(d), 1)
  Equal.trans(Array<U32> & U32, Array.get.go(U32, F.array__thaw(U32, t), F.u32__pow2u(d), 0, U32.is_lt(0, U32.shr(F.u32__pow2u(d)))), Array.get.go(U32, F.array__thaw(U32, t), F.u32__pow2u(d), U32.and(0, M), U32.is_lt(U32.and(0, M), U32.shr(F.u32__pow2u(d)))), (F.array__thaw(U32, t), VB.slot(t, 0n)),
    Equal.cong(U32, Array<U32> & U32, z => Array.get.go(U32, F.array__thaw(U32, t), F.u32__pow2u(d), z, U32.is_lt(z, U32.shr(F.u32__pow2u(d)))), 0, U32.and(0, M), Equal.sym(U32, U32.and(0, M), 0, F.u32__mask_pow2u(0, d, hd, h0))),
    F.logic__subst(Array<U32> & U32, z => {Array.get.at(U32, 0, z) == (F.array__thaw(U32, t), VB.slot(t, 0n)) : Array<U32> & U32}, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(d)), F.array__size_thaw(U32, d, t, pf), g0))

# ---- source words, wrapping at the array's size ------------------------------------------

def wsel(b: Bool, S: F.array__Tree<U32>, +k: Nat) -> U32:
  match b:
    case True{}: VB.slot(S, k)
    case False{}: VB.slot(S, 0n)

# Source word k of a 2^ds-word array as Base Array reads it (k <= 2^ds).
def RS(+ds: Nat, S: F.array__Tree<U32>, +k: Nat) -> U32: wsel(Nat.is_lt(k, VB.pw(ds)), S, k)

def get_rs_c(+ds: Nat, +S: F.array__Tree<U32>, +q: U32, +k: Nat, +eq: {U32.to_nat(q) == k : Nat},
    +hd: {Nat.is_lt(ds, 32n) == True{} : Bool}, +hk: {Nat.is_le(k, VB.pw(ds)) == True{} : Bool},
    +pf: {F.array__perfect(U32, ds, S) == True{} : Bool}, +c: Bool, +ec: {Nat.is_lt(k, VB.pw(ds)) == c : Bool})
    -> {Array.get(U32, F.array__thaw(U32, S), q) == (F.array__thaw(U32, S), wsel(c, S, k)) : Array<U32> & U32}:
  match c:
    case True{}: VB.get_n(ds, S, q, k, eq, hd, ec, pf)
    case False{}:
      get_wrap(ds, S, q, Equal.trans(Nat, U32.to_nat(q), k, VB.pw(ds), eq, F.nat__le_antisym(k, VB.pw(ds), hk, F.nat__not_lt_le(k, VB.pw(ds), ec))), hd, pf)

def get_rs(+ds: Nat, +S: F.array__Tree<U32>, +q: U32, +k: Nat, +eq: {U32.to_nat(q) == k : Nat},
    +hd: {Nat.is_lt(ds, 32n) == True{} : Bool}, +hk: {Nat.is_le(k, VB.pw(ds)) == True{} : Bool},
    +pf: {F.array__perfect(U32, ds, S) == True{} : Bool})
    -> {Array.get(U32, F.array__thaw(U32, S), q) == (F.array__thaw(U32, S), RS(ds, S, k)) : Array<U32> & U32}:
  get_rs_c(ds, S, q, k, eq, hd, hk, pf, Nat.is_lt(k, VB.pw(ds)), {==})

# Below the size, RS is the slot.
def rs_lt_c(+ds: Nat, +S: F.array__Tree<U32>, +k: Nat, +c: Bool, +ec: {Nat.is_lt(k, VB.pw(ds)) == c : Bool}, +h: {Nat.is_lt(k, VB.pw(ds)) == True{} : Bool})
    -> {wsel(c, S, k) == VB.slot(S, k) : U32}:
  match c:
    case True{}: {==}
    case False{}: Empty.absurd({VB.slot(S, 0n) == VB.slot(S, k) : U32}, F.logic__false_true(Equal.trans(Bool, False{}, Nat.is_lt(k, VB.pw(ds)), True{}, Equal.sym(Bool, Nat.is_lt(k, VB.pw(ds)), False{}, ec), h)))

def rs_lt(+ds: Nat, +S: F.array__Tree<U32>, +k: Nat, +h: {Nat.is_lt(k, VB.pw(ds)) == True{} : Bool}) -> {RS(ds, S, k) == VB.slot(S, k) : U32}:
  rs_lt_c(ds, S, k, Nat.is_lt(k, VB.pw(ds)), {==}, h)

# ---- the shifted copy's model --------------------------------------------------------------

# n shifted word copies at byte s: dst[j + x] = join(s, src[i + x], src[i + x + 1]).
def smone(+s: Nat, n: Nat, +i: Nat, +j: Nat, +dd: Nat, +ds: Nat, D: F.array__Tree<U32>, +S: F.array__Tree<U32>) -> F.array__Tree<U32>:
  match n:
    case 0n: D
    case 1n+p: smone(s, p, 1n+i, 1n+j, dd, ds, F.array__upd(U32, dd, D, j, UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i))), S)

law smone_perfect:
  for +s: Nat
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +ds: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  {F.array__perfect(U32, dd, smone(s, n, i, j, dd, ds, D, S)) == True{} : Bool}
def smone_perfect(s, n, i, j, dd, ds, D, S, pf):
  match n:
    case 0n: pf
    case 1n+ +p:
      smone_perfect(s, p, 1n+i, 1n+j, dd, ds, F.array__upd(U32, dd, D, j, UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i))), S,
        F.array__upd_perfect(U32, dd, D, j, UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i)), pf))

law smone_add:
  for +s: Nat
  for +m: Nat
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +ds: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  {smone(s, n, Nat.add(m, i), Nat.add(m, j), dd, ds, smone(s, m, i, j, dd, ds, D, S), S) == smone(s, Nat.add(m, n), i, j, dd, ds, D, S) : F.array__Tree<U32>}
def smone_add(s, m, n, i, j, dd, ds, D, S):
  match m:
    case 0n: {==}
    case 1n+ +p:
      +D1 = F.array__upd(U32, dd, D, j, UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i)))
      %F.nat__add_succ(p, i) :
        {smone(s, n, _, 1n+Nat.add(p, j), dd, ds, smone(s, p, 1n+i, 1n+j, dd, ds, D1, S), S) == smone(s, Nat.add(p, n), 1n+i, 1n+j, dd, ds, D1, S) : F.array__Tree<U32>}
      %F.nat__add_succ(p, j) :
        {smone(s, n, Nat.add(p, 1n+i), _, dd, ds, smone(s, p, 1n+i, 1n+j, dd, ds, D1, S), S) == smone(s, Nat.add(p, n), 1n+i, 1n+j, dd, ds, D1, S) : F.array__Tree<U32>}
      smone_add(s, p, n, 1n+i, 1n+j, dd, ds, D1, S)

# ---- the shifted copy's words, as lists ----------------------------------------------------

# The words of n shifted copies from source word i.
def SJ(+s: Nat, n: Nat, +i: Nat, +ds: Nat, +S: F.array__Tree<U32>) -> List<&2, U32>:
  match n:
    case 0n: []
    case 1n+p: Con{UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i)), SJ(s, p, 1n+i, ds, S)}

# The list model of smone.
def slm(+s: Nat, n: Nat, +i: Nat, +j: Nat, L: List<&2, U32>, +ds: Nat, +S: F.array__Tree<U32>) -> List<&2, U32>:
  match n:
    case 0n: L
    case 1n+p: slm(s, p, 1n+i, 1n+j, F.spec_common__update(U32, L, j, UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i))), ds, S)

law slm_len:
  for +s: Nat
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +L: List<&2, U32>
  for +ds: Nat
  for +S: F.array__Tree<U32>
  {VB.len(slm(s, n, i, j, L, ds, S)) == VB.len(L) : Nat}
def slm_len(s, n, i, j, L, ds, S):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +v = UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i))
      %F.list__length_update(U32, L, j, v) :
        {VB.len(slm(s, p, 1n+i, 1n+j, F.spec_common__update(U32, L, j, v), ds, S)) == _ : Nat}
      slm_len(s, p, 1n+i, 1n+j, F.spec_common__update(U32, L, j, v), ds, S)

law slm_pre:
  for +s: Nat
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +L: List<&2, U32>
  for +ds: Nat
  for +S: F.array__Tree<U32>
  for +k: Nat
  for +hk: {Nat.is_lt(k, j) == True{} : Bool}
  {F.flat__nthc(slm(s, n, i, j, L, ds, S), k) == F.flat__nthc(L, k) : U32}
def slm_pre(s, n, i, j, L, ds, S, k, hk):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +v = UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i))
      +L1 = F.spec_common__update(U32, L, j, v)
      %Equal.sym(U32, F.flat__nthc(slm(s, p, 1n+i, 1n+j, L1, ds, S), k), F.flat__nthc(L1, k), slm_pre(s, p, 1n+i, 1n+j, L1, ds, S, k, F.nat__lt_trans(k, j, 1n+j, hk, F.nat__lt_succ(j)))) :
        {_ == F.flat__nthc(L, k) : U32}
      F.flat__nthc_other(L, j, k, v, F.flat__ne_gt(j, k, hk))

law slm_win:
  for +s: Nat
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +L: List<&2, U32>
  for +ds: Nat
  for +S: F.array__Tree<U32>
  for +hj: {Nat.is_le(Nat.add(n, j), VB.len(L)) == True{} : Bool}
  {VS.wtake(n, VB.wdr(j, slm(s, n, i, j, L, ds, S))) == SJ(s, n, i, ds, S) : List<&2, U32>}
def slm_win(s, n, i, j, L, ds, S, hj):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +v = UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i))
      +L1 = F.spec_common__update(U32, L, j, v)
      +A = slm(s, p, 1n+i, 1n+j, L1, ds, S)
      +hjL = VB.le1_head(p, j, VB.len(L), hj)
      +hjA = F.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, VB.len(L), VB.len(A),
        Equal.sym(Nat, VB.len(A), VB.len(L), Equal.trans(Nat, VB.len(A), VB.len(L1), VB.len(L), slm_len(s, p, 1n+i, 1n+j, L1, ds, S), F.list__length_update(U32, L, j, v))), hjL)
      %Equal.sym(List<&2, U32>, VB.wdr(j, A), Con{F.flat__nthc(A, j), VB.wdr(1n+j, A)}, VB.wdr_eta(j, A, hjA)) :
        {VS.wtake(1n+p, _) == SJ(s, 1n+p, i, ds, S) : List<&2, U32>}
      %Equal.sym(U32, F.flat__nthc(A, j), F.flat__nthc(L1, j), slm_pre(s, p, 1n+i, 1n+j, L1, ds, S, j, F.nat__lt_succ(j))) :
        {Con{_, VS.wtake(p, VB.wdr(1n+j, A))} == Con{v, SJ(s, p, 1n+i, ds, S)} : List<&2, U32>}
      %Equal.sym(U32, F.flat__nthc(L1, j), v, F.flat__nthc_same(L, j, v, hjL)) :
        {Con{_, VS.wtake(p, VB.wdr(1n+j, A))} == Con{v, SJ(s, p, 1n+i, ds, S)} : List<&2, U32>}
      %Equal.sym(List<&2, U32>, VS.wtake(p, VB.wdr(1n+j, A)), SJ(s, p, 1n+i, ds, S),
          slm_win(s, p, 1n+i, 1n+j, L1, ds, S,
            F.logic__subst(Nat, z => {Nat.is_le(Nat.add(p, 1n+j), z) == True{} : Bool}, VB.len(L), VB.len(L1), Equal.sym(Nat, VB.len(L1), VB.len(L), F.list__length_update(U32, L, j, v)), VB.le1_shift(p, j, VB.len(L), hj)))) :
        {Con{v, _} == Con{v, SJ(s, p, 1n+i, ds, S)} : List<&2, U32>}
      {==}

# The slots of the copied tree are its list model.
law slots_smone:
  for +s: Nat
  for +n: Nat
  for +i: Nat
  for +j: Nat
  for +dd: Nat
  for +ds: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hj: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool}
  {F.array__slots(U32, smone(s, n, i, j, dd, ds, D, S)) == slm(s, n, i, j, F.array__slots(U32, D), ds, S) : List<&2, U32>}
def slots_smone(s, n, i, j, dd, ds, D, S, pf, hj):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +v = UA.jn(s, RS(ds, S, i), RS(ds, S, 1n+i))
      +D1 = F.array__upd(U32, dd, D, j, v)
      %Equal.sym(List<&2, U32>, F.array__slots(U32, smone(s, p, 1n+i, 1n+j, dd, ds, D1, S)), slm(s, p, 1n+i, 1n+j, F.array__slots(U32, D1), ds, S),
          slots_smone(s, p, 1n+i, 1n+j, dd, ds, D1, S, F.array__upd_perfect(U32, dd, D, j, v, pf), VB.le1_shift(p, j, VB.pw(dd), hj))) :
        {_ == slm(s, p, 1n+i, 1n+j, F.spec_common__update(U32, F.array__slots(U32, D), j, v), ds, S) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, F.array__slots(U32, D1), F.spec_common__update(U32, F.array__slots(U32, D), j, v),
          F.array__upd_slots(U32, dd, D, j, v, VB.le1_head(p, j, VB.pw(dd), hj), pf)) :
        {slm(s, p, 1n+i, 1n+j, _, ds, S) == slm(s, p, 1n+i, 1n+j, F.spec_common__update(U32, F.array__slots(U32, D), j, v), ds, S) : List<&2, U32>}
      {==}

# The first n words of the copy are SJ.
def smone_words(+s: Nat, +n: Nat, +i: Nat, +dd: Nat, +ds: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_le(Nat.add(n, 0n), VB.pw(dd)) == True{} : Bool})
    -> {VS.wtake(n, F.array__slots(U32, smone(s, n, i, 0n, dd, ds, D, S))) == SJ(s, n, i, ds, S) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, smone(s, n, i, 0n, dd, ds, D, S)), slm(s, n, i, 0n, F.array__slots(U32, D), ds, S), slots_smone(s, n, i, 0n, dd, ds, D, S, pf, hj)) :
    {VS.wtake(n, _) == SJ(s, n, i, ds, S) : List<&2, U32>}
  slm_win(s, n, i, 0n, F.array__slots(U32, D), ds, S,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(n, 0n), z) == True{} : Bool}, VB.pw(dd), VB.len(F.array__slots(U32, D)), Equal.sym(Nat, VB.len(F.array__slots(U32, D)), VB.pw(dd), F.array__slots_length(U32, dd, D, pf)), hj))

# ---- the copy's bytes -------------------------------------------------------------------------

# The source words as the copy reads them: the array's slots, then slot 0 again (the wrapped read).
def WX(+S: F.array__Tree<U32>) -> List<&2, U32>: VF.app(UA.SL(S), [VB.slot(S, 0n)])

law nthc_app_lt:
  for +xs: List<&2, U32>
  for +R: List<&2, U32>
  for +k: Nat
  for +h: {Nat.is_lt(k, VB.len(xs)) == True{} : Bool}
  {F.flat__nthc(VF.app(xs, R), k) == F.flat__nthc(xs, k) : U32}
def nthc_app_lt(xs, R, k, h):
  match xs k:
    case Nil{} _: Empty.absurd({F.flat__nthc(VF.app(Nil{}, R), k) == F.flat__nthc(Nil{}, k) : U32}, F.nat__lt_zero_absurd(k, h))
    case Con{+x, +t} 0n: {==}
    case Con{+x, +t} 1n+ +q: nthc_app_lt(t, R, q, h)

law nthc_app_len:
  for +xs: List<&2, U32>
  for +x: U32
  {F.flat__nthc(VF.app(xs, [x]), VB.len(xs)) == x : U32}
def nthc_app_len(xs, x):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}: nthc_app_len(t, x)

def rs_wx_c(+ds: Nat, +S: F.array__Tree<U32>, +k: Nat, +hk: {Nat.is_le(k, VB.pw(ds)) == True{} : Bool},
    +pf: {F.array__perfect(U32, ds, S) == True{} : Bool}, +c: Bool, +ec: {Nat.is_lt(k, VB.pw(ds)) == c : Bool})
    -> {wsel(c, S, k) == F.flat__nthc(WX(S), k) : U32}:
  match c:
    case True{}:
      +eL = F.array__slots_length(U32, ds, S, pf)
      Equal.sym(U32, F.flat__nthc(WX(S), k), VB.slot(S, k),
        nthc_app_lt(UA.SL(S), [VB.slot(S, 0n)], k, F.logic__subst(Nat, z => {Nat.is_lt(k, z) == True{} : Bool}, VB.pw(ds), VB.len(UA.SL(S)), Equal.sym(Nat, VB.len(UA.SL(S)), VB.pw(ds), eL), ec)))
    case False{}:
      +eL = F.array__slots_length(U32, ds, S, pf)
      +ek = F.nat__le_antisym(k, VB.pw(ds), hk, F.nat__not_lt_le(k, VB.pw(ds), ec))
      %Equal.trans(Nat, VB.len(UA.SL(S)), VB.pw(ds), k, eL, Equal.sym(Nat, k, VB.pw(ds), ek)) : {VB.slot(S, 0n) == F.flat__nthc(WX(S), _) : U32}
      Equal.sym(U32, F.flat__nthc(WX(S), VB.len(UA.SL(S))), VB.slot(S, 0n), nthc_app_len(UA.SL(S), VB.slot(S, 0n)))

def rs_wx(+ds: Nat, +S: F.array__Tree<U32>, +k: Nat, +hk: {Nat.is_le(k, VB.pw(ds)) == True{} : Bool},
    +pf: {F.array__perfect(U32, ds, S) == True{} : Bool}) -> {RS(ds, S, k) == F.flat__nthc(WX(S), k) : U32}:
  rs_wx_c(ds, S, k, hk, pf, Nat.is_lt(k, VB.pw(ds)), {==})

# The words of n shifted copies from word i of a list.
def SJW(+s: Nat, n: Nat, +i: Nat, +W: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: []
    case 1n+p: Con{UA.jn(s, F.flat__nthc(W, i), F.flat__nthc(W, 1n+i)), SJW(s, p, 1n+i, W)}

law sj_wx:
  for +s: Nat
  for +n: Nat
  for +i: Nat
  for +ds: Nat
  for +S: F.array__Tree<U32>
  for +pf: {F.array__perfect(U32, ds, S) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(n, i), VB.pw(ds)) == True{} : Bool}
  {SJ(s, n, i, ds, S) == SJW(s, n, i, WX(S)) : List<&2, U32>}
def sj_wx(s, n, i, ds, S, pf, h):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +h1 = VB.le1_next(p, i, VB.pw(ds), h)
      +h0 = F.nat__le_trans(i, 1n+i, VB.pw(ds), F.nat__le_succ(i), h1)
      %Equal.sym(U32, RS(ds, S, i), F.flat__nthc(WX(S), i), rs_wx(ds, S, i, h0, pf)) :
        {Con{UA.jn(s, _, RS(ds, S, 1n+i)), SJ(s, p, 1n+i, ds, S)} == SJW(s, 1n+p, i, WX(S)) : List<&2, U32>}
      %Equal.sym(U32, RS(ds, S, 1n+i), F.flat__nthc(WX(S), 1n+i), rs_wx(ds, S, 1n+i, h1, pf)) :
        {Con{UA.jn(s, F.flat__nthc(WX(S), i), _), SJ(s, p, 1n+i, ds, S)} == SJW(s, 1n+p, i, WX(S)) : List<&2, U32>}
      %Equal.sym(List<&2, U32>, SJ(s, p, 1n+i, ds, S), SJW(s, p, 1n+i, WX(S)), sj_wx(s, p, 1n+i, ds, S, pf, VB.le1_shift(p, i, VB.pw(ds), h))) :
        {Con{UA.jn(s, F.flat__nthc(WX(S), i), F.flat__nthc(WX(S), 1n+i)), _} == SJW(s, 1n+p, i, WX(S)) : List<&2, U32>}
      {==}

# The limbs of n shifted copies at byte s (0 < s < 4) are the 4 n bytes from 4 i + s.
law sjw_bytes:
  for +s: Nat
  for +n: Nat
  for +i: Nat
  for +W: List<&2, U32>
  for +hr: {Nat.is_lt(s, 4n) == True{} : Bool}
  for +h: {Nat.is_lt(Nat.add(n, i), VB.len(W)) == True{} : Bool}
  {FX.limbs(SJW(s, n, i, W)) == VS.bt(A.quad(n), VS.bdr(Nat.add(A.quad(i), s), FX.limbs(W))) : +List<U32>}
def sjw_bytes(s, n, i, W, hr, h):
  match n:
    case 0n: {==}
    case 1n+ +p:
      +X = Nat.add(A.quad(i), s)
      +LW = FX.limbs(W)
      +v = UA.jn(s, F.flat__nthc(W, i), F.flat__nthc(W, 1n+i))
      +h1i = F.nat__le_lt_trans(1n+i, 1n+Nat.add(p, i), VB.len(W), Order.left_below_sum(p, i), h)
      +h0 = F.nat__lt_trans(i, 1n+i, VB.len(W), F.nat__lt_succ(i), h1i)
      +hp = F.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(W)) == True{} : Bool}, 1n+Nat.add(p, i), Nat.add(p, 1n+i), Equal.sym(Nat, Nat.add(p, 1n+i), 1n+Nat.add(p, i), F.nat__add_succ(p, i)), h)
      %Equal.sym(+List<U32>, VS.bt(Nat.add(4n, A.quad(p)), VS.bdr(X, LW)), List.append(&2, U32, VS.bt(4n, VS.bdr(X, LW)), VS.bt(A.quad(p), VS.bdr(4n, VS.bdr(X, LW)))), VBC.bt_split(4n, A.quad(p), VS.bdr(X, LW))) :
        {List.append(&2, U32, I.limb(v), FX.limbs(SJW(s, p, 1n+i, W))) == _ : +List<U32>}
      %VN.bdr_add(X, 4n, LW) :
        {List.append(&2, U32, I.limb(v), FX.limbs(SJW(s, p, 1n+i, W))) == List.append(&2, U32, VS.bt(4n, VS.bdr(X, LW)), VS.bt(A.quad(p), _)) : +List<U32>}
      %Equal.sym(Nat, Nat.add(X, 4n), Nat.add(4n, X), F.nat__add_comm(X, 4n)) :
        {List.append(&2, U32, I.limb(v), FX.limbs(SJW(s, p, 1n+i, W))) == List.append(&2, U32, VS.bt(4n, VS.bdr(X, LW)), VS.bt(A.quad(p), VS.bdr(_, LW))) : +List<U32>}
      %Equal.sym(+List<U32>, FX.limbs(SJW(s, p, 1n+i, W)), VS.bt(A.quad(p), VS.bdr(Nat.add(A.quad(1n+i), s), LW)), sjw_bytes(s, p, 1n+i, W, hr, hp)) :
        {List.append(&2, U32, I.limb(v), _) == List.append(&2, U32, VS.bt(4n, VS.bdr(X, LW)), VS.bt(A.quad(p), VS.bdr(4n+X, LW))) : +List<U32>}
      %UA.bytes_r(W, i, s, hr, h0, hq => h1i) :
        {List.append(&2, U32, I.limb(v), VS.bt(A.quad(p), VS.bdr(4n+X, LW))) == List.append(&2, U32, _, VS.bt(A.quad(p), VS.bdr(4n+X, LW))) : +List<U32>}
      %Equal.sym(+List<U32>, List.append(&2, U32, I.limb(v), []), I.limb(v), VS.app_nil(I.limb(v))) :
        {List.append(&2, U32, I.limb(v), VS.bt(A.quad(p), VS.bdr(4n+X, LW))) == List.append(&2, U32, _, VS.bt(A.quad(p), VS.bdr(4n+X, LW))) : +List<U32>}
      {==}

law bt_le:
  for +a: Nat
  for +c: Nat
  for +xs: +List<U32>
  for +h: {Nat.is_le(a, c) == True{} : Bool}
  {VS.bt(a, VS.bt(c, xs)) == VS.bt(a, xs) : +List<U32>}
def bt_le(a, c, xs, h):
  match a c xs:
    case 0n _ _: {==}
    case 1n+ +p 0n _: Empty.absurd({VS.bt(1n+p, VS.bt(0n, xs)) == VS.bt(1n+p, xs) : +List<U32>}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q Nil{}: {==}
    case 1n+ +p 1n+ +q Con{+x, +t}:
      %bt_le(p, q, t, h) : {x <> VS.bt(p, VS.bt(q, t)) == x <> _ : +List<U32>}
      {==}

law bdr_app_le:
  for +P: Nat
  for +xs: +List<U32>
  for +R: +List<U32>
  for +h: {Nat.is_le(P, List.length(&2, U32, xs)) == True{} : Bool}
  {VS.bdr(P, List.append(&2, U32, xs, R)) == List.append(&2, U32, VS.bdr(P, xs), R) : +List<U32>}
def bdr_app_le(P, xs, R, h):
  match P xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({VS.bdr(1n+p, List.append(&2, U32, Nil{}, R)) == List.append(&2, U32, VS.bdr(1n+p, Nil{}), R) : +List<U32>}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: bdr_app_le(p, t, R, h)

def len_wx(+ds: Nat, +S: F.array__Tree<U32>, +pf: {F.array__perfect(U32, ds, S) == True{} : Bool}) -> {VB.len(WX(S)) == 1n+VB.pw(ds) : Nat}:
  %Equal.sym(Nat, VB.len(WX(S)), Nat.add(VB.len(UA.SL(S)), 1n), F.list__length_append(U32, UA.SL(S), [VB.slot(S, 0n)])) : {_ == 1n+VB.pw(ds) : Nat}
  %Equal.sym(Nat, VB.len(UA.SL(S)), VB.pw(ds), F.array__slots_length(U32, ds, S, pf)) : {Nat.add(_, 1n) == 1n+VB.pw(ds) : Nat}
  F.nat__add_comm(VB.pw(ds), 1n)

# U2, bytes: the first L bytes of n shifted copies from word i at byte s
# (0 < s < 4) are the buffer's spec bytes [4 i + s, 4 i + s + L).
law sm_bytes:
  for +s: Nat
  for +n: Nat
  for +L: Nat
  for +i: Nat
  for +dd: Nat
  for +ds: Nat
  for +D: F.array__Tree<U32>
  for +S: F.array__Tree<U32>
  for +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +pfS: {F.array__perfect(U32, ds, S) == True{} : Bool}
  for +hr: {Nat.is_lt(s, 4n) == True{} : Bool}
  for +hn: {Nat.is_le(Nat.add(n, 0n), VB.pw(dd)) == True{} : Bool}
  for +hi: {Nat.is_le(Nat.add(n, i), VB.pw(ds)) == True{} : Bool}
  for +hL: {Nat.is_le(L, A.quad(n)) == True{} : Bool}
  for +hB: {Nat.is_le(Nat.add(Nat.add(A.quad(i), s), L), A.quad(VB.pw(ds))) == True{} : Bool}
  {VS.bt(L, FX.limbs(F.array__slots(U32, smone(s, n, i, 0n, dd, ds, D, S)))) == VS.bt(L, VS.bdr(Nat.add(A.quad(i), s), UA.BYT(S))) : +List<U32>}
def sm_bytes(s, n, L, i, dd, ds, D, S, pfD, pfS, hr, hn, hi, hL, hB):
  +SM = F.array__slots(U32, smone(s, n, i, 0n, dd, ds, D, S))
  +P = Nat.add(A.quad(i), s)
  +R = FX.limbs([VB.slot(S, 0n)])
  +hW = F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(n, i), z) == True{} : Bool}, 1n+VB.pw(ds), VB.len(WX(S)), Equal.sym(Nat, VB.len(WX(S)), 1n+VB.pw(ds), len_wx(ds, S, pfS)),
    F.nat__le_lt_trans(Nat.add(n, i), VB.pw(ds), 1n+VB.pw(ds), hi, F.nat__lt_succ(VB.pw(ds))))
  +eB = VR.lenS(ds, S, pfS)
  +hB2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(P, L), z) == True{} : Bool}, A.quad(VB.pw(ds)), List.length(&2, U32, UA.BYT(S)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(S)), A.quad(VB.pw(ds)), eB), hB)
  +hP = F.nat__le_trans(P, Nat.add(P, L), List.length(&2, U32, UA.BYT(S)), Order.below_sum(P, L), hB2)
  %bt_le(L, A.quad(n), FX.limbs(SM), hL) :
    {_ == VS.bt(L, VS.bdr(P, UA.BYT(S))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(n), FX.limbs(SM)), FX.limbs(VS.wtake(n, SM)), VS.bt_limbs(n, SM)) :
    {VS.bt(L, _) == VS.bt(L, VS.bdr(P, UA.BYT(S))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(n, SM), SJ(s, n, i, ds, S), smone_words(s, n, i, dd, ds, D, S, pfD, hn)) :
    {VS.bt(L, FX.limbs(_)) == VS.bt(L, VS.bdr(P, UA.BYT(S))) : +List<U32>}
  %Equal.sym(List<&2, U32>, SJ(s, n, i, ds, S), SJW(s, n, i, WX(S)), sj_wx(s, n, i, ds, S, pfS, hi)) :
    {VS.bt(L, FX.limbs(_)) == VS.bt(L, VS.bdr(P, UA.BYT(S))) : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(SJW(s, n, i, WX(S))), VS.bt(A.quad(n), VS.bdr(P, FX.limbs(WX(S)))), sjw_bytes(s, n, i, WX(S), hr, hW)) :
    {VS.bt(L, _) == VS.bt(L, VS.bdr(P, UA.BYT(S))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(L, VS.bt(A.quad(n), VS.bdr(P, FX.limbs(WX(S))))), VS.bt(L, VS.bdr(P, FX.limbs(WX(S)))), bt_le(L, A.quad(n), VS.bdr(P, FX.limbs(WX(S))), hL)) :
    {_ == VS.bt(L, VS.bdr(P, UA.BYT(S))) : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(WX(S)), List.append(&2, U32, UA.BYT(S), R), VF.limbs_app(UA.SL(S), [VB.slot(S, 0n)])) :
    {VS.bt(L, VS.bdr(P, _)) == VS.bt(L, VS.bdr(P, UA.BYT(S))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(P, List.append(&2, U32, UA.BYT(S), R)), List.append(&2, U32, VS.bdr(P, UA.BYT(S)), R), bdr_app_le(P, UA.BYT(S), R, hP)) :
    {VS.bt(L, _) == VS.bt(L, VS.bdr(P, UA.BYT(S))) : +List<U32>}
  VN.bt_app(L, VS.bdr(P, UA.BYT(S)), R, VR.bdr_len(P, UA.BYT(S), L, hB2))

# L <= 4 ceil(L / 4).
def lquadU(+L: U32, +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(L), A.quad(VC.NW(L))) == True{} : Bool}:
  %Equal.sym(Nat, VC.NW(L), VD.s_rng(2n, 3n+U32.to_nat(L)), VC.eNWu(L, hy)) : {Nat.is_le(U32.to_nat(L), A.quad(_)) == True{} : Bool}
  F.nat__le_trans(3n+U32.to_nat(L), 1n+Nat.double(VD.s_h2(3n+U32.to_nat(L))), 3n+A.quad(VD.s_h2(VD.s_h2(3n+U32.to_nat(L)))), VC.h2_up(3n+U32.to_nat(L)),
    Order.double_monotone(VD.s_h2(3n+U32.to_nat(L)), 1n+Nat.double(VD.s_h2(VD.s_h2(3n+U32.to_nat(L)))), VC.h2_up(VD.s_h2(3n+U32.to_nat(L)))))

def lquad(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(L), A.quad(VC.NW(L))) == True{} : Bool}:
  lquadU(L, VC.hyU(L, k, hk, hy))

# U2, bytes of the copy: copy_in's storage at byte s = 1, 2, 3 (MK of smone,
# see vua_sc.ci_any*) has the buffer's spec bytes [4 i + s, 4 i + s + L) first.
law ci_bytesU:
  for +s: Nat
  for +L: U32
  for +i: Nat
  for +dz: Nat
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +hy: {Nat.is_le(VC.YL(L), U32.to_nat(VB.UMAX())) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hr: {Nat.is_lt(s, 4n) == True{} : Bool}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hz: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hB: {Nat.is_le(Nat.add(Nat.add(A.quad(i), s), U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool}
  {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, VBY.MK(L, dz, smone(s, VC.NW(L), i, 0n, dz, d, VC.ZT(dz), t))))) == VS.bt(U32.to_nat(L), VS.bdr(Nat.add(A.quad(i), s), UA.BYT(t))) : +List<U32>}
def ci_bytesU(s, L, i, dz, d, t, hy, pf, hr, hs, hz, hB):
  +M = smone(s, VC.NW(L), i, 0n, dz, d, VC.ZT(dz), t)
  +pz = F.array__trep_perfect(U32, dz, 0)
  Equal.trans(+List<U32>, VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, VBY.MK(L, dz, M)))), VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, M))), VS.bt(U32.to_nat(L), VS.bdr(Nat.add(A.quad(i), s), UA.BYT(t))),
    VBY.mk_bytesU(L, dz, M, hy, F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dz)) == True{} : Bool}, Nat.add(VC.NW(L), 0n), VC.NW(L), F.nat__add_zero(VC.NW(L)), hz),
      smone_perfect(s, VC.NW(L), i, 0n, dz, d, VC.ZT(dz), t, pz)),
    sm_bytes(s, VC.NW(L), U32.to_nat(L), i, dz, d, VC.ZT(dz), t, pz, pf, hr, hz, hs, lquadU(L, hy), hB))

law ci_bytes:
  for +s: Nat
  for +L: U32
  for +i: Nat
  for +dz: Nat
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +k: Nat
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hr: {Nat.is_lt(s, 4n) == True{} : Bool}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hz: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hB: {Nat.is_le(Nat.add(Nat.add(A.quad(i), s), U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool}
  {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, VBY.MK(L, dz, smone(s, VC.NW(L), i, 0n, dz, d, VC.ZT(dz), t))))) == VS.bt(U32.to_nat(L), VS.bdr(Nat.add(A.quad(i), s), UA.BYT(t))) : +List<U32>}
def ci_bytes(s, L, i, dz, d, t, k, hk, hy, pf, hr, hs, hz, hB):
  ci_bytesU(s, L, i, dz, d, t, VC.hyU(L, k, hk, hy), pf, hr, hs, hz, hB)
