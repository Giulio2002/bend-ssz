import Base
import ../../spec/tree.bend as TR
import ../../spec/limits.bend as Lim
import ../../spec/bit_root.bend as Bm
import ../../spec/fulu_schemas.bend as Spec
import ../../types/schema.bend as S
import ./bitlist_obj.bend as BO
import ./words_obj_light.bend as WO
import ./big_lim_sym.bend as LSY
import ./lim_ul.bend as LUL

# The closed schema facts of the 2^17 leaves under root_types' names without
# evaluating the limit in unary (each was about 0.3 s, and every name holding
# one repeated it): Attestation's aggregation_bits (BitList[2^17], Schema38,
# depth 9) and Blob (ByteVector[2^17], Schema107, depth 12). As in lim_ul.bend,
# the limit word is TR.capacity(17) and the fact is proved for a symbolic depth
# d, then instantiated in the exact form of the goal.

# 256 * c, as TR.capacity(8 + d) unfolds to it.
def d8(c: Nat) -> Nat: Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(c))))))))

# Division by 256 of 256c + 255, one block of 256 steps at a time.
law go256:
  for +c: Nat
  for +acc: Nat
  {Nat.divmod.go(Nat.add(d8(c), 255n), 255n, acc, 0n) == (Nat.add(c, acc), 255n) : Nat & Nat}
def go256(c, acc):
  match c:
    case 0n: {==}
    case 1n+p:
      %LSY.add_s(p, acc) : {Nat.divmod.go(Nat.add(d8(1n+p), 255n), 255n, acc, 0n) == (_, 255n) : Nat & Nat}
      go256(p, 1n+acc)

# A bit list of 2^(8+d) bits has 2^d chunks.
law clb:
  for +d: Nat
  {Bm.chunk_limit(TR.capacity(Nat.add(8n, d))) == TR.capacity(d) : Nat}
def clb(d):
  %LSY.add_z(TR.capacity(d)) : {Bm.chunk_limit(TR.capacity(Nat.add(8n, d))) == _ : Nat}
  Equal.cong(Nat & Nat, Nat, x => Nat.div.fin(x), Nat.divmod.go(Nat.add(d8(TR.capacity(d)), 255n), 255n, 0n, 0n), (Nat.add(TR.capacity(d), 0n), 255n), go256(TR.capacity(d), 0n))

# BitList[2^(8+d)] is minimal at depth d.
law bits_okp:
  for +d: Nat
  {BO.ok_bits(S.BitList{TR.capacity(Nat.add(8n, d))}, d) == True{} : Bool}
def bits_okp(d):
  %Equal.sym(Nat, Bm.chunk_limit(TR.capacity(Nat.add(8n, d))), TR.capacity(d), clb(d)) : {Lim.minimal(_, d) == True{} : Bool}
  LSY.min_cap(d)

# ByteVector[2^(5+d)] is minimal at depth d.
law bv_okp:
  for +d: Nat
  {WO.ok_bv(S.ByteVector{TR.capacity(Nat.add(5n, d))}, d) == True{} : Bool}
def bv_okp(d):
  LSY.mcl(d)

law bits_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema38() : S.Schema}
  {BO.ok_bits(s, 9n) == True{} : Bool}
def bits_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema38(), es) : {BO.ok_bits(_, 9n) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema38(), S.BitList{U32.to_nat(131072)}, {==}) : {BO.ok_bits(_, 9n) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(131072), TR.capacity(17n), LUL.pow17()) : {BO.ok_bits(S.BitList{_}, 9n) == True{} : Bool}
  %Equal.sym(Nat, TR.capacity(17n), TR.capacity(Nat.add(8n, 9n)), {==}) : {BO.ok_bits(S.BitList{_}, 9n) == True{} : Bool}
  bits_okp(9n)

law bv_ok_at:
  for +s: S.Schema
  for +es: {s == Spec.Schema107() : S.Schema}
  {WO.ok_bv(s, 12n) == True{} : Bool}
def bv_ok_at(s, es):
  %Equal.sym(S.Schema, s, Spec.Schema107(), es) : {WO.ok_bv(_, 12n) == True{} : Bool}
  %Equal.sym(S.Schema, Spec.Schema107(), S.ByteVector{U32.to_nat(131072)}, {==}) : {WO.ok_bv(_, 12n) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(131072), TR.capacity(17n), LUL.pow17()) : {WO.ok_bv(S.ByteVector{_}, 12n) == True{} : Bool}
  %Equal.sym(Nat, TR.capacity(17n), TR.capacity(Nat.add(5n, 12n)), {==}) : {WO.ok_bv(S.ByteVector{_}, 12n) == True{} : Bool}
  bv_okp(12n)
