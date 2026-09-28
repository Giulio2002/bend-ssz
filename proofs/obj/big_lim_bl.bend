import Base
import ../../spec/tree.bend as TR
import ../../spec/limits.bend as Lim
import ../../spec/byte_list.bend as BL
import ../../spec/fulu_schemas.bend as Spec
import ../../types/schema.bend as S
import ./list_obj_light.bend as LO
import ./obj_support.bend as OS
import ./big_lim_sym.bend as LSY

# BIG (codegen --big): the closed schema facts of the names holding a
# Transaction (ByteList[2^30]), without evaluating a 2^30-sized number. The
# byte-list fact is proved at every depth d for 2^(5+d) bytes
# (proofs/obj/lim_sym.bend) and instantiated at d = 25; containers split their
# conjunction with and_t so only that conjunct needs the lemma. Needs a
# checker that compares syntactically identical terms without normalizing
# them (bendlang/bend#1075); stock Bend 2.0.28 evaluates them in unary.

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

law bl_okp:
  for +d: Nat
  {LO.ok_bl(S.ByteList{TR.capacity(Nat.add(5n, d))}, d) == True{} : Bool}
def bl_okp(d):
  %Equal.sym(Nat, BL.chunk_limit(TR.capacity(Nat.add(5n, d))), TR.capacity(d), LSY.cl(d)) : {Lim.minimal(_, d) == True{} : Bool}
  LSY.min_cap(d)

# Spec.Transaction() is ByteList[2^30]; its chunk limit 2^25 is minimal at depth 25.
def tx_okc() -> {LO.ok_bl(Spec.Transaction(), OS.dv_25(OS.DV0())) == True{} : Bool}:
  %LSY.tx_schema() : {LO.ok_bl(_, OS.dv_25(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(1073741824), TR.capacity(30n), LSY.pow30()) : {LO.ok_bl(S.ByteList{_}, OS.dv_25(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_25(OS.DV0()), 25n, {==}) : {LO.ok_bl(S.ByteList{TR.capacity(30n)}, _) == True{} : Bool}
  %Equal.sym(Nat, TR.capacity(30n), TR.capacity(Nat.add(5n, 25n)), {==}) : {LO.ok_bl(S.ByteList{_}, 25n) == True{} : Bool}
  bl_okp(25n)

# The same fact for any schema equal to Spec.Transaction(), stated in the
# form the root laws' goals take (the schema is the caller's term).
law tx_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Transaction() : S.Schema}
  {LO.ok_bl(s, OS.dv_25(OS.DV0())) == True{} : Bool}
def tx_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Transaction(), es) : {LO.ok_bl(_, OS.dv_25(OS.DV0())) == True{} : Bool}
  tx_okc()
