import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
import ../src/root.bend as IR
import ../src/cached_tree.bend as Cache
import ../src/bit_root.bend as IBits
import ../src/nat_bytes.bend as ILen
import ../src/limits.bend as ILimits
import ../src/progressive.bend as IProgressive
import ../src/primitives.bend as IP
import ../spec/root_relation.bend as R
import ../spec/bit_root.bend as SBits
import ../spec/nat_bytes.bend as SLen
import ../spec/progressive.bend as SProgressive
import ../spec/primitives.bend as SP
import ./root_relation_merkle.bend as Merkle
import ./bit_list_root.bend as BitListRoot
import ./nat_bytes.bend as Lengths
import ./cached_tree.bend as CacheLaws
import ./limits.bend as LimitLaws
import ./progressive.bend as ProgressiveLaws
import ./tree.bend as Tree
import ./lists.bend as L
import ./word_facts.bend as W
import ../src/codec.bend as IC
import ../spec/codec.bend as SC
import ./root_scope.bend as RootScope
import ./leaf_sizes.bend as Leaf
import ../src/mixing.bend as IMixing
import ../spec/mixing.bend as SMixing
import ./mixing.bend as MixingLaws
import ../spec/type_legality.bend as TL
import ../src/bit_packing.bend as IBitPack
import ../spec/bit_packing.bend as SBitPack
import ./bit_packing.bend as BitPackLaws
import ./nat_order.bend as Order
import ./primitive_invariants.bend as V
import ../src/lists.bend as Lists
import ../src/schema.bend as IS
import ./root_relation_leaves.bend as Leaves
import ./integer_encoding.bend as IntegerRoot
import ./basic_root.bend as BasicRoot
import ./bit_root.bend as BitRoot
import ../src/byte_root.bend as IByteRoot
import ../src/byte_list.bend as IByteList
import ../src/packing.bend as IPack
import ../spec/packing.bend as SPack
import ./packing.bend as Packing

# Relational root soundness views: a successful actual result satisfies the
# independent root relation (spec/root_relation.bend).
def rel_single(P: +List<+List<U32>> -> Type, result: Maybe<&2, +List<+List<U32>>>) -> Type:
  match result:
    case None{}: Unit
    case Some{outs}: P(outs)

law single_rel:
  for +m: Maybe<&2, +List<U32>>
  rel_single(outs => R.single(m, outs), IR.single(m))
def single_rel(m):
  match m:
    case None{}: Unit{}
    case Some{x}: {==}

law spec_mix_scope:
  for +root: +List<U32>
  for +n: Nat
  for scope: {SP.byte_scope(32n, root) == True{} : Bool}
  {IBits.mix_length_bytes(Some{root}, ILen.encode(32n, n)) == SBits.mix_length_bytes(Some{root}, SLen.encoding(32n, n)) : Maybe<&2, +List<U32>>}
def spec_mix_scope(root, n, scope):
  %Lengths.encode_correct(32n, n) : {IBits.mix_length_bytes(Some{root}, ILen.encode(32n, n)) == SBits.mix_length_bytes(Some{root}, _) : Maybe<&2, +List<U32>>}
  BitListRoot.mix_correct(Some{root}, ILen.encode(32n, n), scope, Lengths.length_scope(n))

law mixed_sound:
  for +root: +List<U32>
  for +length: Maybe<&2, Nat>
  for +scope: {SP.byte_scope(32n, root) == True{} : Bool}
  rel_single(outs => R.length_mixed(root, length, outs), IR.single(IR.length_mix(Some{root}, length)))
def mixed_sound(root, length, scope):
  match length:
    case None{}: {==}
    case Some{n}:
      %Equal.sym(Maybe<&2, +List<U32>>, IBits.mix_length_bytes(Some{root}, ILen.encode(32n, n)), SBits.mix_length_bytes(Some{root}, SLen.encoding(32n, n)), spec_mix_scope(root, n, scope)) : rel_single(outs => R.length_mixed(root, Some{n}, outs), IR.single(_))
      single_rel(SBits.mix_length_bytes(Some{root}, SLen.encoding(32n, n)))

law none_mix_bytes:
  for +length: Maybe<&2, +List<U32>>
  {IBits.mix_length_bytes(None{}, length) == None{} : Maybe<&2, +List<U32>>}
def none_mix_bytes(length):
  match length:
    case None{}: {==}
    case Some{xs}: {==}

law none_mix:
  for +length: Maybe<&2, Nat>
  {IR.length_mix(None{}, length) == None{} : Maybe<&2, +List<U32>>}
def none_mix(length):
  match length:
    case None{}: {==}
    case Some{n}: none_mix_bytes(ILen.encode(32n, n))

law aggregate_intro:
  for +prog: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +length: Maybe<&2, Nat>
  for +root: +List<U32>
  for tree: R.tree(prog, limit, chunks, root)
  for +result: Maybe<&2, +List<+List<U32>>>
  for mixed: rel_single(outs => R.length_mixed(root, length, outs), result)
  rel_single(outs => R.aggregate(prog, limit, chunks, length, outs), result)
def aggregate_intro(prog, limit, chunks, length, root, tree, result, mixed):
  match result:
    case None{}: Unit{}
    case Some{outs}: (root, (tree, mixed))

law merkle_result:
  for +prog: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +length: Maybe<&2, Nat>
  for +m: Maybe<&2, +List<U32>>
  for tree: @+root: +List<U32> -> {m == Some{root} : Maybe<&2, +List<U32>>} -> R.tree(prog, limit, chunks, root)
  for scope: Tree.result_scope(m)
  rel_single(outs => R.aggregate(prog, limit, chunks, length, outs), IR.single(IR.length_mix(m, length)))
def merkle_result(prog, limit, chunks, length, m, tree, scope):
  match m:
    case None{}:
      %Equal.sym(Maybe<&2, +List<U32>>, IR.length_mix(None{}, length), None{}, none_mix(length)) : rel_single(outs => R.aggregate(prog, limit, chunks, length, outs), IR.single(_))
      Unit{}
    case Some{root}: aggregate_intro(prog, limit, chunks, length, root, tree(root, {==}), IR.single(IR.length_mix(Some{root}, length)), mixed_sound(root, length, scope))

law spec_progressive_scope:
  for +chunks: +List<+List<U32>>
  Tree.result_scope(SProgressive.merkleize(chunks))
def spec_progressive_scope(chunks):
  %ProgressiveLaws.merkleize_correct(chunks) : Tree.result_scope(_)
  ProgressiveLaws.merkleize_scope(chunks)

law cached_scope:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +size: Nat
  Tree.result_scope(Cache.merkleize(limit, chunks, Cache.zeros(size)))
def cached_scope(limit, chunks, size):
  %Equal.sym(Maybe<&2, +List<U32>>, Cache.merkleize(limit, chunks, Cache.zeros(size)), ILimits.merkleize(limit, chunks), CacheLaws.merkleize_correct(limit, chunks, size)) : Tree.result_scope(_)
  LimitLaws.merkleize_scope(limit, chunks)

law aggregate_sound:
  for +prog: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +length: Maybe<&2, Nat>
  for +size: Nat
  rel_single(outs => R.aggregate(prog, limit, chunks, length, outs), IR.single(IR.length_mix(IR.merkle(Some{chunks}, limit, prog, Cache.zeros(size)), length)))
def aggregate_sound(prog, limit, chunks, length, size):
  match prog:
    case False{}: merkle_result(False{}, limit, chunks, length, Cache.merkleize(limit, chunks, Cache.zeros(size)), root => e => Merkle.accepted_merkle(limit, chunks, size, root, e), cached_scope(limit, chunks, size))
    case True{}:
      %Equal.sym(Maybe<&2, +List<U32>>, Cache.progressive(chunks, Cache.zeros(size)), SProgressive.merkleize(chunks), Merkle.cached_progressive_correct(chunks, size)) : rel_single(outs => R.aggregate(True{}, limit, chunks, length, outs), IR.single(IR.length_mix(_, length)))
      merkle_result(True{}, limit, chunks, length, SProgressive.merkleize(chunks), root => e => e, spec_progressive_scope(chunks))

law sequence_intro:
  for +size: Maybe<&2, Nat>
  for +spec_enc: Maybe<&2, +List<U32>>
  for composite: +List<+List<U32>> -> Type
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +chunks: +List<+List<U32>>
  for chunked: R.sequence_chunks(size, spec_enc, composite, chunks)
  for +result: Maybe<&2, +List<+List<U32>>>
  for aggregated: rel_single(outs => R.aggregate(prog, R.sequence_limit(size, limit), chunks, length, outs), result)
  rel_single(outs => R.sequence(size, spec_enc, composite, limit, prog, length, outs), result)
def sequence_intro(size, spec_enc, composite, limit, prog, length, chunks, chunked, result, aggregated):
  match result:
    case None{}: Unit{}
    case Some{outs}: (chunks, (chunked, aggregated))

law empty_result:
  for P: +List<+List<U32>> -> Type
  for +prog: Bool
  for +limit: Nat
  for +length: Maybe<&2, Nat>
  for +size: Nat
  rel_single(P, IR.single(IR.length_mix(IR.merkle(None{}, limit, prog, Cache.zeros(size)), length)))
def empty_result(P, prog, limit, length, size):
  %Equal.sym(Maybe<&2, +List<U32>>, IR.length_mix(None{}, length), None{}, none_mix(length)) : rel_single(P, IR.single(_))
  Unit{}

law packed_sound:
  for +w: Nat
  for +bytes: +List<U32>
  for composite: +List<+List<U32>> -> Type
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +size: Nat
  for +packed: Maybe<&2, +List<+List<U32>>>
  for +packed_eq: {SPack.pack(bytes) == packed : Maybe<&2, +List<+List<U32>>>}
  rel_single(outs => R.sequence(Some{w}, Some{bytes}, composite, limit, prog, length, outs), IR.single(IR.length_mix(IR.merkle(packed, IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length)))
def packed_sound(w, bytes, composite, limit, prog, length, size, packed, packed_eq):
  match packed:
    case None{}: empty_result(outs => R.sequence(Some{w}, Some{bytes}, composite, limit, prog, length, outs), prog, IR.count_limit(Some{w}, limit), length, size)
    case Some{chunks}: sequence_intro(Some{w}, Some{bytes}, composite, limit, prog, length, chunks, (bytes, ({==}, packed_eq)), IR.single(IR.length_mix(IR.merkle(Some{chunks}, IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length)), aggregate_sound(prog, IR.count_limit(Some{w}, limit), chunks, length, size))

law composite_sound:
  for composite: +List<+List<U32>> -> Type
  for +spec_enc: Maybe<&2, +List<U32>>
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +size: Nat
  for +chunks: Maybe<&2, +List<+List<U32>>>
  for known: rel_single(composite, chunks)
  rel_single(outs => R.sequence(None{}, spec_enc, composite, limit, prog, length, outs), IR.single(IR.length_mix(IR.merkle(chunks, limit, prog, Cache.zeros(size)), length)))
def composite_sound(composite, spec_enc, limit, prog, length, size, chunks, known):
  match chunks:
    case None{}: empty_result(outs => R.sequence(None{}, spec_enc, composite, limit, prog, length, outs), prog, limit, length, size)
    case Some{rs}: sequence_intro(None{}, spec_enc, composite, limit, prog, length, rs, known, IR.single(IR.length_mix(IR.merkle(Some{rs}, limit, prog, Cache.zeros(size)), length)), aggregate_sound(prog, limit, rs, length, size))

law basic_sound:
  for +w: Nat
  for composite: +List<+List<U32>> -> Type
  for +spec_enc: Maybe<&2, +List<U32>>
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +size: Nat
  rel_single(outs => R.sequence(Some{w}, spec_enc, composite, limit, prog, length, outs), IR.single(IR.length_mix(IR.merkle(IR.packed(spec_enc), IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length)))
def basic_sound(w, composite, spec_enc, limit, prog, length, size):
  match spec_enc:
    case None{}: empty_result(outs => R.sequence(Some{w}, None{}, composite, limit, prog, length, outs), prog, IR.count_limit(Some{w}, limit), length, size)
    case Some{bytes}:
      %Equal.sym(Maybe<&2, +List<+List<U32>>>, IPack.pack(bytes), SPack.pack(bytes), Packing.pack_correct(bytes)) : rel_single(outs => R.sequence(Some{w}, Some{bytes}, composite, limit, prog, length, outs), IR.single(IR.length_mix(IR.merkle(_, IR.count_limit(Some{w}, limit), prog, Cache.zeros(size)), length)))
      packed_sound(w, bytes, composite, limit, prog, length, size, SPack.pack(bytes), {==})

law sequence_sound:
  for +size: Maybe<&2, Nat>
  for -enc: Unit -> Maybe<&2, +List<U32>>
  for -comp: Unit -> Maybe<&2, +List<+List<U32>>>
  for +spec_enc: Maybe<&2, +List<U32>>
  for composite: +List<+List<U32>> -> Type
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +table_size: Nat
  for +enc_eq: {enc(Unit{}) == spec_enc : Maybe<&2, +List<U32>>}
  for +comp_result: Maybe<&2, +List<+List<U32>>>
  for +comp_eq: {comp(Unit{}) == comp_result : Maybe<&2, +List<+List<U32>>>}
  for known: rel_single(composite, comp_result)
  rel_single(outs => R.sequence(size, spec_enc, composite, limit, prog, length, outs), IR.single(IR.length_mix(IR.merkle(IR.choose_chunks(size, enc, comp), IR.count_limit(size, limit), prog, Cache.zeros(table_size)), length)))
def sequence_sound(size, enc, comp, spec_enc, composite, limit, prog, length, table_size, enc_eq, comp_result, comp_eq, known):
  match size:
    case None{}:
      %Equal.sym(Maybe<&2, +List<+List<U32>>>, comp(Unit{}), comp_result, comp_eq) : rel_single(outs => R.sequence(None{}, spec_enc, composite, limit, prog, length, outs), IR.single(IR.length_mix(IR.merkle(_, limit, prog, Cache.zeros(table_size)), length)))
      composite_sound(composite, spec_enc, limit, prog, length, table_size, comp_result, known)
    case Some{w}:
      %Equal.sym(Maybe<&2, +List<U32>>, enc(Unit{}), spec_enc, enc_eq) : rel_single(outs => R.sequence(Some{w}, spec_enc, composite, limit, prog, length, outs), IR.single(IR.length_mix(IR.merkle(IR.packed(_), IR.count_limit(Some{w}, limit), prog, Cache.zeros(table_size)), length)))
      basic_sound(w, composite, spec_enc, limit, prog, length, table_size)

# ---------------------------------------------------------------------------
# Leaves.

law leaf_sound:
  for P: +List<+List<U32>> -> Type
  for +m: Maybe<&2, +List<U32>>
  for known: @+root: +List<U32> -> {m == Some{root} : Maybe<&2, +List<U32>>} -> P([root])
  rel_single(P, IR.single(m))
def leaf_sound(P, m, known):
  match m:
    case None{}: Unit{}
    case Some{root}: known(root, {==})

law boolean_sound:
  for +b: Bool
  rel_single(outs => R.roots(T.BooleanValue{b}, T.Boolean{}, outs), Some{[IP.boolean_root(b)]})
def boolean_sound(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law uint_sound:
  for +w: Primitive.Width
  for +v: Primitive.UInt
  rel_single(outs => R.roots(T.UnsignedValue{v}, T.Unsigned{w}, outs), IR.single(IP.uint_root(w, v)))
def uint_sound(w, v):
  %Equal.sym(Maybe<&2, +List<U32>>, IP.uint_root(w, v), SP.uint_hash_tree_root(w, v), IntegerRoot.uint_hash_tree_root_correct(w, v)) : rel_single(outs => R.roots(T.UnsignedValue{v}, T.Unsigned{w}, outs), IR.single(_))
  single_rel(SP.uint_hash_tree_root(w, v))

law null_sound:
  rel_single(outs => R.roots(T.NullValue{}, T.Null{}, outs), Some{[IP.pad(32n, [])]})
def null_sound():
  Equal.cong(+List<U32>, +List<+List<U32>>, x => [x], IP.pad(32n, []), SP.zero_bytes(32n), BasicRoot.empty_padding(32n))

law progressive_bits_sound:
  for +bits: +List<Bool>
  for +size: Nat
  rel_single(outs => R.roots(T.BitsValue{bits}, T.ProgressiveBits{}, outs), IR.single(IR.length_mix(Cache.progressive(IBits.chunks(bits), Cache.zeros(size)), Some{Lists.length(Bool, bits)})))
def progressive_bits_sound(bits, size):
  %Equal.sym(+List<+List<U32>>, IBits.chunks(bits), SBits.chunks(bits), BitRoot.chunks_correct(bits)) : rel_single(outs => R.roots(T.BitsValue{bits}, T.ProgressiveBits{}, outs), IR.single(IR.length_mix(Cache.progressive(_, Cache.zeros(size)), Some{Lists.length(Bool, bits)})))
  %Equal.sym(Nat, Lists.length(Bool, bits), List.length(&2, Bool, bits), L.length_correct(Bool, bits)) : rel_single(outs => R.roots(T.BitsValue{bits}, T.ProgressiveBits{}, outs), IR.single(IR.length_mix(Cache.progressive(SBits.chunks(bits), Cache.zeros(size)), Some{_})))
  aggregate_sound(True{}, 0n, SBits.chunks(bits), Some{List.length(&2, Bool, bits)}, size)

# ---------------------------------------------------------------------------
# Forests: accumulated roots in declaration order.

def forest_sound(value: T.Value, schema: T.Schema, acc: +List<+List<U32>>, result: Maybe<&2, +List<+List<U32>>>) -> Type:
  match result:
    case None{}: Unit
    case Some{outs}: Exists(+List<+List<U32>>, mine => R.roots(value, schema, mine) & {outs == List.reverse.go(&2, +List<U32>, acc, mine) : +List<+List<U32>>})

def sound(value: T.Value, schema: T.Schema, acc: +List<+List<U32>>, result: Maybe<&2, +List<+List<U32>>>) -> Type:
  match schema:
    case T.Chain{h, t}: forest_sound(value, T.Chain{h, t}, acc, result)
    case T.End{}: forest_sound(value, T.End{}, acc, result)
    case T.Repeat{e}: forest_sound(value, T.Repeat{e}, acc, result)
    case _: rel_single(outs => R.roots(value, schema, outs), result)

law empty_sound:
  for +schema: T.Schema
  for +acc: +List<+List<U32>>
  for rel: R.roots(T.EmptyItems{}, schema, [])
  forest_sound(T.EmptyItems{}, schema, acc, Some{List.reverse(&2, +List<U32>, acc)})
def empty_sound(schema, acc, rel): ([], (rel, {==}))

law chain_tail:
  for +h: T.Value
  for +t: T.Value
  for +s: T.Schema
  for +rest: T.Schema
  for +acc: +List<+List<U32>>
  for +hs: +List<+List<U32>>
  for +result: Maybe<&2, +List<+List<U32>>>
  for head: R.roots(h, s, hs)
  for tail: forest_sound(t, rest, List.reverse.go(&2, +List<U32>, hs, acc), result)
  forest_sound(T.Items{h, t}, T.Chain{s, rest}, acc, result)
def chain_tail(h, t, s, rest, acc, hs, result, head, tail):
  match result:
    case None{}: Unit{}
    case Some{outs}:
      (+mt, (rt, same)) = tail
      (List.append(&2, +List<U32>, hs, mt), ((hs, (mt, (head, (rt, {==})))), Equal.trans(+List<+List<U32>>, outs, List.reverse.go(&2, +List<U32>, List.reverse.go(&2, +List<U32>, hs, acc), mt), List.reverse.go(&2, +List<U32>, acc, List.append(&2, +List<U32>, hs, mt)), same, L.reverse_acc(+List<U32>, hs, acc, mt))))

law chain_sound:
  for +h: T.Value
  for +t: T.Value
  for +s: T.Schema
  for +rest: T.Schema
  for +acc: +List<+List<U32>>
  for +hr: Maybe<&2, +List<+List<U32>>>
  for next: +List<+List<U32>> -> Maybe<&2, +List<+List<U32>>>
  for head: rel_single(outs => R.roots(h, s, outs), hr)
  for tail: @+prior: +List<+List<U32>> -> forest_sound(t, rest, prior, next(prior))
  forest_sound(T.Items{h, t}, T.Chain{s, rest}, acc, IR.accumulate(hr, acc, next))
def chain_sound(h, t, s, rest, acc, hr, next, head, tail):
  match hr:
    case None{}: Unit{}
    case Some{hs}: chain_tail(h, t, s, rest, acc, hs, next(List.reverse.go(&2, +List<U32>, hs, acc)), head, tail(List.reverse.go(&2, +List<U32>, hs, acc)))

law repeat_tail:
  for +h: T.Value
  for +t: T.Value
  for +s: T.Schema
  for +acc: +List<+List<U32>>
  for +hs: +List<+List<U32>>
  for +result: Maybe<&2, +List<+List<U32>>>
  for head: R.roots(h, s, hs)
  for tail: forest_sound(t, T.Repeat{s}, List.reverse.go(&2, +List<U32>, hs, acc), result)
  forest_sound(T.Items{h, t}, T.Repeat{s}, acc, result)
def repeat_tail(h, t, s, acc, hs, result, head, tail):
  match result:
    case None{}: Unit{}
    case Some{outs}:
      (+mt, (rt, same)) = tail
      (List.append(&2, +List<U32>, hs, mt), ((hs, (mt, (head, (rt, {==})))), Equal.trans(+List<+List<U32>>, outs, List.reverse.go(&2, +List<U32>, List.reverse.go(&2, +List<U32>, hs, acc), mt), List.reverse.go(&2, +List<U32>, acc, List.append(&2, +List<U32>, hs, mt)), same, L.reverse_acc(+List<U32>, hs, acc, mt))))

law repeat_sound:
  for +h: T.Value
  for +t: T.Value
  for +s: T.Schema
  for +acc: +List<+List<U32>>
  for +hr: Maybe<&2, +List<+List<U32>>>
  for next: +List<+List<U32>> -> Maybe<&2, +List<+List<U32>>>
  for head: rel_single(outs => R.roots(h, s, outs), hr)
  for tail: @+prior: +List<+List<U32>> -> forest_sound(t, T.Repeat{s}, prior, next(prior))
  forest_sound(T.Items{h, t}, T.Repeat{s}, acc, IR.accumulate(hr, acc, next))
def repeat_sound(h, t, s, acc, hr, next, head, tail):
  match hr:
    case None{}: Unit{}
    case Some{hs}: repeat_tail(h, t, s, acc, hs, next(List.reverse.go(&2, +List<U32>, hs, acc)), head, tail(List.reverse.go(&2, +List<U32>, hs, acc)))

# ---------------------------------------------------------------------------
# Containers.

law chunks_rewrite:
  for +items: T.Value
  for +fields: T.Schema
  for +rs: +List<+List<U32>>
  for +mine: +List<+List<U32>>
  for rel: R.roots(items, fields, mine)
  for same: {rs == List.reverse.go(&2, +List<U32>, [], mine) : +List<+List<U32>>}
  R.roots(items, fields, rs)
def chunks_rewrite(items, fields, rs, mine, rel, same):
  %Equal.sym(+List<+List<U32>>, rs, List.reverse.go(&2, +List<U32>, [], mine), same) : R.roots(items, fields, _)
  rel

law container_intro:
  for +names: +List<String>
  for +items: T.Value
  for +fields: T.Schema
  for +rs: +List<+List<U32>>
  for rel: R.roots(items, fields, rs)
  for +result: Maybe<&2, +List<+List<U32>>>
  for aggregated: rel_single(outs => R.aggregate(False{}, R.count(fields), rs, None{}, outs), result)
  rel_single(outs => R.roots(T.Sequence{items}, T.Container{names, fields}, outs), result)
def container_intro(names, items, fields, rs, rel, result, aggregated):
  match result:
    case None{}: Unit{}
    case Some{outs}: (rs, (rel, aggregated))

law container_sound:
  for +names: +List<String>
  for +items: T.Value
  for +fields: T.Schema
  for +size: Nat
  for +count: {IS.count(fields) == R.count(fields) : Nat}
  for +result: Maybe<&2, +List<+List<U32>>>
  for inner: forest_sound(items, fields, [], result)
  rel_single(outs => R.roots(T.Sequence{items}, T.Container{names, fields}, outs), IR.single(IR.merkle(result, IS.count(fields), False{}, Cache.zeros(size))))
def container_sound(names, items, fields, size, count, result, inner):
  match result:
    case None{}: Unit{}
    case Some{rs}:
      (mine, (rel, same)) = inner
      %Equal.sym(Nat, IS.count(fields), R.count(fields), count) : rel_single(outs => R.roots(T.Sequence{items}, T.Container{names, fields}, outs), IR.single(IR.merkle(Some{rs}, _, False{}, Cache.zeros(size))))
      container_intro(names, items, fields, rs, chunks_rewrite(items, fields, rs, mine, rel, same), IR.single(IR.merkle(Some{rs}, R.count(fields), False{}, Cache.zeros(size))), aggregate_sound(False{}, R.count(fields), rs, None{}, size))

# ---------------------------------------------------------------------------
# Unions: the child root and the selector are mixed exactly as specified.

def selected_rel(root_value: T.Value, schema: T.Schema, selector: U32, outs: +List<+List<U32>>) -> Type:
  Exists(+List<U32>, root => R.roots(root_value, schema, [root]) & R.single(SMixing.mix_in_selector(root, selector), outs))

law mix_selected:
  for +v: T.Value
  for +s: T.Schema
  for +selector: U32
  for +root: +List<U32>
  for child: R.roots(v, s, [root])
  for +m: Maybe<&2, +List<U32>>
  rel_single(outs => selected_rel(v, s, selector, outs), IR.single(m)) -> rel_single(outs => selected_rel(v, s, selector, outs), IR.single(m))
def mix_selected(v, s, selector, root, child, m): x => x

law selector_parts:
  for +v: T.Value
  for +s: T.Schema
  for +selector: U32
  for +rs: +List<+List<U32>>
  for known: R.roots(v, s, rs)
  rel_single(outs => selected_rel(v, s, selector, outs), IR.selector_mix(IR.unwrap(Some{rs}), selector))
def selector_parts(v, s, selector, rs, known):
  match rs:
    case Nil{}: Unit{}
    case Con{root, rest}:
      match rest:
        case Nil{}:
          %Equal.sym(Maybe<&2, +List<U32>>, IMixing.mix_in_selector(root, selector), SMixing.mix_in_selector(root, selector), MixingLaws.mix_in_selector_correct(root, selector)) : rel_single(outs => selected_rel(v, s, selector, outs), IR.single(_))
          leaf_sound(outs => selected_rel(v, s, selector, outs), SMixing.mix_in_selector(root, selector), x => e => (root, (known, e)))
        case Con{a, b}: Unit{}

law selector_sound:
  for +v: T.Value
  for +s: T.Schema
  for +selector: U32
  for +result: Maybe<&2, +List<+List<U32>>>
  for known: rel_single(outs => R.roots(v, s, outs), result)
  rel_single(outs => selected_rel(v, s, selector, outs), IR.selector_mix(IR.unwrap(result), selector))
def selector_sound(v, s, selector, result, known):
  match result:
    case None{}: Unit{}
    case Some{rs}: selector_parts(v, s, selector, rs, known)

law union_sound:
  for +v: T.Value
  for +selector: U32
  for +found: Maybe<&2, T.Schema>
  for +size: Nat
  for recur: @+s: T.Schema -> @+same: {found == Some{s} : Maybe<&2, T.Schema>} -> rel_single(outs => R.roots(v, s, outs), IR.roots_go(v, s, [], Cache.zeros(size)))
  rel_single(outs => R.selected(found, s => selected_rel(v, s, selector, outs)), IR.with_schema(found, s => IR.selector_mix(IR.unwrap(IR.roots_go(v, s, [], Cache.zeros(size))), selector)))
def union_sound(v, selector, found, size, recur):
  match found:
    case None{}: Unit{}
    case Some{s}: selector_sound(v, s, selector, IR.roots_go(v, s, [], Cache.zeros(size)), recur(s, {==}))

# ---------------------------------------------------------------------------
# Progressive containers: active-slot placement and active-bit mixing.

def roots_nonempty(xs: +List<+List<U32>>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: True{}

def pred(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: p

law placed_chunks:
  for +active: +List<Bool>
  for +rs: +List<+List<U32>>
  for +count: {TL.active_count(active) == List.length(&2, +List<U32>, rs) : Nat}
  R.placed(active, rs, IR.active_chunks(active, rs))
def placed_chunks(active, rs, count):
  match active:
    case Nil{}:
      match rs:
        case Nil{}: Unit{}
        case Con{h, t}: Empty.absurd(R.placed([], h <> t, []), W.false_true(Equal.cong(Nat, Bool, n => Nat.is_lt(0n, n), 0n, 1n+List.length(&2, +List<U32>, t), count)))
    case Con{bit, rest}:
      match bit:
        case False{}: (BasicRoot.empty_padding(32n), placed_chunks(rest, rs, count))
        case True{}:
          match rs:
            case Nil{}: Empty.absurd(R.placed(True{} <> rest, [], IR.active_chunks(True{} <> rest, [])), W.false_true(Equal.cong(Nat, Bool, n => Nat.is_eq(n, 0n), 1n+TL.active_count(rest), 0n, count)))
            case Con{h, t}: ({==}, placed_chunks(rest, t, Equal.cong(Nat, Nat, n => pred(n), 1n+TL.active_count(rest), 1n+List.length(&2, +List<U32>, t), count)))

law positive_bound:
  for +m: Nat
  for +k: Nat
  for +bound: {Nat.is_le(1n+m, Nat.mul(k, 8n)) == True{} : Bool}
  {Nat.is_le(1n, k) == True{} : Bool}
def positive_bound(m, k, bound):
  match k:
    case 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, W.false_true(bound))
    case 1n+q: Order.zero_le(q)

law byte_count_bound:
  for +n: Nat
  for +k: Nat
  for +bound: {Nat.is_le(n, Nat.mul(k, 8n)) == True{} : Bool}
  {Nat.is_le(SBitPack.byte_count(n), k) == True{} : Bool}
def byte_count_bound(n, k, bound):
  match n:
    case 0n: Order.zero_le(k)
    case 1n: positive_bound(0n, k, bound)
    case 2n: positive_bound(1n, k, bound)
    case 3n: positive_bound(2n, k, bound)
    case 4n: positive_bound(3n, k, bound)
    case 5n: positive_bound(4n, k, bound)
    case 6n: positive_bound(5n, k, bound)
    case 7n: positive_bound(6n, k, bound)
    case 8n+p:
      match k:
        case 0n: Empty.absurd({Nat.is_le(SBitPack.byte_count(8n+p), 0n) == True{} : Bool}, W.false_true(bound))
        case 1n+q: byte_count_bound(p, q, bound)

law add_sub:
  for +a: Nat
  for +b: Nat
  for +le: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.add(a, Nat.sub(b, a)) == b : Nat}
def add_sub(a, b, le):
  match a:
    case 0n:
      match b:
        case 0n: {==}
        case 1n+q: {==}
    case 1n+p:
      match b:
        case 0n: Empty.absurd({Nat.add(1n+p, Nat.sub(0n, 1n+p)) == 0n : Nat}, W.false_true(le))
        case 1n+q: Equal.cong(Nat, Nat, n => 1n+n, Nat.add(p, Nat.sub(q, p)), q, add_sub(p, q, le))

law pack_small:
  for +active: +List<Bool>
  for +bound: {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool}
  {Nat.is_le(List.length(&2, U32, SBitPack.pack(active)), 32n) == True{} : Bool}
def pack_small(active, bound):
  %Equal.sym(Nat, List.length(&2, U32, SBitPack.pack(active)), SBitPack.byte_count(List.length(&2, Bool, active)), Leaf.spec_pack_length(active)) : {Nat.is_le(_, 32n) == True{} : Bool}
  byte_count_bound(List.length(&2, Bool, active), 32n, bound)

law pad_active:
  for +active: +List<Bool>
  for +bound: {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool}
  {IP.pad(32n, IBitPack.pack(active)) == List.append(&2, U32, SBitPack.pack(active), SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active))))) : +List<U32>}
def pad_active(active, bound):
  %Equal.sym(+List<U32>, IBitPack.pack(active), SBitPack.pack(active), BitPackLaws.pack_correct(active)) : {IP.pad(32n, _) == List.append(&2, U32, SBitPack.pack(active), SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active))))) : +List<U32>}
  %add_sub(List.length(&2, U32, SBitPack.pack(active)), 32n, pack_small(active, bound)) : {IP.pad(_, SBitPack.pack(active)) == List.append(&2, U32, SBitPack.pack(active), SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active))))) : +List<U32>}
  BasicRoot.padding_content(SBitPack.pack(active), Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active))))


law active_mix:
  for +names: +List<String>
  for +items: T.Value
  for +fields: T.Schema
  for +active: +List<Bool>
  for +rs: +List<+List<U32>>
  for rel: R.roots(items, fields, rs)
  for placed: R.placed(active, rs, IR.active_chunks(active, rs))
  for +bound: {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool}
  for +m: Maybe<&2, +List<U32>>
  for +merkle: {SProgressive.merkleize(IR.active_chunks(active, rs)) == m : Maybe<&2, +List<U32>>}
  for scope: Tree.result_scope(m)
  rel_single(outs => R.roots(T.Sequence{items}, T.ProgressiveContainer{names, fields, active}, outs), IR.single(IBits.mix_length_bytes(m, Some{IP.pad(32n, IBitPack.pack(active))})))
def active_mix(names, items, fields, active, rs, rel, placed, bound, m, merkle, scope):
  match m:
    case None{}: Unit{}
    case Some{root}:
      %Equal.sym(Maybe<&2, +List<U32>>, IBits.mix_length_bytes(Some{root}, Some{IP.pad(32n, IBitPack.pack(active))}), SBits.mix_length_bytes(Some{root}, Some{IP.pad(32n, IBitPack.pack(active))}), BitListRoot.mix_correct(Some{root}, Some{IP.pad(32n, IBitPack.pack(active))}, scope, RootScope.padded_scope(IBitPack.pack(active), BitPackLaws.pack_bytes(active)))) : rel_single(outs => R.roots(T.Sequence{items}, T.ProgressiveContainer{names, fields, active}, outs), IR.single(_))
      %Equal.sym(+List<U32>, IP.pad(32n, IBitPack.pack(active)), List.append(&2, U32, SBitPack.pack(active), SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active))))), pad_active(active, bound)) : rel_single(outs => R.roots(T.Sequence{items}, T.ProgressiveContainer{names, fields, active}, outs), IR.single(SBits.mix_length_bytes(Some{root}, Some{_})))
      leaf_sound(outs => R.roots(T.Sequence{items}, T.ProgressiveContainer{names, fields, active}, outs), SBits.mix_length_bytes(Some{root}, Some{List.append(&2, U32, SBitPack.pack(active), SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active)))))}), x => e => (rs, (rel, (IR.active_chunks(active, rs), (placed, (root, (merkle, e)))))))

law active_counted:
  for +names: +List<String>
  for +items: T.Value
  for +fields: T.Schema
  for +active: +List<Bool>
  for +size: Nat
  for +bound: {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool}
  for +rs: +List<+List<U32>>
  for counted: {TL.active_count(active) == List.length(&2, +List<U32>, rs) : Nat} & R.roots(items, fields, rs)
  rel_single(outs => R.roots(T.Sequence{items}, T.ProgressiveContainer{names, fields, active}, outs), IR.active_root(Some{rs}, active, Cache.zeros(size)))
def active_counted(names, items, fields, active, size, bound, rs, counted):
  (count, rel) = counted
  %Equal.sym(Maybe<&2, +List<U32>>, Cache.progressive(IR.active_chunks(active, rs), Cache.zeros(size)), SProgressive.merkleize(IR.active_chunks(active, rs)), Merkle.cached_progressive_correct(IR.active_chunks(active, rs), size)) : rel_single(outs => R.roots(T.Sequence{items}, T.ProgressiveContainer{names, fields, active}, outs), IR.single(IBits.mix_length_bytes(_, Some{IP.pad(32n, IBitPack.pack(active))})))
  active_mix(names, items, fields, active, rs, rel, placed_chunks(active, rs, count), bound, SProgressive.merkleize(IR.active_chunks(active, rs)), {==}, spec_progressive_scope(IR.active_chunks(active, rs)))

law active_sound:
  for +names: +List<String>
  for +items: T.Value
  for +fields: T.Schema
  for +active: +List<Bool>
  for +size: Nat
  for +bound: {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool}
  for +result: Maybe<&2, +List<+List<U32>>>
  for inner: forest_sound(items, fields, [], result)
  for count: @+rs: +List<+List<U32>> -> R.roots(items, fields, rs) -> {TL.active_count(active) == List.length(&2, +List<U32>, rs) : Nat} & R.roots(items, fields, rs)
  rel_single(outs => R.roots(T.Sequence{items}, T.ProgressiveContainer{names, fields, active}, outs), IR.active_root(result, active, Cache.zeros(size)))
def active_sound(names, items, fields, active, size, bound, result, inner, count):
  match result:
    case None{}: Unit{}
    case Some{rs}:
      (mine, (rel, same)) = inner
      active_counted(names, items, fields, active, size, bound, rs, count(rs, chunks_rewrite(items, fields, rs, mine, rel, same)))


# ---------------------------------------------------------------------------
# Codec bridge for packed basic sequences.

law unwrap_parts:
  for +ps: +List<T.Part>
  {IC.unwrap(Some{ps}) == SC.bytes(Some{ps}) : Maybe<&2, +List<U32>>}
def unwrap_parts(ps):
  match ps:
    case Nil{}: {==}
    case Con{T.Fixed{xs}, Nil{}}: {==}
    case Con{T.Variable{xs}, Nil{}}: {==}
    case Con{T.Fixed{xs}, Con{a, b}}: {==}
    case Con{T.Variable{xs}, Con{a, b}}: {==}

# ---------------------------------------------------------------------------
# Relation shape: every non-forest root relation has exactly one output.
# Relations are threaded back so affine proofs can be reused.

law unwrap_bytes:
  for +r: Maybe<&2, +List<T.Part>>
  {IC.unwrap(r) == SC.bytes(r) : Maybe<&2, +List<U32>>}
def unwrap_bytes(r):
  match r:
    case None{}: {==}
    case Some{ps}: unwrap_parts(ps)

def one(outs: +List<+List<U32>>) -> Type:
  {List.length(&2, +List<U32>, outs) == 1n : Nat}

law single_one:
  for +m: Maybe<&2, +List<U32>>
  for +outs: +List<+List<U32>>
  for rel: R.single(m, outs)
  one(outs) & R.single(m, outs)
def single_one(m, outs, rel):
  match outs:
    case Nil{}:
      match rel:
    case Con{r, rest}:
      match rest:
        case Nil{}: ({==}, rel)
        case Con{a, b}:
          match rel:

law listed_one:
  for +root: +List<U32>
  for +outs: +List<+List<U32>>
  for +rel: {outs == [root] : +List<+List<U32>>}
  one(outs)
def listed_one(root, outs, rel):
  %Equal.sym(+List<+List<U32>>, outs, [root], rel) : one(_)
  {==}

law listed_pair:
  for +root: +List<U32>
  for +outs: +List<+List<U32>>
  for +rel: {outs == [root] : +List<+List<U32>>}
  one(outs) & {outs == [root] : +List<+List<U32>>}
def listed_pair(root, outs, rel): (listed_one(root, outs, rel), rel)

law mixed_one:
  for +root: +List<U32>
  for +length: Maybe<&2, Nat>
  for +outs: +List<+List<U32>>
  for rel: R.length_mixed(root, length, outs)
  one(outs) & R.length_mixed(root, length, outs)
def mixed_one(root, length, outs, rel):
  match length:
    case None{}: listed_pair(root, outs, rel)
    case Some{n}: single_one(SBits.mix_length_bytes(Some{root}, SLen.encoding(32n, n)), outs, rel)

law aggregate_back:
  for +prog: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +length: Maybe<&2, Nat>
  for +outs: +List<+List<U32>>
  for +root: +List<U32>
  for tree: R.tree(prog, limit, chunks, root)
  for pair: one(outs) & R.length_mixed(root, length, outs)
  one(outs) & R.aggregate(prog, limit, chunks, length, outs)
def aggregate_back(prog, limit, chunks, length, outs, root, tree, pair):
  (size, mixed) = pair
  (size, (root, (tree, mixed)))

law aggregate_one:
  for +prog: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +length: Maybe<&2, Nat>
  for +outs: +List<+List<U32>>
  for rel: R.aggregate(prog, limit, chunks, length, outs)
  one(outs) & R.aggregate(prog, limit, chunks, length, outs)
def aggregate_one(prog, limit, chunks, length, outs, rel):
  (+root, (tree, mixed)) = rel
  aggregate_back(prog, limit, chunks, length, outs, root, tree, mixed_one(root, length, outs, mixed))

