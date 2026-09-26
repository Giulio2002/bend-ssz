import Base
import ../compact/found.bend as F
import ./vu32.bend as VU
import ./vua_lay.bend as LY

# Sums of U32 constants, for layouts whose positions are large (BeaconState's run to 2.7M).
#
# The checker evaluates a closed Nat term (U32.to_nat(c), Nat.add(C, x), Nat.is_le(A, B)) in
# unary, so a byte position is kept as the term U32.to_nat(c) and never evaluated: the facts
# between positions are proved here for variables, then instantiated at the constants, where
# the side conditions (a carry, a U32 sum, a U32 comparison) are closed U32 terms, evaluated in
# binary.

# The carry out of a + b.
def CY(+a: U32, +b: U32) -> Bool:
  match a b:
    case U32{+x} U32{+y}: F.lru_addition__carry_out(32n, x, y, False{})

def add_nc_w(+n: Nat, +x: Word(n), +y: Word(n), +hc: {F.lru_addition__carry_out(n, x, y, False{}) == False{} : Bool})
    -> {F.u32alg__uw(n, Word.add(n, x, y)) == Nat.add(F.u32alg__uw(n, x), F.u32alg__uw(n, y)) : Nat}:
  +us = F.u32alg__uw(n, Word.add(n, x, y))
  +uxy = Nat.add(F.u32alg__uw(n, x), F.u32alg__uw(n, y))
  +e1 = F.logic__subst(Bool, z => {Nat.add(us, F.u32alg__sc(n, F.spec_numeric__bit_value(z))) == uxy : Nat}, F.lru_addition__carry_out(n, x, y, False{}), False{}, hc,
    F.u32alg__cons(n, x, y))
  Equal.trans(Nat, us, Nat.add(us, F.u32alg__sc(n, 0n)), uxy,
    Equal.sym(Nat, Nat.add(us, F.u32alg__sc(n, 0n)), us, Equal.trans(Nat, Nat.add(us, F.u32alg__sc(n, 0n)), Nat.add(us, 0n), us,
      Equal.cong(Nat, Nat, q => Nat.add(us, q), F.u32alg__sc(n, 0n), 0n, F.u32alg__sc_zero(n)), F.nat__add_zero(us))),
    e1)

# a + b without a carry is the Nat sum.
def add_nc(+a: U32, +b: U32, +hc: {CY(a, b) == False{} : Bool}) -> {U32.to_nat(U32.add(a, b)) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}:
  match a b:
    case U32{+x} U32{+y}:
      +tx = U32.to_nat(U32{x})
      +ty = U32.to_nat(U32{y})
      +ux = F.u32alg__uw(32n, x)
      +uy = F.u32alg__uw(32n, y)
      +sum = Equal.trans(Nat, Nat.add(tx, ty), Nat.add(ux, ty), Nat.add(ux, uy),
        Equal.cong(Nat, Nat, q => Nat.add(q, ty), tx, ux, F.u32__to_nat_word(x)),
        Equal.cong(Nat, Nat, q => Nat.add(ux, q), ty, uy, F.u32__to_nat_word(y)))
      Equal.trans(Nat, U32.to_nat(U32{Word.add(32n, x, y)}), F.u32alg__uw(32n, Word.add(32n, x, y)), Nat.add(tx, ty),
        F.u32__to_nat_word(Word.add(32n, x, y)),
        Equal.trans(Nat, F.u32alg__uw(32n, Word.add(32n, x, y)), Nat.add(ux, uy), Nat.add(tx, ty),
          add_nc_w(32n, x, y, hc), Equal.sym(Nat, Nat.add(tx, ty), Nat.add(ux, uy), sum)))

# A position plus a size: to_nat(a) + s = to_nat(c), for c = a + b (no carry), s = to_nat(b).
def stp(+a: U32, +b: U32, +c: U32, +s: Nat, +es: {U32.to_nat(b) == s : Nat}, +ec: {U32.add(a, b) == c : U32}, +hc: {CY(a, b) == False{} : Bool})
    -> {Nat.add(U32.to_nat(a), s) == U32.to_nat(c) : Nat}:
  %es : {Nat.add(U32.to_nat(a), _) == U32.to_nat(c) : Nat}
  %ec : {Nat.add(U32.to_nat(a), U32.to_nat(b)) == U32.to_nat(_) : Nat}
  Equal.sym(Nat, U32.to_nat(U32.add(a, b)), Nat.add(U32.to_nat(a), U32.to_nat(b)), add_nc(a, b, hc))

# A size plus a length: s + to_nat(b) = to_nat(c), for c = a + b (no carry), s = to_nat(a).
def stpL(+a: U32, +b: U32, +c: U32, +s: Nat, +es: {U32.to_nat(a) == s : Nat}, +ec: {U32.add(a, b) == c : U32}, +hc: {CY(a, b) == False{} : Bool})
    -> {Nat.add(s, U32.to_nat(b)) == U32.to_nat(c) : Nat}:
  %es : {Nat.add(_, U32.to_nat(b)) == U32.to_nat(c) : Nat}
  %ec : {Nat.add(U32.to_nat(a), U32.to_nat(b)) == U32.to_nat(_) : Nat}
  Equal.sym(Nat, U32.to_nat(U32.add(a, b)), Nat.add(U32.to_nat(a), U32.to_nat(b)), add_nc(a, b, hc))

def le_nat(+a: U32, +b: U32, +h: {U32.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}:
  F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

# A position plus a size within f: to_nat(a) + s <= to_nat(f), for a + b <= f (no carry), s = to_nat(b).
def lea(+a: U32, +b: U32, +f: U32, +s: Nat, +es: {U32.to_nat(b) == s : Nat}, +hc: {CY(a, b) == False{} : Bool}, +h: {U32.is_le(U32.add(a, b), f) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(a), s), U32.to_nat(f)) == True{} : Bool}:
  %es : {Nat.is_le(Nat.add(U32.to_nat(a), _), U32.to_nat(f)) == True{} : Bool}
  %add_nc(a, b, hc) : {Nat.is_le(_, U32.to_nat(f)) == True{} : Bool}
  le_nat(U32.add(a, b), f, h)

# ---- the widths of a layout, summed ----------------------------------------------------------------

# WFS of a cons, from its head's slot and its tail's sum.
def wfs_c(+w: Maybe<&2, Nat>, +t: +List<Maybe<&2, Nat>>, +a: Nat, +b: Nat, +e1: {LY.WSL(w) == a : Nat}, +e2: {LY.WFS(t) == b : Nat})
    -> {LY.WFS(Con{w, t}) == Nat.add(a, b) : Nat}:
  %e1 : {LY.WFS(Con{w, t}) == Nat.add(_, b) : Nat}
  %e2 : {LY.WFS(Con{w, t}) == Nat.add(LY.WSL(w), _) : Nat}
  {==}

# WPOS at 1 + q of a cons, from its head's slot and the tail's WPOS at q.
def wpos_c(+w: Maybe<&2, Nat>, +t: +List<Maybe<&2, Nat>>, +q: Nat, +a: Nat, +b: Nat, +e1: {LY.WSL(w) == a : Nat}, +e2: {LY.WPOS(t, q) == b : Nat})
    -> {LY.WPOS(Con{w, t}, 1n+q) == Nat.add(a, b) : Nat}:
  %e1 : {LY.WPOS(Con{w, t}, 1n+q) == Nat.add(_, b) : Nat}
  %e2 : {LY.WPOS(Con{w, t}, 1n+q) == Nat.add(LY.WSL(w), _) : Nat}
  {==}

def wpos_0(+t: +List<Maybe<&2, Nat>>) -> {LY.WPOS(t, 0n) == 0n : Nat}:
  match t:
    case Nil{}: {==}
    case Con{+w, +r}: {==}
