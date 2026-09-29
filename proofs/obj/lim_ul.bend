import Base
import ../../spec/tree.bend as TR
import ../../spec/limits.bend as Lim
import ../../spec/fulu_schemas.bend as Spec
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../src/obj.bend as O
import ./obj_support.bend as OS
import ./ulist_obj.bend as UL
import ./ulist_obj_light.bend as UL_L
import ./lim_sym.bend as LSY

# The closed schema fact of IndexedAttestation's attesting_indices (List[uint64,
# 2^17], Schema45, depth 15) without evaluating its 2^17 limit in unary: the limit
# word is TR.capacity(17) (lim_sym pw_nat), and a list of limit 2^(2 + d)
# uint64 is minimal at depth d for a symbolic d. Used by root_types (and every
# root_* through it) in place of {==} on the whole ok_<Name> check.

# List[uint64, 2^(2 + d)]: 2^(5 + d) bytes, 2^d chunks, minimal at depth d.
law ul_okp:
  for +d: Nat
  {UL_L.ok_ul(S.ListOf{S.Unsigned{P.U64{}}, TR.capacity(Nat.add(2n, d))}, d) == True{} : Bool}
def ul_okp(d):
  %Equal.sym(Nat, Nat.mul(TR.capacity(Nat.add(2n, d)), 8n), O.e8(TR.capacity(Nat.add(2n, d))), Equal.sym(Nat, O.e8(TR.capacity(Nat.add(2n, d))), Nat.mul(TR.capacity(Nat.add(2n, d)), 8n), UL.e8_mul(TR.capacity(Nat.add(2n, d))))) :
    {Lim.minimal(Nat.div(Nat.add(_, 31n), 32n), d) == True{} : Bool}
  LSY.mcl(d)

def pow17() -> {U32.to_nat(131072) == TR.capacity(17n) : Nat}:
  Equal.trans(Nat, U32.to_nat(131072), Word.to_nat(32n, LSY.pw(17n, 32n)), TR.capacity(17n),
    Equal.trans(Nat, U32.to_nat(131072), U32.to_nat(U32{LSY.pw(17n, 32n)}), Word.to_nat(32n, LSY.pw(17n, 32n)),
      Equal.cong(U32, Nat, x => U32.to_nat(x), 131072, U32{LSY.pw(17n, 32n)}, {==}),
      LSY.u32_word(LSY.pw(17n, 32n))),
    LSY.pw_nat(17n, 14n))

law ia_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema45() : S.Schema}
  {UL_L.ok_ul(s, OS.dv_15(OS.DV0())) == True{} : Bool}
def ia_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema45(), es) : {UL_L.ok_ul(_, OS.dv_15(OS.DV0())) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema45(), S.ListOf{S.Unsigned{P.U64{}}, U32.to_nat(131072)}, {==}) : {UL_L.ok_ul(_, OS.dv_15(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(131072), TR.capacity(17n), pow17()) : {UL_L.ok_ul(S.ListOf{S.Unsigned{P.U64{}}, _}, OS.dv_15(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_15(OS.DV0()), 15n, {==}) : {UL_L.ok_ul(S.ListOf{S.Unsigned{P.U64{}}, TR.capacity(17n)}, _) == True{} : Bool}
  %Equal.sym(Nat, TR.capacity(17n), TR.capacity(Nat.add(2n, 15n)), {==}) : {UL_L.ok_ul(S.ListOf{S.Unsigned{P.U64{}}, _}, 15n) == True{} : Bool}
  ul_okp(15n)

# A conjunction from its two facts (the okI lemmas of root_laws_b).
law and_t:
  for +a: Bool
  for +b: Bool
  for +ha: {a == True{} : Bool}
  for +hb: {b == True{} : Bool}
  {Bool.and(a, b) == True{} : Bool}
def and_t(a, b, ha, hb):
  match a:
    case True{}: hb
    case False{}: ha
