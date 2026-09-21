import Base
import ./found.bend as F

# U32 arithmetic facts used by the compact runtime proofs, derived from the
# checked word laws in found.bend.
#
# The pinned checker evaluates closed Nat terms in unary, so a statement that
# mentions 2^32 as a closed term (pow2(32n), a literal above 4294967295n) does
# not check. Every bound here is therefore relative: a sum is bounded by the
# value of some other word, and the word laws are proved for a symbolic width
# n and only then applied to U32.

# Generic width: a sum bounded by some n-bit word does not wrap.
def add_le_w(+n: Nat, +x: Word(n), +y: Word(n), +z: Word(n),
    +h: {Nat.is_le(Nat.add(F.u32alg__uw(n, x), F.u32alg__uw(n, y)), F.u32alg__uw(n, z)) == True{} : Bool})
    -> {F.u32alg__uw(n, Word.add(n, x, y)) == Nat.add(F.u32alg__uw(n, x), F.u32alg__uw(n, y)) : Nat}:
  +ux = F.u32alg__uw(n, x)
  +uy = F.u32alg__uw(n, y)
  +us = F.u32alg__uw(n, Word.add(n, x, y))
  +zero = Equal.trans(Nat, Nat.add(Nat.add(ux, uy), F.u32alg__sc(n, 0n)), Nat.add(Nat.add(ux, uy), 0n), Nat.add(ux, uy),
    Equal.cong(Nat, Nat, q => Nat.add(Nat.add(ux, uy), q), F.u32alg__sc(n, 0n), 0n, F.u32alg__sc_zero(n)),
    F.nat__add_zero(Nat.add(ux, uy)))
  +eq = Equal.trans(Nat, Nat.add(us, F.u32alg__sc(n, F.u32alg__cy(n, x, y, False{}))), Nat.add(ux, uy), Nat.add(Nat.add(ux, uy), F.u32alg__sc(n, 0n)),
    F.u32alg__cons(n, x, y), Equal.sym(Nat, Nat.add(Nat.add(ux, uy), F.u32alg__sc(n, 0n)), Nat.add(ux, uy), zero))
  +b1 = F.u32__WB_unsigned(n, Word.add(n, x, y))
  +b2 = F.nat__le_lt_trans(Nat.add(ux, uy), F.u32alg__uw(n, z), F.u32alg__sc(n, 1n), h, F.u32__WB_unsigned(n, z))
  F.u32alg__uniq(n, us, Nat.add(ux, uy), F.u32alg__cy(n, x, y, False{}), 0n, eq, b1, b2)

# U32: a sum bounded by the value of some word does not wrap.
def add_le(+a: U32, +b: U32, +c: U32,
    +h: {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), U32.to_nat(c)) == True{} : Bool})
    -> {U32.to_nat(U32.add(a, b)) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}:
  match a b c:
    case U32{+x} U32{+y} U32{+z}:
      +tx = U32.to_nat(U32{x})
      +ty = U32.to_nat(U32{y})
      +ux = F.u32alg__uw(32n, x)
      +uy = F.u32alg__uw(32n, y)
      # to_nat and the spec's unsigned value agree on every word
      +sum = Equal.trans(Nat, Nat.add(tx, ty), Nat.add(ux, ty), Nat.add(ux, uy),
        Equal.cong(Nat, Nat, q => Nat.add(q, ty), tx, ux, F.u32__to_nat_word(x)),
        Equal.cong(Nat, Nat, q => Nat.add(ux, q), ty, uy, F.u32__to_nat_word(y)))
      +hz = F.logic__subst(Nat, q => {Nat.is_le(q, F.u32alg__uw(32n, z)) == True{} : Bool}, Nat.add(tx, ty), Nat.add(ux, uy), sum,
        F.logic__subst(Nat, q => {Nat.is_le(Nat.add(tx, ty), q) == True{} : Bool}, U32.to_nat(U32{z}), F.u32alg__uw(32n, z), F.u32__to_nat_word(z), h))
      Equal.trans(Nat, U32.to_nat(U32{Word.add(32n, x, y)}), F.u32alg__uw(32n, Word.add(32n, x, y)), Nat.add(tx, ty),
        F.u32__to_nat_word(Word.add(32n, x, y)),
        Equal.trans(Nat, F.u32alg__uw(32n, Word.add(32n, x, y)), Nat.add(ux, uy), Nat.add(tx, ty),
          add_le_w(32n, x, y, z, hz), Equal.sym(Nat, Nat.add(tx, ty), Nat.add(ux, uy), sum)))

# ---- Nat facts about 4x (double of double) ---------------------------------

def quad(+x: Nat) -> Nat: Nat.double(Nat.double(x))

# x <= k + x
def le_skip(+k: Nat, +x: Nat) -> {Nat.is_le(x, Nat.add(k, x)) == True{} : Bool}:
  match k:
    case 0n: F.nat__le_refl(x)
    case 1n+p: F.nat__le_trans(x, Nat.add(p, x), 1n+Nat.add(p, x), le_skip(p, x), F.nat__le_succ(Nat.add(p, x)))

def quad_lt(+u: Nat, +v: Nat, +h: {Nat.is_lt(quad(u), quad(v)) == True{} : Bool}) -> {Nat.is_lt(u, v) == True{} : Bool}:
  F.nat__bit_double_lt(False{}, u, v, F.nat__bit_double_lt(False{}, Nat.double(u), Nat.double(v), h))

def quad_ge(+x: Nat) -> {Nat.is_le(x, quad(x)) == True{} : Bool}:
  F.nat__le_trans(x, Nat.double(x), quad(x), F.nat__double_self_le(x), F.nat__double_self_le(Nat.double(x)))

# X + k == k + X, as a rewrite for small literal k
def add_right(+x: Nat, +k: Nat) -> {Nat.add(x, k) == Nat.add(k, x) : Nat}:
  F.nat__add_comm(x, k)

# An aligned four-byte read at 4r fits a capacity of 4p bytes only if r < p.
def room_aligned(+r: Nat, +p: Nat, +h: {Nat.is_le(Nat.add(quad(r), 4n), quad(p)) == True{} : Bool}) -> {Nat.is_lt(r, p) == True{} : Bool}:
  +h1 = F.logic__subst(Nat, q => {Nat.is_le(q, quad(p)) == True{} : Bool}, Nat.add(quad(r), 4n), 4n+quad(r), add_right(quad(r), 4n), h)
  +h2 = F.nat__le_trans(1n+quad(r), 4n+quad(r), quad(p), le_skip(3n, 1n+quad(r)), h1)
  quad_lt(r, p, F.nat__succ_le_lt(quad(r), quad(p), h2))

# An unaligned four-byte read at 4r + j (j = 1, 2, 3) touches word r + 1.
def room_unaligned(+j: Nat, +r: Nat, +p: Nat, +h: {Nat.is_le(Nat.add(1n+Nat.add(j, quad(r)), 4n), quad(p)) == True{} : Bool}) -> {Nat.is_lt(1n+r, p) == True{} : Bool}:
  +h1 = F.logic__subst(Nat, q => {Nat.is_le(q, quad(p)) == True{} : Bool}, Nat.add(1n+Nat.add(j, quad(r)), 4n), 4n+(1n+Nat.add(j, quad(r))), add_right(1n+Nat.add(j, quad(r)), 4n), h)
  +h2 = F.nat__le_trans(5n+quad(r), 5n+Nat.add(j, quad(r)), quad(p), le_skip(j, quad(r)), h1)
  quad_lt(1n+r, p, F.nat__succ_le_lt(4n+quad(r), quad(p), h2))
