import Base
import ./primitive_invariants.bend as V
import ./codec_inverse.bend as Codec
import ../src/tree.bend as I
import ../src/sha256.bend as H
import ../spec/tree.bend as S
import ../spec/merkle.bend as M
import ../spec/packing.bend as Pack
import ../spec/primitives.bend as P
import ../src/primitives.bend as R
import 0xe4067e0d858024083f36a7abe7281e89/spec/crypto/sha.bend as FIPS
import ../HASH_PROOF.bend as Hash
import ./merkle.bend as Nodes
import ./packing.bend as Packing
import ./bytes.bend as B
import ./primitives.bend as Basic

law drop_empty:
  for n: Nat
  {S.drop(n, []) == [] : +List<+List<U32>>}
def drop_empty(n):
  match n:
    case 0n: {==}
    case 1n+p: {==}

law drop_add:
  for +a: Nat
  for +b: Nat
  for +xs: +List<+List<U32>>
  {S.drop(b, S.drop(a, xs)) == S.drop(Nat.add(a, b), xs) : +List<+List<U32>>}
def drop_add(a, b, xs):
  match a:
    case 0n: {==}
    case 1n+p:
      match xs:
        case Nil{}: drop_empty(b)
        case Con{h, t}: drop_add(p, b, t)

law double_add:
  for +n: Nat
  {Nat.double(n) == Nat.add(n, n) : Nat}
def double_add(n):
  match n:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Nat, Nat.add(p, 1n+p), 1n+Nat.add(p, p), Packing.add_succ(p, p)) : {Nat.double(1n+p) == 1n+_ : Nat}
      %double_add(p) : {2n+Nat.double(p) == 2n+_ : Nat}
      {==}

law consume_correct:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  {I.consume(depth, chunks) == (S.tree(depth, chunks), S.drop(S.capacity(depth), chunks)) : (+List<U32> & +List<+List<U32>>)}
def consume_correct(depth, chunks):
  match depth:
    case 0n:
      match chunks:
        case Nil{}: {==}
        case Con{h, t}: {==}
    case 1n+p:
      match chunks:
        case Nil{}:
          %Equal.sym(+List<+List<U32>>, S.drop(S.capacity(1n+p), []), [], drop_empty(S.capacity(1n+p))) :
            {I.consume(1n+p, []) == (M.zero_subtree(1n+p), _) : (+List<U32> & +List<+List<U32>>)}
          %Nodes.zero_hash_correct(1n+p) : {I.consume(1n+p, []) == (_, []) : (+List<U32> & +List<+List<U32>>)}
          {==}
        case Con{h, t}:
          %Equal.sym((+List<U32> & +List<+List<U32>>), I.consume(p, h <> t), (S.tree(p, h <> t), S.drop(S.capacity(p), h <> t)), consume_correct(p, h <> t)) :
            {I.branch(I.consume(p), _) == (S.tree(1n+p, h <> t), S.drop(S.capacity(1n+p), h <> t)) : (+List<U32> & +List<+List<U32>>)}
          %Equal.sym((+List<U32> & +List<+List<U32>>), I.consume(p, S.drop(S.capacity(p), h <> t)), (S.tree(p, S.drop(S.capacity(p), h <> t)), S.drop(S.capacity(p), S.drop(S.capacity(p), h <> t))), consume_correct(p, S.drop(S.capacity(p), h <> t))) :
            {I.joined(S.tree(p, h <> t), _) == (S.tree(1n+p, h <> t), S.drop(S.capacity(1n+p), h <> t)) : (+List<U32> & +List<+List<U32>>)}
          %Hash.hash_refines_fips(List.append(&2, U32, S.tree(p, h <> t), S.tree(p, S.drop(S.capacity(p), h <> t)))) :
            {(H.hash(List.append(&2, U32, S.tree(p, h <> t), S.tree(p, S.drop(S.capacity(p), h <> t)))), S.drop(S.capacity(p), S.drop(S.capacity(p), h <> t))) == (_, S.drop(S.capacity(1n+p), h <> t)) : (+List<U32> & +List<+List<U32>>)}
          %Equal.sym(Nat, Nat.double(S.capacity(p)), Nat.add(S.capacity(p), S.capacity(p)), double_add(S.capacity(p))) :
            {(H.hash(List.append(&2, U32, S.tree(p, h <> t), S.tree(p, S.drop(S.capacity(p), h <> t)))), S.drop(S.capacity(p), S.drop(S.capacity(p), h <> t))) == (H.hash(List.append(&2, U32, S.tree(p, h <> t), S.tree(p, S.drop(S.capacity(p), h <> t)))), S.drop(_, h <> t)) : (+List<U32> & +List<+List<U32>>)}
          %drop_add(S.capacity(p), S.capacity(p), h <> t) :
            {(H.hash(List.append(&2, U32, S.tree(p, h <> t), S.tree(p, S.drop(S.capacity(p), h <> t)))), S.drop(S.capacity(p), S.drop(S.capacity(p), h <> t))) == (H.hash(List.append(&2, U32, S.tree(p, h <> t), S.tree(p, S.drop(S.capacity(p), h <> t)))), _) : (+List<U32> & +List<+List<U32>>)}
          {==}

law finish_drop:
  for +n: Nat
  for +chunks: +List<+List<U32>>
  for +root: +List<U32>
  {I.finish((root, S.drop(n, chunks))) == P.optional(Nat.is_le(List.length(&2, +List<U32>, chunks), n), root) : Maybe<&2, +List<U32>>}
def finish_drop(n, chunks, root):
  match n:
    case 0n:
      match chunks:
        case Nil{}: {==}
        case Con{h, t}: {==}
    case 1n+p:
      match chunks:
        case Nil{}: {==}
        case Con{h, t}: finish_drop(p, t, root)

law optional_tree:
  for ok: Bool
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  {P.optional(ok, S.tree(depth, chunks)) == S.checked(ok, depth, chunks) : Maybe<&2, +List<U32>>}
def optional_tree(ok, depth, chunks):
  match ok:
    case False{}: {==}
    case True{}: {==}

law checked_correct:
  for +ok: Bool
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  {I.checked(ok, depth, chunks) == S.checked(Bool.and(ok, Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth))), depth, chunks) : Maybe<&2, +List<U32>>}
def checked_correct(ok, depth, chunks):
  match ok:
    case False{}: {==}
    case True{}:
      %Equal.sym((+List<U32> & +List<+List<U32>>), I.consume(depth, chunks), (S.tree(depth, chunks), S.drop(S.capacity(depth), chunks)), consume_correct(depth, chunks)) :
        {I.finish(_) == S.checked(Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth)), depth, chunks) : Maybe<&2, +List<U32>>}
      %optional_tree(Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth)), depth, chunks) :
        {I.finish((S.tree(depth, chunks), S.drop(S.capacity(depth), chunks))) == _ : Maybe<&2, +List<U32>>}
      finish_drop(S.capacity(depth), chunks, S.tree(depth, chunks))

law valid_go_correct:
  for +chunks: +List<+List<U32>>
  for +ok: Bool
  {I.valid_go(chunks, ok) == Bool.and(ok, Pack.chunks_domain(chunks)) : Bool}
def valid_go_correct(chunks, ok):
  match chunks:
    case Nil{}: Equal.sym(Bool, Bool.and(ok, True{}), ok, B.and_identity(ok))
    case Con{h, t}:
      %Basic.byte_scope_correct(32n, h) :
        {I.valid_go(t, Bool.and(ok, R.valid_bytes(32n, h))) == Bool.and(ok, Bool.and(_, Pack.chunks_domain(t))) : Bool}
      %B.and_associative(ok, R.valid_bytes(32n, h), Pack.chunks_domain(t)) :
        {I.valid_go(t, Bool.and(ok, R.valid_bytes(32n, h))) == _ : Bool}
      valid_go_correct(t, Bool.and(ok, R.valid_bytes(32n, h)))

law merkleize_at_depth_correct:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  {I.merkleize_at_depth(depth, chunks) == S.merkleize_at_depth(depth, chunks) : Maybe<&2, +List<U32>>}
def merkleize_at_depth_correct(depth, chunks):
  %valid_go_correct(chunks, True{}) :
    {I.merkleize_at_depth(depth, chunks) == S.checked(Bool.and(_, Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth))), depth, chunks) : Maybe<&2, +List<U32>>}
  checked_correct(I.valid_go(chunks, True{}), depth, chunks)

law checked_acceptance:
  for +ok: Bool
  for depth: Nat
  for chunks: +List<+List<U32>>
  {R.is_some(S.checked(ok, depth, chunks)) == ok : Bool}
def checked_acceptance(ok, depth, chunks):
  match ok:
    case False{}: {==}
    case True{}: {==}

law merkleize_at_depth_rejection:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  {R.is_some(I.merkleize_at_depth(depth, chunks)) == Bool.and(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth))) : Bool}
def merkleize_at_depth_rejection(depth, chunks):
  %Equal.sym(Maybe<&2, +List<U32>>, I.merkleize_at_depth(depth, chunks), S.merkleize_at_depth(depth, chunks), merkleize_at_depth_correct(depth, chunks)) :
    {R.is_some(_) == Bool.and(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth))) : Bool}
  checked_acceptance(Bool.and(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth))), depth, chunks)

law fips_scope:
  for +xs: +List<U32>
  {P.byte_scope(32n, FIPS.sha256_bytes(xs)) == True{} : Bool}
def fips_scope(xs):
  %Hash.hash_refines_fips(xs) : {P.byte_scope(32n, _) == True{} : Bool}
  Packing.scope_from_size(H.hash(xs), 32n, Hash.hash_length(xs), Nodes.runtime_hash_bytes(xs))

law zero_scope:
  for +depth: Nat
  {P.byte_scope(32n, M.zero_subtree(depth)) == True{} : Bool}
def zero_scope(depth):
  %Nodes.zero_hash_correct(depth) : {P.byte_scope(32n, _) == True{} : Bool}
  Nodes.zero_hash_chunk(depth)

law tree_scope:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  for e: {Pack.chunks_domain(chunks) == True{} : Bool}
  {P.byte_scope(32n, S.tree(depth, chunks)) == True{} : Bool}
def tree_scope(depth, chunks, e):
  match depth:
    case 0n:
      match chunks:
        case Nil{}: {==}
        case Con{h, t}: V.and_left(P.byte_scope(32n, h), Pack.chunks_domain(t), e)
    case 1n+p:
      match chunks:
        case Nil{}: zero_scope(1n+p)
        case Con{h, t}: fips_scope(List.append(&2, U32, S.tree(p, h <> t), S.tree(p, S.drop(S.capacity(p), h <> t))))

def result_scope(result: Maybe<&2, +List<U32>>) -> Type:
  match result:
    case None{}: Unit
    case Some{root}: {P.byte_scope(32n, root) == True{} : Bool}

law checked_scope:
  for +ok: Bool
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  for e: {ok == Bool.and(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth))) : Bool}
  result_scope(S.checked(ok, depth, chunks))
def checked_scope(ok, depth, chunks, e):
  match ok:
    case False{}: Unit{}
    case True{}:
      tree_scope(depth, chunks, V.and_left(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth)), Equal.sym(Bool, True{}, Bool.and(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth))), e)))

law merkleize_at_depth_scope:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  result_scope(I.merkleize_at_depth(depth, chunks))
def merkleize_at_depth_scope(depth, chunks):
  %Equal.sym(Maybe<&2, +List<U32>>, I.merkleize_at_depth(depth, chunks), S.merkleize_at_depth(depth, chunks), merkleize_at_depth_correct(depth, chunks)) : result_scope(_)
  checked_scope(Bool.and(Pack.chunks_domain(chunks), Nat.is_le(List.length(&2, +List<U32>, chunks), S.capacity(depth))), depth, chunks, {==})

law result_length:
  for +r: Maybe<&2, +List<U32>>
  for e: result_scope(r)
  {Basic.lengths(r) == Basic.expected_root_length(r) : Maybe<&2, Nat>}
def result_length(r, e):
  match r:
    case None{}: {==}
    case Some{root}:
      Equal.cong(Nat, Maybe<&2, Nat>, n => Some{n}, List.length(&2, U32, root), 32n, Codec.scope_length(32n, root, e))

law merkleize_at_depth_length:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  {Basic.lengths(I.merkleize_at_depth(depth, chunks)) == Basic.expected_root_length(I.merkleize_at_depth(depth, chunks)) : Maybe<&2, Nat>}
def merkleize_at_depth_length(depth, chunks): result_length(I.merkleize_at_depth(depth, chunks), merkleize_at_depth_scope(depth, chunks))
