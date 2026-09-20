"""Compose leaf root refinements into the independent relational model.

ByteVector/ByteList use the root-only (ungated) leaf roots merkle_root and the
structural leaf relations of spec/root_relation.bend (root_domain_steps).
"""
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]
lines=['import Base','import ../types/schema.bend as T','import ../src/byte_root.bend as BV','import ../src/byte_list.bend as BL','import ../src/bit_root.bend as B','import ../src/limits.bend as Depth','import ../spec/byte_root.bend as SBV','import ../spec/byte_list.bend as SBL','import ../spec/bit_root.bend as SB','import ../spec/root_relation.bend as S','import ./byte_root.bend as PBV','import ./byte_list.bend as PBL','import ./bit_root.bend as PB','import ./bit_list_root.bend as PBLBits','import ./limits.bend as Limits','import ../spec/root_relation.bend as R','import ./root_domain_steps.bend as Steps','']
rows=[
 ('bytevector','U32','BytesValue','ByteVector','BV.merkle_root(n, xs)','R.bytevector_at_depth(n, depth, xs)','PBV.witness(xs)','PBV.witness_valid(xs)','Steps.bytevector_root_correct(n, xs, depth, minimal)'),
 ('bytelist','U32','BytesValue','ByteList','BL.merkle_root(n, xs)','R.bytelist_at_depth(n, depth, xs)','Depth.depth(SBL.chunk_limit(n))','Limits.depth_minimal(SBL.chunk_limit(n))','Steps.bytelist_root_correct(n, depth, xs, minimal)'),
 ('bitvector','Bool','BitsValue','BitVector','B.bitvector_hash_tree_root(n, xs)','SB.bitvector_at_depth(n, depth, xs)','Depth.depth(B.chunk_limit(n))','PB.selected_depth_is_canonical(n)','PB.bitvector_hash_tree_root_correct(n, xs, depth, minimal)'),
 ('bitlist','Bool','BitsValue','BitList','B.bitlist_hash_tree_root(n, xs)','SB.bitlist_at_depth(n, depth, xs)','Depth.depth(B.chunk_limit(n))','PB.selected_depth_is_canonical(n)','PBLBits.bitlist_root_correct(n, depth, xs, minimal)'),
]
for name,typ,v,s,actual,expected,depth,minimum,refine in rows:
 selected=re.sub(r'\bdepth\b', lambda _: depth, expected)
 proof=re.sub(r'\bminimal\b', lambda _: minimum, re.sub(r'\bdepth\b', lambda _: depth, refine))
 relation=f'S.roots(T.{v}{{xs}}, T.{s}{{n}}, [root])'
 lines.append(f'''law {name}_sound:
  for +n: Nat
  for +xs: +List<{typ}>
  for +root: +List<U32>
  for accepted: {{{actual} == Some{{root}} : Maybe<&2, +List<U32>>}}
  {relation}
def {name}_sound(n, xs, root, accepted):
  ({depth}, ({minimum}, Equal.trans(Maybe<&2, +List<U32>>, {selected}, {actual}, Some{{root}}, Equal.sym(Maybe<&2, +List<U32>>, {actual}, {selected}, {proof}), accepted)))

law {name}_complete:
  for +n: Nat
  for +xs: +List<{typ}>
  for +root: +List<U32>
  for witness: {relation}
  {{{actual} == Some{{root}} : Maybe<&2, +List<U32>>}}
def {name}_complete(n, xs, root, witness):
  (depth, (minimal, encoded)) = witness
  Equal.trans(Maybe<&2, +List<U32>>, {actual}, {expected}, Some{{root}}, {refine}, encoded)
''')
(root/'proofs/root_relation_leaves.bend').write_text('\n'.join(lines))
