import Base
import ../src/limits.bend as Limits
import ./lists.bend as ListLaws
import ../src/progressive.bend as Progressive
import ../src/lists.bend as Lists
import ../src/sha256.bend as Hash
import ../src/cached_tree.bend as I
import ../src/merkle.bend as M
import ../src/tree.bend as T
import ./packing.bend as Pack

law lookup_empty:
  for n: Nat
  for +original: Nat
  {I.lookup(n, [], original) == M.zero_hash(original) : +List<U32>}
def lookup_empty(n, original):
  match n:
    case 0n: {==}
    case 1n+p: {==}

law built_lookup:
  for +n: Nat
  for +size: Nat
  for +base: Nat
  {I.lookup(n, I.build(size, M.zero_hash(base)), Nat.add(base, n)) == M.zero_hash(Nat.add(base, n)) : +List<U32>}
def built_lookup(n, size, base):
  match n:
    case 0n:
      match size:
        case 0n: Equal.cong(Nat, +List<U32>, d => M.zero_hash(d), base, Nat.add(base, 0n), Equal.sym(Nat, Nat.add(base, 0n), base, Pack.add_zero(base)))
        case 1n+p: Equal.cong(Nat, +List<U32>, d => M.zero_hash(d), base, Nat.add(base, 0n), Equal.sym(Nat, Nat.add(base, 0n), base, Pack.add_zero(base)))
    case 1n+p:
      match size:
        case 0n: lookup_empty(p, Nat.add(base, 1n+p))
        case 1n+k:
          %Equal.sym(Nat, Nat.add(base, 1n+p), 1n+Nat.add(base, p), Pack.add_succ(base, p)) : {I.lookup(p, I.build(k, M.zero_hash(1n+base)), _) == M.zero_hash(_) : +List<U32>}
          built_lookup(p, k, 1n+base)

law zeros_lookup:
  for +n: Nat
  for +size: Nat
  {I.lookup(n, I.zeros(size), n) == M.zero_hash(n) : +List<U32>}
def zeros_lookup(n, size): built_lookup(n, size, 0n)

law branch_correct:
  for +depth: Nat
  for +table: +List<+List<U32>>
  for pair: (+List<U32> & +List<+List<U32>>)
  for recur: @+xs: +List<+List<U32>> -> {I.consume(depth, xs, table) == T.consume(depth, xs) : (+List<U32> & +List<+List<U32>>)}
  {T.branch(rest => I.consume(depth, rest, table), pair) == T.branch(T.consume(depth), pair) : (+List<U32> & +List<+List<U32>>)}
def branch_correct(depth, table, pair, recur):
  (+root, +rest) = pair
  Equal.cong((+List<U32> & +List<+List<U32>>), (+List<U32> & +List<+List<U32>>), next => T.joined(root, next), I.consume(depth, rest, table), T.consume(depth, rest), recur(rest))

law consume_correct:
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  for +size: Nat
  {I.consume(depth, chunks, I.zeros(size)) == T.consume(depth, chunks) : (+List<U32> & +List<+List<U32>>)}
def consume_correct(depth, chunks, size):
  match depth:
    case 0n:
      match chunks:
        case Nil{}: {==}
        case Con{h, t}: {==}
    case 1n+p:
      match chunks:
        case Nil{}: Equal.cong(+List<U32>, (+List<U32> & +List<+List<U32>>), root => (root, []), I.lookup(1n+p, I.zeros(size), 1n+p), M.zero_hash(1n+p), zeros_lookup(1n+p, size))
        case Con{h, t}:
          %Equal.sym((+List<U32> & +List<+List<U32>>), I.consume(p, h <> t, I.zeros(size)), T.consume(p, h <> t), consume_correct(p, h <> t, size)) : {T.branch(rest => I.consume(p, rest, I.zeros(size)), _) == T.consume(1n+p, h <> t) : (+List<U32> & +List<+List<U32>>)}
          branch_correct(p, I.zeros(size), T.consume(p, h <> t), rest => consume_correct(p, rest, size))

law progressive_join:
  for +fuel: Nat
  for +depth: Nat
  for +size: Nat
  for pair: (+List<U32> & +List<+List<U32>>)
  for recur: @+xs: +List<+List<U32>> -> {I.progressive_go(fuel, depth, xs, I.zeros(size)) == Progressive.tree(fuel, depth, xs) : +List<U32>}
  {I.join(pair, rest => I.progressive_go(fuel, depth, rest, I.zeros(size))) == Progressive.join(pair, rest => Progressive.tree(fuel, depth, rest)) : +List<U32>}
def progressive_join(fuel, depth, size, pair, recur):
  (+right, +rest) = pair
  Equal.cong(+List<U32>, +List<U32>, left => Hash.hash(Lists.append(U32, left, right)), I.progressive_go(fuel, depth, rest, I.zeros(size)), Progressive.tree(fuel, depth, rest), recur(rest))

law progressive_go_correct:
  for +fuel: Nat
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  for +size: Nat
  {I.progressive_go(fuel, depth, chunks, I.zeros(size)) == Progressive.tree(fuel, depth, chunks) : +List<U32>}
def progressive_go_correct(fuel, depth, chunks, size):
  match fuel:
    case 0n: {==}
    case 1n+p:
      match chunks:
        case Nil{}: {==}
        case Con{h, t}:
          %Equal.sym((+List<U32> & +List<+List<U32>>), I.consume(depth, h <> t, I.zeros(size)), T.consume(depth, h <> t), consume_correct(depth, h <> t, size)) : {I.join(_, rest => I.progressive_go(p, 2n+depth, rest, I.zeros(size))) == Progressive.tree(1n+p, depth, h <> t) : +List<U32>}
          progressive_join(p, 2n+depth, size, T.consume(depth, h <> t), rest => progressive_go_correct(p, 2n+depth, rest, size))

law progressive_gate_correct:
  for ok: Bool
  for +chunks: +List<+List<U32>>
  for +size: Nat
  {I.progressive_gate(ok, chunks, I.zeros(size)) == Progressive.gate(ok, chunks) : Maybe<&2, +List<U32>>}
def progressive_gate_correct(ok, chunks, size):
  match ok:
    case False{}: {==}
    case True{}: Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, xs => Some{xs}, I.progressive_go(Lists.length(+List<U32>, chunks), 0n, chunks, I.zeros(size)), Progressive.tree(Lists.length(+List<U32>, chunks), 0n, chunks), progressive_go_correct(Lists.length(+List<U32>, chunks), 0n, chunks, size))

law progressive_correct:
  for +chunks: +List<+List<U32>>
  for +size: Nat
  {I.progressive(chunks, I.zeros(size)) == Progressive.merkleize(chunks) : Maybe<&2, +List<U32>>}
def progressive_correct(chunks, size): progressive_gate_correct(T.valid_go(chunks, True{}), chunks, size)

def checked_gate(ok: Bool, valid: Bool, depth: Nat, chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: T.checked(valid, depth, chunks)

law combined_gate_correct:
  for +ok: Bool
  for +valid: Bool
  for +depth: Nat
  for +chunks: +List<+List<U32>>
  for +size: Nat
  {I.gate(Bool.and(valid, ok), depth, chunks, I.zeros(size)) == checked_gate(ok, valid, depth, chunks) : Maybe<&2, +List<U32>>}
def combined_gate_correct(ok, valid, depth, chunks, size):
  match ok valid:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}:
      Equal.cong((+List<U32> & +List<+List<U32>>), Maybe<&2, +List<U32>>, pair => T.finish(pair), I.consume(depth, chunks, I.zeros(size)), T.consume(depth, chunks), consume_correct(depth, chunks, size))

law limit_gate_correct:
  for +ok: Bool
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  {checked_gate(ok, T.valid_go(chunks, True{}), Limits.depth(limit), chunks) == Limits.gate(ok, limit, chunks) : Maybe<&2, +List<U32>>}
def limit_gate_correct(ok, limit, chunks):
  match ok:
    case False{}: {==}
    case True{}: {==}

law merkleize_correct:
  for +limit: Nat
  for +chunks: +List<+List<U32>>
  for +size: Nat
  {I.merkleize(limit, chunks, I.zeros(size)) == Limits.merkleize(limit, chunks) : Maybe<&2, +List<U32>>}
def merkleize_correct(limit, chunks, size):
  %ListLaws.length_correct(+List<U32>, chunks) : {I.merkleize(limit, chunks, I.zeros(size)) == Limits.gate(Nat.is_le(_, limit), limit, chunks) : Maybe<&2, +List<U32>>}
  Equal.trans(Maybe<&2, +List<U32>>, I.merkleize(limit, chunks, I.zeros(size)), checked_gate(Nat.is_le(Lists.length(+List<U32>, chunks), limit), T.valid_go(chunks, True{}), Limits.depth(limit), chunks), Limits.gate(Nat.is_le(Lists.length(+List<U32>, chunks), limit), limit, chunks), combined_gate_correct(Nat.is_le(Lists.length(+List<U32>, chunks), limit), T.valid_go(chunks, True{}), Limits.depth(limit), chunks, size), limit_gate_correct(Nat.is_le(Lists.length(+List<U32>, chunks), limit), limit, chunks))
