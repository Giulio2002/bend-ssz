import Base
import ./tree.bend as T
import ./merkle.bend as M
import ./sha256.bend as H
import ./primitives.bend as P
import ./limits.bend as Limits
import ./lists.bend as Lists

# Per-public-root memo table: hashes are computed with the pinned SHA API,
# never stored expected roots. A cache miss computes the ordinary zero subtree,
# so cache size imposes no limit on legal tree depths.
def build(n: Nat, +current: +List<U32>) -> +List<+List<U32>>:
  match n:
    case 0n: [current]
    case 1n+p: current <> build(p, H.hash(List.append(&2, U32, current, current)))

def zeros(size: Nat) -> +List<+List<U32>>: build(size, P.pad(32n, []))

def lookup(n: Nat, table: +List<+List<U32>>, original: Nat) -> +List<U32>:
  match n table:
    case 0n Nil{}: M.zero_hash(original)
    case 1n+p Nil{}: M.zero_hash(original)
    case 0n Con{h, t}: h
    case 1n+p Con{h, t}: lookup(p, t, original)

def consume(+depth: Nat, chunks: +List<+List<U32>>, +table: +List<+List<U32>>) -> (+List<U32> & +List<+List<U32>>):
  match depth:
    case 0n:
      match chunks:
        case Nil{}: (P.pad(32n, []), [])
        case Con{h, t}: (h, t)
    case 1n+p:
      match chunks:
        case Nil{}: (lookup(1n+p, table, 1n+p), [])
        case Con{h, t}: T.branch(rest => consume(p, rest, table), consume(p, h <> t, table))

def gate(ok: Bool, depth: Nat, chunks: +List<+List<U32>>, table: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: T.finish(consume(depth, chunks, table))

def merkleize(+limit: Nat, +chunks: +List<+List<U32>>, table: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  gate(Bool.and(T.valid_go(chunks, True{}), Nat.is_le(Lists.length(+List<U32>, chunks), limit)), Limits.depth(limit), chunks, table)

def join(pair: +List<U32> & +List<+List<U32>>, next: +List<+List<U32>> -> +List<U32>) -> +List<U32>:
  (right, rest) = pair
  H.hash(Lists.append(U32, next(rest), right))

def progressive_go(fuel: Nat, +depth: Nat, chunks: +List<+List<U32>>, +table: +List<+List<U32>>) -> +List<U32>:
  match fuel:
    case 0n: P.pad(32n, [])
    case 1n+p:
      match chunks:
        case Nil{}: P.pad(32n, [])
        case Con{h, t}: join(consume(depth, h <> t, table), rest => progressive_go(p, 2n+depth, rest, table))

def progressive_gate(ok: Bool, +chunks: +List<+List<U32>>, table: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{progressive_go(Lists.length(+List<U32>, chunks), 0n, chunks, table)}

def progressive(+chunks: +List<+List<U32>>, table: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  progressive_gate(T.valid_go(chunks, True{}), chunks, table)
