import Base
import ../../src/buffer.bend as B
import ../compact/found.bend as F
import ../compact/arith.bend as AR
import ./mtree_defs.bend as MD
import ./words_spec.bend as WS
import ./len_bridge.bend as LB

# The native driver's input path (native_bench/driver.bend `read_loop`) fills
# the buffer in pieces of 65536 bytes at offsets 0, 65536, ... - one
# `B.fill_at(buf, offset, piece)` per piece - while the decode laws are stated
# for one whole fill at offset 0 (proofs/obj/load.bend). Here: filling a piece
# whose length is a multiple of 4 and then the rest at the next word is filling
# the concatenation (fill_two), and the driver's next offset is exactly that
# next word (next_off); by induction the pieces fill as the whole list
# (fill_pieces).

# ---- word groups ------------------------------------------------------------------

# The list is whole words (its length is a multiple of 4).
def al(xs: +List<U32>) -> Bool:
  match xs:
    case Con{a, Con{b, Con{c, Con{d, rest}}}}: al(rest)
    case Con{a, Con{b, Con{c, Nil{}}}}: False{}
    case Con{a, Con{b, Nil{}}}: False{}
    case Con{a, Nil{}}: False{}
    case Nil{}: True{}

# The word index after filling xs from word i.
def adv(xs: +List<U32>, +i: U32) -> U32:
  match xs:
    case Con{a, Con{b, Con{c, Con{d, rest}}}}: adv(rest, (i + 1 : U32))
    case Con{a, Con{b, Con{c, Nil{}}}}: i
    case Con{a, Con{b, Nil{}}}: i
    case Con{a, Nil{}}: i
    case Nil{}: i

# The number of whole words.
def nq(xs: +List<U32>) -> Nat:
  match xs:
    case Con{a, Con{b, Con{c, Con{d, rest}}}}: 1n+nq(rest)
    case Con{a, Con{b, Con{c, Nil{}}}}: 0n
    case Con{a, Con{b, Nil{}}}: 0n
    case Con{a, Nil{}}: 0n
    case Nil{}: 0n

law fill_app:
  for +xs: +List<U32>
  for +ys: +List<U32>
  for -ws: Array<U32>
  for +i: U32
  for +e: {al(xs) == True{} : Bool}
  {B.fill_go(List.append(&2, U32, xs, ys), ws, i) == B.fill_go(ys, B.fill_go(xs, ws, i), adv(xs, i)) : Array<U32>}
def fill_app(xs, ys, ws, i, e):
  match xs:
    case Con{+a, Con{+b, Con{+c, Con{+d, +rest}}}}:
      fill_app(rest, ys, Array.set(U32, ws, i, B.word_of(a, b, c, d)), (i + 1 : U32), e)
    case Con{+a, Con{+b, Con{+c, Nil{}}}}: Empty.absurd({B.fill_go(List.append(&2, U32, [a, b, c], ys), ws, i) == B.fill_go(ys, B.fill_go([a, b, c], ws, i), adv([a, b, c], i)) : Array<U32>}, MD.false_true(e))
    case Con{+a, Con{+b, Nil{}}}: Empty.absurd({B.fill_go(List.append(&2, U32, [a, b], ys), ws, i) == B.fill_go(ys, B.fill_go([a, b], ws, i), adv([a, b], i)) : Array<U32>}, MD.false_true(e))
    case Con{+a, Nil{}}: Empty.absurd({B.fill_go(List.append(&2, U32, [a], ys), ws, i) == B.fill_go(ys, B.fill_go([a], ws, i), adv([a], i)) : Array<U32>}, MD.false_true(e))
    case Nil{}: {==}

# Filling xs (whole words) at `off` and then ys at the word after it is filling
# their concatenation at `off`.
law fill_two:
  for -ws: Array<U32>
  for +n: U32
  for +off: U32
  for +off2: U32
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +e: {al(xs) == True{} : Bool}
  for +ei: {U32.shrn(off2, 2n) == adv(xs, U32.shrn(off, 2n)) : U32}
  {B.fill_at(B.fill_at(B.Buf{ws, n}, off, xs), off2, ys) == B.fill_at(B.Buf{ws, n}, off, List.append(&2, U32, xs, ys)) : B.Buf}
def fill_two(ws, n, off, off2, xs, ys, e, ei):
  %Equal.sym(U32, U32.shrn(off2, 2n), adv(xs, U32.shrn(off, 2n)), ei) : {B.Buf{B.fill_go(ys, B.fill_go(xs, ws, U32.shrn(off, 2n)), _), n} == B.fill_at(B.Buf{ws, n}, off, List.append(&2, U32, xs, ys)) : B.Buf}
  %Equal.sym(Array<U32>, B.fill_go(List.append(&2, U32, xs, ys), ws, U32.shrn(off, 2n)), B.fill_go(ys, B.fill_go(xs, ws, U32.shrn(off, 2n)), adv(xs, U32.shrn(off, 2n))), fill_app(xs, ys, ws, U32.shrn(off, 2n), e)) :
    {B.Buf{B.fill_go(ys, B.fill_go(xs, ws, U32.shrn(off, 2n)), adv(xs, U32.shrn(off, 2n))), n} == B.Buf{_, n} : B.Buf}
  {==}

# ---- the word index -------------------------------------------------------------------

def ne0(+k: Nat, +e: {0n == 1n+k : Nat}) -> Empty:
  MD.false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(Nat, Bool, x => Nat.is_eq(x, 0n), 0n, 1n+k, e)))

def pred1(x: Nat) -> Nat:
  match x:
    case 0n: 0n
    case 1n+p: p

def pred2(x: Nat) -> Nat:
  match x:
    case 0n: 0n
    case 1n+p: pred1(p)

def peel2(+a: Nat, +b: Nat, +e: {2n+a == 2n+b : Nat}) -> {a == b : Nat}:
  Equal.cong(Nat, Nat, pred2, 2n+a, 2n+b, e)

law dbl_inj:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.double(a) == Nat.double(b) : Nat}
  {a == b : Nat}
def dbl_inj(a, b, e):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: Empty.absurd({0n == 1n+q : Nat}, ne0(1n+Nat.double(q), e))
    case 1n+p 0n: Empty.absurd({1n+p == 0n : Nat}, ne0(1n+Nat.double(p), Equal.sym(Nat, 2n+Nat.double(p), 0n, e)))
    case 1n+ +p 1n+ +q:
      %Equal.sym(Nat, p, q, dbl_inj(p, q, peel2(Nat.double(p), Nat.double(q), e))) : {1n+_ == 1n+q : Nat}
      {==}

law odd_even:
  for +z: Nat
  for +y: Nat
  for +e: {1n+Nat.double(z) == Nat.double(y) : Nat}
  Empty
def odd_even(z, y, e):
  match z y:
    case _ 0n: ne0(Nat.double(z), Equal.sym(Nat, 1n+Nat.double(z), 0n, e))
    case 0n 1n+q: ne0(Nat.double(q), Equal.cong(Nat, Nat, pred1, 1n, 2n+Nat.double(q), e))
    case 1n+ +p 1n+ +q: odd_even(p, q, peel2(1n+Nat.double(p), Nat.double(q), e))

def le1(+k: Nat) -> {Nat.is_le(1n, 1n+k) == True{} : Bool}: F.nat__le_add_right(0n, k)

def rw_le(+a: Nat, +b: Nat, +c: Nat, +e: {a == b : Nat}, +h: {Nat.is_le(a, c) == True{} : Bool}) -> {Nat.is_le(b, c) == True{} : Bool}:
  %e : {Nat.is_le(_, c) == True{} : Bool}
  h

def step_eq(+i: U32, +rest: +List<U32>, +inc: {U32.to_nat((i + 1 : U32)) == Nat.add(U32.to_nat(i), U32.to_nat(1)) : Nat})
    -> {Nat.add(U32.to_nat((i + 1 : U32)), nq(rest)) == Nat.add(U32.to_nat(i), 1n+nq(rest)) : Nat}:
  %Equal.sym(Nat, U32.to_nat((i + 1 : U32)), Nat.add(U32.to_nat(i), U32.to_nat(1)), inc) : {Nat.add(_, nq(rest)) == Nat.add(U32.to_nat(i), 1n+nq(rest)) : Nat}
  F.nat__add_assoc(U32.to_nat(i), 1n, nq(rest))

def half_bit(+b: Bool, +z: Nat, +y: Nat, +e: {Nat.add(F.spec_numeric__bit_value(b), Nat.double(z)) == Nat.double(y) : Nat}) -> {z == y : Nat}:
  match b:
    case False{}: dbl_inj(z, y, e)
    case True{}: Empty.absurd({z == y : Nat}, odd_even(z, y, e))

# A word whose value is 2y shifts right to y.
def half(+x: U32, +y: Nat, +e: {U32.to_nat(x) == Nat.double(y) : Nat}) -> {U32.to_nat(U32.shr(x)) == y : Nat}:
  +sp = Equal.trans(Nat, Nat.add(F.spec_numeric__bit_value(F.u32__low_bit(x)), Nat.double(U32.to_nat(U32.shr(x)))), U32.to_nat(x), Nat.double(y), Equal.sym(Nat, U32.to_nat(x), Nat.add(F.spec_numeric__bit_value(F.u32__low_bit(x)), Nat.double(U32.to_nat(U32.shr(x)))), F.u32__shr_split(x)), e)
  half_bit(F.u32__low_bit(x), U32.to_nat(U32.shr(x)), y, sp)

def quarter(+x: U32, +y: Nat, +e: {U32.to_nat(x) == Nat.double(Nat.double(y)) : Nat}) -> {U32.to_nat(U32.shrn(x, 2n)) == y : Nat}:
  half(U32.shr(x), y, half(x, Nat.double(y), e))

law adv_nat:
  for +xs: +List<U32>
  for +i: U32
  for +c: U32
  for +e: {al(xs) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(U32.to_nat(i), nq(xs)), U32.to_nat(c)) == True{} : Bool}
  {U32.to_nat(adv(xs, i)) == Nat.add(U32.to_nat(i), nq(xs)) : Nat}
def adv_nat(xs, i, c, e, h):
  match xs:
    case Con{+a, Con{+b, Con{+c1, Con{+d, +rest}}}}:
      +h1 = F.nat__le_trans(Nat.add(U32.to_nat(i), 1n), Nat.add(U32.to_nat(i), 1n+nq(rest)), U32.to_nat(c), F.nat__le_add_left(1n, 1n+nq(rest), U32.to_nat(i), le1(nq(rest))), h)
      +inc = AR.add_le(i, 1, c, h1)
      +h2 = rw_le(Nat.add(U32.to_nat(i), 1n+nq(rest)), Nat.add(U32.to_nat((i + 1 : U32)), nq(rest)), U32.to_nat(c), Equal.sym(Nat, Nat.add(U32.to_nat((i + 1 : U32)), nq(rest)), Nat.add(U32.to_nat(i), 1n+nq(rest)), step_eq(i, rest, inc)), h)
      Equal.trans(Nat, U32.to_nat(adv(rest, (i + 1 : U32))), Nat.add(U32.to_nat((i + 1 : U32)), nq(rest)), Nat.add(U32.to_nat(i), 1n+nq(rest)), adv_nat(rest, (i + 1 : U32), c, e, h2), step_eq(i, rest, inc))
    case Con{+a, Con{+b, Con{+c1, Nil{}}}}: Empty.absurd({U32.to_nat(adv([a, b, c1], i)) == Nat.add(U32.to_nat(i), nq([a, b, c1])) : Nat}, MD.false_true(e))
    case Con{+a, Con{+b, Nil{}}}: Empty.absurd({U32.to_nat(adv([a, b], i)) == Nat.add(U32.to_nat(i), nq([a, b])) : Nat}, MD.false_true(e))
    case Con{+a, Nil{}}: Empty.absurd({U32.to_nat(adv([a], i)) == Nat.add(U32.to_nat(i), nq([a])) : Nat}, MD.false_true(e))
    case Nil{}: Equal.sym(Nat, Nat.add(U32.to_nat(i), 0n), U32.to_nat(i), F.nat__add_zero(U32.to_nat(i)))

# ---- the driver's pieces -----------------------------------------------------------
# The piece size is a word P = 4Q (the driver's 65536 = 4 * 16384); it stays a
# variable in the laws below and its value is one Bool fact evaluated at the
# use site (a closed number past 2^15 must not be compared digit by digit).

def quad(+y: Nat) -> Nat: Nat.double(Nat.double(y))

law quad_add:
  for +a: Nat
  for +b: Nat
  {quad(Nat.add(a, b)) == Nat.add(quad(a), quad(b)) : Nat}
def quad_add(a, b):
  %Equal.sym(Nat, Nat.double(Nat.add(a, b)), Nat.add(Nat.double(a), Nat.double(b)), LB.double_add(a, b)) : {Nat.double(_) == Nat.add(quad(a), quad(b)) : Nat}
  LB.double_add(Nat.double(a), Nat.double(b))

law le_quad:
  for +y: Nat
  {Nat.is_le(y, quad(y)) == True{} : Bool}
def le_quad(y):
  match y:
    case 0n: {==}
    case 1n+ +p: F.nat__le_trans(p, quad(p), 3n+quad(p), le_quad(p), AR.le_skip(3n, quad(p)))

law app_nil:
  for +xs: +List<U32>
  {List.append(&2, U32, xs, []) == xs : +List<U32>}
def app_nil(xs):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(+List<U32>, List.append(&2, U32, t, []), t, app_nil(t)) : {h <> _ == h <> t : +List<U32>}
      {==}

# A list of whole words is 4 bytes per word.
law len_quad:
  for +xs: +List<U32>
  for +e: {al(xs) == True{} : Bool}
  {List.length(&2, U32, xs) == quad(nq(xs)) : Nat}
def len_quad(xs, e):
  match xs:
    case Con{+a, Con{+b, Con{+c, Con{+d, +rest}}}}:
      %Equal.sym(Nat, List.length(&2, U32, rest), quad(nq(rest)), len_quad(rest, e)) : {4n+_ == 4n+quad(nq(rest)) : Nat}
      {==}
    case Con{+a, Con{+b, Con{+c, Nil{}}}}: Empty.absurd({List.length(&2, U32, [a, b, c]) == quad(nq([a, b, c])) : Nat}, MD.false_true(e))
    case Con{+a, Con{+b, Nil{}}}: Empty.absurd({List.length(&2, U32, [a, b]) == quad(nq([a, b])) : Nat}, MD.false_true(e))
    case Con{+a, Nil{}}: Empty.absurd({List.length(&2, U32, [a]) == quad(nq([a])) : Nat}, MD.false_true(e))
    case Nil{}: {==}

def qs(+off: U32, +y: Nat, +P: U32, +Q: Nat, +ey: {U32.to_nat(off) == quad(y) : Nat}, +eP: {U32.to_nat(P) == quad(Q) : Nat})
    -> {Nat.add(U32.to_nat(off), U32.to_nat(P)) == quad(Nat.add(y, Q)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(off), quad(y), ey) : {Nat.add(_, U32.to_nat(P)) == quad(Nat.add(y, Q)) : Nat}
  %Equal.sym(Nat, U32.to_nat(P), quad(Q), eP) : {Nat.add(quad(y), _) == quad(Nat.add(y, Q)) : Nat}
  Equal.sym(Nat, quad(Nat.add(y, Q)), Nat.add(quad(y), quad(Q)), quad_add(y, Q))

def ba_of(+off: U32, +y: Nat, +P: U32, +Q: Nat, +p: +List<U32>, +c: U32,
    +sy: {U32.to_nat(U32.shrn(off, 2n)) == y : Nat}, +ep: {nq(p) == Q : Nat},
    +q2: {Nat.add(U32.to_nat(off), U32.to_nat(P)) == quad(Nat.add(y, Q)) : Nat},
    +hb: {Nat.is_le(Nat.add(U32.to_nat(off), U32.to_nat(P)), U32.to_nat(c)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(U32.shrn(off, 2n)), nq(p)), U32.to_nat(c)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(U32.shrn(off, 2n)), y, sy) : {Nat.is_le(Nat.add(_, nq(p)), U32.to_nat(c)) == True{} : Bool}
  %Equal.sym(Nat, nq(p), Q, ep) : {Nat.is_le(Nat.add(y, _), U32.to_nat(c)) == True{} : Bool}
  F.nat__le_trans(Nat.add(y, Q), quad(Nat.add(y, Q)), U32.to_nat(c), le_quad(Nat.add(y, Q)),
    rw_le(Nat.add(U32.to_nat(off), U32.to_nat(P)), quad(Nat.add(y, Q)), U32.to_nat(c), q2, hb))

def av_of(+off: U32, +y: Nat, +Q: Nat, +p: +List<U32>,
    +sy: {U32.to_nat(U32.shrn(off, 2n)) == y : Nat}, +ep: {nq(p) == Q : Nat},
    +av: {U32.to_nat(adv(p, U32.shrn(off, 2n))) == Nat.add(U32.to_nat(U32.shrn(off, 2n)), nq(p)) : Nat})
    -> {U32.to_nat(adv(p, U32.shrn(off, 2n))) == Nat.add(y, Q) : Nat}:
  %sy : {U32.to_nat(adv(p, U32.shrn(off, 2n))) == Nat.add(_, Q) : Nat}
  %ep : {U32.to_nat(adv(p, U32.shrn(off, 2n))) == Nat.add(U32.to_nat(U32.shrn(off, 2n)), _) : Nat}
  av

# The offset after a whole piece of P bytes is the word after the piece.
def next_off(+off: U32, +y: Nat, +P: U32, +Q: Nat, +p: +List<U32>, +c: U32,
    +ey: {U32.to_nat(off) == quad(y) : Nat},
    +eP: {U32.to_nat(P) == quad(Q) : Nat},
    +e: {al(p) == True{} : Bool},
    +ep: {nq(p) == Q : Nat},
    +hb: {Nat.is_le(Nat.add(U32.to_nat(off), U32.to_nat(P)), U32.to_nat(c)) == True{} : Bool})
    -> {U32.shrn((off + P : U32), 2n) == adv(p, U32.shrn(off, 2n)) : U32}:
  +sy = quarter(off, y, ey)
  +q2 = qs(off, y, P, Q, ey, eP)
  +s2 = Equal.trans(Nat, U32.to_nat((off + P : U32)), Nat.add(U32.to_nat(off), U32.to_nat(P)), quad(Nat.add(y, Q)), AR.add_le(off, P, c, hb), q2)
  +sy2 = quarter((off + P : U32), Nat.add(y, Q), s2)
  +av = adv_nat(p, U32.shrn(off, 2n), c, e, ba_of(off, y, P, Q, p, c, sy, ep, q2, hb))
  F.u32__injective(U32.shrn((off + P : U32), 2n), adv(p, U32.shrn(off, 2n)),
    Equal.trans(Nat, U32.to_nat(U32.shrn((off + P : U32), 2n)), Nat.add(y, Q), U32.to_nat(adv(p, U32.shrn(off, 2n))), sy2,
      Equal.sym(Nat, U32.to_nat(adv(p, U32.shrn(off, 2n))), Nat.add(y, Q), av_of(off, y, Q, p, sy, ep, av))))

# The driver's loop, without the file reads: piece k is filled at offset k * P.
def fillp(ps: List<&2, +List<U32>>, b: B.Buf, +off: U32, +P: U32) -> B.Buf:
  match ps:
    case Nil{}: b
    case Con{+p, rest}: fillp(rest, B.fill_at(b, off, p), (off + P : U32), P)

def cat(ps: List<&2, +List<U32>>) -> +List<U32>:
  match ps:
    case Nil{}: []
    case Con{+p, rest}: List.append(&2, U32, p, cat(rest))

# Every piece but the last is Q whole words.
def good(ps: List<&2, +List<U32>>, +Q: Nat) -> Bool:
  match ps:
    case Nil{}: True{}
    case Con{+p, rest}:
      match rest:
        case Nil{}: True{}
        case Con{q, r}: Bool.and(al(p), Bool.and(Nat.is_eq(nq(p), Q), good(Con{q, r}, Q)))

law len_app:
  for +xs: +List<U32>
  for +ys: +List<U32>
  {List.length(&2, U32, List.append(&2, U32, xs, ys)) == Nat.add(List.length(&2, U32, xs), List.length(&2, U32, ys)) : Nat}
def len_app(xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, t, ys)), Nat.add(List.length(&2, U32, t), List.length(&2, U32, ys)), len_app(t, ys)) : {1n+_ == 1n+Nat.add(List.length(&2, U32, t), List.length(&2, U32, ys)) : Nat}
      {==}

def len_p(+p: +List<U32>, +P: U32, +Q: Nat, +e: {al(p) == True{} : Bool}, +ep: {nq(p) == Q : Nat}, +eP: {U32.to_nat(P) == quad(Q) : Nat})
    -> {List.length(&2, U32, p) == U32.to_nat(P) : Nat}:
  %Equal.sym(Nat, U32.to_nat(P), quad(Q), eP) : {List.length(&2, U32, p) == _ : Nat}
  %ep : {List.length(&2, U32, p) == quad(_) : Nat}
  len_quad(p, e)

# The first piece's bound, from the whole bound.
def hb_first(+off: U32, +P: U32, +p: +List<U32>, +rest: +List<U32>, +c: U32,
    +lp: {List.length(&2, U32, p) == U32.to_nat(P) : Nat},
    +hb: {Nat.is_le(Nat.add(U32.to_nat(off), List.length(&2, U32, List.append(&2, U32, p, rest))), U32.to_nat(c)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(off), U32.to_nat(P)), U32.to_nat(c)) == True{} : Bool}:
  +h1 = rw_le(Nat.add(U32.to_nat(off), List.length(&2, U32, List.append(&2, U32, p, rest))), Nat.add(U32.to_nat(off), Nat.add(List.length(&2, U32, p), List.length(&2, U32, rest))), U32.to_nat(c),
    Equal.cong(Nat, Nat, x => Nat.add(U32.to_nat(off), x), List.length(&2, U32, List.append(&2, U32, p, rest)), Nat.add(List.length(&2, U32, p), List.length(&2, U32, rest)), len_app(p, rest)), hb)
  +h2 = F.nat__le_trans(Nat.add(U32.to_nat(off), List.length(&2, U32, p)), Nat.add(U32.to_nat(off), Nat.add(List.length(&2, U32, p), List.length(&2, U32, rest))), U32.to_nat(c),
    F.nat__le_add_left(List.length(&2, U32, p), Nat.add(List.length(&2, U32, p), List.length(&2, U32, rest)), U32.to_nat(off), F.nat__le_add_right(List.length(&2, U32, p), List.length(&2, U32, rest))), h1)
  rw_le(Nat.add(U32.to_nat(off), List.length(&2, U32, p)), Nat.add(U32.to_nat(off), U32.to_nat(P)), U32.to_nat(c), Equal.cong(Nat, Nat, x => Nat.add(U32.to_nat(off), x), List.length(&2, U32, p), U32.to_nat(P), lp), h2)

# The rest's bound at the next offset.
def hb_rest(+off: U32, +P: U32, +p: +List<U32>, +rest: +List<U32>, +c: U32,
    +lp: {List.length(&2, U32, p) == U32.to_nat(P) : Nat},
    +np: {U32.to_nat((off + P : U32)) == Nat.add(U32.to_nat(off), U32.to_nat(P)) : Nat},
    +hb: {Nat.is_le(Nat.add(U32.to_nat(off), List.length(&2, U32, List.append(&2, U32, p, rest))), U32.to_nat(c)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat((off + P : U32)), List.length(&2, U32, rest)), U32.to_nat(c)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat((off + P : U32)), Nat.add(U32.to_nat(off), U32.to_nat(P)), np) : {Nat.is_le(Nat.add(_, List.length(&2, U32, rest)), U32.to_nat(c)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(off), U32.to_nat(P)), List.length(&2, U32, rest)), Nat.add(U32.to_nat(off), Nat.add(U32.to_nat(P), List.length(&2, U32, rest))), F.nat__add_assoc(U32.to_nat(off), U32.to_nat(P), List.length(&2, U32, rest))) : {Nat.is_le(_, U32.to_nat(c)) == True{} : Bool}
  %lp : {Nat.is_le(Nat.add(U32.to_nat(off), Nat.add(_, List.length(&2, U32, rest))), U32.to_nat(c)) == True{} : Bool}
  %len_app(p, rest) : {Nat.is_le(Nat.add(U32.to_nat(off), _), U32.to_nat(c)) == True{} : Bool}
  hb

law fill_pieces:
  for +ps: List<&2, +List<U32>>
  for -ws: Array<U32>
  for +n: U32
  for +off: U32
  for +y: Nat
  for +P: U32
  for +Q: Nat
  for +c: U32
  for +ey: {U32.to_nat(off) == quad(y) : Nat}
  for +eP: {Nat.is_eq(U32.to_nat(P), quad(Q)) == True{} : Bool}
  for +eg: {good(ps, Q) == True{} : Bool}
  for +hb: {Nat.is_le(Nat.add(U32.to_nat(off), List.length(&2, U32, cat(ps))), U32.to_nat(c)) == True{} : Bool}
  {fillp(ps, B.Buf{ws, n}, off, P) == B.fill_at(B.Buf{ws, n}, off, cat(ps)) : B.Buf}
def fill_pieces(ps, ws, n, off, y, P, Q, c, ey, eP, eg, hb):
  match ps:
    case Nil{}: {==}
    case Con{+p, +rest}:
      match rest:
        case Nil{}:
          %Equal.sym(+List<U32>, List.append(&2, U32, p, []), p, app_nil(p)) : {B.fill_at(B.Buf{ws, n}, off, p) == B.fill_at(B.Buf{ws, n}, off, _) : B.Buf}
          {==}
        case Con{+q, +r}:
          +e_al = WS.and_left(al(p), Bool.and(Nat.is_eq(nq(p), Q), good(Con{q, r}, Q)), eg)
          +e_rest = WS.and_right(al(p), Bool.and(Nat.is_eq(nq(p), Q), good(Con{q, r}, Q)), eg)
          +e_nq = WS.nat_eq(nq(p), Q, WS.and_left(Nat.is_eq(nq(p), Q), good(Con{q, r}, Q), e_rest))
          +e_g = WS.and_right(Nat.is_eq(nq(p), Q), good(Con{q, r}, Q), e_rest)
          +eP2 = WS.nat_eq(U32.to_nat(P), quad(Q), eP)
          +lp = len_p(p, P, Q, e_al, e_nq, eP2)
          +hbP = hb_first(off, P, p, cat(Con{q, r}), c, lp, hb)
          +np = AR.add_le(off, P, c, hbP)
          +ey2 = Equal.trans(Nat, U32.to_nat((off + P : U32)), Nat.add(U32.to_nat(off), U32.to_nat(P)), quad(Nat.add(y, Q)), np, qs(off, y, P, Q, ey, eP2))
          Equal.trans(B.Buf, fillp(Con{q, r}, B.Buf{B.fill_go(p, ws, U32.shrn(off, 2n)), n}, (off + P : U32), P),
            B.fill_at(B.fill_at(B.Buf{ws, n}, off, p), (off + P : U32), cat(Con{q, r})),
            B.fill_at(B.Buf{ws, n}, off, List.append(&2, U32, p, cat(Con{q, r}))),
            fill_pieces(Con{q, r}, B.fill_go(p, ws, U32.shrn(off, 2n)), n, (off + P : U32), Nat.add(y, Q), P, Q, c, ey2, eP, e_g, hb_rest(off, P, p, cat(Con{q, r}), c, lp, np, hb)),
            fill_two(ws, n, off, (off + P : U32), p, cat(Con{q, r}), e_al, next_off(off, y, P, Q, p, c, ey, eP2, e_al, e_nq, hbP)))

# The driver: pieces of 65536 bytes (every piece but the last is 16384 whole
# words), read into a fresh buffer from offset 0, fill it as the whole list.
def driver_fill(+size: U32, +ps: List<&2, +List<U32>>, +c: U32,
    +eg: {good(ps, 16384n) == True{} : Bool},
    +hb: {Nat.is_le(List.length(&2, U32, cat(ps)), U32.to_nat(c)) == True{} : Bool})
    -> {fillp(ps, B.alloc(size), 0, 65536) == B.fill_at(B.alloc(size), 0, cat(ps)) : B.Buf}:
  fill_pieces(ps, Array.new(U32, B.capacity(size), 0), size, 0, 0n, 65536, 16384n, c, {==}, {==}, eg, hb)
