import Base
import ../../spec/tree.bend as TR
import ../../spec/limits.bend as Lim
import ../../spec/fulu_schemas.bend as Spec
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../src/obj.bend as O
import ./obj_support.bend as OS
import ./schema_shapes.bend as SH
import ./ulist_obj.bend as UL
import ./ulist_obj_light.bend as UL_L
import ./blist_obj.bend as BLI
import ./lim_sym.bend as LSY

# BIG (codegen --big): the closed schema facts of BeaconState whose limits are
# 2^24, 2^27 and 2^40, without evaluating a number of that size. Each fact is
# proved for a symbolic depth d (a limit 2^(c + d)) and instantiated at the
# field's depth; the schema literal's limit (a U32 literal, or 2^30 * 1024) is
# turned into TR.capacity(k) through equations between words (lim_sym
# pw_nat) and a symbolic product. Like lim_bl.bend this needs a checker
# that compares syntactically identical terms without normalizing them
# (bendlang/bend#1075); stock Bend 2.0.28 evaluates them in unary.

# ---- powers of two ------------------------------------------------------------

def pow24() -> {U32.to_nat(16777216) == TR.capacity(24n) : Nat}:
  Equal.trans(Nat, U32.to_nat(16777216), Word.to_nat(32n, LSY.pw(24n, 32n)), TR.capacity(24n),
    Equal.trans(Nat, U32.to_nat(16777216), U32.to_nat(U32{LSY.pw(24n, 32n)}), Word.to_nat(32n, LSY.pw(24n, 32n)),
      Equal.cong(U32, Nat, x => U32.to_nat(x), 16777216, U32{LSY.pw(24n, 32n)}, {==}),
      LSY.u32_word(LSY.pw(24n, 32n))),
    LSY.pw_nat(24n, 7n))

def pow27() -> {U32.to_nat(134217728) == TR.capacity(27n) : Nat}:
  Equal.trans(Nat, U32.to_nat(134217728), Word.to_nat(32n, LSY.pw(27n, 32n)), TR.capacity(27n),
    Equal.trans(Nat, U32.to_nat(134217728), U32.to_nat(U32{LSY.pw(27n, 32n)}), Word.to_nat(32n, LSY.pw(27n, 32n)),
      Equal.cong(U32, Nat, x => U32.to_nat(x), 134217728, U32{LSY.pw(27n, 32n)}, {==}),
      LSY.u32_word(LSY.pw(27n, 32n))),
    LSY.pw_nat(27n, 4n))

# ten doublings: 1024 x
def d10(x: Nat) -> Nat: Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(x))))))))))

law m10:
  for +x: Nat
  {d10(x) == Nat.mul(x, 1024n) : Nat}
def m10(x):
  match x:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, d10(p), Nat.mul(p, 1024n), m10(p)) : {1024n+_ == Nat.add(1024n, Nat.mul(p, 1024n)) : Nat}
      {==}

# 2^d * 1024 = 2^(10 + d), for a symbolic d.
law m1024:
  for +d: Nat
  {Nat.mul(TR.capacity(d), 1024n) == TR.capacity(Nat.add(10n, d)) : Nat}
def m1024(d):
  Equal.trans(Nat, Nat.mul(TR.capacity(d), 1024n), d10(TR.capacity(d)), TR.capacity(Nat.add(10n, d)),
    Equal.sym(Nat, d10(TR.capacity(d)), Nat.mul(TR.capacity(d), 1024n), m10(TR.capacity(d))), {==})

# The 2^40 limit of the Fulu schemas (VALIDATOR_REGISTRY_LIMIT).
def pow40() -> {Nat.mul(U32.to_nat(1073741824), 1024n) == TR.capacity(40n) : Nat}:
  %Equal.sym(Nat, U32.to_nat(1073741824), TR.capacity(30n), LSY.pow30()) : {Nat.mul(_, 1024n) == TR.capacity(40n) : Nat}
  %Equal.sym(Nat, TR.capacity(40n), TR.capacity(Nat.add(10n, 30n)), {==}) : {Nat.mul(TR.capacity(30n), 1024n) == _ : Nat}
  m1024(30n)

# ---- the facts at a symbolic depth ----------------------------------------------

# A list of limit 2^d: minimal at depth d.
law lim_okp:
  for +E: S.Schema
  for +d: Nat
  {Lim.minimal(SH.ListOf_limit(S.ListOf{E, TR.capacity(d)}), d) == True{} : Bool}
def lim_okp(E, d): LSY.min_cap(d)

# List[Bytes32, 2^d]: its limit 2^d is minimal at depth d.
law lh_okp:
  for +d: Nat
  {BLI.ok_lh(S.ListOf{S.ByteVector{32n}, TR.capacity(d)}, d) == True{} : Bool}
def lh_okp(d): LSY.min_cap(d)

# List[uint64, 2^(2 + d)]: 2^(5 + d) bytes, 2^d chunks, minimal at depth d.
law ul_okp:
  for +d: Nat
  {UL_L.ok_ul(S.ListOf{S.Unsigned{P.U64{}}, TR.capacity(Nat.add(2n, d))}, d) == True{} : Bool}
def ul_okp(d):
  %Equal.sym(Nat, Nat.mul(TR.capacity(Nat.add(2n, d)), 8n), O.e8(TR.capacity(Nat.add(2n, d))), Equal.sym(Nat, O.e8(TR.capacity(Nat.add(2n, d))), Nat.mul(TR.capacity(Nat.add(2n, d)), 8n), UL.e8_mul(TR.capacity(Nat.add(2n, d))))) :
    {Lim.minimal(Nat.div(Nat.add(_, 31n), 32n), d) == True{} : Bool}
  LSY.mcl(d)

# List[uint8, 2^(5 + d)]: 2^d chunks, minimal at depth d.
law l1_okp:
  for +d: Nat
  {BLI.ok_l1(S.ListOf{S.Unsigned{P.U8{}}, TR.capacity(Nat.add(5n, d))}, d) == True{} : Bool}
def l1_okp(d):
  %Equal.sym(Nat, Nat.mul(TR.capacity(Nat.add(5n, d)), 1n), TR.capacity(Nat.add(5n, d)), BLI.mul1(TR.capacity(Nat.add(5n, d)))) :
    {Lim.minimal(Nat.div(Nat.add(_, 31n), 32n), d) == True{} : Bool}
  LSY.mcl(d)

# ---- the BeaconState fields -----------------------------------------------------

# historical_roots: List[Bytes32, 2^24] (Schema76), depth 24.
law hr_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema76() : S.Schema}
  {BLI.ok_lh(s, OS.dv_24(OS.DV0())) == True{} : Bool}
def hr_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema76(), es) : {BLI.ok_lh(_, OS.dv_24(OS.DV0())) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema76(), S.ListOf{S.ByteVector{32n}, U32.to_nat(16777216)}, {==}) : {BLI.ok_lh(_, OS.dv_24(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(16777216), TR.capacity(24n), pow24()) : {BLI.ok_lh(S.ListOf{S.ByteVector{32n}, _}, OS.dv_24(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_24(OS.DV0()), 24n, {==}) : {BLI.ok_lh(S.ListOf{S.ByteVector{32n}, TR.capacity(24n)}, _) == True{} : Bool}
  lh_okp(24n)

# balances, inactivity_scores: List[uint64, 2^40] (Schema79), depth 38.
law bal_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema79() : S.Schema}
  {UL_L.ok_ul(s, OS.dv_38(OS.DV0())) == True{} : Bool}
def bal_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema79(), es) : {UL_L.ok_ul(_, OS.dv_38(OS.DV0())) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema79(), S.ListOf{S.Unsigned{P.U64{}}, Nat.mul(U32.to_nat(1073741824), 1024n)}, {==}) : {UL_L.ok_ul(_, OS.dv_38(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, Nat.mul(U32.to_nat(1073741824), 1024n), TR.capacity(40n), pow40()) : {UL_L.ok_ul(S.ListOf{S.Unsigned{P.U64{}}, _}, OS.dv_38(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_38(OS.DV0()), 38n, {==}) : {UL_L.ok_ul(S.ListOf{S.Unsigned{P.U64{}}, TR.capacity(40n)}, _) == True{} : Bool}
  %Equal.sym(Nat, TR.capacity(40n), TR.capacity(Nat.add(2n, 38n)), {==}) : {UL_L.ok_ul(S.ListOf{S.Unsigned{P.U64{}}, _}, 38n) == True{} : Bool}
  ul_okp(38n)

# previous/current_epoch_participation: List[uint8, 2^40] (Schema82), depth 35.
law part_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema82() : S.Schema}
  {BLI.ok_l1(s, OS.dv_35(OS.DV0())) == True{} : Bool}
def part_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema82(), es) : {BLI.ok_l1(_, OS.dv_35(OS.DV0())) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema82(), S.ListOf{S.Unsigned{P.U8{}}, Nat.mul(U32.to_nat(1073741824), 1024n)}, {==}) : {BLI.ok_l1(_, OS.dv_35(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, Nat.mul(U32.to_nat(1073741824), 1024n), TR.capacity(40n), pow40()) : {BLI.ok_l1(S.ListOf{S.Unsigned{P.U8{}}, _}, OS.dv_35(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_35(OS.DV0()), 35n, {==}) : {BLI.ok_l1(S.ListOf{S.Unsigned{P.U8{}}, TR.capacity(40n)}, _) == True{} : Bool}
  %Equal.sym(Nat, TR.capacity(40n), TR.capacity(Nat.add(5n, 35n)), {==}) : {BLI.ok_l1(S.ListOf{S.Unsigned{P.U8{}}, _}, 35n) == True{} : Bool}
  l1_okp(35n)

# validators: List[..., 2^40] (Schema78), depth 40.
law val_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema78() : S.Schema}
  {Lim.minimal(SH.ListOf_limit(s), OS.dv_40(OS.DV0())) == True{} : Bool}
def val_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema78(), es) : {Lim.minimal(SH.ListOf_limit(_), OS.dv_40(OS.DV0())) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema78(), S.ListOf{Spec.Schema58(), Nat.mul(U32.to_nat(1073741824), 1024n)}, {==}) : {Lim.minimal(SH.ListOf_limit(_), OS.dv_40(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, Nat.mul(U32.to_nat(1073741824), 1024n), TR.capacity(40n), pow40()) : {Lim.minimal(SH.ListOf_limit(S.ListOf{Spec.Schema58(), _}), OS.dv_40(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_40(OS.DV0()), 40n, {==}) : {Lim.minimal(SH.ListOf_limit(S.ListOf{Spec.Schema58(), TR.capacity(40n)}), _) == True{} : Bool}
  lim_okp(Spec.Schema58(), 40n)

# historical_summaries: List[..., 2^24] (Schema84), depth 24.
law hs_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema84() : S.Schema}
  {Lim.minimal(SH.ListOf_limit(s), OS.dv_24(OS.DV0())) == True{} : Bool}
def hs_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema84(), es) : {Lim.minimal(SH.ListOf_limit(_), OS.dv_24(OS.DV0())) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema84(), S.ListOf{Spec.Schema22(), U32.to_nat(16777216)}, {==}) : {Lim.minimal(SH.ListOf_limit(_), OS.dv_24(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(16777216), TR.capacity(24n), pow24()) : {Lim.minimal(SH.ListOf_limit(S.ListOf{Spec.Schema22(), _}), OS.dv_24(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_24(OS.DV0()), 24n, {==}) : {Lim.minimal(SH.ListOf_limit(S.ListOf{Spec.Schema22(), TR.capacity(24n)}), _) == True{} : Bool}
  lim_okp(Spec.Schema22(), 24n)

# pending_deposits: List[..., 2^27] (Schema85), depth 27.
law pd_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema85() : S.Schema}
  {Lim.minimal(SH.ListOf_limit(s), OS.dv_27(OS.DV0())) == True{} : Bool}
def pd_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema85(), es) : {Lim.minimal(SH.ListOf_limit(_), OS.dv_27(OS.DV0())) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema85(), S.ListOf{Spec.Schema51(), U32.to_nat(134217728)}, {==}) : {Lim.minimal(SH.ListOf_limit(_), OS.dv_27(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(134217728), TR.capacity(27n), pow27()) : {Lim.minimal(SH.ListOf_limit(S.ListOf{Spec.Schema51(), _}), OS.dv_27(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_27(OS.DV0()), 27n, {==}) : {Lim.minimal(SH.ListOf_limit(S.ListOf{Spec.Schema51(), TR.capacity(27n)}), _) == True{} : Bool}
  lim_okp(Spec.Schema51(), 27n)

# pending_partial_withdrawals: List[..., 2^27] (Schema86), depth 27.
law ppw_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema86() : S.Schema}
  {Lim.minimal(SH.ListOf_limit(s), OS.dv_27(OS.DV0())) == True{} : Bool}
def ppw_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema86(), es) : {Lim.minimal(SH.ListOf_limit(_), OS.dv_27(OS.DV0())) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema86(), S.ListOf{Spec.Schema19(), U32.to_nat(134217728)}, {==}) : {Lim.minimal(SH.ListOf_limit(_), OS.dv_27(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(134217728), TR.capacity(27n), pow27()) : {Lim.minimal(SH.ListOf_limit(S.ListOf{Spec.Schema19(), _}), OS.dv_27(OS.DV0())) == True{} : Bool}
  %Equal.sym(Nat, OS.dv_27(OS.DV0()), 27n, {==}) : {Lim.minimal(SH.ListOf_limit(S.ListOf{Spec.Schema19(), TR.capacity(27n)}), _) == True{} : Bool}
  lim_okp(Spec.Schema19(), 27n)
