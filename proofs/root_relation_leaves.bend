import Base
import ../types/schema.bend as T
import ../src/byte_root.bend as BV
import ../src/byte_list.bend as BL
import ../src/bit_root.bend as B
import ../src/limits.bend as Depth
import ../spec/byte_root.bend as SBV
import ../spec/byte_list.bend as SBL
import ../spec/bit_root.bend as SB
import ../spec/root_relation.bend as S
import ./byte_root.bend as PBV
import ./byte_list.bend as PBL
import ./bit_root.bend as PB
import ./bit_list_root.bend as PBLBits
import ./limits.bend as Limits

law bytevector_sound:
  for +n: Nat
  for +xs: +List<U32>
  for +root: +List<U32>
  for accepted: {BV.hash_tree_root(n, xs) == Some{root} : Maybe<&2, +List<U32>>}
  S.roots(T.BytesValue{xs}, T.ByteVector{n}, [root])
def bytevector_sound(n, xs, root, accepted):
  (PBV.witness(xs), (PBV.witness_valid(xs), Equal.trans(Maybe<&2, +List<U32>>, SBV.at_depth(n, PBV.witness(xs), xs), BV.hash_tree_root(n, xs), Some{root}, Equal.sym(Maybe<&2, +List<U32>>, BV.hash_tree_root(n, xs), SBV.at_depth(n, PBV.witness(xs), xs), PBV.hash_tree_root_correct(n, xs, PBV.witness(xs), PBV.witness_valid(xs))), accepted)))

law bytevector_complete:
  for +n: Nat
  for +xs: +List<U32>
  for +root: +List<U32>
  for witness: S.roots(T.BytesValue{xs}, T.ByteVector{n}, [root])
  {BV.hash_tree_root(n, xs) == Some{root} : Maybe<&2, +List<U32>>}
def bytevector_complete(n, xs, root, witness):
  (depth, (minimal, encoded)) = witness
  Equal.trans(Maybe<&2, +List<U32>>, BV.hash_tree_root(n, xs), SBV.at_depth(n, depth, xs), Some{root}, PBV.hash_tree_root_correct(n, xs, depth, minimal), encoded)

law bytelist_sound:
  for +n: Nat
  for +xs: +List<U32>
  for +root: +List<U32>
  for accepted: {BL.hash_tree_root(n, xs) == Some{root} : Maybe<&2, +List<U32>>}
  S.roots(T.BytesValue{xs}, T.ByteList{n}, [root])
def bytelist_sound(n, xs, root, accepted):
  (Depth.depth(SBL.chunk_limit(n)), (Limits.depth_minimal(SBL.chunk_limit(n)), Equal.trans(Maybe<&2, +List<U32>>, SBL.at_depth(n, Depth.depth(SBL.chunk_limit(n)), xs), BL.hash_tree_root(n, xs), Some{root}, Equal.sym(Maybe<&2, +List<U32>>, BL.hash_tree_root(n, xs), SBL.at_depth(n, Depth.depth(SBL.chunk_limit(n)), xs), PBL.hash_tree_root_correct(n, Depth.depth(SBL.chunk_limit(n)), xs, Limits.depth_minimal(SBL.chunk_limit(n)))), accepted)))

law bytelist_complete:
  for +n: Nat
  for +xs: +List<U32>
  for +root: +List<U32>
  for witness: S.roots(T.BytesValue{xs}, T.ByteList{n}, [root])
  {BL.hash_tree_root(n, xs) == Some{root} : Maybe<&2, +List<U32>>}
def bytelist_complete(n, xs, root, witness):
  (depth, (minimal, encoded)) = witness
  Equal.trans(Maybe<&2, +List<U32>>, BL.hash_tree_root(n, xs), SBL.at_depth(n, depth, xs), Some{root}, PBL.hash_tree_root_correct(n, depth, xs, minimal), encoded)

law bitvector_sound:
  for +n: Nat
  for +xs: +List<Bool>
  for +root: +List<U32>
  for accepted: {B.bitvector_hash_tree_root(n, xs) == Some{root} : Maybe<&2, +List<U32>>}
  S.roots(T.BitsValue{xs}, T.BitVector{n}, [root])
def bitvector_sound(n, xs, root, accepted):
  (Depth.depth(B.chunk_limit(n)), (PB.selected_depth_is_canonical(n), Equal.trans(Maybe<&2, +List<U32>>, SB.bitvector_at_depth(n, Depth.depth(B.chunk_limit(n)), xs), B.bitvector_hash_tree_root(n, xs), Some{root}, Equal.sym(Maybe<&2, +List<U32>>, B.bitvector_hash_tree_root(n, xs), SB.bitvector_at_depth(n, Depth.depth(B.chunk_limit(n)), xs), PB.bitvector_hash_tree_root_correct(n, xs, Depth.depth(B.chunk_limit(n)), PB.selected_depth_is_canonical(n))), accepted)))

law bitvector_complete:
  for +n: Nat
  for +xs: +List<Bool>
  for +root: +List<U32>
  for witness: S.roots(T.BitsValue{xs}, T.BitVector{n}, [root])
  {B.bitvector_hash_tree_root(n, xs) == Some{root} : Maybe<&2, +List<U32>>}
def bitvector_complete(n, xs, root, witness):
  (depth, (minimal, encoded)) = witness
  Equal.trans(Maybe<&2, +List<U32>>, B.bitvector_hash_tree_root(n, xs), SB.bitvector_at_depth(n, depth, xs), Some{root}, PB.bitvector_hash_tree_root_correct(n, xs, depth, minimal), encoded)

law bitlist_sound:
  for +n: Nat
  for +xs: +List<Bool>
  for +root: +List<U32>
  for accepted: {B.bitlist_hash_tree_root(n, xs) == Some{root} : Maybe<&2, +List<U32>>}
  S.roots(T.BitsValue{xs}, T.BitList{n}, [root])
def bitlist_sound(n, xs, root, accepted):
  (Depth.depth(B.chunk_limit(n)), (PB.selected_depth_is_canonical(n), Equal.trans(Maybe<&2, +List<U32>>, SB.bitlist_at_depth(n, Depth.depth(B.chunk_limit(n)), xs), B.bitlist_hash_tree_root(n, xs), Some{root}, Equal.sym(Maybe<&2, +List<U32>>, B.bitlist_hash_tree_root(n, xs), SB.bitlist_at_depth(n, Depth.depth(B.chunk_limit(n)), xs), PBLBits.bitlist_root_correct(n, Depth.depth(B.chunk_limit(n)), xs, PB.selected_depth_is_canonical(n))), accepted)))

law bitlist_complete:
  for +n: Nat
  for +xs: +List<Bool>
  for +root: +List<U32>
  for witness: S.roots(T.BitsValue{xs}, T.BitList{n}, [root])
  {B.bitlist_hash_tree_root(n, xs) == Some{root} : Maybe<&2, +List<U32>>}
def bitlist_complete(n, xs, root, witness):
  (depth, (minimal, encoded)) = witness
  Equal.trans(Maybe<&2, +List<U32>>, B.bitlist_hash_tree_root(n, xs), SB.bitlist_at_depth(n, depth, xs), Some{root}, PBLBits.bitlist_root_correct(n, depth, xs, minimal), encoded)
