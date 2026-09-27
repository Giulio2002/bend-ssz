import Base
import ../compact/found.bend as F
import ./vcont.bend as VCN
import ./vadd.bend as AD
import ./vuw.bend as UW
import ../../types/schema.bend as S
import ../../spec/layout.bend as Layout

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

# a + b = to_nat(c), for c = sa + cb (no carry), a = to_nat(sa), b = to_nat(cb) (a sum written out as Nat.adds).
def addc(+a: Nat, +b: Nat, +sa: U32, +cb: U32, +c: U32, +ea: {a == U32.to_nat(sa) : Nat}, +eb: {b == U32.to_nat(cb) : Nat},
    +ec: {U32.add(sa, cb) == c : U32}, +hc: {AD.CY(sa, cb) == False{} : Bool}) -> {Nat.add(a, b) == U32.to_nat(c) : Nat}:
  +e2 = Equal.cong(Nat, Nat, z => Nat.add(a, z), b, U32.to_nat(cb), eb)
  +e3 = AD.stpL(sa, cb, c, a, Equal.sym(Nat, a, U32.to_nat(sa), ea), ec, hc)
  Equal.trans(Nat, Nat.add(a, b), Nat.add(a, U32.to_nat(cb)), U32.to_nat(c), e2, e3)

def zeroc() -> {0n == U32.to_nat(0) : Nat}: {==}

# A layout's fixed size, part by part, at U32 sums: fixed_size(Con{h, t}) = to_nat(c), c = sh + ct (no carry).
def fsnil() -> {Layout.fixed_size([]) == U32.to_nat(0) : Nat}: {==}
def fsc(+h: S.Part, +t: +List<S.Part>, +sh: U32, +ct: U32, +c: U32,
    +eh: {Layout.slot(h) == U32.to_nat(sh) : Nat}, +et: {Layout.fixed_size(t) == U32.to_nat(ct) : Nat},
    +ec: {U32.add(sh, ct) == c : U32}, +hc: {AD.CY(sh, ct) == False{} : Bool})
    -> {Layout.fixed_size(Con{h, t}) == U32.to_nat(c) : Nat}:
  addc(Layout.slot(h), Layout.fixed_size(t), sh, ct, c, eh, et, ec, hc)
# a fixed part's slot at its size
def slotf(+xs: +List<U32>, +k: Nat, +u: U32, +e: {List.length(&2, U32, xs) == k : Nat}, +eu: {k == U32.to_nat(u) : Nat})
    -> {Layout.slot(S.Fixed{xs}) == U32.to_nat(u) : Nat}:
  Equal.trans(Nat, List.length(&2, U32, xs), k, U32.to_nat(u), e, eu)
