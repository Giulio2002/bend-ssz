import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/limits.bend as Lim
import ../../spec/tree.bend as Tr
import ../../spec/packing.bend as Pack
import ./mtree_defs.bend as MD
import ./mtree_spec.bend as MS
import ./sha_node_generated.bend as SN

# Support for the per-name root laws (proofs/obj/root_*.bend): the chunk lists
# of digests are exact SSZ chunks, and a list of digests aggregates, in the
# independent relational specification (spec/root_relation.bend `aggregate`),
# to the root of the reference tree over it (proofs/obj/mtree_spec.bend).
#
# Every statement keeps its digests abstract; a per-name law instantiates the
# list with digests that are stuck on the object's fields, so the
# specification's SHA-256 is never applied to a concretely shaped message.

law chunks_domain_bytes:
  for +L: List<&2, D.Digest>
  {Pack.chunks_domain(MD.bytes_list(L)) == True{} : Bool}
def chunks_domain_bytes(L):
  match L:
    case Nil{}: {==}
    case Con{+x, +t}:
      %Equal.sym(Bool, SP.byte_scope(32n, D.bytes(x)), True{}, SN.digest_scope(x)) :
        {Bool.and(_, Pack.chunks_domain(MD.bytes_list(t))) == True{} : Bool}
      chunks_domain_bytes(t)

law length_bytes:
  for +L: List<&2, D.Digest>
  {List.length(&2, +List<U32>, MD.bytes_list(L)) == MD.dlen(L) : Nat}
def length_bytes(L):
  match L:
    case Nil{}: {==}
    case Con{+x, +t}:
      %length_bytes(t) : {1n+List.length(&2, +List<U32>, MD.bytes_list(t)) == 1n+_ : Nat}
      {==}

law le_refl:
  for +n: Nat
  {Nat.is_le(n, n) == True{} : Bool}
def le_refl(n):
  match n:
    case 0n: {==}
    case 1n+ +p: le_refl(p)

# The specification's merkleization at a depth of a list of digests that fits.
law at_depth_tree:
  for +limit: Nat
  for +depth: Nat
  for +hl: Nat
  for +L: List<&2, D.Digest>
  for +hd: {Nat.is_lt(depth, 64n) == True{} : Bool}
  for +hlen: {Nat.is_le(MD.dlen(L), limit) == True{} : Bool}
  for +ehl: {hl == 64n : Nat}
  {Lim.at_depth(limit, depth, MD.bytes_list(L)) == Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(L)), hl, L, 0n))} : Maybe<&2, +List<U32>>}
def at_depth_tree(limit, depth, hl, L, hd, hlen, ehl):
  %Equal.sym(Bool, Pack.chunks_domain(MD.bytes_list(L)), True{}, chunks_domain_bytes(L)) :
    {Tr.checked(Bool.and(_, Nat.is_le(List.length(&2, +List<U32>, MD.bytes_list(L)), limit)), depth, MD.bytes_list(L)) == Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(L)), hl, L, 0n))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, List.length(&2, +List<U32>, MD.bytes_list(L)), MD.dlen(L), length_bytes(L)) :
    {Tr.checked(Bool.and(True{}, Nat.is_le(_, limit)), depth, MD.bytes_list(L)) == Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(L)), hl, L, 0n))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_le(MD.dlen(L), limit), True{}, hlen) :
    {Tr.checked(Bool.and(True{}, _), depth, MD.bytes_list(L)) == Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(L)), hl, L, 0n))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(depth, Nat.is_lt(0n, MD.dlen(L)), hl, L, 0n, {==}, hd, ehl) :
    {Some{_} == Some{D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(L)), hl, L, 0n))} : Maybe<&2, +List<U32>>}
  {==}

# A list of digests aggregates (no progressive tree, no length mixed in) to the
# root of the reference tree over it, at any depth that is minimal for the
# limit. `limit` is the number of chunks the schema allows (a container's field
# count, a vector's chunk count, a list's chunk limit).
law aggregate_digests:
  for +limit: Nat
  for +depth: Nat
  for +hl: Nat
  for +L: List<&2, D.Digest>
  for +hd: {Nat.is_lt(depth, 64n) == True{} : Bool}
  for +hmin: {Lim.minimal(limit, depth) == True{} : Bool}
  for +hlen: {Nat.is_le(MD.dlen(L), limit) == True{} : Bool}
  for +ehl: {hl == 64n : Nat}
  RR.aggregate(False{}, limit, MD.bytes_list(L), None{}, [D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(L)), hl, L, 0n))])
def aggregate_digests(limit, depth, hl, L, hd, hmin, hlen, ehl):
  (D.bytes(MD.rtree(depth, Nat.is_lt(0n, MD.dlen(L)), hl, L, 0n)),
    ((depth, (hmin, at_depth_tree(limit, depth, hl, L, hd, hlen, ehl))), {==}))
