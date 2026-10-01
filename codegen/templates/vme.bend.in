import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vcopy.bend as VC
import ./venc.bend as VE
import ./vmul.bend as VM
import ./vspec.bend as VS
import ./vfix.bend as VF

# GENERATED from codegen/vme.bend.in by codegen/var_multi.py. Do not edit.
# Encoder facts for lists of byte vectors: the storage check of such a list
# (any lower/upper bound and element size), and the sizes' arithmetic.

# E a <= E b when a <= b.
law mulE_mono:
  for +E: Nat
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(VM.mulE(E, a), VM.mulE(E, b)) == True{} : Bool}
def mulE_mono(E, a, b, h):
  match a b:
    case 0n _: F.nat__zero_le(VM.mulE(E, b))
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(VM.mulE(E, 1n+p), VM.mulE(E, 0n)) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +p 1n+ +q: Order.add_left(E, VM.mulE(E, p), VM.mulE(E, q), mulE_mono(E, p, q, h))

law quad_mono:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(A.quad(a), A.quad(b)) == True{} : Bool}
def quad_mono(a, b, h): F.nat__double_le(Nat.double(a), Nat.double(b), F.nat__double_le(a, b, h))

# A U32 that is c whole elements of e bytes has no remainder.
def mod0(+L: U32, +e: U32, +v: Word(31n), +eb: {e == U32{Word.shr.pad(31n, v)} : U32}, +hb: {Nat.is_le(1n, U32.to_nat(e)) == True{} : Bool},
    +hz: {U32.is_zero(e) == False{} : Bool}, +c: Nat, +ec: {U32.to_nat(L) == Nat.mul(c, U32.to_nat(e)) : Nat})
    -> {U32.is_eq(U32.mod(L, e), 0) == True{} : Bool}:
  F.u32alg__eq_true(U32.mod(L, e), 0, F.u32__injective(U32.mod(L, e), 0,
    Pair.snd({U32.to_nat(U32.div(L, e)) == c : Nat}, {U32.to_nat(U32.mod(L, e)) == 0n : Nat}, VU.whole_q(L, e, c, ec, hb, VU.div_u32(L, e, v, eb, hb, hz)))))

# The storage check of a packed byte collection of whole words.
law words_okg:
  for +dw: Nat
  for +T: F.array__Tree<U32>
  for +n: U32
  for +lo: U32
  for +hi: U32
  for +unit: U32
  for +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool}
  for +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}
  for +hlo: {U32.is_le(lo, n) == True{} : Bool}
  for +hhi: {U32.is_le(n, hi) == True{} : Bool}
  for +hu: {O.unit_ok(unit, n) == True{} : Bool}
  for +h3: {U32.and(n, 3) == 0 : U32}
  for +hroom: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool}
  {O.words_ok(O.Words{F.array__thaw(U32, T), n}, lo, hi, False{}, unit) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
def words_okg(dw, T, n, lo, hi, unit, pfT, hdw, hlo, hhi, hu, h3, hroom):
  %Equal.sym(Array<U32> & U32, Array.size(U32, F.array__thaw(U32, T)), (F.array__thaw(U32, T), F.u32__pow2u(dw)), F.array__size_thaw(U32, dw, T, pfT)) :
    {O.wk_cap(Bool.and(Bool.and(U32.is_le(lo, n), Bool.or(False{}, U32.is_le(n, hi))), O.unit_ok(unit, n)), n, _) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Array<U32> & U32, Array.get(U32, F.array__thaw(U32, T), U32.shrn(n, 2n)), (F.array__thaw(U32, T), RD.wd(T, dw, U32.shrn(n, 2n))), VE.get_any(dw, T, U32.shrn(n, 2n), VB.lt32(dw, hdw), pfT)) :
    {O.wk_last(Bool.and(Bool.and(Bool.and(U32.is_le(lo, n), Bool.or(False{}, U32.is_le(n, hi))), O.unit_ok(unit, n)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), n, _) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(lo, n), True{}, hlo) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(_, Bool.or(False{}, U32.is_le(n, hi))), O.unit_ok(unit, n)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), O.tail_zero(U32.and(n, 3), RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(n, hi), True{}, hhi) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, _)), O.unit_ok(unit, n)), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), O.tail_zero(U32.and(n, 3), RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, O.unit_ok(unit, n), True{}, hu) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, True{})), _), U32.is_le(VC.nwu(n), F.u32__pow2u(dw))), O.tail_zero(U32.and(n, 3), RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(Bool, U32.is_le(VC.nwu(n), F.u32__pow2u(dw)), True{}, VE.le_room(n, dw, hdw, hroom)) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, True{})), True{}), _), O.tail_zero(U32.and(n, 3), RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  %Equal.sym(U32, U32.and(n, 3), 0, h3) :
    {(O.Words{F.array__thaw(U32, T), n}, Bool.and(Bool.and(Bool.and(Bool.and(True{}, Bool.or(False{}, True{})), True{}), True{}), O.tail_zero(_, RD.wd(T, dw, U32.shrn(n, 2n))))) == (O.Words{F.array__thaw(U32, T), n}, True{}) : O.Words & Bool}
  {==}

# ---- windows of a tree after a list copy (VB.mone) ------------------------------------------------

def mpeel_lo(+n: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +m: Nat, +p: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(n, j), p) == True{} : Bool})
    -> {VF.WIN(m, p, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, T))) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, T)), VB.lm(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, T)), VB.slots_mone(n, 0n, j, dd, D, T, pf, hj)) :
    {VF.WIN(m, p, _) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}
  VF.lm_lo(n, 0n, j, m, p, F.array__slots(U32, D), F.array__slots(U32, T), h)

def mpeel_hi(+n: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +T: F.array__Tree<U32>, +m: Nat, +p: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(m, p), j) == True{} : Bool})
    -> {VF.WIN(m, p, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, T))) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, T)), VB.lm(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, T)), VB.slots_mone(n, 0n, j, dd, D, T, pf, hj)) :
    {VF.WIN(m, p, _) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}
  VF.lm_hi(n, 0n, j, m, p, F.array__slots(U32, D), F.array__slots(U32, T), h)

# The copied window is the source's first n words.
def mown(+n: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +dw: Nat, +T: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hj: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool}, +hi: {Nat.is_le(Nat.add(n, 0n), VB.pw(dw)) == True{} : Bool})
    -> {VF.WIN(n, j, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, T))) == VS.wtake(n, F.array__slots(U32, T)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, T)), VB.lm(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, T)), VB.slots_mone(n, 0n, j, dd, D, T, pf, hj)) :
    {VF.WIN(n, j, _) == VS.wtake(n, F.array__slots(U32, T)) : List<&2, U32>}
  VB.lm_win(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, T),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(n, j), z) == True{} : Bool}, VB.pw(dd), VB.len(F.array__slots(U32, D)), Equal.sym(Nat, VB.len(F.array__slots(U32, D)), VB.pw(dd), F.array__slots_length(U32, dd, D, pf)), hj),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(n, 0n), z) == True{} : Bool}, VB.pw(dw), VB.len(F.array__slots(U32, T)), Equal.sym(Nat, VB.len(F.array__slots(U32, T)), VB.pw(dw), F.array__slots_length(U32, dw, T, pfT)), hi))
