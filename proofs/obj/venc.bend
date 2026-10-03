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

# A word with 31 free bits is below 2^31.
def word31_lt(+x: U32, +v: Word(31n), +e: {x == U32{Word.shr.pad(31n, v)} : U32})
    -> {Nat.is_lt(U32.to_nat(x), F.spec_common__pow2(31n)) == True{} : Bool}:
  %Equal.sym(U32, x, U32{Word.shr.pad(31n, v)}, e) : {Nat.is_lt(U32.to_nat(_), F.spec_common__pow2(31n)) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(U32{Word.shr.pad(31n, v)}), F.spec_numeric__unsigned(32n, Word.shr.pad(31n, v)), F.u32__to_nat_word(Word.shr.pad(31n, v))) : {Nat.is_lt(_, F.spec_common__pow2(31n)) == True{} : Bool}
  %Equal.sym(Nat, F.spec_numeric__unsigned(32n, Word.shr.pad(31n, v)), F.spec_numeric__unsigned(31n, v), F.u32__pad_value(31n, v)) : {Nat.is_lt(_, F.spec_common__pow2(31n)) == True{} : Bool}
  %Equal.sym(Nat, F.spec_common__pow2(31n), F.spec_numeric__scale_binary(31n, 1n), F.u32__pow2_scale(31n)) : {Nat.is_lt(F.spec_numeric__unsigned(31n, v), _) == True{} : Bool}
  F.lru_word_bounds__unsigned_bound(31n, v)

def pow2_succ(+k: Nat) -> {F.spec_common__pow2(1n+k) == Nat.double(F.spec_common__pow2(k)) : Nat}: {==}
# The word of n one bits, and its value: 1 + (2^n - 1) = 2^n, so the marker 4294967295 is 2^32 - 1 without a closed power.
def ones(+n: Nat) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+ +p: WCon{True{}, ones(p)}

def ones_val(+n: Nat) -> {Nat.add(1n, F.spec_numeric__unsigned(n, ones(n))) == F.spec_numeric__scale_binary(n, 1n) : Nat}:
  match n:
    case 0n: {==}
    case 1n+ +p:
      Equal.cong(Nat, Nat, z => Nat.double(z), Nat.add(1n, F.spec_numeric__unsigned(p, ones(p))), F.spec_numeric__scale_binary(p, 1n), ones_val(p))

def umax_succ() -> {Nat.add(1n, U32.to_nat(O.poison())) == F.spec_common__pow2(32n) : Nat}:
  %Equal.sym(U32, O.poison(), U32{ones(32n)}, {==}) : {Nat.add(1n, U32.to_nat(_)) == F.spec_common__pow2(32n) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32{ones(32n)}), F.spec_numeric__unsigned(32n, ones(32n)), F.u32__to_nat_word(ones(32n))) : {Nat.add(1n, _) == F.spec_common__pow2(32n) : Nat}
  %Equal.sym(Nat, F.spec_common__pow2(32n), F.spec_numeric__scale_binary(32n, 1n), F.u32__pow2_scale(32n)) : {Nat.add(1n, F.spec_numeric__unsigned(32n, ones(32n))) == _ : Nat}
  ones_val(32n)

def hp_lem(+a: U32, +b: U32, +ha: {Nat.is_lt(U32.to_nat(a), F.spec_common__pow2(31n)) == True{} : Bool}, +hb: {Nat.is_lt(U32.to_nat(b), F.spec_common__pow2(31n)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(1n+U32.to_nat(a), U32.to_nat(b)), F.spec_common__pow2(32n)) == True{} : Bool}:
  +P = F.spec_common__pow2(31n)
  F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(1n+U32.to_nat(a), U32.to_nat(b)), z) == True{} : Bool}, Nat.add(P, P), F.spec_common__pow2(32n),
    Equal.trans(Nat, Nat.add(P, P), Nat.double(P), F.spec_common__pow2(32n), Equal.sym(Nat, Nat.double(P), Nat.add(P, P), F.lru_nat_algebra__double_self(P)), Equal.sym(Nat, F.spec_common__pow2(32n), Nat.double(P), pow2_succ(31n))),
    F.nat__le_lt_trans(Nat.add(1n+U32.to_nat(a), U32.to_nat(b)), Nat.add(P, U32.to_nat(b)), Nat.add(P, P), Order.add_right(1n+U32.to_nat(a), P, U32.to_nat(b), F.nat__lt_succ_le_succ(U32.to_nat(a), P, ha)), F.nat__lt_add_left(U32.to_nat(b), P, P, hb)))
def sum_nw(+a: U32, +b: U32, +ha: {Nat.is_lt(U32.to_nat(a), F.spec_common__pow2(31n)) == True{} : Bool}, +hb: {Nat.is_lt(U32.to_nat(b), F.spec_common__pow2(31n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, b)) == Nat.add(U32.to_nat(b), U32.to_nat(a)) : Nat}:
  +hP = hp_lem(a, b, ha, hb)
  +step = F.logic__subst(Nat, z => {Nat.is_lt(z, Nat.add(1n+U32.to_nat(a), U32.to_nat(b))) == True{} : Bool}, Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(U32.to_nat(b), U32.to_nat(a)), F.nat__add_comm(U32.to_nat(a), U32.to_nat(b)), F.nat__lt_succ(Nat.add(U32.to_nat(a), U32.to_nat(b))))
  +h1 = F.nat__lt_trans(Nat.add(U32.to_nat(b), U32.to_nat(a)), Nat.add(1n+U32.to_nat(a), U32.to_nat(b)), F.spec_common__pow2(32n), step, hP)
  VB.add_lt32(a, b, U32.to_nat(a), {==}, h1)
def umax_succ2() -> {Nat.add(1n, U32.to_nat(O.poison())) == F.spec_common__pow2(32n) : Nat}:
  umax_succ()

def lt_pois(+a: U32, +b: U32, +ha: {Nat.is_lt(U32.to_nat(a), F.spec_common__pow2(31n)) == True{} : Bool}, +hb: {Nat.is_lt(U32.to_nat(b), F.spec_common__pow2(31n)) == True{} : Bool})
    -> {Nat.is_lt(U32.to_nat(U32.add(a, b)), U32.to_nat(O.poison())) == True{} : Bool}:
  +hP = hp_lem(a, b, ha, hb)
  +hU = F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(1n+U32.to_nat(a), U32.to_nat(b)), z) == True{} : Bool}, F.spec_common__pow2(32n), Nat.add(1n, U32.to_nat(O.poison())), Equal.sym(Nat, Nat.add(1n, U32.to_nat(O.poison())), F.spec_common__pow2(32n), umax_succ()), hP)
  +hU2 = F.nat__lt_succ_le(Nat.add(1n+U32.to_nat(a), U32.to_nat(b)), U32.to_nat(O.poison()), hU)
  F.logic__subst(Nat, z => {Nat.is_lt(z, U32.to_nat(O.poison())) == True{} : Bool}, Nat.add(U32.to_nat(a), U32.to_nat(b)), U32.to_nat(U32.add(a, b)), Equal.trans(Nat, Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(U32.add(a, b)), F.nat__add_comm(U32.to_nat(a), U32.to_nat(b)), Equal.sym(Nat, U32.to_nat(U32.add(a, b)), Nat.add(U32.to_nat(b), U32.to_nat(a)), sum_nw(a, b, ha, hb))), F.nat__succ_le_lt(Nat.add(U32.to_nat(a), U32.to_nat(b)), U32.to_nat(O.poison()), hU2))
def les_lem(+a: U32, +b: U32, +ha: {Nat.is_lt(U32.to_nat(a), F.spec_common__pow2(31n)) == True{} : Bool}, +hb: {Nat.is_lt(U32.to_nat(b), F.spec_common__pow2(31n)) == True{} : Bool})
    -> {U32.is_le(a, U32.add(a, b)) == True{} : Bool}:
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(U32.add(a, b))), U32.is_le(a, U32.add(a, b)),
    Equal.sym(Bool, U32.is_le(a, U32.add(a, b)), Nat.is_le(U32.to_nat(a), U32.to_nat(U32.add(a, b))), VU.le_u32(a, U32.add(a, b))),
    F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(a), z) == True{} : Bool}, Nat.add(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(U32.add(a, b)), Equal.sym(Nat, U32.to_nat(U32.add(a, b)), Nat.add(U32.to_nat(b), U32.to_nat(a)), sum_nw(a, b, ha, hb)), Order.left_below_sum(U32.to_nat(b), U32.to_nat(a))))

def lts_lem(+a: U32, +b: U32, +ha: {Nat.is_lt(U32.to_nat(a), F.spec_common__pow2(31n)) == True{} : Bool}, +hb: {Nat.is_lt(U32.to_nat(b), F.spec_common__pow2(31n)) == True{} : Bool})
    -> {U32.is_lt(U32.add(a, b), O.poison()) == True{} : Bool}:
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(U32.to_nat(U32.add(a, b)), U32.to_nat(O.poison())), U32.is_lt(U32.add(a, b), O.poison()),
    Equal.sym(Bool, U32.is_lt(U32.add(a, b), O.poison()), Nat.is_lt(U32.to_nat(U32.add(a, b)), U32.to_nat(O.poison())), F.u32__is_lt_nat(U32.add(a, b), O.poison())), lt_pois(a, b, ha, hb))
# O.padd (saturating at the marker 4294967295) adds when both addends are below 2^31: the sum is below the marker, does not wrap and is at least a.
def padd_ok(+a: U32, +b: U32, +av: Word(31n), +bv: Word(31n), +ea: {a == U32{Word.shr.pad(31n, av)} : U32}, +eb: {b == U32{Word.shr.pad(31n, bv)} : U32})
    -> {O.padd(a, b) == U32.add(a, b) : U32}:
  +ha = word31_lt(a, av, ea)
  +hb = word31_lt(b, bv, eb)
  %Equal.sym(Bool, Bool.and(U32.is_le(a, U32.add(a, b)), U32.is_lt(U32.add(a, b), O.poison())), True{}, F.logic__and_intro(U32.is_le(a, U32.add(a, b)), U32.is_lt(U32.add(a, b), O.poison()), les_lem(a, b, ha, hb), lts_lem(a, b, ha, hb))) : {O.pick(_, U32.add(a, b), O.poison()) == U32.add(a, b) : U32}
  {==}

# ---- O.padd of two lengths whose sum is at most NMAX is their sum (no 31-bit hypothesis) -------------------------

# NMAX < 31 + NMAX = UMAX, proved for a variable N (a statement that shares the closed NMAX on both sides is unfolded in unary).
def lt_gen(+N: Nat, +U: Nat, +e: {Nat.add(31n, N) == U : Nat}) -> {Nat.is_lt(N, U) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(N, z) == True{} : Bool}, Nat.add(31n, N), U, e,
    F.nat__lt_le_trans(N, Nat.add(1n, N), Nat.add(31n, N), F.nat__lt_succ(N), Order.add_right(1n, 31n, N, {==})))
def nmax_lt_umax() -> {Nat.is_lt(U32.to_nat(VB.NMAX()), U32.to_nat(VB.UMAX())) == True{} : Bool}:
  lt_gen(U32.to_nat(VB.NMAX()), U32.to_nat(VB.UMAX()), VB.e_umax())
def nmax_le_umax() -> {Nat.is_le(U32.to_nat(VB.NMAX()), U32.to_nat(VB.UMAX())) == True{} : Bool}:
  F.nat__lt_le(U32.to_nat(VB.NMAX()), U32.to_nat(VB.UMAX()), nmax_lt_umax())
def poison_umax() -> {O.poison() == VB.UMAX() : U32}: {==}
def padd_le(+a: U32, +b: U32, +h: {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), U32.to_nat(VB.NMAX())) == True{} : Bool})
    -> {O.padd(a, b) == U32.add(a, b) : U32}:
  +hc = F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(VB.NMAX())) == True{} : Bool}, Nat.add(U32.to_nat(a), U32.to_nat(b)), Nat.add(U32.to_nat(b), U32.to_nat(a)), F.nat__add_comm(U32.to_nat(a), U32.to_nat(b)), h)
  +e = VB.add_nw(a, b, U32.to_nat(a), {==}, F.nat__le_trans(Nat.add(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(VB.NMAX()), U32.to_nat(VB.UMAX()), hc, nmax_le_umax()))
  +hlt = F.nat__le_lt_trans(Nat.add(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(VB.NMAX()), U32.to_nat(VB.UMAX()), hc, nmax_lt_umax())
  +hl = F.logic__subst(Nat, z => {Nat.is_lt(z, U32.to_nat(VB.UMAX())) == True{} : Bool}, Nat.add(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(U32.add(a, b)), Equal.sym(Nat, U32.to_nat(U32.add(a, b)), Nat.add(U32.to_nat(b), U32.to_nat(a)), e), hlt)
  +hp = F.logic__subst(U32, z => {Nat.is_lt(U32.to_nat(U32.add(a, b)), U32.to_nat(z)) == True{} : Bool}, VB.UMAX(), O.poison(), Equal.sym(U32, O.poison(), VB.UMAX(), poison_umax()), hl)
  +hlts = F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(U32.to_nat(U32.add(a, b)), U32.to_nat(O.poison())), U32.is_lt(U32.add(a, b), O.poison()),
    Equal.sym(Bool, U32.is_lt(U32.add(a, b), O.poison()), Nat.is_lt(U32.to_nat(U32.add(a, b)), U32.to_nat(O.poison())), F.u32__is_lt_nat(U32.add(a, b), O.poison())), hp)
  +hles = F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(U32.add(a, b))), U32.is_le(a, U32.add(a, b)),
    Equal.sym(Bool, U32.is_le(a, U32.add(a, b)), Nat.is_le(U32.to_nat(a), U32.to_nat(U32.add(a, b))), VU.le_u32(a, U32.add(a, b))),
    F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(a), z) == True{} : Bool}, Nat.add(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(U32.add(a, b)), Equal.sym(Nat, U32.to_nat(U32.add(a, b)), Nat.add(U32.to_nat(b), U32.to_nat(a)), e), Order.left_below_sum(U32.to_nat(b), U32.to_nat(a))))
  %Equal.sym(Bool, Bool.and(U32.is_le(a, U32.add(a, b)), U32.is_lt(U32.add(a, b), O.poison())), True{}, F.logic__and_intro(U32.is_le(a, U32.add(a, b)), U32.is_lt(U32.add(a, b), O.poison()), hles, hlts)) : {O.pick(_, U32.add(a, b), O.poison()) == U32.add(a, b) : U32}
  {==}

# A length at most NMAX is not poisoned (the size pass's marker and every size past NMAX are).
def np_nmax(+x: U32, +h: {Nat.is_le(U32.to_nat(x), U32.to_nat(VB.NMAX())) == True{} : Bool}) -> {O.is_poisoned(x) == False{} : Bool}:
  F.logic__subst(Bool, z => {z == False{} : Bool}, Nat.is_lt(U32.to_nat(VB.NMAX()), U32.to_nat(x)), O.is_poisoned(x),
    Equal.sym(Bool, O.is_poisoned(x), Nat.is_lt(U32.to_nat(VB.NMAX()), U32.to_nat(x)), F.u32__is_lt_nat(VB.NMAX(), x)),
    F.nat__le_not_lt(U32.to_nat(VB.NMAX()), U32.to_nat(x), h))

# A value below 2^k (k <= 31) is not poisoned.
def np31(+x: U32, +k: Nat, +hk: {Nat.is_le(k, 31n) == True{} : Bool}, +h: {Nat.is_lt(U32.to_nat(x), F.spec_common__pow2(k)) == True{} : Bool}) -> {O.is_poisoned(x) == False{} : Bool}:
  np_nmax(x, VB.le_pw31_nmax(U32.to_nat(x), F.nat__lt_le_trans(U32.to_nat(x), F.spec_common__pow2(k), F.spec_common__pow2(31n), h, F.nat__pow2_mono(k, 31n, hk))))
# x < 31 + x (31 + x within 2^k bounds x by 2^k).
def lt_31x(+x: Nat) -> {Nat.is_lt(x, Nat.add(31n, x)) == True{} : Bool}:
  F.nat__lt_le_trans(x, Nat.add(1n, x), Nat.add(31n, x), F.nat__lt_succ(x), Order.add_right(1n, 31n, x, {==}))

# Not poisoned from the word-count window's bound 31 + x <= 2^k (k <= 31).
def np31y(+x: U32, +k: Nat, +hk: {Nat.is_le(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(Nat.add(31n, U32.to_nat(x)), F.spec_common__pow2(k)) == True{} : Bool}) -> {O.is_poisoned(x) == False{} : Bool}:
  np31(x, k, hk, F.nat__lt_le_trans(U32.to_nat(x), Nat.add(31n, U32.to_nat(x)), F.spec_common__pow2(k), lt_31x(U32.to_nat(x)), hy))

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
  F.array__get_go(U32, d, t, m, x, hd, hm, hx, U32.is_lt(m, U32.shr(F.u32__pow2u(d))), {==}, pf)

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

# ---- the checked product O.mulc (n * es unless it exceeds NMAX, else the marker) ----------------------------------

def mm_le(+a: Nat, +b: Nat, +c: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(Nat.mul(a, c), Nat.mul(b, c)) == True{} : Bool}:
  match a b:
    case 0n _: F.nat__zero_le(Nat.mul(b, c))
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(Nat.mul(1n+p, c), Nat.mul(0n, c)) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: F.nat__le_add_left(Nat.mul(p, c), Nat.mul(q, c), c, mm_le(p, q, c, h))

def le_cancel(+c: Nat, +a: Nat, +b: Nat, +h: {Nat.is_le(Nat.add(c, a), Nat.add(c, b)) == True{} : Bool}) -> {Nat.is_le(a, b) == True{} : Bool}:
  match c:
    case 0n: h
    case 1n+ +p: le_cancel(p, a, b, h)

# n * es <= NMAX gives n <= NMAX / es (the quotient and remainder of NMAX / es as div_u32 states them).
def le_div_go(+n: U32, +es: U32, +c: Bool, +ec: {Nat.is_le(U32.to_nat(n), U32.to_nat(U32.div(VB.NMAX(), es))) == c : Bool},
    +ed: {Nat.add(Nat.mul(U32.to_nat(U32.div(VB.NMAX(), es)), U32.to_nat(es)), U32.to_nat(U32.mod(VB.NMAX(), es))) == U32.to_nat(VB.NMAX()) : Nat},
    +er: {Nat.is_lt(U32.to_nat(U32.mod(VB.NMAX(), es)), U32.to_nat(es)) == True{} : Bool},
    +h: {Nat.is_le(Nat.mul(U32.to_nat(n), U32.to_nat(es)), U32.to_nat(VB.NMAX())) == True{} : Bool})
    -> {U32.is_le(n, U32.div(VB.NMAX(), es)) == True{} : Bool}:
  match c:
    case True{}:
      F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(n), U32.to_nat(U32.div(VB.NMAX(), es))), U32.is_le(n, U32.div(VB.NMAX(), es)),
        Equal.sym(Bool, U32.is_le(n, U32.div(VB.NMAX(), es)), Nat.is_le(U32.to_nat(n), U32.to_nat(U32.div(VB.NMAX(), es))), VB.le_u32n(n, U32.div(VB.NMAX(), es))), ec)
    case False{}:
      +Q = U32.to_nat(U32.div(VB.NMAX(), es))
      +R = U32.to_nat(U32.mod(VB.NMAX(), es))
      +E = U32.to_nat(es)
      +h1 = F.nat__lt_succ_le_succ(Q, U32.to_nat(n), F.nat__not_le_lt(U32.to_nat(n), Q, ec))
      +h2 = F.nat__le_trans(Nat.add(E, Nat.mul(Q, E)), Nat.mul(U32.to_nat(n), E), U32.to_nat(VB.NMAX()), mm_le(1n+Q, U32.to_nat(n), E, h1), h)
      +h4 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(E, Nat.mul(Q, E)), z) == True{} : Bool}, U32.to_nat(VB.NMAX()), Nat.add(Nat.mul(Q, E), R), Equal.sym(Nat, Nat.add(Nat.mul(Q, E), R), U32.to_nat(VB.NMAX()), ed), h2)
      +h5 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(Nat.mul(Q, E), R)) == True{} : Bool}, Nat.add(E, Nat.mul(Q, E)), Nat.add(Nat.mul(Q, E), E), F.nat__add_comm(E, Nat.mul(Q, E)), h4)
      +h6 = le_cancel(Nat.mul(Q, E), E, R, h5)
      Empty.absurd({U32.is_le(n, U32.div(VB.NMAX(), es)) == True{} : Bool}, F.nat__lt_ne(R, R, F.nat__lt_le_trans(R, E, R, er, h6), {==}))

def le_div_pair(+n: U32, +es: U32,
    p: {Nat.add(Nat.mul(U32.to_nat(U32.div(VB.NMAX(), es)), U32.to_nat(es)), U32.to_nat(U32.mod(VB.NMAX(), es))) == U32.to_nat(VB.NMAX()) : Nat} & {Nat.is_lt(U32.to_nat(U32.mod(VB.NMAX(), es)), U32.to_nat(es)) == True{} : Bool},
    +h: {Nat.is_le(Nat.mul(U32.to_nat(n), U32.to_nat(es)), U32.to_nat(VB.NMAX())) == True{} : Bool})
    -> {U32.is_le(n, U32.div(VB.NMAX(), es)) == True{} : Bool}:
  (+ed, +er) = p
  le_div_go(n, es, Nat.is_le(U32.to_nat(n), U32.to_nat(U32.div(VB.NMAX(), es))), {==}, ed, er, h)

def le_div(+n: U32, +es: U32, +v: Word(31n), +eb: {es == U32{Word.shr.pad(31n, v)} : U32}, +hes: {Nat.is_le(1n, U32.to_nat(es)) == True{} : Bool}, +hz: {U32.is_zero(es) == False{} : Bool},
    +h: {Nat.is_le(Nat.mul(U32.to_nat(n), U32.to_nat(es)), U32.to_nat(VB.NMAX())) == True{} : Bool})
    -> {U32.is_le(n, U32.div(VB.NMAX(), es)) == True{} : Bool}:
  le_div_pair(n, es, VU.div_u32(VB.NMAX(), es, v, eb, hes, hz), h)

# the checked product is the product when it is at most NMAX.
def mulc_eq(+n: U32, +es: U32, +hK: {U32.is_le(n, U32.div(VB.NMAX(), es)) == True{} : Bool}) -> {O.mulc(n, es) == U32.mul(n, es) : U32}:
  %Equal.sym(Bool, U32.is_le(n, U32.div(VB.NMAX(), es)), True{}, hK) : {O.pick(_, U32.mul(n, es), O.poison()) == U32.mul(n, es) : U32}
  {==}

def mulc_nat(+n: U32, +es: U32, +v: Word(31n), +eb: {es == U32{Word.shr.pad(31n, v)} : U32}, +hes: {Nat.is_le(1n, U32.to_nat(es)) == True{} : Bool}, +hz: {U32.is_zero(es) == False{} : Bool},
    +h: {Nat.is_le(Nat.mul(U32.to_nat(n), U32.to_nat(es)), U32.to_nat(VB.NMAX())) == True{} : Bool})
    -> {U32.to_nat(O.mulc(n, es)) == Nat.mul(U32.to_nat(n), U32.to_nat(es)) : Nat}:
  %Equal.sym(U32, O.mulc(n, es), U32.mul(n, es), mulc_eq(n, es, le_div(n, es, v, eb, hes, hz, h))) : {U32.to_nat(_) == Nat.mul(U32.to_nat(n), U32.to_nat(es)) : Nat}
  VU.mul_le(n, es, VB.NMAX(), h)

# n <= a literal limit lim with lim <= NMAX / es: the checked product is the product.
def mulc_lim(+n: U32, +es: U32, +lim: U32, +hn: {U32.is_le(n, lim) == True{} : Bool}, +hlk: {U32.is_le(lim, U32.div(VB.NMAX(), es)) == True{} : Bool}) -> {O.mulc(n, es) == U32.mul(n, es) : U32}:
  mulc_eq(n, es, VB.u32le_trans(n, lim, U32.div(VB.NMAX(), es), hn, hlk))

def mulc_limn(+n: U32, +es: U32, +lim: U32, +hn: {Nat.is_le(U32.to_nat(n), U32.to_nat(lim)) == True{} : Bool}, +hlk: {U32.is_le(lim, U32.div(VB.NMAX(), es)) == True{} : Bool}) -> {O.mulc(n, es) == U32.mul(n, es) : U32}:
  mulc_lim(n, es, lim, F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(n), U32.to_nat(lim)), U32.is_le(n, lim), Equal.sym(Bool, U32.is_le(n, lim), Nat.is_le(U32.to_nat(n), U32.to_nat(lim)), VB.le_u32n(n, lim)), hn), hlk)

# mulc_nat for a small element size es < 2^k (k <= 31): the 31-bit word of es is built here.
def mulc_nat_k(+n: U32, +es: U32, +k: Nat, +hk: {Nat.is_le(k, 31n) == True{} : Bool}, +hlt: {Nat.is_lt(U32.to_nat(es), F.spec_common__pow2(k)) == True{} : Bool},
    +hes: {Nat.is_le(1n, U32.to_nat(es)) == True{} : Bool}, +hz: {U32.is_zero(es) == False{} : Bool},
    +h: {Nat.is_le(Nat.mul(U32.to_nat(n), U32.to_nat(es)), U32.to_nat(VB.NMAX())) == True{} : Bool})
    -> {U32.to_nat(O.mulc(n, es)) == Nat.mul(U32.to_nat(n), U32.to_nat(es)) : Nat}:
  mulc_nat(n, es, winit(31n, bits32(es)), small_pad(es, k, hk, hlt), hes, hz, h)
