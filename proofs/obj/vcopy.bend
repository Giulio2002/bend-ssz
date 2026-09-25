import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/buf.bend as BF
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vdepth.bend as VD
import ./vu32.bend as VU

# The input copy O.copy_in (the decoder of every packed field) on the array
# model: an aligned range of whole words.

def split4_c(+b0: Bool, +b1: Bool, +r: Word(30n)) -> {U32.to_nat(U32.shrn(U32{WCon{b0, WCon{b1, r}}}, 2n)) == Word.to_nat(30n, r) : Nat}:
  BF.quarter_value(b0, b1, r)

# A word is four times its value shifted right by two, plus its low two bits.
law split4:
  for +x: U32
  {U32.to_nat(x) == Nat.add(A.quad(U32.to_nat(U32.shrn(x, 2n))), U32.to_nat(U32.and(x, 3))) : Nat}
def split4(x):
  match x:
    case U32{WCon{False{}, WCon{False{}, +r}}}:
      %Equal.sym(Word(30n), Word.and(30n, r, Word.zero(30n)), Word.zero(30n), BF.and_zero(30n, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, r}}}) == Nat.add(A.quad(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{False{}, r}}}, 2n))), U32.to_nat(U32{WCon{False{}, WCon{False{}, _}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{False{}, r}}}, 2n)), Word.to_nat(30n, r), BF.quarter_value(False{}, False{}, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{False{}, r}}}) == Nat.add(A.quad(_), 0n) : Nat}
      %F.nat__add_comm(0n, A.quad(Word.to_nat(30n, r))) : {U32.to_nat(U32{WCon{False{}, WCon{False{}, r}}}) == _ : Nat}
      {==}
    case U32{WCon{True{}, WCon{False{}, +r}}}:
      %Equal.sym(Word(30n), Word.and(30n, r, Word.zero(30n)), Word.zero(30n), BF.and_zero(30n, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, r}}}) == Nat.add(A.quad(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n))), U32.to_nat(U32{WCon{True{}, WCon{False{}, _}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{False{}, r}}}, 2n)), Word.to_nat(30n, r), BF.quarter_value(True{}, False{}, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{False{}, r}}}) == Nat.add(A.quad(_), 1n) : Nat}
      %F.nat__add_comm(1n, A.quad(Word.to_nat(30n, r))) : {U32.to_nat(U32{WCon{True{}, WCon{False{}, r}}}) == _ : Nat}
      {==}
    case U32{WCon{False{}, WCon{True{}, +r}}}:
      %Equal.sym(Word(30n), Word.and(30n, r, Word.zero(30n)), Word.zero(30n), BF.and_zero(30n, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, r}}}) == Nat.add(A.quad(U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n))), U32.to_nat(U32{WCon{False{}, WCon{True{}, _}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{False{}, WCon{True{}, r}}}, 2n)), Word.to_nat(30n, r), BF.quarter_value(False{}, True{}, r)) :
        {U32.to_nat(U32{WCon{False{}, WCon{True{}, r}}}) == Nat.add(A.quad(_), 2n) : Nat}
      %F.nat__add_comm(2n, A.quad(Word.to_nat(30n, r))) : {U32.to_nat(U32{WCon{False{}, WCon{True{}, r}}}) == _ : Nat}
      {==}
    case U32{WCon{True{}, WCon{True{}, +r}}}:
      %Equal.sym(Word(30n), Word.and(30n, r, Word.zero(30n)), Word.zero(30n), BF.and_zero(30n, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, r}}}) == Nat.add(A.quad(U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n))), U32.to_nat(U32{WCon{True{}, WCon{True{}, _}}})) : Nat}
      %Equal.sym(Nat, U32.to_nat(U32.shrn(U32{WCon{True{}, WCon{True{}, r}}}, 2n)), Word.to_nat(30n, r), BF.quarter_value(True{}, True{}, r)) :
        {U32.to_nat(U32{WCon{True{}, WCon{True{}, r}}}) == Nat.add(A.quad(_), 3n) : Nat}
      %F.nat__add_comm(3n, A.quad(Word.to_nat(30n, r))) : {U32.to_nat(U32{WCon{True{}, WCon{True{}, r}}}) == _ : Nat}
      {==}

# The storage word count of n bytes, and the size copy_in allocates for.
def nwu(+L: U32) -> U32: U32.shrn(U32.add(L, 3), 2n)
def NW(+L: U32) -> Nat: U32.to_nat(nwu(L))
def WZ(+L: U32) -> U32: U32.add(U32.mul(U32.shrn(U32.add(L, 31), 5n), 8), 8)
def ZT(+dz: Nat) -> F.array__Tree<U32>: F.array__trep(U32, dz, 0)

def mask_keep(+L: U32, X: Array<U32>, +h3: {U32.and(L, 3) == 0 : U32}) -> {O.mask_last(L, X) == X : Array<U32>}:
  %Equal.sym(U32, U32.and(L, 3), 0, h3) : {O.ml_go(U32.is_eq(_, 0), _, U32.sub(nwu(L), 1), X) == X : Array<U32>}
  {==}

def ci_case(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +off: U32, +i: Nat, +L: U32, +dz: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool},
    +h3: {U32.and(off, 3) == 0 : U32}, +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}, +hL3: {U32.and(L, 3) == 0 : U32},
    +hs: {Nat.is_le(Nat.add(NW(L), i), VB.pw(d)) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(NW(L), 0n), VB.pw(dz)) == True{} : Bool},
    +z: Bool, +ez: {U32.is_eq(L, 0) == z : Bool})
    -> {O.ci_fin(n, L, O.ci_go(z, U32.and(off, 3), U32.shrn(off, 2n), nwu(L), F.array__thaw(U32, ZT(dz)), F.array__thaw(U32, t)))
        == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}:
  match z:
    case True{}:
      +eL = F.u32alg__eq_of(L, 0, ez)
      %Equal.sym(Array<U32>, O.mask_last(L, F.array__thaw(U32, ZT(dz))), F.array__thaw(U32, ZT(dz)), mask_keep(L, F.array__thaw(U32, ZT(dz)), hL3)) :
        {(B.Buf{F.array__thaw(U32, t), n}, O.Words{_, L}) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      %Equal.sym(U32, L, 0, eL) :
        {(B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, ZT(dz)), L}) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(_), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      {==}
    case False{}:
      %Equal.sym(U32, U32.and(off, 3), 0, h3) :
        {O.ci_fin(n, L, O.ci_pick(_, U32.shrn(off, 2n), nwu(L), F.array__thaw(U32, ZT(dz)), F.array__thaw(U32, t)))
          == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      %Equal.sym(Array<U32> & Array<U32>, O.acopy(nwu(L), U32.shrn(off, 2n), 0, F.array__thaw(U32, ZT(dz)), F.array__thaw(U32, t)),
          (F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), F.array__thaw(U32, t)),
          VB.acopy_ok(nwu(L), U32.shrn(off, 2n), 0, i, 0n, dz, d, ZT(dz), t, ei, {==}, hdz, hd, hs, hr, F.array__trep_perfect(U32, dz, 0), pf)) :
        {O.ci_fin(n, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      %Equal.sym(Array<U32>, O.mask_last(L, F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t))), F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), mask_keep(L, F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), hL3)) :
        {(B.Buf{F.array__thaw(U32, t), n}, O.Words{_, L}) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
      {==}

# copy_in of a whole number of words at a word-aligned offset copies them.
law copy_in_ok:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +off: U32
  for +i: Nat
  for +L: U32
  for +dz: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hdz: {Nat.is_lt(dz, 31n) == True{} : Bool}
  for +ez: {B.zeros(B.words_depth_u(WZ(L))) == Array.new(U32, dz, 0) : Array<U32>}
  for +h3: {U32.and(off, 3) == 0 : U32}
  for +ei: {U32.to_nat(U32.shrn(off, 2n)) == i : Nat}
  for +hL3: {U32.and(L, 3) == 0 : U32}
  for +hs: {Nat.is_le(Nat.add(NW(L), i), VB.pw(d)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  {O.copy_in(B.Buf{F.array__thaw(U32, t), n}, off, L) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
def copy_in_ok(d, t, n, off, i, L, dz, pf, hd, hdz, ez, h3, ei, hL3, hs, hr):
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(WZ(L))), Array.new(U32, dz, 0), ez) :
    {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
  %Equal.sym(Array<U32>, Array.new(U32, dz, 0), F.array__thaw(U32, ZT(dz)), F.array__new(U32, dz, 0)) :
    {O.copy_into(B.Buf{F.array__thaw(U32, t), n}, off, L, _) == (B.Buf{F.array__thaw(U32, t), n}, O.Words{F.array__thaw(U32, VB.mone(NW(L), i, 0n, dz, ZT(dz), t)), L}) : B.Buf & O.Words}
  ci_case(d, t, n, off, i, L, dz, pf, hd, hdz, h3, ei, hL3, hs, hr, U32.is_eq(L, 0), {==})

# ---- halvings -----------------------------------------------------------------------------

law h2_mono:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(VD.s_h2(a), VD.s_h2(b)) == True{} : Bool}
def h2_mono(a, b, e):
  match a b:
    case 0n _: Order.zero_le(VD.s_h2(b))
    case 1n 0n: Empty.absurd({Nat.is_le(0n, 0n) == True{} : Bool}, F.logic__false_true(e))
    case 1n 1n+ +q: Order.zero_le(VD.s_h2(1n+q))
    case 2n+p 0n: Empty.absurd({Nat.is_le(VD.s_h2(2n+p), 0n) == True{} : Bool}, F.logic__false_true(e))
    case 2n+p 1n: Empty.absurd({Nat.is_le(VD.s_h2(2n+p), 0n) == True{} : Bool}, F.logic__false_true(e))
    case 2n+ +p 2n+ +q: h2_mono(p, q, e)

law rng_mono:
  for +L: Nat
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(VD.s_rng(L, a), VD.s_rng(L, b)) == True{} : Bool}
def rng_mono(L, a, b, e):
  match L:
    case 0n: e
    case 1n+ +k: h2_mono(VD.s_rng(k, a), VD.s_rng(k, b), rng_mono(k, a, b, e))

law h2_up:
  for +z: Nat
  {Nat.is_le(z, 1n+Nat.double(VD.s_h2(z))) == True{} : Bool}
def h2_up(z):
  match z:
    case 0n: {==}
    case 1n: {==}
    case 2n+ +q: h2_up(q)

law h2_down:
  for +z: Nat
  {Nat.is_le(Nat.double(VD.s_h2(z)), z) == True{} : Bool}
def h2_down(z):
  match z:
    case 0n: {==}
    case 1n: {==}
    case 2n+ +q: h2_down(q)

# rng(2, y) <= y
def rng2_le(+y: Nat) -> {Nat.is_le(VD.s_rng(2n, y), y) == True{} : Bool}:
  +a = VD.s_h2(y)
  F.nat__le_trans(VD.s_h2(a), a, y,
    F.nat__le_trans(VD.s_h2(a), Nat.double(VD.s_h2(a)), a, F.nat__double_self_le(VD.s_h2(a)), h2_down(a)),
    F.nat__le_trans(a, Nat.double(a), y, F.nat__double_self_le(a), h2_down(y)))

# 8 rng(3, z) <= z
def rng3_down(+z: Nat) -> {Nat.is_le(VB.d3(VD.s_rng(3n, z)), z) == True{} : Bool}:
  +a = VD.s_h2(z)
  +b = VD.s_h2(a)
  +c = VD.s_h2(b)
  +l1 = Order.double_monotone(Nat.double(Nat.double(c)), Nat.double(b), Order.double_monotone(Nat.double(c), b, h2_down(b)))
  +l2 = Order.double_monotone(Nat.double(b), a, h2_down(a))
  F.nat__le_trans(VB.d3(c), Nat.double(a), z, F.nat__le_trans(VB.d3(c), Nat.double(Nat.double(b)), Nat.double(a), l1, l2), h2_down(z))

# z <= 8 rng(3, z) + 7
def rng3_up(+z: Nat) -> {Nat.is_le(z, 7n+VB.d3(VD.s_rng(3n, z))) == True{} : Bool}:
  +a = VD.s_h2(z)
  +b = VD.s_h2(a)
  +c = VD.s_h2(b)
  +s1 = h2_up(z)
  +s2 = Order.double_monotone(a, 1n+Nat.double(b), h2_up(a))
  +s3 = Order.double_monotone(Nat.double(b), Nat.double(1n+Nat.double(c)), Order.double_monotone(b, 1n+Nat.double(c), h2_up(b)))
  F.nat__le_trans(z, 1n+Nat.double(a), 7n+VB.d3(c), s1,
    F.nat__le_trans(1n+Nat.double(a), 3n+Nat.double(Nat.double(b)), 7n+VB.d3(c), s2, s3))

law x8_mul:
  for +c: Nat
  {Nat.mul(c, 8n) == VS.x8(c) : Nat}
def x8_mul(c):
  match c:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.mul(p, 8n), VS.x8(p), x8_mul(p)) : {8n+_ == 8n+VS.x8(p) : Nat}
      {==}

def d3_mul(+c: Nat) -> {Nat.mul(c, 8n) == VB.d3(c) : Nat}:
  Equal.trans(Nat, Nat.mul(c, 8n), VS.x8(c), VB.d3(c), x8_mul(c), VB.x8_d3(c))

# ---- the size copy_in allocates for -------------------------------------------------------

def YL(+L: U32) -> Nat: Nat.add(31n, U32.to_nat(L))

def ey31(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(YL(L), VB.pw(k)) == True{} : Bool})
    -> {U32.to_nat(U32.add(L, 31)) == YL(L) : Nat}:
  VB.add_le_at(L, 31, U32.to_nat(L), k, {==}, hk, hy)

def eq_q(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(YL(L), VB.pw(k)) == True{} : Bool})
    -> {U32.to_nat(U32.shrn(U32.add(L, 31), 5n)) == VD.s_rng(5n, YL(L)) : Nat}:
  %Equal.cong(Nat, Nat, z => VD.s_rng(5n, z), U32.to_nat(U32.add(L, 31)), YL(L), ey31(L, k, hk, hy)) :
    {U32.to_nat(U32.shrn(U32.add(L, 31), 5n)) == _ : Nat}
  VD.shrk(5n, U32.add(L, 31))

def q8_le(+Y: Nat) -> {Nat.is_le(VB.d3(VD.s_rng(5n, Y)), Y) == True{} : Bool}:
  F.nat__le_trans(VB.d3(VD.s_rng(5n, Y)), VD.s_rng(2n, Y), Y, rng3_down(VD.s_rng(2n, Y)), rng2_le(Y))

def eM(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(YL(L), VB.pw(k)) == True{} : Bool})
    -> {U32.to_nat(U32.mul(U32.shrn(U32.add(L, 31), 5n), 8)) == VB.d3(VD.s_rng(5n, YL(L))) : Nat}:
  +q = U32.to_nat(U32.shrn(U32.add(L, 31), 5n))
  +e1 = eq_q(L, k, hk, hy)
  +hb = F.logic__subst(Nat, z => {Nat.is_le(Nat.mul(q, 8n), z) == True{} : Bool}, YL(L), U32.to_nat(U32.add(L, 31)), Equal.sym(Nat, U32.to_nat(U32.add(L, 31)), YL(L), ey31(L, k, hk, hy)),
    F.logic__subst(Nat, z => {Nat.is_le(z, YL(L)) == True{} : Bool}, VB.d3(VD.s_rng(5n, YL(L))), Nat.mul(q, 8n),
      Equal.sym(Nat, Nat.mul(q, 8n), VB.d3(VD.s_rng(5n, YL(L))), Equal.trans(Nat, Nat.mul(q, 8n), Nat.mul(VD.s_rng(5n, YL(L)), 8n), VB.d3(VD.s_rng(5n, YL(L))),
        Equal.cong(Nat, Nat, z => Nat.mul(z, 8n), q, VD.s_rng(5n, YL(L)), e1), d3_mul(VD.s_rng(5n, YL(L))))),
      q8_le(YL(L))))
  %Equal.sym(Nat, U32.to_nat(U32.mul(U32.shrn(U32.add(L, 31), 5n), 8)), Nat.mul(q, 8n), VU.mul_le(U32.shrn(U32.add(L, 31), 5n), 8, U32.add(L, 31), hb)) :
    {_ == VB.d3(VD.s_rng(5n, YL(L))) : Nat}
  %Equal.sym(Nat, q, VD.s_rng(5n, YL(L)), e1) : {Nat.mul(_, 8n) == VB.d3(VD.s_rng(5n, YL(L))) : Nat}
  d3_mul(VD.s_rng(5n, YL(L)))

law NA_mono:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for +d: Nat
  for +ab: {Nat.is_le(a, b) == True{} : Bool}
  for +cd: {Nat.is_le(c, d) == True{} : Bool}
  {Nat.is_le(Nat.add(a, c), Nat.add(b, d)) == True{} : Bool}
def NA_mono(a, b, c, d, ab, cd):
  F.nat__le_trans(Nat.add(a, c), Nat.add(b, c), Nat.add(b, d), Order.add_right(a, b, c, ab), Order.add_left(b, c, d, cd))

def eWZ(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(YL(L), VB.pw(k)) == True{} : Bool})
    -> {U32.to_nat(WZ(L)) == Nat.add(VB.d3(VD.s_rng(5n, YL(L))), 8n) : Nat}:
  +M = U32.mul(U32.shrn(U32.add(L, 31), 5n), 8)
  +em = eM(L, k, hk, hy)
  +X = VB.d3(VD.s_rng(5n, YL(L)))
  # X + 8 <= Y + Y <= 2^(1 + k)
  +h1 = F.nat__le_trans(Nat.add(X, 8n), Nat.add(YL(L), YL(L)), VB.pw(1n+k),
    NA_mono(X, YL(L), 8n, YL(L), q8_le(YL(L)), F.nat__zero_le(23n+U32.to_nat(L))),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(YL(L), YL(L)), z) == True{} : Bool}, Nat.add(VB.pw(k), VB.pw(k)), VB.pw(1n+k),
      Equal.sym(Nat, VB.pw(1n+k), Nat.add(VB.pw(k), VB.pw(k)), F.lru_nat_algebra__double_self(VB.pw(k))),
      NA_mono(YL(L), VB.pw(k), YL(L), VB.pw(k), hy, hy)))
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 8n), U32.to_nat(F.u32__pow2u(1n+k))) == True{} : Bool}, X, U32.to_nat(M), Equal.sym(Nat, U32.to_nat(M), X, em),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(X, 8n), z) == True{} : Bool}, VB.pw(1n+k), U32.to_nat(F.u32__pow2u(1n+k)), Equal.sym(Nat, U32.to_nat(F.u32__pow2u(1n+k)), VB.pw(1n+k), F.u32__pow2u_value(1n+k, hk)), h1))
  %Equal.sym(Nat, U32.to_nat(U32.add(M, 8)), Nat.add(U32.to_nat(M), 8n), A.add_le(M, 8, F.u32__pow2u(1n+k), h2)) : {_ == Nat.add(X, 8n) : Nat}
  %Equal.sym(Nat, U32.to_nat(M), X, em) : {Nat.add(_, 8n) == Nat.add(X, 8n) : Nat}
  {==}


def eNW(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(YL(L), VB.pw(k)) == True{} : Bool})
    -> {NW(L) == VD.s_rng(2n, 3n+U32.to_nat(L)) : Nat}:
  +h3 = F.nat__le_trans(3n+U32.to_nat(L), YL(L), VB.pw(k), Order.left_below_sum(28n, U32.to_nat(L)), hy)
  %Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), U32.to_nat(U32.add(L, 3)), 3n+U32.to_nat(L), VB.add_le_at(L, 3, U32.to_nat(L), k, {==}, hk, h3)) :
    {NW(L) == _ : Nat}
  VD.shrk(2n, U32.add(L, 3))

# The allocation has room for the words: (L + 3) >> 2 <= ((L + 31) >> 5) 8 + 8.
def nw_le_wz(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(YL(L), VB.pw(k)) == True{} : Bool})
    -> {Nat.is_le(NW(L), U32.to_nat(WZ(L))) == True{} : Bool}:
  +Y = YL(L)
  +D = VB.d3(VD.s_rng(5n, Y))
  %Equal.sym(Nat, NW(L), VD.s_rng(2n, 3n+U32.to_nat(L)), eNW(L, k, hk, hy)) : {Nat.is_le(_, U32.to_nat(WZ(L))) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(WZ(L)), Nat.add(D, 8n), eWZ(L, k, hk, hy)) : {Nat.is_le(VD.s_rng(2n, 3n+U32.to_nat(L)), _) == True{} : Bool}
  %F.nat__add_comm(8n, D) : {Nat.is_le(VD.s_rng(2n, 3n+U32.to_nat(L)), _) == True{} : Bool}
  F.nat__le_trans(VD.s_rng(2n, 3n+U32.to_nat(L)), VD.s_rng(2n, Y), 8n+D,
    rng_mono(2n, 3n+U32.to_nat(L), Y, Order.left_below_sum(28n, U32.to_nat(L))),
    F.nat__le_trans(VD.s_rng(2n, Y), 7n+D, 8n+D, rng3_up(VD.s_rng(2n, Y)), F.nat__le_succ(7n+D)))

# ... and the allocation is at most (L + 31) / 4 + 8 words.
def wz_le(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(YL(L), VB.pw(k)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(WZ(L)), Nat.add(VD.s_rng(2n, YL(L)), 8n)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(WZ(L)), Nat.add(VB.d3(VD.s_rng(5n, YL(L))), 8n), eWZ(L, k, hk, hy)) : {Nat.is_le(_, Nat.add(VD.s_rng(2n, YL(L)), 8n)) == True{} : Bool}
  Order.add_right(VB.d3(VD.s_rng(5n, YL(L))), VD.s_rng(2n, YL(L)), 8n, rng3_down(VD.s_rng(2n, YL(L))))
