import Base
import ./primitives.bend as P
import ./merkle.bend as M
import ./sha256.bend as H

# Consume a perfect subtree from a stream of chunks. Missing leaves are virtual;
# residual chunks make an over-capacity call fail at the public boundary.
def joined(left: +List<U32>, right: (+List<U32> & +List<+List<U32>>)) -> (+List<U32> & +List<+List<U32>>):
  match right:
    case (root, rest): (H.hash(List.append(&2, U32, left, root)), rest)

def branch(right: +List<+List<U32>> -> (+List<U32> & +List<+List<U32>>), left: (+List<U32> & +List<+List<U32>>)) -> (+List<U32> & +List<+List<U32>>):
  match left:
    case (root, rest): joined(root, right(rest))

def consume(+depth: Nat, chunks: +List<+List<U32>>) -> (+List<U32> & +List<+List<U32>>):
  match depth:
    case 0n:
      match chunks:
        case Nil{}: (M.zero_hash(0n), [])
        case Con{h, t}: (h, t)
    case 1n+p:
      match chunks:
        case Nil{}: (M.zero_hash(1n+p), [])
        case Con{h, t}:
          branch(consume(p), consume(p, h <> t))

def valid_go(chunks: +List<+List<U32>>, ok: Bool) -> Bool:
  match chunks:
    case Nil{}: ok
    case Con{h, t}: valid_go(t, Bool.and(ok, P.valid_bytes(32n, h)))

def finish(pair: (+List<U32> & +List<+List<U32>>)) -> Maybe<&2, +List<U32>>:
  match pair:
    case (root, rest):
      match rest:
        case Nil{}: Some{root}
        case Con{h, t}: None{}

def checked(ok: Bool, depth: Nat, chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: finish(consume(depth, chunks))

def merkleize_at_depth(depth: Nat, +chunks: +List<+List<U32>>) -> Maybe<&2, +List<U32>>:
  checked(valid_go(chunks, True{}), depth, chunks)
