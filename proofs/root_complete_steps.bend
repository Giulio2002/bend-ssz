import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
import ../src/root.bend as IR
import ../src/cached_tree.bend as Cache
import ../src/bit_root.bend as IBits
import ../src/nat_bytes.bend as ILen
import ../src/primitives.bend as IP
import ../src/packing.bend as IPack
import ../src/mixing.bend as IMixing
import ../src/bit_packing.bend as IBitPack
import ../spec/root_relation.bend as R
import ../spec/bit_root.bend as SBits
import ../spec/nat_bytes.bend as SLen
import ../spec/progressive.bend as SProgressive
import ../spec/primitives.bend as SP
import ../spec/packing.bend as SPack
import ../spec/mixing.bend as SMixing
import ../spec/bit_packing.bend as SBitPack
import ./root_steps.bend as G
import ./root_relation_merkle.bend as Merkle
import ./root_scope.bend as Scope
import ./basic_root.bend as BasicRoot
import ./bit_packing.bend as BitPackLaws
import ./mixing.bend as MixingLaws
import ./tree.bend as Tree
import ./lists.bend as L
import ./word_facts.bend as W
import ./bit_list_root.bend as BitListRoot
import ./integer_encoding.bend as IntegerRoot
import ./bit_root.bend as BitRoot
import ../src/lists.bend as Lists
import ./packing.bend as Packing
import ../src/schema.bend as IS
import ../types/schema.bend as TT

# Root completeness steps: whenever the independent relation holds, the actual
# root function returns exactly the related roots.
def roots_present(r: Maybe<&2, +List<+List<U32>>>) -> Bool:
  match r:
    case None{}: False{}
    case Some{x}: True{}

law single_complete:
  for +impl: Maybe<&2, +List<U32>>
  for +m: Maybe<&2, +List<U32>>
  for +outs: +List<+List<U32>>
  for +same: {impl == m : Maybe<&2, +List<U32>>}
  for rel: R.single(m, outs)
  {IR.single(impl) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def single_complete(impl, m, outs, same, rel):
  match outs:
    case Nil{}:
      match rel:
    case Con{x, rest}:
      match rest:
        case Nil{}:
          %Equal.sym(Maybe<&2, +List<U32>>, impl, m, same) : {IR.single(_) == Some{[x]} : Maybe<&2, +List<+List<U32>>>}
          %Equal.sym(Maybe<&2, +List<U32>>, m, Some{x}, rel) : {IR.single(_) == Some{[x]} : Maybe<&2, +List<+List<U32>>>}
          {==}
        case Con{a, b}:
          match rel:

law listed:
  for +root: +List<U32>
  for +outs: +List<+List<U32>>
  for +rel: {outs == [root] : +List<+List<U32>>}
  {IR.single(Some{root}) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def listed(root, outs, rel):
  %Equal.sym(+List<+List<U32>>, outs, [root], rel) : {IR.single(Some{root}) == Some{_} : Maybe<&2, +List<+List<U32>>>}
  {==}

law mixed_complete:
  for +root: +List<U32>
  for +length: Maybe<&2, Nat>
  for +outs: +List<+List<U32>>
  for +scope: {SP.byte_scope(32n, root) == True{} : Bool}
  for rel: R.length_mixed(root, length, outs)
  {IR.single(IR.length_mix(Some{root}, length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def mixed_complete(root, length, outs, scope, rel):
  match length:
    case None{}: listed(root, outs, rel)
    case Some{n}: single_complete(IBits.mix_length_bytes(Some{root}, ILen.encode(32n, n)), SBits.mix_length_bytes(Some{root}, SLen.encoding(32n, n)), outs, G.spec_mix_scope(root, n, scope), rel)

law scope_of:
  for +m: Maybe<&2, +List<U32>>
  for +root: +List<U32>
  for scope: Tree.result_scope(m)
  for +same: {m == Some{root} : Maybe<&2, +List<U32>>}
  {SP.byte_scope(32n, root) == True{} : Bool}
def scope_of(m, root, scope, same):
  %same : Tree.result_scope(_)
  scope

law merkle_root:
  for +m: Maybe<&2, +List<U32>>
  for +root: +List<U32>
  for +length: Maybe<&2, Nat>
  for +outs: +List<+List<U32>>
  for +same: {m == Some{root} : Maybe<&2, +List<U32>>}
  for scope: Tree.result_scope(m)
  for mixed: R.length_mixed(root, length, outs)
  {IR.single(IR.length_mix(m, length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def merkle_root(m, root, length, outs, same, scope, mixed):
  %Equal.sym(Maybe<&2, +List<U32>>, m, Some{root}, same) : {IR.single(IR.length_mix(_, length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  mixed_complete(root, length, outs, scope_of(m, root, scope, same), mixed)

law aggregate_tree:
  for +prog: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +length: Maybe<&2, Nat>
  for +size: Nat
  for +outs: +List<+List<U32>>
  for +root: +List<U32>
  for tree: R.tree(prog, limit, chunks, root)
  for mixed: R.length_mixed(root, length, outs)
  {IR.single(IR.length_mix(IR.merkle(Some{chunks}, limit, prog, Cache.zeros(size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def aggregate_tree(prog, limit, chunks, length, size, outs, root, tree, mixed):
  match prog:
    case False{}:
      merkle_root(Cache.merkleize(limit, chunks, Cache.zeros(size)), root, length, outs, Merkle.merkle_complete(limit, chunks, size, root, tree), Scope.merkle_scope(Some{chunks}, limit, False{}, size), mixed)
    case True{}:
      %Equal.sym(Maybe<&2, +List<U32>>, Cache.progressive(chunks, Cache.zeros(size)), SProgressive.merkleize(chunks), Merkle.cached_progressive_correct(chunks, size)) : {IR.single(IR.length_mix(_, length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
      merkle_root(SProgressive.merkleize(chunks), root, length, outs, tree, G.spec_progressive_scope(chunks), mixed)

law aggregate_complete:
  for +prog: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +length: Maybe<&2, Nat>
  for +size: Nat
  for +outs: +List<+List<U32>>
  for rel: R.aggregate(prog, limit, chunks, length, outs)
  {IR.single(IR.length_mix(IR.merkle(Some{chunks}, limit, prog, Cache.zeros(size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def aggregate_complete(prog, limit, chunks, length, size, outs, rel):
  (+root, (tree, mixed)) = rel
  aggregate_tree(prog, limit, chunks, length, size, outs, root, tree, mixed)


law seq_chunks:
  for +size: Maybe<&2, Nat>
  for -enc: Unit -> Maybe<&2, +List<U32>>
  for comp: Unit -> Maybe<&2, +List<+List<U32>>>
  for +spec_enc: Maybe<&2, +List<U32>>
  for composite: +List<+List<U32>> -> Type
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +table_size: Nat
  for +enc_eq: {enc(Unit{}) == spec_enc : Maybe<&2, +List<U32>>}
  for comp_ok: @+chunks: +List<+List<U32>> -> composite(chunks) -> {comp(Unit{}) == Some{chunks} : Maybe<&2, +List<+List<U32>>>}
  for +outs: +List<+List<U32>>
  for +chunks: +List<+List<U32>>
  for chunked: R.sequence_chunks(size, spec_enc, composite, chunks)
  for aggregated: R.aggregate(prog, R.sequence_limit(size, limit), chunks, length, outs)
  {IR.single(IR.length_mix(IR.merkle(IR.choose_chunks(size, enc, comp), IR.count_limit(size, limit), prog, Cache.zeros(table_size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def seq_chunks(size, enc, comp, spec_enc, composite, limit, prog, length, table_size, enc_eq, comp_ok, outs, chunks, chunked, aggregated):
  match size:
    case None{}:
      %Equal.sym(Maybe<&2, +List<+List<U32>>>, comp(Unit{}), Some{chunks}, comp_ok(chunks, chunked)) : {IR.single(IR.length_mix(IR.merkle(_, limit, prog, Cache.zeros(table_size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
      aggregate_complete(prog, limit, chunks, length, table_size, outs, aggregated)
    case Some{w}:
      (+bytes, (encoded, packed)) = chunked
      %Equal.sym(Maybe<&2, +List<U32>>, enc(Unit{}), spec_enc, enc_eq) : {IR.single(IR.length_mix(IR.merkle(IR.packed(_), IR.count_limit(Some{w}, limit), prog, Cache.zeros(table_size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
      %Equal.sym(Maybe<&2, +List<U32>>, spec_enc, Some{bytes}, encoded) : {IR.single(IR.length_mix(IR.merkle(IR.packed(_), IR.count_limit(Some{w}, limit), prog, Cache.zeros(table_size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
      %Equal.sym(Maybe<&2, +List<+List<U32>>>, IPack.pack(bytes), SPack.pack(bytes), Packing.pack_correct(bytes)) : {IR.single(IR.length_mix(IR.merkle(_, IR.count_limit(Some{w}, limit), prog, Cache.zeros(table_size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
      %Equal.sym(Maybe<&2, +List<+List<U32>>>, SPack.pack(bytes), Some{chunks}, packed) : {IR.single(IR.length_mix(IR.merkle(_, IR.count_limit(Some{w}, limit), prog, Cache.zeros(table_size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
      aggregate_complete(prog, IR.count_limit(Some{w}, limit), chunks, length, table_size, outs, aggregated)

law sequence_complete:
  for +size: Maybe<&2, Nat>
  for -enc: Unit -> Maybe<&2, +List<U32>>
  for comp: Unit -> Maybe<&2, +List<+List<U32>>>
  for +spec_enc: Maybe<&2, +List<U32>>
  for composite: +List<+List<U32>> -> Type
  for +limit: Nat
  for +prog: Bool
  for +length: Maybe<&2, Nat>
  for +table_size: Nat
  for +enc_eq: {enc(Unit{}) == spec_enc : Maybe<&2, +List<U32>>}
  for comp_ok: @+chunks: +List<+List<U32>> -> composite(chunks) -> {comp(Unit{}) == Some{chunks} : Maybe<&2, +List<+List<U32>>>}
  for +outs: +List<+List<U32>>
  for rel: R.sequence(size, spec_enc, composite, limit, prog, length, outs)
  {IR.single(IR.length_mix(IR.merkle(IR.choose_chunks(size, enc, comp), IR.count_limit(size, limit), prog, Cache.zeros(table_size)), length)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def sequence_complete(size, enc, comp, spec_enc, composite, limit, prog, length, table_size, enc_eq, comp_ok, outs, rel):
  (+chunks, (chunked, aggregated)) = rel
  seq_chunks(size, enc, comp, spec_enc, composite, limit, prog, length, table_size, enc_eq, comp_ok, outs, chunks, chunked, aggregated)

law container_complete:
  for +names: +List<String>
  for +items: TT.Value
  for +fields: TT.Schema
  for +size: Nat
  for +count: {IS.count(fields) == R.count(fields) : Nat}
  for +outs: +List<+List<U32>>
  for inner: @+chunks: +List<+List<U32>> -> R.roots(items, fields, chunks) -> {IR.roots_go(items, fields, [], Cache.zeros(size)) == Some{chunks} : Maybe<&2, +List<+List<U32>>>}
  for rel: R.roots(TT.Sequence{items}, TT.Container{names, fields}, outs)
  {IR.single(IR.merkle(IR.roots_go(items, fields, [], Cache.zeros(size)), IS.count(fields), False{}, Cache.zeros(size))) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def container_complete(names, items, fields, size, count, outs, inner, rel):
  (+chunks, (children, aggregated)) = rel
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, IR.roots_go(items, fields, [], Cache.zeros(size)), Some{chunks}, inner(chunks, children)) : {IR.single(IR.merkle(_, IS.count(fields), False{}, Cache.zeros(size))) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Nat, IS.count(fields), R.count(fields), count) : {IR.single(IR.merkle(Some{chunks}, _, False{}, Cache.zeros(size))) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  aggregate_complete(False{}, R.count(fields), chunks, None{}, size, outs, aggregated)

law cons_slot:
  for +slot: +List<U32>
  for +tail: +List<+List<U32>>
  for +x: +List<U32>
  for +xs: +List<+List<U32>>
  for +head: {slot == x : +List<U32>}
  for +rest: {tail == xs : +List<+List<U32>>}
  {slot <> tail == x <> xs : +List<+List<U32>>}
def cons_slot(slot, tail, x, xs, head, rest):
  %Equal.sym(+List<U32>, slot, x, head) : {_ <> tail == x <> xs : +List<+List<U32>>}
  %Equal.sym(+List<+List<U32>>, tail, xs, rest) : {x <> _ == x <> xs : +List<+List<U32>>}
  {==}

law placed_unique:
  for +active: +List<Bool>
  for +fields: +List<+List<U32>>
  for +slots: +List<+List<U32>>
  for placed: R.placed(active, fields, slots)
  {slots == IR.active_chunks(active, fields) : +List<+List<U32>>}
def placed_unique(active, fields, slots, placed):
  match active:
    case Nil{}:
      match fields:
        case Nil{}:
          match slots:
            case Nil{}: {==}
            case Con{a, b}:
              match placed:
        case Con{f, fs}:
          match placed:
    case Con{bit, rest}:
      match bit:
        case False{}:
          match fields:
            case Nil{}:
              match slots:
                case Nil{}:
                  match placed:
                case Con{slot, tail}:
                  (zero, others) = placed
                  cons_slot(slot, tail, IP.pad(32n, []), IR.active_chunks(rest, []), Equal.trans(+List<U32>, slot, SP.zero_bytes(32n), IP.pad(32n, []), zero, Equal.sym(+List<U32>, IP.pad(32n, []), SP.zero_bytes(32n), BasicRoot.empty_padding(32n))), placed_unique(rest, [], tail, others))
            case Con{f, fs}:
              match slots:
                case Nil{}:
                  match placed:
                case Con{slot, tail}:
                  (zero, others) = placed
                  cons_slot(slot, tail, IP.pad(32n, []), IR.active_chunks(rest, f <> fs), Equal.trans(+List<U32>, slot, SP.zero_bytes(32n), IP.pad(32n, []), zero, Equal.sym(+List<U32>, IP.pad(32n, []), SP.zero_bytes(32n), BasicRoot.empty_padding(32n))), placed_unique(rest, f <> fs, tail, others))
        case True{}:
          match fields:
            case Nil{}:
              match placed:
            case Con{f, fs}:
              match slots:
                case Nil{}:
                  match placed:
                case Con{slot, tail}:
                  (same, others) = placed
                  cons_slot(slot, tail, f, IR.active_chunks(rest, fs), same, placed_unique(rest, fs, tail, others))


law active_complete:
  for +names: +List<String>
  for +items: TT.Value
  for +fields: TT.Schema
  for +active: +List<Bool>
  for +size: Nat
  for +bound: {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool}
  for +outs: +List<+List<U32>>
  for inner: @+chunks: +List<+List<U32>> -> R.roots(items, fields, chunks) -> {IR.roots_go(items, fields, [], Cache.zeros(size)) == Some{chunks} : Maybe<&2, +List<+List<U32>>>}
  for rel: R.roots(TT.Sequence{items}, TT.ProgressiveContainer{names, fields, active}, outs)
  {IR.active_root(IR.roots_go(items, fields, [], Cache.zeros(size)), active, Cache.zeros(size)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def active_complete(names, items, fields, active, size, bound, outs, inner, rel):
  (+chunks, (children, (+slots, (placed, (+root, (+merkle, mixed)))))) = rel
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, IR.roots_go(items, fields, [], Cache.zeros(size)), Some{chunks}, inner(chunks, children)) : {IR.active_root(_, active, Cache.zeros(size)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  %placed_unique(active, chunks, slots, placed) : {IR.single(IBits.mix_length_bytes(Cache.progressive(_, Cache.zeros(size)), Some{IP.pad(32n, IBitPack.pack(active))})) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Cache.progressive(slots, Cache.zeros(size)), SProgressive.merkleize(slots), Merkle.cached_progressive_correct(slots, size)) : {IR.single(IBits.mix_length_bytes(_, Some{IP.pad(32n, IBitPack.pack(active))})) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Maybe<&2, +List<U32>>, SProgressive.merkleize(slots), Some{root}, merkle) : {IR.single(IBits.mix_length_bytes(_, Some{IP.pad(32n, IBitPack.pack(active))})) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  single_complete(IBits.mix_length_bytes(Some{root}, Some{IP.pad(32n, IBitPack.pack(active))}), SBits.mix_length_bytes(Some{root}, Some{List.append(&2, U32, SBitPack.pack(active), SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active)))))}), outs,
    Equal.trans(Maybe<&2, +List<U32>>, IBits.mix_length_bytes(Some{root}, Some{IP.pad(32n, IBitPack.pack(active))}), SBits.mix_length_bytes(Some{root}, Some{IP.pad(32n, IBitPack.pack(active))}), SBits.mix_length_bytes(Some{root}, Some{List.append(&2, U32, SBitPack.pack(active), SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active)))))}),
      BitListRoot.mix_correct(Some{root}, Some{IP.pad(32n, IBitPack.pack(active))}, scope_of(SProgressive.merkleize(slots), root, G.spec_progressive_scope(slots), merkle), Scope.padded_scope(IBitPack.pack(active), BitPackLaws.pack_bytes(active))),
      Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, x => SBits.mix_length_bytes(Some{root}, Some{x}), IP.pad(32n, IBitPack.pack(active)), List.append(&2, U32, SBitPack.pack(active), SP.zero_bytes(Nat.sub(32n, List.length(&2, U32, SBitPack.pack(active))))), G.pad_active(active, bound))),
    mixed)

law union_complete:
  for +v: TT.Value
  for +selector: U32
  for +found: Maybe<&2, TT.Schema>
  for +size: Nat
  for +outs: +List<+List<U32>>
  for recur: @+s: TT.Schema -> @+same: {found == Some{s} : Maybe<&2, TT.Schema>} -> @+root: +List<U32> -> R.roots(v, s, [root]) -> {IR.roots_go(v, s, [], Cache.zeros(size)) == Some{[root]} : Maybe<&2, +List<+List<U32>>>}
  for rel: R.selected(found, s => G.selected_rel(v, s, selector, outs))
  {IR.with_schema(found, s => IR.selector_mix(IR.unwrap(IR.roots_go(v, s, [], Cache.zeros(size))), selector)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def union_complete(v, selector, found, size, outs, recur, rel):
  match found:
    case None{}:
      match rel:
    case Some{s}:
      (+root, (child, mixed)) = rel
      %Equal.sym(Maybe<&2, +List<+List<U32>>>, IR.roots_go(v, s, [], Cache.zeros(size)), Some{[root]}, recur(s, {==}, root, child)) : {IR.selector_mix(IR.unwrap(_), selector) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
      single_complete(IMixing.mix_in_selector(root, selector), SMixing.mix_in_selector(root, selector), outs, MixingLaws.mix_in_selector_correct(root, selector), mixed)

law boolean_root_eq:
  for +b: Bool
  {Some{IP.boolean_root(b)} == Some{List.append(&2, U32, SP.boolean_encoding(b), SP.zero_bytes(31n))} : Maybe<&2, +List<U32>>}
def boolean_root_eq(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law boolean_complete:
  for +b: Bool
  for +outs: +List<+List<U32>>
  for rel: R.roots(TT.BooleanValue{b}, TT.Boolean{}, outs)
  {Some{[IP.boolean_root(b)]} == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def boolean_complete(b, outs, rel):
  single_complete(Some{IP.boolean_root(b)}, Some{List.append(&2, U32, SP.boolean_encoding(b), SP.zero_bytes(31n))}, outs, boolean_root_eq(b), rel)

law null_complete:
  for +outs: +List<+List<U32>>
  for +rel: {outs == [SP.zero_bytes(32n)] : +List<+List<U32>>}
  {Some{[IP.pad(32n, [])]} == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def null_complete(outs, rel):
  %Equal.sym(+List<+List<U32>>, outs, [SP.zero_bytes(32n)], rel) : {Some{[IP.pad(32n, [])]} == Some{_} : Maybe<&2, +List<+List<U32>>>}
  Equal.cong(+List<U32>, Maybe<&2, +List<+List<U32>>>, x => Some{[x]}, IP.pad(32n, []), SP.zero_bytes(32n), BasicRoot.empty_padding(32n))

law empty_complete:
  for +acc: +List<+List<U32>>
  for +outs: +List<+List<U32>>
  for +rel: {outs == [] : +List<+List<U32>>}
  {Some{List.reverse(&2, +List<U32>, acc)} == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}
def empty_complete(acc, outs, rel):
  %Equal.sym(+List<+List<U32>>, outs, [], rel) : {Some{List.reverse(&2, +List<U32>, acc)} == Some{List.reverse.go(&2, +List<U32>, acc, _)} : Maybe<&2, +List<+List<U32>>>}
  {==}

law progressive_bits_complete:
  for +bits: +List<Bool>
  for +size: Nat
  for +outs: +List<+List<U32>>
  for rel: R.roots(TT.BitsValue{bits}, TT.ProgressiveBits{}, outs)
  {IR.single(IR.length_mix(Cache.progressive(IBits.chunks(bits), Cache.zeros(size)), Some{Lists.length(Bool, bits)})) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
def progressive_bits_complete(bits, size, outs, rel):
  %Equal.sym(+List<+List<U32>>, IBits.chunks(bits), SBits.chunks(bits), BitRoot.chunks_correct(bits)) : {IR.single(IR.length_mix(Cache.progressive(_, Cache.zeros(size)), Some{Lists.length(Bool, bits)})) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(Nat, Lists.length(Bool, bits), List.length(&2, Bool, bits), L.length_correct(Bool, bits)) : {IR.single(IR.length_mix(Cache.progressive(SBits.chunks(bits), Cache.zeros(size)), Some{_})) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
  aggregate_complete(True{}, 0n, SBits.chunks(bits), Some{List.length(&2, Bool, bits)}, size, outs, rel)

law chain_complete:
  for +h: TT.Value
  for +t: TT.Value
  for +s: TT.Schema
  for +rest: TT.Schema
  for +acc: +List<+List<U32>>
  for +size: Nat
  for +outs: +List<+List<U32>>
  for head_ok: @+head: +List<+List<U32>> -> R.roots(h, s, head) -> {IR.roots_go(h, s, [], Cache.zeros(size)) == Some{head} : Maybe<&2, +List<+List<U32>>>}
  for tail_ok: @+prior: +List<+List<U32>> -> @+tail: +List<+List<U32>> -> R.roots(t, rest, tail) -> {IR.roots_go(t, rest, prior, Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, prior, tail)} : Maybe<&2, +List<+List<U32>>>}
  for rel: R.roots(TT.Items{h, t}, TT.Chain{s, rest}, outs)
  {IR.accumulate(IR.roots_go(h, s, [], Cache.zeros(size)), acc, next => IR.roots_go(t, rest, next, Cache.zeros(size))) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}
def chain_complete(h, t, s, rest, acc, size, outs, head_ok, tail_ok, rel):
  (+head, (+tail, (rh, (rt, same)))) = rel
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, IR.roots_go(h, s, [], Cache.zeros(size)), Some{head}, head_ok(head, rh)) : {IR.accumulate(_, acc, next => IR.roots_go(t, rest, next, Cache.zeros(size))) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(+List<+List<U32>>, outs, List.append(&2, +List<U32>, head, tail), same) : {IR.roots_go(t, rest, List.reverse.go(&2, +List<U32>, head, acc), Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, acc, _)} : Maybe<&2, +List<+List<U32>>>}
  %L.reverse_acc(+List<U32>, head, acc, tail) : {IR.roots_go(t, rest, List.reverse.go(&2, +List<U32>, head, acc), Cache.zeros(size)) == Some{_} : Maybe<&2, +List<+List<U32>>>}
  tail_ok(List.reverse.go(&2, +List<U32>, head, acc), tail, rt)

law repeat_complete:
  for +h: TT.Value
  for +t: TT.Value
  for +s: TT.Schema
  for +acc: +List<+List<U32>>
  for +size: Nat
  for +outs: +List<+List<U32>>
  for head_ok: @+head: +List<+List<U32>> -> R.roots(h, s, head) -> {IR.roots_go(h, s, [], Cache.zeros(size)) == Some{head} : Maybe<&2, +List<+List<U32>>>}
  for tail_ok: @+prior: +List<+List<U32>> -> @+tail: +List<+List<U32>> -> R.roots(t, TT.Repeat{s}, tail) -> {IR.roots_go(t, TT.Repeat{s}, prior, Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, prior, tail)} : Maybe<&2, +List<+List<U32>>>}
  for rel: R.roots(TT.Items{h, t}, TT.Repeat{s}, outs)
  {IR.accumulate(IR.roots_go(h, s, [], Cache.zeros(size)), acc, next => IR.roots_go(t, TT.Repeat{s}, next, Cache.zeros(size))) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}
def repeat_complete(h, t, s, acc, size, outs, head_ok, tail_ok, rel):
  (+head, (+tail, (rh, (rt, same)))) = rel
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, IR.roots_go(h, s, [], Cache.zeros(size)), Some{head}, head_ok(head, rh)) : {IR.accumulate(_, acc, next => IR.roots_go(t, TT.Repeat{s}, next, Cache.zeros(size))) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}
  %Equal.sym(+List<+List<U32>>, outs, List.append(&2, +List<U32>, head, tail), same) : {IR.roots_go(t, TT.Repeat{s}, List.reverse.go(&2, +List<U32>, head, acc), Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, acc, _)} : Maybe<&2, +List<+List<U32>>>}
  %L.reverse_acc(+List<U32>, head, acc, tail) : {IR.roots_go(t, TT.Repeat{s}, List.reverse.go(&2, +List<U32>, head, acc), Cache.zeros(size)) == Some{_} : Maybe<&2, +List<+List<U32>>>}
  tail_ok(List.reverse.go(&2, +List<U32>, head, acc), tail, rt)
