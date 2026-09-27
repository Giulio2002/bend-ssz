import Base
import ../compact/found.bend as F
import ./vcont.bend as VCN
import ./vadd.bend as AD
import ./vuw.bend as UW

# A container's fixed-part positions as U32 sums (BeaconState's fixed part runs to 2.7M bytes).
#
# A closed Nat position is unary to the checker, so the region writer (codegen/var_cont_enc.py,
# its U32 mode) never states one: a position is the term U32.to_nat(c) for a U32 constant c, and
# the lengths of the region's pieces are summed into it here, piece by piece, over variables; the
# instances' side conditions (a U32 sum, its carry) are closed U32 terms, evaluated in binary.

# LN(CAT([])) = to_nat(0).
def lnnil() -> {VCN.LN(VCN.CAT([])) == U32.to_nat(0) : Nat}: {==}

# LN(CAT(Con{p, t})) = to_nat(c), for c = sp + ct (no carry), LN(p) = to_nat(sp), LN(CAT(t)) = to_nat(ct).
def lnc(+p: +List<U32>, +t: +List<+List<U32>>, +sp: U32, +ct: U32, +c: U32,
    +ep: {VCN.LN(p) == U32.to_nat(sp) : Nat}, +et: {VCN.LN(VCN.CAT(t)) == U32.to_nat(ct) : Nat},
    +ec: {U32.add(sp, ct) == c : U32}, +hc: {AD.CY(sp, ct) == False{} : Bool})
    -> {VCN.LN(VCN.CAT(Con{p, t})) == U32.to_nat(c) : Nat}:
  +e1 = VCN.len_app(p, VCN.CAT(t))
  +e2 = Equal.cong(Nat, Nat, z => Nat.add(VCN.LN(p), z), VCN.LN(VCN.CAT(t)), U32.to_nat(ct), et)
  +e3 = AD.stpL(sp, ct, c, VCN.LN(p), Equal.sym(Nat, VCN.LN(p), U32.to_nat(sp), ep), ec, hc)
  Equal.trans(Nat, VCN.LN(VCN.CAT(Con{p, t})), Nat.add(VCN.LN(p), VCN.LN(VCN.CAT(t))), U32.to_nat(c), e1,
    Equal.trans(Nat, Nat.add(VCN.LN(p), VCN.LN(VCN.CAT(t))), Nat.add(VCN.LN(p), U32.to_nat(ct)), U32.to_nat(c), e2, e3))

# SUM([]) = to_nat(0).
def sumnil() -> {VCN.SUM([]) == U32.to_nat(0) : Nat}: {==}

# SUM(Con{a, t}) = to_nat(c), for c = sa + ct (no carry), a = to_nat(sa), SUM(t) = to_nat(ct).
def sumc(+a: Nat, +t: List<&2, Nat>, +sa: U32, +ct: U32, +c: U32,
    +ea: {a == U32.to_nat(sa) : Nat}, +et: {VCN.SUM(t) == U32.to_nat(ct) : Nat},
    +ec: {U32.add(sa, ct) == c : U32}, +hc: {AD.CY(sa, ct) == False{} : Bool})
    -> {VCN.SUM(Con{a, t}) == U32.to_nat(c) : Nat}:
  +e2 = Equal.cong(Nat, Nat, z => Nat.add(a, z), VCN.SUM(t), U32.to_nat(ct), et)
  +e3 = AD.stpL(sa, ct, c, a, Equal.sym(Nat, a, U32.to_nat(sa), ea), ec, hc)
  Equal.trans(Nat, VCN.SUM(Con{a, t}), Nat.add(a, U32.to_nat(ct)), U32.to_nat(c), e2, e3)

# The first variable field's offset: SUM([]) + x = x.
def snil(+x: Nat) -> {Nat.add(VCN.SUM([]), x) == x : Nat}: {==}

# A piece of k (small) zero bytes, or of k bytes by LNPC, at the U32 k.
def lnzb(+k: Nat, +u: U32, +e: {k == U32.to_nat(u) : Nat}) -> {VCN.LN(UW.ZB(k)) == U32.to_nat(u) : Nat}:
  Equal.trans(Nat, VCN.LN(UW.ZB(k)), k, U32.to_nat(u), UW.len_zb(k), e)
def lnpc(+k: Nat, +xs: +List<U32>, +u: U32, +e: {k == U32.to_nat(u) : Nat}) -> {VCN.LN(VCN.PC(k, xs)) == U32.to_nat(u) : Nat}:
  Equal.trans(Nat, VCN.LN(VCN.PC(k, xs)), k, U32.to_nat(u), VCN.len_pc(k, xs), e)
