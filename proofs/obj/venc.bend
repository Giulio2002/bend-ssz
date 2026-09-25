import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vcopy.bend as VC

# The encoders' runtime pieces on the array model: the checked size sum
# O.padd, an aligned word write, the aligned bulk write of O.put_words, and
# the storage check O.words_ok of a list of whole words.

# ---- O.padd of two values with a clear top bit is their sum ----------------------------

def top(n: Nat) -> Word(1n+n):
  match n:
    case 0n: WCon{True{}, WNil{}}
    case 1n+p: WCon{False{}, top(p)}

law and_or_top:
  for +n: Nat
  for +a: Word(n)
  for +b: Word(n)
  {Word.and(1n+n, Word.or(1n+n, Word.shr.pad(n, a), Word.shr.pad(n, b)), top(n)) == Word.zero(1n+n) : Word(1n+n)}
def and_or_top(n, a, b):
  match n a b:
    case 0n WNil{} WNil{}: {==}
    case 1n+ +p WCon{False{}, +at} WCon{False{}, +bt}:
      %Equal.sym(Word(1n+p), Word.and(1n+p, Word.or(1n+p, Word.shr.pad(p, at), Word.shr.pad(p, bt)), top(p)), Word.zero(1n+p), and_or_top(p, at, bt)) : {WCon{False{}, _} == Word.zero(2n+p) : Word(2n+p)}
      {==}
    case 1n+ +p WCon{False{}, +at} WCon{True{}, +bt}:
      %Equal.sym(Word(1n+p), Word.and(1n+p, Word.or(1n+p, Word.shr.pad(p, at), Word.shr.pad(p, bt)), top(p)), Word.zero(1n+p), and_or_top(p, at, bt)) : {WCon{False{}, _} == Word.zero(2n+p) : Word(2n+p)}
      {==}
    case 1n+ +p WCon{True{}, +at} WCon{False{}, +bt}:
      %Equal.sym(Word(1n+p), Word.and(1n+p, Word.or(1n+p, Word.shr.pad(p, at), Word.shr.pad(p, bt)), top(p)), Word.zero(1n+p), and_or_top(p, at, bt)) : {WCon{False{}, _} == Word.zero(2n+p) : Word(2n+p)}
      {==}
    case 1n+ +p WCon{True{}, +at} WCon{True{}, +bt}:
      %Equal.sym(Word(1n+p), Word.and(1n+p, Word.or(1n+p, Word.shr.pad(p, at), Word.shr.pad(p, bt)), top(p)), Word.zero(1n+p), and_or_top(p, at, bt)) : {WCon{False{}, _} == Word.zero(2n+p) : Word(2n+p)}
      {==}

law or_zero:
  for +n: Nat
  for +w: Word(n)
  {Word.or(n, w, Word.zero(n)) == w : Word(n)}
def or_zero(n, w):
  match n w:
    case 0n WNil{}: {==}
    case 1n+ +p WCon{False{}, +t}:
      %Equal.sym(Word(p), Word.or(p, t, Word.zero(p)), t, or_zero(p, t)) : {WCon{False{}, _} == WCon{False{}, t} : Word(1n+p)}
      {==}
    case 1n+ +p WCon{True{}, +t}:
      %Equal.sym(Word(p), Word.or(p, t, Word.zero(p)), t, or_zero(p, t)) : {WCon{True{}, _} == WCon{True{}, t} : Word(1n+p)}
      {==}

def or_zero_u(+x: U32) -> {U32.or(x, U32{Word.zero(32n)}) == x : U32}:
  match x:
    case U32{+w}: Equal.cong(Word(32n), U32, v => U32{v}, Word.or(32n, w, Word.zero(32n)), w, or_zero(32n, w))

def padd_ok(+a: U32, +b: U32, +av: Word(31n), +bv: Word(31n), +ea: {a == U32{Word.shr.pad(31n, av)} : U32}, +eb: {b == U32{Word.shr.pad(31n, bv)} : U32})
    -> {O.padd(a, b) == U32.add(a, b) : U32}:
  %Equal.sym(U32, a, U32{Word.shr.pad(31n, av)}, ea) : {U32.or(U32.add(a, b), U32.and(U32.or(_, b), 2147483648)) == U32.add(a, b) : U32}
  %Equal.sym(U32, b, U32{Word.shr.pad(31n, bv)}, eb) : {U32.or(U32.add(a, b), U32.and(U32.or(U32{Word.shr.pad(31n, av)}, _), 2147483648)) == U32.add(a, b) : U32}
  %Equal.sym(Word(32n), Word.and(32n, Word.or(32n, Word.shr.pad(31n, av), Word.shr.pad(31n, bv)), top(31n)), Word.zero(32n), and_or_top(31n, av, bv)) :
    {U32.or(U32.add(a, b), U32{_}) == U32.add(a, b) : U32}
  or_zero_u(U32.add(a, b))

# ---- a value below 2^k (k <= 31) has a clear top bit ------------------------------------------

def winit(n: Nat, w: Word(1n+n)) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+p:
      match w:
        case WCon{b, t}: WCon{b, winit(p, t)}

def wlast(n: Nat, w: Word(1n+n)) -> Bool:
  match n:
    case 0n:
      match w:
        case WCon{b, t}: b
    case 1n+p:
      match w:
        case WCon{b, t}: wlast(p, t)

law split_last:
  for +n: Nat
  for +w: Word(1n+n)
  {VU.uw(1n+n, w) == Nat.add(VU.uw(n, winit(n, w)), F.spec_numeric__scale_binary(n, F.spec_numeric__bit_value(wlast(n, w)))) : Nat}
def split_last(n, w):
  match n w:
    case 0n WCon{False{}, WNil{}}: {==}
    case 0n WCon{True{}, WNil{}}: {==}
    case 1n+ +p WCon{+b, +t}:
      %Equal.sym(Nat, VU.uw(1n+p, t), Nat.add(VU.uw(p, winit(p, t)), F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t)))), split_last(p, t)) :
        {Nat.add(F.spec_numeric__bit_value(b), Nat.double(_)) == Nat.add(Nat.add(F.spec_numeric__bit_value(b), Nat.double(VU.uw(p, winit(p, t)))), Nat.double(F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t))))) : Nat}
      %Equal.sym(Nat, Nat.double(Nat.add(VU.uw(p, winit(p, t)), F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t))))),
          Nat.add(Nat.double(VU.uw(p, winit(p, t))), Nat.double(F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t))))),
          Equal.sym(Nat, Nat.add(Nat.double(VU.uw(p, winit(p, t))), Nat.double(F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t))))),
            Nat.double(Nat.add(VU.uw(p, winit(p, t)), F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t))))),
            F.nat__add_double(VU.uw(p, winit(p, t)), F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t)))))) :
        {Nat.add(F.spec_numeric__bit_value(b), _) == Nat.add(Nat.add(F.spec_numeric__bit_value(b), Nat.double(VU.uw(p, winit(p, t)))), Nat.double(F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t))))) : Nat}
      Equal.sym(Nat, Nat.add(Nat.add(F.spec_numeric__bit_value(b), Nat.double(VU.uw(p, winit(p, t)))), Nat.double(F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t))))),
        Nat.add(F.spec_numeric__bit_value(b), Nat.add(Nat.double(VU.uw(p, winit(p, t))), Nat.double(F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t)))))),
        F.nat__add_assoc(F.spec_numeric__bit_value(b), Nat.double(VU.uw(p, winit(p, t))), Nat.double(F.spec_numeric__scale_binary(p, F.spec_numeric__bit_value(wlast(p, t))))))

law pad_eta:
  for +n: Nat
  for +w: Word(1n+n)
  for +h: {wlast(n, w) == False{} : Bool}
  {w == Word.shr.pad(n, winit(n, w)) : Word(1n+n)}
def pad_eta(n, w, h):
  match n w:
    case 0n WCon{False{}, WNil{}}: {==}
    case 0n WCon{True{}, WNil{}}: Empty.absurd({WCon{True{}, WNil{}} == Word.shr.pad(0n, winit(0n, WCon{True{}, WNil{}})) : Word(1n)}, F.logic__true_false(h))
    case 1n+ +p WCon{+b, +t}:
      %pad_eta(p, t, h) : {WCon{b, t} == WCon{b, _} : Word(2n+p)}
      {==}

def last_go(+n: Nat, +w: Word(1n+n), +k: Nat, +hk: {Nat.is_le(k, n) == True{} : Bool},
    +h: {Nat.is_lt(VU.uw(1n+n, w), F.spec_common__pow2(k)) == True{} : Bool}, +c: Bool, +ec: {wlast(n, w) == c : Bool})
    -> {wlast(n, w) == False{} : Bool}:
  match c:
    case False{}: ec
    case True{}:
      +S = F.spec_numeric__scale_binary(n, 1n)
      +e1 = F.logic__subst(Bool, z => {VU.uw(1n+n, w) == Nat.add(VU.uw(n, winit(n, w)), F.spec_numeric__scale_binary(n, F.spec_numeric__bit_value(z))) : Nat}, wlast(n, w), True{}, ec, split_last(n, w))
      +ge = F.logic__subst(Nat, z => {Nat.is_le(S, z) == True{} : Bool}, Nat.add(VU.uw(n, winit(n, w)), S), VU.uw(1n+n, w), Equal.sym(Nat, VU.uw(1n+n, w), Nat.add(VU.uw(n, winit(n, w)), S), e1),
        Order.left_below_sum(VU.uw(n, winit(n, w)), S))
      +lt = F.nat__lt_le_trans(VU.uw(1n+n, w), F.spec_common__pow2(k), S, h, F.u32__pow2_le_scale(n, k, hk))
      Empty.absurd({wlast(n, w) == False{} : Bool}, F.nat__lt_ne(S, S, F.nat__le_lt_trans(S, VU.uw(1n+n, w), S, ge, lt), {==}))

def bits32(x: U32) -> Word(32n):
  match x:
    case U32{w}: w

# A word below 2^k (k <= 31) is the padding of its low 31 bits.
def small_pad(+x: U32, +k: Nat, +hk: {Nat.is_le(k, 31n) == True{} : Bool}, +h: {Nat.is_lt(U32.to_nat(x), F.spec_common__pow2(k)) == True{} : Bool})
    -> {x == U32{Word.shr.pad(31n, winit(31n, bits32(x)))} : U32}:
  match x:
    case U32{+w}:
      +h1 = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(k)) == True{} : Bool}, U32.to_nat(U32{w}), VU.uw(32n, w), F.u32__to_nat_word(w), h)
      Equal.cong(Word(32n), U32, v => U32{v}, w, Word.shr.pad(31n, winit(31n, w)),
        pad_eta(31n, w, last_go(31n, w, k, hk, h1, wlast(31n, w), {==})))


# ---- reads at any index -----------------------------------------------------------------

def get_any(+d: Nat, +t: F.array__Tree<U32>, +q: U32, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {Array.get(U32, F.array__thaw(U32, t), q) == (F.array__thaw(U32, t), RD.wd(t, d, q)) : Array<U32> & U32}:
  +m = RD.masked(q, d)
  +hm = RD.mask_lt(q, d, hd)
  +x = F.flat__nthc(F.array__slots(U32, t), U32.to_nat(m))
  +hx = F.flat__nthc_nth(F.array__slots(U32, t), U32.to_nat(m), F.array__len_lt(U32, d, t, U32.to_nat(m), pf, hm))
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, t)), (F.array__thaw(U32, t), F.u32__pow2u(d)), F.array__size_thaw(U32, d, t, pf)) :
    {Array.get.at(U32, q, _) == (F.array__thaw(U32, t), RD.wd(t, d, q)) : Array<U32> & U32}
  F.array__get_go(U32, d, t, m, x, hd, hm, hx, U32.is_lt(m, F.u32__pow2u(F.nat__pred(d))), {==}, pf)

# ---- the aligned bulk write ------------------------------------------------------------------

def pw_case(+dd: Nat, +dw: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hn3: {U32.and(n, 3) == 0 : U32},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +z: Bool, +ez: {U32.is_eq(n, 0) == z : Bool})
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
      %Equal.sym(U32, U32.and(n, 3), 0, hn3) :
        {O.put_fin(n, O.pw_al_tail(U32.is_eq(_, 0), VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(U32.is_eq(_, 0), VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T))))
          == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      %Equal.sym(Array<U32> & Array<U32>, O.acopy(VC.nwu(n), 0, U32.shrn(p, 2n), F.array__thaw(U32, D), F.array__thaw(U32, T)),
          (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), F.array__thaw(U32, T)),
          VB.acopy_ok(VC.nwu(n), 0, U32.shrn(p, 2n), 0n, P, dd, dw, D, T, {==}, eP, hdd, hdw, hsrc, hdst, pfD, pfT)) :
        {O.put_fin(n, _) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}

# O.put_words of a whole number of words at a word-aligned position copies them.
law put_words_ok:
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
  for +hn3: {U32.and(n, 3) == 0 : U32}
  for +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool}
  for +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool}
  {O.put_words(F.array__thaw(U32, D), p, O.Words{F.array__thaw(U32, T), n}) == (F.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{F.array__thaw(U32, T), n}) : Array<U32> & O.Words}
def put_words_ok(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, hn3, hsrc, hdst):
  pw_case(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, hn3, hsrc, hdst, U32.is_eq(n, 0), {==})

# ---- the storage check of a list of whole u64 elements ------------------------------------------

def and7_x8(+L: U32, +c: Nat, +e: {U32.to_nat(L) == VS.x8(c) : Nat}) -> {U32.and(L, 7) == 0 : U32}:
  +q = U32.to_nat(U32.shrn(L, 3n))
  +r = U32.to_nat(U32.and(L, 7))
  +e1 = Equal.trans(Nat, Nat.add(Nat.mul(q, 8n), r), Nat.add(VS.x8(q), r), Nat.add(Nat.mul(c, 8n), 0n),
    Equal.cong(Nat, Nat, z => Nat.add(z, r), Nat.mul(q, 8n), VS.x8(q), VC.x8_mul(q)),
    Equal.trans(Nat, Nat.add(VS.x8(q), r), U32.to_nat(L), Nat.add(Nat.mul(c, 8n), 0n), Equal.sym(Nat, U32.to_nat(L), Nat.add(VS.x8(q), r), VB.split8(L)),
      Equal.trans(Nat, U32.to_nat(L), VS.x8(c), Nat.add(Nat.mul(c, 8n), 0n), e,
        Equal.trans(Nat, VS.x8(c), Nat.mul(c, 8n), Nat.add(Nat.mul(c, 8n), 0n), Equal.sym(Nat, Nat.mul(c, 8n), VS.x8(c), VC.x8_mul(c)),
          Equal.sym(Nat, Nat.add(Nat.mul(c, 8n), 0n), Nat.mul(c, 8n), F.nat__add_zero(Nat.mul(c, 8n)))))))
  +hr = F.nat__le_lt_trans(r, 7n, 8n, RD.and_le(L, 7), {==})
  F.u32__injective(U32.and(L, 7), 0, Pair.snd({q == c : Nat}, {r == 0n : Nat}, VU.dm_unique(q, r, c, 0n, 8n, e1, hr, {==})))

def is_true(+b: Bool, +e: {b == True{} : Bool}) -> {b == True{} : Bool}: e

def le0(+n: U32) -> {U32.is_le(0, n) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(0, n), Nat.is_le(U32.to_nat(0), U32.to_nat(n)), VU.le_u32(0, n)) : {_ == True{} : Bool}
  F.nat__zero_le(U32.to_nat(n))

def le_hi(+n: U32, +hi: U32, +h: {Nat.is_le(U32.to_nat(n), U32.to_nat(hi)) == True{} : Bool}) -> {U32.is_le(n, hi) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(n, hi), Nat.is_le(U32.to_nat(n), U32.to_nat(hi)), VU.le_u32(n, hi)) : {_ == True{} : Bool}
  h

def le_room(+n: U32, +dw: Nat, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +h: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool})
    -> {U32.is_le(VC.nwu(n), F.u32__pow2u(dw)) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(VC.nwu(n), F.u32__pow2u(dw)), Nat.is_le(VC.NW(n), U32.to_nat(F.u32__pow2u(dw))), VU.le_u32(VC.nwu(n), F.u32__pow2u(dw))) : {_ == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(F.u32__pow2u(dw)), VB.pw(dw), F.u32__pow2u_value(dw, VB.lt32(dw, hdw))) : {Nat.is_le(VC.NW(n), _) == True{} : Bool}
  F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, Nat.add(VC.NW(n), 0n), VC.NW(n), F.nat__add_zero(VC.NW(n)), h)

law words_ok_u64:
  for +dw: Nat
  for +T: F.array__Tree<U32>
  for +n: U32
  for +hi: U32
  for +c: Nat
  for +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}
  for +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}
  for +ec: {U32.to_nat(n) == VS.x8(c) : Nat}
  for +hle: {Nat.is_le(U32.to_nat(n), U32.to_nat(hi)) == True{} : Bool}
  for +hroom: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool}
  {O.words_ok(O.Words{F.array__thaw(U32, T), n}, 0, hi, False{}, 8) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
def words_ok_u64(dw, T, n, hi, c, pfT, hdw, ec, hle, hroom):
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, T)), (F.array__thaw(U32, T), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, T, pfT)) :
    {O.wk_cap(Bool.and(Bool.and(U32.is_le(0, n), Bool.or(False{}, U32.is_le(n, hi))), O.unit_ok(8, n)), n, _) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n)), (F.array__thaw(U32, T), RD.wd(T, dw, U32.shrn(n, 2n))), get_any(dw, T, U32.shrn(n, 2n), VB.lt32(dw, hdw), pfT)) :
    {O.wk_last(Bool.and(Bool.and(Bool.and(U32.is_le(0, n), Bool.or(False{}, U32.is_le(n, hi))), O.unit_ok(8, n)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), n, _) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(0, n), True{}, le0(n)) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(_, Bool.or(False{}, U32.is_le(n, hi))), O.unit_ok(8, n)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), O.tail_zero(U32.and(n, 3), RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(n, hi), True{}, le_hi(n, hi, hle)) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, _)), O.unit_ok(8, n)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), O.tail_zero(U32.and(n, 3), RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(U32, U32.and(n, 7), 0, and7_x8(n, c, ec)) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, True{})), U32.is_eq(_, 0)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), O.tail_zero(U32.and(n, 3), RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(VC.nwu(n), F.u32__pow2u(dw)), True{}, le_room(n, dw, hdw, hroom)) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, True{})), U32.is_eq(0, 0)), _), O.tail_zero(U32.and(n, 3), RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(U32, U32.and(n, 3), 0, VC.and3_x8(n, c, ec)) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, True{})), U32.is_eq(0, 0)), True{}), O.tail_zero(_, RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  {==}
